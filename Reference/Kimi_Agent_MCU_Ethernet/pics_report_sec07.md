# 802.3-2022 Ethernet 协议分析与 PICS + MCU 实现映射

## 1. 协议概述

IEEE Std 802.3-2022 是 IEEE 发布的最新版 Ethernet 标准，全文超过 7000 页，涵盖了从 10 Mbps 到 400 Gbps 的各种物理层（PHY, Physical Layer）规范[^1^]。该标准定义了以太网的 MAC（Media Access Control，媒体访问控制）子层和多种 PHY 实现，包括线缆类型、接口规范、电气特性、协议一致性等内容。在汽车电子领域，标准中定义的单对双绞线车载以太网（Single-Pair Automotive Ethernet）已成为现代汽车电子电气架构（EEA, Electrical/Electronic Architecture）的核心通信技术，支撑从车身控制到自动驾驶域控制器的全层级数据交换需求。

在车载相关物理层规范方面，802.3-2022 纳入了多种单对双绞线（single balanced pair）标准，这些规范通过单对线缆实现全双工通信，相较传统以太网大幅减少布线重量与成本。**100BASE-T1（Clause 96）** 源自 IEEE 802.3bw-2015，采用 PAM3 调制和 3B/4B 编码方案，支持 100 Mbps 全双工通信，链路传输距离可达 15 米，是当前车载网络中部署最广泛的物理层，主要用于车身控制、传感器接口和信息娱乐等领域[^2^]。**1000BASE-T1（Clause 97）** 源自 IEEE 802.3bp-2016，采用 PAM3 调制配合 80B/81B 编码和 RS-FEC（450,406）前向纠错，支持 1 Gbps 速率，主要用于 ADAS 域控制器、IVI 系统和高速传感器聚合场景[^3^]。**10BASE-T1S（Clause 147-148）** 源自 IEEE 802.3cg-2019，采用差分曼彻斯特编码（DME, Differential Manchester Encoding），支持 10 Mbps 半双工通信，其特色在于多点总线拓扑（multidrop）和 PLCA（Physical Layer Collision Avoidance，物理层冲突避免）机制，可在同一总线上连接多达 8 个节点，适用于低成本传感器/执行器网络[^4^]。**Multi-Gig（Clause 149-150）** 源自 IEEE 802.3ch-2020，包含 2.5GBASE-T1、5GBASE-T1 和 10GBASE-T1，采用 PAM4 调制和 64B/65B 编码，主要用于下一代 ADAS/AD 域控制器和骨干网络，支持 15 米传输距离（10GBASE-T1 为 10 米）[^5^]。

MAC 层规范（Clause 3）定义了统一的帧格式，包括目的地址（DA, Destination Address）、源地址（SA, Source Address）、Length/Type 字段、MAC Client Data 和 FCS（Frame Check Sequence）校验。所有车载 PHY 均使用相同的 MAC 帧格式，通过不同的 Reconciliation Sublayer（协调子层）接口与 PHY 交互。关键接口包括 MII（Media Independent Interface，媒体独立接口，4-bit 并行，25 MHz）、RGMII（Reduced Gigabit MII，4-bit DDR，125 MHz）、SGMII（Serial GMII，1.25 Gbps 串行）和 USXGMII（Universal Serial 10GE MAC-PHY Interface，10 Gbps 串行），这些接口的选择直接影响 MCU 与 PHY 之间的引脚数量和 PCB 布线复杂度[^6^]。

## 2. 车载 PHY PICS + MCU 映射

PICS（Protocol Implementation Conformance Statement，协议实现一致性声明）是 IEEE 802.3 标准中定义的规范化表格，用于声明特定实现对标准各项功能的支持情况。以下各节从 802.3-2022 标准原文 PICS proforma 附录中提取车载相关条目，并与主流车载 MCU（TC4x、S32G、S32K3、R-Car S4）的硬件能力进行映射分析。

### 2.1 100BASE-T1（Clause 96）PICS 映射

100BASE-T1 的 PICS 分布在 802.3-2022 第 96.11 节（PDF 页码 3932-3980），涵盖 PCS（Physical Coding Sublayer，物理编码子层）、PMA（Physical Medium Attachment，物理媒介连接子层）和电气参数。Clause 96 定义的 100BASE-T1 采用 PAM3 调制和 3B/4B 编码，符号率为 66.666 Mbaud，MASTER 模式时钟容差为 ±100 ppm[^7^]。

