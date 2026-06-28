# P5 Analysis: Clocks, Reset, Low-Power, DFT & Automotive Safety Features

Source: Cadence IP7014A User Guide (clocks/reset, low-power/DFT/ASF) and Safety Manual (r1p12).

---

## 1. Clock Domains and Reset Requirements

### 1.1 Clock Domains

| Clock      | Frequency (typical)          | Usage |
|-----------|------------------------------|-------|
| `pclk`    | 10–500 MHz                   | APB clock for MAC/PCS register blocks. |
| `hclk`    | 10–500 MHz (≤250 w/ ECC)     | AHB DMA clock. |
| `aclk`    | 10–500 MHz (≤400 w/ ECC)     | AXI DMA clock. |
| `tx_clk`  | 1.25/2.5/12.5/25/125 MHz     | MAC transmit path; MII/GMII/RMII/SGMII rates. |
| `rx_clk`  | 1.25/2.5/12.5/25/62.5/125 MHz| MAC receive path; from PHY or PCS. |
| `n_tx_clk`| Inverted `tx_clk`            | RGMII + loopback retiming. |
| `n_rx_clk`| Inverted `rx_clk`            | RGMII receive. |
| `tsu_clk` | 5–400 MHz (> 1/8 of tx/rx)   | Timestamp unit alternate clock. |
| `gtx_clk` | 125 MHz                      | PCS transmit clock (SGMII/SerDes). |
| `gtx20_clk`| 62.5 MHz                    | PCS 20-bit PHY transmit interface. |
| `pcs_rx_clk`| 62.5 MHz                   | PCS receive channel (non-legacy). |
| `pcs_rx10_clk`| 125 MHz                  | PCS 10-bit PHY receive interface. |
| `rbc0/rbc1`| 62.5 MHz, 180° out-of-phase| PCS receive (legacy TBI mode). |
| `ref_clk` | 50 MHz                       | RMII reference; tx/rx derived internally. |

### 1.2 Reset Requirements

- **Active-low** reset required **per clock domain**.
- Reset may be asserted asynchronously; **de-assertion must be synchronous** to the clock.
- Most clocks are asynchronous; cross-clock transfers use 2+ flip-flop synchronizers + handshaking.
- Special cases:
  - TBI mode: `rbc1`/`pcs_rx_clk` and `rx_clk` must be synchronous.
  - Internal loopback: `tx_clk` and `rx_clk` from same reference; `n_tx_clk` from inverted reference. Disable TX/RX before switching to avoid glitches.

---

## 2. RMII / RGMII / PCS Clocking Schemes

| Interface | Clocking Summary |
|-----------|-----------------|
| **RMII**  | `tx_clk` and `rx_clk` are generated from external 50 MHz `ref_clk`, fed out and back in to allow clock-tree control. `gem_clk_ctrl.v` shows muxing with loopback clock. |
| **RGMII** | Source-synchronous; 125 MHz @ 1G, 25 MHz @ 100M, 2.5 MHz @ 10M. v1.3 uses PCB trace delay; v2.0/RGMII-ID uses on-chip 2 ns delay on `rgmii_tx_clk`. `rgmii_tx_clk_sig` is a delayed version of `rgmii_tx_clk` for mux select. |
| **PCS**   | SGMII: TX PCS 125 MHz (`gtx_clk`), wrapper 62.5 MHz (`gtx20_clk`); RX PCS 62.5 MHz (`pcs_rx_clk`), 10-bit interface 125 MHz (`pcs_rx10_clk`). 10/100 SGMII divides clocks by 10/100. TBI legacy uses `rbc0`/`rbc1` at 62.5 MHz 180° apart. TX and RX clocks require common source/balanced tree. |

---

## 3. Low-Power and DFT Features

### 3.1 Energy-Efficient Ethernet (EEE / LPI)

| Item | Detail |
|------|--------|
| Standard | IEEE 802.3az |
| Control  | Firmware-driven via `tx_lpi_en` bit in network control register. |
| Entry condition | Link up ≥ 1 s and no frame to transmit. |
| LPI signal | `txd = 0x01`, `tx_en = 0`, `tx_er = 1`. |
| 1000BASE-X | PHY goes quiet after sleep; refresh/quiet periods per 802.3az Table 78-2. |
| SGMII | Not part of 802.3az; must **not** go quiet. |
| Wake time | Programmable via `tw_sys_tx_time` register; default counts 8 `tx_clk` periods. |
| Receive path | LPI detected via interrupt; software may disable RX logic (keep PCS/SerDes active). |

