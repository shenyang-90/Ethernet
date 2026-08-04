#ifndef TLM_HOST_H
#define TLM_HOST_H

/**
 * @file tlm_host.h
 * @brief Host/Driver TLM 2.0 Model
 *
 * 实现驱动发包线程、中断处理、CSR 访问、流量生成
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>

#include <vector>
#include <random>

#include "ethernet_types.h"
#include "ethernet_config.h"
#include "frame_payload.h"
#include "tlm_dma.h"

namespace ethernet_tlm {

/**
 * @class tlm_host
 * @brief Host 驱动事务级模型
 *
 * 建模内容：
 * - 驱动发包线程（描述符环管理）
 * - 中断处理（参数化延迟）
 * - CSR 读写
 * - 流量生成（可配置帧长分布、速率）
 *
 * 精度等级：Loosely-Timed (LT)
 */
class tlm_host : public sc_core::sc_module {
public:
    tlm_utils::simple_initiator_socket<tlm_host> csr_socket;

    // 统计
    uint64_t tx_frames_submitted = 0;
    uint64_t rx_frames_received = 0;
    uint64_t irq_count = 0;

    SC_HAS_PROCESS(tlm_host);

    /**
     * @brief Constructor
     * @param name Module name
     * @param cfg Model configuration
     * @param dma DMA reference
     */
    tlm_host(sc_core::sc_module_name name,
             const model_config& cfg = model_config(),
             tlm_dma* dma = nullptr)
        : sc_core::sc_module(name)
        , m_cfg(cfg)
        , m_dma(dma)
        , m_running(false)
        , m_tx_rate_mbps(1000.0)
        , m_frame_len_dist({64, 128, 256, 512, 1024, 1518})
        , m_frame_len_weights({1, 1, 1, 1, 1, 1})
        , m_irq_delay_ns(1000.0)
        , m_gen(m_rd())
    {
        csr_socket.register_nb_transport_bw(this, &tlm_host::csr_nb_transport_bw);
    }

    /**
     * @brief CSR backward
     */
    tlm::tlm_sync_enum csr_nb_transport_bw(tlm::tlm_generic_payload& trans,
                                            tlm::tlm_phase& phase,
                                            sc_core::sc_time& delay)
    {
        return tlm::TLM_ACCEPTED;
    }

    /**
     * @brief 启动流量生成
     */
    void start_traffic(double rate_mbps = 1000.0)
    {
        m_tx_rate_mbps = rate_mbps;
        m_running = true;
        sc_core::sc_spawn_options opts1;
        
        sc_core::sc_spawn([this]() { tx_process(); },
                          sc_core::sc_gen_unique_name("tx_process"), &opts1);
        sc_core::sc_spawn_options opts2;
        
        sc_core::sc_spawn([this]() { irq_process(); },
                          sc_core::sc_gen_unique_name("irq_process"), &opts2);
    }

    /**
     * @brief 停止流量生成
     */
    void stop_traffic()
    {
        m_running = false;
    }

    /**
     * @brief 设置帧长分布
     */
    void set_frame_length_distribution(const std::vector<uint32_t>& lengths,
                                       const std::vector<uint32_t>& weights)
    {
        m_frame_len_dist = lengths;
        m_frame_len_weights = weights;
    }

    /**
     * @brief 设置中断延迟
     */
    void set_irq_delay(double ns)
    {
        m_irq_delay_ns = ns;
    }

    /**
     * @brief CSR 读
     */
    uint32_t csr_read(uint64_t addr)
    {
        tlm::tlm_generic_payload trans;
        uint32_t data = 0;
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        trans.set_address(addr);
        trans.set_data_ptr(reinterpret_cast<uint8_t*>(&data));
        trans.set_data_length(4);
        trans.set_read();

        tlm::tlm_phase phase = tlm::BEGIN_REQ;
        csr_socket->nb_transport_fw(trans, phase, delay);

        return data;
    }

    /**
     * @brief CSR 写
     */
    void csr_write(uint64_t addr, uint32_t data)
    {
        tlm::tlm_generic_payload trans;
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        trans.set_address(addr);
        trans.set_data_ptr(reinterpret_cast<uint8_t*>(&data));
        trans.set_data_length(4);
        trans.set_write();

        tlm::tlm_phase phase = tlm::BEGIN_REQ;
        csr_socket->nb_transport_fw(trans, phase, delay);
    }

private:
    const model_config& m_cfg;
    tlm_dma* m_dma;
    bool m_running;

    // 流量配置
    double m_tx_rate_mbps;
    std::vector<uint32_t> m_frame_len_dist;
    std::vector<uint32_t> m_frame_len_weights;
    double m_irq_delay_ns;

    // 随机数
    std::random_device m_rd;
    std::mt19937 m_gen;

    /**
     * @brief TX 发包线程
     */
    void tx_process()
    {
        if (!m_dma) return;

        while (m_running) {
            // 选择帧长
            uint32_t frame_len = select_frame_length();

            // 计算帧间隔
            double bits = (frame_len + PREAMBLE_LEN + SFD_LEN + IFG_LEN) * 8.0;
            double interval_ns = bits / (m_tx_rate_mbps * 1e6) * 1e9;

            // 提交到 DMA
            int channel = select_tx_channel();
            uint64_t buffer_addr = 0x20000000 + tx_frames_submitted * 2048;

            if (m_dma->submit_tx_frame(channel, buffer_addr, frame_len)) {
                tx_frames_submitted++;
            }

            wait(sc_core::sc_time(interval_ns, sc_core::SC_NS));
        }
    }

    /**
     * @brief 中断处理线程
     */
    void irq_process()
    {
        if (!m_dma) return;

        while (m_running) {
            wait(m_dma->irq_event);

            // 模拟中断延迟
            wait(sc_core::sc_time(m_irq_delay_ns, sc_core::SC_NS));

            irq_count++;
            rx_frames_received++;
        }
    }

    /**
     * @brief 选择帧长
     */
    uint32_t select_frame_length()
    {
        std::discrete_distribution<> dist(m_frame_len_weights.begin(),
                                          m_frame_len_weights.end());
        return m_frame_len_dist[dist(m_gen)];
    }

    /**
     * @brief 选择 TX 通道
     */
    int select_tx_channel()
    {
        static int next_channel = 0;
        int ch = next_channel;
        next_channel = (next_channel + 1) % m_cfg.DMA_CH_COUNT;
        return ch;
    }
};

} // namespace ethernet_tlm

#endif // TLM_HOST_H