| 项目编号 | 功能名称 | 状态 | TC4x 支持 | S32G 支持 | S32K3 支持 | 实现方式 | 备注 |
|---------|---------|------|-----------|-----------|------------|---------|------|
| PCS | 100BASE-T1 PCS | M | 是 (外部 PHY) | 是 (外部 PHY) | 是 (外部 PHY) | PHY 内部 | 3B/4B 编码 + PAM3 调制[^7^] |
| PMA | 100BASE-T1 PMA | M | 是 (外部 PHY) | 是 (外部 PHY) | 是 (外部 PHY) | PHY 内部 | 含 Link Monitor 功能 |
| MII | PHY associated with MII | O | 是 | 是 | 是 | HW (MAC) | TC4x/S32G/S32K3 GMAC 均支持 MII |
| MDIO | MDIO 寄存器访问 | O | 是 | 是 | 是 | HW (MDC/MDIO) | Clause 45 寄存器空间 |
| AN | Auto-negotiation (Clause 98) | O | 取决于 PHY | 取决于 PHY | 取决于 PHY | PHY 内部 | 需 PHY 硬件支持 |
| PCT1-14 | PCS Transmit 功能组 | M | N/A | N/A | N/A | PHY 内部 | Scrambler + 3B/4B 转换 |
| PCR1-10 | PCS Receive 功能组 | M | N/A | N/A | N/A | PHY 内部 | Descrambler + 错误处理 |
| PCR6 | 自动极性检测 | O | N/A | N/A | N/A | PHY 内部 | 接收信号极性自动校正 |
| PMF1-9 | PMA 功能组 | M | N/A | N/A | N/A | PHY 内部 | 含 maxwait_timer (200ms)[^7^] |
| PME1-15 | 电气规范组 | M | N/A | N/A | N/A | PHY 内部 | TX 幅度 1.0Vpp ±20% |
| AUTO | 车载环境安装 | O | 是 | 是 | 是 | 系统设计 | 需满足 CISPR 25 / ISO 11452 |

100BASE-T1 的全部 PCS、PMA 和电气规范均在 PHY 芯片内部实现，MCU 端仅需通过 MII 接口与 PHY 交互。TC4x、S32G 和 S32K3 的 GMAC（Gigabit MAC）模块均支持 MII 接口，其中 S32K3 的 EMAC（Ethernet MAC）仅支持 10/100 Mbps 速率，因此与 100BASE-T1 的匹配最为直接[^8^]。从系统架构角度，100BASE-T1 的链路建立时间（link-up time）从 power_on 起不得超过 100 ms（PMF6），该约束对 MCU 端驱动程序的 PHY 初始化时序提出了明确要求——驱动程序需在 PHY 复位后等待至少 100 ms 才能完成链路状态轮询。此外，PCS 回环（PCL1-PCL4）功能对于产线测试和故障诊断至关重要，需通过 MDIO 寄存器 3.0.14 位启用，该功能在所有支持 MDIO 接口的 MCU 上均可通过软件配置实现。

### 2.2 1000BASE-T1（Clause 97）PICS 映射

1000BASE-T1 的 PICS 分布在 802.3-2022 第 97.11 节（PDF 页码 4034-4055）。相较于 100BASE-T1，1000BASE-T1 引入了更复杂的编码方案和可选的 EEE（Energy-Efficient Ethernet，节能以太网）功能，PCS 采用 80B/81B 编码配合 RS-FEC（450,406）前向纠错，符号率为 750 Mbaud[^9^]。

