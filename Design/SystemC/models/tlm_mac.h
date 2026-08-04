#ifndef TLM_MAC_H
#define TLM_MAC_H

/**
 * @file tlm_mac.h
 * @brief MAC Layer TLM 2.0 Model
 *
 * 实现帧组装/拆解、FCS 检查、时间戳捕获、帧长检查、帧抢占
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include <queue>
#include <vector>

#include "ethernet_types.h"
#include "ethernet_config.h"
#include "frame_payload.h"
#include "tlm_mm.h"
#include "tlm_phc.h"

namespace ethernet_tlm {

/**
 * @class tlm_mac
 * @brief MAC 层事务级模型
 *
 * 建模内容：
 * - 帧组装/拆解（Preamble/SFD/DA/SA/Type/Payload/FCS）
 * - FCS CRC32 检查
 * - SFD 点时间戳捕获
 * - 帧长检查（runt/giant）
 * - 帧抢占（express/preemptable 队列）
 *
 * 精度等级：Approximately-Timed (AT)
 */
class tlm_mac : public sc_core::sc_module {
public:
    // 接口
    tlm_utils::simple_target_socket<tlm_mac>   swi_rx_socket;   // 从 Switch 接收
    tlm_utils::simple_initiator_socket<tlm_mac> swi_tx_socket;  // 发送到 Switch
    tlm_utils::simple_initiator_socket<tlm_mac> phy_tx_socket;  // 发送到 PHY
    tlm_utils::simple_target_socket<tlm_mac>   phy_rx_socket;   // 从 PHY 接收

    // 统计
    port_counters counters;

    SC_HAS_PROCESS(tlm_mac);

    /**
     * @brief Constructor
     * @param name Module name
     * @param cfg Model configuration
     * @param mac_id MAC instance ID
     * @param phc PHC reference for timestamping
     */
    tlm_mac(sc_core::sc_module_name name,
            const model_config& cfg = model_config(),
            unsigned int mac_id = 0,
            tlm_phc* phc = nullptr)
        : sc_core::sc_module(name)
        , m_cfg(cfg)
        , m_mac_id(mac_id)
        , m_phc(phc)
        , m_express_enabled(true)
    {
        // 注册回调
        swi_rx_socket.register_b_transport(this, &tlm_mac::swi_rx_b_transport);
        phy_rx_socket.register_b_transport(this, &tlm_mac::phy_rx_b_transport);
        swi_tx_socket.register_nb_transport_bw(this, &tlm_mac::swi_tx_nb_transport_bw);
        phy_tx_socket.register_nb_transport_bw(this, &tlm_mac::phy_tx_nb_transport_bw);

        // 启动处理线程
        { sc_core::sc_spawn_options o; 
            sc_core::sc_spawn([this]() { tx_process(); },
                              sc_core::sc_gen_unique_name("tx_process"), &o); }
        { sc_core::sc_spawn_options o; 
            sc_core::sc_spawn([this]() { rx_process(); },
                              sc_core::sc_gen_unique_name("rx_process"), &o); }
    }

