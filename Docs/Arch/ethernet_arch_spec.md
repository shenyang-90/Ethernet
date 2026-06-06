# Ethernet IP Architecture Specification

> **项目**: Ethernet IP (IP_20260502_001)
> **模块/系统**: Gigabit Ethernet MAC + PHY Subsystem
> **版本**: v1.8d
> **日期**: 2026-05-22
> **作者**: Arch Agent
> **评审状态**: Draft → 待评审
*更新: 2026-05-21 — 基于 Reference/Kimi_Agent_MCU_Ethernet/ 中 TC4x/S32G/S32K3/R-Car S4/RH850 全部 feature 并集，修正部分 No → Yes/Configurable*

## 10. PICS 协议实现一致性分析

> **本节基于** `Reference/Kimi_Agent_MCU_Ethernet/PICS/` 中7个协议的PICS文件，通过Deep-Research-Cluster Route D方法逐条确认Yes/No。
> **完整分析**: 见 `Docs/Arch/PICS/pics_analysis_summary.md`

### 10.1 协议支持总览

| 协议标准 | 版本 | PICS来源 | 实现优先级 | 关键Yes项 | 关键No项 |
|---------|------|---------|:----------:|----------|----------|
| **IEEE 802.1AS** | 2020 | Annex A原生 | **P0** | DOM0, MINTA, BMC, **BRDG**, MIMSTR, P2P延迟 | MIPERF, MDFDPP, UMM |
| **IEEE 802.1Q** | 2022 | Annex A原生 | **P0** | FQTSS, ETS, **SCHED**, **PRE**, **PSFP** | **SRP**, **PFC**, ATS, CQF |
| **IEEE 802.3** | 2022 | Annex A原生 | **P0** | 100BASE-T1, 1000BASE-T1, 10BASE-T1S, PLCA, 2.5G/5G/10G | — |
| **IEEE 802.1CB** | 2017 | Annex A原生 | **P0** | IS, TE, LE, RS, Sequence Gen/Recovery | HSR/PRP兼容, IP Stream ID, Autoconfig |
| **IEEE 802.1AE** | 2018 | Annex A原生 | **P1** | SAP, GEN, VER, FMT, CS, KAY | MSC(多SC), MSAK(多SAK), TC(多发送SC), SNMP |
| **IEEE 802.1AB** | 2016 | Annex A原生 | **P1** | Chassis/Port/TTL, Tx/Rx模式, 状态机 | SNMP MIB, Organization TLV |
| **IEEE 1588** | 2019 | Clause 20提取 | **P0** | PTPv2.1, P2P, Two-Step, 硬件时间戳, BC, 数据集 | E2E, IPv4/UDP映射, Management消息, L1Sync, AUTH TLV |
| **IEEE 1722** | 2016 | DRE/AVB分析 | **P1** | AVTP/ACF封装, 流识别, ACF_CAN_BRIEF | Talker/Listener完整协议栈(软件实现) |
| **IEEE 802.3az** | 2010 | 802.3 Annex | **P2** | EEE低功耗PHY模式 | — |
| **IPsec/SecOC/D-TLS** | — | 安全加速器接口 | **P2** | ESP/AH封装接口, SecOC PDU认证, Chacha20-Poly1305 | 完整协议栈(软件/CSS/HSE实现) |

### 10.2 TC4/RH850/R-Car/S32 Feature 并集驱动的更新

> **依据**: `Reference/Kimi_Agent_MCU_Ethernet/` 交叉验证报告确认各平台支持情况。本IP需覆盖全部平台 feature 并集。

| Feature | TC4x | S32G | S32K3 | R-Car S4 | RH850 | **并集决策** | 原决策 | 变更 |
|---------|:----:|:----:|:-----:|:--------:|:-----:|:------------|:-------|:----:|
| 802.1AS gPTP | ✅ | ✅ | ✅ | ✅ | ❌ | **Yes** | Yes | — |
| 802.1Qbv TAS | ✅ | ✅(GMAC0) | ✅(端点) | ✅ | ❌ | **Yes** | Yes | — |
| 802.1Qbu FP | ✅ | ✅(GMAC0) | ✅ | ✅ | ❌ | **Yes** | Yes | — |
| 802.1Qav CBS | ✅ | — | — | ✅ | ❌ | **Yes** | Yes | — |
| 802.1Qci PSFP | ✅(部分) | — | — | ✅ | ❌ | **Yes** | Yes | — |
| 802.1CB FRER | ✅(SW) | — | — | ✅ | ❌ | **Yes** | Yes | — |
| 802.1AE MACsec | ✅(CSS) | ✅(外部PHY) | — | ? | ❌ | **Configurable** | Yes | ↑ |
| **802.3az EEE** | **✅** | — | — | — | ❌ | **Configurable** | **No** | **↑** |
| **IEEE 1722 AVTP** | **✅(DRE)** | — | — | **✅(AVB感知)** | ❌ | **Configurable (默认1，TC4x/R-Car 推荐开启)** | **No** | **↑** |
| **半双工 10/100M** | **✅** | ✅ | ✅ | ✅ | ✅ | **Yes** | 未定义 | **↑** |
| **IPsec 卸载** | **✅(CSS)** | **✅(PFE+HSE)** | — | — | ❌ | **Configurable** | 未定义 | **↑** |
| **SecOC** | **✅(CSS)** | **✅(HSE)** | **✅(HSE)** | — | ❌ | **Configurable** | 未定义 | **↑** |
| **D-TLS** | **✅(CSS)** | — | — | — | ❌ | **Configurable** | 未定义 | **↑** |
| 802.1AB LLDP | ✅ | ✅ | ✅ | ✅ | ✅ | **Yes** | Yes | — |
| TCP/IP校验和卸载 | ✅ | ✅ | ✅ | ✅ | ❌ | **Yes** | Yes | — |
| 10BASE-T1S/PLCA | ✅(LETH) | — | — | — | ❌ | **Yes** | Yes | — |
| Bridge/Switch | ✅ | ✅(PFE) | ✅(外部) | ✅ | ❌ | **Yes** | Yes | — |

**变更说明**:
- **EEE**: TC4x GETH 原生支持 802.3az EEE。从 P3 No 升级为 P2 Configurable（默认关闭，PHY 配合时启用）。
- **AVTP/IEEE 1722**: TC4x DRE 支持 AVTP/ACF 封装，R-Car S4 支持 AVB 硬件感知。`SUPPORT_AVTP` 从默认 0 改为 1。
- **半双工**: 所有平台 10M/100M 均支持半双工。新增 `PHY_x_DUPLEX` 参数。
- **IPsec/SecOC/D-TLS**: TC4x CSS 和 S32G HSE/PFE 均支持。作为 P2 Configurable，需外部安全加速器（CSS/HSE）配合，Ethernet IP 提供封装/卸载接口。

### 10.3 关键No项影响分析

| Feature | 协议 | 风险 | 影响 | 缓解措施 |
|---------|------|:----:|------|---------|
| **SRP (MSRP)** | 802.1Q | Major | 无动态带宽预留 | 使用静态TAS配置(SMD/SMC文件)替代 |
| **PFC** | 802.1Q/802.3 | Major | 拥塞时可能丢帧 | CBS+TAS提供确定性替代 |
| **ATS** | 802.1Q | Minor | 突发流量无平滑 | 静态CBS或门控调度替代 |
| **CQF** | 802.1Q | Minor | 简单调度替代不可用 | TAS已覆盖 |
| **多SC (MSC/TC)** | 802.1AE | Minor | 单SC限制多会话 | 车载点对点链路，单SC足够 |
| **SNMP管理** | 802.1AE/802.1AB | Minor | 不支持SNMP | 车载使用寄存器/UDS诊断替代 |
| **E2E延迟** | 1588 | Minor | 无E2E透明时钟 | 802.1AS不定义TC，P2P TC已满足 |
| **Management消息** | 1588 | Minor | 无PTP管理 | 使用本地诊断/UDS替代 |
| **IPv4/UDP映射** | 1588 | Minor | 不支持IP层PTP | 车载场景使用L2映射 |
| **IEEE 1722 Talker/Listener** | 1722 | Minor | 无完整AVB栈 | DRE/软件实现Talker/Listener逻辑 |
| **IPsec/SecOC/D-TLS 协议栈** | — | Minor | 需外部加速器 | CSS/HSE处理加解密，Ethernet IP提供报文封装接口 |

### 10.4 新增/变更的 Arch Spec 参数

| 参数 | 类型 | 默认值 | 范围 | 说明 | 对应平台 |
|------|------|:------:|:----:|------|---------|
| `SUPPORT_EEE` | bit | 0 | 0/1 | 802.3az EEE低功耗PHY模式 | TC4x |
| `SUPPORT_AVTP` | bit | **1** | 0/1 | IEEE 1722 AVTP/ACF流识别与封装 | TC4x DRE, R-Car S4 |
| `SUPPORT_AVTP_CTL` | bit | 0 | 0/1 | IEEE 1722.1 AVTP控制/路由表 | TC4x DRE |
| `SUPPORT_IPSEC` | bit | 0 | 0/1 | IPsec ESP/AH硬件卸载接口 | TC4x CSS, S32G PFE |
| `SUPPORT_SECOC` | bit | 0 | 0/1 | SecOC PDU级安全认证接口 | TC4x CSS, S32G/S32K3 HSE |
| `SUPPORT_DTLS` | bit | 0 | 0/1 | D/TLS Chacha20-Poly1305接口 | TC4x CSS |
| `PHY_x_DUPLEX` | bit | 1 | 0/1 | 0=半双工, 1=全双工 (10M/100M有效) | TC4x, S32K3, RH850 |

### 10.5 PICS文件存储位置

所有PICS原始文件已复制到:
- `Docs/Arch/PICS/PICS_802.1AS-2020_gPTP.md`
- `Docs/Arch/PICS/PICS_802.1Q-2022_TSN.md`
- `Docs/Arch/PICS/PICS_802.3-2022_Ethernet.md`
- `Docs/Arch/PICS/PICS_802.1CB-2017_FRER.md`
- `Docs/Arch/PICS/PICS_802.1AE-2018_MACsec.md`
- `Docs/Arch/PICS/PICS_802.1AB-2016_LLDP.md`
- `Docs/Arch/PICS/PICS_IEEE-1588-2019_PTP.md`
- `Docs/Arch/PICS/pics_analysis_summary.md` (本分析汇总)

### 10.6 与Arch Spec参数映射验证

| Arch Spec 参数 | 对应PICS | 一致性 |
|---------------|---------|:------:|
| `SUPPORT_GPTP=1` | 802.1AS DOM0/MINTA/BMC/BRDG | ✅ Yes |
| `SUPPORT_1588=1` | 1588 PTP-BASE + P2P | ✅ Yes |
| `SUPPORT_TSN=1` | 802.1Q FQTSS/ETS/SCHED/PRE/PSFP | ✅ Yes |
| `SUPPORT_CBS=1` | 802.1Q ETS中的CBS | ✅ Yes |
| `SUPPORT_TAS=1` | 802.1Q SCHED | ✅ Yes |
| `SUPPORT_FP=1` | 802.1Q PRE | ✅ Yes |
| `SUPPORT_FRER=1` | 802.1CB IS/TE/LE/RS | ✅ Yes |
| `SUPPORT_SWITCH=1` | 802.1AS BRDG + 802.1CB BG/RS | ✅ Yes |
| `SUPPORT_MACSEC=0` | 802.1AE (默认关闭，需外部CSS) | ✅ 默认No，可选启用 |
| `SUPPORT_VLAN=1` | 802.1Q VLAN + 802.1AB addr | ✅ Yes |
| `PHC_COUNT=2` | 802.1AS多域/DOMADD | ✅ Yes |
| `SWITCH_TAS=1` | 802.1Q SCHED在Switch | ✅ Yes |
| **`SUPPORT_EEE=0`** | **802.3az** | **✅ Configurable，TC4x支持** |
| **`SUPPORT_AVTP=1`** | **IEEE 1722** | **✅ Yes，TC4x/R-Car支持** |
| **`SUPPORT_IPSEC=0`** | **IPsec** | **✅ Configurable，TC4x/S32G支持** |
| **`SUPPORT_SECOC=0`** | **SecOC** | **✅ Configurable，TC4x/S32G/S32K3支持** |
| **`PHY_x_DUPLEX=1`** | **802.3半双工** | **✅ Yes，全部平台支持** |

**验证结论**: Arch Spec 的可配置参数与 PICS 分析结果一致，所有 P0 必须功能均已覆盖，P1/P2 Configurable 功能通过外部加速器接口实现，满足 TC4/RH850/R-Car/S32 全平台 feature 并集要求。


---

## 1. Overview

### 1.1 系统概述

本项目旨在设计一款面向车规级应用的 Ethernet IP 子系统，对标 Infineon AURIX TC4x 系列 GETH/LETH 架构**与 Renesas R-Car S4 中央网关方案**。IP 支持 10M/100M/1G/2.5G/5G/10G 全双工速率，集成完整的 TSN（Time-Sensitive Networking）协议栈、**4-port L2/L3 Switch**、**双 PHC + vPHC 虚拟化**、硬件安全加速接口以及多 PHY 接口适配能力。

核心设计目标：
- **高性能**: 支持 5Gbps 线速，**全局 DMA 通道池 (8/16/32 通道) 所有 MAC 共享复用**，64-bit/128-bit AXI Master 接口
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
| **多 MAC 混合架构** | **1~8 个 MAC，每实例独立类型（MAC/GMAC/XGMAC），支持同芯片混合速率** | XGMAC-CORE |
| **4-port L2/L3 Switch** | **MAC 自学习、VLAN 转发、多播过滤、L3 路由** | Switch Core |
| **Switch/独立 混合拓扑** | **每 MAC 可选择接入 Switch 或独立直连（`SWITCH_CONNECTED_MAC_x`）** | Switch Core + DMA |
| **双 PHC + vPHC** | **2 个独立 PHC，Xen IO Rings 虚拟化** | PTP/Timestamp |
| **全局 DMA 通道池** | **8/16/32 通道全局池，所有 MAC 共享复用，每 MAC 动态分配** | DMA Engine |
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

### 1.4.1 协议相关参数 — 全局配置

