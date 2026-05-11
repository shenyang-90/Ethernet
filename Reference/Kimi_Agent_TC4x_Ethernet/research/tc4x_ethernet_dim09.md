# Dimension 9: DRE - Data Routing Engine

## Executive Summary

The **Data Routing Engine (DRE)** is a dedicated hardware accelerator in the Infineon AURIX TC4x microcontroller family designed to perform autonomous data routing between CAN, Ethernet, and memory interfaces without CPU intervention. The DRE represents a significant architectural advancement for automotive gateway and zone controller applications, offering up to **50% performance improvement** versus TriCore software-based routing, while reducing routing latency and jitter by **70-80%** [^25^][^429^]. Working in conjunction with the CAN Routing Engine (CRE), the DRE enables hardware-accelerated protocol translation between IEEE 1722 AVTP encapsulation and native CAN frames, supporting the demanding requirements of modern automotive E/E architectures [^219^][^399^].

---

## 1. DRE Overview

### 1.1 Purpose and Role

The DRE is a **hardware accelerator** used to route Controller Area Network (CAN) frames and Ethernet frames. As defined in Infineon's official documentation:

> "The DRE routes CAN frames between Ethernet interfaces. Additionally, it can assist in routing CAN frames from one CAN interface to another CAN interface or to a user-configured memory location, and in forwarding Ethernet frames between Ethernet interfaces." [^219^]

The DRE is specifically aligned to the **AVTP Control frame format defined by IEEE 1722-2016**, enabling seamless integration with automotive Audio Video Transport Protocol (AVTP) networks [^219^][^216^].

### 1.2 Performance Improvement

According to Infineon's official product presentations and technical documentation:

| Metric | Value | Source |
|--------|-------|--------|
| Performance improvement vs TriCore | Up to 50% | [^25^] |
| Latency and jitter reduction | Up to 70-80% | [^429^] |
| Routing latency improvement | Up to 700% (key path) | [^449^] |
| CPU load reduction | Significant (hardware offload) | [^5^] |

From the AURIX TC4x Overview presentation:

> "AURIX™ Accelerator Suite: DRE - Up to 50% more performance vs. TriCore™" [^25^]

> "TC4xx DRE/CRE routing accelerators: Reduces SW processing load of data transmission. Increase performance and throughput by up to 50% vs TriCore™ by reducing routing latency and jitter." [^25^]

From the Rutronik product introduction:

> "Data routing driver minimize latency (by 70-80%) and CPU load" [^429^]

### 1.3 Key Terminology (per IEEE 1722-2016)

The DRE uses the following notations from the IEEE 1722-2016 standard [^219^]:

- **AVTP frame**: An Ethernet frame containing Audio Video Transport Protocol
- **ACF (AVTP Control Format) frame**: An AVTP frame containing control frames
- **ACF_CAN_BRIEF message**: CAN frames contained within an ACF frame
- **NTSCF**: Non-Time-Synchronous Control Format header

### 1.4 Customer Benefits

As summarized in Infineon's DRE training document [^216^]:

> "Accelerates the data routing between different communication modules and protocol translation between different message formats. Offloads the CPU(s) while the routing is performed by the dedicated hardware module."

---

## 2. Routing Capabilities

### 2.1 Summary of Routing Types

The DRE supports three primary routing categories [^216^][^399^]:

1. **CAN-to-Ethernet**: Routes CAN frames to Ethernet using IEEE 1722 ACF encapsulation
2. **CAN-to-CAN**: Assists CRE in routing CAN frames between different MCMCAN modules
3. **CAN-to-Memory**: Routes received CAN frames to configurable internal memory locations
4. **Ethernet-to-Ethernet**: Forwards Ethernet frames between Ethernet interfaces (via Forwarding Engine)

### 2.2 CAN-to-CAN Frame Routing

The DRE assists the CAN Routing Engine (CRE) to perform CAN frame transfers between CAN interfaces belonging to **different MCMCAN modules**. Key characteristics:

- TC4x supports **5 MCMCAN modules**, each with **4 CAN nodes**, totaling **20 CAN channels** [^402^][^413^]
- CRE triggers the DRE module when a pending CAN frame exists in the Rx Host Buffer waiting to be routed to a CAN interface in a different MCMCAN module [^216^]
- DRE acts as an **SPB master** and performs routing from the Rx Host Buffer of the source CAN interface to the Tx Host Buffer of the destination CAN interface [^216^]
- Intra-module CAN-to-CAN routing is handled directly by CRE; inter-module routing requires DRE assistance

