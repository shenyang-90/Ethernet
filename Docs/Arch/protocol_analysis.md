# Ethernet IP Protocol Analysis - RTL-Coding Detail Level

> **Document Version**: v2.0 (RTL-Coding Detail)
> **Date**: 2026-05-12
> **Author**: Arch Agent + RTL Coding Agent
> **Project**: Ethernet IP (IP_20260502_001)
> **Stage**: PAD → RTL Ready
> **Reference**: IEEE 802.3-2022, IEEE 802.1Q-2022, IEEE 802.1AS-2020, IEEE 802.1AE-2018, IEEE 802.1CB-2017, Renesas R-Car S4 RSwitch2, Infineon TC4x GETH
> **Change**: v2.0 Rewritten for RTL coding: exact state machines, bit fields, byte layouts, formulas, register definitions

---

## 1. Protocol Panorama

### 1.1 Protocol Classification Matrix

| Functional Domain | Protocol/Standard | Version | Priority | RTL Complexity |
|-------------------|-------------------|---------|----------|----------------|
| **Base MAC** | IEEE 802.3 | 2008/2022 | P0 | Medium |
| **TSN Core** | 802.1AS (gPTP) | 2020 | P0 | High |
| | 802.1Qbv (EST) | 2015 | P0 | High |
| | 802.1Qbu (Frame Preemption) | 2016 | P1 | High |
| | 802.1Qav (CBS) | 2009 | P0 | Medium |
| | 802.1Qci (PSFP) | 2017 | P1 | High |
| | 802.1CB (FRER) | 2017 | P1 | High |
| **Network Security** | 802.1AE (MACsec) | 2018 | P1 | High |
| **VLAN/QoS** | 802.1Q | 2022 | P0 | Medium |
| **Time Sync** | IEEE 1588 (PTP) | 2008 | P0 | Medium |
| **PHY Interface** | MII / RMII / RGMII / SGMII / USXGMII | - | P0 | Low |
| **Power Saving** | 802.3az (EEE) | 2010 | P2 | Low |
| **Safety** | ECC / FSM parity / Timeout | - | P0 | Medium |

---

## 2. Protocol RTL-Coding Detail

### 2.1 IEEE 802.3 MAC - RTL-Coding Detail

#### 2.1.1 Exact Frame Format (Byte-by-Byte)

```
IEEE 802.3 Ethernet Frame (on-wire order, LSB first per octet)

Byte Offset | Field                    | Size     | Value/Note
------------|--------------------------|----------|----------------------------------
0..6        | Preamble                 | 7 bytes  | 0x55 0x55 0x55 0x55 0x55 0x55 0x55
7           | SFD (Start Frame Delim.) | 1 byte   | 0xD5
8..13       | DA (Destination MAC)     | 6 bytes  | Bit0 of Byte8 = I/G (0=unicast, 1=group)
                                          |          | Bit1 of Byte8 = U/L (0=global, 1=local)
14..19      | SA (Source MAC)            | 6 bytes  | Same I/G/U/L semantics as DA
20..21      | Type/Length                | 2 bytes  | > 1536 (0x0600) = Type (EtherType)
                                          |          | <= 1500 = Length
22..21+n    | Payload                    | 46-1500B | n = length field value or 1500 max
                                          |          | If payload < 46B, pad to 46B
22+pad..end-4 | Payload + Pad            | 46-1500B | Pad bytes = 0x00
end-3..end  | FCS (CRC-32)               | 4 bytes  | CRC-32 polynomial = 0x04C11DB7

Minimum frame size (DA+SA+Type/Length+Payload+Pad) = 64 bytes
Maximum frame size (without VLAN/Q-tag) = 1518 bytes
Maximum frame size (with single VLAN tag) = 1522 bytes
Maximum jumbo frame (if supported) = 9018 or 16000 bytes

Total on-wire size including Preamble+SFD+FCS:
  Min: 7+1+6+6+2+46+4 = 72 bytes (576 bit-times @ 100M = 5.76 μs)
  Std max: 7+1+6+6+2+1500+4 = 1526 bytes
```

**RTL Implementation Note**: The TX Engine must prepend preamble, append FCS, and insert padding. The RX Engine must strip preamble/SFD, verify FCS, and detect runt/giant frames.

#### 2.1.2 TX FSM (Transmit State Machine) - Exact States & Transitions

```verilog
// TX FSM States
localparam TX_IDLE      = 4'd0;
localparam TX_PREAMBLE  = 4'd1;
localparam TX_SFD       = 4'd2;
localparam TX_DATA      = 4'd3;
localparam TX_PAD       = 4'd4;
localparam TX_FCS       = 4'd5;
localparam TX_IFG       = 4'd6;
localparam TX_ERROR     = 4'd7;
localparam TX_JAM       = 4'd8;

// State Transition Conditions (posedge clk_mac)
// Reset: rst_n = 0 → TX_IDLE

case (tx_state)

TX_IDLE:
  if (tx_start && tx_enable) begin
    // tx_start: MTL FIFO signals frame available
    // tx_enable: MAC_Configuration.TE (Transmit Enable, bit 3)
    next_state = TX_PREAMBLE;
    tx_byte_cnt <= 0;
    crc_reg <= 32'hFFFFFFFF;  // CRC initial value
  end

TX_PREAMBLE:
  // Output 0x55 for 7 bytes (56 bits)
  // At MII: 14 nibbles (7 bytes × 2 nibble/byte)
  // At GMII/RGMII: 7 bytes
  if (tx_byte_cnt == 7) begin
    next_state = TX_SFD;
    tx_byte_cnt <= 0;
  end else begin
    tx_mii_data = 4'h5;  // MII: nibble
    tx_gmii_data = 8'h55; // GMII/RGMII: byte
    tx_byte_cnt <= tx_byte_cnt + 1;
    // CRC not computed during preamble
  end

TX_SFD:
  // Output 0xD5 (1 byte)
  tx_mii_data = 4'hD;
  tx_gmii_data = 8'hD5;
  next_state = TX_DATA;
  tx_byte_cnt <= 0;       // Payload byte counter
  tx_crc_byte_cnt <= 0;   // FCS byte counter
  crc_reg <= 32'hFFFFFFFF;

TX_DATA:
  // Output payload bytes from MTL FIFO
  if (tx_byte_cnt < tx_payload_length) begin
    tx_gmii_data = tx_fifo_rdata;
    tx_byte_cnt <= tx_byte_cnt + 1;
    
    // CRC-32 bit-by-bit computation (LSB first per byte)
    // Polynomial: 0x04C11DB7 (x^32 + x^26 + x^23 + x^22 + x^16 +
    //                         x^12 + x^11 + x^10 + x^8 + x^7 +
    //                         x^5 + x^4 + x^2 + x + 1)
    for (i = 0; i < 8; i = i + 1) begin
      crc_bit = crc_reg[31] ^ tx_fifo_rdata[i];  // i=0 is LSB first
      crc_reg = {crc_reg[30:0], 1'b0};
      if (crc_bit) crc_reg = crc_reg ^ 32'h04C11DB7;
    end
    
  end else begin
    // Payload exhausted
    if (tx_byte_cnt < 46) begin
      // Need padding: minimum payload = 46 bytes
      // Total DA+SA+Type/Length+Payload+Pad = 64 bytes
      next_state = TX_PAD;
    end else begin
      next_state = TX_FCS;
      tx_crc_byte_cnt <= 0;
    end
  end

TX_PAD:
  // Output padding bytes (0x00) until payload reaches 46 bytes
  tx_gmii_data = 8'h00;
  tx_byte_cnt <= tx_byte_cnt + 1;
  
  // CRC continues over pad bytes
  for (i = 0; i < 8; i = i + 1) begin
    crc_bit = crc_reg[31] ^ 1'b0;
    crc_reg = {crc_reg[30:0], 1'b0};
    if (crc_bit) crc_reg = crc_reg ^ 32'h04C11DB7;
  end
  
  if (tx_byte_cnt == 46) begin
    next_state = TX_FCS;
    tx_crc_byte_cnt <= 0;
  end

TX_FCS:
  // Output CRC-32 (bit-reversed, complemented)
  // CRC on wire order: crc_reg bit-reversed per byte, then one's complement
  // Byte 0: {~crc_reg[24], ~crc_reg[25], ..., ~crc_reg[31]} (reversed)
  // Byte 1: {~crc_reg[16], ..., ~crc_reg[23]} (reversed)
  // Byte 2: {~crc_reg[8], ..., ~crc_reg[15]} (reversed)
  // Byte 3: {~crc_reg[0], ..., ~crc_reg[7]} (reversed)
  case (tx_crc_byte_cnt)
    0: tx_gmii_data = ~{crc_reg[24], crc_reg[25], crc_reg[26], crc_reg[27],
                         crc_reg[28], crc_reg[29], crc_reg[30], crc_reg[31]};
    1: tx_gmii_data = ~{crc_reg[16], crc_reg[17], crc_reg[18], crc_reg[19],
                         crc_reg[20], crc_reg[21], crc_reg[22], crc_reg[23]};
    2: tx_gmii_data = ~{crc_reg[8], crc_reg[9], crc_reg[10], crc_reg[11],
                         crc_reg[12], crc_reg[13], crc_reg[14], crc_reg[15]};
    3: tx_gmii_data = ~{crc_reg[0], crc_reg[1], crc_reg[2], crc_reg[3],
                         crc_reg[4], crc_reg[5], crc_reg[6], crc_reg[7]};
  endcase
  
  tx_crc_byte_cnt <= tx_crc_byte_cnt + 1;
  if (tx_crc_byte_cnt == 3) begin
    next_state = TX_IFG;
    tx_ifg_cnt <= 0;
  end

TX_IFG:
  // Inter-Frame Gap = minimum 96 bit-times
  // Programmable range: 64 ~ 224 bit-times (MAC_Configuration.IPG[2:0])
  // 1000M: 96 bit-times = 96 ns (GMII 1 byte/cycle @ 125MHz)
  // 100M: 96 bit-times = 960 ns (MII 1 nibble/cycle @ 25MHz)
  // 10M: 96 bit-times = 9.6 μs
  tx_gmii_data = 8'h00;  // Idle
  tx_gmii_en = 0;
  tx_ifg_cnt <= tx_ifg_cnt + 1;
  
  if (tx_ifg_cnt >= programmed_ipg_bit_times) begin
    next_state = TX_IDLE;
  end

TX_ERROR:
  // Entered from TX_DATA/TX_PAD on underflow or collision (half-duplex)
  next_state = TX_JAM;
  tx_jam_cnt <= 0;

TX_JAM:
  // Jam pattern: 0x55 repeated for 32 bits (4 bytes) minimum
  tx_gmii_data = 8'h55;
  tx_jam_cnt <= tx_jam_cnt + 1;
  if (tx_jam_cnt >= 3) begin
    next_state = TX_IFG;
    tx_ifg_cnt <= 0;  // Start IFG from jam completion
  end

endcase
```

**Critical Timing**: SFD byte (0xD5) must be contiguous with preamble. No gap allowed between Preamble-SFD-Data. IFG starts after FCS last bit.

#### 2.1.3 RX FSM (Receive State Machine) - Exact States & Transitions

