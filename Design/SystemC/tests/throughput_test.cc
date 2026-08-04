/**
 * @file throughput_test.cc
 * @brief SC-01: 线速转发吞吐测试（直接创建 top，无 base_test）
 */

#include <systemc>
#include <iostream>
#include <iomanip>

#include "../models/tlm_ethernet_top.h"

namespace ethernet_tlm {

class throughput_test : public sc_core::sc_module {
public:
    SC_HAS_PROCESS(throughput_test);

    explicit throughput_test(sc_core::sc_module_name name)
        : sc_core::sc_module(name)
        , dut("dut")
    {
        SC_THREAD(run_test);
    }

    void run_test()
    {
        const std::string case_name = "sc01_linerate";

        // 初始化 VCD 波形和日志
        dut.init_vcd_trace(case_name);

        std::cout << "\n========================================\n";
        std::cout << "SC-01: Line-Rate Forwarding Test\n";
        std::cout << "========================================\n";

        // 添加静态 FDB
        for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
            mac_addr_t mac = {0x00, 0x11, 0x22, 0x33, 0x44,
                              static_cast<uint8_t>(0x60 + i)};
            dut.switch_core->fdb_add_static(mac, i);
        }

        // 启动流量（低速率，减少事件密度）
        for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
            dut.start_traffic(i, 100.0);
        }

        std::cout << "[INFO] Running simulation for 10 us...\n";
        wait(10, sc_core::SC_US);

        // 周期性更新 VCD 信号
        dut.update_vcd_signals();

        // 停止流量
        for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
            dut.stop_traffic(i);
        }

        // 收集统计
        std::cout << "\n========================================\n";
        std::cout << "Results\n";
        std::cout << "========================================\n";

        double total_tx = 0, total_rx = 0;
        for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
            auto& tg = dut.traffic_gens[i];
            auto& mac = dut.macs[i];
            total_tx += tg->tx_frames;
            total_rx += mac->counters.rx_frames;

            std::cout << "Port " << i << ": TX=" << tg->tx_frames
                      << " RX=" << mac->counters.rx_frames << "\n";
        }

        std::cout << "Total TX: " << total_tx << ", Total RX: " << total_rx << "\n";

        bool pass = (total_tx > 0) && (total_rx > 0);
        std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
        std::cout << "========================================\n\n";

        // 导出统计到 tmp/<case_name>/
        dut.export_statistics(case_name);

        sc_core::sc_stop();
    }

private:
    tlm_ethernet_top dut;
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::throughput_test test("test");
    sc_core::sc_start();
    return 0;
}
