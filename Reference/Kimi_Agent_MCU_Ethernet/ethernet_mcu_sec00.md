# 车规MCU Ethernet模块架构深度分析报告

## 执行摘要

### 核心发现

汽车E/E架构从域控制向区域架构的演进，正推动车载通信从CAN/CAN-FD向高速Ethernet迁移。带宽需求从100Mbps跃升至1Gbps乃至5Gbps，时间确定性从毫秒级进入微秒级，网络安全从可选变为强制。在这一技术变革中，MCU集成的Ethernet模块架构成为区域控制器、中央网关和ADAS域的核心技术选型要素。

本报告对Infineon AURIX TC4x、NXP S32G2/G3/S32K3、Renesas RH850/R-Car S4三款主流车规MCU的Ethernet模块进行了系统性深度分析，覆盖PHY接口、MAC架构、DMA设计、TSN协议支持、AVB协议支持、TCP/IP卸载、时间同步、网络安全和功能安全九大维度。

三家厂商呈现出三条截然不同的Ethernet技术路线：**Infineon TC4x采用"垂直深度集成"策略**，以双5Gbps XGMAC+内部Bridge+CSS网络安全加速器构成业界集成度最高的方案，独有的MACsec硬件加速（763MB/s）使其在安全敏感场景具有不可替代性；**NXP S32G采用"异构双引擎灵活可编程"策略**，GMAC_0负责TSN端点、PFE固件引擎负责L2/3/4路由，通过固件更新实现功能扩展，最适合中央网关的服务化架构演进；**NXP S32K3与Renesas RH850采用"极简MAC+外部扩展"策略**，通过外部TSN Switch（如SJA1110B）或集成MPU Switch（如R-Car S4的3端口2.5G TSN Switch）满足网络需求，以成本优化为核心诉求。

在TSN协议硬件支持方面，差异显著：TC4x GETH硬件支持802.1Qav/Qbv/Qbu，但存在已知CBS erratum（约2.65%带宽误差）和多端口Transparent Clock限制；S32G的Qbv/Qbu能力仅限GMAC_0，与PFE分离的架构导致TSN能力"分裂"；R-Car S4的集成TSN Switch支持最完整的协议栈（含802.1CB FRER和802.1Qci PSFP），但定位为MPU而非MCU。值得注意的是，**IEEE 1722 AVTP（Audio Video Transport Protocol）在三款MCU上均无硬件卸载**，Talker/Listener功能完全依赖软件栈实现。

在设计参考层面，报告提出了八层模块化Ethernet IP架构模板（PHY接口层、MAC核心层、DMA/Buffer层、TSN/AVB加速层、时间同步层、安全层、Bridge/Switch层、功能安全层），并将12个关键协议映射到对应模块。硬件/软件划分决策准则明确量化：速率>1Gbps、确定性延迟<10μs、加密吞吐量>500MB/s、功能安全ASIL-C/D等阈值应优先硬件实现；协议状态机复杂度高、配置灵活性需求强的功能适合软件实现。

基于应用类型的MCU选型决策树表明：**ADAS传感器融合域**优选TC4x（5Gbps带宽+MACsec）；**中央网关**优选S32G（PFE可编程路由+IPSec卸载）；**车身/舒适域**优选S32K3（成本优化+外部SJA1110）；**信息娱乐域**优选R-Car S4（集成TSN Switch+AVB硬件意识）。

未来五年，车载Ethernet将向10Gbps演进，TSN over 10BASE-T1S将打通低成本传感器网络与高速骨干网，MACsec有望成为OEM网络安全强制要求，AI加速器与Ethernet的融合将重新定义MCU的网络处理架构。本报告提供的模块功能划分框架和协议映射关系，可直接作为下一代车规Ethernet模块设计的参考基准。

---