```verilog
// RX FSM States
localparam RX_IDLE      = 4'd0;
localparam RX_PREAMBLE  = 4'd1;
localparam RX_SFD       = 4'd2;
localparam RX_DATA      = 4'd3;
localparam RX_FCS       = 4'd4;
localparam RX_DROP      = 4'd5;
localparam RX_IFG       = 4'd6;
localparam RX_RUNT      = 4'd7;
localparam RX_GIANT     = 4'd8;

// State Transition Conditions (posedge clk_mac)
// Reset: rst_n = 0 → RX_IDLE

case (rx_state)

RX_IDLE:
  // Wait for carrier sense (CRS) or RX_DV assertion
  if (rx_dv) begin  // MII: RX_DV; RGMII: rx_ctrl
    rx_byte_cnt <= 0;
    rx_crc_reg <= 32'hFFFFFFFF;
    next_state = RX_PREAMBLE;
  end

RX_PREAMBLE:
  // Expect 7 bytes of 0x55
  if (rx_data == 8'h55 || rx_nibble == 4'h5) begin
    rx_preamble_cnt <= rx_preamble_cnt + 1;
    if (rx_preamble_cnt == 6) begin  // 7 bytes received (0..6)
      next_state = RX_SFD;
    end
  end else if (rx_data != 8'h55 && rx_dv) begin
    // Preamble error - abort
    next_state = RX_DROP;
    rx_drop_reason <= PREAMBLE_ERR;
  end else if (!rx_dv) begin
    // Carrier lost during preamble
    next_state = RX_IFG;
  end

RX_SFD:
  // Expect SFD = 0xD5
  if (rx_data == 8'hD5 || rx_nibble == 4'hD) begin
    next_state = RX_DATA;
    rx_byte_cnt <= 0;
    rx_fcs_cnt <= 0;
    rx_crc_reg <= 32'hFFFFFFFF;
  end else begin
    next_state = RX_DROP;
    rx_drop_reason <= SFD_ERR;
  end

RX_DATA:
  // Receive frame data
  if (rx_dv) begin
    // Write to RX FIFO (MTL)
    rx_fifo_wdata = rx_data;
    rx_fifo_wen = 1;
    rx_byte_cnt <= rx_byte_cnt + 1;
    
    // CRC computation (same polynomial as TX, but on received data)
    for (i = 0; i < 8; i = i + 1) begin
      crc_bit = rx_crc_reg[31] ^ rx_data[i];  // LSB first
      rx_crc_reg = {rx_crc_reg[30:0], 1'b0};
      if (crc_bit) rx_crc_reg = rx_crc_reg ^ 32'h04C11DB7;
    end
    
    // Frame size checks
    if (rx_byte_cnt == 1 && rx_data[0]) begin
      // First bit of DA: I/G bit
      rx_is_multicast = rx_data[0];
    end
    if (rx_byte_cnt == 1518) begin  // Standard max without VLAN
      next_state = RX_GIANT;
    end
  end else begin
    // RX_DV deasserted = end of frame
    if (rx_byte_cnt < 64) begin
      next_state = RX_RUNT;  // Runt frame (< 64 bytes)
    end else begin
      next_state = RX_FCS;
      rx_fcs_cnt <= 0;
    end
  end

RX_FCS:
  // Compare received FCS with computed CRC
  // Expected: rx_crc_reg should equal 32'hC704DD7B (magic residue)
  // when all bytes (including FCS) are fed through CRC engine
  if (rx_crc_reg == 32'hC704DD7B) begin
    rx_fcs_ok = 1;
  end else begin
    rx_fcs_ok = 0;
    rx_drop_reason <= FCS_ERR;
  end
  
  // Push frame to MTL with status word
  rx_status = {rx_fcs_ok, rx_byte_cnt, rx_is_multicast, ...};
  next_state = RX_IFG;
  rx_ifg_cnt <= 0;

RX_DROP:
  // Discard frame until RX_DV deasserted
  rx_fifo_wen = 0;  // Don't write to FIFO
  if (!rx_dv) begin
    next_state = RX_IFG;
    rx_ifg_cnt <= 0;
  end

RX_RUNT:
  // Frame < 64 bytes (including FCS)
  rx_drop_reason <= RUNT_FRAME;
  next_state = RX_DROP;

RX_GIANT:
  // Frame exceeds max size
  rx_drop_reason <= GIANT_FRAME;
  next_state = RX_DROP;

RX_IFG:
  // Minimum 96 bit-times gap before next frame
  rx_ifg_cnt <= rx_ifg_cnt + 1;
  if (rx_ifg_cnt >= 96) begin
    next_state = RX_IDLE;
  end
  // If RX_DV asserts during IFG, restart (false carrier)
  if (rx_dv) begin
    next_state = RX_PREAMBLE;
    rx_preamble_cnt <= 0;
  end

endcase
```

**CRC Magic Residue**: When all bytes (DA through FCS) are fed through the CRC engine initialized to 0xFFFFFFFF, the final value should be 0xC704DD7B if the FCS is correct. RTL can check this residue or compute expected FCS separately.

#### 2.1.4 CRC-32 Algorithm - Bit-by-Bit RTL Implementation

```verilog
// CRC-32 module (used by both TX and RX)
// Polynomial: x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 +
//             x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
// Represented as 0x04C11DB7 (MSB = x^32 coefficient, omitted)

module crc32_8023 (
  input        clk,
  input        rst_n,
  input        crc_en,
  input  [7:0] data_in,    // LSB first per byte
  input        data_valid,
  output [31:0] crc_out,    // Running CRC (not final)
  output [31:0] crc_final   // Bit-reversed, complemented final FCS
);

  reg [31:0] crc_reg;
  wire [31:0] crc_next;
  
  // Bit-by-bit serial CRC (8 cycles per byte)
  // For RTL: unroll into combinatorial logic for single-cycle
  
  function [31:0] crc32_byte;
    input [7:0] b;
    input [31:0] c;
    begin
      // Unrolled LSB-first computation
      // Each step: c = {c[30:0], 0} ^ (c[31] ? 0x04C11DB7 : 0)
      crc32_byte = c;
      crc32_byte = crc32_byte[31] ? (crc32_byte << 1) ^ 32'h04C11DB7 : (crc32_byte << 1);
      crc32_byte[0] = crc32_byte[0] ^ b[0];
      // ... (full unrolling for all 8 bits)
    end
  endfunction
  
  // For production RTL, use lookup table or full combinatorial:
  // Generated CRC table for 0x04C11DB7, LSB-first:
  // (Use standard CRC32 tool to generate Verilog table)
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) crc_reg <= 32'hFFFFFFFF;
    else if (crc_en && data_valid) begin
      // Single-cycle byte-wise CRC using lookup or parallel XOR tree
      crc_reg <= crc32_table(data_in) ^ {crc_reg[7:0], 24'h0} ^ crc_reg[31:8];
    end
  end
  
  // Final FCS computation
  assign crc_final = ~{crc_reg[0], crc_reg[1], ..., crc_reg[31]};  // Bit reverse + complement
  
endmodule
```

#### 2.1.5 PAUSE Frame Format & Quanta Handling

```
IEEE 802.3x PAUSE Frame Format

Byte | Field                 | Value
-----|-----------------------|-------------------
0-5  | DA                    | 01:80:C2:00:00:01 (Multicast)
6-11 | SA                    | Source MAC
12-13| Type/EtherType        | 0x8808 (MAC Control)
14-15| MAC Control Opcode    | 0x0001 (PAUSE)
16-17| PAUSE Quanta          | 0x0000 ~ 0xFFFF
18-63| Padding (if needed)   | 0x00
end-3| FCS                   | CRC-32

PAUSE Quanta: 1 quanta = 512 bit-times
  1000M: 1 quanta = 512 ns
  100M:  1 quanta = 5.12 μs
  10M:   1 quanta = 51.2 μs

Max PAUSE duration = 65535 × 512 bit-times
  1000M: ~33.5 ms
  100M:  ~335 ms
  10M:   ~3.35 s

RTL Implementation:
- RX: Detect DA=01:80:C2:00:00:01 && Type=0x8808 && Opcode=0x0001
      Extract quanta[15:0], write to pause_quanta register
      Assert tx_pause_req to MTL/Scheduler
- TX: On pause_quanta > 0, decrement at 512 bit-time rate
      Stop transmission when quanta > 0 (unless tx_pause_ignore=1)
      Zero-quanta PAUSE = immediate resume
```

#### 2.1.6 MII/GMII/RGMII Interface Timing

**MII Interface (4-bit nibble, separate TX/RX clocks)**

```
Signal        | Direction | Width | Timing
--------------|-----------|-------|-----------------------------------
TX_CLK        | Input     | 1     | 25MHz @ 100M, 2.5MHz @ 10M
TX_EN         | Output    | 1     | Assert with first nibble of preamble
TXD[3:0]      | Output    | 4     | Valid when TX_EN=1, LSN first
TX_ER         | Output    | 1     | Assert with error nibble
RX_CLK        | Input     | 1     | 25MHz @ 100M, 2.5MHz @ 10M
RX_DV         | Input     | 1     | Assert with first nibble of SFD
RXD[3:0]      | Input     | 4     | Valid when RX_DV=1
RX_ER         | Input     | 1     | Error indicator
CRS           | Input     | 1     | Carrier sense (OR of RX_DV and TX_EN)
COL           | Input     | 1     | Collision detect (half-duplex)

MII TX Timing Diagram:
       __    __    __    __    __    __    __    __
TX_CLK    |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
          |<- Preamble ->|<-  SFD  ->|<- Data Byte 0 ->|<- Data 1 ->
TX_EN  ___|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
TXD    ---| 5 | 5 | 5 | 5 | 5 | 5 | 5 | D | 5 | Data[3:0] | Data[7:4]|
          |<- 7 bytes -->|1B |<-      Byte 0 (LSN first)      ->|

Setup time: TXD to TX_CLK rising ≥ 5ns
Hold time: TXD from TX_CLK rising ≥ 5ns
Clock duty cycle: 40%-60%
```

**GMII Interface (8-bit byte, 125MHz)**

```
Signal        | Direction | Width | Timing
--------------|-----------|-------|-----------------------------------
GTX_CLK       | Output    | 1     | 125MHz (from MAC to PHY)
TX_EN         | Output    | 1     | Assert with first byte of preamble
TXD[7:0]      | Output    | 8     | Valid when TX_EN=1
TX_ER         | Output    | 1     | Error indicator
RX_CLK        | Input     | 1     | 125MHz (from PHY to MAC)
RX_DV         | Input     | 1     | Assert with first byte of SFD
RXD[7:0]      | Input     | 8     | Valid when RX_DV=1
RX_ER         | Input     | 1     | Error indicator
CRS           | Input     | 1     | Carrier sense
COL           | Input     | 1     | Collision detect

Setup time: TXD to GTX_CLK rising ≥ 2.5ns
Hold time: TXD from GTX_CLK rising ≥ 0.5ns
```

**RGMII Interface (4-bit DDR, 125MHz)**

```
Signal        | Direction | Width | Timing
--------------|-----------|-------|-----------------------------------
TXC           | Output    | 1     | 125MHz (edge-aligned, DDR)
TXD[3:0]      | Output    | 4     | Rising edge = Data[3:0], Falling edge = Data[7:4]
TX_CTL        | Output    | 1     | Rising edge = TX_EN, Falling edge = TX_EN ^ TX_ER
RXC           | Input     | 1     | 125MHz (delayed from PHY)
RXD[3:0]      | Input     | 4     | Rising edge = Data[3:0], Falling edge = Data[7:4]
RX_CTL        | Input     | 1     | Rising edge = RX_DV, Falling edge = RX_DV ^ RX_ER

RGMII TX Timing (at MAC output, before PCB delay):
       __    __    __    __    __    __    __    __
TXC       |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
          |Rise|Fall|Rise|Fall|Rise|Fall|Rise|Fall|Rise|Fall|Rise|Fall|
TXD    ---|D[3:0]|D[7:4]|D[3:0]|D[7:4]|D[3:0]|D[7:4]|D[3:0]|D[7:4]|
TX_CTL ___| TX_EN|  ERR | TX_EN|  ERR | TX_EN|  ERR | TX_EN|  ERR |

Skew Requirements:
- Data-to-clock skew at MAC transmitter: +500ps to -500ps
- PHY internal delay: typically 1.5~2.0ns
- PCB trace delay budget: ±100ps
- Total RXC-to-RXD skew at receiver: ±1.5ns (including PHY delay)

RTL Implementation Notes:
- TX: DDR output using ODDR primitive or fabric logic
      TX_CTL rising = TX_EN, falling = TX_EN ^ TX_ER
- RX: IDDR primitive to recover [3:0] and [7:4]
      RX_DV = RX_CTL rising edge
      RX_ER = RX_CTL rising ^ RX_CTL falling
- Internal delay line (IDELAY) for RXC or RXD if needed
```

---

#### 2.1.7 MDIO Management Interface - RTL-Coding Detail

**Frame Format (IEEE 802.3-2022 Clause 22):**

```
MDIO Frame: 32 bits total (preamble + start + op + PHYAD + REGAD + TA + data)

Bit Position | Field      | Size | Value
-------------|------------|------|--------
0-31         | Preamble   | 32   | 1's (optional, may be shorter)
32-33        | Start      | 2    | 01 (always)
34-35        | Op Code    | 2    | 01=write, 10=read
36-40        | PHYAD      | 5    | PHY address (0-31)
41-45        | REGAD      | 5    | Register address (0-31)
46-47        | TA         | 2    | Z0 (read) or 10 (write)
48-63        | Data       | 16   | Register data
```

**Timing:**
```
          ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐
MDC       ─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─
           ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑
MDIO       P   P   P   S   S   O   O   A  ...
           ↑preamble↑  ↑st↑  ↑op↑  ↑phy↑
```
- MDC max frequency: 2.5MHz
- MDIO setup time: 10ns min (before MDC rising)
- MDIO hold time: 10ns min (after MDC rising)

**Basic Registers (Clause 22):**

| Register | Address | Description |
|----------|---------|-------------|
| Control | 0 | Reset, loopback, speed select, duplex, autoneg |
| Status | 1 | Autoneg complete, link status, capability |
| PHY ID 1 | 2 | OUI bits [3:18] |
| PHY ID 2 | 3 | OUI bits [19:24], model, revision |
| Autoneg Advertisement | 4 | Advertised abilities |
| Autoneg Link Partner | 5 | Link partner abilities |

