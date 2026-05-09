## 3. TSN协议深度解析

时间敏感网络（Time-Sensitive Networking, TSN）是一组IEEE 802.1标准的集合，旨在以太网上提供确定性、低延迟、高可靠的数据传输。AURIX TC4x通过GETH与LETH双模块架构，在硬件层面实现了对核心TSN协议的全面支持。本章将逐条解析TC4x支持的六个TSN协议——IEEE 802.1AS、802.1Qav、802.1Qbv、802.1Qbu、802.1Qci和802.1CB——深入剖析各协议的工作原理、硬件实现细节，以及GETH与LETH在功能支持上的关键差异。

### 3.1 IEEE 802.1AS-2020 时间同步

#### 3.1.1 gPTP基本原理

IEEE 802.1AS-2020定义了广义精确时间协议（generalized Precision Time Protocol, gPTP），它是IEEE 1588-2019的TSN优化配置文件，为以太网中的所有设备提供亚微秒级时钟同步 [^30^][^183^]。gPTP与通用PTP的关键区别在于其严格限定于二层运行：所有PTP消息直接封装在以太网帧中，使用Ethertype 0x88F7，不经过IP层转发，从而消除了IP协议栈引入的抖动不确定性 [^154^]。

gPTP采用Peer-to-Peer（P2P）延迟测量机制替代了端到端（E2E）方案。在P2P模式下，每个端口独立测量与直连邻居的链路延迟（meanLinkDelay），公式为 $D = \frac{1}{2} \times [r \times (t_4 - t_1) - (t_3 - t_2)]$，其中 $r$ 为neighborRateRatio，$t_1$~$t_4$ 为Pdelay_Req/Pdelay_Resp交换过程捕获的四个时间戳 [^146^][^148^]。P2P机制的优势在于链路延迟变化可本地感知，无需等待主时钟重新计算整条路径的累积延迟。

BMCA（Best Master Clock Algorithm，最佳主时钟算法）负责自动选举网络中的Grandmaster（GM）。在汽车应用中，GM选择通常采用静态配置而非动态BMCA，以减少拓扑变化带来的时钟切换抖动。TC4x的BMCA实现遵循802.1AS-2020规范，支持通过Announce消息交换时钟质量参数（clockClass、clockAccuracy、offsetScaledLogVariance），优先级最高的节点成为GM [^188^]。

#### 3.1.2 TC4x硬件实现

TC4x的GETH模块基于Synopsys DesignWare XGMAC IP核，在时间戳捕获精度上达到了SFD（Start-of-Frame Delimiter）级——即硬件在MII总线上检测到SFD出现在TX/RX总线的瞬间捕获系统时间 [^28^]。这一触发点代表了帧开始在物理介质上传输的精确时刻，消除了MAC内部处理流水线引入的延迟误差。

系统时间的维护依赖于一组64位寄存器：MAC_System_Time_Seconds（偏移0xD08，32位秒计数器）和MAC_System_Time_Nanoseconds（偏移0xD0C，32位纳秒计数器）。当TSCTRLSSR位（bit 9）置1时，纳秒寄存器在0x3B9A_C9FF（999,999,999 ns）处回滚，实现严格纳秒分辨率 [^198^]。时钟频率精调通过Addend寄存器（MAC_Timestamp_Addend，偏移0xD18）完成，其计算公式为 $Addend = 2^{32} / (ClockFreq \times PeriodInSeconds)$。以100 MHz PTP参考时钟为例，Addend值配置为 $2^{32} / (100 \times 10^6 \times 10^{-9}) = 0x028F5C28$ [^66^]。软件通过设置TSADDREG位（bit 5）触发Addend值的原子加载，实现平滑的频率漂移补偿，避免粗调带来的时间跳变。

发送描述符（TDES）中的TTSE位（bit 30）控制单帧时间戳使能，完成传输后DMA将时间戳回写到TDES0/TDES1字段。接收路径采用上下文描述符机制——当RDES3的CTXT位置位时，RDES0/RDES1承载捕获的接收时间戳 [^28^]。

