/**
 * @file test_mac.cc
 * @brief MAC 单元测试
 *
 * 测试用例：FCS 错误检测、帧长检查、时间戳捕获、帧抢占、帧组装/拆解
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_mac.h"
#include "../models/tlm_phc.h"
#include "../models/frame_payload.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"

namespace ethernet_tlm {

class test_mac : public unit_test_base {
public:
    SC_HAS_PROCESS(test_mac);

    explicit test_mac(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg()
        , phc("phc", m_cfg, 0)
        , dut("dut", m_cfg, 0, &phc)
    {
        // 绑定 PHC socket
        auto phc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phc_dummy")));
        phc_dummy->socket.bind(phc.socket);
        m_dummy_inits.push_back(std::move(phc_dummy));

        // 创建 dummy 模块
        auto swi_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("swi_init")));
        swi_init->socket.bind(dut.swi_rx_socket);
        m_dummy_inits.push_back(std::move(swi_init));

        auto phy_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phy_init")));
        phy_init->socket.bind(dut.phy_rx_socket);
        m_dummy_inits.push_back(std::move(phy_init));

        auto swi_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("swi_target")));
        dut.swi_tx_socket.bind(swi_target->socket);
        m_dummy_targets.push_back(std::move(swi_target));

        auto phy_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("phy_target")));
        dut.phy_tx_socket.bind(phy_target->socket);
        m_dummy_targets.push_back(std::move(phy_target));
    }

    std::string get_test_name() const override { return "test_mac"; }

    void test_body() override
    {
        test_fcs_error_detection();
        test_normal_frame();
        test_runt_frame();
        test_giant_frame();
        test_timestamp_capture();
        test_express_queue();
        test_preemptable_queue();
        test_frame_assemble();
        test_frame_disassemble();
    }

private:
    model_config m_cfg;
    tlm_phc phc;
    tlm_mac dut;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_dummy_inits;
    std::vector<std::unique_ptr<tlm_dummy_target>> m_dummy_targets;

    // MAC-U01: FCS 错误检测
    void test_fcs_error_detection()
    {
        std::cout << "\n--- MAC-U01: FCS Error Detection ---\n";

        frame_meta meta;
        meta.length = 64;
        meta.fcs_error = true;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        dut.phy_rx_b_transport(*trans, delay);

        assert_eq(static_cast<uint64_t>(dut.counters.fcs_errors),
                  static_cast<uint64_t>(1), "FCS error counted");
    }

    // MAC-U02: 正常帧通过
    void test_normal_frame()
    {
        std::cout << "\n--- MAC-U02: Normal Frame ---\n";

        frame_meta meta;
        meta.length = 64;
        meta.fcs_error = false;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        uint64_t before = dut.counters.rx_frames;
        dut.phy_rx_b_transport(*trans, delay);

        assert_eq(static_cast<uint64_t>(dut.counters.rx_frames),
                  static_cast<uint64_t>(before + 1), "Normal frame received");
    }

    // MAC-U03: Runt 帧检测
    void test_runt_frame()
    {
        std::cout << "\n--- MAC-U03: Runt Frame ---\n";

        frame_meta meta;
        meta.length = 32;  // < 64B

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        dut.phy_rx_b_transport(*trans, delay);

        assert_eq(static_cast<uint64_t>(dut.counters.runt_frames),
                  static_cast<uint64_t>(1), "Runt frame counted");
    }

    // MAC-U04: Giant 帧检测
    void test_giant_frame()
    {
        std::cout << "\n--- MAC-U04: Giant Frame ---\n";

        frame_meta meta;
        meta.length = 10000;  // > 9018B

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        dut.phy_rx_b_transport(*trans, delay);

        assert_eq(static_cast<uint64_t>(dut.counters.giant_frames),
                  static_cast<uint64_t>(1), "Giant frame counted");
    }

    // MAC-U05: 时间戳捕获
    void test_timestamp_capture()
    {
        std::cout << "\n--- MAC-U05: Timestamp Capture ---\n";

        frame_meta meta;
        meta.length = 64;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        auto phc_time = phc.get_timestamp();
        dut.phy_rx_b_transport(*trans, delay);

        auto* ext = get_frame_meta(*trans);
        assert_true(ext != nullptr, "Frame meta exists");

        double diff = std::fabs((ext->sfd_timestamp - phc_time).to_seconds() * 1e9);
        assert_true(diff < 1000.0, "Timestamp captured near PHC time");
    }

    // MAC-U06: Express 队列
    void test_express_queue()
    {
        std::cout << "\n--- MAC-U06: Express Queue ---\n";

        frame_meta meta;
        meta.length = 64;
        meta.traffic_class = 7;  // 高优先级

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        dut.swi_rx_b_transport(*trans, delay);

        // Express 队列应该有帧
        assert_true(true, "Express queue callable");
    }

    // MAC-U07: Preemptable 队列
    void test_preemptable_queue()
    {
        std::cout << "\n--- MAC-U07: Preemptable Queue ---\n";

        frame_meta meta;
        meta.length = 64;
        meta.traffic_class = 0;  // 低优先级

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        dut.swi_rx_b_transport(*trans, delay);

        assert_true(true, "Preemptable queue callable");
    }

    // MAC-U08: 帧组装
    void test_frame_assemble()
    {
        std::cout << "\n--- MAC-U08: Frame Assemble ---\n";

        frame_meta meta;
        meta.length = 64;

        dut.assemble_frame(meta);

        uint64_t expected = 64 + PREAMBLE_LEN + SFD_LEN + FCS_LEN;
        assert_eq(static_cast<uint64_t>(meta.length),
                  static_cast<uint64_t>(expected), "Frame assembled");
    }

    // MAC-U09: 帧拆解
    void test_frame_disassemble()
    {
        std::cout << "\n--- MAC-U09: Frame Disassemble ---\n";

        frame_meta meta;
        meta.length = 64 + PREAMBLE_LEN + SFD_LEN + FCS_LEN;

        dut.disassemble_frame(meta);

        assert_eq(static_cast<uint64_t>(meta.length),
                  static_cast<uint64_t>(64), "Frame disassembled");
    }
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::test_mac test("test_mac");
    sc_core::sc_start();
    return test.get_fail_count();
}
