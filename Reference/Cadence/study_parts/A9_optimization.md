# A9 Optimization Recommendations — Ethernet IP vs. Cadence GEM GXL

> **Agent**: A9 (Optimization Advisor)  
> **Date**: 2026-06-25  
> **Reference IP**: Cadence GEM GXL (IP7014A, r1p12f4)  
> **Project Docs Reviewed**:
> - `Docs/Arch/ethernet_arch_spec.md` v1.8d
> - `Docs/Arch/protocol_analysis.md` v2.2
> - `Docs/Arch/ethernet_interface_spec.md` v1.1
> - `Docs/Design/ethernet/ethernet_design_spec.md` v1.1
> - `Design/RTL/ip/ethernet/ethernet_top.sv` v0.1
> - `Reference/Cadence/gem_gxl_det0104_r1p12f4/gem_gxl/hdl/hdl_src/*` (top-level and key module inventory)
> - `Reference/Cadence/.../doc/cdn_eth_ip7014A_user_guide_v1.0.pdf` (extracted text)

---

## 1. Executive Summary

The current Ethernet IP project defines a highly differentiated, automotive-grade **multi-MAC / multi-rate / multi-PHY / L2-L3 Switch / dual-PHC / vPHC** architecture. In contrast, the Cadence GEM GXL reference IP is a mature, single-port **10/100/1000 MAC + DMA + 1588 + TSN/AVB endpoint**. The biggest near-term risk is **scope overload** while the RTL top level remains an empty stub.

**Top-level recommendation**: freeze a "base SKU" (single GMAC, RGMII/1G, AXI DMA, 1588, ASIL-B), implement and verify it first, then add TSN, Switch, and vPHC features in gated phases. Reuse proven Cadence sub-blocks for the endpoint MAC functions; design from scratch the features that Cadence does not provide (multi-MAC, Switch, vPHC, multi-rate PCS).

---

## 2. Per-Document Optimization Recommendations

### 2.1 Architecture Specification (`ethernet_arch_spec.md`)

| # | Target Section | Current Issue | Recommended Change | Priority | Effort |
|---|----------------|---------------|--------------------|----------|--------|
| 1 | §1.4.1 / §1.4.4 | Default config enables too much at once: `MAC_COUNT=4`, XGMAC/5G defaults, `SUPPORT_SWITCH=1`, `SUPPORT_VPHC=0` but `PHC_COUNT=2`, security interfaces, etc. This makes the first RTL milestone unmanageable. | Define a **base SKU** default: `MAC_COUNT=1`, `MAC_0_TYPE=GMAC`, `MAC_0_SPEED=1G`, `SUPPORT_SWITCH=0`, `SUPPORT_VPHC=0`, `SUPPORT_IPSEC=SECOC=DTLS=0`. Advanced features remain parameterizable but default-off. | P0 | Small |
| 2 | §3.3.2 / §3.3.4 | PHC clock is fixed at 250 MHz (4 ns tick). While the Addend provides fine frequency adjustment, the raw timestamp resolution is coarse and there is no per-port TX/RX propagation-delay compensation register. | Add **per-port PHY delay compensation CSR** (`PORTx_TX_DELAY`, `PORTx_RX_DELAY`) and document that ±10 ns target requires PCB/PHY characterization. Consider raising `clk_ts` to 375 MHz for higher-end SKUs. | P1 | Small |
| 3 | §1.4.1 / §10.4 | Security accelerator interface (`SUPPORT_IPSEC/SECOC/DTLS/MACSEC`) is a single flat `SECURITY_ACCEL` bundle without protocol-specific descriptor bits or context IDs. | Split into **separate optional wrappers** (`eth_macsec_wrap`, `eth_ipsec_wrap`, `eth_secoc_wrap`) and define descriptor control bits (e.g., `DESC_CTL_SEC_TYPE[2:0]`, context ID) in the DMA descriptor layout. | P1 | Medium |
| 4 | §1.4.1b / §2.1 | Per-MAC and per-PHY type/ speed parameters are rich, but no top-level validation rule ties `PHY_x_SPEED` to `MAC_x_SPEED` and the `AXI_DATA_WIDTH` selection. | Add a **configuration-validation function/table** in the Arch Spec (and later a SystemVerilog `generate` assertion) that derives minimum `AXI_DATA_WIDTH`, `DMA_CH_COUNT`, and `MTL_FIFO_DEPTH` from the active MAC/PHY matrix. | P1 | Small |
| 5 | §1.4.5 / §3.3 | Safety CSR space (0x700–0x718) is small and fixed; vPHC/Security/Switch blocks have separate large CSR regions but no unified safety/isolation policy. | Reserve a **dedicated, write-once safety region** per subsystem with parity-protected access and document which registers are safety-critical vs. diagnostic. Align with Cadence ASF fault-logging concept. | P1 | Medium |

