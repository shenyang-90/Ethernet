# Dimension 3: TSN Protocol - IEEE 802.1AS Time Synchronization on AURIX TC4x

## Table of Contents
1. [Overview of IEEE 802.1AS/gPTP](#1-overview)
2. [gPTP Implementation on TC4x](#2-gptp-implementation)
3. [Hardware Timestamping in XGMAC](#3-hardware-timestamping)
4. [Clock Synchronization Mechanisms](#4-clock-synchronization)
5. [Hardware Features and Registers](#5-hardware-features)
6. [TC4x-Specific Implementation Details](#6-tc4x-specific)
7. [AUTOSAR Integration (StbM/EthTSyn)](#7-autosar-integration)
8. [References](#8-references)

---

## 1. Overview of IEEE 802.1AS/gPTP

### 1.1 Introduction to IEEE 802.1AS-2020

IEEE 802.1AS-2020 defines the **generalized Precision Time Protocol (gPTP)**, a profile of IEEE 1588-2019 optimized for Time-Sensitive Networking (TSN) applications. It provides **sub-microsecond clock synchronization** across all devices on an Ethernet network, creating a single, precise timeline that every switch, controller, and sensor follows [^30^][^183^].

Key characteristics of gPTP:
- Operates **exclusively at Layer 2** (Ethernet data link layer) with Ethertype 0x88F7
- Uses **hardware-assisted timestamping** as a mandatory requirement
- Employs **peer-to-peer (P2P) delay mechanism** for full-duplex Ethernet links
- Requires **two-step processing** by default (with optional one-step mode for Sync)
- All PTP instances are **logically syntonized** (mandatory frequency synchronization)
- Supports the **Best Master Clock Algorithm (BMCA)** for automatic grandmaster selection [^154^][^188^]

### 1.2 Key Differences: 802.1AS-2020 vs 802.1AS-2011

The TC4x supports IEEE 802.1AS-2020, which adds several important features over the 2011 edition [^196^][^146^]:

| Feature | 802.1AS-2011 | 802.1AS-2020 |
|---------|-------------|--------------|
| Domains | Single domain (domain 0) | **Multiple domains** for fault tolerance |
| Port Configuration | BMCA only | **External port configuration** alternative |
| One-step Clocks | Two-step only | **One-step ports supported** |
| Link Delay | Per-domain measurement | **Common Mean Link Delay Service (CMLDS)** |
| Capability Detection | Basic | **Improved non-compliant device detection** |
| Timescale | PTP only | Multiple timescales possible |

### 1.3 TC4x Support Matrix

According to Infineon documentation, the TC4Dx supports IEEE 802.1AS-2020 on both GETH and LETH modules [^30^][^77^]:

| IEEE Standard | Feature | TC4Dx GETH | TC4Dx LETH |
|--------------|---------|------------|------------|
| IEEE 802.1AS/AS-2020 | Timing and Synchronization | Supported | Supported |
| IEEE 802.1Qav | Credit Based Shaper | Yes | Yes |
| IEEE 802.1Qbu | Frame Preemption | Yes | No |
| IEEE 802.1Qbv | Time-Aware Shaper | Yes | Yes |
| IEEE 802.1Qci | Filtering and Policing | Partial | Partial |

---

## 2. gPTP Implementation on TC4x

### 2.1 Hardware Architecture Overview

The TC4x GETH module implements gPTP through the **Synopsys DesignWare XGMAC** IP core, which provides comprehensive IEEE 1588-2008 timestamping capabilities [^28^][^46^]. The architecture includes:

- **XGMAC Core**: Implements the MAC layer with PTP timestamping support
- **MTL (MAC Transaction Layer)**: Provides FIFO buffering between system memory and XGMAC
- **DMA Engine**: Multi-channel DMA with descriptor-based timestamp status writeback
- **Timestamp Unit**: Dedicated hardware for capturing and managing timestamps
- **PTP Offload Module**: Optional hardware acceleration for automatic SYNC/Delay packet generation [^46^][^47^]

### 2.2 Grandmaster/Slave Clock Operation

The gPTP protocol on TC4x operates through the following mechanisms:

**Grandmaster (GM) Operation:**
- The GM is the network's clock source, periodically broadcasting the current system time
- In automotive applications, GM selection is typically done **statically** rather than through BMCA
- The GM sends **Sync messages** out of its master ports at configurable intervals (typically 125ms)
- For **two-step clocks**, a **Follow_Up message** follows each Sync, containing the precise transmission timestamp t1 [^13^][^185^]

**Slave Clock Operation:**
- Slave ports receive Sync messages and capture ingress timestamps (t2)
- After receiving the Follow_Up with the GM's preciseOriginTimestamp (t1), the slave has all information needed to correct its time
- Slaves calculate: **Offset = [(t2 - t1) - (t4 - t3)] / 2**
- Slaves also perform rate correction using the **neighborRateRatio** accumulated in the Follow_Up TLV [^146^][^151^]

### 2.3 Sync and Follow_Up Message Handling

The TC4x supports **two-step timestamping mode** for gPTP:

**Two-Step Process:**
1. GM sends Sync message, hardware captures precise egress timestamp t1
2. GM sends Follow_Up message containing preciseOriginTimestamp = t1
3. Slave receives Sync, hardware captures ingress timestamp t2
4. Slave receives Follow_Up, extracts t1 and correctionField
5. Slave calculates time offset and adjusts local clock [^144^][^147^]

**Message Format:**
- Sync message: PTP header + reserved (10 bytes) + correctionField
- Follow_Up message: PTP header + preciseOriginTimestamp (10 bytes) + Follow_Up information TLV (32 bytes)
- The Follow_Up information TLV contains: cumulativeScaledRateOffset, gmTimeBaseIndicator, lastGmPhaseChange, scaledLastGmFreqChange [^153^]

### 2.4 Peer Delay (pDelay) Measurement

TC4x supports the peer-to-peer delay mechanism for measuring link propagation delay:

**pDelay Message Exchange:**
1. Initiator sends Pdelay_Req, records egress timestamp **t1**
2. Responder receives Pdelay_Req, records ingress timestamp **t2**
3. Responder sends Pdelay_Resp (carries t2), records egress timestamp **t3**
4. Initiator receives Pdelay_Resp, records ingress timestamp **t4**
5. Responder sends Pdelay_Resp_Follow_Up carrying **t3**

**Calculations:**
- **neighborRateRatio** = (t3(N) - t3(N-1)) / (t4(N) - t4(N-1))
- **meanLinkDelay** = (1/2) * [r * (t4 - t1) - (t3 - t2)] [^146^][^148^]

---

## 3. Hardware Timestamping in XGMAC

### 3.1 Timestamp Trigger Point

The TC4x XGMAC captures timestamps at the **Start-of-Frame Delimiter (SFD)**:

> "When the IEEE 1588 timestamping function is enabled, this module captures the system time at the moment the SFD is put on the transmit bus" [^28^]

This provides the most accurate timestamp possible, as it represents the exact moment the frame begins transmission on the wire.

### 3.2 DMA Descriptor Timestamping

The TC4x uses descriptor-based timestamping with writeback from the DMA engine:

**Transmit Descriptor (TDES structure):**
- TDES0: Buffer1 address / Timestamp Low (writeback)
- TDES1: Buffer2 address / Timestamp High (writeback)
- TDES2: Control bits including **TTSE** (Transmit Timestamp Enable, bit 30)
- TDES3: Control bits including **OWN** (DMA ownership), FD, LD [^28^][^44^]

**Writeback Format:**
After transmission, the DMA writes back:
- Timestamp seconds in TDES0/TDES1 fields
- Status bits indicating transmission completion and timestamp validity
- For two-step timestamping, the TX timestamp is captured and stored in the descriptor

**Receive Descriptor (RDES structure):**
- RDES0: Buffer address / Timestamp Low (context descriptor)
- RDES1: Header address / Timestamp High (context descriptor)  
- RDES3: CTXT bit indicates context descriptor with timestamp data [^28^]

> "The Write-Back format contains timestamp and status bits... the receive writeback needs an additional context descriptor to supplement status information" [^28^]

### 3.3 Timestamp Filtering and Control

The XGMAC provides flexible timestamp filtering [^156^][^160^]:

- **TSENALL** (bit 8): Enable timestamp snapshot for all received packets
- **AV8021ASMEN** (bit 28): Enable IEEE 802.1AS mode - processes only untagged PTP over Ethernet packets
- **TSCTRLSSR** (bit 9): Timestamp rollover control - 0x3B9AC9FF for nanosecond accuracy
- **TSINIT** (bit 2): Initialize timestamp with programmed value
- **TSUPDT** (bit 3): Update timestamp (add/subtract)
- **TSADDREG** (bit 5): Update addend register for fine correction

---

## 4. Clock Synchronization Mechanisms

### 4.1 Local Clock Domain vs Network Time Domain

The TC4x maintains two time concepts [^46^][^166^]:

**Local Clock Domain (Virtual Local Time):**
- Derived from the hardware PTP clock (PTP reference clock)
- Implemented as a free-running counter
- Provides the timebase for timestamping events
- Not synchronized to any external reference

**Network Time Domain (Synchronized Time Base):**
- Represents the global time synchronized to the Grandmaster
- Calculated from: **TG = TGSync + (TV - TVSync) * r**
  - TG = Global Time (network time)
  - TV = Virtual Local Time (local hardware counter)
  - TGSync = Global Time at last sync point
  - TVSync = Virtual Local Time at last sync point  
  - r = rate ratio between local and GM clock

### 4.2 Rate Ratio Calculation

The TC4x XGMAC supports **fine correction** through the addend register mechanism:

**Addend Register Operation:**
- The MAC_Timestamp_Addend register provides sub-nanosecond precision for clock rate adjustment
- The formula: **Addend = 2^32 / (ClockFreq * PeriodInSeconds)**
- For example, with a 100MHz PTP clock: Addend = 2^32 / (100 * 10^6 * 10^-9) [^66^][^165^]
- Writing TSADDREG=1 initiates the update of the addend value in the PTP block

**Fine Update vs Coarse Update:**
- **Fine Update**: Uses addend register for gradual frequency adjustment (for drift compensation)
- **Coarse Update**: Directly sets system time seconds/nanoseconds (for initial sync or large offsets) [^156^][^198^]

### 4.3 Sub-Second Increment Register

The MAC_Sub_Second_Increment register controls the basic time unit:

| Field | Bits | Description |
|-------|------|-------------|
| SSINC | 7:0 | Sub-second increment value (nanoseconds per clock cycle) |
| SNSINC | 15:8 | Sub-nanosecond increment for fractional compensation |

Example for 100MHz PTP clock:
- Period = 1/100MHz = 10ns
- SSINC = 0x0A (10 decimal)
- SNSINC = 0x00 (no sub-nanosecond compensation needed) [^155^]

### 4.4 Neighbor Propagation Delay (pDelay) Measurement

The TC4x supports full hardware-assisted pDelay measurement:

1. Hardware captures t1 when Pdelay_Req exits the MAC (SFD on TX bus)
2. Hardware captures t2 when Pdelay_Req enters the peer MAC (SFD on RX bus)
3. Hardware captures t3 when Pdelay_Resp exits the peer MAC
4. Hardware captures t4 when Pdelay_Resp enters the local MAC

The meanLinkDelay is computed by software using:
> D = (1/2) * [r * (t4 - t1) - (t3 - t2)] [^146^]

### 4.5 Path Delay Asymmetry Compensation

The XGMAC provides **registers for asymmetric time correction** [^46^][^47^]:
- MAC supports ingressLatency and egressLatency configuration
- These values compensate for known asymmetries between TX and RX paths
- The correctionField in gPTP messages is adjusted accordingly
- 802.1AS-2020 also adds management support for delay asymmetry measurement using line-swapping [^188^]

---

## 5. Hardware Features and Registers

### 5.1 Timestamp Register Map

The XGMAC timestamp registers (relative to MAC base) [^156^][^160^][^162^]:

| Register | Offset | Description |
|----------|--------|-------------|
| MAC_Timestamp_Control | 0xD00 | Main timestamp control |
| MAC_Sub_Second_Increment | 0xD04 | Sub-second increment value |
| MAC_System_Time_Seconds | 0xD08 | System time - seconds |
| MAC_System_Time_Nanoseconds | 0xD0C | System time - nanoseconds |
| MAC_System_Time_Seconds_Update | 0xD10 | Update seconds value |
| MAC_System_Time_Nanoseconds_Update | 0xD14 | Update nanoseconds value |
| MAC_Timestamp_Addend | 0xD18 | Addend for fine correction |
| MAC_System_Time_Higher_Word | 0xD1C | Extended seconds (if enabled) |
| MAC_Timestamp_Status | 0xD20 | Timestamp interrupt status |
| MAC_TxTimestamp_Status_Nanoseconds | 0xD30 | TX timestamp status - ns |
| MAC_TxTimestamp_Status_Seconds | 0xD34 | TX timestamp status - seconds |
| MAC_PPS0_Target_Time_Seconds | 0xD80 | PPS0 target time seconds |
| MAC_PPS0_Target_Time_Nanoseconds | 0xD84 | PPS0 target time nanoseconds |
| MAC_PPS_Control | 0xD70 | PPS output control |

### 5.2 MAC_Timestamp_Control Register

Key control bits [^156^][^160^]:

| Bit | Name | Function |
|-----|------|----------|
| 0 | TSENA | Timestamp Enable - master enable for timestamping |
| 1 | TSCFUPDT | Timestamp Fine/Coarse Update - 0=fine, 1=coarse |
| 2 | TSINIT | Timestamp Initialize - initialize with update values |
| 3 | TSUPDT | Timestamp Update - add/subtract update values |
| 4 | TSTRIG | Timestamp Trigger - reserved |
| 5 | TSADDREG | Update Addend Register - load new addend value |
| 8 | TSENALL | Enable Timestamp for All Packets |
| 9 | TSCTRLSSR | Timestamp Digital Rollover Control |
| 15 | TSIPENA | Timestamp for IPv4/IPv6 Enable |
| 28 | AV8021ASMEN | AV IEEE 802.1AS Mode Enable |

### 5.3 System Time Registers

The system time is maintained as a 64-bit value [^198^]:
- **Seconds**: 32-bit register (MAC_System_Time_Seconds at 0xD08)
- **Nanoseconds**: 32-bit register (MAC_System_Time_Nanoseconds at 0xD0C)
  - When TSCTRLSSR=1, rolls over at 0x3B9A_C9FF (999,999,999 ns)
  - 1 nanosecond resolution

### 5.4 Target Time Registers (Scheduled Transmission)

The PPS/Target Time registers enable scheduled transmission for TSN [^174^][^175^]:

- **MAC_PPSx_Target_Time_Seconds** (0xD80, 0xD90, ...): Target seconds
- **MAC_PPSx_Target_Time_Nanoseconds** (0xD84, 0xD94, ...): Target nanoseconds
  - Bit 31 (TRGTBUSY): Target time register busy flag
  - Bits 30:0 (TTSL): Target time in nanoseconds

When system time >= target time:
- PPS signal is generated/terminated
- **TSTRGT** bit in MAC_Timestamp_Status is set
- Interrupt can be generated if enabled

This enables **Time-Aware Shaping (802.1Qbv)** integration where packet transmission is precisely scheduled.

### 5.5 PPS Output

The XGMAC supports flexible PPS (Pulse Per Second) output control [^46^][^47^]:
- **ptp_pps_o** signal output for external synchronization
- Configurable PPS width and interval
- Target time scheduling for PPS generation
- Multiple PPS outputs supported (PPS0-PPS3)
- Enables synchronization with external time sources (GPS, etc.)

### 5.6 TX Timestamp Status

For two-step timestamping, the XGMAC provides [^46^][^47^]:
- TX timestamps in CSR status registers
- Option to store up to **16 timestamps** with packet identifier in CSR
- MAC_TxTimestamp_Status_Nanoseconds register with TXTSSTSMIS flag
- MAC_TxTimestamp_Status_Seconds register with TXTSSTSHI flag

---

## 6. TC4x-Specific Implementation Details

### 6.1 GETH/LETH Instance Support

The TC4x provides multiple Ethernet instances [^28^][^182^]:

**GETH (Gigabit Ethernet):**
- Up to 2 XGMAC instances per GETH module
- Supports 10M/100M/1G/2.5G/5G speeds (full-duplex)
- Supports 802.1AS-2020 timestamping on all ports
- Bridge function connects two Ethernet ports + host interface
- Connected to HSPHY (High Speed PHY) for physical layer

**LETH (Lightweight Ethernet):**
- Additional Ethernet instances (e.g., for 10BASE-T1S)
- May have reduced feature set compared to GETH
- Also supports 802.1AS-2020 timestamping

**Clock Configuration:**
- GETH module clock: fGETH = fSOURCE0 / SYSCCUCON1.GETHDIV
- Example: fSOURCE=500MHz, GETHDIV=2 → fGETH=250MHz [^28^]
- PTP reference clock (emac_ptp_clk) is a separate clock input for timestamping

### 6.2 Errata and Limitations

Several errata entries are relevant to 802.1AS on TC4x [^41^]:

**LETH_TC.010 - Missing PTP Time Sync Concept Among All LETH0 MAC Ports:**
> "PTP(IEEE1588) transparent clocks and gPTP(IEEE802.1AS) bridges require a common time base for timestamping on ingress(RX) and egress(TX) ports... However, due to limitation in LETH0 MAC ports if timebase for timestamping is selected via external time base input, LETH0 MAC port cannot output the 64-bit PTP time."

- Impact: Only pairwise daisy-chaining of time base forwarding is possible
- Workaround: LETH0 MAC port 0 internal → port 1 external, port 2 internal → port 3 external (or reverse)

**LETH_AI.024 - Transmit Timestamp Not Properly Transferred:**
> "Transmit Timestamp status is not correctly written in TDES0,TDES1 during Transmit Normal Descriptor write back" when TxDMA channels are not mapped to TXQ0 and bridge is enabled.

**GETH_AI.040 - RX DMA Stall with Timestamp:**
> When VLAN tagged & timestamped ingress packets are duplicated to forwarding path, followed by duplication to RxDMA, the Receive DMA can stall.

**Workaround:** Map lowest RXC as forwarding channel to egress TXQ among duplicated channels.

**LETH_TC.H002 - DMA Channel Lockup with Timestamping:**
> When timestamping is enabled and context descriptor is not available, the DMA channel locks up.

**Workaround:** Software must create one additional descriptor when RBU interrupt is generated.

### 6.3 Interrupt Handling

The TC4x generates interrupts for sync events through the **IR (Interrupt Router)** module [^28^][^44^]:

**Timestamp-Related Interrupts:**
- **TSTRGT0/TSTRGT1/TSTRGT2/TSTRGT3**: Target time reached for PPS0-3
- **TSTRGTERR**: Target time error (programmed time already elapsed)
- **TXTSSTSMIS**: TX timestamp status missed

**DMA Channel Interrupts:**
- TI (Transmit Interrupt): Packet transmission complete
- RI (Receive Interrupt): Packet reception complete
- NIS (Normal Interrupt Summary): Normal operation events
- AIS (Abnormal Interrupt Summary): Error conditions

### 6.4 Timestamp Clock Configuration

The PTP timestamp unit requires proper clock configuration:

```c
// Example: Configure timestamp for 100MHz PTP clock
// 1. Enable timestamp
MODULE_GETH.MAC_TIMESTAMP_CONTROL.B.TSENA = 1;

// 2. Set sub-second increment (10ns per cycle for 100MHz)
MODULE_GETH.MAC_TIMESTAMP_CONTROL.B.TSCTRLSSR = 1;
MODULE_GETH.MAC_SUB_SECOND_INCREMENT.B.SNSINC = 0x00;  // No sub-ns
MODULE_GETH.MAC_SUB_SECOND_INCREMENT.B.SSINC = 0x0A;    // 10 ns

// 3. Initialize system time
MODULE_GETH.MAC_TIMESTAMP_CONTROL.B.TSINIT = 1;
```

**Note:** The System Time Update logic requires a specific clock frequency to achieve target accuracy. The internal GETH-IP clock determines the timestamp resolution [^158^].

### 6.5 PTP Offload Feature

The XGMAC includes an optional **PTP Offload Module** [^46^][^47^]:
- Supports automatic generation and transmission of SYNC packets
- Supports automatic Delay Request/Response handling
- Reduces CPU overhead for time synchronization tasks
- The TC4x errata indicate some limitations with the offload in certain bridge configurations

---

## 7. AUTOSAR Integration (StbM/EthTSyn)

### 7.1 Architecture Overview

The AUTOSAR time synchronization stack integrates with TC4x hardware through [^43^][^47^][^50^]:

```
+--------------------------------------+
|          Application Layer           |
|    (Uses synchronized global time)    |
+--------------------------------------+
|             RTE                      |
+--------------------------------------+
|  StbM (Synchronized Time-Base Mgr)   |
|  - Manages global time bases         |
|  - Provides time to applications     |
|  - Rate/offset correction            |
+--------------------------------------+
|  EthTSyn (Ethernet Time Sync)        |
|  - Implements IEEE 802.1AS protocol  |
|  - Handles Sync/Follow_Up/Pdelay     |
|  - Interfaces with EthIf             |
+--------------------------------------+
|  EthIf (Ethernet Interface)          |
|  - Provides EthIf_GetIngressTimeStamp|
|  - Provides EthIf_GetEgressTimeStamp |
+--------------------------------------+
|  Eth Driver (MCAL)                   |
|  - XGMAC register access             |
|  - DMA descriptor management         |
|  - Hardware timestamp extraction     |
+--------------------------------------+
|  XGMAC Hardware (TC4x)               |
|  - Timestamp capture at SFD          |
|  - DMA timestamp writeback           |
+--------------------------------------+
```

### 7.2 StbM (Synchronized Time-Base Manager)

The StbM module manages the global time base [^58^][^166^]:

**Key Concepts:**
- **Virtual Local Time (TV)**: Local hardware counter time, driven by TC4x PTP clock
- **Synchronized Time Base (TG)**: Global time synchronized to GM
- **Offset Time Base**: TG + configurable offset
- StbM allows maintenance of **up to 32 different time bases**

**Time Correction Formula:**
> TL = TGSync + (TV - TVSync) * r [^166^]

**StbM Functions:**
- Receives time updates from EthTSyn via StbM_BusSetGlobalTime()
- Performs rate correction and offset correction
- Provides StbM_GetCurrentTime() to applications
- Manages time base status (valid/invalid, timeout detection)

### 7.3 EthTSyn (Ethernet Time Synchronization)

The EthTSyn module implements the 802.1AS protocol on Ethernet [^61^][^168^][^170^]:

**Key Features:**
- Supports both **Time Master** and **Time Slave** roles
- Implements periodic and immediate time synchronization
- Handles Pdelay measurement
- Supports hardware timestamping via EthIf interface
- Frame debouncing to prevent priority inversion

**AUTOSAR Limitations (Deviations from IEEE 802.1AS):**
- No support for BMCA protocol
- No support for Announce and Signaling messages
- Pdelay reception is not a precondition for Sync transmission
- Rate correction is performed by StbM, not by Pdelay mechanism
- EthTSyn does not maintain the Ethernet HW clock directly [^168^]

### 7.4 Hardware Timestamp Integration

The TC4x hardware timestamping integrates with AUTOSAR through [^170^][^163^]:

**Hardware Timestamp Support:**
- When EthTSynHardwareTimestampSupport = TRUE:
  - Ingress timestamps retrieved via EthIf_GetIngressTimeStamp()
  - Egress timestamps retrieved via EthIf_GetEgressTimeStamp()
  - Uses XGMAC hardware capture at SFD

**Software Timestamp Fallback:**
- When EthTSynHardwareTimestampSupport = FALSE:
  - Timestamps retrieved via StbM_GetCurrentVirtualLocalTime()
  - Less accurate but works without hardware support

**Timestamp Processing Flow:**
1. Eth driver configures XGMAC for timestamp capture
2. On Sync reception, hardware captures t2 in DMA descriptor
3. EthIf extracts timestamp from driver
4. EthTSyn calculates time offset
5. StbM updates global time base

### 7.5 Configuration Requirements

For proper 802.1AS operation on TC4x in AUTOSAR [^163^][^164^]:

1. **Enable hardware timestamping in MCAL Eth driver**
2. **Register hardware timestamp callbacks with EthIf**
3. **Configure EthTSyn port role** (Master or Slave)
4. **Set sync interval** (typically 125ms for automotive)
5. **Configure Pdelay parameters**
6. **Set up time domain associations**

**Time Domain Configuration:**
- Domain number (default: 0 for 802.1AS)
- sdoId (major: 0x1, minor: 0x00 for gPTP)
- Time base reference
- GlobalTimeTxPeriod
- GlobalTimeFollowUpTimeout

### 7.6 NVIDIA DRIVE Integration Example

The NVIDIA DRIVE platform demonstrates TC4x gPTP integration [^42^][^45^]:

**Configuration:**
- AURIX serves as Global Time Master
- SoC (Xavier) serves as Time Slave
- Uses EthTSyn + StbM modules on AURIX
- Uses linuxptp (ptp4l + phc2sys) on SoC side

**AURIX Commands:**
```
date 0x77DA7A8F    // Set Unix time
gptpon             // Enable gPTP
```

This validates the TC4x 802.1AS implementation in production automotive platforms.

---

## 8. References

| Reference | Source | Description |
|-----------|--------|-------------|
| [^30^] | Infineon TC4x Intro Guide | AURIX TC4x TSN feature overview including 802.1AS support |
| [^28^] | EEWorld China | Detailed TC4x GETH module architecture and descriptor mechanism |
| [^41^] | Infineon Errata Sheet | TC4Dx errata including timestamp and PTP-related issues |
| [^42^] | NVIDIA DRIVE OS | Time sync between AURIX and SoC using gPTP |
| [^43^] | CSDN Blog | AUTOSAR EthTSyn module technical analysis |
| [^44^] | 360doc | AUTOSAR clock sync mechanism with StbM |
| [^46^] | Intel XGMAC Docs | XGMAC core features including IEEE 1588 timestamping |
| [^47^] | Intel XGMAC Docs | XGMAC core feature documentation |
| [^50^] | Infineon TC4xx Docs | Feature list with TSN support matrix |
| [^55^] | NI PXI-6683 Manual | IEEE 802.1AS and 1588 overview |
| [^58^] | AUTOSAR Spec | StbM specification (R22-11) |
| [^61^] | AUTOSAR Spec | EthTSyn SWS (R24-11) |
| [^77^] | Infineon TC4xx Docs | Feature list confirming 802.1AS-2020 support |
| [^146^] | IEEE Presentation | Introduction to IEEE 802.1AS |
| [^151^] | Microchip Docs | Introduction to IEEE 802.1AS |
| [^153^] | AUTOSAR Spec | Time Synchronization Protocol (R23-11) |
| [^154^] | IEEE Standard | IEEE 802.1AS-2020 official standard |
| [^155^] | Infineon Community | TC397 PTP system time update discussion |
| [^156^] | Intel Register Docs | MAC_Timestamp_Control register definition |
| [^158^] | Infineon Community | TC377 GETH Tx timestamp discussion |
| [^160^] | Intel Register Docs | MAC_Timestamp_Control with AV8021ASMEN |
| [^163^] | EasyXMen Docs | EthTSyn functional description |
| [^166^] | EasyXMen Docs | StbM functional description |
| [^168^] | AUTOSAR Spec | EthTSyn SWS R18-10 |
| [^170^] | AUTOSAR Spec | EthTSyn SWS R21-11 |
| [^174^] | Intel Register Docs | MAC_PPS1_Target_Time_Seconds |
| [^175^] | Intel Register Docs | MAC_PPS0_Target_Time_Nanoseconds |
| [^182^] | Infineon Product Page | TC4Dx product description |
| [^183^] | Fiberroad Blog | TSN clock synchronization overview |
| [^185^] | IRIT/UPS | Towards robust network synchronization with 802.1AS |
| [^188^] | IEEE Webinar | Introduction to IEEE 802.1AS (2022) |
| [^191^] | ACM Paper | Application-Level Evaluation of IEEE 802.1AS |
| [^196^] | IEEE Standards Blog | 802.1AS-2020 standard fuels growth |
| [^198^] | Intel Register Docs | MAC_System_Time_Seconds_Update |
| [^200^] | Linuxptp-devel | Common Mean Link Delay Service implementation |
| [^204^] | Meinberg Blog | gPTP technical explanation |

---

*Document compiled from Infineon official documentation, IEEE 802.1AS-2020 standard, AUTOSAR specifications, Intel XGMAC reference documentation, and automotive industry technical sources.*

*Last updated: Research compilation for AURIX TC4x 802.1AS Time Synchronization*
