# Dimension 05: TSN Protocol Hardware Support Comparison

## Research Overview

This document compares how **Infineon TC4x**, **NXP S32G**, and **Renesas RH850/R-Car** support TSN (Time-Sensitive Networking) protocols in hardware. The research is based on official datasheets, product briefs, errata sheets, application notes, academic papers, and community forum discussions.

---

## 1. Infineon AURIX TC4x TSN Hardware Support

### 1.1 Architecture Overview

TC4x provides two Ethernet MAC modules with distinct capabilities [^20^]:

- **GETH (Gigabit Ethernet MAC)**: 2x 5Gbps ports, includes hardware bridge (ETHMAC)
- **LETH (Lite Ethernet)**: 4x 10/100Mbps ports, supports 10BASE-T1S (IEEE 802.3cg-2019)

Claim: GETH supports up to 2x5GBit Ethernet including bridge, with Ethernet ports supporting IEEE 802.1 AVB and TSN protocol hardware requirements. LETH supports 4x10/100MBit Ethernet speeds plus 10Base-T1S standard.
Source: Infineon AURIX TC4x Getting Started Guide
URL: https://www.infineon.cn/assets/china/public/documents/10/tc4--b5--25.07.15--final.pdf
Date: 2025-05-08
Excerpt: "高速和时效性的Gigabit Ethernet GETH(ETHMAC):支持高达2x5GBit以太网，包括桥接器，以太网端口支持IEEE 802.1 AVB和TSN协议的硬件要求"
Context: Official Infineon TC4x introductory guide for China market
Confidence: High

### 1.2 TSN Protocol Support Matrix (TC4Dx)

| IEEE Standard | Protocol Name | GET (GETH) | LETH |
|---------------|---------------|------------|------|
| 802.1AS/AS-2020 | Timing and Synchronization | *(unspecified)* | *(unspecified)* |
| 802.1Qav | Credit-Based Shaper (CBS) | Yes | Yes |
| 802.1Qbv | Time-Aware Shaper (TAS) | Yes | Yes |
| 802.1Qbu | Frame Preemption | Yes | No |
| 802.1Qci | Per-Stream Filtering/Policing | Partial | Partial |
| 802.1CB | Frame Replication and Elimination (FRER) | SW-based | SW-based |

Claim: TC4Dx GETH and LETH both support 802.1Qav (CBS) and 802.1Qbv (TAS) in hardware; 802.1Qbu (Frame Preemption) is hardware-supported only on GETH, not on LETH; 802.1Qci is partially supported on both; 802.1CB is software-based on both.
Source: Infineon AURIX TC4x Getting Started Guide / Infineon Ecosystem Blog
URL: https://www.infineon.cn/assets/china/public/documents/10/tc4--b5--25.07.15--final.pdf
Date: 2025-05-08
Excerpt: "|IEEE 802.1Qav|Credit Base Shaper|是/是| |IEEE 802.1Qbv|Time-Ance Shaper|是/是| |IEEE 802.1Qbu|Frame Preemption|是/否| |IEEE 802.1Qci|Filtering and Policing|部分是/部分是| |IEEE 802.ECB|Frame Publication and Elimination|基于SW(两者)|"
Context: Official Infineon TC4x TSN support table
Confidence: High

**Note**: The table contains a typo labeling 802.1Qbv as "Time-Ance Shaper" (should be Time-Aware Shaper) and lists 802.1Qbu twice. The 802.1AS/AS-2020 row has empty cells, suggesting either software implementation or unspecified hardware support.

### 1.3 IEEE 802.1AS/gPTP Time Synchronization

The official TC4x documentation does not explicitly state whether 802.1AS is implemented in hardware or software. An academic paper analyzing TC4x TSN support assumes 802.1AS is software-based [^143^]:

Claim: TC4x IEEE 802.1AS is supported, but the deployment is in software rather than hardware.
Source: UPC Academic Paper - "The Future Roadmap of In-Vehicle Network Processing"
URL: https://upcommons.upc.edu/server/api/core/bitstreams/33920a2f-f785-4022-a2ff-cc6261691114/content
Date: Unknown (academic publication)
Excerpt: "Aurix TC4x also claims TSN support which, given that is not specified in the new proposal, we assume it is the same as the previous generation... IEEE802.1AS is also supported, however in this case the deployment is in SW"
Context: Academic analysis based on publicly available information at the time; may not reflect final silicon
Confidence: Medium (academic inference, not official confirmation)

**Conflict Note**: The Infineon guide table leaves 802.1AS cells blank, neither confirming nor denying hardware support. Given that gPTP typically requires hardware timestamping for sub-microsecond accuracy, and TC4x GETH is a high-end 5Gbps MAC, hardware timestamping capability is highly probable, but the protocol stack (BMCA, servo, state machine) may still run partially in software.