### 2.2 Protocol Analysis (`protocol_analysis.md`)

| # | Target Section | Current Issue | Recommended Change | Priority | Effort |
|---|----------------|---------------|--------------------|----------|--------|
| 1 | §2.3.2 (GCL FSM) | The GCL FSM increments `gcl_timer` every 1 ns, but `clk_ts` is 250 MHz (4 ns). This creates a resolution mismatch and makes exact gate transitions impossible without a fractional sub-counter. | Redefine the GCL timer in **raw `clk_ts` ticks** (4 ns granularity) and document the quantization error. Provide a programmable sub-tick counter for higher precision if needed. | P0 | Small |
| 2 | §2.9.2 (Switch FSM) | The example FDB lookup uses combinational RAM read (`fdb_mem[fdb_index]`) in the same cycle as hash computation, which is unrealistic for 8K entries at 300 MHz. | Insert a **2-cycle FDB lookup pipeline** (hash → index → read → compare) and update the protocol-analysis pseudo-code and latency budget. | P0 | Medium |
| 3 | §2.2.4 / §3.3.10 (BMCA) | BMCA state machine is described as if it belongs in hardware, but the 802.1AS profile selection, priority vectors, and state decision events are normally handled by software for flexibility. | Clarify the **hardware/software boundary**: hardware captures timestamps and classifies PTP event/general messages; software runs BMCA and writes the selected grandmaster parameters to CSR. | P1 | Small |
| 4 | §2.5 (802.3br Preemption) | mCRC polynomial and SMD values are listed, but no test vectors or reference algorithm are provided for verification. | Add a **mCRC test-vector table** (fragment sizes 64/128/256 bytes) and note that the Cadence `gem_mmsl_*` modules can be adapted for the MAC Merge Layer. | P1 | Small |
| 5 | Across §2.x | Many pseudo-code snippets contain implicit bit-width/overflow assumptions (e.g., 48-bit credit, 80-bit timestamp arithmetic) that are not captured as assertions. | Extract **SystemVerilog Assertion (SVA) templates** from each protocol section and add them to the verification plan (e.g., credit saturation, sequence-number window advance, FCS magic residue). | P1 | Medium |

### 2.3 Interface Specification (`ethernet_interface_spec.md`)

| # | Target Section | Current Issue | Recommended Change | Priority | Effort |
|---|----------------|---------------|--------------------|----------|--------|
| 1 | §3.3 / §2.3 | CSR address width defaults to 12 bits (4 KB space), but the address map already uses offsets 0x3000, 0x3800, and 0xF000 for Switch, Security, and Safety blocks. | Change default `CSR_ADDR_WIDTH` to **14 or 15 bits** and reserve upper address regions per subsystem (MAC/MTL/DMA/Switch/Security/vPHC/Safety). | P0 | Small |
| 2 | §2.3 / §2.4 | AXI4 Master ID/QoS table uses a single ID space. There is no mention of read/write ID separation, `AWUSER/ARUSER`, or descriptor-read buffering like Cadence uses. | Add **per-channel read and write ID counters**, `awuser/aruser` for VM/integrity tagging, and define descriptor-read/write FIFO depths (`gem_axi_*_descr_*_buff_bits` style). | P1 | Medium |
| 3 | §9 (Security Accelerator) | The `SECURITY_ACCEL` interface is a flat 128-bit bundle without packet-boundary signals, making it impossible to stream multi-beat frames safely. | Add **`sec_accel_sop`, `sec_accel_eop`, `sec_accel_len`, `sec_accel_ctx_id`** and define a credit-based handshake with FIFO depth per security type. | P0 | Medium |
| 4 | §5.3 (vPHC) | `vm_id[3:0]` is present but no address-window isolation or per-VM lock mechanism is described. | Define **per-VM CSR aperture** (e.g., base + `VM_ID * 0x100`) with a `VM_LOCK` register and an access-violation interrupt, so vPHC cannot be corrupted by an illegal VM. | P1 | Medium |
| 5 | §6.2 | Interrupt vector is fixed at 16 bits for DMA channels only; no room for Switch, PTP, Security, or Safety events. | Expand `irq_vector` to **32 bits** (or add a second `irq_vector_ext[15:0]`) with a clear allocation: bits 0–15 for DMA, bits 16–23 for Switch/PTP/Security, bits 24–31 for Safety. | P1 | Small |
| 6 | §4.x (PHY interface) | All PHY signals (MII/RMII/RGMII/SGMII/USXGMII/EEE/CRS/COL) are flattened at the top level, creating a huge, error-prone port list. | Use **SystemVerilog interfaces** (e.g., `phy_mac_if`, `phy_serdes_if`) and `generate` blocks so only the configured PHY type exposes pins. | P1 | Medium |

