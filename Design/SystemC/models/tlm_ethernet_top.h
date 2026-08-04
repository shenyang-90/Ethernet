#ifndef TLM_ETHERNET_TOP_H
#define TLM_ETHERNET_TOP_H

/**
 * @file tlm_ethernet_top.h
 * @brief Ethernet IP TLM 2.0 Top-Level Model
 *
 * 集成 Switch Core、MAC、PHC、vPHC、DMA、Host、Traffic Generator
 */

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include <memory>
#include <vector>

#include "ethernet_types.h"
#include "ethernet_config.h"
#include "frame_payload.h"
#include "tlm_switch_core.h"
#include "tlm_mac.h"
#include "tlm_phc.h"
#include "tlm_vphc.h"
#include "tlm_dma.h"
#include "tlm_host.h"
#include "tlm_traffic_gen.h"
#include "../utils/tlm_dummy_initiator.h"
#include "../utils/tlm_dummy_target.h"
#include "../utils/statistics.h"
#include "../utils/trace_helper.h"

namespace ethernet_tlm {

/**
 * @class tlm_ethernet_top
 * @brief Ethernet IP 顶层 TLM 模型
 */
class tlm_ethernet_top : public sc_core::sc_module {
public:
    // 外部接口
    tlm_utils::simple_target_socket<tlm_ethernet_top>   csr_socket;
    tlm_utils::simple_target_socket<tlm_ethernet_top>   host_socket;

    // 子模块
    std::unique_ptr<tlm_switch_core> switch_core;
    std::vector<std::unique_ptr<tlm_mac>> macs;
    std::vector<std::unique_ptr<tlm_phc>> phcs;
    std::unique_ptr<tlm_vphc> vphc;
    std::unique_ptr<tlm_dma> dma;
    std::unique_ptr<tlm_host> host;
    std::vector<std::unique_ptr<tlm_traffic_gen>> traffic_gens;

    // 统计与跟踪
    statistics stats;
    trace_helper tracer;

    // 配置
    const model_config cfg;

    SC_HAS_PROCESS(tlm_ethernet_top);

    explicit tlm_ethernet_top(sc_core::sc_module_name name,
                              const model_config& c = model_config())
        : sc_core::sc_module(name)
        , csr_socket("csr_socket")
        , host_socket("host_socket")
        , cfg(c)
    {
        // 注册外部接口
        csr_socket.register_b_transport(this, &tlm_ethernet_top::csr_b_transport);
        host_socket.register_b_transport(this, &tlm_ethernet_top::host_b_transport);

        // 创建 PHC
        for (unsigned int i = 0; i < cfg.PHC_COUNT; ++i) {
            char name[32];
            snprintf(name, sizeof(name), "phc_%u", i);
            phcs.push_back(std::make_unique<tlm_phc>(name, cfg, i));
        }

        // 创建 vPHC
        if (cfg.SUPPORT_VPHC && !phcs.empty()) {
            vphc = std::make_unique<tlm_vphc>("vphc", cfg, phcs[0].get());
        }

        // 创建 Switch Core
        switch_core = std::make_unique<tlm_switch_core>("switch_core", cfg);

        // 创建 MAC
        for (unsigned int i = 0; i < cfg.MAC_COUNT; ++i) {
            char name[32];
            snprintf(name, sizeof(name), "mac_%u", i);
            macs.push_back(std::make_unique<tlm_mac>(name, cfg, i,
                i < phcs.size() ? phcs[i].get() : nullptr));
        }

        // 创建 DMA
        dma = std::make_unique<tlm_dma>("dma", cfg);

        // 创建 Host
        host = std::make_unique<tlm_host>("host", cfg, dma.get());

        // 创建 Traffic Generator
        for (unsigned int i = 0; i < cfg.MAC_COUNT; ++i) {
            char name[32];
            snprintf(name, sizeof(name), "traffic_gen_%u", i);
            traffic_gens.push_back(std::make_unique<tlm_traffic_gen>(name, cfg, i));
        }

        // ============================================================
        // Socket 绑定
        // ============================================================

        // MAC ↔ Switch Core（前 MAC_COUNT 个端口）
        for (unsigned int i = 0; i < cfg.MAC_COUNT && i < cfg.SWITCH_PORT_COUNT; ++i) {
            macs[i]->swi_tx_socket.bind(*switch_core->rx_socket[i]);
            switch_core->tx_socket[i]->bind(macs[i]->swi_rx_socket);
        }

        // DMA ↔ Switch Core（专用端口，索引 = SWITCH_PORT_COUNT - 1）
        unsigned int dma_port = cfg.SWITCH_PORT_COUNT - 1;
        if (dma_port >= cfg.MAC_COUNT && dma_port < cfg.SWITCH_PORT_COUNT) {
            dma->swi_tx_socket.bind(*switch_core->rx_socket[dma_port]);
            switch_core->tx_socket[dma_port]->bind(dma->swi_rx_socket);
        }

        // Traffic Generator ↔ MAC
        for (unsigned int i = 0; i < cfg.MAC_COUNT; ++i) {
            traffic_gens[i]->socket.bind(macs[i]->phy_rx_socket);
            macs[i]->phy_tx_socket.bind(traffic_gens[i]->rx_socket);
        }

        // Host ↔ DMA
        host->csr_socket.bind(dma->csr_socket);

        // 绑定未使用的 socket
        bind_unused_sockets();
    }

