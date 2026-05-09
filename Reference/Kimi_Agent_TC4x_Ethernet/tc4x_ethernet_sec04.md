## 4. AVB与IEEE 1722协议支持

### 4.1 AVB与TSN的关系

#### 4.1.1 AVB作为TSN基础：802.1Qav、802.1AS的演进关系

音频视频桥接（Audio Video Bridging, AVB）是IEEE于2011至2014年间制定的一组标准集合，旨在为以太网提供时间同步和带宽预留机制，以支持音视频流的确定性传输 [^206^]。AVB协议栈的核心组件包括：IEEE 802.1AS（通用精确时间协议，gPTP），提供亚微秒级时间同步；IEEE 802.1Qav（基于信用的整形器，Credit-Based Shaper, CBS），保障时间敏感流的带宽分配；IEEE 802.1Qat（流预留协议，SRP），在传输路径上动态预留带宽；以及IEEE 802.1BA（AVB系统配置文件），定义完整的系统级要求 [^206^]。

时间敏感网络（Time-Sensitive Networking, TSN）在AVB的基础上进行了显著扩展。TSN保留了AVB的核心机制——gPTP时间同步和基于信用的整形——同时引入了更全面的流量调度能力 [^206^]。具体而言，TSN增加了IEEE 802.1Qbv时间感知整形器（Time-Aware Shaper, TAS），通过门控调度实现微秒级精度的时隙分配；IEEE 802.1Qbu帧抢占机制，允许高优先级帧中断低优先级帧的传输；IEEE 802.1CB帧复制与消除（FRER），提供1+1路径冗余；以及IEEE 802.1Qci逐流过滤与监管，防止错误流量源干扰网络 [^206^]。在同步层面，TSN将802.1AS演进为802.1AS-2020，增强了容错能力和多域支持。TC4x的GETH模块在硬件层面同时实现了CBS和TAS两种整形机制，使得单个芯片即可支持从AVB到TSN的完整流量管理谱系 [^133^]。

![AVB到TSN的协议演进关系](fig4_1_avb_tsn_evolution.png)

#### 4.1.2 汽车应用中的AVB场景：信息娱乐、音频分布、摄像头流

在汽车电子领域，AVB/TSN协议主要服务于以下三类应用场景。第一类是信息娱乐（In-Vehicle Infotainment, IVI）系统，涵盖后座娱乐、多屏互动等功能。AVB通过IEEE 1722 AVTP协议传输压缩或非压缩音视频流，利用呈现时间机制（Presentation Time Mechanism）确保多个扬声器或显示屏的同步渲染精度低于1微秒 [^209^]。第二类是多通道音频分布，典型配置采用AAF（AVTP Audio Format）子类型，以48 kHz采样率、32位位深、每帧6个采样的参数在125微秒的Class A观测间隔内传输，实现跨扬声器的相位同步 [^239^]。第三类是摄像头流传输，ADAS系统需要将多个摄像头的原始视频数据（通过RVF子类型）或压缩视频流（通过CVF子类型）传输至中央计算单元，AVB的带宽预留机制保障了这些高带宽流的可预测传输 [^214^]。

随着区域式（Zonal）E/E架构的普及，AVB的应用范围进一步扩展至传统总线隧穿——即将CAN/CAN FD帧封装为IEEE 1722 ACF消息，通过以太网骨干网传输。Excelfore的技术分析指出："TSN在此基础上增加了精确调度、时间同步和流量整形能力，使以太网能够在同一网络基础设施中同时支持高带宽传感器数据和实时控制流量" [^207^]。TC4x通过DRE（Data Routing Engine）硬件加速器实现CAN帧到ACF格式的自动封装，无需CPU介入即可完成协议转换 [^216^]。

### 4.2 IEEE 1722 AVTP协议详解

#### 4.2.1 AVTP帧格式：EtherType 0x22F0、通用头、呈现时间机制

IEEE 1722定义了音频视频传输协议（Audio Video Transport Protocol, AVTP），其在以太网Layer 2直接运行，EtherType字段值为**0x22F0**，无需经过IP/UDP协议栈，从而避免了TCP/IP处理引入的不可预测延迟 [^208^][^37^]。AVTP协议数据单元（AVTPDU）的帧结构如图4-2所示，由Ethernet Header（14字节，含6字节目的MAC地址、6字节源MAC地址和2字节EtherType）、可选的802.1Q VLAN Tag（4字节，其中PCP字段标识SR优先级类别）、AVTP通用头（Common Header，4字节起）、子类型特定头（Stream-Specific Header）以及变长Payload组成 [^208^]。

![IEEE 1722 AVTP帧结构](fig4_2_avtp_frame_format.png)