#### 3.1.3 多域支持

802.1AS-2020相较于2011版最显著的增强是引入了多域（Multi-Domain）支持。TC4x支持Common Mean Link Delay Service（CMLDS），允许不同gPTP域共享同一组链路延迟测量结果，避免多域场景下重复的Pdelay消息交换带来的带宽开销 [^200^]。CMLDS在大型网络中的效率优势尤为明显：假设网络中存在$N$个时间域，传统模式下每个端口需要进行$N$次独立的Pdelay测量，而CMLDS模式下仅需一次测量，所有域共享结果。

外部端口配置（External Port Configuration）是另一项关键增强，允许管理员通过管理接口直接指定端口角色（Master/Slave/Passive），绕过BMCA自动选举过程。这在汽车网络中具有重要实用价值——GM通常固定为中央计算节点（如中央网关或HPC），静态配置消除了BMCA收敛期间的时钟不确定性。

**表3-1 gPTP关键特性与TC4x硬件支持对照**

| 特性 | 规范要求 | GETH实现 | LETH实现 | 技术影响 |
|------|----------|----------|----------|----------|
| 时间戳触发点 | SFD级精度 | SFD硬件捕获 [^28^] | SFD硬件捕获 [^114^] | 消除MAC处理抖动 |
| 时钟精调 | sub-ns级频率调整 | Addend寄存器32位精度 [^66^] | Addend寄存器32位精度 | 平滑漂移补偿 |
| 同步模式 | 两步/一步可选 | 两步为主，支持一步 [^46^] | 两步为主 | 两步模式兼容性最佳 |
| CMLDS多域 | 802.1AS-2020新增 | 支持 [^200^] | 支持 | 多域共享延迟测量 |
| PTP Offload | 可选硬件加速 | 支持自动Sync生成 [^47^] | 有限支持 | 降低CPU协议处理负载 |
| PPS输出 | 外部时钟同步 | 4路PPS输出 [^46^] | 有限 | GPS等外部时间源对齐 |

表3-1的对比揭示了一个重要的设计权衡：GETH与LETH在时间戳精度层面基本持平，均支持SFD级硬件捕获和Addend寄存器精调，但在PTP Offload和PPS输出能力上GETH显著领先。对于仅需时钟从属（Slave）功能的边缘节点，LETH的gPTP实现已完全满足需求；然而，对于承担Grandmaster角色的中央节点，GETH的PPS输出和多路能力使其成为更可靠的选择。

### 3.2 IEEE 802.1Qav — 基于信用的整形器（CBS）

#### 3.2.1 CBS工作原理

IEEE 802.1Qav定义了基于信用的整形器（Credit-Based Shaper, CBS），其核心机制可类比为"带储蓄功能的信用卡"模型 [^30^]。每个流量类别（Traffic Class, TC）拥有独立的credit计数器，该计数器可在正负区间内浮动，受hiCredit（储蓄上限）和loCredit（债务下限）两个边界约束。

credit的动态变化遵循以下规则：当队列为空或等待传输时，credit以idleSlope速率线性增长；当队列正在传输帧时，credit以sendSlope速率线性下降。sendSlope的计算公式为 $sendSlope = idleSlope - portTransmitRate$。由于idleSlope始终小于portTransmitRate，sendSlope为负值，即credit在传输期间递减。传输决策门限为credit $\geq$ 0：仅当credit非负时，队列中的帧才被允许发送至MAC。若credit在传输过程中降至零以下，当前帧仍允许继续传输至完成（进入"债务"状态），但下一帧必须等待credit回升至非负区域 [^33^]。

hiCredit和loCredit的设定与物理层参数直接相关：$hiCredit = maxInterferenceSize \times (idleSlope / portTransmitRate)$，$loCredit = maxFrameSize \times ((idleSlope / portTransmitRate) - 1)$。这两个边界防止了credit无限累积或债务无限扩张，确保了各流量类别之间的公平性。