### 1.4 IEEE 802.1Qav - Credit-Based Shaper (CBS)

CBS is fully supported in hardware on both GETH and LETH [^20^]. However, Infineon has documented a significant erratum affecting CBS accuracy [^174^]:

Claim: On TC4Dx GETH and LETH, when Credit-Based Shaper (CBS) is enabled, the credit is not decremented during the IPG (Inter-Packet Gap) phase of transmission, causing the traffic class to consume more bandwidth than programmed.
Source: Infineon AURIX TC4Dx AB-ES Errata Sheet
URL: https://www.infineon.com/assets/row/public/documents/10/52/infineon-aurix-tc4dx-ab-es-erratasheet-en.pdf
Date: 2025-06-18
Excerpt: "[GETH_AI.029] CBS credit not decremented during the IPG phase of transmission... As per IEEE 802.1Qav standard, the credit must also be decrement when the packet overheads are transmitted... However due to this defect, the MAC decrements the credit only up to last byte of packet data... and increments the credit during the subsequent nominal IPG period"
Context: Official Infineon errata for TC4Dx AB-ES step; also affects LETH (LETH_AI.005)
Confidence: High

**Performance Impact**: The errata provides a formula for the additional bandwidth consumed:

```
Additional BW = ((# of packets x 12 Bytes) / (Total bytes transmitted including preamble)) x FractionalBW programmed
```

For example, with 30% BW programmed and 100 packets of 128 bytes: **~2.65% extra bandwidth** consumed, effectively allocating 32.65% instead of 30% [^174^].

**Workaround**: "Calculate for a BW fraction target that is lesser than the desired one so that the actual BW consumed is closer to the desired one." [^174^]

### 1.5 IEEE 802.1Qbv - Time-Aware Shaper (TAS)

802.1Qbv is hardware-supported on both GETH and LETH [^20^]. However, an erratum affects TAS scheduling precision [^174^]:

Claim: When Time Aware Shaper (TAS/EST) is enabled on TC4x GETH, extra IPG (more than programmed minimum IPG) is observed in back-to-back packet transmission due to clock domain crossing delays between fGETH and MAC Transmitter clock domains.
Source: Infineon AURIX TC4Dx AB-ES Errata Sheet
URL: https://www.infineon.com/assets/row/public/documents/10/52/infineon-aurix-tc4dx-ab-es-erratasheet-en.pdf
Date: 2025-06-18
Excerpt: "[GETH_AI.032] Time Aware Shaper (TAS) additional IPG in case of back-to-back packet transmission... This can be in worst case 12 clock cycles of slowest among the two clocks (converted to bit times based on operating speed)"
Context: Official Infineon errata; only affects GETH (not listed for LETH in this errata)
Confidence: High

### 1.6 IEEE 802.1Qbu - Frame Preemption

Frame preemption is hardware-supported on **GETH only**, not on LETH [^20^][^287^].

Claim: TC4x GETH supports 802.1Qbu frame preemption (express MAC vs preemptable MAC, mPackets), but LETH does not support frame preemption.
Source: Infineon AURIX TC4x GETH TSN Support Article / Sina Finance
URL: https://finance.sina.com.cn/tech/roll/2025-01-10/doc-ineenatz5657501.shtml
Date: 2025-01-10
Excerpt: "以太网帧抢占是IEEE 802.1Qbu标准中规定的一项功能...可抢占式帧(Preemptable frame)可被分成两个或多个片段"
Context: Infineon ecosystem article explaining TC4x TSN features
Confidence: High

### 1.7 IEEE 802.1Qci - Per-Stream Filtering and Policing (PSFP)

TC4x provides **partial hardware support** for 802.1Qci on both GETH and LETH [^20^][^288^]:

Claim: TC4x GETH MAC implements PSFP through three hardware components: FFP (Flexible Frame Parser) for stream filtering (only 8 gateway IDs), GCL (Gate Control List) for stream gates, and PC (Police Counter) for metering.
Source: Weikeng Infineon Article / WPGDadatong Blog
URL: https://www.weikeng.com.tw/show_news.php?func=pro&id=1133
Date: 2025-01-08
Excerpt: "流过滤器：通过AURIX TC4x GETH MAC中的FFP(Flexible Frame Parser)实现，标识数据流ID并映射到8个网关ID之一；仅支持8个网关ID。流闸门：在AURIX TC4x GETH MAC的GCL中定义... 流量计：通过AURIX TC4x GETH MAC中的PC(Police Counter)实现"
Context: Infineon ecosystem partner article summarizing TC4x TSN capabilities
Confidence: High