### 2.4 Micro-Architecture / Design Spec (`ethernet_design_spec.md`)

| # | Target Section | Current Issue | Recommended Change | Priority | Effort |
|---|----------------|---------------|--------------------|----------|--------|
| 1 | §1.1 / `ethernet_top.sv` | `ethernet_top.sv` is an empty stub with no parameters or ports, while the Design Spec describes 11 subsystems. There is no incremental integration plan. | Implement a **parameterized top-level shell** with `generate` blocks that instantiate only the modules required by the current SKU; start with MAC+MTL+DMA+PTP+Safety. | P0 | Medium |
| 2 | §4.1.1 / §4.1.4 | Global DMA channel pool is described, but no micro-architectural block (e.g., `dma_ch_map` table, WRR weights, per-channel outstanding limiter) is defined. | Add a **Channel Mapping & QoS sub-module** with CSRs: `DMA_CH_MAP[n]`, `DMA_CH_WEIGHT[n]`, `DMA_CH_QOS[n]`, and a global outstanding counter capped at 32. | P0 | Medium |
| 3 | §4.2.1 / §6.1 | MTL TX/RX FIFO defaults to 32 KB per MAC. For 8 MACs this becomes 512 KB of SRAM before Switch FIFOs are counted, conflicting with area targets. | Make FIFO depth **scale inversely with `MAC_COUNT`** or adopt a **shared packet buffer** architecture (similar to Cadence `edma_pbuf_*`) to reduce total SRAM area. | P1 | Large |
| 4 | §4.4.1 (Switch Core) | 8K-entry FDB + L3 route + N-port crossbar + Switch TAS is an aggressive first implementation with unproven timing/area. | Start with a **minimal Switch**: 2–4 ports, 1K static FDB, no L3 route, no dynamic learning. Add dynamic learning, 8K FDB, and L3 only after the base switch passes regression. | P0 | Large |
| 5 | §4.9 (Low Power) | EEE/WoL/Deep Sleep are all enabled by default. WoL magic-packet detection and deep-sleep power sequencing add significant verification effort for a P2 feature. | Keep **EEE LPI enabled** (reuse Cadence LPI concepts), but default `WOL_ENABLE=0` and `DEEP_SLEEP_ENABLE=0` until Phase 3/4. | P1 | Small |
| 6 | §4.7.1 (Safety Monitor) | ECC/parity blocks are generically described without per-memory sizing; many FIFOs and SRAMs need different protection schemes. | Generate **per-memory protection wrappers** (SECDED for data SRAMs, parity for FIFO control) and reuse the Cadence ASF primitives (`cdnsdru_asf_parity_*`, `cdnsdru_ecc_correct_*`, `cdnsdru_asf_trans_timeout_v1`). | P1 | Medium |

---

## 3. Recommended Development Roadmap

The roadmap below deliberately front-loads a **minimal viable MAC (MVM)** so that the team can boot software, run traffic, and close timing before adding the differentiating TSN/Switch/vPHC features.

### Phase 1 — Minimal Viable MAC (MVM) Endpoint
**Goal**: One GMAC, RGMII/1G (or MII/100M), AXI DMA, VLAN, 1588 timestamping, checksum offload, ASIL-B safety.