#### 3.2.2 SR Class A/B流量类别与硬件队列映射

802.1Qav定义了两类流预留（Stream Reservation, SR）流量：SR Class A要求端到端延迟上限为2 ms，默认映射至Priority 3；SR Class B要求50 ms延迟上限，默认映射至Priority 2 [^30^]。TC4x GETH为每个发送队列提供独立的CBS硬件实例，通过MTL层寄存器组进行配置：portj_MTL_TCnA_CBS_CONTROL控制CBS使能，CBSISQ配置idleSlope，CBSSSLOPE配置sendSlope，CBSHICREDIT和CBSLOCREDIT分别设定credit上下边界 [^111^]。GETH最多支持8个队列的并行CBS运算，LETH则支持4个队列 [^114^]。

#### 3.2.3 已知Errata分析

TC4x GETH和LETH模块存在一个影响CBS精度的已知缺陷（GETH_AI.029 / LETH_AI.005）：标准规定credit递减应覆盖完整的帧开销——包括前导码（Preamble）、帧校验序列（FCS）以及帧间间隔（IPG，最小12字节）。然而实际硬件实现中，credit仅递减至FCS的最后一个字节，随后在IPG期间以idleSlope速率反向递增 [^41^]。

该缺陷导致的额外带宽消耗可通过定量分析估算。假设编程带宽为30%（idleSlope/portTransmitRate = 0.3），每帧有效载荷128字节，传输100帧：额外带宽 = $30\% \times (100 \times 12) / (100 \times (8 + 128)) \approx 2.65\%$，实际有效带宽从编程的30%上升至约32.65% [^41^]。在工程实践中，开发人员应将目标带宽下调约2.5%~3%以补偿此偏差。对于SR Class A等高优先级流量，该误差的累积效应可能导致低优先级流量的传输窗口被意外压缩，需在系统设计阶段纳入裕量计算。

**表3-2 CBS参数配置与Errata影响量化**

| 参数 | 寄存器/字段 | 计算公式/典型值 | GETH范围 | LETH范围 |
|------|-------------|-----------------|----------|----------|
| idleSlope | MTL_TCnA_CBSISQ | 带宽比例×线速 | 0~5Gbps等效 | 0~100Mbps等效 |
| sendSlope | MTL_TCnA_CBSSSLOPE | idleSlope − portTransmitRate | 负值，硬件计算 | 负值，硬件计算 |
| hiCredit | MTL_TCnA_CBSHICREDIT | maxInterferenceSize×(idleSlope/线速) | 32位有符号 | 32位有符号 |
| loCredit | MTL_TCnA_CBSLOCREDIT | maxFrameSize×(idleSlope/线速−1) | 32位有符号 | 32位有符号 |
| IPG Errata影响带宽 | — | ~2.65%（128B帧@30%BW）[^41^] | GETH_AI.029 | LETH_AI.005 |
| 队列数量 | — | — | 8路独立CBS | 4路独立CBS |

表3-2的数据揭示了CBS配置的关键工程约束。idleSlope直接决定了为特定流量类别预留的带宽比例，在千兆速率下其寄存器值可达数百万量级，要求开发人员精确计算以避免配置溢出。IPG Errata的影响虽仅为2.65%，但在严格的带宽预留场景中（如SR Class A要求保证2 ms延迟），这一偏差可能导致帧调度提前，破坏下游交换机的整形预期。建议在系统中为CBS配置保留3%~5%的带宽裕量。

### 3.3 IEEE 802.1Qbv — 时间感知整形器（TAS）

#### 3.3.1 门控列表（GCL）机制

IEEE 802.1Qbv定义的时间感知整形器（Time-Aware Shaper, TAS）是实现确定性传输的核心机制。TAS将时间轴划分为重复的周期（Cycle），每个周期进一步细分为多个时段（Time Slot），通过门控列表（Gate Control List, GCL）精确控制每个发送队列的开启（Open）与关闭（Closed）状态 [^30^][^33^]。

