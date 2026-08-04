/**
 * @file test_vphc.cc
 * @brief vPHC 单元测试
 *
 * 测试用例：VM 时间映射、VM 切换、IO Ring、时间域管理
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_vphc.h"
#include "../models/tlm_phc.h"
#include "../utils/tlm_dummy_initiator.h"

namespace ethernet_tlm {

class test_vphc : public unit_test_base {
public:
    SC_HAS_PROCESS(test_vphc);

    explicit test_vphc(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg()
        , phc("phc", m_cfg, 0)
        , dut("dut", m_cfg, &phc)
    {
        m_cfg.SUPPORT_VPHC = true;
        m_cfg.VPHC_VM_COUNT = 4;

        // 绑定 dummy
        auto phc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phc_dummy")));
        phc_dummy->socket.bind(phc.socket);
        m_dummies.push_back(std::move(phc_dummy));

        auto vphc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("vphc_dummy")));
        vphc_dummy->socket.bind(dut.socket);
        m_dummies.push_back(std::move(vphc_dummy));
    }

    std::string get_test_name() const override { return "test_vphc"; }

    void test_body() override
    {
        test_vm_time_mapping();
        test_vm_switch();
        test_switch_monotonic();
        test_ring_submit();
        test_ring_read();
        test_ring_overflow();
        test_multi_vm_requests();
    }

private:
    model_config m_cfg;
    tlm_phc phc;
    tlm_vphc dut;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_dummies;

    // VPHC-U01: VM 时间映射
    void test_vm_time_mapping()
    {
        std::cout << "\n--- VPHC-U01: VM Time Mapping ---\n";

        // 设置 VM0 时间域：offset=1ms, scale=0ppm
        dut.set_vm_time_domain(0, 1000000.0, 0.0);

        auto phc_time = phc.get_timestamp();
        auto vm_time = dut.get_vm_time(0);

        double offset_ns = (vm_time - phc_time).to_seconds() * 1e9;
        assert_near(offset_ns, 1000000.0, 100000.0, "VM0 offset 1ms");
    }

    // VPHC-U02: VM 切换
    void test_vm_switch()
    {
        std::cout << "\n--- VPHC-U02: VM Switch ---\n";

        assert_eq(static_cast<uint64_t>(dut.get_current_vm()),
                  static_cast<uint64_t>(0), "Initial VM0");

        dut.switch_vm(1);
        assert_eq(static_cast<uint64_t>(dut.get_current_vm()),
                  static_cast<uint64_t>(1), "Switched to VM1");

        assert_eq(static_cast<uint64_t>(dut.get_vm_switch_count()),
                  static_cast<uint64_t>(1), "Switch count 1");
    }

    // VPHC-U03: 切换单调性
    void test_switch_monotonic()
    {
        std::cout << "\n--- VPHC-U03: Switch Monotonic ---\n";

        sc_core::sc_time last_time = sc_core::SC_ZERO_TIME;
        bool monotonic = true;

        for (uint32_t vm = 0; vm < 4; ++vm) {
            dut.set_vm_time_domain(vm, vm * 1000000.0, 0.0);
            auto t = dut.get_vm_time(vm);
            if (t < last_time) {
                monotonic = false;
            }
            last_time = t;
        }

        assert_true(monotonic, "VM time monotonic");
    }

    // VPHC-U04: IO Ring 提交
    void test_ring_submit()
    {
        std::cout << "\n--- VPHC-U04: IO Ring Submit ---\n";

        bool ok = dut.submit_request(0, 1);
        assert_true(ok, "Submit request 1");

        ok = dut.submit_request(1, 2);
        assert_true(ok, "Submit request 2");

        assert_eq(static_cast<uint64_t>(dut.get_vm_request_count(0)),
                  static_cast<uint64_t>(1), "VM0 request count");
        assert_eq(static_cast<uint64_t>(dut.get_vm_request_count(1)),
                  static_cast<uint64_t>(1), "VM1 request count");
    }

    // VPHC-U05: IO Ring 读取
    void test_ring_read()
    {
        std::cout << "\n--- VPHC-U05: IO Ring Read ---\n";

        // 清空 Ring（避免之前测试影响）
        dut.clear_ring();

        // 提交请求
        dut.submit_request(0, 100);

        // 等待 ring_process 处理（增加等待时间）
        for (int i = 0; i < 100; ++i) {
            wait(1, sc_core::SC_NS);
        }

        // 读取响应
        uint64_t req_id;
        sc_core::sc_time timestamp;
        bool ok = dut.read_response(req_id, timestamp);

        assert_true(ok, "Read response");
        if (ok) {
            assert_eq(static_cast<uint64_t>(req_id),
                      static_cast<uint64_t>(100), "Response request ID");
        }
    }

    // VPHC-U06: Ring 溢出
    void test_ring_overflow()
    {
        std::cout << "\n--- VPHC-U06: Ring Overflow ---\n";

        // 清空 Ring（避免之前测试影响）
        dut.clear_ring();

        // Ring 大小 32，提交 33 个请求
        for (int i = 0; i < 33; ++i) {
            dut.submit_request(0, i);
        }

        assert_true(dut.get_ring_overflow_count() > 0, "Ring overflow detected");
    }

    // VPHC-U07: 多 VM 请求
    void test_multi_vm_requests()
    {
        std::cout << "\n--- VPHC-U07: Multi VM Requests ---\n";

        // 清空 Ring
        dut.clear_ring();

        uint64_t before2 = dut.get_vm_request_count(2);
        uint64_t before3 = dut.get_vm_request_count(3);

        dut.submit_request(2, 1);
        dut.submit_request(3, 2);
        dut.submit_request(2, 3);
        dut.submit_request(3, 4);

        assert_eq(static_cast<uint64_t>(dut.get_vm_request_count(2)),
                  static_cast<uint64_t>(before2 + 2), "VM2 count +2");
        assert_eq(static_cast<uint64_t>(dut.get_vm_request_count(3)),
                  static_cast<uint64_t>(before3 + 2), "VM3 count +2");
    }
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::test_vphc test("test_vphc");
    sc_core::sc_start();
    return test.get_fail_count();
}
