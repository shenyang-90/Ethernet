# 2. Infineon TC4x Ethernet模块架构深度分析

AURIX TC4x系列是英飞凌面向汽车电子电气（E/E）架构演进推出的新一代多核安全MCU。相较于前代TC3x，TC4x的GETH（Gigabit Ethernet，千兆以太网）模块实现了从1 Gbps到5 Gbps的跨越式带宽提升，同时在DMA通道数、MTL（MAC Transaction Layer，MAC传输层）FIFO容量、TSN（Time-Sensitive Networking，时间敏感网络）硬件加速以及片内桥接能力等维度进行了全面重构。本章以TC4x GETH模块为分析对象，系统拆解其从顶层拓扑到内部子系统的技术架构，为Ethernet模块设计提供可对标的技术基准。

## 2.1 GETH模块顶层架构

### 2.1.1 双XGMAC+Bridge的模块拓扑

TC4x芯片中的GETH模块在硬件层面由最多两个XGMAC（10 Gigabit Media Access Control，万兆媒体访问控制）实例与一个Bridge（桥接器）模块组成，向下通过HSPHY（High Speed PHY，高速物理层）实现物理层信号转换[^8^]。这一拓扑设计区别于传统单MAC嵌入式以太网控制器，其双端口架构配合片内桥接能力，使TC4x能够在不依赖外部Switch的情况下实现双端口Ethernet节点的菊链级联，这一拓扑特征对于区域控制器（Zonal Controller）中多个传感器域的级联互联具有直接的工程价值。

下图展示了TC4x GETH模块的完整硬件拓扑：Host CPU通过64位总线与Bridge交互，Bridge分别连接两个独立的XGMAC核心，每个XGMAC向下通过专用的HSPHY模块对接物理层接口。

![Infineon AURIX TC4x GETH Module Architecture](fig_2_1_geth_architecture.png)

Bridge模块的存在意味着GETH模块内部存在三条静态数据路径：Host至XGMAC0、Host至XGMAC1，以及XGMAC0与XGMAC1之间的直接帧转发[^38^]。后者使得两个5 Gbps端口之间可以在零CPU负载的条件下完成二层帧交换，这一机制是后续菊链拓扑支持的基础硬件前提。

### 2.1.2 速率与PHY接口支持

TC4x GETH的Ethernet端口支持10 M/100 M/1 G/2.5 G/5 G五种速率的全双工（Full-Duplex）模式，同时保留10 M/100 M的半双工（Half-Duplex）兼容[^87^]。这一速率跨度覆盖了从传统车身网络调试接口到高带宽ADAS（Advanced Driver Assistance Systems，高级驾驶辅助系统）传感器数据回传的全部应用场景。HSPHY模块内部集成了最多三个MP8G PHY（Multi-Protocol 8 Gigabit PHY，多协议8千兆物理层），每个MP8G PHY由PCS（Physical Coding Sublayer，物理编码子层）和PMA（Physical Medium Attachment，物理介质连接）组成，线速率可在0.125 Gbps至8 Gbps之间配置[^158^]。针对Ethernet应用，HSPHY内部最多配置两个专用的XPCS模块，负责在Ethernet MAC与MP8G PHY之间进行编码适配，支持USXGMII和SGMII两种串行模式[^158^]。

**表2-1 TC4x GETH支持的PHY接口与速率矩阵**

| PHY接口 | 接口类型 | 支持速率 | 应用场景 | HSPHY内部映射 |
|:------:|:------:|:------|:------|:------|
| MII | 并行 | 10/100 Mbps [^8^] | 传统诊断、 legacy ECU | 直接并行接口 |
| RMII | 并行（精简） | 10/100 Mbps [^8^] | 低成本车身网络 | 引脚数减半的MII |
| RGMII | DDR并行 | 10/100/1000 Mbps [^39^] | 千兆主干网络 | DDR时钟，支持Skew控制 |
| SGMII | 串行 | 100/1000/2500/5000 Mbps [^39^] | 多速率车载骨干 | 经XPCS适配至MP8G |
| USXGMII | 串行（统一） | 100/1000/2500/5000 Mbps [^8^] | 多速率自动协商 | XPCS支持统一协议 |
| MDIO | 管理总线 | — | PHY寄存器配置 | 管理接口 |

