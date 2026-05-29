# Ethernet IP PICS Analysis Summary

> **项目**: Ethernet IP (IP_20260502_001)
> **阶段**: PAD → IDR Transition
> **日期**: 2026-05-21
> **来源**: Reference/Kimi_Agent_MCU_Ethernet/PICS/ 复制并分析
> **方法**: Deep-Research-Cluster Route D (File-Augmented)
> **应用场景**: 车载MCU区域控制器（Zonal Controller）含Switch功能

---

## 1. PICS 文件清单

| 协议标准 | PICS文件名 | 标准Annex | 条目数 |
|---------|-----------|----------|--------|
| IEEE 802.1AS-2020 | `PICS_802.1AS-2020_gPTP.md` | Annex A (原生) | 11 Major Capabilities + 子条目 |
| IEEE 802.1Q-2022 | `PICS_802.1Q-2022_TSN.md` | Annex A (原生) | 10 Major Capabilities + 子条目 |
| IEEE 802.3-2022 | `PICS_802.3-2022_Ethernet.md` | Annex A (原生) | 5 PHY类型 + 通用条目 |
| IEEE 802.1CB-2017 | `PICS_802.1CB-2017_FRER.md` | Annex A (原生) | 7 Sections (BG/IS/TE/LE/RS/CB/COM) |
| IEEE 802.1AE-2018 | `PICS_802.1AE-2018_MACsec.md` | Annex A (原生) | 9 Major Capabilities + SAP/STAT/GEN/VER/FMT |
| IEEE 802.1AB-2016 | `PICS_802.1AB-2016_LLDP.md` | Annex A (原生) | 9 Sections |
| IEEE 1588-2019 | `PICS_IEEE-1588-2019_PTP.md` | 自创 (Clause 20+条款提取) | 14 Categories |
| **IEEE 1722-2016** | **`IEEE_1722_AVTP_PICS.md`** | **自创 (Clause 4~9 提取 + 车载扩展)** | **12 Major Capabilities + 子条目** |

---

## 2. 逐协议 PICS 支持矩阵 (Yes/No/N/A)

### 2.1 IEEE 802.1AS-2020 gPTP — Zonal Controller with Switch

| Major Capability | 状态 | 支持值 | 说明 | 影响分析 (若 No) |
|-----------------|:----:|:------:|------|-----------------|
| **DOM0** — domainNumber 0 (车载默认域) | M | **Yes** | 车载骨干网默认域 | 无法参与骨干网gPTP同步 |
| **DOMADD** — 附加domain支持 | O | **Yes** | 支持多域(如媒体域/控制域分离) | 仅单域运行，域间隔离需其他机制 |
| **MINTA** — 介质无关时间同步 | M | **Yes** | 支持任意介质的时间同步 | 必须支持，用于车载多PHY环境 |
| **BMC** — Best Master Clock算法 | M | **Yes** | 自动GM选择 | 无法自动选择最优时钟源 |
| **SIG** — Signaling消息处理 | O | **Yes** | 消息间隔协商等 | 不支持Signaling协商，使用固定参数 |
| **GMCAP** — Grandmaster能力 | O | **Yes** | 可作为Grandmaster | 仅作Slave/Bridge，不能作为时间源 |
| **BRDG** — Bridge(边界时钟) | **M** | **Yes** | Zonal Controller含Switch必须支持 | 不能桥接gPTP域，丧失Zonal核心功能 |
| **MIMSTR** — 介质无关Master | M | **Yes** | Master端口介质无关 | 必须支持 |
| **MIPERF** — 介质无关性能 | O | **No** | 高精度性能指标 | 无法声明精确同步性能等级 |
| **EXT** — 扩展功能(如帧计数) | O | **Yes** | 帧计数/路径跟踪等 | 缺少诊断能力 |
| **MDFDPP** — 多域帧延迟/路径/协议 | O | **No** | 多域延迟测量与协议 | 多域场景下延迟测量不完整 |

**802.1AS 关键子条目分析**:

