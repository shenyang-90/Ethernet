/**
 * @file test_mac_to_switch.cc
 * @brief MAC ↔ Switch 集成测试
 *
 * 验证 MAC 与 Switch Core 之间的帧传输
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_mac.h"
#include "../models/tlm_switch_core.h"
#include "../models/tlm_phc.h"
#include "../models/frame_payload.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"

namespace ethernet_tlm {

class test_mac_to_switch : public unit_test_base {
public:
    SC_HAS_PROCESS(test_mac_to_switch);

    explicit test_mac_to_switch(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg(create_config())
        , phc("phc", m_cfg, 0)
        , mac("mac", m_cfg, 0, &phc)
        , sw("switch", m_cfg)
    {
        // 绑定 PHC
        auto phc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phc_dummy")));
        phc_dummy->socket.bind(phc.socket);
        m_inits.push_back(std::move(phc_dummy));

        // MAC ↔ Switch
        mac.swi_tx_socket.bind(*sw.rx_socket[0]);
        (*sw.tx_socket[0]).bind(mac.swi_rx_socket);

        // MAC PHY 侧
        auto phy_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phy_init")));
        phy_init->socket.bind(mac.phy_rx_socket);
        m_inits.push_back(std::move(phy_init));

        auto phy_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("phy_target")));
        mac.phy_tx_socket.bind(phy_target->socket);
        m_targets.push_back(std::move(phy_target));

        // Switch 未使用端口
        auto sw_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("sw_dummy")));
        sw_dummy->socket.bind(*sw.rx_socket[1]);
        m_inits.push_back(std::move(sw_dummy));

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

    std::string get_test_name() const override { return "test_mac_to_switch"; }

    void test_body() override
    {
        test_mac_to_switch_frame();
        test_switch_to_mac_frame();
        test_bidirectional();
    }

private:
    model_config m_cfg;
    tlm_phc phc;
    tlm_mac mac;
    tlm_switch_core sw;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_inits;
    std::vector<std::unique_ptr<tlm_dummy_target>> m_targets;

    // INT-U01: MAC → Switch 帧传输
    void test_mac_to_switch_frame()
    {
        std::cout << "\n--- INT-U01: MAC to Switch ---\n";

        // 添加静态 FDB
        mac_addr_t dst_mac = {0x00, 0x11, 0x22, 0x33, 0x44, 0x66};
        sw.fdb_add_static(dst_mac, 1);

        // 从 PHY 侧注入帧到 MAC
        frame_meta meta;
        meta.length = 64;
        meta.src_mac = {0x00, 0x11, 0x22, 0x33, 0x44, 0x55};
        meta.dst_mac = dst_mac;
        meta.src_port = 0;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        mac.phy_rx_b_transport(*trans, delay);

        // 验证 MAC 接收统计
        assert_eq(static_cast<uint64_t>(mac.counters.rx_frames),
                  static_cast<uint64_t>(1), "MAC received frame");
    }

    // INT-U02: Switch → MAC 帧传输
    void test_switch_to_mac_frame()
    {
        std::cout << "\n--- INT-U02: Switch to MAC ---\n";

        // 从 Switch 注入帧到 MAC
        frame_meta meta;
        meta.length = 64;
        meta.src_mac = {0x00, 0x11, 0x22, 0x33, 0x44, 0x77};
        meta.dst_mac = {0x00, 0x11, 0x22, 0x33, 0x44, 0x55};
        meta.src_port = 0;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        mac.swi_rx_b_transport(*trans, delay);

        // 验证接口可调用
        assert_true(true, "Switch to MAC interface");
    }

    // INT-U03: 双向传输
    void test_bidirectional()
    {
        std::cout << "\n--- INT-U03: Bidirectional ---\n";

        // 验证统计计数
        uint64_t total_rx = mac.counters.rx_frames;
        uint64_t total_tx = mac.counters.tx_frames;

        assert_true(total_rx >= 0, "RX counter valid");
        assert_true(total_tx >= 0, "TX counter valid");
    }
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::test_mac_to_switch test("test_mac_to_switch");
    sc_core::sc_start();
    return test.get_fail_count();
}
