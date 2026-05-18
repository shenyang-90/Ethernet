## 7. DRE数据路由引擎

在现代汽车E/E架构向域集中和区域化（Zonal）演进的过程中，不同通信协议之间的数据转发已成为网关和区域控制器的核心功能。传统基于TriCore软件实现的路由方案在处理CAN与Ethernet异构网络间的协议转换时，CPU负载高达30-40%，且路由延迟受任务调度影响呈现显著抖动[^25^]。Infineon AURIX TC4x系列集成的**数据路由引擎（Data Routing Engine, DRE）**作为独立硬件加速器，通过专用硬件电路实现CAN帧与Ethernet帧之间的 autonomous routing，在无需CPU干预的情况下完成协议封装、解封装和帧转发，成为TC4x异构网络架构的关键使能模块[^219^][^399^]。

### 7.1 DRE架构与定位

#### 7.1.1 硬件路由加速器：减少CPU负载50%，降低延迟70-80%

DRE是TC4x中独立的硬件加速器模块，其设计目标是接管所有数据平面（Data Plane）路由操作，将应用处理器从频繁的协议转换和中断处理中解放出来。根据Infineon官方技术文档和实测数据，DRE相较TriCore软件路由方案可实现以下性能指标[^25^][^429^][^449^]：

| 性能指标 | 数值 | 说明 |
|:---------|:-----|:-----|
| 相较TriCore性能提升 | 最高50% | 硬件卸载路由与协议转换[^25^] |
| 延迟与抖动降低 | 70-80% | 确定性硬件处理替代软件轮询[^429^] |
| 关键路径延迟改善 | 最高700% | 特定高频路由场景优化[^449^] |
| CPU负载降低 | 显著（硬件级卸载） | 路由全程无需CPU介入[^5^] |

上述性能提升的根本原因在于DRE采用**非饥饿仲裁（Non-Starving Arbitration）**机制处理多路径并发路由请求，消除了软件任务调度带来的上下文切换开销和优先级反转风险。DRE通过SPB总线主设备接口直接访问MCMCAN模块的Rx Host Buffer，经由SRI总线主设备接口读写内部存储器，路由操作在总线层面完成，数据不经过CPU数据缓存[^455^]。

DRE的核心硬件组件包括以下六个功能单元[^399^]：**中央消息存储RAM（Central Message RAM）**提供CAN帧与Ethernet帧的共享缓冲空间，支持跨时钟域数据同步；**路由控制单元（Routing Control Unit, RCU）**协调从MCMCAN接收数据并向目标接口转发；**ACF CAN-Ethernet格式引擎**执行IEEE 1722 ACF格式封装与解封装；**CAN发送路由引擎**依据用户配置的路由表决定目标CAN接口；**Ethernet描述符处理器（Ethernet Descriptor Handler, EDH）**自动管理GETH和LETH的DMA发送/接收描述符；**转发引擎（Forwarding Engine）**依据转发表实现Ethernet-to-Ethernet帧转发。这六个单元协同工作，构成完整的数据平面处理流水线。

#### 7.1.2 与CANXL、GETH、LETH的交互关系

DRE在TC4x网络子系统中处于数据汇聚与分发的枢纽位置。其上游连接**5个MCMCAN模块**（共计20个CAN节点）和独立的**CANXL模块**；下游连接**GETH**（5Gbps高速以太网MAC）和**LETH**（100Mbps低速以太网MAC，支持10BASE-T1S）[^402^][^413^][^465^]。

DRE与这些模块的交互通过四种总线接口实现[^216^]：作为**SPB Master**从MCMCAN模块获取待路由的CAN帧；作为**SRI Master**访问内部存储器进行CAN-to-Memory路由；作为**SRI Slave**允许软件直接监控Message RAM状态；通过**CRE Interface**接收CAN路由引擎（CRE）的触发信号。当CRE检测到同一MCMCAN模块内部的CAN-to-CAN路由请求时，直接处理；当目标CAN接口属于不同MCMCAN模块时，CRE通过专用信号线触发DRE执行跨模块路由[^216^]。这种分工使得CRE专注于模块内部快速转发，DRE负责跨模块和跨协议的复杂路由，两者形成层次化路由体系。