该接口矩阵体现了TC4x GETH在物理层兼容性上的设计理念：保留对传统并行接口（MII/RMII/RGMII）的向下兼容，同时通过串行接口（SGMII/USXGMII）实现2.5 G/5 G高速扩展。RGMII接口还内置了Skew（时钟偏移）生成能力，HSPHY可通过内部配置在时钟信号上附加可控延迟，从而补偿PCB走线差异带来的采样时序偏差，降低对PCB等长设计的严格依赖[^39^]。

### 2.1.3 64位主机总线架构

TC4x GETH模块采用64位总线宽度，配合优化的总线访问接口，包括一个Local Cross Bar（本地交叉开关）与两条LCB2SRI连接通道[^8^]。这两条通道的设计亮点在于读写分离：一条LCB2SRI通道可专用于读事务（Read Transactions），另一条专用于写事务（Write Transactions），发送帧（TX）的数据缓冲区映射至第一个主控地址空间，接收帧（RX）的数据缓冲区映射至第二个主控地址空间[^8^]。这种物理分离使得TX和RX方向的帧数据可以同时以满缓冲区深度运行，避免了读写争用导致的总线带宽折损。XGMAC-AXI主控接口在DMA控制器统一管理下执行描述符获取（Descriptor Fetch）、描述符回写（Descriptor Writeback）以及数据搬运操作，所有DMA阶段均以流水线（Pipelined）方式独立并行执行[^8^]。

## 2.2 XGMAC核心内部结构

XGMAC是实现链路层功能的核心模块，其内部由XGMAC-CORE、MTL传输层、DMA控制器以及各类总线接口组成[^8^]。XGMAC整体遵循IEEE 802.3-2008与IEEE 802.3-2015标准，同时兼容IEEE 802.1AS 2020、IEEE 802.3az-2010、NBASE-T Alliance 2.5/5 Gigabit Ethernet（USXGMII）、RGMII v2.6及RMII v1.2等多项协议规范[^8^]。以下按子系统层级逐一拆解。

**表2-2 XGMAC内部子系统结构与功能映射**

| 子系统 | 全称 | 核心功能 | 关键规格参数 | 接口/寄存器 |
|:------:|:------|:------|:------|:------|
| CSR | Control and Status Register | DMA/MTL/MAC分层寄存器配置，MCU经SPB总线以AHB协议访问 [^8^] | 32位寄存器地址空间 | SPB→AHB转换 |
| DMA | Direct Memory Access | 8通道独立Tx/Rx引擎，描述符环管理，流水线操作 [^8^] | 每通道最多64K Tx/Rx描述符，接收缓冲区最大16 KB [^201^] | 64位AXI主控 |
| MTL | MAC Transaction Layer | FIFO缓冲与帧数据调节，Tx/Rx异步时钟域同步 [^8^] | 68位宽FIFO（64数据+4控制），Tx 32 KB / Rx 32 KB [^8^] | DMA↔MAC桥接 |
| MAC Core | Media Access Control Core | 802.3帧格式处理、VLAN/SA/FCS操作、PHY接口适配 [^8^] | XGMII/GMII/MII/RGMII/RMII全双工 | MTI/MRI/MCI |
| TPE | Transmit/Receive Packet Engine | 帧收发引擎、时间戳捕获、巨帧/EEE支持 [^8^] | Jabber定时器默认2048字节，巨帧模式扩展至10240字节 | MAC时钟域 |
| AFM | Address Filtering Module | 目的/源MAC地址过滤，VLAN过滤与哈希计算 [^201^] | 最多32个MAC地址过滤器 | 接收路径前置 |

