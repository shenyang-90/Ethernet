#ifndef STATISTICS_H
#define STATISTICS_H

/**
 * @file statistics.h
 * @brief 指标统计工具
 *
 * 实现端口计数、延迟统计、带宽统计、公平性计算、CSV/JSON 导出
 */

#include <systemc>
#include <string>
#include <map>
#include <vector>
#include <deque>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <numeric>
#include <cmath>

#include "../models/ethernet_types.h"

namespace ethernet_tlm {

/**
 * @struct latency_stats
 * @brief 延迟统计
 */
struct latency_stats {
    uint64_t count = 0;
    double   sum_ns = 0.0;
    double   min_ns = 1e18;
    double   max_ns = 0.0;
    std::deque<double> samples;  // 保留最近样本用于 p99 计算

    void record(double latency_ns) {
        count++;
        sum_ns += latency_ns;
        min_ns = std::min(min_ns, latency_ns);
        max_ns = std::max(max_ns, latency_ns);
        samples.push_back(latency_ns);
        if (samples.size() > 10000) {
            samples.pop_front();
        }
    }

    double avg_ns() const { return count > 0 ? sum_ns / count : 0.0; }

    double p99_ns() {
        if (samples.empty()) return 0.0;
        std::vector<double> sorted(samples.begin(), samples.end());
        std::sort(sorted.begin(), sorted.end());
        size_t idx = static_cast<size_t>(sorted.size() * 0.99);
        return sorted[std::min(idx, sorted.size() - 1)];
    }
};

/**
 * @struct bandwidth_stats
 * @brief 带宽统计
 */
struct bandwidth_stats {
    uint64_t total_bytes = 0;
    uint64_t window_bytes = 0;
    sc_core::sc_time window_start;
    double window_duration_ms = 1.0;
    std::deque<double> window_rates;  // Mbps

    void record(uint64_t bytes, const sc_core::sc_time& now) {
        total_bytes += bytes;
        window_bytes += bytes;

        double elapsed_ms = (now - window_start).to_seconds() * 1000.0;
        if (elapsed_ms >= window_duration_ms) {
            double rate_mbps = (window_bytes * 8.0) / (elapsed_ms * 1e6) * 1e3;
            window_rates.push_back(rate_mbps);
            if (window_rates.size() > 1000) {
                window_rates.pop_front();
            }
            window_bytes = 0;
            window_start = now;
        }
    }

    double avg_rate_mbps() const {
        if (window_rates.empty()) return 0.0;
        return std::accumulate(window_rates.begin(), window_rates.end(), 0.0) / window_rates.size();
    }

    double current_rate_mbps(const sc_core::sc_time& now) const {
        double elapsed_s = (now - window_start).to_seconds();
        if (elapsed_s <= 0.0) return 0.0;
        return (window_bytes * 8.0) / (elapsed_s * 1e6);
    }
};

/**
 * @class statistics
 * @brief 全局统计收集器
 */
class statistics {
public:
    statistics() = default;
    ~statistics() = default;

    // ============================================================
    // 端口计数
    // ============================================================

    void register_port(unsigned int port_id) {
        m_port_counters[port_id] = port_counters();
        m_port_bandwidth[port_id] = bandwidth_stats();
        m_port_bandwidth[port_id].window_start = sc_core::sc_time_stamp();
    }

    void record_rx(unsigned int port_id, uint64_t bytes, bool error = false) {
        auto& c = m_port_counters[port_id];
        c.rx_frames++;
        c.rx_bytes += bytes;
        if (error) c.rx_errors++;
        m_port_bandwidth[port_id].record(bytes, sc_core::sc_time_stamp());
    }

    void record_tx(unsigned int port_id, uint64_t bytes) {
        auto& c = m_port_counters[port_id];
        c.tx_frames++;
        c.tx_bytes += bytes;
    }

    void record_drop(unsigned int port_id) {
        m_port_counters[port_id].rx_dropped++;
    }

    void record_error(unsigned int port_id, const std::string& type) {
        auto& c = m_port_counters[port_id];
        if (type == "fcs") c.fcs_errors++;
        else if (type == "runt") c.runt_frames++;
        else if (type == "giant") c.giant_frames++;
        else if (type == "fifo") c.fifo_overflow++;
        c.rx_errors++;
    }

    const port_counters& get_port_counters(unsigned int port_id) const {
        static port_counters empty;
        auto it = m_port_counters.find(port_id);
        return it != m_port_counters.end() ? it->second : empty;
    }

    // ============================================================
    // 延迟统计
    // ============================================================

    void record_latency(unsigned int src_port, unsigned int dst_port,
                        double latency_ns) {
        auto key = std::make_pair(src_port, dst_port);
        m_latency_stats[key].record(latency_ns);
    }

    const latency_stats& get_latency_stats(unsigned int src_port,
                                           unsigned int dst_port) const {
        static latency_stats empty;
        auto it = m_latency_stats.find(std::make_pair(src_port, dst_port));
        return it != m_latency_stats.end() ? it->second : empty;
    }

    // ============================================================
    // 带宽统计
    // ============================================================