每个GCL条目（Gate Control Entry, GCE）包含两个字段：gate_state位掩码（8位，每位对应一个TC队列的开关状态）和time_interval时长（以纳秒为单位）。GCL的执行与gPTP时间基严格同步——Base Time寄存器定义调度启动的绝对时间点，Cycle Time寄存器定义周期的重复间隔（有效范围256 ns至999,999,999 ns）[^111^]。

TC4x GETH通过MTL层的Enhanced Scheduling Traffic（EST）引擎实现TAS。MTL_EST_CTRL寄存器的EEST位（bit 0）全局使能TAS功能；SSWL位（bit 1）触发软件侧GCL列表的原子切换；PTOV字段配置PTP时间偏移补偿；TILS字段控制时间间隔的左移精度 [^111^]。EST引擎内部维护与gPTP时间基同步的周期计数器，在每个GCL转换点同步更新所有队列的门控状态。

#### 3.3.2 双银行配置与无中断更新

TC4x GETH和LETH均支持双银行（Dual-Bank）GCL架构，这是实现hitless（无中断）配置更新的关键。硬件同时维护Bank 0和Bank 1两组GCL存储器，EST引擎执行当前激活银行的同时，软件可安全地写入另一银行 [^28^]。配置更新通过MTL_EST_CTRL.SSWL位触发，硬件在当前周期结束后原子切换到新银行。MTL_EST_STATUS寄存器的SWOL位指示当前激活银行编号，SWLC位（Switch Complete）标识切换完成状态，BTRE位（Base Time Error）则报告Base Time编程错误（如设定时间已过）[^111^]。

这一机制对于动态调度场景至关重要。例如，在汽车网络中，正常驾驶模式与自动驾驶模式可能拥有完全不同的流量调度需求——前者以传感器数据为主，后者以融合决策数据为主。双银行GCL允许两种模式配置预先写入不同银行，模式切换仅需一次寄存器操作即可在下一个周期边界生效，不会造成传输中断或帧丢失。

#### 3.3.3 GCL深度与确定性保障

GCL深度直接决定了调度方案的时间粒度与复杂度。TC4x GETH的GCL容量由GMAC_HW_FEATURE3寄存器的ESTDEP字段标识：值为5时对应1024个条目 [^111^]。这一容量在车载网络中具有显著的工程意义——假设Cycle Time为1 ms，1024个条目允许将每个周期细分为平均约0.98 μs的时段，或构造包含数百个不同模式的复杂调度序列。对于典型的汽车应用，可将GCL组织为多层结构：顶层保留严格的时间关键窗口（如SR Class A的2 ms deadline保障），中层分配中等优先级流量，底层开放尽力而为（Best-Effort）传输。

TAS同样存在已知Errata（GETH_AI.032 / LETH_AI.008）：当EST使能时，发送调度器在当前帧完全转发至MAC发送器之前延迟下一帧调度，导致额外IPG。最坏情况下额外延迟为12个时钟周期（以fGETH和MAC Transmitter时钟中较慢者计），换算为位时间后需纳入Guard Band尺寸计算 [^41^]。Guard Band的基本计算公式为 $T_{guard} = (L_{max} \times 8) / R_{line} + T_{margin}$（无抢占模式）或 $T_{guard} = (L_{frag,max} \times 8) / R_{line} + T_{margin}$（启用帧抢占模式）[^119^]。

### 3.4 IEEE 802.1Qbu — 帧抢占

#### 3.4.1 pMAC/eMAC双MAC架构

IEEE 802.1Qbu定义了帧抢占（Frame Preemption）机制，允许快速（Express）帧中断可抢占（Preemptable）帧的传输，从而将时间关键流量的等待延迟从完整最大帧传输时间降低至一个片段传输时间。该机制在物理MAC内部引入了两个虚拟MAC实体：eMAC（Express MAC）处理不可抢占的时间关键流量，pMAC（Preemptable MAC）处理可被中断的尽力而为流量 [^29^]。

