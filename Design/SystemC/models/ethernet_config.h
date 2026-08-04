#ifndef ETHERNET_CONFIG_H
#define ETHERNET_CONFIG_H

/**
 * @file ethernet_config.h
 * @brief Ethernet IP TLM 模型配置参数
 *
 * 参数值与 Arch Spec §1.4 保持一致
 */

#include "ethernet_types.h"

namespace ethernet_tlm {

// ============================================================
// 模型配置参数（对应 Arch Spec §1.4）
// ============================================================
struct model_config {
    // MAC 配置
    unsigned int MAC_COUNT = 2;
    unsigned int PHY_COUNT = 2;

    // Switch 配置（端口数 = MAC 端口 + DMA 专用口）
    unsigned int SWITCH_PORT_COUNT = 5;  // 4 MAC + 1 DMA
    bool         SUPPORT_SWITCH = true;
    bool         SWITCH_TAS = true;
    bool         SWITCH_L3 = false;
    bool         SUPPORT_FP = true;       // 帧抢占
    bool         SUPPORT_CBS = true;
    bool         SUPPORT_TAS = true;
    bool         SUPPORT_VLAN = true;

    // MTL 队列
    unsigned int MTL_TX_QUEUES = 8;
    unsigned int MTL_RX_QUEUES = 8;
    unsigned int MTL_TX_FIFO_DEPTH = 4096;   // bytes
    unsigned int MTL_RX_FIFO_DEPTH = 4096;   // bytes

    // DMA 配置
    unsigned int DMA_CH_COUNT = 2;
    unsigned int DMA_CH_PER_MAC = 1;
    unsigned int DESC_SIZE = 32;             // bytes
    unsigned int AXI_DATA_WIDTH = 64;        // bits
    unsigned int MAX_BURST_LEN = 16;         // beats
    unsigned int AXI_OUTSTANDING = 4;

    // PHC 配置
    unsigned int PHC_COUNT = 2;
    bool         SUPPORT_VPHC = true;  // 启用 vPHC
    unsigned int VPHC_VM_COUNT = 4;

    // 速率配置 (Mbps)
    unsigned int MAC_SPEED[8] = {5000, 5000, 5000, 5000, 1000, 1000, 100, 10};

    // 仿真参数
    double       AXI_CLOCK_MHZ = 500.0;      // AXI 时钟频率
    double       TIMESTAMP_RES_NS = 1.0;     // 时间戳分辨率 1ns

    // FDB 配置
    unsigned int FDB_SIZE = 4096;            // FDB 条目数
    double       FDB_AGING_TIME_MS = 300.0;  // 老化时间 (默认 300s)

    // TAS 配置
    unsigned int TAS_MAX_GCL_ENTRIES = 64;

    // 计算辅助
    double byte_time_ns(unsigned int port) const {
        // 每字节传输时间 (ns) = 8 / (speed_mbps * 1e6) * 1e9
        return 8.0 / (static_cast<double>(MAC_SPEED[port]) * 1e6) * 1e9;
    }

    double beat_time_ns() const {
        // AXI beat 时间 (ns)
        return (AXI_DATA_WIDTH / 8.0) / (AXI_CLOCK_MHZ * 1e6) * 1e9;
    }
};

} // namespace ethernet_tlm

#endif // ETHERNET_CONFIG_H
