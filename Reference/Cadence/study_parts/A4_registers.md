# A4 Register Interface Analysis – Cadence GEM GXL (r1p12f4)

> **Agent**: A4 (Register Interface Expert)  
> **Scope**: Read-only analysis of the APB/CSR register space in `gem_gxl`  
> **Sources analyzed**:
> - `software/core_driver/src/emac_regs.h` (full register map)
> - `hdl/hdl_src/gem_registers.v`
> - `hdl/hdl_src/gem_reg_top.v`
> - `hdl/hdl_src/gem_reg_*.v` (DMA, interrupts, TSU, filters, scheduler, screeners, ENST, FRER, ASF, MMSL, PHY management, PCS)
> - `Docs/Arch/ethernet_interface_spec.md` (project interface spec, v1.1)

---

## 1. Executive Summary

The Cadence GEM GXL CSR is a single 32-bit APB slave space that integrates **MAC control, DMA descriptor management, 1588 timestamping, PCS management, statistics, TSN features (CBS, screeners, ENST, FRER, MMSL), and RAS/ASF safety registers** in one contiguous address map.  

Key take-aways for reuse in the current project:

| Item | Observation |
|------|-------------|
| Bus interface | APB (32-bit data, `paddr[11:2]`), not AXI4-Lite. The project Interface Spec defines an AXI4-Lite CSR slave. |
| Address map | Cadence-specific, fixed offsets (see §2). Not compatible with the DWC-style MAC/MTL/DMA/Switch offset scheme in the project spec. |
| Queue model | Up to 16 TX/RX DMA queues; queue pointers and per-queue interrupt enable/disable/mask/status registers. |
| 1588/PTP | Full TSU register set (seconds, nanoseconds, increment, comparison, captured timestamps). |
| TSN | CBS, Type-1/Type-2 screeners, 802.1Qbv ENST, 802.1CB FRER, MMSL are present in the CSR. |
| PCS | Internal PCS registers at `0x200` (Clause 22/AN). The project spec assumes external PHY interfaces (RGMII/SGMII/USXGMII/MDIO). |
| Safety/RAS | ASF fault-status registers and lockup-detection registers exist at the top of the map (`0x0E00`, `0x0Bxx`). |
| Secondary bank | The header also lists an `emac_*` register bank starting at `0x1000`. The analyzed RTL implements a single GEM register set; the `emac_` bank appears to be a second-instance/wrapper alias and is not instantiated in the examined Verilog. |

---

## 2. Grouped Address Map

The table below is derived from `emac_regs.h` and cross-checked against the APB decode logic in the `gem_reg_*` modules.  All addresses are byte offsets from the GEM APB base.

