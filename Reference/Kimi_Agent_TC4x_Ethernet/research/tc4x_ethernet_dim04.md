# Dimension 4: TSN Shapers - IEEE 802.1Qav/Qbv/Qbu/Qci/CB

## Infineon AURIX TC4x TSN Traffic Shaping Standards Support

---

## Executive Summary

The Infineon AURIX TC4x microcontroller family provides comprehensive hardware support for Time-Sensitive Networking (TSN) standards through its Gigabit Ethernet (GETH) and Lite Ethernet (LETH) modules. The following table summarizes the TSN feature support matrix:

| IEEE Standard | Standard Name | TC4Dx (GETH/LETH) |
|---|---|---|
| IEEE 802.1Qav | Credit Based Shaper (CBS) | Yes / Yes |
| IEEE 802.1Qbv | Time-Aware Shaper (TAS) | Yes / Yes |
| IEEE 802.1Qbu | Frame Preemption | Yes / No |
| IEEE 802.1Qci | Filtering and Policing (PSFP) | Partial / Partial |
| IEEE 802.1CB | Frame Replication and Elimination (FRER) | SW-based / SW-based |

*Table based on Infineon TC4x documentation [^30^][^77^]*

---

## 1. IEEE 802.1Qav - Credit Based Shaper (CBS)

### 1.1 Overview

IEEE 802.1Qav defines a Credit-Based Shaper (CBS) algorithm designed to "smooth" traffic bursts and provide bounded latency for time-sensitive streams. It is the foundation of the Audio Video Bridging (AVB) credit-based transmission model, which is also adopted by TSN for SR (Stream Reservation) classes. [^33^]

> "IEEE 802.1Qav is a traffic shaping mechanism that reduces buffering at receiving bridges and endpoints. It uses CBS to avoid burst transmissions of packets with the same traffic priority. It can shape traffic, prevent congestion, and ensure optimal performance for all users." [^30^]

### 1.2 Credit-Based Transmission Mechanism

The credit-based shaper in TC4x GETH works like a "credit card with savings functionality" for each transmit queue [^30^][^33^]:

**Key Parameters:**
- **credit (credit counter)**: The current credit value (can be positive or negative)
- **sendSlope**: The rate at which credit is consumed during transmission
- **idleSlope**: The rate at which credit is accumulated when the queue is idle/waiting
- **hiCredit**: The upper bound of credit accumulation (savings limit)
- **loCredit**: The lower bound of credit (maximum debt allowed)

**Transmission Rules:**

1. When a queue wants to transmit: It must have credit >= 0 to be allowed transmission
2. During frame transmission: Credit decreases at the **sendSlope** rate
3. If credit becomes 0 during transmission: The current frame continues transmission (credit goes negative into debt)
4. When queue is idle: Credit increases at the **idleSlope** rate (repaying debt, then accumulating savings)
5. Credit is bounded by **loCredit** (lower limit) and **hiCredit** (upper limit)

### 1.3 Class A and Class B SR Classes

The IEEE 802.1Qav standard defines two Stream Reservation (SR) traffic classes:

| Parameter | Class A (SR Class A) | Class B (SR Class B) |
|---|---|---|
| Max latency | 2 ms | 50 ms |
| Default priority | Priority 3 | Priority 2 |
| Typical use case | Real-time control, safety-critical data | Audio/video streams, less critical data |

### 1.4 Idle Slope and Send Slope Configuration

The TC4x GETH hardware provides dedicated registers for configuring the CBS parameters per traffic class (queue). The configuration is done through the MTL (MAC Transaction Layer) registers [^111^]:

```
For each traffic class TC[0..N]:
  - portj_MTL_TC49A_CBS_CONTROL: Enable/disable CBS
  - portj_MTL_TC49A_CBSISQ: IdleSlope configuration
  - portj_MTL_TC49A_CBSSSLOPE: SendSlope configuration
  - portj_MTL_TC49A_CBSHICREDIT: hiCredit upper bound
  - portj_MTL_TC49A_CBSLOCREDIT: loCredit lower bound
```

**Configuration Notes:**
- The idleSlope determines the bandwidth reserved for the traffic class
- The sendSlope is typically calculated as: sendSlope = idleSlope - portTransmitRate
- hiCredit = maxInterferenceSize x (idleSlope/portTransmitRate)
- loCredit = maxFrameSize x ((idleSlope/portTransmitRate) - 1)

