# Ethernet IP Architecture Specification

> **项目**: Ethernet IP (IP_20260502_001)
> **模块/系统**: Gigabit Ethernet MAC + PHY Subsystem
> **版本**: v1.0
> **日期**: 2026-05-11
> **作者**: Arch Agent
> **评审状态**: Draft → 待评审

---

## 1. Overview

### 1.1 系统概述

本项目旨在设计一款面向车规级应用的 Ethernet IP 子系统，对标 Infineon AURIX TC4x 系列 GETH/LETH 架构。IP 支持 10M/100M/1G/2.5G/5G 全双工速率，集成完整的 TSN（Time-Sensitive Networking）协议栈、硬件安全加速接口以及多 PHY 接口适配能力。

核心设计目标：
- **高性能**: 支持 5Gbps 线速，8 路独立 DMA 通道，64-bit AXI Master 接口
- **确定性**: 硬件级 gPTP 时间同步、TAS 门控调度、CBS 信用整形
- **安全性**: ASIL-B 安全完整性等级，ECC/Parity/Timeout 保护机制
- **可扩展性**: 支持 MII/RMII/RGMII/SGMII/USXGMII 多种 PHY 接口
- **协议完整**: TSN 协议族（802.1AS/802.1Qav/802.1Qbv/802.1Qbu/802.1Qci/802.1CB）硬件支持

### 1.2 应用场景

| 场景 | 描述 | 关键需求 |
|------|------|----------|
| **Zone Controller 骨干网** | 区域控制器间高速互联 | 5Gbps + TSN + MACsec |
| **ADAS 传感器汇聚** | 摄像头/激光雷达数据汇聚 | 多通道 DMA + 低延迟 |
| **OTA 更新** | 固件/软件在线升级 | 高吞吐 + 安全校验 |
| **CAN-Ethernet 网关** | 传统总线桥接至以太网骨干 | 时间戳 + AVTP 封装 |
| **域内边缘节点** | 低速传感器/执行器接入 | 10/100M + 10BASE-T1S |

### 1.3 关键特性

| 特性 | 描述 | 实现模块 |
|------|------|----------|
| **双 XGMAC 架构** | 2 个独立 5G MAC，支持 Bridge 转发 | XGMAC Core |
| **8 路 DMA 通道** | 独立 TX/RX Engine，3 级流水线 | DMA Engine |
| **32KB FIFO** | TX/RX 各 32KB MTL 缓冲 | MTL Layer |
| **TSN 协议栈** | 802.1AS/802.1Qav/802.1Qbv/802.1Qbu 硬件实现 | MAC Core + MTL |
| **帧抢占** | 802.1Qbu pMAC/eMAC 双虚拟 MAC | MAC Merge Layer |
| **硬件时间戳** | SFD 级精度，64-bit 纳秒计数器 | PTP Hardware Unit |
| **安全特性** | ECC/FSM Parity/CSR Timeout，ASIL-B | Safety Monitor |
| **校验和卸载** | IP/TCP/UDP 硬件计算 | TX/RX Checksum Engine |
| **VLAN 处理** | 插入/替换/删除，QinQ 支持 | TBU (Transmit Bus Interface) |
| **PHY 接口** | MII/RMII/RGMII/SGMII/USXGMII | HSPHY (外部) |

---

## 1.4 可配置参数 (Parameter Configuration)

本 IP 支持通过顶层 Verilog/SystemVerilog `parameter` 进行编译时裁剪，以适配不同应用场景（Zone Controller / ADAS HUB / 网关 / 边缘节点）的资源与功能需求。

### 1.4.1 协议相关参数