上表展示了XGMAC内部六大子系统的功能分工与接口关系。CSR作为配置中枢，采用32位寄存器空间实现MCU对XGMAC的全面控制；DMA承担数据搬运主体工作；MTL提供关键的跨时钟域缓冲与QoS（Quality of Service，服务质量）队列管理；MAC Core执行802.3标准帧处理；TPE和AFM则分别在收发引擎和过滤逻辑上提供增强功能。这种分层结构符合经典Ethernet控制器的设计范式，但TC4x在每个子系统的规格参数上均实现了对前代的大幅超越。

### 2.2.1 CSR从接口

CSR（Control and Status Register，控制与状态寄存器）接口为MCU提供了访问XGMAC内部配置资源的统一通道。在GETH模块内部，DMA、MTL和MAC三个层级各自拥有独立的寄存器组[^8^]。MCU通过SPB（System Peripheral Bus，系统外设总线）访问该接口，总线数据在模块内部被转换为AHB（Advanced High-performance Bus，高级高性能总线）协议进行处理[^8^]。这种分层寄存器结构使得驱动开发可以按DMA配置、MTL队列管理、MAC帧操作三个维度进行模块化编程，降低了软件栈的耦合度。

### 2.2.2 DMA控制器

TC4x GETH的DMA控制器具备八个独立通道，较TC3x的四个通道实现翻倍[^8^]。每个通道拥有独立的Tx引擎和Rx引擎：Tx引擎负责将数据从系统内存搬运至MTL层，Rx引擎负责将数据从MTL层搬运至系统内存[^8^]。DMA采用寄存器与描述符列表（Descriptor Lists）相结合的机制，在最小化CPU负载的前提下高效完成数据搬运[^8^]。

在描述符层面，XGMAC支持环形结构（Ring Structure），通过`DMA_CHy_TxDesc_Ring_Length`和`DMA_CHy_RxDesc_Ring_Length`寄存器配置描述符环长度[^8^]。官方培训资料显示，每通道最多支持64K个Tx描述符和64K个Rx描述符，接收缓冲区最大可达16 KB[^201^]。描述符字段中，TDES3的OWN位（bit 31）标记DMA控制权归属，CTXT位（bit 30）区分常规描述符与增强描述符，FD/LD位分别标识首描述符和末描述符，CPC位控制CRC/Pad行为，SAIC位（bits 25:23）控制源地址插入行为，CIC/TPL位（bits 17:16）启用TCP/IP校验和辅助计算[^8^]。

DMA的流水线架构是其吞吐效率的核心：对新数据包的描述符获取、前一数据包的数据传输、以及再前一数据包的描述符回写三个阶段可以并行执行[^8^]。这种流水机制显著降低了包间传输间隔，对于5 Gbps线速下的小包突发场景尤为关键。

### 2.2.3 MTL传输层

MTL（MAC Transaction Layer，MAC传输层）在系统内存与XGMAC IP之间提供FIFO（First-In-First-Out，先进先出）缓冲与帧数据调节功能[^8^]。在TC4x的64位系统中，FIFO宽度为68位——64位数据位加4位控制位——并在发送和接收路径上分别实现异步FIFO以完成时钟域可靠同步[^8^]。

MTL层缓冲容量相较前代TC3x实现跨越式提升：TC3x的Tx FIFO仅为4 KB，Rx FIFO为8 KB；TC4x则将Tx和Rx FIFO分别扩展至32 KB[^8^]，即Tx方向提升8倍，Rx方向提升4倍。这一扩展直接支撑了8队列QoS管理所需的 deeper buffering，使每个队列在拥塞场景下拥有更大的吸收能力。MTL支持阈值模式（Threshold Mode）和存储转发模式（Store-and-Forward Mode）双工操作，前者在FIFO达到预设阈值时即启动传输以降低延迟，后者待完整帧存入FIFO后统一转发以保证帧完整性。

### 2.2.4 MAC核心

MAC Core（MAC核心层）完全遵循IEEE 802.3-2008行业标准，并实现XGMII/GMII/MII/RGMII/RMII全双工接口以与物理编码子层通信[^8^]。MAC层通过MTI（MAC Transmit Interface，MAC发送接口）、MRI（MAC Receive Interface，MAC接收接口）和MCI（MAC Control Interface，MAC控制接口）三个接口与应用侧交互[^8^]。

