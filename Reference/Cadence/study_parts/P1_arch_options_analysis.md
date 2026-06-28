# GEM GXL Architecture & Configuration Analysis (Agent P1)

## 1. Top-Level Architecture

GEM implements a 10/100/1000 Mbps IEEE 802.3 Ethernet MAC, selectable half/full duplex, with MII/RMII/GMII/RGMII/SGMII PHY interfaces. The top-level blocks are:

| Block | Role |
|-------|------|
| **MAC** | TX/RX data path, preamble/FCS/pad insertion, address checking & filtering, loopback, jumbo frames, IP/TCP/UDP checksum offload, 802.1CB duplicate-frame elimination. |
| **PCS** | 1000BASE-X PCS, 8B/10B encode/decode, PCS TX/RX, auto-negotiation; PMA interface can be 10-bit or 20-bit. Optional and removable. |
| **REG_TOP** | APB control/status/statistics registers, MDIO interface, synchronization logic. |
| **DMA_TOP** | DMA TX/RX, descriptor/buffer management, AHB/AXI host arbitration; optional packet-buffer mode (external DPRAM/SPRAM) or internal FIFO mode. Can be omitted for a pure external-FIFO interface. |
| **TSU** | 102-bit IEEE 1588 timer (48 s + 30 ns + 24 sub-ns), programmable increment; optional external 94-bit TSU port. |
| **ASF** | Automotive Safety Features: fault logging/reporting, SRAM protection wrappers, parity, transaction timeout monitor. ASIL-B ready (SGS-TÜV) for a representative config. |

## 2. Key Configuration Parameter Matrix

| Parameter / `define` | Default / Example | Valid Range | Effect |
|----------------------|-------------------|-------------|--------|
| `gem_use_rgmii` | undefined (GMII/MII) | — | Selects RGMII instead of GMII/MII top interface. |
| `gem_include_rmii` | undefined | — | Adds a separate RMII port. |
| `gem_no_pcs` | undefined (PCS included) | — | Removes the PCS module. |
| `gem_pcs_legacy_if` / `gem_pcs_10b_if` / `gem_pcs_20b_if` | — | one of three | PMA interface style for PCS. Mutually exclusive. |
| `gem_int_loopback` | undefined | — | Includes internal loopback (requires tx/rx clock gating). |
| `gem_ext_fifo_interface` | undefined | — | Exposes FIFO IF and removes DMA. |
| `gem_tx_add_fifo_if` | undefined | — | Adds low-latency TX FIFO IF (DMA still present; mutually exclusive with `gem_ext_fifo_interface`). |
| `gem_host_if_soft_select` | undefined | — | Builds both FIFO IF and DMA; software selects after reset. |
| `gem_axi` | undefined (AHB) | — | Selects AXI host interface instead of AHB. |
| `gem_dma_bus_width` | example 128 | 32, 64, 128 | Max DMA AHB/AXI data width. 128 not available with AHB. |
| `gem_dma_addr_width` | — | 32, 64 | DMA address bus width. |
| `gem_emac_bus_width` | — | 32, 64, 128 | MAC/FIFO interface data width. In packet-buffer mode must be 64 when `gem_dma_bus_width=128`. |
| `gem_rx_pipeline_delay` | 10 | ≥7 (with internal filtering + DMA) | MAC RX pipeline depth; delays frame until filtering completes. |
| `gem_rx_pkt_buffer` / `gem_tx_pkt_buffer` | undefined (FIFO mode) | — | Use packet-buffer mode with external memory. |
| `gem_spram` | undefined (DPRAM) | — | Use single-port RAM in packet-buffer mode (AXI clock must be 2× MAC rate; pbuf data must be 128-bit). |
| `gem_pbuf_cutthru` | undefined | — | Enables partial store-and-forward (cut-through) operation. |
| `dma_priority_queue1` … `queue15` | undefined (single queue) | queue1–queue15 | Enables up to 16 TX/RX priority queues. |
| `gem_exclude_cbs` | undefined (CBS included) | — | Excludes 802.1Qav credit-based shaper on top two TX queues. |
| `gem_exclude_qbv` | undefined (EnST included) | — | Excludes 802.1Qbv scheduled-traffic module. |
| `gem_has_802p3br` | undefined | — | Enables 802.3br frame preemption; AHB not supported, dual MAC/DMA instantiated. |
| `gem_no_of_cb_streams` | undefined (0) | 1–16 | Number of 802.1CB stream functions. Must not exceed `num_type2_screeners`. |
| `gem_seq_history_len` | — | up to 64 | Vector-recovery history depth per 802.1CB stream. |
| `num_spec_add_filters` | 4 | 1–36 | Number of specific-address match registers. |
| `num_type1_screeners` / `num_type2_screeners` | example 16 | type1/type2 | RX priority-queue screening registers. Set to 0 by not defining. |
| `num_scr2_ethtype_regs` | example 8 | 0–8 | Ethertype match registers for type-2 screeners. |
| `num_scr2_compare_regs` | example 16 | 0–32 | Field-compare match registers for type-2 screeners. |
| `gem_tsu` | defined (TSU included) | — | Includes IEEE 1588 timestamp unit. |
| `gem_ext_tsu_timer` | undefined | — | Adds external 94-bit TSU port. |
| `gem_tsu_clk` | undefined (PCLK) | — | Clocks TSU from dedicated `tsu_clk` instead of `pclk`. |
| `gem_pbuf_lso` / `gem_pbuf_rsc` | undefined | — | Large Send Offload / Receive Side Coalescing. |
| `gem_asf_enable` | undefined | — | Master switch for Automotive Safety Features. |
| `gem_asf_ecc_sram` / `gem_asf_prot_tsu` / `gem_asf_prot_tx_sched` / `gem_asf_host_par` | undefined | — | ASF sub-features; only valid if `gem_asf_enable` is defined. |