**Control Register (Reg 0) Bit Map:**
```
Bit 15: Reset (1=reset, self-clearing)
Bit 14: Loopback (1=loopback mode)
Bit 13: Speed Select [1] (1=1000Mbps if bit 6=1, else 100Mbps)
Bit 12: Autoneg Enable (1=enable)
Bit 11: Power Down (1=power down)
Bit 10: Isolate (1=electrical isolation)
Bit 9:  Restart Autoneg (1=restart, self-clearing)
Bit 8:  Duplex Mode (1=full, 0=half)
Bit 7:  Collision Test (1=enable collision test)
Bit 6:  Speed Select [0] (1=1000Mbps, see bit 13)
Bits 5-0: Reserved
```

**Status Register (Reg 1) Bit Map:**
```
Bit 15: 100BASE-T4 capability (always 0)
Bit 14: 100BASE-X Full Duplex capability
Bit 13: 100BASE-X Half Duplex capability
Bit 12: 10Mbps Full Duplex capability
Bit 11: 10Mbps Half Duplex capability
Bit 10: 100BASE-T2 Full Duplex capability
Bit 9:  100BASE-T2 Half Duplex capability
Bit 8:  Extended Status (1=Reg 17 supported)
Bit 7:  Reserved
Bit 6:  MF Preamble Suppression (1=can suppress preamble)
Bit 5:  Autoneg Complete (1=complete)
Bit 4:  Remote Fault (1=fault detected)
Bit 3:  Autoneg Capability (1=can perform autoneg)
Bit 2:  Link Status (1=link up, 0=link down; latches low)
Bit 1:  Jabber Detect (1=jabber detected; latches high)
Bit 0:  Extended Capability (1=supports registers beyond 0-15)
```

**RTL Implementation:**
```verilog
module mdio_controller (
    input  wire        clk_sys,       // System clock (>= 25MHz)
    input  wire        rst_n,
    // MDIO interface
    output reg         mdc,
    inout  wire        mdio,
    // Control interface
    input  wire        start,
    input  wire        op,            // 0=write, 1=read
    input  wire [4:0]  phy_addr,
    input  wire [4:0]  reg_addr,
    input  wire [15:0] write_data,
    output reg  [15:0] read_data,
    output reg         done,
    output reg         busy
);
    // MDC generation: clk_sys / 10 (2.5MHz from 25MHz)
    reg [3:0] mdc_div;
    always @(posedge clk_sys or negedge rst_n) begin
        if (!rst_n) begin
            mdc_div <= 0;
            mdc <= 0;
        end else begin
            if (mdc_div >= 4'd9) begin
                mdc_div <= 0;
                mdc <= ~mdc;
            end else begin
                mdc_div <= mdc_div + 1;
            end
        end
    end

    // MDIO state machine
    localparam IDLE      = 4'd0;
    localparam PREAMBLE  = 4'd1;
    localparam START     = 4'd2;
    localparam OP        = 4'd3;
    localparam PHYAD     = 4'd4;
    localparam REGAD     = 4'd5;
    localparam TA        = 4'd6;
    localparam DATA      = 4'd7;
    localparam DONE      = 4'd8;

    reg [3:0]  state;
    reg [4:0]  bit_cnt;
    reg [31:0] shift_reg;
    reg        mdio_out;
    reg        mdio_oe;

    assign mdio = mdio_oe ? mdio_out : 1'bz;

    always @(posedge mdc or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_cnt <= 0;
            shift_reg <= 0;
            mdio_out <= 1;
            mdio_oe <= 0;
            done <= 0;
            busy <= 0;
        end else begin
            done <= 0;
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= PREAMBLE;
                        bit_cnt <= 0;
                        shift_reg <= {32'hFFFFFFFF, 2'b01, ~op, op, phy_addr, reg_addr, (op ? 2'bZ0 : 2'b10), write_data};
                        busy <= 1;
                        mdio_oe <= 1;
                    end
                end
                PREAMBLE: begin
                    mdio_out <= 1;
                    if (bit_cnt >= 31) begin
                        state <= START;
                        bit_cnt <= 0;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                START: begin
                    mdio_out <= shift_reg[63]; // bit 63 = start[1]
                    shift_reg <= shift_reg << 1;
                    state <= OP;
                end
                OP: begin
                    mdio_out <= shift_reg[63];
                    shift_reg <= shift_reg << 1;
                    if (bit_cnt >= 1) begin
                        state <= PHYAD;
                        bit_cnt <= 0;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                PHYAD: begin
                    mdio_out <= shift_reg[63];
                    shift_reg <= shift_reg << 1;
                    if (bit_cnt >= 4) begin
                        state <= REGAD;
                        bit_cnt <= 0;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                REGAD: begin
                    mdio_out <= shift_reg[63];
                    shift_reg <= shift_reg << 1;
                    if (bit_cnt >= 4) begin
                        state <= TA;
                        bit_cnt <= 0;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                TA: begin
                    if (op) begin // READ: Z0, release bus for PHY to drive
                        if (bit_cnt == 0) begin
                            mdio_oe <= 0; // Release bus (Z)
                        end else begin
                            mdio_oe <= 0;
                        end
                    end else begin // WRITE: 10
                        mdio_out <= shift_reg[63];
                        shift_reg <= shift_reg << 1;
                    end
                    if (bit_cnt >= 1) begin
                        state <= DATA;
                        bit_cnt <= 0;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                DATA: begin
                    if (op) begin
                        // READ: sample MDIO on rising edge
                        shift_reg <= {shift_reg[62:0], mdio};
                    end else begin
                        // WRITE: drive data
                        mdio_out <= shift_reg[63];
                        shift_reg <= shift_reg << 1;
                    end
                    if (bit_cnt >= 15) begin
                        state <= DONE;
                        if (op) read_data <= {shift_reg[62:0], mdio};
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                DONE: begin
                    done <= 1;
                    busy <= 0;
                    mdio_oe <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
```

---

### 2.2 IEEE 802.1AS-2020 gPTP - RTL-Coding Detail

#### 2.2.1 gPTP Message Formats (Byte-by-Byte)

All gPTP messages share a common header:

```
gPTP Common Header (34 bytes before body)

Byte | Field                          | Size | Value / Note
-----|--------------------------------|------|----------------------------------
0    | transportSpecific + messageType| 1    | Bits[7:4]=transportSpecific(0x1)
                                      |      | Bits[3:0]=messageType (see below)
1    | versionPTP                     | 1    | 0x02
2-3  | messageLength                  | 2    | Total message length
4    | domainNumber                   | 1    | 0x00 (gPTP domain)
5    | minorSdoId                     | 1    | 0x00
6-7  | flags                          | 2    | Bit flags (see below)
8-15 | correctionField                | 8    | Signed 64-bit nanoseconds × 2^16
16-23| sourcePortIdentity             | 8    | {clockIdentity[64], portNumber[16]}
24   | sequenceId                     | 2    | Per-message-type counter
26   | logMessageInterval             | 1    | Log2 of message interval
27-33| reserved                       | 7    | 0x00

Message Types:
  0x0 = Sync
  0x1 = Pdelay_Req
  0x2 = Pdelay_Resp
  0x3 = Pdelay_Resp_Follow_Up
  0x8 = Follow_Up
  0x9 = Delay_Resp
  0xB = Announce
  0xC = Signaling
  0xD = Management

Flag Bits (byte 6-7):
  Bit 0 (LSB of byte 6): alternateMasterFlag
  Bit 1: twoStepFlag (1 = two-step clock)
  Bit 2: unicastFlag
  Bit 3: profileSpecific1 (PTP profile specific)
  Bit 4: profileSpecific2
  Bit 5: reserved
  Bit 6: reserved
  Bit 7: leap61
  Bit 8: leap59
  Bit 9: currentUtcOffsetValid
  Bit 10: ptpTimescale
  Bit 11: timeTraceable
  Bit 12: frequencyTraceable
  Bit 13: alternateTimeSourceOffsetValid
  Bit 14: profileSpecific3
  Bit 15: profileSpecific4
```

**Sync Message Body (10 bytes, total = 44 bytes)**
```
Byte | Field              | Size
-----|--------------------|------
34-39| originTimestamp    | 10   | {seconds[48], nanoseconds[32]} - only in one-step
40-43| reserved           | 4
```

**Follow_Up Message Body (10 bytes)**
```
Byte | Field              | Size
-----|--------------------|------
34-43| preciseOriginTimestamp | 10 | {seconds[48], nanoseconds[32]}
44-47| reserved           | 4
```

**Delay_Req Message Body (10 bytes)**
```
Byte | Field              | Size
-----|--------------------|------
34-43| originTimestamp    | 10 | {seconds[48], nanoseconds[32]}
44-47| reserved           | 4
```

**Delay_Resp Message Body (20 bytes)**
```
Byte | Field              | Size
-----|--------------------|------
34-43| receiveTimestamp   | 10 | {seconds[48], nanoseconds[32]}
44-51| requestingPortIdentity | 8 | {clockIdentity[64], portNumber[16]}
52   | reserved           | 1
53   | reserved           | 1
54   | logMessageInterval | 1
55   | reserved           | 1
```

**Pdelay_Req Message Body (20 bytes)**
```
Byte | Field              | Size
-----|--------------------|------
34-43| originTimestamp    | 10 | {seconds[48], nanoseconds[32]}
44-51| reserved           | 8
52   | reserved           | 1
53   | reserved           | 1
54   | logMessageInterval | 1
55   | reserved           | 1
```

**Pdelay_Resp Message Body (20 bytes)**
```
Byte | Field              | Size
-----|--------------------|------
34-43| requestReceiptTimestamp | 10 | {seconds[48], nanoseconds[32]}
44-51| requestingPortIdentity  | 8  | {clockIdentity[64], portNumber[16]}
52   | reserved           | 1
53   | reserved           | 1
54   | logMessageInterval | 1
55   | reserved           | 1
```

**Pdelay_Resp_Follow_Up Message Body (20 bytes)**
```
Byte | Field              | Size
-----|--------------------|------
34-43| responseOriginTimestamp | 10 | {seconds[48], nanoseconds[32]}
44-51| requestingPortIdentity | 8  | {clockIdentity[64], portNumber[16]}
52   | reserved           | 1
53   | reserved           | 1
54   | logMessageInterval | 1
55   | reserved           | 1
```

**Announce Message Body (28 bytes)**
```
Byte | Field              | Size
-----|--------------------|------
34-43| originTimestamp    | 10 | {seconds[48], nanoseconds[32]}
44-47| currentUtcOffset   | 2  | Signed integer
48   | reserved           | 1
49   | grandmasterPriority1 | 1
50-55| grandmasterClockQuality | 6 | {class, accuracy, offsetScaledLogVariance}
56   | grandmasterPriority2 | 1
57-64| grandmasterIdentity | 8 | Clock identity
65   | stepsRemoved       | 2
67   | timeSource         | 1
```

#### 2.2.2 Timestamp Capture Point - Exact Timing

```
Timestamp Capture Definition (IEEE 802.1AS-2020, Clause 11.3.1)

Capture Point: "The timestamp point is at the MII/GMII/RGMII boundary
               at the reference plane between the MAC and the PHY."

Exact Timing for TX:
  - One-step clock: Timestamp captured at first bit of SFD (bit 0 of byte 7)
                    on the MII/GMII/RGMII TX interface
  - Two-step clock: Timestamp captured at first bit of SFD
                    Follow_Up message carries this timestamp

Exact Timing for RX:
  - Timestamp captured at first bit of SFD on MII/GMII/RGMII RX interface

SFD Detection:
  MII (4-bit): After 14 nibbles of preamble (7 bytes), SFD = nibble with value D
               Timestamp at nibble boundary when TX_EN/RX_DV still asserted
               and nibble value changes from 5 to D
  
  GMII (8-bit): After 7 bytes of 0x55, SFD = 0xD5
                Timestamp at byte boundary when data == 0xD5
  
  RGMII (4-bit DDR): Same as MII but at DDR rate
                     125MHz clock, 4 bits per edge

RTL Implementation:
  wire tx_sfd_detect = (tx_state == TX_PREAMBLE) && (tx_byte_cnt == 7);
  always @(posedge clk_mac) begin
    if (tx_sfd_detect) begin
      tx_timestamp <= ptp_time;  // 80-bit {seconds[48], ns[32]}
    end
  end

  wire rx_sfd_detect = (rx_state == RX_SFD) && (rx_data == 8'hD5);
  always @(posedge clk_mac) begin
    if (rx_sfd_detect) begin
      rx_timestamp <= ptp_time;
    end
  end

Timestamp Precision Requirements:
  - gPTP requires < 50ns error for 1Gbps
  - At 125MHz (8ns cycle), single-cycle capture is sufficient
  - Use clk_ts (250MHz) for finer granularity if needed (4ns resolution)
```

#### 2.2.3 Clock Format - 80-bit Timestamp

