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
//   Filename:           tb_spram_linerate_monitor.sv
//   Module Name:        tb_spram_linerate_monitor
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
//   Description    :
//
// Monitor the TX Line rate in SPRAM mode to determine if there are any
// drops in linerate. If there are any drops in linerate then raise
// an assertion.
//
// Note this block is only active when sel_ahb_freq is greater than or equal
// to 5 as these tests are specified with a amba rate faster than the
// mac rate so there should be no drops on the bus.
//
//------------------------------------------------------------------------------


`ifndef CDN_UVM
   `include "tb_defs.v"
`endif

module tb_spram_linerate_monitor (

   // Config signals
   input [2:0] sel_ahb_freq,
   input gigabit,
   input speed,

   // MAC IF Signals
   input tx_clk,
   input tx_en,

   // APB Interface
   input pclk,
   input ethernet_int

);



   // -----------------------------------------------------------------------------
   //
   //                        Internal Signals
   //
   // -----------------------------------------------------------------------------



   parameter FAIL_NUM_IDLES = 20; // Number of idles bytes between frames to denote an error

   int unsigned idle_count, frame_count;
   event request_assertion;
   bit trigger_assertion;
   byte unsigned pclk_count;

   // --
   // linerate monitor enable
   // only enable in edma_spram
   // --
   wire linerate_non_en;
   `ifdef edma_spram
      assign linerate_non_en = 1'b1;
   `else
      assign linerate_non_en = 1'b0;
   `endif

   // -----------------------------------------------------------------------------
   //
   //                        Linerate Monitor
   //
   // -----------------------------------------------------------------------------



   initial begin
      trigger_assertion = 0;
      #1;
      // All of the tests when sel_ahb_freq >=5 are targetted at line
      // rate checks, so we only check linerates in this mode.
      if (sel_ahb_freq >=5)
         spram_monitor_linerate();
   end

   task spram_monitor_linerate();
   begin

      byte unsigned fail_num_idles;

      // Allow for some start-up time
      #100;

      fork

         // Monitor the number of idles when a frame finished and raise an
         // error if there are too many idles, unless of course the
         // check is cancelled
         forever begin

            idle_count = 0;
            @(negedge tx_en)

            fail_num_idles = gigabit ? FAIL_NUM_IDLES : 2*FAIL_NUM_IDLES;

            while (!tx_en && frame_count >= 5) begin
               @(posedge tx_clk);
               idle_count++;
               // --
               // only do check if linerate monitor is enabled
               // --
               if (linerate_non_en && (idle_count == fail_num_idles)) begin
                  // It can take time for an interrupt to be raised, owing
                  // to the slower system frequencies in spram mode, so we
                  // request an assertion and if an interupt is raised
                  // relatively quickly then we will cancel the assertion
                  // request.
                  -> request_assertion;
               end
            end

         end

         // We don't want to monitor the linerate until the pipeline has had
         // a few frames to get going (we allow 5 frames). We also stop the linerate check
         // if we see an interrupt as this will halt the pipeline when
         // a frame is restarted.
         begin

            frame_count = 0;

            fork
            forever begin
               @(posedge tx_en);
               frame_count++;
            end
            forever begin
               @(posedge ethernet_int);
               frame_count = 0;
            end
            join

         end

         // The linerate has dropped below expected, but ensure an interrupt
         // isn't pending. If an interrupt occurs then we won't flag the
         // assertion.
         forever begin

            pclk_count = 0;
            trigger_assertion = 0;
            @(request_assertion);
            while (pclk_count < 32 && !ethernet_int) begin
               @(posedge pclk);
               pclk_count++;
               if (pclk_count==32) begin
                  $display("**** Error : FAILED SPRAM Linerate dropped more than expected %t", $time());
                  trigger_assertion = 1;
                 @(posedge pclk);
                 @(posedge pclk);
                  $finish();
               end
            end
         end

      join

   end
   endtask

always @(negedge (pclk))
  AP_SPRAM_LINE_RATE : assert ( trigger_assertion == 1'b0 );

endmodule
