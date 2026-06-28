//------------------------------------------------------------------------------
// Copyright (c) 2017 Cadence Design Systems, Inc.
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
//   Filename:           asf_coverage.sv
//   Module Name:        asf_coverage
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
// Description    :
//
// Functional coverage buckets and sampling for the ASF features
//
//------------------------------------------------------------------------------


`include "gem_gxl_defs.v"
`include "edma_defs.v"

module asf_coverage(
  input     disable_asf_assertions
  );

`ifndef TB_DEFS
  `include "tb_defs.v"
`endif
`ifndef MAC_TOP_HIERARCHY
  `define MAC_TOP_HIERARCHY     `hierarchy.i_gem_mac
  `define GEM_REG_TOP_HIERARCHY `hierarchy.i_gem_reg_top
`endif

`ifndef IFSS_FAULT_SIM_DIS_ASF_ASSERTIONS
  `ifdef ABV_ON
     `define ABV_ON_ASF
  `endif
`else
  `define ABV_ON_ASF
`endif


// Wire declarations for coverpoints (mostly)
wire n_preset;
wire pclk;
wire n_tx_r_reset;
wire tx_r_clk;
wire asf_sram_corr_err;
wire asf_sram_uncorr_err;
wire asf_dap_err;
wire asf_csr_err;
wire asf_trans_to_err;
wire asf_protocol_err;
wire asf_integrity_err;
wire asf_int_nonfatal;
wire asf_int_fatal;

assign n_preset =`hier_gem_top.n_preset;
assign pclk =`hier_gem_top.pclk;

`ifndef gem_ext_fifo_interface
  `ifdef gem_rx_pkt_buffer
    `ifdef gem_spram
      assign n_tx_r_reset =`hierarchy.ambarst_n;
      assign tx_r_clk =`hierarchy.ambaclk;
    `else
      assign n_tx_r_reset =`hierarchy.n_txreset;
      assign tx_r_clk =`hierarchy.tx_clk;
    `endif
  `else
    assign n_tx_r_reset =`hierarchy.n_txreset;
    assign tx_r_clk =`hierarchy.tx_clk;
  `endif
`else
  assign n_tx_r_reset =`hierarchy.n_txreset;
  assign tx_r_clk =`hierarchy.tx_clk;
`endif


`ifdef gem_asf_ecc_sram
assign asf_sram_corr_err           = `hierarchy.asf_sram_corr_err;
`else
assign asf_sram_corr_err           = 1'b0;
`endif
`ifdef gem_asf_dap_prot
assign asf_sram_uncorr_err         = `hierarchy.asf_sram_uncorr_err;
assign asf_dap_err                 = `hierarchy.asf_dap_err;
`else
assign asf_sram_uncorr_err         = 1'b0;
assign asf_dap_err                 = 1'b0;
`endif
`ifdef gem_asf_csr_prot
assign asf_csr_err                 = `hierarchy.asf_csr_err;
`else
assign asf_sram_corr_err           = 1'b0;
`endif
assign asf_trans_to_err            = `hierarchy.asf_trans_to_err;
assign asf_protocol_err            = `hierarchy.asf_protocol_err;
`ifdef gem_asf_integrity_prot
assign asf_integrity_err           = `hierarchy.asf_integrity_err;
`else
assign asf_integrity_err           = 1'b0;
`endif
assign asf_int_nonfatal            = `hierarchy.asf_int_nonfatal;
assign asf_int_fatal               = `hierarchy.asf_int_fatal;

logic asf_dap_prot;
logic asf_csr_prot;
logic asf_trans_to_prot;
logic asf_integrity_prot;
logic asf_ecc_sram;
logic asf_prot_tsu;
logic asf_prot_tx_sched;
logic asf_host_par;
`ifdef gem_asf_enable
  assign asf_dap_prot = 1;
  assign asf_csr_prot = 1;
  assign asf_integrity_prot = 1;
`ifdef gem_asf_ecc_sram
  assign asf_ecc_sram = 1;
`else
  assign asf_ecc_sram = 0;
`endif
`ifdef gem_asf_prot_tsu
  assign asf_prot_tsu = 1;
`else
  assign asf_prot_tsu = 0;
`endif
`ifdef gem_asf_prot_tx_sched
  assign asf_prot_tx_sched = 1;
`else
  assign asf_prot_tx_sched = 0;
`endif
`ifdef gem_asf_host_par
  assign asf_host_par = 1;
`else
  assign asf_host_par = 0;
`endif
`else // gem_asf_enable
`ifdef gem_asf_dap_prot
  assign asf_dap_prot = 1;
`else
  assign asf_dap_prot = 0;
`endif

`ifdef gem_asf_csr_prot
  assign asf_csr_prot = 1;
`else
  assign asf_csr_prot = 0;
`endif

assign asf_trans_to_prot = 1;

`ifdef gem_asf_integrity_prot
  assign asf_integrity_prot = 1;
`else
  assign asf_integrity_prot = 0;
`endif
  assign asf_ecc_sram = 0;
  assign asf_prot_tsu = 0;
  assign asf_prot_tx_sched = 0;
  assign asf_host_par = 0;
`endif // gem_asf_enable


covergroup cg_asf_defines @(posedge pclk);
  cp_asf_dap_prot : coverpoint (asf_dap_prot) {
    bins        asf_dap_prot_off    = {0};
    bins        asf_dap_prot_on     = {1};
  }
  cp_asf_csr_prot : coverpoint (asf_csr_prot) {
    bins        asf_csr_prot_off    = {0};
    bins        asf_csr_prot_on     = {1};
  }
  cp_asf_trans_to_prot : coverpoint (asf_trans_to_prot) {
    bins        asf_trans_to_prot_off    = {0};
    bins        asf_trans_to_prot_on     = {1};
  }
  cp_asf_integrity_prot : coverpoint (asf_integrity_prot) {
    bins        asf_integrity_prot_off    = {0};
    bins        asf_integrity_prot_on     = {1};
  }
  cp_asf_ecc_sram : coverpoint (asf_ecc_sram) {
    bins        asf_ecc_sram_off    = {0};
    bins        asf_ecc_sram_on     = {1};
  }
  cp_asf_prot_tsu : coverpoint (asf_prot_tsu) {
    bins        asf_prot_tsu_off    = {0};
    bins        asf_prot_tsu_on     = {1};
  }
  cp_asf_prot_tx_sched : coverpoint (asf_prot_tx_sched) {
    bins        asf_prot_tx_sched_off    = {0};
    bins        asf_prot_tx_sched_on     = {1};
  }
  cp_asf_host_par : coverpoint (asf_host_par) {
    bins        asf_host_par_off    = {0};
    bins        asf_host_par_on     = {1};
  }
endgroup
cg_asf_defines i_cg_asf_defines = new();

  `ifdef gem_asf_host_par
wire pwdata_bad_par;
wire [31:0] pwdata;
wire [3:0]  pwdata_par;
assign pwdata = `GEM_REG_TOP_HIERARCHY.pwdata;
assign pwdata_par = `GEM_REG_TOP_HIERARCHY.pwdata_par;
assign pwdata_bad_par = !(pwdata_par[3:0] == {^pwdata[31:24],^pwdata[23:16],^pwdata[15:8],^pwdata[7:0]});

// 1.1.1 check that dap error interrupt status is set when bad parity is driven into the registers
`ifdef ABV_ON_ASF
       property check_asf_dap_int_when_host_par_bad_parity;
      @(posedge pclk) disable iff (!n_preset)
        ((1'b1==pwdata_bad_par) && (`hier_gem_top.pwrite && `hier_gem_top.psel && `hier_gem_top.penable))
        |=>  (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[2]);
       endproperty
      assert_check_asf_dap_int_when_host_par_bad_parity: assert property (check_asf_dap_int_when_host_par_bad_parity);
`endif

// 2.1.2 CSR writes with good and bad parity
covergroup cg_asf_csr_par_writes @(`hier_gem_top.pwrite && `hier_gem_top.psel && `hier_gem_top.penable);
  asf_csr_par_cp : coverpoint (pwdata_bad_par) {
    bins        asf_good_parity    = {0};
    bins        asf_bad_parity    = {1};
  }
endgroup
cg_asf_csr_par_writes i_cg_asf_csr_par_writes = new();

// 2.1.3 check that the parity generated on a read is always correct
wire [31:0] prdata;
wire [3:0]  prdata_par;
assign prdata = `GEM_REG_TOP_HIERARCHY.prdata;
assign prdata_par = `GEM_REG_TOP_HIERARCHY.prdata_par;
`ifdef ABV_ON_ASF
       property check_asf_prdata_par_correct;
      @(posedge pclk) disable iff (!n_preset | disable_asf_assertions)
        (!(`hier_gem_top.pwrite) && `hier_gem_top.psel && `hier_gem_top.penable)
        |->  (prdata_par[3:0] == {^prdata[31:24],^prdata[23:16],^prdata[15:8],^prdata[7:0]});
       endproperty
      assert_check_asf_prdata_par_correct : assert property (check_asf_prdata_par_correct);
`endif // ABV_ON_ASF
`endif // gem_asf_host_par



// 2.1.4.1 check that mask are disabled correctly when programmed
  `define ASS_ASF_INT_MASK_PROGRAM(NUM_BIT) \
       property check_asf_int_mask_dis_when_prog_``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        (`hier_gem_top.pwrite && `hier_gem_top.psel && `hier_gem_top.penable && `hier_gem_top.pwdata[NUM_BIT] && (`hier_gem_top.paddr == `gem_asf_int_mask)) \
        |=> (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_int_mask[NUM_BIT]); \
       endproperty \
      assert_check_asf_int_mask_dis_when_prog_``NUM_BIT: assert property (check_asf_int_mask_dis_when_prog_``NUM_BIT);

`ifdef ABV_ON_ASF
      `ASS_ASF_INT_MASK_PROGRAM(0)  // check mask bit for SRAM correctable error interrupt
      `ASS_ASF_INT_MASK_PROGRAM(1)  // check mask bit for SRAM uncorrectable error interrupt
      `ASS_ASF_INT_MASK_PROGRAM(2)  // check mask bit for data and address paths parity error interrupt
      `ASS_ASF_INT_MASK_PROGRAM(3)  // check mask bit for configuration and status registers error interrupt
      `ASS_ASF_INT_MASK_PROGRAM(4)  // check mask bit for transaction timeouts error interrupt
      `ASS_ASF_INT_MASK_PROGRAM(5)  // check mask bit for protocol error interrupt
      `ASS_ASF_INT_MASK_PROGRAM(6)  // check mask bit for integrity error interrupt
`endif // ABV_ON_ASF

// 2.1.4.2 check that interrupts are disabled correctly when mask disabled
  `define ASS_ASF_INT_DIS_WHEN_MASK_DIS(NUM_BIT) \
       property check_asf_int_dis_when_mask_dis_``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_int_mask[NUM_BIT]) \
        |->  !(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_status[NUM_BIT]); \
       endproperty \
      assert_check_asf_int_dis_when_mask_dis_``NUM_BIT: assert property (check_asf_int_dis_when_mask_dis_``NUM_BIT);

`ifdef ABV_ON_ASF
      `ASS_ASF_INT_DIS_WHEN_MASK_DIS(0)  // check no interrupt form SRAM correctable error when mask bit disabled
      `ASS_ASF_INT_DIS_WHEN_MASK_DIS(1)  // check no interrupt form SRAM uncorrectable error when mask bit disabled
      `ASS_ASF_INT_DIS_WHEN_MASK_DIS(2)  // check no interrupt form data and address paths parity error when mask bit disabled
      `ASS_ASF_INT_DIS_WHEN_MASK_DIS(3)  // check no interrupt form configuration and status registers error when mask bit disabled
      `ASS_ASF_INT_DIS_WHEN_MASK_DIS(4)  // check no interrupt form transaction timeouts error when mask bit disabled
      `ASS_ASF_INT_DIS_WHEN_MASK_DIS(5)  // check no interrupt form protocol error when mask bit disabled
      `ASS_ASF_INT_DIS_WHEN_MASK_DIS(6)  // check no interrupt form integrity error when mask bit disabled
`endif // ABV_ON_ASF

// 2.1.4.3 check that (non)fatal interrupts are never driven when asf int status is zero
`ifdef ABV_ON_ASF
       property check_asf_ints_not_driven_when_asf_status_zero;
      @(posedge pclk) disable iff (!n_preset)
        (1'b0==(|(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_status)))
        |->  ((!asf_int_nonfatal) && (!asf_int_fatal));
       endproperty
      assert_check_asf_ints_not_driven_when_asf_status_zero: assert property (check_asf_ints_not_driven_when_asf_status_zero);
`endif // ABV_ON_ASF