```
PTP Timestamp Format (IEEE 1588 / 802.1AS)

Total: 80 bits
  Bits[79:32] = seconds (48 bits, unsigned)
  Bits[31:0]  = nanoseconds (32 bits, 0 ~ 999,999,999)

Maximum time: 2^48 seconds ≈ 8,927,463 years
Nanosecond overflow: when ns >= 1,000,000,000
  seconds <= seconds + 1
  nanoseconds <= nanoseconds - 1,000,000,000

Addend Register (for frequency compensation):
  - 32-bit unsigned fractional value
  - Addend added to accumulator every clock cycle
  - Accumulator overflow triggers nanosecond increment
  
  Example: clk_ts = 250MHz (4ns period)
    To count real nanoseconds (1ns resolution):
    Addend = (2^32 / 4) = 1,073,741,824 = 0x4000_0000
    
    For drift compensation (e.g., +10ppm):
    Addend_corrected = Addend × (1 + 10/1,000,000)
                     = 0x4000_0000 × 1.000010
                     ≈ 0x4001_5555

RTL Implementation:
  reg [47:0] ptp_seconds;
  reg [31:0] ptp_nanoseconds;
  reg [31:0] ptp_addend;
  reg [63:0] ptp_accumulator;  // Extended for precision
  
  always @(posedge clk_ts or negedge rst_ts_n) begin
    if (!rst_ts_n) begin
      ptp_seconds <= 0;
      ptp_nanoseconds <= 0;
      ptp_accumulator <= 0;
    end else begin
      ptp_accumulator <= ptp_accumulator + {32'h0, ptp_addend};
      if (ptp_accumulator[63:32] >= ptp_accumulator[31:0]) begin
        // Overflow check: when upper 32 bits >= lower (threshold)
        ptp_nanoseconds <= ptp_nanoseconds + 1;
        ptp_accumulator <= ptp_accumulator - (1 << 32);
      end
      if (ptp_nanoseconds >= 1_000_000_000) begin
        ptp_nanoseconds <= ptp_nanoseconds - 1_000_000_000;
        ptp_seconds <= ptp_seconds + 1;
      end
    end
  end
```

#### 2.2.4 BMCA State Machine & Dataset Comparison

```
Best Master Clock Algorithm (BMCA) State Machine

States:
  BMCA_INIT          = 3'd0
  BMCA_LISTENING     = 3'd1  // Collecting Announce messages
  BMCA_COMPARING     = 3'd2  // Running dataset comparison
  BMCA_SLAVE         = 3'd3  // Selected as slave (sync to GM)
  BMCA_MASTER        = 3'd4  // Selected as grandmaster
  BMCA_PASSIVE       = 3'd5  // Passive port (not GM, not slave)
  BMCA_UNCALIBRATED  = 3'd6  // Waiting for sync
  BMCA_FAULTY        = 3'd7  // Port faulty

State Transitions:
  BMCA_INIT:
    → BMCA_LISTENING (after port initialization)

  BMCA_LISTENING:
    → BMCA_COMPARING (after announceReceiptTimeout = 3 × announceInterval)
    → BMCA_SLAVE (if received better GM, and port is not disabled)
    → BMCA_MASTER (if no better GM found, and port capable)

  BMCA_COMPARING:
    → BMCA_SLAVE (if gmPriorityVector < portPriorityVector)
    → BMCA_MASTER (if gmPriorityVector > portPriorityVector)
    → BMCA_PASSIVE (if gmPriorityVector == portPriorityVector, and not slave-capable)

Dataset Comparison (Priority Vector, lower is better):

priorityVector = {
    priority1,          // 8 bits, user-configured (default 128)
    clockClass,         // 8 bits (6=locked, 7=holdover, 52=disabled, 187=slave-only)
    clockAccuracy,      // 8 bits (0x20=25ns, 0x21=100ns, 0x22=250ns, ...)
    offsetScaledLogVariance, // 16 bits (0x436A=PTP variance)
    priority2,          // 8 bits, user-configured (default 128)
    clockIdentity,      // 64 bits (EUI-64 based)
    stepsRemoved,       // 16 bits (0 for GM)
    sourcePortIdentity  // 16 bits port number
}

Comparison: Lexicographic compare from priority1 to sourcePortIdentity
  Lower value = better clock

RTL Implementation:
  // Priority vector registers
  reg [7:0]  ds_priority1;
  reg [7:0]  ds_clockClass;
  reg [7:0]  ds_clockAccuracy;
  reg [15:0] ds_offsetScaledLogVariance;
  reg [7:0]  ds_priority2;
  reg [63:0] ds_clockIdentity;
  reg [15:0] ds_stepsRemoved;
  reg [15:0] ds_sourcePortIdentity;
  
  // Comparison function (combinatorial)
  function cmp_priority;
    input [215:0] vec_a, vec_b;
    begin
      cmp_priority = (vec_a < vec_b);  // Unsigned comparison
    end
  endfunction
  
  // State machine
  always @(posedge clk_sys or negedge rst_n) begin
    case (bmca_state)
      BMCA_LISTENING: begin
        if (announce_timer_expired) begin
          if (best_gm_found)
            bmca_state <= BMCA_COMPARING;
          else
            bmca_state <= BMCA_MASTER;
        end
      end
      // ... (full state machine)
    endcase
  end
```

#### 2.2.5 Peer Delay Calculation Formula

```
Peer Delay Calculation (802.1AS Clause 11.2)

Variables:
  t1 = timestamp of Pdelay_Req transmission (at requesting port)
  t2 = timestamp of Pdelay_Req reception (at responding port)
  t3 = timestamp of Pdelay_Resp transmission (at responding port)
  t4 = timestamp of Pdelay_Resp reception (at requesting port)
  correctionField = correctionField from Pdelay_Resp message

Peer Delay (meanPropDelay):
  meanPropDelay = ((t4 - t1) - (t3 - t2) - correctionField) / 2

Where:
  correctionField accounts for residence time in responding port
  All values in nanoseconds (or sub-nanoseconds with fractional part)

Neighbor Rate Ratio (nrr):
  nrr = (t3(n) - t3(n-1)) / (t1(n) - t1(n-1))
  
  Exponential smoothing:
  nrr_filtered = α × nrr_measured + (1-α) × nrr_filtered_prev
  Typical α = 0.1 (configurable)

RTL Implementation:
  reg [79:0] pdelay_t1, pdelay_t2, pdelay_t3, pdelay_t4;
  reg [79:0] pdelay_correction;
  reg [79:0] mean_prop_delay;
  reg [31:0] neighbor_rate_ratio;  // Fixed-point: 16.16
  
  // Delay calculation (signed 80-bit arithmetic)
  wire [79:0] term1 = pdelay_t4 - pdelay_t1;
  wire [79:0] term2 = pdelay_t3 - pdelay_t2;
  wire [79:0] diff = term1 - term2 - pdelay_correction;
  
  // Division by 2 = right shift by 1
  assign mean_prop_delay = diff[79:1];  // /2
  
  // Rate ratio calculation
  wire [79:0] delta_t3 = pdelay_t3_current - pdelay_t3_prev;
  wire [79:0] delta_t1 = pdelay_t1_current - pdelay_t1_prev;
  // Fixed-point division: result = (delta_t3 << 16) / delta_t1
```

#### 2.2.6 PPS Generation Parameters

```
Pulse-Per-Second (PPS) Output

PPS Signal Characteristics:
  - Frequency: 1 Hz (1 pulse per second)
  - Pulse width: Programmable, default 1/2 period (500ms)
  - Output: Single pulse or train of pulses

PPS Control Register (MAC_PPS_Control):
  Bits[3:0]: PPS output control
    0x0 = Single pulse on command
    0x1 = Pulse train (periodic)
    0x2 = Pulse at programmable time
    0x3 = Fine control (using addend)
  Bits[6:4]: Target time interrupt mode

PPS Target Time:
  PPS target seconds: 32-bit register (lower 32 bits of 48-bit seconds)
  PPS target nanoseconds: 32-bit register

PPS Generation Logic:
  pps_output = (ptp_seconds == pps_target_seconds) &&
               (ptp_nanoseconds >= pps_target_ns) &&
               (ptp_nanoseconds < pps_target_ns + pps_pulse_width);

PPS Interval (for pulse train mode):
  Default: 1 second = 1,000,000,000 ns
  Programmable: Any value in nanoseconds

RTL Implementation:
  reg pps_out;
  reg [31:0] pps_target_sec;
  reg [31:0] pps_target_ns;
  reg [31:0] pps_width;
  
  always @(posedge clk_ts) begin
    if (ptp_seconds[31:0] == pps_target_sec &&
        ptp_nanoseconds >= pps_target_ns &&
        ptp_nanoseconds < pps_target_ns + pps_width)
      pps_out <= 1;
    else
      pps_out <= 0;
      
    // Auto-increment target for pulse train
    if (pps_mode == PULSE_TRAIN && ptp_seconds[31:0] > pps_target_sec) begin
      pps_target_sec <= pps_target_sec + pps_interval_sec;
    end
  end
```

---

### 2.3 IEEE 802.1Qbv - Enhanced Scheduled Traffic (EST) - RTL-Coding Detail

#### 2.3.1 GCL Entry Format

```
Gate Control List (GCL) Entry Format

Each GCL Entry: 64 bits (8 bytes)

Bits[63:56] = GateStateVector[7:0]
  Bit[i] = 1: Queue i gate OPEN (transmit allowed)
  Bit[i] = 0: Queue i gate CLOSED (transmit blocked)
  
Bits[55:32] = TimeInterval[23:0] (in nanoseconds)
  Maximum interval: 16,777,215 ns ≈ 16.78 ms
  
Bits[31:0] = reserved / extended (vendor-specific)
  Bit[31]: SetGateStates operation (1) or Set-And-Hold-MAC (0)
  Bit[30]: Interval extension (use extended interval register)

GCL Memory:
  - Depth: 256 entries (configurable: 64/128/256/512)
  - Entry size: 8 bytes
  - Total memory: 256 × 8 = 2048 bytes
  - ECC protection: SECDED per 64-bit entry
  
GCL Entry Example:
  Queue[7:0] = 8'b0000_0001  // Only Queue 0 open
  TimeInterval = 24'd500_000  // 500 μs
  → Queue 0 can transmit for 500 μs, all other queues blocked

RTL Register Definition:
  // GCL Control
  reg gcl_enable;
  reg gcl_cycle_complete;
  reg [7:0] gcl_list_length;     // Number of active entries (1-255)
  reg [31:0] gcl_cycle_time;      // Total cycle time in nanoseconds
  reg [47:0] gcl_base_time_sec;   // Start time: seconds
  reg [31:0] gcl_base_time_ns;    // Start time: nanoseconds
  
  // GCL Memory Interface
  reg [7:0]  gcl_mem_addr;
  reg [63:0] gcl_mem_wdata;
  wire [63:0] gcl_mem_rdata;
  reg        gcl_mem_we;
```

#### 2.3.2 GCL Execution FSM

```verilog
// GCL Execution State Machine
localparam GCL_IDLE      = 3'd0;
localparam GCL_WAIT_BASE = 3'd1;  // Wait for BaseTime
localparam GCL_RUNNING   = 3'd2;  // Execute current entry
localparam GCL_PENDING   = 3'd3;  // Transition between entries
localparam GCL_COMPLETE  = 3'd4;  // Cycle complete

case (gcl_state)

GCL_IDLE:
  if (gcl_enable && gcl_list_length > 0) begin
    if (gcl_base_time_reached)
      gcl_state <= GCL_RUNNING;
    else
      gcl_state <= GCL_WAIT_BASE;
    gcl_entry_idx <= 0;
    gcl_timer <= 0;
  end

GCL_WAIT_BASE:
  // Compare ptp_time with gcl_base_time
  if ({ptp_seconds, ptp_nanoseconds} >= {gcl_base_time_sec, gcl_base_time_ns}) begin
    gcl_state <= GCL_RUNNING;
    gcl_timer <= 0;
  end

GCL_RUNNING:
  // Apply current GCL entry gate state to queue scheduler
  current_gate_vector <= gcl_mem_rdata[63:56];
  
  gcl_timer <= gcl_timer + 1;  // Incremented every 1ns (in ptp_time domain)
  
  if (gcl_timer >= gcl_mem_rdata[55:32]) begin
    // Current entry time expired
    gcl_entry_idx <= gcl_entry_idx + 1;
    gcl_timer <= 0;
    
    if (gcl_entry_idx >= gcl_list_length - 1) begin
      // Last entry complete
      gcl_state <= GCL_COMPLETE;
    end else begin
      gcl_state <= GCL_PENDING;
    end
  end

GCL_PENDING:
  // Transition: check for cycle completion or continue
  if (gcl_entry_idx >= gcl_list_length) begin
    gcl_state <= GCL_COMPLETE;
  end else begin
    gcl_state <= GCL_RUNNING;
    // Load next entry from memory
    gcl_mem_addr <= gcl_entry_idx;
  end

GCL_COMPLETE:
  // Cycle complete: check for cycle time rollover
  if (gcl_cycle_rollover) begin
    gcl_entry_idx <= 0;
    gcl_state <= GCL_RUNNING;
    gcl_timer <= 0;
  end else begin
    gcl_state <= GCL_IDLE;  // Wait for next enable
  end

endcase
```