eMAC在仲裁上始终优先于pMAC。当eMAC有待发帧而pMAC正在传输时，MAC Merge层向pMAC发出hold请求；pMAC在当前片段边界（64字节的整数倍）处暂停传输，追加mCRC（修改的CRC）后释放介质；eMAC帧立即发送；eMAC完成后pMAC通过release信号恢复剩余片段的传输 [^126^]。这一hold/release机制在物理层通过IEEE 802.3br定义的SMD（Start/Modify Delimiter）码实现：SMD-S标记可抢占帧起始，SMD-C标记片段延续，SMD-E标记快速帧。

#### 3.4.2 帧分段与重组流程

帧抢占的分段过程遵循严格的协议规范。原始帧被分割为多个片段，每个片段（除最后一个外）长度必须是64字节的整数倍，并以mCRC结尾。接收端通过SMD码识别片段序列，将片段缓冲并重组为完整帧，最终对重组后的帧执行完整CRC验证 [^29^]。

MAC Merge层在链路建立时执行验证（Verification）流程：两端交换verify mPacket确认彼此支持帧抢占功能。验证状态机包含INITIAL、SUCCEEDED、FAILED、DISABLED四个状态，仅当状态为SUCCEEDED时抢占功能激活。TC4x提供MACMERGE_SUPPORT、MACMERGE_ENABLE、MACMERGE_ACTIVE、MACMERGE_VERIFY_STATUS等状态指示，以及MACMergeFrameAssOkCount、MACMergeFragCountTx/Rx、MACMergeHoldCount等统计计数器，便于开发调试 [^28^]。

#### 3.4.3 GETH-only限制与架构影响

**帧抢占是GETH与LETH之间最关键的功能差异。** GETH完整支持IEEE 802.1Qbu和802.3br MAC Merge，而LETH完全不支持帧抢占 [^30^]。这一限制的架构影响需从两个层面分析。

在功能层面，缺少帧抢占意味着LETH端口上的时间关键流量必须等待当前正在传输的任何帧完成——最坏情况下需等待一个1518字节帧的完整传输时间（100 Mbps下约122 μs，10BASE-T1S下约1.2 ms）。这一等待时间远超SR Class A的2 ms延迟预算，使得LETH无法独立承载严格的时间关键流量路径。

在补偿层面，开发人员可通过精细化TAS配置部分弥补该缺陷。具体策略是：在GCL中为时间关键流量预留足够大的保护窗口，Guard Band尺寸按完整最大帧计算（而非抢占模式下的片段尺寸），确保在该窗口内不会有低优先级帧开始传输。然而，这种方法以牺牲链路利用率为代价——Guard Band期间介质空闲等待，有效带宽下降。

### 3.5 IEEE 802.1Qci — 过滤与监管（PSFP）

#### 3.5.1 流过滤器：灵活帧解析器（FFP）

IEEE 802.1Qci定义了逐流过滤与监管（Per-Stream Filtering and Policing, PSFP），在交换机入端口处隔离故障流和恶意流量，防止其影响网络中其他正常流量 [^30^][^33^]。PSFP管道由三个级联组件构成：流过滤器（Stream Filter）、流门控（Stream Gate）和流量计（Flow Meter）。

TC4x的流过滤器通过Flexible Frame Parser（FFP）实现。FFP是可编程的帧解析引擎，支持基于目的MAC+VLAN ID、源MAC+VLAN ID、IP首部字段等多种模式识别数据流 [^13^][^34^]。识别出的流被映射至最多8个gate ID之一，每个gate ID对应一条独立的PSFP处理通道。8个gate ID的限制是TC4x PSFP实现的关键约束——在大型网络中，若并发流数量超过8条，软件需负责流聚合或分时分组处理。

#### 3.5.2 流门控：基于GCL的开关控制

流门控在FFP识别的流基础上施加时间维度的开关控制。每个gate ID对应一个独立的门控状态（Open/Closed），该状态可由专用GCL或全局TAS GCL共同驱动。当门控处于Closed状态时，属于该gate ID的所有帧被丢弃或标记为低优先级。流门控还支持每流最大SDU（Service Data Unit）长度检查，以及因超限或无效接收而强制关闭门控的选项 [^30^]。

