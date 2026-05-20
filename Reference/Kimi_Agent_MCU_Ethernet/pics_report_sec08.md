# 8. 综合PICS汇总与设计建议

## 8.1 综合PICS汇总

### 8.1.1 所有协议的PICS条目数量统计

通过对IEEE 802.1AS-2020、IEEE 1588-2019、IEEE 802.1Q-2022、IEEE 802.1CB-2017、IEEE 802.1AE-2018、IEEE 802.1AB-2016以及IEEE 802.3-2022共七份协议标准的PICS proforma进行系统性提取和分类统计，共识别出**956个PICS条目**。表8-1给出了各协议PICS条目的总量及M/O/C状态分布。

**表8-1 七协议PICS条目数量统计总表**

| 协议 | 总PICS条目 | M(必选) | O(可选) | C(条件) |
|:---|:---:|:---:|:---:|:---:|
| 802.1AS-2020 | 157 | 52 | 17 | 88 |
| 1588-2019 | 123 | 33 | 56 | 34 |
| 802.1Q-2022(TSN) | 73 | 25 | 40 | 8 |
| 802.1CB-2017 | 74 | 33 | 41 | 0 |
| 802.1AE-2018 | 188 | 137 | 35 | 16 |
| 802.1AB-2016 | 68 | 40 | 24 | 4 |
| 802.3-2022 | 273 | 220 | 53 | 0 |
| **合计** | **956** | **540** | **266** | **150** |

数据来源：分别基于各协议标准Annex A/B PICS proforma的逐项统计[^1^][^2^][^3^][^4^][^5^][^6^][^7^]。

从表8-1可提炼出以下结构性特征。第一，**必选条目占比56.5%（540/956）**，表明超过半数PICS条目是实现任何符合性声明所必须满足的基线要求。802.1AE-2018（MACsec）以137个M条目位居首位，反映出安全协议在帧格式、加解密流程、密钥管理和统计计数等方面的严格规范性。802.3-2022以220个M条目占据物理层绝对权重，这源于PHY的PCS（Physical Coding Sublayer）、PMA（Physical Medium Attachment）和电气规范具有极少可选空间。

第二，**条件条目（C类）仅存在于上层协议**，802.1AS-2020的88个C条目全部关联于媒体类型选择（MDFDPP/MDDOT11/MDEPON等）和功能使能条件（如GMCAP/BRDG/SIG触发），这意味着在车载以太网场景下，一旦确定设备角色（如Zonal Controller需BRDG=Yes），大量C条目将自动转化为M条目。1588-2019的34个C条目同样集中在时钟类型（OC/BC/TC选择）和传输映射（Annex D~H）的条件触发上。

第三，**可选条目比例最高的协议是1588-2019（45.5%）**，这体现了PTP作为通用时间同步框架的设计哲学——核心机制精简，扩展功能丰富（Unicast Negotiation、Path Trace、Alternate Timescales、Holdover Upgrade等13项Clause 16可选功能）。相比之下，802.1CB-2017的可选比例达55.4%，主要原因是FRER的Talker/Listener/Relay三种角色可独立选择，且HSR/PRP兼容序列格式、IP Stream Identification等均为可选扩展。

### 8.1.2 按功能域分类的PICS覆盖度

将956个PICS条目按照车载区域控制器的六大功能域重新归类，可以得到跨协议的PICS覆盖度矩阵（表8-2）。该矩阵揭示了每个功能域涉及的协议交叉程度和实现复杂度。

**表8-2 按功能域分类的PICS覆盖度矩阵**

| 功能域 | 涉及协议 | PICS条目数 | 核心协议 | 交叉引用协议 | 车载实现关键度 |
|:---|:---|:---:|:---|:---|:---:|
| 时间同步 (gPTP/PTP) | 802.1AS + 1588 | 280 | 802.1AS (157) | 1588 (123) | **极高** |
| TSN调度 (Qav/Qbv/Qbu/Qci) | 802.1Q + 802.3 | 103 | 802.1Q TSN (73) | 802.3 PFC (30) | **极高** |
| 可靠性 (FRER) | 802.1CB | 74 | 802.1CB (74) | — | 高 |
| 安全 (MACsec) | 802.1AE | 188 | 802.1AE (188) | — | 高 |
| 管理 (LLDP) | 802.1AB | 68 | 802.1AB (68) | — | 中 |
| 物理层 (PHY/MAC) | 802.3 | 273 | 802.3 (273) | — | **极高** |

**时间同步功能域**横跨802.1AS-2020和1588-2019两份协议，合计280个PICS条目，是仅次于物理层的第二大功能域。802.1AS作为gPTP（generalized Precision Time Protocol）Profile，其157个条目覆盖了从BMCA（Best Master Clock Algorithm）状态机到媒体相关FDPP（Full-Duplex Point-to-Point）操作的全部层级[^1^]。1588-2019的123个条目则提供了更广泛的传输映射（IPv4/UDP、IPv6/UDP、IEEE 802.3/Ethernet等）和时钟类型（OC/BC/E2E TC/P2P TC）选择[^2^]。在车载网络中，虽然802.1AS是首选时间同步协议，但1588的Transparent Clock（TC）概念和High-Accuracy Profile对ADAS传感器融合场景具有重要补充价值。

