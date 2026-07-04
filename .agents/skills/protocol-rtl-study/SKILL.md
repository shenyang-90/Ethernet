---
name: protocol-rtl-study
description: |
  Extract RTL-design-relevant content from technical protocol standards (IEEE 802, IETF RFC, etc.) 
  and generate structured HTML study notes. Use when the user asks to:
  (1) Analyze a protocol standard for RTL/hardware implementation,
  (2) Extract frame formats, state machines, TLVs, datasets, or timing formulas from PDF/Markdown sources,
  (3) Generate a protocol study HTML matching the existing 802.1CB/802.1AE/802.1AS/802.1Q/802.1AB/1588 style,
  (4) Build an RTL implementation checklist or register map from a standard document,
  (5) Convert a protocol PDF into chapter-based Markdown and then into a design reference document.
---

# Protocol RTL Study Skill

Generate RTL-design-reference study documents from protocol standard sources.

## Workflow Overview

Execute in order. Skip a step only if the input is already in the required form.

### Step 1: Source Preparation

Determine input type and convert if needed:

| Input | Action | Output |
|-------|--------|--------|
| PDF standard | Run `scripts/pdf_to_chapter_md.py` (or existing project converter) | `Reference/<standard>/` with chapter `.md` files |
| Single large Markdown | Split by headings into chapter files | Same format as above |
| Already split chapters | Proceed to Step 2 | — |

**Naming convention**: `Reference/<standard>/NNN_<chapter-title>.md`

### Step 2: Locate RTL-Relevant Chapters

Use `grep` to find chapters containing RTL-relevant keywords. Common patterns:

```bash
grep -ril "frame format\|message format\|TLV\|state machine\|data set\|register\|counter\|timer\|delay\|correctionField\|timestamp" Reference/<standard>/
```

Key search targets per protocol type:
- **Data-link / TSN protocols** (802.1Q, 802.1CB, 802.1AB): frame formats, TLVs, state machines, gate control lists
- **Security protocols** (802.1AE): SecTAG, cipher suites, replay protection, SA/SC/PN management
- **Time sync** (1588, 802.1AS): message headers, timestamp formats, correctionField arithmetic, BMCA, delay mechanisms

### Step 3: Extract Structured Content

For each relevant chapter, read and extract into these categories:

1. **Frame / Message Formats**
   - Field name, width (bits/bytes), offset, bit positions, byte order (endianness)
   - Mandatory vs optional fields
   - Example: `messageType [3:0] @ offset 0`

2. **TLV / Tag Formats**
   - Type values table, header structure, info string length rules
   - Mandatory TLV order constraints

3. **State Machines**
   - State list with numeric/enum values
   - Transition conditions (events/guards)
   - Pseudocode reconstruction from textual descriptions

4. **Timers & Counters**
   - Timer name, default value, range, resolution, countdown behavior
   - Counter width, wrap behavior, increment conditions

5. **Datasets / MIBs / Registers**
   - Field name, type, width, access mode (R/W/RW), default value
   - Group by dataset (defaultDS, portDS, etc.)

6. **Formulas & Algorithms**
   - Delay calculations, offset corrections, CRC/polynomial expressions
   - Input/output variable definitions

7. **Addressing & Encapsulation**
   - Destination MAC addresses, Ethertypes, multicast groups
   - VLAN tags, priority code points

See `references/extraction-patterns.md` for detailed checklists per protocol category.

### Step 4: Generate HTML Study Note

Use `assets/html-template.html` as the base. Replace content sections with extracted data.

**Required HTML sections** (match existing study note style):

| Section | Content |
|---------|---------|
| 1. Overview | Protocol purpose, scope, core functions table |
| 2. Addressing / Encapsulation | MAC addresses, Ethertypes, filtering rules |
| 3. Frame/Message Format | Field tables with width/offset/bit definitions |
| 4. TLV/Tag Details | Type values, encoding rules, validation |
| 5. State Machines | State tables, pseudocode, transition diagrams (text) |
| 6. Timers / Counters | Defaults, ranges, behavior |
| 7. Datasets / MIB | Register-style tables |
| 8. Formulas | Delay/offset/algorithm equations |
| 9. Transport / Profile | Ethernet mapping, default profile parameters |
| 10. RTL Design Tips | `.rtl-box` sections with hardware-specific guidance |
| 11. Implementation Checklist | Table of requirements for RTL validation |

**Style requirements**:
- CSS variables: `--accent:#0056b3`, `--warn:#fff3cd`, `--crit:#f8d7da`, `--ok:#d4edda`
- Box classes: `.note` (blue), `.warn` (yellow), `.crit` (red), `.ok` (green)
- RTL-specific: `.rtl-box` (dashed border) for hardware design guidance
- Code blocks: `<pre>` for pseudocode, `<code>` for inline values
- Tables: full-width, bordered, with `th { background:#e2e6ea; }`

### Step 5: Quality Validation

Before delivering, verify:

```
□ All multi-byte fields specify endianness (big-endian for IEEE 802 on-the-wire)
□ Bit numbering convention documented (bit 8=MSB, bit 1=LSB per octet)
□ Mandatory field order constraints explicitly stated
□ State machine pseudocode covers all states and transitions
□ Timer defaults match standard (not assumed)
□ Formula variables defined with units (e.g., ns × 2¹⁶)
□ MAC addresses / Ethertypes verified against standard tables
□ HTML closes all tags; TOC links match section IDs
□ File size and line count reasonable (typically 20–50 KB, 500–1000 lines)
```

## Bundled Resources

- **`assets/html-template.html`**: Reusable HTML skeleton with CSS. Copy and fill content sections.
- **`references/extraction-patterns.md`**: Detailed extraction checklists for TSN, security, time-sync, and management protocols.
- **`scripts/pdf_to_chapter_md.py`**: PDF-to-Markdown splitter using PyMuPDF + bookmarks. Use if project does not already have a converter.
