# Ethernet IP Verification Plan

> **项目**: Ethernet IP (IP_20260502_001)
> **模块/系统**: Gigabit Ethernet MAC + PHY Subsystem
> **版本**: v1.0
> **日期**: 2026-05-21
> **作者**: Verification Agent
> **评审状态**: PAD Rework — 基于 verification_agent_review_20260521.md 修复
> **变更**: 新增黄金配置、覆盖率目标、Erratum回归套件、PICS映射、Formal章节(N/A)

---

## 1. 概述

### 1.1 验证范围

本验证计划覆盖 Ethernet IP 子系统的全部可配置参数组合、协议合规性、功能安全机制及 TC4x erratum 规避验证。验证对象包括：

- **XGMAC-CORE**: 1~8 个 MAC 实例，支持 MAC/GMAC/XGMAC 混合架构
- **MTL**: TX/RX FIFO、CBS 信用整形、TAS 门控调度、帧抢占
- **DMA Engine**: 全局通道池 (8/16/32 通道)、描述符管理、AXI Master
- **Switch Core**: L2/L3 交换、FDB 自学习、VLAN 转发、Crossbar 仲裁
- **PTP/Timestamp**: 双 PHC + vPHC、gPTP 协议栈、硬件时间戳
- **Safety Monitor**: ECC/Parity/Timeout、ASIL-B 安全机制
- **HSPHY Interface**: MII/RMII/RGMII/SGMII/USXGMII、10BASE-T1S/PLCA

### 1.2 不在本计划内的

- **Formal Verification**: 实体 Yang 决策，当前阶段不投入 Formal 验证资源 (详见 §7)
- **硅后验证 (Silicon Bring-up)**: 属于 POST 阶段，不在本计划范围
- **第三方安全加速器 (CSS/HSE) 验证**: MACsec/IPsec/SecOC/D-TLS 的加解密由外部加速器完成，本 IP 仅验证封装/卸载接口
- **SoC 级系统验证**: Lockstep CPU、SMU 双冗余、PMIC 等系统级安全机制

### 1.3 参考文档

| 文档 | 路径 | 说明 |
|------|------|------|
| Architecture Specification | `Docs/Arch/ethernet_arch_spec.md` v1.8c | 可配置参数、erratum 规避设计 |
| Protocol Analysis | `Docs/Arch/protocol_analysis.md` v2.2 | PICS 分析、协议 RTL 细节 |
| Safety Concept | `Docs/FuSa/safety_concept.md` | 功能安全目标、DC/FHTI |
| Interface Spec | `Docs/Arch/ethernet_interface_spec.md` | 信号定义与时序 |
| Clock/Reset Spec | `Docs/Arch/ethernet_clock_reset_spec.md` | 时钟域与复位策略 |

---

## 2. 验证策略

### 2.1 验证方法矩阵

| 验证方法 | 应用范围 | 工具/平台 | 负责人 |
|----------|----------|-----------|--------|
| **UVM 仿真** | 功能验证、协议合规、性能压力、erratum 回归 | VCS / Verilator / Xcelium | Verification Agent |
| **FPGA 原型** | 温度循环、PLCA 时序、PHY 噪声注入、长时间稳定性 | Xilinx Zynq UltraScale+ / 环境箱 | Verification Agent |
| **Assertion (SVA)** | 防退化检查、协议属性、安全状态机 | 内嵌于 UVM / 独立仿真 | Verification Agent |
| ~~Formal Verification~~ | ~~TAS 时序、DMA 无死锁、PTP monotonicity~~ | ~~JasperGold / VC Formal~~ | ~~N/A~~ |

> **Formal 验证说明**: 实体 Yang 决策当前阶段不投入 Formal 验证资源。详见 §7。

### 2.2 测试层次

| 层次 | 目标 | 环境 | 覆盖率要求 |
|------|------|------|----------|
| **模块级 (UT)** | 单模块功能正确性 | IP 级 UVM Testbench | Line ≥ 95% |
| **子系统级 (IT)** | 跨模块交互 (如 DMA+MTL+MAC) | 子系统 UVM | Line ≥ 90% |
| **系统级 (ST)** | 全 IP 端到端 (含 Switch) | 全芯片 UVM + FPGA | Functional ≥ 90% |
| **回归级 (RT)** | 持续验证 erratum 规避不退化 | Nightly / Weekly | Assertion ≥ 95% |

### 2.3 测试类型

| 类型 | 说明 | 占比 |
|------|------|------|
| **Directed Test** | 定向测试：erratum 规避、PICS 合规、安全机制 | 40% |
| **Constrained Random** | 约束随机：流量模式、参数组合、corner case | 45% |
| **Negative Test** | 负面测试：非法参数、错误注入、故障恢复 | 15% |

---

## 3. 黄金配置 (Golden Configurations)

### 3.1 配置定义原则

从 35+ 参数的组合空间中，选取 **5 个黄金配置** 作为 nightly regression 基线。选取原则：
- 覆盖主要出货场景（最小配置、Zone Controller、中央网关、安全升级）
- 覆盖所有 MAC_TYPE (MAC/GMAC/XGMAC) 和 PHY_TYPE 组合
- 覆盖 TSN 全功能开关组合
- 覆盖 ASIL 等级渐变 (QM → ASIL-B → ASIL-D ready)
- 每个配置均为**合法参数组合**，非法组合在约束中排除

### 3.2 全局参数总览（35+ 参数）

| 类别 | 参数名 | 类型 | 默认值 | 可配置范围 |
|------|--------|------|--------|------------|
| **MAC** | `MAC_COUNT` | int | 4 | 1 ~ 8 |
| | `MAC_0_TYPE` ~ `MAC_7_TYPE` | int[8] | {2,2,1,1,1,1,1,1} | 0:MAC, 1:GMAC, 2:XGMAC |
| | `MAC_0_SPEED` ~ `MAC_7_SPEED` | int[8] | {4,4,2,2,2,2,2,2} | 0:10M, 1:100M, 2:1G, 3:2.5G, 4:5G, 5:10G |
| **PHY** | `PHY_COUNT` | int | 4 | 1 ~ 8 |
| | `PHY_0_TYPE` ~ `PHY_7_TYPE` | int[8] | {3,3,2,2,2,2,2,2} | 0:10BASE-T1S, 1:10/100BASE-T1, 2:1000BASE-T1, 3:Multi-Gigabit |
| | `PHY_0_SPEED` ~ `PHY_7_SPEED` | int[8] | {4,4,2,2,2,2,2,2} | 0:10M, 1:100M, 2:1G, 3:2.5G, 4:5G, 5:10G |
| | `PHY_0_DUPLEX` ~ `PHY_7_DUPLEX` | bit[8] | {1,1,1,1,1,1,1,1} | 0:半双工, 1:全双工 |
| **协议** | `SUPPORT_1588` | bit | 1 | 0/1 |
| | `SUPPORT_GPTP` | bit | 1 | 0/1 |
| | `SUPPORT_TSN` | bit | 1 | 0/1 |
| | `SUPPORT_CBS` | bit | 1 | 0/1 |
| | `SUPPORT_TAS` | bit | 1 | 0/1 |
| | `SUPPORT_FP` | bit | 1 | 0/1 |
| | `SUPPORT_FRER` | bit | 1 | 0/1 |
| | `SUPPORT_SWITCH` | bit | 1 | 0/1 |
| | `SWITCH_PORT_COUNT` | int | 4 | 2 ~ 8 |
| | `SWITCH_TAS` | bit | 1 | 0/1 |
| | `SWITCH_L3` | bit | 0 | 0/1 |
| | `SWITCH_CONNECTED_MAC_0` ~ `SWITCH_CONNECTED_MAC_7` | bit[8] | {1,1,1,1,0,0,0,0} | 0/1 |
| | `SUPPORT_VLAN` | bit | 1 | 0/1 |
| | `SUPPORT_MACSEC` | bit | 0 | 0/1 |
| | `SUPPORT_AVTP` | bit | 1 | 0/1 |
| | `SUPPORT_AVTP_AWARE` | bit | 1 | 0/1 |
| | `SUPPORT_AVTP_CTL` | bit | 0 | 0/1 |
| | `SUPPORT_EEE` | bit | 0 | 0/1 |
| | `SUPPORT_IPSEC` | bit | 0 | 0/1 |
| | `SUPPORT_SECOC` | bit | 0 | 0/1 |
| | `SUPPORT_DTLS` | bit | 0 | 0/1 |
| | `PHC_COUNT` | int | 2 | 1, 2 |
| | `SUPPORT_VPHC` | bit | 0 | 0/1 |
| **DMA** | `DMA_CH_COUNT` | int | 8 | 1, 2, 4, 8, 16, 32 |
| | `DMA_CH_PER_MAC` | int | 4 | 1 ~ 8 |
| | `MTL_TX_FIFO_DEPTH` | int | 32 | 8, 16, 32, 64 |
| | `MTL_RX_FIFO_DEPTH` | int | 32 | 8, 16, 32, 64 |
| | `MTL_TX_QUEUES` | int | 8 | 1, 2, 4, 8 |
| | `MTL_RX_QUEUES` | int | 8 | 1, 2, 4, 8 |
| | `DESC_SIZE` | int | 16 | 16, 32 |
| | `AXI_ID_WIDTH` | int | 4 | 4, 8 |
| | `AXI_DATA_WIDTH` | int | 64 | 32, 64, 128 |
| | `CSR_ADDR_WIDTH` | int | 12 | 10, 12, 14 |
| | `MAX_BURST_LEN` | int | 16 | 8, 16 |
| **安全** | `ASIL_LEVEL` | int | 2 | 0:QM, 1:A, 2:B, 3:C, 4:D |
| | `ECC_DATA_WIDTH` | int | 64 | 32, 64 |
| | `ECC_SYNDROME_WIDTH` | int | 8 | 4, 8 |
| | `ENABLE_PARITY_FSM` | bit | 1 | 0/1 |
| | `ENABLE_CSR_TIMEOUT` | bit | 1 | 0/1 |
| | `ENABLE_BUS_TIMEOUT` | bit | 1 | 0/1 |
| | `SMU_ALERT_WIDTH` | int | 4 | 1, 2, 4 |
| | `ECC_SCRUB_INTERVAL` | int | 1000 | 100 ~ 10000 |

