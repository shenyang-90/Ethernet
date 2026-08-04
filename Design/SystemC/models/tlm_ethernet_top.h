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
#include <cstdlib>

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

    // VCD 跟踪信号
    sc_core::sc_signal<uint64_t> sig_tx_frames;
    sc_core::sc_signal<uint64_t> sig_rx_frames;
    sc_core::sc_signal<uint32_t> sig_queue_occupancy;
    sc_core::sc_signal<uint8_t>  sig_gate_state;
    sc_core::sc_signal<uint64_t> sig_error_count;

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

        // 初始化 VCD 信号
        sig_tx_frames.write(0);
        sig_rx_frames.write(0);
        sig_queue_occupancy.write(0);
        sig_gate_state.write(0xFF);
        sig_error_count.write(0);

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

    /**
     * @brief 初始化 VCD 波形跟踪
     * @param case_name 测试用例名（用于创建 tmp/<case_name>/ 目录）
     */
    void init_vcd_trace(const std::string& case_name)
    {
        // 创建 tmp/<case_name>/ 目录
        std::string dir = "tmp/" + case_name;
        std::string cmd = "mkdir -p " + dir;
        system(cmd.c_str());

        // 初始化 VCD（sc_create_vcd_trace_file 自动添加 .vcd 后缀）
        std::string vcd_file = dir + "/waveform";
        tracer.init_vcd(vcd_file);

        // 跟踪顶层信号
        tracer.trace_signal("tx_frames", sig_tx_frames);
        tracer.trace_signal("rx_frames", sig_rx_frames);
        tracer.trace_signal("queue_occupancy", sig_queue_occupancy);
        tracer.trace_signal("gate_state", sig_gate_state);
        tracer.trace_signal("error_count", sig_error_count);

        // 初始化日志
        std::string log_file = dir + "/simulation.log";
        tracer.init_log(log_file);

        tracer.info("top", "VCD trace initialized: " + vcd_file);
    }

    /**
     * @brief 更新 VCD 信号（周期性调用）
     */
    void update_vcd_signals()
    {
        uint64_t total_tx = 0, total_rx = 0, total_err = 0;
        for (auto& mac : macs) {
            total_tx += mac->counters.tx_frames;
            total_rx += mac->counters.rx_frames;
            total_err += mac->counters.rx_errors;
        }
        sig_tx_frames.write(total_tx);
        sig_rx_frames.write(total_rx);
        sig_error_count.write(total_err);

        if (switch_core) {
            sig_queue_occupancy.write(switch_core->get_queue_occupancy(0, 0));
        }
    }

    /**
     * @brief 导出统计到 tmp/<case_name>/
     */
    void export_statistics(const std::string& case_name)
    {
        std::string prefix = "tmp/" + case_name + "/metrics";
        stats.export_csv(prefix + ".csv");
        stats.export_json(prefix + ".json");
        stats.print_summary();

        // 导出帧跟踪
        tracer.export_frame_trace("tmp/" + case_name + "/frame_trace.csv");
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