| 子条目 | 状态 | 支持值 | 影响分析 |
|-------|:----:|:------:|---------|
| ANC — Announce消息 | M | Yes | 基础功能 |
| SYN — Sync消息 (One-Step/Two-Step) | M | Yes | Two-Step为主，One-Step可选 |
| DEL — Pdelay机制 | M | Yes | 802.1AS核心机制 |
| PMC — 端口测量计数器 | O | Yes | 诊断支持 |
| TDS — 时间分发服务 | O | Yes | 时间分发 |
| UMM — 单播媒体独立模式 | O | **No** | 车载场景以组播为主，影响较小 |
| RLY — Relay(桥接转发) | BRDG:M | Yes | Bridge必须 |
| PTP-802.3/Ethernet传输映射 | M | Yes | 车载以太网主要映射 |

---

### 2.2 IEEE 802.1Q-2022 TSN — Major Capabilities

| Major Capability | 状态 | 支持值 | 说明 | 影响分析 (若 No) |
|-----------------|:----:|:------:|------|-----------------|
| **FQTSS** — 转发和排队时间敏感流 | O.1 | **Yes** | TSN基础转发能力 | 无法支持TSN流转发 |
| **SRP** — Stream Reservation Protocol | O.2 | **No** | 流预留协议(MSRP) | 无法动态预留带宽，需静态配置或CBS替代 |
| **PFC** — Priority-based Flow Control (802.3bd) | O.2 | **No** | 基于优先级的流控 | 无损以太网场景不支持，拥塞时可能丢帧 |
| **ETS** — Enhanced Transmission Selection (802.1Qaz) | O.2 | **Yes** | 增强传输选择 | 带宽分配能力 |
| **SCHED** — Scheduled Traffic (802.1Qbv/TAS) | O.2 | **Yes** | 时间感知整形器 | 确定性调度核心功能 |
| **PRE** — Frame Preemption (802.1Qbu/802.3br) | O.2 | **Yes** | 帧抢占 | 低延迟关键帧传输 |
| **PSFP** — Per-Stream Filtering and Policing (802.1Qci) | O.2 | **Yes** | 流过滤和管制 | 网络安全和流隔离 |
| **ATS** — Asynchronous Traffic Shaper (802.1Qcr) | O.2 | **No** | 异步流量整形 | 高突发流量场景无平滑能力 |
| **CQF** — Cyclic Queuing and Forwarding (802.1Qch) | O.2 | **No** | 循环排队转发 | 简单TSN调度替代方案不可用 |
| **PCR** — Packet Replication and Elimination (802.1CB) | O.2 | **Yes** | 帧复制消除 | 冗余可靠性 |

**关键决策说明**:

| Feature | 决策 | 理由 |
|---------|:----:|------|
| SRP | **No** | 车载场景通常使用静态TSN配置(SMD/SMC文件)，动态SRP开销大且不符合确定性要求 |
| PFC | **No** | 车载以太网以有限带宽和可控拓扑为主，PFC的全停特性可能导致 Head-of-Line Blocking；优先使用CBS+TAS的确定性方案 |
| ATS | **No** | 资源受限MCU场景，ATS软件复杂度高；如需平滑突发，可用CBS或静态门控替代 |
| CQF | **No** | TAS(SCHED)已覆盖确定性调度需求，CQF作为简化替代无需重复支持 |

---

### 2.3 IEEE 802.3-2022 Ethernet PHY

| PHY类型 | 状态 | 支持值 | 车载适用性 | 影响分析 |
|---------|:----:|:------:|:---------:|---------|
| **100BASE-T1** (IEEE 802.3bw-2015) | O | **Yes** | 高 | 车载百兆骨干/传感器 |
| **1000BASE-T1** (IEEE 802.3bp-2016) | O | **Yes** | 高 | 车载千兆骨干 |
| **10BASE-T1S** (IEEE 802.3cg-2019) | O | **Yes** | 中 | 低成本传感器总线(PLCA) |
| **2.5GBASE-T1/5GBASE-T1/10GBASE-T1** (802.3ch/cu/cv) | O | **Yes** | 中 | ADAS高带宽/骨干网 |
| **PLCA** (Physical Layer Collision Avoidance) | O | **Yes** | 中 | 10BASE-T1S多点总线仲裁 |
| **EEE** (802.3az Energy Efficient Ethernet) | O | **No** | 低 | 车载场景对功耗管理需求不同于数据中心 |

**PHY 子条目关键分析**:

| 条目 | 状态 | 支持值 | 说明 |
|-----|:----:|:------:|------|
| PCS (物理编码子层) | M | Yes | 所有PHY必须 |
| PMA (物理介质附加子层) | M | Yes | 所有PHY必须 |
| AN (Auto-Negotiation) | O | Yes | 链路自协商 |
| MDIO管理接口 | M | Yes | PHY寄存器访问 |

---

### 2.4 IEEE 802.1CB-2017 FRER

| Capability | 状态 | 支持值 | 说明 | 影响分析 |
|-----------|:----:|:------:|------|---------|
| **BG** — C-component Bridge | O | **Yes** | FRER集成Bridge | 支持冗余流桥接 |
| **IS** — Stream Identification | O.1 | **Yes** | 流识别(Null/Active MAC+VLAN/IP) | 冗余流识别基础 |
| **TE** — Talker End System | O.1 | **Yes** | 帧复制+序列生成 | 发送端冗余 |
| **LE** — Listener End System | O.1 | **Yes** | 帧消除+序列恢复 | 接收端冗余 |
| **RS** — Relay System | BG:M+O.1 | **Yes** | 中继节点处理 | Bridge转发冗余流 |
| COM3 — Latent Error Detection | LE+RS:M | N/A | 潜在错误检测 | 需要软件配合实现 |
| COM8 — 650M+链路64位计数器 | M | N/A | 高速链路统计 | 车载<10G场景适用 |

**FRER 关键功能支持**:

| 功能 | 支持值 | 说明 |
|-----|:------:|------|
| Sequence Generation (R-TAG) | Yes | 发送端序列号注入 |
| Sequence Recovery (Match/Vector) | Yes | 接收端重复帧消除 |
| Stream Splitting (复制) | Yes | 多路径冗余发送 |
| HSR/PRP兼容标签 | No | 工业以太网冗余，车载场景不使用HSR/PRP |
| IP Stream Identification | No | 车载场景使用L2 MAC+VLAN识别 |
| Autoconfiguration | No | 静态配置为主 |

---

### 2.5 IEEE 802.1AE-2018 MACsec

| Major Capability | 状态 | 支持值 | 说明 | 影响分析 |
|-----------------|:----:|:------:|------|---------|
| **SAP** — SecY端口架构 | M | **Yes** | Controlled/Uncontrolled/Common Port | 基础架构 |
| **STAT** — MAC状态与点对点参数 | M | **Yes** | MAC操作状态同步 | 状态管理 |
| **GEN** — 安全帧生成 | M | **Yes** | 加密+SecTAG+ICV生成 | 发送端安全处理 |
| **VER** — 安全帧验证 | M | **Yes** | 解密+ICV验证+重放保护 | 接收端安全处理 |
| **FMT** — MACsec PDU编解码 | M | **Yes** | SecTAG格式+版本+标志位 | PDU格式 |
| **SCI** — SCI标识 | M | **Yes** | 48-bit MAC+16-bit Port ID | 通道标识 |
| **PERF** — 性能要求 | M | **Yes** | Table 10-3要求 | 性能合规 |
| **KAY** — 密钥协商接口 | M | **Yes** | MKA/802.1X-2020 LMI | 密钥管理接口 |
| **MGT** — 管理功能 | M | **Yes** | 10.7管理对象 | 配置管理 |
| **CS** — Cipher Suite使用 | M | **Yes** | GCM-AES-128/256 | 加密套件 |
| **CSI** — 默认套件完整性 | M | **Yes** | GCM-AES-128 ICV | 完整性保护 |
| **CSC** — 默认套件机密性 | ¬CSO:O/CSO:M | **Yes** | GCM-AES-128加密 | 机密性保护 |
| **CSO** — 带offset机密性 | O | **Yes** | partial encryption | 部分加密优化 |
| **MSC** — 多receive SC | O | **No** | 多接收安全通道 | 单SC设计简化 |
| **MSAK** — 多receive SAK | O | **No** | 多接收SAK | 2个SAK足够 |
| **TC** — 多transmit SC | O | **No** | 多发送安全通道 | 单SC设计简化 |
| **MIB** — SNMPv3 MIB | O | **No** | 网络管理 | 车载不用SNMP |
| **FULL** — Full Conformance | O | **Yes** | 完整一致性声明 | 合规声明 |

**MACsec 关键实现决策**:

