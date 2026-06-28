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
//   Filename:           gem_clk_cntrl.v
//   Module Name:        gem_clk_cntrl
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
//   Description    :   The clock and distribution module for the GEM.
//                      This could be used to form the basis of a clock
//                      generator module for the GEM design.
//
//------------------------------------------------------------------------------


// include definition files
  `include "gem_gxl_defs.v"

module gem_clk_cntrl (

   // Inputs.
   n_reset,
   pclk_source,
   hclk_source,
   rx_clk_from_phy,
   tx_clk_from_phy,
   gtx_ref_clk,
   gtx20_ref_clk,
   rbc0_from_phy,
   rbc1_from_phy,
   pcs_rx_clk_from_phy,
   pcs_rx20_clk_from_phy,
   mii_select,
   gigabit,
   tbi,
   speed,
   loopback_local,
   scan_clk,
   scan_test_mode,

   // rmii clocks
   rmii_rx_clk,
   rmii_tx_clk,

   // loopback clocks
   loop_clk_source,
   n_tx_clk_to_gem,
   n_rx_clk_to_gem,

   // Outputs
   pclk_to_gem,
   hclk_to_gem,
   gtx_clk_to_gem,
   gtx20_clk_to_gem,
   rbc0_to_gem,
   rbc1_to_gem,
   pcs_rx_clk_to_gem,
   pcs_rx20_clk_to_gem,
   rx_clk_to_gem,
   tx_clk_to_gem

   );

   // port declarations.

   // inputs.
   input        n_reset;         // system asynchronous reset
   input        pclk_source;     // APB clock source
   input        hclk_source;     // AHB clock source
   input        rx_clk_from_phy; // receive data clock (mii/gmii) 2.5/25/125MHz
   input        tx_clk_from_phy; // transmit data clock (mii) 2.5/25MHz
   input        gtx_ref_clk;     // gigabit transmit reference clock (125MHz)
                                 // for PCS and GMII MAC.
   input        gtx20_ref_clk;   // 20-bit GTX clock
   input        rbc0_from_phy;   // pcs receive clock 0. (62.5 MHz)
   input        rbc1_from_phy;   // pcs receive clock 1. (62.5 MHz)
   input        pcs_rx_clk_from_phy;  // 125MHz
   input        pcs_rx20_clk_from_phy;// 62.5MHz
   input        gigabit;         // indicate gigabit operation.
   input        mii_select;      // when not in Gigabit, selects mii or rmii
                                 // 0 - rmii, 1 - mii
   input        tbi;             // indicate pcs in use.
   input        speed;           // indicates 10 or 100Mbps operation (high for
                                 // 100Mbps)
   input        loopback_local;  // indicate internal loopback.

   input  [10:0] scan_clk;        // scan clocks
   input        scan_test_mode;  // indicates scan test is active

   input        rmii_rx_clk;     // rx clock for the RMII interface
   input        rmii_tx_clk;     // tx clock for the RMII interface

   // outputs.
   output       pclk_to_gem;     // pclk
   output       hclk_to_gem;     // hclk
   output       gtx_clk_to_gem;  // pcs tx clk
   output       gtx20_clk_to_gem;// pcs tx clk
   output       rbc0_to_gem;     // pcs rx clk phase 0.
   output       rbc1_to_gem;     // pcs rx clk phase 1.
   output       pcs_rx_clk_to_gem;
   output       pcs_rx20_clk_to_gem;
   output       rx_clk_to_gem;   // rx clock for gem_gxl receive blocks.
   output       tx_clk_to_gem;   // tx clock for gem_gxl transmit blocks.

   // Loopback clocks
   input        loop_clk_source; // clock used during internal loopback.
   output       n_tx_clk_to_gem; // inverted tx_clk for loopback
   output       n_rx_clk_to_gem; // inverted rx_clk for loopback

   // reg and wire declarations.
   wire         pclk_to_gem;     // pclk
   wire         hclk_to_gem;     // hclk
   wire         gtx_clk_to_gem;  // pcs tx clk
   wire         rbc0_to_gem;     // pcs rx clk phase 0.
   wire         rbc1_to_gem;     // pcs rx clk phase 1.
   reg          rx_clk_to_gem;   // rx clock for gem_gxl receive blocks.
   reg          tx_clk_to_gem;   // tx clock for gem_gxl transmit blocks.

   wire         tx_clk_mii_int;  // tx clock output from rmii mux
   wire         tx_clk_int;      // tx clock output from tx_clk/gtx_clk mux
   wire         tx_clk_int2;     // tx clock output from loopback mux
   wire         tx_clk_int3;     // tx clock output from scan mux
   wire         rx_clk_int;      // rx clock output from rx_clk/rbc1 mux
   wire         rx_clk_int2;     // rx clock output from loopback mux
   wire         rx_clk_int3;     // rx clock output from scan mux
   wire         rbc0_int;        // internal rbc from SerDes or external PHY
   wire         rbc1_int;        // internal rbc from SerDes or external PHY
   reg          gigabit_pclk;    // gigabit synced to pclk.
   reg          tbi_pclk;        // tbi synced to pclk.
   reg          loopback_pclk;   // loopback_local synced to pclk.
   reg          mii_select_pclk; // selects mii or rmii clocks
   reg          rbc1_delete;     // deletes clock phases for 10/100 SGMII mode
   reg          gtx_clk_delete;  // deletes clock phases for 10/100 SGMII mode
   reg    [5:0] rbc1_count;      // used to count rbc1 clock phases for deletion
   reg    [6:0] gtx_clk_count;   // used to count rbc1 clock phases for deletion

   // tbi is set when the ten bit interface is being used in gigabit or SGMII
   // modes. gigabit is set for gigabit operation. speed is set for 100 Mbps
   // operation and is low for 10Mbps.
   //
   //  tbi gigabit speed
   //   1     1      x       gigabit SGMII or tbi operation
   //   0     1      x       gigabit GMII operation
   //   1     0      1       100Mbps SGMII operation
   //   1     0      0       10Mbps SGMII operation
   //   0     0      x       MII operation (10/100Mbps)

   // The MAC tx_clk is sourced from the PHY for MII mode and from
   // gtx_ref_clk for all other modes (gigabit, tbi and SGMII). In
   // SGMII 10/100Mbps modes gtx_ref_clk is divided down before being
   // supplied to tx_clk.

   // The MAC rx_clk is sourced from the PHY for MII and GMII modes and from
   // rbc1 in other modes (tbi and SGMII). In SGMII 10/100Mbps modes rbc1 is
   // divided down before being supplied to rx_clk.


   // Drive directly from PHY signals
   assign rbc0_int = rbc0_from_phy;
   assign rbc1_int = rbc1_from_phy;

   // Generate rbc1_delete signal. This is to divide rbc1 down from 62.5MHz
   // to 1.25Mhz and 12.5MHz in 10 and 100Mbps SGMII mode. MAC receive datapath
   // is 16 bits for gigabit TBI and 8 bits for 10 and 100Mbps SGMII mode. So
   // divide clock speed down by 5 and 50 rather than 10 and 100.
   // Note negedge timing so gating occurs when rbc1_int is low.
   always @(negedge rbc1_int or negedge n_reset)
      if (~n_reset)
         begin
            rbc1_delete   <= 1'b0;
            rbc1_count    <= 6'b0;
         end
      else if (gigabit | ((rbc1_count == 6'b000100) & speed) // 5-1=4
                       |  (rbc1_count == 6'b110001)) // 50-1=49
         begin
            rbc1_delete   <= 1'b0;
            rbc1_count    <= 6'b0;
         end
      else
         begin
            rbc1_delete   <= 1'b1;
            rbc1_count    <= rbc1_count + 1;
         end


   // Generate gtx_clk_delete signal. This is to divide gtx_clk down from
   // 125MHz to 1.25Mhz and 12.5MHz in 10 and 100Mbps SGMII mode
   // Note negedge timing so gating occurs when gtx_ref_clk is low.
   always @(negedge gtx_ref_clk or negedge n_reset)
      if (~n_reset)
         begin
            gtx_clk_delete   <= 1'b0;
            gtx_clk_count    <= 7'b0;
         end
      else if (gigabit | ((gtx_clk_count == 7'b0001001) & speed) // 10-1=9
                       |  (gtx_clk_count == 7'b1100011)) // 100-1=99
         begin
            gtx_clk_delete   <= 1'b0;
            gtx_clk_count    <= 7'b0;
         end
      else
         begin
            gtx_clk_delete   <= 1'b1;
            gtx_clk_count    <= gtx_clk_count + 1;
         end


   //---------------------------------------------------------------------------
   // Synchronise control signals to PCLK
   //---------------------------------------------------------------------------

   // Resynchronise clock mux control signals back into pclk domain
   // (already in pclk domain, but helps timing to resynchronise)
   always @(posedge pclk_source or negedge n_reset)
      if (~n_reset)
         begin
            gigabit_pclk  <= 1'b0;
            tbi_pclk      <= 1'b0;
            loopback_pclk <= 1'b0;
            mii_select_pclk <= 1'b0;
         end
      else
         begin
            gigabit_pclk  <= gigabit;
            tbi_pclk      <= tbi;
            loopback_pclk <= loopback_local;
            mii_select_pclk <= mii_select;
         end



   //---------------------------------------------------------------------------
   // transmit clocks
   //---------------------------------------------------------------------------

   // tx_clk_mii_int is used to selecr between the tx_clk_from_phy (mii) and
   // rmii_tx_clk (rmii) using mii_select. Switching is glitch free and is
   // logically equivalent to the following
   //
   // assign tx_clk_mii_int = (mii_select)? tx_clk_from_phy : rmii_tx_clk;
   // Note that the design of the glitch free muxes requires that both clocks
   // must be running at the point of switching. This may not be suitable in
   // all systems, especially if a clock source is generated externally
   // (e.g. receive clock generated by the PHY)
   gem_glitch_mux i_gfm_tx_mii (
   .n_reset (n_reset),
   .clock1  (tx_clk_from_phy),
   .clock2  (rmii_tx_clk),
   .select1 (mii_select_pclk),
   .clkout  (tx_clk_mii_int)
   );

   // tx_clk_int is sourced from either gtx_ref_clk or tx_clk_mii_int,
   // depending on gigabit.
   // Switching is glitch free and is logically equivalent to the following:
   //
   // assign tx_clk_int = (gigabit_pclk | tbi_pclk) ?
   //                                         gtx_ref_clk : tx_clk_mii_int;
   //
   // Note that the design of the glitch free muxes requires that both clocks
   // must be running at the point of switching. This may not be suitable in
   // all systems, especially if a clock source is generated externally
   // (e.g. receive clock generated by the PHY)
   gem_glitch_mux i_gfm_tx (
   .n_reset (n_reset),
   .clock1  (gtx_ref_clk & ~gtx_clk_delete),
   .clock2  (tx_clk_mii_int),
   .select1 (gigabit_pclk | tbi_pclk),
   .clkout  (tx_clk_int)
   );


   // In loopback tx_clk domain is sourced from loop_clk_source
   `ifdef gem_int_loopback

   // Switching is glitch free and is logically equivalent to the following:
   //
   // assign tx_clk_int2 = (loopback_pclk) ? loop_clk_source : tx_clk_int;
   //
   // Note that the design of the glitch free muxes requires that both clocks
   // must be running at the point of switching. This may not be suitable in
   // all systems, especially if a clock source is generated externally
   // (e.g. receive clock generated by the PHY)
   gem_glitch_mux i_gfm_txloop (
   .n_reset (n_reset),
   .clock1  (loop_clk_source),
   .clock2  (tx_clk_int),
   .select1 (loopback_pclk),
   .clkout  (tx_clk_int2)
   );

   `else  // if not gem_int_loopback
   assign tx_clk_int2 = tx_clk_int;
   `endif // gem_int_loopback


   //---------------------------------------------------------------------------
   // receive clocks
   //---------------------------------------------------------------------------

   // rmii_rx_clk_int is used to select between rx_clk_from_phy and rmii_rx_clk,
   // Switching is glitch free and is logically equivalent to the following:
   //
   // assign rx_clk_mii_int = (mii_select) ? rx_clk_from_phy : rmii_rx_clk;
   //
   // Note that the design of the glitch free muxes requires that both clocks
   // must be running at the point of switching. This may not be suitable in
   // all systems, especially if a clock source is generated externally
   // (e.g. receive clock generated by the PHY)
   gem_glitch_mux i_gfm_rx_rmii (
   .n_reset (n_reset),
   .clock1  (rx_clk_from_phy),
   .clock2  (rmii_rx_clk),
   .select1 (mii_select),
   .clkout  (rx_clk_mii_int)
   );

   // rx_clk_int is sourced from either rbc1_int or rx_clk_mii_int,
   // depending on tbi
   // Switching is glitch free and is logically equivalent to the following:
   //
   // assign rx_clk_int = (tbi_pclk) ? rbc1_int : rx_clk_mii_int;
   //
   // Note that the design of the glitch free muxes requires that both clocks
   // must be running at the point of switching. This may not be suitable in
   // all systems, especially if a clock source is generated externally
   // (e.g. receive clock generated by the PHY)
   gem_glitch_mux i_gfm_rx (
   .n_reset (n_reset),
   .clock1  (rbc1_int & ~rbc1_delete),
   .clock2  (rx_clk_mii_int),
   .select1 (tbi_pclk),
   .clkout  (rx_clk_int)
   );


   // In loopback rx_clk domain is sourced from loop_clk_source
   `ifdef gem_int_loopback

   // Switching is glitch free and is logically equivalent to the following:
   //
   // assign rx_clk_int2 = (loopback_pclk) ? loop_clk_source : rx_clk_int;
   //
   // Note that the design of the glitch free muxes requires that both clocks
   // must be running at the point of switching. This may not be suitable in
   // all systems, especially if a clock source is generated externally
   // (e.g. receive clock generated by the PHY)
   gem_glitch_mux i_gfm_rxloop (
   .n_reset (n_reset),
   .clock1  (loop_clk_source),
   .clock2  (rx_clk_int),
   .select1 (loopback_pclk),
   .clkout  (rx_clk_int2)
   );

   `else  // if gem_not int_loopback
   assign rx_clk_int2 = rx_clk_int;
   `endif // gem_int_loopback


   // delay to simulate clock insertion delay. Helps make gate and
   // RTL simulations behave the same. Not actually needed.
   always @(rx_clk_int3)
      #0 rx_clk_to_gem = rx_clk_int3;

   // delay to simulate clock insertion delay.
   always @(tx_clk_int3)
      #0 tx_clk_to_gem = tx_clk_int3;


   assign pclk_to_gem = (scan_test_mode) ? scan_clk[7] : pclk_source;
   assign hclk_to_gem = (scan_test_mode) ? scan_clk[6] : hclk_source;

   //---------------------------------------------------------------------------
   // PCS transmit clock
   //---------------------------------------------------------------------------
   assign gtx_clk_to_gem = (scan_test_mode) ? scan_clk[5] : gtx_ref_clk;
   assign gtx20_clk_to_gem = (scan_test_mode) ? scan_clk[8] : gtx20_ref_clk;

   //---------------------------------------------------------------------------
   // PCS receive clocks
   //---------------------------------------------------------------------------
   assign rbc0_to_gem = (scan_test_mode) ? scan_clk[4] : rbc0_int;
   assign rbc1_to_gem = (scan_test_mode) ? scan_clk[3] : rbc1_int;

   assign pcs_rx_clk_to_gem = (scan_test_mode) ? scan_clk[9] :  pcs_rx_clk_from_phy;
   assign pcs_rx20_clk_to_gem = (scan_test_mode) ? scan_clk[10] :  pcs_rx20_clk_from_phy;

   //---------------------------------------------------------------------------
   // loopback clocks
   //---------------------------------------------------------------------------

   // Inverted tx_clk used for buffering TX signals to be fed into rx_clk domain
   assign n_tx_clk_to_gem = (scan_test_mode) ? scan_clk[2] : ~tx_clk_to_gem;
   assign n_rx_clk_to_gem = (scan_test_mode) ? scan_clk[2] : ~rx_clk_to_gem;

   assign rx_clk_int3 = (scan_test_mode) ? scan_clk[0] : rx_clk_int2;
   assign tx_clk_int3 = (scan_test_mode) ? scan_clk[1] : tx_clk_int2;



endmodule