| Address range | Group | Key registers / notes |
|---------------|-------|-----------------------|
| `0x000`–`0x0FC` | **Network / MAC control & status** | `network_control`, `network_config`, `network_status`, `dma_config`, `transmit_status`, `receive_status`, `int_status/enable/disable/mask`, `phy_management`, `user_io_register`, `revision_reg` |
| `0x100`–`0x1BC` | **Statistics (MIB/RMON)** | TX/RX octet/frame/collision/error counters, histograms, checksum-error counters, `auto_flushed_pkts`. Presence gated by `p_edma_no_stats`. |
| `0x1BC`–`0x1FC` | **TSU / 1588 timer** | `tsu_timer_incr_sub_nsec`, `tsu_timer_msb_sec`, `tsu_strobe_*`, `tsu_timer_sec/nsec/adjust/incr`, PTP event/peer timestamp capture registers |
| `0x200`–`0x23C` | **PCS / Clause 22** | `pcs_control`, `pcs_status`, `pcs_phy_top/bot_id`, `pcs_an_adv`, `pcs_an_lp_base`, `pcs_an_exp`, `pcs_an_np_tx`, `pcs_an_lp_np`, `pcs_an_ext_status`. Optional (`p_edma_has_pcs`). |
| `0x260`–`0x29C` | **Pause / PFC / LPI** | `tx_pause_quantum1/2/3`, `pfc_status`, `rx_lpi`, `rx_lpi_time`, `tx_lpi`, `tx_lpi_time` |
| `0x2A0`–`0x2EC` | **AXI/DMA configuration** | `designcfg_debug1..12`, `axi_qos_cfg_0..3`, `axi_max_pipeline` |
| `0x300`–`0x3FC` | **Specific address filters 5..36** | `spec_add5..36_bottom/top`. Number present = `p_num_spec_add_filters` (1 is mandatory for pause source address). |
| `0x400`–`0x6BC` | **Per-queue interrupts & DMA pointers** | `int_q1..15_status/enable/disable/mask`, `transmit_q1..15_ptr`, `receive_q1..15_ptr`, `dma_rxbuf_size_q1..15` |
| `0x6C0`–`0x7FC` | **Screener Type-2 compare / ethertype** | `screening_type_2_ethertype_reg_0..7`, `type2_compare_0..31_word_0/1` |
| `0x800`–`0x87C` | **ENST (Qbv) start/on/off times** | `enst_start_time_q8..15`, `enst_on_time_q8..15`, `enst_off_time_q8..15` (header naming; RTL maps these to 8 ENST queue indices 0–7) |
| `0x880`–`0x884` | **ENST control** | `enst_control[7:0]` enable vector |
| `0x8A0`–`0x9BC` | **FRER (802.1CB)** | `frer_timeout`, `frer_red_tag`, per-stream `frer_control_*_a/b`, `frer_statistics_*_a/b` |
| `0xB00`–`0xB3C` | **RX queue flush** | `rx_q0..15_flush` |
| `0xB40`–`0xB84` | **Screener Type-2 rate limiting** | `scr2_reg0..15_rate_limit`, `scr2_rate_status` |
| `0xE00`–`0xE48` | **ASF (RAS / safety)** | `asf_int_status/raw_status/mask/test/fatal_nonfatal_select`, SRAM fault status/stats, transaction-timeout and protocol-fault status/mask |
| `0xF00`–`0xF28` | **MMSL** | `mmsl_control`, `mmsl_status`, `mmsl_err_stats`, counters, interrupt status/enable/disable/mask |
| `0x1000`–`0x1E48` | **Secondary `emac_*` bank** | Duplicate/alias of many core MAC/DMA/filter/TSU/scheduler registers. Not implemented in the examined RTL; treated as a wrapper/integration bank. |

---

## 3. Key Control / Status Registers and Bit Fields

### 3.1 `network_control` (offset `0x000`)

Implemented in `gem_reg_nwc.v`.

| Bit | Field | Function |
|-----|-------|----------|
| 0 | `loopback` | External PHY loopback enable |
| 1 | `loopback_local` | Internal MAC loopback enable |
| 2 | `enable_receive` | RX MAC enable |
| 3 | `enable_transmit` | TX MAC enable |
| 4 | `man_port_en` | MDIO management port enable |
| 5 | `clear_all_stats_regs` | Clear all statistics (pulse) |
| 6 | `inc_all_stats_regs` | Increment all statistics (test pulse) |
| 7 | `stats_write_en` | Allow software write to stats registers |
| 8 | `back_pressure` | Force half-duplex back-pressure (collisions) |
| 9 | `tx_start_pclk` | Toggle to start TX DMA / transmission |
| 10 | `tx_halt_pclk` | Toggle to halt TX DMA |
| 11 | `tx_pause_frame_req` | Toggle to send 802.3 pause frame |
| 12 | `tx_pause_frame_zero` | Toggle to send zero-quantum pause frame |
| 13 | `stats_take_snap` | Snapshot statistics (if snapshots enabled) |
| 14 | `stats_read_snap` | Read statistics snapshot |
| 15 | `store_rx_ts` | Store RX timestamp to descriptor |
| 16 | `pfc_enable` | Enable PFC pause frame reception |
| 17 | `tx_pfc_frame_req` | Toggle to send PFC pause frame |
| 18 | `flush_rx_pkt_pclk` | Flush RX packet buffer (toggle) |
| 19 | `tx_lpi_en` | Enable TX LPI (EEE) |
| 20 | `ptp_unicast_ena` | Enable PTPv2 IPv4 unicast detection |
| 21 | `alt_sgmii_mode` | Alternative SGMII configuration |
| 22 | `store_udp_offset` | Store TCP/UDP offset to memory |
| 23 | `ext_tsu_timer_en` | Use external TSU timer input |
| 24 | `one_step_sync_mode` | One-step 1588 sync timestamp insertion |
| 25 | `pfc_ctrl` | PFC multi-quantum control (if configured) |
| 26 | `ext_rxq_sel_en` | External RX queue selection enable |
| 27 | `oss_correction_field` | Update 1588 correction field in one-step sync |
| 28 | `sel_mii_on_rgmii` | Reconfigure RGMII pins for MII |
| 29 | `two_pt_five_gig` | 2.5 Gb/s mode indication |
| 30 | `ifg_eats_qav_credit` | IFG/IPG consumes CBS/Qav credit |
| 31 | – | Reserved / tied 0 |

