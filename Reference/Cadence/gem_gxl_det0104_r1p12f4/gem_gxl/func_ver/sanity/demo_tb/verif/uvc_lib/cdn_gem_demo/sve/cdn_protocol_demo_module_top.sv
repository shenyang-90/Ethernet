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
// This file contains the demo tb, specific for the protocol under demo,
// for the cdn_demo UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_protocol_demo_module_top.sv
 *
 * This is the protocol-specific demo_tb top module.
 *
 * Imported packages:-
 * - ENET VIP base classes and user package.
 * - CDN_GEM_DEMO UVC package.
 *
 * Included code:-
 * - CDN_GEM_DEMO testbench.
 * - CDN_GEM_DEMO test libraries.
 */

`ifndef CDN_PROTOCOL_DEMO_MODULE_TOP_SV
  `define CDN_PROTOCOL_DEMO_MODULE_TOP_SV

//------------------------------------------------------------------------
// UVM package and protocol-specific packages
//------------------------------------------------------------------------

// Protocol interfaces are provided as sources in the Makefile since they cannot
// be `included inside modules.

// ENET VIP base classes and user package
import cdnEnetUvm::*;
import cdn_enet_vip_pkg::*;

// CDN_GEM_DEMO package
import cdn_gem_demo_pkg::*;