// 2.1.5 each disable/mask had been set and unset
 `define CP_ASF_SET_UNSET(REG_PATH,REG_NAME,NUM_BIT) \
    cp_asf_bit_set_unset_``REG_NAME``NUM_BIT : coverpoint (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.``REG_PATH``REG_NAME[NUM_BIT]) { \
      bins asf_bit_unset  = {0}; \
      bins asf_bit_set  = {1}; \
    }

  covergroup cg_asf_each_dis_set_unset @(posedge `hier_gem_top.pclk);
   `ifdef gem_asf_integrity_prot
   `CP_ASF_SET_UNSET(,asf_fatal_nonfatal_select,6)
   `CP_ASF_SET_UNSET(,asf_int_mask,6)
   `endif
   `ifdef gem_asf_ecc_sram
   `CP_ASF_SET_UNSET(,asf_fatal_nonfatal_select,0)
   `CP_ASF_SET_UNSET(,asf_int_mask,0)
   `endif
   `ifdef gem_asf_dap_prot
   `CP_ASF_SET_UNSET(,asf_fatal_nonfatal_select,1)
   `CP_ASF_SET_UNSET(,asf_int_mask,1)
   `CP_ASF_SET_UNSET(,asf_fatal_nonfatal_select,2)
   `CP_ASF_SET_UNSET(,asf_int_mask,2)
   `endif
   `ifdef gem_asf_csr_prot
   `CP_ASF_SET_UNSET(,asf_fatal_nonfatal_select,3)
   `CP_ASF_SET_UNSET(,asf_int_mask,3)
   `endif
   `ifdef gem_asf_trans_to_prot
     `ifndef gem_ext_fifo_interface
       `ifdef gem_tx_pkt_buffer
         `CP_ASF_SET_UNSET(gen_trans_to_added.,asf_trans_to_fault_mask_r,2)
         `CP_ASF_SET_UNSET(gen_trans_to_added.,asf_trans_to_fault_mask_r,3)
         `CP_ASF_SET_UNSET(gen_trans_to_added.,asf_trans_to_fault_mask_r,4)
          cp_asf_bit_set_unset_asf_trans_to_en : coverpoint (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.gen_trans_to_added.gen_trans_to_ctrl.asf_trans_to_en_r) {
            bins asf_bit_unset  = {0};
            bins asf_bit_set  = {1};
          }
         `endif
       `endif
   `endif
   `CP_ASF_SET_UNSET(,asf_fatal_nonfatal_select,4)
   `CP_ASF_SET_UNSET(,asf_int_mask,4)
   `CP_ASF_SET_UNSET(gen_trans_to_added.,asf_trans_to_fault_mask_r,0)
   `CP_ASF_SET_UNSET(gen_trans_to_added.,asf_trans_to_fault_mask_r,1)
   `CP_ASF_SET_UNSET(,asf_fatal_nonfatal_select,5)
   `CP_ASF_SET_UNSET(,asf_int_mask,5)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,0)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,1)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,2)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,3)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,4)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,5)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,6)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,7)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,8)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,16)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,17)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,18)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,19)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,20)
   `CP_ASF_SET_UNSET(gen_protocol_check_added.,asf_protocol_fault_mask_r,21)
  endgroup
  cg_asf_each_dis_set_unset i_cg_asf_each_dis_set_unset = new();

// 2.1.6 each interrupt source is driven
 `define CP_ASF_INT_DRIVEN(REG_NAME,NUM_BIT) \
    cp_asf_int_src_driven_``REG_NAME``NUM_BIT : coverpoint (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.``REG_NAME[NUM_BIT]) { \
      bins asf_int_src_driven  = {1}; \
    }

  covergroup cg_asf_each_int_src_driven @(posedge `hier_gem_top.pclk);
   `ifdef gem_asf_ecc_sram
   `CP_ASF_INT_DRIVEN(asf_int_status,0)
   `CP_ASF_INT_DRIVEN(asf_int_raw_status,0)
   `endif
   `ifdef gem_asf_dap_prot
   `CP_ASF_INT_DRIVEN(asf_int_status,1)
   `CP_ASF_INT_DRIVEN(asf_int_raw_status,1)
   `CP_ASF_INT_DRIVEN(asf_int_status,2)
   `CP_ASF_INT_DRIVEN(asf_int_raw_status,2)
   `endif
   `ifdef gem_asf_csr_prot
   `CP_ASF_INT_DRIVEN(asf_int_status,3)
   `CP_ASF_INT_DRIVEN(asf_int_raw_status,3)
   `endif
   `CP_ASF_INT_DRIVEN(asf_int_status,4)
   `CP_ASF_INT_DRIVEN(asf_int_raw_status,4)
   `CP_ASF_INT_DRIVEN(asf_trans_to_fault_status_padded,0)
   `CP_ASF_INT_DRIVEN(asf_trans_to_fault_status_padded,1)
   `ifdef gem_asf_trans_to_prot
     `ifndef gem_ext_fifo_interface
       `ifdef gem_tx_pkt_buffer
         `CP_ASF_INT_DRIVEN(asf_trans_to_fault_status_padded,2)
         `CP_ASF_INT_DRIVEN(asf_trans_to_fault_status_padded,3)
         `CP_ASF_INT_DRIVEN(asf_trans_to_fault_status_padded,4)
       `endif
     `endif
   `endif
   `CP_ASF_INT_DRIVEN(asf_int_status,5)
   `CP_ASF_INT_DRIVEN(asf_int_raw_status,5)
   `ifdef gem_asf_integrity_prot
   `CP_ASF_INT_DRIVEN(asf_int_status,6)
   `CP_ASF_INT_DRIVEN(asf_int_raw_status,6)
   `endif
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,0)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,1)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,2)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,3)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,4)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,5)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,6)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,7)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,8)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,16)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,17)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,18)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,19)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,20)
   `CP_ASF_INT_DRIVEN(asf_protocol_fault_status_padded,21)
  endgroup
  cg_asf_each_int_src_driven i_cg_asf_each_int_src_driven = new();

// 2.1.7 all error and interrupt pins are driven
 `define CP_ASF_PINS_DRIVEN(PIN_NAME) \
    cp_asf_pins_driven_``PIN_NAME : coverpoint (`hier_gem_top.PIN_NAME) { \
      bins asf_pins_driven  = {1}; \
    }

  covergroup cg_asf_pins_driven @(posedge `hier_gem_top.pclk);
   `ifdef gem_asf_ecc_sram
   `CP_ASF_PINS_DRIVEN(asf_sram_corr_err)
   `endif
   `ifdef gem_asf_dap_prot
   `CP_ASF_PINS_DRIVEN(asf_sram_uncorr_err)
   `CP_ASF_PINS_DRIVEN(asf_dap_err)
   `endif
   `ifdef gem_asf_csr_prot
   `CP_ASF_PINS_DRIVEN(asf_csr_err)
   `endif
   `CP_ASF_PINS_DRIVEN(asf_trans_to_err)
   `CP_ASF_PINS_DRIVEN(asf_protocol_err)
   `ifdef gem_asf_integrity_prot
   `CP_ASF_PINS_DRIVEN(asf_integrity_err)
   `endif
   // ASF and fatal and non-fatal interrupts
   `CP_ASF_PINS_DRIVEN(asf_int_nonfatal)
   `CP_ASF_PINS_DRIVEN(asf_int_fatal)

   `ifdef gem_has_802p3_br
   // ASF comman output error indications for emac
   `ifdef gem_asf_ecc_sram
   `CP_ASF_PINS_DRIVEN(emac_asf_sram_corr_err)
   `endif
   `ifdef gem_asf_dap_prot
   `CP_ASF_PINS_DRIVEN(emac_asf_sram_uncorr_err)
   `CP_ASF_PINS_DRIVEN(emac_asf_dap_err)
   `endif
   `ifdef gem_asf_csr_prot
   `CP_ASF_PINS_DRIVEN(emac_asf_csr_err)
   `endif
   `CP_ASF_PINS_DRIVEN(emac_asf_trans_to_err)
   `CP_ASF_PINS_DRIVEN(emac_asf_protocol_err)
   `ifdef gem_asf_integrity_prot
   `CP_ASF_PINS_DRIVEN(emac_asf_integrity_err)
   `endif
   // ASF and fatal and non-fatal interrupts for emac
   `CP_ASF_PINS_DRIVEN(emac_asf_int_nonfatal)
   `CP_ASF_PINS_DRIVEN(emac_asf_int_fatal)
   `endif
  endgroup
  cg_asf_pins_driven i_cg_asf_fault_log_rpt = new();

// 2.1.9 each bit in the interrupt test register is triggered
 `define CP_ASF_INT_TEST_TRIGGER(NUM_BIT) \
    cp_asf_int_test_trigger``NUM_BIT : coverpoint (`hier_gem_top.pwdata[NUM_BIT]) { \
      bins asf_int_test_trigger  = {1}; \
    }

  covergroup cg_asf_int_test_trigger @(posedge   `GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_test_active);
   `ifdef gem_asf_ecc_sram
   `CP_ASF_INT_TEST_TRIGGER(0)
   `endif
   `ifdef gem_asf_dap_prot
   `CP_ASF_INT_TEST_TRIGGER(1)
   `CP_ASF_INT_TEST_TRIGGER(2)
   `endif
   `ifdef gem_asf_csr_prot
   `CP_ASF_INT_TEST_TRIGGER(3)
   `endif
   `CP_ASF_INT_TEST_TRIGGER(4)
   `CP_ASF_INT_TEST_TRIGGER(5)
   `ifdef gem_asf_integrity_prot
   `CP_ASF_INT_TEST_TRIGGER(6)
   `endif
  endgroup
  cg_asf_int_test_trigger i_cg_asf_int_test_trigger = new();

// 2.1.10 check that hardware emulation of faults trigger an interrupt status correctly
  `define ASS_ASF_INT_FAULT_TRIGGER_CORRECT(NUM_BIT) \
       property check_asf_int_fault_trigger_correct_``NUM_BIT; \
      @(negedge pclk) disable iff (!n_preset) \
        ((`hier_gem_top.pwdata[NUM_BIT]) && (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_test_active)) \
        |=> (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[NUM_BIT]); \
       endproperty \
      assert_check_asf_int_fault_trigger_correct_``NUM_BIT: assert property (check_asf_int_fault_trigger_correct_``NUM_BIT);

`ifdef ABV_ON_ASF
   `ifdef gem_asf_ecc_sram
      `ASS_ASF_INT_FAULT_TRIGGER_CORRECT(0)  // Emulate SRAM correctable error interrupt
   `endif
   `ifdef gem_asf_dap_prot
      `ASS_ASF_INT_FAULT_TRIGGER_CORRECT(1)  // Emulate SRAM uncorrectable error interrupt
      `ASS_ASF_INT_FAULT_TRIGGER_CORRECT(2)  // Emulate data and address paths parity error interrupt
   `endif
   `ifdef gem_asf_csr_prot
      `ASS_ASF_INT_FAULT_TRIGGER_CORRECT(3)  // Emulate configuration and status registers error interrupt
   `endif
      `ASS_ASF_INT_FAULT_TRIGGER_CORRECT(4)  // Emulate transaction timeouts error interrupt
      `ASS_ASF_INT_FAULT_TRIGGER_CORRECT(5)  // Emulate protocol error interrupt
   `ifdef gem_asf_integrity_prot
      `ASS_ASF_INT_FAULT_TRIGGER_CORRECT(6)  // Emulate integrity error interrupt
   `endif
`endif // ABV_ON_ASF

// 2.1.11 all interrupt sources are programmed as fatal and nonfatal interrupts
 `define CP_ASF_INT_FATAL_NONFATAL(REG_PATH,REG_NAME,NUM_BIT) \
    cp_``REG_NAME``NUM_BIT : coverpoint (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.``REG_PATH``REG_NAME[NUM_BIT]) { \
      bins asf_int_nonfatal_sel = {0}; \
      bins asf_int_fatal_sel  = {1}; \
    }

  covergroup cg_asf_fatal_nonfatal_prog @(posedge `hier_gem_top.pclk);
   `ifdef gem_asf_ecc_sram
   `CP_ASF_INT_FATAL_NONFATAL(,asf_fatal_nonfatal_select,0)
   `endif
   `ifdef gem_asf_dap_prot
   `CP_ASF_INT_FATAL_NONFATAL(,asf_fatal_nonfatal_select,1)
   `CP_ASF_INT_FATAL_NONFATAL(,asf_fatal_nonfatal_select,2)
   `endif
   `ifdef gem_asf_csr_prot
   `CP_ASF_INT_FATAL_NONFATAL(,asf_fatal_nonfatal_select,3)
   `endif
   `CP_ASF_INT_FATAL_NONFATAL(,asf_fatal_nonfatal_select,4)
   `CP_ASF_INT_FATAL_NONFATAL(,asf_fatal_nonfatal_select,5)
   `ifdef gem_asf_integrity_prot
   `CP_ASF_INT_FATAL_NONFATAL(,asf_fatal_nonfatal_select,6)
   `endif
  endgroup
  cg_asf_fatal_nonfatal_prog i_cg_asf_fatal_nonfatal_prog = new();

// 2.1.12. check that the fatal and non-fatal interrupts are driven correctly based on programmed configuration
  `define ASS_INT_STATUS_1_THEN_NONFATAL_INT_DRIVEN(NUM_BIT) \
       property check_asf_int_status_1_then_nonfatal_int_driven_``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_status[NUM_BIT]) \
        && !(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_fatal_nonfatal_select[NUM_BIT])) \
        |-> (`hier_gem_top.asf_int_nonfatal); \
       endproperty \
      assert_check_asf_int_status_1_then_nonfatal_int_driven_``NUM_BIT: assert property (check_asf_int_status_1_then_nonfatal_int_driven_``NUM_BIT);

`ifdef ABV_ON_ASF
      `ASS_INT_STATUS_1_THEN_NONFATAL_INT_DRIVEN(0)  // check non-fatal for SRAM correctable error interrupt
      `ASS_INT_STATUS_1_THEN_NONFATAL_INT_DRIVEN(1)  // check non-fatal for SRAM uncorrectable error interrupt
      `ASS_INT_STATUS_1_THEN_NONFATAL_INT_DRIVEN(2)  // check non-fatal for data and address paths parity error interrupt
      `ASS_INT_STATUS_1_THEN_NONFATAL_INT_DRIVEN(3)  // check non-fatal for configuration and status registers error interrupt
      `ASS_INT_STATUS_1_THEN_NONFATAL_INT_DRIVEN(4)  // check non-fatal for transaction timeouts error interrupt
      `ASS_INT_STATUS_1_THEN_NONFATAL_INT_DRIVEN(5)  // check non-fatal for protocol error interrupt
      `ASS_INT_STATUS_1_THEN_NONFATAL_INT_DRIVEN(6)  // check non-fatal for integrity error interrupt
`endif // ABV_ON_ASF

  `define ASS_INT_STATUS_1_THEN_FATAL_INT_DRIVEN(NUM_BIT) \
       property check_asf_int_status_1_then_fatal_int_driven_``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_status[NUM_BIT]) \
        && (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_fatal_nonfatal_select[NUM_BIT])) \
        |-> (`hier_gem_top.asf_int_fatal); \
       endproperty \
      assert_check_asf_int_status_1_then_fatal_int_driven_``NUM_BIT: assert property (check_asf_int_status_1_then_fatal_int_driven_``NUM_BIT);