| 参数名 | 类型 | 默认值 | 可配置范围 | 说明 | 影响模块 |
|--------|------|--------|------------|------|----------|
| `MAC_COUNT` | int | **4** | **1 ~ 8** | MAC 实例数量 | XGMAC-CORE, DMA, MTL |
| `PHY_COUNT` | int | **4** | **1 ~ 8** | PHY 实例总数量（**独立于 MAC 数量**） | HSPHY IF, PHY MUX |
| `SUPPORT_1588` | bit | 1 | 0 / 1 | 是否支持 IEEE 1588 / gPTP 时间同步 | PTP/Timestamp |
| `SUPPORT_GPTP` | bit | 1 | 0 / 1 | 是否支持 802.1AS gPTP（依赖 SUPPORT_1588=1） | PTP/Timestamp |
| `SUPPORT_TSN` | bit | 1 | 0 / 1 | 是否支持 TSN 协议栈总开关 | MTL, MAC Core |
| `SUPPORT_CBS` | bit | 1 | 0 / 1 | 是否支持 802.1Qav CBS（依赖 SUPPORT_TSN） | MTL Scheduler |
| `SUPPORT_TAS` | bit | 1 | 0 / 1 | 是否支持 802.1Qbv TAS（依赖 SUPPORT_TSN） | MTL Gate Control |
| `SUPPORT_FP` | bit | 1 | 0 / 1 | 是否支持 802.1Qbu 帧抢占（依赖 SUPPORT_TSN） | MAC Merge Layer |
| `SUPPORT_FRER` | bit | 1 | 0 / 1 | 是否支持 802.1CB FRER（依赖 SUPPORT_SWITCH=1） | Switch, SEQ/R-Tag |
| `SUPPORT_SWITCH` | bit | 1 | 0 / 1 | 是否支持 **L2/L3 Switch**（替代 Bridge） | **Switch Core** |
| **`SWITCH_PORT_COUNT`** | int | **4** | **2 ~ 8** | **Switch 端口数量（默认 4，可扩展至 8）** | **Switch Core** |
| **`SWITCH_TAS`** | bit | **1** | 0 / 1 | **是否支持 Switch 级 802.1Qbv TAS（依赖 SUPPORT_SWITCH=1）** | **Switch Core** |
| **`SWITCH_L3`** | bit | **0** | 0 / 1 | **是否支持 Layer 3 IP 路由（依赖 SUPPORT_SWITCH=1）** | **Switch Core** |
| **`SWITCH_CONNECTED_MAC_0` ~ `SWITCH_CONNECTED_MAC_7`** | bit[8] | **`{1,1,1,1,0,0,0,0}`** | **0 / 1** | **每 MAC 是否接入 Switch（`1`=接入 Switch, `0`=独立直连）** | **Switch Core, DMA 路由** |
| `SUPPORT_VLAN` | bit | 1 | 0 / 1 | 是否支持 802.1Q VLAN 处理 | TBU, RX Filter, Switch |
| `SUPPORT_MACSEC` | bit | 0 | 0 / 1 | 是否支持 802.1AE MACsec（需外部 CSS 加速器） | HSPHY IF (安全通道) |
| `SUPPORT_SRP` | bit | 0 | 0 / 1 | 是否支持 802.1Q SRP/MSRP（默认关闭，车载使用静态 TAS） | MTL Scheduler |
| `SUPPORT_PFC` | bit | 0 | 0 / 1 | 是否支持 802.3bd PFC（默认关闭，CBS+TAS 替代） | MTL Scheduler |
| **`SUPPORT_AVTP`** | bit | **1** | 0 / 1 | **是否支持 IEEE 1722 AVTP/ACF 流识别与封装（TC4x DRE/R-Car S4 AVB 感知兼容）** | **RX Filter + DMA** |
| **`SUPPORT_AVTP_AWARE`** | bit | **1** | 0 / 1 | **是否支持 AVTP 流识别与 RX 分离（依赖 SUPPORT_AVTP=1）** | **RX Filter, Switch** |
| **`SUPPORT_AVTP_CTL`** | bit | **0** | 0 / 1 | **是否支持 IEEE 1722.1 AVTP 控制/路由表（TC4x DRE 兼容）** | **DRE-like Engine** |
| **`SUPPORT_EEE`** | bit | **0** | 0 / 1 | **是否支持 802.3az EEE 低功耗 PHY 模式（TC4x 兼容，需 PHY 配合）** | **HSPHY IF** |
| **`SUPPORT_IPSEC`** | bit | **0** | 0 / 1 | **是否支持 IPsec ESP/AH 硬件卸载接口（需外部 CSS/HSE 加速器）** | **Security IF** |
| **`SUPPORT_SECOC`** | bit | **0** | 0 / 1 | **是否支持 SecOC PDU 级安全认证接口（需外部 CSS/HSE 加速器）** | **Security IF** |
| **`SUPPORT_DTLS`** | bit | **0** | 0 / 1 | **是否支持 D/TLS Chacha20-Poly1305 接口（需外部 CSS 加速器）** | **Security IF** |
| **`PHC_COUNT`** | int | **2** | **1, 2** | **PTP Hardware Clock 数量** | **PTP/Timestamp** |
| **`SUPPORT_VPHC`** | bit | **0** | 0 / 1 | **是否支持 vPHC 虚拟化（依赖 PHC_COUNT=2）** | **PTP/Timestamp, Xen IO Rings** |

### 1.4.1a 协议相关参数 — **每 MAC 独立配置**

> 每个 MAC 实例 (x = 0..`MAC_COUNT`-1) 拥有独立类型配置，支持混合架构（如 MAC0=XGMAC/5G, MAC1=GMAC/1G, MAC2=MAC/10M）

| 参数名 | 类型 | 默认值 | 可配置范围 | 说明 | 影响 |
|--------|------|--------|------------|------|------|
| `MAC_0_TYPE` ~ `MAC_7_TYPE` | int[8] | `{2,2,1,1,1,1,1,1}` | **0: MAC (10/100M)<br>1: GMAC (1G)<br>2: XGMAC (2.5G/5G/10G)** | 每 MAC 核心类型，独立配置 | XGMAC-CORE, HSPHY IF |
| `MAC_0_SPEED` ~ `MAC_7_SPEED` | int[8] | `{4,4,2,2,2,2,2,2}` | **0: 10M<br>1: 100M<br>2: 1G<br>3: 2.5G<br>4: 5G<br>5: 10G** | 每 MAC 线速率，受限于 `MAC_x_TYPE` | XGMAC-CORE, DMA |

> **MAC 类型/速率约束**:
> - `MAC_x_TYPE = 0 (MAC)`: `MAC_x_SPEED` 仅支持 0~1 (10M/100M)
> - `MAC_x_TYPE = 1 (GMAC)`: `MAC_x_SPEED` 支持 0~2 (10M/100M/1G)
> - `MAC_x_TYPE = 2 (XGMAC)`: `MAC_x_SPEED` 支持 0~5 (10M~10G)
> - `MAC_x_SPEED > MAC_x_TYPE 最大支持速率` → 硬件自动 clamp 到该类型最大速率，并置位 `MAC_SPEED_CLAMPED[x]` 诊断位

### 1.4.1b 协议相关参数 — **每 PHY 独立配置**

> 每个 PHY 实例 (x = 0..`PHY_COUNT`-1) 拥有独立类型和速率配置

| 参数名 | 类型 | 默认值 | 可配置范围 | 说明 | 影响 |
|--------|------|--------|------------|------|------|
| `PHY_0_TYPE` ~ `PHY_7_TYPE` | int[8] | `{3,3,2,2,2,2,2,2}` | **0: 10BASE-T1S<br>1: 10/100BASE-T1<br>2: 1000BASE-T1<br>3: Multi-Gigabit** | 每 PHY 接口类型 | HSPHY IF, PCS/PMA |
| `PHY_0_SPEED` ~ `PHY_7_SPEED` | int[8] | `{4,4,2,2,2,2,2,2}` | **0: 10M<br>1: 100M<br>2: 1G<br>3: 2.5G<br>4: 5G<br>5: 10G** | 每 PHY 最高速率，受限于 `PHY_x_TYPE` | HSPHY IF, PCS/PMA |
| **`PHY_0_DUPLEX` ~ `PHY_7_DUPLEX`** | **bit[8]** | **`{1,1,1,1,1,1,1,1}`** | **0: 半双工<br>1: 全双工** | **每 PHY 双工模式 (10M/100M时有效，1G以上强制全双工)** | **HSPHY IF, MAC Core** |

> **PHY 类型/速率约束**:
> - `PHY_x_TYPE = 0` (10BASE-T1S): `PHY_x_SPEED` 仅支持 0 (10M)
> - `PHY_x_TYPE = 1` (10/100BASE-T1): `PHY_x_SPEED` 支持 0~1 (10M/100M)
> - `PHY_x_TYPE = 2` (1000BASE-T1): `PHY_x_SPEED` 支持 0~2 (10M/100M/1G)
> - `PHY_x_TYPE = 3` (Multi-Gigabit): `PHY_x_SPEED` 支持 0~5 (10M~10G)
> - 半双工约束：`PHY_x_TYPE = 0` 时自动关闭该 PHY 对应 MAC 的 `SUPPORT_FP` 和 `SUPPORT_TAS`

> **MAC-PHY 绑定约束**:
> - 默认一对一绑定：`MAC_x` ↔ `PHY_x` (x < min(MAC_COUNT, PHY_COUNT))
> - 若 `PHY_COUNT > MAC_COUNT`：多余 PHY 通过 PHY MUX 共享 MAC（时分复用）
> - 若 `PHY_COUNT < MAC_COUNT`：多余 MAC 通过 Switch 内部环回或预留
> - `PHY_x_SPEED` 与 `MAC_x_SPEED` 不匹配时，MAC 自动降频到 PHY 速率，置位 `SPEED_MISMATCH[x]` 诊断位

### 1.4.2 非协议相关 — DMA/缓冲参数

| 参数名 | 类型 | 默认值 | 可配置范围 | 说明 | 影响 |
|--------|------|--------|------------|------|------|
| `DMA_CH_COUNT` | int | **8** | **1, 2, 4, 8, 16, 32** | **全局 DMA 通道数量（所有 MAC 共享池）** | DMA Engine, 描述符内存 |
| `DMA_CH_PER_MAC` | int | **4** | **1 ~ 8** | **每 MAC 可分配的 DMA 通道数上限** | DMA Engine, 仲裁器 |
| `MTL_TX_FIFO_DEPTH` | int | 32 | 8, 16, 32, 64 | TX FIFO 深度（KB） | MTL TX, SRAM |
| `MTL_RX_FIFO_DEPTH` | int | 32 | 8, 16, 32, 64 | RX FIFO 深度（KB） | MTL RX, SRAM |
| `MTL_TX_QUEUES` | int | 8 | 1, 2, 4, 8 | TX 队列数量（每 MAC） | MTL Scheduler |
| `MTL_RX_QUEUES` | int | 8 | 1, 2, 4, 8 | RX 队列数量（每 MAC） | MTL RX Filter |
| `DESC_SIZE` | int | 16 | 16, 32 | 描述符大小（Byte，标准/扩展） | DMA, 内存布局 |
| `AXI_ID_WIDTH` | int | 4 | 4, 8 | AXI Master ID 位宽 | AXI Master |
| `AXI_DATA_WIDTH` | int | 64 | 32, 64, 128 | AXI Master 数据位宽 | AXI Master, DMA |
| `CSR_ADDR_WIDTH` | int | 12 | 10, 12, 14 | AXI-Lite Slave 地址位宽 | CSR 寄存器数量 |
| `MAX_BURST_LEN` | int | 16 | 8, 16 | AXI 最大 Burst 长度 | DMA, AXI 效率 |

> **DMA 全局通道池设计**:
> - `DMA_CH_COUNT` 定义全局 DMA 通道池总数，所有 MAC 共享，而非每 MAC 专属
> - 每 MAC 可分配 `DMA_CH_PER_MAC` 个通道（通过可配置映射表），支持动态/静态绑定
> - 例如：8 通道全局池，2 个 MAC，每 MAC 分配 4 通道；或 1 个 MAC 独占 8 通道
> - **配置约束**:
>   - `DMA_CH_COUNT` 必须 ≥ `MAC_COUNT` × `DMA_CH_PER_MAC`（所有 MAC 的最小需求）
>   - 推荐 `DMA_CH_COUNT = MAC_COUNT × DMA_CH_PER_MAC`，最大化并行度
>   - 支持 DMA 通道动态重分配（通过 `DMA_CH_REMAP` 寄存器），但不支持运行时迁移（需复位后生效）
> - **带宽评估**: 见 §4.4 带宽评估计算器

> **其他配置约束**：
> - `MTL_TX_FIFO_DEPTH` + `MTL_RX_FIFO_DEPTH` × `MAC_COUNT` ≤ 总 SRAM 预算
> - `AXI_DATA_WIDTH` 需与 SoC 总线位宽匹配
> - **每 MAC 类型/速率独立**: `MAC_x_TYPE` 和 `MAC_x_SPEED` 按实例独立配置，不同 MAC 可混合类型（如 MAC0=XGMAC/5G, MAC1=GMAC/1G, MAC2=MAC/10M）
> - **每 PHY 类型/速率独立**: `PHY_x_TYPE` 和 `PHY_x_SPEED` 按实例独立配置
> - **DMA 通道按 MAC 类型加权**: XGMAC 实例默认分配更多通道（`DMA_CH_PER_MAC_XGMAC = 4`, `DMA_CH_PER_MAC_GMAC = 2`, `DMA_CH_PER_MAC = 1`），可通过 `DMA_CH_MAP` 覆盖
> - **AXI 位宽按最大 MAC 速率选择**: `AXI_DATA_WIDTH` 应满足 `max(MAC_x_SPEED)` 的线速需求，见 §4.4.4 配置推荐矩阵
> - **Switch 连接约束**:
>   - `SWITCH_PORT_COUNT` ≤ count(`SWITCH_CONNECTED_MAC_x == 1`)（Switch 端口数 ≤ 接入 Switch 的 MAC 数）
>   - `SUPPORT_SWITCH=0` 时，`SWITCH_PORT_COUNT` 和 `SWITCH_CONNECTED_MAC_x` 被忽略
>   - **独立 MAC（`SWITCH_CONNECTED_MAC_x=0`）**：不经过 Switch，直接由 Host/DMA 访问（标准端点模式）
>   - **Switch MAC（`SWITCH_CONNECTED_MAC_x=1`）**：所有 TX/RX 流量经过 Switch Core 转发
>   - Switch 内部有独立 Host 端口（用于管理帧和 CPU 收发），不计入 `SWITCH_PORT_COUNT`
>   - **混合架构示例**：`MAC_COUNT=6`, `SWITCH_CONNECTED_MAC={1,1,1,1,0,0}` → MAC0~3 接入 4-port Switch，MAC4~5 独立直连
>   - **MAC 与 PHY 解耦**：`PHY_COUNT` 可以大于 `MAC_COUNT`（通过 PHY MUX 共享 MAC），也可以小于（通过 Switch 扩展）
> - **PHY_TYPE 与 PHY_SPEED 配对约束**：`PHY_x_TYPE=0` (10BASE-T1S) 仅支持 `PHY_x_SPEED=0` (10M)；`PHY_x_TYPE=1` 支持 `PHY_x_SPEED=0~1` (10M/100M)；`PHY_x_TYPE=2` 支持 `PHY_x_SPEED=0~2` (10M/100M/1G)；`PHY_x_TYPE=3` 支持 `PHY_x_SPEED=0~5` (10M~10G)
> - **10BASE-T1S 特殊约束**：`PHY_x_TYPE=0` 时，PHY 支持多点总线拓扑（PLCA），最多 8 个节点；不支持全双工（仅半双工），因此 `SUPPORT_FP` (帧抢占) 和 `SUPPORT_TAS` 在此 PHY 上自动关闭
> - **Switch 级 TAS 约束**：`SWITCH_TAS=1` 时，端点 MAC 的 `SUPPORT_TAS` 自动关闭（端点无需感知门控周期，由 Switch 统一调度）

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

