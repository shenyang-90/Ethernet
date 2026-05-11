## 1. TC4x Ethernet整体架构概览

Infineon AURIX TC4x微控制器家族重新定义了车载以太网的集成方式。与TC3xx仅提供单端口千兆以太网MAC不同，TC4x将GETH（Gigabit Ethernet，千兆以太网）、LETH（Lite Ethernet，轻量以太网）、CSS（Cyber Security Satellite，网络安全加速器）和DRE（Data Routing Engine，数据路由引擎）四大模块整合为统一的网络通信子系统 [^19^][^20^]。这一架构并非简单堆叠MAC端口，而是以64位SRI（Shared Resource Interconnect）交叉开关为核心，构建了一个覆盖物理层到应用层的完整Ethernet通信矩阵，直接服务于区域架构（Zonal Architecture）下Zone Controller的通信枢纽需求。本章从模块组成、车载定位和特性矩阵三个维度，为后续各章的深度解析建立整体认知框架。

### 1.1 TC4x网络模块组成

#### 1.1.1 GETH、LETH、CSS、DRE四大模块的功能定位与协同关系

TC4x Ethernet子系统的四个模块在功能上形成明确的分层协作关系。下图以文字形式描述了TC4x Ethernet系统架构的整体布局：

```
+========================================================================================+
|                        TC4x Ethernet System Architecture                               |
+========================================================================================+
|                                                                                        |
|  +------------------------+        64-bit SRI Crossbar        +------------------------+ |
|  |   GETH (Gigabit        |<===============================>|   LETH (Lite Ethernet)  | |
|  |    Ethernet)           |     Dual LCB2SRI Channels        |                         | |
|  |                        |     ECC | 250 MHz                |                         | |
|  |  [XGMAC0] [XGMAC1]     |                                  | [MAC0][MAC1][MAC2][MAC3] | |
|  |   5G MAC   5G MAC      |                                  |  10/100M 10/100M ...    | |
|  |       |     Bridge     |                                  |       |                 | |
|  |  MTL:32KB TX/RX FIFO   |                                  |  16KB TX / 8KB RX FIFO  | |
|  |  8 DMA Channels        |                                  |  4 DMA Channels         | |
|  |       |                |                                  |       |                 | |
|  |  HSPHY: MII/RGMII/     |                                  |  10BASE-T1S Int. PHY    | |
|  |  SGMII/USXGMII         |                                  |  TC14 Interface         | |
|  +-------|----------------+                                  +-------|-----------------+ |
|          |                                                          |                   |
|          v                                                          v                   |
|    RGMII/SGMII/USXGMII                                        MII/RMII/10BASE-T1S       |
|          |                                                          |                   |
|          +==========================+=================================+                   |
|                                     |                                                  |
|  +------------------------+         |         +------------------------+                |
|  |   CSS (Cyber Security  |<--------|-------->|   DRE (Data Routing    |                |
|  |    Satellite)          |                  |    Engine)             |                |
|  |                        |                  |                        |                |
|  |  3x AES (CMAC/GMAC/    |                  |  ACF Format Engine     |                |
|  |       GCM)             |                  |  (IEEE 1722 Encap)     |                |
|  |  Chacha20 | Poly1305   |                  |  Forwarding Engine     |                |
|  |  SHA-1/2/3 | SipHash   |                  |  (1:6 Multicast)       |                |
|  |                        |                  |                        |                |
|  |  8KB Key RAM | ASIL-D  |                  |  Message RAM | Routing  |                |
|  |  MAC Comparator        |                  |  Table | Forward Table  |                |
|  |  21 Channels (20+1)    |                  |  SPB/SRI Master        |                |
|  +------------------------+                  +------------------------+                |
|                                                                                        |
+========================================================================================+
```

**GETH**是TC4x的高速骨干网络接口，包含最多两个XGMAC（10 Gigabit Media Access Control）实例和一个Bridge模块 [^39^][^75^]。每个XGMAC支持IEEE 802.3-2015标准，数据速率覆盖10M/100M/1G/2.5G/5G全双工模式 [^77^]。GETH通过HSPHY（High Speed PHY）模块对外提供MII、RMII、RGMII、SGMII和USXGMII五种物理层接口 [^115^]。MTL（MAC Transaction Layer）为TX和RX方向各配置了32KB FIFO，配合8路独立DMA通道（较TC3x的4路翻倍），满足多队列并发传输的缓冲区需求 [^28^][^44^]。Bridge模块实现两个XGMAC之间的硬件级帧转发，支持菊花链拓扑和IEEE 802.1CB FRER（Frame Replication and Elimination for Reliability）帧复制消除机制 [^34^]。

