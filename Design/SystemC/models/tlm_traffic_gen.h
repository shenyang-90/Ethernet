#ifndef TLM_TRAFFIC_GEN_H
#define TLM_TRAFFIC_GEN_H

/**
 * @file tlm_traffic_gen.h
 * @brief Traffic Generator TLM 2.0 Model
 *
 * 实现线速帧生成、错误注入、流量模式控制
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include <vector>
#include <random>
#include <map>

#include "ethernet_types.h"
#include "ethernet_config.h"
#include "frame_payload.h"
#include "tlm_mm.h"

namespace ethernet_tlm {

/**
 * @class tlm_traffic_gen
 * @brief Traffic Generator 事务级模型
 *
 * 建模内容：
 * - 线速帧生成（可配置速率、帧长分布）
 * - 错误注入（FCS 错误、runt/giant 帧）
 * - 流量模式（单播/多播/广播混合）
 *
 * 精度等级：Loosely-Timed (LT)
 */
class tlm_traffic_gen : public sc_core::sc_module {
public:
    tlm_utils::simple_initiator_socket<tlm_traffic_gen> socket;      // TX: 发送到 MAC
    tlm_utils::simple_target_socket<tlm_traffic_gen>   rx_socket;   // RX: 从 MAC 接收

    // 统计
    uint64_t tx_frames = 0;
    uint64_t tx_bytes = 0;
    uint64_t rx_frames = 0;
    uint64_t rx_bytes = 0;
    uint64_t fcs_errors_injected = 0;
    uint64_t runt_frames_injected = 0;
    uint64_t giant_frames_injected = 0;

    SC_HAS_PROCESS(tlm_traffic_gen);

    /**
     * @brief Constructor
     * @param name Module name
     * @param cfg Model configuration
     * @param port_id Port ID
     */
    tlm_traffic_gen(sc_core::sc_module_name name,
                    const model_config& cfg = model_config(),
                    unsigned int port_id = 0)
        : sc_core::sc_module(name)
        , socket("socket")
        , rx_socket("rx_socket")
        , m_cfg(cfg)
        , m_port_id(port_id)
        , m_running(false)
        , m_rate_mbps(5000.0)
        , m_dst_port(1)
        , m_error_rate(0.0)
        , m_gen(m_rd())
        , m_next_frame_id(0)
    {
        socket.register_nb_transport_bw(this, &tlm_traffic_gen::nb_transport_bw);
        rx_socket.register_b_transport(this, &tlm_traffic_gen::rx_b_transport);

        // 默认 MAC 地址
        m_src_mac = {0x00, 0x11, 0x22, 0x33, 0x44,
                     static_cast<uint8_t>(0x50 + port_id)};
        m_dst_mac = {0x00, 0x11, 0x22, 0x33, 0x44,
                     static_cast<uint8_t>(0x60 + m_dst_port)};
    }

    /**
     * @brief TLM backward
     */
    tlm::tlm_sync_enum nb_transport_bw(tlm::tlm_generic_payload& trans,
                                        tlm::tlm_phase& phase,
                                        sc_core::sc_time& delay)
    {
        return tlm::TLM_ACCEPTED;
    }