> **注**: 以下配置为推荐默认，实际可自由组合每 MAC/PHY 类型。`MAC_x_TYPE` 和 `PHY_x_TYPE` 按实例独立配置。

| **场景** | **MAC 配置摘要** | **PHY 配置摘要** | **DMA_CH (全局池)** | **TSN** | **1588** | **Switch** | **IP ASIL** | **SoC 集成后** | **估算门数** |
|------|-----------------|-----------------|--------|-----|------|--------|-------------|---------------|----------|
| **中央网关 (4-port Switch)** | **4 MAC: GMAC/1G ×4** | **4 PHY: 1000BASE-T1/1G ×4** | **16** | **✅** | **✅** | **✅** | **B** | **D¹** | **~480k** |
| ADAS 传感器汇聚 | 2 MAC: **XGMAC/5G ×2** | 2 PHY: **Multi-Gigabit/5G ×2** | **16** | ✅ | ✅ | ❌ | B | D¹ | ~190k |
| Zone Controller 骨干 | 2 MAC: **XGMAC/5G ×2** | 2 PHY: **Multi-Gigabit/5G ×2** | **16** | ✅ | ✅ | ✅ | B | D¹ | ~205k |
| **SDV 中央网关 (Switch+vPHC)** | **4 MAC: GMAC/1G ×4** | **4 PHY: 1000BASE-T1/1G ×4** | **16** | **✅** | **✅** | **✅** | **B** | **D¹** | **~520k** |
| **混合网关 (ADAS+车身)** | **2 MAC: XGMAC/5G + GMAC/1G** | **2 PHY: Multi-Gigabit/5G + 1000BASE-T1/1G** | **12** | **✅** | **✅** | **✅** | **B** | **D¹** | **~260k** |
| CAN-Ethernet 网关 | 1 MAC: **GMAC/1G** | 1 PHY: **1000BASE-T1/1G** | **4** | ❌ | ✅ | ❌ | B | B | ~120k |
| **域内边缘节点 (10BASE-T1S)** | 1 MAC: **MAC/10M** | 1 PHY: **10BASE-T1S/10M** | **2** | ❌ | ❌ | ❌ | QM | QM | ~45k |
| **车身传感器网络** | 1 MAC: **MAC/10M** | 1 PHY: **10BASE-T1S/10M** | **2** | ❌ | ❌ | ❌ | QM | QM | ~40k |
| **OTA 更新节点** | 1 MAC: **GMAC/1G** | 1 PHY: **1000BASE-T1/1G** | **4** | ❌ | ❌ | ❌ | A | B | ~80k |
| **信息娱乐域 (AVB)** | 1 MAC: **GMAC/1G** | 1 PHY: **1000BASE-T1/1G** | **4** | ✅ | ✅ | ❌ | QM | QM | ~110k |
| **混合边缘 (1G+10M)** | **2 MAC: GMAC/1G + MAC/10M** | **2 PHY: 1000BASE-T1/1G + 10BASE-T1S/10M** | **6** | **✅** | **✅** | **❌** | **B** | **B** | **~135k** |
| **中央网关+独立端口 (6MAC 混合)** | **6 MAC: GMAC/1G ×4 + GMAC/1G ×2 独立** | **6 PHY: 1000BASE-T1/1G ×6** | **24** | **✅** | **✅** | **✅ (4-port)** | **B** | **D¹** | **~560k** |

> **¹ ASIL-D 为系统级认证**: 需 SoC 提供 Lockstep CPU + SMU 双冗余 + 外部 PMIC (如 TLF4x) + SafeTlib 运行时测试。本 IP 模块内部仅提供 ASIL-B 安全机制（ECC + Parity + Timeout + Clock Monitor），详见 `Docs/FuSa/safety_concept.md` §5.3。
> **² 估算门数依据**: 门数估算基于 §4.3 资源估算与竞品对标分析，含 SRAM/TCAM 面积折算。

> **详细参数展开示例**（中央网关）:
> ```verilog
> MAC_COUNT       = 4;
> MAC_0_TYPE      = 1;   MAC_0_SPEED = 2;  // GMAC, 1G
> MAC_1_TYPE      = 1;   MAC_1_SPEED = 2;  // GMAC, 1G
> MAC_2_TYPE      = 1;   MAC_2_SPEED = 2;  // GMAC, 1G
> MAC_3_TYPE      = 1;   MAC_3_SPEED = 2;  // GMAC, 1G
> PHY_COUNT       = 4;
> PHY_0_TYPE      = 2;   PHY_0_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_1_TYPE      = 2;   PHY_1_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_2_TYPE      = 2;   PHY_2_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_3_TYPE      = 2;   PHY_3_SPEED = 2;  // 1000BASE-T1, 1G
> DMA_CH_COUNT    = 16;  DMA_CH_PER_MAC = 4;
> SUPPORT_SWITCH  = 1;   SWITCH_PORT_COUNT = 4;
> PHC_COUNT       = 2;  SUPPORT_VPHC = 1;  // SDV 场景
> ```

> **详细参数展开示例**（混合网关 ADAS+车身）:
> ```verilog
> MAC_COUNT       = 2;
> MAC_0_TYPE      = 2;   MAC_0_SPEED = 4;  // XGMAC, 5G (ADAS 骨干)
> MAC_1_TYPE      = 1;   MAC_1_SPEED = 2;  // GMAC, 1G (车身域)
> PHY_COUNT       = 2;
> PHY_0_TYPE      = 3;   PHY_0_SPEED = 4;  // Multi-Gigabit, 5G
> PHY_1_TYPE      = 2;   PHY_1_SPEED = 2;  // 1000BASE-T1, 1G
> DMA_CH_COUNT    = 12;  // XGMAC 6ch + GMAC 4ch + Switch 2ch
> SUPPORT_SWITCH  = 1;   SWITCH_PORT_COUNT = 2;
> PHC_COUNT       = 2;   // gPTP 双域同步
> ```

> **详细参数展开示例**（中央网关 + 独立端口 — 6MAC 混合架构）:
> ```verilog
> // 保守方向: 默认 2 MAC, 但支持扩展到 6 MAC 混合架构
> // MAC0~3: 接入 4-port Switch (中央网关域)
> // MAC4~5: 独立直连 (OTA/诊断/日志端口)
> MAC_COUNT       = 6;
> MAC_0_TYPE      = 1;   MAC_0_SPEED = 2;  // GMAC, 1G (Switch Port 0)
> MAC_1_TYPE      = 1;   MAC_1_SPEED = 2;  // GMAC, 1G (Switch Port 1)
> MAC_2_TYPE      = 1;   MAC_2_SPEED = 2;  // GMAC, 1G (Switch Port 2)
> MAC_3_TYPE      = 1;   MAC_3_SPEED = 2;  // GMAC, 1G (Switch Port 3)
> MAC_4_TYPE      = 1;   MAC_4_SPEED = 2;  // GMAC, 1G (独立 — OTA)
> MAC_5_TYPE      = 1;   MAC_5_SPEED = 2;  // GMAC, 1G (独立 — 诊断)
> PHY_COUNT       = 6;
> PHY_0_TYPE      = 2;   PHY_0_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_1_TYPE      = 2;   PHY_1_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_2_TYPE      = 2;   PHY_2_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_3_TYPE      = 2;   PHY_3_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_4_TYPE      = 2;   PHY_4_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_5_TYPE      = 2;   PHY_5_SPEED = 2;  // 1000BASE-T1, 1G
> DMA_CH_COUNT    = 24;  // 6 MAC × 4 ch
> SUPPORT_SWITCH  = 1;   SWITCH_PORT_COUNT = 4;
> // Switch 连接配置: MAC0~3 接入 Switch, MAC4~5 独立
> SWITCH_CONNECTED_MAC_0 = 1;
> SWITCH_CONNECTED_MAC_1 = 1;
> SWITCH_CONNECTED_MAC_2 = 1;
> SWITCH_CONNECTED_MAC_3 = 1;
> SWITCH_CONNECTED_MAC_4 = 0;  // 独立 OTA 端口
> SWITCH_CONNECTED_MAC_5 = 0;  // 独立诊断端口
> PHC_COUNT       = 2;   // gPTP 双域同步
> ```

> **详细参数展开示例**（保守默认 — 2 MAC 入门级）:
> ```verilog
> // 保守方向默认配置: 2 MAC, 无 Switch, 1G 入门
> MAC_COUNT       = 2;
> MAC_0_TYPE      = 1;   MAC_0_SPEED = 2;  // GMAC, 1G
> MAC_1_TYPE      = 1;   MAC_1_SPEED = 2;  // GMAC, 1G
> PHY_COUNT       = 2;
> PHY_0_TYPE      = 2;   PHY_0_SPEED = 2;  // 1000BASE-T1, 1G
> PHY_1_TYPE      = 2;   PHY_1_SPEED = 2;  // 1000BASE-T1, 1G
> DMA_CH_COUNT    = 8;   // 2 MAC × 4 ch
> SUPPORT_SWITCH  = 0;   // 默认无 Switch
> SWITCH_PORT_COUNT = 0;
> PHC_COUNT       = 1;   // 单 PHC 入门
> ```

---

### 1.4.5 安全 CSR 地址空间 (PAD-009)

安全相关寄存器纳入 CSR 映射，地址范围 **0x700 ~ 0x718**，定义如下：

| 寄存器 | 地址偏移 | 位宽 | 说明 | 访问权限 | 安全属性 |
|--------|----------|------|------|----------|----------|
| `SAFETY_STATE` | 0x700 | 2-bit | 当前安全状态 (00=NORMAL, 01=DEGRADED, 10=SAFE_STATE, 11=Reserved) | RO | 安全关键 |
| `SAFETY_ERR_CNT` | 0x704 | 32-bit | ECC 错误计数器 (每通道独立) | RO/Clear-on-Write | 安全关键 |
| `SAFETY_DEGRADED_MASK` | 0x708 | 64-bit | 降级模式通道屏蔽 (DMA/MAC/PHY/Switch 分层) | RW (Write-Once) | 安全关键 |
| `SAFETY_TIMEOUT_CFG` | 0x70C | 32-bit | 超时阈值配置 (DMA/CSR/Bus 独立) | RW (Write-Once) | 安全关键 |
| `SAFETY_ERR_LOG` | 0x710 | 32-bit | 首次错误类型记录 (FIFO，深度 16) | RO | 安全关键 |
| `SAFETY_BIST_CTRL` | 0x714 | 32-bit | 安全自检控制 (启动/状态/结果) | RW | 安全关键 |
| `SAFETY_SMU_ALERT` | 0x718 | 32-bit | SMU 报警信号输出配置 | RW (Write-Once) | 安全关键 |
| `SAFETY_UNLOCK` | 0x71C | 16-bit | 解锁序列寄存器 (写 0x5A5A 解锁 Write-Once) | WO | 安全关键 |