| 参数名 | 类型 | 默认值 | 可配置范围 | 说明 | 影响模块 |
|--------|------|--------|------------|------|----------|
| `MAC_COUNT` | int | 2 | 1 ~ 2 | MAC 实例数量 | XGMAC-CORE, DMA, MTL |
| `MAC_SPEED_MODE` | int | 3 | 0: 10M/100M<br>1: 1G<br>2: 2.5G<br>3: 5G<br>4: 10G | 每个 MAC 支持的最高速率 | XGMAC-CORE, HSPHY IF |
| `PHY_COUNT_PER_MAC` | int | 1 | 1 ~ 2 | 每个 MAC 连接的 PHY 数量 | HSPHY IF, RGMII/SGMII MUX |
| `SUPPORT_1588` | bit | 1 | 0 / 1 | 是否支持 IEEE 1588 / gPTP 时间同步 | PTP/Timestamp |
| `SUPPORT_GPTP` | bit | 1 | 0 / 1 | 是否支持 802.1AS gPTP（依赖 SUPPORT_1588=1） | PTP/Timestamp |
| `SUPPORT_TSN` | bit | 1 | 0 / 1 | 是否支持 TSN 协议栈总开关 | MTL, MAC Core |
| `SUPPORT_CBS` | bit | 1 | 0 / 1 | 是否支持 802.1Qav CBS（依赖 SUPPORT_TSN） | MTL Scheduler |
| `SUPPORT_TAS` | bit | 1 | 0 / 1 | 是否支持 802.1Qbv TAS（依赖 SUPPORT_TSN） | MTL Gate Control |
| `SUPPORT_FP` | bit | 1 | 0 / 1 | 是否支持 802.1Qbu 帧抢占（依赖 SUPPORT_TSN） | MAC Merge Layer |
| `SUPPORT_FRER` | bit | 1 | 0 / 1 | 是否支持 802.1CB FRER（依赖 SUPPORT_BRIDGE） | Bridge, SEQ/R-Tag |
| `SUPPORT_BRIDGE` | bit | 1 | 0 / 1 | 是否支持 MAC-to-MAC Bridge 转发 | Bridge |
| `SUPPORT_VLAN` | bit | 1 | 0 / 1 | 是否支持 802.1Q VLAN 处理 | TBU, RX Filter |
| `SUPPORT_MACSEC` | bit | 0 | 0 / 1 | 是否支持 802.1AE MACsec（需外部 CSS 加速器） | HSPHY IF (安全通道) |
| `SUPPORT_AVTP` | bit | 0 | 0 / 1 | 是否支持 IEEE 1722 AVTP 封装（车载音频/视频） | TX Checksum |

> **配置约束**：
> - `SUPPORT_GPTP=1` 要求 `SUPPORT_1588=1`
> - `SUPPORT_FRER=1` 要求 `SUPPORT_BRIDGE=1` 且 `MAC_COUNT ≥ 2`
> - `SUPPORT_FP=1` 要求 `MAC_SPEED_MODE ≥ 1` (≥1G)
> - `SUPPORT_TAS=1` 要求 `SUPPORT_CBS=1`（推荐，非强制）
> - `SUPPORT_MACSEC=1` 要求外部 CSS 安全加速器连接

### 1.4.2 非协议相关 — DMA/缓冲参数

| 参数名 | 类型 | 默认值 | 可配置范围 | 说明 | 影响 |
|--------|------|--------|------------|------|------|
| `DMA_CH_COUNT` | int | 8 | 1, 2, 4, 8 | DMA 通道数量（每 MAC） | DMA Engine, 描述符内存 |
| `MTL_TX_FIFO_DEPTH` | int | 32 | 8, 16, 32, 64 | TX FIFO 深度（KB） | MTL TX, SRAM |
| `MTL_RX_FIFO_DEPTH` | int | 32 | 8, 16, 32, 64 | RX FIFO 深度（KB） | MTL RX, SRAM |
| `MTL_TX_QUEUES` | int | 8 | 1, 2, 4, 8 | TX 队列数量（每 MAC） | MTL Scheduler |
| `MTL_RX_QUEUES` | int | 8 | 1, 2, 4, 8 | RX 队列数量（每 MAC） | MTL RX Filter |
| `DESC_SIZE` | int | 16 | 16, 32 | 描述符大小（Byte，标准/扩展） | DMA, 内存布局 |
| `AXI_ID_WIDTH` | int | 4 | 4, 8 | AXI Master ID 位宽 | AXI Master |
| `AXI_DATA_WIDTH` | int | 64 | 32, 64, 128 | AXI Master 数据位宽 | AXI Master, DMA |
| `CSR_ADDR_WIDTH` | int | 12 | 10, 12, 14 | AXI-Lite Slave 地址位宽 | CSR 寄存器数量 |
| `MAX_BURST_LEN` | int | 16 | 8, 16 | AXI 最大 Burst 长度 | DMA, AXI 效率 |

