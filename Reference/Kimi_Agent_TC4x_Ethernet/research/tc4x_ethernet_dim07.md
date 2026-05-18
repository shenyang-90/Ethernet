# Dimension 7: LETH Module - Lite Ethernet (Infineon AURIX TC4x)

## Table of Contents
1. [LETH Overview](#1-leth-overview)
2. [Supported Speeds](#2-supported-speeds)
3. [10BASE-T1S Support](#3-10base-t1s-support)
4. [Architecture](#4-architecture)
5. [PHY Interfaces](#5-phy-interfaces)
6. [Supported Protocols](#6-supported-protocols)
7. [Use Cases](#7-use-cases)
8. [Differences from GETH](#8-differences-from-geth)
9. [References](#9-references)

---

## 1. LETH Overview

The **Lite Ethernet (LETH)** module in the Infineon AURIX TC4x family provides a lightweight, cost-optimized Ethernet MAC solution designed for low-speed automotive communication. It extends Ethernet connectivity to traditional ECU domains that do not require the high bandwidth of the Gigabit Ethernet (GETH) module.

### Key Characteristics

| Parameter | Value |
|-----------|-------|
| **Number of MAC instances** | 4 independent LETH MACs |
| **Maximum speed** | 10/100 Mbps per MAC |
| **Standards** | IEEE 802.3 Ethernet |
| **Target applications** | Low-speed ECU communication, sensor/actuator networks |
| **Special feature** | Integrated 10BASE-T1S digital PHY support |

> **Quote from Infineon AURIX TC4x Overview:**
> "4x10/100MBit Ethernet supporting 10Base-T1S standard" [^19^]

> **Quote from Infineon automotive Ethernet article:**
> "广泛性的Lite Ethernet（LETH）支持 4x10/100MBit以太网速度，另外还支持了10Base-T1S标准，把以太网的应用范围延伸到一些传统ECU需要的低速数据通讯领域。"
> (The extensive Lite Ethernet (LETH) supports 4x10/100 Mbit Ethernet speeds, and additionally supports the 10Base-T1S standard, extending the application scope of Ethernet to low-speed data communication fields required by traditional ECUs.) [^110^][^112^]

### Role in TC4x Connectivity

The TC4x provides a comprehensive Ethernet portfolio:
- **GETH**: 2x 5 Gbps Ethernet for high-speed backbone communication
- **LETH**: 4x 10/100 Mbps Ethernet for low-speed edge node communication
- **CSS (Cyber Security Satellite)**: Hardware crypto acceleration for secure CAN/Ethernet communication [^113^]

### AUTOSAR MCAL Support

The LETH module is supported by Infineon's MC-ISAR AUTOSAR MCAL drivers:
> "Comm enhanced ASIL B & - FlexRay - GETH Gigabit Ethernet - LETH Lite Ethernet" [^313^]

The TC4x MCAL (AUTOSAR R20-11) includes dedicated LETH drivers with ASIL B safety claims.

---

## 2. Supported Speeds

### 2.1 100 Mbps Mode

The LETH MAC supports **100 Mbps full-duplex** operation via:
- **MII (Media Independent Interface)**: 4-bit wide data interface, 25 MHz clock
- **RMII (Reduced Media Independent Interface)**: 2-bit wide data interface, 50 MHz reference clock

In 100 Mbps mode, the LETH connects to an external Ethernet PHY chip via MII or RMII interface pins.

### 2.2 10 Mbps Mode

The LETH MAC supports **10 Mbps** operation in two configurations:

#### a) Standard MII/RMII with External 10 Mbps PHY
- Connects to a standard 10BASE-T or 10BASE-T1S external PHY
- Uses MII (2.5 MHz RXCLK) or RMII interface

#### b) 10BASE-T1S 3-Pin Transceiver Mode (Integrated Digital PHY)

The LETH includes an **integrated 10BASE-T1S digital PHY** that directly outputs to an external PMD (Physical Medium Dependent) transceiver via the **OPEN Alliance TC14 3-pin interface** [^41^]:

> **Quote from TC4Dx Errata Sheet:**
> "The LETH 10BASE-T1S Digital PHY transmits RZI encoded 5-bits symbols serially on the TX pin of OA 3-pin interface. Each bit is of duration 80ns" [^41^]

**3-Pin Interface Signals (TC14)**:
| Pin | Direction | Description |
|-----|-----------|-------------|
| **TX** | MAC → Transceiver | Transmit data / command encoding (TRANSMIT, RESET, LOWPWRRQ, CONFIG) |
| **RX** | Transceiver → MAC | Receive data in RZI encoding |
| **ED** | Transceiver → MAC | Energy Detection / Collision indication |

The TC14 interface uses pulse-width modulated commands on the TX pin:
- **TRANSMIT**: Short low pulse (20 ns) followed by high - starts data transmission
- **RESET**: TX low for >200 ns - resets transceiver to NORMAL state
- **LOWPWRRQ**: TX low for >20 us - enters low-power mode
- **CONFIG**: Short pulse (20 ns low, 20 ns high) followed by long low (>16 us) - enters configuration mode [^306^]

### 2.3 Speed Selection

Speed selection is typically performed via:
- PHY register configuration (BMCR register bits 13 and 8) [^398^]
- Auto-negotiation (when enabled)
- 10BASE-T1S mode enabled via dedicated LETH control registers

---

## 3. 10BASE-T1S Support

### 3.1 IEEE 802.3cg Standard

**10BASE-T1S** (10 Megabit per second Ethernet over a single twisted pair, short reach) is defined in **IEEE 802.3cg-2019** (Clause 147). It provides:

| Parameter | Specification |
|-----------|-------------|
| Data rate | 10 Mbps |
| Cable type | Single twisted pair (unshielded or shielded) |
| Topology | Point-to-point (15m) or Multidrop (up to 8 nodes, 25m total) |
| Encoding | Differential Manchester Encoding (DME) with 4B/5B line code |
| Symbol rate | 25 MHz |
| Access method | CSMA/CD (fallback) or PLCA (preferred for multidrop) |

> **Quote from IEEE 802.3cg CFI:**
> "10BASE-T1S single pair multidrop (PLCA) was added to 802.3cg to serve the automotive Ethernet needs." [^301^]

### 3.2 PLCA (Physical Layer Collision Avoidance) Mechanism

PLCA is the key enabler for 10BASE-T1S multidrop operation. It operates at the PHY layer, entirely within the **Reconciliation Sublayer (RS)**, and works with the CSMA/CD MAC (Clause 4).

#### How PLCA Works

> **Quote from Intrepidcs:**
> "In PLCA, each node is assigned an ID starting with 0 and incrementing to the number of nodes minus one... The node with ID 0 is responsible for sending one of these special symbols called a BEACON. The BEACON indicates the start of a network cycle where every node will have a transmit opportunity (TO) starting with node 0 until the node with the highest ID in a round-robin fashion." [^388^]

**PLCA Cycle Sequence**:
```
|<- Beacon ->|<- TO0 ->|<- TO1 ->|<- TO2 ->|<- TO3 ->| ... |<- TO_N ->|
  Coordinator  Node0    Node1    Node2    Node3          NodeN
```

**Key PLCA Symbols**:
| Symbol | Description |
|--------|-------------|
| **BEACON** | Synchronization signal sent by coordinator (Node 0) to start a new cycle |
| **COMMIT** | Signal sent by a node to indicate it will transmit data during its TO |
| **SSD** | Start of Stream Delimiter - marks beginning of packet data |
| **ESD/ESDOK** | End of Stream Delimiter / OK - marks end of successful transmission |
| **SILENCE** | No signal on bus - indicates idle state |

#### Timing Parameters

> **Quote from Japanese technical article:**
> "PLCA の最小タイムスロットは 2マイクロ秒（20 クロックサイクル）で最大タイムスロットは Commit と最大 Ethernet フレーム送信時間の和になる。"
> (The minimum PLCA time slot is 2 microseconds (20 clock cycles), and the maximum time slot is the sum of COMMIT and the maximum Ethernet frame transmission time.) [^392^]

| Parameter | Typical Value |
|-----------|---------------|
| TO_TIMER (Transmit Opportunity window) | 24-32 bit times (~2.4-3.2 us) |
| Minimum PLCA cycle | ~18 us (all nodes silent) |
| Maximum PLCA cycle | ~9.9 ms (all nodes transmit max frames) |
| BEACON-to-TO latency per node | ~2 us per node ID |

#### PLCA Burst Mode

An optional burst mode allows a node to transmit **up to 255 additional packets** during a single Transmit Opportunity [^388^]:

> "An optional Burst Mode in 10BASE-T1S enables a node to transmit from 0 up to 255 additional packets during its Transmit Opportunity (TO)."

This is useful for:
- **Asymmetric traffic**: Heavy data producer nodes can send more packets
- **Isochronous streams**: Audio data at 48 kHz (one packet every 20 us) that may exceed the PLCA cycle time

#### Burst Mode Operation
- First packet ends with **ESDBRS** (instead of ESD) + ESDOK to indicate more data
- Subsequent packets are preceded by a new COMMIT
- Last packet ends with normal ESD/ESDOK

### 3.3 Multi-Drop Bus Topology

```
                    10BASE-T1S Multidrop Bus
    =================================================================
    |                                                                |
  [Node 0]        [Node 1]        [Node 2]        [Node 3]        [Node N]
  Coordinator     Drop Node       Drop Node       Drop Node       Drop Node
  (PLCA ID=0)     (PLCA ID=1)     (PLCA ID=2)     (PLCA ID=3)     (PLCA ID=N)
    |                |               |               |               |
  [TC4x LETH]    [TC4x LETH]    [TC4x LETH]    [TC4x LETH]    [TC4x LETH]
  + PMD Xcvr     + PMD Xcvr     + PMD Xcvr     + PMD Xcvr     + PMD Xcvr
```

**Bus Design Rules** [^386^]:
- Maximum **8 nodes** per bus segment (including coordinator)
- Total cable length **≤ 25 meters**
- Stub length **≤ 0.3 meters** (ideally minimized)
- **100 Ohm termination** resistors at both ends of bus
- Each drop node connects with high-Z when not transmitting

### 3.4 Collision Detection and Avoidance

In 10BASE-T1S multidrop mode, collisions are **avoided** by PLCA rather than detected and recovered:

> **Quote from Peak Systems:**
> "Unlike traditional point-to-point Ethernet connections, 10BASE-T1S enables multiple devices to share a single twisted-pair cable. This bus-like architecture reduces the number of required connectors and cables, significantly lowering both weight and system costs." [^302^]

**Collision Handling**:
1. PLCA prevents collisions by design - only one node transmits at any time
2. The LETH 10BASE-T1S digital PHY includes **collision detection** comparing TX and RX paths [^41^]
3. If a collision is detected (simultaneous TX and RX activity), the PHY signals COL to the MAC
4. The MAC then performs standard CSMA/CD back-off procedure

### 3.5 Advantages over CAN for Low-Speed Data

| Feature | 10BASE-T1S | CAN-FD | CAN-CC | LIN |
|---------|------------|--------|--------|-----|
| **Data rate** | 10 Mbps | 8 Mbps | 1 Mbps | 20 kbps |
| **Topology** | Multidrop bus | Bus | Bus | Bus |
| **Nodes per segment** | Up to 8 | Up to 32 | Up to 32 | Up to 16 |
| **Cabling** | Single twisted pair | Twisted pair | Twisted pair | Single wire |
| **Software stack** | Full Ethernet/IP | CAN-specific | CAN-specific | LIN-specific |
| **Security** | MACsec capable | Limited | Limited | None |
| **Power over data** | PoDL supported | No | No | No |
| **Cable length** | 25m (8 nodes) | ~40m | ~40m | ~40m |
| **Determinism** | Bounded (PLCA) | Good | Good | Good |
| **Cost per node** | Low | Low | Very low | Very low |

> **Quote from automotive Ethernet basics:**
> "10BASE-T1S revolutionizes in-vehicle networking: 10 Mbps over a single pair, reduced cabling, lower costs. Ideal for sensors, actuators, and zonal architectures - the Ethernet-based future replacing classic bus systems like CAN or LIN." [^302^]

**Key Advantages**:
1. **Unified IP-based stack**: Same TCP/IP, SOME/IP, DoIP, UDP/IP stack as high-speed Ethernet - no protocol translation gateways needed
2. **Deterministic latency**: PLCA provides bounded maximum latency based on node count
3. **Security**: MACsec (Layer 2 encryption) can be applied, unlike CAN/LIN
4. **Scalability**: Seamless upgrade path from 10 Mbps (10BASE-T1S) to 100 Mbps (100BASE-T1) to 1 Gbps (1000BASE-T1)
5. **Simplified wiring**: Single twisted pair with multidrop topology reduces harness complexity
6. **Service-oriented communication**: Native support for SOME/IP and future service-oriented architectures

---

## 4. Architecture

### 4.1 Internal Structure

> **Quote from Infineon LETH Training:**
> The LETH block diagram shows the following key components [^114^]:
> - **MAC Core**: Ethernet MAC engine
> - **Buffer RAM**: Internal packet buffers
> - **Tx DMA / Rx DMA**: Direct memory access engines
> - **Clock Control**: Clock generation and management
> - **MII / RMII / MDIO**: PHY interface signals
> - **Control & Status Registers**: AHB/SRI bus accessible configuration

```
                    LETH Block Diagram
    +----------------------------------------------------------+
    |                      LETH MAC                             |
    |  +---------+   +----------+   +--------------------+     |
    |  |  MAC    |<->|  Buffer  |<->|     Tx DMA         |     |
    |  |  Core   |   |   RAM    |   |  (Transmit DMA)    |     |
    |  +---------+   +----------+   +--------------------+     |
    |       ^                       +--------------------+     |
    |       |                       |     Rx DMA         |     |
    |       v                       |  (Receive DMA)     |     |
    |  +---------+   +--------+     +--------------------+     |
    |  |  CRC/   |   | Clock  |              |                |
    |  |  Pad    |   |Control |              v                |
    |  +---------+   +--------+        +------------+          |
    |       |                               | SRI Bus |          |
    |       v                               +------------+      |
    |  +---------+   +--------+   +-----+                    |
    |  |   MII   |   |  MDIO  |   |Shaper|                   |
    |  |  RMII   |   |        |   |Queue |                   |
    |  +---------+   +--------+   +-----+                    |
    |       |                                                   |
    +-------|---------------------------------------------------+
            |
    +-------v---------------------------------------------------+
    |                  External PHY / PMD                       |
    |              (10/100 PHY or 10BASE-T1S Xcvr)              |
    +-----------------------------------------------------------+
```

### 4.2 DMA Engine Capabilities

The LETH includes a **multichannel DMA engine** for efficient data transfer with minimal CPU intervention:

> **Quote from Infineon LETH Training:**
> "Data traffic separated into 4 queues: Up to 4 Tx queues sharing 16 KB FIFO - Up to 4 Rx queues sharing 8 KB FIFO. Each queue can be connected to any CPU." [^114^]

**DMA Channel Configuration**:
| Parameter | Value |
|-----------|-------|
| **Number of Tx DMA channels** | Up to 4 |
| **Number of Rx DMA channels** | Up to 4 |
| **Tx FIFO size** | 16 KB (shared among Tx queues) |
| **Rx FIFO size** | 8 KB (shared among Rx queues) |
| **Queue-to-CPU mapping** | Flexible - any queue can route to any CPU |
| **Descriptor type** | Normal descriptors + Context descriptors (for timestamps) |

**DMA Features** (inferred from errata documentation) [^41^]:
- Normal descriptor ring management for packet data
- Context descriptors for timestamp status (IEEE 802.1AS)
- Packet flush capability to prevent head-of-line blocking
- Per-channel independent operation
- Timestamp integration with descriptor write-back

**Descriptor Structure** (from errata references):
- **TDES0-TDES3**: Transmit descriptor words (status, buffer addresses, control)
- **RDES0-RDES3**: Receive descriptor words (status, buffer addresses, control)
- Context descriptors store captured timestamps when TSA (Timestamp Available) bit is set

### 4.3 Queue Structure

> **Quote from Infineon LETH Training:**
> "Data traffic separated into 4 queues: Up to 4 Tx queues sharing 16 KB FIFO - Up to 4 Rx queues sharing 8 KB FIFO" [^114^]

**Transmit Path**:
```
    CPU/Software
         |
    +----v----+   +---------+   +---------+   +---------+   +---------+
    |  TxQ0   |   |  TxQ1   |   |  TxQ2   |   |  TxQ3   |
    |Queue 0  |   |Queue 1  |   |Queue 2  |   |Queue 3  |
    +----+----+   +----+----+   +----+----+   +----+----+
         |             |             |             |
         +------+------+------+------+-------------+
                |
    +-----------v-----------+    +------------------+
    |   Tx Scheduler        |    |  Shaper Logic    |
    |  (Priority/TSN)       |<---| (CBS/TAS)        |
    +-----------+-----------+    +------------------+
                |
    +-----------v-----------+
    |   MAC Core            |
    |   (Transmit Engine)   |
    +-----------------------+
```

**Receive Path**:
```
    MAC Core (Rx Engine)
         |
    +----v------------------+
    |   Rx Parser/Filter    |
    +----+------------------+
         |
    +----v----+   +---------+   +---------+   +---------+
    |  RxQ0   |   |  RxQ1   |   |  RxQ2   |   |  RxQ3   |
    |Queue 0  |   |Queue 1  |   |Queue 2  |   |Queue 3  |
    +----+----+   +----+----+   +----+----+   +----+----+
         |             |             |             |
    +----v----+   +----v----+   +----v----+   +----v----+
    | DMA Ch0 |   | DMA Ch1 |   | DMA Ch2 |   | DMA Ch3 |
    +---------+   +---------+   +---------+   +---------+
```

**Queue Shapers**:
- **4 Credit-Based Shapers** (CBS) - IEEE 802.1Qav compatible
- **4 Time-Based Shapers** (TAS) - for time-triggered deterministic traffic
- Each queue can use both shapers individually enabled/disabled [^114^]

### 4.4 Packet Filtering

> **Quote from Infineon LETH Training:**
> "The main advantage is the unloading of the CPU SW Stacks by: Pre-processing of data traffic in HW (no SW load). Three levels of filters: MAC addresses, VLAN Tags and PCP, Ethernet protocols AVB, PTP, TCP/UDP/IP. Unicast and Multicast. Bridging function" [^114^]

**Filter Levels**:
1. **L2 MAC Address Filtering**: Destination/Source MAC address matching
2. **VLAN Filtering**: VLAN tag presence, VLAN ID, Priority Code Point (PCP)
3. **Protocol Filtering**: AVB, PTP, TCP/UDP/IP protocol identification
4. **Unicast/Multicast**: Separate handling of unicast and multicast frames

### 4.5 Timestamp Unit (IEEE 802.1AS)

> **Quote from Infineon LETH Training:**
> "Time Stamp Unit for IEEE 802.1AS: HW unit for IEEE 802.1AS (PTP) - Required for clock synchronization - Supports master and slave mode - Supports 1-step time stamp" [^114^]

| Feature | Value |
|---------|-------|
| **Protocol** | IEEE 802.1AS (gPTP) / IEEE 1588 PTP |
| **Operation modes** | Master and Slave |
| **Timestamp method** | 1-step timestamp |
| **Timestamp resolution** | Hardware-based, high precision |
| **Integration** | Timestamp values written to DMA descriptors |

**Note**: The errata sheet documents that PTP time synchronization among all LETH0 MAC ports is missing (LETH_TC.010), indicating a limitation in multi-port timestamp correlation [^41^].

---

## 5. PHY Interfaces

### 5.1 MII (Media Independent Interface)

The MII interface provides a standard 4-bit parallel data path between the LETH MAC and external PHY.

**MII Signal Mapping (from TC4Dx datasheet)** [^282^]:

| Signal | Direction | Description |
|--------|-----------|-------------|
| LETHx_Pn_MII_TXD[3:0] | Output | Transmit data (4-bit nibble) |
| LETHx_Pn_MII_RXD[3:0] | Input | Receive data (4-bit nibble) |
| LETHx_Pn_TXCLK | Output/Input | Transmit clock (2.5 MHz @ 10 Mbps, 25 MHz @ 100 Mbps) |
| LETHx_Pn_RXCLK | Input | Receive clock (from PHY) |
| LETHx_Pn_MII_RXDV | Input | Receive data valid |
| LETHx_Pn_MII_CRS | Input | Carrier sense |
| LETHx_Pn_MDC | Output | Management data clock |
| LETHx_Pn_MDIO | I/O | Management data I/O |

**Multiple Port Instances**:
The TC4Dx supports multiple LETH ports (P0, P1, P2, P3) with signals mapped to different GPIO ports:
- **LETH0_P0_xxx**: Port 0 signals (mapped to P16, P20, P21 pins)
- **LETH0_P1_xxx**: Port 1 signals (mapped to P22, P23, P25, P30 pins)
- **LETH0_P2_xxx**: Port 2 signals (mapped to P10, P13, P14 pins)
- **LETH0_P3_xxx**: Port 3 signals (mapped to P13, P14, P15 pins)

Each port can be mapped to multiple pin alternatives (A, B, C, D) for flexible PCB layout.

### 5.2 RMII (Reduced Media Independent Interface)

RMII reduces pin count by using a 2-bit data path and a shared reference clock.

**RMII Signal Mapping** [^282^]:

| Signal | Direction | Description |
|--------|-----------|-------------|
| LETHx_Pn_RMIIn_TXD[1:0] | Output | Transmit data (2-bit) |
| LETHx_Pn_RMIIn_RXD[1:0] | Input | Receive data (2-bit) |
| LETHx_Pn_REFCLK | Input | 50 MHz reference clock (shared TX/RX) |
| LETHx_Pn_RMII_CRSDV | Input | Carrier sense / Receive data valid |
| LETHx_Pn_TXEN | Output | Transmit enable |
| LETHx_Pn_MDC | Output | Management data clock |
| LETHx_Pn_MDIO | I/O | Management data I/O |

**RMII vs MII Pin Savings**:
| Interface | Data Pins | Clock Pins | Control Pins | Total (excl. MDIO) |
|-----------|-----------|------------|--------------|-------------------|
| MII | 8 (TXD[3:0]+RXD[3:0]) | 2 (TXCLK+RXCLK) | 2 (CRS+RXDV) | 12 |
| RMII | 4 (TXD[1:0]+RXD[1:0]) | 1 (REFCLK) | 1 (CRSDV) | 6 |

RMII saves approximately **50% of pins** compared to MII.

### 5.3 10BASE-T1S 3-Pin (TC14) Interface

When operating in 10BASE-T1S mode, the LETH uses its integrated digital PHY with the TC14 interface:

| Signal | Pin Name | Description |
|--------|----------|-------------|
| TX | LETHx_Pn_TXD | TC14 transmit data / command output |
| RX | LETHx_Pn_RXD | TC14 receive data input |
| ED | LETHx_Pn_ED | Energy detection / collision input |

**Note**: In TC14 mode, the MII/RMII data pins are repurposed for the 3-pin interface. The external PMD transceiver handles all analog signaling (DME encoding, line driving, collision detection).

### 5.4 MDIO Management Interface

The MDIO interface is used to configure external PHYs or the integrated 10BASE-T1S digital PHY:
- **MDC clock**: Up to 2.5 MHz (standard), higher rates optionally supported
- **MDIO data**: Bidirectional serial data
- **PHY address**: TC14 PMD transceivers respond to PHYAD 0x01 [^306^]

---

## 6. Supported Protocols

### 6.1 TSN Support Summary

> **Quote from AURIX TC4x TSN Guide:**
> "英飞凌的AURIXTM TC4x支持定时同步和CBS这些时间敏感网络最重要的功能"
> (Infineon's AURIX TC4x supports the most important TSN functions: timing synchronization and CBS) [^30^]

**LETH TSN Feature Comparison** (compiled from multiple sources) [^30^][^77^]:

| IEEE Standard | Standard Name | GETH | LETH |
|---------------|---------------|------|------|
| **IEEE 802.1AS/AS-2020** | Timing and Synchronization (gPTP) | Yes | Yes |
| **IEEE 802.1Qav** | Credit-Based Shaper (CBS) | Yes | Yes |
| **IEEE 802.1Qbv** | Time-Aware Shaper (TAS/EST) | Yes | Yes |
| **IEEE 802.1Qbu** | Frame Preemption | Yes | **No** |
| **IEEE 802.1Qci** | Filtering and Policing | Partial | Partial |
| **IEEE 802.1CB** | Frame Replication and Elimination (FRER) | SW-based | SW-based |

> **Quote from TC4x TSN Guide comparison table:**
> "IEEE 802.1Qbu: Frame Preemption - 是/否" (Yes/No - LETH does NOT support Frame Preemption) [^30^]

### 6.2 IEEE 802.1AS - Timing and Synchronization

LETH supports **IEEE 802.1AS-2020** (gPTP) for precise clock synchronization:

- Hardware timestamp unit for PTP event messages
- 1-step timestamp mode (timestamp inserted in hardware)
- Master and slave mode support
- Time synchronization accuracy in microsecond range
- Required for TSN traffic scheduling (time-triggered transmission)

> **Quote from Infineon LETH Training:**
> "HW unit for IEEE 802.1AS (PTP) - Required for clock synchronization - Supports master and slave mode - Supports 1-step time stamp" [^114^]

**Known Limitation**: The TC4Dx errata notes "Missing PTP time sync concept among all LETH0 MAC ports" (LETH_TC.010), indicating that timestamp synchronization across multiple LETH ports may require software management [^41^].

### 6.3 IEEE 802.1Qav - Credit-Based Shaper (CBS)

CBS provides traffic shaping on the two highest-priority queues:

> **Quote from Microchip GMAC documentation (same IP family):**
> "A credit-based shaping algorithm is available on the two highest priority queues and is defined in the standard 802.1Qav: Forwarding and Queuing Enhancements for Time-Sensitive Streams. This allows traffic on these queues to be limited and to allow other queues to transmit." [^52^]

**CBS Operation**:
- Each shaper maintains a **credit counter** (measured in bytes)
- Credit accumulates at **IdleSlope** rate when waiting
- Credit decrements at **sendSlope** (= portTransmitRate - IdleSlope) during transmission
- Queue can only transmit when credit is non-negative
- Maximum IdleSlope for 100 Mbps: 100 Mbps / 4 = 0x17D7840 [^52^]

> **Quote from Infineon LETH Training:**
> "4 Credit Based Shaper - IEEE 802.1Q compatible - 4 Time Based Shapers - For time triggered deterministic traffic - Each queue provides both shapers - Each shaper can be enabled/disabled individually" [^114^]

**LETH CBS Errata Note**: The TC4Dx errata documents a defect where "CBS credit not decremented during the IPG phase of transmission" (LETH_AI.005). The credit is decremented only up to the last byte of FCS, then incremented during the IPG. This results in ~2.65% additional bandwidth consumption for a stream of 128-byte packets at 30% programmed bandwidth [^41^].

### 6.4 IEEE 802.1Qbv - Time-Aware Shaper (TAS)

The Time-Aware Shaper (also called Enhancements for Scheduled Traffic, EST) enables time-triggered transmission:

> **Quote from Infineon LETH Training:**
> "4 Time Based Shapers - For time triggered deterministic traffic" [^114^]

- Gate Control List (GCL) defines gate open/close schedules
- Frames are transmitted only when their queue's gate is open
- Enables deterministic, jitter-free transmission for critical traffic
- Guard band prevents frame transmission from overrunning into closed windows

**LETH TAS Errata Note**: "Time Aware Shaper (TAS) additional IPG in case of back-to-back packet transmission" (LETH_AI.008). Extra IPG of up to 12 clock cycles of the slower clock can occur due to CDC delays between fLETH and MAC Transmitter clock domains [^41^].

### 6.5 Frame Preemption Limitations

**LETH does NOT support IEEE 802.1Qbu Frame Preemption.**

Frame preemption allows:
- Express (time-critical) frames to interrupt preemptable (best-effort) frames
- Reduced latency for scheduled traffic
- Requires specialized MAC (pMAC + eMAC) support

> **Quote from TC4x TSN comparison:**
> "IEEE 802.1Qbu: Frame Preemption - 是/否" (GETH: Yes / LETH: No) [^30^]

This is a key differentiator from GETH, which supports frame preemption. For LETH applications requiring very low latency, the Time-Aware Shaper (802.1Qbv) can be used instead to reserve time slots for critical traffic.

### 6.6 Other Supported Features

| Feature | Support | Notes |
|---------|---------|-------|
| **IEEE 802.1Q VLAN** | Yes | VLAN tagging, VLAN filtering |
| **IEEE 1588 PTP** | Yes | Hardware timestamping |
| **Unicast/Multicast filtering** | Yes | MAC-level address filtering |
| **TCP/UDP/IP checksum** | Yes | Offload support |
| **CRC generation/checking** | Yes | Automatic |
| **Padding** | Yes | Automatic pad to 64 bytes |

---

## 7. Use Cases

### 7.1 Low-Speed ECU Communication

LETH enables Ethernet connectivity for traditional low-bandwidth ECUs:
- **Body control modules**: Door controllers, seat controllers, mirror controllers
- **Climate control**: HVAC controllers, temperature sensors
- **Lighting**: LED headlight controllers, ambient lighting
- **Comfort systems**: Window lifters, sunroof controllers

> **Quote from Infineon:**
> "10Base-T1S Ethernet gives customers the performance, throughput, and flexibility needed to implement new automotive-specific microcontrollers with E/E architectures." [^302^]

### 7.2 Sensor and Actuator Networks

10BASE-T1S is ideal for sensor/actuator networks in zonal architectures:
- **Environmental sensors**: Temperature, humidity, pressure
- **Position sensors**: Door position, seat position, steering angle
- **Actuator control**: Motor drivers, valve controllers, pump controllers
- **Switch monitoring**: Button panels, switch matrices

### 7.3 Firmware Over-the-Air (FOTA) Updates

> **Quote from Infineon LETH Training:**
> "Firmware updates in cars can make use of Ethernet to exchange data much faster compared to other existing communication interfaces. The Lite Ethernet MAC allows with the high-speed data transfer to update multiple ECUs in parallel in a car." [^114^]

LETH enables faster firmware updates than CAN-based flashing:
- 10 Mbps Ethernet vs. 1 Mbps CAN = ~10x faster raw data rate
- IP-based protocols allow parallel updates to multiple ECUs
- DoIP (Diagnostic over IP) standard support

### 7.4 Zonal Architecture Edge Nodes

In zonal E/E architectures, LETH serves as the edge network interface:

```
    +------------------+        +------------------+        +------------------+
    |   Central HPC    |<------>|   Zonal Gateway  |<------>|   Edge Nodes     |
    |   (GETH 5Gbps)   |        |   (GETH+LETH)    |        |   (LETH 10/100)  |
    +------------------+        +------------------+        +------------------+
                                       |                            |
                                       | 100BASE-T1/1000BASE-T1     | 10BASE-T1S
                                       v                            v
                              +------------------+        +------------------+
                              |   CAN/CAN-XL     |        |  Sensors/Actuators|
                              |   (Legacy bridge)|        |  (10 Mbps shared) |
                              +------------------+        +------------------+
```

### 7.5 Service-Oriented Communication (SOME/IP)

LETH supports SOME/IP for service-oriented architectures:
- Event-driven communication model
- Service discovery and subscription
- Efficient serialization/deserialization
- Compatible with AUTOSAR Adaptive Platform

---

## 8. Differences from GETH

### 8.1 Feature Comparison Table

| Feature | **GETH (Gigabit Ethernet)** | **LETH (Lite Ethernet)** |
|---------|---------------------------|------------------------|
| **Number of ports** | Up to 2 instances | Up to 4 instances |
| **Maximum speed** | 5 Gbps (with USXGMII/SerialGMII) | 100 Mbps |
| **10 Mbps support** | Yes (full/half duplex) | Yes (with 10BASE-T1S) |
| **100 Mbps support** | Yes (full duplex) | Yes (MII/RMII) |
| **1 Gbps support** | Yes | No |
| **2.5/5 Gbps support** | Yes | No |
| **10BASE-T1S** | No | **Yes (integrated digital PHY)** |
| **MII interface** | Yes | Yes |
| **RMII interface** | Yes | Yes |
| **RGMII interface** | Yes (via HSPHY) | No |
| **USXGMII/SerialGMII** | Yes | No |
| **Frame Preemption (802.1Qbu)** | Yes | **No** |
| **CBS (802.1Qav)** | Yes | Yes |
| **TAS (802.1Qbv)** | Yes | Yes |
| **802.1AS gPTP** | Yes | Yes |
| **Tx Queues** | 8 queues | 4 queues |
| **Rx Queues** | 8 queues | 4 queues |
| **Tx FIFO** | 32 KB | 16 KB |
| **Rx FIFO** | 16 KB | 8 KB |
| **Ethernet Bridge** | Yes | No |
| **MACsec** | Yes (with CSS HW accel) | Limited |
| **TSN Filtering (802.1Qci)** | Partial | Partial |
| **Target use case** | High-speed backbone | Low-speed edge nodes |
| **Power consumption** | Higher | Lower |
| **Cost per channel** | Higher | Lower |

### 8.2 Architecture Differences

**GETH Architecture**:
- High-performance MAC with 64-bit DMA master interface
- 8 transmit/receive queues with 32 KB/16 KB FIFO
- Supports Ethernet Bridge (MAC-to-MAC forwarding)
- Full TSN support including Frame Preemption (802.1Qbu)
- Connects to high-speed PHYs via RGMII/SerialGMII/USXGMII

**LETH Architecture**:
- Streamlined MAC optimized for 10/100 Mbps
- 4 transmit/receive queues with 16 KB/8 KB FIFO
- No Ethernet Bridge function
- TSN support (CBS + TAS) but no Frame Preemption
- Built-in 10BASE-T1S digital PHY (TC14 interface)
- Lower power and area footprint

### 8.3 When to Use LETH vs GETH

| Use Case | Recommended | Reason |
|----------|-------------|--------|
| High-speed sensor fusion (cameras, lidar) | GETH | >1 Gbps bandwidth needed |
| Backbone communication between HPCs | GETH | 5 Gbps with low latency |
| ADAS data processing pipeline | GETH | High throughput + TSN |
| Body control module networking | LETH | 10-100 Mbps sufficient |
| Sensor/actuator edge network | LETH | Cost-optimized, 10BASE-T1S |
| Door/seat/climate ECUs | LETH | Low-speed, multidrop capable |
| Diagnostic/DoIP gateway | LETH | Standard Ethernet sufficient |
| FOTA update distribution | LETH | Adequate bandwidth |

---

## 9. Errata and Known Issues

The TC4Dx errata sheet documents several LETH-specific issues [^41^]:

| Issue ID | Title | Impact |
|----------|-------|--------|
| **LETH_AI.003** | 10BT1S Delayed transmission after TO starts as follower | Transmission timing issue |
| **LETH_AI.004** | Long COMMIT without TRANSMIT | Extra COMMIT symbols delay next node |
| **LETH_AI.005** | CBS credit not decremented during IPG | ~2.65% extra bandwidth consumed |
| **LETH_AI.008** | TAS additional IPG in back-to-back TX | Extra inter-packet gap |
| **LETH_AI.014** | 10BT1S Incorrect encoding of first bit after TX command | Packet transmission failure |
| **LETH_AI.015** | Unintended dropping of next received packet | Data loss on corrupted symbols |
| **LETH_AI.022** | 10BT1S Coordinator transmits packet without BEACON | Network sync loss |
| **LETH_TC.010** | Missing PTP time sync among LETH0 MAC ports | Multi-port timestamp limitation |

---

## 10. Summary

The **LETH (Lite Ethernet)** module in the AURIX TC4x provides a purpose-built, cost-optimized Ethernet MAC solution for automotive low-speed communication. Its key differentiators are:

1. **Four independent 10/100 Mbps MAC instances** - more ports than GETH for edge connectivity
2. **Integrated 10BASE-T1S digital PHY** - unique capability for multidrop, low-speed Ethernet
3. **OPEN Alliance TC14 3-pin interface** - minimal pin count for 10 Mbps communication
4. **PLCA support** - deterministic bus access for up to 8 nodes on shared medium
5. **TSN support (CBS + TAS + 802.1AS)** - real-time communication without the overhead of GETH
6. **Lower power and cost** compared to GETH, suitable for resource-constrained ECUs

LETH enables the transition from traditional CAN/LIN networks to a unified Ethernet-based in-vehicle network, bringing IP-based communication, security (MACsec), and service-oriented architectures to the entire vehicle, from high-performance computers down to simple sensor/actuator nodes.

---

## 9. References

| Ref | Document | Source |
|-----|----------|--------|
| [^14^] | Infineon AURIX TC4x Product Page | infineon.com |
| [^19^] | AURIX TC4x Overview Presentation | Infineon |
| [^20^] | AURIX TC4x Architecture | Infineon |
| [^30^] | AURIX TC4x TSN Guide (Chinese) | Infineon China |
| [^41^] | TC4Dx AB ES Errata Sheet | Infineon |
| [^77^] | GETH Feature List | Infineon Documentation |
| [^110^] | Automotive Ethernet and TC4x Overview (Chinese) | Infineon |
| [^112^] | AURIX TC4x Ethernet/TSN Overview | EEPW China |
| [^114^] | LETH Lite Ethernet Training v1.0 | Infineon |
| [^282^] | TC4Dx A-step COM Datasheet | Infineon |
| [^301^] | IEEE 802.3cg CFI Presentation | IEEE 802.3 |
| [^302^] | 10BASE-T1S Automotive Ethernet Basics | Peak Systems |
| [^303^] | 10BASE-T1S Technical Details | Macnica |
| [^305^] | NXP 10BASE-T1S Transceivers | All About Circuits |
| [^306^] | OPEN Alliance TC14 PMD Transceiver Interface | OPEN Alliance |
| [^308^] | 10BASE-T1S Ethernet PHY | Graniteriverlabs |
| [^313^] | AURIX TC4xx Software Solutions | Hitex |
| [^386^] | 10BASE-T1S Game-Changing Network | DLab.ie |
| [^388^] | Multi-drop PLCA Technical Article | Intrepidcs |
| [^392^] | 10BASE-T1S PLCA Technical Explanation | NSC Japan |
| [^394^] | Enabling TAS on Half-Duplex Ethernet | IEEE Standards |
| [^398^] | Small Footprint MII/RMII 10/100 Ethernet | Microchip |