#### 2.3.3 GCL Cycle Time & Base Time

```
GCL Cycle Parameters

CycleTime: Total duration of one GCL cycle (all entries)
  - 32-bit nanoseconds
  - Range: 1 ns to ~4.29 seconds
  - Must be >= sum of all entry TimeIntervals
  
BaseTime: Absolute start time of first GCL cycle
  - 80-bit PTP timestamp (48b seconds + 32b nanoseconds)
  - Aligned to gPTP time base
  
Cycle Rollover:
  - When current cycle completes, next cycle starts at: BaseTime + N × CycleTime
  - N = floor((current_ptp_time - BaseTime) / CycleTime) + 1

RTL Implementation:
  // Cycle time accumulator
  reg [31:0] cycle_time_accum;
  reg [47:0] cycle_base_sec;
  reg [31:0] cycle_base_ns;
  
  always @(posedge clk_ts) begin
    if (gcl_state == GCL_COMPLETE) begin
      // Calculate next cycle start
      cycle_base_ns <= cycle_base_ns + gcl_cycle_time;
      if (cycle_base_ns >= 1_000_000_000) begin
        cycle_base_ns <= cycle_base_ns - 1_000_000_000;
        cycle_base_sec <= cycle_base_sec + 1;
      end
    end
  end
```

---

### 2.4 IEEE 802.1Qav - Credit-Based Shaper (CBS) - RTL-Coding Detail

#### 2.4.1 Credit Formula - Fixed-Point Implementation

```
Credit-Based Shaper (802.1Qav, Clause 8.6.8)

Credit Update Formula:
  credit_new = credit + (idleSlope × delta_t) - (sendSlope × frameSize)

Where:
  idleSlope = configured bandwidth fraction × portTransmitRate
  sendSlope = idleSlope - portTransmitRate
  
  Example: Queue configured for 20% of 1Gbps
    idleSlope = 0.20 × 1Gbps = 200 Mbps
    sendSlope = 200 Mbps - 1000 Mbps = -800 Mbps

Credit Bounds:
  hiCredit = maxInterferenceSize × (idleSlope / portTransmitRate)
  loCredit = 0 (or negative for burst tolerance)

Fixed-Point Representation:
  - Credit: 48-bit signed (16-bit integer + 32-bit fractional)
  - idleSlope: 32-bit unsigned (8-bit integer + 24-bit fractional)
  - sendSlope: 32-bit signed
  - portTransmitRate: 32-bit (Mbps)
  
  Scaling: All values scaled by 2^24 for fractional precision
  
  Example fixed-point:
    idleSlope = 200 Mbps = 200,000,000
    Scaled: 200,000,000 × 2^24 = 3,355,443,200,000,000 (0x0BEBC200_000000)

RTL Implementation:
  reg [47:0] credit;          // Signed 48-bit (16.32 fixed-point)
  reg [31:0] idle_slope;      // 8.24 fixed-point
  reg [31:0] send_slope;      // Signed 8.24 fixed-point
  reg [31:0] port_rate;       // Mbps
  reg [47:0] hi_credit;
  
  // Credit update (per clock cycle or per frame)
  wire [47:0] credit_increment = idle_slope * delta_t;  // delta_t in ns
  wire [47:0] credit_decrement = send_slope * frame_size;  // frame_size in bits
  
  always @(posedge clk_mac) begin
    if (credit_update_en) begin
      credit <= credit + credit_increment - credit_decrement;
      // Saturate at bounds
      if (credit > hi_credit) credit <= hi_credit;
      if (credit < 0) credit <= 0;
    end
  end
  
  // Transmission gate: open when credit >= 0 and frame available
  wire cbs_gate_open = (credit >= 0) && queue_has_frame;
```

#### 2.4.2 CBS Integration with Queue Scheduler

```
CBS Queue Scheduler Integration

Priority Order (highest to lowest):
  1. TAS Gate Control (802.1Qbv) - if TAS enabled
  2. CBS Shaper (802.1Qav) - per queue credit-based
  3. Strict Priority (SP) - fixed queue priority
  4. Weighted Round Robin (WRR) - configurable weights

Scheduler Arbitration Logic:
  if (tas_enabled && tas_gate_open[selected_queue]) begin
    // TAS takes precedence
    selected_queue = tas_selected_queue;
  end else if (cbs_enabled && cbs_gate_open[selected_queue]) begin
    // CBS shaped queue
    selected_queue = highest_priority_cbs_queue;
  end else if (sp_enabled) begin
    // Strict priority
    selected_queue = highest_priority_ready_queue;
  end else begin
    // WRR
    selected_queue = wrr_next_queue;
  end

RTL Implementation:
  // Combined scheduler
  reg [2:0] selected_queue;
  
  always @(*) begin
    if (tas_active) begin
      selected_queue = tas_queue;
    end else begin
      // Check CBS queues first (highest priority CBS queue)
      for (i = 7; i >= 0; i = i - 1) begin
        if (cbs_gate_open[i]) begin
          selected_queue = i;
          break;
        end
      end
      // If no CBS queue, use strict priority
      // ...
    end
  end
```

---

### 2.5 IEEE 802.1Qbu - Frame Preemption - RTL-Coding Detail

#### 2.5.1 mPacket Format

```
Frame Preemption - mPacket Format (802.1Qbu / 802.3br)

Express Traffic: High priority, non-preemptable
Preemptable Traffic: Low priority, can be preempted by express

mPacket (MAC Merge Packet) Format:

Non-fragment (complete frame):
  [Preamble: 7B 0x55] [SMD-S: 1B Start] [Frame Data] [FCS: 4B]
  SMD-S = 0xE6 (Start of express frame, not preemptable)
  or SMD-S = 0x7A (Start of preemptable frame)

First fragment:
  [Preamble: 7B 0x55] [SMD-E: 1B] [Fragment Data] [CRC: 4B partial] [mCRC: 3B]
  SMD-E = 0xE5 (Express verification, not used in fragmentation)
  SMD-C = 0x61 (Continue fragment)

Continuation fragment:
  [Preamble: 7B 0x55] [SMD-C: 1B] [Fragment Data] [mCRC: 3B]
  SMD-C = 0x61

Last fragment:
  [Preamble: 7B 0x55] [SMD-C: 1B] [Fragment Data] [FCS: 4B] [mCRC: 3B]

SMD (Start/Continuation Frame Delimiter) Values:
  SMD-S (0xE6) = Start of non-preemptable frame
  SMD-E (0xE5) = Express frame (not preemptable)
  SMD-C (0x61) = Continuation fragment
  SMD-V (0x78) = Verify (for alignment check)

mCRC (3-byte CRC for fragment integrity):
  - Polynomial: x^24 + x^21 + x^20 + x^17 + x^15 + x^11 + x^9 + x^8 + x^6 + x^5 + x^1 + 1
  - Different from standard CRC-32
  - Verifies fragment integrity during reassembly

Fragment Size Constraints:
  - Minimum fragment size: 64 bytes (including preamble)
  - Maximum fragment size: limited by FIFO depth
  - Last fragment must include full FCS
```

#### 2.5.2 Preemption FSM - TX Side

```verilog
// Frame Preemption TX State Machine
localparam PREEMPT_IDLE        = 3'd0;
localparam PREEMPT_TRANSMIT    = 3'd1;  // Transmitting preemptable frame
localparam PREEMPT_FRAGMENT    = 3'd2;  // Fragmenting preemptable frame
localparam PREEMPT_EXPRESS     = 3'd3;  // Transmitting express frame
localparam PREEMPT_RESUME      = 3'd4;  // Resuming preempted frame
localparam PREEMPT_VERIFY      = 3'd5;  // Verify SMD alignment

case (preempt_tx_state)

PREEMPT_IDLE:
  if (express_frame_ready) begin
    preempt_tx_state <= PREEMPT_EXPRESS;
  end else if (preemptable_frame_ready) begin
    preempt_tx_state <= PREEMPT_TRANSMIT;
  end

PREEMPT_TRANSMIT:
  // Transmitting preemptable frame normally
  if (express_frame_ready) begin
    // Express frame arrives - preempt current frame
    // Save current position, send mCRC, then switch to express
    save_tx_position = current_tx_byte;
    preempt_tx_state <= PREEMPT_FRAGMENT;
  end else if (frame_complete) begin
    preempt_tx_state <= PREEMPT_IDLE;
  end

PREEMPT_FRAGMENT:
  // Send fragment with SMD-C and mCRC
  tx_smd = SMD_C;  // 0x61
  tx_data = fragment_data;
  tx_mcrc = compute_mcrc(fragment_data);
  
  if (fragment_sent) begin
    preempt_tx_state <= PREEMPT_EXPRESS;
  end

PREEMPT_EXPRESS:
  // Transmit express frame
  tx_smd = SMD_S;  // 0xE6
  tx_data = express_frame_data;
  
  if (express_frame_complete) begin
    if (preempted_frame_pending) begin
      preempt_tx_state <= PREEMPT_RESUME;
    end else begin
      preempt_tx_state <= PREEMPT_IDLE;
    end
  end

PREEMPT_RESUME:
  // Resume preempted frame from saved position
  tx_smd = SMD_C;  // 0x61
  tx_data = resumed_frame_data;
  
  if (frame_complete) begin
    preempt_tx_state <= PREEMPT_IDLE;
  end else if (express_frame_ready) begin
    // Another express frame - preempt again
    save_tx_position = current_tx_byte;
    preempt_tx_state <= PREEMPT_FRAGMENT;
  end

endcase
```

#### 2.5.3 Fragmentation and Reassembly

```
Fragmentation Rules:
  1. Preemptable frame can be fragmented at any byte boundary
  2. Minimum fragment size: 64 bytes
  3. Each fragment (except last) carries mCRC
  4. Last fragment carries full FCS
  5. Maximum fragments per frame: limited by FIFO (typically 4-8)

Reassembly Rules:
  1. Fragments must arrive in sequence (no reordering)
  2. mCRC verified per fragment
  3. If mCRC fails, discard entire frame
  4. Timeout: if fragment not received within ~1ms, discard

RTL Implementation:
  reg [15:0] fragment_seq_num;
  reg [15:0] expected_seq_num;
  reg [31:0] reassembly_buffer;
  reg [3:0]  fragment_count;
  
  always @(posedge clk_mac) begin
    if (rx_smd == SMD_C) begin
      // Continuation fragment
      if (fragment_seq_num == expected_seq_num) begin
        reassembly_buffer <= {reassembly_buffer, fragment_data};
        expected_seq_num <= expected_seq_num + 1;
        fragment_count <= fragment_count + 1;
      end else begin
        // Out of sequence - discard
        reassembly_state <= REASM_DISCARD;
      end
    end else if (rx_smd == SMD_S && rx_data == SMD_E) begin
      // End of fragmented frame
      if (mCRC_valid) begin
        reassembly_state <= REASM_COMPLETE;
      end else begin
        reassembly_state <= REASM_DISCARD;
      end
    end
  end
```

---

### 2.6 IEEE 802.1Q VLAN - RTL-Coding Detail

#### 2.6.1 TCI Bit Layout

```
VLAN Tag Control Information (TCI) - 16 bits

Bits[15:13] = PCP (Priority Code Point)
  0 = Best Effort (BK)
  1 = Background (BE)
  2 = Excellent Effort (EE)
  3 = Critical Applications (CA)
  4 = Video (< 100ms latency)
  5 = Voice (< 10ms latency)
  6 = Internetwork Control (IC)
  7 = Network Control (NC)

Bit[12] = DEI (Drop Eligible Indicator)
  0 = Not drop eligible
  1 = Drop eligible when congested

Bits[11:0] = VID (VLAN Identifier)
  0x000 = Null VLAN (untagged)
  0x001 = Default VLAN
  0xFFF = Reserved
  0x001-0xFFE = Normal VLAN IDs (4094 available)

VLAN Tag Insertion Format:
  [DA: 6B] [SA: 6B] [TPID: 0x8100] [TCI: 2B] [Type/Length: 2B] [Payload] [FCS]
  
Double VLAN (Q-in-Q):
  [DA] [SA] [Outer TPID: 0x8100] [Outer TCI] [Inner TPID: 0x8100] [Inner TCI] [Type] [Payload] [FCS]

RTL Implementation:
  // TCI register
  reg [2:0]  vlan_pcp;
  reg        vlan_dei;
  reg [11:0] vlan_vid;
  
  // VLAN tag detection
  wire vlan_tagged = (frame_data[12:13] == 16'h8100);
  wire [15:0] tci = frame_data[14:15];
  
  assign vlan_pcp = tci[15:13];
  assign vlan_dei = tci[12];
  assign vlan_vid = tci[11:0];
```

#### 2.6.2 VLAN Filtering Logic

