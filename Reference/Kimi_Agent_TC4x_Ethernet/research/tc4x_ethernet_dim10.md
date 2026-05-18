# Dimension 10: PHY Interfaces & HSPHY - Infineon AURIX TC4x

## Research Summary

This document provides a comprehensive analysis of the Infineon AURIX TC4x PHY interfaces and the High Speed Physical Layer (HSPHY) module. The HSPHY serves as the physical infrastructure core for high-speed data exchange, enabling Gigabit Ethernet (GETH), Lite Ethernet (LETH), PCI Express Gen 3, Serial Gigabit Trace (SGBT), and high-speed xSPI interfaces.

---

## Table of Contents

1. [HSPHY Module Architecture](#1-hsphy-module-architecture)
2. [Supported PHY Interfaces](#2-supported-phy-interfaces)
3. [Speed Configuration](#3-speed-configuration)
4. [MDIO Management](#4-mdio-management)
5. [Pin Configuration](#5-pin-configuration)
6. [RGMII Timing and DLL Skew Control](#6-rgmii-timing-and-dll-skew-control)
7. [Auto-Negotiation](#7-auto-negotiation)
8. [HSPHY Integration and Initialization](#8-hsphy-integration-and-initialization)
9. [10BASE-T1S via LETH](#9-10base-t1s-via-leth)
10. [Safety Mechanisms](#10-safety-mechanisms)
11. [Errata and Workarounds](#11-errata-and-workarounds)
12. [References](#12-references)

---

## 1. HSPHY Module Architecture

### 1.1 Overview

The HSPHY (High Speed Physical Layer) is the physical infrastructure core for high-speed data exchange in the AURIX TC4x series. It is based on a **Multi-Protocol 8G PHY (MP8G PHY)** architecture that can be configured to support serial line rates up to **8 Gbps** [^115^][^389^].

> "HSPHY isTC4x系列实现高速数据交换的物理基础设施核心。它基于一个名为 **多协议8G PHY（MP8G PHY）** 的通用物理层架构构建，该架构可配置支持高达 **8 Gbps** 的串行线速率。" [^115^]

Key capabilities of HSPHY:
- Gigabit Ethernet communication via SGMII, USXGMII, or RGMII
- PCI Express Gen 3 speeds up to 8 Gb/s
- Serial Gigabit Trace (SGBT) interface supporting 1, 2.5, and 5 Gbps data rates
- xSPI interface up to 400 MBps with skew control of 138.88 ps [^389^]
- Emergency stop safety mechanism for ASIL-D compliance
- Three independent access protection units for resource security isolation [^115^]

### 1.2 Internal Architecture

The HSPHY module consists of several key submodules [^115^][^117^]:

```
                    +-------------------+
    XGMAC0 -------->|      XPCS0        |        +------------+
    XGMAC1 -------->|      XPCS1        |------->| MP8G PHY 0 |----> Port
                    |                   |        | (PCS+PMA)  |
    SGBT ---------->|
    PCIe ---------->|
    xSPI ---------->|  DLL & Skew Ctrl  |        +------------+
                    |                   |        +------------+
                    +-------------------+------->| MP8G PHY 1 |----> Port
                                                 | (PCS+PMA)  |     (TX/RX)
                                                 +------------+
                                                 +------------+
                                                 | MP8G PHY 2 |----> Port
                                                 | (PCS+PMA)  |
                                                 +------------+
```

#### 1.2.1 MP8G PHY (Multi-Protocol 8 Gigabit PHY)

The module's core contains up to three **MP8G PHYs** - universal high-speed serial transceiver engines [^115^][^117^]:

- Each MP8G PHY consists of **PCS** (Physical Coding Sublayer) and **PMA** (Physical Medium Attachment)
- Supports data transmission and reception up to **8 Gbps**
- Can receive PCIe reference clock through differential reference clock lines
- Supports multiple standards: SGMII (without auto-negotiation), USXGMII, PCIe Gen 3, and Aurora protocol
- Covers serial line rates from **0.125 Gbit/s to 8 Gbit/s** [^115^]

**Configurable Serial Line Rates** [^115^]:
| Line Rate (Gbit/s) | Typical Usage |
|-------------------|---------------|
| 0.125 | SGMII 100M |
| 1.25 | SGMII 1G |
| 2.5 | SGBT 2G |
| 3.125 | SGMII 2.5G |
| 5.0 | SGBT 4G |
| 5.15625 | USXGMII 5G |
| 8.0 | PCIe Gen 3 |

**MP8G PHY Features** [^115^]:
- Adaptive and configurable receive CTLE (Continuous Time Linear Equalizer)
- Decision Feedback Equalizer (DFE) for receive signal conditioning
- Adaptive and programmable transmit equalization
- Independent TX and RX control per channel
- Configurable TX and RX power modes
- PRBS generator and checker (PRBS31, PRBS23, PRBS16, PRBS15, PRBS11, PRBS9, PRBS7)
- Programmable 10-bit pattern generation with error injection
- Wide reference clock frequency range with optional fractional division correction
- Spread Spectrum Clocking (SSC) capability

#### 1.2.2 PMA (Physical Medium Attachment)

The PMA layer serves as the bridge between the digital and analog domains [^115^][^117^]:

- **SerDes**: Serialization and deserialization of data
- **Clock Data Recovery (CDR)**: Recovery of clock from incoming serial data
- **Transmit Clock Generation**: Synthesis of high-precision, low-jitter transmit clocks
- **Signal Conditioning**: Drive transmit equalization (pre-emphasis/de-emphasis) to compensate for channel losses

Note: The HSPHY **does NOT include PMD** (Physical Media Dependent) layer - it outputs high-speed, low-voltage differential signals for PCB-level connections to external PHY chips [^115^].

#### 1.2.3 XPCS (Gigabit Physical Coding Sublayer)

Up to two **XPCS** blocks are dedicated for Ethernet, serving as the protocol-specific frontend [^115^][^117^]:

- XPCS is the Ethernet-specific frontend that ensures data format correctness per IEEE 802.3
- Connects to MAC via media-independent interfaces (MII, RMII, RGMII, SGMII, USXGMII)
- Connects to MP8G PHY on the lower side
- Uses **25 MHz reference clock**

**XPCS Transmit Path** [^115^]:
1. **GMII Tx Rate Adaptor Logic (RAL)**: Converts MAC data of different rates/widths to uniform internal format (8-bit data + 2-bit control at 125 MHz)
2. **TX Word Encoder**: For 2.5G PCS mode, encodes XGMII data following IEEE Std 802.3cb Clause 127
3. **PCS-X 8B/10B Encoder**: Performs 8B/10B conversion per IEEE Std 802.3
4. For 5G USXGMII mode: XGMII interface -> DDW mode (64-bit data + 8-bit control) -> 64/66 encoder -> Scrambler

**XPCS Receive Path** [^115^]:
1. 8B/10B Decoder (for 1G/2.5G modes)
2. 64/66 Decoder (per IEEE 802.3 Clause 49)
3. Descrambler
4. Clock Rate Compensation (eliminates clock jitter and frequency drift)
5. Byte-to-Character conversion for 2.5G mode
6. GMII or XGMII interface mapping

#### 1.2.4 TPCS (Trace Physical Coding Sublayer)

- Connects debug trace unit to MP8G PHY
- Dedicated for SGBT interface
- Supports Aurora 8b/10b protocol
- Uses 20 MHz, 25 MHz, or 100 MHz reference clock [^115^]

#### 1.2.5 DLL and Skew Control

The DLL (Delay Lock Loop) and Skew Control block provides precise timing management [^115^][^389^]:

- Dedicated for **RGMII** and **xSPI** interfaces
- Supports up to 400 MBps DDR transfers
- Skew control precision: **138.88 ps** at 200 MHz transmit clock
- Phase control: **10-degree steps** with 100-200 MHz transmit clock
- HSPHY uses CCU's **Fxspi** clock, multiplied for xSPI operations
- **DLL_CFG register** controls the timing adjustment

> "The RGMII data and clock are typically transferred by IPs simultaneously, without any skew on the clock. For proper sampling of the data signals at the receiver side, a skew shall be added to the clock signal, either by the PCB traces, or by the transmitter/receiver itself. HSPHY provides these options." [^389^]

### 1.3 System Integration

The HSPHY integrates into the TC4x system as follows [^389^]:

```
    +---------+      +---------+
    | XGMAC 0 |      | XGMAC 1 |
    +----+----+      +----+----+
         |                |
         +------+  +------+
                |  |
           +----+----+
           |  HSPHY  |<------ PCIe Refclk
           |         |<------ CCU Clock (Fxspi)
           +----+----+
                |
      +---------+---------+
      |         |         |
   Port 16   Port 20   Port 11
   TX/RX     TX/RX     TX/RX
```

Key integration points:
- Clock unit provides necessary clocks for HSPHY
- PCIe requires external reference clock
- SMU alarms can be raised from HSPHY safety flip-flops
- Peripherals (PCIe, Ethernet) use MP8G PHY for data stream serialization
- xSPI and Ethernet use the integrated DLL for clock-to-data skew generation [^389^]

---

## 2. Supported PHY Interfaces

The HSPHY provides physical pad connections for the following interfaces [^75^][^35^]:

### 2.1 MII (Media Independent Interface)

| Parameter | Specification |
|-----------|--------------|
| Data Width | 4-bit nibble (TXD[3:0], RXD[3:0]) |
| Clock Frequency | 25 MHz for 100 Mbps |
| Clock Source | TX_CLK and RX_CLK provided by PHY |
| TX Signals | TXD[3:0], TX_EN, TX_ER, TX_CLK |
| RX Signals | RXD[3:0], RX_DV, RX_ER, RX_CLK |
| Half-Duplex | CRS (Carrier Sense), COL (Collision Detect) |
| Max Speed | 100 Mbps |
| Pin Count | 16+ pins |

MII is the foundational standard interface. Data is transferred 4 bits at a time (nibble), synchronous to the PHY-provided clocks [^422^]:
- At 100 Mbps: 25 MHz clock, 4-bit data
- At 10 Mbps: 2.5 MHz clock (clock divided by 10)

> "MII TRANSMIT CLOCK: 25 MHz Transmit clock output in 100Mb/s mode" [^470^]

### 2.2 RMII (Reduced MII)

| Parameter | Specification |
|-----------|--------------|
| Data Width | 2-bit (TXD[1:0], RXD[1:0]) |
| Clock Frequency | 50 MHz REF_CLK (shared for TX and RX) |
| Clock Source | External reference clock (MAC or PHY sourced) |
| TX Signals | TXD[1:0], TX_EN |
| RX Signals | RXD[1:0], CRS_DV |
| Reference Clock | REF_CLK (50 MHz) |
| Max Speed | 100 Mbps |
| Pin Count | 8+ pins |
| Pin Reduction | ~50% compared to MII |

RMII reduces pin count by [^422^][^465^]:
- Eliminating independent TX/RX clocks (using shared REF_CLK)
- Reducing data width from 4-bit to 2-bit
- Multiplexing CRS and DV into CRS_DV signal

> "标准RMII协议要求一个 **50MHz的REF_CLK**（参考时钟），用于同步发送（TX）和接收（RX）数据。在RMII模式下，每个时钟周期传输 **2位数据**，因此50MHz时钟可支持100Mbps速率（50MHz x 2 bits = 100Mbps）" [^465^]

**Critical Constraint**: All RMII interface pins must be assigned to the **same port group**. Available port groups are [^115^][^117^]:
- Port 11
- Port 16
- Port 20 and Port 21

### 2.3 RGMII (Reduced Gigabit MII)

| Parameter | Specification |
|-----------|--------------|
| Data Width | 4-bit DDR (TXD[3:0], RXD[3:0]) |
| Clock Frequency | 125 MHz at 1Gbps / 25 MHz at 100Mbps / 2.5 MHz at 10Mbps |
| Clock Mechanism | DDR (Double Data Rate) - both clock edges |
| TX Signals | TXD[3:0], TX_CTL (TX_EN + TX_ER multiplexed) |
| RX Signals | RXD[3:0], RX_CTL (RX_DV + RX_ER multiplexed) |
| Max Speed | 1 Gbps |
| Pin Count | 12+ pins |

RGMII achieves Gigabit speed with reduced pin count [^422^][^389^]:
- Uses 4-bit data path with **both clock edges** (DDR)
- 125 MHz x 4-bit x 2 (edges) = 1 Gbps
- TX_CTL multiplexes TX_EN (rising edge) and TX_ER (falling edge)
- RX_CTL multiplexes RX_DV (rising edge) and RX_ER (falling edge)
- Requires **clock skew** (delay) between clock and data for proper sampling

**RGMII Speeds Supported** [^389^]:
- 10 Mb/s (2.5 MHz clock, DDR)
- 100 Mb/s (25 MHz clock, DDR)
- 1000 Mb/s (125 MHz clock, DDR)

**DLL Skew Control**: HSPHY provides internal clock skew generation for RGMII via the DLL_CFG register, eliminating the need for PCB trace length matching [^115^][^389^].

### 2.4 SGMII (Serial Gigabit MII)

| Parameter | Specification |
|-----------|--------------|
| Data Format | Serial LVDS differential pairs |
| Line Rate | 1.25 Gbps (for 1G) / 3.125 Gbps (for 2.5G) / 125 Mbps (for 100M) |
| Signaling | LVDS differential |
| TX Signals | SGMII_TXP, SGMII_TXN |
| RX Signals | SGMII_RXP, SGMII_RXN |
| Clock | Embedded clock (8B/10B coding) |
| Max Speed | 2.5 Gbps |
| Pin Count | 4 pins (2 differential pairs) |
| Coding | 8B/10B |

SGMII advantages [^422^][^389^]:
- Ultra-low pin count (4 pins vs 16+ for MII)
- Clock embedded in data via 8B/10B coding (no external clock needed)
- Supports auto-negotiation for 1G/2.5G rate adaptation
- Excellent noise immunity via LVDS differential signaling

**SGMII Speed Modes on TC4x** [^389^][^41^]:
| Mode | Serial Line Rate | MAC Speed |
|------|-----------------|-----------|
| SGMII 100M | 125 Mbps | 100 Mbps |
| SGMII 1G | 1.25 Gbps | 1 Gbps |
| SGMII 2.5G | 3.125 Gbps | 2.5 Gbps |

> "SerialGMII for 100/1000/2500/5000 Mb/s connections" [^389^]

### 2.5 USXGMII (Universal Serial 10GE MII)

| Parameter | Specification |
|-----------|--------------|
| Data Format | 4-lane LVDS serial |
| Line Rate | 5.15625 Gbps (5G-USXGMII) or 10.3125 Gbps (10G-USXGMII) |
| Max MAC Speed | 5 Gbps (TC4x) / 10 Gbps (standard) |
| Pin Count | 16 pins (4 TX + 4 RX differential pairs) |
| Coding | 64B/66B (Clause 49) |
| Modes | 100M / 1G / 2.5G / 5G |

USXGMII is the most advanced interface supported by TC4x HSPHY [^389^][^467^]:
- Single interface supporting **100M/1G/2.5G/5G** seamless switching
- Uses 64B/66B PCS coding (IEEE 802.3 Clause 49)
- Hardware-assisted auto-negotiation for all supported speeds
- Rate adaptation through data replication/sampling
- Supports in-band auto-negotiation Clause 37

**USXGMII Speed Configuration** [^468^]:
| USXGMII_SPEED | Speed |
|--------------|-------|
| 3'b010 | 1G |
| 3'b011 | 10G |
| 3'b100 | 2.5G |
| 3'b101 | 5G |

> "USXGMII does not support 2.5G(2.578125Gbps) interface speed due to 2.5 replication requirement to carrying 1G. 2.5G is best suited for single port PHYs and recommendation is to use 2500BASE-X" [^469^]

### 2.6 Interface Comparison Summary

| Interface | Max Speed | Data Width | Clock | Pins | Key Application |
|-----------|-----------|------------|-------|------|-----------------|
| MII | 100M | 4-bit parallel | 25MHz | 16+ | Legacy 10/100M devices [^422^] |
| RMII | 100M | 2-bit parallel | 50MHz REF | 8+ | Low-cost/IoT automotive [^422^] |
| RGMII | 1G | 4-bit DDR | 125MHz | 12+ | Mainstream Gigabit [^422^] |
| SGMII | 2.5G | 1 LVDS pair | 1.25/3.125Gbps | 4 | Compact switches/PHYs [^422^] |
| USXGMII | 5G (TC4x) | 4 LVDS pairs | 5.156Gbps | 16 | High-speed automotive [^389^] |

---

## 3. Speed Configuration

### 3.1 Speed Mode Overview

The TC4x GETH/LETH modules support the following Ethernet speeds [^40^][^389^]:

| Speed | Interface | PHY Module |
|-------|-----------|------------|
| 10 Mbps | MII, RMII, RGMII | GETH/LETH |
| 100 Mbps | MII, RMII, RGMII, SGMII | GETH/LETH |
| 1 Gbps | RGMII, SGMII, USXGMII | GETH |
| 2.5 Gbps | SGMII, USXGMII | GETH |
| 5 Gbps | SGMII, USXGMII | GETH |

> "Gigabit Ethernet: capable of supporting 10 M, 100 M, 1 G, 2.5 G and 5 G speed in full-duplex mode" [^40^]
> "Lite Ethernet supporting 10 M (including 10 BASE-T1S) and 100 M" [^40^]

### 3.2 Speed Configuration via HSPHY

#### 3.2.1 RGMII Speed Selection

For RGMII, speed is determined by:
- XGMAC MAC configuration (speed register bits)
- PHY-side auto-negotiation
- RGMII clock frequency automatically adjusts:
  - 10M: 2.5 MHz
  - 100M: 25 MHz
  - 1G: 125 MHz

#### 3.2.2 SGMII Speed Configuration

SGMII speed configuration involves programming the XPCS registers [^41^]:

1. Configure MP8G PHY for appropriate serial line rate:
   - SGMII 100M: **125 Mbps**
   - SGMII 1G: **1.25 Gbps**
   - SGMII 2.5G: **3.125 Gbps**

2. Configure XPCS speed selection via PCS control registers

3. Critical Erratum [HSPHY_TC.H008]: Do NOT assert RX_RST_0 bit in VR_XS_PMA_MP_12G_16G_25G_RX_GENCTRL1 before PCS speed selection [^41^]:

> "In the programming sequence of HSPHY initialization for Ethernet SGMII 100M, 1G and 2.5G mode, do not execute the step which asserts and de-asserts the RX_RST_0 bit of VR_XS_PMA_MP_12G_16G_25G_RX_GENCTRL1 register."

#### 3.2.3 USXGMII 5G Configuration

USXGMII 5G mode (Base-R) uses:
- Serial line rate: **5.15625 Gbps**
- 64B/66B PCS encoding
- Auto-negotiation Clause 37 support [^467^][^468^]

### 3.3 Clock Requirements

#### 3.3.1 Interface Clocks

| Interface | Speed | Clock Frequency | Source |
|-----------|-------|-----------------|--------|
| MII | 100M | 25 MHz | PHY-provided (TX_CLK/RX_CLK) |
| MII | 10M | 2.5 MHz | PHY-provided |
| RMII | 100M | 50 MHz | External REF_CLK |
| RGMII | 1G | 125 MHz | MAC/PHY sourced |
| RGMII | 100M | 25 MHz | MAC/PHY sourced |
| RGMII | 10M | 2.5 MHz | MAC/PHY sourced |
| SGMII | 1G | 1.25 Gbps SerDes | Embedded (8B/10B) |
| SGMII | 2.5G | 3.125 Gbps SerDes | Embedded (8B/10B) |
| USXGMII | 5G | 5.156 Gbps SerDes | Embedded (64B/66B) |

#### 3.3.2 GETH Module Clock (fGETH)

> "从图中可以看出 **fGETH** 模块为整个GETH模块的时钟输入，fSRI是总线时钟，用于与GETH模块进行数据交互使用" [^36^]

The GETH module has two primary clock domains:
- **fGETH**: Clock input for the entire GETH module
- **fSRI**: Bus clock for data exchange with the system

### 3.4 10 Mbps via 3-Pin Transceiver (10BASE-T1S)

10 Mbps is supported through the **LETH (Lite Ethernet)** module using external 3-pin (MII) transceivers for 10BASE-T1S [^40^][^41^]:

- Uses MII interface to external 10BASE-T1S PHY
- Supports PLCA (Physical Layer Collision Avoidance) for multi-drop bus operation
- Coordinator node ID = 0, Follower nodes ID = 1-254
- Default TO Timer: 32 bit times
- PLCA management registers per Open Alliance TC14 specification [^41^]

---

## 4. MDIO Management

### 4.1 MDIO Interface Overview

The MDIO (Management Data Input/Output) interface provides PHY register access for configuration and management. The TC4x GETH supports both **Clause 22** and **Clause 45** MDIO protocols [^133^][^487^].

MDIO signals [^455^][^487^]:
| Signal | Direction | Description |
|--------|-----------|-------------|
| MDC | MAC -> PHY | Management clock (max 2.5 MHz) |
| MDIO | Bidirectional | Management data |

> "MDC的时钟最大可设置为2.5MHz. 可通过MAC_MDIO_ADDRESS寄存器来设置." [^487^]

### 4.2 Clause 22 Protocol

Clause 22 is the legacy MDIO protocol supporting 5-bit PHY addresses and 5-bit register addresses [^487^]:

**Frame Format**:
| Field | Bits | Description |
|-------|------|-------------|
| ST | 2 | Start of Frame (01) |
| OP | 2 | Opcode (10=Read, 01=Write) |
| PHYADR | 5 | Physical Address (0-31) |
| REGADR | 5 | Register Address (0-31) |
| TA | 2 | Turnaround (Z0 for read, 10 for write) |
| DATA | 16 | Data |

Key registers (standardized for first 16 addresses):
- Register 0: Control Register (BMCR)
- Register 1: Status Register (BMSR)
- Register 2,3: PHY Identifier
- Register 4: Auto-Negotiation Advertisement
- Register 9: 1000BASE-T Control
- Register 17/18: SGMIIS status/control (vendor-specific)

**Software Implementation**:
Two key registers control MDIO operations [^487^]:
1. **MAC_MDIO_ADDRESS**: Configures MDC clock, Clause type, opcode, PHY address, register address
2. **MAC_MDIO_DATA**: Contains 16-bit write data or read result

Key bits in MAC_MDIO_ADDRESS:
- **GB (Go/Busy)**: Set to 1 to initiate operation; clears to 0 when complete
- **GOC_1/GOC_0**: Opcode selection
- **C45E**: Clause 45 enable
- **PA[4:0]**: PHY address
- **RDA[4:0]**: Register address / DEVTYPE

### 4.3 Clause 45 Protocol

Clause 45 extends MDIO for 10G+ Ethernet with indirect addressing [^487^]:

**Frame Format**:
| Field | Bits | Description |
|-------|------|-------------|
| ST | 2 | Start of Frame (00) |
| OP | 2 | Opcode (00=Address, 01=Write, 11=Read, 10=Post-read-increment) |
| PHYADR | 5 | Physical Address |
| DEVTYPE | 5 | Device Type (MMD) |
| TA | 2 | Turnaround |
| ADDR/DATA | 16 | Address or Data |

> "TC2xx的MCU只支持Clause22的数据帧格式, TC3xx支持Clause22和Clause45." [^487^]

The TC4x, being the successor to TC3x, continues to support both Clause 22 and Clause 45.

### 4.4 MDIO Pin Mapping (Example: TriBoard TC4X7)

From the TriBoard TC4X7 documentation [^455^]:

| Signal | AURIX Pin | Function |
|--------|-----------|----------|
| MDC | P16.11 | MDIO Clock (GETH0_MDC0/MDC1) |
| MDIO | P16.14 | MDIO Data (GETH0_MDIOB/MDIO1) |
| PHYRSTB_N (GET0) | P00.10 | PHY Reset (General-purpose output) |
| PHYRSTB_N (GET1) | P00.11 | PHY Reset (General-purpose output) |
| INTB (GET0) | P10.2 | PHY Interrupt (ERU channel 2 input) |
| INTB (GET1) | P10.3 | PHY Interrupt (ERU channel 3 input) |

---

## 5. Pin Configuration

### 5.1 Port Groups for Ethernet Interfaces

The TC4x maps Ethernet signals to specific port groups. Critical constraints apply [^115^][^117^]:

**RMII Port Groups** (ALL RMII pins must be in the SAME group):
- Port 11
- Port 16
- Port 20 and Port 21

**RGMII via Port 16**:
- Uses **HSFAST pads** for high-speed DDR operation [^456^]
- RGMII signals at 1Gbps require HSPHY DLL skew control

**MII via Port 16 / Port 20**:
- MII signals use standard GPIO pads
- 25 MHz TX_CLK/RX_CLK operation

**SGMII/USXGMII**:
- Uses differential SerDes lanes from MP8G PHY
- Typically mapped to Port 16 dedicated high-speed lanes

### 5.2 Pin Configuration Sequence

Per the HSPHY documentation, pin configuration must follow this order [^115^]:

1. Enable HSPHY module via **CLC** register
2. Configure DLL settings (for RGMII/xSPI interfaces) via **DLL_CFG** register
3. Configure pin mode, drive strength, and other pad settings
4. Configure the Ethernet MAC (GETH/LETH) after HSPHY is configured

> "GETH模块在不使用HSPHY的物理层协议的情况下，与Port的连接仍然需要经过HSPHY。并且这些配置需要在以太网模块配置之前完成。" [^115^]

### 5.3 Input/Output Pin Setup

For MII/RMII/RGMII interfaces, each pin must be configured for:
- **Direction** (input/output/bidirectional)
- **Drive strength** (especially important for RGMII at 125 MHz)
- **Pull-up/pull-down** (if needed)
- **Pad speed** (fast slew rate for high-speed signals)
- **Input hysteresis** (for noise immunity)

---

## 6. RGMII Timing and DLL Skew Control

### 6.1 RGMII Timing Requirements

RGMII uses DDR (Double Data Rate) signaling where both clock edges sample data [^389^][^443^]:

**TX Path (MAC -> PHY)**:
- TXD[3:0] and TX_CTL valid on both rising and falling edges of TX_CLK
- TX_CTL: TX_EN on rising edge, TX_ER on falling edge

**RX Path (PHY -> MAC)**:
- RXD[3:0] and RX_CTL valid on both rising and falling edges of RX_CLK
- RX_CTL: RX_DV on rising edge, RX_ER on falling edge

### 6.2 Clock Skew Requirement

RGMII requires a **skew (delay)** between clock and data signals for proper setup/hold times [^389^][^443^]:

> "The RGMII data and clock are typically transferred by IPs simultaneously, without any skew on the clock. For proper sampling of the data signals at the receiver side, a skew shall be added to the clock signal, either by the PCB traces, or by the transmitter/receiver itself. HSPHY provides these options." [^389^]

Three stages where skew can be added:
1. **In HSPHY (MAC side)**: Via DLL_CFG register
2. **On PCB traces**: Via length-mismatched traces
3. **In external PHY**: Via PHY internal delay registers [^443^]

**Best practice**: Implement skew at only ONE stage per path.

### 6.3 HSPHY DLL Configuration

The HSPHY DLL provides configurable clock skew for RGMII [^115^][^389^]:

- **DLL_CFG register** controls the timing adjustment
- Skew control precision: **138.88 ps** at 200 MHz
- Phase adjustment: **10-degree steps** (100-200 MHz)
- RGMII and xSPI share the same DLL block
- Uses **Fxspi** clock from CCU as reference

**Typical RGMII delay values** (from industry-standard PHYs for reference):
| Mode | Delay |
|------|-------|
| No delay | 0 ns |
| Short delay | 0.5 ns |
| Medium delay | 1.5-2.0 ns |
| Long delay | 2.5-4.0 ns |

The exact register values for DLL_CFG depend on the specific TC4x device variant and should be obtained from the device-specific User Manual.

### 6.4 External PHY RGMII Delay Configuration

When using external PHYs with RGMII, delays are typically configured via MDIO [^443^][^445^]:

```
// Example: RGMII with both TX and RX internal delays enabled
// (for PHYs like Marvell 88E151x, TI DP83867)
XAxiEthernet_PhyWrite(xaxiemacp, PHY_ADDRESS, IEEE_PAGE_ADDRESS_REGISTER, 2);
XAxiEthernet_PhyRead(xaxiemacp, PHY_ADDRESS, IEEE_CONTROL_REG_MAC, &control);
control |= (IEEE_RGMII_TX_CLOCK_DELAYED_MASK | IEEE_RGMII_RX_CLOCK_DELAYED_MASK);
XAxiEthernet_PhyWrite(xaxiemacp, PHY_ADDRESS, IEEE_CONTROL_REG_MAC, control);
```

Linux phy-mode settings for RGMII delay [^443^]:
| Mode | TX Delay | RX Delay |
|------|----------|----------|
| rgmii | Disabled | Disabled |
| rgmii-id | Enabled | Enabled |
| rgmii-rxid | Disabled | Enabled |
| rgmii-txid | Enabled | Disabled |

---

## 7. Auto-Negotiation

### 7.1 Overview

Auto-negotiation allows Ethernet devices to automatically select the highest common speed and duplex mode. The TC4x supports multiple auto-negotiation mechanisms depending on the interface type.

### 7.2 Clause 37 Auto-Negotiation (for SGMII)

SGMII uses **Clause 37** auto-negotiation as defined in IEEE 802.3 [^449^][^454^]:

Configuration sequence for Clause 37 SGMII [^454^]:
1. VR_MII_MMD_CTRL Bit[12] [AN_ENABLE] = 0 (disable SGMII AN first)
2. VR_MII_AN_CTRL Bit[2:1] [PCS_MODE] = 10b (SGMII AN mode)
3. VR_MII_AN_CTRL Bit[3] [TX_CONFIG] = 0b (MAC side SGMII)
4. VR_MII_DIG_CTRL1 Bit[9] [MAC_AUTO_SW] = 1b (auto speed/duplex change by HW)
5. VR_MII_MMD_CTRL Bit[12] [AN_ENABLE] = 1 (enable SGMII AN)

> "For AN for C37 SGMII mode, the settings are: 1) Disable SGMII AN, 2) Set PCS_MODE to SGMII AN, 3) TX_CONFIG = MAC side, 4) MAC_AUTO_SW = 1b, 5) Enable SGMII AN." [^454^]

**Important**: When switching from 2500BASE-X to SGMII, a soft reset is required to re-initiate Clause 37 auto-negotiation [^449^].

### 7.3 USXGMII Auto-Negotiation

USXGMII supports hardware-assisted auto-negotiation for all speed modes [^468^][^469^]:

- **usxgmii_control register**: Enables/disables USXGMII mode and auto-negotiation
- **USXGMII_AN_ENA**: Enable auto-negotiation for automatic speed configuration
- **USXGMII_SPEED**: Manual speed selection when AN is disabled
- **RESTART_AUTO_NEGOTIATION**: Write 1 to restart AN sequence

USXGMII auto-negotiation advertises [^468^]:
- Speed capability (10M/100M/1G/2.5G/5G/10G)
- Duplex mode (full/half)
- EEE capability
- Link status

### 7.4 RGMII/MII/RMII Auto-Negotiation

For parallel interfaces (RGMII/MII/RMII), auto-negotiation is handled by the external PHY:
- Standard auto-negotiation per IEEE 802.3 Clause 28
- Advertised via PHY register 4 (Auto-Neg Advertisement)
- Status in PHY register 1 (BMSR) and register 9 (1000BASE-T Status)
- TC4x MAC reads PHY status via MDIO and adjusts MAC speed accordingly

---

## 8. HSPHY Integration and Initialization

### 8.1 Reset Dependencies

The HSPHY module has specific reset requirements [^41^][^448^]:

**Before application/system reset**:
> "Reset all PHYs involved in mission mode data transfer (PCIE and Ethernet), immediately prior to an application reset or system reset by set the corresponding CTRL1.RSTx to 1, where x=PHY Index." [^41^]

**Clock gating before reset**:
> "Software must ensure that the HSSL module clock is disabled (CLC.DISR=1 and CLC.DISS=1) before issuing kernel reset or module group reset." [^41^]

### 8.2 Initialization Sequence

#### 8.2.1 General HSPHY Initialization

1. **Enable HSPHY clock** via CLC register (clear DISR bit)
2. **Wait for HSPHY clock stable** (poll DISS bit)
3. **Release HSPHY reset** via CTRL1 register
4. **Configure MP8G PHY** for target serial line rate
5. **Configure XPCS** for target Ethernet mode
6. **Configure DLL** (if using RGMII/xSPI) via DLL_CFG register
7. **Configure pins** for target interface
8. **Configure MAC** (GETH/LETH) after HSPHY is ready

#### 8.2.2 SGMII Initialization (Specific)

Per Infineon errata, the following corrections apply to the SGMII initialization [^41^]:

**Correction [HSPHY_TC.H007] - RX Adaption Control**:
For SGMII 100M at 125 Mbps, SGMII 1G at 1.25 Gbps, and SGMII 2.5G at 3.125 Gbps:
```
Write 0B to AFE_EN_0 and DFE_EN_0 bit-fields of 
XPCSi_VR_XS_PMA_MP_12G_AFE_DFE_EN_CTRL register
```

For USXGMII 5G: Default reset values (1B) apply for AFE_EN_0 and DFE_EN_0.

**Correction [HSPHY_TC.H008] - Skip RX_RST step**:
> "In the programming sequence of HSPHY initialization for Ethernet SGMII 100M, 1G and 2.5G mode, do not execute the step which asserts and de-asserts the RX_RST_0 bit of VR_XS_PMA_MP_12G_16G_25G_RX_GENCTRL1 register." [^41^]

**Correction [HSPHY_TC.005] - RX_MISC for Temperature Drift**:
Configure XPCSi_VR_XS_PMA_MP_16G_25G_RX_MISC_CTRL0.RX0_MISC bit-field [^41^]:

| Mode | Serial Line Rate | RX0_MISC Value |
|------|-----------------|----------------|
| SGMII 100M | 125 Mbps | 177 (decimal) |
| SGMII 1G | 1.25 Gbps | 161 (decimal) |
| SGMII 2.5G | 3.125 Gbps | 96 (decimal) |
| USXGMII 5G | 5.15625 Gbps (Base-R) | 163 (decimal) |

### 8.3 HSPHY Clock Configuration

The HSPHY receives clocks from the **CCU (Clock Control Unit)** [^389^][^115^]:

- **Fxspi clock**: Used by DLL for RGMII/xSPI timing control
- **fGETH**: Main clock for GETH module
- For PCIe: External reference clock must be provided to HSPHY

---

## 9. 10BASE-T1S via LETH

### 9.1 Overview

The TC4x **LETH (Lite Ethernet)** module supports 10BASE-T1S, the automotive-specific 10 Mbps Ethernet standard [^40^][^41^]:

> "Lite Ethernet supporting 10 M (including 10 BASE-T1S) and 100 M" [^40^]

10BASE-T1S characteristics [^458^][^460^]:
- Half-duplex multi-drop bus topology
- PLCA (Physical Layer Collision Avoidance) for deterministic access
- Up to at least 8 nodes on a single bus segment
- Coordinator (Node ID 0) sends BEACON to synchronize all nodes
- TO (Transmit Opportunity) timer controls access timing

### 9.2 PLCA Configuration

PLCA parameters configured via MDIO registers (Open Alliance TC14) [^41^][^460^]:

| Parameter | Range | Default | Description |
|-----------|-------|---------|-------------|
| PLCA_NODE_ID | 0-255 | 255 | Local node ID (0=Coordinator) |
| PLCA_NODE_COUNT | 2-255 | 8 | Total nodes on bus |
| PLCA_TO_TIMER | 1-255 BT | 32 BT | Transmit Opportunity timer |
| PLCA_BURST_COUNT | 0-255 | 0 | Max burst packets |
| PLCA_BURST_TIMER | 0-255 | 128 BT | Burst timer duration |

**Critical requirements** [^391^][^460^]:
- All nodes MUST enable PLCA for >2 node operation
- All nodes MUST have same TO_TIMER value
- All nodes MUST have same BURST_TIMER value
- Node IDs MUST be unique on the bus
- Node Count typically set only on Coordinator (Node 0)

### 9.3 LETH 10BASE-T1S Errata Notes

Several functional deviations affect 10BASE-T1S operation [^41^]:

**LETH_AI.011 - Delayed transmission in follower**:
- Follower transmission delayed by ~1.24us beyond specification
- May cause TO timer misalignment between nodes

**LETH_AI.013 - Long COMMIT without TRANSMIT**:
- Commit timer duration is 30us instead of specified 28.8us
- May delay transmission from next node

**LETH_AI.016 - PLCA cycle time deviation**:
- Actual PLCA cycle time ~32us vs expected ~29us max
- Round trip time longer than specified

**LETH_AI.017 - PS bit polarity reversed**:
- Portj_B10T1S_PLCA_Sts.PS bit has inverted polarity vs User Manual
- 1 = PLCA active (normal), 0 = PLCA inactive

---

## 10. Safety Mechanisms

### 10.1 Emergency Stop

HSPHY integrates an **emergency stop** safety mechanism [^115^][^117^]:

> "秉承AURIX家族对功能安全的极致追求，HSPHY集成了 **紧急停止** 安全机制。当系统监测到如CPU锁步错误等严重安全故障时，该机制能够立即屏蔽对外数据发送，防止潜在的危险信息传出，从而满足包括ASIL-D在内的汽车安全完整性等级要求。" [^115^]

When a serious safety fault is detected (e.g., CPU lockstep error):
- HSPHY immediately masks/block external data transmission
- Prevents potentially dangerous information from being sent
- Satisfies **ASIL-D** safety integrity level requirements

### 10.2 Access Protection

HSPHY provides **three independent access protection units** [^115^]:
- Separate protection for three groups of resources
- Ensures secure isolation and access control when different applications or cores share high-speed communication resources

### 10.3 SMU Alarms

HSPHY can raise alarms to the **SMU (Safety and Security Alarm Management Unit)** [^389^][^82^]:
- Alarms generated from safety flip-flops within HSPHY
- Configurable alarm reactions: NMI, interrupt, reset, or external fault signal
- Alarm flags stored in diagnostic registers (only cleared by Power-On Reset)

### 10.4 ASIL-D Compliance

The TC4x platform is designed for ISO 26262 ASIL-D compliance [^76^][^20^]:
- AURIX TC4x developed as Safety Element out of Context (SEooC)
- Hardware safety mechanisms detect high percentage of failures
- Software safety mechanisms (SafeTlib) available for fault detection
- MC-ISAR provides ASIL D-compliant MCAL drivers [^331^]

---

## 11. Errata and Workarounds

### 11.1 Summary of HSPHY-Related Errata

| Errata ID | Description | Workaround |
|-----------|-------------|------------|
| [HSPHY_TC.H007] | Missing register for RX adaption control | Write AFE_EN_0=0, DFE_EN_0=0 for SGMII modes [^41^] |
| [HSPHY_TC.H008] | Incorrect SGMII init sequence | Skip RX_RST_0 assertion step [^41^] |
| [HSPHY_TC.005] | Loss of RX comm during temperature change | Configure RX_MISC with corrected values [^41^] |
| [HSPHY_TC.H006] | (Related) Reset before application reset | Set CTRL1.RSTx=1 for all mission-mode PHYs [^41^] |

### 11.2 LETH-Related Errata for 10BASE-T1S

| Errata ID | Description | Workaround |
|-----------|-------------|------------|
| [LETH_AI.005] | CBS credit not decremented during IPG | Limit TxDMA PBL <= 4 beats [^41^] |
| [LETH_AI.011] | Delayed follower transmission | None available [^41^] |
| [LETH_AI.013] | Long COMMIT without TX | None available [^41^] |
| [LETH_AI.016] | PLCA cycle time deviation | None available [^41^] |
| [LETH_AI.017] | PS bit polarity reversed | Interpret PS bit per design [^41^] |
| [LETH_AI.020] | Coordinator sends without BEACON | None available [^41^] |
| [LETH_AI.021] | PLCA_R reset timing | Wait 3 clock cycles [^41^] |

---

## 12. References

### 12.1 Infineon Official Documentation

1. **AURIX TC4x High Speed Physical Layer Training** (Infineon, 2024) - Document ID: AURIX_3_High_Speed_Physical_Layer [^389^]
2. **AURIX TC4Dx Errata Sheet** (Infineon, 2025) [^41^]
3. **AURIX TC4x System Architecture Training** (Infineon, 2024) [^40^]
4. **AURIX TC4x Safety Concept Training** (Infineon, 2024) [^76^]
5. **AURIX TC4x SMU Training** (Infineon, 2024) [^82^]
6. **AURIX TC4x Clocking System Training** (Infineon, 2024) [^491^]
7. **TriBoard TC4X7 COM User Manual V3.0** (Infineon) [^455^]
8. **AURIX TC4xx Functional Overview** (Infineon Documentation Portal) [^75^]

### 12.2 Technical Articles

9. **英飞凌AURIX TC4x HSPHY模块详解** (EET China, 2025) [^115^]
10. **英飞凌Aurix TC4x 以太网GETH模块详解** (EET China, 2025) [^44^]
11. **英飞凌AURIX TC4x xSPI模块详解** (EET China, 2025) [^456^]

### 12.3 Standards and Specifications

12. **IEEE Std 802.3** - Ethernet standard (MII, RGMII, SGMII definitions)
13. **IEEE Std 802.3cb** - 2.5 Gbps Ethernet (Clause 127)
14. **Open Alliance TC14** - 10BASE-T1S PLCA Management Registers
15. **USXGMII Specification** - Universal Serial 10GE MII [^469^]

### 12.4 Related Resources

16. **MII/RMII/GMII/RGMII/SGMII/USXGMII核心区别** (CSDN, 2025) [^422^]
17. **RGMII Interface Timing Considerations** (Opsero) [^443^]
18. **RGMII Interface Timing Budgets** (TI SNLA243) [^490^]
19. **USXGMII Ethernet Subsystem** (AMD PG251) [^466^]
20. **10BASE-T1S PLCA参数详解** (CSDN, 2025) [^391^]

---

## Document Information

- **Research Topic**: Infineon AURIX TC4x PHY Interfaces & HSPHY Module
- **Generated**: Research session output
- **Sources Consulted**: 20+ web searches across Infineon official docs, technical articles, community forums, and industry standards
- **Primary Sources**: Infineon official training documents, errata sheets, AURIX documentation portal
- **Key Source Languages**: English, Chinese (supplemental)
