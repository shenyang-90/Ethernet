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
//   Filename:           cdnsdru_ecc_parity_gen_80_8_v1.v
//   Module Name:        cdnsdru_ecc_parity_gen_80_8_v1
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
// Description    :
//
// Hamming Code Generator for 80-bit data
//
//------------------------------------------------------------------------------

module cdnsdru_ecc_parity_gen_80_8_v1 
  (
   data_in,
   parity_out
   );

  input [79:0] data_in;
  output [7:0] parity_out;


  wire  [87:1] data_word;
  wire   [7:0] parity_word;

  wire         data_in_lower_xored;
  wire         data_in_upper_xored;

  assign       parity_out = parity_word;

  assign       data_word[1] = 1'b0;
  assign       data_word[2] = 1'b0;
  assign       data_word[3] = data_in[0];
  assign       data_word[4] = 1'b0;
  assign       data_word[7:5] = data_in[3:1];
  assign       data_word[8] = 1'b0;
  assign       data_word[15:9] = data_in[10:4];
  assign       data_word[16] = 1'b0;
  assign       data_word[31:17] = data_in[25:11];
  assign       data_word[32] = 1'b0;
  assign       data_word[63:33] = data_in[56:26];
  assign       data_word[64] = 1'b0;
  assign       data_word[71:65] = data_in[63:57];
 
  assign       data_word[87:72] = data_in[79:64];

  assign       parity_word[0] = data_word[1] ^ data_word[3] ^ data_word[5] ^ data_word[7] ^ data_word[9]
       ^ data_word[11] ^ data_word[13] ^ data_word[15] ^ data_word[17] ^ data_word[19]
       ^ data_word[21] ^ data_word[23] ^ data_word[25] ^ data_word[27] ^ data_word[29]
       ^ data_word[31] ^ data_word[33] ^ data_word[35] ^ data_word[37] ^ data_word[39]
       ^ data_word[41] ^ data_word[43] ^ data_word[45] ^ data_word[47] ^ data_word[49]
       ^ data_word[51] ^ data_word[53] ^ data_word[55] ^ data_word[57] ^ data_word[59]
       ^ data_word[61] ^ data_word[63] ^ data_word[65] ^ data_word[67] ^ data_word[69]
       ^ data_word[71] ^ data_word[73] ^ data_word[75] ^ data_word[77] ^ data_word[79]
       ^ data_word[81] ^ data_word[83] ^ data_word[85] ^ data_word[87];

  assign       parity_word[1] = data_word[2] ^ data_word[3] ^ data_word[6] ^ data_word[7]
       ^ data_word[10] ^ data_word[11] ^ data_word[14] ^ data_word[15]
       ^ data_word[18] ^ data_word[19] ^ data_word[22] ^ data_word[23]
       ^ data_word[26] ^ data_word[27] ^ data_word[30] ^ data_word[31]
       ^ data_word[34] ^ data_word[35] ^ data_word[38] ^ data_word[39]
       ^ data_word[42] ^ data_word[43] ^ data_word[46] ^ data_word[47]
       ^ data_word[50] ^ data_word[51] ^ data_word[54] ^ data_word[55]
       ^ data_word[58] ^ data_word[59] ^ data_word[62] ^ data_word[63]
       ^ data_word[66] ^ data_word[67] ^ data_word[70] ^ data_word[71]
       ^ data_word[74] ^ data_word[75] ^ data_word[78] ^ data_word[79]
       ^ data_word[82] ^ data_word[83] ^ data_word[86] ^ data_word[87];

  assign       parity_word[2] = data_word[4] ^ data_word[5] ^ data_word[6] ^ data_word[7]
       ^ data_word[12] ^ data_word[13] ^ data_word[14] ^ data_word[15]
       ^ data_word[20] ^ data_word[21] ^ data_word[22] ^ data_word[23]
       ^ data_word[28] ^ data_word[29] ^ data_word[30] ^ data_word[31]
       ^ data_word[36] ^ data_word[37] ^ data_word[38] ^ data_word[39]
       ^ data_word[44] ^ data_word[45] ^ data_word[46] ^ data_word[47]
       ^ data_word[52] ^ data_word[53] ^ data_word[54] ^ data_word[55]
       ^ data_word[60] ^ data_word[61] ^ data_word[62] ^ data_word[63]
       ^ data_word[68] ^ data_word[69] ^ data_word[70] ^ data_word[71]
       ^ data_word[76] ^ data_word[77] ^ data_word[78] ^ data_word[79]
       ^ data_word[84] ^ data_word[85] ^ data_word[86] ^ data_word[87];

  assign       parity_word[3] = data_word[8] ^ data_word[9] ^ data_word[10] ^ data_word[11]
       ^ data_word[12] ^ data_word[13] ^ data_word[14] ^ data_word[15]
       ^ data_word[24] ^ data_word[25] ^ data_word[26] ^ data_word[27]
       ^ data_word[28] ^ data_word[29] ^ data_word[30] ^ data_word[31]
       ^ data_word[40] ^ data_word[41] ^ data_word[42] ^ data_word[43]
       ^ data_word[44] ^ data_word[45] ^ data_word[46] ^ data_word[47]
       ^ data_word[56] ^ data_word[57] ^ data_word[58] ^ data_word[59]
       ^ data_word[60] ^ data_word[61] ^ data_word[62] ^ data_word[63]
       ^ data_word[72] ^ data_word[73] ^ data_word[74] ^ data_word[75]
       ^ data_word[76] ^ data_word[77] ^ data_word[78] ^ data_word[79];

  assign       parity_word[4] = data_word[16] ^ data_word[17] ^ data_word[18] ^ data_word[19]
       ^ data_word[20] ^ data_word[21] ^ data_word[22] ^ data_word[23]
       ^ data_word[24] ^ data_word[25] ^ data_word[26] ^ data_word[27]
       ^ data_word[28] ^ data_word[29] ^ data_word[30] ^ data_word[31]
       ^ data_word[48] ^ data_word[49] ^ data_word[50] ^ data_word[51]
       ^ data_word[52] ^ data_word[53] ^ data_word[54] ^ data_word[55]
       ^ data_word[56] ^ data_word[57] ^ data_word[58] ^ data_word[59]
       ^ data_word[60] ^ data_word[61] ^ data_word[62] ^ data_word[63]
               ^ data_word[80] ^ data_word[81] ^ data_word[82] ^ data_word[83]
               ^ data_word[84] ^ data_word[85] ^ data_word[86] ^ data_word[87];

  assign       parity_word[5] = data_word[32] ^ data_word[33] ^ data_word[34] ^ data_word[35]
       ^ data_word[36] ^ data_word[37] ^ data_word[38] ^ data_word[39]
       ^ data_word[40] ^ data_word[41] ^ data_word[42] ^ data_word[43]
       ^ data_word[44] ^ data_word[45] ^ data_word[46] ^ data_word[47]
       ^ data_word[48] ^ data_word[49] ^ data_word[50] ^ data_word[51]
       ^ data_word[52] ^ data_word[53] ^ data_word[54] ^ data_word[55]
       ^ data_word[56] ^ data_word[57] ^ data_word[58] ^ data_word[59]
       ^ data_word[60] ^ data_word[61] ^ data_word[62] ^ data_word[63];

  assign       parity_word[6] = data_word[64] ^ data_word[65] ^ data_word[66] ^ data_word[67]

       ^ data_word[68] ^ data_word[69] ^ data_word[70] ^ data_word[71] ^
       ^ data_word[72] ^ data_word[73] ^ data_word[74] ^ data_word[75]
       ^ data_word[76] ^ data_word[77] ^ data_word[78] ^ data_word[79]
               ^ data_word[80] ^ data_word[81] ^ data_word[82] ^ data_word[83]
               ^ data_word[84] ^ data_word[85] ^ data_word[86] ^ data_word[87];

  assign       data_in_lower_xored = (^data_in[39:0]);
  assign       data_in_upper_xored = (^data_in[79:40]);
  assign       parity_word[7] = data_in_lower_xored ^ data_in_upper_xored ^ (^parity_word[6:0]);

endmodule // cdnsdru_ecc_parity_gen_80_8_v1