```
VLAN Filtering Modes

1. Perfect Match Filtering:
   - Up to 8 VLAN IDs can be programmed
   - Frame passes if VID matches any programmed entry
   - Enable: MAC_VLAN_Tag_Filter[0] = 1

2. Hash Filtering:
   - 6-bit hash of VID
   - Hash = VID[5:0] XOR VID[11:6]
   - 64-bit hash table (one bit per hash value)
   - Frame passes if hash_table[hash] = 1

3. Inverse Filtering:
   - Frame passes if VID does NOT match programmed entries
   - Enable: MAC_VLAN_Tag_Filter[1] = 1

4. VLAN Tag Stripping:
   - Remove outer VLAN tag before passing to upper layers
   - Enable: MAC_VLAN_Tag_CTRL[0] = 1

RTL Implementation:
  // Perfect match filter
  reg [11:0] vlan_perfect_match [0:7];
  reg [7:0]  vlan_perfect_enable;
  
  wire vlan_perfect_pass = |({8{vlan_vid == vlan_perfect_match[7]} & vlan_perfect_enable[7],
                              {8{vlan_vid == vlan_perfect_match[6]} & vlan_perfect_enable[6],
                              ...});
  
  // Hash filter
  wire [5:0] vlan_hash = vlan_vid[5:0] ^ vlan_vid[11:6];
  reg [63:0] vlan_hash_table;
  wire vlan_hash_pass = vlan_hash_table[vlan_hash];
  
  // Combined filter
  wire vlan_pass = vlan_perfect_pass || vlan_hash_pass;
  
  // VLAN tag stripping
  always @(posedge clk_mac) begin
    if (vlan_strip_enable && vlan_tagged) begin
      // Remove 4 bytes (TPID + TCI) from frame
      stripped_frame <= {frame_data[0:11], frame_data[16:end]};
    end
  end
```

---

### 2.7 IEEE 802.1CB FRER - RTL-Coding Detail

#### 2.7.1 R-tag Format

```
Redundancy Tag (R-tag) Format - 6 bytes

Byte | Field              | Size | Description
-----|--------------------|------|----------------------------------
0-1  | TPID               | 2    | 0xF1C1 (Redundancy Tag Identifier)
2-3  | R-PC               | 2    | {Reserved[3:0], SequenceNumber[11:0]}
4-5  | Reserved           | 2    | 0x0000

Sequence Number: 12-bit unsigned
  - Range: 0 to 4095
  - Wraparound: 4095 → 0
  - Increment: +1 per frame per stream

RTL Implementation:
  // R-tag detection
  wire rtag_present = (frame_data[12:13] == 16'hF1C1);
  wire [11:0] seq_num = frame_data[14][3:0] | (frame_data[15][7:0] << 4);
```

#### 2.7.2 Sequence Number Window Algorithm

```
Duplicate Detection - Sequence Number Window

Window Size: 32 (configurable: 16/32/64/128)
Window Position: advances as new sequence numbers are received

Algorithm:
  1. For each received frame with sequence number S:
     a. If S is within current window and not seen before → ACCEPT
     b. If S is within current window and seen before → DISCARD (duplicate)
     c. If S is ahead of window → ADVANCE window to include S, ACCEPT
     d. If S is behind window → DISCARD (late)

Window Data Structure:
  - Bit vector: 128 bits (one bit per sequence number in window)
  - Base sequence number: oldest sequence number in window
  - Window position: base + window_size

RTL Implementation:
  reg [127:0] seq_window;      // Bit vector of received sequence numbers
  reg [11:0]  seq_base;        // Base sequence number
  reg [11:0]  seq_window_size; // Configurable: 16/32/64/128
  
  function seq_accept;
    input [11:0] seq;
    begin
      if (seq >= seq_base && seq < seq_base + seq_window_size) begin
        // Within window
        if (!seq_window[seq - seq_base]) begin
          // Not seen before - accept
          seq_window[seq - seq_base] <= 1;
          seq_accept = 1;
        end else begin
          // Duplicate - discard
          seq_accept = 0;
        end
      end else if (seq >= seq_base + seq_window_size) begin
        // Ahead of window - advance
        seq_base <= seq;
        seq_window <= 0;  // Clear window
        seq_window[0] <= 1;  // Mark current as received
        seq_accept = 1;
      end else begin
        // Behind window - discard
        seq_accept = 0;
      end
    end
  endfunction
```

#### 2.7.3 Frame Replication

```
Frame Replication (at sender)

For each stream configured for FRER:
  1. Assign unique sequence number
  2. Insert R-tag with sequence number
  3. Replicate frame to N egress ports (typically 2)
  4. Each replica carries same sequence number

Sequence Number Generation:
  - Per-stream counter
  - Increment by 1 per frame
  - Wrap at 4095

RTL Implementation:
  reg [11:0] seq_counter [0:MAX_STREAMS-1];
  
  always @(posedge clk_mac) begin
    if (frer_stream_enable[stream_id]) begin
      // Insert R-tag
      tx_data[12:13] = 16'hF1C1;  // TPID
      tx_data[14] = {4'h0, seq_counter[stream_id][11:8]};
      tx_data[15] = seq_counter[stream_id][7:0];
      
      // Increment counter
      if (seq_counter[stream_id] == 12'hFFF)
        seq_counter[stream_id] <= 12'h000;
      else
        seq_counter[stream_id] <= seq_counter[stream_id] + 1;
    end
  end
```

---

### 2.8 PHY Interfaces - RTL-Coding Detail

#### 2.8.1 MII Interface (4-bit Nibble)

```
MII (Media Independent Interface) - 4-bit nibble, 25MHz

Signal        | Direction | Width | Description
--------------|-----------|-------|-----------------------------------
TX_CLK        | Input     | 1     | 25MHz (100M) or 2.5MHz (10M)
TX_EN         | Output    | 1     | Transmit enable
TXD[3:0]      | Output    | 4     | Transmit data (nibble)
TX_ER         | Output    | 1     | Transmit error
RX_CLK        | Input     | 1     | 25MHz (100M) or 2.5MHz (10M)
RX_DV         | Input     | 1     | Receive data valid
RXD[3:0]      | Input     | 4     | Receive data (nibble)
RX_ER         | Input     | 1     | Receive error
CRS           | Input     | 1     | Carrier sense
COL           | Input     | 1     | Collision detect

Timing:
  TX_CLK/RX_CLK: 25MHz ± 50ppm (100M), 2.5MHz (10M)
  Setup time: 5ns (TXD to TX_CLK rising)
  Hold time: 5ns (TXD from TX_CLK rising)
  Clock duty cycle: 40%-60%

Data Rate:
  100M: 25MHz × 4 bits = 100 Mbps
  10M: 2.5MHz × 4 bits = 10 Mbps

RTL Implementation:
  // MII TX: convert byte to nibble
  reg [3:0] tx_nibble;
  reg       tx_nibble_sel;  // 0=LSN, 1=MSN
  
  always @(posedge tx_clk) begin
    if (tx_en) begin
      tx_nibble_sel <= ~tx_nibble_sel;
      tx_nibble <= tx_nibble_sel ? tx_byte[7:4] : tx_byte[3:0];
    end
  end
  
  // MII RX: convert nibble to byte
  reg [3:0] rx_nibble_lsn;
  reg [7:0] rx_byte;
  reg       rx_byte_valid;
  
  always @(posedge rx_clk) begin
    if (rx_dv) begin
      rx_nibble_lsn <= rxd;
      rx_byte <= {rxd, rx_nibble_lsn};  // MSN + LSN
      rx_byte_valid <= ~rx_byte_valid;   // Valid every 2 nibbles
    end
  end
```

#### 2.8.2 RMII Interface (2-bit, 50MHz REF_CLK)

```
RMII (Reduced MII) - 2-bit, 50MHz REF_CLK

Signal        | Direction | Width | Description
--------------|-----------|-------|-----------------------------------
REF_CLK       | Input     | 1     | 50MHz ± 50ppm
TX_EN         | Output    | 1     | Transmit enable
TXD[1:0]      | Output    | 2     | Transmit data
RXD[1:0]      | Input     | 2     | Receive data
CRS_DV        | Input     | 1     | Carrier sense + data valid
RX_ER         | Input     | 1     | Receive error (optional)

Timing:
  REF_CLK: 50MHz continuous
  Setup time: 4ns
  Hold time: 2ns

Data Rate:
  100M: 50MHz × 2 bits = 100 Mbps
  10M: 50MHz × 2 bits = 10 Mbps (with /10 decimation)

CRS_DV Decoding:
  CRS_DV transitions indicate start/end of frame
  First transition: CRS asserted (start of frame)
  Second transition: CRS deasserted, DV still high (end of frame)

RTL Implementation:
  // RMII TX: convert byte to dibit
  reg [1:0] tx_dibit;
  reg [1:0] tx_dibit_cnt;
  
  always @(posedge ref_clk) begin
    if (tx_en) begin
      tx_dibit_cnt <= tx_dibit_cnt + 1;
      case (tx_dibit_cnt)
        0: tx_dibit <= tx_byte[1:0];
        1: tx_dibit <= tx_byte[3:2];
        2: tx_dibit <= tx_byte[5:4];
        3: tx_dibit <= tx_byte[7:6];
      endcase
    end
  end
  
  // RMII RX: CRS_DV decode
  reg crs_dv_prev;
  reg [1:0] rx_dibit [0:3];
  reg [7:0] rx_byte_rmii;
  
  always @(posedge ref_clk) begin
    crs_dv_prev <= crs_dv;
    if (!crs_dv_prev && crs_dv) begin
      // Start of frame
      rx_frame_start <= 1;
    end
    if (crs_dv_prev && !crs_dv) begin
      // End of frame (CRS deasserted, DV still high)
      rx_frame_end <= 1;
    end
  end
```

#### 2.8.3 RGMII Interface (4-bit DDR, 125MHz)

```
RGMII (Reduced Gigabit MII) - 4-bit DDR, 125MHz

Signal        | Direction | Width | Description
--------------|-----------|-------|-----------------------------------
TXC           | Output    | 1     | 125MHz (from MAC)
TXD[3:0]      | Output    | 4     | Data (DDR)
TX_CTL        | Output    | 1     | Control (DDR)
RXC           | Input     | 1     | 125MHz (from PHY)
RXD[3:0]      | Input     | 4     | Data (DDR)
RX_CTL        | Input     | 1     | Control (DDR)

Timing:
  TXC: 125MHz, duty cycle 45%-55%
  RXC: 125MHz, delayed 1.5-2.0ns by PHY
  
  Data-to-clock skew at transmitter: ±500ps
  Total RX skew budget: ±1.5ns

Data Encoding:
  TXD[3:0] @ TXC rising edge = Data[3:0]
  TXD[3:0] @ TXC falling edge = Data[7:4]
  TX_CTL @ TXC rising edge = TX_EN
  TX_CTL @ TXC falling edge = TX_EN ^ TX_ER

  RXD[3:0] @ RXC rising edge = Data[3:0]
  RXD[3:0] @ RXC falling edge = Data[7:4]
  RX_CTL @ RXC rising edge = RX_DV
  RX_CTL @ RXC falling edge = RX_DV ^ RX_ER

RTL Implementation:
  // RGMII TX: DDR output
  ODDR txc_oddr (.Q(txc), .C(clk_125m), .CE(1'b1), .D1(1'b0), .D2(1'b1));
  
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin
      ODDR txd_oddr (.Q(txd[i]), .C(clk_125m), .CE(1'b1),
                     .D1(tx_byte[i]), .D2(tx_byte[i+4]));
    end
  endgenerate
  
  ODDR txctl_oddr (.Q(tx_ctl), .C(clk_125m), .CE(1'b1),
                   .D1(tx_en), .D2(tx_en ^ tx_er));
  
  // RGMII RX: DDR input
  genvar j;
  generate
    for (j = 0; j < 4; j = j + 1) begin
      IDDR rxd_iddr (.Q1(rx_byte[j]), .Q2(rx_byte[j+4]),
                     .C(rxc), .CE(1'b1), .D(rxd[j]));
    end
  endgenerate
  
  IDDR rxctl_iddr (.Q1(rx_dv), .Q2(rx_er_raw),
                   .C(rxc), .CE(1'b1), .D(rx_ctl));
  
  assign rx_er = rx_dv ^ rx_er_raw;  // Decode
```

#### 2.8.4 SGMII Interface (8b/10b, 1.25Gbps)

