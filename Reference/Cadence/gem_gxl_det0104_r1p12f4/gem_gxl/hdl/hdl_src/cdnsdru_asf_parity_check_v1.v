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
//   Filename:           cdnsdru_asf_parity_check_v1.v
//   Module Name:        cdnsdru_asf_parity_check_v1
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
// Description    : ASF Parity Checker reuse component
//                  A Generic parity generation byte-wide even or odd parity.
//                  May be configured to support even or odd parity schemes.
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

module cdnsdru_asf_parity_check_v1 #(

  parameter p_data_width  = 32'd32,                     // Set the IP datapath width
  // internal parameters
  parameter p_num_par     = (p_data_width+32'd7)/32'd8, // number of parity bits
  parameter p_int_width   =  p_num_par*32'd8            // internal (padded) data width

) (

   input                                      odd_par,                // Parity scheme: 0 - Even parity
                                                                      //                1 - Odd parity
   input  [p_data_width-1:0]                  data_in,                // Input data for which parity will be checked against
   input  [p_num_par-1:0]                     parity_in,              // Input parity in line with data_in
   output                                     parity_err              // Parity error detected
);

// -----------------------------------------------------------------------------
//  wire and reg declarations
// -----------------------------------------------------------------------------

   wire   [p_num_par-1:0]                     comp_parity;            // Computed parity to be checked against incoming parity

// -----------------------------------------------------------------------------
//  Beginning of main code.
// -----------------------------------------------------------------------------


 cdnsdru_asf_parity_gen_v1 #( .p_data_width(p_data_width),
                              .p_num_par(p_num_par),
                              .p_int_width(p_int_width) )
  i_parity_gen(
   .odd_par (odd_par),
    .data_in (data_in),
    .data_out(),
    .parity_out(comp_parity)
    );

  // outputs
  assign parity_err   = |(comp_parity^parity_in);

endmodule