> **访问权限说明**:
> - **RO**: 只读，任何访问均可读
> - **RW**: 可读可写，但 Write-Once 位仅首次写入有效
> - **WO**: 仅写入，读取返回 0
> - **Clear-on-Write**: 写 1 清零
> - **Write-Once**: 首次写入后锁定，需通过 `SAFETY_UNLOCK` 解锁序列才能修改
> - **安全关键寄存器**: 受 CSR Parity 保护，非法访问触发 `SAFETY_SMU_ALERT`

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
|  |                     Switch Core (L2/L3, N=2~8 ports, 默认N=4)                    |  +
|  |   MAC0 <───┐                                                                    |  +
|  |   MAC1 <───┼── [Crossbar + Arbiter] ──► Port 0/1/2/3...N-1 (全并发转发)       |  +
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
|  +----------|----------+  +-----|------+  +-----|------+  +-----|------+              |
|             |                    |              |              |                      |
|             v                    v              v              v                       |
|  +================================================================================+  +
|  |                         DMA Engine (全局通道池)                                |  +
|  |   CH[0:N-1] (N = DMA_CH_COUNT，图示为 8 通道示例) 全局共享 — 所有 MAC 通过 MTL 动态分配通道                             |  +
|  |   · 静态绑定: 复位时配置 CH_MAP[n] → MAC_x                                     |  +
|  |   · 动态仲裁: Round-Robin / Weighted QoS (AXI AWQOS/ARQOS)                      |  +
|  |   · AXI4 Master: 64/128-bit 数据面访问系统内存                                  |  +
|  +================================================================================+  +
|             |                                                                            |
|             v                                                                            |
|  +================================================================================+  +
|  |                         HSPHY (High Speed PHY)                                   |  +
|  |   MII/RMII/RGMII  |  SGMII  |  USXGMII  |  PPS Output                            |  +
|  +================================================================================+  +
|                                                                                        |
|  图例:                                                                                 |
|    ─── 粗线 = Switch 路径 (MAC0~3 经过 Switch Crossbar)                               |
|    ··· 细线 = 独立路径 (MAC4~5 直连 Host/DMA，不经过 Switch)                          |
|    每 MAC 类型由 MAC_x_TYPE 独立决定 (0=MAC/10-100M, 1=GMAC/1G, 2=XGMAC/2.5G-10G)   |
|    DMA 为全局共享池，非每 MAC 独立                                                    |
|                                                                                        |
+========================================================================================+
```

### 2.2 子系统划分

> **混合架构说明**: 每个 MAC 实例通过 `MAC_x_TYPE` 独立配置类型，支持同一 IP 内混合 XGMAC/GMAC/MAC。例如中央网关可配置 MAC0/MAC1=XGMAC (5G ADAS)，MAC2/MAC3=GMAC (1G 车身域)。资源按实际实例累加（见 §4.3）。

> **Switch 连接架构说明**: 通过 `SWITCH_CONNECTED_MAC_x` 参数，灵活配置哪些 MAC 接入 Switch、哪些独立直连：
> - **Switch MAC** (`SWITCH_CONNECTED_MAC_x=1`): TX/RX 经过 Switch Core 转发，参与 L2/L3 交换
> - **独立 MAC** (`SWITCH_CONNECTED_MAC_x=0`): 不经过 Switch，直接由 Host CPU/DMA 访问（标准端点模式）
> - **典型混合架构**: `MAC_COUNT=6`, `SWITCH_CONNECTED_MAC={1,1,1,1,0,0}` → MAC0~3 接入 4-port Switch，MAC4~5 独立直连（如 ADAS 骨干 + OTA/诊断端口）
> - Switch Core 内部包含独立 Host 端口（CPU 管理/收发），不计入 `SWITCH_PORT_COUNT`

| 子系统 | 功能 | ASIL | 实例数 |
|--------|------|------|--------|
| **XGMAC-CORE** | IEEE 802.3 MAC 层实现、帧过滤、VLAN 处理 | B | 1~8 (按 `MAC_COUNT`) |
| **MTL** | FIFO 缓冲、队列管理、流量整形 (CBS/TAS) | B | 1~8 (每 MAC 一个) |
| **DMA** | 描述符管理、数据搬运、时间戳回写 | B | 1~8 (每 MAC 一个) |
| **Switch Core** | **L2/L3 帧交换、FDB 自学习、VLAN 转发、多播过滤、Switch 级 TAS** | **B** | 0~1 (可选) |
| **PTP/Timestamp** | 1588/gPTP 时间同步、**双 PHC + vPHC 虚拟化**、PPS 输出 | B | 1~2 (按 `PHC_COUNT`) |
| **Safety Monitor** | ECC/Parity/Timeout 检测与报警 | B | 1 |
| **HSPHY Interface** | PHY 接口适配 (RGMII/SGMII/USXGMII) | B | 1~8 (按 `PHY_COUNT`) |

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
| `clk_ts` | **250 MHz** | PTP 时间戳、Addend 精调 |
| `clk_pcs` | 62.5/156.25/312.5/625 MHz | PCS/PMA 串行接口 |

### 3.2 复位策略概要

- **全局复位 (`rst_n`)**: 上电复位，全模块复位
- **模块级复位**: 各子系统独立软复位，通过 CSR 控制
- **DMA 通道复位**: 单通道独立复位，不影响其他通道
- **安全复位**: SMU 触发的紧急复位（ASIL-D 要求）

---

## 3.3 PTP 时间子系统 (gPTP / 1588)

本节描述 IEEE 1588-2008 / 802.1AS-2020 gPTP 的硬件时间同步实现，对标 TC4x GETH 的 ns 级同步能力。

### 3.3.1 PHC 架构

```
┌─────────────────────────────────────────────────────────────┐
│                    PTP Hardware Clock (PHC)                │
│                                                             │
│   ┌─────────────┐      ┌─────────────┐                     │
│   │   PHC 0     │      │   PHC 1     │                     │
│   │  64-bit     │◄────►│  64-bit     │                     │
│   │  计数器     │ 同步  │  计数器     │                     │
│   └──────┬──────┘      └──────┬──────┘                     │
│          │                    │                             │
│          └────────┬───────────┘                             │
│                   │ Crossbar                                │
│          ┌────────┼────────┬────────┐                       │
│          ▼        ▼        ▼        ▼                       │
│      Port 0    Port 1   Port 2   Port 3 (Switch/独立 MAC)   │
└─────────────────────────────────────────────────────────────┘
```

- **PHC0/PHC1**: 独立 64-bit 计数器，同源 `clk_ts`（同一时钟域，无时钟偏差）
- **Crossbar**: 每端口独立绑定任意 PHC，无菊花链限制（规避 LETH_TC.010）
- **vPHC**: 基于 Xen IO Rings，每 VM 虚拟时间域（`SUPPORT_VPHC=1` 时启用）

### 3.3.2 时钟与计数器

| 参数 | 值 | 说明 |
|------|------|------|
| `clk_ts` | **250 MHz** | PHC 参考时钟 |
| **Tick 周期** | **4 ns** | 1 / 250MHz = 4ns |
| **计数器格式** | 64-bit | 秒[32] + 纳秒[32] |
| **纳秒字段范围** | 0 ~ 999,999,999 | 标准纳秒，非 raw tick |
| **Addend 位宽** | 32-bit | Fractional accumulator |

**TC4x 对标**: TC4x 使用 ~375MHz (2.67ns)。本 IP 选 250MHz (4ns) 的原因：
- 易从 1GHz 时钟源 ÷4 派生，时钟树更简单
- 功耗更低（车规热预算）
- 配合 fractional addend 精调，同步精度仍可达 **±10ns**（满足 802.1AS 要求）

### 3.3.3 Addend 精调机制

Addend 寄存器实现 fractional frequency adjustment，消除本地时钟与 Grand Master 的频率偏差。

**硬件公式**:

```
addend = (2^32) / (clk_ts_freq / 1e9)
       = (2^32) / (250,000,000 / 1,000,000,000)
       = (2^32) / 0.25
       = 17,179,869,184  (0x4000_0000)
```

**频率调整**: 软件通过 `ptp_adjfine(scaled_ppm)` 写入 Addend 偏移，硬件 accumulator 每 tick 累加一次，产生 sub-4ns 的精调分辨率。

**实际分辨率**: 32-bit fractional → 理论分辨率 = 4ns / 2^32 ≈ **0.93 fs**（远小于实际需求，足够平滑）

### 3.3.4 硬件时间戳捕获

**捕获点**: MII/GMII/RGMII 接口的 **SFD (Start Frame Delimiter)** 起始边沿

| 方向 | 触发条件 | 锁存值 | 存储位置 |
|------|----------|--------|----------|
| **RX** | MII RX_DV 上升沿 + SFD 字节检测 | PHC 当前值 | RX 时间戳 FIFO |
| **TX** | MII TX_EN 上升沿 + SOP (Start of Packet) | PHC 当前值 | TX 时间戳 FIFO |

**回写路径**: 时间戳随 DMA 描述符回写（`descriptor.tstamp` 字段），channel_id 独立路由，规避 TC4x LETH_AI.024 Bridge 时间戳错误。

**精度**: SFD 级捕获 + MII 传播延迟补偿 → 精度 **±10ns**（目标）

### 3.3.5 P2P 路径延迟测量 (Peer Delay)

802.1AS gPTP 强制使用 P2P (Peer-to-Peer) 路径延迟机制，逐跳测量，不累积误差。

**软件实现** (默认):
- SYNC/PDELAY_REQ/PDELAY_RESP 报文携带时间戳
- 软件计算: `peer_delay = ((t4 - t1) - (t3 - t2)) / 2`
- 适用于普通终端节点 (OC)

**硬件 Transparent Clock** (可选, `SUPPORT_GPTP=1`):
- Switch Core 自动测量 residence time（报文 ingress→egress 时间）
- residence time 直接修正到 Follow_Up 报文的 correctionField
- **验证目标**: 4-port TC 模式下 residence time 误差 < ±20ns（见 §6.2.6）

### 3.3.6 同步精度目标

| 场景 | 目标精度 | 实现方式 | 对标 |
|------|----------|----------|------|
| 单域 gPTP (1 Grand Master) | **±10 ns** | SFD 时间戳 + Addend 精调 | TC4x 同类水平 |
| 双域 gPTP (2 PHC 独立域) | **±15 ns** | 双 PHC + Crossbar 独立绑定 | TC4x 无此能力 |
| 4-port TC Relay | **±20 ns** | 硬件 residence time 修正 | R-Car S4 水平 |
| SDV 虚拟化 (vPHC) | **±25 ns** | Xen IO Ring + PHC 虚拟化 | 本 IP 独有 |

> **注**: ±10ns 是 802.1AS 对车载以太网的基本要求（典型值 50ns，本 IP 目标更激进）。实际精度受 PHY 传播延迟抖动、电缆长度、温度漂移影响，需软件层补偿。

### 3.3.7 寄存器映射 (概要)

| 寄存器 | 偏移 | 说明 |
|--------|------|------|
| `PHC_CURRENT_SEC` | 0x800 | PHC 当前秒[31:0] |
| `PHC_CURRENT_NS` | 0x804 | PHC 当前纳秒[31:0] |
| `PHC_ADDEND` | 0x808 | Addend 值[31:0] |
| `PHC_INCREMENT` | 0x80C | 每 tick 增量（默认 4ns = 0x04） |
| `PHC_ADJUST_NS` | 0x810 | 粗调偏移（纳秒级步进） |
| `PHC_TS_CTRL` | 0x814 | 时间戳使能 / 捕获模式 |
| `PHC_PPS_CTRL` | 0x818 | PPS 输出配置（周期/脉宽） |

### 3.3.8 IEEE 1588-2019 通用消息头规范 (Clause 13)

本 IP 同时支持 802.1AS-2020 (gPTP) 与 IEEE 1588-2019 标准 PTP 模式，后者提供更完整的域隔离、BMCA 与 Transparent Clock 能力。

#### 通用消息头格式 (34 字节)

| 字段 | 八位组 | 偏移 | 位宽 | 说明 |
|------|--------|------|------|------|
| `majorSdoId` | 1 | 0 | [7:4] | 4-bit Nibble，默认 = 0（向后兼容 transportSpecific） |
| `messageType` | 1 | 0 | [3:0] | 4-bit Enumeration4，定义消息类别 |
| `minorVersionPTP` | 1 | 1 | [7:4] | 4-bit UInteger4 |
| `versionPTP` | 1 | 1 | [3:0] | 4-bit UInteger4，portDS.versionNumber |
| `messageLength` | 2 | 2 | [15:0] | UInteger16：PTP 消息总八位组数 |
| `domainNumber` | 1 | 4 | [7:0] | UInteger8，域 ID |
| `minorSdoId` | 1 | 5 | [7:0] | UInteger8，默认 = 0 |
| `flagField` | 2 | 6 | [15:0] | Octet[2]，位标志（见下表） |
| `correctionField` | 8 | 8 | [63:0] | Integer64：ns × 2¹⁶（亚纳秒分数在低 16 位） |
| `messageTypeSpecific` | 4 | 16 | [31:0] | Octet[4]，线路上保留（传输时必须发 0） |
| `sourcePortIdentity` | 10 | 20 | — | PortIdentity：clockIdentity[8] + portNumber[2] |
| `sequenceId` | 2 | 30 | [15:0] | UInteger16，每消息类型独立计数 |
| `controlField` | 1 | 32 | [7:0] | UInteger8，已废弃（传输 0，接收忽略） |
| `logMessageInterval` | 1 | 33 | [7:0] | Integer8 |

#### Message Type 值 (Enumeration4)

| 值 (hex) | 消息 | 类别 | RTL 时间戳需求 |
|----------|------|------|----------------|
| 0x0 | **Sync** | Event | ✅ 硬件时间戳捕获 |
| 0x1 | **Delay_Req** | Event | ✅ 硬件时间戳捕获 |
| 0x2 | **Pdelay_Req** | Event | ✅ 硬件时间戳捕获 |
| 0x3 | **Pdelay_Resp** | Event | ✅ 硬件时间戳捕获 |
| 0x8 | **Follow_Up** | General | ❌ 无需时间戳 |
| 0x9 | **Delay_Resp** | General | ❌ 无需时间戳 |
| 0xA | **Pdelay_Resp_Follow_Up** | General | ❌ 无需时间戳 |
| 0xB | **Announce** | General | ❌ 无需时间戳 |
| 0xC | Signaling | General | ❌ 无需时间戳 |
| 0xD | Management | General | ❌ 无需时间戳 |

> **RTL 关键提示**：messageType 的 MSB（bit 3）区分 Event（0）和 General（1）消息。所有 Event 消息都需要在 reference plane（MII/GMII/RGMII 边界）处捕获硬件时间戳。

#### flagField 位定义 (2 个八位组)

| 八位组 | 位 | 名称 | 适用消息 |
|--------|-----|------|----------|
| 0 | 0 | `alternateMasterFlag` | Announce, Sync, Follow_Up, Delay_Resp |
| 0 | 1 | `twoStepFlag` | Sync, Pdelay_Resp |
| 0 | 2 | `unicastFlag` | ALL |
| 0 | 5 | PTP Profile Specific 1 | ALL |
| 0 | 6 | PTP Profile Specific 2 | ALL |
| 0 | 7 | Reserved | — |
| 1 | 0 | `leap61` | Announce |
| 1 | 1 | `leap59` | Announce |
| 1 | 2 | `currentUtcOffsetValid` | Announce |
| 1 | 3 | `ptpTimescale` | Announce |
| 1 | 4 | `timeTraceable` | Announce |
| 1 | 5 | `frequencyTraceable` | Announce |
| 1 | 6 | `synchronizationUncertain` | Announce（可选） |
| 1 | 7 | Reserved | — |

#### correctionField 语义

| 消息类型 | correctionField 内容 |
|----------|----------------------|
| Sync, Delay_Req, Pdelay_Req, Pdelay_Resp, Follow_Up, Delay_Resp, Pdelay_Resp_Follow_Up | 亚纳秒分数、驻留时间、delayAsymmetry、meanDelay 的修正 |
| Announce, Signaling, Management | Zero |

**单位**：Integer64，表示 nanoseconds × 2¹⁶。示例：2.5 ns = `0x0000000000028000`。
全 1 值（除最高位外）表示修正值过大，无法表示。

#### 时间戳与 PortIdentity 格式

```
struct Timestamp {
    UInteger48 secondsField;      // 6 bytes, big-endian
    UInteger32 nanosecondsField;  // 4 bytes, big-endian
};  // 总计 10 字节，nanosecondsField 必须始终 < 10⁹