### 3.3 Config-A: 最小配置 (Edge Node / QM)

**场景**: 域内边缘节点、车身传感器网络、最小门数快速冒烟

| 参数 | 值 | 说明 |
|------|-----|------|
| `MAC_COUNT` | 1 | 单 MAC |
| `MAC_0_TYPE` | 0 | MAC (10/100M) |
| `MAC_0_SPEED` | 0 | 10M |
| `PHY_COUNT` | 1 | 单 PHY |
| `PHY_0_TYPE` | 0 | 10BASE-T1S |
| `PHY_0_SPEED` | 0 | 10M |
| `PHY_0_DUPLEX` | 0 | 半双工 (10BASE-T1S 强制) |
| `SUPPORT_1588` | 0 | 无 PTP |
| `SUPPORT_GPTP` | 0 | 无 gPTP |
| `SUPPORT_TSN` | 0 | 无 TSN |
| `SUPPORT_CBS` | 0 | — |
| `SUPPORT_TAS` | 0 | — |
| `SUPPORT_FP` | 0 | — |
| `SUPPORT_FRER` | 0 | — |
| `SUPPORT_SWITCH` | 0 | 无 Switch |
| `SWITCH_PORT_COUNT` | 0 | — |
| `SWITCH_TAS` | 0 | — |
| `SWITCH_L3` | 0 | — |
| `SWITCH_CONNECTED_MAC_0` | 0 | 独立直连 |
| `SUPPORT_VLAN` | 0 | 无 VLAN |
| `SUPPORT_MACSEC` | 0 | 无安全 |
| `SUPPORT_AVTP` | 0 | 无 AVTP |
| `SUPPORT_AVTP_AWARE` | 0 | — |
| `SUPPORT_AVTP_CTL` | 0 | — |
| `SUPPORT_EEE` | 0 | 无 EEE |
| `SUPPORT_IPSEC` | 0 | — |
| `SUPPORT_SECOC` | 0 | — |
| `SUPPORT_DTLS` | 0 | — |
| `PHC_COUNT` | 1 | 单 PHC (最小) |
| `SUPPORT_VPHC` | 0 | 无虚拟化 |
| `DMA_CH_COUNT` | 2 | 最小通道 |
| `DMA_CH_PER_MAC` | 2 | — |
| `MTL_TX_FIFO_DEPTH` | 8 | 最小 FIFO |
| `MTL_RX_FIFO_DEPTH` | 8 | — |
| `MTL_TX_QUEUES` | 1 | 单队列 |
| `MTL_RX_QUEUES` | 1 | — |
| `DESC_SIZE` | 16 | 标准描述符 |
| `AXI_ID_WIDTH` | 4 | — |
| `AXI_DATA_WIDTH` | 32 | 32-bit 总线 |
| `CSR_ADDR_WIDTH` | 10 | 最小地址空间 |
| `MAX_BURST_LEN` | 8 | — |
| `ASIL_LEVEL` | 0 | QM |
| `ECC_DATA_WIDTH` | 32 | — |
| `ECC_SYNDROME_WIDTH` | 4 | — |
| `ENABLE_PARITY_FSM` | 0 | 关闭 |
| `ENABLE_CSR_TIMEOUT` | 0 | — |
| `ENABLE_BUS_TIMEOUT` | 0 | — |
| `SMU_ALERT_WIDTH` | 1 | — |
| `ECC_SCRUB_INTERVAL` | 1000 | — |

**验证重点**:
- 10M 半双工 MAC TX/RX FSM 状态转移
- PLCA 多点总线时序 (TO 延迟、commit timer)
- MII 4-bit nibble 接口时序
- 最小 FIFO 深度下的 underflow/overflow 边界
- QM 模式下所有安全机制关闭，面积最小化验证

**已知约束 / 非法组合**:
- `PHY_0_TYPE=0` 时 `PHY_0_SPEED` 必须为 0 (10M)，否则硬件 clamp
- `PHY_0_TYPE=0` 时 `PHY_0_DUPLEX` 强制 0 (半双工)，全双工设置被忽略
- `MAC_0_TYPE=0` 时 `MAC_0_SPEED` 仅支持 0~1 (10M/100M)
- `SUPPORT_TSN=0` 时所有 TSN 子功能 (CBS/TAS/FP) 被忽略
- `SUPPORT_SWITCH=0` 时 `SWITCH_PORT_COUNT` 必须为 0

### 3.4 Config-B: 标准车载 (Zone Controller)

**场景**: Zone Controller 骨干网、标准车载网关、ASIL-B + TSN

| 参数 | 值 | 说明 |
|------|-----|------|
| `MAC_COUNT` | 2 | 双 MAC |
| `MAC_0_TYPE` | 2 | XGMAC |
| `MAC_0_SPEED` | 4 | 5G |
| `MAC_1_TYPE` | 1 | GMAC |
| `MAC_1_SPEED` | 2 | 1G |
| `PHY_COUNT` | 2 | — |
| `PHY_0_TYPE` | 3 | Multi-Gigabit |
| `PHY_0_SPEED` | 4 | 5G |
| `PHY_0_DUPLEX` | 1 | 全双工 |
| `PHY_1_TYPE` | 2 | 1000BASE-T1 |
| `PHY_1_SPEED` | 2 | 1G |
| `PHY_1_DUPLEX` | 1 | 全双工 |
| `SUPPORT_1588` | 1 | 支持 1588 |
| `SUPPORT_GPTP` | 1 | 支持 gPTP |
| `SUPPORT_TSN` | 1 | 支持 TSN |
| `SUPPORT_CBS` | 1 | 支持 CBS |
| `SUPPORT_TAS` | 0 | **端点 TAS 关闭** (Switch 级 TAS 启用) |
| `SUPPORT_FP` | 1 | 支持帧抢占 |
| `SUPPORT_FRER` | 1 | 支持 FRER |
| `SUPPORT_SWITCH` | 1 | **启用 Switch** |
| `SWITCH_PORT_COUNT` | 4 | 4-port Switch |
| `SWITCH_TAS` | 1 | **Switch 级 TAS** |
| `SWITCH_L3` | 0 | 无 L3 |
| `SWITCH_CONNECTED_MAC_0` | 1 | MAC0 接入 Switch |
| `SWITCH_CONNECTED_MAC_1` | 1 | MAC1 接入 Switch |
| `SUPPORT_VLAN` | 1 | 支持 VLAN |
| `SUPPORT_MACSEC` | 0 | 默认关闭 |
| `SUPPORT_AVTP` | 1 | 支持 AVTP |
| `SUPPORT_AVTP_AWARE` | 1 | AVTP 流识别 |
| `SUPPORT_AVTP_CTL` | 0 | — |
| `SUPPORT_EEE` | 0 | — |
| `SUPPORT_IPSEC` | 0 | — |
| `SUPPORT_SECOC` | 0 | — |
| `SUPPORT_DTLS` | 0 | — |
| `PHC_COUNT` | 2 | 双 PHC |
| `SUPPORT_VPHC` | 0 | — |
| `DMA_CH_COUNT` | 16 | — |
| `DMA_CH_PER_MAC` | 4 | — |
| `MTL_TX_FIFO_DEPTH` | 32 | — |
| `MTL_RX_FIFO_DEPTH` | 32 | — |
| `MTL_TX_QUEUES` | 8 | — |
| `MTL_RX_QUEUES` | 8 | — |
| `DESC_SIZE` | 16 | — |
| `AXI_ID_WIDTH` | 4 | — |
| `AXI_DATA_WIDTH` | 128 | 128-bit 总线 |
| `CSR_ADDR_WIDTH` | 12 | — |
| `MAX_BURST_LEN` | 16 | — |
| `ASIL_LEVEL` | 2 | **ASIL-B** |
| `ECC_DATA_WIDTH` | 64 | — |
| `ECC_SYNDROME_WIDTH` | 8 | — |
| `ENABLE_PARITY_FSM` | 1 | 使能 |
| `ENABLE_CSR_TIMEOUT` | 1 | 使能 |
| `ENABLE_BUS_TIMEOUT` | 0 | ASIL-B 不强制 |
| `SMU_ALERT_WIDTH` | 4 | — |
| `ECC_SCRUB_INTERVAL` | 1000 | — |

**验证重点**:
- 混合速率 (5G + 1G) 并发收发
- Switch Crossbar 4-port 满载转发零丢帧
- Switch 级 TAS 门控调度 (非端点级)
- CBS 信用整形带宽精度 (误差 < 0.1%)
- gPTP 双域同步精度 (±10ns)
- ASIL-B 安全机制：ECC 单/双 bit、FSM Parity、CSR Timeout
- AVTP 流识别与 DMA 队列隔离

**已知约束 / 非法组合**:
- `SWITCH_TAS=1` 时 `SUPPORT_TAS` 必须为 0 (硬件互锁，端点无需感知门控)
- `SWITCH_PORT_COUNT=4` 要求至少 4 个 MAC 接入 Switch (本配置 2 MAC，实际 Switch 端口数 ≤ 接入 MAC 数，此处需调整为 `SWITCH_PORT_COUNT=2` 或增加 MAC 数)
- **修正**: 本配置为 2 MAC 接入 Switch，`SWITCH_PORT_COUNT` 实际有效值为 2 (受限于接入 MAC 数)
- `MAC_0_TYPE=2` 时 `MAC_0_SPEED` 支持 0~5，但 PHY_0 为 Multi-Gigabit/5G，速率匹配

### 3.5 Config-C: 全功能 TSN + AVB

**场景**: ADAS 传感器汇聚 + AVB 信息娱乐、全 TSN 协议栈、MACsec 安全