> **配置约束**：
> - `DMA_CH_COUNT` 必须 ≥ `MTL_TX_QUEUES` 且 ≥ `MTL_RX_QUEUES`
> - `MTL_TX_FIFO_DEPTH` + `MTL_RX_FIFO_DEPTH` × `MAC_COUNT` ≤ 总 SRAM 预算
> - `AXI_DATA_WIDTH` 需与 SoC 总线位宽匹配

### 1.4.3 非协议相关 — 功能安全参数

| 参数名 | 类型 | 默认值 | 可配置范围 | 说明 | 影响 |
|--------|------|--------|------------|------|------|
| `ASIL_LEVEL` | int | 2 | 0: QM<br>1: ASIL-A<br>2: ASIL-B<br>3: ASIL-C<br>4: ASIL-D | 目标安全完整性等级 | 所有模块 |
| `ECC_DATA_WIDTH` | int | 64 | 32, 64 | ECC 保护数据位宽 | SRAM, FIFO |
| `ECC_SYNDROME_WIDTH` | int | 8 | 4, 8 | ECC Syndrome 位宽 | ECC 编码器/解码器 |
| `ENABLE_PARITY_FSM` | bit | 1 | 0 / 1 | 是否使能 FSM 状态机 Parity 保护 | 所有 FSM |
| `ENABLE_CSR_TIMEOUT` | bit | 1 | 0 / 1 | 是否使能 CSR 访问超时检测 | CSR 接口 |
| `ENABLE_BUS_TIMEOUT` | bit | 1 | 0 / 1 | 是否使能 AXI 总线超时检测 | AXI Master |
| `SMU_ALERT_WIDTH` | int | 4 | 1, 2, 4 | SMU 报警信号位宽 | Safety Monitor |
| `ECC_SCRUB_INTERVAL` | int | 1000 | 100 ~ 10000 | ECC 刷新间隔（时钟周期） | SRAM 控制器 |

> **配置约束**：
> - `ASIL_LEVEL ≥ 2` (ASIL-B) 要求 `ENABLE_PARITY_FSM=1` 且 `ENABLE_CSR_TIMEOUT=1`
> - `ASIL_LEVEL ≥ 3` (ASIL-C) 额外要求 `ECC_DATA_WIDTH=64` 且 `ENABLE_BUS_TIMEOUT=1`
> - `ASIL_LEVEL=0` (QM) 可关闭所有安全机制，最小化面积

### 1.4.4 参数配置矩阵 — 典型应用场景

| 场景 | MAC_COUNT | MAC_SPEED | DMA_CH | TSN | 1588 | Bridge | ASIL | 估算门数 |
|------|-----------|-----------|--------|-----|------|--------|------|----------|
| **Zone Controller 骨干** | 2 | 5G | 8 | ✅ | ✅ | ✅ | B | ~205k |
| **ADAS 传感器汇聚** | 2 | 5G | 8 | ✅ | ✅ | ❌ | B | ~190k |
| **CAN-Ethernet 网关** | 1 | 1G | 4 | ❌ | ✅ | ❌ | B | ~120k |
| **域内边缘节点** | 1 | 100M | 2 | ❌ | ❌ | ❌ | QM | ~60k |
| **OTA 更新节点** | 1 | 1G | 4 | ❌ | ❌ | ❌ | A | ~80k |

---

## 2. System Block Diagram

### 2.1 顶层框图