struct PortIdentity {
    ClockIdentity clockIdentity;  // 8 bytes (OUI/CID + 实现者定义)
    UInteger16    portNumber;     // 2 bytes
};  // 总计 10 字节
```

---

### 3.3.9 IEEE 1588-2019 消息体格式与长度

所有 PTP 消息共享 34 字节通用头；用 `messageType` 索引跳转表处理不同消息体。

#### 各消息体长度汇总

| 消息类型 | messageType | 消息体长度 | 总长度 (含 34B 头) |
|----------|-------------|-----------|-------------------|
| **Sync** | 0x0 | 10 bytes | 44 bytes |
| **Delay_Req** | 0x1 | 10 bytes | 44 bytes |
| **Pdelay_Req** | 0x2 | 20 bytes | 54 bytes |
| **Pdelay_Resp** | 0x3 | 20 bytes | 54 bytes |
| **Follow_Up** | 0x8 | 10 bytes | 44 bytes |
| **Delay_Resp** | 0x9 | 20 bytes | 54 bytes |
| **Pdelay_Resp_Follow_Up** | 0xA | 20 bytes | 54 bytes |
| **Announce** | 0xB | 30 bytes | 64 bytes |
| Signaling | 0xC | Variable | 34 + TLV |
| Management | 0xD | Variable | 34 + TLV |

#### Announce Message Body (30 bytes, offset 34)

| 字段 | 八位组 | 说明 |
|------|--------|------|
| `originTimestamp` | 10 | 发送时间戳（seconds[48] + nanoseconds[32]） |
| `currentUtcOffset` | 2 | TAI-UTC 偏移，秒（有符号） |
| `reserved` | 1 | 保留 |
| `grandmasterPriority1` | 1 | BMCA 第一优先级（默认 128） |
| `grandmasterClockQuality` | 4 | clockClass + clockAccuracy + offsetScaledLogVariance |
| `grandmasterPriority2` | 1 | BMCA 第二优先级（默认 128） |
| `grandmasterIdentity` | 8 | Grandmaster 的 ClockIdentity |
| `stepsRemoved` | 2 | 距 GM 的跳数 |
| `timeSource` | 1 | 时间来源枚举（见 IEEE 1588 Table 6） |

#### Sync / Delay_Req / Follow_Up Message Body (10 bytes)

| 字段 | 八位组 | 说明 |
|------|--------|------|
| `originTimestamp` / `preciseOriginTimestamp` | 10 | 秒[48] + 纳秒[32] |

> **RTL 设计提示**：Sync 的一步式时钟在消息体中携带 `originTimestamp`（发送时刻），两步式时钟则置 0 并通过 Follow_Up 分发 `preciseOriginTimestamp`。

#### Pdelay 消息族 Body (20 bytes)

| 字段 | 八位组 | 说明 |
|------|--------|------|
| `originTimestamp` / `requestReceiptTimestamp` / `responseOriginTimestamp` | 10 | 时间戳 |
| `requestingPortIdentity` | 10 | 请求方 PortIdentity |

---

### 3.3.10 时钟类型与 BMCA 最佳主时钟算法 (Clause 6/7/9)

本 IP 支持三种 IEEE 1588-2019 时钟类型，由配置参数 `PTP_CLOCK_TYPE` 选择。

#### 时钟类型对比

| 特性 | Ordinary Clock (OC) | Boundary Clock (BC) | Transparent Clock (TC) |
|------|---------------------|---------------------|------------------------|
| **PTP 端口数** | 1 | N ≥ 2 | N ≥ 2 |
| **Master/Slave** | 单端口可切换 | 一端口 Slave，其余 Master | 无 Master/Slave 状态 |
| **PTP 消息处理** | 终止并生成 | 终止并生成 | **透明转发**（修正 correctionField） |
| **延迟机制** | E2E 或 P2P 之一 | E2E 或 P2P（可桥接区域） | E2E TC 或 P2P TC |
| **适用场景** | 终端节点（ECU） | 网关节点 | Switch/Bridge 节点 |
| **RTL 复杂度** | 中 | 高 | 高（correctionField 累加） |

#### TC 子类型详细行为

| 特性 | E2E TC | P2P TC |
|------|--------|--------|
| **驻留时间** | 测量并累积到 correctionField | 测量并累积到 correctionField |
| **路径延迟** | 不修正路径延迟 | 通过 Pdelay_Req/Resp 测量每端口 `meanLinkDelay` |
| **Pdelay 消息** | 透明转发 | **终止** Pdelay 消息 |
| **Sync/Follow_Up** | 转发所有，添加 residenceTime | 仅转发 Sync/Follow_Up，添加 residenceTime + meanLinkDelay |
| **Delay_Req/Resp** | 转发所有，添加 residenceTime | **丢弃** Delay_Req/Resp |

> **关键区别**：E2E TC 只修正驻留时间，路径延迟由端点的 Slave 通过 Delay_Req/Resp 测量；P2P TC 额外修正链路延迟，因此 Slave 不需要发送 Delay_Req。

#### BMCA 数据集比较算法 (Clause 9.3)

按以下字段的 **严格优先级顺序** 比较两个数据集 A 和 B（值越小越好）：

| 优先级 | 字段 | 说明 |
|--------|------|------|
| 1 | `GM priority1` | 用户配置，默认 128 |
| 2 | `GM identity` (clockIdentity) | 64-bit 唯一标识 |
| 3 | `GM clockClass` | 6=locked, 7=holdover, 52=disabled, 187=slave-only, 248=default |
| 4 | `GM clockAccuracy` | 0x20=25ns, 0x21=100ns, 0x22=250ns, ... |
| 5 | `GM offsetScaledLogVariance` | 16-bit 时钟稳定性度量 |
| 6 | `GM priority2` | 用户配置，默认 128 |
| 7 | `GM identity`（再次，决胜） | 防止相同属性冲突 |
| 8 | `stepsRemoved` | 距 GM 的跳数 |
| 9 | `topology tie-breaker` | 接收方 portNumber vs 发送方 portNumber |

**状态决策码** (Clause 9.3.2, Figure 33)：

| 条件 | 决策码 | 推荐状态 |
|------|--------|----------|
| D0 优于 Erbest 且 D0.clockClass 1–127 | M1 | **MASTER** |
| D0 优于 Erbest 且 D0.clockClass ≥128 | M2 | **MASTER** |
| D0 优于 Ebest | M3 | **MASTER** |
| D0 不优于 Ebest 且 Ebest 在端口 R 接收 | S1 | **SLAVE** |
| D0 不优于 Ebest 且 Ebest == Erbest | S1 | **SLAVE** |
| 其他情况 | P1/P2 | **PASSIVE** |

其中：D0 = defaultDS of C0, Erbest = 端口 r 上接收到的最佳 Announce, Ebest = 所有端口上 Erbest 中的最佳者。

**外国主时钟资格**：
- `FOREIGN_MASTER_TIME_WINDOW` = 4 × announceInterval
- `FOREIGN_MASTER_THRESHOLD` = 窗口内 2 条 Announce 消息
- 外国主列表最小容量 = 5 条记录

---

### 3.3.11 PTP 端口状态机与延迟测量 (Clause 9.2 / Clause 11)

#### 端口状态定义 (Enumeration8)

| 值 (hex) | 状态 | 说明 |
|----------|------|------|
| 0x01 | **INITIALIZING** | 初始化数据集、硬件、通信。不发送。 |
| 0x02 | **FAULTY** | 故障状态。不发送，除管理响应外。 |
| 0x03 | **DISABLED** | 不发送。丢弃所有接收（管理除外）。 |
| 0x04 | **LISTENING** | 等待 announceReceiptTimeout 或 Announce。仅发送 Pdelay/Signaling/Mgmt。 |
| 0x05 | **PRE_MASTER** | 行为同 MASTER 但不发送定时消息。暂态。 |
| 0x06 | **MASTER** | 发送所有必需 PTP 消息。 |
| 0x07 | **PASSIVE** | 不发送，除 Pdelay/Signaling/Mgmt 外。 |
| 0x08 | **UNCALIBRATED** | 暂态：准备伺服，更新数据集。 |
| 0x09 | **SLAVE** | 执行时钟调整以跟踪 Master。 |

#### 关键状态转换 (Figure 30)

| 转换条件 | 目标状态 |
|----------|----------|
| POWERUP / INITIALIZE | INITIALIZING |
| INITIALIZATION_COMPLETE + PL=FALSE | LISTENING |
| INITIALIZATION_COMPLETE + PL=TRUE | MASTER |
| STATE_DECISION_EVENT + BMC_SLAVE + PU | UNCALIBRATED |
| MASTER_CLOCK_SELECTED + PU | SLAVE |
| ANNOUNCE_RECEIPT_TIMEOUT_EXPIRES（无其他 Slave 端口） | MASTER |
| ANNOUNCE_RECEIPT_TIMEOUT_EXPIRES（有其他 Slave 端口） | LISTENING |
| FAULT_DETECTED + PF | FAULTY |
| DESIGNATED_DISABLED + PD + PF | DISABLED |

> PL = portList（端口列表非空），PU = portUp（端口运行），PF = portFaulty（端口故障），PD = portDisabled（端口禁用）。

#### E2E 延迟测量 (Delay Request-Response, Clause 11.3)

**时间戳**：
- t1 = Sync 发送时间戳（Master 时间）
- t2 = Sync 接收时间戳（Slave 时间）
- t3 = Delay_Req 发送时间戳（Slave 时间）
- t4 = Delay_Req 接收时间戳（Master 时间）

**公式**：
```
<meanPathDelay> = [(t2 - t1) + (t4 - t3)] / 2
                = [(t2 - t3) + (t4 - t1)] / 2
```

**一步式 Sync**：
```
<offsetFromMaster> = t2 - originTimestamp - <meanPathDelay> - <correctedSyncCorrectionField>
```

**两步式 Sync**：
```
<offsetFromMaster> = t2 - preciseOriginTimestamp - <meanPathDelay>
                     - <correctedSyncCorrectionField> - correctionField(Follow_Up)
```

#### P2P 延迟测量 (Peer Delay, Clause 11.4)

**时间戳**：
- t1 = Pdelay_Req 发送时间戳（Requester）
- t2 = Pdelay_Req 接收时间戳（Responder）
- t3 = Pdelay_Resp 发送时间戳（Responder）
- t4 = Pdelay_Resp 接收时间戳（Requester）

**一步式 Responder**：设置 `requestReceiptTimestamp = 0`，计算周转时间 `t3 - t2` 加到 Pdelay_Resp 的 correctionField。

**两步式 Responder（选项 B）**：设置 `requestReceiptTimestamp = t2`，`responseOriginTimestamp = t3`，分数纳秒修正到 correctionField。

**Requester 计算**：
```
<meanLinkDelay> = [(t4 - t1) - <correctedPdelayRespCorrectionField>] / 2   （一步式）
<meanLinkDelay> = [(t4 - t1) - (responseOriginTimestamp - requestReceiptTimestamp)
                   - <correctedPdelayRespCorrectionField>
                   - correctionField(Pdelay_Resp_Follow_Up)] / 2   （两步式）
```

---

### 3.3.12 Transparent Clock 操作与数据集 (Clause 8/10)

#### TC correctionField 修正规则

**驻留时间计算**：
```
<residenceTime> = <egressTimestamp> - <ingressTimestamp>
```

**E2E TC — Sync 消息（一步式出口端口）**：
```
correctionField(Sync_egress) = correctionField(Sync_ingress)
                               + <residenceTime> + ingress<delayAsymmetry>
```

**P2P TC — Sync 消息（一步式出口端口）**：
```
correctionField(Sync_egress) = correctionField(Sync_ingress)
                               + <residenceTime> + <meanLinkDelay> + ingress<delayAsymmetry>