在帧处理功能上，MAC Core支持VLAN（Virtual Local Area Network，虚拟局域网）标签的逐帧粒度插入、替换与删除操作；支持源MAC地址的自动修改；并能在源地址变更后自动更新FCS（Frame Check Sequence，帧校验序列）[^2^]。TFC（Transmit Frame Controller，发送帧控制器）提供四种帧尾处理模式：对长度不小于60字节的帧自动附加CRC（Cyclic Redundancy Check，循环冗余校验）；对短帧补充填充至60字节后追加CRC；仅追加CRC而不补充填充；以及完全禁用CRC由应用层自行处理校验[^2^]。

## 2.3 Bridge与网络互联

### 2.3.1 Bridge架构

Bridge（桥接器）是TC4x GETH区别于TC3x的关键新增模块，其连接两个XGMAC与主机接口，支持在三者之间静态建立数据路径，实现Ethernet帧的转发[^2^][^38^]。具体而言，Bridge支持三类转发方向：从Host到任一XGMAC、从两个XGMAC到Host，以及从一个XGMAC到另一个XGMAC[^38^]。

Bridge的帧转发无需软件参与，即不占用CPU负载[^201^]。这种硬件级桥接能力在区域控制器架构中具有明确的拓扑价值：当TC4x作为中间节点串联两个Ethernet网段时，来自端口0的帧可以直接经Bridge转发至端口1，反之亦然，无需将数据包先送至CPU内存再重新下发。这种"cut-through"式的片内转发大幅降低了级联节点的转发延迟，并释放了CPU带宽用于应用层处理。

### 2.3.2 灵活帧解析器（FFP）

TC4x GETH在每个5 Gbps MAC中各集成一个灵活帧解析器（Flexible Frame Parser，FFP），提供高度可编程的帧过滤能力[^201^]。FFP通过一棵最多包含256个比较节点的可编程二叉树对入帧的任意部分进行逐层评估，每个比较节点可检测入帧中最多32位宽的数据段，并产生Match（匹配）或Fail（不匹配）判决结果[^201^]。

FFP的判决结果直接驱动帧的转发或丢弃决策，为硬件防火墙和入侵检测服务（IDS/IDPS）提供了底层支撑[^87^]。在802.1Qci Per-Stream Filtering and Policing（PSFP，逐流过滤与管制）的语境下，FFP充当流过滤器的硬件实现基础，负责标识数据流ID并将其映射至最多8个网关ID之一，后续由GCL（Gate Control List，门控列表）进行流闸门控制，PC（Police Counter，管制计数器）实现流量计量[^288^]。需要指出的是，8个网关ID的限制意味着并发独立 policing 的流数量存在硬件上限，对于流密度极高的场景需通过软件分流或聚合策略补偿。

### 2.3.3 菊链拓扑支持

双端口Bridge的硬件转发能力为菊链（Daisy Chain）拓扑提供了原生支持。在菊链架构中，多个区域控制器通过单一Ethernet链路依次串联，每个中间节点需要同时作为终端接收本节点数据并作为中继转发上下游数据。TC4x的XGMAC0↔XGMAC1直接转发路径使这一拓扑无需外部Layer-2 Switch即可实现[^201^]，配合IEEE 802.1AS时间同步和802.1Qbv门控调度，可以构建确定性的线性级联网络。这一设计权衡体现了TC4x"集成深度优先"的架构路线：将网络交换功能尽可能集成于MCU片内，以减少BOM（Bill of Materials，物料清单）成本和PCB面积。

![TC3x vs TC4x GETH Key Metrics and PHY Interface Coverage](fig_2_2_tc3x_tc4x_comparison.png)

上图直观呈现了TC3x到TC4x在关键规格上的代际跃迁。左图显示DMA通道、FIFO容量和队列数量均实现翻倍或数倍增益，右图表明PHY接口从并行主导（MII/RMII/RGMII）扩展至串行高速接口（SGMII/USXGMII）的全面覆盖。这一跃迁意味着TC4x的GETH模块已不再是传统意义上的"MAC+PHY"组合，而是一个具备交换、过滤、TSN加速和安全卸载能力的集成网络子系统。

