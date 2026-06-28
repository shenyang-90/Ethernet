# A6 Analysis: Safety, DFT, and Low-Power Features in Cadence GEM GXL (IP7014A r1p12)

**Scope:** Read-only review of functional-safety (ASF), DFT, and low-power infrastructure in the Cadence GEM GXL Ethernet MAC IP delivered at `/home/CALTERAH/yshen/sandbox/ethernet/Reference/Cadence/gem_gxl_det0104_r1p12f4/gem_gxl/`.

**Analyst:** Agent A6 (Safety & DFT Expert)  
**Date:** 2026-06-25

---

## 1. Executive Summary

The GEM GXL IP is a configurable automotive Ethernet MAC+DMA+1588+TSN controller (part IP7014A). For safety-critical use it provides an **Advanced Safety Features (ASF)** subsystem that is enabled with the single Verilog define `gem_asf_enable`. ASF adds parity/ECC protection, lockup detection, transaction-timeout monitors, duplicated critical blocks, and a centralized fault-logging/reporting APB register bank. The IP is delivered as a **Safety Element out of Context (SEooC)** and is documented as **ASIL-B Ready** by Cadence/SGS-TÜV for a representative GMII/AXI/3-queue configuration with all ASF options enabled.

DFT infrastructure is Cadence-tool-centric (Genus/Modus/TetraMAX). The RTL has **no embedded scan chains**; scan insertion is performed during synthesis. The delivered flow uses multi-mode SDCs, ATPG clock-constraint extraction, and a template CPF with a single always-on power domain.

Low-power support is minimal at the IP level: the delivered CPF/UPF directories are empty and the example CPF defines only one default power domain. Dynamic power reduction relies on **tool-inserted clock gating** (Genus `lp_insert_clock_gating`) and the IEEE 802.3az Low Power Idle (LPI) MAC feature.

---

## 2. Files Reviewed

| Category | Path / File |
|----------|-------------|
| **ASF fault logging & CSR** | `hdl/hdl_src/cdnsdru_asf_fault_log_rpt_v2.v`  
| **ASF fault-log CSR slice** | `hdl/hdl_src/cdnsdru_asf_fault_log_rpt_csr_v2.v` |
| **ASF parity** | `hdl/hdl_src/cdnsdru_asf_parity_gen_v1.v`, `cdnsdru_asf_parity_check_v1.v` |
| **ASF SRAM protection** | `hdl/hdl_src/cdnsdru_asf_sram_protect_v1.v` |
| **ASF transaction timeout** | `hdl/hdl_src/cdnsdru_asf_trans_timeout_v1.v` |
| **ECC generation/correction** | `hdl/hdl_src/cdnsdru_ecc_parity_gen_80_8_v1.v`, `cdnsdru_ecc_parity_gen_wrap_v1.v`, `cdnsdru_ecc_correct_80_8_v1.v`, `cdnsdru_ecc_correct_wrap_v1.v` |
| **Lockup detection** | `hdl/hdl_src/edma_lockup_detect.v`, `edma_tx_lockup_detect.v`, `edma_rx_lockup_detect.v`, `gem_mac_lockup_detect.v`, `gem_tx_lockup_detect.v`, `gem_rx_lockup_detect.v` |
| **Clock-domain synchronization** | `hdl/hdl_src/gem_pclk_syncs.v`, `gem_pclk_syncs_sram_stats.v` |
| **Top-level integration** | `hdl/hdl_src/gem_gxl.v`, `gem_top.v`, `gem_registers.v` |
| **Configuration defines** | `hdl/hdl_src/edma_defs.v` |
| **DFT constraints** | `hdl_qc/cfg/pbuf_3qs_axi/dft/constraints/clock_constraints_pbuf_3qs_axi.txt` |
| **DFT flow scripts** | `synth/scripts/genus/genus_synth.tcl`, `synth/scripts/genus/dft_setup.tcl`, `synth/scripts/genus/dft_insert_scan.tcl`, `synth/scripts/sdc/template.scan*.sdc`, `synth/scripts/modus/write_vectors_template.txt`, `synth/scripts/tmax/atpg.tcl` |
| **Low-power intent** | `pwr_intent/cpf/` (empty), `pwr_intent/upf/` (empty), `synth/scripts/cpf/project.cpf` |
| **Safety manual** | `doc/cdn_eth_IP701xA_r1p12_safety_manual_v1.1.pdf` (text extracted) |

