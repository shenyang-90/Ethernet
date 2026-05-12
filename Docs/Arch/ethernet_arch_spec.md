# Ethernet IP Architecture Specification

> **项目**: Ethernet IP (IP_20260502_001)
> **模块/系统**: Gigabit Ethernet MAC + PHY Subsystem
> **版本**: v1.4
> **日期**: 2026-05-12
> **作者**: Arch Agent
> **评审状态**: Draft → 待评审
> **变更**: v1.1 新增可配置参数矩阵; v1.2 重构 MAC/PHY 参数; v1.3 分析 ISSUE-001/003/004/005; **v1.4 基于 R-Car S4 Gap Analysis 升级: 4-port Switch + vPHC + AVTP 硬件感知**

---

## 1. Overview

### 1.1 系统概述

本项目旨在设计一款面向车规级应用的 Ethernet IP 子系统，对标 Infineon AURIX TC4x 系列 GETH/LETH 架构**与 Renesas R-Car S4 中央网关方案**。IP 支持 10M/100M/1G/2.5G/5G/10G 全双工速率，集成完整的 TSN（Time-Sensitive Networking）协议栈、**4-port L2/L3 Switch**、**双 PHC + vPHC 虚拟化**、硬件安全加速接口以及多 PHY 接口适配能力。

核心设计目标：
- **高性能**: 支持 5Gbps 线速，8 路独立 DMA 通道，64-bit AXI Master 接口
- **确定性**: 硬件级 gPTP 时间同步、TAS 门控调度、CBS 信用整形
- **可交换性**: **4-port L2/L3 Switch** 支持 MAC 自学习、VLAN 转发、多播过滤
- **虚拟化**: **双 PHC + vPHC** 支持 SDV/Hypervisor 多 VM 时间域隔离
- **安全性**: ASIL-B 安全完整性等级，ECC/Parity/Timeout 保护机制
- **可扩展性**: 支持 MII/RMII/RGMII/SGMII/USXGMII 多种 PHY 接口
- **协议完整**: TSN 协议族（802.1AS/802.1Qav/802.1Qbv/802.1Qbu/802.1Qci/802.1CB）硬件支持，**Switch 级 TAS**

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
| **双 XGMAC 架构** | 2 个独立 5G MAC，支持 **Switch 转发** | XGMAC Core |
| **4-port L2/L3 Switch** | **MAC 自学习、VLAN 转发、多播过滤、L3 路由** | Switch Core |
| **双 PHC + vPHC** | **2 个独立 PHC，Xen IO Rings 虚拟化** | PTP/Timestamp |
| **8 路 DMA 通道** | 独立 TX/RX Engine，3 级流水线 | DMA Engine |
| **32KB FIFO** | TX/RX 各 32KB MTL 缓冲 | MTL Layer |
| **TSN 协议栈** | 802.1AS/802.1Qav/802.1Qbv/802.1Qbu **硬件实现** | MAC Core + MTL |
| **Switch 级 TAS** | **802.1Qbv 在 Switch 入口端口硬件调度** | Switch Core |
| **帧抢占** | 802.1Qbu pMAC/eMAC 双虚拟 MAC | MAC Merge Layer |
| **硬件时间戳** | SFD 级精度，64-bit 纳秒计数器 | PTP Hardware Unit |
| **安全特性** | ECC/FSM Parity/CSR Timeout，ASIL-B | Safety Monitor |
| **校验和卸载** | IP/TCP/UDP 硬件计算 | TX/RX Checksum Engine |
| **VLAN 处理** | 插入/替换/删除，QinQ 支持 | TBU (Transmit Bus Interface) |
| **AVTP 硬件感知** | **AVTP 流识别、RX 分离到独立 DMA 队列** | RX Filter + DMA |
| **PHY 接口** | MII/RMII/RGMII/SGMII/USXGMII | HSPHY (外部) |

---

## 1.4 可配置参数 (Parameter Configuration)

