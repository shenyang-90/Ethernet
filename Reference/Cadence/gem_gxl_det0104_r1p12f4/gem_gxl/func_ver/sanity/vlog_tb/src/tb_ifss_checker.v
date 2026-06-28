//------------------------------------------------------------------------------
// Copyright (c) 2016-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_ifss_checker.v
//   Module Name:        tb_ifss_checker
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
// Description : This module, when enabled, polls for certain ASF fault detections
//              and will automatically validate the following :
//              1. That the appropriate interrupts are driven
//              2. The correct status registers are driven
//              3. The stats are driven
//
//------------------------------------------------------------------------------


`ifndef TB_DEFS
   `include "tb_defs.v"
   `include "edma_defs.v"
`endif

module tb_ifss_checker (

   // Ram Read Clocks (needed to sample errors) ...
   input              rx_sram_read_clk,
   input              tx_sram_read_clk,

   // Auto fault checker enable .. This comes from the testcase and will enable the automatic validation of errors in interrupt/stats
   input              auto_fault_checker,
   input              auto_restart_after_fatal,

   // Test status indication from rest of TB.
   input              all_done,
   input              end_trig,

   // Rest of GEM TB APB driver (normal TB)
   input              pclk,              // amba apb clock.
   input              n_preset,          // amba apb reset.
   input              psel,
   input              psel_int,
   input       [31:0] prdata,            // APB read data from GEM.

   // SRAM READ Addresses (for checking ECC fault location)
   input       [23:0] rx_sram_read_add,
   input       [23:0] tx_sram_read_add,

   // APB interface signals.
   output  reg [12:0] paddr_ifss,        // address bus of selected master.
   output  reg [31:0] pwdata_ifss,       // write data.
   output  reg  [3:0] pwdata_par_ifss,
   output  reg        pwrite_ifss,       // peripheral write strobe.
   output  reg        penable_ifss,      // peripheral enable.
   output  reg        psel_ifss,         // peripheral select.

   // IFSS Checker Fail Signal (used to fail the test)
   output  reg        fail_ifss,
   output  reg        ifss_done

  );

initial
begin
  paddr_ifss  = 13'h0000;
  pwdata_ifss = 32'h00000000;
  pwdata_par_ifss = 4'h0;
  pwrite_ifss = 1'b0;
  penable_ifss= 1'b0;
  psel_ifss   = 1'b0;
  fail_ifss   = 1'b0;
  ifss_done   = 1'b1;
end

  `include "edma_params.v"

   // -----------------------------------------------------------------------------
   //
   //             IFSS Auto Validate Code
   //
   // -----------------------------------------------------------------------------

  reg [31:0] prdata_ifss;
  reg [31:0] prdata_ifss_save;
  bit asf_int_raised;

  bit rx_ecc_corr;
  bit rx_ecc_uncorr;
  bit rx_ram_en;
  //bit rxdpram_blk;
  bit tx_ecc_corr;
  bit tx_ecc_uncorr;
  bit tx_ram_en;
  //bit txdpram_blk;
//  bit dp_prty_errs;

  bit csr_parity_err;

  bit dap_rxclk_err;
  bit dap_txclk_err;
  bit dap_dma_err;

  bit asf_integrity_tsu_err;
  bit asf_integrity_dma_err;
  bit asf_integrity_tx_sched_err;
/*
  bit tx_axi_dma_dp_prty_errs;
  bit tx_dma_mac_dp_prty_errs;
  bit rx_dma_axi_dp_prty_errs;
  bit rx_mac_dma_dp_prty_errs;
  bit tx_axi_dma_ts_prty_errs;
  bit tx_dma_mac_ts_prty_errs;
  bit rx_dma_axi_ts_prty_errs;
  bit rx_mac_dma_ts_prty_errs;
  bit tsu_err;
  bit descr_addr_err;
  */
  reg [15:0] num_rx_ecc_corrs;
  reg [15:0] num_rx_ecc_uncorrs;
  reg [15:0] num_tx_ecc_corrs;
  reg [15:0] num_tx_ecc_uncorrs;
/*
  reg block_tx_axi_dma_dp_prty_counter;
  reg block_tx_dma_mac_dp_prty_counter;
  reg block_rx_dma_axi_dp_prty_counter;
  reg block_rx_mac_dma_dp_prty_counter;
  reg [15:0] num_tx_axi_dma_dp_prty_errs;
  reg [15:0] num_tx_dma_mac_dp_prty_errs;
  reg [15:0] num_rx_dma_axi_dp_prty_errs;
  reg [15:0] num_rx_mac_dma_dp_prty_errs;
  reg [15:0] num_ts_prty_errs;
  reg block_csr_err_counter;
  reg [15:0] num_csr_parity_errs;
  reg block_tsu_err_counter;
  reg [15:0] num_tsu_errs;
  reg block_descr_addr_err_counter;
  reg [15:0] num_descr_addr_errs;
*/
//  reg   waiting_for_int ;
  reg   expected_asf_int_fatal;
  reg   expected_asf_int_nonfatal;
  reg [6:0]  expected_asf_status;

  reg done_apb;



  reg rx_ecc_corr_r;
  reg rx_ecc_uncorr_r;
  reg tx_ecc_corr_r;
  reg tx_ecc_uncorr_r;

generate if (p_edma_asf_dap_prot & p_edma_rx_pkt_buffer) begin
  initial
  begin
    rx_ecc_uncorr_r <= 0;
    tx_ecc_uncorr_r <= 0;
  end

  always @(posedge rx_sram_read_clk)
  begin
    rx_ecc_uncorr_r  <=  `hierarchy.rx_uncorr_err
                           & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[1]);
  end
  always @(posedge tx_sram_read_clk)
  begin
    tx_ecc_uncorr_r  <=  `hierarchy.tx_uncorr_err
                           & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[1]);
  end
     assign rx_ecc_uncorr = rx_ecc_uncorr_r;
     assign tx_ecc_uncorr = tx_ecc_uncorr_r;
end else begin
    assign rx_ecc_uncorr  =  1'b0;
    assign tx_ecc_uncorr  =  1'b0;
end
endgenerate


  // first probe the design to find the correctable error and non-correctable error signals
  generate if (p_edma_asf_ecc_sram) begin
    initial
    begin
      rx_ecc_corr_r   <= 0;
      tx_ecc_corr_r   <= 0;
    //expected_ras_status <= 0;
    end
    always @(posedge rx_sram_read_clk) begin
       rx_ecc_corr_r    <=  `hierarchy.rx_corr_err
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[0]);
    end
    always @(posedge tx_sram_read_clk) begin
       tx_ecc_corr_r    <=  `hierarchy.tx_corr_err
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[0]);
    end

     assign rx_ecc_corr   = rx_ecc_corr_r;
     assign tx_ecc_corr   = tx_ecc_corr_r;

    if (p_edma_spram == 1) begin
      assign rx_ram_en    =  1'b0;  // TODO
      assign tx_ram_en    =  1'b0;  // TODO
    end else begin
      assign rx_ram_en    =  `hierarchy.rx_sram_enb;
      assign tx_ram_en    =  `hierarchy.tx_sram_enb;
    end
  //`ifdef rtl
   // assign rxdpram_blk    = `hierarchy.i_gem_reg_top.i_gem_pclk_syncs.gen_rx_pkt_buffer.gen_rx_ras_ecc.rx_dpram_uncorr_add_full;
   // assign txdpram_blk    = `hierarchy.i_gem_reg_top.i_gem_pclk_syncs.gen_tx_pkt_buffer.gen_tx_ras_ecc.tx_dpram_uncorr_add_full;
  //`else // for synthesis
  //  assign rxdpram_blk    = `hierarchy.i_gem_reg_top.i_gem_pclk_syncs.gen_rx_pkt_buffer_gen_rx_ras_ecc_rx_dpram_uncorr_add_full;
  //  assign txdpram_blk    = `hierarchy.i_gem_reg_top.i_gem_pclk_syncs.gen_tx_pkt_buffer_gen_tx_ras_ecc_tx_dpram_uncorr_add_full;
