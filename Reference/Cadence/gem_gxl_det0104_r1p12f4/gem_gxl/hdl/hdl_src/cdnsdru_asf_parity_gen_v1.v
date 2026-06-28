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
//   Filename:           cdnsdru_asf_parity_gen_v1.v
//   Module Name:        cdnsdru_asf_parity_gen_v1
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
// Description    : ASF Parity Generator reuse component
//                  A Generic parity generation byte-wide even or odd parity.
//                  May be configured to support even or odd parity schemes.
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

module cdnsdru_asf_parity_gen_v1 #(

  parameter p_data_width  = 32'd32,                     // Set the IP datapath width
  // internal parameters
  parameter p_num_par     = (p_data_width+32'd7)/32'd8, // number of parity bits
  parameter p_int_width   =  p_num_par*32'd8            // internal (padded) data width

) (

   input                                      odd_par,                // Parity scheme: 0 - Even parity
                                                                      //                1 - Odd parity
   input  [p_data_width-1:0]                  data_in,                // Input data for which parity will be generated
   output [p_data_width-1:0]                  data_out,               // Output data, this is identical to data_in and is just a pass-through
   output [p_num_par-1:0]                     parity_out              // Generated parity in line with data_out
);

// -----------------------------------------------------------------------------
//  wire and reg declarations
// -----------------------------------------------------------------------------

   wire   [p_int_width-1:0]                   data_padded;            // Internal data padded to bytes wide

   wire   [p_num_par-1:0]                     parity_even;            // Generated even parity
   wire   [p_num_par-1:0]                     parity_odd;             // Generated odd parity

// -----------------------------------------------------------------------------
//  Beginning of main code.
// -----------------------------------------------------------------------------

  // Data bytes wide padded 
  // Even parity: Pad data with zeros
  // Odd parity: Pad data with ones
  // if data width is multiply of 8 (byte) then no padding
  generate if( p_data_width < p_int_width) begin : gen_data_padding
    assign data_padded = {{(p_int_width-p_data_width){(odd_par == 1'b1)? 1'b1 : 1'b0}},data_in};
  end else begin : gen_data_no_padding
    assign data_padded = data_in;
  end
  endgenerate

  genvar  n;
  generate
    for (n=0; n < p_num_par ; n=n+1)
    begin : gen_par_gen
      assign parity_even[n] =  (^data_padded[n*8+7:n*8]);
    end // gen_byte_wide_par_gen
  endgenerate

  assign parity_odd = ~parity_even;

  // outputs
  assign parity_out = (odd_par == 1)? parity_odd : parity_even;
  assign data_out   = data_in;

endmodule