## 2.4 硬件卸载功能

硬件卸载（Hardware Offload）是将本应由CPU执行的协议处理操作下沉至Ethernet控制器硬件的过程，其目标是降低CPU中断频率和计算负载，提升有效吞吐率。TC4x GETH在多个协议层面提供了卸载支持。

**表2-3 TC4x GETH硬件卸载功能矩阵**

| 卸载功能 | 协议/标准 | 操作方向 | 控制机制 | 技术规格 |
|:------:|:------|:------:|:------|:------|
| TCP/IP校验和 | IPv4/IPv6/TCP/UDP/ICMP | Tx计算+Rx验证 [^2^][^34^] | TDES3 CIC/TPL位（bits 17:16）[^8^] | 硬件自动计算并插入/验证 |
| IPv4头校验和 | IPv4 | Rx路径检查 [^34^] | MAC配置寄存器IPC位 | 仅接收方向 |
| VLAN标签操作 | 802.1Q | Tx插入/替换/删除 [^2^] | MAC_VLAN_Incl寄存器VLT字段 | 逐帧粒度或全局配置 |
| 源地址操作 | MAC地址 | Tx插入/替换 [^2^] | TDES3 SAIC位（bits 25:23）[^8^] | 基于MAC_Address0寄存器 |
| CRC/Pad处理 | 802.3 | Tx四种模式 [^2^] | TFC自动/填充/仅CRC/禁用 | 自动更新FCS |
| FCS更新 | 802.3 | Tx自动重算 [^2^] | 源地址变更触发 | 与SA操作联动 |
| TSO | TCP分段 | — | 未确认硬件支持 | 研究未发现TSO明确文档 |

上表汇总了TC4x GETH的硬件卸载能力。其中TCP/IP校验和卸载覆盖了传输层的核心计算任务，对于需要处理大量TCP/UDP流量的车载诊断或OTA（Over-The-Air，空中升级）场景，可将CPU从逐包校验和计算中解放出来。VLAN标签和源MAC地址的逐帧粒度操作则对需要动态封装或代理转发的应用场景（如车载以太网网关中的VLAN隔离或MAC地址重写）具有直接工程意义。

### 2.4.1 TCP/IP校验和卸载

TC4x GETH通过TDES3中的CIC/TPL位（bits 17:16）控制TCP/IP校验和辅助计算功能的使能[^2^]。在发送路径上，校验和卸载引擎（COE，Checksum Offload Engine）自动计算并插入校验和；在接收路径上，引擎对接收帧的校验和进行验证[^459^]。MAC配置寄存器的IPC（Checksum Offload，bit 10）位用于使能IPv4头校验和检查以及TCP/UDP/ICMP载荷头校验和验证[^442^]。这种双向卸载能力覆盖了IPv4/IPv6头部与TCP/UDP/ICMP传输层协议的完整校验和生命周期。

### 2.4.2 TSO与分片

TCP分段卸载（TSO，TCP Segmentation Offload）是数据中心级NIC（Network Interface Controller，网络接口控制器）的常见功能，但在车载Ethernet控制器中并非标准配置。针对TC4x GETH的广泛技术检索未找到TSO硬件支持的明确文档证据，DMA描述符字段中也未见TSO专用控制位。这一现象与汽车Ethernet的设计优先级一致：车载网络以确定性延迟和协议可靠性为核心诉求，而非极致吞吐率，因此TSO这类面向大带宽批量传输的卸载功能在汽车MCU中通常被省略。

### 2.4.3 VLAN与SA操作

TBU（Transmit Bus Interface，发送总线接口）支持基于逐帧或全局范围的VLAN标签动态处理：通过配置`MAC_VLAN_Incl`寄存器的VLT位域，可实现VLAN标签的插入、删除或替换[^2^]。在源MAC地址（SA，Source Address）处理方面，TBU模块支持通过`MAC_Address0_High`和`MAC_Address0_Low`寄存器配置SA字段内容，实现源地址的添加与替换；若原始帧已包含FCS，TBU会自动重新计算并更新为准确的FCS校验值[^2^]。TDES3中的SAIC位（bits 25:23）提供了逐描述符级别的SA插入控制，使得上层协议栈可以在不修改帧内容的情况下，通过描述符配置即完成MAC层源地址的自动重写[^2^]。

