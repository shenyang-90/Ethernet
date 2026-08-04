#ifndef TLM_PHC_H
#define TLM_PHC_H

/**
 * @file tlm_phc.h
 * @brief PHC (PTP Hardware Clock) TLM 2.0 Model
 *
 * 实现 64-bit 纳秒计数器、Addend 频率调整、时间戳捕获、P2P 延迟测量
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>

#include <deque>

#include "ethernet_types.h"
#include "ethernet_config.h"

namespace ethernet_tlm {

/**
 * @class tlm_phc
 * @brief PHC 时钟事务级模型
 *
 * 建模内容：
 * - 64-bit 纳秒计数器（sc_time 累加）
 * - Addend 频率调整机制
 * - 时间戳捕获点（SFD 级）
 * - P2P 路径延迟测量抽象
 *
 * 精度等级：Loosely-Timed (LT) + 时间标注
 */
class tlm_phc : public sc_core::sc_module {
public:
    tlm_utils::simple_target_socket<tlm_phc> socket;

    SC_HAS_PROCESS(tlm_phc);

    /**
     * @brief Constructor
     * @param name Module name
     * @param cfg Model configuration
     * @param phc_id PHC instance ID
     */
    tlm_phc(sc_core::sc_module_name name,
            const model_config& cfg = model_config(),
            unsigned int phc_id = 0)
        : sc_core::sc_module(name)
        , m_cfg(cfg)
        , m_phc_id(phc_id)
        , m_addend(0xFFFFFFFFULL)  // 默认接近 1:1 频率 (2^32 - 1)
        , m_offset(0, sc_core::SC_NS)
        , m_last_update(sc_core::SC_ZERO_TIME)
        , m_accumulated(0, sc_core::SC_NS)
    {
        socket.register_b_transport(this, &tlm_phc::b_transport);

        // 启动时钟更新线程
        { sc_core::sc_spawn_options o; 
            sc_core::sc_spawn([this]() { clock_process(); },
                              sc_core::sc_gen_unique_name("clock_process"), &o); }
    }

    /**
     * @brief TLM blocking transport（CSR 访问）
     */
    void b_transport(tlm::tlm_generic_payload& trans,
                     sc_core::sc_time& delay)
    {
        wait(delay);
        delay = sc_core::SC_ZERO_TIME;

        // 简化的 CSR 访问
        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    /**
     * @brief 获取当前 PHC 时间戳
     */
    sc_core::sc_time get_timestamp() const
    {
        update_accumulated();
        return m_accumulated + m_offset;
    }

    /**
     * @brief 设置 PHC 时间
     */
    void set_time(const sc_core::sc_time& time)
    {
        update_accumulated();
        m_offset = time - m_accumulated;
    }

    /**
     * @brief 频率调整（Addend 机制）
     * @param addend 32-bit addend 值，每周期累加 addend/2^32 个时钟周期
     */
    void adjust_freq(uint32_t addend)
    {
        update_accumulated();
        m_addend = addend;
    }

    /**
     * @brief 偏移调整
     */
    void adjust_offset(const sc_core::sc_time& offset)
    {
        update_accumulated();
        m_offset += offset;
    }

    /**
     * @brief 获取 Addend 值
     */
    uint32_t get_addend() const { return m_addend; }

    /**
     * @brief 获取 PHC ID
     */
    unsigned int get_phc_id() const { return m_phc_id; }

    // ============================================================
    // P2P 延迟测量
    // ============================================================

    /**
     * @brief 记录 Pdelay_Req 发送时间戳
     */
    void record_pdelay_req_tx(uint64_t sequence_id)
    {
        m_pdelay_req_tx[sequence_id] = get_timestamp();
    }

    /**
     * @brief 记录 Pdelay_Req 接收时间戳
     */
    void record_pdelay_req_rx(uint64_t sequence_id)
    {
        m_pdelay_req_rx[sequence_id] = get_timestamp();
    }

    /**
     * @brief 记录 Pdelay_Resp 发送时间戳
     */
    void record_pdelay_resp_tx(uint64_t sequence_id)
    {
        m_pdelay_resp_tx[sequence_id] = get_timestamp();
    }

    /**
     * @brief 记录 Pdelay_Resp 接收时间戳
     */
    void record_pdelay_resp_rx(uint64_t sequence_id)
    {
        m_pdelay_resp_rx[sequence_id] = get_timestamp();
    }

    /**
     * @brief 计算 P2P 路径延迟
     * delay = (t4 - t1) - (t3 - t2) / 2
     */
    sc_core::sc_time compute_pdelay(uint64_t sequence_id) const
    {
        auto t1 = m_pdelay_req_tx.find(sequence_id);
        auto t2 = m_pdelay_req_rx.find(sequence_id);
        auto t3 = m_pdelay_resp_tx.find(sequence_id);
        auto t4 = m_pdelay_resp_rx.find(sequence_id);

        if (t1 == m_pdelay_req_tx.end() || t2 == m_pdelay_req_rx.end() ||
            t3 == m_pdelay_resp_tx.end() || t4 == m_pdelay_resp_rx.end()) {
            return sc_core::SC_ZERO_TIME;
        }

        auto delay = ((t4->second - t1->second) - (t3->second - t2->second)) / 2;
        return delay;
    }

private:
    const model_config& m_cfg;
    unsigned int m_phc_id;

    // Addend 频率调整
    uint32_t m_addend;

    // 时间偏移
    sc_core::sc_time m_offset;

    // 内部累加器
    mutable sc_core::sc_time m_last_update;
    mutable sc_core::sc_time m_accumulated;

    // P2P 时间戳记录
    std::map<uint64_t, sc_core::sc_time> m_pdelay_req_tx;
    std::map<uint64_t, sc_core::sc_time> m_pdelay_req_rx;
    std::map<uint64_t, sc_core::sc_time> m_pdelay_resp_tx;
    std::map<uint64_t, sc_core::sc_time> m_pdelay_resp_rx;

    /**
     * @brief 更新累加器（基于 Addend）
     */
    void update_accumulated() const
    {
        auto now = sc_core::sc_time_stamp();
        auto elapsed = now - m_last_update;

        // Addend 机制：每 ns 累加 addend/2^32 ns
        double addend_ratio = static_cast<double>(m_addend) / (1ULL << 32);
        double elapsed_ns = elapsed.to_seconds() * 1e9;
        double adjusted_ns = elapsed_ns * addend_ratio;

        m_accumulated += sc_core::sc_time(adjusted_ns, sc_core::SC_NS);
        m_last_update = now;
    }

    /**
     * @brief 时钟更新线程（保持活跃）
     */
    void clock_process()
    {
        while (true) {
            wait(sc_core::sc_time(1, sc_core::SC_US));
            update_accumulated();
        }
    }
};

} // namespace ethernet_tlm

#endif // TLM_PHC_H