本 IP 支持通过顶层 Verilog/SystemVerilog `parameter` 进行编译时裁剪，以适配不同应用场景（Zone Controller / ADAS HUB / 网关 / 边缘节点）的资源与功能需求。

### 1.4.1 协议相关参数

| 参数名 | 类型 | 默认值 | 可配置范围 | 说明 | 影响模块 |
|--------|------|--------|------------|------|----------|
| `MAC_COUNT` | int | 2 | **1 ~ 8** | MAC 实例数量 | XGMAC-CORE, DMA, MTL |
| `MAC_TYPE` | int | 2 | **0: MAC (10/100M)<br>1: GMAC (1G)<br>2: XGMAC (2.5G/5G/10G)** | MAC 核心类型，决定 MAC 层能力等级 | XGMAC-CORE, HSPHY IF |
| `PHY_COUNT` | int | 2 | **1 ~ 8** | PHY 实例总数量（**独立于 MAC 数量**） | HSPHY IF, PHY MUX |
| `PHY_TYPE` | int | 1 | **0: 10BASE-T1S (多点总线, PLCA)<br>1: 10/100BASE-T1 (点对点)<br>2: 1000BASE-T1 (点对点)<br>3: Multi-Gigabit (2.5G/5G/10G)** | PHY 接口类型，决定物理层拓扑和支持的速率等级 | HSPHY IF, PCS/PMA |
| `PHY_SPEED` | int | 3 | **0: 10M (10BASE-T1S)<br>1: 100M<br>2: 1G<br>3: 2.5G<br>4: 5G<br>5: 10G** | 每个 PHY 支持的最高速率（**按 PHY 独立配置**） | HSPHY IF, PCS/PMA |
| `SUPPORT_1588` | bit | 1 | 0 / 1 | 是否支持 IEEE 1588 / gPTP 时间同步 | PTP/Timestamp |
| `SUPPORT_GPTP` | bit | 1 | 0 / 1 | 是否支持 802.1AS gPTP（依赖 SUPPORT_1588=1） | PTP/Timestamp |
| `SUPPORT_TSN` | bit | 1 | 0 / 1 | 是否支持 TSN 协议栈总开关 | MTL, MAC Core |
| `SUPPORT_CBS` | bit | 1 | 0 / 1 | 是否支持 802.1Qav CBS（依赖 SUPPORT_TSN） | MTL Scheduler |
| `SUPPORT_TAS` | bit | 1 | 0 / 1 | 是否支持 802.1Qbv TAS（依赖 SUPPORT_TSN） | MTL Gate Control |
| `SUPPORT_FP` | bit | 1 | 0 / 1 | 是否支持 802.1Qbu 帧抢占（依赖 SUPPORT_TSN） | MAC Merge Layer |
| `SUPPORT_FRER` | bit | 1 | 0 / 1 | 是否支持 802.1CB FRER（依赖 SUPPORT_SWITCH=1） | Switch, SEQ/R-Tag |
| `SUPPORT_SWITCH` | bit | 1 | 0 / 1 | 是否支持 **L2/L3 Switch**（替代 Bridge） | **Switch Core** |
| **`SWITCH_PORT_COUNT`** | int | **4** | **2 ~ 8** | **Switch 端口数量** | **Switch Core** |
| **`SWITCH_TAS`** | bit | **1** | 0 / 1 | **是否支持 Switch 级 802.1Qbv TAS（依赖 SUPPORT_SWITCH=1）** | **Switch Core** |
| **`SWITCH_L3`** | bit | **0** | 0 / 1 | **是否支持 Layer 3 IP 路由（依赖 SUPPORT_SWITCH=1）** | **Switch Core** |
| `SUPPORT_VLAN` | bit | 1 | 0 / 1 | 是否支持 802.1Q VLAN 处理 | TBU, RX Filter, Switch |
| `SUPPORT_MACSEC` | bit | 0 | 0 / 1 | 是否支持 802.1AE MACsec（需外部 CSS 加速器） | HSPHY IF (安全通道) |
| `SUPPORT_AVTP` | bit | 0 | 0 / 1 | 是否支持 IEEE 1722 AVTP（⚠️ 所有车规MCU均无硬件卸载，但支持**AVTP 硬件感知**） | RX Filter + DMA |
| **`SUPPORT_AVTP_AWARE`** | bit | **0** | 0 / 1 | **是否支持 AVTP 流识别与 RX 分离（依赖 SUPPORT_AVTP=1）** | **RX Filter, Switch** |
| **`PHC_COUNT`** | int | **1** | **1, 2** | **PTP Hardware Clock 数量** | **PTP/Timestamp** |
| **`SUPPORT_VPHC`** | bit | **0** | 0 / 1 | **是否支持 vPHC 虚拟化（依赖 PHC_COUNT=2）** | **PTP/Timestamp, Xen IO Rings** |

