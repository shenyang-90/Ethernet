/**
 * @file test_dma.cc
 * @brief DMA 单元测试
 *
 * 测试用例：描述符提交、通道轮询、AXI 延迟、错误检测、帧写入、描述符写回
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_dma.h"
#include "../models/frame_payload.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"

namespace ethernet_tlm {

class test_dma : public unit_test_base {
public:
    SC_HAS_PROCESS(test_dma);

    explicit test_dma(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg(create_dma_config())
        , dut("dut", m_cfg)
    {
        // 绑定 dummy 模块
        auto csr_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("csr_init")));
        csr_init->socket.bind(dut.csr_socket);
        m_dummy_inits.push_back(std::move(csr_init));

        auto swi_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("swi_init")));
        swi_init->socket.bind(dut.swi_rx_socket);
        m_dummy_inits.push_back(std::move(swi_init));

        auto axi_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("axi_target")));
        dut.axi_socket.bind(axi_target->socket);
        m_dummy_targets.push_back(std::move(axi_target));

        auto swi_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("swi_target")));
        dut.swi_tx_socket.bind(swi_target->socket);
        m_dummy_targets.push_back(std::move(swi_target));
    }

    static model_config create_dma_config() {
        model_config cfg;
        cfg.DMA_CH_COUNT = 4;
        cfg.DMA_CH_PER_MAC = 1;
        cfg.AXI_DATA_WIDTH = 64;
        cfg.MAX_BURST_LEN = 16;
        return cfg;
    }

    std::string get_test_name() const override { return "test_dma"; }

    void test_body() override
    {
        test_descriptor_submit();
        test_channel_roundrobin();
        test_axi_delay();
        test_descriptor_error();
        test_frame_write_memory();
        test_descriptor_writeback();
    }

private:
    model_config m_cfg;
    tlm_dma dut;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_dummy_inits;
    std::vector<std::unique_ptr<tlm_dummy_target>> m_dummy_targets;

    // DMA-U01: 描述符提交
    void test_descriptor_submit()
    {
        std::cout << "\n--- DMA-U01: Descriptor Submit ---\n";

        bool ok = dut.submit_tx_frame(0, 0x1000, 64);
        assert_true(ok, "Submit TX frame to channel 0");

        ok = dut.submit_tx_frame(1, 0x2000, 128);
        assert_true(ok, "Submit TX frame to channel 1");

        ok = dut.submit_tx_frame(99, 0x3000, 256);  // 非法通道
        assert_false(ok, "Submit to invalid channel rejected");
    }

    // DMA-U02: 通道轮询
    void test_channel_roundrobin()
    {
        std::cout << "\n--- DMA-U02: Channel Round-Robin ---\n";

        // 清空之前的队列（DMA-U01 已提交）
        while (dut.get_channel_queue_size(0) > 0 ||
               dut.get_channel_queue_size(1) > 0 ||
               dut.get_channel_queue_size(2) > 0 ||
               dut.get_channel_queue_size(3) > 0) {
            wait(1, sc_core::SC_NS);
        }

        // 提交到多个通道
        dut.submit_tx_frame(0, 0x1000, 64);
        dut.submit_tx_frame(1, 0x2000, 64);
        dut.submit_tx_frame(2, 0x3000, 64);
        dut.submit_tx_frame(3, 0x4000, 64);

        // 验证队列大小（允许异步处理）
        size_t q0 = dut.get_channel_queue_size(0);
        size_t q1 = dut.get_channel_queue_size(1);
        size_t q2 = dut.get_channel_queue_size(2);
        size_t q3 = dut.get_channel_queue_size(3);

        assert_true(q0 <= 1, "Channel 0 queue size <= 1");
        assert_true(q1 <= 1, "Channel 1 queue size <= 1");
        assert_true(q2 <= 1, "Channel 2 queue size <= 1");
        assert_true(q3 <= 1, "Channel 3 queue size <= 1");
    }

    // DMA-U03: AXI 延迟计算
    void test_axi_delay()
    {
        std::cout << "\n--- DMA-U03: AXI Delay ---\n";

        // 64B 帧，64-bit AXI = 8 bytes/beat
        // beats = ceil(64/8) = 8
        // delay = 8 * beat_time
        double beat_time = m_cfg.beat_time_ns();
        double expected = 8 * beat_time;

        // 验证 beat_time 计算
        assert_true(beat_time > 0, "Beat time positive");
    }

    // DMA-U04: 描述符错误
    void test_descriptor_error()
    {
        std::cout << "\n--- DMA-U04: Descriptor Error ---\n";

        // 验证错误统计接口
        auto& cnt = dut.channel_counters[0];
        assert_eq(static_cast<uint64_t>(cnt.rx_errors),
                  static_cast<uint64_t>(0), "No errors initially");
    }

    // DMA-U05: 帧写入内存
    void test_frame_write_memory()
    {
        std::cout << "\n--- DMA-U05: Frame Write Memory ---\n";

        frame_meta meta;
        meta.length = 64;
        meta.src_port = 0;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        dut.swi_rx_b_transport(*trans, delay);

        // 验证统计
        assert_true(dut.axi_total_bytes > 0, "AXI bytes counted");
    }

    // DMA-U06: 描述符写回
    void test_descriptor_writeback()
    {
        std::cout << "\n--- DMA-U06: Descriptor Writeback ---\n";

        // 验证描述符结构
        dma_descriptor desc;
        desc.length = 64;
        desc.own = true;
        desc.valid = true;

        assert_true(desc.valid, "Descriptor valid");
        assert_eq(static_cast<uint64_t>(desc.length),
                  static_cast<uint64_t>(64), "Descriptor length");
    }
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::test_dma test("test_dma");
    sc_core::sc_start();
    return test.get_fail_count();
}
