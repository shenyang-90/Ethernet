#ifndef TLM_SWITCH_CORE_H
#define TLM_SWITCH_CORE_H

/**
 * @file tlm_switch_core.h
 * @brief Switch Core TLM 2.0 Model
 *
 * 实现 FDB 自学习、VLAN 转发、TAS 门控、CBS 整形、Crossbar 仲裁
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include <map>
#include <queue>
#include <vector>
#include <deque>
#include <functional>
#include <memory>

#include "ethernet_types.h"
#include "ethernet_config.h"
#include "frame_payload.h"
#include "tlm_mm.h"

namespace ethernet_tlm {

/**
 * @class tlm_switch_core
 * @brief Switch Core 事务级模型
 *
 * 建模内容：
 * - FDB 自学习（MAC→端口映射，支持老化）
 * - VLAN 转发（802.1Q）
 * - 泛洪处理（FDB 未命中）
 * - 共享队列管理（store-and-forward）
 * - TAS 门控调度（802.1Qbv）
 * - CBS 信用整形（802.1Qav）
 * - Crossbar 轮询仲裁
 *
 * 精度等级：Approximately-Timed (AT)
 */
class tlm_switch_core : public sc_core::sc_module {
public:
    // 端口接口类型定义
    using target_socket_t = tlm_utils::simple_target_socket<tlm_switch_core>;
    using initiator_socket_t = tlm_utils::simple_initiator_socket<tlm_switch_core>;

    // 端口 socket 数组（指针形式，因为 socket 不可复制）
    std::vector<std::unique_ptr<target_socket_t>>   rx_socket;  // ingress: 端口→Switch
    std::vector<std::unique_ptr<initiator_socket_t>> tx_socket;  // egress: Switch→端口

    // 统计
    std::vector<port_counters> counters;

    SC_HAS_PROCESS(tlm_switch_core);

    /**
     * @brief Constructor
     * @param name Module name
     * @param cfg Model configuration
     */
    explicit tlm_switch_core(sc_core::sc_module_name name,
                             const model_config& cfg = model_config())
        : sc_core::sc_module(name)
        , m_cfg(cfg)
        , m_port_count(cfg.SWITCH_PORT_COUNT)
        , m_fdb_aging_time(cfg.FDB_AGING_TIME_MS, sc_core::SC_MS)
    {
        // 初始化端口 socket
        counters.resize(m_port_count);
        for (unsigned int i = 0; i < m_port_count; ++i) {
            m_queue_events.push_back(std::make_unique<sc_core::sc_event>());
        }

        for (unsigned int i = 0; i < m_port_count; ++i) {
            char buf[32];

            snprintf(buf, sizeof(buf), "rx_socket_%u", i);
            rx_socket.push_back(std::make_unique<target_socket_t>(buf));
            rx_socket[i]->register_b_transport(this, &tlm_switch_core::b_transport);

            snprintf(buf, sizeof(buf), "tx_socket_%u", i);
            tx_socket.push_back(std::make_unique<initiator_socket_t>(buf));
            tx_socket[i]->register_nb_transport_bw(this, &tlm_switch_core::nb_transport_bw);
        }

        // 记录当前处理的端口（用于 b_transport 中识别端口）
        // 由于 simple_target_socket 不支持带 tag 的回调，我们在 b_transport 中
        // 通过 socket 指针反查端口 ID

        // 初始化队列
        m_egress_queues.resize(m_port_count);
        for (auto& q : m_egress_queues) {
            q.resize(m_cfg.MTL_TX_QUEUES);
        }

        // 初始化 TAS 门控
        if (m_cfg.SWITCH_TAS) {
            m_gate_control_list.resize(m_cfg.TAS_MAX_GCL_ENTRIES);
            for (auto& entry : m_gate_control_list) {
                entry.gate_mask = 0xFF;
                entry.duration = sc_core::sc_time(125, sc_core::SC_US) / m_cfg.TAS_MAX_GCL_ENTRIES;
            }
            m_current_gcl_index = 0;
            m_gate_states.resize(m_port_count, 0xFF);
            { sc_core::sc_spawn_options o; 
                sc_core::sc_spawn([this]() { tas_scheduler(); },
                                  sc_core::sc_gen_unique_name("tas_scheduler"), &o); }
        }

        // 初始化 CBS
        if (m_cfg.SUPPORT_CBS) {
            m_cbs_credits.resize(m_port_count);
            for (auto& credits : m_cbs_credits) {
                credits.resize(m_cfg.MTL_TX_QUEUES);
                for (auto& credit : credits) {
                    credit.credit = 0;
                    credit.idle_slope = 2 * 1000 * 1000;
                    credit.send_slope = credit.idle_slope - 5000LL * 1000 * 1000;
                    credit.hi_credit = 100000;
                    credit.lo_credit = -100000;
                    credit.last_update = sc_core::sc_time_stamp();
                }
            }
        }

        // 启动发送线程（合并为 1 个轮询线程，减少线程数）
        {
            sc_core::sc_spawn_options opts;
            sc_core::sc_spawn([this]() { egress_process_all(); },
                              sc_core::sc_gen_unique_name("egress_process_all"), &opts);
        }

        // FDB 老化线程
        { sc_core::sc_spawn_options o;
            sc_core::sc_spawn([this]() { fdb_aging_process(); },
                              sc_core::sc_gen_unique_name("fdb_aging_process"), &o); }
    }

