# 802.1AE-2018 MACsec 协议分析与 PICS + MCU 实现映射

## 1. 协议概述

### 1.1 MACsec 架构与核心组件

IEEE Std 802.1AE-2018 定义了 **MAC Security (MACsec，媒体访问控制安全)** 协议，在数据链路层（Data Link Layer, OSI Layer 2）为以太网通信提供透明的安全保护服务。MACsec 的核心功能实体称为 **SecY (MAC Security Entity)**，每个 SecY 通过 **Common Port** 连接下层物理网络，向上层同时提供 **Controlled Port**（安全 MAC Service）和 **Uncontrolled Port**（非安全透明传输）两种服务实例 [^792^]。这一双端口架构使得密钥协商协议（如 MKA）可以在 Uncontrolled Port 上运行，而受保护的数据流量则通过 Controlled Port 传输，实现了密钥管理与用户数据的安全隔离。

MACsec 帧格式在原始以太网帧基础上引入两个关键字段：**SecTAG (Security Tag)** 和 **ICV (Integrity Check Value)**。SecTAG 长度为 8 或 16 字节，包含 MACsec EtherType (0x88E5)、TCI (TAG Control Information)、AN (Association Number, 4-bit)、SL (Short Length) 和 PN (Packet Number, 32-bit) 等字段，其中 SCI (Secure Channel Identifier, 64-bit) 为可选字段 [^792^]。ICV 由 Cipher Suite 生成，GCM-AES 系列使用 128 位（16 octets）ICV 长度 [^792^]。帧结构遵循以下格式：Destination MAC (6B) | Source MAC (6B) | SecTAG (8/16B) | Secure Data | ICV (8-16B)。

### 1.2 Cipher Suites 与密钥协商

IEEE Std 802.1AE-2018 在 Clause 14 中规定了四种标准 Cipher Suite [^792^]：**GCM-AES-128**（标识符 00-80-C2-00-01-00-00-01）为必选套件，使用 128 位密钥和 32 位 PN；**GCM-AES-256**（标识符 00-80-C2-00-01-00-00-02）为可选套件，提供 256 位密钥强度；**GCM-AES-XPN-128**（标识符 00-80-C2-00-01-00-00-03）和 **GCM-AES-XPN-256**（标识符 00-80-C2-00-01-00-00-04）为扩展包序号套件，使用 64 位 PN 而非 32 位，可保护超过 2^32 帧而不需更换 SAK，适用于高速链路场景 [^794^]。所有套件均基于 NIST SP 800-38D 指定的 AES-GCM 算法，IV 由 SCI (64-bit) 与 PN (32-bit 或 64-bit) 组合构成。Default Cipher Suite 的完整性保护为必选，机密性保护为可选 [^792^]。

密钥管理依赖于 IEEE Std 802.1X-2010 中定义的 **MKA (MACsec Key Agreement)** 协议。MKA 通过 **EAPOL (Extensible Authentication Protocol over LAN)** 传输消息，实现以下功能：对等体认证与授权、Connectivity Association (CA) 成员管理、Key Server 选举、SAK 生成与分发、存活检测以及 PN 耗尽预警 [^792^]。对于每个 Secure Channel (SC) —— 由 48-bit MAC Address 与 16-bit Port Identifier 组成的 SCI 唯一标识的单向信道 —— 可包含最多 4 个 Secure Association (SA)，每个 SA 使用独立的 **SAK (Secure Association Key)** 进行加解密操作 [^792^]。

### 1.3 车载安全意义

在区域控制器架构中，MACsec 提供了不可替代的链路层安全保障。与 AUTOSAR SecOC 相比，MACsec 的保护范围覆盖所有 Layer 2 以上流量，包括 ARP、VLAN Tag、IEEE 1722 AVTP、PTP (gPTP) 等控制协议，而 SecOC 仅保护应用层 PDU 载荷 [^803^]。MACsec 的逐跳（hop-by-hop）保护模式与 SecOC 的端到端（end-to-end）保护形成互补关系：MACsec 确保以太网链路上的数据不被窃听或篡改，SecOC 则验证应用层消息的真实性和完整性。

ISO/SAE 21434 (Road Vehicles — Cybersecurity Engineering) 要求车辆网络通信具备适当的加密保护机制。MACsec 作为 Layer 2 透明加密方案，符合 defence-in-depth 纵深防御策略 [^809^]，可有效防止中间人攻击（Man-in-the-Middle）、数据窃听（Eavesdropping）和帧注入（Frame Injection）等威胁。对于传输 ADAS 传感器数据（摄像头、雷达、激光雷达）、底盘控制信号（制动、转向、悬架）以及 OTA 更新数据的车载以太网链路，MACsec 提供了标准化的安全基座。

