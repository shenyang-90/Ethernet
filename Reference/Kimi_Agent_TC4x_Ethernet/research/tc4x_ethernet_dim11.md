# Dimension 11: AURIX TC4x Ethernet Bridge & Packet Classification

## 1. Ethernet Bridge

### 1.1 Hardware Bridge Overview

The AURIX TC4x GETH module integrates a hardware **Bridge** that connects two XGMAC cores and the host interface, enabling Ethernet frame forwarding between all three entities [^75^][^77^].

> "Bridge (exists in products with Ethernet Bridge only): Connects two XGMACs and the host; Forwards Ethernet frames: From the host to a XGMAC, From the two XGMACs to the host, From one XGMAC to the other XGMAC." — Infineon AURIX TC4xx Documentation [^75^]

**Bridge Architecture:**
```
GETH Module
  ├── Host Interface (64-bit SRI master + 32-bit SPB slave)
  ├── Bridge (NEW in TC4x)
  │     ├── Connects XGMAC0 ↔ XGMAC1
  │     ├── Connects XGMAC0 ↔ Host DMA
  │     └── Connects XGMAC1 ↔ Host DMA
  ├── XGMAC Core 0
  │     └── MTL Layer → HSPHY → Port 0
  └── XGMAC Core 1
        └── MTL Layer → HSPHY → Port 1
```

### 1.2 Fast Frame Forwarding (MAC-to-MAC)

The bridge supports **MAC-to-MAC frame forwarding**, a critical feature for daisy-chain and ring topology applications in automotive networks [^28^][^48^][^36^].

> "AURIX™ TC4x GETH通过硬件网桥支持MAC到MAC的帧转发，可用于将帧转发到目标接收器上, 支援FR的应用需求。" — Infineon TC4x TSN Support Article [^48^]

**Bridge forwarding paths include:**
- **Host → XGMAC**: CPU-generated frames transmitted out a specific port
- **XGMAC → Host**: Received frames delivered to host memory via DMA
- **XGMAC ↔ XGMAC**: Port-to-port forwarding without CPU intervention [^75^][^36^]

> "该桥接器专需在终端站点通过双以太网端口接入网络的场景而设计，其具备双重数据处理能力：既能通过多通道DMA接口将任一端口的流量终结至主机系统，又能实现双端口间的数据转发。后一功能主要针对菊花链拓扑结构的以太网网络应用。" — TC4x GETH Module Deep Dive [^28^]

### 1.3 Bridge Filtering and Parser Capabilities

The TC4x Ethernet bridge integrates comprehensive filtering at the ingress point [^5^][^77^]:

> "Ethernet bridge with filter and parser capabilities — Reduces communication load on CPUs and enables safety critical real time communication" — Infineon TC4x Product Brief [^25^]

Key bridge filtering features:
- **Flexible Frame Parser (FFP)**: Programmable packet header inspection for filtering and monitoring [^33^][^13^]
- **L2/L3/L4 filter integration**: All filter results feed into forwarding decisions
- **Forwarding Table (FTCFG)**: Static forwarding table configuration for bridge routing decisions [^41^]

### 1.4 Daisy Chain and Ring Topology Support

The TC4x bridge is explicitly designed for daisy-chain Ethernet topologies commonly used in automotive E/E architectures [^28^][^36^][^5^].

> "Performance & redundancy for safety critical application in daisy chain & ring topologies" — Infineon HotChips Presentation [^5^]

**Topology benefits:**
- Hardware forwarding eliminates CPU processing per frame in the relay path
- Deterministic latency for bridged traffic
- Reduced SW processing load through hardware acceleration [^25^]

### 1.5 Redundancy for Safety-Critical Applications

The TC4x GETH supports **IEEE 802.1CB Frame Replication and Elimination for Reliability (FRER)** [^48^][^13^][^33^]:

> "IEEE 802.1CB可靠性帧复制和消除(FRER)通过多个不相连的路径发送每个帧的副本，它可为不能容忍数据包丢失的控制应用程序提供主动无缝冗余。复制帧在2个（或更多）不相交的路径上发送帧，然后在相交点合并并删除多余的帧。" — TC4x TSN Support Article [^13^]

**FRER mechanism:**
- Frame copies are sent over 2 (or more) disjoint paths
- Duplicate frames are merged and eliminated at intersection points
- Each replicated frame carries a sequence identifier for reordering
- Provides 1+1 (or 1+n) per-frame redundancy [^48^]