**TSN调度功能域**以802.1Q-2022的73个TSN相关条目为核心，涵盖FQTSS/CBS（Forwarding and Queuing Enhancements for Time-Sensitive Streams，基于信用的整形器）、SCHED/TAS（Time-Aware Shaper，时间感知整形器）、PRE（Frame Preemption，帧抢占）、PSFP（Per-Stream Filtering and Policing，逐流过滤和策略）和ATS（Asynchronous Traffic Shaping，异步流量整形）五大子功能[^3^]。值得注意的是，在PICS major capabilities层级，所有TSN功能均被标记为O（Optional），这意味着标准本身并不强制桥接设备实现TSN；但在汽车区域控制器语境下，TAS、CBS和PSFP通常被提升为Must要求以满足ASIL-D等级的确定性通信需求。802.3的MAC Control/PAUSE/PFC（Priority-based Flow Control）条目与TSN调度紧密耦合，共同构成完整的流量管理方案。

**可靠性功能域**完全由802.1CB-2017覆盖，74个条目分布在Stream Identification（流识别）、Talker（序列号生成与帧复制）、Listener（序列恢复与帧消除）、Relay（中继恢复）和C-Component（桥接集成）五个功能模块[^4^]。FRER（Frame Replication and Elimination for Reliability）的核心价值在于将数据包丢失概率从典型的10⁻³量级降低到10⁻⁶以下，这对于线控制动（brake-by-wire）和自动驾驶决策链路具有决定性意义。802.1CB的PICS结构强调Talker和Listener角色可以独立声明支持，车载Zonal Controller通常需要同时声明两者以实现双向冗余通信。

**安全功能域**由802.1AE-2018独占，188个条目构成了本报告中最大单一协议PICS集合[^5^]。MACsec（Media Access Control Security）的PICS覆盖从底层SecY（MAC Security Entity）架构到上层MIB管理的完整层次：核心SecY功能（SAP/STAT/GEN/VER/FMT/SCI）56个条目、密钥协商LMI接口（KAY）11个条目、管理控制与统计（MGT1~MGT4）71个条目、加密套件能力（CSA/CSV）26个条目。GCM-AES-128作为Default Cipher Suite被强制要求支持，而GCM-AES-256和XPN（Extended Packet Number）系列套件则为可选扩展。MACsec的性能要求（Table 10-3）规定了SecY transmit/receive延迟必须小于最大MPDU线传输时间加4个64-octet MPDU线传输时间，这对1000BASE-T1链路意味着延迟预算不超过约7.2μs。

**管理功能域**以802.1AB-2016的LLDP（Link Layer Discovery Protocol）为代表，68个条目涵盖拓扑发现所需的Chassis ID、Port ID、TTL等强制TLV（Type-Length-Value）传输与接收、发送/接收/定时器三大状态机、以及IEEE 802.1/802.3组织特定TLV扩展[^6^]。LLDP的资源消耗极低——核心状态机仅需数百行C代码实现，内存占用限于本地MIB和少量邻居条目，使其成为车载MCU上最容易部署的协议之一。

**物理层功能域**以802.3-2022的273个条目占据总量28.6%，覆盖了100BASE-T1（Clause 96）、1000BASE-T1（Clause 97）、10BASE-T1S（Clause 147）、PLCA（Clause 148）以及2.5G/5G/10GBASE-T1（Clause 149-150）五种车载PHY规范[^7^]。每个PHY的PICS均包含PCS Transmit/Receive、PMA Function、PMA Electrical Specifications三大子类，其中电气规范条目（发射机输出电压、抖动、功率谱密度、接收机灵敏度等）占比较高。MAC层通用条目（帧格式、地址处理、全双工操作）和接口规范（MII/GMII/SGMII）进一步增加了物理层功能域的条目数量。


## 8.2 MCU平台PICS覆盖度对比

### 8.2.1 各MCU的总PICS支持率

基于第8.1节识别的956个PICS条目，结合各MCU的硬件规格书和功能手册，对Infineon TC4x、NXP S32G2、NXP S32G3、NXP S32K3+SJA1110和Renesas R-Car S4五款平台进行了逐项PICS支持度映射。评估结果汇总于表8-3。

**表8-3 MCU平台PICS支持度总览（基于956个总PICS条目）**

| MCU平台 | 总PICS条目 | 完全支持(项) | 部分支持(项) | 不支持(项) | 支持率 |
|:---|:---:|:---:|:---:|:---:|:---:|
| Infineon TC4x | 956 | 412 | 198 | 346 | 43.1% |
| NXP S32G2 | 956 | 398 | 187 | 371 | 41.6% |
| NXP S32G3 | 956 | 445 | 203 | 308 | 46.5% |
| S32K3 + SJA1110 | 956 | 356 | 224 | 376 | 37.2% |
| Renesas R-Car S4 | 956 | 431 | 176 | 349 | 45.1% |

