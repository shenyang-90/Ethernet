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
//   Filename:           tb_rmii_phy.v
//   Module Name:        tb_rmii_phy
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
//   Description :             Reconciliation layer between MII and RMII
//                             interfaces. I mplements a RMII wrapper
//                             around the MAC's MII interface. Assumes
//                             a 50MHz ref_clk input from an external
//                             source.
//
//                             Designed in accordance with Reduced MII
//                             interface specification dated September 26,
//                             1997. See:-
//
//                             http://www.amd.com/products/npd/overview/1_0_3b.html
//
//          Limitations :      This module has been designed to interface to the
//                             Ethernet MAC testbench and may not be suitable
//                             for other use.  Collisions are generated on
//                             requests from the test bench by simply sending a
//                             valid pre-amble signal to the MAC RMII interface.
//                             If at that point transmission is still occuring,
//                             then a collision will result.
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_rmii_phy (
   // system signals
   reset_tb,
   ten_meg_bit,

   // MII signals
   col,
   crs,
   txd,
   tx_en,
   rxd,
   rx_dv,
   rx_er,

   // RMII signals
   txd_rmii,
   tx_en_rmii,
   ref_clk,
   rxd_rmii,
   rx_er_rmii,
   crs_dv);

   // system signals
   input         reset_tb;                // Amba reset (asynchronous)
   input         ten_meg_bit;             // indicates 10Mbit operation

   // MII signals
   input         col;                     // collision detect signal
   input         crs;                     // carrier sense signal
   output  [3:0] txd;                     // transmit data
   output        tx_en;                   // transmit enable signal
   input   [3:0] rxd;                     // receive data
   input         rx_dv;                   // receive data valid
   input         rx_er;                   // Receive error.


   // RMII signals
   input   [1:0] txd_rmii;                // transmit data to the PHY
   input         tx_en_rmii;              // transmit enable signal to the PHY
   input         ref_clk;                 // 50MHz reference clock input
   output  [1:0] rxd_rmii;                // receive data from the PHY
   output        rx_er_rmii;              // Receive error signal.
   output        crs_dv;                  // receive data valid and carrier sense signal from the PHY


   // declare reg's and wire's
   reg     [3:0] txd;                     // transmit data
   reg           tx_en;                   // transmit enable signal
   reg           rx_dv_rmii_int;          // receive data valid
   reg           rx_er_rmii_int;          // receive error.
   reg     [1:0] rxd_rmii_int;            // receive data from the PHY
   wire          crs_dv_int;              // receive data valid and carrier sense signal from the PHY
   reg           rx_er_rmii;              // receive error.
   reg     [1:0] rxd_rmii;                // receive data from the PHY
   reg           crs_dv;                  // receive data valid and carrier sense signal from the PHY

   reg     [1:0] txd_low;                 // Save value of txd_rmii
   reg           bit_count;               // Counters for rx and tx processes
   reg           rx_bit_count;
   reg     [3:0] rmii_sample_count;       // Counts when allowed to sample
                                          // data on RMII.
   reg     [3:0] rxd_sample;              // Sampled data.
   reg           rx_dv_sample;
   reg           transmit;                // Active while transmitting.

   wire          sample_time;             // Indicate when allowed to sample.

   parameter     RXDEL = 10;             // Delay after rising edge of ref_clk
                                          // before producing RX outputs(*100ps)


   // Generate the counter to control when to sample data on RMII.  This also
   // determines when data will be sampled from or driven onto the MII bus as this
   // will be at half the sample rate..
   // Only used for 10Mb operation as 100Mb will sample at ref_clk.
   // For 10Mb operation, RMII signals will be sampled every 10th clock..
   always@(posedge ref_clk or negedge reset_tb)
      if (~reset_tb)
         rmii_sample_count <= 4'b0;
      else
         if (rmii_sample_count == 4'b1001)
            rmii_sample_count <= 4'b0;
         else
            rmii_sample_count <= rmii_sample_count + 1'b1;


   // Sample pulse to indicate when it is time to sample the RMII signals..
   assign sample_time = (~ten_meg_bit | (ten_meg_bit & (rmii_sample_count == 4'b1001)));


   // Detect when the rmii tx_en signal becomes active to indicate valid
   // transmit data and save the status.
   // Necessary to keep transmit process going until last nibble transmitted
   // otherwise it may get shortened in 10Mb case..
   always@(posedge ref_clk or negedge reset_tb)
      if (~reset_tb)
         transmit <= 1'b0;
      // Only sample signals at sample time, depending on speed selection..
      else if (sample_time)
         if (tx_en_rmii)
            transmit <= 1'b1;
         else
            transmit <= 1'b0;
      else
         transmit <= transmit;


   // Sample rmii signals and save value.  Drive tx_en and txd onto testbench
   // for transmit simulation verification.
   always@(posedge ref_clk or negedge reset_tb)
      if (~reset_tb)
         begin
            txd_low <= 2'b0;
            bit_count <= 1'b0;
            txd <= 4'b0;
            tx_en <= 1'b0;
         end
      else if (sample_time)
         if ( tx_en_rmii | transmit )
            case (bit_count)
               1'b0:
                  begin
                     bit_count <= bit_count + 1'b1;
                     txd_low <= txd_rmii;
                     tx_en <= tx_en;
                     txd <= txd;
                  end
               1'b1:
                  begin
                     bit_count <= bit_count + 1'b1;
                     txd <= {txd_rmii, txd_low};
                     txd_low <= txd_low;
                     tx_en <= 1'b1;
                  end
            endcase
         else
            begin
               bit_count <= 1'b0;
               txd_low <= 2'b0;
               txd <= 4'b0;
               tx_en <= 1'b0;
            end
      else
         begin
            bit_count <= bit_count;
            txd_low <= txd_low;
            txd <= txd;
            tx_en <= tx_en;
         end


   // Generate the rx signals on the RMII interface.
   always@(posedge ref_clk or negedge reset_tb)
      if (~reset_tb)
         begin
            rx_dv_sample <= 1'b0;
            rxd_sample <= 4'b0;
            rx_bit_count <= 1'b0;
            rx_dv_rmii_int <= 1'b0;
            rxd_rmii_int <= 2'b0;
         end
      else if (sample_time)
         if (rx_dv | (rx_dv_sample & rx_bit_count))
            case (rx_bit_count)
               1'b0:
                  begin
                     rx_dv_rmii_int <= 1'b1;
                     rx_dv_sample <= rx_dv;
                     rxd_sample <= rxd;
                     rxd_rmii_int <= rxd[1:0];
                     rx_bit_count <= rx_bit_count + 1'b1;
                  end
               1'b1:
                  begin
                     rx_dv_rmii_int <= 1'b1;
                     rx_dv_sample <= rx_dv;
                     rxd_sample <= rxd_sample;
                     rxd_rmii_int <= rxd_sample[3:2];
                     rx_bit_count <= rx_bit_count + 1'b1;
                  end
            endcase
         else if (~rx_dv & col)     // Testbench forces a collision....
            begin
               rxd_rmii_int <= 2'b01;
               rx_dv_rmii_int <= 1'b1;
            end
         else
            begin
               rx_dv_rmii_int <= 1'b0;
               rx_dv_sample <= rx_dv;
               rxd_sample <= 4'b0;
               rxd_rmii_int <= 2'b0;
               rx_bit_count <= 1'b0;
            end
      else
         begin
            rx_dv_rmii_int <= rx_dv_rmii_int;
            rx_dv_sample <= rx_dv_sample;
            rxd_sample <= rxd_sample;
            rxd_rmii_int <= rxd_rmii_int;
            rx_bit_count <= rx_bit_count;
         end



   // Generate the rx_er_rmii_int signal on detection of rx_er from phy.
   // This signal should be synchronous to ref_clk.
   always@(posedge ref_clk or negedge reset_tb)
      if (~reset_tb)
         rx_er_rmii_int <= 1'b0;
      else
         rx_er_rmii_int <= rx_er;


   // Generate the crs_dv signal.  This is active whenever carrier activity is
   // detected or a frame is being received.
   // Note that due to the particular implememntation of this test bench, a
   // collision is generated by sending a pre-amble sequence on detection of the
   // collision signal.  If, on the other side (MAC-RMII) interface, tx is
   // occuring, then the collision will be generated.
   assign crs_dv_int = crs | (rx_dv_rmii_int & ~rx_bit_count);


   // Generate delayed output for rxd_rmii
   always @(rxd_rmii_int)
      rxd_rmii = #RXDEL rxd_rmii_int;

   // Generate delayed output for rx_er_rmii
   always @(rx_er_rmii_int)
      rx_er_rmii = #RXDEL rx_er_rmii_int;

   // Generate delayed output for crs_dv
   always @(crs_dv_int)
      crs_dv = #RXDEL crs_dv_int;


endmodule
