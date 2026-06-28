# A2 — MAC Core Datapath Analysis (Cadence GEM GXL)

**Agent**: A2 (MAC Core Expert)  
**Scope**: Read-only analysis of the Cadence GEM GXL Ethernet MAC datapath RTL.  
**Files analyzed**: `gem_mac.v`, `gem_tx.v`, `gem_tx_state.v`, `gem_rx.v`, `gem_filter.v`, `gem_loop.v`, `gem_mii_bridge.v`, `rgmii.v`, `rmii_interface.v` under `Reference/Cadence/gem_gxl_det0104_r1p12f4/gem_gxl/hdl/hdl_src/`.  
**Cross-reference**: IEEE 802.3-2022 MAC study at `Reference/8023-2022/studies/8023-2022_MAC_study.html`.

---

## 1. Executive Summary

The Cadence GEM GXL MAC is a full-featured 10/100/1000 Mb/s Ethernet MAC that implements the IEEE 802.3 MAC sublayer. The analyzed RTL shows a classic **two-clock (tx_clk / rx_clk) split datapath** with:

- A transmit path (`gem_tx.v` + `gem_tx_state.v`) that fetches frame data from a FIFO, prepends preamble/SFD, optionally pads, computes/appends CRC-32, handles CSMA/CD in half duplex, and emits MII/GMII/PCS data.
- A receive path (`gem_rx.v` + `gem_filter.v`) that deserializes MII/GMII/PCS data, strips preamble/SFD, realigns bytes, filters by destination/type, optionally strips FCS, computes CRC, and pushes data to a FIFO.
- A loopback module (`gem_loop.v`) that retimes TX data back into the RX path.
- PHY interface adapters: `gem_mii_bridge.v` (GMII/MII/PCS mux), `rgmii.v` (RGMII DDR), and `rmii_interface.v` (RMII 50 MHz reference).

The implementation is highly configurable (parameters for DMA width, TSU, screeners, FRER, ASF parity, PCS, RGMII, RMII, etc.). This note focuses on the **MAC datapath essentials** and flags which features are optional for a minimal MAC.

---

## 2. Top-Level MAC Integration (`gem_mac.v`)

`gem_mac.v` is the integration wrapper. It instantiates:

| Submodule | Role |
|-----------|------|
| `gem_tx_wrap` / `gem_tx.v` | Transmit datapath and MAC control |
| `gem_rx.v` | Receive datapath and filtering |
| `gem_loop` | Internal GMII/MII loopback (parameterized by `p_edma_int_loopback`) |

Key observations:

- TX and RX each have their own clock/reset (`tx_clk`/`n_txreset`, `rx_clk`/`n_rxreset`).
- Loopback is performed **at the GMII/MII boundary**: TX data (`txd_to_loop`, `tx_en_to_loop`, `tx_er_to_loop`) is sampled on the **falling edge of `tx_clk`** (`n_tx_clk`/`n_ntxreset`) and presented back to `gem_rx.v` as `rxd_from_loop`, `rx_dv_from_loop`, `rx_er_from_loop`.
- PCS interface is selected when `tbi=1`; otherwise GMII/MII is used.
- `gem_tx_wrap` hides the queue scheduler / credit-based shaping logic; the actual MAC state machine lives in `gem_tx_state.v` instantiated inside `gem_tx.v`.

---

## 3. Transmit Datapath (`gem_tx.v` / `gem_tx_state.v`)

### 3.1 TX State Machine (`gem_tx_state.v`)

`gem_tx_state` is a 16-state FSM in the `tx_clk` domain. It is the **heart of the MAC transmit media-access manager**.

#### State Encoding

