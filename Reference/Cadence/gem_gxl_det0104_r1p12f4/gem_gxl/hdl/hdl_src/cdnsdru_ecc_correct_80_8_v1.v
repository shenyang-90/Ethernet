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
//   Filename:           cdnsdru_ecc_correct_80_8_v1.v
//   Module Name:        cdnsdru_ecc_correct_80_8_v1
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
// Correct single errors in 80-bit data
//
//------------------------------------------------------------------------------

module cdnsdru_ecc_correct_80_8_v1 
  (
   data_in,
   parity_in,
   data_out,
   correctable_error_out,
   uncorrectable_error_out
   );

  input  [79:0] data_in;
  input   [7:0] parity_in;
  output [79:0] data_out;
  output        correctable_error_out;
  output        uncorrectable_error_out;

  wire          error_detected;
  wire    [7:0] check_parity;
  wire    [6:0] syndrome;

  wire          data_in_lower_xored;
  wire          data_in_upper_xored;

  // Generate check bits
  cdnsdru_ecc_parity_gen_80_8_v1  ecc_parity_check_gen_mod
  (
   .data_in   (data_in),
   .parity_out(check_parity)
   );

  // Calculate syndrome
   assign   syndrome[6:0]            = parity_in[6:0] ^ check_parity[6:0];
  
  assign   data_out[0]              = (syndrome == 7'd3)? ~data_in[0] : data_in[0];
  assign   data_out[1]              = (syndrome == 7'd5)? ~data_in[1] : data_in[1];
  assign   data_out[2]              = (syndrome == 7'd6)? ~data_in[2] : data_in[2];
  assign   data_out[3]              = (syndrome == 7'd7)? ~data_in[3] : data_in[3];
  assign   data_out[4]              = (syndrome == 7'd9)? ~data_in[4] : data_in[4];
  assign   data_out[5]              = (syndrome == 7'd10)? ~data_in[5] : data_in[5];
  assign   data_out[6]              = (syndrome == 7'd11)? ~data_in[6] : data_in[6];
  assign   data_out[7]              = (syndrome == 7'd12)? ~data_in[7] : data_in[7];
  assign   data_out[8]              = (syndrome == 7'd13)? ~data_in[8] : data_in[8];
  assign   data_out[9]              = (syndrome == 7'd14)? ~data_in[9] : data_in[9];

  assign   data_out[10]             = (syndrome == 7'd15)? ~data_in[10] : data_in[10];
  assign   data_out[11]             = (syndrome == 7'd17)? ~data_in[11] : data_in[11];
  assign   data_out[12]             = (syndrome == 7'd18)? ~data_in[12] : data_in[12];
  assign   data_out[13]             = (syndrome == 7'd19)? ~data_in[13] : data_in[13];
  assign   data_out[14]             = (syndrome == 7'd20)? ~data_in[14] : data_in[14];
  assign   data_out[15]             = (syndrome == 7'd21)? ~data_in[15] : data_in[15];
  assign   data_out[16]             = (syndrome == 7'd22)? ~data_in[16] : data_in[16];
  assign   data_out[17]             = (syndrome == 7'd23)? ~data_in[17] : data_in[17];
  assign   data_out[18]             = (syndrome == 7'd24)? ~data_in[18] : data_in[18];
  assign   data_out[19]             = (syndrome == 7'd25)? ~data_in[19] : data_in[19];

  assign   data_out[20]             = (syndrome == 7'd26)? ~data_in[20] : data_in[20];
  assign   data_out[21]             = (syndrome == 7'd27)? ~data_in[21] : data_in[21];
  assign   data_out[22]             = (syndrome == 7'd28)? ~data_in[22] : data_in[22];
  assign   data_out[23]             = (syndrome == 7'd29)? ~data_in[23] : data_in[23];
  assign   data_out[24]             = (syndrome == 7'd30)? ~data_in[24] : data_in[24];
  assign   data_out[25]             = (syndrome == 7'd31)? ~data_in[25] : data_in[25];
  assign   data_out[26]             = (syndrome == 7'd33)? ~data_in[26] : data_in[26];
  assign   data_out[27]             = (syndrome == 7'd34)? ~data_in[27] : data_in[27];
  assign   data_out[28]             = (syndrome == 7'd35)? ~data_in[28] : data_in[28];
  assign   data_out[29]             = (syndrome == 7'd36)? ~data_in[29] : data_in[29];

  assign   data_out[30]             = (syndrome == 7'd37)? ~data_in[30] : data_in[30];
  assign   data_out[31]             = (syndrome == 7'd38)? ~data_in[31] : data_in[31];
  assign   data_out[32]             = (syndrome == 7'd39)? ~data_in[32] : data_in[32];
  assign   data_out[33]             = (syndrome == 7'd40)? ~data_in[33] : data_in[33];
  assign   data_out[34]             = (syndrome == 7'd41)? ~data_in[34] : data_in[34];
  assign   data_out[35]             = (syndrome == 7'd42)? ~data_in[35] : data_in[35];
  assign   data_out[36]             = (syndrome == 7'd43)? ~data_in[36] : data_in[36];
  assign   data_out[37]             = (syndrome == 7'd44)? ~data_in[37] : data_in[37];
  assign   data_out[38]             = (syndrome == 7'd45)? ~data_in[38] : data_in[38];
  assign   data_out[39]             = (syndrome == 7'd46)? ~data_in[39] : data_in[39];

  assign   data_out[40]             = (syndrome == 7'd47)? ~data_in[40] : data_in[40];
  assign   data_out[41]             = (syndrome == 7'd48)? ~data_in[41] : data_in[41];
  assign   data_out[42]             = (syndrome == 7'd49)? ~data_in[42] : data_in[42];
  assign   data_out[43]             = (syndrome == 7'd50)? ~data_in[43] : data_in[43];
  assign   data_out[44]             = (syndrome == 7'd51)? ~data_in[44] : data_in[44];
  assign   data_out[45]             = (syndrome == 7'd52)? ~data_in[45] : data_in[45];
  assign   data_out[46]             = (syndrome == 7'd53)? ~data_in[46] : data_in[46];
  assign   data_out[47]             = (syndrome == 7'd54)? ~data_in[47] : data_in[47];
  assign   data_out[48]             = (syndrome == 7'd55)? ~data_in[48] : data_in[48];
  assign   data_out[49]             = (syndrome == 7'd56)? ~data_in[49] : data_in[49];

  assign   data_out[50]             = (syndrome == 7'd57)? ~data_in[50] : data_in[50];
  assign   data_out[51]             = (syndrome == 7'd58)? ~data_in[51] : data_in[51];
  assign   data_out[52]             = (syndrome == 7'd59)? ~data_in[52] : data_in[52];
  assign   data_out[53]             = (syndrome == 7'd60)? ~data_in[53] : data_in[53];
  assign   data_out[54]             = (syndrome == 7'd61)? ~data_in[54] : data_in[54];
  assign   data_out[55]             = (syndrome == 7'd62)? ~data_in[55] : data_in[55];
  assign   data_out[56]             = (syndrome == 7'd63)? ~data_in[56] : data_in[56];
  assign   data_out[57]             = (syndrome == 7'd65)? ~data_in[57] : data_in[57];
  assign   data_out[58]             = (syndrome == 7'd66)? ~data_in[58] : data_in[58];
  assign   data_out[59]             = (syndrome == 7'd67)? ~data_in[59] : data_in[59];

  assign   data_out[60]             = (syndrome == 7'd68)? ~data_in[60] : data_in[60];
  assign   data_out[61]             = (syndrome == 7'd69)? ~data_in[61] : data_in[61];
  assign   data_out[62]             = (syndrome == 7'd70)? ~data_in[62] : data_in[62];
  assign   data_out[63]             = (syndrome == 7'd71)? ~data_in[63] : data_in[63];
 
  assign   data_out[64]             = (syndrome == 7'd72)? ~data_in[64] : data_in[64];
  assign   data_out[65]             = (syndrome == 7'd73)? ~data_in[65] : data_in[65];
  assign   data_out[66]             = (syndrome == 7'd74)? ~data_in[66] : data_in[66];
  assign   data_out[67]             = (syndrome == 7'd75)? ~data_in[67] : data_in[67];
  assign   data_out[68]             = (syndrome == 7'd76)? ~data_in[68] : data_in[68];
  assign   data_out[69]             = (syndrome == 7'd77)? ~data_in[69] : data_in[69];

  assign   data_out[70]             = (syndrome == 7'd78)? ~data_in[70] : data_in[70];
  assign   data_out[71]             = (syndrome == 7'd79)? ~data_in[71] : data_in[71];
  assign   data_out[72]             = (syndrome == 7'd80)? ~data_in[72] : data_in[72];
  assign   data_out[73]             = (syndrome == 7'd81)? ~data_in[73] : data_in[73];
  assign   data_out[74]             = (syndrome == 7'd82)? ~data_in[74] : data_in[74];
  assign   data_out[75]             = (syndrome == 7'd83)? ~data_in[75] : data_in[75];
  assign   data_out[76]             = (syndrome == 7'd84)? ~data_in[76] : data_in[76];
  assign   data_out[77]             = (syndrome == 7'd85)? ~data_in[77] : data_in[77];
  assign   data_out[78]             = (syndrome == 7'd86)? ~data_in[78] : data_in[78];
  assign   data_out[79]             = (syndrome == 7'd87)? ~data_in[79] : data_in[79];


  assign    data_in_lower_xored = (^data_in[39:0]);
  assign    data_in_upper_xored = (^data_in[79:40]);   
  assign   error_detected           = data_in_lower_xored ^ data_in_upper_xored  ^ (^parity_in[7:0]);


  assign   uncorrectable_error_out  = (syndrome != 7'd0) & ~error_detected;
  assign   correctable_error_out    =  error_detected;
  
endmodule // cdnsdru_ecc_correct_80_8_v1