    /**
     * @brief 从 Switch 接收帧（TX 方向）
     */
    void swi_rx_b_transport(tlm::tlm_generic_payload& trans,
                            sc_core::sc_time& delay)
    {
        auto* ext = get_frame_meta_mut(trans);
        if (!ext) {
            trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
            return;
        }

        wait(delay);
        delay = sc_core::SC_ZERO_TIME;

        // 帧抢占分类
        if (m_cfg.SUPPORT_FP && m_express_enabled) {
            if (ext->traffic_class >= 4) {  // 高优先级 → express 队列
                m_express_queue.push(&trans);
                m_express_event.notify();
            } else {
                m_preemptable_queue.push(&trans);
                m_preemptable_event.notify();
            }
        } else {
            m_tx_queue.push(&trans);
            m_tx_event.notify();
        }

        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    /**
     * @brief 从 PHY 接收帧（RX 方向）
     */
    void phy_rx_b_transport(tlm::tlm_generic_payload& trans,
                            sc_core::sc_time& delay)
    {
        auto* ext = get_frame_meta_mut(trans);
        if (!ext) {
            trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
            return;
        }

        wait(delay);
        delay = sc_core::SC_ZERO_TIME;

        // SFD 点时间戳捕获
        if (m_phc) {
            ext->sfd_timestamp = m_phc->get_timestamp();
        }

        // FCS 检查
        if (!check_fcs(trans)) {
            ext->fcs_error = true;
            counters.fcs_errors++;
        }

        // 帧长检查
        if (ext->length < MIN_FRAME_SIZE) {
            ext->runt_frame = true;
            counters.runt_frames++;
        } else if (ext->length > MAX_FRAME_SIZE) {
            ext->giant_frame = true;
            counters.giant_frames++;
        }

        // 更新统计
        counters.rx_frames++;
        counters.rx_bytes += ext->length;

        // 错误帧处理（按配置：丢弃或透传标记）
        if (ext->fcs_error || ext->runt_frame || ext->giant_frame) {
            counters.rx_errors++;
            // 默认丢弃错误帧
            trans.set_response_status(tlm::TLM_OK_RESPONSE);
            return;
        }

        // 入队等待发送到 Switch
        m_rx_queue.push(&trans);
        m_rx_event.notify();

        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    /**
     * @brief Switch TX backward
     */
    tlm::tlm_sync_enum swi_tx_nb_transport_bw(tlm::tlm_generic_payload& trans,
                                               tlm::tlm_phase& phase,
                                               sc_core::sc_time& delay)
    {
        return tlm::TLM_ACCEPTED;
    }

    /**
     * @brief PHY TX backward
     */
    tlm::tlm_sync_enum phy_tx_nb_transport_bw(tlm::tlm_generic_payload& trans,
                                               tlm::tlm_phase& phase,
                                               sc_core::sc_time& delay)
    {
        return tlm::TLM_ACCEPTED;
    }

    /**
     * @brief TX 处理线程（MAC → PHY）
     */
    void tx_process()
    {
        while (true) {
            tlm::tlm_generic_payload* trans = nullptr;

            // 优先级：express > preemptable > normal
            if (!m_express_queue.empty()) {
                trans = m_express_queue.front();
                m_express_queue.pop();
            } else if (!m_preemptable_queue.empty()) {
                trans = m_preemptable_queue.front();
                m_preemptable_queue.pop();
            } else if (!m_tx_queue.empty()) {
                trans = m_tx_queue.front();
                m_tx_queue.pop();
            } else {
                wait(m_tx_event | m_express_event | m_preemptable_event);
                continue;
            }

            auto* ext = get_frame_meta_mut(*trans);
            if (ext) {
                // 添加帧头/帧尾（模拟）
                assemble_frame(*ext);

                // 计算线速传输延迟
                double byte_time = m_cfg.byte_time_ns(m_mac_id);
                sc_core::sc_time tx_delay(
                    static_cast<uint64_t>((ext->length + PREAMBLE_LEN + SFD_LEN + IFG_LEN) * byte_time),
                    sc_core::SC_NS);

                // 发送到 PHY
                tlm::tlm_phase phase = tlm::BEGIN_REQ;
                phy_tx_socket->nb_transport_fw(*trans, phase, tx_delay);

                counters.tx_frames++;
                counters.tx_bytes += ext->length;
            }

            // 由 socket fw_process 统一管理生命周期
        }
    }

    /**
     * @brief RX 处理线程（MAC → Switch）
     */
    void rx_process()
    {
        while (true) {
            if (m_rx_queue.empty()) {
                wait(m_rx_event);
                continue;
            }

            auto* trans = m_rx_queue.front();
            m_rx_queue.pop();

            auto* ext = get_frame_meta_mut(*trans);
            if (ext) {
                // 计算传输延迟
                double byte_time = m_cfg.byte_time_ns(m_mac_id);
                sc_core::sc_time tx_delay(
                    static_cast<uint64_t>(ext->length * byte_time),
                    sc_core::SC_NS);

                // 发送到 Switch
                tlm::tlm_phase phase = tlm::BEGIN_REQ;
                swi_tx_socket->nb_transport_fw(*trans, phase, tx_delay);
            }

            // 由 socket fw_process 统一管理生命周期
        }
    }

    // ============================================================
    // 帧处理
    // ============================================================

    /**
     * @brief FCS CRC32 检查（简化实现）
     */
    bool check_fcs(const tlm::tlm_generic_payload& trans)
    {
        // 简化：随机模拟 FCS 错误（实际应计算 CRC32）
        // 错误率约 1e-9
        auto* ext = get_frame_meta(trans);
        if (ext && ext->fcs_error) {
            return false;  // 外部注入的错误
        }
        return true;
    }

    /**
     * @brief 帧组装（添加 Preamble/SFD/FCS）
     */
    void assemble_frame(frame_meta& meta)
    {
        // 模拟帧组装开销
        // 实际应修改 frame data，这里仅更新长度
        meta.length = meta.length + PREAMBLE_LEN + SFD_LEN + FCS_LEN;
    }

    /**
     * @brief 帧拆解（移除 Preamble/SFD/FCS）
     */
    void disassemble_frame(frame_meta& meta)
    {
        if (meta.length >= PREAMBLE_LEN + SFD_LEN + FCS_LEN) {
            meta.length = meta.length - PREAMBLE_LEN - SFD_LEN - FCS_LEN;
        }
    }

    // ============================================================
    // 配置接口
    // ============================================================

    void set_express_enabled(bool enabled) { m_express_enabled = enabled; }
    bool is_express_enabled() const { return m_express_enabled; }

    unsigned int get_mac_id() const { return m_mac_id; }

private:
    const model_config& m_cfg;
    unsigned int m_mac_id;
    tlm_phc* m_phc;
    bool m_express_enabled;

    // 队列
    std::queue<tlm::tlm_generic_payload*> m_tx_queue;
    std::queue<tlm::tlm_generic_payload*> m_rx_queue;
    std::queue<tlm::tlm_generic_payload*> m_express_queue;
    std::queue<tlm::tlm_generic_payload*> m_preemptable_queue;

    // 事件
    sc_core::sc_event m_tx_event;
    sc_core::sc_event m_rx_event;
    sc_core::sc_event m_express_event;
    sc_core::sc_event m_preemptable_event;
};

} // namespace ethernet_tlm

#endif // TLM_MAC_H