#### 3.5.3 流量计：Police Counter令牌桶监管

流量计通过Police Counter（PC）实现双速率三色标记（RFC 2698）算法。PC为每个流维护两个令牌桶：CIR（Committed Information Rate，承诺信息速率）桶和EIR（Excess Information Rate，超额信息速率）桶。帧到达时，若CIR桶有足够令牌标记为Green（正常转发）；若CIR不足但EIR充足标记为Yellow（可转发但DEI位置位）；若两者皆不足标记为Red（丢弃）[^30^][^33^]。

**表3-3 PSFP三阶段流水线与TC4x硬件实现**

| 组件 | 标准功能 | TC4x实现方式 | GETH能力 | LETH能力 | 关键限制 |
|------|----------|-------------|----------|----------|----------|
| 流过滤器（FFP） | 识别数据流，映射gate ID | 硬件灵活帧解析器 [^13^] | 8 gate ID | 少于8 gate ID | 并发流数受限 |
| 流门控（Stream Gate） | Open/Close控制，SDU检查 | GCL驱动的硬件门控 | 完整支持 | 有限支持 | GCL需与TAS协调 |
| 流量计（PC） | 双速率三色标记（RFC 2698） | 硬件Police Counter [^33^] | CIR/EIR双桶 | 有限 | 令牌桶精度依赖时钟 |
| PSFP整体 | 入端口故障隔离 | 硬件+软件混合 [^30^] | Partial | Partial | 高级策略需软件辅助 |

表3-3展示了PSFP在TC4x上的混合实现架构。三个核心组件（FFP、Stream Gate、Flow Meter）均具备硬件加速，这是TC4x相较于纯软件PSFP方案的显著优势——每个数据包的过滤决策在纳秒级硬件流水线中完成，无需CPU介入。然而，"Partial"支持评级意味着部分高级PSFP特性（如复杂的流识别规则、动态门控策略）仍依赖软件层实现。8个gate ID的限制对汽车网络的实际影响需结合具体拓扑评估：在典型的区域控制器（Zone Controller）场景中，入端口通常仅需隔离3~5个关键流（如制动指令、转向信号、传感器融合数据），8个gate ID的容量基本满足需求。

### 3.6 IEEE 802.1CB — 帧复制与消除（FRER）

#### 3.6.1 R-TAG格式与序列号管理

IEEE 802.1CB通过帧复制与消除实现可靠性（Frame Replication and Elimination for Reliability, FRER），为不能容忍丢包的控制应用提供主动无缝冗余。FRER在发送端（Talker或Relay）为关键帧生成一个或多个副本，每个副本通过不同的冗余路径传输；在接收端（Listener或Relay），通过序列号识别并消除重复帧 [^13^][^30^]。

FRER使用R-TAG（Redundancy Tag）承载序列号信息。R-TAG共6字节：2字节Reserved（固定0x0000）、2字节Sequence Number（0~65535循环）、2字节Encapsulated Protocol（原始Ethertype）。R-TAG的Ethertype为0xF1C1，接收端通过该值识别FRER帧 [^50^]。序列号空间GenSeqSpace = 65536，每发送一帧递增1（模65536运算）。

#### 3.6.2 向量恢复与匹配恢复算法

TC4x支持两种序列恢复算法。向量恢复（Vector Recovery）算法维护一个序列历史位向量，记录最近接收的序列号集合。新到达帧的序列号若在历史窗口内且已被标记为接收，则判定为重复帧并丢弃；若不在窗口内或为首次接收，则更新向量并转发。向量恢复适用于批量流传输，其历史长度可通过frerSeqRcvyHistoryLength参数配置 [^50^][^138^]。

