//------------------------------------------------------------------------------
// Copyright (c) 2001-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_dma.v
//   Module Name:        tb_dma
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


`include "tb_defs.v"

module tb_dma (
   reset_tb,
   hclk,
   fault_sim,
   double_error_injection,
   dma_bus_width,
   amba_ready_delay,
   bus_grant_delay,
   apb_endian_wr,
   apb_endian_val,

   //AHB Interface
   haddr,
   htrans,
   hwrite,
   hsize,
   hburst,
   hprot,
   hwdata,

   hrdata,
   hready,
   hresp,

   randomize_hgrant,
   randomize_hready,
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
   hbusreqdma,
   hlockdma,

   hgrantdma,

   dma_done,
   dma_fail,

   apb_64b_addr_mode_en

);

// -----------------------------------------------------------------------------
// Declare inputs and outputs
// -----------------------------------------------------------------------------
   input          reset_tb;            // test bench reset
   input          hclk;                // AHB clock bus
   input          fault_sim;           // Fault simulation avoid x
   input          double_error_injection; // Error injection, ignore errors!
   input    [1:0] dma_bus_width;       // DMA bus width
                                       // 00 = 32 bit
                                       // 01 = 64 bit
                                       // 1x = 128 bit
   input    [3:0] amba_ready_delay;    // number of clocks hready_tmp is delayed
   input    [3:0] bus_grant_delay;     // number of clocks hgrant is delayed
   input          apb_endian_wr;       // APB write to endianism value
   input    [1:0] apb_endian_val;      // APB endian value during write

   // AHB interface signals
   input   [`edma_addr_width-1:0] haddr;               // address to write to
   input    [1:0] htrans;              // transfer method
   input          hwrite;              // read/write
   input    [2:0] hsize;               // transfer size -
                                       // set to 3'b010 for 32 bit words
                                       // set to 3'b011 for 64 bit words
                                       // set to 3'b100 for 128 bit words
   input    [2:0] hburst;              // burst mode
   input    [3:0] hprot;               // AHB protection (fixed, not checked)
   input  [127:0] hwdata;              // Write data

   output [127:0] hrdata;              // read data
   output         hready;              // AHB Slave ready
   output   [1:0] hresp;               // AHB Slave response

   input          hbusreqdma;          // Bus request
   input          randomize_hgrant;    // Randomize Hgrant
   input          randomize_hready;    // Randomize Hready
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
   input          hlockdma;            // Lock the bus

   output         hgrantdma;           // AHB ARBITER control grant

   // test bench reporting stuff
   output         dma_done;            // Testbench complete
   output         dma_fail;            // Testbench failed

   input          apb_64b_addr_mode_en; // indicates 64b address mode reg has been enabled