> "CRE triggers the DRE module once there is a pending CAN frame in the Rx Host Buffer waiting to be routed to the CAN interface belonging to the different MCMCAN module. DRE acts as a SPB master and performs the routing of the CAN frame from the Rx Host Buffer of the source CAN interface to the Tx Host Buffer of the destination CAN interface." [^216^]

### 2.3 CAN-to-Memory Frame Routing

The DRE assists CRE to perform routing of received CAN frames to configurable internal memory address locations [^216^]:

- **Up to 28 different destination memory regions** can be defined by the user
- Users can create a **circular list of virtual CAN buffers** in destination memory
- **Automatic memory address increment and wrap around**
- **User-configured watermark interrupt generation** for CPU notification

Each virtual CAN buffer contains up to three elements [^216^]:
1. **Destination memory status information** (optional)
2. **Timing header** (intrusion detection and timestamp information) (optional)
3. **CAN frame with the respective payload data**

### 2.4 CAN-to-Ethernet Routing (IEEE 1722 Encapsulation)

The DRE's most important function is routing CAN frames to Ethernet frames. This involves:

- Encapsulation using **ACF (AVTP Control Format)** as defined in IEEE 1722-2016 [^402^][^413^]
- Support for **Non-Time-Synchronous Control Format header (NTSCF)** [^216^]
- Support for **Abbreviated CAN/CAN FD message type (ACF_CAN_BRIEF)** [^216^]
- The sending DRE encapsulates CAN messages into ACF format; the receiving side extracts CAN messages from the Ethernet packets [^402^]

#### 2.4.1 Ethernet Transmit Trigger Modes

The DRE supports **four different Ethernet transmit trigger modes** [^216^]:

| Trigger Mode | Description |
|-------------|-------------|
| **Frame count transmit mode** | Transmit after accumulating a configured number of frames |
| **Buffer fill level-based transmit mode** | Transmit based on buffer fill level threshold |
| **Time-Triggered transmit mode** | Transmit at configured time intervals |
| **Software-triggered transmit mode** | Transmit triggered explicitly by software |

#### 2.4.2 Ethernet Header Configuration

- Optional user configuration for **Ethernet 802.3 MAC header** [^216^]
- Optional **802.1Q Tag field** (VLAN tagging) corresponding to ACF frames contained in Layer 2 Ethernet frame [^216^]
- Configurable **AVTP Stream-ID** [^455^]

#### 2.4.3 CAN Frame Filtering

- **Classical ID filter mode** for filtering CAN frames tunneled over Ethernet [^216^]
- **CAN-ID based CAN interface destination search** [^455^]
- User-configured **CAN Routing Table** to identify destination CAN interface for CAN frames tunneled over Ethernet [^455^]

### 2.5 Multi-Cast Support

The DRE supports multi-cast routing to multiple destinations [^455^]:

- **1:1 uni-cast routing** and **1:4 multi-cast Ethernet-to-CAN routing**
- **1:1 uni-cast** or **1:6 multi-cast forwarding** of Ethernet frames between interfaces

> "Supports 1:1 uni-cast routing and 1:4 multi-cast Ethernet to CAN routing" [^455^]
> "Supports 1:1 uni-cast or 1:6 multi-cast forwarding of Ethernet frames between interfaces" [^455^]

---

## 3. Ethernet-Specific Features

### 3.1 IEEE 1722 AVTP Encapsulation

The DRE is aligned to the **AVTP Control frame format defined by IEEE 1722-2016** [^219^]. The encapsulation process:

1. CAN frames are encapsulated into **ACF_CAN_BRIEF** messages
2. Multiple ACF messages can be aggregated into a single **NTSCF** (Non-Time-Synchronous Control Format) header
3. The NTSCF frame is then encapsulated in a standard Ethernet frame with configurable Layer 2 headers

From the HotChips presentation:

> "CAN-to-Ethernet routing (EEE: 1722 support). Multi-cast up to 4 destinations." [^5^]

This confirms **Energy Efficient Ethernet (EEE) support** alongside IEEE 1722 encapsulation.

### 3.2 Packet Formatting and Encapsulation

The **ACF CAN - Ethernet Format Engine** performs the translation of CAN frames to ACF frame format and vice versa [^399^]. Key formatting capabilities:

- Automatic ACF_CAN_BRIEF message construction from CAN frame data
- NTSCF header generation for non-time-synchronous transport
- Configurable Ethernet MAC header (Layer 2) for transmitted ACF frames [^455^]
- Support for 802.1Q VLAN tagging

### 3.3 Ethernet Descriptor Handling

The DRE includes an **Ethernet Descriptor Handler** that [^399^]:

- Maintains Ethernet Transmit (Tx) and Receive (Rx) descriptors
- Descriptors are used by Ethernet DMA or software to transmit/receive Ethernet frames
- Provides **automatic Ethernet DMA transmit and receive descriptor handling** [^455^]

### 3.4 Frame Storage to Memory

Routed frames can be stored in the DRE's **central message storage RAM** (Message RAM) which buffers both CAN frames and Ethernet frames [^399^]. The SRI slave interface allows direct software access to monitor the Message RAM [^216^].

---

## 4. CANXL Integration

### 4.1 CANXL Module Overview

The TC4x includes a dedicated **CANXL interface** separate from the MCMCAN modules [^465^]:

- Classical CAN, CAN FD, and **CAN XL communication** per ISO 11898-1:2024
- **CAN XL payload size of up to 2048 data bytes**
- CAN XL communication baud rate up to **20 Mbits/s**
- Hardware-based **64-bit time stamping**
- Integrated **DMA for message transfers without CPU load**

### 4.2 CANXL-to-Ethernet Routing via DRE

The DRE works in conjunction with the CANXL module to enable CANXL-to-Ethernet routing. Key aspects:

- CANXL frames are routed through the DRE using the same IEEE 1722 ACF encapsulation mechanism as CAN/CAN FD frames [^472^][^473^]
- The large payload (2048 bytes) of CANXL is handled through the DRE's buffering and segmentation mechanisms
- **Integrated DMA** in the CANXL module works with the DRE for zero-copy message transfers [^465^]

From Infineon's technical documentation:

> "For gateway controller developers, this is an interesting new feature. TC4XX adds a data routing module DRE for routing data between Ethernet and CAN, or between CAN and CAN. The DRE uses the AVTP control frame format defined by IEEE 1722-2016 for alignment." [^472^]

### 4.3 Protocol Conversion for Large Payloads

The DRE handles the protocol conversion between CANXL's large 2048-byte payloads and Ethernet frames:

- CANXL data is encapsulated using the ACF format
- For payloads exceeding standard Ethernet MTU, the DRE works with the Ethernet MAC's support for jumbo frames
- The **ACF_CAN_BRIEF** message format can accommodate the full CANXL payload

---

## 5. Hardware Architecture

### 5.1 DRE Block Diagram Components

The DRE hardware consists of the following core elements [^399^]:

```
+------------------------+     +---------------------+
|  MCMCAN Modules        |     |  Ethernet MACs      |
|  (CAN/CAN FD)          |     |  (GETH/LETH)        |
+-----------+------------+     +----------+----------+
            |                             |
            v                             v
+-----------+------------+   +------------+-----------+
|   Routing Control Unit |   | Ethernet Descriptor    |
|   (RCU)                |   | Handler (EDH)          |
+-----------+------------+   +------------+-----------+
            |                             |
            v                             v
+-----------+----------------------------+-----------+
|              Central Message RAM                    |
|         (buffers CAN + Ethernet frames)             |
+-----------------------------------------------------+
            |
            v
+-----------+------------+   +------------------------+
| ACF CAN-Ethernet       |   | CAN Transmit Routing   |
| Format Engine          |   | Engine                 |
+-----------+------------+   +-----------+------------+
            |                             |
            v                             v
+-----------+------------+   +------------+-----------+
| Forwarding Engine      |   | Routing Table          |
| (with Forwarding Table)|   | (user-configured)      |
+------------------------+   +------------------------+
```

### 5.2 Core Hardware Elements

#### 5.2.1 Central Message Storage RAM

> "The DRE contains a central message storage RAM which buffers the CAN frames and the Ethernet frames." [^399^]

- Single-ported RAM for intermediate frame storage
- Accessible via SRI slave interface for software monitoring
- Provides buffering between different clock domains

#### 5.2.2 Routing Control Unit (RCU)

> "The Routing Control Unit assists in the transfer of received CAN frames from the MCMCAN module to the internal message RAM. The Routing Control Unit also transfers the CAN frame to the identified CAN interface for transmission." [^399^]