| 项目编号 | 功能名称 | 状态 | TC4x 支持 | S32G 支持 | S32K3 支持 | 实现方式 | 备注 |
|---------|---------|------|-----------|-----------|------------|---------|------|
| PCS | 1000BASE-T1 PCS | M | 是 (外部 PHY) | 是 (外部 PHY) | 部分 (外部 PHY) | PHY 内部 | 80B/81B + RS-FEC(450,406)[^9^] |
| PMA | 1000BASE-T1 PMA | M | 是 (外部 PHY) | 是 (外部 PHY) | 部分 (外部 PHY) | PHY 内部 | PAM3 调制，750 Mbaud |
| EEE | EEE 低功耗空闲 | O | 取决于 PHY | 取决于 PHY | 否 | PHY 内部 | LPI / QUIET / REFRESH 模式 |
| OAM | PCS-level OAM 通道 | O | 取决于 PHY | 取决于 PHY | 否 | PHY 内部 | 带外管理通道 |
| PCT1-7 | PCS Transmit 基础功能 | M | N/A | N/A | N/A | PHY 内部 | 含 Idle / LP_IDLE 处理 |
| PCT8 | EEE IDLE 转换 | EEE:M | N/A | N/A | N/A | PHY 内部 | EEE 不支持时转 IDLE |
| PCT9-12 | RS-FEC 编码器 | M | N/A | N/A | N/A | PHY 内部 | 校验计算前寄存器初始化为零 |
| PCT13-22 | Scrambler + EEE 状态图 | M/EEE:M | N/A | N/A | N/A | PHY 内部 | MASTER/SLAVE 种子值不同 |
| PCR1-10 | PCS Receive + Descrambler | M | N/A | N/A | N/A | PHY 内部 | 侧流解扰，公式(97-3/4)[^9^] |
| PME1-8 | 测试模式 | M | N/A | N/A | N/A | PHY 内部 | MDIO reg 1.2304.15:13 控制 |
| PME9-10 | TX 幅度 / 下垂 | M | N/A | N/A | N/A | PHY 内部 | 1.0Vpp ±20%，下垂 < 25% |
| PME11 | TX 抖动 | M | N/A | N/A | N/A | PHY 内部 | < 60 ps rms (test mode 1) |
| PME12 | 功率谱密度 | M | N/A | N/A | N/A | PHY 内部 | 满足模板约束 |
| PME13-15 | RX 输入 / 串扰 / 回损 | M | N/A | N/A | N/A | PHY 内部 | BER < 1e-7，外来串扰 <-100 dBm/Hz |

1000BASE-T1 的总延迟约束（发送 + 接收）不得超过 7168 bit times，即 7168 ns（G3 项），该约束对支持 TSN（Time-Sensitive Networking）的 gPTP（generalized Precision Time Protocol）实现具有直接影响——PHY 延迟的不确定性会累积到时钟同步误差中[^10^]。TC4x 和 S32G 的 GMAC 均支持 RGMII 接口，可直接对接 1000BASE-T1 PHY；S32G 还支持 SGMII 接口，可通过 SerDes 以单对差分线连接 PHY，减少引脚数量。S32K3 的 EMAC 仅支持 10/100 Mbps，但部分 S32K3 型号集成的 GMAC 模块可支持 RGMII 和 1G 速率，选型时需注意具体型号差异。EEE 功能（PCT8、PCT16-22）在车载应用中通常因实时性要求而禁用，因为 LPI（Low Power Idle）模式会在链路上引入微秒级的唤醒延迟，可能破坏 TSN 时间门控调度的确定性[^11^]。

### 2.3 10BASE-T1S + PLCA（Clause 147-148）PICS 映射

10BASE-T1S 的 PICS 分布在 802.3-2022 第 147.12 节（PDF 页码 5924-5950），PLCA（Physical Layer Collision Avoidance）PICS 在第 148.5 节（PDF 页码 5951-5960）。10BASE-T1S 是唯一支持半双工（half-duplex）模式的车载以太网 PHY，采用 DME 编码，符号率为 10 MBd，其多点总线（multidrop）拓扑和 PLCA 冲突避免机制使其可直接替代 CAN/LIN 网络[^12^]。