    /**
     * @brief 通过 socket 指针查找端口 ID
     */
    int find_port_by_socket(const target_socket_t* socket) const {
        for (size_t i = 0; i < rx_socket.size(); ++i) {
            if (rx_socket[i].get() == socket) {
                return static_cast<int>(i);
            }
        }
        return -1;
    }

    /**
     * @brief TLM blocking transport (ingress from port)
     */
    void b_transport(tlm::tlm_generic_payload& trans,
                     sc_core::sc_time& delay)
    {
        // 从扩展中读取端口 ID
        auto* ext = get_frame_meta_mut(trans);
        if (!ext) {
            trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
            return;
        }

        int port_id = ext->src_port >= 0 ? ext->src_port : 0;

        wait(delay);
        delay = sc_core::SC_ZERO_TIME;

        // 记录 ingress 时间
        ext->ingress_time = sc_core::sc_time_stamp();
        ext->src_port = port_id;

        // 更新统计
        counters[port_id].rx_frames++;
        counters[port_id].rx_bytes += ext->length;

        // FDB 自学习
        fdb_learn(ext->src_mac, port_id, ext->vlan_id);

        // 转发决策
        std::vector<int> dst_ports;
        forward_decision(*ext, dst_ports);

        if (ext->drop) {
            counters[port_id].rx_dropped++;
            trans.set_response_status(tlm::TLM_OK_RESPONSE);
            return;
        }

        // 入队到目的端口
        for (int dst : dst_ports) {
            if (dst >= 0 && dst < static_cast<int>(m_port_count)) {
                enqueue_frame(dst, trans, *ext);
            }
        }

        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    /**
     * @brief TLM non-blocking backward (egress to port)
     */
    tlm::tlm_sync_enum nb_transport_bw(tlm::tlm_generic_payload& trans,
                                        tlm::tlm_phase& phase,
                                        sc_core::sc_time& delay)
    {
        return tlm::TLM_ACCEPTED;
    }

    // ============================================================
    // FDB 操作
    // ============================================================

    void fdb_learn(const mac_addr_t& mac, int port, uint16_t vlan_id = 0)
    {
        if (is_multicast(mac) || is_broadcast(mac)) {
            return;
        }

        fdb_entry entry;
        entry.mac = mac;
        entry.port = port;
        entry.vlan_id = vlan_id;
        entry.timestamp = sc_core::sc_time_stamp();
        entry.is_static = false;
        entry.valid = true;

        m_fdb[mac] = entry;
    }

    int fdb_lookup(const mac_addr_t& mac, uint16_t vlan_id = 0) const
    {
        auto it = m_fdb.find(mac);
        if (it == m_fdb.end() || !it->second.valid) {
            return -1;
        }
        if (m_cfg.SUPPORT_VLAN && it->second.vlan_id != vlan_id) {
            return -1;
        }
        return it->second.port;
    }

    void fdb_add_static(const mac_addr_t& mac, int port, uint16_t vlan_id = 0)
    {
        fdb_entry entry;
        entry.mac = mac;
        entry.port = port;
        entry.vlan_id = vlan_id;
        entry.timestamp = sc_core::sc_time_stamp();
        entry.is_static = true;
        entry.valid = true;
        m_fdb[mac] = entry;
    }

    void fdb_aging_process()
    {
        while (true) {
            wait(m_fdb_aging_time / 10);

            auto now = sc_core::sc_time_stamp();
            for (auto it = m_fdb.begin(); it != m_fdb.end();) {
                if (!it->second.is_static &&
                    (now - it->second.timestamp) > m_fdb_aging_time) {
                    it = m_fdb.erase(it);
                } else {
                    ++it;
                }
            }
        }
    }

    // ============================================================
    // 转发决策
    // ============================================================

    void forward_decision(frame_meta& meta, std::vector<int>& dst_ports)
    {
        dst_ports.clear();

        if (is_broadcast(meta.dst_mac)) {
            meta.flood = true;
            for (unsigned int i = 0; i < m_port_count; ++i) {
                if (static_cast<int>(i) != meta.src_port) {
                    dst_ports.push_back(i);
                }
            }
            return;
        }

        if (is_multicast(meta.dst_mac)) {
            meta.flood = true;
            for (unsigned int i = 0; i < m_port_count; ++i) {
                if (static_cast<int>(i) != meta.src_port) {
                    dst_ports.push_back(i);
                }
            }
            return;
        }

        int dst = fdb_lookup(meta.dst_mac, meta.vlan_id);
        if (dst >= 0) {
            if (dst != meta.src_port) {
                dst_ports.push_back(dst);
            } else {
                meta.drop = true;
            }
        } else {
            meta.flood = true;
            for (unsigned int i = 0; i < m_port_count; ++i) {
                if (static_cast<int>(i) != meta.src_port) {
                    dst_ports.push_back(i);
                }
            }
        }
    }

    // ============================================================
    // 队列管理
    // ============================================================

    void enqueue_frame(int port_id, tlm::tlm_generic_payload& trans,
                       const frame_meta& meta)
    {
        uint8_t queue_id = meta.vlan_valid ? meta.vlan_pcp : meta.traffic_class;
        if (queue_id >= m_cfg.MTL_TX_QUEUES) {
            queue_id = m_cfg.MTL_TX_QUEUES - 1;
        }

        auto& queue = m_egress_queues[port_id][queue_id];

        if (queue.size() >= 1024) {
            counters[port_id].fifo_overflow++;
            return;
        }

        // 创建新 transaction（简化：不复制数据，仅复制元数据）
        auto* new_trans = create_frame_payload(meta);
        new_trans->set_data_ptr(trans.get_data_ptr());
        new_trans->set_data_length(trans.get_data_length());
        new_trans->set_response_status(tlm::TLM_OK_RESPONSE);

        queue.push(new_trans);
        m_queue_events[port_id]->notify();
    }

    // ============================================================
    // TAS 门控调度
    // ============================================================

    void tas_scheduler()
    {
        while (true) {
            const auto& entry = m_gate_control_list[m_current_gcl_index];

            for (unsigned int i = 0; i < m_port_count; ++i) {
                m_gate_states[i] = entry.gate_mask;
            }

            m_gate_change_event.notify();

            wait(entry.duration);

            m_current_gcl_index = (m_current_gcl_index + 1) % m_gate_control_list.size();
        }
    }

    bool is_gate_open(int port_id, uint8_t queue_id) const
    {
        if (!m_cfg.SWITCH_TAS) return true;
        return (m_gate_states[port_id] & (1 << queue_id)) != 0;
    }

    // ============================================================
    // CBS 信用整形
    // ============================================================

    void update_cbs_credit(int port_id, uint8_t queue_id)
    {
        if (!m_cfg.SUPPORT_CBS) return;

        auto& credit = m_cbs_credits[port_id][queue_id];
        auto now = sc_core::sc_time_stamp();
        double elapsed_ns = (now - credit.last_update).to_seconds() * 1e9;

        if (credit.credit < 0) {
            credit.credit += static_cast<int64_t>(credit.idle_slope * elapsed_ns / 1e9);
            if (credit.credit > credit.hi_credit) {
                credit.credit = credit.hi_credit;
            }
        }

        credit.last_update = now;
    }

    bool can_send_cbs(int port_id, uint8_t queue_id) const
    {
        if (!m_cfg.SUPPORT_CBS) return true;
        return m_cbs_credits[port_id][queue_id].credit >= 0;
    }

    void consume_cbs_credit(int port_id, uint8_t queue_id, uint32_t frame_bits)
    {
        if (!m_cfg.SUPPORT_CBS) return;

        auto& credit = m_cbs_credits[port_id][queue_id];
        credit.credit -= static_cast<int64_t>(frame_bits);
        if (credit.credit < credit.lo_credit) {
            credit.credit = credit.lo_credit;
        }
    }

    // ============================================================
    // 发送处理
    // ============================================================

    /**
     * @brief 单端口发送处理（原 egress_process，保留供参考）
     */
    void egress_process(int port_id)
    {
        while (true) {
            bool has_frame = false;
            for (uint8_t q = 0; q < m_cfg.MTL_TX_QUEUES; ++q) {
                if (!m_egress_queues[port_id][q].empty()) {
                    has_frame = true;
                    break;
                }
            }

            if (!has_frame) {
                wait(*m_queue_events[port_id]);
                continue;
            }

            int selected_queue = -1;
            for (int q = m_cfg.MTL_TX_QUEUES - 1; q >= 0; --q) {
                if (m_egress_queues[port_id][q].empty()) continue;
                if (!is_gate_open(port_id, q)) continue;

                update_cbs_credit(port_id, q);
                if (!can_send_cbs(port_id, q)) continue;

                selected_queue = q;
                break;
            }

            if (selected_queue < 0) {
                wait(sc_core::sc_time(100, sc_core::SC_NS));
                continue;
            }

            auto* trans = m_egress_queues[port_id][selected_queue].front();
            m_egress_queues[port_id][selected_queue].pop();

            auto* ext = get_frame_meta_mut(*trans);
            if (ext) {
                double byte_time = m_cfg.byte_time_ns(port_id);
                sc_core::sc_time tx_delay(static_cast<uint64_t>(ext->length * byte_time),
                                          sc_core::SC_NS);

                consume_cbs_credit(port_id, selected_queue, ext->length * 8);

                counters[port_id].tx_frames++;
                counters[port_id].tx_bytes += ext->length;

                tlm::tlm_phase phase = tlm::BEGIN_REQ;
                (*tx_socket[port_id])->nb_transport_fw(*trans, phase, tx_delay);

                ext->tas_scheduled = m_cfg.SWITCH_TAS;
            }
        }
    }

    /**
     * @brief 全端口轮询发送处理（合并线程，减少线程数）
     *
     * 每周期轮询所有端口，处理每个端口最高优先级可发帧
     */
    void egress_process_all()
    {
        while (true) {
            bool any_frame = false;

            // 轮询所有端口
            for (unsigned int port_id = 0; port_id < m_port_count; ++port_id) {
                // 检查该端口是否有帧
                bool has_frame = false;
                for (uint8_t q = 0; q < m_cfg.MTL_TX_QUEUES; ++q) {
                    if (!m_egress_queues[port_id][q].empty()) {
                        has_frame = true;
                        break;
                    }
                }

                if (!has_frame) continue;
                any_frame = true;

                // 选择最高优先级可发队列
                int selected_queue = -1;
                for (int q = m_cfg.MTL_TX_QUEUES - 1; q >= 0; --q) {
                    if (m_egress_queues[port_id][q].empty()) continue;
                    if (!is_gate_open(port_id, q)) continue;

                    update_cbs_credit(port_id, q);
                    if (!can_send_cbs(port_id, q)) continue;

                    selected_queue = q;
                    break;
                }

                if (selected_queue < 0) continue;

                // 出队并发送
                auto* trans = m_egress_queues[port_id][selected_queue].front();
                m_egress_queues[port_id][selected_queue].pop();

                auto* ext = get_frame_meta_mut(*trans);
                if (ext) {
                    double byte_time = m_cfg.byte_time_ns(port_id);
                    sc_core::sc_time tx_delay(static_cast<uint64_t>(ext->length * byte_time),
                                              sc_core::SC_NS);

                    consume_cbs_credit(port_id, selected_queue, ext->length * 8);

                    counters[port_id].tx_frames++;
                    counters[port_id].tx_bytes += ext->length;

                    tlm::tlm_phase phase = tlm::BEGIN_REQ;
                    (*tx_socket[port_id])->nb_transport_fw(*trans, phase, tx_delay);

                    ext->tas_scheduled = m_cfg.SWITCH_TAS;
                }
            }

            // 无帧时等待，有帧时继续轮询（避免忙等）
            if (!any_frame) {
                // 固定轮询间隔（简化，避免 sc_event_or_list 与 sc_time 组合问题）
                wait(sc_core::sc_time(1, sc_core::SC_US));
            }
        }
    }

    // ============================================================
    // 配置接口
    // ============================================================

    void set_gate_control_list(const std::vector<tas_gate_entry>& gcl)
    {
        m_gate_control_list = gcl;
        m_current_gcl_index = 0;
    }

    void set_cbs_params(int port_id, uint8_t queue_id,
                        int64_t idle_slope, int64_t send_slope,
                        int64_t hi_credit, int64_t lo_credit)
    {
        if (port_id < 0 || port_id >= static_cast<int>(m_port_count)) return;
        if (queue_id >= m_cfg.MTL_TX_QUEUES) return;

        auto& credit = m_cbs_credits[port_id][queue_id];
        credit.idle_slope = idle_slope;
        credit.send_slope = send_slope;
        credit.hi_credit = hi_credit;
        credit.lo_credit = lo_credit;
    }

    size_t get_fdb_size() const { return m_fdb.size(); }

    size_t get_queue_occupancy(int port_id, uint8_t queue_id) const
    {
        if (port_id < 0 || port_id >= static_cast<int>(m_port_count)) return 0;
        if (queue_id >= m_cfg.MTL_TX_QUEUES) return 0;
        return m_egress_queues[port_id][queue_id].size();
    }

private:
    const model_config& m_cfg;
    unsigned int m_port_count;

    std::map<mac_addr_t, fdb_entry> m_fdb;
    sc_core::sc_time m_fdb_aging_time;

    std::vector<std::vector<std::queue<tlm::tlm_generic_payload*>>> m_egress_queues;
    std::vector<std::unique_ptr<sc_core::sc_event>> m_queue_events;

    std::vector<tas_gate_entry> m_gate_control_list;
    size_t m_current_gcl_index = 0;
    std::vector<uint8_t> m_gate_states;
    sc_core::sc_event m_gate_change_event;

    std::vector<std::vector<cbs_credit>> m_cbs_credits;
};

} // namespace ethernet_tlm

#endif // TLM_SWITCH_CORE_H