### 7.2 路由功能详解

DRE支持四类核心路由模式：CAN-to-CAN、CAN-to-Ethernet、CAN-to-Memory和Ethernet-to-Ethernet[^216^][^399^]。以下逐一分析各模式的技术实现。

#### 7.2.1 CAN-to-CAN路由：跨20个CAN通道的帧转发

TC4x内置5个MCMCAN模块，每个模块包含4个CAN节点，总计支持20个独立CAN通道[^402^][^413^]。CAN-to-CAN路由分为两个层次：同一MCMCAN模块内部的帧转发由CRE直接处理，延迟最小；跨MCMCAN模块的帧转发则由CRE触发DRE完成。

具体而言，当CRE在Rx Host Buffer中发现需要路由至其他MCMCAN模块的CAN帧时，通过CRE Interface向DRE发出触发信号。DRE以SPB Master身份从源CAN接口的Rx Host Buffer读取完整CAN帧（含标识符、控制场和数据场），将其写入中央消息RAM进行缓冲，随后依据CAN发送路由引擎查询用户配置的**路由表（Routing Table）**，确定目标CAN接口，再将帧数据写入目标MCMCAN模块对应CAN节点的Tx Host Buffer[^216^]。整个过程帧数据不经过CPU或系统主存储器，完全在DRE硬件流水线中完成。路由表支持基于CAN-ID的目的地搜索，用户可通过MCAL DRE驱动在EB tresos中配置路由规则[^455^]。

#### 7.2.2 CAN-to-Ethernet路由：IEEE 1722 AVTP/ACF/NTSCF封装

CAN-to-Ethernet路由是DRE最重要的功能，其技术核心在于将CAN帧封装为符合**IEEE 1722-2016**标准的AVTP（Audio Video Transport Protocol）控制帧格式[^219^]。IEEE 1722标准定义了在汽车以太网中传输非AVB/TSN敏感控制数据的机制，ACF（AVTP Control Format）子格式专门用于承载CAN帧数据。

DRE采用的封装层次如下：首先，ACF CAN-Ethernet格式引擎将单个CAN帧转换为**ACF_CAN_BRIEF**消息格式，该精简格式包含CAN标识符（11位标准ID或29位扩展ID）、数据长度码（DLC）、CAN数据（0-2048字节）以及标志位（IDE指示扩展帧、FDF指示CAN FD、XLF指示CANXL）[^216^]。随后，多个ACF_CAN_BRIEF消息可聚合并附加**NTSCF（Non-Time-Synchronous Control Format）**头部，形成完整的NTSCF帧。NTSCF头部包含序列号、时间戳和载荷长度等控制信息，用于接收端的数据重组与同步检测。最后，DRE的Ethernet描述符处理器自动构建Ethernet L2头部（含可配置的目标MAC地址、可选的802.1Q VLAN Tag和AVTP Stream-ID），将NTSCF帧封装为标准Ethernet帧，通过GETH或LETH的DMA通道发送[^455^]。

![DRE CAN-to-Ethernet IEEE 1722封装流程](fig_dre_encapsulation_flow.png)

**图7-1：DRE CAN-to-Ethernet IEEE 1722封装流程图**。从MCMCAN接收CAN帧开始，经CRE触发、RCU调度、ACF格式引擎封装、NTSCF头部添加，最终形成完整Ethernet帧并通过GETH/LETH DMA发送，全程无需CPU介入。

上述封装流程的关键技术优势在于**协议开销极小**：ACF_CAN_BRIEF格式仅需8-16字节控制开销即可承载完整CAN帧信息[^402^]，对比传统UDP/IP隧道方案（28字节IP/UDP头部 + 应用层头部），带宽利用率提升3-4倍。此外，DRE支持对封装后的Ethernet帧配置**802.1Q VLAN Tag**，使得CAN数据流可映射到不同的TSN流量类别（Traffic Class），在GETH端口上获得差异化的服务质量保障[^455^]。