| Work Item | Priority | Effort | Cadence Reuse |
|-----------|----------|--------|---------------|
| Parameterized `ethernet_top` shell with generate blocks | P0 | Medium | New |
| Single-port MAC TX/RX FSM + CRC + PAUSE | P0 | Medium | Adapt `gem_mac`, `gem_tx`, `gem_rx` |
| MII/RGMII/RMII PHY interface | P0 | Small | Reuse `gem_mii_bridge`, `rgmii.v`, `rmii_interface.v` |
| AXI4 DMA + descriptor rings | P0 | Large | Adapt `edma_pbuf_axi_*`, `edma_axi_arbiter` |
| 1588 timestamp capture (SFD) + PPS | P0 | Medium | Adapt `gem_tsu` |
| VLAN insert/strip/filter + checksum offload | P1 | Small | Adapt `gem_filter`, `edma_csum` |
| Safety wrappers (ECC/parity/timeout) | P0 | Medium | Reuse `cdnsdru_asf_*`, `cdnsdru_ecc_*` |
| UVM base environment + sanity tests | P0 | Large | New (reuse Cadence sanity TB concepts) |

**Exit criteria**: 1 Gbps line-rate throughput, ping, basic 1588 timestamp test, lint/CDC clean.

### Phase 2 — TSN Endpoint
**Goal**: Add the time-sensitive networking features to the single- or dual-MAC endpoint.

| Work Item | Priority | Effort | Cadence Reuse |
|-----------|----------|--------|---------------|
| 802.1Qav CBS shaper | P0 | Medium | Adapt `edma_tfc_shaper` |
| 802.1Qbv TAS / EnST gate control list | P0 | Large | Adapt `edma_pbuf_tx_enst*` |
| 802.1Qbu frame preemption (MAC Merge) | P1 | Medium | Strongly reuse `gem_mmsl_*` |
| 802.1CB FRER (limited streams, e.g., 4) | P1 | Medium | Partial: sequence gen/check logic |
| 802.1Qci PSFP ingress policing | P1 | Medium | New |
| 802.1AB LLDP parser | P1 | Small | New (mostly software) |

**Exit criteria**: TSN scheduling verified with network analyzer, preemption interop with reference PHY, FRER duplicate elimination verified.

### Phase 3 — Switch + vPHC Virtualization
**Goal**: Integrate the L2/L3 Switch, dual PHC crossbar, and virtual PHC support.

| Work Item | Priority | Effort | Notes |
|-----------|----------|--------|-------|
| 2–4 port L2 Switch with static FDB | P0 | Large | Design from scratch; start small |
| Switch-level TAS GCL | P1 | Large | Extend endpoint EnST engine |
| Dynamic MAC learning + aging | P1 | Medium | Add after static FDB is stable |
| Dual PHC + per-port crossbar binding | P0 | Large | Key differentiator |
| vPHC Xen IO Ring / VM isolation | P1 | Large | New; requires hypervisor integration |
| Optional L3 route engine | P2 | Large | Defer if not needed for first tape-out |

**Exit criteria**: 4-port line-rate switching with <1 µs latency, gPTP transparent clock correction verified, vPHC isolation tested with two VMs.

### Phase 4 — Multi-Rate & Security Extensions
**Goal**: Scale to 2.5G/5G/10G, multi-PHY mux, and security accelerators.

| Work Item | Priority | Effort | Notes |
|-----------|----------|--------|-------|
| XGMAC 2.5G/5G/10G datapath | P1 | Large | New; 64-bit datapath |
| USXGMII / SGMII PCS adaptation | P1 | Large | Reuse 8b/10b blocks; 64b/66b custom |
| Multi-PHY mux and per-PHY clocking | P1 | Large | New |
| IPsec/SecOC/D-TLS/MACsec wrapper | P2 | Large | Interface only; crypto in CSS/HSE |
| EEE LPI, WoL, Deep Sleep | P2 | Medium–Large | Reuse EEE; defer WoL/Deep Sleep if possible |

---

## 4. Borrow vs. Design-from-Scratch Guidance

### 4.1 Strongly Reuse / Adapt from Cadence GEM GXL

These blocks are proven in the reference IP and map closely to the project's Phase 1/2 needs:

| Cadence Module(s) | What to Borrow | Where It Fits in This Project |
|-------------------|----------------|-------------------------------|
| `gem_mac`, `gem_tx`, `gem_rx`, `gem_filter` | 802.3 MAC TX/RX FSM, CRC, address/VLAN filtering, pause handling | `eth_mac` subsystem, Phase 1 |
| `gem_mii_bridge`, `rgmii.v`, `rmii_interface.v` | MII/RMII/RGMII timing, DDR primitives, CRS/COL handling | `eth_hsphy` subsystem, Phase 1 |
| `gem_mmsl_*` | 802.3br MAC Merge Layer (frame preemption, SMD/mCRC) | `eth_mtl` / MAC Merge, Phase 2 |
| `gem_tsu` | 1588 timestamp capture, PPS generation, TSU control | `eth_ptp` subsystem, Phase 1/2 |
| `edma_pbuf_axi_*`, `edma_axi_arbiter` | AXI DMA descriptor fetch/write, outstanding/pipelining management | `eth_dma` subsystem, Phase 1 |
| `edma_tfc_shaper`, `edma_pbuf_tx_enst*` | CBS shaper, TAS/EnST gate control | `eth_mtl` scheduler, Phase 2 |
| `cdnsdru_asf_parity_*`, `cdnsdru_ecc_*`, `cdnsdru_asf_trans_timeout_v1` | Parity generation/check, ECC encode/decode, transaction timeout | `eth_safety` subsystem, Phase 1 |
| `gem_pcs_enc8b10b`, `gem_pcs_dec8b10b` | 8b/10b encoding for SGMII | Optional `eth_hsphy` SGMII path, Phase 4 |

### 4.2 Design from Scratch

These features are either outside the scope of GEM GXL or require a fundamentally different architecture:

| Feature | Why It Must Be Custom | Key Design Risks |
|---------|----------------------|------------------|
| Multi-MAC wrapper (`MAC_COUNT=1..8`, mixed MAC/GMAC/XGMAC) | GEM GXL is single-port. | Clock/reset per MAC, global DMA arbitration, pin muxing. |
| Multi-rate 2.5G/5G/10G XGMAC + USXGMII | GEM GXL supports only up to 1G. | 64-bit datapath, 64b/66b PCS, timing closure. |
| L2/L3 Switch Core | GEM GXL has no switch. | FDB/VLAN scale, crossbar arbitration, HOL blocking, latency. |
| Dual PHC + Crossbar + vPHC | GEM GXL has one TSU only. | Synchronization, VM isolation, Xen IO Ring latency. |
| Global DMA channel pool | GEM GXL uses per-core DMA. | Channel-to-MAC mapping, QoS, fairness, deadlock avoidance. |
| Security accelerator wrapper (IPsec/SecOC/D-TLS) | GEM GXL has no such interface. | Protocol context management, packet-boundary signaling. |
| AVTP hardware parser / DMA queue routing | GEM GXL does not include AVTP. | Stream-ID matching, Presentation Time handling. |

### 4.3 Hybrid: Cadence as a "Known-Good" Core Inside a Wrapper

A pragmatic option for Phase 1 is to **instantiate a Cadence GEM-like single-MAC subsystem** (TX/RX MAC, DMA, TSU, safety primitives) as the first `eth_mac[0]` instance, wrapped by the project's parameter shell. As phases progress, this instance can be replaced or augmented with custom XGMAC/Switch logic. This approach:

- De-risks the base MAC/DMA/1588 functionality.
- Provides a working software driver model early.
- Lets the verification team build the UVM environment around a known-good DUT before the custom blocks are ready.

---

## 5. Immediate Next Steps (First 2 Weeks)

1. **Freeze the base SKU** in `ethernet_arch_spec.md` §1.4.4: one GMAC, RGMII/1G, no Switch, no vPHC, no security accelerators.
2. **Update `ethernet_interface_spec.md`** CSR address width to 14/15 bits and fix interrupt vector width.
3. **Populate `ethernet_top.sv`** with the full parameter list from the Arch Spec and a `generate`-based instantiation plan for Phase 1 modules.
4. **Create an RTL integration plan** that lists which Cadence modules will be adapted and which will be newly designed.
5. **Add SVA assertions** from `protocol_analysis.md` to the UVM verification plan before RTL coding proceeds.

---

*End of A9 Optimization Report*