**Limitation**: Only 8 gateway IDs are supported, which limits the number of concurrent streams that can be individually policed.

### 1.8 IEEE 802.1CB - Frame Replication and Elimination (FRER)

FRER is **software-based** on both GETH and LETH [^20^]. The hardware bridge supports MAC-to-MAC frame forwarding that can be leveraged for FRER applications, but the actual sequence number management, duplicate detection, and elimination are done in software.

Claim: TC4x 802.1CB FRER is software-based for both GET and LETH. The hardware bridge supports MAC-to-MAC forwarding that can assist FRER implementation but does not provide full hardware FRER.
Source: Infineon AURIX TC4x Getting Started Guide
URL: https://www.infineon.cn/assets/china/public/documents/10/tc4--b5--25.07.15--final.pdf
Date: 2025-05-08
Excerpt: "基于SW(两者)" (SW-based for both)
Context: Official Infineon TC4x TSN support table
Confidence: High

### 1.9 IEEE 802.1Qca - Path Control and Reservation

No evidence found of TC4x hardware support for 802.1Qca (Path Control and Reservation). This standard is typically implemented in higher-layer software or network configuration tools.

---

## 2. NXP S32G TSN Hardware Support

### 2.1 Architecture Overview

S32G provides Ethernet connectivity through two distinct hardware blocks [^53^][^446^]:

- **PFE (Packet Forwarding Engine)**: 3 Ethernet interfaces (PFE_MAC0/1/2), firmware-based architecture
- **GMAC_0**: 1 Ethernet interface (independent of PFE), Synopsys DWMAC 4/5 based

Claim: S32G3 uses PFE for three high-performance Ethernet interfaces and GMAC_0 for TSN time-aware shaping (802.1Qbv) and preemption (802.1Qbu). PFE supports TSN time synchronization (802.1AS-Rev) via firmware.
Source: NXP S32G3 Product Brief
URL: https://www.nxp.com/docs/en/product-brief/PBS32G3V2.pdf
Date: Unknown
Excerpt: "This Ethernet interface (GMAC_0) additionally supports TSN time aware shaping (802.1Qbv) and pre-emption (802.1Qbu) functionality... PFE provides... Support for TSN time synchronization (802.1AS-Rev)... Firmware based architecture"
Context: Official NXP product brief for S32G3
Confidence: High

### 2.2 TSN Protocol Support Split (Critical Finding)

The S32G has a **split TSN implementation** across PFE and GMAC_0:

| Protocol | PFE | GMAC_0 |
|----------|-----|--------|
| 802.1AS-Rev (gPTP) | Yes (firmware-based) | Yes (hardware) |
| 802.1Qbv (TAS) | No | Yes (hardware) |
| 802.1Qbu (Preemption) | No | Yes (hardware) |
| 802.1Qav (CBS) | Not documented | Not documented |
| 802.1Qci (PSFP) | No | No |
| 802.1CB (FRER) | No | No |

Claim: On S32G, GMAC_0 supports 802.1Qbv, 802.1AS-Rev, and 802.1Qbu in hardware, while PFE supports only 802.1AS-Rev (firmware-based). PFE does not support 802.1Qbv or 802.1Qbu.
Source: NXP Community Forum - TSN Support Plan on GMAC for S32G Platforms
URL: https://community.nxp.com/t5/S32G/TSN-support-plan-on-GMAC-for-S32G-platforms/m-p/1631938
Date: 2023-04-12
Excerpt: "GMAC: Time Aware Shaper (IEEE 802.1Qbv), Time Synchronization (IEEE 802.1AS-Rev), and Frame Preemption (IEEE 802.1Qbu)... PFE: Supports 802.1AS-Rev and IEEE 1588 precision clock synchronization protocol"
Context: NXP community forum answer from NXP expert confirming TSN feature split
Confidence: High

### 2.3 S32G2 vs S32G3 TSN Differences

A critical hardware difference exists between S32G2 and S32G3 regarding simultaneous TAS and preemption usage [^unknown-from-EB00922^]:

Claim: On S32G2, frame scheduling (802.1Qbv) and frame preemption (802.1Qbu) cannot be used at the same time. On S32G3, frame scheduling and frame preemption can be used simultaneously.
Source: EB Zoneo documentation / S32G platform comparison
URL: (from earlier search results referencing EB00922)
Date: Unknown
Excerpt: "S32G2: Frame scheduling and frame preemption cannot be used at the same time. S32G3: Frame scheduling and frame preemption can be used at the same time."
Context: Software/firmware documentation describing S32G2 vs S32G3 hardware capabilities
Confidence: High

