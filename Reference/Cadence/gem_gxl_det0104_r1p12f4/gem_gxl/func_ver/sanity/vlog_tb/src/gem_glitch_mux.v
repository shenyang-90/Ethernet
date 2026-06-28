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
//   Filename:           gem_glitch_mux.v
//   Module Name:        gem_glitch_mux
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
//   Description    :   Glitch free multiplexer for clocks.
//                      Note that both source clocks must be free running when
//                      switching clock source.
//
//------------------------------------------------------------------------------


module gem_glitch_mux (
   n_reset,
   clock1,
   clock2,
   select1,
   clkout
   );

   //---------------------------------------------------------------------------
   // declare inputs
   //---------------------------------------------------------------------------
   input          n_reset;             // system asynchronous reset
   input          clock1;              // clock source 1
   input          clock2;              // clock source 2
   input          select1;             // select clock source 1 for clkout

   //---------------------------------------------------------------------------
   // declare outputs
   //---------------------------------------------------------------------------
   output         clkout;              // output clock from MUX


   //---------------------------------------------------------------------------
   // declare internal signals
   //---------------------------------------------------------------------------
   reg            en_del1_clk1;        // select enable delayed for clock 1
   reg            en_del2_clk1;        // select enable delayed for clock 1
   reg            en_del3_nclk1;       // select enable delayed for clock 1
   reg            en_del1_clk2;        // select enable delayed for clock 2
   reg            en_del2_clk2;        // select enable delayed for clock 2
   reg            en_del3_nclk2;       // select enable delayed for clock 2
   wire           n_select1;           // inverted select1



   //---------------------------------------------------------------------------
   // BEGINNING OF MAIN CODE
   //---------------------------------------------------------------------------

   // if clock1 not selected hold clock 1 source enable logic in reset
   always @(posedge clock1 or negedge select1)
   begin
      if (~select1)
      begin
         en_del1_clk1 <= 1'b0;
         en_del2_clk1 <= 1'b0;
      end
      else
      begin
         en_del1_clk1 <= ~en_del3_nclk2;
         en_del2_clk1 <= en_del1_clk1;
      end
   end

   //sync last enable to negedge so full pulse will be seen
   always @(negedge clock1 or negedge n_reset)
   begin
      if (~n_reset)
      begin
         en_del3_nclk1 <= 1'b0;
      end
      else
      begin
         en_del3_nclk1 <= en_del2_clk1;
      end
   end


   // invert select signal so can hold clock2 source enable logic in reset
   assign n_select1 = ~select1;


   // if clock2 not selected hold source enable logic in reset
   always @(posedge clock2 or negedge n_select1)
   begin
      if (~ n_select1)
      begin
         en_del1_clk2 <= 1'b0;
         en_del2_clk2 <= 1'b0;
      end
      else
      begin
         en_del1_clk2 <= ~en_del3_nclk1;
         en_del2_clk2 <= en_del1_clk2;
      end
   end

   //sync last enable to negedge so full pulse will be seen
   always @(negedge clock2 or negedge n_reset)
   begin
      if (~n_reset)
      begin
         en_del3_nclk2 <= 1'b0;
      end
      else
      begin
         en_del3_nclk2 <= en_del2_clk2;
      end
   end


   //assign glitch free mux output
   assign clkout = ((en_del3_nclk1 & clock1) | (en_del3_nclk2 & clock2));




endmodule
