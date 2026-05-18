# Dimension 8: CSS - Cyber Security Satellite (AURIX TC4x)

## Executive Summary

The **Cyber Security Satellite (CSS)** is a brand-new hardware module in the Infineon AURIX TC4x microcontroller family, designed as a distributed cryptographic acceleration engine for symmetric cryptography and hash functions. Located directly on the SRI crossbar, the CSS provides **20+1 independent channels** with dedicated hardware accelerators including **3x AES engines**, **Chacha20**, **SipHash (2-4, 4-8)**, **Poly1305**, and **SHA-x hash engines**. With an **8KB internal RAM** for secret key storage and an **ASIL-D Safe MAC Comparator**, the CSS enables high-throughput, low-latency security processing for automotive Ethernet (MACsec, IPsec, D/TLS, SecOC) and CAN communication without burdening the main CPU cores.

---

## Table of Contents

1. [CSS Architecture](#1-css-architecture)
2. [Hardware Accelerators](#2-hardware-accelerators)
3. [Key Management](#3-key-management)
4. [ASIL-D Safety Features](#4-asil-d-safety-features)
5. [Performance Figures](#5-performance-figures)
6. [Ethernet Security Use Cases](#6-ethernet-security-use-cases)
7. [System Integration](#7-system-integration)
8. [Comparison with TC3x HSM](#8-comparison-with-tc3x-hsm)
9. [References](#9-references)

---

## 1. CSS Architecture

### 1.1 Location on SRI Crossbar

The CSS is a **brand new module located on the SRI (Shared Resource Interconnect) crossbar** [^21^], providing lowest-latency data transfer for connected masters. As shown in the system architecture diagram:

```
+---------------------+        SRI interconnect        +---------------------+
|   Cybersecurity     |<==============================>|   TriCore LS CPU    |
|      Domain         |     +------------------+       |   (Application)     |
|                     |     |      CSS         |       +---------------------+
|  +---------------+  |     |  (20+1 channels) |       +---------------------+
|  |  TriCore LS   |  |     +------------------+       |   TriCore LS CPU    |
|  |   (CSRM)      |  |            ^                  |   (Application)     |
|  +---------------+  |            | Bridge             +---------------------+
|  |     DMA       |  |            v
|  +---------------+  |     +------------------+       +---------------------+
|  |   D-NVMcs     |  |     |      CSRM        |       |      NVMcs        |
|  +---------------+  |     |  (Cybersecurity  |       |  (Non-volatile)   |
|  |     RNG       |  |     |   Real-time Mod) |       +---------------------+
|  +---------------+  |     +------------------+
|  |   Public Key  |  |
|  |    Crypto     |  |
|  +---------------+  |
+---------------------+
```

> **"CSS is located on a crossbar with 2 CPUs and a DMA: lowest latency for data transfer"** [^21^]

The CSS is connected with the rest of the device through the **SRI bus**, and functional blocks related to the Cyber Security (CS) Cluster can be associated with the CSRM using the **PROT/APU mechanism** (e.g., DMA, IR, WTU, VMT, SMU, SMM, Clock and Debug control) [^21^].

### 1.2 20+1 Independent Channels

The CSS provides **up to 20+1 channels** for independent tasks for symmetric cryptography and hash functions [^21^]:

| Feature | Specification |
|---------|--------------|
| Total Channels | 21 (20 application + 1 CSRM exclusive) |
| Channel Type | Independent, parallel operation |
| Channel Purpose | Symmetric cryptography and hash functions |
| Freedom of Interference | Yes - channels are isolated |

> **"Up to 20+1 channels for independent task for symmetric cryptography and Hash functions"** [^21^]

> **"21 individual channels to be used by application (compared to one channel in TC3x)"** [^5^]

The **+1 channel is exclusively reserved for the CSRM** (CPUcs), meaning 20 channels are available for application CPUs, DMA, and other bus masters. This represents a massive architectural improvement over TC3x, which had only a single HSM channel.

### 1.3 Connection to CSRM

The **CSRM (Cyber Security Real-time Module)** is connected to the CSS via a bridge on the same SRI crossbar:

> **"CSRM is connected via a bridge to the same crossbar"** [^21^]

The CSRM serves as the **root of trust** and security manager for the CSS. After reset:

- **CSRM has exclusive rights to access CSS**
- **CSRM configures the channel's access rights** [^21^]

The CSRM contains:
- A dedicated **TriCore 1.8 CPU (CPUcs)** running at up to 500 MHz
- **Public Key Crypto (PKC)** engine for asymmetric operations
- **True Random Number Generator (TRNG)**
- Private PFlash and data flash (NVMcs, D-NVMcs)
- **Cyber-Security Bus Control Unit (CSBCU)**

### 1.4 Access Rights and Configuration Model

The CSS implements a sophisticated **multi-layer access control** system:

#### Access Granularity (Per Channel)
For each channel, access can be independently configured for:
- **Read/write data** - Allow data transfers through the channel
- **Read/write configuration** - Allow modification of channel settings [^21^]

#### Exclusive CSRM Configuration Interface
The CSRM has exclusive configuration rights over:

| Configuration Item | Description |
|--------------------|-------------|
| **Channels priority** | Assign priority levels to channels |
| **Interrupts mapping** | Map channel interrupts to system interrupt router |
| **Reaction for keys locking on event** | Configure key lock behavior on security events |
| **Allocation of channels to CSS RAM areas** | Assign specific RAM regions to each channel |
| **Write keys to whole CSS RAM** | Write keys (except write-protected keys) |
| **Threshold of failed authentication** | Per-channel alarm threshold |
| **Rights for channel configuration masters** | Allow masters to update their own keys |

> **"After reset, CSRM has exclusive rights to access CSS, configure the channel's access rights"** [^21^]

#### Three Cybersecurity Use Case Modes

The CSS supports three operational modes [^21^]:

1. **Backward Compatibility** - CSRM updates keys and uses CSS crypto (similar to TC3x HSM model)
2. **Security & Performance** - CSRM updates keys, Host (application CPU) uses CSS crypto directly - **"reducing critical delays for short frames (e.g. CAN, ETH control frames)"**
3. **Pure HW Accelerator** - Host updates keys and uses CSS crypto directly - maximum throughput, lowest latency

---

## 2. Hardware Accelerators

The CSS integrates multiple dedicated hardware accelerators for parallel cryptographic processing:

### 2.1 3x AES Engines

The CSS contains **three AES hardware engines** supporting:

| AES Mode | Key Sizes | Use Case |
|----------|-----------|----------|
| **AES-CMAC** | 128-bit, 192-bit, 256-bit | Message authentication (CAN/Ethernet frames) |
| **AES-GMAC** | 128-bit, 256-bit | Authentication for MACsec, IPsec |
| **AES-GCM** | 128-bit, 256-bit | AEAD encryption/decryption |
| **GHASH** | - | Authentication component of GCM |

> **"AES256 bit supporting CMAC, GMAC, GHASH cipher modes among others"** [^21^]

> **"3 x AES, Chacha20, SipHash(2-4, 4-8), Poly1305 and SHAx HW accelerators"** [^21^]

The three AES engines enable parallel processing of multiple AES operations simultaneously, which is critical for multi-channel MACsec/IPsec processing at gigabit Ethernet speeds.

### 2.2 Chacha20 Engine

- **Stream cipher** providing confidentiality
- 256-bit key, 96-bit nonce
- **30 cycles per 64 bytes** at 400 MHz
- Throughput: **856 MB/s** [^21^]
- Used in **ChaCha20-Poly1305 AEAD** mode for TLS 1.3, DTLS

### 2.3 SipHash Engine

The CSS includes a dedicated **SipHash engine** supporting both variants:

| Variant | Cycles/64B | Throughput @ 400MHz | Use Case |
|---------|-----------|---------------------|----------|
| **SipHash 2-4** | 20 cycles | **1280 MB/s** | Fast message authentication |
| **SipHash 4-8** | 40 cycles | **640 MB/s** | Higher security margin |

> **"SipHash24: 20 cycles / 64 bytes = 1280 MB/s, SipHash48: 40 cycles / 64 bytes = 640 MB/s"** [^21^]

SipHash is particularly relevant for **SecOC (Secure Onboard Communication)** PDU-level authentication in AUTOSAR networks.

### 2.4 Poly1305 Engine

- **Message authentication code (MAC)** algorithm
- **55 cycles per 64 bytes** at 400 MHz
- Throughput: **468 MB/s** [^21^]
- Combined with Chacha20 to form **ChaCha20-Poly1305 AEAD**

> **"ChaCha20/Poly1305 = Poly"** [^21^] - The CSS can combine Chacha20 and Poly1305 operations

### 2.5 SHA-x Hash Engines

The CSS provides comprehensive hash acceleration:

| Algorithm | Cycles/Input | Throughput @ 400MHz |
|-----------|-------------|---------------------|
| **SHA-1 (160)** | 88 cycles / 64 bytes | **292 MB/s** |
| **SHA-224** | 72 cycles / 64 bytes | **356 MB/s** |
| **SHA-256** | 72 cycles / 64 bytes | **356 MB/s** |
| **SHA-384** | 88 cycles / 128 bytes | **584 MB/s** |
| **SHA-512** | 88 cycles / 128 bytes | **584 MB/s** |
| **HMAC(xxx)** | Few additional cycles for key | ~same as base hash |
| **SHA3-224** | 27 cycles / 144 bytes | **2136 MB/s** |
| **SHA3-256** | 27 cycles / 136 bytes | **2016 MB/s** |
| **SHA3-384** | 27 cycles / 104 bytes | **1544 MB/s** |
| **SHA3-512** | 27 cycles / 72 bytes | **1068 MB/s** |
| **SHAKE128** | 27 cycles / 168 bytes | **2492 MB/s** |
| **SHAKE256** | 27 cycles / 136 bytes | **2016 MB/s** |

> Preliminary performance figures from simulation [^21^]

### 2.6 Accelerator Summary Table

| Accelerator | Count | Primary Use | Ethernet Security Role |
|-------------|-------|-------------|----------------------|
| AES Engine | 3 | AES-CMAC, AES-GMAC, AES-GCM, GHASH | MACsec (GCM), IPsec (GCM), SecOC (CMAC) |
| Chacha20 | 1 | Stream cipher | DTLS/TLS 1.3 for V2X |
| SipHash | 1 | Message authentication | SecOC PDU authentication |
| Poly1305 | 1 | MAC algorithm | DTLS/TLS 1.3 AEAD |
| SHA Engine | 1 (multi-mode) | SHA-1/2/3, HMAC, SHAKE | Certificate validation, key derivation |

---

## 3. Key Management

### 3.1 8KB Internal RAM for Secret Keys

The CSS contains **8KB of flexible internal RAM** for secure key storage:

> **"Flexible internal RAM (8KB) to store secret keys (128, 192, 256 bits) with attributes and IVs"** [^21^]

Key RAM features:
- **No interface to read CSS RAM** - keys cannot be read back by software [^21^]
- Supports **128-bit, 192-bit, and 256-bit key sizes**
- **Flexible partitioning** between key and IV areas per channel
- **Possibility to share keys among channels**
- Each channel is mapped to a specific RAM region

### 3.2 Key Storage Layout

The CSS RAM is organized per channel with configurable base addresses and sizes:

```
CSS RAM Layout (per channel):
+------------------+------------------+
|   Key Storage    |    IV Storage    |
|  (configurable   |  (configurable   |
|   size/addr)     |   size/addr)     |
+------------------+------------------+
| Key0-h, Key0-l   | IV0, IV1         |
| Key1-h, Key1-l   | IV2, IV3         |
| Key2...Key13     | IV4, IV5         |
+------------------+------------------+
```

Each channel's key/IV areas can be configured with:
- **Base address** - Starting location in CSS RAM
- **Size** - Number of entries allocated [^21^]

### 3.3 Key Attributes and Access Control

Keys stored in CSS RAM have configurable **attributes** that control:
- **Write protection** - Certain keys can be made permanently write-protected
- **Read protection** - No read interface exists for CSS RAM
- **Channel allocation** - Keys are assigned to specific channels
- **Sharing permissions** - Keys can be shared across multiple channels

### 3.4 Key Locking on Security Events

The CSS implements a security event response system:

> **"Reaction for keys locking on event"** - configurable per channel by CSRM [^21^]

When a security event occurs (e.g., failed authentication threshold exceeded, debug intrusion detected):
- Keys can be **automatically locked**
- Access to specific channels can be **revoked**
- An **alarm is generated** to the SMU (Safety and Security alarm Management Unit)

### 3.5 SMU Alarm Integration

> **"Threshold of failed authentication generating alarm (per channel)"** [^21^]

Each channel has an independently configurable **failed authentication threshold**:
- Counts MAC verification failures per channel
- Triggers SMU alarm when threshold is exceeded
- Supports different reaction policies per channel

---

## 4. ASIL-D Safety Features

### 4.1 Safe MAC Comparator

The CSS includes an **ASIL-D certified Safe MAC Comparator** for secure message authentication verification:

> **"ASIL-D Comparator for MAC verification, MAC length from 1 to 512 bits"** [^21^]

Key safety features:
- **MAC verification from 1 to 512 bits** - supports arbitrary MAC lengths
- **Constant-time comparison** - timing is independent of comparison result
- **ASIL-D safety rating** - highest automotive safety integrity level

### 4.2 MAC Verification Operation

The MAC comparator performs comparison between:
1. **Reference MAC value** - written by user to `CHx_MAC_VALUEi` SFR
2. **Computed MAC value** - either calculated by CSS hardware or by CPUcs software [^21^]

> **"The safe MAC comparator performs a comparison of two message authentication codes"** [^21^]

### 4.3 Constant-Time Comparison

The CSS implements **constant-time comparison** to prevent timing side-channel attacks:

> **"The time required for comparison is independent of the comparison result"** [^21^]

> **"In case of a failed comparison the result is not provided earlier than in case the comparison passed"** [^21^]

This is a critical security feature for automotive applications where side-channel resistance is mandatory.

### 4.4 Hardware vs. Software MAC Calculation

Two options are supported for MAC value calculation:

| Option | Method | Use Case |
|--------|--------|----------|
| Hardware MAC | CSS calculates MAC internally | High throughput, low latency |
| Software MAC | CPUcs calculates MAC | Flexibility, complex algorithms |

> **"To perform a safe MAC compare two options are supported: Hardware MAC calculation through CSS, Software MAC calculation through CPUcs"** [^21^]

### 4.5 Safety Architecture Summary

```
+-----------------------+
|   CSS MAC Comparator  |
|     (ASIL-D Rated)    |
+-----------------------+
| - Constant-time comp  |
| - 1-512 bit MAC len   |
| - HW/SW MAC calc      |
| - Per-channel config  |
| - SMU alarm on fail   |
+-----------------------+
```

---

## 5. Performance Figures

### 5.1 AES-CMAC and AES-GMAC Throughput

Performance at **400 MHz** system clock [^21^]:

| Algorithm | MB/20ms | ms/12MB | ms/24MB | **MB/s** |
|-----------|---------|---------|---------|----------|
| **AES-CMAC-128** | 11.1 MB | 21.6 ms | 43.2 ms | **555 MB/s** |
| **AES-CMAC-256** | 8.14 MB | 29.5 ms | 59 ms | **407 MB/s** |
| **AES-GMAC-128** | 15.3 MB | 15.7 ms | 31.4 ms | **763 MB/s** |
| **AES-GMAC-256** | 15.3 MB | 15.7 ms | 31.4 ms | **763 MB/s** |

> **"Figures at 400 MHz for CMAC and GMAC"** [^21^]

> **"AES-GCM, Authentication only"** [^21^]

### 5.2 Ethernet Frame Processing Latency

Latency for MACsec-style Ethernet frame processing:

| Frame Size | 128-bit Key | 256-bit Key |
|------------|-------------|-------------|
| **64-byte frame** | 0.135 us | 0.155 us |
| **1024-byte frame** | 1.335 us | 1.355 us |

### 5.3 Hash and Authentication Throughput Summary

| Algorithm | Throughput @ 400MHz |
|-----------|---------------------|
| SHA-1 | 292 MB/s |
| SHA-256 | 356 MB/s |
| SHA-384/512 | 584 MB/s |
| SHA3-256 | 2016 MB/s |
| SHAKE128 | 2492 MB/s |
| **SipHash24** | **1280 MB/s** |
| **SipHash48** | **640 MB/s** |
| **Chacha20** | **856 MB/s** |
| **Poly1305** | **468 MB/s** |

### 5.4 Channel Allocation and Prioritization

- **21 individual channels** available (20 application + 1 CSRM) [^5^]
- **Channel priority** is configurable by CSRM [^21^]
- Multiple HW accelerators can operate **in parallel** across different channels
- Each channel can be assigned to a **specific cryptographic engine**

### 5.5 Freedom of Interference

The CSS provides **freedom of interference** between channels:

> **"Provide freedom of interference"** [^21^]

> **"CSS: Distributed crypto and hash engines for secure CAN/Ethernet communication"** [^20^]

> **"21 individual channels to be used by application (compared to one channel in TC3x), Providing freedom of interference for domain/zone controllers"** [^5^]

Each channel operates independently with:
- Dedicated key/IV storage areas
- Independent configuration
- Separate interrupt and alarm paths
- Isolated access control per channel

---

## 6. Ethernet Security Use Cases

The CSS specifically targets communication security for automotive networks:

### 6.1 MACsec Frame Processing

> **"Accelerated MACsec support by HW accelerator in CSS and application SW driver"** [^19^]

> **"CSS-Security Accelerator: Supports security algorithms for MACsec"** [^5^]

MACsec (IEEE 802.1AE) is supported through:
- **AES-GCM encryption/decryption** - hardware accelerated via 3x AES engines
- **GMAC authentication** - for MACsec Integrity Check Value (ICV)
- **Multiple channels** - support concurrent MACsec streams on different Ethernet ports
- The TC4x supports up to **2x 5 Gbps Ethernet** and **4x 10/100 Mbps Ethernet** [^20^]

MACsec processing flow:
```
Ethernet Frame -> CSS Channel -> AES-GCM Engine -> Secured MACsec Frame
                    |                ^
                    v                |
               Key RAM (8KB)    IV/Nonce
```

### 6.2 IPsec Encryption/Decryption

> **"CSS-Security Accelerator: Supports security algorithms for IPsec"** [^5^]

IPsec is supported via:
- **AES-GCM** for ESP (Encapsulating Security Payload)
- **AES-GMAC** for authentication-only mode (AH)
- **SHA-x** HMAC for integrity verification
- **ChaCha20-Poly1305** as an alternative to AES-GCM (RFC 7634)

### 6.3 DTLS/TLS Acceleration

> **"CSS-Security Accelerator: Supports security algorithms for D/TLS"** [^5^]

DTLS/TLS acceleration capabilities:
- **AES-GCM** - for AES-based cipher suites (TLS 1.2/1.3)
- **ChaCha20-Poly1305** - for modern TLS 1.3 cipher suites
- **SHA-2/SHA-3** - for handshake message hashing
- **HMAC** - for TLS record layer authentication

The CSS achieves:
- **856 MB/s** for Chacha20 encryption
- **468 MB/s** for Poly1305 authentication
- Combined **ChaCha20-Poly1305 AEAD** at high throughput

### 6.4 SecOC (Secure Onboard Communication) PDU-Level Security

> **"CSS-Security Accelerator: Supports security algorithms for SecOC (PDU level)"** [^5^]

SecOC (from AUTOSAR) for CAN/CAN-FD/Ethernet PDU authentication:
- **AES-CMAC** - for Freshness Value and Authentic PDU verification
- **SipHash** - for lightweight PDU authentication
- **SHA-256** - for key derivation functions
- **Per-channel key allocation** - separate keys per SecOC PDU

### 6.5 Combined Modes (AEAD/AAD)

> **"Combined modes are supported in CSS"** [^5^]

> **"Authenticated Encryption with Associated Data (AEAD); Authentication with Associated Data (AAD). Combined modes are supported in CSS."** [^348^]

The CSS natively supports:
- **AES-GCM (AEAD)** - encryption + authentication in single pass
- **ChaCha20-Poly1305 (AEAD)** - stream cipher + MAC
- **AES-GMAC (AAD)** - authentication only
- **AES-CMAC** - MAC-only mode

### 6.6 In-Vehicle Network Security Use Cases

The security cluster addresses [^5^]:

| Use Case Category | Examples | CSS Role |
|-------------------|----------|----------|
| **E/E COM observation** | Intrusion Detection System (IDS) | Hash/MAC acceleration |
| **E/E COM filtering** | Intrusion Detection Prevention (IDPS) | Real-time MAC verification |
| **Firewall** | HW filters in MAC + SW | Authentication support |
| **COM Message Security** | CAN/FD/Ethernet MACsec | Full crypto acceleration |

---

## 7. System Integration

### 7.1 Cybersecurity Domain Architecture

The CSS is part of the comprehensive **Cybersecurity (CS) Cluster** [^21^]:

```
+-------------------+     +-------------------+
|    CSRM (Root     |     |   CSS (Satellite) |
|     of Trust)     |     |  (20+1 channels)  |
|                   |     |                   |
| - CPUcs (TriCore) |<--->| - 3x AES Engines  |
| - PKC (asymmetric)|Bridge| - Chacha20       |
| - TRNG (entropy)  |     | - SipHash         |
| - Private Flash   |     | - Poly1305        |
| - CSBCU           |     | - SHA-x           |
+-------------------+     | - 8KB Key RAM     |
                          | - MAC Comparator  |
                          +-------------------+
                                   |
                          SRI Bus  |
                                   v
+-------------------+     +-------------------+     +-------------------+
|  TriCore CPUs     |     |  DMA Controller   |     |  SMU (alarms)     |
|  (Application)    |     |  (data transfer)  |     |  (safety/security)|
+-------------------+     +-------------------+     +-------------------+
```

### 7.2 Bus Interfaces

- **SRI Master/Slave** - Primary interface for data and configuration
- **Bridge to CSRM** - Secure management channel
- **CSPB (Cyber-Security Peripheral Bus)** - Internal peripheral bus
- **CSBCU** - Bus control unit for access protection [^21^]

### 7.3 PROT/APU Integration

The CSS and CSRM use the **PROT/APU (Protection/Access Protection Unit)** mechanism to control access to cybersecurity-related resources:

> **"Functional Blocks related to the Cyber Security (CS) Cluster, which includes CSS, can be associated with the CSRM using the PROT/APU mechanism"** [^21^]

Protected resources include:
- **CS-DMA** - DMA channels for crypto data movement
- **CS-IR** - Interrupt router for security events
- **CS-WTU** - Watchdog timer unit
- **CS-VMT** - Volatile memory test
- **CS-SMU** - Safety/security alarm management
- **CS-SMM** - System mode management
- **CS-CLOCK** - Clock control
- **CS-DEBUG** - Debug access control [^21^]

---

## 8. Comparison with TC3x HSM

| Feature | TC3x HSM | TC4x CSS |
|---------|----------|----------|
| **Architecture** | Single security island | Distributed (CSRM + CSS) |
| **Channels** | 1 shared channel | 20+1 independent channels |
| **AES Engines** | 1x AES | 3x AES |
| **Chacha20** | Not available | Hardware accelerated |
| **SipHash** | Not available | Hardware accelerated |
| **Poly1305** | Not available | Hardware accelerated |
| **SHA-3** | Not available | Hardware accelerated |
| **SHAKE** | Not available | Hardware accelerated |
| **Key RAM** | Limited | 8KB flexible |
| **MAC Comparator** | Not ASIL-D | ASIL-D certified |
| **Direct CPU Access** | Via HSM firmware | Direct channel access |
| **Freedom of Interference** | Limited | Full per-channel isolation |
| **Throughput** | ~50-100 MB/s AES | Up to 763 MB/s GMAC |

---

## 9. Summary of Key Features

### CSS Differentiators

1. **20+1 parallel channels** - massive parallelism vs. TC3x single channel
2. **3x AES engines** - concurrent multi-stream AES processing
3. **8KB secure key RAM** - no read-back interface, write-protected keys
4. **ASIL-D MAC comparator** - constant-time comparison, 1-512 bit support
5. **SRI crossbar location** - lowest latency for data transfer
6. **Freedom of interference** - isolated channels for mixed-criticality systems
7. **Multi-algorithm support** - AES, Chacha20, SipHash, Poly1305, SHA-1/2/3
8. **AEAD combined modes** - native AES-GCM, ChaCha20-Poly1305
9. **CSRM-managed security** - root of trust with flexible access policies
10. **Ethernet security ready** - MACsec, IPsec, D/TLS, SecOC acceleration

### CSS for Ethernet Security Processing

The CSS is uniquely positioned for high-speed automotive Ethernet security:
- **2x 5 Gbps Ethernet ports** require hardware MACsec acceleration
- **MACsec at 5 Gbps** needs ~625 MB/s crypto throughput - CSS delivers **763 MB/s**
- **21 parallel channels** enable concurrent security for multiple network segments
- **ASIL-D MAC comparator** ensures safe authentication for safety-critical messages
- **Constant-time comparison** prevents side-channel attacks

---

## 9. References

### Primary Infineon Documentation

| Document | Reference |
|----------|-----------|
| **CSS Training Document V1.0** | Infineon-AURIX_TC4x_Cyber_Security_Satellite_V1.0.pdf [^21^] |
| **CSRM Training Document V1.0** | Infineon-AURIX_TC4x_Cyber_Security_Real-time_Module_V1.0.pdf [^348^] |
| **TC4x Overview Presentation** | infineon-tc4x-overview-productpresentation-en.pdf [^20^] |
| **TC4Dx Datasheet** | Infineon_AURIX_TC4Dx_A_DataSheet_v01_10_EN.pdf [^304^] |

### Infineon Product Pages

| Product | URL |
|---------|-----|
| TC4x Family | https://www.infineon.com/products/microcontroller/32-bit-tricore/aurix-tc4x [^14^] |
| TC4Dx | https://www.infineon.com/products/microcontroller/32-bit-tricore/aurix-tc4x/tc4dx [^182^] |
| TC48x | https://www.infineon.com/products/microcontroller/32-bit-tricore/aurix-tc4x/tc48x [^355^] |
| TC45x | https://www.infineon.com/products/microcontroller/32-bit-tricore/aurix-tc4x/tc45x [^334^] |

### Partner & Ecosystem References

| Partner | Contribution |
|---------|-------------|
| **Vector** | MICROSAR HSM firmware for CSS, direct host CPU crypto driver [^307^] |
| **ETAS/ESCRYPT** | CycurHSM 3.x integrated into CSRM [^373^] |
| **HighTec** | Rust and C/C++ compiler for CSRM, safety solutions [^343^] |

### HotChips Presentation

| Document | Reference |
|----------|-----------|
| **HotChips 33** | "Heterogeneous computing to enable the highest level of safety in automotive systems" [^5^] |

### Training & Documentation Portal

| Resource | URL |
|----------|-----|
| TC4x Training Hub | https://documentation.infineon.com/aurixtc4xx/docs/ytw1727796290101 [^309^] |
| Functional Overview | https://documentation.infineon.com/aurixtc4xx/docs/tbj1539348095168 [^353^] |

---

## A. CSS Quick Reference Card

```
+------------------+------------------------------------------+
| Module           | CSS - Cyber Security Satellite           |
| Location         | SRI Crossbar                             |
| Channels         | 20 + 1 (CSRM exclusive)                  |
| AES Engines      | 3 (CMAC, GMAC, GCM, GHASH)               |
| Chacha20         | Yes (856 MB/s @ 400MHz)                  |
| SipHash          | Yes (2-4, 4-8 variants)                  |
| Poly1305         | Yes (468 MB/s @ 400MHz)                  |
| SHA-x            | SHA-1/2/3, HMAC, SHAKE128/256            |
| Key RAM          | 8KB (128/192/256-bit keys + IVs)         |
| MAC Comparator   | ASIL-D, 1-512 bit, constant-time         |
| Security Modes   | AEAD, AAD, Combined modes                |
| Ethernet Security| MACsec, IPsec, D/TLS, SecOC              |
| Max GMAC         | 763 MB/s @ 400MHz                        |
| Root of Trust    | CSRM (configures CSS after reset)        |
+------------------+------------------------------------------+
```

---

*Document compiled from Infineon official training materials, datasheets, product presentations, and technical documentation. Performance figures are preliminary from simulation. All trademarks belong to their respective owners.*

*Last updated: Based on TC4x documentation as of September 2024 (V1.0.0)*
