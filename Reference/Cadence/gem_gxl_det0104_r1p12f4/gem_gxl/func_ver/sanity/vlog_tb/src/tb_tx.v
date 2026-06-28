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
//   Filename:           tb_tx.v
//   Module Name:        tb_tx
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
//   Description    : This module checks frames transmitted by the Ethernet MAC.
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_tx (
   reset_tb,
   tx_clk,

   apb_cbs_ctrl_wr,
   apb_idleslope_a_wr,
   apb_idleslope_b_wr,
   pwdata,
   speed,

   col,
   half_duplex,
   gigabit,
   tbi,
   txd,
   tx_en,
   tx_er,

   tx_done,
   tx_fail
);


// -----------------------------------------------------------------------------
// Declare inputs and outputs
// -----------------------------------------------------------------------------
   input          reset_tb;            // testbench reset.
   input          tx_clk;              // transmit clock.

   input          apb_cbs_ctrl_wr;     // Write to CBS control register
   input          apb_idleslope_a_wr;  // Write to CBS Idleslope A
   input          apb_idleslope_b_wr;  // Write to CBS Idleslope BS
   input   [31:0] pwdata;              // APB write data

   output         col;                 // high for collision.

   input          speed;               // indicate 10 (0) / 100 (1).
   input          half_duplex;         // half duplex signal to the PHY.
   input          gigabit;             // high for gigabit operation.
   input          tbi;                 // high for ten bit operation.

   input    [7:0] txd;                 // transmit data to the PHY.
   input          tx_en;               // transmit enable signal to the PHY.
   input          tx_er;               // transmit error signal to the PHY.

   output         tx_done;             // all frames have been transmitted.
   output         tx_fail;             // transmit failed, mismatch between
                                       // transmitted data and reference
                                       // data.

// -----------------------------------------------------------------------------
// Declare internal signals
// -----------------------------------------------------------------------------

   // test data array
   integer        j;                   // loop for array
   reg     [27:0] txd_vector_reg[1:800000];
   reg     [27:0] txd_vector1_reg[1:800000];
   reg     [27:0] txd_vector2_reg[1:800000];
   reg     [27:0] txd_vector3_reg[1:800000];
   reg     [27:0] txd_vector4_reg[1:800000];
   reg     [27:0] txd_vector5_reg[1:800000];
   reg     [27:0] txd_vector6_reg[1:800000];
   reg     [27:0] txd_vector7_reg[1:800000];
   reg     [27:0] txd_vector8_reg[1:800000];
   reg     [27:0] txd_vector9_reg[1:800000];
   reg     [27:0] txd_vector10_reg[1:800000];
   reg     [27:0] txd_vector11_reg[1:800000];
   reg     [27:0] txd_vector12_reg[1:800000];
   reg     [27:0] txd_vector13_reg[1:800000];
   reg     [27:0] txd_vector14_reg[1:800000];
   reg     [27:0] txd_vector15_reg[1:800000];
                                       // array for holding test data
   integer        txd_index;           // current index to array
   integer        txd_index1;          // current index to array
   integer        txd_index2;          // current index to array
   integer        txd_index3;          // current index to array
   integer        txd_index4;          // current index to array
   integer        txd_index5;          // current index to array
   integer        txd_index6;          // current index to array
   integer        txd_index7;          // current index to array
   integer        txd_index8;          // current index to array
   integer        txd_index9;          // current index to array
   integer        txd_index10;          // current index to array
   integer        txd_index11;          // current index to array
   integer        txd_index12;          // current index to array
   integer        txd_index13;          // current index to array
   integer        txd_index14;          // current index to array
   integer        txd_index15;          // current index to array
   integer        txd_index_str;           // current index to array
   integer        txd_index1_str;          // current index to array
   integer        txd_index2_str;          // current index to array
   integer        txd_index3_str;          // current index to array
   integer        txd_index4_str;          // current index to array
   integer        txd_index5_str;          // current index to array
   integer        txd_index6_str;          // current index to array
   integer        txd_index7_str;          // current index to array
   integer        txd_index8_str;          // current index to array
   integer        txd_index9_str;          // current index to array
   integer        txd_index10_str;          // current index to array
   integer        txd_index11_str;          // current index to array
   integer        txd_index12_str;          // current index to array
   integer        txd_index13_str;          // current index to array
   integer        txd_index14_str;          // current index to array
   integer        txd_index15_str;          // current index to array
   wire    [27:0] txd_vector;          // current txd_vector_reg
   wire    [27:0] txd_vector1;          // current txd_vector_reg
   wire    [27:0] txd_vector2;          // current txd_vector_reg
   wire    [27:0] txd_vector3;          // current txd_vector_reg
   wire    [27:0] txd_vector4;          // current txd_vector_reg
   wire    [27:0] txd_vector5;          // current txd_vector_reg
   wire    [27:0] txd_vector6;          // current txd_vector_reg
   wire    [27:0] txd_vector7;          // current txd_vector_reg
   wire    [27:0] txd_vector8;          // current txd_vector_reg
   wire    [27:0] txd_vector9;          // current txd_vector_reg
   wire    [27:0] txd_vector10;          // current txd_vector_reg
   wire    [27:0] txd_vector11;          // current txd_vector_reg
   wire    [27:0] txd_vector12;          // current txd_vector_reg
   wire    [27:0] txd_vector13;          // current txd_vector_reg
   wire    [27:0] txd_vector14;          // current txd_vector_reg
   wire    [27:0] txd_vector15;          // current txd_vector_reg
   wire     [3:0] tx_control;          // control field of txd_vector
   wire     [3:0] tx_control1;          // control field of txd_vector
   wire     [3:0] tx_control2;          // control field of txd_vector
   wire     [3:0] tx_control3;          // control field of txd_vector
   wire     [3:0] tx_control4;          // control field of txd_vector
   wire     [3:0] tx_control5;          // control field of txd_vector
   wire     [3:0] tx_control6;          // control field of txd_vector
   wire     [3:0] tx_control7;          // control field of txd_vector
   wire     [3:0] tx_control8;          // control field of txd_vector
   wire     [3:0] tx_control9;          // control field of txd_vector
   wire     [3:0] tx_control10;          // control field of txd_vector
   wire     [3:0] tx_control11;          // control field of txd_vector
   wire     [3:0] tx_control12;          // control field of txd_vector
   wire     [3:0] tx_control13;          // control field of txd_vector
   wire     [3:0] tx_control14;          // control field of txd_vector
   wire     [3:0] tx_control15;          // control field of txd_vector

   // state machine tracking current section of frame
   reg      [1:0] tx_mon_state;        // current state
   reg      [1:0] tx_mon_state_nxt;    // next state

   // counts to help track progress through frame
   reg     [15:0] tx_length;           // current byte length of frame
   integer        total_bit_count;     // current bit length of frame
   reg     [15:0] ifg_length;          // detect and measure IFG
   reg            nibble_sel;          // keep track of current nibble in 10/100
   reg     [63:0] last_64_bits;        // value of the last 64 bits received

   // detect when DUT is bursting and check burst limit
   reg            burst_mode;          // Currently detecting a burst
   wire           burst_expected;      // expecting a burst between frames
   reg            burst_expected_hold; // held burst_expected
   reg            burst_limit_reached; // reached burst limit (no new bursts!)
   reg     [13:0] burst_limit_count;   // count for detecting burst limit

   wire           expect_fragment;      // expecting a burst between frames

   // txd data checking
   wire     [7:0] tx_compare;          // expected txd byte
   wire     [7:0] tx_compare1;          // expected txd byte
   wire     [7:0] tx_compare2;          // expected txd byte
   wire     [7:0] tx_compare3;          // expected txd byte
   wire     [7:0] tx_compare4;          // expected txd byte
   wire     [7:0] tx_compare5;          // expected txd byte
   wire     [7:0] tx_compare6;          // expected txd byte
   wire     [7:0] tx_compare7;          // expected txd byte
   wire     [7:0] tx_compare8;          // expected txd byte
   wire     [7:0] tx_compare9;          // expected txd byte
   wire     [7:0] tx_compare10;          // expected txd byte
   wire     [7:0] tx_compare11;          // expected txd byte
   wire     [7:0] tx_compare12;          // expected txd byte
   wire     [7:0] tx_compare13;          // expected txd byte
   wire     [7:0] tx_compare14;          // expected txd byte
   wire     [7:0] tx_compare15;          // expected txd byte
   reg      [7:0] tx_actual;           // received txd byte
   reg            expected_fail;       // testbench failed

   // collision assertion and jam checking
   wire           assert_col;          // assert col signal during next byte
   reg            timed_col;           // assert a colliion at byte specified
                                       // by col_time
   reg     [15:0] col_time;            // byte at which to assert timed col
   reg            collision_asserted;  // detect when collision is asserted
   reg            preamble_coll;       // set if collision during preamble
   reg            sfd_coll;            // set if collision during SFD
   reg            extension_coll;      // set if collision during carr extension
   reg            jam_expected;        // set if expecting a JAM sequence
   integer        jam_delay;           // delay before JAM will be output
   integer        jam_length;          // length of JAM
   reg            jam_expected_done;   // pulsed once expected JAM is seen.
   reg            jam_fail;            // jam checking failed
   reg            match;
   reg            match1;
   reg            match2;
   reg            match3;
   reg            match4;
   reg            match5;
   reg            match6;
   reg            match7;
   reg            match8;
   reg            match9;
   reg            match10;
   reg            match11;
   reg            match12;
   reg            match13;
   reg            match14;
   reg            match15;

   // CRC checking signals
   reg     [31:0] crc_tb;              // calculated CRC value
   wire    [31:0] txtb_str_out0;       // stripe out for bit 0
   wire    [31:0] txtb_str_out1;       // stripe out for bit 1
   wire    [31:0] txtb_str_out2;       // stripe out for bit 2
   wire    [31:0] txtb_str_out3;       // stripe out for bit 3
   wire    [31:0] txtb_str_out4;       // stripe out for bit 4
   wire    [31:0] txtb_str_out5;       // stripe out for bit 5
   wire    [31:0] txtb_str_out6;       // stripe out for bit 6
   wire    [31:0] txtb_str_out7;       // stripe out for bit 7
   wire    [31:0] txtb_str_out8;       // stripe out for bit 8
   wire    [31:0] txtb_str_out9;       // stripe out for bit 9
   wire    [31:0] txtb_str_out10;       // stripe out for bit 10
   wire    [31:0] txtb_str_out11;       // stripe out for bit 11
   wire    [31:0] txtb_str_out12;       // stripe out for bit 12
   wire    [31:0] txtb_str_out13;       // stripe out for bit 13
   wire    [31:0] txtb_str_out14;       // stripe out for bit 14
   wire    [31:0] txtb_str_out15;       // stripe out for bit 15

   // reporting to higher level testbench
   reg            tx_done;             // testbench complete
   reg            tx_done1;
   reg            tx_done2;
   reg            tx_done3;
   reg            tx_done4;
   reg            tx_done5;
   reg            tx_done6;
   reg            tx_done7;
   reg            tx_done8;
   reg            tx_done9;
   reg            tx_done10;
   reg            tx_done11;
   reg            tx_done12;
   reg            tx_done13;
   reg            tx_done14;
   reg            tx_done15;
   wire           tx_done_pending;
   wire           tx_done1_pending;
   wire           tx_done2_pending;
   wire           tx_done3_pending;
   wire           tx_done4_pending;
   wire           tx_done5_pending;
   wire           tx_done6_pending;
   wire           tx_done7_pending;
   wire           tx_done8_pending;
   wire           tx_done9_pending;
   wire           tx_done10_pending;
   wire           tx_done11_pending;
   wire           tx_done12_pending;
   wire           tx_done13_pending;
   wire           tx_done14_pending;
   wire           tx_done15_pending;