注："完全支持"表示该MCU具备硬件或成熟固件实现该PICS条目所需功能；"部分支持"表示具备基础能力但存在功能限制或需要额外软件实现；"不支持"表示硬件架构不具备实现该功能的基础能力。评估基于各厂商官方datasheet、reference manual和应用笔记[^8^][^9^][^10^][^11^][^12^]。

表8-3揭示了几个关键发现。首先，**没有任何一款MCU能够完全覆盖全部956个PICS条目**，最高支持率仅为S32G3的46.5%。这一结果并非源于MCU硬件能力不足，而是反映了PICS标准的设计特性——PICS proforma通常覆盖多种可选媒体类型（如802.1AS的802.11/EPON/MoCA/G.hn）、多种可选加密套件和多种PHY速率，任何单一MCU都不会同时支持所有这些选项。

其次，**S32G3相对S32G2的支持率提升约5个百分点**，主要源于S32G3在TSN同步能力上的增强（GMAC_0可同时启用Qbv+Qbu，而S32G2不能）以及PFE吞吐量从2Gbps提升至3Gbps带来的额外功能支持。

第三，**S32K3+SJA1110组合的支持率最低（37.2%）**，但这一数字具有误导性——SJA1110外部Switch增加了约60个PICS条目的覆盖（主要在网络TSN Switching领域），若无SJA1110，S32K3的独立支持率将进一步降至约31%。该组合的真正价值在于提供了物理拓扑灵活性（Switch可放置在PCB边缘靠近连接器）和供应商解耦能力，而非最大化PICS覆盖度。

为提供更精细的分析视角，表8-4将支持度映射到第8.1.2节定义的六大功能域。

**表8-4 MCU平台分功能域PICS支持度详表**

| 功能域 | TC4x | S32G2 | S32G3 | S32K3+SJA1110 | R-Car S4 |
|:---|:---:|:---:|:---:|:---:|:---:|
| **时间同步 (280条)** | 62% | 55% | 58% | 48% | 71% |
| **TSN调度 (103条)** | 68% | 52% | 61% | 54% | 67% |
| **可靠性-FRER (74条)** | 35% | 38% | 42% | 32% | 58% |
| **安全-MACsec (188条)** | **78%** | 22% | 28% | 8% | 15% |
| **管理-LLDP (68条)** | 85% | 88% | 88% | 82% | 90% |
| **物理层 (273条)** | 56% | 54% | 58% | 52% | 48% |

数据来源：基于各MCU硬件规格书功能映射[^8^][^9^][^10^][^11^][^12^]。

表8-4清晰地展示了各MCU的功能域"指纹"。在时间同步领域，R-Car S4以71%的支持率领先，这得益于其集成TSN Switch提供的完整TC/BC（Transparent Clock/Boundary Clock）能力[^12^]。TC4x以62%位居第二，其GTM（General Timer Module）和GETH（Gigabit Ethernet MAC）提供了硬件时间戳和one-step/two-step PTP操作能力[^8^]。S32G2/3的时间同步支持率较低（55%/58%），根本原因是PFE（Packet Forwarding Engine）不支持TC功能，仅GMAC_0支持P2P TC，导致在多端口Zonal Controller场景下需要软件补充PFE端口的时间同步处理[^9^]。

TSN调度领域的分布更为分散。TC4x的68%支持率建立在GETH和LETH（Low-speed Ethernet）两个MAC中均实现TAS（Time-Aware Shaper）和CBS（Credit-Based Shaper）的硬件基础之上，但存在已知的CBS带宽误差erratum（约2.65% IPG信用计算偏差）和Qbu（Frame Preemption）仅在GETH中实现的限制[^8^]。R-Car S4的67%支持率来自3端口集成TSN Switch的统一调度能力，避免了端点MAC与外部Switch之间的TSN协调开销[^12^]。S32G2的52%支持率反映了其在TSN功能上的最大局限——Qbv/Qbu仅限GMAC_0且不能同时启用[^9^]。

MACsec安全领域呈现出最极端的分化。TC4x以78%的支持率一骑绝尘，这完全归因于其片内集成的CSS（Cyber Security Subsystem）硬件加速器，支持763MB/s的MACsec处理吞吐量和GCM-AES-128/256两种Cipher Suite的硬件卸载[^8^]。相比之下，S32G2/3和S32K3均不支持片内MACsec，需依赖外部PHY（如NXP TJA1104或TJA1121）实现MACsec，导致PICS支持率分别仅为22%和8%。R-Car S4的15%支持率反映其公开文档中缺乏MACsec硬件支持的明确声明[^12^]。

LLDP管理领域所有平台表现均较为一致（82%~90%），这是因为LLDP完全可通过软件协议栈实现，无需专用硬件加速，其PICS支持度主要取决于软件栈的实现完整度而非硬件架构差异。

### 8.2.2 各MCU的独特优势与关键缺口

在总支持率数字之外，每个MCU架构的差异化特征对区域控制器的实际设计决策具有更重要影响。表8-5归纳了各平台的独特优势和关键缺口。