## 2.5 功能安全与网络安全

汽车MCU的Ethernet模块不仅要满足带宽与协议需求，还必须符合ISO 26262功能安全标准和ISO 21434网络安全标准。TC4x GETH在这两个维度均建立了完整的硬件机制。

### 2.5.1 安全机制

TC4x GETH为存储器和寄存器提供ECC（Error Correction Code，错误校正码）保护，ECC类型为SECDED（Single Error Correction, Double Error Detection，单错误纠正双错误检测），由每个存储器实例的SSH（SRAM Support Hardware，SRAM支持硬件）模块管理[^605^]。单比特错误由硬件实时纠正，不视为安全相关故障；双比特错误触发Trap和SMU（Safety Management Unit，安全管理单元）报警[^20^]。

除ECC外，GETH还支持FSM（Finite State Machine，有限状态机）奇偶校验与超时保护，以及应用/CSR接口超时保护[^87^]。这些机制共同构成了对Ethernet控制器内部逻辑通路和配置访问路径的故障覆盖。在功能安全等级上，TC4x中除SCR（System Control Register，系统控制寄存器）和CSRM（Customer Specific ROM，客户专用ROM）等少数模块为QM或ASIL-B等级外，其余模块硬件电路均可达到ASIL-D等级[^20^]，Ethernet通信外设（GETH/LETH/XGETH）包含在内。这一设计使得基于TC4x的Ethernet节点可在系统层面支持最高ASIL-D的功能安全需求，无需为通信路径额外增加外部安全监控电路。

### 2.5.2 CSS网络安全

TC4x的网络安全能力由CSS（Cyber Security Satellite，网络安全卫星）模块集中承载。CSS集成21通道加密加速器，支持MACsec、IPsec、D/TLS和SecOC（PDU级别）等安全算法的硬件加速[^316^]。在MACsec（IEEE 802.1AE-2018）方面，CSS提供高达763 MB/s的硬件加速能力[^339^]，可在400 MHz工作频率下以0.135 μs处理64字节Ethernet帧（128位密钥）或以1.335 μs处理1024字节帧[^339^]。这一性能足以覆盖5 Gbps线速下的MACsec帧认证需求，使TC4x成为当前车规MCU中唯一在片内集成MACsec硬件加速的产品[^7^]。

CSS的加密加速器阵列包含3组AES引擎，支持CMAC、GMAC、GHASH等密码模式，以及ChaCha20-Poly1305 AEAD（Authenticated Encryption with Associated Data，关联数据认证加密）套件，ChaCha20吞吐率达856 MB/s，Poly1305达468 MB/s[^339^]。这些算法原语不仅服务于MACsec，还为TLS 1.3和DTLS的安全通道建立提供了硬件基础。

在入侵检测与防护层面，GETH模块的可编程报头检测能力（FFP）与Bridge的流量分类功能协同，可实现L2/L3/L4级别的过滤、监控和防火墙保护[^87^]。FFP的256节点二叉树结构支持对入帧任意偏移处的32位字段进行模式匹配，这一粒度足以检测常见网络攻击特征码，并在硬件层面直接丢弃可疑帧，避免恶意流量到达CPU。

综合上述分析，TC4x GETH模块通过双XGMAC+Bridge的顶层拓扑、大幅扩展的DMA/MTL规格、全面的TSN硬件支持、丰富的协议卸载能力以及片内集成的功能安全与网络安全机制，构建了一个高度集成的车载网络子系统。其架构特征可概括为"深度集成、高带宽、确定性时延、安全内置"，这一设计路线为需要同时处理高带宽数据平面与安全控制平面的区域控制器提供了完整的片上解决方案。在后续章节的跨架构对比中，TC4x的这一集成深度将成为衡量其他厂商Ethernet方案的重要基准。
