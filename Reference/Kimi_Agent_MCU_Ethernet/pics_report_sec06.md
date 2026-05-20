# 6. 802.1AB-2016 LLDP 协议分析与 PICS + MCU 实现映射

## 6.1 协议概述

IEEE Std 802.1AB-2016 定义了链路层发现协议（LLDP, Link Layer Discovery Protocol），其核心目标是为 IEEE 802 局域网提供标准化的物理拓扑发现（Physical Topology Discovery）机制[^1^]。协议允许连接到同一 LAN 的站点向相邻设备通告自身的能力（Capabilities）、管理地址以及接入点标识信息，所有分布式信息通过标准 MIB（Management Information Base）结构存储，可供网络管理系统（NMS）通过 SNMP 或等效接口访问[^2^]。该标准是对 802.1AB-2009 的修订版本，整合了 Cor 1-2013 和 Cor 2-2015 两份勘误，未引入新功能[^3^]。

LLDP 数据单元（LLDPDU）采用严格的 TLV（Type-Length-Value）顺序封装：Chassis ID TLV（Type=1）、Port ID TLV（Type=2）和 Time To Live TLV（Type=3）为强制前三个字段，其后可按任意顺序排列可选 TLV（Type 4–8, 127），并以 End of LLDPDU TLV（Type=0）结尾[^4^]。每个 TLV 头部包含 7-bit 类型字段和 9-bit 长度字段，信息字符串最大 511 字节[^5^]。协议还通过 Organizationally Specific TLV（Type=127）支持组织扩展，其中 IEEE 802.1 扩展定义于 802.1Q Annex D，IEEE 802.3 扩展定义于 802.3 Clause 79[^6^]。

LLDP-MED（Media Endpoint Discovery）是 TIA-1057 定义的组织特定扩展（OUI = 00-BB-C2），主要用于媒体终端设备的发现和能力通告，包括网络策略、位置标识和紧急呼叫等扩展 TLV[^7^]。IEEE 802.1AB-2016 本身不包含 LLDP-MED 的具体定义，仅提供扩展 TLV 承载机制。

在车载网络中，LLDP 的核心价值体现在三个方面：**拓扑自动发现**——通过 Chassis ID 和 Port ID TLV 自动识别 ECU 和交换机的物理连接关系；**设备自动识别**——通过 System Capabilities TLV 识别节点功能类型（Bridge 或 Station）；**诊断与故障定位**——通过 TTL 超时机制检测邻居设备离线，辅助网络连通性诊断[^8^]。车载 Zonal 架构中，区域控制器（Zonal Controller）通常作为 LLDP Agent 运行 Tx+Rx 模式，以支持双向拓扑发现[^9^]。

## 6.2 PICS + MCU 映射表

IEEE Std 802.1AB-2016 Annex A 提供了完整的 PICS proforma，以下从主要能力与选项（A.4）中提取核心条目，映射至三款车载 MCU（Infineon AURIX TC4x、NXP S32G、Renesas R-Car/RH850）的实现能力。所有 MCU 均通过软件协议栈支持 LLDP，无专用硬件加速[^10^]。