`ifdef ABV_ON_ASF
      `ASS_INT_STATUS_1_THEN_FATAL_INT_DRIVEN(0)  // check fatal for SRAM correctable error interrupt
      `ASS_INT_STATUS_1_THEN_FATAL_INT_DRIVEN(1)  // check fatal for SRAM uncorrectable error interrupt
      `ASS_INT_STATUS_1_THEN_FATAL_INT_DRIVEN(2)  // check fatal for data and address paths parity error interrupt
      `ASS_INT_STATUS_1_THEN_FATAL_INT_DRIVEN(3)  // check fatal for configuration and status registers error interrupt
      `ASS_INT_STATUS_1_THEN_FATAL_INT_DRIVEN(4)  // check fatal for transaction timeouts error interrupt
      `ASS_INT_STATUS_1_THEN_FATAL_INT_DRIVEN(5)  // check fatal for protocol error interrupt
      `ASS_INT_STATUS_1_THEN_FATAL_INT_DRIVEN(6)  // check fatal for integrity error interrupt
`endif // ABV_ON_ASF

// 2.1.13 fatal and non-fatal are set at the same time
  covergroup cg_asf_int_fatal_nonfatal_1_at_same_time @(posedge `hier_gem_top.pclk);
   // ASF and fatal and non-fatal interrupts
   `CP_ASF_PINS_DRIVEN(asf_int_nonfatal)
   `CP_ASF_PINS_DRIVEN(asf_int_fatal)
   cp_asf_cross_fatal_nonfatal : cross cp_asf_pins_driven_asf_int_nonfatal, cp_asf_pins_driven_asf_int_fatal {
      ignore_bins asf_ignore_unset = binsof(cp_asf_pins_driven_asf_int_fatal) intersect{0}
                                     || binsof(cp_asf_pins_driven_asf_int_nonfatal) intersect {0};
   }
  endgroup
  cg_asf_int_fatal_nonfatal_1_at_same_time i_cg_asf_int_fatal_nonfatal_1_at_same_time = new();

// 2.1.14 coverage on number of simultaneous fault sources
logic [31:0]   num_of_faults = 0;
initial begin
   forever begin
      @(posedge `hier_gem_top.pclk);
         num_of_faults = 0;
         if ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[0]) == 1'b1) num_of_faults    += 1;
         if ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[1]) == 1'b1) num_of_faults    += 1;
         if ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[2]) == 1'b1) num_of_faults    += 1;
         if ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[3]) == 1'b1) num_of_faults    += 1;
         if ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[4]) == 1'b1) num_of_faults    += 1;
         if ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[5]) == 1'b1) num_of_faults    += 1;
         if ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[6]) == 1'b1) num_of_faults    += 1;
   end
end

  covergroup cg_asf_num_of_faults @(posedge `hier_gem_top.pclk);
    cp_asf_num_of_faults : coverpoint (num_of_faults) {
      ignore_bins asf_no_fault                = {0};
      bins asf_one_fault_simultaneous         = {1};
      bins asf_2to7_faults_simultaneous       = {[2:7]};
      illegal_bins asf_gr_faults_simultaneous = {[7:$]};
    }
  endgroup
  cg_asf_num_of_faults i_cg_asf_num_of_faults = new();


// 2.1.15 check that for a single source, fatal and non-fatal cannot be triggered
`ifdef ABV_ON_ASF
       property check_asf_single_int_fatal_or_nonfatal_triggered;
      @(posedge pclk) disable iff (!n_preset)
        ($onehot(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_status))
        |->  ((asf_int_nonfatal^asf_int_fatal) == 1'b1);
       endproperty
      assert_check_asf_single_int_fatal_or_nonfatal_triggered: assert property (check_asf_single_int_fatal_or_nonfatal_triggered);
`endif // ABV_ON_ASF


`ifndef gem_ext_fifo_interface
`ifdef gem_rx_pkt_buffer
`ifdef gem_asf_enable
`ifdef gem_asf_ecc_sram

`ifdef ABV_ON_ASF
// 2.1.16 check that the stats counters are incremented correctly
       property check_asf_sram_corr_stats_inc_correct;
      @(posedge pclk) disable iff (!n_preset)
        (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_corr_fault)
        |->  (((($past(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_sram_protect_added.gen_asf_sram_corr_count.asf_sram_fault_corr_stats_r))
              + ($past(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_corr_fault_stats_upd))) >= 16'hffff)
              ? 16'hffff
              : (($past(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_sram_protect_added.gen_asf_sram_corr_count.asf_sram_fault_corr_stats_r))
              + ($past(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_corr_fault_stats_upd))))
              == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_sram_protect_added.gen_asf_sram_corr_count.asf_sram_fault_corr_stats_r);
       endproperty
      assert_check_asf_sram_corr_stats_inc_correct: assert property (check_asf_sram_corr_stats_inc_correct);

// 2.1.17 check that the rollover point counters are correctly observed
       property check_asf_sram_corr_stats_rollover_correct;
      @(posedge pclk) disable iff (!n_preset)
        ((((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_sram_protect_added.gen_asf_sram_corr_count.asf_sram_fault_corr_stats_r))
              + ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_corr_fault_stats_upd))) >= 16'hffff)
        |=> (16'hffff == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_sram_protect_added.gen_asf_sram_corr_count.asf_sram_fault_corr_stats_r));
       endproperty
      assert_check_asf_sram_corr_stats_rollover_correct: assert property (check_asf_sram_corr_stats_rollover_correct);
`endif // ABV_ON_ASF

