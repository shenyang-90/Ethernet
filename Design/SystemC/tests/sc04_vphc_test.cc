/**
 * @file sc04_vphc_test.cc
 * @brief SC-04: vPHC VM 切换测试（直接创建 top）
 */

#include <systemc>
#include <iostream>
#include <iomanip>

#include "../models/tlm_ethernet_top.h"

namespace ethernet_tlm {

class sc04_vphc_test : public sc_core::sc_module {
public:
    SC_HAS_PROCESS(sc04_vphc_test);

    explicit sc04_vphc_test(sc_core::sc_module_name name)
        : sc_core::sc_module(name)
        , dut("dut")
    {
        SC_THREAD(run_test);
    }

    void run_test()
    {
        std::cout << "\n========================================\n";
        std::cout << "SC-04: vPHC VM Switch Test\n";
        std::cout << "========================================\n";

        if (!dut.vphc) {
            std::cout << "[ERROR] vPHC not enabled\n";
            sc_core::sc_stop();
            return;
        }

        // 配置 VM 时间域
        for (uint32_t i = 0; i < dut.cfg.VPHC_VM_COUNT; ++i) {
            dut.vphc->set_vm_time_domain(i, i * 1000000.0, i * 10.0);
        }

        // 提交时间戳请求
        std::cout << "[INFO] Submitting timestamp requests...\n";
        for (uint32_t vm = 0; vm < dut.cfg.VPHC_VM_COUNT; ++vm) {
            for (int req = 0; req < 5; ++req) {
                dut.vphc->submit_request(vm, req);
            }
        }

        // 运行仿真
        wait(100, sc_core::SC_US);

        // 读取响应
        std::cout << "[INFO] Reading responses...\n";
        uint64_t req_id;
        sc_core::sc_time timestamp;
        int rsp_count = 0;
        while (dut.vphc->read_response(req_id, timestamp)) {
            rsp_count++;
        }
        std::cout << "  Received " << rsp_count << " responses\n";

        // VM 切换测试
        std::cout << "\n[INFO] Testing VM switch...\n";
        for (uint32_t vm = 0; vm < dut.cfg.VPHC_VM_COUNT; ++vm) {
            std::cout << "  Switch to VM" << vm << "\n";
            dut.vphc->switch_vm(vm);

            auto vm_time = dut.vphc->get_vm_time(vm);
            auto phc_time = dut.get_phc_timestamp(0);

            std::cout << "    PHC Time: " << phc_time << "\n";
            std::cout << "    VM" << vm << " Time: " << vm_time << "\n";

            wait(10, sc_core::SC_US);
        }

        // 检查结果
        std::cout << "\n========================================\n";
        std::cout << "Results\n";
        std::cout << "========================================\n";
        std::cout << "VM Switch Count: " << dut.vphc->get_vm_switch_count() << "\n";
        std::cout << "Ring Overflow Count: " << dut.vphc->get_ring_overflow_count() << "\n";

        bool pass = (dut.vphc->get_vm_switch_count() >= 3) && (rsp_count > 0);

        std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
        std::cout << "========================================\n\n";

        sc_core::sc_stop();
    }

private:
    tlm_ethernet_top dut;
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::sc04_vphc_test test("test");
    sc_core::sc_start();
    return 0;
}