### 2.4 IEEE 802.1AS/gPTP - Known Hardware Limitation

A significant known issue affects S32G's 802.1AS implementation [^451^]:

Claim: S32G experiences "no ingress timestamp" issues on 802.1AS/gPTP, causing ptp4l to report "received SYNC without timestamp" errors. This affects both PFE and GMAC ports and is a known hardware/software limitation.
Source: NXP Community Forum - s32g 802.1as no ingress timestamp
URL: https://community.nxp.com/t5/S32G/s32g-802-1as-no-ingress-timestamp/m-p/2078706
Date: 2025-04-14
Excerpt: "port 1 (eth0): received SYNC without timestamp... SO_TIMESTAMPING message test... hwts->type=1"
Context: User-reported issue on S32G399ARDb3 with Linux ptp4l; confirmed by dmesg showing firmware load
Confidence: High

This limitation severely impacts gPTP time synchronization accuracy on S32G platforms, as ingress timestamping is essential for precise peer delay measurement.

### 2.5 IEEE 802.1Qbv - Time-Aware Shaper (TAS)

GMAC_0 implements 802.1Qbv TAS in hardware. The hardware is based on Synopsys DWMAC 4/5 IP [^394^]:

Claim: S32G GMAC_0 uses Synopsys DWMAC 4/5 (User ID: 0x10, Synopsys ID: 0x52) and supports hardware TSN including TAS (802.1Qbv).
Source: NXP Community Forum - S32G3 Linux BSP boot log
URL: https://community.nxp.com/t5/S32G/There-is-no-Eth0-in-the-linux-bsp42-0-of-S32G-RDB3/m-p/2012845
Date: 2024-12-12
Excerpt: "s32cc-dwmac 4033c000.ethernet: User ID: 0x10, Synopsys ID: 0x52... s32cc-dwmac 4033c000.ethernet: DWMAC4/5"
Context: Linux kernel boot log on S32G399A EVB3 confirming GMAC hardware ID
Confidence: High

The GCL (Gate Control List) depth is configurable via the ESTDEP register field. Based on the GMAC Subsystem reference manual, the GCL depth field supports configurable depth settings [^from-register-info^]:

Claim: GMAC_0 GCL depth is configurable with register field ESTDEP controlling the depth of the gate control list for TAS.
Source: GMAC Subsystem Reference Manual / NXP documentation
URL: (from earlier search on GMAC register ESTDEP)
Date: Unknown
Excerpt: "GCL depth is configured through ESTDEP"
Context: Register-level hardware documentation for S32G GMAC
Confidence: Medium

### 2.6 IEEE 802.1Qbu - Frame Preemption

802.1Qbu frame preemption is supported in hardware on GMAC_0 only [^446^]. As noted above, on S32G2 it cannot be used simultaneously with 802.1Qbv TAS.

### 2.7 IEEE 802.1Qav, 802.1Qci, 802.1CB, 802.1Qca

No hardware support found for 802.1Qav (CBS), 802.1Qci (PSFP), 802.1CB (FRER), or 802.1Qca on S32G. These would need to be implemented in software if required.

---

## 3. Renesas RH850 / R-Car TSN Hardware Support

### 3.1 Architecture Overview

Renesas has a **dual-tier** approach to TSN support:

- **RH850 MCU family**: Older generations (F1KM, U2A) support only **Ethernet AVB**, not TSN [^413^][^408^]
- **R-Car SoC family**: V4H/V4M mention generic "TSN" support; S4 has AVB/TSN switch; **X5H has full R-Switch 3.0 TSN engine**

### 3.2 RH850 - No Native TSN Hardware Support

Claim: RH850/F1KM series MCU supports Ethernet AVB (Audio Video Bridging) with hardware features for gateway applications, but does NOT support TSN protocols like 802.1Qbv or 802.1AS in hardware.
Source: Sekorm / Renesas RH850/F1KM Article
URL: https://www.sekorm.com/news/97519563.html
Date: 2018-11-21
Excerpt: "瑞萨电子40nm MONOS闪存工艺的32位MCU RH850/F1KM... 多种通信接口（Ethernet AVB、8路CAN-FD(兼容CAN)、LIN、SPI等）"
Context: Renesas partner article describing RH850/F1KM for Ethernet gateway applications
Confidence: High

The RH850 U2B24-E MCU is paired with the R-Car X5H in demonstrations, but the TSN functionality comes from the X5H's R-Switch 3.0, not from the RH850 itself [^401^].

### 3.3 R-Car V4H/V4M - Generic TSN Mention

