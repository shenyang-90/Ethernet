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
//   Filename:           tb_pcs_tx.v
//   Module Name:        tb_pcs_tx
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
//   Description    :   PCS_tx transactor. Compares either I2 ordered sets or
//                      test vectors read from ../work/files/tb_pcs_tx.data.
//                      This start to compare input code groups with I2 ordered
//                      set after tb_reset deasserted. If at some point /S/ or
//                      /C/ is detected,the transactor starts to read vectors
//                      from the testcase file and compare them against the
//                      gem_gxl tx_group. This continues until /I2/ is detected.
//                      Whenever carrier extension needed, this must be supplied
//                      within the test vectors. The test bench checks the
//                      presense of a min interframe gap only in terms of min
//                      12 cycles between /T/ and next /S/ (this regards any
//                      two consequtive frames being rx-tx or tx-tx).
//                      Also generates 1cycle pulse to trigger other transactors
//
//------------------------------------------------------------------------------


module tb_pcs_tx (
  // Inputs
  reset_tb,             // testbench reset
  gtx_clk,              // gtx clock (to the PHY)
  tx_group,             // 10 bit codegroups
  tbi,                  // TBI interface selected

  apb_trig,             // Trigger from APb transactor
  int_pulse,            // Trigger from interrupt detected
  rx_in_progress,       // input from tb_pcs_rx - synch_trigger
  idle_1_received,      // EPD of the tb_pcs_rx ended with I1 ordered set

  link_fault_sig_en,    // Indicates LFSM enable
  link_fault,           // The Link Fault status indicator:
                        // 00 - OK
                        // 01 - Local Fault
                        // 10 - Remote Fault
                        // 11 - Link Interruption

  // Outputs
  pcs_tx_done,          // signals completion of tx activity
  pcs_tx_fail,          // signals failure of a comparison check

  trig_from_pcs_tx      // 1 cycle pulse for triggering other transactors
);

// *****************************************************************************
// Declare inputs and outputs
// *****************************************************************************

  input        reset_tb;            // global tb reset
  input        gtx_clk;             // transmit clock from the mac
  input  [9:0] tx_group;            // TBI receive data from the mac
  input        tbi;                 // tbi in use by the gem_gxl

  input        apb_trig;            // Trigger from APB transactor
  input        int_pulse;           // Trigger from interrupt detected
  input        rx_in_progress;      // flags reception in progress
  input        idle_1_received;     // gem_gxl received EPD followed by I1

  input        link_fault_sig_en;   // Indicates LFSM enable
  input  [1:0] link_fault;          // The Link Fault status indicator:
                                    // 00 - OK
                                    // 01 - Local Fault
                                    // 10 - Remote Fault
                                    // 11 - Link Interruption

  output       pcs_tx_done;         // indicates all test vectors executed
  output       pcs_tx_fail;         // indicates vector comparison failed

  output       trig_from_pcs_tx;    // 1 cycle pulse for triggering other tb