---

## 3. Safety Mechanisms

### 3.1 ASF Activation & Configuration Defines

`gem_asf_enable` is the master switch. In `hdl/hdl_src/edma_defs.v` it automatically enables:

| Define | Effect |
|--------|--------|
| `gem_asf_enable` | Master ASF switch; enables DAP, CSR, transaction-timeout, and integrity protection |
| `gem_asf_ecc_sram` | Adds SECDED ECC to TX/RX packet-buffer SRAM data paths |
| `gem_asf_prot_tsu` | Duplicates the Timestamp Unit (TSU) and compares outputs |
| `gem_asf_prot_tx_sched` | Duplicates the transmit scheduler and compares outputs |
| `gem_asf_host_par` | Adds parity signals on the AXI/APB host data/address buses |

Sub-defines used internally: `gem_asf_dap_prot`, `gem_asf_csr_prot`, `gem_asf_trans_to_prot`, `gem_asf_integrity_prot`.

### 3.2 Centralized Fault Logging & Reporting (`cdnsdru_asf_fault_log_rpt_v2`)

Implemented in `gem_registers.v` and clocked from `pclk`. It exposes an APB-mapped register bank starting at offset `0xE00`:

| Offset | Register | Purpose |
|--------|----------|---------|
| `0xE00` | `ASF_INT_STATUS` | Masked interrupt status (bits 6:0) |
| `0xE04` | `ASF_INT_RAW_STATUS` | Raw latched fault status |
| `0xE08` | `ASF_INT_MASK` | Per-source mask; reset = `0x7F` (all masked) |
| `0xE0C` | `ASF_INT_TEST` | SW write-1-to-set test bits |
| `0xE10` | `ASF_FATAL_NONFATAL_SELECT` | Classify each source as fatal/non-fatal |
| `0xE20` | `ASF_SRAM_CORR_FAULT_STATUS` | {instance[7:0], address[23:0]} of last correctable SRAM error |
| `0xE24` | `ASF_SRAM_UNCORR_FAULT_STATUS` | {instance[7:0], address[23:0]} of last uncorrectable SRAM error |
| `0xE28` | `ASF_SRAM_FAULT_STATS` | {uncorr_count[15:0], corr_count[15:0]} |
| `0xE30` | `ASF_TRANS_TO_CTRL` | Enable + 16-bit timeout reload value |
| `0xE34` | `ASF_TRANS_TO_FAULT_MASK` | Mask per transaction-timeout source |
| `0xE38` | `ASF_TRANS_TO_FAULT_STATUS` | Latched per-source timeout status |
| `0xE40` | `ASF_PROTOCOL_FAULT_MASK` | Mask per protocol fault source |
| `0xE44` | `ASF_PROTOCOL_FAULT_STATUS` | Latched protocol-fault status |

Interrupt bit mapping (raw status):

| Bit | Source | Typical ASIL-B Use |
|-----|--------|-------------------|
| 0 | SRAM correctable error | Non-fatal diagnostic |
| 1 | SRAM uncorrectable error | **Fatal** → safe state |
| 2 | Data/Address Path parity error | **Fatal** |
| 3 | Configuration/Status Register parity/duplication error | **Fatal** |
| 4 | Transaction timeout (lockup) | **Fatal** |
| 5 | Protocol fault | Fatal or non-fatal per source |
| 6 | Integrity fault (TSU/scheduler mismatch) | **Fatal** |

### 3.3 SRAM Protection (`cdnsdru_asf_sram_protect_v1`)

A reusable wrapper placed between the DMA/MAC logic and the external TX/RX packet-buffer SRAMs. It supports two mutually exclusive modes selected by `p_use_ecc`:

| Mode | Write Behavior | Read Behavior | Overhead |
|------|---------------|---------------|----------|
| Parity only (`p_use_ecc=0`) | Generates 1-bit parity per byte of data + 1-bit parity per byte of address | Checks both; flags uncorrectable error only | Data + address parity bits |
| ECC (`p_use_ecc=1`) | Generates SECDED ECC over data + address parity | Corrects single-bit errors, detects double-bit errors; flags `corr_err` and `uncorr_err` | 7 or 8 ECC bits per ≤80-bit chunk + address parity |