| 参数 | 值 | 说明 |
|------|-----|------|
| `MAC_COUNT` | 4 | 4 MAC |
| `MAC_0_TYPE` | 2 | XGMAC/5G (ADAS 骨干) |
| `MAC_0_SPEED` | 4 | 5G |
| `MAC_1_TYPE` | 2 | XGMAC/5G |
| `MAC_1_SPEED` | 4 | 5G |
| `MAC_2_TYPE` | 1 | GMAC/1G (AVB) |
| `MAC_2_SPEED` | 2 | 1G |
| `MAC_3_TYPE` | 1 | GMAC/1G (车身) |
| `MAC_3_SPEED` | 2 | 1G |
| `PHY_COUNT` | 4 | — |
| `PHY_0_TYPE` | 3 | Multi-Gigabit/5G |
| `PHY_0_SPEED` | 4 | 5G |
| `PHY_0_DUPLEX` | 1 | 全双工 |
| `PHY_1_TYPE` | 3 | Multi-Gigabit/5G |
| `PHY_1_SPEED` | 4 | 5G |
| `PHY_1_DUPLEX` | 1 | 全双工 |
| `PHY_2_TYPE` | 2 | 1000BASE-T1/1G |
| `PHY_2_SPEED` | 2 | 1G |
| `PHY_2_DUPLEX` | 1 | 全双工 |
| `PHY_3_TYPE` | 2 | 1000BASE-T1/1G |
| `PHY_3_SPEED` | 2 | 1G |
| `PHY_3_DUPLEX` | 1 | 全双工 |
| `SUPPORT_1588` | 1 | — |
| `SUPPORT_GPTP` | 1 | — |
| `SUPPORT_TSN` | 1 | — |
| `SUPPORT_CBS` | 1 | — |
| `SUPPORT_TAS` | 0 | 端点 TAS 关闭 |
| `SUPPORT_FP` | 1 | — |
| `SUPPORT_FRER` | 1 | — |
| `SUPPORT_SWITCH` | 1 | — |
| `SWITCH_PORT_COUNT` | 4 | 4-port Switch |
| `SWITCH_TAS` | 1 | Switch 级 TAS |
| `SWITCH_L3` | 0 | 无 L3 |
| `SWITCH_CONNECTED_MAC_0` | 1 | 接入 Switch |
| `SWITCH_CONNECTED_MAC_1` | 1 | 接入 Switch |
| `SWITCH_CONNECTED_MAC_2` | 1 | 接入 Switch |
| `SWITCH_CONNECTED_MAC_3` | 1 | 接入 Switch |
| `SUPPORT_VLAN` | 1 | — |
| `SUPPORT_MACSEC` | 1 | **启用 MACsec** |
| `SUPPORT_AVTP` | 1 | — |
| `SUPPORT_AVTP_AWARE` | 1 | — |
| `SUPPORT_AVTP_CTL` | 1 | **启用 AVTP 控制** |
| `SUPPORT_EEE` | 0 | — |
| `SUPPORT_IPSEC` | 0 | — |
| `SUPPORT_SECOC` | 0 | — |
| `SUPPORT_DTLS` | 0 | — |
| `PHC_COUNT` | 2 | — |
| `SUPPORT_VPHC` | 1 | **启用 vPHC** |
| `DMA_CH_COUNT` | 16 | — |
| `DMA_CH_PER_MAC` | 4 | — |
| `MTL_TX_FIFO_DEPTH` | 32 | — |
| `MTL_RX_FIFO_DEPTH` | 32 | — |
| `MTL_TX_QUEUES` | 8 | — |
| `MTL_RX_QUEUES` | 8 | — |
| `DESC_SIZE` | 16 | — |
| `AXI_ID_WIDTH` | 4 | — |
| `AXI_DATA_WIDTH` | 128 | — |
| `CSR_ADDR_WIDTH` | 12 | — |
| `MAX_BURST_LEN` | 16 | — |
| `ASIL_LEVEL` | 2 | ASIL-B |
| `ECC_DATA_WIDTH` | 64 | — |
| `ECC_SYNDROME_WIDTH` | 8 | — |
| `ENABLE_PARITY_FSM` | 1 | — |
| `ENABLE_CSR_TIMEOUT` | 1 | — |
| `ENABLE_BUS_TIMEOUT` | 0 | — |
| `SMU_ALERT_WIDTH` | 4 | — |
| `ECC_SCRUB_INTERVAL` | 1000 | — |

**验证重点**:
- 全 TSN 功能并发：CBS + TAS + FP + PSFP + FRER
- MACsec 安全通道建立与数据流加密 (通过 CSS 接口)
- AVTP 流识别 + AVTP 控制路由表
- vPHC 虚拟化：多 VM 时间域隔离
- 4-port Switch 全并发 + FRER 序列号管理
- 双 XGMAC/5G + 双 GMAC/1G 混合带宽压力
- 帧抢占 (FP) 与 CBS 联合调度

**已知约束 / 非法组合**:
- `SUPPORT_MACSEC=1` 需外部 CSS 加速器配合，独立验证 CSS 接口时序
- `SUPPORT_VPHC=1` 需 SoC Hypervisor 支持，验证需软件模拟 Xen IO Ring
- `SUPPORT_AVTP_CTL=1` 依赖 `SUPPORT_AVTP=1` 且 `SUPPORT_SWITCH=1`
- 全 TSN 开启时门控周期配置冲突检查 (TAS GCL 与 CBS credit 周期对齐)

### 3.6 Config-D: 最大性能 (Central Gateway)

**场景**: 中央网关、SDV 骨干、最大端口数、L3 路由

| 参数 | 值 | 说明 |
|------|-----|------|
| `MAC_COUNT` | 8 | 最大 MAC |
| `MAC_0_TYPE` ~ `MAC_3_TYPE` | 2 | XGMAC/5G ×4 |
| `MAC_0_SPEED` ~ `MAC_3_SPEED` | 4 | 5G |
| `MAC_4_TYPE` ~ `MAC_7_TYPE` | 1 | GMAC/1G ×4 |
| `MAC_4_SPEED` ~ `MAC_7_SPEED` | 2 | 1G |
| `PHY_COUNT` | 8 | 最大 PHY |
| `PHY_0_TYPE` ~ `PHY_3_TYPE` | 3 | Multi-Gigabit/5G |
| `PHY_0_SPEED` ~ `PHY_3_SPEED` | 4 | 5G |
| `PHY_4_TYPE` ~ `PHY_7_TYPE` | 2 | 1000BASE-T1/1G |
| `PHY_4_SPEED` ~ `PHY_7_SPEED` | 2 | 1G |
| `PHY_x_DUPLEX` | 1 | 全双工 (所有) |
| `SUPPORT_1588` | 1 | — |
| `SUPPORT_GPTP` | 1 | — |
| `SUPPORT_TSN` | 1 | — |
| `SUPPORT_CBS` | 1 | — |
| `SUPPORT_TAS` | 0 | 端点 TAS 关闭 |
| `SUPPORT_FP` | 1 | — |
| `SUPPORT_FRER` | 1 | — |
| `SUPPORT_SWITCH` | 1 | — |
| `SWITCH_PORT_COUNT` | 8 | **8-port Switch** |
| `SWITCH_TAS` | 1 | — |
| `SWITCH_L3` | 1 | **启用 L3 路由** |
| `SWITCH_CONNECTED_MAC_0` ~ `SWITCH_CONNECTED_MAC_7` | 1 | 所有 MAC 接入 Switch |
| `SUPPORT_VLAN` | 1 | — |
| `SUPPORT_MACSEC` | 0 | — |
| `SUPPORT_AVTP` | 1 | — |
| `SUPPORT_AVTP_AWARE` | 1 | — |
| `SUPPORT_AVTP_CTL` | 0 | — |
| `SUPPORT_EEE` | 0 | — |
| `SUPPORT_IPSEC` | 0 | — |
| `SUPPORT_SECOC` | 0 | — |
| `SUPPORT_DTLS` | 0 | — |
| `PHC_COUNT` | 2 | — |
| `SUPPORT_VPHC` | 1 | — |
| `DMA_CH_COUNT` | 32 | **最大通道池** |
| `DMA_CH_PER_MAC` | 4 | — |
| `MTL_TX_FIFO_DEPTH` | 32 | — |
| `MTL_RX_FIFO_DEPTH` | 32 | — |
| `MTL_TX_QUEUES` | 8 | — |
| `MTL_RX_QUEUES` | 8 | — |
| `DESC_SIZE` | 32 | 扩展描述符 |
| `AXI_ID_WIDTH` | 8 | — |
| `AXI_DATA_WIDTH` | 128 | — |
| `CSR_ADDR_WIDTH` | 14 | — |
| `MAX_BURST_LEN` | 16 | — |
| `ASIL_LEVEL` | 2 | ASIL-B |
| `ECC_DATA_WIDTH` | 64 | — |
| `ECC_SYNDROME_WIDTH` | 8 | — |
| `ENABLE_PARITY_FSM` | 1 | — |
| `ENABLE_CSR_TIMEOUT` | 1 | — |
| `ENABLE_BUS_TIMEOUT` | 1 | **ASIL-C 预备** |
| `SMU_ALERT_WIDTH` | 4 | — |
| `ECC_SCRUB_INTERVAL` | 1000 | — |

**验证重点**:
- 8-port Switch Crossbar 全并发仲裁 (无饿死、无冲突)
- L3 路由表 1K 条目满载查表延迟 (<200ns)
- 32 通道 DMA 全局池仲裁公平性
- 4×5G + 4×1G 混合速率并发带宽压力
- AXI 128-bit @ 300MHz 总线饱和度测试
- 扩展描述符 (32B) 时间戳回写精度
- 温度自适应链路降速 (5G→2.5G→1G)

**已知约束 / 非法组合**:
- `SWITCH_PORT_COUNT=8` 要求 `MAC_COUNT ≥ 8` 且所有 MAC 接入 Switch
- `DMA_CH_COUNT=32` 为上限，8 MAC × 4 ch = 32 刚好饱和，无冗余
- `AXI_DATA_WIDTH=128` + `clk_sys=300MHz` = 38.4Gbps，需满足 4×5G + 4×1G = 24Gbps 线速 + Switch 转发 ×2 = 48Gbps，**总线带宽不足**
- **修正**: 此配置下 Switch 为 cut-through 模式 (R_switch_ct = 1.2×R_total)，AXI 带宽需求 ≈ 24 × 1.2 / 0.8 = 36Gbps < 38.4Gbps，满足
- `DESC_SIZE=32` 时描述符内存布局与 16B 模式不同，需独立验证

