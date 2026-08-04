#ifndef BASE_TEST_H
#define BASE_TEST_H

/**
 * @file base_test.h
 * @brief TLM 2.0 Test Base Class
 */

#include <systemc>
#include <tlm>
#include <string>
#include <memory>

// 定义 SystemC 默认栈大小（1MB），inline 避免多重定义
inline const int SC_DEFAULT_STACK_SIZE = 0x40000;

#include "../models/tlm_ethernet_top.h"
#include "../utils/statistics.h"
#include "../utils/trace_helper.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"

namespace ethernet_tlm {

/**
 * @class base_test
 * @brief 测试基类，提供公共激励与检查框架
 */
class base_test : public sc_core::sc_module {
public:
    SC_HAS_PROCESS(base_test);

    explicit base_test(sc_core::sc_module_name name)
        : sc_core::sc_module(name)
        , dut("dut")
    {
        // 注意：csr_socket 和 host_socket 已在 tlm_ethernet_top 内部绑定到 dummy
        // 无需外部重复绑定
        // 测试线程由派生类创建（确保虚函数正确解析）
    }

    virtual ~base_test() = default;

    /**
     * @brief 测试主线程
     */
    virtual void run_test() = 0;

    /**
     * @brief 初始化测试环境
     */
    virtual void setup()
    {
        // 注册统计端口
        for (unsigned int i = 0; i < dut.cfg.SWITCH_PORT_COUNT; ++i) {
            dut.stats.register_port(i);
        }
    }

    /**
     * @brief 清理测试环境
     */
    virtual void teardown()
    {
        // 导出统计
        dut.export_statistics("metrics_test");
    }

protected:
    tlm_ethernet_top dut;
};

} // namespace ethernet_tlm

#endif // BASE_TEST_H