| State | Encoding | Description |
|-------|----------|-------------|
| `INTERFRAME_GAP_INIT` | 4'b0000 | Initial IFG after reset |
| `IDLE` | 4'b0001 | Waiting for a frame; carrier deference |
| `PREAMBLE` | 4'b0010 | Transmitting 7-byte preamble |
| `PREAMBLE_COLL` | 4'b0011 | Collision during preamble — finish preamble+SFD then jam |
| `SFD_COLL` | 4'b0100 | Collision flagged at SFD boundary — enter jam |
| `JAM_ST` | 4'b0101 | Jam sequence after collision |
| `SFD` | 4'b0110 | Transmitting Start Frame Delimiter |
| `DATA` | 4'b0111 | Transmitting frame payload |
| `CRC` | 4'b1000 | Transmitting FCS (CRC-32) |
| `BACKOFF_ST` | 4'b1001 | Waiting for backoff counter |
| `INTERFRAME_GAP_BOFF` | 4'b1010 | IFG after backoff |
| `INTERFRAME_GAP_BURST` | 4'b1011 | Carrier extension within IFG for gigabit half-duplex bursting |
| `INTERFRAME_GAP_ST` | 4'b1100 | Normal IFG after successful frame |
| `FILL` | 4'b1101 | Padding to 60 bytes |
| `CARRIER_EXTEND` | 4'b1110 | Carrier extension to meet slot time |
| `JAM_CE` | 4'b1111 | Jam during carrier extension |

#### Simplified State-Flow Table

| From State | Condition | To State | Outputs / Notes |
|------------|-----------|----------|-----------------|
| `INTERFRAME_GAP_INIT` | IFG done | `IDLE` | — |
| `IDLE` | `frame_ready` | `PREAMBLE` | `start_frame=1` |
| `IDLE` | `crs_sync` | `INTERFRAME_GAP_ST` | Deferral |
| `PREAMBLE` | `last_preamble` and no collision | `SFD` | — |
| `PREAMBLE` | collision, `last_preamble` | `SFD_COLL` | Finish SFD, then jam |
| `PREAMBLE` | collision, not last | `PREAMBLE_COLL` | — |
| `SFD` | collision | `JAM_ST` | `start_jam=1` |
| `SFD` | no collision | `DATA` | — |
| `DATA` | collision | `JAM_ST` | `start_jam=1` |
| `DATA` | `~last_data` | `DATA` | — |
| `DATA` | `tx_no_crc` and gigabit half-duplex short frame | `CARRIER_EXTEND` | — |
| `DATA` | `tx_no_crc` and burst possible | `INTERFRAME_GAP_BURST` | — |
| `DATA` | `tx_no_crc` otherwise | `INTERFRAME_GAP_ST` | End frame |
| `DATA` | `within_60bytes` | `FILL` | Pad required |
| `DATA` | otherwise | `CRC` | Append FCS |
| `FILL` | `~within_60bytes` | `CRC` | — |
| `CRC` | `~last_crc` | `CRC` | — |
| `CRC` | gigabit half-duplex short frame | `CARRIER_EXTEND` | — |
| `CRC` | gigabit half-duplex burst | `INTERFRAME_GAP_BURST` | — |
| `CRC` | otherwise | `INTERFRAME_GAP_ST` | End frame |
| `JAM_ST` | jam done, last attempt/underrun/gigabit late collision | `INTERFRAME_GAP_ST` | `end_frame=1` |
| `JAM_ST` | jam done, retry possible | `INTERFRAME_GAP_BOFF` | `load_backoff=1` |
| `BACKOFF_ST` / `INTERFRAME_GAP_BOFF` | backoff done & frame ready | `PREAMBLE` | Retry |
| `CARRIER_EXTEND` | slot time done & frame ready | `INTERFRAME_GAP_BURST` | Burst continue |
| `CARRIER_EXTEND` | slot time done & no frame | `INTERFRAME_GAP_ST` | — |

> **Key RTL insight**: The FSM uses a `data_type` output (4 bits) to tell `gem_tx.v` what data to place on `txd_next`. This cleanly separates sequencing from datapath muxing.

