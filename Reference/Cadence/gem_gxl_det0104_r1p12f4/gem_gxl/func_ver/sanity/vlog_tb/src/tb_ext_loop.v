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
//   Filename:           tb_ext_loop.v
//   Module Name:        tb_ext_loop
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
// Description: Implements external loop back for the MAC
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_ext_loop (
   reset_tb,
   tx_clk,
   loopback,
   tbi,
   rxd_int,
   rx_dv_int,
   rx_er_int,
   rx_group_int,
   txd,
   tx_en,
   tx_er,
   tx_group,
   rxd,
   rx_dv,
   rx_er,
   rx_group
);

// -----------------------------------------------------------------------------
// Define inputs and outputs
// -----------------------------------------------------------------------------
   input          reset_tb;            // testbench reset
   input          tx_clk;              // transmit clock from the PHY
   input          loopback;            // loopback signal to the PHY
   input          tbi;                 // PCS enable

   input    [7:0] rxd_int;             // receive data from the PHY
   input          rx_dv_int;           // receive data valid signal from the PHY
   input          rx_er_int;           // receive data error signal from the PHY

`ifdef gem_pcs_20b_if
   output  [19:0] rx_group;            // TBI receve data to DUT
   input   [19:0] tx_group;            // TBI transmitted data from DUT
   input   [19:0] rx_group_int;        // TBI receve data from PHY
`else
   output  [9:0] rx_group;             // TBI receve data to DUT
   input   [9:0] tx_group;             // TBI transmitted data from DUT
   input   [9:0] rx_group_int;         // TBI receve data from PHY
`endif

   input    [7:0] txd;                 // transmit data to the PHY
   input          tx_en;               // transmit enable signal to the PHY
   input          tx_er;               // transmit error  signal to the PHY

   output   [7:0] rxd;                 // receive data from the PHY
   output         rx_dv;               // receive data valid signal from the PHY
   output         rx_er;               // receive data error signal from the PHY


// -----------------------------------------------------------------------------
//  Signal declarations
// -----------------------------------------------------------------------------

  // define the number of elements in pipeline delay
  `define tb_gem_loopback_delay   200

  reg       [7:0] tx_data_delay[`tb_gem_loopback_delay-1:0];
                                       // delayed txd for loopback testing
  reg [`tb_gem_loopback_delay-1:0]
                  tx_en_delay;         // delayed tx_en for loopback testing
  reg [`tb_gem_loopback_delay-1:0]
                  tx_er_delay;         // delayed tx_er for loopback testing

  reg       [7:0] rxd_loop;            // delayed tx_data_delay
  reg             rx_dv_loop;          // delayed tx_en_delay
  reg             rx_er_loop;          // delayed tx_er_delay
  integer         i;                   // loop variable
  integer         j;                   // loop variable

`ifdef gem_pcs_20b_if
  reg       [19:0] tx_group_delay[`tb_gem_loopback_delay-1:0];
  reg       [19:0] rx_group_loop;            // delayed tx_data_delay
`else
  reg       [9:0]  tx_group_delay[`tb_gem_loopback_delay-1:0];
  reg       [9:0]  rx_group_loop;            // delayed tx_data_delay
`endif


// -----------------------------------------------------------------------------
//  display message when entering external loopback mode
// -----------------------------------------------------------------------------

  // report loopback state
  always @(loopback)
    if (loopback)
      $display(" Testbench configured for loopback operation, this is used in soak testing\n");
    else
      $display(" Testbench configured for non-loopback operation (ie normal operation)\n");



// -----------------------------------------------------------------------------
// delay pipeline `tb_gem_loopback_delay deep,
// equating to `tb_gem_loopback_delay tx_clk delay
// -----------------------------------------------------------------------------

  // Delay tx data for loopback.
  // output data to rxd from position pointed to by j
  // input data from txd to position pointed to by j-1
  always @( negedge (reset_tb) or posedge (tx_clk) )
  begin
    if (~reset_tb)
      begin
        for (i=0; i<`tb_gem_loopback_delay; i=i+1)
        begin
           tx_data_delay[i] <= 8'b0;
           tx_group_delay[i] <= 0;
        end
        tx_en_delay   <= 0;
        tx_er_delay   <= 0;
        j <= 0;
      end
    else
      begin
        if (j == 0)
           begin
              tx_data_delay[`tb_gem_loopback_delay-1] <= txd;
              tx_en_delay[`tb_gem_loopback_delay-1]   <= tx_en;
              tx_er_delay[`tb_gem_loopback_delay-1]   <= tx_er;
              tx_group_delay[`tb_gem_loopback_delay-1]<= tx_group;
              j <= j + 1;
           end
        else if (j == (`tb_gem_loopback_delay-1))
           begin
              tx_data_delay[j-1] <= txd;
              tx_en_delay[j-1]   <= tx_en;
              tx_er_delay[j-1]   <= tx_er;
              tx_group_delay[j-1]<= tx_group;
              j <= 0;
           end
        else
           begin
              tx_data_delay[j-1] <= txd;
              tx_en_delay[j-1]   <= tx_en;
              tx_er_delay[j-1]   <= tx_er;
              tx_group_delay[j-1]<= tx_group;
              j <= j+1;
           end
      end
  end

// -----------------------------------------------------------------------------
//  delay outputs to rx, to get them away from a clock edge
// -----------------------------------------------------------------------------

  // apply delays to loopback versions to ensure that RX inputs are away from
  // edge for gate level sims.
  always @(tx_data_delay[j])
  begin
     rxd_loop = #20 tx_data_delay[j];
  end

  // apply delays to loopback versions to ensure that RX inputs are away from
  // edge for gate level sims.
  always @(tx_en_delay[j])
  begin
     rx_dv_loop = #20 tx_en_delay[j];
  end

  // apply delays to loopback versions to ensure that RX inputs are away from
  // edge for gate level sims.
  always @(tx_er_delay[j])
  begin
     rx_er_loop = #20 tx_er_delay[j];
  end

  always @(tx_group_delay[j])
  begin
     rx_group_loop = #20 tx_group_delay[j];
  end

// -----------------------------------------------------------------------------
//  outputs to RX
// -----------------------------------------------------------------------------

  assign rxd        = ((loopback === 1'b1) ? rxd_loop        : rxd_int);
  assign rx_dv      = ((loopback === 1'b1) ? rx_dv_loop      : rx_dv_int);
  assign rx_er      = ((loopback === 1'b1) ? rx_er_loop      : rx_er_int);
  assign rx_group   = ((loopback === 1'b1) ? rx_group_loop   : rx_group_int);

endmodule