Implementation details:
- Uses `cdnsdru_ecc_parity_gen_wrap_v1` / `cdnsdru_ecc_correct_wrap_v1` to split wide data across multiple `80_8` Hamming generators/correctors.
- Address parity is always byte-wide even parity (odd_par=0).
- Read latency is parameterized (`p_read_latency`, default 1) to match the external SRAM.
- In `gem_top.v` the TX/RX SRAMs each get two `cdnsdru_asf_sram_protect_v1` instances: port A (write side), port B (read side).
- Correctable-error statistics and the failing address are synchronized to `pclk` by `gem_pclk_syncs_sram_stats.v`.

### 3.4 Parity Generation/Checking (`cdnsdru_asf_parity_gen_v1` / `_check_v1`)

- Generic byte-wise parity generator/checker.
- Configurable even/odd parity via `odd_par`.
- Pads non-byte-aligned data with `0` for even parity or `1` for odd parity.
- Used for:
  - APB `pwdata` / `prdata` parity (`gem_asf_host_par`).
  - Data and address path parity inside DMA/MAC (`gem_asf_dap_prot`).
  - Configuration/control register parity (`gem_asf_csr_prot`).

### 3.5 Lockup Detection

Three levels of watchdog-style lockup detection are implemented:

#### 3.5.1 DMA Lockup (`edma_lockup_detect` → `edma_tx_lockup_detect` / `edma_rx_lockup_detect`)

| Check | What it monitors | Timeout register |
|-------|-----------------|------------------|
| TX Part 1 | From `tx_start_pclk` to full packet written into TX SRAM | `dma_lockup_time` |
| TX Part 2 | Packet count in TX SRAM not decrementing (packet stuck before MAC) | `dma_lockup_time`, per-queue enable `dma_tx_lockup_q_en` |
| RX | Packet count in RX SRAM not decrementing (packet stuck before host memory) | `dma_lockup_time` |

Restrictions:
- Full-duplex only for TX Part 2 (collisions in half-duplex would false-trigger).
- Not compatible with TX cut-through or RX Side Coalescing (RSC) when enabled.

#### 3.5.2 MAC Lockup (`gem_mac_lockup_detect` → `gem_tx_lockup_detect` / `gem_rx_lockup_detect`)

| Check | What it monitors | Timeout register |
|-------|-----------------|------------------|
| TX MAC | FIFO-interface EOP → MII-bridge EOP | `tx_mac_lockup_time` |
| RX MAC | Good packet received within interval | `rx_mac_lockup_time` |

A programmable 16-bit prescaler in `tx_clk` generates a toggling timebase (`lockup_prescale_tog`) shared by the DMA and MAC lockup modules.

#### 3.5.3 Mapping to ASF Transaction-Timeout Faults

In `gem_registers.v`:

| `asf_trans_to_fault` bit | Source |
|--------------------------|--------|
| 0 | `tx_lockup_detected` (MAC TX) |
| 1 | `rx_lockup_detected` (MAC RX) |
| 2 | `dma_tx_lockup_detected` |
| 3 | `dma_rx_lockup_detected` |
| 4 | `asf_host_trans_to_err_pclk` (AXI host timeout, optional) |

### 3.6 Transaction Timeout Monitor (`cdnsdru_asf_trans_timeout_v1`)

- Generic request/response timeout timer.
- Parameterizable counter width (`p_count_width`, default 12).
- Optional registered output (`p_reg_op`).
- Counts while `enable & (trans_req | timer_active) & timer_cnt_en` until `trans_resp` or `timer == timeout_val`.
- Used directly by the lockup-detection logic and for optional host-bus transaction timeouts.

### 3.7 CSR/Register Corruption Detection

When `gem_asf_csr_prot` is enabled (`gem_registers.v`):

| Mechanism | Coverage |
|-----------|----------|
| Byte-wise parity on all configuration/control registers | Detects single-bit and odd-bit corruption |
| Register duplication + continuous compare for mission-critical status/config registers | Detects stuck-at and many multi-bit faults |
| Parity stored from host write (`gem_asf_host_par`) | End-to-end APB write parity |

Aggregated `csr_parity_fault` combines errors from PCS, MMSL, common registers, TSU, screeners, scheduler, filters, ENST, RX queue flush, DMA, CB, pause, interrupt-status duplication, network-config duplication, and MDIO PHY management blocks.

Registers **not protected**: GPIO and statistics registers (considered informational).

### 3.8 Data and Address Path (DAP) Protection

Enabled by `gem_asf_dap_prot`:

- 1-bit-per-byte parity on key data paths between the AMBA host interface and the GMII line interface.
- Address-bus parity on host-side address paths.
- Covers buffering, byte-alignment, and pipeline stages.
- Diagnostic coverage assumed 98% conservative for wide 64-bit+ paths.

### 3.9 Integrity Protection

Enabled by `gem_asf_integrity_prot`:

| Block | Protection |
|-------|------------|
| TSU timer (`gem_asf_prot_tsu`) | Module duplication + continuous output compare |
| Transmit scheduler (`gem_asf_prot_tx_sched`) | Module duplication + continuous output compare |
| AXI transaction integrity (`gem_asf_integrity_prot`) | Optional AXI response/transaction checking (AXI mode) |

Faults are reported as `asf_integrity_err`.

### 3.10 Protocol Fault Checking

`asf_protocol_fault_status` (offset `0xE44`) captures built-in MAC/DMA exception events. Bit assignments observed in RTL:

| Bit | Event |
|-----|-------|
| 0 | RX CRC error |
| 1 | RX short frame |
| 2 | RX long frame |
| 3 | RX symbol error |
| 4 | RX length error |
| 5 | RX IP checksum error |
| 6 | RX TCP checksum error |
| 7 | RX UDP checksum error |
| 8 | TX too many retries / late collision (half-duplex) |
| 16 | TX underrun |
| 17 | TX buffers exhausted mid-frame |
| 18 | TX AHB/AXI `hresp` error |
| 19 | RX AHB/AXI `hresp` error |
| 20 | RX overflow / packet dropped |
| 21 | RX DMA packet flushed |

Most are informational; safety-critical systems should treat host-bus errors, underrun, overflow, and retry/l collision as fatal.

---

## 4. DFT Infrastructure

### 4.1 Scan Strategy

- **No hard-coded scan chains in RTL.** Scan is inserted by the Cadence Genus/RC synthesis flow.
- `genus_synth.tcl` sources `dft_setup.tcl` before SDC and `dft_insert_scan.tcl` after synthesis if `INSERT_SCAN==1`.
- `set_db / .dft_auto_identify_shift_register true` allows shift-register recognition.
- `set_db / .use_scan_seqs_for_non_dft $SCAN_SEQ_MODE` lets non-DFT logic reuse scan flip-flops.
- Preserved pre-mapped submodules are marked `dft_dont_scan`.

### 4.2 Clock Constraints

Functional SDC (`synth/constraints/cfg/pbuf_3qs_axi/gem_gxl_pbuf_3qs_axi.func.sdc`) defines six asynchronous clock groups:

| Clock | Frequency | Domain |
|-------|-----------|--------|
| `aclk` | 400 MHz | AXI DMA host |
| `rx_clk` | 125 MHz | MAC RX / line side |
| `tx_clk` | 125 MHz | MAC TX / line side |
| `n_tx_clk` | 125 MHz (inverted) | Loopback/MII bridge |
| `tsu_clk` | 400 MHz | IEEE 1588 timestamp unit |
| `pclk` | 100 MHz | APB register/config |

All cross-clock paths are constrained with `set_max_delay` and `set_false_path -hold` or full `set_false_path` from `pclk` to all other clocks.

ATPG-specific clock constraints are extracted with `extract_clock_constraints_for_atpg` and written to:

- `hdl_qc/cfg/pbuf_3qs_axi/dft/constraints/clock_constraints_pbuf_3qs_axi.txt`
- Example content (8 lines): tx_clk 125 MHz, tsu_clk 400 MHz, n_tx_clk 125 MHz, pclk 100 MHz, rx_clk 125 MHz, aclk 400 MHz, plus tx_clk/n_tx_clk relationships.

### 4.3 Scan/Test Mode SDC Templates

| File | Purpose |
|------|---------|
| `synth/scripts/sdc/template.scan.sdc` | Top-level scan constraints |
| `synth/scripts/sdc/template.scan_shift.sdc` | Shift-mode constraints |
| `synth/scripts/sdc/template.scan_capture.sdc` | Capture-mode constraints |

### 4.4 ATPG / Vector Generation

| File / Script | Tool | Purpose |
|---------------|------|---------|
| `synth/scripts/tmax/atpg.tcl` | Synopsys TetraMAX | ATPG script example |
| `synth/scripts/modus/write_vectors_template.txt` | Cadence Modus | Vector timing/padding template |
| `synth/scripts/run_atpg.csh`, `run_atpg_ddr.csh` | Shell wrappers | Launch ATPG |
| `synth/scripts/run_sims_atpg*.csh` | VCS/NC | Run gate-level ATPG simulations |
| `hdl_qc/cfg/pbuf_3qs_axi/dft/dummy.tdr` | Encounter Test | Dummy tester description rule for ATPG timing |