### 3.2 TX Datapath Operations

#### Preamble / SFD Generation

```verilog
// gem_tx.v, data_type mux
TYPE_PREAMBLE: txd_next = tx_byte_mode ? 8'h55 : 8'h05;   // 0x55 bytes or 0x5 nibbles
TYPE_SFD:      txd_next = tx_byte_mode ? 8'hD5 : 8'h0D;   // SFD pattern
```

- `preamble_cnt` starts at `4'hE` (14 nibbles) in 10/100 mode and counts down to 0, signaling `last_preamble`.
- In `tx_byte_mode` (gigabit/PCS) it starts at `4'h6` (7 bytes).
- Matches IEEE 802.3: 7 × `0x55` + 1 × `0xD5`.

#### Data Buffering and FIFO Interface

- `gem_tx.v` contains a buffer state machine (`R_BUF_INIT`, `R_RD_PEND_INIT`, `R_FRAME_RDY`, `R_READ`, `R_RD_PEND`, etc.) that fetches 32/64/128-bit words from the TX FIFO.
- `no_of_valid_bytes` is decoded from `tx_r_mod` and `dma_bus_width`.
- `transmit_data_buf` is a shift register (width depends on TSU parameter) that feeds one byte/nibble per clock to the PHY.
- `tx_r_rd` is asserted when the buffer has ≤ 4 bytes (or ≤ 5 in byte mode) remaining.

#### FCS / CRC Generation

- CRC is computed by a cascade of 8 `gem_stripe` modules (one per data bit), effectively an LFSR with polynomial `0x04C11DB7`.
- Initial value: `32'hFFFFFFFF`.
- Update happens during `TYPE_DATA` and `TYPE_FILL`.
- On the wire the CRC bytes are **bit-inverted** and transmitted MSB of each byte first:

```verilog
TYPE_CRC:
  txd_next[7:0] = {~crc[24],~crc[25],~crc[26],~crc[27],
                   ~crc[28],~crc[29],~crc[30],~crc[31]};  // byte mode
```

- In nibble mode only the top 4 bits of `crc` are sent per clock.

#### Padding

- `tx_frame_length` increments during SFD, DATA, FILL, and CRC.
- `within_60bytes = tx_frame_length < 14'h003C`.
- When data ends before 60 bytes, the FSM enters `FILL` and transmits zeros; the CRC is computed over the pad bytes too.
- This guarantees a 64-byte minimum frame including FCS.

#### InterFrame Gap

- `interframe_cnt` counts 96 bit times.
- In `tx_byte_mode` it increments by 1 per clock; in nibble mode by 1 every other clock.
- Deferral: if `crs_sync` is asserted in the **first 32 bit times** of the IFG, the counter resets (`first_frame` must also be set). This matches the IEEE 802.3 robustness measure.
- Optional **IPG stretching** is supported via `stretch_enable`/`stretch_ratio` (full duplex only).

#### CSMA/CD and Backoff

- Collision input `col` is synchronized to `tx_clk` as `coll_sync`; gated by `~full_duplex`.
- Jam counter: 32 bits (3'h3 in byte mode, 3'h7 in nibble mode).
- Backoff uses a pseudo-random 16-bit LFSR (`random1`) initialized from `spec_add1[15:0]`, plus a second LFSR (`random2`) to reduce correlation.
- Backoff range follows truncated binary exponential backoff: slotTime × `random[0..attempts-1]` capped at attempt 10.
- `attemptLimit` = 16 (`last_attempt` when `attempts == 4'hF`).
- Late-collision threshold: 143 nibble clocks (10/100) or 527 byte clocks (gigabit).

#### Pause Frames

- `gem_tx.v` can generate **802.3 PAUSE** and **PFC** frames internally:
  - Destination address: `01:80:C2:00:00:01`.
  - Source address from `spec_add1`.
  - Length/Type = `0x8808`.
  - Opcode `0x0001` for PAUSE, `0x0101` for PFC.
  - Pause quantum from `tx_pause_quantum*` registers.
