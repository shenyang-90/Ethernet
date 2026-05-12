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
  // Cycle time alignment check
  // If entry transitions are too fast (< 1μs), hardware may need
  // to extend to minimum feasible time
  gcl_state <= GCL_RUNNING;

GCL_COMPLETE:
  // Check if cycle time extension needed
  if (gcl_timer >= gcl_cycle_time) begin
    gcl_state <= GCL_RUNNING;
    gcl_entry_idx <= 0;
    gcl_timer <= 0;
    gcl_cycle_count <= gcl_cycle_count + 1;
  end else begin
    gcl_timer <= gcl_timer + 1;
  end

endcase

// Gate output to Queue Scheduler
assign gate_open[0] = current_gate_vector[0] && gcl_state == GCL_RUNNING;
assign gate_open[1] = current_gate_vector[1] && gcl_state == GCL_RUNNING;
// ... (for all 8 queues)
```

#### 2.3.3 gPTP Time to GCL Cycle Mapping

```
GCL Cycle Time Computation

Cycle Time = sum of all TimeInterval values in GCL entries

Cycle alignment to gPTP time:
  effective_time = ptp_time - gcl_base_time
  cycle_position = effective_time mod gcl_cycle_time
  
  Find entry i where:
    sum(TimeInterval[0..i-1]) <= cycle_position < sum(TimeInterval[0..i])

RTL Implementation:
  // Pre-compute cumulative time table (at configuration time)
  reg [31:0] gcl_cumulative [0:255];
  // cumulative[i] = sum of TimeInterval[0..i]
  
  // Runtime position lookup
  wire [79:0] eff_time = {ptp_seconds, ptp_nanoseconds} -
                         {gcl_base_time_sec, gcl_base_time_ns};
  wire [31:0] cycle_pos = eff_time[31:0] % gcl_cycle_time;
  
  // Binary search or linear scan for current entry
  // (Linear scan acceptable for 256 entries at ns speed)
  always @(*) begin
    gcl_entry_idx = 0;
    for (i = 0; i < gcl_list_length; i = i + 1) begin
      if (cycle_pos >= gcl_cumulative[i])
        gcl_entry_idx = i + 1;
    end
  end
```

#### 2.3.4 CycleTime and BaseTime Registers

```
GCL Time Registers

Register: GCL_BASE_TIME_SECONDS (0x0408)
  Bits[47:0]: BaseTime seconds (48-bit)
  
Register: GCL_BASE_TIME_NANOSECONDS (0x040C)
  Bits[31:0]: BaseTime nanoseconds (32-bit)
  
Register: GCL_CYCLE_TIME_SECONDS (0x0410)
  Bits[47:0]: CycleTime seconds (48-bit)
  
Register: GCL_CYCLE_TIME_NANOSECONDS (0x0414)
  Bits[31:0]: CycleTime nanoseconds (32-bit)
  
Register: GCL_CONTROL (0x0400)
  Bit[0]: GCL_ENABLE
  Bit[1]: GCL_RESTART (self-clearing)
  Bit[2]: GCL_CHANGE (request GCL update)
  Bits[7:3]: reserved
  Bits[15:8]: GCL_LIST_LENGTH (1-255)
  Bit[16]: GCL_CYCLE_COMPLETE_IRQ_EN
  Bit[17]: GCL_ENTRY_CHANGE_IRQ_EN
  Bits[31:18]: reserved

Register: GCL_STATUS (0x0404)
  Bit[0]: GCL_ACTIVE
  Bit[1]: GCL_CYCLE_COMPLETE
  Bit[2]: GCL_ENTRY_CHANGED
  Bits[7:3]: GCL_CURRENT_ENTRY_IDX
  Bits[15:8]: GCL_ERROR_CODE
  Bits[31:16]: reserved

GCL Update Sequence (RTL Handshake):
  1. Software writes new GCL entries to memory
  2. Software sets GCL_CHANGE = 1
  3. Hardware: If GCL currently IDLE or COMPLETE → load immediately
     If GCL RUNNING → wait for current cycle completion
  4. Hardware clears GCL_CHANGE when loaded
```

---

### 2.4 IEEE 802.1Qav - Credit-Based Shaper (CBS) - RTL-Coding Detail

#### 2.4.1 Exact Credit Formula

```
Credit-Based Shaper Algorithm (IEEE 802.1Qav, Clause 34.3)

Variables per queue (i = 0..7):
  credit_i: Current credit value (signed fixed-point)
  idleSlope_i: Rate at which credit increases (bits per second)
  sendSlope_i: Rate at which credit decreases (bits per second)
  hiCredit_i: Upper bound (0 or positive)
  loCredit_i: Lower bound (negative or 0)
  frameSize: Size of frame to be transmitted (bits)
  portTransmitRate: Line rate (bits per second)

Credit Update Rules:

1. If queue is not transmitting AND gate is open:
     credit += idleSlope × Δt
     (credit increases over time)

2. If queue is transmitting:
     credit -= sendSlope × frameSize
     (credit decreases by sendSlope for duration of frame transmission)

3. If gate is closed:
     credit = max(credit, 0)  // Or hold, depending on implementation

Where:
  sendSlope = portTransmitRate - idleSlope
  
  Typically: idleSlope = allocatedBandwidth × portTransmitRate
              sendSlope = (1 - allocatedBandwidth) × portTransmitRate

Credit Bounds:
  loCredit ≤ credit ≤ hiCredit
  
  hiCredit = maxFrameSize × (idleSlope / sendSlope)
  loCredit = -maxInterferenceSize × (idleSlope / portTransmitRate)

Transmission Condition:
  A frame from queue i can be transmitted if:
    a) gate_open[i] == 1 (from GCL or always open)
    b) credit_i ≥ 0
    c) No higher-priority queue with credit ≥ 0 and frame ready
```

#### 2.4.2 Fixed-Point Representation

```verilog
// Credit Fixed-Point Representation
// Format: 48.16 (48 integer bits, 16 fractional bits)
// Range: ±2^47 credits ≈ ±140T credits
// Resolution: 1/65536 ≈ 0.000015 credit units

typedef struct packed {
  logic signed [47:0] integer_part;
  logic        [15:0] fractional_part;
} credit_t;

// Or combined:
typedef logic signed [63:0] credit_value_t;  // [63:16] = integer, [15:0] = fraction

// Slopes in fixed-point (bits per nanosecond, scaled)
// idleSlope = allocatedBandwidth [0.0 ~ 1.0] × portTransmitRate
// 
// Example: 1Gbps port, 25% allocated to AVB queue
//   idleSlope = 0.25 × 1Gbps = 250Mbps
//   sendSlope = 750Mbps
//   
// In bits/ns: idleSlope = 250 / 1000 = 0.25 bits/ns
//   Fixed-point: idleSlope_fp = 0.25 × 2^16 = 16384 = 0x4000

// Credit update every clock cycle (ns granularity)
// credit_new = credit_old + (idleSlope_fp × Δt_ns) - (sendSlope_fp × frame_bits)

// Parameters per queue (registers)
reg [31:0] cbs_idle_slope [0:7];   // Fixed-point 16.16, bits/ns
reg [31:0] cbs_send_slope [0:7];   // Fixed-point 16.16, bits/ns
reg signed [47:0] cbs_hi_credit [0:7];  // Upper bound
reg signed [47:0] cbs_lo_credit [0:7];  // Lower bound

// Credit accumulator
reg signed [63:0] cbs_credit [0:7];  // 48.16 fixed-point

