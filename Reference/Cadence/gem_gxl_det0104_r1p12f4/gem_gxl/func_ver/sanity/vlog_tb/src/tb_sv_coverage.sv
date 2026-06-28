//------------------------------------------------------------------------------
// Copyright (c) 2012-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_sv_coverage.sv
//   Module Name:        sv_coverage
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
//   Description    : Contains SVA assertionbs
//
//------------------------------------------------------------------------------

`include "tb_defs.v"
`timescale 1ns/1ps

module sv_coverage (
  input         disable_asf_assertions
);

// GMORRIS: need to comment out in all reg test
`ifndef UVM_ALL_REG_TEST

`ifdef rtl // add to ensure gate level sims don't use coverage

`ifndef TB_DEFS
  `include "tb_defs.v"
`endif

// --
// Wire declarations for coverpoints (mostly)
// --
wire axi_valid;
wire hclk;
wire hready;
wire tx_pad_en;
wire rx_pad_en;
wire tx_pad;
wire rx_pad;
reg rx_pad_d1 = 1'b0;
reg tx_pad_d1 = 1'b0;
reg [3:0] tx_pad_cnt = 4'h0;
reg [3:0] rx_pad_cnt = 4'h0;
wire [7:0] scr2_ethtype_match;
wire [31:0] scr2_compare_match;
wire [2:0] priority_queue_cp;
wire [99:0] match_queue_type1;
wire [99:0] match_queue_type2;
wire check_bndry_1k_crossed;
wire [1:0] data_width;
wire  addressing_64b;
wire  addressing_64b_en;
wire  tx_ext_bd;
wire  rx_ext_bd;
wire priority_queue;
wire  descriptor_endian_swap;
integer spram_divisor;               // SPRAM Period Divisor
wire dma_bus_width;
wire check_ahb_error_in_burst;
bit  descr_access;
wire axi_mode;
wire tx_eob_burst_has_err;
wire rx_eob_burst_has_err;
wire rx_eop_burst_has_err;
wire tx_eob_burst_crosses_1k;
wire rx_eob_burst_crosses_1k;
wire rx_eop_burst_crosses_1k;
wire tx_descr_rd_check_trigger;
wire tx_enable;
wire rx_enable;
bit  [1:0] last_tx_descr_access_cnt;
bit  [1:0] tx_descr_access_cnt_wr;
bit  [1:0] last_tx_descr_access_cnt_wr;
bit  [2:0] tx_ahb_queue_aph;
bit  [2:0] tx_ahb_queue_aph_wr;
bit  [2:0] tx_ahb_queue_aph_last;
bit  [2:0] tx_ahb_queue_aph_last_wr;
bit        last_tx_dma_state_is_man_rd;
bit        last_tx_dma_state_is_man_wr;
bit        tx_manwr_done_d1;
wire tx_dma_state_is_man_rd;
wire tx_dma_state_is_man_wr;
wire tx_descr_rd_access;
wire tx_descr_wr_access;
wire tx_manrd_done;
wire tx_manwr_done;
wire tx_dma_state_man_wr;
wire rx_dma_state_man_wr;
wire rx_dma_state_man_rd;
wire tx_dma_state_man_rd;
wire [2:0] tx_ahb_access_size;
bit [3:0]  rx_descr_access_cnt;
bit [3:0]  rx_descr_access_cnt_wr;
bit [3:0]  last_rx_descr_access_cnt;
bit [3:0]  last_rx_descr_access_cnt_wr;
bit [3:0]  rx_descr_access_cnt_end;
bit [3:0]  rx_descr_access_cnt_wr_end;
bit        rx_dma_state_man_rd_d1;
bit        rx_dma_state_man_wr_d1;
wire  rx_dma_state_man_rd_end;
wire  rx_dma_state_man_wr_end;
wire rx_clk;
wire n_rxreset;
wire rx_w_eop;
wire rx_w_err;

wire  [5:0] rx_dec_state;
reg   [5:0] rx_dec_state_last;

assign rx_clk    = `hierarchy.i_gem_mac.i_gem_rx.rx_clk;
assign n_rxreset = `hierarchy.i_gem_mac.i_gem_rx.n_rxreset;
assign rx_w_eop  = `hierarchy.i_gem_mac.i_gem_rx.rx_w_eop;
assign rx_w_err  = `hierarchy.i_gem_mac.i_gem_rx.rx_w_err;

assign rx_dec_state = `hierarchy.i_gem_mac.i_gem_rx.i_rx_deco.rx_dec_state;
always@(posedge rx_clk or negedge n_rxreset)
begin
  if (~n_rxreset)
    rx_dec_state_last <= 6'h00;
  else
    rx_dec_state_last <= rx_dec_state;
end


  reg tx_descr_no_check;  // ignore all the AXI responses associated with requests made while tx_enable was low
  initial
  begin
    tx_descr_no_check      = 0;
  end



`ifdef edma_tx_pkt_buffer
  `ifdef edma_axi
    assign  rx_dma_state_man_rd_end = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_reads[0].rx_descr_rd_req_done;
    reg last_rx_descr_wr;
    initial last_rx_descr_wr = 0;
    always @(posedge hclk)
      last_rx_descr_wr <= `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_wr_fifo_add_pop;
    assign  rx_dma_state_man_wr_end = last_rx_descr_wr;
  `else
    assign  rx_dma_state_man_rd_end = rx_dma_state_man_rd_d1 && ~rx_dma_state_man_rd;
    assign  rx_dma_state_man_wr_end = rx_dma_state_man_wr_d1 && ~rx_dma_state_man_wr;
  `endif
`endif