---

## 2. PICS + MCU 映射表

IEEE Std 802.1AE-2018 Annex A 提供了完整的 PICS proforma，涵盖 SecY 核心功能、Cipher Suite 支持、Key Agreement LMI、管理控制与统计等 8 大类共 200 余项条目。以下表格从 Annex A 中提取 35 项与车载区域控制器实现密切相关的 PICS 条目，映射至三款主流车规 MCU 平台的硬件支持能力。

| 项目编号 | 功能名称 | 条款 | 状态 | TC4x (CSS) | S32G | Renesas | 实现方式 | 备注 |
|:---------|:---------|:-----|:----:|:----------:|:----:|:-------:|:---------|:-----|
| SAP | SecY Controlled/Uncontrolled/Common Port 架构 | 5.3(a), 10 | M | Yes | 外部PHY | 外部PHY | HW | TC4x CSS内置SecY完整实现 [^339^] |
| GEN | Secure Frame Generation (安全帧生成) | 5.3(c), 10.5 | M | Yes | 外部PHY | 外部PHY | HW | TC4x CSS GMAC-128/256 @763MB/s [^339^] |
| VER | Secure Frame Verification (安全帧验证) | 5.3(d), 10.6 | M | Yes | 外部PHY | 外部PHY | HW | — |
| FMT | MACsec PDU 编码/解码 (SecTAG+ICV) | 5.3(e), Clause 9 | M | Yes | 外部PHY | 外部PHY | HW | — |
| SCI | 48-bit MAC + 16-bit Port Identifier | 5.3(f), 8.2.1 | M | Yes | 外部PHY | 外部PHY | HW | CSS支持21通道独立SCI [^339^] |
| PERF | Table 10-3 性能要求满足 | 5.3(g), 10.1 | M | Yes | PHY依赖 | PHY依赖 | HW | CSS 0.135us(64B)/1.335us(1KB) [^339^] |
| KAY | Key Agreement Entity LMI 支持 | 5.3(h), 10.7 | M | SW | SW | SW | SW | 需MCAL/软件栈实现MKA |
| MGT | 10.7 管理功能 | 5.3(i) | M | SW | SW | SW | SW | — |
| CS | Cipher Suite 实现 PROTECT/VALIDATE | 5.3(j), 14.1 | M | Yes | 外部PHY | 外部PHY | HW | — |
| CSI | Default Cipher Suite 完整性保护 | 5.3(k), 14.5 | M | Yes | Yes | Yes | HW/SW | GCM-AES-128认证only模式 |
| CSC | Default Cipher Suite 无offset机密性 | 5.4(e) | O→M | Yes | Yes | Yes | HW | 需加密模式支持 |
| CSO | Default Cipher Suite confidentiality offset | 5.4(f) | O | No | No | No | — | XPN套件不支持此功能 [^792^] |
| CSA | 额外标准 Cipher Suite (256/XPN) | 5.4(g) | O | Yes | PHY依赖 | PHY依赖 | HW | CSS支持GCM-AES-128/256 [^339^] |
| CSR | 每Cipher Suite最小资源 (1rxSC/2rxSAK/1txSC) | 5.3(l) | M | Yes | Yes | Yes | HW | TC4x支持21通道×多SA [^339^] |
| GEN-1 | protectFrames=False 旁路模式 | 10.5 | M | Yes | Yes | Yes | HW | — |
| GEN-2 | protectFrames=True 保护模式 | 10.5 | M | Yes | Yes | Yes | HW | — |
| GEN-5 | 禁止PN=0 | 10.5.2 | X | N/A | N/A | N/A | — | 硬件自动处理 |
| GEN-6 | PN 递增 | 10.5.2 | M | Yes | Yes | Yes | HW | — |
| GEN-11 | E bit 加密指示 | 9.5 | M | Yes | Yes | Yes | HW | — |
| VER-1 | SecTAG 验证与解码 | 10.6, 9.3-9.12 | M | Yes | 外部PHY | 外部PHY | HW | — |
| VER-6 | PN重放保护 (replayProtect) | 10.6.2, 10.6.4 | M | Yes | 外部PHY | 外部PHY | HW | replayWindow可配置 |
| VER-10 | 验证失败丢弃 (Strict模式) | 10.6.5 | M | Yes | Yes | Yes | HW/SW | — |
| KAY-1 | KaY读取MAC_Operational状态 | 10.7.2 | M | SW | SW | SW | SW | MKA协议栈功能 |
| KAY-2 | KaY设置ControlledPortEnabled | 10.7.4 | M | SW | SW | SW | SW | — |
| KAY-11 | KaY创建和控制SAK | 10.7.26, 10.7.28 | M | SW | SW | SW | SW | 需HSM支持密钥存储 |
| MGT2-1 | validateFrames 可配置 | 10.7.8 | O | Yes | Yes | Yes | SW | 运行时参数配置 |
| MGT2-4 | protectFrames 可配置 | 10.7.17 | O | Yes | Yes | Yes | SW | — |
| MGT4-8 | InPktsUntagged 统计 | 10.7.9 | M | Yes | 有限 | 有限 | HW | TC4x CSS提供完整计数器 |
| MGT4-14 | InPktsUnchecked (per SC) | 10.7.9 | M | Yes | 有限 | 有限 | HW | — |
| MGT4-26 | OutPktsProtected (per SC) | 10.7.18 | M | Yes | 有限 | 有限 | HW | — |
| CSA-2 | 非机密性完整性保护 (GCM-AES-256) | 14.2(a) | O | Yes | TBD | TBD | HW | 认证only模式 [^798^] |
| CSA-3 | 完全机密性保护 (无offset) | 14.2(d) | O/M | Yes | TBD | TBD | HW | — |
| CSA-4 | Offset机密性保护 | 14.2(e) | O | No | No | No | — | — |
| MSAK | 支持多于2个receive SAK | 5.4(c) | O | Yes | PHY依赖 | PHY依赖 | HW | 支持无缝密钥切换 |
| MSC | 支持多于1个receive SC | 5.4(b) | O | Yes | PHY依赖 | PHY依赖 | HW | TC4x 21通道 [^339^] |

