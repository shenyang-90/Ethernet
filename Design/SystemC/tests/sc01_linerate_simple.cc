/**
 * @file sc01_linerate_simple.cc
 * @brief SC-01 简化版：单端口线速转发测试
 *
 * 验证基本系统级功能，线程数控制在 10 以内
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

class sc01_linerate_simple : public unit_test_base {
public:
    SC_HAS_PROCESS(sc01_linerate_simple);

    explicit sc01_linerate_simple(sc_core::sc_module_name name)
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
        return cfg;
    }

    std::string get_test_name() const override { return "sc01_linerate_simple"; }

    void test_body() override
    {
        std::cout << "\n========================================\n";
        std::cout << "SC-01 Simple: Single-Port Line-Rate Test\n";
        std::cout << "========================================\n";

        // 添加静态 FDB（环回）
        mac_addr_t mac_addr = {0x00, 0x11, 0x22, 0x33, 0x44, 0x60};
        sw.fdb_add_static(mac_addr, 0);

        // 启动流量生成
        std::cout << "[INFO] Starting traffic generation...\n";
        tg.start(1000.0);  // 1 Gbps

        // 运行 1ms
        wait(1, sc_core::SC_MS);

        // 停止流量
        tg.stop();

        // 收集统计
        std::cout << "\n========================================\n";
        std::cout << "Results\n";
        std::cout << "========================================\n";
        std::cout << "Traffic Gen TX: " << tg.tx_frames << " frames\n";
        std::cout << "MAC RX: " << mac.counters.rx_frames << " frames\n";
        std::cout << "Switch RX: " << sw.counters[0].rx_frames << " frames\n";

        bool pass = (tg.tx_frames > 0) && (mac.counters.rx_frames > 0);

        std::cout << "\n========================================\n";
        std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
        std::cout << "========================================\n\n";

        assert_true(pass, "System-level frame forwarding");
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
    ethernet_tlm::sc01_linerate_simple test("sc01_linerate_simple");
    sc_core::sc_start();
    return test.get_fail_count();
}