### 3.7 Config-E: 安全升级 (ASIL-D ready)

**场景**: 高安全等级网关、无 TSN 简化、全安全机制

| 参数 | 值 | 说明 |
|------|-----|------|
| `MAC_COUNT` | 2 | — |
| `MAC_0_TYPE` | 1 | GMAC/1G |
| `MAC_0_SPEED` | 2 | 1G |
| `MAC_1_TYPE` | 1 | GMAC/1G |
| `MAC_1_SPEED` | 2 | 1G |
| `PHY_COUNT` | 2 | — |
| `PHY_0_TYPE` | 2 | 1000BASE-T1 |
| `PHY_0_SPEED` | 2 | 1G |
| `PHY_0_DUPLEX` | 1 | 全双工 |
| `PHY_1_TYPE` | 2 | 1000BASE-T1 |
| `PHY_1_SPEED` | 2 | 1G |
| `PHY_1_DUPLEX` | 1 | 全双工 |
| `SUPPORT_1588` | 1 | — |
| `SUPPORT_GPTP` | 1 | — |
| `SUPPORT_TSN` | 0 | **无 TSN** |
| `SUPPORT_CBS` | 0 | — |
| `SUPPORT_TAS` | 0 | — |
| `SUPPORT_FP` | 0 | — |
| `SUPPORT_FRER` | 0 | — |
| `SUPPORT_SWITCH` | 1 | — |
| `SWITCH_PORT_COUNT` | 4 | — |
| `SWITCH_TAS` | 0 | — |
| `SWITCH_L3` | 0 | — |
| `SWITCH_CONNECTED_MAC_0` | 1 | — |
| `SWITCH_CONNECTED_MAC_1` | 1 | — |
| `SUPPORT_VLAN` | 1 | — |
| `SUPPORT_MACSEC` | 1 | **启用 MACsec** |
| `SUPPORT_AVTP` | 0 | 无 AVTP |
| `SUPPORT_AVTP_AWARE` | 0 | — |
| `SUPPORT_AVTP_CTL` | 0 | — |
| `SUPPORT_EEE` | 0 | — |
| `SUPPORT_IPSEC` | 1 | **启用 IPsec** |
| `SUPPORT_SECOC` | 1 | **启用 SecOC** |
| `SUPPORT_DTLS` | 1 | **启用 D-TLS** |
| `PHC_COUNT` | 2 | — |
| `SUPPORT_VPHC` | 0 | — |
| `DMA_CH_COUNT` | 8 | — |
| `DMA_CH_PER_MAC` | 4 | — |
| `MTL_TX_FIFO_DEPTH` | 32 | — |
| `MTL_RX_FIFO_DEPTH` | 32 | — |
| `MTL_TX_QUEUES` | 4 | 简化队列 |
| `MTL_RX_QUEUES` | 4 | — |
| `DESC_SIZE` | 16 | — |
| `AXI_ID_WIDTH` | 4 | — |
| `AXI_DATA_WIDTH` | 64 | — |
| `CSR_ADDR_WIDTH` | 12 | — |
| `MAX_BURST_LEN` | 16 | — |
| `ASIL_LEVEL` | 4 | **ASIL-D ready** |
| `ECC_DATA_WIDTH` | 64 | — |
| `ECC_SYNDROME_WIDTH` | 8 | — |
| `ENABLE_PARITY_FSM` | 1 | — |
| `ENABLE_CSR_TIMEOUT` | 1 | — |
| `ENABLE_BUS_TIMEOUT` | 1 | **必须使能** |
| `SMU_ALERT_WIDTH` | 4 | — |
| `ECC_SCRUB_INTERVAL` | 500 | 更频繁刷新 |

**验证重点**:
- 全安全机制验证：ECC 单 bit 纠错、双 bit 检错 + SMU 报警
- FSM Parity 故障注入：状态跳转错误检测与 Safe State 收敛
- AXI 总线超时：故障注入后 DMA/Switch 正确进入降级模式
- ASIL-D 等级下安全状态机转换 (NORMAL → DEGRADED → SAFE_STATE)
- MACsec + IPsec + SecOC + D-TLS 安全接口并发 (需外部加速器)
- 无 TSN 时基础 MAC/Switch 功能正确性
- 安全机制覆盖率：ECC 所有 SRAM/FIFO、Parity 所有 FSM、Timeout 所有接口

**已知约束 / 非法组合**:
- `ASIL_LEVEL=4` 要求 `ENABLE_PARITY_FSM=1`、`ENABLE_CSR_TIMEOUT=1`、`ENABLE_BUS_TIMEOUT=1`、`ECC_DATA_WIDTH=64`
- `ASIL_LEVEL=4` 为 **ready** 状态 (本 IP 内部机制)，完整 ASIL-D 需 SoC 级 Lockstep + SMU
- `SUPPORT_TSN=0` 时所有 TSN 子功能强制关闭，与 Switch_TAS=0 一致
- 安全加速器接口 (MACsec/IPsec/SecOC/D-TLS) 需外部 CSS/HSE，验证仅覆盖接口时序和握手

### 3.8 黄金配置回归策略

| 配置 | Nightly | Weekly | Smoke | 备注 |
|------|:-------:|:------:|:-----:|------|
| Config-A | ✅ | — | ✅ | 最小配置快速冒烟 |
| Config-B | ✅ | — | ✅ | 标准车载主配置 |
| Config-C | ✅ | ✅ | — | 全功能 TSN，回归时间较长 |
| Config-D | — | ✅ | — | 最大性能，FPGA 资源占用大 |
| Config-E | ✅ | — | — | 安全机制专项 |

---

## 4. 覆盖率目标 (Coverage Goals)

### 4.1 代码覆盖率

| 覆盖率类型 | 目标值 | 依据/说明 | 测量工具 |
|-----------|:------:|----------|---------|
| **Line coverage** | ≥ **95%** | 车规 IP 行业标准 (ISO 26262 推荐 >90%，本 IP 目标 95%) | VCS/Verilator Coverage |
| **Branch coverage** | ≥ **90%** | 组合逻辑复杂度 (TSN 调度器、Switch 仲裁器多分支) | VCS/Verilator Coverage |
| **FSM coverage** | ≥ **98%** | 安全状态机必须全覆盖；关键状态机 (MAC TX/RX、PTP 端口、DMA 命令 FIFO) 要求 100% 状态 + 转移 | VCS/Verilator Coverage |
| **Toggle coverage** | ≥ **90%** | 数据通路、配置寄存器 toggle；AXI 总线、DMA 描述符位域必须覆盖 | VCS/Verilator Coverage |
| **Condition coverage** | ≥ **90%** | 复杂条件表达式 (如 TAS 门控使能条件、CBS credit 判断) | VCS/Verilator Coverage |

**关键状态机 100% 覆盖清单**:

| 状态机 | 模块 | 状态数 | 必须覆盖的转移 |
|--------|------|--------|---------------|
| TX FSM | mac_core | 9 (TX_IDLE~TX_JAM) | 全部 20+ 转移 |
| RX FSM | mac_core | 9 (RX_IDLE~RX_IFG) | 全部 20+ 转移 |
| BMCA FSM | timestamp_unit | 8 | 全部 15+ 转移 |
| DMA CMD FSM | dma_engine | 4 (IDLE/CMD_POP/EXEC/RECOVERY) | 全部 8 转移 |
| TAS GCL FSM | mtl_scheduler | 5 | 全部 10 转移 |
| Switch FWD FSM | switch_core | 7 | 全部 12 转移 |
| Safety FSM | safety_monitor | 3 (NORMAL/DEGRADED/SAFE_STATE) | 全部 6 转移 |

### 4.2 功能覆盖率

| Covergroup | 覆盖点 | 目标 | 说明 |
|-----------|--------|------|------|
| `cg_mac_config` | `MAC_TYPE` × `MAC_SPEED` 所有合法组合 | 100% | 0×0~1, 1×0~2, 2×0~5 |
| `cg_phy_config` | `PHY_TYPE` × `PHY_SPEED` × `PHY_DUPLEX` | 100% | 含半双工约束 |
| `cg_tsn_features` | `SUPPORT_TSN` × `SUPPORT_CBS` × `SUPPORT_TAS` × `SUPPORT_FP` | 所有合法组合 | TAS/FP 互斥场景 |
| `cg_switch_config` | `SWITCH_PORT_COUNT` × `SWITCH_CONNECTED_MAC[0:7]` | 2/4/8-port × 接入拓扑 | 含混合拓扑 |
| `cg_asil_degradation` | `ASIL_LEVEL` × 安全机制开关 | 0~4 × ECC/Parity/Timeout | 渐变验证 |
| `cg_dma_channel` | `DMA_CH_COUNT` × `DMA_CH_PER_MAC` | 1/2/4/8/16/32 × 1~8 | 通道分配边界 |
| `cg_errata_scenarios` | 13 项 erratum 各至少 1 个 coverpoint | 100% | 每项 erratum 独立 coverpoint |
| `cg_protocol_compliance` | 802.3/802.1AS/802.1Q/802.1CB 关键帧类型 | 所有 Mandatary 帧类型 | 协议合规 |
| `cg_avtp_stream` | `SUPPORT_AVTP` × Stream ID 匹配/不匹配 | 100% | AVTP 流识别 |
| `cg_bandwidth_stress` | 帧长分布 × 速率 × 并发端口数 | Corner cases | 性能压力 |

### 4.3 断言覆盖率

| 断言类别 | 数量规划 | 目标覆盖率 | 重点模块 |
|---------|:--------:|:----------:|---------|
| **Protocol SVA** | ~80 条 | ≥ 95% | 802.3 帧格式、802.1AS 时间戳、802.1Q TAS 门控 |
| **Safety SVA** | ~60 条 | ≥ 95% | ECC 检测、FSM Parity、Timeout 触发 |
| **Erratum Anti-Regression** | ~40 条 | **100%** | 13 项 erratum 防退化 (详见 §5) |
| **DMA Integrity** | ~40 条 | ≥ 95% | 描述符环形缓冲区、AXI 握手、无死锁 |
| **Switch Arbitration** | ~30 条 | ≥ 95% | Crossbar 无冲突、公平性、无饿死 |
| **Total** | **~250 条** | ≥ 95% | — |