**LETH**面向低速边缘节点通信，集成4个独立MAC实例，每个支持10M和100M两种速率 [^19^]。其核心差异化特性是内建10BASE-T1S数字PHY，通过OPEN Alliance TC14 3引脚接口直接连接外部PMD（Physical Medium Dependent）收发器 [^41^][^114^]。LETH配置16KB TX FIFO和8KB RX FIFO，4路DMA通道，支持IEEE 802.1Qav CBS（Credit-Based Shaper）和802.1Qbv TAS（Time-Aware Shaper），但不支持802.1Qbu帧抢占 [^30^]。该模块的目标应用是将传统CAN/LIN域的传感器、执行器和小型ECU接入统一Ethernet网络。

**CSS**是TC4x新增的网络安全硬件加速器，直接挂载于SRI交叉开关上以降低数据传输延迟 [^21^]。CSS提供20+1个独立通道（20个应用通道加1个CSRM独占通道），内部集成3路AES引擎（支持CMAC、GMAC、GCM模式）、Chacha20、Poly1305、SipHash和SHA-1/2/3硬件加速单元 [^5^][^21^]。8KB内部安全RAM用于密钥存储，配合ASIL-D等级的MAC比较器实现安全消息认证。CSS为GETH和LETH提供MACsec（IEEE 802.1AE）帧加密的底层AES-GCM运算加速，是实现车载网络安全通信的核心基础设施 [^20^]。

**DRE**是专用于CAN与Ethernet之间数据路由的硬件加速器，支持CAN-to-Ethernet、CAN-to-CAN、CAN-to-Memory和Ethernet-to-Ethernet四类路由路径 [^219^]。DRE将CAN帧封装为IEEE 1722-2016 AVTP/ACF（AVTP Control Format）格式以便在Ethernet骨干上传输，封装开销仅为8-16字节 [^216^]。该模块提供4种发送触发模式（帧计数、缓冲区填充度、时间触发、软件触发），并支持1:6多播转发 [^455^]。相较于TriCore软件路由方案，DRE可降低70-80%的路由延迟与抖动 [^429^]。

四模块的协同逻辑清晰：GETH端口连接其他Zone Controller或中央HPC（High Performance Computer）构建高速骨干；LETH端口连接本区域内的边缘设备；CSS为所有Ethernet流量提供统一的安全加速；DRE负责将 legacy CAN/CAN-FD 网络无缝桥接到Ethernet骨干，无需CPU介入 [^25^][^484^]。

#### 1.1.2 从TC3x到TC4x的架构演进：新增Bridge、扩展DMA通道、新增CSS

TC3xx的GETH模块基于Synopsys DWC_ether_qos IP，仅包含单GMAC，最高支持1Gbps速率，TX/RX FIFO分别为4KB和8KB，配置4路DMA通道 [^92^]。这一设计在域控制器（Domain Controller）时代足以满足单一功能的网络需求，但面对区域架构下的多端口、高带宽、低延迟通信需求则显得捉襟见肘。

TC4x在架构层面实现了四项关键演进。第一，**端口数量与速率双升级**：GETH从1个GMAC扩展为最多2个XGMAC，单端口峰值速率从1G提升至5Gbps（通过USXGMII接口），总交换容量达到10Gbps级别 [^5^][^77^]。第二，**新增硬件Bridge模块**：TC3x不支持MAC-to-MAC直接转发，所有跨端口流量须经CPU处理；TC4x的Bridge模块在硬件层面完成XGMAC0与XGMAC1之间的帧转发，配合32KB FIFO吸收突发流量，为菊花链和环网拓扑提供原生支持 [^75^]。第三，**DMA与缓冲区大幅扩展**：DMA通道从4路增至8路，MTL TX/RX FIFO从4KB/8KB统一升级至32KB [^28^][^44^]。新增双通道LCB2SRI（Local Cross Bar to SRI）架构允许TX与RX流量在物理上分离——一条LCB2SRI专用于读取传输，另一条专用于写入传输，避免全双工场景下的总线争用 [^36^]。第四，**新增CSS安全子系统**：TC3x依赖单通道HSM（Hardware Security Module）处理所有加密操作，难以满足5Gbps速率下MACsec的实时加解密需求；CSS的21独立通道和3路AES引擎将GMAC吞吐率提升至763MB/s，足以覆盖2x5Gbps端口的线速MACsec处理 [^21^]。

### 1.2 汽车E/E架构中的TC4x定位

#### 1.2.1 区域控制器(Zone Controller)通信枢纽角色

在区域架构（Zonal E/E Architecture）中，车辆被划分为多个物理区域（如前左Zone、前右Zone、后Zone），每个Zone由一台Zone Controller统一管理。TC4x的Ethernet子系统正是为这一角色量身设计：GETH的5Gbps端口提供与车辆中央HPC或其他Zone Controller的高速互联，LETH的4个10/100M端口将Ethernet延伸至本区域内数十个边缘ECU、传感器和执行器 [^110^][^484^]。