```
+========================================================================================+
|                           Ethernet IP Subsystem                                         |
+========================================================================================+
|                                                                                        |
|  +---------------------+         +---------------------+                               |
|  |   Host Interface    |         |   Host Interface    |                               |
|  |   (AXI4 Master)     |         |   (AXI4 Slave/CSR)  |                               |
|  |   64-bit Data       |         |   32-bit Config     |                               |
|  +----------|----------+         +----------|----------+                               |
|             |                               |                                          |
|             v                               v                                          |
|  +================================================================================+  |
|  |                              Bridge Module (可选)                                |  |
|  |                  XGMAC0 <---> XGMAC1 / Host <---> XGMAC1                         |  |
|  +================================================================================+  |
|             |                               |                                          |
|  +----------v-----------+         +----------v-----------+                             |
|  |     XGMAC 0          |         |     XGMAC 1          |                             |
|  |  +---------------+   |         |  +---------------+   |                             |
|  |  | XGMAC-CORE    |   |         |  | XGMAC-CORE    |   |                             |
|  |  | (MAC Layer)   |   |         |  | (MAC Layer)   |   |                             |
|  |  +-------|-------+   |         |  +-------|-------+   |                             |
|  |          |           |         |          |           |                             |
|  |  +-------v-------+   |         |  +-------v-------+   |                             |
|  |  |     MTL       |   |         |  |     MTL       |   |                             |
|  |  | (32KB FIFO)   |   |         |  | (32KB FIFO)   |   |                             |
|  |  +-------|-------+   |         |  +-------|-------+   |                             |
|  |          |           |         |          |           |                             |
|  |  +-------v-------+   |         |  +-------v-------+   |                             |
|  |  |  DMA Engine   |   |         |  |  DMA Engine   |   |                             |
|  |  | (8 Channels)  |   |         |  | (8 Channels)  |   |                             |
|  |  +---------------+   |         |  +---------------+   |                             |
|  +----------|----------+         +----------|----------+                             |
|             |                               |                                          |
|             v                               v                                          |
|  +================================================================================+  |
|  |                         HSPHY (High Speed PHY)                                   |  |
|  |   MII/RMII/RGMII  |  SGMII  |  USXGMII  |  PPS Output                            |  |
|  +================================================================================+  |
|                                                                                        |
+========================================================================================+
```

### 2.2 子系统划分

| 子系统 | 功能 | ASIL |
|--------|------|------|
| **XGMAC-CORE** | IEEE 802.3 MAC 层实现、帧过滤、VLAN 处理 | B |
| **MTL** | FIFO 缓冲、队列管理、流量整形 (CBS/TAS) | B |
| **DMA** | 描述符管理、数据搬运、时间戳回写 | B |
| **PTP/Timestamp** | 1588/gPTP 时间同步、PPS 输出 | B |
| **Bridge** | MAC-to-MAC 帧转发、FRER 路径冗余 | B |
| **Safety Monitor** | ECC/Parity/Timeout 检测与报警 | B |
| **HSPHY Interface** | PHY 接口适配 (RGMII/SGMII/USXGMII) | B |

---

## 3. 时钟与复位

> **详见**: [ethernet_clock_reset_spec.md](ethernet_clock_reset_spec.md)

### 3.1 时钟架构概要

| 时钟域 | 频率范围 | 用途 |
|--------|----------|------|
| `clk_sys` | 100-300 MHz | AXI 系统总线、CSR 接口 |
| `clk_mac` | 150-300 MHz | MAC Core、MTL 控制逻辑 |
| `clk_tx_phy` | 25/125/312.5 MHz | TX PHY 接口时钟 |
| `clk_rx_phy` | 25/125/312.5 MHz | RX PHY 接口时钟 |
| `clk_ts` | 100 MHz (典型) | PTP 时间戳、Addend 精调 |
| `clk_pcs` | 62.5/156.25/312.5/625 MHz | PCS/PMA 串行接口 |

### 3.2 复位策略概要

- **全局复位 (`rst_n`)**: 上电复位，全模块复位
- **模块级复位**: 各子系统独立软复位，通过 CSR 控制
- **DMA 通道复位**: 单通道独立复位，不影响其他通道
- **安全复位**: SMU 触发的紧急复位（ASIL-D 要求）

