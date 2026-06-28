//------------------------------------------------------------------------------
// Copyright (c) 2002-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_dma_axi.v
//   Module Name:        tb_dma_axi
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
// Description: This testbench block provides stimulus and checking for
//              the AHB interfaces. Read and write operations are tested
//              separately. The stimulus and check data is loaded from
//              files that have been created with the Perl program
//              trans_eth.pl
//
//------------------------------------------------------------------------------


`ifdef xgm
  `include "xgm_defs.v"
`else
  `include "gem_gxl_defs.v"
`endif
`include "tb_defs.v"

module tb_dma_axi (
   reset_tb,
   hclk,
   fault_sim,
   double_error_injection,
   dma_bus_width,
   amba_ready_delay,
   bus_grant_delay,
   apb_endian_wr,
   apb_endian_val,
   axi_perf_test,

   // AXI Interface
   // Write Address Channel
   awqos,
   awid,
   awaddr,
   awlen,
   awsize,
   awburst,
   awlock,
   awcache,
   awprot,
   awvalid,
   awready,
   // Write Data Channel
   wdata,
   wstrb,
   wlast,
   wready,
   wvalid,

   // Response Channel
   bid,
   bresp,
   bvalid,
   bready,

   // Read Address Channel
   arqos,
   arid,
   araddr,
   arlen,
   arsize,
   arburst,
   arlock,
   arcache,
   arprot,
   arvalid,
   arready,
   // Read Data Channel
   rid,
   rdata,
   rresp,
   rlast,
   rvalid,
   rready,

   randomize_hgrant,
   randomize_hready,
   fixed_latency_mode,
   descr_min,
   descr_max,
   data_min ,
   data_max ,
   data_min_lock ,
   data_max_lock ,
   read_min  ,
   read_max  ,
   write_min ,
   write_max ,

   dma_done,
   dma_fail,

   apb_64b_addr_mode_en,
   apb_tx_ext_bd_mode_en,
   apb_qos_for_axi

);

// -----------------------------------------------------------------------------
// Declare inputs and outputs
// -----------------------------------------------------------------------------
   input          reset_tb;            // test bench reset
   input          hclk;                // AHB clock bus
   input          fault_sim;           // Fault simulation, avoid x
   input          double_error_injection; //
   input    [1:0] dma_bus_width;       // DMA bus width
                                       // 00 = 32 bit
                                       // 01 = 64 bit
                                       // 1x = 128 bit
   input    [3:0] amba_ready_delay;    // number of clocks hready is delayed
   input    [3:0] bus_grant_delay;     // number of clocks hgrant is delayed
   input          apb_endian_wr;       // APB write to endianism value
   input    [1:0] apb_endian_val;      // APB endian value during write
   input          axi_perf_test;       // performance Test

   // AHB interface signals
   // Write Address Channel
   input  [3:0]  awqos;
   input  [3:0]  awid;
   input  [`edma_addr_width-1:0] awaddr;
   input  [7:0]  awlen;
   input  [2:0]  awsize;
   input  [1:0]  awburst;
   input  [1:0]  awlock;
   input  [3:0]  awcache;
   input  [2:0]  awprot;
   input         awvalid;
   output        awready;
   // Write Data Channel
   input [127:0] wdata;
   input [15:0]  wstrb;
   input         wlast;
   output        wready;
   input         wvalid;

   // Response Channel
   output  [3:0] bid;
   output  [1:0] bresp;
   output        bvalid;
   input         bready;

   // Read Address Channel
   input  [3:0]  arqos;
   input  [3:0]  arid;
   input  [`edma_addr_width-1:0] araddr;
   input  [7:0]  arlen;
   input  [2:0]  arsize;
   input  [1:0]  arburst;
   input  [1:0]  arlock;
   input  [3:0]  arcache;
   input  [2:0]  arprot;
   input         arvalid;
   output        arready;
   // Read Data Channel
   output [3:0]  rid;
   output[127:0] rdata;
   output [1:0]  rresp;
   output        rlast;
   output        rvalid;
   input         rready;

   input          randomize_hgrant;    // Randomize Hgrant
   input          randomize_hready;    // Randomize Hready
   input          fixed_latency_mode;
   input   [7:0]  descr_min;
   input   [7:0]  descr_max;
   input   [7:0]  data_min ;
   input   [7:0]  data_max ;
   input   [7:0]  data_min_lock ;
   input   [7:0]  data_max_lock ;
   input   [7:0]  read_min ;
   input   [7:0]  read_max ;
   input   [7:0]  write_min ;
   input   [7:0]  write_max ;

   // test bench reporting stuff
   output         dma_done;            // Testbench complete
   output         dma_fail;            // Testbench failed

   input          apb_64b_addr_mode_en; // indicates 64b address mode reg has been enabled
   input          apb_tx_ext_bd_mode_en; //
   input  [127:0] apb_qos_for_axi; //


`ifdef edma_axi
parameter tb_axi_pipeline_depth = 4;  // the actual depth is 2^ of this number
// -----------------------------------------------------------------------------
// Declare internal signals
// -----------------------------------------------------------------------------

   // decode access size and address alignment
   reg      arready;
   reg      awready;
   reg      wready ;
   reg      rvalid ;
   reg      bvalid ;


   reg      [1:0] aw_access_width;        // async decode of access width
   reg      [1:0] ar_access_width;        // async decode of access width

   reg      [1:0] endian_value;        // Current endianism value programmed



   reg     [31:0] hready_vector_reg [1:20];  // array used for reading file
   wire    [31:0] hready_vector;       // current hready_vector_reg
   integer        hready_index;        // pointer to current hready_vector
   reg            hready_stop;         // stop hready whilst active
   reg     [15:0] hready_stop_cnt;     // counter used for hready stopping
   wire    [15:0] hready_stop_delay;   // delay before asserting hready_stop
   wire    [15:0] hready_stop_active;  // how long hready_stop is asserted for

   reg            fail_1, fail_2, fail_3, fail_4;
   // tb_dma array for test file read data storage
   reg     [99:0] dma_rd_vector_reg[1:200000];
   integer        next_dma_rd_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_index;        // current index to dma_rd_vector_reg

   reg     [99:0] dma_rd_q1_vector_reg[1:200000];
   integer        next_dma_rd_q1_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q1_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q2_vector_reg[1:200000];
   integer        next_dma_rd_q2_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q2_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q3_vector_reg[1:200000];
   integer        next_dma_rd_q3_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q3_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q4_vector_reg[1:200000];
   integer        next_dma_rd_q4_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q4_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q5_vector_reg[1:200000];
   integer        next_dma_rd_q5_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q5_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q6_vector_reg[1:200000];
   integer        next_dma_rd_q6_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q6_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q7_vector_reg[1:200000];
   integer        next_dma_rd_q7_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q7_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q8_vector_reg[1:200000];
   integer        next_dma_rd_q8_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q8_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q9_vector_reg[1:200000];
   integer        next_dma_rd_q9_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q9_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q10_vector_reg[1:200000];
   integer        next_dma_rd_q10_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q10_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q11_vector_reg[1:200000];
   integer        next_dma_rd_q11_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q11_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q12_vector_reg[1:200000];
   integer        next_dma_rd_q12_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q12_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q13_vector_reg[1:200000];
   integer        next_dma_rd_q13_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q13_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q14_vector_reg[1:200000];
   integer        next_dma_rd_q14_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q14_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_q15_vector_reg[1:200000];
   integer        next_dma_rd_q15_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_q15_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_vector_tx_data_q0_reg[1:200000];
   integer        tx_data_q0_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q0_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q1_reg[1:200000];
   integer        tx_data_q1_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q1_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q2_reg[1:200000];
   integer        tx_data_q2_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q2_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q3_reg[1:200000];
   integer        tx_data_q3_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q3_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q4_reg[1:200000];
   integer        tx_data_q4_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q4_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q5_reg[1:200000];
   integer        tx_data_q5_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q5_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q6_reg[1:200000];
   integer        tx_data_q6_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q6_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q7_reg[1:200000];
   integer        tx_data_q7_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q7_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q8_reg[1:200000];
   integer        tx_data_q8_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q8_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q9_reg[1:200000];
   integer        tx_data_q9_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q9_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q10_reg[1:200000];
   integer        tx_data_q10_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q10_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q11_reg[1:200000];
   integer        tx_data_q11_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q11_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q12_reg[1:200000];
   integer        tx_data_q12_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q12_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q13_reg[1:200000];
   integer        tx_data_q13_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q13_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q14_reg[1:200000];
   integer        tx_data_q14_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q14_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_data_q15_reg[1:200000];
   integer        tx_data_q15_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_data_q15_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_reg[1:200000];
   integer        tx_descr_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q1_reg[1:200000];
   integer        tx_descr_q1_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q1_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q2_reg[1:200000];
   integer        tx_descr_q2_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q2_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q3_reg[1:200000];
   integer        tx_descr_q3_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q3_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q4_reg[1:200000];
   integer        tx_descr_q4_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q4_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q5_reg[1:200000];
   integer        tx_descr_q5_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q5_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q6_reg[1:200000];
   integer        tx_descr_q6_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q6_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q7_reg[1:200000];
   integer        tx_descr_q7_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q7_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q8_reg[1:200000];
   integer        tx_descr_q8_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q8_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q9_reg[1:200000];
   integer        tx_descr_q9_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q9_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q10_reg[1:200000];
   integer        tx_descr_q10_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q10_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q11_reg[1:200000];
   integer        tx_descr_q11_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q11_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q12_reg[1:200000];
   integer        tx_descr_q12_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q12_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q13_reg[1:200000];
   integer        tx_descr_q13_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q13_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q14_reg[1:200000];
   integer        tx_descr_q14_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q14_dma_rd_index; // current index to dma_rd_vector_reg -
   reg     [99:0] dma_rd_vector_tx_descr_q15_reg[1:200000];
   integer        tx_descr_q15_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_q15_dma_rd_index; // current index to dma_rd_vector_reg -
   integer        tx_rewind_index;        // current index to dma_rd_vector_reg -
                                       // only used by random tb
   integer        j;                   // loop variable
   wire    [99:0] dma_rd_vector_nxt_orig; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q1; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q2; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q3; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q4; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q5; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q6; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q7; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q8; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q9; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q10; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q11; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q12; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q13; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q14; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_q15; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q0; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q1; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q2; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q3; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q4; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q5; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q6; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q7; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q8; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q9; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q10; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q11; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q12; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q13; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q14; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_data_q15; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q1; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q2; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q3; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q4; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q5; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q6; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q7; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q8; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q9; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q10; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q11; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q12; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q13; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q14; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_nxt_tx_descr_q15; // next dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_plus0; // current dma_rd_vector_reg
   wire    [99:0] dma_rd_vector_plus1; // current dma_rd_vector_reg + 1
   wire    [99:0] dma_rd_vector_plus2; // current dma_rd_vector_reg + 2
   wire    [99:0] dma_rd_vector_plus3; // current dma_rd_vector_reg + 3
   wire    [31:0] read_data_31to0;     // read data to drive (31 to 0)
   wire    [31:0] read_data_63to32;    // read data to drive (63 to 32)
   wire    [31:0] read_data_95to64;    // read data to drive (95 to 64)
   wire    [31:0] read_data_127to96;   // read data to drive (127 to 96)
   wire    [63:0] next_read_add_orig;       // expected read address
   wire    [63:0] next_read_add_q1;       // expected read address
   wire    [63:0] next_read_add_q2;       // expected read address
   wire    [63:0] next_read_add_q3;       // expected read address
   wire    [63:0] next_read_add_q4;       // expected read address
   wire    [63:0] next_read_add_q5;       // expected read address
   wire    [63:0] next_read_add_q6;       // expected read address
   wire    [63:0] next_read_add_q7;       // expected read address
   wire    [63:0] next_read_add_q8;       // expected read address
   wire    [63:0] next_read_add_q9;       // expected read address
   wire    [63:0] next_read_add_q10;       // expected read address
   wire    [63:0] next_read_add_q11;       // expected read address
   wire    [63:0] next_read_add_q12;       // expected read address
   wire    [63:0] next_read_add_q13;       // expected read address
   wire    [63:0] next_read_add_q14;       // expected read address
   wire    [63:0] next_read_add_q15;       // expected read address
   wire    [63:0] next_read_add_tx_data_q0 ;       // expected read address
   wire    [63:0] next_read_add_tx_data_q1;       // expected read address
   wire    [63:0] next_read_add_tx_data_q2;       // expected read address
   wire    [63:0] next_read_add_tx_data_q3;       // expected read address
   wire    [63:0] next_read_add_tx_data_q4;       // expected read address
   wire    [63:0] next_read_add_tx_data_q5;       // expected read address
   wire    [63:0] next_read_add_tx_data_q6;       // expected read address
   wire    [63:0] next_read_add_tx_data_q7;       // expected read address
   wire    [63:0] next_read_add_tx_data_q8;       // expected read address
   wire    [63:0] next_read_add_tx_data_q9;       // expected read address
   wire    [63:0] next_read_add_tx_data_q10;       // expected read address
   wire    [63:0] next_read_add_tx_data_q11;       // expected read address
   wire    [63:0] next_read_add_tx_data_q12;       // expected read address
   wire    [63:0] next_read_add_tx_data_q13;       // expected read address
   wire    [63:0] next_read_add_tx_data_q14;       // expected read address
   wire    [63:0] next_read_add_tx_data_q15;       // expected read address
   wire    [63:0] next_read_add_tx_descr;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q1;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q2;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q3;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q4;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q5;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q6;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q7;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q8;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q9;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q10;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q11;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q12;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q13;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q14;       // expected read address
   wire    [63:0] next_read_add_tx_descr_q15;       // expected read address
   wire    [63:0] next_read_add;       // expected read address
   wire           rd_not_ok;           // whether the read will have an error
   wire           rd_endian_swap;      // Endian word swap
   wire           dma_rd_done;         // all read data complete
   wire    [31:0] read_data_31to0_end;  // read data to drive (31 to 0) endian swapped
   wire    [31:0] read_data_63to32_end; // read data to drive (63 to 32) endian swapped
   wire    [31:0] read_data_95to64_end; // read data to drive (95 to 64) endian swapped
   wire    [31:0] read_data_127to96_end;// read data to drive (127 to 96) endian swapped

   // tb_dma array for test file write data storage
   reg     [107:0] dma_wr_rx_data_q0[1:200000];
                                       // array for storing test file data
   integer        next_index_dma_wr_rx_data_q0;   // next index to dma_wr_rx_data_q0
   integer        index_dma_wr_rx_data_q0;        // current index to dma_wr_rx_data_q0
   integer        k;                   // loop variable
   wire    [107:0] vector_dma_wr_rx_data_q0; // current dma_wr_rx_data_q0
   wire    [107:0] dma_wr_vector_plus0; // current dma_wr_rx_data_q0
   wire    [107:0] dma_wr_vector_plus1; // current dma_wr_rx_data_q0 + 1
   wire    [107:0] dma_wr_vector_plus2; // current dma_wr_rx_data_q0 + 2
   wire    [107:0] dma_wr_vector_plus3; // current dma_wr_rx_data_q0 + 3
   wire    [31:0] write_data_31to0;    // expected write data (31 to 0)
   wire    [31:0] write_data_63to32;   // expected write data (63 to 32)
   wire    [31:0] write_data_95to64;   // expected write data (95 to 64)
   wire    [31:0] write_data_127to96;  // expected write data (127 to 96)
   wire    [31:0]  write_en_31to0;    // expected write strobe (31 to 0)
   wire    [31:0]  write_en_63to32;   // expected write strobe (63 to 32)
   wire    [31:0]  write_en_95to64;   // expected write strobe (95 to 64)
   wire    [31:0]  write_en_127to96;  // expected write strobe (127 to 96)
   wire    [107:0] nxt_vector_dma_wr_rx_data_q0;  // next dma_wr_rx_data_q0
   wire    [107:0] nxt_vector_dma_wr;  // next dma_wr_rx_data_q0
   wire    [63:0] next_rx_data_write_add_q0;      // next expected addr
   wire    [63:0] next_write_add;      // next expected addr
   wire           wr_not_ok;           // whether the write will have an error
   wire           wr_endian_swap;      // Endian word swap
   wire           dma_wr_done;         // all write data complete
   integer        next_index_dma_wr_tx_descr_q0;   // next index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q0;        // current index to dma_wr_rx_data_q0
   integer        next_index_dma_wr_rx_descr_q0;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_rx_descr_q0;        // current index to dma_wr_rx_data_q0
   reg     [107:0] dma_wr_tx_descr_q0[1:200000];
   reg     [107:0] dma_rx_wr_descr_q0[1:200000];
                                       // array for storing test file data
   wire    [107:0] vector_dma_wr_tx_descr_q0; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_rx_descr_q0; // current dma_wr_rx_data_q0
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q0;  // next dma_wr_rx_data_q0
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q0;  // next dma_wr_rx_data_q0
   wire    [63:0] next_tx_descr_write_add_q0;      // next expected addr
   wire    [63:0] next_rx_descr_write_add_q0;      // next expected addr

   wire           using_q0_rx_data_wr;
   wire           using_q0_tx_descr_wr;
   wire           using_q0_rx_descr_wr;
   `ifdef dma_priority_queue1
   reg     [107:0] dma_wr_tx_descr_q1[1:200000];
   reg     [107:0] dma_wr_tx_descr_q2[1:200000];
   reg     [107:0] dma_wr_tx_descr_q3[1:200000];
   reg     [107:0] dma_wr_tx_descr_q4[1:200000];
   reg     [107:0] dma_wr_tx_descr_q5[1:200000];
   reg     [107:0] dma_wr_tx_descr_q6[1:200000];
   reg     [107:0] dma_wr_tx_descr_q7[1:200000];
   reg     [107:0] dma_wr_tx_descr_q8[1:200000];
   reg     [107:0] dma_wr_tx_descr_q9[1:200000];
   reg     [107:0] dma_wr_tx_descr_q10[1:200000];
   reg     [107:0] dma_wr_tx_descr_q11[1:200000];
   reg     [107:0] dma_wr_tx_descr_q12[1:200000];
   reg     [107:0] dma_wr_tx_descr_q13[1:200000];
   reg     [107:0] dma_wr_tx_descr_q14[1:200000];
   reg     [107:0] dma_wr_tx_descr_q15[1:200000];
   reg     [107:0] dma_wr_rx_descr_q1[1:200000];
   reg     [107:0] dma_wr_rx_descr_q2[1:200000];
   reg     [107:0] dma_wr_rx_descr_q3[1:200000];
   reg     [107:0] dma_wr_rx_descr_q4[1:200000];
   reg     [107:0] dma_wr_rx_descr_q5[1:200000];
   reg     [107:0] dma_wr_rx_descr_q6[1:200000];
   reg     [107:0] dma_wr_rx_descr_q7[1:200000];
   reg     [107:0] dma_wr_rx_descr_q8[1:200000];
   reg     [107:0] dma_wr_rx_descr_q9[1:200000];
   reg     [107:0] dma_wr_rx_descr_q10[1:200000];
   reg     [107:0] dma_wr_rx_descr_q11[1:200000];
   reg     [107:0] dma_wr_rx_descr_q12[1:200000];
   reg     [107:0] dma_wr_rx_descr_q13[1:200000];
   reg     [107:0] dma_wr_rx_descr_q14[1:200000];
   reg     [107:0] dma_wr_rx_descr_q15[1:200000];
   reg     [107:0] dma_wr_rx_data_q1[1:200000];
   reg     [107:0] dma_wr_rx_data_q2[1:200000];
   reg     [107:0] dma_wr_rx_data_q3[1:200000];
   reg     [107:0] dma_wr_rx_data_q4[1:200000];
   reg     [107:0] dma_wr_rx_data_q5[1:200000];
   reg     [107:0] dma_wr_rx_data_q6[1:200000];
   reg     [107:0] dma_wr_rx_data_q7[1:200000];
   reg     [107:0] dma_wr_rx_data_q8[1:200000];
   reg     [107:0] dma_wr_rx_data_q9[1:200000];
   reg     [107:0] dma_wr_rx_data_q10[1:200000];
   reg     [107:0] dma_wr_rx_data_q11[1:200000];
   reg     [107:0] dma_wr_rx_data_q12[1:200000];
   reg     [107:0] dma_wr_rx_data_q13[1:200000];
   reg     [107:0] dma_wr_rx_data_q14[1:200000];
   reg     [107:0] dma_wr_rx_data_q15[1:200000];

   wire    [107:0] vector_dma_wr_tx_descr_q1; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q2; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q3; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q4; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q5; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q6; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q7; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q8; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q9; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q10; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q11; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q12; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q13; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q14; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_tx_descr_q15; // current dma_wr_rx_data_q0
   wire    [107:0] vector_dma_wr_rx_data_q1;
   wire    [107:0] vector_dma_wr_rx_data_q2;
   wire    [107:0] vector_dma_wr_rx_data_q3;
   wire    [107:0] vector_dma_wr_rx_data_q4;
   wire    [107:0] vector_dma_wr_rx_data_q5;
   wire    [107:0] vector_dma_wr_rx_data_q6;
   wire    [107:0] vector_dma_wr_rx_data_q7;
   wire    [107:0] vector_dma_wr_rx_data_q8;
   wire    [107:0] vector_dma_wr_rx_data_q9;
   wire    [107:0] vector_dma_wr_rx_data_q10;
   wire    [107:0] vector_dma_wr_rx_data_q11;
   wire    [107:0] vector_dma_wr_rx_data_q12;
   wire    [107:0] vector_dma_wr_rx_data_q13;
   wire    [107:0] vector_dma_wr_rx_data_q14;
   wire    [107:0] vector_dma_wr_rx_data_q15;
   wire    [107:0] vector_dma_wr_rx_descr_q1;
   wire    [107:0] vector_dma_wr_rx_descr_q2;
   wire    [107:0] vector_dma_wr_rx_descr_q3;
   wire    [107:0] vector_dma_wr_rx_descr_q4;
   wire    [107:0] vector_dma_wr_rx_descr_q5;
   wire    [107:0] vector_dma_wr_rx_descr_q6;
   wire    [107:0] vector_dma_wr_rx_descr_q7;
   wire    [107:0] vector_dma_wr_rx_descr_q8;
   wire    [107:0] vector_dma_wr_rx_descr_q9;
   wire    [107:0] vector_dma_wr_rx_descr_q10;
   wire    [107:0] vector_dma_wr_rx_descr_q11;
   wire    [107:0] vector_dma_wr_rx_descr_q12;
   wire    [107:0] vector_dma_wr_rx_descr_q13;
   wire    [107:0] vector_dma_wr_rx_descr_q14;
   wire    [107:0] vector_dma_wr_rx_descr_q15;

   wire    [107:0] nxt_vector_dma_wr_tx_descr_q1;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q2;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q3;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q4;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q5;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q6;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q7;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q8;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q9;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q10;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q11;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q12;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q13;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q14;
   wire    [107:0] nxt_vector_dma_wr_tx_descr_q15;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q1;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q2;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q3;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q4;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q5;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q6;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q7;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q8;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q9;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q10;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q11;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q12;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q13;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q14;
   wire    [107:0] nxt_vector_dma_wr_rx_descr_q15;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q1;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q2;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q3;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q4;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q5;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q6;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q7;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q8;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q9;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q10;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q11;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q12;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q13;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q14;
   wire    [107:0] nxt_vector_dma_wr_rx_data_q15;

   integer        index_dma_wr_tx_descr_q1;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q2;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q3;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q4;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q5;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q6;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q7;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q8;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q9;        // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q10;       // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q11;       // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q12;       // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q13;       // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q14;       // current index to dma_wr_rx_data_q0
   integer        index_dma_wr_tx_descr_q15;       // current index to dma_wr_rx_data_q0
   integer        next_index_dma_wr_tx_descr_q1;
   integer        next_index_dma_wr_tx_descr_q2;
   integer        next_index_dma_wr_tx_descr_q3;
   integer        next_index_dma_wr_tx_descr_q4;
   integer        next_index_dma_wr_tx_descr_q5;
   integer        next_index_dma_wr_tx_descr_q6;
   integer        next_index_dma_wr_tx_descr_q7;
   integer        next_index_dma_wr_tx_descr_q8;
   integer        next_index_dma_wr_tx_descr_q9;
   integer        next_index_dma_wr_tx_descr_q10;
   integer        next_index_dma_wr_tx_descr_q11;
   integer        next_index_dma_wr_tx_descr_q12;
   integer        next_index_dma_wr_tx_descr_q13;
   integer        next_index_dma_wr_tx_descr_q14;
   integer        next_index_dma_wr_tx_descr_q15;

   integer        index_dma_wr_rx_data_q1;
   integer        index_dma_wr_rx_data_q2;
   integer        index_dma_wr_rx_data_q3;
   integer        index_dma_wr_rx_data_q4;
   integer        index_dma_wr_rx_data_q5;
   integer        index_dma_wr_rx_data_q6;
   integer        index_dma_wr_rx_data_q7;
   integer        index_dma_wr_rx_data_q8;
   integer        index_dma_wr_rx_data_q9;
   integer        index_dma_wr_rx_data_q10;
   integer        index_dma_wr_rx_data_q11;
   integer        index_dma_wr_rx_data_q12;
   integer        index_dma_wr_rx_data_q13;
   integer        index_dma_wr_rx_data_q14;
   integer        index_dma_wr_rx_data_q15;
   integer        next_index_dma_wr_rx_data_q1;
   integer        next_index_dma_wr_rx_data_q2;
   integer        next_index_dma_wr_rx_data_q3;
   integer        next_index_dma_wr_rx_data_q4;
   integer        next_index_dma_wr_rx_data_q5;
   integer        next_index_dma_wr_rx_data_q6;
   integer        next_index_dma_wr_rx_data_q7;
   integer        next_index_dma_wr_rx_data_q8;
   integer        next_index_dma_wr_rx_data_q9;
   integer        next_index_dma_wr_rx_data_q10;
   integer        next_index_dma_wr_rx_data_q11;
   integer        next_index_dma_wr_rx_data_q12;
   integer        next_index_dma_wr_rx_data_q13;
   integer        next_index_dma_wr_rx_data_q14;
   integer        next_index_dma_wr_rx_data_q15;

   integer        index_dma_wr_rx_descr_q1;
   integer        index_dma_wr_rx_descr_q2;
   integer        index_dma_wr_rx_descr_q3;
   integer        index_dma_wr_rx_descr_q4;
   integer        index_dma_wr_rx_descr_q5;
   integer        index_dma_wr_rx_descr_q6;
   integer        index_dma_wr_rx_descr_q7;
   integer        index_dma_wr_rx_descr_q8;
   integer        index_dma_wr_rx_descr_q9;
   integer        index_dma_wr_rx_descr_q10;
   integer        index_dma_wr_rx_descr_q11;
   integer        index_dma_wr_rx_descr_q12;
   integer        index_dma_wr_rx_descr_q13;
   integer        index_dma_wr_rx_descr_q14;
   integer        index_dma_wr_rx_descr_q15;
   integer        next_index_dma_wr_rx_descr_q1;
   integer        next_index_dma_wr_rx_descr_q2;
   integer        next_index_dma_wr_rx_descr_q3;
   integer        next_index_dma_wr_rx_descr_q4;
   integer        next_index_dma_wr_rx_descr_q5;
   integer        next_index_dma_wr_rx_descr_q6;
   integer        next_index_dma_wr_rx_descr_q7;
   integer        next_index_dma_wr_rx_descr_q8;
   integer        next_index_dma_wr_rx_descr_q9;
   integer        next_index_dma_wr_rx_descr_q10;
   integer        next_index_dma_wr_rx_descr_q11;
   integer        next_index_dma_wr_rx_descr_q12;
   integer        next_index_dma_wr_rx_descr_q13;
   integer        next_index_dma_wr_rx_descr_q14;
   integer        next_index_dma_wr_rx_descr_q15;

   wire    [63:0] next_tx_descr_write_add_q1;
   wire    [63:0] next_tx_descr_write_add_q2;
   wire    [63:0] next_tx_descr_write_add_q3;
   wire    [63:0] next_tx_descr_write_add_q4;
   wire    [63:0] next_tx_descr_write_add_q5;
   wire    [63:0] next_tx_descr_write_add_q6;
   wire    [63:0] next_tx_descr_write_add_q7;
   wire    [63:0] next_tx_descr_write_add_q8;
   wire    [63:0] next_tx_descr_write_add_q9;
   wire    [63:0] next_tx_descr_write_add_q10;
   wire    [63:0] next_tx_descr_write_add_q11;
   wire    [63:0] next_tx_descr_write_add_q12;
   wire    [63:0] next_tx_descr_write_add_q13;
   wire    [63:0] next_tx_descr_write_add_q14;
   wire    [63:0] next_tx_descr_write_add_q15;
   wire    [63:0] next_rx_descr_write_add_q1;
   wire    [63:0] next_rx_descr_write_add_q2;
   wire    [63:0] next_rx_descr_write_add_q3;
   wire    [63:0] next_rx_descr_write_add_q4;
   wire    [63:0] next_rx_descr_write_add_q5;
   wire    [63:0] next_rx_descr_write_add_q6;
   wire    [63:0] next_rx_descr_write_add_q7;
   wire    [63:0] next_rx_descr_write_add_q8;
   wire    [63:0] next_rx_descr_write_add_q9;
   wire    [63:0] next_rx_descr_write_add_q10;
   wire    [63:0] next_rx_descr_write_add_q11;
   wire    [63:0] next_rx_descr_write_add_q12;
   wire    [63:0] next_rx_descr_write_add_q13;
   wire    [63:0] next_rx_descr_write_add_q14;
   wire    [63:0] next_rx_descr_write_add_q15;
   wire    [63:0] next_rx_data_write_add_q1;
   wire    [63:0] next_rx_data_write_add_q2;
   wire    [63:0] next_rx_data_write_add_q3;
   wire    [63:0] next_rx_data_write_add_q4;
   wire    [63:0] next_rx_data_write_add_q5;
   wire    [63:0] next_rx_data_write_add_q6;
   wire    [63:0] next_rx_data_write_add_q7;
   wire    [63:0] next_rx_data_write_add_q8;
   wire    [63:0] next_rx_data_write_add_q9;
   wire    [63:0] next_rx_data_write_add_q10;
   wire    [63:0] next_rx_data_write_add_q11;
   wire    [63:0] next_rx_data_write_add_q12;
   wire    [63:0] next_rx_data_write_add_q13;
   wire    [63:0] next_rx_data_write_add_q14;
   wire    [63:0] next_rx_data_write_add_q15;

  `endif
   reg            tx_rewind_index_en;

   reg [3:0]      tx_current_queue_descr_resp;
   wire           bf_auto_complete_descrd;
   reg            alt_cycle_32bit_aph;
   reg            alt_cycle_32bit_dph;
   wire           armaster_aph;
   wire           axi_no_wr_rd_depend;
   reg            data_fail;           // write data compare failed
   reg            address_fail;        // address compare failed
   reg            width_fail_reg;      // not a valid width/address combination
   wire           width_fail;          // not a valid width/address combination
   reg            rlast;
   reg  [127:0]   rdata_tmp;
   reg  [127:0]   rdata;
   wire [63:0]    araddr_data_cmp,awaddr_data_cmp;
   reg  [127:0]   data_written_end_swapped;
   reg  [15:0]    write_en_end_swapped;
   reg  [127:0]   write_en_end_swapped_pad;
   wire           ignore_data_rd_add_mismatch_tx;
   wire           ignore_descr_rd_add_mismatch_tx;
   wire           ignore_descr_rd_add_mismatch_rx;
   wire           ignore_rd_add_mismatch;
   reg [63:0]     nxt_ignored_add_descr_tx [15:0];
   reg [63:0]     nxt_ignored_add_descr_rx [15:0];
   reg [63:0]     nxt_ignored_add_data_tx;
   wire           r_is_descr;
   wire           r_is_tx;
   wire [3:0]     current_rx_queue_resp;
   wire arready_tmp,awready_tmp,wready_tmp,rvalid_tmp,rlast_tmp,bvalid_tmp;
   wire [1:0]     bresp_tmp;
   reg  [1:0]     bresp;
   reg            repeating;



  wire          gem_dma_addr_w_is_64;
  assign gem_dma_addr_w_is_64 = ((`edma_addr_width == 64) & apb_64b_addr_mode_en);  // if 'define and reg enabled


// -----------------------------------------------------------------------------
// Parameters declaration
// -----------------------------------------------------------------------------
  // TX STATES
   parameter
      DMA_IDLE     = 3'b000, // idle state, reset and flush fifo
      DMA_MANRD    = 3'b001, // read descriptor for frame one
      DMA_PKTDATA  = 3'b010, // Pkt data read from AHB
      DMA_PKTINFO  = 3'b100, // Pkt status and TCP offload checksum updates
      DMA_MANWR    = 3'b011; // writeback descriptor for frame one

   // RX STATES
   parameter
      RX_DMA_IDLE          = 3'b000,    // RX disabled
      RX_DMA_WAIT_STATUS   = 3'b001,    // wait for rx_buffer_required
      RX_DMA_MAN_RD        = 3'b010,    // Management read
      RX_DMA_DATA_STORE    = 3'b011,    // Data store
      RX_DMA_MAN_WR        = 3'b100;    // Management write

  parameter top_queue = `edma_queues-1;

    reg apb_endian_val_hs;
    reg apb_endian_val_hs_done;

   always @(negedge reset_tb or posedge apb_endian_wr or posedge apb_endian_val_hs_done)
    if (~reset_tb)
      apb_endian_val_hs = 0;
    else if (apb_endian_val_hs_done)
      apb_endian_val_hs = 0;
    else
      apb_endian_val_hs = 1;

   always @(negedge reset_tb or negedge hclk)
      if (~reset_tb)
         begin
            apb_endian_val_hs_done = 0;
            endian_value <= `edma_endian_swap_def;
         end
      else if (apb_endian_val_hs)
         begin
            apb_endian_val_hs_done = 1;
            endian_value <= apb_endian_val[1:0];
         end
      else
            apb_endian_val_hs_done = 0;