**表格解读**：上述 35 项 PICS 条目覆盖了 MACsec 实现中的 5 大关键维度。第一，核心 SecY 架构（SAP、GEN、VER、FMT、SCI）是所有实现必须满足的 Mandatory 条目，TC4x 通过 CSS 硬件子系统完整实现了这些功能，而 S32G 和 Renesas R-Car 平台当前无片内 MACsec 硬件，必须依赖外部 PHY（如 NXP TJA1121 [^798^]）或软件实现。第二，性能要求（PERF）方面，802.1AE-2018 Table 10-3 规定了严格的延迟约束 —— SecY transmit/receive delay 不得超过最大 MPDU 线传输时间加上 4 倍 64-octet MPDU 线传输时间 [^792^]，SecY transmit delay variance 不得超过 transmit delay 本身 —— TC4x CSS 在 400MHz 下实现 64 字节帧处理仅需 0.135μs、1024 字节帧 1.335μs [^339^]，完全满足 100Mbps~5Gbps 车载以太网的延迟预算。第三，Cipher Suite 支持方面，TC4x CSS 明确支持 GCM-AES-128 和 GCM-AES-256（认证模式吞吐量 763MB/s）[^339^]，满足 CSA 条目要求；而 XPN 套件的支持取决于具体固件版本。第四，MKA 密钥协商（KAY-1~KAY-11）在所有平台均需软件实现，这包括 MKA 协议栈、EAPOL 帧处理以及与 HSM 的密钥交互。第五，管理统计功能（MGT4 系列）对车载故障诊断至关重要，TC4x CSS 硬件提供完整的每-SC/每-SA 统计计数器，而外部 PHY 方案的计数器能力取决于具体器件型号。值得注意的是，confidentiality offset（CSO/CSA-4）在所有分析平台均不支持，这与 XPN 套件本身不兼容 offset 功能的特性一致 [^792^]，且车载环境通常要求完全加密而非部分偏移。

---

## 3. 技术分析

### 3.1 TC4x CSS：唯一片内 MACsec MCU 的技术优势

Infineon AURIX TC4x 系列内置的 **CSS (Cyber Security Subsystem)** 是当前车规 MCU 市场中唯一集成硬件 MACsec 加速引擎的解决方案 [^339^] [^3^]。CSS 子系统在 400MHz 工作频率下提供 GMAC-128/256 认证吞吐量高达 763MB/s，对应 CMAC-128 555MB/s 和 CMAC-256 407MB/s 的处理能力 [^339^]。这一性能指标足以覆盖 5Gbps 车载以太网接口的线速处理需求，因为 5Gbps 理论线速约为 625MB/s，CSS 的 763MB/s GMAC 吞吐量留有约 22% 的性能裕量。