- Pause request can come from pins, registers, or automatic RX-fill-level logic.

---

## 4. Receive Datapath (`gem_rx.v` / `gem_filter.v`)

### 4.1 RX State Machine

`gem_rx.v` contains a 4-state receive FSM:

| State | Encoding | Description |
|-------|----------|-------------|
| `RX_IDLE` | 2'b00 | Waiting for carrier / receive enable |
| `RX_PREAMBLE` | 2'b01 | Receiving preamble, looking for SFD |
| `RX_DATA` | 2'b10 | Receiving frame data |
| `RX_CARR_EXT` | 2'b11 | Receiving carrier extension (gigabit half duplex) |

#### Transitions

| From | To | Condition |
|------|----|-----------|
| `RX_IDLE` | `RX_PREAMBLE` | `rx_dv_int_le` (rising edge of RX_DV) |
| `RX_PREAMBLE` | `RX_DATA` | `start_of_data` = valid preamble + valid SFD + RX_DV |
| `RX_PREAMBLE` | `RX_IDLE` | Bad preamble or RX_DV trailing edge |
| `RX_DATA` | `RX_CARR_EXT` | `start_of_carr_ext` = gigabit half-duplex + RX_ER rising |
| `RX_DATA` | `RX_IDLE` | `end_of_frame` (RX_DV falling, no carrier extension) |
| `RX_CARR_EXT` | `RX_PREAMBLE` | New RX_DV rising edge (burst) |
| `RX_CARR_EXT` | `RX_IDLE` | `end_of_frame` (RX_ER falling or slot time done) |

### 4.2 RX Data Deserialization and Re-alignment

- `gem_rx.v` accepts data from GMII/MII (`rxd_gmii` 8-bit + parity), PCS (`rxd_pcs` 16-bit), or TBI/SGMII.
- It builds a 16-bit current-data buffer (`curr_data_16`) using a nibble pointer to handle MII (4-bit) input.
- Preamble and SFD are detected; valid data bytes are extracted into `curr_data_align`.
- An alignment buffer (`new_data_align`) re-forms 16-bit words after stripping preamble/SFD.
- A **configurable pipeline delay** (`p_gem_rx_pipeline_delay`) gives the filter time to decide whether to keep the frame before it reaches the FIFO.

### 4.3 Address / Type Filtering (`gem_filter.v`)

`gem_filter.v` implements the IEEE 802.3 receive-address filtering function:

| Filter Type | Mechanism |
|-------------|-----------|
| Broadcast | `&ext_da` (all 1s), gated by `no_broadcast` |
| Multicast | `ext_da[0] == 1` |
| Unicast hash | `~ext_da[0] & hash[hash_index] & uni_hash_en` |
| Multicast hash | `ext_da[0] & hash[hash_index] & multi_hash_en` |
| Specific address | Up to `p_num_spec_add_filters` 48-bit filters with per-byte mask; filter 0 also supports `mask_add1` |
| Specific type | Four 16-bit type/length comparisons (`spec_type1..4`) |
| External match | Four `ext_match*` inputs sampled in a window after DA |
| Copy all | `copy_all_frames` bypasses filtering |
| VLAN only | `rm_non_vlan` blocks non-VLAN frames |
| Pause frames | Detected by DA = `01:80:C2:00:00:01` (or specific address 1 match) |

Hash index generation:

```verilog
hash_index[0] = ext_da[0]  ^ ext_da[6]  ^ ... ^ ext_da[42];
...
hash_index[5] = ext_da[5]  ^ ext_da[11] ^ ... ^ ext_da[47];
```

This is the standard 6-bit XOR hash over the destination address.

### 4.4 RX FCS Handling

