/**
 * @file sc04_vphc_simple.cc
 * @brief SC-04 简化版：vPHC VM 切换系统测试
 *
 * 验证 VM 时间域热切换（简化版：PHC + vPHC）
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_phc.h"
#include "../models/tlm_vphc.h"
#include "../utils/tlm_dummy_initiator.h"

namespace ethernet_tlm {

class sc04_vphc_simple : public unit_test_base {
public:
    SC_HAS_PROCESS(sc04_vphc_simple);

    explicit sc04_vphc_simple(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg(create_config())
        , phc("phc", m_cfg, 0)
        , vphc("vphc", m_cfg, &phc)
    {
        // 绑定 PHC
        auto phc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phc_dummy")));
        phc_dummy->socket.bind(phc.socket);
        m_dummies.push_back(std::move(phc_dummy));

        // 绑定 vPHC
        auto vphc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("vphc_dummy")));
        vphc_dummy->socket.bind(vphc.socket);
        m_dummies.push_back(std::move(vphc_dummy));
    }

    static model_config create_config() {
        model_config cfg;
        cfg.SUPPORT_VPHC = true;
        cfg.VPHC_VM_COUNT = 4;
        return cfg;
    }

    std::string get_test_name() const override { return "sc04_vphc_simple"; }

    void test_body() override
    {
        std::cout << "\n========================================\n";
        std::cout << "SC-04 Simple: vPHC VM Switch Test\n";
        std::cout << "========================================\n";

        // 配置 VM 时间域
        for (uint32_t i = 0; i < 4; ++i) {
            vphc.set_vm_time_domain(i, i * 1000000.0, i * 10.0);
        }

        // 提交时间戳请求
        std::cout << "[INFO] Submitting timestamp requests...\n";
        for (uint32_t vm = 0; vm < 4; ++vm) {
            for (int req = 0; req < 5; ++req) {
                vphc.submit_request(vm, req);
            }
        }

        // 运行仿真
        wait(100, sc_core::SC_US);

        // 读取响应
        std::cout << "[INFO] Reading responses...\n";
        uint64_t req_id;
        sc_core::sc_time timestamp;
        int rsp_count = 0;
        while (vphc.read_response(req_id, timestamp)) {
            rsp_count++;
        }
        std::cout << "  Received " << rsp_count << " responses\n";

        // VM 切换测试
        std::cout << "\n[INFO] Testing VM switch...\n";
        for (uint32_t vm = 0; vm < 4; ++vm) {
            std::cout << "  Switch to VM" << vm << "\n";
            vphc.switch_vm(vm);

            auto vm_time = vphc.get_vm_time(vm);
            auto phc_time = phc.get_timestamp();

            std::cout << "    PHC Time: " << phc_time << "\n";
            std::cout << "    VM" << vm << " Time: " << vm_time << "\n";
            std::cout << "    Offset: " << (vm_time - phc_time) << "\n";

            wait(10, sc_core::SC_US);
        }

        // 检查结果
        std::cout << "\n========================================\n";
        std::cout << "Results\n";
        std::cout << "========================================\n";
        std::cout << "VM Switch Count: " << vphc.get_vm_switch_count() << "\n";
        std::cout << "Ring Overflow Count: " << vphc.get_ring_overflow_count() << "\n";

        for (uint32_t vm = 0; vm < 4; ++vm) {
            std::cout << "VM" << vm << " Requests: " << vphc.get_vm_request_count(vm) << "\n";
        }

        bool pass = (vphc.get_vm_switch_count() >= 3) && (rsp_count > 0);

        std::cout << "\n========================================\n";
        std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
        std::cout << "========================================\n\n";

        assert_true(pass, "vPHC VM switch");
    }

private:
    model_config m_cfg;
    tlm_phc phc;
    tlm_vphc vphc;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_dummies;
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::sc04_vphc_simple test("sc04_vphc_simple");
    sc_core::sc_start();
    return test.get_fail_count();
}