The dummy TDR declares resources: 20,000 pins, 128 clock pins, 512 scan-in pins, 32 oscillators, min cycle 2500 ps, min scan cycle 13250 ps.

### 4.5 What the DFT Flow Expects from the Integrator

- Provide technology library with scan cells.
- Define `SCAN_SEQ_MODE`, `INSERT_SCAN`, `CONNECT_CHAINS`, `CLOCK_GATING`, etc. in `project.tcl`.
- Connect scan-mode/test-mode ports at chip level; the IP itself does not expose dedicated scan pins.
- Handle multi-clock ATPG because the design contains six asynchronous clocks plus derived clocks.

---

## 5. Low-Power Intent

### 5.1 Delivered CPF/UPF

| Directory | Content |
|-----------|---------|
| `pwr_intent/cpf/` | Empty (only directory) |
| `pwr_intent/upf/` | Empty (only directory) |
| `synth/scripts/cpf/project.cpf` | Example single-domain CPF used by synthesis |

`project.cpf` defines:

| Item | Value |
|------|-------|
| CPF version | 1.1 |
| Default power domain | `PD_vdd` |
| Nominal condition | `power_on` |
| Power mode | `PM_ALL_on` (always on) |
| Power nets | `vdd` / `gnd` |
| Global connections | `VDD` → `vdd`, `vss`/`VSS` → `gnd` |

All power-domain/state-retention/isolation/level-shifter rules are commented out. The IP therefore ships with **no multi-voltage or power-shutoff intent**; it is the integrator’s responsibility to add domain partitioning if needed.

### 5.2 Clock Gating

- Synthesis script `genus_synth.tcl` enables `lp_insert_clock_gating` when `CLOCK_GATING==1`.
- Minimum gating width: 3 flops (`lp_clock_gating_min_flops 3`).
- Clock-gating reports are generated in synthesis (`report_clock_gating`).
- No explicit clock-gating cells are instantiated in the analyzed RTL; gating is inserted automatically.

### 5.3 Functional Low-Power Features

- **IEEE 802.3az LPI (Low Power Idle)** is supported by the GEM MAC and exposed through `lpi_indicate` / LPI status registers. This is a line-side power-saving protocol negotiated with the PHY, not a power-domain shutdown.
- **TSU, DMA, MAC clock enables** are managed internally by the RTL but are not described by a UPF/CPF.

---

## 6. ASIL-B Essential vs. Optional

Based on the safety manual and RTL analysis, the following table distinguishes features that are **essential for an ASIL-B automotive deployment** from those that are **optional or use-case dependent**.

| Feature | ASIL-B Essential? | Rationale / Notes |
|---------|-------------------|-------------------|
| `gem_asf_enable` (DAP + CSR + trans-to + integrity) | **Essential** | Master switch that enables the core ASF diagnostics required for the ASIL-B Ready FMEDA. |
| `gem_asf_ecc_sram` (SECDED on packet buffers) | **Essential** | Without ECC the SPFM/LFM drops dramatically; safety manual shows ECC moves SPFM to ~98.8% and LFM to ~99.95%. |
| Lockup detection (MAC + DMA) | **Essential** | Detects stuck datapaths/liveness failures. Must be enabled and SW must configure timeouts. |
| Data/Address Path parity (`gem_asf_dap_prot`) | **Essential** | Covers the wide data paths; included by `gem_asf_enable`. |
| CSR parity/duplication (`gem_asf_csr_prot`) | **Essential** | Protects config/status registers; included by `gem_asf_enable`. |
| AMBA host-bus error reporting | **Essential** | Illegal DMA addresses must trigger safe-state transition. |
| `gem_asf_prot_tsu` (TSU duplication) | **Use-case dependent** | Required only if PTP/1588/802.1AS timing is safety-relevant. |
| `gem_asf_prot_tx_sched` (scheduler duplication) | **Use-case dependent** | Required only if strict QoS/bandwidth allocation is safety-relevant. |
| `gem_asf_host_par` (host bus parity) | **Recommended** | Provides end-to-end parity on AXI/APB; useful if host bus supports parity. |
| Protocol fault monitoring (CRC, length, checksums, etc.) | **Use-case dependent** | CRC/length errors are informational for normal networks; treat host-bus errors/underrun/overflow as fatal. |
| Statistics registers | **Not safety-critical** | Explicitly excluded from protection; considered informational. |
| GPIO / WOL / external interrupt input | **Not safety-critical** | Not protected; avoid for safety functions. |
| Full store-and-forward mode | **Essential for ASIL-B** | Safety manual assumes cut-through is **not** used; eliminates TX underrun risk and simplifies lockup detection. |
| Full-duplex only | **Essential** | TX lockup Part 2 requires full duplex; half-duplex collisions break packet-count logic. |
| Disable LSO / RSC / 802.3br / 802.1CB | **Essential/recommended** | These features conflict with lockup detection or significantly increase area; safety manual excludes them from the reference config. |
| Periodic transfer test (external SW/HW) | **Essential complement** | Required external mechanism per safety manual to detect stuck-at faults not covered by internal monitors. |
| APB register mirror check | **Recommended** | External SW mechanism to validate dynamic control registers. |
| Interrupt pin validation | **Recommended** | SW write-to-test register to verify interrupt path. |
| Redundant IP instance | **Optional** | Only if safe-state shutdown violates system safety goals. |

