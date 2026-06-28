//------------------------------------------------------------------------------
// Copyright (c) 2015-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_20_10_grbx.v
//   Module Name:        tb_20_10_grbx
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
//   Description    : 20-bit in, 10-bit out gearbox with 1:2 clock ratio.
//
//------------------------------------------------------------------------------


module tb_20_10_grbx (

  input               in_clk,       // Input clock
  input               in_rst_n,     // Reset
  input               out_clk,      // Output clock
  input               out_rst_n,    // Reset
  input       [19:0]  in_data,      // Input data
  output  reg [9:0]   out_data      // Output data

);

  // in_clk is assumed to be aligned with out_clk so we don't actually need
  // to use in_clk to save testbench latency...

  reg   [19:0]  in_smpl;    // Sample input
  reg           smp_tog;    // Toggle to sample data

  always@(posedge out_clk or negedge out_rst_n)
  begin
    if (~out_rst_n)
    begin
      in_smpl <= {2{10'h057}};
      smp_tog <= 1'b0;
    end
    else
    begin
      smp_tog <= ~smp_tog;
      if (smp_tog)
        in_smpl <= in_data;
    end
  end

  always@(*)
  begin
    if (smp_tog)
      out_data  = in_smpl[19:10];
    else
      out_data  = in_smpl[9:0];
  end




endmodule