| 决策项 | 值 | 理由 |
|---------|:--:|------|
| 多SC支持 (MSC/TC) | No | 车载点对点链路为主，单SC+2 SAK满足需求，简化硬件 |
| 非标准Cipher Suite (CSX) | No (X) | 禁止，仅用标准GCM-AES-128/256 |
| SNMP管理 (MIB) | No | 车载使用寄存器/UDS诊断，非SNMP |
| 旧版SNMP (SNMX) | No (X) | 禁止 |

---

### 2.6 IEEE 802.1AB-2016 LLDP

| Capability | 状态 | 支持值 | 说明 | 影响分析 |
|-----------|:----:|:------:|------|---------|
| **cntrlport** — 802.1X受控端口LLDP | M | **Yes/N/A** | 安全端口LLDP | 如启用802.1X则必须 |
| **uncntrlport** — 非受控端口LLDP | O | **Yes** | 标准LLDP交换 | 拓扑发现基础 |
| **addr** — 寻址能力 | — | — | DA/SA/EtherType | — |
| **addr/3** — SA=站点MAC | M | **Yes** | 源地址规范 | 必须 |
| **addr/4** — LLDP EtherType=0x88CC | M | **Yes** | EtherType固定值 | 必须 |
| **addr/5** — C-VLAN Bridge DA | M | **N/A** | 本IP非纯Bridge | 不适用(作为Switch) |
| **basictlv** — 基本管理TLV集 | — | — | Chassis/Port/TTL等 | — |
| **basictlv/2** — Chassis ID TLV | M | **Yes** | 第一个TLV | 必须 |
| **basictlv/3** — Port ID TLV | M | **Yes** | 第二个TLV | 必须 |
| **basictlv/4** — Time To Live TLV | M | **Yes** | 第三个TLV | 必须 |
| **optxrx** — 操作模式 | O.1 | **Yes (optxrx/1)** | Tx+Rx模式 | 收发全功能 |
| **mib** — 数据存储 | O.2 | **Yes (mib/2)** | 非SNMP等效存储 | 车载环境不用SNMP |
| **equivstor** — 等效存储 | M(nomib) | **Yes** | 功能等效存储 | 必须 |

**LLDP 实现范围**:

| Feature | 支持值 | 说明 |
|---------|:------:|------|
| 基本TLV发送/接收 | Yes | Chassis/Port/TTL/Port Desc/System Name/Desc/Capabilities/Mgmt Addr |
| Organization Specific TLV | No | 车载场景不使用组织特定TLV |
| SNMP MIB访问 | No | 使用寄存器直接访问替代 |
| 发送定时器/状态机 | Yes | 标准状态机实现 |
| 邻居信息表 | Yes | 本地MIB存储邻居信息 |

---

### 2.7 IEEE 1588-2019 PTP

| Category | 关键条目 | 状态 | 支持值 | 说明 | 影响分析 |
|---------|---------|:----:|:------:|------|---------|
| **基础** | PTP-BASE-01 (PTPv2.1) | M | **Yes** | 版本支持 | 必须 |
| **基础** | PTP-BASE-04 (sdoId) | M | **Yes** | Profile隔离 | 2019版新增，多Profile共存 |
| **时钟** | PTP-CLK-01 (OC) | C | **Yes** | Ordinary Clock | 端节点/传感器 |
| **时钟** | PTP-CLK-02 (BC) | O | **Yes** | Boundary Clock | Zonal Controller桥接 |
| **时钟** | PTP-CLK-03 (TC-E2E) | O | **No** | E2E Transparent Clock | 802.1AS无TC概念，不适用 |
| **时钟** | PTP-CLK-04 (TC-P2P) | O | **Yes** | P2P Transparent Clock | Switch端口residence time |
| **延迟** | PTP-DLY-01 (E2E) | C | **No** | Delay Req-Resp | 802.1AS使用P2P，不实现E2E |
| **延迟** | PTP-DLY-02 (P2P) | C | **Yes** | Peer-to-Peer | 802.1AS核心机制 |
| **时间戳** | PTP-TS-01 (One-Step) | O | **Yes** | 一步法 | 高精度硬件支持 |
| **时间戳** | PTP-TS-02 (Two-Step) | O | **Yes** | 两步法 | 软件友好 |
| **时间戳** | PTP-TS-05 (硬件时间戳) | O | **Yes** | 硬件时间戳 | 高精度实现必选 |
| **BMCA** | PTP-BMCA-01 (默认BMCA) | M | **Yes** | 标准数据集比较 | 必须 |
| **BMCA** | PTP-BMCA-02 (替代BMCA) | O | **No** | Profile指定替代 | 802.1AS使用简化BMCA |
| **消息** | PTP-MSG-01 (Sync) | M | **Yes** | 核心同步消息 | 必须 |
| **消息** | PTP-MSG-03 (Signaling) | C | **Yes** | 信令消息 | 消息间隔协商 |
| **消息** | PTP-MSG-04 (Management) | O | **No** | PTP管理协议 | 车载使用UDS/诊断替代 |
| **数据集** | PTP-DS-01~05 | M/C | **Yes** | defaultDS/currentDS/parentDS/timePropertiesDS/portDS | 完整数据集 |
| **Profile** | PTP-PRF-02 (P2P Profile) | C | **Yes** | 默认P2P Profile | 802.1AS基础 |
| **传输** | PTP-TRN-03 (802.3/Ethernet) | C | **Yes** | Ethernet映射 | 车载主要映射 |
| **传输** | PTP-TRN-01 (IPv4/UDP) | C | **No** | IP/UDP映射 | 车载L2直接映射为主 |
| **安全** | PTP-OPT-13 (AUTH TLV) | O | **No** | 认证安全 | MACsec替代 |
| **L1Sync** | PTP-L1-01~07 | C | **No** | L1层同步 | 车载以太网PHY不支持SyncE |