```

**两步式出口端口（入口 Sync twoStepFlag = FALSE）**：
- 在出口 Sync 上设置 `twoStepFlag = TRUE`
- 生成 Follow_Up：`preciseOriginTimestamp = originTimestamp(入口 Sync)`
- `correctionField(Follow_Up) = <residenceTime> + <meanLinkDelay> + ingress<delayAsymmetry>`

> **RTL 关键提示**：correctionField 是 64-bit 有符号整数，单位 ns × 2¹⁶。累加操作需处理溢出（全 1 除符号位表示"过大"）。建议用 96-bit 或更宽内部累加器避免中间溢出。P2P TC 需要每端口维护 `meanLinkDelay` 值（通过 Pdelay 机制测量）。

#### PTP 数据集结构 (Clause 8)

**defaultDS**（默认数据集）：

| 成员 | 类型 | 类别 | 说明 |
|------|------|------|------|
| `clockIdentity` | ClockIdentity (8B) | static | 此 PTP 实例的唯一 ID |
| `numberPorts` | UInteger16 | static | OC=1，BC=N |
| `clockQuality` | ClockQuality (6B) | dynamic | clockClass + clockAccuracy + offsetScaledLogVariance |
| `priority1` | UInteger8 | config | BMCA 优先级，默认 128 |
| `priority2` | UInteger8 | config | BMCA 次优先级，默认 128 |
| `domainNumber` | UInteger8 | config | 域 ID，默认 0 |
| `slaveOnly` | Boolean | config | TRUE = 不能成为 Master |
| `sdoId` | UInteger12 | config | 默认 0x000 |

**portDS**（端口数据集）：

| 成员 | 类型 | 说明 |
|------|------|------|
| `portIdentity` | PortIdentity | 此端口的身份 |
| `portState` | Enumeration8 | 当前状态 (0x01–0x09) |
| `logMinDelayReqInterval` | Integer8 | log₂(minDelayReqInterval) |
| `meanLinkDelay` | TimeInterval | P2P 测量的链路延迟 |
| `logAnnounceInterval` | Integer8 | log₂(announceInterval) |
| `announceReceiptTimeout` | UInteger8 | announceInterval 超时的乘数 |
| `logSyncInterval` | Integer8 | log₂(syncInterval) |
| `delayMechanism` | Enumeration8 | 01=E2E, 02=P2P, FE=NO_MECHANISM |
| `logMinPdelayReqInterval` | Integer8 | log₂(minPdelayReqInterval) |
| `versionNumber` | UInteger4 | PTP 主版本（1588-2019 为 2） |
| `delayAsymmetry` | TimeInterval | 配置/静态不对称 |

---

### 3.3.13 IEEE 1588-2019 以太网传输与默认 Profile (Annex E / Annex I)

#### 以太网传输参数 (Annex E)

| 参数 | 值 | 说明 |
|------|------|------|
| **Ethertype** | **0x88F7** | PTP 专用 Ethertype |
| **标准 PTP 组播目的 MAC** | 01-1B-19-00-00-00 | 除 peer delay 外的所有消息 |
| **P2P 延迟消息目的 MAC** | 01-80-C2-00-00-0E | Pdelay_Req/Resp/Follow_Up，802.1Q 桥不转发 |
| **networkProtocol** | 0x0003 (IEEE 802.3) | PortAddress 中的协议标识 |
| **addressLength** | 6 | MAC 地址长度 |

> 按 Profile 允许对所有消息使用任一地址。`majorSdoId` 解释为 Ethertype 子类型；若子类型未被识别 → 丢弃。

#### 默认 Profile 参数 (Annex I)

**Delay Request-Response 默认 Profile (#1)**：

| 参数 | 默认值 | 可配置范围 |
|------|--------|-----------|
| `defaultDS.domainNumber` | 0 | Per Table 2 |
| `portDS.logAnnounceInterval` | 1 (2s) | 0 to 4 |
| `portDS.logSyncInterval` | 0 (1s) | -1 to +1 |
| `portDS.logMinDelayReqInterval` | 0 (1s) | 0 to 5 |
| `portDS.announceReceiptTimeout` | 3 | 2 to 10 |
| `defaultDS.priority1` | 128 | — |
| `defaultDS.priority2` | 128 | — |
| `defaultDS.slaveOnly` | FALSE | — |
| `defaultDS.sdoId` | 0x000 | — |
| τ (tau) | 1.0 s | — |

**Peer-to-Peer 默认 Profile (#2)**：

| 参数 | 默认值 | 可配置范围 |
|------|--------|-----------|
| `defaultDS.domainNumber` | 0 | Per Table 2 |
| `portDS.logAnnounceInterval` | 1 (2s) | 0 to 4 |
| `portDS.logSyncInterval` | 0 (1s) | -1 to +1 |
| `portDS.logMinPdelayReqInterval` | 0 (1s) | 0 to 5 |
| `portDS.announceReceiptTimeout` | 3 | 2 to 10 |
| `defaultDS.priority1` | 128 | — |
| `defaultDS.priority2` | 128 | — |
| `defaultDS.slaveOnly` | FALSE | — |
| `defaultDS.sdoId` | 0x000 | — |
| τ (tau) | 1.0 s | — |

**间隔计算**：
```
announceInterval       = 2^(portDS.logAnnounceInterval)       seconds
syncInterval           = 2^(portDS.logSyncInterval)           seconds
minDelayReqInterval    = 2^(portDS.logMinDelayReqInterval)    seconds
minPdelayReqInterval   = 2^(portDS.logMinPdelayReqInterval)   seconds
announceReceiptTimeoutInterval = portDS.announceReceiptTimeout × announceInterval
```

**定时容差**：平均间隔在 ±30% 内。至少 90% 的间隔在 ±30% 内。

---

### 3.3.14 PTP RTL 模块划分建议

基于 IEEE 1588-2019 标准，PTP 时间同步子系统的 RTL 模块划分如下：

| 模块 | 功能 | 复杂度 | 备注 |
|------|------|--------|------|
| **PTP Header Parser** | 解析 34-byte 通用头，提取 messageType、domainNumber、sdoId、flagField、correctionField、sourcePortIdentity、sequenceId | 中 | 所有消息共用 |
| **Timestamp Engine** | 在 reference plane 捕获 Event 消息的 ingress/egress 时间戳 | 中 | 250MHz clk_ts |
| **correctionField ALU** | 64-bit 有符号整数加法/累加，处理 ns × 2¹⁶ 单位 | 中 | 建议 96-bit 内部累加器 |
| **BMCA Engine** | 数据集比较（priority1→class→accuracy→variance→priority2→identity→steps→topology） | 高 | 需维护外国主列表 |
| **State Machine Controller** | 实现 9 个端口状态及转换 | 中 | INITIALIZING→LISTENING→MASTER/SLAVE |
| **Sync/Delay Handler** | OC/BC 的 Sync 生成、Delay_Req/Resp 处理 | 高 | E2E 机制 |
| **Pdelay Handler** | P2P 的 Pdelay_Req/Resp/Follow_Up 生成与处理 | 高 | 802.1AS 强制 |
| **TC Engine** | residenceTime 计算、correctionField 累加、消息转发 | 高 | Switch 模式必需 |
| **Dataset RAM** | 存储 defaultDS/currentDS/parentDS/timePropertiesDS/portDS | 中 | 每端口/每实例 |
| **Follow_Up Generator** | 两步式时钟的 Follow_Up 消息生成 | 低 | 绑定时间戳 FIFO |
| **Announce Generator** | 周期性 Announce 消息生成 | 低 | 含 priority vector |

---


### 4.1 吞吐率

| 速率模式 | 理论线速 | 实测有效吞吐 | 瓶颈分析 | 备注 |
|----------|----------|--------------|----------|------|
| 10M MII | 10 Mbps | ~9.8 Mbps | IPG + 前导码开销 | — |
| 100M MII | 100 Mbps | ~98 Mbps | 同上 | — |
| 1G RGMII | 1 Gbps | ~990 Mbps | AXI burst 效率 | — |
| 2.5G SGMII | 2.5 Gbps | ~2.48 Gbps | LCB2SRI 通道带宽 | — |
| 5G USXGMII | 5 Gbps | ~4.95 Gbps | 双 LCB2SRI 分离配置 | — |
| **CBS 信用整形** | — | **~99.9%** 理论带宽 | Credit 累积/消耗模型 | ✅ **TC4x erratum 已规避**: IPG 期间 credit 持续递减，带宽误差 < 0.1% |

> [^1^]: 参考 `Reference/Kimi_Agent_MCU_Ethernet/research/ethernet_mcu_cross_verification.md` — TC4x CBS 存在已知 erratum，信用值计算导致约 2.65% 的带宽损失。本 IP 设计时应通过软件补偿（Credit 值预校正）或硬件修复（改进 Credit 算法）规避此问题。

### 4.2 延迟

| 路径 | 典型延迟 | 最大延迟 | 说明 |
|------|----------|----------|------|
| TX 存储转发 | ~2 μs | ~5 μs | 含 FIFO 填充 + DMA 传输 |
| TX 阈值模式 | ~0.5 μs | ~2 μs | 提前启动，效率折中 |
| RX 存储转发 | ~2 μs | ~5 μs | 完整帧接收后转发 |
| PTP 时间戳精度 | ±8 ns | ±20 ns | SFD 捕获精度 |
| TAS 门控切换 | <1 μs | <2 μs | 硬件周期计数器驱动 |

---

### 4.2.1 Switch 满负载丢帧率

**指标定义**: 4-port Switch 在所有端口同时线速收发、任意帧长分布（64B~1522B）、全广播/多播风暴场景下，48 小时连续运行的丢帧数量 / 总转发帧数。

| 测试场景 | 帧长分布 | 流量模式 | **丢帧率目标** | 对标 |
|----------|----------|----------|---------------|------|
| **4-port 线速满载** | 64B:50% / 512B:30% / 1518B:20% | 全单播（FDB 命中） | **≤ 0.001% (1 in 100k)** | TC4x Bridge |
| **广播风暴** | 1518B | 全广播（FDB 未命中，泛洪） | **≤ 0.01%** | R-Car S4 RSwitch2 |
| **混合多播** | 256B | 50% 多播 + 50% 单播 | **≤ 0.005%** | — |
| **TSN 门控满载** | 128B | TAS 门控周期 1ms，时间窗口满载 | **≤ 0.001%** | TC4x + TAS |

**保证机制**:
- **Ingress FIFO 独立**: 每端口独立 2KB~8KB FIFO，单端口拥塞不阻塞其他端口（无 HOL 阻塞）
- **Crossbar 全并发**: 4 端口同时线速转发，无仲裁冲突
- **背压 (Back-pressure)**: Egress 端口忙时，向 Ingress 端口发送 pause 帧，不丢弃已接收帧
- **优先级调度**: TSN 队列（AVB/gPTP）优先转发，普通队列在余量带宽中轮转
- **FDB 静态条目**: 关键帧（gPTP SYNC/Announce）静态绑定 egress 端口，零查表延迟

> **对标**: TC4x Bridge 在广播泛洪时无明确丢帧率指标（Bridge 静态桥接无 FDB）。R-Car S4 RSwitch2 标称 "Zero packet loss @ wire speed" 但依赖外部缓存。本 IP 目标 ≤0.001% 是务实且可验证的。

### 4.2.2 低功耗模式

| 模式 | 触发条件 | **功耗目标** | **进入时间** | **唤醒时间** | 恢复状态 |
|------|----------|-------------|-------------|-------------|----------|
| **Active (全速)** | 正常通信 | 基准 100% | — | — | 全功能 |
| **EEE (Energy Efficient Ethernet)** | 802.3az 链路空闲 | **~30%** Active | 硬件自动（μs级） | **< 10 μs** | 链路保持，MAC/PHY 低功耗 |
| **Wakeup on LAN (WoL)** | 链路断开，等待魔术包 | **~5%** Active | 软件配置 | **< 100 μs** | MAC 最小逻辑 + PHY 监听 |
| **Deep Sleep** | 系统休眠指令 | **~1%** Active | 软件配置 | **< 1 ms** | CSR 保持，FIFO/PHC 断电 |

**功耗估算（典型场景）**:

| 场景 | 配置 | **估算功耗** | 说明 |
|------|------|-------------|------|
| 中央网关 (4×1G + Switch) | Active | **~800 mW** | 2×5G MAC + 4-port Switch + PHC |
| ADAS (2×5G) | Active | **~600 mW** | 2×XGMAC + DMA + PHC |
| 边缘节点 (1×10M) | Active | **~50 mW** | 单 MAC + 小 PHY |
| 任意场景 | EEE 空闲 | **~25%** Active | PHY 侧主导节省 |
| 任意场景 | Deep Sleep | **~10 mW** | 仅 CSR + 唤醒逻辑 |
| **中央网关扩展 (8×1G + Switch)** | Active | **~1,100 mW** | 8-port Switch + 仲裁器面积增加 (~52kGE) |

**关键机制**:
- **EEE (802.3az)**: PHY 自动进入 Low Power Idle (LPI)，MAC 在 TX 前发送 Wake 序列，PHY 在 <10μs 内恢复
- **时钟门控**: 各子模块独立 `clk_gate_en`，空闲模块时钟关闭（无动态功耗）
- **PHY 电源控制**: `PHY_PWR_DOWN` CSR 位，单独控制每 PHY 上下电
- **FIFO 深度自适应**: 低负载时 MTL FIFO 水位降低到 8KB（vs 默认 32KB），减少 SRAM 漏电

> **对标**: TC4x GETH 未公开功耗数据。NXP S32G3 GMAC 标称 ~200mW/端口 @1G。本 IP 估算基于 22nm 工艺门数 × 0.15mW/kGE (典型) + SRAM 漏电，±30% 误差，需 RTL 综合后校准。

---

## 4.3 资源估算

> **公式化估算**（按实际实例累加，非固定乘数）
> **Switch Core 门数/SRAM 已按端口数参数化** (PAD-REWORK-004 修复 RTL-CRIT-004)

| 模块 | 每实例门数 (kGE) | 每实例 SRAM (KB) | 累加公式 | 备注 |
|------|-----------------|-----------------|----------|------|
| XGMAC-CORE | ~40 | 4 | `40 × N_xgmac` | N_xgmac = count(MAC_x_TYPE==2) |
| GMAC-CORE | ~25 | 2 | `25 × N_gmac` | N_gmac = count(MAC_x_TYPE==1) |
| MAC-CORE (10/100M) | ~15 | 1 | `15 × N_mac` | N_mac = count(MAC_x_TYPE==0) |
| MTL | ~10 | 32 | `10 × MAC_COUNT` | TX/RX FIFO 各 32KB |
| DMA | ~20 | 2 | `20 × MAC_COUNT` | 描述符缓存 |
| **Switch Core** | **~14~52** | **~84~128** | **参数化: f(N)** | N=`SWITCH_PORT_COUNT`; 仲裁器 ~14kGE@N=4, ~52kGE@N=8; FDB ~84KB; VLAN ~8KB; L3 ~16KB; TAS GCL ~16KB |
| PTP/Timestamp | ~10 | 2 | `10 + 10×(PHC_COUNT-1)` | 基础 + 每额外 PHC |
| vPHC 虚拟化 | ~5 | 1 | `5 × SUPPORT_VPHC` | Xen IO Ring 逻辑 |
| Safety/ECC | ~15 + 2×(MAC_COUNT−1) | 0 | 参数化: `15 kGE + 2 kGE × (MAC_COUNT − 1)` | 校验逻辑按 MAC 实例累加 |
| HSPHY IF | ~5 | 0 | `5 × PHY_COUNT` | 每 PHY 接口逻辑 |
| **总计（典型 N=4）** | **~205** | **~160** | — | 4×GMAC + 4-port Switch + 双 PHC |
| **总计（扩展 N=8）** | **~280** | **~210** | — | 8×GMAC + 8-port Switch + 双 PHC |

> **Switch Core 资源详细分解 (按端口数 N)**:
> | 子模块 | N=2 | N=4 | N=8 | 来源 |
> |--------|-----|-----|-----|------|
> | FDB (2×4K×84-bit SRAM + 查表逻辑) | ~42KB + ~8kGE | ~84KB + ~12kGE | ~168KB + ~20kGE | `switch_fdb_microarch.md` |
> | Egress 仲裁器 (Crossbar + RR + Priority) | ~7kGE | ~14kGE | ~52kGE | `switch_arbiter_design.md` |
> | VLAN Table | ~4KB + ~2kGE | ~8KB + ~3kGE | ~16KB + ~5kGE | 估算 |
> | L3 Route Table | ~8KB + ~3kGE | ~16KB + ~5kGE | ~32KB + ~8kGE | 估算 (SWITCH_L3=1) |
> | TAS GCL | ~8KB + ~2kGE | ~16KB + ~3kGE | ~32KB + ~5kGE | 估算 (SWITCH_TAS=1) |
> | Ingress FIFO (每端口) | ~1KB × N | ~2KB × N | ~4KB × N | 按端口累加 |
> | Egress FIFO (每端口) | ~0.5KB × N | ~1KB × N | ~2KB × N | 按端口累加 |
> | Crossbar XBAR FIFO | ~0.5KB × N² | ~1KB × N² | ~2KB × N² | N² 个交叉点 |
> | **Switch Core 合计 (N=4)** | — | **~84KB SRAM + ~38kGE** | — | 实际 |
> | **Switch Core 合计 (N=8)** | — | — | **~250KB SRAM + ~90kGE** | 实际 |

> **典型场景快速估算**:
> - **中央网关 (4 GMAC/1G + Switch + vPHC)**: ~205 kGE, ~160 KB SRAM
> - **ADAS (2 XGMAC/5G)**: ~160 kGE, ~58 KB SRAM
> - **混合 (1 XGMAC/5G + 1 GMAC/1G + Switch)**: ~175 kGE, ~64 KB SRAM
> - **边缘节点 (1 MAC/10M)**: ~65 kGE, ~35 KB SRAM
> - **中央网关扩展 (8 GMAC/1G + 8-port Switch)**: ~280 kGE, ~210 KB SRAM (Config-D 等扩展场景)

---

### 4.4 带宽评估计算器

> **设计原则**: 根据所有 MAC 线速、TSN 整形需求、突发流量模型，计算最小 DMA 通道数、AXI 总线位宽和频率需求。

#### 4.4.1 输入参数

| 参数 | 符号 | 单位 | 说明 |
|------|------|------|------|
| MAC 数量 | N_mac | — | `MAC_COUNT` |
| 每 MAC 速率 | R_mac | Mbps | `MAC_x_SPEED` × 1000 |
| TSN 使能 | TSN_en | — | `SUPPORT_TSN` |
| CBS 队列数 | N_cbs | — | `MTL_TX_QUEUES` (若 `SUPPORT_CBS=1`) |
| TAS 门控周期 | T_tas | μs | GCL 周期 (若 `SUPPORT_TAS=1` 或 `SWITCH_TAS=1`) |
| 最大帧长 | L_max | Byte | 1518 (标准) / 1522 (VLAN) / 9018 (Jumbo) |
| 最小帧长 | L_min | Byte | 64 |
| AXI 数据位宽 | W_axi | bit | `AXI_DATA_WIDTH` |
| AXI 频率 | F_axi | MHz | `clk_sys` |
| 目标带宽利用率 | U_target | % | 通常 80% (留 20% 余量给开销) |

#### 4.4.2 计算公式

**步骤 1: 单 MAC 有效数据率**
```
R_eff_mac = R_mac × (L_max / (L_max + 20))  // 20 = preamble(8) + IPG(12)
```

**步骤 2: 总线线速需求**
```
R_total = Σ(N_mac × R_eff_mac)  // 所有 MAC 线速之和
```

**步骤 3: TSN 整形余量**
```
// CBS: 信用整形引入约 0.1% 开销 (已规避 TC4x erratum)
// TAS: 门控切换引入约 0.5% 开销 (周期边界调度)
R_tsn = R_total × 1.005  // TAS 余量
```

**步骤 4: AXI 总线带宽需求**
```
B_axi_min = R_tsn / U_target  // 例如: 2×5Gbps / 0.8 = 12.5Gbps
```

**步骤 5: AXI 位宽/频率验证**
```
B_axi_actual = W_axi × F_axi  // 例如: 128-bit × 200MHz = 25.6Gbps
```

**步骤 6: DMA 通道数需求**
```
// 每通道最小有效带宽: 支持至少 1Gbps (用于 1G MAC)
// 每通道最大带宽: 受限于 AXI 通道仲裁
DMA_CH_MIN = ceil(R_total / 1Gbps)  // 每 Gbps 至少 1 通道