这种"高速上行 + 低速下行"的端口配置与区域架构的拓扑需求精确匹配。以Marelli与Infineon联合开发的Zone Control Unit为例，单一TC4x需要同时处理照明、车身控制、音频、配电、推进、热管理和底盘控制等多个域的数据汇聚，DRE模块在此过程中确保CAN帧以极低延迟封装后进入Ethernet骨干 [^484^]。CSS则为跨域安全通信提供硬件级MACsec加速，使得不同ASIL等级的功能域在网络上实现Freedom of Interference（免于干扰）[^5^]。

#### 1.2.2 从域架构到区域架构的网络需求演变

传统域架构（Domain Architecture）按功能划分网络——动力域、底盘域、车身域各自独立，域间通信通过中央网关转发。这种架构下，单个ECU通常只需连接一条CAN或一条100Mbps Ethernet即可满足需求。随着ADAS/AD（Advanced Driving Assistance Systems / Automated Driving）传感器数据量和OTA（Over-The-Air）更新带宽需求的指数级增长，域架构面临线束复杂度高、网关瓶颈和扩展性差等问题。

区域架构将通信组织从"功能导向"转为"空间导向"，对MCU的Ethernet能力提出了全新要求。首先，**带宽需求分层化**：Zone之间需要1Gbps以上的骨干连接以传输摄像头、激光雷达等传感器原始数据；Zone内部则仅需10-100Mbps连接门控、座椅、气候控制等ECU [^302^]。TC4x的GETH+LETH双速架构天然适配这种分层需求。其次，**拓扑结构从星型向菊花链演变**：FRER（IEEE 802.1CB）允许Zone Controller以菊花链方式串接，减少线束总长度和重量；GETH Bridge的MAC-to-MAC转发功能是实现这一拓扑的硬件基础 [^34^]。第三，**TSN（Time-Sensitive Networking）成为刚性需求**：区域架构中，传感器数据流、控制指令和诊断流量共享同一物理网络，必须通过802.1AS时间同步、802.1Qbv门控调度和802.1Qbu帧抢占等机制保障确定性延迟。TC4x的GETH端口支持完整的TSN协议栈，LETH端口支持CBS+TAS+gPTP的子集，覆盖不同速率域的实时通信需求 [^30^]。第四，**安全边界从网关下放到端口**：区域架构中每个Zone都是潜在的网络攻击入口，CSS的21独立MACsec通道允许为每个逻辑网络分区配置独立的安全关联（SA），实现"默认安全"（Secure-by-Default）的网络设计 [^20^][^21^]。

### 1.3 TC4x Ethernet Feature矩阵

#### 1.3.1 速度等级对照表：GETH(10M-5G) vs LETH(10M-100M)支持的速度与接口

| 参数项 | GETH (Gigabit Ethernet) | LETH (Lite Ethernet) |
|:---|:---|:---|
| MAC实例数 | 最多2个XGMAC [^39^] | 4个独立MAC [^19^] |
| 最大数据速率 | 5 Gbps（USXGMII/SGMII）[^5^] | 100 Mbps（MII/RMII）[^114^] |
| 10M支持 | 是（全/半双工，MII/RMII）[^77^] | 是（10BASE-T1S / MII / RMII）[^41^] |
| 100M支持 | 是（全双工，MII/RMII/RGMII）[^77^] | 是（全双工，MII/RMII）[^114^] |
| 1G支持 | 是（RGMII/SGMII）[^77^] | 否 |
| 2.5G支持 | 是（SGMII）[^5^] | 否 |
| 5G支持 | 是（SGMII/USXGMII）[^5^] | 否 |
| MII接口 | 是 [^75^] | 是 [^114^] |
| RMII接口 | 是 [^75^] | 是 [^114^] |
| RGMII接口 | 是（通过HSPHY）[^115^] | 否 |
| SGMII接口 | 是（通过HSPHY）[^125^] | 否 |
| USXGMII接口 | 是（通过HSPHY）[^125^] | 否 |
| 10BASE-T1S | 否 | 是（集成数字PHY，TC14接口）[^41^] |
| TX FIFO容量 | 32 KB（每XGMAC）[^44^] | 16 KB（共享）[^114^] |
| RX FIFO容量 | 32 KB（每XGMAC）[^44^] | 8 KB（共享）[^114^] |
| DMA通道数 | 8路 [^28^] | 4路 [^114^] |
| Ethernet Bridge | 是（硬件MAC-MAC转发）[^75^] | 否 |