> "AURIX™ TC4x GETH通过硬件网桥支持MAC到MAC的帧转发，可用于将帧转发到目标接收器上, 支援FR的应用需求。" — TC4x GETH TSN Article [^48^]

---

## 2. Packet Classification

### 2.1 L2 Classification

The XGMAC core provides extensive Layer 2 classification capabilities [^78^][^79^]:

**MAC Address Filtering:**
- Up to **32 Destination Address (DA) perfect match filters** with per-byte masks
- Up to **31 Source Address (SA) perfect match filters** with per-byte masks
- 64-bit hash filter (optional) for multicast and unicast DAs
- Promiscuous mode for network monitoring
- Option to pass all multicast-addressed frames [^78^][^28^]

> "Support for the following flexible address filtering modes for received frames: Up to 32 destination address (DA) perfect match address filters with masks for each byte; Up to 31 source address (SA) perfect match filters with masks for each byte; 64-bit hash filter (optional) for multicast and unicast DAs" — Intel XGMAC Core Reference [^78^]

**VLAN-based L2 Classification:**
- Up to **32 VLAN-based perfect match and hash filtering** entries [^78^]
- Extended VLAN tag-based filtering with 8 filter selection options

**EtherType Classification:**
- Standard Ethernet Type/Length field parsing
- Support for custom protocol identification

### 2.2 L3 Classification

The XGMAC provides Layer 3 filtering capabilities [^78^][^28^]:

- **IPv4 header checksum offload** on reception
- **Source IP address filtering** (IPv4/IPv6)
- **Destination IP address filtering** (IPv4/IPv6)
- Protocol type identification (TCP, UDP, ICMP over IPv4/IPv6) [^78^]

### 2.3 L4 Classification

Layer 4 filtering is supported through dedicated hardware filters:

- Up to **16 Layer 3 and Layer 4 match filters** for TCP or UDP over IPv4 or IPv6 [^78^][^79^]
- Source/destination TCP port number matching
- Source/destination UDP port number matching
- All incoming packets can be passed with status report as determined by filter

> "Up to 16 Layer 3- and Layer 4-based (TCP or UDP over IPv4 or IPv6) match filters" — Intel XGMAC Core Reference [^78^]

### 2.4 Flexible Parser Rules (FRP - Flexible Receive Parser)

The TC4x implements a **Flexible Receive Parser (FRP)** — a programmable parser for custom packet inspection [^41^][^508^]:

> "The MAC hardware controller has an in-built programmable parser to parse the Ethernet packet based on a software-controlled/programmable rule-set. This supports filtering and packet steering decisions (DMA channel selection) of the received packet based on any header field, 64/124 bytes from SOF (start of frame), of existing protocols or custom and future protocols." — NVIDIA FRP Documentation [^508^]

**FRP capabilities:**
- **Instruction table** with up to 256 entries
- Parse any header field within first 64/124 bytes from SOF
- Support for existing protocols and custom/future protocols
- Filter modes: Accept and route, Reject and drop, Link to OK index, Inverse match [^508^]

**FRP match types supported:**
| Type | Match Data |
|------|-----------|
| 0 | Normal data |
| 1 | L2 DA MAC |
| 2 | L2 SA MAC |
| 3 | L3 Source IP |
| 4 | L3 Destination IP |
| 5 | L4 UDP Source Port |
| 6 | L4 UDP Destination Port |
| 7 | L4 TCP Source Port |
| 8 | L4 TCP Destination Port |
| 9 | VLAN Tag |

> "When FRP-based routing is enabled, MAC, RSS and IP based routing will not apply." — NVIDIA FRP Documentation [^508^]

**FRP for PSFP (IEEE 802.1Qci):**
The TC4x uses FRP for Per-Stream Filtering and Policing [^33^][^13^]:
- Stream filter: Identifies stream ID and maps to one of 8 gateway IDs
- Flow gate: Defined in Gate Control List (GCL)
- Flow meter: Implemented via Police Counter (PC)

---

## 3. Quality of Service (QoS)

### 3.1 Multiple TX/RX Queues

The TC4x GETH features significantly expanded queue resources compared to TC3x:

| Feature | TC3x | TC4x |
|---------|------|------|
| DMA Channels | 4 | **8** |
| TX Queues | 4 | **8** |
| RX Queues | 4 | **8** |
| TX FIFO Size | 4 KB | **32 KB** |
| RX FIFO Size | 8 KB | **32 KB** |

> "DMA包含8个独立通道（上一代为4个），每个通道具备独立的Tx引擎和Rx引擎。" — TC4x GETH Deep Dive [^36^]