**1588 vs 802.1AS 实现策略**:

| 功能 | 1588-2019 | 802.1AS-2020 | 本IP实现 |
|-----|:---------:|:------------:|:--------:|
| 延迟机制 | E2E + P2P | P2P only | **P2P only** |
| 时钟类型 | OC/BC/TC | OC/BC | **OC + BC** |
| BMCA | 完整 | 简化 | **简化BMCA** (802.1AS风格) |
| TC概念 | 有E2E TC/P2P TC | 无TC概念 | **P2P TC** (Switch端口residence time) |
| Profile | 多Profile可选 | 单一 automotive Profile | **802.1AS Profile** |
| 传输映射 | IPv4/IPv6/802.3 | 802.3 only | **802.3 only** |
| 单播 | 可选 | 不支持 | **不支持** |

---

### 2.8 IEEE 1722-2016 AVTP — Zonal Controller AVTP Awareness

| Major Capability | 状态 | 支持值 | 说明 | 影响分析 (若 No) |
|-----------------|:----:|:------:|------|-----------------|
| **TK** — Talker 端系统 (AVTP 流发送) | O.1 | **Yes** | 车载 ECU 作为 AVTP Talker | 无法发送 AVTP 流 (ADAS 视频/时钟) |
| **LS** — Listener 端系统 (AVTP 流接收) | O.1 | **Yes** | 车载 ECU 作为 AVTP Listener | 无法接收 AVTP 流 |
| **SW** — Switch AVTP 感知 | O.1 | **Yes** | **Zonal Controller 必须支持** | 无法识别和转发 AVTP 流 |
| **SID** — Stream ID / DA 映射 | TK+LS+SW: M | **Yes** | Stream 识别与路由基础 | 无法按流识别转发 |
| **TS** — 时间戳生成与解析 | TK+LS: M | **Yes** | gPTP 同步时间戳 | 无法时间同步播放 |
| **PM** — TSN 优先级映射 | SW: M | **Yes** | AVTP 流 → QoS 队列 | 无法确定性调度 AVTP |
| **ACF** — ACF (CAN/LIN 封装) | O | **Yes** | 车载控制数据隧道 | 无 CAN over Ethernet 能力 |
| **ACM** — ACF CAN Multiple | ACF: O | **Yes** | 多 CAN 帧聚合 | 单帧效率低 |
| **ACB** — ACF CAN Brief | ACF: O | **Yes** | 精简 CAN 封装 | 开销较大 |
| **CTL** — IEEE 1722.1 AVDECC | O | **No** | 软件层控制协议 | 硬件不实现控制面 |
| **SRF** — Stream Reservation 失败处理 | SW: M | **Yes** | 未预留流丢弃/转发 | 网络拥塞风险 |

**AVTP 关键子条目分析**:

| 子条目 | 状态 | 支持值 | 影响分析 |
|-------|:----:|:------:|---------|
| TK-1~16 — Talker 帧生成 | TK: M/O | Yes | RVF/CRF 硬件发送 |
| LS-1~8 — Listener 帧解析 | LS: M/O | Yes | Stream ID 匹配、序列号检查 |
| SID-1~8 — Stream ID 映射 | SW: M/O | Yes | 32+ 条目 SRAM 查表 |
| TS-TK/LS — 时间戳格式 | TK+LS: M | Yes | 32-bit sec + 32-bit ns，gPTP 基准 |
| PM-1~12 — TSN 优先级映射 | SW: M/O | Yes | SR Class A/B + CBS + TAS |
| PM-TAS-1~6 — 门控协同 | PM-TAS: M/O | Yes | Switch 级 TAS GCL |
| ACF-1~9 — ACF CAN 桥接 | ACF: M/O | Yes | CAN/CAN-Multiple/CAN-Brief |

**AVTP 关键实现决策**:

| 决策项 | 值 | 理由 |
|---------|:--:|------|
| AAF (Audio Format) | No | 硬件不直接处理音频，软件后处理 |
| CVF (Compressed Video) | No | 压缩视频由软件编解码器处理 |
| IIDC/VSF | No | 车载场景不使用 |
| ACF LIN | No | LIN 场景较少，CAN 已覆盖 |
| IEEE 1722.1 AVDECC 完整栈 | No | 软件层实现 (控制面) |
| SRP 动态预留 | No | 静态配置替代 (与 802.1Q SRP=No 一致) |
| IP 层 AVTP 传输 | No | 车载 L2 直接传输 |

**AVTP 时间戳映射策略**:

| 时间戳类型 | 格式 | 来源 | 支持状态 |
|-----------|------|------|:--------:|
| AVTP_timestamp | 32-bit sec + 32-bit ns | gPTP Grandmaster | **Yes** |
| CRF_timestamp | 32-bit sec + 32-bit ns + 32-bit pull | CRF Talker | **Yes** |
| DMA Timestamp | 32-bit ns (截断) | MTL 入口/出口 | **Yes** |

---

## 3. No Feature 影响分析汇总

### 3.1 高风险/不可接受缺失

| Feature | 协议 | 风险等级 | 影响 | 缓解措施 |
|---------|------|:--------:|------|---------|
| BRDG (Bridge/BC) | 802.1AS | **Critical** | Zonal Controller不能桥接gPTP域 | 必须实现 |
| P2P延迟测量 | 802.1AS/1588 | **Critical** | 无法测量link delay | 必须实现 |
| 硬件时间戳 | 802.1AS/1588 | **Critical** | 同步精度降至ms级 | 必须实现 |
| Secure Frame GEN/VER | 802.1AE | **Critical** | MACsec功能失效 | 必须实现 |
| Cipher Suite | 802.1AE | **Critical** | 无加密能力 | 必须实现 |
| Chassis/Port/TTL TLV | 802.1AB | **Major** | LLDP基础功能缺失 | 必须实现 |

### 3.2 中风险/有条件可接受

| Feature | 协议 | 风险等级 | 影响 | 缓解措施 |
|---------|------|:--------:|------|---------|
| SRP (MSRP) | 802.1Q | **Major** | 无动态带宽预留 | 使用静态TAS配置(SMD/SMC文件)替代 |
| PFC | 802.1Q/802.3 | **Major** | 拥塞时可能丢帧 | CBS+TAS提供确定性替代方案 |
| ATS | 802.1Q | **Minor** | 突发流量无平滑 | 静态CBS或门控调度替代 |
| CQF | 802.1Q | **Minor** | 简单调度替代不可用 | TAS已覆盖 |
| MSC/TC (多SC) | 802.1AE | **Minor** | 单SC限制多会话 | 车载点对点链路，单SC足够 |
| IPv4/UDP传输映射 | 1588 | **Minor** | 不支持IP层PTP | 车载场景使用L2映射 |
| E2E TC | 1588 | **Minor** | 无E2E透明时钟 | 802.1AS不定义TC，P2P TC已满足 |
| Management消息 | 1588 | **Minor** | 无PTP管理 | 使用本地诊断/UDS替代 |
| HSR/PRP标签 | 802.1CB | **Minor** | 不兼容工业冗余 | 车载使用原生FRER，无需兼容 |

