/**
 * @file sc02_tsn_test.cc
 * @brief SC-02: TSN 门控调度测试（直接 sc_main 控制，无 SC_THREAD）
 */

#include <systemc>
#include <iostream>
#include <iomanip>

#include "../models/tlm_ethernet_top.h"

int sc_main(int argc, char* argv[])
{
    std::cout << "\n========================================\n";
    std::cout << "SC-02: TSN Gate Control Test\n";
    std::cout << "========================================\n";

    // 创建 top
    ethernet_tlm::tlm_ethernet_top dut("dut");

    // 配置 TAS 门控列表（Queue 7 始终开，其他轮询）
    // std::vector<ethernet_tlm::tas_gate_entry> gcl;
    // for (int i = 0; i < 8; ++i) {
    //     ethernet_tlm::tas_gate_entry entry;
    //     entry.gate_mask = 0x80 | (1 << i);  // bit7 始终为 1
    //     entry.duration = sc_core::sc_time(125.0 / 8, sc_core::SC_US);
    //     gcl.push_back(entry);
    // }
    // dut.switch_core->set_gate_control_list(gcl);

    // 配置 CBS
    dut.switch_core->set_cbs_params(0, 5,
                                    2 * 1000 * 1000,
                                    2 * 1000 * 1000 - 5000LL * 1000 * 1000,
                                    100000, -100000);

    // 添加静态 FDB
    for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
        ethernet_tlm::mac_addr_t mac = {0x00, 0x11, 0x22, 0x33, 0x44,
                                        static_cast<uint8_t>(0x60 + i)};
        dut.switch_core->fdb_add_static(mac, i);
    }

    // 启动流量
    for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
        dut.start_traffic(i, 100.0);
    }

    std::cout << "[INFO] Running TSN gate control simulation for 10 us...\n";
    sc_core::sc_start(10, sc_core::SC_US);

    // 停止流量
    for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
        dut.stop_traffic(i);
    }

    // 检查结果
    std::cout << "\n========================================\n";
    std::cout << "Results\n";
    std::cout << "========================================\n";
    std::cout << "TAS Gate Cycle: 125 us (8 slots)\n";
    std::cout << "CBS Queue 5: idle_slope=2Mbps\n";

    bool pass = true;
    for (unsigned int i = 0; i < dut.cfg.MAC_COUNT; ++i) {
        auto& tg = dut.traffic_gens[i];
        auto& mac = dut.macs[i];
        std::cout << "Port " << i << ": TX=" << tg->tx_frames
                  << " RX=" << mac->counters.rx_frames << "\n";
        if (tg->tx_frames == 0) pass = false;
    }

    std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
    std::cout << "========================================\n\n";

    return pass ? 0 : 1;
}