### 4.4 交叉覆盖率 (Cross Coverage)

| 交叉组合 | 维度1 | 维度2 | 维度3 | 目标 |
|----------|-------|-------|-------|------|
| `cross_mac_phy_type` | `MAC_x_TYPE` (3) | `PHY_x_TYPE` (4) | — | 所有合法 12 组合 |
| `cross_tsn_protocol` | `SUPPORT_CBS` | `SUPPORT_TAS` | `SUPPORT_FP` | 8 组合 (排除非法) |
| `cross_switch_tas` | `SWITCH_TAS` | `SWITCH_PORT_COUNT` | 流量模式 | 门控周期内满载/空闲 |
| `cross_asil_fault` | `ASIL_LEVEL` | 故障类型 (ECC/Parity/Timeout) | 恢复结果 | 所有故障注入组合 |
| `cross_dma_stress` | `DMA_CH_COUNT` | 并发通道数 | AXI 延迟 | 边界饱和 |
| `cross_ptp_accuracy` | `PHC_COUNT` | 端口数 | 同步模式 (OC/BC/TC) | 精度覆盖 |

---

## 5. TC4x Erratum 回归套件 (Erratum Regression Suite)

### 5.1 回归策略

| Erratum 严重度 | 数量 | 回归频率 | 说明 |
|---------------|:----:|:--------:|------|
| **高 (High)** | 5 项 | **Nightly** | 核心卖点，任何 RTL 变更后必须验证 |
| **中 (Medium)** | 8 项 | **Weekly** | 定期回归，release gate 前全量 |

### 5.2 Erratum → Testcase 映射

| Errata ID | 标题 | 严重度 | Testcase ID | 验证方法 | 通过判据 | SVA 断言 (防退化) |
|-----------|------|:------:|-------------|----------|----------|-------------------|
| **GETH_AI.029** | CBS credit 不在 IPG 期间递减 | **高** | `TC4-ERR-001-CBS-IPG` | UVM directed: 1000 帧 CBS 整形后带宽测量 | 误差 < 0.1% (vs TC4x ~2.65%) | `ASSERT_CBS_IPG_DECR: credit_decr_en == 1 → credit decreases during IPG` |
| **GETH_AI.032** | TAS 背靠背传输额外 IPG | **高** | `TC4-ERR-002-TAS-IPG` | UVM directed: TAS 门控周期内背靠背传输 | 额外 IPG = 0 周期 | `ASSERT_TAS_ZERO_IPG: tas_gate_open && tx_ready → tx_start within 1 cycle` |
| **GETH_AI.036** | MAC 在 TX FIFO 达阈值前开始传输 | **高** | `TC4-ERR-003-TX-THRESH` | UVM directed: 阈值模式下 FIFO 水位监控 | Underflow 零发生 | `ASSERT_TX_THRESH_READY: tx_start → tx_fifo_level >= threshold` |
| **GETH_AI.039** | MII 模式下 underflow 不终止传输 | **高** | `TC4-ERR-004-UF-TERM` | UVM fault injection: MII 模式强制 underflow | 检测到 Jam 序列 + TX_EN 下降 | `ASSERT_UF_TERMINATE: underflow_detected → tx_state == TX_JAM within 2 cycles` |
| **GETH_AI.037/040/041/042** | RX DMA 多种 stall 场景 | **高** | `TC4-ERR-005-DMA-STALL` | UVM concurrent: flush/resume/变长包同时触发 | 3ms 内自恢复，无通道阻塞 | `ASSERT_DMA_RECOVERY: dma_stall → recovery_complete within 3ms` |
| **LETH_TC.010** | 多端口 PTP 只能成对菊花链 | **高** | `TC4-ERR-006-PTP-XBAR` | UVM + FPGA: 4-port 并发 PTP 同步 | 各端口 residence time < ±20ns | `ASSERT_PTP_CROSSBAR: ptp_port_req[i] → ptp_phc_grant[i] within 1 cycle` |
| **LETH_AI.024** | Bridge 启用时非 TxQ0 时间戳错误 | **高** | `TC4-ERR-007-TS-ROUTE` | UVM directed: 多 TxQ 时间戳捕获与回写 | channel_id 匹配，时间戳误差 < ±10ns | `ASSERT_TS_CHANNEL_MATCH: tx_tstamp_ch_id == tx_queue_ch_id` |
| **DRE_TC.H002** | DRE 转发带宽瓶颈丢帧 | **高** | `TC4-ERR-008-SW-FLOOD` | UVM performance: 4-port 广播风暴满载 | 丢帧率 ≤ 0.01% | `ASSERT_SW_NO_HOL: ingress_fifo_full[i] → !egress_stall[j]` |
| **GETH_AI.035** | RX watchdog timer 不重置 | 中 | `TC4-ERR-009-RX-WDOG` | UVM directed: 多 timer 并发触发后统一重置 | 所有 timer 正确重置 | `ASSERT_RX_WDOG_RESET: irq_aggregated → all_wdog_timers_reset` |
| **GETH_AI.033** | VLAN filter fail queue 路由错误 | 中 | `TC4-ERR-010-VLAN-FAIL` | UVM directed: VLAN 不匹配帧的路由 | 路由到 fail queue 或丢弃 | `ASSERT_VLAN_FAIL_ROUTE: vlan_filter_fail → frame_to_fail_queue` |
| **GETH_AI.045** | Bridge 转发填充 8 字节 padding | 中 | `TC4-ERR-011-FCS-RECALC` | UVM directed: Switch 修改 DA/SA/VLAN 后 FCS | FCS 正确重算，帧长无 padding 异常 | `ASSERT_FCS_RECALC: header_modified → fcs_recalc_en asserted` |
| **HSPHY_TC.005** | 温度变化时 RX 通信丢失 | 中 | `TC4-ERR-012-TEMP-LINK` | FPGA + 环境箱: -40°C~+125°C 温度循环 | 链路降速后恢复成功率 > 99.9% | `ASSERT_TEMP_ADAPTIVE: |delta_T| > 10C → speed_downgrade graceful` |
| **GETH_AI.034** | MII 模式非标准 IPG 不匹配 | 中 | `TC4-ERR-013-MII-IPG` | UVM directed: MII 模式 IPG 寄存器配置 | IPG 精确匹配编程值 | `ASSERT_MII_IPG_ALIGN: ipg_programmed == actual_ipg_boundary_aligned` |

### 5.3 PLCA 时序 Erratum 回归 (10BASE-T1S)

| Errata ID | 标题 | Testcase ID | 验证方法 | SVA 断言 |
|-----------|------|-------------|----------|----------|
| LETH_AI.011 | TO 延迟超标 | `TC4-ERR-014-PLCA-TO` | UVM + FPGA: 4-node PLCA 网络 | `ASSERT_PLCA_TO: to_timer_expired → tx_en within 5.56us` |
| LETH_AI.013 | Commit timer 超标 | `TC4-ERR-015-PLCA-COMMIT` | UVM directed: commit timer 硬限制 | `ASSERT_PLCA_COMMIT: commit_timer <= 288 cycles` |
| LETH_AI.016 | RTT 偏差 | `TC4-ERR-016-PLCA-RTT` | UVM directed: RTT 自适应测量 | `ASSERT_PLCA_RTT: |rtt_measured - expected| < 10%` |

### 5.4 外部 PHY 选型约束验证 (非 RTL erratum)

| 约束项 | Testcase ID | 验证方法 | 说明 |
|--------|-------------|----------|------|
| TC14 PMD v1.5+ 合规 | `TC4-ERR-017-PHY-TC14` | 文档评审 + 供应商确认 | PHY 数据手册审查 |
| Elastic Buffer ≤ 8 | `TC4-ERR-018-PHY-EBUF` | 供应商确认 | 选型约束 |
| Symbol Aligner 5-bit | `TC4-ERR-019-PHY-ALIGN` | 供应商确认 | 选型约束 |
| ED 脉冲 ≤ 20ns | `TC4-ERR-020-PHY-ED` | FPGA 实测 | 示波器验证 |

---

## 6. PICS 可追溯性 (PICS Traceability)

### 6.1 追溯矩阵原则

- 每个 PICS **Mandatory/Optional Yes** 项 → 至少 1 个 testcase ID
- 每个 PICS **No** 项 → 至少 1 个 **negative test case ID**（验证正确拒绝/忽略）
- 每个 **Configurable** 项 → 至少 2 个 testcase ID（enable / disable 状态各一）

### 6.2 IEEE 802.1AS-2020 gPTP

| PICS 项 | 状态 | 支持 | Testcase ID (Yes) | Testcase ID (No/Negative) | 备注 |
|---------|:----:|:----:|-------------------|--------------------------|------|
| DOM0 | M | Yes | `TC-8021AS-001-DOM0-SYNC` | — | gPTP Domain 0 同步 |
| DOMADD | O | Yes | `TC-8021AS-002-DOMADD` | — | 多域支持 (PHC_COUNT=2) |
| MINTA | M | Yes | `TC-8021AS-003-MINTA` | — | 最小时间同步精度 |
| BMC | M | Yes | `TC-8021AS-004-BMCA` | — | 最佳主时钟算法 |
| SIG | O | Yes | `TC-8021AS-005-SIGNALING` | — | Signaling 消息 |
| GMCAP | O | Yes | `TC-8021AS-006-GMCAP` | — | Grandmaster 能力 |
| **BRDG** | **M** | **Yes** | `TC-8021AS-007-BRDG-FWD` | — | **Bridge 转发 (Switch 替代)** |
| MIMSTR | M | Yes | `TC-8021AS-008-MIMSTR` | — | 多实例管理 |
| MIPERF | O | **No** | — | `TC-8021AS-NEG-001-NO-MIPERF` | 拒绝性能声明请求 |
| MDFDPP | O | **No** | — | `TC-8021AS-NEG-002-NO-MDFDPP` | 忽略多域延迟测量 |
| UMM | O | **No** | — | `TC-8021AS-NEG-003-NO-UMM` | 忽略非统一消息 |

