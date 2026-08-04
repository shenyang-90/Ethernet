/**
 * @file sc03_concurrent_simple.cc
 * @brief SC-03 简化版：多端口并发系统测试
 *
 * 验证 DMA 通道池仲裁与共享缓存行为（简化版：1 MAC + DMA）
 */

#include <systemc>
#include <iostream>
#include <memory>
#include <vector>

#include "unit_test_base.h"
#include "../models/tlm_traffic_gen.h"
#include "../models/tlm_mac.h"
#include "../models/tlm_switch_core.h"
#include "../models/tlm_dma.h"
#include "../models/tlm_phc.h"
#include "../models/frame_payload.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"
#include "../utils/statistics.h"

namespace ethernet_tlm {

class sc03_concurrent_simple : public unit_test_base {
public:
    SC_HAS_PROCESS(sc03_concurrent_simple);

    explicit sc03_concurrent_simple(sc_core::sc_module_name name)
        : unit_test_base(name)
        , m_cfg(create_config())
        , phc("phc", m_cfg, 0)
        , mac("mac", m_cfg, 0, &phc)
        , sw("switch", m_cfg)
        , dma("dma", m_cfg)
        , tg("traffic_gen", m_cfg, 0)
    {
        // 绑定 PHC
        auto phc_dummy = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("phc_dummy")));
        phc_dummy->socket.bind(phc.socket);
        m_dummies.push_back(std::move(phc_dummy));

        // MAC ↔ Switch 端口 0
        mac.swi_tx_socket.bind(*sw.rx_socket[0]);
        (*sw.tx_socket[0]).bind(mac.swi_rx_socket);

        // DMA ↔ Switch 端口 1
        dma.swi_tx_socket.bind(*sw.rx_socket[1]);
        (*sw.tx_socket[1]).bind(dma.swi_rx_socket);

        // Traffic Gen ↔ MAC
        tg.socket.bind(mac.phy_rx_socket);
        mac.phy_tx_socket.bind(tg.rx_socket);

        // DMA AXI 到内存
        auto mem_target = std::unique_ptr<tlm_dummy_target>(
            new tlm_dummy_target(sc_core::sc_module_name("mem_target")));
        dma.axi_socket.bind(mem_target->socket);
        m_targets.push_back(std::move(mem_target));

        // DMA CSR
        auto csr_init = std::unique_ptr<tlm_dummy_initiator>(
            new tlm_dummy_initiator(sc_core::sc_module_name("csr_init")));
        csr_init->socket.bind(dma.csr_socket);
        m_dummies.push_back(std::move(csr_init));
    }

    static model_config create_config() {
        model_config cfg;
        cfg.SWITCH_PORT_COUNT = 2;
        cfg.DMA_CH_COUNT = 2;
        cfg.DMA_CH_PER_MAC = 1;
        return cfg;
    }

    std::string get_test_name() const override { return "sc03_concurrent_simple"; }

    void test_body() override
    {
        std::cout << "\n========================================\n";
        std::cout << "SC-03 Simple: Multi-Port Concurrent Test\n";
        std::cout << "========================================\n";

        // 添加静态 FDB
        mac_addr_t mac_addr = {0x00, 0x11, 0x22, 0x33, 0x44, 0x60};
        sw.fdb_add_static(mac_addr, 0);
        mac_addr_t dma_mac = {0x00, 0x11, 0x22, 0x33, 0x44, 0x70};
        sw.fdb_add_static(dma_mac, 1);

        // 启动 MAC 侧流量
        std::cout << "[INFO] Starting MAC-side traffic...\n";
        tg.start(1000.0);

        // 启动 DMA 侧流量
        std::cout << "[INFO] Starting DMA-side traffic...\n";
        for (int i = 0; i < 2; ++i) {
            dma.submit_tx_frame(i, 0x1000 + i * 0x100, 64);
        }

        // 运行 500us
        wait(500, sc_core::SC_US);

        tg.stop();

        // 检查结果
        std::cout << "\n========================================\n";
        std::cout << "Results\n";
        std::cout << "========================================\n";
        std::cout << "Traffic Gen TX: " << tg.tx_frames << " frames\n";
        std::cout << "MAC RX: " << mac.counters.rx_frames << " frames\n";
        std::cout << "DMA TX: " << dma.channel_counters[0].tx_frames + dma.channel_counters[1].tx_frames << " frames\n";
        std::cout << "DMA AXI Bytes: " << dma.axi_total_bytes << " bytes\n";

        // 公平性计算
        std::vector<double> rates;
        for (int i = 0; i < 2; ++i) {
            rates.push_back(static_cast<double>(dma.channel_counters[i].tx_frames));
        }
        double fairness = statistics::jains_fairness_index(rates);

        std::cout << "DMA Fairness (Jain's Index): " << fairness << "\n";

        bool pass = (tg.tx_frames > 0) && (mac.counters.rx_frames > 0) && (fairness >= 0.9);

        std::cout << "\n========================================\n";
        std::cout << "Verdict: " << (pass ? "PASS" : "FAIL") << "\n";
        std::cout << "========================================\n\n";

        assert_true(pass, "Multi-port concurrent forwarding");
    }

private:
    model_config m_cfg;
    tlm_phc phc;
    tlm_mac mac;
    tlm_switch_core sw;
    tlm_dma dma;
    tlm_traffic_gen tg;
    std::vector<std::unique_ptr<tlm_dummy_initiator>> m_dummies;
    std::vector<std::unique_ptr<tlm_dummy_target>> m_targets;
};

} // namespace ethernet_tlm

int sc_main(int argc, char* argv[])
{
    ethernet_tlm::sc03_concurrent_simple test("sc03_concurrent_simple");
    sc_core::sc_start();
    return test.get_fail_count();
}
