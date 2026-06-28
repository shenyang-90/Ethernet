# P4 TSU/TSN Analysis — Cadence GEM (IP7014A) User Guide

Source: `Reference/Cadence/study_parts/pdf_extracts/ug_tsu_tsn.txt` (User Guide pages 105–119).

---

## 1. IEEE 1588 TSU Operation

| Item | Description |
|------|-------------|
| Timer width | 102-bit: 48-bit seconds, 30-bit nanoseconds, 24-bit sub-nanoseconds. Lower 54 bits roll over at 1 s. |
| Clock source | `pclk`, or dedicated `tsu_clk` if `gem_tsu_clk` is defined. |
| Increment | Per-cycle increment set by `tsu_timer_incr` (8-bit ns default + alt legacy fields) and `tsu_timer_incr_sub_nsec` (24-bit sub-ns). |
| Alternative increment | Legacy mode using bits [23:16] for count and bits [15:8] for alternate ns value; **not recommended**. |
| Timer adjust | One-off add/subtract via `tsu_timer_adjust`, or ±1 ns control via `gem_tsu_inc_ctrl[1:0]` + `gem_tsu_ms` (increment/clear/sync-strobe modes). |
| Compare | 48-bit seconds + upper 22-bit ns compared to `tsu_timer_comparison` registers (0x0DC, 0x0E0, 0x0E4); match drives output signal and interrupt status bit 29. |
| External timer | Optional 94-bit external timestamp port (94 MSBs of internal count), synchronous to `tsu_clk`, enabled via network control. Write/adjust registers have no effect, but read/compare still work. |
| SOF capture | TX/RX SOF crossing MII/GMII boundary is synchronized to `tsu_clk` and samples the TSU count. Value is stable for ≥64 MAC clock cycles. |
| Capture outputs | APB capture registers (8×80-bit), DMA TX/RX descriptor timestamps, or direct insertion into one-step TX Sync frames. |
| Capture accuracy | ≤1 `tsu_clk` cycle uncertainty due to CDC. |
| One-step TX sync | Network-control bit enables replacing the timestamp field; `oss_correction_field` (bit 27) enables single-step residence-time correction-field update. Requires `tsu_clk` > 1/8 of `tx_clk`/`rx_clk`; incompatible with UDP checksum offload. |
| 802.1AS | Subset of 1588; recognizes sync on 01-80-C2-00-00-0E in addition to 1588 addresses. 802.1AS does **not** use one-step timestamping. |

---

## 2. 802.1Qbv EnST (Enhancement for Scheduled Traffic)

| Item | Description |
|------|-------------|
| Concept | Time-aware gating of the eight highest-priority TX queues, synchronized to the TSU. |
| Per-queue registers | `start_time[31:0]` (2-bit seconds + 30-bit ns), `on_time[16:0]` (bytes), `off_time[16:0]` (bytes), `enst_en`. |
| Control | 16-bit enable/disable register: bits [7:0] enable each queue, bits [15:8] disable (disable has priority). |
| Operation | Gate opens at `start_time`; then repeats `on_time` / `off_time` cycles. Not a full IEEE cycle-timer FSM — fixed-period only. To change schedule, disable queue, reprogram, then re-enable. |
| Frame eligibility | A frame is not started if it cannot finish within remaining `on_time`; if it can never fit, it is dropped and an error is flagged. |
| Byte-to-time scaling | `on_time`/`off_time` in bytes: 1 byte = 8 ns @ 1 Gb/s, 80 ns @ 100 Mb/s, 800 ns @ 10 Mb/s, etc. Max ~1.05 ms. |
| Coexistence | Works alongside CBS and strict priority; software must ensure gates do not overlap. |

---

## 3. 802.1CB FRER Support