    double get_port_bandwidth_mbps(unsigned int port_id) const {
        auto it = m_port_bandwidth.find(port_id);
        return it != m_port_bandwidth.end() ? it->second.avg_rate_mbps() : 0.0;
    }

    double get_aggregate_bandwidth_mbps() const {
        double total = 0.0;
        for (const auto& [port, bw] : m_port_bandwidth) {
            total += bw.avg_rate_mbps();
        }
        return total;
    }

    // ============================================================
    // 公平性计算
    // ============================================================

    static double jains_fairness_index(const std::vector<double>& values) {
        if (values.empty()) return 1.0;
        double sum = std::accumulate(values.begin(), values.end(), 0.0);
        double sq_sum = 0.0;
        for (double v : values) sq_sum += v * v;
        if (sq_sum <= 0.0) return 1.0;
        return (sum * sum) / (values.size() * sq_sum);
    }

    double compute_port_fairness() const {
        std::vector<double> rates;
        for (const auto& [port, bw] : m_port_bandwidth) {
            rates.push_back(bw.avg_rate_mbps());
        }
        return jains_fairness_index(rates);
    }

    // ============================================================
    // 导出
    // ============================================================

    void export_csv(const std::string& filename) {
        std::ofstream ofs(filename);
        if (!ofs) return;

        // 端口统计
        ofs << "port,rx_frames,tx_frames,rx_bytes,tx_bytes,"
            << "rx_dropped,tx_dropped,rx_errors,fcs_errors,"
            << "runt_frames,giant_frames,fifo_overflow,bandwidth_mbps\n";

        for (const auto& [port, c] : m_port_counters) {
            double bw = get_port_bandwidth_mbps(port);
            ofs << port << "," << c.rx_frames << "," << c.tx_frames << ","
                << c.rx_bytes << "," << c.tx_bytes << ","
                << c.rx_dropped << "," << c.tx_dropped << "," << c.rx_errors << ","
                << c.fcs_errors << "," << c.runt_frames << "," << c.giant_frames << ","
                << c.fifo_overflow << "," << bw << "\n";
        }

        // 延迟统计
        ofs << "\nsrc_port,dst_port,count,avg_ns,min_ns,max_ns,p99_ns\n";
        for (auto& [key, stats] : m_latency_stats) {
            ofs << key.first << "," << key.second << "," << stats.count << ","
                << stats.avg_ns() << "," << stats.min_ns << "," << stats.max_ns << ","
                << stats.p99_ns() << "\n";
        }

        ofs.close();
    }

    void export_json(const std::string& filename) {
        std::ofstream ofs(filename);
        if (!ofs) return;

        ofs << "{\n";
        ofs << "  \"timestamp\": \"" << sc_core::sc_time_stamp() << "\",\n";
        ofs << "  \"aggregate_bandwidth_mbps\": " << get_aggregate_bandwidth_mbps() << ",\n";
        ofs << "  \"port_fairness_index\": " << compute_port_fairness() << ",\n";

        ofs << "  \"ports\": [\n";
        bool first = true;
        for (const auto& [port, c] : m_port_counters) {
            if (!first) ofs << ",\n";
            first = false;
            ofs << "    {\n";
            ofs << "      \"port_id\": " << port << ",\n";
            ofs << "      \"rx_frames\": " << c.rx_frames << ",\n";
            ofs << "      \"tx_frames\": " << c.tx_frames << ",\n";
            ofs << "      \"rx_bytes\": " << c.rx_bytes << ",\n";
            ofs << "      \"tx_bytes\": " << c.tx_bytes << ",\n";
            ofs << "      \"rx_dropped\": " << c.rx_dropped << ",\n";
            ofs << "      \"rx_errors\": " << c.rx_errors << ",\n";
            ofs << "      \"bandwidth_mbps\": " << get_port_bandwidth_mbps(port) << "\n";
            ofs << "    }";
        }
        ofs << "\n  ]\n";
        ofs << "}\n";

        ofs.close();
    }

    /**
     * @brief 打印摘要到 stdout
     */
    void print_summary() const {
        printf("\n=== Statistics Summary ===\n");
        printf("Aggregate Bandwidth: %.2f Mbps\n", get_aggregate_bandwidth_mbps());
        printf("Port Fairness Index: %.4f\n", compute_port_fairness());

        for (const auto& [port, c] : m_port_counters) {
            printf("Port %u: RX=%lu frames/%lu bytes, TX=%lu frames/%lu bytes, "
                   "Drop=%lu, Err=%lu, BW=%.2f Mbps\n",
                   port, c.rx_frames, c.rx_bytes, c.tx_frames, c.tx_bytes,
                   c.rx_dropped, c.rx_errors, get_port_bandwidth_mbps(port));
        }
        printf("==========================\n\n");
    }

private:
    std::map<unsigned int, port_counters> m_port_counters;
    std::map<unsigned int, bandwidth_stats> m_port_bandwidth;
    std::map<std::pair<unsigned int, unsigned int>, latency_stats> m_latency_stats;
};

} // namespace ethernet_tlm

#endif // STATISTICS_H