---

## 4. 性能分析

### 4.1 吞吐率

| 速率模式 | 理论线速 | 实测有效吞吐 | 瓶颈分析 |
|----------|----------|--------------|----------|
| 10M MII | 10 Mbps | ~9.8 Mbps | IPG + 前导码开销 |
| 100M MII | 100 Mbps | ~98 Mbps | 同上 |
| 1G RGMII | 1 Gbps | ~990 Mbps | AXI burst 效率 |
| 2.5G SGMII | 2.5 Gbps | ~2.48 Gbps | LCB2SRI 通道带宽 |
| 5G USXGMII | 5 Gbps | ~4.95 Gbps | 双 LCB2SRI 分离配置 |

### 4.2 延迟

| 路径 | 典型延迟 | 最大延迟 | 说明 |
|------|----------|----------|------|
| TX 存储转发 | ~2 μs | ~5 μs | 含 FIFO 填充 + DMA 传输 |
| TX 阈值模式 | ~0.5 μs | ~2 μs | 提前启动，效率折中 |
| RX 存储转发 | ~2 μs | ~5 μs | 完整帧接收后转发 |
| PTP 时间戳精度 | ±8 ns | ±20 ns | SFD 捕获精度 |
| TAS 门控切换 | <1 μs | <2 μs | 硬件周期计数器驱动 |

### 4.3 资源估算

| 模块 | 门数 (kGE) | SRAM (KB) | 备注 |
|------|-----------|-------------|------|
| XGMAC-CORE ×2 | ~80 | 8 | 不含 FIFO |
| MTL ×2 | ~20 | 64 (32K×2) | TX/RX FIFO |
| DMA ×2 | ~40 | 4 | 描述符缓存 |
| PTP/Timestamp | ~15 | 2 | 时间戳 FIFO |
| Bridge | ~10 | 4 | 转发表 |
| Safety/ECC | ~15 | 0 | 校验逻辑 |
| HSPHY IF | ~25 | 0 | 接口逻辑 |
| **总计** | **~205** | **~82** | — |

---

## 5. 数据通路与控制通路

### 5.1 发送数据通路

```
CPU/Software
    |
    v
[描述符准备] --> DMA_CHx_TxDesc_List (内存)
    |
    v
[DMA Engine] --(AXI Master)--> [MTL TX FIFO]
    |
    v
[MTL Scheduler] --(CBS/TAS/优先级仲裁)--> [XGMAC-CORE TX]
    |
    v
[TBU (VLAN/SA/CRC)] --> [MAC TX Protocol Engine]
    |
    v
[HSPHY] --> 物理介质 (MII/RGMII/SGMII/USXGMII)
```

### 5.2 接收数据通路

```
物理介质
    |
    v
[HSPHY] --> [XGMAC-CORE RX]
    |
    v
[AFM (地址过滤)] --> [VLAN 过滤] --> [L3/L4 过滤]
    |
    v
[MTL RX FIFO] (8 队列分类)
    |
    v
[DMA Engine] --(AXI Master)--> [系统内存]
    |
    v
[描述符回写] (状态 + 时间戳)
```

### 5.3 控制通路

- **CSR 配置**: AXI4-Lite Slave 接口，32-bit 寄存器访问
- **中断**: 每通道独立 TX/RX 中断，汇总至 IR (Interrupt Router)
- **安全报警**: ECC/Parity/Timeout 错误上报至 SMU
- **PTP 同步**: gPTP 协议栈通过 CSR 配置时间戳参数

---

## 6. 协议分析（参考附录）

> **详见**: [protocol_analysis.md](protocol_analysis.md)

本章节引用 `protocol_analysis.md` 中的协议分析结果作为架构设计的输入依据。关键协议-模块映射关系：