AVTP通用头的字节0包含7位的`subtype`字段，定义了Payload的格式类型；字节1包含控制/数据标志（cd，在1722-2016版本中已移除）；字节2包含`sv`（stream_id有效位）、`version`（通常为0）以及类型特定标志位，包括`mr`（media clock restart，媒体时钟重启）、`tv`（timestamp valid，时间戳有效）和`tu`（timestamp uncertain，时间戳不确定，当gPTP同步异常时置位）。字节3起为64位的`stream_id`，由48位的Talker MAC地址和16位的唯一流标识符拼接而成，在全局网络范围内唯一标识一条AVTP流 [^37^][^214^]。

呈现时间机制是AVTP实现跨设备媒体同步的核心。Talker在生成媒体采样时捕获当前gPTP全局时间 $T_{\text{currentGlobalTime}}$，叠加最大传输时间 $T_{\text{maxTransitTime}}$ 得到呈现时间 $T_{\text{avtpPresentationTime}}$，计算公式为：

$$T_{\text{avtpPresentationTime}} = T_{\text{currentGlobalTime}} + T_{\text{maxTransitTime}}$$

该值被写入32位的`avtp_timestamp`字段（`tv=1`表示有效）。Listener在接收到AVTPDU后，将数据缓冲至本地gPTP时间达到呈现时间时才传递给上层时间敏感应用，从而补偿网络传输时间的抖动，确保所有Listener同时渲染媒体 [^38^][^275^]。AUTOSAR IEEE1722Tp模块对此的定义为："AVTP呈现时间表示AVTPDU载荷中指定数据被转移至流数据消费者的时间敏感应用的gPTP时间" [^38^]。SR Class A的默认最大传输时间为2 ms（需向上取整至媒体时钟周期的整数倍），SR Class B在汽车应用中被缩短为10 ms（标准值为50 ms），以适应车载网络对低延迟的严格要求 [^275^][^280^]。

#### 4.2.2 支持的子类型：AAF/RVF/61883_IDC/CRF/TSCF/NTSCF

IEEE 1722-2016标准定义了多种AVTPDU子类型（标准中表6），TC4x通过AUTOSAR IEEE1722Tp模块支持其中与汽车应用密切相关的子类型，如表4-1所示。

**表4-1 TC4x支持的AVTP子类型及汽车应用场景**

| 子类型值 | 名称 | 功能描述 | 汽车应用场景 | AUTOSAR R24-11支持 |
|:---:|:---|:---|:---|:---:|
| 0x00 | 61883_IIDC | IEC 61883/IIDC over AVTP | 工业相机视频、MPEG2-TS容器传输 | 是 |
| 0x02 | AAF | AVTP音频格式 | 多通道PCM/AES3音频分布、跨扬声器同步 | 是 |
| 0x03 | CRF | 时钟参考格式 | 媒体时钟恢复、PLL锁相 | 是 |
| 0x04 | CVF | 压缩视频格式 | H.264/H.265压缩视频流传输 | 部分 |
| 0x05 | TSCF | 时间同步控制格式 | 时间敏感控制命令（底盘、转向、制动） | 是 |
| 0x07 | RVF | 原始视频格式 | 摄像头原始像素数据、ADAS传感器流 | 是 |
| 0x82 | NTSCF | 非时间同步控制格式 | CAN/LIN帧隧穿、非关键控制消息 | 是 |

AAF（ subtype 0x02，IEEE 1722-2016 Clause 7）专为非压缩数字音频设计，支持PCM和AES3两种封装格式。AAF PCM头字段包含`nsr`（标称采样率，范围8 kHz至192 kHz）、`sp`（稀疏时间戳模式标志）、`channels_per_frame`（每帧通道数）和`bit_depth`（16/24/32位）。在Avnu Milan规范中，AAF的典型配置为：48 kHz采样率下每帧6个采样，帧周期125 μs（Class A），可承载1至8个32位通道 [^239^][^240^]。

RVF（subtype 0x07，Clause 12）用于原始视频流传输，其头字段包含`active_pixels`（每行有效像素）、`total_lines`（总行数）、`pixel_depth`（像素位深）、`pixel_format`（像素格式码）和`colorspace`（色彩空间标识）。RVF允许将一帧视频分割为多个AVTPDU传输，解决了标准以太网MTU（1500字节）不足以承载完整视频帧的问题 [^214^][^283^]。CRF（subtype 0x03，Clause 10）是媒体时钟重建的关键机制，将在4.2.3节详细论述。TSCF（0x05）和NTSCF（0x82）作为AVTP控制格式（ACF）的两种头变体，是CAN over AVTP封装的基础，将在4.3节展开分析。