匹配恢复（Match Recovery）算法采用更简单的逐帧匹配策略：维护最近接收的序列号，新帧序列号与之比较，若相同则丢弃，不同则更新并转发。匹配恢复适用于间歇性流传输（逐帧发送模式），内存开销低于向量恢复 [^50^]。两种算法均配备定时器机制，在长时间无流量时自动重置恢复状态，避免 stale 状态导致的误判。

#### 3.6.3 Bridge-based MAC-to-MAC转发实现

**TC4x不提供专用FRER硬件加速器**，FRER功能通过软件实现， leveraging GETH硬件Bridge的MAC-to-MAC转发能力 [^13^][^30^]。软件栈负责R-TAG的插入/解析、序列号生成/恢复、以及冗余路径选择。硬件Bridge在两个GETH端口之间提供线速帧转发，消除CPU转发瓶颈。

FRER的软件实现架构分为发送路径和接收路径。发送路径中，应用层帧到达FRER模块后，序列号生成器分配递增序列号，R-TAG编码模块封装R-TAG，流分割（Stream Split）模块创建两份副本并通过不同端口送出。接收路径中，来自不同冗余路径的帧汇聚至流合并（Stream Merge）模块，序列号提取后进行向量或匹配恢复算法处理，首次到达的唯一帧被转发至上层，后续重复帧被静默丢弃。潜伏错误检测（Latent Error Detection）模块持续监控各路径的到达状态，若某路径长时间无帧到达则上报路径故障告警 [^50^]。

**表3-4 TSN协议完整支持矩阵：GETH vs LETH**

| IEEE标准 | 协议名称 | GETH支持 | LETH支持 | 实现方式 | 关键差异分析 |
|----------|----------|----------|----------|----------|-------------|
| 802.1AS-2020 | gPTP时间同步 | 完整支持 [^30^] | 完整支持 [^114^] | 硬件SFD时间戳 | GETH PPS输出更丰富 |
| 802.1Qav | 基于信用的整形器 | 8队列CBS [^111^] | 4队列CBS [^114^] | 硬件信用计数器 | GETH队列粒度更细 |
| 802.1Qbv | 时间感知整形器 | 1024条目GCL [^111^] | 有限条目GCL | 硬件EST引擎 | GETH调度复杂度更高 |
| 802.1Qbu | 帧抢占 | **支持** [^29^] | **不支持** [^30^] | pMAC/eMAC硬件 | **最关键差异** |
| 802.1Qci | PSFP过滤监管 | Partial [^13^] | Partial | FFP+PC硬件 | 均限8 gate ID |
| 802.1CB | FRER冗余 | 软件实现 [^30^] | 软件实现 | SW+HW Bridge | GETH Bridge加速转发 |

表3-4的六维对比揭示了TC4x TSN架构的核心设计哲学：GETH定位为高性能TSN中枢，承载严格确定性要求的时间关键流量；LETH定位为成本优化的边缘接入点，满足软实时和尽力而为通信需求。帧抢占（802.1Qbu）的有无是影响最大的单一因素——它决定了端口能否满足最严格的确定性延迟约束。对于要求ASIL-D等级的安全关键通信路径（如线控制动、线控转向），GETH是必选方案；而对于车身控制、环境传感器等低带宽、软实时场景，LETH的CBS+TAS组合已能提供足够的QoS保障。

FRER的软件实现方式虽然在吞吐率上不如专用硬件，但结合GETH Bridge的线速MAC-to-MAC转发能力，仍可为菊花链拓扑提供有效的1+1冗余保护 [^13^][^33^]。在典型的区域控制器互联场景中，TC4x通过XGMAC0和XGMAC1两个端口构建冗余路径，软件FRER模块管理序列号，硬件Bridge负责帧转发，32 KB发送FIFO吸收冗余事件期间的突发流量。这种软硬件协同方案在消除外部TSN交换机成本的同时，以适度的CPU开销换取了系统级可靠性。开发人员需重点关注FRER软件路径的延迟预算——序列生成与恢复的处理时间直接累加到端到端延迟中，在高频控制循环（如1 kHz周期）中需确保软件处理时间远小于周期时间。
