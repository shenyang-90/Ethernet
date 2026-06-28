# P3 MAC TX/RX/Filter Analysis

Source: Cadence IP7014A GEM User Guide extract (`ug_mac_tx_rx_filter.txt`), pages 89-100.

---

## 1. MAC Transmit State Machine & Frame Format

### Frame Construction (GMII/MII or TBI output)

| Step | Behavior |
|------|----------|
| Data input | External FIFO / DMA → small input buffer; read width 32/64/128-bit per `dma_bus_width`; later processing in bytes. |
| Preamble/SFD | Prepended automatically: preamble + Start Frame Delimiter. |
| Data width | Gigabit: `txd[7:0]`; 10/100M: nibble `txd[3:0]`, `txd[7:4]=0`. |
| Padding | Added to reach 60 bytes if needed. |
| FCS/CRC | CRC-32 computed, inverted, appended → minimum frame size 64 bytes. |
| No-CRC mode | If `no CRC` bit set in TX descriptor word 1 or FIFO interface, **neither pad nor CRC** is appended. |

### Duplex Behavior

| Mode | Transmit behavior |
|------|-------------------|
| Full duplex | Transmit immediately; back-to-back frames separated by ≥96 bit times (IFG). |
| Half duplex | Check carrier sense; if active, wait for deassertion + 96-bit IFG before sending. |
| Collision | Send 32-bit jam sequence, then retry using truncated binary exponential backoff (up to 16 attempts). |
| Collision during P/SFD | Complete preamble/SFD first, then jam. |
| Late collision | 10/100M: same as collision, retry up to 16; Gigabit: abort, no retry, reported as late collision. |
| Underrun | Auto-append bad CRC and assert `tx_er`. |

### Inter-Packet Gap & Back Pressure

| Feature | Description |
|---------|-------------|
| IPG stretch | Enabled by network config bit 28; full duplex only. `IPG_STRETCH` scales IPG based on previous frame length; cannot go below 96 bits. |
| Half-duplex back pressure | `back_pressure` bit or `half_duplex_flow_control_en` forces collision by transmitting 64 bits of `1011` nibbles (or 64 `1`s) on incoming frame. **Not available in gigabit half duplex.** |

---

## 2. MAC Receive State Machine & Error Detection

### Data Path & Checks

| Item | Description |
|------|-------------|
| Datapath | 16-bit internal datapath. |
| Interfaces | External FIFO and/or DMA; TBI → 16-bit words, 10/100 SGMII → 8-bit repeated sampling. |
| Per-frame checks | Valid preamble, FCS, alignment, length. |
| FCS removal | Network config bit 17: store frames without FCS; reported length reduced by 4 bytes. |
| CRC error handling | Bit 26 set: CRC errors ignored, errored frames **not** discarded; descriptor bit[13] indicates FCS validity (DMA mode, non-jumbo). |

### Error Conditions & Actions

| Error | Behavior |
|-------|----------|
| Too long (giant) | Bad frame indication to FIFO; cease writing to memory. |
| Runt / short frame | Incremented in statistics; frame bad. |
| Long frame / jabber | Incremented in statistics. |
| Alignment error | Incremented in statistics. |
| Symbol error (`rx_er`) | Incremented in statistics. |
| FCS/CRC error | Incremented; discarded unless bit 26 set. |
| Length field error | Bit 16: compare measured length vs. length/type bytes 13-14; discard if measured shorter. Checked only for frames 64–1518 bytes and length/type < 0x0600. |
| Gigabit half-duplex slot time | Discard frames <512 bytes; burst subsequent frames must be ≥64 bytes. |

---

## 3. Address Filtering Summary

| Filter Type | Description |
|-------------|-------------|
| Specific address filters | 0–36 source/destination filters; each uses Bottom (first 4 bytes) + Top (last 2 bytes + SA/DA select + 6-bit byte mask). Filter 1 supports bit-level masking via a dedicated mask register. |
| Type ID match | 4 type ID registers; enabled by bit 31; OR-matched against bytes 13–14 (non-VLAN/non-SNAP). |
| Broadcast | Stored only if `no broadcast` bit = 0. |
| Hash filter | 64-bit hash register; 6-bit index = XOR of every 6th bit of DA. Separate unicast/multicast hash enable bits. All-multicast by setting hash register to all-ones. |
| External match | Optional pins `ext_sa/da/type/vid/ip_sa/ip_da/sp/dp` with strobes; `ext_match1-4` ORed; enabled by network config bit 9. |
| Promiscuous | `copy all frames` bit: copy all valid frames (no FCS/symbol errors); FCS-errored frames copied if bit 26 set. |
| Pause frame copy disable | Bit 23: pause frames never copied to memory regardless of other matches. |
| VLAN filtering | VLAN tag at byte 13; max frame length 1536 bytes via bit 8. Bit to discard all non-VLAN frames. VLAN/priority/CFI status reported in RX descriptor. |

---

## 4. Checksum Offload for IP/TCP/UDP

| Direction | Enable | Behavior |
|-----------|--------|----------|
| Receive | Network config bit 24 | Verify IPv4 header checksum (RFC 791), TCP (RFC 793), UDP (RFC 768). |
| Transmit | DMA config bit 11 | Generate checksums; only available in DMA packet-buffer mode with full store-and-forward. |

### Receive Offload Conditions

| Requirement | Notes |
|-------------|-------|
| VLAN | 4-octet VLAN, CFI=0; one stacked VLAN supported. |
| Encapsulation | RFC 894 Ethernet, RFC 1042 SNAP, or PPPoE. |
| IP | IPv4 or IPv6; valid header length; IP options supported; IPv6 extension headers supported **except fragmentation**. |
| IPv4 flags | Reserved bit must be 0. |
| Fragmentation | **Not supported** — checksum not checked for fragmented packets. |
| Result | Incorrect checksum → packet discarded and stats counter incremented; descriptor reports verification status. |

---

## 5. PAUSE / PFC Flow Control Support

| Feature | Support Notes |
|---------|---------------|
| IEEE 802.3x PAUSE | Not explicitly described as full PAUSE frame generation/reception. The document only mentions **disabling copy of pause frames** to memory (bit 23) and half-duplex back-pressure. |
| Half-duplex back pressure | Supported in 10/100M half duplex via forced collision (`back_pressure` bit or `half_duplex_flow_control_en` input). **Not supported in gigabit half duplex.** |
| IEEE 802.1Qbb PFC | Not mentioned in the extracted text. |

---

## Key Takeaways

- TX automatically builds minimal Ethernet frames (preamble, SFD, pad, FCS) unless no-CRC mode is selected.
- Collision/backoff behavior differs between 10/100M and gigabit half duplex.
- RX supports comprehensive length/FCS/alignment/symbol error detection with optional FCS stripping and CRC-error passthrough.
- Filtering is highly configurable via specific-address, hash, type-ID, VLAN, external match, and promiscuous modes.
- Checksum offload covers IPv4/IPv6/TCP/UDP but excludes IP fragmentation.
- Flow control support is limited to half-duplex back-pressure and pause-frame suppression; explicit 802.3x PAUSE/PFC frame handling is not documented in this extract.
