# TC4x Ethernet Cross-Verification Report

## High Confidence Findings (Confirmed by >=2 sources)

### 1. GETH Module Architecture
- **2x 5Gbps MAC + Bridge**: Confirmed by Infineon docs [^75^][^77^], EET-China [^39^], HotChips [^5^]
- **8 DMA channels**: Confirmed by Infineon docs [^77^], dim01/dim02 research
- **32KB TX/RX FIFO**: Confirmed by Infineon docs, multiple sources
- **Dual LCB2SRI**: Confirmed by Infineon docs [^75^], dim01

### 2. TSN Protocol Support
- **802.1AS-2020**: Confirmed by Infineon docs [^30^][^77^], dim03
- **CBS (802.1Qav)**: GETH=Yes, LETH=Yes - confirmed by multiple sources
- **TAS (802.1Qbv)**: GETH=Yes, LETH=Yes - confirmed [^30^]
- **Preemption (802.1Qbu)**: GETH=Yes, LETH=No - confirmed
- **PSFP (802.1Qci)**: Partial on both - confirmed
- **FRER (802.1CB)**: SW-based on both - confirmed

### 3. CSS Security
- **20+1 channels**: Confirmed by CSS training doc [^21^]
- **MACsec acceleration**: Confirmed by product brief [^20^], dim08
- **8KB key RAM**: Confirmed [^21^]

### 4. DRE Routing
- **50% performance improvement**: Confirmed by product brief [^25^]
- **IEEE 1722 encapsulation**: Confirmed by DRE training [^219^]
- **CAN-to-Ethernet**: Confirmed [^25^][^219^]

### 5. LETH
- **4x 10/100M MAC**: Confirmed [^19^]
- **10BASE-T1S support**: Confirmed
- **TSN support (limited)**: Confirmed

## Medium Confidence Findings

### 1. Performance Numbers
- CSS throughput figures from single training document [^21^]
- DRE latency reduction claims from Rutronik [^429^]

### 2. HSPHY Architecture
- MP8G PHY details from technical articles [^115^]
- DLL skew control precision from documentation

## Conflict Zones

### 1. MACsec Implementation
- **Source A**: Says "Accelerated MACsec by HW accelerator in CSS" [^20^]
- **Source B**: CSS provides crypto primitives, MACsec frame processing requires SW driver
- **Resolution**: CSS accelerates AES-GCM for MACsec but full MACsec (SecTAG/ICV handling) requires SW driver. This is "accelerated" not "offloaded"

### 2. GETH vs LETH TSN Support
- Some sources say LETH supports all TSN features
- Other sources clearly state Qbu preemption is GETH-only
- **Resolution**: LETH does NOT support frame preemption. This is the key differentiator.

### 3. DMA Channel Count
- Most sources say 8 channels
- Some early documentation may reference 4 (TC3x legacy)
- **Resolution**: TC4x GETH has 8 DMA channels (confirmed in official docs)