```
SGMII (Serial Gigabit MII) - 8b/10b encoding, 1.25Gbps

Physical Layer: SERDES
Line Rate: 1.25 Gbps (1Gbps data + 8b/10b overhead)
Reference Clock: 125MHz

8b/10b Encoding:
  - Each 8-bit data byte → 10-bit symbol
  - Two code groups: Data (D) and Special (K)
  - D codes: 256 data characters
  - K codes: 12 control characters

Key K-codes:
  K28.5 (0xBC) = Comma, used for alignment
  K27.7 (0xFB) = Start of frame
  K29.7 (0xFD) = End of frame
  K30.7 (0xFE) = Error propagation

Code Group Format:
  abcdei fghj (10 bits)
  6b/5b + 4b/3b sub-blocks with running disparity

Running Disparity (RD):
  - RD+: Previous symbol had more 1s than 0s
  - RD-: Previous symbol had more 0s than 1s
  - Each valid symbol maintains RD rules

RTL Implementation:
  // 8b/10b encoder
  module encode_8b10b (
    input [7:0] data,
    input       k_char,  // 1 = K-code, 0 = D-code
    input       rd_in,   // Running disparity in
    output [9:0] code_group,
    output       rd_out  // Running disparity out
  );
    // Lookup table implementation
    // (Standard 8b/10b tables available in public domain)
  endmodule
  
  // 8b/10b decoder
  module decode_8b10b (
    input [9:0] code_group,
    input       rd_in,
    output [7:0] data,
    output       k_char,
    output       rd_out,
    output       code_error,
    output       disp_error
  );
    // Inverse lookup table
  endmodule
```

#### 2.8.5 USXGMII Interface (64b/66b, 6.25Gbps)

```
USXGMII (Universal Serial 10GE MII) - 64b/66b, 6.25Gbps

Physical Layer: SERDES
Line Rate: 6.25 Gbps (10Gbps data + 64b/66b overhead)
Reference Clock: 156.25MHz or 312.5MHz

64b/66b Encoding:
  - 64-bit data block → 66-bit encoded block
  - Sync header: 2 bits (01 = data, 10 = control)
  - Invalid headers (00, 11) indicate error

Block Types:
  0x1E = Start of frame (C0)
  0x2D = End of frame (C1-C7)
  0x33 = Control frame
  0x66 = Data frame
  0x78 = Idle

Scrambling:
  - Self-synchronizing scrambler
  - Polynomial: 1 + x^39 + x^58
  - Scrambler runs continuously over all bits

Alignment:
  - 66-bit block boundary
  - Search for valid sync headers
  - Lock after 64 consecutive valid headers

RTL Implementation:
  // 64b/66b scrambler
  module scrambler_64b66b (
    input [65:0] data_in,
    input        clk,
    input        rst_n,
    output [65:0] data_out
  );
    reg [57:0] state;  // Scrambler state
    // x^58 + x^39 + 1
    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) state <= 0;
      else begin
        state <= {state[56:0], state[57] ^ state[38]};
      end
    end
    assign data_out = data_in ^ {state, state[57:0]};
  endmodule
  
  // Block alignment
  module block_align_66b (
    input [65:0] raw_data,
    input        clk,
    output [65:0] aligned_block,
    output        block_locked
  );
    // Search for valid sync headers (01 or 10)
    // Shift until valid header found
  endmodule
```

---

### 2.9 Switch Core - RTL-Coding Detail

#### 2.9.1 FDB Entry Format

```
Forwarding Database (FDB) Entry Format

Each FDB Entry: 128 bits (16 bytes)

Bits[127:80] = MAC Address [47:0]
Bits[79:68]  = VLAN ID [11:0]
Bits[67:64]  = Port Mask [3:0]
  Bit[i] = 1: Forward to port i
Bits[63]     = Valid
Bits[62]     = Static/Dynamic
  0 = Dynamic (learned, can age out)
  1 = Static (programmed, never ages out)
Bits[61:48]  = Age Counter [13:0]
  - Incremented every aging period (default 300 seconds)
  - When age > max_age, entry invalidated
Bits[47:32]  = Reserved
Bits[31:0]   = Hash Value (for collision handling)

FDB Memory:
  - Depth: 8K entries (configurable: 4K/8K/16K)
  - Entry size: 16 bytes
  - Total memory: 8K × 16 = 128KB
  - ECC protection: SECDED per 128-bit entry
  - Hash table: 16-way set associative

Hash Function:
  hash = {MAC[47:24] XOR MAC[23:0]} XOR {VLAN[11:0], 12'b0}
  index = hash[12:0]  // 8K entries → 13-bit index

RTL Implementation:
  // FDB entry structure
  typedef struct packed {
    logic [47:0] mac_addr;
    logic [11:0] vlan_id;
    logic [3:0]  port_mask;
    logic        valid;
    logic        static_entry;
    logic [13:0] age_counter;
    logic [15:0] reserved;
    logic [31:0] hash;
  } fdb_entry_t;
  
  // FDB memory
  fdb_entry_t fdb_mem [0:FDB_DEPTH-1];
  
  // Hash calculation
  wire [23:0] mac_hi = mac_addr[47:24];
  wire [23:0] mac_lo = mac_addr[23:0];
  wire [23:0] mac_xor = mac_hi ^ mac_lo;
  wire [11:0] vlan_shift = vlan_id;
  wire [23:0] hash_val = mac_xor ^ {12'b0, vlan_shift};
  wire [12:0] fdb_index = hash_val[12:0];
```

#### 2.9.2 L2 Forwarding FSM

```verilog
// L2 Forwarding State Machine
localparam FWD_IDLE      = 3'd0;
localparam FWD_PARSE     = 3'd1;  // Parse DA, SA, VLAN
localparam FWD_LOOKUP    = 3'd2;  // FDB lookup
localparam FWD_DECISION  = 3'd3;  // Forwarding decision
localparam FWD_FORWARD   = 3'd4;  // Forward to egress port(s)
localparam FWD_LEARN     = 3'd5;  // Self-learning (update FDB)
localparam FWD_DROP      = 3'd6;  // Drop frame

case (fwd_state)

FWD_IDLE:
  if (ingress_frame_valid) begin
    fwd_state <= FWD_PARSE;
    ingress_port <= ingress_port_id;
  end

FWD_PARSE:
  // Extract DA, SA, VLAN from frame header
  da <= frame_data[0:5];
  sa <= frame_data[6:11];
  if (vlan_tagged) begin
    vid <= frame_data[14][3:0] | (frame_data[15][7:0] << 4);
  end else begin
    vid <= default_vlan;
  end
  fwd_state <= FWD_LOOKUP;

FWD_LOOKUP:
  // Hash calculation
  fdb_hash <= hash_function(da, vid);
  fdb_index <= fdb_hash[12:0];
  
  // Read FDB entry
  fdb_entry <= fdb_mem[fdb_index];
  
  // Check for hit
  fdb_hit <= (fdb_entry.valid &&
              fdb_entry.mac_addr == da &&
              fdb_entry.vlan_id == vid);
  
  fwd_state <= FWD_DECISION;

FWD_DECISION:
  if (fdb_hit) begin
    // FDB hit - forward to port mask
    egress_mask <= fdb_entry.port_mask;
    fwd_state <= FWD_FORWARD;
  end else if (da == broadcast_mac) begin
    // Broadcast - flood to all ports except ingress
    egress_mask <= 4'b1111 & ~{4{ingress_port}};
    fwd_state <= FWD_FORWARD;
  end else begin
    // Unknown unicast - flood or drop (configurable)
    if (unknown_unicast_flood)
      egress_mask <= 4'b1111 & ~{4{ingress_port}};
    else
      fwd_state <= FWD_DROP;
  end
  
  // Always learn SA (if enabled)
  if (learning_enable) begin
    fwd_state <= FWD_LEARN;
  end

FWD_FORWARD:
  // Forward frame to egress ports
  for (i = 0; i < 4; i = i + 1) begin
    if (egress_mask[i]) begin
      egress_fifo[i].wen <= 1;
      egress_fifo[i].wdata <= frame_data;
    end
  end
  fwd_state <= FWD_IDLE;

FWD_LEARN:
  // Update FDB with SA
  if (!fdb_entry.static_entry) begin
    fdb_mem[fdb_index].mac_addr <= sa;
    fdb_mem[fdb_index].vlan_id <= vid;
    fdb_mem[fdb_index].port_mask <= {4{ingress_port}};
    fdb_mem[fdb_index].valid <= 1;
    fdb_mem[fdb_index].static_entry <= 0;
    fdb_mem[fdb_index].age_counter <= 0;
  end
  fwd_state <= FWD_IDLE;

FWD_DROP:
  // Discard frame
  drop_counter <= drop_counter + 1;
  fwd_state <= FWD_IDLE;

endcase
```

#### 2.9.3 Crossbar Arbitration

```
Crossbar Switch Arbitration

4-port Crossbar: Each ingress can connect to any egress
Concurrent forwarding: Up to 4 simultaneous transfers

Arbitration Priority:
  1. TSN traffic (time-critical)
  2. High priority (PCP 6-7)
  3. Medium priority (PCP 3-5)
  4. Low priority (PCP 0-2)

Port Conflict Resolution:
  - If multiple ingress ports target same egress:
    a. TSN traffic wins
    b. Higher PCP wins
    c. Round-robin for same priority

RTL Implementation:
  // Crossbar request matrix
  reg [3:0] crossbar_req [0:3];  // req[src][dst]
  reg [3:0] crossbar_grant [0:3]; // grant[src][dst]
  
  // Arbitration per egress port
  genvar dst;
  generate
    for (dst = 0; dst < 4; dst = dst + 1) begin
      // Priority arbiter for each egress
      always @(*) begin
        crossbar_grant[0][dst] = 0;
        crossbar_grant[1][dst] = 0;
        crossbar_grant[2][dst] = 0;
        crossbar_grant[3][dst] = 0;
        
        // Check TSN first
        for (src = 0; src < 4; src = src + 1) begin
          if (crossbar_req[src][dst] && tsn_priority[src]) begin
            crossbar_grant[src][dst] = 1;
            break;
          end
        end
        
        // Then check PCP priority
        if (!|crossbar_grant[dst]) begin
          highest_pcp = 0;
          selected_src = 0;
          for (src = 0; src < 4; src = src + 1) begin
            if (crossbar_req[src][dst] && ingress_pcp[src] > highest_pcp) begin
              highest_pcp = ingress_pcp[src];
              selected_src = src;
            end
          end
          crossbar_grant[selected_src][dst] = 1;
        end
      end
    end
  endgenerate
```

#### 2.9.4 L3 Routing (if supported)

```
L3 Routing Table Entry Format (Optional)

Each L3 Entry: 256 bits (32 bytes)

Bits[255:224] = Destination IP Address (IPv4) or MSB (IPv6)
Bits[223:192] = Subnet Mask
Bits[191:160] = Next Hop IP Address
Bits[159:128] = Next Hop MAC Address (for ARP)
Bits[127:96]  = Output Port Mask
Bits[95:64]   = Route Metric / Cost
Bits[63]      = Valid
Bits[62]      = Static/Dynamic
Bits[61:48]   = Age Counter
Bits[47:0]    = Reserved

L3 Forwarding Process:
  1. Check EtherType = 0x0800 (IPv4) or 0x86DD (IPv6)
  2. Extract destination IP from packet
  3. Lookup routing table (longest prefix match)
  4. Determine next hop
  5. Rewrite DA with next hop MAC
  6. Decrement TTL
  7. Recalculate IP header checksum
  8. Forward to output port

RTL Implementation:
  // L3 route lookup
  reg [31:0] route_table [0:ROUTE_DEPTH-1];
  
  function route_lookup;
    input [31:0] dest_ip;
    begin
      for (i = 0; i < ROUTE_DEPTH; i = i + 1) begin
        if (route_table[i].valid &&
            (dest_ip & route_table[i].subnet_mask) ==
            (route_table[i].dest_ip & route_table[i].subnet_mask)) begin
          route_lookup = i;
          break;
        end
      end
    end
  endfunction
```

---

## 3. RTL Module Partitioning Summary

```
ethernet_top
├── mac_core
│   ├── tx_engine        # 802.3 Tx FSM (§2.1.2), VLAN insert, preemption
│   ├── rx_engine        # 802.3 Rx FSM (§2.1.3), VLAN strip/filter
│   ├── crc32            # CRC-32 polynomial (§2.1.4)
│   └── pause_ctrl       # PAUSE frame handling (§2.1.5)
├── phy_interface
│   ├── mii_if           # 4-bit nibble timing (§2.8.1)
│   ├── rmii_if          # 2-bit 50MHz (§2.8.2)
│   ├── rgmii_if         # DDR 125MHz skew (§2.8.3)
│   ├── sgmii_if         # 8b/10b encoding (§2.8.4)
│   └── usxgmii_if       # 64b/66b scrambling (§2.8.5)
├── timestamp_unit
│   ├── ptp_counter      # 80-bit timestamp (§2.2.3)
│   ├── addend_accum     # 32-bit fractional (§2.2.3)
│   ├── timestamp_cap    # SFD capture (§2.2.2)
│   ├── bmca_fsm         # Best Master Clock (§2.2.4)
│   └── pps_gen          # PPS output (§2.2.6)
├── mtl_scheduler
│   ├── cbs_shaper       # Credit formula (§2.4.1)
│   ├── tas_gate_ctrl    # GCL execution FSM (§2.3.2)
│   ├── queue_arbiter    # Priority/WRR (§2.4.2)
│   └── preempt_ctrl     # mPacket format (§2.5.1)
├── flow_filter
│   ├── stream_id        # Stream identification
│   ├── psfp_gate        # Stream gate control
│   └── meter            # Token bucket metering
├── frer_engine
│   ├── seq_gen          # Sequence number (§2.7.3)
│   ├── seq_check        # Window algorithm (§2.7.2)
│   └── rtag_insert      # R-tag format (§2.7.1)
├── switch_core (optional)
│   ├── fdb_lookup       # Hash table (§2.9.1)
│   ├── l2_forward       # Forwarding FSM (§2.9.2)
│   ├── crossbar         # Arbitration (§2.9.3)
│   ├── vlan_proc        # VLAN processing
│   └── l3_route         # IP routing (§2.9.4)
├── dma_engine
│   ├── desc_fetch       # Descriptor format
│   ├── data_xfer        # AXI Master
│   └── ch_arbiter       # Channel arbitration
├── csr_block
│   └── reg_file         # AXI4-Lite register map
└── safety_monitor
    ├── ecc_checker      # SECDED
    ├── parity_gen       # FSM parity
    └── timeout_watch    # CSR timeout
```