// *****************************************************************************
// Declare internal signals
// *****************************************************************************

  // test data array
  reg    [23:0]  pcs_tx_vector_mem [1:16384];
                                         // memory holding testcase data
  integer        i;                      // loop index
  integer        pcs_tx_index;           // index for the test vector memory
  wire   [23:0]  pcs_tx_vector;          // current command
  wire   [23:0]  pcs_tx_vector_nxt;      // next command

  // test data array decodes
  wire   [9:0]   expected_10bit;         // expected 10 bit code
  reg    [9:0]   rev_expected_10bit;     // expected 10 bit code reversed
  wire   [9:0]   expected_10bit_nxt;     // next expected 10 bit code
  reg    [9:0]   rev_expected_10bit_nxt; // expected 10 bit code reversed
  reg    [7:0]   exp_cfg_reg;            // expected config reg (autonegotiation)
  reg    [7:0]   exp_cfg_reg_nxt;        // next expected config reg (autoneg)
  wire   [7:0]   exp_cfg_reg_low;        // expected config reg (low)
  wire   [7:0]   exp_cfg_reg_low_nxt;    // next expected config reg (low)
  wire   [7:0]   exp_cfg_reg_high;       // expected config reg (high)
  wire   [7:0]   exp_cfg_reg_high_nxt;   // next expected config reg (high)
  wire   [6:0]   pcs_tx_ctrl;            // current control field
  wire   [6:0]   pcs_tx_ctrl_nxt;        // next control field
  wire           pcs_tx_done;            // current vector indicates done
  wire           pcs_tx_done_nxt;        // next vector indicates done
  wire           wait_for_s;             // current wait for start of packet
  wire           wait_for_s_nxt;         // next wait for start of packet
  wire           auto_neg_ctrl;          // current vector indicates autonegotiate
  wire           auto_neg_ctrl_nxt;      // next vector indicates autonegotiate
  wire           trigger_ctrl;           // current trigger other testbenches
  wire           trigger_ctrl_nxt;       // next trigger other testbenches
  wire           wait_for_apb;           // current wait for apb trigger
  wire           wait_for_apb_nxt;       // next wait for apb trigger
  wire           wait_for_int;           // current wait for interrupt trigger
  wire           wait_for_int_nxt;       // next wait for interrupt trigger
  wire           reset_ctrl;             // current is PCS reset occuring
  wire           reset_ctrl_nxt;         // next is PCS reset occuring

  // detect apb and interrupt triggers
  reg            apb_trigger_lat;        // latch apb_trig
  reg            apb_trigger_det;        // detect apb_trigger_lat into gtx_clk
  reg            int_trigger_lat;        // latch int_pulse
  reg            int_trigger_det;        // detect int_trigger_lat into gtx_clk

  // decode incoming data stream
  reg    [9:0]   reversed_tx_group;      // tx_group[0:9]
  wire           k28_0_p;                // current is a K28.0 with +ve disparity
  wire           k28_0_n;                // current is a K28.0 with -ve disparity
  wire           k28_1_p;                // current is a K28.1 with +ve disparity
  wire           k28_1_n;                // current is a K28.1 with -ve disparity
  wire           k28_2_p;                // current is a K28.2 with +ve disparity
  wire           k28_2_n;                // current is a K28.2 with -ve disparity
  wire           k28_3_p;                // current is a K28.3 with +ve disparity
  wire           k28_3_n;                // current is a K28.3 with -ve disparity
  wire           k28_4_p;                // current is a K28.4 with +ve disparity
  wire           k28_4_n;                // current is a K28.4 with -ve disparity
  wire           k28_5_p;                // current is a K28.5 with +ve disparity
  wire           k28_5_n;                // current is a K28.5 with -ve disparity
  wire           k28_6_p;                // current is a K28.6 with +ve disparity
  wire           k28_6_n;                // current is a K28.6 with -ve disparity
  wire           k28_7_p;                // current is a K28.7 with +ve disparity
  wire           k28_7_n;                // current is a K28.7 with -ve disparity
  wire           k23_7_p;                // current is a K23.7 with +ve disparity
  wire           k23_7_n;                // current is a K23.7 with -ve disparity
  wire           k27_7_p;                // current is a K27.7 with +ve disparity
  wire           k27_7_n;                // current is a K27.7 with -ve disparity
  wire           k29_7_p;                // current is a K29.7 with +ve disparity
  wire           k29_7_n;                // current is a K29.7 with -ve disparity
  wire           k30_7_p;                // current is a K30.7 with +ve disparity
  wire           k30_7_n;                // current is a K30.7 with -ve disparity
  reg            prev_k28_0_p;           // previous was K28.0 with +ve disparity
  reg            prev_k28_0_n;           // previous was K28.0 with -ve disparity
  reg            prev_k28_1_p;           // previous was K28.1 with +ve disparity
  reg            prev_k28_1_n;           // previous was K28.1 with -ve disparity
  reg            prev_k28_2_p;           // previous was K28.2 with +ve disparity
  reg            prev_k28_2_n;           // previous was K28.2 with -ve disparity
  reg            prev_k28_3_p;           // previous was K28.3 with +ve disparity
  reg            prev_k28_3_n;           // previous was K28.3 with -ve disparity
  reg            prev_k28_4_p;           // previous was K28.4 with +ve disparity
  reg            prev_k28_4_n;           // previous was K28.4 with -ve disparity
  reg            prev_k28_5_p;           // previous was K28.5 with +ve disparity
  reg            prev_k28_5_n;           // previous was K28.5 with -ve disparity
  reg            prev_k28_6_p;           // previous was K28.6 with +ve disparity
  reg            prev_k28_6_n;           // previous was K28.6 with -ve disparity
  reg            prev_k28_7_p;           // previous was K28.7 with +ve disparity
  reg            prev_k28_7_n;           // previous was K28.7 with -ve disparity
  reg            prev_k23_7_p;           // previous was K23.7 with +ve disparity
  reg            prev_k23_7_n;           // previous was K23.7 with -ve disparity
  reg            prev_k27_7_p;           // previous was K27.7 with +ve disparity
  reg            prev_k27_7_n;           // previous was K27.7 with -ve disparity
  reg            prev_k29_7_p;           // previous was K29.7 with +ve disparity
  reg            prev_k29_7_n;           // previous was K29.7 with -ve disparity
  reg            prev_k30_7_p;           // previous was K30.7 with +ve disparity
  reg            prev_k30_7_n;           // previous was K30.7 with -ve disparity
  wire           d21_5_p;                // current is a D21.5 with +ve disparity
  wire           d21_5_n;                // current is a D21.5 with -ve disparity
  wire           d2_2_p;                 // current is a D2.2  with +ve disparity
  wire           d2_2_n;                 // current is a D2.2  with -ve disparity
  wire           d5_6_p;                 // current is a D5.6  with +ve disparity
  wire           d5_6_n;                 // current is a D5.6  with -ve disparity
  wire           d16_2_p;                // current is a D16.2 with +ve disparity
  wire           d16_2_n;                // current is a D16.2 with -ve disparity
  wire           d6_5_p;                 // current is a D6.5  with +ve disparity
  wire           d6_5_n;                 // current is a D6.5  with -ve disparity
  wire           d26_4_p;                // current is a D26.4 with +ve disparity
  wire           d26_4_n;                // current is a D26.4 with -ve disparity
  wire           d0_0_p ;                // current is a D0.0  with +ve disparity;
  wire           d0_0_n ;                // current is a D0.0  with -ve disparity;
  wire           d0_6_p ;                // current is a D0.6  with +ve disparity;
  wire           d0_6_n ;                // current is a D0.6  with -ve disparity;
  wire           d16_6_p;                // current is a D16.6 with +ve disparity;
  wire           d16_6_n;                // current is a D16.6 with -ve disparity;
  wire           d0_7_p ;                // current is a D0.7  with +ve disparity;
  wire           d0_7_n ;                // current is a D0.7  with -ve disparity;
  wire           d16_7_p;                // current is a D16.7 with +ve disparity;
  wire           d16_7_n;                // current is a D16.7 with -ve disparity;

  // keep track of disparity of tx_group input
  integer        j;                      // loop variable
  integer        k;                      // loop variable
  integer        ones_number_6;          // number of one's in 6 bit group
  integer        ones_number_4;          // number of one's in 4 bit group
  reg            new_disparity_6;        // new disparity from 6 bit calculation
  reg            new_disparity_4;        // new disparity from 4 bit calculation
  reg            running_disparity;      // current running disparity value

  // detect special ordered sets
  wire           idle_1_detected;        // detected a /I1/ sequence
  wire           idle_2_detected;        // detected a /I2/ sequence
  wire           lpi_1_detected;         // detected a /LI1/ sequence
  wire           lpi_2_detected;         // detected a /LI2/ sequence
  wire           config_1_detected;      // detected a /C1/ sequence
  wire           config_2_detected;      // detected a /C2/ sequence
  wire           carr_ext_detected;      // detected a /R/ sequence
  wire           sop_detected;           // detected a /S/ sequence
  wire           eop_detected;           // detected a /T/ sequence
  wire           err_prop_detected;      // detected a /V/ sequence

  // detect EOP sequences
  wire           eop_t_r;                // detected a /T/R/ sequence
  reg            prev_eop_t_r;           // detected a /T/R/ sequence previously
  wire           eop_t_r_i;              // detected a /T/R/I/ sequence
  wire           eop_t_r_r;              // detected a /T/R/R/ sequence
  reg            prev_eop_t_r_r;         // detected a /T/R/R/ sequence previously
  wire           eop_t_r_r_i;            // detected a /T/R/R/I/ sequence

  // synchronise to GEM DUT
  wire           end_of_gem_reset;       // detect when the gem_gxl is operating
  reg            end_of_gem_reset_hld;   // hold when the gem_gxl is operating
  wire           gem_out_of_reset;       // indicates the gem_gxl is operating
  reg            even_codegroup;         // K28.5 group for the I2 ordered set
  reg            frame_txed_detect;      // detecting a frame being transmitted
  wire           frame_being_txed;       // detecting a frame being transmitted

  // trigger when to begin data checking
  wire           pulse_trigger;          // pulse to trigger new frame check
  reg            synch_trigger;          // hold whilst checking data
  wire           check_expected;         // check data (not autonegotiation)
  reg            trig_from_pcs_tx;       // 1 cycle pulse for triggering other tbs

  // detect configuration cycles and check config reg value
  reg            det_config_reg_low;     // check lower 8bits of data
  reg            det_config_reg_high;    // check upper 8bits of data
  wire           det_config_reg_data;    // OR of high and low data checks
  wire           curr_control;           // control input for current 8B10B (LOW)
  wire           next_control;           // control input for next 8B10B (LOW)
  wire     [9:0] curr_encoded_value;     // output of 8B10B encoder for current
  wire     [9:0] next_encoded_value;     // output of 8B10B encoder for next
  reg      [9:0] curr_enc_low_saved;     // saved version of curr_encoded_value
  reg      [9:0] next_enc_low_saved;     // saved version of next_encoded_value
  reg      [9:0] rev_tx_low_saved;       // saved version of reversed_tx_group
  wire     [9:0] auto_neg_exp_low;       // selected 8B10B output for checking
  wire     [9:0] auto_neg_exp_high;      // selected 8B10B output for checking
  reg      [8:0] last_data_low;
  reg      [8:0] last_data_high;
  wire           next_auto_word;         // next autonegotiation value required

  wire     [7:0] actual_data;            // decode of actual data
  wire           actual_cont;            // decode of actual cont
  wire     [7:0] expected_data;          // decode of expected data
  wire           expected_cont;          // decode of expected cont
  wire     [7:0] expected_data_nxt;      // decode of expected data
  wire           expected_cont_nxt;      // decode of expected cont
  reg      [7:0] actual_data_saved;      // decode of actual data delayed
  reg            actual_cont_saved;      // decode of actual cont delayed

  // data checking failures
  reg            pcs_tx_fail;            // data checking failed

  reg            oset_transition;
  wire           bump_index_due_to_preamble_erosion;

  // Link Fault Signaling (802.3bz/802.3cb)
  reg            gtx_clk_half;           // gtx_clk at half speed
  wire           gtx_clk_half_trig;      // trigger for gtx_clk_half generation
  reg            gtx_clk_half_trig_reg;  // needed to hold the gtx_clk_half_trig to 1
  reg      [9:0] tx_group_prev;          // holds the previous value of tx_group
  reg     [19:0] tx_group_buffer_prev;   // holds the previous value of tx_group_buffer
  wire    [19:0] tx_group_buffer;        // a buffer to hold tx_group codegroups in couples
  wire           d0_0_k28_5;             // current rx_group_buffer is /D0.0/K28.5/
  wire           d0_6_k28_5;             // current rx_group_buffer is /D0.6/K28.5/
  wire           d0_7_k28_5;             // current rx_group_buffer is /D0.7/K28.5/
  wire           q_lfs_w0_detected;      // detect W0 of a Link Fault /Q/
  wire           q_lfs_w1_detected;      // detect W1 of a Link Fault /Q/
  wire           q_lfs_w2_detected;      // detect W2 of a Link Fault /Q/ (Remote Fault only)
  wire           q_lfs_w3_detected;      // detect W3 of a Link Fault /Q/
  wire           q_lfs_detection_en;     // asserted if the Link Fault /Q/ decoding process is running
  reg      [1:0] link_fault_char_count;  // count the buffered char in the /Q/ decode process
  reg      [1:0] link_fault_synch;       // synchronize link_fault to gtx_clk_half
  reg     [31:0] propagation_count;      // check the Tx path after a certain delay to give DUT time to process Rx data

  // Debugging parameter for more message info
  parameter p_pcs_debug = 1'b1;
   wire           bump_index_due_to_removal_of_r_no_cext;
   wire           bump_index_due_to_addition_of_r_in_cext;
   reg            preamble_was_eroded;

  // State here the maximum propagation_count (Link Fault) in gtx_clk_half
  // cycles
  parameter PROPAGATION_COUNT_MAX = 31'd15;

