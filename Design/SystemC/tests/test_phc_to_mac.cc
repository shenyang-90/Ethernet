/**
 * @file test_phc_to_mac.cc
 * @brief PHC ↔ MAC 集成测试
 *
 * 验证 PHC 时间戳捕获链路
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_phc.h"
#include "../models/tlm_mac.h"
#include "../models/frame_payload.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"

namespace ethernet_tlm {

class test_phc_to_mac : public unit_test_base {
public:
    SC_HAS_PROCESS(test_phc_to_mac);

    explicit test_phc_to_mac(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg()
        , phc("phc", m_cfg, 0)
        , mac("mac", m_cfg, 0, &phc)
    {
        // 绑定 PHC
        auto phc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phc_dummy")));
        phc_dummy->socket.bind(phc.socket);
        m_inits.push_back(std::move(phc_dummy));

        // MAC 侧 dummy
        auto swi_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("swi_init")));
        swi_init->socket.bind(mac.swi_rx_socket);
        m_inits.push_back(std::move(swi_init));

        auto phy_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phy_init")));
        phy_init->socket.bind(mac.phy_rx_socket);
        m_inits.push_back(std::move(phy_init));

        auto swi_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("swi_target")));
        mac.swi_tx_socket.bind(swi_target->socket);
        m_targets.push_back(std::move(swi_target));

        auto phy_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("phy_target")));
        mac.phy_tx_socket.bind(phy_target->socket);
        m_targets.push_back(std::move(phy_target));
    }

    std::string get_test_name() const override { return "test_phc_to_mac"; }

    void test_body() override
    {
        test_timestamp_capture_link();
        test_timestamp_accuracy();
    }

private:
    model_config m_cfg;
    tlm_phc phc;
    tlm_mac mac;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_inits;
    std::vector<std::unique_ptr<tlm_dummy_target>> m_targets;

    // INT-U06: 时间戳捕获链路
    void test_timestamp_capture_link()
    {
        std::cout << "\n--- INT-U06: Timestamp Capture Link ---\n";

        frame_meta meta;
        meta.length = 64;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        auto phc_time = phc.get_timestamp();
        mac.phy_rx_b_transport(*trans, delay);

        auto* ext = get_frame_meta(*trans);
        assert_true(ext != nullptr, "Frame meta exists");

        double diff = std::fabs((ext->sfd_timestamp - phc_time).to_seconds() * 1e9);
        assert_true(diff < 1000.0, "Timestamp captured from PHC");
    }

    // INT-U07: 时间戳精度
    void test_timestamp_accuracy()
    {
        std::cout << "\n--- INT-U07: Timestamp Accuracy ---\n";

        // 设置已知时间
        phc.set_time(sc_core::sc_time(5000, sc_core::SC_NS));

        frame_meta meta;
        meta.length = 64;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        mac.phy_rx_b_transport(*trans, delay);

        auto* ext = get_frame_meta(*trans);
        double ts_ns = ext->sfd_timestamp.to_seconds() * 1e9;

        assert_near(ts_ns, 5000.0, 100.0, "Timestamp accuracy ±100ns");
    }
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::test_phc_to_mac test("test_phc_to_mac");
    sc_core::sc_start();
    return test.get_fail_count();
}