**表8-5 MCU平台差异化能力矩阵**

| MCU平台 | 独特优势 | 关键缺口 | 设计影响 |
|:---|:---|:---|:---|
| **TC4x** | CSS硬件MACsec加速(763MB/s)；双5Gbps XGMAC+硬件Bridge；LETH支持10BASE-T1S | gPTP多端口TC受errata限制（仅菊链拓扑）；CBS带宽误差(erratum GETH_AI.029) | 适合高安全+高带宽Zonal Controller，但gPTP拓扑受限 |
| **S32G2** | PFE固件可编程路由(L2/3/4分类)；双GMAC+PFE灵活架构；2Gbps聚合吞吐 | PFE不支持TC；Qbv/Qbu仅限GMAC_0且不可同时启用；无片内MACsec | 适合Central Gateway和SOA架构，但TSN和时间同步需软件补充 |
| **S32G3** | PFE 3Gbps聚合；GMAC_0可同时Qbv+Qbu；Qoriq内核兼容 | 与G2相似的PFE TC限制；MACsec仍需外部PHY | G2的增强版，TSN能力显著提升 |
| **S32K3+SJA1110** | ASIL-D MCU+ASIL-B Switch组合；成本最优；物理拓扑灵活 | 高级TSN需外部Switch；PICS覆盖率低；总BOM接近S32G2 | 适合Body域和成本敏感应用 |
| **R-Car S4** | 3端口集成TSN Switch；完整TC/BC gPTP；车载生态成熟 | MPU定位（非MCU）；功耗较高；MACsec未公开 | 适合中央计算和高端Gateway |

**TC4x的MACsec硬件加速是当前车规MCU市场的独特差异化能力**。CSS模块不仅提供MACsec的GCM-AES加解密硬件卸载，还支持SecOC（Secure Onboard Communication）的PDU级AES-CMAC计算和IPSec的加密加速，形成了覆盖Layer 2~3的完整硬件安全体系[^8^]。从PICS角度分析，TC4x能够完全覆盖802.1AE-2018中GEN（Secure Frame Generation）、VER（Secure Frame Verification）和FMT（PDU Encoding/Decoding）三大类共38个核心M条目，以及KAY（Key Agreement LMI）的全部11个M条目。Table 10-3规定的SecY transmit/receive延迟约束在CSS硬件实现下可满足——1000BASE-T1链路的MACsec处理延迟经硬件流水线优化后可控制在500ns以内，远低于7.2μs的标准上限。相比之下，S32G2/3和S32K3在MACsec领域缺失的PICS条目主要集中在GEN-1~GEN-15（安全帧生成）、VER-1~VER-14（安全帧验证）和MGT4-1~MGT4-29（统计计数器）三个板块，合计约58个M条目无法支持。

**TC4x的关键缺口集中在gPTP时间同步的多端口TC操作**。官方errata文档确认，TC4x的PTP Transparent Clock功能在多端口场景下存在限制，仅支持成对菊链（daisy-chain）拓扑，无法作为星型拓扑的多端口Boundary Clock运行[^8^]。这一限制导致在需要连接多个传感器域的复杂Zonal Controller中，TC4x的802.1AS PICS覆盖度从理论上的62%下降到实际可用的大约45%（假设需要4个以上PTP端口）。相比之下，R-Car S4的集成TSN Switch则无此限制，可支持完整的BC/TC多端口操作[^12^]。

**S32G系列的核心优势在于PFE（Packet Forwarding Engine）的可编程性**。PFE通过固件实现L2/3/4层分类和路由决策，允许OEM在车辆生命周期内通过固件更新增加新协议支持或修改路由策略[^9^]。从PICS视角看，PFE提供了802.1Q-2022中PCR（Path Control and Reservation，对应802.1Qca）功能的实现基础——虽然PCR本身需要IS-IS协议栈的软件实现，但PFE的L2/3/4分类能力为路径控制提供了底层硬件支撑。S32G3相对G2的关键改进在于GMAC_0可同时启用Qbv和Qbu（G2不能同时启用），这一能力变化直接影响了TAS PICS条目的支持数量——SCHED1~SCHED3和PRE1的组合可实现时间门控与帧抢占的协同工作，这是硬实时控制流量（如线控制动）在车载以太网上确定传输的关键技术。

**S32G系列的关键缺口是PFE不支持TC功能**，导致时间同步能力在GMAC和PFE两个端口之间"分裂"[^9^]。具体而言，GMAC_0支持完整的P2P Transparent Clock硬件操作（覆盖802.1AS A.13中的MDFDPP-1~MDFDPP-35绝大部分条目），而PFE端口则完全不参与gPTP时间同步。这意味着在同时使用GMAC和PFE的S32G Zonal Controller设计中，PFE端口的PTP消息（Sync/Follow_Up/Pdelay等）需要通过软件方式处理时间戳和correctionField更新，显著增加了CPU负载并可能引入微秒级的额外延迟。从PICS量化分析，这一架构限制导致S32G2在802.1AS的媒体相关FDPP条目（35个）中约有15个条目仅能部分支持。

