//------------------------------------------------------------------------------
// Copyright (c) 2006-2017 Cadence Design Systems, Inc.
//
// The information herein (Cadence IP) contains confidential and proprietary
// information of Cadence Design Systems, Inc. Cadence IP may not be modified,
// copied, reproduced, distributed, or disclosed to third parties in any manner,
// medium, or form, in whole or in part, without the prior written consent of
// Cadence Design Systems Inc. Cadence IP is for use by Cadence Design Systems,
// Inc. customers only. Cadence Design Systems, Inc. reserves the right to make
// changes to Cadence IP at any time and without notice.
//------------------------------------------------------------------------------
//
//   Filename:           tb_dpram.v
//   Module Name:        tb_dpram
//
//   Release Revision:   r1p12
//   Release SVN Tag:    gem_gxl_det0104_r1p12
//
//   IP Name:            GEM Gigabit Ethernet MAC
//   IP Part Number:     IP7014A
//
//   Product Type:       Off-the-shelf
//   IP Type:            Soft
//   IP Family:          Ethernet Controller
//   Technology:         N/A
//   Protocol:           Ethernet
//   Architecture:       N/A
//   Licensable IP:      SIP-Ethernet-MAC+DMA+1588+TSN+PCS+A-10M/100M/1G-IP7014A
//
//------------------------------------------------------------------------------
//   Description    : Simple Dual Port SRAM model for testbench
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_dpram (
   // Port A
   a_we,
   a_cs,
   a_clk,
   a_addr,
   a_wdata,
   a_rdata,

   // Port B
   b_we,
   b_cs,
   b_clk,
   b_addr,
   b_wdata,
   b_rdata
);



// Parameters
   parameter p_clash_chk  = 0;
   parameter p_data_width = 32;     // Number of data bits
   parameter p_addr_width = 12;     // Number of address bits
   parameter p_depth      = 2048;   // Number of address locations
   parameter p_ram_inactive_val = 1'bx;


// I/O declarations

// Port A
   output [p_data_width-1:0] a_rdata;
   input  [p_addr_width-1:0] a_addr;
   input                     a_cs;
   input                     a_we;
   input                     a_clk;
   input  [p_data_width-1:0] a_wdata;

// Port B
   output [p_data_width-1:0] b_rdata;
   input  [p_addr_width-1:0] b_addr;
   input                     b_cs;
   input                     b_we;
   input                     b_clk;
   input  [p_data_width-1:0] b_wdata;


// Internal variables
   reg    [p_data_width-1:0] a_rdata;
   reg    [p_data_width-1:0] a_rdata_rise;
   reg    [p_data_width-1:0] b_rdata;
   reg    [p_data_width-1:0] b_rdata_rise;
   reg    [p_data_width-1:0] mem[p_depth-1:0];
   reg    [p_depth-1:0]      valid;
   wire   [p_data_width-1:0] mem0;
   wire   [p_data_width-1:0] mem1;
   wire                      wr_clash;


   reg  [p_addr_width-1:0] b_addr_del;
// Initialise variables
initial
   begin
   valid = {p_depth{1'b0}};
   end


// Port A memory access
always @(posedge a_clk)
   if (a_cs)
   begin
   // Invalidate current lcoation to indicate that it has been read
   // and assign next read data
   if (~a_we)
      begin
      valid[a_addr] <= 1'b0;
      a_rdata_rise <= mem[a_addr];
      end
   else
      a_rdata_rise <= {p_data_width{p_ram_inactive_val}};

   // If writing then write data to array and validate location.
   if (a_we)
      begin
      mem[a_addr]   <= a_wdata;
      valid[a_addr] <= 1'b1;
      end
   end
   else
      a_rdata_rise <= {p_data_width{p_ram_inactive_val}};

always @(negedge a_clk)
   begin
    a_rdata = a_rdata_rise;
   end

// Port B memory access
always @(posedge b_clk)
   if (b_cs)
   begin
   // Invalidate current lcoation to indicate that it has been read
   // and assign next read data
   valid[b_addr] <= 1'b0;

   // If writing then write data to array and validate location.
   if (b_we)
      begin
      mem[b_addr]   <= b_wdata;
      valid[b_addr] <= 1'b1;
      end
   end
always @(posedge b_clk)
   if (b_cs & ~b_we)
   begin
    b_rdata_rise <= mem[b_addr];
   end
  else
     b_rdata_rise <= {p_data_width{p_ram_inactive_val}};

always @(negedge b_clk)
   begin
    b_rdata = b_rdata_rise;
   end


// Detect a clash where both PORT A and PORT B access the same location.
assign wr_clash = (a_cs & b_cs & a_addr == b_addr) && (p_clash_chk != 32'd0);
always @(posedge wr_clash)
  begin
    // Check its not a glitch
    #8;
    if (wr_clash)
    begin
    $display ("**** WARNING: TB_DPRAM: Clash of write/read addresses");
    $display ("**** FAILED ****");
    $finish;
    end
  end



// Monitor wires for debug
assign mem0 = mem[0];
assign mem1 = mem[1];


endmodule