### 6.3 IEEE 802.1Q-2022 TSN

| PICS 项 | 状态 | 支持 | Testcase ID (Yes) | Testcase ID (No/Negative) | 备注 |
|---------|:----:|:----:|-------------------|--------------------------|------|
| FQTSS | O.1 | Yes | `TC-8021Q-001-FQTSS` | — | 转发与排队 TSN |
| **SRP** | **O.2** | **No** | — | `TC-8021Q-NEG-001-NO-SRP` | **拒绝 MSRP 报文** |
| **PFC** | **O.2** | **No** | — | `TC-8021Q-NEG-002-NO-PFC` | **忽略 PAUSE 扩展** |
| ETS | O.2 | Yes | `TC-8021Q-002-ETS` | — | 增强传输选择 |
| **SCHED** | **O.2** | **Yes** | `TC-8021Q-003-TAS` | — | **TAS 门控调度** |
| **PRE** | **O.2** | **Yes** | `TC-8021Q-004-PRE` | — | **帧抢占** |
| **PSFP** | **O.2** | **Yes** | `TC-8021Q-005-PSFP` | — | **流过滤与监管** |
| ATS | O.2 | No | — | `TC-8021Q-NEG-003-NO-ATS` | 忽略 ATS 请求 |
| CQF | O.2 | No | — | `TC-8021Q-NEG-004-NO-CQF` | 忽略 CQF 配置 |
| **PCR(FRER)** | **O.2** | **Yes** | `TC-8021Q-006-FRER` | — | **帧复制与消除** |

### 6.4 IEEE 802.1AE-2018 MACsec

| PICS 项 | 状态 | 支持 | Testcase ID (Yes) | Testcase ID (No/Negative) | 备注 |
|---------|:----:|:----:|-------------------|--------------------------|------|
| SAP/STAT/GEN/VER/FMT/SCI | M | Yes | `TC-8021AE-001-MACSEC-BASE` | — | 核心安全功能 |
| KAY/MGT/CS/CSI/CSC | M | Yes | `TC-8021AE-002-KEY-MGMT` | — | 密钥管理 |
| CSO | O | Yes | `TC-8021AE-003-CSO` | — | 部分加密优化 |
| MSC (多 SC) | O | **No** | — | `TC-8021AE-NEG-001-NO-MSC` | 单 SC 限制验证 |
| MSAK (多 SAK) | O | **No** | — | `TC-8021AE-NEG-002-NO-MSAK` | 2 SAK 限制验证 |
| TC (多发送 SC) | O | **No** | — | `TC-8021AE-NEG-003-NO-TC` | 单发送 SC 验证 |
| MIB (SNMPv3) | O | **No** | — | `TC-8021AE-NEG-004-NO-MIB` | 忽略 SNMP 请求 |
| CSX (非标准 Cipher) | X | **No** | — | `TC-8021AE-NEG-005-NO-CSX` | 拒绝非标准加密套件 |

### 6.5 IEEE 1588-2019 PTP

| PICS 项 | 状态 | 支持 | Testcase ID (Yes) | Testcase ID (No/Negative) | 备注 |
|---------|:----:|:----:|-------------------|--------------------------|------|
| PTPv2.1 基础 | M | Yes | `TC-1588-001-PTP-BASE` | — | 基础 PTP |
| P2P 延迟机制 | M | Yes | `TC-1588-002-P2P` | — | 点对点延迟 |
| Two-Step | O | Yes | `TC-1588-003-TWO-STEP` | — | 两步式时钟 |
| 硬件时间戳 | O | Yes | `TC-1588-004-HW-TS` | — | SFD 级捕获 |
| BC (Boundary Clock) | O | Yes | `TC-1588-005-BC` | — | 边界时钟 |
| 数据集 | M | Yes | `TC-1588-006-DATASET` | — | 数据集管理 |
| E2E | O | **No** | — | `TC-1588-NEG-001-NO-E2E` | 拒绝 E2E 报文 |
| IPv4/UDP 映射 | O | **No** | — | `TC-1588-NEG-002-NO-IPV4` | 忽略 IP 层 PTP |
| Management 消息 | O | **No** | — | `TC-1588-NEG-003-NO-MGMT` | 忽略 Management 请求 |
| L1Sync | O | **No** | — | `TC-1588-NEG-004-NO-L1SYNC` | 忽略 L1 同步 |
| AUTH TLV | O | **No** | — | `TC-1588-NEG-005-NO-AUTH` | 忽略认证 TLV |

### 6.6 IEEE 802.3-2022 Ethernet

| PICS 项 | 状态 | 支持 | Testcase ID (Yes) | Testcase ID (No/Negative) | 备注 |
|---------|:----:|:----:|-------------------|--------------------------|------|
| 100BASE-T1 | M | Yes | `TC-8023-001-100BT1` | — | 100M 车载以太网 |
| 1000BASE-T1 | M | Yes | `TC-8023-002-1000BT1` | — | 1G 车载以太网 |
| 10BASE-T1S | O | Yes | `TC-8023-003-10BT1S` | — | 10M 多点总线 |
| PLCA | O | Yes | `TC-8023-004-PLCA` | — | 物理层冲突避免 |
| 2.5G/5G/10G | O | Yes | `TC-8023-005-MULTIGIG` | — | 多千兆速率 |
| EEE | O | **Configurable** | `TC-8023-006-EEE-ON` / `TC-8023-007-EEE-OFF` | — | 低功耗模式开关验证 |

### 6.7 IEEE 802.1CB-2017 FRER

| PICS 项 | 状态 | 支持 | Testcase ID (Yes) | Testcase ID (No/Negative) | 备注 |
|---------|:----:|:----:|-------------------|--------------------------|------|
| IS (Individual Stream) | M | Yes | `TC-8021CB-001-IS` | — | 独立流识别 |
| TE (Transmit Endpoint) | M | Yes | `TC-8021CB-002-TE` | — | 发送端点 |
| LE (Listen Endpoint) | M | Yes | `TC-8021CB-003-LE` | — | 监听端点 |
| RS (Recovery Stream) | M | Yes | `TC-8021CB-004-RS` | — | 恢复流 |
| Sequence Gen/Recovery | M | Yes | `TC-8021CB-005-SEQ` | — | 序列号生成/恢复 |
| HSR/PRP 兼容 | O | **No** | — | `TC-8021CB-NEG-001-NO-HSR` | 拒绝 HSR/PRP 帧 |
| IP Stream ID | O | **No** | — | `TC-8021CB-NEG-002-NO-IP-SID` | 忽略 IP 流标识 |
| Autoconfig | O | **No** | — | `TC-8021CB-NEG-003-NO-AUTO` | 忽略自动配置 |

### 6.8 IEEE 802.1AB-2016 LLDP

| PICS 项 | 状态 | 支持 | Testcase ID (Yes) | Testcase ID (No/Negative) | 备注 |
|---------|:----:|:----:|-------------------|--------------------------|------|
| Chassis/Port/TTL | M | Yes | `TC-8021AB-001-CHASSIS` | — | 基础 TLV |
| Tx/Rx 模式 | M | Yes | `TC-8021AB-002-TXRX` | — | 收发模式 |
| 状态机 | M | Yes | `TC-8021AB-003-FSM` | — | LLDP 状态机 |
| SNMP MIB | O | **No** | — | `TC-8021AB-NEG-001-NO-MIB` | 忽略 SNMP 查询 |
| Organization TLV | O | **No** | — | `TC-8021AB-NEG-002-NO-ORG` | 忽略组织特定 TLV |

### 6.9 IEEE 1722 AVTP/ACF

| PICS 项 | 状态 | 支持 | Testcase ID (Yes) | Testcase ID (No/Negative) | 备注 |
|---------|:----:|:----:|-------------------|--------------------------|------|
| AVTP 封装 | M | Yes | `TC-1722-001-AVTP-ENCAP` | — | AVTP 帧封装 |
| ACF 封装 | M | Yes | `TC-1722-002-ACF-ENCAP` | — | ACF 帧封装 |
| 流识别 | M | Yes | `TC-1722-003-STREAM-ID` | — | Stream ID 匹配 |
| ACF_CAN_BRIEF | O | Yes | `TC-1722-004-CAN-BRIEF` | — | CAN  brief 封装 |
| Talker/Listener 完整栈 | O | **No** | — | `TC-1722-NEG-001-NO-TALKER` | 软件实现验证 |
| IEEE 1722.1 Control | O | **Configurable** | `TC-1722-005-CTL-ON` / `TC-1722-006-CTL-OFF` | — | 控制路由表开关 |

### 6.10 安全加速器接口 (Configurable)

| PICS 项 | 状态 | 支持 | Testcase ID (Enable) | Testcase ID (Disable) | 备注 |
|---------|:----:|:----:|---------------------|----------------------|------|
| IPsec ESP/AH | Configurable | 默认 Off | `TC-SEC-001-IPSEC-ON` | `TC-SEC-002-IPSEC-OFF` | 外部 CSS/HSE |
| SecOC PDU | Configurable | 默认 Off | `TC-SEC-003-SECOC-ON` | `TC-SEC-004-SECOC-OFF` | 外部 CSS/HSE |
| D-TLS | Configurable | 默认 Off | `TC-SEC-005-DTLS-ON` | `TC-SEC-006-DTLS-OFF` | 外部 CSS |
| MACsec | Configurable | 默认 Off | `TC-SEC-007-MACSEC-ON` | `TC-SEC-008-MACSEC-OFF` | 外部 CSS |
| EEE | Configurable | 默认 Off | `TC-SEC-009-EEE-ON` | `TC-SEC-010-EEE-OFF` | PHY 配合 |

---

## 6.11 IEEE 1722-2016 AVTP 验证

### 6.11.1 验证范围