| 项目编号 | 功能名称 | 条款 | 状态 | TC4x | S32G | Renesas | 实现方式 | 备注 |
|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|
| **addr/3** | SA = 站点 MAC 地址 | 7.2 | M | ✓ | ✓ | ✓ | SW | 源地址必须使用端口 MAC[^11^] |
| **addr/4** | LLDP EtherType = 0x88CC | 7.3 | M | ✓ | ✓ | ✓ | SW | EtherType 编码强制[^12^] |
| **addr/14** | End Station: DA = Nearest Bridge | 7.1 | M | ✓ | ✓ | ✓ | SW | 车载终端节点强制使用 01-80-C2-00-00-0E[^13^] |
| **addr/15** | End Station: DA = Nearest non-TPMR | 7.1 | O | — | — | — | SW | 车载场景通常不需要[^14^] |
| **lldpdu** | LLDPDU 封装 TLV 顺序规范 | 7.3, 8.2 | M | ✓ | ✓ | ✓ | SW | Chassis ID → Port ID → TTL 顺序[^15^] |
| **tlvfmt** | 基本 TLV 格式 | 8.4 | M | ✓ | ✓ | ✓ | SW | 7-bit Type + 9-bit Length[^16^] |
| **basictlv/1** | End Of LLDPDU TLV | 8.5.1 | O | ✓ | ✓ | ✓ | SW | 可选，推荐实现以明确帧边界[^17^] |
| **basictlv/2** | Chassis ID TLV | 8.5.2 | M | ✓ | ✓ | ✓ | SW | 强制第一个 TLV；子类型推荐 MAC(4)或 Local(7)[^18^] |
| **basictlv/3** | Port ID TLV | 8.5.3 | M | ✓ | ✓ | ✓ | SW | 强制第二个 TLV；子类型推荐 Local(7)[^19^] |
| **basictlv/4** | Time To Live TLV | 8.5.4 | M | ✓ | ✓ | ✓ | SW | 强制第三个 TLV；TTL = msgTxInterval × msgTxHold[^20^] |
| **basictlv/5** | Port Description TLV | 8.5.5 | M | ✓ | ✓ | ✓ | SW | 强制实现能力，传输可选[^21^] |
| **basictlv/6** | System Name TLV | 8.5.6 | M | ✓ | ✓ | ✓ | SW | 强制实现能力，传输可选[^22^] |
| **basictlv/7** | System Description TLV | 8.5.7 | M | ✓ | ✓ | ✓ | SW | 强制实现能力，传输可选[^23^] |
| **basictlv/8** | System Capabilities TLV | 8.5.8 | M | ✓ | ✓ | ✓ | SW | 强制实现能力；Station Only(bit 8)或 Bridge(bit 3)[^24^] |
| **basictlv/9** | Management Address TLV | 8.5.9 | M | ✓ | ✓ | ✓ | SW | 强制实现能力，传输可选；推荐车载使能[^25^] |
| **xtlvfmt** | Organizationally Specific TLV | 8.6 | O | ✓ | ✓ | ✓ | SW | 扩展 TLV 支持；需 OUI + Subtype[^26^] |
| **optxrx/1** | Tx + Rx 操作模式 | 6.1 | O.1 | ✓ | ✓ | ✓ | SW | **车载推荐模式**——双向拓扑发现[^27^] |
| **optxrx/2** | Tx Only 操作模式 | 6.1 | O.1 | ✓ | ✓ | ✓ | SW | 简单终端设备适用[^28^] |
| **optxrx/3** | Rx Only 操作模式 | 6.1 | O.1 | ✓ | ✓ | ✓ | SW | 被动监控场景适用[^29^] |
| **txsm** | 发送状态机（Transmit SM） | 9.2.8 | M(Tx) | ✓ | ✓ | ✓ | SW | 含正常/Shutdown LLDPDU 构造[^30^] |
| **rxsm** | 接收状态机（Receive SM） | 9.2.9 | M(Rx) | ✓ | ✓ | ✓ | SW | 帧验证、邻居信息表更新[^31^] |
| **txtsm** | 发送定时器状态机 | 9.2.10 | M(Tx) | ✓ | ✓ | ✓ | SW | msgTxInterval 默认 30s，msgTxHold 默认 4[^32^] |
| **tlvtxenable** | 按端口 TLV 传输使能配置 | 5.3 l) | M(Tx) | ✓ | ✓ | ✓ | SW | 强制支持按端口使能/禁用可选 TLV[^33^] |
| **tlvtx/portdesc** | Port Description TLV 传输使能 | 10.2.2 | O | ✓ | ✓ | ✓ | SW | 推荐车载使能——便于端口识别[^34^] |
| **tlvtx/syscaps** | System Capabilities TLV 传输使能 | 10.2.2 | O | ✓ | ✓ | ✓ | SW | **强烈推荐**——标识 Bridge/Station 类型[^35^] |
| **tlvtx/mgmtaddr** | Management Address TLV 传输使能 | 10.2.2 | O | ✓ | ✓ | ✓ | SW | 推荐车载使能——支持管理访问[^36^] |
| **ieee8021_tlv** | IEEE 802.1 Organizationally Specific TLVs | 802.1Q D | O | Δ | Δ | Δ | SW | DCBX/EVB 扩展；TC4x 需额外集成[^37^] |
| **ieee8023_tlv** | IEEE 802.3 Organizationally Specific TLVs | 802.3 79 | O | Δ | Δ | Δ | SW | MAC/PHY 配置状态；取决于 SDK 版本[^38^] |
| **lldp_med_tlv** | LLDP-MED TLVs (TIA-1057) | 外部 | O | — | — | — | SW | 车载场景通常不需要；面向 IP 电话/媒体终端[^39^] |
| **lldpLocSysGroup** | 本地系统信息 MIB 对象组 | 11.5 | M | ✓ | ✓ | ✓ | SW | 本地 Chassis/Port 信息存储[^40^] |
| **lldpRemSysGroup** | 远程系统信息 MIB 对象组 | 11.5 | M(Rx) | ✓ | ✓ | ✓ | SW | 邻居信息表；按端口存储远程 TLV[^41^] |