// -----------------------------------------------------------------------------
// Declare internal signals
// -----------------------------------------------------------------------------

   // decode access size and address alignment
   reg      [1:0] access_width;        // async decode of access width
   reg      [1:0] access_width_saved;  // saved access_width for use in data ph
   reg      [1:0] haddr3_2_saved;      // saved haddr3_2 for use in data phase
   reg      [1:0] data_lane_sel_wr;    // data lane selected for write access
   reg      [1:0] data_lane_sel_rd;    // data lane selected for read access
   reg    [127:0] data_lane_written;   // selected write data for comparison
   reg      [1:0] endian_value;        // Current endianism value programmed
   wire           rd_endian_swap_saved;// Endian word swap saved
   reg            wr_endian_swap_saved;// Endian word swap saved
   wire           dma_nxt_tx_descrd;
   wire           dma_nxt_tx_descwr;
   wire           dma_nxt_rx_descrd;
   wire           dma_nxt_rx_descwr;

   // Detect burst errors
   reg            address_at_1k_bound; // bursting across a 1K boundary
   reg      [4:0] beat_count;          // burst beat count
   reg      [4:0] burst_length;        // burst length detected from HBURST

   // tb_dma array for test file read data storage
   reg     [99:0] dma_rd_vector_reg[1:200000];
                                       // array for storing test file data
   integer        next_dma_rd_index;   // next index to dma_rd_vector_reg
   integer        dma_rd_index;        // current index to dma_rd_vector_reg
   reg     [99:0] dma_rd_vector_alt_reg[1:200000];
                                       // array for storing test file data
   integer        alt_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        alt_dma_rd_index; // current index to dma_rd_vector_reg -
                                    // only used by random tb
   reg     [99:0] dma_rd_vector_tx_descr_reg[1:200000];
                                       // array for storing test file data
   integer        tx_descr_next_dma_rd_index;   // next index to dma_rd_vector_reg - only used by random tb
   integer        tx_descr_dma_rd_index; // current index to dma_rd_vector_reg -
                                    // only used by random tb
   integer        rewind_index_alt;        // current index to dma_rd_vector_reg -
                                       // only used by random tb
   integer        rewind_index_tx_descr;        // current index to dma_rd_vector_reg -
                                       // only used by random tb
   integer        j;                   // loop variable
   wire    [98:0] dma_rd_vector_plus0_orig; // current dma_rd_vector_reg
   wire    [98:0] dma_rd_vector_plus0_alt; // current dma_rd_vector_reg
   wire    [98:0] dma_rd_vector_plus0_tx_descr; // current dma_rd_vector_reg
   wire    [98:0] dma_rd_vector_nxt_orig; // next dma_rd_vector_reg
   wire    [98:0] dma_rd_vector_nxt_alt; // next dma_rd_vector_reg
   wire    [98:0] dma_rd_vector_nxt_tx_descr; // next dma_rd_vector_reg
   wire    [98:0] dma_rd_vector_plus0; // current dma_rd_vector_reg
   wire    [98:0] dma_rd_vector_plus1; // current dma_rd_vector_reg + 1
   wire    [98:0] dma_rd_vector_plus2; // current dma_rd_vector_reg + 2
   wire    [98:0] dma_rd_vector_plus3; // current dma_rd_vector_reg + 3
   wire    [31:0] read_data_31to0;     // read data to drive (31 to 0)
   wire    [31:0] read_data_63to32;    // read data to drive (63 to 32)
   wire    [31:0] read_data_95to64;    // read data to drive (95 to 64)
   wire    [31:0] read_data_127to96;   // read data to drive (127 to 96)
   wire    [98:0] next_dma_rd_vector;  // next dma_rd_vector_reg
   wire    [63:0] next_read_add_orig;       // expected read address
   wire    [63:0] next_read_add_alt;       // expected read address
   wire    [63:0] next_read_add_tx_descr;       // expected read address
   wire    [63:0] next_read_add;       // expected read address
   wire           rd_not_ok;           // whether the read will have an error
   wire           rd_endian_swap;      // Endian word swap
   wire           dma_rd_done;         // all read data complete
   wire    [31:0] read_data_31to0_end;  // read data to drive (31 to 0) endian swapped
   wire    [31:0] read_data_63to32_end; // read data to drive (63 to 32) endian swapped
   wire    [31:0] read_data_95to64_end; // read data to drive (95 to 64) endian swapped
   wire    [31:0] read_data_127to96_end;// read data to drive (127 to 96) endian swapped

   // tb_dma array for test file write data storage
   reg     [107:0] dma_wr_vector_reg[1:200000];
                                       // array for storing test file data
   integer        next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        dma_wr_index;        // current index to dma_wr_vector_reg
   integer        k;                   // loop variable
   wire    [98:0] dma_wr_vector_plus0_orig; // current dma_wr_vector_reg
   wire    [98:0] dma_wr_vector_plus0; // current dma_wr_vector_reg
   wire    [98:0] dma_wr_vector_plus1; // current dma_wr_vector_reg + 1
   wire    [98:0] dma_wr_vector_plus2; // current dma_wr_vector_reg + 2
   wire    [98:0] dma_wr_vector_plus3; // current dma_wr_vector_reg + 3
   wire    [31:0] write_data_31to0;    // expected write data (31 to 0)
   wire    [31:0] write_data_63to32;   // expected write data (63 to 32)
   wire    [31:0] write_data_95to64;   // expected write data (95 to 64)
   wire    [31:0] write_data_127to96;  // expected write data (127 to 96)
   wire    [98:0] next_dma_wr_vector_orig;  // next dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector;  // next dma_wr_vector_reg
   wire    [63:0] next_write_add_orig;      // next expected addr
   wire    [63:0] next_write_add;      // next expected addr
   wire           wr_not_ok;           // whether the write will have an error
   wire           wr_endian_swap;      // Endian word swap
   wire           dma_wr_done;         // all write data complete
   wire    [31:0] write_data_31to0_end;  // expected write data (31 to 0) endian swapped
   wire    [31:0] write_data_63to32_end; // expected write data (63 to 32) endian swapped
   wire    [31:0] write_data_95to64_end; // expected write data (95 to 64) endian swapped
   wire    [31:0] write_data_127to96_end;// expected write data (127 to 96) endian swapped


   // keep track of current AHB phase
   wire           wr_addr_phase;       // write address phase
   reg            wr_data_phase;       // write data phase
   wire           rd_addr_phase;       // read address phase
   reg            rd_data_phase;       // read data phase

   // outputs to the AHB
   reg    [127:0] hrdata_tmp;              // read data
   wire    [127:0] hrdata_tmp2;              // read data
   reg     [127:0] hrdata;              // read data
   reg    [127:0] hrdata_fill;         // read data fill outside of an access
   reg      [7:0] delay_hready;        // wait state counter before hready
   wire           insert_wait;         // New access detected insert waits
   reg            insert_wait_hold;    // insert_wait held
   reg            hready;              // AHB Slave ready
   reg            hready_tmp;          // AHB Slave ready
   reg      [1:0] hresp;               // AHB Slave response (retimed)
   reg      [1:0] hresp_tmp;           // AHB Slave response
   reg      [3:0] grant_cnt;           // hgrant delay from hbusreq
   reg            hgrantdma_tmp;       // AHB ARBITER control grant
   reg            hgrantdma;           // AHB ARBITER control grant

   // test bench fail detection
   reg            data_fail;           // write data compare failed
   reg            address_fail;        // address compare failed
   reg            width_fail_reg;      // not a valid width/address combination
   reg            width_fail;          // not a valid width/address combination
   reg            burst_fail;          // invalid hburst
   reg            hprot_fail;          // invalid hprot

   // hready stopping
   reg     [`edma_addr_width:0] hready_vector_reg [1:20];  // array used for reading file
   wire    [`edma_addr_width:0] hready_vector;       // current hready_vector_reg
   integer        hready_index;        // pointer to current hready_vector
   reg            hready_stop;         // stop hready_tmp whilst active
   reg     [15:0] hready_stop_cnt;     // counter used for hready_tmp stopping
   wire    [15:0] hready_stop_delay;   // delay before asserting hready_stop
   wire    [15:0] hready_stop_active;  // how long hready_stop is asserted for
   reg     [7:0]  random_hready;

   reg            hmastlock;
   reg            lock_nxt_burst;
   reg     [`edma_addr_width:0] locka_addr;
   reg            reset_tb_sync;       // to make behaviour same in Questa

   reg [2:0]  descr_rd_cnt;
   `ifdef dma_priority_queue1
   reg        descrd_auto_comp;
   `else
   wire       descrd_auto_comp;
   `endif
   wire       bf_auto_complete_descrd;
   wire       extra_ahb_read_descr_rd;
   reg        alt_cycle_32bit_aph;
   reg        alt_cycle_32bit_dph;

   integer        alt_next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        alt_dma_wr_index;        // current index to dma_wr_vector_reg
   integer        next_dma_rx_wr_descr_index;        // current index to dma_wr_vector_reg
   integer        dma_rx_wr_descr_index;        // current index to dma_wr_vector_reg
   reg     [107:0] alt_dma_wr_vector_reg[1:200000];
   reg     [107:0] dma_rx_wr_descr_vector_reg[1:200000];
                                       // array for storing test file data
   wire    [98:0] dma_wr_vector_plus0_alt; // current dma_wr_vector_reg
   wire    [99:0] dma_rx_wr_descr_vector_plus0; // current dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector_alt;  // next dma_wr_vector_reg
   wire    [`edma_addr_width:0] next_write_add_alt,next_write_add_rx_descr;      // next expected addr
   wire    [99:0] next_dma_rx_wr_descr_vector;  // next dma_wr_vector_reg

   wire           using_orig;
   wire           using_tx_descr;
   wire           using_orig_wr;
   wire           using_alt_wr,alt_wr,using_rx_descr_wr;
   reg            using_alt_wr_dph,using_alt_rd_dph,using_rx_descr_wr_dph,using_tx_descr_rd_dph;
   wire           dma_nxt_tx_data;
   wire           dma_nxt_tx_idle;
   `ifdef dma_priority_queue1
   integer        q1_next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        q1_dma_wr_index;        // current index to dma_wr_vector_reg
   reg     [107:0] q1_dma_wr_vector_reg[1:200000];
                                       // array for storing test file data
   wire    [98:0] dma_wr_vector_plus0_q1; // current dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector_q1;  // next dma_wr_vector_reg
   wire    [`edma_addr_width:0] next_write_add_q1;      // next expected addr

   wire           using_q1_wr;
   reg            using_q1_wr_dph;

   integer        q2_next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        q2_dma_wr_index;        // current index to dma_wr_vector_reg
   reg     [107:0] q2_dma_wr_vector_reg[1:200000];
                                       // array for storing test file data
   wire    [98:0] dma_wr_vector_plus0_q2; // current dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector_q2;  // next dma_wr_vector_reg
   wire    [`edma_addr_width:0] next_write_add_q2;      // next expected addr

   wire           using_q2_wr;
   reg            using_q2_wr_dph;

   integer        q3_next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        q3_dma_wr_index;        // current index to dma_wr_vector_reg
   reg     [107:0] q3_dma_wr_vector_reg[1:200000];
                                       // array for storing test file data
   wire    [98:0] dma_wr_vector_plus0_q3; // current dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector_q3;  // next dma_wr_vector_reg
   wire    [`edma_addr_width:0] next_write_add_q3;      // next expected addr

   wire           using_q3_wr;
   reg            using_q3_wr_dph;

   integer        q4_next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        q4_dma_wr_index;        // current index to dma_wr_vector_reg
   reg     [107:0] q4_dma_wr_vector_reg[1:200000];
                                       // array for storing test file data
   wire    [98:0] dma_wr_vector_plus0_q4; // current dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector_q4;  // next dma_wr_vector_reg
   wire    [`edma_addr_width:0] next_write_add_q4;      // next expected addr

   wire           using_q4_wr;
   reg            using_q4_wr_dph;

   integer        q5_next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        q5_dma_wr_index;        // current index to dma_wr_vector_reg
   reg     [107:0] q5_dma_wr_vector_reg[1:200000];
                                       // array for storing test file data
   wire    [98:0] dma_wr_vector_plus0_q5; // current dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector_q5;  // next dma_wr_vector_reg
   wire    [`edma_addr_width:0] next_write_add_q5;      // next expected addr

   wire           using_q5_wr;
   reg            using_q5_wr_dph;

   integer        q6_next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        q6_dma_wr_index;        // current index to dma_wr_vector_reg
   reg     [107:0] q6_dma_wr_vector_reg[1:200000];
                                       // array for storing test file data
   wire    [98:0] dma_wr_vector_plus0_q6; // current dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector_q6;  // next dma_wr_vector_reg
   wire    [`edma_addr_width:0] next_write_add_q6;      // next expected addr

   wire           using_q6_wr;
   reg            using_q6_wr_dph;

   integer        q7_next_dma_wr_index;   // next index to dma_wr_vector_reg
   integer        q7_dma_wr_index;        // current index to dma_wr_vector_reg
   reg     [107:0] q7_dma_wr_vector_reg[1:200000];
                                       // array for storing test file data
   wire    [98:0] dma_wr_vector_plus0_q7; // current dma_wr_vector_reg
   wire    [98:0] next_dma_wr_vector_q7;  // next dma_wr_vector_reg
   wire    [`edma_addr_width:0] next_write_add_q7;      // next expected addr

   wire           using_q7_wr;
   reg            using_q7_wr_dph;
   reg            dma_tx_descrd;
    `ifdef rtl
   wire           tx_buffer_full;
   `else
   wire            tx_buffer_full;
   `endif
   wire           rewind_index_en;
  `endif

  wire          gem_dma_addr_w_is_64;

  assign gem_dma_addr_w_is_64 = ((`edma_addr_width == 64) & apb_64b_addr_mode_en);  // if 'define and reg enabled



// -----------------------------------------------------------------------------
// Parameters declaration
// -----------------------------------------------------------------------------
   // htrans encoding
   parameter
      p_htrans_idle   = 2'b00,         // AHB IDLE access
      p_htrans_nseq   = 2'b10,         // AHB NONSEQ access
      p_htrans_seq    = 2'b11;         // AHB SEQ access

   // hsize encoding
   parameter
      p_hsize_32b    = 3'b010,         // AHB 32-bit access
      p_hsize_64b    = 3'b011,         // AHB 64-bit access
      p_hsize_128b   = 3'b100;         // AHB 128-bit access

   // hburst encoding
   parameter
      p_hburst_single  = 3'b000,       // AHB single access
      p_hburst_incr    = 3'b001,       // AHB INCR access
      p_hburst_incr_4  = 3'b011,       // AHB INCR4 access
      p_hburst_incr_8  = 3'b101,       // AHB INCR8 access
      p_hburst_incr_16 = 3'b111;       // AHB INCR16 access

   // hresp encoding
   parameter
      p_hresp_ok   = 2'b00;            // AHB OK response

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

  `ifdef dma_priority_queue7
   parameter top_queue = 3'h7;
  `else
    `ifdef dma_priority_queue6
    parameter top_queue = 3'h6;
    `else
      `ifdef dma_priority_queue5
      parameter top_queue = 3'h5;
      `else
        `ifdef dma_priority_queue4
        parameter top_queue = 3'h4;
        `else
          `ifdef dma_priority_queue3
          parameter top_queue = 3'h3;
          `else
            `ifdef dma_priority_queue2
             parameter top_queue = 3'h2;
            `else
              `ifdef dma_priority_queue1
              parameter top_queue = 3'h1;
              `else
              parameter top_queue = 3'h0;
              `endif
            `endif
          `endif
        `endif
      `endif
    `endif
  `endif

  `ifdef dma_priority_queue1
    `ifdef edma_tx_pbuf_num_segments_q0
     parameter edma_tx_pbuf_addr_q0  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size + `edma_tx_pbuf_num_segments_q0);
     parameter queue0_base          = {`edma_tx_pbuf_queue_segment_size{1'b0}};
     parameter queue0_top           = {{(`edma_tx_pbuf_queue_segment_size - `edma_tx_pbuf_num_segments_q0){1'b0}},{`edma_tx_pbuf_num_segments_q0{1'b1}}};
    `else
     parameter edma_tx_pbuf_addr_q0  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size);
     parameter queue0_base          = {`edma_tx_pbuf_queue_segment_size{1'b0}};
     parameter queue0_top           = {{`edma_tx_pbuf_queue_segment_size{1'b0}},1'b1};
    `endif
    `ifdef edma_tx_pbuf_num_segments_q1
     parameter edma_tx_pbuf_addr_q1  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size + `edma_tx_pbuf_num_segments_q1);
     parameter queue1_base          = queue0_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue1_top           = queue1_base + {{`edma_tx_pbuf_queue_segment_size - `edma_tx_pbuf_num_segments_q1{1'b0}},{`edma_tx_pbuf_num_segments_q1{1'b1}}};
    `else
     parameter edma_tx_pbuf_addr_q1  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size);
     parameter queue1_base          = queue0_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue1_top           = queue1_base + {(`edma_tx_pbuf_queue_segment_size){1'b0}};
    `endif
  `endif
  `ifdef dma_priority_queue2
    `ifdef edma_tx_pbuf_num_segments_q2
     parameter edma_tx_pbuf_addr_q2  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size + `edma_tx_pbuf_num_segments_q2);
     parameter queue2_base          = queue1_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue2_top           = queue2_base + {{`edma_tx_pbuf_queue_segment_size - `edma_tx_pbuf_num_segments_q2{1'b0}},{`edma_tx_pbuf_num_segments_q2{1'b1}}};
    `else
     parameter edma_tx_pbuf_addr_q2  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size);
     parameter queue2_base          = queue1_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue2_top           = queue2_base + {`edma_tx_pbuf_queue_segment_size{1'b0}};
    `endif
  `endif
  `ifdef dma_priority_queue3
    `ifdef edma_tx_pbuf_num_segments_q3
     parameter edma_tx_pbuf_addr_q3  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size + `edma_tx_pbuf_num_segments_q3);
     parameter queue3_base          = queue2_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue3_top           = queue3_base + {{`edma_tx_pbuf_queue_segment_size - `edma_tx_pbuf_num_segments_q3{1'b0}},{`edma_tx_pbuf_num_segments_q3{1'b1}}};
    `else
     parameter edma_tx_pbuf_addr_q3  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size);
     parameter queue3_base          = queue2_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue3_top           = queue3_base + {`edma_tx_pbuf_queue_segment_size{1'b0}};
    `endif
  `endif
  `ifdef dma_priority_queue4
    `ifdef edma_tx_pbuf_num_segments_q4
     parameter edma_tx_pbuf_addr_q4  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size + `edma_tx_pbuf_num_segments_q4);
     parameter queue4_base          = queue3_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue4_top           = queue4_base + {{`edma_tx_pbuf_queue_segment_size - `edma_tx_pbuf_num_segments_q4{1'b0}},{`edma_tx_pbuf_num_segments_q4{1'b1}}};
    `else
     parameter edma_tx_pbuf_addr_q4  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size);
     parameter queue4_base          = queue3_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue4_top           = queue4_base + {`edma_tx_pbuf_queue_segment_size{1'b0}};
    `endif
  `endif
  `ifdef dma_priority_queue5
    `ifdef edma_tx_pbuf_num_segments_q5
     parameter edma_tx_pbuf_addr_q5  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size + `edma_tx_pbuf_num_segments_q5);
     parameter queue5_base          = queue4_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue5_top           = queue5_base + {{`edma_tx_pbuf_queue_segment_size - `edma_tx_pbuf_num_segments_q5{1'b0}},{`edma_tx_pbuf_num_segments_q5{1'b1}}};
    `else
     parameter edma_tx_pbuf_addr_q5  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size);
     parameter queue5_base          = queue4_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue5_top           = queue5_base + {`edma_tx_pbuf_queue_segment_size{1'b0}};
    `endif
  `endif
  `ifdef dma_priority_queue6
    `ifdef edma_tx_pbuf_num_segments_q6
     parameter edma_tx_pbuf_addr_q6  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size + `edma_tx_pbuf_num_segments_q6);
     parameter queue6_base          = queue5_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue6_top           = queue6_base + {{`edma_tx_pbuf_queue_segment_size - `edma_tx_pbuf_num_segments_q6{1'b0}},{`edma_tx_pbuf_num_segments_q6{1'b1}}};
    `else
     parameter edma_tx_pbuf_addr_q6  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size);
     parameter queue6_base          = queue5_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue6_top           = queue6_base + {`edma_tx_pbuf_queue_segment_size{1'b0}};
    `endif
  `endif
  `ifdef dma_priority_queue7
    `ifdef edma_tx_pbuf_num_segments_q7
     parameter edma_tx_pbuf_addr_q7  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size + `edma_tx_pbuf_num_segments_q7);
     parameter queue7_base          = queue6_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue7_top           = queue7_base + {{`edma_tx_pbuf_queue_segment_size - `edma_tx_pbuf_num_segments_q7{1'b0}},{`edma_tx_pbuf_num_segments_q7{1'b1}}};
    `else
     parameter edma_tx_pbuf_addr_q7  = (`edma_tx_pbuf_addr - `edma_tx_pbuf_queue_segment_size );
     parameter queue7_base          = queue6_top[`edma_tx_pbuf_queue_segment_size-1:0]+1;
     parameter queue7_top           = queue7_base + {`edma_tx_pbuf_queue_segment_size{1'b0}};
    `endif
  `endif


`ifdef gem_ext_fifo_interface
`else
// -----------------------------------------------------------------------------
// keep track of current AHB phase
// -----------------------------------------------------------------------------

   // decode phases of AHB accesses
   assign wr_addr_phase = hready_tmp & (htrans !== p_htrans_idle) & hwrite;
   assign rd_addr_phase = hready_tmp & (htrans !== p_htrans_idle) & ~hwrite;

   // decode when addresss or data phase
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         begin
            wr_data_phase <= 1'b0;
            rd_data_phase <= 1'b0;
         end
      else if (wr_addr_phase)
         begin
            wr_data_phase <= 1'b1;
            rd_data_phase <= 1'b0;
         end
      else if (rd_addr_phase)
         begin
            wr_data_phase <= 1'b0;
            rd_data_phase <= 1'b1;
         end
      else if (hready_tmp)
         begin
            wr_data_phase <= 1'b0;
            rd_data_phase <= 1'b0;
         end


// -----------------------------------------------------------------------------
// Latch current design endianism value
// -----------------------------------------------------------------------------
   always @(negedge reset_tb or negedge hclk)
      if (~reset_tb)
         begin
            endian_value <= `edma_endian_swap_def;
         end
      else if (apb_endian_wr)
         begin
            endian_value <= apb_endian_val[1:0];
         end



// -----------------------------------------------------------------------------
// Decode access size and alignment
// -----------------------------------------------------------------------------

   // decode required access width
   always @(dma_bus_width or hsize)
      begin
         width_fail = 1'b0;
         casex ({dma_bus_width[1:0], hsize[2:0]})
         5'bxx_00x : width_fail = 1'b1;    // no support for 8 or 16 bit accesses
         5'b00_x11 : width_fail = 1'b1;    // error if in 32 bit mode and access is 64 bits
         5'b0x_1xx : width_fail = 1'b1;    // error if in 32 or 64 bit mode and access greater than 64 bits
         5'bxx_010 : access_width = 2'b00; // valid 32 bit access to 32, 64 or 128 DMA width
         5'bxx_011 : access_width = 2'b01; // valid 64 bit access to 64 or 128 DMA width
         5'b1x_100 : access_width = 2'b10; // valid 128 bit access to 128 DMA width
         5'b1x_1xx : width_fail = 1'b1;    // error if in 128 bit mode and access greater than 128 bits
         default   : width_fail = 1'b1;    // other non-supported combination
         endcase
      end


   // save access_width for use in data phase
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         begin
            access_width_saved <= 2'b00;
            haddr3_2_saved     <= 2'b00;
            wr_endian_swap_saved <= 0;
         end
      else if (wr_addr_phase | rd_addr_phase | apb_endian_wr)
         begin
            access_width_saved <= access_width;
            haddr3_2_saved     <= haddr[3:2];
            wr_endian_swap_saved <= wr_endian_swap;
         end
      else if (hready_tmp)
         begin
            access_width_saved <= 2'b00;
            haddr3_2_saved     <= haddr3_2_saved;
            wr_endian_swap_saved <= 0;
         end

         assign rd_endian_swap_saved = rd_endian_swap;



   // decode data lane selected for read- must take into account zero wait state
   // If endian swap is active swap words around - only affects 32-bit access size.
   always @(*)
   begin
      casex ({dma_bus_width[1:0],access_width[1:0], haddr[3:2]})
         // 32 bit access, 32 bit bus
         6'b00_00_xx : data_lane_sel_rd = 2'b00;


         // 32 bit access, 64 bit bus
         6'b01_00_00 : data_lane_sel_rd = (rd_endian_swap)? 2'b01 : 2'b00;
         6'b01_00_01 : data_lane_sel_rd = (rd_endian_swap)? 2'b00 : 2'b01;
         6'b01_00_10 : data_lane_sel_rd = (rd_endian_swap)? 2'b01 : 2'b00;
         6'b01_00_11 : data_lane_sel_rd = (rd_endian_swap)? 2'b00 : 2'b01;

         // 64 bit access, 64 bit bus
         6'b01_01_00 : data_lane_sel_rd = (rd_endian_swap)? 2'b01 : 2'b00;
         6'b01_01_10 : data_lane_sel_rd = (rd_endian_swap)? 2'b01 : 2'b00;


         // 32 bit access, 128 bit bus
         6'b1x_00_00 : data_lane_sel_rd = (rd_endian_swap)? 2'b11 : 2'b00;
         6'b1x_00_01 : data_lane_sel_rd = (rd_endian_swap)? 2'b10 : 2'b01;
         6'b1x_00_10 : data_lane_sel_rd = (rd_endian_swap)? 2'b01 : 2'b10;
         6'b1x_00_11 : data_lane_sel_rd = (rd_endian_swap)? 2'b00 : 2'b11;

         // 64 bit access, 128 bit bus
         6'b1x_01_00 : data_lane_sel_rd = (rd_endian_swap)? 2'b11 : 2'b00;
         6'b1x_01_10 : data_lane_sel_rd = (rd_endian_swap)? 2'b01 : 2'b10;

         // 128 bit access, 128 bit bus
         6'b1x_10_00 : data_lane_sel_rd = (rd_endian_swap)? 2'b11 : 2'b00;


         // anything else is illegal
         default  : data_lane_sel_rd = 2'bxx;

      endcase
   end

   // decode data lane selected for write- not affected by zero wait state
   // If endian swap is active swap words around - only affects 32-bit access size.
   always @(dma_bus_width or haddr3_2_saved or access_width_saved or wr_endian_swap_saved)
   begin
      casex ({dma_bus_width[1:0],access_width_saved[1:0], haddr3_2_saved})
         // 32 bit access, 32 bit bus
         6'b00_00_xx : data_lane_sel_wr = 2'b00;


         // 32 bit access, 64 bit bus
         6'b01_00_00 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b01 : 2'b00;
         6'b01_00_01 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b00 : 2'b01;
         6'b01_00_10 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b01 : 2'b00;
         6'b01_00_11 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b00 : 2'b01;

         // 64 bit access, 64 bit bus
         6'b01_01_00 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b01 : 2'b00;
         6'b01_01_10 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b01 : 2'b00;


         // 32 bit access, 128 bit bus
         6'b1x_00_00 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b11 : 2'b00;
         6'b1x_00_01 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b10 : 2'b01;
         6'b1x_00_10 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b01 : 2'b10;
         6'b1x_00_11 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b00 : 2'b11;

         // 128 bit access, 128 bit bus
         6'b1x_10_00 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b11 : 2'b00;

         // 64 bit access, 128 bit bus
         6'b1x_01_00 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b11 : 2'b00;
         6'b1x_01_10 : data_lane_sel_wr = (wr_endian_swap_saved)? 2'b01 : 2'b10;


         // anything else is illegal
         default  : data_lane_sel_wr = 2'bxx;

      endcase
   end


// -----------------------------------------------------------------------------
// select write data from appropriate data lanes
// -----------------------------------------------------------------------------

   always @(access_width_saved or data_lane_sel_wr or hwdata)
   begin
      data_lane_written[127:0] = 128'bx & {128{~fault_sim}};

      case (access_width_saved)
      2'b00   : // get addressed 32-bit word
                case (data_lane_sel_wr)
                   2'b00   : data_lane_written[31:0]  = hwdata[31:0];
                   2'b01   : data_lane_written[31:0]  = hwdata[63:32];
                   2'b10   : data_lane_written[31:0]  = hwdata[95:64];
                   2'b11   : data_lane_written[31:0]  = hwdata[127:96];
                   default : data_lane_written[127:0] = 128'bx & {128{~fault_sim}};
                endcase

      2'b01   : // get addressed 64-bit word
                case (data_lane_sel_wr)
                   2'b00   : data_lane_written[63:0]  = hwdata[63:0];
                   2'b10   : data_lane_written[63:0]  = hwdata[127:64];
                   2'b01   : data_lane_written[63:0]  = {hwdata[31:0],hwdata[63:32]};
                   default : data_lane_written[63:0]  = {hwdata[95:64],hwdata[127:96]};
                endcase

      default : // get addressed 128-bit word
                case (data_lane_sel_wr)
                   2'b00   : data_lane_written[127:0] = hwdata[127:0];
                   2'b11   : data_lane_written[127:0] = {hwdata[31:0],hwdata[63:32],hwdata[95:64],hwdata[127:96]};
                   default : data_lane_written[127:0] = 128'bx & {128{~fault_sim}};
                endcase

      endcase
   end


// -----------------------------------------------------------------------------
// Byte swap expected write data and supplied read data for endianism swap
// -----------------------------------------------------------------------------
assign write_data_31to0_end  = (~wr_endian_swap_saved)? write_data_31to0: {write_data_31to0[7:0],
                                                                           write_data_31to0[15:8],
                                                                           write_data_31to0[23:16],
                                                                           write_data_31to0[31:24]};
assign write_data_63to32_end = (~wr_endian_swap_saved)? write_data_63to32: {write_data_63to32[7:0],
                                                                            write_data_63to32[15:8],
                                                                            write_data_63to32[23:16],
                                                                            write_data_63to32[31:24]};
assign write_data_95to64_end = (~wr_endian_swap_saved)? write_data_95to64: {write_data_95to64[7:0],
                                                                            write_data_95to64[15:8],
                                                                            write_data_95to64[23:16],
                                                                            write_data_95to64[31:24]};
assign write_data_127to96_end= (~wr_endian_swap_saved)? write_data_127to96: {write_data_127to96[7:0],
                                                                             write_data_127to96[15:8],
                                                                             write_data_127to96[23:16],
                                                                             write_data_127to96[31:24]};
assign read_data_31to0_end   = (~rd_endian_swap_saved)? read_data_31to0: {read_data_31to0[7:0],
                                                                          read_data_31to0[15:8],
                                                                          read_data_31to0[23:16],
                                                                          read_data_31to0[31:24]};
assign read_data_63to32_end  = (~rd_endian_swap_saved)? read_data_63to32: {read_data_63to32[7:0],
                                                                           read_data_63to32[15:8],
                                                                           read_data_63to32[23:16],
                                                                           read_data_63to32[31:24]};
assign read_data_95to64_end  = (~rd_endian_swap_saved)? read_data_95to64: {read_data_95to64[7:0],
                                                                           read_data_95to64[15:8],
                                                                           read_data_95to64[23:16],
                                                                           read_data_95to64[31:24]};
assign read_data_127to96_end = (~rd_endian_swap_saved)? read_data_127to96: {read_data_127to96[7:0],
                                                                            read_data_127to96[15:8],
                                                                            read_data_127to96[23:16],
                                                                            read_data_127to96[31:24]};

// -----------------------------------------------------------------------------
// Detect bursting errors
// -----------------------------------------------------------------------------

   // detect 1K boundary and store.
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         address_at_1k_bound <= 1'b0;
      else if ((htrans !== p_htrans_idle) & hready_tmp) // end of valid addr phase
         case (dma_bus_width[1:0])
            2'b00   : address_at_1k_bound <= &haddr[9:2] & (hburst !== p_hburst_single);
            2'b01   : address_at_1k_bound <= &haddr[9:3] & (hburst !== p_hburst_single);
            default : address_at_1k_bound <= &haddr[9:4] & (hburst !== p_hburst_single);
         endcase
      else if (htrans === p_htrans_idle) // not active
         address_at_1k_bound <= 1'b0;
      else // else maintain value whilst in burst
         address_at_1k_bound <= address_at_1k_bound;

   // Count beats in fixed length bursts
   // Only count while bursting, reset otherwise (max 31-beat)
   // If expecting HRESP error assume burst will be broken.
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         begin
            beat_count   <= 5'h0;
            burst_length <= 5'h0;
         end
      // bursting when SEQ
      else if ((htrans === p_htrans_seq) & (burst_length != 5'h00))
         begin
            if (&beat_count)
               beat_count <= beat_count;        // hold max
            else if (hready_tmp)
               beat_count <= beat_count + 5'h1; // increment
         end
      else if ((htrans === p_htrans_nseq) & hready_tmp & ~wr_not_ok & ~rd_not_ok)
         begin
            case (hburst)
              p_hburst_incr_4  : begin
                                    burst_length <= 5'h04;
                                    beat_count   <= 5'h01;
                                 end
              p_hburst_incr_8  : begin
                                    burst_length <= 5'h08;
                                    beat_count   <= 5'h01;
                                 end
              p_hburst_incr_16 : begin
                                    burst_length <= 5'h10;
                                    beat_count   <= 5'h01;
                                 end
              default          : begin
                                    burst_length <= 5'h00;
                                    beat_count   <= 5'h00;
                                 end
            endcase
         end
      else if (hready_tmp)
         begin
            beat_count   <= 5'h0;
            burst_length <= 5'h0;
         end

   // Detect bursting errors
   //  1. Burst over 1k boundary
   //  2. Early burst termination (beat count < indicated hburst)
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         burst_fail <= 1'b0;
      else if (double_error_injection)
      begin end
      // end of valid burst address phase & previous was 1k boundary
      // for a burst need htrans to be sequential
      else if ((htrans === p_htrans_seq) & hready_tmp & address_at_1k_bound &
               (hburst !== p_hburst_single))
         begin
            burst_fail <= 1'b1;
            $display("**** DMA ERROR : 1K boundary bursted over at %0dns",$time);
         end

      // Early burst termination (beat count < indicated hburst)
      else if ((htrans !== p_htrans_seq) & hready_tmp &
               (beat_count != burst_length) & (burst_length != 0) &
               ~(randomize_hgrant))
         begin
            burst_fail <= 1'b1;
            $display("**** DMA ERROR : HBURST indicated incorrect number of beats in burst, %0d",$time);
         end

      else // not active
         burst_fail <= 1'b0;


// -----------------------------------------------------------------------------
// initialise arrays for holding test file data & decode from selected word
// -----------------------------------------------------------------------------

   // read dma read data
   initial
      begin
         dma_rd_vector_reg[1] = 100'bx;
         $readmemh("./files/tb_dma_rd_rx_descr_q0.data",dma_rd_vector_reg);
         if (dma_rd_vector_reg[1] === 100'bx)
            $display("\n No dma read data file read \n");
      end

   // read alternative dma read data
   initial
      begin
         dma_rd_vector_alt_reg[1] = 100'bx;
         $readmemh("./files/tb_dma_rd_tx_data_q0.data",dma_rd_vector_alt_reg);
         if (dma_rd_vector_alt_reg[1] === 100'bx)
            $display("\n No alternative dma read data file read \n");
      end

   // read tx_descr dma read data
   initial
      begin
         dma_rd_vector_tx_descr_reg[1] = 100'bx;
         $readmemh("./files/tb_dma_rd_tx_descr_q0.data",dma_rd_vector_tx_descr_reg);
         if (dma_rd_vector_tx_descr_reg[1] === 100'bx)
            $display("\n No tx_descr dma read data file read \n");
      end

   assign dma_rd_vector_plus0_orig = dma_rd_vector_reg[dma_rd_index][98:0];
   assign dma_rd_vector_plus0_alt  = dma_rd_vector_alt_reg[alt_dma_rd_index][98:0];
   assign dma_rd_vector_plus0_tx_descr  = dma_rd_vector_tx_descr_reg[tx_descr_dma_rd_index][98:0];
   assign dma_rd_vector_nxt_orig  = dma_rd_vector_reg[next_dma_rd_index][98:0];
   assign dma_rd_vector_nxt_alt   = dma_rd_vector_alt_reg[alt_next_dma_rd_index][98:0];
   assign dma_rd_vector_nxt_tx_descr   = dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index][98:0];
   assign next_read_add_orig  = dma_rd_vector_nxt_orig[95:32];
   assign next_read_add_alt   = dma_rd_vector_nxt_alt [95:32];
   assign next_read_add_tx_descr   = dma_rd_vector_nxt_tx_descr [95:32];

   assign using_orig          = hready_tmp ? rd_addr_phase & (haddr == next_read_add_orig) : using_orig; // Latch between accesses
   assign using_alt           = hready_tmp ? ~using_orig & rd_addr_phase & (haddr == next_read_add_alt) : using_alt; // Latch between accesses
   assign using_tx_descr      = hready_tmp ? ~using_orig & rd_addr_phase & (haddr == next_read_add_tx_descr) : using_tx_descr; // Latch between accesses
   assign next_read_add       = using_alt ? next_read_add_alt : using_tx_descr ? next_read_add_tx_descr : next_read_add_orig;


   // decode current vector values
   assign dma_rd_vector_plus0 = using_alt       ? dma_rd_vector_alt_reg[alt_next_dma_rd_index][98:0]     :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index][98:0]         :
                                                  dma_rd_vector_reg[next_dma_rd_index][98:0];
   assign dma_rd_vector_plus1 = using_alt       ? dma_rd_vector_alt_reg[alt_next_dma_rd_index+1][98:0]         :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index+1][98:0]         :
                                                  dma_rd_vector_reg[next_dma_rd_index+1][98:0];
   assign dma_rd_vector_plus2 = using_alt       ? dma_rd_vector_alt_reg[alt_next_dma_rd_index+2][98:0]         :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index+2][98:0]         :
                                                  dma_rd_vector_reg[next_dma_rd_index+2][98:0];
   assign dma_rd_vector_plus3 = using_alt       ? dma_rd_vector_alt_reg[alt_next_dma_rd_index+3][98:0]         :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index+3][98:0]         :
                                                  dma_rd_vector_reg[next_dma_rd_index+3][98:0];
   assign dma_rd_done         = dma_rd_vector_nxt_tx_descr[98] &  dma_rd_vector_nxt_alt[98] & dma_rd_vector_nxt_orig[98];

   `ifdef dma_priority_queue1
   assign read_data_31to0     = (bf_auto_complete_descrd | descrd_auto_comp) & dma_nxt_tx_descrd ? 32'h80000000 : dma_rd_vector_plus0[31:0];
   assign read_data_63to32    = (bf_auto_complete_descrd | descrd_auto_comp) & dma_nxt_tx_descrd ? 32'h80000000 : dma_rd_vector_plus1[31:0];
   `else
   assign read_data_31to0     = dma_rd_vector_plus0[31:0];
   assign read_data_63to32    = dma_rd_vector_plus1[31:0];
   `endif
   assign read_data_95to64    = dma_rd_vector_plus2[31:0];
   assign read_data_127to96   = dma_rd_vector_plus3[31:0];
   assign next_dma_rd_vector  = using_alt       ? dma_rd_vector_alt_reg[alt_next_dma_rd_index][98:0] :
                                using_tx_descr  ? dma_rd_vector_tx_descr_reg[tx_descr_next_dma_rd_index][98:0] :
                                                  dma_rd_vector_reg[next_dma_rd_index][98:0];
   assign rd_not_ok           = dma_rd_vector_plus0[96];
   assign rd_endian_swap      = (dma_rd_vector_plus0[97]) | (&endian_value);



   // read dma write data
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_rx_data_q0.data",dma_wr_vector_reg);
         if (dma_wr_vector_reg[1] === 108'hx)
            $display("\n No dma write data file read \n");
      end
   // read alternative dma write data
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            alt_dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q0.data",alt_dma_wr_vector_reg);
         if (alt_dma_wr_vector_reg[1] === 108'hx)
            $display("\n No alternative dma write data file read \n");
      end
   // read dma descriptor write data for RX
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            dma_rx_wr_descr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_rx_descr_q0.data",dma_rx_wr_descr_vector_reg);
         if (dma_rx_wr_descr_vector_reg[1] === 108'hx)
            $display("\n No RX dma descriptor write data file read \n");
      end
   `ifdef dma_priority_queue1
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            q1_dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q1.data",q1_dma_wr_vector_reg);
      end
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            q2_dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q2.data",q2_dma_wr_vector_reg);
      end
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            q3_dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q3.data",q3_dma_wr_vector_reg);
      end
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            q4_dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q4.data",q4_dma_wr_vector_reg);
      end
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            q5_dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q5.data",q5_dma_wr_vector_reg);
      end
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            q6_dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q6.data",q6_dma_wr_vector_reg);
      end
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            q7_dma_wr_vector_reg[k] = 108'b0;

         $readmemh("./files/tb_dma_wr_tx_descr_q7.data",q7_dma_wr_vector_reg);
      end
   `endif


   assign dma_wr_vector_plus0_orig = dma_wr_vector_reg    [dma_wr_index][106:8];
   assign dma_wr_vector_plus0_alt  = alt_dma_wr_vector_reg[alt_dma_wr_index][106:8];
   assign dma_rx_wr_descr_vector_plus0  = dma_rx_wr_descr_vector_reg[dma_rx_wr_descr_index][106:8];
   `ifdef dma_priority_queue1
   assign dma_wr_vector_plus0_q1  = q1_dma_wr_vector_reg[q1_dma_wr_index][106:8];
   assign dma_wr_vector_plus0_q2  = q2_dma_wr_vector_reg[q2_dma_wr_index][106:8];
   assign dma_wr_vector_plus0_q3  = q3_dma_wr_vector_reg[q3_dma_wr_index][106:8];
   assign dma_wr_vector_plus0_q4  = q4_dma_wr_vector_reg[q4_dma_wr_index][106:8];
   assign dma_wr_vector_plus0_q5  = q5_dma_wr_vector_reg[q5_dma_wr_index][106:8];
   assign dma_wr_vector_plus0_q6  = q6_dma_wr_vector_reg[q6_dma_wr_index][106:8];
   assign dma_wr_vector_plus0_q7  = q7_dma_wr_vector_reg[q7_dma_wr_index][106:8];
   `endif

   assign next_dma_wr_vector_orig  = dma_wr_vector_reg[next_dma_wr_index][106:8];
   assign next_dma_wr_vector_alt   = alt_dma_wr_vector_reg[alt_next_dma_wr_index][106:8];
   assign next_dma_rx_wr_descr_vector = dma_rx_wr_descr_vector_reg[next_dma_rx_wr_descr_index][106:8];
   `ifdef dma_priority_queue1
   assign next_dma_wr_vector_q1   = q1_dma_wr_vector_reg[q1_next_dma_wr_index][106:8];
   assign next_dma_wr_vector_q2   = q2_dma_wr_vector_reg[q2_next_dma_wr_index][106:8];
   assign next_dma_wr_vector_q3   = q3_dma_wr_vector_reg[q3_next_dma_wr_index][106:8];
   assign next_dma_wr_vector_q4   = q4_dma_wr_vector_reg[q4_next_dma_wr_index][106:8];
   assign next_dma_wr_vector_q5   = q5_dma_wr_vector_reg[q5_next_dma_wr_index][106:8];
   assign next_dma_wr_vector_q6   = q6_dma_wr_vector_reg[q6_next_dma_wr_index][106:8];
   assign next_dma_wr_vector_q7   = q7_dma_wr_vector_reg[q7_next_dma_wr_index][106:8];
   `endif



   assign next_write_add_orig  = next_dma_wr_vector_orig[95:32];
   assign next_write_add_alt   = next_dma_wr_vector_alt [95:32];
   assign next_write_add_rx_descr   = next_dma_rx_wr_descr_vector [95:32];
   `ifdef dma_priority_queue1
   assign next_write_add_q1   = next_dma_wr_vector_q1 [95:32];
   assign next_write_add_q2   = next_dma_wr_vector_q2 [95:32];
   assign next_write_add_q3   = next_dma_wr_vector_q3 [95:32];
   assign next_write_add_q4   = next_dma_wr_vector_q4 [95:32];
   assign next_write_add_q5   = next_dma_wr_vector_q5 [95:32];
   assign next_write_add_q6   = next_dma_wr_vector_q6 [95:32];
   assign next_write_add_q7   = next_dma_wr_vector_q7 [95:32];
   `endif

   assign using_orig_wr     = hready_tmp ? wr_addr_phase & (haddr == next_write_add_orig )                       : using_orig_wr;
   assign using_alt_wr      = hready_tmp ? (~using_orig_wr & wr_addr_phase & (haddr == next_write_add_alt))      : using_alt_wr;
   assign using_rx_descr_wr = hready_tmp ? (~using_orig_wr & wr_addr_phase & (haddr == next_write_add_rx_descr)) : using_rx_descr_wr;
   `ifdef dma_priority_queue1
   assign using_q1_wr      = hready_tmp ? wr_addr_phase & (haddr == next_write_add_q1) : using_q1_wr;
   assign using_q2_wr      = hready_tmp ? wr_addr_phase & (haddr == next_write_add_q2) : using_q2_wr;
   assign using_q3_wr      = hready_tmp ? wr_addr_phase & (haddr == next_write_add_q3) : using_q3_wr;
   assign using_q4_wr      = hready_tmp ? wr_addr_phase & (haddr == next_write_add_q4) : using_q4_wr;
   assign using_q5_wr      = hready_tmp ? wr_addr_phase & (haddr == next_write_add_q5) : using_q5_wr;
   assign using_q6_wr      = hready_tmp ? wr_addr_phase & (haddr == next_write_add_q6) : using_q6_wr;
   assign using_q7_wr      = hready_tmp ? wr_addr_phase & (haddr == next_write_add_q7) : using_q7_wr;
   `endif
   assign next_write_add       = using_alt_wr       ? next_write_add_alt :
                                 using_rx_descr_wr  ? next_write_add_rx_descr
   `ifdef dma_priority_queue1
                               : using_q1_wr  ? next_write_add_q1
                               : using_q2_wr  ? next_write_add_q2
                               : using_q3_wr  ? next_write_add_q3
                               : using_q4_wr  ? next_write_add_q4
                               : using_q5_wr  ? next_write_add_q5
                               : using_q6_wr  ? next_write_add_q6
                               : using_q7_wr  ? next_write_add_q7
   `endif
                                              : next_write_add_orig;

   // decode current vector values
   assign dma_wr_vector_plus0 = using_alt_wr_dph        ? alt_dma_wr_vector_reg[alt_dma_wr_index][106:8] :
                                using_rx_descr_wr_dph   ? dma_rx_wr_descr_vector_reg[dma_rx_wr_descr_index][106:8] :
                                `ifdef dma_priority_queue1
                                using_q1_wr_dph        ? q1_dma_wr_vector_reg[q1_dma_wr_index][106:8] :
                                using_q2_wr_dph        ? q2_dma_wr_vector_reg[q2_dma_wr_index][106:8] :
                                using_q3_wr_dph        ? q3_dma_wr_vector_reg[q3_dma_wr_index][106:8] :
                                using_q4_wr_dph        ? q4_dma_wr_vector_reg[q4_dma_wr_index][106:8] :
                                using_q5_wr_dph        ? q5_dma_wr_vector_reg[q5_dma_wr_index][106:8] :
                                using_q6_wr_dph        ? q6_dma_wr_vector_reg[q6_dma_wr_index][106:8] :
                                using_q7_wr_dph        ? q7_dma_wr_vector_reg[q7_dma_wr_index][106:8] :
                                `endif
                                                         dma_wr_vector_reg[dma_wr_index][106:8];

   assign dma_wr_vector_plus1 = using_alt_wr_dph      ? alt_dma_wr_vector_reg[alt_dma_wr_index + 1][106:8]:
                                using_rx_descr_wr_dph ? dma_rx_wr_descr_vector_reg[dma_rx_wr_descr_index + 1][106:8] :
                                                        dma_wr_vector_reg[dma_wr_index + 1][106:8];
   assign dma_wr_vector_plus2 = using_alt_wr_dph      ? alt_dma_wr_vector_reg[alt_dma_wr_index + 2][106:8] :
                                using_rx_descr_wr_dph ? dma_rx_wr_descr_vector_reg[dma_rx_wr_descr_index + 2] [106:8]:
                                                        dma_wr_vector_reg[dma_wr_index + 2][106:8];
   assign dma_wr_vector_plus3 = using_alt_wr_dph      ? alt_dma_wr_vector_reg[alt_dma_wr_index + 3][106:8] :
                                using_rx_descr_wr_dph ? dma_rx_wr_descr_vector_reg[dma_rx_wr_descr_index + 3][106:8] :
                                                        dma_wr_vector_reg[dma_wr_index + 3][106:8];
   assign dma_wr_done         = dma_wr_vector_plus0_orig[98] & dma_wr_vector_plus0_alt[98] & dma_rx_wr_descr_vector_plus0[98]
                                `ifdef dma_priority_queue1
                                & dma_wr_vector_plus0_q1[98] & dma_wr_vector_plus0_q2[98] & dma_wr_vector_plus0_q3[98] & dma_wr_vector_plus0_q4[98]
                                & dma_wr_vector_plus0_q5[98] & dma_wr_vector_plus0_q7[98] & dma_wr_vector_plus0_q7[98]
                                `endif
                                ;
   assign write_data_31to0    = dma_wr_vector_plus0[31:0];
   assign write_data_63to32   = dma_wr_vector_plus1[31:0];
   assign write_data_95to64   = dma_wr_vector_plus2[31:0];
   assign write_data_127to96  = dma_wr_vector_plus3[31:0];
   assign next_dma_wr_vector  = using_alt_wr        ? next_dma_wr_vector_alt :
                                using_rx_descr_wr   ? next_dma_rx_wr_descr_vector :
                                                      next_dma_wr_vector_orig;
   assign wr_not_ok           = next_dma_wr_vector[96];
   assign wr_endian_swap      = (next_dma_wr_vector[97]) | (&endian_value);


// -----------------------------------------------------------------------------
// index to write array
// -----------------------------------------------------------------------------

   // next index to write array
   always @(*)
   begin
      if (wr_data_phase & hready_tmp & ~using_alt_wr_dph  & ~using_rx_descr_wr_dph
      `ifdef dma_priority_queue1
        & ~using_q1_wr_dph & ~using_q2_wr_dph & ~using_q3_wr_dph & ~using_q4_wr_dph & ~using_q5_wr_dph & ~using_q6_wr_dph & ~using_q7_wr_dph
      `endif
      )
         case (access_width_saved)
            2'b00   : next_dma_wr_index = dma_wr_index + 1;
            2'b01   : next_dma_wr_index = dma_wr_index + 2;
            default : next_dma_wr_index = dma_wr_index + 4;
         endcase
      else
         next_dma_wr_index = dma_wr_index;
   end


   always @(wr_data_phase or hready_tmp or access_width_saved or alt_dma_wr_index or using_alt_wr_dph)
   begin
      if (wr_data_phase & hready_tmp & using_alt_wr_dph)
         case (access_width_saved)
            2'b00   : alt_next_dma_wr_index = alt_dma_wr_index + 1;
            2'b01   : alt_next_dma_wr_index = alt_dma_wr_index + 2;
            default : alt_next_dma_wr_index = alt_dma_wr_index + 4;
         endcase
      else
         alt_next_dma_wr_index = alt_dma_wr_index;
   end

   always @(wr_data_phase or hready_tmp or access_width_saved or dma_rx_wr_descr_index or using_rx_descr_wr_dph)
   begin
        if (wr_data_phase & hready_tmp & using_rx_descr_wr_dph)
           case (access_width_saved)
              2'b00   : next_dma_rx_wr_descr_index = dma_rx_wr_descr_index + 1;
              2'b01   : next_dma_rx_wr_descr_index = dma_rx_wr_descr_index + 2;
              default : next_dma_rx_wr_descr_index = dma_rx_wr_descr_index + 4;
           endcase
      else
         next_dma_rx_wr_descr_index = dma_rx_wr_descr_index;
   end
   // next index to write array
  `ifdef dma_priority_queue1
   always @(wr_data_phase or hready_tmp or access_width_saved or q1_dma_wr_index or using_q1_wr_dph)
   begin
      if (wr_data_phase & hready_tmp & using_q1_wr_dph)
         case (access_width_saved)
            2'b00   : q1_next_dma_wr_index = q1_dma_wr_index + 1;
            2'b01   : q1_next_dma_wr_index = q1_dma_wr_index + 2;
            default : q1_next_dma_wr_index = q1_dma_wr_index + 4;
         endcase
      else
         q1_next_dma_wr_index = q1_dma_wr_index;
   end
   always @(wr_data_phase or hready_tmp or access_width_saved or q2_dma_wr_index or using_q2_wr_dph)
   begin
      if (wr_data_phase & hready_tmp & using_q2_wr_dph)
         case (access_width_saved)
            2'b00   : q2_next_dma_wr_index = q2_dma_wr_index + 1;
            2'b01   : q2_next_dma_wr_index = q2_dma_wr_index + 2;
            default : q2_next_dma_wr_index = q2_dma_wr_index + 4;
         endcase
      else
         q2_next_dma_wr_index = q2_dma_wr_index;
   end
   always @(wr_data_phase or hready_tmp or access_width_saved or q3_dma_wr_index or using_q3_wr_dph)
   begin
      if (wr_data_phase & hready_tmp & using_q3_wr_dph)
         case (access_width_saved)
            2'b00   : q3_next_dma_wr_index = q3_dma_wr_index + 1;
            2'b01   : q3_next_dma_wr_index = q3_dma_wr_index + 2;
            default : q3_next_dma_wr_index = q3_dma_wr_index + 4;
         endcase
      else
         q3_next_dma_wr_index = q3_dma_wr_index;
   end
   always @(wr_data_phase or hready_tmp or access_width_saved or q4_dma_wr_index or using_q4_wr_dph)
   begin
      if (wr_data_phase & hready_tmp & using_q4_wr_dph)
         case (access_width_saved)
            2'b00   : q4_next_dma_wr_index = q4_dma_wr_index + 1;
            2'b01   : q4_next_dma_wr_index = q4_dma_wr_index + 2;
            default : q4_next_dma_wr_index = q4_dma_wr_index + 4;
         endcase
      else
         q4_next_dma_wr_index = q4_dma_wr_index;
   end
   always @(wr_data_phase or hready_tmp or access_width_saved or q5_dma_wr_index or using_q5_wr_dph)
   begin
      if (wr_data_phase & hready_tmp & using_q5_wr_dph)
         case (access_width_saved)
            2'b00   : q5_next_dma_wr_index = q5_dma_wr_index + 1;
            2'b01   : q5_next_dma_wr_index = q5_dma_wr_index + 2;
            default : q5_next_dma_wr_index = q5_dma_wr_index + 4;
         endcase
      else
         q5_next_dma_wr_index = q5_dma_wr_index;
   end
   always @(wr_data_phase or hready_tmp or access_width_saved or q6_dma_wr_index or using_q6_wr_dph)
   begin
      if (wr_data_phase & hready_tmp & using_q6_wr_dph)
         case (access_width_saved)
            2'b00   : q6_next_dma_wr_index = q6_dma_wr_index + 1;
            2'b01   : q6_next_dma_wr_index = q6_dma_wr_index + 2;
            default : q6_next_dma_wr_index = q6_dma_wr_index + 4;
         endcase
      else
         q6_next_dma_wr_index = q6_dma_wr_index;
   end
   always @(wr_data_phase or hready_tmp or access_width_saved or q7_dma_wr_index or using_q7_wr_dph)
   begin
      if (wr_data_phase & hready_tmp & using_q7_wr_dph)
         case (access_width_saved)
            2'b00   : q7_next_dma_wr_index = q7_dma_wr_index + 1;
            2'b01   : q7_next_dma_wr_index = q7_dma_wr_index + 2;
            default : q7_next_dma_wr_index = q7_dma_wr_index + 4;
         endcase
      else
         q7_next_dma_wr_index = q7_dma_wr_index;
   end
  `endif

   // current index to write array
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
         using_alt_wr_dph <= 0;
         using_rx_descr_wr_dph <= 0;
         dma_wr_index <= 1;
         alt_dma_wr_index <= 1;
         dma_rx_wr_descr_index <= 1;
        `ifdef dma_priority_queue1
            using_q1_wr_dph <= 0;
            using_q2_wr_dph <= 0;
            using_q3_wr_dph <= 0;
            using_q4_wr_dph <= 0;
            using_q5_wr_dph <= 0;
            using_q6_wr_dph <= 0;
            using_q7_wr_dph <= 0;
            q1_dma_wr_index <= 1;
            q2_dma_wr_index <= 1;
            q3_dma_wr_index <= 1;
            q4_dma_wr_index <= 1;
            q5_dma_wr_index <= 1;
            q6_dma_wr_index <= 1;
            q7_dma_wr_index <= 1;
         `endif
      end
      else
      begin
         if (hready_tmp)
         begin
            using_alt_wr_dph <= using_alt_wr;
            using_rx_descr_wr_dph <= using_rx_descr_wr;
         end
         dma_wr_index <= next_dma_wr_index;
         alt_dma_wr_index <= alt_next_dma_wr_index;
         dma_rx_wr_descr_index <= next_dma_rx_wr_descr_index;
        `ifdef dma_priority_queue1
         if (hready_tmp)
            using_q1_wr_dph <= using_q1_wr;
         q1_dma_wr_index <= q1_next_dma_wr_index;
         if (hready_tmp)
            using_q2_wr_dph <= using_q2_wr;
         q2_dma_wr_index <= q2_next_dma_wr_index;
         if (hready_tmp)
            using_q3_wr_dph <= using_q3_wr;
         q3_dma_wr_index <= q3_next_dma_wr_index;
         if (hready_tmp)
            using_q4_wr_dph <= using_q4_wr;
         q4_dma_wr_index <= q4_next_dma_wr_index;
         if (hready_tmp)
            using_q5_wr_dph <= using_q5_wr;
         q5_dma_wr_index <= q5_next_dma_wr_index;
         if (hready_tmp)
            using_q6_wr_dph <= using_q6_wr;
         q6_dma_wr_index <= q6_next_dma_wr_index;
         if (hready_tmp)
            using_q7_wr_dph <= using_q7_wr;
         q7_dma_wr_index <= q7_next_dma_wr_index;
         `endif
      end
   end


// -----------------------------------------------------------------------------
// index to read array
// -----------------------------------------------------------------------------

   // next index to write array
//   always @(rd_addr_phase or amba_ready_delay or hready_tmp or rd_data_phase or using_alt_rd_dph or
//            delay_hready or access_width or dma_rd_index or dma_rd_done or using_alt)
//   begin
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        next_dma_rd_index <= 1;
      end
      else
      begin
        if (~dma_rd_done & rd_addr_phase & using_orig & ~(descrd_auto_comp & dma_nxt_tx_descrd))
           case (access_width)
              2'b00   : next_dma_rd_index <= next_dma_rd_index + 1;
              2'b01   : next_dma_rd_index <= next_dma_rd_index + 2;
              default : next_dma_rd_index <= next_dma_rd_index + 4;
           endcase
        else
           next_dma_rd_index <= next_dma_rd_index;
      end
   end

  reg abort_data_en;
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
        alt_next_dma_rd_index <= 1;
        abort_data_en  <= 1'b0;
      end
      else
      begin
        `ifdef dma_priority_queue1
        if (beat_count == (burst_length-2) & tx_buffer_full)
          abort_data_en <= 1'b1;
        else if (beat_count == burst_length)
          abort_data_en <= 1'b0;

        if (rewind_index_en)
          alt_next_dma_rd_index <= rewind_index_alt;
        else
        `endif
        begin
          if (~dma_rd_done & rd_addr_phase & using_alt & ~descrd_auto_comp)
           case (access_width)
              2'b00   : alt_next_dma_rd_index <= alt_next_dma_rd_index + 1;
              2'b01   : alt_next_dma_rd_index <= alt_next_dma_rd_index + 2;
              default : alt_next_dma_rd_index <= alt_next_dma_rd_index + 4;
           endcase
          else
           alt_next_dma_rd_index <= alt_next_dma_rd_index;
        end
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
        `ifdef dma_priority_queue1
        if (rewind_index_en)
          tx_descr_next_dma_rd_index <= rewind_index_tx_descr;
        else
        `endif
        begin
          if (~dma_rd_done & rd_addr_phase & using_tx_descr & ~descrd_auto_comp)
           case (access_width)
              2'b00   : tx_descr_next_dma_rd_index <= tx_descr_next_dma_rd_index + 1;
              2'b01   : tx_descr_next_dma_rd_index <= tx_descr_next_dma_rd_index + 2;
              default : tx_descr_next_dma_rd_index <= tx_descr_next_dma_rd_index + 4;
           endcase
          else
           tx_descr_next_dma_rd_index <= tx_descr_next_dma_rd_index;
        end
      end
   end
   // current index to write array
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
         using_alt_rd_dph <= 0;
         using_tx_descr_rd_dph <= 0;
         dma_rd_index <= 1;
         alt_dma_rd_index <= 1;
         tx_descr_dma_rd_index <= 1;
      end
      else
      begin
         if (hready_tmp)
         begin
           using_alt_rd_dph     <= using_alt;
           using_tx_descr_rd_dph     <= using_tx_descr;
           dma_rd_index           <= next_dma_rd_index;
           alt_dma_rd_index       <= alt_next_dma_rd_index;
           tx_descr_dma_rd_index       <= tx_descr_next_dma_rd_index;
        end
      end
   end


   // sync reset_tb to hclk. This helps to make questa and nc behave the same
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         begin
            reset_tb_sync <= 1'b0;
         end
      else
         begin
            reset_tb_sync <= reset_tb;
         end


// -----------------------------------------------------------------------------
// hgrant delay from hbusreq
// -----------------------------------------------------------------------------
reg rnd;
   // grant bus after a delay
   always @(negedge reset_tb_sync or posedge hclk)
      if (~reset_tb_sync)
         begin
            hgrantdma_tmp <= 1'b0;
            grant_cnt <= 4'b0;
            rnd <= 1'b0;
         end
      else
      begin
         rnd <= $random;
         if (bus_grant_delay == 4'b0)
            begin
               // grant bus always for zero bus grant delay
               hgrantdma_tmp <= 1'b1;
               grant_cnt <= 4'b0;
            end
         else if (~hbusreqdma)
            begin
               hgrantdma_tmp <= 1'b0;
               grant_cnt <= 4'b0;
            end
         else if (hgrantdma_tmp & (randomize_hgrant))
            begin
               hgrantdma_tmp <= rnd;
               grant_cnt <= rnd ? bus_grant_delay : 4'b0;
            end
         else if (hbusreqdma & (grant_cnt != bus_grant_delay))
            begin
               hgrantdma_tmp <= 1'b0;
               grant_cnt <= grant_cnt + 4'h1;
            end
         else
            begin
               hgrantdma_tmp <= 1'b1;
               grant_cnt <= grant_cnt;
            end
         end
         
  initial hgrantdma = 1'b0;
  always @(negedge hclk) hgrantdma = hgrantdma_tmp;

// -----------------------------------------------------------------------------
// hready_tmp delay & hready_tmp output
// -----------------------------------------------------------------------------

   // Detect when the DMA is performing an access
   assign insert_wait = ((hgrantdma_tmp | (htrans !== p_htrans_idle)) & hready_tmp);

   // Hold insert_wait until access complete
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         insert_wait_hold <= 1'b0;
      else if ( ((amba_ready_delay == 4'h0) & ~randomize_hready) |
                ((random_hready == 0) & randomize_hready & hready_tmp))
         insert_wait_hold <= 1'b0;
      else if (insert_wait_hold & delay_hready == 1)
         insert_wait_hold <= 1'b0;
      else if (insert_wait)
         insert_wait_hold <= 1'b1;


   // wait states counter
  reg [7:0] tmp;
  reg   hlock_data;
  wire  tx_grant;
  wire  rx_grant;
  wire  descr_rd_done_dph;
  // The following signals are needed by the core testbench components to model priority queueing auto packet tx replays
  // This means we need a way to probe the signals even at gate level.  This can be done by maintaining heirarchy during
  // synthesis, and carefully applying probes.
  `ifdef edma_tx_pkt_buffer
    `ifdef rtl
      wire [2:0] current_queue;
      assign dma_nxt_tx_data  = `hier_pbuf_tx_wr.i_edma_pbuf_tx_align.tx_dma_state_data;
      assign tx_grant         = `hier_pbuf_tx_wr.hgrant_descr |
                                `hier_pbuf_tx_wr.hgrant_data;
      assign descr_rd_done_dph  = `hier_pbuf_tx_wr.descr_rd_done_dph;
      assign dma_nxt_tx_descrd  = `hier_pbuf_tx_wr.dma_state_man_rd;
      assign dma_nxt_tx_descwr  = `hier_pbuf_tx_wr.dma_state_man_wr;
      assign dma_nxt_rx_descrd  = `hier_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_rd;
      assign dma_nxt_rx_descwr  = `hier_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_wr;
      assign dma_nxt_rx_data    = `hier_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_data;
      `ifdef dma_priority_queue1
      // When using the randomized verification environment, the DMA transactions associated with particular queues are
      // generated by trans.pl.  However, this file cannot take into account dynamic events like when the DPRAM regions
      // become full.
      // when the DPRAM region becomes full, the MANRD for a particular queue is handled in a similar way to what happens
      // when a used bit is read for that queue - it simply moves onto the next queue.  The trans.pl models the used bit
      // but cannot model the buffer_full as it is a dynamic event.  We therefore need to model this here, monitoring
      // the buffer_full status of the DMA and driving the indexes to the TX data file appropriately so we can rewind it if
      // necessary.
        assign current_queue        = `hier_pbuf_tx_wr.queue_ptr_dph;
        assign tx_buffer_full_str   = `hier_pbuf_tx_wr.buffullstr_sel;
        assign tx_buffer_full       = `hier_pbuf_tx_wr.buffer_full;
        assign used_bit_read        = `hier_pbuf_tx_wr.used_bit_read;
        assign prev_eof_bit         = `hier_pbuf_tx_wr.first_buffer_of_pkt;
        assign pkt_flush_norep      = `hier_pbuf_tx_wr.pkt_flush_norep;
      `endif


    `else
      wire [2:0] current_queue_rph;
      reg  [2:0] current_queue_aph;
      reg  [2:0] current_queue;
      wire [2:0] dma_state;
      wire [2:0] rx_dma_state;
      assign dma_nxt_tx_data  = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.i_edma_pbuf_tx_align.tx_dma_state_data;
      assign tx_grant         = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.hgrant_descr |
                                `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.hgrant_data;
      assign rx_dma_state = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state ;

      assign dma_nxt_rx_data    = rx_dma_state==RX_DMA_DATA_STORE;
      assign dma_nxt_rx_descrd  = rx_dma_state==RX_DMA_MAN_RD;
      assign dma_nxt_rx_descwr  = rx_dma_state==RX_DMA_MAN_WR;
//      assign dma_nxt_rx_data = {`hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_rx.i_edma_pbuf_rx_rd.\rx_dma_state[1] ,
//                                `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_rx.i_edma_pbuf_rx_rd.\rx_dma_state[0] } == 2'b11;

      assign dma_state[2]       = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\dma_state_reg[2] .Q;
      assign dma_state[1]       = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\dma_state_reg[1] .Q;
      assign dma_state[0]       = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\dma_state_reg[0] .Q;
//      assign dma_state = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.dma_state ;


      assign dma_nxt_tx_descrd = dma_state == DMA_MANRD;
      assign dma_nxt_tx_descwr = dma_state == DMA_MANWR;
      `ifdef dma_priority_queue1
        reg           buffer_full_q0;         // DPRAM currently full - stop writing
        reg           buffer_full_q1;         // DPRAM currently full - stop writing
        reg           buffer_full_q2;         // DPRAM currently full - stop writing
        reg           buffer_full_q3;         // DPRAM currently full - stop writing
        reg           buffer_full_q4;         // DPRAM currently full - stop writing
        reg           buffer_full_q5;         // DPRAM currently full - stop writing
        reg           buffer_full_q6;         // DPRAM currently full - stop writing
        reg           buffer_full_q7;         // DPRAM currently full - stop writing
        wire   [8:0] dpram_fill_lvl;
        wire   [8:0] dpram_fill_lvl_q1;
        `ifdef dma_priority_queue2
        wire   [8:0] dpram_fill_lvl_q2;
        `endif
        `ifdef dma_priority_queue3
        wire   [8:0] dpram_fill_lvl_q3;
        `endif
        `ifdef dma_priority_queue4
        wire   [8:0] dpram_fill_lvl_q4;
        `endif
        `ifdef dma_priority_queue5
        wire   [8:0] dpram_fill_lvl_q5;
        `endif
        `ifdef dma_priority_queue6
        wire   [8:0] dpram_fill_lvl_q6;
        `endif
        `ifdef dma_priority_queue7
        wire   [8:0] dpram_fill_lvl_q7;
        `endif
        wire                            tx_buffer_full_str;
        reg                             buffer_full;
        wire    [7:0]                   buf_full_stored_c;
        wire    [4:0]                   ahb_burst_length;
        reg     [7:0]                   buf_full_stored;
        assign descr_rd_done_dph       = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.descr_rd_done_dph_reg.Q;
        assign current_queue_rph[0]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.gen_set_queue_ptrs_queue_ptr_rph_r[0];
        assign current_queue_rph[1]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.gen_set_queue_ptrs_queue_ptr_rph_r[1];
        assign current_queue_rph[2]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.gen_set_queue_ptrs_queue_ptr_rph_r[2];
        assign buf_full_stored_c[0]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\gen_priq_specific_code_buf_full_stored_reg[0] .D ;
        assign buf_full_stored_c[1]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\gen_priq_specific_code_buf_full_stored_reg[1] .D ;
        `ifdef dma_priority_queue2
        assign buf_full_stored_c[2]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\gen_priq_specific_code_buf_full_stored_reg[2] .D ;
        `endif
        `ifdef dma_priority_queue3
        assign buf_full_stored_c[3]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\gen_priq_specific_code_buf_full_stored_reg[3] .D ;
        `endif
        `ifdef dma_priority_queue4
        assign buf_full_stored_c[4]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\gen_priq_specific_code_buf_full_stored_reg[4] .D ;
        `endif
        `ifdef dma_priority_queue5
        assign buf_full_stored_c[5]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\gen_priq_specific_code_buf_full_stored_reg[5] .D ;
        `endif
        `ifdef dma_priority_queue6
        assign buf_full_stored_c[6]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\gen_priq_specific_code_buf_full_stored_reg[6] .D ;
        `endif
        `ifdef dma_priority_queue7
        assign buf_full_stored_c[7]    = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\gen_priq_specific_code_buf_full_stored_reg[7] .D ;
        `endif
        always @(negedge reset_tb or posedge hclk)
        begin
          if (~reset_tb)
          begin
            buf_full_stored <= 8'h00;
            current_queue_aph <= 3'b000;
            current_queue <= 3'b000;
          end
          else
          begin
            buf_full_stored <= buf_full_stored_c;
            if (hready_tmp)
            begin
              current_queue_aph <= current_queue_rph;
              current_queue <= current_queue_aph;
            end
          end
        end


        assign ahb_burst_length     = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\ahb_burst_length ;

        assign used_bit_read_regc = (dma_tx_descrd & hready_tmp & (`hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.descr_rd_done_dph_cnt == 4'h0)) &
                                    ((hrdata[31] & dma_bus_width == 2'b00) |
                                    (hrdata[63] &(|dma_bus_width)));

        assign descriptor_rd_1_access = (|dma_bus_width & ~gem_dma_addr_w_is_64);
        assign descriptor_rd_2_access = (|dma_bus_width[1:0] & gem_dma_addr_w_is_64) |
                                         (dma_bus_width[1:0] == 2'b00 & ~gem_dma_addr_w_is_64);
        assign descriptor_rd_3_access = (dma_bus_width == 2'b00 & gem_dma_addr_w_is_64);
        assign used_bit_read  = descriptor_rd_1_access
                                  ? used_bit_read_regc & dma_tx_descrd :
                                descriptor_rd_2_access
                                  ? `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\used_bit_read_reg & `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.descr_rd_done_dph_cnt[3:0] == 4'h1 & hready_tmp & dma_tx_descrd
                                  : `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.\used_bit_read_reg & `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.descr_rd_done_dph_cnt[3:0] == 4'h2 & hready_tmp & dma_tx_descrd; // 3 access

        assign prev_eof_bit         = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.first_buffer_of_pkt_reg.Q ;

        assign tx_buffer_full_str   = // Copied from RTL
                                `ifdef dma_priority_queue7
                                (current_queue == 3'd7) ? buf_full_stored[7] :
                                `endif
                                `ifdef dma_priority_queue6
                                (current_queue == 3'd6) ? buf_full_stored[6] :
                                `endif
                                `ifdef dma_priority_queue5
                                (current_queue == 3'd5) ? buf_full_stored[5] :
                                `endif
                                `ifdef dma_priority_queue4
                                (current_queue == 3'd4) ? buf_full_stored[4] :
                                `endif
                                `ifdef dma_priority_queue3
                                (current_queue == 3'd3) ? buf_full_stored[3] :
                                `endif
                                `ifdef dma_priority_queue2
                                (current_queue == 3'd2) ? buf_full_stored[2] :
                                `endif
                                (current_queue == 3'd1) ? buf_full_stored[1] :
                                                          buf_full_stored[0];

        assign pkt_flush_norep = `hierarchy.gen_dma_i_edma_top.gen_pkt_buffer_i_edma_pbuf_tx.i_edma_pbuf_ahb_tx_wr.pkt_flush_norep_d1_reg.D ;


      `endif
    `endif


  // LEGACY DMA
  `else
    assign tx_grant = hready_tmp;
    `ifdef rtl
      assign dma_nxt_tx_data    = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.dma_state_data;
      assign dma_nxt_tx_descrd  = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.tx_dma_state_man_rd;
      assign dma_nxt_tx_descwr  = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.tx_dma_state_man_wr;
      assign dma_nxt_rx_descrd  = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.rx_dma_state_man_rd;
      assign dma_nxt_rx_descwr  = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.rx_dma_state_man_wr;
      assign dma_nxt_rx_data    = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.dma_state_data;
    `else
      assign dma_nxt_tx_data    = 1'b0;
      assign dma_nxt_tx_descrd  = 1'b0;
      assign dma_nxt_tx_descwr  = 1'b0;
      assign dma_nxt_rx_descrd  = 1'b0;
      assign dma_nxt_rx_descwr  = 1'b0;
      assign dma_nxt_rx_data    = 1'b0;
    `endif
  `endif






  `ifdef rtl
    `ifdef edma_tx_pkt_buffer
      assign rx_grant = `hier_pbuf_rx.i_edma_pbuf_rx_rd.hgrant_descr | `hier_pbuf_rx.i_edma_pbuf_rx_rd.hgrant_data;
//      assign dma_nxt_rx_data = `hier_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_data;
      assign dma_nxt_tx_desc = `hier_pbuf_tx_wr.dma_state_man_rd |
                               `hier_pbuf_tx_wr.dma_state_man_wr;
      assign dma_nxt_rx_desc = `hier_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_rd |
                               `hier_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_wr;
      assign dma_nxt_tx_idle = `hier_pbuf_tx_wr.dma_state == 0;

    `else
      assign rx_grant = tx_grant;
//      assign dma_nxt_rx_data = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.dma_state_data;
      assign dma_nxt_tx_desc = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.tx_dma_state_man_rd |
                               `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.tx_dma_state_man_wr;
      assign dma_nxt_rx_desc = `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.rx_dma_state_man_rd |
                               `hierarchy.gen_dma.gen_legacy_dma.i_edma_fifo_ahb_top.i_edma_fifo_ahb.rx_dma_state_man_wr;
   `endif



  // Gate Level
  `else
   assign rx_grant = tx_grant;
//   assign dma_nxt_rx_data = 1'b0;
   assign dma_nxt_tx_desc = 1'b0;
   assign dma_nxt_rx_desc = 1'b0;
  `endif




  // When simulating with the random trans.pl packet generator, it is impossible for trans.pl to model
  // what happens in the DUT when the TX internal packet buffer gets full when configured for priority
  // queueing. In this case, the DMA will abort the current packet and rewind the internal FIFO write
  // pointer back to the start of the packet that caused the full condition.  It then waits until the
  // next frame has been transmitted to the wire before attempting to reread the current packet from AHB.
  // the trans.pl just builds the datafiles and assumes the internal packet buffer NEVER fills up, so we
  // need to model that here.


  // when the buffer for a queue is full, the GEM core will continue reading the remaining descriptors
  // for the other queues until all descriptors have completed.  This process cannot be modelled by trans.pl
  // The following signal will indicate when the descriptor access should be auto-completed.  This happens
  // when one of the queue's descriptors was read during a descriptor read, and the used bit was clear but
  // the buffer associated with that queue indicated a full state.  In this case, trans.pl will think
  // the packet is okay to be read, but the design will not and will replay the dexcriptor later on. What
  // we do here is to auto-complete any remaining descriptor fetches with used bits set and then rewind the
  // index to the datafiles back to the start of the descriptor accesses.
  // There is also a corner case to consider here.  in the GEM 32bit DMA code, there are 2 AHB accesses for each
  // queue's descriptor read(so for 3 queues, there are 6 AHB accesses).  The 1st access gives us knowledge of the
  // used bit and is used to drive the hbusreq signal.  Imagine a situation where there are 3 queues, queue 1 is
  // empty(the used bit is set), queue 2 has data ready to transmit. Assuming 1 wait state, the following AHB accesses
  // will happen ... address A is for the first descriptor to queue 0, B is the 2nd descriptor to queue0, C is 1st descr
  // to queue 1 etc.
  //
  // hbusreq    __---------____
  // hgrant     ___---------___
  // htrans     000022222222200
  // haddr      AAAAABBCCDDEE
  // hready_tmp     -----_-_-_-_-_-
  // DescrAData ______-________
  // DescrBData ________-______
  // DescrCData __________-____
  // DescrDData ____________-__
  // DescrEData ______________-

  // When DescrAData is high, the read data is checked for the used bit high, and also the internal DPRAM buffer
  // for that queue is checked for fullness.  If either the DPRAM buffer is full, or the used bit is set, then
  // hbusreq stays high and we continue reading the other descriptors. In our example the used bit for descriptor0
  // is set, so we continue reading.

  // When DescrCData is high, the read data is the 1st data for the 2nd descriptor.  The used bit is clear, and the buffer
  // is not full, so hbusreq is cleared and we proceed to transmit from that queue ... Note that due to AHB pipeline,
  // the 1st descriptor of the third queue is done, but the data returned is thrown away. trans.pl models this.

  // In the next example, the buffer is full on the 1st descriptor access of the 2nd queue, meaning hbusreq is not cleared.
  // however, the buffer becomes empty almost immediately.  In this corner case, the GEM core will continue to use queue2
  // to transmit but will end up performing a dummy extra read.
  // This extra read cannot be  modelled by trans.pl and we therefore need to take care of this in this TB - the signal used
  // to identify this is "extra_ahb_read_descr_rd"
  //
  // hbusreq    __|----------__
  // hgrant     ___|----------_
  // htrans     000022222222200
  // haddr      AAAAABBCCDDEE
  // hready_tmp     -----_-_-_-_-_-
  // DescrAData ______-________
  // DescrBData ________-______
  // DescrCData __________-____
  // DescrDData ____________-__
  // DescrEData ______________-
  // Buf2Full   ----------_____




  // on the first of 2 descriptor read access.
  `ifdef dma_priority_queue1
  // auto_complete_descrd_en is just an enable signal - it captures lots of the signals that have to be true
  // before a auto completion can continue ...
  reg auto_complete_descrd_en;
  reg queue_was_full;
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      auto_complete_descrd_en <= 1'b0;
      queue_was_full <= 1'b0;
    end
    else
    begin
      if (dma_nxt_tx_descrd & tx_grant & prev_eof_bit & hready_tmp & dma_tx_descrd & (|htrans))
        auto_complete_descrd_en <= 1'b1;
      else if (descr_rd_done_dph & hready_tmp)
        auto_complete_descrd_en <= 1'b0;

      if (dma_bus_width[0])
      begin
      end
      else
      begin

        if (hready_tmp)
          queue_was_full <= tx_buffer_full_str;

      end
    end
  end

  // see comment above ...
//  assign extra_ahb_read_descr_rd = auto_complete_descrd_en & queue_was_full & ~tx_buffer_full_str & alt_cycle_32bit_dph &
//                                  (|htrans) & hready_tmp & dma_tx_descrd;

  // auto complete the descriptor, then replay the packet by rewinding the pointers
  assign bf_auto_complete_descrd = (pkt_flush_norep|tx_buffer_full_str|queue_was_full) & using_tx_descr_rd_dph &
                                  auto_complete_descrd_en & ~used_bit_read & descr_rd_done_dph & (|htrans) & hready_tmp;


  `endif


  `ifdef dma_priority_queue1
  // Need to replay the packet if the packet fetch was restarted due to DPRAM region becoming full
  // while in datastate or manrd
    assign replay_current_packet = pkt_flush_norep &
                                   (dma_nxt_tx_data | (dma_nxt_tx_descrd & (~prev_eof_bit | ~descrd_auto_comp)));

    // rewind_index_en will rewind the pointers back to the beginning of the last descriptor read
    assign rewind_index_en = (descrd_auto_comp | replay_current_packet);
  `endif


   assign next_lock = hlock_data;

   always @(negedge reset_tb or posedge hclk)
     if (~reset_tb)
     begin
       delay_hready <= {4'h0,amba_ready_delay};
       random_hready <= 0;
       hlock_data <= 0;


     end

     else
     begin
//       random_hready_tmp <= $random;
       if (hlockdma & insert_wait)
         hlock_data <= 1'b1;
       else if (insert_wait)
         hlock_data <= 1'b0;

       if (insert_wait & ((dma_nxt_tx_descwr & tx_grant) |(dma_nxt_rx_descwr & rx_grant)))
       begin
          tmp = $random;
          if (descr_max == descr_min)
            tmp = descr_max;
          else while ((tmp > descr_max) | (tmp < descr_min) | (tmp < write_min) | (tmp > write_max))
            tmp = $random;
          random_hready <= tmp;
       end
       else if (insert_wait & ((dma_nxt_tx_descrd & tx_grant) |(dma_nxt_rx_descrd & rx_grant)))
       begin
          tmp = $random;
          if (descr_max == descr_min)
            tmp = descr_max;
          else while ((tmp > descr_max) | (tmp < descr_min) | (tmp < read_min) | (tmp > read_max))
            tmp = $random;
          random_hready <= tmp;
       end
       else if (insert_wait & ((dma_nxt_tx_data & tx_grant)))
       begin
         if (next_lock)
         begin
          tmp = $random;
          if (data_max_lock == data_min_lock)
            tmp = data_min_lock;
          else while ((tmp > data_max_lock) | (tmp < data_min_lock) | (tmp < read_min) | (tmp > read_max))
            tmp = $random;
           random_hready <= tmp;
         end
         else
         begin
          tmp = $random;
          if (data_max == data_min)
            tmp = data_min;
          else while ((tmp > data_max) | (tmp < data_min) | (tmp < read_min) | (tmp > read_max))
            tmp = $random;
           random_hready <= tmp;
         end
       end
       else if (insert_wait & ((dma_nxt_rx_data & rx_grant)))
       begin
         if (next_lock)
         begin
          tmp = $random;
          if (data_max_lock == data_min_lock)
            tmp = data_min_lock;
          else while ((tmp > data_max_lock) | (tmp < data_min_lock) | (tmp < write_min) | (tmp > write_max))
            tmp = $random;
           random_hready <= tmp;
         end
         else
         begin
          tmp = $random;
          if (data_max == data_min)
            tmp = data_min;
          else while ((tmp > data_max) | (tmp < data_min) | (tmp < write_min) | (tmp > write_max))
            tmp = $random;
           random_hready <= tmp;
         end
       end
       else if (insert_wait)
           random_hready <= 0;



       if (hready_stop)
         delay_hready <= {4'h0,delay_hready};

       // Next clock will be final wait state (zero wait state)
       else if (insert_wait & randomize_hready)
         delay_hready <= random_hready;

       else if (insert_wait & (amba_ready_delay == 4'h0))
         delay_hready <= amba_ready_delay;

      else if (insert_wait_hold & (delay_hready == 4'h1))
         delay_hready <= amba_ready_delay;

       else if (insert_wait_hold)
         delay_hready <= delay_hready - 8'h01;

       // Else maintain value
       else
         delay_hready <= delay_hready;
     end


   // hready_tmp generation
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         hready_tmp <= 1'b1;

      else if (hready_stop)
         hready_tmp <= 1'b0;

      else if (insert_wait & randomize_hready & random_hready == 0)
        hready_tmp <= 1'b1;

      else if (insert_wait & ~randomize_hready & amba_ready_delay == 0)
        hready_tmp <= 1'b1;

      else if (insert_wait_hold & delay_hready == 8'h01)
        hready_tmp <= 1'b1;

      // New access detected or already detected so counting wait states
      else if (insert_wait | insert_wait_hold)
         hready_tmp <= 1'b0;

      // Else toggle hready_tmp outside valid access to get coverage
      else
         hready_tmp <= ~hready_tmp;

   always @(negedge hclk)
     hready = hready_tmp;


// -----------------------------------------------------------------------------
// hready_tmp stopping
// -----------------------------------------------------------------------------

   // read hready_tmp stop data from file
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
  `ifdef dma_priority_queue1
  always @(negedge reset_tb or posedge hclk)
  begin
    if (~reset_tb)
    begin
      descr_rd_cnt        <= top_queue;
      descrd_auto_comp    <= 1'b0;
      rewind_index_tx_descr        <= 1;
      rewind_index_alt        <= 1;
      alt_cycle_32bit_aph <= 1'b0;
      alt_cycle_32bit_dph <= 1'b0;
      dma_tx_descrd       <= 1'b0;
    end
    else
    begin
      if (hready_tmp)
      begin
        dma_tx_descrd <= dma_nxt_tx_descrd & tx_grant;
        //check DMA read address
        if (~dma_tx_descrd & dma_nxt_tx_descrd & tx_grant)
        begin
          if (prev_eof_bit)
          begin
            rewind_index_tx_descr <= tx_descr_next_dma_rd_index;
            rewind_index_alt <= alt_next_dma_rd_index;
          end
          alt_cycle_32bit_aph <= 1'b0;
          alt_cycle_32bit_dph <= 1'b0;
          descr_rd_cnt <= top_queue;
        end
        else
        begin
          if (rd_addr_phase)
            alt_cycle_32bit_aph <= ~alt_cycle_32bit_aph;
          if (rd_data_phase)
            alt_cycle_32bit_dph <= ~alt_cycle_32bit_dph;

//          if (bf_auto_complete_descrd & tx_grant)
          if (bf_auto_complete_descrd)
          begin
            // descr_rd_cnt gives some indication of how many more descr rds are required
            descrd_auto_comp <= 1'b1;
          end
          else if (~dma_nxt_tx_descrd)
          begin
            descrd_auto_comp <= 1'b0;
          end

          if (dma_nxt_tx_descrd & prev_eof_bit & rd_addr_phase & tx_grant & descr_rd_done_dph)
          begin
            if (descr_rd_cnt == 0)
              descr_rd_cnt <= top_queue;
            else
              descr_rd_cnt <= descr_rd_cnt - 1;
          end
          else if (~dma_nxt_tx_descrd)
              descr_rd_cnt <= top_queue;
        end
      end
    end
  end
  `else
  assign descrd_auto_comp = 0;
  `endif

//  assign tx_final_descr_filling_buffers = (rd_addr_phase & haddr !== next_read_add);dma_nxt_tx_descrd
  wire rx_final_extra_descr_rd;  // the AHB RX DMA will sometimes do an extra descriptor read after receiving the final frame
                                 // to prepare for the next frame. At the end of the test we dont care about this ...
                                 // if the DUT goes on to use this read for any reason, we will catch it with the payload read
  reg already_ignored_rx_final_descriptor_rd1;
  reg already_ignored_rx_final_descriptor_rd2;
  assign rx_final_extra_descr_rd = (rd_addr_phase & haddr !== next_read_add && dma_nxt_rx_descrd && dma_rd_vector_nxt_orig[98] & !(already_ignored_rx_final_descriptor_rd1 & already_ignored_rx_final_descriptor_rd2));


   // check write & read address
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
      begin
         address_fail <= 1'b0;
         already_ignored_rx_final_descriptor_rd1 <= 1'b0;
         already_ignored_rx_final_descriptor_rd2 <= 1'b0;
      end
      else
         begin
            // check DMA write address
            if (double_error_injection) // Ignore all writes !
            begin
            end
            else if (wr_addr_phase)
               begin
                 if (gem_dma_addr_w_is_64)
                  // check DMA write address
                  if (haddr !== next_write_add)
                     begin
                        $display("\n **** error DMA WRITE ADDRESS expected :- (%h or %h or %h)  got :- %h (%0dns)",next_write_add_orig,next_write_add_alt,next_write_add_rx_descr,haddr,$time);
                        address_fail <= 1'b1;
                     end
                  else if (haddr === next_write_add)
                     begin
                        `ifdef debugmsglvl0
                        `else
                        $display("       good DMA WRITE ADDRESS got :- %h",haddr);
                        `endif
                        address_fail <= 1'b0;
                     end
                  else
                     begin
                        $display("\n **** error DMA WRITE ADDRESS expected :- (%h or %h or %h)  got :- %h (%0dns)",next_write_add_orig,next_write_add_alt,next_write_add_rx_descr,haddr,$time);
                        address_fail <= 1'b1;
                     end
                 else // 32b
                  // check DMA write address
                  if (haddr[31:0] !== next_write_add[31:0])
                     begin
                        $display("\n **** error DMA WRITE ADDRESS expected :- (%h or %h or %h)  got :- %h (%0dns)",next_write_add_orig[31:0],next_write_add_alt[31:0],next_write_add_rx_descr[31:0],haddr[31:0],$time);
                        address_fail <= 1'b1;
                     end
                  else if (haddr[31:0] === next_write_add[31:0])
                     begin
                        `ifdef debugmsglvl0
                        `else
                        $display("       good DMA WRITE ADDRESS got :- %h",haddr[31:0]);
                        `endif
                        address_fail <= 1'b0;
                     end
                  else
                     begin
                        $display("\n **** error DMA WRITE ADDRESS expected :- (%h or %h or %h)  got :- %h (%0dns)",next_write_add_orig[31:0],next_write_add_alt[31:0],next_write_add_rx_descr[31:0],haddr[31:0],$time);
                        address_fail <= 1'b1;
                     end
               end


            if (rd_addr_phase)
               begin
                 if (rx_final_extra_descr_rd)
                 begin
                  already_ignored_rx_final_descriptor_rd1 <= 1'b1;
                  already_ignored_rx_final_descriptor_rd2 <= already_ignored_rx_final_descriptor_rd1;
                  `ifdef debugmsglvl0
                  `else
                    $display("       Unexpected Final few RX Descriptor Read from design is OKAY(filling up DUT's descriptor buffer. Address = %h (%0dns)",haddr[31:0],$time);
                  `endif
                 end
                 else if (double_error_injection) // Ignore reads when error injected into design
                 begin
                 end
                 else if (gem_dma_addr_w_is_64)
                // check DMA read address
                  if (((bf_auto_complete_descrd & dma_bus_width == 2'b00) | descrd_auto_comp) & dma_nxt_tx_descrd)
                  begin
                    $display("       Ignoring remainder of Descr rd as DPRAM region is full(%0dns)",$time);
                  end
                  else if (haddr !== next_read_add)
                     begin
                        $display("\n **** error DMA READ ADDRESS  expected :- (%h or %h or %h)  got :- %h (%0dns)",next_read_add_orig,next_read_add_alt,next_read_add_tx_descr,haddr,$time);
                        address_fail <= 1'b1;
                     end
                  else if (haddr === next_read_add)
                     begin
                        `ifdef debugmsglvl0
                        `else
                        $display("       good DMA READ ADDRESS  got :- %h",haddr);
                        address_fail <= 1'b0;
                        `endif
                     end
                  else
                     begin
                        $display("\n **** error DMA READ ADDRESS  expected :- (%h or %h or %h)  got :- %h (%0dns)",next_read_add_orig,next_read_add_alt,next_read_add_tx_descr,haddr,$time);
                        address_fail <= 1'b1;
                     end
                 else // 32b
                // check DMA read address
                  if (descrd_auto_comp & dma_nxt_tx_descrd)
                  begin
                    $display("       Ignoring remainder of Descr rd as DPRAM region is full(%0dns)",$time);
                  end
                  else if (haddr[31:0] !== next_read_add[31:0])
                     begin
                        $display("\n **** error DMA READ ADDRESS  expected :- (%h or %h or %h)  got :- %h (%0dns)",next_read_add_orig[31:0],next_read_add_alt[31:0],next_read_add_tx_descr,haddr[31:0],$time);
                        address_fail <= 1'b1;
                     end
                  else if (haddr[31:0] === next_read_add[31:0])
                     begin
                        `ifdef debugmsglvl0
                        `else
                        $display("       good DMA READ ADDRESS  got :- %h",haddr[31:0]);
                        address_fail <= 1'b0;
                        `endif
                     end
                  else
                     begin
                        $display("\n **** error DMA READ ADDRESS  expected :- (%h or %h or %h)  got :- %h (%0dns)",next_read_add_orig[31:0],next_read_add_alt[31:0],next_read_add_tx_descr,haddr[31:0],$time);
                        address_fail <= 1'b1;
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
      else if (wr_data_phase & hready_tmp & ~double_error_injection)
         begin

            // check DMA write data
            case (access_width_saved)
            2'b00   : begin // 32 bit access

                         // first 32 bits
                         if (write_data_31to0_end[31:0] === 32'hzzzzzzzz)
                           begin
                           `ifdef debugmsglvl0
                           `else
                             $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                           `endif
                           end
                         else if (data_lane_written[31:0] !== write_data_31to0_end[31:0])
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_31to0_end[31:0],data_lane_written[31:0],$time);
                               data_fail <= 1'b1;
                            end
                         else if (data_lane_written[31:0] === write_data_31to0_end[31:0])
                            begin
                               `ifdef debugmsglvl0
                               `else
                               $display("       good DMA WRITE DATA  got :- %h",data_lane_written[31:0]);
                               `endif
                               data_fail <= 1'b0;
                            end
                         else
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_31to0_end[31:0],data_lane_written[31:0],$time);
                               data_fail <= 1'b1;
                            end
                      end


            2'b01   : begin // 64 bit access

                         // first 32 bits
                         if (write_data_31to0_end[31:0] === 32'hzzzzzzzz)
                           begin
                           `ifdef debugmsglvl0
                           `else
                             $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                           `endif
                           end
                         else if (data_lane_written[31:0] !== write_data_31to0_end[31:0])
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_31to0_end[31:0],data_lane_written[31:0],$time);
                               data_fail <= 1'b1;
                            end
                         else if (data_lane_written[31:0] === write_data_31to0_end[31:0])
                            begin
                               `ifdef debugmsglvl0
                               `else
                               $display("       good DMA WRITE DATA  got :- %h",data_lane_written[31:0]);
                               `endif
                               data_fail <= 1'b0;
                            end
                         else
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_31to0_end[31:0],data_lane_written[31:0],$time);
                               data_fail <= 1'b1;
                            end

                         // second 32 bits
                         if (write_data_63to32_end[31:0] === 32'hzzzzzzzz)
                           $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                         else if (data_lane_written[63:32] !== write_data_63to32_end[31:0])
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_63to32_end[31:0],data_lane_written[63:32],$time);
                               data_fail <= 1'b1;
                            end
                         else if (data_lane_written[63:32] === write_data_63to32_end[31:0])
                            begin
                               `ifdef debugmsglvl0
                               `else
                               $display("       good DMA WRITE DATA  got :- %h",data_lane_written[63:32]);
                               `endif
                               // data_fail maintains current value
                            end
                         else
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_63to32_end[31:0],data_lane_written[63:32],$time);
                               data_fail <= 1'b1;
                            end
                      end


            default : begin // 128 bit access

                         // first 32 bits
                         if (write_data_31to0_end[31:0] === 32'hzzzzzzzz)
                           begin
                           `ifdef debugmsglvl0
                           `else
                             $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                           `endif
                           end
                         else if (data_lane_written[31:0] !== write_data_31to0_end[31:0])
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_31to0_end[31:0],data_lane_written[31:0],$time);
                               data_fail <= 1'b1;
                            end
                         else if (data_lane_written[31:0] === write_data_31to0_end[31:0])
                            begin
                               `ifdef debugmsglvl0
                               `else
                               $display("       good DMA WRITE DATA  got :- %h",data_lane_written[31:0]);
                               `endif
                               data_fail <= 1'b0;
                            end
                         else
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_31to0_end[31:0],data_lane_written[31:0],$time);
                               data_fail <= 1'b1;
                            end

                         // second 32 bits
                         if (write_data_63to32_end[31:0] === 32'hzzzzzzzz)
                           $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                         else if (data_lane_written[63:32] !== write_data_63to32_end[31:0])
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_63to32_end[31:0],data_lane_written[63:32],$time);
                               data_fail <= 1'b1;
                            end
                         else if (data_lane_written[63:32] === write_data_63to32_end[31:0])
                            begin
                               `ifdef debugmsglvl0
                               `else
                               $display("       good DMA WRITE DATA  got :- %h",data_lane_written[63:32]);
                               `endif
                               // data_fail maintains current value
                            end
                         else
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_63to32_end[31:0],data_lane_written[63:32],$time);
                               data_fail <= 1'b1;
                            end

                         // third 32 bits
                         if (write_data_95to64_end[31:0] === 32'hzzzzzzzz)
                           begin
                           `ifdef debugmsglvl0
                           `else
                             $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                           `endif
                           end
                         else if (data_lane_written[95:64] !== write_data_95to64_end[31:0])
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_95to64_end[31:0],data_lane_written[95:64],$time);
                               data_fail <= 1'b1;
                            end
                         else if (data_lane_written[95:64] === write_data_95to64_end[31:0])
                            begin
                               `ifdef debugmsglvl0
                               `else
                               $display("       good DMA WRITE DATA  got :- %h",data_lane_written[95:64]);
                               `endif
                               // data_fail maintains current value
                            end
                         else
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_95to64_end[31:0],data_lane_written[95:64],$time);
                               data_fail <= 1'b1;
                            end

                         // fourth 32 bits
                         if (write_data_127to96_end[31:0] === 32'hzzzzzzzz)
                           begin
                           `ifdef debugmsglvl0
                           `else
                             $display("       Warning ...  DMA WRITE DATA not checked due to Z's in testcase (%0dns)",$time);
                           `endif
                           end
                         else if (data_lane_written[127:96] !== write_data_127to96_end[31:0])
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_127to96_end[31:0],data_lane_written[127:96],$time);
                               data_fail <= 1'b1;
                            end
                         else if (data_lane_written[127:96] === write_data_127to96_end[31:0])
                            begin
                               `ifdef debugmsglvl0
                               `else
                               $display("       good DMA WRITE DATA  got :- %h",data_lane_written[127:96]);
                               `endif
                               // data_fail maintains current value
                            end
                         else
                            begin
                               $display("\n **** error DMA WRITE DATA    expected :- %h  got :- %h (%0dns)",write_data_127to96_end[31:0],data_lane_written[127:96],$time);
                               data_fail <= 1'b1;
                            end
                      end
            endcase
         end // wr_data_phase
   end // always


// -----------------------------------------------------------------------------
// drive read data
// -----------------------------------------------------------------------------

   // supply read data
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
         hrdata_tmp <= 128'b0;
      else
         begin
            if (rd_addr_phase)
               begin
                  case (access_width)
                  2'b00   : begin // 32 bit access
                               `ifdef debugmsglvl0
                               `else
                               $display("            DMA READ DATA                                  %h",read_data_31to0_end[31:0]);
                               `endif
                               // drive correct word lanes
                               case (data_lane_sel_rd)
                                  2'b00   : hrdata_tmp[127:0] <= {96'b0, read_data_31to0_end[31:0]};
                                  2'b01   : hrdata_tmp[127:0] <= {64'b0, read_data_31to0_end[31:0], 32'b0};
                                  2'b10   : hrdata_tmp[127:0] <= {32'b0, read_data_31to0_end[31:0], 64'b0};
                                  2'b11   : hrdata_tmp[127:0] <= {read_data_31to0_end[31:0], 96'b0};
                                  default : hrdata_tmp[127:0] <= 128'bx & {128{~fault_sim}};
                               endcase
                            end
                  2'b01   : begin // 64 bit access
                               `ifdef debugmsglvl0
                               `else
                               $display("            DMA READ DATA                                  %h",read_data_31to0_end[31:0]);
                               `endif
                               // drive correct word lanes
                               case (data_lane_sel_rd)
                                  2'b00   : hrdata_tmp[127:0] <= {96'b0, read_data_31to0_end[31:0]};
                                  2'b10   : hrdata_tmp[127:0] <= {32'b0, read_data_31to0_end[31:0], 64'b0};
                                  2'b01   : hrdata_tmp[127:0] <= {64'b0, read_data_31to0_end[31:0], 32'b0};
                                  default : hrdata_tmp[127:0] <= {read_data_31to0_end[31:0], 96'b0};
                               endcase

                               `ifdef debugmsglvl0
                               `else
                               $display("            DMA READ DATA                                  %h",read_data_63to32_end[31:0]);
                               `endif
                               // drive correct word lanes
                               case (data_lane_sel_rd)
                                  2'b00   : hrdata_tmp[63:32]  <= read_data_63to32_end[31:0];
                                  2'b10   : hrdata_tmp[127:96] <= read_data_63to32_end[31:0];
                                  2'b01   : hrdata_tmp[31:0]   <= read_data_63to32_end[31:0];
                                  default : hrdata_tmp[95:64]  <= read_data_63to32_end[31:0];
                               endcase
                            end
                  default : begin // 128 bit access
                               `ifdef debugmsglvl0
                               `else
                               $display("            DMA READ DATA                                  %h",read_data_31to0_end[31:0]);
                               `endif
                               // drive correct word lanes
                               case (data_lane_sel_rd)
                                  2'b00   : hrdata_tmp[31:0]  <= read_data_31to0_end[31:0];
                                  2'b11   : hrdata_tmp[31:0]  <= read_data_127to96_end[31:0];
                                  default : hrdata_tmp[127:0] <= 128'bx & {128{~fault_sim}};
                               endcase

                               `ifdef debugmsglvl0
                               `else
                               $display("            DMA READ DATA                                  %h",read_data_63to32_end[31:0]);
                               `endif
                               // drive correct word lanes
                               case (data_lane_sel_rd)
                                  2'b00   : hrdata_tmp[63:32] <= read_data_63to32_end[31:0];
                                  2'b11   : hrdata_tmp[63:32] <= read_data_95to64_end[31:0];
                                  default : hrdata_tmp[127:0] <= 128'bx & {128{~fault_sim}};
                               endcase

                               `ifdef debugmsglvl0
                               `else
                               $display("            DMA READ DATA                                  %h",read_data_95to64_end[31:0]);
                               `endif
                               // drive correct word lanes
                               case (data_lane_sel_rd)
                                  2'b00   : hrdata_tmp[95:64] <= read_data_95to64_end[31:0];
                                  2'b11   : hrdata_tmp[95:64] <= read_data_63to32_end[31:0];
                                  default : hrdata_tmp[127:0] <= 128'bx & {128{~fault_sim}};
                               endcase

                               `ifdef debugmsglvl0
                               `else
                               $display("            DMA READ DATA                                  %h",read_data_127to96_end[31:0]);
                               `endif
                               // drive correct word lanes
                               case (data_lane_sel_rd)
                                  2'b00   : hrdata_tmp[127:96] <= read_data_127to96_end[31:0];
                                  2'b11   : hrdata_tmp[127:96] <= read_data_31to0_end[31:0];
                                  default : hrdata_tmp[127:0]  <= 128'bx & {128{~fault_sim}};
                               endcase
                            end
                  endcase
               end // rd_data_phase


         end // clock else
   end // always

   // Default AHB read fill data value
   // At every valid read data phase toggle fill data
   initial hrdata_fill = 128'b0;
   always @(posedge hready_tmp)
      if (rd_data_phase)
         hrdata_fill <= ~hrdata_fill;

assign hrdata_tmp2 = (hready_tmp & rd_data_phase)? hrdata_tmp : hrdata_fill;
always @(negedge hclk)
   hrdata = hrdata_tmp2;


// -----------------------------------------------------------------------------
// hresp output
// -----------------------------------------------------------------------------

   // drive hresp output
   // 00 is OKAY anything else is not OK
   // Use one of ERROR, RETRY or SPLIT, depending on address & data bits
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
         hresp_tmp <= 2'b00;
      else if (wr_addr_phase)
         hresp_tmp <= {(wr_not_ok & haddr[31]),
                       (wr_not_ok & (hwdata[31] | ~haddr[31]))};
      else if (rd_addr_phase)
         hresp_tmp <= {(rd_not_ok & haddr[31]),
                       (rd_not_ok & (hwdata[31] | ~haddr[31]))};
   end
always @(negedge hclk)
   hresp = hresp_tmp;


// -----------------------------------------------------------------------------
// check hprot value
// -----------------------------------------------------------------------------

   // check hprot value
   always @(negedge reset_tb or posedge hclk)
   begin
      if (~reset_tb)
         hprot_fail <= 1'b0;
      else if (hprot !== `edma_hprot_value)
         begin
            $display("\n **** error HPROT value   expected :- %b  got :- %b",`edma_hprot_value,hprot);
            hprot_fail <= 1'b1;
         end
   end



// -----------------------------------------------------------------------------
// drive done signal to top level testbench
// -----------------------------------------------------------------------------

   // drive done signal
   assign dma_done = dma_rd_done & dma_wr_done;


// -----------------------------------------------------------------------------
// indicate failure to top level testbench
// -----------------------------------------------------------------------------

   // register width_fail (only valid on a clock edge in gate level sims)
   always @(negedge reset_tb or posedge hclk)
      if (~reset_tb)
         width_fail_reg <= 1'b0;
      else
         width_fail_reg <= width_fail;


   // failure signal
   assign dma_fail = width_fail_reg | address_fail | data_fail | burst_fail |
                     hprot_fail;

`endif

endmodule

