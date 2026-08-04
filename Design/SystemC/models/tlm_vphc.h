#ifndef TLM_VPHC_H
#define TLM_VPHC_H

/**
 * @file tlm_vphc.h
 * @brief vPHC (Virtual PHC) TLM 2.0 Model
 *
 * 实现 Xen IO Ring 虚拟化、VM 时间域映射、VM 切换
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>

#include <deque>
#include <map>

#include "ethernet_types.h"
#include "ethernet_config.h"
#include "tlm_phc.h"

namespace ethernet_tlm {

// Xen IO Ring 大小
static constexpr size_t VPHC_RING_SIZE = 32;

/**
 * @struct vphc_ring_entry
 * @brief Xen IO Ring 条目
 */
struct vphc_ring_entry {
    uint64_t request_id = 0;
    uint32_t vm_id = 0;
    uint64_t timestamp = 0;      // 请求/响应时间戳
    bool     is_response = false;
    bool     valid = false;
};

/**
 * @struct vm_time_domain
 * @brief VM 时间域配置
 */
struct vm_time_domain {
    double   offset_ns = 0.0;    // 时间偏移 (ns)
    double   scale_ppm = 0.0;    // 频率偏移 (ppm)
    uint64_t request_count = 0;  // 请求计数
};

/**
 * @class tlm_vphc
 * @brief vPHC 虚拟化事务级模型
 *
 * 建模内容：
 * - Xen IO Ring 生产者/消费者语义
 * - VM 时间域映射 (offset/scale 仿射变换)
 * - VM 切换序列
 * - 时间戳请求/响应处理
 *
 * 精度等级：Loosely-Timed (LT)
 */
class tlm_vphc : public sc_core::sc_module {
public:
    tlm_utils::simple_target_socket<tlm_vphc> socket;

    // VM 切换事件
    sc_core::sc_event vm_switch_event;

    SC_HAS_PROCESS(tlm_vphc);

    /**
     * @brief Constructor
     * @param name Module name
     * @param cfg Model configuration
     * @param phc PHC reference
     */
    tlm_vphc(sc_core::sc_module_name name,
             const model_config& cfg = model_config(),
             tlm_phc* phc = nullptr)
        : sc_core::sc_module(name)
        , m_cfg(cfg)
        , m_phc(phc)
        , m_current_vm(0)
        , m_req_prod(0)
        , m_req_cons(0)
        , m_rsp_prod(0)
        , m_rsp_cons(0)
    {
        socket.register_b_transport(this, &tlm_vphc::b_transport);

        // 初始化 VM 时间域
        m_vm_domains.resize(m_cfg.VPHC_VM_COUNT);
        for (size_t i = 0; i < m_vm_domains.size(); ++i) {
            m_vm_domains[i].offset_ns = static_cast<double>(i) * 1000000.0;  // 1ms 间隔
            m_vm_domains[i].scale_ppm = 0.0;
        }

        // 初始化 Ring
        m_req_ring.resize(VPHC_RING_SIZE);
        m_rsp_ring.resize(VPHC_RING_SIZE);

        // 启动处理线程
        { sc_core::sc_spawn_options o; 
            sc_core::sc_spawn([this]() { ring_process(); },
                              sc_core::sc_gen_unique_name("ring_process"), &o); }
    }