#### 7.2.3 CAN-to-Memory路由：28个目标区域，灵活存储

CAN-to-Memory路由模式将接收的CAN帧直接写入用户配置的内存区域，适用于数据记录、诊断缓冲和软件协议栈深度处理场景。DRE在该模式下支持以下特性[^216^]：

- **最多28个独立目标内存区域**，每个区域可配置独立的缓冲策略
- **循环缓冲区（Circular Buffer）**机制，自动地址递增与回卷
- **可配置水印中断**，当缓冲区填充达到设定阈值时触发CPU中断
- **可选时序头部**，包含入侵检测信息和硬件时间戳

每个虚拟CAN缓冲区由三部分组成：目标内存状态信息（可选，供软件监控缓冲区状态）、时序头部（包含64位时间戳和入侵检测信息）、CAN帧及其有效载荷数据[^216^]。这种灵活的结构允许系统架构师根据应用需求选择存储格式——对于高性能数据记录，可省略状态信息和时序头部以最小化存储开销；对于安全关键应用，可启用完整时序信息以支持事后追溯分析。

下表汇总DRE四类路由模式的技术规格对比：

| 路由模式 | 源接口 | 目标接口 | 核心机制 | 关键参数 |
|:---------|:-------|:---------|:---------|:---------|
| CAN-to-CAN | MCMCAN (20通道) | MCMCAN (跨模块) | CRE触发 + SPB Master传输 | CAN-ID路由表，RCU调度[^216^] |
| CAN-to-Ethernet | MCMCAN/CANXL | GETH/LETH | IEEE 1722 ACF封装 + NTSCF头部 | ACF_CAN_BRIEF, VLAN Tag[^219^] |
| CAN-to-Memory | MCMCAN | 内部存储器 | SRI Master直接写入 | 28区域，循环缓冲，水印中断[^216^] |
| Ethernet-to-Ethernet | GETH/LETH | GETH/LETH | 转发引擎查询FTCFG | 1:6多播，FID索引[^455^] |

从架构设计角度分析，这四类路由模式覆盖了汽车网关和区域控制器的全部核心数据通路。CAN-to-CAN路由保留传统CAN网络内部通信的低延迟特性；CAN-to-Ethernet路由实现异构网络间的无缝桥接，是将CAN数据引入以太网骨干网的关键机制；CAN-to-Memory路由为软件协议栈（如SOME/IP、DDS）提供零拷贝数据接入点；Ethernet-to-Ethernet路由则支持以太网帧在GETH与LETH端口间的快速转发，适用于区域控制器内部的数据汇聚。四类路由共享DRE的中央消息RAM和非饥饿仲裁器，确保并发场景下的资源公平分配[^455^]。

### 7.3 高级特性

#### 7.3.1 多播：Ethernet-to-CAN 1:4，Ethernet-to-Ethernet 1:6

DRE支持硬件级多播路由，无需CPU参与即可完成单帧到多目的地的复制与分发[^455^]。

在**Ethernet-to-CAN方向**，DRE支持**1:4多播**，即单个Ethernet帧（含多个ACF_CAN_BRIEF消息）可解封装后分发至最多4个不同的CAN接口。这一功能在区域控制器架构中极具实用价值：例如，来自中央计算平台的传感器配置指令通过Ethernet到达后，DRE可自动将其同时分发至该区域控制的4个独立CAN子网络，实现配置的一键同步下发[^455^]。

在**Ethernet-to-Ethernet方向**，DRE转发引擎支持更广泛的**1:6多播**，即单个接收的Ethernet帧可同时转发至最多6个目标Ethernet接口[^455^]。转发引擎依据用户配置的**转发表（Forwarding Table, FTCFG）**中的转发标识符（Forwarding ID, FID）进行目标接口解析。FID由源Ethernet接口索引（EIF）、DMA通道号（DMACH）和MAC地址匹配结果（MADRM）组合构造，在配置阶段通过EB tresos生成[^41^]。