### 3.3 低风险/可接受缺失

| Feature | 协议 | 风险等级 | 影响 | 缓解措施 |
|---------|------|:--------:|------|---------|
| MIPERF (性能指标) | 802.1AS | **Low** | 无法声明精确性能等级 | 内部测试声明，不对外标准化 |
| MDFDPP (多域帧延迟) | 802.1AS | **Low** | 多域延迟测量不完整 | 单域为主，多域用独立测量 |
| UMM (单播模式) | 802.1AS | **Low** | 不支持单播协商 | 车载组播为主 |
| EEE | 802.3 | **Low** | 无节能以太网 | 车载功耗管理通过PHY休眠实现 |
| SNMP MIB | 802.1AE/802.1AB | **Low** | 不支持SNMP网络管理 | 车载使用寄存器/诊断接口 |
| Organization TLV | 802.1AB | **Low** | 无厂商扩展TLV | 标准TLV已足够 |
| L1Sync | 1588 | **Low** | 无L1层同步 | 车载PHY不支持SyncE |
| AUTH TLV (PTP安全) | 1588 | **Low** | PTP层无认证 | MACsec提供L2安全替代 |
| HA Profile | 1588 | **Low** | 无高精度Profile | 802.1AS精度已满足车载需求 |

---

## 4. 协议实现优先级建议

### 4.1 P0 — 必须实现 (M + 场景强制O)

| 协议 | 功能 | 说明 |
|------|------|------|
| 802.1AS | DOM0, MINTA, BMC, BRDG, MIMSTR | gPTP核心功能 |
| 802.1AS | P2P延迟, Sync, Announce | 时间同步基础 |
| 802.1Q | FQTSS, ETS, SCHED, PRE, PSFP | TSN核心功能 |
| 802.1Q | VLAN, QoS, 优先级映射 | 基础交换功能 |
| 802.3 | 100BASE-T1, 1000BASE-T1, PCS/PMA | 车载PHY |
| 802.1CB | IS/TE/LE/RS + Sequence Gen/Recovery | FRER冗余 |
| 802.1AE | SAP/STAT/GEN/VER/FMT/SCI/KAY/CS | MACsec安全 |
| 802.1AB | Chassis/Port/TTL + Tx/Rx状态机 | LLDP拓扑发现 |
| 1588 | PTPv2.1基础, P2P, Two-Step, 数据集 | PTP底层支持 |
| **1722** | **TK/LS/SW/SID/TS/PM/ACF** | **AVTP流识别与TSN协同** |

### 4.2 P1 — 推荐实现 (高价值O)

| 协议 | 功能 | 说明 |
|------|------|------|
| 802.1AS | DOMADD, SIG, GMCAP, EXT | 多域/GM能力/扩展 |
| 802.1Q | ATS (如资源允许) | 异步整形 |
| 802.3 | 10BASE-T1S + PLCA | 低成本传感器 |
| 802.3 | 2.5G/5G/10GBASE-T1 | ADAS高带宽 |
| 802.1CB | BG (C-component) + Latent Error Detection | Bridge级FRER |
| 802.1AE | CSO (confidentiality offset) | 部分加密优化 |
| 1588 | One-Step时间戳 | 高精度 |
| 1588 | TC-P2P (residence time) | Switch透明时钟 |
| **1722** | **RVF/CRF Talker/Listener, ACF CAN Bridge** | **ADAS视频/控制隧道** |

### 4.3 P2 — 可选实现 (特定场景)

| 协议 | 功能 | 场景 |
|------|------|------|
| 802.1Q | SRP, PFC, CQF | 特定OEM要求 |
| 802.1AE | 多SC/多SAK扩展 | 多会话安全 |
| 1588 | E2E延迟, Unicast, Management | 通用PTP场景 |
| 802.3 | EEE | 低功耗需求 |

### 4.4 P3 — 明确不实现