    void csr_b_transport(tlm::tlm_generic_payload& trans,
                         sc_core::sc_time& delay)
    {
        wait(delay);
        delay = sc_core::SC_ZERO_TIME;
        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    void host_b_transport(tlm::tlm_generic_payload& trans,
                          sc_core::sc_time& delay)
    {
        wait(delay);
        delay = sc_core::SC_ZERO_TIME;
        trans.set_response_status(tlm::TLM_OK_RESPONSE);
    }

    void start_traffic(unsigned int port, double rate_mbps)
    {
        if (port < traffic_gens.size()) {
            traffic_gens[port]->start(rate_mbps);
        }
    }

    void stop_traffic(unsigned int port)
    {
        if (port < traffic_gens.size()) {
            traffic_gens[port]->stop();
        }
    }

    void start_host_traffic(double rate_mbps)
    {
        if (host) {
            host->start_traffic(rate_mbps);
        }
    }

    void stop_host_traffic()
    {
        if (host) {
            host->stop_traffic();
        }
    }

    void export_statistics(const std::string& prefix)
    {
        stats.export_csv(prefix + ".csv");
        stats.export_json(prefix + ".json");
        stats.print_summary();
    }

    sc_core::sc_time get_phc_timestamp(unsigned int phc_id = 0) const
    {
        if (phc_id < phcs.size()) {
            return phcs[phc_id]->get_timestamp();
        }
        return sc_core::SC_ZERO_TIME;
    }

    sc_core::sc_time get_vm_time(uint32_t vm_id) const
    {
        if (vphc) {
            return vphc->get_vm_time(vm_id);
        }
        return sc_core::SC_ZERO_TIME;
    }

private:
    std::vector<std::unique_ptr<tlm_dummy_initiator>> dummy_inits;
    std::vector<std::unique_ptr<tlm_dummy_target>> dummy_targets;

    void bind_unused_sockets()
    {
        // CSR 外部接口（内部绑定到 dummy，避免外部未绑定错误）
        auto dummy_csr = std::make_unique<tlm_dummy_initiator>(
            sc_core::sc_gen_unique_name("dummy_csr"));
        dummy_csr->socket.bind(csr_socket);
        dummy_inits.push_back(std::move(dummy_csr));

        // Host 外部接口（内部绑定到 dummy）
        auto dummy_host = std::make_unique<tlm_dummy_initiator>(
            sc_core::sc_gen_unique_name("dummy_host_ext"));
        dummy_host->socket.bind(host_socket);
        dummy_inits.push_back(std::move(dummy_host));

        // PHC socket
        for (auto& phc : phcs) {
            auto dummy = std::make_unique<tlm_dummy_initiator>(
                sc_core::sc_gen_unique_name("dummy_phc"));
            dummy->socket.bind(phc->socket);
            dummy_inits.push_back(std::move(dummy));
        }

        // vPHC socket
        if (vphc) {
            auto dummy = std::make_unique<tlm_dummy_initiator>(
                sc_core::sc_gen_unique_name("dummy_vphc"));
            dummy->socket.bind(vphc->socket);
            dummy_inits.push_back(std::move(dummy));
        }

        // DMA AXI socket
        auto dummy_mem = std::make_unique<tlm_dummy_target>("dummy_mem");
        dma->axi_socket.bind(dummy_mem->socket);
        dummy_targets.push_back(std::move(dummy_mem));

        // 未使用的 Switch 端口（排除 DMA 端口）
        for (unsigned int i = cfg.MAC_COUNT; i < cfg.SWITCH_PORT_COUNT - 1; ++i) {
            auto dummy_init = std::make_unique<tlm_dummy_initiator>(
                sc_core::sc_gen_unique_name("dummy_switch"));
            dummy_init->socket.bind(*switch_core->rx_socket[i]);
            dummy_inits.push_back(std::move(dummy_init));

            auto dummy_target = std::make_unique<tlm_dummy_target>(
                sc_core::sc_gen_unique_name("dummy_switch_target"));
            (*switch_core->tx_socket[i]).bind(dummy_target->socket);
            dummy_targets.push_back(std::move(dummy_target));
        }
    }
};

} // namespace ethernet_tlm

#endif // TLM_ETHERNET_TOP_H