| 项目编号 | 功能名称 | 状态 | TC4x 支持 | S32G 支持 | S32K3 支持 | 实现方式 | 备注 |
|---------|---------|------|-----------|-----------|------------|---------|------|
| HALF | 半双工模式 | M | 是 (LETH) | 部分 | 部分 | MAC 配置 | 10BASE-T1S 仅支持半双工 |
| MULT | 多点总线模式 | O | 是 (LETH) | 否 | 否 | PHY + MAC | 最多 8 节点/总线[^12^] |
| FULL | 全双工点对点 | O | 是 | 是 | 是 | PHY 配置 | 点对点模式可选 |
| PCS | 10BASE-T1S PCS | M | 是 (外部 PHY) | 是 (外部 PHY) | 是 (外部 PHY) | PHY 内部 | 5B/4B + DME 编码 |
| PMA | 10BASE-T1S PMA | M | 是 (外部 PHY) | 是 (外部 PHY) | 是 (外部 PHY) | PHY 内部 | 含 Link Monitor |
| AN | Auto-negotiation (Clause 98) | O | 是 | 部分 | 部分 | PHY 内部 | 含 PLCA 参数协商 |
| PCST1-6 | PCS Transmit 功能 | M | N/A | N/A | N/A | PHY 内部 | g(x)=x^7+x^4+1 scrambler |
| PCSR1-4 | PCS Receive 功能 | M | N/A | N/A | N/A | PHY 内部 | 自同步 descrambler |
| CD1-4 | 碰撞检测 (半双工) | HALF:M | 是 | 有限 | 有限 | MAC 硬件 | MII COL/CRS 信号 |
| PLCA1-4 | RS 对 PLCA 信号反应 | M | 是 (LETH) | 否 | 否 | HW (LETH) | rx_cmd = BEACON/COMMIT |
| CON1 | PLCA Control 功能 | M | 是 (LETH) | 否 | 否 | HW (LETH) | 符合图 148-3/148-4[^13^] |
| DAT1 | PLCA Data 功能 | M | 是 (LETH) | 否 | 否 | HW (LETH) | 符合图 148-5/148-6 |
| STS1 | PLCA Status 功能 | M | 是 (LETH) | 否 | 否 | HW (LETH) | 符合图 148-7 |
| PMAE8-11 | TX 电气 / 负载 | M/MULT:M | N/A | N/A | N/A | PHY 内部 | 多点模式 50Ω ±0.1% |
| MDI1-4 | MDI 规范 | M/MULT:M | N/A | N/A | N/A | PHY 内部 | 短路保护，最高 60V DC |

10BASE-T1S 的技术独特之处在于其半双工操作和 PLCA 机制的协同工作。在传统半双工以太网中，CSMA/CD（Carrier Sense Multiple Access with Collision Detection）机制在节点数量增加时碰撞概率急剧上升，导致有效吞吐量下降；PLCA 通过引入 BEACON（信标）时隙和 COMMIT（承诺）信号，将总线访问转化为确定性的轮询时隙分配，每个节点在预定时间窗口内发送数据，从根本上消除了碰撞[^13^]。TC4x 的 LETH（Lightweight Ethernet）模块是业界首批在硬件层面完整支持 PLCA 的 MAC 实现之一，包括 PLCA Control、Data 和 Status 三个状态机的硬件加速，这使得 TC4x 在 10BASE-T1S 应用场景中具有显著优势。S32G 和 S32K3 目前缺乏对 PLCA 的硬件支持，若需使用 10BASE-T1S 需依赖软件模拟，实时性和效率均受限。从电气角度，多点模式要求 PHY 在发送间隙进入高阻抗状态（PMAE16），且总线终端阻抗从 100Ω（点对点）变为 50Ω（多点），这些参数需在 PHY 选型和 PCB 设计中严格匹配[^12^]。

### 2.4 Multi-Gig（Clause 149-150）PICS 映射

Multi-Gig 车载以太网（2.5G/5G/10GBASE-T1）的 PICS 分布在 802.3-2022 第 149.11 节（PDF 页码 6052-6087）和第 150.11 节（PDF 页码 6088-6100）。这些 PHY 采用 PAM4 调制（四级脉冲幅度调制）和 64B/65B 编码配合 RS-FEC 前向纠错，实现多 Gbps 速率下的单对线传输[^14^]。

