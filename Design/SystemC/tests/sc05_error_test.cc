/**
 * @file sc05_error_test.cc
 * @brief SC-05: 错误注入测试（直接 sc_main 控制，无 SC_THREAD）
 */

#include <systemc>
#include <iostream>
#include <iomanip>

#include "../models/tlm_ethernet_top.h"

int sc_main(int argc, char* argv[])
{
    const std::string case_name = "sc05_error";

    std::cout << "\n========================================\n";
    std::cout << "SC-05: Error Injection Test\n";
    std::cout << "========================================\n";

    // 创建 top
    ethernet_tlm::tlm_ethernet_top dut("dut");

    // 初始化 VCD 波形和日志
    dut.init_vcd_trace(case_name);

    // 添加静态 FDB
    for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
        ethernet_tlm::mac_addr_t mac = {0x00, 0x11, 0x22, 0x33, 0x44,
                                        static_cast<uint8_t>(0x60 + i)};
        dut.switch_core->fdb_add_static(mac, i);
    }

    // 测试 1: FCS 错误
    std::cout << "[TEST 1] FCS Error Injection\n";
    dut.traffic_gens[0]->inject_fcs_error();
    dut.start_traffic(0, 100.0);
    sc_core::sc_start(10, sc_core::SC_US);
    dut.stop_traffic(0);

    // 测试 2: Runt 帧
    std::cout << "[TEST 2] Runt Frame Injection\n";
    if (dut.cfg.MAC_COUNT > 1) {
        dut.traffic_gens[1]->inject_runt_frame();
        dut.start_traffic(1, 100.0);
        sc_core::sc_start(10, sc_core::SC_US);
        dut.stop_traffic(1);
    }

    // 周期性更新 VCD 信号
    dut.update_vcd_signals();

    // 收集统计
    std::cout << "\n========================================\n";
    std::cout << "Results\n";
    std::cout << "========================================\n";

    uint64_t total_errors = 0;
    for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
        auto& tg = dut.traffic_gens[i];
        auto& mac = dut.macs[i];

        std::cout << "Port " << i << ":\n";
        std::cout << "  TX Frames: " << tg->tx_frames << "\n";
        std::cout << "  FCS Errors: " << tg->fcs_errors_injected << "\n";
        std::cout << "  Runt Frames: " << tg->runt_frames_injected << "\n";
        std::cout << "  MAC RX Errors: " << mac->counters.rx_errors << "\n";

        total_errors += mac->counters.rx_errors;
    }

    std::cout << "\nTotal Errors Detected: " << total_errors << "\n";

    bool pass = (total_errors > 0);
    std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
    std::cout << "========================================\n\n";

    // 导出统计到 tmp/<case_name>/
    dut.export_statistics(case_name);

    return pass ? 0 : 1;
}
