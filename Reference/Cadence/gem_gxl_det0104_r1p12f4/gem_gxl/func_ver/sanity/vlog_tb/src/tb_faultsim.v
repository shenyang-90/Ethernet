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
//   Filename:           tb_faultsim.v
//   Module Name:        tb_faultsim
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
//   Description : This module, when enabled,will run some tests to aid IFSS
//                 fault simulations. 1. Fast APB sweep. Writes all zeros to
//                 all regs, then all ones. No functional read checks
//
//------------------------------------------------------------------------------


`ifndef TB_DEFS
   `include "tb_defs.v"
   `include "edma_defs.v"
`endif

module tb_faultsim (

   // Auto fault checker enable .. This comes from the testcase and will enable the automatic validation of errors in interrupt/stats
   input   [15:0]    fault_sim,

   // Test status indication from rest of TB.
   input              fault_sim_trig,

   // Rest of GEM TB APB driver (normal TB)
   input              pclk,              // amba apb clock.
   input              n_preset,          // amba apb reset.
   input              psel,
   input              psel_int,

   // APB interface signals.
   output  reg [12:0] paddr_faultsim,        // address bus of selected master.
   output  reg [31:0] pwdata_faultsim,       // write data.
   output  reg  [3:0] pwdata_par_faultsim,
   output  reg        pwrite_faultsim,       // peripheral write strobe.
   output  reg        penable_faultsim,      // peripheral enable.
   output  reg        psel_faultsim,         // peripheral select.

   // used to finish the test
   output  reg        fault_sim_done

  );

  reg done_apb;
  integer i;

  `include "edma_params.v"

  initial begin
    psel_faultsim    = 1'b0;
    penable_faultsim = 1'b0;
    pwdata_faultsim  = 32'h00000000;
    pwdata_par_faultsim = 4'h0;
    pwrite_faultsim  = 1'b0;
    paddr_faultsim   = 13'h0000;
    fault_sim_done = 1'b1;
    done_apb = 1'b0;
    fault_sim_done = 0;
    @(negedge pclk);
    fault_sim_done = !fault_sim_trig;

    forever begin
      if (!done_apb) @(negedge pclk);
      done_apb = 1'b0;
      penable_faultsim = 1'b0;
      psel_faultsim    = 1'b0;

      if (fault_sim_trig )
      begin

        case (fault_sim)

          16'd0 : // APB sweep for CSR validation
          begin
            @(negedge pclk);
            $display ("Starting Fault Simulation - I will shortly blast the design with an all zeroes/all ones write");
            $display ("Expect all CSR's that have faults injected by IFSS to be detected ..");
            while (!n_preset) @(negedge pclk);
            for (i=0;i<200;i++) @(negedge pclk);  // short delay before we start
            $display ("Writing all zeroes to APB address space");
            for (i=0;i<=13'h1fff;i=i+4) if (i[11:0]!=12'he0c) do_apb_write(i[12:0],32'h00000000);   // exclude ASF int test register
            $display ("Writing all ones to APB address space");
            for (i=0;i<=13'h1fff;i=i+4) if (i[11:0]!=12'he0c) do_apb_write(i[12:0],32'hffffffff);
            fault_sim_done = 1'b1;
          end

        endcase

      end
    end
  end


   task do_apb_read;
      input [12:0] paddr;
//      $display("APB read at address %08x at time %0dns",paddr,$time);
      while(psel_int === 1'b1) @(posedge pclk);
      psel_faultsim    = 1'b1;
      penable_faultsim = 1'b0;
      paddr_faultsim   = paddr;
      pwrite_faultsim  = 1'b0;
      pwdata_faultsim  = 32'h00000000;
      pwdata_par_faultsim = 4'h0;
      @(negedge pclk);
      penable_faultsim = 1'b1;
//      prdata_faultsim = prdata;
      @(negedge pclk);
      done_apb = 1'b1;
   endtask

   task do_apb_write;
      input [12:0] paddr;
      input [31:0] pwdata;
      psel_faultsim    = 1'b1;
      pwrite_faultsim  = 1'b1;
      paddr_faultsim   = paddr;
      penable_faultsim = 1'b0;
      pwdata_faultsim  = pwdata;
      pwdata_par_faultsim = {^pwdata[31:24],^pwdata[23:16],^pwdata[15:8],^pwdata[7:0]};
      @(negedge pclk);
      penable_faultsim = 1'b1;
      @(negedge pclk);
      done_apb = 1'b1;
   endtask

endmodule