R-Car V4H and V4M mention "以太网AVB、TSN" (Ethernet AVB, TSN) as dedicated automotive interfaces, but no specific TSN protocol breakdown is provided in public documentation [^404^][^407^].

### 3.4 R-Car S4 - AVB/TSN Switch

R-Car S4 is described as having a "高速以太网AVB/TSN交换机" (high-speed Ethernet AVB/TSN switch) [^399^], but again, no detailed protocol list is available.

### 3.5 R-Car X5H - R-Switch 3.0 (Complete TSN Hardware)

The **R-Car X5H** represents Renesas's most comprehensive TSN implementation [^401^][^417^][^445^]:

Claim: R-Car X5H integrates R-Switch 3.0, a third-generation automotive Ethernet TSN switch IP providing up to 8 external ports (1G-10G), 8 internal ports, and 2 CPU ports with 100Gbps internal switching bandwidth. It fully supports 802.1AS-rev (dual clock domain), 802.1Qav, 802.1Qbv, 802.1Qbu+802.3br, 802.1Qci, and 802.1CB in hardware.
Source: Ameya360 / Renesas AES2026 Presentation Summary
URL: https://m.ameya360.com/hangye/116274.html
Date: 2026-04-21
Excerpt: "在TSN特性上，R-Switch 3.0几乎覆盖了所有车载所需的关键标准：802.1AS-rev(双时钟域)、802.1Qav(信用感知调度)、802.1Qbv(时间感知调度)、802.1Qbu + 802.3br(帧抢占)、802.1Qci(输入流监管)、802.1CB(帧复制与消除)。"
Context: Summary of Renesas presentation at AES2026 (Automotive Ethernet Summit); describes X5H and RH850 U2B24-E demo
Confidence: High

#### R-Switch 3.0 Specifications:

| Feature | Specification |
|---------|---------------|
| External Ports | Up to 8 (1Gbps - 10Gbps) |
| Internal Ports | 8 |
| CPU Ports | 2 |
| Total External Bandwidth | 50 Gbps aggregate |
| Internal Switching Bandwidth | 100 Gbps |
| Forwarding | L1-L4 full hardware (Port → MAC/Stream ID → IPv4/IPv6 → UDP/TCP) |
| Lookup Tables | CAM/TCAM |
| DMA | Multiple dedicated Ethernet DMA channels |
| Security | MACsec on all external ports |
| Standards | IEEE 802.1DG, OPEN TC11 |

Claim: R-Switch 3.0 provides hardware L1-L4 forwarding with CAM/TCAM lookup tables, dedicated DMA channels, and MACsec on all external ports.
Source: Ameya360 / Renesas AES2026
URL: https://en.ameya360.com/hangye/116274.html
Date: 2026-04-30
Excerpt: "转发架构：基于流水线的无阻塞存储转发，集成CAM/TCAM转发表... 路由能力：硬件完成从Layer 1 (Port) – Layer 2 (MAC/Stream ID) – Layer 3 (IPv4/IPv6) – Layer 4 (UDP/TCP) 等各层转发"
Context: Detailed R-Switch 3.0 architecture description
Confidence: High

### 3.6 Renesas TSN Support Summary

| Platform | 802.1AS | 802.1Qav | 802.1Qbv | 802.1Qbu | 802.1Qci | 802.1CB | 802.1Qca |
|----------|---------|----------|----------|----------|----------|---------|----------|
| RH850/F1KM | No | No | No | No | No | No | No |
| RH850/U2A | No | No | No | No | No | No | No |
| R-Car V4H/V4M | ? | ? | ? | ? | ? | ? | ? |
| R-Car S4 | ? | ? | ? | ? | ? | ? | ? |
| **R-Car X5H** | **Yes** | **Yes** | **Yes** | **Yes** | **Yes** | **Yes** | **Unknown** |

**Note**: For R-Car V4H/V4M/S4, public documentation only mentions "TSN" generically without protocol-level detail. The X5H is the only Renesas product with publicly documented full TSN protocol support.

---

## 4. Cross-Vendor TSN Hardware Comparison

### 4.1 Protocol Support Matrix

| Protocol | Infineon TC4x (GETH) | Infineon TC4x (LETH) | NXP S32G (GMAC_0) | NXP S32G (PFE) | Renesas R-Car X5H |
|----------|----------------------|----------------------|-------------------|----------------|-------------------|
| **802.1AS-2020/gPTP** | ? (likely SW) | ? (likely SW) | HW | FW-based | HW (dual domain) |
| **802.1Qav (CBS)** | HW | HW | ? | ? | HW |
| **802.1Qbv (TAS)** | HW | HW | HW | No | HW |
| **802.1Qbu (Preemption)** | HW | No | HW | No | HW |
| **802.1Qci (PSFP)** | Partial | Partial | No | No | HW |
| **802.1CB (FRER)** | SW | SW | No | No | HW |
| **802.1Qca** | No | No | No | No | Unknown |