> "这一代的MTL层的Buffer较上一代（RX 8k，TX 4k）有较大提升，TX和RX分别支持到32k大小。" — TC4x GETH Module Analysis [^44^][^28^]

**Queue-to-DMA mapping:** Each queue can be connected to any DMA channel, providing flexible data path configuration.

### 3.2 Priority-Based Queue Assignment

The TC4x supports **Traffic Classification** between host port and ingress/egress ports [^77^]:

- Traffic is classified into multiple priority classes
- Each class maps to a specific TX/RX queue
- 8 priority levels supported (matching IEEE 802.1Q UP field)
- **User Priority (UP) to queue mapping** via programmable registers

### 3.3 Queue Scheduling Mechanisms

The TC4x GETH/LETH supports multiple QoS shapers [^114^][^29^]:

**Credit Based Shaper (CBS) — IEEE 802.1Qav:**
- 4 Credit Based Shapers per port
- IEEE 802.1Q compatible
- Shapes AVB traffic by controlling bandwidth allocation
- IdleSlope and SendSlope programmable parameters [^41^]

> "When Credit Based Shaper(CBS) is enabled for a Traffic Class(TC), the packet available in a TC is scheduled for transmission when zero or positive credit is accumulated for the TC." — TC4Dx Errata Sheet [^41^]

**Time Aware Shaper (TAS) — IEEE 802.1Qbv:**
- 4 Time Based Shapers per port
- Gate Control List (GCL) for deterministic scheduling
- Time-triggered transmission for critical traffic
- Each queue can enable/disable shapers individually [^114^]

> "IEEE 802.1Qbv Time Aware Shapter TAS allows scheduling the transmission of time-critical frames and lower-priority frames in time-triggered windows." — TC4x TSN Article [^29^]

**Strict Priority (SP):**
- Higher-numbered queues have higher priority
- Default scheduling when no shapers are enabled
- Combined with CBS for AVB traffic classes

### 3.4 Priority Mapping (UP to Queue)

- IEEE 802.1Q **PCP (Priority Code Point)** field maps directly to Traffic Class (TC)
- TC 0-7 supported, mapping to queues 0-7
- Programmable UP-to-queue mapping via MTL configuration registers

---

## 4. Frame Filtering

### 4.1 Address Filtering (Perfect Match, Hash Filter)

The **Address Filtering Module (AFM)** performs comprehensive MAC address filtering [^28^][^78^]:

> "地址过滤模块（AFM）检查所有接收帧的目的MAC地址和/或源MAC地址，并向RFC报告地址过滤状态。" — TC4x GETH Deep Dive [^28^]

**Perfect Match Filters:**
- 32 DA filters with individual byte masks
- 31 SA filters with individual byte masks
- Each filter can be enabled/disabled independently
- Supports unicast and multicast addresses

**Hash Filter:**
- 64-bit hash table for DA filtering
- Supports both unicast and multicast destination addresses
- Configurable hash algorithm

**Special modes:**
- Promiscuous mode: Pass all frames without filtering
- Pass all multicast: Forward all multicast frames
- Inverse filtering: Drop matched addresses (instead of pass)

### 4.2 VLAN Filtering

The XGMAC supports comprehensive VLAN filtering [^133^][^78^]:

- Up to **32 VLAN-based perfect match and hash filtering** entries
- Extended VLAN tag-based filtering (8 filter selections)
- Support for filtering based on **outer or inner VLAN tag** [^133^]
- VLAN hash filtering mode (with known erratum workaround) [^41^]

> "VLAN tag-based: Perfect match and Hash-based (optional) filtering. Filtering based on either outer or inner VLAN tag is possible. Extended VLAN tag based filtering 8 filter selection" — AURIX TC3xx/TC4xx Documentation [^133^]

**VLAN filter fail handling:**
- Frames failing VLAN filter can be routed to a specific "filter fail queue"
- Known erratum: VLAN filter fail queue routing requires software check [^41^]

### 4.3 Layer 3/Layer 4 Filter

The XGMAC integrates L3/L4 filtering hardware [^78^][^28^]:

- Up to **16 L3/L4 match filters**
- TCP/UDP/ICMP over IPv4 or IPv6
- Source/destination IP address matching
- Source/destination port number matching
- Filter results reported in receive descriptor status

### 4.4 Broadcast/Multicast Filtering

- Dedicated broadcast frame filtering
- Multicast hash filter (64-bit) for efficient group address filtering
- "Pass all multicast" mode for protocols requiring all multicast reception
- Inverse filtering support for selective multicast blocking

