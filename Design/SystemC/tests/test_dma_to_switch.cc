/**
 * @file test_dma_to_switch.cc
 * @brief DMA ↔ Switch 集成测试
 *
 * 验证 DMA 与 Switch Core 之间的帧传输
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_dma.h"
#include "../models/tlm_switch_core.h"
#include "../models/frame_payload.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"

namespace ethernet_tlm {

class test_dma_to_switch : public unit_test_base {
public:
    SC_HAS_PROCESS(test_dma_to_switch);

    explicit test_dma_to_switch(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg(create_config())
        , dma("dma", m_cfg)
        , sw("switch", m_cfg)
    {
        // DMA ↔ Switch
        dma.swi_tx_socket.bind(*sw.rx_socket[0]);
        (*sw.tx_socket[0]).bind(dma.swi_rx_socket);

        // DMA AXI 到内存
        auto mem_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("mem_target")));
        dma.axi_socket.bind(mem_target->socket);
        m_targets.push_back(std::move(mem_target));

        // DMA CSR
        auto csr_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("csr_init")));
        csr_init->socket.bind(dma.csr_socket);
        m_inits.push_back(std::move(csr_init));

        // Switch 未使用端口
        auto sw_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("sw_dummy")));
        sw_dummy->socket.bind(*sw.rx_socket[1]);
        m_inits.push_back(std::move(sw_dummy));

        auto sw_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("sw_target")));
        (*sw.tx_socket[1]).bind(sw_target->socket);
        m_targets.push_back(std::move(sw_target));
    }

    static model_config create_config() {
        model_config cfg;
        cfg.DMA_CH_COUNT = 4;
        cfg.DMA_CH_PER_MAC = 1;
        cfg.SWITCH_PORT_COUNT = 2;
        return cfg;
    }

    std::string get_test_name() const override { return "test_dma_to_switch"; }

    void test_body() override
    {
        test_dma_to_switch_frame();
        test_switch_to_dma_frame();
    }

private:
    model_config m_cfg;
    tlm_dma dma;
    tlm_switch_core sw;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_inits;
    std::vector<std::unique_ptr<tlm_dummy_target>> m_targets;

    // INT-U04: DMA → Switch 帧传输
    void test_dma_to_switch_frame()
    {
        std::cout << "\n--- INT-U04: DMA to Switch ---\n";

        // 添加静态 FDB
        mac_addr_t dst_mac = {0x00, 0x11, 0x22, 0x33, 0x44, 0x66};
        sw.fdb_add_static(dst_mac, 1);

        // 提交 TX 帧到 DMA
        bool ok = dma.submit_tx_frame(0, 0x1000, 64);
        assert_true(ok, "Submit TX frame to DMA");

        // 验证队列
        assert_true(dma.get_channel_queue_size(0) > 0, "DMA queue not empty");
    }

    // INT-U05: Switch → DMA 帧传输
    void test_switch_to_dma_frame()
    {
        std::cout << "\n--- INT-U05: Switch to DMA ---\n";

        // 从 Switch 注入帧到 DMA
        frame_meta meta;
        meta.length = 64;
        meta.src_mac = {0x00, 0x11, 0x22, 0x33, 0x44, 0x55};
        meta.dst_mac = {0x00, 0x11, 0x22, 0x33, 0x44, 0x66};
        meta.src_port = 0;

        auto* trans = create_frame_payload(meta);
        sc_core::sc_time delay = sc_core::SC_ZERO_TIME;

        dma.swi_rx_b_transport(*trans, delay);

        // 验证 AXI 统计
        assert_true(dma.axi_total_bytes > 0, "DMA AXI bytes counted");
    }
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::test_dma_to_switch test("test_dma_to_switch");
    sc_core::sc_start();
    return test.get_fail_count();
}