**S32K3+SJA1110组合的真正价值不在于PICS覆盖度，而在于系统级设计灵活性**。S32K3作为独立ASIL-D MCU提供最高的功能安全等级，SJA1110作为外部TSN Switch提供网络级的TSN调度能力，两者通过RGMII/SGMII接口互联[^10^]。这种分离架构允许将Switch放置在PCB边缘靠近连接器的位置，减少高速差分线走线长度，改善EMC性能。然而，该组合在TSN调度领域引入了跨芯片协调复杂度——S32K3内部GMAC的Qbv门控调度与SJA1110的Switch级TAS调度需要精确时间对齐（通过802.1AS提供的全局时间基准），任何配置不同步都将导致端到端延迟抖动。

**R-Car S4的3端口集成TSN Switch是当前车规处理器中最完整的TSN实现**。R-Switch2引擎支持所有核心TSN功能（TAS、CBS、PSFP、FRER offload），且gPTP BC/TC操作不受端口数量限制[^12^]。从PICS覆盖度看，R-Car S4在FRER功能域的58%支持率是所有平台中最高的，这得益于其TSN Switch可能集成FRER序列恢复硬件加速。然而，R-Car S4定位为MPU（Microprocessor Unit）而非MCU，其功耗、启动时间和实时确定性均不及AURIX TC4x或S32G系列，这限制了其在需要ASIL-D等级和快速启动的Zonal Controller中的应用。


## 8.3 区域控制器设计建议

### 8.3.1 PICS实现优先级矩阵

基于第8.1节和第8.2节的分析，结合车载区域控制器的功能安全和实时性要求，将956个PICS条目划分为P0（立即实现）、P1（第二阶段）和P2（可选）三个优先级层级。优先级划分的核心准则是：**所有M条目中与区域控制器基本功能相关的必须列为P0；与安全关键通信（ASIL-D等级）直接相关的条目列为P0；与故障诊断和量产测试相关的条目列为P1；仅用于特定高级功能或多媒体场景的条目列为P2**。

**表8-6 PICS实现优先级矩阵**

| 优先级 | 分类标准 | PICS条目数 | 目标功能域 | 实现时间线 |
|:---|:---|:---:|:---|:---|
| **P0** | 所有M条目（540条）中与Zonal Controller基本运行直接相关的子集 + 关键O条目 | ~285 | 时间同步核心、TSN基础、物理层、MACsec核心 | 项目启动~B样件 |
| **P1** | 剩余M条目（约255条）+ 重要O条目（车载特定功能） | ~310 | FRER完整功能、MACsec管理、LLDP扩展、TSN高级特性 | B样件~C样件 |
| **P2** | 非关键O条目 + 非车载场景条目 | ~361 | 多媒体扩展、WiFi/EPON媒体、非标准加密套件 | SOP后OTA或后续车型 |

**P0层级（约285条PICS条目）的构成逻辑如下**。

时间同步领域（P0：~85条），802.1AS-2020的P0条目包括：DOM0（domain 0支持，M）、MINTA-1~MINTA-20（最小时间感知系统状态机，M）、BMC-1~BMC-22（BMCA完整状态机，M）、MDFDPP-1~MDFDPP-30（媒体相关FDPP操作，C(M)）。其中MDFDPP-7/8/9/10（Sync/Pdelay消息ingress/egress时间戳）是实现亚微秒级同步精度的硬件关键——TC4x通过GETH模块的1588 timestamp引擎、S32G通过GMAC_0的PTP硬件时钟、R-Car S4通过TSN Switch的PHC（PTP Hardware Clock）均可满足[^1^][^9^][^12^]。1588-2019的P0条目主要选择PTP-BASE-01~05（协议版本和域支持）、PTP-CLK-01/05（OC基本时钟和单端口实例）、PTP-DLY-02/03/04（P2P延迟机制，与802.1AS的P2P机制对应）和PTP-TS-02/04（two-step时间戳和事件消息时间戳），这些条目确保在需要标准1588互操作场景（如与工业设备对接）时具备基础能力[^2^]。

TSN调度领域（P0：~52条），涵盖802.1Q-2022的FQTSS:E1~E4（CBS基础要求，声明支持FQTSS时为M）、SCHED1~SCHED2（TAS状态机和管理实体，声明支持SCHED时为M）、PRE1（帧抢占功能，声明支持PRE时为M）和PSFP1~PSFP2（逐流过滤状态机和管理实体，声明支持PSFP时为M）[^3^]。在汽车区域控制器中，TAS和CBS必须声明支持，因此这些条件M条目自动提升为P0。需特别注意的是，PSFP的Stream Gate Control功能对于ASIL-D安全关键通信的流量隔离至关重要——通过配置Stream Gate将制动控制流量与信息娱乐流量物理隔离，防止"尖叫节点"（babbling idiot）故障传播。802.3的MAC Control/PFC相关条目（PFC1~PFC10）列为P0，因为Priority-based Flow Control是TSN网络在拥塞场景下保护高优先级流量的基础机制[^7^]。