| 协议 | 功能 | 不实现理由 |
|------|------|-----------|
| 802.1Q | — | — |
| 802.1CB | HSR/PRP兼容标签 | 车载不使用工业冗余协议 |
| 802.1CB | IP Stream Identification | 车载L2识别足够 |
| 802.1AE | SNMP/SNMPv3管理 | 车载不用SNMP |
| 802.1AE | 非标准Cipher Suite | 安全合规要求 |
| 802.1AB | SNMP MIB访问 | 使用寄存器替代 |
| 802.1AB | Organization Specific TLV | 标准功能足够 |
| **1722** | **AAF/CVF/IIDC/VSF/ACF_LIN** | **硬件不直接处理音频/视频编解码/LIN** |
| **1722** | **IEEE 1722.1 AVDECC 完整栈** | **软件层控制面实现** |
| **1722** | **IP层AVTP传输** | **车载L2直接传输为主** |
| 1588 | IPv4/UDP/IPv6映射 | 车载L2直接映射 |
| 1588 | L1Sync | PHY不支持SyncE |
| 1588 | HA Profile | 802.1AS已覆盖 |
| 1588 | E2E TC | 802.1AS无TC概念 |

---

## 5. Cross-Protocol 依赖矩阵

| 上层协议 | 依赖下层协议 | 依赖说明 |
|---------|------------|---------|
| 802.1AS gPTP | 802.3 Ethernet | PTP消息通过Ethernet传输 (Annex F映射) |
| 802.1AS gPTP | 1588-2019 PTP | 802.1AS是1588的Profile，核心机制继承 |
| 802.1Q TSN | 802.3 Ethernet | TSN调度基于MAC/PHY时隙 |
| 802.1Q TSN | 802.1AS gPTP | TAS/ATS依赖gPTP全局时间基准 |
| 802.1CB FRER | 802.1Q VLAN | R-TAG与VLAN tag共存/顺序 |
| 802.1CB FRER | 802.1AS gPTP | 冗余流的时间同步一致性 |
| 802.1AE MACsec | 802.3 Ethernet | MACsec在MAC层操作 |
| 802.1AE MACsec | 802.1AS gPTP | PTP消息可能需要绕过MACsec或特殊处理 |
| 802.1AB LLDP | 802.3 Ethernet | LLDPDU通过Ethernet传输 |
| 1588-2019 PTP | 802.3 Ethernet | Annex F Ethernet映射 |
| **1722 AVTP** | **802.1AS gPTP** | **AVTP时间戳依赖gPTP同步基准** |
| **1722 AVTP** | **802.1Q TSN** | **AVTP流映射到TSN队列与整形器** |
| **1722 AVTP** | **802.1CB FRER** | **冗余AVTP流依赖FRER序列号管理** |
| **1722 AVTP** | **802.3 Ethernet** | **AVTPDU通过Ethernet传输 (EtherType=0x22F0)** |

---

## 6. 与现有 Arch Spec 参数映射

| Arch Spec 参数 | 对应PICS条目 | 状态 |
|---------------|-------------|:----:|
| `SUPPORT_GPTP` | 802.1AS DOM0/MINTA/BMC/BRDG | Yes |
| `SUPPORT_1588` | 1588 PTP-BASE + P2P | Yes |
| `SUPPORT_TSN` | 802.1Q FQTSS/ETS/SCHED/PRE/PSFP | Yes |
| `SUPPORT_CBS` | 802.1Q ETS中的CBS | Yes |
| `SUPPORT_TAS` | 802.1Q SCHED | Yes |
| `SUPPORT_FP` | 802.1Q PRE | Yes |
| `SUPPORT_FRER` | 802.1CB IS/TE/LE/RS | Yes |
| `SUPPORT_SWITCH` | 802.1AS BRDG + 802.1CB BG/RS | Yes |
| `SUPPORT_MACSEC` | 802.1AE SAP/GEN/VER/CS | Yes (外部CSS) |
| `SUPPORT_VLAN` | 802.1Q VLAN + 802.1AB addr | Yes |
| `SUPPORT_AVTP` | **IEEE 1722 TK/LS/SW/SID/TS/PM/ACF** | **Yes** | **新增 PICS 覆盖** |
| `PHC_COUNT=2` | 802.1AS多域/DOMADD | Yes |
| `SWITCH_TAS` | 802.1Q SCHED在Switch | Yes |
| `SWITCH_L3` | 802.1Q无直接对应 | 扩展功能 |

---

*本PICS分析基于 Reference/Kimi_Agent_MCU_Ethernet/ 研究输出，通过Deep-Research-Cluster Route D (File-Augmented)方法提取。所有PICS原始文件已复制到本目录下。*