| 项目编号 | 功能名称 | 状态 | TC4x 支持 | S32G 支持 | R-Car S4 支持 | 实现方式 | 备注 |
|---------|---------|------|-----------|-----------|---------------|---------|------|
| PCS | Multi-Gig PCS | M | 是 (外部 PHY) | 部分 | 是 (外部 PHY) | PHY 内部 | 64B/65B + RS-FEC |
| PMA | Multi-Gig PMA | M | 是 (外部 PHY) | 部分 | 是 (外部 PHY) | PHY 内部 | PAM4 调制 |
| 2.5G | 2.5GBASE-T1 | M | 是 | 部分型号 | 是 (2.5G RGMII) | PHY + MAC | USXGMII/RGMII 接口 |
| 5G | 5GBASE-T1 | M | 是 | 否 | 否 | PHY + MAC | 仅 TC4x 支持 |
| 10G | 10GBASE-T1 | M | 否 | 否 | 否 | N/A | 当前无车载 MCU 支持 |
| EEE | EEE capability | O | 取决于 PHY | 取决于 PHY | 取决于 PHY | PHY 内部 | 低功耗空闲模式 |
| OAM | PCS-level OAM | O | 取决于 PHY | 取决于 PHY | 取决于 PHY | PHY 内部 | 运维管理通道 |
| PCT1-13 | PCS Transmit 功能 | M | N/A | N/A | N/A | PHY 内部 | 含 Idle/LPI 以 4 个为一组插入/删除 |
| PCR1-8 | PCS Receive + RS-FEC Decode | M | N/A | N/A | N/A | PHY 内部 | Reed-Solomon 解码器 |
| PME1-5 | 测试模式 | M | N/A | N/A | N/A | PHY 内部 | PAM4 Gray 编码序列 (test mode 4) |
| PME6 | TX 输出幅度 | M | N/A | N/A | N/A | PHY 内部 | 2.0Vpp ±10%（PAM4 电平）[^14^] |
| PME7 | TX 下垂 | M | N/A | N/A | N/A | PHY 内部 | < 15% (test mode 1) |
| PME8 | TX 抖动 | M | N/A | N/A | N/A | PHY 内部 | 满足 Table 149-18/19 |
| PME9 | 功率谱密度 | M | N/A | N/A | N/A | PHY 内部 | 满足模板约束 |
| PME10-11 | RX 输入 / 串扰抑制 | M | N/A | N/A | N/A | PHY 内部 | BER < 1e-7，外来串扰抑制 |

Multi-Gig PHY 的延迟约束以 pause_quanta 为单位表示：2.5G/5G/10G（1x 模式）均为 10240 bit times（20 pause_quanta），5G/10G（2x 模式）为 13824 bit times（27 pause_quanta），10G（4x 模式）为 20480 bit times（40 pause_quanta）[^15^]。这种以 pause_quanta 为单位的延迟度量方式直接关联到 802.3x PAUSE 帧和 802.1Qbb PFC（Priority-based Flow Control）的操作——每个 pause_quantum 等于 512 bit times，接收方在解析 PAUSE 帧后必须在指定 quanta 数内完成反应。TC4x 是目前唯一在硬件层面同时支持 2.5G 和 5GBASE-T1 的车载 MCU，其集成的 USXGMII（Universal Serial 10GE MAC-PHY Interface）接口以 10.3125 Gbps 的串行速率与 PHY 通信，仅需一对差分线即可完成全双工数据收发，相较 RGMII 的 12 根数据线大幅降低了引脚占用和 PCB 布线复杂度[^16^]。R-Car S4 通过 2.5G RGMII 接口支持 2.5GBASE-T1，但其 3 端口 Switch 架构更适合网关而非高带宽终端应用。10GBASE-T1 目前在车载 MCU 中尚无支持，主要受限于 SerDes 速率和功耗约束。

## 3. MAC 层 PICS + MCU 映射

MAC 层 PICS 基于 IEEE 802.3-2022 Clause 3（MAC 帧格式）和 Clause 4（MAC 操作）创建，适用于所有车载 PHY 实现。MAC 层功能直接由 MCU 的 GMAC/EMAC 硬件模块实现，因此 MCU 支持情况与 PHY 类型无关。

### 3.1 MAC 帧格式和处理

