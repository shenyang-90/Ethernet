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
//   Filename:           cdnsdru_ecc_correct_wrap_v1.v
//   Module Name:        cdnsdru_ecc_correct_wrap_v1
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
//   Description    : Wrapper for instantiating ECC correction modules.
//                    Provides a generic correction module that can deal
//                    with any number of data input bits with corresponding
//                    parity.
//                    Expected to be used with its partner ecc_parity_gen_wrap 
//                    module for creating the parity bits.
//                    The data bits will be split across multiple instances of
//                    80_8 ECC correction modules if necessary.
//                    If the number of data bits for each 80_8 module is less 
//                    than 58-bits then the 2nd top parity bit of each module is
//                    not used and tied to 0.
//
//------------------------------------------------------------------------------
//   Revision Control
//
//   see cvs log
//------------------------------------------------------------------------------

module cdnsdru_ecc_correct_wrap_v1 #(
  parameter p_num_bits      = 32'd64,
  parameter p_num_inst      = (p_num_bits+32'd79)/32'd80,
  parameter p_num_bits_each = ( (p_num_bits + (p_num_inst-32'd1)) / p_num_inst),
  parameter p_num_bits_last = p_num_bits - ((p_num_inst-32'd1) * p_num_bits_each),
  parameter p_num_par_each  = (p_num_bits_each < 32'd58)  ? 32'd7 : 32'd8,
  parameter p_num_par_last  = (p_num_bits_last < 32'd58)  ? 32'd7 : 32'd8,
  parameter p_num_par       = p_num_par_last + ((p_num_inst-32'd1)*p_num_par_each)
)(

  input       [p_num_bits-1:0]  data_in,    // Input bits that are protected by parity_in
  input       [p_num_par-1:0]   parity_in,  // ECC parity for protected data_in
  output      [p_num_bits-1:0]  data_out,   // Corrected data out
  output                        correctable_error_out,
  output                        uncorrectable_error_out

);
  
  wire  [p_num_inst-1:0]  corr_err_int;     // Correctable error indicator for each module
  wire  [p_num_inst-1:0]  uncorr_err_int;   // Uncorrectable error indicator for each module
  
  // Instantiate the ecc_correct_80_8 block multiple times and evenly split
  // the data_in across all the modules.
  generate
    genvar  loop_i;
    for (loop_i = 0; loop_i < p_num_inst; loop_i = loop_i + 1)
    begin : gen_inst
      wire  [80:0]  data_in_int;    // This needs to be 81-bits to handle case where data is 80-bits to fix lint
      wire  [79:0]  data_out_int;
      wire  [7:0]   parity_in_int;
      
      if (loop_i == (p_num_inst - 1)) begin : gen_last
        assign data_in_int  = {{(81-p_num_bits_last){1'b0}},
                                data_in[(loop_i*p_num_bits_each)+p_num_bits_last-1:(loop_i*p_num_bits_each)]};

        if (p_num_par_last == 32'd7)  begin : gen_par_7
          assign parity_in_int = {parity_in[p_num_par-1],1'b0,parity_in[p_num_par-2:p_num_par-7]};
        end else begin : gen_par_8
          assign parity_in_int = parity_in[p_num_par-1:p_num_par-8];
        end // gen_oar_8
        assign data_out[p_num_bits-1:p_num_bits-p_num_bits_last]  = data_out_int[p_num_bits_last-1:0];
      end
      else begin : gen_each
        assign data_in_int  = {{(81-p_num_bits_each){1'b0}},
                                data_in[(loop_i*p_num_bits_each)+p_num_bits_each-1:(loop_i*p_num_bits_each)]};

        if (p_num_par_each == 32'd7)  begin : gen_par_7
          assign parity_in_int = {parity_in[(loop_i*7)+6],1'b0,parity_in[(loop_i*7)+5:(loop_i*7)]};
        end else begin : gen_par_8
          assign parity_in_int = parity_in[(loop_i*8)+7:(loop_i*8)];
        end // gen_oar_8
        assign data_out[(loop_i*p_num_bits_each)+p_num_bits_each-1:(loop_i*p_num_bits_each)]  = data_out_int[p_num_bits_each-1:0];
      end
      
      // Pad data going into ECC generator block
      cdnsdru_ecc_correct_80_8_v1 i_ecc_corr (
        .data_in    (data_in_int[79:0]),
        .parity_in  (parity_in_int),
        .data_out   (data_out_int),
        .correctable_error_out  (corr_err_int[loop_i]),
        .uncorrectable_error_out(uncorr_err_int[loop_i])
      );
    end
  endgenerate
  
  // Signal uncorrectable error if any of the modules detected uncorrectable
  assign uncorrectable_error_out  = |uncorr_err_int;
  
  // Signal correctable error if any of the modules detected correctable AND uncorrectable is not being signalled on any modules.
  assign correctable_error_out    = (|corr_err_int) & ~(|uncorr_err_int);
  
  
endmodule