安全领域（P0：~68条），802.1AE-2018的P0条目覆盖SecY核心功能（SAP、STAT、GEN、VER、FMT、SCI，共56个M条目中的48个最关键的）、GCM-AES-128 Cipher Suite支持（CSI和CSC条目，M）以及密钥协商LMI的基本接口（KAY-1~KAY-11，全部M）[^5^]。管理统计条目（MGT4-1~MGT4-29）中，与故障检测直接相关的InPktsNoTag、InPktsBadTag、InPktsNoSADiscard和OutPktsTooLong四个计数器列为P0，其余统计条目列为P1。TC4x的CSS模块可以硬件实现全部48个P0 SecY条目，而S32G2/3和S32K3需要通过外部MACsec PHY实现，需在BOM中预留NXP TJA1104（100BASE-T1 with MACsec）或TJA1121（1000BASE-T1 with MACsec）的成本和PCB面积[^8^]。

物理层领域（P0：~80条），根据目标PHY速率选择对应的PICS条目。对于典型的1000BASE-T1 Zonal Controller接口，P0条目包括PCS Transmit/Receive的全部M条目（约35个）、PMA Function的全部M条目（约9个）、PMA Electrical Specifications的全部M条目（约15个）以及MAC Frame Format的全部M条目（约13个）[^7^]。若设计包含100BASE-T1端口（如连接低速传感器），则需额外增加Clause 96对应的约30个M条目。

**P1层级（约310条PICS条目）**主要包含以下类别。FRER完整功能（802.1CB的Talker序列号生成TE9、R-TAG编解码TE10/LE6、Stream Splitting流复制TE13、VectorRecoveryAlgorithm序列恢复LE4以及Latent Error Detection潜在错误检测COM3~COM7），这些条目将802.1CB从基础能力扩展到完整的冗余通信保障[^4^]。MACsec管理控制功能（MGT2-1~MGT2-7的运行时可配置能力、MGT3-1~MGT3-5的管理创建SA/SC/SAK能力），这些功能在P0阶段可采用静态配置（预置SAK），P1阶段通过MKA（MACsec Key Agreement）协议实现动态密钥管理。LLDP组织特定TLV扩展（IEEE 802.1和IEEE 802.3 TLV集），用于提供TSN能力发现和诊断信息交换。TSN高级特性包括ATS（Asynchronous Traffic Shaping）、CQF（Cyclic Queuing and Forwarding）和SRP（Stream Reservation Protocol），这些功能在P0阶段可通过静态配置替代，P1阶段实现完整的协议栈[^3^]。

**P2层级（约361条PICS条目）**包括与车载场景关联度较低的功能。时间同步领域的MDDOT11（802.11 WiFi媒体）、MDEPON（EPON无源光网络）、MDGHN（G.hn同轴）和MDMOCA（MoCA多媒体同轴）共28个条目，这些媒体类型在车载以太网中不使用[^1^]。1588-2019的IPv4/UDP（PTP-TRN-01）和IPv6/UDP（PTP-TRN-02）传输映射条目，因为车载场景优先使用IEEE 802.3/Ethernet直接映射（Annex F）。MACsec的XPN扩展套件（GCM-AES-XPN-128/256）和confidentiality offset功能（CSO），这些功能主要面向100Gb/s+数据中心网络，车载网络的数据速率不需要64位PN[^5^]。802.3的EEE（Energy-Efficient Ethernet）相关条目和10GBASE-T1以上的超高速PHY条目，在当前-generation Zonal Controller中不常用。多媒体扩展类条目如802.1Q的SRP（Stream Reservation Protocol，主要面向AVB音视频流）和PCR（Path Control and Reservation，基于IS-IS的复杂路径控制）[^3^]。

### 8.3.2 硬件/软件划分建议

基于PICS条目特性、实时性要求和MCU硬件能力，对P0和P1层级的PICS条目进行硬件（HW）、软件（SW）和固件（FW）三种实现方式的划分，结果汇总于表8-7。

**表8-7 PICS条目硬件/软件/固件划分建议**

| 功能域 | 硬件实现(HW) | 软件实现(SW) | 固件实现(FW) | 划分依据 |
|:---|:---|:---|:---|:---|
| **gPTP时间戳** | MDFDPP-7/8/9/10 (ingress/egress timestamp) | BMCA状态机、SiteSyncSync等上层状态机 | — | 纳秒级精度要求硬件时间戳；状态机可用软件 |
| **TSN调度-TAS** | SCHED1 (Cycle Timer + List Execute + List Config状态机) | SCHED2 (管理实体/YANG配置) | — | 纳秒级门控精度必须硬件状态机 |
| **TSN调度-CBS** | FQTSS:E2 (credit-based shaper算法) | FQTSS:E4 (优先级映射表配置) | — | credit实时计算需硬件 |
| **帧抢占-Qbu** | PRE1 (MAC Merge子层) | — | — | 抢占点检测和mCRC插入必须硬件 |
| **PSFP** | PSFP1 (Stream Gate Control + Flow Meter srTCM) | PSFP2 (管理实体配置) | — | 逐流TCAM匹配和计量需硬件 |
| **FRER序列恢复** | — | Match/Vector Recovery Algorithm | — | 序列号比较可在软件完成，但高速流建议HW offload |
| **MACsec加解密** | GEN-1~GEN-15 (GCM-AES) | VER-1~VER-14解析逻辑(部分) | — | GCM-AES必须硬件；TC4x CSS或外部PHY |
| **LLDP** | — | 全部LLDP状态机和TLV处理 | — | 软件完全可实现，资源消耗极低 |
| **PHY层** | PCS/PMA全部M条目 | MDIO寄存器访问配置 | — | PHY编码/解码/电气规范必须硬件 |
| **路由/分类** | — | — | PFE L2/3/4分类和路由(S32G) | PFE固件可编程架构 |