Key functions:
- Transfer received CAN frames from MCMCAN to Message RAM
- Transfer CAN frames to identified CAN interfaces for transmission
- Coordinate with CRE trigger signals

#### 5.2.3 ACF CAN-Ethernet Format Engine

> "The ACF CAN - Ethernet Format Engine performs the translation of CAN frames to ACF frame format and vice versa." [^399^]

- Encapsulates CAN/CAN FD/CANXL frames into IEEE 1722 ACF format
- De-encapsulates ACF frames from Ethernet back to CAN format
- Handles NTSCF header generation and parsing

#### 5.2.4 CAN Transmit Routing Engine

> "The CAN Transmit Routing Engine, along with a user-configured Routing Table, decides the destination CAN interface from which a CAN frame has to be transmitted." [^399^]

- Uses user-configured **Routing Table** for destination selection
- Supports CAN-ID based destination search
- Coordinates with RCU for frame transfer

#### 5.2.5 Ethernet Descriptor Handler

> "The Ethernet Descriptor Handler maintains the Ethernet Transmit (Tx) and Receive (Rx) descriptors which will then be used by Ethernet DMA or the software to transmit or receive Ethernet frames." [^399^]

- Automatic DMA descriptor management
- Interfaces with both GETH and LETH DMA channels

#### 5.2.6 Forwarding Engine

> "The Forwarding Engine, along with a user-configured Forwarding Table, decides the destination Ethernet interface(s) to which the Ethernet frame has to be forwarded." [^399^]

- Supports 1:1 uni-cast and 1:6 multi-cast forwarding [^455^]
- Uses user-configured **Forwarding Table** (FTCFG)
- Handles Ethernet-to-Ethernet frame forwarding

### 5.3 System Integration

The DRE integrates with the TC4x system through multiple interfaces [^216^]:

| Interface | Type | Function |
|-----------|------|----------|
| **SPB Master** | Bus Master | Fetch and route CAN frames from/to MCMCAN modules |
| **SRI Master** | Bus Master | Fetch and route CAN/Ethernet frames from/to internal memory |
| **SRI Slave** | Bus Slave | Direct software access to monitor Message RAM |
| **CRE Interface** | Direct trigger | Direct trigger signals - no CPU intervention needed |
| **Interrupt Router** | Interrupt output | Schedules service requests from DRE interrupt sources |

### 5.4 Non-Starving Arbitration

The DRE implements fair arbitration mechanisms:

> "Provides non-starving arbitration between routing transfer requests" [^455^]
> "Provides non-starving arbitration between routing and forwarding requests" [^455^]

This ensures that no single routing path can monopolize the DRE resources, providing deterministic latency for all routing operations.

### 5.5 Error Handling and Monitoring

The DRE provides **error monitoring mechanisms for accelerated detection of faults** [^455^]. Specific error handling features identified in the TC4Dx errata sheet include [^41^]:

- **Watchdog timer**: DRE includes a watchdog timer feature that triggers timeout interrupts if operations don't complete within the configured period
- **SPB bus transaction error interrupt**: Triggered when SPB bus errors occur during multi-cast routing
- **DMA status polling**: Monitors DMA_CHy_Status register bits (TBU, FBE) for Tx descriptor errors
- **Error status registers**: ME_FESRCA register for identifying erroneous multi-cast requests; ME_SRCA for currently processed requests
- **ME_ERR.FEDID field**: Provides index information for error debugging

Errata sheet notes on error handling [^41^]:

> "There is an error interrupt triggered by the DRE during an SPB bus transaction error. The software shall identify the erroneous multi-cast request on the ME_FESRCA register and read the routing header and ME_ERR.FEDID to determine the index of the error."

> "Another possible option is to use the watchdog timer feature of DRE instead of DMA_CHy_Status polling feature. DRE will then trigger a timeout interrupt."

#### Known Errata (TC4Dx)

| Erratum | Description | Workaround |
|---------|-------------|------------|
| DRE_TC.001 | Pending requests in COBL_BPR0/1 cannot be cleared by software | None - read-only registers |
| DRE_TC.005 | ETH2CAN-ACF_CAN_ADDR field not being reset | None available |
| DRE_TC.006 | Inconsistency between GETH and LETH error interrupt triggering | Use LETH error interrupt to stop DRE Tx descriptor handler; or use DRE watchdog timer |
| DRE_TC.008 | Forwarding ID wrongly assembled for LETH | Set ELIRS bit to 0; construct FID based on EIF, DMACH, MADRM |

