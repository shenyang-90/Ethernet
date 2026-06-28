# P6 Register Analysis – Cadence GEM (IP7014A)

## 1. Register Address Map

| Address Range | Group | Key Registers |
|---------------|-------|---------------|
| 0x0000–0x00FC | Control / Status | network_control, network_config, network_status, dma_config, receive_q_ptr, transmit_q_ptr, int_status/enable/disable/mask, phy_management |
| 0x0100–0x01B8 | Statistics | octets_txed/rxed, frames_txed/rxed_ok, pause_frames, fcs_errors, overruns, etc. |
| 0x01BC–0x01FC | TSU | tsu_timer_incr_sub_nsec, tsu_timer_sec/nsec/adjust/incr, tsu_ptp_tx/rx_sec/nsec, tsu_strobe_* |
| 0x0200–0x025C | PCS | pcs_control, pcs_status, pcs_an_adv, pcs_an_lp_base, pcs_an_ext_status |
| 0x0260–0x02FC | Miscellaneous | tx_pause_quantum1–3, pfc_status, rx/tx_lpi, designcfg_debug*, axi_qos_cfg_0–3 |
| 0x0300–0x03FC | Extended Filter | spec_add5_bottom/top … spec_add21_bottom/top |
| 0x0400–0x0FFC | Other Functional Blocks | Priority Queue & Screening, TSN, ASF, MMSL |
| 0x1000–0x1FFF | eMAC | Duplicate of pMAC register set at `+0x1000` |

## 2. Critical Control Register Bitfields
### network_control (0x00, RW, reset 0x0000_0000)

| Bit(s) | Name | Description |
|--------|------|-------------|
| 31 | reserved | RO, read 0 |
| 30 | ifg_eats_qav_credit | IFG/IPG counts toward 802.1Qav credit |
| 29 | reserved | RO |
| 28 | sel_mii_on_rgmii | MII over RGMII (no eMAC effect in 802.3br) |
| 27:20 | tsu/ptp/sgmii/qav | oss_correction(27), ext_rxq_sel_en(26), pfc_ctrl(25), one_step_sync(24), ext_tsu_port_en(23), store_udp_offset(22), alt_sgmii_mode(21), ptp_unicast_ena(20) |
| 19 | tx_lpi_en | TX LPI (pMAC only in 802.3br) |
| 18:11 | flush / pfc / pause / stats | flush_rx_pkt_pclk(18), tx_pfc_pause(17), pfc_enable(16), store_rx_ts(15), stats read/take snap(14:13), pause req/zero(12:11) — mostly WO |
| 10 | transmit_halt | Halt TX DMA reads (WO) |
| 9 | transmit_start | Start transmission (WO) |
| 8 | back_pressure | Half-duplex back-pressure |
| 7:5 | stats_test_en | stats_write_en(7), inc/clear stats(6:5) |
| 4 | man_port_en | Enable MDIO management port |
| 3 | enable_transmit | Enable transmitter |
| 2 | enable_receive | Enable receiver |
| 1 | loopback_local | Internal MAC loopback |
| 0 | loopback | Loopback output pin |

### network_config (0x04, RW, reset 0x0008_0000)

| Bit(s) | Name | Description |
|--------|------|-------------|
| 31 | uni_direction_enable | Allow TX data when link down |
| 30 | ignore_ipg_rx_er | Ignore RX_ER during IPG |
| 29 | nsp_change | Accept non-standard preamble |
| 28 | ipg_stretch_enable | Stretch TX IPG |
| 27 | sgmii_mode_enable | SGMII mode / 1.6 ms AN timer |
| 26 | ignore_rx_fcs | Do not drop frames with bad FCS |
| 25 | en_half_duplex_rx | RX while TX in half-duplex |
| 24 | receive_checksum_offload_enable | RX IP/TCP/UDP checksum offload |
| 23 | disable_copy_of_pause_frames | Drop pause frames from memory |
| 22:21 | data_bus_width | 00=32b, 01=64b, 10=128b, 11=invalid |
| 20:18 | mdc_clock_division | pclk→MDC divisor: 000=/8 … 111=/224 |
| 17 | fcs_remove | Strip FCS from RX frames |
| 16 | length_field_error_frame_discard | Drop undersized length-field frames |
| 15:14 | receive_buffer_offset | RX data offset in bytes |
| 13 | pause_enable | React to classic pause frames |
| 12 | retry_test | Test only; must be 0 |
| 11 | pcs_select | 0=GMII/MII, 1=TBI (must match eMAC/pMAC) |
| 10 | gigabit_mode_enable | 0=10/100, 1=1000 Mbps (must match eMAC/pMAC) |
| 9 | external_address_match_enable | External address match copy |
| 8 | receive_1536_byte_frames | Accept frames up to 1536 B |
| 7 | unicast_hash_enable | Hash unicast filtering |
| 6 | multicast_hash_enable | Hash multicast filtering |
| 5 | no_broadcast | Reject broadcast frames |
| 4 | copy_all_frames | Promiscuous mode |
| 3 | jumbo_frames | Accept jumbo frames |
| 2 | discard_non_vlan_frames | Drop non-VLAN frames |
| 1 | full_duplex | Full-duplex mode |
| 0 | speed | 1=100 Mbps, 0=10 Mbps (no eMAC effect in 802.3br) |

### dma_config (0x10, RW, reset 0x0002_07C4)

