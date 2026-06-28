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
//   Filename:           tb_8b10b_enc.v
//   Module Name:        tb_8b10b_enc
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
//   Description    :   Simple 8B10B encoder for GEM testbench
//
//------------------------------------------------------------------------------


module tb_8b10b_enc (
   control,
   octet_value_in,
   running_disparity,
   encoded_value
   );


// *****************************************************************************
// Declare inputs and outputs
// *****************************************************************************
   input          control;             // select special or data group encoding
   input    [7:0] octet_value_in;      // 8 bit value to be encoded
   input          running_disparity;   // current disparity
   output   [9:0] encoded_value;       // 10bit encoded data output


// *****************************************************************************
// Declare internal signals
// *****************************************************************************
   reg      [9:0] encoded_value;       //  10bit encoded data output
   reg      [7:0] octet_value;         // buffered input 8-bit value


// *****************************************************************************
// Beginning of code
// *****************************************************************************

// buffer input value to prevent problems at startup
// ------------------------------------------
initial octet_value = 8'h00;

always @(octet_value_in)
   octet_value = octet_value_in;
// ------------------------------------------


// encode 8 bit value into 10 bit value
// ------------------------------------------
always @(control or running_disparity or octet_value)
begin
   if (control & running_disparity) // control & positive input disparity
   begin
      case (octet_value)
      8'h1c : encoded_value = 10'b1100001011; // 30b
      8'h3c : encoded_value = 10'b1100000110; // 306
      8'h5c : encoded_value = 10'b1100001010; // 30a
      8'h7c : encoded_value = 10'b1100001100; // 30c
      8'h9c : encoded_value = 10'b1100001101; // 30d
      8'hbc : encoded_value = 10'b1100000101; // 305
      8'hdc : encoded_value = 10'b1100001001; // 309
      8'hfc : encoded_value = 10'b1100000111; // 307
      8'hf7 : encoded_value = 10'b0001010111; // 057
      8'hfb : encoded_value = 10'b0010010111; // 097
      8'hfd : encoded_value = 10'b0100010111; // 117
      8'hfe : encoded_value = 10'b1000010111; // 217
      default : $display ("**** Error: Illegal special octet value: %h \n\n", octet_value);
      endcase
   end // control & positive input disparity


   else if (control & ~running_disparity) // control & negative input disparity
   begin
      case (octet_value)
      8'h1c : encoded_value = 10'b0011110100; // 0f4
      8'h3c : encoded_value = 10'b0011111001; // 0f9
      8'h5c : encoded_value = 10'b0011110101; // 0f5
      8'h7c : encoded_value = 10'b0011110011; // 0f3
      8'h9c : encoded_value = 10'b0011110010; // 0f2
      8'hbc : encoded_value = 10'b0011111010; // 0fa
      8'hdc : encoded_value = 10'b0011110110; // 0f6
      8'hfc : encoded_value = 10'b0011111000; // 0f8
      8'hf7 : encoded_value = 10'b1110101000; // 3a8
      8'hfb : encoded_value = 10'b1101101000; // 368
      8'hfd : encoded_value = 10'b1011101000; // 2e8
      8'hfe : encoded_value = 10'b0111101000; // 1e8
      default : $display ("**** Error: Illegal special octet value: %h \n\n", octet_value);
      endcase
   end // control & negative input disparity


   else if (~control & running_disparity) // data & positive input disparity
   begin
      case (octet_value)
      8'h0 :  encoded_value = 10'h18b;
      8'h1 :  encoded_value = 10'h22b;
      8'h2 :  encoded_value = 10'h12b;
      8'h3 :  encoded_value = 10'h314;
      8'h4 :  encoded_value = 10'hab;
      8'h5 :  encoded_value = 10'h294;
      8'h6 :  encoded_value = 10'h194;
      8'h7 :  encoded_value = 10'h74;
      8'h8 :  encoded_value = 10'h6b;
      8'h9 :  encoded_value = 10'h254;
      8'ha :  encoded_value = 10'h154;
      8'hb :  encoded_value = 10'h344;
      8'hc :  encoded_value = 10'hd4;
      8'hd :  encoded_value = 10'h2c4;
      8'he :  encoded_value = 10'h1c4;
      8'hf :  encoded_value = 10'h28b;
      8'h10 : encoded_value = 10'h24b;
      8'h11 : encoded_value = 10'h234;
      8'h12 : encoded_value = 10'h134;
      8'h13 : encoded_value = 10'h324;
      8'h14 : encoded_value = 10'hb4;
      8'h15 : encoded_value = 10'h2a4;
      8'h16 : encoded_value = 10'h1a4;
      8'h17 : encoded_value = 10'h5b;
      8'h18 : encoded_value = 10'hcb;
      8'h19 : encoded_value = 10'h264;
      8'h1a : encoded_value = 10'h164;
      8'h1b : encoded_value = 10'h9b;
      8'h1c : encoded_value = 10'he4;
      8'h1d : encoded_value = 10'h11b;
      8'h1e : encoded_value = 10'h21b;
      8'h1f : encoded_value = 10'h14b;
      8'h20 : encoded_value = 10'h189;
      8'h21 : encoded_value = 10'h229;
      8'h22 : encoded_value = 10'h129;
      8'h23 : encoded_value = 10'h319;
      8'h24 : encoded_value = 10'ha9;
      8'h25 : encoded_value = 10'h299;
      8'h26 : encoded_value = 10'h199;
      8'h27 : encoded_value = 10'h79;
      8'h28 : encoded_value = 10'h69;
      8'h29 : encoded_value = 10'h259;
      8'h2a : encoded_value = 10'h159;
      8'h2b : encoded_value = 10'h349;
      8'h2c : encoded_value = 10'hd9;
      8'h2d : encoded_value = 10'h2c9;
      8'h2e : encoded_value = 10'h1c9;
      8'h2f : encoded_value = 10'h289;
      8'h30 : encoded_value = 10'h249;
      8'h31 : encoded_value = 10'h239;
      8'h32 : encoded_value = 10'h139;
      8'h33 : encoded_value = 10'h329;
      8'h34 : encoded_value = 10'hb9;
      8'h35 : encoded_value = 10'h2a9;
      8'h36 : encoded_value = 10'h1a9;
      8'h37 : encoded_value = 10'h59;
      8'h38 : encoded_value = 10'hc9;
      8'h39 : encoded_value = 10'h269;
      8'h3a : encoded_value = 10'h169;
      8'h3b : encoded_value = 10'h99;
      8'h3c : encoded_value = 10'he9;
      8'h3d : encoded_value = 10'h119;
      8'h3e : encoded_value = 10'h219;
      8'h3f : encoded_value = 10'h149;
      8'h40 : encoded_value = 10'h185;
      8'h41 : encoded_value = 10'h225;
      8'h42 : encoded_value = 10'h125;
      8'h43 : encoded_value = 10'h315;
      8'h44 : encoded_value = 10'ha5;
      8'h45 : encoded_value = 10'h295;
      8'h46 : encoded_value = 10'h195;
      8'h47 : encoded_value = 10'h75;
      8'h48 : encoded_value = 10'h65;
      8'h49 : encoded_value = 10'h255;
      8'h4a : encoded_value = 10'h155;
      8'h4b : encoded_value = 10'h345;
      8'h4c : encoded_value = 10'hd5;
      8'h4d : encoded_value = 10'h2c5;
      8'h4e : encoded_value = 10'h1c5;
      8'h4f : encoded_value = 10'h285;
      8'h50 : encoded_value = 10'h245;
      8'h51 : encoded_value = 10'h235;
      8'h52 : encoded_value = 10'h135;
      8'h53 : encoded_value = 10'h325;
      8'h54 : encoded_value = 10'hb5;
      8'h55 : encoded_value = 10'h2a5;
      8'h56 : encoded_value = 10'h1a5;
      8'h57 : encoded_value = 10'h55;
      8'h58 : encoded_value = 10'hc5;
      8'h59 : encoded_value = 10'h265;
      8'h5a : encoded_value = 10'h165;
      8'h5b : encoded_value = 10'h95;
      8'h5c : encoded_value = 10'he5;
      8'h5d : encoded_value = 10'h115;
      8'h5e : encoded_value = 10'h215;
      8'h5f : encoded_value = 10'h145;
      8'h60 : encoded_value = 10'h18c;
      8'h61 : encoded_value = 10'h22c;
      8'h62 : encoded_value = 10'h12c;
      8'h63 : encoded_value = 10'h313;
      8'h64 : encoded_value = 10'hac;
      8'h65 : encoded_value = 10'h293;
      8'h66 : encoded_value = 10'h193;
      8'h67 : encoded_value = 10'h73;
      8'h68 : encoded_value = 10'h6c;
      8'h69 : encoded_value = 10'h253;
      8'h6a : encoded_value = 10'h153;
      8'h6b : encoded_value = 10'h343;
      8'h6c : encoded_value = 10'hd3;
      8'h6d : encoded_value = 10'h2c3;
      8'h6e : encoded_value = 10'h1c3;
      8'h6f : encoded_value = 10'h28c;
      8'h70 : encoded_value = 10'h24c;
      8'h71 : encoded_value = 10'h233;
      8'h72 : encoded_value = 10'h133;
      8'h73 : encoded_value = 10'h323;
      8'h74 : encoded_value = 10'hb3;
      8'h75 : encoded_value = 10'h2a3;
      8'h76 : encoded_value = 10'h1a3;
      8'h77 : encoded_value = 10'h5c;
      8'h78 : encoded_value = 10'hcc;
      8'h79 : encoded_value = 10'h263;
      8'h7a : encoded_value = 10'h163;
      8'h7b : encoded_value = 10'h9c;
      8'h7c : encoded_value = 10'he3;
      8'h7d : encoded_value = 10'h11c;
      8'h7e : encoded_value = 10'h21c;
      8'h7f : encoded_value = 10'h14c;
      8'h80 : encoded_value = 10'h18d;
      8'h81 : encoded_value = 10'h22d;
      8'h82 : encoded_value = 10'h12d;
      8'h83 : encoded_value = 10'h312;
      8'h84 : encoded_value = 10'had;
      8'h85 : encoded_value = 10'h292;
      8'h86 : encoded_value = 10'h192;
      8'h87 : encoded_value = 10'h72;
      8'h88 : encoded_value = 10'h6d;
      8'h89 : encoded_value = 10'h252;
      8'h8a : encoded_value = 10'h152;
      8'h8b : encoded_value = 10'h342;
      8'h8c : encoded_value = 10'hd2;
      8'h8d : encoded_value = 10'h2c2;
      8'h8e : encoded_value = 10'h1c2;
      8'h8f : encoded_value = 10'h28d;
      8'h90 : encoded_value = 10'h24d;
      8'h91 : encoded_value = 10'h232;
      8'h92 : encoded_value = 10'h132;
      8'h93 : encoded_value = 10'h322;
      8'h94 : encoded_value = 10'hb2;
      8'h95 : encoded_value = 10'h2a2;
      8'h96 : encoded_value = 10'h1a2;
      8'h97 : encoded_value = 10'h5d;
      8'h98 : encoded_value = 10'hcd;
      8'h99 : encoded_value = 10'h262;
      8'h9a : encoded_value = 10'h162;
      8'h9b : encoded_value = 10'h9d;
      8'h9c : encoded_value = 10'he2;
      8'h9d : encoded_value = 10'h11d;
      8'h9e : encoded_value = 10'h21d;
      8'h9f : encoded_value = 10'h14d;
      8'ha0 : encoded_value = 10'h18a;
      8'ha1 : encoded_value = 10'h22a;
      8'ha2 : encoded_value = 10'h12a;
      8'ha3 : encoded_value = 10'h31a;
      8'ha4 : encoded_value = 10'haa;
      8'ha5 : encoded_value = 10'h29a;
      8'ha6 : encoded_value = 10'h19a;
      8'ha7 : encoded_value = 10'h7a;
      8'ha8 : encoded_value = 10'h6a;
      8'ha9 : encoded_value = 10'h25a;
      8'haa : encoded_value = 10'h15a;
      8'hab : encoded_value = 10'h34a;
      8'hac : encoded_value = 10'hda;
      8'had : encoded_value = 10'h2ca;
      8'hae : encoded_value = 10'h1ca;
      8'haf : encoded_value = 10'h28a;
      8'hb0 : encoded_value = 10'h24a;
      8'hb1 : encoded_value = 10'h23a;
      8'hb2 : encoded_value = 10'h13a;
      8'hb3 : encoded_value = 10'h32a;
      8'hb4 : encoded_value = 10'hba;
      8'hb5 : encoded_value = 10'h2aa;
      8'hb6 : encoded_value = 10'h1aa;
      8'hb7 : encoded_value = 10'h5a;
      8'hb8 : encoded_value = 10'hca;
      8'hb9 : encoded_value = 10'h26a;
      8'hba : encoded_value = 10'h16a;
      8'hbb : encoded_value = 10'h9a;
      8'hbc : encoded_value = 10'hea;
      8'hbd : encoded_value = 10'h11a;
      8'hbe : encoded_value = 10'h21a;
      8'hbf : encoded_value = 10'h14a;
      8'hc0 : encoded_value = 10'h186;
      8'hc1 : encoded_value = 10'h226;
      8'hc2 : encoded_value = 10'h126;
      8'hc3 : encoded_value = 10'h316;
      8'hc4 : encoded_value = 10'ha6;
      8'hc5 : encoded_value = 10'h296;
      8'hc6 : encoded_value = 10'h196;
      8'hc7 : encoded_value = 10'h76;
      8'hc8 : encoded_value = 10'h66;
      8'hc9 : encoded_value = 10'h256;
      8'hca : encoded_value = 10'h156;
      8'hcb : encoded_value = 10'h346;
      8'hcc : encoded_value = 10'hd6;
      8'hcd : encoded_value = 10'h2c6;
      8'hce : encoded_value = 10'h1c6;
      8'hcf : encoded_value = 10'h286;
      8'hd0 : encoded_value = 10'h246;
      8'hd1 : encoded_value = 10'h236;
      8'hd2 : encoded_value = 10'h136;
      8'hd3 : encoded_value = 10'h326;
      8'hd4 : encoded_value = 10'hb6;
      8'hd5 : encoded_value = 10'h2a6;
      8'hd6 : encoded_value = 10'h1a6;
      8'hd7 : encoded_value = 10'h56;
      8'hd8 : encoded_value = 10'hc6;
      8'hd9 : encoded_value = 10'h266;
      8'hda : encoded_value = 10'h166;
      8'hdb : encoded_value = 10'h96;
      8'hdc : encoded_value = 10'he6;
      8'hdd : encoded_value = 10'h116;
      8'hde : encoded_value = 10'h216;
      8'hdf : encoded_value = 10'h146;
      8'he0 : encoded_value = 10'h18e;
      8'he1 : encoded_value = 10'h22e;
      8'he2 : encoded_value = 10'h12e;
      8'he3 : encoded_value = 10'h311;
      8'he4 : encoded_value = 10'hae;
      8'he5 : encoded_value = 10'h291;
      8'he6 : encoded_value = 10'h191;
      8'he7 : encoded_value = 10'h71;
      8'he8 : encoded_value = 10'h6e;
      8'he9 : encoded_value = 10'h251;
      8'hea : encoded_value = 10'h151;
      8'heb : encoded_value = 10'h348;
      8'hec : encoded_value = 10'hd1;
      8'hed : encoded_value = 10'h2c8;
      8'hee : encoded_value = 10'h1c8;
      8'hef : encoded_value = 10'h28e;
      8'hf0 : encoded_value = 10'h24e;
      8'hf1 : encoded_value = 10'h231;
      8'hf2 : encoded_value = 10'h131;
      8'hf3 : encoded_value = 10'h321;
      8'hf4 : encoded_value = 10'hb1;
      8'hf5 : encoded_value = 10'h2a1;
      8'hf6 : encoded_value = 10'h1a1;
      8'hf7 : encoded_value = 10'h5e;
      8'hf8 : encoded_value = 10'hce;
      8'hf9 : encoded_value = 10'h261;
      8'hfa : encoded_value = 10'h161;
      8'hfb : encoded_value = 10'h9e;
      8'hfc : encoded_value = 10'he1;
      8'hfd : encoded_value = 10'h11e;
      8'hfe : encoded_value = 10'h21e;
      8'hff : encoded_value = 10'h14e;
      default : $display ("**** Error: Illegal data octet value: %h \n\n", octet_value);
      endcase
   end // data & positive input disparity


   else if (~control & ~running_disparity) // data & negative input disparity
   begin
      case (octet_value)
      8'h0 :  encoded_value = 10'h274;
      8'h1 :  encoded_value = 10'h1d4;
      8'h2 :  encoded_value = 10'h2d4;
      8'h3 :  encoded_value = 10'h31b;
      8'h4 :  encoded_value = 10'h354;
      8'h5 :  encoded_value = 10'h29b;
      8'h6 :  encoded_value = 10'h19b;
      8'h7 :  encoded_value = 10'h38b;
      8'h8 :  encoded_value = 10'h394;
      8'h9 :  encoded_value = 10'h25b;
      8'ha :  encoded_value = 10'h15b;
      8'hb :  encoded_value = 10'h34b;
      8'hc :  encoded_value = 10'hdb;
      8'hd :  encoded_value = 10'h2cb;
      8'he :  encoded_value = 10'h1cb;
      8'hf :  encoded_value = 10'h174;
      8'h10 : encoded_value = 10'h1b4;
      8'h11 : encoded_value = 10'h23b;
      8'h12 : encoded_value = 10'h13b;
      8'h13 : encoded_value = 10'h32b;
      8'h14 : encoded_value = 10'hbb;
      8'h15 : encoded_value = 10'h2ab;
      8'h16 : encoded_value = 10'h1ab;
      8'h17 : encoded_value = 10'h3a4;
      8'h18 : encoded_value = 10'h334;
      8'h19 : encoded_value = 10'h26b;
      8'h1a : encoded_value = 10'h16b;
      8'h1b : encoded_value = 10'h364;
      8'h1c : encoded_value = 10'heb;
      8'h1d : encoded_value = 10'h2e4;
      8'h1e : encoded_value = 10'h1e4;
      8'h1f : encoded_value = 10'h2b4;
      8'h20 : encoded_value = 10'h279;
      8'h21 : encoded_value = 10'h1d9;
      8'h22 : encoded_value = 10'h2d9;
      8'h23 : encoded_value = 10'h319;
      8'h24 : encoded_value = 10'h359;
      8'h25 : encoded_value = 10'h299;
      8'h26 : encoded_value = 10'h199;
      8'h27 : encoded_value = 10'h389;
      8'h28 : encoded_value = 10'h399;
      8'h29 : encoded_value = 10'h259;
      8'h2a : encoded_value = 10'h159;
      8'h2b : encoded_value = 10'h349;
      8'h2c : encoded_value = 10'hd9;
      8'h2d : encoded_value = 10'h2c9;
      8'h2e : encoded_value = 10'h1c9;
      8'h2f : encoded_value = 10'h179;
      8'h30 : encoded_value = 10'h1b9;
      8'h31 : encoded_value = 10'h239;
      8'h32 : encoded_value = 10'h139;
      8'h33 : encoded_value = 10'h329;
      8'h34 : encoded_value = 10'hb9;
      8'h35 : encoded_value = 10'h2a9;
      8'h36 : encoded_value = 10'h1a9;
      8'h37 : encoded_value = 10'h3a9;
      8'h38 : encoded_value = 10'h339;
      8'h39 : encoded_value = 10'h269;
      8'h3a : encoded_value = 10'h169;
      8'h3b : encoded_value = 10'h369;
      8'h3c : encoded_value = 10'he9;
      8'h3d : encoded_value = 10'h2e9;
      8'h3e : encoded_value = 10'h1e9;
      8'h3f : encoded_value = 10'h2b9;
      8'h40 : encoded_value = 10'h275;
      8'h41 : encoded_value = 10'h1d5;
      8'h42 : encoded_value = 10'h2d5;
      8'h43 : encoded_value = 10'h315;
      8'h44 : encoded_value = 10'h355;
      8'h45 : encoded_value = 10'h295;
      8'h46 : encoded_value = 10'h195;
      8'h47 : encoded_value = 10'h385;
      8'h48 : encoded_value = 10'h395;
      8'h49 : encoded_value = 10'h255;
      8'h4a : encoded_value = 10'h155;
      8'h4b : encoded_value = 10'h345;
      8'h4c : encoded_value = 10'hd5;
      8'h4d : encoded_value = 10'h2c5;
      8'h4e : encoded_value = 10'h1c5;
      8'h4f : encoded_value = 10'h175;
      8'h50 : encoded_value = 10'h1b5;
      8'h51 : encoded_value = 10'h235;
      8'h52 : encoded_value = 10'h135;
      8'h53 : encoded_value = 10'h325;
      8'h54 : encoded_value = 10'hb5;
      8'h55 : encoded_value = 10'h2a5;
      8'h56 : encoded_value = 10'h1a5;
      8'h57 : encoded_value = 10'h3a5;
      8'h58 : encoded_value = 10'h335;
      8'h59 : encoded_value = 10'h265;
      8'h5a : encoded_value = 10'h165;
      8'h5b : encoded_value = 10'h365;
      8'h5c : encoded_value = 10'he5;
      8'h5d : encoded_value = 10'h2e5;
      8'h5e : encoded_value = 10'h1e5;
      8'h5f : encoded_value = 10'h2b5;
      8'h60 : encoded_value = 10'h273;
      8'h61 : encoded_value = 10'h1d3;
      8'h62 : encoded_value = 10'h2d3;
      8'h63 : encoded_value = 10'h31c;
      8'h64 : encoded_value = 10'h353;
      8'h65 : encoded_value = 10'h29c;
      8'h66 : encoded_value = 10'h19c;
      8'h67 : encoded_value = 10'h38c;
      8'h68 : encoded_value = 10'h393;
      8'h69 : encoded_value = 10'h25c;
      8'h6a : encoded_value = 10'h15c;
      8'h6b : encoded_value = 10'h34c;
      8'h6c : encoded_value = 10'hdc;
      8'h6d : encoded_value = 10'h2cc;
      8'h6e : encoded_value = 10'h1cc;
      8'h6f : encoded_value = 10'h173;
      8'h70 : encoded_value = 10'h1b3;
      8'h71 : encoded_value = 10'h23c;
      8'h72 : encoded_value = 10'h13c;
      8'h73 : encoded_value = 10'h32c;
      8'h74 : encoded_value = 10'hbc;
      8'h75 : encoded_value = 10'h2ac;
      8'h76 : encoded_value = 10'h1ac;
      8'h77 : encoded_value = 10'h3a3;
      8'h78 : encoded_value = 10'h333;
      8'h79 : encoded_value = 10'h26c;
      8'h7a : encoded_value = 10'h16c;
      8'h7b : encoded_value = 10'h363;
      8'h7c : encoded_value = 10'hec;
      8'h7d : encoded_value = 10'h2e3;
      8'h7e : encoded_value = 10'h1e3;
      8'h7f : encoded_value = 10'h2b3;
      8'h80 : encoded_value = 10'h272;
      8'h81 : encoded_value = 10'h1d2;
      8'h82 : encoded_value = 10'h2d2;
      8'h83 : encoded_value = 10'h31d;
      8'h84 : encoded_value = 10'h352;
      8'h85 : encoded_value = 10'h29d;
      8'h86 : encoded_value = 10'h19d;
      8'h87 : encoded_value = 10'h38d;
      8'h88 : encoded_value = 10'h392;
      8'h89 : encoded_value = 10'h25d;
      8'h8a : encoded_value = 10'h15d;
      8'h8b : encoded_value = 10'h34d;
      8'h8c : encoded_value = 10'hdd;
      8'h8d : encoded_value = 10'h2cd;
      8'h8e : encoded_value = 10'h1cd;
      8'h8f : encoded_value = 10'h172;
      8'h90 : encoded_value = 10'h1b2;
      8'h91 : encoded_value = 10'h23d;
      8'h92 : encoded_value = 10'h13d;
      8'h93 : encoded_value = 10'h32d;
      8'h94 : encoded_value = 10'hbd;
      8'h95 : encoded_value = 10'h2ad;
      8'h96 : encoded_value = 10'h1ad;
      8'h97 : encoded_value = 10'h3a2;
      8'h98 : encoded_value = 10'h332;
      8'h99 : encoded_value = 10'h26d;
      8'h9a : encoded_value = 10'h16d;
      8'h9b : encoded_value = 10'h362;
      8'h9c : encoded_value = 10'hed;
      8'h9d : encoded_value = 10'h2e2;
      8'h9e : encoded_value = 10'h1e2;
      8'h9f : encoded_value = 10'h2b2;
      8'ha0 : encoded_value = 10'h27a;
      8'ha1 : encoded_value = 10'h1da;
      8'ha2 : encoded_value = 10'h2da;
      8'ha3 : encoded_value = 10'h31a;
      8'ha4 : encoded_value = 10'h35a;
      8'ha5 : encoded_value = 10'h29a;
      8'ha6 : encoded_value = 10'h19a;
      8'ha7 : encoded_value = 10'h38a;
      8'ha8 : encoded_value = 10'h39a;
      8'ha9 : encoded_value = 10'h25a;
      8'haa : encoded_value = 10'h15a;
      8'hab : encoded_value = 10'h34a;
      8'hac : encoded_value = 10'hda;
      8'had : encoded_value = 10'h2ca;
      8'hae : encoded_value = 10'h1ca;
      8'haf : encoded_value = 10'h17a;
      8'hb0 : encoded_value = 10'h1ba;
      8'hb1 : encoded_value = 10'h23a;
      8'hb2 : encoded_value = 10'h13a;
      8'hb3 : encoded_value = 10'h32a;
      8'hb4 : encoded_value = 10'hba;
      8'hb5 : encoded_value = 10'h2aa;
      8'hb6 : encoded_value = 10'h1aa;
      8'hb7 : encoded_value = 10'h3aa;
      8'hb8 : encoded_value = 10'h33a;
      8'hb9 : encoded_value = 10'h26a;
      8'hba : encoded_value = 10'h16a;
      8'hbb : encoded_value = 10'h36a;
      8'hbc : encoded_value = 10'hea;
      8'hbd : encoded_value = 10'h2ea;
      8'hbe : encoded_value = 10'h1ea;
      8'hbf : encoded_value = 10'h2ba;
      8'hc0 : encoded_value = 10'h276;
      8'hc1 : encoded_value = 10'h1d6;
      8'hc2 : encoded_value = 10'h2d6;
      8'hc3 : encoded_value = 10'h316;
      8'hc4 : encoded_value = 10'h356;
      8'hc5 : encoded_value = 10'h296;
      8'hc6 : encoded_value = 10'h196;
      8'hc7 : encoded_value = 10'h386;
      8'hc8 : encoded_value = 10'h396;
      8'hc9 : encoded_value = 10'h256;
      8'hca : encoded_value = 10'h156;
      8'hcb : encoded_value = 10'h346;
      8'hcc : encoded_value = 10'hd6;
      8'hcd : encoded_value = 10'h2c6;
      8'hce : encoded_value = 10'h1c6;
      8'hcf : encoded_value = 10'h176;
      8'hd0 : encoded_value = 10'h1b6;
      8'hd1 : encoded_value = 10'h236;
      8'hd2 : encoded_value = 10'h136;
      8'hd3 : encoded_value = 10'h326;
      8'hd4 : encoded_value = 10'hb6;
      8'hd5 : encoded_value = 10'h2a6;
      8'hd6 : encoded_value = 10'h1a6;
      8'hd7 : encoded_value = 10'h3a6;
      8'hd8 : encoded_value = 10'h336;
      8'hd9 : encoded_value = 10'h266;
      8'hda : encoded_value = 10'h166;
      8'hdb : encoded_value = 10'h366;
      8'hdc : encoded_value = 10'he6;
      8'hdd : encoded_value = 10'h2e6;
      8'hde : encoded_value = 10'h1e6;
      8'hdf : encoded_value = 10'h2b6;
      8'he0 : encoded_value = 10'h271;
      8'he1 : encoded_value = 10'h1d1;
      8'he2 : encoded_value = 10'h2d1;
      8'he3 : encoded_value = 10'h31e;
      8'he4 : encoded_value = 10'h351;
      8'he5 : encoded_value = 10'h29e;
      8'he6 : encoded_value = 10'h19e;
      8'he7 : encoded_value = 10'h38e;
      8'he8 : encoded_value = 10'h391;
      8'he9 : encoded_value = 10'h25e;
      8'hea : encoded_value = 10'h15e;
      8'heb : encoded_value = 10'h34e;
      8'hec : encoded_value = 10'hde;
      8'hed : encoded_value = 10'h2ce;
      8'hee : encoded_value = 10'h1ce;
      8'hef : encoded_value = 10'h171;
      8'hf0 : encoded_value = 10'h1b1;
      8'hf1 : encoded_value = 10'h237;
      8'hf2 : encoded_value = 10'h137;
      8'hf3 : encoded_value = 10'h32e;
      8'hf4 : encoded_value = 10'hb7;
      8'hf5 : encoded_value = 10'h2ae;
      8'hf6 : encoded_value = 10'h1ae;
      8'hf7 : encoded_value = 10'h3a1;
      8'hf8 : encoded_value = 10'h331;
      8'hf9 : encoded_value = 10'h26e;
      8'hfa : encoded_value = 10'h16e;
      8'hfb : encoded_value = 10'h361;
      8'hfc : encoded_value = 10'hee;
      8'hfd : encoded_value = 10'h2e1;
      8'hfe : encoded_value = 10'h1e1;
      8'hff : encoded_value = 10'h2b1;
      default : $display ("**** Error: Illegal data octet value: %h \n\n", octet_value);
      endcase
   end // data & negative input disparity
end
// ------------------------------------------


endmodule