## 3. Essential vs. Advanced Parameters

| Category | Parameters |
|----------|------------|
| **Minimal GMAC** | `gem_axi`, `gem_dma_bus_width`, `gem_dma_addr_width`, `gem_emac_bus_width`, `gem_rx_pipeline_delay`, `gem_use_rgmii`/`gem_include_rmii`, `gem_no_pcs`, `num_spec_add_filters`, `gem_tsu` (if 1588 required). |
| **Advanced / Optional** | Priority queues (`dma_priority_queue*`, `gem_exclude_cbs`), 802.1CB (`gem_no_of_cb_streams`, `gem_seq_history_len`), 802.1Qbv (`gem_exclude_qbv`), 802.3br (`gem_has_802p3br`), cut-through (`gem_pbuf_cutthru`), LSO/RSC, external FIFO interfaces (`gem_ext_fifo_interface`, `gem_tx_add_fifo_if`), snapshot statistics, PFC multi-quantum, ASF (`gem_asf_enable` and sub-options), external TSU. |

## 4. Important Dependencies & Rules

- **PCS interface style**: only one of `gem_pcs_legacy_if`, `gem_pcs_10b_if`, `gem_pcs_20b_if` may be defined, and only when PCS is present (`gem_no_pcs` not set).
- **FIFO/DMA host interface**: `gem_ext_fifo_interface`, `gem_tx_add_fifo_if`, and `gem_host_if_soft_select` are mutually exclusive; `gem_ext_fifo_interface` cannot be combined with packet-buffer mode.
- **Packet-buffer width**: if `gem_dma_bus_width=128`, `gem_emac_bus_width` must be 64 in packet-buffer mode; for non-packet-buffer DMA they are normally equal.
- **SPRAM**: requires `gem_rx_pbuf_data` and `gem_tx_pbuf_data` set to 128, and AXI/AHB clock running 2× the MAC data rate.
- **802.1CB streams**: `gem_no_of_cb_streams` must not exceed `num_type2_screeners`.
- **802.3br preemption**: forces AXI-only host interface and instantiates two MAC/DMA blocks internally.
- **ASF sub-options**: `gem_asf_ecc_sram`, `gem_asf_prot_tsu`, `gem_asf_prot_tx_sched`, `gem_asf_host_par` are valid only when `gem_asf_enable` is defined.

## 5. Reference FMEDA Configuration

The ASIL-B-ready FMEDA baseline used: no PCS, no RGMII, internal loopback, statistics included, four specific-address filters, 64-bit data bus, 32-bit addressing, AXI host, dual-port 16 KB TX/RX SRAM, three priority queues, no cut-through, no LSO, four type-1 / four type-2 screeners, 12 type-2 compare registers, 802.1Qav/Qbv included, TSU included, `tsu_clk` included.