---

## 6. Software Interface

### 6.1 MCAL DRE Driver

The TC4x MCAL (Microcontroller Driver) includes a dedicated **DRE driver** classified under the **Connectivity** driver group [^313^]:

- **Safety claim**: ASIL B [^313^]
- **AUTOSAR version**: R20-11 [^313^]
- **Configuration tool**: EB tresos v29.2.1+ [^313^]
- MCAL drivers support virtualization and multicore allocation [^408^]

From the Hitex AURIX TC4xx Software Solutions document:

> "Connectivity ASIL B & DRE Data Routing" [^313^]

### 6.2 Configuration Tools

The DRE is configured through **EB tresos Studio** [^408^][^471^]:

- DRE configuration is integrated into the standard MCAL configuration workflow
- Configuration is performed via EB tresos GUI or through automated scripts
- The DRE driver configuration includes routing tables, forwarding tables, trigger modes, and filter settings
- Generated code is integrated with AUTOSAR BSW (Basic Software)

Configuration workflow [^408^]:
1. Configure MCAL (including DRE) in EB tresos
2. Generate MCAL configuration files
3. Export MCAL configuration in ARXML format
4. Import into BSW configuration tool
5. Generate BSW configuration files

### 6.3 Routing Table Setup

The DRE routing configuration involves setting up multiple user-configured tables:

#### CAN Routing Table
- Identifies the destination CAN interface for CAN frames tunneled over Ethernet
- Supports CAN-ID based destination search
- Configured through MCAL DRE driver in EB tresos

#### Forwarding Table (FTCFG)
- Used by the Forwarding Engine for Ethernet-to-Ethernet forwarding
- Contains Forwarding ID (FID) to identify destination Ethernet port
- Configured based on Ethernet interface parameters (EIF, DMACH, MADRM) [^41^]

#### Example Routing Configuration (from Gateway Demo)

The AURIX DriveCore Gateway demo provides example routing configurations [^476^]:

**CAN-to-CAN Routing:**
| Name | Type | CAN ID | CAN Type | Source | Destination |
|------|------|--------|----------|--------|-------------|
| Route_1005_CanToCanU | Unicast | 1005 | CAN 2.0 | CAN_Ctrl_0 | CAN_Ctrl_1 |
| Route_1008_CanToCanU | Unicast | 1008 | CAN FD | CAN_Ctrl_3 | CAN_Ctrl_4 |
| Route_1012_CanToCanM | **Multicast** | 1012 | CAN 2.0 | CAN_Ctrl_0 | CAN_Ctrl_1,3,4 |

**CAN-to-Memory Routing:**
| Name | Type | CAN ID | CAN Type | Source |
|------|------|--------|----------|--------|
| Route_1001_CanToMemU | Unicast | 1003 | CAN FD | CAN_Ctrl_3 |

**CAN-to-Ethernet (IEEE 1722) Routing:**
| Name | Type | Stream ID | CAN ID | CAN Type | Source | Destination |
|------|------|-----------|--------|----------|--------|-------------|
| Routing_1105_CanToEthU | Unicast | 103001 | 1005 | CAN 2.0 | CAN_Ctrl_0 | GETH0 |

**Ethernet-to-CAN (IEEE 1722) Routing:**
| Name | Type | Stream ID | CAN ID | CAN Type | Source | Destination |
|------|------|-----------|--------|----------|--------|-------------|
| Routing_1108_EthToCanU | Unicast | 103001 | 1108 | CAN FD | GETH0 | CAN_Ctrl_4 |

### 6.4 iLLD (Low-Level Driver) Support

The Infineon Low-Level Driver (iLLD) provides APIs for DRE configuration and control:

- DRE initialization and configuration functions
- Routing table programming APIs
- Interrupt service request handling
- Status and error monitoring functions

---

## 7. Use Cases

### 7.1 Zone Controller Data Aggregation

The DRE is a critical enabler for **zone controller architectures** in modern automotive E/E designs. A real-world example is the **Marelli Zone Control Unit** developed in collaboration with Infineon [^484^][^415^]:

> "The adoption of Infineon's AURIX™ TC4x microcontrollers in the Zones brings significant benefits to OEMs. The special data routing engine (DRE) within Infineon AURIX™ microcontrollers ensures extremely low latency levels when connecting CAN and Ethernet, enabling the Zones to consolidate numerous electronic computing units into a single piece of hardware." [^484^]

Zone controllers consolidate ECUs from multiple domains [^484^]:
- Lighting
- Body control
- Audio
- Power distribution
- Propulsion
- Thermal management
- Chassis control
- Vehicle diagnostics

### 7.2 CAN-Ethernet Gateway

The primary DRE use case is the **automotive gateway** application:

> "DRE module extends the gateway capabilities of the AURIX™ devices by performing protocol translation and data routing without CPU intervention." [^216^]

Gateway application advantages [^216^]:
- **Accelerated data routing and protocol translation**
- **CPU offloading**
- Support for protocol translation to Ethernet-based protocols beyond AVTP (e.g., SOME/IP) with CAN-to-memory routing capability

### 7.3 Sensor Data Routing

The DRE enables efficient routing of sensor data:

- CAN sensor data can be routed to Ethernet for aggregation at domain controllers
- Time-triggered transmit mode enables deterministic sensor data delivery
- Watermark interrupts notify the CPU when memory buffers reach configurable thresholds
- The intrusion detection timing header option supports security monitoring of sensor data

### 7.4 PPU Data Movement

The DRE also assists in shuttling data between the **Parallel Processing Unit (PPU)** and other subsystems:

> "A Data Routing Engine (DRE) is included in the TC4x architecture to facilitate efficient data movement between the PPU, main memory, and other peripherals." [^401^]

---

## 8. Comparison: CRE vs DRE

| Feature | CRE (CAN Routing Engine) | DRE (Data Routing Engine) |
|---------|------------------------|--------------------------|
| Location | Inside MCMCAN module | Standalone hardware module |
| Intra-module CAN-to-CAN | Yes (direct) | No |
| Inter-module CAN-to-CAN | Assists (triggers DRE) | Yes (performs routing) |
| CAN-to-Ethernet | No | Yes (IEEE 1722 ACF) |
| Ethernet-to-CAN | No | Yes (de-encapsulation) |
| CAN-to-Memory | Assists (triggers DRE) | Yes (performs routing) |
| Ethernet-to-Ethernet | No | Yes (forwarding) |
| Bus interface | Internal to MCMCAN | SPB Master, SRI Master/Slave |
| Trigger mechanism | FIFO/Buffer triggers | CRE triggers, software triggers |

---

## 9. Key Specifications Summary

| Specification | Value |
|-------------|-------|
| CAN channels supported | Up to 20 (5 MCMCAN x 4 nodes) |
| CAN-to-CAN routing scope | Inter-MCMCAN module |
| CAN-to-Memory destinations | Up to 28 memory regions |
| Ethernet encapsulation | IEEE 1722-2016 AVTP/ACF/NTSCF |
| CAN message type in ACF | ACF_CAN_BRIEF |
| Ethernet-to-CAN multi-cast | 1:4 destinations |
| Ethernet-to-Ethernet multi-cast | 1:6 destinations |
| Ethernet trigger modes | 4 (frame count, fill level, time-triggered, software) |
| Arbitration | Non-starving |
| VLAN support | 802.1Q Tag configuration |
| AVTP Stream-ID | Configurable |
| DMA descriptor handling | Automatic |
| Performance improvement | Up to 50% vs TriCore |
| Latency reduction | 70-80% |
| Safety claim (MCAL) | ASIL B |
| CANXL payload support | Up to 2048 bytes |

---

## 10. References

### Primary Sources