// parameters used for decoding
//-------------------------------
  // special groups
  parameter CONST_K28_0_P     = 10'h30b;
  parameter CONST_K28_0_N     = 10'h0f4;
  parameter CONST_K28_1_P     = 10'h306;
  parameter CONST_K28_1_N     = 10'h0f9;
  parameter CONST_K28_2_P     = 10'h30a;
  parameter CONST_K28_2_N     = 10'h0f5;
  parameter CONST_K28_3_P     = 10'h30c;
  parameter CONST_K28_3_N     = 10'h0f3;
  parameter CONST_K28_4_P     = 10'h30d;
  parameter CONST_K28_4_N     = 10'h0f2;
  parameter CONST_K28_5_P     = 10'h305;
  parameter CONST_K28_5_N     = 10'h0fa;
  parameter CONST_K28_6_P     = 10'h309;
  parameter CONST_K28_6_N     = 10'h0f6;
  parameter CONST_K28_7_P     = 10'h307;
  parameter CONST_K28_7_N     = 10'h0f8;
  parameter CONST_K23_7_P     = 10'h057;
  parameter CONST_K23_7_N     = 10'h3a8;
  parameter CONST_K27_7_P     = 10'h097;
  parameter CONST_K27_7_N     = 10'h368;
  parameter CONST_K29_7_P     = 10'h117;
  parameter CONST_K29_7_N     = 10'h2e8;
  parameter CONST_K30_7_P     = 10'h217;
  parameter CONST_K30_7_N     = 10'h1e8;

  // special groups (reversed)
  parameter CONST_K28_5_P_REV = 10'h283;
  parameter CONST_K28_5_N_REV = 10'h17c;
  parameter CONST_K23_7_P_REV = 10'h3a8;
  parameter CONST_K23_7_N_REV = 10'h057;

  // useful data groups
  parameter CONST_D21_5_P     = 10'h2aa;
  parameter CONST_D21_5_N     = 10'h2aa;
  parameter CONST_D2_2_P      = 10'h125;
  parameter CONST_D2_2_N      = 10'h2d5;
  parameter CONST_D5_6_P      = 10'h296;
  parameter CONST_D5_6_N      = 10'h296;
  parameter CONST_D16_2_P     = 10'h245;
  parameter CONST_D16_2_N     = 10'h1b5;
  parameter CONST_D6_5_P      = 10'h19a;
  parameter CONST_D6_5_N      = 10'h19a;
  parameter CONST_D26_4_P     = 10'h162;
  parameter CONST_D26_4_N     = 10'h16d;
  parameter CONST_D0_0_P      = 10'h18b;
  parameter CONST_D0_0_N      = 10'h274;
  parameter CONST_D0_6_P      = 10'h186;
  parameter CONST_D0_6_N      = 10'h276;
  parameter CONST_D16_6_P     = 10'h246;
  parameter CONST_D16_6_N     = 10'h1b6;
  parameter CONST_D0_7_P      = 10'h18e;
  parameter CONST_D0_7_N      = 10'h271;
  parameter CONST_D16_7_P     = 10'h24e;
  parameter CONST_D16_7_N     = 10'h1b1;

  // useful data groups (reversed)
  parameter CONST_D0_0_P_REV  = 10'h346;
  parameter CONST_D0_0_N_REV  = 10'h0b9;
  parameter CONST_D16_2_P_REV = 10'h289;
  parameter CONST_D16_2_N_REV = 10'h2b6;
  parameter CONST_D0_6_P_REV  = 10'h186;
  parameter CONST_D0_6_N_REV  = 10'h1b9;
  parameter CONST_D5_6_REV    = 10'h1a5; // (both -ve and +ve disparity)
  parameter CONST_D16_6_P_REV = 10'h189;
  parameter CONST_D16_6_N_REV = 10'h1b6;
  parameter CONST_D0_7_P_REV  = 10'h1c6;
  parameter CONST_D0_7_N_REV  = 10'h239;
  parameter CONST_D16_7_P_REV = 10'h1c9;
  parameter CONST_D16_7_N_REV = 10'h236;
//-------------------------------

// *****************************************************************************
// Initialise and decode test data array from file
// *****************************************************************************

