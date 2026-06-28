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
//   Filename:           tb_rx_bit_slip.v
//   Module Name:        tb_rx_bit_slip
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
//   Description    : Bit slip module, taking 10-bit input and applying up to
//                    20-bit times of skew.
//
//------------------------------------------------------------------------------


module tb_rx_bit_slip (

  input             clk,
  input             reset_n,
  input       [4:0] slip_sel,
  input       [9:0] in_data,
  output  reg [9:0] out_data
);

  // Internal signals
  reg   [19:0]  dat_store;    // Store input data into an array.
  reg   [4:0]   slip_sel_int; // Ensure bit slip occurs synchronously
  reg   [4:0]   slip_sel_save;
  // Data is always written into top of array.
  // Note that since this is a testbench component, no specific clock domain
  // handling is required for slip_sel capture as the test environment will
  // always be modifying all bits simultaneously.
  always@(posedge clk or negedge reset_n)
  begin
    if (~reset_n)
    begin
      dat_store     <= {20{1'b0}};
      slip_sel_int  <= 5'd0;
      slip_sel_save <= 5'd0;
    end
    else
    begin
      slip_sel_save <= slip_sel;
      dat_store     <= {in_data,dat_store[19:10]};
      if (slip_sel != slip_sel_save)
      begin
        if (slip_sel <= 5'd20)
          slip_sel_int  <= slip_sel;
        else
          slip_sel_int  <= $urandom_range(20,0);
      end
    end
  end


  // The output data is taken based on slip_sel
  always@(*)
  begin
    case (slip_sel_int)
      5'd1:   out_data  <= {in_data[8:0],dat_store[19]};
      5'd2:   out_data  <= {in_data[7:0],dat_store[19:18]};
      5'd3:   out_data  <= {in_data[6:0],dat_store[19:17]};
      5'd4:   out_data  <= {in_data[5:0],dat_store[19:16]};
      5'd5:   out_data  <= {in_data[4:0],dat_store[19:15]};
      5'd6:   out_data  <= {in_data[3:0],dat_store[19:14]};
      5'd7:   out_data  <= {in_data[2:0],dat_store[19:13]};
      5'd8:   out_data  <= {in_data[1:0],dat_store[19:12]};
      5'd9:   out_data  <= {in_data[0],dat_store[19:11]};
      5'd10:  out_data  <= dat_store[19:10];
      5'd11:  out_data  <= dat_store[18:9];
      5'd12:  out_data  <= dat_store[17:8];
      5'd13:  out_data  <= dat_store[16:7];
      5'd14:  out_data  <= dat_store[15:6];
      5'd15:  out_data  <= dat_store[14:5];
      5'd16:  out_data  <= dat_store[13:4];
      5'd17:  out_data  <= dat_store[12:3];
      5'd18:  out_data  <= dat_store[11:2];
      5'd19:  out_data  <= dat_store[10:1];
      5'd20:  out_data  <= dat_store[9:0];
      default:  out_data  <= in_data;
    endcase
  end

endmodule