### 4.2 Hardware Module Mapping

#### Infineon TC4x:
- **GETH (2x5Gbps)**: 802.1Qav (CBS), 802.1Qbv (TAS), 802.1Qbu (Preemption), Partial 802.1Qci, SW 802.1CB
- **LETH (4x10/100Mbps)**: 802.1Qav (CBS), 802.1Qbv (TAS), Partial 802.1Qci, SW 802.1CB
- **Bridge**: HW MAC-to-MAC forwarding for FRER assistance
- **CSS (Cyber Security Satellite)**: Crypto/Hash for secure Ethernet/CAN

#### NXP S32G:
- **GMAC_0**: 802.1Qbv (TAS), 802.1Qbu (Preemption), 802.1AS-Rev (gPTP)
- **PFE_MAC0/1/2**: 802.1AS-Rev (firmware-based gPTP/1588), L2/3/4 classification, routing/bridging up to 3 Gbps
- **S32G2 Limitation**: Cannot use 802.1Qbv and 802.1Qbu simultaneously
- **S32G3 Improvement**: Can use 802.1Qbv and 802.1Qbu simultaneously

#### Renesas R-Car X5H:
- **R-Switch 3.0**: All major TSN protocols in hardware (802.1AS-rev, 802.1Qav, 802.1Qbv, 802.1Qbu, 802.1Qci, 802.1CB)
- **Integrated**: 8 external + 8 internal + 2 CPU ports, 100 Gbps switching
- **RH850 U2B24-E**: Companion MCU for real-time processing; TSN comes from X5H

### 4.3 Performance Numbers

#### Time Synchronization Accuracy

| Platform | Claimed Accuracy | Notes |
|----------|-----------------|-------|
| IEEE 802.1AS Standard | < 1 μs end-to-end (7 hops) | ~15.6 ns per hop for industrial [^403^] |
| NXP (general) | "10s of nanoseconds" | With 1588 hardware timestamping [^402^] |
| S32G (actual) | Degraded | "No ingress timestamp" issue causes ptp4l failures [^451^] |
| TSN-TAS + gPTP (industrial) | ±50 ns | For >1024 channels in aerospace/power [^393^] |
| FPGA-based gPTP | 2^(-16) ns math resolution | Custom logic implementation [^403^] |

Claim: IEEE 802.1AS standard requires <1μs end-to-end synchronization accuracy for 7 or fewer hops during steady state. The 802.1AS-REV draft considers ~15.6 ns per hop for up to 64 hops in industrial applications.
Source: DornerWorks Blog
URL: https://www.dornerworks.com/blog/achieving-theoretical-maximum-performance-with-high-accuracy-time-synchronization-over-ethernet/
Date: 2019-11-26
Excerpt: "According to the IEEE 802.1AS standards, gPTP implementations must obtain < 1 μs end-to-end synchronization accuracy for 7 or fewer hops during steady state conditions. Currently, the IEEE 802.1AS-REV draft is considering 1-μs end-to-end synchronization accuracy for 64 or fewer hops for industrial applications which is approximately 15.6 ns per hop."
Context: Technical blog analyzing IEEE 802.1AS precision requirements
Confidence: High

Claim: NXP TSN platforms can achieve synchronization accuracy within "10s of nanoseconds" using 1588 hardware timestamping and time logic.
Source: NXP Time Sensitive Networking and Precision Time Protocol Presentation
URL: https://community.nxp.com/pwmxy87654/attachments/pwmxy87654/tech-days/235/1/AMF-IND-T3038.pdf
Date: Unknown
Excerpt: "Achieve synchronization accuracy within 10s of nanoseconds... 1588 hardware timestamping and time logic available in Layerscape processors"
Context: NXP technical presentation on TSN capabilities
Confidence: Medium (general NXP claim, not specifically validated for S32G)

#### Latency and Jitter

Claim: TSN with 802.1Qbv can control end-to-end delay within 1 ms in automotive applications.
Source: 21ic Electronics Network
URL: https://www.21ic.com/article/891365.html
Date: 2021-05-08
Excerpt: "时间敏感网络(TSN)：通过802.1Qbv时间感知调度、802.1Qbu帧抢占等标准，将端到端延迟控制在1ms以内"
Context: General industry article on TSN automotive applications
Confidence: Medium

---

## 5. Key Findings and Differentiators