// CDN_GEM_DEMO testbench and test layers
`include "cdn_gem_demo_module_tb.sv"
`include "cdn_gem_demo_test_lib.sv"
`include "cdn_gem_demo_c_test_lib.sv"

//------------------------------------------------------------------------
// TB Signals
//------------------------------------------------------------------------

// Integer value used to convert PureSpec *Denali* Error into UVM_ERROR (count
// the number of the former and issue the latter).
integer ps_error_count;

//------------------------------------------------------------------------
// Tie Offs
//------------------------------------------------------------------------

// Disable TB interrupt
assign interrupt = 1'b0;

// APB Slave 1 IF
assign apb_reg_if_slave1.pready = 1'b1;
assign apb_reg_if_slave1.prdata = 32'd0;

//------------------------------------------------------------------------
// Assigns
//------------------------------------------------------------------------

// Misc Signals IF
assign misc_signals_if.ps_error_count = ps_error_count;

//------------------------------------------------------------------------
// Required SV Interfaces
//------------------------------------------------------------------------

// The clock signals are configured in the cdn_demo_env/cdn_gem_demo_env via
// cdn_clock UVC. Several interfaces are available as following:-
//
// Interface 0, 125 MHz (GMII and RGMII 1G mode operations):-
// - clock_if0.sig_clock_0, used as a/h/pclk            - 0.0 ns delay.
// - clock_if0.sig_clock_1, used as tx_clk              - 0.0 ns delay.
// - clock_if0.sig_clock_2, used as tx_clk_sig          - 1.0 ns delay.
// - clock_if0.sig_clock_3, used as rx_clk to RGMII PHY - 1.0 ns delay.
// - clock_if0.sig_clock_4, used as rx_clk              - 2.0 ns delay.
// - clock_if0.sig_clock_5, used as tx_clk to RGMII PHY - 2.0 ns delay.
//
// Interface 1, 50 MHz (support for RMII/MII and lower speeds, not demonstrated
// in tests):-
// - clock_if1.sig_clock_0, suitable as ref_clk - 0.0 ns delay.
//
// Interface 2, 25 MHz (support for 100M operations):-
// - clock_if2.sig_clock_0 - 0.0 ns delay.
//
// Interface 3, 2.5 MHz (support for 10M operations):-
// - clock_if3.sig_clock_0 - 0.0 ns delay.
//
// Please note that each clock signal has an independent random skew inside
// [0:200] ps, additionally to the intentional delay.

`ifdef gem_use_rgmii
  cdn_enet_vip_rgmii_if rgmii_if
  (
    `ifdef CDN_GEM_DEMO_UVM_REG_TESTS
      .sig_RGMII_TXC ( 1'b0                  ),
      .sig_RGMII_RXC ( 1'b0                  ),
      .sig_MDCLK     ( 1'b0                  )
    `else
      .sig_RGMII_TXC ( clock_if0.sig_clock_5 ),
      .sig_RGMII_RXC ( clock_if0.sig_clock_3 ),
      .sig_MDCLK     ( misc_signals_if.mdc   )
    `endif
  );
`else
  cdn_enet_vip_gmii_if gmii_if
  (
    `ifdef CDN_GEM_DEMO_UVM_REG_TESTS
      .sig_GMII_TX_CLK ( 1'b0                  ),
      .sig_GMII_RX_CLK ( 1'b0                  ),
      .sig_MDCLK       ( 1'b0                  )
    `else
      .sig_GMII_TX_CLK ( clock_if0.sig_clock_5 ),
      .sig_GMII_RX_CLK ( clock_if0.sig_clock_3 ),
      .sig_MDCLK       ( misc_signals_if.mdc   )
    `endif
  );
`endif

`ifdef gem_include_rmii
  cdn_enet_vip_rmii_if rmii_if
  (
    `ifdef CDN_GEM_DEMO_UVM_REG_TESTS
      .sig_RMII_REF_CLK ( 1'b0                  ),
      .sig_MDCLK        ( 1'b0                  )
    `else
      .sig_RMII_REF_CLK ( clock_if1.sig_clock_0 ),
      .sig_MDCLK        ( misc_signals_if.mdc   )
    `endif
  );
`endif

//------------------------------------------------------------------------
// DUT Wrapper
//------------------------------------------------------------------------

cdn_gem_demo_dut_wrapper i_gem_wrapper
(
  .reset_if            ( reset_if0            ),
  .clock_if_125mhz     ( clock_if0            ),
  .clock_if_50mhz      ( clock_if1            ),
  .clock_if_25mhz      ( clock_if2            ),
  .clock_if_2p5mhz     ( clock_if3            ),
  .apb_if              ( apb_reg_if_slave0    ),
  .axi_if              ( axi_if               ),
  `ifdef gem_use_rgmii
    .rgmii_if          ( rgmii_if             ),
  `else
    .gmii_if           ( gmii_if              ),
  `endif
  `ifdef gem_include_rmii
    .rmii_if           ( rmii_if              ),
  `endif
  .misc_signals_if     ( misc_signals_if      )
);

//------------------------------------------------------------------------------
// Transmit SRAM
//------------------------------------------------------------------------------

`ifndef gem_ext_fifo_interface
  `ifdef gem_tx_pkt_buffer
    tb_dpram
    #(
       .p_data_width ( `edma_tx_pbuf_reduncy+`gem_tx_pbuf_data ),
       .p_depth      ( 2**`gem_tx_pbuf_addr                    ),
       .p_addr_width ( `gem_tx_pbuf_addr                       )
    )
    i_txsram
    (
       .a_we         ( misc_signals_if.txsram_wea              ), // I
       .a_cs         ( misc_signals_if.txsram_ena              ), // I
       .a_clk        ( misc_signals_if.txsram_clka             ), // I
       .a_addr       ( misc_signals_if.txsram_addra            ), // I
       .a_wdata      ( misc_signals_if.txsram_dia              ), // I
       .a_rdata      ( misc_signals_if.txsram_doa              ), // O
       .b_we         ( misc_signals_if.txsram_web              ), // I
       .b_cs         ( misc_signals_if.txsram_enb              ), // I
       .b_clk        ( misc_signals_if.txsram_clkb             ), // I
       .b_addr       ( misc_signals_if.txsram_addrb            ), // I
       .b_wdata      ( misc_signals_if.txsram_dib              ), // I
       .b_rdata      ( misc_signals_if.txsram_dob              )  // O
    );
  `endif
`endif
`ifdef gem_has_802p3_br
  `ifndef gem_ext_fifo_interface
    `ifdef gem_tx_pkt_buffer
      tb_dpram
      #(
         .p_data_width ( `edma_emac_tx_pbuf_reduncy+`gem_tx_pbuf_data ),
         .p_depth      ( 2**`gem_emac_tx_pbuf_addr                    ),
         .p_addr_width ( `gem_emac_tx_pbuf_addr                       )
      )
      i_emac_txsram
      (
         .a_we         ( misc_signals_if.emac_txsram_wea              ), // I
         .a_cs         ( misc_signals_if.emac_txsram_ena              ), // I
         .a_clk        ( misc_signals_if.emac_txsram_clka             ), // I
         .a_addr       ( misc_signals_if.emac_txsram_addra            ), // I
         .a_wdata      ( misc_signals_if.emac_txsram_dia              ), // I
         .a_rdata      ( misc_signals_if.emac_txsram_doa              ), // O
         .b_we         ( misc_signals_if.emac_txsram_web              ), // I
         .b_cs         ( misc_signals_if.emac_txsram_enb              ), // I
         .b_clk        ( misc_signals_if.emac_txsram_clkb             ), // I
         .b_addr       ( misc_signals_if.emac_txsram_addrb            ), // I
         .b_wdata      ( misc_signals_if.emac_txsram_dib              ), // I
         .b_rdata      ( misc_signals_if.emac_txsram_dob              )  // O
        );
    `endif
  `endif
`endif

//------------------------------------------------------------------------------
// Receive SRAM
//------------------------------------------------------------------------------

`ifndef gem_ext_fifo_interface
  `ifdef gem_tx_pkt_buffer
    tb_dpram
    #(
       .p_data_width ( `edma_rx_pbuf_reduncy+`gem_rx_pbuf_data ),
       .p_depth      ( 2**`gem_rx_pbuf_addr                    ),
       .p_addr_width ( `gem_rx_pbuf_addr                       )
    )
    i_rxsram
    (
       .a_we         ( misc_signals_if.rxsram_wea              ), // I
       .a_cs         ( misc_signals_if.rxsram_ena              ), // I
       .a_clk        ( misc_signals_if.rxsram_clka             ), // I
       .a_addr       ( misc_signals_if.rxsram_addra            ), // I
       .a_wdata      ( misc_signals_if.rxsram_dia              ), // I
       .a_rdata      ( misc_signals_if.rxsram_doa              ), // O
       .b_we         ( misc_signals_if.rxsram_web              ), // I
       .b_cs         ( misc_signals_if.rxsram_enb              ), // I
       .b_clk        ( misc_signals_if.rxsram_clkb             ), // I
       .b_addr       ( misc_signals_if.rxsram_addrb            ), // I
       .b_wdata      ( misc_signals_if.rxsram_dib              ), // I
       .b_rdata      ( misc_signals_if.rxsram_dob              )  // O
    );
  `endif
`endif
`ifdef gem_has_802p3_br
  `ifndef gem_ext_fifo_interface
    `ifdef gem_tx_pkt_buffer
      tb_dpram
      #(
         .p_data_width ( `edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data ),
         .p_depth      ( 2**`gem_emac_rx_pbuf_addr                    ),
         .p_addr_width ( `gem_emac_rx_pbuf_addr                       )
      )
      i_emac_rxsram
      (
         .a_we         ( misc_signals_if.emac_rxsram_wea              ), // I
         .a_cs         ( misc_signals_if.emac_rxsram_ena              ), // I
         .a_clk        ( misc_signals_if.emac_rxsram_clka             ), // I
         .a_addr       ( misc_signals_if.emac_rxsram_addra            ), // I
         .a_wdata      ( misc_signals_if.emac_rxsram_dia              ), // I
         .a_rdata      ( misc_signals_if.emac_rxsram_doa              ), // O
         .b_we         ( misc_signals_if.emac_rxsram_web              ), // I
         .b_cs         ( misc_signals_if.emac_rxsram_enb              ), // I
         .b_clk        ( misc_signals_if.emac_rxsram_clkb             ), // I
         .b_addr       ( misc_signals_if.emac_rxsram_addrb            ), // I
         .b_wdata      ( misc_signals_if.emac_rxsram_dib              ), // I
         .b_rdata      ( misc_signals_if.emac_rxsram_dob              )  // O
      );
    `endif
  `endif
`endif

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
