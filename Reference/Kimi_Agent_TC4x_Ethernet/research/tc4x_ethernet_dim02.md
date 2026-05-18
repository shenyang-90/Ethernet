# Dimension 2: GETH DMA & Descriptor Mechanism - AURIX TC4x

## Table of Contents
1. [DMA Architecture](#1-dma-architecture)
2. [Descriptor Structure Overview](#2-descriptor-structure-overview)
3. [Transmit Descriptor Fields](#3-transmit-descriptor-fields)
4. [Receive Descriptor Fields](#4-receive-descriptor-fields)
5. [Ring Buffer Management](#5-ring-buffer-management)
6. [Transmit Flow](#6-transmit-flow)
7. [Receive Flow](#7-receive-flow)
8. [Checksum Offload](#8-checksum-offload)
9. [PTP Timestamping](#9-ptp-timestamping)
10. [Key Registers](#10-key-registers)
11. [Errata and Workarounds](#11-errata-and-workarounds)

---

## 1. DMA Architecture

### 1.1 Overview

The AURIX TC4x GETH module integrates a high-performance multi-channel DMA engine based on the Synopsys DWC_xgmac IP core. The DMA is responsible for transferring data between system memory and the MTL (MAC Transaction Layer) without CPU intervention [^43^][^28^].

> "The DMA is responsible for transferring received data packets from external interfaces to RX Buffers in system memory, and transferring data from Tx Buffers in system memory that needs to be sent out. The DMA contains 8 independent channels (compared to 4 in the previous generation), each with its own Tx engine and Rx engine. The Tx Engine direction is from system memory to MTL, and the Rx Engine is from MTL to system memory." [^28^]

### 1.2 Eight DMA Channels

**Key architectural features** [^43^][^62^]:

| Feature | TC4x GETH | TC3x GETH (for comparison) |
|---------|-----------|---------------------------|
| DMA Channels | 8 independent | 4 independent |
| Tx Descriptors per channel | Up to 64K | Limited |
| Rx Descriptors per channel | Up to 64K | Limited |
| Enhanced descriptor | Yes (time-based scheduling) | Basic |
| Header/Payload split | Yes | Limited |
| Descriptor size | 16 bytes (4 words) | 16 bytes (4 words) |

Each DMA channel has:
- **Independent Tx Engine**: Transfers data from system memory to MTL Tx queues
- **Independent Rx Engine**: Transfers data from MTL Rx queues to system memory
- **Dedicated descriptor lists**: One Tx descriptor ring and one Rx descriptor ring per channel
- **Independent interrupt control**: Channel-specific status and interrupt enable registers

### 1.3 Channel Assignment and Mapping

The TC4x GETH provides flexible queue-to-DMA channel mapping [^99^][^67^]:

```c
// Example iLLD configuration showing multi-queue/channel setup
GethConfig.dma.numOfTxChannels = 2;
GethConfig.dma.numOfRxChannels = 1;

GethConfig.dma.txChannel[0].channelId = IfxGeth_TxDmaChannel_0;
GethConfig.dma.txChannel[1].channelId = IfxGeth_TxDmaChannel_1;

GethConfig.mtl.rxQueue[0].rxDmaChannelMap = IfxGeth_RxDmaChannel_0;
```

Rx queues can be dynamically mapped to DMA channels through `rxq-dyn-dma-en` and `rxq-dma-ch-sel` configurations [^67^].

### 1.4 Priority and Arbitration Scheme

The DMA supports two arbitration modes controlled by the `DMA_Mode` register [^66^][^52^]:

**1. Weighted Round Robin (WRR)** - `DA = 0` in DMA_Mode:
- Configurable weights for Tx and Rx DMA via `TXPR` and `PR` fields
- Distributes bandwidth proportionally among channels
- **Known issue**: In single-queue/single-DMA configurations, QoS requirements may not be met when both Tx and Rx simultaneously request access [^52^]

**2. Fixed Priority** - `DA = 1` in DMA_Mode:
- Rx DMA has higher priority over Tx (`TXPR = 0`)
- Strict priority based on channel number
- **Workaround recommended** for the WRR issue: "Operate in Fixed Priority arbitration mode (DA=1) with Rx DMA having higher priority over Tx (TXPR=0). Operate the Tx buffers in Store-and-Forward mode to avoid any buffer Underflows/Overflows." [^52^]

**Descriptor Read Priority**:
The `TDRP` bit in DMA_Mode controls descriptor fetch priority [^66^]:
- `TDRP = 0`: RxDMA descriptor fetches have higher priority (default)
- `TDRP = 1`: TxDMA descriptor fetches have higher priority

### 1.5 Programmable Burst Length (PBL)

Each DMA channel supports programmable burst length [^67^][^100^]:
- Configurable via `dma-ch-txpbl` and `dma-ch-rxpbl` fields
- Supported values: 4, 5, 16, 32, 64, 128, 256 beats
- Default: 32 beats
- 8xPBL mode available: Multiplies PBL by 8 (range: 8-2048 beats)
- Configured through DMA_CHx_Tx_Control and DMA_CHx_Rx_Control registers [^100^]

### 1.6 Pipeline Architecture

The DMA operates with a 3-stage pipeline for maximum throughput [^28^]:

```
Stage 1: Descriptor Fetch      Stage 2: Data Transfer      Stage 3: Descriptor Write-Back
        |                              |                             |
        v                              v                             v
   [Prefetch next]               [Transfer packet N]          [Write-back packet N-2]
```

> "All DMA phases operate in a pipelined fashion: descriptor fetching for a new packet can occur simultaneously with data transfer for the previous packet, while descriptor write-back for the packet before that is also executing. This pipelined mechanism effectively reduces packet transmission intervals and significantly improves overall throughput." [^28^]

---

## 2. Descriptor Structure Overview

### 2.1 Basic Descriptor Format

All GETH DMA descriptors are **16 bytes** (4 x 32-bit words) in size [^28^][^64^]:

```
+--------+--------+--------+--------+
| Word 0 | Word 1 | Word 2 | Word 3 |
| (DES0) | (DES1) | (DES2) | (DES3) |
| 4 bytes| 4 bytes| 4 bytes| 4 bytes|
+--------+--------+--------+--------+
    ^         ^         ^         ^
   TDES0    TDES1     TDES2     TDES3   (Transmit)
   RDES0    RDES1     RDES2     RDES3   (Receive)
```

### 2.2 Descriptor Types

The GETH supports two descriptor formats [^48^][^44^]:

#### 2.2.1 Normal Descriptor

Used for standard packet transmission/reception. Contains buffer addresses, lengths, and control/status flags.

**Read-Format**: Written by software before DMA processing
**Write-Back Format**: Written by DMA after processing completion

#### 2.2.2 Context Descriptor (Enhanced Descriptor)

Used for additional control information and extended status:
- **Transmit Context Descriptor**: Provides timestamp for one-step timestamp correction, VLAN tag, and MSS for TSO
- **Receive Context Descriptor**: Carries extended status including PTP timestamp information

The context descriptor is valid for the current packet and subsequent packets until a new context is provided [^48^].

### 2.3 Descriptor Organization: Ring Structure

Descriptors are organized as a **ring buffer (circular linked list)** in system memory [^28^][^64^]:

```
Descriptor Ring Structure:
                    +-------------+
                    |  Desc [0]   | <--- List Base Address
                    +-------------+
                          |
                          v
                    +-------------+
                    |  Desc [1]   |
                    +-------------+
                          |
                          v
                         ...
                          |
                          v
                    +-------------+
                    |  Desc [N-1] | <--- Ring Length (N descriptors)
                    +-------------+
                          |
                          v (wraps around)
                    +-------------+
                    |  Desc [0]   |
                    +-------------+
```

Key ring parameters [^44^]:
- **TDES3_RING_LENGTH** / **RDES3_RING_LENGTH**: Number of descriptors in ring (up to 64K)
- **TXDESC_LIST_ADDRESS** / **RXDESC_LIST_ADDRESS**: Base address of descriptor ring
- **TXDESC_TAIL_POINTER** / **RXDESC_TAIL_POINTER**: Points to descriptor after last valid one
- **CURRENT_TXDESC** / **CURRENT_RXDESC**: Points to descriptor currently being processed

> "The number of descriptors in the list is configured by the corresponding transmit/receive descriptor ring length register. When the DMA processes the last descriptor in the list, it jumps back to the descriptor pointed to by the list address register, forming the descriptor ring structure." [^28^]

---

## 3. Transmit Descriptor Fields

### 3.1 Transmit Normal Descriptor (Read Format)

The read format is used by software to set up the descriptor before handing it to the DMA [^68^][^27^]:

#### TDES0 (Transmit Descriptor Word 0)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | BUF1AP | Buffer 1 Address Pointer - Physical address of first data buffer [^27^] |

#### TDES1 (Transmit Descriptor Word 1)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | BUF2AP | Buffer 2 Address Pointer - Physical address of second buffer (optional) [^27^] |

> "BUF2AP: Buffer 2 address, but we generally do not use it, including Infineon's official MCAL code" [^27^]

#### TDES2 (Transmit Descriptor Word 2)

| Bits | Field | Description |
|------|-------|-------------|
| [31] | IOC | **Interrupt on Completion** - When set, triggers TI/ETI interrupt after packet transmission [^27^][^68^] |
| [30] | TTSE | **Transmit Timestamp Enable** - Enables IEEE 1588 timestamp capture for this packet [^27^][^68^] |
| [29:16] | B2L | Buffer 2 Length - Length of data in buffer 2 (in bytes) [^27^] |
| [15:14] | VTIR | VLAN Tag Insertion/Replacement - Controls VLAN tagging (00=none, 01=remove, 10=insert, 11=replace) [^68^] |
| [13:0] | B1L | Buffer 1 Length - Length of data in buffer 1 (in bytes) [^27^] |

#### TDES3 (Transmit Descriptor Word 3)

| Bits | Field | Description |
|------|-------|-------------|
| [31] | **OWN** | **Ownership bit** - 1=DMA owns descriptor, 0=CPU owns descriptor [^27^][^39^] |
| [30] | CTXT | Context descriptor indicator - 0=Normal descriptor [^27^] |
| [29] | FD | **First Descriptor** - Set for first descriptor of a packet [^27^] |
| [28] | LD | **Last Descriptor** - Set for last descriptor of a packet [^27^] |
| [27:26] | **CPC** | **CRC Pad Control** - Controls CRC insertion and padding [^27^] |
| [25:23] | **SAIC** | **Source Address Insertion Control** - Controls SA insertion/replacement [^27^] |
| [22:19] | SLOTNUM | Slot Number Control Bits in AV Mode [^27^] |
| [18] | RES | Reserved |
| [17:16] | **CIC/TPL** | **Checksum Insertion Control / TCP Payload Length** [^27^] |

**OWN Bit Detail** [^39^][^27^]:
> "OWN: **DMA ownership flag bit**. When set, it indicates that DMA has control of the descriptor. It will read the corresponding Buffer and write back the descriptor, clearing this bit."

**Important erratum**: A race condition exists between CPU and GMAC DMA where the DMA may read an old TDES2 value (e.g., length=0) along with a new TDES3 (OWN bit set) due to data integrity issues at different clock domains (CPU: 300MHz, GMAC DMA: 150MHz or less) [^39^].

### 3.2 Transmit Normal Descriptor (Write-Back Format)

After completing transmission, the DMA writes back the descriptor with status information [^65^][^68^]:

#### TDES0 (Write-Back)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | TTSL | **Transmit Packet Timestamp Low** - Lower 32 bits of captured timestamp [^65^] |

#### TDES1 (Write-Back)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | TTSH | **Transmit Packet Timestamp High** - Upper 32 bits of captured timestamp [^65^] |

#### TDES2 (Write-Back)

Reserved.

#### TDES3 (Write-Back)

| Bits | Field | Description |
|------|-------|-------------|
| [31] | OWN | Cleared to 0 - descriptor returned to CPU |
| [30] | CTXT | Context type indicator |
| [29] | FD | First Descriptor |
| [28] | LD | Last Descriptor |
| [27:24] | Reserved | - |
| [23] | DE | **Descriptor Error** - Indicates descriptor content was incorrect [^68^] |
| [22:18] | Reserved | - |

> "The write-back is only applicable to the last descriptor of the corresponding packet. The LD bit (TDES3[28]) is set in the descriptor where the DMA writes back the transmission status and timestamp information." [^68^]

Timestamp write-back conditions [^65^]:
- TTSE bit must be set in TDES2 of the first descriptor of the packet
- LD bit must be set
- Timestamp Status (TTSS) bit must be set

### 3.3 Transmit Context Descriptor

Used for one-step timestamp correction and TSO configuration [^68^][^69^]:

#### TDES0 (Context)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | TTSL | Timestamp Low for one-step correction |

#### TDES1 (Context)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | TTSH | Timestamp High for one-step correction |

#### TDES2 (Context)

| Bits | Field | Description |
|------|-------|-------------|
| [31:16] | IVT | Inner VLAN Tag (valid when IVLTV=1) |
| [15:0] | MSS | Maximum Segment Size for TSO (valid when TCMSSV=1) |

#### TDES3 (Context)

| Bits | Field | Description |
|------|-------|-------------|
| [31] | OWN | DMA ownership |
| [30] | CTXT | Must be 1 (context descriptor) |
| [29:28] | Reserved | - |
| [27] | OSTC | **One-Step Timestamp Correction Enable** [^68^] |
| [26] | TCMSSV | Timestamp Correction Input or MSS Valid [^68^] |
| [25:24] | Reserved | - |
| [23] | CDE | Context Descriptor Error |
| [22:20] | Reserved | - |
| [19] | IVLTV | Inner VLAN Tag Valid |
| [18] | VLTV | VLAN Tag Valid |
| [17:0] | VT | VLAN Tag for insertion/replacement |

### 3.4 Field Details: CPC (CRC Pad Control)

The CPC field controls CRC and padding behavior [^27^]:

| CPC[27:26] | Behavior |
|------------|----------|
| 00 | CRC and Pad insertion - MAC appends CRC and pads short frames |
| 01 | Pad insertion only - MAC pads but does not append CRC |
| 10 | CRC insertion only - MAC appends CRC but does not pad |
| 11 | No CRC, no Pad - Application provides complete frame |

### 3.5 Field Details: SAIC (Source Address Insertion Control)

Controls automatic SA insertion/replacement [^27^][^28^]:

| SAIC[25:23] | Behavior |
|-------------|----------|
| 000 | SA insertion disabled |
| 001 | Insert SA from MAC_Address0 registers |
| 010 | Replace SA with MAC_Address0 registers |
| Others | Reserved |

> "Can be configured to let the MAC layer automatically modify the source MAC address based on the MAC address registers, without requiring upper-layer specification." [^27^]

### 3.6 Field Details: CIC (Checksum Insertion Control)

Controls hardware TCP/IP checksum calculation [^27^]:

| CIC[17:16] | Behavior |
|------------|----------|
| 00 | Checksum insertion disabled |
| 01 | IP header checksum only |
| 10 | IP header + TCP/UDP/ICMP checksum (pseudo-header included) |
| 11 | Reserved |

---

## 4. Receive Descriptor Fields

### 4.1 Receive Normal Descriptor (Read Format)

#### RDES0 (Receive Descriptor Word 0)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | BUF1AP | Buffer 1 Address Pointer - Physical address of receive buffer [^44^] |

#### RDES1 (Receive Descriptor Word 1)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | BUF2AP | Buffer 2 Address Pointer or Header buffer (optional) [^44^] |

#### RDES2 (Receive Descriptor Word 2)

Reserved in read format.

#### RDES3 (Receive Descriptor Word 3)

| Bits | Field | Description |
|------|-------|-------------|
| [31] | OWN | **Ownership bit** - 1=DMA owns, 0=CPU owns [^44^] |
| [30] | INTE | Normal/Context descriptor indicator [^44^] |
| [29:28] | Reserved | - |
| [27] | BUF2V | Buffer 2 Address Valid |
| [26] | BUF1V | Buffer 1 Address Valid |
| [25:24] | Reserved | - |
| [23:14] | Reserved | - |
| [13:0] | Reserved | - |

### 4.2 Receive Normal Descriptor (Write-Back Format)

After packet reception, the DMA writes back status information [^44^][^103^]:

#### RDES0 (Write-Back)

| Bits | Field | Description |
|------|-------|-------------|
| [31:16] | OVT | Outer VLAN Tag (if RS0V=1) [^103^] |
| [15:0] | IVT | Inner VLAN Tag (if RS0V=1) [^103^] |

#### RDES1 (Write-Back)

| Bits | Field | Description |
|------|-------|-------------|
| [31:16] | OPC | OAM Sub-Type Code [^103^] |
| [15] | TD | **Timestamp Dropped** - Timestamp captured but lost due to overflow [^103^] |
| [14] | TSA | **Timestamp Available** - Next context descriptor contains valid timestamp [^103^] |
| [13] | PV | PTP Version |
| [12] | PFT | PTP Packet Type |
| [11:8] | PMT | PTP Message Type |
| [7] | IPCE | IP Payload Error |
| [6] | IPCB | IP Checksum Bypassed |
| [5] | IPV6 | IPv6 Header Present |
| [4] | IPV4 | IPv4 Header Present |
| [3] | IPHE | IP Header Error |
| [2:0] | PT | **Payload Type** (000=UDP, 001=TCP, 010=ICMP) [^103^] |

#### RDES2 (Write-Back)

| Bits | Field | Description |
|------|-------|-------------|
| [31:27] | Reserved | - |
| [26:19] | MADRM | MAC Address Match or Hash Value [^103^] |
| [18] | HF | Hash Filter Status |
| [17] | DAF | Destination Address Filter Fail |
| [16] | SAF | Source Address Filter Fail |
| [15] | OTS | VLAN Filter Status |
| [14] | ITS | Inner VLAN Tag Filter Status |
| [13:11] | Reserved | - |
| [10] | ARPNR | ARP Reply Not Generated |
| [9:0] | HL | L3/L4 Header Length [^103^] |

#### RDES3 (Write-Back)

| Bits | Field | Description |
|------|-------|-------------|
| [31] | OWN | Cleared to 0 |
| [30] | CTXT | Context type indicator |
| [29] | FD | **First Descriptor** of packet |
| [28] | LD | **Last Descriptor** of packet |
| [27] | RS2V | RDES2 Valid (contains extended status) |
| [26] | RS1V | RDES1 Valid (contains extended status) |
| [25] | RS0V | RDES0 Valid (contains VLAN tag info) |
| [24] | CE | CRC Error |
| [23] | GP | Giant Packet |
| [22] | RWT | Receive Watchdog Timeout |
| [21] | OE | Overflow Error |
| [20] | RE | Receive Error |
| [19] | DE | Dribble Error |
| [18:16] | LT | Length/Type Field |
| [15] | ES | Error Summary |
| [14:0] | PL | **Packet Length** (received frame size in bytes) |

### 4.3 Receive Context Descriptor (Write-Back Only)

The receive context descriptor provides the PTP timestamp for the previously received packet [^68^]:

#### RDES0 (Context)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | RTSL | **Receive Packet Timestamp Low** - Lower 32 bits of capture timestamp [^68^] |

#### RDES1 (Context)

| Bits | Field | Description |
|------|-------|-------------|
| [31:0] | RTSH | **Receive Packet Timestamp High** - Upper 32 bits of capture timestamp [^68^] |

#### RDES2 (Context)

Reserved.

#### RDES3 (Context)

| Bits | Field | Description |
|------|-------|-------------|
| [31] | OWN | DMA ownership (cleared) |
| [30] | CTXT | Always 1 (context descriptor) |
| [29] | DE | Descriptor Error |
| [28:0] | Reserved | - |

> "This descriptor is read-only for the application. Only the DMA can write this descriptor. The context descriptor provides extended status information related to the last received packet." [^68^]

---

## 5. Ring Buffer Management

### 5.1 Key Registers

Each DMA channel has dedicated registers for ring management [^44^][^100^]:

| Register | Description |
|----------|-------------|
| `DMA_CHx_TxDesc_List_HAddress` | Upper 32 bits of Tx descriptor list base address (40/48-bit mode) [^100^] |
| `DMA_CHx_TxDesc_List_LAddress` | Lower 32 bits of Tx descriptor list base address |
| `DMA_CHx_RxDesc_List_HAddress` | Upper 32 bits of Rx descriptor list base address |
| `DMA_CHx_RxDesc_List_LAddress` | Lower 32 bits of Rx descriptor list base address |
| `DMA_CHx_TxDesc_Ring_Length` | Number of Tx descriptors in ring (up to 64K) [^62^] |
| `DMA_CHx_RxDesc_Ring_Length` | Number of Rx descriptors in ring (up to 64K) [^62^] |
| `DMA_CHx_TxDesc_Tail_Pointer` | Points to descriptor after last valid descriptor [^44^] |
| `DMA_CHx_RxDesc_Tail_Pointer` | Points to descriptor after last valid descriptor |
| `DMA_CHx_Current_App_TxDesc_L` | Lower 32 bits of current Tx descriptor being processed [^56^] |
| `DMA_CHx_Current_App_RxDesc_L` | Lower 32 bits of current Rx descriptor being processed |
| `DMA_CHx_Current_App_TxBuffer_L` | Current Tx buffer address being processed |

### 5.2 Ring Operation Example

From an actual memory snapshot showing 4 Tx descriptors [^44^]:

```
Descriptor Ring (4 entries):

  Desc[0]    Desc[1]    Desc[2]    Desc[3]
  +------+   +------+   +------+   +------+
  | TDES0|   | TDES0|   | TDES0|   | TDES0|
  | TDES1|   | TDES1|   | TDES1|   | TDES1|
  | TDES2|   | TDES2|   | TDES2|   | TDES2|
  | TDES3|   | TDES3|   | TDES3|   | TDES3|
  +------+   +------+   +------+   +------+
     ^            ^
     |            |
  LIST_BASE   CURRENT_TXDESC (pointing to Desc[1])

  TXDESC_RING_LENGTH = 3 (meaning 4 descriptors, 0-3)
```

> "We can see that CURRENT_TXDESC points to the second descriptor, meaning that if we want to send data, we use this descriptor. TXDESC_LIST_ADDRESS points to the first descriptor, and TXDESC_RING_LENGTH is 3 indicating 4 descriptors are configured." [^44^]

### 5.3 Software Flow for Ring Management

**Initialization** [^64^]:
```c
/* Initialize descriptors in ring mode */
for (i = 0; i < IFXGETH_MAX_TX_DESCRIPTORS; i++) {
    descr->TDES0.U = (uint32)(config->txBuffer1Size * i) + buffer1StartAddress;
    descr->TDES1.U = 0; /* buffer2 not used */
    descr->TDES2.U = (IFXGETH_MAX_TX_BUFFER_SIZE & 0x3FFF); /* B1L */
    descr->TDES3.U = 0xB0000000U | (1 << 28) | (1 << 29); /* OWN=1, FD=1, LD=1 */
    descr++;
}
```

**Processing cycle**:
1. Software fills buffer and sets OWN=1 to give descriptor to DMA
2. Software updates Tail Pointer register to trigger DMA polling
3. DMA processes descriptor (reads data, transmits)
4. DMA clears OWN=0 and writes back status
5. Software checks OWN=0 to reclaim descriptor, processes status/timestamp
6. Software refills buffer and sets OWN=1 again

---

## 6. Transmit Flow

### 6.1 DMA Transmit Operation Sequence

The TxDMA data transfer operates as follows [^44^][^74^]:

```
Step 1: Descriptor Fetch
    The descriptor fetch engine reads valid descriptors (OWN=1)
    from system memory or descriptor prefetch cache.
           |
           v
Step 2: Control Processing
    The engine processes descriptor control bits and buffer sizes,
    calculates data transfer amount based on TxPBL register setting.
    Checks TxQ availability before issuing transfer requests.
           |
           v
Step 3: Data Transfer
    AXI master accepts request and schedules it on the bus.
    The engine immediately calculates the next transfer amount
    and issues a new request (pipelined).
           |
           v
Step 4: Buffer Completion
    When all valid buffer data is extracted, descriptor is released
    and pushed to the descriptor write-back engine for closure.
    Next descriptor from prefetch cache enters processing.
           |
           v
Step 5: Write-Back
    DMA writes timestamp (if TTSE=1) to TDES0/TDES1
    DMA writes status and clears OWN bit in TDES3
    If IOC=1, transmit interrupt is triggered
```

### 6.2 Detailed Transmit Steps

1. **Descriptor fetch engine** reads valid descriptors (OWN=1) from system memory or prefetch cache and delivers to data transfer engine [^44^]

2. Engine processes descriptor control bits and buffer sizes, calculates data transfer amount based on **TxPBL** register. Before initiating transfer, checks if corresponding **TxQ** has available space [^44^]

3. When AXI master accepts the request, the engine immediately calculates next transfer and issues a new request. Second request may be:
   - (a) Continuation burst of same buffer
   - (b) Buffer 2 data burst (if buffer 1 complete)
   - (c) Next descriptor's buffer 1 (if buffer 2 empty/complete)
   - (d) New packet's buffer (if entire packet complete) [^44^]

4. **At most two outstanding transfer requests** are allowed at any time [^44^]

5. When requested data is extracted and written to MTL TxQ, the request is considered complete

6. When all valid buffer data is extracted, descriptor is released to write-back engine

### 6.3 Suspend and Resume

> "After DMA initialization, it stays in the Suspend Tx DMA Queue state waiting. When the user writes to the **descriptor tail register**, the DMA begins Transmit polling, and returns to the Suspend state after transmission completes." [^35^]

**Key behaviors**:
- **CURRENT_TXDESC** is the key handle to the descriptor list - advances to next descriptor after each transmission [^35^]
- After processing the last descriptor, wraps around to the first descriptor
- DMA enters suspend state when it encounters a descriptor with OWN=0
- Writing to Tail Pointer register wakes up the DMA from suspend

### 6.4 Operate on Second Packet (OSF) Mode

When OSF mode is enabled, the DMA can process the second packet before closing the first packet's descriptor [^74^]:

> "Without closing the previous frame's last descriptor, the DMA fetches the next descriptor." [^74^]

This allows overlapping processing for higher throughput. The descriptor chain must have **more than two different descriptors** for correct operation in OSF mode.

---

## 7. Receive Flow

### 7.1 DMA Receive Operation Sequence

The RxDMA data transfer operates as follows [^44^]:

```
Step 1: Descriptor Fetch
    Descriptor fetch engine reads valid descriptors (OWN=1)
    from system memory or prefetch cache.
           |
           v
Step 2: Ready Signal
    Data transfer engine calculates burst length based on
    buffer size and RxPBL, signals ready to MTL Rx queue reader.
           |
           v
Step 3: Queue Selection
    Rx queue read controller selects a receive queue
    (for multi-queue configurations) and triggers RxDMA.
           |
           v
Step 4: Data Transfer
    RxDMA issues transfer request, AXI master executes.
    Data is written to system memory buffer via AXI write channel.
           |
           v
Step 5: Completion Check
    If EOP (End of Packet) not yet transferred, return to Step 2.
    If buffers full but packet incomplete, write intermediate
    status and fetch next descriptor.
    If EOP received, get final packet status, push to write-back.
           |
           v
Step 6: Write-Back + Context
    DMA writes status to normal descriptor (clears OWN)
    If timestamp enabled, writes timestamp to context descriptor
    If IOC=1, receive interrupt is triggered
```

### 7.2 Detailed Receive Steps

1. Descriptor fetch engine reads valid descriptors (OWN=1) and delivers to data transfer engine [^44^]

2. Data transfer engine calculates supported burst transfer length based on buffer size and **RxPBL** register setting, signals readiness to MTL Rx queue read controller [^44^]

3. Rx queue read controller selects a receive queue and triggers RxDMA [^44^]

4. RxDMA engine issues transfer request, AXI master receives and executes. Data is transferred to system memory buffer via AXI write channel [^44^]

5. If data transfer completes internally but packet transfer is not complete (EOP flag not transferred), engine returns to Step 2 [^44^]

6. If both receive buffers pointed to by descriptor are full, engine pushes descriptor with intermediate status to write-back engine, fetches next descriptor from prefetch cache, returns to Step 2 [^44^]

7. If EOP flag is transferred during last burst, engine gets final packet status from Rx queue, pushes descriptor to write-back engine, returns to Step 2 [^44^]

### 7.3 Receive Context Descriptor

> "Compared to transmit descriptors, receive descriptors have more write-back content, so their status write-back occupies an additional **enhanced descriptor** for supplementary status information." [^44^]

The context descriptor follows the normal descriptor in memory when enhanced status/timestamping is enabled. It contains:
- **RDES0**: Receive Timestamp Low (RTSL)
- **RDES1**: Receive Timestamp High (RTSH)
- **RDES3**: OWN bit, CTXT=1, DE flag

### 7.4 Application Processing

After reception, the application must [^44^]:
1. Check OWN=0 (descriptor returned by DMA)
2. Read packet data from buffer
3. Read status fields (PL for packet length, ES for error summary)
4. If TSA=1, read timestamp from context descriptor
5. Reinitialize descriptor (set OWN=1) to return buffer to DMA
6. Update tail pointer if needed

---

## 8. Checksum Offload

### 8.1 Overview

The TC4x GETH provides hardware checksum calculation for IP, TCP, and UDP packets in both transmit and receive directions [^78^][^93^]:

> "IPv4 header checksum offload on reception. TCP, UDP, or ICMP checksum offload (IPv4 and IPv6) for received packets." [^78^]

### 8.2 Receive-Side Checksum

On reception, the hardware:
1. Parses incoming frame and verifies Ethernet CRC/FCS
2. Checks Length/Type field for IPv4 (0x0800) or IPv6 (0x86DD)
3. Verifies IP version field matches encapsulation type
4. Computes checksum over IPv4 header fields (including checksum field)
5. Result 0xFFFF indicates correct checksum; any mismatch reported as error
6. Computes checksum over IP payload (TCP/UDP segment)
7. Reports IPv4 header checksum error and TCP/UDP checksum error via status bits [^94^]

Status reporting in receive descriptor [^103^]:
- **IPHE** (RDES1[3]): IP Header Error
- **IPCE** (RDES1[7]): IP Payload Error
- **IPCB** (RDES1[6]): IP Checksum Bypassed
- **IPV4** (RDES1[4]): IPv4 Header Present
- **IPV6** (RDES1[5]): IPv6 Header Present
- **PT** (RDES1[2:0]): Payload Type (000=UDP, 001=TCP, 010=ICMP)

### 8.3 Transmit-Side Checksum

On transmission, the hardware:
1. Computes checksum for outgoing frame based on protocol
2. Inserts checksum value in appropriate header field
3. Supports per-frame enable via descriptor CIC field [^94^]

The **CIC** field in TDES3 controls checksum insertion [^27^]:

| CIC Value | Checksum Type |
|-----------|---------------|
| 00 | Disabled - no checksum insertion |
| 01 | IP header checksum only |
| 10 | IP header checksum + TCP/UDP/ICMP checksum (with pseudo-header) |
| 11 | Reserved |

### 8.4 Benefits

> "To calculate these checksums in software requires each byte of the packet to be processed. For TCP and UDP this can use a large amount of processing power. Offloading the checksum calculation to hardware can result in significant performance improvements." [^93^]

---

## 9. PTP Timestamping

### 9.1 Overview

The TC4x GETH supports IEEE 1588-2002 (v1) and IEEE 1588-2008 (v2) Precision Time Protocol for high-precision network clock synchronization [^44^]:

> "XGMAC supports both IEEE 1588-2002 (version 1) and IEEE 1588-2008 (version 2) standards. The former supports PTP over UDP/IP transport, while the latter supports PTP over Ethernet direct transport." [^44^]

### 9.2 Timestamp Capture Point

The timestamp is captured at the **Start Frame Delimiter (SFD)** transmission/reception on the MII bus [^44^]:

> "When IEEE 1588 timestamping is enabled, this module captures the system time at the instant the SFD is put on the transmit bus, providing a critical time reference for high-precision time synchronization." [^44^]

### 9.3 Supported Clock Types

- **Ordinary Clock**: Single PTP node, typically master or slave
- **Boundary Clock**: Multiple PTP ports, forwards timing between domains
- **End-to-End Transparent Clock**: Updates correctionField with residence time
- **Peer-to-Peer Transparent Clock**: Includes path delay in correctionField [^34^][^102^]

### 9.4 Timestamp Formats

The hardware supports two timestamp formats:
- **48-bit seconds + 32-bit nanoseconds**
- **64-bit nanoseconds** (binary format)

Sub-second measurement options include digital or binary format [^44^].

### 9.5 Descriptor-Based Timestamping

**Transmit Timestamping** [^68^][^65^]:
- Software sets **TTSE=1** in TDES2 of the first descriptor
- DMA captures timestamp at SFD transmission
- On write-back, if LD=1 and TTSS=1:
  - TDES0 contains **TTSL** (Timestamp Low)
  - TDES1 contains **TTSH** (Timestamp High)

**Receive Timestamping** [^68^][^103^]:
- DMA captures timestamp at SFD reception
- Normal descriptor write-back sets **TSA=1** (RDES1[14]) if timestamp available
- Following context descriptor contains:
  - RDES0: **RTSL** (Receive Timestamp Low)
  - RDES1: **RTSH** (Receive Timestamp High)
- **TD** bit (RDES1[15]) indicates if timestamp was dropped due to overflow

### 9.6 One-Step Timestamp Correction

For one-step PTP operation (inserting timestamp directly into Sync frame) [^68^]:
- Software prepares a **Transmit Context Descriptor** before the packet descriptor
- Sets **OSTC=1** and **TCMSSV=1** in TDES3
- Provides timestamp correction value in TDES0 (TTSL) and TDES1 (TTSH)
- DMA performs one-step timestamp correction using these values

### 9.7 Timebase Distribution

For multi-port configurations, the TC4x supports timebase distribution [^41^]:

> "A daisy-chaining of internal local time base output of LETHO MAC port(j) and external time base input to LETHO MAC port(j+1) provides a mechanism for time base distribution between LETHO MAC ports." [^41^]

**Known limitation**: Only pairwise daisy-chaining is supported - LETH0 MAC port 0 can forward to port 1, and port 2 can forward to port 3 (or reverse), but not arbitrary connections [^41^].

### 9.8 Timestamping for TSN

PTP timestamping is fundamental for TSN protocols [^34^]:
- **gPTP (IEEE 802.1AS)**: Uses timestamps for precise clock synchronization across network
- **Time-Aware Shaper (IEEE 802.1Qbv)**: Requires synchronized time base for gate control
- **CBS (IEEE 802.1Qav)**: Relies on timestamps for credit-based scheduling

> "To calculate the link propagation delay of MAC/PHY, accurate local egress and ingress timestamps are required." [^34^]

---

## 10. Key Registers

### 10.1 DMA Global Registers

| Register | Address Offset | Description |
|----------|---------------|-------------|
| `DMA_Mode` | 0x0000 | DMA mode - SWR, DA, TXPR, arbitration [^66^] |
| `DMA_SysBus_Mode` | 0x0004 | System bus mode configuration |
| `DMA_Interrupt_Status` | 0x0008 | Global interrupt status |
| `DMA_Debug_Status` | 0x000C | Debug status |

### 10.2 DMA Channel Registers (per channel x=0-7)

| Register | Offset | Description |
|----------|--------|-------------|
| `DMA_CHx_Control` | +0x00 | MSS, header splitting, 8xPBL mode [^100^] |
| `DMA_CHx_Tx_Control` | +0x04 | Tx PBL, TCP segmentation, Tx channel weight [^100^] |
| `DMA_CHx_Rx_Control` | +0x08 | Rx PBL, buffer size, extended status [^100^] |
| `DMA_CHx_Slot_Function` | +0x0C | Slot function control/status |
| `DMA_CHx_TxDesc_List_HAddr` | +0x10 | Tx descriptor list high address [^100^] |
| `DMA_CHx_TxDesc_List_LAddr` | +0x14 | Tx descriptor list low address |
| `DMA_CHx_RxDesc_List_HAddr` | +0x18 | Rx descriptor list high address |
| `DMA_CHx_RxDesc_List_LAddr` | +0x1C | Rx descriptor list low address |
| `DMA_CHx_TxDesc_Tail_Pointer` | +0x20 | Tx descriptor tail pointer |
| `DMA_CHx_RxDesc_Tail_Pointer` | +0x24 | Rx descriptor tail pointer |
| `DMA_CHx_TxDesc_Ring_Length` | +0x28 | Tx descriptor ring length |
| `DMA_CHx_RxDesc_Ring_Length` | +0x2C | Rx descriptor ring length |
| `DMA_CHx_Interrupt_Enable` | +0x34 | Channel interrupt enable |
| `DMA_CHx_Rx_Interrupt_WDT` | +0x38 | Rx interrupt watchdog timer |
| `DMA_CHx_Current_App_TxDesc_L` | +0x44 | Current application Tx descriptor [^56^] |
| `DMA_CHx_Current_App_RxDesc_L` | +0x4C | Current application Rx descriptor [^56^] |

### 10.3 DMA Mode Register Bit Definitions

| Bit | Name | Description |
|-----|------|-------------|
| [0] | SWR | Software Reset - resets DMA, MTL, MAC logic [^66^] |
| [4] | TDRP | Tx Descriptor Read Priority - Tx/Rx descriptor fetch priority |
| [6] | DA | DMA Arbitration scheme - 0=WRR, 1=Fixed Priority [^52^] |
| [11] | TXPR | Tx Priority - gives priority to Tx over Rx |

---

## 11. Errata and Workarounds

### 11.1 Descriptor Data Integrity Race Condition

**Problem**: Small probability that OWN bit is set but DMA reads incorrect descriptor data [^39^]:

> "Racing condition happens between CPU and GMAC DMA, that GMAC DMA gets old TDES2 (length=0) and new TDES3 (OWN bit set), because of data integrity issue of descriptor. (CPU: 300MHz, Gmac DMA: 150MHz or less)" [^39^]

**Impact**: DMA may process descriptor with wrong buffer length, causing transmission of incorrect data

### 11.2 Transmit Timestamp in Multi-Port Configurations

**Problem**: When TxDMA channel is mapped to any queue except TxQ0 and bridge is enabled, transmit timestamp is not correctly written [^41^]:

> "The DMA copies the timestamp information pertaining to TxDMA0 into the descriptor for all Tx DMA channels which is then written back to TDES0, TDES1 and TDES2 incorrectly." [^41^]

**Scope**: All of: multi-port configuration + TxDMA channels not mapped to TXQ0 + TTSE bit set
**Workaround**: None available [^41^]

### 11.3 Rx DMA Stall with Context Descriptor Closure

**Problem**: Under specific conditions (frame duplication to host and forwarding path, VLAN tagged + timestamped packet), Rx DMA channel may stall [^41^]:

> "When the Receive DMA channel is stalled no further packets are transferred to the host even when Rx Descriptors are available. This eventually results in Head of line blocking in the corresponding RXQ." [^41^]

**Workaround**: "Software must ensure that ingress packet is duplicated to the bridge forwarding path only once and after the duplication to all the RxDMA channels are completed. Map lowest RXC as the forwarding channel among the channels to which packet is duplicated." [^41^]

### 11.4 WRR Arbitration Issue

**Problem**: When using Weighted Round Robin with different weights and only one queue/DMA enabled, QoS bandwidth allocation may not be met [^52^]:

**Workaround**: "Operate in Fixed Priority arbitration mode (DA=1) with Rx DMA having higher priority over Tx (TXPR=0). Operate the Tx buffers in Store-and-Forward mode." [^52^]

### 11.5 PTP Timebase Synchronization Limitation

**Problem**: Cannot simultaneously use external timebase input and output internal timebase on same LETH0 MAC port [^41^]:

**Impact**: Only pairwise daisy-chaining supported for timebase forwarding
**Workaround**: None available [^41^]

---

## References

- [^27^] Infineon Aurix TC4x GETH Module Detailed Explanation (eeworld.com.cn)
- [^28^] Infineon Aurix TC4x Ethernet GETH Module Detailed (10100.com)
- [^35^] Infineon Aurix TC4x Ethernet GETH Module Detailed (eeworld.com.cn)
- [^39^] Infineon Community: Eth_17_GEthMac DMA state machine stuck due to descriptor issue
- [^41^] Infineon AURIX TC4Dx Errata Sheet
- [^43^] Infineon AURIX TC4x Gigabit Ethernet Training
- [^44^] Infineon Aurix TC4x GETH Module (eet-china.com)
- [^48^] CSDN Blog: AVB Notes with DWC_xgmac descriptor details
- [^52^] Infineon AURIX TC39x Errata Sheet (WRR arbitration issue)
- [^56^] Intel DWC_XGMAC DMA_CH0 Register Map
- [^62^] Infineon AURIX TC4x Gigabit Ethernet Training PDF
- [^64^] 360doc: DMA Descriptor explanation with TC3xx code
- [^65^] Elecfans: DWC_ether_qos descriptor format
- [^66^] Intel DMA_Mode Register documentation
- [^67^] Zephyr Documentation: snps,dwcxgmac bindings
- [^68^] Tencent Cloud: GMAC transmit descriptor detailed
- [^69^] CSDN Blog: GMAC transmit descriptor
- [^74^] Intel TX DMA Operation: OSF Mode documentation
- [^78^] Intel XGMAC Core documentation
- [^93^] Microchip: Checksum Offload for IP, TCP and UDP
- [^94^] Synopsys IP Technical Bulletin: Checksum Offload
- [^96^] Infineon Community: GETH RX DMA resume from suspend
- [^99^] Infineon Community: Multiple queues/channels for Ethernet on TC397
- [^100^] Intel DWC_XG_DMA_CH0 Address Map
- [^102^] IEEE 1588 PTP Hardware Timestamping Guide
- [^103^] CSDN Blog: Aurix2G TC3XX GETH Module详解