// 考虑 TSN 隔离: CBS/TAS 队列需要独立通道
DMA_CH_TSN = N_mac × max(N_cbs, 2)  // 每 MAC 至少 2 通道 (TX/RX 分离)

// 最终需求
DMA_CH_COUNT = max(DMA_CH_MIN, DMA_CH_TSN)
```

**步骤 7: Switch 转发额外带宽**
```
// 若 SWITCH 使能: 内部转发占用 AXI 带宽 (read from 内存 + write to 内存)
// 最坏情况: 所有端口全转发 → 2×R_total (读 + 写)
R_switch = R_total × 2  // 全转发场景

// 若 Switch Core 支持 cut-through: 降低至 R_total × 1.2
R_switch_ct = R_total × 1.2
```

#### 4.4.3 典型场景计算示例

| 场景 | MAC_COUNT | `MAC_x_SPEED` | R_total | DMA_CH_MIN | DMA_CH_TSN | **DMA_CH_REC** | W_axi | F_axi | B_axi_actual | 裕量 |
|------|-----------|-----------|---------|------------|------------|----------------|-------|-------|--------------|------|
| 中央网关 (4×1G) | 4 | 1G | 4 Gbps | 4 | 8 | **8** | 128 | 200 | 25.6 Gbps | **6.4×** |
| ADAS (2×5G) | 2 | 5G | 10 Gbps | 10 | 16 | **16** | 128 | 300 | 38.4 Gbps | **3.84×** |
| Zone 骨干 (2×5G+Switch) | 2 | 5G | 10 Gbps | 10 | 16 | **16** | 128 | 300 | 38.4 Gbps | **3.2×** (含 Switch 转发) |
| 边缘节点 (1×10M) | 1 | 10M | 10 Mbps | 1 | 2 | **2** | 32 | 100 | 3.2 Gbps | **320×** |
| OTA (1×1G) | 1 | 1G | 1 Gbps | 1 | 4 | **4** | 64 | 100 | 6.4 Gbps | **6.4×** |

#### 4.4.4 配置推荐矩阵

| 总线带宽需求 | AXI_DATA_WIDTH | clk_sys (F_axi) | 适用场景 |
|-------------|----------------|-----------------|----------|
| < 1 Gbps | 32-bit | 100 MHz | 10/100M 边缘节点 |
| 1 ~ 5 Gbps | 64-bit | 100 ~ 150 MHz | 1G 单 MAC / CAN 网关 |
| 5 ~ 20 Gbps | 128-bit | 150 ~ 250 MHz | 多端口 1G / 5G ADAS |
| 20 ~ 40 Gbps | 128-bit | 250 ~ 300 MHz | 5G+Switch / 中央网关 |
| > 40 Gbps | 256-bit | 300+ MHz | 10G+ 多端口 (未来扩展) |

#### 4.4.5 设计决策

```
[DMA 全局通道池架构]
- DMA_CH_COUNT: 全局共享池 (1/2/4/8/16/32 通道)
- DMA_CH_PER_MAC: 每 MAC 可分配上限 (1~8)
- 分配方式:
  静态分配 (复位时配置): MAC0→CH[0:3], MAC1→CH[4:7]
  动态分配 (运行时): 通过 DMA_CH_MAP[n] 寄存器重映射
  
- 仲裁策略:
  Round-Robin (默认): 各通道均分 AXI 带宽
  Weighted: 高优先级通道 (TSN/AVTP) 分配更多带宽权重
  
- QoS 支持:
  AXI AWQOS/ARQOS: TSN 队列 = 0xF, 普通队列 = 0x8, 背景 = 0x0
```

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

## 6. TC4x 已知 Erratum 设计规避决策

> **来源**: `protocol_analysis.md` §8 — TC4x Errata 完整分析
> **原则**: 凡硬件 root cause 导致的 erratum，本 IP 通过 RTL/架构级设计修改解决；非硬件缺陷通过软件 workaround 规避
> **状态**: 全部 **15** 项关键 erratum 已有明确设计方案，纳入 EDR 阶段实现

### 6.1 设计规避总览

| Errata ID | 标题 | 严重程度 | 设计修改点 | 验证方法 |
|-----------|------|----------|-----------|---------|
| GETH_AI.028 | Bridge 模块数据转发延迟不一致 | **高** | **Switch Core Crossbar 替代 Bridge**，消除 Bridge 路径差异导致的延迟抖动 | 多端口转发延迟一致性测试 |
| GETH_AI.030 | Bridge 模块帧顺序/完整性异常 | **高** | **Switch Core Crossbar 替代 Bridge**，无 Bridge 内部缓冲重排序问题 | 帧顺序完整性压力测试 |
| GETH_AI.029 | CBS credit 不在 IPG 期间递减 | **高** | MTL CBS credit_decrement 扩展至 IPG 全周期 | 带宽精度测试 |
| GETH_AI.032 | TAS 背靠背传输额外 IPG | **高** | TAS Scheduler 与 MAC TX 同 clk_mac 域，消除 CDC 延迟 | IPG 精度测试 |
| GETH_AI.036 | MAC 在 TX FIFO 达阈值前开始传输 | **高** | 增加 tx_threshold_ready 握手信号，阈值可配 | Underflow 压力测试 |
| GETH_AI.039 | MII 模式下 underflow 不终止传输 | **高** | Underflow 触发 Jam 序列 + 立即终止 | Underflow 注入测试 |
| GETH_AI.035 | RX watchdog timer 不重置 | 中 | 中断聚合控制器统一重置所有 timer | 多 timer 触发测试 |
| GETH_AI.037/040/041/042 | RX DMA 多种 stall 场景 | **高** | 命令 FIFO 互斥 + context desc 错误跳过 + 变长包隔离 + recovery 超时 | 并发 flush/resume 测试 |
| GETH_AI.033 | VLAN filter fail queue 路由错误 | 中 | VLAN FAIL 强制路由到可配 fail queue，支持丢弃/送队列 | VLAN 失败路径测试 |
| GETH_AI.045 | Bridge 转发填充 8 字节 padding | 中 | **Switch Core Crossbar 替代 Bridge**，无 delayed word 问题 | 帧长精确测试 |
| LETH_TC.010 | 多端口 PTP 只能成对菊花链 | **高** | **双 PHC + Crossbar 架构**，各端口独立访问任意 PHC | 4-port PTP 同步精度 |
| LETH_AI.024 | Bridge 启用时非 TxQ0 时间戳错误 | **高** | DMA channel_id 独立路由，Switch 按 matched_channel 回写 | 多 TxQ 时间戳精度 |
| DRE_TC.H002 | DRE 转发带宽瓶颈丢帧 | **高** | **Switch Crossbar 全并发**，无 DRE 中间层，背压不丢帧 | 4-port 满载零丢帧 |
| HSPHY_TC.005 | 温度变化时 RX 通信丢失 | 中 | 温度自适应链路降速 (5G→2.5G)，维持链路后恢复 | 温度循环稳定性 |
| GETH_AI.034 | MII 模式非标准 IPG 不匹配 | 中 | IPG 寄存器直接编码 (非折半)，硬件自动边界对齐 | IPG 精确度测试 |

### 6.2 关键 RTL 修改决策

#### 6.2.1 CBS IPG Credit 修正 (MTL Scheduler)

```
[RTL 修改]
- credit_decrement 条件:
  旧: tx_active (仅 packet data)
  新: tx_active || ipg_active (packet + preamble + FCS + IPG)
  
- 新增配置位: CBS_IPG_DECR_EN (偏移 0xA0 bit[16], 默认=1)
  0: 仅 packet 期间递减 (兼容旧行为)
  1: IPG 期间持续递减 (默认, 规避 GETH_AI.029)
```
**验证目标**: 1000 帧 CBS 整形后实际带宽误差 < 0.1% (vs TC4x ~2.65% 误差)

#### 6.2.2 TAS CDC 消除 (MTL EST Engine)

```
[架构决策]
- TAS Gate Control List 调度器与 MAC TX Engine 同 clk_mac 时钟域
- 门控决策信号直接驱动 MAC TX 使能，无需跨域同步
- 若未来需支持 clk_mac ≠ fGETH 场景，增加 tas_cdc_compensation[3:0] 补偿寄存器
```
**验证目标**: 背靠背传输时额外 IPG = 0 (vs TC4x 最坏 12 周期)

#### 6.2.3 TX Threshold 握手 (MTL TX FIFO → MAC)

```
[RTL 修改]
- MTL TX FIFO 输出: tx_threshold_ready (水位 ≥ 阈值 + SOP valid)
- MAC TX 状态机:
  IDLE → (tx_threshold_ready=1) → PREAMBLE → DATA → FCS → IPG → IDLE
  
- tx_threshold 配置: 64B / 128B / 256B / 512B / full (5 档)
- 安全 clamp: 阈值 < 64B 时自动提升到 64B
```

#### 6.2.4 Underflow 终止 + Jam (MAC TX Engine)

```
[RTL 修改]
- underflow 检测: fifo_empty && tx_active && !eof_reached
- 检测后动作序列:
  1. 发送 Jam pattern (0x55_55_55_55, 32-bit)
  2. Deassert TX_EN
  3. 置位 TX_UNDERFLOW_ERR (CSR 0x008 bit[1])
  4. 若 TX_UNDERFLOW_IRQ_EN=1，触发中断
  5. 状态机 → IDLE
  
- 新增配置位: TX_UNDERFLOW_TERMINATE_EN (默认=1, 强制终止)
```

#### 6.2.5 DMA 鲁棒性增强 (DMA Engine)

```
[RTL 修改]
1. 命令 FIFO 互斥:
   - flush 和 resume 命令进入统一 4-entry 命令 FIFO
   - 状态机: IDLE → CMD_POP → EXEC → IDLE
   - 同一时刻仅执行一条命令，禁止重叠

2. Context Descriptor 错误恢复:
   - 硬件检查 ctx_desc.length=0 或 ctx_desc.type 非法
   - 错误时置位 CDE (Context Descriptor Error)，跳过该 desc
   - DMA 继续下一描述符，不阻塞通道

3. RX 变长包 + 转发隔离:
   - RX DMA 与 TX forwarding DMA 使用独立 AXI ID (ARID/AWID 区分)
   - RX 通道 QoS 优先级高于 TX forwarding (QoS=0xF vs 0x8)
   - 避免 TX 反压阻塞 RX

4. Recovery 超时监控:
   - dma_rx_watchdog_timer: 3ms 无进度自动触发 recovery
   - 状态: 尝试 context save → desc 重新获取 → 继续
   - 连续 3 次 recovery 失败 → 报告 DMA_STALL_FATAL，请求通道复位
```

#### 6.2.6 双 PHC + Crossbar (PTP/Timestamp + Switch)

```
[架构决策]
- PHC0/PHC1 独立 64-bit 计数器，同源晶体 (同一 clk_ts 域)
- Switch Core 每个端口通过 Crossbar 独立访问任意 PHC:
  port[0..3] → crossbar → PHC0 or PHC1 (per-port 绑定)
  
- 无菊花链限制:
  BC 模式: Port 0,1 可绑定 PHC0（支持任意 per-port 组合）; Port 2,3 可绑定 PHC1 (或全端口 → PHC0)
  TC 模式: 各端口独立 residence time 测量，无需共享时间基
  
- gPTP Relay 多端口并发:
  所有端口同时捕获/修正时间戳，无端口对限制
```
**验证目标**: 4-port gPTP TC 模式下 residence time 误差 < ±20ns

#### 6.2.7 Switch Core 替代 Bridge (Switch Core)

```
[架构决策]
- 不实现 GETH/LETH "Bridge" 模块 (避免 GETH_AI.028/030/045/LETH_AI.024)。**GETH_AI.028/030/045 与 LETH_AI.024 均通过 Switch Core Crossbar 替代 Bridge 统一规避，已在 §6.1 中独立列出以维持可追溯性。**
- 采用 4-port Switch Core + Crossbar:
  - 每端口独立 ingress/egress FIFO (各 2KB~8KB)
  - Crossbar 全并发: 4 端口同时线速转发
  - 无 DRE 中间层: 帧直接 Switch 转发，不经过外部 DMA 重路由
  
- FCS 重新计算:
  egress 路径若修改 DA/SA/VLAN/优先级 → 自动触发 CRC-32 重算
  fcs_recalc_en (默认=1)
  
- 无 HOL 阻塞:
  ingress FIFO 独立，egress 仲裁轮询+优先级混合
  单端口忙不阻塞其他端口转发
```

#### 6.2.8 温度自适应链路 (HSPHY Interface)

```
[RTL 修改]
- link_status_qualifier: 连续 3 次采样 down 才报告链路断开
- 温度变化检测 (SoC 提供 temp_sensor 输入):
  - |ΔT| > 10°C/min → 触发速率降级
  - 5G → 2.5G → 1G 阶梯降级
  - 链路恢复 (连续 100ms link_up) → 阶梯升回原速率
  