上表共列出 30 项 PICS 条目，覆盖地址与 EtherType 编码（addr）、LLDPDU 封装与基本 TLV（basictlv）、操作模式（optxrx）、状态机（txsm/rxsm/txtsm）、TLV 传输管理（tlvtxenable/tlvtx）以及 MIB 对象组（lldpLocSysGroup/lldpRemSysGroup）六大类别。三款 MCU 在所有核心条目上均标记为支持（✓），这源于 LLDP 的纯软件实现特性：协议不依赖硬件加速，仅需以太网 MAC 层提供基本的帧收发能力[^42^]。对于 IEEE 802.1/802.3 组织特定 TLV（标记为 Δ），支持程度取决于 SDK/软件栈的版本和配置，通常需要通过第三方协议栈（如 lldpd 开源实现或 AUTOSAR EthTSyn 模块）集成扩展功能[^43^]。LLDP-MED TLV 在车载场景中标记为不支持（—），因为 TIA-1057 面向 IP 电话和会议室媒体终端，与车载 Zonal 网络的功能需求不匹配[^44^]。

## 6.3 技术分析

### 6.3.1 LLDP 的软件实现特性

LLDP 协议本质上是一个轻量级的数据链路层管理协议，其全部功能可通过软件在 MCU 上实现，无需专用硬件加速[^45^]。从技术架构角度分析，LLDP Agent 由三个核心状态机构成：发送状态机（Transmit State Machine）负责 LLDPDU 的构造和发送，包括正常 LLDPDU 和 TTL=0 的 Shutdown LLDPDU；接收状态机（Receive State Machine）处理接收帧的验证、解析和远程系统 MIB 更新；发送定时器状态机（Transmit Timer State Machine）管理基于信用的传输策略和新邻居检测后的快速发送序列[^46^]。这三个状态机的逻辑复杂度较低，核心代码量通常在数百行 C 代码量级，适合集成到 AUTOSAR EthTSyn 模块或作为独立服务运行[^47^]。

资源消耗方面，LLDP 对 MCU 的内存占用极低：本地 MIB 仅需维护 Chassis ID、Port ID、System Capabilities 等固定长度的本地属性；远程 MIB 的存储需求与端口数量和邻居数量成正比，在车载 Zonal 架构中每个区域控制器通常连接 4–16 个下行端口，按每端口 1–2 个邻居计算，邻居表总条目数不超过 32 项[^48^]。以每项邻居信息约 200 字节估算，远程 MIB 总占用约 6–8 KB RAM，对 TC4x（最高 16 MB SRAM）、S32G（最高 8 MB SRAM）和 Renesas R-Car S4（最高 8 MB SRAM）均可忽略不计[^49^]。CPU 占用方面，LLDP 状态机由定时器驱动，正常发送间隔 30 秒的周期性处理几乎不占用 CPU 带宽，仅在链路状态变化（新邻居加入/现有邻居 TTL 超时）时触发额外处理[^50^]。

### 6.3.2 车载场景中的 LLDP 价值

在车载 Zonal 以太网架构中，LLDP 的价值远超传统企业网络的"资产发现"功能。首先，**拓扑自动发现**是车辆下线检测和产线配置的核心使能技术：每个 Zonal Controller 通过 LLDP 收集邻居的 Chassis ID 和 Port ID，构建完整的网络邻接矩阵，与预配置的 golden topology 比对以验证装配正确性[^51^]。其次，**设备身份识别**通过 System Capabilities TLV 实现：Zonal Controller 通告 Bridge 能力（bit 3），终端 ECU 通告 Station Only 能力（bit 8），使网络管理系统能够快速识别节点功能角色[^52^]。第三，**故障定位**利用 TTL 超时机制实现被动式链路监控——当邻居设备在 TTL 到期（默认 30s × 4 = 120s）前未发送 LLDPDU 更新时，接收状态机自动将该邻居标记为过期并从远程 MIB 中删除，触发 RemTablesChange 通知[^53^]。

### 6.3.3 与 TSN 协议共存的注意事项