### 1.5 Hardware Implementation in TC4x GETH

The TC4x GETH MAC integrates the CBS algorithm directly in hardware:

> "The CBS algorithm is integrated into the GETH MAC hardware, operating independently per traffic class queue. The credit counter is updated based on the configured idleSlope and sendSlope parameters, with automatic credit accumulation when the queue is idle and credit consumption during frame transmission." [^30^]

**Key Hardware Features:**
- Independent CBS instance per transmit queue (up to 8 queues)
- Automatic credit accumulation/decrement based on hardware state
- Configurable hiCredit and loCredit bounds
- Hardware-protected credit counter updates

### 1.6 Known Errata - CBS Credit During IPG

**Important**: The TC4x GETH and LETH modules have a known erratum regarding CBS credit behavior during the Inter-Packet Gap (IPG) [^41^]:

> **GETH_AI.029 / LETH_AI.005**: "When Credit Based Shaper (CBS) is enabled for a Traffic Class (TC), the packet available in a TC is scheduled for transmission when zero or positive credit is accumulated for the TC... As per IEEE 802.1Qav standard, the credit must also be decremented when the packet overheads are transmitted. These overheads include the preamble bytes before the start of packet, CRC/FCS bytes, and the minimum IPG (Inter packet Gap of 12 bytes) after the end of packet data transfer. However due to this defect, the MAC decrements the credit only up to last byte of packet data (last byte of Frame Check Sequence (FCS)) transfer and increments the credit during the subsequent nominal IPG period associated with that packet." [^41^]

**Impact:** The accumulated credit value is higher than expected, causing the next packet of that traffic class to be scheduled earlier than expected. The actual bandwidth consumed exceeds the programmed value.

**Estimated Additional Bandwidth:**
```
Additional BW = ((# of packets x 12 Bytes) / (Total bytes transmitted including preamble)) x FractionalBW

Example: 30% BW programmed, 100 packets of 128 bytes
Additional BW = 30% x (100 x 12) / (100 x (8+128)) = ~2.65%
Effective BW = 32.65% instead of programmed 30%
```

**Workaround:** Program a slightly lower bandwidth target to compensate for the additional bandwidth consumed due to the defective algorithm. [^41^]

### 1.7 GETH vs LETH Support

| Feature | GETH | LETH |
|---|---|---|
| CBS Support | Yes (8 queues) | Yes (4 queues) |
| Number of CBS instances | Up to 8 | 4 |
| Credit precision | Full hardware | Full hardware |
| Errata | GETH_AI.029 | LETH_AI.005 |

---

## 2. IEEE 802.1Qbv - Time Aware Shaper (TAS)

### 2.1 Overview

IEEE 802.1Qbv defines the Time-Aware Shaper (TAS) that enables deterministic transmission scheduling by controlling gate states for each transmit queue based on a precise time schedule. TAS is essential for achieving deterministic low-latency communication in automotive and industrial applications.

> "In addition to credit-based shaping, IEEE 802.1Qbv Time-Aware Shaper (TAS) allows scheduling of time-critical frames and lower-priority frames in time-triggered windows, which helps guarantee deterministic limited latency for time-critical frames." [^30^][^33^]

### 2.2 Time Slot-Based Scheduling

TAS divides time into repeating cycles, and each cycle is further divided into time slots:

```
Time Axis:
|----Cycle N----|----Cycle N+1----|----Cycle N+2----|
|Slot0|Slot1|...|Slot0|Slot1| ... |Slot0|Slot1|...|
```

**Key Parameters:**
- **Base Time**: The absolute time when the schedule starts (aligned with gPTP time)
- **Cycle Time**: The period of one complete schedule cycle (configurable)
- **Cycle Time Extension**: Maximum time by which a cycle can be extended during configuration changes
- **Time Slot**: A time interval within a cycle during which specific queues are open/closed
- **Guard Band**: A protection interval at the end of each time slot to prevent frame overrun

### 2.3 Gate Control List (GCL) Configuration

The GCL is a sequence of Gate Control Entries (GCE), where each entry defines:

1. **Gate States**: A bitmask indicating which queues are open (1) or closed (0)
2. **Time Interval**: Duration (in nanoseconds) that the gate states remain active