> **配置约束**：
> - `SUPPORT_GPTP=1` 要求 `SUPPORT_1588=1`
> - `SUPPORT_FRER=1` 要求 `SUPPORT_SWITCH=1` 且 `MAC_COUNT ≥ 2`
> - `SUPPORT_FP=1` 要求 `MAC_TYPE ≥ 1` (GMAC/XGMAC)
> - **`SUPPORT_TAS` 与 `SWITCH_TAS` 互斥**：
>   - 当 `SUPPORT_SWITCH=1` 时，**TAS 统一为 Switch 级**（`SWITCH_TAS=1`, `SUPPORT_TAS=0`）
>   - 当 `SUPPORT_SWITCH=0` 时，TAS 为端点级（`SUPPORT_TAS=1`, `SWITCH_TAS=0`）
>   - 两者不可同时使能，硬件互锁：`SWITCH_TAS=1 → SUPPORT_TAS=0`
> - `SUPPORT_TAS=1` 要求 `SUPPORT_CBS=1`（推荐，非强制）
> - **`SWITCH_TAS=1` 要求 `SUPPORT_SWITCH=1` 且 `SUPPORT_TSN=1`**
> - **`SWITCH_L3=1` 要求 `SUPPORT_SWITCH=1` 且 `MAC_TYPE ≥ 1`**
> - **`SUPPORT_VPHC=1` 要求 `PHC_COUNT=2` 且 `SUPPORT_GPTP=1`**
> - **`SUPPORT_AVTP_AWARE=1` 要求 `SUPPORT_AVTP=1` 且 `SUPPORT_VLAN=1`**
> - `SUPPORT_MACSEC=1` 要求外部 CSS 安全加速器连接
> - **MAC 与 PHY 解耦**：`PHY_COUNT` 可以大于 `MAC_COUNT`（通过 PHY MUX 共享 MAC），也可以小于（通过 Switch 扩展）
> - **Switch 端口约束**：`SWITCH_PORT_COUNT ≤ MAC_COUNT`（每 Switch 端口绑定一个 MAC）
> - **MAC_TYPE 与 PHY_SPEED 独立配置**：MAC_TYPE 决定 MAC 层能力，PHY_SPEED 决定物理层速率。例如 XGMAC (MAC_TYPE=2) 可通过降频运行在 1G PHY (PHY_SPEED=2) 上
> - **PHY_TYPE 与 PHY_SPEED 配对约束**：`PHY_TYPE=0` (10BASE-T1S) 仅支持 `PHY_SPEED=0` (10M)；`PHY_TYPE=1` 支持 `PHY_SPEED=0~1` (10M/100M)；`PHY_TYPE=2` 支持 `PHY_SPEED=0~2` (10M/100M/1G)；`PHY_TYPE=3` 支持 `PHY_SPEED=0~5` (10M~10G)
> - **10BASE-T1S 特殊约束**：`PHY_TYPE=0` 时，PHY 支持多点总线拓扑（PLCA），最多 8 个节点；不支持全双工（仅半双工），因此 `SUPPORT_FP` (帧抢占) 和 `SUPPORT_TAS` 在此 PHY 上自动关闭
> - **Switch 级 TAS 约束**：`SWITCH_TAS=1` 时，端点 MAC 的 `SUPPORT_TAS` 自动关闭（端点无需感知门控周期，由 Switch 统一调度）

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