| 项目编号 | 功能名称 | 状态 | TC4x 支持 | S32G 支持 | S32K3 支持 | 实现方式 | 备注 |
|---------|---------|------|-----------|-----------|------------|---------|------|
| MAC-F1 | Preamble 发送 (7×0x55) | M | 是 | 是 | 是 | HW (GMAC) | 硬件自动附加前导码 |
| MAC-F2 | SFD 发送 (0xD5) | M | 是 | 是 | 是 | HW (GMAC) | 起始帧定界符 |
| MAC-F3 | DA 字段处理 (6 bytes) | M | 是 | 是 | 是 | HW (GMAC) | 目的 MAC 地址识别 |
| MAC-F4 | SA 字段处理 (6 bytes) | M | 是 | 是 | 是 | HW (GMAC) | 源 MAC 地址插入 |
| MAC-F5 | Length/Type 字段 (2 bytes) | M | 是 | 是 | 是 | HW (GMAC) | 长度或类型解释 |
| MAC-F6 | MAC Client Data (46-1500 bytes) | M | 是 | 是 | 是 | HW (GMAC) | 含 padding 至 46 字节 |
| MAC-F7 | FCS (CRC-32) 生成与校验 | M | 是 | 是 | 是 | HW (GMAC) | 自动计算并附加/验证 |
| MAC-F8 | 最小帧长 64 bytes | M | 是 | 是 | 是 | HW | 自动丢弃 runt 帧 |
| MAC-F9 | 最大帧长 1518 bytes | M | 是 | 是 | 是 | HW | 含 VLAN tag 1522 bytes |
| MAC-F10 | IPG (96 bit times) | M | 是 | 是 | 是 | HW | 包间间隔自动维护 |
| MAC-F11 | Q-tagged VLAN 帧 (802.1Q) | O | 是 | 是 | 部分 | HW | 硬件 tag insert/remove[^17^] |
| MAC-F12 | Envelope frame (2000 bytes) | O | 是 | 是 | 否 | HW/SW | 巨型帧支持 |

MAC 帧格式处理是 GMAC 硬件的基本功能，所有三款 MCU 均在硬件层面完整支持标准帧处理流程。FCS（CRC-32）的硬件自动生成与校验功能对功能安全具有重要意义——错误帧的自动丢弃可避免将损坏数据传递给上层协议栈，降低因数据传输错误导致的安全风险[^18^]。TC4x 和 S32G 的 GMAC 支持硬件 VLAN tag 的插入与剥离（MAC-F11），这在车载网络中尤为重要，因为 802.1Q VLAN 标签（PCP 字段）与 802.1Qbv 时间门控和 802.1Qbu 帧抢占机制紧密耦合，硬件层面的 tag 处理可避免软件干预引入的延迟不确定性。S32K3 的 VLAN 支持相对有限，主要通过软件实现 tag 操作，在处理高吞吐量的 VLAN 流量时可能成为瓶颈。

### 3.2 流量控制（PAUSE / PFC）

| 项目编号 | 功能名称 | 状态 | TC4x 支持 | S32G 支持 | S32K3 支持 | 实现方式 | 备注 |
|---------|---------|------|-----------|-----------|------------|---------|------|
| MC1 | MAC Control 帧识别 (0x8808) | O | 是 | 是 | 部分 | HW | Length/Type = 0x8808 |
| PAUSE1-10 | 802.3x PAUSE 帧操作 | MC1:M | 是 | 是 | 是 | HW (GMAC) | Opcode 0x0001，pause_time 0-65535[^19^] |
| PFC1-10 | 802.1Qbb PFC 操作 | O | 是 | 是 | 部分 | HW (GMAC) | Opcode 0x0101，8 优先级独立控制 |
| PAUSE5 | PAUSE 接收反应时间 | MC1:M | < 512 bit times | < 512 bit times | < 512 bit times | HW | 收到 PAUSE 后暂停传输 |
| PFC6-7 | PFC 发送/接收状态图 | PFC1:M | 是 | 是 | 否 | HW | 符合图 31D-3/4/5 |
| PFC8 | 每优先级独立 PAUSE timer | PFC1:M | 是 | 是 | 否 | HW | 8 个优先级各独立计时 |