LLDP 与车载 TSN 协议栈的共存需要从协议标识、门控调度和资源优先级三个维度分析。协议标识层面，LLDP 使用 EtherType 0x88CC，与 gPTP（0x88F7）、AVTP（0x22F0）等 TSN 协议使用不同的 EtherType，MAC 层可直接区分，无帧解析冲突[^54^]。门控调度层面，IEEE 802.1Qbv 时间感知整形器（TAS）需要根据 LLDP 帧的传输特性配置适当的门控窗口：LLDPDU 长度通常不超过 200 字节（含三个强制 TLV 和少量可选 TLV），在 100 Mbit/s 链路中传输时间约 16 μs（含前导码和 IFG），在 1 Gbit/s 链路中约 1.6 μs，门控窗口分配应预留至少 50 μs 以确保可靠性[^55^]。资源优先级层面，LLDP 属于网络管理流量，建议在 Qbv 门控列表中分配独立的低优先级队列（如优先级 1），与 gPTP（优先级 7，时间关键）和音视频流量（优先级 5–6，高带宽）隔离[^56^]。此外，LLDP 帧的目的地址 01-80-C2-00-00-0E（Nearest Bridge）被所有桥接设备拦截，不会泛洪到整个网络，这天然限制了 LLDP 流量的传播范围，降低了带宽占用[^57^]。

## 6.4 设计建议

### 6.4.1 区域控制器的 LLDP 配置建议

对于车载 Zonal Controller 的 LLDP 实现，推荐采用以下配置策略。**操作模式**应统一选择 Tx+Rx（收发双向），以确保每个节点既能通告自身信息又能发现邻居设备，这是构建完整物理拓扑的必要条件[^58^]。**目的地地址**使用 Nearest Bridge（01-80-C2-00-00-0E），该地址被所有桥接设备拦截，传播范围限制在单条物理链路，避免了 LLDP 帧在网络中的不必要的泛洪[^59^]。

**定时器参数**建议保持标准默认值：msgTxInterval = 30s、msgTxHold = 4，对应 TTL = 120s。此配置在拓扑变化检测灵敏度（120s 内发现邻居离线）和网络开销（每 30s 一个 LLDPDU，约 200 字节）之间取得了合理平衡[^60^]。如需更快的故障检测，可将 msgTxInterval 缩短至 5s（TTL = 20s），但应评估对 Qbv 门控调度的影响。**Chassis ID 子类型**推荐选用 MAC address（subtype=4），利用以太网端口的 48-bit MAC 地址作为唯一设备标识符，避免本地分配方案可能导致的命名冲突[^61^]。

### 6.4.2 必选与可选 TLV 裁剪策略

车载 LLDP 实现应在满足标准强制要求的前提下，根据功能需求裁剪可选 TLV 传输集合。强制 TLV（Chassis ID、Port ID、TTL）必须始终包含在发送的 LLDPDU 中，且顺序不可变更[^62^]。可选 TLV 的使能策略建议如下：

**强烈推荐使能**的 TLV 包括：System Capabilities（标识 Bridge/Station 角色，网络管理必需）、Management Address（提供设备管理地址，远程诊断必需）、Port Description（便于运维识别物理端口用途）[^63^]。**条件性使能**的 TLV 包括：IEEE 802.1 Organizationally Specific TLV（如需支持 DCBX 或 EVB 功能）、IEEE 802.3 Organizationally Specific TLV（如需通告 MAC/PHY 配置状态）[^64^]。**不建议使能**的 TLV 包括：LLDP-MED 扩展（面向 IP 电话/媒体终端，车载场景无功能价值）、System Name 和 System Description（车载设备通常通过 Chassis ID + 管理地址标识，这两项冗余）[^65^]。

TLV 传输使能应支持按端口独立配置：Zonal Controller 的上行端口（连接到中央计算单元）应使能完整的可选 TLV 集，以支持全面的拓扑管理；下行端口（连接传感器/执行器）可仅使能强制 TLV 和 System Capabilities，降低网络开销[^66^]。这种分层裁剪策略将 LLDPDU 大小控制在 100–150 字节（下行端口）或 150–250 字节（上行端口），在 100 Mbit/s 链路中占用的带宽分别约为 0.005% 和 0.008%，对实时流量调度影响可忽略[^67^]。

对于 MIB 存储方案，考虑到车载 MCU 通常不运行完整的 SNMP Agent，建议采用等效存储（equivalent storage）方案——即提供与 SNMP MIB 结构等效的数据存储和检索接口，供车载诊断协议（如 DoIP / UDS over Ethernet）或车辆管理平台直接访问[^68^]。lldpLocSysGroup 和 lldpRemSysGroup 是必须实现的核心 MIB 对象组，前者存储本地 Chassis/Port 信息，后者维护邻居信息表[^69^]。等效存储方案应避免动态内存分配，采用静态数组预分配邻居表条目（按最大端口数 × 每端口邻居数），以满足车载功能安全（ASIL）对内存确定性的要求[^70^]。