### 3.2 `network_config` (offset `0x004`)

Implemented in `gem_registers.v`.

| Bit(s) | Field | Function |
|--------|-------|----------|
| 0 | `speed` | 0 = 10M / 1 = 100M |
| 1 | `full_duplex` | Full-duplex mode |
| 2 | `rm_non_vlan` | Discard non-VLAN frames |
| 3 | `jumbo_enable` | Enable jumbo frame reception |
| 4 | `copy_all_frames` | Promiscuous mode |
| 5 | `no_broadcast` | Drop broadcast frames |
| 6 | `multi_hash_en` | Multicast hash filtering enable |
| 7 | `uni_hash_en` | Unicast hash filtering enable |
| 8 | `rx_1536_en` | Accept 1536-byte frames |
| 9 | `ext_match_en` | External address match enable |
| 10 | `gigabit` | 1 Gb/s (or 2.5G with `two_pt_five_gig`) |
| 11 | `tbi` | Ten-Bit Interface (PCS) mode |
| 12 | `retry_test` | Test mode (must be 0 for normal operation) |
| 13 | `pause_enable` | React to received 802.3 pause frames |
| 14-15 | – | Reserved |
| 16 | `check_rx_length` | Enable length-field checking |
| 17 | `strip_rx_fcs` | Strip RX FCS before DMA write |
| 18-20 | `mdc_clock_div[2:0]` | MDC clock divider from PCLK |
| 21-22 | `dma_bus_width[1:0]` | DMA bus width encoding (32/64/128) |
| 23 | `rx_no_pause_frames` | Do not copy pause frames to memory |
| 24 | `rx_toe_enable` | RX checksum offload enable |
| 25 | `en_half_duplex_rx` | Allow RX while TX in half-duplex |
| 26 | `rx_no_crc_check` | Disable RX CRC check |
| 27 | `sgmii_mode` | PCS configured for SGMII |
| 28 | `stretch_enable` | Enable IPG stretching |
| 29 | `rx_bad_preamble` | Accept frames with bad preamble |
| 30 | `ign_ipg_rx_er` | Ignore `rx_er` when `rx_dv` low |
| 31 | `uni_direct_en` | PCS uni-directional mode |

### 3.3 `dma_config` (offset `0x010`)

Implemented in `gem_reg_dma.v`.  The meaning of several bits is configuration-dependent (`p_edma_tx_pkt_buffer`, `p_edma_axi`, `p_edma_addr_width`).

