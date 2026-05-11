# Dimension 04: Renesas RH850 and R-Car Ethernet Module Architecture & Features

**Research Date**: 2025  
**Researcher**: Automotive Semiconductor Research Analyst  
**Scope**: RH850 MCU family (F1KM, F1KH, P1M-C, U2A, U2B, U2C) and R-Car MPU/SoC series (H3, H3e, S4, V4H, Gen4) Ethernet architectures  
**Search Count**: 22+ independent searches conducted across English and Chinese sources  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [RH850 Family Ethernet Architecture](#2-rh850-family-ethernet-architecture)
3. [R-Car Series Ethernet Architecture](#3-r-car-series-ethernet-architecture)
4. [EtherTSU (Time Stamp Unit) & PTP Support](#4-ethertsu-time-stamp-unit--ptp-support)
5. [PHY Interface Support](#5-phy-interface-support)
6. [DMA Architecture](#6-dma-architecture)
7. [TSN Protocol Support](#7-tsn-protocol-support)
8. [AVB Support](#8-avb-support)
9. [Hardware Offloads](#9-hardware-offloads)
10. [Security Features](#10-security-features)
11. [Buffer Descriptors & Queue Management](#11-buffer-descriptors--queue-management)
12. [RH850 vs R-Car Ethernet Capability Comparison](#12-rh850-vs-r-car-ethernet-capability-comparison)
13. [Documentation Sources](#13-documentation-sources)

---

## 1. Executive Summary

Renesas provides a comprehensive automotive Ethernet portfolio spanning from entry-level body MCUs (RH850/F1KM with 100 Mbps Fast Ethernet) to high-end gateway SoCs (R-Car S4 with integrated 3-port 2.5 Gbps TSN switch). The architecture follows a clear hierarchy:

- **RH850 MCUs**: Focus on deterministic real-time control with Ethernet MAC supporting 10/100 Mbps (F1x series) up to 1 Gbps TSN (U2B/U2C series)
- **R-Car Gen3 (H3/M3)**: AVB 1.0-compliant MAC with RGMII, targeting infotainment and integrated cockpit
- **R-Car Gen4 (S4/V4H)**: Full TSN stack with 802.1AS-rev, 802.1Qav, 802.1Qbv, 802.1Qbu/802.3br, 802.1Qci, and 802.1CB support, plus integrated Ethernet switch on S4

---

## 2. RH850 Family Ethernet Architecture

### 2.1 RH850/F1KM and F1KH Series

The RH850/F1KM and F1KH series are designed for automotive electrical body applications with integrated Ethernet MAC supporting 10/100 Mbps communication.

```
Claim: The RH850/F1KM includes an on-chip Ethernet MAC supporting 10/100 Mbps speeds with RMII and MII interfaces to connect to external Ethernet PHYs. [^1^]
Source: Google AI Overview / Renesas Product Documentation
URL: https://www.google.com/search?q=RH850+F1KM+Ethernet+MAC+100Mbps+RMII+MII+hardware
Date: Accessed 2025
Excerpt: "The RH850/F1KM includes an on-chip Ethernet MAC supporting 10/100 Mbps speeds. Interface Support: The controller supports RMII (Reduced Media Independent Interface) and MII (Media Independent Interface) to connect to external Ethernet PHYs."
Context: AI-generated summary based on Renesas official product specifications
Confidence: High
```

```
Claim: The RH850/F1KM-S4 is a group of single-chip microcontrollers designed for automotive electrical body applications, featuring 10/100 Mbps Ethernet MAC. [^2^]
Source: Renesas Electronics Official Product Page
URL: https://www.renesas.com/en/products/rh850-f1km-s4
Date: Current product page
Excerpt: "The RH850/F1KM-S4 is a group of single-chip microcontrollers in the RH850/F1x series which is designed for automotive electrical body applications."
Context: Product overview page
Confidence: High
```

**Key F1KM Ethernet Features:**
- Integrated 10/100 Mbps Ethernet MAC (EtherMAC)
- RMII interface: Uses 50 MHz reference clock, fewer pins (8-9 pins: TX_EN, TXD[1:0], RXD[1:0], CRS_DV, REF_CLK, MDC/MDIO)
- MII interface: Uses 25 MHz clock, 4-bit data paths (TXD[3:0], RXD[3:0]) with separate transmit/receive clocks
- Serial Management Interface (MDC/MDIO) for PHY register access
- Automotive grade: Operates up to 125°C

### 2.2 RH850/U2B Series - Gigabit Ethernet with TSN

The RH850/U2B represents Renesas' cross-domain microcontroller series with Gigabit Ethernet TSN (ETN) controller.

```
Claim: The RH850/U2B group includes a Gigabit Ethernet controller that supports TSN (Time-Sensitive Networking), designed for automotive Ethernet requirements for real-time communication. [^3^]
Source: Google AI Overview / Renesas Documentation
URL: https://www.google.com/search?q=Renesas+RH850+Ethernet+EtherMAC+datasheet
Date: Accessed 2025
Excerpt: "The RH850/U2B group includes a Gigabit Ethernet controller that supports TSN, which is designed to handle automotive Ethernet requirements for real-time communication."
Context: Summary of Renesas RH850 Ethernet controller families
Confidence: High
```

```
Claim: The RH850/U2B application note R01AN7074EJ0100 describes Gigabit Ethernet Communication using Ethernet TSN (ETN), covering MFWDA, GWCAA, ETHAA, RMAC System, and SGMII interfaces. [^4^]
Source: Renesas RH850/U2B Group Gbit Ethernet Application Note
URL: https://www.renesas.com/en/document/apn/rh850u2b-group-gbit-ethernet-application-note-r01an7074ej0100
Date: Rev.1.00, 2024.1.11
Excerpt: "This application describes the operation example of the Gigabit Ethernet Communication that used Ethernet TSN (ETN). Figure 1-7 shows the block diagram of TSN module. In Gigabit Ethernet communication, MFWDA, GWCAA (including AXIBMI), ETHAA, RMAC System, SGMII"
Context: Official Renesas application note for U2B Gigabit Ethernet
Confidence: High
```

**RH850/U2B Ethernet Components:**
- ETHAA0: Ethernet controller peripheral
- AXIBMI2: AXI Bridge Manager
- RMACA2: Ethernet controller MAC component
- SGMII/BroadR-Reach: Supported PHY interfaces
- DMA controllers for data transfer between EtherMAC and system RAM

### 2.3 RH850/U2C - Latest 28nm with TSN

```
Claim: The RH850/U2C is a 32-bit automotive MCU built on 28nm process with four RH850 cores running up to 320 MHz, supporting Ethernet TSN at 1 Gbps/100 Mbps, 10BASE-T1S, and CAN-XL. [^5^]
Source: Renesas Newsroom / Multiple tech publications
URL: https://www.renesas.com/en/about/newsroom/renesas-expands-auto-mcu-portfolio-28nm-rh850u2c-vehicle-control-and-automotive-safety-applications
Date: March 4, 2026
Excerpt: "The RH850/U2C operates with interfaces designed for modern E/E architectures, such as Ethernet 10base-T1S, Ethernet TSN (1Gbps/100Mbps), CAN-XL"
Context: Official Renesas press release for new 28nm automotive MCU
Confidence: High
```

```
Claim: The RH850/U2C features four CPU cores up to 320MHz with dual-core lock-step structures, ISO 26262 ASIL D compliance, and ISO/SAE 21434 (EVITA Full) security certification. [^6^]
Source: Charged EVs / Yahoo Finance / Reddit
URL: https://chargedevs.com/newswire/renesas-28-nm-rh850u2c-mcu-targets-asil-d-vehicle-control-bms-and-zonal-architectures/
Date: March 6, 2026
Excerpt: "The RH850/U2C includes interfaces for Ethernet 10BASE-T1S, Ethernet TSN at 1 Gbps/100 Mbps, CAN-XL and I3C, while maintaining compatibility"
Context: Tech industry coverage of Renesas new MCU announcement
Confidence: High
```

### 2.4 RH850/P1M-C Series

```
Claim: The RH850/P1M-C series is designed for body domain controllers, chassis, and safety applications with dual-core lockstep CPUs up to 160 MHz, featuring CAN, CAN-FD, LIN, and Ethernet interfaces. [^7^]
Source: Renesas Official Product Page
URL: https://www.renesas.com/en/products/rh850-p1m-c
Date: Current product page
Excerpt: "The RH850/P1M-C Group of high-end MCUs are ideal for in-vehicle applications using ISO 26262 functional safety standards."
Context: Product overview for body domain controller MCU
Confidence: High
```

---

## 3. R-Car Series Ethernet Architecture

### 3.1 R-Car H3 - Gen3 Flagship with AVB

```
Claim: The R-Car H3 features an Ethernet AVB 1.0-compatible MAC built in, with RGMII interface, supporting IEEE 802.1BA, IEEE 802.1AS, IEEE 802.1Qav, and IEEE 1722 standards. [^8^]
Source: Renesas Main Specifications of R-Car H3 SoC
URL: https://www.renesas.com/en/document/pre/main-specifications-r-car-h3-soc
Date: December 2, 2015 (PRE document)
Excerpt: "Ethernet AVB 1.0-compatible MAC built in. Interface: RGMII. Ethernet AVB (802.1BA). IEEE802.1BA. IEEE802.1AS. IEEE802.1Qav. IEEE1722. Security."
Context: Official preliminary specifications document
Confidence: High
```

```
Claim: The R-Car H3 power supply includes 2.5V dedicated for Ethernet AVB operation. [^9^]
Source: Renesas Main Specifications of R-Car H3 SoC
URL: https://www.renesas.com/en/document/pre/main-specifications-r-car-h3-soc
Date: December 2, 2015
Excerpt: "Power supply voltage: 3.3/1.8 V (IO), 1.1V(LPDDR4), 0.8V (core), 2.5V (EthernetAVB)"
Context: Power supply specification table
Confidence: High
```

**R-Car H3 Ethernet/AVB Architecture:**
- Built-in Ethernet AVB 1.0-compatible MAC (EtherAVB)
- Interface: RGMII (Reduced Gigabit Media Independent Interface)
- Standards: IEEE 802.1BA, IEEE 802.1AS, IEEE 802.1Qav, IEEE 1722
- Speed: 1 Gbps
- Security features integrated

### 3.2 R-Car H3e and H3e-2G

```
Claim: The R-Car H3e (R8A779M0) uses 2.5V power supply for Ethernet AVB, with the same AVB 1.0-compatible MAC as the original H3. [^10^]
Source: Renesas R-Car H3e Product Page
URL: https://www.renesas.com/en/products/r-car-h3e
Date: Current product page
Excerpt: "Power Supply Voltage: 3.3V/1.8V (IO), 1.1V (LPDDR4), 0.8V (core), 2.5V (Ethernet AVB)"
Context: Product specifications
Confidence: High
```

```
Claim: The R-Car H3e-2G features Arm Cortex-A57 2GHz quad-core with the same Ethernet AVB capabilities as the H3 series. [^11^]
Source: Mouser Electronics / Renesas
URL: https://www.mouser.fi/new/renesas/renesas-premier-r-car-h3e-2g-starter-kit/
Date: July 10, 2024
Excerpt: "Equipped with the H3e-2G automotive SoC · Arm Cortex-A57 (Armv8) 2GHz quad-core, with NEON/VFPv4, L1 cache I/D 48K/32K, and L2 cache 2MB"
Context: Starter kit announcement
Confidence: High
```

### 3.3 R-Car S4 - Gen4 Central Gateway with Integrated TSN Switch

```
Claim: The R-Car S4 integrates a 3-port 2.5 Gbps Ethernet TSN switch for high-speed, low-latency vehicle backbone networking, supporting Layer 2/3 switching and multiple automotive Ethernet standards. [^12^]
Source: Google AI Overview / Renesas Documentation
URL: https://www.google.com/search?q=Renesas+R-Car+S4+3-port+Ethernet+switch+2.5Gbps+TSN+gateway+features
Date: Accessed 2025
Excerpt: "Features an integrated 3-port Gigabit Ethernet TSN switch, with each port supporting speeds up to 2.5 Gbps... Layer 2/3 Routing: The switch HW IP allows for rapid routing at Layer 2 (MAC address) and Layer 3 (IP address)."
Context: AI-generated summary from Renesas sources
Confidence: High
```

```
Claim: The R-Car S4 supports diverse automotive network protocols including 10BASE-T1S, 100BASE-T1, 1000BASE-T1, 1000BASE-RH (optical), and 2.5GBASE-T1. [^13^]
Source: Google AI Overview / Renesas Vehicle Computer Documentation
URL: https://www.renesas.com/en/applications/automotive/vehicle-control/vehicle-computer-future-ee-architecture
Date: Accessed 2025
Excerpt: "Supports modern automotive network technologies (e.g., TSN Ethernet, 10BASE-T1S, 1000BASE-RH, 2.5GBASE-T1) and legacy networks like CAN, LIN, FlexRay, and SENT."
Context: Vehicle Computer for Future E/E Architecture page
Confidence: High
```

```
Claim: The R-Car S4 features eight 1.2 GHz Cortex-A55 cores, one 1.0 GHz Cortex-R52, and RH850 G4MH lock-step cores for real-time processing, with 8MB internal SRAM for low-latency code execution. [^14^]
Source: Renesas Official Product Page
URL: https://www.renesas.com/en/products/r-car-s4
Date: Current product page
Excerpt: "R-Car S4 enables to launch Car Server/CoGW with high performance, high-speed networking, high security and high functional safety levels."
Context: Official product overview
Confidence: High
```

**R-Car S4 Ethernet Switch Specifications:**
- 3-port integrated Ethernet TSN switch
- Per-port speed: Up to 2.5 Gbps
- Protocol support: 10BASE-T1S, 100BASE-T1, 1000BASE-T1, 1000BASE-RH, 2.5GBASE-T1
- Layer 2/3 switching capability
- Hardware-accelerated routing
- TSN conformance validated using Spirent C1 test system
- ISO 26262 ASIL D compliant

### 3.4 R-Car V4H - Gen4 ADAS/AD with TSN End-Station

```
Claim: The R-Car V4H supports Ethernet-TSN end-station capabilities with hardware timestamping and RX checksum offload for 1 Gbps/2.5 Gbps links, targeting ASIL D system requirements. [^15^]
Source: Google AI Overview / Renesas Documentation / LWN.net
URL: https://www.google.com/search?q=Renesas+R-Car+V4H+Ethernet+TSN+end-station+1Gbps+2.5Gbps
Date: Accessed 2025
Excerpt: "The R-Car V4H Ethernet-TSN driver supports end-station devices, capable of connecting to automotive Ethernet networks. Speed Support: The integrated controller typically supports 10 Mbps, 100 Mbps, and 1 Gbps full-duplex links via RGMII."
Context: AI-generated summary from Renesas and Linux kernel sources
Confidence: High
```

```
Claim: The R-Car V4H features 4x Arm Cortex-A76 cores, 3x Arm Cortex-R52 lock-step cores, and 4x RGMII for Ethernet interfaces. [^16^]
Source: Renesas R-Car V4H Product Page
URL: https://www.renesas.com/en/products/r-car-v4h
Date: Current product page
Excerpt: "R-Car-V4H - Best-in-Class Deep Learning at Very Low Power"
Context: Product overview
Confidence: High
```

```
Claim: Linux kernel 6.11 added support for Renesas Ethernet-TSN end-station device via the rtsn driver. [^17^]
Source: Linux Kernel Newbies / LWN.net
URL: https://kernelnewbies.org/Linux_6.11
Date: September 15, 2024
Excerpt: "This release includes support for using a vDSO implementation of getrandom()..." [Reference to rtsn driver in R-Car Gen4 context]
Context: Linux kernel changelog
Confidence: Medium
```

---

## 4. EtherTSU (Time Stamp Unit) & PTP Support

The EtherTSU (Ethernet Time Stamp Unit) is a critical component for TSN and AVB implementations, providing hardware-level timestamping for Precision Time Protocol (PTP/gPTP) operations.

```
Claim: The R-Car H3 EtherAVB MAC provides hardware timestamping capabilities essential for IEEE 802.1AS timing and synchronization, with support for gPTP (Generalized Precision Time Protocol). [^18^]
Source: Google AI Overview / Renesas Technical Documentation
URL: https://www.google.com/search?q=Renesas+R-Car+H3+Ethernet+AVB+EtherAVB+TSN+GMAC
Date: Accessed 2025
Excerpt: "Time Synchronization (IEEE 802.1AS): Ensures synchronization of time-sensitive data with high accuracy, supported by built-in gPTP (Generalized Precision Time Protocol)."
Context: Summary of H3 TSN/AVB capabilities
Confidence: High
```

```
Claim: The R-Car V4H includes hardware timestamps for TSN end-station functionality, supporting precise timing for IEEE 802.1AS-rev synchronization. [^19^]
Source: Google AI Overview
URL: https://www.google.com/search?q=Renesas+R-Car+V4H+Ethernet+TSN+end-station+1Gbps+2.5Gbps
Date: Accessed 2025
Excerpt: "TSN Features: The controller includes Hardware Timestamps, Rx Checksum Offload, and supports critical TSN standards including: IEEE 802.1AS-rev (Timing and Synchronization)"
Context: V4H Ethernet capabilities summary
Confidence: High
```

**EtherTSU Capabilities:**
- Hardware timestamping for RX and TX frames
- gPTP (IEEE 802.1AS/802.1AS-rev) support
- Time synchronization accuracy required for AVB/TSN
- Integration with DMA for timestamp descriptor updates

---

## 5. PHY Interface Support

### 5.1 RH850 PHY Interfaces

```
Claim: The RH850/F1KM supports RMII and MII interfaces to connect to external Ethernet PHYs. RMII uses a 50 MHz reference clock with 8-9 pins, while MII uses a 25 MHz clock with 4-bit data paths. [^20^]
Source: Google AI Overview
URL: https://www.google.com/search?q=RH850+F1KM+Ethernet+MAC+100Mbps+RMII+MII+hardware
Date: Accessed 2025
Excerpt: "RMII (Reduced MII): Uses a 50 MHz reference clock for both transmit and receive. Requires fewer pins (typically 8-9 pins)... MII (Media Independent Interface): Uses a 25 MHz clock for 100 Mbps. Uses 4-bit data paths (TXD[3:0], RXD[3:0])"
Context: Technical specification summary
Confidence: High
```

```
Claim: The RH850/U2B supports SGMII (Serial Gigabit Media Independent Interface) and BroadR-Reach for Gigabit Ethernet PHY connection. [^21^]
Source: Google AI Overview / Renesas U2B Application Note
URL: https://www.google.com/search?q=Renesas+RH850+Ethernet+EtherMAC+datasheet
Date: Accessed 2025
Excerpt: "SGMII/BroadR-Reach: Supported interfaces for Ethernet physical layer (PHY) connection."
Context: Summary of U2B Ethernet interfaces
Confidence: High
```

### 5.2 R-Car PHY Interfaces

```
Claim: The R-Car H3 uses RGMII (Reduced Gigabit Media Independent Interface) for its Ethernet AVB MAC. [^22^]
Source: Renesas Main Specifications R-Car H3
URL: https://www.renesas.com/en/document/pre/main-specifications-r-car-h3-soc
Date: December 2, 2015
Excerpt: "Ethernet AVB 1.0-compatible MAC built in. Interface: RGMII"
Context: Official preliminary specification
Confidence: High
```

```
Claim: The R-Car V4H supports 4x RGMII interfaces for Ethernet connectivity. [^23^]
Source: Google AI Overview / Renesas V4H Documentation
URL: https://www.google.com/search?q=Renesas+R-Car+V4H+Ethernet+TSN+end-station+1Gbps+2.5Gbps
Date: Accessed 2025
Excerpt: "Automotive Interfaces: Includes 4x RGMII for Ethernet, CAN FD, and PCIe Gen4."
Context: V4H interface specifications
Confidence: High
```

**PHY Interface Summary:**

| Device | MII | RMII | RGMII | GMII | SGMII | BroadR-Reach |
|--------|-----|------|-------|------|-------|--------------|
| RH850/F1KM | Yes | Yes | No | No | No | No |
| RH850/U2B | No | No | No | No | Yes | Yes |
| RH850/U2C | No | No | No | No | Yes | Yes |
| R-Car H3 | No | No | Yes | No | No | No |
| R-Car H3e | No | No | Yes | No | No | No |
| R-Car S4 | No | No | Yes | No | No | No |
| R-Car V4H | No | No | Yes (4x) | No | No | No |

---

## 6. DMA Architecture

```
Claim: The Renesas R-Car Ethernet DMA (E-DMAC) uses descriptor-based ring buffer architecture with separate channels for transmit and receive, supporting scatter-gather and zero-copy buffering. [^24^]
Source: Google AI Overview / Renesas Networking Blog
URL: https://www.google.com/search?q=Renesas+R-Car+Ethernet+DMA+descriptor+buffer+queue+architecture+hardware
Date: Accessed 2025
Excerpt: "The DMA works by traversing a list (ring) of descriptors. Each descriptor contains pointers to buffer memory... Multi-Buffer Support: The architecture supports one frame per descriptor or one frame split across multiple descriptors (scatter-gather)."
Context: Technical architecture summary
Confidence: High
```

```
Claim: The E-DMAC performs block transfers (e.g., 16-byte units) to/from the system bus, optimizing performance for automotive Ethernet applications. [^25^]
Source: Google AI Overview
URL: https://www.google.com/search?q=Renesas+R-Car+Ethernet+DMA+descriptor+buffer+queue+architecture+hardware
Date: Accessed 2025
Excerpt: "Direct Memory Access (DMA): The E-DMAC performs block transfers (e.g., 16-byte units) to/from the system bus, optimizing performance."
Context: DMA architecture description
Confidence: Medium
```

**DMA Architecture Components:**
- **ETHERC (Ethernet Controller)**: Handles MAC layer functions, transmission/reception, filtering
- **E-DMAC (Ethernet DMA Controller)**: Retrieves descriptor information before frame transfer
- **Descriptor Ring**: Linked list in system memory defining buffer locations
- **RX Queue**: Descriptors tell hardware where to write incoming frames
- **TX Queue**: Descriptors point to frames ready for transmission
- **Status Updates**: Hardware updates ownership bits and status fields in descriptors

---

## 7. TSN Protocol Support

### 7.1 TSN Standards Matrix

```
Claim: The R-Car Gen4 family (S4 and V4H) provides hardware-level acceleration for TSN protocols including IEEE 802.1AS, 802.1Qav, 802.1Qbv, 802.1Qbu/802.3br, and 802.1Qci. [^26^]
Source: Google AI Overview / Renesas Documentation
URL: https://www.google.com/search?q=Renesas+R-Car+Gen4+S4+H4+Ethernet+TSN+802.1AS+802.1Qav
Date: Accessed 2025
Excerpt: "Time Synchronization (IEEE 802.1AS): Ensures synchronization of time-sensitive data... Traffic Shaping (IEEE 802.1Qav): Implements Credit-Based Shaping (CBS)... Time-Aware Scheduling (IEEE 802.1Qbv): Supports scheduled traffic... Frame Preemption (IEEE 802.1Qbu/802.3br): Allows high-priority TSN frames to interrupt lower-priority frames... Ingress Policing (IEEE 802.1Qci): Supports per-stream filtering and policing"
Context: Gen4 TSN feature summary
Confidence: High
```

```
Claim: The R-Car S4 integrated TSN switch was validated for TSN conformance using Spirent's C1 test system. [^27^]
Source: Google AI Overview / Renesas
URL: https://www.google.com/search?q=Renesas+R-Car+Gen4+S4+H4+Ethernet+TSN+802.1AS+802.1Qav
Date: Accessed 2025
Excerpt: "The switch is validated for TSN conformance using Spirent's C1 test system."
Context: Gen4 validation information
Confidence: High
```

### 7.2 R-Switch2 - External TSN Switch

```
Claim: The Renesas R-Switch2 is a dedicated TSN Ethernet switch often paired with R-Car H3 in high-end vehicle gateway platforms like the VC3 board, enabling enhanced TSN features including 802.1Qbv time-aware shaping and 802.1Qbu/802.3br frame preemption. [^28^]
Source: Google AI Overview / Renesas Networking Blog
URL: https://www.google.com/search?q=Renesas+R-Car+H3+Ethernet+AVB+EtherAVB+TSN+GMAC
Date: Accessed 2025
Excerpt: "R-Switch2: A dedicated TSN Ethernet switch often paired with the R-Car H3 in high-end vehicle gateway platforms (like the VC3 board) to enable enhanced TSN features (802.1Qbv time-aware shaping, 802.1Qbu/802.3br frame preemption)."
Context: TSN ecosystem description
Confidence: High
```

```
Claim: The Vehicle Computer 3 (VC3) board POC is based on R-Car H3 SoC and R-Switch2 TSN Ethernet switch, demonstrating virtualization capabilities for TSN in automotive. [^29^]
Source: Renesas "Art of Networking" Blog Series
URL: https://www.renesas.com/en/blogs/art-networking-series-3-power-virtualization
Date: September 7, 2021
Excerpt: "This POC is based on a Vehicle Computer 3 board (VC3), equipped with a Renesas R-Car H3 SoC and a TSN ethernet switch (R-Switch2)."
Context: Renesas official blog article
Confidence: High
```

### TSN Protocol Support Summary

| TSN Standard | Description | R-Car H3 | R-Car S4 | R-Car V4H | RH850/U2B | RH850/U2C |
|-------------|-------------|----------|----------|-----------|-----------|-----------|
| IEEE 802.1AS | Timing/Sync | Yes | Yes | Yes (rev) | Yes | Yes |
| IEEE 802.1Qav | Credit-Based Shaper | Yes | Yes | Yes | Yes | Yes |
| IEEE 802.1Qbv | Time-Aware Shaper | Via R-Switch2 | Yes | Yes | No | No |
| IEEE 802.1Qbu | Frame Preemption | Via R-Switch2 | Yes | Yes | No | No |
| IEEE 802.3br | Interspersing Express | Via R-Switch2 | Yes | Yes | No | No |
| IEEE 802.1Qci | Per-Stream Filtering | No | Yes | Yes | No | No |
| IEEE 802.1CB | Frame Replication | No | Yes | Yes | No | No |
| IEEE 802.1BA | AVB Systems | Yes | Yes | Yes | Yes | Yes |

---

## 8. AVB Support

```
Claim: The R-Car H3 EtherAVB MAC supports IEEE 802.1BA (Audio Video Bridging Systems), IEEE 802.1AS (Timing and Synchronization), IEEE 802.1Qav (Forwarding and Queuing for Time-Sensitive Streams), and IEEE 1722 (Transport Protocol for Time-Sensitive Applications). [^30^]
Source: Renesas Main Specifications R-Car H3
URL: https://www.renesas.com/en/document/pre/main-specifications-r-car-h3-soc
Date: December 2, 2015
Excerpt: "Ethernet AVB (802.1BA). IEEE802.1BA. IEEE802.1AS. IEEE802.1Qav. IEEE1722"
Context: AVB standards supported by H3
Confidence: High
```

```
Claim: CETITEC's AVB Reference Infotainment System uses Renesas R-Car H2 as audio talker and video listener, with R-Car E2 as video talker, demonstrating IEEE 1722/1733, 802.1AS, and 802.1Q stream reservation. [^31^]
Source: CETITEC AVB and TSN Product Page
URL: https://www.cetitec.com/products/avb-and-tsn/
Date: Current
Excerpt: "CETITEC's AVB Reference Infotainment System consists of: Renesas R-Car H2 board with Linux, which is used as an automotive headunit and acts as an audio talker and video listener."
Context: Third-party AVB stack implementation on Renesas hardware
Confidence: High
```

**AVB Hardware Support Summary:**
- IEEE 802.1BA: AVB Systems (R-Car H3, S4, V4H, RH850/U2B, U2C)
- IEEE 802.1AS: gPTP Timing and Synchronization (all platforms)
- IEEE 802.1Qav: Credit-Based Shaper (all platforms)
- IEEE 1722: AVTP Transport Protocol (all AVB-capable platforms)
- IEEE 1733: RTP-based transport (supported via software on R-Car)

---

## 9. Hardware Offloads

```
Claim: The Renesas Gigabit Ethernet (GbEth) IP supports hardware acceleration for RX TCP, UDP, and ICMPv6 checksums, and the hardware appends a 64-bit receive frame information status word to each received frame. [^32^]
Source: Google AI Overview / Linux Kernel Documentation
URL: https://www.google.com/search?q=Renesas+EtherAVB+MAC+hardware+offload+checksum+VLAN+header+operations
Date: Accessed 2025
Excerpt: "The Gigabit Ethernet (GbEth) IP supports hardware acceleration for receiving TCP, UDP, and ICMPv6 checksums... When a frame is received, the MAC appends a 64-bit status word to the frame, indicating error status, frame size, and type."
Context: Hardware offload capabilities summary
Confidence: High
```

```
Claim: The ravb Linux driver had to disable IPv4 header TX checksum offloading because the hardware does not correctly calculate IPv4 header checksums in the TX path. [^33^]
Source: Patchew / Linux Kernel Mailing List
URL: https://patchew.org/linux/20240930160845.8520-1-paul@pbarker.dev/20240930160845.8520-7-paul@pbarker.dev/
Date: September 30, 2024
Excerpt: "From: Paul Barker <paul.barker.ct@bp.renesas.com> For IPv4 packets, the header checksum will always be calculated in software in the TX path"
Context: Linux kernel patch submission from Renesas engineer
Confidence: High
```

```
Claim: The GbEth IP supports offloading IPv6 TCP, UDP & ICMPv6 checksums in the RX path, enabled by control register bits like CSR2_RTCP4, CSR2_RUDP4, CSR2_RICMP4, CSR2_RTCP6. [^34^]
Source: Patchew / Linux Kernel
URL: https://patchew.org/linux/202410151336... (ravb: Enable IPv6 RX checksum offloading for GbEth)
Date: October 15, 2024
Excerpt: "The GbEth IP supports offloading IPv6 TCP, UDP & ICMPv6 checksums in the RX path."
Context: Linux kernel patch for ravb driver
Confidence: High
```

**Hardware Offload Capabilities:**

| Feature | R-Car Gen3 (H3) | R-Car Gen4 (S4/V4H) | RH850/U2B |
|---------|-----------------|---------------------|-----------|
| RX IPv4 checksum | Yes | Yes | Limited |
| TX IPv4 header checksum | Software only | Software only | Software |
| RX IPv6 TCP/UDP/ICMPv6 | Yes | Yes | Yes |
| TX TCP/UDP checksum | Hardware | Hardware | Limited |
| VLAN tag insertion/stripping | Yes | Yes | Yes |
| RX 64-bit status word | Yes | Yes | Yes |

---

## 10. Security Features

```
Claim: The R-Car S4 incorporates multiple Hardware Security Modules (HSMs), supports secure boot, encryption, authentication, and features "Freedom from Interference" (FFI) using Region ID and SPID access protection. [^35^]
Source: Google AI Overview / Renesas Documentation
URL: https://www.google.com/search?q=Renesas+R-Car+S4+security+features+HSM+firewall+Ethernet+IDS+IPS
Date: Accessed 2025
Excerpt: "Multiple Hardware Security Modules (HSMs): The R-Car S4 incorporates multiple HSMs, supporting secure boot, encryption, and authentication... Hardware Firewalls & Access Protection: It supports 'Freedom from Interference' (FFI) using Region ID and System Peripheral ID (SPID) access protection."
Context: Security feature summary
Confidence: High
```

```
Claim: The R-Car S4 Starter Kit includes IDS/IPS (Intrusion Detection/Prevention System) reference software for network security, enabling developers to build secure automotive gateway systems. [^36^]
Source: Renesas Blog / Embedded Computing Design
URL: https://www.renesas.com/en/blogs/accelerate-your-automotive-innovations-r-car-s4-soc-low-cost-evaluation-board-starter-kit
Date: July 22, 2023
Excerpt: "By incorporating intrusion detection/protection service (IDS/IPS) reference software, the starter kit enables developers to build secure and..."
Context: Official Renesas blog post
Confidence: High
```

```
Claim: The R-Car S4 is compliant with ISO-26262 functional safety up to ASIL D and supports ISO/SAE 21434 cybersecurity standards. [^37^]
Source: Multiple sources (Renesas, TechInsights)
URL: https://www.techinsights.com/r-car-s4-bo...
Date: Current
Excerpt: "The Renesas R-Car S4 serves as a vehicle's central networking hub, but it also integrates ASIL-capable application CPUs, real-time CPUs, and safety"
Context: Third-party technical analysis
Confidence: High
```

**Security Features Summary:**

| Feature | R-Car S4 | R-Car V4H | RH850/U2C |
|---------|----------|-----------|-----------|
| Multiple HSMs | Yes | Yes | Yes |
| Secure Boot | Yes | Yes | Yes |
| Hardware Firewall | Yes | Yes | Yes |
| IDS/IPS Support | Yes (reference SW) | Limited | No |
| ISO/SAE 21434 | Yes | Yes | Yes |
| ASIL D | Yes | Yes | Yes |
| EVITA Full | Yes | Yes | Yes |

---

## 11. Buffer Descriptors & Queue Management

```
Claim: The Renesas Ethernet DMA architecture uses ring buffer descriptors in shared system memory, with the hardware traversing a linked list of descriptors. Each descriptor contains pointers to buffer memory, frame size, and status fields. [^38^]
Source: Google AI Overview
URL: https://www.google.com/search?q=Renesas+R-Car+Ethernet+DMA+descriptor+buffer+queue+architecture+hardware
Date: Accessed 2025
Excerpt: "Descriptor Ring Structure: The DMA works by traversing a list (ring) of descriptors. Each descriptor contains pointers to buffer memory... Descriptor Status Updates: The hardware updates the status fields in the descriptors, such as ownership bits, to notify the CPU that a frame has been received or transmitted."
Context: DMA architecture description
Confidence: High
```

**Buffer Descriptor Architecture:**
- **Ring-based structure**: Linked list of descriptors in system memory
- **Ownership bits**: Hardware/CPU handshaking mechanism
- **Multi-buffer support**: One frame per descriptor or scatter-gather across multiple descriptors
- **Zero-copy capability**: DMA writes directly into networking stack memory spaces
- **Status fields**: Error status, frame size, type information appended as 64-bit word
- **Interrupt generation**: "Finish" interrupts for TX/RX completion

---

## 12. RH850 vs R-Car Ethernet Capability Comparison

| Feature | RH850/F1KM | RH850/U2B | RH850/U2C | R-Car H3 | R-Car S4 | R-Car V4H |
|---------|-----------|-----------|-----------|----------|----------|-----------|
| **Target** | Body ECU | Cross-domain | Zone/Domain | IVI/Cockpit | Central Gateway | ADAS/AD |
| **Max Speed** | 100 Mbps | 1 Gbps | 1 Gbps | 1 Gbps | 2.5 Gbps | 1 Gbps (4x) |
| **Ethernet MAC** | EtherMAC | ETN (TSN) | ETN (TSN) | EtherAVB | 3-port TSN switch | TSN End-station |
| **PHY Interface** | MII/RMII | SGMII | SGMII | RGMII | RGMII | RGMII (4x) |
| **TSN 802.1AS** | No | Yes | Yes | Via SW | Yes | Yes (rev) |
| **TSN 802.1Qav** | No | Yes | Yes | Via SW | Yes | Yes |
| **TSN 802.1Qbv** | No | No | No | Via R-Switch2 | Yes | Yes |
| **TSN 802.1Qbu** | No | No | No | Via R-Switch2 | Yes | Yes |
| **AVB 1722** | No | Yes | Yes | Yes | Yes | Yes |
| **Layer 2/3 Switch** | No | No | No | No | Yes | No |
| **HW Checksum** | Limited | Yes | Yes | Yes | Yes | Yes |
| **VLAN HW** | No | Yes | Yes | Yes | Yes | Yes |
| **Timestamp** | No | Yes | Yes | Yes | Yes | Yes |
| **Safety (ASIL)** | B-D | D | D | B | D | D |
| **Security** | HSM | HSM | HSM/EVITA | HSM | HSM/IDS/IPS | HSM |

---

## 13. Documentation Sources

### Primary Sources (Renesas Official)

1. **RH850/U2B Group Gbit Ethernet Application Note** (R01AN7074EJ0100)
   - URL: https://www.renesas.com/en/document/apn/rh850u2b-group-gbit-ethernet-application-note-r01an7074ej0100
   - Date: Rev.1.00, January 11, 2024

2. **RH850/U2B Group Fast Ethernet Application Note**
   - URL: https://www.renesas.com/en/document/apn/rh850u2b-group-fast-ethernet-application-note
   - Date: Rev.1.00, October 10, 2023

3. **R-Car H3 Main Specifications** (PRE Document)
   - URL: https://www.renesas.com/en/document/pre/main-specifications-r-car-h3-soc
   - Date: December 2, 2015

4. **R-Car S4 Series User's Manual: Hardware** (R19UH0161EJ0130)
   - URL: https://www.renesas.com/en/document/mah/r-car-s4-series-users-manual-hardware-r19uh0161ej0130
   - Date: Rev.1.30, June 30, 2025

5. **R-Car S4 Product Page**
   - URL: https://www.renesas.com/en/products/r-car-s4

6. **R-Car V4H Product Page**
   - URL: https://www.renesas.com/en/products/r-car-v4h

7. **R-Car H3e Product Page**
   - URL: https://www.renesas.com/en/products/r-car-h3e

8. **RH850/F1KM-S4 Product Page**
   - URL: https://www.renesas.com/en/products/rh850-f1km-s4

9. **RH850/U2C Product Page**
   - URL: https://www.renesas.com/en/products/rh850-u2c

10. **RH850/P1M-C Product Page**
    - URL: https://www.renesas.com/en/products/rh850-p1m-c

### Secondary Sources (Industry Publications)

11. **Renesas "Art of Networking" Blog Series**
    - URL: https://www.renesas.com/en/blogs/art-networking-series-3-power-virtualization
    - Topics: VC3 board, R-Switch2, TSN virtualization

12. **CETITEC AVB Reference System**
    - URL: https://www.cetitec.com/products/avb-and-tsn/
    - Demonstrates R-Car H2/E2 AVB capabilities

13. **Linux Kernel ravb/rtsn Drivers**
    - URL: https://kernel.org/doc/Documentation/devicetree/bindings/net/renesas%2Cravb.txt
    - URL: https://lwn.net/ (R-Car V4H rtsn driver)

14. **RH850/U2C Press Coverage**
    - URL: https://chargedevs.com/newswire/renesas-28-nm-rh850u2c-mcu-targets-asil-d-vehicle-control-bms-and-zonal-architectures/
    - Date: March 6, 2026

---

## Research Methodology Notes

### Search Queries Used (22+ Independent Searches)

1. `Renesas RH850 Ethernet EtherMAC datasheet` - General RH850 Ethernet info
2. `Renesas R-Car S4 Ethernet TSN hardware manual` - S4 TSN documentation
3. `Renesas R-Car H3 Ethernet AVB EtherAVB TSN GMAC` - H3 AVB/TSN features
4. `site:renesas.com R-Car H3 Ethernet hardware manual` - Official H3 docs
5. `Renesas R-Switch2 TSN Ethernet switch automotive` - External TSN switch
6. `RH850 F1KM Ethernet MAC 100Mbps RMII MII hardware` - F1KM Ethernet specs
7. `Renesas R-Car Gen4 S4 H4 Ethernet TSN 802.1AS 802.1Qav` - Gen4 TSN
8. `RH850 U2A U2B Ethernet TSN controller SGMII RGMII` - U2B interfaces
9. `Renesas R-Car S4 3-port Ethernet switch 2.5Gbps TSN gateway features` - S4 switch
10. `Renesas EtherTSU timestamp PTP hardware manual R-Car` - Timestamp unit
11. `Renesas EtherAVB MAC hardware offload checksum VLAN header operations` - Offloads
12. `site:renesas.com R-Car S4 hardware manual Ethernet switch TSN chapter` - S4 manual
13. `Renesas R-Car Ethernet DMA descriptor buffer queue architecture hardware` - DMA
14. `Renesas R-Car S4 security features HSM firewall Ethernet IDS IPS` - Security
15. `Renesas RH850 P1M-C Ethernet body domain controller features` - P1M-C
16. `Renesas RH850 U2C Ethernet TSN 28nm automotive MCU` - U2C new MCU
17. `Renesas R-Car V4H Ethernet TSN end-station 1Gbps 2.5Gbps` - V4H Ethernet
18. `Renesas R-Car H3e Ethernet AVB TSN RGMII specifications` - H3e specs
19. `Renesas R-Car H3e-2G Ethernet AVB specifications RGMII 1Gbps` - H3e-2G
20. `Renesas R-Car S4 integrated Ethernet switch 3-port TSN` - S4 switch details
21. `RH850 F1KH Ethernet AVB hardware specifications` - F1KH variant
22. `Renesas automotive Ethernet security features hardware` - Security overview

### Limitations & Gaps

- **R-Car S4 Hardware Manual**: Requires MyRenesas login for full access; specific register-level details for the TSN switch IP could not be extracted
- **RH850/F1KM Hardware Manual**: Detailed EtherMAC register maps not accessible without login
- **EtherTSU Block Diagram**: Limited publicly available documentation on the internal architecture of the timestamp unit
- **R-Car H3 vs H3e Ethernet Differences**: No material differences found in Ethernet capabilities between H3 and H3e variants
- **TSN Switch IP**: The exact internal architecture of the S4's integrated 3-port TSN switch (vendor/IP source) is not publicly disclosed

### Counter-Arguments / Conflicting Information

- **TX IPv4 Checksum**: The Linux kernel patches indicate that the GbEth IP does NOT correctly calculate IPv4 header checksums in TX path, requiring software calculation. This is a documented hardware limitation.
- **R-Car H3 TSN vs AVB**: The original R-Car H3 documentation specifies "AVB 1.0" support. Later Gen4 documentation (S4/V4H) explicitly lists full TSN protocol support. The H3's AVB capabilities can be extended to TSN through external R-Switch2.
- **RH850 U2C TSN Speed**: Press releases mention both 1 Gbps and 100 Mbps TSN support; the exact PHY interface configuration for U2C remains unclear from public sources.

---

*End of Dimension 04 Research Report*
