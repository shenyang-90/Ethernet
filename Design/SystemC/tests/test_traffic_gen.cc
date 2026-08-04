/**
 * @file test_traffic_gen.cc
 * @brief Traffic Generator 单元测试
 *
 * 测试用例：帧长分布、速率控制、错误注入
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_traffic_gen.h"
#include "../models/frame_payload.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"

namespace ethernet_tlm {

class test_traffic_gen : public unit_test_base {
public:
    SC_HAS_PROCESS(test_traffic_gen);

    explicit test_traffic_gen(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg()
        , dut("dut", m_cfg, 0)
    {
        // 绑定 dummy target 到 TX socket
        auto target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("target")));
        dut.socket.bind(target->socket);
        m_targets.push_back(std::move(target));

        // 绑定 dummy initiator 到 RX socket
        auto rx_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("rx_init")));
        rx_init->socket.bind(dut.rx_socket);
        m_inits.push_back(std::move(rx_init));
    }

    std::string get_test_name() const override { return "test_traffic_gen"; }

    void test_body() override
    {
        test_frame_length_dist();
        test_rate_control();
        test_fcs_error_injection();
        test_runt_frame_injection();
        test_giant_frame_injection();
        test_continuous_error_rate();
    }

private:
    model_config m_cfg;
    tlm_traffic_gen dut;
    std::vector<std::unique_ptr<tlm_dummy_target>> m_targets;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_inits;

    // TG-U01: 帧长分布
    void test_frame_length_dist()
    {
        std::cout << "\n--- TG-U01: Frame Length Distribution ---\n";

        // 启动流量生成
        dut.start(1000.0);

        // 运行一段时间
        wait(10, sc_core::SC_US);

        dut.stop();

        // 验证生成了帧
        assert_true(dut.tx_frames > 0, "Frames generated");
        assert_true(dut.tx_bytes > 0, "Bytes generated");
    }

    // TG-U02: 速率控制
    void test_rate_control()
    {
        std::cout << "\n--- TG-U02: Rate Control ---\n";

        uint64_t before = dut.tx_frames;

        dut.start(1000.0);  // 1000 Mbps
        wait(1, sc_core::SC_US);
        dut.stop();

        uint64_t frames = dut.tx_frames - before;
        assert_true(frames > 0, "Frames generated at 1000 Mbps");
    }

    // TG-U03: FCS 错误注入
    void test_fcs_error_injection()
    {
        std::cout << "\n--- TG-U03: FCS Error Injection ---\n";

        uint64_t before = dut.fcs_errors_injected;

        dut.inject_fcs_error();
        dut.start(1000.0);
        wait(1, sc_core::SC_US);
        dut.stop();

        assert_true(dut.fcs_errors_injected > before, "FCS error injected");
    }

    // TG-U04: Runt 帧注入
    void test_runt_frame_injection()
    {
        std::cout << "\n--- TG-U04: Runt Frame Injection ---\n";

        uint64_t before = dut.runt_frames_injected;

        dut.inject_runt_frame();
        dut.start(1000.0);
        wait(1, sc_core::SC_US);
        dut.stop();

        assert_true(dut.runt_frames_injected > before, "Runt frame injected");
    }

    // TG-U05: Giant 帧注入
    void test_giant_frame_injection()
    {
        std::cout << "\n--- TG-U05: Giant Frame Injection ---\n";

        uint64_t before = dut.giant_frames_injected;

        dut.inject_giant_frame();
        dut.start(1000.0);
        wait(1, sc_core::SC_US);
        dut.stop();

        assert_true(dut.giant_frames_injected > before, "Giant frame injected");
    }

    // TG-U06: 连续错误率
    void test_continuous_error_rate()
    {
        std::cout << "\n--- TG-U06: Continuous Error Rate ---\n";

        uint64_t before_fcs = dut.fcs_errors_injected;

        dut.set_error_rate(0.5);  // 50% 错误率
        dut.start(1000.0);
        wait(10, sc_core::SC_US);
        dut.stop();

        // 50% 错误率下应该有一些错误帧
        assert_true(dut.fcs_errors_injected > before_fcs,
                    "Continuous errors injected");
    }
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::test_traffic_gen test("test_traffic_gen");
    sc_core::sc_start();
    return test.get_fail_count();
}