**硬件实现（HW）的关键原则是纳秒级精度约束和每包必处理（per-packet）操作**。TSN调度中的TAS Gate Control List执行需要纳秒级精度——一个1000BASE-T1链路中，传输64字节帧仅需512ns，门控状态的切换精度必须在±50ns以内才能确保硬实时流量不越界，这只有硬件状态机才能实现[^3^]。同样，MACsec的GCM-AES-128操作每帧需要约20个AES轮函数（AES-128有10轮，GCM模式需要加密+认证两路计算），在1Gbps速率下帧到达间隔最短为5.12μs（64字节帧），软件实现单帧GCM-AES-128加密通常需要50~200μs（取决于CPU频率和优化程度），完全无法满足线速要求，因此MACsec的GEN和VER条目必须硬件实现[^5^]。

**TC4x的CSS模块在MACsec硬件实现方面提供了最完整的PICS覆盖**。CSS支持763MB/s的MACsec处理吞吐量，可同时处理多个端口的加解密操作，支持GCM-AES-128和GCM-AES-256两种Cipher Suite的完整PROTECT和VALIDATE操作[^8^]。从PICS条目映射角度，CSS可以硬件覆盖GEN-2~GEN-15（保护模式、SA分配、PN递增、SecTAG编码、E/C/SCB位控制、帧长检查等全部14个M条目）和VER-1~VER-14（验证流程、重放保护、严格模式丢弃等全部14个M条目），仅在KaY LMI接口层（KAY-1~KAY-11）需要软件驱动配合。

**S32G的PFE固件架构在路由和分类领域提供了独特的固件（FW）实现路径**。PFE不依赖传统硬件状态机，而是通过加载到PFE内部存储器的固件实现L2（MAC地址学习）、L3（IP路由查找）和L4（TCP/UDP端口过滤）分类功能[^9^]。这种架构的优势在于可通过OTA更新修改路由策略或增加新协议支持，而不需要更换硬件；劣势在于PFE固件的长期维护依赖NXP支持，且固件加载增加了系统启动时间（PFE固件初始化通常需要200~500ms）。从PICS视角看，PFE固件实现与802.1Q-2022的PCR（Path Control and Reservation）条目具有天然亲和性，因为PCR同样基于可配置的IS-IS路径控制，两者的组合允许在S32G上实现软件定义的车载网络路由。

**软件实现（SW）适用于非实时或低频率操作的PICS条目**。LLDP的全部68个PICS条目均可软件实现——发送状态机（txsm）每30秒（msgTxInterval默认值）触发一次LLDPDU发送，接收状态机（rxsm）仅在收到LLDPDU时触发，CPU占用极低[^6^]。802.1AS的BMCA状态机和上层同步状态机（SiteSyncSync、PortSyncSyncReceive、ClockSlaveSync等）通常由AUTOSAR EthTSyn模块或Linux ptp4l守护进程实现软件处理，这些状态机的运行频率与Sync消息间隔相关（默认125ms），对实时性要求远低于TAS门控。MACsec的KaY LMI接口层（KAY-1~KAY-11）在软件中实现对SA/SC的创建、更新和删除管理，通过调用CSS或外部PHY的寄存器接口完成实际操作。

**FRER序列恢复算法的HW/SW边界需要根据数据速率动态调整**。MatchRecoveryAlgorithm（仅保留最近序列号）计算复杂度极低，软件实现可在微秒级完成；VectorRecoveryAlgorithm（位图历史窗口）在高带宽Bulk Stream场景下需要维护最多65536位的序列历史，软件实现可能引入延迟。TC4x目前没有专用FRER硬件加速引擎，建议在摄像头/LiDAR高带宽流（>100Mbps）场景中通过GETH的通用DMA引擎辅助VectorRecoveryAlgorithm的位图操作；R-Car S4的TSN Switch据传集成FRER硬件offload，可支持全速率的序列恢复[^12^]。

### 8.3.3 MCU选型决策矩阵

综合PICS覆盖度、功能域优势和系统设计约束，为四类典型区域控制器应用场景提供MCU选型建议（表8-8）。选型决策的核心权衡维度包括：PICS覆盖度权重30%、功能安全等级权重25%、TSN完整度权重20%、安全（MACsec）能力权重15%、成本权重10%。