---

## 7. Key Integration Notes for an ASIL-B SoC

1. **Reset strategy:** The safety manual recommends hardware reset of all IP reset pins to enter the safe state; software-only disable via `network_control` requires re-initialization of all config registers.
2. **Clock/power failures:** Clock and power failures are explicitly out of scope of the IP-level FMEDA and must be handled by the SoC integrator.
3. **Safe states:** Disabled, held-in-reset, or powered-off. The integrator must ensure these states do not violate the system-level safety goal.
4. **Recovery:** On any fatal ASF interrupt, transition to safe state, run a periodic transfer test, and only resume if the test passes; otherwise treat as permanent failure.
5. **SRAM integration:** The packet-buffer SRAMs are external to the IP. The integrator must provide SRAMs that meet the protected data width (data + ECC/parity + address parity) and 1-cycle read latency assumed by `cdnsdru_asf_sram_protect_v1`.
6. **DFT:** No test-mode pins exist at the IP boundary. The integrator must define chip-level scan/test modes and ensure that ATPG constraints cover the six asynchronous clock domains.
7. **Low power:** No UPF/CPF power domains are defined beyond a single always-on domain. Any power-domain partitioning, retention, or isolation must be added by the integrator.

---

## 8. Observations & Gaps

| # | Observation | Impact |
|---|-------------|--------|
| 1 | `pwr_intent/cpf/` and `pwr_intent/upf/` are empty. | The IP does not ship with a production low-power intent file; integrator must author one. |
| 2 | `dft/` top-level directory is empty. | DFT collateral lives under `synth/scripts` and `hdl_qc/cfg/.../dft`; no central DFT README. |
| 3 | No dedicated test-mode/scan-enable/scan-in/scan-out ports in `gem_gxl.v`. | Scan insertion is fully tool-driven; integration must add pin-level test infrastructure. |
| 4 | ECC coverage includes address parity but not full address ECC. | Address corruption beyond the parity-detection capability (even number of bit errors within a byte) may be missed; this is consistent with the conservative 98% DC assumption. |
| 5 | Statistics/GPIO registers are not protected. | SW must not use them for safety decisions. |
| 6 | Lockup detection does not support TX cut-through or RSC. | These features must be disabled for ASIL-B. |
| 7 | The safety manual is a PDF only; no machine-readable FMEDA is delivered in this archive. | Integrator must request/obtain the FMEDA spreadsheet from Cadence for ASIL-B work-product evidence. |

---

## 9. Conclusion

The Cadence GEM GXL provides a well-structured, parameterizable ASF subsystem suitable for ASIL-B automotive Ethernet applications **when the recommended configuration is followed**: enable `gem_asf_enable` + `gem_asf_ecc_sram`, disable cut-through/LSO/RSC/half-duplex, and implement the external periodic-transfer and register-mirror checks described in the safety manual. DFT and low-power features are intentionally left as tool-driven/integrator responsibilities: scan is inserted by Genus/Modus, and power intent is limited to a single always-on domain example CPF. The integrator must therefore supply the chip-level DFT and power-domain implementation to complete an ASIL-B SoC solution.

---

*End of A6 Safety & DFT Analysis Report*
