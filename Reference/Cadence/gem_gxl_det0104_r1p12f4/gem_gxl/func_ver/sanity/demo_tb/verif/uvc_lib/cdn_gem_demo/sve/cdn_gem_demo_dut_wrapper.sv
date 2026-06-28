//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file contains a SV wrapper for the GEM_GXL ethernet controller.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_dut_wrapper.sv
 *
 * This file contains a SV wrapper for the GEM_GXL ethernet controller.
 */

`ifndef CDN_GEM_DEMO_DUT_WRAPPER_SV
  `define CDN_GEM_DEMO_DUT_WRAPPER_SV

`include "edma_defs.v"

/*
 * Function: cdn_gem_demo_dut_wrapper
 *
 * This is the SV wrapper for the GEM_GXL Ethernet controller.
 * It contains needed signals tie-offs and logic for external loopback
 * connection if this is driven by the testbench.
 */
module cdn_gem_demo_dut_wrapper
(
  cdn_reset_if                 reset_if,
  cdn_clock_if                 clock_if_125mhz,
  cdn_clock_if                 clock_if_50mhz,
  cdn_clock_if                 clock_if_25mhz,
  cdn_clock_if                 clock_if_2p5mhz,
  cdnApb4SlaveInterface        apb_if,
  cdn_axi_vip_if               axi_if,
  `ifdef gem_use_rgmii
    cdn_enet_vip_rgmii_if      rgmii_if,
  `else
    cdn_enet_vip_gmii_if       gmii_if,
  `endif
  `ifdef gem_include_rmii
    cdn_enet_vip_rmii_if       rmii_if,
  `endif
  cdn_demo_misc_signals_if     misc_signals_if
);

//------------------------------------------------------------------------
// Signal Declarations
//------------------------------------------------------------------------

// Connect the DUT to C loopback signals or wrapper interfaces
wire [7:0]   gmii_rxd_to_dut;
wire         gmii_rx_dv_to_dut;
wire         gmii_rx_er_to_dut;
wire [3:0]   rgmii_rxd_to_dut;
wire         rgmii_rx_ctl_to_dut;

// C loopback signals: needed to apply a delay and ensure a reliable Tx-Rx
// connection
`ifdef CDN_DEMO_C
  parameter  LOOPBACK_DELAY = 50; // This MUST be an even number
  bit [7:0]  gmii_rxd_c_loopback;
  bit        gmii_rx_dv_c_loopback;
  bit        gmii_rx_er_c_loopback;
  bit [3:0]  rgmii_rxd_c_loopback;
  bit        rgmii_rx_ctl_c_loopback;
`endif

//------------------------------------------------------------------------
// Tie Offs
//------------------------------------------------------------------------

//-----------------------------------------
// APB IF Unused DUT Input
//-----------------------------------------

assign apb_if.pready = 1'b1;

//-----------------------------------------
// AXI IF Unused DUT Input
//-----------------------------------------

assign axi_if.awid       = 4'd0;
assign axi_if.arid       = 4'd0;
assign axi_if.arlen[7:4] = 4'd0;
assign axi_if.awlen[7:4] = 4'd0;

//-----------------------------------------
// ENET IF Unused DUT Input
//-----------------------------------------

`ifdef gem_use_rgmii
  assign rgmii_if.sig_GMII_RX_ER   = 1'b0;
  assign rgmii_if.sig_GMII_COL     = 1'b0;
  assign rgmii_if.sig_GMII_CRS     = 1'b0;
`endif

`ifdef gem_include_rmii
  assign rmii_if.mii_select       = 1'b1;
  assign rmii_if.sig_RMII_RX_DATA = 2'b0;
  assign rmii_if.sig_RMII_RX_ER   = 1'b0;
  assign rmii_if.sig_RMII_CRS_DV  = 1'b0;
`endif

//-----------------------------------------
// MISC IF Unused DUT Input
//-----------------------------------------

// TBI
assign misc_signals_if.pcs_cal_bypass     = 1'b0;
assign misc_signals_if.pcs_cgalign_bypass = 1'b0;
`ifdef gem_pcs_20b_if
  assign misc_signals_if.rx_group         = 20'd0;
`else
  assign misc_signals_if.rx_group         = 10'd0;