上表揭示了一个精心设计的速度分层策略。GETH覆盖10M至5G的完整速率范围，通过HSPHY模块的3个MP8G PHY实现串行接口（SGMII/USXGMII）与5Gbps速率 [^115^][^125^]。在100M速率下，GETH与LETH均支持MII和RMII接口，为开发者提供了在两种MAC之间灵活选择的余地——当应用场景需要Bridge功能或未来可能升级至千兆速率时选择GETH，当成本敏感且仅需10/100M速率时选择LETH。LETH独有的10BASE-T1S集成数字PHY是其最关键的价值主张：通过TC14 3引脚接口（TX、RX、ED）直接驱动外部PMD收发器，支持PLCA（Physical Layer Collision Avoidance）机制实现最多8个节点、25米总线长度的多点总线拓扑 [^41^][^388^]。这一特性使Ethernet能够直接替代传统CAN/LIN网络，无需为每个节点配备独立PHY芯片，显著降低了系统成本。

#### 1.3.2 协议支持总览：TSN/AVB/安全/路由协议完整列表

| 协议/标准 | 标准名称 | GETH支持 | LETH支持 | 负责模块/说明 |
|:---|:---|:---:|:---:|:---|
| IEEE 802.3-2015 | Ethernet MAC | 是 [^44^] | 是 [^114^] | XGMAC/MAC Core |
| IEEE 802.1AS-2020 | gPTP时间同步 | 是 [^30^] | 是 [^114^] | 硬件时间戳单元 |
| IEEE 802.1Qav | 信用整形器（CBS） | 是 [^30^] | 是 [^114^] | 4个CBS整形器 |
| IEEE 802.1Qbv | 时间感知整形器（TAS） | 是 [^30^] | 是 [^114^] | 门控列表调度 |
| IEEE 802.1Qbu | 帧抢占（Preemption） | **是** [^30^] | **否** [^30^] | **仅GETH支持** |
| IEEE 802.1Qci | 逐流过滤与策略（PSFP） | 部分 [^48^] | 部分 | FFP/GCL/PC |
| IEEE 802.1CB | 帧复制消除（FRER） | SW [^34^] | SW | 依赖Bridge转发 |
| IEEE 802.1AE | MACsec（Layer 2安全） | 加速 [^19^] | 有限 | CSS提供AES-GCM加速 |
| IEEE 1588-2008 | PTP精确时钟同步 | 是 [^44^] | 是 [^114^] | v1/v2双版本支持 |
| IEEE 1722-2016 | AVTP/ACF传输 | 是 [^219^] | 是 [^219^] | DRE封装/解封装 |
| IEEE 1722.1 | AVTP控制 | 是 [^455^] | 是 [^455^] | DRE路由表支持 |
| IEEE 802.1Q | VLAN标记 | 是 [^44^] | 是 [^114^] | 硬件VLAN插入/过滤 |
| IEEE 802.3az | 节能以太网（EEE） | 是 [^28^] | — | 低功耗PHY模式 |
| TCP/UDP/IP | 校验和卸载 | 是 [^77^] | 是 [^114^] | 硬件IP/TCP/UDP校验和 |
| IPsec | 网络层安全 | 加速 [^5^] | — | CSS AES-GCM加速ESP |
| D/TLS | 传输层安全 | 加速 [^5^] | — | CSS Chacha20-Poly1305 |
| SecOC | PDU级安全 | 加速 [^5^] | — | CSS SipHash/CMAC |
| 802.3cg / 10BASE-T1S | 单对多点以太网 | 否 | 是 [^41^] | LETH集成数字PHY |
| PLCA | 物理层碰撞避免 | 否 | 是 [^388^] | 10BASE-T1S多点总线 |

上述协议矩阵覆盖了TC4x Ethernet子系统从Layer 1到Layer 4的完整协议栈。在TSN协议族方面，GETH提供了完整的硬件支持（802.1AS/802.1Qav/802.1Qbv/802.1Qbu），LETH则通过CBS和TAS实现了确定性通信的核心能力，但不具备帧抢占功能——这一差异意味着在LETH连接的10BASE-T1S网络中，设计人员必须依赖更精确的TAS门控配置和更大的保护带（Guard Band）来避免低优先级帧阻塞高优先级流 [^30^]。在安全协议层面，CSS的21独立通道架构使得每个GETH/LETH端口或虚拟网络分区均可拥有独立的安全关联和密钥空间，配合ASIL-D MAC比较器为功能安全相关通信提供安全认证保障 [^21^]。DRE通过IEEE 1722 ACF_CAN_BRIEF格式实现CAN帧到Ethernet帧的高效封装，使 legacy CAN网络中的传感器和执行器成为Ethernet骨干上的"一等公民"，CPU无需参与协议转换即可获得比TriCore软件方案快50%的路由性能 [^25^][^429^]。
