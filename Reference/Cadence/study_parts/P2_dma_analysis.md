# Cadence GEM DMA Analysis (P2)

Source: `Reference/Cadence/study_parts/pdf_extracts/ug_dma.txt` (IP7014A User Guide, Rev 1.0)

---

## 1. DMA Descriptor Structure

GEM uses separate TX/RX descriptor rings. Each descriptor word is 32 bits.
Descriptor width depends on addressing and extended BD mode:

| Addressing | Extended BD | Words per BD | Total Width |
|------------|-------------|--------------|-------------|
| 32-bit     | No          | 2            | 64 bit      |
| 64-bit     | No          | 4            | 128 bit     |
| 32-bit     | Yes         | 4            | 128 bit     |
| 64-bit     | Yes         | 6            | 192 bit     |

### Receive Buffer Descriptor (RX BD)

```
Word 0  [31:3]  Buffer start address [31:3]
        [2]     Address[2]  OR  timestamp-valid (extended mode)
        [1]     Wrap
        [0]     Ownership: 0=SW/free, 1=GEM used

Word 1  [31]    Broadcast
        [30]    Multicast hash match
        [29]    Unicast hash match
        [28]    External address match
        [27]    Specific address match
        [26:25] Specific address register number
        [24:22] Type-ID match  OR  RX checksum-offload status
        [21]    VLAN tag
        [20]    Priority tag
        [19:17] VLAN priority; bit17=last header buffer (header-split)
        [16]    Header buffer flag / FCS error / CFI
        [15]    End of frame (EOF)
        [14]    Start of frame (SOF)
        [13]    Jumbo length MSB  OR  per-frame FCS status
        [12:0]  Frame length (or header length if header-split)
```

*64-bit mode adds Word 2 = upper address, Word 3 = unused. Extended BD mode adds timestamp (seconds + nanoseconds) to the **last** BD of a frame.*

### Transmit Buffer Descriptor (TX BD) — Non-LSO

```
Word 0  [31:0]  Byte address of buffer

Word 1  [31]    Used: 0=ready, 1=complete
        [30]    Wrap
        [29]    Retry limit exceeded
        [28]    Transmit underrun
        [27]    TX frame corruption / bus error
        [26]    Late collision
        [23]    Timestamp captured (extended BD)
        [22:20] TX checksum-offload error code
        [16]    No CRC appended by MAC
        [15]    Last buffer
        [13:0]  Buffer length
```

*LSO/TSO/UFO repurpose bits [18:17] for LSO control, [29:16]/[25:24] for MSS/TCP-stream ID.*

---

## 2. DMA Operation Flow

```
SW:  RX: allocate buffers, fill descriptors (addr, ownership=0)
     TX: build frame, fill descriptors (addr, len, last, used=0)

DMA: Fetch descriptor from ring base
     if ownership=1 -> halt / resource error / interrupt
     TX: read data from memory -> MAC
     RX: write data from MAC -> memory
     Write status back to Word 1 (used=1, errors, len, timestamp)
     Advance pointer; wrap on wrap-bit

IRQ: frame transmitted, frame received, buffer unavailable,
     overrun, underrun, bus error
```

Key notes:
- RX base address locks once receive is enabled; TX base updates only when TX disabled.
- TX DMA halts on `used=1`; a terminating "used" descriptor is required.
- Internal-FIFO mode may write RX fragments before late errors are detected.
- Packet-buffer full store-and-forward drops bad RX frames before memory writeback.

---

## 3. Advanced DMA Features

| Feature | Description | Enable |
|---------|-------------|--------|
| Scatter-Gather | Up to 128 TX buffers per frame | Always via descriptors |
| Header-Data Split | RX header and payload in separate buffers | DMA Config bit 5 |
| RSC | Coalesce TCP segments; needs header-split + priority queues + AXI | `gem_pbuf_rsc` + RSC reg |
| TSO | TCP Segmentation Offload via header + payload descriptors | Header BD bits [18:17]=2'b10/11 |
| UFO | UDP Fragmentation Offload at IP layer | Header BD bits [18:17]=2'b01 |
| Checksum Offload | TX/RX IP/TCP/UDP checksum generation/checking | DMA/Network Config |
| Partial Store & Forward | Low-latency cut-through from packet buffer | TX/RX partial-SF regs |
| Priority Queuing | Up to 16 independent TX/RX queues | `gem_gxl_defs.v` |
| Time-Based TX Scheduling | Per-frame launch time vs TSU timer | Extended BD + UTLT bit |
| Timestamp Capture | PTP timestamp in extended descriptor | Extended BD + BD control |

---

## 4. Constraints & Configuration

| Item | Value / Rule |
|------|--------------|
| RX buffer size | 64 – 16320 bytes; default 128 |
| TX frame length | 14 – 16383 bytes |
| Max TX buffers/frame | 128 |
| Data bus width | 32/64/128 bit (packet buffer); 32/64 bit (internal FIFO) |
| Burst length | Single, 4, 8, 16, 256 (256 AXI4 only; 16 AHB max) |
| AXI boundary | Never crosses 4 KB |
| AHB boundary | Never crosses 1 KB |
| Endianness | Default little-endian; bits [7:6] of DMA Config swap data/mgmt |
| RX alignment | Word address; SOF offset up to 3 bytes (+4 bytes for 64-bit datapath in packet-buffer) |
| TX alignment | Byte address; FIFO mode 64/128-bit datapath needs bus-width alignment with offset < 4 bytes |
| 64-bit descriptor ring | Must reside in one 4 GB region (upper bits fixed); packet data unrestricted |

---

## 5. Essential vs Optional for a Minimal DMA

**Essential:** descriptor rings, ownership/wrap bits, buffer address + length, SOF/EOF/used status, basic error status, scatter-gather, programmable burst/width, completion/resource-error interrupts, endianness config.

**Optional:** 64-bit addressing, timestamp capture, time-based scheduling, header-data splitting, RSC, TSO/UFO, checksum offload, priority queuing, packet-buffer modes, burst padding, AXI descriptor caching/outstanding transactions.

---

*Analysis prepared by Agent P2 — read-only summary of Cadence GEM DMA chapter.*