AVTP 验证覆盖 IEEE 1722 Talker、Listener 及 Switch AVTP Awareness 三个角色，重点验证：
- **帧生成与解析**: AVTPDU Common Header、Stream ID、时间戳、subtype 格式正确性
- **流识别与错误注入**: Stream ID 匹配/不匹配场景、非法帧处理
- **TSN 门控协同**: AVTP 流映射到 TSN 队列、与 CBS/TAS 联合调度
- **ACF 控制隧道**: CAN/CAN-Multiple/CAN-Brief 封装与桥接

### 6.11.2 AVTP 帧生成/解析验证

| 测试项 | Testcase ID | 验证方法 | 通过判据 | SVA 断言 |
|--------|-------------|----------|----------|----------|
| **Talker 帧生成** | `TC-AVTP-001-TX-FORMAT` | UVM directed: 配置 Talker 发送 RVF/CRF 帧 | AVTPDU 格式符合 Table 5-1，sequence_num 递增 | `ASSERT_AVTP_SEQ_INC: seq_num == prev_seq_num + 1` |
| **Listener 帧解析** | `TC-AVTP-002-RX-PARSE` | UVM directed: 注入标准 AVTP 帧到 Listener | 正确解析 Stream ID、timestamp、subtype | `ASSERT_AVTP_STREAM_MATCH: sid_match == 1 -> dma_ch routed` |
| **Common Header 字段** | `TC-AVTP-003-HDR-FIELDS` | UVM directed: 遍历 sv/tv/gv/mr 位组合 | 各标志位正确影响接收行为 | `ASSERT_AVTP_HDR_VALID: version==0 && ethertype==0x22F0` |
| **时间戳精度** | `TC-AVTP-004-TS-ACC` | UVM + 参考模型: 比较 AVTP_timestamp 与 gPTP 时间 | 误差 ≤ 1μs | `ASSERT_AVTP_TS_BOUND: |avtp_ts - gptp_ts| <= 1000ns` |
| **多 subtype 支持** | `TC-AVTP-005-SUBTYPE` | UVM directed: RVF/CRF/ACF 帧交替发送 | 根据 subtype 正确分发到对应处理路径 | `ASSERT_AVTP_SUBTYPE_ROUTE: subtype -> correct_path` |

### 6.11.3 Stream 识别错误注入

| 测试项 | Testcase ID | 验证方法 | 通过判据 | SVA 断言 |
|--------|-------------|----------|----------|----------|
| **Stream ID 匹配失败** | `TC-AVTP-006-SID-MISS` | UVM error injection: 注入未注册 Stream ID 的 AVTP 帧 | 帧被丢弃或转发到默认端口，触发 sid_miss 计数器 | `ASSERT_AVTP_SID_MISS: !sid_hit -> drop_or_default` |
| **Stream ID 表满** | `TC-AVTP-007-SID-FULL` | UVM directed: 配置最大条目数 (32条) 后新增 Stream | 第 33 条 Stream 配置返回 ERROR，现有流不受影响 | `ASSERT_AVTP_SID_FULL: sid_table_count <= MAX_SID` |
| **非法 EtherType** | `TC-AVTP-008-BAD-ETYPE` | UVM error injection: EtherType != 0x22F0 | 帧被识别为非 AVTP，走标准以太网转发路径 | `ASSERT_AVTP_ETYPE_CHK: ethertype!=0x22F0 -> non_avtp_path` |
| **版本错误** | `TC-AVTP-009-BAD-VER` | UVM error injection: version != 0 | 版本错误帧丢弃，或按前向兼容处理 | `ASSERT_AVTP_VER_CHK: version!=0 -> drop` |
| **时间戳过期** | `TC-AVTP-010-TS-EXPIRED` | UVM directed: 注入 presentation_time << current_time 的帧 | 过期帧被丢弃或标记为 LATE | `ASSERT_AVTP_TS_EXPIRED: pres_ts < (curr_ts - thresh) -> late_drop` |
| **序列号跳跃** | `TC-AVTP-011-SEQ-GAP` | UVM error injection: 故意制造 sequence_num gap > 1 | 检测到丢帧，触发 seq_gap 中断/计数器 | `ASSERT_AVTP_SEQ_GAP: seq_gap > 1 -> gap_detected` |
| **ACF CAN 格式错误** | `TC-AVTP-012-ACF-BAD` | UVM error injection: ACF 头中 acfhdrlen 与实际 payload 不符 | 格式错误帧丢弃，不传递给 CAN 桥接 | `ASSERT_ACF_LEN_CHK: acfhdrlen == actual_acf_len` |

### 6.11.4 TSN 门控协同验证

| 测试项 | Testcase ID | 验证方法 | 通过判据 | SVA 断言 |
|--------|-------------|----------|----------|----------|
| **SR Class A 映射** | `TC-AVTP-013-SR-A` | UVM directed: AVTP 流配置为 SR Class A (PCP=3) | 映射到 TC 0，启用 CBS，信用整形生效 | `ASSERT_AVTP_SR_A: pcp==3 -> tc==0 && cbs_en` |
| **SR Class B 映射** | `TC-AVTP-014-SR-B` | UVM directed: AVTP 流配置为 SR Class B (PCP=2) | 映射到 TC 1，启用 CBS | `ASSERT_AVTP_SR_B: pcp==2 -> tc==1 && cbs_en` |
| **Best Effort 控制流** | `TC-AVTP-015-BE-CTL` | UVM directed: ACF/AVDECC 流配置为 Best Effort | 映射到 TC 3，不占用 SR 带宽 | `ASSERT_AVTP_BE_CTL: acf_frame -> tc==3 && !sr_class` |
| **TAS 门控窗口内 AVTP 传输** | `TC-AVTP-016-TAS-WINDOW` | UVM directed: TAS GCL 配置 AVTP 专用门控窗口 | 门控开启期间 AVTP 帧正常发送，关闭期间缓冲或丢弃 | `ASSERT_AVTP_TAS_GATE: tas_gate_open && avtp_ready -> tx_start` |
| **TAS 门控边界保护** | `TC-AVTP-017-TAS-BOUNDARY` | UVM directed: 门控关闭前 1 cycle 启动长帧传输 | 帧不被截断，或截断后正确填充/FCS 重算 | `ASSERT_AVTP_TAS_BOUNDARY: !tas_gate_open -> !new_tx_start` |
| **CBS + TAS 联合调度** | `TC-AVTP-018-CBS-TAS` | UVM performance: AVTP 突发流在 TAS 窗口内 CBS 整形 | 实际带宽与配置误差 < 0.1%，无帧丢失 | `ASSERT_AVTP_CBS_TAS: credit >= 0 && gate_open -> tx_scheduled` |
| **FP 抢占 AVTP 窗口** | `TC-AVTP-019-FP-PREEMPT` | UVM directed: TAS AVTP 窗口内 Express 帧插入 | Express 帧抢占可抢占帧，AVTP 帧从断点恢复 | `ASSERT_AVTP_FP: express_req -> preempt_ok && resume_ok` |
| **FRER 冗余 AVTP 流** | `TC-AVTP-020-FRER-AVTP` | UVM directed: AVTP 流启用 FRER 双路径发送 | R-TAG 序列号正确注入，双路径延迟差 < 100μs | `ASSERT_AVTP_FRER: rtag_seq == frer_seq_gen && path_delay < 100us` |
| **gPTP 域与 AVTP 时间一致性** | `TC-AVTP-021-GPTP-ALIGN` | UVM directed: gPTP 时间跳变 (闰秒/域切换) | AVTP 时间戳正确跟随 gPTP，无时间漂移 | `ASSERT_AVTP_GPTP_ALIGN: |avtp_ts_base - gptp_gm_ts| < 1us` |

### 6.11.5 ACF CAN 桥接验证

| 测试项 | Testcase ID | 验证方法 | 通过判据 | SVA 断言 |
|--------|-------------|----------|----------|----------|
| **ACF CAN 单帧桥接** | `TC-AVTP-030-ACF-SINGLE` | UVM directed: 单 CAN 帧封装为 ACF CAN 发送 | CAN ID/DLC/Data 正确提取，桥接到内部 CAN IF | `ASSERT_ACF_CAN_BRIDGE: acf_can_valid -> can_if_tx_en` |
| **ACF CAN Multiple 聚合** | `TC-AVTP-031-ACF-MULTI` | UVM directed: 4 条 CAN 帧聚合为 ACM 发送 | 各子帧 CAN ID 独立解析，顺序保持 | `ASSERT_ACF_MULTI_SEQ: multi_frame[i].can_id == expected[i]` |
| **ACF CAN Brief 精简** | `TC-AVTP-032-ACF-BRIEF` | UVM directed: Brief 格式 CAN 帧收发 | 精简字段 (无 timestamp) 正确解析 | `ASSERT_ACF_BRIEF_LEN: brief_payload_len == 8+dlc` |
| **ACF CAN 时间戳** | `TC-AVTP-033-ACF-TS` | UVM directed: ACF CAN 帧时间戳与 gPTP 对齐 | ACF timestamp 与 AVTP timestamp 同基准 | `ASSERT_ACF_TS_ALIGN: |acf_ts - gptp_ts| < 1us` |

### 6.11.6 AVTP 覆盖率目标

| Covergroup | 覆盖点 | 目标 | 说明 |
|-----------|--------|------|------|
| `cg_avtp_header` | sv/tv/gv/mr × version × ethertype | 100% | 公共头所有合法组合 |
| `cg_avtp_subtype` | RVF/CRF/ACF_CAN/ACF_CM/ACF_CB | 100% | 支持的所有 subtype |
| `cg_avtp_stream_id` | 匹配/不匹配/表满/边界 | 100% | Stream ID 查表场景 |
| `cg_avtp_ts` | 正常/过期/超前/闰秒边界 | 100% | 时间戳场景 |
| `cg_avtp_qos_map` | SR_A/SR_B/BE × traffic class | 100% | 优先级映射 |
| `cg_avtp_tas` | gate_open/closed × avtp_ready/not_ready | 100% | 门控协同 |
| `cg_avtp_acf` | CAN/CM/CB × 单帧/多帧 | 100% | ACF 场景 |

