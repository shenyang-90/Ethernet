/**
 * @file test_phc.cc
 * @brief PHC 单元测试
 *
 * 测试用例：时间戳单调性、Addend 调整、偏移调整、多实例独立、P2P 延迟
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_phc.h"
#include "../utils/tlm_dummy_initiator.h"

namespace ethernet_tlm {

class test_phc : public unit_test_base {
public:
    SC_HAS_PROCESS(test_phc);

    explicit test_phc(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg()
        , phc0("phc0", m_cfg, 0)
        , phc1("phc1", m_cfg, 1)
    {
        // 绑定 dummy initiator 到 PHC socket
        auto dummy0 = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("dummy0")));
        dummy0->socket.bind(phc0.socket);
        m_dummies.push_back(std::move(dummy0));

        auto dummy1 = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("dummy1")));
        dummy1->socket.bind(phc1.socket);
        m_dummies.push_back(std::move(dummy1));
    }

    std::string get_test_name() const override { return "test_phc"; }

    void test_body() override
    {
        test_timestamp_monotonic();
        test_addend_adjust();
        test_offset_adjust();
        test_set_time();
        test_multi_instance();
        test_p2p_delay();
    }

private:
    model_config m_cfg;
    tlm_phc phc0;
    tlm_phc phc1;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_dummies;

    // PHC-U01: 时间戳单调性
    void test_timestamp_monotonic()
    {
        std::cout << "\n--- PHC-U01: Timestamp Monotonic ---\n";

        auto t1 = phc0.get_timestamp();
        wait(10, sc_core::SC_NS);
        auto t2 = phc0.get_timestamp();

        assert_true(t2 > t1, "Timestamp monotonic");
    }

    // PHC-U02: Addend 调整
    void test_addend_adjust()
    {
        std::cout << "\n--- PHC-U02: Addend Adjust ---\n";

        // 验证 Addend 接口可调用
        phc0.adjust_freq(0x80000000);
        assert_eq(static_cast<uint64_t>(phc0.get_addend()),
                  static_cast<uint64_t>(0x80000000), "Addend set to 0x80000000");

        phc0.adjust_freq(0x40000000);
        assert_eq(static_cast<uint64_t>(phc0.get_addend()),
                  static_cast<uint64_t>(0x40000000), "Addend set to 0x40000000");

        phc0.adjust_freq(0xFFFFFFFF);
        assert_eq(static_cast<uint64_t>(phc0.get_addend()),
                  static_cast<uint64_t>(0xFFFFFFFF), "Addend set to 0xFFFFFFFF");
    }

    // PHC-U03: 偏移调整
    void test_offset_adjust()
    {
        std::cout << "\n--- PHC-U03: Offset Adjust ---\n";

        auto t1 = phc1.get_timestamp();
        phc1.adjust_offset(sc_core::sc_time(1, sc_core::SC_US));
        auto t2 = phc1.get_timestamp();

        double offset_ns = (t2 - t1).to_seconds() * 1e9;
        assert_near(offset_ns, 1000.0, 100.0, "Offset 1us applied");
    }

    // PHC-U04: 设置时间
    void test_set_time()
    {
        std::cout << "\n--- PHC-U04: Set Time ---\n";

        phc0.set_time(sc_core::sc_time(500, sc_core::SC_NS));
        auto t = phc0.get_timestamp();

        assert_near(t.to_seconds() * 1e9, 500.0, 50.0, "Set time to 500ns");
    }

    // PHC-U05: 多实例独立
    void test_multi_instance()
    {
        std::cout << "\n--- PHC-U05: Multi Instance ---\n";

        phc0.set_time(sc_core::sc_time(1000, sc_core::SC_NS));
        phc1.set_time(sc_core::sc_time(2000, sc_core::SC_NS));

        auto t0 = phc0.get_timestamp();
        auto t1 = phc1.get_timestamp();

        assert_near(t0.to_seconds() * 1e9, 1000.0, 50.0, "PHC0 independent");
        assert_near(t1.to_seconds() * 1e9, 2000.0, 50.0, "PHC1 independent");
    }

    // PHC-U06: P2P 延迟计算
    void test_p2p_delay()
    {
        std::cout << "\n--- PHC-U06: P2P Delay ---\n";

        uint64_t seq = 1;

        // 直接设置时间戳（避免 wait() 精度问题）
        phc0.set_time(sc_core::sc_time(0, sc_core::SC_NS));
        phc0.record_pdelay_req_tx(seq);

        phc0.set_time(sc_core::sc_time(10, sc_core::SC_NS));
        phc0.record_pdelay_req_rx(seq);

        phc0.set_time(sc_core::sc_time(20, sc_core::SC_NS));
        phc0.record_pdelay_resp_tx(seq);

        phc0.set_time(sc_core::sc_time(30, sc_core::SC_NS));
        phc0.record_pdelay_resp_rx(seq);

        auto delay = phc0.compute_pdelay(seq);
        double delay_ns = delay.to_seconds() * 1e9;

        // delay = ((t4-t1) - (t3-t2)) / 2 = ((30-0) - (20-10)) / 2 = 10 ns
        assert_near(delay_ns, 10.0, 2.0, "P2P delay calculation");
    }
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::test_phc test("test_phc");
    sc_core::sc_start();
    return test.get_fail_count();
}