bit         rd_address_valid;
bit         wr_address_valid;
bit  [31:0] rd_upper_address;
bit  [31:0] wr_upper_address;
bit [`edma_addr_width-1:0] haddr;



// --
// Qualifiers for assertions-
// --
// moving them to here to make it more obvious
`ifdef edma_axi
  assign axi_valid  = 1'b1;
  assign axi_mode   = 1'b1;
`else
  assign axi_valid  = 1'b0;
  assign axi_mode   = 1'b0;
`endif

`ifdef xgm
assign tx_status         = tb_xgm.i_xgm.i_xgm_tx.stats_eop;
wire [31:0] tx_pkt_length = tb_xgm.i_xgm.i_xgm_tx.frame_len;
wire mac_tx_clk            = tb_xgm.i_xgm.i_xgm_tx.tx_clk;
wire mac_rx_clk            = tb_xgm.i_xgm.i_xgm_edma_wrapper.rx_w_clk;
`else
wire mac_tx_clk = `hierarchy.i_gem_mac.i_gem_tx_wrap.i_gem_tx.tx_clk;
wire mac_rx_clk = `hierarchy.i_gem_mac.i_gem_rx.rx_clk;
wire tx_status  = `hierarchy.i_gem_mac.i_gem_tx_wrap.i_gem_tx.tx_status_edge;
wire [31:0] tx_pkt_length = `hierarchy.i_gem_mac.i_gem_tx_wrap.i_gem_tx.tx_bytes_in_frame;
`endif


// --
// GMORRIS 26/09/13
// `top is specific to verilog TB.
// I've created local wires and assigning to the correesponding `top path
// only when we're not in UVM TB i.e. CDN_UVM is not defined
// --
wire cg_spram_system_sample;
wire gigabit;
wire speed;
wire [3:0] ten_gig_mode;
wire tb_top_dma_bus_width;
`ifndef CDN_UVM
   assign cg_spram_system_sample = `top.i_tb_top.cg_spram_system_sample;
   assign gigabit                = `top.i_tb_top.gigabit;
   assign speed                  = `top.i_tb_top.speed;
   assign ten_gig_mode           = `top.i_tb_top.ten_gig_mode;
   assign tb_top_dma_bus_width   = `top.i_tb_top.dma_bus_width;
`endif


`ifdef edma_tx_pkt_buffer
// wire added for >1 tx manwr waiting
  `ifdef edma_axi
    assign  rx_dma_state_man_rd_end = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_reads[0].rx_descr_rd_req_done;
    wire man_wr_cnt_1 = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.tx_descr_wr_rdy == 1'b0;
  `else
    wire man_wr_cnt_1 = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.man_wr_cnt[1];
  `endif
`else
wire man_wr_cnt_1 = 1'b0;
`endif

reg [2:0] man_wr_cnt_1_cnt = 3'b000 ;
reg       man_wr_cnt_1_multiple = 1'b0 ;

// count man_wr_cnt_1 occurances
// we want to detect more than one occurance as we know the
// condition occurs at the end of tests when the used bit is read
// but we want to detect at least one other occurance
always @(posedge man_wr_cnt_1)
begin
  if (man_wr_cnt_1_cnt <= 3'b111)
    man_wr_cnt_1_cnt = man_wr_cnt_1_cnt + 1;
  if (man_wr_cnt_1_cnt > 3'b001)
    man_wr_cnt_1_multiple <= 1'b1;
end

`ifdef rtl

`ifdef edma_tx_pkt_buffer
// This is the coverage file used to map coverage points defined in
// the gemstone2 project vplan

// ---------------------------------------------------------------------------
// Testing the feature to force GEM to always issue max length AHB bursts ...
// First create a signal that counts the number of padding
`ifdef edma_axi
assign hclk       = `hierarchy.aclk;
assign hreset     = `hierarchy.n_areset;
assign hready     = 1'b0;
assign tx_pad     = 1'b0;  //****TBD****
assign rx_pad     = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.padding_rph;
`else
assign hclk       = `hierarchy.hclk;
assign hreset     = `hierarchy.n_hreset;
assign hready     = `hierarchy.hready;
assign tx_pad     = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.reading_pad_rph;
assign rx_pad     = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.padding_rph;
`endif
assign tx_pad_en = `hierarchy.force_max_ahb_burst_tx;
assign rx_pad_en = `hierarchy.force_max_ahb_burst_rx;

always @(posedge hclk)
begin
  if (hready)
  begin
    rx_pad_d1 <= rx_pad;
    tx_pad_d1 <= tx_pad;
    if (tx_pad & ~tx_pad_d1)
      tx_pad_cnt <= tx_pad_cnt + 1;
    else if (tx_pad_d1 & ~tx_pad)
      tx_pad_cnt <= 0;
    else if (tx_pad_cnt != 4'h0)
      tx_pad_cnt <= tx_pad_cnt + 1;
    if (rx_pad & ~rx_pad_d1)
      rx_pad_cnt <= rx_pad_cnt + 1;
    else if (rx_pad_d1 & ~rx_pad)
      rx_pad_cnt <= 0;
    else if (rx_pad_cnt != 4'h0)
      rx_pad_cnt <= rx_pad_cnt + 1;
  end
end

wire tx_last_access_of_burst,rx_last_access_of_burst;
`ifdef edma_axi
// Cover the case where the burst at the end of a buffer crosses a 1k boundary ...
wire [31:0] rx_addr                 = 32'd0;
wire [1:0]  rx_htrans               = 2'd0;
wire [31:0] tx_addr                 = 32'd0;
wire [1:0]  tx_htrans               = 2'd0;
wire [4:0]  ahb_burst_length        = 5'd0;
assign      tx_last_access_of_burst = 1'b0;
assign      rx_last_access_of_burst = 1'b0;
wire [11:0] tx_num_words_left_rph   = 12'd0;
wire [11:0] rx_buf_words_left_rph   = 12'd0;
wire [11:0] rx_pkt_len              = 12'd0;
wire [11:0] rx_pkt_word_cnt         = 12'd0;
`else
wire [31:0] rx_addr = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.haddr_data;
wire [1:0]  rx_htrans = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.htrans_data;
wire [31:0] tx_addr = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.haddr_data;
wire [1:0]  tx_htrans = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.htrans_data;
wire [4:0]  ahb_burst_length = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.ahb_burst_length;
assign tx_last_access_of_burst = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.ahb_access_cnt == 0;
assign rx_last_access_of_burst = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.ahb_access_cnt == 0;
wire [11:0] tx_num_words_left_rph = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.num_requests;
wire [11:0] rx_buf_words_left_rph = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.buffer_fill_lvl;
wire [11:0] rx_pkt_len = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.status_word_1[26:15];
wire [11:0] rx_pkt_word_cnt = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.pkt_dplocns;
`endif

reg [11:0] tx_num_words_left_aph;
initial tx_num_words_left_aph <= 12'h000;
always@(posedge hclk)
  if (hready)
    tx_num_words_left_aph <= tx_num_words_left_rph;

reg  [11:0] rx_buf_words_left_aph;
initial   rx_buf_words_left_aph <= 12'h000;
always@(posedge hclk)
if (hready)
  rx_buf_words_left_aph <= rx_buf_words_left_rph;

wire [11:0] rx_words_remaining_rph;
reg  [11:0] rx_words_remaining_aph;
assign rx_words_remaining_rph = rx_pkt_len - rx_pkt_word_cnt;
initial rx_words_remaining_aph <= 12'h000;
always@(posedge hclk)
if (hready)
  rx_words_remaining_aph <= rx_words_remaining_rph;


assign tx_eob_burst_crosses_1k = tx_htrans[1] & tx_addr[11:0] == 12'h000 & ~tx_last_access_of_burst & tx_num_words_left_aph < ahb_burst_length;
assign rx_eob_burst_crosses_1k = rx_htrans[1] & rx_addr[11:0] == 12'h000 & ~rx_last_access_of_burst & rx_buf_words_left_aph < ahb_burst_length;
assign rx_eop_burst_crosses_1k = rx_htrans[1] & rx_addr[11:0] == 12'h000 & ~rx_last_access_of_burst & rx_words_remaining_aph < ahb_burst_length;

assign check_bndry_1k_crossed = (rx_eob_burst_crosses_1k | rx_eop_burst_crosses_1k | tx_eob_burst_crosses_1k) & hclk;


// Cover the case where the burst at the end of a buffer has an AHB error in it...
`ifdef edma_axi
wire [1:0] rx_hresp_err = 2'd0;
wire [1:0] tx_hresp_err = 2'd0;
`else
wire [1:0] rx_hresp_err = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.hresp;
wire [1:0] tx_hresp_err = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.hresp;
`endif

assign tx_eob_burst_has_err = tx_htrans[1] & tx_hresp_err != 2'h0 & ~tx_last_access_of_burst & tx_num_words_left_aph < ahb_burst_length;
assign rx_eob_burst_has_err = rx_htrans[1] & rx_hresp_err != 2'h0 & ~rx_last_access_of_burst & rx_buf_words_left_aph < ahb_burst_length;
assign rx_eop_burst_has_err = rx_htrans[1] & rx_hresp_err != 2'h0 & ~rx_last_access_of_burst & rx_words_remaining_aph < ahb_burst_length;



assign check_ahb_error_in_burst = (tx_eob_burst_has_err | rx_eob_burst_has_err | rx_eop_burst_has_err) & hclk;

`ifdef num_type2_screeners
// ----------------------------------------
// Screener matches
// Check that all active screener type 2 registers match at least once
`ifndef xgm
// Check that all active ethertype registers match at least once
   assign scr2_ethtype_match  = `hierarchy.i_gem_mac.i_gem_rx.scr2_ethtype_match[7:0];
   assign scr2_compare_match  = `hierarchy.i_gem_mac.i_gem_rx.scr2_compare_match[31:0];
   assign priority_queue_cp   = `hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.priority_queue;
   assign match_queue_type2  = {{100-`num_type2_screeners{1'b0}},`hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.match_queue_type2};
`else
   assign scr2_ethtype_match  = tb_xgm.i_xgm.i_xgm_rx.i_edma_pkt_decode.scr2_ethtype_match[7:0];
   assign scr2_compare_match  = tb_xgm.i_xgm.i_xgm_rx.i_edma_pkt_decode.scr2_compare_match[31:0];
   assign priority_queue_cp   = tb_xgm.i_xgm.i_xgm_rx.i_edma_pkt_decode.i_xgm_screener_top.priority_queue;
   assign match_queue_type2  = {{100-`num_type1_screeners{1'b0}},tb_xgm.i_xgm.i_xgm_rx.i_edma_pkt_decode.i_xgm_screener_top.match_queue_type2};
`endif
`else
   assign scr2_ethtype_match  = 8'h00;
   assign scr2_compare_match  = 32'd0;
   assign priority_queue_cp   = 3'b000;
   assign match_queue_type2  = {100{1'b0}};
`endif

`ifdef num_type1_screeners
`ifndef xgm
   assign match_queue_type1  = {{100-`num_type1_screeners{1'b0}},`hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.match_queue_type1};
`else
   assign match_queue_type1  = {{100-`num_type1_screeners{1'b0}},tb_xgm.i_xgm.i_xgm_rx.i_edma_pkt_decode.i_xgm_screener_top.match_queue_type1};
`endif
`else
   assign match_queue_type1  = {100{1'b0}};
`endif

// --------------------
// generic RX MAC stuff
// --------------------
// trigger point is when stats are updated. we can then get pkt lengths, etc to use in coverage.
// --
wire stats_valid;
`ifdef xgm
assign stats_valid         = tb_xgm.i_xgm.i_xgm_edma_wrapper.rx_w_eop;
wire [13:0] rx_pkt_length = tb_xgm.i_xgm.i_xgm_edma_wrapper.rx_w_stats_octets;
`else
wire pipeline_finished     = `hierarchy.i_gem_mac.i_gem_rx.pipeline_finished;
wire update_in_progress    = `hierarchy.i_gem_mac.i_gem_rx.update_in_progress;
wire update_finished       = `hierarchy.i_gem_mac.i_gem_rx.update_finished;
wire too_long              = `hierarchy.i_gem_mac.i_gem_rx.too_long;
wire rx_end_frame          = `hierarchy.i_gem_mac.i_gem_rx.rx_end_frame;
wire update_overflow       = `hierarchy.i_gem_mac.i_gem_rx.update_overflow;
wire [31:0] rx_pkt_length         = `hierarchy.i_gem_mac.i_gem_rx.rx_bytes_in_frame;
assign stats_valid         = ((pipeline_finished & ~((update_in_progress & ~too_long) |
                                            (rx_end_frame & too_long))) |
                                            (update_finished & update_overflow));
`endif

event          sample_rx_stats;
logic [31:0]   rx_consec_64byte_cnt    = 1;
logic [31:0]   rx_consec_65byte_cnt    = 1;
reg   [31:0]   last_rx_pkt_length;

// --
// Determine RX sampling event and also update consec counters
// --
always@(posedge mac_rx_clk)
  if (stats_valid)
    last_rx_pkt_length   <= rx_pkt_length;

initial begin
   forever begin
      @(negedge mac_rx_clk);
      if (stats_valid) begin
         // --
         // control for consecutive length counters
         // --
         if (rx_pkt_length == 64) begin
            rx_consec_64byte_cnt    += 1;
            rx_consec_65byte_cnt    = 0;
         end else if (rx_pkt_length == 65) begin
            rx_consec_64byte_cnt    = 0;
            rx_consec_65byte_cnt    += 1;
         end
         // --
         // trigger sampling
         // --
         ->sample_rx_stats;
      end
   end
end

covergroup rx_stats_cg @(sample_rx_stats);
   //NetworkControl_speed_cp:   coverpoint NetworkControl_speed {
         //bins speed_0            = {0};
         //bins speed_1            = {1};
   //}
   pkt_length_cp: coverpoint rx_pkt_length {
         bins pkt_short          = {[0:63]};
         bins pkt_64byte         = {64};
         bins pkt_65byte         = {65};
         bins pkt_small          = {[64:500]};
         bins pkt_med            = {[501:1000]};
         bins pkt_large          = {[1001:$]};
   }
   consec_64_65_pkts_cp: coverpoint rx_pkt_length {
         bins consec_64_65_byte  = {65} iff (last_rx_pkt_length == 64);
   }
   consec_65_64_pkts_cp: coverpoint rx_pkt_length {
         bins consec_65_64_byte  = {64} iff (last_rx_pkt_length == 65);
   }

   consec_64_pkts_cp: coverpoint rx_consec_64byte_cnt {
         bins consec_64byte[]          = {[1:4]} iff (rx_pkt_length==64);
   }

   consec_65_pkts_cp: coverpoint rx_consec_65byte_cnt {
         bins consec_65byte[]          = {[1:4]} iff (rx_pkt_length==65);
   }

   //pkt_kind_cp: coverpoint.......
   //rx_crc_strip_cp: coverpoint gem_misc_if.rx_crc_strip[0] {
         //bins Rx_CRC_No_Strip    = {0};
         //bins Rx_CRC_Strip       = {1};
   //}
   //tx_crc_add_cp: coverpoint gem_misc_if.tx_crc_add[0] {
         //bins Tx_CRC_No_Add      = {0};
         //bins Tx_CRC_Add         = {1};
   //}
endgroup
rx_stats_cg    i_rx_stats_cg     = new();

// --------------------
// generic RX MAC stuff
// --------------------
// trigger point is when stats are updated. we can then get pkt lengths, etc to use in coverage.
// --
logic [31:0]   tx_consec_64byte_cnt    = 1;
logic [31:0]   tx_consec_65byte_cnt    = 1;
reg   [31:0]   last_tx_pkt_length;
event          sample_tx_stats;
// --
// Determine RX sampling event and also update consec counters
// --
always@(posedge mac_tx_clk)
  if (tx_status)
    last_tx_pkt_length   = tx_pkt_length;

initial begin
   forever begin
      @(negedge mac_tx_clk);
      if (tx_status) begin
         // --
         // control for consecutive length counters
         // --
         if (tx_pkt_length == 64) begin
            tx_consec_64byte_cnt    += 1;
            tx_consec_65byte_cnt    = 0;
         end else if (tx_pkt_length == 65) begin
            tx_consec_64byte_cnt    = 0;
            tx_consec_65byte_cnt    += 1;
         end
         // --
         // trigger sampling
         // --
         ->sample_tx_stats;
      end
   end
end

covergroup tx_stats_cg @(sample_tx_stats);
   //NetworkControl_speed_cp:   coverpoint NetworkControl_speed {
         //bins speed_0            = {0};
         //bins speed_1            = {1};
   //}
   pkt_length_cp: coverpoint tx_pkt_length {
         bins pkt_short          = {[0:63]};
         bins pkt_64byte         = {64};
         bins pkt_65byte         = {65};
         bins pkt_small          = {[64:500]};
         bins pkt_med            = {[501:1000]};
         bins pkt_large          = {[1001:$]};
   }
   consec_64_65_pkts_cp: coverpoint tx_pkt_length {
         bins consec_64_65_byte  = {65} iff (last_tx_pkt_length == 64);
   }
   consec_65_64_pkts_cp: coverpoint tx_pkt_length {
         bins consec_65_64_byte  = {64} iff (last_tx_pkt_length == 65);
   }

   consec_64_pkts_cp: coverpoint tx_consec_64byte_cnt {
         bins consec_64byte[]          = {[1:7]} iff (tx_pkt_length==64);
   }

   consec_65_pkts_cp: coverpoint tx_consec_65byte_cnt {
         bins consec_65byte[]          = {[1:7]} iff (tx_pkt_length==65);
   }

   //pkt_kind_cp: coverpoint.......
   //tx_crc_strip_cp: coverpoint gem_misc_if.tx_crc_strip[0] {
         //bins Rx_CRC_No_Strip    = {0};
         //bins Rx_CRC_Strip       = {1};
   //}
   //tx_crc_add_cp: coverpoint gem_misc_if.tx_crc_add[0] {
         //bins Tx_CRC_No_Add      = {0};
         //bins Tx_CRC_Add         = {1};
   //}
endgroup
tx_stats_cg    i_tx_stats_cg     = new();




// This coverage point is to ensure we have tested all combinations of databus width, address bus
// width,  and descriptor timestamp insertion for AHB solutions
`ifdef edma_axi
  assign descriptor_endian_swap  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.endian_swap[0];
  assign tx_dma_state_is_man_rd  = 1'b0;
  assign tx_dma_state_is_man_wr  = 1'b0;
`else
  assign descriptor_endian_swap  = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.endian_swap[0];
  assign tx_dma_state_is_man_rd  = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.dma_state_man_rd;
  assign tx_dma_state_is_man_wr  = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.dma_state_man_wr;
`endif


`ifdef edma_axi
  assign tx_dma_state_man_rd      = 1'b0;
  assign tx_dma_state_man_wr      = 1'b0;
  assign rx_dma_state_man_wr      = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_wr;
  assign rx_dma_state_man_rd      = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_rd;
  assign tx_descr_rd_access       = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.arvalid_tx_descr &&
                                    `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.arready_tx_descr;

  assign tx_descr_wr_access       = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awvalid_tx_descr &&
                                    `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awready_tx_descr;

  reg [1:0] mreq_sm_cs;
  reg       tx_descr_rd_req_start;
  reg       tx_descr_rd_req_end;
  reg       tx_descr_rd_resp_end;

  assign mreq_sm_cs            = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.mreq_sm_cs;
  assign tx_descr_rd_req_start = tx_descr_rd_access && (mreq_sm_cs == 2'b01);
  assign tx_descr_rd_req_end   = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.descr_rd_req_end;
  assign tx_descr_rd_resp_end  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.descr_rd_resp_end;

  reg       last_tx_descr_rd;

  always @(posedge hclk)
  begin
    last_tx_descr_rd <= tx_descr_rd_resp_end;
  end

  assign tx_manrd_done  = last_tx_descr_rd;

  assign tx_manwr_done  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.wb_data_fifo_pop; // Always only 1 access for manwr

`else
  assign tx_descr_rd_access  = (|`hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.htrans_descr &
                                ~`hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.hwrite_descr &
                                 `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.hready);
  assign tx_descr_wr_access  = ((|`hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.htrans_descr) &
                                  `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.hwrite_descr &
                                  `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.hready);
  assign tx_dma_state_man_rd = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.dma_state_man_rd;
  assign rx_dma_state_man_wr = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_wr;
  assign rx_dma_state_man_rd = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_rd;
  assign tx_dma_state_man_wr = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.dma_state_man_wr;
  assign tx_manrd_done       = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.manrd_done & tx_dma_state_man_rd;
  assign tx_manwr_done       = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.manwr_done & tx_dma_state_man_wr;
`endif

assign data_width                 = `hierarchy.dma_bus_width;
assign addressing_64b_en          = `hierarchy.dma_addr_bus_width;
assign addressing_64b             = addressing_64b_en;
assign tx_ext_bd                  = `hierarchy.tx_bd_extended_mode_en;
assign rx_ext_bd                  = `hierarchy.rx_bd_extended_mode_en;
assign rx_enable                  = `hierarchy.enable_receive;
assign tx_enable                  = `hierarchy.enable_transmit;

// wires added for rx descr accesses
wire  rx_descr_rd_access;
wire  rx_descr_wr_access;
`ifdef edma_axi
  assign  rx_descr_rd_access  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.rx_descr_rd_req & `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.arvalid & `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.arready & `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.ar_grant_rx;
  assign  rx_descr_wr_access  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.rx_descr_wr_req & `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awvalid & `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awready & `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.aw_grant_rx[2];
`else
  assign  rx_descr_rd_access  = (|`hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.htrans_descr &
                                 ~`hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.hwrite_descr &
                                  `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.hready );

  assign  rx_descr_wr_access  = ((|`hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.htrans_descr) &
                                   `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.hwrite_descr &
                                   `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.hready );
`endif

// --
// New signals for SRAM coverage
// --
wire  [2:0]    spram_dma_state_pktinfo;
wire  [2:0]    spram_tx_ena;
wire  [2:0]    spram_128b_mode;
wire           dpram_pktinfo_wr;
wire  [`edma_tx_pbuf_data-1:0] spram_tx_data;
`ifdef edma_axi
assign    spram_dma_state_pktinfo       = 3'd0;  //*** TBD ****
assign    spram_tx_ena                  = 3'd0;  //*** TBD ****
assign    spram_128b_mode               = 3'd0;  //*** TBD ****
assign    dpram_pktinfo_wr              = 1'b0;
assign    spram_tx_data                 = {`edma_tx_pbuf_data{1'b0}};
`else
assign    spram_dma_state_pktinfo       = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.dma_state==3'b100 ? 1 : 0;
assign    spram_tx_ena                  = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.tx_ena_int;
assign    spram_128b_mode               = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.edma_tx_pbuf_data_w_is_128;
assign    dpram_pktinfo_wr              = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.dpram_pktinfo_wr;
assign    spram_tx_data                 = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.tx_dia;
`endif

reg [11:0]     spram_data_words;
reg [4:0]      spram_valid_last_bytes;
reg spram_ipv4;
reg spram_tcp_udp;
reg spram_sample_pkt;
reg [5:0]      spram_byte_mult;
reg [15:0]     spram_pkt_length;
reg [15:0]     last_spram_pkt_length;
event          sample_spram_pkts;
logic [1:0]    spram_pkt_type;
logic [1:0]    last_spram_pkt_type;
reg            spram_pkt_found;
logic [2:0]    spram_state_cnt;
logic [5:0]    spram_consec_64byte_cnt          = 1;
logic [5:0]    spram_consec_65byte_cnt          = 1;
logic [5:0]    spram_tcp_udp_consec_64byte_cnt  = 1;
logic [5:0]    spram_ipv4_consec_64byte_cnt     = 1;
logic [5:0]    spram_eth_consec_64byte_cnt      = 1;
logic [5:0]    spram_tcp_udp_consec_65byte_cnt  = 1;
logic [5:0]    spram_ipv4_consec_65byte_cnt     = 1;
logic [5:0]    spram_eth_consec_65byte_cnt      = 1;

// --
// Delay state by 1 cycle since we want to check the RTL reg's that are set by the state,
// hence 1 cycle before they drive new value
// --
always@(posedge hclk) begin
`ifdef edma_axi
   spram_state_cnt   <= 1'b0;
`else
   spram_state_cnt   <= `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.state_cnt;
`endif
end
initial begin
   spram_ipv4        = 0;
   spram_tcp_udp     = 0;
   spram_byte_mult   = 4;
   spram_sample_pkt  = 0;
   spram_pkt_found   = 0;
   spram_pkt_type          = 0;
   forever begin
      // --
      // sync to negedge hclk...guarantee signals are safe
      // then Check we have dpram_pktinfo_wr set
      // --
      @(negedge hclk);
      // --
      // Init our cover vars every clk cycle
      // --
      if (spram_dma_state_pktinfo)begin
         if (spram_128b_mode)
            spram_byte_mult   = 16;
         else
            spram_byte_mult   = 4;
         if (dpram_pktinfo_wr) begin
            if (spram_state_cnt == 3'b01) begin
               spram_data_words        = spram_tx_data[11:0];
               spram_valid_last_bytes  = spram_tx_data[15:12] == 4'h0 ? spram_byte_mult : spram_tx_data[15:12];
               if (spram_data_words > 0) begin
                  spram_sample_pkt  = 1;
                  spram_pkt_length  = ((spram_data_words-1)*spram_byte_mult) + spram_valid_last_bytes + 4;
               end else begin
                  spram_sample_pkt  = 0;
                  spram_pkt_length  = 0;
               end
            // --
            // IPV4 when state cnt = 3
            // --
            end else if (spram_state_cnt == 3'b011) begin
               if (spram_tx_ena && spram_data_words > 0) begin
                  spram_ipv4              = 1;
                  spram_pkt_type          = 1;
               end
            // --
            // TCP/UDP when state cnt = 4
            // --
            end else if (spram_state_cnt == 3'b100) begin
               if (spram_tx_ena && spram_data_words > 0) begin
                  spram_tcp_udp              = 1;
                  spram_pkt_type          = 2;
               end
            end
         end
      end
   end
end
// --
// Emit sampling event only if we have packet data
// --
initial begin
   forever begin
      @(negedge dpram_pktinfo_wr);
      if (spram_sample_pkt) begin
         // --
         // control for consecutive length counters
         // --
         spram_update_consec_cnts;
         ->sample_spram_pkts;
         @(posedge hclk);
         spram_sample_pkt  = 0;
         last_spram_pkt_length   = spram_pkt_length;
         last_spram_pkt_type     = spram_pkt_type;
         spram_pkt_type          = 0;
         spram_ipv4     = 0;
         spram_tcp_udp  = 0;
         spram_data_words  = 0;
      end
   end
end

task spram_update_consec_cnts;
   case (spram_pkt_type)
      0  :  begin //ETHERNET
               if (spram_pkt_length == 64) begin
                  spram_consec_64byte_cnt       += 1;
                  spram_eth_consec_64byte_cnt   +=1;
                  spram_consec_65byte_cnt       = 0;
               end else if (spram_pkt_length == 65) begin
                  spram_consec_65byte_cnt       += 1;
                  spram_eth_consec_65byte_cnt   +=1;
                  spram_consec_64byte_cnt       = 0;
               end
               spram_ipv4_consec_64byte_cnt     = 0;
               spram_tcp_udp_consec_64byte_cnt  = 0;
               spram_ipv4_consec_65byte_cnt     = 0;
               spram_tcp_udp_consec_65byte_cnt  = 0;
            end
      1  :  begin //IPV4
               if (spram_pkt_length == 64) begin
                  spram_consec_64byte_cnt       += 1;
                  spram_ipv4_consec_64byte_cnt  +=1;
                  spram_consec_65byte_cnt       = 0;
               end else if (spram_pkt_length == 65) begin
                  spram_consec_65byte_cnt       += 1;
                  spram_ipv4_consec_65byte_cnt  +=1;
                  spram_consec_64byte_cnt       = 0;
               end
               spram_eth_consec_64byte_cnt     = 0;
               spram_tcp_udp_consec_64byte_cnt = 0;
               spram_eth_consec_65byte_cnt     = 0;
               spram_tcp_udp_consec_65byte_cnt = 0;
            end
      0  :  begin //TCP_UDP
               if (spram_pkt_length == 64) begin
                  spram_consec_64byte_cnt       += 1;
                  spram_tcp_udp_consec_64byte_cnt   +=1;
                  spram_consec_65byte_cnt       = 0;
               end else if (spram_pkt_length == 65) begin
                  spram_consec_65byte_cnt       += 1;
                  spram_tcp_udp_consec_65byte_cnt   +=1;
                  spram_consec_64byte_cnt       = 0;
               end
               spram_ipv4_consec_64byte_cnt     = 0;
               spram_eth_consec_64byte_cnt      = 0;
               spram_ipv4_consec_65byte_cnt     = 0;
               spram_eth_consec_65byte_cnt      = 0;
            end
   endcase
endtask
// --
// new covergroup for SPRAM packet sizes
// --
covergroup spram_pkts_cg @(sample_spram_pkts);
   pkt_length_cp: coverpoint spram_pkt_length {
         bins pkt_short          = {[0:63]};
         bins pkt_64byte         = {64};
         bins pkt_65byte         = {65};
         bins pkt_small          = {[64:500]};
         bins pkt_med            = {[501:1000]};
         bins pkt_large          = {[1001:$]};
   }
   pkt_type: coverpoint spram_pkt_type {
         bins other_ethernet     = {0};
         bins ipv4               = {1};
         bins tcp_udp            = {2};
   }
   pkt_type_and_length_cx: cross pkt_type, pkt_length_cp {
      bins ethernet_64_65  = (binsof(pkt_length_cp.pkt_64byte) || binsof (pkt_length_cp.pkt_65byte)) && binsof(pkt_type.other_ethernet);
      bins ethernet_short  = binsof(pkt_length_cp.pkt_short)   && binsof(pkt_type.other_ethernet);
      bins ethernet_small  = binsof(pkt_length_cp.pkt_small)   && binsof(pkt_type.other_ethernet);
      bins ethernet_med    = binsof(pkt_length_cp.pkt_med)     && binsof(pkt_type.other_ethernet);
      bins ethernet_large  = binsof(pkt_length_cp.pkt_large)   && binsof(pkt_type.other_ethernet);
      bins ipv4_64_65      = (binsof(pkt_length_cp.pkt_64byte) || binsof (pkt_length_cp.pkt_65byte)) && binsof(pkt_type.ipv4);
      bins ipv4_short      = binsof(pkt_length_cp.pkt_short)   && binsof(pkt_type.ipv4);
      bins ipv4_med        = binsof(pkt_length_cp.pkt_med)     && binsof(pkt_type.ipv4);
      bins ipv4_small      = binsof(pkt_length_cp.pkt_small)   && binsof(pkt_type.ipv4);
      bins ipv4_large      = binsof(pkt_length_cp.pkt_large)   && binsof(pkt_type.ipv4);
      bins tcp_udp_64_65   = (binsof(pkt_length_cp.pkt_64byte) || binsof (pkt_length_cp.pkt_65byte)) && binsof(pkt_type.tcp_udp);
      bins tcp_udp_short   = binsof(pkt_length_cp.pkt_short)   && binsof(pkt_type.tcp_udp);
      bins tcp_udp_med     = binsof(pkt_length_cp.pkt_med)     && binsof(pkt_type.tcp_udp);
      bins tcp_udp_small   = binsof(pkt_length_cp.pkt_small)   && binsof(pkt_type.tcp_udp);
      bins tcp_udp_large   = binsof(pkt_length_cp.pkt_large)   && binsof(pkt_type.tcp_udp);
   }
   consec_64_65_pkts_cp: coverpoint spram_pkt_length {
         bins consec_64_65_byte  = {65} iff (last_spram_pkt_length == 64);
   }
   consec_65_64_pkts_cp: coverpoint spram_pkt_length {
         bins consec_65_64_byte  = {64} iff (last_spram_pkt_length == 65);
   }

   consec_64_pkts_cp: coverpoint spram_consec_64byte_cnt {
         bins consec_64byte[]          = {[1:7]} iff (spram_pkt_length==64);
   }

   consec_ipv4_64_pkts_cp: coverpoint spram_ipv4_consec_65byte_cnt {
         bins consec_64byte[]          = {[1:7]} iff (spram_pkt_length==64 && spram_pkt_type==1);
   }

   consec_tcp_udp_64_pkts_cp: coverpoint spram_tcp_udp_consec_65byte_cnt {
         bins consec_64byte[]          = {[1:7]} iff (spram_pkt_length==64 && spram_pkt_type==2);
   }

   consec_65_pkts_cp: coverpoint spram_consec_65byte_cnt {
         bins consec_65byte[]          = {[1:7]} iff (spram_pkt_length==65);
   }

   consec_ipv4_65_pkts_cp: coverpoint spram_ipv4_consec_65byte_cnt {
         bins consec_65byte[]          = {[1:7]} iff (spram_pkt_length==65 && spram_pkt_type==1);
   }

   consec_tcp_udp_65_pkts_cp: coverpoint spram_tcp_udp_consec_65byte_cnt {
         bins consec_65byte[]          = {[1:7]} iff (spram_pkt_length==65 && spram_pkt_type==2);
   }

endgroup
spram_pkts_cg    i_spram_pkts_cg     = new();



`ifndef gem_ext_fifo_interface
`ifdef dma_priority_queue1
    wire [2:0] tx_ahb_queue_rph;
  `ifdef edma_axi
    assign tx_ahb_queue_rph      = 3'd0;
  `else
    assign tx_ahb_queue_rph      = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.queue_ptr_rph;
  `endif
    assign priority_queue        = 1'b1;
`else
    wire [2:0] tx_ahb_queue_rph = 3'b000;
    assign  priority_queue      = 1'b0;
`endif
`else
    wire [2:0] tx_ahb_queue_rph = 3'b000;
    assign  priority_queue      = 1'b0;
`endif

`ifdef edma_axi

  reg  [1:0] tx_descr_access_cnt;

  initial
  begin
    tx_descr_access_cnt       = 0;
    last_tx_descr_access_cnt  = 0;

    tx_descr_access_cnt_wr = 0;
    descr_access           = 0;
  end

  always @(posedge hclk)
  begin
    last_tx_descr_access_cnt_wr  <= tx_descr_access_cnt_wr;
    tx_manwr_done_d1             <= tx_manwr_done;
    descr_access                 <= tx_dma_state_man_wr || tx_dma_state_man_rd || rx_dma_state_man_wr || rx_dma_state_man_rd;

    if (~tx_enable)
    begin
      tx_descr_access_cnt   <= 0;
      last_tx_descr_access_cnt <= 0;
      if (tx_descr_rd_access)
        tx_descr_no_check <= 1;
    end
    else
    begin
      if (tx_descr_rd_req_start)
        tx_descr_access_cnt <= 1;
      else
        if (tx_descr_rd_access)
          tx_descr_access_cnt <= tx_descr_access_cnt + 1;

      if (tx_descr_rd_req_end)
      begin
        tx_descr_no_check <= 0;
        if (tx_descr_rd_req_start)
          last_tx_descr_access_cnt <= 1;
        else
          last_tx_descr_access_cnt <= tx_descr_access_cnt + 1;
      end


      if (tx_manwr_done)
        tx_descr_access_cnt_wr <= 0;
      else
        if (tx_descr_wr_access)
          tx_descr_access_cnt_wr <= tx_descr_access_cnt_wr + 1;

    end

  end


`else
  bit  [1:0] tx_descr_access_cnt;

  initial
  begin
    tx_descr_access_cnt    = 0;
    tx_descr_access_cnt_wr = 0;
    descr_access           = 0;
  end

  always @(posedge hclk)
  begin
    last_tx_dma_state_is_man_rd  <= tx_dma_state_is_man_rd;
    last_tx_dma_state_is_man_wr  <= tx_dma_state_is_man_wr;
    last_tx_descr_access_cnt     <= tx_descr_access_cnt;
    last_tx_descr_access_cnt_wr  <= tx_descr_access_cnt_wr;
    descr_access                 <= tx_dma_state_man_wr || tx_dma_state_man_rd || rx_dma_state_man_wr || rx_dma_state_man_rd;
    tx_manwr_done_d1             <= tx_manwr_done;
    if (tx_dma_state_is_man_rd)
    begin
      if (hready)
      begin
        tx_ahb_queue_aph <= tx_ahb_queue_rph;
        if (tx_descr_rd_access)
        begin
          tx_ahb_queue_aph_last   <= tx_ahb_queue_aph;
          if (tx_descr_access_cnt == 0 | (tx_ahb_queue_aph == tx_ahb_queue_aph_last))
            tx_descr_access_cnt <= tx_descr_access_cnt + 1;
          else
            tx_descr_access_cnt <= 1;
        end
      end
    end
    else
    begin
      tx_descr_access_cnt <= 0;
      tx_ahb_queue_aph <= tx_ahb_queue_rph;
    end

    if (tx_manwr_done)
      tx_descr_access_cnt_wr <= 0;
    else
      if (tx_descr_wr_access)
        tx_descr_access_cnt_wr <= tx_descr_access_cnt_wr + 1;
  end

`endif


//rx descr


initial
begin
  rx_descr_access_cnt         = 0;
  rx_descr_access_cnt_wr      = 0;
  last_rx_descr_access_cnt      = 0;
  last_rx_descr_access_cnt_wr   = 0;
  rx_dma_state_man_rd_d1      = 0;
  rx_dma_state_man_wr_d1      = 0;
  rx_descr_access_cnt_end     = 0;
  rx_descr_access_cnt_wr_end  = 0;
end
always @(posedge hclk)
begin
   rx_dma_state_man_rd_d1    <= rx_dma_state_man_rd;
   rx_dma_state_man_wr_d1    <= rx_dma_state_man_wr;
   last_rx_descr_access_cnt      <= rx_descr_access_cnt;
   last_rx_descr_access_cnt_wr   <= rx_descr_access_cnt_wr;

  if (rx_dma_state_man_rd_end)
   rx_descr_access_cnt_end      <= last_rx_descr_access_cnt;

  if (rx_dma_state_man_wr_end)
   rx_descr_access_cnt_wr_end   <= last_rx_descr_access_cnt_wr;

  if (rx_descr_rd_access)
  begin
    if (rx_dma_state_man_rd_end)
      rx_descr_access_cnt    <= 1;
    else
      rx_descr_access_cnt    <= rx_descr_access_cnt + 1;
  end
  else if (rx_dma_state_man_rd_end)
    rx_descr_access_cnt    <= 0;

  if (rx_descr_wr_access)
  begin
    if (rx_dma_state_man_wr_end)
      rx_descr_access_cnt_wr    <= 1;
    else
      rx_descr_access_cnt_wr    <= rx_descr_access_cnt_wr + 1;
  end
  else if (rx_dma_state_man_wr_end)
    rx_descr_access_cnt_wr    <= 0;
end






// Trigger TX descriptor read checks on the exit from MAN_RD state
assign tx_descr_rd_check_trigger = tx_manrd_done;


// Rules for number of decsriptor accesses ...


`endif // of `ifdef edma_tx_pkt_buffer


//`ifdef edma_spram

   // --
   // SPRAM : used later for covergroups
   // --
   reg axi;
   `ifdef edma_axi
   initial axi=1'b1;
   `else
   initial axi=1'b0;
   `endif

   wire [2:0]  sel_ahb_freq;
   wire tx_clk_to_gem;
   wire tx_en;
   wire pclk_source;
   wire ethernet_int;
   `ifndef CDN_UVM
      assign sel_ahb_freq  = `top.i_tb_top.sel_ahb_freq;
      assign spram_divisor = `top.i_tb_top.spram_divisor;
      assign dma_bus_width = `top.i_tb_top.dma_bus_width;
      assign tx_clk_to_gem = `top.i_tb_top.tx_clk_to_gem;
      assign pclk_source   = `top.i_tb_top.pclk_source;
      assign ethernet_int  = `top.i_tb_top.ethernet_int;
      assign tx_en         = `top.i_tb_top.tx_en;
   `endif




//`endif



   // -----------------------------------------------------------------------------
   //
   //                               AXI Wrapper Coverage
   //
   // -----------------------------------------------------------------------------
// --
// GMORRIS UPDATE: Covergroups, wires/logc/etc, moved into  core module.
// Only actual assignments done within `ifdef
// --
  wire [3:0] ar2r_pipeline;
  wire [3:0] aw2w_pipeline;
  wire [3:0] w2b_pipeline;
  wire       tx_dma_descr_rd;
  reg  [3:0] num_tx_frames_pipelined;
  wire [3:0] tx_descr_rd_fill;
  wire [3:0] rx_descr_rd_fill;
  wire [3:0] tx_descr_wr_fill;
  wire [3:0] rx_descr_wr_fill;
  wire [3:0] q0_num_used_all;
  wire       tx_descr_rd_push;
  wire       rx_descr_rd_push;
  wire       tx_descr_wr_push;
  wire       rx_descr_wr_push;
  wire       tx_descr_rd_pop;
  wire       rx_descr_rd_pop;
  wire       tx_descr_wr_pop;
  wire       rx_descr_wr_pop;
  wire       tx_descr_rd_full;
  wire       rx_descr_rd_full;
  wire       tx_descr_wr_full;
  wire       rx_descr_wr_full;
  wire       all_data_for_txbuf_requested;
  wire [7:0] arlen;
  wire [7:0] awlen;
  wire       arvalid;
  wire [`edma_addr_width-1: 0]      araddr;
  wire       arready;
  wire       awvalid;
  wire [`edma_addr_width-1: 0]      awaddr;
  wire       awready;
  wire       rvalid;
  wire       rready;
  wire       rlast;
  wire       wvalid;
  wire       wready;
  wire       wlast;
  wire       bvalid;
  wire       bready;
  wire       test_finished;
  `ifndef CDN_UVM
     assign     test_finished       = `top.i_tb_top.all_done | `top.i_tb_top.end_trig;
  `endif
  wire [7:0] programmed_max_burst_len;
  logic [4:0] ar_latency_cnt_index,r_latency_cnt_index;
  logic [7:0] ar2r_latency_cnt [0:31];
  logic [7:0] last_ar2r_latency;
  logic [4:0] w_latency_cnt_index,b_latency_cnt_index;
  logic [7:0] w2b_latency_cnt [0:31];
  logic [7:0] last_w2b_latency;

  `ifdef edma_tx_pkt_buffer
    `ifdef edma_axi
    assign  ar2r_pipeline          = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.ar2r_pipeline_fill;
    assign  aw2w_pipeline          = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.aw2w_pipeline_fill;
    assign  w2b_pipeline           = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.w2b_pipeline_fill;
    assign  tx_descr_rd_fill       = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db2_fill_axi_q[0];
    assign  rx_descr_rd_fill       = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_reads[0].i_rx_descr_rd_fifo.qlevel;
    assign  tx_descr_wr_fill       = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.wb_int_fifo_fill;
    assign  rx_descr_wr_fill       = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.i_rx_descr_wr_dat_fifo.qlevel;
    assign  q0_num_used_all        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.q0_num_used_all;
    assign tx_descr_rd_push        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.i_tx_descr_sec_buff.push;
    assign rx_descr_rd_push        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_reads[0].i_rx_descr_rd_fifo.push;
    assign tx_descr_wr_push        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.i_tx_descr_wr_int_fifo.push;
    assign rx_descr_wr_push        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.i_rx_descr_wr_dat_fifo.push;
    assign tx_descr_rd_pop         = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.i_tx_descr_sec_buff.pop_2;  // DMA port
    assign rx_descr_rd_pop         = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_reads[0].i_rx_descr_rd_fifo.pop;
    assign tx_descr_wr_pop         = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.i_tx_descr_wr_int_fifo.pop;
    assign rx_descr_wr_pop         = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.i_rx_descr_wr_dat_fifo.pop;
    assign tx_descr_rd_full        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.i_tx_descr_sec_buff.qfull_2;
    assign rx_descr_rd_full        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_reads[0].i_rx_descr_rd_fifo.qfull;
    assign tx_descr_wr_full        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.i_tx_descr_wr_int_fifo.qfull;
    assign rx_descr_wr_full        = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.i_rx_descr_wr_add_fifo.qfull;
    assign all_data_for_txbuf_requested = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.all_data_for_txbuf_requested;
    assign  arlen                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.arlen;
    assign  awlen                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awlen;
    assign arvalid                 = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.arvalid;
    assign araddr                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.araddr;
    assign arready                 = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.arready;
    assign awvalid                 = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awvalid;
    assign awaddr                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awaddr;
    assign awready                 = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awready;
    assign rvalid                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.rvalid;
    assign rready                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.rready;
    assign rlast                   = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.rlast;
    assign wvalid                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.wvalid;
    assign wready                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.wready;
    assign wlast                   = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.wlast;
    assign bvalid                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.bvalid;
    assign bready                  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.bready;
    assign  programmed_max_burst_len = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.burst_length[4]   ? 8'd15 :
                                          `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.burst_length[3]   ? 8'd7 :
                                          `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.burst_length[2]   ? 8'd3 :8'd0;
    initial num_tx_frames_pipelined = 0;
    always @(posedge hclk)
    begin
      if (~last_tx_dma_state_is_man_wr & tx_dma_state_is_man_wr)
      begin
        if (~all_data_for_txbuf_requested)
          num_tx_frames_pipelined = num_tx_frames_pipelined - 1;
      end
      else if (all_data_for_txbuf_requested)
        num_tx_frames_pipelined = num_tx_frames_pipelined + 1;

    end

    initial
    begin
      ar_latency_cnt_index = 0;
      r_latency_cnt_index = 0;
      w_latency_cnt_index = 0;
      b_latency_cnt_index = 0;
      for (int int_i = 0;int_i<32;int_i=int_i+1)
      begin
        ar2r_latency_cnt[int_i] = 0;
        w2b_latency_cnt[int_i] = 0;
      end
    end

    always @(posedge hclk)
    begin
      if (arvalid & arready)
        ar_latency_cnt_index  <= ar_latency_cnt_index + 1;
      if (rvalid & rready & rlast)
        r_latency_cnt_index  <= r_latency_cnt_index + 1;

      for (int int_i = 0;int_i<32;int_i=int_i+1)
        if (ar2r_latency_cnt[int_i] != 0)
          ar2r_latency_cnt[int_i] <= ar2r_latency_cnt[int_i] + 1 ;
      if (rvalid & rready)
        ar2r_latency_cnt[r_latency_cnt_index] <= 0;
      if (arvalid & arready)
        ar2r_latency_cnt[ar_latency_cnt_index] <= 1;

      if (rvalid & rready & ar2r_latency_cnt[r_latency_cnt_index] != 0)
      begin
      // $display ("READ Latency was %0d",ar2r_latency_cnt[r_latency_cnt_index]);
        last_ar2r_latency <= ar2r_latency_cnt[r_latency_cnt_index];
      end

      if (wvalid & wready & wlast)
        w_latency_cnt_index  <= w_latency_cnt_index + 1;
      if (bvalid & bready)
        b_latency_cnt_index  <= b_latency_cnt_index + 1;

      for (int int_i = 0;int_i<32;int_i=int_i+1)
        if (w2b_latency_cnt[int_i] != 0)
          w2b_latency_cnt[int_i] <= w2b_latency_cnt[int_i] + 1 ;
      if (bvalid & bready)
        w2b_latency_cnt[b_latency_cnt_index] <= 0;
      if (wvalid & wready & wlast)
        w2b_latency_cnt[w_latency_cnt_index] <= 1;

      if (bvalid & bready)
      begin
      // $display ("WRITE Latency was %0d",w2b_latency_cnt[b_latency_cnt_index]);
        last_w2b_latency <= w2b_latency_cnt[b_latency_cnt_index];
      end
    end
    `endif
  `endif
// --
// GMORRIS: Covergroups outside `ifdef
// --


// -----------------------------------------------------------------------------
//
//                        SPRAM Specific Covergroup
//
// -----------------------------------------------------------------------------
covergroup cg_spram_system @(cg_spram_system_sample);
  cp_spram_amba_rate : coverpoint (spram_divisor)  {
    bins times1p8      = {18};
    bins times1p9      = {19};
    bins times2p0      = {20};
    bins times2p1to3p0 = {[21:30]};
    `ifndef xgm
    bins times3p1to4p5 = {[31:45]};
    bins times4p6to6p0 = {[46:60]};
    bins times6p1to8p0 = {[61:80]};
    `endif
  }

  cp_mac_rate : coverpoint ({ten_gig_mode,gigabit,speed})  {
    `ifndef xgm
    bins speed10m  = {0};
    bins speed100m = {1};
    bins speed1g   = {2};
    `else
    bins speed10g  = {4};
//    bins speed40g  = {8}; // Removing for now, as 40g mode is not fully designed to work with DMA yet
    `endif
  }

  cp_dma_bus_width : coverpoint (tb_top_dma_bus_width)  {
    bins dma_bus_width_32  = {0};
    bins dma_bus_width_64  = {1};
//    bins dma_bus_width_128 = {2};// 128bit SPRAM not supported
  }

  `ifndef xgm
  cp_amba_mode : coverpoint (axi_mode)  {
    bins ahb  = {0};
    bins axi  = {1};
  }

  `endif
  cp_spram_system_cross : cross cp_spram_amba_rate, cp_mac_rate, cp_dma_bus_width;

endgroup

cg_spram_system i_cg_spram_system = new();

// -----------------------------------------------------------------------------
//
//        64b Addressing and Extended Buffer Desriptor Specific Coverage
//
// -----------------------------------------------------------------------------
`ifdef edma_axi
assign descr_access_ahb = 1'b0;
assign descr_access_axi = descr_access;
`else
assign descr_access_axi = 1'b0;
assign descr_access_ahb = descr_access;
`endif

covergroup axi_descriptor_coverage @ (descr_access_axi);
  dma_data_width : coverpoint (data_width)  {
    bins data_width_is_32b   = {0};
    bins data_width_is_64b   = {1};
    bins data_width_is_128b  = {2};
  }
  dma_addr_width : coverpoint (addressing_64b)  {
    bins addr_width_is_32b   = {0};
    bins addr_width_is_64b   = {1};
  }
  dma_tx_ext_bd : coverpoint (tx_ext_bd)  {
    bins tx_ext_bd_off    = {0};
    bins tx_ext_bd_on     = {1};
  }
  dma_rx_ext_bd : coverpoint (rx_ext_bd)  {
    bins rx_ext_bd_off    = {0};
    bins rx_ext_bd_on     = {1};
  }
  dma_priority_queue : coverpoint (priority_queue)  {
    bins priority_queue_off    = {0};
    bins priority_queue_on     = {1};
  }
  cover_endian_swap : coverpoint (descriptor_endian_swap)  {}

  cross_tx_descriptor_access_type_axi : cross dma_data_width,dma_addr_width,dma_tx_ext_bd,dma_priority_queue;
  cross_rx_descriptor_access_type_axi : cross dma_data_width,dma_addr_width,dma_rx_ext_bd,dma_priority_queue;

endgroup
axi_descriptor_coverage axi_descriptor_coverage_i = new();

covergroup ahb_descriptor_coverage @ (descr_access_ahb);
  dma_data_width : coverpoint (data_width)  {
    bins data_width_is_32b   = {0};
    bins data_width_is_64b   = {1};
  }
  dma_addr_width : coverpoint (addressing_64b)  {
    bins addr_width_is_32b   = {0};
    bins addr_width_is_64b   = {1};
  }
  dma_tx_ext_bd : coverpoint (tx_ext_bd)  {
    bins tx_ext_bd_off    = {0};
    bins tx_ext_bd_on     = {1};
  }
  dma_rx_ext_bd : coverpoint (rx_ext_bd)  {
    bins rx_ext_bd_off    = {0};
    bins rx_ext_bd_on     = {1};
  }
  dma_priority_queue : coverpoint (priority_queue)  {
    bins priority_queue_off    = {0};
    bins priority_queue_on     = {1};
  }
  cover_endian_swap : coverpoint (descriptor_endian_swap)  {}

  cross_tx_descriptor_access_type_ahb : cross dma_data_width,dma_addr_width,dma_tx_ext_bd,dma_priority_queue;
  cross_rx_descriptor_access_type_ahb : cross dma_data_width,dma_addr_width,dma_rx_ext_bd,dma_priority_queue;

endgroup
ahb_descriptor_coverage ahb_descriptor_coverage_i = new();

covergroup tx_ext_bd_pending_manwr_coverage @ (tx_manwr_done);
  dma_data_width : coverpoint (data_width)  {
    bins data_width_is_32b   = {0};
    bins data_width_is_64b   = {1};
    bins data_width_is_128b  = {2};
  }
  dma_tx_ext_bd_on : coverpoint (tx_ext_bd)  {
    bins tx_ext_bd_on     = {1};
  }
  dma_tx_man_wr_multiple_on : coverpoint (man_wr_cnt_1_multiple)  {
    bins man_wr_cnt_1_multiple_on     = {1};
  }

  cross_tx_ext_bd_pending_manwr_ahb : cross dma_tx_ext_bd_on, dma_data_width, dma_tx_man_wr_multiple_on;

endgroup
tx_ext_bd_pending_manwr_coverage tx_ext_bd_pending_manwr_coverage_i = new();


covergroup ahb_error_in_burst @ (negedge check_ahb_error_in_burst);
  tx_eob_ahb_err : coverpoint (tx_pad_en & tx_eob_burst_has_err)  {
    bins zero   = {0};
    bins one    = {1};
  }
  rx_eob_ahb_err : coverpoint (rx_pad_en & rx_eob_burst_has_err) {
    bins zero   = {0};
    bins one    = {1};
  }
  rx_eop_ahb_err : coverpoint (rx_pad_en & rx_eop_burst_has_err) {
    bins zero   = {0};
    bins one    = {1};
  }
endgroup
ahb_error_in_burst ahb_error_in_burst_i = new();


covergroup bndry_1k_crossed @ (negedge check_bndry_1k_crossed);
  tx_eob_bndry_1k_crossed : coverpoint (tx_pad_en & tx_eob_burst_crosses_1k)  {
    bins zero   = {0};
    bins one    = {1};
  }
  rx_eob_bndry_1k_crossed : coverpoint (rx_pad_en & rx_eob_burst_crosses_1k) {
    bins zero   = {0};
    bins one    = {1};
  }
  rx_eop_bndry_1k_crossed : coverpoint (rx_pad_en & rx_eop_burst_crosses_1k) {
    bins zero   = {0};
    bins one    = {1};
  }
endgroup
bndry_1k_crossed bndry_1k_crossed_i = new();

covergroup screener1_matches @ (negedge hclk);
  screener1_match_regs : coverpoint (match_queue_type1[15:0])  {
    bins screener_reg0_matched   = {16'd1};
    bins screener_reg1_matched   = {16'd1 << 1};
    bins screener_reg2_matched   = {16'd1 << 2};
    bins screener_reg3_matched   = {16'd1 << 3};
    bins screener_reg4_matched   = {16'd1 << 4};
    bins screener_reg5_matched   = {16'd1 << 5};
    bins screener_reg6_matched   = {16'd1 << 6};
    bins screener_reg7_matched   = {16'd1 << 7};
    bins screener_reg8_matched   = {16'd1 << 8};
    bins screener_reg9_matched   = {16'd1 << 9};
    bins screener_reg10_matched  = {16'd1 << 10};
    bins screener_reg11_matched  = {16'd1 << 11};
    bins screener_reg12_matched  = {16'd1 << 12};
    bins screener_reg13_matched  = {16'd1 << 13};
    bins screener_reg14_matched  = {16'd1 << 14};
    bins screener_reg15_matched  = {16'd1 << 15};
  }
endgroup
screener1_matches screener1_matches_i = new();

covergroup screener2_matches @ (negedge hclk);
  screener2_match_regs : coverpoint (match_queue_type2[15:0])  {
    bins screener_reg0_matched   = {16'd1};
    bins screener_reg1_matched   = {16'd1 << 1};
    bins screener_reg2_matched   = {16'd1 << 2};
    bins screener_reg3_matched   = {16'd1 << 3};
    bins screener_reg4_matched   = {16'd1 << 4};
    bins screener_reg5_matched   = {16'd1 << 5};
    bins screener_reg6_matched   = {16'd1 << 6};
    bins screener_reg7_matched   = {16'd1 << 7};
    bins screener_reg8_matched   = {16'd1 << 8};
    bins screener_reg9_matched   = {16'd1 << 9};
    bins screener_reg10_matched  = {16'd1 << 10};
    bins screener_reg11_matched  = {16'd1 << 11};
    bins screener_reg12_matched  = {16'd1 << 12};
    bins screener_reg13_matched  = {16'd1 << 13};
    bins screener_reg14_matched  = {16'd1 << 14};
    bins screener_reg15_matched  = {16'd1 << 15};
  }
endgroup
screener2_matches screener2_matches_i = new();



covergroup queue_matches @ (negedge hclk);
  queue_matches : coverpoint (priority_queue_cp)  {
    bins queue0_selected   = {0};
    bins queue1_selected   = {1};
    bins queue2_selected   = {2};
  }
endgroup
queue_matches queue_matches_i = new();

covergroup comp_reg_matches @ (negedge hclk);
  compa_match_regs : coverpoint (scr2_compare_match[31:0])  {
    wildcard bins comp_reg0_matched   = {32'b???????????????????????????????1};
    wildcard bins comp_reg1_matched   = {32'b??????????????????????????????10};
    wildcard bins comp_reg2_matched   = {32'b?????????????????????????????100};
    wildcard bins comp_reg3_matched   = {32'b????????????????????????????1000};
    wildcard bins comp_reg4_matched   = {32'b???????????????????????????10000};
    wildcard bins comp_reg5_matched   = {32'b??????????????????????????100000};
    wildcard bins comp_reg6_matched   = {32'b?????????????????????????1000000};
    wildcard bins comp_reg7_matched   = {32'b????????????????????????10000000};
    wildcard bins comp_reg8_matched   = {32'b???????????????????????100000000};
    wildcard bins comp_reg9_matched   = {32'b??????????????????????1000000000};
    wildcard bins comp_reg10_matched  = {32'b?????????????????????10000000000};
    wildcard bins comp_reg11_matched  = {32'b????????????????????100000000000};
    wildcard bins comp_reg12_matched  = {32'b???????????????????1000000000000};
    wildcard bins comp_reg13_matched  = {32'b??????????????????10000000000000};
    wildcard bins comp_reg14_matched  = {32'b?????????????????100000000000000};
    wildcard bins comp_reg15_matched  = {32'b????????????????1000000000000000};
    wildcard bins comp_reg16_matched  = {32'b???????????????10000000000000000};
    wildcard bins comp_reg17_matched  = {32'b??????????????100000000000000000};
    wildcard bins comp_reg18_matched  = {32'b?????????????1000000000000000000};
    wildcard bins comp_reg19_matched  = {32'b????????????10000000000000000000};
    wildcard bins comp_reg20_matched  = {32'b???????????100000000000000000000};
    wildcard bins comp_reg21_matched  = {32'b??????????1000000000000000000000};
    wildcard bins comp_reg22_matched  = {32'b?????????10000000000000000000000};
    wildcard bins comp_reg23_matched  = {32'b????????100000000000000000000000};
    wildcard bins comp_reg24_matched  = {32'b???????1000000000000000000000000};
    wildcard bins comp_reg25_matched  = {32'b??????10000000000000000000000000};
    wildcard bins comp_reg26_matched  = {32'b?????100000000000000000000000000};
    wildcard bins comp_reg27_matched  = {32'b????1000000000000000000000000000};
    wildcard bins comp_reg28_matched  = {32'b???10000000000000000000000000000};
    wildcard bins comp_reg29_matched  = {32'b??100000000000000000000000000000};
    wildcard bins comp_reg30_matched  = {32'b?1000000000000000000000000000000};
    wildcard bins comp_reg31_matched  = {32'b10000000000000000000000000000000};
  }
endgroup
comp_reg_matches comp_reg_matches_i = new();
covergroup ethtype_matches @ (negedge hclk);
  ethtype_match_regs : coverpoint (scr2_ethtype_match)  {
    bins ethtype_reg0_matched   = {16'd1 << 0};
    bins ethtype_reg1_matched   = {16'd1 << 1};
    bins ethtype_reg2_matched   = {16'd1 << 2};
    bins ethtype_reg3_matched   = {16'd1 << 3};
    bins ethtype_reg4_matched   = {16'd1 << 4};
    bins ethtype_reg5_matched   = {16'd1 << 5};
    bins ethtype_reg6_matched   = {16'd1 << 6};
    bins ethtype_reg7_matched   = {16'd1 << 7};
  }
endgroup
ethtype_matches ethtype_matches_i = new();

assign pad_trigger = hclk & ((tx_pad_d1 & ~tx_pad) | (rx_pad_d1 & ~rx_pad));
covergroup ahb_force_pad_count @ (negedge pad_trigger);
  tx_pad_count : coverpoint tx_pad_cnt {
    bins zero   = {0};
    bins one    = {1};
    bins two    = {2};
    bins three  = {3};
    bins four   = {4};
    bins five   = {5};
    bins six    = {6};
    bins seven  = {7};
    bins eight  = {8};
    bins ninetofourteen  = {[9:14]};
    bins fifteen  = {15};
  }
  rx_pad_count : coverpoint rx_pad_cnt {
    bins zero   = {0};
    bins one    = {1};
    bins two    = {2};
    bins three  = {3};
    bins four   = {4};
    bins five   = {5};
    bins six    = {6};
    bins seven  = {7};
    bins eight  = {8};
    bins ninetofourteen  = {[9:14]};
    bins fifteen  = {15};
  }
endgroup
ahb_force_pad_count ahb_force_pad_count_i = new();

// Cover the number of pipelined accesses
covergroup axi_wrapper @ (negedge hclk);
 ar2r_pipeline       : coverpoint (ar2r_pipeline) {}
 aw2w_pipeline       : coverpoint (aw2w_pipeline) {}
 w2b_pipeline        : coverpoint (w2b_pipeline) {}
 axi_read_burst_len  : coverpoint (arlen) {
   bins one          = {0};
   bins four         = {3};
   bins eight        = {7};
   bins sixteen      = {15};
   bins anythingelse = {[1:2],[4:6],[8:14],[16:255]};
 }
 axi_write_burst_len : coverpoint (awlen) {
   bins one          = {0};
   bins four         = {3};
   bins eight        = {7};
   bins sixteen      = {15};
   bins anythingelse = {[1:2],[4:6],[8:14],[16:255]};
 }
 axi_num_TX_frames_pipelines : coverpoint (num_tx_frames_pipelined) {
   bins one          = {1};
   bins two          = {2};
   bins three        = {3};
   bins four         = {4};
   bins morethanfour = {[4:$]};
 }
 axi_num_RX_frames_pipelines : coverpoint (rx_descr_wr_fill) {
   bins one          = {1};
   bins two          = {2};
   bins three        = {3};
   bins four         = {4};
   bins morethanfour = {[4:$]};
 }
 axi_tx_descr_rd_push_and_pop  : coverpoint (tx_descr_rd_pop & tx_descr_rd_push) {}
 axi_rx_descr_rd_push_and_pop  : coverpoint (rx_descr_rd_pop & rx_descr_rd_push) {}
 axi_tx_descr_wr_push_and_pop  : coverpoint (tx_descr_wr_pop & tx_descr_wr_push) {}
 axi_rx_descr_wr_push_and_pop  : coverpoint (rx_descr_wr_pop & rx_descr_wr_push) {}
 axi_tx_descr_rd_fill          : coverpoint (tx_descr_rd_fill) {
   bins one           = {1};
   bins two_four      = {[2:4]};
   bins five_eight    = {[4:8]};
   bins morethaneight = {[9:$]};
 }
 axi_rx_descr_rd_fill          : coverpoint (rx_descr_rd_fill) {
   bins one           = {1};
   bins two_four      = {[2:4]};
   bins five_eight    = {[4:8]};
   bins morethaneight = {[9:$]};
 }
 axi_tx_descr_wr_fill          : coverpoint (tx_descr_wr_fill) {
   bins one           = {1};
   bins two_four      = {[2:4]};
   bins five_eight    = {[4:8]};
   bins morethaneight = {[9:$]};
 }
 axi_rx_descr_wr_fill          : coverpoint (rx_descr_wr_fill) {
   bins one           = {1};
   bins two_four      = {[2:4]};
   bins five_eight    = {[4:8]};
   bins morethaneight = {[9:$]};
 }
 axi_tx_descr_rd_got_full      : coverpoint (tx_descr_rd_full) {}
 axi_rx_descr_rd_got_full      : coverpoint (rx_descr_rd_full) {}
 axi_tx_descr_wr_got_full      : coverpoint (tx_descr_wr_full) {}
 axi_rx_descr_wr_got_full      : coverpoint (rx_descr_wr_full) {}
 axi_read_latency              : coverpoint (last_ar2r_latency) {
   bins one          = {1};
   bins two          = {2};
   bins three        = {3};
   bins four         = {4};
   bins to_15        = {[5:15]};
   bins to_31        = {[16:31]};
   bins to_63        = {[32:63]};
   bins to_127       = {[64:127]};
   bins more_than_128 = {[128:$]};
 }
 axi_write_latency             : coverpoint (last_w2b_latency) {
   bins one          = {1};
   bins two          = {2};
   bins three        = {3};
   bins four         = {4};
   bins to_15        = {[5:15]};
   bins to_31        = {[16:31]};
   bins to_63        = {[32:63]};
   bins to_127       = {[64:127]};
   bins more_than_128 = {[128:$]};
 }
endgroup
axi_wrapper axi_wrapper_i = new();

`endif

// -------------
// FIFO loopback
// -------------
// Main coverage and assertions will be aimed at 8B FIFO
// --
wire  fifo_if_tx_clk;
wire  fifo_if_rx_clk;
wire  fifo_if_latency_err;
wire  [3:0] fifo_if_tx_r_mod;
wire  fifo_8b_mode;
wire  rx_w_wr;

`ifdef gem_fifo_8b_if
  assign fifo_lpbk_mode      = `fifo_path.loopback;
  assign fifo_if_tx_clk      = `fifo_path.tx_clk;
  assign fifo_if_rx_clk      = `fifo_path.rx_clk;
  assign fifo_if_tx_r_mod    = `hierarchy.tx_r_mod;
  assign fifo_if_tx_eop      = `fifo_path.tx_r_eop;
  assign fifo_if_rx_eop      = `fifo_path.rx_w_eop;
  assign fifo_if_tx_sop      = `fifo_path.tx_r_sop;
  assign fifo_if_rx_sop      = `fifo_path.rx_w_sop;
  assign fifo_rx_w_wr        = `fifo_path.rx_w_wr;
`else
  assign fifo_lpbk_mode      = 1'b0;
  assign fifo_if_tx_clk      = 1'b0;
  assign fifo_if_rx_clk      = 1'b0;
  assign fifo_if_tx_r_mod    = 4'b0000;
  assign fifo_if_tx_eop      = 1'b0;
  assign fifo_if_rx_eop      = 1'b0;
  assign fifo_if_tx_sop      = 1'b0;
  assign fifo_if_rx_sop      = 1'b0;
  assign fifo_rx_w_wr        = 1'b0;

`endif

// --
// Only use certain assertions and coverage in 8b fifo mode and UVM sims
// --
`ifdef gem_fifo_8b_if
   `ifdef CDN_UVM
      assign fifo_8b_mode           = 1'b1;
      //assign fifo_8b_mode           = 1'b0; //DISABLE FOR NOW
      assign fifo_if_latency_err    = `fifo_path.tx_r_fixed_lat_err;
   `endif
`endif

// ----------------
// EOP then SOP
// --------------
// Some code to check for consecutive EOP->SOP
// --

// TX
reg fifo_tx_eop_valid, fifo_tx_eop_then_sop;
reg fifo_rx_eop_valid, fifo_rx_eop_then_sop;
initial begin
   fifo_tx_eop_valid    = 0;
   fifo_tx_eop_then_sop = 0;
   forever begin
      @(negedge fifo_if_tx_clk);
      if (fifo_if_tx_eop) begin
         fifo_tx_eop_valid = 1'b1;
      end else if (fifo_if_tx_sop) begin
            fifo_tx_eop_then_sop = fifo_tx_eop_valid;
            fifo_tx_eop_valid = 0;
      end else begin
         fifo_tx_eop_then_sop = 0;
         fifo_tx_eop_valid    = 0;
      end
   end
end
// RX
initial begin
   fifo_rx_eop_valid    = 0;
   fifo_rx_eop_then_sop = 0;
   forever begin
      @(negedge fifo_if_rx_clk);
      if (fifo_if_rx_eop) begin
         fifo_rx_eop_valid = 1'b1;
      end else if (fifo_if_rx_sop) begin
            fifo_rx_eop_then_sop = fifo_rx_eop_valid;
            fifo_rx_eop_valid = 0;
      end else begin
         fifo_rx_eop_then_sop = 0;
         fifo_rx_eop_valid    = 0;
      end
   end
end

`ifdef ABV_ON
  // -------------
  // PROPERTIES
  // -------------
  // Use propertes to also allow coverage for assertion
  // --
  // --
  // fifo_8b_rx_w_wr
  // --
  // Checks that after an EOP, the 8b fifo does not hold fifo_rx_w_wr high
  // unless an SOP is present
  // --
  property fifo_8b_rx_w_wr;
     @(posedge fifo_if_rx_clk) (fifo_8b_mode && fifo_if_rx_eop && fifo_rx_w_wr)
                                   |=> fifo_if_rx_sop? fifo_rx_w_wr==1 : fifo_rx_w_wr==0;
  endproperty

  // --
  // fifo_8b_lat_prop
  // --
  // Confirms that in fifo 8B mode, the fifo_if_latency_err is never high. This
  // is a signal from the FIFO loopback module that checks the latency from the
  // TX FIFO I/F to the TX ENET output is fixed.
  // --
  property fifo_8b_lat_prop;
     @(posedge fifo_if_tx_clk) fifo_8b_mode |-> fifo_if_latency_err == 1'b0;
  endproperty

  // --
  // assert/cover properties
  // --
  AP_fifo_8b_lat : assert property (fifo_8b_lat_prop);
  CP_fifo_8b_lat : cover property (fifo_8b_lat_prop);
  AP_fifo_8b_rx_w_wr : assert property (fifo_8b_rx_w_wr);
  CP_fifo_8b_rx_w_wr : cover property (fifo_8b_rx_w_wr);
`endif

// -------------------
// 8B FIFO Covergroups
// -------------------
// Bins are only activated when fifo_8b_mode is set though may expand
// in future for any FIFO modes
// --
covergroup fifo_tx_8b_cg @(fifo_if_tx_clk);
   tx_mod: coverpoint  fifo_if_tx_r_mod {
      bins mod_0              = {0} iff (fifo_8b_mode == 1'b1);
      bins mod_1              = {1} iff (fifo_8b_mode == 1'b1);
      bins mod_2              = {2} iff (fifo_8b_mode == 1'b1);
      bins mod_3              = {3} iff (fifo_8b_mode == 1'b1);
   }
   tx_eop_then_sop : coverpoint fifo_tx_eop_then_sop {
      bins consec_eop_sop     = {0} iff (fifo_8b_mode == 1'b1);
      bins non_consec_eop_sop = {1} iff (fifo_8b_mode == 1'b1);
   }
endgroup

covergroup fifo_rx_8b_cg @(fifo_if_rx_clk);
   rx_eop_then_sop : coverpoint fifo_rx_eop_then_sop {
      bins consec_eop_sop     = {0} iff (fifo_8b_mode == 1'b1);
      bins non_consec_eop_sop = {1} iff (fifo_8b_mode == 1'b1);
   }
endgroup

fifo_tx_8b_cg i_fifo_tx_8b_cg = new();
fifo_rx_8b_cg i_fifo_rx_8b_cg = new();

   // -----------------------------------------------------------------------------
   //
   //                   Prioity queue address bound checker
   //          (Ensures queues don't access addresses outwith their bounds)
   // -----------------------------------------------------------------------------

   `ifndef gem_ext_fifo_interface
   `ifdef dma_priority_queue1
  wire [`edma_queues-1:0] tx_disable_queue;
  wire [16:0] tx_disable_queue_pad;
  assign tx_disable_queue = `hierarchy.tx_disable_queue;
  assign tx_disable_queue_pad = {{(17-`edma_queues){1'b0}},tx_disable_queue};
      tb_queue_bound_checker i_tb_queue_bound_checker(
        .edma_tx_pbuf_num_segments_q0   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[2:0]),
        .edma_tx_pbuf_num_segments_q1   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[5:3]),
        .edma_tx_pbuf_num_segments_q2   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[8:6]),
        .edma_tx_pbuf_num_segments_q3   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[11:9]),
        .edma_tx_pbuf_num_segments_q4   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[14:12]),
        .edma_tx_pbuf_num_segments_q5   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[17:15]),
        .edma_tx_pbuf_num_segments_q6   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[20:18]),
        .edma_tx_pbuf_num_segments_q7   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[23:21]),
        .edma_tx_pbuf_num_segments_q8   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[26:24]),
        .edma_tx_pbuf_num_segments_q9   (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[29:27]),
        .edma_tx_pbuf_num_segments_q10  (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[32:30]),
        .edma_tx_pbuf_num_segments_q11  (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[35:33]),
        .edma_tx_pbuf_num_segments_q12  (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[38:36]),
        .edma_tx_pbuf_num_segments_q13  (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[41:39]),
        .edma_tx_pbuf_num_segments_q14  (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[44:42]),
        .edma_tx_pbuf_num_segments_q15  (`hierarchy.i_gem_reg_top.i_gem_registers.tx_pbuf_segments[47:45])
      );

   `endif
   `endif

`ifdef ABV_ON
  // 64b address bus width
  // Check that upper 32 address bits are 0 when 64b address bus width is set but 64b addressing is not enabled
  always @(posedge (wr_address_valid && (`edma_addr_width == 64) && ~addressing_64b_en))
    CHECK_ADDR_BUSS_MSB_IS_ZERO : assert ( wr_upper_address == 32'h00000000 );
  always @(posedge (rd_address_valid && (`edma_addr_width == 64) && ~addressing_64b_en))
    CHECK_RD_ADDR_BUSS_MSB_IS_ZERO : assert ( rd_upper_address == 32'h00000000 );
`endif

integer tx_descr_rd_cnt_32_32;
integer tx_descr_rd_cnt_64_32;
integer tx_descr_rd_cnt_128_32;
integer tx_descr_rd_cnt_32_64;
integer tx_descr_rd_cnt_64_64;
integer tx_descr_rd_cnt_128_64;
integer tx_descr_wr_cnt;

`ifdef edma_tx_pkt_buffer
  `ifdef edma_axi
  assign tx_descr_rd_cnt_32_32 = 2;
  assign tx_descr_rd_cnt_64_32 = 1;
  assign tx_descr_rd_cnt_128_32 = 1;
  assign tx_descr_rd_cnt_32_64 = 3;
  assign tx_descr_rd_cnt_64_64 = 2;
  assign tx_descr_rd_cnt_128_64 = 2;  // Always does two 64b accesses currently
  assign tx_descr_wr_cnt = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_writebacks_num;
  `else
  assign tx_descr_rd_cnt_32_32 = 2;
  assign tx_descr_rd_cnt_64_32 = 1;
  assign tx_descr_rd_cnt_128_32 = 1;
  assign tx_descr_rd_cnt_32_64 = 3;
  assign tx_descr_rd_cnt_64_64 = 2;
  assign tx_descr_rd_cnt_128_64 = 2;
  assign tx_descr_wr_cnt = tx_ext_bd ? 3 : 1;
  `endif
`endif

`ifdef ABV_ON
  // 32b addressing

//  // 32b datapath, 32b addressing = 2 accesses, both 32b
//  always @(negedge hclk)
//    if (tx_descr_rd_check_trigger & data_width == 2'b00 & ~addressing_64b & tx_enable & ~tx_descr_no_check)
//    CHECK_DB32_AB32_TX_DESCR_RD_NUM : assert ( last_tx_descr_access_cnt == tx_descr_rd_cnt_32_32 );
//
//  // 64b datapath, 32b addressing = 1 access
//  always @(negedge hclk)
//    if (tx_descr_rd_check_trigger & data_width == 2'b01 & ~addressing_64b & tx_enable & ~tx_descr_no_check)
//    CHECK_DB64_AB32_TX_DESCR_RD_NUM : assert ( last_tx_descr_access_cnt == tx_descr_rd_cnt_64_32 );
//
//  // 128b datapath, 32b addressing = 1 access
//  always @(negedge hclk)
//    if (tx_descr_rd_check_trigger & data_width[1] == 1'b1 & ~addressing_64b & tx_enable & ~tx_descr_no_check )
//    CHECK_DB128_AB32_TX_DESCR_RD_NUM : assert ( last_tx_descr_access_cnt == tx_descr_rd_cnt_128_32 );
//
//  // 64b addressing
//
//  // 32b datapath, 64b addressing = 3 accesses, both 32b
//  always @(negedge hclk)
//    if (tx_descr_rd_check_trigger & data_width == 2'b00 & addressing_64b & tx_enable & ~tx_descr_no_check)
//    CHECK_DB32_AB64_TX_DESCR_RD_NUM : assert ( last_tx_descr_access_cnt == tx_descr_rd_cnt_32_64 );
//
//  // 64b datapath, 64b addressing = 2 access
//  always @(negedge hclk)
//    if (tx_descr_rd_check_trigger & data_width == 2'b01 & addressing_64b & tx_enable & ~tx_descr_no_check)
//    CHECK_DB64_AB64_TX_DESCR_RD_NUM : assert ( last_tx_descr_access_cnt == tx_descr_rd_cnt_64_64 );
//
//  // 128b datapath, 64b addressing = 2 access
//  always @(negedge hclk)
//    if (tx_descr_rd_check_trigger & data_width[1] == 1'b1 & addressing_64b & tx_enable & ~tx_descr_no_check)
//    CHECK_DB128_AB64_TX_DESCR_RD_NUM : assert ( last_tx_descr_access_cnt == tx_descr_rd_cnt_128_64 );

`endif

// ////////////
//
// // Trigger TX descriptor read checks on the exit from MAN_WR state
`ifdef edma_axi
 assign tx_descr_wr_check_trigger = tx_manwr_done_d1;
`else
 assign tx_descr_wr_check_trigger = tx_manwr_done & ~tx_manwr_done_d1;
`endif

`ifdef ABV_ON
  // // EXT BD mode OFF

//  // 32b/64b/128b datapath, 32b/64b addressing. EXT BD mode OFF  = 1 accesses (32b)
//  // Allow 0 accesses to cover cases where descriptor writebacks do not issue any physical transactions
//  always @(negedge hclk)
//    if (tx_descr_wr_check_trigger & ~tx_ext_bd & tx_enable)
//    CHECK_EXT_BD_OFF_TX_DESCR_WR_NUM : assert ( tx_descr_access_cnt_wr == tx_descr_wr_cnt || tx_descr_access_cnt_wr == 0) ;
//
//  // 32b/64b/128b datapath, 32b/64b addressing. EXT BD mode ON  = 3 accesses in AHB (only uses 32b), or varying in AXI (more optimized)
//  // Allow 0 accesses to cover cases where descriptor writebacks do not issue any physical transactions
//  always @(negedge hclk)
//    if (tx_descr_wr_check_trigger & tx_ext_bd & tx_enable)
//    CHECK_EXT_BD_ON_TX_DESCR_WR_NUM : assert ( tx_descr_access_cnt_wr == 0 || tx_descr_access_cnt_wr == tx_descr_wr_cnt) ;
//

  // //////////////////
  // // RX DESCR CHECKS
  //
  // // rx descr reads are either 1 or 2 accesses  (2 when addr64 on , otherwise 1 )
  //
  // // 1 access
  // always @(posedge (rx_dma_state_man_rd_end & ~addressing_64b & ~axi_mode))
  //   CHECK_ONE_ACCESS_RX_DESCR_RD_NUM : assert ( last_rx_descr_access_cnt == 1 );
  //
  // // 2 access
  // always @(posedge (rx_dma_state_man_rd_end & addressing_64b & ~axi_mode))
  //   CHECK_TWO_ACCESS_RX_DESCR_RD_NUM : assert ( last_rx_descr_access_cnt == 2 );
  //
  // // rx descr write are either 1 2 or 4 accesses
  // // dma_bus_width       extended_bd_extended_mode_en                no_of_man_wr_accesses
  // //
  // //     128/64                       0                               one   64 bit access
  // //     128/64                       1                               two   64 bit accesses
  // //       32                         0                               two   32 bit accesses
  // //       32                         1                               four  32 bit accesses
  //

   always @(negedge hclk)
    if (rx_dma_state_man_wr_end & ~rx_ext_bd & |data_width & rx_enable & ~disable_asf_assertions)
     CHECK_ONE_ACCESS_RX_DESCR_WR_NUM : assert ( rx_descr_access_cnt_wr == 1 || rx_descr_access_cnt_wr == 0);

   always @(negedge hclk)
     if (rx_dma_state_man_wr_end & rx_ext_bd & |data_width & rx_enable & ~disable_asf_assertions)
     CHECK_TWO_ACCESS_RX_DESCR_WR_NUM : assert ( rx_descr_access_cnt_wr == 2 || rx_descr_access_cnt_wr == 0);

   always @(negedge hclk)
     if (rx_dma_state_man_wr_end & ~rx_ext_bd & (data_width == 2'b00) & rx_enable & ~disable_asf_assertions)
     CHECK_TWO_ACCESS_DB32_RX_DESCR_WR_NUM : assert ( rx_descr_access_cnt_wr == 2 || rx_descr_access_cnt_wr == 0);

   always @(negedge hclk)
     if (rx_dma_state_man_wr_end & rx_ext_bd & (data_width == 2'b00) & rx_enable & ~disable_asf_assertions)
     CHECK_FOUR_ACCESS_DB32_RX_DESCR_WR_NUM : assert ( rx_descr_access_cnt_wr == 4 || rx_descr_access_cnt_wr == 0);



  // check that the burst length never exceeds what it should be as per programmed burst length value
  always @(negedge (hclk))
    if (axi_valid && arvalid && arready)
    CHECK_AXI_AR_BURST_LEN : assert ( (arlen <= programmed_max_burst_len) || (programmed_max_burst_len == 8'h00));
  always @(negedge (hclk))
    if (axi_valid && awvalid && awready)
    CHECK_AXI_AW_BURST_LEN : assert ( (awlen <= programmed_max_burst_len) || (programmed_max_burst_len == 8'h00));

  // check that the descriptor buffers are empty at end of test ...
  always @(posedge (test_finished))
  begin
    #50;
    if (axi_valid) begin
       CHECK_AXI_TX_DESCR_RD_BUF_EMPTY : assert (tx_descr_rd_fill == 4'h0) else $error("\n****ERROR**** TX descriptor RD buffer in AXI wrapper wasnt empty at end of test\n");
       CHECK_AXI_TX_DESCR_WR_BUF_EMPTY : assert (tx_descr_wr_fill == 4'h0) else $error("\n****ERROR**** TX descriptor WR buffer in AXI wrapper wasnt empty at end of test\n");
  //     CHECK_AXI_RX_DESCR_RD_BUF_EMPTY : assert (rx_descr_rd_fill == 4'h0) else $error("\n****ERROR**** RX descriptor RD buffer in AXI wrapper wasnt empty at end of test\n");
       CHECK_AXI_RX_DESCR_WR_BUF_EMPTY : assert (rx_descr_wr_fill == 4'h0) else $error("\n****ERROR**** RX descriptor WR buffer in AXI wrapper wasnt empty at end of test\n");
       CHECK_AXI_USED_CNT_EMPTY : assert (q0_num_used_all == 4'h0) else $error("\n****ERROR**** Used bit across all queue counter in AXI wrapper wasnt empty at end of test\n");
     end
  end

`endif
// -----------------------------------------------------------------------------
//
//                        SPRAM linerate monitor
//
// --
// GMORRIS CHANGE 02/09/13: always instantiate linerate monitor
// else assertion will be lost in merge. I've update linerate monitor with
// a qualifying signal to ensure its only doing stuff in edma_spram mode.
// --
// -----------------------------------------------------------------------------

tb_spram_linerate_monitor tb_spram_linerate_monitor (

   .sel_ahb_freq(sel_ahb_freq),
   .gigabit(gigabit),
   .speed(speed),
   .tx_clk(tx_clk_to_gem),
   .tx_en(tx_en),
   .pclk(pclk_source),
   .ethernet_int(ethernet_int)

);

// -----------------------------------------------------------------------------
//
// Coverage Added for Specific Address Filter Enhancement
//
// -----------------------------------------------------------------------------
wire [31:0] num_spec_add_filters;
`ifdef num_spec_add_filters
  assign num_spec_add_filters = `num_spec_add_filters;
`else
  assign num_spec_add_filters = 0;
`endif

covergroup mac_rx_num_spec_add_filters @(posedge test_finished);
   cover_num_spec_add_filters : coverpoint num_spec_add_filters {
      bins four_or_less   = {[1:4]};
      bins more_than_four = {[4:$]};
   }
endgroup
mac_rx_num_spec_add_filters i_mac_rx_num_spec_add_filters = new();



//
// PFC pause multi quantum probed signals
//
wire       tx_pfc_pause_frame_txed ;
wire [7:0] pause_pfc_pri_vector    ;
wire [7:0] pause_pfc_zero_vector   ;
wire       pfc_multi_quantum_ctrl  ;
reg  [7:0] pause_pfc_pri_vector_capt   ;
reg  [7:0] pause_pfc_zero_vector_capt  ;
reg        pfc_multi_quantum_ctrl_capt ;

`ifdef xgm
  assign       tx_pfc_pause_frame_txed = tb_xgm.i_xgm.i_xgm_tx.i_pg.send_pfc;
  assign       pause_pfc_pri_vector    = tb_xgm.i_xgm.i_xgm_tx.i_pg.tx_pfc_pause_del;
  assign       pause_pfc_zero_vector   = tb_xgm.i_xgm.i_xgm_tx.i_pg.tx_pfc_pause_zero_del;
  `ifdef xgm_pfc_multi_quantum
  assign       pfc_multi_quantum_ctrl  = tb_xgm.i_xgm.i_xgm_cfg.pfc_ctrl;
  `else
  assign       pfc_multi_quantum_ctrl  = 1'b0;
  `endif

`else
  assign       tx_pfc_pause_frame_txed = `hierarchy.i_gem_mac.i_gem_tx_wrap.i_gem_tx.tx_pfc_pause_frame_txed;
  assign       pause_pfc_pri_vector    = `hierarchy.i_gem_mac.i_gem_tx_wrap.i_gem_tx.pause_pfc_pri_vector;
  assign       pause_pfc_zero_vector   = `hierarchy.i_gem_mac.i_gem_tx_wrap.i_gem_tx.pause_pfc_zero_vector;
  `ifdef gem_pfc_multi_quantum
  assign       pfc_multi_quantum_ctrl  = `hierarchy.i_gem_reg_top.i_gem_registers.pfc_ctrl;
  `else
  assign       pfc_multi_quantum_ctrl  = 1'b0;
  `endif
`endif

//
// Pause Priority 0
//
covergroup pfc_pri_and_time_p0 @ (tx_pfc_pause_frame_txed);
  pfc_control : coverpoint (pfc_multi_quantum_ctrl)  {
    bins pfc_ctrl_off   = {0};
    bins pfc_ctrl_on    = {1};
  }
  pfc_pri_p0 : coverpoint (pause_pfc_pri_vector[0])  {
    bins pause_pfc_pri_vector_off_p0   = {0};
    bins pause_pfc_pri_vector_on_p0    = {1};
  }
  pfc_zero_p0 : coverpoint (pause_pfc_zero_vector[0])  {
    bins pause_pfc_zero_vector_off_p0   = {0};
    bins pause_pfc_zero_vector_on_p0    = {1};
  }

  cross_pfc_p0 : cross pfc_control,pfc_pri_p0,pfc_zero_p0;

endgroup

// instance covergroup
pfc_pri_and_time_p0    i_pfc_pri_and_time_p0     = new();



//
// Pause Priority 1
//
covergroup pfc_pri_and_time_p1 @ (tx_pfc_pause_frame_txed);
  pfc_control : coverpoint (pfc_multi_quantum_ctrl)  {
    bins pfc_ctrl_off   = {0};
    bins pfc_ctrl_on    = {1};
  }
  pfc_pri_p1 : coverpoint (pause_pfc_pri_vector[1])  {
    bins pause_pfc_pri_vector_off_p1   = {0};
    bins pause_pfc_pri_vector_on_p1    = {1};
  }
  pfc_zero_p1 : coverpoint (pause_pfc_zero_vector[1])  {
    bins pause_pfc_zero_vector_off_p1   = {0};
    bins pause_pfc_zero_vector_on_p1    = {1};
  }

  cross_pfc_p1 : cross pfc_control,pfc_pri_p1,pfc_zero_p1;

endgroup

// instance covergroup
pfc_pri_and_time_p1    i_pfc_pri_and_time_p1     = new();



//
// Pause Priority 2
//
covergroup pfc_pri_and_time_p2 @ (tx_pfc_pause_frame_txed);
  pfc_control : coverpoint (pfc_multi_quantum_ctrl)  {
    bins pfc_ctrl_off   = {0};
    bins pfc_ctrl_on    = {1};
  }
  pfc_pri_p2 : coverpoint (pause_pfc_pri_vector[2])  {
    bins pause_pfc_pri_vector_off_p2   = {0};
    bins pause_pfc_pri_vector_on_p2    = {1};
  }
  pfc_zero_p2 : coverpoint (pause_pfc_zero_vector[2])  {
    bins pause_pfc_zero_vector_off_p2   = {0};
    bins pause_pfc_zero_vector_on_p2    = {1};
  }

  cross_pfc_p2 : cross pfc_control,pfc_pri_p2,pfc_zero_p2;

endgroup

// instance covergroup
pfc_pri_and_time_p2    i_pfc_pri_and_time_p2     = new();



//
// Pause Priority 3
//
covergroup pfc_pri_and_time_p3 @ (tx_pfc_pause_frame_txed);
  pfc_control : coverpoint (pfc_multi_quantum_ctrl)  {
    bins pfc_ctrl_off   = {0};
    bins pfc_ctrl_on    = {1};
  }
  pfc_pri_p3 : coverpoint (pause_pfc_pri_vector[3])  {
    bins pause_pfc_pri_vector_off_p3   = {0};
    bins pause_pfc_pri_vector_on_p3    = {1};
  }
  pfc_zero_p3 : coverpoint (pause_pfc_zero_vector[3])  {
    bins pause_pfc_zero_vector_off_p3   = {0};
    bins pause_pfc_zero_vector_on_p3    = {1};
  }

  cross_pfc_p3 : cross pfc_control,pfc_pri_p3,pfc_zero_p3;

endgroup

// instance covergroup
pfc_pri_and_time_p3    i_pfc_pri_and_time_p3     = new();



//
// Pause Priority 4
//
covergroup pfc_pri_and_time_p4 @ (tx_pfc_pause_frame_txed);
  pfc_control : coverpoint (pfc_multi_quantum_ctrl)  {
    bins pfc_ctrl_off   = {0};
    bins pfc_ctrl_on    = {1};
  }
  pfc_pri_p4 : coverpoint (pause_pfc_pri_vector[4])  {
    bins pause_pfc_pri_vector_off_p4   = {0};
    bins pause_pfc_pri_vector_on_p4    = {1};
  }
  pfc_zero_p4 : coverpoint (pause_pfc_zero_vector[4])  {
    bins pause_pfc_zero_vector_off_p4   = {0};
    bins pause_pfc_zero_vector_on_p4    = {1};
  }

  cross_pfc_p4 : cross pfc_control,pfc_pri_p4,pfc_zero_p4;

endgroup

// instance covergroup
pfc_pri_and_time_p4    i_pfc_pri_and_time_p4     = new();



//
// Pause Priority 5
//
covergroup pfc_pri_and_time_p5 @ (tx_pfc_pause_frame_txed);
  pfc_control : coverpoint (pfc_multi_quantum_ctrl)  {
    bins pfc_ctrl_off   = {0};
    bins pfc_ctrl_on    = {1};
  }
  pfc_pri_p5 : coverpoint (pause_pfc_pri_vector[5])  {
    bins pause_pfc_pri_vector_off_p5   = {0};
    bins pause_pfc_pri_vector_on_p5    = {1};
  }
  pfc_zero_p5 : coverpoint (pause_pfc_zero_vector[5])  {
    bins pause_pfc_zero_vector_off_p5   = {0};
    bins pause_pfc_zero_vector_on_p5    = {1};
  }

  cross_pfc_p5 : cross pfc_control,pfc_pri_p5,pfc_zero_p5;

endgroup

// instance covergroup
pfc_pri_and_time_p5    i_pfc_pri_and_time_p5     = new();



//
// Pause Priority 6
//
covergroup pfc_pri_and_time_p6 @ (tx_pfc_pause_frame_txed);
  pfc_control : coverpoint (pfc_multi_quantum_ctrl)  {
    bins pfc_ctrl_off   = {0};
    bins pfc_ctrl_on    = {1};
  }
  pfc_pri_p6 : coverpoint (pause_pfc_pri_vector[6])  {
    bins pause_pfc_pri_vector_off_p6   = {0};
    bins pause_pfc_pri_vector_on_p6    = {1};
  }
  pfc_zero_p6 : coverpoint (pause_pfc_zero_vector[6])  {
    bins pause_pfc_zero_vector_off_p6   = {0};
    bins pause_pfc_zero_vector_on_p6    = {1};
  }

  cross_pfc_p6 : cross pfc_control,pfc_pri_p6,pfc_zero_p6;

endgroup

// instance covergroup
pfc_pri_and_time_p6    i_pfc_pri_and_time_p6     = new();



//
// Pause Priority 7
//
covergroup pfc_pri_and_time_p7 @ (tx_pfc_pause_frame_txed);
  pfc_control : coverpoint (pfc_multi_quantum_ctrl)  {
    bins pfc_ctrl_off   = {0};
    bins pfc_ctrl_on    = {1};
  }
  pfc_pri_p7 : coverpoint (pause_pfc_pri_vector[7])  {
    bins pause_pfc_pri_vector_off_p7   = {0};
    bins pause_pfc_pri_vector_on_p7    = {1};
  }
  pfc_zero_p7 : coverpoint (pause_pfc_zero_vector[7])  {
    bins pause_pfc_zero_vector_off_p7   = {0};
    bins pause_pfc_zero_vector_on_p7    = {1};
  }

  cross_pfc_p7 : cross pfc_control,pfc_pri_p7,pfc_zero_p7;

endgroup

// instance covergroup
pfc_pri_and_time_p7    i_pfc_pri_and_time_p7     = new();






logic [15:0]  gatestate;
logic [18:0]  byte_count_q0;
logic         reschedule_now;

`ifdef edma_tx_pkt_buffer
  assign gatestate      = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.i_edma_tx_sched.gatestate;
  assign byte_count_q0  = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.i_edma_tx_sched.byte_count_arr[0];
  assign reschedule_now = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.i_edma_tx_sched.reschedule_now;
`else
  assign gatestate      = 0;
  assign byte_count_q0  = 0;
  assign reschedule_now = 0;
`endif

// Coverage of allowable byte count for Q0
covergroup cg_byte_count_q0 @(posedge reschedule_now);
  byte_count_q0 : coverpoint (byte_count_q0) {
    bins bin_0_1023     = {[0:1023]};
    bins bin_1024_2047  = {[1024:2047]};
    bins bin_2048_4095  = {[2048:4095]};
    bins bin_4096_8191  = {[4096:8191]};
    bins bin_8192_other = {[8192:$]};
  }
endgroup
cg_byte_count_q0  m_cg_byte_count_q0 = new();

// Coverage of the number of queues that can transmit due to gatestate
logic [4:0] num_queues_gate_en;
always@(*)
begin
  num_queues_gate_en = gatestate[0] + gatestate[1] + gatestate[2] + gatestate[3] +
                        gatestate[4] + gatestate[5] + gatestate[6] + gatestate[7] +
                        gatestate[8] + gatestate[9] + gatestate[10] + gatestate[11] +
                        gatestate[12] + gatestate[13] + gatestate[14] + gatestate[15];
end
covergroup cg_num_queues_gate_en @(posedge reschedule_now);
  num_queues  : coverpoint (num_queues_gate_en) {
    bins bin_1  = {1};
    bins bin_2_4  = {[2:4]};
    bins bin_5_8  = {[5:8]};
    bins bin_9_16 = {[9:16]};
  }
endgroup
cg_num_queues_gate_en m_cg_num_queues_gate_en = new();

// Check that the upper 32 bits of the address bus
// are all 0's when 64 bit physical address bus width
// but 64b addressing is not enabled in the DAM confog register

`ifdef edma_axi
`else
  `ifdef edma_tx_pkt_buffer
    assign haddr         = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.haddr;
    assign hbusreq       = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.hbusreq;
  `endif
`endif

parameter p_edma_addr_width = `edma_addr_width == 64 ;
wire  physical_addr_bus_width_is_64b;
assign  physical_addr_bus_width_is_64b  = p_edma_addr_width;
wire [64:0] araddr_pad;
assign araddr_pad = {{(65 - p_edma_addr_width){1'b0}},araddr};
wire [64:0] awaddr_pad;
assign awaddr_pad = {{(65 - p_edma_addr_width){1'b0}},awaddr};
wire [64:0] haddr_pad;
assign haddr_pad = {{(65 - p_edma_addr_width){1'b0}},haddr};

initial
begin
    wr_address_valid = 1'b0;
    rd_address_valid = 1'b0;
end

always @(*)
begin
  if (physical_addr_bus_width_is_64b == 1'b1)
  begin
    `ifdef edma_axi
    wr_address_valid = (awvalid & awready);
    rd_address_valid = (arvalid & arready);
    wr_upper_address = awaddr_pad[63:32];
    rd_upper_address = araddr_pad[63:32];
    `else
      `ifdef edma_tx_pkt_buffer
        wr_address_valid = hbusreq;
        wr_upper_address = haddr_pad[63:32];
        rd_address_valid = 1'b0;
        rd_upper_address = 32'h00000000;
      `else  // hold off when no pbuf dma in design
        wr_address_valid = 1'b0;
        wr_upper_address = 32'h00000000;
        rd_address_valid = 1'b0;
        rd_upper_address = 32'h00000000;
      `endif
    `endif
  end
  else  // hold off when address bus width is 32b
  begin
    wr_address_valid = 1'b0;
    wr_upper_address = 32'h00000000;
    rd_address_valid = 1'b0;
    rd_upper_address = 32'h00000000;
  end
end

//----------------------------------------------------------------------------//
//                               PCS Coverage                                 //
//----------------------------------------------------------------------------//
// - PCS setup, PCS Rx, PCS Tx                                                //
// - PCS Autonegotiation                                                      //
// - PCS Link Status Notification                                             //
// - PCS Link Fault Signaling (802.3bz/802.3cb support)                       //
//----------------------------------------------------------------------------//

// Define the hierarchy of the PCS for convenience
`ifndef hier_gem_pcs
  `define hier_gem_pcs          `hier_gem_top.i_gem_mii_bridge.GEN_PCS.i_gem_pcs
  `define hier_gem_pcs_rx_fault `hier_gem_pcs.i_pcs_rx.i_gem_pcs_rx_fault
`endif

//----------------------------------------------------------------------------
// Declare needed signals
//----------------------------------------------------------------------------

wire        mac_tx_enable;
wire        pcs_tbi;
wire [1:0]  pcs_if_type;
wire [3:0]  speed_mode;
wire        full_duplex;
wire        pcs_2_5g_mode;
wire [7:0]  pcs_tx_din;
wire        pcs_tx_cont;
wire        pcs_rx_err;
wire [7:0]  pcs_rx_din;
wire        pcs_rx_cont;
wire        gtx_clk;
wire        pcs_rx_clk;
wire [7:0]  gmii_txd;
wire        gmii_tx_en;
wire        gmii_tx_er;
wire        gmii_col;
wire [15:0] gmii_rxd;
wire [1:0]  gmii_rx_er;
wire [1:0]  gmii_rx_dv;

wire [7:0]  tb_rx_bit_slip;
wire        pcs_an_complete;
wire [1:0]  pcs_an_xmit;
wire [1:0]  pcs_rx_indicate;
wire        pcs_sgmii_lsn_complete;
wire [15:0] pcs_an_tx_abil;
wire [15:0] pcs_an_rx_abil;
wire [15:0] pcs_an_lp_sgmii_status;
wire [9:0]  pcs_rx_cal_select;
wire        pcs_rx_cg_align_sel_0_1;
wire        pcs_rx_cg_align_sel_1_0;
wire        pcs_tx_state_even;

wire        n_gtxreset;
wire        n_pcs_rxreset;
wire        pcs_rx_sync;
wire        pcs_rx_cg_align_sel;

reg         cg_pcs_setup_sample;
reg         cg_pcs_tx_sample;
reg         cg_pcs_rx_sample;
reg         pcs_rx_cg_align_sel_last;

// Link Fault Signaling (design probes)
wire        gem_pcs_rx_fault_en;
wire        gem_pcs_rx_fault_sync;
wire [15:0] gem_pcs_rx_fault_code;
wire [1:0]  gem_pcs_rx_fault_status;
wire [8:0]  gem_pcs_rx_fault_col_cnt;

// Link Fault Signaling (Rx model)
wire        lfsm_covmod_rx_w0;
wire        lfsm_covmod_rx_w1;
wire        lfsm_covmod_rx_w2;
wire        lfsm_covmod_rx_w3;
wire        lfsm_covmod_rx_q_det;
reg  [63:0] lfsm_covmod_rx_q_buffer;
reg  [1:0]  lfsm_covmod_rx_char_count;
reg  [1:0]  lfsm_covmod_rx_fault_type;
reg  [1:0]  lfsm_covmod_rx_fault_type_prev;
reg  [31:0] lfsm_covmod_rx_seq_cnt;
reg  [31:0] lfsm_covmod_rx_seq_cnt_prev;
reg  [31:0] lfsm_covmod_rx_half_col_cnt;
reg  [1:0]  lfsm_covmod_rx_fault_status_prev;

// Link Fault Signaling (Tx model)
wire [7:0]  lfsm_covmod_tx_group;
reg  [7:0]  lfsm_covmod_tx_group_prev;
wire        lfsm_covmod_tx_w0_0;
wire        lfsm_covmod_tx_w0_1;
wire        lfsm_covmod_tx_w1_0;
wire        lfsm_covmod_tx_w1_1;
wire        lfsm_covmod_tx_w2_0;
wire        lfsm_covmod_tx_w2_1;
wire        lfsm_covmod_tx_w3_0;
wire        lfsm_covmod_tx_w3_1;
wire        lfsm_covmod_tx_q_det;
wire        lfsm_covmod_tx_i1;
wire        lfsm_covmod_tx_i2;
wire        lfsm_covmod_tx_i_det;
reg  [63:0] lfsm_covmod_tx_q_buffer;
reg         lfsm_covmod_tx_8b_count;
reg  [1:0]  lfsm_covmod_tx_16b_count;

//----------------------------------------------------------------------------
// Connect needed signals
//----------------------------------------------------------------------------

assign mac_tx_enable = `hierarchy.i_gem_mac.enable_transmit;
assign gmii_tx_en    = `hierarchy.tx_en_pcs;
assign gmii_tx_er    = `hierarchy.tx_er_pcs;
assign gmii_txd      = `hierarchy.txd_pcs;
assign gmii_rxd      = `hierarchy.rxd_pcs;
assign gmii_rx_er    = `hierarchy.rx_er_pcs;
assign gmii_rx_dv    = `hierarchy.rx_dv_pcs;
assign gmii_col      = `hierarchy.col_pcs;
assign speed_mode    = `hierarchy.speed_mode;
assign full_duplex   = `hierarchy.full_duplex;
assign pcs_tbi       = speed_mode[2];

`ifdef CDN_UVM
  assign pcs_2_5g_mode = 1'b0;
`else
  assign pcs_2_5g_mode = `top.i_tb_top.tb_mode_2_5g;
`endif

`ifdef CDN_UVM
  assign tb_rx_bit_slip = 8'h00;
`else
  assign tb_rx_bit_slip = `top.i_tb_top.tb_rx_bit_slip;
`endif

`ifdef gem_no_pcs
  assign gtx_clk                        = 1'b0;
  assign pcs_rx_clk                     = 1'b0;

  assign pcs_if_type                    = 2'b00;

  assign pcs_tx_din                     = 8'h00;
  assign pcs_tx_cont                    = 1'b0;

  assign pcs_rx_err                     = 1'b0;
  assign pcs_rx_din                     = 8'h00;
  assign pcs_rx_cont                    = 1'b0;

  assign pcs_an_xmit                    = 2'b00;
  assign pcs_rx_indicate                = 2'b00;

  assign pcs_an_complete                = 1'b0;
  assign pcs_an_tx_abil                 = 16'h0000;
  assign pcs_an_rx_abil                 = 16'h0000;

  assign pcs_sgmii_lsn_complete         = 1'b0;
  assign pcs_an_lp_sgmii_status         = 16'h0000;

  assign pcs_rx_cal_select              = 10'h000;
  assign pcs_rx_cg_align_sel_0_1        = 1'b0;
  assign pcs_rx_cg_align_sel_1_0        = 1'b0;

  assign pcs_tx_state_even              = 1'b0;

  assign n_gtxreset                     = 1'b0;
  assign n_pcs_rxreset                  = 1'b0;
  assign pcs_rx_sync                    = 1'b0;
  assign pcs_rx_cg_align_sel            = 1'b0;

  // Link Fault Signaling
  assign gem_pcs_rx_fault_en            = 1'b0;
  assign gem_pcs_rx_fault_sync          = 1'b0;
  assign gem_pcs_rx_fault_code          = 16'h0000;
  assign gem_pcs_rx_fault_status        = 2'b00;
  assign gem_pcs_rx_col_cnt             = 9'h000;
`else
  assign gtx_clk                        = `hier_gem_top.gtx_clk;
  assign pcs_rx_clk                     = `hier_gem_top.pcs_rx_clk;
  assign n_gtxreset                     = `hier_gem_top.n_gtxreset;
  assign n_pcs_rxreset                  = `hier_gem_top.n_pcs_rxreset;
  assign pcs_rx_sync                    = `hier_gem_pcs.sync_status;

  assign pcs_tx_din                     = `hier_gem_pcs.i_pcs_tx.i_encoder.din;
  assign pcs_tx_cont                    = `hier_gem_pcs.i_pcs_tx.i_encoder.cont;
  assign pcs_rx_din                     = `hier_gem_pcs.i_pcs_rx.doutA;
  assign pcs_rx_cont                    = `hier_gem_pcs.i_pcs_rx.contA;
  assign pcs_rx_err                     = `hier_gem_pcs.i_pcs_rx.errA;

  assign pcs_an_complete                = `hier_gem_pcs.i_pcs_an.mr_an_complete;
  assign pcs_an_xmit                    = `hier_gem_pcs.xmit_s;
  assign pcs_rx_indicate                = `hier_gem_pcs.rx_indicate;

  assign pcs_an_tx_abil                 = `hier_gem_pcs.i_pcs_an.mr_adv_ability_int;
  assign pcs_an_rx_abil                 = `hier_gem_pcs.i_pcs_an.mr_lp_adv_ability;

  assign pcs_sgmii_lsn_complete         = `hier_gem_pcs.i_pcs_an.sgmii_mode & pcs_an_complete;
  assign pcs_an_lp_sgmii_status         = `hier_gem_pcs.i_pcs_an.mr_lp_adv_ability;

  assign pcs_tx_state_even              = `hier_gem_pcs.i_pcs_tx.i_txstate.tx_even;

  // Link Fault Signaling
  assign gem_pcs_rx_fault_en            = `hier_gem_pcs_rx_fault.link_fault_signal_en;
  assign gem_pcs_rx_fault_sync          = `hier_gem_pcs_rx_fault.sync_status;
  assign gem_pcs_rx_fault_code          = `hier_gem_pcs_rx_fault.rx_code;
  assign gem_pcs_rx_fault_status        = `hier_gem_pcs_rx_fault.link_fault_status;
  assign gem_pcs_rx_col_cnt             = `hier_gem_pcs_rx_fault.col_count;

  `ifdef gem_pcs_legacy_if
    assign pcs_rx_cal_select       = 10'h000;
    assign pcs_rx_cg_align_sel     = 1'b0;
  `else
    assign pcs_rx_cal_select       = `hier_gem_pcs.i_pcs_rx.GEN_RX_ALIGN.i_cal.cal_select;
    assign pcs_rx_cg_align_sel     = `hier_gem_pcs.i_pcs_rx.GEN_RX_ALIGN.i_cg_align.align_sel;
  `endif

  `ifdef gem_pcs_legacy_if
    assign pcs_if_type  = 2'b01;
  `else
    `ifdef gem_pcs_10b_if
      assign pcs_if_type  = 2'b10;
    `endif
    `ifdef gem_pcs_20b_if
      assign pcs_if_type  = 2'b11;
    `endif
  `endif

  // Setup is sampled when MAC TX is enabled with PCS selected.
  always @(posedge gtx_clk or negedge n_gtxreset)
  begin
    if (~n_gtxreset)
      cg_pcs_setup_sample <= 1'b0;
    else
      if (mac_tx_enable & pcs_tbi)
        cg_pcs_setup_sample <= 1'b1;
      else
        cg_pcs_setup_sample <= 1'b0;
  end

  // TX is sampled when MAC TX is enabled with PCS selected.
  always @(posedge gtx_clk or negedge n_gtxreset)
  begin
    if (~n_gtxreset)
      cg_pcs_tx_sample <= 1'b0;
    else
      if (tx_enable & pcs_tbi)
        cg_pcs_tx_sample <= ~cg_pcs_tx_sample;  // Sample every 2nd cycle
      else
        cg_pcs_tx_sample <= 1'b0;
  end

  // RX is sampled when PCS achieves sync.
  always @(posedge pcs_rx_clk or negedge n_pcs_rxreset)
  begin
    if (~n_pcs_rxreset)
    begin
      cg_pcs_rx_sample <= 1'b0;
      pcs_rx_cg_align_sel_last <= 1'b0;
    end
    else
    begin
      pcs_rx_cg_align_sel_last <= pcs_rx_cg_align_sel;
      if (pcs_rx_sync & pcs_tbi)
        cg_pcs_rx_sample <= ~cg_pcs_rx_sample;  // Sample every 2nd cycle
      else
        cg_pcs_rx_sample <= 1'b0;
    end
  end

  // Assign these signals here since we need to drive pcs_rx_cg_align_sel_last
  assign pcs_rx_cg_align_sel_0_1 = ~pcs_rx_cg_align_sel_last & pcs_rx_cg_align_sel;
  assign pcs_rx_cg_align_sel_1_0 = pcs_rx_cg_align_sel_last & ~pcs_rx_cg_align_sel;

//----------------------------------------------------------------------------
// Link Fault Signaling Rx Model
//----------------------------------------------------------------------------

  // Detect W0, W1, W2 and W3 of Rx Link Fault /Q/ ordered sets
  assign lfsm_covmod_rx_w0    = (gem_pcs_rx_fault_code == 16'h00bc) &&
                                (lfsm_covmod_rx_char_count == 2'h0);

  assign lfsm_covmod_rx_w1    = (gem_pcs_rx_fault_code == 16'hc0bc) &&
                                (lfsm_covmod_rx_char_count == 2'h1);

  assign lfsm_covmod_rx_w2    = ((gem_pcs_rx_fault_code == 16'hc0bc)  ||
                                 (gem_pcs_rx_fault_code == 16'hd0bc)  ||
                                 (gem_pcs_rx_fault_code == 16'he0bc)  ||
                                 (gem_pcs_rx_fault_code == 16'hf0bc)) &&
                                 (lfsm_covmod_rx_char_count == 2'h2);

  assign lfsm_covmod_rx_w3    = (gem_pcs_rx_fault_code == 16'h00bc) &&
                                (lfsm_covmod_rx_char_count == 2'h3);

  assign lfsm_covmod_rx_q_det = lfsm_covmod_rx_w0 ||
                                lfsm_covmod_rx_w1 ||
                                lfsm_covmod_rx_w2 ||
                                lfsm_covmod_rx_w3;

  // Hold the previous value of the link status
  always @(posedge pcs_rx_clk or negedge n_pcs_rxreset) begin
    if (~n_pcs_rxreset) begin
      lfsm_covmod_rx_fault_status_prev <= 2'b01;
    end else begin
      lfsm_covmod_rx_fault_status_prev <= gem_pcs_rx_fault_status;
    end
  end

  // Buffer an entire Rx Link Fault /Q/ ordered set
  always @(posedge pcs_rx_clk or negedge n_pcs_rxreset) begin
    if (~n_pcs_rxreset) begin
      lfsm_covmod_rx_char_count        <= 2'h0;
      lfsm_covmod_rx_q_buffer          <= 64'h00000000_00000000;
      lfsm_covmod_rx_fault_type        <= 2'b00;
      lfsm_covmod_rx_fault_type_prev   <= 2'b00;
    end else if (gem_pcs_rx_fault_sync) begin
      if (lfsm_covmod_rx_w0) begin
        lfsm_covmod_rx_char_count      <= lfsm_covmod_rx_char_count + 2'h1;
        lfsm_covmod_rx_q_buffer[15:0]  <= gem_pcs_rx_fault_code;
      end else if (lfsm_covmod_rx_w1) begin
        lfsm_covmod_rx_char_count      <= lfsm_covmod_rx_char_count + 2'h1;
        lfsm_covmod_rx_q_buffer[31:16] <= gem_pcs_rx_fault_code;
      end else if (lfsm_covmod_rx_w2) begin
        lfsm_covmod_rx_char_count      <= lfsm_covmod_rx_char_count + 2'h1;
        lfsm_covmod_rx_q_buffer[47:32] <= gem_pcs_rx_fault_code;
        lfsm_covmod_rx_fault_type_prev <= lfsm_covmod_rx_fault_type;
        if (gem_pcs_rx_fault_code == 16'hc0bc) begin
          lfsm_covmod_rx_fault_type    <= 2'b00;
        end else if (gem_pcs_rx_fault_code == 16'hd0bc) begin
          lfsm_covmod_rx_fault_type    <= 2'b01;
        end else if (gem_pcs_rx_fault_code == 16'he0bc) begin
          lfsm_covmod_rx_fault_type    <= 2'b10;
        end else if (gem_pcs_rx_fault_code == 16'hf0bc) begin
          lfsm_covmod_rx_fault_type    <= 2'b11;
        end
      end else if (lfsm_covmod_rx_w3) begin
        lfsm_covmod_rx_char_count      <= 2'h0;
        lfsm_covmod_rx_q_buffer[63:48] <= gem_pcs_rx_fault_code;
      end else begin
        lfsm_covmod_rx_char_count      <= 2'h0;
        lfsm_covmod_rx_q_buffer        <= 64'h00000000_00000000;
      end
    end
  end

  // Count Rx columns and Link Fault /Q/ ordered sets
  always @(posedge pcs_rx_clk or negedge n_pcs_rxreset) begin
    if (~n_pcs_rxreset) begin
      lfsm_covmod_rx_seq_cnt          <= 32'd0;
      lfsm_covmod_rx_half_col_cnt     <= 32'd0;
    end else begin
      lfsm_covmod_rx_seq_cnt_prev     <= lfsm_covmod_rx_seq_cnt;
      if (~gem_pcs_rx_fault_en) begin
        lfsm_covmod_rx_half_col_cnt   <= 32'd0;
      end else if (lfsm_covmod_rx_w3) begin
        lfsm_covmod_rx_half_col_cnt   <= 32'd0;
        if (lfsm_covmod_rx_fault_type_prev != lfsm_covmod_rx_fault_type) begin
          lfsm_covmod_rx_seq_cnt      <= 32'd1;
        end else begin
          lfsm_covmod_rx_seq_cnt      <= lfsm_covmod_rx_seq_cnt + 32'd1;
        end
      end else if (!lfsm_covmod_rx_q_det) begin
        if (lfsm_covmod_rx_half_col_cnt > 32'd255) begin
          lfsm_covmod_rx_seq_cnt      <= 32'd0;
          lfsm_covmod_rx_half_col_cnt <= 32'd0;
        end else begin
          lfsm_covmod_rx_half_col_cnt <= lfsm_covmod_rx_half_col_cnt + {30'd0, lfsm_covmod_rx_char_count} + 32'd1;
        end
      end
    end
  end

//----------------------------------------------------------------------------
// Link Fault Signaling Tx Model
//----------------------------------------------------------------------------

  // Hold current and previous values of pcs_tx_din
  assign lfsm_covmod_tx_group = pcs_tx_din;
  always @(posedge gtx_clk or negedge n_gtxreset) begin
    if (~n_gtxreset) begin
      lfsm_covmod_tx_group_prev <= 8'h00;
    end else begin
      lfsm_covmod_tx_group_prev <= lfsm_covmod_tx_group;
    end
  end

  // Detect W0, W1, W2 and W3 of Tx Remote Fault /Q/ ordered sets
  assign lfsm_covmod_tx_w0_0  = ((lfsm_covmod_tx_group_prev == 8'hbc  &&
                                  lfsm_covmod_tx_group      == 8'h00) &&
                                 (lfsm_covmod_tx_16b_count  == 2'h0   &&
                                  lfsm_covmod_tx_8b_count   == 1'b0 ));

  assign lfsm_covmod_tx_w0_1  = ((lfsm_covmod_tx_group_prev == 8'h00  &&
                                  lfsm_covmod_tx_group      == 8'hbc) &&
                                 (lfsm_covmod_tx_16b_count  == 2'h1   &&
                                  lfsm_covmod_tx_8b_count   == 1'b1 ));

  assign lfsm_covmod_tx_w1_0  = ((lfsm_covmod_tx_group_prev == 8'hbc  &&
                                  lfsm_covmod_tx_group      == 8'hc0) &&
                                 (lfsm_covmod_tx_16b_count  == 2'h1   &&
                                  lfsm_covmod_tx_8b_count   == 1'b0 ));

  assign lfsm_covmod_tx_w1_1  = ((lfsm_covmod_tx_group_prev == 8'hc0  &&
                                  lfsm_covmod_tx_group      == 8'hbc) &&
                                 (lfsm_covmod_tx_16b_count  == 2'h2   &&
                                  lfsm_covmod_tx_8b_count   == 1'b1 ));

  assign lfsm_covmod_tx_w2_0  = ((lfsm_covmod_tx_group_prev == 8'hbc  &&
                                  lfsm_covmod_tx_group      == 8'he0) &&
                                 (lfsm_covmod_tx_16b_count  == 2'h2   &&
                                  lfsm_covmod_tx_8b_count   == 1'b0 ));

  assign lfsm_covmod_tx_w2_1  = ((lfsm_covmod_tx_group_prev == 8'he0  &&
                                  lfsm_covmod_tx_group      == 8'hbc) &&
                                 (lfsm_covmod_tx_16b_count  == 2'h3   &&
                                  lfsm_covmod_tx_8b_count   == 1'b1 ));

  assign lfsm_covmod_tx_w3_0  = ((lfsm_covmod_tx_group_prev == 8'hbc  &&
                                  lfsm_covmod_tx_group      == 8'h00) &&
                                 (lfsm_covmod_tx_16b_count  == 2'h3   &&
                                  lfsm_covmod_tx_8b_count   == 1'b0 ));

  assign lfsm_covmod_tx_w3_1  = ((lfsm_covmod_tx_group_prev == 8'h00  &&
                                  lfsm_covmod_tx_group      == 8'hbc) &&
                                 (lfsm_covmod_tx_16b_count  == 2'h0   &&
                                  lfsm_covmod_tx_8b_count   == 1'b1 ));

  assign lfsm_covmod_tx_q_det = lfsm_covmod_tx_w0_0 ||
                                lfsm_covmod_tx_w1_0 ||
                                lfsm_covmod_tx_w2_0 ||
                                lfsm_covmod_tx_w3_0 ||
                                lfsm_covmod_tx_w0_1 ||
                                lfsm_covmod_tx_w1_1 ||
                                lfsm_covmod_tx_w2_1 ||
                                lfsm_covmod_tx_w3_1;

  // Detect IDLE (/I1/ or /I2/)
  assign lfsm_covmod_tx_i1    = (lfsm_covmod_tx_group_prev == 8'hbc  &&
                                 lfsm_covmod_tx_group      == 8'hc5) ||
                                (lfsm_covmod_tx_group_prev == 8'hc5  &&
                                 lfsm_covmod_tx_group      == 8'hbc);

  assign lfsm_covmod_tx_i2    = (lfsm_covmod_tx_group_prev == 8'hbc  &&
                                 lfsm_covmod_tx_group      == 8'h50) ||
                                (lfsm_covmod_tx_group_prev == 8'h50  &&
                                 lfsm_covmod_tx_group      == 8'hbc);

  assign lfsm_covmod_tx_i_det = lfsm_covmod_tx_i1 ||
                                lfsm_covmod_tx_i2;

  // Buffer Tx Link Fault /Q/ characters to check for an entire sequence value
  always @(posedge gtx_clk or negedge n_gtxreset) begin
    if (~n_gtxreset) begin
      lfsm_covmod_tx_8b_count          <= 1'b0;
      lfsm_covmod_tx_16b_count         <= 2'h0;
      lfsm_covmod_tx_q_buffer          <= 64'h00000000_00000000;
    end else begin
      if (lfsm_covmod_tx_w0_0) begin
        lfsm_covmod_tx_8b_count        <= 1'b1;
        lfsm_covmod_tx_16b_count       <= 2'h1;
      end else if (lfsm_covmod_tx_w0_1) begin
        lfsm_covmod_tx_8b_count        <= 1'b0;
        lfsm_covmod_tx_q_buffer[15:0]  <= {lfsm_covmod_tx_group, lfsm_covmod_tx_group_prev};
      end else if (lfsm_covmod_tx_w1_0) begin
        lfsm_covmod_tx_8b_count        <= 1'b1;
        lfsm_covmod_tx_16b_count       <= 2'h2;
      end else if (lfsm_covmod_tx_w1_1) begin
        lfsm_covmod_tx_8b_count        <= 1'b0;
        lfsm_covmod_tx_q_buffer[31:16] <= {lfsm_covmod_tx_group, lfsm_covmod_tx_group_prev};
      end else if (lfsm_covmod_tx_w2_0) begin
        lfsm_covmod_tx_8b_count        <= 1'b1;
        lfsm_covmod_tx_16b_count       <= 2'h3;
      end else if (lfsm_covmod_tx_w2_1) begin
        lfsm_covmod_tx_8b_count        <= 1'b0;
        lfsm_covmod_tx_q_buffer[47:32] <= {lfsm_covmod_tx_group, lfsm_covmod_tx_group_prev};
      end else if (lfsm_covmod_tx_w3_0) begin
        lfsm_covmod_tx_8b_count        <= 1'b1;
        lfsm_covmod_tx_16b_count       <= 2'h0;
      end else if (lfsm_covmod_tx_w3_1) begin
        lfsm_covmod_tx_8b_count        <= 1'b0;
        lfsm_covmod_tx_q_buffer[63:48] <= {lfsm_covmod_tx_group, lfsm_covmod_tx_group_prev};
      end else begin
        lfsm_covmod_tx_8b_count        <= 1'b0;
        lfsm_covmod_tx_16b_count       <= 2'h0;
        lfsm_covmod_tx_q_buffer        <= 64'h00000000_00000000;
      end
    end
  end
`endif // gem_no_pcs

//----------------------------------------------------------------------------
// Covergroups
//----------------------------------------------------------------------------

// PCS Setup
covergroup cg_pcs_setup @(posedge cg_pcs_setup_sample);
  cp_pcs_link_rate : coverpoint ({pcs_2_5g_mode}) {
    bins  speed_1g    = {0};
    bins  speed_2_5g  = {1};
  }
  cp_pcs_if_type : coverpoint ({pcs_if_type}) {
    bins  legacy      = {1};
    bins  srd_10b     = {2};
    bins  srd_20b     = {3};
  }
  cp_pcs_link_if_cross : cross cp_pcs_link_rate, cp_pcs_if_type;
  cp_pcs_speed_mode : coverpoint ({speed_mode}) {
    bins  sgmii_10m    = {4};
    bins  sgmii_100m   = {5};
    bins  sgmii_tbi_1g = {6};
  }
  cp_pcs_speed_mode_2p5g : coverpoint ({speed_mode}) {
    // TODO: better define what to cover as speed mode in 2.5G
    //bins sgmii_2p5g     = {10};
    bins sgmii_tbi_2p5g = {14};
  }
endgroup : cg_pcs_setup
cg_pcs_setup i_cg_pcs_setup = new();

// PCS Tx Enable
covergroup cg_pcs_tx_en @(posedge cg_pcs_tx_sample);
  cp_pcs_speed_mode : coverpoint ({speed_mode}) {
    bins  sgmii_10m   = {4};
    bins  sgmii_100m  = {5};
    bins  sgmii_tbi_1g= {6};
  }
  cp_pcs_speed_mode_2p5g : coverpoint ({speed_mode}) {
    // TODO: better define what to cover as speed mode in 2.5G
    //bins sgmii_2p5g     = {10};
    bins sgmii_tbi_2p5g = {14};
  }
  cp_pcs_duplex : coverpoint ({full_duplex});
  cp_pcs_speed_x_duplex  : cross cp_pcs_speed_mode, cp_pcs_duplex;
endgroup : cg_pcs_tx_en
cg_pcs_tx_en i_cg_pcs_tx_en = new();

// PCS Tx Functional
covergroup cg_pcs_tx @(posedge gtx_clk);
  // 8B10B Encode
  cp_pcs_enc_tx_data : coverpoint ({pcs_tx_din});
  cp_pcs_enc_tx_cont : coverpoint ({pcs_tx_cont,pcs_tx_din}) {
    bins  k28_5 = {9'h1bc};
    bins  k23_7 = {9'h1f7};
    bins  k27_7 = {9'h1fb};
    bins  k29_7 = {9'h1fd};
    bins  k30_7 = {9'h1fe};
  }
  cp_pcs_tx_lpi : coverpoint ({gmii_tx_en,gmii_tx_er,gmii_txd}) {
    bins  tx_lpi  = {10'h101};
  }
  cp_pcs_tx_align : coverpoint ({pcs_tx_state_even,gmii_tx_en}) {
    bins  odd   = {2'b01};
    bins  even  = {2'b11};
  }
  cp_pcs_col : coverpoint ({gmii_tx_en,gmii_col}) {
    bins  col   = {2'b11};
  }
  cp_pcs_xmit : coverpoint ({pcs_an_xmit}) {
    bins  cfg     = {2'b00};
    bins  idle    = {2'b01};
    bins  data    = {2'b11};
  }
endgroup : cg_pcs_tx
cg_pcs_tx i_cg_pcs_tx = new();

// PCS Rx Enable
covergroup cg_pcs_rx_en @(posedge cg_pcs_rx_sample);
  cp_pcs_speed_mode : coverpoint ({speed_mode}) {
    bins  sgmii_10m    = {4};
    bins  sgmii_100m   = {5};
    bins  sgmii_tbi_1g = {6};
  }
  cp_pcs_speed_mode_2p5g : coverpoint ({speed_mode}) {
    // TODO: better define what to cover as speed mode in 2.5G
    //bins sgmii_2p5g     = {10};
    bins sgmii_tbi_2p5g = {14};
  }
  cp_pcs_duplex : coverpoint ({full_duplex});
  cp_pcs_speed_x_duplex : cross cp_pcs_speed_mode, cp_pcs_duplex;
  cp_pcs_tb_rx_slip : coverpoint ({tb_rx_bit_slip}) {
    bins  slip_0  = {0};
    bins  slip_1  = {1};
    bins  slip_2  = {2};
    bins  slip_3  = {3};
    bins  slip_4  = {4};
    bins  slip_5  = {5};
    bins  slip_6  = {6};
    bins  slip_7  = {7};
    bins  slip_8  = {8};
    bins  slip_9  = {9};
    bins  slip_10 = {10};
    bins  slip_11 = {11};
    bins  slip_12 = {12};
    bins  slip_13 = {13};
    bins  slip_14 = {14};
    bins  slip_15 = {15};
    bins  slip_16 = {16};
    bins  slip_17 = {17};
    bins  slip_18 = {18};
    bins  slip_19 = {19};
  }
  cp_pcs_rx_cal_sel : coverpoint ({pcs_rx_cal_select}) {
    bins  sel_0   = {10'b0000000001};
    bins  sel_1   = {10'b0000000010};
    bins  sel_2   = {10'b0000000100};
    bins  sel_3   = {10'b0000001000};
    bins  sel_4   = {10'b0000010000};
    bins  sel_5   = {10'b0000100000};
    bins  sel_6   = {10'b0001000000};
    bins  sel_7   = {10'b0010000000};
    bins  sel_8   = {10'b0100000000};
    bins  sel_9   = {10'b1000000000};
  }
endgroup : cg_pcs_rx_en
cg_pcs_rx_en i_cg_pcs_rx_en = new();

// PCS Rx Functional
covergroup cg_pcs_rx @(posedge pcs_rx_clk);
  // 8B10B Decode
  cp_pcs_dec_rx_data : coverpoint ({pcs_rx_din});
  cp_pcs_dec_rx_cont : coverpoint ({pcs_rx_cont,pcs_rx_din}) {
    bins  k28_5 = {9'h1bc};
    bins  k23_7 = {9'h1f7};
    bins  k27_7 = {9'h1fb};
    bins  k29_7 = {9'h1fd};
    bins  k30_7 = {9'h1fe};
  }
  cp_pcs_dec_rx_err : coverpoint ({pcs_rx_err});
  cp_pcs_cg_align_0_1 : coverpoint ({pcs_rx_cg_align_sel_0_1}) {
    bins  align_0_1 = {1};
  }
  cp_pcs_cg_align_1_0 : coverpoint ({pcs_rx_cg_align_sel_1_0}) {
    bins  align_1_0 = {1};
  }
  cp_pcs_rx_lpi : coverpoint ({gmii_rx_dv,gmii_rx_er,gmii_rxd}) {
    bins  tx_lpi  = {20'h30101};
  }
  cp_pcs_rx_ind : coverpoint ({pcs_rx_indicate}) {
    bins  idle    = {2'b00};
    bins  invalid = {2'b01};
    bins  cfg     = {2'b11};
  }
endgroup : cg_pcs_rx
cg_pcs_rx i_cg_pcs_rx = new();

// PCS Autonegotiation
covergroup cg_pcs_an_done @(posedge pcs_an_complete);
  // AN Pause Resolution
  // Should match 37.2.4.3 of IEEE 802.3.
  // Note that [8] corresponds to ASM and [7] to PAUSE
  cp_pcs_an_pause_res : coverpoint ({pcs_an_tx_abil[8:7],pcs_an_rx_abil[8:7]}) {
    bins  local_asm   = {4'b1011};
    bins  remote_asm  = {4'b1110};
    bins  pause_on    = {4'b0101,4'b0111,4'b1101,4'b1111};
    bins  pause_off   = default;
  }
  // Duplex resolution
  cp_pcs_an_duplex_res : coverpoint ({pcs_an_tx_abil[6:5],pcs_an_rx_abil[6:5]}) {
    bins  full_duplex = {4'b0101,4'b1101,4'b0111,4'b1111};
    bins  half_duplex = {4'b1010};
    bins  illegal     = default;
  }
endgroup : cg_pcs_an_done
cg_pcs_an_done i_cg_pcs_an_done = new();

// PCS Link Status Notification
covergroup cg_pcs_lsn_done @(posedge pcs_sgmii_lsn_complete);
  // Link status notification:
  cp_pcs_lsn_status : coverpoint ({pcs_an_lp_sgmii_status[15]}) {
    bins  link_up   = {1};
    bins  link_down = {0};
  }
  cp_pcs_lsn_duplex : coverpoint ({pcs_an_lp_sgmii_status[12]}) {
    bins  full_duplex = {1};
    bins  half_duplex = {0};
  }
  cp_pcs_lsn_speed : coverpoint ({pcs_an_lp_sgmii_status[11:10]}) {
    bins  sp_1000   = {2};
    bins  sp_100    = {1};
    bins  sp_10     = {0};
  }
endgroup : cg_pcs_lsn_done
cg_pcs_lsn_done i_cg_pcs_lsn_done = new();

// PCS Link Fault Signaling (802.3bz/802.3cb)
covergroup cg_pcs_link_fault @(posedge pcs_rx_clk);
  cp_pcs_lfsm_enable : coverpoint gem_pcs_rx_fault_en {
    bins enabled           = {1} iff (pcs_rx_sync);
    bins disabled          = {0} iff (pcs_rx_sync);
  }
  cp_lfsm_link_fault_status : coverpoint gem_pcs_rx_fault_status {
    bins local_fault       = {1} iff (gem_pcs_rx_fault_en);
    bins remote_fault      = {2} iff (gem_pcs_rx_fault_en);
    bins link_interruption = {3} iff (gem_pcs_rx_fault_en);
  }
  cp_lfsm_rx_fault_codes : coverpoint lfsm_covmod_rx_q_buffer {
    //bins ok                = {64'h00bc_c0bc_c0bc_00bc} iff (gem_pcs_rx_fault_en);
    bins local_fault       = {64'h00bc_d0bc_c0bc_00bc} iff (gem_pcs_rx_fault_en);
    bins remote_fault      = {64'h00bc_e0bc_c0bc_00bc} iff (gem_pcs_rx_fault_en);
    bins link_interruption = {64'h00bc_f0bc_c0bc_00bc} iff (gem_pcs_rx_fault_en);
  }
endgroup : cg_pcs_link_fault
cg_pcs_link_fault i_cg_pcs_link_fault = new();

//----------------------------------------------------------------------------
// Assertions
//----------------------------------------------------------------------------

`ifdef ABV_ON
  parameter [7:0] MIN_GTX_CYCLES_TOLERANCE = 8'd10;
  parameter [7:0] MAX_GTX_CYCLES_TOLERANCE = 8'd20;

  // If the link status is Local Fault when the PCS gets synchronized, then the
  // link status shall change to OK.
  property check_status_ok_on_pcs_sync;
    @(posedge gem_pcs_rx_fault_sync)
      (gem_pcs_rx_fault_status == 2'b01)
    |->
    @(negedge pcs_rx_clk)
      ##1
        (gem_pcs_rx_fault_status != lfsm_covmod_rx_fault_status_prev) &&
        (gem_pcs_rx_fault_status == 2'b00);
  endproperty : check_status_ok_on_pcs_sync
  assert_check_status_ok_on_pcs_sync : assert property(check_status_ok_on_pcs_sync);

  // If the LFSM is enabled, a fault is received and the sequence count is less
  // than four, then the link status shall not change.
  property check_link_status_no_change_below_4faults;
    @(posedge pcs_rx_clk)
      gem_pcs_rx_fault_en &&
      lfsm_covmod_rx_w3
      ##1
        (lfsm_covmod_rx_seq_cnt < 32'd4)
    |->
    (gem_pcs_rx_fault_status == lfsm_covmod_rx_fault_status_prev);
  endproperty : check_link_status_no_change_below_4faults
  assert_check_link_status_no_change_below_4faults : assert property(check_link_status_no_change_below_4faults);

  // If the LFSM is enabled, a fault is received, the sequence count is equal
  // to four and the fault type is Local Fault, then the link status shall
  // change to Local Fault.
  property check_link_status_lf_on_4lfs;
    @(posedge pcs_rx_clk)
      gem_pcs_rx_fault_en &&
      lfsm_covmod_rx_w3
      ##1
        (lfsm_covmod_rx_fault_type == 2'b01) &&
        (lfsm_covmod_rx_seq_cnt == 32'd4)
    |->
    (gem_pcs_rx_fault_status != lfsm_covmod_rx_fault_status_prev) &&
    (gem_pcs_rx_fault_status == 2'b01);
  endproperty : check_link_status_lf_on_4lfs
  assert_check_link_status_lf_on_4lfs : assert property(check_link_status_lf_on_4lfs);

  // If the LFSM is enabled, a fault is received, the sequence count is equal
  // to four and the fault type is Remote Fault, then the link status shall
  // change to Remote Fault.
  property check_link_status_rf_on_4rfs;
    @(posedge pcs_rx_clk)
      gem_pcs_rx_fault_en &&
      lfsm_covmod_rx_w3
      ##1
        (lfsm_covmod_rx_fault_type == 2'b10) &&
        (lfsm_covmod_rx_seq_cnt == 32'd4)
    |->
    (gem_pcs_rx_fault_status != lfsm_covmod_rx_fault_status_prev) &&
    (gem_pcs_rx_fault_status == 2'b10);
  endproperty : check_link_status_rf_on_4rfs
  assert_check_link_status_rf_on_4rfs : assert property(check_link_status_rf_on_4rfs);

  // If the LFSM is enabled, a fault is received, the sequence count is equal
  // to four and the fault type is Link Interruption, then the link status shall
  // change to Link Interruption.
  property check_link_status_li_on_4lis;
    @(posedge pcs_rx_clk)
      gem_pcs_rx_fault_en &&
      lfsm_covmod_rx_w3
      ##1
        (lfsm_covmod_rx_fault_type == 2'b11) &&
        (lfsm_covmod_rx_seq_cnt == 32'd4)
    |->
    (gem_pcs_rx_fault_status != lfsm_covmod_rx_fault_status_prev) &&
    (gem_pcs_rx_fault_status == 2'b11);
  endproperty : check_link_status_li_on_4lis
  assert_check_link_status_li_on_4lis : assert property(check_link_status_li_on_4lis);

  // If the LFSM is enabled and the link status changes to Local Fault, then the
  // PCS shall start transmitting Remote Faults.
  property check_rf_txed_on_lf_rxed;
    @(posedge pcs_rx_clk)
      gem_pcs_rx_fault_en                                           &&
      (gem_pcs_rx_fault_status != lfsm_covmod_rx_fault_status_prev) &&
      (gem_pcs_rx_fault_status == 2'b01)
    |->
    @(posedge gtx_clk)
      ##[MIN_GTX_CYCLES_TOLERANCE:MAX_GTX_CYCLES_TOLERANCE]
        lfsm_covmod_tx_w3_1;
  endproperty : check_rf_txed_on_lf_rxed
  assert_check_rf_txed_on_lf_rxed : assert property(check_rf_txed_on_lf_rxed);

  // If the LFSM is enabled and the link status changes to Remote Fault or Link
  // Interruption, then the PCS shall start transmitting IDLEs.
  property check_idle_txed_on_rf_or_li_rxed;
    @(posedge pcs_rx_clk)
      gem_pcs_rx_fault_en                                                        &&
      ((gem_pcs_rx_fault_status == 2'b10) || (gem_pcs_rx_fault_status == 2'b11)) &&
      (gem_pcs_rx_fault_status != lfsm_covmod_rx_fault_status_prev)
    |->
    @(posedge gtx_clk)
      ##[MIN_GTX_CYCLES_TOLERANCE:MAX_GTX_CYCLES_TOLERANCE]
        lfsm_covmod_tx_i_det;
  endproperty : check_idle_txed_on_rf_or_li_rxed
  assert_check_idle_txed_on_rf_or_li_rxed : assert property(check_idle_txed_on_rf_or_li_rxed);

  // If the LFSM is enabled, the link status is Local Fault and the PCS is
  // transmitting Remote Faults, then the PCS shall keep on transmitting Remote
  // Faults.
  property check_rf_txed_while_lf;
    @(negedge gtx_clk)
      gem_pcs_rx_fault_en                &&
      (gem_pcs_rx_fault_status == 2'b01) &&
      lfsm_covmod_tx_q_det
    |->
    ##1
      lfsm_covmod_tx_q_det;
  endproperty : check_rf_txed_while_lf
  assert_check_rf_txed_while_lf : assert property(check_rf_txed_while_lf);

  // If the LFSM is enabled, the link status is Remote Fault or Link
  // Interruption and the PCS is transmitting IDLEs, then the PCS shall keep on
  // transmitting IDLEs.
  property check_idle_txed_while_rf_or_li;
    @(negedge gtx_clk)
      gem_pcs_rx_fault_en                                                        &&
      ((gem_pcs_rx_fault_status == 2'b10) || (gem_pcs_rx_fault_status == 2'b11)) &&
      lfsm_covmod_tx_i_det
    |->
    ##1
      lfsm_covmod_tx_i_det;
  endproperty : check_idle_txed_while_rf_or_li
  assert_check_idle_txed_while_rf_or_li : assert property(check_idle_txed_while_rf_or_li);

  // If the PCS is synchronized and the column count has reached 128 (256 couple
  // of code groups), then the link status shall come back to OK.
  property check_clear_link_status_upon_waiting;
    @(posedge pcs_rx_clk)
      (lfsm_covmod_rx_half_col_cnt == 32'd256) &&
      gem_pcs_rx_fault_sync
    |->
    ##1
      (gem_pcs_rx_fault_status == 2'b00);
  endproperty : check_clear_link_status_upon_waiting
  assert_check_clear_link_status_upon_waiting : assert property (check_clear_link_status_upon_waiting);

  // If the sequence count increases (i.e. a fault sequence is received), then
  // the column count shall be reset to zero.
  property check_column_count_reset_on_fault;
    @(posedge pcs_rx_clk)
      (lfsm_covmod_rx_seq_cnt != lfsm_covmod_rx_seq_cnt_prev) &&
      (lfsm_covmod_rx_seq_cnt != 32'd0)
    |->
    gem_pcs_rx_col_cnt == 9'd0;
  endproperty : check_column_count_reset_on_fault
  assert_check_column_count_reset_on_fault : assert property(check_column_count_reset_on_fault);

  // If the LFSM is enabled, the link status changes to a fault value and the
  // MAC is transmitting packets to the PCS, then the PCS shall transmit fault
  // indications.
  property check_override_pkt_with_fault_indication;
    @(posedge pcs_rx_clk)
      gem_pcs_rx_fault_en                                           &&
      (gem_pcs_rx_fault_status != lfsm_covmod_rx_fault_status_prev) &&
      (gem_pcs_rx_fault_status != 2'b00)                            &&
      gmii_tx_en
    |->
    @(posedge gtx_clk)
      ##[MIN_GTX_CYCLES_TOLERANCE:MAX_GTX_CYCLES_TOLERANCE]
        (lfsm_covmod_tx_w3_1 || lfsm_covmod_tx_i_det);
  endproperty : check_override_pkt_with_fault_indication
  assert_check_override_pkt_with_fault_indication : assert property(check_override_pkt_with_fault_indication);
`endif

// -----------------------------------------------------------------------------
//
//                               802.3br Coverage
//
// -----------------------------------------------------------------------------

reg tx_rdy_pmac_d1;
reg tx_en_pmac_d1;
reg tx_en_emac_d1;
reg rx_dv_pmac_d1;
reg rx_dv_emac_d1;
reg [13:0] pmac_frame_size;
wire emac_enst_hold;
wire emac_enst_gate;
reg emac_enst_hold_d1;
integer pmac_rx_frag_byte_cnt;
integer pmac_rx_frm_byte_cnt;
integer emac_rx_frm_byte_cnt;
integer pmac_rx_frag_cnt;
reg [1:0] preemption_cause;
integer num_cycles_from_hold_to_rdy;
wire [1:0] add_frag_size;
wire disable_verify;
wire pre_enable;
wire restart_ver;
wire tr_sop_trigger; //start of frame to trigger coverage
wire rx_dv_emac;
wire rx_dv_pmac;
wire tx_en_emac;
wire tx_en_pmac;

wire tx_sel_emac;
wire rx_sel_emac;

wire [3:0] pmac_tx_state;
wire       pmac_tx_rdy;
wire [1:0] pmac_rx_nibble_pntr;
wire       preempting;

initial
begin
  pmac_rx_frag_byte_cnt = 0;
  pmac_rx_frm_byte_cnt = 0;
  emac_rx_frm_byte_cnt = 0;
  pmac_rx_frag_cnt = 0;
  tx_rdy_pmac_d1 = 1'b0;
  tx_en_pmac_d1 = 1'b0;
  tx_en_emac_d1 = 1'b0;
  rx_dv_pmac_d1 = 1'b0;
  rx_dv_emac_d1 = 1'b0;
  emac_enst_hold_d1 <= 0;
  num_cycles_from_hold_to_rdy <= 0;
end

`ifdef gem_has_802p3_br
  assign preempting    = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.preempt;
  assign add_frag_size = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.add_frag_size;
  assign disable_verify = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.disable_verify;
  assign pre_enable = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.pre_enable;
  assign restart_ver = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_ver.restart_ver;  // This is a pulse on tx_clk
  assign rx_dv_emac = `hier_gem_top.gen_has_802p3_br.emac_rx_dv | (|`hier_gem_top.gen_has_802p3_br.emac_rx_dv_pcs);
  assign rx_dv_pmac = `hier_gem_top.pmac_rx_dv | (|`hier_gem_top.pmac_rx_dv_pcs);
  assign tx_en_emac = (`hier_gem_top.emac_tx_en | `hier_gem_top.emac_tx_en_pcs);
  assign tx_en_pmac = (`hier_gem_top.pmac_tx_en | `hier_gem_top.pmac_tx_en_pcs);

  assign tx_sel_emac  = (`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.n_state == 5'b00010);
  assign rx_sel_emac  = (`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_exp_flt.n_state == 4'b0111) ||
                        (`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_exp_flt.n_state == 4'b1000);

  assign pmac_tx_state = `hierarchy.i_gem_mac.i_gem_tx_wrap.i_gem_tx.i_tx_state.mac_state_tx;
  assign pmac_rx_nibble_pntr = `hierarchy.i_gem_mac.i_gem_rx.nibble_pntr;

  assign pmac_tx_rdy  = `hier_gem_top.pmac_tx_rdy;

  always @(posedge mac_tx_clk)
  begin
    tx_rdy_pmac_d1 <= pmac_tx_rdy;
    tx_en_pmac_d1 <= tx_en_pmac && pmac_tx_rdy;
    tx_en_emac_d1 <= tx_en_emac && `hier_gem_top.emac_tx_rdy;
    pmac_frame_size <= `hier_gem_top.pmac_tx_frame_len;
  end

  always@(posedge mac_rx_clk)
  begin
    rx_dv_pmac_d1 <= rx_dv_pmac;
    rx_dv_emac_d1 <= rx_dv_emac;
    if (rx_dv_pmac_d1 & !rx_dv_pmac)  // Falling edge
    begin
      pmac_rx_frag_byte_cnt <= 0;
      if (`hier_gem_top.pmac_rx_halt) // end of fragment
        pmac_rx_frag_cnt++;
      else  // end of frame
      begin
        pmac_rx_frag_cnt     <= 0;
        pmac_rx_frm_byte_cnt <= 0;
      end
    end
    else if (rx_dv_pmac)
    begin
      pmac_rx_frm_byte_cnt++;
      pmac_rx_frag_byte_cnt++;
    end

    if (rx_dv_emac_d1 & !rx_dv_emac)  // Falling edge
      emac_rx_frm_byte_cnt <= 0;
    else if (rx_dv_emac)
      emac_rx_frm_byte_cnt++;
  end

`ifdef gem_exclude_qbv
  assign  emac_enst_hold  = 1'b0;
  assign  emac_enst_gate  = 1'b0;
`else
  `ifdef edma_tx_pkt_buffer
    assign  emac_enst_hold  = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.hold;
    assign  emac_enst_gate  = `hier_gem_top.gen_has_802p3_br.i_gem_top.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.gen_enst_module.gen_enst1.gen_edma_pbuf_tx_enst1[0].i_edma_pbuf_tx_enst.gatestate;
  `endif
`endif

  always @(posedge mac_tx_clk)
  begin
    emac_enst_hold_d1 <= emac_enst_hold;
    if (emac_enst_hold & !tx_en_emac)
    begin
      if (pmac_tx_rdy & tx_en_pmac)
        num_cycles_from_hold_to_rdy++;
      else
        num_cycles_from_hold_to_rdy <= 0;
    end
    else
      num_cycles_from_hold_to_rdy <= 0;
  end
  assign  preemption_cause = emac_enst_hold && !emac_enst_gate && !pmac_tx_rdy ? 2'b01 :
                                                                  !pmac_tx_rdy ? 2'b10 : 2'b00;
  //assign  add_frag_size = `hier_gem_top.gen_has_802p3_br.i_gem_top.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.gen_enst_module.gen_enst1.gen_edma_pbuf_tx_enst1[0].i_edma_pbuf_tx_enst.add_frag_size[1:0];
`else
  assign add_frag_size = 2'b00;
  assign disable_verify = 1'b0;
  assign pre_enable = 1'b0;
  assign restart_ver = 1'b0;
  assign rx_dv_emac = 1'b0;
  assign rx_dv_pmac = 1'b0;
  assign tx_en_emac = 1'b0;
  assign tx_en_pmac = 1'b0;
  assign tx_sel_emac  = 1'b0;
  assign rx_sel_emac  = 1'b0;
  assign pmac_tx_state = 4'h0;
  assign pmac_tx_rdy   = 1'b0;
  assign pmac_rx_nibble_pntr  = 2'h0;

  always @(posedge mac_tx_clk)
  begin
    tx_rdy_pmac_d1 <= 1'b0;
    tx_en_pmac_d1 <= 1'b0;
    tx_en_emac_d1 <= 1'b0;
    num_cycles_from_hold_to_rdy <= 0;
    pmac_frame_size <= 14'd0;
  end
  always @(posedge mac_rx_clk)
  begin
    rx_dv_pmac_d1 <= 1'b0;
    rx_dv_emac_d1 <= 1'b0;
    pmac_rx_frag_byte_cnt = 0;
    pmac_rx_frm_byte_cnt = 0;
    pmac_rx_frag_cnt = 0;
    emac_rx_frm_byte_cnt = 0;
    emac_enst_hold_d1 <= 0;
    preemption_cause <= 2'b00;
  end
  assign  emac_enst_hold   = 1'b0;
`endif

  `ifndef FIFO_DMA_FC
  // *** FIFO/DMA switch used in some FC ***
  `define FIFO_DMA_FC
  `ifdef gem_ext_fifo_interface // FIFO used
    `define DECLARE_DMA_FIFO_FLAG \
      bit fifo_dma_flag = 1'b0;
  `else // DMA used
    `define DECLARE_DMA_FIFO_FLAG \
      bit fifo_dma_flag = 1'b1;
  `endif // gem_ext_fifo_interface

  `define DMA_FIFO_CP \
    dma_fifo_cp : coverpoint fifo_dma_flag { \
      bins fifo = {1'b0}; \
      bins dma  = {1'b1}; \
    }
  `define DMA_FIFO_CROSS(the_other_cp) \
    the_other_cp``_x_fifo_dma_cp : cross dma_fifo_cp, the_other_cp;
  `endif // FIFO_DMA_FC

  `DECLARE_DMA_FIFO_FLAG

  // phys_if_type
  // 0 : GMII
  // 1 : MII 100M (RGMII not physically configured)
  // 2 : MII 10M (RGMII not physically configured)
  // 3 : RGMII gigabit
  // 4 : RGMII 100m
  // 5 : RGMII 10m
  // 6 : RMII 100m
  // 7 : RMII 10m
  // 8 : MII 100M (RGMII is physically configured)
  // 9 : MII 10M (RGMII is physically configured)
  // 10: TBI 2.5G
  // 11 : TBI gigabit
  // 12 : TBI 100M
  // 13 : TBI 10M
  wire [3:0] phys_if_type;
  wire tbi;
  assign tbi = speed_mode[2];
  wire rmii;
  `ifdef gem_include_rmii
  assign rmii =!`hier_gem_top.mii_select & ~tbi;
  `else
  assign rmii = 1'b0;
  `endif
  wire rgmii;
  wire mii_on_rgmii;
  `ifdef gem_use_rgmii
  assign rgmii        = ~rmii & ~tbi & !`hier_gem_top.i_gem_top.i_gem_reg_top.i_gem_registers.sel_mii_on_rgmii;
  assign mii_on_rgmii = ~rmii & ~tbi & `hier_gem_top.i_gem_top.i_gem_reg_top.i_gem_registers.sel_mii_on_rgmii;
  `else
  assign rgmii        = 1'b0;
  assign mii_on_rgmii = 1'b0;
  `endif
  wire gmii;
  assign gmii = ~rgmii & ~rmii & ~tbi & speed_mode[1];
  wire mii;
  assign mii = ~rgmii & ~rmii & ~tbi & ~gmii & ~mii_on_rgmii;

  assign phys_if_type = mii && speed_mode[0]          ? 4'h1 :
                        mii                           ? 4'h2 :
                        rgmii && speed_mode[1]        ? 4'h3 :
                        rgmii && speed_mode[0]        ? 4'h4 :
                        rgmii                         ? 4'h5 :
                        rmii && speed_mode[0]         ? 4'h6 :
                        rmii                          ? 4'h7 :
                        mii_on_rgmii && speed_mode[0] ? 4'h8 :
                        mii_on_rgmii                  ? 4'h9 :
                        tbi && speed_mode[3]          ? 4'ha :
                        tbi && speed_mode[1]          ? 4'hb :
                        tbi && speed_mode[0]          ? 4'hc :
                        tbi                           ? 4'hd : 4'h0;

  // Cover where PMAC TX state machine is
  `define CP_PMAC_TX_STATE \
    cp_pmac_tx_state   : coverpoint pmac_tx_state { \
      bins  init_ipg  = {0};  \
      bins  idle      = {1};  \
      bins  preamble  = {2};  \
      bins  sfd       = {6};  \
      bins  data      = {7};  \
      bins  crc       = {8};  \
    }

  // We are interested in rising edge of emac tx_en where the PMAC would be halted and the current TX
  // state machine state.
  covergroup cg_802p3br_pmac_tx_state_x_emac_en @(posedge (tx_en_emac & ~tx_en_emac_d1 & mac_tx_clk));
    `CP_PMAC_TX_STATE
    `DMA_FIFO_CP
    `DMA_FIFO_CROSS(cp_pmac_tx_state)
  endgroup : cg_802p3br_pmac_tx_state_x_emac_en
  cg_802p3br_pmac_tx_state_x_emac_en  i_cg_802p3br_pmac_tx_state_x_emac_en = new();

  // Cover cases of pmac_tx_rdy vs storage state of transmit buffer.
  covergroup cg_802p3br_pmac_store_x_rdy @(posedge (tx_rdy_pmac_d1 & ~pmac_tx_rdy & mac_tx_clk));
    no_of_stored_bytes  : coverpoint `hierarchy.i_gem_mac.i_gem_tx_wrap.i_gem_tx.no_of_stored_bytes {
        bins one_byte     = {1};
        bins two_bytes    = {2};
        bins three_bytes  = {3};
        bins four_bytes   = {4};
        bins five_bytes   = {5};
        bins six_bytes    = {6};
        bins seven_bytes  = {7};
        bins eight_bytes  = {8};
    }
    `DMA_FIFO_CP
    `DMA_FIFO_CROSS(no_of_stored_bytes)
  endgroup : cg_802p3br_pmac_store_x_rdy
  cg_802p3br_pmac_store_x_rdy  i_cg_802p3br_pmac_store_x_rdy = new();

  // Cover halt of RX vs pmac_rx_nibble_pntr
  covergroup cg_802p3br_pmac_rx_nibble_pntr_x_halt @(posedge `hier_gem_top.pmac_rx_halt);
    pmac_rx_nibble_pntr : coverpoint pmac_rx_nibble_pntr;
    //`DMA_FIFO_CP
    //`DMA_FIFO_CROSS(pmac_rx_nibble_pntr)
  endgroup : cg_802p3br_pmac_rx_nibble_pntr_x_halt
  cg_802p3br_pmac_rx_nibble_pntr_x_halt i_cg_802p3br_pmac_rx_nibble_pntr_x_halt = new();

// cover if a frame has been routed to eMAC
// cover if a frame has been routed to pMAC
// cover frame size
// cover physical interface type
// cover physical interface speed
  `define CP_PHYS_IF_TYPE \
    phys_if_type_cp   : coverpoint phys_if_type { \
         bins gmii              = {0};  \
         bins mii_100m          = {1};  \
         bins mii_10m           = {2};  \
         bins rgmii_1gm         = {3};  \
         bins rgmii_100m        = {4};  \
         bins rgmii_10m         = {5};  \
         bins rmii_100m         = {6};  \
         bins rmii_10m          = {7};  \
         bins mii_on_rgmii_100m = {8};  \
         bins mii_on_rgmii_10m  = {9};  \
         bins tbi_2p5g          = {10}; \
         bins tbi_1gm           = {11}; \
         bins tbi_100m          = {12}; \
         bins tbi_10m           = {13}; \
    }

  covergroup cg_802p3br_pmac_tx @(negedge (tx_en_pmac_d1 & !tx_en_pmac & mac_tx_clk));
    frame_length_cp   : coverpoint pmac_frame_size {
         bins pkt_short          = {[1:63]};
         bins pkt_small          = {[64:500]};
         bins pkt_med            = {[501:1000]};
         bins pkt_large          = {[1001:$]};
    }
    `CP_PHYS_IF_TYPE
  endgroup : cg_802p3br_pmac_tx
  cg_802p3br_pmac_tx i_cg_802p3br_pmac_tx = new();

  // Simple coverage of PMAC and EMAC transmitting
  covergroup cg_802p3br_pmac_tx_if @(posedge (~tx_sel_emac & tx_en_pmac));
    `CP_PHYS_IF_TYPE
    //`DMA_FIFO_CP
    //`DMA_FIFO_CROSS(phys_if_type_cp)
  endgroup : cg_802p3br_pmac_tx_if
  cg_802p3br_pmac_tx_if i_cg_802p3br_pmac_tx_if = new();

  covergroup cg_802p3br_emac_tx_if @(posedge (tx_sel_emac & tx_en_emac));
    `CP_PHYS_IF_TYPE
    //`DMA_FIFO_CP
    //`DMA_FIFO_CROSS(phys_if_type_cp)
  endgroup : cg_802p3br_emac_tx_if
  cg_802p3br_emac_tx_if i_cg_802p3br_emac_tx_if = new();

  covergroup cg_802p3br_emac_tx @(negedge (preempting));
    `CP_PHYS_IF_TYPE
    `DMA_FIFO_CP
    cause_of_preemption_cp   : coverpoint preemption_cause {
         bins enst_hold_causing_preemption        = {1};
         bins express_pkt_causing_preemption      = {2};
    }
    cause_of_preemption_cross : cross cause_of_preemption_cp, phys_if_type_cp, dma_fifo_cp;
  endgroup : cg_802p3br_emac_tx
  cg_802p3br_emac_tx i_cg_802p3br_emac_tx = new();

  covergroup cg_802p3br_pmac_rx @(negedge (rx_dv_pmac_d1 & !rx_dv_pmac & mac_rx_clk));
    `CP_PHYS_IF_TYPE
    frame_length_cp   : coverpoint pmac_rx_frm_byte_cnt {
         bins pkt_short          = {[1:63]};
         bins pkt_small          = {[64:500]};
         bins pkt_med            = {[501:1000]};
         bins pkt_large          = {[1001:$]};
    }
    num_pmac_fragments_cp   : coverpoint pmac_rx_frag_cnt {
         bins one_frag_in_frm     = {1};
         bins two_frags_in_frm    = {2};
         bins three_frags_in_frm  = {3};
         bins gt4_frags_in_frm    = {[4:$]};
    }
    pmac_fragment_size_cp   : coverpoint pmac_rx_frag_byte_cnt {
         bins frag_short         = {[1:64]};
         bins frag_med           = {[65:500]};
         bins frag_long          = {[501:$]};
    }
  endgroup : cg_802p3br_pmac_rx
  cg_802p3br_pmac_rx i_cg_802p3br_pmac_rx = new();
  covergroup cg_802p3br_emac_rx @(negedge (rx_dv_emac_d1 & !rx_dv_emac & mac_rx_clk));
    `CP_PHYS_IF_TYPE
    frame_length_cp   : coverpoint emac_rx_frm_byte_cnt {
         bins pkt_short          = {[1:63]};
         bins pkt_small          = {[64:500]};
         bins pkt_med            = {[501:1000]};
         bins pkt_large          = {[1001:$]};
    }
  endgroup : cg_802p3br_emac_rx
  cg_802p3br_emac_rx i_cg_802p3br_emac_rx = new();

  // Simple coverage of PMAC and EMAC receiving
  covergroup cg_802p3br_pmac_rx_if @(posedge (~rx_sel_emac & rx_dv_pmac));
    `CP_PHYS_IF_TYPE
    //`DMA_FIFO_CP
    //`DMA_FIFO_CROSS(phys_if_type_cp)
  endgroup : cg_802p3br_pmac_rx_if
  cg_802p3br_pmac_rx_if i_cg_802p3br_pmac_rx_if = new();

  covergroup cg_802p3br_emac_rx_if @(posedge (rx_sel_emac & rx_dv_emac));
    `CP_PHYS_IF_TYPE
    //`DMA_FIFO_CP
    //`DMA_FIFO_CROSS(phys_if_type_cp)
  endgroup : cg_802p3br_emac_rx_if
  cg_802p3br_emac_rx_if i_cg_802p3br_emac_rx_if = new();


  // Coverage of EMAC and PMAC transmission states.
  covergroup cg_802p3br_pmac_emac_tx_cross @(posedge (mac_tx_clk));
    mac_selection : coverpoint tx_sel_emac {
      bins  emac  = {1};
      bins  pmac  = {0};
    }
    pmac_tx_en    : coverpoint tx_en_pmac;
    emac_tx_en    : coverpoint tx_en_emac;
    `DMA_FIFO_CP
    cross mac_selection, pmac_tx_en, emac_tx_en, dma_fifo_cp {
        ignore_bins mmsl_cant_select_emac_without_emac_request = (binsof (emac_tx_en) intersect {0}) &&
                                                                  binsof (mac_selection.emac);
    }
  endgroup : cg_802p3br_pmac_emac_tx_cross
  cg_802p3br_pmac_emac_tx_cross i_cg_802p3br_pmac_emac_tx_cross = new();

  // ENST Coverage with 802.3br
  // Cover EnST HOLD from eMAC causing pre-emption of pMAC
  // We can do this by checking that pMAC tx_rdy goes low even when
  // eMAC is not transmitting.
  //
  assign cg_802p3br_enst_trig = (emac_enst_hold & tx_rdy_pmac_d1 & !pmac_tx_rdy & mac_tx_clk);
  covergroup cg_802p3br_enst @(negedge (cg_802p3br_enst_trig));
    `DMA_FIFO_CP

    time_enst_hold_to_preemption : coverpoint num_cycles_from_hold_to_rdy {
         bins cycles_1_64        = {[1:64]};
         bins cycles_64_128      = {[65:128]};
         bins cycles_129_196     = {[129:196]};
         bins cycles_gt196       = {[197:$]};
    }
    `DMA_FIFO_CROSS(time_enst_hold_to_preemption)

    //add_frag_size : coverpoint  add_frag_size;
  endgroup
  cg_802p3br_enst i_cg_802p3br_enst = new();

  // BR configuration coverage
`ifdef gem_has_802p3_br
  assign tr_sop_trigger = (`hier_gem_top.i_gem_top.i_gem_mac.rx_w_sop || `hier_gem_top.i_gem_top.i_gem_mac.tx_r_sop);

  covergroup cg_static_registers @(posedge tr_sop_trigger);
    `DMA_FIFO_CP
    add_frag_size_cp   : coverpoint add_frag_size {
         bins bytes_64              = {0};
         bins bytes_128             = {1};
         bins bytes_192             = {2};
         bins bytes_256             = {3};
    }
    `DMA_FIFO_CROSS(add_frag_size_cp)
    disable_verify_cp   : coverpoint disable_verify {
         bins verify_enable         = {0};
         bins verify_disable        = {1};
    }
    `DMA_FIFO_CROSS(disable_verify_cp)
  endgroup : cg_static_registers
  cg_static_registers i_cg_static_registers = new();

  covergroup cg_dynamic_registers_tr_trig @(posedge tr_sop_trigger);
    pre_enable_cp   : coverpoint pre_enable {
         bins preemption_enable     = {0};
         bins preemption_disable    = {1};
    }
    `DMA_FIFO_CP
    `DMA_FIFO_CROSS(pre_enable_cp)
  endgroup : cg_dynamic_registers_tr_trig
  cg_dynamic_registers_tr_trig i_cg_dynamic_registers_tr_trig = new();

  covergroup cg_dynamic_registers_clk_trig @(posedge mac_tx_clk);
    restart_ver_cp   : coverpoint restart_ver {
         bins restart_disable       = {0};
         bins restart_enable        = {1};
    }
    `DMA_FIFO_CP
    `DMA_FIFO_CROSS(restart_ver_cp)
  endgroup : cg_dynamic_registers_clk_trig
  cg_dynamic_registers_clk_trig i_cg_dynamic_registers_clk_trig = new();

  logic [4:0] gem_rx_pbuf_addr = `gem_rx_pbuf_addr;
  logic [4:0] gem_tx_pbuf_addr = `gem_tx_pbuf_addr;
  logic [4:0] emac_rx_pbuf_addr = `gem_emac_rx_pbuf_addr;
  logic [4:0] emac_tx_pbuf_addr = `gem_emac_tx_pbuf_addr;
  logic [4:0] rx_pbuf_addr_diff;
  logic [4:0] tx_pbuf_addr_diff;
  assign rx_pbuf_addr_diff = gem_rx_pbuf_addr ^ emac_rx_pbuf_addr;
  assign tx_pbuf_addr_diff = gem_tx_pbuf_addr ^ emac_tx_pbuf_addr;

  covergroup cg_br_defines @(posedge tr_sop_trigger);
    `DMA_FIFO_CP
    rx_pbuf_addr_cp : coverpoint rx_pbuf_addr_diff {
          bins        same_buffer_size    = {0};
          bins        unique_buffer_size  = {[1:$]};
    }
    `DMA_FIFO_CROSS(rx_pbuf_addr_cp)
    tx_pbuf_addr_cp : coverpoint tx_pbuf_addr_diff {
          bins        same_buffer_size    = {0};
          bins        unique_buffer_size  = {[1:$]};
    }
    `DMA_FIFO_CROSS(tx_pbuf_addr_cp)
  endgroup : cg_br_defines
  cg_br_defines i_cg_br_defines = new();
`endif


// Instantiate the coverage module for CB
cb_coverage i_cb_cov ();

// All cover/assertions related to ASF
generate begin : gen_asf_cov
  // Instantiate the coverage module for ASF
  asf_coverage i_asf_cov (
    .disable_asf_assertions(disable_asf_assertions)
  );
end
endgenerate

  // -----------------------------------------------------------------------
  //
  //           Assertions and FC for type1 screener's drop functionality
  //
  // -----------------------------------------------------------------------
  wire   frame_being_decoded;
  reg    frame_being_decoded_del;
  assign frame_being_decoded = `hierarchy.i_gem_mac.i_gem_rx.frame_being_decoded;

  always @ (posedge rx_clk or negedge n_rxreset)
  begin
    if(~n_rxreset)
      frame_being_decoded_del <= 1'b0;
    else
      frame_being_decoded_del <= frame_being_decoded;
  end

  `ifdef num_type1_screeners
    reg  [`num_type1_screeners-1:0] type1_match_n_drop_set;
    reg  [`num_type1_screeners-1:0] type1_match_n_drop_unset;
    wire [`num_type1_screeners-1:0] drop_frame_type1;

    assign drop_frame_type1 = `hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.drop_frame_type1[`num_type1_screeners:1];

    genvar k;
    generate for(k=0; k<`num_type1_screeners; k=k+1) begin: gen_fc_type1_drop_on_match
      wire type1_scrn_drop_on_match;
      wire type1_scrn_match;

      assign type1_scrn_drop_on_match = `hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.gen_scrn1.gen_screener_type1[k].i_screener_type1.udptos_rules[30];
      assign type1_scrn_match         = `hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.gen_scrn1.gen_screener_type1[k].i_screener_type1.matched;

      // Support registers for the assertions
      always @ (posedge rx_clk or negedge n_rxreset)
      begin
        if(~n_rxreset)
          type1_match_n_drop_set[k] <= 1'b0;
        else
          begin
            if(rx_w_eop)
              type1_match_n_drop_set[k] <= 1'b0;
            else
              begin
                if(~frame_being_decoded && frame_being_decoded_del)
                  begin
                    if(type1_scrn_match && type1_scrn_drop_on_match)
                      type1_match_n_drop_set[k] <= 1'b1;
                  end
              end
          end
      end

      always @ (posedge rx_clk or negedge n_rxreset)
      begin
        if(~n_rxreset)
          type1_match_n_drop_unset[k] <= 1'b0;
        else
          begin
            if(rx_w_eop)
              type1_match_n_drop_unset[k] <= 1'b0;
            else
              begin
                if(~frame_being_decoded && frame_being_decoded_del)
                  begin
                    if(type1_scrn_match && ~type1_scrn_drop_on_match)
                      type1_match_n_drop_unset[k] <= 1'b1;
                  end
              end
          end
      end

      `define CP_TYPE1_SCRN_DROP_ON_MATCH \
        cp_scrn_type1_drop_on_match_range : coverpoint type1_scrn_drop_on_match { \
          bins type1_scrn_drop_on_match_off = {0}; \
          bins type1_scrn_drop_on_match_on  = {1}; \
        }

      `define CP_TYPE1_SCRN_MATCH \
        cp_scrn_type1_match_range : coverpoint type1_scrn_match { \
          bins type1_scrn_match_no  = {0}; \
          bins type1_scrn_match_yes = {1}; \
        }

      // Cross coverage between drop_on_match and screener match
      covergroup cg_drop_on_match_x_type1_scrn_match @(negedge rx_clk);

         option.per_instance = 1;
        `CP_TYPE1_SCRN_DROP_ON_MATCH
        `CP_TYPE1_SCRN_MATCH

         drop_on_match_x_type1_scrn_match: cross cp_scrn_type1_drop_on_match_range, cp_scrn_type1_match_range;
      endgroup
      cg_drop_on_match_x_type1_scrn_match i_cg_drop_on_match_x_type1_scrn_match = new();

      `ifdef ABV_ON
        // Check that packets are correctly dropped when a screener matches with the drop_on_match bit set
        // This check has to be done for each screener individually
        property check_drop_on_match_type1_a;
        @(posedge rx_clk)
          (type1_match_n_drop_set[k] && rx_w_eop) |-> rx_w_err;
        endproperty
        assert_check_drop_on_match_type1_a : assert property (check_drop_on_match_type1_a);

        property check_drop_on_match_type1_b;
        // Check that packets are not dropped when drop_on_match is not set and the screener matches
        // This check has to be done for each screener individually
        @(posedge rx_clk)
          (type1_match_n_drop_unset[k]) |-> ~drop_frame_type1[k];
        endproperty
        assert_check_drop_on_match_type1_b : assert property (check_drop_on_match_type1_b);
      `endif

    end
    endgenerate

    `ifdef ABV_ON
      // Check that if any screener matches with drop on match set, the packet should be dropped
      property check_drop_on_any_match_type1;
      @(posedge rx_clk)
        (|type1_match_n_drop_set && rx_w_eop) |-> rx_w_err;
      endproperty
      assert_check_drop_on_any_match_type1 : assert property (check_drop_on_any_match_type1);

      // Check that, if a packet is matched on multiple screeners with different values of drop_on_match
      // then the packet is dropped if at least one of them has drop_on_match set
      // What we can do is to check the type1_match_n_drop_set and type1_match_n_drop_unset.
      // If we have at least one in one of them then the condition is satisfied
      property check_drop_if_type1_screeners_disagree;
      @(posedge rx_clk)
        (|type1_match_n_drop_set && |type1_match_n_drop_unset && rx_w_eop) |-> rx_w_err;
      endproperty
      assert_check_drop_if_type1_screeners_disagree : assert property (check_drop_if_type1_screeners_disagree);
    `endif

  `endif

  // -----------------------------------------------------------------------
  //
  //           Assertions and FC for type2 screener's drop functionality
  //
  // -----------------------------------------------------------------------
  `ifdef num_type2_screeners
    reg  [`num_type2_screeners-1:0] type2_match_n_drop_set;
    reg  [`num_type2_screeners-1:0] type2_match_n_drop_unset;
    wire [`num_type2_screeners-1:0] drop_frame_type2;

    assign drop_frame_type2 = `hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.drop_frame_type2[`num_type2_screeners:1];

    genvar m;
    generate for(m=0; m<`num_type2_screeners; m=m+1) begin: gen_fc_type2_drop_on_match
      wire type2_scrn_drop_on_match;
      wire type2_scrn_match;

      assign type2_scrn_drop_on_match = `hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.gen_scrn2.screener_type2[m].i_screener_type2.vlan_rules[31];
      assign type2_scrn_match         = `hierarchy.i_gem_mac.i_gem_rx.gen_screeners.i_gem_screener_top.gen_scrn2.screener_type2[m].i_screener_type2.matched;

      // Support registers for the assertions
      always @ (posedge rx_clk or negedge n_rxreset)
      begin
        if(~n_rxreset)
          type2_match_n_drop_set[m] <= 1'b0;
        else
          begin
            if(rx_w_eop)
              type2_match_n_drop_set[m] <= 1'b0;
            else
              begin
                if(~frame_being_decoded && frame_being_decoded_del)
                  begin
                    if(type2_scrn_match && type2_scrn_drop_on_match)
                      type2_match_n_drop_set[m] <= 1'b1;
                  end
              end
          end
      end

      always @ (posedge rx_clk or negedge n_rxreset)
      begin
        if(~n_rxreset)
          type2_match_n_drop_unset[m] <= 1'b0;
        else
          begin
            if(rx_w_eop)
              type2_match_n_drop_unset[m] <= 1'b0;
            else
              begin
                if(~frame_being_decoded && frame_being_decoded_del)
                  begin
                    if(type2_scrn_match && ~type2_scrn_drop_on_match)
                      type2_match_n_drop_unset[m] <= 1'b1;
                  end
              end
          end
      end

      `define CP_TYPE2_SCRN_DROP_ON_MATCH \
        cp_scrn_type2_drop_on_match_range : coverpoint type2_scrn_drop_on_match { \
          bins type2_scrn_drop_on_match_off = {0}; \
          bins type2_scrn_drop_on_match_on  = {1}; \
        }

      `define CP_TYPE2_SCRN_MATCH \
        cp_scrn_type2_match_range : coverpoint type2_scrn_match { \
          bins type2_scrn_match_no  = {0}; \
          bins type2_scrn_match_yes = {1}; \
        }

      // Cross coverage between drop_on_match and screener match
      covergroup cg_drop_on_match_x_type2_scrn_match @(negedge rx_clk);

         option.per_instance = 1;
        `CP_TYPE2_SCRN_DROP_ON_MATCH
        `CP_TYPE2_SCRN_MATCH

         drop_on_match_x_type2_scrn_match: cross cp_scrn_type2_drop_on_match_range, cp_scrn_type2_match_range;
      endgroup
      cg_drop_on_match_x_type2_scrn_match i_cg_drop_on_match_x_type2_scrn_match = new();

      `ifdef ABV_ON
        // Check that packets are correctly dropped when a screener matches with the drop_on_match bit set
        // This check has to be done for each screener individually
        property check_drop_on_match_type2_a;
        @(posedge rx_clk)
          (type2_match_n_drop_set[m] && rx_w_eop) |-> rx_w_err;
        endproperty
        assert_check_drop_on_match_type2_a : assert property (check_drop_on_match_type2_a);

        // Check that packets are not dropped when drop_on_match is not set and the screener matches
        // This check has to be done for each screener individually
        property check_drop_on_match_type2_b;
        @(posedge rx_clk)
          (type2_match_n_drop_unset[m]) |-> ~drop_frame_type2[m];
        endproperty
        assert_check_drop_on_match_type2_b : assert property (check_drop_on_match_type2_b);
      `endif

    end
    endgenerate

    `ifdef ABV_ON
      // Check that if any screener matches with drop on match set, the packet should be dropped
      property check_drop_on_any_match_type2;
      @(posedge rx_clk)
        (|type2_match_n_drop_set && rx_w_eop) |-> rx_w_err;
      endproperty
      assert_check_drop_on_any_match_type2 : assert property (check_drop_on_any_match_type2);

      // Check that, if a packet is matched on multiple screeners with different values of drop_on_match
      // then the packet is dropped if at least one of them has drop_on_match set
      // What we can do is to check the type2_match_n_drop_set and type2_match_n_drop_unset.
      // If we have at least one in one of them then the condition is satisfied
      property check_drop_if_type2_screeners_disagree;
      @(posedge rx_clk)
        (|type2_match_n_drop_set && |type2_match_n_drop_unset && rx_w_eop) |-> rx_w_err;
      endproperty
      assert_check_drop_if_type2_screeners_disagree : assert property (check_drop_if_type2_screeners_disagree);
    `endif

  `endif

    // -----------------------------------------------------------------------
    //
    //           Assertions for per-queue rx flush Mode0 and Mode3
    //
    // -----------------------------------------------------------------------
    wire      [`edma_queues-1:0] drop_all_frames_rx_clk;         // Mode0 enable vector at core level
    wire      [`edma_queues-1:0] force_discard_on_err_q_ambaclk; // Mode1 enable vector at core level
    wire      [`edma_queues-1:0] limit_num_bytes_allowed_ambaclk;// Mode2 enable vector at core level Gated with Mode3 enable signal
    wire      [`edma_queues-1:0] limit_frames_size_rx_clk;       // Mode3 enable vector at core level
    wire                  [13:0] frame_length;
    wire                         final_eop_push;
    reg       [`edma_queues-1:0] frame_rxd_q;
    wire [(16*`edma_queues)-1:0] max_val_pclk;
    wire                   [3:0] queue_pointer;

    assign drop_all_frames_rx_clk       = `hierarchy.i_gem_mac.i_gem_rx.drop_all_frames_rx_clk;
    assign frame_length                 = `hierarchy.i_gem_mac.i_gem_rx.frame_length;
    assign final_eop_push               = `hierarchy.i_gem_mac.i_gem_rx.final_eop_push;
    assign queue_pointer                = `hierarchy.i_gem_mac.i_gem_rx.queue_ptr_rx;
    assign limit_frames_size_rx_clk     = `hierarchy.i_gem_mac.i_gem_rx.i_gem_rx_per_queue_flush.limit_frames_size_rx_clk;
    assign max_val_pclk                 = `hierarchy.i_gem_mac.i_gem_rx.i_gem_rx_per_queue_flush.max_val_pclk;

    parameter [1:0] max_loop = (`edma_queues == 1)? 2'd1: 2'd2;

  `ifdef ABV_ON
    // All these assertions will be generated only for the first 2 queues of the design.
    // Check that all new frames that are received after drop_all_frames is set
    // are dropped.
    genvar i_mode0;
    generate for (i_mode0=0; i_mode0<max_loop; i_mode0=i_mode0+1) begin: assertion_drop_all_frames_loop
      property check_mode0;

      @(posedge rx_clk)
        (drop_all_frames_rx_clk[i_mode0] && (queue_pointer == i_mode0) & rx_w_eop) |-> rx_w_err;
      endproperty
      assert_check_mode0 : assert property (check_mode0);
    end
    endgenerate

    // Check that the packets are dropped with respect to the programmed rules
    // So the check will prove that, if the core has detected a max_val breach for that mode,
    // and if that mode has been enabled and is considered active then the frame will be errored
    genvar i_mode3;
    generate for(i_mode3=0; i_mode3<max_loop; i_mode3=i_mode3+1) begin: gen_mode3_assertion_loop
      property check_mode3;

      @(posedge rx_clk)
        ((queue_pointer == i_mode3) &
         (frame_length > max_val_pclk[(15+(16*i_mode3)):(16*i_mode3)]) & limit_frames_size_rx_clk[i_mode3] &
          final_eop_push)
          |-> (##1 rx_w_err);

      endproperty
      assert_check_mode3 : assert property (check_mode3);

    end
    endgenerate
  `endif

  // -----------------------------------------------------------------------
  //
  //          FC for per-queue receive flush Mode0 and Mode3 functionality
  //
  // -----------------------------------------------------------------------
  // All these items will be generated only for the first 2 queues of the design.

  genvar a;
  generate for(a=0; a<max_loop; a=a+1) begin: gen_frame_rxd
    always @ (*)
    begin
      if((queue_pointer == a) && rx_w_eop)
        frame_rxd_q[a] = 1'b1;
      else
        frame_rxd_q[a] = 1'b0;
    end
  end
  endgenerate

  genvar i;
  generate for(i=0; i<max_loop; i=i+1) begin: gen_fc_mode0_n_3

    `define CP_MODE3 \
      cp_mode3 : coverpoint limit_frames_size_rx_clk[i] { \
        bins mode3_off = {0}; \
        bins mode3_on  = {1}; \
      }

    `define CP_MODE3_MAX_VAL \
      cp_mode3_max_val: coverpoint max_val_pclk[15+(i*16):(i*16)] { \
        bins max_val_1_749    ={[1:749]}; \
        bins max_val_750_1k5  ={[750:1499]}; \
        bins max_val_great_1k5={[1500:$]}; \
      }

    `define CP_MODE0 \
      cp_mode0 : coverpoint drop_all_frames_rx_clk[i] { \
        bins mode0_off = {0}; \
        bins mode0_on  = {1}; \
      }

    // Cover Mode3 set/unset on a frame rcvd for that queue
    covergroup cg_mode3 @(posedge frame_rxd_q[i]);

       option.per_instance = 1;
      `CP_MODE3

    endgroup
    cg_mode3 i_cg_mode3 = new();

    // Cover mode3 set with the range of max_val
    covergroup cg_mode3_max_val  @(posedge frame_rxd_q[i] && limit_frames_size_rx_clk[i]);

       option.per_instance = 1;
      `CP_MODE3_MAX_VAL

    endgroup
    cg_mode3_max_val i_cg_mode3_max_val = new();

    // Cover mode0 is set and unset when receiving a frame for that queue
    covergroup cg_mode0 @(posedge frame_rxd_q[i]);

     option.per_instance = 1;
    `CP_MODE0

    endgroup
    cg_mode0 i_cg_mode0 = new();

  end
  endgenerate

  // -----------------------------------------------------------------------
  //
  //           Assertion proving the queue independence for the
  //           per-queue rx flush mechanism
  //
  // -----------------------------------------------------------------------
  // So basically we want to monitor the Mode0, Mode1, Mode2 and Mode3 enable
  // signals at the input of the module that implementes this functionality and
  // everytime we see that one of the bit has changed we want to make sure this
  // comes from the correct bit in the register block.
  // Note that Mode2 and Mode3 can't work together so the signal called
  // limit_num_bytes_allowed_ambaclk has been ANDed with the Mode3 enable signal
  // in the pclk domain, therefore that signal is 1 only if Mode2 is enabled and Mode3 is not.
  // Similarly, for this check, the enable_array_pclk is considered with this condition on
  // the bit2: this will not considered set unless Mode3 is unset and Mode2 is set.

  wire [`edma_queues-1:0] drop_all_frames_pclk;        // Mode0 enable vector at register block level
  wire [`edma_queues-1:0] force_discard_on_err_q_pclk; // Mode1 enable vector at register block level
  wire [`edma_queues-1:0] limit_num_bytes_pclk;        // Mode2 enable vector at register block level
  wire [`edma_queues-1:0] limit_frames_size_pclk;      // Mode3 enable vector at register block level

  wire [3:0] enable_array_pclk     [15:0]; // Enable array at register block level
  wire [3:0] enable_array_core     [15:0]; // Enable array at core level
  wire [3:0] enable_array_core_del [15:0]; // Registered version of the above

  genvar b;
  genvar nb;
  generate for (b=0; b<`edma_queues; b=b+1) begin: gen_queue_indep_assert_build
    reg  [3:0] enable_array_core_r;

    // We will only probe the enables for the Mode1 and Mode2 if in pkt_buffer mode (and it will depend if axi or ahb)
    // otherwise they will be tied to zero. otherwise a compilation error will occur because there will be no DMA
    `ifdef edma_tx_pkt_buffer
      `ifdef edma_axi
        assign force_discard_on_err_q_ambaclk[b] = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.force_discard_on_err_q[b];
        assign limit_num_bytes_allowed_ambaclk[b]= `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.limit_num_bytes_allowed_ambaclk[b];
      `else
        assign force_discard_on_err_q_ambaclk[b] = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.force_discard_on_err_q[b];
        assign limit_num_bytes_allowed_ambaclk[b]= `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.limit_num_bytes_allowed_ambaclk[b];
      `endif
    `else
      assign force_discard_on_err_q_ambaclk[b]  = 1'b0;
      assign limit_num_bytes_allowed_ambaclk[b] = 1'b0;
    `endif

    assign drop_all_frames_pclk[b]        = `hierarchy.i_gem_reg_top.i_gem_registers.rx_q_flush[32*b];
    assign force_discard_on_err_q_pclk[b] = `hierarchy.i_gem_reg_top.i_gem_registers.rx_q_flush[(32*b)+1];
    assign limit_num_bytes_pclk[b]        = `hierarchy.i_gem_reg_top.i_gem_registers.rx_q_flush[(32*b)+2];
    assign limit_frames_size_pclk[b]      = `hierarchy.i_gem_reg_top.i_gem_registers.rx_q_flush[(32*b)+3];

    assign enable_array_pclk[b] = {limit_frames_size_pclk[b],  limit_num_bytes_pclk[b] && ~limit_frames_size_pclk[b], force_discard_on_err_q_pclk[b],   drop_all_frames_pclk[b]};
    assign enable_array_core[b] = {limit_frames_size_rx_clk[b],limit_num_bytes_allowed_ambaclk[b],                    force_discard_on_err_q_ambaclk[b],drop_all_frames_rx_clk[b]};

    always @ (posedge rx_clk or negedge n_rxreset)
    begin
      if(~n_rxreset)
        enable_array_core_r <= 4'd0;
      else
        enable_array_core_r <= enable_array_core[b];
    end
    assign enable_array_core_del[b] = enable_array_core_r;
  end

  if(`edma_queues <16) begin: gen_remain_queue_indep_assert_build
    for(nb=`edma_queues; nb<16; nb=nb+1) begin: gen_loop
      assign enable_array_core_del[nb] = 4'd0;
      assign enable_array_core[nb]     = 4'd0;
      assign enable_array_pclk[nb]     = 4'd0;
    end
  end

  endgenerate

  // if one of the Modes enable is changed for that queue go and make sure that the correspondant
  // bits in the registers block is changed as well. The assertions must be outside the for because
  // they have to be mapped into the VPLAN from the per_type view.
  // Now, the enable_array_pclk vector contains some bits that will be sync-ed to the rx_clk domain and others
  // that will be sync-ed to the ambaclk domain, meaning that the enable_array_core vector is composed by component
  // sync-ed in rx_clk and others sync-ed in ambaclk,
  // so if the test will write simultaneously both the bits being sync-ed to the rx_clk and those to be sync-ed in the
  // ambaclk domain an issue might occur:
  // In fact, it might happen that if ambaclk is faster than rx_clk (as an example), the ambaclk elements might
  // update before the elements in rx_clk and this would mean that the assertion will fail because
  // it won't match the enable_array_pclk. But this would be a false fail because the check only needs to wait
  // for the values on the rx_clk to be updated as well. For this reason we give 3 clock cycles time for the check
  // to be validated, so the value will be updated also for the elements rx_clk sync-ed and the assertion
  // will pass. 3 clock cycle is an empirical value that showed to work, if new tests with different clock relationships
  // will be introduced this number might need to be updated.
  property queues_independent_q0;  @(posedge rx_clk) (enable_array_core_del[0] != enable_array_core[0] ) |-> (## [0:2] enable_array_core[0]  == enable_array_pclk[0] ); endproperty assert_queues_independent_q0 :assert property (queues_independent_q0 );
  property queues_independent_q1;  @(posedge rx_clk) (enable_array_core_del[1] != enable_array_core[1] ) |-> (## [0:2] enable_array_core[1]  == enable_array_pclk[1] ); endproperty assert_queues_independent_q1 :assert property (queues_independent_q1 );
  property queues_independent_q2;  @(posedge rx_clk) (enable_array_core_del[2] != enable_array_core[2] ) |-> (## [0:2] enable_array_core[2]  == enable_array_pclk[2] ); endproperty assert_queues_independent_q2 :assert property (queues_independent_q2 );
  property queues_independent_q3;  @(posedge rx_clk) (enable_array_core_del[3] != enable_array_core[3] ) |-> (## [0:2] enable_array_core[3]  == enable_array_pclk[3] ); endproperty assert_queues_independent_q3 :assert property (queues_independent_q3 );
  property queues_independent_q4;  @(posedge rx_clk) (enable_array_core_del[4] != enable_array_core[4] ) |-> (## [0:2] enable_array_core[4]  == enable_array_pclk[4] ); endproperty assert_queues_independent_q4 :assert property (queues_independent_q4 );
  property queues_independent_q5;  @(posedge rx_clk) (enable_array_core_del[5] != enable_array_core[5] ) |-> (## [0:2] enable_array_core[5]  == enable_array_pclk[5] ); endproperty assert_queues_independent_q5 :assert property (queues_independent_q5 );
  property queues_independent_q6;  @(posedge rx_clk) (enable_array_core_del[6] != enable_array_core[6] ) |-> (## [0:2] enable_array_core[6]  == enable_array_pclk[6] ); endproperty assert_queues_independent_q6 :assert property (queues_independent_q6 );
  property queues_independent_q7;  @(posedge rx_clk) (enable_array_core_del[7] != enable_array_core[7] ) |-> (## [0:2] enable_array_core[7]  == enable_array_pclk[7] ); endproperty assert_queues_independent_q7 :assert property (queues_independent_q7 );
  property queues_independent_q8;  @(posedge rx_clk) (enable_array_core_del[8] != enable_array_core[8] ) |-> (## [0:2] enable_array_core[8]  == enable_array_pclk[8] ); endproperty assert_queues_independent_q8 :assert property (queues_independent_q8 );
  property queues_independent_q9;  @(posedge rx_clk) (enable_array_core_del[9] != enable_array_core[9] ) |-> (## [0:2] enable_array_core[9]  == enable_array_pclk[9] ); endproperty assert_queues_independent_q9 :assert property (queues_independent_q9 );
  property queues_independent_q10; @(posedge rx_clk) (enable_array_core_del[10]!= enable_array_core[10]) |-> (## [0:2] enable_array_core[10] == enable_array_pclk[10]); endproperty assert_queues_independent_q10:assert property (queues_independent_q10);
  property queues_independent_q11; @(posedge rx_clk) (enable_array_core_del[11]!= enable_array_core[11]) |-> (## [0:2] enable_array_core[11] == enable_array_pclk[11]); endproperty assert_queues_independent_q11:assert property (queues_independent_q11);
  property queues_independent_q12; @(posedge rx_clk) (enable_array_core_del[12]!= enable_array_core[12]) |-> (## [0:2] enable_array_core[12] == enable_array_pclk[12]); endproperty assert_queues_independent_q12:assert property (queues_independent_q12);
  property queues_independent_q13; @(posedge rx_clk) (enable_array_core_del[13]!= enable_array_core[13]) |-> (## [0:2] enable_array_core[13] == enable_array_pclk[13]); endproperty assert_queues_independent_q13:assert property (queues_independent_q13);
  property queues_independent_q14; @(posedge rx_clk) (enable_array_core_del[14]!= enable_array_core[14]) |-> (## [0:2] enable_array_core[14] == enable_array_pclk[14]); endproperty assert_queues_independent_q14:assert property (queues_independent_q14);
  property queues_independent_q15; @(posedge rx_clk) (enable_array_core_del[15]!= enable_array_core[15]) |-> (## [0:2] enable_array_core[15] == enable_array_pclk[15]); endproperty assert_queues_independent_q15:assert property (queues_independent_q15);

  // -----------------------------------------------------------------------
  //
  //          Enhancement for Scheduled Traffic (EnST) Assertions
  //
  // -----------------------------------------------------------------------
  `ifdef gem_tx_pkt_buffer
    `define pkt_buff_or_fifo
  `else
    `ifdef gem_ext_fifo_interface
       `define pkt_buff_or_fifo
    `endif
  `endif

  `ifdef pkt_buff_or_fifo
    `ifndef gem_exclude_qbv
      // Mapping signals from the module gem_tx_fifo_if
      // Declaring also some signals used internally for the
      // Assertions
      wire                          tx_clk;
      wire                          n_txreset;
      wire                          tsu_clk;
      wire                          n_tsureset;
      wire                  [255:0] start_time;
      wire                    [7:0] enst_en;
      wire                  [135:0] on_time;
      wire                  [135:0] off_time;
      wire  [(19*`edma_queues)-1:0] byte_count;
      wire       [`edma_queues-1:0] gatestate_vec;
      wire                  [93:16] tsu_timer_cnt;
      wire                          bit_rate;
      wire                          two_pt_five_gig;
      wire                          enst_gigabit;
      reg                     [1:0] counter;
      reg                           valid_reset_n;
      wire       [`edma_queues-1:0] start_time_is0;
      wire                          one_start_time_is0;
      reg        [`edma_queues-1:0] gate_closing;
      reg        [`edma_queues-1:0] gatestate_reg;
      reg        [`edma_queues-1:0] in_range;
      reg        [`edma_queues-1:0] valid_gatestate_a;
      reg        [`edma_queues-1:0] valid_gatestate_b;
      reg                     [6:0] recipr_rate;
      reg                    [31:0] gate_rise_time        [`edma_queues-1:0];
      reg                    [31:0] gate_fall_time        [`edma_queues-1:0];
      reg                    [19:0] calculated_on_time    [`edma_queues-1:0];
      reg                    [19:0] max_limit             [`edma_queues-1:0];
      reg                    [19:0] min_limit             [`edma_queues-1:0];
      reg                    [31:0] gate_rise_time_2      [`edma_queues-1:0];
      reg                    [31:0] gate_rise_time_2_prev [`edma_queues-1:0];
      reg                    [19:0] max_limit_2           [`edma_queues-1:0];
      reg                    [19:0] min_limit_2           [`edma_queues-1:0];
      reg                    [19:0] theoric_period        [`edma_queues-1:0];
      reg                    [19:0] calculated_period     [`edma_queues-1:0];
      reg        [`edma_queues-1:0] in_range_2;
      reg        [`edma_queues-1:0] toggle;
      reg        [`edma_queues-1:0] toggle_reg;
      reg        [`edma_queues-1:0] pulse;
      reg        [`edma_queues-1:0] gatestate_a_reg, pulse_a;
      reg        [`edma_queues-1:`edma_queues-8] gatestate_b_reg, pulse_b;
      reg                                        gatestate_ok;
      wire       [`edma_queues-1:0] gatestate_to_sched;

      assign tx_clk          = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.tx_clk;
      assign n_txreset       = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.n_txreset;
      assign tsu_clk         = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.tsu_clk;
      assign n_tsureset      = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.n_tsureset;
      assign start_time      = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.start_time;
      assign enst_en         = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.enst_en;
      assign on_time         = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.on_time;
      assign off_time        = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.off_time;
      assign gatestate_to_sched = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.gatestate_to_sched;
      assign tsu_timer_cnt      = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.tsu_timer_cnt;
      assign bit_rate           = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.bit_rate;
      assign two_pt_five_gig    = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.two_pt_five_gig;
      assign enst_gigabit       = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.gigabit;

      generate if(`edma_queues <9) begin: gen_less_8
        assign byte_count      = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.gen_enst_module.gen_enst1.byte_count_tx;
        assign gatestate_vec   = `hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.gen_enst_module.gen_enst1.gatestate_tx;
      end else begin: gen_more_8
        assign byte_count      = {`hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.gen_enst_module.gen_enst2.int_byte_count_tx, {(((`edma_queues-8)*19)){1'b1}}};
        assign gatestate_vec   = {`hierarchy.i_gem_mac.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.gen_enst_module.gen_enst2.int_gatestate_tx,  {((`edma_queues-8)){1'b1}}};
      end
      endgenerate

      //The Stand Alone tests have a high reset pulse and then a low reset again and then an high pulse again,
      //in which the IP is being stimulated. We don't want to consider the first pulse as after that the reset
      //would be still low again. So I created a signal called valid_reset_n that is equal to the n_txreset
      //only if it lasts for more than 2 clock cycles.
      always @ (posedge tx_clk)
      begin
        if (~n_txreset)
          begin
            counter     <= 2'd0;
            valid_reset_n <= 0;
          end
        else
          begin
            if(counter == 2'b10)
              begin
                valid_reset_n <= 1'b1;
                counter       <= 2'd0;
              end
            else
              begin
                if(~valid_reset_n)
                  begin
                    counter       <= counter + 2'd1;
                    valid_reset_n <= 0;
                  end
                else
                  begin
                    counter       <= 2'd0;
                    valid_reset_n <= 1;
                  end
              end
          end
      end

      always @ *
      begin
        if(two_pt_five_gig || enst_gigabit)
          recipr_rate = 7'd1;
        else if (bit_rate) //100Mbps
          recipr_rate = 7'd10;
        else //10Mbps
          recipr_rate = 7'd100;
      end

      // In this first section there will be some logic
      // which calculates some support signals for the assertions.
      assign one_start_time_is0 = |start_time_is0;

      genvar m1,m2,m3,k1,k2;
      generate if(`edma_queues<9) begin : gen_enst_support_8_q_or_less

        always @ *
        begin
          if((gatestate_vec[`edma_queues-1:0] == 0)  ||
             (gatestate_vec[`edma_queues-1:0] == 1)  ||
             (gatestate_vec[`edma_queues-1:0] == 2)  ||
             (gatestate_vec[`edma_queues-1:0] == 4)  ||
             (gatestate_vec[`edma_queues-1:0] == 6)  ||
             (gatestate_vec[`edma_queues-1:0] == 8)  ||
             (gatestate_vec[`edma_queues-1:0] == 16) ||
             (gatestate_vec[`edma_queues-1:0] == 32) ||
             (gatestate_vec[`edma_queues-1:0] == 64) ||
             (gatestate_vec[`edma_queues-1:0] == 128))
            gatestate_ok = 1;
          else
            gatestate_ok = 0;
        end

        for(m1=0; m1<`edma_queues; m1=m1+1)
        begin : gen_q_loop
          assign start_time_is0[m1] = (start_time[(31+(32*m1)):(32*m1)] == 32'd0);

          always @ (posedge tx_clk or negedge n_txreset)
          begin
            if(~n_txreset)
              gatestate_a_reg[m1] <= 1'b0;
            else
              gatestate_a_reg[m1] <= gatestate_vec[m1];
          end

          always @ (*) pulse_a[m1] = ~gatestate_a_reg[m1] & gatestate_vec[m1];

          always @ *
          begin
            if(start_time[(31+(32*m1)):(32*m1)] == 32'd0)
              valid_gatestate_a[m1] = 0;
            else
            begin
              if(tsu_timer_cnt[47:16] > start_time[(31+(32*m1)):(32*m1)] && enst_en[m1])
                valid_gatestate_a[m1] = gatestate_vec[m1];
              else
                valid_gatestate_a[m1] = 0;
            end
          end

          always @ (posedge valid_gatestate_a[m1]) gate_rise_time[m1][31:0] <= $time;
          always @ (negedge valid_gatestate_a[m1]) gate_fall_time[m1][31:0] <= $time;

          always @ (posedge tx_clk or negedge n_txreset)
          begin
            if(~n_txreset)
              gatestate_reg[m1] <= 1'b0;
            else
              gatestate_reg[m1] <= gatestate_vec[m1];
          end

          always @ *
          begin
            gate_closing      [m1]       = gatestate_reg[m1] & ~gatestate_vec[m1];
            max_limit         [m1][19:0] = (8*recipr_rate*on_time[(16+(17*m1)):(17*m1)] + 20'd300);
            min_limit         [m1][19:0] = (8*recipr_rate*on_time[(16+(17*m1)):(17*m1)] - 20'd300);
            calculated_on_time[m1][19:0] = (gate_fall_time[m1][31:0] - gate_rise_time[m1][31:0]);
          end

          always@ *
          begin
            //We check that the period in which the gate is open is in a certain range around the value that has been set in the register.
            if((calculated_on_time[m1] <= max_limit[m1]) && (calculated_on_time[m1] >= min_limit[m1]))
              in_range[m1] = 1;
            else
              in_range[m1] = 0;
          end

          always @ (posedge valid_gatestate_a[m1])
          begin
            gate_rise_time_2     [m1][31:0] <= $time;
            gate_rise_time_2_prev[m1][31:0] <= gate_rise_time_2[m1][31:0];
          end

          always @ (gate_rise_time_2_prev[m1][31:0] or negedge n_txreset)
          begin
            if(~n_txreset)
              toggle[m1] <= 1'b0;
            else
              toggle[m1] <= ~toggle[m1];
          end

          always @ (posedge tx_clk or negedge n_txreset)
          begin
            if(~n_txreset)
              toggle_reg[m1] <= 0;
            else
              toggle_reg[m1] <= toggle[m1];
          end

          always @ *
          begin
            pulse            [m1]       = toggle_reg[m1] ^ toggle[m1];
            calculated_period[m1]       = gate_rise_time_2[m1][31:0] - gate_rise_time_2_prev[m1][31:0];
            theoric_period   [m1]       = (8*recipr_rate*on_time[(16+(17*m1)):(17*m1)]) + (8*recipr_rate*off_time[(16+(17*m1)):(17*m1)]);
            max_limit_2      [m1][19:0] = (theoric_period[m1] + 20'd300);
            min_limit_2      [m1][19:0] = (theoric_period[m1] - 20'd300);
          end

          always@ *
          begin
            if((calculated_period[m1] <= max_limit_2[m1]) && (calculated_period[m1] >= min_limit_2[m1]))
              in_range_2[m1] = 1;
            else
              in_range_2[m1] = 0;
          end

        end
      end
      else if(`edma_queues >8) begin : gen_enst_support_more_than_8_q

        always @ *
        begin
          if((gatestate_vec[`edma_queues-1:`edma_queues-8] == 0)  ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 1)  ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 2)  ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 4)  ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 6)  ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 8)  ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 16) ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 32) ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 64) ||
             (gatestate_vec[`edma_queues-1:`edma_queues-8] == 128))
             gatestate_ok = 1;
          else
            gatestate_ok = 0;
        end

        for(m2=`edma_queues-8; m2<`edma_queues; m2=m2+1)
        begin : gen_q_loop
          assign start_time_is0[m2] = (start_time[(31+(32*(m2-`edma_queues+8))):(32*(m2-`edma_queues+8))] == 32'd0);

          always @ (posedge tx_clk or negedge n_txreset)
          begin
            if(~n_txreset)
              gatestate_b_reg[m2] <= 1'b0;
            else
              gatestate_b_reg[m2] <= gatestate_vec[m2];
          end

          always @ (*)
          begin
            pulse_b[m2] = ~gatestate_b_reg[m2] & gatestate_vec[m2];
          end

          always @ *
          begin
            if(start_time[(31+(32*(m2-`edma_queues+8))):(32*(m2-`edma_queues+8))] == 32'd0)
              valid_gatestate_b[m2] = 0;
            else
            begin
              if(tsu_timer_cnt[47:16] > start_time[(31+(32*(m2-`edma_queues+8))):(32*(m2-`edma_queues+8))] && enst_en[m2-`edma_queues+8])
                valid_gatestate_b[m2] = gatestate_vec[m2];
              else
                valid_gatestate_b[m2] = 0;
            end
          end

          always @ (posedge valid_gatestate_b[m2]) gate_rise_time[m2][31:0] <= $time;
          always @ (negedge valid_gatestate_b[m2]) gate_fall_time[m2][31:0] <= $time;

          always @ (posedge tx_clk or negedge n_txreset)
          begin
            if(~n_txreset)
              gatestate_reg[m2] <= 1'b0;
            else
              gatestate_reg[m2] <= gatestate_vec[m2];
          end

          always @ *
          begin
            gate_closing      [m2]       = gatestate_reg[m2] & ~gatestate[m2];
            max_limit         [m2][19:0] = (8*recipr_rate*on_time[(16+(17*(m2-`edma_queues+8))):(17*(m2-`edma_queues+8))] + 20'd100);
            min_limit         [m2][19:0] = (8*recipr_rate*on_time[(16+(17*(m2-`edma_queues+8))):(17*(m2-`edma_queues+8))] - 20'd100);
            calculated_on_time[m2][19:0] = (gate_fall_time[m2][31:0] - gate_rise_time[m2][31:0]);
          end

          always@*
          begin
            //We check that the period in which the gate is open is in a certain range around the value that has been set in the register.
            if((calculated_on_time[m2] <= max_limit[m2]) && (calculated_on_time[m2] >= min_limit[m2]))
              in_range[m2] = 1;
            else
              in_range[m2] = 0;
          end

          always @ (posedge valid_gatestate_b[m2])
          begin
            gate_rise_time_2     [m2][31:0] <= $time;
            gate_rise_time_2_prev[m2][31:0] <= gate_rise_time_2[m2][31:0];
          end

          always @ (posedge tx_clk or negedge n_txreset)
          begin
            if(~n_txreset)
              toggle_reg[m2] <= 0;
            else
              toggle_reg[m2] <= toggle[m2];
          end

          always @ (gate_rise_time_2_prev[m2][31:0] or negedge n_txreset)
          begin
            if(~n_txreset)
              toggle[m2] <= 1'b0;
            else
              toggle[m2] <= ~toggle[m2];
          end

          always @ *
          begin
            pulse            [m2]       = toggle_reg[m2] ^ toggle[m2];
            calculated_period[m2]       = gate_rise_time_2[m2][31:0] - gate_rise_time_2_prev[m2][31:0];
            theoric_period   [m2]       = (8*recipr_rate*on_time[(16+(17*(m2-`edma_queues+8))):(17*(m2-`edma_queues+8))]) + (8*recipr_rate*off_time[(16+(17*(m2-`edma_queues+8))):(17*(m2-`edma_queues+8))]);
            max_limit_2      [m2][19:0] = (theoric_period[m2] + 20'd100);
            min_limit_2      [m2][19:0] = (theoric_period[m2] - 20'd100);
          end

          always@*
          begin
            if((calculated_period[m2] <= max_limit_2[m2]) && (calculated_period[m2] >= min_limit_2[m2]))
              in_range_2[m2] = 1;
            else
              in_range_2[m2] = 0;
          end

        end

        // Set to zero all the other start_time_is0 for the queues EnST doesn't apply to
        for(m3=0; m3<`edma_queues-8; m3=m3+1) begin: gen_q_no_enst
          assign start_time_is0[m3] = 1'b0;
        end

      end
      endgenerate

      `ifdef ABV_ON
        generate if(`edma_queues<9) begin: gen_enst_ass_8
          for(k1=0; k1<`edma_queues; k1=k1+1)
          begin : gen_loop
            // Core Features/1.1.1: Queeus that haven't EnST enabled can transmit when there is a frame available for transmission.(q<9)
            property Pr_111;
            @(posedge tx_clk)
              (!enst_en[k1] && valid_reset_n) |-> (##[0:25] gatestate_vec[k1] == 1);
            endproperty
            AP_Pr_111 : assert property (Pr_111);

            // Core Features/1.1.3 if disabled queue, the bytecount must be all ones (q<9)
            property Pr_113;
            @(posedge tx_clk)
              (!enst_en[k1] && valid_reset_n) |-> ( ##[0:25] byte_count[((19*k1)+18):(19*k1)] == 19'h7FFFF);
            endproperty
            AP_Pr_113 : assert property (Pr_113);

            // Core Features/1.1.6 Bytecount action time: byte_count has to decrement only during the on_time slot (q<9)
            // We will verify that after and before the gatestate_vec the bytecounter is zero. This means that the bytecounter is only decrementing in the on_time:
            property Pr_116;
            @(posedge tx_clk)
              ((!gatestate_vec[k1])  && (enst_en[k1]) && (tsu_timer_cnt[47:16] >  start_time[(31+(32*k1)):(32*k1)])) |->  byte_count[(18+(19*k1)):(19*k1)]== 19'd0;
            endproperty
            AP_Pr_116 : assert property (Pr_116);

            // Core Features/1.1.8 Bytecount starting value (q<9): Make sure the starting value of byte_count is exactly what has been set in the register "on_time"
            // if 1Gbps, 100Mpbs, 10Mps, while it must be 2,5*on_time if 2.5Gbps.
            property Pr_118;
            @(posedge(tx_clk))
              (pulse_a[k1] && (enst_en[k1]) && (tsu_timer_cnt[47:16] >  start_time[(31+(32*k1)):(32*k1)]) ) |-> ( ##[0:1] byte_count[(18+(19*k1)) : (19*k1)] == (1 + (two_pt_five_gig*1.5)) * on_time [(16+(17*k1)):(17*k1)] );
            endproperty
            AP_Pr_118 : assert property (Pr_118);

            // Core Features/1.1.10 Non overlapping gatestates (q<9): Verify that two or more queues can't have their gates open at the same time, exception made for the case in which they all receive a enst_en = 0.
            property Pr_1110;
            @(posedge(tsu_clk))
              (!one_start_time_is0 && gatestate_vec[k1] && enst_en[k1] && (tsu_timer_cnt[47:16] >  start_time[(31+(32*k1)):(32*k1)]) ) |-> (##[0:5] gatestate_ok == 1);
            endproperty
            AP_Pr_1110 : assert property (Pr_1110);

            // Timings 1.1.12.5 Queue active time (q<9): Check the on_time matches the queue enable time.
            property Pr_11125;
            @(negedge gate_closing[k1])
              ((!one_start_time_is0) && (enst_en[k1]) && (tsu_timer_cnt[47:16] > start_time[(31+(32*k1)):(32*k1)])) |-> (in_range[k1] == 1);
            endproperty
            AP_Pr_11125 : assert property (Pr_11125);

            // Timings 1.1.12.7 Periodic Operation (q<9): Verify that the gatestate_vec is toggling between '1' and '0' with period on_time + off_time.
            property Pr_11127;
            @(negedge pulse[k1])
              ((enst_en[k1]) && (tsu_timer_cnt[47:16] > start_time[(31+(32*k1)):(32*k1)]) && gatestate_ok) |-> (in_range_2[k1] == 1) ;
            endproperty
            AP_Pr_11127 : assert property (Pr_11127);

            // Timings 1.1.12.1 Check that the queue is not enabled until tsu_time >= start_time
            property Pr_11121;
            @(posedge tsu_clk)
              (valid_gatestate_a[k1] && enst_en[k1] && valid_reset_n) |-> (tsu_timer_cnt[47:16] > start_time[(31+(32*k1)):(32*k1)]);
            endproperty
            AP_Pr_11121 : assert property (Pr_11121);
          end
        end
        else if(`edma_queues > 8) begin: gen_enst_ass_more_than_8
          for(k2=`edma_queues-8; k2<`edma_queues; k2=k2+1) begin
            // Core Features/1.1.2: Queeus that haven't EnST enabled can transmit when there is a frame available for transmission.(q>8)
            property Pr_112;
            @(posedge tx_clk)
              (!enst_en[k2-`edma_queues+8] && valid_reset_n) |-> (##[0:25] gatestate_vec[k2] == 1);
            endproperty
            AP_Pr_112 : assert property (Pr_112);

            // Core Features/1.1.4 if disabled queue, the bytecount must be all ones (q>8)
            property Pr_114;
            @(posedge tx_clk)
              (!enst_en[k2-`edma_queues+8] && valid_reset_n) |-> ( ##[0:25] byte_count[(18+(19*k2)):(19*k2)] == 19'h7FFFF);
            endproperty
            AP_Pr_114 : assert property (Pr_114);

            // Core Features/1.1.7 Bytecount action time: byte_count has to decrement only during the on_time slot (q>8)
            // We will verify that after and before the gatestate_vec the bytecounter is zero. This means that the bytecounter is only decrementing in the on_time:
            property Pr_117;
            @(posedge tx_clk)
              (!one_start_time_is0 && (!gatestate_vec[k2])  && (enst_en[k2-`edma_queues+8]) && (tsu_timer_cnt[47:16] > start_time[(31+(32*(k2-`edma_queues+8))):(32*(k2-`edma_queues+8))]))|->  byte_count[(18+(19*k2)):(19*(k2))]== 19'd0;
            endproperty
            AP_Pr_117 : assert property (Pr_117);

            // Core Features/1.1.9 Bytecount starting value (q>8): Make sure the starting value of byte_count is exactly what has been set in the register "on_time"
            // if 1Gbps, 100Mpbs, 10Mps, while it must be 2,5*on_time if 2.5Gbps.
            property Pr_119;
            @(posedge(tx_clk))
              (!one_start_time_is0 && pulse_b[k2] && (enst_en[k2-`edma_queues+8]) && (tsu_timer_cnt[47:16] >  start_time[(31+(32*(k2-`edma_queues+8))):(32*(k2-`edma_queues+8))])) |-> ( ##[0:1] byte_count[(18+(19*k2)):(19*k2)] == (1 + (two_pt_five_gig*1.5)) * on_time [(16+(17*(k2-`edma_queues+8))):(17*(k2-`edma_queues+8))]);
            endproperty
            AP_Pr_119 : assert property (Pr_119);

            // Core Features/1.1.11 Non overlapping gatestates (q>8): Verify that two or more queues can't have their gates open at the same time, exception made for the case in which they all receive a enst_en = 0.
            property Pr_1111;
            @(posedge(tsu_clk))
              (!one_start_time_is0 && gatestate_vec[k2] && enst_en[k2-`edma_queues+8] && (tsu_timer_cnt[47:16] >  start_time[(31+(32*(k2-`edma_queues+8))):(32*(k2-`edma_queues+8))]) ) |-> (##[0:5] gatestate_ok == 1);
            endproperty
            AP_Pr_1111 : assert property (Pr_1111);

            // Timings 1.1.12.6 Queue active time (q>8): Check the on_time matches the queue enable time.
            property Pr_11126;
            @(negedge gate_closing[k2])
              ((!one_start_time_is0) && (enst_en[k2-`edma_queues+8]) && (tsu_timer_cnt[47:16] > start_time[(31+(32*(k2-`edma_queues+8))):(32*(k2-`edma_queues+8))])) |-> (in_range[k2] == 1) ;
            endproperty
            AP_Pr_11126 : assert property (Pr_11126);

            // Timings 1.1.12.8 Periodic Operation (q>8): Verify that the gatestate_vec is toggling between '1' and '0' with period on_time + off_time.
            property Pr_11128;
            @(negedge pulse[k2])
              ((enst_en[k2-`edma_queues+8]) && (tsu_timer_cnt[47:16] > start_time[(31+(32*(k2-`edma_queues+8))):(32*(k2-`edma_queues+8))])) && gatestate_ok |-> (in_range_2[k2] == 1) ;
            endproperty
            AP_Pr_11128: assert property (Pr_11128);

            // Timings 1.1.12.2 :Start timer_1 (q>8): Check that the queue is not enabled until tsu_time >= start_time.if(p_edma_exclude_qbv == 0)
            property Pr_11122;
            @(posedge tsu_clk)
              (valid_gatestate_b[k2] && enst_en[k2-`edma_queues+8] && valid_reset_n) |-> (tsu_timer_cnt[47:16] > start_time[(31+(32*(k2-`edma_queues+8))):(32*(k2-`edma_queues+8))]);
            endproperty
            AP_Pr_11122 : assert property (Pr_11122);
          end // end for
          property Pr_115;
          @(posedge tx_clk)
             // I am actually checking that the gatestates of the LS queues are set to '1' when more than 8 queues, cause the EnST has been applied only on the MS queues.
            (`edma_queues > 8) |-> (gatestate_to_sched[`edma_queues-9:0] == {(`edma_queues-8){1'b1}});
          endproperty
          AP_Pr_115 : assert property (Pr_115);
        end // end if else ...
        endgenerate

      `endif // ABV_ON
    `endif
  `endif

  // -----------------------------------------------------------------------
  //
  //          802.3br Assertions
  //
  // -----------------------------------------------------------------------

  `ifdef gem_has_802p3_br

    // Mapping signals from the MMSL
    // Declaring also some signals used internally for the
    // Assertions
    wire  [1:0] pmac_rx_dv_pcs;
    wire        pmac_rx_dv;
    wire        pmac_rx_halt;
    wire        mmsl_tx_clk;
    wire        mmsl_n_txreset;
    wire  [2:0] v_state;
    wire  [2:0] v_state_pclk;
    wire        v_tx_en;
    wire        v_tx_rdy;
    wire        r_tx_en;
    wire        r_tx_rdy;
    wire        r_state;
    wire        pmac_tx_en;
    wire        emac_tx_rdy;
    wire        emac_tx_en;
    wire        preempt;
    wire [16:0] frag_size;
    wire        mmsl_tx_en;
    wire        p_allow;
    wire        preemptable_frag_size;
    wire        min_remain;
    wire        hold;
    wire        mmsl_mii;
    wire [16:0] frag_count_rx;
    wire [16:0] frag_count_tx;
    wire  [7:0] smd_error_count;
    wire  [7:0] ass_error_count;
    wire        frag_count_rx_td;
    wire        frag_count_tx_td;
    wire        smd_error_count_td;
    wire        ass_error_count_td;
    wire        read_registers;
    wire  [3:0] paddr;
    wire        pclk;
    wire        n_preset;
    reg   [1:0] pmac_rx_dv_check;
    wire        data_16;
    wire        data_8in16;
    wire        emac_tx_en_pulse_hi;
    wire        pmac_tx_en_pulse_hi;
    reg         emac_tx_en_del;
    reg         pmac_tx_en_del;
    reg  [16:0] mmsl_byte_count;
    reg         flag;
    reg         preempt_del;
    reg         hold_del;
    wire        preempt_pulse_hi;
    wire        hold_pulse_hi;
    reg  [16:0] frag_count_rx_del;
    reg  [16:0] frag_count_tx_del;
    reg  [7:0]  smd_error_count_del;
    reg  [7:0]  ass_error_count_del;

    assign pmac_rx_dv_pcs        = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.pmac_rx_dv_pcs;
    assign pmac_rx_dv            = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.pmac_rx_dv;
    assign pmac_rx_halt          = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.pmac_rx_halt;
    assign mmsl_tx_clk           = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.tx_clk;
    assign mmsl_n_txreset        = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.n_txreset;
    assign v_state               = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.v_state;
    assign v_state_pclk          = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.v_state_pclk;
    assign v_tx_en               = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.v_tx_en;
    assign v_tx_rdy              = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.v_tx_rdy;
    assign r_tx_en               = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.r_tx_en;
    assign r_tx_rdy              = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.r_tx_rdy;
    assign r_state               = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.r_state;
    assign pmac_tx_en            = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.pmac_tx_en;
    assign emac_tx_rdy           = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.emac_tx_rdy;
    assign emac_tx_en            = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.emac_tx_en;
    assign preempt               = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.preempt;
    assign frag_size             = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.frag_size;
    assign mmsl_tx_en            = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.tx_en;
    assign p_allow               = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.p_allow;
    assign preemptable_frag_size = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.preemptable_frag_size;
    assign min_remain            = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.min_remain;
    assign hold                  = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.hold;
    assign mmsl_mii              = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.mii;
    assign frag_count_rx         = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.frag_count_rx;
    assign frag_count_tx         = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.frag_count_tx;
    assign smd_error_count       = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.smd_error_count;
    assign ass_error_count       = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.ass_error_count;
    assign frag_count_rx_td      = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.frag_count_rx_td;
    assign frag_count_tx_td      = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.frag_count_tx_td;
    assign smd_error_count_td    = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.smd_error_count_td;
    assign ass_error_count_td    = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.ass_error_count_td;
    assign read_registers        = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.read_registers;
    assign paddr                 = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.paddr;
    assign pclk                  = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.pclk;
    assign n_preset              = `hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_reg.n_preset;

    parameter MMSL_ERR_STATS     = 4'h2;
    parameter MMSL_FRAG_COUNT_RX = 4'h4;
    parameter MMSL_FRAG_COUNT_TX = 4'h5;
    parameter SEND_VERIFY        = 3'b010;
    parameter SEND_RESPOND       = 1'b1;

    ///////////////////////////// Assertions //////////////////////////////////////////
    // The rx_br_halt_pipe signal should never be set during IPG, i.e.
    // when pmac_rx_dv_check is low.
    assign data_16    = (speed_mode[2:1] == 2'b11);
    assign data_8in16 = (speed_mode[3:1] == 3'b010);

    always @ *
    begin
     if(data_16 || data_8in16)
       pmac_rx_dv_check = pmac_rx_dv_pcs;
     else
       pmac_rx_dv_check = {1'b0, pmac_rx_dv};
    end

    `ifdef ABV_ON
       property rx_br_halt_not_ipg;
         @(posedge rx_clk) disable iff (n_rxreset != 1'b1)
           ~(pmac_rx_halt && (pmac_rx_dv_check == 2'b00));
       endproperty
       AP_rx_br_halt_not_ipg : assert property (rx_br_halt_not_ipg);

       //check 4.5.4 check status registers show successful and failed verification
       property check_454_a;
         @(posedge mmsl_tx_clk)
         (v_state == 3'b100) |-> (##[0:20] v_state_pclk == 3'b100);
       endproperty
       assert_check_454_a: assert property (check_454_a);

       property check_454_b;
         @(posedge mmsl_tx_clk)
         (v_state == 3'b101) |-> (##[0:20] v_state_pclk == 3'b101);
       endproperty
       assert_check_454_b: assert property (check_454_b);

       property verify_causes_backpressure_prop;
       @(posedge mmsl_tx_clk)
         first_match(
               $rose(v_state == SEND_VERIFY) ##[0:$]
               (v_tx_en & v_tx_rdy)
           ) |=> (
               (~pmac_tx_rdy | ~pmac_tx_en) &
               (~emac_tx_rdy | ~emac_tx_en)
           )[*71];
       endproperty : verify_causes_backpressure_prop
       assert_verify_causes_backpressure: assert property (verify_causes_backpressure_prop);

       property respond_causes_backpressure_prop;
       @(posedge mmsl_tx_clk)
           first_match(
               $rose(r_state == SEND_RESPOND) ##[0:$]
               (r_tx_en & r_tx_rdy)
           ) |=> (
               (~pmac_tx_rdy | ~pmac_tx_en) &
               (~emac_tx_rdy | ~emac_tx_en)
           )[*71];
       endproperty : respond_causes_backpressure_prop
       assert_respond_causes_backpressure: assert property (respond_causes_backpressure_prop);

       // Assertion 4.4.5: check that the
       // length of a non-final fragment is at least
       // 64*(1+addfrag_size)-4
       reg [16:0] p_frag_size;

       always @ *
       begin
         case(add_frag_size)
           2'd0:     p_frag_size = 17'd120;
           2'd1:     p_frag_size = 17'd248;
           2'd2:     p_frag_size = 17'd376;
           default:  p_frag_size = 17'd504;
         endcase
       end

       property check_445;
       @(posedge mmsl_tx_clk)
         preempt |->  frag_size >= p_frag_size;
       endproperty
       assert_check_445 : assert property (check_445);

       // Assertion 4.4.3: prove the the eMAC is always
       // prioritised when there is data available
       // from both
       // We will check that, if emac_tx_en and pmac_tx_en
       // go to '1' in the same clock cycle then the eMAC
       // will have the priority.
       always @ (posedge mmsl_tx_clk or negedge mmsl_n_txreset)
       begin
         if(~mmsl_n_txreset)
           begin
             emac_tx_en_del <= 1'b0;
             pmac_tx_en_del <= 1'b0;
           end
         else
           begin
             emac_tx_en_del <= emac_tx_en;
             pmac_tx_en_del <= pmac_tx_en;
           end
       end

       assign emac_tx_en_pulse_hi = emac_tx_en && ~emac_tx_en_del;
       assign pmac_tx_en_pulse_hi = pmac_tx_en && ~pmac_tx_en_del;

       property check_443;
       @(posedge mmsl_tx_clk)
         (emac_tx_en_pulse_hi && pmac_tx_en_pulse_hi) |-> (##1 mmsl_tx_en == emac_tx_en);
       endproperty
       assert_check_443 : assert property (check_443);

       // Assertion 4.4.2.1: Cause of preemption
       // We will check that the preemption will
       // be allowed because of the hold signal (before emac_tx_en)
       // or because of emac_tx_en (without hold)
       // or if they are asserted together.(a simple OR, just the way is implemented).
       property check_4421;
       @(posedge mmsl_tx_clk)
         (p_allow && preemptable_frag_size && min_remain && (emac_tx_en || hold)) |-> (preempt == 1);
       endproperty
       assert_check_4421 : assert property (check_4421);

       // Assertion 4.4.2.5: check the number of bytes between hold high and tx_en low
       // doesn't exceed 64*(1+add_frag_size)-4
       // We will create a byte counter and check the number of bytes passing
       // between hold up and tx_en low.
       always @ (posedge mmsl_tx_clk or negedge mmsl_n_txreset)
       begin
         if(~mmsl_n_txreset)
           begin
             preempt_del <= 1'b0;
             hold_del    <= 1'b0;
           end
         else
           begin
             preempt_del <= preempt;
             hold_del    <= hold;
           end
       end

       assign preempt_pulse_hi = preempt && ~preempt_del;
       assign hold_pulse_hi    = hold    && ~hold_del;

       always @ (posedge mmsl_tx_clk or negedge mmsl_n_txreset)
       begin
         if(~mmsl_n_txreset)
           begin
             mmsl_byte_count <= 17'd0;
             flag            <= 1'b0;
           end
         else
           begin
             if(preempt_pulse_hi && hold_pulse_hi && mmsl_tx_en)
               begin
                 mmsl_byte_count <= (~mmsl_mii ? 17'd2: 17'd1);
                 flag            <= 1'b1;
               end
             else
               begin
                 if(~mmsl_tx_en)
                   begin
                     mmsl_byte_count <= mmsl_byte_count;
                     flag            <= 1'b0;
                   end
                 else if(flag)
                   mmsl_byte_count <= mmsl_byte_count + (~mmsl_mii ? 17'd2: 17'd1);
                 else
                   mmsl_byte_count <= 17'd0;
               end
           end
         end

       property check_4425;
       @(posedge mmsl_tx_clk)
         (flag && ~mmsl_tx_en) |-> (mmsl_byte_count <= p_frag_size);
       endproperty
       assert_check_4425 : assert property (check_4425);

       // Assertion 5.3: check the stats increment for error cases
       // We will write 4 different assertions for each of:
       // frag_count_rx
       // frag_count_tx
       // smd_error_count
       // ass_error_count
       // Actually the vplan just required the last 2
       // but we will write the assertions also for frag_count_rx
       // and frag_count_tx
       always @ (posedge pclk or negedge n_preset)
       begin
         if(~n_preset)
           begin
             frag_count_rx_del   <= 17'd0;
             frag_count_tx_del   <= 17'd0;
             smd_error_count_del <= 8'd0;
             ass_error_count_del <= 8'd0;
           end
         else
           begin
             frag_count_rx_del   <= frag_count_rx;
             frag_count_tx_del   <= frag_count_tx;
             smd_error_count_del <= smd_error_count;
             ass_error_count_del <= ass_error_count;
           end
       end

       property check_53a;
       @(posedge pclk)
         (frag_count_rx_td && ~&frag_count_rx && ~(read_registers && (paddr == MMSL_FRAG_COUNT_RX))) |-> (##[0:1] frag_count_rx == frag_count_rx_del + 17'd1);
       endproperty
       assert_check_53a : assert property (check_53a);

       property check_53b;
       @(posedge pclk)
         (frag_count_tx_td && ~&frag_count_tx && ~(read_registers && (paddr == MMSL_FRAG_COUNT_TX))) |-> (##[0:1] frag_count_tx == frag_count_tx_del + 17'd1);
       endproperty
       assert_check_53b : assert property (check_53b);

       property check_53c;
       @(posedge pclk)
         (smd_error_count_td && ~&smd_error_count && ~(read_registers && (paddr == MMSL_ERR_STATS))) |-> (##[0:1] smd_error_count == smd_error_count_del + 8'd1);
       endproperty
       assert_check_53c : assert property (check_53c);

       property check_53d;
       @(posedge pclk)
         (ass_error_count_td && ~&ass_error_count && ~(read_registers && (paddr == MMSL_ERR_STATS))) |-> (##[0:1] ass_error_count == ass_error_count_del + 8'd1);
       endproperty
       assert_check_53d : assert property (check_53d);

    `endif // ABV_ON
  `endif // gem_has_802p3_br

`endif // for ifdef rtl
`endif //UVM_ALL_REG_TEST

endmodule