**GCL Entry Format (Hardware):**
```
GCE = {gate_state[7:0], time_interval_ns}
```

**Example GCL:**
```
Entry 0: {TC7=open, TC6=closed, TC5-0=closed}, 500us   -- Time-critical window
Entry 1: {TC7=open, TC6=open,  TC5-0=closed}, 200us   -- Medium priority window
Entry 2: {TC7=open, TC6=open,  TC5-0=open},   300us   -- Best-effort window
```

**TC4x GETH GCL Hardware Configuration:**

The TC4x GETH uses the MTL Enhanced Scheduling Traffic (EST) registers for TAS configuration [^111^]:

```
Registers:
- MTL_EST_CTRL (0xC50): TAS control register
  - EEST: Enable EST (TAS)
  - SSWL: Switch to software-owned GCL list
  - TILS[2:0]: Time interval left shift
  - PTOV[7:0]: PTP time offset
  - CTOV[11:0]: Current time offset

- MTL_EST_STATUS (0xC58): TAS status register
  - SWOL: Software-owned list indicator (shows active GCL bank)
  - BTRE: Base time error
  - SWLC: Switch complete

- MTL_EST_GCL_CTRL (0xC80): GCL control register
  - ADDR[2:0]: GCL address (entry index)
  - DBGB1: Debug bank select
  - DBGM: Debug mode
  - GCRR: GC Related Registers access
  - SRWO: Start read/write operation

- MTL_EST_GCL_DATA (0xC84): GCL data register
  - Data for GCL entry or GCRR
```

**GCL Banks (Double Buffering):**
The TC4x GETH supports dual GCL banks for hitless configuration updates:
- Bank 0 and Bank 1
- Software writes to one bank while hardware executes the other
- Controlled by MTL_EST_STATUS.SWOL bit

**GCL Depth (Hardware Capacity):**
The GCL depth is determined by the hardware capability register:
```
ESTDEP[2:0] in GMAC_HW_FEATURE3:
  0: Not supported
  1: 64 entries
  2: 128 entries
  3: 256 entries
  4: 512 entries
  5: 1024 entries
```

### 2.4 Gate Open/Close Control Per Queue

Each queue's gate state is controlled independently in each GCE:

> "Each queue's gate can be controlled by the Gate Control List (GCL). The GCL can configure the time interval for each time slot and the gate controller for each queue." [^30^]

**Queue Priority Mapping:**
- TC7: Highest priority (typically scheduled critical traffic)
- TC6-TC1: Intermediate priorities
- TC0: Lowest priority (typically best-effort traffic)

### 2.5 Cycle Time and Cycle Extension

**Cycle Time Configuration:**
```
Cycle Time = Cycle_Time_Hi (seconds) + Cycle_Time_Lo (nanoseconds)
Valid range: 256 ns to 999,999,999 ns (approximately 1 second)
```

**Cycle Time Extension:**
```
TER: Time Extension value (nanoseconds)
Purpose: Maximum time to extend current cycle when new GCL is installed
Valid range: 256 ns to 999,999,999 ns
```

**Guard Band Calculation:**
```
Without Preemption:
  T_guard = (L_max x 8) / R_line + T_margin

With Preemption:
  T_guard = (L_frag_max x 8) / R_line + T_margin
```

Where L_max is maximum frame size, R_line is line rate, and T_margin is implementation margin. [^119^]

### 2.6 Hardware Implementation Details

**TC4x GETH TAS Hardware Architecture:**

> "The GETH module in TC4x integrates an Enhanced Scheduling Traffic (EST) engine in the MTL layer. The EST engine maintains a cycle counter synchronized with the gPTP time base. At each GCL transition point, the EST engine updates the gate states for all transmit queues simultaneously." [^28^]

**Key Implementation Features:**
1. **Time Base**: Synchronized to IEEE 802.1AS gPTP time
2. **GCL Storage**: Dedicated hardware memory for GCL entries
3. **Cycle Counter**: Hardware-maintained cycle timing
4. **Gate State Application**: Simultaneous update of all queue gates
5. **Configuration Switching**: Atomic bank switch for GCL updates

### 2.7 Known Errata - TAS Additional IPG

**GETH_AI.032 / LETH_AI.008**: When EST is enabled, extra IPG is observed even when back-to-back packets are available for scheduling [^41^]:

> "When Enhancements to Scheduling Traffic (EST) feature is enabled, the Transmit Scheduler defers next packet scheduling until the current packet is completely forwarded to MAC Transmitter... due to the defect, extra IPG (more than programmed minimum IPG) is observed even when back-to-back packets are available for scheduling."

> "This can be in worst case 12 clock cycles of slowest among the two clocks (converted to bit times based on operating speed) based on the frequency and phase relationship of fGETH and MAC Transmitter clocks." [^41^]

**Workaround:** Account for the additional IPG in cycle time calculations. The extra delay is deterministic and can be factored into guard band sizing.

### 2.8 GETH vs LETH Support

| Feature | GETH | LETH |
|---|---|---|
| TAS Support | Yes | Yes |
| GCL Banks | 2 (double-buffered) | 2 (double-buffered) |
| GCL Depth | Up to 1024 entries | Limited entries |
| Time Resolution | Nanosecond | Nanosecond |
| Queue Gates | 8 gates | 4 gates |

---

## 3. IEEE 802.1Qbu - Frame Preemption

### 3.1 Overview

IEEE 802.1Qbu defines Frame Preemption, which allows express (time-critical) frames to interrupt the transmission of preemptable (lower-priority) frames. This reduces the blocking latency for time-sensitive traffic.

> "Ethernet frame preemption is a function specified in the IEEE 802.1Qbu standard, which defines two types of MAC for the egress port, namely pMAC (preemptable MAC) and eMAC (express MAC). Express frames can interrupt the transmission of preemptable frames." [^29^]

### 3.2 pMAC and eMAC Architecture

Frame preemption introduces two virtual MACs within a single physical MAC:

**eMAC (Express MAC):**
- Handles express (time-critical) traffic
- Has priority over pMAC
- Frames transmitted through eMAC cannot be preempted
- Uses standard Ethernet frame format

**pMAC (Preemptable MAC):**
- Handles preemptable (best-effort) traffic
- Can be interrupted by eMAC traffic
- Frames are fragmented when preemption occurs
- Uses fragment format defined in IEEE 802.3br

### 3.3 Frame Fragmentation and Reassembly

**Transmission Side (Fragmentation):**

When an express frame arrives while a preemptable frame is being transmitted:

1. The preemptable frame transmission is paused at a fragment boundary (64-byte multiple)
2. A Fragmentation Tail (mCRC) is appended to the fragment
3. The express frame is transmitted immediately
4. After the express frame completes, the remaining part of the preemptable frame is transmitted
5. If needed, multiple fragments can be created

**Fragment Format:**
```
Original Frame: [Preamble|SFD|DA|SA|...Payload...|FCS]
Fragment 1:     [SMD-E|DA|SA|...Payload(64B multiple)|mCRC]
Fragment 2:     [SMD-C|...Remaining Payload...|FCS]
```

SMD (Start/Modify Delimiter) codes:
- SMD-E (0xE6): Express frame
- SMD-S (0xE6): Start of preemptable frame
- SMD-C (0xE6): Continuation of preemptable frame
- SMD-R (0xE6): Verify fragment

**Reception Side (Reassembly):**
1. Receive fragments and buffer them
2. Use SMD codes to identify fragment sequence
3. Reassemble the original frame from fragments
4. Validate CRC on reassembled frame
5. Deliver to upper layers

### 3.4 Hold/Release Mechanism

The MAC Merge layer manages the preemption hold/release:

**Hold Mechanism:**
- When express traffic is pending, the eMAC requests hold on pMAC
- pMAC transmission pauses at the next fragment boundary
- Express frame is transmitted

**Release Mechanism:**
- After express frame completes, pMAC resumes transmission
- If multiple express frames are queued, they are transmitted in priority order
- pMAC only resumes when all express frames are cleared

**Hold/Release Timing:**
```
Time:  |---------- Express Frame ----------|
        |                |                  |
pMAC:   [Fragment 1][Frag2]     [Fragment 3][Frag4]
                       ^Hold^  Release^
```

### 3.5 Verification and Status

The TC4x GETH provides frame preemption status and verification:

**Verification Process:**
1. MAC Merge layer performs verification with link partner
2. Exchange verify mPackets to confirm both sides support preemption
3. Status tracked as: INITIAL, SUCCEEDED, FAILED, DISABLED