CSS 的架构设计包含 21 个独立安全通道（security channels），支持 MACsec、IPsec、D/TLS 和 SecOC (PDU level) 等多种安全协议 [^373^]。在 MACsec 场景下，21 通道意味着 TC4x 可同时保护 21 条独立以太网链路的 MACsec 通信，这对于需要多端口连接的区域控制器（Zonal Controller）至关重要 —— 例如同时连接传感器 ECU、执行器 ECU、相邻区域控制器和中央计算平台的场景。每个通道可独立配置 Cipher Suite、SCI 和密钥参数，硬件自动处理 SecTAG 插入/解析、ICV 生成/验证、PN 管理和重放保护检测。

从延迟角度分析，CSS 对 64 字节以太网帧（128-bit key）的处理延迟为 0.135μs [^339^]。以 100Mbps 车载以太网为例，64 字节帧的线传输时间为 5.12μs，加上 CSS 处理延迟 0.135μs，总延迟约为 5.255μs，远低于 Table 10-3 中规定的 "最大 MPDU 线传输时间 + 4×64-octet MPDU 线传输时间"（即 5×5.12μs = 25.6μs）的约束 [^792^]。对于 1Gbps 链路，64 字节帧线传输时间为 512ns，CSS 处理延迟 0.135μs 占总延迟的约 20.9%，仍满足性能要求。在 5Gbps 链路（TC4x 支持的最高以太网速率 [^373^]）上，64 字节帧线传输时间约 102ns，CSS 处理延迟成为延迟预算的主要组成部分，但仍处于可接受范围内。

### 3.2 S32G 外部 PHY 方案的成本与供应链分析

NXP S32G 系列作为车载网络处理器（Vehicle Network Processor）在区域控制器市场中占有重要地位，但其内部未集成 MACsec 硬件加速引擎 [^815^]。S32G 实现 MACsec 需依赖外部 PHY 器件，如 NXP TJA1121 [^798^] 或其他支持 IEEE 802.1AE-2018 的车载以太网 PHY。这一方案引入了多维度的成本和工程复杂性。

**BOM 成本方面**，每端口增加一颗 MACsec PHY 芯片（估算单价 $3-8）对区域控制器的材料成本产生直接影响。以典型的 4-6 端口区域控制器为例，仅 MACsec PHY 就增加 $12-48 的 BOM 成本。相比之下，TC4x 的 CSS 硬件为片上集成，不增加额外器件成本。**PCB 复杂度方面**，MACsec PHY 通常通过 MII/RMII/RGMII/SGMII 接口连接到 S32G 的以太网 MAC [^373^]，增加了走线数量、PCB 层数和布局难度。**供应链风险方面**，车规级 MACsec PHY（如 TJA1121）的供应稳定性、AEC-Q100 认证状态和多源采购（multi-sourcing）可用性均需纳入评估。目前支持 MACsec 的车规 PHY 供应商有限，主要集中于 NXP、Renesas 等少数厂商，供应链韧性低于通用以太网 PHY。

**性能约束方面**，外部 PHY 方案的 MACsec 吞吐量受限于 PHY 与 MAC 之间的接口速率。TJA1121 支持每安全通道双向密钥轮换，最多 4 个安全通道（TX 和 RX 方向）[^798^]，但其处理延迟、SAK 切换时间和统计计数器精度取决于 PHY 内部实现。Table 10-3 中规定的 "Transmit SAK 切换延迟 < 64-octet MPDU 线传输时间" 要求 [^792^] 在无丢包密钥切换场景下对外部 PHY 的硬件设计提出较高要求。相比之下，TC4x CSS 的片内集成设计可通过内部总线直接访问密钥存储和配置寄存器，SAK 切换路径更短、确定性更高。

### 3.3 MACsec 与 SecOC 的互补关系

在车载多层安全架构中，MACsec 与 AUTOSAR SecOC 并非竞争关系，而是分别在不同协议层次提供安全保护的互补方案 [^809^] [^803^]。

MACsec 位于 OSI Layer 2，提供逐跳的链路级保护。其保护范围覆盖完整的以太网帧 —— 包括 Ethernet Header、VLAN Tag、ARP/NDP、IP Header、TCP/UDP Header 以及上层应用数据 [^803^]。MACsec 对所有流量类型（Unicast、Multicast、Broadcast）均提供统一的加密和完整性保护，且仅需每链路一个安全关联（SA），密钥管理开销相对较低 [^804^]。MACsec 的启动时间经优化后可达到约 18ms（PHY linkup 到 MACsec ready）[^804^]，满足车载快速启动要求。