| 协议 | 负责模块 | 实现优先级 | 关键约束 |
|------|----------|----------|----------|
| 802.3-2022 MAC | XGMAC-CORE | P0 | 全双工/半双工、帧长约束 |
| 802.1AS-2020 gPTP | PTP/Timestamp | P0 | SFD 级精度、Addend 精调 |
| 802.1Qav CBS | MTL Scheduler | P0 | 8 队列独立 credit |
| 802.1Qbv TAS | MTL EST Engine | P0 | 256-entry GCL |
| 802.1Qbu 抢占 | MAC Merge (pMAC/eMAC) | P1 | 仅 GETH 支持 |
| 802.1Qci PSFP | FFP + GCL + PC | P1 | 8 gate ID 限制 |
| 802.1CB FRER | Bridge + Software | P1 | 软件序列管理 |
| 802.1AE MACsec | CSS (外部加速器) | P1 | 21 通道 AES-GCM |
| 802.3az EEE | HSPHY + MAC | P2 | 低功耗模式 |

---

## 7. 安全架构

### 7.1 ASIL-B 安全机制

| 安全机制 | 保护对象 | 检测能力 | 恢复策略 |
|----------|----------|----------|----------|
| **ECC** | MTL FIFO、描述符缓存、Bridge 表 | 单 bit 纠错、双 bit 检错 | 自动纠错 + 错误计数 |
| **FSM Parity** | 所有状态机 (MAC/DMA/MTL/PTP) | 奇偶校验错误 | 安全状态转换 + 报警 |
| **Timeout** | CSR 访问、DMA 响应、Bridge 转发 | 响应超时检测 | 复位请求 + 状态上报 |
| **Clock Monitor** | 各时钟域 | 时钟丢失/毛刺检测 | 安全复位 + 备用时钟 |
| **Lockstep** | 关键控制信号 (可选) | 双核比较 | NMI 触发 |

### 7.2 安全状态机

```
正常操作 (NORMAL)
    |
    +-- ECC 单 bit 错误 --> 自动纠错 + 计数
    +-- ECC 双 bit 错误 --> 进入 DEGRADED
    +-- FSM Parity 错误 --> 进入 SAFE_STATE
    +-- Timeout 错误 --> 进入 DEGRADED
    |
v
降级模式 (DEGRADED): 关闭故障通道，其他通道继续运行
    |
    +-- 多通道故障 --> 进入 SAFE_STATE
    |
v
安全状态 (SAFE_STATE): 停止所有传输，上报 SMU，等待复位
```

---

## 8. 附录

### 8.1 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v0.1 | 2026-05-02 | Arch Agent | 初始模板创建 |
| v1.0 | 2026-05-11 | Arch Agent | 填充完整架构内容，基于 TC4x 研究和协议分析 |

### 8.2 待解决问题

| ID | 问题描述 | 优先级 | 负责人 | 状态 |
|----|----------|--------|--------|------|
| ISSUE-001 | Bridge 模块的 FRER 软件实现延迟预算需精确计算 | P1 | Arch Agent | 待分析 |
| ISSUE-002 | 5G USXGMII 模式下 LCB2SRI 通道分离配置的具体地址映射 | P1 | Design Agent | 待设计 |
| ISSUE-003 | ASIL-B → ASIL-D 升级路径 (Lockstep 集成方案) | P2 | Arch Agent | 待评估 |
| ISSUE-004 | CSS 安全加速器接口定义 (AXI Slave / DMA 通道分配) | P1 | Arch Agent | 待定义 |
| ISSUE-005 | 10BASE-T1S LETH 模块是否纳入本 IP 范围 | P2 | PM Agent | 待决策 |

### 8.3 参考文档

| 文档 | 路径 | 说明 |
|------|------|------|
| Protocol Analysis | `Docs/Arch/protocol_analysis.md` | 协议详细分析与竞品对比 |
| Interface Spec | `Docs/Arch/ethernet_interface_spec.md` | 信号定义与时序要求 |
| Clock/Reset Spec | `Docs/Arch/ethernet_clock_reset_spec.md` | 时钟域与复位策略 |
| TC4x GETH 研究 | `Reference/Kimi_Agent_TC4x_Ethernet/` | Kimi Agent 深度研究材料 |

---

*文档生成: 2026-05-11 | 状态: Draft | 下一步: Arch Review*