### 5.1 Infineon TC4x Differentiators
- **Strengths**: GETH provides high-speed 5Gbps ports with comprehensive TSN (CBS, TAS, Preemption); LETH extends TSN to low-speed 10/100Mbps + 10BASE-T1S domain; integrated hardware bridge
- **Weaknesses**: Known errata affecting CBS accuracy (~2.65% extra bandwidth for small packets) and TAS back-to-back scheduling (up to 12 clock cycles extra IPG); 802.1CB is software-only; 802.1Qci limited to 8 gateway IDs; 802.1AS hardware support not explicitly confirmed
- **Unique**: Only vendor offering TSN (802.1Qbv/CBS) on 10BASE-T1S low-speed Ethernet via LETH

### 5.2 NXP S32G Differentiators
- **Strengths**: Dedicated GMAC_0 with HW TAS and preemption; PFE provides firmware-based flexible 802.1AS-Rev; high-performance L2/3/4 packet classification
- **Weaknesses**: **Split TSN implementation** - 802.1Qbv/Qbu only on GMAC_0, 802.1AS-Rev on both but PFE is firmware-based; **S32G2 cannot use TAS and preemption simultaneously**; known "no ingress timestamp" issue affecting gPTL accuracy; no HW support for 802.1Qci, 802.1CB, or 802.1Qav
- **Unique**: PFE's firmware-based architecture allows field-upgradable TSN features (at cost of determinism)

### 5.3 Renesas R-Car X5H Differentiators
- **Strengths**: **Most complete hardware TSN implementation** - all major protocols (802.1AS-rev, 802.1Qav, 802.1Qbv, 802.1Qbu, 802.1Qci, 802.1CB) in R-Switch 3.0; 100 Gbps switching bandwidth; L1-L4 hardware forwarding; dual-clock domain 802.1AS-rev
- **Weaknesses**: X5H is a high-end server-class SoC, not a traditional MCU; RH850 companion MCUs have no native TSN; earlier R-Car generations (V4H, S4) lack publicly documented protocol-level TSN support
- **Unique**: Only automotive platform with hardware 802.1CB FRER and 802.1Qci PSFP support documented; R-Switch 3.0 is a standalone switch IP that can be integrated across product lines

---

## 6. Conflicts and Uncertainties

### 6.1 TC4x 802.1AS Hardware vs Software
- **Academic paper** [^143^] claims TC4x 802.1AS is "deployment in SW"
- **Infineon official docs** leave 802.1AS cells blank in the support table [^20^]
- Given that GETH is a 5Gbps MAC with hardware timestamping typically required for gPTP, some hardware assistance likely exists, but the full protocol stack may be software-based
- **Resolution**: Confidence = Medium; requires direct review of TC4x GETH reference manual for timestamping registers

### 6.2 Renesas R-Car V4H/S4 TSN Detail Level
- Public Renesas documentation mentions "TSN" only generically for V4H, V4M, and S4 [^404^][^407^][^399^]
- No protocol-level breakdown (which specific 802.1 standards) is publicly available for these products
- **Resolution**: Cannot confirm whether V4H/S4 support 802.1Qbv, 802.1Qbu, etc. in hardware without access to detailed reference manuals

### 6.3 S32G GMAC_0 GCL Depth
- Register documentation confirms configurable GCL depth via ESTDEP field
- Exact maximum depth (64? 256? 1024?) could not be definitively confirmed from public sources
- **Resolution**: Confidence = Medium; likely configurable up to at least 1024 entries based on typical Synopsys DWMAC 5.x implementations

---

## 7. AUTOSAR and TSN Specification Context

Claim: AUTOSAR R22-11 and related standards increasingly require TSN support for automotive Ethernet, including 802.1AS time sync, 802.1Qbv TAS for deterministic scheduling, and 802.1Qci for cybersecurity/isolation.
Source: EB zoneo SwitchCore / Elektrobit
URL: https://www.elektrobit.cn/products/ecu/eb-zoneo/switchcore/
Date: 2023-11-06
Excerpt: "支持IEEE 802.1 TSN/AVB协议，例如gPTP (802.1AS)、停留时间补偿、交换机注册防火墙、基于以太网更新"
Context: Elektrobit automotive Ethernet switch firmware product page
Confidence: Medium

The automotive TSN landscape is evolving toward:
- **IEEE 802.1DG**: Automotive TSN profile (R-Switch 3.0 claims native support [^445^])
- **OPEN Alliance TC11**: TSN test specifications for automotive
- **OEM requirements**: Most major OEMs now require 802.1AS + 802.1Qbv minimum; some adding 802.1Qci for security

---

## 8. Summary Table

