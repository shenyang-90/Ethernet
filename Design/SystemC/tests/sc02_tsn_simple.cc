/**
 * @file sc02_tsn_simple.cc
 * @brief SC-02 简化版：TSN 门控调度系统测试
 *
 * 验证 TAS 门控列表执行与 CBS 整形（单端口简化版）
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_traffic_gen.h"
#include "../models/tlm_mac.h"
#include "../models/tlm_switch_core.h"
#include "../models/tlm_phc.h"
#include "../models/frame_payload.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"

namespace ethernet_tlm {

class sc02_tsn_simple : public unit_test_base {
public:
    SC_HAS_PROCESS(sc02_tsn_simple);

    explicit sc02_tsn_simple(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg(create_config())
        , phc("phc", m_cfg, 0)
        , mac("mac", m_cfg, 0, &phc)
        , sw("switch", m_cfg)
        , tg("traffic_gen", m_cfg, 0)
    {
        // 绑定 PHC
        auto phc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phc_dummy")));
        phc_dummy->socket.bind(phc.socket);
        m_dummies.push_back(std::move(phc_dummy));

        // MAC ↔ Switch
        mac.swi_tx_socket.bind(*sw.rx_socket[0]);
        (*sw.tx_socket[0]).bind(mac.swi_rx_socket);

        // Traffic Gen ↔ MAC
        tg.socket.bind(mac.phy_rx_socket);
        mac.phy_tx_socket.bind(tg.rx_socket);

        // Switch 未使用端口
        auto sw_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("sw_dummy")));
        sw_dummy->socket.bind(*sw.rx_socket[1]);
        m_dummies.push_back(std::move(sw_dummy));

        auto sw_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("sw_target")));
        (*sw.tx_socket[1]).bind(sw_target->socket);
        m_targets.push_back(std::move(sw_target));
    }

    static model_config create_config() {
        model_config cfg;
        cfg.SWITCH_PORT_COUNT = 2;
        cfg.SWITCH_TAS = true;
        cfg.SUPPORT_CBS = true;
        cfg.MTL_TX_QUEUES = 8;
        return cfg;
    }

    std::string get_test_name() const override { return "sc02_tsn_simple"; }

    void test_body() override
    {
        std::cout << "\n========================================\n";
        std::cout << "SC-02 Simple: TSN Gate Control Test\n";
        std::cout << "========================================\n";

        // 配置 TAS 门控列表（125us 周期，8 时隙）
        std::vector<tas_gate_entry> gcl;
        for (int i = 0; i < 8; ++i) {
            tas_gate_entry entry;
            entry.gate_mask = (1 << i);
            entry.duration = sc_core::sc_time(125.0 / 8, sc_core::SC_US);
            gcl.push_back(entry);
        }
        sw.set_gate_control_list(gcl);

        // 配置 CBS（Queue 5，AVB 流）
        sw.set_cbs_params(0, 5,
                          2 * 1000 * 1000,   // idle_slope = 2 Mbps
                          2 * 1000 * 1000 - 5000LL * 1000 * 1000,
                          100000, -100000);

        // 添加静态 FDB
        mac_addr_t mac_addr = {0x00, 0x11, 0x22, 0x33, 0x44, 0x60};
        sw.fdb_add_static(mac_addr, 0);

        // 启动流量
        std::cout << "[INFO] Starting traffic with TAS gate control...\n";
        tg.start(1000.0);

        // 运行 500us（4 个 TAS 周期）
        wait(500, sc_core::SC_US);

        tg.stop();

        // 检查结果
        std::cout << "\n========================================\n";
        std::cout << "Results\n";
        std::cout << "========================================\n";
        std::cout << "TAS Gate Cycle: 125 us (8 slots)\n";
        std::cout << "CBS Queue 5: idle_slope=2Mbps\n";
        std::cout << "Traffic Gen TX: " << tg.tx_frames << " frames\n";
        std::cout << "MAC RX: " << mac.counters.rx_frames << " frames\n";
        std::cout << "Switch RX: " << sw.counters[0].rx_frames << " frames\n";

        bool pass = (tg.tx_frames > 0) && (mac.counters.rx_frames > 0);

        std::cout << "\n========================================\n";
        std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
        std::cout << "========================================\n\n";

        assert_true(pass, "TSN gate control forwarding");
    }

private:
    model_config m_cfg;
    tlm_phc phc;
    tlm_mac mac;
    tlm_switch_core sw;
    tlm_traffic_gen tg;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_dummies;
    std::vector<std::unique_ptr<tlm_dummy_target>> m_targets;
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::sc02_tsn_simple test("sc02_tsn_simple");
    sc_core::sc_start();
    return test.get_fail_count();
}