**Status Indicators:**
- MACMERGE_SUPPORT: Preemption supported
- MACMERGE_ENABLE: Preemption enabled
- MACMERGE_ACTIVE: Preemption active (link partner verified)
- MACMERGE_VERIFY_STATUS: Verification state

**Statistics Counters:**
```
- MACMergeFrameAssErrorCount: Frame assembly errors
- MACMergeFrameSmdErrorCount: SMD field errors
- MACMergeFrameAssOkCount: Successful frame assemblies
- MACMergeFragCountRx: Fragments received
- MACMergeFragCountTx: Fragments transmitted
- MACMergeHoldCount: Number of holds issued
```

### 3.6 GETH vs LETH Support

**Critical Difference**: Frame preemption is **only supported on GETH**, NOT on LETH.

| Feature | GETH | LETH |
|---|---|---|
| Frame Preemption | **Yes** | **No** |
| IEEE 802.3br MAC Merge | Yes | No |
| pMAC/eMAC | Dual virtual MAC | N/A |
| Fragmentation | Hardware | N/A |

> "以太网帧抢占是IEEE 802.1Qbu标准中规定的一项功能... Frame Preemption: Yes/No (GETH/LETH)" [^30^]

---

## 4. IEEE 802.1Qci - Filtering and Policing (PSFP)

### 4.1 Overview

IEEE 802.1Qci defines Per-Stream Filtering and Policing (PSFP), also known as Ingress Policing. It isolates network faults and malicious traffic by filtering and policing at the switch ingress port, preventing faulty streams from affecting other traffic.

> "To prevent interference from network failures or malicious attacks, 802.1Qci isolates failures to specific areas of the network. 802.1Qci is also known as Ingress Policing. It operates at the ingress of the switch, filtering and managing each traffic flow, referred to as PSFP (Per-Stream Filtering and Policing)." [^30^][^33^]

### 4.2 PSFP Architecture

PSFP consists of three main components [^13^][^30^]:

```
+-----------------------------------------------------+
|                    PSFP Pipeline                     |
+-----------------------------------------------------+
|  Stream Identification  |  Stream Gate  |  Flow Meter |
|                         |               |              |
|  FFP (Flexible Frame    |  GCL-based    |  PC (Police   |
|   Parser)               |  gate control |   Counter)    |
|                         |               |              |
|  - Matches stream       |  - Open/Close |  - Bandwidth |
|    patterns             |    per time   |    policing  |
|  - Maps to gateID       |    slot       |  - Burst     |
|  (max 8)                |  - Controls   |    control   |
|                         |    max octets |  - Mark/drop |
+-----------------------------------------------------+
```

### 4.3 Stream Filter - FFP (Flexible Frame Parser)

The Stream Filter is implemented using the Flexible Frame Parser (FFP) in the TC4x GETH MAC [^13^][^34^]:

**Function:**
- Identifies incoming frames belonging to specific streams
- Maps identified streams to one of 8 gate IDs
- Supports flexible frame parsing with programmable rules

**Stream Identification Methods:**
1. **Null Stream identification**: Based on destination MAC + VLAN ID
2. **Source MAC and VLAN Stream identification**: Based on source MAC + VLAN ID
3. **IP Stream identification**: Based on IP header fields
4. **Active Destination MAC and VLAN Stream identification**: Can modify MAC/VLAN

**FFP Capabilities:**
> "Stream filter: Implemented by the Flexible Frame Parser (FFP) in the AURIX TC4x GETH MAC, identifies the stream ID and maps to one of 8 gate IDs; only 8 gate IDs are supported." [^13^][^34^]

**Important Limitation:** The TC4x GETH FFP only supports **8 gate IDs**, which limits the number of concurrent stream filters that can be active.

### 4.4 Stream Gate - GCL-Based Control

The Stream Gate controls whether frames from a particular stream are allowed to pass:

**Function:**
- Opens or closes based on GCL entries
- Controls which streams can transmit during specific time slots
- Can enforce maximum SDU (Service Data Unit) size per stream

**Gate States:**
- **Open**: Frames from the stream are allowed to pass
- **Closed**: Frames from the stream are blocked/dropped

**Gate Control Parameters:**
- Gate state (open/closed)
- Internal Priority Value (IPV) - re-mapped priority for the stream
- Maximum octets allowed during the open interval
- Close gate due to invalid RX option
- Close gate due to octets exceeded option