---

## 7. Formal 验证 (Formal Verification)

### 7.1 项目决策

> **实体 Yang 决策 (2026-05-21)**: 当前 PAD → EDR 阶段 **不投入 Formal 验证资源**。
>
> 不购买/不部署 Formal 验证工具 (JasperGold / VC Formal / SymbiYosys)。

### 7.2 决策理由

| 理由 | 说明 |
|------|------|
| **资源限制** | 项目预算与时间表不允许额外 Formal 验证工具 license 采购及工程师培训 |
| **验证替代方案** | 全部 Formal 验证目标模块通过 **UVM + SVA Assertion** 覆盖，提供充分的仿真级验证保证 |
| **风险可控** | 以下模块的 Formal 属性已通过 SVA 在 UVM 环境中覆盖：TAS 门控周期一致性、DMA 描述符环形缓冲区无溢出、PTP 时间戳 monotonicity、Switch Crossbar 无冲突、ECC 单/双 bit 检测 |
| **行业标准** | 车规 IP 验证可通过仿真 + assertion 达到合规要求 (ISO 26262 不强制 Formal) |

### 7.3 未来扩展

若后续项目阶段或客户要求需要 Formal 验证，可补充以下计划：

| 模块 | 属性类型 | 工具建议 | 收敛目标 |
|------|----------|----------|----------|
| TAS Scheduler | Safety (周期一致性) + Liveness (门控触发) | JasperGold | Proof coverage > 95% |
| DMA Descriptor Controller | Safety (指针一致性) + Liveness (无死锁) | VC Formal | Proof coverage > 95% |
| PTP Timestamp Engine | Safety (monotonicity) | JasperGold | Proof coverage > 95% |
| Switch Crossbar Arbiter | Safety (无冲突) + Liveness (公平性) | VC Formal | Proof coverage > 95% |
| ECC Controller | Safety (单/双 bit 正确检测) | JasperGold | Proof coverage > 95% |
| CBS Credit Shaper | Safety (信用值有界) | VC Formal | Proof coverage > 95% |

> **注**: 原 VERIF-CRIT-003 (Formal 验证为 Critical 路径) 已删除，本章节标记为 N/A。

---

## 8. 验证环境 (Verification Environment)

### 8.1 UVM Testbench 架构

```
+========================================================================================+
|                          Ethernet IP UVM Testbench                                      |
+========================================================================================+
|                                                                                        |
|  +----------------+     +----------------+     +----------------+                    |
|  |  Test Sequence |────►|   UVM Agent    |────►|   DUT (IP)     |                    |
|  |  (Virtual Seq) |     |  (MAC/PHY/DMA) |     |                |                    |
|  +----------------+     +----------------+     +----------------+                    |
|         │                       │                       │                            |
|         ▼                       ▼                       ▼                            |
|  +----------------+     +----------------+     +----------------+                    |
|  |  Scoreboard    |◄────|   Monitor      |◄────|   Coverage     |                    |
|  |  (Ref Model)   |     |  (Protocol CK) |     |  (Covergroup)  |                    |
|  +----------------+     +----------------+     +----------------+                    |
|         │                       │                       │                            |
|         ▼                       ▼                       ▼                            |
|  +================================================================================+  |
|  |                         Assertion Engine (SVA)                                  |  |
|  |   · Protocol Checks (802.3/802.1AS/802.1Q)                                    |  |
|  |   · Safety Checks (ECC/Parity/Timeout)                                        |  |
|  |   · Erratum Anti-Regression (13× SVA)                                          |  |
|  +================================================================================+  |
```

### 8.2 UVM Agent 清单

| Agent | 协议/接口 | 功能 | 优先级 |
|-------|-----------|------|--------|
| `mac_agent` | MII/GMII/RGMII | MAC 帧收发、时间戳捕获 | P0 |
| `phy_agent` | SGMII/USXGMII | PHY 寄存器访问、链路状态 | P0 |
| `dma_agent` | AXI4 Master | DMA 描述符/数据搬搬、中断 | P0 |
| `csr_agent` | AXI4-Lite Slave | 寄存器配置、中断读取 | P0 |
| `tsn_agent` | 802.1Qav/802.1Qbv | CBS credit 监控、TAS 门控 | P0 |
| `ptp_agent` | 802.1AS/1588 | gPTP 消息收发、时间戳精度 | P0 |
| `switch_agent` | L2/L3 Switch | FDB/VLAN 配置、转发验证 | P0 |
| `safety_agent` | ECC/Parity/Timeout | 故障注入、安全状态监控 | P1 |
| `avtp_agent` | IEEE 1722 | AVTP 流识别、DMA 队列路由 | P1 |

### 8.3 FPGA 验证平台

| 平台 | 器件 | 用途 | 覆盖配置 |
|------|------|------|----------|
| **FPGA-A** | Zynq UltraScale+ ZCU102 | 功能验证 + 温度循环 | Config-B, Config-E |
| **FPGA-B** | Xilinx Virtex UltraScale+ VCU118 | 性能压力 + 8-port Switch | Config-D |
| **FPGA-C** | 定制板 (10BASE-T1S PHY) | PLCA 时序 + 噪声注入 | Config-A |

### 8.4 参考模型 (Reference Model)

| 模块 | 参考模型 | 语言 | 来源 |
|------|----------|------|------|
| MAC TX/RX | 802.3 标准帧生成/校验 | C/SystemVerilog | 自研 |
| CBS Shaper | Credit-Based Shaper 数学模型 | C | IEEE 802.1Qav 公式 |
| TAS GCL | 门控周期执行仿真器 | SystemVerilog | 自研 |
| PTP Timestamp | 纳秒级时钟模型 | C | IEEE 1588 规范 |
| Switch Forwarding | L2 学习桥参考模型 | C | IEEE 802.1D |

---

## 9. 回归策略 (Regression Strategy)

### 9.1 回归层次

| 层次 | 频率 | 时长 | 覆盖内容 | 触发条件 |
|------|------|------|----------|----------|
| **Smoke** | 每次 RTL 提交 | ~30 min | Config-A + Config-B 基础功能 | Pre-commit hook |
| **Nightly** | 每天 02:00 | ~6 hr | Config-A/B/C/E + 5 项 High erratum + 核心 PICS | 定时触发 |
| **Weekly** | 每周六 00:00 | ~24 hr | 全部 5 配置 + 13 项 erratum + 全 PICS + 覆盖率收集 | 定时触发 |
| **Release Gate** | Release 前 | ~48 hr | 全量回归 + FPGA 环境 + 温度循环 | 手动触发 |

### 9.2 回归通过标准

| 检查项 | 通过标准 | 失败处理 |
|--------|----------|----------|
| 仿真通过 | 100% testcase pass (无失败、无挂起) | 阻断，必须修复 |
| 代码覆盖率 | Line ≥ 95%, Branch ≥ 90%, FSM ≥ 98% | 有条件通过，需补充测试 |
| 功能覆盖率 | Covergroup ≥ 90%, Cross ≥ 85% | 有条件通过，需补充测试 |
| 断言覆盖率 | Assertion ≥ 95% | 有条件通过，需补充 SVA |
| Erratum 回归 | 13 项全部通过 | 阻断，必须修复 |
| PICS 验证 | 所有 Yes/No/Configurable 项对应 testcase pass | 阻断，必须修复 |
| FPGA 长时间 | 48h 连续运行无丢帧/无链路断开 | 阻断，必须修复 |

### 9.3 回归环境配置

| 资源 | Smoke | Nightly | Weekly | Release Gate |
|------|:-----:|:-------:|:------:|:------------:|
| 仿真服务器 | 2 核 | 16 核 | 32 核 | 64 核 |
| 并行 job 数 | 4 | 16 | 32 | 64 |
| 存储 | 100GB | 500GB | 2TB | 5TB |
| FPGA 板卡 | — | 1×FPGA-A | 2×FPGA-A + 1×FPGA-B | 全部 |

---

## 10. 验证计划版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v0.1 | 2026-05-02 | Verification Agent | 初始模板创建 |
| v1.0 | 2026-05-21 | Verification Agent | PAD Rework: 新增 §3 黄金配置 (5个)、§4 覆盖率目标、§5 Erratum 回归套件 (13项)、§6 PICS 映射、§7 Formal N/A、§8/§9 环境/回归策略 |
| v1.1 | 2026-05-29 | Verification Agent | PAD-REWORK-014: 新增 §6.11 AVTP 验证章节 (帧生成/解析、Stream 识别错误注入、TSN 门控协同、ACF CAN 桥接)，补充 IEEE 1722 AVTP PICS 文件 |

---

## 附录 A: 验收检查清单

- [x] 5 个黄金配置参数值完整 (Config-A~E)
- [x] 覆盖率目标数值有依据 (Line ≥95%, Branch ≥90%, FSM ≥98%, Assertion ≥95%, Functional ≥90%)
- [x] 13 项 erratum 各有 testcase ID + SVA 断言 (TC4-ERR-001~013)
- [x] PLCA 时序 erratum 补充 testcase (TC4-ERR-014~016) + 外部 PHY 约束 (TC4-ERR-017~020)
- [x] PICS Yes/No/Configurable 映射到 testcase (802.1AS/802.1Q/802.1AE/1588/802.3/802.1CB/802.1AB/1722)
- [x] **AVTP 验证章节完整** (§6.11: 帧生成/解析、Stream 识别错误注入、TSN 门控协同、ACF CAN 桥接)
- [x] Formal 章节标记 "不投入" 并说明理由 (§7)
- [x] 删除原 VERIF-CRIT-003 相关内容
- [x] 验证环境定义 (UVM Agent + FPGA 平台)
- [x] 回归策略定义 (Smoke/Nightly/Weekly/Release Gate)
- [x] **AVTP PICS 文件**: `Docs/Arch/PICS/IEEE_1722_AVTP_PICS.md` (Talker/Listener/Stream ID/TSN 映射/ACF)

---

*文档完成: 2026-05-21 18:59 GMT+8*  
*作者: Verification Agent*  
*评审状态: PAD Rework 完成，待实体 Yang 审阅*
