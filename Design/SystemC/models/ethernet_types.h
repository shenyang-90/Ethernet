#ifndef ETHERNET_TYPES_H
#define ETHERNET_TYPES_H

/**
 * @file ethernet_types.h
 * @brief Ethernet IP TLM 模型公共类型定义
 */

#include <cstdint>
#include <array>
#include <vector>
#include <systemc>

namespace ethernet_tlm {

// ============================================================
// 基础常量
// ============================================================
static constexpr size_t MAX_FRAME_SIZE      = 9018;  // Jumbo frame
static constexpr size_t MIN_FRAME_SIZE      = 64;    // Ethernet min
static constexpr size_t ETHERNET_HEADER_LEN = 14;    // DA(6)+SA(6)+Type(2)
static constexpr size_t VLAN_TAG_LEN        = 4;     // 802.1Q tag
static constexpr size_t FCS_LEN             = 4;
static constexpr size_t PREAMBLE_LEN        = 7;
static constexpr size_t SFD_LEN             = 1;
static constexpr size_t IFG_LEN             = 12;

// ============================================================
// 地址类型
// ============================================================
using mac_addr_t = std::array<uint8_t, 6>;
using ipv4_addr_t = uint32_t;

static constexpr mac_addr_t BROADCAST_MAC = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};

// ============================================================
// 帧元数据（随 TLM payload 传输）
// ============================================================
struct frame_meta {
    // 帧标识
    uint64_t frame_id = 0;
    uint16_t length = 0;           // 帧长度（含 FCS）

    // 地址
    mac_addr_t dst_mac = {};
    mac_addr_t src_mac = {};
    uint16_t ether_type = 0;

    // VLAN
    bool     vlan_valid = false;
    uint16_t vlan_id = 0;
    uint8_t  vlan_pcp = 0;         // Priority Code Point (0~7)
    uint8_t  vlan_dei = 0;

    // 端口与时间戳
    int      src_port = -1;        // 源端口 ID
    int      dst_port = -1;        // 目的端口（转发决策结果）
    sc_core::sc_time ingress_time; // 进入 Switch 时间
    sc_core::sc_time sfd_timestamp; // SFD 检测时间戳（PHC）

    // 流量分类
    uint8_t  traffic_class = 0;    // TC 0~7
    uint8_t  queue_id = 0;         // 队列编号
    bool     is_avtp = false;
    uint16_t avtp_stream_id = 0;

    // 错误标志
    bool     fcs_error = false;
    bool     runt_frame = false;
    bool     giant_frame = false;
    bool     pause_frame = false;

    // 转发控制
    bool     cut_through = false;  // cut-through 模式
    bool     flood = false;        // 泛洪（FDB 未命中）
    bool     drop = false;         // 丢弃标记

    // DMA 相关
    int      dma_channel = -1;
    uint64_t desc_addr = 0;        // 描述符物理地址
    uint64_t buffer_addr = 0;      // 数据缓冲区地址

    // TSN
    bool     tas_scheduled = false; // 是否经 TAS 调度
    sc_core::sc_time gate_open_time;
};

// ============================================================
// DMA 描述符（32-byte，对应 Arch Spec §1.4.5）
// ============================================================
struct dma_descriptor {
    // Word 0-1: Buffer Address
    uint64_t buffer_addr = 0;

    // Word 2: Control/Status
    uint32_t length = 0;           // 帧长度
    bool     own = false;          // OWN bit (1=DMA owns, 0=Host owns)
    bool     first_desc = false;   // First descriptor of frame
    bool     last_desc = false;    // Last descriptor of frame
    bool     error = false;        // Error summary

    // Word 3: Extended Status
    uint16_t vlan_tag = 0;
    uint8_t  traffic_class = 0;
    uint8_t  src_port = 0;

    // Word 4-5: Timestamp
    uint64_t timestamp = 0;        // PHC 时间戳 (ns)

    // Word 6-7: AVTP / Reserved
    uint16_t avtp_stream_id = 0;
    uint16_t reserved = 0;

    // 辅助字段（模型内部使用，非真实描述符内容）
    uint64_t desc_addr = 0;        // 描述符自身物理地址
    int      channel_id = -1;
    bool     valid = false;
};

// ============================================================
// FDB 条目
// ============================================================
struct fdb_entry {
    mac_addr_t mac;
    int        port = -1;
    bool       is_static = false;
    sc_core::sc_time timestamp;    // 学习时间（用于老化）
    uint16_t   vlan_id = 0;
    bool       valid = false;
};

// ============================================================
// TAS 门控条目
// ============================================================
struct tas_gate_entry {
    uint8_t  gate_mask = 0xFF;     // bit[i] = queue i 门控状态 (1=open)
    sc_core::sc_time duration;     // 持续时间
};

// ============================================================
// CBS 信用参数
// ============================================================
struct cbs_credit {
    int64_t  credit = 0;           // 当前信用值 (bits)
    int64_t  idle_slope = 0;       // 空闲斜率 (bits/s)
    int64_t  send_slope = 0;       // 发送斜率 (bits/s)
    int64_t  hi_credit = 0;        // 信用上限
    int64_t  lo_credit = 0;        // 信用下限
    sc_core::sc_time last_update;  // 上次更新时间
};

// ============================================================
// 统计计数器
// ============================================================
struct port_counters {
    uint64_t rx_frames = 0;
    uint64_t tx_frames = 0;
    uint64_t rx_bytes = 0;
    uint64_t tx_bytes = 0;
    uint64_t rx_dropped = 0;
    uint64_t tx_dropped = 0;
    uint64_t rx_errors = 0;
    uint64_t fcs_errors = 0;
    uint64_t runt_frames = 0;
    uint64_t giant_frames = 0;
    uint64_t fifo_overflow = 0;
};

// ============================================================
// 辅助函数
// ============================================================
inline bool is_multicast(const mac_addr_t& addr) {
    return (addr[0] & 0x01) != 0;
}

inline bool is_broadcast(const mac_addr_t& addr) {
    return addr == BROADCAST_MAC;
}

inline std::string mac_to_string(const mac_addr_t& addr) {
    char buf[18];
    snprintf(buf, sizeof(buf), "%02X:%02X:%02X:%02X:%02X:%02X",
             addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
    return std::string(buf);
}

} // namespace ethernet_tlm

#endif // ETHERNET_TYPES_H