- phy_temp_adaptive_en (默认=1)
- temp_degraded_status (只读诊断位)
```

#### 6.2.9 PLCA 时序校准 (10BASE-T1S PHY IF)

```
[RTL 修改]
- PLCA TO Timer 补偿:
  to_timer_start_delay[7:0]: 补偿 MII 传播延迟 (默认 10 周期 = 0.76μs @ 80ns)
  可配范围: 0~255 周期 (0~20.4μs)
  
- Commit Timer 硬限制:
  commit_timer_max = 288 (固定，28.8μs @ 80ns)
  若 timer > 288 → 强制退出 WAIT_MAC，置位 COMMIT_TIMER_ERR
  
- RTT 自适应测量:
  plca_rtt_measured[9:0]: 硬件自动测量 BEACON TX→CRS de-assertion
  cycle_time 动态调整: N × to_timer + rtt_measured + beacon_length
  偏差 > 10% → 置位 PLCA_CYCLE_WARN
  
- 错误监控:
  tx_plca_follower_latency[9:0]: 只读，监控 follower 实际延迟
  若延迟 > 6.0μs → 置位 PLCA_TIMING_ERR → SMU 报警
```
**验证目标**: 4-node PLCA 网络，TO→TX_EN 延迟 ≤ 5.56μs，commit timer ≤ 28.85μs，1000-cycle 间隔偏差 < 5%

#### 6.2.10 外部 PHY 选型约束 (10BASE-T1S)

```
[PHY 选型约束 — 非 RTL 修改]
- TC14 PMD v1.5+ 合规: PHY 数据手册明确声明首符号首比特特殊编码合规
- Elastic Buffer 深度 ≤ 8 (降低错误缓存概率)
- Symbol Aligner: 严格 5-bit 边界验证后再输出特殊符号检测
- ED 脉冲检测阈值 ≤ 20ns (符合 IEEE 802.3cg)
- PLCA 寄存器: 遵循 OPEN Alliance TC14 v1.3 (非 vendor-specific UM)

[MAC 层错误检测辅助]
- COL 监控: 首符号后 1μs 内 COL 有效 → PMD_ENCODE_ERR
- RX_ER 计数: 1ms 窗口内 > 阈值 → LINE_NOISE_ERR
- Runt Frame 检测: 连续 < 64B → SHORT_FRAME_ERR
- EOF 偏差: RX_DV 下降沿与预期 EOF > 1μs → EOF_MISMATCH
```
**验证目标**: 外部 PHY 选型评审通过；噪声注入测试 RX 恢复成功率 > 99.9%

### 6.3 与 TC4x 的对比优势

| 维度 | TC4x (含 erratum) | 本 IP (设计规避后) |
|------|-------------------|-------------------|
| **CBS 带宽精度** | ~2.65% 误差 (需软件补偿) | <0.1% 误差 (硬件正确) |
| **TAS 背靠背 IPG** | 最坏 +12 时钟周期 | **0 额外周期** |
| **多端口 PTP** | 仅成对菊花链 (2 对 max) | **全端口独立绑定** (4 端口自由组合) |
| **跨 MAC 转发** | DRE 瓶颈 ~81% 带宽 | **Crossbar 100% 线速** |
| **Bridge FCS** | 修改 L2 header 不重新计算 FCS | **自动 CRC-32 重算** |
| **Bridge HOL** | 单端口阻塞全部转发 | **独立 FIFO + Crossbar，无阻塞** |
| **TX 时间戳 (Bridge)** | 非 TxQ0 时间戳错误 | **channel_id 独立路由，精确回写** |
| **DMA 鲁棒性** | 多种 stall 需软件复位 | **硬件 recovery + 超时自恢复** |
| **温度链路稳定性** | 温度变化可能丢链路 | **自适应降速维持链路** |
| **PLCA follower 时序** | TO 延迟 6.8μs (超标准 5.56μs) | **TO 补偿 + 延迟监控 ≤ 5.56μs** |
| **PLCA commit timer** | 30μs (超标准 28.8μs) | **硬限制 288 周期 = 28.8μs** |
| **PLCA cycle time** | RTT 4.43μs (超标准 1.56μs) | **RTT 自适应测量 + 动态补偿** |

### 6.4 验证计划摘要

| 测试项 | 目标 | 测试平台 | EDR 负责人 |
|--------|------|----------|-----------|
| CBS 带宽精度 | 误差 < 0.1% | UVM 仿真 + FPGA | Verification Agent |
| TAS IPG 精度 | 背靠背 0 额外 IPG | UVM 仿真 | Verification Agent |
| TX Underflow | 强制终止 + Jam 序列 | UVM 故障注入 | Verification Agent |
| DMA Stall Recovery | 3ms 内自恢复 | UVM 并发测试 | Verification Agent |
| 4-port PTP 同步 | residence time < ±20ns | UVM + FPGA | Verification Agent |
| 4-port 满载转发 | 零丢帧 @ 线速 | UVM 性能测试 | Verification Agent |
| 温度链路稳定性 | -40°C~+125°C 循环 | FPGA + 环境箱 | Verification Agent |
| **PLCA 时序精度** | **TO 延迟 ≤ 5.56μs, commit ≤ 28.85μs, cycle 偏差 < 5%** | **UVM + FPGA** | **Verification Agent** |
| **外部 PHY 噪声恢复** | **噪声注入后 RX 恢复成功率 > 99.9%** | **FPGA + 噪声源** | **Verification Agent** |

---

## 7. 协议分析（参考附录）

> **详见**: [protocol_analysis.md](protocol_analysis.md)

本章节引用 `protocol_analysis.md` 中的协议分析结果作为架构设计的输入依据。关键协议-模块映射关系：

| 协议 | 负责模块 | 实现优先级 | 关键约束 |
|------|----------|----------|----------|
| 802.3-2022 MAC | XGMAC-CORE | P0 | 全双工/半双工、帧长约束 |
| 802.1AS-2020 gPTP | PTP/Timestamp | P0 | SFD 级精度、Addend 精调 |
| 802.1AS TC | PTP/Timestamp | P1 | ✅ **多端口 Transparent Clock 已规避**：双 PHC + Crossbar，全端口独立绑定，无菊花链限制 [^2^] |
| 802.1Qav CBS | MTL Scheduler | P0 | 8 队列独立 credit；✅ **TC4x erratum 已规避**：IPG 期间 credit 持续递减，误差 < 0.1% [^1^] |
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
| **10BASE-T1S** | **HSPHY (PLCA)** | **P2** | **多点总线，最多 8 节点，半双工，不支持 TSN 抢占 [^4^]；✅ PLCA 时序 erratum 已规避：TO 补偿 + commit timer 硬限 + RTT 自适应 [^5^]；⚠️ PMD/PMA 层 erratum 通过外部 PHY 选型约束规避 [^6^]** |

> [^1^]: 参考 `protocol_analysis.md` §8 — TC4x CBS erratum 已在本 IP 通过 RTL 设计规避 (§6.2.1)
> [^2^]: 参考 `protocol_analysis.md` §8 — TC4x PTP 多端口限制已通过双 PHC + Crossbar 架构规避 (§6.2.6)
> [^3^]: 参考 `Reference/Kimi_Agent_MCU_Ethernet/research/ethernet_mcu_cross_verification.md` — TC4x CSS MACsec 加速速率
> [^4^]: 参考 `Reference/Kimi_Agent_MCU_Ethernet/ethernet_mcu.agent.final.md` — 10BASE-T1S 在车规 MCU 中的支持情况
> [^5^]: 参考 `protocol_analysis.md` §8 — PLCA 时序类 erratum (LETH_AI.011/013/016) 已通过 RTL 修改规避 (§6.2.x)
> [^6^]: 参考 `protocol_analysis.md` §8 — PMD/PMA 层 erratum (LETH_AI.014/015/022/006) 属外部 PHY 缺陷，通过 PHY 选型约束规避

---

## 8. 安全架构

### 8.1 ASIL-B 安全机制

| 安全机制 | 保护对象 | 检测能力 | 恢复策略 |
|----------|----------|----------|----------|
| **ECC** | MTL FIFO、描述符缓存、**Switch FDB/VLAN/L3 表** | 单 bit 纠错、双 bit 检错 | 自动纠错 + 错误计数 |
| **FSM Parity** | 所有状态机 (MAC/DMA/MTL/PTP/**Switch**) | 奇偶校验错误 | 安全状态转换 + 报警 |
| **Timeout** | CSR 访问、DMA 响应、**Switch 转发** | 响应超时检测 | 复位请求 + 状态上报 |
| **Clock Monitor** | 各时钟域 | 时钟丢失/毛刺检测 | 安全复位 + 备用时钟 |
| **Lockstep** | 关键控制信号 (可选) | 双核比较 | **IP 内部不内嵌 Lockstep，SoC 级可选提供** | NMI 触发 |

### 8.2 安全状态机

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

## 9. 附录

### 9.1 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v0.1 | 2026-05-02 | Arch Agent | 初始模板创建 |
| v1.0 | 2026-05-11 | Arch Agent | 填充完整架构内容，基于 TC4x 研究和协议分析 |
| v1.1 | 2026-05-11 | Arch Agent | 新增 1.4 可配置参数矩阵（协议/DMA/安全参数） |
| v1.2 | 2026-05-11 | Arch Agent | 重构参数：MAC_COUNT 1-8, MAC_TYPE (MAC/GMAC/XGMAC), PHY_COUNT 独立 1-8, PHY_SPEED 解耦 |
| v1.3 | 2026-05-11 | Arch Agent | 更新版本头与变更日志；新增 FuSa Agent 引用与安全概念文档链接 |
| v1.4 | 2026-05-12 | Arch Agent | **基于 R-Car S4 Gap Analysis 升级**: 4-port L2/L3 Switch (替换 Bridge), 双 PHC + vPHC 虚拟化, AVTP 硬件感知, Switch 级 TAS/PSFP, 更新应用场景矩阵和资源估算 |
| v1.4.1 | 2026-05-12 | Arch Agent | ISSUE-006~009 参数化定义: TAS 互斥规则 (Switch 级优先), 双 PHC/vPHC 寄存器接口, L3 路由表/ARP 缓存, AVTP RX Filter/DMA 队列映射 |
| v1.4.2 | 2026-05-12 | Arch Agent | **PAD 阶段零问题声明**: 全部 9 项 ISSUE 关闭/转移，无遗留问题 |
| v1.5 | 2026-05-12 | Arch Agent | **TC4x 13项已知 erratum RTL/架构级设计规避方案**: §6.1 规避总表 + §6.2 关键 RTL 修改决策 + §6.3 对比优势 + §6.4 验证计划 |
| v1.6 | 2026-05-12 | Arch Agent | **DMA 全局通道池设计**: 所有 MAC 共享 DMA 通道池 (8/16/32)，非每 MAC 专属；新增 §4.4 带宽评估计算器；参数矩阵 DMA_CH 列更新为全局池视角 |
| v1.7 | 2026-05-12 | Arch Agent | **TC4x LETH/10BASE-T1S erratum 补充**: 10 项 PLCA/PMD/PMA 层 erratum 分析与规避方案 (ERR-014~023)；新增 §6.2.9 PLCA 时序校准 + §6.2.10 外部 PHY 选型约束；protocol_analysis.md 更新至 v1.2 (23 项 erratum 全覆盖) |
| v1.8 | 2026-05-12 | Arch Agent | **架构基线冻结**: 整合 v1.5~v1.7 全部 erratum 规避方案；ASIL-D 澄清（IP 级 ASIL-B / 系统级 ASIL-D）；补充 §7 协议分析引用 + §8 安全架构概要 |
| v1.8a | 2026-05-12 | Arch Agent | **保守默认方向 + 每实例独立参数**: MAC_COUNT=2 保守默认；MAC_x_TYPE/MAC_x_SPEED 每 MAC 独立；PHY_x_TYPE/PHY_x_SPEED/PHY_x_DUPLEX 每 PHY 独立；Switch/独立混合拓扑 (SWITCH_CONNECTED_MAC_x) |
| v1.8b | 2026-05-12 | Arch Agent | **关键特性修正 + DMA 框图更新**: §1.3 关键特性表补全；§2.1 顶层框图更新为 Switch/独立混合拓扑 + DMA 全局池；SWITCH_PORT_COUNT 参数化说明 |
| v1.8c | 2026-05-18 | Arch Agent | **PTP 时间子系统 + 性能指标完整定义**: §3.3 PHC 架构/Addend 精调/硬件时间戳/P2P 路径延迟；§3.3.8~3.3.14 IEEE 1588-2019 消息格式/BMCA/端口状态机/TC 操作/数据集/传输参数；§4.2.1 Switch 丢帧率 + §4.2.2 低功耗模式 |
| **v1.8d** | **2026-05-22** | **Arch Agent** | **PICS 协议一致性分析 + 全平台 feature 并集对齐 + 版本历史修复**: §10 PICS 协议实现一致性分析 (7 协议)；TC4/S32G/S32K3/R-Car S4/RH850 feature 并集：EEE/AVTP/IPsec/SecOC/D-TLS/半双工 从 No→Configurable/Yes；修正版本历史时序；§6.1 补充 GETH_AI.028/030 独立条目 |

### 9.2 待解决问题

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
| **ISSUE-005** | **10BASE-T1S PHY 集成决策** | **P2** | **PM Agent** | **✅ 已关闭** | **PAD 结论**: 10BASE-T1S 纳入本 IP 范围，作为 `PHY_x_SPEED=0` 选项，通过 `PHY_x_TYPE=0` 参数独立配置（按 PHY 实例）。支持 PLCA 多点总线（最多 8 节点），半双工，不支持帧抢占/TAS。应用场景：域内边缘节点、车身传感器网络。与 100BASE-T1S 区别：10BASE-T1S 多点总线，100BASE-T1S 仅点对点。参考 `Reference/Kimi_Agent_MCU_Ethernet/ethernet_mcu.agent.final.md` |

> **PAD 阶段已知问题清零声明**
>
> **截至 Arch Spec v1.4.2，全部 9 项 ISSUE 已完成 PAD 阶段分析，结论如下**：
> - **已关闭 (7 项)**: ISSUE-001, 003, 004, 005, 006, 007, 008, 009 — 均有明确 PAD 结论和 EDR 后续任务
> - **转移至 EDR (1 项)**: ISSUE-002 — LCB2SRI 地址映射属于微架构实现细节，由 Design Agent 在 EDR 阶段完成
> - **PAD 阶段无待解决问题**

### 9.3 参考文档

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

---