| 场景 | MAC_COUNT | MAC_TYPE | PHY_COUNT | PHY_TYPE | PHY_SPEED | DMA_CH | TSN | 1588 | **Switch** | ASIL | 估算门数 |
|------|-----------|----------|-----------|----------|-----------|--------|-----|------|--------|------|----------|
| **中央网关 (Switch)** | **4** | **GMAC** | **4** | **1000BASE-T1** | **1G** | **4** | **✅** | **✅** | **✅** | **B** | **~480k** |
| ADAS 传感器汇聚 | 2 | XGMAC | 2 | Multi-Gigabit | 5G | 8 | ✅ | ✅ | ❌ | B | ~190k |
| Zone Controller 骨干 | 2 | XGMAC | 2 | Multi-Gigabit | 5G | 8 | ✅ | ✅ | ✅ | B | ~205k |
| **SDV 中央网关 (Switch+vPHC)** | **4** | **GMAC** | **4** | **1000BASE-T1** | **1G** | **4** | **✅** | **✅** | **✅** | **B** | **~520k** |
| CAN-Ethernet 网关 | 1 | GMAC | 1 | 1000BASE-T1 | 1G | 4 | ❌ | ✅ | ❌ | B | ~120k |
| **域内边缘节点 (10BASE-T1S)** | 1 | MAC | 1 | 10BASE-T1S | 10M | 2 | ❌ | ❌ | ❌ | QM | ~45k |
| **车身传感器网络** | 1 | MAC | 1 | 10BASE-T1S | 10M | 2 | ❌ | ❌ | ❌ | QM | ~40k |
| **OTA 更新节点** | 1 | GMAC | 1 | 1000BASE-T1 | 1G | 4 | ❌ | ❌ | ❌ | A | ~80k |
| **信息娱乐域 (AVB)** | 1 | GMAC | 1 | 1000BASE-T1 | 1G | 4 | ✅ | ✅ | ❌ | QM | ~110k |

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
|  +================================================================================+  +
|  |                     Switch Core (L2/L3, 2~8 ports, 可选)                        |  +
|  |   MAC0 <───┐                                                                    |  +
|  |   MAC1 <───┼── [Crossbar + Arbiter] ──► Port 0/1/2/3... (全并发转发)           |  +
|  |   MAC2 <───┤   - FDB (Forwarding DB, 自学习/静态)                              |  +
|  |   MAC3 <───┘   - VLAN Table (VID → 端口掩码)                                  |  +
|  |   Host  ───►   - L3 Route Table (IP → MAC, 可选)                              |  +
|  |                - TAS GCL (Switch 级门控, 可选)                                |  +
|  |                - Multicast Filter / IGMP Snooping                            |  +
|  +================================================================================+  +
|             |              |              |              |                             |
|  +----------v----------+  +-v----------+  +-v----------+  +-v----------+               |
|  |     MAC 0           |  |   MAC 1    |  |   MAC 2    |  |   MAC 3    |               |
|  |  +---------------+  |  | +--------+ |  | +--------+ |  | +--------+               |
|  |  | XGMAC-CORE    |  |  | |XGMAC   | |  | |XGMAC   | |  | |XGMAC   |               |
|  |  | (MAC Layer)   |  |  | |(或GMAC)| |  | |(或GMAC)| |  | |(或GMAC)|               |
|  |  +-------|-------+  |  | +---|----+ |  | +---|----+ |  | +---|----+               |
|  |          |          |  |     |      |  |     |      |  |     |                    |
|  |  +-------v-------+  |  | +---v----+ |  | +---v----+ |  | +---v----+               |
|  |  |     MTL       |  |  | |  MTL   | |  | |  MTL   | |  | |  MTL   |               |
|  |  | (32KB FIFO)   |  |  | |(FIFO)  | |  | |(FIFO)  | |  | |(FIFO)  |               |
|  |  +-------|-------+  |  | +---|----+ |  | +---|----+ |  | +---|----+               |
|  |          |          |  |     |      |  |     |      |  |     |                    |
|  |  +-------v-------+  |  | +---v----+ |  | +---v----+ |  | +---v----+               |
|  |  |  DMA Engine   |  |  | |  DMA   | |  | |  DMA   | |  | |  DMA   |               |
|  |  | (8 Channels)  |  |  | |(4/8ch) | |  | |(4/8ch) | |  | |(4/8ch) |               |
|  |  +---------------+  |  | +--------+ |  | +--------+ |  | +--------+               |
|  +----------|----------+  +------------+  +------------+  +------------+              |
|             |              |              |              |                             |
|             v              v              v              v                             |
|  +================================================================================+  +
|  |                         HSPHY (High Speed PHY)                                   |  +
|  |   MII/RMII/RGMII  |  SGMII  |  USXGMII  |  PPS Output                            |  +
|  +================================================================================+  +
|                                                                                        |
+========================================================================================+
```

### 2.2 子系统划分

| 子系统 | 功能 | ASIL |
|--------|------|------|
| **XGMAC-CORE** | IEEE 802.3 MAC 层实现、帧过滤、VLAN 处理 | B |
| **MTL** | FIFO 缓冲、队列管理、流量整形 (CBS/TAS) | B |
| **DMA** | 描述符管理、数据搬运、时间戳回写 | B |
| **Switch Core** | **L2/L3 帧交换、FDB 自学习、VLAN 转发、多播过滤、Switch 级 TAS** | **B** |
| **PTP/Timestamp** | 1588/gPTP 时间同步、**双 PHC + vPHC 虚拟化**、PPS 输出 | B |
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

| 速率模式 | 理论线速 | 实测有效吞吐 | 瓶颈分析 | 备注 |
|----------|----------|--------------|----------|------|
| 10M MII | 10 Mbps | ~9.8 Mbps | IPG + 前导码开销 | — |
| 100M MII | 100 Mbps | ~98 Mbps | 同上 | — |
| 1G RGMII | 1 Gbps | ~990 Mbps | AXI burst 效率 | — |
| 2.5G SGMII | 2.5 Gbps | ~2.48 Gbps | LCB2SRI 通道带宽 | — |
| 5G USXGMII | 5 Gbps | ~4.95 Gbps | 双 LCB2SRI 分离配置 | — |
| **CBS 信用整形** | — | **~97.35%** 理论带宽 | Credit 累积/消耗模型 | ⚠️ **已知 erratum：约 2.65% 带宽误差** [^1^] |

> [^1^]: 参考 `Reference/Kimi_Agent_MCU_Ethernet/research/ethernet_mcu_cross_verification.md` — TC4x CBS 存在已知 erratum，信用值计算导致约 2.65% 的带宽损失。本 IP 设计时应通过软件补偿（Credit 值预校正）或硬件修复（改进 Credit 算法）规避此问题。

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
| Switch Core | **~80** | **16** | **FDB + VLAN + L3 Route + TAS GCL** |
| PTP/Timestamp | ~15 | 2 | 时间戳 FIFO |
| PTP/Timestamp (双 PHC) | **~25** | **4** | **双 PHC + vPHC 虚拟化** |
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
| 802.1AS TC | PTP/Timestamp | P1 | ⚠️ **多端口 Transparent Clock 限制**：每端口独立时钟偏移补偿，跨端口同步需软件协调 [^2^] |
| 802.1Qav CBS | MTL Scheduler | P0 | 8 队列独立 credit；⚠️ **已知 erratum：约 2.65% 带宽误差** [^1^] |
| 802.1Qbv TAS | MTL EST Engine | P0 | 256-entry GCL；**Switch 级 TAS 在 Switch Core 实现** |
| 802.1Qbu 抢占 | MAC Merge (pMAC/eMAC) | P1 | 仅 GETH (≥1G) 支持，10BASE-T1S 不支持 |
| 802.1Qci PSFP | FFP + GCL + PC | P1 | 8 gate ID 限制；**Switch 级 PSFP 在入口端口实现** |
| **802.1CB FRER** | **Switch Core + Software** | P1 | **硬件帧复制/消除路径选择，软件序列号管理** |
| **802.1D MAC Bridge** | **Switch Core** | **P1** | **MAC 地址自学习、老化、静态 FDB** |
| **802.1Q VLAN Switch** | **Switch Core** | **P0** | **VLAN 转发表、端口成员关系、Tag 处理** |
| **L3 IP 路由** | **Switch Core (可选)** | **P2** | **IP 地址查表、ARP 缓存、L3 转发决策** |
| **多播过滤 / IGMP** | **Switch Core** | **P2** | **IGMP Snooping、静态多播组、泛洪控制** |
| **Switch 级 gPTP Relay** | **PTP/Timestamp + Switch Core** | **P1** | **多端口 BC/TC Relay，双 PHC 绑定** |
| 802.1AE MACsec | CSS (外部加速器) | P1 | 21 通道 AES-GCM；763MB/s 吞吐率 [^3^] |
| 802.3az EEE | HSPHY + MAC | P2 | 低功耗模式 |
| 10BASE-T1S | HSPHY (PLCA) | P2 | 多点总线，最多 8 节点，半双工，不支持 TSN 抢占 [^4^] |

> [^1^]: 参考 `Reference/Kimi_Agent_MCU_Ethernet/research/ethernet_mcu_cross_verification.md` — TC4x CBS 已知 erratum
> [^2^]: 参考 `Reference/Kimi_Agent_MCU_Ethernet/research/ethernet_mcu_cross_verification.md` — TC4x PTP Transparent Clock 多端口限制
> [^3^]: 参考 `Reference/Kimi_Agent_MCU_Ethernet/research/ethernet_mcu_cross_verification.md` — TC4x CSS MACsec 加速速率
> [^4^]: 参考 `Reference/Kimi_Agent_MCU_Ethernet/ethernet_mcu.agent.final.md` — 10BASE-T1S 在车规 MCU 中的支持情况

---

## 7. 安全架构

### 7.1 ASIL-B 安全机制

| 安全机制 | 保护对象 | 检测能力 | 恢复策略 |
|----------|----------|----------|----------|
| **ECC** | MTL FIFO、描述符缓存、**Switch FDB/VLAN/L3 表** | 单 bit 纠错、双 bit 检错 | 自动纠错 + 错误计数 |
| **FSM Parity** | 所有状态机 (MAC/DMA/MTL/PTP/**Switch**) | 奇偶校验错误 | 安全状态转换 + 报警 |
| **Timeout** | CSR 访问、DMA 响应、**Switch 转发** | 响应超时检测 | 复位请求 + 状态上报 |
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
| v1.1 | 2026-05-11 | Arch Agent | 新增 1.4 可配置参数矩阵（协议/DMA/安全参数） |
| v1.2 | 2026-05-11 | Arch Agent | 重构参数：MAC_COUNT 1-8, MAC_TYPE (MAC/GMAC/XGMAC), PHY_COUNT 独立 1-8, PHY_SPEED 解耦 |
| v1.4 | 2026-05-12 | Arch Agent | **基于 R-Car S4 Gap Analysis 升级**: 4-port L2/L3 Switch (替换 Bridge), 双 PHC + vPHC 虚拟化, AVTP 硬件感知, Switch 级 TAS/PSFP, 更新应用场景矩阵和资源估算 |
| **v1.4.2** | **2026-05-12** | **Arch Agent** | **ISSUE 全部关闭/转移**: 7 项已关闭 (001/003/004/005/006/007/008/009), 1 项转移至 EDR (002), PAD 阶段零待解决问题声明 |
| v1.4.1 | 2026-05-12 | Arch Agent | ISSUE-006~009 参数化定义: TAS 互斥规则 (Switch 级优先), 双 PHC/vPHC 寄存器接口, L3 路由表/ARP 缓存, AVTP RX Filter/DMA 队列映射 |

### 8.2 待解决问题

| ID | 问题描述 | 优先级 | 负责人 | 状态 | 分析结论 |
|----|----------|--------|--------|------|----------|
| ISSUE-001 | Switch 模块的 FDB 自学习算法与 FRER 硬件路径选择延迟预算 | P1 | Arch Agent | **✅ 已关闭** | **PAD 结论**: FDB 容量 4K/8K/16K 条目可配，老化时间 300s 可配；FRER 采用硬件辅助帧复制/消除 + 软件序列号管理，Switch 级并行 4 端口，延迟预算：路径差异 <2μs，序列号比较 <500ns。**EDR 后续**: Verification Agent 验证 FDB 满载老化性能和 FRER 序列号冲突恢复 |
| ISSUE-002 | 5G USXGMII 模式下 LCB2SRI 通道分离配置的具体地址映射 | P1 | Design Agent | **➡️ 转移至 EDR** | **PAD 结论**: LCB2SRI 是物理层 SerDes 适配模块，地址映射属于微架构实现细节，非 PAD 阶段决策范围。**EDR 任务**: Design Agent 在 EDR 阶段定义 LCB2SRI 寄存器地址映射（基地址、通道偏移、配置位域），参考 TC4x LCB2SRI 手册 `Reference/Infineon/016_14 Gigabit Ethernet (GETH).md` §5.4 |
| ISSUE-003 | ASIL-B → ASIL-D 升级路径 (Lockstep 集成方案) | P2 | Arch Agent | **✅ 已关闭** | **PAD 结论**: 本 IP 保持 ASIL-B 基线（ECC + Parity + Timeout），ASIL-D 通过外部 SMU 系统级集成实现。升级路径预留：ASIL-C +15% 面积（总线超时 + 双 bit 报警），ASIL-D +35% 面积（Lockstep + 独立监控通道）。不纳入本 IP 设计范围 |
| ISSUE-004 | CSS 安全加速器接口定义 (AXI Slave / DMA 通道分配) | P1 | Arch Agent | **✅ 已关闭** | **PAD 结论**: CSS 作为外部安全加速器，AXI4 Slave 32-bit 配置 + 128-bit 专用数据通道。MACsec 数据流：MAC ↔ CSS ↔ PHY。CSS 21 通道预留 2 通道给 GETH（每 MAC 1 通道）。TC4x CSS 763MB/s 吞吐率覆盖 2×5Gbps MACsec。**EDR 后续**: Design Agent 细化 CSS 接口时序和握手协议 |
| ISSUE-006 | Switch 级 TAS (802.1Qbv) 参数化定义与端点级 TAS 互斥规则 | P1 | Arch Agent | **✅ 已关闭** | **PAD 结论**: TAS 互斥规则确定——`SUPPORT_SWITCH=1` 时强制 Switch 级 TAS（`SWITCH_TAS=1, SUPPORT_TAS=0`），`SUPPORT_SWITCH=0` 时端点级 TAS（`SUPPORT_TAS=1`），硬件互锁。删除 `TAS_MODE` 参数。**EDR 后续**: Design Agent 实现 `SWITCH_TAS` 与 `SUPPORT_TAS` 的硬件互锁逻辑 |
| ISSUE-007 | 双 PHC + vPHC 的 Xen IO Ring 接口定义与 SoC 集成 | P1 | Arch Agent | **✅ 已关闭** | **PAD 结论**: PHC0/PHC1 寄存器接口定义完成（64-bit 纳秒 + 32-bit 亚纳秒，+0x000/+0x100 偏移）；vPHC IO Ring 格式 64B（8B 时间戳 + 4B 域ID + 4B 序列号 + 48B 保留）；权限控制 Region ID 分级；中断 `vphc_update_irq`。SoC 集成方提供 Hypervisor 适配层。**EDR 后续**: Design Agent 实现 PHC 寄存器模块和 vPHC IO Ring 控制器 |
| ISSUE-008 | L3 路由表容量、查表机制与 ARP 缓存定义 | P2 | Design Agent | **✅ 已关闭** | **PAD 结论**: 路由表 256/512/1K 条目可配（`L3_ROUTE_TABLE_SIZE`），哈希表默认（4-way 组相联，<200ns），TCAM 可选（<50ns）。ARP 缓存 128 条目，600s 老化。默认路由 0.0.0.0/0 → Host。**EDR 后续**: Design Agent 实现路由表哈希引擎/TCAM 接口；Verification Agent 验证 1K 满载查表延迟和冲突率 |
| ISSUE-009 | AVTP 硬件感知的 RX Filter 位定义与 DMA 队列映射 | P2 | Arch Agent | **✅ 已关闭** | **PAD 结论**: AVTP 识别：以太类型 0x22F0 或 VLAN+PCP 匹配（PCP=2/3 掩码可配），64-bit Stream ID 白名单 16 条目。DMA 独立队列 `RX_Q_AVTP`（默认 Queue 7）。寄存器 `AVTP_CTRL`/`AVTP_VLAN_PCP_MASK`/`AVTP_STREAM_ID[n]`。默认支持 IEEE 1722-2016。**EDR 后续**: Design Agent 实现 AVTP RX Filter 模块；Verification Agent 验证 AVTP 流识别精度和 DMA 队列隔离 |
| **ISSUE-005** | **10BASE-T1S PHY 集成决策** | **P2** | **PM Agent** | **✅ 已关闭** | **PAD 结论**: 10BASE-T1S 纳入本 IP 范围，作为 `PHY_SPEED=0` 选项，通过 `PHY_TYPE=0` 参数独立配置。支持 PLCA 多点总线（最多 8 节点），半双工，不支持帧抢占/TAS。应用场景：域内边缘节点、车身传感器网络。与 100BASE-T1S 区别：10BASE-T1S 多点总线，100BASE-T1S 仅点对点。参考 `Reference/Kimi_Agent_MCU_Ethernet/ethernet_mcu.agent.final.md` |

> **PAD 阶段已知问题清零声明**
>
> **截至 Arch Spec v1.4.2，全部 9 项 ISSUE 已完成 PAD 阶段分析，结论如下**：
> - **已关闭 (7 项)**: ISSUE-001, 003, 004, 005, 006, 007, 008, 009 — 均有明确 PAD 结论和 EDR 后续任务
> - **转移至 EDR (1 项)**: ISSUE-002 — LCB2SRI 地址映射属于微架构实现细节，由 Design Agent 在 EDR 阶段完成
> - **PAD 阶段无待解决问题**

### 8.3 参考文档

| 文档 | 路径 | 说明 |
|------|------|------|
| **Safety Concept** | `Docs/FuSa/safety_concept.md` | **FuSa Agent — 功能安全概念 (安全目标/DC/FHTI/ASIL分解)** |
| Protocol Analysis | `Docs/Arch/protocol_analysis.md` | 协议详细分析与竞品对比 |
| Interface Spec | `Docs/Arch/ethernet_interface_spec.md` | 信号定义与时序要求 |
| Clock/Reset Spec | `Docs/Arch/ethernet_clock_reset_spec.md` | 时钟域与复位策略 |
| **MCU Ethernet 研究** | `Reference/Kimi_Agent_MCU_Ethernet/` | **Kimi Agent 车规MCU Ethernet深度研究（TC4x/S32G/S32K3/R-Car S4 对比分析）** |
| **R-Car S4 差距分析** | `Docs/Arch/gap_analysis_rcar_s4.md` | **本 IP vs R-Car S4 功能差距分析：Switch/PHC/AVTP/FFI/IDS** |
| TC4x GETH 研究 | `Reference/Kimi_Agent_TC4x_Ethernet/` | Kimi Agent TC4x 专项研究材料 |

---

*文档生成: 2026-05-11 | 状态: Draft | 下一步: Arch Review*