| Bit(s) | Field | Function |
|--------|-------|----------|
| 4:0 | `ahb_burst_length` | AHB/AXI maximum burst length (one-hot: 1/2/4/8/16 beats) |
| 5 | `hdr_data_splitting_en` | Header/data splitting enable |
| 6-7 | `endian_swap` | Endian-swap control |
| 8-9 | `rx_pbuf_size` | RX packet-buffer size encoding |
| 10 | `tx_pbuf_size` | TX packet-buffer size |
| 11 | `tx_pbuf_tcp_en` | TX TCP checksum offload enable |
| 12 | `inf_last_dbuf_size_en` | Last descriptor buffer is infinite |
| 13 | `crc_error_report` | Jumbo-length/CRC-error reporting |
| 14-15 | – | Reserved / parity-only (masked from functional read) |
| 16-23 | `rx_dma_buf_size_q0` | RX buffer size for queue 0 (bytes/64) |
| 24 | `force_discard_on_err` | Discard PBUF contents after AHB error |
| 25 | `force_max_ahb_burst_rx` | Force RX to always use max burst |
| 26 | `force_max_ahb_burst_tx` | Force TX to always use max burst |
| 27 | – | Reserved / parity-only |
| 28 | `rx_bd_extended_mode_en` | Extended RX buffer descriptors |
| 29 | `tx_bd_extended_mode_en` | Extended TX buffer descriptors |
| 30 | `dma_addr_bus_width` | 0 = 32-bit addresses, 1 = 64-bit |
| 31 | – | Reserved / parity-only |

### 3.4 `int_status` (offset `0x024`) – queue 0

Per-queue interrupt status/mask/enable/disable are at offsets `0x400`/`0x600`/`0x620`/`0x640`.  The bit definitions below come from `gem_reg_int_sts.v`.

| Bit | Interrupt source |
|-----|------------------|
| 0 | PHY management (MDIO) transfer complete |
| 1 | RX frame complete |
| 2 | RX buffer not ready |
| 3 | TX buffers exhausted |
| 4 | TX underrun |
| 5 | TX too many retries / late collision (gigabit) |
| 6 | TX buffer exhausted mid-frame / frame too large / AXI disable |
| 7 | TX frame complete |
| 8 | Reserved |
| 9 | PCS link-change / link-fault change |
| 10 | RX DMA overrun |
| 11 | AXI/AHB bus error (RX/TX) |
| 12 | RX pause frame with non-zero quantum |
| 13 | TX pause timer reached zero |
| 14 | TX pause/PFC frame transmitted |
| 15 | External interrupt input rising edge |
| 16 | PCS autonegotiation complete |
| 17 | PCS next-page data ready |
| 18 | PTP delay_req received |
| 19 | PTP sync received |
| 20 | PTP delay_req transmitted |
| 21 | PTP sync transmitted |
| 22 | PTP pdelay_req received |
| 23 | PTP pdelay_resp received |
| 24 | PTP pdelay_req transmitted |
| 25 | PTP pdelay_resp transmitted |
| 26 | TSU seconds increment |
| 27 | LPI indication changed |
| 28 | Wake-on-LAN pulse |
| 29 | TSU timer comparison match |
| 30 | RX lockup detected |
| 31 | TX lockup detected |

### 3.5 `transmit_status` (`0x014`) and `receive_status` (`0x020`)

`transmit_status`:

| Bit | Field |
|-----|-------|
| 0 | TX buffers exhausted |
| 1 | Collision occurred |
| 2 | Too many retries |
| 3 | TX DMA `go` |
| 4 | TX buffer exhausted mid-frame |
| 5 | TX frame complete |
| 6 | TX underrun |
| 7 | Late collision (gigabit) |
| 8 | TX AHB/AXI error |
| 9 | TX MAC lockup detected |
| 10 | TX DMA lockup detected |

`receive_status`:

| Bit | Field |
|-----|-------|
| 0 | RX buffer not ready |
| 1 | RX frame complete |
| 2 | RX overrun |
| 3 | RX AHB/AXI error |
| 4 | RX MAC lockup detected |
| 5 | RX DMA lockup detected |

### 3.6 `phy_management` (offset `0x034`)

Implemented in `gem_reg_phy_man.v`.

| Bit(s) | Usage |
|--------|-------|
| 31:28 | MDIO opcode (Clause 22: `01` = write, `10` = read; Clause 45: `0011`) |
| 27:23 | PHY address |
| 22:18 | Register address (Clause 22) / dev-type (Clause 45) |
| 17:16 | Turn-around field |
| 15:0 | Write data / read data |

Writing this register starts an MDIO transaction; `network_control.man_port_en` must be set.  Bit 0 of `int_status` is asserted when the transfer completes.

### 3.7 PCS registers (`0x200`–`0x23C`)

Implemented in `gem_pcs_registers.v`.