// 2.1.18 asf_sram_fault_stats_upd
// 2.1.19 cross asf_sram_fault_stats_upd X counter overflow
  covergroup cg_asf_sram_corr_fault_stats @(posedge `GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_corr_fault);
    cp_asf_sram_corr_fault_stats_upd : coverpoint (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_corr_fault_stats_upd) {
      illegal_bins asf_zero_faults_upd          = {0};
      bins         asf_1_sram_corr_fault_upd    = {1};
      bins         asf_2gr_sram_corr_faults_upd = {[2:$]};
    }
    cp_asf_sram_corr_fault_count : coverpoint (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_sram_protect_added.gen_asf_sram_corr_count.asf_sram_fault_corr_stats_r) {
      ignore_bins  asf_zero_count                 = {0};
      bins         asf_1_sram_corr_fault_count    = {1};
      bins         asf_2gr_sram_corr_faults_count = {[2:65534]};
      bins         asf_max_sram_corr_fault_count  = {65535};
    }
   cp_asf_cross_overflow_upd : cross cp_asf_sram_corr_fault_stats_upd, cp_asf_sram_corr_fault_count {
      ignore_bins asf_ignore_unset = binsof(cp_asf_sram_corr_fault_count.asf_zero_count)
                                     || binsof(cp_asf_sram_corr_fault_count.asf_1_sram_corr_fault_count)
                                     || binsof(cp_asf_sram_corr_fault_count.asf_2gr_sram_corr_faults_count);
    }
  endgroup
  cg_asf_sram_corr_fault_stats i_cg_asf_sram_corr_fault_stats = new();

// 2.1.20 check the stats counters and status registers are cleared using W1C
`ifdef ABV_ON_ASF
       property check_asf_sram_corr_stats_w1c;
      @(posedge pclk) disable iff (!n_preset)
        ((`hier_gem_top.pwrite && `hier_gem_top.psel && `hier_gem_top.penable && |(`hier_gem_top.pwdata[15:0]) && (`hier_gem_top.paddr == `gem_asf_sram_fault_stats))
             && (1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_corr_fault)))
        |=>  (16'd0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_sram_protect_added.gen_asf_sram_corr_count.asf_sram_fault_corr_stats_r));
       endproperty
      // 2.1.21.4 check W1C for SRAM correctable stats counter
      assert_check_asf_sram_corr_stats_w1c: assert property (check_asf_sram_corr_stats_w1c);
`endif // ABV_ON_ASF

`endif // gem_asf_ecc_sram
`endif // gem_asf_enable
`endif // gem_rx_pkt_buffer
`endif //gem_ext_fifo_interface

  `define ASS_ASF_INT_STATUS_CLR(FAULT_NAME,NUM_BIT) \
       property check_asf_int_status_w1c_``FAULT_NAME``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        ((`hier_gem_top.pwrite && `hier_gem_top.psel && (~(`hier_gem_top.penable)) && `hier_gem_top.pwdata[NUM_BIT] && ((`hier_gem_top.paddr == `gem_asf_int_status) || (`hier_gem_top.paddr == `gem_asf_int_raw_status))) \
           && (1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_``FAULT_NAME))) \
        |=> (1'b0 == ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[NUM_BIT]) \
            || (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_status[NUM_BIT]))); \
       endproperty \
      assert_check_asf_int_status_w1c_``FAULT_NAME``NUM_BIT: assert property (check_asf_int_status_w1c_``FAULT_NAME``NUM_BIT);

  `define ASS_ASF_INT_STATUS_CLR_TRANS_TO(NUM_BIT) \
       property check_asf_int_status_w1c_trans_to``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        ((`hier_gem_top.pwrite && `hier_gem_top.psel && (~(`hier_gem_top.penable)) && `hier_gem_top.pwdata[NUM_BIT] && ((`hier_gem_top.paddr == `gem_asf_int_status) || (`hier_gem_top.paddr == `gem_asf_int_raw_status))) \
           && (1'b0 == (|(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_trans_to_fault & ~(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.gen_trans_to_added.asf_trans_to_fault_mask_r))))) \
        |=> (1'b0 == ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[NUM_BIT]) \
            || (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_status[NUM_BIT]))); \
       endproperty \
      assert_check_asf_int_status_w1c_trans_to``NUM_BIT: assert property (check_asf_int_status_w1c_trans_to``NUM_BIT);

  `define ASS_ASF_INT_STATUS_CLR_PROTOCOL(NUM_BIT) \
       property check_asf_int_status_w1c_protocol``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        ((`hier_gem_top.pwrite && `hier_gem_top.psel && (~(`hier_gem_top.penable)) && `hier_gem_top.pwdata[NUM_BIT] && ((`hier_gem_top.paddr == `gem_asf_int_status) || (`hier_gem_top.paddr == `gem_asf_int_raw_status))) \
           && (1'b0 == (|(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_protocol_fault & ~(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.gen_protocol_check_added.asf_protocol_fault_mask_r))))) \
        |=> (1'b0 == ((`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[NUM_BIT]) \
            || (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_status[NUM_BIT]))); \
       endproperty \
      assert_check_asf_int_status_w1c_protocol``NUM_BIT: assert property (check_asf_int_status_w1c_protocol``NUM_BIT);

  `define ASS_ASF_TRANS_TO_STATUS_CLR(NUM_BIT) \
       property check_asf_trans_to_status_w1c_``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        ((`hier_gem_top.pwrite && `hier_gem_top.psel && (~(`hier_gem_top.penable)) && `hier_gem_top.pwdata[NUM_BIT] && (`hier_gem_top.paddr == `gem_asf_trans_to_fault_status)) \
           && (1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_trans_to_fault[NUM_BIT]))) \
        |=> (1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_trans_to_added.gen_asf_trans_to_fault_status[NUM_BIT].gen_asf_trans_to_fault_status_exists.asf_trans_to_fault_status_rm)); \
       endproperty \
      assert_check_asf_trans_to_status_w1c_``NUM_BIT: assert property (check_asf_trans_to_status_w1c_``NUM_BIT);

  `define ASS_ASF_PROTOCOL_STATUS_CLR(NUM_BIT) \
       property check_asf_protocol_status_w1c_``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        ((`hier_gem_top.pwrite && `hier_gem_top.psel && (~(`hier_gem_top.penable)) && `hier_gem_top.pwdata[NUM_BIT] && (`hier_gem_top.paddr == `gem_asf_protocol_fault_status)) \
           && (1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_protocol_fault[NUM_BIT]))) \
        |=> (1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_protocol_check_added.gen_asf_protocol_fault_status[NUM_BIT].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn)); \
       endproperty \
      assert_check_asf_protocol_status_w1c_``NUM_BIT: assert property (check_asf_protocol_status_w1c_``NUM_BIT);

`ifdef ABV_ON_ASF
   `ifdef gem_asf_ecc_sram
      `ASS_ASF_INT_STATUS_CLR(sram_corr_fault,0)    // check W1C for SRAM correctable fault
   `endif
   `ifdef gem_asf_dap_prot
      `ASS_ASF_INT_STATUS_CLR(sram_uncorr_fault,1)  // check W1C for SRAM uncorrectable fault
      `ASS_ASF_INT_STATUS_CLR(dap_fault,2)          // check W1C for data and address paths parity fault
   `endif
   `ifdef gem_asf_csr_prot
      `ASS_ASF_INT_STATUS_CLR(csr_fault,3)            // check W1C for configuration and status registers fault
   `endif
   `ASS_ASF_INT_STATUS_CLR_TRANS_TO(4)             // check W1C for transaction timeouts fault
   `ASS_ASF_TRANS_TO_STATUS_CLR(0)
   `ASS_ASF_TRANS_TO_STATUS_CLR(1)
   `ifdef gem_asf_trans_to_prot
     `ifndef gem_ext_fifo_interface
       `ifdef gem_tx_pkt_buffer
         `ASS_ASF_TRANS_TO_STATUS_CLR(2)
         `ASS_ASF_TRANS_TO_STATUS_CLR(3)
         `ASS_ASF_TRANS_TO_STATUS_CLR(4)
       `endif
     `endif
   `endif
      `ASS_ASF_INT_STATUS_CLR_PROTOCOL(5)             // check W1C for protocol fault
   `ifdef gem_asf_integrity_prot
   `ASS_ASF_INT_STATUS_CLR(integrity_fault,6)      // check W1C for integrity fault
   `endif
   `ASS_ASF_PROTOCOL_STATUS_CLR(0)
   `ASS_ASF_PROTOCOL_STATUS_CLR(1)
   `ASS_ASF_PROTOCOL_STATUS_CLR(2)
   `ASS_ASF_PROTOCOL_STATUS_CLR(3)
   `ASS_ASF_PROTOCOL_STATUS_CLR(4)
   `ASS_ASF_PROTOCOL_STATUS_CLR(5)
   `ASS_ASF_PROTOCOL_STATUS_CLR(6)
   `ASS_ASF_PROTOCOL_STATUS_CLR(7)
   `ASS_ASF_PROTOCOL_STATUS_CLR(8)
   `ASS_ASF_PROTOCOL_STATUS_CLR(16)
   `ASS_ASF_PROTOCOL_STATUS_CLR(17)
   `ASS_ASF_PROTOCOL_STATUS_CLR(18)
   `ASS_ASF_PROTOCOL_STATUS_CLR(19)
   `ASS_ASF_PROTOCOL_STATUS_CLR(20)
   `ASS_ASF_PROTOCOL_STATUS_CLR(21)
`endif // ABV_ON_ASF

// 2.1.21 config with ASF and not-ECC configured, and SRAM error injection run
logic asf_sram_uncorr_int_status_when_no_ecc;
assign asf_sram_uncorr_int_status_when_no_ecc = asf_dap_prot && (!asf_ecc_sram) && (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[1]);
  covergroup cg_asf_sram_uncorr_int_status_when_no_ecc @(posedge `hier_gem_top.pclk);
      cp_asf_sram_uncorr_int_status_when_no_ecc : coverpoint (asf_sram_uncorr_int_status_when_no_ecc){
      bins asf_bit_set  = {1};
      }
  endgroup
  cg_asf_sram_uncorr_int_status_when_no_ecc i_cg_asf_sram_uncorr_int_status_when_no_ecc = new();

///////////////////////////////////////////////////
// 2.4 Data and Address Path (AXI-only)

logic asf_axi_interface;
`ifdef gem_axi
  assign asf_axi_interface = 1;
`else
  assign asf_axi_interface = 0;
`endif

wire [1:0] data_width;
wire  addressing_64b;
assign data_width               = `hierarchy.dma_bus_width;
assign addressing_64b           = `hierarchy.dma_addr_bus_width;
logic asf_tsu_en;
`ifdef gem_tsu
  assign asf_tsu_en = 1;
`else
  assign asf_tsu_en = 0;
`endif
logic gem_has_802p3_br;
`ifdef gem_has_802p3_br
  assign gem_has_802p3_br = 1;
`else
  assign gem_has_802p3_br = 0;
`endif
logic gem_has_int_loopback;
`ifdef gem_int_loopback
  assign gem_has_int_loopback = 1;
`else
  assign gem_has_int_loopback = 0;
`endif
logic gem_has_pcs;
`ifdef gem_no_pcs
  assign gem_has_pcs = 0;
`else
  assign gem_has_pcs = 1;
`endif

  wire dap_pbuf_ahb_tx_sram_dia_err;
  wire dap_pbuf_ahb_rx_sram_dia_err;
  wire dap_pbuf_ahb_tx_rd_tx_r_data_err;
  wire dap_pbuf_ahb_tx_wr_hwdata_err;
  wire dap_pbuf_axi_fe_desc_buff_db2_out_dma_err;
  wire dap_pbuf_axi_fe_desc_buff_db2_out_nxt_axi_err;
  wire dap_pbuf_axi_fe_desc_buff_db2_out_axi_err;
  wire dap_pbuf_axi_fe_desc_buff_db1_out_err;
  wire dap_asf_host_par_rdata_err;
  wire dap_gem_rx_data_store_128_err;
  wire dap_pbuf_rx_wr_timestamp_cpt_err;
  wire dap_pbuf_rx_wr_cutthru_status_word_err;
  wire dap_pbuf_rx_rd_rxdpram_dob_offset_err;
  wire dap_pbuf_rx_rd_nxt_descr_ptr_pad_err;
  wire dap_pbuf_rx_rd_haddr_err;
  wire dap_pbuf_rx_rd_status_word_err;
  wire dap_pbuf_rx_rd_hwdata_err;
  wire dap_pbuf_axi_tx_wr_cutthru_status_word_err;
  wire dap_pbuf_axi_tx_rd_xfer_status_bus_ts_err;
  wire dap_pbuf_axi_tx_rd_xfer_status_bus_err;
  wire dap_pbuf_axi_tx_rd_status_word_err;
  wire dap_pbuf_axi_tx_rd_tx_r_data_err;
  wire dap_pbuf_axi_tx_rd_status_word_nxt_err;
  wire dap_pbuf_axi_tx_top_sram_dia_err;
  wire dap_pbuf_axi_top_rx_sram_dia_err;
  wire dap_pbuf_axi_fe_awaddr_err;
  wire dap_pbuf_axi_fe_araddr_err;
  wire dap_pbuf_axi_fe_wdata_err;
  wire dap_pbuf_axi_fe_tx_buff_stripe_err;
  wire dap_pbuf_axi_fe_tx_wb_timestamp_err;
  wire dap_pbuf_axi_fe_tx_wb_data_err;
  wire dap_pbuf_axi_fe_tx_db1_in_err;
  wire dap_pbuf_axi_fe_tx_db1_in_hold_err;
  wire dap_pbuf_axi_fe_tx_wb_addr_fifo_out_err;
  wire dap_pbuf_axi_fe_tx_cur_descr_rd_add_err;
  wire dap_pbuf_axi_fe_tx_ar2al_fifo_out_err;
  wire dap_pbuf_axi_fe_rx_hrdata_rx_err;
  wire dap_pbuf_axi_fe_rx_rx_descr_wr_fifo_out_err;
  wire dap_pbuf_axi_fe_rx_rx_data_addr_err;
  wire dap_pbuf_axi_fe_rx_rx_descr_addr_err;
  wire dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_out_err;
  wire dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_in_err;

`ifdef gem_asf_enable
  genvar i;

`ifdef gem_no_pcs
  assign dap_pcs_tx_code_err = 1'b0;
  assign dap_pcs_rxd_err     = 1'b0;
`else
  assign dap_pcs_tx_code_err = (`hier_gem_top.i_gem_mii_bridge.GEN_PCS.i_gem_pcs.i_pcs_tx.tx_dap_err);
  assign dap_pcs_rxd_err = (`hier_gem_top.i_gem_mii_bridge.GEN_PCS.i_gem_pcs.i_pcs_rx.rx_dap_err);
`endif
`ifdef gem_has_802p3_br
  assign dap_802p3_br_txd_err = (`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_tx_proc.asf_dap_mmsl_tx_err);
  assign dap_802p3_br_pmac_rxd_err = (`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_proc.pmac_rxd_par != ^(`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_proc.pmac_rxd[7:0]));
  assign dap_802p3_br_pmac_rxd_pcs_err = (`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_proc.pmac_rxd_par_pcs[1:0] != {^(`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_proc.pmac_rxd_pcs[15:8]),
                                                                                                                                  ^(`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_proc.pmac_rxd_pcs[7:0])});
  assign dap_802p3_br_emac_rxd_err = (`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_exp_flt.emac_rxd_par != ^(`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_exp_flt.emac_rxd[7:0]));
  assign dap_802p3_br_emac_rxd_pcs_err = (`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_exp_flt.emac_rxd_par_pcs[1:0] != {^(`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_exp_flt.emac_rxd_pcs[15:8]),
                                                                                                                                  ^(`hier_gem_top.gen_has_802p3_br.i_gem_mmsl.i_gem_mmsl_rx_exp_flt.emac_rxd_pcs[7:0])});
`else
  assign dap_802p3_br_txd_err = 1'b0;
  assign dap_802p3_br_pmac_rxd_pcs_err = 1'b0;
  assign dap_802p3_br_pmac_rxd_err = 1'b0;
  assign dap_802p3_br_emac_rxd_err = 1'b0;
  assign dap_802p3_br_emac_rxd_pcs_err = 1'b0;
`endif

`ifdef gem_asf_host_par
  assign dap_asf_host_par_paddr_err  = (`hier_gem_top.asf_dap_paddr_err);
  assign dap_asf_host_par_prdata_err = (`hier_gem_top.asf_dap_prdata_err);
  assign dap_asf_host_par_rdata_err  = | (`hier_gem_top.asf_dap_rdata_err);
`else
  assign dap_asf_host_par_paddr_err  = 1'b0;
  assign dap_asf_host_par_prdata_err = 1'b0;
  assign dap_asf_host_par_rdata_err  = 1'b0;
`endif

  assign dap_gem_rx_data_store_128_err = (`MAC_TOP_HIERARCHY.i_gem_rx.asf_dap_mac_rx_err);

  assign dap_gem_mac_txd_to_loop_err = (`MAC_TOP_HIERARCHY.uncorr_err_dp_txd_to_loop);

  assign dap_gem_mac_txd_gmii_err = (`MAC_TOP_HIERARCHY.uncorr_err_dp_txd_gmii);

`ifndef gem_ext_fifo_interface
  `ifdef gem_rx_pkt_buffer
    `ifdef gem_axi
      parameter p_gem_axi = 1 ;
    `else
      parameter p_gem_axi = 0;
    `endif
  `else
    parameter p_gem_axi = 0;
  `endif
`else
  parameter p_gem_axi = 0;
`endif

generate if (p_gem_axi == 1) begin : gen_ass_gem_axi

  assign dap_pbuf_rx_wr_timestamp_cpt_err = (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.dap_ts_cpt_err);
  assign dap_pbuf_rx_wr_cutthru_status_word_err = (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.gen_dp_par_chk.ct_sw_par_err_r);
  assign dap_pbuf_rx_rd_rxdpram_dob_offset_err = (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.gen_edma_dp_par.dap_err_dma_data);

  assign dap_pbuf_rx_rd_nxt_descr_ptr_pad_err  = |(`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.gen_edma_dp_par.dap_err_nxt_descr_ptr);

  assign dap_pbuf_rx_rd_haddr_err = (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.gen_edma_dp_par.dap_err_haddr);
  assign dap_pbuf_rx_rd_status_word_err = (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.gen_edma_dp_par.dap_err_status_words);

//  wire [(32/8)-1:0] dap_pbuf_rx_rd_nxt_descr_ptr_pad_err_i;
//  for (i=0;i<`edma_queues;i=i+1) begin : gen_chk_nxt_descr_ptr
//    assign dap_pbuf_rx_rd_nxt_descr_ptr_pad_err_i[i] = (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.gen_edma_dp_par.dap_err_nxt_descr_ptr[i]);
//  end
//  assign dap_pbuf_rx_rd_nxt_descr_ptr_pad_err  = | dap_pbuf_rx_rd_nxt_descr_ptr_pad_err_i;
  assign dap_pbuf_rx_rd_hwdata_err = (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.gen_edma_dp_par.dap_err_hwdata);

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_wr.cutthru_status_word[138:0]
  assign dap_pbuf_axi_tx_wr_cutthru_status_word_err  =  `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_wr.gen_dap.ct_sw_par_err_r;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.xfer_status_bus_ts[42:0]
  assign dap_pbuf_axi_tx_rd_xfer_status_bus_ts_err  =  `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.gen_dp_parity.dap_err_xfer_sts_bus_ts;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.xfer_status_bus[81:0]
  assign dap_pbuf_axi_tx_rd_xfer_status_bus_err  =  `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.gen_dp_parity.dap_err_xfer_sts_bus;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.status_word_0[31:0]
//{status_word_3[31:0],
//                status_word_2[31:0],
//                status_word_0[31:0],
//                status_word_mac_3[31:0],
//                status_word_mac_2[31:0],
//                status_word_mac_0[31:0]}
  assign dap_pbuf_axi_tx_rd_status_word_err  =  `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.gen_dp_parity.dap_err_status_words;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.tx_r_data[63:0]
   reg dap_pbuf_axi_tx_rd_tx_r_data_err_r;
    always@(posedge tx_r_clk or negedge n_tx_r_reset)
    begin
      if (~(n_tx_r_reset))
        dap_pbuf_axi_tx_rd_tx_r_data_err_r <= 1'b0;
      else
        dap_pbuf_axi_tx_rd_tx_r_data_err_r <= `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.gen_dp_parity.dap_err_tx_r_data_c;
    end
  assign dap_pbuf_axi_tx_rd_tx_r_data_err = dap_pbuf_axi_tx_rd_tx_r_data_err_r;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.sw01_par_err[1:0]
  assign dap_pbuf_axi_tx_rd_status_word_nxt_err  = | `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd.sw01_par_err;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.tx_sram_dia[63:0]
  assign dap_pbuf_axi_tx_top_sram_dia_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.asf_dap_tx_ram_wr_err;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.rx_sram_dia[63:0]
  assign dap_pbuf_axi_top_rx_sram_dia_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.asf_dap_rx_ram_wr_err;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.awaddr[63:0]
  assign dap_pbuf_axi_fe_awaddr_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.gen_dp_parity.dap_awaddr_err;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.araddr[63:0]
  assign dap_pbuf_axi_fe_araddr_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.gen_dp_parity.dap_araddr_err;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.wdata[63:0]
  assign dap_pbuf_axi_fe_wdata_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.gen_dp_parity.dap_wdata_err;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.buff_stripe
  assign dap_pbuf_axi_fe_tx_buff_stripe_err  = (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.gen_dap_par_chk.dap_err_buff_stripe &
                                                `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.buff_stripe_vld);

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.wb_timestamp
  assign dap_pbuf_axi_fe_tx_wb_timestamp_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.gen_dap_par_chk.dap_err_wb_timestamp;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.wb_data
  assign dap_pbuf_axi_fe_tx_wb_data_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.gen_dap_par_chk.dap_err_wb_data;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in
  assign dap_pbuf_axi_fe_tx_db1_in_err  = ((`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.gen_dap_par_chk.dap_err_db1_in)
                                         & (`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_push));

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.db1_in_hold
  assign dap_pbuf_axi_fe_tx_db1_in_hold_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.gen_dap_par_chk.dap_err_db1_in_hold;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.wb_addr_fifo_out
  assign dap_pbuf_axi_fe_tx_wb_addr_fifo_out_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.gen_dap_par_chk.dap_err_wb_addr_fifo_out;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.cur_descr_rd_add
  assign dap_pbuf_axi_fe_tx_cur_descr_rd_add_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.gen_dap_par_chk.dap_err_cur_descr_rd_add;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.ar2al_fifo_out
  assign dap_pbuf_axi_fe_tx_ar2al_fifo_out_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.dap_err_ar2al_fifo;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.hrdata_rx
  assign dap_pbuf_axi_fe_rx_hrdata_rx_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.gen_asf_dap_chk.dap_err_hrdata_rx;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_wr_fifo_out
  assign dap_pbuf_axi_fe_rx_rx_descr_wr_fifo_out_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.gen_asf_dap_chk.dap_err_wr_fifo_out;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_data_addr
  assign dap_pbuf_axi_fe_rx_rx_data_addr_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.gen_asf_dap_chk.dap_err_data_addr;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_addr
  assign dap_pbuf_axi_fe_rx_rx_descr_addr_err  = `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.gen_asf_dap_chk.dap_err_descr_addr;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_rd_fifo_out[15:0]
  assign dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_out_err  = |(`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.gen_asf_dap_chk.dap_err_rd_fifo_out);

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.rx_descr_reads[0].rx_descr_rd_fifo_in[63:0]
assign dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_in_err = |(`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_rx.dap_err_rd_fifo_in);

    for (i = 0; i < `edma_queues; i = i + 1) begin : tx_descr_buff
      // tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.db2_out_dma
      assign dap_pbuf_axi_fe_desc_buff_db2_out_dma_err  = |(`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[i].i_tx_descr_buff.gen_par_chk_db2.db2_out_dma_err);
      // tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.db2_out_nxt_axi[132:0]
      assign dap_pbuf_axi_fe_desc_buff_db2_out_nxt_axi_err  = |(`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[i].i_tx_descr_buff.gen_par_chk_db2.db2_out_nxt_axi_err);
      // tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.db2_out_axi
      assign dap_pbuf_axi_fe_desc_buff_db2_out_axi_err  = |(`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[i].i_tx_descr_buff.gen_par_chk_db2.db2_out_axi_err);
      // tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[0].i_tx_descr_buff.db1_out
      assign dap_pbuf_axi_fe_desc_buff_db1_out_err  = |(`hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe.i_edma_pbuf_axi_fe_tx.tx_descr_buff[i].i_tx_descr_buff.db1_out_par_err);
    end  // tx_descr_buff

  assign dap_pbuf_ahb_tx_wr_hwdata_err    = 1'b0;
  assign dap_pbuf_ahb_tx_rd_tx_r_data_err = 1'b0;
  assign dap_pbuf_ahb_rx_sram_dia_err     = 1'b0;
  assign dap_pbuf_ahb_tx_sram_dia_err     = 1'b0;

  end else begin : gen_ass_gem_ahb

`ifndef gem_ext_fifo_interface
`ifdef gem_rx_pkt_buffer
// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.hwdata
  assign dap_pbuf_ahb_tx_wr_hwdata_err  = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr.asf_dap_tx_wr_err;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_rd.tx_r_data
  assign dap_pbuf_ahb_tx_rd_tx_r_data_err  = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_rd.gen_dp_parity.tx_r_data_par_err_c;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.rx_sram_dia
  assign dap_pbuf_ahb_rx_sram_dia_err  = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.gen_ram_par_check.asf_dap_rx_ram_wr_err_int;

// tb_gem_gxl.i_gem_gxl.i_gem_ss.i_gem_top.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.tx_sram_dia
  assign dap_pbuf_ahb_tx_sram_dia_err  = `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top.gen_ram_par_check.asf_dap_tx_ram_wr_err_int;
`else

  assign dap_pbuf_ahb_tx_wr_hwdata_err      = 1'b0;
  assign dap_pbuf_ahb_tx_rd_tx_r_data_err      = 1'b0;
  assign dap_pbuf_ahb_rx_sram_dia_err      = 1'b0;
  assign dap_pbuf_ahb_tx_sram_dia_err      = 1'b0;

`endif // gem_rx_pkt_buffer
`endif //gem_ext_fifo_interface

  assign dap_pbuf_rx_wr_timestamp_cpt_err      = 1'b0;
  assign dap_pbuf_rx_wr_cutthru_status_word_err      = 1'b0;
  assign dap_pbuf_rx_rd_rxdpram_dob_offset_err      = 1'b0;
  assign dap_pbuf_rx_rd_nxt_descr_ptr_pad_err      = 1'b0;
  assign dap_pbuf_rx_rd_haddr_err      = 1'b0;
  assign dap_pbuf_rx_rd_status_word_err      = 1'b0;
  assign dap_pbuf_rx_rd_hwdata_err      = 1'b0;
  assign dap_pbuf_axi_tx_wr_cutthru_status_word_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_xfer_status_bus_ts_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_xfer_status_bus_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_status_word_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_tx_r_data_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_status_word_nxt_err      = 1'b0;
  assign dap_pbuf_axi_tx_top_sram_dia_err      = 1'b0;
  assign dap_pbuf_axi_top_rx_sram_dia_err      = 1'b0;
  assign dap_pbuf_axi_fe_awaddr_err      = 1'b0;
  assign dap_pbuf_axi_fe_araddr_err      = 1'b0;
  assign dap_pbuf_axi_fe_wdata_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_buff_stripe_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_wb_timestamp_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_wb_data_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_db1_in_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_db1_in_hold_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_wb_addr_fifo_out_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_cur_descr_rd_add_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_ar2al_fifo_out_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_hrdata_rx_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_descr_wr_fifo_out_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_data_addr_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_descr_addr_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_out_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_in_err      = 1'b0;
  assign dap_pbuf_axi_fe_desc_buff_db2_out_dma_err      = 1'b0;
  assign dap_pbuf_axi_fe_desc_buff_db2_out_nxt_axi_err      = 1'b0;
  assign dap_pbuf_axi_fe_desc_buff_db2_out_axi_err      = 1'b0;
  assign dap_pbuf_axi_fe_desc_buff_db1_out_err      = 1'b0;
  end
  endgenerate


`else  // gem_asf_enable
  assign dap_pcs_tx_code_err           = 1'b0;
  assign dap_pcs_rxd_err               = 1'b0;
  assign dap_802p3_br_txd_err          = 1'b0;
  assign dap_802p3_br_pmac_rxd_pcs_err = 1'b0;
  assign dap_802p3_br_pmac_rxd_err     = 1'b0;
  assign dap_asf_host_par_paddr_err    = 1'b0;
  assign dap_asf_host_par_prdata_err   = 1'b0;
  assign dap_asf_host_par_rdata_err    = 1'b0;
  assign dap_gem_rx_data_store_128_err = 1'b0;
  assign dap_gem_mac_txd_to_loop_err   = 1'b0;
  assign dap_gem_mac_txd_gmii_err      = 1'b0;
  assign dap_pbuf_rx_wr_timestamp_cpt_err      = 1'b0;
  assign dap_pbuf_rx_wr_cutthru_status_word_err      = 1'b0;
  assign dap_pbuf_rx_rd_rxdpram_dob_offset_err      = 1'b0;
  assign dap_pbuf_rx_rd_nxt_descr_ptr_pad_err      = 1'b0;
  assign dap_pbuf_rx_rd_haddr_err      = 1'b0;
  assign dap_pbuf_rx_rd_status_word_err      = 1'b0;
  assign dap_pbuf_rx_rd_hwdata_err      = 1'b0;
  assign dap_pbuf_axi_tx_wr_cutthru_status_word_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_xfer_status_bus_ts_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_xfer_status_bus_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_status_word_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_tx_r_data_err      = 1'b0;
  assign dap_pbuf_axi_tx_rd_status_word_nxt_err      = 1'b0;
  assign dap_pbuf_axi_tx_top_sram_dia_err      = 1'b0;
  assign dap_pbuf_axi_top_rx_sram_dia_err      = 1'b0;
  assign dap_pbuf_axi_fe_awaddr_err      = 1'b0;
  assign dap_pbuf_axi_fe_araddr_err      = 1'b0;
  assign dap_pbuf_axi_fe_wdata_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_buff_stripe_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_wb_timestamp_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_wb_data_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_db1_in_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_db1_in_hold_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_wb_addr_fifo_out_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_cur_descr_rd_add_err      = 1'b0;
  assign dap_pbuf_axi_fe_tx_ar2al_fifo_out_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_hrdata_rx_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_descr_wr_fifo_out_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_data_addr_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_descr_addr_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_out_err      = 1'b0;
  assign dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_in_err      = 1'b0;
  assign dap_pbuf_axi_fe_desc_buff_db2_out_dma_err      = 1'b0;
  assign dap_pbuf_axi_fe_desc_buff_db2_out_nxt_axi_err      = 1'b0;
  assign dap_pbuf_axi_fe_desc_buff_db2_out_axi_err      = 1'b0;
  assign dap_pbuf_axi_fe_desc_buff_db1_out_err      = 1'b0;
  assign dap_pbuf_ahb_tx_wr_hwdata_err      = 1'b0;
  assign dap_pbuf_ahb_tx_rd_tx_r_data_err      = 1'b0;
  assign dap_pbuf_ahb_rx_sram_dia_err      = 1'b0;
  assign dap_pbuf_ahb_tx_sram_dia_err      = 1'b0;
`endif

// 2.4.1 for each error pin of parity checker, ensure that at least 1 fault is detectable
  covergroup cg_asf_dap_fault @(posedge `hier_gem_top.pclk);
    cp_asf_host_interface : coverpoint (asf_axi_interface) {
      bins asf_axi_interface  = {1};
    }
    cp_dma_data_width : coverpoint (data_width)  {
      bins data_width_is_32b   = {0};
      bins data_width_is_64b   = {1};
      bins data_width_is_128b  = {2};
    }
    cp_dma_addr_width : coverpoint (addressing_64b)  {
      bins addr_width_is_32b   = {0};
      bins addr_width_is_64b   = {1};
    }
    cp_asf_tsu_en : coverpoint (asf_tsu_en) {
      bins asf_without_tsu  = {0};
      bins asf_has_tsu   = {1};
    }
    cp_gem_has_int_loopback : coverpoint (gem_has_int_loopback) {
      bins gem_without_int_loopback   = {0};
      bins gem_has_int_loopback       = {1};
    }
    cp_gem_has_802p3_br : coverpoint (gem_has_802p3_br) {
      bins gem_without_802p3_br   = {0};
      bins gem_has_802p3_br       = {1};
    }
    cp_gem_has_pcs : coverpoint (gem_has_pcs) {
      bins gem_without_pcs   = {0};
      bins gem_has_pcs       = {1};
    }
    cp_dap_pcs_tx_code_err : coverpoint (dap_pcs_tx_code_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pcs_rxd_err : coverpoint (dap_pcs_rxd_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_802p3_br_txd_err : coverpoint (dap_802p3_br_txd_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_802p3_br_pmac_rxd_pcs_err : coverpoint (dap_802p3_br_pmac_rxd_pcs_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_802p3_br_pmac_rxd_err : coverpoint (dap_802p3_br_pmac_rxd_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_asf_host_par_paddr_err : coverpoint (dap_asf_host_par_paddr_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_asf_host_par_prdata_err : coverpoint (dap_asf_host_par_prdata_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_asf_host_par_rdata_err : coverpoint (dap_asf_host_par_rdata_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_gem_rx_data_store_128_err : coverpoint (dap_gem_rx_data_store_128_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_gem_mac_txd_to_loop_err : coverpoint (dap_gem_mac_txd_to_loop_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_gem_mac_txd_gmii_err : coverpoint (dap_gem_mac_txd_gmii_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_rx_wr_timestamp_cpt_err : coverpoint (dap_pbuf_rx_wr_timestamp_cpt_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_rx_wr_cutthru_status_word_err : coverpoint (dap_pbuf_rx_wr_cutthru_status_word_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_rx_rd_rxdpram_dob_offset_err : coverpoint (dap_pbuf_rx_rd_rxdpram_dob_offset_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_rx_rd_nxt_descr_ptr_pad_err : coverpoint (dap_pbuf_rx_rd_nxt_descr_ptr_pad_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_rx_rd_haddr_err : coverpoint (dap_pbuf_rx_rd_haddr_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_rx_rd_status_word_err : coverpoint (dap_pbuf_rx_rd_status_word_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_rx_rd_hwdata_err : coverpoint (dap_pbuf_rx_rd_hwdata_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_tx_wr_cutthru_status_word_err : coverpoint (dap_pbuf_axi_tx_wr_cutthru_status_word_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_tx_rd_xfer_status_bus_ts_err : coverpoint (dap_pbuf_axi_tx_rd_xfer_status_bus_ts_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_tx_rd_xfer_status_bus_err : coverpoint (dap_pbuf_axi_tx_rd_xfer_status_bus_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_tx_rd_status_word_err : coverpoint (dap_pbuf_axi_tx_rd_status_word_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_tx_rd_tx_r_data_err : coverpoint (dap_pbuf_axi_tx_rd_tx_r_data_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_tx_rd_status_word_nxt_err : coverpoint (dap_pbuf_axi_tx_rd_status_word_nxt_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_tx_top_sram_dia_err : coverpoint (dap_pbuf_axi_tx_top_sram_dia_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_top_rx_sram_dia_err : coverpoint (dap_pbuf_axi_top_rx_sram_dia_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_awaddr_err : coverpoint (dap_pbuf_axi_fe_awaddr_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_araddr_err : coverpoint (dap_pbuf_axi_fe_araddr_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_wdata_err : coverpoint (dap_pbuf_axi_fe_wdata_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_tx_buff_stripe_err : coverpoint (dap_pbuf_axi_fe_tx_buff_stripe_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_tx_wb_timestamp_err : coverpoint (dap_pbuf_axi_fe_tx_wb_timestamp_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_tx_db1_in_err : coverpoint (dap_pbuf_axi_fe_tx_wb_data_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_tx_db1_in_hold_err : coverpoint (dap_pbuf_axi_fe_tx_db1_in_hold_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_tx_wb_addr_fifo_out_err : coverpoint (dap_pbuf_axi_fe_tx_wb_addr_fifo_out_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_tx_ar2al_fifo_out_err : coverpoint (dap_pbuf_axi_fe_tx_cur_descr_rd_add_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_rx_hrdata_rx_err : coverpoint (dap_pbuf_axi_fe_rx_hrdata_rx_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_rx_rx_descr_wr_fifo_out_err : coverpoint (dap_pbuf_axi_fe_rx_rx_descr_wr_fifo_out_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_rx_rx_data_addr_err : coverpoint (dap_pbuf_axi_fe_rx_rx_data_addr_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_rx_rx_descr_addr_err : coverpoint (dap_pbuf_axi_fe_rx_rx_descr_addr_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_out_err : coverpoint (dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_out_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_in_err : coverpoint (dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_in_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_desc_buff_db2_out_dma_err : coverpoint (dap_pbuf_axi_fe_desc_buff_db2_out_dma_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_desc_buff_db2_out_nxt_axi_err : coverpoint (dap_pbuf_axi_fe_desc_buff_db2_out_nxt_axi_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_desc_buff_db2_out_axi_err : coverpoint (dap_pbuf_axi_fe_desc_buff_db2_out_axi_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_axi_fe_desc_buff_db1_out_err : coverpoint (dap_pbuf_axi_fe_desc_buff_db1_out_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_ahb_tx_wr_hwdata_err : coverpoint (dap_pbuf_ahb_tx_wr_hwdata_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_ahb_tx_rd_tx_r_data_err : coverpoint (dap_pbuf_ahb_tx_rd_tx_r_data_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_ahb_rx_sram_dia_err : coverpoint (dap_pbuf_ahb_rx_sram_dia_err) {
      bins gem_has_fault       = {1};
    }
    cp_dap_pbuf_ahb_tx_sram_dia_err : coverpoint (dap_pbuf_ahb_tx_sram_dia_err) {
      bins gem_has_fault       = {1};
    }
  endgroup
  cg_asf_dap_fault i_cg_asf_dap_fault = new();

`ifdef ABV_ON_ASF
//  2.4.2 check that parity errors in the data and address path raise dap status interrupt
       property check_asf_dap_err_raise_dap_fault;
      @(posedge pclk) disable iff (!n_preset)
        dap_pcs_tx_code_err
        || dap_pcs_rxd_err
        || dap_802p3_br_txd_err
        || dap_802p3_br_pmac_rxd_pcs_err
        || dap_802p3_br_pmac_rxd_err
        || dap_asf_host_par_paddr_err
        || dap_asf_host_par_prdata_err
        || dap_asf_host_par_rdata_err
        || dap_gem_rx_data_store_128_err
        || dap_gem_mac_txd_to_loop_err
        || dap_gem_mac_txd_gmii_err
        || dap_pbuf_rx_wr_timestamp_cpt_err
        || dap_pbuf_rx_wr_cutthru_status_word_err
        || dap_pbuf_rx_rd_rxdpram_dob_offset_err
        || dap_pbuf_rx_rd_nxt_descr_ptr_pad_err
        || dap_pbuf_rx_rd_haddr_err
        || dap_pbuf_rx_rd_status_word_err
        || dap_pbuf_rx_rd_hwdata_err
        || dap_pbuf_axi_tx_wr_cutthru_status_word_err
        || dap_pbuf_axi_tx_rd_xfer_status_bus_ts_err
        || dap_pbuf_axi_tx_rd_xfer_status_bus_err
        || dap_pbuf_axi_tx_rd_status_word_err
        || dap_pbuf_axi_tx_rd_tx_r_data_err
        || dap_pbuf_axi_tx_rd_status_word_nxt_err
        || dap_pbuf_axi_tx_top_sram_dia_err
        || dap_pbuf_axi_top_rx_sram_dia_err
        || dap_pbuf_axi_fe_awaddr_err
        || dap_pbuf_axi_fe_araddr_err
        || dap_pbuf_axi_fe_wdata_err
        || dap_pbuf_axi_fe_tx_buff_stripe_err
        || dap_pbuf_axi_tx_top_sram_dia_err
        || dap_pbuf_axi_fe_tx_wb_timestamp_err
        || dap_pbuf_axi_fe_tx_wb_data_err
        || dap_pbuf_axi_fe_tx_db1_in_err
        || dap_pbuf_axi_fe_tx_db1_in_hold_err
        || dap_pbuf_axi_fe_tx_wb_addr_fifo_out_err
        || dap_pbuf_axi_fe_tx_cur_descr_rd_add_err
        || dap_pbuf_axi_fe_tx_ar2al_fifo_out_err
        || dap_pbuf_axi_fe_rx_hrdata_rx_err
        || dap_pbuf_axi_fe_rx_rx_descr_wr_fifo_out_err
        || dap_pbuf_axi_fe_rx_rx_data_addr_err
        || dap_pbuf_axi_fe_rx_rx_descr_addr_err
        || dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_out_err
        || dap_pbuf_axi_fe_rx_rx_descr_rd_fifo_in_err
        || dap_pbuf_axi_fe_desc_buff_db2_out_dma_err
        || dap_pbuf_axi_fe_desc_buff_db2_out_nxt_axi_err
        || dap_pbuf_axi_fe_desc_buff_db2_out_axi_err
        || dap_pbuf_axi_fe_desc_buff_db1_out_err
        || dap_pbuf_ahb_tx_wr_hwdata_err
        || dap_pbuf_ahb_tx_rd_tx_r_data_err
        || dap_pbuf_ahb_rx_sram_dia_err
        || dap_pbuf_ahb_tx_sram_dia_err
    |-> ##[0:100] (1'b1 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_dap_fault));
       endproperty
      assert_check_asf_dap_err_raise_dap_fault: assert property (check_asf_dap_err_raise_dap_fault);

// 2.4.3 check that no errors when no faults are injected to  the data and address paths
logic ifss_off;
`ifndef IFSS_FAULT_SIM_DIS_ASF_ASSERTIONS
  assign ifss_off = 1;
`else
  assign ifss_off = 0;
`endif
       property check_asf_no_err_when_no_dap_fault_inj;
      @(posedge pclk) disable iff (!n_preset | disable_asf_assertions)
        (1'b1 == ifss_off) |-> (1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_dap_fault));
       endproperty
      assert_check_asf_no_err_when_no_dap_fault_inj: assert property (check_asf_no_err_when_no_dap_fault_inj);
`endif // ABV_ON_ASF

///////////////////////////////////////////////////
// 2.5 IP Integrity Protection
`ifndef PBUF_AXI_FE_HIERARCHY
  `define PBUF_AXI_FE_HIERARCHY     `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top.i_edma_pbuf_axi_fe
`endif
  wire   asf_integrity_ar2r_fifo_err;
  wire   asf_integrity_aw2w_fifo_err;
  wire   asf_integrity_w2b_fifo_err;

`ifndef gem_ext_fifo_interface
`ifdef gem_rx_pkt_buffer
`ifdef gem_axi
`ifdef gem_asf_enable
  assign asf_integrity_ar2r_fifo_err = (`PBUF_AXI_FE_HIERARCHY.asf_integrity_ar2r_fifo_err);
  assign asf_integrity_aw2w_fifo_err = (`PBUF_AXI_FE_HIERARCHY.asf_integrity_aw2w_fifo_err);
  assign asf_integrity_w2b_fifo_err  = (`PBUF_AXI_FE_HIERARCHY.asf_integrity_w2b_fifo_err);
`else
  assign asf_integrity_ar2r_fifo_err = 1'b0;
  assign asf_integrity_aw2w_fifo_err = 1'b0;
  assign asf_integrity_w2b_fifo_err  = 1'b0;
`endif // gem_asf_enable
`else
  assign asf_integrity_ar2r_fifo_err = 1'b0;
  assign asf_integrity_aw2w_fifo_err = 1'b0;
  assign asf_integrity_w2b_fifo_err  = 1'b0;
`endif // gem_axi
`else
  assign asf_integrity_ar2r_fifo_err = 1'b0;
  assign asf_integrity_aw2w_fifo_err = 1'b0;
  assign asf_integrity_w2b_fifo_err  = 1'b0;
`endif // gem_rx_pkt_buffer
`else
  assign asf_integrity_ar2r_fifo_err = 1'b0;
  assign asf_integrity_aw2w_fifo_err = 1'b0;
  assign asf_integrity_w2b_fifo_err  = 1'b0;
`endif //gem_ext_fifo_interface

  wire  tsu_timer_cnt_err;
  wire  tsu_timer_cnt_par_err;
  wire  timer_strobe_err;
  wire  tsu_sec_incr_err;
  wire  tsu_timer_cmp_val_err;
`ifdef gem_tsu
`ifdef gem_asf_prot_tsu
`ifndef TSU_PROTECT_HIERARCHY
  `define TSU_PROTECT_HIERARCHY     `hierarchy.gen_tsu.gen_tsu_protect
`endif
  assign timer_strobe_err      = ((`hierarchy.timer_strobe) != (`TSU_PROTECT_HIERARCHY.timer_strobe_dplc));
  assign tsu_sec_incr_err      = ((`hierarchy.tsu_sec_incr) != (`TSU_PROTECT_HIERARCHY.tsu_sec_incr_dplc));
  assign tsu_timer_cnt_err     = ((`hierarchy.tsu_timer_cnt) != (`TSU_PROTECT_HIERARCHY.tsu_timer_cnt_dplc));
  assign tsu_timer_cnt_par_err = ((`hierarchy.tsu_timer_cnt_par) != (`TSU_PROTECT_HIERARCHY.tsu_timer_cnt_par_dplc));
  assign tsu_timer_cmp_val_err = ((`hierarchy.tsu_timer_cmp_val) != (`TSU_PROTECT_HIERARCHY.tsu_timer_cmp_val_dplc));
`else
  assign timer_strobe_err      = 1'b0;
  assign tsu_sec_incr_err      = 1'b0;
  assign tsu_timer_cnt_err     = 1'b0;
  assign tsu_timer_cnt_par_err = 1'b0;
  assign tsu_timer_cmp_val_err = 1'b0;
`endif
`else
  assign timer_strobe_err      = 1'b0;
  assign tsu_sec_incr_err      = 1'b0;
  assign tsu_timer_cnt_err     = 1'b0;
  assign tsu_timer_cnt_par_err = 1'b0;
  assign tsu_timer_cmp_val_err = 1'b0;
`endif

  wire  any_ets_en_err;
  wire  scheduled_queue_err;
  wire  nothing_to_xmit_err;
`ifdef gem_asf_prot_tx_sched
`ifndef TX_FIFO_IF_HIERARCHY
  `define TX_FIFO_IF_HIERARCHY     `MAC_TOP_HIERARCHY.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if
`endif
  assign any_ets_en_err      = ((`TX_FIFO_IF_HIERARCHY.any_ets_en) != (`TX_FIFO_IF_HIERARCHY.gen_edma_tx_sched_protect.any_ets_en_dplc));
  assign scheduled_queue_err = ((`TX_FIFO_IF_HIERARCHY.scheduled_queue) != (`TX_FIFO_IF_HIERARCHY.gen_edma_tx_sched_protect.scheduled_queue_dplc));
  assign nothing_to_xmit_err = ((`TX_FIFO_IF_HIERARCHY.nothing_to_xmit) != (`TX_FIFO_IF_HIERARCHY.gen_edma_tx_sched_protect.nothing_to_xmit_dplc));
`else
  assign any_ets_en_err      = 1'b0;
  assign scheduled_queue_err = 1'b0;
  assign nothing_to_xmit_err = 1'b0;
`endif

  wire fsm_active_err;
  wire tsu_hold_err;
  wire tsu_gatestate_err;
  wire byte_count_err;
  wire gatestate_out_err;

`ifdef gem_asf_prot_tx_sched
  `ifndef PBUF_TX_ENST1_HIERARCHY
    `define PBUF_TX_ENST1_HIERARCHY  `TX_FIFO_IF_HIERARCHY.gen_enst_module.gen_enst1 
  `endif
  `ifndef PBUF_TX_ENST2_HIERARCHY
    `define PBUF_TX_ENST2_HIERARCHY  `TX_FIFO_IF_HIERARCHY.gen_enst_module.gen_enst2 
  `endif
  `ifdef gem_exclude_qbv
    assign fsm_active_err      = 1'b0;
    assign scheduled_queue_err = 1'b0;
    assign nothing_to_xmit_err = 1'b0;
    assign byte_count_err      = 1'b0;
    assign gatestate_out_err   = 1'b0;
  `else
    generate if( `edma_queues < 32'd9 ) begin : gen_pbuf_tx_enst1
      wire [`edma_queues-1:0] fsm_active_err_q;
      wire [`edma_queues-1:0] tsu_hold_err_q;
      wire [`edma_queues-1:0] tsu_gatestate_err_q;
      wire [`edma_queues-1:0] byte_count_err_q;
      wire [`edma_queues-1:0] gatestate_out_err_q;
      genvar enst1_q;
      for (enst1_q=0; enst1_q<`edma_queues; enst1_q=enst1_q+1) begin: gen_loop_enst1
        assign fsm_active_err_q   [enst1_q] = ((`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.i_enst_fsm.fsm_active)   != (`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fsm_asf_duplc.fsm_active));
        assign tsu_hold_err_q     [enst1_q] = ((`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.i_enst_fsm.tsu_hold)     != (`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fsm_asf_duplc.tsu_hold));
        assign tsu_gatestate_err_q[enst1_q] = ((`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.i_enst_fsm.tsu_gatestate)!= (`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fsm_asf_duplc.tsu_gatestate));
        assign byte_count_err_q   [enst1_q] = ((`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.i_enst_fc.byte_count)    != (`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fc_asf_duplc.byte_count));
        assign gatestate_out_err_q[enst1_q] = ((`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.i_enst_fc.gatestate_out) != (`PBUF_TX_ENST1_HIERARCHY.gen_edma_pbuf_tx_enst1[enst1_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fc_asf_duplc.gatestate_out));
      end
      assign fsm_active_err      = |fsm_active_err_q;   
      assign tsu_hold_err        = |tsu_hold_err_q;     
      assign tsu_gatestate_err   = |tsu_gatestate_err_q;
      assign byte_count_err      = |byte_count_err_q;   
      assign gatestate_out_err   = |gatestate_out_err_q;
    end else begin : gen_pbuf_tx_enst2
      wire [7:0] fsm_active_err_q;
      wire [7:0] tsu_hold_err_q;
      wire [7:0] tsu_gatestate_err_q;
      wire [7:0] byte_count_err_q;
      wire [7:0] gatestate_out_err_q;
      genvar enst2_q;
      for (enst2_q=`edma_queues-8; enst2_q<`edma_queues; enst2_q=enst2_q+1) begin: gen_loop_enst2
        assign fsm_active_err_q   [enst2_q-`edma_queues+8] = ((`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.i_enst_fsm.fsm_active)   != (`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fsm_asf_duplc.fsm_active));
        assign tsu_hold_err_q     [enst2_q-`edma_queues+8] = ((`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.i_enst_fsm.tsu_hold)     != (`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fsm_asf_duplc.tsu_hold));
        assign tsu_gatestate_err_q[enst2_q-`edma_queues+8] = ((`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.i_enst_fsm.tsu_gatestate)!= (`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fsm_asf_duplc.tsu_gatestate));
        assign byte_count_err_q   [enst2_q-`edma_queues+8] = ((`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.i_enst_fc.byte_count)    != (`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fc_asf_duplc.byte_count));
        assign gatestate_out_err_q[enst2_q-`edma_queues+8] = ((`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.i_enst_fc.gatestate_out) != (`PBUF_TX_ENST2_HIERARCHY.gen_edma_pbuf_tx_enst2[enst2_q].i_edma_pbuf_tx_enst.gen_edma_pbuf_tx_enst_protect.i_enst_fc_asf_duplc.gatestate_out));
      end
      assign fsm_active_err      = |fsm_active_err_q;   
      assign tsu_hold_err        = |tsu_hold_err_q;     
      assign tsu_gatestate_err   = |tsu_gatestate_err_q;
      assign byte_count_err      = |byte_count_err_q;   
      assign gatestate_out_err   = |gatestate_out_err_q;
    end
    endgenerate
  `endif
`else
  assign fsm_active_err      = 1'b0;
  assign scheduled_queue_err = 1'b0;
  assign nothing_to_xmit_err = 1'b0;
  assign byte_count_err      = 1'b0;
  assign gatestate_out_err   = 1'b0;
`endif

// 2.5.1 for each output pin of a duplicated module, ensure that at least 1 fault is detectable
  covergroup cg_asf_intergrity_fault @(posedge `hier_gem_top.pclk);
    cp_asf_integrity_ar2r_fifo_err : coverpoint (asf_integrity_ar2r_fifo_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_aw2w_fifo_err : coverpoint (asf_integrity_aw2w_fifo_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_w2b_fifo_err : coverpoint (asf_integrity_w2b_fifo_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_tsu_err_timer_strobe : coverpoint (timer_strobe_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_tsu_err_tsu_sec_incr : coverpoint (tsu_sec_incr_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_tsu_err_tsu_timer_cnt : coverpoint (tsu_timer_cnt_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_tsu_err_tsu_timer_cnt_par : coverpoint (tsu_timer_cnt_par_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_tsu_err_tsu_timer_cmp_val : coverpoint (tsu_timer_cmp_val_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_edma_tx_sched_err_any_ets_en : coverpoint (any_ets_en_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_edma_tx_sched_err_scheduled_queue : coverpoint (scheduled_queue_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_edma_tx_sched_err_nothing_to_xmit : coverpoint (nothing_to_xmit_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_edma_tx_sched_err_fsm_active : coverpoint (fsm_active_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_edma_tx_sched_err_tsu_hold : coverpoint (tsu_hold_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_edma_tx_sched_err_tsu_gatestate : coverpoint (tsu_gatestate_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_edma_tx_sched_err_byte_count : coverpoint (byte_count_err) {
      bins asf_integrity_fault  = {1};
    }
    cp_asf_integrity_edma_tx_sched_err_gatestate_out : coverpoint (gatestate_out_err) {
      bins asf_integrity_fault  = {1};
    }
  endgroup
  cg_asf_intergrity_fault i_cg_asf_intergrity_fault = new();
`ifdef ABV_ON_ASF
// 2.5.2 check the status
       property check_asf_intergity_fault_each_output_of_duplicated_raise_int_status;
      @(posedge pclk) disable iff (!n_preset)
        (asf_integrity_ar2r_fifo_err
        || asf_integrity_aw2w_fifo_err
        || asf_integrity_w2b_fifo_err
        || timer_strobe_err
        || tsu_sec_incr_err
        || tsu_timer_cnt_err
        || tsu_timer_cnt_par_err
        || tsu_timer_cmp_val_err
        || any_ets_en_err
        || scheduled_queue_err
        || nothing_to_xmit_err
        || fsm_active_err
        || tsu_hold_err
        || tsu_gatestate_err
        || byte_count_err
        || gatestate_out_err)
        |->  ##[0:100] (1'b1 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.asf_int_raw_status[6]));
       endproperty
      assert_check_asf_intergity_fault_each_output_of_duplicated_raise_int_status: assert property (check_asf_intergity_fault_each_output_of_duplicated_raise_int_status);
`endif // ABV_ON_ASF

///////////////////////////////////////////////////
// 2.6 IP Protocol Checking
// checks that an interrupt occurs if any of the status bits are set and not masked
       property check_asf_protocol_gen_int;
      @(posedge pclk) disable iff (!n_preset)
        (1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_int_mask[5]))
         && (|( (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_protocol_fault)
               & (~(`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.gen_protocol_check_added.asf_protocol_fault_mask_r))))
        |=> ((asf_int_nonfatal^asf_int_fatal) == 1'b1);
       endproperty
      assert_check_asf_protocol_gen_int: assert property (check_asf_protocol_gen_int);

// 2.6.1 check that for each masked and generated fault set bit in the protocol fault status register
  `define ASS_ASF_PROTOCOL_SET_STATUS(NUM_BIT) \
       property check_asf_protocol_set_status_``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
         (( 1'b1 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_protocol_fault[NUM_BIT])) \
         && ( 1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.gen_protocol_check_added.asf_protocol_fault_mask_r[NUM_BIT]))) \
        |=> ( 1'b1 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_protocol_check_added.asf_protocol_fault_status_w[NUM_BIT])); \
       endproperty \
      assert_check_asf_protocol_set_status_``NUM_BIT: assert property (check_asf_protocol_set_status_``NUM_BIT);

`ifdef ABV_ON_ASF
   `ASS_ASF_PROTOCOL_SET_STATUS(0)
   `ASS_ASF_PROTOCOL_SET_STATUS(1)
   `ASS_ASF_PROTOCOL_SET_STATUS(2)
   `ASS_ASF_PROTOCOL_SET_STATUS(3)
   `ASS_ASF_PROTOCOL_SET_STATUS(4)
   `ASS_ASF_PROTOCOL_SET_STATUS(5)
   `ASS_ASF_PROTOCOL_SET_STATUS(6)
   `ASS_ASF_PROTOCOL_SET_STATUS(7)
   `ASS_ASF_PROTOCOL_SET_STATUS(8)
   `ASS_ASF_PROTOCOL_SET_STATUS(16)
   `ASS_ASF_PROTOCOL_SET_STATUS(17)
   `ASS_ASF_PROTOCOL_SET_STATUS(18)
   `ASS_ASF_PROTOCOL_SET_STATUS(19)
   `ASS_ASF_PROTOCOL_SET_STATUS(20)
   `ASS_ASF_PROTOCOL_SET_STATUS(21)
`endif // ABV_ON_ASF

// 2.6.2 check that each IP protocol function can be individually masked
  `define ASS_ASF_PROTOCOL_IND_MASK(NUM_BIT) \
       property check_asf_protocol_ind_masked_``NUM_BIT; \
      @(posedge pclk) disable iff (!n_preset) \
        (( 1'b1 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_protocol_fault[NUM_BIT])) \
         & ( 1'b1 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.gen_protocol_check_added.asf_protocol_fault_mask_r[NUM_BIT]))) \
       |=> ( 1'b0 == (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.i_asf_fault_log_rpt_csr.gen_protocol_check_added.asf_protocol_fault_status_w[NUM_BIT])); \
       endproperty \
      assert_check_asf_protocol_ind_masked_``NUM_BIT: assert property (check_asf_protocol_ind_masked_``NUM_BIT);

`ifdef ABV_ON_ASF
   `ASS_ASF_PROTOCOL_IND_MASK(0)
   `ASS_ASF_PROTOCOL_IND_MASK(1)
   `ASS_ASF_PROTOCOL_IND_MASK(2)
   `ASS_ASF_PROTOCOL_IND_MASK(3)
   `ASS_ASF_PROTOCOL_IND_MASK(4)
   `ASS_ASF_PROTOCOL_IND_MASK(5)
   `ASS_ASF_PROTOCOL_IND_MASK(6)
   `ASS_ASF_PROTOCOL_IND_MASK(7)
   `ASS_ASF_PROTOCOL_IND_MASK(8)
   `ASS_ASF_PROTOCOL_IND_MASK(16)
   `ASS_ASF_PROTOCOL_IND_MASK(17)
   `ASS_ASF_PROTOCOL_IND_MASK(18)
   `ASS_ASF_PROTOCOL_IND_MASK(19)
   `ASS_ASF_PROTOCOL_IND_MASK(20)
   `ASS_ASF_PROTOCOL_IND_MASK(21)
`endif // ABV_ON_ASF

/////////////////////////////////////////////////////
//// 2.7 ECC

`ifndef gem_ext_fifo_interface
 `ifdef gem_rx_pkt_buffer
  wire asf_sram_corr_fault;
  wire asf_sram_uncorr_fault;
  wire rx_sram_prot_b_corr_err;
  wire tx_sram_prot_b_corr_err;

  `ifdef gem_asf_enable
   `ifdef gem_asf_ecc_sram
      assign asf_sram_corr_fault = (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_corr_fault);
   `else
      assign asf_sram_corr_fault = 1'b0;
   `endif // gem_asf_ecc_sram
    assign asf_sram_uncorr_fault = (`GEM_REG_TOP_HIERARCHY.i_gem_registers.i_reg_asf_fault_log_rpt.asf_sram_uncorr_fault);
    assign rx_sram_prot_b_corr_err = (`hierarchy.gen_dma.gen_pkt_buf_sram.gen_sram_prot.i_rx_sram_prot_b.corr_err);
    assign tx_sram_prot_b_corr_err = (`hierarchy.gen_dma.gen_pkt_buf_sram.gen_sram_prot.i_tx_sram_prot_b.corr_err);
  `else
    assign asf_sram_corr_fault   = 1'b0;
    assign asf_sram_uncorr_fault = 1'b0;
    assign rx_sram_prot_b_corr_err = 1'b0;
    assign tx_sram_prot_b_corr_err = 1'b0;
  `endif // gem_asf_enable

  wire directed_single_error_injection;
  wire directed_double_error_injection;
`ifdef directed
  assign directed_single_error_injection = `top.single_error_injection;
  assign directed_double_error_injection = `top.double_error_injection;
`else
  assign directed_single_error_injection = 1'b0;
  assign directed_double_error_injection = 1'b0;
`endif // directed

// 2.7.1 check that no errors when no faults are injected
`ifdef ABV_ON_ASF

       property check_asf_no_err_when_no_sram_fault_inj;
      @(posedge pclk) disable iff (!n_preset | disable_asf_assertions)
        ((1'b0 == directed_single_error_injection)
        && (1'b0 == directed_double_error_injection)
        && (1'b1 == ifss_off))
        |-> ((1'b0 == asf_sram_corr_fault)
              && (1'b0 == asf_sram_uncorr_fault));
       endproperty
      assert_check_asf_no_err_when_no_sram_fault_inj: assert property (check_asf_no_err_when_no_sram_fault_inj);

// 2.7.2 All single-bit faults should be detectable and correctable
`ifdef gem_asf_ecc_sram
      property check_asf_1_fault_inj_then_corr_detect;
      @(posedge pclk) disable iff (!n_preset)
        ((((1'b1 == directed_single_error_injection) || (1'b1 == ifss_off))
        && (1'b0 == directed_double_error_injection))
        && (rx_sram_prot_b_corr_err
             || tx_sram_prot_b_corr_err))
        |-> ##[1:10] (1'b1 == asf_sram_corr_fault);
       endproperty
      assert_check_asf_1_fault_inj_then_corr_detect: assert property (check_asf_1_fault_inj_then_corr_detect);
`endif

`endif // ABV_ON_ASF

logic [31:0] rx_pbuf_data;
assign rx_pbuf_data = `gem_rx_pbuf_data;
logic [31:0] tx_pbuf_data;
assign tx_pbuf_data = `gem_tx_pbuf_data;
logic [1:0] pbuf_mode;
`ifndef gem_ext_fifo_interface
  `ifdef gem_rx_pkt_buffer
    `ifdef gem_spram
      assign pbuf_mode = 1;
    `else
      assign pbuf_mode = 2;
    `endif
  `else
    assign pbuf_mode = 0;
  `endif
`else
  assign pbuf_mode = 0;
`endif

  wire rx_double_err_inj_wait_int;
  wire rx_err_inj_pos;
  wire rx_inj_err_now;
  wire tx_double_err_inj_wait_int;
  wire tx_err_inj_pos;
  wire tx_inj_err_now;
`ifdef directed
  assign rx_double_err_inj_wait_int = `top.i_tb_top.i_rx_ram_err_inj.double_inj_wait_int;
  assign rx_err_inj_pos = `top.i_tb_top.i_rx_ram_err_inj.err_pos;
  assign rx_inj_err_now = `top.i_tb_top.i_rx_ram_err_inj.inj_err_now;
  assign tx_double_err_inj_wait_int = `top.i_tb_top.i_tx_ram_err_inj.double_inj_wait_int;
  assign tx_err_inj_pos = `top.i_tb_top.i_tx_ram_err_inj.err_pos;
  assign tx_inj_err_now = `top.i_tb_top.i_rx_ram_err_inj.inj_err_now;
`else
  assign rx_double_err_inj_wait_int = 1'b0;
  assign rx_err_inj_pos = 1'b0;
  assign rx_inj_err_now = 1'b0;
  assign tx_double_err_inj_wait_int = 1'b0;
  assign tx_err_inj_pos = 1'b0;
  assign tx_inj_err_now = 1'b0;
`endif // directed

  integer err_rx_inj_pos;
  integer err_tx_inj_pos;
  integer first_2_err_rx_inj_pos;
  integer second_2_err_rx_inj_pos;
  integer first_2_err_tx_inj_pos;
  integer second_2_err_tx_inj_pos;

  always@(*) begin
    if (1'b1 == directed_double_error_injection) begin
      if (rx_double_err_inj_wait_int) begin
        first_2_err_rx_inj_pos = rx_err_inj_pos;
      end else begin
        second_2_err_rx_inj_pos = rx_err_inj_pos;
      end
      if (tx_double_err_inj_wait_int) begin
        first_2_err_tx_inj_pos = tx_err_inj_pos;
      end else begin
        second_2_err_tx_inj_pos = tx_err_inj_pos;
      end
    end else begin
      err_rx_inj_pos = 'dx;
      err_tx_inj_pos = 'dx;
    end
    if (1'b1 == directed_single_error_injection) begin
      err_rx_inj_pos = rx_err_inj_pos;
      err_tx_inj_pos = tx_err_inj_pos;
    end else begin
      err_rx_inj_pos = 'dx;
      err_tx_inj_pos = 'dx;
    end
  end
  assign rx_inj_err_now = rx_inj_err_now;
  assign tx_inj_err_now = tx_inj_err_now;

// 2.7.3 show that faults have been injected all bits of the data bus
// 2.7.4 cross faults injected X data bus width X SPRAM X tx_rx
// 2.7.6 show that 2-bit faults have been detected
// 2.7.7 cross 2-bit faults with data_bus_width X SPRAM X tx_rx
  covergroup cg_asf_rx_sram_err_inj @(posedge rx_inj_err_now);
    cp_pbuf_mode : coverpoint (pbuf_mode) {
      ignore_bins no_pbuf       = {0};
      bins        pbuf_spram    = {1};
      bins        pbuf_dpram    = {2};
    }
    cp_rx_pbuf_data : coverpoint (rx_pbuf_data)  {
      bins rx_pbuf_data_is_32b   = {32};
      bins rx_pbuf_data_is_64b   = {64};
      bins rx_pbuf_data_is_128b  = {128};
      illegal_bins data_width_bad = default;
    }
    cp_asf_rx_sram_1_err_inj_in_all_bits : coverpoint (err_rx_inj_pos) {
      bins asf_sram_1_err_at_bit[]  = {[1:`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data]};
    }
    cp_asf_rx_sram_1_err_inj_in_all_bits_all_mode : cross cp_asf_rx_sram_1_err_inj_in_all_bits, cp_rx_pbuf_data, cp_pbuf_mode;

    cp_first_2_err_rx_inj_pos : coverpoint (first_2_err_rx_inj_pos)  {
      bins two_err_inj_in_low_bits   = {[0:50]};
      bins two_err_inj_in_med_bits   = {[49:99]};
      bins two_err_inj_in_high_bits  = {[100:$]};
//      ignore_bins two_err_inj_in_300bit  = {300};
    }
    cp_second_2_err_rx_inj_pos : coverpoint (second_2_err_rx_inj_pos)  {
      bins two_err_inj_in_low_bits   = {[0:50]};
      bins two_err_inj_in_med_bits   = {[49:99]};
      bins two_err_inj_in_high_bits  = {[100:$]};
//      ignore_bins two_err_inj_in_300bit  = {300};
    }
   cp_2_err_rx_inj_pos : cross cp_first_2_err_rx_inj_pos, cp_second_2_err_rx_inj_pos;

//    cp_asf_rx_sram_2_err_inj_in_all_bits : coverpoint (tb_gem_gxl.i_tb_top.i_rx_ram_err_inj.err_pos) {
//      bins asf_sram_1_err_at_bit[]  = {[1:`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data]};
 //   }
//    cp_asf_tx_sram_2_err_inj_in_all_bits : coverpoint (tb_gem_gxl.i_tb_top.i_tx_ram_err_inj.err_pos) {
//      bins asf_sram_1_err_at_bit[]  = {[1:`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data]};
//    }
//    cp_asf_rx_sram_1_err_inj_in_all_bits_all_mode : cross cp_asf_rx_sram_1_err_inj_in_all_bits, cp_rx_pbuf_data, cp_pbuf_mode;
//    cp_asf_tx_sram_1_err_inj_in_all_bits_all_mode : cross cp_asf_tx_sram_1_err_inj_in_all_bits, cp_tx_pbuf_data, cp_pbuf_mode;
//

  endgroup
  cg_asf_rx_sram_err_inj i_cg_asf_rx_sram_err_inj = new();

// 2.7.3 show that faults have been injected all bits of the data bus
// 2.7.4 cross faults injected X data bus width X SPRAM X tx_rx
// 2.7.6 show that 2-bit faults have been detected
// 2.7.7 cross 2-bit faults with data_bus_width X SPRAM X tx_rx
  covergroup cg_asf_tx_sram_err_inj @(posedge tx_inj_err_now);
    cp_pbuf_mode : coverpoint (pbuf_mode) {
      ignore_bins no_pbuf       = {0};
      bins        pbuf_spram    = {1};
      bins        pbuf_dpram    = {2};
    }
    cp_tx_pbuf_data : coverpoint (tx_pbuf_data)  {
      bins tx_pbuf_data_is_32b   = {32};
      bins tx_pbuf_data_is_64b   = {64};
      bins tx_pbuf_data_is_128b  = {128};
      illegal_bins data_width_bad = default;
    }
    cp_asf_tx_sram_1_err_inj_in_all_bits : coverpoint (err_tx_inj_pos) {
      bins asf_sram_1_err_at_bit[]  = {[1:`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data]};
    }
    cp_asf_tx_sram_1_err_inj_in_all_bits_all_mode : cross cp_asf_tx_sram_1_err_inj_in_all_bits, cp_tx_pbuf_data, cp_pbuf_mode;

    cp_first_2_err_tx_inj_pos : coverpoint (first_2_err_tx_inj_pos)  {
      bins two_err_inj_in_low_bits   = {[0:50]};
      bins two_err_inj_in_med_bits   = {[49:99]};
      bins two_err_inj_in_high_bits  = {[100:$]};
//      ignore_bins two_err_inj_in_300bit  = {300};
    }
    cp_second_2_err_tx_inj_pos : coverpoint (second_2_err_tx_inj_pos)  {
      bins two_err_inj_in_low_bits   = {[0:50]};
      bins two_err_inj_in_med_bits   = {[49:99]};
      bins two_err_inj_in_high_bits  = {[100:$]};
//      ignore_bins two_err_inj_in_300bit  = {300};
    }
    cp_2_err_tx_inj_pos : cross cp_first_2_err_tx_inj_pos, cp_second_2_err_tx_inj_pos;

//    cp_asf_rx_sram_2_err_inj_in_all_bits : coverpoint (tb_gem_gxl.i_tb_top.i_rx_ram_err_inj.err_pos) {
//      bins asf_sram_1_err_at_bit[]  = {[1:`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data]};
 //   }
//    cp_asf_tx_sram_2_err_inj_in_all_bits : coverpoint (tb_gem_gxl.i_tb_top.i_tx_ram_err_inj.err_pos) {
//      bins asf_sram_1_err_at_bit[]  = {[1:`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data]};
//    }
//    cp_asf_rx_sram_1_err_inj_in_all_bits_all_mode : cross cp_asf_rx_sram_1_err_inj_in_all_bits, cp_rx_pbuf_data, cp_pbuf_mode;
//    cp_asf_tx_sram_1_err_inj_in_all_bits_all_mode : cross cp_asf_tx_sram_1_err_inj_in_all_bits, cp_tx_pbuf_data, cp_pbuf_mode;
//

  endgroup
  cg_asf_tx_sram_err_inj i_cg_asf_tx_sram_err_inj = new();

 `endif // gem_rx_pkt_buffer
`endif //gem_ext_fifo_interface

endmodule



