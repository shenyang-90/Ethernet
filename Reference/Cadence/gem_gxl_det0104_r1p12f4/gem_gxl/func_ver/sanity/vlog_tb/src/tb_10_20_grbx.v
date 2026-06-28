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
//   Filename:           tb_10_20_grbx.v
//   Module Name:        tb_10_20_grbx
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
//   Description    : 10-bit in, 20-bit out gearbox with 2:1 clock ratio.
//
//------------------------------------------------------------------------------


module tb_10_20_grbx (

  input               in_clk,       // Input clock
  input               in_rst_n,     // Reset
  input               out_clk,      // Output clock
  input               out_rst_n,    // Reset
  input       [9:0]   in_data,      // Input data
  output  reg [19:0]  out_data      // Output data
);

  reg           tog;        // Toggle for storing
  reg   [9:0]   in_save;    // Store previous cycle.

  always@(posedge in_clk or negedge in_rst_n)
  begin
    if (~in_rst_n)
    begin
      in_save <= 10'h000;
      tog     <= 1'b0;
    end
    else
    begin
      tog <= ~tog;
      if (~tog)
        in_save <= in_data;
    end
  end

  // Output data at half frequency, always take last save cycle and current.
  always@(posedge out_clk or negedge out_rst_n)
  begin
    if (~out_rst_n)
      out_data  <= 20'h00000;
    else
      out_data  <= {in_data,in_save};
  end




endmodule
