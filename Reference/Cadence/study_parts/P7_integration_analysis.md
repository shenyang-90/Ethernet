# Cadence GEM GXL SoC Integration Analysis

**Agent**: P7  
**Sources**: `integration_guide.txt`, `quickstart.txt`, `rgmii_app_note.txt`  
**Scope**: read-only summary of integration requirements, clocking, RGMII variants, initialization, deliverables, and verification flow.

---

## 1. SoC Integration Requirements

| Item | Requirement / Recommendation |
|------|------------------------------|
| **Host bus** | AMBA Rev 2.0 compliant AXI or AHB DMA master (DMA-capable variants) plus APB slave for registers. |
| **AXI/AHB hookup** | Connect DMA master to system memory/interconnect; connect APB to CPU/register access. Packet-buffer RAMs connect externally to `txdpram_*` / `rxdpram_*` ports. |
| **Register/config visibility** | `gem_gxl_defs.v` compile-time defines; configuration readable via APB starting at `0x280`. |
| **External memories** | Required for DMA packet-buffer variants. Supports 32/64/128-bit AMBA data widths; dual-port or single-port (128-bit only). |
| **RAM sizing rule** | Size ≥ 2× max frame size for peak throughput; minimum > max frame length in store-and-forward. Per-TX-queue independent; RX shared. |
| **Clock domains** | `aclk`/`hclk` (DMA/AMBA), `pclk` (APB), MAC `tx_clk`/`rx_clk`, PCS clocks (`gtx_clk`, `rbc1`/`pcs_rx_clk`), plus RGMII/RMII reference clocks. |
| **Resets** | Assert asynchronously, de-assert synchronously to the relevant clock domain. |
| **Low power** | No built-in low-power features; external memory power-down must be handled by SoC. |
| **Technology cells** | Fully synthesizable RTL; synchronizer `cdnsdru_datasync_v1` may be replaced with a technology-specific cell. |
| **DFT** | No special DFT integration required; flops are scannable and all clocks are top-level. |

---

## 2. Recommended Clock Frequencies & Constraints

### Minimum AHB/AXI frequency (single-port external memory)

| DMA Bus Width | MAC Rate | Minimum `aclk`/`hclk` |
|---------------|----------|----------------------|
| 32-bit | 1000 Mbps | 125 MHz |
| 32-bit | 100 Mbps  | 15 MHz  |
| 32-bit | 10 Mbps   | 10 MHz  |
| 64-bit | 1000 Mbps | 65 MHz  |
| 64-bit | 100 Mbps  | 10 MHz  |
| 64-bit | 10 Mbps   | 10 MHz  |
| 128-bit | — | Not supported with single-port memory |

### Typical PPA reference frequencies

| Clock | Typical Frequency |
|-------|-------------------|
| AXI (DMA) | 400 MHz |
| APB | 100 MHz |
| RGMII Gigabit `tx_clk` | 125 MHz |
| 10/100 MII `tx_clk` | Sourced from PHY (25 MHz / 2.5 MHz) |

### Key synthesis/STA constraints

| Constraint | Detail |
|------------|--------|
| Cross-clock handshaking | Max delay between domains ≤ one destination clock period. |
| Gigabit TBI | `rx_clk` sourced from `rbc1`/`pcs_rx_clk`; `tx_clk` sourced from `gtx_clk`; balance respective clock trees. |
| RGMII | Inverted `tx_clk`/`n_tx_clk` and `rx_clk`/`n_rx_clk` must be balanced with their non-inverted versions. |
| RMII | `rmii_tx_clk`/`rmii_rx_clk` derived from `ref_clk`; balance `tx_clk` with `ref_clk` (RX has ~20 ns slack). |
| RGMII comb paths | Tightly constrain `rgmii_tx_clk_sig` → `rgmii_txd`/`rgmii_tx_ctl` and flop/mux → output paths. |
| I/O delay | Set to **0.6 × clock period** in generated SDC. |
| Output variation | Keep transmit data/control skew within **500 ps** before adding clock delay. |

---

## 3. RGMII Clocking Variants

| Variant | Clock Delay Method | Pad Type | Notes |
|---------|-------------------|----------|-------|
| **RGMII v1.3** | PCB trace delay on clock: **1.5–2.0 ns** | 2.5 V CMOS | Clock and data edge-aligned at SoC output; board delay centers clock at PHY. |
| **RGMII v2.0+** | On-chip source delay option (**RGMII-ID**) | 1.5 V HSTL | Delay added inside SoC or PHY; PHY may provide programmable delay. |
| **RGMII-ID** | `tx_clk` delayed ~**2 ns** relative to data | Depends on implementation | Centre-aligned at PHY; implementer must provide programmable delay buffer for `tx_clk`. |

