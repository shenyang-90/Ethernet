# Dimension 12: Infineon AURIX TC4x Ethernet Software Ecosystem & Driver Development

## Table of Contents
1. [MCAL Drivers](#1-mcal-drivers)
2. [AUTOSAR Stack](#2-autosar-stack)
3. [iLLD (Low Level Driver)](#3-illd-low-level-driver)
4. [Initialization Sequence](#4-initialization-sequence)
5. [Configuration Tools](#5-configuration-tools)
6. [Debugging Tools](#6-debugging-tools)
7. [Code Examples](#7-code-examples)
8. [Errata and Workarounds](#8-errata-and-workarounds)
9. [References](#9-references)

---

## 1. MCAL Drivers

### 1.1 Overview

The AURIX TC4x MCAL (Microcontroller Driver Layer) is provided by Infineon as the MC-ISAR (Microcontroller Independent Software Abstraction Layer) driver package. The TC4x MCAL includes **35 drivers**, with **17 holding ASIL-D safety claims**, based on **AUTOSAR R20-11** (memory drivers aligned to R21-11) [^313^].

**Key Features of TC4x MCAL:**
- ISO 26262:2018 ASIL-D compliant
- ISO 21434 cybersecurity standard compliant
- ASPICE v3.1 Level 3
- MISRA C:2012 + CERT C:2016 coding standards
- Virtualization & Multicore support
- Allocation of drivers to different safety partitions
- Configuration tool: EB tresos v29.2.1 [^313^]

**TC4x MCAL Package Structure:**

| Category | Drivers | Safety Claim |
|----------|---------|--------------|
| Basic | MCU, Port, DIO, SPI, ICU, ADC, WDG, GTM, etc. | ASIL B |
| Comm Enhanced | FlexRay, **GETH**, **LETH**, CAN, LIN | ASIL B |
| Complex MCD | DMA, SMU, DS-ADC, I2C, UART | ASIL D |
| Secured Memory | CSRM MEMACC, CSRM FEE | ASIL B |
| Connectivity | **DRE**, PCIe | ASIL B/D |

[^313^]

### 1.2 Ethernet (Eth) MCAL Driver

#### 1.2.1 GETH MCAL Module

The **GETH (Gigabit Ethernet)** MCAL driver is classified under "Comm enhanced ASIL B" drivers. It provides:

- Support for 10M, 100M, 1G, 2.5G, 5G speed in full-duplex mode
- Support for half-duplex mode in 10M and 100M speed
- IEEE 802.1 AVB and TSN specification hardware support
- Multichannel DMA engine (8 DMA channels in TC4x, up from 4 in TC3x)
- Bridge function for Ethernet frame forwarding between two ports [^77^] [^313^]

**MCAL API Functions (Standard AUTOSAR Eth Interface):**

| API Function | Description |
|-------------|-------------|
| `Eth_Init()` | Initialize Ethernet driver with configuration |
| `Eth_ControllerInit()` | Initialize specific Ethernet controller |
| `Eth_SetControllerMode()` | Enable/disable controller |
| `Eth_GetControllerMode()` | Get current controller mode |
| `Eth_Transmit()` | Transmit an Ethernet frame |
| `Eth_Receive()` | Receive an Ethernet frame |
| `Eth_TxConfirmation()` | Confirm transmission status |
| `Eth_GetPhysAddr()` | Get physical (MAC) address |
| `Eth_SetPhysAddr()` | Set physical (MAC) address |
| `Eth_GetVersionInfo()` | Get driver version info |
| `Eth_UpdatePhysAddrFilter()` | Update physical address filter |
| `Eth_GetCurrentTime()` | Get current time (for time sync) |
| `Eth_EnableEgressTimeStamp()` | Enable egress timestamp |
| `Eth_GetEgressTimeStamp()` | Get egress timestamp |
| `Eth_GetIngressTimeStamp()` | Get ingress timestamp |

#### 1.2.3 LETH MCAL Module

The **LETH (Lite Ethernet)** module provides up to **4x 10/100 Mbit Ethernet** ports supporting the **10Base-T1S** standard. It is classified alongside GETH under "Comm enhanced ASIL B" drivers [^313^].

**LETH Key Features:**
- 10/100 Mbit Ethernet operation
- 10BASE-T1S support (open Alliance standard for automotive)
- Bridge functionality for forwarding between ports and host
- Multichannel DMA capability
- AVB/TSN support (IEEE 802.1AS, 802.1Qav, 802.1Qbv) [^77^]

**LETH Bridge Configuration:**
- PORTj_RXC_MAP and PORTj_TXQ_MAP registers map receive/transmit paths
- PORTj_CTRL_REG enables required RXCs and transmit queues
- Must be programmed **after** PORTj_RXC_MAP and PORTj_TXQ_MAP for proper operation [^41^]

### 1.3 DRE (Data Routing Engine) MCAL Driver

The **DRE** is classified as a "Connectivity ASIL B" driver and is a hardware accelerator for routing CAN frames to/from Ethernet and between CAN modules [^313^] [^216^].

**DRE Key Capabilities:**
- Routing of CAN frames to/from Ethernet IEEE 1722 ACF frames
- Routing of CAN frames between different MCMCAN modules
- Routing of CAN frames to configurable memory address locations
- Aligned to AVTP Control frame format (IEEE 1722-2016)
- Supports NTSCF (Non-Time-Synchronous Control Format) header
- Supports ACF_CAN_BRIEF message type [^216^]

**Ethernet Transmit Trigger Modes:**
1. Frame count transmit mode
2. Buffer fill level-based transmit mode
3. Time-Triggered transmit mode
4. Software-triggered transmit mode [^216^]

**DRE Architecture Components:**
- Central message storage RAM
- Routing Control Unit
- ACF CAN-Ethernet Format Engine
- CAN Transmit Routing Engine with routing table
- Ethernet Descriptor Handler
- Forwarding Engine with forwarding table [^399^]

```c
// Example: CAN to Ethernet routing via DRE
// Routing table determines destination Ethernet interface
// Forwarding engine handles Ethernet frame forwarding
```

**DRE Configuration for GETH-to-LETH Forwarding:**
- Frame loss can occur at ingress MAC when forwarding sustained burst traffic to LETH egress
- Recommendation: Configure ingress/egress DMA for maximum burst, increase RXQ FIFO, operate at max clock frequency [^41^]

### 1.4 CSS (Cyber Security Satellite) Driver Integration

The **CSS** provides hardware acceleration for MACsec and other cryptographic operations. It works with the **CSRM (Cyber Security Real-time Module)** for secure CAN/Ethernet communication [^20^] [^334^].

**CSS Key Features:**
- Up to 20+1 channels for independent symmetric cryptography and Hash tasks
- 3x AES, Chacha20, SipHash(2-4,4-8), Poly1305, SHA HW accelerators
- 8KB flexible internal RAM for secret key storage (128/192/256 bits)
- ASIL-D safe MAC comparator
- MAC length from 1 to 512 bits [^21^]

**MACsec Support:**
- "Accelerated MACsec support by HW accelerator in CSS and application SW driver" [^20^]
- CSS handles AES-256 CMAC, GMAC, GHASH cipher modes
- CSRM manages CSS channel configuration and key provisioning
- After reset, CSRM has exclusive rights to access and configure CSS [^21^]

**CSS Interface Performance:**

| Algorithm | Performance (MB/20ms) |
|-----------|----------------------|
| CMAC-128 | 11.1 |
| CMAC-256 | 8.14 |
| GMAC-128 | 15.3 |
| GMAC-256 | 15.3 |

[^21^]

---

## 2. AUTOSAR Stack

### 2.1 EthIf (Ethernet Interface)

The **EthIf** module provides a hardware-independent interface to the upper layers. It abstracts the underlying Ethernet controllers (GETH, LETH) and provides uniform access.

**Key Functions:**
- Abstracts hardware-specific Ethernet controller details
- Manages multiple Ethernet controllers
- Provides frame transmission/reception interfaces
- Supports time synchronization interfaces (for gPTP)
- Virtual LAN (VLAN) handling
- Supports hardware timestamping for time-sensitive applications

### 2.2 EthTSyn (Time Synchronization over Ethernet)

**EthTSyn** is the AUTOSAR module responsible for Ethernet time synchronization based on IEEE 802.1AS (gPTP) [^163^] [^170^].

**Key Features:**
- Implements IEEE 802.1AS (gPTP) protocol
- Provides nanosecond-level time synchronization precision
- Supports multiple time domains
- Master/Slave clock role switching
- Periodic and Immediate time synchronization modes
- Peer-to-peer (P2P) path delay measurement [^163^] [^164^]

**Architecture Position:**
- Located in the **System Services Layer** of AUTOSAR
- Depends on **EthIf** (lower layer) and **StbM** (Synchronized Time-Base Manager, upper layer) [^163^]

**Time Synchronization Process:**
1. Master port sends SYNC messages at configurable period
2. Slave records local time when SYNC is received
3. Master sends FOLLOW_UP with transmitted SYNC timestamp
4. Slave calculates offset and adjusts local clock [^163^]

**Delay Measurement:**
- Uses gPTP peer delay mechanism
- Pdelay_Req/Pdelay_Resp/Pdelay_Resp_Follow_Up exchange
- Delay = (t4 - t1 - (t3 - t2)) / 2 [^167^]

**Key APIs:**
```c
void EthTSyn_Init(const EthTSyn_ConfigType *configPtr);
void EthTSyn_GetVersionInfo(Std_VersionInfoType *versioninfo);
void EthTSyn_SetTransmissionMode(uint8 ctrlIdx, EthTSyn_TransmissionModeType mode);
```

[^163^] [^170^]

### 2.3 SoAd (Socket Adapter)

The **SoAd** module provides socket-based communication services over Ethernet. It is configured via tools like EB tresos Studio or Vector DaVinci [^526^].

**Key Features:**
- TCP/UDP socket management
- IP address and port configuration
- Connection handling (establishment, maintenance, teardown)
- PDU routing between PDUR and TCP/IP
- Supports both client and server socket connections

**Configuration Example:**
```xml
<SoAd>
    <General>
        <Version>4.3.0</Version>
    </General>
    <Sockets>
        <Socket>
            <ID>1</ID>
            <Protocol>TCP</Protocol>
            <IPAddress>192.168.1.100</IPAddress>
            <Port>12345</Port>
        </Socket>
    </Sockets>
</SoAd>
```

[^526^]

### 2.4 TcpIp Module

The **TcpIp** module implements the TCP/IP protocol stack. It is located between SoAd and EthIf in the AUTOSAR architecture [^535^].

**Responsibilities:**
- IP layer: Addressing, fragmentation, routing
- TCP layer: Connection-oriented reliable transmission
- UDP layer: Connectionless transmission
- ARP/ICMP protocol support
- DHCP client support
- Integration with EthIf for L2 communication

### 2.5 IEEE1722Tp Module

The **IEEE1722Tp** module provides support for IEEE 1722 AVTP (Audio Video Transport Protocol) streams over Ethernet [^214^].

**Supported AVTP Stream Subtypes:**

| Subtype | Description |
|---------|-------------|
| AAF | AVTP Audio Format |
| RVF | Raw Video Format |
| 61883_IIDC | IEC 61883/IIDC format |
| CRF | Clock Reference Format (media clock) |
| TSCF | Time Sensitive Control Format |
| NTSCF | Non-Time Sensitive Control Format |

**Use Cases:**
- Audio and video streaming
- Distribution of media clock rate
- Encapsulation of bus frames (CAN, LIN) via ACF (AVTP Control Format) streams
- Tunneling CAN frames over Ethernet [^214^] [^38^]

**Key Dependencies:**
- **LSduR**: For L-SDU interchange
- **StbM**: For accessing synchronized global time (AVTP presentation time)
- **EthIf**: For direct hardware clock time access via `EthIf_GetCurrentTimeTuple` [^214^]

**AVTP Presentation Time Calculation:**
```
AVTP_Presentation_Time = Current_Synchronized_Time + Max_Transit_Time
```

**Limitations (R23-11/R24-11):**
- Streams interact only with CDDs (Complex Device Drivers), not with standardized BSW modules like COM or LdCom
- RTE is not supported for IEEE1722Tp streams
- Lower layers (CanIf, LinIf) not fully prepared for encapsulated bus frames [^214^]

### 2.6 CANXL/Ethernet Gateway Modules

The **DRE** serves as the primary hardware accelerator for CAN-to-Ethernet gateway functionality. In AUTOSAR context:

- **CRE (CAN Routing Engine)**: Extension to MCMCAN module for CAN-to-CAN routing
- **DRE**: Hardware accelerator for CAN-to-Ethernet and Ethernet-to-CAN routing
- **IEEE1722Tp**: Handles AVTP stream encapsulation/decapsulation for CAN frames over Ethernet

**Typical Gateway Flow:**
```
CAN Frame -> MCMCAN -> CRE -> DRE -> ACF_CAN Format -> IEEE1722Tp -> EthIf -> GETH/LETH
```

---

## 3. iLLD (Low Level Driver)

### 3.1 Overview

The **iLLD (Infineon Low Level Driver)** provides a library of driver functions for AURIX TC4x. It is an open-source software package supporting multiple compilers with hardware abstraction [^518^] [^520^].

**iLLD Release TC4x:**
- Current version: **V2.5.0** (as of latest release)
- Available on GitHub: `Infineon/illd_release_tc4x` [^520^]
- Folder structure: `doc`, `examples`, `src`
- Build system: BaseFramework projects linked to libraries

**iLLD Abstraction Levels:**
1. **Special Function Register Level**: Register access by name
2. **Driver Level**: Encapsulated register configuration functions
3. **Function Level**: Initialize, configure, start/stop any peripheral [^518^]

### 3.2 IfxGeth_Eth Driver API

#### 3.2.1 Data Structures

```c
// Runtime global control block
IfxGeth_Eth geth0;

// PHY control block (external PHY)
phy_t phy_0;

// GETH module configuration structure
IfxGeth_Eth_Config config;
```

[^44^]

#### 3.2.2 Key API Functions

| Function | Description |
|----------|-------------|
| `IfxGeth_enableModule()` | Enable GETH module clock (via CLC register) |
| `IfxGeth_Eth_initModuleConfig()` | Initialize default GETH module configuration |
| `IfxGeth_Eth_initModule()` | Initialize GETH module (hardware init) |
| `IfxGeth_Eth_configureDMA()` | Configure DMA (reset, descriptors, interrupts) |
| `IfxGeth_Eth_configureMacCore()` | Configure XGMAC_CORE (MAC address, filters) |
| `IfxGeth_Eth_configureMTL()` | Configure MTL layer |
| `IfxGeth_startRxDma()` | Start RX DMA channel |
| `IfxGeth_startTxDma()` | Start TX DMA channel |
| `IfxGeth_Eth_getTransmitBuffer()` | Get TX buffer address from descriptor |
| `IfxGeth_Eth_sendTransmitBuffer()` | Send packet via TX DMA |
| `IfxGeth_Eth_isRxDataAvailable()` | Check if RX data is available |
| `IfxGeth_Eth_getReceivedBuffer()` | Get received buffer pointer |
| `IfxGeth_Eth_freeReceivedBuffer()` | Free RX buffer for next reception |

[^35^] [^536^]

#### 3.2.3 DMA Configuration Functions

```c
// DMA Software Reset
void IfxGeth_Eth_configureDMA(IfxGeth_Eth *eth);
// - Resets DMA via DMA_MODE.SWR bit
// - Initializes descriptor ring buffers
// - Configures DMA channel interrupts

// Set descriptor addresses
void IfxEth_setReceiveDescriptorAddress(Ifx_ETH *eth, void *address);
void IfxEth_setTransmitDescriptorAddress(Ifx_ETH *eth, void *address);
```

[^536^]

#### 3.2.4 MAC Configuration Functions

```c
// Set MAC address
void IfxEth_setMacAddress(IfxGeth_Eth *eth, uint8 *macAddress);

// Set PHY interface mode
void IfxEth_setPhyInterfaceMode(IfxGeth_Eth *eth, IfxGeth_PhyInterfaceMode mode);
// Supported modes: MII, RMII, RGMII, SGMII, USXGMII

// Set loopback mode
void IfxEth_setLoopbackMode(IfxGeth_Eth *eth, boolean loopbackMode);
```

[^536^]

### 3.3 Module Initialization Sequence

The iLLD initialization sequence for GETH follows this pattern:

```c
// 1. Enable module clock
IfxGeth_enableModule(&geth0);

// 2. Configure input pins (HSPHY + Port) BEFORE DMA reset
IfxHsphy_Geth_setupRmiiInputPins(&hsphyConfig);

// 3. Initialize default configuration
IfxGeth_Eth_initModuleConfig(&config, &geth0);
// Modify specific settings:
// config.macAddress = ...
// config.speed = ...
// config.buffer addresses = ...

// 4. Initialize module (configures DMA, MAC, MTL)
IfxGeth_Eth_initModule(&geth0, &config);
// Internally calls:
//   - IfxGeth_Eth_configureDMA()    (reset + descriptor init)
//   - IfxGeth_Eth_configureMacCore() (MAC layer config)
//   - IfxGeth_Eth_configureMTL()     (MTL layer config)

// 5. Start DMA channels
IfxGeth_startRxDma(&geth0, IfxGeth_RxDmaChannel_0);
IfxGeth_startTxDma(&geth0, IfxGeth_TxDmaChannel_0);

// 6. Configure output pins
IfxHsphy_Geth_setupRmiiOutputPins(&hsphyConfig);
```

[^28^] [^35^] [^44^]

### 3.4 Descriptor Management

#### 3.4.1 Descriptor Format

Each descriptor is **16 bytes** (4 words). Descriptors are organized in ring buffers in system memory [^28^].

**Transmit Descriptor (TDES):**

| Field | Bits | Description |
|-------|------|-------------|
| TDES0.BUF1AP | 31:0 | Buffer 1 address pointer |
| TDES1.BUF2AP | 31:0 | Buffer 2 address (usually not used) |
| TDES2.IOC | 31 | Interrupt on Completion |
| TDES2.TTSE | 30 | Transmit Timestamp Enable |
| TDES2.B1L | 13:0 | Buffer 1 length |
| TDES3.OWN | 31 | DMA ownership bit |
| TDES3.CTXT | 30 | Context descriptor indicator (0=normal) |
| TDES3.FD | 29 | First Descriptor |
| TDES3.LD | 28 | Last Descriptor |
| TDES3.CPC | 27:26 | CRC Pad Control |
| TDES3.SAIC | 25:23 | Source Address Insertion Control |
| TDES3.CIC | 17:16 | Checksum Insertion Control |

[^28^]

**Receive Descriptor (RDES):**

| Field | Bits | Description |
|-------|------|-------------|
| RDES0 | 31:0 | Buffer 1 address (read) / Packet info (write-back) |
| RDES2 | 31:0 | Buffer 2 address or Header address |
| RDES3.OWN | 31 | DMA ownership bit |
| RDES3.CTXT | 30 | Context descriptor indicator |
| RDES3.FD | 29 | First Descriptor |
| RDES3.LD | 28 | Last Descriptor |

[^28^]

---

## 4. Initialization Sequence

### 4.1 Detailed Initialization Steps

The TC4x Ethernet initialization must follow a strict sequence to ensure proper operation. The HSPHY must provide a reference clock before DMA reset can succeed [^492^].

**Step 1: Module Clock Enable**
```c
// Enable GETH module clock via CLC register
IfxGeth_enableModule(&geth0);
// This clears CLC.DISR bit, enabling the module clock
```

**Step 2: HSPHY Input Pin Configuration**
```c
// Configure HSPHY input pins BEFORE DMA reset
// DMA reset requires external PHY reference clock
IfxHsphy_Geth_setupRmiiInputPins(&hsphyConfig);
// Or for RGMII:
// IfxHsphy_Geth_setupRgmiiInputPins(&hsphyConfig);
// Or for SGMII:
// IfxHsphy_Geth_setupSgmiiInputPins(&hsphyConfig);
```
**Critical**: Input pins must be configured before DMA reset because the DMA reset requires the external PHY clock to be running [^44^].

**Step 3: DMA Reset and Descriptor Initialization**
```c
// Inside IfxGeth_Eth_initModule():
// 1. Kernel reset of GETH module (KRST0/1 registers)
// 2. Wait 35 fSPB cycles after kernel reset
// 3. Software reset via DMA_MODE.SWR bit
// 4. Wait 4 fSPB cycles, check DMA_MODE.SWR=0
// 5. Initialize descriptor ring buffers
// 6. Configure DMA channel settings (PBL, burst length)
// 7. Configure DMA interrupts
```

**TC3x Errata - Initialization Workaround** [^157^]:
```
1. Finish active transfers, ensure TX/RX stopped
2. Check RPSx/TPSx in DMA_DEBUG_STATUS0/1
3. Check MTL debug registers = 0 (may need 70 fSPB cycles wait)
4. Disable GETH interrupts globally
5. Ensure GETH_GPCTL.EPR=000B
6. Ensure GETH_SKEWCTL=0x0
7. Apply kernel reset (KRST0/1)
8. Wait 35 fSPB cycles
9. Set GETH_GPCTL.EPR=001B (RGMII)
10. Configure SKEWCTL if required
11. Software reset (DMA_MODE.SWR)
12. Wait 4 fSPB cycles, check SWR=0
13. Configure remaining GMAC registers
```

[^157^]

**Step 4: MAC Core Configuration**
```c
// Inside IfxGeth_Eth_configureMacCore():
// - Set MAC address (MAC_Address0_High/Low)
// - Configure PHY interface mode (RGMII/RMII/SGMII)
// - Configure frame filtering
// - Configure flow control
// - Configure checksum offload
```

**Step 5: MTL Configuration**
```c
// Inside IfxGeth_Eth_configureMTL():
// - Configure TX queue operation mode (threshold/store-forward)
// - Configure RX queue operation mode
// - Allocate queue sizes (TX: 32KB total, RX: 32KB total in TC4x)
// - Configure queue-to-DMA channel mapping
```

**MTL FIFO Configuration:**
- TC4x TX FIFO: **32KB** (up from 4KB in TC3x)
- TC4x RX FIFO: **32KB** (up from 8KB in TC3x)
- Allocation in blocks of 256 bytes
- Minimum 1 block (256 bytes) per queue [^128^]

**Step 6: DMA Start (RX then TX)**
```c
// Start RX DMA first
IfxGeth_startRxDma(&geth0, IfxGeth_RxDmaChannel_0);

// Then start TX DMA
IfxGeth_startTxDma(&geth0, IfxGeth_TxDmaChannel_0);
```

**Step 7: Output Pin Configuration**
```c
// Configure HSPHY output pins for data transmission
IfxHsphy_Geth_setupRmiiOutputPins(&hsphyConfig);
// Or for RGMII:
// IfxHsphy_Geth_setupRgmiiOutputPins(&hsphyConfig);
```

[^28^] [^35^] [^44^] [^157^]

### 4.2 Clock Configuration

The GETH module clock (fGETH) is derived from fSOURCE0:
```
fGETH = fSOURCE0 / SYSCCUCON1.GETHDIV
```

Example for TC4D9:
- fSOURCE = 500 MHz
- GETHDIV = 2
- fGETH = 250 MHz [^28^]

The register control bus clock uses the SPB clock.

---

## 5. Configuration Tools

### 5.1 EB tresos Studio

**EB tresos Studio** is the primary configuration tool for TC4x MCAL drivers [^313^] [^517^].

**Version Requirements:**
- MCAL configuration tool 2.0.0-A1: **EB tresos v29.2.1** [^313^]

**Features:**
- GUI-based MCAL module configuration
- Automatic code generation from configuration
- Error checking and validation
- Support for all 35 TC4x MCAL drivers including GETH, LETH, DRE

**MCAL Starterkit Bundle includes:**
- EB tresos tool for configuration and integration
- HighTec LLVM safety-certified compiler
- HighTec IDE with integrated debugger
- Ready-to-Go Example Projects
- MCAL GUI helper tool for project creation [^313^] [^517^]

### 5.2 Infineon ConfigWizard

The **ConfigWizard** is part of the AURIX Development Studio (ADS) environment for iLLD-based projects. It provides:
- Visual configuration of iLLD modules
- Automatic code generation for initialization sequences
- Integration with iLLD examples

### 5.3 Vector DaVinci Configurator

**Vector DaVinci Configurator** supports TC4x AUTOSAR stack configuration:
- Full BSW configuration including Ethernet modules (EthIf, EthTSyn, SoAd, TcpIp)
- MICROSAR Classic stack integration with TC4x MCAL [^537^]
- HSM firmware integration for CSS/CSRM

**Vector MICROSAR on TC4x:**
- Supports CSRM and CSS hardware
- HSM firmware enables hardware-accelerated crypto operations via CSS
- Direct addressing of CSS by host CPU crypto driver
- Key management between CSS and CSRM executed via firmware [^537^]

---

## 6. Debugging Tools

### 6.1 Lauterbach TRACE32

**TRACE32** supports AURIX TC4x with:
- Multi-core debugging (up to 6 TriCore v1.8 cores)
- GTM/eGTM debugging
- MCDS (Multi-Core Debug Solution) on-chip trace
- Virtualization mode debugging
- PPU debugging support [^193^]

**Ethernet-specific debugging features:**
- Memory view for descriptor ring inspection
- Register view for DMA/MTL/MAC status
- Trace analysis for Ethernet packet flow

### 6.2 iSYSTEM winIDEA

**winIDEA** is bundled with AURIX Development Studio (ADS) and SmartCode compiler [^115^].

**Features:**
- TC4x device programming in Foreground Boot mode
- Handshake script for CPU0/CPUcs boot coordination
- Multi-core debugging
- On-chip trace support
- State machine support for dual MCDS [^547^]

**winIDEA Foreground Boot Configuration:**
1. Open CPU Options | Reset | Before Programming
2. Add custom script "Fake finished foreground boot"
3. Enable Reset CPU after Download
4. Perform Download [^547^]

### 6.3 PLS UDE

**UDE (Universal Debug Engine)** from PLS provides comprehensive TC4x debugging support [^354^] [^356^].

**Key Features:**
- Multicore debugging with synchronized run-control
- FLASH programming
- MCDS on-chip trace support
- Initial GTM debugging (added 2023.0.2)
- Simplified start configuration with Core 0/Core CS configurations
- Dual-MCDS cross trigger routing (added 2025.0.3)
- State machine support for dual MCDS [^356^]

**UDE TC4x Support History:**
- 2023.0.4: Initial TC4x trace support
- 2023.0.6: TC4D production device debugging
- 2025.0.3: Dual-MCDS cross trigger routing
- 2025.0.4: TC4x connect with CS in foreground boot mode [^356^]

### 6.4 AURIX Development Studio (ADS)

Infineon's **AURIX Development Studio Limited** provides:
- Import of official Infineon demo examples
- Built-in winIDEA debugger
- miniWiggler JDS debugger hardware support
- iLLD integration [^115^] [^117^]

---

## 7. Code Examples

### 7.1 Basic Packet Transmit

```c
#include "IfxGeth_Eth.h"

IfxGeth_Eth geth0;
IfxGeth_Eth_Config config;

void ethernet_init(void)
{
    // Step 1: Enable module clock
    IfxGeth_enableModule(&geth0);
    
    // Step 2: Configure HSPHY input pins (before DMA reset)
    IfxHsphy_Geth_setupRmiiInputPins(&hsphyConfig);
    
    // Step 3: Initialize configuration
    IfxGeth_Eth_initModuleConfig(&config, &geth0);
    
    // Step 4: Initialize module (DMA + MAC + MTL)
    IfxGeth_Eth_initModule(&geth0, &config);
    
    // Step 5: Start DMA channels (RX first, then TX)
    IfxGeth_startRxDma(&geth0, IfxGeth_RxDmaChannel_0);
    IfxGeth_startTxDma(&geth0, IfxGeth_TxDmaChannel_0);
    
    // Step 6: Configure output pins
    IfxHsphy_Geth_setupRmiiOutputPins(&hsphyConfig);
}

void ethernet_transmit(void)
{
    // Get TX buffer from descriptor ring
    uint8 *pTxBuf = IfxGeth_Eth_getTransmitBuffer(&geth0, IfxGeth_TxDmaChannel_0);
    
    // Destination MAC address
    uint8 DstMacAddress[6] = {0x88, 0x03, 0x19, 0x00, 0x00, 0x88};
    
    // ICMP packet data
    uint8 TestBuffer[86] = { /* ICMP payload */ };
    
    // Build Ethernet frame
    memcpy(&pTxBuf[0], &DstMacAddress[0], 6);          // Destination MAC
    memcpy(&pTxBuf[6], &geth0_p0_mac_address[0], 6);   // Source MAC
    memcpy(&pTxBuf[12], &TestBuffer[0], 16);           // EtherType + Payload
    
    // Send packet (payload_size + header)
    IfxGeth_Eth_sendTransmitBuffer(&geth0, 0, 86 + 12, IfxGeth_TxDmaChannel_0);
}
```

[^44^]

### 7.2 Interrupt Handling

```c
// DMA Channel Interrupt Categories:
// Normal Interrupts (NIS): TI, RI, TBU - successful packet transfer
// Abnormal Interrupts (AIS): Errors

// Interrupt clear: Write 1'b1 to corresponding bit
// Must clear ALL bits in DMA_CH(#i)_Status before exiting ISR

__interrupt(ETH_VECTOR) __vector_table(0)
void Eth_ISR(void)
{
    // Read DMA channel 0 status
    uint32 status = GETH_DMA_CH0_STATUS.U;
    
    // Check for TX interrupt
    if (status & IFX_GETH_DMA_CH_STATUS_TI_MSK)
    {
        // Handle TX completion
        // ...
        GETH_DMA_CH0_STATUS.U = IFX_GETH_DMA_CH_STATUS_TI_MSK; // Clear
    }
    
    // Check for RX interrupt
    if (status & IFX_GETH_DMA_CH_STATUS_RI_MSK)
    {
        // Handle RX completion
        // ...
        GETH_DMA_CH0_STATUS.U = IFX_GETH_DMA_CH_STATUS_RI_MSK; // Clear
    }
    
    // CRITICAL: Clear ALL status bits before exiting
    // Any remaining bits will prevent interrupt re-triggering
}
```

**Important Note from iLLD Bug List**: "You MUST clear ALL bits in the ETH_STATUS register before exiting from the Ethernet interrupt handler. If ANY bits are left set, it will prevent the interrupt from being triggered again." [^519^]

### 7.3 Descriptor Management Best Practices

```c
// Descriptor ring configuration
typedef struct {
    volatile IfxGeth_TxDmaDescriptor *txDesc;
    volatile IfxGeth_RxDmaDescriptor *rxDesc;
    uint8 *txBuffer;
    uint8 *rxBuffer;
    uint32 txCount;
    uint32 rxCount;
    uint32 txIndex;
    uint32 rxIndex;
} Eth_DescriptorRing;

// RX processing with descriptor ownership checking
void eth_processRx(void)
{
    // Scan descriptors from last recorded position
    // to first descriptor owned by DMA
    while (rxRing.rxDesc[rxRing.rxIndex].des3.OWN == 0)
    {
        // Descriptor owned by CPU - process received packet
        uint8 *rxBuf = &rxRing.rxBuffer[rxRing.rxIndex * BUFFER_SIZE];
        uint16 rxLen = rxRing.rxDesc[rxRing.rxIndex].des0.RX_PACKET_LEN;
        
        // Process packet...
        
        // Return descriptor to DMA (set OWN bit)
        rxRing.rxDesc[rxRing.rxIndex].des3.OWN = 1;
        
        // Update tail pointer to restart DMA if suspended
        GETH_DMA_CH0_RXDESC_TAIL_PTR.U = (uint32)&rxRing.rxDesc[rxRing.rxIndex];
        
        rxRing.rxIndex = (rxRing.rxIndex + 1) % rxRing.rxCount;
    }
}
```

[^28^]

### 7.4 Cache Coherency Considerations

**Critical**: The AURIX DMA is **never cache-coherent**. The Ethernet GMAC DMA uses DMA to access descriptors and buffers, but the drivers must account for this [^519^].

**Recommendation:**
```c
// Set CPUx_PMA0 to 0x100 (cache PFLASH segment 8 only)
// rather than default 0x300 (segments 8 + 9)
// This avoids cache coherency issues between CPU cores or with DMA
```

**iLLD Ethernet Driver Known Bugs** [^519^]:
1. RMII mode: Code fails to configure SMI (MDC/MDIO) pins
2. Pin mux tables contain incorrect mux data for some pins
3. `IfxEth_wakeupTransmitter()` and `IfxEth_wakeupReceiver()` broken - do not start if in STOPPED state
4. No cache coherency handling for DMA-accessed descriptors and buffers

---

## 8. Errata and Workarounds

### 8.1 GETH Module Errata

**GETH_TC.H007 - Incomplete Reset Isolation** [^41^]:
Before applying kernel/module/software reset:
1. All TX/RX transactions must be finished
2. MAC transmitter and receiver must be disabled
3. PPS generation must be disabled

**GETH_AI.036 - MAC Incorrectly Starts Packet Transmission** [^41^]:
- TTC field programmed to 0 causes premature pointer passing at 32 bytes instead of 64
- **Workaround**: Program TTC field to 2 (encoding for 96 bytes threshold)

**GETH_AI.037 - Receive DMA Stops When Packet Flush and Suspend Overlap** [^41^]:
- Occurs when RPF=1 and tail pointer updated during SUSPEND
- **Workaround**: Software reset (DMA_MODE.SWR=1) to recover

**GETH_AI.038 - Unintended Closure of Receive Descriptor** [^41^]:
- After DMA reconfigure/restart, first descriptor incorrectly has LD=1
- **Workaround**: Software must ignore first receive descriptor with LD=1 after restart

**GETH_AI.039 - Transmit Packet Not Terminated in MII Speed Modes** [^41^]:
- Underflow at 10/100 Mbps causes data word repeat
- **Workaround**: Operate TXQ in store-and-forward mode

### 8.2 HSPHY Errata

**HSPHY_TC.H008 - Incorrect SGMII Initialization Sequence** [^41^]:
- RX_RST assertion before PCS speed selection can trigger safety alarm
- **Workaround**: Do not assert/de-assert RX_RST_0 bit during SGMII init

### 8.3 LETH Errata

**LETH_AI.H001 - Forwarding and Reception Combination** [^41^]:
- PORTj_CTRL_REG must be programmed **after** PORTj_RXC_MAP and PORTj_TXQ_MAP

**LETH_TC.H001 - Incomplete Reset Isolation** [^41^]:
- Same workaround as GETH: finish transactions, disable TX/RX before reset

### 8.4 DRE Errata

**DRE_TC.H002 - Throughput Drop for GETH-to-LETH Forwarding** [^41^]:
- Frame loss at ingress MAC during sustained burst traffic
- **Workaround**: Max burst transactions, increased RXQ FIFO, max clock frequencies

---

## 9. References

| Reference | Source | Description |
|-----------|--------|-------------|
| [^313^] | Hitex AURIX Knowledge Lab 2024 | TC4x Software Solutions presentation |
| [^28^] | 10100.com Article | TC4x GETH Module Detailed Explanation |
| [^35^] | en.eeworld.com.cn | Infineon Aurix TC4x Ethernet GETH Module Detailed |
| [^44^] | eet-china.com | TC4x GETH Module Detailed (Code Examples) |
| [^77^] | Infineon Documentation | TC4xx Feature List |
| [^128^] | Infineon Community KBA | GETH embedded MTL queue FIFOs handling |
| [^157^] | TC39x Errata Sheet | Ethernet initialization sequence workaround |
| [^163^] | EasyXMen Docs | EthTSyn Module Documentation |
| [^170^] | AUTOSAR Specification | SWS Time Synchronization over Ethernet (R21-11) |
| [^214^] | AUTOSAR Specification | CP SWS IEEE1722 Transport Protocol (R24-11) |
| [^216^] | Infineon Training | DRE Data Routing Engine v1.0 |
| [^313^] | Hitex | AURIX TC4xx Software Solutions |
| [^399^] | Infineon Documentation | DRE Functional Overview |
| [^41^] | Infineon | TC4Dx Errata Sheet |
| [^492^] | Infineon Community | Ethernet clock issues with TC4x HSPHY+Eth |
| [^517^] | HighTec | MCAL and More - TC4x Evaluation Package |
| [^519^] | Infineon Community | iLLD Ethernet driver bug list |
| [^520^] | GitHub | Infineon illd_release_tc4x |
| [^354^] | PLS | UDE for Infineon TriCore AURIX TC4x |
| [^356^] | PLS | UDE Release Notes |
| [^537^] | Vector/EPDT | Automotive MCUs Cybersecurity with HSM Firmware |
| [^21^] | Infineon Training | CSS Cyber Security Satellite |
| [^20^] | Infineon | TC4x Overview Product Presentation |
| [^313^] | Infineon | MCAL Driver List for TC4x |
| [^526^] | CSDN | SoAd (Socket Adaptor) Module Description |
| [^535^] | AUTOSAR | CP SWS TCP/IP Stack (R23-11) |
| [^115^] | eet-china.com | TC4x HSPHY Module Detailed |
| [^117^] | WeChat Article | TC4x HSPHY Module Detailed |
| [^180^] | Infineon Documentation | TC4xx Application Notes (AP32591) |
| [^547^] | Tasking KB | winIDEA TC4x Foreground Boot Mode |

---

*Document compiled from Infineon official documentation, AUTOSAR specifications, community forums, and third-party technical articles. All sources cited with inline references.*