    /**
     * @brief TLM blocking transport（CSR/IO Ring 访问）
     */
    void b_transport(tlm::tlm_generic_payload& trans,
                     sc_core::sc_time& delay)
    {
        wait(delay);
        delay = sc_core::SC_ZERO_TIME;
        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    // ============================================================
    // VM 时间域操作
    // ============================================================

    /**
     * @brief 获取指定 VM 的虚拟时间
     */
    sc_core::sc_time get_vm_time(uint32_t vm_id) const
    {
        if (!m_phc || vm_id >= m_vm_domains.size()) {
            return sc_core::SC_ZERO_TIME;
        }

        auto phc_time = m_phc->get_timestamp();
        const auto& domain = m_vm_domains[vm_id];

        // 仿射变换: vm_time = phc_time * (1 + scale_ppm/1e6) + offset
        double phc_ns = phc_time.to_seconds() * 1e9;
        double scale_factor = 1.0 + domain.scale_ppm / 1e6;
        double vm_ns = phc_ns * scale_factor + domain.offset_ns;

        return sc_core::sc_time(vm_ns, sc_core::SC_NS);
    }

    /**
     * @brief 设置 VM 时间域参数
     */
    void set_vm_time_domain(uint32_t vm_id, double offset_ns, double scale_ppm)
    {
        if (vm_id < m_vm_domains.size()) {
            m_vm_domains[vm_id].offset_ns = offset_ns;
            m_vm_domains[vm_id].scale_ppm = scale_ppm;
        }
    }

    /**
     * @brief 获取当前活动 VM
     */
    uint32_t get_current_vm() const { return m_current_vm; }

    // ============================================================
    // VM 切换
    // ============================================================

    /**
     * @brief VM 切换
     */
    void switch_vm(uint32_t new_vm)
    {
        if (new_vm >= m_vm_domains.size() || new_vm == m_current_vm) {
            return;
        }

        uint32_t old_vm = m_current_vm;
        m_current_vm = new_vm;
        m_vm_switch_count++;

        vm_switch_event.notify();
    }

    /**
     * @brief 获取 VM 切换计数
     */
    uint64_t get_vm_switch_count() const { return m_vm_switch_count; }

    // ============================================================
    // Xen IO Ring 操作
    // ============================================================

    /**
     * @brief 提交时间戳请求到 IO Ring
     * @return true 成功，false Ring 满
     */
    bool submit_request(uint32_t vm_id, uint64_t request_id)
    {
        size_t next_prod = (m_req_prod + 1) % VPHC_RING_SIZE;
        if (next_prod == m_req_cons) {
            m_ring_overflow_count++;
            return false;  // Ring 满
        }

        auto& entry = m_req_ring[m_req_prod];
        entry.request_id = request_id;
        entry.vm_id = vm_id;
        entry.timestamp = 0;
        entry.is_response = false;
        entry.valid = true;

        m_req_prod = next_prod;
        m_ring_event.notify();

        if (vm_id < m_vm_domains.size()) {
            m_vm_domains[vm_id].request_count++;
        }

        return true;
    }

    /**
     * @brief 从 IO Ring 读取响应
     * @return true 成功，false 无响应
     */
    bool read_response(uint64_t& request_id, sc_core::sc_time& timestamp)
    {
        if (m_rsp_cons == m_rsp_prod) {
            return false;  // 无响应
        }

        const auto& entry = m_rsp_ring[m_rsp_cons];
        if (!entry.valid) {
            return false;
        }

        request_id = entry.request_id;
        timestamp = sc_core::sc_time(entry.timestamp, sc_core::SC_NS);

        m_rsp_cons = (m_rsp_cons + 1) % VPHC_RING_SIZE;
        return true;
    }

    /**
     * @brief 获取 Ring 溢出计数
     */
    uint64_t get_ring_overflow_count() const { return m_ring_overflow_count; }

    /**
     * @brief 获取 VM 请求计数
     */
    uint64_t get_vm_request_count(uint32_t vm_id) const
    {
        if (vm_id < m_vm_domains.size()) {
            return m_vm_domains[vm_id].request_count;
        }
        return 0;
    }

    /**
     * @brief 清空 Ring（测试用）
     */
    void clear_ring()
    {
        m_req_prod = m_req_cons = 0;
        m_rsp_prod = m_rsp_cons = 0;
        for (auto& e : m_req_ring) e.valid = false;
        for (auto& e : m_rsp_ring) e.valid = false;
    }

private:
    const model_config& m_cfg;
    tlm_phc* m_phc;

    // VM 管理
    uint32_t m_current_vm;
    uint64_t m_vm_switch_count = 0;
    std::vector<vm_time_domain> m_vm_domains;

    // Xen IO Ring
    std::vector<vphc_ring_entry> m_req_ring;
    std::vector<vphc_ring_entry> m_rsp_ring;
    size_t m_req_prod, m_req_cons;
    size_t m_rsp_prod, m_rsp_cons;
    sc_core::sc_event m_ring_event;

    // 统计
    uint64_t m_ring_overflow_count = 0;

    /**
     * @brief Ring 处理线程（轮询模式，避免事件丢失）
     */
    void ring_process()
    {
        while (true) {
            // 处理所有待处理请求
            while (m_req_cons != m_req_prod) {
                auto& req = m_req_ring[m_req_cons];
                if (!req.valid) {
                    m_req_cons = (m_req_cons + 1) % VPHC_RING_SIZE;
                    continue;
                }

                // 生成响应
                size_t next_rsp = (m_rsp_prod + 1) % VPHC_RING_SIZE;
                if (next_rsp != m_rsp_cons) {
                    auto& rsp = m_rsp_ring[m_rsp_prod];
                    rsp.request_id = req.request_id;
                    rsp.vm_id = req.vm_id;
                    rsp.timestamp = get_vm_time(req.vm_id).to_seconds() * 1e9;
                    rsp.is_response = true;
                    rsp.valid = true;
                    m_rsp_prod = next_rsp;
                }

                req.valid = false;
                m_req_cons = (m_req_cons + 1) % VPHC_RING_SIZE;
            }

            // 轮询间隔（避免过密事件导致调度器过载）
            wait(sc_core::sc_time(1, sc_core::SC_US));
        }
    }
};

} // namespace ethernet_tlm

#endif // TLM_VPHC_H