SecOC 位于 AUTOSAR 协议栈上层（PDU Level），提供端到端（end-to-end）的应用数据认证 [^809^]。SecOC 使用对称密钥和截断消息认证码（Truncated MAC）为特定 PDU 提供数据源认证和重放保护，其 Freshness Counter 管理和密钥分发由 AUTOSAR Crypto Stack 和 Key Manager 模块负责 [^806^]。SecOC 的优势在于保护范围延伸至应用层，可验证特定信号（如制动命令、转向角度）的真实性，且不受中间网络设备（交换机、网关）的影响。

两者的互补性体现在以下维度：第一，**保护层次互补** —— MACsec 保护链路传输过程中不被窃听或篡改，SecOC 保护应用层 PDU 端到端的真实性。攻击者即使通过物理接入链路获取 MACsec 加密帧，仍需破解 MACsec 密钥才能获取任何有效信息；若攻击者在交换机内部注入伪造帧，SecOC 可在应用层检测出异常。第二，**密钥管理分离** —— MACsec 使用 MKA 或静态 SAK 管理链路密钥，SecOC 使用 AUTOSAR Key Manager 管理 PDU 级密钥，两套密钥体系独立运行，降低了单点失效风险。第三，**部署粒度不同** —— MACsec 对所有以太网流量统一保护，SecOC 可针对安全关键信号选择性启用，两者结合实现灵活的 security-policy 配置。

### 3.4 车载部署中的密钥管理挑战

密钥管理是 MACsec 车载部署中最具挑战性的环节。802.1X/MKA 协议栈在传统企业网络中运行成熟，但车载环境提出了独特约束 [^804^] [^805^]：

**启动时间约束**：标准 MKA 实现（如 Linux macsec 模块）的密钥协商时间可达数秒 [^804^]，远超车载 ECU 上电启动要求（通常 <100ms）。Technica Engineering 等供应商通过优化 MKA 状态机、预配置 CAK (Connectivity Association Key) 和并行化处理，将 automotive MKA 启动时间缩短至约 18ms（含 MACsec 硬件配置）[^804^]。对于启动时间极敏感的底盘控制链路，静态 SAK（预配置密钥）方案可能更为合适。

**密钥分发与存储**：车载生产中每个 ECU 需要唯一的密钥材料。MKA 方案使用 CAK 派生 SAK，CAK 可通过工厂预配置证书（X.509）或预共享密钥（PSK）分发 [^805^]。静态 SAK 方案则需在出厂时通过安全编程（secure provisioning）将 SAK 写入 HSM 或受保护的 OTP 存储区。两种方式均需符合 ISO 21434 的密钥生命周期管理要求。

**密钥轮换机制**：GCM-AES-128 使用 32-bit PN，在 1Gbps 速率下约 34 秒耗尽 2^31 个 PN [^794^]，因此需要定期 SAK 更换。XPN-128/256 使用 64-bit PN，在相同速率下需要数年时间才会耗尽 [^794^]，显著降低密钥轮换频率。对于车载以太网（通常为 100Mbps），即使标准 32-bit PN 也能支撑数小时的连续通信，满足单次驾驶循环的需求。

---

## 4. 设计建议

### 4.1 区域控制器的 MACsec 部署策略

基于上述 PICS 分析和 MCU 能力评估，区域控制器的 MACsec 部署应遵循以下策略：

**MCU 选型优先级**：对于需要片内 MACsec 加速的区域控制器，Infineon TC4x 因其 CSS 硬件子系统提供目前唯一的 MCU 集成 MACsec 方案 [^339^]，应作为首选平台。TC4x 的 21 通道 CSS 支持最多 21 条独立以太网链路的 MACsec 保护，5Gbps 以太网 MAC 接口 [^373^] 满足高带宽传感器（如 8MP 摄像头、4D 成像雷达）的传输需求。对于已选用 S32G 或 Renesas R-Car S4 的项目，需通过外部 MACsec PHY（如 TJA1121 [^798^]）实现链路保护，设计时应充分评估 BOM 成本、PCB 面积和供应链风险。

**端口级部署决策**：并非所有车载以太网链路都需要 MACsec 保护。建议优先在以下链路启用 MACsec：第一，跨越车辆物理边界的外部接口（如 OTA 诊断口、V2X 天线链路）；第二，连接不同安全域的骨干链路（如区域控制器到中央计算平台）；第三，传输安全关键数据的链路（如底盘控制、制动信号）。同一安全域内部的传感器-区域控制器链路可根据威胁模型评估决定是否启用。