- CRC is computed on aligned data as it exits the pipeline using 16 `gem_stripe` instantiations (`rx_stripe_out0..15`).
- Good-frame residue is `32'hC704DD7B` (Cadence implementation style, matching the study's standard CRC-32 note).
- `strip_rx_fcs` removes the last 4 bytes from the data pushed to the FIFO by looking ahead in the pipeline (`pipeline_delay_fcs1/2`).
- `rx_no_crc_check` can disable CRC checking.

### 4.5 Frame-Length Checks

| Check | Threshold | Note |
|-------|-----------|------|
| Minimum frame size | 64 bytes | `too_short = not_min_frame_size \| ~slot_time_saved` |
| Normal max | 1518 bytes | `frm_byte_cnt == 14'h05EE` triggers `too_long` |
| 1536-byte mode | 1536 bytes | `rx_1536_en` |
| Jumbo mode | configurable (`jumbo_max_length`) | `jumbo_enable` |
| Length-field check | compare `length_field_saved` vs `frm_byte_cnt` | `check_rx_length` |

### 4.6 Pause Reception

- 802.3 PAUSE and PFC frames are decoded in `gem_rx_decode` (instantiated inside `gem_rx.v`).
- `new_pause_time` and `new_pause_tog` are sent to `gem_tx.v` to halt transmission.
- Per-priority PFC counters are maintained in `gem_rx_pfc_counter`.

---

## 5. FCS / CRC Details

### 5.1 Polynomial and Implementation

- Polynomial: `G(x) = x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1` (`0x04C11DB7`).
- TX and RX both use the `gem_stripe` module to implement the serial LFSR one bit at a time.
- TX CRC is initialized to `0xFFFFFFFF` and reset whenever `data_type != TYPE_HOLD` outside DATA/FILL/CRC.
- RX CRC is initialized to `0xFFFFFFFF` and updated on every `new_pipeline_data`.

### 5.2 Bit/Byte Ordering on Wire

- Data bytes are transmitted **LSB first** on the wire.
- The FCS bytes are transmitted with the **MSB of each byte first** (see `~crc[24]` as bit 7 of first CRC byte in byte mode).
- This matches IEEE 802.3 Clause 3.2.9.

---

## 6. Padding and InterFrame Gap

### 6.1 Padding

- Pad is inserted only when the frame data (DA+SA+Length/Type+client data) is shorter than 60 bytes.
- `within_60bytes` flag controls entry into `FILL` state.
- Pad bytes are zeros; CRC is computed over pad bytes.

### 6.2 InterFrame Gap

- 96 bit times minimum.
- Implemented as a counter (`interframe_cnt`) in `tx_clk` domain.
- Deferral resets the counter if carrier is sensed in the first 32 bit times (only when `first_frame` is set, not during bursting).
- IPG stretching extends the gap proportionally to the previous frame length.

---

## 7. Loopback (`gem_loop.v`)

`gem_loop.v` is a simple retiming wrapper:

- When `loopback_local` is high:
  - TX outputs to the PHY are forced to zero / inactive (`tx_en_from_loop=0`, `txd_from_loop=0`).
  - TX data is registered on the **falling edge of `tx_clk`** (`n_tx_clk`) into `rxd_looped`, `rx_er_looped`, `rx_dv_looped`.
  - These retimed values are presented back to `gem_rx.v` as the RX inputs.
  - `crs_from_loop` follows `tx_en_to_loop` so the TX MAC sees its own carrier.
- When `loopback_local` is low, signals pass through transparently.

This provides **internal loopback at the GMII/MII boundary**, useful for self-test.

---

## 8. PHY Interface Adaptation

### 8.1 `gem_mii_bridge.v` — MII/GMII/PCS Mux

`gem_mii_bridge.v` is the central PHY-interface bridge. It conditionally instantiates:

| Interface | Control |
|-----------|---------|
| GMII/MII | Default when `p_edma_using_rgmii == 0` |
| RGMII | `p_edma_using_rgmii == 1` |
| RMII | `p_edma_include_rmii == 1` |
| PCS (TBI/SGMII) | `p_edma_has_pcs == 1` |

Key functions:

- Selects between `rxd_int` from RGMII/RMII or top-level MII inputs.
- Generates `rxd_to_mac` (8-bit to MAC RX), `rx_dv_to_mac`, `rx_er_to_mac`, `col_to_mac`, `crs_to_mac`.
- Routes TX data from MAC to RGMII, RMII, or GMII/MII outputs.
- Generates parity for `rxd_to_mac` when ASF DAP protection is enabled.
- Instantiates `gem_pcs` when PCS is configured.

### 8.2 `rgmii.v` — RGMII Adapter

`rgmii.v` converts between GMII and RGMII:

- **Transmit**: lower nibble (`tx_data_pos`) on rising edge of `rgmii_tx_clk`, upper nibble (`tx_data_neg`) on falling edge. Control `rgmii_tx_ctl` is `tx_en` on rising edge and `tx_en ^ tx_er` on falling edge.
- **Receive**: samples `rgmii_rxd` and `rgmii_rx_ctl` on both edges of `rgmii_rx_clk`, reconstructs 8-bit `gmii_rxd`, `gmii_rx_dv`, and `gmii_rx_er = rx_ctrl_pos ^ rx_ctrl_neg`.
- **Link status decode**: when `rx_ctrl_pos==0` and `rx_ctrl_neg==0`, `rx_data_pos` carries link status, speed, and duplex.
- **CRS decode**: recognizes idle / carrier sense / false carrier / carrier extend / carrier extend error codes.

### 8.3 `rmii_interface.v` — RMII Adapter

`rmii_interface.v` converts between MII and RMII using a 50 MHz `ref_clk`:

- Generates `tx_clk` (25 MHz for 100M, 2.5 MHz for 10M) and `rx_clk` from `ref_clk`.
- **Transmit**: di-bit `txd_rmii` plus `tx_en_rmii`; two di-bits per MII nibble.
- **Receive**: samples `rxd_rmii` on each `ref_clk` edge, reconstructs 4-bit MII `rxd`; supports `crs_dv` toggling and preamble detection.
- LPI support: `tx_lpi_en` forces `txd_rmii=2'b01` with `tx_en_rmii=0`.

---

## 9. Essential vs Optional Features

### 9.1 Minimal Ethernet MAC (Must-Have)

| Feature | Files | Why Essential |
|---------|-------|---------------|
| TX/RX clock domains | `gem_tx.v`, `gem_rx.v` | MAC operates on PHY clocks |
| Preamble/SFD generation & stripping | `gem_tx.v`, `gem_rx.v` | IEEE 802.3 packet framing |
| Frame data FIFO interface | `gem_tx.v`, `gem_rx.v` | Connect MAC to DMA/client |
| CRC-32 generation (TX) and check (RX) | `gem_tx.v`, `gem_rx.v`, `gem_stripe` | FCS integrity |
| Padding to 64 bytes | `gem_tx.v`, `gem_tx_state.v` | minFrameSize compliance |
| InterFrame Gap (96 bit times) | `gem_tx.v` | Inter-packet spacing |
| Half-duplex CSMA/CD | `gem_tx.v`, `gem_tx_state.v` | 10/100 shared-medium operation |
| Truncated binary exponential backoff | `gem_tx.v` | Collision resolution |
| Address filtering (unicast/multicast/broadcast) | `gem_filter.v` | Deliver only relevant frames |
| MII/GMII interface | `gem_mii_bridge.v` | PHY connectivity |

### 9.2 Optional / Configurable Features

| Feature | Files | Why Optional |
|---------|-------|--------------|
| RGMII | `rgmii.v`, `gem_mii_bridge.v` | Only if RGMII PHY selected (`p_edma_using_rgmii`) |
| RMII | `rmii_interface.v`, `gem_mii_bridge.v` | Only if RMII PHY selected (`p_edma_include_rmii`) |
| PCS / SGMII / TBI | `gem_pcs`, `gem_mii_bridge.v` | Only for SerDes/backplane (`p_edma_has_pcs`) |
| Internal loopback | `gem_loop.v` | Diagnostic only (`p_edma_int_loopback`) |
| 802.3 PAUSE / PFC | `gem_tx.v`, `gem_rx.v` | Flow control; not needed for simple MAC |
| TSU / 1588 timestamping | `gem_tx.v`, `gem_rx.v` | PTP only (`p_edma_tsu`) |
| Specific-address filters (beyond filter 0) | `gem_filter.v` | Additional filtering (`p_num_spec_add_filters`) |
| Hash filtering | `gem_filter.v` | Scalable multicast filtering |
| VLAN / stacked VLAN | `gem_rx_decode` | 802.1Q awareness |
| IP/TCP/UDP checksum offload | `gem_rx.v` | Offload engine (`rx_toe_enable`) |
| Jumbo frames | `gem_rx.v` | `jumbo_enable` / `jumbo_max_length` |
| Magic Packet / Wake-on-LAN | `gem_rx.v` | Power management |
| IPG stretching | `gem_tx.v` | Rate control / testing |
| Credit-based shaping / scheduling | `gem_tx_wrap` | TSN/QoS features |
| ASF parity protection | throughout | Safety/ECC features (`p_edma_asf_dap_prot`) |
| 802.1CB FRER | `gem_rx.v` | TSN redundancy (`p_gem_num_cb_streams`) |
| 802.3br MMSL preemption | `gem_rx.v`, `gem_tx_wrap` | TSN preemption (`p_edma_has_br`) |

---

## 10. Cross-Reference with IEEE 802.3-2022 MAC Study

| 802.3 Requirement | GEM Implementation | Study Section |
|-------------------|-------------------|---------------|
| 7-byte preamble + SFD | `TYPE_PREAMBLE` / `TYPE_SFD` in `gem_tx.v`; detection in `gem_rx.v` | 1.2 |
| minFrameSize = 64 bytes | `within_60bytes` → `FILL` state | 1.5, 1.6 |
| CRC-32 polynomial 0x04C11DB7 | `gem_stripe` LFSR, init `0xFFFFFFFF` | 2.1 |
| FCS transmitted MSB-first within byte | `~crc[24..31]` ordering in `txd_next` | 2.3 |
| IFG = 96 bit times | `interframe_cnt` in `gem_tx.v` | 3.4 |
| Truncated binary exponential backoff | `random1`/`random2` LFSRs, `attemptLimit=16` | 3.5 |
| Jam sequence after collision | `JAM_ST` state, 32-bit jam | 3.6 |
| Slot time / carrier extension | `CARRIER_EXTEND`, `INTERFRAME_GAP_BURST` | 1.7 |
| DA first bit = I/G | `ext_da[0]` used in `gem_filter.v` | 1.3 |
| Broadcast address all 1s | `&ext_da` in `gem_filter.v` | 1.3 |
| Length/Type threshold 0x0600 | Length/type comparisons in `gem_rx_decode` | 1.4 |
| PAUSE frame DA 01:80:C2:00:00:01 | `PAUSE_SPEC_ADD` in `gem_filter.v` | 5 |

---

## 11. Key RTL Snippets

### 11.1 TX CRC Update (`gem_tx.v`)

```verilog
gem_stripe i_str_tx_0(.din(txd_next[0]), .stripe_in(crc),       .stripe_out(tx_stripe_out0));
...
gem_stripe i_str_tx_7(.din(txd_next[7]), .stripe_in(tx_stripe_out6), .stripe_out(tx_stripe_out7));

always@(posedge tx_clk or negedge n_txreset)
  if (~n_txreset) crc <= 32'hffffffff;
  else if (tx_en_next & ((data_type == TYPE_DATA) | (data_type == TYPE_FILL)))
    if (tx_byte_mode) crc <= tx_stripe_out7;
    else              crc <= tx_stripe_out3;
  else if (tx_en_next & (data_type == TYPE_CRC))
    if (tx_byte_mode) crc <= {crc[23:0],8'h00};
    else              crc <= {crc[27:0],4'h0};
  else if (data_type != TYPE_HOLD)
    crc <= 32'hffffffff;
```

### 11.2 TX State Machine Instantiation (`gem_tx.v`)

```verilog
gem_tx_state i_tx_state (
  .tx_clk            (tx_clk),
  .n_txreset         (n_txreset),
  .backoff           (backoff),
  .last_attempt      (last_attempt),
  .interframe_gap    (interframe_gap),
  .coll_sync         (coll_sync),
  .late_collision    (late_collision),
  .crs_sync          (crs_sync),
  .fifo_underrun     (fifo_underrun),
  .jam               (jam),
  .last_data         (last_data),
  .frame_ready       (frame_tx),
  .last_crc          (last_crc),
  .last_preamble     (last_preamble),
  .within_60bytes    (within_60bytes),
  .within_512bytes   (within_512bytes),
  .en_transmit_sync  (en_transmit_sync),
  .tx_no_crc         (tx_no_crc_valid),
  .gigabit           (gigabit),
  .within_burst_limit(within_burst_limit),
  .full_duplex       (full_duplex),
  .txd_rdy           (txd_rdy),
  ...
);
```

### 11.3 Address Filter Core (`gem_filter.v`)

```verilog
assign uni_hash_dec   = ~ext_da[0] & hash[hash_index] & uni_hash_en;
assign multi_hash_dec =  ext_da[0] & hash[hash_index] & multi_hash_en;
assign broadcast_dec  = (& ext_da) & ~no_broadcast;
assign multicast_dec  = ext_da[0] & ~broadcast_dec;
```

### 11.4 RGMII TX DDR (`rgmii.v`)

```verilog
assign rgmii_txd    = rgmii_tx_clk_sig ? tx_data_pos : tx_data_neg;
assign rgmii_tx_ctl = rgmii_tx_clk_sig ? tx_ctrl_pos : tx_ctrl_neg;
```

### 11.5 Loopback Retiming (`gem_loop.v`)

```verilog
always@(posedge n_tx_clk or negedge n_ntxreset)
  if (~n_ntxreset) begin
    rxd_looped   <= {1'b0,8'h00};
    rx_er_looped <= 1'b0;
    rx_dv_looped <= 1'b0;
  end else begin
    rxd_looped   <= txd_to_loop;
    rx_er_looped <= tx_er_to_loop;
    rx_dv_looped <= tx_en_to_loop;
  end
```

---

## 12. Recommendations for a Minimal MAC

Based on this analysis, a minimal IEEE 802.3-compliant Ethernet MAC should retain the following from the GEM design:

1. **TX path**: FIFO fetch, preamble/SFD insertion, CRC-32 generation, padding to 60 bytes before FCS, IFG, half-duplex CSMA/CD with backoff.
2. **RX path**: MII/GMII deserialization, preamble/SFD stripping, byte realignment, CRC check, basic address filtering (unicast/broadcast/multicast), FIFO push.
3. **PHY interface**: GMII/MII is sufficient; RGMII/RMII/PCS can be omitted initially.
4. **Optional to defer**: 1588 TSU, PFC/PAUSE, VLAN processing, checksum offload, jumbo frames, magic packet, IPG stretching, TSN features (CBS, FRER, MMSL), ASF parity.

The `gem_tx_state.v` FSM and the `gem_filter.v` address-matching logic are excellent reference implementations for the canonical IEEE 802.3 MAC behavior.

---

*End of A2 MAC Core Analysis*