| Bit(s) | Name | Description |
|--------|------|-------------|
| 30 | dma_addr_bus_width_1 | 0=32b DMA address, 1=64b |
| 29 | tx_bd_extended_mode_en | TX extended BD mode |
| 28 | rx_bd_extended_mode_en | RX extended BD mode |
| 26 | force_max_amba_burst_tx | Force max TX bursts on EOP/EOB |
| 25 | force_max_amba_burst_rx | Force max RX bursts on EOP/EOB |
| 24 | force_discard_on_err | Auto-discard oldest RX frame on resource error |
| 23:16 | rx_buf_size | RX buffer size in 64 B multiples (0x02=128 B) |
| 13 | crc_error_report | BD bit 16 = CRC error vs CFI |
| 12 | infinite_last_dbuf_size_en | Last descriptor elastic-size mode |
| 11 | tx_pbuf_tcp_en | TX IP/TCP/UDP checksum offload |
| 10 | tx_pbuf_size | 1=full TX packet buffer, 0=half |
| 9:8 | rx_pbuf_size | 11=full, 10=half, 01=quarter, 00=eighth |
| 7 | endian_swap_packet | Swap endian for packet data |
| 6 | endian_swap_management | Swap endian for management descriptors |
| 5 | hdr_data_splitting_en | Header/payload split to separate buffers |
| 4:0 | amba_burst_length | AHB/AXI burst encoding (reset 0x04 ⇒ up to 4-beat) |

### Interrupt Registers (status 0x24, enable 0x28, disable 0x2C, mask 0x30)

Enable/disable use the same bit map; `int_mask` (RO, reset `0xFFFF_FEFF`) reflects the current mask.

| Bit | Event | Bit | Event |
|-----|-------|-----|-------|
| 31 | tx_lockup_detected | 15 | external_interrupt |
| 30 | rx_lockup_detected | 14 | pause_frame_tx |
| 29 | tsu_timer_comparison | 13 | pause_time_elapsed |
| 28 | wol_interrupt | 12 | pause_frame_nonzero_quantum_rx |
| 27 | rx_lpi_status_change | 11 | resp_not_ok |
| 26 | tsu_seconds_increment | 10 | receive_overrun |
| 25 | ptp_pdelay_resp_tx | 9 | link_change |
| 24 | ptp_pdelay_req_tx | 8 | reserved |
| 23 | ptp_pdelay_resp_rx | 7 | transmit_complete |
| 22 | ptp_pdelay_req_rx | 6 | amba_error |
| 21 | ptp_sync_tx | 5 | retry_limit_exceeded_or_late_collision |
| 20 | ptp_delay_req_tx | 4 | transmit_under_run |
| 19 | ptp_sync_rx | 3 | tx_used_bit_read |
| 18 | ptp_delay_req_rx | 2 | rx_used_bit_read |
| 17 | pcs_link_partner_page_rx | 1 | receive_complete |
| 16 | pcs_auto_negotiation_complete | 0 | management_frame_sent |

### phy_management (0x34, RW, reset 0x0000_0000)

| Bit(s) | Name | Description |
|--------|------|-------------|
| 31 | write0 | Must be 0 |
| 30 | write1 | 1=Clause 22, 0=Clause 45 |
| 29:28 | operation | C45: 00=addr,01=wr,10=post-rd-incr,11=rd; C22: 01=wr,10=rd |
| 27:23 | phy_address | 5-bit PHY address |
| 22:18 | register_address | 5-bit PHY register address |
| 17:16 | write10 | Must be 0b10 |
| 15:0 | phy_write_read_data | Write data / read result |

## 3. Essential Bring-up / Initialization Bits

- **MDIO**: `man_port_en` (network_control[4]); `mdc_clock_division` (network_config[20:18]).
- **PHY mode**: `pcs_select`[11], `gigabit_mode_enable`[10], `speed`[0], `full_duplex`[1].
- **RX/TX enable**: `enable_receive`[2], `enable_transmit`[3]; then `transmit_start`[9].
- **DMA setup**: `rx_buf_size`[23:16], `rx_pbuf_size`[9:8], `tx_pbuf_size`[10], `amba_burst_length`[4:0], `dma_addr_bus_width_1`[30], endian bits.
- **Descriptors**: program `receive_q_ptr` (0x18) and `transmit_q_ptr` (0x1C) before enabling RX/TX.
- **Interrupts**: unmask via `int_enable` (write 1s for wanted events) or write `int_mask` directly.
- **Loopback**: `loopback_local`[1]; disable TX/RX while switching.

## 4. pMAC / eMAC Duplicate Register Layout

- **pMAC**: `0x0000`–`0x0FFF`; **eMAC**: `0x1000`–`0x1FFF` (`+0x1000` mirror). `pcs_select` and `gigabit_mode_enable` must match in pMAC/eMAC; `sel_mii_on_rgmii` and `speed` have no eMAC effect in 802.3br; LPI (`tx_lpi_en`) is controlled from pMAC only.

| pMAC Offset | Register | eMAC Offset |
|-------------|----------|-------------|
| 0x00 | network_control | 0x1000 |
| 0x04 | network_config | 0x1004 |
| 0x10 | dma_config | 0x1010 |
| 0x24 | int_status | 0x1024 |
| 0x28 | int_enable | 0x1028 |
| 0x2C | int_disable | 0x102C |
| 0x30 | int_mask | 0x1030 |
| 0x34 | phy_management | 0x1034 |