// Initialise array
//-------------------------------
initial
   begin
      for (i=1; i<=16384; i=i+1)
         pcs_tx_vector_mem[i] = {24{1'b0}};

      $readmemh("./files/tb_pcs_tx.data", pcs_tx_vector_mem);
      if (pcs_tx_vector_mem[1] == 24'hx)
         begin
            $display("\n No pcs_tx data file read \n");
            $stop;
         end
   end
//-------------------------------


// decode current and next vectors
//-------------------------------
   assign pcs_tx_vector      = pcs_tx_vector_mem[pcs_tx_index];
   assign pcs_tx_vector_nxt  = pcs_tx_vector_mem[pcs_tx_index+1];

   assign expected_10bit     = pcs_tx_vector[9:0];
   assign expected_10bit_nxt = pcs_tx_vector_nxt[9:0];

   assign exp_cfg_reg_low       = pcs_tx_vector[15:8];
   assign exp_cfg_reg_low_nxt   = pcs_tx_vector_nxt[15:8];
   assign exp_cfg_reg_high      = pcs_tx_vector[7:0];
   assign exp_cfg_reg_high_nxt  = pcs_tx_vector_nxt[7:0];


   assign pcs_tx_ctrl      = pcs_tx_vector[22:16];
   assign pcs_tx_ctrl_nxt  = pcs_tx_vector_nxt[22:16];

   assign pcs_tx_done_nxt  = ~pcs_tx_ctrl_nxt[0];
   assign pcs_tx_done      = (auto_neg_ctrl)? ~pcs_tx_ctrl_nxt[0] :
                                              ~pcs_tx_ctrl[0];
   assign wait_for_s       = pcs_tx_ctrl[1];
   assign wait_for_s_nxt   = pcs_tx_ctrl_nxt[1];
   assign auto_neg_ctrl    = pcs_tx_ctrl[2];
   assign auto_neg_ctrl_nxt= pcs_tx_ctrl_nxt[2];
   assign trigger_ctrl     = pcs_tx_ctrl[3];
   assign trigger_ctrl_nxt = pcs_tx_ctrl_nxt[3];
   assign wait_for_apb     = pcs_tx_ctrl[4];
   assign wait_for_apb_nxt = pcs_tx_ctrl_nxt[4];
   assign wait_for_int     = pcs_tx_ctrl[5];
   assign wait_for_int_nxt = pcs_tx_ctrl_nxt[5];
   assign reset_ctrl       = pcs_tx_ctrl[6];
   assign reset_ctrl_nxt   = pcs_tx_ctrl_nxt[6];
//-------------------------------


// Generate the index to the array
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      pcs_tx_index <= 1;

   // if all checking done then maintain value
   else if (pcs_tx_done)
      pcs_tx_index <= pcs_tx_index;

   // if checking frame data increment every clock cycle
   else if (synch_trigger & ~auto_neg_ctrl)
      begin
         if (bump_index_due_to_addition_of_r_in_cext)
            pcs_tx_index <= pcs_tx_index;
         else if ((bump_index_due_to_preamble_erosion || bump_index_due_to_removal_of_r_no_cext) &&
                  (expected_data_nxt == actual_data && expected_cont_nxt == actual_cont))
            pcs_tx_index <= pcs_tx_index + 2;
         else
            pcs_tx_index <= pcs_tx_index + 1;
      end

   // Detect special case of autonegotiation complete and next is going to
   // be a SOP detected of a transmitted frame. Add 2 in this case.
   else if (pulse_trigger & wait_for_s_nxt & sop_detected & auto_neg_ctrl)
      pcs_tx_index <= pcs_tx_index + 2;

   // if been waiting for SOP increment to check first data
   else if (pulse_trigger & wait_for_s)
      pcs_tx_index <= pcs_tx_index + 1;

   // if doing autonegotiation checking then only increment on next_auto_word
   else if (next_auto_word & auto_neg_ctrl)
      pcs_tx_index <= pcs_tx_index + 1;
//-------------------------------



// *****************************************************************************
// Detect triggers from APB and interrupts
// *****************************************************************************

// latch apb_trig trigger
always @(posedge apb_trig or posedge apb_trigger_det or negedge reset_tb)
   if (~reset_tb | apb_trigger_det)
      apb_trigger_lat = 1'b0;
   else if (apb_trig)
      apb_trigger_lat = 1'b1;


// latch int_pulse trigger
always @(posedge int_pulse or posedge int_trigger_det or negedge reset_tb)
   if (~reset_tb | int_trigger_det)
      int_trigger_lat = 1'b0;
   else if (int_pulse)
      int_trigger_lat = 1'b1;


// synch into gtx_clk domain
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      begin
         apb_trigger_det <= 1'b0;
         int_trigger_det <= 1'b0;
      end
   else
      begin
         apb_trigger_det <= apb_trigger_lat;
         int_trigger_det <= int_trigger_lat;
      end



// *****************************************************************************
// Decode incoming data and recognise main code group types
// *****************************************************************************


// Invert the incomming codegroup to prepare for comparison
//-------------------------------
always @(tx_group)
   for (i=0; i<=9; i=i+1)
      reversed_tx_group[i] <= tx_group[9-i];
//-------------------------------
//-------------------------------
always @(*)
begin
   for (i=0; i<=9; i=i+1)
      rev_expected_10bit[i] <= expected_10bit[9-i];
   for (i=0; i<=9; i=i+1)
      rev_expected_10bit_nxt[i] <= expected_10bit_nxt[9-i];
end
//-------------------------------


// Detect special code groups
//-------------------------------
assign k28_0_p = (reversed_tx_group == CONST_K28_0_P);
assign k28_0_n = (reversed_tx_group == CONST_K28_0_N);

assign k28_1_p = (reversed_tx_group == CONST_K28_1_P);
assign k28_1_n = (reversed_tx_group == CONST_K28_1_N);

assign k28_2_p = (reversed_tx_group == CONST_K28_2_P);
assign k28_2_n = (reversed_tx_group == CONST_K28_2_N);

assign k28_3_p = (reversed_tx_group == CONST_K28_3_P);
assign k28_3_n = (reversed_tx_group == CONST_K28_3_N);

assign k28_4_p = (reversed_tx_group == CONST_K28_4_P);
assign k28_4_n = (reversed_tx_group == CONST_K28_4_N);

assign k28_5_p = (reversed_tx_group == CONST_K28_5_P);
assign k28_5_n = (reversed_tx_group == CONST_K28_5_N);

assign k28_6_p = (reversed_tx_group == CONST_K28_6_P);
assign k28_6_n = (reversed_tx_group == CONST_K28_6_N);

assign k28_7_p = (reversed_tx_group == CONST_K28_7_P);
assign k28_7_n = (reversed_tx_group == CONST_K28_7_N);

assign k23_7_p = (reversed_tx_group == CONST_K23_7_P);
assign k23_7_n = (reversed_tx_group == CONST_K23_7_N);

assign k27_7_p = (reversed_tx_group == CONST_K27_7_P);
assign k27_7_n = (reversed_tx_group == CONST_K27_7_N);

assign k29_7_p = (reversed_tx_group == CONST_K29_7_P);
assign k29_7_n = (reversed_tx_group == CONST_K29_7_N);

assign k30_7_p = (reversed_tx_group == CONST_K30_7_P);
assign k30_7_n = (reversed_tx_group == CONST_K30_7_N);
//-------------------------------


// hold previous code special groups
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      begin
         prev_k28_0_p <= 1'b0;
         prev_k28_0_n <= 1'b0;
         prev_k28_1_p <= 1'b0;
         prev_k28_1_n <= 1'b0;
         prev_k28_2_p <= 1'b0;
         prev_k28_2_n <= 1'b0;
         prev_k28_3_p <= 1'b0;
         prev_k28_3_n <= 1'b0;
         prev_k28_4_p <= 1'b0;
         prev_k28_4_n <= 1'b0;
         prev_k28_5_p <= 1'b0;
         prev_k28_5_n <= 1'b0;
         prev_k28_6_p <= 1'b0;
         prev_k28_6_n <= 1'b0;
         prev_k28_7_p <= 1'b0;
         prev_k28_7_n <= 1'b0;
         prev_k23_7_p <= 1'b0;
         prev_k23_7_n <= 1'b0;
         prev_k27_7_p <= 1'b0;
         prev_k27_7_n <= 1'b0;
         prev_k29_7_p <= 1'b0;
         prev_k29_7_n <= 1'b0;
         prev_k30_7_p <= 1'b0;
         prev_k30_7_n <= 1'b0;
      end
   else
      begin
         prev_k28_0_p <= k28_0_p;
         prev_k28_0_n <= k28_0_n;
         prev_k28_1_p <= k28_1_p;
         prev_k28_1_n <= k28_1_n;
         prev_k28_2_p <= k28_2_p;
         prev_k28_2_n <= k28_2_n;
         prev_k28_3_p <= k28_3_p;
         prev_k28_3_n <= k28_3_n;
         prev_k28_4_p <= k28_4_p;
         prev_k28_4_n <= k28_4_n;
         prev_k28_5_p <= k28_5_p;
         prev_k28_5_n <= k28_5_n;
         prev_k28_6_p <= k28_6_p;
         prev_k28_6_n <= k28_6_n;
         prev_k28_7_p <= k28_7_p;
         prev_k28_7_n <= k28_7_n;
         prev_k23_7_p <= k23_7_p;
         prev_k23_7_n <= k23_7_n;
         prev_k27_7_p <= k27_7_p;
         prev_k27_7_n <= k27_7_n;
         prev_k29_7_p <= k29_7_p;
         prev_k29_7_n <= k29_7_n;
         prev_k30_7_p <= k30_7_p;
         prev_k30_7_n <= k30_7_n;
      end
//-------------------------------


// Detect useful data code groups
//-------------------------------
assign d21_5_p = (reversed_tx_group == CONST_D21_5_P);
assign d21_5_n = (reversed_tx_group == CONST_D21_5_N);

assign d2_2_p  = (reversed_tx_group == CONST_D2_2_P);
assign d2_2_n  = (reversed_tx_group == CONST_D2_2_N);

assign d5_6_p  = (reversed_tx_group == CONST_D5_6_P);
assign d5_6_n  = (reversed_tx_group == CONST_D5_6_N);

assign d16_2_p = (reversed_tx_group == CONST_D16_2_P);
assign d16_2_n = (reversed_tx_group == CONST_D16_2_N);

assign d6_5_p  = (reversed_tx_group == CONST_D6_5_P);
assign d6_5_n  = (reversed_tx_group == CONST_D6_5_N);

assign d26_4_p = (reversed_tx_group == CONST_D26_4_P);
assign d26_4_n = (reversed_tx_group == CONST_D26_4_N);

assign d0_0_p  = (reversed_tx_group == CONST_D0_0_P);
assign d0_0_n  = (reversed_tx_group == CONST_D0_0_N);

assign d0_6_p  = (reversed_tx_group == CONST_D0_6_P);
assign d0_6_n  = (reversed_tx_group == CONST_D0_6_N);

assign d16_6_p = (reversed_tx_group == CONST_D16_6_P);
assign d16_6_n = (reversed_tx_group == CONST_D16_6_N);

assign d0_7_p  = (reversed_tx_group == CONST_D0_7_P);
assign d0_7_n  = (reversed_tx_group == CONST_D0_7_N);

assign d16_7_p = (reversed_tx_group == CONST_D16_7_P);
assign d16_7_n = (reversed_tx_group == CONST_D16_7_N);
//-------------------------------



// *****************************************************************************
// Keep track of running disparity from DUT
// *****************************************************************************

// count number of one's in 6 bit group
//-------------------------------
always @(reversed_tx_group)
begin
   ones_number_6 = 0;
   for (k=4;k<10;k=k+1)
      ones_number_6 = ones_number_6 + reversed_tx_group[k];
end
//-------------------------------


// count number of one's in 4 bit group
//-------------------------------
always @(reversed_tx_group)
begin
   ones_number_4 = 0;
   for (j=0;j<4;j=j+1)
      ones_number_4 = ones_number_4 + reversed_tx_group[j];
end
//-------------------------------


// new disparity from 6 bit group
//-------------------------------
always @(ones_number_6 or running_disparity)
begin
   if (ones_number_6 < 3)
      new_disparity_6 = 1'b0;
   else if (ones_number_6 > 3)
      new_disparity_6 = 1'b1;
   else
      new_disparity_6 = running_disparity;
end
//-------------------------------


// new disparity from 4 bit group
//-------------------------------
always @(ones_number_4 or new_disparity_6)
begin
   if (ones_number_4 < 2)
      new_disparity_4 = 1'b0;
   else if (ones_number_4 > 2)
      new_disparity_4 = 1'b1;
   else
      new_disparity_4 = new_disparity_6;
end
//-------------------------------


// maintain a running disparity
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      running_disparity <= 1'b0;
   else
      running_disparity <= new_disparity_4;
//-------------------------------



// *****************************************************************************
// Detect ordered sets
// *****************************************************************************

// Detect /I1/ ordered set
// Check for K28.5 followed by D5.6
//-------------------------------
assign idle_1_detected = gem_out_of_reset &
                              ((prev_k28_5_p & d5_6_n & ~running_disparity) |
                               (prev_k28_5_n & d5_6_p &  running_disparity));
//-------------------------------


// Detect I2 ordered set
// Check for K28.5 followed by D16.2
//-------------------------------
assign idle_2_detected = gem_out_of_reset &
                              ((prev_k28_5_p & d16_2_n & ~running_disparity) |
                               (prev_k28_5_n & d16_2_p &  running_disparity));

// Detect Seq ordered set
// Check for K28.5 followed by D16.2
//-------------------------------
assign seq_os_detected = gem_out_of_reset &
                              ((prev_k28_5_p||prev_k28_5_n) & !actual_cont &
                                !d5_6_n & !d5_6_p & !d16_2_n & !d16_2_p & !d6_5_n & !d6_5_p & !d26_4_n & !d26_4_p);
//-------------------------------

// Detect /LI1/ ordered set
// Check for K28.5 followed by D6.5
//-------------------------------
assign lpi_1_detected = gem_out_of_reset &
                              ((prev_k28_5_p & d6_5_n & ~running_disparity) |
                               (prev_k28_5_n & d6_5_p &  running_disparity));
//-------------------------------


// Detect LI2 ordered set
// Check for K28.5 followed by D26.4
//-------------------------------
assign lpi_2_detected = gem_out_of_reset &
                              ((prev_k28_5_p & d26_4_n & ~running_disparity) |
                               (prev_k28_5_n & d26_4_p &  running_disparity));
//-------------------------------

// detect /C1/ config cycles
//-------------------------------
assign config_1_detected = gem_out_of_reset &
                              ((prev_k28_5_p & d21_5_n & ~running_disparity) |
                               (prev_k28_5_n & d21_5_p &  running_disparity));
//-------------------------------


// detect /C2/ config cycles
//-------------------------------
assign config_2_detected = gem_out_of_reset &
                              ((prev_k28_5_p & d2_2_n & ~running_disparity) |
                               (prev_k28_5_n & d2_2_p &  running_disparity));
//-------------------------------


// detect Encapsulation
//-------------------------------
assign carr_ext_detected = gem_out_of_reset & ((k23_7_p &  running_disparity) |
                                               (k23_7_n & ~running_disparity));

assign sop_detected      = gem_out_of_reset & ((k27_7_p &  running_disparity) |
                                               (k27_7_n & ~running_disparity));

assign eop_detected      = gem_out_of_reset & ((k29_7_p &  running_disparity) |
                                               (k29_7_n & ~running_disparity));

assign err_prop_detected = gem_out_of_reset & ((k30_7_p &  running_disparity) |
                                               (k30_7_n & ~running_disparity));
//-------------------------------


// detect end of packet delimiter sequences
//-------------------------------
assign eop_t_r     = gem_out_of_reset & carr_ext_detected & (prev_k29_7_p | prev_k29_7_n);
assign eop_t_r_r   = prev_eop_t_r & carr_ext_detected;
assign eop_t_r_i   = prev_eop_t_r & (k28_5_p | k28_5_n);
assign eop_t_r_r_i = prev_eop_t_r_r & (k28_5_p | k28_5_n);

always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      begin
         prev_eop_t_r   <= 1'b0;
         prev_eop_t_r_r <= 1'b0;
      end
   else
      begin
         prev_eop_t_r   <= eop_t_r;
         prev_eop_t_r_r <= eop_t_r_r;
      end
//-------------------------------


// *****************************************************************************
// synchronise with GEM design
// *****************************************************************************


// Detect when the gem_gxl is out of reset.
// While in reset state, the pcs send /R/ symbol with neutral output disparity,
// represented by one only codegroup with octet value F7 and encoded as for
// negative input disparity. When out of reset, the first codegroup corresponds
// to K28.5 for negative input disparity. /I2/ ordered sets follow
// When reset_ctrl trigger is seen as next_auto_word is requested, then we
// should be seeing a PCS reset
//-------------------------------

assign end_of_gem_reset = ~end_of_gem_reset_hld & k28_5_n;

always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      end_of_gem_reset_hld <= 1'b0;
   else if (end_of_gem_reset)
      end_of_gem_reset_hld <= 1'b1;
   else if (next_auto_word & auto_neg_ctrl & reset_ctrl)
      end_of_gem_reset_hld <= 1'b0;

assign gem_out_of_reset = end_of_gem_reset |
                          (end_of_gem_reset_hld &
                           ~(next_auto_word & auto_neg_ctrl & reset_ctrl));
//-------------------------------


// Determine when the transmitted codegroup is even aligned. This is
// used during checks for idle 2
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
     begin
      even_codegroup <= 1'b1;
     end
   else if (~gem_out_of_reset)
      even_codegroup <= 1'b1;

   // if detect a K28.5, then next group must be an odd code group
   else if ((k28_5_p &  running_disparity) |
            (k28_5_n & ~running_disparity))
      even_codegroup <= 1'b0;

   // otherwise toggle between odd and even
   else
     begin
      even_codegroup <= ~even_codegroup;   // toggle b/n even and odd
     end
//-------------------------------


// Detect frame limits
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      frame_txed_detect <= 1'b0;
   else if (eop_t_r_i | eop_t_r_r_i)
      frame_txed_detect <= 1'b0;
   else if (sop_detected)
      frame_txed_detect <= 1'b1;

assign frame_being_txed = sop_detected  | frame_txed_detect;
//-------------------------------



// *****************************************************************************
// Control triggering of checking against array data
// *****************************************************************************

// Generate a pulse for triggering comparison against the test vectors
// This pulse is registerred for the duration of a packet comprised of
// individual codegroups in each test vector
//-------------------------------
   assign pulse_trigger = gem_out_of_reset &
        ((wait_for_s & sop_detected) | // /S/ RD+/-
         (wait_for_s_nxt & sop_detected & auto_neg_ctrl) | // /S/ RD+/-
         (wait_for_apb & apb_trigger_det) |
         (wait_for_int & int_trigger_det));
//-------------------------------


// Generate a trigger for reading a frame
//-------------------------------
always @(negedge reset_tb or posedge gtx_clk)
   if (~reset_tb)
      synch_trigger <= 1'b0;
   else if (pulse_trigger)
      synch_trigger <= 1'b1;
   else if (pcs_tx_done_nxt | wait_for_s_nxt |
            wait_for_apb_nxt | wait_for_int_nxt)
      synch_trigger <= 1'b0;
//-------------------------------


// Determine when to do checking of frame data
//-------------------------------
assign check_expected = synch_trigger | pulse_trigger;
//-------------------------------


// generate one cycle pulse for triggering another transactor
// if the next test vector control group is requiring so
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      trig_from_pcs_tx <= 1'b0;
   else if ((synch_trigger & trigger_ctrl) |
            (det_config_reg_data & next_auto_word & trigger_ctrl_nxt))
      trig_from_pcs_tx <= 1'b1;
   else
      trig_from_pcs_tx <= 1'b0;
//-------------------------------



// *****************************************************************************
// Autonegotiation expected code group generation
// *****************************************************************************

// Detect configuration cycles and indicate when config_reg[7:0] & [15:8]
// should be checked
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      begin
         det_config_reg_low  <= 1'b0;
         det_config_reg_high <= 1'b0;
      end
   else if (config_1_detected | config_2_detected)
      begin
         det_config_reg_low  <= 1'b1;
         det_config_reg_high <= 1'b0;
      end
   else if (det_config_reg_low)
      begin
         det_config_reg_low  <= 1'b0;
         det_config_reg_high <= 1'b1;
      end
   else
      begin
         det_config_reg_low  <= 1'b0;
         det_config_reg_high <= 1'b0;
      end


assign det_config_reg_data = det_config_reg_low | det_config_reg_high;
//-------------------------------


// Only ever detecting data during autonegotiation so tie off
// control inputs to decoder
//-------------------------------
assign curr_control = 1'b0;
assign next_control = 1'b0;
//-------------------------------


// Select which expected data to send to encoders (current and next)
//-------------------------------

// current value
always @(det_config_reg_low or exp_cfg_reg_low or exp_cfg_reg_high)
   if (det_config_reg_low)
      exp_cfg_reg = exp_cfg_reg_low;
   else
      exp_cfg_reg = exp_cfg_reg_high;

// next value
always @(det_config_reg_low or exp_cfg_reg_low_nxt or exp_cfg_reg_high_nxt)
   if (det_config_reg_low)
      exp_cfg_reg_nxt = exp_cfg_reg_low_nxt;
   else
      exp_cfg_reg_nxt = exp_cfg_reg_high_nxt;
//-------------------------------



// Encode current expected byte to ten bit group
//-------------------------------
tb_8b10b_enc i_tb_8b10b_enc_curr (
   .control           (curr_control),
   .octet_value_in    (exp_cfg_reg),
   .running_disparity (running_disparity),
   .encoded_value     (curr_encoded_value)
   );
//-------------------------------


// Encode next expected byte to ten bit group
//-------------------------------
tb_8b10b_enc i_tb_8b10b_enc_next (
   .control           (next_control),
   .octet_value_in    (exp_cfg_reg_nxt),
   .running_disparity (running_disparity),
   .encoded_value     (next_encoded_value)
   );
//-------------------------------


// save config register low data and use for comparison of full 16bits once
// upper byte received.
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)
   if (~reset_tb)
      begin
         curr_enc_low_saved <= 10'b0;
         next_enc_low_saved <= 10'b0;
         rev_tx_low_saved   <= 10'b0;
         actual_data_saved  <= 8'b0;
         actual_cont_saved  <= 1'b0;
      end
   else if (det_config_reg_low)
      begin
         curr_enc_low_saved <= curr_encoded_value;
         next_enc_low_saved <= next_encoded_value;
         rev_tx_low_saved   <= reversed_tx_group;
         actual_data_saved  <= actual_data;
         actual_cont_saved  <= actual_cont;
      end
//-------------------------------


// Increment to next word when data does not match current expected
// do comparison of full 16 bits in one go.
//-------------------------------
assign next_auto_word = ((reversed_tx_group !== curr_encoded_value) |
                         (rev_tx_low_saved !== curr_enc_low_saved)) &
                        auto_neg_ctrl & det_config_reg_high;
//-------------------------------


// If data doesn't match current expected move onto checking next
//-------------------------------
assign auto_neg_exp_low = (next_auto_word) ? next_enc_low_saved:
                                             curr_enc_low_saved;

assign auto_neg_exp_high = (next_auto_word) ? next_encoded_value:
                                              curr_encoded_value;
//-------------------------------


// *****************************************************************************
// Logic for Link Fault Signaling (802.3bz/802.3cb).
// Check whether the DUT correctly transmits Remote Fault /Q/ or IDLEs in
// response to the Link Fault status indicator, as specified by the LFSM
// behavior (IEEE 802.3 clause 46.3.4.3).
// *****************************************************************************

// Create a trigger for gtx_clk_half when the PCS is enabled and tx_group goes
// from K23.7 (reset) to K28.5
always @(posedge gtx_clk or negedge reset_tb) begin
  if (~reset_tb) begin
    gtx_clk_half_trig_reg   <= 1'b0;
  end else begin
    if (tx_group_prev == CONST_K23_7_N_REV && tx_group == CONST_K28_5_N_REV) begin
      gtx_clk_half_trig_reg <= 1'b1;
    end
  end
end
assign gtx_clk_half_trig = (tx_group_prev == CONST_K23_7_N_REV && tx_group == CONST_K28_5_N_REV) || gtx_clk_half_trig_reg;

// Create gtx_clk_half
always @(posedge gtx_clk or negedge reset_tb) begin
  if (~reset_tb) begin
    gtx_clk_half   <= 1'b0;
  end else begin
    if (~gtx_clk_half_trig) begin
      gtx_clk_half <= 1'b0;
    end else begin
      gtx_clk_half <= gtx_clk_half + 1'b1;
    end
  end
end

// Hold previous values of tx_group and tx_group_buffer
always @(posedge gtx_clk or negedge reset_tb) begin
  if (~reset_tb) begin
    tx_group_prev        <= 10'h0;
    tx_group_buffer_prev <= 20'h0;
  end else begin
    tx_group_prev        <= tx_group;
    tx_group_buffer_prev <= tx_group_buffer;
  end
end

// Assign rx_group_buffer on the posedge of gtx_clk_half
assign tx_group_buffer = (gtx_clk_half == 1'b1) ? {tx_group, tx_group_prev} : tx_group_buffer_prev;

// Detect useful code group couples
assign d0_0_k28_5  =  (tx_group_buffer == {CONST_D0_0_P_REV , CONST_K28_5_N_REV} ||
                       tx_group_buffer == {CONST_D0_0_N_REV , CONST_K28_5_P_REV});
assign d0_6_k28_5  =  (tx_group_buffer == {CONST_D0_6_P_REV , CONST_K28_5_N_REV} ||
                       tx_group_buffer == {CONST_D0_6_N_REV , CONST_K28_5_P_REV});
assign d0_7_k28_5  =  (tx_group_buffer == {CONST_D0_7_P_REV , CONST_K28_5_N_REV} ||
                       tx_group_buffer == {CONST_D0_7_N_REV , CONST_K28_5_P_REV});
assign d5_6_k28_5  =  (tx_group_buffer == {CONST_D5_6_REV   , CONST_K28_5_N_REV} ||
                       tx_group_buffer == {CONST_D5_6_REV   , CONST_K28_5_P_REV});
assign d16_2_k28_5 =  (tx_group_buffer == {CONST_D16_2_P_REV, CONST_K28_5_N_REV} ||
                       tx_group_buffer == {CONST_D16_2_N_REV, CONST_K28_5_P_REV});

// Detect a D0.0 data character on W0
assign q_lfs_w0_detected = d0_0_k28_5 && (link_fault_char_count == 3'h0);

// Detect a D0.6 data character on W1
assign q_lfs_w1_detected = d0_6_k28_5 && (link_fault_char_count == 3'h1);

// Detect a D0.7 data character on W2 (Remote Fault)
assign q_lfs_w2_detected = d0_7_k28_5 && (link_fault_char_count == 3'h2);

// Detect a D0.0 data character on W3
assign q_lfs_w3_detected = d0_0_k28_5 && (link_fault_char_count == 3'h3);

// While the /Q/ detection is in place this signal is high
assign q_lfs_detection_en = q_lfs_w0_detected ||
                            q_lfs_w1_detected ||
                            q_lfs_w2_detected ||
                            q_lfs_w3_detected;

// Detect a Remote Fault /Q/ ordered set
always @(posedge gtx_clk_half or negedge reset_tb) begin
  if (~reset_tb) begin
    link_fault_char_count <= 2'b00;
  end else begin
    if (q_lfs_w0_detected || q_lfs_w1_detected || q_lfs_w2_detected) begin
      link_fault_char_count <= link_fault_char_count + 2'b01;
    end else begin
      link_fault_char_count <= 2'b00;
    end
  end
end

// Synchronize link_fault to gtx_clk_half and hold the previous value
always @(posedge gtx_clk_half or negedge reset_tb) begin
  if (~reset_tb) begin
    link_fault_synch <= 2'b00;
  end else begin
    link_fault_synch <= link_fault;
  end
end

// Make the propagation_count counting (reset count each time link_fault
// changes)
always @(posedge gtx_clk_half or negedge reset_tb) begin
  if (~reset_tb) begin
    propagation_count   <= 31'd0;
  end else begin
    if (link_fault != link_fault_synch) begin // link_fault change
      propagation_count <= 31'd0;
    end else begin
      propagation_count <= propagation_count + 31'd1;
    end
  end
end

// Check that the correct PCS Tx output is issued based on the Link Fault status
// indicator
always @(posedge gtx_clk_half or negedge reset_tb) begin
  if (~reset_tb) begin
    pcs_tx_fail <= 1'b0;
  end else begin
    if (link_fault_sig_en && (propagation_count > PROPAGATION_COUNT_MAX)) begin
      if (link_fault_synch == 2'b01 && !q_lfs_detection_en) begin
        $display("***** Error [tb_pcs_tx]: PCS Tx stopped issuing Remote Fault while Link is in Local Fault - @time %0.2f ns",
          $realtime/10);
        $display("        propagation_count = %0d | link_fault_synch = %d | tx_group_buffer[19:10] = 0x%0h | tx_group_buffer[9:0] = 0x%0h",
          propagation_count, link_fault_synch, tx_group_buffer[19:10], tx_group_buffer[9:0]);
        pcs_tx_fail <= 1'b1;
      end else if (link_fault_synch == 2'b10 && !(d16_2_k28_5 || d5_6_k28_5)) begin
        $display("***** Error [tb_pcs_tx]: detected something other than /I1/ or /I2/ on PCS Tx while Link is in Remote Fault - @time %0.2f ns",
          $realtime/10);
        $display("        propagation_count = %0d | link_fault_synch = %d | tx_group_buffer[19:10] = 0x%0h | tx_group_buffer[9:0] = 0x%0h",
          propagation_count, link_fault_synch, tx_group_buffer[19:10], tx_group_buffer[9:0]);
        pcs_tx_fail <= 1'b1;
      end else if (link_fault_synch == 2'b11 && !(d16_2_k28_5 || d5_6_k28_5)) begin
        $display("***** Error [tb_pcs_tx]: detected something other than /I1/ or /I2/ on PCS Tx while Link is in Link Interruption - @time %0.2f ns",
          $realtime/10);
        $display("        propagation_count = %0d | link_fault_synch = %d | tx_group_buffer[19:10] = 0x%0h | tx_group_buffer[9:0] = 0x%0h",
          propagation_count, link_fault_synch, tx_group_buffer[19:10], tx_group_buffer[9:0]);
        pcs_tx_fail <= 1'b1;
      end
    end
  end
end
//-------------------------------


// *****************************************************************************
// check tx_group against expected array data.
// (10-bit data taken straight from array)
// *****************************************************************************

   tb_8b10b_dec i_decoder_tx_tb(
      .clk(~gtx_clk),
      .n_reset(reset_tb),
      .din(tx_group),
      .dataout(actual_data),
      .control(actual_cont)
      );

   tb_8b10b_dec i_decoder_tx_tb2(
      .clk(~gtx_clk),
      .n_reset(reset_tb),
      .din(rev_expected_10bit),
      .dataout(expected_data),
      .control(expected_cont)
      );

   tb_8b10b_dec i_decoder_tx_tb3(
      .clk(~gtx_clk),
      .n_reset(reset_tb),
      .din(rev_expected_10bit_nxt),
      .dataout(expected_data_nxt),
      .control(expected_cont_nxt)
      );

reg [23:0] control_field;
always @(actual_cont or actual_data)
begin
  if (actual_cont == 1'b1)
     begin
        if (actual_data == 8'hfb)
          control_field = "sop";
        else if (actual_data == 8'hfb)
          control_field = "eop";
        else if (actual_data == 8'hfe)
          control_field = "err";
        else if (actual_data == 8'hf7)
          control_field = "cex";
        else if (actual_data == 8'hbc)
          control_field = "com";
        else
          control_field = "   ";
      end
   else
     control_field = "   ";
end

// bump index if the GEM has deleted a preamble.
// Also need to bump idex at the end of the frame during cext if preamble was eroded earlier in the frame
assign bump_index_due_to_preamble_erosion       = (expected_data == 8'h55 && expected_cont == 1'b0 && expected_data_nxt == 8'hd5 && expected_cont_nxt == 1'b0 && actual_data == 8'hd5 && actual_cont == 1'b0);
assign bump_index_due_to_removal_of_r_no_cext   = (preamble_was_eroded && expected_data == 8'hf7 && expected_cont == 1'b1 && !(expected_data_nxt == 8'hf7 && expected_cont_nxt == 1'b1) && !(actual_data == 8'hf7 && actual_cont == 1'b1));
assign bump_index_due_to_addition_of_r_in_cext  = (preamble_was_eroded && expected_data == 8'hbc && expected_cont == 1'b1 && actual_data == 8'hf7 && actual_cont == 1'b1);


// Check the tx_group input
//-------------------------------
always @(posedge gtx_clk or negedge reset_tb)

   // system reset
   if (~reset_tb)
     begin
      pcs_tx_fail <= 1'b0;
      oset_transition <= 1'b0;
      preamble_was_eroded <= 1'b0;
     end

   // System out of reset and tbi enabled, but PCS hasn't started yet.
   // GEM should send out /R/ RD- (3A8)
   else if (tbi & ~gem_out_of_reset)
     begin
      if (~k23_7_n)        // /R/ RD-
        begin
         $display("Invalid tx_codegroup detected while gem_gxl is in reset");
         $display("***** Bad pcs_txd!    Expected: /R/ 3A8    Got: %h   %h %h",
                   reversed_tx_group, actual_data, actual_cont);
         pcs_tx_fail <= 1'b1;
        end
     end

   // GEM up and running, no frame being txed and not autonegotiation.
   // should only see /I1/ and /I2/ and /LI1/ and /LI2/ and /K28.5/Wx/ (/Q/).
   else if (tbi & gem_out_of_reset & ~frame_being_txed & ~auto_neg_ctrl)
     begin
      if (
          ~((even_codegroup & (k28_5_p | k28_5_n)) | // K28.5 RD+/-
           (~even_codegroup & idle_2_detected)     | // D16.2 RD+/-
           (~even_codegroup & idle_1_detected)     | // D5.6 RD+/-
           (~even_codegroup & lpi_2_detected)      | // D26.4 RD+/-
           (~even_codegroup & lpi_1_detected)      | // D6.5 RD+/-
           (                  q_lfs_w0_detected)   | // /K28.5/D0.0/ on W0
           (                  q_lfs_w1_detected)   | // /K28.5/D0.6/ on W1
           (                  q_lfs_w2_detected)   | // /K28.5/D0.7/ on W2
           (                  q_lfs_w3_detected))    // /K28.5/D0.0/ on W3
         )
        begin
         $display("Invalid even tx_codegroup detected while gem_gxl is in Idle, Time = %0dns",$time);
         $display("***** Bad pcs_txd!    Expected: /I1/ or /I2/ or /LI1/ or /LI2/ or /Q/ (RF)   Got: %h   %h %h",
                   reversed_tx_group, actual_data, actual_cont);
         pcs_tx_fail <= 1'b1;
        end
     end

   // GEM up and running, no frame being txed but autonegotiation active
   // should only see /I1/ or /I2/ or /C1/ or /C2/. Configuration register data
   // is checked below.
   else if (tbi & gem_out_of_reset & ~frame_being_txed & auto_neg_ctrl &
            ~det_config_reg_data)
     begin
      if (
         ~((even_codegroup & (k28_5_p | k28_5_n)) | // K28.5 RD+/-
           (~even_codegroup & idle_2_detected) |    // D16.2 RD+/-
           (~even_codegroup & idle_1_detected) |    // D5.6 RD+/-
           (~even_codegroup & config_1_detected) |  //
           (~even_codegroup & config_2_detected))   //
         )
        begin
         $display("Invalid even tx_codegroup detected while gem_gxl is in autonegotiation");
         $display("***** Bad pcs_txd!    Expected: /I1/ or /I2/ or /C1/ or /C2/   Got: %h   %h %h",
                   reversed_tx_group, actual_data, actual_cont);
         pcs_tx_fail <= 1'b1;
        end
     end

   // frame being txed so check against expecetd 10bit codes from test array.
   // Note the GEM can delete a byte of preamble to align itself.
   // This is allowed, so we need to check for it ..
   else if (tbi & gem_out_of_reset & check_expected & ~auto_neg_ctrl)
     begin
      if (k28_5_p | k28_5_n)
        preamble_was_eroded <= 1'b0;
      else if (bump_index_due_to_removal_of_r_no_cext || bump_index_due_to_addition_of_r_in_cext)
        preamble_was_eroded <= 1'b0;
      else if (bump_index_due_to_preamble_erosion)
        preamble_was_eroded <= 1'b1;

      if (bump_index_due_to_removal_of_r_no_cext)
        $display("     The GEM appears to have deleted an F7 cext byte to maintain alignment - OK, this is allowed once as we previously deleted a preamble byte  ..");
      else if (bump_index_due_to_addition_of_r_in_cext)
        $display("     The GEM appears to have added an F7 cext byte to maintain alignment - OK, this is allowed once as we previously deleted a preamble byte ..");
      else if (bump_index_due_to_preamble_erosion)
        $display("     The GEM appears to have deleted a preamble - OK, this is allowed ..");
      else if (reversed_tx_group !== expected_10bit)
        begin
         $display("Invalid even tx_codegroup detected during frame or CExt");
     //    $display("***** Bad pcs_txd!    Expected: %h    Got: %h   %h %h", expected_10bit, reversed_tx_group, actual_data, actual_cont);
         $display("***** Bad pcs_txd!    Expected: %h   (%h)   Got: %h   (%h %h) %s", expected_data, expected_10bit, actual_data, actual_cont, reversed_tx_group, control_field);
         pcs_tx_fail <= 1'b1;
        end
      else
        begin
         $display("     Good pcs_txd!    Expected: %h   (%h)   Got: %h   (%h %h) %s", expected_data, expected_10bit, actual_data, actual_cont, reversed_tx_group, control_field);
        end
     end

   // autonegotiation active so compare configuration register data to
   // encoded upper and lower 8 bits from array.
   else if (tbi & gem_out_of_reset & auto_neg_ctrl & det_config_reg_high)
     begin
      // If the GEM is just transitioning into sending config ordered sets, it is possible that the lower byte might transition before the upper byte
      // meaning there might be a miscomparison on the upper byte.
      // EG. if we were transmitting 0x0000 config ordered sets, then transitioned to sending 0x0140, we might see a single step where it goes
      // 0x0000 -> 0x0040 -> 0x0140
      // This is very dependent on GEM configuration and timing, so we should add the capability to this testbench to detect this and allow the transition
      if ((rev_tx_low_saved !== auto_neg_exp_low) && (reversed_tx_group == auto_neg_exp_high) && (last_data_low == {actual_cont_saved,actual_data_saved}) && (last_data_high !== {actual_cont,actual_data}) && !oset_transition)
        begin
          $display("   The GEM appears to be transitioning into a new config ordered set - ingoring the transition... Got %h",{actual_data,actual_data_saved});
          oset_transition <= 1'b1;
        end
      else if ((rev_tx_low_saved !== auto_neg_exp_low) || (reversed_tx_group !== auto_neg_exp_high))
        begin
         $display("Invalid configuration register data received, Expected %h Got %h", {exp_cfg_reg_high_nxt, exp_cfg_reg_low_nxt},{actual_data,actual_data_saved});
         $display("***** Bad pcs_an_tx!    Expected: %h    Got: %h   %h %h at time %d",
                   auto_neg_exp_low, rev_tx_low_saved, actual_data_saved, actual_cont_saved, $time);
         $display("***** Bad pcs_an_tx!    Expected: %h    Got: %h   %h %h at time %d",
                   auto_neg_exp_high, reversed_tx_group, actual_data, actual_cont, $time);
         pcs_tx_fail <= 1'b1;
        end
      else
        begin
          if ((last_data_low !== {actual_cont_saved,actual_data_saved}) || (last_data_high !== {actual_cont,actual_data}))
          begin
             if (p_pcs_debug) $display("     Good pcs_an_tx!    Expected: %h     Got: %h   %h %h", auto_neg_exp_low, rev_tx_low_saved, actual_data_saved, actual_cont_saved);
             if (p_pcs_debug) $display("     Good pcs_an_tx!    Expected: %h     Got: %h   %h %h", auto_neg_exp_high, reversed_tx_group, actual_data, actual_cont);
             last_data_low   <= {actual_cont_saved,actual_data_saved};
             last_data_high  <= {actual_cont,actual_data};
             oset_transition <= 1'b0;
          end
        end
     end

   else
     begin
      pcs_tx_fail <= 1'b0;
     end
//-------------------------------



endmodule