PAUSE（802.3x）和 PFC（802.1Qbb）流量控制机制在车载 TSN 网络中扮演关键角色。PAUSE 帧以全局方式暂停链路传输，适用于单流量类型的场景；PFC 则支持按优先级（0-7）独立暂停，使得高优先级时间关键流量（如传感器数据）可继续传输，而低优先级尽力而为流量（如诊断日志）被临时抑制[^20^]。TC4x 和 S32G 的 GMAC 均在硬件层面完整支持 PAUSE 和 PFC 帧的自动生成、解析和执行，包括每优先级独立 timer（PFC8）的硬件维护。S32K3 仅支持基础 PAUSE 功能，PFC 支持有限。从 TSN 角度看，PFC 是 802.1Qbv（增强流量整形）和 802.1Qbu（帧抢占）的必要补充——当 TSN 桥的缓冲区接近溢出时，PFC 可向上游节点发送暂停信号以防止帧丢失，这种背压（backpressure）机制对于维持确定性延迟至关重要[^21^]。

### 3.3 MII / RGMII / SGMII / USXGMII 接口

| 项目编号 | 功能名称 | 状态 | TC4x 支持 | S32G 支持 | S32K3 支持 | R-Car S4 支持 | 备注 |
|---------|---------|------|-----------|-----------|------------|---------------|------|
| MII1-12 | MII 接口 (4-bit, 25 MHz) | MII:M | 是 | 是 | 是 (EMAC) | 否 | 100BASE-T1 / 10BASE-T1S |
| GMII1-12 | GMII 接口 (8-bit, 125 MHz) | GMII:M | 是 | 是 | 否 | 否 | 1000BASE-T1 (较少使用) |
| RGMII | RGMII 接口 (4-bit DDR) | O | 是 | 是 | 是 (部分) | 是 (2.5G) | 最常用 1G/2.5G 接口[^22^] |
| SGMII1-5 | SGMII 串行接口 (1.25 Gbps) | O | 是 | 是 | 否 | 是 | SerDes，8B/10B 编码 |
| USXGMII | USXGMII 接口 (10 Gbps) | O | 是 | 否 | 否 | 否 | TC4x 独有，5G 支持 |

接口选型直接影响 MCU-PHY 之间的引脚数量、PCB 布线复杂度和信号完整性。MII 接口使用 12 根数据线（TXD[3:0] + RXD[3:0] + 控制信号）+ MDC/MDIO，适用于 100 Mbps 场景；RGMII 通过 DDR（Double Data Rate）技术在 4 根数据线上实现 1 Gbps 传输，是 1000BASE-T1 最广泛采用的接口，仅需 6 根信号线（TXC + TXD[3:0] + TX_CTL + RXC + RXD[3:0] + RX_CTL）+ MDC/MDIO[^22^]。SGMII 以 1.25 Gbps 串行速率传输，通过 SerDes 实现，仅需一对差分发送线和一对差分接收线，显著减少了引脚占用，但需要 MCU 集成 SerDes 收发器。USXGMII 是 TC4x 的差异化优势接口，以 10.3125 Gbps 串行速率支持 2.5G/5G PHY，仅需两对差分线（Tx+/Tx-, Rx+/Rx-），相较 RGMII 的 12 根数据线减少了 83% 的引脚占用[^16^]。R-Car S4 支持 2.5G RGMII 变体（RGMII-v2.0 扩展），可实现 2.5Gbps 速率，但 5G 及以上速率仍需 USXGMII。

## 4. PHY 接口选型建议

### 4.1 车载区域控制器 PHY 选型矩阵

| 应用场景 | 推荐 PHY | 推荐 MCU | 接口 | 关键考量 |
|---------|---------|---------|------|---------|
| 车身域 (Door/Seat/Light) | 100BASE-T1 | S32K3 | MII/RMII | 成本优先，引脚少 |
| 传感器/执行器总线 | 10BASE-T1S + PLCA | TC4x (LETH) | MII | 多点总线替代 CAN/LIN |
| 网关 (Central Gateway) | 1000BASE-T1 × N | S32G | RGMII/SGMII | 端口数量，TSN 支持 |
| ADAS 域控制器 | 1000BASE-T1 / 2.5GBASE-T1 | TC4x, S32G | RGMII/USXGMII | 带宽、确定性延迟 |
| IVI 系统 | 1000BASE-T1 | TC4x, S32G | RGMII | 带宽、AVB/TSN |
| 高分辨率摄像头聚合 | 2.5GBASE-T1 × N | TC4x | USXGMII | 多路摄像头数据汇聚 |
| 骨干网络 (Backbone) | 2.5G/5GBASE-T1 | TC4x | USXGMII | 最高带宽、USXGMII 引脚优势 |
| 中央计算平台 | 10GBASE-T1 (未来) | 高端 SoC | USXGMII | 当前无车载 MCU 支持 |