// Credit computation (per ns)
always @(posedge clk_mac) begin
  for (i = 0; i < 8; i = i + 1) begin
    if (gate_open[i] && !tx_active[i] && cbs_credit[i] < cbs_hi_credit[i]) begin
      // Credit accumulation (idle)
      cbs_credit[i] <= cbs_credit[i] + {{32{cbs_idle_slope[i][31]}}, cbs_idle_slope[i]};
    end else if (tx_active[i]) begin
      // Credit consumption (transmitting)
      cbs_credit[i] <= cbs_credit[i] -
        ({{16{1'b0}}, frame_size_bits} * {{32{cbs_send_slope[i][31]}}, cbs_send_slope[i]} >> 16);
    end
    
    // Clamp to bounds
    if (cbs_credit[i] > cbs_hi_credit[i]) cbs_credit[i] <= cbs_hi_credit[i];
    if (cbs_credit[i] < cbs_lo_credit[i]) cbs_credit[i] <= cbs_lo_credit[i];
  end
end
```

#### 2.4.3 Credit Bounds (0 and hiCredit)

```
Credit Bound Calculations

hiCredit Calculation:
  hiCredit = maxFrameSize × (idleSlope / sendSlope)
  
  Example: maxFrameSize = 1522 bytes = 12176 bits
           idleSlope = 250 Mbps, sendSlope = 750 Mbps
           hiCredit = 12176 × (250/750) = 12176 × 0.333 = 4059 bits

loCredit Calculation:
  loCredit = -maxInterferenceSize × (idleSlope / portTransmitRate)
  
  Example: maxInterferenceSize = 1522 bytes = 12176 bits
           idleSlope = 250 Mbps, portTransmitRate = 1 Gbps
           loCredit = -12176 × (250/1000) = -3044 bits

RTL Implementation:
  // Pre-computed bounds (configured by software)
  wire signed [47:0] hi_credit = cbs_hi_credit_reg;
  wire signed [47:0] lo_credit = cbs_lo_credit_reg;  // Negative value
  
  // Transmission eligibility
  assign cbs_can_transmit[i] = (cbs_credit[i] >= 0) && gate_open[i] && frame_ready[i];
```

#### 2.4.4 Integration with Queue Scheduler

```
CBS + Queue Scheduler Integration

Priority Order (strict priority within AVB class):
  1. Time-triggered (TT) traffic: GCL-gated, highest priority
  2. AVB Class A (SR Class A): CBS shaped
  3. AVB Class B (SR Class B): CBS shaped
  4. Best-effort traffic: No shaping

Scheduler Decision Logic:
  if (TT_frame_ready && TT_gate_open)
    transmit TT frame
  else if (ClassA_frame_ready && ClassA_gate_open && ClassA_credit >= 0)
    transmit Class A frame
  else if (ClassB_frame_ready && ClassB_gate_open && ClassB_credit >= 0)
    transmit Class B frame
  else if (BE_frame_ready)
    transmit BE frame
  else
    idle

RTL Implementation:
  // Combined scheduler with CBS and GCL
  always @(*) begin
    tx_queue_sel = 3'd7;  // Default: no transmission
    
    if (gcl_gate_open[0] && tt_frame_ready)
      tx_queue_sel = 3'd0;  // TT queue
    else if (gcl_gate_open[1] && avb_a_ready && cbs_credit[1] >= 0)
      tx_queue_sel = 3'd1;  // AVB Class A
    else if (gcl_gate_open[2] && avb_b_ready && cbs_credit[2] >= 0)
      tx_queue_sel = 3'd2;  // AVB Class B
    else if (gcl_gate_open[7] && be_frame_ready)
      tx_queue_sel = 3'd7;  // Best effort
  end
  
  // Frame transmission starts → credit decreases
  always @(posedge clk_mac) begin
    if (tx_start && tx_queue_sel == 3'd1)
      tx_active[1] <= 1;  // Class A transmitting
    else if (tx_complete)
      tx_active[1] <= 0;
  end
```

---

### 2.5 IEEE 802.1Qbu/802.3br - Frame Preemption - RTL-Coding Detail

#### 2.5.1 Exact mPacket Format with SMD Values

```
Frame Preemption: mPacket Format (802.1Qbu/802.3br)

Express MAC (eMAC): Handles time-critical traffic
Preemptable MAC (pMAC): Handles preemptable traffic

Frame Classification:
  Express Traffic: Highest priority, cannot be preempted
    - PCP values: Configurable (default 7, 6)
    - VLAN PCP or MAC-specific rules
  Preemptable Traffic: Can be interrupted by express traffic
    - All other traffic classes

mPacket (MAC Merge Packet) Format:

Complete Frame (non-preempted):
  | Preamble (7B) | SFD (1B: 0xD5) | eMAC Frame | FCS (4B) |

Preempted Frame Fragments:
  First Fragment:
    | Preamble (7B) | SMD-Sx (1B) | pMAC Fragment Data | CRC-8 (3B) |
  
  Continuation Fragments:
    | Preamble (7B) | SMD-Cx (1B) | pMAC Fragment Data | CRC-8 (3B) |
  
  Final Fragment:
    | Preamble (7B) | SMD-Ex (1B) | pMAC Remaining Data | FCS (4B) |

SMD (Start MDelimiter) Values:
  SMD-S0 = 0xE6  // First fragment (sequence 0)
  SMD-S1 = 0x7C  // First fragment (sequence 1)
  SMD-S2 = 0xB0  // First fragment (sequence 2)
  SMD-S3 = 0xFC  // First fragment (sequence 3)
  SMD-C0 = 0x61  // Continuation fragment (sequence 0)
  SMD-C1 = 0x52  // Continuation fragment (sequence 1)
  SMD-C2 = 0x9E  // Continuation fragment (sequence 2)
  SMD-C3 = 0x2A  // Continuation fragment (sequence 3)
  SMD-E0 = 0xE6 ^ 0x78 = 0x9E  // Verify: SMD-E0 = 0x9E (per spec)
  Actually: SMD-E0 = 0x78, SMD-E1 = 0x4B, SMD-E2 = 0x87, SMD-E3 = 0x3D
  
  (Complete table per IEEE 802.3br Table 99-1)
  
  SMD-Sx pattern: bits[7:6] = 2'b11, bits[5:4] = sequence[1:0]
  SMD-Cx pattern: bits[7:6] = 2'b10, bits[5:4] = sequence[1:0]
  SMD-Ex pattern: bits[7:6] = 2'b01, bits[5:4] = sequence[1:0]

Verify Sequence Number:
  SMD-V = 0x07  // Verification frame (not a real SMD, but verify seq)

Fragment Constraints:
  - Minimum fragment size: 64 bytes (including preamble + SMD + CRC)
  - Maximum fragment size: Limited by on-wire max (1522 bytes)
  - Minimum non-final fragment: 64 bytes
  - Express frame must complete before preempting again

CRC-8 for Fragments:
  Polynomial: x^8 + x^2 + x + 1 (0x07)
  Initial: 0xFF
  Covers: SMD + fragment data
  
  Note: Fragment CRC-8 is NOT the final frame CRC-32.
  Final fragment uses standard CRC-32 over entire original frame.
```

#### 2.5.2 Express vs Preemptable Classification Rules

```verilog
// Frame Classification Logic
function automatic is_express;
  input [15:0] vlan_tci;  // VLAN Tag Control Information
  input [47:0] da;         // Destination MAC
  input [15:0] ether_type;
  begin
    // Priority-based classification
    if (vlan_tci[15:13] >= express_pcp_threshold)  // Default threshold = 6
      is_express = 1;
    // MAC-address-based classification
    else if (da == express_multicast_addr)  // e.g., 01:80:C2:00:00:0E
      is_express = 1;
    // EtherType-based classification
    else if (ether_type == express_etype)  // e.g., AVTP = 0x22F0
      is_express = 1;
    else
      is_express = 0;
  end
endfunction

// Classification table (configurable, 16 entries)
reg [2:0]  classify_pcp [0:15];
reg [47:0] classify_da_mask [0:15];
reg [47:0] classify_da_value [0:15];
reg [15:0] classify_etype [0:15];
reg        classify_result [0:15];  // 1 = express

// Default rules:
// Rule 0: PCP 7 = Express
// Rule 1: PCP 6 = Express  
// Rule 2: PCP 5 = Preemptable
// ...
// Rule 15: Default = Preemptable
```

#### 2.5.3 Frame Fragmentation and Reassembly FSM

```verilog
// Preemption TX FSM (pMAC side)
localparam PREEMPT_IDLE        = 4'd0;
localparam PREEMPT_FIRST_FRAG  = 4'd1;
localparam PREEMPT_INTERMED    = 4'd2;
localparam PREEMPT_VERIFY      = 4'd3;
localparam PREEMPT_FINAL_FRAG  = 4'd4;
localparam PREEMPT_EXPRESS     = 4'd5;
localparam PREEMPT_WAIT_EXP    = 4'd6;

reg [1:0] frag_sequence;  // 0..3, wraps around
reg [15:0] frag_byte_cnt;
reg [15:0] total_frame_bytes;
reg [31:0] frame_crc32;   // Running CRC-32 of full frame

case (preempt_state)

PREEMPT_IDLE:
  if (express_frame_ready) begin
    preempt_state <= PREEMPT_EXPRESS;
  end else if (preemptable_frame_ready) begin
    preempt_state <= PREEMPT_FIRST_FRAG;
    frag_sequence <= frag_sequence + 1;
    frag_byte_cnt <= 0;
    frame_crc32 <= 32'hFFFFFFFF;  // Initialize CRC
  end

PREEMPT_FIRST_FRAG:
  // Output: Preamble + SMD-Sx + data + CRC-8
  tx_gmii_data = (frag_byte_cnt < 7) ? 8'h55 :
                 (frag_byte_cnt == 7) ? smd_s_value[frag_sequence] :
                 tx_fifo_rdata;
  
  frag_byte_cnt <= frag_byte_cnt + 1;
  total_frame_bytes <= total_frame_bytes + 1;
  
  // Update CRC-32 (for final verification)
  frame_crc32 <= crc32_update(frame_crc32, tx_fifo_rdata);
  
  // Check for express preemption request
  if (express_frame_ready && frag_byte_cnt >= 64) begin
    // Minimum 64 bytes transmitted before preemption allowed
    preempt_state <= PREEMPT_WAIT_EXP;
    // Output CRC-8 and close fragment
  end else if (total_frame_bytes >= preemptable_frame_length) begin
    // Frame complete without preemption
    preempt_state <= PREEMPT_FINAL_FRAG;
  end

PREEMPT_WAIT_EXP:
  // Complete current fragment with CRC-8
  tx_gmii_data = crc8_value;
  preempt_state <= PREEMPT_EXPRESS;

PREEMPT_EXPRESS:
  // eMAC takes over: standard frame transmission
  if (express_tx_complete) begin
    // Return to pMAC if preemptable frame not complete
    if (total_frame_bytes < preemptable_frame_length)
      preempt_state <= PREEMPT_INTERMED;
    else
      preempt_state <= PREEMPT_IDLE;
  end

PREEMPT_INTERMED:
  // Continuation fragment: Preamble + SMD-Cx
  tx_gmii_data = (frag_byte_cnt < 7) ? 8'h55 :
                 (frag_byte_cnt == 7) ? smd_c_value[frag_sequence] :
                 tx_fifo_rdata;
  frag_byte_cnt <= frag_byte_cnt + 1;
  
  if (express_frame_ready && frag_byte_cnt >= 64)
    preempt_state <= PREEMPT_WAIT_EXP;
  else if (total_frame_bytes >= preemptable_frame_length)
    preempt_state <= PREEMPT_FINAL_FRAG;

PREEMPT_FINAL_FRAG:
  // Final fragment: Preamble + SMD-Ex + remaining data + CRC-32
  tx_gmii_data = (frag_byte_cnt < 7) ? 8'h55 :
                 (frag_byte_cnt == 7) ? smd_e_value[frag_sequence] :
                 tx_fifo_rdata;
  
  if (all_data_sent) begin
    // Append FCS (CRC-32 of full original frame)
    tx_gmii_data = crc32_final_value;
    preempt_state <= PREEMPT_VERIFY;
  end

PREEMPT_VERIFY:
  // Verify sequence continuity check
  // SMD-V frame sent periodically (every 128 fragments)
  if (verify_count >= 128) begin
    send_smd_v_frame();
    verify_count <= 0;
  end
  preempt_state <= PREEMPT_IDLE;

endcase
```

#### 2.5.4 CRC Handling for Fragments

```
Fragment CRC-8 Calculation:
  Polynomial: G(x) = x^8 + x^2 + x + 1 = 0x07
  Initial value: 0xFF
  
  CRC-8 covers: SMD byte + all data bytes in fragment
  
  After computing CRC-8 over SMD + data:
    Final CRC = NOT(computed_value)  // One's complement
    
  On receive: recompute CRC-8, should equal 0xF3 (magic check value)

Full Frame CRC-32:
  The final fragment includes the CRC-32 of the COMPLETE original frame.
  The CRC-32 is computed over all bytes from DA through final data byte.
  
  Preemption does NOT affect the final CRC-32: it is computed as if
  the frame was transmitted contiguously.

RTL Implementation:
  // Dual CRC engines
  crc8_engine  fragment_crc (  // For intermediate fragments
    .polynomial(8'h07),
    .init(8'hFF),
    .data_in(fragment_data),
    .crc_out(fragment_crc8)
  );
  
  crc32_engine frame_crc (     // For final CRC-32
    .polynomial(32'h04C11DB7),
    .init(32'hFFFFFFFF),
    .data_in(frame_data),
    .crc_out(final_fcs)
  );
```

---

### 2.6 IEEE 802.1Q VLAN - RTL-Coding Detail

#### 2.6.1 Exact TCI Bit Layout

```
VLAN Tag Control Information (TCI) - 16 bits

Bit[15:13] = PCP (Priority Code Point) - 3 bits
  000 (0) = Background (BK)
  001 (1) = Best Effort (BE)
  010 (2) = Excellent Effort (EE)
  011 (3) = Critical Applications (CA)
  100 (4) = Video (< 100ms latency)
  101 (5) = Voice (< 10ms latency)
  110 (6) = Internetwork Control (IC)
  111 (7) = Network Control (NC)

Bit[12] = DEI (Drop Eligible Indicator) - 1 bit
  0 = Not drop eligible
  1 = Drop eligible when congestion

Bit[11:0] = VID (VLAN Identifier) - 12 bits
  0x000 = Null VLAN (untagged frame on ingress, native VLAN)
  0x001 = Default VLAN
  0x002-0xFFE = Normal VLAN IDs (1-4094)
  0xFFF = Reserved

VLAN Tag Insertion (4 bytes):
  Byte 0: 0x81 (TPID upper)
  Byte 1: 0x00 (TPID lower)  → TPID = 0x8100 (C-VLAN)
  Byte 2: TCI[15:8] (PCP[2:0] + DEI + VID[11:8])
  Byte 3: TCI[7:0] (VID[7:0])

Double VLAN Tag (Q-in-Q, Stacked VLAN):
  Outer Tag (S-TAG):
    TPID = 0x88A8 (S-VLAN) or 0x9100 (old) or 0x9200/0x9300
    TCI = {PCP[2:0], DEI, SVID[11:0]}
  
  Inner Tag (C-TAG):
    TPID = 0x8100
    TCI = {PCP[2:0], DEI, CVID[11:0]}

Frame with Double VLAN:
  | DA | SA | S-TAG (4B) | C-TAG (4B) | Type | Payload | FCS |
  Total overhead: 8 bytes
```

#### 2.6.2 Exact Filtering Logic (Perfect Match + Hash)

```verilog
// VLAN Filtering Module
// Supports: Perfect match (up to 32 entries) + Hash filtering

// Perfect Match Filter
reg [11:0] vlan_perfect_match [0:31];  // 32 VLAN IDs
reg        vlan_perfect_valid [0:31];  // Entry valid
reg [2:0]  vlan_perfect_queue [0:31];  // Target queue mapping

// Hash Filter
reg [63:0] vlan_hash_table;  // 64-bit hash
reg [5:0]  vlan_hash_bits;    // Number of hash bits (6 = 64 entries)

// Hash Function (CRC-8 based)
function [5:0] vlan_hash;
  input [11:0] vid;
  begin
    // Simple hash: bits[5:0] of (VID XOR (VID >> 6))
    vlan_hash = vid[5:0] ^ vid[11:6];
    // Alternative: use CRC-8 of VID[11:0]
    // vlan_hash = crc8_0x07(vid[11:0])[5:0];
  end
endfunction

// Filtering Decision
always @(*) begin
  vlan_filter_pass = 0;
  vlan_target_queue = 3'd0;
  
  // Perfect match check
  for (i = 0; i < 32; i = i + 1) begin
    if (vlan_perfect_valid[i] && (vid == vlan_perfect_match[i])) begin
      vlan_filter_pass = 1;
      vlan_target_queue = vlan_perfect_queue[i];
    end
  end
  
  // Hash match (if no perfect match)
  if (!vlan_filter_pass) begin
    hash_idx = vlan_hash(vid);
    vlan_filter_pass = vlan_hash_table[hash_idx];
  end
  
  // Promiscuous mode override
  if (vlan_promiscuous)
    vlan_filter_pass = 1;
end
```

#### 2.6.3 Double VLAN Tag (Q-in-Q) Parsing Rules

```
Q-in-Q Parsing State Machine

Ingress Parsing:
  1. Check EtherType after SA:
     If bytes[12:13] == 0x88A8 or 0x8100:
       → VLAN tagged
     
  2. First tag:
     If TPID == 0x88A8:
       outer_tagged = 1
       svid = TCI[11:0]
       spcp = TCI[15:13]
       sdei = TCI[12]
     Else if TPID == 0x8100:
       inner_tagged = 1  // Single tag
       cvid = TCI[11:0]
       
  3. Check next 2 bytes:
     If bytes[16:17] == 0x8100:
       inner_tagged = 1
       cvid = TCI[11:0]
       cpcp = TCI[15:13]
       cdei = TCI[12]
     Else:
       inner_tagged = 0

Priority Mapping:
  If double-tagged: use outer PCP (spcp) for queue mapping
  If single-tagged: use inner PCP (cpcp)
  If untagged: use port default PCP (port_pcp_default)

RTL Implementation:
  reg [11:0] parsed_svid, parsed_cvid;
  reg [2:0]  parsed_spcp, parsed_cpcp;
  reg        has_stag, has_ctag;
  
  // Parse pipeline (2 cycles)
  always @(posedge clk_mac) begin
    // Cycle 1: Detect TPID
    if (frame_byte_12_13 == 16'h88A8) begin
      has_stag <= 1;
      parsed_spcp <= frame_byte_15[15:13];
      parsed_svid <= {frame_byte_15[11:8], frame_byte_16[7:0]};
    end else if (frame_byte_12_13 == 16'h8100) begin
      has_ctag <= 1;
      parsed_cpcp <= frame_byte_15[15:13];
      parsed_cvid <= {frame_byte_15[11:8], frame_byte_16[7:0]};
    end
    
    // Cycle 2: Check for inner tag
    if (has_stag && frame_byte_16_17 == 16'h8100) begin
      has_ctag <= 1;
      parsed_cpcp <= frame_byte_19[15:13];
      parsed_cvid <= {frame_byte_19[11:8], frame_byte_20[7:0]};
    end
  end
```

#### 2.6.4 Hash Function for VLAN Filtering

```verilog
// VLAN Hash Function
// CRC-8 based hash for 12-bit VLAN ID

function [63:0] vlan_hash_compute;
  input [11:0] vid;
  reg [7:0] crc;
  integer i;
  begin
    crc = 8'hFF;  // Initial value
    
    // Process VID byte by byte (12 bits = 2 bytes, upper 4 bits padded)
    for (i = 0; i < 12; i = i + 1) begin
      crc = crc ^ {7'b0, vid[i]};  // XOR LSB in
      if (crc[0])
        crc = {1'b0, crc[7:1]} ^ 8'h8C;  // Polynomial 0x8C for CRC-8
      else
        crc = {1'b0, crc[7:1]};
    end
    
    vlan_hash_compute = 64'h1 << crc[5:0];  // One-hot encode
  end
endfunction
```

---

### 2.7 IEEE 802.1CB - FRER - RTL-Coding Detail

#### 2.7.1 Exact R-Tag Format

```
R-Tag (Redundancy Tag) Format - 6 bytes

Byte 0-1: TPID = 0xF1C1 (Redundancy Tag EtherType)
Byte 2:   Flags
  Bit[7:4]: Reserved (0)
  Bit[3]:   ESEL (Encode Stream ID from Ethernet parameters)
  Bit[2]:   EDE (Encode Discard Eligibility)
  Bit[1]:   EPCP (Encode PCP from Ethernet parameters)
  Bit[0]:   Reserved
Byte 3:   Flags2
  Bit[7]:   Reserved
  Bit[6:4]: LAN ID (0-7, identifies redundant path)
  Bit[3:0]: Reserved
Byte 4-5: Sequence Number (16-bit unsigned)
  Range: 0 - 65535, wraps to 0 after 65535

R-Tag Insertion Position:
  Before VLAN tag if present:
    | DA | SA | R-Tag (6B) | VLAN Tag (4B) | Type | Payload | FCS |
  
  Without VLAN:
    | DA | SA | R-Tag (6B) | Type | Payload | FCS |

Sequence Number Generation:
  - Per-stream sequence number
  - 16-bit counter, increments by 1 for each frame in stream
  - Wrap-around: 65535 → 0
  - Initial value: 0 (or random to avoid startup duplicates)

Sequence Number Assignment:
  Stream identification based on:
    a) Null stream: Single sequence generator for all FRER traffic
    b) SMAC/ DMAC-based: Per-source/destination pair
    c) VLAN-based: Per-VLAN + PCP combination
    d) IP-based: Per IP 5-tuple (if L3-aware)
```

#### 2.7.2 Sequence Number Generation (16-bit Space)

```verilog
// Sequence Number Generator
// One per stream (up to 64 streams)

reg [15:0] seq_num [0:63];     // Sequence number per stream
reg [5:0]  stream_id_map [0:63]; // Stream ID lookup result
reg        stream_valid [0:63];

// Stream Identification
function [5:0] identify_stream;
  input [47:0] smac, dmac;
  input [11:0] vid;
  input [2:0]  pcp;
  input [15:0] etype;
  begin
    // Hash-based stream identification
    identify_stream = hash_stream(smac, dmac, vid, pcp, etype);
  end
endfunction

// Sequence number assignment
always @(posedge clk_mac) begin
  if (frer_enable && tx_frame_valid) begin
    stream_idx = identify_stream(smac, dmac, vid, pcp, etype);
    
    if (stream_valid[stream_idx]) begin
      tx_r_tag[15:0] = seq_num[stream_idx];  // Insert into frame
      seq_num[stream_idx] <= seq_num[stream_idx] + 1;
      if (seq_num[stream_idx] == 16'hFFFF)
        seq_num[stream_idx] <= 0;  // Wrap-around
    end
  end
end
```

#### 2.7.3 Duplicate Detection: Sequence Number Window Algorithm

```verilog
// Duplicate Detection Window Algorithm
// Window size: 32 (configurable 16/32/64/128)

localparam WINDOW_SIZE = 32;
localparam WINDOW_BITS = 5;  // log2(32)

reg [15:0] seq_history [0:WINDOW_SIZE-1];  // Circular buffer
reg [WINDOW_BITS-1:0] seq_history_wr;      // Write pointer
reg [15:0] seq_expected;                      // Expected next sequence

// Duplicate check
function is_duplicate;
  input [15:0] rx_seq_num;
  integer i;
  begin
    is_duplicate = 0;
    
    // Check if sequence number is in history window
    for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
      if (rx_seq_num == seq_history[i])
        is_duplicate = 1;
    end
    
    // Also check for old sequences (outside window, very delayed)
    if (!$isunknown(seq_expected)) begin
      if ((rx_seq_num < seq_expected) && 
          (seq_expected - rx_seq_num > WINDOW_SIZE))
        is_duplicate = 1;  // Too old, must be duplicate
    end
  end
endfunction

// Window update
always @(posedge clk_mac) begin
  if (frer_rx_valid && !is_duplicate(rx_seq_num)) begin
    // Accept frame, add to history
    seq_history[seq_history_wr] <= rx_seq_num;
    seq_history_wr <= seq_history_wr + 1;
    
    // Update expected sequence
    if (rx_seq_num >= seq_expected)
      seq_expected <= rx_seq_num + 1;
  end
end

// Recovery (Vector Recovery Algorithm - optional)
// For out-of-order but within-window frames:
//   Accept if rx_seq_num > (seq_expected - WINDOW_SIZE)
//   Update seq_expected = max(seq_expected, rx_seq_num + 1)
```

---

### 2.8 PHY Interfaces - RTL-Coding Detail

#### 2.8.1 MII Interface

```
Media Independent Interface (MII) - IEEE 802.3 Clause 22

Data Path:
  TX: 4-bit nibble, TX_CLK synchronous
  RX: 4-bit nibble, RX_CLK synchronous

Clocks:
  TX_CLK: 25 MHz @ 100M, 2.5 MHz @ 10M (from PHY to MAC)
  RX_CLK: 25 MHz @ 100M, 2.5 MHz @ 10M (from PHY to MAC)

Exact Timing Diagram:

MII TX (100M mode, 25MHz TX_CLK):

        | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10| 11| 12| 13| 14| 15| 16|
TX_CLK  ‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|
        |<- Preamble nibbles ->|<SFD>|<---- Data Byte 0 ---->|<- D1 ->
TX_EN   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
TXD[3:0]---| 5 | 5 | 5 | 5 | 5 | 5 | 5 | D | 5 |D[3:0] | D[7:4]|D[3:0] |
        |<- 56 bits (14 nibbles) ->|4bit|<-- lower nibble --><- upp ->

TX_EN setup to TX_CLK rising: ≥ 10ns
TXD setup to TX_CLK rising: ≥ 10ns
TXD hold from TX_CLK rising: ≥ 0ns

MII RX (100M mode, 25MHz RX_CLK):

RX_CLK  ‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|
        |<- Preamble nibbles ->|<SFD>|<---- Data Byte 0 ---->|<- D1 ->
RX_DV   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
RXD[3:0]---| 5 | 5 | 5 | 5 | 5 | 5 | 5 | D | 5 |D[3:0] | D[7:4]|D[3:0] |

RX_DV valid to RX_CLK rising: ≤ 10ns (clock-to-valid)
RXD valid to RX_CLK rising: ≤ 25ns
RXD hold: ≥ 10ns

RTL Interface Module:
  // MII TX (from MAC to PHY)
  output reg [3:0] mii_txd,
  output reg       mii_tx_en,
  output reg       mii_tx_er,
  input            mii_tx_clk,
  
  // MII RX (from PHY to MAC)
  input      [3:0] mii_rxd,
  input            mii_rx_dv,
  input            mii_rx_er,
  input            mii_rx_clk,
  input            mii_crs,
  input            mii_col,

  // TX Nibble assembler
  reg [7:0] tx_byte_buffer;
  reg       tx_byte_valid;
  reg       tx_nibble_sel;  // 0 = lower, 1 = upper
  
  always @(posedge mii_tx_clk) begin
    if (mii_tx_en) begin
      if (!tx_nibble_sel) begin
        mii_txd <= tx_byte_buffer[3:0];  // Lower nibble
      end else begin
        mii_txd <= tx_byte_buffer[7:4];  // Upper nibble
      end
      tx_nibble_sel <= ~tx_nibble_sel;
    end else begin
      mii_txd <= 4'h0;  // Idle
    end
  end
  
  // RX Nibble assembler
  reg [3:0] rx_nibble_lower;
  reg       rx_nibble_valid;
  
  always @(posedge mii_rx_clk) begin
    if (mii_rx_dv) begin
      if (!rx_nibble_valid) begin
        rx_nibble_lower <= mii_rxd;
        rx_nibble_valid <= 1;
      end else begin
        rx_byte <= {mii_rxd, rx_nibble_lower};  // Upper + lower
        rx_byte_valid <= 1;
        rx_nibble_valid <= 0;
      end
    end else begin
      rx_byte_valid <= 0;
      rx_nibble_valid <= 0;
    end
  end
```

#### 2.8.2 RMII Interface

```
Reduced MII (RMII) - IEEE 802.3 Clause 22 (variant)

Data Path:
  TX: 2-bit dibit, REF_CLK synchronous
  RX: 2-bit dibit, REF_CLK synchronous

Clocks:
  REF_CLK: 50 MHz (fixed, from PHY or external oscillator)
  
  Effective data rate:
    100M: 50MHz × 2-bit = 100 Mbps
    10M:  REF_CLK still 50MHz, but data repeated 10x (nibble every 500ns)

Signal Mapping:
  REF_CLK: 50MHz clock (input)
  TXD[1:0]: 2-bit transmit data
  TX_EN:    Transmit enable
  RXD[1:0]: 2-bit receive data
  CRS_DV:   Carrier sense / data valid (multiplexed)
  RX_ER:    Receive error

CRS_DV Multiplexing:
  CRS_DV = 0: No carrier, no data valid
  CRS_DV = 1, RXD != 00: Data valid (reception active)
  CRS_DV = 1, RXD = 00: Carrier sense (between frames)
  CRS_DV transitions 0→1 with RXD=00: Start of frame (SFD pending)

Exact Timing (50MHz REF_CLK, 20ns period):

        | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10| 11| 12| 13| 14| 15| 16| 17| 18| 19| 20|
REF_CLK ‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|
        |<-- Preamble dibits (28 cycles) -->|<SFD>|<-- Data Byte 0 (4 cycles) -->|
TX_EN   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
TXD     --|01 |01 |01 |01 |01 |01 |01 |11 |01 |D[1:0]|D[3:2]|D[5:4]|D[7:6]|

Note: RMII preamble = 28 bits (vs MII 56 bits) because dibit rate
      is half of MII nibble rate at same REF_CLK frequency.
      Actually: RMII has NO preamble on interface (preamble is generated
      by PHY, not MAC). MAC starts with TX_EN assertion.

RTL Implementation:
  input        rmii_ref_clk,  // 50MHz
  output [1:0] rmii_txd,
  output       rmii_tx_en,
  input  [1:0] rmii_rxd,
  input        rmii_crs_dv,
  input        rmii_rx_er,
  
  // 2-bit to 8-bit conversion (4 cycles per byte)
  reg [1:0] rmii_rx_buffer [0:3];
  reg [2:0] rmii_rx_cnt;
  
  always @(posedge rmii_ref_clk) begin
    if (rmii_crs_dv && (rmii_rxd != 2'b00 || rmii_rx_cnt > 0)) begin
      rmii_rx_buffer[rmii_rx_cnt] <= rmii_rxd;
      rmii_rx_cnt <= rmii_rx_cnt + 1;
      if (rmii_rx_cnt == 3) begin
        rx_byte <= {rmii_rx_buffer[3], rmii_rx_buffer[2],
                     rmii_rx_buffer[1], rmii_rxd};
        rx_byte_valid <= 1;
        rmii_rx_cnt <= 0;
      end
    end else begin
      rx_byte_valid <= 0;
      if (!rmii_crs_dv)
        rmii_rx_cnt <= 0;
    end
  end
```

#### 2.8.3 RGMII Interface

```
Reduced GMII (RGMII) - IEEE 802.3 (industry standard, not formal IEEE)

Data Path:
  TX: 4-bit DDR, both edges of TXC
  RX: 4-bit DDR, both edges of RXC

Clocks:
  TXC: 125MHz @ 1G, 25MHz @ 100M, 2.5MHz @ 10M (from MAC to PHY)
  RXC: 125MHz @ 1G, 25MHz @ 100M, 2.5MHz @ 10M (from PHY to MAC)

Signal Mapping:
  TXC:  Clock (output from MAC)
  TXD[3:0]: Data, rising edge = [3:0], falling edge = [7:4]
  TX_CTL: Control, rising = TX_EN, falling = TX_EN ^ TX_ER
  RXC:  Clock (input from PHY)
  RXD[3:0]: Data, rising edge = [3:0], falling edge = [7:4]
  RX_CTL: Control, rising = RX_DV, falling = RX_DV ^ RX_ER

Exact DDR Timing:

RGMII TX (1G mode, 125MHz TXC):

TXC     ‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__|
        |Rise|Fall|Rise|Fall|Rise|Fall|Rise|Fall|Rise|Fall|Rise|Fall|Rise|Fall|
        |<--- Byte 0 --->|<--- Byte 1 --->|<--- Byte 2 --->|
TXD[3:0]---|D0L|D0U|D1L|D1U|D2L|D2U|D3L|D3U|
           | [3:0]|[7:4]| [3:0]|[7:4]|
TX_CTL   ___|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
           | TX_EN| TX_EN| TX_EN| TX_EN| ... (rising edges)
           | TX_ER| TX_ER| TX_ER| TX_ER| ... (falling edges, if error)

Skew Requirements:
  - TX data to TXC skew: ±500ps (at MAC output)
  - RX data to RXC skew: ±1.5ns (including PHY internal delay)
  - Typical PHY internal delay: 1.5~2.0ns

RGMII v2.0 added requirement:
  - PHY can add internal delay to RXC (typically 2ns)
  - Or MAC can delay RXC/TXC (IDELAY primitive)
  
RTL Implementation:
  output       rgmii_txc,
  output [3:0] rgmii_txd,
  output       rgmii_tx_ctl,
  input        rgmii_rxc,
  input  [3:0] rgmii_rxd,
  input        rgmii_rx_ctl,
  
  // TX DDR (using ODDR primitive)
  ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE")
  ) txc_oddr (
    .Q(rgmii_txc),
    .C(gtx_clk),
    .CE(1'b1),
    .D1(1'b1),  // Rising edge
    .D2(1'b0),  // Falling edge
    .R(1'b0),
    .S(1'b0)
  );
  
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : txd_ddr
      ODDR txd_oddr (
        .Q(rgmii_txd[i]),
        .C(gtx_clk),
        .CE(1'b1),
        .D1(tx_byte[i]),      // Rising: lower nibble
        .D2(tx_byte[i+4]),    // Falling: upper nibble
        .R(1'b0),
        .S(1'b0)
      );
    end
  endgenerate
  
  ODDR tx_ctl_oddr (
    .Q(rgmii_tx_ctl),
    .C(gtx_clk),
    .CE(1'b1),
    .D1(tx_en),           // Rising
    .D2(tx_en ^ tx_er),  // Falling
    .R(1'b0),
    .S(1'b0)
  );
  
  // RX DDR recovery (using IDDR primitive)
  wire [7:0] rx_byte_recovered;
  wire       rx_dv_recovered;
  wire       rx_er_recovered;
  
  generate
    for (i = 0; i < 4; i = i + 1) begin : rxd_iddr
      IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
      ) rxd_iddr (
        .Q1(rx_byte_recovered[i]),      // Rising edge
        .Q2(rx_byte_recovered[i+4]),    // Falling edge
        .C(rgmii_rxc),
        .CE(1'b1),
        .D(rgmii_rxd[i]),
        .R(1'b0),
        .S(1'b0)
      );
    end
  endgenerate
  
  IDDR ctl_iddr (
    .Q1(rx_dv_recovered),
    .Q2(rx_er_xor),
    .C(rgmii_rxc),
    .CE(1'b1),
    .D(rgmii_rx_ctl),
    .R(1'b0),
    .S(1'b0)
  );
  
  assign rx_er_recovered = rx_dv_recovered ^ rx_er_xor;
```

#### 2.8.4 SGMII Interface

```
Serial GMII (SGMII) - Cisco/Industry standard, IEEE 802.3 Clause 36 (adapted)

Data Path:
  TX: 1 differential pair, 1.25 Gbps line rate
  RX: 1 differential pair, 1.25 Gbps line rate

Physical Layer:
  8b/10b encoding (IBM code)
  Line rate: 1.25 Gbps (1G Ethernet)
  Effective data rate: 1 Gbps (20% overhead for 8b/10b)
  
  Reference clock: 125 MHz
  SERDES: 10x serialization (125MHz × 10 = 1.25G)

8b/10b Encoding:
  Data characters: /Dxx.y/ (256 data codes + 12 control codes)
  Control characters:
    /K28.5/ = 0xBC (comma, used for alignment)
    /K27.7/ = 0xFB (Start of frame, SOP)
    /K29.7/ = 0xFD (End of frame, EOP)
    /K30.7/ = 0xFE (Error, ERR)

SGMII vs 1000BASE-X:
  SGMII carries GMII signals over SERDES:
    - /C/ ordered sets for configuration
    - /S/ + data + /T/ for frame transmission
  
  1000BASE-X carries actual Ethernet:
    - Native MAC frame encoding
    - Auto-negotiation over in-band signaling

RTL Interface:
  Typically implemented with external SERDES/PHY:
  - MAC provides GMII/8-bit interface to PCS
  - PCS does 8b/10b encoding
  - SERDES serializes to differential pair
  
  Internal interface (MAC to PCS):
    input        sgmii_tx_clk,     // 125MHz
    output [7:0] sgmii_txd,
    output       sgmii_tx_en,
    output       sgmii_tx_er,
    input        sgmii_rx_clk,     // 125MHz from CDR
    input  [7:0] sgmii_rxd,
    input        sgmii_rx_dv,
    input        sgmii_rx_er,
    
  PCS Logic (if internal):
    // 8b/10b encoder/decoder
    // Comma detection and word alignment
    // Ordered set generation (/C1/, /C2/ for config)
```

#### 2.8.5 USXGMII Interface

```
Universal Serial 10GE MII (USXGMII) - IEEE 802.3 Clause 162

Data Path:
  TX: 1 differential pair, variable line rate
  RX: 1 differential pair, variable line rate

Line Rates:
  2.5G: 3.125 Gbps line rate
  5G:   6.25 Gbps line rate
  10G:  10.3125 Gbps line rate

Encoding:
  64b/66b (10G) or 64b/66b with RS-FEC (25G+)
  
  64b/66b block format:
    Bit[65] = 1, Bit[64] = 0: Data block (D)
      Bits[63:0] = 8 bytes data
    Bit[65] = 0, Bit[64] = 1: Control block (C)
      Bits[63:0] = control codes

USXGMII Multiplexing:
  Supports up to 8 virtual ports over single PHY
  Frame format includes 2-byte USXGMII header:
    Bits[15:13] = Port ID (0-7)
    Bit[12] = Start of frame
    Bit[11] = End of frame
    Bits[10:8] = reserved
    Bits[7:0] = data

RTL Interface:
  Typically external SERDES/PHY with USXGMII support:
  
  // MAC side (GMII-like, with port ID)
  output [2:0] usxg_port_id,
  output [7:0] usxg_txd,
  output       usxg_tx_en,
  output       usxg_tx_er,
  output       usxg_start,
  output       usxg_end,
  input  [7:0] usxg_rxd,
  input        usxg_rx_dv,
  input        usxg_rx_er,
  input        usxg_rx_start,
  input        usxg_rx_end,
  input  [2:0] usxg_rx_port_id,
```

---

### 2.9 Switch - RTL-Coding Detail

#### 2.9.1 FDB Entry Format

```
Forwarding Database (FDB) Entry Format

Entry Size: 128 bits (16 bytes)

Bits[127:80] = MAC Address [47:0] (48 bits)
Bits[79:68]  = VLAN ID [11:0] (12 bits)
Bits[67:64]  = Port Mask [3:0] (4 bits, one per egress port)
Bit[63]      = Static/Dynamic (1 = static, 0 = dynamic/learned)
Bits[62:56]  = Age Counter [6:0] (7 bits, decrements every aging period)
Bit[55]      = Valid
Bit[54]      = Drop (1 = drop frames to this MAC)
Bits[53:48]  = Reserved
Bits[47:32]  = MAC Address Hash [15:0] (for collision detection)
Bits[31:0]   = Timestamp/Sequence [31:0] (for LRU ordering)

FDB Memory:
  - Capacity: 4096 / 8192 / 16384 entries (configurable)
  - Organization: Hash table with 4-way or 8-way set associativity
  - Hash input: {MAC[47:0], VID[11:0]} = 60 bits
  - Hash output: Index into entry set

Hash Function (for 60-bit {MAC, VID}):
  hash[11:0] = crc12({mac, vid})  // 12-bit hash for 4K entries
  hash[12:0] = crc13({mac, vid})  // 13-bit hash for 8K entries
  
  CRC polynomial for FDB hash: 0x80F (CRC-12)
  
  // Alternative: XOR-folding
  hash = mac[47:24] ^ mac[23:0] ^ {20'b0, vid};

RTL Implementation:
  // FDB Entry Structure
  typedef struct packed {
    logic [47:0] mac_addr;
    logic [11:0] vid;
    logic [3:0]  port_mask;
    logic        is_static;
    logic [6:0]  age_counter;
    logic        valid;
    logic        drop;
    logic [15:0] hash_check;
    logic [31:0] timestamp;
  } fdb_entry_t;
  
  fdb_entry_t fdb_mem [0:FDB_SIZE-1];
  
  // Lookup (combinatorial, 2-cycle latency)
  wire [11:0] fdb_hash = crc12({rx_dmac, rx_vid});
  wire [3:0]  fdb_set = fdb_hash[3:0];  // 16 sets
  wire [7:0]  fdb_way_idx;  // 8-way associative
  
  // Parallel comparison across all ways in set
  always @(*) begin
    fdb_hit = 0;
    fdb_hit_mask = 4'b0000;
    for (i = 0; i < 8; i = i + 1) begin
      if (fdb_mem[fdb_set * 8 + i].valid &&
          fdb_mem[fdb_set * 8 + i].mac_addr == rx_dmac &&
          fdb_mem[fdb_set * 8 + i].vid == rx_vid) begin
        fdb_hit = 1;
        fdb_hit_mask = fdb_mem[fdb_set * 8 + i].port_mask;
      end
    end
  end
```

#### 2.9.2 Exact L2 Forwarding FSM

```verilog
// L2 Forwarding State Machine (per ingress frame)
localparam FWD_IDLE        = 4'd0;
localparam FWD_PARSE_DA    = 4'd1;
localparam FDB_LOOKUP      = 4'd2;
localparam FDB_WAIT        = 4'd3;
localparam VLAN_CHECK      = 4'd4;
localparam FWD_DECISION    = 4'd5;
localparam FWD_CROSSBAR    = 4'd6;
localparam FWD_BROADCAST   = 4'd7;
localparam FWD_MULTICAST   = 4'd8;
localparam FWD_DROP        = 4'd9;
localparam FWD_HOST        = 4'd10;

case (fwd_state)

FWD_IDLE:
  if (ingress_frame_valid) begin
    fwd_state <= FWD_PARSE_DA;
    ingress_port <= ingress_port_id;
  end

FWD_PARSE_DA:
  // Extract DA and first VLAN tag
  dmac <= frame_da;
  vid <= frame_vid;
  
  // Check special addresses
  if (dmac[40] == 1'b1) begin  // Group address (broadcast/multicast)
    if (dmac == 48'hFFFFFFFF_FFFF)
      fwd_state <= FWD_BROADCAST;
    else
      fwd_state <= FWD_MULTICAST;
  end else begin
    fwd_state <= FDB_LOOKUP;
  end

FDB_LOOKUP:
  // Initiate hash computation
  fdb_hash <= compute_hash(dmac, vid);
  fwd_state <= FDB_WAIT;

FDB_WAIT:
  // Wait for memory read (1 cycle for synchronous SRAM)
  fwd_state <= VLAN_CHECK;

VLAN_CHECK:
  // Check VLAN membership for ingress port
  vlan_member <= vlan_table[vid].port_mask[ingress_port];
  if (!vlan_member && !vlan_ingress_filter_bypass) begin
    fwd_state <= FWD_DROP;
    drop_reason <= VLAN_MEMBER_ERR;
  end else begin
    fwd_state <= FWD_DECISION;
  end

FWD_DECISION:
  if (fdb_hit) begin
    if (fdb_entry.drop) begin
      fwd_state <= FWD_DROP;
    end else begin
      egress_mask <= fdb_entry.port_mask;
      // Remove ingress port from egress (no loopback)
      egress_mask[ingress_port] <= 0;
      fwd_state <= FWD_CROSSBAR;
    end
  end else begin
    // Unknown unicast → flood to all VLAN members except ingress
    egress_mask <= vlan_table[vid].port_mask & ~(1 << ingress_port);
    fwd_state <= FWD_CROSSBAR;
  end

FWD_CROSSBAR:
  // Request Crossbar for each egress port
  for (p = 0; p < PORT_COUNT; p = p + 1) begin
    if (egress_mask[p])
      crossbar_req[p] <= 1;
  end
  fwd_state <= FWD_IDLE;  // Wait for crossbar grant

FWD_BROADCAST:
  // Flood to all ports in VLAN except ingress
  egress_mask <= vlan_table[vid].port_mask & ~(1 << ingress_port);
  fwd_state <= FWD_CROSSBAR;

FWD_MULTICAST:
  // Check multicast group table
  if (mcg_table_hit) begin
    egress_mask <= mcg_entry.port_mask;
  end else begin
    egress_mask <= vlan_table[vid].port_mask & ~(1 << ingress_port);
  end
  fwd_state <= FWD_CROSSBAR;

FWD_DROP:
  // Increment drop counter
  drop_cnt <= drop_cnt + 1;
  fwd_state <= FWD_IDLE;

FWD_HOST:
  // Frame to CPU (management)
  host_req <= 1;
  fwd_state <= FWD_IDLE;

endcase
```

#### 2.9.3 L3 Routing Lookup (if supported)

```
Layer 3 IP Routing Table Entry

Entry Size: 256 bits (32 bytes)

Bits[255:224] = IP Prefix (IPv4) or Upper 32 bits (IPv6)
Bits[223:192] = IP Lower (IPv4: don't care, IPv6: lower 96 bits in separate table)
Bits[191:160] = Next Hop IP Address (IPv4)
Bits[159:128] = Next Hop MAC Address [47:16]
Bits[127:112] = Next Hop MAC Address [15:0]
Bits[111:108] = Egress Port [3:0]
Bits[107]     = Valid
Bits[106]     = Is IPv6 (1 = IPv6, 0 = IPv4)
Bits[105:96]  = Prefix Length (0-32 for IPv4, 0-128 for IPv6)
Bits[95:80]   = VLAN ID (egress VLAN)
Bits[79:64]   = MTU
Bits[63:32]   = Route Metric/Priority
Bits[31:0]    = Age/Last Used Timestamp

Lookup Algorithm:
  Longest Prefix Match (LPM)
  
  Method 1: TCAM (Ternary CAM)
    - Direct LPM in hardware
    - < 50ns lookup time
    - Higher area/power
    
  Method 2: Trie/Radix tree in SRAM
    - Multi-cycle lookup
    - 200-500ns typical
    - Lower area/power

RTL Implementation (TCAM-based):
  // TCAM key: {IP Address, Prefix Length} with mask
  // TCAM entry: {Prefix, Mask, Next Hop Info}
  
  wire [31:0] l3_dst_ip = extracted_ip_dst;
  wire [4:0]  l3_prefix_len;
  wire [47:0] l3_next_hop_mac;
  wire [3:0]  l3_egress_port;
  
  // TCAM match
  tcam_l3_lookup #(
    .DEPTH(1024),
    .KEY_WIDTH(32)
  ) l3_tcam (
    .key(l3_dst_ip),
    .match(l3_tcam_match),
    .match_index(l3_tcam_idx),
    .entry_data({l3_next_hop_mac, l3_egress_port})
  );
```

#### 2.9.4 Crossbar Arbitration Algorithm

```verilog
// Crossbar Switch Matrix
// N ingress ports × N egress ports
// Supports concurrent non-conflicting transfers

// Arbitration: Round-Robin per egress port
// Priority: TT traffic > AVB > BE

module crossbar_arbiter #(
  parameter PORT_COUNT = 4
)(
  input  clk,
  input  rst_n,
  // Requests: req[src][dst] = 1 means port src wants to send to dst
  input  [PORT_COUNT-1:0] req [0:PORT_COUNT-1],
  // Grants: grant[src][dst] = 1 means src→dst authorized
  output [PORT_COUNT-1:0] grant [0:PORT_COUNT-1],
  // Egress busy
  input  [PORT_COUNT-1:0] egress_busy
);

  // Per-egress-port round-robin pointer
  reg [PORT_COUNT-1:0] rr_ptr [0:PORT_COUNT-1];
  
  // Two-level arbitration
  // Level 1: Per-egress, select one ingress among requestors
  // Level 2: Check for conflicts (one ingress can only go to one egress)
  
  genvar dst, src;
  generate
    for (dst = 0; dst < PORT_COUNT; dst = dst + 1) begin : egress_arb
      
      // Collect all requests to this egress
      wire [PORT_COUNT-1:0] req_to_dst;
      for (src = 0; src < PORT_COUNT; src = src + 1) begin
        assign req_to_dst[src] = req[src][dst] && !egress_busy[dst];
      end
      
      // Round-robin arbitration
      wire [PORT_COUNT-1:0] grant_to_dst;
      round_robin_arb #(
        .WIDTH(PORT_COUNT)
      ) rr_arb (
        .req(req_to_dst),
        .grant(grant_to_dst),
        .pointer(rr_ptr[dst]),
        .clk(clk),
        .rst_n(rst_n)
      );
      
      // Assign grants back
      for (src = 0; src < PORT_COUNT; src = src + 1) begin
        assign grant[src][dst] = grant_to_dst[src];
      end
    end
  endgenerate
  
  // Conflict resolution: if one ingress granted to multiple egress,
  // keep highest priority and clear others
  // Priority order: dst 0 > dst 1 > dst 2 > dst 3 (configurable)
  
  always @(posedge clk) begin
    for (dst = 0; dst < PORT_COUNT; dst = dst + 1) begin
      if (|grant_to_dst)
        rr_ptr[dst] <= next_rr_pointer(rr_ptr[dst], grant_to_dst);
    end
  end

endmodule
```

#### 2.9.5 AVTP Filter Format

```
AVTP (IEEE 1722) Filter Format

AVTP Common Header:
  Byte 0:    cd_field (1 bit) + subtype (7 bits)
             cd=1: control, cd=0: data
             subtype: 0x00 = 61883, 0x01 = CRF, 0x02 = AVC,
                      0x03 = AAF, 0x04 = CVF, 0x05 = CLF,
                      0x06 = MAAP
  Byte 1:    sv_field (1 bit) + version (3 bits) + mr_field (1 bit) +
             gv_field (1 bit) + tv_field (1 bit) + reserved (1 bit)
  Bytes 2-3: sequence_num (16 bits)
  Bytes 4-7: timestamp (32 bits, nanoseconds)
  Bytes 8-9: stream_id_upper (16 bits)
  Bytes 10-17: stream_id_lower (64 bits)

AVTP Filter Entry (per stream):
  Bits[63:0]  = Stream ID (match against bytes 8-17)
  Bits[79:64] = VLAN ID (for stream isolation)
  Bits[87:80] = PCP (priority mapping)
  Bits[95:88] = Target DMA Queue
  Bits[103:96] = Subtype filter (0xFF = any)
  Bit[104]    = Valid
  Bit[105]    = Timestamp capture enable
  Bit[106]    = RX separation enable (route to dedicated queue)
  Bits[127:107] = reserved

Filter Lookup:
  Key = {VLAN ID, Stream ID} (80 bits)
  Match → Route to configured DMA queue + optional timestamp capture

RTL Implementation:
  typedef struct packed {
    logic [63:0] stream_id;
    logic [11:0] vid;
    logic [2:0]  pcp;
    logic [2:0]  target_queue;
    logic [7:0]  subtype;
    logic        valid;
    logic        ts_capture;
    logic        rx_separate;
  } avtp_filter_t;
  
  avtp_filter_t avtp_filters [0:31];  // 32 streams
  
  // AVTP detection and filtering
  wire is_avtp = (frame_etype == 16'h22F0);  // IEEE 1722 EtherType
  
  always @(*) begin
    avtp_match = 0;
    avtp_queue = 0;
    for (i = 0; i < 32; i = i + 1) begin
      if (avtp_filters[i].valid &&
          avtp_filters[i].stream_id == frame_stream_id &&
          avtp_filters[i].vid == frame_vid) begin
        avtp_match = 1;
        avtp_queue = avtp_filters[i].target_queue;
      end
    end
  end
```

---

## 3. Protocol-to-Function Mapping

### 3.1 Function-Protocol Correspondence

| GETH Function | Protocol | Implementation Module | RTL Complexity |
|---------------|----------|----------------------|---------------|
| 10M~5G MAC | 802.3 | XGMAC-CORE | Medium |
| Full/Half Duplex | 802.3 | XGMAC-CORE | Low |
| VLAN tag insert/strip/filter | 802.1Q | XGMAC-CORE | Medium |
| Stacked VLAN (Q-in-Q) | 802.1Q | XGMAC-CORE | Medium |
| gPTP time sync | 802.1AS | XGMAC-CORE (TS module) | High |
| IEEE 1588 PTP | 1588 | XGMAC-CORE | Medium |
| Credit-Based Shaper | 802.1Qav | XGMAC-MTL | Medium |
| Frame Preemption | 802.1Qbu/802.3br | XGMAC-CORE | High |
| Scheduled Traffic (EST) | 802.1Qbv | XGMAC-MTL (GCL Memory) | High |
| Stream-Gate Filtering | 802.1Qci | XGMAC-CORE | High |
| FRER (frame replication/elimination) | 802.1CB | Bridge / XGMAC-CORE | High |
| MACsec | 802.1AE | XGMAC-CORE / Security Engine | High |
| EEE | 802.3az | XGMAC-CORE | Low |
| Checksum Offload | - | XGMAC-CORE | Medium |
| L3/L4 Filtering | - | XGMAC-CORE | Medium |
| Multichannel DMA (8ch) | - | XGMAC-DMA | High |
| **Switch Core (4-port L2/L3)** | **802.1D/802.1Q** | **Switch Core** | **High** |
| FDB self-learning | 802.1D | Switch Core | Medium |
| VLAN forwarding | 802.1Q | Switch Core | Medium |
| L3 IP routing | - | Switch Core | High |
| Multicast filtering / IGMP Snooping | - | Switch Core | Medium |
| **Switch-level TAS** | **802.1Qbv** | **Switch Core** | **High** |
| **Switch-level gPTP Relay** | **802.1AS** | **Switch Core + PTP** | **High** |
| PHY interfaces (MII/RMII/RGMII/SGMII/USXGMII) | 802.3 | HSPHY | Medium |
| ECC/Parity/Timeout | - | Global | Medium |
| RMON/MIB counters | RFC2819/2665 | XGMAC-CORE | Low |

### 3.2 Module-Level Protocol Coverage

```
XGMAC-CORE (MAC Core)
├── 802.3 MAC Tx/Rx (exact FSM states defined in §2.1)
├── 802.1Q VLAN processing (TCI bit layout in §2.6)
├── 802.1AS/1588 timestamp (80-bit format, SFD capture in §2.2)
├── 802.1Qbu frame preemption (mPacket format, SMD values in §2.5)
├── 802.1Qci flow filtering
├── 802.1AE MACsec (optional)
├── 802.3az EEE
├── Address filtering (32 DA + 32 SA perfect match)
├── L3/L4 filtering (8 filters)
└── RMON counters

XGMAC-MTL (MAC Transaction Layer)
├── 32KB Tx FIFO
├── 32KB Rx FIFO
├── 802.1Qav CBS (credit formula, fixed-point in §2.4)
├── 802.1Qbv EST (GCL entry format, execution FSM in §2.3)
└── Queue management (8 TxQ / 8 RxQ)

XGMAC-DMA
├── 8-channel Tx/Rx DMA
├── Descriptor ring management
├── Timestamp delivery
└── Interrupt management

Switch Core (optional, 2~8 ports)
├── **L2 switching**: MAC self-learning, VLAN forwarding, multicast filtering
├── **L3 routing**: IP lookup, ARP cache (optional)
├── **802.1CB FRER**: Frame replication/elimination, multi-port parallel
├── **802.1Qbv Switch-level TAS**: Ingress port gate control scheduling
├── **802.1Qci Switch-level PSFP**: Per-stream filtering and policing
├── **802.1AS multi-port Relay**: BC/TC, dual PHC binding
├── **FDB**: 4K/8K/16K entries, hardware hash table, auto-aging
├── **VLAN Table**: VID → port mask, tag processing
└── **Crossbar + Arbiter**: Multi-port full concurrent forwarding

HSPHY (High Speed PHY Interface)
├── MII (4-bit nibble, 25MHz, exact timing in §2.8.1)
├── RMII (2-bit, 50MHz REF_CLK in §2.8.2)
├── RGMII (4-bit DDR, 125MHz, skew requirements in §2.8.3)
├── SGMII (8b/10b, 1.25Gbps in §2.8.4)
└── USXGMII (64b/66b, 6.25Gbps in §2.8.5)
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
│   ├── crc