//    assign rxdpram_blk    = 1'b0; TODO
//    assign txdpram_blk    = 1'b0; TODO
//  `endif

  end else begin
    assign rx_ecc_corr    =  1'b0;
    assign rx_ram_en    =  1'b0;
   // assign rxdpram_blk    =  1'b0;
    assign tx_ecc_corr    =  1'b0;
    assign tx_ram_en    =  1'b0;
   // assign txdpram_blk    =  1'b0;
  end
  endgenerate


generate if (p_edma_asf_dap_prot) begin
   assign dap_rxclk_err =  `hierarchy.i_gem_reg_top.asf_dap_rxclk_err
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[2]);
   assign dap_txclk_err =  `hierarchy.i_gem_reg_top.asf_dap_txclk_err
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[2]);
   assign dap_dma_err   =  `hierarchy.i_gem_reg_top.asf_dap_dma_err
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[2]);
  end else begin
    assign dap_rxclk_err = 1'b0;
    assign dap_txclk_err = 1'b0;
    assign dap_dma_err   = 1'b0;
  end
endgenerate
 /*
  generate if (p_edma_asf_dap_prot) begin

`ifdef rtl
      assign tx_axi_dma_dp_prty_errs = `hierarchy.i_gem_reg_top.i_gem_registers.tx_axi_dma_dp_parity_err_pclk
                                  & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[0]);
      assign rx_dma_axi_dp_prty_errs = `hierarchy.i_gem_reg_top.i_gem_registers.rx_dma_axi_dp_parity_err_pclk
                                  & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[0]);
      assign tx_axi_dma_ts_prty_errs = `hierarchy.i_gem_reg_top.i_gem_registers.tx_axi_dma_ts_parity_err_pclk
                                  & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[2]);
      assign rx_dma_axi_ts_prty_errs = `hierarchy.i_gem_reg_top.i_gem_registers.rx_dma_axi_ts_parity_err_pclk
                               & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[2]);
`else
      assign tx_axi_dma_dp_prty_errs  = 1'b0;
      assign rx_dma_axi_dp_prty_errs  = 1'b0;
      assign tx_axi_dma_ts_prty_errs  = 1'b0;
      assign rx_dma_axi_ts_prty_errs  = 1'b0;
`endif


    assign tx_dma_mac_dp_prty_errs = `hierarchy.i_gem_reg_top.i_gem_registers.tx_dma_mac_dp_parity_err_pclk
                                & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[0]);
    assign rx_mac_dma_dp_prty_errs = `hierarchy.i_gem_reg_top.i_gem_registers.rx_mac_dma_dp_parity_err_pclk
                                & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[0]);
    assign tx_dma_mac_ts_prty_errs = `hierarchy.i_gem_reg_top.i_gem_registers.tx_dma_mac_ts_parity_err_pclk
                                & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[2]);
    assign rx_mac_dma_ts_prty_errs = `hierarchy.i_gem_reg_top.i_gem_registers.rx_mac_dma_ts_parity_err_pclk
                                & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[2]);
  end
  else begin
    assign tx_axi_dma_dp_prty_errs =  1'b0;
    assign tx_dma_mac_dp_prty_errs =  1'b0;
    assign rx_dma_axi_dp_prty_errs =  1'b0;
    assign rx_mac_dma_dp_prty_errs =  1'b0;
    assign tx_axi_dma_ts_prty_errs =  1'b0;
    assign tx_dma_mac_ts_prty_errs =  1'b0;
    assign rx_dma_axi_ts_prty_errs =  1'b0;
    assign rx_mac_dma_ts_prty_errs =  1'b0;
  end
  endgenerate