| Register | Offset | Notes |
|----------|--------|-------|
| `pcs_control` | `0x200` | Bit 15 = reset, 14 = loopback, 12 = AN enable, 9 = AN restart, 8 = full-duplex (hardwired), 7 = collision test |
| `pcs_status` | `0x204` | Bit 5 = AN complete, 4 = remote fault, 3 = AN capable, 2 = link state, 1:0 = `01` |
| `pcs_phy_top_id` | `0x208` | PHY ID high |
| `pcs_phy_bot_id` | `0x20C` | PHY ID low |
| `pcs_an_adv` | `0x210` | Local advertised abilities |
| `pcs_an_lp_base` | `0x214` | Link-partner base page |
| `pcs_an_exp` | `0x218` | AN expansion (`np_capable`, `page_rx`) |
| `pcs_an_np_tx` | `0x21C` | Next page to transmit |
| `pcs_an_lp_np` | `0x220` | Link-partner next page |
| `pcs_an_ext_status` | `0x23C` | Returns `0x8000` |

---

## 4. Essential vs Optional Register Groups

| Group | Essential? | Config / comment |
|-------|:----------:|------------------|
| Network control / config / status | **Essential** | Always present; MAC enable, loopback, duplex, speed, filters. |
| DMA config + queue pointers | **Essential** | Required for descriptor-ring operation. Number of queues = `p_edma_queues`. |
| Interrupt status / enable / mask | **Essential** | Global + per-queue registers gated by queue count. |
| TX/RX status registers | **Essential** | Always present. |
| PHY management | **Essential** | Required for MDIO PHY access. |
| Statistics | Optional | Can be removed with `p_edma_no_stats = 1`. |
| TSU / 1588 | Optional | Gated by `p_edma_tsu`. |
| PCS registers | Optional | Gated by `p_edma_has_pcs` / `p_edma_no_pcs`. |
| Pause/PFC/LPI | Optional | PFC requires `p_edma_pfc_multi_quantum`; LPI requires EEE support. |
| CBS / scheduler / bandwidth limits | Optional | CBS excluded by `p_edma_exclude_cbs`; scheduler valid only with multi-queue. |
| Screeners (Type-1/Type-2) | Optional | Counts set by `p_num_type*_screeners`, `p_num_scr2_*`. |
| ENST (Qbv) | Optional | Valid for queues ≤ 8. |
| FRER (802.1CB) | Optional | `p_gem_num_cb_streams` controls number of streams. |
| MMSL | Optional | Separate APB-like sub-block at `0xF00`. |
| ASF / lockup detection | Optional | Safety/RAS features, gated by `p_edma_asf_*` and packet-buffer config. |
| AXI QoS / 64-bit address / extended BD | Optional | Depend on `p_edma_axi`, `p_edma_addr_width`, `p_edma_tx_pkt_buffer`. |
| `emac_*` bank | Optional / wrapper | Not instantiated in the examined RTL; used for a second MAC instance or wrapper alias. |

---

## 5. Comparison with Project Interface Spec

The current project Interface Spec (`Docs/Arch/ethernet_interface_spec.md`, v1.1) defines a **32-bit AXI4-Lite CSR slave** with a DWC-style partitioned address map:

| Project Spec region | Project offset | GEM equivalent | Comment |
|---------------------|----------------|----------------|---------|
| `MAC_Configuration` | `0x0000` | `network_control`, `network_config`, `network_status` | Functions overlap but register bit layout differs completely. |
| `MAC_Extended_Configuration` / `Packet_Filter` / `VLAN_Tag` | `0x0004`–`0x00D0` | `network_config`, hash/specific-address/type filters, `stacked_vlan` | GEM combines filtering in one block; project spec separates them. |
| `Timestamp_Control` / `System_Time_*` / `PPS_Control` | `0x00D0`–`0x0100` | TSU registers (`0x1BC`–`0x1FC`) | Project spec is PHC-oriented; GEM uses a Cadence TSU layout. |
| `MTL_Operation_Mode` / `TxQ0/RxQ0` / `CBS` / `EST` | `0x0200`–`0x050C` | `dma_config`, `cbs_control`, `tx_sched_ctrl`, `dwrr_ets_control`, ENST registers | Both have CBS and scheduling, but addresses and register shapes differ. |
| `DMA_Mode` / `DMA_CHx_*` | `0x1000`–`0x13xx` | `dma_config`, per-queue pointer/status/interrupt registers | Project uses channel ring-length/tail-ptr registers; GEM uses queue base pointers + BD rings. |
| `Switch_Control` / `FDB` | `0x3000`–`0x3004` | **Not present** in GEM. | Project spec assumes an L2 switch; GEM is a single-port MAC. |
| `Security_Control` | `0x3800` | **Not present** in GEM. | Project spec adds MACsec/IPsec/SecOC/D-TLS wrapper registers. |
| `EEE_Control` | `0x3900` | `tx_lpi`, `rx_lpi`, LPI time/status registers | GEM has LPI registers, but not at the project offset. |
| `Safety_ECC_Status` / `FSM_Parity` / `Timeout` | `0xF000`–`0xF010` | ASF registers (`0x0E00`) and lockup config (`0x068`–`0x070`) | Both have RAS/safety concepts, but register maps differ. |
| `vPHC` | `0x1_1000` | **Not present** in GEM. | Project adds virtual-PHC per-VM CSR bank. |

### 5.1 Key differences

1. **Bus protocol**: GEM uses APB; the project spec mandates AXI4-Lite.  A protocol bridge or wrapper is required to reuse GEM inside the project.
2. **Address map**: There is no 1:1 mapping.  The project’s `MAC/MTL/DMA/Switch/Security/vPHC` partition is not reflected in GEM.
3. **Feature gaps in GEM** (relative to project spec):
   - No L2 switch / FDB registers.
   - No security-accelerator wrapper (MACsec/IPsec/SecOC/D-TLS) registers.
   - No virtual-PHC (vPHC) per-VM bank.
4. **Extra features in GEM** (not in project spec):
   - Internal PCS management registers (Clause 22 AN).
   - 802.1CB FRER and MMSL registers.
   - Per-queue bandwidth-rate-limit and Type-1/Type-2 screener registers.
   - ASF fault-reporting registers.
5. **Interrupt model**: GEM exposes one interrupt line per queue (`ethernet_int[15:0]`) plus aggregated status registers.  The project spec uses a single 16-bit `irq_vector[15:0]`.

### 5.2 Reuse implications

- If GEM GXL is adopted as the MAC/DMA core, the **AXI4-Lite CSR interface in the project spec must be translated to GEM’s APB transactions** (address remap + protocol conversion).
- The project’s expected **Switch, Security, and vPHC register blocks** must be implemented outside GEM (or the spec must be relaxed).
- The GEM-specific TSN blocks (CBS, screeners, ENST, FRER, MMSL) can be used to enhance the project’s TSN support if required, but they need to be exposed in the new address map.
- Safety/ASF registers can be mapped to the project’s `Safety_*` address region, but the bit/field layout will be GEM-specific.

---

## 6. Recommendations

1. **Create a GEM-to-project address-translation layer** that maps the AXI4-Lite offsets from the Interface Spec to GEM APB offsets.  Reserve “passthrough” regions for GEM-native features.
2. **Decide feature scope**:
   - If Switch/Security/vPHC are mandatory, plan separate RTL blocks; do not expect GEM to provide them.
   - If 802.1CB FRER / MMSL / internal PCS are not needed, disable them via parameters to save area and simplify the CSR map.
3. **Standardize interrupt integration**: combine GEM’s per-queue `ethernet_int[15:0]` into the project’s `irq_vector[15:0]` and add any missing aggregated sources (switch, security, vPHC).
4. **Update the Interface Spec** if GEM is selected, documenting the translated CSR offsets and which project features are implemented inside GEM vs. external wrappers.
5. **Verify parameter defaults** (`p_edma_queues`, `p_edma_tsu`, `p_edma_has_pcs`, `p_edma_exclude_cbs`, `p_num_spec_add_filters`, etc.) because they directly determine which optional registers exist and which addresses return `perr`.

---

*Analysis complete. No source files were modified.*