### 4.5 Flow Meter - PC (Police Counter)

The Flow Meter is implemented using the Police Counter (PC) in the TC4x GETH MAC:

**Function:**
- Provides bandwidth policing per stream
- Uses a two-rate, three-color marker (RFC 2698) algorithm
- Protects TSN from traffic anomalies, attacks, or bridge failures

**Meter Types:**
- **Committed Information Rate (CIR)**: Assured bandwidth
- **Excess Information Rate (EIR)**: Additional bandwidth available

**Color Marking:**
- **Green**: Frame is within committed rate - forwarded
- **Yellow**: Frame exceeds committed rate but within excess rate - forwarded with DEI set
- **Red**: Frame exceeds excess rate - dropped

**PC Selection:**
> "Flow meter: Implemented by the Police Counter (PC) in the AURIX TC4x GETH MAC, selected via PC/PCN fields in frame parse instructions." [^30^][^33^]

### 4.6 Hardware vs Software Implementation

The TC4x implements PSFP partially in hardware and partially in software:

| PSFP Component | TC4x Implementation | Notes |
|---|---|---|
| Stream Filter (FFP) | **Hardware** | Flexible Frame Parser, 8 gate IDs |
| Stream Gate | **Hardware** | GCL-based gate control |
| Flow Meter (PC) | **Hardware** | Police Counter per stream |
| Stream Identification | **Hardware + SW** | FFP handles common patterns |
| Advanced Policing | **Software** | Complex policies need SW support |

**Limitations:**
- Only 8 gate IDs (limited number of concurrent stream filters)
- Some advanced PSFP features may require software assistance
- Both GETH and LETH marked as "partial" support

### 4.7 GETH vs LETH Support

| Feature | GETH | LETH |
|---|---|---|
| PSFP Support | Partial | Partial |
| Stream Filter (FFP) | Yes (8 gate IDs) | Limited |
| Stream Gate | Yes | Limited |
| Flow Meter (PC) | Yes | Limited |
| Number of Gates | 8 | Less than 8 |

---

## 5. IEEE 802.1CB - Frame Replication and Elimination (FRER)

### 5.1 Overview

IEEE 802.1CB provides Frame Replication and Elimination for Reliability (FRER). It sends copies of critical frames over multiple disjoint paths and eliminates duplicates at the receiving end, providing proactive seamless redundancy for control applications that cannot tolerate packet loss.

> "IEEE 802.1CB reliability frame replication and elimination (FRER) sends a copy of each frame over multiple disjoint paths. It can provide proactive seamless redundancy for control applications that cannot tolerate packet loss. Copies are sent over 2 (or more) disjoint paths, then merged and excess frames deleted at intersection points. Each copied frame has a sequence identifier used for reordering and merging frames, and discarding duplicate frames." [^13^][^30^][^33^]

### 5.2 FRER Architecture

**FRER Basic Operation:**

```
           Path 1 (Member Stream 1)
Talker ----->[R1]----------->[R3]-----> Listener
      |                                         ^
      | Path 2 (Member Stream 2)                |
      +->[R2]----------->[R4]-------------------+

R-TAG with Sequence Number added at Talker
Duplicates eliminated at Listener
```

**Key Concepts:**
- **Compound Stream**: The logical stream that is replicated
- **Member Streams**: The individual copies sent on different paths
- **R-TAG (Redundancy Tag)**: The tag containing the sequence number (EtherType: 0xF1C1)
- **Stream Splitting**: Creating multiple copies of a frame
- **Stream Merging**: Combining member streams and eliminating duplicates

### 5.3 Sequence Number Handling

**R-TAG Format:**
```
R-TAG:
- Reserved (2 bytes): 0x0000
- Sequence Number (2 bytes): 0 to 65535 (wraps around)
- Encapsulated Protocol (2 bytes): Original EtherType

Total R-TAG size: 6 bytes
EtherType: 0xF1C1
```

**Sequence Generation:**
- Sequence numbers generated from 0 to 65535 (GenSeqSpace = 65536)
- Incremented by 1 for each frame: GenSeqNum = (GenSeqNum + 1) mod 65536 [^50^]

**Sequence Recovery Algorithms:**