`endif
assign misc_signals_if.signal_detect      = 1'b0;

// Control/Status
assign misc_signals_if.tx_pause                   = 1'b0;
assign misc_signals_if.tx_pause_zero              = 1'b0;
assign misc_signals_if.tx_pfc_sel                 = 1'b0;
assign misc_signals_if.tx_pfc_pause               = 8'h00;
assign misc_signals_if.tx_pfc_pause_zero          = 8'h00;
assign misc_signals_if.halfduplex_flow_control_en = 1'b0;
assign misc_signals_if.trigger_dma_tx_start       = 1'b0;

// TSU
assign misc_signals_if.gem_tsu_inc_ctrl  = 2'b11;
assign misc_signals_if.gem_tsu_ms        = 1'b0;
assign misc_signals_if.ext_tsu_timer     = 94'd0;
assign misc_signals_if.ext_tsu_timer_par = 12'd0;

// Tx FIFO
assign misc_signals_if.tx_r_data_rdy       = {`edma_queues{1'b0}};
assign misc_signals_if.tx_r_valid          = 1'b0;
assign misc_signals_if.tx_r_data           = {`gem_emac_bus_width{1'b0}};
assign misc_signals_if.tx_r_sop            = 1'b0;
assign misc_signals_if.tx_r_eop            = 1'b0;
assign misc_signals_if.tx_r_mod            = 4'b0000;
assign misc_signals_if.tx_r_err            = 1'b0;
assign misc_signals_if.tx_r_underflow      = 1'b0;
assign misc_signals_if.tx_r_flushed        = 1'b0;
assign misc_signals_if.tx_r_control        = 1'b0;
assign misc_signals_if.tx_r_frame_size     = {`edma_queues*14{1'b0}};
assign misc_signals_if.tx_r_frame_size_vld = {`edma_queues{1'b0}};
assign misc_signals_if.dma_tx_status_tog   = 1'b0;

// Rx FIFO
assign misc_signals_if.rx_w_overflow = 1'b0;

// Interrupt
assign misc_signals_if.ext_interrupt_in = 1'b0;

// User
`ifdef gem_user_io
  assign misc_signals_if.user_in = {`gem_user_in_width{1'b0}};
`endif

// MDIO
assign misc_signals_if.mdio_in = 1'b0;

// Filter
assign misc_signals_if.ext_match1 = 1'b0;
assign misc_signals_if.ext_match2 = 1'b0;
assign misc_signals_if.ext_match3 = 1'b0;
assign misc_signals_if.ext_match4 = 1'b0;

// TX SRAM
assign misc_signals_if.txsram_dib = {`edma_tx_pbuf_reduncy+`gem_tx_pbuf_data{1'b0}};
`ifdef gem_spram
  assign misc_signals_if.txsram_web   = 1'b0;
  assign misc_signals_if.txsram_enb   = 1'b0;
  assign misc_signals_if.txsram_addrb = {`gem_rx_pbuf_addr{1'b0}};
  assign misc_signals_if.txsram_dib   = {(`edma_rx_pbuf_reduncy+`gem_rx_pbuf_data){1'b0}};
  assign misc_signals_if.txsram_clka  = clock_if_125mhz.sig_clock_0;
  assign misc_signals_if.txsram_clkb  = 1'b0;
`else
  assign misc_signals_if.txsram_clka  = clock_if_125mhz.sig_clock_0;
  assign misc_signals_if.txsram_clkb  = clock_if_125mhz.sig_clock_1;
`endif

// RX SRAM
assign misc_signals_if.rxsram_dib = {`edma_tx_pbuf_reduncy+`gem_tx_pbuf_data{1'b0}};
`ifdef gem_spram
  assign misc_signals_if.rxsram_web   = 1'b0;
  assign misc_signals_if.rxsram_enb   = 1'b0;
  assign misc_signals_if.rxsram_addrb = {`gem_rx_pbuf_addr{1'b0}};
  assign misc_signals_if.rxsram_dib   = {(`edma_rx_pbuf_reduncy+`gem_rx_pbuf_data){1'b0}};
  assign misc_signals_if.rxsram_clka  = clock_if_125mhz.sig_clock_0;
  assign misc_signals_if.rxsram_clkb  = 1'b0;
`else
  assign misc_signals_if.rxsram_clka  = clock_if_125mhz.sig_clock_4;
  assign misc_signals_if.rxsram_clkb  = clock_if_125mhz.sig_clock_0;
`endif

//-------------------
// 802.3br
//-------------------

// Tx FIFO
//assign misc_signals_if.emac_tx_r_data_rdy       = {`edma_queues{1'b0}};
//assign misc_signals_if.emac_tx_r_valid          = 1'b0;
//assign misc_signals_if.emac_tx_r_data           = {`gem_emac_bus_width{1'b0}};
//assign misc_signals_if.emac_tx_r_sop            = 1'b0;
//assign misc_signals_if.emac_tx_r_eop            = 1'b0;
//assign misc_signals_if.emac_tx_r_mod            = 4'b0000;
//assign misc_signals_if.emac_tx_r_err            = 1'b0;
//assign misc_signals_if.emac_tx_r_underflow      = 1'b0;
//assign misc_signals_if.emac_tx_r_flushed        = 1'b0;
//assign misc_signals_if.emac_tx_r_control        = 1'b0;
//assign misc_signals_if.emac_tx_r_frame_size     = {`edma_queues*14{1'b0}};
//assign misc_signals_if.emac_tx_r_frame_size_vld = {`edma_queues{1'b0}};
//assign misc_signals_if.emac_dma_tx_status_tog   = 1'b0;

// Rx FIFO
//assign misc_signals_if.emac_rx_w_overflow = 1'b0;

// TX SRAM
assign misc_signals_if.emac_txsram_dib = {`edma_tx_pbuf_reduncy+`gem_tx_pbuf_data{1'b0}};
`ifdef gem_spram
  assign misc_signals_if.emac_txsram_web   = 1'b0;
  assign misc_signals_if.emac_txsram_enb   = 1'b0;
  assign misc_signals_if.emac_txsram_addrb = {`gem_emac_tx_pbuf_addr{1'b0}};
  assign misc_signals_if.emac_txsram_dib   = {(`edma_emac_tx_pbuf_reduncy+`gem_tx_pbuf_data){1'b0}};
  assign misc_signals_if.emac_txsram_clka  = clock_if_125mhz.sig_clock_0;
  assign misc_signals_if.emac_txsram_clkb  = 1'b0;
`else
  assign misc_signals_if.emac_txsram_clka  = clock_if_125mhz.sig_clock_0;
  assign misc_signals_if.emac_txsram_clkb  = clock_if_125mhz.sig_clock_1;
`endif

// RX SRAM
assign misc_signals_if.emac_rxsram_dib = {`edma_tx_pbuf_reduncy+`gem_tx_pbuf_data{1'b0}};
`ifdef gem_spram
  assign misc_signals_if.emac_rxsram_web   = 1'b0;
  assign misc_signals_if.emac_rxsram_enb   = 1'b0;
  assign misc_signals_if.emac_rxsram_addrb = {`gem_emac_rx_pbuf_addr{1'b0}};
  assign misc_signals_if.emac_rxsram_dib   = {(`edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data){1'b0}};
  assign misc_signals_if.emac_rxsram_clka  = clock_if_125mhz.sig_clock_0;
  assign misc_signals_if.emac_rxsram_clkb  = 1'b0;
`else
  assign misc_signals_if.emac_rxsram_clka  = clock_if_125mhz.sig_clock_4;
  assign misc_signals_if.emac_rxsram_clkb  = clock_if_125mhz.sig_clock_0;
`endif

//------------------------------------------------------------------------------
// C/UVM Line Side Connection
//------------------------------------------------------------------------------

// C tests use a GMII/RGMII loopback connection.
// UVM tests connect straight to the wrapper interfaces.
`ifdef CDN_DEMO_C
  `ifdef gem_use_rgmii
    // Apply a LOOPBACK_DELAY to data and control with respect to the Tx
    // synchronous clock. RGMII is DDR, signals shall be driven at both posedge
    // and negedge.
    always @(posedge clock_if_125mhz.sig_clock_2 or negedge clock_if_125mhz.sig_clock_2) begin
      rgmii_rxd_c_loopback    <= repeat (LOOPBACK_DELAY-1) @(clock_if_125mhz.sig_clock_2) rgmii_if.sig_RGMII_TD;
      rgmii_rx_ctl_c_loopback <= repeat (LOOPBACK_DELAY-1) @(clock_if_125mhz.sig_clock_2) rgmii_if.sig_RGMII_TX_CTL;
    end
    // Connect data and control to the DUT
    assign rgmii_rxd_to_dut    = rgmii_rxd_c_loopback;
    assign rgmii_rx_ctl_to_dut = rgmii_rx_ctl_c_loopback;
  `else
    // Apply a LOOPBACK_DELAY to data and control with respect to the Tx
    // synchronous clock
    always @(posedge clock_if_125mhz.sig_clock_1) begin
      gmii_rxd_c_loopback   <= repeat (LOOPBACK_DELAY-1) @(posedge clock_if_125mhz.sig_clock_1) gmii_if.sig_GMII_TX_DATA;
      gmii_rx_dv_c_loopback <= repeat (LOOPBACK_DELAY-1) @(posedge clock_if_125mhz.sig_clock_1) gmii_if.sig_GMII_TX_EN;
      gmii_rx_er_c_loopback <= repeat (LOOPBACK_DELAY-1) @(posedge clock_if_125mhz.sig_clock_1) gmii_if.sig_GMII_TX_ER;
    end
    // Connect to the DUT data and control
    assign gmii_rxd_to_dut   = gmii_rxd_c_loopback;
    assign gmii_rx_dv_to_dut = gmii_rx_dv_c_loopback;
    assign gmii_rx_er_to_dut = gmii_rx_er_c_loopback;
  `endif
`else
    // Connect clock, data and control to the DUT
    `ifdef gem_use_rgmii
      assign rgmii_rxd_to_dut    = rgmii_if.sig_RGMII_RD;
      assign rgmii_rx_ctl_to_dut = rgmii_if.sig_RGMII_RX_CTL;
    `else
      assign gmii_rxd_to_dut     = gmii_if.sig_GMII_RX_DATA;
      assign gmii_rx_dv_to_dut   = gmii_if.sig_GMII_RX_DV;
      assign gmii_rx_er_to_dut   = gmii_if.sig_GMII_RX_ER;
    `endif
`endif

//------------------------------------------------------------------------
// Instantiate the DUT
//------------------------------------------------------------------------

gem_gxl i_gem
(
  // Internal Loopback Signals
  `ifdef gem_int_loopback
    .n_ntxreset     ( reset_if.sig_reset             ), // I
    .n_tx_clk       ( ~clock_if_125mhz.sig_clock_1   ), // I
    .loopback_local ( misc_signals_if.loopback_local ), // O
  `else
    `ifdef gem_use_rgmii
      .n_ntxreset   ( reset_if.sig_reset             ), // I
      .n_tx_clk     ( ~clock_if_125mhz.sig_clock_1   ), // I
    `endif
  `endif

  // Ethernet Interface (GMII/RGMII)
  .rx_clk              ( clock_if_125mhz.sig_clock_4  ), // I
  .tx_clk              ( clock_if_125mhz.sig_clock_1  ), // I
  `ifdef gem_use_rgmii
    .tx_clk_sig        ( clock_if_125mhz.sig_clock_2  ), // I
    .n_nrxreset        ( reset_if.sig_reset           ), // I
    .n_rx_clk          ( ~clock_if_125mhz.sig_clock_4 ), // I
    .rgmii_txd         ( rgmii_if.sig_RGMII_TD        ), // O
    .rgmii_tx_ctl      ( rgmii_if.sig_RGMII_TX_CTL    ), // O
    .rgmii_rxd         ( rgmii_rxd_to_dut             ), // I
    .rgmii_rx_ctl      ( rgmii_rx_ctl_to_dut          ), // I
    .rgmii_link_status ( rgmii_if.rgmii_link_status   ), // O
    .rgmii_speed       ( rgmii_if.rgmii_speed         ), // O
    .rgmii_duplex_out  ( rgmii_if.rgmii_duplex_out    ), // O
    .tx_er             ( rgmii_if.sig_GMII_TX_ER      ), // O
    .rx_er             ( rgmii_if.sig_GMII_RX_ER      ), // I
    .col               ( rgmii_if.sig_GMII_COL        ), // I
    .crs               ( rgmii_if.sig_GMII_CRS        ), // I
  `else
    .col               ( gmii_if.sig_GMII_COL         ), // I
    .crs               ( gmii_if.sig_GMII_CRS         ), // I
    .txd               ( gmii_if.sig_GMII_TX_DATA     ), // O
    .rxd               ( gmii_rxd_to_dut              ), // I
    .tx_en             ( gmii_if.sig_GMII_TX_EN       ), // O
    .rx_dv             ( gmii_rx_dv_to_dut            ), // I
    .tx_er             ( gmii_if.sig_GMII_TX_ER       ), // O
    .rx_er             ( gmii_if.sig_GMII_RX_ER       ), // I
  `endif

  // Ethernet Interface (MII/RMII)
  `ifdef gem_include_rmii
    .ref_clk     ( clock_if_50mhz.sig_clock_0 ), // I
    .n_ref_reset ( reset_if.sig_reset         ), // I
    .mii_select  ( rmii_if.mii_select         ), // I TODO: implement this in tb. Selects MII (1) or RMII (0).
    .rmii_txd    ( rmii_if.sig_RMII_TX_DATA   ), // O
    .rmii_rxd    ( rmii_if.sig_RMII_RX_DATA   ), // I
    .rmii_tx_en  ( rmii_if.sig_RMII_TX_EN     ), // O
    .rmii_rx_er  ( rmii_if.sig_RMII_RX_ER     ), // I
    .rmii_crs_dv ( rmii_if.sig_RMII_CRS_DV    ), // I
    .rmii_rx_clk ( rmii_if.rmii_rx_clk        ), // O
    .rmii_tx_clk ( rmii_if.rmii_tx_clk        ), // O
  `endif

  // Ethernet Interface (TBI)
  `ifndef gem_no_pcs
    .gtx_clk              (                    ), // I TODO: see which clock is proper here.
    .n_gtxreset           ( reset_if.sig_reset ), // I
    `ifdef gem_pcs_20b_if
      .gtx20_clk          (                    ), // I TODO: see which clock is proper here.
      .n_gtx20reset       ( reset_if.sig_reset ), // I
    `endif
    `ifdef gem_pcs_legacy_if
      .rbc0               (                    ), // I TODO: see which clock is proper here.
      .rbc1               (                    ), // I TODO: see which clock is proper here.
      .n_rbc0reset        ( reset_if.sig_reset ), // I
      .n_rbc1reset        ( reset_if.sig_reset ), // I
    `else
      .pcs_rx_clk         (                    ), // I TODO: see which clock is proper here.
      .n_pcs_rxreset      ( reset_if.sig_reset ), // I
      .pcs_cal_bypass     (                    ), // I TODO: create and connect TBI if/vif in the cdn_enet_vip UVC.
      .pcs_cgalign_bypass (                    ), // I TODO: create and connect TBI if/vif in the cdn_enet_vip UVC.
    `endif
    `ifdef gem_pcs_10b_if
       .pcs_rx10_clk      (                    ), // I TODO: see which clock is proper here.
       .n_pcs_rx10reset   ( reset_if.sig_reset ), // I
    `endif
    .tx_group             (                    ), // O TODO: create and connect TBI if/vif in the cdn_enet_vip UVC.
    .rx_group             (                    ), // I TODO: create and connect TBI if/vif in the cdn_enet_vip UVC.
    .ewrap                (                    ), // O TODO: create and connect TBI if/vif in the cdn_enet_vip UVC.
    .en_cdet              (                    ), // O TODO: create and connect TBI if/vif in the cdn_enet_vip UVC.
    .signal_detect        (                    ), // I TODO: create and connect TBI if/vif in the cdn_enet_vip UVC.
  `endif

  // Control/Status Interface
  .loopback                   ( misc_signals_if.loopback                   ), // O
  .half_duplex                ( misc_signals_if.half_duplex                ), // O
  .speed_mode                 ( misc_signals_if.speed_mode                 ), // O
  .tx_pause                   ( misc_signals_if.tx_pause                   ), // I
  .tx_pfc_sel                 ( misc_signals_if.tx_pfc_sel                 ), // I
  .tx_pause_zero              ( misc_signals_if.tx_pause_zero              ), // I
  .tx_pfc_pause               ( misc_signals_if.tx_pfc_pause               ), // I
  .tx_pfc_pause_zero          ( misc_signals_if.tx_pfc_pause_zero          ), // I
  .halfduplex_flow_control_en ( misc_signals_if.halfduplex_flow_control_en ), // I
  .dma_bus_width              ( misc_signals_if.dma_bus_width              ), // O
  `ifndef gem_ext_fifo_interface
    `ifdef gem_tx_pkt_buffer
      .trigger_dma_tx_start   ( misc_signals_if.trigger_dma_tx_start       ), // I
    `endif
  `endif
  .rx_pfc_paused              ( misc_signals_if.rx_pfc_paused              ), // O
  .pfc_negotiate              ( misc_signals_if.pfc_negotiate              ), // O
  `ifndef gem_ext_fifo_interface
    .rx_databuf_wr_q0         ( misc_signals_if.rx_databuf_wr_q0           ), // O
    `ifdef dma_priority_queue1
      .rx_databuf_wr_q1       ( misc_signals_if.rx_databuf_wr_q1           ), // O
    `endif
    `ifdef dma_priority_queue2
      .rx_databuf_wr_q2       ( misc_signals_if.rx_databuf_wr_q2           ), // O
    `endif
    `ifdef dma_priority_queue3
      .rx_databuf_wr_q3       ( misc_signals_if.rx_databuf_wr_q3           ), // O
    `endif
    `ifdef dma_priority_queue4
      .rx_databuf_wr_q4       ( misc_signals_if.rx_databuf_wr_q4           ), // O
    `endif
    `ifdef dma_priority_queue5
      .rx_databuf_wr_q5       ( misc_signals_if.rx_databuf_wr_q5           ), // O
    `endif
    `ifdef dma_priority_queue6
      .rx_databuf_wr_q6       ( misc_signals_if.rx_databuf_wr_q6           ), // O
    `endif
    `ifdef dma_priority_queue7
      .rx_databuf_wr_q7       ( misc_signals_if.rx_databuf_wr_q7           ), // O
    `endif
    `ifdef dma_priority_queue8
      .rx_databuf_wr_q8       ( misc_signals_if.rx_databuf_wr_q8           ), // O
    `endif
    `ifdef dma_priority_queue9
      .rx_databuf_wr_q9       ( misc_signals_if.rx_databuf_wr_q9           ), // O
    `endif
    `ifdef dma_priority_queue10
      .rx_databuf_wr_q10      ( misc_signals_if.rx_databuf_wr_q10          ), // O
    `endif
    `ifdef dma_priority_queue11
      .rx_databuf_wr_q11      ( misc_signals_if.rx_databuf_wr_q11          ), // O
    `endif
    `ifdef dma_priority_queue12
      .rx_databuf_wr_q12      ( misc_signals_if.rx_databuf_wr_q12          ), // O
    `endif
    `ifdef dma_priority_queue13
      .rx_databuf_wr_q13      ( misc_signals_if.rx_databuf_wr_q13          ), // O
    `endif
    `ifdef dma_priority_queue14
      .rx_databuf_wr_q14      ( misc_signals_if.rx_databuf_wr_q14          ), // O
    `endif
    `ifdef dma_priority_queue15
      .rx_databuf_wr_q15      ( misc_signals_if.rx_databuf_wr_q15          ), // O
    `endif
  `endif

  // Time Stamp Unit (TSU)
  `ifdef gem_tsu
    .gem_tsu_inc_ctrl      ( misc_signals_if.gem_tsu_inc_ctrl  ), // I
    .gem_tsu_ms            ( misc_signals_if.gem_tsu_ms        ), // I
    .tsu_timer_cnt         ( misc_signals_if.tsu_timer_cnt     ), // O
    `ifdef edma_asf_dap_prot
      .tsu_timer_cnt_par   ( misc_signals_if.tsu_timer_cnt_par ), // O
    `endif
    .tsu_timer_cmp_val     ( misc_signals_if.tsu_timer_cmp_val ), // O
    `ifdef gem_ext_tsu_timer
      .ext_tsu_timer       ( misc_signals_if.ext_tsu_timer     ), // I
      `ifdef edma_asf_dap_prot
        .ext_tsu_timer_par ( misc_signals_if.ext_tsu_timer_par ), // I
      `endif
    `endif
    `ifdef gem_tsu_clk
      .tsu_clk             ( clock_if_125mhz.sig_clock_0           ), // I
      .n_tsureset          ( reset_if.sig_reset                    ), // I
    `endif
  `endif

  // Interrupt Controller Interface
  .ext_interrupt_in      ( misc_signals_if.ext_interrupt_in  ), // I
  `ifndef gem_ext_fifo_interface
    .ethernet_int        ( misc_signals_if.ethernet_int      ), // O
    `ifdef gem_has_802p3_br
      .emac_ethernet_int ( misc_signals_if.emac_ethernet_int ), // O
      .mmsl_int          ( misc_signals_if.mmsl_int          ), // O
    `endif
    `ifdef dma_priority_queue1
      .ethernet_int_q1   ( misc_signals_if.ethernet_int_q1   ), // O
    `endif
    `ifdef dma_priority_queue2
      .ethernet_int_q2   ( misc_signals_if.ethernet_int_q2   ), // O
    `endif
    `ifdef dma_priority_queue3
      .ethernet_int_q3   ( misc_signals_if.ethernet_int_q3   ), // O
    `endif
    `ifdef dma_priority_queue4
      .ethernet_int_q4   ( misc_signals_if.ethernet_int_q4   ), // O
    `endif
    `ifdef dma_priority_queue5
      .ethernet_int_q5   ( misc_signals_if.ethernet_int_q5   ), // O
    `endif
    `ifdef dma_priority_queue6
      .ethernet_int_q6   ( misc_signals_if.ethernet_int_q6   ), // O
    `endif
    `ifdef dma_priority_queue7
      .ethernet_int_q7   ( misc_signals_if.ethernet_int_q7   ), // O
    `endif
    `ifdef dma_priority_queue8
      .ethernet_int_q8   ( misc_signals_if.ethernet_int_q8   ), // O
    `endif
    `ifdef dma_priority_queue9
      .ethernet_int_q9   ( misc_signals_if.ethernet_int_q9   ), // O
    `endif
    `ifdef dma_priority_queue10
      .ethernet_int_q10  ( misc_signals_if.ethernet_int_q10  ), // O
    `endif
    `ifdef dma_priority_queue11
      .ethernet_int_q11  ( misc_signals_if.ethernet_int_q11  ), // O
    `endif
    `ifdef dma_priority_queue12
      .ethernet_int_q12  ( misc_signals_if.ethernet_int_q12  ), // O
    `endif
    `ifdef dma_priority_queue13
      .ethernet_int_q13  ( misc_signals_if.ethernet_int_q13  ), // O
    `endif
    `ifdef dma_priority_queue14
      .ethernet_int_q14  ( misc_signals_if.ethernet_int_q14  ), // O
    `endif
    `ifdef dma_priority_queue15
      .ethernet_int_q15  ( misc_signals_if.ethernet_int_q15  ), // O
    `endif
  `endif

  // External Transmit FIFO Interface
  `ifdef gem_add_tx_external_fifo_if
    .tx_r_data_rdy       ( misc_signals_if.tx_r_data_rdy       ), // I
    .tx_r_rd             ( misc_signals_if.tx_r_rd             ), // O
    .tx_r_valid          ( misc_signals_if.tx_r_valid          ), // I
    .tx_r_data           ( misc_signals_if.tx_r_data           ), // I
    .tx_r_sop            ( misc_signals_if.tx_r_sop            ), // I
    .tx_r_eop            ( misc_signals_if.tx_r_eop            ), // I
    .tx_r_mod            ( misc_signals_if.tx_r_mod            ), // I
    .tx_r_err            ( misc_signals_if.tx_r_err            ), // I
    .tx_r_underflow      ( misc_signals_if.tx_r_underflow      ), // I
    .tx_r_flushed        ( misc_signals_if.tx_r_flushed        ), // I
    .tx_r_control        ( misc_signals_if.tx_r_control        ), // I
    .tx_r_frame_size     ( misc_signals_if.tx_r_frame_size     ), // I
    .tx_r_frame_size_vld ( misc_signals_if.tx_r_frame_size_vld ), // I
    .dma_tx_end_tog      ( misc_signals_if.dma_tx_end_tog      ), // O
    .dma_tx_status_tog   ( misc_signals_if.dma_tx_status_tog   ), // I
    .tx_r_status         ( misc_signals_if.tx_r_status         ), // O
    `ifdef dma_priority_queue1
      .tx_r_queue        ( misc_signals_if.tx_r_queue          ), // O
    `endif
    `ifdef gem_tsu
      .tx_r_timestamp    ( misc_signals_if.tx_r_timestamp      ), // O
    `endif
  `endif
  `ifdef gem_has_802p3_br
    `ifdef gem_add_tx_external_fifo_if
      .emac_tx_r_data_rdy       ( misc_signals_if.emac_tx_r_data_rdy       ), // I
      .emac_tx_r_rd             ( misc_signals_if.emac_tx_r_rd             ), // O
      .emac_tx_r_valid          ( misc_signals_if.emac_tx_r_valid          ), // I
      .emac_tx_r_data           ( misc_signals_if.emac_tx_r_data           ), // I
      .emac_tx_r_sop            ( misc_signals_if.emac_tx_r_sop            ), // I
      .emac_tx_r_eop            ( misc_signals_if.emac_tx_r_eop            ), // I
      .emac_tx_r_mod            ( misc_signals_if.emac_tx_r_mod            ), // I
      .emac_tx_r_err            ( misc_signals_if.emac_tx_r_err            ), // I
      .emac_tx_r_underflow      ( misc_signals_if.emac_tx_r_underflow      ), // I
      .emac_tx_r_flushed        ( misc_signals_if.emac_tx_r_flushed        ), // I
      .emac_tx_r_control        ( misc_signals_if.emac_tx_r_control        ), // I
      .emac_tx_r_frame_size     ( misc_signals_if.emac_tx_r_frame_size     ), // I
      .emac_tx_r_frame_size_vld ( misc_signals_if.emac_tx_r_frame_size_vld ), // I
      .emac_dma_tx_end_tog      ( misc_signals_if.emac_dma_tx_end_tog      ), // O
      .emac_dma_tx_status_tog   ( misc_signals_if.emac_dma_tx_status_tog   ), // I
      .emac_tx_r_status         ( misc_signals_if.emac_tx_r_status         ), // O
      `ifdef dma_priority_queue1
        .emac_tx_r_queue        ( misc_signals_if.emac_tx_r_queue          ), // O
      `endif
      `ifdef gem_tsu
        .emac_tx_r_timestamp    ( misc_signals_if.emac_tx_r_timestamp      ), // O
      `endif
    `endif
  `endif

  // External Receive FIFO Interface
  `ifdef gem_add_rx_external_fifo_if
    .rx_w_wr          ( misc_signals_if.rx_w_wr        ), // O
    .rx_w_data        ( misc_signals_if.rx_w_data      ), // O
    .rx_w_sop         ( misc_signals_if.rx_w_sop       ), // O
    .rx_w_eop         ( misc_signals_if.rx_w_eop       ), // O
    .rx_w_status      ( misc_signals_if.rx_w_status    ), // O
    .rx_w_mod         ( misc_signals_if.rx_w_mod       ), // O
    .rx_w_err         ( misc_signals_if.rx_w_err       ), // O
    .rx_w_overflow    ( misc_signals_if.rx_w_overflow  ), // I
    .rx_w_flush       ( misc_signals_if.rx_w_flush     ), // O
    `ifdef num_spec_add_filters
      .add_match_vec  ( misc_signals_if.add_match_vec  ), // O
    `endif
    `ifdef gem_tsu
      .rx_w_timestamp ( misc_signals_if.rx_w_timestamp ), // O
    `endif
    `ifdef dma_priority_queue1
      .rx_w_queue     ( misc_signals_if.rx_w_queue     ), // O
    `endif
  `endif
  `ifdef gem_has_802p3_br
    `ifdef gem_add_rx_external_fifo_if
      .emac_rx_w_wr          ( misc_signals_if.emac_rx_w_wr        ), // O
      .emac_rx_w_data        ( misc_signals_if.emac_rx_w_data      ), // O
      .emac_rx_w_sop         ( misc_signals_if.emac_rx_w_sop       ), // O
      .emac_rx_w_eop         ( misc_signals_if.emac_rx_w_eop       ), // O
      .emac_rx_w_status      ( misc_signals_if.emac_rx_w_status    ), // O
      .emac_rx_w_mod         ( misc_signals_if.emac_rx_w_mod       ), // O
      .emac_rx_w_err         ( misc_signals_if.emac_rx_w_err       ), // O
      .emac_rx_w_overflow    ( misc_signals_if.emac_rx_w_overflow  ), // I
      .emac_rx_w_flush       ( misc_signals_if.emac_rx_w_flush     ), // O
      `ifdef num_spec_add_filters
        .emac_add_match_vec  ( misc_signals_if.emac_add_match_vec  ), // O
      `endif
      `ifdef gem_tsu
        .emac_rx_w_timestamp ( misc_signals_if.emac_rx_w_timestamp ), // O
      `endif
      `ifdef dma_priority_queue1
        .emac_rx_w_queue     ( misc_signals_if.emac_rx_w_queue     ), // O
      `endif
    `endif
  `endif

  // APB Interface
  .n_preset     ( reset_if.sig_reset               ),
  .pclk         ( clock_if_125mhz.sig_clock_0      ),
  .prdata       ( apb_if.prdata                    ),
  .perr         ( apb_if.pslverr                   ),
  .psel         ( apb_if.psel                      ),
  .penable      ( apb_if.penable                   ),
  .pwrite       ( apb_if.pwrite                    ),
  .pwdata       ( apb_if.pwdata                    ),
  `ifdef gem_asf_host_par
    .paddr_par  (                                  ), // I TODO: add to some if (APB custom one??) and determine which signal is proper to connect here
    .pwdata_par (                                  ), // I TODO: add to some if (APB custom one??) and determine which signal is proper to connect here
    .prdata_par (                                  ), // O TODO: add to some if (APB custom one??)
    `ifdef gem_has_802p3_br
      .paddr    ( {3'h0, apb_if.paddr[12:2], 2'h0} ),
    `else
      .paddr    ( {4'h0, apb_if.paddr[11:2], 2'h0} ),
    `endif
  `else
    `ifdef gem_has_802p3_br
      .paddr    ( apb_if.paddr[12:2]               ),
    `else
      .paddr    ( apb_if.paddr[11:2]               ),
    `endif
  `endif

  // Host Side Interface (AXI/AHB)
  `ifdef gem_axi
    .n_areset     ( reset_if.sig_reset          ), // I
    .aclk         ( clock_if_125mhz.sig_clock_0 ), // I
    .awaddr       ( axi_if.awaddr               ), // O
    .awlen        ( axi_if.awlen                ), // O
    .awsize       ( axi_if.awsize               ), // O
    .awburst      ( axi_if.awburst              ), // O
    .awvalid      ( axi_if.awvalid              ), // O
    .awqos        ( axi_if.awqos                ), // O
    .awready      ( axi_if.awready              ), // I
    .awid         ( axi_if.awid                 ), // O
    .awcache      ( axi_if.awcache              ), // O
    .awlock       ( axi_if.awlock               ), // O
    .awprot       ( axi_if.awprot               ), // O
    .wdata        ( axi_if.wdata                ), // O
    .wstrb        ( axi_if.wstrb                ), // O
    .wlast        ( axi_if.wlast                ), // O
    .wid          ( axi_if.wid                  ), // O
    .wvalid       ( axi_if.wvalid               ), // O
    .wready       ( axi_if.wready               ), // I
    .bresp        ( axi_if.bresp                ), // I
    .bid          ( axi_if.bid                  ), // I
    .bvalid       ( axi_if.bvalid               ), // I
    .bready       ( axi_if.bready               ), // O
    .araddr       ( axi_if.araddr               ), // O
    .arlen        ( axi_if.arlen                ), // O
    .arsize       ( axi_if.arsize               ), // O
    .arburst      ( axi_if.arburst              ), // O
    .arvalid      ( axi_if.arvalid              ), // O
    .arqos        ( axi_if.arqos                ), // O
    .arready      ( axi_if.arready              ), // I
    .arid         ( axi_if.arid                 ), // O
    .arcache      ( axi_if.arcache              ), // O
    .arlock       ( axi_if.arlock               ), // O
    .arprot       ( axi_if.arprot               ), // O
    .rdata        ( axi_if.rdata                ), // I
    .rlast        ( axi_if.rlast                ), // I
    .rresp        ( axi_if.rresp                ), // I
    .rid          ( axi_if.rid                  ), // I
    .rvalid       ( axi_if.rvalid               ), // I
    .rready       ( axi_if.rready               ), // O
    `ifdef gem_asf_host_par
      .awaddr_par (                             ), // O TODO: add to some if (AXI custom??)
      .wdata_par  (                             ), // O TODO: add to some if (AXI custom??)
      .araddr_par (                             ), // O TODO: add to some if (AXI custom??)
      .rdata_par  (                             ), // I TODO: add_to some if (AXI custom??) and determine which signal is proper to connect here
    `endif
  `else
    .n_hreset ( reset_if.sig_reset          ), // I
    .hclk     ( clock_if_125mhz.sig_clock_0 ), // I
    .hready   (                             ), // I TODO: Create an AHB UVC
    .hresp    (                             ), // I TODO: Create an AHB UVC
    .hgrant   (                             ), // I TODO: Create an AHB UVC
    .haddr    (                             ), // O TODO: Create an AHB UVC
    .htrans   (                             ), // O TODO: Create an AHB UVC
    .hwrite   (                             ), // O TODO: Create an AHB UVC
    .hrdata   (                             ), // I TODO: Create an AHB UVC
    .hsize    (                             ), // O TODO: Create an AHB UVC
    .hburst   (                             ), // O TODO: Create an AHB UVC
    .hprot    (                             ), // O TODO: Create an AHB UVC
    .hwdata   (                             ), // O TODO: Create an AHB UVC
    .hbusreq  (                             ), // O TODO: Create an AHB UVC
    .hlock    (                             ), // O TODO: Create an AHB UVC
  `endif

  // Transmit Packet Buffer Memory Interface (SPSRAM/DPSRAM)
  `ifndef gem_ext_fifo_interface
    `ifdef gem_tx_pkt_buffer
      `ifdef gem_spram
        .txspram_we           ( misc_signals_if.txsram_wea   ), // O
        .txspram_en           ( misc_signals_if.txsram_ena   ), // O
        .txspram_addr         ( misc_signals_if.txsram_addra ), // O
        .txspram_do           ( misc_signals_if.txsram_doa   ), // I
        .txspram_di           ( misc_signals_if.txsram_dia   ), // O
      `else
        .txdpram_wea          ( misc_signals_if.txsram_wea   ), // O
        .txdpram_ena          ( misc_signals_if.txsram_ena   ), // O
        .txdpram_addra        ( misc_signals_if.txsram_addra ), // O
        .txdpram_dia          ( misc_signals_if.txsram_dia   ), // O
        .txdpram_web          ( misc_signals_if.txsram_web   ), // O
        .txdpram_enb          ( misc_signals_if.txsram_enb   ), // O
        .txdpram_addrb        ( misc_signals_if.txsram_addrb ), // O
        .txdpram_dob          ( misc_signals_if.txsram_dob   ), // I
      `endif
    `endif
  `endif
  `ifdef gem_has_802p3_br
    `ifndef gem_ext_fifo_interface
      `ifdef gem_tx_pkt_buffer
        `ifdef gem_spram
          .emac_txspram_we    ( misc_signals_if.emac_txsram_wea   ), // O
          .emac_txspram_en    ( misc_signals_if.emac_txsram_ena   ), // O
          .emac_txspram_addr  ( misc_signals_if.emac_txsram_addra ), // O
          .emac_txspram_do    ( misc_signals_if.emac_txsram_doa   ), // I
          .emac_txspram_di    ( misc_signals_if.emac_txsram_dia   ), // O
        `else
          .emac_txdpram_wea   ( misc_signals_if.emac_txsram_wea   ), // O
          .emac_txdpram_ena   ( misc_signals_if.emac_txsram_ena   ), // O
          .emac_txdpram_addra ( misc_signals_if.emac_txsram_addra ), // O
          .emac_txdpram_dia   ( misc_signals_if.emac_txsram_dia   ), // O
          .emac_txdpram_web   ( misc_signals_if.emac_txsram_web   ), // O
          .emac_txdpram_enb   ( misc_signals_if.emac_txsram_enb   ), // O
          .emac_txdpram_addrb ( misc_signals_if.emac_txsram_addrb ), // O
          .emac_txdpram_dob   ( misc_signals_if.emac_txsram_dob   ), // I
        `endif
      `endif
    `endif
  `endif

  // Receive Packet Buffer Memory Interface (SPSRAM/DPSRAM)
  `ifndef gem_ext_fifo_interface
    `ifdef gem_tx_pkt_buffer
      `ifdef gem_spram
        .rxspram_we    ( misc_signals_if.rxsram_wea   ), // O
        .rxspram_en    ( misc_signals_if.rxsram_ena   ), // O
        .rxspram_addr  ( misc_signals_if.rxsram_addra ), // O
        .rxspram_do    ( misc_signals_if.rxsram_doa   ), // I
        .rxspram_di    ( misc_signals_if.rxsram_dia   ), // O
      `else
        .rxdpram_wea   ( misc_signals_if.rxsram_wea   ), // O
        .rxdpram_ena   ( misc_signals_if.rxsram_ena   ), // O
        .rxdpram_addra ( misc_signals_if.rxsram_addra ), // O
        .rxdpram_dia   ( misc_signals_if.rxsram_dia   ), // O
        .rxdpram_web   ( misc_signals_if.rxsram_web   ), // O
        .rxdpram_enb   ( misc_signals_if.rxsram_enb   ), // O
        .rxdpram_addrb ( misc_signals_if.rxsram_addrb ), // O
        .rxdpram_dob   ( misc_signals_if.rxsram_dob   ), // I
      `endif
    `endif
  `endif
  `ifdef gem_has_802p3_br
    `ifndef gem_ext_fifo_interface
      `ifdef gem_tx_pkt_buffer
        `ifdef gem_spram
          .emac_rxspram_we    ( misc_signals_if.emac_rxsram_wea   ), // O
          .emac_rxspram_en    ( misc_signals_if.emac_rxsram_ena   ), // O
          .emac_rxspram_addr  ( misc_signals_if.emac_rxsram_addra ), // O
          .emac_rxspram_do    ( misc_signals_if.emac_rxsram_doa   ), // I
          .emac_rxspram_di    ( misc_signals_if.emac_rxsram_dia   ), // O
        `else
          .emac_rxdpram_wea   ( misc_signals_if.emac_rxsram_wea   ), // O
          .emac_rxdpram_ena   ( misc_signals_if.emac_rxsram_ena   ), // O
          .emac_rxdpram_addra ( misc_signals_if.emac_rxsram_addra ), // O
          .emac_rxdpram_dia   ( misc_signals_if.emac_rxsram_dia   ), // O
          .emac_rxdpram_web   ( misc_signals_if.emac_rxsram_web   ), // O
          .emac_rxdpram_enb   ( misc_signals_if.emac_rxsram_enb   ), // O
          .emac_rxdpram_addrb ( misc_signals_if.emac_rxsram_addrb ), // O
          .emac_rxdpram_dob   ( misc_signals_if.emac_rxsram_dob   ), // I
        `endif
      `endif
    `endif
  `endif

  // User I/O interface.
  `ifdef gem_user_io
    .user_out ( misc_signals_if.user_out ), // O
    .user_in  ( misc_signals_if.user_in  ), // I
  `endif

  // ASF Signals
  .asf_trans_to_err                 ( misc_signals_if.asf_trans_to_err         ), // O
  .asf_protocol_err                 ( misc_signals_if.asf_protocol_err         ), // O
  .asf_int_nonfatal                 ( misc_signals_if.asf_int_nonfatal         ), // O
  .asf_int_fatal                    ( misc_signals_if.asf_int_fatal            ), // O
  `ifndef gem_ext_fifo_interface
    `ifdef gem_tx_pkt_buffer
      `ifdef gem_asf_ecc_sram
        .asf_sram_corr_err          ( misc_signals_if.asf_sram_corr_err        ), // O
      `endif
      `ifdef gem_asf_dap_prot
        .asf_sram_uncorr_err        ( misc_signals_if.asf_sram_uncorr_err      ), // O
      `endif
    `endif
  `endif
  `ifdef gem_asf_integrity_prot
    .asf_integrity_err              ( misc_signals_if.asf_integrity_err        ), // O
  `endif
  `ifdef gem_asf_dap_prot
    .asf_dap_err                    ( misc_signals_if.asf_dap_err              ), // O
  `endif
  `ifdef gem_asf_csr_prot
    .asf_csr_err                    ( misc_signals_if.asf_csr_err              ), // O
  `endif
  `ifdef gem_has_802p3_br
    .emac_asf_trans_to_err          ( misc_signals_if.emac_asf_trans_to_err    ), // O
    .emac_asf_protocol_err          ( misc_signals_if.emac_asf_protocol_err    ), // O
    .emac_asf_int_nonfatal          ( misc_signals_if.emac_asf_int_nonfatal    ), // O
    .emac_asf_int_fatal             ( misc_signals_if.emac_asf_int_fatal       ), // O
    `ifndef gem_ext_fifo_interface
      `ifdef gem_tx_pkt_buffer
        `ifdef gem_asf_ecc_sram
          .emac_asf_sram_corr_err   ( misc_signals_if.emac_asf_sram_corr_err   ), // O
        `endif
        `ifdef gem_asf_dap_prot
          .emac_asf_sram_uncorr_err ( misc_signals_if.emac_asf_sram_uncorr_err ), // O
        `endif
      `endif
    `endif
    `ifdef gem_asf_integrity_prot
      .emac_asf_integrity_err       ( misc_signals_if.emac_asf_integrity_err   ), // O
    `endif
    `ifdef gem_asf_dap_prot
      .emac_asf_dap_err             ( misc_signals_if.emac_asf_dap_err         ), // O
    `endif
    `ifdef gem_asf_csr_prot
      .emac_asf_csr_err             ( misc_signals_if.emac_asf_csr_err         ), // O
    `endif
  `endif

  // System Interface
  .n_txreset ( reset_if.sig_reset ), // I
  .n_rxreset ( reset_if.sig_reset ), // I

  // MDIO Interface
  .mdc      ( misc_signals_if.mdc      ), // O
  .mdio_in  ( misc_signals_if.mdio_in  ), // I
  .mdio_out ( misc_signals_if.mdio_out ), // O
  .mdio_en  ( misc_signals_if.mdio_en  ), // O

  // IEEE 1588 PTP Frame Recognition
  .sof_tx         ( misc_signals_if.sof_tx         ), // O
  .sync_frame_tx  ( misc_signals_if.sync_frame_tx  ), // O
  .delay_req_tx   ( misc_signals_if.delay_req_tx   ), // O
  .pdelay_req_tx  ( misc_signals_if.pdelay_req_tx  ), // O
  .pdelay_resp_tx ( misc_signals_if.pdelay_resp_tx ), // O
  .sof_rx         ( misc_signals_if.sof_rx         ), // O
  .sync_frame_rx  ( misc_signals_if.sync_frame_rx  ), // O
  .delay_req_rx   ( misc_signals_if.delay_req_rx   ), // O
  .pdelay_req_rx  ( misc_signals_if.pdelay_req_rx  ), // O
  .pdelay_resp_rx ( misc_signals_if.pdelay_resp_rx ), // O

  // External Filter Interface
  .ext_match1        ( misc_signals_if.ext_match1        ), // I
  .ext_match2        ( misc_signals_if.ext_match2        ), // I
  .ext_match3        ( misc_signals_if.ext_match3        ), // I
  .ext_match4        ( misc_signals_if.ext_match4        ), // I
  .ext_sa            ( misc_signals_if.ext_sa            ), // O
  .ext_sa_stb        ( misc_signals_if.ext_sa_stb        ), // O
  .ext_da            ( misc_signals_if.ext_da            ), // O
  .ext_da_stb        ( misc_signals_if.ext_da_stb        ), // O
  .ext_type          ( misc_signals_if.ext_type          ), // O
  .ext_type_stb      ( misc_signals_if.ext_type_stb      ), // O
  .ext_vlan_tag1     ( misc_signals_if.ext_vlan_tag1     ), // O
  .ext_vlan_tag1_stb ( misc_signals_if.ext_vlan_tag1_stb ), // O
  .ext_vlan_tag2     ( misc_signals_if.ext_vlan_tag2     ), // O
  .ext_vlan_tag2_stb ( misc_signals_if.ext_vlan_tag2_stb ), // O
  .ext_ip_sa         ( misc_signals_if.ext_ip_sa         ), // O
  .ext_ip_sa_stb     ( misc_signals_if.ext_ip_sa_stb     ), // O
  .ext_ip_da         ( misc_signals_if.ext_ip_da         ), // O
  .ext_ip_da_stb     ( misc_signals_if.ext_ip_da_stb     ), // O
  .ext_source_port   ( misc_signals_if.ext_source_port   ), // O
  .ext_sp_stb        ( misc_signals_if.ext_sp_stb        ), // O
  .ext_dest_port     ( misc_signals_if.ext_dest_port     ), // O
  .ext_dp_stb        ( misc_signals_if.ext_dp_stb        ), // O
  .ext_ipv6          ( misc_signals_if.ext_ipv6          ), // O
  .wol               ( misc_signals_if.wol               )  // O
);

endmodule

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