*/
  generate if (p_edma_asf_csr_prot) begin

      assign csr_parity_err     = `hierarchy_asf.asf_csr_fault
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[3]);
  end
  else begin
      assign csr_parity_err = 1'b0;
  end
  endgenerate



`ifdef rtl
  assign asf_integrity_tsu_err = `hierarchy.i_gem_reg_top.asf_integrity_tsu_err_pclk
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[6]);
  assign asf_integrity_dma_err = `hierarchy.i_gem_reg_top.asf_integrity_dma_err_pclk
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[6]);
  // synthesis cut those wires off if they are connected to zero i.e. when features not available
  `ifdef gem_asf_prot_tx_sched
    assign asf_integrity_tx_sched_err = `hierarchy.i_gem_reg_top.asf_integrity_tx_sched_err_pclk
                                & ~(`hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[6]);
  `else
    assign asf_integrity_tx_sched_err = 1'b0;
  `endif
`else
  assign asf_integrity_tsu_err = 1'b0;
  assign asf_integrity_dma_err = 1'b0;
  assign asf_integrity_tx_sched_err = 1'b0;
`endif



  /*
  generate if (p_edma_asf_prot_tsu == 1) begin
      assign tsu_err = `hierarchy.i_gem_reg_top.i_gem_registers.tsu_err
                                & ~(`hierarchy.i_gem_reg_top.i_gem_registers.ras_int_mask[3]);
  end
  else begin
      assign tsu_err = 1'b0;
  end
  endgenerate
  */

  wire [15:0]  ethernet_int_bus;      // ethernet mac interrupt signal
  wire asf_int_fatal;                // ASF fatal interrupt signal
  wire asf_int_nonfatal;             // ASF non-fatal interrupt signal
  assign ethernet_int_bus  = `hierarchy.ethernet_int_bus;
  assign asf_int_fatal    = `hierarchy.asf_int_fatal;
  assign asf_int_nonfatal = `hierarchy.asf_int_nonfatal;

  wire [6:0]  fatal_nonfatal;      // ASF Fatal or non-Fatal Interrupt Select signal
//  wire [6:0]  asf_int_mask;                   // ASF Interrupt Mask signal
  assign fatal_nonfatal    = `hierarchy_asf.i_asf_fault_log_rpt_csr.asf_fatal_nonfatal_select[6:0];
 // assign asf_int_mask      = `hierarchy_asf.i_asf_fault_log_rpt_csr.asf_int_mask[6:0];

  bit rx_sram_read_clk_b;
  bit tx_sram_read_clk_b;

  bit pclk_b;
  bit rxclk;
  bit txclk;
  bit ambaclk;
  bit [31:0] prdata_tmp;

  assign rx_sram_read_clk_b = rx_sram_read_clk;
  assign tx_sram_read_clk_b = tx_sram_read_clk;
  assign pclk_b = pclk;
  assign rxclk  = `hierarchy.rx_clk;
  assign txclk  = `hierarchy.tx_clk;
  generate if (p_edma_ext_fifo_interface == 1'b0) begin: gen_hclk
    assign ambaclk = `hierarchy.i_gem_reg_top.hclk;
  end else begin: gen_no_hclk
    assign ambaclk = 1'b0;
  end
  endgenerate  

  initial begin
   asf_int_raised = 1'b0;

    num_rx_ecc_corrs = 0;
    num_tx_ecc_corrs = 0;
    num_rx_ecc_uncorrs = 0;
    num_tx_ecc_uncorrs = 0;
 /*
    block_tx_axi_dma_dp_prty_counter = 0;
    block_tx_dma_mac_dp_prty_counter = 0;
    block_rx_dma_axi_dp_prty_counter = 0;
    block_rx_mac_dma_dp_prty_counter = 0;
    num_tx_axi_dma_dp_prty_errs = 0;
    num_tx_dma_mac_dp_prty_errs = 0;
    num_rx_dma_axi_dp_prty_errs = 0;
    num_rx_mac_dma_dp_prty_errs = 0;
    num_ts_prty_errs = 0;
  */
    //num_csr_parity_errs = 0;
    //block_csr_err_counter = 1'b0;
/*
    num_tsu_errs = 0;
    block_tsu_err_counter = 1'b0;
  */
  end

  // Monitor for the faults ..
  initial forever monitor_fault_sram(.src_clk(rx_sram_read_clk_b),.dest_clk(pclk_b),.clkbndry(1),.src_sig(rx_ecc_corr),.message("RX Correctable Error"),.count(num_rx_ecc_corrs),.exp_int(1),.asf_stat_idx(0));
  initial forever monitor_fault_sram(.src_clk(tx_sram_read_clk_b),.dest_clk(pclk_b),.clkbndry(1),.src_sig(tx_ecc_corr),.message("TX Correctable Error"),.count(num_tx_ecc_corrs),.exp_int(1),.asf_stat_idx(0));
  initial forever monitor_fault_sram(.src_clk(rx_sram_read_clk_b),.dest_clk(pclk_b),.clkbndry(1),.src_sig(rx_ecc_uncorr),.message("RX Uncorrectable Error"),.count(num_rx_ecc_uncorrs),.exp_int(1),.asf_stat_idx(1));
  initial forever monitor_fault_sram(.src_clk(tx_sram_read_clk_b),.dest_clk(pclk_b),.clkbndry(1),.src_sig(tx_ecc_uncorr),.message("TX Uncorrectable Error"),.count(num_tx_ecc_uncorrs),.exp_int(1),.asf_stat_idx(1));

  initial forever monitor_fault(.src_clk(ambaclk),.dest_clk(pclk_b),.clkbndry(1),.src_sig(dap_dma_err),.message("DMA Data path parity error"),.exp_int(1),.asf_stat_idx(2));
  initial forever monitor_fault(.src_clk(txclk),.dest_clk(pclk_b),.clkbndry(1),.src_sig(dap_txclk_err),.message("TX Data path parity error"),.exp_int(1),.asf_stat_idx(2));
  initial forever monitor_fault(.src_clk(rxclk),.dest_clk(pclk_b),.clkbndry(1),.src_sig(dap_rxclk_err),.message("RX Data path parity error"),.exp_int(1),.asf_stat_idx(2));

  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(1),.src_sig(asf_integrity_dma_err),.message("EDMA integrity error"),.exp_int(1),.asf_stat_idx(6));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(1),.src_sig(asf_integrity_tsu_err),.message("TSU integrity error"),.exp_int(1),.asf_stat_idx(6));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(1),.src_sig(asf_integrity_tx_sched_err),.message("Transmit Scheduler integrity error"),.exp_int(1),.asf_stat_idx(6));



  /*
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(tx_axi_dma_dp_prty_errs),.message("Data path parity error TX AXI -> SRAM"),.count(num_tx_axi_dma_dp_prty_errs),.exp_int(1),.ras_stat_idx(0));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(tx_dma_mac_dp_prty_errs),.message("Data path parity error TX SRAM -> MAC"),.count(num_tx_dma_mac_dp_prty_errs),.exp_int(1),.ras_stat_idx(0));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(rx_dma_axi_dp_prty_errs),.message("Data path parity error RX DMA -> AXI"),.count(num_rx_dma_axi_dp_prty_errs),.exp_int(1),.ras_stat_idx(0));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(rx_mac_dma_dp_prty_errs),.message("Data path parity error RX MAC -> SRAM"),.count(num_rx_mac_dma_dp_prty_errs),.exp_int(1),.ras_stat_idx(0));

  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(tx_axi_dma_ts_prty_errs),.message("Timestamp h parity error TX AXI -> SRAM"),.count(num_ts_prty_errs),.exp_int(1),.ras_stat_idx(3));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(tx_dma_mac_ts_prty_errs),.message("Timestamp parity error TX SRAM -> MAC"),.count(num_ts_prty_errs),.exp_int(1),.ras_stat_idx(3));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(rx_dma_axi_ts_prty_errs),.message("Timestamp parity error RX DMA -> AXI"),.count(num_ts_prty_errs),.exp_int(1),.ras_stat_idx(3));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(rx_mac_dma_ts_prty_errs),.message("Timestamp parity error RX MAC -> SRAM"),.count(num_ts_prty_errs),.exp_int(1),.ras_stat_idx(3));

*/
  //initial forever monitor_csr_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(csr_parity_err),.message("CSR parity Error"),.count(num_csr_parity_errs),.counter_blockade(block_csr_err_counter),.exp_int(1),.ras_stat_idx(1));
  initial forever monitor_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(csr_parity_err),.message("CSR parity Error"),.exp_int(1),.asf_stat_idx(3));


/*
  initial forever monitor_csr_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(tsu_err),.message("TSU Error"),.count(num_tsu_errs),.counter_blockade(block_tsu_err_counter),.exp_int(1),.ras_stat_idx(3));

  initial forever monitor_csr_fault(.src_clk(pclk_b),.dest_clk(pclk_b),.clkbndry(0),.src_sig(descr_addr_err),.message("DMA descriptor address protection Error"),.count(num_descr_addr_errs),.counter_blockade(block_descr_addr_err_counter),.exp_int(1),.ras_stat_idx(4));

  initial begin
//      $display("wol_reg fault injection after init");
//      #82000 `hierarchy.i_gem_reg_top.i_gem_registers.lockup_time = 16'h0101;
//      #82000 `hierarchy.i_gem_reg_top.i_gem_registers.wol_ip_addr = 16'h0001;
//      #20000  `hierarchy.i_gem_reg_top.i_gem_registers.wol_ip_addr = 16'h0000;
//      #10000  `hierarchy.i_gem_reg_top.i_gem_registers.stacked_vlantype = 17'h00001;
//      #5000   `hierarchy.i_gem_reg_top.i_gem_registers.wol_ip_addr = 16'h0001;
//      #5000   `hierarchy.i_gem_reg_top.i_gem_registers.stacked_vlantype = 17'h00000;
//      #5000   `hierarchy.i_gem_reg_top.i_gem_registers.wol_ip_addr = 16'h0000;
//      #5000   `hierarchy.i_gem_reg_top.i_gem_registers.wol_ip_addr = 16'h0001;

//      #53500 `hierarchy.gen_tsu.i_gem_tsu.timer_sec_calc_val[0] = 1'b1;

//      $display("DMA descr addr fault");
//      #20866 `hierarchy.gen_dma.i_edma_top.gen_pkt_buffer.gen_axi_instance.i_edma_pbuf_axi.i_edma_pbuf_axi_rx.rx_descr_ptr_req[0] = 64'h00000000_FFFF0048;
//      #207820 `hierarchy.gen_dma.i_edma_top.gen_pkt_buffer.gen_axi_instance.i_edma_pbuf_axi.i_edma_pbuf_axi_rx.rx_next_descr_ptr_inc[31:0] =
//                `hierarchy.gen_dma.i_edma_top.gen_pkt_buffer.gen_axi_instance.i_edma_pbuf_axi.i_edma_pbuf_axi_rx.rx_next_descr_ptr_inc[31:0] * 2;
//      #80 `hierarchy.gen_dma.i_edma_top.gen_pkt_buffer.gen_axi_instance.i_edma_pbuf_axi.i_edma_pbuf_axi_rx.rx_next_descr_ptr_inc[31:0] =
//                `hierarchy.gen_dma.i_edma_top.gen_pkt_buffer.gen_axi_instance.i_edma_pbuf_axi.i_edma_pbuf_axi_rx.rx_next_descr_ptr_inc[31:0] / 2;
  end
*/
  initial begin
    psel_ifss    = 1'b0;
    penable_ifss = 1'b0;
    pwdata_ifss  = 32'h00000000;
    pwdata_par_ifss = 4'h0;
    pwrite_ifss  = 1'b0;
    paddr_ifss   = 13'h0000;
//    waiting_for_int = 0;
    fail_ifss = 1'b0;
    ifss_done = 1'b0;
    expected_asf_int_fatal = 1'b0;
    expected_asf_int_nonfatal = 1'b0;
    expected_asf_status = 7'd0;
    done_apb = 1'b0;
    fork



    // This is the part that will actually drive the APB bus based on events occuring in the DUT
    // Handles clearing interrupts (and checking if RAS interrupt is expected ..), checking stats at end of test ...
    forever begin
      if (!done_apb) @(negedge pclk);
      done_apb = 1'b0;
      penable_ifss = 1'b0;
      psel_ifss    = 1'b0;
      if (auto_fault_checker )
      begin

        // Wait until end of test, and then check statistics ...
        if ((all_done | end_trig) & !ifss_done)
        begin
          $display("IFSS Checker - End Of Test triggered - checking stats ..",$time);

          // Check Status Register -should be 0 at end of test
          do_apb_read(`gem_asf_int_raw_status);
          if (prdata_ifss != 0)
          begin
            $display("\n**** IFSS Checker ERROR : ASF Status Register(offset 0x%3x) was not zero at end of test.Got 0x%8x",`gem_asf_int_raw_status,prdata_ifss);
            fail_ifss = 1;
          end

          // Check Correctable Error count
          do_apb_read(`gem_asf_sram_fault_stats);
          if (prdata_ifss[15:0] == (num_tx_ecc_corrs+num_rx_ecc_corrs))
            $display("IFSS Checker - Good ECC Count Reg(offset 0x%3x). Got 0x%8x at time %0dns",`gem_asf_sram_fault_stats,prdata_ifss,$time );
          else
          begin
            $display("\n**** IFSS Checker ERROR : BAD ECC Correctable Count Reg(offset 0x%3x). Expected 0x%4x, Got 0x%4x at time %0dns",`gem_asf_sram_fault_stats,(num_tx_ecc_corrs+num_rx_ecc_corrs),prdata_ifss[15:0],$time );
            fail_ifss = 1;
          end
/*
          // Check parity data path error count
          do_apb_read(`gem_ras_dp_err_count);
          if (prdata_ifss == {num_tx_axi_dma_dp_prty_errs,num_tx_dma_mac_dp_prty_errs,num_rx_dma_axi_dp_prty_errs,num_rx_mac_dma_dp_prty_errs})
            $display("IFSS Checker - Good Data Path Parity Error Count Reg(offset 0x%3x). Got 0x%8x at time %0dns",`gem_ras_dp_err_count,prdata_ifss,$time );
          else
          begin
            $display("\n**** IFSS Checker ERROR : BAD Data Path Parity Error Count Reg(offset 0x%3x). Expected 0x%8x, Got 0x%8x at time %0dns",`gem_ras_dp_err_count,{num_tx_axi_dma_dp_prty_errs[7:0],num_tx_dma_mac_dp_prty_errs[7:0],num_rx_dma_axi_dp_prty_errs[7:0],num_rx_mac_dma_dp_prty_errs[7:0]},prdata_ifss,$time );
            fail_ifss = 1;
          end

          // Check CSR Parity
          do_apb_read(`gem_ras_csr_err_count);
          if (prdata_ifss == {16'h0000,num_csr_parity_errs})
            $display("IFSS Checker - Good CSR Parity Count Reg(offset 0x%3x). Got 0x%8x at time %0dns",`gem_ras_csr_err_count,prdata_ifss,$time );
          else
          begin
            $display("\n**** IFSS Checker ERROR : BAD CSR Parity  Count Reg(offset 0x%3x). Expected 0x%8x, Got 0x%8x at time %0dns",`gem_ras_csr_err_count,{16'h0000,num_csr_parity_errs[15:0]},prdata_ifss,$time );
            fail_ifss = 1;
          end
*/
          ifss_done = 1'b1;
        end

        // Auto-clear interrupts as they come in ..
        for (int a = 0; a<16;a++)
        begin
          if (a==0)
          begin
            if (ethernet_int_bus[0])
            begin
              do_apb_read(12'h024);
              $display("IFSS Checker - Got interrupt(q%0d) at time %0dns, read data was 0x%8x",a,$time, prdata_ifss);
              do_apb_write(12'h024,prdata_ifss);
            end
          end else begin
            if (ethernet_int_bus[a])
            begin
              do_apb_read(12'h400 + 4*a-4);
              $display("IFSS Checker - Got interrupt(q%0d) at time %0dns, read data was 0x%8x",a,$time, prdata_ifss);
              do_apb_write((12'h400 + 4*a-4),prdata_ifss);
            end
          end
        end
/*
        // Auto-clear ASF interrupt as it come in
        if(ethernet_int_bus[16])
        begin
          do_apb_read(`gem_asf_int_status);
          if (expected_asf_int) begin
                $display("IFSS Checker - Got expected ASF interrupt at time %0dns, read data was 0x%8x",$time, prdata_ifss);
          end
          else
          begin
            $display("\n**** IFSS Checker ERROR : Got an unexpected ASF interrupt at time %0dns",$time);
            fail_ifss = 1'b1;
          end
          expected_asf_int = 1'b0;
          do_apb_write(`gem_asf_int_status,prdata_ifss);  // Clear Int ..
        end
*/
        // Auto-clear ASF interrupt as it comes in
        if(asf_int_fatal | asf_int_nonfatal)
        begin
          do_apb_read(`gem_asf_int_status);
          if (asf_int_fatal) begin
            if (expected_asf_int_fatal) begin
                  $display("IFSS Checker - Got expected ASF Fatal interrupt at time %0dns, read data was 0x%8x",$time, prdata_ifss);
            end
            else
            begin
              $display("\n**** IFSS Checker ERROR : Got an unexpected ASF Fatal interrupt at time %0dns",$time);
              fail_ifss = 1'b1;
            end
            expected_asf_int_fatal = 1'b0;
          end else begin
            if (expected_asf_int_nonfatal) begin
                  $display("IFSS Checker - Got expected ASF Non-Fatal interrupt at time %0dns, read data was 0x%8x",$time, prdata_ifss);
            end
            else
            begin
              $display("\n**** IFSS Checker ERROR : Got an unexpected ASF Non-Fatal interrupt at time %0dns",$time);
              fail_ifss = 1'b1;
            end
            expected_asf_int_nonfatal = 1'b0;
          end

          prdata_ifss_save  = prdata_ifss;
          do_apb_write(`gem_asf_int_status,prdata_ifss);  // Clear Int ..
          // Check SRAM address ...
          if(p_edma_asf_ecc_sram == 1) begin
              if (prdata_ifss_save[0])
              begin
                do_apb_read(`gem_asf_sram_corr_fault_status);
                if (prdata_ifss[31:24] === 8'h01) begin
                  if ({8'h00,prdata_ifss[23:0]} !== rx_sram_read_add)
                  begin
                    $display("\n**** IFSS Checker ERROR : Captured RX Correctable error Address incorrect at time %0dns. expected %8x, got %8x",$time,rx_sram_read_add,prdata_ifss);
                    fail_ifss = 1'b1;
                  end
                end else if (prdata_ifss[31:24] === 8'h00) begin
                  if ({8'h00,prdata_ifss[23:0]} !== tx_sram_read_add)
                  begin
                    $display("\n**** IFSS Checker ERROR : Captured TX Correctable error Address incorrect at time %0dns. expected %8x, got %8x",$time,tx_sram_read_add,prdata_ifss);
                    fail_ifss = 1'b1;
                  end
                end else begin
                    $display("\n**** IFSS Checker ERROR : Unknown SRAM Captured at time %0dns. expected %8x, got %8x",$time,rx_sram_read_add,prdata_ifss);
                    fail_ifss = 1'b1;
                end
              end
          end
          if (p_edma_asf_dap_prot & p_edma_rx_pkt_buffer) begin
              if (prdata_ifss_save[1])
              begin
                do_apb_read(`gem_asf_sram_uncorr_fault_status);
                if (prdata_ifss[31:24] === 8'h01) begin
                  if ({8'h00,prdata_ifss[23:0]} !== rx_sram_read_add)
                  begin
                    $display("\n**** IFSS Checker ERROR : Captured RX Uncorrectable error Address incorrect at time %0dns. expected %8x, got %8x",$time,rx_sram_read_add,prdata_ifss);
                    fail_ifss = 1'b1;
                  end
                end else if (prdata_ifss[31:24] === 8'h00) begin
                  if ({8'h00,prdata_ifss[23:0]} !== tx_sram_read_add)
                  begin
                    $display("\n**** IFSS Checker ERROR : Captured TX Uncorrectable error Address incorrect at time %0dns. expected %8x, got %8x",$time,tx_sram_read_add,prdata_ifss);
                    fail_ifss = 1'b1;
                  end
                end else begin
                    $display("\n**** IFSS Checker ERROR : Unknown SRAM Captured at time %0dns. expected %8x, got %8x",$time,rx_sram_read_add,prdata_ifss);
                    fail_ifss = 1'b1;
                end
              end
          end
          if (auto_restart_after_fatal) do_auto_restart();
        end

/*
        // Auto-clear ASF Status Register
        if(|expected_asf_status)
        begin
          do_apb_read(`gem_ras_status);
          // we might have more expected than actual - thats ok. As long as the actual is in the expected ...
          if ((prdata_ifss[31:0] & {23'd0,expected_ras_status}) != prdata_ifss[31:0])
          begin
            $display("\n**** IFSS Checker ERROR : RAS Status Incorrect at time %0dns. expected %3x, got %3x",$time,expected_ras_status,prdata_ifss[8:0]);
            fail_ifss = 1'b1;
          end
          expected_ras_status = expected_ras_status & ~prdata_ifss[8:0]; // Clear just the bits that we read
          do_apb_write(`gem_ras_status,prdata_ifss);  // Clear Status ..

          // Check SRAM address ...
          if(p_edma_asf_ecc_sram == 1) begin
              if (prdata_ifss[6])
              begin
                do_apb_read(`gem_rxdpram_non_crr_err_addr);
                if (prdata_ifss !== rx_sram_read_add_d1)
                begin
                  $display("\n**** IFSS Checker ERROR : ECC RX  Captured Address incorrect at time %0dns. expected %8x, got %8x",$time,rx_sram_read_add_d1,prdata_ifss);
                  fail_ifss = 1'b1;
                end
              end
              if (prdata_ifss[8])
              begin
                do_apb_read(`gem_txdpram_non_crr_err_addr);
                if (prdata_ifss !== tx_sram_read_add_d1)
                begin
                  $display("\n**** IFSS Checker ERROR : ECC TX Captured Address incorrect at time %0dns. expected %8x, got %8x",$time,tx_sram_read_add_d1,prdata_ifss);
                  fail_ifss = 1'b1;
                end
              end
          end
        end*/

      end
      else
      begin
        // Wait until end of test, and then check statistics ...
        if ((all_done | end_trig) & !ifss_done)
        begin
          $display("IFSS Checker - End Of Test triggered - checking stats ..",$time);
          // Check no ASF interrupt rise if normal mode
          if (asf_int_raised)
          begin
            $display("\n**** IFSS Checker ERROR : Error detected when no error was injected");
            fail_ifss = 1;
          end
          ifss_done = 1'b1;
        end
      end
    end

    join

  end

   task do_apb_read;
      input [12:0] paddr;
//      $display("APB read at address %08x at time %0dns",paddr,$time);
      while(psel_int === 1'b1) @(posedge pclk);
      psel_ifss    = 1'b1;
      penable_ifss = 1'b0;
      paddr_ifss   = paddr;
      pwrite_ifss  = 1'b0;
      pwdata_ifss  = 32'h00000000;
      pwdata_par_ifss = 4'h0;
      @(negedge pclk);
      penable_ifss = 1'b1;
      prdata_ifss = prdata;
      @(negedge pclk);
      done_apb = 1'b1;
   endtask

   task do_apb_write;
      input [12:0] paddr;
      input [31:0] pwdata;
      psel_ifss    = 1'b1;
      pwrite_ifss  = 1'b1;
      paddr_ifss   = paddr;
      penable_ifss = 1'b0;
      pwdata_ifss  = pwdata;
      pwdata_par_ifss = {^pwdata[31:24],^pwdata[23:16],^pwdata[15:8],^pwdata[7:0]};
      @(negedge pclk);
      penable_ifss = 1'b1;
      @(negedge pclk);
      done_apb = 1'b1;
   endtask

   task do_auto_restart;
     do_apb_read(0);  // Clear Int ..
     prdata_tmp = prdata_ifss;
     do_apb_write(0,0);  // disable
     do_apb_read(0);  // Delay
     do_apb_read(0);  // Delay
     do_apb_read(0);  // Delay
     do_apb_read(0);  // Delay
     do_apb_read(0);  // Delay
     do_apb_write(0,prdata_tmp);  // reenable
     do_apb_read(0);  // Delay
     do_apb_read(0);  // Delay
     do_apb_read(0);  // Delay
     do_apb_read(0);  // Delay
     do_apb_read(0);  // Delay
     do_apb_write(0,(prdata_ifss|(32'h00000200 & {32{prdata_tmp[3]}})));  // restart tx
   endtask
/*
   task wait_for_int;
      input [15:0] max_wait_time;
      integer wait_time;
      waiting_for_int = 1;
      wait_time = 0;
      while (ethernet_int_bus == 0 && max_wait_time > wait_time)
      begin
        @(negedge pclk);
        wait_time++;
      end
      if (wait_time == max_wait_time)
      begin
        $display("\n**** IFSS Checker ERROR : expected interrupt didnt happen at time %0dns",$time);
        fail_ifss = 1'b1;
      end

      waiting_for_int = 0;
   endtask

   task wait_for_asf_int_fatal;
      input [15:0] max_wait_time;
      integer wait_time;
      waiting_for_int = 1;
      wait_time = 0;
      while (asf_int_fatal == 1'b0 && max_wait_time > wait_time)
      begin
        @(negedge pclk);
        wait_time++;
      end
      if (wait_time == max_wait_time)
      begin
        $display("\n**** IFSS Checker ERROR : expected ASF Fatal interrupt didnt happen at time %0dns",$time);
        fail_ifss = 1'b1;
      end

      waiting_for_int = 0;
   endtask


   task wait_for_asf_int_nonfatal;
      input [15:0] max_wait_time;
      integer wait_time;
      waiting_for_int = 1;
      wait_time = 0;
      while (asf_int_nonfatal == 1'b0 && max_wait_time > wait_time)
      begin
        @(negedge pclk);
        wait_time++;
      end
      if (wait_time == max_wait_time)
      begin
        $display("\n**** IFSS Checker ERROR : expected ASF Non-Fatal interrupt didnt happen at time %0dns",$time);
        fail_ifss = 1'b1;
      end

      waiting_for_int = 0;
   endtask
*/
   task automatic monitor_fault (ref bit src_clk, ref bit dest_clk,input clkbndry,ref bit src_sig, input string message,input exp_int, input int asf_stat_idx);
      begin
        while (src_sig !== 1'b1) @(posedge src_clk);
        if (clkbndry)
        begin
          @(posedge dest_clk);
          @(posedge dest_clk);
        end
        $display("IFSS Checker - Detected ",message,". Time = %0dns ..",$time);
        if (!auto_fault_checker) asf_int_raised = 1'b1;
        if (exp_int)
        begin
          if(fatal_nonfatal[asf_stat_idx]) expected_asf_int_fatal = 1'b1;
          else expected_asf_int_nonfatal = 1'b1;
        end
        fork
        begin
          // the rtl actually has an extra delay before the register is updated due to the toggle detection
          // so delay expected_ras_status by 1 clock
          @(posedge dest_clk);
          expected_asf_status[asf_stat_idx] = 1'b1;
        end
        if (clkbndry)
        begin
          @(posedge src_clk);  // 2 for sync
          @(posedge src_clk)
          @(posedge src_clk);  // 1 to model the toggle to pulse identifier
          @(posedge src_clk);  // Final clock
        end
        join
      end
   endtask

   task automatic monitor_fault_sram (ref bit src_clk, ref bit dest_clk,input clkbndry,ref bit src_sig, input string message,ref reg [15:0] count,input exp_int, input int asf_stat_idx);
      begin
        while (src_sig !== 1'b1) @(posedge src_clk);
        while (src_sig === 1'b1) begin
          if(count < 16'hffff ) count++;
          $display("IFSS Checker - Detected ",message,". Count = %0d, Time = %0dns ..",count,$time);
          @(posedge src_clk);
        end

        if (clkbndry)
        begin
          @(posedge dest_clk);
          @(posedge dest_clk);
        end
        if (!auto_fault_checker) asf_int_raised = 1'b1;
        if (exp_int)
        begin
          if(fatal_nonfatal[asf_stat_idx]) expected_asf_int_fatal = 1'b1;
          else expected_asf_int_nonfatal = 1'b1;
        end
        fork
        begin
          // the rtl actually has an extra delay before the register is updated due to the toggle detection
          // so delay expected_ras_status by 1 clock
          @(posedge dest_clk);
          expected_asf_status[asf_stat_idx] = 1'b1;
        end
        if (clkbndry)
        begin
          @(posedge src_clk);  // 2 for sync
          @(posedge src_clk)
          @(posedge src_clk);  // 1 to model the toggle to pulse identifier
          @(posedge src_clk);  // Final clock
        end
        join
      end
    endtask

/*
   task automatic monitor_fault (ref bit src_clk, ref bit dest_clk,input clkbndry,ref bit src_sig, input string message,ref reg [15:0] count,input exp_int, input int ras_stat_idx);
      begin
        while (src_sig !== 1'b1) @(posedge src_clk);
        if (clkbndry)
        begin
          @(posedge dest_clk);
          @(posedge dest_clk);
        end
        if(count < 8'hFF ) count++;
        $display("IFSS Checker - Detected ",message,". Count = %0d, Time = %0dns ..",count,$time);
        if (exp_int) expected_ras_int = 1'b1;
        fork
        begin
          // the rtl actually has an extra delay before the register is updated due to the toggle detection
          // so delay expected_ras_status by 1 clock
          @(posedge dest_clk);
          expected_ras_status[ras_stat_idx] = 1'b1;
        end
        if (clkbndry)
        begin
          @(posedge src_clk);  // 2 for sync
          @(posedge src_clk)
          @(posedge src_clk);  // 1 to model the toggle to pulse identifier
          @(posedge src_clk);  // Final clock
        end
        join
      end
    endtask
*//*
   task automatic monitor_csr_fault (ref bit src_clk, ref bit dest_clk,input clkbndry,ref bit src_sig, input string message,ref reg [15:0] count, ref reg counter_blockade, input exp_int, input int asf_stat_idx);
      begin
        while (src_sig !== 1'b1) @(posedge src_clk) counter_blockade = 1'b0;

        if (exp_int) expected_asf_int = 1'b1;

        if (clkbndry)
        begin
          @(posedge dest_clk);
          @(posedge dest_clk);
        end

        if(~counter_blockade) begin
            count++;
            counter_blockade = 1'b1;
            $display("IFSS Checker - Detected ",message,". Count = %0d, Time = %0dns ..",count,$time);
        end

        fork
        begin
          // the rtl actually has an extra delay before the register is updated due to the toggle detection
          // so delay expected_ras_status by 1 clock
          @(posedge dest_clk);
          expected_asf_status[ras_stat_idx] = 1'b1;
        end
        if (clkbndry)
        begin
          @(posedge src_clk);  // 2 for sync
          @(posedge src_clk)
          @(posedge src_clk);  // 1 to model the toggle to pulse identifier
          @(posedge src_clk);  // Final clock
        end
        join
      end
    endtask
*/
endmodule