---

## 5. VLAN Handling

### 5.1 VLAN Tag Insertion/Removal

The TC4x GETH MAC supports comprehensive VLAN tag manipulation [^28^][^35^]:

**Transmit VLAN handling (TBU - Transmit Bus Interface Unit):**
- VLAN tag **insertion** on a per-frame or global basis
- VLAN tag **replacement** (overwrite existing tag)
- VLAN tag **deletion** (stripping)
- Controlled via MAC_VLAN_Incl register VLT field and TDES2 VTIR field [^28^]

> "TBU & VLAN Tag Modification: 发送总线接口模块（TBU）负责对发送帧进行VLAN标签和源地址（SA）的灵活操作，包括添加、替换或删除VLAN标签" — TC4x GETH Module Deep Dive [^28^]

**Receive VLAN handling:**
- IEEE 802.1Q VLAN tag detection
- Optional VLAN tag stripping in received packets [^78^]
- VLAN tag information provided in receive descriptor status

> "VTIR（15:14）: VLAN标签插入、替换标志位，VLAN一般由上层处理，AUTOSAR中也一般交给EthIf来管理，所以该位一般是0" — TC4x GETH Deep Dive [^28^]

### 5.2 Double VLAN (QinQ) Support

The XGMAC core supports **stacked VLAN tagging** [^78^][^79^]:

> "Support for up to two Stacked-VLAN tagged or QinQ tagged packets" — Intel XGMAC Core Reference [^78^]

QinQ capabilities:
- Outer tag (Provider VLAN, S-VLAN) and inner tag (Customer VLAN, C-VLAN)
- TPID 0x8100 on both inner and outer tags supported
- Independent filtering on outer or inner VLAN tag [^133^]
- Optional stripping of up to two VLAN tags with tag values in status [^78^]

### 5.3 VLAN Priority Handling

- IEEE 802.1Q **PCP (Priority Code Point)** extraction from VLAN tag
- **DEI (Drop Eligible Indicator)** handling
- Priority-based queue assignment from PCP field
- VLAN priority-based flow control

---

## 6. Safety Features

### 6.1 Frame Redundancy (FRER / 802.1CB)

The TC4x supports hardware-level frame redundancy through IEEE 802.1CB [^48^][^13^][^33^]:

**Frame Replication and Elimination for Reliability (FRER):**
- Hardware MAC-to-MAC forwarding supports Frame Replication applications
- Duplicate frames sent over disjoint paths
- Sequence number-based duplicate elimination
- 1+1 or 1+n redundancy schemes supported

> "IEEE 802.1CB可靠性帧复制和消除(FRER)通过多个不相连的路径发送每个帧的副本，它可为不能容忍数据包丢失的控制应用程序提供主动无缝冗余。" — TC4x TSN Article [^33^]

### 6.2 Error Detection

The TC4x GETH implements comprehensive error detection mechanisms [^77^][^28^]:

**Memory Protection:**
- **Error Correction Code (ECC)** protection for all internal memories (RX/TX FIFOs, descriptor caches)
- Single-bit error correction, double-bit error detection

**FSM Protection:**
- **FSM parity and timeout protection** for all state machines
- Detects and reports FSM corruption or lockups

**Interface Protection:**
- **Application/CSR interface timeout protection**
- Prevents bus lockups due to faulty register accesses

> "Automotive Safety Features: The automotive safety features improve the reliability and reduce the time taken to detect faults. GETH supports: Error correction code (ECC) protection for memories; FSM parity and timeout protection; Application/CSR interface timeout protection" — Infineon TC4xx Documentation [^77^]

**CRC and Frame Error Detection:**
- Automatic FCS (Frame Check Sequence) verification on receive
- CRC-32 generation on transmit
- Jabber frame detection
- Runt frame detection
- Giant frame detection
- Frame length error detection

### 6.3 Fault Isolation

The TC4x architecture supports fault isolation for safety-critical applications:

**IEEE 802.1Qci Per-Stream Filtering and Policing (PSFP):** [^33^][^13^]
- Isolates network faults to specific regions
- Prevents faulty nodes from affecting other traffic
- Ingress policing against DDoS-like attacks

**PSFP Components:**
1. **Stream Filter**: Identifies stream ID via FFP, maps to 8 gateway IDs [^13^]
2. **Stream Gate**: Gate Control List (GCL) for per-stream gate control
3. **Flow Meter**: Police Counter (PC) for bandwidth enforcement

