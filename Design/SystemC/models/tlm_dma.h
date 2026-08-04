#ifndef TLM_DMA_H
#define TLM_DMA_H

/**
 * @file tlm_dma.h
 * @brief DMA Engine TLM 2.0 Model
 *
 * 实现描述符环、通道池仲裁、AXI burst 传输、帧数据读写
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include <deque>
#include <map>
#include <vector>

#include "ethernet_types.h"
#include "ethernet_config.h"
#include "frame_payload.h"
#include "tlm_mm.h"

namespace ethernet_tlm {

/**
 * @class tlm_dma
 * @brief DMA Engine 事务级模型
 *
 * 建模内容：
 * - 描述符环管理（fetch/write-back）
 * - 通道池仲裁（轮询）
 * - AXI burst 传输
 * - 帧数据读写（TX/RX）
 * - 描述符错误检测
 *
 * 精度等级：LT + 时间标注
 */
class tlm_dma : public sc_core::sc_module {
public:
    // 接口
    tlm_utils::simple_initiator_socket<tlm_dma> axi_socket;      // AXI Master 到内存
    tlm_utils::simple_target_socket<tlm_dma>   csr_socket;       // CSR 访问
    tlm_utils::simple_initiator_socket<tlm_dma> swi_tx_socket;   // 到 Switch
    tlm_utils::simple_target_socket<tlm_dma>   swi_rx_socket;    // 从 Switch

    // 中断
    sc_core::sc_event irq_event;

    // 统计
    std::vector<port_counters> channel_counters;
    uint64_t axi_total_bytes = 0;
    uint64_t axi_total_beats = 0;

    SC_HAS_PROCESS(tlm_dma);

    /**
     * @brief Constructor
     * @param name Module name
     * @param cfg Model configuration
     */
    explicit tlm_dma(sc_core::sc_module_name name,
                     const model_config& cfg = model_config())
        : sc_core::sc_module(name)
        , m_cfg(cfg)
    {
        // 注册回调
        csr_socket.register_b_transport(this, &tlm_dma::csr_b_transport);
        swi_rx_socket.register_b_transport(this, &tlm_dma::swi_rx_b_transport);
        axi_socket.register_nb_transport_bw(this, &tlm_dma::axi_nb_transport_bw);
        swi_tx_socket.register_nb_transport_bw(this, &tlm_dma::swi_tx_nb_transport_bw);

        // 初始化通道
        channel_counters.resize(m_cfg.DMA_CH_COUNT);
        for (unsigned int i = 0; i < m_cfg.DMA_CH_COUNT; ++i) {
            m_channels.push_back(std::make_unique<channel_state>());
            m_channels[i]->channel_id = i;
            m_channels[i]->mac_id = i / m_cfg.DMA_CH_PER_MAC;
        }

        // 启动通道处理线程（合并为 1 个轮询线程，减少线程数）
        {
            sc_core::sc_spawn_options opts;
            sc_core::sc_spawn([this]() { channel_process_all(); },
                              sc_core::sc_gen_unique_name("channel_process_all"), &opts);
        }
    }