表4-1所列子类型覆盖了汽车电子从音视频娱乐到ADAS传感器数据传输再到控制命令隧穿的全谱系需求。AUTOSAR R24-11规范在R23-11基础上完成了对TSCF和NTSCF子类型的完整支持，实现了"在AUTOSAR通信栈中完成IEEE 1722规定的传统通信（CAN和LIN）隧穿过程"的目标 [^274^]。值得注意的是，IEEE1722Tp模块在R23-11中仅支持通过复杂设备驱动（CDD）进行音视频流交互，无法与COM或LdCom等标准BSW模块交换数据 [^38^]；R24-11通过ACF机制弥补了这一缺口，使CAN/LIN帧能够经由标准AUTOSAR栈在以太网上隧穿。

#### 4.2.3 媒体时钟重建：基于802.1AS时间戳的跨时间戳同步

尽管gPTP（802.1AS）为网络中的所有设备提供了统一的绝对时间基准，但各设备的本地媒体时钟（如48 kHz音频采样时钟）仍然存在漂移差异。长期来看，这种漂移会导致Listener端缓冲区上溢或下溢，破坏播放连续性 [^37^][^217^]。

CRF（Clock Reference Format）子类型专门用于解决这一问题。其工作机制如下：媒体时钟提供者（Media Clock Provider，作为Talker）发送CRF包，其中包含与媒体时钟速率相关的gPTP时间戳序列；媒体时钟消费者（Media Clock Consumer，作为Listener）接收CRF流后，通过锁相环（Phase-Locked Loop, PLL）将本地媒体时钟锁定到CRF流中的参考频率 [^209^]。CRF头中的`type`字段标识时钟类型（AUDIO_SAMPLE=0x00、VIDEO_FRAME_SYNC=0x02），`base_frequency`（29位）定义基准频率，`pull`（3位）提供分频/倍频系数以支持非整数倍频率关系（如1.001倍速的NTSC视频），`timestamp_interval`（16位）指定相邻时间戳之间的间隔 [^278^]。以48 kHz音频时钟为例，典型配置为`base_frequency=48000`、`timestamp_interval=96`，对应500 Hz（2 ms间隔）的CRF时间戳频率 [^278^]。

对于不具备PLL硬件的ECU，可采用基于时间戳差值平均的软件恢复方法：计算相邻CRF包时间戳的差值序列，取平均值后推导出主时钟的恢复频率 [^222^]。TC4x的DRE硬件加速器在接收到CRF流后，可将时间戳直接路由至GPT12模块辅助PLL锁相，进一步降低CPU负载 [^216^]。

### 4.3 CAN over AVTP封装(ACF)

#### 4.3.1 ACF_CAN与ACF_CAN_BRIEF格式差异与选择

AVTP控制格式（AVTP Control Format, ACF）定义于IEEE 1722-2016 Clause 9，为传统车载总线帧（CAN/CAN FD、LIN、FlexRay）的以太网隧穿提供了标准化的封装机制 [^214^][^229^]。在ACF消息类型中，`ACF_CAN`（0x01）和`ACF_CAN_BRIEF`（0x02）是汽车应用中最常用的两种格式，二者的字段构成差异如表4-2所示。

**表4-2 ACF_CAN与ACF_CAN_BRIEF格式对比**

| 字段 | ACF_CAN (0x01) | ACF_CAN_BRIEF (0x02) | 说明 |
|:---|:---:|:---:|:---|
| `msg_type` + `payload_length` | 2字节 | 2字节 | 消息类型(7b) + 载荷长度(9b) |
| `pad`（填充长度） | 3位 | 3位 | 32位对齐填充 |
| `mtv`（消息时间戳有效） | 1位 | 1位 | ACF_CAN_BRIEF中固定为0 |
| `rtr`（远程传输请求） | 1位 | 1位 | CAN RTR标志 |
| `eff`（扩展帧格式） | 1位 | 1位 | 0=11-bit ID, 1=29-bit ID |
| `brs`（位速率切换） | 1位 | 1位 | CAN FD BRS标志 |
| `fdf`（FD格式） | 1位 | 1位 | 0=CAN 2.0, 1=CAN FD |
| `esi`（错误状态指示） | 1位 | 1位 | 主动/被动错误状态 |
| `can_bus_id` | 5位 | 5位 | CAN总线标识符(0-31) |
| `message_timestamp` | 8字节 | **无** | gPTP同步时间(仅ACF_CAN) |
| `can_identifier` | 29位 | 29位 | CAN帧标识符 |
| `can_msg_payload` | 0-64字节 | 0-64字节 | CAN 2.0最多8B, CAN FD最多64B |
| **总载荷长度(Classic CAN)** | **16-24字节** | **8-16字节** | ACF_CAN_BRIEF节省8字节 |