多播功能的硬件实现依赖于DRE中央消息RAM的帧引用机制：帧数据在Message RAM中仅保存单一副本，多播时各目标通道获取该副本的只读引用并独立执行发送描述符提交，避免了数据冗余拷贝带来的带宽浪费。

#### 7.3.2 触发模式：帧计数、缓冲区填充、时间触发、软件触发

DRE为CAN-to-Ethernet路由提供四种发送触发模式，允许系统架构师根据流量特性选择最优的路由策略[^216^]：

| 触发模式 | 触发条件 | 适用场景 | 延迟特性 |
|:---------|:---------|:---------|:---------|
| 帧计数模式（Frame Count） | 累积至配置的帧数N后触发发送 | 周期性批量数据上报 | 累积延迟，带宽效率高 |
| 缓冲区填充模式（Buffer Fill） | 缓冲区填充达到设定阈值后触发 | 突发性CAN流量聚合 | 自适应延迟，抗突发 |
| 时间触发模式（Time-Triggered） | 到达配置的绝对时间点触发 | 确定性实时数据流传输 | 严格定时，抖动<1μs |
| 软件触发模式（Software） | CPU通过寄存器写入显式触发 | 诊断/标定等按需操作 | 立即响应，延迟可控 |

时间触发模式是DRE最具特色的功能之一。该模式与TC4x的**GTM（Generic Timer Module）**或**STM（System Timer）**硬件同步，在配置的绝对时间点触发Ethernet帧发送[^216^]。这意味着CAN数据从接收、封装到Ethernet发送的整个流水线可在亚微秒级精度上同步到全局时间基准，对于ADAS传感器融合、底盘控制闭环等严格时序要求的应用场景至关重要。Marelli在其基于TC4x的区域控制单元设计中明确指出，DRE的极低延迟CAN-Ethernet桥接能力是整合照明、车身、音频、动力总成等多个域控制单元至单一硬件的关键使能因素[^484^]。

四种触发模式可混合配置于不同的DRE路由通道，实现异构流量在同一硬件平台上的差异化处理。例如， chassis CAN数据配置为时间触发模式以确保确定性延迟，body CAN数据配置为帧计数模式以优化带宽利用率，diagnostic CAN数据配置为软件触发模式以支持按需查询。

#### 7.3.3 CANXL支持：2048字节载荷，20Mbps速率

TC4x的DRE从硬件层面支持**CANXL（CAN Extra Long）**协议，该协议将CAN帧数据场扩展至**2048字节**，通信波特率提升至**20 Mbps**，较CAN FD的64字节/8 Mbps规格实现数量级提升[^465^]。CANXL-to-Ethernet路由沿用与CAN/CAN FD相同的IEEE 1722 ACF封装机制，ACF_CAN_BRIEF消息格式可容纳完整的2048字节CANXL载荷[^472^][^473^]。

对于超大载荷场景，DRE需要处理CANXL帧封装后可能超过标准Ethernet MTU（1500字节）的情况。此时，DRE与GETH/Leth的Jumbo Frame（巨型帧）支持协同工作：GETH端口最大支持16KB帧长，LETH端口支持最大4KB帧长，均可轻松承载封装后的CANXL帧[^465^]。CANXL模块内置的集成DMA与DRE联动，实现从CANXL接收缓冲区到DRE Message RAM的零拷贝传输，进一步降低了大数据量场景下的CPU负载[^465^]。

从协议演进视角审视，CANXL代表了传统CAN总线向更高数据速率发展的方向，其2048字节载荷可满足新一代汽车传感器（如高分辨率雷达、激光雷达点云数据预处理单元）的带宽需求。DRE将CANXL帧无缝映射到IEEE 1722 AVTP格式并注入高速以太网骨干，实质上构建了一条从边缘CANXL传感器到中央计算平台的**全硬件数据高速公路**，为下一代自动驾驶数据架构提供了物理层保障。

