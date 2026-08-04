#ifndef TRACE_HELPER_H
#define TRACE_HELPER_H

/**
 * @file trace_helper.h
 * @brief 波形/日志辅助工具
 *
 * 实现 VCD 波形输出、结构化日志、帧跟踪、事件跟踪
 */

#include <systemc>
#include <string>
#include <map>
#include <fstream>
#include <deque>

#include "../models/ethernet_types.h"

namespace ethernet_tlm {

/**
 * @struct frame_trace_entry
 * @brief 帧跟踪条目
 */
struct frame_trace_entry {
    uint64_t frame_id;
    sc_core::sc_time timestamp;
    std::string event;
    int port;
    std::string details;
};

/**
 * @class trace_helper
 * @brief 统一的波形与日志输出管理
 */
class trace_helper {
public:
    trace_helper() = default;
    ~trace_helper() { close(); }

    /**
     * @brief 初始化 VCD 波形文件
     */
    void init_vcd(const std::string& filename) {
        m_vcd_file = sc_core::sc_create_vcd_trace_file(filename.c_str());
        if (m_vcd_file) {
            m_vcd_enabled = true;
        }
    }

    /**
     * @brief 跟踪信号到 VCD
     */
    template<typename T>
    void trace_signal(const std::string& name, const T& signal) {
        if (m_vcd_enabled && m_vcd_file) {
            sc_core::sc_trace(m_vcd_file, signal, name);
        }
    }

    /**
     * @brief 初始化日志文件
     */
    void init_log(const std::string& filename) {
        m_log_file.open(filename);
        m_log_enabled = m_log_file.is_open();
    }

    /**
     * @brief 记录日志
     */
    void log(const std::string& level, const std::string& module,
             const std::string& message) {
        std::string entry = "[" + sc_core::sc_time_stamp().to_string() + "] "
                          + "[" + level + "] [" + module + "] " + message;

        if (m_log_enabled) {
            m_log_file << entry << std::endl;
        }

        if (level == "ERROR" || level == "FATAL") {
            printf("%s\n", entry.c_str());
        }
    }

    void info(const std::string& module, const std::string& msg) {
        log("INFO", module, msg);
    }

    void warn(const std::string& module, const std::string& msg) {
        log("WARN", module, msg);
    }

    void error(const std::string& module, const std::string& msg) {
        log("ERROR", module, msg);
    }

    // ============================================================
    // 帧跟踪
    // ============================================================

    /**
     * @brief 跟踪帧事件
     */
    void trace_frame(uint64_t frame_id, const std::string& event,
                     int port, const std::string& details = "") {
        frame_trace_entry entry;
        entry.frame_id = frame_id;
        entry.timestamp = sc_core::sc_time_stamp();
        entry.event = event;
        entry.port = port;
        entry.details = details;

        m_frame_traces.push_back(entry);
        if (m_frame_traces.size() > 100000) {
            m_frame_traces.pop_front();
        }
    }

    /**
     * @brief 导出帧跟踪到 CSV
     */
    void export_frame_trace(const std::string& filename) {
        std::ofstream ofs(filename);
        if (!ofs) return;

        ofs << "frame_id,timestamp,event,port,details\n";
        for (const auto& e : m_frame_traces) {
            ofs << e.frame_id << "," << e.timestamp << "," << e.event << ","
                << e.port << "," << e.details << "\n";
        }
        ofs.close();
    }

    // ============================================================
    // 事件跟踪
    // ============================================================

    /**
     * @brief 跟踪 TAS 门控切换
     */
    void trace_tas_gate(int port, uint8_t gate_mask) {
        log("TAS", "switch", "Port " + std::to_string(port) +
            " gate mask = 0x" + to_hex(gate_mask));
    }

    /**
     * @brief 跟踪 CBS credit 变化
     */
    void trace_cbs_credit(int port, uint8_t queue, int64_t credit) {
        log("CBS", "switch", "Port " + std::to_string(port) +
            " Queue " + std::to_string(queue) +
            " credit = " + std::to_string(credit));
    }

    /**
     * @brief 跟踪错误事件
     */
    void trace_error(int port, const std::string& error_type,
                     const std::string& details = "") {
        log("ERROR", "port" + std::to_string(port),
            error_type + (details.empty() ? "" : ": " + details));
    }

    /**
     * @brief 跟踪 FDB 学习
     */
    void trace_fdb_learn(const mac_addr_t& mac, int port) {
        log("FDB", "switch", "Learn " + mac_to_string(mac) +
            " on port " + std::to_string(port));
    }

    /**
     * @brief 关闭所有输出
     */
    void close() {
        if (m_vcd_file) {
            sc_core::sc_close_vcd_trace_file(m_vcd_file);
            m_vcd_file = nullptr;
            m_vcd_enabled = false;
        }
        if (m_log_file.is_open()) {
            m_log_file.close();
            m_log_enabled = false;
        }
    }

private:
    sc_core::sc_trace_file* m_vcd_file = nullptr;
    bool m_vcd_enabled = false;

    std::ofstream m_log_file;
    bool m_log_enabled = false;

    std::deque<frame_trace_entry> m_frame_traces;

    static std::string to_hex(uint8_t val) {
        char buf[8];
        snprintf(buf, sizeof(buf), "%02X", val);
        return std::string(buf);
    }
};

} // namespace ethernet_tlm

#endif // TRACE_HELPER_H