### 3.2 DFT Features

- `retry_text` bit in network configuration register accelerates collision back-off, pause counter, and FRER timeout for directed functional testing.
- Each clock domain reset supports scan-based insertion; RMII clock loop-out/loop-back supports scan clock control.

---

## 4. Automotive Safety Features (ASF)

| Feature | Description |
|---------|-------------|
| **Fault logging** | Unified ASF status accessible from address `0x0E00`; logs lockup, parity, ECC, and protocol errors. |
| **CSR protection** | Configuration/control/status registers protected by **parity**; critical registers (network control, TX/RX status, interrupt, MDIO, scheduler) protected by **duplication + comparison**. |
| **SRAM ECC** | SECDED ECC on TX/RX SRAM; single-bit correct, double-bit detect. Adds 7/8/16 bits for 32/64/128-bit datapaths. Non-correctable error address logged. |
| **Datapath parity** | 1-bit-per-byte parity over TX/RX data paths and descriptor write-back data/addresses; end-to-end where possible. |
| **Address path parity** | Starting buffer addresses from descriptors parity-protected; regenerated for incremented accesses. |
| **TSU protection** | Optional TSU module duplication (`gem_protect_tsu`) with continuous output compare; timestamp value parity-protected. |
| **Scheduler protection** | Optional duplication of TX scheduler + EnST/CBS; continuous output compare. |
| **Transaction timeout** | One timeout monitor per AXI channel; timeout value controlled by fault logging module. |
| **Lockup detection** | Programmable prescaler + timers for: DMA TX, MAC TX, MAC RX, DMA RX. Can auto-disable TX/RX datapath on detection. |
| **Protocol fault logging** | RX CRC/short/long/symbol/length/IP/TCP/UDP errors, TX underrun/retry, AHB `hresp`, overflow, etc. maskable. |
| **Interrupt classification** | Dedicated `asf_int_fatal` and `asf_int_nonfatal` pins; routable via `asf_fatal_nonfatal_select` and `asf_int_mask`. |

---

## 5. Safety Manual Summary

### 5.1 Safety Goals (High-Level Failures)

- DMA descriptor address / write-data corruption.
- DMA data buffer address / write-data corruption.
- RX lockup (no data on outgoing AXI).
- APB status read data corruption.
- Interrupt output corruption.
- TX/RX SRAM output corruption.
- Outgoing Ethernet packet corruption.
- Outgoing Ethernet QoS/bandwidth allocation corruption.
- TX lockup (no data on outgoing Ethernet).
- TSU timer corruption.
- MDIO access corruption.

### 5.2 ASIL Assumptions

| Item | Assumption |
|------|------------|
| SEooC | IP developed as Safety Element out of Context per ISO 26262. |
| ASIL target | **ASIL-B Ready** with SGS-TÜV FMEDA when internal + external mechanisms implemented. |
| Base failure rate | IEC TR 62380; ~0.0174 FIT for representative TSMC 28HPM config (N ≈ 1.35M transistors). |
| SPFM / LFM | Without SRAM: 90.7% / 98.1%; **with SRAM ECC: 98.8% / 99.95%**. |
| Clock/power | Input clock and power failures out of scope; integrator responsibility. |
| Safe states | Disabled, held in reset, or powered off. Assumed not to violate system safety goal. |

### 5.3 Internal Safety Mechanisms

1. AMBA host bus response error detection.  
2. Receive overflow detection.  
3. Transmit retry exception detection.  
4. Transmit underrun detection.  
5. TX datapath lockup detection (DMA + MAC).  
6. RX datapath lockup detection (DMA + MAC).  
7. CSR corruption detection (parity + duplication).  
8. Data and address path parity protection.  
9. TSU timer duplication/comparison.  
10. TX scheduler duplication.  
11. SRAM SECDED ECC.  
12. Protocol fault checking with maskable interrupts.

### 5.4 External Safety Mechanisms (Recommended)

1. End-to-end frame data validation (e.g., TCP checksum in SW, disable HW offload).  
2. Periodic transfer / loopback test within FTT.  
3. Software TX/RX watchdogs (lockup detection).  
4. Monitor DMA descriptor write-back address sequence.  
5. Validate DMA descriptor write-back status bits.  
6. Classify and validate status/interrupt sources.  
7. APB register read-back against SW mirror.  
8. Interrupt pin self-test by forcing status register.  
9. Redundant communication paths for fail-operational systems.
