/**
 * @file latency_test.cc
 * @brief SC-03: 多端口并发延迟测试（直接创建 top）
 */

#include <systemc>
#include <iostream>
#include <iomanip>

#include "../models/tlm_ethernet_top.h"
#include "../utils/statistics.h"

namespace ethernet_tlm {

class latency_test : public sc_core::sc_module {
public:
    SC_HAS_PROCESS(latency_test);

    explicit latency_test(sc_core::sc_module_name name)
        : sc_core::sc_module(name)
        , dut("dut")
    {
        SC_THREAD(run_test);
    }

    void run_test()
    {
        std::cout << "\n========================================\n";
        std::cout << "SC-03: Multi-Port Concurrent Test\n";
        std::cout << "========================================\n";

        // 添加静态 FDB
        for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
            mac_addr_t mac = {0x00, 0x11, 0x22, 0x33, 0x44,
                              static_cast<uint8_t>(0x60 + i)};
            dut.switch_core->fdb_add_static(mac, i);
        }

        // 启动 MAC 侧流量
        for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
            dut.start_traffic(i, 100.0);
        }

        // 启动 Host 流量
        dut.start_host_traffic(100.0);

        std::cout << "[INFO] Running simulation for 10 us...\n";
        wait(10, sc_core::SC_US);

        // 停止流量
        for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
            dut.stop_traffic(i);
        }
        dut.stop_host_traffic();

        // 收集统计
        std::cout << "\n========================================\n";
        std::cout << "Results\n";
        std::cout << "========================================\n";

        double total_bw = 0;
        uint64_t total_rx = 0, total_tx = 0;

        for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
            auto& tg = dut.traffic_gens[i];
            auto& mac = dut.macs[i];
            double bw = dut.stats.get_port_bandwidth_mbps(i);

            total_bw += bw;
            total_rx += mac->counters.rx_frames;
            total_tx += tg->tx_frames;

            std::cout << "Port " << i << ": TX=" << tg->tx_frames
                      << " RX=" << mac->counters.rx_frames << "\n";
        }

        // DMA 统计
        std::cout << "\nDMA Statistics:\n";
        uint64_t dma_tx = 0, dma_rx = 0;
        for (unsigned int i = 0; i < dut.cfg.DMA_CH_COUNT; ++i) {
            auto& cnt = dut.dma->channel_counters[i];
            dma_tx += cnt.tx_frames;
            dma_rx += cnt.rx_frames;
        }
        std::cout << "  Total DMA TX: " << dma_tx << ", RX: " << dma_rx << "\n";

        // Host 统计
        std::cout << "Host TX: " << dut.host->tx_frames_submitted << "\n";
        std::cout << "Host RX: " << dut.host->rx_frames_received << "\n";

        // 公平性
        std::vector<double> channel_rates;
        for (unsigned int i = 0; i < dut.cfg.DMA_CH_COUNT; ++i) {
            auto& cnt = dut.dma->channel_counters[i];
            channel_rates.push_back(static_cast<double>(cnt.tx_frames + cnt.rx_frames));
        }
        double fairness = statistics::jains_fairness_index(channel_rates);

        std::cout << "DMA Fairness (Jain's Index): " << fairness << "\n";

        bool pass = (fairness >= 0.5) && (total_rx > 0);
        std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
        std::cout << "========================================\n\n";

        sc_core::sc_stop();
    }

private:
    tlm_ethernet_top dut;
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::latency_test test("test");
    sc_core::sc_start();
    return 0;
}