两种格式的核心差异在于`message_timestamp`字段的有无。ACF_CAN包含64位的gPTP同步时间戳（`mtv=1`时有效），适用于需要精确时间关联的应用场景，如诊断日志记录或时间敏感控制命令的回溯。ACF_CAN_BRIEF省略该字段（`mtv`固定为0），以8字节的开销代价换取更小的封装 overhead，适用于对时间戳无需求的普通CAN帧隧穿 [^38^][^214^]。在Classic CAN帧（8字节数据）场景下，ACF_CAN的总载荷为16-24字节，而ACF_CAN_BRIEF仅为8-16字节，带宽效率提升约33%至50%。

在TC4x平台上，ACF格式选择需综合考虑以下因素。若应用场景需要记录CAN帧的精确接收时间（如用于端到端延迟分析或故障诊断），应选用ACF_CAN；若追求最大带宽效率且时间戳信息可由上层协议补充，则ACF_CAN_BRIEF更为适合。值得注意的是，TC4x的DRE硬件加速器主要支持ACF_CAN_BRIEF格式 [^216^]，这是因为DRE的设计目标是以最小开销实现高速CAN到以太网的无CPU路由，ACF_CAN_BRIEF的精简结构与此目标高度匹配。对于需要完整时间戳的应用，则需通过IEEE1722Tp软件模块以ACF_CAN格式进行处理。

#### 4.3.2 收集模式：帧计数、缓冲区填充、超时触发

ACF协议允许将多个ACF消息拼接在单个AVTPDU载荷中传输，这一聚合机制显著提升了以太网带宽利用率，避免了为每个CAN帧单独发送一个以太网帧所带来的开销（前导码、IFG等共计至少20字节）[^209^]。IEEE1722Tp模块和DRE硬件均支持ACF消息的收集与聚合，触发条件包括以下三种模式。

**帧计数触发（Frame Count）**：当收集到配置的CAN帧数量时触发以太网传输。该模式适用于流量稳定、周期性强的CAN总线，可确保固定的聚合粒度。DRE硬件支持对此模式的直接配置 [^216^]。

**缓冲区填充触发（Buffer Fill Level）**：当聚合缓冲区的填充量达到配置阈值时触发传输。AUTOSAR IEEE1722Tp模块通过`AcfCollectionThreshold`参数配置此阈值，典型值为1500字节（接近以太网MTU）[^209^]。该模式最大化单个以太网帧的载荷效率，适用于高负载CAN总线。

**超时触发（Timeout）**：当自首个收集帧起的时间超过配置的超时值时强制传输。`AcfCollectionTimeout`参数定义此超时时间，典型配置为1 ms [^209^]。该模式作为保底机制，防止低流量场景下CAN帧在缓冲区中无限等待，牺牲了部分带宽效率以换取 bounded latency。

上述三种触发模式可组合使用，形成"任一条件满足即触发"的语义。例如，配置`threshold=1500 bytes`且`timeout=1 ms`时，只要填充量达到1500字节或已等待1毫秒，即刻发送聚合的AVTPDU。这种组合策略在高负载时通过填充阈值保证效率，在低负载时通过超时保证延迟上限。

TC4x的DRE在此流程中实现了硬件级加速。当CAN帧到达源CAN接口时，CRE（CAN Routing Engine）检测到匹配帧并触发DRE；DRE从接收主机缓冲区读取CAN帧，将其封装为ACF_CAN_BRIEF格式，添加以太网头（MAC地址和可选的802.1Q VLAN Tag），然后将完整帧写入以太网发送缓冲区；最终由GETH MAC完成以太网帧的物理传输 [^216^]。整个过程中CPU零介入，仅在网络配置阶段由软件设定过滤规则（ classical CAN ID filter或mask-based range filter）和触发参数。DRE还支持将同一CAN帧路由至多达4个多播目的地，实现CAN到以太网的扇出（fan-out）分发 [^216^]。

从系统架构角度看，CAN over AVTP封装与DRE硬件加速的协同，使TC4x能够在保持整个CAN协议栈投资的同时，无缝迁移至以以太网为核心的区域式架构。CAN帧作为ACF消息在以太网骨干网上获得"一等公民"地位，其确定性时序通过TSCF子类型的呈现时间戳或多播分发的时间触发模式得以保留 [^209^]。这一机制在软件定义汽车（SDV）时代具有重要的现实意义：域控制器和区域控制器无需为CAN设备部署单独的协议网关，仅需通过IEEE1722Tp配置流参数即可实现CAN与以太网之间的透明桥接。