    /**
     * @brief CSR 访问
     */
    void csr_b_transport(tlm::tlm_generic_payload& trans,
                         sc_core::sc_time& delay)
    {
        wait(delay);
        delay = sc_core::SC_ZERO_TIME;

        auto addr = trans.get_address();
        auto* data = trans.get_data_ptr();
        auto len = trans.get_data_length();

        if (trans.is_read()) {
            // CSR 读
            memset(data, 0, len);
        } else {
            // CSR 写
        }

        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    /**
     * @brief 从 Switch 接收帧（RX 方向）
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

        // 分配到通道
        int ch = select_channel(ext->src_port);
        if (ch < 0) {
            trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
            return;
        }

        // 创建描述符并写入内存
        dma_descriptor desc;
        desc.buffer_addr = allocate_buffer(ext->length);
        desc.length = ext->length;
        desc.own = true;
        desc.first_desc = true;
        desc.last_desc = true;
        desc.timestamp = ext->sfd_timestamp.to_seconds() * 1e9;
        desc.vlan_tag = ext->vlan_id;
        desc.traffic_class = ext->traffic_class;
        desc.src_port = ext->src_port;
        desc.channel_id = ch;
        desc.valid = true;

        // 写帧数据到内存（模拟 AXI burst）
        write_frame_to_memory(desc, trans);

        // 写描述符到内存
        write_descriptor_to_memory(desc);

        // 更新统计
        channel_counters[ch].rx_frames++;
        channel_counters[ch].rx_bytes += ext->length;

        // 触发中断
        irq_event.notify();

        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    /**
     * @brief AXI backward
     */
    tlm::tlm_sync_enum axi_nb_transport_bw(tlm::tlm_generic_payload& trans,
                                            tlm::tlm_phase& phase,
                                            sc_core::sc_time& delay)
    {
        return tlm::TLM_ACCEPTED;
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
     * @brief 提交 TX 帧（Host 调用）
     */
    bool submit_tx_frame(int channel_id, uint64_t buffer_addr, uint32_t length)
    {
        if (channel_id < 0 || channel_id >= static_cast<int>(m_cfg.DMA_CH_COUNT)) {
            return false;
        }

        auto& ch = *m_channels[channel_id];
        dma_descriptor desc;
        desc.buffer_addr = buffer_addr;
        desc.length = length;
        desc.own = false;  // Host owns
        desc.first_desc = true;
        desc.last_desc = true;
        desc.channel_id = channel_id;
        desc.valid = true;

        ch.tx_queue.push_back(desc);
        ch.tx_event->notify();

        return true;
    }

    /**
     * @brief 获取通道状态
     */
    size_t get_channel_queue_size(int channel_id) const
    {
        if (channel_id < 0 || channel_id >= static_cast<int>(m_cfg.DMA_CH_COUNT)) {
            return 0;
        }
        return m_channels[channel_id]->tx_queue.size();
    }

private:
    const model_config& m_cfg;

    // 通道状态
    struct channel_state {
        int channel_id = -1;
        int mac_id = -1;
        std::deque<dma_descriptor> tx_queue;
        std::unique_ptr<sc_core::sc_event> tx_event;
        bool error = false;

        channel_state() : tx_event(std::make_unique<sc_core::sc_event>()) {}
    };
    std::vector<std::unique_ptr<channel_state>> m_channels;

    // 内存模拟
    std::map<uint64_t, std::vector<uint8_t>> m_memory;
    uint64_t m_next_buffer_addr = 0x4000000;

    /**
     * @brief 单通道处理（原 channel_process，保留供参考）
     */
    void channel_process(int channel_id)
    {
        auto& ch = *m_channels[channel_id];

        while (true) {
            if (ch.tx_queue.empty()) {
                wait(*ch.tx_event);
                continue;
            }

            auto desc = ch.tx_queue.front();
            ch.tx_queue.pop_front();

            // 检查描述符错误
            if (desc.own) {
                // OWN bit 冲突
                ch.error = true;
                channel_counters[channel_id].rx_errors++;
                irq_event.notify();
                continue;
            }

            // 从内存读帧数据
            auto frame_data = read_frame_from_memory(desc);

            // 创建 transaction 发送到 Switch
            frame_meta meta;
            meta.frame_id = reinterpret_cast<uint64_t>(this);
            meta.length = desc.length;
            meta.buffer_addr = desc.buffer_addr;
            meta.dma_channel = channel_id;

            auto* trans = create_frame_payload(meta);
            trans->set_data_ptr(frame_data.data());
            trans->set_data_length(desc.length);

            // 计算 AXI 延迟
            sc_core::sc_time axi_delay = compute_axi_delay(desc.length);

            // 发送到 Switch
            tlm::tlm_phase phase = tlm::BEGIN_REQ;
            swi_tx_socket->nb_transport_fw(*trans, phase, axi_delay);

            // 更新统计
            channel_counters[channel_id].tx_frames++;
            channel_counters[channel_id].tx_bytes += desc.length;
        }
    }

    /**
     * @brief 全通道轮询处理（合并线程，减少线程数）
     *
     * 每周期轮询所有通道，处理每个通道的待发送描述符
     */
    void channel_process_all()
    {
        while (true) {
            bool any_work = false;

            // 轮询所有通道
            for (unsigned int channel_id = 0; channel_id < m_cfg.DMA_CH_COUNT; ++channel_id) {
                auto& ch = *m_channels[channel_id];

                if (ch.tx_queue.empty()) continue;
                any_work = true;

                auto desc = ch.tx_queue.front();
                ch.tx_queue.pop_front();

                // 检查描述符错误
                if (desc.own) {
                    // OWN bit 冲突
                    ch.error = true;
                    channel_counters[channel_id].rx_errors++;
                    irq_event.notify();
                    continue;
                }

                // 从内存读帧数据
                auto frame_data = read_frame_from_memory(desc);

                // 创建 transaction 发送到 Switch
                frame_meta meta;
                meta.frame_id = reinterpret_cast<uint64_t>(this);
                meta.length = desc.length;
                meta.buffer_addr = desc.buffer_addr;
                meta.dma_channel = channel_id;

                auto* trans = create_frame_payload(meta);
                trans->set_data_ptr(frame_data.data());
                trans->set_data_length(desc.length);

                // 计算 AXI 延迟
                sc_core::sc_time axi_delay = compute_axi_delay(desc.length);

                // 发送到 Switch
                tlm::tlm_phase phase = tlm::BEGIN_REQ;
                swi_tx_socket->nb_transport_fw(*trans, phase, axi_delay);

                // 更新统计
                channel_counters[channel_id].tx_frames++;
                channel_counters[channel_id].tx_bytes += desc.length;
            }

            // 无工作时等待，有工作时继续轮询
            if (!any_work) {
                // 固定轮询间隔（简化，避免 sc_event_or_list 与 sc_time 组合问题）
                wait(sc_core::sc_time(1, sc_core::SC_US));
            }
        }
    }

    /**
     * @brief 选择通道
     */
    int select_channel(int port_id) const
    {
        // 轮询选择该 MAC 的通道
        static std::map<int, int> last_channel;
        int base = port_id * m_cfg.DMA_CH_PER_MAC;
        int next = (last_channel[port_id] + 1) % m_cfg.DMA_CH_PER_MAC;
        last_channel[port_id] = next;
        return base + next;
    }

    /**
     * @brief 分配缓冲区
     */
    uint64_t allocate_buffer(uint32_t size)
    {
        uint64_t addr = m_next_buffer_addr;
        m_next_buffer_addr += ((size + 63) / 64) * 64;  // 64-byte 对齐
        return addr;
    }

    /**
     * @brief 计算 AXI 传输延迟
     */
    sc_core::sc_time compute_axi_delay(uint32_t bytes) const
    {
        unsigned int beats = (bytes + m_cfg.AXI_DATA_WIDTH / 8 - 1) / (m_cfg.AXI_DATA_WIDTH / 8);
        double ns = beats * m_cfg.beat_time_ns();
        return sc_core::sc_time(ns, sc_core::SC_NS);
    }

    /**
     * @brief 写帧数据到内存
     */
    void write_frame_to_memory(const dma_descriptor& desc,
                               tlm::tlm_generic_payload& trans)
    {
        std::vector<uint8_t> data(desc.length, 0);
        if (trans.get_data_ptr() != nullptr) {
            memcpy(data.data(), trans.get_data_ptr(), desc.length);
        }
        m_memory[desc.buffer_addr] = data;

        axi_total_bytes += desc.length;
        axi_total_beats += (desc.length + m_cfg.AXI_DATA_WIDTH / 8 - 1) / (m_cfg.AXI_DATA_WIDTH / 8);
    }

    /**
     * @brief 从内存读帧数据
     */
    std::vector<uint8_t> read_frame_from_memory(const dma_descriptor& desc)
    {
        auto it = m_memory.find(desc.buffer_addr);
        if (it != m_memory.end()) {
            return it->second;
        }
        return std::vector<uint8_t>(desc.length, 0);
    }

    /**
     * @brief 写描述符到内存
     */
    void write_descriptor_to_memory(const dma_descriptor& desc)
    {
        // 描述符写入延迟
        sc_core::sc_time delay = compute_axi_delay(m_cfg.DESC_SIZE);
        axi_total_bytes += m_cfg.DESC_SIZE;
    }
};

} // namespace ethernet_tlm

#endif // TLM_DMA_H