1. **Vector Recovery Algorithm**: 
   - Maintains a sequence history bit vector
   - Frames within history window that have been seen are discarded
   - Suitable for bulk streams
   - Configurable history length (frerSeqRcvyHistoryLength)
   - Timer-based reset for error recovery [^50^][^138^]

2. **Match Recovery Algorithm**:
   - Simple sequence number matching
   - If sequence number seen before, discard
   - Suitable for intermittent streams (one-by-one transmission)
   - Timer-based reset [^50^][^138^]

### 5.4 Stream Splitting and Merging

**Stream Splitting (at Talker or Relay):**
- Incoming frame with stream_handle is received
- Stream Split function creates 0 or more copies
- Each copy gets a different stream_handle (one may keep original)
- Sequence number is generated and encoded into R-TAG
- Copies are forwarded to different output ports

**Stream Merging (at Listener or Relay):**
- Member streams from different paths arrive
- Sequence numbers are decoded from R-TAG
- Recovery algorithm identifies and removes duplicates
- First unique copy is forwarded; subsequent duplicates are dropped
- Latent error detection monitors for lost paths

### 5.5 Software-Based Implementation in TC4x

The TC4x **does not** have dedicated FRER hardware. FRER is implemented in software, leveraging the hardware bridge for MAC-to-MAC forwarding [^13^][^30^][^33^]:

> "AURIX TC4x GETH supports MAC-to-MAC frame forwarding through the hardware bridge, which can be used to forward frames to target receivers, supporting FR application requirements." [^13^][^33^]

**Software Implementation Approach:**

1. **Frame Replication (Software):**
   - Software receives frame from application
   - Adds R-TAG with sequence number
   - Creates copies for each egress port
   - Uses GETH hardware bridge for port-to-port forwarding

2. **Frame Elimination (Software):**
   - Software processes incoming frames from multiple ports
   - Extracts sequence number from R-TAG
   - Runs vector or match recovery algorithm
   - Forwards first unique frame, drops duplicates

3. **Hardware Bridge Support:**
   - GETH bridge connects two Ethernet ports and host interface
   - Enables MAC-to-MAC frame forwarding
   - Used for routing replicated frames between ports

**TC4x FRER Software Architecture:**
```
Application Layer
      |
      v
+-----+-----+
| FRER SW   |  <- Sequence generation/recovery (software)
| (802.1CB) |
+-----+-----+
      |
      v
+-----+-----+
| GETH HW   |  <- Frame tx/rx, bridge forwarding
| Bridge    |
+-----+-----+
      |
      v
   Ports
```

**Key Software Components:**
- Stream Identification module
- Sequence Generation module
- Sequence Recovery module (with vector/match algorithms)
- R-TAG Encode/Decode module
- Stream Splitting module
- Stream Merging module
- Latent Error Detection module

### 5.6 GETH vs LETH Support

| Feature | GETH | LETH |
|---|---|---|
| FRER Support | Software-based | Software-based |
| Hardware Bridge | Yes (for MAC-to-MAC forwarding) | Limited |
| R-TAG Processing | Software | Software |
| Sequence Recovery | Software | Software |

---

## 6. Summary: GETH vs LETH TSN Feature Comparison

### 6.1 Feature Support Matrix

| TSN Feature | IEEE Standard | GETH Support | LETH Support | Notes |
|---|---|---|---|---|
| Credit Based Shaper | 802.1Qav | Full HW | Full HW | 8 queues (GETH), 4 queues (LETH) |
| Time-Aware Shaper | 802.1Qbv | Full HW | Full HW | Dual GCL banks on both |
| Frame Preemption | 802.1Qbu/802.3br | **Full HW** | **Not Supported** | Key differentiator |
| PSFP | 802.1Qci | Partial HW | Partial HW | 8 gate IDs on GETH |
| FRER | 802.1CB | SW-based | SW-based | Uses HW bridge (GETH) |

### 6.2 Key Differences

1. **Frame Preemption (802.1Qbu)**: The most significant difference - GETH supports hardware frame preemption while LETH does not. This makes GETH essential for applications requiring the lowest possible latency with preemption-based guard band reduction.

2. **Queue Count**: GETH supports up to 8 traffic class queues while LETH supports 4 queues, affecting the granularity of traffic prioritization.

3. **Speed**: GETH supports up to 5Gbps while LETH supports up to 100Mbps (or 10BASE-T1S).