### Receive
- PHY already delays `rx_clk` vs. data; delay at SoC pins is **1–3 ns** (min 1 ns setup, min 1 ns hold).
- Constrain input paths from `rgmii_rxd`/`rgmii_rx_ctl` and generated `rx_clk`/`n_rx_clk` to first flops.

### Transmit
- v1.3: match external `tx_clk` delay to data outputs (edge-aligned).
- RGMII-ID: delay `tx_clk` output ~2 ns vs. data (centre-aligned).
- `tx_clk_sig` (mux select) should be delayed sufficiently (e.g., ~2 ns / 90° of `tx_clk`) to avoid glitches; ensure timing path C > paths A & B across all corners.

---

## 4. Quick-Start Initialization / Configuration Checklist

1. **Install the IP**
   - Copy tarball and run `tar -zvxf <gem_gxl_detXXXX_r1p12.tar.gz>`.
2. **Generate configuration**
   - GUI: `cd gem_gxl/work && ./gem_cfg_builder.pl -gui`, then save `<user_config_name>.cee`.
   - CLI: use `gem_cfg_builder.pl -cfg pbuf_3qs_axi`, edit `gem_gxl_defs.v`, save as `<user_config_name>.v`, import, then regenerate with `-gen_synth`.
3. **Run sanity simulation**
   - Directed Verilog TB: `make run_sim TB=directed CFG=<user_config_name> TST=txrx_soak`.
   - Or all scenarios: `make run_sim TB=directed`.
   - Check `irun.log` for `**** PASSED ****`.
4. **Run demo UVM/VIP simulation** (optional)
   - `make run_sim TB=uvm_demotb CFG=pbuf_axi_uvm TST=cdn_gem_demo_c_uc_enet_txrx_3pkts_test`.
   - Check `irun_<test_name>.log` for pass messages.
5. **Run sanity synthesis**
   - `make run_synth CFG=<user_config_name>`.
   - Review `gem_gxl/synth/default/<user_config_name>/reports/rc.log` and `gem_qor.rpt`.
6. **Run LEC** (post-synthesis)
   - `cd ../work_phys_<config> && ../synth/scripts/run_phys.csh -lec_2stage`.
   - Check `rtl2mapped.lec.log` and `map2final.lec.log`.

---

## 5. Deliverables & Recommended Verification Flow

### Deliverables

| Directory | Contents |
|-----------|----------|
| `doc/` | User guide, integration guide, quick-start, safety manual, release/errata notes. |
| `hdl/hdl_src/` | Unencrypted synthesizable RTL. |
| `hdl_qc/` | Lint/CDC/synthesis setup files. |
| `func_ver/` | Gate-sim info, HVM testbench, sanity testbenches (directed Verilog + UVM demo), SVA, SDF back-annotation. |
| `software/` | Core driver, Linux reference driver, driver docs, release notes. |
| `synth/` | Constraints, synthesis scripts, technology setup examples. |
| `work/` | Makefile, `gem_cfg_builder.pl`, `cfg_gen_pkg` (fixed/imported configs). |

### Recommended verification flow

| Step | Activity | Artifact / Success Criteria |
|------|----------|----------------------------|
| 1 | Configuration generation & filelist creation | `gem_gxl_defs.v`, `gem_gxl.f`, SDC, setup files. |
| 2 | Directed sanity simulation | `irun.log` shows `PASSED`. |
| 3 | UVM/VIP demo regression (optional) | `irun_<test>.log` pass messages. |
| 4 | Lint with generated waiver files | AFL / SpyGlass clean or waived. |
| 5 | CDC check with generated waiver files | Cadence Conformal Constraint Designer clean. |
| 6 | Trial synthesis & QoR review | `rc.log`, `gem_qor.rpt` meet timing/area. |
| 7 | LEC (rtl2mapped / map2final) | Both LEC logs pass. |
| 8 | Gate-level simulation with SDF back-annotation (if available) | Match RTL behavior. |
| 9 | ATPG / scan (optional) | Trial stuck-at coverage ~99.82 %; at-speed ~89.97 %. |

---

## Key Integration Notes

- PHY mode selection is configuration/register controlled (RGMII, RMII, TBI, MII-over-RGMII via `sel_mii_on_rgmii` bit 28 of network control register).
- For PCS configurations, disable TBI mode (bit 11 of network configuration register) when using internal loopback.
- Set `retry_test` bit to accelerate collision back-off, pause counter, and FRER timeout during directed testing.
- Automotive (IP701xA) variants: preserve duplicated TSU/scheduler logic in synthesis; monitor ASF fault/status registers.