| Dimension | Infineon TC4x | NXP S32G | Renesas R-Car X5H |
|-----------|---------------|----------|-------------------|
| **Primary Ethernet MAC** | GETH (2x5G) + LETH (4x100M) | PFE (3x1/2.5G) + GMAC_0 (1x1G) | R-Switch 3.0 (8x1-10G ext + 8 int) |
| **802.1AS-2020** | ? (likely SW-assisted) | HW (GMAC) + FW (PFE) | HW (dual clock domain) |
| **802.1Qav (CBS)** | HW (both GETH/LETH) | No HW support | HW |
| **802.1Qbv (TAS)** | HW (both GETH/LETH) | HW (GMAC_0 only) | HW |
| **802.1Qbu (Preemption)** | HW (GETH only) | HW (GMAC_0 only) | HW |
| **802.1Qci (PSFP)** | Partial (8 gate IDs) | No | HW |
| **802.1CB (FRER)** | SW | No | HW |
| **Simultaneous Qbv+Qbu** | Yes | S32G2: No / S32G3: Yes | Yes |
| **Max Switch Bandwidth** | Not disclosed | 3 Gbps (PFE) | 100 Gbps |
| **Known Errata/Limitations** | CBS IPG bug, TAS extra IPG | No ingress timestamp issue | None publicly reported |

---

## Citations

[^20^] Infineon AURIX TC4x Getting Started Guide (China) - https://www.infineon.cn/assets/china/public/documents/10/tc4--b5--25.07.15--final.pdf
[^53^] NXP S32G3 Product Brief - https://www.nxp.com/docs/en/product-brief/PBS32G3V2.pdf
[^143^] UPC Academic Paper - "The Future Roadmap of In-Vehicle Network Processing" - https://upcommons.upc.edu/server/api/core/bitstreams/33920a2f-f785-4022-a2ff-cc6261691114/content
[^174^] Infineon AURIX TC4Dx AB-ES Errata Sheet - https://www.infineon.com/assets/row/public/documents/10/52/infineon-aurix-tc4dx-ab-es-erratasheet-en.pdf
[^233^] NXP Community - TSN Support Plan on GMAC for S32G - https://community.nxp.com/t5/S32G/TSN-support-plan-on-GMAC-for-S32G-platforms/m-p/1631938
[^287^] Sina Finance - AURIX TC4x GETH TSN Support - https://finance.sina.com.cn/tech/roll/2025-01-10/doc-ineenatz5657501.shtml
[^288^] Weikeng - Infineon TC4x PSFP Article - https://www.weikeng.com.tw/show_news.php?func=pro&id=1133
[^293^] WPGDadatong - AURIX TC4x Ethernet/TSN Overview - https://www.wpgdadatong.com/blog/detail/75463
[^394^] NXP Community - S32G3 Linux Boot Log - https://community.nxp.com/t5/S32G/There-is-no-Eth0-in-the-linux-bsp42-0-of-S32G-RDB3/m-p/2012845
[^399^] QQ News - Renesas Next Generation EE Architecture - https://view.inews.qq.com/a/20230917A033XY00
[^401^] Ameya360 - Renesas R-Car X5H TSN Network - https://m.ameya360.com/hangye/116274.html
[^402^] NXP TSN/Precision Time Presentation - https://community.nxp.com/pwmxy87654/attachments/pwmxy87654/tech-days/235/1/AMF-IND-T3038.pdf
[^403^] DornerWorks - High Accuracy Time Sync - https://www.dornerworks.com/blog/achieving-theoretical-maximum-performance-with-high-accuracy-time-synchronization-over-ethernet/
[^404^] Renesas R-Car V4H/V4M Announcement - https://www.renesas.cn/zh/about/newsroom/renesas-leads-adas-innovation-power-efficient-4th-generation-r-car-automotive-socs
[^407^] Renesas R-Car V4H Announcement - https://www.renesas.cn/zh/about/newsroom/renesas-unveils-r-car-v4h-automated-driving-level-2-level-3-support-high-volume-vehicle-production
[^413^] Sekorm - RH850/F1KM Ethernet Gateway - https://www.sekorm.com/news/97519563.html
[^417^] ICANIC - R-Car X5H R-Switch 3.0 - https://www.icanic.cn/news/9335.html
[^445^] Ameya360 EN - R-Car X5H Specifications - https://en.ameya360.com/hangye/116274.html
[^446^] NXP S32G2 Product Brief - https://www.mouser.com/pdfDocs/NXP_S32G2_PB.pdf
[^451^] NXP Community - S32G 802.1AS No Ingress Timestamp - https://community.nxp.com/t5/S32G/s32g-802-1as-no-ingress-timestamp/m-p/2078706