4. **Hardware Bridge**: GETH includes a full hardware bridge for MAC-to-MAC forwarding, which is essential for FRER and switch applications.

### 6.3 Application Guidance

- **Use GETH when**: High bandwidth (>100Mbps), frame preemption, complex TSN scheduling, or switch/bridge functionality is required
- **Use LETH when**: Lower bandwidth (10/100Mbps), cost-sensitive applications, 10BASE-T1S is needed, or basic CBS/TAS is sufficient

---

## 7. References

[^13^] Infineon, "AURIX TC4x GETH introduces support for time-sensitive networking," EEWorld, 2024. https://en.eeworld.com.cn/mp/Infineon-Ecosystem/a389388.jspx

[^28^] 英飞凌, "Aurix TC4x 以太网GETH模块详解," 10100.com, 2025. https://m.10100.com/article/24352199

[^29^] Infineon, "AURIX TC4x GETH supports time-sensitive networking," EEWorld, 2025. https://en.eeworld.com.cn/news/qrs/eic701590.html

[^30^] Infineon, "英飞凌AURIX TC4x入门指南," Infineon Training, 2025. https://www.infineon.cn/assets/china/public/documents/10/tc4--b5--25.07.15--final.pdf

[^33^] Infineon, "AURIX TC4x GETH对时间敏感网络的支持介绍," Sina Finance, 2025. https://finance.sina.com.cn/tech/roll/2025-01-10/doc-ineenatz5657501.shtml

[^34^] Infineon, "AURIX TC4x GETH introduces support for time-sensitive networking," EEWorld, 2024. https://en.eeworld.com.cn/mp/Infineon-Ecosystem/a389388.jspx

[^41^] Infineon, "AURIX TC4Dx errata sheet," Infineon Official, 2025. https://www.infineon.com/assets/row/public/documents/10/52/infineon-aurix-tc4dx-ab-es-erratasheet-en.pdf

[^50^] NXP/Linux Kernel, "introduce a frer action to implement 802.1CB," LKML, 2021. https://lkml.org/lkml/2021/9/28/535

[^77^] Infineon, "Feature list | AURIX TC4xx Documentation," Infineon Documentation, 2025. https://documentation.infineon.com/aurixtc4xx/docs/dxd1545132654390

[^104^] Infineon, "車載以太網和AURIX TC4x 千兆以太網/時間敏感網絡概覽," WPGDadatong, 2024. https://www.wpgdadatong.com/blog/detail/75463

[^106^] Infineon, "英飞凌(Infineon)：车载以太网和AURIX TC4x千兆以太网/时间敏感网络概览," Cmalls, 2024. https://www.cmalls.net/news/16042.html

[^111^] Intel/Linux Kernel, "introduce IEEE 802.1Qbv configuration functionalities," LKML, 2019. https://lkml.org/lkml/2019/6/18/528

[^114^] Infineon, "LETH Lite Ethernet Training," Infineon Training, 2025. https://www.infineon.com/row/public/documents/10/56/infineon-aurix-tc4x-lite-ethernet-v1.0.pdf-training-en.pdf

[^119^] IC Navigator, "TSN Switch/Bridge: 802.1AS, Qbv, Qbu, HW PTP," 2026. https://icnavigator.com/technology/interfaces-phy-serdes/tsn-switch-bridge/

[^125^] CSDN, "AURIX TC4x GETH对时间敏感网络的支持介绍," CSDN, 2025. https://blog.csdn.net/wpgddt/article/details/145677184

[^126^] LWN.net, "802.1Q Frame Preemption and 802.3 MAC Merge support via ethtool," LWN. https://lwn.net/Articles/904970/

[^137^] Infineon, "AURIX TC4x GETH對時間敏感網絡的支持介紹," WPGDadatong, 2025. https://www.wpgdadatong.com/blog/detail/76725

[^138^] CSDN, "TSN协议之冗余协议——IEEE 802.1 CB," CSDN, 2021. https://blog.csdn.net/m0_47334080/article/details/118018119

[^141^] CSDN, "TSN协议之冗余协议——IEEE 802.1 CB," CSDN, 2021. https://blog.csdn.net/m0_47334080/article/details/118018119

---

*Document compiled from Infineon official documentation, training materials, errata sheets, and technical articles. Last updated: 2025.*