| Item | Description |
|------|-------------|
| Scope | Supports **stream identification and frame elimination only**; does **not** support frame replication. |
| Configuration | Enabled when `gem_no_of_cb_streams` is non-zero (≤16, ≤ `num_type2_screeners`). History length `gem_seq_history_len` (1–64). |
| Stream ID | Uses existing Type 2 Screener compares. Each CB stream has `member_stream_1` / `member_stream_2` pointing to screeners. |
| Sequence number source | Redundancy Tag (Ethertype `0xF1C1`), 4-byte (draft 2.4) or 6-byte (draft 2.5+) format selected by `frer_red_tag` register. Tag may be stripped for software transparency. Alternatively, byte offset programmed in control register (e.g., TCP seq). |
| Recovery algorithms | **Match** and **Vector** recovery, selected per stream via `en_vector_rec_alg`. |
| Match algorithm | First matched frame sets hidden `RecovSeqNum`; duplicates (same seq) are dropped; non-duplicate resets `RecovSeqNum`, may increment latent-error/out-of-order counters, and resets timeout timer. |
| Vector algorithm | Maintains history vector of length `gem_seq_history_len` around `RecovSeqNum`. Duplicates and frames outside history depth (rogues) are rejected; accepted frames update history and `RecovSeqNum`. |
| Timeout | `FRER timeout` register loaded into sequence-recovery reset timer on accepted frames; if timer reaches zero, `RecovSeqNum` and duplicate state reset. |

---

## 4. 802.3br / 802.1Qbu Frame Preemption (MMSL)

| Item | Description |
|------|-------------|
| Architecture | Two MAC instances + MMSL + AXI arbiter/APB switch. `eMAC` = express MAC; `pMAC` = preemptable MAC. |
| eMAC constraints | Fixed to 1 queue; CB stream functions fixed to 2 if CB enabled; uses pMAC’s TSU as external TSU; RSC not supported. |
| TX preemption | If eMAC requests channel while pMAC is sending an M-frame, pMAC frame is halted, appended with 32-bit `MCRC`, then express frame transmits. |
| Non-preempt cases | <64 M-frame bytes remain; `add_frag_size` minimum not yet transmitted; preemption disabled; verification failed/handshake incomplete. |
| Fragment size | Minimum fragment length programmable via `add_frag_size` register. |
| RX reassembly | MMSL routes M-frames: eMAC frames are standard Ethernet; pMAC frames use modified SFD to detect fragments. RX state machine halts during express frame, resumes on continuation fragment. |
| Verification | After reset, a verify frame is sent; expects a respond frame within 10 ms. Retries up to 2 more times before disabling preemption. Can be restarted by software. |
| Memory map | pMAC 0x0000–0x0EFC, MMSL 0x0F00–0x0FFC, eMAC 0x1000–0x1FFC. |

---

## 5. 802.1Qci Receive (Ingress) Traffic Policing

| Item | Description |
|------|-------------|
| Mechanism | Discards received frames that exceed allocated frame length or flow rate. |
| `rx_q_flush` (0x0B00) | Per-queue discard triggers: all traffic, BD-used bit set, SRAM usage threshold (128-byte chunks), or frame length threshold. |
| `scr2_reg_rate_limit` (0x0B40) | Discards frames exceeding a programmed flow rate. |
| Notes | Provides hardware policing hooks; thresholds/rates and stream-gate semantics are configured by software. |

---

## 6. Hardware vs. Software Responsibilities

| Function | Implemented in Hardware | Requires Software |
|----------|------------------------|-------------------|
| **1588 TSU** | Timer count, rollover, compare, SOF timestamp capture, one-step sync/correction-field insertion, external timestamp port. | PTP protocol state machine, BMCA, delay calculations, timer init/increment/adjust programming, unicast PTP address setup. |
| **802.1Qbv EnST** | Per-queue gate on/off state machine driven by TSU. | Program `start_time`, `on_time`, `off_time`, enable bits; ensure non-overlapping schedule; handle dropped-frame errors. |
| **802.1CB FRER** | Type 2 screener-based stream ID, redundancy-tag parsing, match/vector recovery, duplicate/rogue/latent/out-of-order counters, timeout reset. | Configure screeners, member streams, R-tag or offset mode, recovery algorithm, timeout value; **replication is not done by GEM**. |
| **802.3br MMSL** | eMAC/pMAC arbitration, M-frame fragmentation/MCRC, RX reassembly, verification handshake, programmable `add_frag_size`. | Enable preemption, handle verification restart, configure fragment size, manage eMAC/pMAC queues. |
| **802.1Qci policing** | Queue flush and rate-limit trigger logic. | Set length/depth/rate thresholds; map streams to queues/policers. |