**验证模式选择**：PICS 条目 MGT2-1（validateFrames 可配置）支持 Disabled/Checked/Strict 三种验证模式。车载环境强烈建议使用 **Strict 模式**（VER-10），丢弃所有验证失败帧，防止恶意帧进入上层协议栈。仅在开发和调试阶段可临时使用 Checked 模式以收集统计信息。

### 4.2 Cipher Suite 选择建议

| 应用场景 | 推荐 Cipher Suite | PICS 关联 | 理由 |
|:---------|:------------------|:----------|:-----|
| 一般控制数据 (100Mbps) | GCM-AES-128 | CS, CSI, CSC | 必选套件，硬件支持最广泛，满足当前安全要求 |
| 高安全级别数据 (制动/转向) | GCM-AES-256 | CSA | 256 位密钥强度，满足未来量子计算威胁预备 |
| 高速数据流 (摄像头 1Gbps+) | GCM-AES-XPN-128 | CSA | 64 位 PN 避免高速下频繁密钥更换 [^794^] |
| 最高安全 + 高速数据 | GCM-AES-XPN-256 | CSA | 最高安全级别 + 大 PN 空间 |

实际部署中，建议区域控制器至少支持 GCM-AES-128 和 GCM-AES-256 两种套件（对应 PICS 条目 CS/CSI/CSC/CSA），以满足不同安全等级链路的差异化保护需求。对于 1Gbps 以上的高速链路，XPN 套件可有效减少 SAK 更换频率，但需确认 MCU 或 PHY 的硬件支持状态。TC4x CSS 在硬件层面支持 GCM-AES-128/256 [^339^]，XPN 支持需通过固件更新确认。

### 4.3 静态 SAK 与 MKA 的权衡

| 维度 | 静态 SAK (预配置密钥) | MKA (动态密钥协商) |
|:----|:---------------------|:-------------------|
| PICS 关联 | KAY-11 (SAK管理) | KAY-1~KAY-11 (完整MKA) |
| 启动时间 | < 10ms (密钥已预置) | ~18ms (优化automotive MKA) [^804^] |
| CPU 开销 | 极低 | 中 (EAPOL处理+状态机) |
| 密钥轮换 | OTA 或定期维护更新 | 自动 (PN耗尽前/定时触发) |
| 证书基础设施 | 不需要 | 可选 (EAP-TLS) 或 PSK |
| 适用场景 | 传感器-区域控制器固定链路 | 动态拓扑链路 (诊断/V2X) |

对于车载区域控制器的典型部署模式 —— 传感器/执行器 ECU 通过固定以太网链路连接到区域控制器 —— **静态 SAK 方案** 具有启动时间快、运行时确定性高、实现简单等优势。SAK 应安全存储在 HSM（Hardware Security Module）或 SHE（Secure Hardware Extension）中，通过 OTA 更新机制实现周期性密钥轮换。对于需要连接外部设备（如诊断仪、充电设施）的端口，**MKA 方案** 提供动态认证和密钥协商能力，可增强连接灵活性。混合部署（固定链路使用静态 SAK，外部端口使用 MKA）是最务实的区域控制器 MACsec 密钥管理策略。

### 4.4 性能优化建议

第一，**充分利用硬件统计计数器**（PICS MGT4-8~MGT4-29）：TC4x CSS 硬件提供完整的 MACsec 统计计数器（InPktsUntagged、InPktsNoTag、InPktsBadTag、InPktsOK、OutPktsProtected 等），应通过 AUTOSAR 诊断栈或自定义监控任务定期读取，用于检测异常流量模式和潜在攻击。第二，**启用重放保护**（PICS VER-6）：配置合适的 replayWindow 值，在保障网络鲁棒性（容忍一定乱序）的同时防止重放攻击。第三，**优化 SAK 切换流程**：Table 10-3 要求 Transmit SAK 切换延迟 < 64-octet MPDU 线传输时间 [^792^]，设计时应确保密钥切换期间不丢帧 —— CSS 硬件支持重叠接收 SA 的无缝切换。第四，**监控 PN 耗尽**：对于 GCM-AES-128（32-bit PN）在高速链路上的部署，需通过 KAY-9（PN 监控）功能在 PN 达到 75% 阈值前触发 SAK 更换 [^794^]，避免因 PN 溢出导致的安全风险。