// -----------------------------------------------------------------------------
// Decode access size and alignment
// -----------------------------------------------------------------------------

   // decode required access width
  always @(*)
  begin
    if (awsize[2:0] == 3'b010)
      aw_access_width = 2'b00;  // 32 bit access
    else if (awsize[2:0] == 3'b011)
      aw_access_width = 2'b01;  // 64 bit access
    else
      aw_access_width = 2'b11;  // 128 bit access
  end
  always @(*)
  begin
    if (arsize[2:0] == 3'b010)
      ar_access_width = 2'b00;  // 32 bit access
    else if (arsize[2:0] == 3'b011)
      ar_access_width = 2'b01;  // 64 bit access
    else
      ar_access_width = 2'b11;  // 128 bit access
  end

 assign width_fail = (awvalid &
                      ((awsize[2:1] == 2'b00)  | // no support for 8 or 16 bit accesses
                       (awsize[2:0] == 3'b011 & dma_bus_width == 2'b00) | // error if in 32 bit mode and access is 64 bits
                       (awsize[2] & ~dma_bus_width[1]) | // error if in 32/64 bit mode and access is >64 bits
                       (awsize[2] & |awsize[1:0] & dma_bus_width[1]))) // error if in 32/64 bit mode and access is >64 bits
                      |
                     (arvalid &
                      ((arsize[2:1] == 2'b00)  |
                       (arsize[2:0] == 3'b011 & dma_bus_width == 2'b00) | // error if in 32 bit mode and access is 64 bits
                       (arsize[2] & ~dma_bus_width[1]) | // error if in 32/64 bit mode and access is >64 bits
                       (arsize[2] & |arsize[1:0] & dma_bus_width[1]))) ; // error if in 32/64 bit mode and access is >64 bits


  // generate some useful signals
  assign valid_aw_access = (awvalid & awready_tmp);
  assign valid_ar_access = (arvalid & arready_tmp);
  assign valid_dw_access = (wvalid & wready_tmp);
  assign valid_dr_access = (rvalid_tmp & rready);
  assign last_dw_access  = (valid_dw_access & wlast);
  assign last_dr_access  = (valid_dr_access & rlast_tmp);

  // In AXI, we may have multiple addresses before the data is returned.
  // we call this overlapping transfers.
  //
  // Since we need to know the address information at the time the data
  // is driven (for writes) or sampled (for reads) then we'll buffer this
  // information up now.


  reg [(20 + `edma_addr_width):0]  aw_buffer [2**tb_axi_pipeline_depth-1:0];
  reg [3:0]  w_buffer [2**tb_axi_pipeline_depth-1:0];
  reg [(20 + `edma_addr_width):0]  ar_buffer [2**tb_axi_pipeline_depth-1:0];
  reg         aw_buffer_empty,ar_buffer_empty,w_buffer_empty;
  reg         aw_buffer_full,ar_buffer_full,w_buffer_full;
  reg [tb_axi_pipeline_depth-1:0]   aw_buffer_wptr,aw_buffer_rptr;
  reg [tb_axi_pipeline_depth-1:0]   w_buffer_wptr,w_buffer_rptr;
  reg [tb_axi_pipeline_depth-1:0]   ar_buffer_wptr,ar_buffer_rptr;
  reg [(20+`edma_addr_width):0] aw_info_wdata,ar_info_rdata;

  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      aw_buffer_empty <= 1'b1;
      aw_buffer_full <= 1'b0;
      aw_buffer_wptr  <= 0;
      aw_buffer_rptr  <= 0;
      w_buffer_empty  <= 0;
      w_buffer_wptr  <= 0;
      w_buffer_rptr  <= 0;
      ar_buffer_empty <= 1'b1;
      ar_buffer_full <= 1'b0;
      ar_buffer_wptr  <= 0;
      ar_buffer_rptr  <= 0;
      fail_1          <= 1'b0;
    end
    else
    begin
      if (last_dw_access)
        aw_buffer_rptr   <= aw_buffer_rptr + 1;

      if (valid_aw_access)
      begin
        aw_buffer[aw_buffer_wptr]  <= {awqos,awid,awaddr,awlen,awsize,awburst};
        aw_buffer_empty <= 1'b0;
        aw_buffer_full <= aw_buffer_rptr == ((aw_buffer_wptr + 1)%(2**tb_axi_pipeline_depth)) & ~last_dw_access;
        aw_buffer_wptr  <= aw_buffer_wptr + 1;
      end
      else if (last_dw_access)
      begin
        aw_buffer_empty <= aw_buffer_wptr == ((aw_buffer_rptr + 1)%(2**tb_axi_pipeline_depth));
        aw_buffer_full <= 1'b0;
      end

      if (last_dw_access)
      begin
        w_buffer[w_buffer_wptr]  <= aw_info_wdata[(16 + `edma_addr_width):(13 + `edma_addr_width)];
        w_buffer_wptr  <= w_buffer_wptr + 1;
      end

      if (bvalid)
        w_buffer_rptr  <= w_buffer_rptr + 1;

      if (last_dr_access)
        ar_buffer_rptr   <= ar_buffer_rptr + 1;

      if (valid_ar_access)
      begin
        ar_buffer[ar_buffer_wptr]  <= {arqos,arid,araddr,arlen,arsize,arburst};
        ar_buffer_empty <= 1'b0;
        ar_buffer_full <= ar_buffer_rptr == ((ar_buffer_wptr + 1)%(2**tb_axi_pipeline_depth)) & ~last_dr_access;
        ar_buffer_wptr  <= ar_buffer_wptr + 1;
      end
      else if (last_dr_access)
      begin
        ar_buffer_empty <= ar_buffer_wptr == ((ar_buffer_rptr + 1)%(2**tb_axi_pipeline_depth));
        ar_buffer_full <= 1'b0;
      end

      // check there is no data before address ...
      if (aw_buffer_empty & valid_dw_access)
      begin
        $display("**** DMA ERROR : Write Data was detected before any address information at %0dns",$time);
        fail_1 <= 1'b1;
      end
      // check there is no data before address ...
      if (ar_buffer_empty & valid_dr_access)
      begin
        $display("**** DMA ERROR : Read Data was detected before any address information at %0dns",$time);
        fail_1 <= 1'b1;
      end

    end
  end

  // the following signals hold the address information associated with the burst
  // but in the data.  We can use this information to map the data with the address
  // that it is associated with.
  always @(*)
  begin
    aw_info_wdata = aw_buffer[aw_buffer_rptr];
    ar_info_rdata = ar_buffer[ar_buffer_rptr];
  end

  wire [`edma_addr_width-1:0] awaddr_data,araddr_data;
  wire [7:0]  awlen_data,arlen_data;
  wire [2:0]  awsize_data,arsize_data;
  wire [1:0]  awburst_data,arburst_data;
  wire [3:0]  awid_data,arid_data;
  wire [3:0]  awqos_data,arqos_data;
  assign awqos_data   = aw_info_wdata[(20+`edma_addr_width):(17+`edma_addr_width)];
  assign awid_data    = aw_info_wdata[(16+`edma_addr_width):(13+`edma_addr_width)];
  assign awaddr_data  = aw_info_wdata[(12+`edma_addr_width):13];
  assign awlen_data   = aw_info_wdata[12:5];
  assign awsize_data  = aw_info_wdata[4:2];
  assign awburst_data = aw_info_wdata[1:0];
  assign arqos_data   = ar_info_rdata[(20+`edma_addr_width):(17+`edma_addr_width)];
  assign arid_data    = ar_info_rdata[(16+`edma_addr_width):(13+`edma_addr_width)];
  assign araddr_data  = ar_info_rdata[(12+`edma_addr_width):13];
  assign arlen_data   = ar_info_rdata[12:5];
  assign arsize_data  = ar_info_rdata[4:2];
  assign arburst_data = ar_info_rdata[1:0];

  wire  [3:0] rid_tmp,bid_tmp;
  reg  [3:0] rid,bid;
  assign rid_tmp = ar_buffer_empty ? 4'h0 : arid_data;
  assign bid_tmp = w_buffer_empty ? 4'h0 : w_buffer[w_buffer_rptr];

  // Determine where each data entry is in the current burst
  reg   [7:0] w_burst_ptr;
  reg   [7:0] r_burst_ptr;
  reg         waddr_at_1k_bound;
  reg         raddr_at_1k_bound;
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      w_burst_ptr <= 8'h0;
      r_burst_ptr <= 8'h0;
      fail_2      <= 1'b0;
    end
    else
    begin
      // check bursts > 1 access are always incrementing, and fixed bursts used for single accesses only
      if ((awlen > 8'h0 & awburst != 2'b01) | (arlen > 8'h0 & arburst != 2'b01))
      begin
        $display("**** DMA ERROR : Detected a burst that was not Incrementing-address at %0dns",$time);
        fail_2 <= 1'b1;
      end
      if ((awlen == 8'h0 & awburst == 2'b00) | (arlen == 8'h0 & arburst == 2'b00))
      begin
        $display("**** DMA WARNING : Detected a single access when burst type was set to FIXED at %0dns",$time);
      end
      if (awburst[1] | arburst[1])
      begin
        $display("**** DMA ERROR : Detected a wrapping burst which is illegal for GEM at %0dns",$time);
        fail_2 <= 1'b1;
      end

      if (last_dw_access & (w_burst_ptr != awlen_data))
      begin
        $display("**** DMA ERROR : Finished the write burst too early at %0dns",$time);
        fail_2 <= 1'b1;
      end
      if (last_dr_access & (r_burst_ptr != arlen_data))
      begin
        $display("**** DMA ERROR : Finished the read burst too early at %0dns",$time);
        fail_2 <= 1'b1;
      end
      if (valid_dw_access & (w_burst_ptr > awlen_data))
      begin
        $display("**** DMA ERROR : Write burst going on longer than expected at %0dns",$time);
        fail_2 <= 1'b1;
      end
      if (valid_dr_access & (r_burst_ptr > arlen_data))
      begin
        $display("**** DMA ERROR : Read burst going on longer than expected at %0dns",$time);
        fail_2 <= 1'b1;
      end

      // Check if the burst goes over 1k boundaries ...
      if ((valid_dw_access & waddr_at_1k_bound & ~last_dw_access) |
          (valid_dr_access & raddr_at_1k_bound & ~last_dr_access))
      begin
        $display("**** DMA ERROR : 1K boundary bursted over at %0dns",$time);
        fail_2 <= 1'b1;
      end


      if (last_dw_access)
        w_burst_ptr <= 8'b0;
      else if (valid_dw_access)
        w_burst_ptr <= w_burst_ptr + 8'b1;

      if (last_dr_access)
        r_burst_ptr <= 8'b0;
      else if (valid_dr_access)
        r_burst_ptr <= r_burst_ptr + 8'b1;

    end
  end
  assign rlast_tmp = r_burst_ptr == arlen_data & ~ar_buffer_empty;

  always @(*)
  begin
    case (dma_bus_width)
      2'b00   : waddr_at_1k_bound = &(awaddr_data[22:15] + w_burst_ptr[7:0]*4) & awlen_data != 8'h00;
      2'b01   : waddr_at_1k_bound = &(awaddr_data[22:16] + w_burst_ptr[6:0]*8) & awlen_data != 8'h00;
      default : waddr_at_1k_bound = &(awaddr_data[22:17] + w_burst_ptr[5:0]*16) & awlen_data != 8'h00;
    endcase
    case (dma_bus_width)
      2'b00   : raddr_at_1k_bound = &(araddr_data[22:15] + r_burst_ptr[7:0]*4) & arlen_data != 8'h00;
      2'b01   : raddr_at_1k_bound = &(araddr_data[22:16] + r_burst_ptr[6:0]*8) & arlen_data != 8'h00;
      default : raddr_at_1k_bound = &(araddr_data[22:17] + r_burst_ptr[5:0]*16) & arlen_data != 8'h00;
    endcase
  end


//

// -----------------------------------------------------------------------------
// initialise arrays for holding test file data & decode from selected word
// -----------------------------------------------------------------------------

   // read dma read data
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q0.data",dma_rd_vector_reg);
         if (dma_rd_vector_reg[1] === 99'hx)
            $display("\n No dma read data file read \n");
      end

   // read dma read data Q1
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q1_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q1.data",dma_rd_q1_vector_reg);
         if (dma_rd_q1_vector_reg[1] === 99'hx)
            $display("\n No dma_q1 read data file read \n");
      end

   // read dma read data q2
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q2_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q2.data",dma_rd_q2_vector_reg);
         if (dma_rd_q2_vector_reg[1] === 99'hx)
            $display("\n No dma_q2 read data file read \n");
      end

   // read dma read data q3
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q3_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q3.data",dma_rd_q3_vector_reg);
         if (dma_rd_q3_vector_reg[1] === 99'hx)
            $display("\n No dma_q3 read data file read \n");
      end

   // read dma read data q4
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q4_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q4.data",dma_rd_q4_vector_reg);
         if (dma_rd_q4_vector_reg[1] === 99'hx)
            $display("\n No dma_q4 read data file read \n");
      end

   // read dma read data q5
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q5_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q5.data",dma_rd_q5_vector_reg);
         if (dma_rd_q5_vector_reg[1] === 99'hx)
            $display("\n No dma_q5 read data file read \n");
      end

   // read dma read data q6
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q6_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q6.data",dma_rd_q6_vector_reg);
         if (dma_rd_q6_vector_reg[1] === 99'hx)
            $display("\n No dma_q6 read data file read \n");
      end

   // read dma read data Q7
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q7_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q7.data",dma_rd_q7_vector_reg);
         if (dma_rd_q7_vector_reg[1] === 99'hx)
            $display("\n No dma_q7 read data file read \n");
      end

   // read dma read data Q8
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q8_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q8.data",dma_rd_q8_vector_reg);
         if (dma_rd_q8_vector_reg[1] === 99'hx)
            $display("\n No dma_q8 read data file read \n");
      end

   // read dma read data Q9
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q9_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q9.data",dma_rd_q9_vector_reg);
         if (dma_rd_q9_vector_reg[1] === 99'hx)
            $display("\n No dma_q9 read data file read \n");
      end

   // read dma read data Q10
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q10_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q10.data",dma_rd_q10_vector_reg);
         if (dma_rd_q10_vector_reg[1] === 99'hx)
            $display("\n No dma_q10 read data file read \n");
      end

   // read dma read data Q11
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q11_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q11.data",dma_rd_q11_vector_reg);
         if (dma_rd_q11_vector_reg[1] === 99'hx)
            $display("\n No dma_q11 read data file read \n");
      end

   // read dma read data Q12
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q12_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q12.data",dma_rd_q12_vector_reg);
         if (dma_rd_q12_vector_reg[1] === 99'hx)
            $display("\n No dma_q12 read data file read \n");
      end

   // read dma read data Q13
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q13_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q13.data",dma_rd_q13_vector_reg);
         if (dma_rd_q13_vector_reg[1] === 99'hx)
            $display("\n No dma_q13 read data file read \n");
      end

   // read dma read data Q14
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q14_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q14.data",dma_rd_q14_vector_reg);
         if (dma_rd_q14_vector_reg[1] === 99'hx)
            $display("\n No dma_q14 read data file read \n");
      end

   // read dma read data Q15
   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_q15_vector_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_rx_descr_q15.data",dma_rd_q15_vector_reg);
         if (dma_rd_q15_vector_reg[1] === 99'hx)
            $display("\n No dma_q15 read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q0_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q0.data",dma_rd_vector_tx_data_q0_reg);
         if (dma_rd_vector_tx_data_q0_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q1_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q1.data",dma_rd_vector_tx_data_q1_reg);
         if (dma_rd_vector_tx_data_q1_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q2_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q2.data",dma_rd_vector_tx_data_q2_reg);
         if (dma_rd_vector_tx_data_q2_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q3_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q3.data",dma_rd_vector_tx_data_q3_reg);
         if (dma_rd_vector_tx_data_q3_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q4_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q4.data",dma_rd_vector_tx_data_q4_reg);
         if (dma_rd_vector_tx_data_q4_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q5_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q5.data",dma_rd_vector_tx_data_q5_reg);
         if (dma_rd_vector_tx_data_q5_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q6_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q6.data",dma_rd_vector_tx_data_q6_reg);
         if (dma_rd_vector_tx_data_q6_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q7_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q7.data",dma_rd_vector_tx_data_q7_reg);
         if (dma_rd_vector_tx_data_q7_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q8_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q8.data",dma_rd_vector_tx_data_q8_reg);
         if (dma_rd_vector_tx_data_q8_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q9_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q9.data",dma_rd_vector_tx_data_q9_reg);
         if (dma_rd_vector_tx_data_q9_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q10_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q10.data",dma_rd_vector_tx_data_q10_reg);
         if (dma_rd_vector_tx_data_q10_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q11_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q11.data",dma_rd_vector_tx_data_q11_reg);
         if (dma_rd_vector_tx_data_q11_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q12_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q12.data",dma_rd_vector_tx_data_q12_reg);
         if (dma_rd_vector_tx_data_q12_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q13_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q13.data",dma_rd_vector_tx_data_q13_reg);
         if (dma_rd_vector_tx_data_q13_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q14_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q14.data",dma_rd_vector_tx_data_q14_reg);
         if (dma_rd_vector_tx_data_q14_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_data_q15_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_data_q15.data",dma_rd_vector_tx_data_q15_reg);
         if (dma_rd_vector_tx_data_q15_reg[1] === 99'hx)
            $display("\n No alternative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q0.data",dma_rd_vector_tx_descr_reg);
         if (dma_rd_vector_tx_descr_reg[1] === 99'hx)
            $display("\n No tx_descrernative dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q1_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q1.data",dma_rd_vector_tx_descr_q1_reg);
         if (dma_rd_vector_tx_descr_q1_reg[1] === 99'hx)
            $display("\n No tx_descr q1 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q2_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q2.data",dma_rd_vector_tx_descr_q2_reg);
         if (dma_rd_vector_tx_descr_q2_reg[1] === 99'hx)
            $display("\n No tx_descr q2 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q3_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q3.data",dma_rd_vector_tx_descr_q3_reg);
         if (dma_rd_vector_tx_descr_q3_reg[1] === 99'hx)
            $display("\n No tx_descr q3 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q4_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q4.data",dma_rd_vector_tx_descr_q4_reg);
         if (dma_rd_vector_tx_descr_q4_reg[1] === 99'hx)
            $display("\n No tx_descr q4 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q5_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q5.data",dma_rd_vector_tx_descr_q5_reg);
         if (dma_rd_vector_tx_descr_q5_reg[1] === 99'hx)
            $display("\n No tx_descr q5 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q6_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q6.data",dma_rd_vector_tx_descr_q6_reg);
         if (dma_rd_vector_tx_descr_q6_reg[1] === 99'hx)
            $display("\n No tx_descr q6 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q7_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q7.data",dma_rd_vector_tx_descr_q7_reg);
         if (dma_rd_vector_tx_descr_q7_reg[1] === 99'hx)
            $display("\n No tx_descr q7 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q8_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q8.data",dma_rd_vector_tx_descr_q8_reg);
         if (dma_rd_vector_tx_descr_q8_reg[1] === 99'hx)
            $display("\n No tx_descr q8 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q9_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q9.data",dma_rd_vector_tx_descr_q9_reg);
         if (dma_rd_vector_tx_descr_q9_reg[1] === 99'hx)
            $display("\n No tx_descr q9 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q10_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q10.data",dma_rd_vector_tx_descr_q10_reg);
         if (dma_rd_vector_tx_descr_q10_reg[1] === 99'hx)
            $display("\n No tx_descr q10 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q11_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q11.data",dma_rd_vector_tx_descr_q11_reg);
         if (dma_rd_vector_tx_descr_q11_reg[1] === 99'hx)
            $display("\n No tx_descr q11 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q12_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q12.data",dma_rd_vector_tx_descr_q12_reg);
         if (dma_rd_vector_tx_descr_q12_reg[1] === 99'hx)
            $display("\n No tx_descr q12 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q13_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q13.data",dma_rd_vector_tx_descr_q13_reg);
         if (dma_rd_vector_tx_descr_q13_reg[1] === 99'hx)
            $display("\n No tx_descr q13 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q14_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q14.data",dma_rd_vector_tx_descr_q14_reg);
         if (dma_rd_vector_tx_descr_q14_reg[1] === 99'hx)
            $display("\n No tx_descr q14 dma read data file read \n");
      end

   initial
      begin
         for (j=1; j<=(819*`edma_tx_pbuf_addr); j=j+1)
            dma_rd_vector_tx_descr_q15_reg[j] = 99'b0;

         $readmemh("./files/tb_dma_rd_tx_descr_q15.data",dma_rd_vector_tx_descr_q15_reg);
         if (dma_rd_vector_tx_descr_q15_reg[1] === 99'hx)
            $display("\n No tx_descr q15 dma read data file read \n");
      end

   assign dma_rd_vector_nxt_orig     = dma_rd_vector_reg[next_dma_rd_index];
   assign dma_rd_vector_nxt_q1       = dma_rd_q1_vector_reg[next_dma_rd_q1_index];
   assign dma_rd_vector_nxt_q2       = dma_rd_q2_vector_reg[next_dma_rd_q2_index];
   assign dma_rd_vector_nxt_q3       = dma_rd_q3_vector_reg[next_dma_rd_q3_index];
   assign dma_rd_vector_nxt_q4       = dma_rd_q4_vector_reg[next_dma_rd_q4_index];
   assign dma_rd_vector_nxt_q5       = dma_rd_q5_vector_reg[next_dma_rd_q5_index];
   assign dma_rd_vector_nxt_q6       = dma_rd_q6_vector_reg[next_dma_rd_q6_index];
   assign dma_rd_vector_nxt_q7       = dma_rd_q7_vector_reg[next_dma_rd_q7_index];
   assign dma_rd_vector_nxt_q8       = dma_rd_q8_vector_reg[next_dma_rd_q8_index];
   assign dma_rd_vector_nxt_q9       = dma_rd_q9_vector_reg[next_dma_rd_q9_index];
   assign dma_rd_vector_nxt_q10       = dma_rd_q10_vector_reg[next_dma_rd_q10_index];
   assign dma_rd_vector_nxt_q11       = dma_rd_q11_vector_reg[next_dma_rd_q11_index];
   assign dma_rd_vector_nxt_q12       = dma_rd_q12_vector_reg[next_dma_rd_q12_index];
   assign dma_rd_vector_nxt_q13       = dma_rd_q13_vector_reg[next_dma_rd_q13_index];
   assign dma_rd_vector_nxt_q14       = dma_rd_q14_vector_reg[next_dma_rd_q14_index];
   assign dma_rd_vector_nxt_q15       = dma_rd_q15_vector_reg[next_dma_rd_q15_index];
   assign dma_rd_vector_nxt_tx_data_q0  = dma_rd_vector_tx_data_q0_reg[tx_data_q0_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q1  = dma_rd_vector_tx_data_q1_reg[tx_data_q1_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q2  = dma_rd_vector_tx_data_q2_reg[tx_data_q2_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q3  = dma_rd_vector_tx_data_q3_reg[tx_data_q3_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q4  = dma_rd_vector_tx_data_q4_reg[tx_data_q4_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q5  = dma_rd_vector_tx_data_q5_reg[tx_data_q5_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q6  = dma_rd_vector_tx_data_q6_reg[tx_data_q6_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q7  = dma_rd_vector_tx_data_q7_reg[tx_data_q7_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q8  = dma_rd_vector_tx_data_q8_reg[tx_data_q8_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q9  = dma_rd_vector_tx_data_q9_reg[tx_data_q9_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q10 = dma_rd_vector_tx_data_q10_reg[tx_data_q10_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q11 = dma_rd_vector_tx_data_q11_reg[tx_data_q11_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q12 = dma_rd_vector_tx_data_q12_reg[tx_data_q12_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q13 = dma_rd_vector_tx_data_q13_reg[tx_data_q13_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q14 = dma_rd_vector_tx_data_q14_reg[tx_data_q14_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_data_q15 = dma_rd_vector_tx_data_q15_reg[tx_data_q15_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr    = dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q1 = dma_rd_vector_tx_descr_q1_reg[tx_descr_q1_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q2 = dma_rd_vector_tx_descr_q2_reg[tx_descr_q2_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q3 = dma_rd_vector_tx_descr_q3_reg[tx_descr_q3_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q4 = dma_rd_vector_tx_descr_q4_reg[tx_descr_q4_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q5 = dma_rd_vector_tx_descr_q5_reg[tx_descr_q5_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q6 = dma_rd_vector_tx_descr_q6_reg[tx_descr_q6_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q7 = dma_rd_vector_tx_descr_q7_reg[tx_descr_q7_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q8 = dma_rd_vector_tx_descr_q8_reg[tx_descr_q8_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q9 = dma_rd_vector_tx_descr_q9_reg[tx_descr_q9_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q10 = dma_rd_vector_tx_descr_q10_reg[tx_descr_q10_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q11 = dma_rd_vector_tx_descr_q11_reg[tx_descr_q11_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q12 = dma_rd_vector_tx_descr_q12_reg[tx_descr_q12_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q13 = dma_rd_vector_tx_descr_q13_reg[tx_descr_q13_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q14 = dma_rd_vector_tx_descr_q14_reg[tx_descr_q14_next_dma_rd_index];
   assign dma_rd_vector_nxt_tx_descr_q15 = dma_rd_vector_tx_descr_q15_reg[tx_descr_q15_next_dma_rd_index];

   assign next_read_add_orig  = dma_rd_vector_nxt_orig[95:32];
   assign next_read_add_q1    = dma_rd_vector_nxt_q1[95:32];
   assign next_read_add_q2    = dma_rd_vector_nxt_q2[95:32];
   assign next_read_add_q3    = dma_rd_vector_nxt_q3[95:32];
   assign next_read_add_q4    = dma_rd_vector_nxt_q4[95:32];
   assign next_read_add_q5    = dma_rd_vector_nxt_q5[95:32];
   assign next_read_add_q6    = dma_rd_vector_nxt_q6[95:32];
   assign next_read_add_q7    = dma_rd_vector_nxt_q7[95:32];
   assign next_read_add_q8    = dma_rd_vector_nxt_q8[95:32];
   assign next_read_add_q9    = dma_rd_vector_nxt_q9[95:32];
   assign next_read_add_q10    = dma_rd_vector_nxt_q10[95:32];
   assign next_read_add_q11    = dma_rd_vector_nxt_q11[95:32];
   assign next_read_add_q12    = dma_rd_vector_nxt_q12[95:32];
   assign next_read_add_q13    = dma_rd_vector_nxt_q13[95:32];
   assign next_read_add_q14    = dma_rd_vector_nxt_q14[95:32];
   assign next_read_add_q15    = dma_rd_vector_nxt_q15[95:32];
   assign next_read_add_tx_data_q0   = dma_rd_vector_nxt_tx_data_q0 [95:32];
   assign next_read_add_tx_data_q1   = dma_rd_vector_nxt_tx_data_q1 [95:32];
   assign next_read_add_tx_data_q2   = dma_rd_vector_nxt_tx_data_q2 [95:32];
   assign next_read_add_tx_data_q3   = dma_rd_vector_nxt_tx_data_q3 [95:32];
   assign next_read_add_tx_data_q4   = dma_rd_vector_nxt_tx_data_q4 [95:32];
   assign next_read_add_tx_data_q5   = dma_rd_vector_nxt_tx_data_q5 [95:32];
   assign next_read_add_tx_data_q6   = dma_rd_vector_nxt_tx_data_q6 [95:32];
   assign next_read_add_tx_data_q7   = dma_rd_vector_nxt_tx_data_q7 [95:32];
   assign next_read_add_tx_data_q8   = dma_rd_vector_nxt_tx_data_q8 [95:32];
   assign next_read_add_tx_data_q9   = dma_rd_vector_nxt_tx_data_q9 [95:32];
   assign next_read_add_tx_data_q10  = dma_rd_vector_nxt_tx_data_q10[95:32];
   assign next_read_add_tx_data_q11  = dma_rd_vector_nxt_tx_data_q11[95:32];
   assign next_read_add_tx_data_q12  = dma_rd_vector_nxt_tx_data_q12[95:32];
   assign next_read_add_tx_data_q13  = dma_rd_vector_nxt_tx_data_q13[95:32];
   assign next_read_add_tx_data_q14  = dma_rd_vector_nxt_tx_data_q14[95:32];
   assign next_read_add_tx_data_q15  = dma_rd_vector_nxt_tx_data_q15[95:32];
   assign next_read_add_tx_descr       = dma_rd_vector_nxt_tx_descr [95:32];
   assign next_read_add_tx_descr_q1    = dma_rd_vector_nxt_tx_descr_q1  [95:32];
   assign next_read_add_tx_descr_q2    = dma_rd_vector_nxt_tx_descr_q2  [95:32];
   assign next_read_add_tx_descr_q3    = dma_rd_vector_nxt_tx_descr_q3  [95:32];
   assign next_read_add_tx_descr_q4    = dma_rd_vector_nxt_tx_descr_q4  [95:32];
   assign next_read_add_tx_descr_q5    = dma_rd_vector_nxt_tx_descr_q5  [95:32];
   assign next_read_add_tx_descr_q6    = dma_rd_vector_nxt_tx_descr_q6  [95:32];
   assign next_read_add_tx_descr_q7    = dma_rd_vector_nxt_tx_descr_q7  [95:32];
   assign next_read_add_tx_descr_q8    = dma_rd_vector_nxt_tx_descr_q8  [95:32];
   assign next_read_add_tx_descr_q9    = dma_rd_vector_nxt_tx_descr_q9  [95:32];
   assign next_read_add_tx_descr_q10   = dma_rd_vector_nxt_tx_descr_q10 [95:32];
   assign next_read_add_tx_descr_q11   = dma_rd_vector_nxt_tx_descr_q11 [95:32];
   assign next_read_add_tx_descr_q12   = dma_rd_vector_nxt_tx_descr_q12 [95:32];
   assign next_read_add_tx_descr_q13   = dma_rd_vector_nxt_tx_descr_q13 [95:32];
   assign next_read_add_tx_descr_q14   = dma_rd_vector_nxt_tx_descr_q14 [95:32];
   assign next_read_add_tx_descr_q15   = dma_rd_vector_nxt_tx_descr_q15 [95:32];

   assign using_orig        = (valid_dr_access) ? (araddr_data_cmp == next_read_add_orig)  : using_orig; // Latch between accesses
   assign using_q1          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q1)    : using_q1; // Latch between accesses
   assign using_q2          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q2)    : using_q2; // Latch between accesses
   assign using_q3          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q3)    : using_q3; // Latch between accesses
   assign using_q4          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q4)    : using_q4; // Latch between accesses
   assign using_q5          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q5)    : using_q5; // Latch between accesses
   assign using_q6          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q6)    : using_q6; // Latch between accesses
   assign using_q7          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q7)    : using_q7; // Latch between accesses
   assign using_q8          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q8)    : using_q8; // Latch between accesses
   assign using_q9          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q9)    : using_q9; // Latch between accesses
   assign using_q10          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q10)    : using_q10; // Latch between accesses
   assign using_q11          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q11)    : using_q11; // Latch between accesses
   assign using_q12          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q12)    : using_q12; // Latch between accesses
   assign using_q13          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q13)    : using_q13; // Latch between accesses
   assign using_q14          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q14)    : using_q14; // Latch between accesses
   assign using_q15          = (valid_dr_access) ? (araddr_data_cmp == next_read_add_q15)    : using_q15; // Latch between accesses
   assign using_tx_data_q0    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q0 ) : using_tx_data_q0 ;
   assign using_tx_data_q1    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q1 ) : using_tx_data_q1 ;
   assign using_tx_data_q2    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q2 ) : using_tx_data_q2 ;
   assign using_tx_data_q3    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q3 ) : using_tx_data_q3 ;
   assign using_tx_data_q4    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q4 ) : using_tx_data_q4 ;
   assign using_tx_data_q5    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q5 ) : using_tx_data_q5 ;
   assign using_tx_data_q6    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q6 ) : using_tx_data_q6 ;
   assign using_tx_data_q7    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q7 ) : using_tx_data_q7 ;
   assign using_tx_data_q8    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q8 ) : using_tx_data_q8 ;
   assign using_tx_data_q9    = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q9 ) : using_tx_data_q9 ;
   assign using_tx_data_q10   = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q10) : using_tx_data_q10;
   assign using_tx_data_q11   = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q11) : using_tx_data_q11;
   assign using_tx_data_q12   = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q12) : using_tx_data_q12;
   assign using_tx_data_q13   = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q13) : using_tx_data_q13;
   assign using_tx_data_q14   = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q14) : using_tx_data_q14;
   assign using_tx_data_q15   = (valid_dr_access) ? (~using_orig & araddr_data_cmp == next_read_add_tx_data_q15) : using_tx_data_q15;
   assign using_tx_descr       = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr) : using_tx_descr;
   assign using_tx_descr_q1    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q1) : using_tx_descr_q1;
   assign using_tx_descr_q2    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q2) : using_tx_descr_q2;
   assign using_tx_descr_q3    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q3) : using_tx_descr_q3;
   assign using_tx_descr_q4    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q4) : using_tx_descr_q4;
   assign using_tx_descr_q5    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q5) : using_tx_descr_q5;
   assign using_tx_descr_q6    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q6) : using_tx_descr_q6;
   assign using_tx_descr_q7    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q7) : using_tx_descr_q7;
   assign using_tx_descr_q8    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q8) : using_tx_descr_q8;
   assign using_tx_descr_q9     = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q9) : using_tx_descr_q9;
   assign using_tx_descr_q10    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q10) : using_tx_descr_q10;
   assign using_tx_descr_q11    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q11) : using_tx_descr_q11;
   assign using_tx_descr_q12    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q12) : using_tx_descr_q12;
   assign using_tx_descr_q13    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q13) : using_tx_descr_q13;
   assign using_tx_descr_q14    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q14) : using_tx_descr_q14;
   assign using_tx_descr_q15    = (valid_dr_access) ? (araddr_data_cmp == next_read_add_tx_descr_q15) : using_tx_descr_q15;

   assign next_read_add     = using_tx_data_q0       ? next_read_add_tx_data_q0 :
                              using_tx_data_q1       ? next_read_add_tx_data_q1 :
                              using_tx_data_q2       ? next_read_add_tx_data_q2 :
                              using_tx_data_q3       ? next_read_add_tx_data_q3 :
                              using_tx_data_q4       ? next_read_add_tx_data_q4 :
                              using_tx_data_q5       ? next_read_add_tx_data_q5 :
                              using_tx_data_q6       ? next_read_add_tx_data_q6 :
                              using_tx_data_q7       ? next_read_add_tx_data_q7 :
                              using_tx_data_q8       ? next_read_add_tx_data_q8 :
                              using_tx_data_q9       ? next_read_add_tx_data_q9 :
                              using_tx_data_q10      ? next_read_add_tx_data_q10:
                              using_tx_data_q11      ? next_read_add_tx_data_q11:
                              using_tx_data_q12      ? next_read_add_tx_data_q12:
                              using_tx_data_q13      ? next_read_add_tx_data_q13:
                              using_tx_data_q14      ? next_read_add_tx_data_q14:
                              using_tx_data_q15      ? next_read_add_tx_data_q15:
                              using_q1               ? next_read_add_q1 :
                              using_q2               ? next_read_add_q2 :
                              using_q3               ? next_read_add_q3 :
                              using_q4               ? next_read_add_q4 :
                              using_q5               ? next_read_add_q5 :
                              using_q6               ? next_read_add_q6 :
                              using_q7               ? next_read_add_q7 :
                              using_q8               ? next_read_add_q8 :
                              using_q9               ? next_read_add_q9 :
                              using_q10              ? next_read_add_q10 :
                              using_q11              ? next_read_add_q11 :
                              using_q12              ? next_read_add_q12 :
                              using_q13              ? next_read_add_q13 :
                              using_q14              ? next_read_add_q14 :
                              using_q15              ? next_read_add_q15 :
                              using_tx_descr         ? next_read_add_tx_descr :
                              using_tx_descr_q1      ? next_read_add_tx_descr_q1 :
                              using_tx_descr_q2      ? next_read_add_tx_descr_q2 :
                              using_tx_descr_q3      ? next_read_add_tx_descr_q3 :
                              using_tx_descr_q4      ? next_read_add_tx_descr_q4 :
                              using_tx_descr_q5      ? next_read_add_tx_descr_q5 :
                              using_tx_descr_q6      ? next_read_add_tx_descr_q6 :
                              using_tx_descr_q7      ? next_read_add_tx_descr_q7 :
                              using_tx_descr_q8      ? next_read_add_tx_descr_q8 :
                              using_tx_descr_q9      ? next_read_add_tx_descr_q9 :
                              using_tx_descr_q10     ? next_read_add_tx_descr_q10 :
                              using_tx_descr_q11     ? next_read_add_tx_descr_q11 :
                              using_tx_descr_q12     ? next_read_add_tx_descr_q12 :
                              using_tx_descr_q13     ? next_read_add_tx_descr_q13 :
                              using_tx_descr_q14     ? next_read_add_tx_descr_q14 :
                              using_tx_descr_q15     ? next_read_add_tx_descr_q15 :
                                                       next_read_add_orig;


   // decode current vector values
   assign dma_rd_vector_plus0 = using_tx_data_q0       ? dma_rd_vector_tx_data_q0_reg[tx_data_q0_next_dma_rd_index] :
                                using_tx_data_q1       ? dma_rd_vector_tx_data_q1_reg[tx_data_q1_next_dma_rd_index] :
                                using_tx_data_q2       ? dma_rd_vector_tx_data_q2_reg[tx_data_q2_next_dma_rd_index] :
                                using_tx_data_q3       ? dma_rd_vector_tx_data_q3_reg[tx_data_q3_next_dma_rd_index] :
                                using_tx_data_q4       ? dma_rd_vector_tx_data_q4_reg[tx_data_q4_next_dma_rd_index] :
                                using_tx_data_q5       ? dma_rd_vector_tx_data_q5_reg[tx_data_q5_next_dma_rd_index] :
                                using_tx_data_q6       ? dma_rd_vector_tx_data_q6_reg[tx_data_q6_next_dma_rd_index] :
                                using_tx_data_q7       ? dma_rd_vector_tx_data_q7_reg[tx_data_q7_next_dma_rd_index] :
                                using_tx_data_q8       ? dma_rd_vector_tx_data_q8_reg[tx_data_q8_next_dma_rd_index] :
                                using_tx_data_q9       ? dma_rd_vector_tx_data_q9_reg[tx_data_q9_next_dma_rd_index] :
                                using_tx_data_q10      ? dma_rd_vector_tx_data_q10_reg[tx_data_q10_next_dma_rd_index] :
                                using_tx_data_q11      ? dma_rd_vector_tx_data_q11_reg[tx_data_q11_next_dma_rd_index] :
                                using_tx_data_q12      ? dma_rd_vector_tx_data_q12_reg[tx_data_q12_next_dma_rd_index] :
                                using_tx_data_q13      ? dma_rd_vector_tx_data_q13_reg[tx_data_q13_next_dma_rd_index] :
                                using_tx_data_q14      ? dma_rd_vector_tx_data_q14_reg[tx_data_q14_next_dma_rd_index] :
                                using_tx_data_q15      ? dma_rd_vector_tx_data_q15_reg[tx_data_q15_next_dma_rd_index] :
                                using_q1        ? dma_rd_q1_vector_reg[next_dma_rd_q1_index] :
                                using_q2        ? dma_rd_q2_vector_reg[next_dma_rd_q2_index] :
                                using_q3        ? dma_rd_q3_vector_reg[next_dma_rd_q3_index] :
                                using_q4        ? dma_rd_q4_vector_reg[next_dma_rd_q4_index] :
                                using_q5        ? dma_rd_q5_vector_reg[next_dma_rd_q5_index] :
                                using_q6        ? dma_rd_q6_vector_reg[next_dma_rd_q6_index] :
                                using_q7        ? dma_rd_q7_vector_reg[next_dma_rd_q7_index] :
                                using_q8        ? dma_rd_q8_vector_reg[next_dma_rd_q8_index] :
                                using_q9        ? dma_rd_q9_vector_reg[next_dma_rd_q9_index] :
                                using_q10        ? dma_rd_q10_vector_reg[next_dma_rd_q10_index] :
                                using_q11        ? dma_rd_q11_vector_reg[next_dma_rd_q11_index] :
                                using_q12        ? dma_rd_q12_vector_reg[next_dma_rd_q12_index] :
                                using_q13        ? dma_rd_q13_vector_reg[next_dma_rd_q13_index] :
                                using_q14        ? dma_rd_q14_vector_reg[next_dma_rd_q14_index] :
                                using_q15        ? dma_rd_q15_vector_reg[next_dma_rd_q15_index] :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index] :
                                using_tx_descr_q1  ? dma_rd_vector_tx_descr_q1_reg[tx_descr_q1_next_dma_rd_index] :
                                using_tx_descr_q2  ? dma_rd_vector_tx_descr_q2_reg[tx_descr_q2_next_dma_rd_index] :
                                using_tx_descr_q3  ? dma_rd_vector_tx_descr_q3_reg[tx_descr_q3_next_dma_rd_index] :
                                using_tx_descr_q4  ? dma_rd_vector_tx_descr_q4_reg[tx_descr_q4_next_dma_rd_index] :
                                using_tx_descr_q5  ? dma_rd_vector_tx_descr_q5_reg[tx_descr_q5_next_dma_rd_index] :
                                using_tx_descr_q6  ? dma_rd_vector_tx_descr_q6_reg[tx_descr_q6_next_dma_rd_index] :
                                using_tx_descr_q7  ? dma_rd_vector_tx_descr_q7_reg[tx_descr_q7_next_dma_rd_index] :
                                using_tx_descr_q8  ? dma_rd_vector_tx_descr_q8_reg[tx_descr_q8_next_dma_rd_index] :
                                using_tx_descr_q9  ? dma_rd_vector_tx_descr_q9_reg[tx_descr_q9_next_dma_rd_index] :
                                using_tx_descr_q10  ? dma_rd_vector_tx_descr_q10_reg[tx_descr_q10_next_dma_rd_index] :
                                using_tx_descr_q11  ? dma_rd_vector_tx_descr_q11_reg[tx_descr_q11_next_dma_rd_index] :
                                using_tx_descr_q12  ? dma_rd_vector_tx_descr_q12_reg[tx_descr_q12_next_dma_rd_index] :
                                using_tx_descr_q13  ? dma_rd_vector_tx_descr_q13_reg[tx_descr_q13_next_dma_rd_index] :
                                using_tx_descr_q14  ? dma_rd_vector_tx_descr_q14_reg[tx_descr_q14_next_dma_rd_index] :
                                using_tx_descr_q15  ? dma_rd_vector_tx_descr_q15_reg[tx_descr_q15_next_dma_rd_index] :
                                                  dma_rd_vector_reg[next_dma_rd_index];
   assign dma_rd_vector_plus1 = using_tx_data_q0       ? dma_rd_vector_tx_data_q0_reg[tx_data_q0_next_dma_rd_index+1] :
                                using_tx_data_q1       ? dma_rd_vector_tx_data_q1_reg[tx_data_q1_next_dma_rd_index+1] :
                                using_tx_data_q2       ? dma_rd_vector_tx_data_q2_reg[tx_data_q2_next_dma_rd_index+1] :
                                using_tx_data_q3       ? dma_rd_vector_tx_data_q3_reg[tx_data_q3_next_dma_rd_index+1] :
                                using_tx_data_q4       ? dma_rd_vector_tx_data_q4_reg[tx_data_q4_next_dma_rd_index+1] :
                                using_tx_data_q5       ? dma_rd_vector_tx_data_q5_reg[tx_data_q5_next_dma_rd_index+1] :
                                using_tx_data_q6       ? dma_rd_vector_tx_data_q6_reg[tx_data_q6_next_dma_rd_index+1] :
                                using_tx_data_q7       ? dma_rd_vector_tx_data_q7_reg[tx_data_q7_next_dma_rd_index+1] :
                                using_tx_data_q8       ? dma_rd_vector_tx_data_q8_reg[tx_data_q8_next_dma_rd_index+1] :
                                using_tx_data_q9       ? dma_rd_vector_tx_data_q9_reg[tx_data_q9_next_dma_rd_index+1] :
                                using_tx_data_q10      ? dma_rd_vector_tx_data_q10_reg[tx_data_q10_next_dma_rd_index+1] :
                                using_tx_data_q11      ? dma_rd_vector_tx_data_q11_reg[tx_data_q11_next_dma_rd_index+1] :
                                using_tx_data_q12      ? dma_rd_vector_tx_data_q12_reg[tx_data_q12_next_dma_rd_index+1] :
                                using_tx_data_q13      ? dma_rd_vector_tx_data_q13_reg[tx_data_q13_next_dma_rd_index+1] :
                                using_tx_data_q14      ? dma_rd_vector_tx_data_q14_reg[tx_data_q14_next_dma_rd_index+1] :
                                using_tx_data_q15      ? dma_rd_vector_tx_data_q15_reg[tx_data_q15_next_dma_rd_index+1] :
                                using_q1        ? dma_rd_q1_vector_reg[next_dma_rd_q1_index+1] :
                                using_q2        ? dma_rd_q2_vector_reg[next_dma_rd_q2_index+1] :
                                using_q3        ? dma_rd_q3_vector_reg[next_dma_rd_q3_index+1] :
                                using_q4        ? dma_rd_q4_vector_reg[next_dma_rd_q4_index+1] :
                                using_q5        ? dma_rd_q5_vector_reg[next_dma_rd_q5_index+1] :
                                using_q6        ? dma_rd_q6_vector_reg[next_dma_rd_q6_index+1] :
                                using_q7        ? dma_rd_q7_vector_reg[next_dma_rd_q7_index+1] :
                                using_q8        ? dma_rd_q8_vector_reg[next_dma_rd_q8_index+1] :
                                using_q9        ? dma_rd_q9_vector_reg[next_dma_rd_q9_index+1] :
                                using_q10        ? dma_rd_q10_vector_reg[next_dma_rd_q10_index+1] :
                                using_q11        ? dma_rd_q11_vector_reg[next_dma_rd_q11_index+1] :
                                using_q12        ? dma_rd_q12_vector_reg[next_dma_rd_q12_index+1] :
                                using_q13        ? dma_rd_q13_vector_reg[next_dma_rd_q13_index+1] :
                                using_q14        ? dma_rd_q14_vector_reg[next_dma_rd_q14_index+1] :
                                using_q15        ? dma_rd_q15_vector_reg[next_dma_rd_q15_index+1] :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index+1] :
                                using_tx_descr_q1  ? dma_rd_vector_tx_descr_q1_reg[tx_descr_q1_next_dma_rd_index+1] :
                                using_tx_descr_q2  ? dma_rd_vector_tx_descr_q2_reg[tx_descr_q2_next_dma_rd_index+1] :
                                using_tx_descr_q3  ? dma_rd_vector_tx_descr_q3_reg[tx_descr_q3_next_dma_rd_index+1] :
                                using_tx_descr_q4  ? dma_rd_vector_tx_descr_q4_reg[tx_descr_q4_next_dma_rd_index+1] :
                                using_tx_descr_q5  ? dma_rd_vector_tx_descr_q5_reg[tx_descr_q5_next_dma_rd_index+1] :
                                using_tx_descr_q6  ? dma_rd_vector_tx_descr_q6_reg[tx_descr_q6_next_dma_rd_index+1] :
                                using_tx_descr_q7  ? dma_rd_vector_tx_descr_q7_reg[tx_descr_q7_next_dma_rd_index+1] :
                                using_tx_descr_q8  ? dma_rd_vector_tx_descr_q8_reg[tx_descr_q8_next_dma_rd_index+1] :
                                using_tx_descr_q9  ? dma_rd_vector_tx_descr_q9_reg[tx_descr_q9_next_dma_rd_index+1] :
                                using_tx_descr_q10  ? dma_rd_vector_tx_descr_q10_reg[tx_descr_q10_next_dma_rd_index+1] :
                                using_tx_descr_q11  ? dma_rd_vector_tx_descr_q11_reg[tx_descr_q11_next_dma_rd_index+1] :
                                using_tx_descr_q12  ? dma_rd_vector_tx_descr_q12_reg[tx_descr_q12_next_dma_rd_index+1] :
                                using_tx_descr_q13  ? dma_rd_vector_tx_descr_q13_reg[tx_descr_q13_next_dma_rd_index+1] :
                                using_tx_descr_q14  ? dma_rd_vector_tx_descr_q14_reg[tx_descr_q14_next_dma_rd_index+1] :
                                using_tx_descr_q15  ? dma_rd_vector_tx_descr_q15_reg[tx_descr_q15_next_dma_rd_index+1] :
                                                  dma_rd_vector_reg[next_dma_rd_index+1];
   assign dma_rd_vector_plus2 = using_tx_data_q0       ? dma_rd_vector_tx_data_q0_reg[tx_data_q0_next_dma_rd_index+2] :
                                using_tx_data_q1       ? dma_rd_vector_tx_data_q1_reg[tx_data_q1_next_dma_rd_index+2] :
                                using_tx_data_q2       ? dma_rd_vector_tx_data_q2_reg[tx_data_q2_next_dma_rd_index+2] :
                                using_tx_data_q3       ? dma_rd_vector_tx_data_q3_reg[tx_data_q3_next_dma_rd_index+2] :
                                using_tx_data_q4       ? dma_rd_vector_tx_data_q4_reg[tx_data_q4_next_dma_rd_index+2] :
                                using_tx_data_q5       ? dma_rd_vector_tx_data_q5_reg[tx_data_q5_next_dma_rd_index+2] :
                                using_tx_data_q6       ? dma_rd_vector_tx_data_q6_reg[tx_data_q6_next_dma_rd_index+2] :
                                using_tx_data_q7       ? dma_rd_vector_tx_data_q7_reg[tx_data_q7_next_dma_rd_index+2] :
                                using_tx_data_q8       ? dma_rd_vector_tx_data_q8_reg[tx_data_q8_next_dma_rd_index+2] :
                                using_tx_data_q9       ? dma_rd_vector_tx_data_q9_reg[tx_data_q9_next_dma_rd_index+2] :
                                using_tx_data_q10      ? dma_rd_vector_tx_data_q10_reg[tx_data_q10_next_dma_rd_index+2] :
                                using_tx_data_q11      ? dma_rd_vector_tx_data_q11_reg[tx_data_q11_next_dma_rd_index+2] :
                                using_tx_data_q12      ? dma_rd_vector_tx_data_q12_reg[tx_data_q12_next_dma_rd_index+2] :
                                using_tx_data_q13      ? dma_rd_vector_tx_data_q13_reg[tx_data_q13_next_dma_rd_index+2] :
                                using_tx_data_q14      ? dma_rd_vector_tx_data_q14_reg[tx_data_q14_next_dma_rd_index+2] :
                                using_tx_data_q15      ? dma_rd_vector_tx_data_q15_reg[tx_data_q15_next_dma_rd_index+2] :
                                using_q1        ? dma_rd_q1_vector_reg[next_dma_rd_q1_index+2] :
                                using_q2        ? dma_rd_q2_vector_reg[next_dma_rd_q2_index+2] :
                                using_q3        ? dma_rd_q3_vector_reg[next_dma_rd_q3_index+2] :
                                using_q4        ? dma_rd_q4_vector_reg[next_dma_rd_q4_index+2] :
                                using_q5        ? dma_rd_q5_vector_reg[next_dma_rd_q5_index+2] :
                                using_q6        ? dma_rd_q6_vector_reg[next_dma_rd_q6_index+2] :
                                using_q7        ? dma_rd_q7_vector_reg[next_dma_rd_q7_index+2] :
                                using_q8        ? dma_rd_q8_vector_reg[next_dma_rd_q8_index+2] :
                                using_q9        ? dma_rd_q9_vector_reg[next_dma_rd_q9_index+2] :
                                using_q10        ? dma_rd_q10_vector_reg[next_dma_rd_q10_index+2] :
                                using_q11        ? dma_rd_q11_vector_reg[next_dma_rd_q11_index+2] :
                                using_q12        ? dma_rd_q12_vector_reg[next_dma_rd_q12_index+2] :
                                using_q13        ? dma_rd_q13_vector_reg[next_dma_rd_q13_index+2] :
                                using_q14        ? dma_rd_q14_vector_reg[next_dma_rd_q14_index+2] :
                                using_q15        ? dma_rd_q15_vector_reg[next_dma_rd_q15_index+2] :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index+2] :
                                using_tx_descr_q1  ? dma_rd_vector_tx_descr_q1_reg[tx_descr_q1_next_dma_rd_index+2] :
                                using_tx_descr_q2  ? dma_rd_vector_tx_descr_q2_reg[tx_descr_q2_next_dma_rd_index+2] :
                                using_tx_descr_q3  ? dma_rd_vector_tx_descr_q3_reg[tx_descr_q3_next_dma_rd_index+2] :
                                using_tx_descr_q4  ? dma_rd_vector_tx_descr_q4_reg[tx_descr_q4_next_dma_rd_index+2] :
                                using_tx_descr_q5  ? dma_rd_vector_tx_descr_q5_reg[tx_descr_q5_next_dma_rd_index+2] :
                                using_tx_descr_q6  ? dma_rd_vector_tx_descr_q6_reg[tx_descr_q6_next_dma_rd_index+2] :
                                using_tx_descr_q7  ? dma_rd_vector_tx_descr_q7_reg[tx_descr_q7_next_dma_rd_index+2] :
                                using_tx_descr_q8  ? dma_rd_vector_tx_descr_q8_reg[tx_descr_q8_next_dma_rd_index+2] :
                                using_tx_descr_q9  ? dma_rd_vector_tx_descr_q9_reg[tx_descr_q9_next_dma_rd_index+2] :
                                using_tx_descr_q10  ? dma_rd_vector_tx_descr_q10_reg[tx_descr_q10_next_dma_rd_index+2] :
                                using_tx_descr_q11  ? dma_rd_vector_tx_descr_q11_reg[tx_descr_q11_next_dma_rd_index+2] :
                                using_tx_descr_q12  ? dma_rd_vector_tx_descr_q12_reg[tx_descr_q12_next_dma_rd_index+2] :
                                using_tx_descr_q13  ? dma_rd_vector_tx_descr_q13_reg[tx_descr_q13_next_dma_rd_index+2] :
                                using_tx_descr_q14  ? dma_rd_vector_tx_descr_q14_reg[tx_descr_q14_next_dma_rd_index+2] :
                                using_tx_descr_q15  ? dma_rd_vector_tx_descr_q15_reg[tx_descr_q15_next_dma_rd_index+2] :
                                                  dma_rd_vector_reg[next_dma_rd_index+2];
   assign dma_rd_vector_plus3 = using_tx_data_q0       ? dma_rd_vector_tx_data_q0_reg[tx_data_q0_next_dma_rd_index+3] :
                                using_tx_data_q1       ? dma_rd_vector_tx_data_q1_reg[tx_data_q1_next_dma_rd_index+3] :
                                using_tx_data_q2       ? dma_rd_vector_tx_data_q2_reg[tx_data_q2_next_dma_rd_index+3] :
                                using_tx_data_q3       ? dma_rd_vector_tx_data_q3_reg[tx_data_q3_next_dma_rd_index+3] :
                                using_tx_data_q4       ? dma_rd_vector_tx_data_q4_reg[tx_data_q4_next_dma_rd_index+3] :
                                using_tx_data_q5       ? dma_rd_vector_tx_data_q5_reg[tx_data_q5_next_dma_rd_index+3] :
                                using_tx_data_q6       ? dma_rd_vector_tx_data_q6_reg[tx_data_q6_next_dma_rd_index+3] :
                                using_tx_data_q7       ? dma_rd_vector_tx_data_q7_reg[tx_data_q7_next_dma_rd_index+3] :
                                using_tx_data_q8       ? dma_rd_vector_tx_data_q8_reg[tx_data_q8_next_dma_rd_index+3] :
                                using_tx_data_q9       ? dma_rd_vector_tx_data_q9_reg[tx_data_q9_next_dma_rd_index+3] :
                                using_tx_data_q10      ? dma_rd_vector_tx_data_q10_reg[tx_data_q10_next_dma_rd_index+3] :
                                using_tx_data_q11      ? dma_rd_vector_tx_data_q11_reg[tx_data_q11_next_dma_rd_index+3] :
                                using_tx_data_q12      ? dma_rd_vector_tx_data_q12_reg[tx_data_q12_next_dma_rd_index+3] :
                                using_tx_data_q13      ? dma_rd_vector_tx_data_q13_reg[tx_data_q13_next_dma_rd_index+3] :
                                using_tx_data_q14      ? dma_rd_vector_tx_data_q14_reg[tx_data_q14_next_dma_rd_index+3] :
                                using_tx_data_q15      ? dma_rd_vector_tx_data_q15_reg[tx_data_q15_next_dma_rd_index+3] :
                                using_q1        ? dma_rd_q1_vector_reg[next_dma_rd_q1_index+3] :
                                using_q2        ? dma_rd_q2_vector_reg[next_dma_rd_q2_index+3] :
                                using_q3        ? dma_rd_q3_vector_reg[next_dma_rd_q3_index+3] :
                                using_q4        ? dma_rd_q4_vector_reg[next_dma_rd_q4_index+3] :
                                using_q5        ? dma_rd_q5_vector_reg[next_dma_rd_q5_index+3] :
                                using_q6        ? dma_rd_q6_vector_reg[next_dma_rd_q6_index+3] :
                                using_q7        ? dma_rd_q7_vector_reg[next_dma_rd_q7_index+3] :
                                using_q8        ? dma_rd_q8_vector_reg[next_dma_rd_q8_index+3] :
                                using_q9        ? dma_rd_q9_vector_reg[next_dma_rd_q9_index+3] :
                                using_q10        ? dma_rd_q10_vector_reg[next_dma_rd_q10_index+3] :
                                using_q11        ? dma_rd_q11_vector_reg[next_dma_rd_q11_index+3] :
                                using_q12        ? dma_rd_q12_vector_reg[next_dma_rd_q12_index+3] :
                                using_q13        ? dma_rd_q13_vector_reg[next_dma_rd_q13_index+3] :
                                using_q14        ? dma_rd_q14_vector_reg[next_dma_rd_q14_index+3] :
                                using_q15        ? dma_rd_q15_vector_reg[next_dma_rd_q15_index+3] :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index+3] :
                                using_tx_descr_q1  ? dma_rd_vector_tx_descr_q1_reg[tx_descr_q1_next_dma_rd_index+3] :
                                using_tx_descr_q2  ? dma_rd_vector_tx_descr_q2_reg[tx_descr_q2_next_dma_rd_index+3] :
                                using_tx_descr_q3  ? dma_rd_vector_tx_descr_q3_reg[tx_descr_q3_next_dma_rd_index+3] :
                                using_tx_descr_q4  ? dma_rd_vector_tx_descr_q4_reg[tx_descr_q4_next_dma_rd_index+3] :
                                using_tx_descr_q5  ? dma_rd_vector_tx_descr_q5_reg[tx_descr_q5_next_dma_rd_index+3] :
                                using_tx_descr_q6  ? dma_rd_vector_tx_descr_q6_reg[tx_descr_q6_next_dma_rd_index+3] :
                                using_tx_descr_q7  ? dma_rd_vector_tx_descr_q7_reg[tx_descr_q7_next_dma_rd_index+3] :
                                using_tx_descr_q8  ? dma_rd_vector_tx_descr_q8_reg[tx_descr_q8_next_dma_rd_index+3] :
                                using_tx_descr_q9  ? dma_rd_vector_tx_descr_q9_reg[tx_descr_q9_next_dma_rd_index+3] :
                                using_tx_descr_q10  ? dma_rd_vector_tx_descr_q10_reg[tx_descr_q10_next_dma_rd_index+3] :
                                using_tx_descr_q11  ? dma_rd_vector_tx_descr_q11_reg[tx_descr_q11_next_dma_rd_index+3] :
                                using_tx_descr_q12  ? dma_rd_vector_tx_descr_q12_reg[tx_descr_q12_next_dma_rd_index+3] :
                                using_tx_descr_q13  ? dma_rd_vector_tx_descr_q13_reg[tx_descr_q13_next_dma_rd_index+3] :
                                using_tx_descr_q14  ? dma_rd_vector_tx_descr_q14_reg[tx_descr_q14_next_dma_rd_index+3] :
                                using_tx_descr_q15  ? dma_rd_vector_tx_descr_q15_reg[tx_descr_q15_next_dma_rd_index+3] :
                                                  dma_rd_vector_reg[next_dma_rd_index+3];

   assign dma_rd_done         = dma_rd_vector_nxt_tx_data_q0[98] &
                                dma_rd_vector_nxt_tx_data_q1[98] &
                                dma_rd_vector_nxt_tx_data_q2[98] &
                                dma_rd_vector_nxt_tx_data_q3[98] &
                                dma_rd_vector_nxt_tx_data_q4[98] &
                                dma_rd_vector_nxt_tx_data_q5[98] &
                                dma_rd_vector_nxt_tx_data_q6[98] &
                                dma_rd_vector_nxt_tx_data_q7[98] &
                                dma_rd_vector_nxt_tx_data_q8[98] &
                                dma_rd_vector_nxt_tx_data_q9[98] &
                                dma_rd_vector_nxt_tx_data_q10[98] &
                                dma_rd_vector_nxt_tx_data_q11[98] &
                                dma_rd_vector_nxt_tx_data_q12[98] &
                                dma_rd_vector_nxt_tx_data_q13[98] &
                                dma_rd_vector_nxt_tx_data_q14[98] &
                                dma_rd_vector_nxt_tx_data_q15[98] &
                                dma_rd_vector_nxt_tx_descr[98] &
                                dma_rd_vector_nxt_q15[98] &
                                dma_rd_vector_nxt_q14[98] &
                                dma_rd_vector_nxt_q13[98] &
                                dma_rd_vector_nxt_q12[98] &
                                dma_rd_vector_nxt_q11[98] &
                                dma_rd_vector_nxt_q10[98] &
                                dma_rd_vector_nxt_q9[98] &
                                dma_rd_vector_nxt_q8[98] &
                                dma_rd_vector_nxt_q7[98] &
                                dma_rd_vector_nxt_q6[98] &
                                dma_rd_vector_nxt_q5[98] &
                                dma_rd_vector_nxt_q4[98] &
                                dma_rd_vector_nxt_q3[98] &
                                dma_rd_vector_nxt_q2[98] &
                                dma_rd_vector_nxt_q1[98] &
                                dma_rd_vector_nxt_orig[98];
   assign read_data_31to0     = dma_rd_vector_plus0[31:0];
   assign read_data_63to32    = dma_rd_vector_plus1[31:0];
   assign read_data_95to64    = dma_rd_vector_plus2[31:0];
   assign read_data_127to96   = dma_rd_vector_plus3[31:0];
   assign rd_not_ok           = dma_rd_vector_plus0[96] && !dma_rd_vector_plus0[99];
   assign rd_endian_swap      = (dma_rd_vector_plus0[97]) | (&endian_value);
   assign repeat_var          = dma_rd_vector_plus0[99] && dma_rd_vector_plus0[96];
   assign tx_descr_rd_access  = dma_rd_vector_plus0[99] && !dma_rd_vector_plus0[96];


   wire qos_correct_rd,qos_correct_wr;
   reg qos_rd_fail,qos_wr_fail;
   assign qos_correct_rd      = using_tx_data_q0                  ? arqos_data == apb_qos_for_axi[3:0]:
                                using_tx_data_q1                  ? arqos_data == apb_qos_for_axi[11:8]:
                                using_tx_data_q2                  ? arqos_data == apb_qos_for_axi[19:16] :
                                using_tx_data_q3                  ? arqos_data == apb_qos_for_axi[27:24]:
                                using_tx_data_q4                  ? arqos_data == apb_qos_for_axi[35:32] :
                                using_tx_data_q5                  ? arqos_data == apb_qos_for_axi[43:40]:
                                using_tx_data_q6                  ? arqos_data == apb_qos_for_axi[51:48] :
                                using_tx_data_q7                  ? arqos_data == apb_qos_for_axi[59:56]:
                                using_tx_data_q8                  ? arqos_data == apb_qos_for_axi[67:64] :
                                using_tx_data_q9                  ? arqos_data == apb_qos_for_axi[75:72]:
                                using_tx_data_q10                 ? arqos_data == apb_qos_for_axi[83:80] :
                                using_tx_data_q11                 ? arqos_data == apb_qos_for_axi[91:88]:
                                using_tx_data_q12                 ? arqos_data == apb_qos_for_axi[99:96] :
                                using_tx_data_q13                 ? arqos_data == apb_qos_for_axi[107:104]:
                                using_tx_data_q14                 ? arqos_data == apb_qos_for_axi[115:112] :
                                using_tx_data_q15                 ? arqos_data == apb_qos_for_axi[123:120]:
                                using_tx_descr_q1   | using_q1    ? arqos_data == apb_qos_for_axi[15:12]:
                                using_tx_descr_q2   | using_q2    ? arqos_data == apb_qos_for_axi[23:20] :
                                using_tx_descr_q3   | using_q3    ? arqos_data == apb_qos_for_axi[31:28]:
                                using_tx_descr_q4   | using_q4    ? arqos_data == apb_qos_for_axi[39:36] :
                                using_tx_descr_q5   | using_q5    ? arqos_data == apb_qos_for_axi[47:44]:
                                using_tx_descr_q6   | using_q6    ? arqos_data == apb_qos_for_axi[55:52] :
                                using_tx_descr_q7   | using_q7    ? arqos_data == apb_qos_for_axi[63:60]:
                                using_tx_descr_q8   | using_q8    ? arqos_data == apb_qos_for_axi[71:68] :
                                using_tx_descr_q9   | using_q9    ? arqos_data == apb_qos_for_axi[79:76]:
                                using_tx_descr_q10  | using_q10   ? arqos_data == apb_qos_for_axi[87:84] :
                                using_tx_descr_q11  | using_q11   ? arqos_data == apb_qos_for_axi[95:92]:
                                using_tx_descr_q12  | using_q12   ? arqos_data == apb_qos_for_axi[103:100] :
                                using_tx_descr_q13  | using_q13   ? arqos_data == apb_qos_for_axi[111:108]:
                                using_tx_descr_q14  | using_q14   ? arqos_data == apb_qos_for_axi[119:116] :
                                using_tx_descr_q15  | using_q15   ? arqos_data == apb_qos_for_axi[127:124]:
                                                                    arqos_data == apb_qos_for_axi[7:4] ;



   // read dma write data (used by RX data writes)
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            dma_wr_rx_data_q0[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_rx_data_q0.data",dma_wr_rx_data_q0);
         if (dma_wr_rx_data_q0[1] === 99'hx)
            $display("\n No dma write data file read \n");
      end
   // read alternative dma write data used by TX descriptor writes
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            dma_wr_tx_descr_q0[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q0.data",dma_wr_tx_descr_q0);
         if (dma_wr_tx_descr_q0[1] === 99'hx)
            $display("\n No alternative dma write data file read \n");
      end
   // read dma descriptor write data for RX
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            dma_rx_wr_descr_q0[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_rx_descr_q0.data",dma_rx_wr_descr_q0);
         if (dma_rx_wr_descr_q0[1] === 99'hx)
            $display("\n No RX dma descriptor write data file read \n");
      end

   `ifdef dma_priority_queue1
   // read TX descriptor and data write data
    initial
    begin
      for (k=1; k<=8192; k=k+1)
      begin
        dma_wr_tx_descr_q1[k]  = 108'b0;
        dma_wr_tx_descr_q2[k]  = 108'b0;
        dma_wr_tx_descr_q3[k]  = 108'b0;
        dma_wr_tx_descr_q4[k]  = 108'b0;
        dma_wr_tx_descr_q5[k]  = 108'b0;
        dma_wr_tx_descr_q6[k]  = 108'b0;
        dma_wr_tx_descr_q7[k]  = 108'b0;
        dma_wr_tx_descr_q8[k]  = 108'b0;
        dma_wr_tx_descr_q9[k]  = 108'b0;
        dma_wr_tx_descr_q10[k] = 108'b0;
        dma_wr_tx_descr_q11[k] = 108'b0;
        dma_wr_tx_descr_q12[k] = 108'b0;
        dma_wr_tx_descr_q13[k] = 108'b0;
        dma_wr_tx_descr_q14[k] = 108'b0;
        dma_wr_tx_descr_q15[k] = 108'b0;
        dma_wr_rx_data_q1[k] = 108'b0;
        dma_wr_rx_data_q2[k] = 108'b0;
        dma_wr_rx_data_q3[k] = 108'b0;
        dma_wr_rx_data_q4[k] = 108'b0;
        dma_wr_rx_data_q5[k] = 108'b0;
        dma_wr_rx_data_q6[k] = 108'b0;
        dma_wr_rx_data_q7[k] = 108'b0;
        dma_wr_rx_data_q8[k] = 108'b0;
        dma_wr_rx_data_q9[k] = 108'b0;
        dma_wr_rx_data_q10[k] = 108'b0;
        dma_wr_rx_data_q11[k] = 108'b0;
        dma_wr_rx_data_q12[k] = 108'b0;
        dma_wr_rx_data_q13[k] = 108'b0;
        dma_wr_rx_data_q14[k] = 108'b0;
        dma_wr_rx_data_q15[k] = 108'b0;
        dma_wr_rx_descr_q1[k] = 108'b0;
        dma_wr_rx_descr_q2[k] = 108'b0;
        dma_wr_rx_descr_q3[k] = 108'b0;
        dma_wr_rx_descr_q4[k] = 108'b0;
        dma_wr_rx_descr_q5[k] = 108'b0;
        dma_wr_rx_descr_q6[k] = 108'b0;
        dma_wr_rx_descr_q7[k] = 108'b0;
        dma_wr_rx_descr_q8[k] = 108'b0;
        dma_wr_rx_descr_q9[k] = 108'b0;
        dma_wr_rx_descr_q10[k] = 108'b0;
        dma_wr_rx_descr_q11[k] = 108'b0;
        dma_wr_rx_descr_q12[k] = 108'b0;
        dma_wr_rx_descr_q13[k] = 108'b0;
        dma_wr_rx_descr_q14[k] = 108'b0;
        dma_wr_rx_descr_q15[k] = 108'b0;
      end
      $readmemh("./files/tb_dma_wr_tx_descr_q1.data",dma_wr_tx_descr_q1);
      $readmemh("./files/tb_dma_wr_tx_descr_q2.data",dma_wr_tx_descr_q2);
      $readmemh("./files/tb_dma_wr_tx_descr_q3.data",dma_wr_tx_descr_q3);
      $readmemh("./files/tb_dma_wr_tx_descr_q4.data",dma_wr_tx_descr_q4);
      $readmemh("./files/tb_dma_wr_tx_descr_q5.data",dma_wr_tx_descr_q5);
      $readmemh("./files/tb_dma_wr_tx_descr_q6.data",dma_wr_tx_descr_q6);
      $readmemh("./files/tb_dma_wr_tx_descr_q7.data",dma_wr_tx_descr_q7);
      $readmemh("./files/tb_dma_wr_tx_descr_q8.data",dma_wr_tx_descr_q8);
      $readmemh("./files/tb_dma_wr_tx_descr_q9.data",dma_wr_tx_descr_q9);
      $readmemh("./files/tb_dma_wr_tx_descr_q10.data",dma_wr_tx_descr_q10);
      $readmemh("./files/tb_dma_wr_tx_descr_q11.data",dma_wr_tx_descr_q11);
      $readmemh("./files/tb_dma_wr_tx_descr_q12.data",dma_wr_tx_descr_q12);
      $readmemh("./files/tb_dma_wr_tx_descr_q13.data",dma_wr_tx_descr_q13);
      $readmemh("./files/tb_dma_wr_tx_descr_q14.data",dma_wr_tx_descr_q14);
      $readmemh("./files/tb_dma_wr_tx_descr_q15.data",dma_wr_tx_descr_q15);

      $readmemh("./files/tb_dma_wr_rx_data_q1.data",dma_wr_rx_data_q1);
      $readmemh("./files/tb_dma_wr_rx_data_q2.data",dma_wr_rx_data_q2);
      $readmemh("./files/tb_dma_wr_rx_data_q3.data",dma_wr_rx_data_q3);
      $readmemh("./files/tb_dma_wr_rx_data_q4.data",dma_wr_rx_data_q4);
      $readmemh("./files/tb_dma_wr_rx_data_q5.data",dma_wr_rx_data_q5);
      $readmemh("./files/tb_dma_wr_rx_data_q6.data",dma_wr_rx_data_q6);
      $readmemh("./files/tb_dma_wr_rx_data_q7.data",dma_wr_rx_data_q7);
      $readmemh("./files/tb_dma_wr_rx_data_q8.data",dma_wr_rx_data_q8);
      $readmemh("./files/tb_dma_wr_rx_data_q9.data",dma_wr_rx_data_q9);
      $readmemh("./files/tb_dma_wr_rx_data_q10.data",dma_wr_rx_data_q10);
      $readmemh("./files/tb_dma_wr_rx_data_q11.data",dma_wr_rx_data_q11);
      $readmemh("./files/tb_dma_wr_rx_data_q12.data",dma_wr_rx_data_q12);
      $readmemh("./files/tb_dma_wr_rx_data_q13.data",dma_wr_rx_data_q13);
      $readmemh("./files/tb_dma_wr_rx_data_q14.data",dma_wr_rx_data_q14);
      $readmemh("./files/tb_dma_wr_rx_data_q15.data",dma_wr_rx_data_q15);

      $readmemh("./files/tb_dma_wr_rx_descr_q1.data",dma_wr_rx_descr_q1);
      $readmemh("./files/tb_dma_wr_rx_descr_q2.data",dma_wr_rx_descr_q2);
      $readmemh("./files/tb_dma_wr_rx_descr_q3.data",dma_wr_rx_descr_q3);
      $readmemh("./files/tb_dma_wr_rx_descr_q4.data",dma_wr_rx_descr_q4);
      $readmemh("./files/tb_dma_wr_rx_descr_q5.data",dma_wr_rx_descr_q5);
      $readmemh("./files/tb_dma_wr_rx_descr_q6.data",dma_wr_rx_descr_q6);
      $readmemh("./files/tb_dma_wr_rx_descr_q7.data",dma_wr_rx_descr_q7);
      $readmemh("./files/tb_dma_wr_rx_descr_q8.data",dma_wr_rx_descr_q8);
      $readmemh("./files/tb_dma_wr_rx_descr_q9.data",dma_wr_rx_descr_q9);
      $readmemh("./files/tb_dma_wr_rx_descr_q10.data",dma_wr_rx_descr_q10);
      $readmemh("./files/tb_dma_wr_rx_descr_q11.data",dma_wr_rx_descr_q11);
      $readmemh("./files/tb_dma_wr_rx_descr_q12.data",dma_wr_rx_descr_q12);
      $readmemh("./files/tb_dma_wr_rx_descr_q13.data",dma_wr_rx_descr_q13);
      $readmemh("./files/tb_dma_wr_rx_descr_q14.data",dma_wr_rx_descr_q14);
      $readmemh("./files/tb_dma_wr_rx_descr_q15.data",dma_wr_rx_descr_q15);
   end
   `endif


   assign vector_dma_wr_rx_data_q0    = dma_wr_rx_data_q0[index_dma_wr_rx_data_q0];
   assign vector_dma_wr_tx_descr_q0   = dma_wr_tx_descr_q0[index_dma_wr_tx_descr_q0];
   assign vector_dma_wr_rx_descr_q0   = dma_rx_wr_descr_q0[index_dma_wr_rx_descr_q0];

   `ifdef dma_priority_queue1
   assign vector_dma_wr_tx_descr_q1  = dma_wr_tx_descr_q1[index_dma_wr_tx_descr_q1];
   assign vector_dma_wr_tx_descr_q2  = dma_wr_tx_descr_q2[index_dma_wr_tx_descr_q2];
   assign vector_dma_wr_tx_descr_q3  = dma_wr_tx_descr_q3[index_dma_wr_tx_descr_q3];
   assign vector_dma_wr_tx_descr_q4  = dma_wr_tx_descr_q4[index_dma_wr_tx_descr_q4];
   assign vector_dma_wr_tx_descr_q5  = dma_wr_tx_descr_q5[index_dma_wr_tx_descr_q5];
   assign vector_dma_wr_tx_descr_q6  = dma_wr_tx_descr_q6[index_dma_wr_tx_descr_q6];
   assign vector_dma_wr_tx_descr_q7  = dma_wr_tx_descr_q7[index_dma_wr_tx_descr_q7];
   assign vector_dma_wr_tx_descr_q8  = dma_wr_tx_descr_q8[index_dma_wr_tx_descr_q8];
   assign vector_dma_wr_tx_descr_q9  = dma_wr_tx_descr_q9[index_dma_wr_tx_descr_q9];
   assign vector_dma_wr_tx_descr_q10 = dma_wr_tx_descr_q10[index_dma_wr_tx_descr_q10];
   assign vector_dma_wr_tx_descr_q11 = dma_wr_tx_descr_q11[index_dma_wr_tx_descr_q11];
   assign vector_dma_wr_tx_descr_q12 = dma_wr_tx_descr_q12[index_dma_wr_tx_descr_q12];
   assign vector_dma_wr_tx_descr_q13 = dma_wr_tx_descr_q13[index_dma_wr_tx_descr_q13];
   assign vector_dma_wr_tx_descr_q14 = dma_wr_tx_descr_q14[index_dma_wr_tx_descr_q14];
   assign vector_dma_wr_tx_descr_q15 = dma_wr_tx_descr_q15[index_dma_wr_tx_descr_q15];
   assign vector_dma_wr_rx_descr_q1  = dma_wr_rx_descr_q1[index_dma_wr_rx_descr_q1];
   assign vector_dma_wr_rx_descr_q2  = dma_wr_rx_descr_q2[index_dma_wr_rx_descr_q2];
   assign vector_dma_wr_rx_descr_q3  = dma_wr_rx_descr_q3[index_dma_wr_rx_descr_q3];
   assign vector_dma_wr_rx_descr_q4  = dma_wr_rx_descr_q4[index_dma_wr_rx_descr_q4];
   assign vector_dma_wr_rx_descr_q5  = dma_wr_rx_descr_q5[index_dma_wr_rx_descr_q5];
   assign vector_dma_wr_rx_descr_q6  = dma_wr_rx_descr_q6[index_dma_wr_rx_descr_q6];
   assign vector_dma_wr_rx_descr_q7  = dma_wr_rx_descr_q7[index_dma_wr_rx_descr_q7];
   assign vector_dma_wr_rx_descr_q8  = dma_wr_rx_descr_q8[index_dma_wr_rx_descr_q8];
   assign vector_dma_wr_rx_descr_q9  = dma_wr_rx_descr_q9[index_dma_wr_rx_descr_q9];
   assign vector_dma_wr_rx_descr_q10 = dma_wr_rx_descr_q10[index_dma_wr_rx_descr_q10];
   assign vector_dma_wr_rx_descr_q11 = dma_wr_rx_descr_q11[index_dma_wr_rx_descr_q11];
   assign vector_dma_wr_rx_descr_q12 = dma_wr_rx_descr_q12[index_dma_wr_rx_descr_q12];
   assign vector_dma_wr_rx_descr_q13 = dma_wr_rx_descr_q13[index_dma_wr_rx_descr_q13];
   assign vector_dma_wr_rx_descr_q14 = dma_wr_rx_descr_q14[index_dma_wr_rx_descr_q14];
   assign vector_dma_wr_rx_descr_q15 = dma_wr_rx_descr_q15[index_dma_wr_rx_descr_q15];
   assign vector_dma_wr_rx_data_q1  = dma_wr_rx_data_q1[index_dma_wr_rx_data_q1];
   assign vector_dma_wr_rx_data_q2  = dma_wr_rx_data_q2[index_dma_wr_rx_data_q2];
   assign vector_dma_wr_rx_data_q3  = dma_wr_rx_data_q3[index_dma_wr_rx_data_q3];
   assign vector_dma_wr_rx_data_q4  = dma_wr_rx_data_q4[index_dma_wr_rx_data_q4];
   assign vector_dma_wr_rx_data_q5  = dma_wr_rx_data_q5[index_dma_wr_rx_data_q5];
   assign vector_dma_wr_rx_data_q6  = dma_wr_rx_data_q6[index_dma_wr_rx_data_q6];
   assign vector_dma_wr_rx_data_q7  = dma_wr_rx_data_q7[index_dma_wr_rx_data_q7];
   assign vector_dma_wr_rx_data_q8  = dma_wr_rx_data_q8[index_dma_wr_rx_data_q8];
   assign vector_dma_wr_rx_data_q9  = dma_wr_rx_data_q9[index_dma_wr_rx_data_q9];
   assign vector_dma_wr_rx_data_q10 = dma_wr_rx_data_q10[index_dma_wr_rx_data_q10];
   assign vector_dma_wr_rx_data_q11 = dma_wr_rx_data_q11[index_dma_wr_rx_data_q11];
   assign vector_dma_wr_rx_data_q12 = dma_wr_rx_data_q12[index_dma_wr_rx_data_q12];
   assign vector_dma_wr_rx_data_q13 = dma_wr_rx_data_q13[index_dma_wr_rx_data_q13];
   assign vector_dma_wr_rx_data_q14 = dma_wr_rx_data_q14[index_dma_wr_rx_data_q14];
   assign vector_dma_wr_rx_data_q15 = dma_wr_rx_data_q15[index_dma_wr_rx_data_q15];
   `endif

   assign nxt_vector_dma_wr_rx_data_q0  = dma_wr_rx_data_q0[next_index_dma_wr_rx_data_q0];
   assign nxt_vector_dma_wr_tx_descr_q0 = dma_wr_tx_descr_q0[next_index_dma_wr_tx_descr_q0];
   assign nxt_vector_dma_wr_rx_descr_q0 = dma_rx_wr_descr_q0[next_index_dma_wr_rx_descr_q0];
   `ifdef dma_priority_queue1
   assign nxt_vector_dma_wr_tx_descr_q1   = dma_wr_tx_descr_q1[next_index_dma_wr_tx_descr_q1];
   assign nxt_vector_dma_wr_tx_descr_q2   = dma_wr_tx_descr_q2[next_index_dma_wr_tx_descr_q2];
   assign nxt_vector_dma_wr_tx_descr_q3   = dma_wr_tx_descr_q3[next_index_dma_wr_tx_descr_q3];
   assign nxt_vector_dma_wr_tx_descr_q4   = dma_wr_tx_descr_q4[next_index_dma_wr_tx_descr_q4];
   assign nxt_vector_dma_wr_tx_descr_q5   = dma_wr_tx_descr_q5[next_index_dma_wr_tx_descr_q5];
   assign nxt_vector_dma_wr_tx_descr_q6   = dma_wr_tx_descr_q6[next_index_dma_wr_tx_descr_q6];
   assign nxt_vector_dma_wr_tx_descr_q7   = dma_wr_tx_descr_q7[next_index_dma_wr_tx_descr_q7];
   assign nxt_vector_dma_wr_tx_descr_q8   = dma_wr_tx_descr_q8[next_index_dma_wr_tx_descr_q8];
   assign nxt_vector_dma_wr_tx_descr_q9   = dma_wr_tx_descr_q9[next_index_dma_wr_tx_descr_q9];
   assign nxt_vector_dma_wr_tx_descr_q10  = dma_wr_tx_descr_q10[next_index_dma_wr_tx_descr_q10];
   assign nxt_vector_dma_wr_tx_descr_q11  = dma_wr_tx_descr_q11[next_index_dma_wr_tx_descr_q11];
   assign nxt_vector_dma_wr_tx_descr_q12  = dma_wr_tx_descr_q12[next_index_dma_wr_tx_descr_q12];
   assign nxt_vector_dma_wr_tx_descr_q13  = dma_wr_tx_descr_q13[next_index_dma_wr_tx_descr_q13];
   assign nxt_vector_dma_wr_tx_descr_q14  = dma_wr_tx_descr_q14[next_index_dma_wr_tx_descr_q14];
   assign nxt_vector_dma_wr_tx_descr_q15  = dma_wr_tx_descr_q15[next_index_dma_wr_tx_descr_q15];
   assign nxt_vector_dma_wr_rx_descr_q1   = dma_wr_rx_descr_q1[next_index_dma_wr_rx_descr_q1];
   assign nxt_vector_dma_wr_rx_descr_q2   = dma_wr_rx_descr_q2[next_index_dma_wr_rx_descr_q2];
   assign nxt_vector_dma_wr_rx_descr_q3   = dma_wr_rx_descr_q3[next_index_dma_wr_rx_descr_q3];
   assign nxt_vector_dma_wr_rx_descr_q4   = dma_wr_rx_descr_q4[next_index_dma_wr_rx_descr_q4];
   assign nxt_vector_dma_wr_rx_descr_q5   = dma_wr_rx_descr_q5[next_index_dma_wr_rx_descr_q5];
   assign nxt_vector_dma_wr_rx_descr_q6   = dma_wr_rx_descr_q6[next_index_dma_wr_rx_descr_q6];
   assign nxt_vector_dma_wr_rx_descr_q7   = dma_wr_rx_descr_q7[next_index_dma_wr_rx_descr_q7];
   assign nxt_vector_dma_wr_rx_descr_q8   = dma_wr_rx_descr_q8[next_index_dma_wr_rx_descr_q8];
   assign nxt_vector_dma_wr_rx_descr_q9   = dma_wr_rx_descr_q9[next_index_dma_wr_rx_descr_q9];
   assign nxt_vector_dma_wr_rx_descr_q10  = dma_wr_rx_descr_q10[next_index_dma_wr_rx_descr_q10];
   assign nxt_vector_dma_wr_rx_descr_q11  = dma_wr_rx_descr_q11[next_index_dma_wr_rx_descr_q11];
   assign nxt_vector_dma_wr_rx_descr_q12  = dma_wr_rx_descr_q12[next_index_dma_wr_rx_descr_q12];
   assign nxt_vector_dma_wr_rx_descr_q13  = dma_wr_rx_descr_q13[next_index_dma_wr_rx_descr_q13];
   assign nxt_vector_dma_wr_rx_descr_q14  = dma_wr_rx_descr_q14[next_index_dma_wr_rx_descr_q14];
   assign nxt_vector_dma_wr_rx_descr_q15  = dma_wr_rx_descr_q15[next_index_dma_wr_rx_descr_q15];
   assign nxt_vector_dma_wr_rx_data_q1    = dma_wr_rx_data_q1[next_index_dma_wr_rx_data_q1];
   assign nxt_vector_dma_wr_rx_data_q2    = dma_wr_rx_data_q2[next_index_dma_wr_rx_data_q2];
   assign nxt_vector_dma_wr_rx_data_q3    = dma_wr_rx_data_q3[next_index_dma_wr_rx_data_q3];
   assign nxt_vector_dma_wr_rx_data_q4    = dma_wr_rx_data_q4[next_index_dma_wr_rx_data_q4];
   assign nxt_vector_dma_wr_rx_data_q5    = dma_wr_rx_data_q5[next_index_dma_wr_rx_data_q5];
   assign nxt_vector_dma_wr_rx_data_q6    = dma_wr_rx_data_q6[next_index_dma_wr_rx_data_q6];
   assign nxt_vector_dma_wr_rx_data_q7    = dma_wr_rx_data_q7[next_index_dma_wr_rx_data_q7];
   assign nxt_vector_dma_wr_rx_data_q8    = dma_wr_rx_data_q8[next_index_dma_wr_rx_data_q8];
   assign nxt_vector_dma_wr_rx_data_q9    = dma_wr_rx_data_q9[next_index_dma_wr_rx_data_q9];
   assign nxt_vector_dma_wr_rx_data_q10   = dma_wr_rx_data_q10[next_index_dma_wr_rx_data_q10];
   assign nxt_vector_dma_wr_rx_data_q11   = dma_wr_rx_data_q11[next_index_dma_wr_rx_data_q11];
   assign nxt_vector_dma_wr_rx_data_q12   = dma_wr_rx_data_q12[next_index_dma_wr_rx_data_q12];
   assign nxt_vector_dma_wr_rx_data_q13   = dma_wr_rx_data_q13[next_index_dma_wr_rx_data_q13];
   assign nxt_vector_dma_wr_rx_data_q14   = dma_wr_rx_data_q14[next_index_dma_wr_rx_data_q14];
   assign nxt_vector_dma_wr_rx_data_q15   = dma_wr_rx_data_q15[next_index_dma_wr_rx_data_q15];
   `endif

   assign next_rx_data_write_add_q0       = nxt_vector_dma_wr_rx_data_q0[103:40];
   assign next_tx_descr_write_add_q0      = nxt_vector_dma_wr_tx_descr_q0[103:40];
   assign next_rx_descr_write_add_q0      = nxt_vector_dma_wr_rx_descr_q0[103:40];

   `ifdef dma_priority_queue1
   assign next_tx_descr_write_add_q1   = nxt_vector_dma_wr_tx_descr_q1 [103:40];
   assign next_tx_descr_write_add_q2   = nxt_vector_dma_wr_tx_descr_q2 [103:40];
   assign next_tx_descr_write_add_q3   = nxt_vector_dma_wr_tx_descr_q3 [103:40];
   assign next_tx_descr_write_add_q4   = nxt_vector_dma_wr_tx_descr_q4 [103:40];
   assign next_tx_descr_write_add_q5   = nxt_vector_dma_wr_tx_descr_q5 [103:40];
   assign next_tx_descr_write_add_q6   = nxt_vector_dma_wr_tx_descr_q6 [103:40];
   assign next_tx_descr_write_add_q7   = nxt_vector_dma_wr_tx_descr_q7 [103:40];
   assign next_tx_descr_write_add_q8   = nxt_vector_dma_wr_tx_descr_q8 [103:40];
   assign next_tx_descr_write_add_q9   = nxt_vector_dma_wr_tx_descr_q9 [103:40];
   assign next_tx_descr_write_add_q10  = nxt_vector_dma_wr_tx_descr_q10 [103:40];
   assign next_tx_descr_write_add_q11  = nxt_vector_dma_wr_tx_descr_q11 [103:40];
   assign next_tx_descr_write_add_q12  = nxt_vector_dma_wr_tx_descr_q12 [103:40];
   assign next_tx_descr_write_add_q13  = nxt_vector_dma_wr_tx_descr_q13 [103:40];
   assign next_tx_descr_write_add_q14  = nxt_vector_dma_wr_tx_descr_q14 [103:40];
   assign next_tx_descr_write_add_q15  = nxt_vector_dma_wr_tx_descr_q15 [103:40];
   assign next_rx_descr_write_add_q1   = nxt_vector_dma_wr_rx_descr_q1 [103:40];
   assign next_rx_descr_write_add_q2   = nxt_vector_dma_wr_rx_descr_q2 [103:40];
   assign next_rx_descr_write_add_q3   = nxt_vector_dma_wr_rx_descr_q3 [103:40];
   assign next_rx_descr_write_add_q4   = nxt_vector_dma_wr_rx_descr_q4 [103:40];
   assign next_rx_descr_write_add_q5   = nxt_vector_dma_wr_rx_descr_q5 [103:40];
   assign next_rx_descr_write_add_q6   = nxt_vector_dma_wr_rx_descr_q6 [103:40];
   assign next_rx_descr_write_add_q7   = nxt_vector_dma_wr_rx_descr_q7 [103:40];
   assign next_rx_descr_write_add_q8   = nxt_vector_dma_wr_rx_descr_q8 [103:40];
   assign next_rx_descr_write_add_q9   = nxt_vector_dma_wr_rx_descr_q9 [103:40];
   assign next_rx_descr_write_add_q10  = nxt_vector_dma_wr_rx_descr_q10 [103:40];
   assign next_rx_descr_write_add_q11  = nxt_vector_dma_wr_rx_descr_q11 [103:40];
   assign next_rx_descr_write_add_q12  = nxt_vector_dma_wr_rx_descr_q12 [103:40];
   assign next_rx_descr_write_add_q13  = nxt_vector_dma_wr_rx_descr_q13 [103:40];
   assign next_rx_descr_write_add_q14  = nxt_vector_dma_wr_rx_descr_q14 [103:40];
   assign next_rx_descr_write_add_q15  = nxt_vector_dma_wr_rx_descr_q15 [103:40];
   assign next_rx_data_write_add_q1    = nxt_vector_dma_wr_rx_data_q1 [103:40];
   assign next_rx_data_write_add_q2    = nxt_vector_dma_wr_rx_data_q2 [103:40];
   assign next_rx_data_write_add_q3    = nxt_vector_dma_wr_rx_data_q3 [103:40];
   assign next_rx_data_write_add_q4    = nxt_vector_dma_wr_rx_data_q4 [103:40];
   assign next_rx_data_write_add_q5    = nxt_vector_dma_wr_rx_data_q5 [103:40];
   assign next_rx_data_write_add_q6    = nxt_vector_dma_wr_rx_data_q6 [103:40];
   assign next_rx_data_write_add_q7    = nxt_vector_dma_wr_rx_data_q7 [103:40];
   assign next_rx_data_write_add_q8    = nxt_vector_dma_wr_rx_data_q8 [103:40];
   assign next_rx_data_write_add_q9    = nxt_vector_dma_wr_rx_data_q9 [103:40];
   assign next_rx_data_write_add_q10   = nxt_vector_dma_wr_rx_data_q10 [103:40];
   assign next_rx_data_write_add_q11   = nxt_vector_dma_wr_rx_data_q11 [103:40];
   assign next_rx_data_write_add_q12   = nxt_vector_dma_wr_rx_data_q12 [103:40];
   assign next_rx_data_write_add_q13   = nxt_vector_dma_wr_rx_data_q13 [103:40];
   assign next_rx_data_write_add_q14   = nxt_vector_dma_wr_rx_data_q14 [103:40];
   assign next_rx_data_write_add_q15   = nxt_vector_dma_wr_rx_data_q15 [103:40];
   `endif


   assign using_q0_rx_data_wr       = valid_dw_access & w_burst_ptr == 0    ? (awaddr_data_cmp == next_rx_data_write_add_q0)                              : using_q0_rx_data_wr;
   assign using_q0_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0    ? (~using_q0_rx_data_wr & (awaddr_data_cmp == next_tx_descr_write_add_q0))      : using_q0_tx_descr_wr;
   assign using_q0_rx_descr_wr         = valid_dw_access & w_burst_ptr == 0 ? (~using_q0_rx_data_wr & (awaddr_data_cmp == next_rx_descr_write_add_q0)) : using_q0_rx_descr_wr;
   `ifdef dma_priority_queue1
   assign using_q1_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q1) : using_q1_tx_descr_wr;
   assign using_q2_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q2) : using_q2_tx_descr_wr;
   assign using_q3_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q3) : using_q3_tx_descr_wr;
   assign using_q4_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q4) : using_q4_tx_descr_wr;
   assign using_q5_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q5) : using_q5_tx_descr_wr;
   assign using_q6_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q6) : using_q6_tx_descr_wr;
   assign using_q7_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q7) : using_q7_tx_descr_wr;
   assign using_q8_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q8) : using_q8_tx_descr_wr;
   assign using_q9_tx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q9) : using_q9_tx_descr_wr;
   assign using_q10_tx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q10) : using_q10_tx_descr_wr;
   assign using_q11_tx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q11) : using_q11_tx_descr_wr;
   assign using_q12_tx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q12) : using_q12_tx_descr_wr;
   assign using_q13_tx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q13) : using_q13_tx_descr_wr;
   assign using_q14_tx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q14) : using_q14_tx_descr_wr;
   assign using_q15_tx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_tx_descr_write_add_q15) : using_q15_tx_descr_wr;
   assign using_q1_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q1) : using_q1_rx_descr_wr;
   assign using_q2_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q2) : using_q2_rx_descr_wr;
   assign using_q3_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q3) : using_q3_rx_descr_wr;
   assign using_q4_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q4) : using_q4_rx_descr_wr;
   assign using_q5_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q5) : using_q5_rx_descr_wr;
   assign using_q6_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q6) : using_q6_rx_descr_wr;
   assign using_q7_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q7) : using_q7_rx_descr_wr;
   assign using_q8_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q8) : using_q8_rx_descr_wr;
   assign using_q9_rx_descr_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q9) : using_q9_rx_descr_wr;
   assign using_q10_rx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q10) : using_q10_rx_descr_wr;
   assign using_q11_rx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q11) : using_q11_rx_descr_wr;
   assign using_q12_rx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q12) : using_q12_rx_descr_wr;
   assign using_q13_rx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q13) : using_q13_rx_descr_wr;
   assign using_q14_rx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q14) : using_q14_rx_descr_wr;
   assign using_q15_rx_descr_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_descr_write_add_q15) : using_q15_rx_descr_wr;
   assign using_q1_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q1) : using_q1_rx_data_wr;
   assign using_q2_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q2) : using_q2_rx_data_wr;
   assign using_q3_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q3) : using_q3_rx_data_wr;
   assign using_q4_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q4) : using_q4_rx_data_wr;
   assign using_q5_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q5) : using_q5_rx_data_wr;
   assign using_q6_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q6) : using_q6_rx_data_wr;
   assign using_q7_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q7) : using_q7_rx_data_wr;
   assign using_q8_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q8) : using_q8_rx_data_wr;
   assign using_q9_rx_data_wr      = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q9) : using_q9_rx_data_wr;
   assign using_q10_rx_data_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q10) : using_q10_rx_data_wr;
   assign using_q11_rx_data_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q11) : using_q11_rx_data_wr;
   assign using_q12_rx_data_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q12) : using_q12_rx_data_wr;
   assign using_q13_rx_data_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q13) : using_q13_rx_data_wr;
   assign using_q14_rx_data_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q14) : using_q14_rx_data_wr;
   assign using_q15_rx_data_wr     = valid_dw_access & w_burst_ptr == 0 ? (awaddr_data_cmp == next_rx_data_write_add_q15) : using_q15_rx_data_wr;
   `endif
   assign qos_correct_wr      = using_q0_tx_descr_wr | using_q0_rx_descr_wr ? awqos_data == apb_qos_for_axi[7:4]:
   `ifdef dma_priority_queue1
                                using_q1_rx_data_wr                         ? awqos_data == apb_qos_for_axi[11:8]:
                                using_q2_rx_data_wr                         ? awqos_data == apb_qos_for_axi[19:16] :
                                using_q3_rx_data_wr                         ? awqos_data == apb_qos_for_axi[27:24]:
                                using_q4_rx_data_wr                         ? awqos_data == apb_qos_for_axi[35:32] :
                                using_q5_rx_data_wr                         ? awqos_data == apb_qos_for_axi[43:40]:
                                using_q6_rx_data_wr                         ? awqos_data == apb_qos_for_axi[51:48] :
                                using_q7_rx_data_wr                         ? awqos_data == apb_qos_for_axi[59:56]:
                                using_q8_rx_data_wr                         ? awqos_data == apb_qos_for_axi[67:64] :
                                using_q9_rx_data_wr                         ? awqos_data == apb_qos_for_axi[75:72]:
                                using_q10_rx_data_wr                        ? awqos_data == apb_qos_for_axi[83:80] :
                                using_q11_rx_data_wr                        ? awqos_data == apb_qos_for_axi[91:88]:
                                using_q12_rx_data_wr                        ? awqos_data == apb_qos_for_axi[99:96] :
                                using_q13_rx_data_wr                        ? awqos_data == apb_qos_for_axi[107:104]:
                                using_q14_rx_data_wr                        ? awqos_data == apb_qos_for_axi[115:112] :
                                using_q15_rx_data_wr                        ? awqos_data == apb_qos_for_axi[123:120]:
                               using_q1_tx_descr_wr | using_q1_rx_descr_wr    ? awqos_data == apb_qos_for_axi[15:12]:
                               using_q2_tx_descr_wr | using_q2_rx_descr_wr    ? awqos_data == apb_qos_for_axi[23:20] :
                               using_q3_tx_descr_wr | using_q3_rx_descr_wr    ? awqos_data == apb_qos_for_axi[31:28]:
                               using_q4_tx_descr_wr | using_q4_rx_descr_wr    ? awqos_data == apb_qos_for_axi[39:36] :
                               using_q5_tx_descr_wr | using_q5_rx_descr_wr    ? awqos_data == apb_qos_for_axi[47:44]:
                               using_q6_tx_descr_wr | using_q6_rx_descr_wr    ? awqos_data == apb_qos_for_axi[55:52] :
                               using_q7_tx_descr_wr | using_q7_rx_descr_wr    ? awqos_data == apb_qos_for_axi[63:60]:
                               using_q8_tx_descr_wr | using_q8_rx_descr_wr    ? awqos_data == apb_qos_for_axi[71:68] :
                               using_q9_tx_descr_wr | using_q9_rx_descr_wr    ? awqos_data == apb_qos_for_axi[79:76]:
                               using_q10_tx_descr_wr| using_q10_rx_descr_wr   ? awqos_data == apb_qos_for_axi[87:84] :
                               using_q11_tx_descr_wr| using_q11_rx_descr_wr   ? awqos_data == apb_qos_for_axi[95:92]:
                               using_q12_tx_descr_wr| using_q12_rx_descr_wr   ? awqos_data == apb_qos_for_axi[103:100] :
                               using_q13_tx_descr_wr| using_q13_rx_descr_wr   ? awqos_data == apb_qos_for_axi[111:108]:
                               using_q14_tx_descr_wr| using_q14_rx_descr_wr   ? awqos_data == apb_qos_for_axi[119:116] :
                               using_q15_tx_descr_wr| using_q15_rx_descr_wr   ? awqos_data == apb_qos_for_axi[127:124]:
   `endif
                                                                                awqos_data == apb_qos_for_axi[3:0] ;


   assign next_write_add       = using_q0_tx_descr_wr   ? next_tx_descr_write_add_q0 :
                                 using_q0_rx_descr_wr   ? next_rx_descr_write_add_q0
   `ifdef dma_priority_queue1
                               : using_q1_tx_descr_wr   ? next_tx_descr_write_add_q1
                               : using_q2_tx_descr_wr   ? next_tx_descr_write_add_q2
                               : using_q3_tx_descr_wr   ? next_tx_descr_write_add_q3
                               : using_q4_tx_descr_wr   ? next_tx_descr_write_add_q4
                               : using_q5_tx_descr_wr   ? next_tx_descr_write_add_q5
                               : using_q6_tx_descr_wr   ? next_tx_descr_write_add_q6
                               : using_q7_tx_descr_wr   ? next_tx_descr_write_add_q7
                               : using_q8_tx_descr_wr   ? next_tx_descr_write_add_q8
                               : using_q9_tx_descr_wr   ? next_tx_descr_write_add_q9
                               : using_q10_tx_descr_wr  ? next_tx_descr_write_add_q10
                               : using_q11_tx_descr_wr  ? next_tx_descr_write_add_q11
                               : using_q12_tx_descr_wr  ? next_tx_descr_write_add_q12
                               : using_q13_tx_descr_wr  ? next_tx_descr_write_add_q13
                               : using_q14_tx_descr_wr  ? next_tx_descr_write_add_q14
                               : using_q15_tx_descr_wr  ? next_tx_descr_write_add_q15
                               : using_q1_rx_descr_wr   ? next_rx_descr_write_add_q1
                               : using_q2_rx_descr_wr   ? next_rx_descr_write_add_q2
                               : using_q3_rx_descr_wr   ? next_rx_descr_write_add_q3
                               : using_q4_rx_descr_wr   ? next_rx_descr_write_add_q4
                               : using_q5_rx_descr_wr   ? next_rx_descr_write_add_q5
                               : using_q6_rx_descr_wr   ? next_rx_descr_write_add_q6
                               : using_q7_rx_descr_wr   ? next_rx_descr_write_add_q7
                               : using_q8_rx_descr_wr   ? next_rx_descr_write_add_q8
                               : using_q9_rx_descr_wr   ? next_rx_descr_write_add_q9
                               : using_q10_rx_descr_wr  ? next_rx_descr_write_add_q10
                               : using_q11_rx_descr_wr  ? next_rx_descr_write_add_q11
                               : using_q12_rx_descr_wr  ? next_rx_descr_write_add_q12
                               : using_q13_rx_descr_wr  ? next_rx_descr_write_add_q13
                               : using_q14_rx_descr_wr  ? next_rx_descr_write_add_q14
                               : using_q15_rx_descr_wr  ? next_rx_descr_write_add_q15
                               : using_q1_rx_data_wr   ? next_rx_data_write_add_q1
                               : using_q2_rx_data_wr   ? next_rx_data_write_add_q2
                               : using_q3_rx_data_wr   ? next_rx_data_write_add_q3
                               : using_q4_rx_data_wr   ? next_rx_data_write_add_q4
                               : using_q5_rx_data_wr   ? next_rx_data_write_add_q5
                               : using_q6_rx_data_wr   ? next_rx_data_write_add_q6
                               : using_q7_rx_data_wr   ? next_rx_data_write_add_q7
                               : using_q8_rx_data_wr   ? next_rx_data_write_add_q8
                               : using_q9_rx_data_wr   ? next_rx_data_write_add_q9
                               : using_q10_rx_data_wr  ? next_rx_data_write_add_q10
                               : using_q11_rx_data_wr  ? next_rx_data_write_add_q11
                               : using_q12_rx_data_wr  ? next_rx_data_write_add_q12
                               : using_q13_rx_data_wr  ? next_rx_data_write_add_q13
                               : using_q14_rx_data_wr  ? next_rx_data_write_add_q14
                               : using_q15_rx_data_wr  ? next_rx_data_write_add_q15
   `endif
                                                       : next_rx_data_write_add_q0;

   // decode current vector values
   assign dma_wr_vector_plus0 = using_q0_tx_descr_wr        ? dma_wr_tx_descr_q0[next_index_dma_wr_tx_descr_q0] :
                                using_q0_rx_descr_wr        ? dma_rx_wr_descr_q0[next_index_dma_wr_rx_descr_q0] :
                                `ifdef dma_priority_queue1
                                using_q1_tx_descr_wr        ? dma_wr_tx_descr_q1[next_index_dma_wr_tx_descr_q1] :
                                using_q2_tx_descr_wr        ? dma_wr_tx_descr_q2[next_index_dma_wr_tx_descr_q2] :
                                using_q3_tx_descr_wr        ? dma_wr_tx_descr_q3[next_index_dma_wr_tx_descr_q3] :
                                using_q4_tx_descr_wr        ? dma_wr_tx_descr_q4[next_index_dma_wr_tx_descr_q4] :
                                using_q5_tx_descr_wr        ? dma_wr_tx_descr_q5[next_index_dma_wr_tx_descr_q5] :
                                using_q6_tx_descr_wr        ? dma_wr_tx_descr_q6[next_index_dma_wr_tx_descr_q6] :
                                using_q7_tx_descr_wr        ? dma_wr_tx_descr_q7[next_index_dma_wr_tx_descr_q7] :
                                using_q8_tx_descr_wr        ? dma_wr_tx_descr_q8[next_index_dma_wr_tx_descr_q8] :
                                using_q9_tx_descr_wr        ? dma_wr_tx_descr_q9[next_index_dma_wr_tx_descr_q9] :
                                using_q10_tx_descr_wr       ? dma_wr_tx_descr_q10[next_index_dma_wr_tx_descr_q10] :
                                using_q11_tx_descr_wr       ? dma_wr_tx_descr_q11[next_index_dma_wr_tx_descr_q11] :
                                using_q12_tx_descr_wr       ? dma_wr_tx_descr_q12[next_index_dma_wr_tx_descr_q12] :
                                using_q13_tx_descr_wr       ? dma_wr_tx_descr_q13[next_index_dma_wr_tx_descr_q13] :
                                using_q14_tx_descr_wr       ? dma_wr_tx_descr_q14[next_index_dma_wr_tx_descr_q14] :
                                using_q15_tx_descr_wr       ? dma_wr_tx_descr_q15[next_index_dma_wr_tx_descr_q15] :
                                using_q1_rx_descr_wr        ? dma_wr_rx_descr_q1[next_index_dma_wr_rx_descr_q1] :
                                using_q2_rx_descr_wr        ? dma_wr_rx_descr_q2[next_index_dma_wr_rx_descr_q2] :
                                using_q3_rx_descr_wr        ? dma_wr_rx_descr_q3[next_index_dma_wr_rx_descr_q3] :
                                using_q4_rx_descr_wr        ? dma_wr_rx_descr_q4[next_index_dma_wr_rx_descr_q4] :
                                using_q5_rx_descr_wr        ? dma_wr_rx_descr_q5[next_index_dma_wr_rx_descr_q5] :
                                using_q6_rx_descr_wr        ? dma_wr_rx_descr_q6[next_index_dma_wr_rx_descr_q6] :
                                using_q7_rx_descr_wr        ? dma_wr_rx_descr_q7[next_index_dma_wr_rx_descr_q7] :
                                using_q8_rx_descr_wr        ? dma_wr_rx_descr_q8[next_index_dma_wr_rx_descr_q8] :
                                using_q9_rx_descr_wr        ? dma_wr_rx_descr_q9[next_index_dma_wr_rx_descr_q9] :
                                using_q10_rx_descr_wr       ? dma_wr_rx_descr_q10[next_index_dma_wr_rx_descr_q10] :
                                using_q11_rx_descr_wr       ? dma_wr_rx_descr_q11[next_index_dma_wr_rx_descr_q11] :
                                using_q12_rx_descr_wr       ? dma_wr_rx_descr_q12[next_index_dma_wr_rx_descr_q12] :
                                using_q13_rx_descr_wr       ? dma_wr_rx_descr_q13[next_index_dma_wr_rx_descr_q13] :
                                using_q14_rx_descr_wr       ? dma_wr_rx_descr_q14[next_index_dma_wr_rx_descr_q14] :
                                using_q15_rx_descr_wr       ? dma_wr_rx_descr_q15[next_index_dma_wr_rx_descr_q15] :
                                using_q1_rx_data_wr        ? dma_wr_rx_data_q1[next_index_dma_wr_rx_data_q1] :
                                using_q2_rx_data_wr        ? dma_wr_rx_data_q2[next_index_dma_wr_rx_data_q2] :
                                using_q3_rx_data_wr        ? dma_wr_rx_data_q3[next_index_dma_wr_rx_data_q3] :
                                using_q4_rx_data_wr        ? dma_wr_rx_data_q4[next_index_dma_wr_rx_data_q4] :
                                using_q5_rx_data_wr        ? dma_wr_rx_data_q5[next_index_dma_wr_rx_data_q5] :
                                using_q6_rx_data_wr        ? dma_wr_rx_data_q6[next_index_dma_wr_rx_data_q6] :
                                using_q7_rx_data_wr        ? dma_wr_rx_data_q7[next_index_dma_wr_rx_data_q7] :
                                using_q8_rx_data_wr        ? dma_wr_rx_data_q8[next_index_dma_wr_rx_data_q8] :
                                using_q9_rx_data_wr        ? dma_wr_rx_data_q9[next_index_dma_wr_rx_data_q9] :
                                using_q10_rx_data_wr       ? dma_wr_rx_data_q10[next_index_dma_wr_rx_data_q10] :
                                using_q11_rx_data_wr       ? dma_wr_rx_data_q11[next_index_dma_wr_rx_data_q11] :
                                using_q12_rx_data_wr       ? dma_wr_rx_data_q12[next_index_dma_wr_rx_data_q12] :
                                using_q13_rx_data_wr       ? dma_wr_rx_data_q13[next_index_dma_wr_rx_data_q13] :
                                using_q14_rx_data_wr       ? dma_wr_rx_data_q14[next_index_dma_wr_rx_data_q14] :
                                using_q15_rx_data_wr       ? dma_wr_rx_data_q15[next_index_dma_wr_rx_data_q15] :
                                `endif
                                                              dma_wr_rx_data_q0[next_index_dma_wr_rx_data_q0];

   assign dma_wr_vector_plus1 = using_q0_tx_descr_wr        ? dma_wr_tx_descr_q0[next_index_dma_wr_tx_descr_q0 + 1]  :
                                using_q0_rx_descr_wr        ? dma_rx_wr_descr_q0[next_index_dma_wr_rx_descr_q0 + 1] :
                                `ifdef dma_priority_queue1
                                using_q1_tx_descr_wr        ? dma_wr_tx_descr_q1[next_index_dma_wr_tx_descr_q1+1] :
                                using_q2_tx_descr_wr        ? dma_wr_tx_descr_q2[next_index_dma_wr_tx_descr_q2+1] :
                                using_q3_tx_descr_wr        ? dma_wr_tx_descr_q3[next_index_dma_wr_tx_descr_q3+1] :
                                using_q4_tx_descr_wr        ? dma_wr_tx_descr_q4[next_index_dma_wr_tx_descr_q4+1] :
                                using_q5_tx_descr_wr        ? dma_wr_tx_descr_q5[next_index_dma_wr_tx_descr_q5+1] :
                                using_q6_tx_descr_wr        ? dma_wr_tx_descr_q6[next_index_dma_wr_tx_descr_q6+1] :
                                using_q7_tx_descr_wr        ? dma_wr_tx_descr_q7[next_index_dma_wr_tx_descr_q7+1] :
                                using_q8_tx_descr_wr        ? dma_wr_tx_descr_q8[next_index_dma_wr_tx_descr_q8+1] :
                                using_q9_tx_descr_wr        ? dma_wr_tx_descr_q9[next_index_dma_wr_tx_descr_q9+1] :
                                using_q10_tx_descr_wr       ? dma_wr_tx_descr_q10[next_index_dma_wr_tx_descr_q10+1] :
                                using_q11_tx_descr_wr       ? dma_wr_tx_descr_q11[next_index_dma_wr_tx_descr_q11+1] :
                                using_q12_tx_descr_wr       ? dma_wr_tx_descr_q12[next_index_dma_wr_tx_descr_q12+1] :
                                using_q13_tx_descr_wr       ? dma_wr_tx_descr_q13[next_index_dma_wr_tx_descr_q13+1] :
                                using_q14_tx_descr_wr       ? dma_wr_tx_descr_q14[next_index_dma_wr_tx_descr_q14+1] :
                                using_q15_tx_descr_wr       ? dma_wr_tx_descr_q15[next_index_dma_wr_tx_descr_q15+1] :
                                using_q1_rx_descr_wr        ? dma_wr_rx_descr_q1[next_index_dma_wr_rx_descr_q1+1] :
                                using_q2_rx_descr_wr        ? dma_wr_rx_descr_q2[next_index_dma_wr_rx_descr_q2+1] :
                                using_q3_rx_descr_wr        ? dma_wr_rx_descr_q3[next_index_dma_wr_rx_descr_q3+1] :
                                using_q4_rx_descr_wr        ? dma_wr_rx_descr_q4[next_index_dma_wr_rx_descr_q4+1] :
                                using_q5_rx_descr_wr        ? dma_wr_rx_descr_q5[next_index_dma_wr_rx_descr_q5+1] :
                                using_q6_rx_descr_wr        ? dma_wr_rx_descr_q6[next_index_dma_wr_rx_descr_q6+1] :
                                using_q7_rx_descr_wr        ? dma_wr_rx_descr_q7[next_index_dma_wr_rx_descr_q7+1] :
                                using_q8_rx_descr_wr        ? dma_wr_rx_descr_q8[next_index_dma_wr_rx_descr_q8+1] :
                                using_q9_rx_descr_wr        ? dma_wr_rx_descr_q9[next_index_dma_wr_rx_descr_q9+1] :
                                using_q10_rx_descr_wr       ? dma_wr_rx_descr_q10[next_index_dma_wr_rx_descr_q10+1] :
                                using_q11_rx_descr_wr       ? dma_wr_rx_descr_q11[next_index_dma_wr_rx_descr_q11+1] :
                                using_q12_rx_descr_wr       ? dma_wr_rx_descr_q12[next_index_dma_wr_rx_descr_q12+1] :
                                using_q13_rx_descr_wr       ? dma_wr_rx_descr_q13[next_index_dma_wr_rx_descr_q13+1] :
                                using_q14_rx_descr_wr       ? dma_wr_rx_descr_q14[next_index_dma_wr_rx_descr_q14+1] :
                                using_q15_rx_descr_wr       ? dma_wr_rx_descr_q15[next_index_dma_wr_rx_descr_q15+1] :
                                using_q1_rx_data_wr        ? dma_wr_rx_data_q1[next_index_dma_wr_rx_data_q1+1] :
                                using_q2_rx_data_wr        ? dma_wr_rx_data_q2[next_index_dma_wr_rx_data_q2+1] :
                                using_q3_rx_data_wr        ? dma_wr_rx_data_q3[next_index_dma_wr_rx_data_q3+1] :
                                using_q4_rx_data_wr        ? dma_wr_rx_data_q4[next_index_dma_wr_rx_data_q4+1] :
                                using_q5_rx_data_wr        ? dma_wr_rx_data_q5[next_index_dma_wr_rx_data_q5+1] :
                                using_q6_rx_data_wr        ? dma_wr_rx_data_q6[next_index_dma_wr_rx_data_q6+1] :
                                using_q7_rx_data_wr        ? dma_wr_rx_data_q7[next_index_dma_wr_rx_data_q7+1] :
                                using_q8_rx_data_wr        ? dma_wr_rx_data_q8[next_index_dma_wr_rx_data_q8+1] :
                                using_q9_rx_data_wr        ? dma_wr_rx_data_q9[next_index_dma_wr_rx_data_q9+1] :
                                using_q10_rx_data_wr       ? dma_wr_rx_data_q10[next_index_dma_wr_rx_data_q10+1] :
                                using_q11_rx_data_wr       ? dma_wr_rx_data_q11[next_index_dma_wr_rx_data_q11+1] :
                                using_q12_rx_data_wr       ? dma_wr_rx_data_q12[next_index_dma_wr_rx_data_q12+1] :
                                using_q13_rx_data_wr       ? dma_wr_rx_data_q13[next_index_dma_wr_rx_data_q13+1] :
                                using_q14_rx_data_wr       ? dma_wr_rx_data_q14[next_index_dma_wr_rx_data_q14+1] :
                                using_q15_rx_data_wr       ? dma_wr_rx_data_q15[next_index_dma_wr_rx_data_q15+1] :
                                `endif
                                                              dma_wr_rx_data_q0[next_index_dma_wr_rx_data_q0 + 1];
   assign dma_wr_vector_plus2 = using_q0_tx_descr_wr        ? dma_wr_tx_descr_q0[next_index_dma_wr_tx_descr_q0 + 2]  :
                                using_q0_rx_descr_wr           ? dma_rx_wr_descr_q0[next_index_dma_wr_rx_descr_q0 + 2] :
                                `ifdef dma_priority_queue1
                                using_q1_tx_descr_wr        ? dma_wr_tx_descr_q1[next_index_dma_wr_tx_descr_q1+2] :
                                using_q2_tx_descr_wr        ? dma_wr_tx_descr_q2[next_index_dma_wr_tx_descr_q2+2] :
                                using_q3_tx_descr_wr        ? dma_wr_tx_descr_q3[next_index_dma_wr_tx_descr_q3+2] :
                                using_q4_tx_descr_wr        ? dma_wr_tx_descr_q4[next_index_dma_wr_tx_descr_q4+2] :
                                using_q5_tx_descr_wr        ? dma_wr_tx_descr_q5[next_index_dma_wr_tx_descr_q5+2] :
                                using_q6_tx_descr_wr        ? dma_wr_tx_descr_q6[next_index_dma_wr_tx_descr_q6+2] :
                                using_q7_tx_descr_wr        ? dma_wr_tx_descr_q7[next_index_dma_wr_tx_descr_q7+2] :
                                using_q8_tx_descr_wr        ? dma_wr_tx_descr_q8[next_index_dma_wr_tx_descr_q8+2] :
                                using_q9_tx_descr_wr        ? dma_wr_tx_descr_q9[next_index_dma_wr_tx_descr_q9+2] :
                                using_q10_tx_descr_wr       ? dma_wr_tx_descr_q10[next_index_dma_wr_tx_descr_q10+2] :
                                using_q11_tx_descr_wr       ? dma_wr_tx_descr_q11[next_index_dma_wr_tx_descr_q11+2] :
                                using_q12_tx_descr_wr       ? dma_wr_tx_descr_q12[next_index_dma_wr_tx_descr_q12+2] :
                                using_q13_tx_descr_wr       ? dma_wr_tx_descr_q13[next_index_dma_wr_tx_descr_q13+2] :
                                using_q14_tx_descr_wr       ? dma_wr_tx_descr_q14[next_index_dma_wr_tx_descr_q14+2] :
                                using_q15_tx_descr_wr       ? dma_wr_tx_descr_q15[next_index_dma_wr_tx_descr_q15+2] :
                                using_q1_rx_descr_wr        ? dma_wr_rx_descr_q1[next_index_dma_wr_rx_descr_q1+2] :
                                using_q2_rx_descr_wr        ? dma_wr_rx_descr_q2[next_index_dma_wr_rx_descr_q2+2] :
                                using_q3_rx_descr_wr        ? dma_wr_rx_descr_q3[next_index_dma_wr_rx_descr_q3+2] :
                                using_q4_rx_descr_wr        ? dma_wr_rx_descr_q4[next_index_dma_wr_rx_descr_q4+2] :
                                using_q5_rx_descr_wr        ? dma_wr_rx_descr_q5[next_index_dma_wr_rx_descr_q5+2] :
                                using_q6_rx_descr_wr        ? dma_wr_rx_descr_q6[next_index_dma_wr_rx_descr_q6+2] :
                                using_q7_rx_descr_wr        ? dma_wr_rx_descr_q7[next_index_dma_wr_rx_descr_q7+2] :
                                using_q8_rx_descr_wr        ? dma_wr_rx_descr_q8[next_index_dma_wr_rx_descr_q8+2] :
                                using_q9_rx_descr_wr        ? dma_wr_rx_descr_q9[next_index_dma_wr_rx_descr_q9+2] :
                                using_q10_rx_descr_wr       ? dma_wr_rx_descr_q10[next_index_dma_wr_rx_descr_q10+2] :
                                using_q11_rx_descr_wr       ? dma_wr_rx_descr_q11[next_index_dma_wr_rx_descr_q11+2] :
                                using_q12_rx_descr_wr       ? dma_wr_rx_descr_q12[next_index_dma_wr_rx_descr_q12+2] :
                                using_q13_rx_descr_wr       ? dma_wr_rx_descr_q13[next_index_dma_wr_rx_descr_q13+2] :
                                using_q14_rx_descr_wr       ? dma_wr_rx_descr_q14[next_index_dma_wr_rx_descr_q14+2] :
                                using_q15_rx_descr_wr       ? dma_wr_rx_descr_q15[next_index_dma_wr_rx_descr_q15+2] :
                                using_q1_rx_data_wr        ? dma_wr_rx_data_q1[next_index_dma_wr_rx_data_q1+2] :
                                using_q2_rx_data_wr        ? dma_wr_rx_data_q2[next_index_dma_wr_rx_data_q2+2] :
                                using_q3_rx_data_wr        ? dma_wr_rx_data_q3[next_index_dma_wr_rx_data_q3+2] :
                                using_q4_rx_data_wr        ? dma_wr_rx_data_q4[next_index_dma_wr_rx_data_q4+2] :
                                using_q5_rx_data_wr        ? dma_wr_rx_data_q5[next_index_dma_wr_rx_data_q5+2] :
                                using_q6_rx_data_wr        ? dma_wr_rx_data_q6[next_index_dma_wr_rx_data_q6+2] :
                                using_q7_rx_data_wr        ? dma_wr_rx_data_q7[next_index_dma_wr_rx_data_q7+2] :
                                using_q8_rx_data_wr        ? dma_wr_rx_data_q8[next_index_dma_wr_rx_data_q8+2] :
                                using_q9_rx_data_wr        ? dma_wr_rx_data_q9[next_index_dma_wr_rx_data_q9+2] :
                                using_q10_rx_data_wr       ? dma_wr_rx_data_q10[next_index_dma_wr_rx_data_q10+2] :
                                using_q11_rx_data_wr       ? dma_wr_rx_data_q11[next_index_dma_wr_rx_data_q11+2] :
                                using_q12_rx_data_wr       ? dma_wr_rx_data_q12[next_index_dma_wr_rx_data_q12+2] :
                                using_q13_rx_data_wr       ? dma_wr_rx_data_q13[next_index_dma_wr_rx_data_q13+2] :
                                using_q14_rx_data_wr       ? dma_wr_rx_data_q14[next_index_dma_wr_rx_data_q14+2] :
                                using_q15_rx_data_wr       ? dma_wr_rx_data_q15[next_index_dma_wr_rx_data_q15+2] :
                                `endif
                                                              dma_wr_rx_data_q0[next_index_dma_wr_rx_data_q0 + 2];
   assign dma_wr_vector_plus3 = using_q0_tx_descr_wr ? dma_wr_tx_descr_q0[next_index_dma_wr_tx_descr_q0 + 3]  :
                                using_q0_rx_descr_wr ? dma_rx_wr_descr_q0[next_index_dma_wr_rx_descr_q0 + 3] :
                                `ifdef dma_priority_queue1
                                using_q1_tx_descr_wr        ? dma_wr_tx_descr_q1[next_index_dma_wr_tx_descr_q1+3] :
                                using_q2_tx_descr_wr        ? dma_wr_tx_descr_q2[next_index_dma_wr_tx_descr_q2+3] :
                                using_q3_tx_descr_wr        ? dma_wr_tx_descr_q3[next_index_dma_wr_tx_descr_q3+3] :
                                using_q4_tx_descr_wr        ? dma_wr_tx_descr_q4[next_index_dma_wr_tx_descr_q4+3] :
                                using_q5_tx_descr_wr        ? dma_wr_tx_descr_q5[next_index_dma_wr_tx_descr_q5+3] :
                                using_q6_tx_descr_wr        ? dma_wr_tx_descr_q6[next_index_dma_wr_tx_descr_q6+3] :
                                using_q7_tx_descr_wr        ? dma_wr_tx_descr_q7[next_index_dma_wr_tx_descr_q7+3] :
                                using_q8_tx_descr_wr        ? dma_wr_tx_descr_q8[next_index_dma_wr_tx_descr_q8+3] :
                                using_q9_tx_descr_wr        ? dma_wr_tx_descr_q9[next_index_dma_wr_tx_descr_q9+3] :
                                using_q10_tx_descr_wr       ? dma_wr_tx_descr_q10[next_index_dma_wr_tx_descr_q10+3] :
                                using_q11_tx_descr_wr       ? dma_wr_tx_descr_q11[next_index_dma_wr_tx_descr_q11+3] :
                                using_q12_tx_descr_wr       ? dma_wr_tx_descr_q12[next_index_dma_wr_tx_descr_q12+3] :
                                using_q13_tx_descr_wr       ? dma_wr_tx_descr_q13[next_index_dma_wr_tx_descr_q13+3] :
                                using_q14_tx_descr_wr       ? dma_wr_tx_descr_q14[next_index_dma_wr_tx_descr_q14+3] :
                                using_q15_tx_descr_wr       ? dma_wr_tx_descr_q15[next_index_dma_wr_tx_descr_q15+3] :
                                using_q1_rx_descr_wr        ? dma_wr_rx_descr_q1[next_index_dma_wr_rx_descr_q1+3] :
                                using_q2_rx_descr_wr        ? dma_wr_rx_descr_q2[next_index_dma_wr_rx_descr_q2+3] :
                                using_q3_rx_descr_wr        ? dma_wr_rx_descr_q3[next_index_dma_wr_rx_descr_q3+3] :
                                using_q4_rx_descr_wr        ? dma_wr_rx_descr_q4[next_index_dma_wr_rx_descr_q4+3] :
                                using_q5_rx_descr_wr        ? dma_wr_rx_descr_q5[next_index_dma_wr_rx_descr_q5+3] :
                                using_q6_rx_descr_wr        ? dma_wr_rx_descr_q6[next_index_dma_wr_rx_descr_q6+3] :
                                using_q7_rx_descr_wr        ? dma_wr_rx_descr_q7[next_index_dma_wr_rx_descr_q7+3] :
                                using_q8_rx_descr_wr        ? dma_wr_rx_descr_q8[next_index_dma_wr_rx_descr_q8+3] :
                                using_q9_rx_descr_wr        ? dma_wr_rx_descr_q9[next_index_dma_wr_rx_descr_q9+3] :
                                using_q10_rx_descr_wr       ? dma_wr_rx_descr_q10[next_index_dma_wr_rx_descr_q10+3] :
                                using_q11_rx_descr_wr       ? dma_wr_rx_descr_q11[next_index_dma_wr_rx_descr_q11+3] :
                                using_q12_rx_descr_wr       ? dma_wr_rx_descr_q12[next_index_dma_wr_rx_descr_q12+3] :
                                using_q13_rx_descr_wr       ? dma_wr_rx_descr_q13[next_index_dma_wr_rx_descr_q13+3] :
                                using_q14_rx_descr_wr       ? dma_wr_rx_descr_q14[next_index_dma_wr_rx_descr_q14+3] :
                                using_q15_rx_descr_wr       ? dma_wr_rx_descr_q15[next_index_dma_wr_rx_descr_q15+3] :
                                using_q1_rx_data_wr        ? dma_wr_rx_data_q1[next_index_dma_wr_rx_data_q1+3] :
                                using_q2_rx_data_wr        ? dma_wr_rx_data_q2[next_index_dma_wr_rx_data_q2+3] :
                                using_q3_rx_data_wr        ? dma_wr_rx_data_q3[next_index_dma_wr_rx_data_q3+3] :
                                using_q4_rx_data_wr        ? dma_wr_rx_data_q4[next_index_dma_wr_rx_data_q4+3] :
                                using_q5_rx_data_wr        ? dma_wr_rx_data_q5[next_index_dma_wr_rx_data_q5+3] :
                                using_q6_rx_data_wr        ? dma_wr_rx_data_q6[next_index_dma_wr_rx_data_q6+3] :
                                using_q7_rx_data_wr        ? dma_wr_rx_data_q7[next_index_dma_wr_rx_data_q7+3] :
                                using_q8_rx_data_wr        ? dma_wr_rx_data_q8[next_index_dma_wr_rx_data_q8+3] :
                                using_q9_rx_data_wr        ? dma_wr_rx_data_q9[next_index_dma_wr_rx_data_q9+3] :
                                using_q10_rx_data_wr       ? dma_wr_rx_data_q10[next_index_dma_wr_rx_data_q10+3] :
                                using_q11_rx_data_wr       ? dma_wr_rx_data_q11[next_index_dma_wr_rx_data_q11+3] :
                                using_q12_rx_data_wr       ? dma_wr_rx_data_q12[next_index_dma_wr_rx_data_q12+3] :
                                using_q13_rx_data_wr       ? dma_wr_rx_data_q13[next_index_dma_wr_rx_data_q13+3] :
                                using_q14_rx_data_wr       ? dma_wr_rx_data_q14[next_index_dma_wr_rx_data_q14+3] :
                                using_q15_rx_data_wr       ? dma_wr_rx_data_q15[next_index_dma_wr_rx_data_q15+3] :
                                `endif
                                                              dma_wr_rx_data_q0[next_index_dma_wr_rx_data_q0 + 3];
   assign dma_wr_tx_done      = vector_dma_wr_tx_descr_q0[106]
                                `ifdef dma_priority_queue1
                                & vector_dma_wr_tx_descr_q1[106] & vector_dma_wr_tx_descr_q2[106] & vector_dma_wr_tx_descr_q3[106] & vector_dma_wr_tx_descr_q4[106]
                                & vector_dma_wr_tx_descr_q5[106] & vector_dma_wr_tx_descr_q6[106] & vector_dma_wr_tx_descr_q7[106]
                                & vector_dma_wr_tx_descr_q8[106] & vector_dma_wr_tx_descr_q9[106] & vector_dma_wr_tx_descr_q10[106] & vector_dma_wr_tx_descr_q11[106]
                                & vector_dma_wr_tx_descr_q12[106] & vector_dma_wr_tx_descr_q13[106] & vector_dma_wr_tx_descr_q14[106] & vector_dma_wr_tx_descr_q15[106]
                                `endif
                                ;
   assign dma_wr_rx_done      = vector_dma_wr_rx_data_q0[106] & vector_dma_wr_rx_descr_q0[106]
                                `ifdef dma_priority_queue1
                                & vector_dma_wr_rx_descr_q1[106] & vector_dma_wr_rx_descr_q2[106] & vector_dma_wr_rx_descr_q3[106] & vector_dma_wr_rx_descr_q4[106]
                                & vector_dma_wr_rx_descr_q5[106] & vector_dma_wr_rx_descr_q6[106] & vector_dma_wr_rx_descr_q7[106]
                                & vector_dma_wr_rx_descr_q8[106] & vector_dma_wr_rx_descr_q9[106] & vector_dma_wr_rx_descr_q10[106] & vector_dma_wr_rx_descr_q11[106]
                                & vector_dma_wr_rx_descr_q12[106] & vector_dma_wr_rx_descr_q13[106] & vector_dma_wr_rx_descr_q14[106] & vector_dma_wr_rx_descr_q15[106]
                                & vector_dma_wr_rx_data_q1[106] & vector_dma_wr_rx_data_q2[106] & vector_dma_wr_rx_data_q3[106] & vector_dma_wr_rx_data_q4[106]
                                & vector_dma_wr_rx_data_q5[106] & vector_dma_wr_rx_data_q6[106] & vector_dma_wr_rx_data_q7[106]
                                & vector_dma_wr_rx_data_q8[106] & vector_dma_wr_rx_data_q9[106] & vector_dma_wr_rx_data_q10[106] & vector_dma_wr_rx_data_q11[106]
                                & vector_dma_wr_rx_data_q12[106] & vector_dma_wr_rx_data_q13[106] & vector_dma_wr_rx_data_q14[106] & vector_dma_wr_rx_data_q15[106]
                                `endif
                                ;
   assign dma_wr_done         = dma_wr_rx_done & dma_wr_tx_done;

  always @(*)
  begin
    case (dma_bus_width)
      2'b10, 2'b11 : // 128 bit
      begin
        if (awsize_data == 3'b010) // 32 bit access
        begin
          data_written_end_swapped[127:32] = 96'b0;
          write_en_end_swapped[15:4] = 12'h000;
          case (awaddr_data[3:2])
            2'b00 :
            begin
              if (wr_endian_swap)
              begin
                data_written_end_swapped[31:0] = {wdata[103:96],wdata[111:104],wdata[119:112],wdata[127:120]};
                write_en_end_swapped[3:0] = {wstrb[12],wstrb[13],wstrb[14],wstrb[15]};
              end
              else
              begin
                data_written_end_swapped[31:0] = wdata[31:0];
                write_en_end_swapped[3:0] = wstrb[3:0];
              end
            end
            2'b01 :
            begin
              if (wr_endian_swap)
              begin
                data_written_end_swapped[31:0] = {wdata[71:64],wdata[79:72],wdata[87:80],wdata[95:88]};
                write_en_end_swapped[3:0] = {wstrb[8],wstrb[9],wstrb[10],wstrb[11]};
              end
              else
              begin
                data_written_end_swapped[31:0] = wdata[63:32];
                write_en_end_swapped[3:0] = wstrb[7:4];
              end
            end
            2'b10 :
            begin
              if (wr_endian_swap)
              begin
                data_written_end_swapped[31:0] = {wdata[39:32],wdata[47:40],wdata[55:48],wdata[63:56]};
                write_en_end_swapped[3:0] = {wstrb[4],wstrb[5],wstrb[6],wstrb[7]};
              end
              else
              begin
                data_written_end_swapped[31:0] = wdata[95:64];
                write_en_end_swapped[3:0] = wstrb[11:8];
              end
            end
            default :
            begin
              if (wr_endian_swap)
              begin
                data_written_end_swapped[31:0] = {wdata[7:0],wdata[15:8],wdata[23:16],wdata[31:24]};
                write_en_end_swapped[3:0] = {wstrb[0],wstrb[1],wstrb[2],wstrb[3]};
              end
              else
              begin
                data_written_end_swapped[31:0] = wdata[127:96];
                write_en_end_swapped[3:0] = wstrb[15:12];
              end
            end
          endcase
        end
        else if (awsize_data == 3'b011) // 64 bit access
        begin
          data_written_end_swapped[127:64] = 64'b0;
          write_en_end_swapped[15:8]       = 8'h00;
          case (awaddr_data[3])
            1'b0 :
            begin
              if (wr_endian_swap)
              begin
                data_written_end_swapped[63:0] = {wdata[71:64],wdata[79:72],wdata[87:80],wdata[95:88],
                                                  wdata[103:96],wdata[111:104],wdata[119:112],wdata[127:120]};
                write_en_end_swapped[7:0] = {wstrb[8],wstrb[9],wstrb[10],wstrb[11],
                                             wstrb[12],wstrb[13],wstrb[14],wstrb[15]};
              end
              else
              begin
                data_written_end_swapped[63:0] = wdata[63:0];
                write_en_end_swapped[7:0] = wstrb[7:0];
              end
            end
            1'b1 :
            begin
              if (wr_endian_swap)
              begin
                data_written_end_swapped[63:0] = {wdata[7:0],wdata[15:8],wdata[23:16],wdata[31:24],
                                                  wdata[39:32],wdata[47:40],wdata[55:48],wdata[63:56]};
                write_en_end_swapped[7:0] = {wstrb[0],wstrb[1],wstrb[2],wstrb[3],
                                             wstrb[4],wstrb[5],wstrb[6],wstrb[7]};
              end
              else
              begin
                data_written_end_swapped[63:0] = wdata[127:64];
                write_en_end_swapped[7:0] = wstrb[15:8];
              end
            end
          endcase
        end

        else  // 128 bit access
        begin
          if (wr_endian_swap)
          begin
            data_written_end_swapped[127:96]  = {wdata[7:0],wdata[15:8],wdata[23:16],wdata[31:24]};
            data_written_end_swapped[95:64]   = {wdata[39:32],wdata[47:40],wdata[55:48],wdata[63:56]};
            data_written_end_swapped[63:32]   = {wdata[71:64],wdata[79:72],wdata[87:80],wdata[95:88]};
            data_written_end_swapped[31:0]    = {wdata[103:96],wdata[111:104],wdata[119:112],wdata[127:120]};
            write_en_end_swapped[15:0]        = {wstrb[0],wstrb[1],wstrb[2],wstrb[3],
                                                 wstrb[4],wstrb[5],wstrb[6],wstrb[7],
                                                 wstrb[8],wstrb[9],wstrb[10],wstrb[11],
                                                 wstrb[12],wstrb[13],wstrb[14],wstrb[15]};
          end
          else
          begin
            data_written_end_swapped[127:96]  = wdata[127:96];
            data_written_end_swapped[95:64]   = wdata[95:64];
            data_written_end_swapped[63:32]   = wdata[63:32];
            data_written_end_swapped[31:0]    = wdata[31:0];
            write_en_end_swapped[15:0]        = wstrb[15:0];
          end
        end
      end

      2'b01 : // 64 bit
      begin
        if (awsize_data == 3'b010) // 32 bit access
        begin
          data_written_end_swapped[127:32] = 96'b0;
          write_en_end_swapped[15:4]       = 12'h000;
          if (awaddr_data[2]) // 32 bit access,in upper half ...
          begin
            if (wr_endian_swap)
            begin
              data_written_end_swapped[31:0] = {wdata[7:0],wdata[15:8],wdata[23:16],wdata[31:24]};
              write_en_end_swapped[3:0]     = {wstrb[0],wstrb[1],wstrb[2],wstrb[3]};
            end
            else
            begin
              data_written_end_swapped[31:0] = wdata[63:32];
              write_en_end_swapped[3:0]      = wstrb[7:4];
            end
          end

          else             // 32 bit access,in lower half ...
          begin
            if (wr_endian_swap)
            begin
              data_written_end_swapped[31:0] = {wdata[7:0],wdata[15:8],wdata[23:16],wdata[31:24]};
              write_en_end_swapped[3:0]      = {wstrb[0],wstrb[1],wstrb[2],wstrb[3]};
            end
            else
            begin
              data_written_end_swapped[31:0] = wdata[31:0];
              write_en_end_swapped[3:0]      = wstrb[3:0];
            end
          end
        end
        else  // 64 bit access
        begin
          data_written_end_swapped[127:64] = 64'b0;
          write_en_end_swapped[15:8]       = 8'h00;
          if (wr_endian_swap)
          begin
            data_written_end_swapped[63:32]= {wdata[7:0],wdata[15:8],wdata[23:16],wdata[31:24]};
            data_written_end_swapped[31:0] = {wdata[39:32],wdata[47:40],wdata[55:48],wdata[63:56]};
            write_en_end_swapped[7:0]      = {wstrb[0],wstrb[1],wstrb[2],wstrb[3],
                                              wstrb[4],wstrb[5],wstrb[6],wstrb[7]};
          end
          else
          begin
            data_written_end_swapped[63:32]= wdata[63:32];
            data_written_end_swapped[31:0] = wdata[31:0];
            write_en_end_swapped[7:0]      = wstrb[7:0];
          end
        end
      end

      2'b00 :  // 32 bit datapath only ...
      begin
        data_written_end_swapped[127:32] = 96'b0;
        write_en_end_swapped[15:4]       = 12'h000;
        if (wr_endian_swap)
        begin
          data_written_end_swapped[31:0]  = {wdata[7:0],wdata[15:8],wdata[23:16],wdata[31:24]};
          write_en_end_swapped[3:0]       = {wstrb[0],wstrb[1],wstrb[2],wstrb[3]};
        end
        else
        begin
          data_written_end_swapped[31:0]  = wdata[31:0];
          write_en_end_swapped[3:0]       = wstrb[3:0];
        end
      end
    endcase
  end

   assign write_data_31to0    = dma_wr_vector_plus0[39:8];
   assign write_data_63to32   = dma_wr_vector_plus1[39:8];
   assign write_data_95to64   = dma_wr_vector_plus2[39:8];
   assign write_data_127to96  = dma_wr_vector_plus3[39:8];
   assign write_en_31to0      = {{8{dma_wr_vector_plus0[3]}},{8{dma_wr_vector_plus0[2]}},{8{dma_wr_vector_plus0[1]}},{8{dma_wr_vector_plus0[0]}}};
   assign write_en_63to32     = {{8{dma_wr_vector_plus1[3]}},{8{dma_wr_vector_plus1[2]}},{8{dma_wr_vector_plus1[1]}},{8{dma_wr_vector_plus1[0]}}};
   assign write_en_95to64     = {{8{dma_wr_vector_plus2[3]}},{8{dma_wr_vector_plus2[2]}},{8{dma_wr_vector_plus2[1]}},{8{dma_wr_vector_plus2[0]}}};
   assign write_en_127to96    = {{8{dma_wr_vector_plus3[3]}},{8{dma_wr_vector_plus3[2]}},{8{dma_wr_vector_plus3[1]}},{8{dma_wr_vector_plus3[0]}}};
   assign write_en_end_swapped_pad = {
                                    {8{write_en_end_swapped[15]}},{8{write_en_end_swapped[14]}},{8{write_en_end_swapped[13]}},{8{write_en_end_swapped[12]}},{8{write_en_end_swapped[11]}},{8{write_en_end_swapped[10]}},{8{write_en_end_swapped[9]}},{8{write_en_end_swapped[8]}},
                                    {8{write_en_end_swapped[7]}},{8{write_en_end_swapped[6]}},{8{write_en_end_swapped[5]}},{8{write_en_end_swapped[4]}},{8{write_en_end_swapped[3]}},{8{write_en_end_swapped[2]}},{8{write_en_end_swapped[1]}},{8{write_en_end_swapped[0]}}
                                     };
   assign nxt_vector_dma_wr  = using_q0_tx_descr_wr    ? nxt_vector_dma_wr_tx_descr_q0 :
                               using_q0_rx_descr_wr    ? nxt_vector_dma_wr_rx_descr_q0 :
                                                         nxt_vector_dma_wr_rx_data_q0;
   assign wr_not_ok           = nxt_vector_dma_wr[104];
   assign wr_endian_swap      = (nxt_vector_dma_wr[105]) | (&endian_value);

// -----------------------------------------------------------------------------
// index to write array
// -----------------------------------------------------------------------------

   // next index to write array
   always @(negedge reset_tb or posedge hclk)
   begin
     if (~reset_tb)
       next_index_dma_wr_rx_data_q0 <= 1;
     else
     begin
        if (valid_dw_access & using_q0_rx_data_wr)
           case ({awsize_data[2],awsize_data[0]})
              2'b00   : next_index_dma_wr_rx_data_q0 <= next_index_dma_wr_rx_data_q0 + 1;
              2'b01   : next_index_dma_wr_rx_data_q0 <= next_index_dma_wr_rx_data_q0 + 2;
              default : next_index_dma_wr_rx_data_q0 <= next_index_dma_wr_rx_data_q0 + 4;
           endcase
     end
   end


   always @(negedge reset_tb or posedge hclk)
   begin
     if (~reset_tb)
       next_index_dma_wr_tx_descr_q0 <= 1;
     else
     begin
        if (valid_dw_access & using_q0_tx_descr_wr)
           case ({awsize_data[2],awsize_data[0]})
              2'b00   : next_index_dma_wr_tx_descr_q0 <= next_index_dma_wr_tx_descr_q0 + 1;
              2'b01   : next_index_dma_wr_tx_descr_q0 <= next_index_dma_wr_tx_descr_q0 + 2;
              default : next_index_dma_wr_tx_descr_q0 <= next_index_dma_wr_tx_descr_q0 + 4;
           endcase
     end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
     if (~reset_tb)
       next_index_dma_wr_rx_descr_q0 <= 1;
     else
     begin
        if (valid_dw_access & using_q0_rx_descr_wr)
           case ({awsize_data[2],awsize_data[0]})
              2'b00   : next_index_dma_wr_rx_descr_q0 <= next_index_dma_wr_rx_descr_q0 + 1;
              2'b01   : next_index_dma_wr_rx_descr_q0 <= next_index_dma_wr_rx_descr_q0 + 2;
              default : next_index_dma_wr_rx_descr_q0 <= next_index_dma_wr_rx_descr_q0 + 4;
           endcase
     end
   end
     // next index to write array
  `ifdef dma_priority_queue1

   always @(negedge reset_tb or posedge hclk)
   begin
     if (~reset_tb)
     begin
       next_index_dma_wr_tx_descr_q1 <= 1;
       next_index_dma_wr_tx_descr_q2 <= 1;
       next_index_dma_wr_tx_descr_q3 <= 1;
       next_index_dma_wr_tx_descr_q4 <= 1;
       next_index_dma_wr_tx_descr_q5 <= 1;
       next_index_dma_wr_tx_descr_q6 <= 1;
       next_index_dma_wr_tx_descr_q7 <= 1;
       next_index_dma_wr_tx_descr_q8 <= 1;
       next_index_dma_wr_tx_descr_q9 <= 1;
       next_index_dma_wr_tx_descr_q10 <= 1;
       next_index_dma_wr_tx_descr_q11 <= 1;
       next_index_dma_wr_tx_descr_q12 <= 1;
       next_index_dma_wr_tx_descr_q13 <= 1;
       next_index_dma_wr_tx_descr_q14 <= 1;
       next_index_dma_wr_tx_descr_q15 <= 1;
       next_index_dma_wr_rx_descr_q1 <= 1;
       next_index_dma_wr_rx_descr_q2 <= 1;
       next_index_dma_wr_rx_descr_q3 <= 1;
       next_index_dma_wr_rx_descr_q4 <= 1;
       next_index_dma_wr_rx_descr_q5 <= 1;
       next_index_dma_wr_rx_descr_q6 <= 1;
       next_index_dma_wr_rx_descr_q7 <= 1;
       next_index_dma_wr_rx_descr_q8 <= 1;
       next_index_dma_wr_rx_descr_q9 <= 1;
       next_index_dma_wr_rx_descr_q10 <= 1;
       next_index_dma_wr_rx_descr_q11 <= 1;
       next_index_dma_wr_rx_descr_q12 <= 1;
       next_index_dma_wr_rx_descr_q13 <= 1;
       next_index_dma_wr_rx_descr_q14 <= 1;
       next_index_dma_wr_rx_descr_q15 <= 1;
       next_index_dma_wr_rx_data_q1 <= 1;
       next_index_dma_wr_rx_data_q2 <= 1;
       next_index_dma_wr_rx_data_q3 <= 1;
       next_index_dma_wr_rx_data_q4 <= 1;
       next_index_dma_wr_rx_data_q5 <= 1;
       next_index_dma_wr_rx_data_q6 <= 1;
       next_index_dma_wr_rx_data_q7 <= 1;
       next_index_dma_wr_rx_data_q8 <= 1;
       next_index_dma_wr_rx_data_q9 <= 1;
       next_index_dma_wr_rx_data_q10 <= 1;
       next_index_dma_wr_rx_data_q11 <= 1;
       next_index_dma_wr_rx_data_q12 <= 1;
       next_index_dma_wr_rx_data_q13 <= 1;
       next_index_dma_wr_rx_data_q14 <= 1;
       next_index_dma_wr_rx_data_q15 <= 1;
     end
     else
     begin
      if (valid_dw_access)
      begin
        if (using_q1_tx_descr_wr) next_index_dma_wr_tx_descr_q1  <= next_index_dma_wr_tx_descr_q1  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q2_tx_descr_wr) next_index_dma_wr_tx_descr_q2  <= next_index_dma_wr_tx_descr_q2  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q3_tx_descr_wr) next_index_dma_wr_tx_descr_q3  <= next_index_dma_wr_tx_descr_q3  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q4_tx_descr_wr) next_index_dma_wr_tx_descr_q4  <= next_index_dma_wr_tx_descr_q4  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q5_tx_descr_wr) next_index_dma_wr_tx_descr_q5  <= next_index_dma_wr_tx_descr_q5  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q6_tx_descr_wr) next_index_dma_wr_tx_descr_q6  <= next_index_dma_wr_tx_descr_q6  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q7_tx_descr_wr) next_index_dma_wr_tx_descr_q7  <= next_index_dma_wr_tx_descr_q7  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q8_tx_descr_wr) next_index_dma_wr_tx_descr_q8  <= next_index_dma_wr_tx_descr_q8  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q9_tx_descr_wr) next_index_dma_wr_tx_descr_q9  <= next_index_dma_wr_tx_descr_q9  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q10_tx_descr_wr) next_index_dma_wr_tx_descr_q10 <= next_index_dma_wr_tx_descr_q10 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q11_tx_descr_wr) next_index_dma_wr_tx_descr_q11 <= next_index_dma_wr_tx_descr_q11 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q12_tx_descr_wr) next_index_dma_wr_tx_descr_q12 <= next_index_dma_wr_tx_descr_q12 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q13_tx_descr_wr) next_index_dma_wr_tx_descr_q13 <= next_index_dma_wr_tx_descr_q13 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q14_tx_descr_wr) next_index_dma_wr_tx_descr_q14 <= next_index_dma_wr_tx_descr_q14 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q15_tx_descr_wr) next_index_dma_wr_tx_descr_q15 <= next_index_dma_wr_tx_descr_q15 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q1_rx_descr_wr) next_index_dma_wr_rx_descr_q1  <= next_index_dma_wr_rx_descr_q1  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q2_rx_descr_wr) next_index_dma_wr_rx_descr_q2  <= next_index_dma_wr_rx_descr_q2  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q3_rx_descr_wr) next_index_dma_wr_rx_descr_q3  <= next_index_dma_wr_rx_descr_q3  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q4_rx_descr_wr) next_index_dma_wr_rx_descr_q4  <= next_index_dma_wr_rx_descr_q4  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q5_rx_descr_wr) next_index_dma_wr_rx_descr_q5  <= next_index_dma_wr_rx_descr_q5  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q6_rx_descr_wr) next_index_dma_wr_rx_descr_q6  <= next_index_dma_wr_rx_descr_q6  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q7_rx_descr_wr) next_index_dma_wr_rx_descr_q7  <= next_index_dma_wr_rx_descr_q7  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q8_rx_descr_wr) next_index_dma_wr_rx_descr_q8  <= next_index_dma_wr_rx_descr_q8  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q9_rx_descr_wr) next_index_dma_wr_rx_descr_q9  <= next_index_dma_wr_rx_descr_q9  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q10_rx_descr_wr) next_index_dma_wr_rx_descr_q10 <= next_index_dma_wr_rx_descr_q10 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q11_rx_descr_wr) next_index_dma_wr_rx_descr_q11 <= next_index_dma_wr_rx_descr_q11 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q12_rx_descr_wr) next_index_dma_wr_rx_descr_q12 <= next_index_dma_wr_rx_descr_q12 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q13_rx_descr_wr) next_index_dma_wr_rx_descr_q13 <= next_index_dma_wr_rx_descr_q13 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q14_rx_descr_wr) next_index_dma_wr_rx_descr_q14 <= next_index_dma_wr_rx_descr_q14 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q15_rx_descr_wr) next_index_dma_wr_rx_descr_q15 <= next_index_dma_wr_rx_descr_q15 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q1_rx_data_wr) next_index_dma_wr_rx_data_q1  <= next_index_dma_wr_rx_data_q1  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q2_rx_data_wr) next_index_dma_wr_rx_data_q2  <= next_index_dma_wr_rx_data_q2  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q3_rx_data_wr) next_index_dma_wr_rx_data_q3  <= next_index_dma_wr_rx_data_q3  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q4_rx_data_wr) next_index_dma_wr_rx_data_q4  <= next_index_dma_wr_rx_data_q4  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q5_rx_data_wr) next_index_dma_wr_rx_data_q5  <= next_index_dma_wr_rx_data_q5  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q6_rx_data_wr) next_index_dma_wr_rx_data_q6  <= next_index_dma_wr_rx_data_q6  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q7_rx_data_wr) next_index_dma_wr_rx_data_q7  <= next_index_dma_wr_rx_data_q7  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q8_rx_data_wr) next_index_dma_wr_rx_data_q8  <= next_index_dma_wr_rx_data_q8  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q9_rx_data_wr) next_index_dma_wr_rx_data_q9  <= next_index_dma_wr_rx_data_q9  + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q10_rx_data_wr) next_index_dma_wr_rx_data_q10 <= next_index_dma_wr_rx_data_q10 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q11_rx_data_wr) next_index_dma_wr_rx_data_q11 <= next_index_dma_wr_rx_data_q11 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q12_rx_data_wr) next_index_dma_wr_rx_data_q12 <= next_index_dma_wr_rx_data_q12 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q13_rx_data_wr) next_index_dma_wr_rx_data_q13 <= next_index_dma_wr_rx_data_q13 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q14_rx_data_wr) next_index_dma_wr_rx_data_q14 <= next_index_dma_wr_rx_data_q14 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
        if (using_q15_rx_data_wr) next_index_dma_wr_rx_data_q15 <= next_index_dma_wr_rx_data_q15 + {awsize_data[2],awsize_data[0],(awsize_data[2:0] == 3'b000 || awsize_data[2:0] == 3'b010)};
      end
     end
   end

  `endif

   // current index to write array
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
         index_dma_wr_rx_data_q0 <= 1;
         index_dma_wr_tx_descr_q0 <= 1;
         index_dma_wr_rx_descr_q0 <= 1;
        `ifdef dma_priority_queue1
            index_dma_wr_tx_descr_q1 <= 1;
            index_dma_wr_tx_descr_q2 <= 1;
            index_dma_wr_tx_descr_q3 <= 1;
            index_dma_wr_tx_descr_q4 <= 1;
            index_dma_wr_tx_descr_q5 <= 1;
            index_dma_wr_tx_descr_q6 <= 1;
            index_dma_wr_tx_descr_q7 <= 1;
            index_dma_wr_tx_descr_q8 <= 1;
            index_dma_wr_tx_descr_q9 <= 1;
            index_dma_wr_tx_descr_q10 <= 1;
            index_dma_wr_tx_descr_q11 <= 1;
            index_dma_wr_tx_descr_q12 <= 1;
            index_dma_wr_tx_descr_q13 <= 1;
            index_dma_wr_tx_descr_q14 <= 1;
            index_dma_wr_tx_descr_q15 <= 1;
            index_dma_wr_rx_descr_q1 <= 1;
            index_dma_wr_rx_descr_q2 <= 1;
            index_dma_wr_rx_descr_q3 <= 1;
            index_dma_wr_rx_descr_q4 <= 1;
            index_dma_wr_rx_descr_q5 <= 1;
            index_dma_wr_rx_descr_q6 <= 1;
            index_dma_wr_rx_descr_q7 <= 1;
            index_dma_wr_rx_descr_q8 <= 1;
            index_dma_wr_rx_descr_q9 <= 1;
            index_dma_wr_rx_descr_q10 <= 1;
            index_dma_wr_rx_descr_q11 <= 1;
            index_dma_wr_rx_descr_q12 <= 1;
            index_dma_wr_rx_descr_q13 <= 1;
            index_dma_wr_rx_descr_q14 <= 1;
            index_dma_wr_rx_descr_q15 <= 1;
            index_dma_wr_rx_data_q1 <= 1;
            index_dma_wr_rx_data_q2 <= 1;
            index_dma_wr_rx_data_q3 <= 1;
            index_dma_wr_rx_data_q4 <= 1;
            index_dma_wr_rx_data_q5 <= 1;
            index_dma_wr_rx_data_q6 <= 1;
            index_dma_wr_rx_data_q7 <= 1;
            index_dma_wr_rx_data_q8 <= 1;
            index_dma_wr_rx_data_q9 <= 1;
            index_dma_wr_rx_data_q10 <= 1;
            index_dma_wr_rx_data_q11 <= 1;
            index_dma_wr_rx_data_q12 <= 1;
            index_dma_wr_rx_data_q13 <= 1;
            index_dma_wr_rx_data_q14 <= 1;
            index_dma_wr_rx_data_q15 <= 1;
         `endif
      end
      else
      begin
         index_dma_wr_rx_data_q0   <= next_index_dma_wr_rx_data_q0;
         index_dma_wr_tx_descr_q0  <= next_index_dma_wr_tx_descr_q0;
         index_dma_wr_rx_descr_q0  <= next_index_dma_wr_rx_descr_q0;
        `ifdef dma_priority_queue1
         index_dma_wr_tx_descr_q1  <= next_index_dma_wr_tx_descr_q1;
         index_dma_wr_tx_descr_q2  <= next_index_dma_wr_tx_descr_q2;
         index_dma_wr_tx_descr_q3  <= next_index_dma_wr_tx_descr_q3;
         index_dma_wr_tx_descr_q4  <= next_index_dma_wr_tx_descr_q4;
         index_dma_wr_tx_descr_q5  <= next_index_dma_wr_tx_descr_q5;
         index_dma_wr_tx_descr_q6  <= next_index_dma_wr_tx_descr_q6;
         index_dma_wr_tx_descr_q7  <= next_index_dma_wr_tx_descr_q7;
         index_dma_wr_tx_descr_q8  <= next_index_dma_wr_tx_descr_q8;
         index_dma_wr_tx_descr_q9  <= next_index_dma_wr_tx_descr_q9;
         index_dma_wr_tx_descr_q10 <= next_index_dma_wr_tx_descr_q10;
         index_dma_wr_tx_descr_q11 <= next_index_dma_wr_tx_descr_q11;
         index_dma_wr_tx_descr_q12 <= next_index_dma_wr_tx_descr_q12;
         index_dma_wr_tx_descr_q13 <= next_index_dma_wr_tx_descr_q13;
         index_dma_wr_tx_descr_q14 <= next_index_dma_wr_tx_descr_q14;
         index_dma_wr_tx_descr_q15 <= next_index_dma_wr_tx_descr_q15;
         index_dma_wr_rx_descr_q1  <= next_index_dma_wr_rx_descr_q1;
         index_dma_wr_rx_descr_q2  <= next_index_dma_wr_rx_descr_q2;
         index_dma_wr_rx_descr_q3  <= next_index_dma_wr_rx_descr_q3;
         index_dma_wr_rx_descr_q4  <= next_index_dma_wr_rx_descr_q4;
         index_dma_wr_rx_descr_q5  <= next_index_dma_wr_rx_descr_q5;
         index_dma_wr_rx_descr_q6  <= next_index_dma_wr_rx_descr_q6;
         index_dma_wr_rx_descr_q7  <= next_index_dma_wr_rx_descr_q7;
         index_dma_wr_rx_descr_q8  <= next_index_dma_wr_rx_descr_q8;
         index_dma_wr_rx_descr_q9  <= next_index_dma_wr_rx_descr_q9;
         index_dma_wr_rx_descr_q10 <= next_index_dma_wr_rx_descr_q10;
         index_dma_wr_rx_descr_q11 <= next_index_dma_wr_rx_descr_q11;
         index_dma_wr_rx_descr_q12 <= next_index_dma_wr_rx_descr_q12;
         index_dma_wr_rx_descr_q13 <= next_index_dma_wr_rx_descr_q13;
         index_dma_wr_rx_descr_q14 <= next_index_dma_wr_rx_descr_q14;
         index_dma_wr_rx_descr_q15 <= next_index_dma_wr_rx_descr_q15;
         index_dma_wr_rx_data_q1  <= next_index_dma_wr_rx_data_q1;
         index_dma_wr_rx_data_q2  <= next_index_dma_wr_rx_data_q2;
         index_dma_wr_rx_data_q3  <= next_index_dma_wr_rx_data_q3;
         index_dma_wr_rx_data_q4  <= next_index_dma_wr_rx_data_q4;
         index_dma_wr_rx_data_q5  <= next_index_dma_wr_rx_data_q5;
         index_dma_wr_rx_data_q6  <= next_index_dma_wr_rx_data_q6;
         index_dma_wr_rx_data_q7  <= next_index_dma_wr_rx_data_q7;
         index_dma_wr_rx_data_q8  <= next_index_dma_wr_rx_data_q8;
         index_dma_wr_rx_data_q9  <= next_index_dma_wr_rx_data_q9;
         index_dma_wr_rx_data_q10 <= next_index_dma_wr_rx_data_q10;
         index_dma_wr_rx_data_q11 <= next_index_dma_wr_rx_data_q11;
         index_dma_wr_rx_data_q12 <= next_index_dma_wr_rx_data_q12;
         index_dma_wr_rx_data_q13 <= next_index_dma_wr_rx_data_q13;
         index_dma_wr_rx_data_q14 <= next_index_dma_wr_rx_data_q14;
         index_dma_wr_rx_data_q15 <= next_index_dma_wr_rx_data_q15;
         `endif
      end
   end


// -----------------------------------------------------------------------------
// index to read array
// -----------------------------------------------------------------------------

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_orig & araddr_data_cmp == next_read_add_orig)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_index <= next_dma_rd_index + 1;
              2'b01   : next_dma_rd_index <= next_dma_rd_index + 2;
              default : next_dma_rd_index <= next_dma_rd_index + 4;
           endcase
        else
           next_dma_rd_index <= next_dma_rd_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q1_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q1 & ~using_tx_descr & araddr_data_cmp == next_read_add_q1)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q1_index <= next_dma_rd_q1_index + 1;
              2'b01   : next_dma_rd_q1_index <= next_dma_rd_q1_index + 2;
              default : next_dma_rd_q1_index <= next_dma_rd_q1_index + 4;
           endcase
        else
           next_dma_rd_q1_index <= next_dma_rd_q1_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q2_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q2 & ~using_tx_descr & araddr_data_cmp == next_read_add_q2)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q2_index <= next_dma_rd_q2_index + 1;
              2'b01   : next_dma_rd_q2_index <= next_dma_rd_q2_index + 2;
              default : next_dma_rd_q2_index <= next_dma_rd_q2_index + 4;
           endcase
        else
           next_dma_rd_q2_index <= next_dma_rd_q2_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q3_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q3 & ~using_tx_descr & araddr_data_cmp == next_read_add_q3)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q3_index <= next_dma_rd_q3_index + 1;
              2'b01   : next_dma_rd_q3_index <= next_dma_rd_q3_index + 2;
              default : next_dma_rd_q3_index <= next_dma_rd_q3_index + 4;
           endcase
        else
           next_dma_rd_q3_index <= next_dma_rd_q3_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q4_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q4 & ~using_tx_descr & araddr_data_cmp == next_read_add_q4)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q4_index <= next_dma_rd_q4_index + 1;
              2'b01   : next_dma_rd_q4_index <= next_dma_rd_q4_index + 2;
              default : next_dma_rd_q4_index <= next_dma_rd_q4_index + 4;
           endcase
        else
           next_dma_rd_q4_index <= next_dma_rd_q4_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q5_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q5 & ~using_tx_descr & araddr_data_cmp == next_read_add_q5)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q5_index <= next_dma_rd_q5_index + 1;
              2'b01   : next_dma_rd_q5_index <= next_dma_rd_q5_index + 2;
              default : next_dma_rd_q5_index <= next_dma_rd_q5_index + 4;
           endcase
        else
           next_dma_rd_q5_index <= next_dma_rd_q5_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q6_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q6 & ~using_tx_descr & araddr_data_cmp == next_read_add_q6)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q6_index <= next_dma_rd_q6_index + 1;
              2'b01   : next_dma_rd_q6_index <= next_dma_rd_q6_index + 2;
              default : next_dma_rd_q6_index <= next_dma_rd_q6_index + 4;
           endcase
        else
           next_dma_rd_q6_index <= next_dma_rd_q6_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q7_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q7 & ~using_tx_descr & araddr_data_cmp == next_read_add_q7)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q7_index <= next_dma_rd_q7_index + 1;
              2'b01   : next_dma_rd_q7_index <= next_dma_rd_q7_index + 2;
              default : next_dma_rd_q7_index <= next_dma_rd_q7_index + 4;
           endcase
        else
           next_dma_rd_q7_index <= next_dma_rd_q7_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q8_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q8 & ~using_tx_descr & araddr_data_cmp == next_read_add_q8)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q8_index <= next_dma_rd_q8_index + 1;
              2'b01   : next_dma_rd_q8_index <= next_dma_rd_q8_index + 2;
              default : next_dma_rd_q8_index <= next_dma_rd_q8_index + 4;
           endcase
        else
           next_dma_rd_q8_index <= next_dma_rd_q8_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q9_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q9 & ~using_tx_descr & araddr_data_cmp == next_read_add_q9)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q9_index <= next_dma_rd_q9_index + 1;
              2'b01   : next_dma_rd_q9_index <= next_dma_rd_q9_index + 2;
              default : next_dma_rd_q9_index <= next_dma_rd_q9_index + 4;
           endcase
        else
           next_dma_rd_q9_index <= next_dma_rd_q9_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q10_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q10 & ~using_tx_descr & araddr_data_cmp == next_read_add_q10)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q10_index <= next_dma_rd_q10_index + 1;
              2'b01   : next_dma_rd_q10_index <= next_dma_rd_q10_index + 2;
              default : next_dma_rd_q10_index <= next_dma_rd_q10_index + 4;
           endcase
        else
           next_dma_rd_q10_index <= next_dma_rd_q10_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q11_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q11 & ~using_tx_descr & araddr_data_cmp == next_read_add_q11)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q11_index <= next_dma_rd_q11_index + 1;
              2'b01   : next_dma_rd_q11_index <= next_dma_rd_q11_index + 2;
              default : next_dma_rd_q11_index <= next_dma_rd_q11_index + 4;
           endcase
        else
           next_dma_rd_q11_index <= next_dma_rd_q11_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q12_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q12 & ~using_tx_descr & araddr_data_cmp == next_read_add_q12)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q12_index <= next_dma_rd_q12_index + 1;
              2'b01   : next_dma_rd_q12_index <= next_dma_rd_q12_index + 2;
              default : next_dma_rd_q12_index <= next_dma_rd_q12_index + 4;
           endcase
        else
           next_dma_rd_q12_index <= next_dma_rd_q12_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q13_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q13 & ~using_tx_descr & araddr_data_cmp == next_read_add_q13)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q13_index <= next_dma_rd_q13_index + 1;
              2'b01   : next_dma_rd_q13_index <= next_dma_rd_q13_index + 2;
              default : next_dma_rd_q13_index <= next_dma_rd_q13_index + 4;
           endcase
        else
           next_dma_rd_q13_index <= next_dma_rd_q13_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q14_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q14 & ~using_tx_descr & araddr_data_cmp == next_read_add_q14)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q14_index <= next_dma_rd_q14_index + 1;
              2'b01   : next_dma_rd_q14_index <= next_dma_rd_q14_index + 2;
              default : next_dma_rd_q14_index <= next_dma_rd_q14_index + 4;
           endcase
        else
           next_dma_rd_q14_index <= next_dma_rd_q14_index;
      end
   end
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_q15_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & valid_dr_access & using_q15 & ~using_tx_descr & araddr_data_cmp == next_read_add_q15)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : next_dma_rd_q15_index <= next_dma_rd_q15_index + 1;
              2'b01   : next_dma_rd_q15_index <= next_dma_rd_q15_index + 2;
              default : next_dma_rd_q15_index <= next_dma_rd_q15_index + 4;
           endcase
        else
           next_dma_rd_q15_index <= next_dma_rd_q15_index;
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q0_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q0)
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q0_next_dma_rd_index <= tx_data_q0_next_dma_rd_index + 1;
              2'b01   : tx_data_q0_next_dma_rd_index <= tx_data_q0_next_dma_rd_index + 2;
              default : tx_data_q0_next_dma_rd_index <= tx_data_q0_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q0_next_dma_rd_index <= tx_data_q0_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q1_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q1 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q1_next_dma_rd_index <= tx_data_q1_next_dma_rd_index + 1;
              2'b01   : tx_data_q1_next_dma_rd_index <= tx_data_q1_next_dma_rd_index + 2;
              default : tx_data_q1_next_dma_rd_index <= tx_data_q1_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q1_next_dma_rd_index <= tx_data_q1_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q2_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q2 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q2_next_dma_rd_index <= tx_data_q2_next_dma_rd_index + 1;
              2'b01   : tx_data_q2_next_dma_rd_index <= tx_data_q2_next_dma_rd_index + 2;
              default : tx_data_q2_next_dma_rd_index <= tx_data_q2_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q2_next_dma_rd_index <= tx_data_q2_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q3_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q3 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q3_next_dma_rd_index <= tx_data_q3_next_dma_rd_index + 1;
              2'b01   : tx_data_q3_next_dma_rd_index <= tx_data_q3_next_dma_rd_index + 2;
              default : tx_data_q3_next_dma_rd_index <= tx_data_q3_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q3_next_dma_rd_index <= tx_data_q3_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q4_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q4 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q4_next_dma_rd_index <= tx_data_q4_next_dma_rd_index + 1;
              2'b01   : tx_data_q4_next_dma_rd_index <= tx_data_q4_next_dma_rd_index + 2;
              default : tx_data_q4_next_dma_rd_index <= tx_data_q4_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q4_next_dma_rd_index <= tx_data_q4_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q5_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q5 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q5_next_dma_rd_index <= tx_data_q5_next_dma_rd_index + 1;
              2'b01   : tx_data_q5_next_dma_rd_index <= tx_data_q5_next_dma_rd_index + 2;
              default : tx_data_q5_next_dma_rd_index <= tx_data_q5_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q5_next_dma_rd_index <= tx_data_q5_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q6_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q6 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q6_next_dma_rd_index <= tx_data_q6_next_dma_rd_index + 1;
              2'b01   : tx_data_q6_next_dma_rd_index <= tx_data_q6_next_dma_rd_index + 2;
              default : tx_data_q6_next_dma_rd_index <= tx_data_q6_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q6_next_dma_rd_index <= tx_data_q6_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q7_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q7 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q7_next_dma_rd_index <= tx_data_q7_next_dma_rd_index + 1;
              2'b01   : tx_data_q7_next_dma_rd_index <= tx_data_q7_next_dma_rd_index + 2;
              default : tx_data_q7_next_dma_rd_index <= tx_data_q7_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q7_next_dma_rd_index <= tx_data_q7_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q8_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q8 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q8_next_dma_rd_index <= tx_data_q8_next_dma_rd_index + 1;
              2'b01   : tx_data_q8_next_dma_rd_index <= tx_data_q8_next_dma_rd_index + 2;
              default : tx_data_q8_next_dma_rd_index <= tx_data_q8_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q8_next_dma_rd_index <= tx_data_q8_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q9_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q9 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q9_next_dma_rd_index <= tx_data_q9_next_dma_rd_index + 1;
              2'b01   : tx_data_q9_next_dma_rd_index <= tx_data_q9_next_dma_rd_index + 2;
              default : tx_data_q9_next_dma_rd_index <= tx_data_q9_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q9_next_dma_rd_index <= tx_data_q9_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q10_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q10 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q10_next_dma_rd_index <= tx_data_q10_next_dma_rd_index + 1;
              2'b01   : tx_data_q10_next_dma_rd_index <= tx_data_q10_next_dma_rd_index + 2;
              default : tx_data_q10_next_dma_rd_index <= tx_data_q10_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q10_next_dma_rd_index <= tx_data_q10_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q11_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q11 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q11_next_dma_rd_index <= tx_data_q11_next_dma_rd_index + 1;
              2'b01   : tx_data_q11_next_dma_rd_index <= tx_data_q11_next_dma_rd_index + 2;
              default : tx_data_q11_next_dma_rd_index <= tx_data_q11_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q11_next_dma_rd_index <= tx_data_q11_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q12_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q12 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q12_next_dma_rd_index <= tx_data_q12_next_dma_rd_index + 1;
              2'b01   : tx_data_q12_next_dma_rd_index <= tx_data_q12_next_dma_rd_index + 2;
              default : tx_data_q12_next_dma_rd_index <= tx_data_q12_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q12_next_dma_rd_index <= tx_data_q12_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q13_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q13 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q13_next_dma_rd_index <= tx_data_q13_next_dma_rd_index + 1;
              2'b01   : tx_data_q13_next_dma_rd_index <= tx_data_q13_next_dma_rd_index + 2;
              default : tx_data_q13_next_dma_rd_index <= tx_data_q13_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q13_next_dma_rd_index <= tx_data_q13_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q14_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q14 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q14_next_dma_rd_index <= tx_data_q14_next_dma_rd_index + 1;
              2'b01   : tx_data_q14_next_dma_rd_index <= tx_data_q14_next_dma_rd_index + 2;
              default : tx_data_q14_next_dma_rd_index <= tx_data_q14_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q14_next_dma_rd_index <= tx_data_q14_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_data_q15_next_dma_rd_index <= 1;
      end
      else
      begin
          if (~dma_rd_done & valid_dr_access & using_tx_data_q15 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_data_q15_next_dma_rd_index <= tx_data_q15_next_dma_rd_index + 1;
              2'b01   : tx_data_q15_next_dma_rd_index <= tx_data_q15_next_dma_rd_index + 2;
              default : tx_data_q15_next_dma_rd_index <= tx_data_q15_next_dma_rd_index + 4;
           endcase
          else
           tx_data_q15_next_dma_rd_index <= tx_data_q15_next_dma_rd_index;
        end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_next_dma_rd_index <= tx_descr_next_dma_rd_index + 1;
              2'b01   : tx_descr_next_dma_rd_index <= tx_descr_next_dma_rd_index + 2;
              default : tx_descr_next_dma_rd_index <= tx_descr_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_next_dma_rd_index <= tx_descr_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q1_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q1_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q1_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q1_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q1 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q1_next_dma_rd_index <= tx_descr_q1_next_dma_rd_index + 1;
              2'b01   : tx_descr_q1_next_dma_rd_index <= tx_descr_q1_next_dma_rd_index + 2;
              default : tx_descr_q1_next_dma_rd_index <= tx_descr_q1_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q1_next_dma_rd_index <= tx_descr_q1_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q2_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q2_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q2_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q2_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q2 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q2_next_dma_rd_index <= tx_descr_q2_next_dma_rd_index + 1;
              2'b01   : tx_descr_q2_next_dma_rd_index <= tx_descr_q2_next_dma_rd_index + 2;
              default : tx_descr_q2_next_dma_rd_index <= tx_descr_q2_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q2_next_dma_rd_index <= tx_descr_q2_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q3_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q3_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q3_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q3_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q3 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q3_next_dma_rd_index <= tx_descr_q3_next_dma_rd_index + 1;
              2'b01   : tx_descr_q3_next_dma_rd_index <= tx_descr_q3_next_dma_rd_index + 2;
              default : tx_descr_q3_next_dma_rd_index <= tx_descr_q3_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q3_next_dma_rd_index <= tx_descr_q3_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q4_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q4_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q4_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q4_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q4 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q4_next_dma_rd_index <= tx_descr_q4_next_dma_rd_index + 1;
              2'b01   : tx_descr_q4_next_dma_rd_index <= tx_descr_q4_next_dma_rd_index + 2;
              default : tx_descr_q4_next_dma_rd_index <= tx_descr_q4_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q4_next_dma_rd_index <= tx_descr_q4_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q5_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q5_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q5_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q5_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q5 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q5_next_dma_rd_index <= tx_descr_q5_next_dma_rd_index + 1;
              2'b01   : tx_descr_q5_next_dma_rd_index <= tx_descr_q5_next_dma_rd_index + 2;
              default : tx_descr_q5_next_dma_rd_index <= tx_descr_q5_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q5_next_dma_rd_index <= tx_descr_q5_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q6_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q6_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q6_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q6_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q6 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q6_next_dma_rd_index <= tx_descr_q6_next_dma_rd_index + 1;
              2'b01   : tx_descr_q6_next_dma_rd_index <= tx_descr_q6_next_dma_rd_index + 2;
              default : tx_descr_q6_next_dma_rd_index <= tx_descr_q6_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q6_next_dma_rd_index <= tx_descr_q6_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q7_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q7_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q7_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q7_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q7 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q7_next_dma_rd_index <= tx_descr_q7_next_dma_rd_index + 1;
              2'b01   : tx_descr_q7_next_dma_rd_index <= tx_descr_q7_next_dma_rd_index + 2;
              default : tx_descr_q7_next_dma_rd_index <= tx_descr_q7_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q7_next_dma_rd_index <= tx_descr_q7_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q8_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q8_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q8_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q8_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q8 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q8_next_dma_rd_index <= tx_descr_q8_next_dma_rd_index + 1;
              2'b01   : tx_descr_q8_next_dma_rd_index <= tx_descr_q8_next_dma_rd_index + 2;
              default : tx_descr_q8_next_dma_rd_index <= tx_descr_q8_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q8_next_dma_rd_index <= tx_descr_q8_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q9_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q9_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q9_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q9_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q9 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q9_next_dma_rd_index <= tx_descr_q9_next_dma_rd_index + 1;
              2'b01   : tx_descr_q9_next_dma_rd_index <= tx_descr_q9_next_dma_rd_index + 2;
              default : tx_descr_q9_next_dma_rd_index <= tx_descr_q9_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q9_next_dma_rd_index <= tx_descr_q9_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q10_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q10_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q10_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q10_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q10 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q10_next_dma_rd_index <= tx_descr_q10_next_dma_rd_index + 1;
              2'b01   : tx_descr_q10_next_dma_rd_index <= tx_descr_q10_next_dma_rd_index + 2;
              default : tx_descr_q10_next_dma_rd_index <= tx_descr_q10_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q10_next_dma_rd_index <= tx_descr_q10_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q11_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q11_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q11_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q11_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q11 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q11_next_dma_rd_index <= tx_descr_q11_next_dma_rd_index + 1;
              2'b01   : tx_descr_q11_next_dma_rd_index <= tx_descr_q11_next_dma_rd_index + 2;
              default : tx_descr_q11_next_dma_rd_index <= tx_descr_q11_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q11_next_dma_rd_index <= tx_descr_q11_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q12_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q12_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q12_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q12_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q12 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q12_next_dma_rd_index <= tx_descr_q12_next_dma_rd_index + 1;
              2'b01   : tx_descr_q12_next_dma_rd_index <= tx_descr_q12_next_dma_rd_index + 2;
              default : tx_descr_q12_next_dma_rd_index <= tx_descr_q12_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q12_next_dma_rd_index <= tx_descr_q12_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q13_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q13_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q13_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q13_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q13 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q13_next_dma_rd_index <= tx_descr_q13_next_dma_rd_index + 1;
              2'b01   : tx_descr_q13_next_dma_rd_index <= tx_descr_q13_next_dma_rd_index + 2;
              default : tx_descr_q13_next_dma_rd_index <= tx_descr_q13_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q13_next_dma_rd_index <= tx_descr_q13_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q14_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q14_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q14_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q14_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q14 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q14_next_dma_rd_index <= tx_descr_q14_next_dma_rd_index + 1;
              2'b01   : tx_descr_q14_next_dma_rd_index <= tx_descr_q14_next_dma_rd_index + 2;
              default : tx_descr_q14_next_dma_rd_index <= tx_descr_q14_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q14_next_dma_rd_index <= tx_descr_q14_next_dma_rd_index;
        end
      end
   end

   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        tx_descr_q15_next_dma_rd_index <= 1;
      end
      else
      begin
        if (tx_rewind_index_en &( tx_current_queue_descr_resp == top_queue))
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q15_next_dma_rd_index <= tx_rewind_index;
              2'b01   : tx_descr_q15_next_dma_rd_index <= tx_rewind_index;
              default : tx_descr_q15_next_dma_rd_index <= tx_rewind_index;
           endcase
        else
        begin
          if (~dma_rd_done & valid_dr_access & using_tx_descr_q15 )
           case ({arsize_data[2],arsize_data[0]})
              2'b00   : tx_descr_q15_next_dma_rd_index <= tx_descr_q15_next_dma_rd_index + 1;
              2'b01   : tx_descr_q15_next_dma_rd_index <= tx_descr_q15_next_dma_rd_index + 2;
              default : tx_descr_q15_next_dma_rd_index <= tx_descr_q15_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_q15_next_dma_rd_index <= tx_descr_q15_next_dma_rd_index;
        end
      end
   end

   // current index to write array
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
         dma_rd_index <= 1;
         dma_rd_q1_index <= 1;
         dma_rd_q2_index <= 1;
         dma_rd_q3_index <= 1;
         dma_rd_q4_index <= 1;
         dma_rd_q5_index <= 1;
         dma_rd_q6_index <= 1;
         dma_rd_q7_index <= 1;
         dma_rd_q8_index <= 1;
         dma_rd_q9_index <= 1;
         dma_rd_q10_index <= 1;
         dma_rd_q11_index <= 1;
         dma_rd_q12_index <= 1;
         dma_rd_q13_index <= 1;
         dma_rd_q14_index <= 1;
         dma_rd_q15_index <= 1;
         tx_data_q0_dma_rd_index <= 1;
         tx_data_q1_dma_rd_index <= 1;
         tx_data_q2_dma_rd_index <= 1;
         tx_data_q3_dma_rd_index <= 1;
         tx_data_q4_dma_rd_index <= 1;
         tx_data_q5_dma_rd_index <= 1;
         tx_data_q6_dma_rd_index <= 1;
         tx_data_q7_dma_rd_index <= 1;
         tx_data_q8_dma_rd_index <= 1;
         tx_data_q9_dma_rd_index <= 1;
         tx_data_q10_dma_rd_index <= 1;
         tx_data_q11_dma_rd_index <= 1;
         tx_data_q12_dma_rd_index <= 1;
         tx_data_q13_dma_rd_index <= 1;
         tx_data_q14_dma_rd_index <= 1;
         tx_data_q15_dma_rd_index <= 1;
         tx_descr_dma_rd_index <= 1;
         tx_descr_q1_dma_rd_index <= 1;
         tx_descr_q2_dma_rd_index <= 1;
         tx_descr_q3_dma_rd_index <= 1;
         tx_descr_q4_dma_rd_index <= 1;
         tx_descr_q5_dma_rd_index <= 1;
         tx_descr_q6_dma_rd_index <= 1;
         tx_descr_q7_dma_rd_index <= 1;
         tx_descr_q8_dma_rd_index <= 1;
         tx_descr_q9_dma_rd_index <= 1;
         tx_descr_q10_dma_rd_index <= 1;
         tx_descr_q11_dma_rd_index <= 1;
         tx_descr_q12_dma_rd_index <= 1;
         tx_descr_q13_dma_rd_index <= 1;
         tx_descr_q14_dma_rd_index <= 1;
         tx_descr_q15_dma_rd_index <= 1;
      end
      else
      begin
         if (tx_rewind_index_en & (tx_current_queue_descr_resp == top_queue))
           tx_descr_dma_rd_index       <= tx_rewind_index;
         else if (valid_dr_access)
           tx_descr_dma_rd_index       <= tx_descr_next_dma_rd_index;

         if (valid_dr_access)
         begin
           tx_data_q0_dma_rd_index <= tx_data_q0_next_dma_rd_index;
           tx_data_q1_dma_rd_index <= tx_data_q1_next_dma_rd_index;
           tx_data_q2_dma_rd_index <= tx_data_q2_next_dma_rd_index;
           tx_data_q3_dma_rd_index <= tx_data_q3_next_dma_rd_index;
           tx_data_q4_dma_rd_index <= tx_data_q4_next_dma_rd_index;
           tx_data_q5_dma_rd_index <= tx_data_q5_next_dma_rd_index;
           tx_data_q6_dma_rd_index <= tx_data_q6_next_dma_rd_index;
           tx_data_q7_dma_rd_index <= tx_data_q7_next_dma_rd_index;
           tx_data_q8_dma_rd_index <= tx_data_q8_next_dma_rd_index;
           tx_data_q9_dma_rd_index <= tx_data_q9_next_dma_rd_index;
           tx_data_q10_dma_rd_index <= tx_data_q10_next_dma_rd_index;
           tx_data_q11_dma_rd_index <= tx_data_q11_next_dma_rd_index;
           tx_data_q12_dma_rd_index <= tx_data_q12_next_dma_rd_index;
           tx_data_q13_dma_rd_index <= tx_data_q13_next_dma_rd_index;
           tx_data_q14_dma_rd_index <= tx_data_q14_next_dma_rd_index;
           tx_data_q15_dma_rd_index <= tx_data_q15_next_dma_rd_index;
           dma_rd_q1_index        <= next_dma_rd_q1_index;
           dma_rd_q2_index        <= next_dma_rd_q2_index;
           dma_rd_q3_index        <= next_dma_rd_q3_index;
           dma_rd_q4_index        <= next_dma_rd_q4_index;
           dma_rd_q5_index        <= next_dma_rd_q5_index;
           dma_rd_q6_index        <= next_dma_rd_q6_index;
           dma_rd_q7_index        <= next_dma_rd_q7_index;
           dma_rd_q8_index        <= next_dma_rd_q8_index;
           dma_rd_q9_index        <= next_dma_rd_q9_index;
           dma_rd_q10_index        <= next_dma_rd_q10_index;
           dma_rd_q11_index        <= next_dma_rd_q11_index;
           dma_rd_q12_index        <= next_dma_rd_q12_index;
           dma_rd_q13_index        <= next_dma_rd_q13_index;
           dma_rd_q14_index        <= next_dma_rd_q14_index;
           dma_rd_q15_index        <= next_dma_rd_q15_index;
           dma_rd_index            <= next_dma_rd_index;
           tx_descr_q1_dma_rd_index  <= tx_descr_q1_next_dma_rd_index;
           tx_descr_q2_dma_rd_index  <= tx_descr_q2_next_dma_rd_index;
           tx_descr_q3_dma_rd_index  <= tx_descr_q3_next_dma_rd_index;
           tx_descr_q4_dma_rd_index  <= tx_descr_q4_next_dma_rd_index;
           tx_descr_q5_dma_rd_index  <= tx_descr_q5_next_dma_rd_index;
           tx_descr_q6_dma_rd_index  <= tx_descr_q6_next_dma_rd_index;
           tx_descr_q7_dma_rd_index  <= tx_descr_q7_next_dma_rd_index;
           tx_descr_q8_dma_rd_index  <= tx_descr_q8_next_dma_rd_index;
           tx_descr_q9_dma_rd_index  <= tx_descr_q9_next_dma_rd_index;
           tx_descr_q10_dma_rd_index <= tx_descr_q10_next_dma_rd_index;
           tx_descr_q11_dma_rd_index <= tx_descr_q11_next_dma_rd_index;
           tx_descr_q12_dma_rd_index <= tx_descr_q12_next_dma_rd_index;
           tx_descr_q13_dma_rd_index <= tx_descr_q13_next_dma_rd_index;
           tx_descr_q14_dma_rd_index <= tx_descr_q14_next_dma_rd_index;
           tx_descr_q15_dma_rd_index <= tx_descr_q15_next_dma_rd_index;
        end
      end
   end



// -----------------------------------------------------------------------------
// hready delay & hready output
// -----------------------------------------------------------------------------

/*
   // Detect when the DMA is performing an access
   assign insert_wait = ((hgrantdma | (htrans !== p_htrans_idle)) & hready);

   // Hold insert_wait until access complete
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         insert_wait_hold <= 1'b0;
      else if ( ((amba_ready_delay == 4'h0) & ~randomize_hready) |
                ((random_hready == 0) & randomize_hready & hready))
         insert_wait_hold <= 1'b0;
      else if (insert_wait_hold & delay_hready == 1)
         insert_wait_hold <= 1'b0;
      else if (insert_wait)
         insert_wait_hold <= 1'b1;
*/


   // wait states counter
  reg [7:0] tmp;
  reg   hlock_data;
  reg  valid_ahbrd_access;
  wire tx_descr_rd_resp;
  //wire [63:0] tx_descr_pri_buff_in;
  reg  [`edma_queues-1:0] db1_push;
  reg   [`edma_queues-1:0]   ignore_remaining_desc_rds;
  wire    used_err_on_descr_rd;
  integer z;
  // The following signals are needed by the core testbench components to model priority queueing auto packet tx replays
  // This means we need a way to probe the signals even at gate level.  This can be done by maintaining heirarchy during
  // synthesis, and carefully applying probes.

    `ifdef rtl
      wire [4:0] tx_descr_rd_resp_cnt;
      assign armaster_aph           = 1'b0;
      assign tx_descr_rd_resp_cnt   = 5'd0;

      `ifdef gem_has_802p3_br
        assign tx_descr_rd_resp       = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.descr_rd_resp_end : // can be replaced by trans.pl
                                                  `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.descr_rd_resp_end; // can be replaced by trans.pl
        assign tx_descr_pri_buff_in   = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in[63:0] :
                                                  `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in[63:0];
        //assign tx_descr_pri_buff_in   = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in[63:0] :
       //                                           `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in[63:0];
        assign r_is_tx                = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.r_is_tx :    // can be replaced by trans.pl
                                                  `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.r_is_tx;     // can be replaced by trans.pl
        assign r_is_descr             = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.r_is_descr : // can be replaced by trans.pl
                                                  `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.r_is_descr;  // can be replaced by trans.pl
        assign current_rx_queue_resp  = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.r_queue :    // can be replaced by trans.pl
                                                  `edma_queues;     // can be replaced by trans.pl

        always @(*)
        begin
          for (z = 0;z < `edma_queues;z=z+1)
          begin
            db1_push[z]                   = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_push & `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue == z : // needs to come from design
                                                      `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_push & `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue == z;
            ignore_remaining_desc_rds[z]  = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.ignore_remaining_desc_rds[z] :
                                                      `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.ignore_remaining_desc_rds[z];
          end
          tx_current_queue_descr_resp     = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue :
                                                      `edma_queues;
        end
        assign used_err_on_descr_rd       = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_used_all_q :
                                                      `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_used_all_q;

        assign used_bit_read              = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_used_bit :
                                                      `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_used_bit;
      `else
        assign tx_descr_rd_resp       = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.descr_rd_resp_end; // can be replaced by trans.pl
        assign tx_descr_pri_buff_in   = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in[63:0];
        //assign tx_descr_pri_buff_in   = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in[63:0];
        assign r_is_tx                = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.r_is_tx; // can be replaced by trans.pl
        assign r_is_descr             = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.r_is_descr; // can be replaced by trans.pl
        assign current_rx_queue_resp  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.r_queue; // can be replaced by trans.pl

        always @(*)
        begin
          for (z = 0;z < `edma_queues;z=z+1)
          begin
            db1_push[z]                   = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_push & `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue == z; // needs to come from design
            ignore_remaining_desc_rds[z]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.ignore_remaining_desc_rds[z];
          end
          tx_current_queue_descr_resp     = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue;
        end
        assign used_err_on_descr_rd       = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_used_all_q;
        assign used_bit_read              = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_used_bit;
      `endif

    `else // GL

      assign armaster_aph = 1'b0;



      assign r_is_tx              = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.r_is_tx
                                            : `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.r_is_tx ;
      assign r_is_descr           = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.r_is_descr
                                            : `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.r_is_descr ;
      assign tx_descr_pri_buff_in = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_0_i_tx_descr_buff.db1_in[63:0]
                                            : `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_0_i_tx_descr_buff.db1_in[63:0] ;
      //assign tx_descr_pri_buff_in = !rid[0] ? `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.db1_in[63:0]
      //                                      : `hier_emac.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.db1_in[63:0] ;

      `ifdef dma_priority_queue1
        `ifdef dma_priority_queue8
          assign current_rx_queue_resp= !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.current_rx_queue_resp : `edma_queues;
        `else
          `ifdef dma_priority_queue4
            assign current_rx_queue_resp= !rid[0] ? {1'b0,`hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.current_rx_queue_resp[2:0] } : `edma_queues;
          `else
            `ifdef dma_priority_queue2
              assign current_rx_queue_resp= !rid[0] ? {2'b00,`hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.current_rx_queue_resp[1:0] } : `edma_queues;
            `else
              assign current_rx_queue_resp= !rid[0] ? {3'b000,`hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.current_rx_queue_resp[0] } : `edma_queues;
            `endif
          `endif
        `endif
      `else
        assign current_rx_queue_resp= 4'h0;
      `endif

      reg used_bit_read;
      assign tx_descr_rd_resp_cnt = 5'd0;
      wire [`edma_queues-1:0] tx_descr_rd_resp_r;
      parameter p_sram_bus_width = `edma_tx_pbuf_data;
      parameter p_dma_bus_width  = `edma_bus_width;
       parameter p_edma_queues = `edma_queues;
      always @(*)
      begin
        used_bit_read = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_hold[63]
                                : `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_hold[63];
        for (int z = 0;z < `edma_queues;z=z+1)
        begin
          db1_push[z] = 1'b0;
          //db1_push[z] = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_0_i_tx_descr_buff.db1_push  & `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue  == z // needs to come from design
          //                      : `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_0_i_tx_descr_buff.db1_push  & `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue  == z ; // needs to come from design

       //   ignore_remaining_desc_rds[z] = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_gen_axi_instance_i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.\ignore_remaining_desc_rds_reg[z] .Q;
        end
        `ifdef dma_priority_queue1
          tx_current_queue_descr_resp[0] = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue[0] : p_edma_queues[0];
        `else
          tx_current_queue_descr_resp[0] = 1'b0;
        `endif
        `ifdef dma_priority_queue2
          tx_current_queue_descr_resp[1] = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue[1] : p_edma_queues[1];
        `else
          tx_current_queue_descr_resp[1] = 1'b0;
        `endif
        `ifdef dma_priority_queue4
          tx_current_queue_descr_resp[2] = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue[2] : p_edma_queues[2];
        `else
          tx_current_queue_descr_resp[2] = 1'b0;
        `endif
        `ifdef dma_priority_queue8
          tx_current_queue_descr_resp[3] = !rid[0] ? `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.r_queue[3] : p_edma_queues[3];
        `else
          tx_current_queue_descr_resp[3] = 1'b0;
        `endif
      end
      assign tx_descr_rd_resp_r[0]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_0_i_tx_descr_buff.descr_rd_resp_end;
      `ifdef dma_priority_queue1
        assign tx_descr_rd_resp_r[1]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_1_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue2
        assign tx_descr_rd_resp_r[2]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_2_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue3
        assign tx_descr_rd_resp_r[3]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_3_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue4
        assign tx_descr_rd_resp_r[4]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_4_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue5
        assign tx_descr_rd_resp_r[5]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_5_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue6
        assign tx_descr_rd_resp_r[6]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_6_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue7
        assign tx_descr_rd_resp_r[7]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_7_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue8
        assign tx_descr_rd_resp_r[8]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_8_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue9
        assign tx_descr_rd_resp_r[9]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_9_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue10
        assign tx_descr_rd_resp_r[10]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_10_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue11
        assign tx_descr_rd_resp_r[11]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_11_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue12
        assign tx_descr_rd_resp_r[12]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_12_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue13
        assign tx_descr_rd_resp_r[13]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_13_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue14
        assign tx_descr_rd_resp_r[14]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_14_i_tx_descr_buff.descr_rd_resp_end;
      `endif
      `ifdef dma_priority_queue15
        assign tx_descr_rd_resp_r[15]  = `hier_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_15_i_tx_descr_buff.descr_rd_resp_end;
      `endif

      `ifdef gem_has_802p3_br
      //assign tx_descr_rd_resp     = |tx_descr_rd_resp_r | `hier_emac_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff_0_i_tx_descr_buff.descr_rd_resp_end; // can be replaced by trans.pl
      assign tx_descr_rd_resp     = |tx_descr_rd_resp_r; // The above line is correct, but sometimes genus optimizes it out ..
      `else
      assign tx_descr_rd_resp     = |tx_descr_rd_resp_r;
      `endif

      //assign used_err_on_descr_rd = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_gen_axi_instance_i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_err_was_detected_0_reg .D;
      assign used_err_on_descr_rd = 1'b0;


      `ifdef dma_priority_queue1
      // When using the randomized verification environment, the DMA transactions associated with particular queues are
      // generated by trans.pl.  However, this file cannot take into account dynamic events like when the DPRAM regions
      // become full.
      // when the DPRAM region becomes full, the MANRD for a particular queue is handled in a similar way to what happens
      // when a used bit is read for that queue - it simply moves onto the next queue.  The trans.pl models the used bit
      // but cannot model the buffer_full as it is a dynamic event.  We therefore need to model this here, monitoring
      // the buffer_full status of the DMA and driving the indexes to the TX data file appropriately so we can rewind it if
      // necessary.
//        assign current_queue[0]        = `hierarchy.gen_dma_gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_tx.i_edma_pbuf_tx_wr.\queue_ptr_dph_reg[0] .Q;
//        assign current_queue[1]        = `hierarchy.gen_dma_gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_tx.i_edma_pbuf_tx_wr.\queue_ptr_dph_reg[1] .Q;
//        assign current_queue[2]        = `hierarchy.gen_dma_gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_tx.i_edma_pbuf_tx_wr.\queue_ptr_dph_reg[2] .Q;
//        assign prev_eof_bit         = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_tx_wr.\first_buffer_of_pkt_reg .Q;
      `endif
    `endif

   reg   [159:0] axi_latency_data_reg[1:1];
   reg   [159:0] axi_latency_data;
   reg   [15:0] arready_min;
   reg   [15:0] arready_max;
   reg   [15:0] rvalid_min ;
   reg   [15:0] rvalid_max ;
   reg   [15:0] awready_min;
   reg   [15:0] awready_max;
   reg   [15:0] wready_min ;
   reg   [15:0] wready_max ;
   reg   [15:0] bvalid_min ;
   reg   [15:0] bvalid_max ;
  initial
    begin
      $readmemh("./files/tb_axi_latency_file.data",axi_latency_data_reg);
      axi_latency_data   = axi_latency_data_reg[1];
      arready_min  = axi_latency_data[159:144];
      arready_max = axi_latency_data[143:128];
      rvalid_min = axi_latency_data[127:112];
      rvalid_max = axi_latency_data[111:96];
      awready_min = axi_latency_data[95:80];
      awready_max = axi_latency_data[79:64];
      wready_min = axi_latency_data[63:48];
      wready_max = axi_latency_data[47:32];
      bvalid_min = axi_latency_data[31:16];
      bvalid_max = axi_latency_data[15:0];
    end


reg  [ 1500 :0]rvalid_latency_fifo;
reg  [ 1500 :0]bvalid_latency_fifo;
integer tempi;
reg rvalid_last_shift;
reg bvalid_last_shift;
reg ar_inserted;
reg w_inserted;

always @(posedge hclk)
begin
//  if (rready)
//  begin
  rvalid_latency_fifo[1500] <= 1'b0;
  bvalid_latency_fifo[1500] <= 1'b0;
  rvalid_last_shift = 0;
  bvalid_last_shift = 0;
  ar_inserted = 1'b0;
  w_inserted = 1'b0;
  for (tempi = 0;tempi<1500;tempi=tempi+1)
  begin
    if (tempi == 0)
    begin
      w_inserted = 1'b0;
      bvalid_last_shift = (bvalid & bready)| (bvalid_latency_fifo[0] !== 1'b1);
    end
    else
      bvalid_last_shift = bvalid_last_shift | (bvalid_latency_fifo[tempi] !== 1'b1);

    if (tempi == 0)
    begin
      ar_inserted = 1'b0;
      rvalid_last_shift = (rvalid_tmp & rready & rlast_tmp) | (rvalid_latency_fifo[0] !== 1'b1);
    end
    else
      rvalid_last_shift = rvalid_last_shift | (rvalid_latency_fifo[tempi] !== 1'b1);

    if (wvalid & wready_tmp & wlast & tempi >= bvalid_min & ~w_inserted &
       (bvalid_latency_fifo[tempi] !== 1'b1 | (bvalid_last_shift & bvalid_latency_fifo[tempi+1] !== 1'b1)))
    begin
      bvalid_latency_fifo[tempi] <= wvalid & wready_tmp & wlast;            // sets start point
      w_inserted = 1'b1;
    end
    else if (bvalid_last_shift)                                         // shifts up if position to shift is 0 or we have popped
      bvalid_latency_fifo[tempi] <= bvalid_latency_fifo[tempi+1];

    if (arvalid & arready_tmp & tempi >= rvalid_min & ~ar_inserted &
       (rvalid_latency_fifo[tempi] !== 1'b1 | (rvalid_last_shift & rvalid_latency_fifo[tempi+1] !== 1'b1)))
    begin
      rvalid_latency_fifo[tempi] <= arvalid & arready_tmp;                  // sets start point
      ar_inserted = 1'b1;
    end
    else if (rvalid_last_shift)                                         // shifts up if position to shift is 0 or we have popped
      rvalid_latency_fifo[tempi] <= rvalid_latency_fifo[tempi+1];
  end
//  end
end

reg [7:0] arready_ws_ctr,awready_ws_ctr,rvalid_ws_ctr,wready_ws_ctr,bvalid_ws_ctr;

reg [3:0] num_reqd_bresps;

assign arready_tmp  = arready_ws_ctr == 0 & ~hready_stop & ~ar_buffer_full;
assign awready_tmp   = awready_ws_ctr == 0 & ~hready_stop & ~aw_buffer_full;
assign wready_tmp    = wready_ws_ctr == 0 & ~hready_stop;
assign rvalid_tmp    = fixed_latency_mode ? rvalid_latency_fifo[0] === 1'b1 : ~ar_buffer_empty & rvalid_ws_ctr == 0 & ~hready_stop;
assign bvalid_tmp    = fixed_latency_mode ? bvalid_latency_fifo[0] === 1'b1 : bvalid_ws_ctr == 0 & ~hready_stop & (|num_reqd_bresps);
//assign rvalid   = ~ar_buffer_empty & rvalid_ws_ctr == 0 & ~hready_stop;
//assign bvalid   = bvalid_ws_ctr == 0 & ~hready_stop & (|num_reqd_bresps);


parameter default_arready_wait_states = 0; // Between arvalid & arready
parameter default_awready_wait_states = 0; // Between awvalid & awready
parameter default_rvalid_wait_states  = 4; // Between (arready | prev rvalid) & rvalid - 0 means 1 cycle
parameter default_wready_wait_states  = 4; // Between wvalid & wready
parameter default_bvalid_wait_states  = 0; // Between wready & bvalid -- 0 means 1 cycle
reg dec_rvalid_ws_ctr,dec_bvalid_ws_ctr;
reg [7:0] random_num_0t15_rd;
reg [7:0] random_num2_0t15_rd;
reg [7:0] random_num3_0t15_rd;
reg [7:0] random_num4_0t15_rd;
reg [7:0] random_num5_0t15_rd;
reg [7:0] random_num_0t15_wr;
reg [7:0] random_num2_0t15_wr;
reg [7:0] random_num3_0t15_wr;
reg [7:0] random_num4_0t15_wr;
reg [7:0] random_num5_0t15_wr;
reg [15:0] random_arready;
reg [15:0] random_rvalid;
reg [15:0] random_awready;
reg [15:0] random_wready;
reg [15:0] random_bvalid ;
parameter max_random_num  = 255; //
  always @(negedge reset_tb or posedge hclk)
    if (~reset_tb)
    begin
      arready_ws_ctr  <= arready_min;
      awready_ws_ctr  <= arready_max;
      rvalid_ws_ctr   <= {4'b0,(amba_ready_delay+4'h1)};
      wready_ws_ctr   <= amba_ready_delay;
      bvalid_ws_ctr   <=  {4'b0,(default_bvalid_wait_states + 1)};
      random_num_0t15_rd <= 8'h0;
      random_num2_0t15_rd <= 8'h0;
      random_num3_0t15_rd <= 8'h0;
      random_num4_0t15_rd <= 8'h0;
      random_num5_0t15_rd <= 8'h0;
      random_num_0t15_wr <= 8'h0;
      random_num2_0t15_wr <= 8'h0;
      random_num3_0t15_wr <= 8'h0;
      random_num4_0t15_wr <= 8'h0;
      random_num5_0t15_wr <= 8'h0;
      dec_rvalid_ws_ctr  <= 1'b0;
      dec_bvalid_ws_ctr  <= 1'b0;
      num_reqd_bresps <= 4'h0;
      random_arready <= 16'h0000;
      random_rvalid  <= 16'h0000;
      random_awready <= 16'h0000;
      random_wready  <= 16'h0000;
      random_bvalid  <= 16'h0000;
    end

    else
    begin
      random_num_0t15_rd  <= ($random % (read_max  - read_min  + 1)) + read_min ;
      random_num2_0t15_rd <= ($random % (read_max  - read_min  + 1)) + read_min ;
      random_num3_0t15_rd <= ($random % (read_max  - read_min  + 1)) + read_min ;
      random_num4_0t15_rd <= ($random % (read_max  - read_min  + 1)) + read_min ;
      random_num5_0t15_rd <= ($random % (read_max  - read_min  + 1)) + read_min ;
      random_num_0t15_wr  <= ($random % (write_max - write_min + 1)) + write_min;
      random_num2_0t15_wr <= ($random % (write_max - write_min + 1)) + write_min;
      random_num3_0t15_wr <= ($random % (write_max - write_min + 1)) + write_min;
      random_num4_0t15_wr <= ($random % (write_max - write_min + 1)) + write_min;
      random_num5_0t15_wr <= ($random % (write_max - write_min + 1)) + write_min;

      random_arready  <= ($random % (arready_max  - arready_min  + 1)) + arready_min;
      random_awready  <= ($random % (awready_max  - awready_min  + 1)) + awready_min;

      random_rvalid   <= rvalid_max  > 0 ? ($random % (rvalid_max   - rvalid_min  + 1))  + rvalid_min  : amba_ready_delay;
      random_wready   <= wready_max  > 0 ? ($random % (wready_max   - wready_min  + 1))  + wready_min  : amba_ready_delay;
      random_bvalid   <= bvalid_max  > 0 ? ($random % (bvalid_max   - bvalid_min  + 1))  + bvalid_min  : amba_ready_delay;

       if (arready_ws_ctr == 0 & randomize_hready)
         arready_ws_ctr  <= random_num_0t15_rd % (max_random_num+1);
       else if (arready_ws_ctr == 0)
         arready_ws_ctr <= random_arready;
       else //if (arvalid)
         arready_ws_ctr <= arready_ws_ctr - 8'h01;

       if (awready_ws_ctr == 0 & randomize_hready)
         awready_ws_ctr <= random_num2_0t15_wr % (max_random_num+1);
       else if (awready_ws_ctr == 0)
         awready_ws_ctr <= random_awready;
       else //if (awvalid)
         awready_ws_ctr <= awready_ws_ctr - 8'h01;


       if ((arready & arvalid & ar_buffer_empty) | (rvalid_tmp & rready))
       begin
         dec_rvalid_ws_ctr  <= 1'b1;
         rvalid_ws_ctr <= randomize_hready ? random_num2_0t15_rd % (max_random_num+1) : amba_ready_delay;
       end

       // Hold rvalid until rready
       else if (rvalid_tmp)
         dec_rvalid_ws_ctr  <= 1'b0;
/*
       else if (rvalid_tmp & rlast_tmp)
       begin
         dec_rvalid_ws_ctr  <= 1'b0;
         rvalid_ws_ctr <= randomize_hready ? (random_num_0t15_rd+1) % (max_random_num+1): (amba_ready_delay+4'h1);
       end
*/
       else if (dec_rvalid_ws_ctr)
       begin
         if (ar_buffer_empty)
           dec_rvalid_ws_ctr  <= 1'b0;
         else
           rvalid_ws_ctr <= rvalid_ws_ctr - 8'h01;
       end

       if (wready_ws_ctr == 0 & randomize_hready)
         wready_ws_ctr <= random_num3_0t15_wr % (max_random_num+1);
       else if (wready_ws_ctr == 0)
         wready_ws_ctr <= amba_ready_delay;
       else if (wvalid)
         wready_ws_ctr <= wready_ws_ctr - 8'h01;

       if (wready & wvalid & wlast)
       begin
         if (~(bvalid & bready))
           num_reqd_bresps <= num_reqd_bresps + 1;
       end
       else if (bvalid&bready & (|num_reqd_bresps))
        num_reqd_bresps <= num_reqd_bresps - 1;

       if ((wready & wvalid & wlast & num_reqd_bresps == 4'h0) | //
           (bvalid & bready & num_reqd_bresps > 4'h1) |
           (bvalid & bready & num_reqd_bresps == 4'h1 & wready_tmp & wvalid & wlast))//
       begin
         dec_bvalid_ws_ctr  <= 1'b1;
         bvalid_ws_ctr <= randomize_hready ? random_num4_0t15_wr % (max_random_num+1) : amba_ready_delay;
       end
       else if (bvalid & bready)
       begin
         dec_bvalid_ws_ctr  <= 1'b0;
         bvalid_ws_ctr <= randomize_hready ? (random_num4_0t15_wr+1) % (max_random_num+1): (amba_ready_delay+4'h1);
       end
       else if (dec_bvalid_ws_ctr)
         bvalid_ws_ctr <= bvalid_ws_ctr - 8'h01;
     end



// -----------------------------------------------------------------------------
// hready stopping
// -----------------------------------------------------------------------------

   // read hready stop data from file
   initial
      begin
         for (j=1; j<=20; j=j+1)
            hready_vector_reg[j] = 32'b0;

         $readmemh("./files/tb_dma_hrdy.data",hready_vector_reg);
         if (hready_vector_reg[1] === 32'hx)
            $display("\n No dma hready stop file read \n");
      end

   // decode current vector
   assign hready_vector      = hready_vector_reg[hready_index];
   assign hready_stop_delay  = hready_vector[15:0];
   assign hready_stop_active = hready_vector[31:16];


   // assert hready_stop when count reaches hready_stop_active. Deassert again
   // when count reaches hready_stop_active.
   // End seen when hready_stop_active is zero.
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
         begin
            hready_stop_cnt <= 16'h0000;
            hready_stop     <= 1'b0;
            hready_index    <= 1;
         end
      else if (hready_stop_active == 16'h0000)
         begin
            hready_stop_cnt <= 16'h0000;
            hready_stop     <= 1'b0;
            hready_index    <= hready_index;
         end
      else if ((hready_stop_cnt == hready_stop_active) & hready_stop)
         begin
            hready_stop_cnt <= 16'h0000;
            hready_stop     <= 1'b0;
            hready_index    <= hready_index + 1;
         end
      else if ((hready_stop_cnt == hready_stop_delay) & ~hready_stop)
         begin
            hready_stop_cnt <= 16'h0000;
            hready_stop     <= 1'b1;
            hready_index    <= hready_index;
         end
      else
         begin
            hready_stop_cnt <= hready_stop_cnt + 16'h0001;
            hready_stop     <= hready_stop;
            hready_index    <= hready_index;
         end
   end




// -----------------------------------------------------------------------------
// check write & read address
// -----------------------------------------------------------------------------

  // If the DPRAM in the PBUF DMA is full, then it wont actually accept the descriptor read. It will discard it and retry it again
  // later.  This is a dynamic event and trans.pl cannot model it. therefore we rewind the pointer here.

  reg seen_descr_rd_access_id;
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      tx_rewind_index_en <= 1'b0;
      seen_descr_rd_access_id <= 1'b0;
    end
    else
    begin
      if (tx_descr_rd_resp)
        seen_descr_rd_access_id <= 1'b0;
      else if(tx_descr_rd_access & valid_dr_access)
        seen_descr_rd_access_id <= 1'b1;

      if (tx_rewind_index_en & (tx_current_queue_descr_resp == top_queue))
        tx_rewind_index_en <= 1'b0;
      else if ((tx_descr_rd_access|seen_descr_rd_access_id) & tx_descr_rd_resp & ~db1_push[tx_current_queue_descr_resp] & using_tx_descr &
                (~used_bit_read | used_err_on_descr_rd) & ~ignore_remaining_desc_rds[tx_current_queue_descr_resp])
        tx_rewind_index_en <= 1'b0;
      // also rewind if design read a used bit, but it had already read some non used descriptors previously and the TX descriptor read buffer is
      // therefore non-empty - in this case, the design will completely ignore the used and will reattempt a new read later.
      // If this is a random test and we are currently reading a used bit (indicated by tx_descr_rd_access & using_tx_descr &
      // used_bit_read), and the descriptor buffer isnt empty (tx_descr_rd_resp_cnt != 0), then the used bit will be read, the
      // TX descr file index will increment as normal. But since the used bit was ignored by the design, we will have to replay it, so
      // we'll rewind the pointer back 2 places to the where the used bit is located
      // currently doesnt work in priority queues - will need explicit repead used bits in testcase itself, or will need to model this more
      // accurately here
    `ifdef dma_priority_queue1
    `else
      else if ((tx_descr_rd_access|seen_descr_rd_access_id) & tx_descr_rd_resp & ~db1_push[tx_current_queue_descr_resp] & using_tx_descr &
                used_bit_read & ~ignore_remaining_desc_rds[tx_current_queue_descr_resp] & tx_descr_rd_resp_cnt != 0)
        tx_rewind_index_en <= 1'b0;
    `endif

      if ((tx_current_queue_descr_resp == top_queue) & ~seen_descr_rd_access_id & tx_descr_rd_access & valid_dr_access)
        tx_rewind_index <= tx_descr_next_dma_rd_index;

    end
  end


/*
  // Also on TX, since the TX descriptor read buffer in AXI configurations can be quite large, and we can issue the AR requests well in
  // advance of the responses,the DMA may issue lots of requests that may eventually be dropped by the DMA.
  // For example, if the DMA issues 10 requests for descriptors.  After the 3rd response, the wrap bit was set
  // All responses following that 3rd response should be discarded by the DMA. This is not modelled by trans.pl, so we need to mdoel it
  // here
  reg descr_rd_ignoreds_by_design_en;
  reg [31:0] descr_rd_ignoreds_by_design_cmp_add;
  wire descr_rd_ignoreds_by_design;
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      descr_rd_ignoreds_by_design_en <= 1'b0;
      descr_rd_ignoreds_by_design_cmp_add <= 32'h00000000;
    end
    else
    begin
      if (tx_descr_rd_resp)
      begin
        if (using_tx_descr)
        begin
          if (|tx_descr_pri_buff_in[63:62])
            // Wrap/Used bit was detected.  Any descriptor reads with addresses within 16 bytes of the current address
            // will be ignroed by design and can have the data randomize. Dont increment the pointers if this is detected
            descr_rd_ignoreds_by_design_en <= 1'b1;
          else
            descr_rd_ignoreds_by_design_en <= 1'b0;
        end

        descr_rd_ignoreds_by_design_cmp_add <= araddr_data_cmp;
      end
    end
  end
//  assign descr_rd_ignoreds_by_design = ~using_tx_descr &
//                                       descr_rd_ignoreds_by_design_en & ((araddr_data_cmp == descr_rd_ignoreds_by_design_cmp_add + 4) |
//                                                                         (araddr_data_cmp == descr_rd_ignoreds_by_design_cmp_add + 8) |
//                                                                         (araddr_data_cmp == descr_rd_ignoreds_by_design_cmp_add + 12) |
//                                                                         (araddr_data_cmp == descr_rd_ignoreds_by_design_cmp_add + 16) |
//                                                                         (araddr_data_cmp == descr_rd_ignoreds_by_design_cmp_add + 20) |
//                                                                         (araddr_data_cmp == descr_rd_ignoreds_by_design_cmp_add + 24) |
//                                                                         (araddr_data_cmp == descr_rd_ignoreds_by_design_cmp_add + 28) |
//                                                                         (araddr_data_cmp == descr_rd_ignoreds_by_design_cmp_add + 32)
//                                                                         );


*/

  assign descr_rd_ignoreds_by_design = 1'b0;

  assign final_descr_rds_filling_buffers = (valid_dr_access & ~r_is_tx & r_is_descr &
                                            ~using_orig & ~using_q1 & ~using_q2 & ~using_q3 & ~using_q4 & ~using_q5 & ~using_q6 & ~using_q7 &
                                            ~using_q8 & ~using_q9 & ~using_q10 & ~using_q11 & ~using_q12 & ~using_q13 & ~using_q14 & ~using_q15 &
                                            ~using_tx_data_q0 & ~using_tx_descr & (
                                                 (current_rx_queue_resp == 4'h0 & dma_rd_vector_nxt_orig[98])
                                            `ifdef dma_priority_queue1
                                             |   (current_rx_queue_resp == 4'h1 & dma_rd_vector_nxt_q1[98])
                                             |   (current_rx_queue_resp == 4'h2 & dma_rd_vector_nxt_q2[98])
                                             |   (current_rx_queue_resp == 4'h3 & dma_rd_vector_nxt_q3[98])
                                             |   (current_rx_queue_resp == 4'h4 & dma_rd_vector_nxt_q4[98])
                                             |   (current_rx_queue_resp == 4'h5 & dma_rd_vector_nxt_q5[98])
                                             |   (current_rx_queue_resp == 4'h6 & dma_rd_vector_nxt_q6[98])
                                             |   (current_rx_queue_resp == 4'h7 & dma_rd_vector_nxt_q7[98])
                                             |   (current_rx_queue_resp == 4'h8 & dma_rd_vector_nxt_q8[98])
                                             |   (current_rx_queue_resp == 4'h9 & dma_rd_vector_nxt_q9[98])
                                             |   (current_rx_queue_resp == 4'd10 & dma_rd_vector_nxt_q10[98])
                                             |   (current_rx_queue_resp == 4'd11 & dma_rd_vector_nxt_q11[98])
                                             |   (current_rx_queue_resp == 4'd12 & dma_rd_vector_nxt_q12[98])
                                             |   (current_rx_queue_resp == 4'd13 & dma_rd_vector_nxt_q13[98])
                                             |   (current_rx_queue_resp == 4'd14 & dma_rd_vector_nxt_q14[98])
                                             |   (current_rx_queue_resp == 4'd15 & dma_rd_vector_nxt_q15[98])
                                            `endif
                                             ));



  assign tx_final_descr_filling_buffers = (valid_dr_access & r_is_tx & r_is_descr &
                                              ((dma_rd_vector_nxt_tx_data_q0[98]   & ~using_tx_descr & ~using_tx_descr_q1 & ~using_tx_descr_q2 & ~using_tx_descr_q3 & ~using_tx_descr_q4 & ~using_tx_descr_q5 & ~using_tx_descr_q6 & ~using_tx_descr_q7 & ~using_tx_descr_q8 & ~using_tx_descr_q9 & ~using_tx_descr_q10 & ~using_tx_descr_q11 & ~using_tx_descr_q12 & ~using_tx_descr_q13 & ~using_tx_descr_q14 & ~using_tx_descr_q15) |
                                               (dma_rd_vector_nxt_tx_descr[98]     & tx_current_queue_descr_resp == 4'h0) |
                                               (dma_rd_vector_nxt_tx_descr_q1[98]  & tx_current_queue_descr_resp == 4'h1) |
                                               (dma_rd_vector_nxt_tx_descr_q2[98]  & tx_current_queue_descr_resp == 4'h2) |
                                               (dma_rd_vector_nxt_tx_descr_q3[98]  & tx_current_queue_descr_resp == 4'h3) |
                                               (dma_rd_vector_nxt_tx_descr_q4[98]  & tx_current_queue_descr_resp == 4'h4) |
                                               (dma_rd_vector_nxt_tx_descr_q5[98]  & tx_current_queue_descr_resp == 4'h5) |
                                               (dma_rd_vector_nxt_tx_descr_q6[98]  & tx_current_queue_descr_resp == 4'h6) |
                                               (dma_rd_vector_nxt_tx_descr_q7[98]  & tx_current_queue_descr_resp == 4'h7) |
                                               (dma_rd_vector_nxt_tx_descr_q8[98]  & tx_current_queue_descr_resp == 4'h8) |
                                               (dma_rd_vector_nxt_tx_descr_q9[98]  & tx_current_queue_descr_resp == 4'h9) |
                                               (dma_rd_vector_nxt_tx_descr_q10[98] & tx_current_queue_descr_resp == 4'ha) |
                                               (dma_rd_vector_nxt_tx_descr_q11[98] & tx_current_queue_descr_resp == 4'hb) |
                                               (dma_rd_vector_nxt_tx_descr_q12[98] & tx_current_queue_descr_resp == 4'hc) |
                                               (dma_rd_vector_nxt_tx_descr_q13[98] & tx_current_queue_descr_resp == 4'hd) |
                                               (dma_rd_vector_nxt_tx_descr_q14[98] & tx_current_queue_descr_resp == 4'he) |
                                               (dma_rd_vector_nxt_tx_descr_q15[98] & tx_current_queue_descr_resp == 4'hf)));


  // If the design issues a descriptor read and we reply with a wrap or used bit set, it is possible the design could race ahead and supply
  // more descriptor reads that the test doesnt expect.  We can detect these extra reads by looking at the wrap bit.
  //  we may need to rewind pointer on datafile
  integer abc;
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      for (abc=0;abc<16;abc++)
      begin
        nxt_ignored_add_descr_tx[abc] <= 64'h00000000_00000000;
        nxt_ignored_add_descr_rx[abc] <= 64'h00000000_00000000;
      end
      nxt_ignored_add_data_tx <= 64'h00000000_00000000;
      repeating <= 1'b1;
    end
    else
    begin
      if (valid_dr_access)
      begin
        // Update nxt_ignored_add when we are repeating ...
        if (r_is_tx && !r_is_descr && repeat_var)
        begin
          repeating <= 1'b1;
          case (dma_bus_width)
            2'b00   : nxt_ignored_add_data_tx <= araddr_data_cmp + 4;
            2'b01   : nxt_ignored_add_data_tx <= araddr_data_cmp + 8;
            default : nxt_ignored_add_data_tx <= araddr_data_cmp + 16;
          endcase
        end
        // Update nxt_ignored_add on the last of the descriptor fetches ... This changes dependent on 64 bit addressing and data bus width
        else if (r_is_tx && repeating && ignore_data_rd_add_mismatch_tx)
        begin
            case (dma_bus_width)
            2'b00   : nxt_ignored_add_data_tx <= nxt_ignored_add_data_tx + 4;
            2'b01   : nxt_ignored_add_data_tx <= nxt_ignored_add_data_tx + 8;
            default : nxt_ignored_add_data_tx <= nxt_ignored_add_data_tx + 16;
            endcase
        end
        else
        begin
          repeating <= 1'b0;
          nxt_ignored_add_data_tx <= 64'h00000000_00000000;
        end

        if (r_is_tx & r_is_descr && tx_descr_rd_resp)
        begin
          repeating <= 1'b0;
          if (gem_dma_addr_w_is_64 | apb_tx_ext_bd_mode_en) // the address of the tranaction followimng this will be +4 for 32 bit DP's, +8 for all others
            nxt_ignored_add_descr_tx[tx_current_queue_descr_resp] <= (araddr_data_cmp + 4);
          else // the address of the tranaction followimng this will always be +8, even for 32bit
            nxt_ignored_add_descr_tx[tx_current_queue_descr_resp] <= (araddr_data_cmp + 8);
        end
        if (~r_is_tx && r_is_descr)
        begin
          if ((~gem_dma_addr_w_is_64 & ~araddr_data_cmp[2]) |
              (gem_dma_addr_w_is_64 & araddr_data_cmp[3]))
            nxt_ignored_add_descr_rx[current_rx_queue_resp] <= (araddr_data_cmp + 8 + (8*gem_dma_addr_w_is_64));
        end
      end
    end
  end

  assign ignore_data_rd_add_mismatch_tx = valid_dr_access & !r_is_descr & r_is_tx &
                                        araddr_data_cmp[31:0] !== next_read_add[31:0] & araddr_data_cmp[31:0] == nxt_ignored_add_data_tx[31:0];

  // Ignore mismatching addresses if the DUT issues a descriptor read that is pre-fetching the next descriptor
  assign ignore_descr_rd_add_mismatch_tx = valid_dr_access & r_is_descr & r_is_tx &
                                        araddr_data_cmp[31:0] !== next_read_add[31:0] &
                                       (   (araddr_data_cmp[31:0] ==  nxt_ignored_add_descr_tx[tx_current_queue_descr_resp][31:0]      | (araddr_data_cmp[31:0] == (nxt_ignored_add_descr_tx[tx_current_queue_descr_resp][31:0] + 4))) |
                                         (((araddr_data_cmp[31:0] == (nxt_ignored_add_descr_tx[tx_current_queue_descr_resp][31:0]+8))  | (araddr_data_cmp[31:0] == (nxt_ignored_add_descr_tx[tx_current_queue_descr_resp][31:0] + 12))) & (gem_dma_addr_w_is_64|apb_tx_ext_bd_mode_en)) |
                                         (((araddr_data_cmp[31:0] == (nxt_ignored_add_descr_tx[tx_current_queue_descr_resp][31:0]+16)) | (araddr_data_cmp[31:0] == (nxt_ignored_add_descr_tx[tx_current_queue_descr_resp][31:0] + 20))) & (gem_dma_addr_w_is_64&apb_tx_ext_bd_mode_en)));

  assign ignore_descr_rd_add_mismatch_rx = valid_dr_access & r_is_descr & ~r_is_tx &
                                        araddr_data_cmp[31:0] !== next_read_add[31:0] &
                                       (((araddr_data_cmp[31:3] == nxt_ignored_add_descr_rx[current_rx_queue_resp][31:3]) & ~gem_dma_addr_w_is_64) |
                                        ((araddr_data_cmp[31:4] == nxt_ignored_add_descr_rx[current_rx_queue_resp][31:4]) & gem_dma_addr_w_is_64));

  assign ignore_rd_add_mismatch = ignore_descr_rd_add_mismatch_tx | ignore_descr_rd_add_mismatch_rx | ignore_data_rd_add_mismatch_tx;


   // check write & read address
   assign araddr_data_cmp = dma_bus_width == 2'b01 ? araddr_data + r_burst_ptr*8 :
                            dma_bus_width == 2'b00 ? araddr_data + r_burst_ptr*4 :
                                                     araddr_data + r_burst_ptr*16;

   assign awaddr_data_cmp = dma_bus_width == 2'b01 ? awaddr_data + w_burst_ptr*8 :
                            dma_bus_width == 2'b00 ? awaddr_data + w_burst_ptr*4 :
                                                     awaddr_data + w_burst_ptr*16;
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      address_fail <= 1'b0;
      qos_rd_fail <= 1'b0;
      qos_wr_fail <= 1'b0;
    end
    else
    begin
      // check DMA write address
      if (double_error_injection) // Ignore all writes !
      begin
      end
      else if (valid_dw_access)
      begin
        if (gem_dma_addr_w_is_64)
        begin
         // check DMA write address
          if (awaddr_data_cmp !== next_write_add)
          begin
            $display("\n **** error DMA WRITE ADDRESS expected :- %h  got :- %h (%0dns)",next_write_add,awaddr_data_cmp,$time);
            address_fail <= 1'b1;
          end
          else if (awaddr_data_cmp === next_write_add)
          begin
            if (!qos_correct_wr)
            begin
              qos_wr_fail <= 1'b1;
              `ifdef debugmsglvl0
              `else
              $display("\n **** error DMA WR QOS got :- %h (%0dns)",awqos_data,$time);
              `endif
            end
            `ifdef debugmsglvl0
            `else
            $display("       good DMA WRITE ADDRESS expected :- %h  got :- %h",next_write_add,awaddr_data_cmp);
            `endif
            address_fail <= 1'b0;
          end
          else
          begin
            $display("\n **** error DMA WRITE ADDRESS expected :- %h  got :- %h (%0dns)",next_write_add,awaddr_data_cmp,$time);
            address_fail <= 1'b1;
          end
        end
        else
        begin
          if (awaddr_data_cmp[31:0] !== next_write_add[31:0])
          begin
            $display("\n **** error DMA WRITE ADDRESS expected :- %h  got :- %h (%0dns)",next_write_add[31:0],awaddr_data_cmp[31:0],$time);
            address_fail <= 1'b1;
          end
          else if (awaddr_data_cmp[31:0] === next_write_add[31:0])
          begin
            if (!qos_correct_wr)
            begin
              qos_wr_fail <= 1'b1;
              `ifdef debugmsglvl0
              `else
              $display("\n **** error DMA WR QOS got :- %h (%0dns)",awqos_data,$time);
              `endif
            end

            `ifdef debugmsglvl0
            `else
            $display("       good DMA WRITE ADDRESS expected :- %h  got :- %h",next_write_add[31:0],awaddr_data_cmp[31:0]);
            `endif
            address_fail <= 1'b0;
          end
          else
          begin
            $display("\n **** error DMA WRITE ADDRESS expected :- %h  got :- %h (%0dns)",next_write_add[31:0],awaddr_data_cmp[31:0],$time);
            address_fail <= 1'b1;
          end
        end
      end


      if (valid_dr_access)
      begin
      if (double_error_injection)
      begin
       // $display("       Double error injection test - just responding to read with fixed data pattern ..time %0x",$time);
      end

      else if (~using_orig &
          ~using_q2 &
          ~using_q3 &
          ~using_q4 &
          ~using_q5 &
          ~using_q6 &
          ~using_q7 &
          ~using_q8 &
          ~using_q9 &
          ~using_q10 &
          ~using_q11 &
          ~using_q12 &
          ~using_q13 &
          ~using_q14 &
          ~using_q15 &
          ~using_tx_data_q0 &
          ~using_tx_descr &
          ~using_tx_descr_q1 &
          ~using_tx_descr_q2 &
          ~using_tx_descr_q3 &
          ~using_tx_descr_q4 &
          ~using_tx_descr_q5 &
          ~using_tx_descr_q6 &
          ~using_tx_descr_q7 &
          ~using_tx_descr_q8 &
          ~using_tx_descr_q9 &
          ~using_tx_descr_q10 &
          ~using_tx_descr_q11 &
          ~using_tx_descr_q12 &
          ~using_tx_descr_q13 &
          ~using_tx_descr_q14 &
          ~using_tx_descr_q15 &
          descr_rd_ignoreds_by_design
         )
        begin
          //$display("       Multiple TX descriptor requests were issued. One of the non-last completions had the used/wrap bit set, so design\nwill discard the rest. Testbench will complete with random responses. Address = %h (%0dns)",araddr_data_cmp[31:0],$time);
         `ifdef debugmsglvl0
         `else
          $display("       Ignoring TX descriptor read as the DUT issued it following a wrap and the DUT will discard it. Address = %h (%0dns)",araddr_data_cmp[31:0],$time);
          `endif
        end

        else if (final_descr_rds_filling_buffers)
        begin
          `ifdef debugmsglvl0
          `else
          $display("       Unexpected Final few RX Descriptor Read from design is OKAY(filling up DUT's descriptor buffer. Address = %h (%0dns)",araddr_data_cmp[31:0],$time);
          `endif
        end

        else if (tx_final_descr_filling_buffers)
        begin
          `ifdef debugmsglvl0
          `else
          $display("       Unexpected Final few TX Descriptor Read from design is OKAY(filling up DUT's descriptor buffer. Address = %h (%0dns)",araddr_data_cmp[31:0],$time);
          `endif
        end
       // check DMA read address
        else if (gem_dma_addr_w_is_64)
        begin
          if (ignore_rd_add_mismatch)
          begin
            `ifdef debugmsglvl0
            `else
            $display("       Ignoring mismatching DMA READ ADDRESS (part of descr prefetch that is dont care for this test)  expected :- %h  got :- %h",next_read_add,araddr_data_cmp);
            `endif
          end
          else if (araddr_data_cmp === next_read_add)
          begin
            if (!qos_correct_rd)
            begin
              qos_rd_fail <= 1'b1;
              `ifdef debugmsglvl0
              `else
              $display("\n **** error DMA RD QOS got :- %h (%0dns)",arqos_data,$time);
              `endif
            end
            `ifdef debugmsglvl0
            `else
            $display("       good DMA READ ADDRESS  expected :- %h  got :- %h",next_read_add,araddr_data_cmp);
            address_fail <= 1'b0;
            `endif
          end
          else
          begin
            $display("\n **** error DMA READ ADDRESS  expected :- %h  got :- %h (%0dns)",next_read_add,araddr_data_cmp,$time);
            address_fail <= 1'b1;
          end
        end
        else
        begin
          if (ignore_rd_add_mismatch)
          begin
            `ifdef debugmsglvl0
            `else
            $display("       Ignoring mismatching DMA READ ADDRESS (part of descr prefetch that is dont care for this test)  expected :- %h  got :- %h",next_read_add[31:0],araddr_data_cmp[31:0]);
            `endif
          end
          else if (araddr_data_cmp[31:0] !== next_read_add[31:0])
          begin
            $display("\n **** error DMA READ ADDRESS  expected :- %h  got :- %h (%0dns)",next_read_add[31:0],araddr_data_cmp[31:0],$time);
            address_fail <= 1'b1;
          end
          else if (araddr_data_cmp[31:0] === next_read_add[31:0])
          begin
            if (!qos_correct_rd)
            begin
              qos_rd_fail <= 1'b1;
              `ifdef debugmsglvl0
              `else
              $display("\n **** error DMA RD QOS got :- %h (%0dns)",arqos_data,$time);
              `endif
            end
            `ifdef debugmsglvl0
            `else
            $display("       good DMA READ ADDRESS  expected :- %h  got :- %h",next_read_add[31:0],araddr_data_cmp[31:0]);
            address_fail <= 1'b0;
            `endif
          end
          else
          begin
            $display("\n **** error DMA READ ADDRESS  expected :- %h  got :- %h (%0dns)",next_read_add[31:0],araddr_data_cmp[31:0],$time);
            address_fail <= 1'b1;
          end
        end
      end
    end
  end



// -----------------------------------------------------------------------------
// check write data
// -----------------------------------------------------------------------------

   // check write data
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
         data_fail <= 1'b0;
      else if (valid_dw_access)
         begin

            if (double_error_injection)
            begin end
            // check DMA write data

            // first 32 bits
            else if (write_data_31to0[31:0] === 32'hzzzzzzzz)
            begin
            `ifdef debugmsglvl0
            `else
              $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
            `endif
            end
            else if ((data_written_end_swapped[31:0] & write_en_31to0) !== (write_data_31to0[31:0] & write_en_31to0[31:0]))
               begin
                  $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",(write_data_31to0[31:0] & write_en_31to0[31:0]),(data_written_end_swapped[31:0] & write_en_31to0),$time);
                  data_fail <= 1'b1;
               end
            else if ((data_written_end_swapped[31:0] & write_en_31to0) === (write_data_31to0[31:0] & write_en_31to0[31:0]))
               begin
                  `ifdef debugmsglvl0
                  `else
                  $display("       good DMA WRITE DATA    expected :- %h  got :- %h",(write_data_31to0[31:0] & write_en_31to0[31:0]),data_written_end_swapped[31:0]);
                  `endif
                  data_fail <= 1'b0;
               end
            else
               begin
                  $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",(write_data_31to0[31:0] & write_en_31to0[31:0]),(data_written_end_swapped[31:0] & write_en_31to0),$time);
                  data_fail <= 1'b1;
               end

            // 64 or 128 bit access
            if ({awsize_data[2],awsize_data[0]} >= 2'b01)
               if (write_data_63to32[31:0] === 32'hzzzzzzzz)
                begin
                `ifdef debugmsglvl0
                `else
                  $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                `endif
                end
               else if ((data_written_end_swapped[63:32] & write_en_63to32) !== (write_data_63to32[31:0] & write_en_63to32[31:0]))
                  begin
                     $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",(write_data_63to32[31:0] & write_en_63to32[31:0]),(data_written_end_swapped[63:32] & write_en_63to32),$time);
                     data_fail <= 1'b1;
                  end
               else if ((data_written_end_swapped[63:32] & write_en_63to32) === (write_data_63to32[31:0] & write_en_63to32[31:0]))
                  begin
                     `ifdef debugmsglvl0
                     `else
                     $display("       good DMA WRITE DATA    expected :- %h  got :- %h",(write_data_63to32[31:0] & write_en_63to32[31:0]),(data_written_end_swapped[63:32] & write_en_63to32));
                     `endif
                     // data_fail maintains current value
                  end
               else
                  begin
                     $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",(write_data_63to32[31:0] & write_en_63to32[31:0]),(data_written_end_swapped[63:32] & write_en_63to32),$time);
                     data_fail <= 1'b1;
                  end

            // 128 bit access
            if ({awsize_data[2],awsize_data[0]} >= 2'b10)
            begin
               if (write_data_95to64  === 32'hzzzzzzzz)
                begin
                `ifdef debugmsglvl0
                `else
                  $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                `endif
                end
               else if ((data_written_end_swapped[95:64] & write_en_95to64) !== (write_data_95to64 & write_en_95to64))
                  begin
                     $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",(write_data_95to64 & write_en_95to64),(data_written_end_swapped[95:64] & write_en_95to64),$time);
                     data_fail <= 1'b1;
                  end
               else if ((data_written_end_swapped[95:64] & write_en_95to64) === (write_data_95to64 & write_en_95to64))
                  begin
                     `ifdef debugmsglvl0
                     `else
                     $display("       good DMA WRITE DATA    expected :- %h  got :- %h",(write_data_95to64 & write_en_95to64),(data_written_end_swapped[95:64] & write_en_95to64));
                     `endif
                     // data_fail maintains current value
                  end
               else
                  begin
                     $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",(write_data_95to64 & write_en_95to64),(data_written_end_swapped[95:64] & write_en_95to64),$time);
                     data_fail <= 1'b1;
                  end

               if (write_data_127to96  === 32'hzzzzzzzz)
                begin
                `ifdef debugmsglvl0
                `else
                  $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                `endif
                end
               else if ((data_written_end_swapped[127:96] & write_en_127to96) !== (write_data_127to96 & write_en_127to96))
                  begin
                     $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",(write_data_127to96 & write_en_127to96),(data_written_end_swapped[127:96] & write_en_127to96),$time);
                     data_fail <= 1'b1;
                  end
               else if ((data_written_end_swapped[127:96] & write_en_127to96) === (write_data_127to96 & write_en_127to96))
                  begin
                     `ifdef debugmsglvl0
                     `else
                     $display("       good DMA WRITE DATA    expected :- %h  got :- %h",(write_data_127to96 & write_en_127to96),(data_written_end_swapped[127:96] & write_en_127to96));
                     `endif
                     // data_fail maintains current value
                  end
               else
                  begin
                     $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",(write_data_127to96 & write_en_127to96),(data_written_end_swapped[127:96] & write_en_127to96),$time);
                     data_fail <= 1'b1;
                  end
              end

         end // wr_data_phase
   end // always

  reg [3:0]   bresp_fifo_wr_ptr,bresp_fifo_rd_ptr;
  reg [15:0]  bresp_fifo;
  reg         wr_not_ok_sample;
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      bresp_fifo_wr_ptr <= 4'h0;
      bresp_fifo_rd_ptr <= 4'h0;
      wr_not_ok_sample  <= 1'b0;
    end
    else
    begin
      if (last_dw_access)
      begin
        wr_not_ok_sample  <= 1'b0;
        bresp_fifo[bresp_fifo_wr_ptr] <= wr_not_ok_sample | wr_not_ok ;
        bresp_fifo_wr_ptr <= bresp_fifo_wr_ptr + 4'h1;
      end
      else if (valid_dw_access)
        wr_not_ok_sample  <= wr_not_ok | wr_not_ok_sample;

      if (bvalid)
      begin
        bresp_fifo_rd_ptr <= bresp_fifo_rd_ptr + 4'h1;
      end
    end
  end
  assign bresp_tmp = bresp_fifo[bresp_fifo_rd_ptr] & ~(bresp_fifo_wr_ptr == bresp_fifo_rd_ptr) ? 2'b10 : 2'b00;


// -----------------------------------------------------------------------------
// drive read data
// -----------------------------------------------------------------------------

   // supply read data

  always @(*)
  begin
    #1;
    if (valid_dr_access)
    begin
      if (double_error_injection)
      begin
        rdata_tmp[127:0] = {4{32'h00808010}};
      end

      else if (ignore_rd_add_mismatch)
        rdata_tmp[127:0] = {4{32'h00808000}};
      else if (tx_final_descr_filling_buffers)
        rdata_tmp[127:0] = {128{1'b1}};
      else if (final_descr_rds_filling_buffers |
          ( ~using_orig &
            ~using_q2 &
            ~using_q3 &
            ~using_q4 &
            ~using_q5 &
            ~using_q6 &
            ~using_q7 &
            ~using_q8 &
            ~using_q9 &
            ~using_q10 &
            ~using_q11 &
            ~using_q12 &
            ~using_q13 &
            ~using_q14 &
            ~using_q15 &
            ~using_tx_data_q0 &
            descr_rd_ignoreds_by_design)
         )
      begin
        rdata_tmp[127:96] = $random;
        rdata_tmp[95:64] = $random;
        rdata_tmp[63:32] = $random;
        rdata_tmp[31:0] = $random;
      end
      else
       case ({arsize_data[2],arsize_data[0]})
       2'b00   : begin // 32 bit access
                    rdata_tmp[127:64] = 64'hx & {64{~fault_sim}};
                    `ifdef debugmsglvl0
                    `else
                    $display("            DMA READ DATA                                  %h (%0dns)",read_data_31to0[31:0],$time);
                    `endif
                    if (dma_bus_width[1])
                      if (rd_endian_swap)
                         case (araddr_data_cmp[3:2])
                            2'b00 : rdata_tmp[127:96] = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24]};
                            2'b01 : rdata_tmp[95:64]  = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24]};
                            2'b10 : rdata_tmp[63:32]  = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24]};
                            2'b11 : rdata_tmp[31:0]   = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24]};
                        endcase
                      else
                         case (araddr_data_cmp[3:2])
                            2'b00 : rdata_tmp[31:0]   = read_data_31to0;
                            2'b01 : rdata_tmp[63:32]  = read_data_31to0;
                            2'b10 : rdata_tmp[95:64]  = read_data_31to0;
                            2'b11 : rdata_tmp[127:96] = read_data_31to0;
                        endcase
                    else
                      if (rd_endian_swap)
                      begin
                        if (dma_bus_width[0])
                          rdata_tmp[63:0] = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24], 32'bx & {32{~fault_sim}}};
                        else
                          rdata_tmp[63:0] = {32'bx & {32{~fault_sim}},read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24]};
                      end
                      else
                        rdata_tmp[63:0] = {32'bx & {32{~fault_sim}}, read_data_31to0[31:0]};
                 end
       2'b01   : begin // 64 bit access
                    rdata_tmp[127:0] = 128'hx & {128{~fault_sim}};;
                    `ifdef debugmsglvl0
                    `else
                    $display("            DMA READ DATA                                  %h",read_data_31to0[31:0]);
                    $display("            DMA READ DATA                                  %h",read_data_63to32[31:0]);
                    `endif
                    // drive correct word lanes
                    if (dma_bus_width[1])
                      if (araddr_data_cmp[3])
                        if (rd_endian_swap)
                          rdata_tmp[63:0] = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24],
                                         read_data_63to32[7:0],read_data_63to32[15:8],read_data_63to32[23:16],read_data_63to32[31:24]};
                        else
                          rdata_tmp[127:64] = {read_data_63to32[31:0], read_data_31to0[31:0]};
                      else
                        if (rd_endian_swap)
                          rdata_tmp[127:64] = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24],
                                          read_data_63to32[7:0],read_data_63to32[15:8],read_data_63to32[23:16],read_data_63to32[31:24]};
                        else
                          rdata_tmp[63:0] = {read_data_63to32[31:0], read_data_31to0[31:0]};
                    else
                      if (rd_endian_swap)
                        rdata_tmp[63:0] = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24],
                                       read_data_63to32[7:0],read_data_63to32[15:8],read_data_63to32[23:16],read_data_63to32[31:24]};
                      else
                        rdata_tmp[63:0] = {read_data_63to32[31:0], read_data_31to0[31:0]};
                 end
       default : begin // 128 bit access
                    `ifdef debugmsglvl0
                    `else
                    $display("            DMA READ DATA                                  %h",read_data_31to0[31:0]);
                    $display("            DMA READ DATA                                  %h",read_data_63to32[31:0]);
                    $display("            DMA READ DATA                                  %h",read_data_95to64[31:0]);
                    $display("            DMA READ DATA                                  %h",read_data_127to96[31:0]);
                    `endif
                    // drive correct word lanes
                    if (rd_endian_swap)
                      rdata_tmp[127:0] = {read_data_31to0[7:0],read_data_31to0[15:8],read_data_31to0[23:16],read_data_31to0[31:24],
                                     read_data_63to32[7:0],read_data_63to32[15:8],read_data_63to32[23:16],read_data_63to32[31:24],
                                     read_data_95to64[7:0],read_data_95to64[15:8],read_data_95to64[23:16],read_data_95to64[31:24],
                                     read_data_127to96[7:0],read_data_127to96[15:8],read_data_127to96[23:16],read_data_127to96[31:24]};
                    else
                      rdata_tmp[127:0] = {read_data_127to96[31:0],read_data_95to64[31:0],read_data_63to32[31:0], read_data_31to0[31:0]};
                 end
       endcase
    end // rd_data_phase
  end // clock else

assign rresp = rd_not_ok;

// check wstrb
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      fail_3 <= 1'b0;
    end
    else
    begin
      if (wvalid & !double_error_injection) // ignore all fails when we are injecting double errors..
      begin
        if (awsize_data == 3'b010)  // 32 bit
        begin
          if (write_en_end_swapped_pad[31:0] != write_en_31to0 & wvalid & wready_tmp)
          begin
            $display("\n **** error on wstrb, got :- %h expected :- %h (%0dns)",write_en_end_swapped_pad[31:0],write_en_31to0,$time);
            fail_3 <= 1'b1;
          end
/*
          if (wstrb[15:0] != 16'h000f && wstrb[15:0] != 16'h00f0 && wstrb[15:0] != 16'h0f00 && wstrb[15:0] != 16'hf000)
          begin
            $display("\n **** error on wstrb, only using 32 bit datapath, but wstrb had upper bits set expected 8'h0f    got :- %h (%0dns)",wstrb,$time);
            fail_3 <= 1'b1;
          end
          // 32 bit bus width
          else if (wstrb != 16'h000f & dma_bus_width == 2'b00 )
          begin
           $display("\n **** error on wstrb, expected 8'h0f    got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          // 64 bit bus width
          else if (((( wr_endian_swap  & awaddr_data_cmp[2] == 1'b1) & wstrb != 16'h000f) |
                   ((~wr_endian_swap  & awaddr_data_cmp[2] == 1'b0) & wstrb != 16'h000f))  & dma_bus_width == 2'b01 )
          begin
           $display("\n **** error on wstrb, expected 8'h0f    got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          else if (((( wr_endian_swap  & awaddr_data_cmp[2] == 1'b0) & wstrb != 16'h00f0) |
                    ((~wr_endian_swap &  awaddr_data_cmp[2] == 1'b1) & wstrb != 16'h00f0)) && dma_bus_width == 2'b01)
          begin
           $display("\n **** error on wstrb, expected 8'hf0    got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          // 128 bus width
          else if (((( wr_endian_swap  & awaddr_data_cmp[3:2] == 2'b11) & wstrb != 16'h000f) |
                    ((~wr_endian_swap  & awaddr_data_cmp[3:2] == 2'b00) & wstrb != 16'h000f)) && dma_bus_width[1] )
          begin
           $display("\n **** error on wstrb, expected 16'h000f    got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          else if (((( wr_endian_swap  & awaddr_data_cmp[3:2] == 2'b10) & wstrb != 16'h00f0) |
                    ((~wr_endian_swap  & awaddr_data_cmp[3:2] == 2'b01) & wstrb != 16'h00f0)) && dma_bus_width[1] )
          begin
           $display("\n **** error on wstrb, expected 16'h00f0    got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          else if (((( wr_endian_swap  & awaddr_data_cmp[3:2] == 2'b01) & wstrb != 16'h0f00) |
                    ((~wr_endian_swap  & awaddr_data_cmp[3:2] == 2'b10) & wstrb != 16'h0f00)) && dma_bus_width[1] )
          begin
           $display("\n **** error on wstrb, expected 16'h0f00    got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          else if (((( wr_endian_swap  & awaddr_data_cmp[3:2] == 2'b00) & wstrb != 16'hf000) |
                    ((~wr_endian_swap  & awaddr_data_cmp[3:2] == 2'b11) & wstrb != 16'hf000)) && dma_bus_width[1] )
          begin
           $display("\n **** error on wstrb, expected 16'hf000    got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
*/
        end
        else if (awsize_data == 3'b011)  // 64 bit
        begin
          if (write_en_end_swapped_pad[63:0] != {write_en_63to32,write_en_31to0} & wvalid & wready_tmp)
          begin
            $display("\n **** error on wstrb, got :- %h expected :- %h (%0dns)",write_en_end_swapped_pad[63:0],{write_en_63to32,write_en_31to0},$time);
            fail_3 <= 1'b1;
          end
/*
          if (dma_bus_width==2'b00)
          begin
           $display("\n **** Can't do a 64 bit access in 32 bit mode. wstrb :  (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          else if (wstrb != 16'h00ff && dma_bus_width==2'b01)
          begin
           $display("\n **** error on wstrb, expected 16'h00ff  got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          else if (((( wr_endian_swap  & awaddr_data_cmp[3] == 1'b0) & wstrb != 16'hff00) |
                    ((~wr_endian_swap  & awaddr_data_cmp[3] == 1'b1) & wstrb != 16'hff00)) && dma_bus_width[1] )
          begin
           $display("\n **** error on wstrb, expected 16'hff00  got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
          else if (((( wr_endian_swap  & awaddr_data_cmp[3] == 1'b1) & wstrb != 16'h00ff) |
                    ((~wr_endian_swap  & awaddr_data_cmp[3] == 1'b0) & wstrb != 16'h00ff)) && dma_bus_width[1] )
          begin
           $display("\n **** error on wstrb, expected 16'h00ff  got :- %h (%0dns)",wstrb,$time);
           fail_3 <= 1'b1;
          end
*/
        end
        else if (awsize_data == 3'b100)  // 128 bit
        begin

          // TX descriptor writes have unique wstrb
          if (~apb_64b_addr_mode_en & apb_tx_ext_bd_mode_en & (using_q0_tx_descr_wr
          `ifdef dma_priority_queue1
            | using_q1_tx_descr_wr | using_q2_tx_descr_wr | using_q3_tx_descr_wr | using_q4_tx_descr_wr | using_q5_tx_descr_wr | using_q6_tx_descr_wr | using_q7_tx_descr_wr
            | using_q8_tx_descr_wr | using_q9_tx_descr_wr | using_q10_tx_descr_wr | using_q11_tx_descr_wr | using_q12_tx_descr_wr | using_q13_tx_descr_wr | using_q14_tx_descr_wr | using_q15_tx_descr_wr
          `endif
          ))
          begin
            if (((~wr_endian_swap & wstrb != 16'hfff0) | (wr_endian_swap & wstrb != 16'h0fff)) & wvalid & wready_tmp)
            begin
              $display("\n **** error on wstrb, expected 16'hfff0   got :- %h (%0dns)",wstrb,$time);
              fail_3 <= 1'b1;
            end
          end
          else if (write_en_end_swapped_pad != {write_en_127to96,write_en_95to64,write_en_63to32,write_en_31to0} & wvalid & wready_tmp)
          begin
           $display("\n **** error on wstrb, got :- %h expected :- %h   (%0dns)",write_en_end_swapped_pad,{write_en_127to96,write_en_95to64,write_en_63to32,write_en_31to0},$time);
           fail_3 <= 1'b1;
          end
        end
        else
        begin
           $display("\n **** error awsize not valid    got :- %h (%0dns)",awsize_data,$time);
           fail_3 <= 1'b1;
        end
      end
    end
  end

  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
      width_fail_reg  <=1'b0;
    else
      width_fail_reg  <=width_fail; // Removes any glitches on this caused by rx_enable or tx_enable
  end


/*
 // AXI requires that there is no dependency between read and write channels...
 //  section 8.6 Read and write interaction
 //    There are no ordering restrictions between read and write transactions and they are allowed to
 //    complete in any order.
 //    If a master requires a given relationship between read and write transaction then it must ensure
 //    that the earlier transaction is complete before issuing the later transaction. In the case of reads
 //    the earlier transaction can be considered complete when the last read data is returned to the
 //    master. In the case of writes the transaction can only be considered complete when the write
 //    response is received by the master, it is not acceptable to consider the write transaction complete
 //    when all the write data is sent.
 // By default the GEM introduces a dependency on RX descriptor writeback
 // and subsequent descriptor read for a new buffer descriptor.
 // An additional programmable mode ensures that the strict AXI protocol is
 // adhered to. We will check this with an assertion here...
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      fail_4 <= 1'b0;
    end
`ifdef rtl // Only check for RTL sims
    else if (axi_no_wr_rd_depend & (last_rx_dma_state == RX_DMA_MAN_WR) & dma_nxt_rx_descrd & arvalid & ~armaster_aph)
    begin
      $display("\n **** error DMA AXI DEPENDENCY BETWEEN READ AND WRITE CHANNELS - VALID RX DESCR READ WHILST RX DESCR WR INCOMPLETE (%0dns)",$time);
      fail_4 <= 1'b1;
    end
    else if (axi_no_wr_rd_depend & ~rready)
    begin
      $display("\n **** error DMA AXI DEPENDENCY BETWEEN READ AND WRITE CHANNELS - RREADY SEEN LOW (%0dns)",$time);
      fail_4 <= 1'b1;
    end
`endif
  end
*/

assign dma_done = dma_wr_done & dma_rd_done;
assign dma_fail = data_fail | address_fail | fail_1 | fail_2 | fail_3 | width_fail_reg | qos_wr_fail | qos_rd_fail; //  | fail_4;

  integer axi_perf_count,file;
  reg printed_last;
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      axi_perf_count <= 0;
      printed_last <= 1'b0;
    end
    else
    begin
      if (axi_perf_test)
      begin
        if (axi_perf_count == 0 & ((arvalid & arready_tmp) | (awvalid & awready_tmp)))
          axi_perf_count <= 1;
        else if (~(dma_rd_done & dma_wr_rx_done) & |axi_perf_count)
          axi_perf_count <= axi_perf_count + 1;
        else if (dma_done & ~printed_last)
        begin
          printed_last <= 1'b1;
          $display("\n AXI PERF TEST ENDED - NUMBER OF CYCLES FROM FIRST AXI READ/WRITE TO LAST AXI READ/WRITE = %0d (%0dns)",axi_perf_count,$time);
          file = $fopen ("axiperf.txt", "w");
          $fwrite (file, "%0d", axi_perf_count);
        end
      end
    end
  end


// Delay slightly for GL sims
initial begin
  arready = 1'b0;
  awready = 1'b0;
  wready  = 1'b0;
  rvalid  = 1'b0;
  rlast   = 1'b0;
  rdata   = 128'd0;
  rdata_tmp = 128'd0;
  rid     = 4'h0;
  bid     = 4'h0;
  bvalid  = 1'b0;
  bresp   = 2'b0;
end

always @(negedge hclk)
begin
  arready = arready_tmp;
  awready = awready_tmp;
  wready  = wready_tmp ;
  rvalid  = rvalid_tmp ;
  rlast   = rlast_tmp ;
  rid     = rid_tmp;
  rdata   = rdata_tmp;
  bid     = bid_tmp;
  bvalid  = bvalid_tmp ;
  bresp   = bresp_tmp ;
end
`endif


endmodule