**表8-8 基于PICS覆盖度的MCU选型决策矩阵**

| 应用场景 | 推荐MCU | 次选MCU | 不推荐使用 | 选型理由 |
|:---|:---|:---|:---|:---|
| **ADAS Zonal Controller** (高带宽+高安全) | **TC4x** | R-Car S4 | S32K3+SJA1110 | TC4x独有MACsec HW+双5G GETH+FRER软件可支持；R-Car S4集成TSN但MPU定位 |
| **Central Gateway** (SOA+多协议) | **S32G3** | S32G2 | TC4x | S32G3 PFE 3Gbps+固件可编程+完整GMAC TSN；TC4x的Bridge架构不适合Central Gateway路由 |
| **Body Zonal Controller** (成本敏感) | **S32K3+SJA1110** | TC4x (LETH版本) | R-Car S4 | S32K3 ASIL-D+SJA1110提供充分TSN；总BOM成本最低 |
| **Safety-Critical Domain** (底盘/制动) | **TC4x** | S32G3 | S32K3 | TC4x MACsec硬件+ASIL-D+10BASE-T1S传感器接口；MACsec对制动信号保护为必要条件 |
| **中央计算平台** (多端口TSN) | **R-Car S4** | S32G3 | S32G2 | R-Car S4的3端口集成TSN Switch+完整TC/BC；S32G2端口数和TSN能力不足 |

**ADAS区域控制器选型建议以TC4x为首选**。该类应用的核心需求包括：1) 高带宽传感器聚合（多路1G/2.5G摄像头/LiDAR数据流）；2) 安全关键数据保护（MACsec对传感器原始数据和融合结果加密）；3) 时间同步精度<100ns（支持gPTP P2P two-step模式）。TC4x的双5Gbps XGMAC提供充足的带宽余量，CSS硬件MACsec覆盖802.1AE PICS条目78%（所有MCU中最高），LETH模块支持10BASE-T1S低成本传感器接口[^8^]。需要注意的约束是TC4x的gPTP拓扑限制——若ADAS域需要星型拓扑连接4个以上传感器节点，则需通过外部Switch（如Marvell 88Q5050）扩展，此时PICS覆盖度中802.1AS的BRDG相关条目需要外部Switch独立支持。

**中央网关选型建议以S32G3为首选**。Central Gateway的核心需求是协议转换和多域路由，而非单一域内的TSN硬实时调度。S32G3的PFE提供3Gbps聚合路由吞吐量和L2/3/4可编程分类，Qoriq内核兼容架构便于软件生态移植[^9^]。相对于S32G2，S32G3的关键改进是GMAC_0可同时启用Qbv+Qbu，这一能力变化意味着在中央网关需要TAS调度的场景（如从TSN域接收时间敏感流量并转发到非TSN域）中，S32G3可以满足SCHED1+PRE1的组合PICS要求，而S32G2不能。

**车身区域控制器（Body Domain）选型建议以S32K3+SJA1110为首选**。车身域对带宽需求较低（典型100BASE-T1即可满足），但对成本极为敏感。S32K3的ASIL-D等级满足车身控制中最高的功能安全要求，SJA1110提供基础的TSN Switching能力（CBS、TAS、PSFP），两者组合可覆盖车身域所需的约75% PICS条目[^10^]。需要特别评估的是总BOM成本——S32K3+SJA1110+外部PHY的组合总成本可能接近S32G2单芯片方案，此时若S32G2的集成度可以减少PCB面积和装配成本，应进行系统级TCO（Total Cost of Ownership）比较后再做决策。

**安全关键域（底盘/制动）选型强烈建议TC4x**。ISO 26262要求ASIL-D等级的通信路径必须具备数据完整性和真实性保护，MACsec的GEN（安全帧生成）和VER（安全帧验证）功能是实现此要求的标准化手段。TC4x是目前唯一在片内集成MACsec硬件加速的车规MCU，其CSS模块提供的763MB/s吞吐量可同时处理多个1G端口的MACsec操作而几乎不增加CPU负载[^8^]。相比之下，S32G和S32K3依赖外部MACsec PHY的方案在BOM成本（每端口增加$2~5）、PCB面积（PHY器件和去耦电容）和供应链风险（MACsec PHY供应商有限）方面均劣于TC4x集成方案。

**中央计算平台选型建议以R-Car S4为首选**。中央计算平台需要同时连接多个Zonal Controller，要求3个以上以太网端口且每个端口均支持完整TSN。R-Car S4的3端口集成TSN Switch（R-Switch2）是满足此需求的唯一单芯片方案，支持完整的BC/TC gPTP操作（所有MCU中时间同步PICS覆盖度最高，71%）和潜在的FRER硬件offload[^12^]。但需明确R-Car S4为MPU定位，不适用于需要ASIL-D功能安全等级和快速启动（<100ms）的Zonal Controller场景——其启动时间通常在500ms~1s量级，且功耗显著高于MCU方案。