    /**
     * @brief RX 接收处理（从 MAC 接收帧）
     */
    void rx_b_transport(tlm::tlm_generic_payload& trans,
                        sc_core::sc_time& delay)
    {
        auto* ext = get_frame_meta(trans);
        if (ext) {
            rx_frames++;
            rx_bytes += ext->length;
        }
        wait(delay);
        delay = sc_core::SC_ZERO_TIME;
        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    /**
     * @brief 启动流量生成
     */
    void start(double rate_mbps = 0.0)
    {
        if (rate_mbps > 0.0) {
            m_rate_mbps = rate_mbps;
        }
        m_running = true;
        sc_core::sc_spawn_options opts;
        
        sc_core::sc_spawn([this]() { generate_process(); },
                          sc_core::sc_gen_unique_name("generate_process"), &opts);
    }

    /**
     * @brief 停止流量生成
     */
    void stop()
    {
        m_running = false;
    }

    /**
     * @brief 设置目的端口
     */
    void set_dst_port(unsigned int dst_port)
    {
        m_dst_port = dst_port;
        m_dst_mac[5] = static_cast<uint8_t>(0x60 + dst_port);
    }

    /**
     * @brief 设置源 MAC
     */
    void set_src_mac(const mac_addr_t& mac)
    {
        m_src_mac = mac;
    }

    /**
     * @brief 设置目的 MAC
     */
    void set_dst_mac(const mac_addr_t& mac)
    {
        m_dst_mac = mac;
    }

    /**
     * @brief 设置错误注入率 (0.0 ~ 1.0)
     */
    void set_error_rate(double rate)
    {
        m_error_rate = rate;
    }

    /**
     * @brief 注入 FCS 错误
     */
    void inject_fcs_error()
    {
        m_inject_fcs_error = true;
    }

    /**
     * @brief 注入 runt 帧
     */
    void inject_runt_frame()
    {
        m_inject_runt = true;
    }

    /**
     * @brief 注入 giant 帧
     */
    void inject_giant_frame()
    {
        m_inject_giant = true;
    }

private:
    const model_config& m_cfg;
    unsigned int m_port_id;
    bool m_running;

    // 流量配置
    double m_rate_mbps;
    unsigned int m_dst_port;
    double m_error_rate;

    // MAC 地址
    mac_addr_t m_src_mac;
    mac_addr_t m_dst_mac;

    // 错误注入标志
    bool m_inject_fcs_error = false;
    bool m_inject_runt = false;
    bool m_inject_giant = false;

    // 随机数
    std::random_device m_rd;
    std::mt19937 m_gen;
    uint64_t m_next_frame_id;

    /**
     * @brief 帧生成线程
     */
    void generate_process()
    {
        // 默认帧长分布
        std::vector<uint32_t> lengths = {64, 128, 256, 512, 1024, 1518};
        std::vector<uint32_t> weights = {1, 1, 1, 1, 1, 1};
        std::discrete_distribution<> len_dist(weights.begin(), weights.end());

        while (m_running) {
            // 选择帧长
            uint32_t frame_len = lengths[len_dist(m_gen)];

            // 处理错误注入
            bool fcs_error = m_inject_fcs_error ||
                             (m_error_rate > 0.0 &&
                              std::uniform_real_distribution<>(0.0, 1.0)(m_gen) < m_error_rate);
            bool runt = m_inject_runt;
            bool giant = m_inject_giant;

            if (runt) {
                frame_len = 32;  // < 64B
                m_inject_runt = false;
                runt_frames_injected++;
            } else if (giant) {
                frame_len = 10000;  // > 9018B
                m_inject_giant = false;
                giant_frames_injected++;
            }

            if (fcs_error) {
                fcs_errors_injected++;
                m_inject_fcs_error = false;
            }

            // 创建 transaction
            frame_meta meta;
            meta.frame_id = m_next_frame_id++;
            meta.length = frame_len;
            meta.src_mac = m_src_mac;
            meta.dst_mac = m_dst_mac;
            meta.src_port = m_port_id;
            meta.ether_type = 0x0800;
            meta.fcs_error = fcs_error;
            meta.runt_frame = runt;
            meta.giant_frame = giant;
            meta.ingress_time = sc_core::sc_time_stamp();

            auto* trans = create_frame_payload(meta);
            std::vector<uint8_t> data(frame_len, 0xAA);
            trans->set_data_ptr(data.data());
            trans->set_data_length(frame_len);

            // 计算帧间隔
            double bits = (frame_len + PREAMBLE_LEN + SFD_LEN + IFG_LEN) * 8.0;
            double interval_ns = bits / (m_rate_mbps * 1e6) * 1e9;

            // 发送
            tlm::tlm_phase phase = tlm::BEGIN_REQ;
            sc_core::sc_time delay = sc_core::SC_ZERO_TIME;
            socket->nb_transport_fw(*trans, phase, delay);

            tx_frames++;
            tx_bytes += frame_len;

            // 注意：不调用 trans->release()，由接收方（simple_target_socket 的 nb2b_thread）负责释放

            wait(sc_core::sc_time(interval_ns, sc_core::SC_NS));
        }
    }
};

} // namespace ethernet_tlm

#endif // TLM_TRAFFIC_GEN_H
