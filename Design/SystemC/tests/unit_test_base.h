#ifndef UNIT_TEST_BASE_H
#define UNIT_TEST_BASE_H

/**
 * @file unit_test_base.h
 * @brief SystemC/TLM 单元测试基类
 *
 * 提供断言、结果统计、测试报告功能
 */

#include <systemc>
#include <string>
#include <vector>
#include <iostream>
#include <cmath>

namespace ethernet_tlm {

/**
 * @class unit_test_base
 * @brief 轻量级单元测试基类（作为 sc_module）
 *
 * 使用方式：
 *   class my_test : public unit_test_base {
 *       SC_HAS_PROCESS(my_test);
 *       my_test(sc_core::sc_module_name name) : unit_test_base(name) {}
 *       void test_body() override { ... }
 *       std::string get_test_name() const override { return "my_test"; }
 *   };
 *   // sc_main: my_test t("t"); sc_core::sc_start();
 */
class unit_test_base : public sc_core::sc_module {
public:
    SC_HAS_PROCESS(unit_test_base);

    explicit unit_test_base(sc_core::sc_module_name name)
        : sc_core::sc_module(name)
    {
        SC_THREAD(test_thread);
    }

    virtual ~unit_test_base() = default;

    /**
     * @brief 测试线程
     */
    void test_thread() {
        std::cout << "\n========================================\n";
        std::cout << "Running: " << get_test_name() << "\n";
        std::cout << "========================================\n";

        test_body();

        print_result();
        sc_core::sc_stop();
    }

    /**
     * @brief 测试主体（子类实现）
     */
    virtual void test_body() = 0;

    /**
     * @brief 获取测试名称
     */
    virtual std::string get_test_name() const = 0;

    // ============================================================
    // 断言
    // ============================================================

    void assert_true(bool cond, const std::string& msg) {
        if (cond) {
            m_pass++;
            std::cout << "  [PASS] " << msg << "\n";
        } else {
            m_fail++;
            m_failures.push_back(msg);
            std::cout << "  [FAIL] " << msg << "\n";
        }
    }

    void assert_false(bool cond, const std::string& msg) {
        assert_true(!cond, msg);
    }

    void assert_eq(uint64_t actual, uint64_t expected, const std::string& msg) {
        if (actual == expected) {
            m_pass++;
            std::cout << "  [PASS] " << msg << " (" << actual << ")\n";
        } else {
            m_fail++;
            m_failures.push_back(msg + " (expected " + std::to_string(expected) +
                                 ", got " + std::to_string(actual) + ")");
            std::cout << "  [FAIL] " << msg << " (expected " << expected
                      << ", got " << actual << ")\n";
        }
    }

    void assert_near(double actual, double expected, double tolerance,
                     const std::string& msg) {
        if (std::fabs(actual - expected) <= tolerance) {
            m_pass++;
            std::cout << "  [PASS] " << msg << " (" << actual << ")\n";
        } else {
            m_fail++;
            m_failures.push_back(msg + " (expected " + std::to_string(expected) +
                                 " ± " + std::to_string(tolerance) +
                                 ", got " + std::to_string(actual) + ")");
            std::cout << "  [FAIL] " << msg << " (expected " << expected
                      << " ± " << tolerance << ", got " << actual << ")\n";
        }
    }

    // ============================================================
    // 结果
    // ============================================================

    void print_result() {
        std::cout << "\n========================================\n";
        std::cout << "Result: " << get_test_name() << "\n";
        std::cout << "========================================\n";
        std::cout << "  PASS: " << m_pass << "\n";
        std::cout << "  FAIL: " << m_fail << "\n";

        if (m_fail > 0) {
            std::cout << "\nFailures:\n";
            for (const auto& f : m_failures) {
                std::cout << "  - " << f << "\n";
            }
        }

        std::cout << "  Status: " << (m_fail == 0 ? "ALL PASS" : "HAS FAILURES") << "\n";
        std::cout << "========================================\n\n";
    }

    int get_pass_count() const { return m_pass; }
    int get_fail_count() const { return m_fail; }
    bool all_passed() const { return m_fail == 0; }

private:
    int m_pass = 0;
    int m_fail = 0;
    std::vector<std::string> m_failures;
};

} // namespace ethernet_tlm

#endif // UNIT_TEST_BASE_H