> "为了防止网络故障影响或恶意攻击对网络造成的干扰，802.1Qci将故障隔离到网络中的特定区域。" — TC4x GETH Article [^33^]

**Bridge-level fault isolation:**
- Separate RX/TX queues prevent Head-of-Line (HOL) blocking between traffic classes
- Per-DMA channel isolation
- Bridge forwarding errors contained to affected path [^41^]

### 6.4 Additional Safety Considerations

**LETH (Lite Ethernet) Safety Integration:**
- Safety alarms routed to SMU (Safety Management Unit)
- Reset isolation considerations documented in errata [^41^]
- Watchdog timer support for DMA channel monitoring

**Errata-Specific Safety Notes:**
- Bridge forwarding padding issue: Extra bytes may be padded in specific forwarding scenarios; egress MAC recomputes CRC (no FCS error) [^41^]
- Rx DMA stall in bridge mode: Workarounds require timestamp enable or specific channel mapping [^41^]
- TAS extra IPG: Worst-case 12 clock cycles additional IPG due to CDC delays [^41^]

---

## 7. Summary Table

| Feature | TC4x GETH Capability |
|---------|---------------------|
| **Ethernet Bridge** | Hardware bridge between 2 XGMACs + Host |
| **MAC-to-MAC Forwarding** | Yes, hardware-based without CPU intervention |
| **Daisy Chain Support** | Yes, primary use case for bridge |
| **Ring Topology** | Supported via bridge + software |
| **FRER (802.1CB)** | Supported via hardware bridge |
| **DMA Channels** | 8 (up from 4 in TC3x) |
| **TX/RX Queues** | 8 TX / 8 RX |
| **MTL FIFO Size** | 32 KB TX / 32 KB RX |
| **DA Perfect Match Filters** | 32 |
| **SA Perfect Match Filters** | 31 |
| **Hash Filter** | 64-bit for DA multicast/unicast |
| **VLAN Perfect Match** | 32 entries |
| **L3/L4 Filters** | 16 (TCP/UDP over IPv4/IPv6) |
| **FRP Entries** | Up to 256 instruction table entries |
| **QoS Shapers** | 4 CBS + 4 TAS per port |
| **VLAN Tag Handling** | Insert/Replace/Delete, QinQ (2 tags) |
| **ECC Protection** | All internal memories |
| **FSM Protection** | Parity + timeout |
| **Speeds** | 10M/100M/1G/2.5G/5G full-duplex |
| **PHY Interfaces** | SGMII, USXGMII, RGMII, RMII, MII |

---

## 8. References

- [^5^] Infineon HotChips Presentation: "Heterogeneous Computing to enable highest level of safety"
- [^13^] EEWORLD: "AURIX™ TC4x GETH对时间敏感网络的支持介绍"
- [^25^] Infineon: "Welcome to the next generation AURIX™ TC4x" Product Brief
- [^28^] 10100.com: "英飞凌Aurix™ TC4x 以太网GETH模块详解"
- [^29^] EEWORLD: "AURIX™ TC4x GETH supports time-sensitive networking"
- [^33^] Sina Finance: "AURIX TC4x GETH对时间敏感网络的支持介绍"
- [^35^] EEWORLD (English): "Infineon Aurix™ TC4x Ethernet GETH Module Detailed"
- [^36^] Tencent News: "英飞凌Aurix TC4x 以太网GETH模块详解"
- [^41^] Infineon: "AURIX™ TC4Dx errata sheet" (ES-AB)
- [^44^] EET China: "英飞凌Aurix™ TC4x 以太网GETH模块详解"
- [^48^] WeChat: "AURIX™ TC4x GETH对时间敏感网络的支持介绍"
- [^75^] Infineon Documentation: "Functional overview | AURIX™ TC4xx"
- [^77^] Infineon Documentation: "Feature list | AURIX™ TC4xx"
- [^78^] Intel: "XGMAC Core" Reference Documentation
- [^79^] Intel: "XGMAC Core (5.1.3.1)" Reference Documentation
- [^114^] Infineon Training: "LETH Lite Ethernet"
- [^128^] Infineon Community: "GETH embedded MTL queue FIFOs handling"
- [^133^] Infineon Documentation: "Gigabit Ethernet (GETH) | AURIX™ TC3xx"
- [^216^] Infineon Training: "DRE Data Routing Engine"
- [^508^] NVIDIA Documentation: "FRP (Flexible Receive Parser) Validation"
- [^510^] Infineon Documentation: "CANXL Feature list | AURIX™ TC4xx"