### 4.2 速率-成本-距离权衡分析

车载以太网 PHY 的选型需在数据速率、物料成本和传输距离三个维度之间进行权衡。100BASE-T1 作为最成熟的车载以太网标准，其 PHY 芯片单价已降至 2-3 美元量级，链路预算支持 15 米传输距离，满足绝大多数车内节点间通信需求；1000BASE-T1 PHY 单价约 4-6 美元，传输距离同样为 15 米，但单芯片即可支持多路 100M 摄像头的数据汇聚[^23^]。2.5GBASE-T1 和 5GBASE-T1 的 PHY 目前处于量产初期，单价在 8-15 美元区间，传输距离 15 米（5G 模式下），主要面向下一代高分辨率摄像头（8MP+）和 4K 显示器连接场景。10GBASE-T1 受限于信号完整性约束，传输距离降至 10 米，且当前尚无车载级 MCU 集成 10G MAC，预计将在 2026-2027 年后随着中央计算架构（Central Compute）的普及而逐步商用。

从区域控制器（Zonal Controller）架构演进角度看，10BASE-T1S 的多点总线拓扑提供了独特的成本优势。传统点对点（point-to-point）100BASE-T1 连接每个终端节点均需独立 PHY 和线缆，而 10BASE-T1S 的 multidrop 总线可在单条线上串联 8 个节点，总线型拓扑使线束重量减少 30-50%，节点成本降低至每个 1-2 美元（PHY 复用总线）[^24^]。TC4x 的 LETH 模块在硬件层面支持 PLCA，使其成为 10BASE-T1S 应用的首选 MCU；对于不使用 PLCA 的纯半双工 CSMA/CD 模式，S32K3 亦可满足需求，但需注意碰撞概率随节点数增加的退化问题。

### 4.3 TC4x USXGMII 差异化优势

TC4x 的 USXGMII 接口是其在中高端车载网络应用中的核心差异化竞争力。传统 RGMII 接口在 2.5G 速率下需要 12 根数据线（含时钟和控制），且 DDR 时序约束（setup/hold time）在 625 MHz 等效频率下变得极为苛刻，PCB 布线长度匹配要求通常小于 5 mm；USXGMII 通过 SerDes 技术将接口压缩至两对差分线，不仅减少 83% 的引脚占用，还将高速信号完整性问题从并行总线转换为受控阻抗差分对问题，PCB 布线复杂度大幅降低[^16^]。对于需要 4-8 路 2.5G 接口的 ADAS 域控制器，USXGMII 的引脚节省效应更为显著——8 路 RGMII 需要 96 根数据线，而 8 路 USXGMII 仅需 16 根差分线（32 引脚），加上共享参考时钟和复位信号，总引脚数控制在 40 以内，这在 BGA 封装引脚资源有限的车规 MCU 中具有决定性优势。

### 4.4 10BASE-T1S 的多点总线价值

10BASE-T1S + PLCA 的技术组合在车载传感器/执行器网络领域代表了从" switched Ethernet" 到"bus Ethernet" 的范式回归。传统车载网络中，CAN（1 Mbps）和 LIN（20 Kbps）采用总线拓扑但带宽有限；100BASE-T1 虽提供 100 Mbps 带宽但强制点对点拓扑，每个节点需独立 PHY 和交换机端口。10BASE-T1S 首次将以太网级别的带宽（10 Mbps）与总线拓扑的经济性结合，通过 PLCA 机制解决了传统 CSMA/CD 在节点数增加时的碰撞退化问题[^24^]。从 PICS 实现角度，PLCA 的 Control、Data 和 Status 三个状态机（CON1、DAT1、STS1）若在软件中模拟，每比特处理延迟约 100-500 ns（取决于 CPU 频率和缓存状态），而 TC4x LETH 的硬件实现将延迟控制在 10 ns 以下，确保了 10 Mbps 速率下每比特 100 ns 时间窗口内的确定性响应。对于需要 ASIL-B/D 功能安全等级的车身控制应用，这种硬件确定性的 PLCA 实现是满足故障容错时间间隔（FTTI）要求的关键保障。