---

## 4. Competitor Comparison

### 4.1 TSN Protocol Support

| TSN Protocol | TC4x GETH | NXP S32G3 | TI TDA4 | R-Car S4 |
|-------------|-----------|-----------|---------|----------|
| 802.1AS (gPTP) | ✅ Full | ✅ | ✅ | ✅ |
| 802.1Qav (CBS) | ✅ Full | ✅ | ✅ | ✅ |
| 802.1Qbv (EST) | ✅ Full | ✅ | ✅ | ✅ |
| 802.1Qbu (Preemption) | ✅ Full | ✅ | ⚠️ Partial | ⚠️ Partial |
| 802.1Qci (PSFP) | ✅ Full | ⚠️ Partial | ❌ | ❌ |
| 802.1CB (FRER) | ⚠️ Inferred | ✅ | ❌ | ⚠️ Partial |
| 802.1AE (MACsec) | ⚠️ HW req | ✅ | ⚠️ Partial | ❌ |
| **Switch-level TAS** | ❌ | ❌ | ❌ | ✅ |
| **Switch-level gPTP Relay** | ⚠️ Limited | ❌ | ❌ | ✅ |
| **L2/L3 Switch** | ❌ (Bridge only) | ✅ | ⚠️ Limited | ✅ |
| **Dual PHC / vPHC** | ❌ | ❌ | ❌ | ✅ |

### 4.2 PHY Interface Support

| PHY Interface | TC4x GETH | NXP S32G3 | TI TDA4 | R-Car S4 |
|--------------|-----------|-----------|---------|----------|
| MII | ✅ | ✅ | ✅ | ✅ |
| RMII | ✅ | ✅ | ✅ | ✅ |
| RGMII | ✅ | ✅ | ✅ | ✅ |
| SGMII | ✅ | ✅ | ✅ | ✅ |
| USXGMII | ✅ | ❌ | ❌ | ❌ |
| 5G Support | ✅ | ❌ | ❌ | ❌ |

---

## 5. RTL Implementation Priority

### 5.1 Phase 1 (MVP - RTL Ready)

| Protocol | RTL Module | Key Deliverable |
|----------|-----------|-----------------|
| 802.3 MAC | mac_core | TX/RX FSM, CRC-32, exact frame format |
| MII/GMII/RGMII | phy_interface | Timing diagrams, skew specs, DDR logic |
| 802.1Q VLAN | mac_core | TCI layout, perfect/hash filtering, Q-in-Q |
| 802.1AS gPTP | timestamp_unit | 80-bit timestamp, BMCA FSM, peer delay formula |
| Multichannel DMA | dma_engine | Descriptor format, channel arbitration |

### 5.2 Phase 2 (TSN Core)

| Protocol | RTL Module | Key Deliverable |
|----------|-----------|-----------------|
| 802.1Qav CBS | mtl_scheduler | Credit formula, fixed-point, bounds |
| 802.1Qbv EST | mtl_gate_ctrl | GCL entry format, execution FSM, cycle time |
| 802.1Qbu Preemption | mac_merge | mPacket format, SMD values, fragment FSM |

### 5.3 Phase 3 (Safety + Reliability)

| Protocol | RTL Module | Key Deliverable |
|----------|-----------|-----------------|
| 802.1Qci PSFP | flow_filter | Stream identification, gate control, metering |
| 802.1CB FRER | frer_engine | R-tag format, 16-bit sequence, window algorithm |
| 802.1AE MACsec | macsec_engine | AES-GCM, SecTAG, SA management |

### 5.4 Phase 4 (Switch + Extensions)

| Protocol | RTL Module | Key Deliverable |
|----------|-----------|-----------------|
| L2/L3 Switch | switch_core | FDB format, L2 FSM, crossbar arbiter |
| Switch-level TAS | switch_gcl | Per-port GCL, cycle mapping |
| AVTP Filter | avtp_filter | Stream ID matching, DMA queue routing |
| USXGMII/5G | hsphy | 64b/66b encoding, multi-port mux |

---

## 6. Architecture Design Inputs

### 6.1 RTL Module Partitioning

```
ethernet_top
├── mac_core
│   ├── tx_engine        # 802.3 Tx FSM (§2.1.2), VLAN insert, preemption
│   ├── rx_engine        # 802.3 Rx FSM (§2.1.3), VLAN strip/filter
│   ├── crc32            # CRC-32 polynomial (§2.1.4)
│   └── pause_ctrl       # PAUSE frame handling (§2.1.5)
├── phy_interface
│   ├── mii_if           # 4-bit nibble timing (§2.8.1)
│   ├── rmii_if          # 2-bit 50MHz (§2.8.2)
│   ├── rgmii_if         # DDR 125MHz skew (§2.8.3)
│   ├── sgmii_if         # 8b/10b encoding (§2.8.4)
│   └── usxgmii_if       # 64b/66b scrambling (§2.8.5)
├── timestamp_unit
│   ├── ptp_counter      # 80-bit timestamp (§2.2.3)
│   ├── addend_accum     # 32-bit fractional (§2.2.3)
│   ├── timestamp_cap    # SFD capture (§2.2.2)
│   ├── bmca_fsm         # Best Master Clock (§2.2.4)
│   └── pps_gen          # PPS output (§2.2.6)
├── mtl_scheduler
│   ├── cbs_shaper       # Credit formula (§2.4.1)
│   ├── tas_gate_ctrl    # GCL execution FSM (§2.3.2)
│   ├── queue_arbiter    # Priority/WRR (§2.4.2)
│   └── preempt_ctrl     # mPacket format (§2.5.1)
├── flow_filter
│   ├── stream_id        # Stream identification
│   ├── psfp_gate        # Stream gate control
│   └── meter            # Token bucket metering
├── frer_engine
│   ├── seq_gen          # Sequence number (§2.7.3)
│   ├── seq_check        # Window algorithm (§2.7.2)
│   └── rtag_insert      # R-tag format (§2.7.1)
├── switch_core (optional)
│   ├── fdb_lookup       # Hash table (§2.9.1)
│   ├── l2_forward       # Forwarding FSM (§2.9.2)
│   ├── crossbar         # Arbitration (§2.9.3)
│   ├── vlan_proc        # VLAN processing
│   └── l3_route         # IP routing (§2.9.4)
├── dma_engine
│   ├── desc_fetch       # Descriptor format
│   ├── data_xfer        # AXI Master
│   └── ch_arbiter       # Channel arbitration
├── csr_block
│   └── reg_file         # AXI4-Lite register map
└── safety_monitor
    ├── ecc_checker      # SECDED
    ├── parity_gen       # FSM parity
    └── timeout_watch    # CSR timeout
```

---

## 7. Protocol Implementation Checklist

### 7.1 802.3 MAC Implementation Checklist

- [ ] Frame format: Preamble (7B), SFD (1B), DA (6B), SA (6B), Type/Length (2B), Payload (46-1500B), FCS (4B)
- [ ] TX FSM: IDLE → PREAMBLE → SFD → DATA → PAD → FCS → IFG
- [ ] RX FSM: IDLE → PREAMBLE → SFD → DATA → FCS → IFG
- [ ] CRC-32: Polynomial 0x04C11DB7, LSB-first, magic residue 0xC704DD7B
- [ ] Padding: Minimum 46 bytes payload, 60 bytes total excluding FCS
- [ ] IFG: Minimum 96 bit-times, programmable 64-224
- [ ] PAUSE frame: DA=01:80:C2:00:00:01, Type=0x8808, Opcode=0x0001, Quanta=512 bit-times
- [ ] MII timing: 25MHz, 4-bit nibble, setup/hold 5ns
- [ ] GMII timing: 125MHz, 8-bit byte, setup 2.5ns, hold 0.5ns
- [ ] RGMII timing: 125MHz DDR, skew ±500ps at transmitter, ±1.5ns at receiver

### 7.2 802.1AS gPTP Implementation Checklist

- [ ] Message formats: Sync, Follow_Up, Delay_Req, Delay_Resp, Pdelay_Req, Pdelay_Resp, Pdelay_Resp_Follow_Up, Announce
- [ ] Timestamp: 80-bit (48b seconds + 32b nanoseconds), SFD capture point
- [ ] BMCA: 8 states, priority vector comparison, 8 fields lexicographic
- [ ] Peer delay: ((t4-t1)-(t3-t2)-correctionField)/2
- [ ] PPS: 1Hz, programmable width, target time registers
- [ ] Clock: 250MHz clk_ts, Addend=0x4000_0000, 32-bit fractional accumulator

### 7.3 802.1Qbv EST Implementation Checklist

- [ ] GCL entry: 64-bit {GateStateVector[7:0], TimeInterval[23:0], Reserved[31:0]}
- [ ] GCL depth: 256 entries (configurable 64/128/256/512)
- [ ] GCL FSM: IDLE → WAIT_BASE → RUNNING → PENDING → COMPLETE
- [ ] Cycle time: 32-bit nanoseconds, BaseTime 80-bit PTP timestamp
- [ ] Gate control: 8 queues, OPEN/CLOSED per entry

### 7.4 802.1Qav CBS Implementation Checklist

- [ ] Credit formula: credit + (idleSlope × delta_t) - (sendSlope × frameSize)
- [ ] Fixed-point: 48-bit signed credit (16.32), 32-bit slopes (8.24)
- [ ] Credit bounds: hiCredit, loCredit=0
- [ ] Integration: CBS queue priority in scheduler

### 7.5 802.1Qbu Preemption Implementation Checklist

- [ ] mPacket format: SMD-S(0xE6), SMD-E(0xE5), SMD-C(0x61)
- [ ] Express vs preemptable classification
- [ ] Fragmentation FSM: TRANSMIT → FRAGMENT → EXPRESS → RESUME
- [ ] mCRC: 3-byte CRC per fragment
- [ ] Reassembly: sequence check, mCRC verify, timeout

### 7.6 802.1Q VLAN Implementation Checklist

- [ ] TCI layout: PCP[15:13], DEI[12], VID[11:0]
- [ ] Perfect match: 8 entries, 32-bit hash table
- [ ] Hash filter: 6-bit hash, 64-bit table
- [ ] Double VLAN: Q-in-Q parsing
- [ ] Tag stripping: configurable removal

### 7.7 802.1CB FRER Implementation Checklist

- [ ] R-tag: TPID=0xF1C1, R-PC={Reserved[3:0], SeqNum[11:0]}
- [ ] Sequence number: 12-bit, per-stream counter
- [ ] Window algorithm: 32-entry window, bit vector tracking
- [ ] Replication: same sequence number to multiple ports
- [ ] Elimination: duplicate detection, sequence recovery

### 7.8 PHY Interface Implementation Checklist

- [ ] MII: 4-bit nibble, 25MHz, 14 nibbles preamble, setup/hold 5ns
- [ ] RMII: 2-bit, 50MHz REF_CLK, CRS_DV decode
- [ ] RGMII: 4-bit DDR, 125MHz, ODDR/IDDR primitives, skew control
- [ ] SGMII: 8b/10b, 1.25Gbps, K-codes, running disparity
- [ ] USXGMII: 64b/66b, 6.25Gbps, scrambling, block alignment

### 7.9 Switch Implementation Checklist

- [ ] FDB entry: 128-bit {MAC[48], VID[12], PortMask[4], Valid, Static, Age[14]}
- [ ] FDB depth: 8K entries, 16-way set associative
- [ ] Hash function: MAC XOR, 13-bit index
- [ ] L2 FSM: PARSE → LOOKUP → DECISION → FORWARD/LEARN/DROP
- [ ] Crossbar: 4-port, priority arbitration, TSN first
- [ ] L3 route: IP lookup, longest prefix match, next hop MAC

---

*Document Status: RTL-Coding Detail Complete*
*Version: v2.0*
*Date: 2026-05-12*
*Author: Arch Agent + RTL Coding Agent*
*Project: Ethernet IP (IP_20260502_001)*