// -----------------------------------------------------------------------------
// Declare parameters
// -----------------------------------------------------------------------------
   // state decode paramater declarations.
   parameter
      IFG_IDLE       = 2'b00, // check interframe gap time is not violated
      FRAME_DATA     = 2'b01, // check minimum frame size - 64 bytes.
      FRAME_CARR_EXT = 2'b10, // check slot time in gigabit mode (half duplex)
      IFG_CARR_EXT   = 2'b11; // check interframe gap during carrier
                              // extension (bursting mode, gigabit, half duplex)

   `ifdef XG
   parameter MINIMUM_IFG = 5;
   `else
   parameter MINIMUM_IFG = 12;
   `endif


// -----------------------------------------------------------------------------
// initialise test data array from file
// -----------------------------------------------------------------------------

   // read tx data.
   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd.data",txd_vector_reg);
         if (txd_vector_reg[1] === 28'hx)
            $display("\n No txd data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector1_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd1.data",txd_vector1_reg);
         if (txd_vector1_reg[1] === 28'hx)
            $display("\n No txd1 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector2_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd2.data",txd_vector2_reg);
         if (txd_vector2_reg[1] === 28'hx)
            $display("\n No txd2 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector3_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd3.data",txd_vector3_reg);
         if (txd_vector3_reg[1] === 28'hx)
            $display("\n No txd3 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector4_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd4.data",txd_vector4_reg);
         if (txd_vector4_reg[1] === 28'hx)
            $display("\n No txd4 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector5_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd5.data",txd_vector5_reg);
         if (txd_vector5_reg[1] === 28'hx)
            $display("\n No txd5 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector6_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd6.data",txd_vector6_reg);
         if (txd_vector6_reg[1] === 28'hx)
            $display("\n No txd6 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector7_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd7.data",txd_vector7_reg);
         if (txd_vector7_reg[1] === 28'hx)
            $display("\n No txd7 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector8_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd8.data",txd_vector8_reg);
         if (txd_vector8_reg[1] === 28'hx)
            $display("\n No txd8 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector9_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd9.data",txd_vector9_reg);
         if (txd_vector9_reg[1] === 28'hx)
            $display("\n No txd9 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector10_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd10.data",txd_vector10_reg);
         if (txd_vector10_reg[1] === 28'hx)
            $display("\n No txd10 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector11_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd11.data",txd_vector11_reg);
         if (txd_vector11_reg[1] === 28'hx)
            $display("\n No txd11 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector12_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd12.data",txd_vector12_reg);
         if (txd_vector12_reg[1] === 28'hx)
            $display("\n No txd12 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector13_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd13.data",txd_vector13_reg);
         if (txd_vector13_reg[1] === 28'hx)
            $display("\n No txd13 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector14_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd14.data",txd_vector14_reg);
         if (txd_vector14_reg[1] === 28'hx)
            $display("\n No txd14 data file read \n");
      end

   initial
      begin
         // reset array to all zero's.
         for (j=1; j<=32768; j=j+1)
            txd_vector15_reg[j] = 28'b0;

         // two dimensional array of frame reference data read from file.
         $readmemh("./files/tb_txd15.data",txd_vector15_reg);
         if (txd_vector15_reg[1] === 28'hx)
            $display("\n No txd15 data file read \n");
      end

// -----------------------------------------------------------------------------
// Decode current vector
// -----------------------------------------------------------------------------

   // each line of the file referenced by pointer.
   assign txd_vector = txd_vector_reg[txd_index];
   assign txd_vector1 = txd_vector1_reg[txd_index1];
   assign txd_vector2 = txd_vector2_reg[txd_index2];
   assign txd_vector3 = txd_vector3_reg[txd_index3];
   assign txd_vector4 = txd_vector4_reg[txd_index4];
   assign txd_vector5 = txd_vector5_reg[txd_index5];
   assign txd_vector6 = txd_vector6_reg[txd_index6];
   assign txd_vector7 = txd_vector7_reg[txd_index7];
   assign txd_vector8 = txd_vector8_reg[txd_index8];
   assign txd_vector9 = txd_vector9_reg[txd_index9];
   assign txd_vector10 = txd_vector10_reg[txd_index10];
   assign txd_vector11 = txd_vector11_reg[txd_index11];
   assign txd_vector12 = txd_vector12_reg[txd_index12];
   assign txd_vector13 = txd_vector13_reg[txd_index13];
   assign txd_vector14 = txd_vector14_reg[txd_index14];
   assign txd_vector15 = txd_vector15_reg[txd_index15];

   // testbench reference value for comparison with gem_tx output.
   assign tx_compare = txd_vector[7:0];
   assign tx_compare1 = txd_vector1[7:0];
   assign tx_compare2 = txd_vector2[7:0];
   assign tx_compare3 = txd_vector3[7:0];
   assign tx_compare4 = txd_vector4[7:0];
   assign tx_compare5 = txd_vector5[7:0];
   assign tx_compare6 = txd_vector6[7:0];
   assign tx_compare7 = txd_vector7[7:0];
   assign tx_compare8 = txd_vector8[7:0];
   assign tx_compare9 = txd_vector9[7:0];
   assign tx_compare10 = txd_vector10[7:0];
   assign tx_compare11 = txd_vector11[7:0];
   assign tx_compare12 = txd_vector12[7:0];
   assign tx_compare13 = txd_vector13[7:0];
   assign tx_compare14 = txd_vector14[7:0];
   assign tx_compare15 = txd_vector15[7:0];

   // Decode control portion of vector
   assign tx_control[3:0] = (txd_vector[27:24]);
   assign tx_control1[3:0] = (txd_vector1[27:24]);
   assign tx_control2[3:0] = (txd_vector2[27:24]);
   assign tx_control3[3:0] = (txd_vector3[27:24]);
   assign tx_control4[3:0] = (txd_vector4[27:24]);
   assign tx_control5[3:0] = (txd_vector5[27:24]);
   assign tx_control6[3:0] = (txd_vector6[27:24]);
   assign tx_control7[3:0] = (txd_vector7[27:24]);
   assign tx_control8[3:0] = (txd_vector8[27:24]);
   assign tx_control9[3:0] = (txd_vector9[27:24]);
   assign tx_control10[3:0] = (txd_vector10[27:24]);
   assign tx_control11[3:0] = (txd_vector11[27:24]);
   assign tx_control12[3:0] = (txd_vector12[27:24]);
   assign tx_control13[3:0] = (txd_vector13[27:24]);
   assign tx_control14[3:0] = (txd_vector14[27:24]);
   assign tx_control15[3:0] = (txd_vector15[27:24]);

   // last active value of reference data has been read.
   assign tx_done_pending  = (tx_control == 4'b0000);
   assign tx_done1_pending = (tx_control1 == 4'b0000);
   assign tx_done2_pending = (tx_control2 == 4'b0000);
   assign tx_done3_pending = (tx_control3 == 4'b0000);
   assign tx_done4_pending = (tx_control4 == 4'b0000);
   assign tx_done5_pending = (tx_control5 == 4'b0000);
   assign tx_done6_pending = (tx_control6 == 4'b0000);
   assign tx_done7_pending = (tx_control7 == 4'b0000);
   assign tx_done8_pending = (tx_control8 == 4'b0000);
   assign tx_done9_pending = (tx_control9 == 4'b0000);
   assign tx_done10_pending = (tx_control10 == 4'b0000);
   assign tx_done11_pending = (tx_control11 == 4'b0000);
   assign tx_done12_pending = (tx_control12 == 4'b0000);
   assign tx_done13_pending = (tx_control13 == 4'b0000);
   assign tx_done14_pending = (tx_control14 == 4'b0000);
   assign tx_done15_pending = (tx_control15 == 4'b0000);


   reg txd_rdy_sync,txd_rdy_d1;
   always@(posedge tx_clk or negedge reset_tb)
   begin
      if (~reset_tb)
      begin
         txd_rdy_sync <= 1'b0;
         txd_rdy_d1 <= 1'b0;
      end
      else
      begin
        `ifdef rtl
          txd_rdy_sync <= `hierarchy.i_gem_mac.txd_rdy;
        // Gate Level
        `else
          txd_rdy_sync <= 1'b1;
        `endif
         txd_rdy_d1 <= txd_rdy_sync;
      end
   end


// -----------------------------------------------------------------------------
// State machine to track frame phase
// -----------------------------------------------------------------------------

   // synchronous part of tx monitoring state machine.
   always@(posedge tx_clk or negedge reset_tb)
   begin
      if (~reset_tb)
         // reset for tx monitoring state machine.
         tx_mon_state <= IFG_IDLE;
      else
         // present state of tx monitoring state machine.
         tx_mon_state <= tx_mon_state_nxt;
   end

   // next state decode for tx monitoring state machine.

   // IFG_IDLE       - state used to check interframe gap time is not violated.
   // FRAME_DATA     - state used to check minimum frame size - 64 bytes.
   // FRAME_CARR_EXT - state used to check slot time in gigabit mode (half
   //                - duplex) - 512 bytes.
   // IFG_CARR_EXT   - state used to check interframe gap during carrier
   //                - extension (bursting mode, gigabit, half duplex).

   always@(tx_mon_state or tx_en or tx_er or half_duplex or gigabit
           or tx_length or burst_mode)
   begin
      // decodes for next state.
      case (tx_mon_state)
         IFG_IDLE:
            // interframe gap or idle.
            begin
               if (tx_en)
                  // new frame detected.
                  tx_mon_state_nxt = FRAME_DATA;
               else
                  // remain in idle state.
                  tx_mon_state_nxt = IFG_IDLE;
            end
         FRAME_DATA:
            // frame in progress, tx_en is active.
            begin
               if (tx_en | txd_rdy_sync == 1'b0)
                  // frame still active.
                  tx_mon_state_nxt = FRAME_DATA;
               else if (~tx_en & tx_er & half_duplex & gigabit & (tx_length < 512) & ~burst_mode)
                  // carrier extension for frame (within slot time).
                  tx_mon_state_nxt = FRAME_CARR_EXT;
               else if (~tx_en & tx_er & half_duplex & gigabit)
                  // carrier extension for ifg, bursting active.
                  tx_mon_state_nxt = IFG_CARR_EXT;
               else
                  // frame complete, no carrier extend.
                  tx_mon_state_nxt = IFG_IDLE;
            end
         FRAME_CARR_EXT:
            // carrier extension forming part of frame.
            begin
               if (tx_er & ~tx_en & (tx_length < 512))
                  // frame carrier extension still active.
                  tx_mon_state_nxt = FRAME_CARR_EXT;
               else if (tx_er & ~tx_en)
                  // carrier extension in interframe gap.
                  tx_mon_state_nxt = IFG_CARR_EXT;
               else if (~tx_er & ~tx_en)
                  // frame complete, no ifg carrier extend.
                  tx_mon_state_nxt = IFG_IDLE;
               else // both tx_en and tx_er active or just tx_en.
                  begin
                     // return to idle state, as an error has occurred.
                     tx_mon_state_nxt = IFG_IDLE;

                     $display(" Testbench has detected incorrect carrier extension operation");
                     $display(" Both tx_en and tx_er active during carrier extension \n");

                  end
            end
         IFG_CARR_EXT:
            // interframe gap with carrier extension, bursting.
            begin
               if (tx_er & ~tx_en)
                  // remain in carrier extention state.
                  tx_mon_state_nxt = IFG_CARR_EXT;
               else if (~tx_er & tx_en)
                  // new frame detected.
                  tx_mon_state_nxt = FRAME_DATA;
               else
                  begin
                     // return to idle state, as an error has occurred.
                     tx_mon_state_nxt = IFG_IDLE;
                     $display(" Testbench has detected an interframe gap carrier");
                     $display(" extension error, no new frame to transmit \n");
                  end
            end
      endcase
   end

// -----------------------------------------------------------------------------
// Detect fragment
// -----------------------------------------------------------------------------
   assign expect_fragment = tx_control[3:0] == 4'b1001;

// -----------------------------------------------------------------------------
// Detect burst mode
// -----------------------------------------------------------------------------

   // Detect if supposed to be part of a burst
   assign burst_expected =  match   ? (tx_control[3:0] == 4'b0010) :
                            match1  ? (tx_control1[3:0] == 4'b0010) :
                            match2  ? (tx_control2[3:0] == 4'b0010) :
                            match3  ? (tx_control3[3:0] == 4'b0010) :
                            match4  ? (tx_control4[3:0] == 4'b0010) :
                            match5  ? (tx_control5[3:0] == 4'b0010) :
                            match6  ? (tx_control6[3:0] == 4'b0010) :
                            match7  ? (tx_control7[3:0] == 4'b0010) :
                            match8  ? (tx_control8[3:0] == 4'b0010) :
                            match9  ? (tx_control9[3:0] == 4'b0010) :
                            match10 ? (tx_control10[3:0] == 4'b0010) :
                            match11 ? (tx_control11[3:0] == 4'b0010) :
                            match12 ? (tx_control12[3:0] == 4'b0010) :
                            match13 ? (tx_control13[3:0] == 4'b0010) :
                            match14 ? (tx_control14[3:0] == 4'b0010) :
                                      (tx_control15[3:0] == 4'b0010) ;

   // burst mode flag, set once burst mode has
   // been detected ( at end of first frame).
   always@(posedge tx_clk or negedge reset_tb)
   begin
      if (~reset_tb)
         burst_mode <= 1'b0;
      else if (tx_mon_state == IFG_IDLE)
         burst_mode <= 1'b0;
      else if (tx_mon_state == IFG_CARR_EXT)
         burst_mode <= 1'b1;
      else
         burst_mode <= burst_mode;
   end

// -----------------------------------------------------------------------------
// main testbench operation and checking
// -----------------------------------------------------------------------------
   reg dropping_this_fragment;
   always@(posedge tx_clk or negedge reset_tb)
   begin
   if (~reset_tb)
      begin
         crc_tb              <= 32'hffffffff;
         collision_asserted  <= 1'b0;
         expected_fail       <= 1'b0;
         tx_done             <= 1'b0;
         txd_index           <= 1;
         txd_index1           <= 1;
         txd_index2           <= 1;
         txd_index3           <= 1;
         txd_index4           <= 1;
         txd_index5           <= 1;
         txd_index6           <= 1;
         txd_index7           <= 1;
         txd_index8           <= 1;
         txd_index9           <= 1;
         txd_index10           <= 1;
         txd_index11           <= 1;
         txd_index12           <= 1;
         txd_index13           <= 1;
         txd_index14           <= 1;
         txd_index15           <= 1;
         timed_col           <= 1'b0;
         col_time            <= 16'b0;
         ifg_length          <= 16'h0;
         tx_length           <= 16'h0;
         total_bit_count     <= 0;
         nibble_sel          = 0;       // only referenced in this process
         tx_actual           = 8'bx;    // only referenced in this process
         last_64_bits        = 64'h0;   // only referenced in this process
         burst_limit_reached <= 1'b0;
         burst_expected_hold <= 1'b0;
         burst_limit_count   <= 14'h0000;
         match  = 1'b1;
         match1 = 1'b1;
         match2 = 1'b1;
         match3 = 1'b1;
         match4 = 1'b1;
         match5 = 1'b1;
         match6 = 1'b1;
         match7 = 1'b1;
         match8 = 1'b1;
         match9 = 1'b1;
         match10 = 1'b1;
         match11 = 1'b1;
         match12 = 1'b1;
         match13 = 1'b1;
         match14 = 1'b1;
         match15 = 1'b1;
         txd_index_str  = 1;
         txd_index1_str = 1;
         txd_index2_str = 1;
         txd_index3_str = 1;
         txd_index4_str = 1;
         txd_index5_str = 1;
         txd_index6_str = 1;
         txd_index7_str = 1;
         txd_index8_str = 1;
         txd_index9_str = 1;
         txd_index10_str = 1;
         txd_index11_str = 1;
         txd_index12_str = 1;
         txd_index13_str = 1;
         txd_index14_str = 1;
         txd_index15_str = 1;
         dropping_this_fragment <= 1'b0;
      end
   else
   begin
      if (expect_fragment)
      begin
        if (tx_en && !dropping_this_fragment)
        begin
          dropping_this_fragment  <= 1'b1;
          $display("TB_TX : Frame detected on TX is not being checked as per testcase (%0dns)",$time);
        end
        else if (!tx_en)
          dropping_this_fragment  <= 1'b0;
      end

      if (tx_mon_state_nxt == FRAME_DATA)
      begin
        if (txd_rdy_sync)
         // test bench is receiving a frame.
        begin
           if (gigabit)  // byte wide gmii.
              begin
                 total_bit_count   <= total_bit_count + 8;
                 nibble_sel        = 0;
                 last_64_bits      = last_64_bits << 8;
                 last_64_bits[7]   = txd[0];
                 last_64_bits[6]   = txd[1];
                 last_64_bits[5]   = txd[2];
                 last_64_bits[4]   = txd[3];
                 last_64_bits[3]   = txd[4];
                 last_64_bits[2]   = txd[5];
                 last_64_bits[1]   = txd[6];
                 last_64_bits[0]   = txd[7];
                 tx_actual         = txd;
              end
           else  // nibble wide mii.
              begin
                 total_bit_count   <= total_bit_count + 4;
                 last_64_bits      = last_64_bits << 4;
                 last_64_bits[3]   = txd[0];
                 last_64_bits[2]   = txd[1];
                 last_64_bits[1]   = txd[2];
                 last_64_bits[0]   = txd[3];
                 if (tx_mon_state != FRAME_DATA)
                    // reset nibble pointer at start of frame.
                    begin
                       nibble_sel = 1;
                       tx_actual[3:0] = txd[3:0];
                    end
                 else if (nibble_sel == 0)
                    // lower nibble active.
                    begin
                       nibble_sel = 1;
                       tx_actual[3:0] = txd[3:0];
                    end
                 else // upper nibble active.
                    begin
                       nibble_sel = 0;
                       tx_actual[7:4] = txd[3:0];
                    end
              end

              if (total_bit_count == 0)
              begin
                match  = 1'b1;
                match1 = 1'b1;
                match2 = 1'b1;
                match3 = 1'b1;
                match4 = 1'b1;
                match5 = 1'b1;
                match6 = 1'b1;
                match7 = 1'b1;
                match8 = 1'b1;
                match9 = 1'b1;
                match10 = 1'b1;
                match11 = 1'b1;
                match12 = 1'b1;
                match13 = 1'b1;
                match14 = 1'b1;
                match15 = 1'b1;
                txd_index_str  = txd_index;
                txd_index1_str = txd_index1;
                txd_index2_str = txd_index2;
                txd_index3_str = txd_index3;
                txd_index4_str = txd_index4;
                txd_index5_str = txd_index5;
                txd_index6_str = txd_index6;
                txd_index7_str = txd_index7;
                txd_index8_str = txd_index8;
                txd_index9_str = txd_index9;
                txd_index10_str = txd_index10;
                txd_index11_str = txd_index11;
                txd_index12_str = txd_index12;
                txd_index13_str = txd_index13;
                txd_index14_str = txd_index14;
                txd_index15_str = txd_index15;
              end
           if (nibble_sel == 0)   // then check data.
              begin

                 if (!((tx_actual === tx_compare) | (tx_compare === 8'hzz)) || expect_fragment)
                   match = 1'b0;
                 if (!((tx_actual === tx_compare1) | (tx_compare1 === 8'hzz)))
                   match1 = 1'b0;
                 if (!((tx_actual === tx_compare2) | (tx_compare2 === 8'hzz)))
                   match2 = 1'b0;
                 if (!((tx_actual === tx_compare3) | (tx_compare3 === 8'hzz)))
                   match3 = 1'b0;
                 if (!((tx_actual === tx_compare4) | (tx_compare4 === 8'hzz)))
                   match4 = 1'b0;
                 if (!((tx_actual === tx_compare5) | (tx_compare5 === 8'hzz)))
                   match5 = 1'b0;
                 if (!((tx_actual === tx_compare6) | (tx_compare6 === 8'hzz)))
                   match6 = 1'b0;
                 if (!((tx_actual === tx_compare7) | (tx_compare7 === 8'hzz)))
                   match7 = 1'b0;
                 if (!((tx_actual === tx_compare8) | (tx_compare8 === 8'hzz)))
                   match8 = 1'b0;
                 if (!((tx_actual === tx_compare9) | (tx_compare9 === 8'hzz)))
                   match9 = 1'b0;
                 if (!((tx_actual === tx_compare10) | (tx_compare10 === 8'hzz)))
                   match10 = 1'b0;
                 if (!((tx_actual === tx_compare11) | (tx_compare11 === 8'hzz)))
                   match11 = 1'b0;
                 if (!((tx_actual === tx_compare12) | (tx_compare12 === 8'hzz)))
                   match12 = 1'b0;
                 if (!((tx_actual === tx_compare13) | (tx_compare13 === 8'hzz)))
                   match13 = 1'b0;
                 if (!((tx_actual === tx_compare14) | (tx_compare14 === 8'hzz)))
                   match14 = 1'b0;
                 if (!((tx_actual === tx_compare15) | (tx_compare15 === 8'hzz)))
                   match15 = 1'b0;


                 if ((tx_actual === tx_compare) |
                     (tx_actual === tx_compare1) |
                     (tx_actual === tx_compare2) |
                     (tx_actual === tx_compare3) |
                     (tx_actual === tx_compare4) |
                     (tx_actual === tx_compare5) |
                     (tx_actual === tx_compare6) |
                     (tx_actual === tx_compare7) |
                     (tx_actual === tx_compare8) |
                     (tx_actual === tx_compare9) |
                     (tx_actual === tx_compare10) |
                     (tx_actual === tx_compare11) |
                     (tx_actual === tx_compare12) |
                     (tx_actual === tx_compare13) |
                     (tx_actual === tx_compare14) |
                     (tx_actual === tx_compare15))
                    begin
                       `ifdef debugmsglvl0
                       `else
                       if (!expect_fragment)
                       begin
                         if (tx_actual === tx_compare)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare,tx_actual);
                         else if (tx_actual === tx_compare1)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare1,tx_actual);
                         else if (tx_actual === tx_compare2)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare2,tx_actual);
                         else if (tx_actual === tx_compare3)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare3,tx_actual);
                         else if (tx_actual === tx_compare4)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare4,tx_actual);
                         else if (tx_actual === tx_compare5)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare5,tx_actual);
                         else if (tx_actual === tx_compare6)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare6,tx_actual);
                         else if (tx_actual === tx_compare7)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare7,tx_actual);
                         else if (tx_actual === tx_compare8)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare8,tx_actual);
                         else if (tx_actual === tx_compare9)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare9,tx_actual);
                         else if (tx_actual === tx_compare10)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare10,tx_actual);
                         else if (tx_actual === tx_compare11)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare11,tx_actual);
                         else if (tx_actual === tx_compare12)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare12,tx_actual);
                         else if (tx_actual === tx_compare13)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare13,tx_actual);
                         else if (tx_actual === tx_compare14)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare14,tx_actual);
                         else if (tx_actual === tx_compare15)
                         $display("      good txd ---- expected:-  %h  got:-  %h"
                                                          ,tx_compare15,tx_actual);
                       end
                       `endif
                       expected_fail <= 1'b0;
                    end
                 else if ((tx_compare === 8'hzz) |
                          (tx_compare1 === 8'hzz) |
                          (tx_compare2 === 8'hzz) |
                          (tx_compare3 === 8'hzz) |
                          (tx_compare4 === 8'hzz) |
                          (tx_compare5 === 8'hzz) |
                          (tx_compare6 === 8'hzz) |
                          (tx_compare7 === 8'hzz) |
                          (tx_compare8 === 8'hzz) |
                          (tx_compare9 === 8'hzz) |
                          (tx_compare10 === 8'hzz) |
                          (tx_compare11 === 8'hzz) |
                          (tx_compare12 === 8'hzz) |
                          (tx_compare13 === 8'hzz) |
                          (tx_compare14 === 8'hzz) |
                          (tx_compare15 === 8'hzz))
                    begin
                       $display(" WARNING, Dont care expected in txd check data - not checking this byte ----- expected:-  %h  got:-  %h"
                                                        ,tx_compare,tx_actual);
                       expected_fail <= 1'b0;
                    end
                 else if (!expect_fragment)
                    begin
                       $display(" **** bad txd ----- expected:-  %h  got:-  %h (%0dns)"
                                                        ,tx_compare,tx_actual,$time);
                       expected_fail <= 1'b1;
                    end

                 if (col)
                    begin
                       collision_asserted <= 1'b1;
                       $display(" Testbench is asserting collision at byte %d"
                                                                  ,tx_length);
                    end

                 if (tx_done &
                     tx_done1 &
                     tx_done2 &
                     tx_done3 &
                     tx_done4 &
                     tx_done5 &
                     tx_done6 &
                     tx_done7 &
                     tx_done8 &
                     tx_done9 &
                     tx_done10 &
                     tx_done11 &
                     tx_done12 &
                     tx_done13 &
                     tx_done14 &
                     tx_done15)
                 begin
                   // reference data in file less than frame data
                   // transmitted.
                   $display("\n Not enough reference ethernet data \n");
                 end
                 else
                 begin
                   // Q0 is the only queue where trans.pl allows collisions in preamble.
                   // This is a special case because all queues preamble will look the same
                   // and all queues 'match' signals will be '1'
                   if (match & ~tx_done)
                   begin
                     if (tx_actual != 8'h55 && tx_actual != 8'hd5 && tx_compare === 8'hzz && (match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15))
                       txd_index <= txd_index_str;
                     else
                     begin
                       // increment pointer until end of reference data.
                       txd_index <= txd_index + 1;
                       tx_done <= tx_done_pending;
                     end
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done)
                   begin
                     txd_index <= txd_index_str;
                   end

                   if (match1 & ~tx_done1)
                   begin
                     // increment pointer until end of reference data.
                     txd_index1 <= txd_index1 + 1;
                     tx_done1 <= tx_done1_pending;
                   end
                   else if ((match | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done1)
                   begin
                     txd_index1 <= txd_index1_str;
                   end

                   if (match2 & ~tx_done2)
                   begin
                     // increment pointer until end of reference data.
                     txd_index2 <= txd_index2 + 1;
                     tx_done2 <= tx_done2_pending;
                   end
                   else if ((match1 | match | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done2)
                   begin
                     txd_index2 <= txd_index2_str;
                   end

                   if (match3 & ~tx_done3)
                   begin
                     // increment pointer until end of reference data.
                     txd_index3 <= txd_index3 + 1;
                     tx_done3 <= tx_done3_pending;
                   end
                   else if ((match1 | match2 | match | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done3)
                   begin
                     txd_index3 <= txd_index3_str;
                   end

                   if (match4 & ~tx_done4)
                   begin
                     // increment pointer until end of reference data.
                     txd_index4 <= txd_index4 + 1;
                     tx_done4 <= tx_done4_pending;
                   end
                   else if ((match1 | match2 | match3 | match | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done4)
                   begin
                     txd_index4 <= txd_index4_str;
                   end

                   if (match5 & ~tx_done5)
                   begin
                     // increment pointer until end of reference data.
                     txd_index5 <= txd_index5 + 1;
                     tx_done5 <= tx_done5_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done5)
                   begin
                     txd_index5 <= txd_index5_str;
                   end

                   if (match6 & ~tx_done6)
                   begin
                     // increment pointer until end of reference data.
                     txd_index6 <= txd_index6 + 1;
                     tx_done6 <= tx_done6_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done6)
                   begin
                     txd_index6 <= txd_index6_str;
                   end

                   if (match7 & ~tx_done7)
                   begin
                     // increment pointer until end of reference data.
                     txd_index7 <= txd_index7 + 1;
                     tx_done7 <= tx_done7_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done7)
                   begin
                     txd_index7 <= txd_index7_str;
                   end

                   if (match8 & ~tx_done8)
                   begin
                     // increment pointer until end of reference data.
                     txd_index8 <= txd_index8 + 1;
                     tx_done8 <= tx_done8_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match | match9 | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done8)
                   begin
                     txd_index8 <= txd_index8_str;
                   end

                   if (match9 & ~tx_done9)
                   begin
                     // increment pointer until end of reference data.
                     txd_index9 <= txd_index9 + 1;
                     tx_done9 <= tx_done9_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match | match10 | match11 | match12 | match13 | match14 | match15) & ~tx_done9)
                   begin
                     txd_index9 <= txd_index9_str;
                   end

                   if (match10 & ~tx_done10)
                   begin
                     // increment pointer until end of reference data.
                     txd_index10 <= txd_index10 + 1;
                     tx_done10 <= tx_done10_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match | match11 | match12 | match13 | match14 | match15) & ~tx_done10)
                   begin
                     txd_index10 <= txd_index10_str;
                   end

                   if (match11 & ~tx_done11)
                   begin
                     // increment pointer until end of reference data.
                     txd_index11 <= txd_index11 + 1;
                     tx_done11 <= tx_done11_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match | match12 | match13 | match14 | match15) & ~tx_done11)
                   begin
                     txd_index11 <= txd_index11_str;
                   end

                   if (match12 & ~tx_done12)
                   begin
                     // increment pointer until end of reference data.
                     txd_index12 <= txd_index12 + 1;
                     tx_done12 <= tx_done12_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match | match13 | match14 | match15) & ~tx_done12)
                   begin
                     txd_index12 <= txd_index12_str;
                   end

                   if (match13 & ~tx_done13)
                   begin
                     // increment pointer until end of reference data.
                     txd_index13 <= txd_index13 + 1;
                     tx_done13 <= tx_done13_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match | match14 | match15) & ~tx_done13)
                   begin
                     txd_index13 <= txd_index13_str;
                   end

                   if (match14 & ~tx_done14)
                   begin
                     // increment pointer until end of reference data.
                     txd_index14 <= txd_index14 + 1;
                     tx_done14 <= tx_done14_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match | match15) & ~tx_done14)
                   begin
                     txd_index14 <= txd_index14_str;
                   end

                   if (match15 & ~tx_done15)
                   begin
                     // increment pointer until end of reference data.
                     txd_index15 <= txd_index15 + 1;
                     tx_done15 <= tx_done15_pending;
                   end
                   else if ((match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13 | match14 | match) & ~tx_done15)
                   begin
                     txd_index15 <= txd_index15_str;
                   end
                 end


                 // only increment tx_length once preamble is completed.
                 // used for minimum frame length and minimum slot time
                 // verification.
                 if (((total_bit_count > 60) & ~gigabit) |
                     ((total_bit_count > 56) & gigabit))
                    // increment byte count once preamble is complete.
                    tx_length <= tx_length + 1;
              end

           if (total_bit_count == 0)
              // reset stuff at start of frame reception.
              begin
               `ifdef debugmsglvl0
               `else
                 $display("\n Testbench has detected an ethernet frame \n");
                 $display(" Interframe gap period was %d bytes long\n",
                                                                   ifg_length);
               `endif


                 // reset tx_length when tx_en goes high.
                 tx_length <= 16'h0;

                 // reset collision asserted.
                 collision_asserted <= 1'b0;

                 // set timed collision if indicated by vector control nibble
                 timed_col <= match  ? (tx_control == 4'b1000) :
                              match1 ? (tx_control1 == 4'b1000) :
                              match2 ? (tx_control2 == 4'b1000) :
                              match3 ? (tx_control3 == 4'b1000) :
                              match4 ? (tx_control4 == 4'b1000) :
                              match5 ? (tx_control5 == 4'b1000) :
                              match6 ? (tx_control6 == 4'b1000) :
                              match7 ? (tx_control7 == 4'b1000) :
                              match8 ? (tx_control8 == 4'b1000) :
                              match9 ? (tx_control9 == 4'b1000) :
                              match10 ? (tx_control10 == 4'b1000) :
                              match11 ? (tx_control11 == 4'b1000) :
                              match12 ? (tx_control12 == 4'b1000) :
                              match13 ? (tx_control13 == 4'b1000) :
                              match14 ? (tx_control14 == 4'b1000) :
                                       (tx_control15 == 4'b1000) ;
                 col_time[15:0] <= match  ? (txd_vector[23:8]) :
                                   match1 ? (txd_vector1[23:8]) :
                                   match2 ? (txd_vector2[23:8]) :
                                   match3 ? (txd_vector3[23:8]) :
                                   match4 ? (txd_vector4[23:8]) :
                                   match5 ? (txd_vector5[23:8]) :
                                   match6 ? (txd_vector6[23:8]) :
                                   match7 ? (txd_vector7[23:8]) :
                                   match8 ? (txd_vector8[23:8]) :
                                   match9 ? (txd_vector9[23:8]) :
                                   match10 ? (txd_vector10[23:8]) :
                                   match11 ? (txd_vector11[23:8]) :
                                   match12 ? (txd_vector12[23:8]) :
                                   match13 ? (txd_vector13[23:8]) :
                                   match14 ? (txd_vector14[23:8]) :
                                            (txd_vector15[23:8]);

                 // reset crc calculator.
                 crc_tb  <= 32'hffffffff;

              end
           else if (((total_bit_count == 60) & ~gigabit) |
                    ((total_bit_count == 56) & gigabit))
              // check preamble when 64 bits have been received, preamble
              // should always be generated, regardless of whether a collision
              // occurs in the first 64 bit times or not.
              begin
                 if (last_64_bits !== 64'haaaaaaaaaaaaaaab)
                    begin
                       $display("\n Testbench has detected a preamble error\n");
                    end
              end
           else if (((total_bit_count > 60) & ~gigabit) |
                    ((total_bit_count > 56) & gigabit))
              // calculate CRC after preamble.
              begin
                 if (gigabit) // byte wide gmii.
                    crc_tb <= txtb_str_out7;
                 else // nibble wide mii.
                    crc_tb <= txtb_str_out3;
              end

           // ifg length check is reset.
           ifg_length <= 16'h0;

        end
      end
      else if (tx_mon_state_nxt == FRAME_CARR_EXT)
         // carrier extension within slot time.
         begin
            expected_fail <= 1'b0;
            total_bit_count <= 0;
            tx_done <= tx_done_pending;
            tx_done1 <= tx_done1_pending;
            tx_done2 <= tx_done2_pending;
            tx_done3 <= tx_done3_pending;
            tx_done4 <= tx_done4_pending;
            tx_done5 <= tx_done5_pending;
            tx_done6 <= tx_done6_pending;
            tx_done7 <= tx_done7_pending;
            tx_done8 <= tx_done8_pending;
            tx_done9 <= tx_done9_pending;
            tx_done10 <= tx_done10_pending;
            tx_done11 <= tx_done11_pending;
            tx_done12 <= tx_done12_pending;
            tx_done13 <= tx_done13_pending;
            tx_done14 <= tx_done14_pending;
            tx_done15 <= tx_done15_pending;

            // check for carrier extension error. If collision has been
            // asserted we must expect a JAM sequence signalled as
            // carrier extension error.
            if (jam_expected & (txd[7:0] !== 8'h1f))
               begin
                  $display(" **** Expected carrier extension error not seen ---- expected:-  %h  got:-  %h",8'h1f,txd);
                  expected_fail <= 1'b1;
               end
            else if ((txd[7:0] !== 8'h0f) & ~jam_expected)
               begin
                  $display(" **** Carrier extension error ---- expected:-  %h  got:-  %h",8'h0f,txd);
                  expected_fail <= 1'b1;
               end

            // assert collision during carrier extension of frame.
            if (assert_col)
               begin
                  collision_asserted <= 1'b1;
                  $display(" Testbench is asserting collision at byte %d",tx_length);
               end

            // increment frame byte length monitor for slot time measurement.
            tx_length <= tx_length + 1;

            // ifg length check is reset.
            ifg_length <= 16'h0;
         end
      else if (tx_mon_state_nxt == IFG_CARR_EXT)
         // carrier extension within ifg.
         begin
            expected_fail <= 1'b0;
            total_bit_count <= 0;
            tx_done <= tx_done_pending;
            tx_done1 <= tx_done1_pending;
            tx_done2 <= tx_done2_pending;
            tx_done3 <= tx_done3_pending;
            tx_done4 <= tx_done4_pending;
            tx_done5 <= tx_done5_pending;
            tx_done6 <= tx_done6_pending;
            tx_done7 <= tx_done7_pending;
            tx_done8 <= tx_done8_pending;
            tx_done9 <= tx_done9_pending;
            tx_done10 <= tx_done10_pending;
            tx_done11 <= tx_done11_pending;
            tx_done12 <= tx_done12_pending;
            tx_done13 <= tx_done13_pending;
            tx_done14 <= tx_done14_pending;
            tx_done15 <= tx_done15_pending;

            // check for carrier extension error. If collision has been
            // asserted we must expect a JAM sequence signalled as
            // carrier extension error.
            if (jam_expected & (txd[7:0] !== 8'h1f))
               begin
                  $display(" **** Expected carrier extension error not seen ---- expected:-  %h  got:-  %h",8'h1f,txd);
                  expected_fail <= 1'b1;
               end
            else if ((txd[7:0] !== 8'h0f) & ~jam_expected)
               begin
                  $display(" **** Carrier extension error ---- expected:-  %h  got:-  %h",8'h0f,txd);
                  expected_fail <= 1'b1;
               end

            // assert collision during carrier extension of frame.
            if (assert_col)
               begin
                  collision_asserted <= 1'b1;
                  $display(" Testbench is asserting a collision in carrier extension at byte %d within ifg ",ifg_length);
               end

            // increment length monitor for generating collisions during carrier
            // extension (ifg).
            tx_length <= tx_length + 1;

            // increment ifg length count.
            ifg_length <= ifg_length + 1;
         end
      else // tx_mon_state_nxt == IFG_IDLE
         // interframe gap active.
         begin
            if (dropping_this_fragment)
            begin
              txd_index <= txd_index + 1;
              tx_done <= tx_done_pending;
            end
            expected_fail <= 1'b0;
            total_bit_count <= 0;
            tx_done <= tx_done_pending;
            tx_done1 <= tx_done1_pending;
            tx_done2 <= tx_done2_pending;
            tx_done3 <= tx_done3_pending;
            tx_done4 <= tx_done4_pending;
            tx_done5 <= tx_done5_pending;
            tx_done6 <= tx_done6_pending;
            tx_done7 <= tx_done7_pending;
            tx_done8 <= tx_done8_pending;
            tx_done9 <= tx_done9_pending;
            tx_done10 <= tx_done10_pending;
            tx_done11 <= tx_done11_pending;
            tx_done12 <= tx_done12_pending;
            tx_done13 <= tx_done13_pending;
            tx_done14 <= tx_done14_pending;
            tx_done15 <= tx_done15_pending;

            if (gigabit)  // byte wide gmii.
               // count for ifg measurement (byte data).
               begin
                  if (tx_mon_state != IFG_IDLE)
                     // reset interframe gap count on first byte.
                     begin
                        ifg_length <= 16'h0001;
                        nibble_sel = 0;
                     end
                  else
                     // increment interframe gap count.
                     begin
                        ifg_length <= ifg_length + 1;
                        nibble_sel = 0;
                     end
               end
            else  // nibble wide mii.
               // count for ifg measurement (nibble data).
               begin
                  if (tx_mon_state != IFG_IDLE)
                     // reset interframe gap count on first byte.
                     begin
                        ifg_length <= 16'h0001;
                        nibble_sel = ~nibble_sel;
                     end
                  else if (nibble_sel == 0)
                     // increment interframe gap count.
                     begin
                        ifg_length <= ifg_length + 1;
                        nibble_sel = 1;
                     end
                  else // nibble_sel == 1
                     begin
                        ifg_length <= ifg_length;
                        nibble_sel = 0;
                     end
               end
         end

     `ifdef debugmsglvl0
     `else
      if ((tx_mon_state_nxt != FRAME_DATA) & (tx_mon_state == FRAME_DATA))
         // testbench has just received a frame, this is the cycle
         // immediately after the frame has been received.
         begin
            $display("\n Testbench has received an ethernet frame\n");

            // check for alignment error.
            if ((nibble_sel !=  1) & ~gigabit)
               begin
                  if (~collision_asserted)
                     begin
                        $display("\n Dribble Error \n");
                     end
               end

            // check CRC.
            if (collision_asserted & half_duplex)
               $display("\n Testbench has detected jam sequence of %h \n"
                ,last_64_bits[31:0]);
            else if (crc_tb === 32'hc704dd7b)
               //$display(" FCS GOOD, crc_tb is :-   %h\n",crc_tb);
               $display(" with GOOD FCS \n");
            else
               begin
                  $display(" ******* FCS bad *******, crc_tb is :-   %h\n",crc_tb);
               end

            // check min length of data.
            if ((tx_length < 64) & ~collision_asserted)
               begin
                  $display(" SHORT FRAME :- %d  bytes long\n",tx_length);
               end

            // check slot time.
            if ((tx_length < 512) & ~collision_asserted & ~burst_mode &
                (tx_mon_state_nxt != FRAME_CARR_EXT) & gigabit & half_duplex)
               begin
                  $display(" **** Mimimum slot time error\n");
                  $display(" FRAME LENGTH :- %d  bytes long\n",tx_length);
               end

            // check jumbo length frames.
            if ((tx_length > 1536) & ~collision_asserted)
               begin
                  $display(" LONG FRAME :- %d  bytes long\n",tx_length);
               end

            // check max length frames.
            if ((tx_length > 10240) & ~collision_asserted)
               begin
                  $display(" **** JUMBO FRAME LENGTH EXCEEDED :- %d  bytes long\n"
                                                                   ,tx_length);
               end

         end

      // check minimum slot time cycle after carrier extension of frame
      // has finished.
      if ((tx_mon_state_nxt != FRAME_CARR_EXT) &
                                      (tx_mon_state == FRAME_CARR_EXT))
         begin
            $display(" Carrier extension used to extend frame\n");
            //check minimum slot time.
            if ((tx_length < 512) & ~burst_mode)
               begin
                  $display(" **** Mimimum slot time error\n");
                  $display(" FRAME LENGTH (inc CE) :- %d  bytes long\n",tx_length);
               end
         end

      // Print message when frame forms part of a burst.
      if ((tx_mon_state_nxt == FRAME_DATA) & (tx_mon_state == IFG_CARR_EXT))
         begin
            $display(" Testbench has detected burst operation");
            $display(" Previous frame and next frame form part of a burst \n");
         end
      `endif

      // check minimum interframe gap when leaving the idle state.
      if ((tx_mon_state_nxt != IFG_IDLE) & (tx_mon_state == IFG_IDLE))
         begin
            //check minimum ifg time.
            if (ifg_length < MINIMUM_IFG)
               begin
                  $display(" **** Mimimum interframe gap error\n");
                  expected_fail <= 1'b1;
               end
         end

      //check minimum interframe gap when leaving the ifg carrier extend state.
      //only check when going to data state (may have had a collision)
      if ((tx_mon_state_nxt == FRAME_DATA) & (tx_mon_state == IFG_CARR_EXT))
         begin
            $display(" Carrier extension used within interframe gap\n");
            //check minimum ifg time.
            if (ifg_length < MINIMUM_IFG)
               begin
                  $display(" **** Mimimum interframe gap error within carrier extension\n");
                  expected_fail <= 1'b1;
               end
         end

      // hold burst_expected for length of frame. This indicates whether
      // the current frame and the next expected frame should form part of
      // a burst.
      // sampled when entering data state
      if ((tx_mon_state_nxt == FRAME_DATA) & (tx_mon_state != FRAME_DATA))
         burst_expected_hold <= burst_expected;

      // Do check on whether it should or be part of a burst. This
      // only checks "it should be bursted and is not being",
      // but not "it's being bursted and shouldn't be".
      if (burst_expected_hold & (tx_mon_state_nxt == IFG_IDLE) &
          (tx_mon_state != IFG_IDLE))
         begin
            $display(" **** Expected burst did not happen\n");
            expected_fail <= 1'b1;
         end

      // Monitor burst limit
      // Burst limit is set at 64kbits (8192 bytes), and includes
      // all frame fields (DA, SA, typeID, data, pad, CRC) and framing
      // bits (preamble, SFD, carrier extension).
      // Therfore count when ever not in IFG_IDLE, unless limit is reached, or
      // not in gigabit half duplex mode.
      // Once burst limit is reached we are not allowed to start any new
      // frame. Also need to predict if burst limit will be reached during
      // IFG, and if so prevent the IFG from being signalled with carrier
      // extension.
      if ((tx_mon_state_nxt == IFG_IDLE) | ~half_duplex | ~gigabit)
         begin
            burst_limit_reached <= 1'b0;
            burst_limit_count   <= 14'h0000;
         end
      else if ((burst_limit_count == 8180) & ~burst_limit_reached)
         begin
            $display(" Burst limit reached - don't start any new frames\n");
            burst_limit_reached <= 1'b1;
            burst_limit_count   <= burst_limit_count;
         end
      else if (~burst_limit_reached)
         begin
            burst_limit_reached <= 1'b0;
            burst_limit_count   <= burst_limit_count + 14'h0001;
         end

      // Check no new burst frame is started if burst limit has been reached.
      // New burst frame starting when in FRAME_DATA and not staying in
      // FRAME_DATA or going to IFG_IDLE.
      if (burst_limit_reached & (tx_mon_state == FRAME_DATA) &
          ~(tx_mon_state_nxt == IFG_IDLE) & ~(tx_mon_state_nxt == FRAME_DATA))
         begin
            $display(" **** Burst limit exceeded\n");
            expected_fail <= 1'b1;
         end

   end
   end



// -----------------------------------------------------------------------------
// Drive collision signal and detect JAM
// -----------------------------------------------------------------------------

   // collision can either be asserted during frame (27:24) or
   // during carrier extension as a byte count from the start of frame.
   // If a collision occurs in the preamble, there is no way of this
   // TB knowing which queue the frame was for. We therefore probe into
   // the design for that
   wire [3:0] queue;
   wire not_using_any_other_queues;
   assign not_using_any_other_queues = tx_control1[3:0] == 4'h0 && tx_control2[3:0] == 4'h0 && tx_control3[3:0] == 4'h0 && tx_control4[3:0] == 4'h0 && tx_control5[3:0] == 4'h0 && tx_control6[3:0] == 4'h0 && tx_control7[3:0] == 4'h0 && tx_control8[3:0] == 4'h0 && tx_control9[3:0] == 4'h0 && tx_control10[3:0] == 4'h0 && tx_control11[3:0] == 4'h0 && tx_control12[3:0] == 4'h0 && tx_control13[3:0] == 4'h0 && tx_control14[3:0] == 4'h0 && tx_control15[3:0] == 4'h0;
   assign assert_col = match  && (queue == 0 || not_using_any_other_queues)   ? (tx_control[3:0]  == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match1 && queue == 1   ? (tx_control1[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match2 && queue == 2   ? (tx_control2[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match3 && queue == 3   ? (tx_control3[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match4 && queue == 4   ? (tx_control4[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match5 && queue == 5   ? (tx_control5[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match6 && queue == 6   ? (tx_control6[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match7 && queue == 7   ? (tx_control7[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match8 && queue == 8   ? (tx_control8[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match9 && queue == 9   ? (tx_control9[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match10 && queue == 10 ? (tx_control10[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match11 && queue == 11 ? (tx_control11[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match12 && queue == 12 ? (tx_control12[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match13 && queue == 13 ? (tx_control13[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                       match14 && queue == 14 ? (tx_control14[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) :
                                  queue == 15 ? (tx_control15[3:0] == 4'b0111 | (timed_col & tx_length == col_time)) : 1'b0 ;


`ifndef gem_ext_fifo_interface
   `ifdef gem_tx_pkt_buffer
      `ifdef dma_priority_queue1
        reg       tx_en_gmii_d1;
        reg [3:0] queue_dma;
        reg [3:0] queue_mac;
        wire      sched_clk;
        `ifdef gem_spram
          assign sched_clk = `hierarchy.i_gem_mac.i_gem_tx_wrap.hclk;
        `else
          assign sched_clk = `hierarchy.i_gem_mac.i_gem_tx_wrap.tx_clk;
        `endif
          
        always@(posedge sched_clk or negedge reset_tb)
        begin
          if (~reset_tb)
          begin
            queue_dma     <= 4'h0;
            queue_mac     <= 4'h0;
            tx_en_gmii_d1 <= 1'b0;
          end
          else
          begin
            tx_en_gmii_d1 <= `hierarchy.i_gem_mac.tx_en_gmii;
            if (`hierarchy.i_gem_mac.tx_r_sop && `hierarchy.i_gem_mac.tx_r_valid)
            begin
              queue_dma[0] <= `hierarchy.i_gem_mac.tx_r_queue[0];
              `ifdef dma_priority_queue2
              queue_dma[1] <= `hierarchy.i_gem_mac.tx_r_queue[1];
              `else
              queue_dma[1] <= 1'b0;
              `endif
              `ifdef dma_priority_queue4
              queue_dma[2] <= `hierarchy.i_gem_mac.tx_r_queue[2];
              `else
              queue_dma[2] <= 1'b0;
              `endif
              `ifdef dma_priority_queue8
              queue_dma[3] <= `hierarchy.i_gem_mac.tx_r_queue[3];
              `else
              queue_dma[3] <= 1'b0;
              `endif
            end
            if (!`hierarchy.i_gem_mac.tx_en_gmii)
              queue_mac <= queue_dma;
          end
        end
        assign queue = queue_mac;
      `else
        assign queue = 4'h0;
      `endif
   `else
   assign queue = 4'h0;
   `endif
`else
   assign queue = 4'h0;
`endif


   // collision signal output to gem_tx.
   assign #30 col = assert_col;


   // indicate when a jam is expected
   // set jam_expected 3 clocks after collision_asserted, then
   // reset when four bytes received (i.e. the 4 bytes of jam)
   reg collision_was_on_6th;
   always @(posedge tx_clk or negedge reset_tb)
   begin
      if (~reset_tb)
      begin
         jam_expected <= 1'b0;
         jam_expected_done <= 1'b0;
         preamble_coll <= 1'b0;
         sfd_coll <= 1'b0;
         extension_coll <= 1'b0;
         collision_was_on_6th <= 1'b0;
      end
      else if (collision_asserted &
                 (((total_bit_count > 56) & ~gigabit) | // finished pre 10/100
                  ((total_bit_count > 48) &  gigabit) | // finished pre gigabit
                  extension_coll)) // extension collision
      begin
         // adjust length and delay for JAM to occur depending on mode
         // and whether it was a preamble or SFD collision.

         if (gigabit)
         begin
            jam_delay  = 2;
            jam_length = 4;
         end else begin
            jam_delay  = (sfd_coll)? 0 : 5;
            jam_length = 8;
         end

         if (~preamble_coll)
            for (j=1; j<=jam_delay; j=j+1)
               @(posedge tx_clk);
         // special case when collision happens on 6th byte of preamble in gigabit mode
         if (collision_was_on_6th) @(posedge tx_clk);
         jam_expected <= half_duplex;
         for (j=1; j<=jam_length; j=j+1)
            @(posedge tx_clk);
         jam_expected <= 1'b0;
         jam_expected_done <= half_duplex;
            @(posedge tx_clk);
         jam_expected_done <= 1'b0;
         preamble_coll <= 1'b0;
         sfd_coll <= 1'b0;
         extension_coll <= 1'b0;
      end

      // extension/IFG collision
      else if (assert_col & ((tx_mon_state == FRAME_CARR_EXT) |
                             (tx_mon_state == IFG_CARR_EXT)))
         extension_coll <= 1'b1;

      // preamble collision (allow time for syncing)
      else if (assert_col & (total_bit_count <= 40))
         preamble_coll <= 1'b1;

      // SFD collision (allow time for syncing)
      else if (assert_col & (total_bit_count > 40) & (total_bit_count <= 52)
               & ~preamble_coll)
         sfd_coll <= 1'b1;

      if (jam_expected_done || !half_duplex)
        collision_was_on_6th <= 1'b0;
      else if (gigabit && assert_col && total_bit_count == 40)
        collision_was_on_6th <= 1'b1;

   end


   // detect whether expected JAM happens
   always @(posedge tx_clk or negedge reset_tb)
   begin
      if (~reset_tb)
         jam_fail <= 1'b0;

      else if( gigabit )
      begin

         // Check that we had correct JAM length
         if (jam_expected & (tx_mon_state_nxt == IFG_IDLE))
            begin
               $display(" **** Too few jam bytes \n");
               jam_fail <= 1'b1;
            end

         else if (jam_expected_done & (tx_mon_state_nxt != IFG_IDLE))
            begin
               $display(" **** Too many jam bytes \n");
               jam_fail <= 1'b1;
            end

         else
            jam_fail <= 1'b0;
      end
      else
         jam_fail <= 1'b0;
   end



// -----------------------------------------------------------------------------
// Testbench failure reporting to top level
// -----------------------------------------------------------------------------


   assign tx_fail = jam_fail | expected_fail;




// -----------------------------------------------------------------------------
// CRC checking
// -----------------------------------------------------------------------------

   // Calcultae CRC on incoming data and check against received CRC
   tb_crcgen i_tb_crcgen_tx0(.din(txd[0]),.stripe_in(crc_tb       ),
                                                    .stripe_out(txtb_str_out0));
   tb_crcgen i_tb_crcgen_tx1(.din(txd[1]),.stripe_in(txtb_str_out0),
                                                    .stripe_out(txtb_str_out1));
   tb_crcgen i_tb_crcgen_tx2(.din(txd[2]),.stripe_in(txtb_str_out1),
                                                    .stripe_out(txtb_str_out2));
   tb_crcgen i_tb_crcgen_tx3(.din(txd[3]),.stripe_in(txtb_str_out2),
                                                    .stripe_out(txtb_str_out3));
   tb_crcgen i_tb_crcgen_tx4(.din(txd[4]),.stripe_in(txtb_str_out3),
                                                    .stripe_out(txtb_str_out4));
   tb_crcgen i_tb_crcgen_tx5(.din(txd[5]),.stripe_in(txtb_str_out4),
                                                    .stripe_out(txtb_str_out5));
   tb_crcgen i_tb_crcgen_tx6(.din(txd[6]),.stripe_in(txtb_str_out5),
                                                    .stripe_out(txtb_str_out6));
   tb_crcgen i_tb_crcgen_tx7(.din(txd[7]),.stripe_in(txtb_str_out6),
                                                    .stripe_out(txtb_str_out7));


// -----------------------------------------------------------------------------
// Credit-Based Shaping Statistics gathering
// -----------------------------------------------------------------------------

wire        tx_index_q_a;
wire        tx_index_q_b;
integer     last_byte_count_q_a;
integer     last_byte_count_q_b;

real        last_total_byte_count_q_a;
real        last_total_byte_count_q_b;
real        total_bytes_all_queues;
wire        bandwidth_a_percentage;
wire        bandwidth_b_percentage;
wire        bandwidth_q_a_percentage;
wire        bandwidth_q_b_percentage;
wire        idleslope_q_a_percentage;
wire        idleslope_q_b_percentage;
real        bytes_between_q_a;
real        bytes_between_q_b;
real        total_bytes_q_a;
real        total_bytes_q_b;
wire        portTransmitRate;

wire  [3:0] tx_control_q_a;
wire  [3:0] tx_control_q_b;
wire        tx_control_ord;
wire        end_edge_detect;
wire        start_counting_a;
wire        start_counting_b;

reg         end_edge_detect_d;
reg         q_a_start_edge_d;
reg         q_a_start_edge_det_del;
reg         q_a_start_edge_det_del2;
reg         q_b_start_edge_d;
reg         q_b_start_edge_det_del;
reg         q_b_start_edge_det_del2;
reg   [1:0] cbs_ctrl;
reg  [31:0] idleslope_a;
reg  [31:0] idleslope_b;
reg         enable_cnt_q_a;
reg         enable_cnt_q_b;


assign start_counting_a = !tx_control_ord & match2;
assign start_counting_b = !tx_control_ord & match1;



// Register APB write to CBS registers

   always @(posedge tx_clk or negedge reset_tb)
     begin
     if (~reset_tb)
       begin
         cbs_ctrl    <= 2'b00;
         idleslope_a <= 32'h00000000;
         idleslope_b <= 32'h00000000;
       end
     else if (apb_cbs_ctrl_wr)
       begin
         cbs_ctrl <= pwdata[1:0];
       end
     else if (apb_idleslope_a_wr)
       begin
         idleslope_a <= pwdata[31:0];
       end
     else if (apb_idleslope_b_wr)
       begin
         idleslope_b <= pwdata[31:0];
       end
     else
       begin
         cbs_ctrl    <= cbs_ctrl;
         idleslope_a <= idleslope_a;
         idleslope_b <= idleslope_b;
       end

     end


// Select the portTransmitRate depending on speed mode
assign portTransmitRate  = (gigabit)   ? 32'h07735940 : // 1 Gbit
                           (speed)?      32'h017D7840 : // 100 Mbit
                                         32'h002625A0;  // 10 Mbit

// Select the priorty queues to feed statistics
          `ifdef dma_priority_queue15
            assign tx_index_q_a   = txd_index15;
            assign tx_index_q_b   = txd_index14;
            assign tx_control_q_a = tx_control15;
            assign tx_control_q_b = tx_control14;
            assign tx_control_q_b = tx_control14;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12 | match13);
          `else
          `ifdef dma_priority_queue14
            assign tx_index_q_a   = txd_index14;
            assign tx_index_q_b   = txd_index13;
            assign tx_control_q_a = tx_control14;
            assign tx_control_q_b = tx_control13;
            assign tx_control_q_b = tx_control13;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11 | match12);
          `else
          `ifdef dma_priority_queue13
            assign tx_index_q_a   = txd_index13;
            assign tx_index_q_b   = txd_index12;
            assign tx_control_q_a = tx_control13;
            assign tx_control_q_b = tx_control12;
            assign tx_control_q_b = tx_control12;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10 | match11);
          `else
          `ifdef dma_priority_queue12
            assign tx_index_q_a   = txd_index12;
            assign tx_index_q_b   = txd_index11;
            assign tx_control_q_a = tx_control12;
            assign tx_control_q_b = tx_control11;
            assign tx_control_q_b = tx_control11;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9 | match10);
          `else
          `ifdef dma_priority_queue11
            assign tx_index_q_a   = txd_index11;
            assign tx_index_q_b   = txd_index10;
            assign tx_control_q_a = tx_control11;
            assign tx_control_q_b = tx_control10;
            assign tx_control_q_b = tx_control10;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8 | match9);
          `else
          `ifdef dma_priority_queue10
            assign tx_index_q_a   = txd_index10;
            assign tx_index_q_b   = txd_index9;
            assign tx_control_q_a = tx_control10;
            assign tx_control_q_b = tx_control9;
            assign tx_control_q_b = tx_control9;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5 | match6 | match7 | match8);
          `else
          `ifdef dma_priority_queue9
            assign tx_index_q_a   = txd_index9;
            assign tx_index_q_b   = txd_index8;
            assign tx_control_q_a = tx_control9;
            assign tx_control_q_b = tx_control8;
            assign tx_control_q_b = tx_control8;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5 | match6 | match7);
          `else
          `ifdef dma_priority_queue8
            assign tx_index_q_a   = txd_index8;
            assign tx_index_q_b   = txd_index7;
            assign tx_control_q_a = tx_control8;
            assign tx_control_q_b = tx_control7;
            assign tx_control_q_b = tx_control7;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5 | match6);
          `else
          `ifdef dma_priority_queue7
            assign tx_index_q_a   = txd_index7;
            assign tx_index_q_b   = txd_index6;
            assign tx_control_q_a = tx_control7;
            assign tx_control_q_b = tx_control6;
            assign tx_control_q_b = tx_control6;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4 | match5);
          `else
          `ifdef dma_priority_queue6
            assign tx_index_q_a   = txd_index6;
            assign tx_index_q_b   = txd_index5;
            assign tx_control_q_a = tx_control6;
            assign tx_control_q_b = tx_control5;
            assign tx_control_ord = (match | match1 | match2 | match3 | match4);
          `else
          `ifdef dma_priority_queue5
            assign tx_index_q_a   = txd_index5;
            assign tx_index_q_b   = txd_index4;
            assign tx_control_q_a = tx_control5;
            assign tx_control_q_b = tx_control4;
            assign tx_control_ord = (match | match1 | match2 | match3);
          `else
          `ifdef dma_priority_queue4
            assign tx_index_q_a   = txd_index4;
            assign tx_index_q_b   = txd_index3;
            assign tx_control_q_a = tx_control4;
            assign tx_control_q_b = tx_control3;
            assign tx_control_ord = (match | match1 | match2);
          `else
          `ifdef dma_priority_queue3
            assign tx_index_q_a   = txd_index3;
            assign tx_index_q_b   = txd_index2;
            assign tx_control_q_a = tx_control3;
            assign tx_control_q_b = tx_control2;
            assign tx_control_ord = (match | match1);
          `else
          `ifdef dma_priority_queue2
            assign tx_index_q_a   = txd_index2;
            assign tx_index_q_b   = txd_index1;
            assign tx_control_q_a = tx_control2;
            assign tx_control_q_b = tx_control1;
            assign tx_control_ord = match;
          `else
          `ifdef dma_priority_queue1
            assign tx_index_q_a   = txd_index1;
            assign tx_index_q_b   = txd_index;
            assign tx_control_q_a = tx_control1;
            assign tx_control_q_b = tx_control;
            assign tx_control_ord = 0;
          `else
            assign tx_index_q_a   = 0;
            assign tx_index_q_b   = 0;
            assign tx_control_q_a = 0;
            assign tx_control_q_b = 0;
            assign tx_control_ord = 0;
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif
         `endif


assign all_done = (tx_done & tx_done1 & tx_done2 & tx_done3 &
                   tx_done4 & tx_done5 & tx_done6 & tx_done7);

assign end_edge_detect          = !end_edge_detect_d & all_done;

assign q_a_start_edge_detect    = !q_a_start_edge_d & start_counting_a;
assign q_b_start_edge_detect    = !q_b_start_edge_d & start_counting_b;

assign bandwidth_a_percentage   = (tx_index_q_a/total_bytes_all_queues)*100;
assign bandwidth_b_percentage   = (tx_index_q_b/total_bytes_all_queues)*100;
assign bandwidth_q_a_percentage = (last_byte_count_q_a/last_total_byte_count_q_a)*100;
assign bandwidth_q_b_percentage = (last_byte_count_q_b/last_total_byte_count_q_b)*100;
assign idleslope_q_a_percentage = (idleslope_a/portTransmitRate)*100;
assign idleslope_q_b_percentage = (idleslope_b/portTransmitRate)*100;

// Count the total bandwidth from whent he first byte is transmitted to
// the last byte.
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       begin
         total_bytes_all_queues <= 0;
       end
//     else if (((nibble_sel & !gigabit) | gigabit) & (
     else if ((txd_index !== 1)  | (txd_index1 !== 1) |
              (txd_index2 !== 1) | (txd_index3 !== 1) |
              (txd_index4 !== 1) | (txd_index5 !== 1) |
              (txd_index6 !== 1) | (txd_index7 !== 1) |
              (txd_index8 !== 1) | (txd_index9 !== 1) |
              (txd_index10 !== 1) | (txd_index11 !== 1) |
              (txd_index12 !== 1) | (txd_index13 !== 1) |
              (txd_index14 !== 1) | (txd_index15 !== 1))
       begin
         total_bytes_all_queues <= total_bytes_all_queues + 1;
       end
   end



// Count the total bandwidth from whent he first byte is transmitted to
// the last byte.
   always @(posedge tx_clk or negedge reset_tb)
   begin
       if (end_edge_detect)
         begin
           $display("");
           $display("");
           $display(" *---------------------------------------------------*");
           $display("        Credit Based Shaping Statistics");
           $display(" ** Total bytes for all queues %f \n **", total_bytes_all_queues);
           $display(" ** Total bytes for queue A %d \n\n **", tx_index_q_a);
           $display(" ** Total bytes for queue B %d \n **", tx_index_q_b);
           $display(" ** Queue A percentage bandwidth %0f \n **", bandwidth_a_percentage);
           $display(" ** Queue B percentage bandwidth %0f \n **", bandwidth_b_percentage);
           $display(" *---------------------------------------------------*");
           $display("  (%0dns)        ", $time);
           $display("");
           $display("");
         end
   end

// Detect when all queues are complete
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       end_edge_detect_d <= 0;
     else
       end_edge_detect_d <= all_done;
   end


//------------------------------------------------------------------------------
// Queue A stats handling
//------------------------------------------------------------------------------
// Detect the start of tranmission
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       q_a_start_edge_d <= 0;
     else
       q_a_start_edge_d <= start_counting_a;
   end

// Delay start edge detect to allow counts to be latched before checking
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
     begin
       q_a_start_edge_det_del  <= 0;
       q_a_start_edge_det_del2 <= 0;
     end
     else //if ((nibble_sel & !gigabit) | gigabit)
     begin
       q_a_start_edge_det_del  <= q_a_start_edge_detect;
       q_a_start_edge_det_del2 <= q_a_start_edge_det_del;
     end
   end

// Store the final values at the start of subsequent transfer on the same queue
// to allow the stats to be evaluated while the counters proceed with the next
// transfer
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
     begin
       last_byte_count_q_a <= 0;
       last_total_byte_count_q_a <= 0;
     end
     else if (q_a_start_edge_detect)
     begin
       last_byte_count_q_a <= total_bytes_q_a;
       last_total_byte_count_q_a <= bytes_between_q_a;
     end
   end

// Count total bytes between the start of a packet transfer in the same queue
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       enable_cnt_q_a <= 0;
     else if (q_a_start_edge_detect)
       enable_cnt_q_a <= 1'b1;
     else
       enable_cnt_q_a <= enable_cnt_q_a;
   end

// Count the bytes between the start of two consecutive packets
// on the same queue
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       total_bytes_q_a <= 0;
     else if (q_a_start_edge_detect)
       total_bytes_q_a <= 0;
     else if (start_counting_a)
       total_bytes_q_a <= total_bytes_q_a + 1;
     else
       total_bytes_q_a <= total_bytes_q_a;
   end

// Count the bytes actually transferred in the current transfer
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       bytes_between_q_a <= 0;
     else if (q_a_start_edge_detect)
       bytes_between_q_a <= 0;
     else if (enable_cnt_q_a)
       bytes_between_q_a <= bytes_between_q_a + 1;
     else
       bytes_between_q_a <= bytes_between_q_a;
   end



//------------------------------------------------------------------------------
// Queue B stats handling
//------------------------------------------------------------------------------
// Detect the start of tranmission
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       q_b_start_edge_d <= 0;
     else
       q_b_start_edge_d <= start_counting_b;
   end

// Delay start edge detect to allow counts to be latched before checking
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
     begin
       q_b_start_edge_det_del  <= 0;
       q_b_start_edge_det_del2 <= 0;
     end
     else //if ((nibble_sel & !gigabit) | gigabit)
     begin
       q_b_start_edge_det_del  <= q_b_start_edge_detect;
       q_b_start_edge_det_del2 <= q_b_start_edge_det_del;
     end
   end

// Store the final values at the start of subsequent transfer on the same queue
// to allow the stats to be evaluated while the counters proceed with the next
// transfer
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
     begin
       last_byte_count_q_b <= 0;
       last_total_byte_count_q_b <= 0;
     end
     else if (q_b_start_edge_detect)
     begin
       last_byte_count_q_b <= total_bytes_q_b;
       last_total_byte_count_q_b <= bytes_between_q_b;
     end
   end

// Count total bytes between the start of a packet transfer in the same queue
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       enable_cnt_q_b <= 0;
     else if (q_b_start_edge_detect)
       enable_cnt_q_b <= 1'b1;
     else
       enable_cnt_q_b <= enable_cnt_q_b;
   end

// Count the bytes between the start of two consecutive packets
// on the same queue
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       total_bytes_q_b <= 0;
     else if (q_b_start_edge_detect)
       total_bytes_q_b <= 0;
     else if (start_counting_b)
       total_bytes_q_b <= total_bytes_q_b + 1;
     else
       total_bytes_q_b <= total_bytes_q_b;
   end

// Count the bytes actually transferred in the current transfer
   always @(posedge tx_clk or negedge reset_tb)
   begin
     if (~reset_tb)
       bytes_between_q_b <= 0;
     else if (q_b_start_edge_detect)
       bytes_between_q_b <= 0;
     else if (enable_cnt_q_b)
       bytes_between_q_b <= bytes_between_q_b + 1;
     else
       bytes_between_q_b <= bytes_between_q_b;
   end


// Count the total bandwidth from whent he first byte is transmitted to
// the last byte.
   always @(posedge tx_clk or negedge reset_tb)
   begin
       if (q_a_start_edge_det_del & cbs_ctrl[0])
         begin
           $display("");
           $display(" *---------------------------------------------------*");
           $display("  IdleSlope for Queue A               = %0f        ", idleslope_q_a_percentage);
           $display("  Proportion of Bandwidth for queue A = %0f        ", bandwidth_q_a_percentage);
           $display("  (%0dns)        ", $time);
           $display(" *---------------------------------------------------*");
           $display("");
         end
   end

   always @(posedge tx_clk or negedge reset_tb)
   begin
       if (q_b_start_edge_det_del & cbs_ctrl[1])
         begin
           $display("");
           $display(" *---------------------------------------------------*");
           $display("  IdleSlope for Queue B               = %0f         ", idleslope_q_b_percentage);
           $display("  Proportion of Bandwidth for queue B = %0f         ", bandwidth_q_b_percentage);
           $display("  (%0dns)        ", $time);
           $display(" *---------------------------------------------------*");
           $display("");
         end
   end


endmodule
