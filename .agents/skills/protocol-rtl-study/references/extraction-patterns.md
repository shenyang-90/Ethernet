# Protocol Extraction Patterns

Reference guide for extracting RTL-relevant content from technical standards.

## Table of Contents
- [Generic Extraction Dimensions](#generic-extraction-dimensions)
- [Protocol Category Patterns](#protocol-category-patterns)
  - [Data-Link / TSN (802.1Q, 802.1CB, 802.1AB)](#data-link--tsn)
  - [Security (802.1AE)](#security)
  - [Time Synchronization (1588, 802.1AS)](#time-synchronization)
  - [Higher-Layer Management](#higher-layer-management)
- [Keyword Mapping](#keyword-mapping)
- [RTL Implementation Checklist Template](#rtl-implementation-checklist-template)

---

## Generic Extraction Dimensions

Every protocol standard should be analyzed across these 7 dimensions. Not all apply to every protocol.

| Dimension | What to Extract | Output Format |
|-----------|----------------|---------------|
| **Addressing** | DA/SA rules, multicast addresses, Ethertypes, VLAN/Priority handling | Table: Name / Value / Scope |
| **Frame Format** | Header fields, payload structure, bit widths, offsets, endianness | Table: Field / Octets / Offset / Bits / Description |
| **TLV/Tag Encoding** | Type values, length rules, mandatory order, info string limits | Table: Type / Name / Usage / Length Rules |
| **State Machines** | States (with numeric values), events, transitions, actions | Table + Pseudocode blocks |
| **Timers & Counters** | Name, default, range, resolution, behavior (count-up/down) | Table: Name / Default / Range / Description |
| **Datasets/MIBs** | Field name, type, width, access, default, grouping | Table per dataset |
| **Formulas** | Delay, offset, correction, scheduling equations | `<pre>` block with variable definitions |

---

## Protocol Category Patterns

### Data-Link / TSN

**Applies to**: 802.1Q (VLAN/TSN), 802.1CB (FRER), 802.1AB (LLDP), 802.1Qbv (TAS), 802.1Qbu (Frame Preemption)

**Frame format focus**:
- Tag formats: C-TAG (0x8100), S-TAG (0x88A8), I-TAG (0x88E7)
- TCI/PCP/DEI/VID bit positions
- TSN specific: Gate Control List entries, guard band, hold/release

**State machine focus**:
- Transmission selection algorithms (strict priority, CBS, ATS)
- PSFP: Stream Filter/Sate Gate state machines
- TAS: Gate scheduling state machine (OPEN/CLOSE per queue)

**RTL-specific**:
- Per-queue gate states are time-driven; need cycle-accurate scheduler
- Frame Preemption: express/preemptable queue interaction, mPacket CRC
- FRER: sequence number recovery (R-tag), duplicate elimination

**Key clauses to grep**:
```
frame format | tag format | TCI | PCP | VID
gate control list | schedule | cycle time | base time
stream filter | stream gate | flow meter
sequence number | R-Tag | recovery function
```

### Security

**Applies to**: 802.1AE (MACsec), 802.1X, future security extensions

**Frame format focus**:
- SecTAG: TCI/AN/SL/PN/SCI fields
- ICV length (8B or 16B depending on cipher suite)
- Cipher suite identifiers (Table in standard)

**State machine focus**:
- SecY transmit/receive secure channels
- SA lifetime management (PN exhaustion → SA change)
- Key agreement (MKA) state transitions (if applicable)

**RTL-specific**:
- PN must be strictly monotonic per SA; hardware must detect exhaustion
- Replay window management (lowest acceptable PN)
- AES-GCM pipeline latency vs line rate requirements

**Key clauses to grep**:
```
SecTAG | TCI | AN | PN | SCI | ICV
cipher suite | AES-GCM | confidentiality | integrity
replay protection | replay window | lowest PN
SA lifetime | PN exhaustion | key agreement
```

### Time Synchronization

**Applies to**: IEEE 1588-2019 (PTP), IEEE 802.1AS-2020 (gPTP)

**Frame format focus**:
- Common PTP header: 34 bytes, messageType, flagField, correctionField
- Timestamp format: 10 bytes (48-bit seconds + 32-bit nanoseconds)
- Message-specific bodies: Sync, Follow_Up, Delay_Req, Delay_Resp, Announce, Pdelay

**State machine focus**:
- BMCA: dataset comparison algorithm (9-level priority)
- Port state machine: INITIALIZING → LISTENING → MASTER/SLAVE/PASSIVE
- Foreign master qualification

**RTL-specific**:
- Hardware timestamp capture at reference plane (near PHY)
- correctionField arithmetic: 64-bit signed, unit = ns × 2^16
- Residence time accumulation in Transparent Clocks
- One-step vs two-step clock handling

**Key clauses to grep**:
```
common header | messageType | flagField | correctionField
timestamp | originTimestamp | preciseOriginTimestamp
BMCA | best master | dataset comparison | clockClass
meanPathDelay | meanLinkDelay | residenceTime | delayAsymmetry
transparent clock | one-step | two-step
```

### Higher-Layer Management

**Applies to**: SNMP MIBs, YANG models, CLI register maps

**Extraction focus**:
- Scalar objects vs tabular objects
- Access mode: read-only, read-write, read-create
- Index columns for table entries
- Counter widths and wrap behavior

**RTL-specific**:
- Which objects need hardware registers vs software-only?
- Counter saturation vs wrap behavior
- Atomic read requirements for 64-bit counters

---

## Keyword Mapping

Map standard-document terminology to RTL design concepts.

| Standard Term | RTL Concept | Example |
|---------------|-------------|---------|
| data set | register block / CSR map | defaultDS → hw_reg_default_ds |
| state machine | FSM / state register + next-state logic | txStateMachine → tx_fsm_reg |
| timer | countdown counter + tick enable | txTTR → tx_ttr_counter |
| counter | event counter with wrap | statsFramesOutTotal → 32b counter |
| TLV / message body | packet parser output struct | lldp_tlv_t |
| frame format | packet header struct / bus layout | ptp_header_t |
| correctionField | signed accumulator | cf_accumulator [63:0] |
| gate control list | SRAM table + scheduler FSM | gate_list_sram[512] |
| stream filter | TCAM + action table | stream_filter_tcam |

---

## RTL Implementation Checklist Template

Use this as the final section of every study HTML.

```markdown
### RTL Implementation Checklist

| Item | Requirement | Verification Method |
|------|-------------|---------------------|
| Parser | Validate mandatory field order and lengths | Simulation with good/bad frames |
| Length checks | All variable-length fields within max bounds | Corner-case tests |
| Key extraction | Unique key constructed per standard (MSAP, PortIdentity, etc.) | Review against spec |
| State machine | All states reachable; no deadlock; reset → IDLE | Formal or simulation |
| Timers | Resolution and range match standard; wrap behavior correct | Timer testbench |
| Counters | Width matches spec; wrap at specified value; no overflow | Counter testbench |
| Byte order | Multi-octet fields use specified endianness | Protocol analyzer check |
| Address filter | DA/Ethertype match logic correct | Filter test vectors |
| Fast path | New neighbor / local change triggers fast TX | Event-driven test |
| Shutdown | TTL=0 sent on disable; reinitDelay respected | Disable/enable sequence |
| Dataset consistency | All related fields updated atomically on state change | Consistency checker |
| Formula precision | Arithmetic width prevents intermediate overflow | Bounded model check |
```

---

## Common Pitfalls

1. **Bit numbering confusion**: IEEE standards number bits 1=LSB, 8=MSB within an octet. RTL typically uses 0=LSB. Document the mapping explicitly.
2. **Endianness**: On-the-wire formats are big-endian (lower octet number = more significant). RTL register interfaces may be little-endian. Be explicit.
3. **Timer resolution**: Standards often specify 1-second timers, but RTL may use faster clocks. Document the clock division.
4. **State machine diagrams**: Extracted PDFs often lose graphical state machines. Reconstruct from textual transition descriptions.
5. **Optional features**: Distinguish M (mandatory), O (optional), and X (exclusive) features. RTL should gate optional logic with parameters.
