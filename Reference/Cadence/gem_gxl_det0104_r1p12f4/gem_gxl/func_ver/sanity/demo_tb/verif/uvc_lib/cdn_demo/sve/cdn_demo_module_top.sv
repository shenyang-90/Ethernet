//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file contains the demo tb for the cdn_demo UVC.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Required timescale for sequence delays.
//----------------------------------------------------------------------------
`timescale 1ns / 1ps

//----------------------------------------------------------------------------
// Interfaces
//----------------------------------------------------------------------------

`include "cdn_clock_if.sv"
`include "cdn_reset_if.sv"
`include "cdn_demo_misc_signals_if.sv"
`include "cdnApb4Interface.sv"
`include "cdn_axi_vip_if.sv"
`include "cdn_demo_module_top_c_dpi.sv"
`ifdef CDN_DEMO_RAM_INTEGRATION_TEST
`include "cdn_demo_ram_integration_stub_bfm.sv"
`include "ram_1p.v"
`include "ram_2p.v"
`include "sp_ram_2s.v"
`include "dp_ram_2s.v"
`include "spram.v"
`endif

//----------------------------------------------------------------------------
// Create the testbench.
//----------------------------------------------------------------------------

module cdn_demo_tb;

   //------------------------------------------------------------------------
   // Import Packages
   //------------------------------------------------------------------------
   // Import UVM Package
   import uvm_pkg::*;

   // Bring in the rest of the library (macros)
   `include "uvm_macros.svh"

   // Import the cdn_demo UVC Package
   import cdn_demo_pkg::*;

   //------------------------------------------------------------------------
   // Other testbench signals
   //------------------------------------------------------------------------

   // Clock/Reset/INterrupt
   wire clk0, clk1, clk2, clk3;
   wire rst0_n, rst1_n, rst2_n, rst3_n;
   wire interrupt;

   //------------------------------------------------------------------------
   // Interfaces
   //------------------------------------------------------------------------

   cdn_clock_if clock_if0();
   cdn_clock_if clock_if1();
   cdn_clock_if clock_if2();
   cdn_clock_if clock_if3();
   cdn_reset_if reset_if0(clock_if0.sig_clock_0);
   cdn_reset_if reset_if1(clock_if1.sig_clock_0);
   cdn_reset_if reset_if2(clock_if2.sig_clock_0);
   cdn_reset_if reset_if3(clock_if3.sig_clock_0);

   // This clock if is specific for the csp_delay_us functionality. The block
   // is configured to use a dedicated 1us clock.
   cdn_clock_if clock_if_csp_delay_us();

   cdn_demo_misc_signals_if misc_signals_if(clock_if0.sig_clock_0, reset_if0.sig_reset, interrupt);

   assign clk0 = clock_if0.sig_clock_0;
   assign clk1 = clock_if1.sig_clock_0;
   assign clk2 = clock_if2.sig_clock_0;
   assign clk3 = clock_if3.sig_clock_0;
   assign rst0_n = reset_if0.sig_reset;
   assign rst1_n = reset_if1.sig_reset;
   assign rst2_n = reset_if2.sig_reset;
   assign rst3_n = reset_if3.sig_reset;
   assign clk_csp_delay_us = clock_if_csp_delay_us.sig_clock_0;

   cdn_demo_module_top_c_dpi c_dpi (.clk(clk_csp_delay_us), .interrupt(interrupt));

   //------------------------------------------------------------------------
   // Start the run_test phase
   //------------------------------------------------------------------------
   initial begin
      run_test();
   end

   //------------------------------------------------------------------------
   // DUT INSTANCE AND CONNECTIONS
   //------------------------------------------------------------------------

   initial begin
      misc_signals_if.sig_dut_ready = 0;
      @(reset_if0.sig_reset === 1);
      #200
      misc_signals_if.sig_dut_ready = 1;
   end


   //------------------------------------------------------------------------
   // Instantiate the System Side VIP
   //------------------------------------------------------------------------


   cdnApb4Interface #(.NUM_OF_SLAVES(`CDN_DEMO_APB_NUM_OF_SLAVES),.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH),.DATA_WIDTH(32)) apb_reg_if (clk0,rst0_n);
   `createCdnApb4SlaveInterface(apb_reg_if,0,`CDN_DEMO_APB_ADDRESS_WIDTH)

   // TODO - This workaround shouldn't be needed and needs investigated.
   `ifdef CDN_DEMO_RAM_INTEGRATION_TEST
   cdn_axi_vip_if axi_if   (clk0,rst1_n);
   `else
   cdn_axi_vip_if axi_if   (clk0,rst0_n);
   `endif

   // Create a second slave to connect, for example, a PHY or the RAM integration
   // module
   `createCdnApb4SlaveInterface(apb_reg_if,1,`CDN_DEMO_APB_ADDRESS_WIDTH)
   // If this second slave is not used then it can be tied off using the following
   // lines of code.
   //assign apb_reg_if_slave1.pready = 1'b1;
   //assign apb_reg_if_slave1.prdata = 32'd0;

   //------------------------------------------------------------------------
   // Include the protocol specif DUT, VIP and associated code
   //------------------------------------------------------------------------

   `include "cdn_demo_module_tb.sv"
   `include "cdn_demo_test_lib.sv"
   `ifndef CDN_DEMO_RAM_INTEGRATION_TEST
      `include "cdn_protocol_demo_module_top.sv"
   `endif


   //------------------------------------------------------------------------
   // CDN RAM Integration
   //
   // Incorporate the RAM Integration functionality if specified
   //------------------------------------------------------------------------

   `ifdef CDN_DEMO_RAM_INTEGRATION_TEST
   `ifndef CUSTOMER_DUT
   `include "cdn_demo_ram_integration_top.sv"
   `endif
   `endif

   //------------------------------------------------------------------------
   // DUT Instantiation
   //
   // Instantiate Customer DUT or Cadence DUT
   //------------------------------------------------------------------------

   `ifndef CUSTOMER_DUT

      // Instantiate Cadence DUT

   `else

      `include "customer_dut.sv"

   `endif

endmodule

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------