[^1^]: Infineon AURIX TC4x Wiki - emmtrix Wiki - https://www.emmtrix.com/wiki/Infineon_AURIX_TC4x
[^5^]: Infineon HotChips TC4xx Presentation - Heterogeneous Computing - https://hc33.hotchips.org/assets/program/conference/day1/Heterogeneous%20computing%20to%20enable%20the%20highest%20level%20of%20safety%20in%20automotive%20systems_v1.2.pdf
[^19^]: AURIX TC4x Overview Product Presentation - https://www.infineon.cn/assets/row/public/documents/10/156/infineon-tc4x-overview-productpresentation-en.pdf
[^20^]: AURIX TC4x Overview - https://www.infineon.com/assets/row/public/documents/10/156/infineon-tc4x-overview-productpresentation-en.pdf
[^25^]: Welcome to the next generation AURIX TC4x - https://www.infineon.com/assets/row/public/images/corporate/press/market-news/infineon-aurix-tc4x.pdf
[^41^]: AURIX TC4Dx Errata Sheet - https://www.infineon.com/assets/row/public/documents/10/52/infineon-aurix-tc4dx-ab-es-erratasheet-en.pdf
[^182^]: AURIX TC4Dx Product Page - https://www.infineon.com/products/microcontroller/32-bit-tricore/aurix-tc4x/tc4dx
[^216^]: DRE Data Routing Engine Training Document - https://www.infineon.com/row/public/documents/10/56/infineon-aurix-tc4x-data-routing-engine-v1.0.pdf-training-en.pdf
[^219^]: Data Routing Engine (DRE) Documentation - https://documentation.infineon.com/aurixtc4xx/docs/car1553877122639
[^313^]: AURIX TC4xx Software Solutions (Hitex) - https://www.hitex.com/fileadmin/assets/download/AURIX-Knowledge-Lab-2024/AURIX-Knowledge-Lab-TC4-Software.pdf
[^399^]: DRE Functional Overview - https://documentation.infineon.com/aurixtc4xx/docs/slv1553877124917
[^401^]: Infineon AURIX TC4x PPU Wiki - https://www.emmtrix.com/wiki/Infineon_AURIX_TC4x_Parallel_Processing_Unit_(PPU)
[^402^]: CSDN Technical Overview of TC4x - https://blog.csdn.net/redparrot2008/article/details/149222043
[^408^]: AURIX DriveCore AUTOSAR Getting Started - https://www.infineon.com/assets/row/public/documents/10/68/infineon-aurix-drivecore-autosar-infineon-isoft-tasking-gettingstarted-en.pdf
[^412^]: Infineon Community Blog - CRE and DRE Function - https://community.infineon.com/t5/%E5%8D%9A%E5%AE%A2/%E5%A6%82%E4%BD%95%E6%8B%93%E5%B1%95%E5%AE%9E%E7%8E%B0Aurix-TC4X-Routing-CRE-and-DRE%E5%8A%9F%E8%83%BD/ba-p/1121834
[^413^]: AURIX TC4x Technical Interpretation - https://sandvik.zaoche168.com/detail/_01-ABC00000000000349893.shtml
[^415^]: Marelli and Infineon ZCU Collaboration - https://www.shine.lighting/industry/marelli-automotive-lighting.2395/update/4677/
[^429^]: Rutronik NPI Newsletter July 2025 - https://www.rutronik.com/fileadmin/Rutronik/Micropages/Infineon/NPI/2025/Infineon_NPI_newsletter_0725_customer_version.pdf
[^449^]: Automotive Ethernet: Performance and Reconfigurability - https://xueqiu.com/6659575183/326773375
[^455^]: DRE Feature List (CAN Feature List) - https://documentation.infineon.com/aurixtc4xx/docs/jvl1539935375056
[^456^]: DRE Feature List (Standalone) - https://documentation.infineon.com/aurixtc4xx/docs/upy1553877124220
[^465^]: CANXL Feature List - https://documentation.infineon.com/aurixtc4xx/docs/fcg1626264235337
[^471^]: AURIX TC4x MCAL Installation Guide - https://community.infineon.com/t5/%E5%8D%9A%E5%AE%A2/AURIX-TC4x-MCAL-%E5%AE%89%E8%A3%85%E4%B8%8E-DemoApp-%E7%BC%96%E8%AF%91%E6%8C%87%E5%8D%97/ba-p/1181263
[^472^]: TC4XX New Features (Tencent) - https://new.qq.com/rain/a/20240813A0255D00
[^473^]: AURIX TC4XX New Features (AIJishu) - https://aijishu.com/a/1060000000475879
[^476^]: AURIX DriveCore Gateway Demo Guide - https://www.infineon.com/assets/row/public/documents/10/68/infineon-gsg-aurix-ebtasking.pdf-gettingstarted-en.pdf
[^484^]: Marelli and Infineon ZCU at Auto China 2024 - https://autotechglobal.com/industry/news/marelli-and-infineon-collaborate-to-marelli-s-zone-control-unit-at-the-2024

---

*Document generated from comprehensive research of Infineon official documentation, technical manuals, application notes, and training materials.*
