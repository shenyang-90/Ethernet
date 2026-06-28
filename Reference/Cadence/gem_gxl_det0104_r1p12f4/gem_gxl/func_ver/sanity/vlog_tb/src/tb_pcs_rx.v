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
//   Filename:           tb_pcs_rx.v
//   Module Name:        tb_pcs_rx
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
//   Description    :   PCS_rx transactor. Applies either I2 ordered sets or
//                      test vectors read from ../work/files/tb_pcs_rx.data.
//                      Also generates 1 cycle pulse for triggering other
//                      transactors.
//                      Everything regarding codegroup generation (other than
//                      I2 ordered set is handled in the trans.pl, upon
//                      translation of the testcase
//
//------------------------------------------------------------------------------


module tb_pcs_rx (
  // Inputs
  reset_tb,             // testbench reset
  rx_clk,               // pcs rx test bench requires a 125MHz clock

  pcs_rx_trig,          // tb clock cycle event trigger
  int_pulse,            // interrupt trigger
  trig_from_apb,        // trigger from apb
  trig_from_pcs_tx,     // trigger from pcs_tx transactor
  ewrap,                // PMA loopback enable
  tx_group,             // tx_group from DUT for PMA loopback

  keep_idle_i1,         // Use I1 for Idles

  rx_in_progress,       // reception in progress - corresponds to synch_trigger
  idle_1_received,      // EPD of the tb_pcs_rx ended with I1 ordered set

  // Outputs
  rx_group,             // 10 bit codegroups

  trig_from_pcs_rx,     // enforce one cycle pulse to trigger other transactor

  pcs_rx_done,          // signals completion of rx activity

  link_fault            // The Link Fault status indicator:
                        // 00 - OK
                        // 01 - Local Fault
                        // 10 - Remote Fault
                        // 11 - Link Interruption
);

  input         reset_tb;           // global tb reset
  input         rx_clk;             // 125MHz clock
  input         pcs_rx_trig;        // triggers from cycle count
  input         int_pulse;          // interrupt occurred
  input         trig_from_apb;      // trigger from apb
  input         trig_from_pcs_tx;   // trigger from pcs_tx
  input         ewrap;              // PMA loopback enable
  input   [9:0] tx_group;           // tx_group from DUT for PMA loopback

  input         keep_idle_i1;

  output        rx_in_progress;     // flags reception in progress -
                                    // corresponds to synch_trig
  output        idle_1_received;    // gem_gxl received EPD followed by I1

  output  [9:0] rx_group;           // TBI receive data from the PHY
  output        pcs_rx_done;        // indicates all test vectors executed

  output        trig_from_pcs_rx;   // 1 cycle pulse to trigger another tb

  output  [1:0] link_fault;         // The Link Fault status indicator:
                                    // 00 - OK
                                    // 01 - Local Fault
                                    // 10 - Remote Fault
                                    // 11 - Link Interruption

  // Internal signals
  reg   [15:0]  pcs_rx_vector_mem [1:16384]; // memory holding testcase data
  wire  [15:0]  pcs_rx_vector;               // current command
  wire  [15:0]  pcs_rx_vector_nxt;           // next command
  wire  [3:0]   pcs_rx_ctrl;                 // current control field
  wire  [3:0]   pcs_rx_ctrl_nxt;             // current control field

  reg   [9:0]   rx_group;                    // 10bit encoded data
  reg   [9:0]   reversed_rx_group;           // rx_group[0:9]

  reg           idle_2_k285;                 // K28.5 group for the I2 ordered set
  wire          keep_idle_2;                 // I2 ordered set must be generated
  wire          trig_event;                  // pulse to trigger new frame generation
  reg           latched_trig_event;          // latched trig_event pulse until after
                                             // end of the current I2 ordered set
  reg           synch_trigger;               // synchronized gate for reading and
                                             // applying tests vectors while 1
  integer       pcs_rx_index;                // index for the test vector memory
  integer       gap_timer;                   // counter for the interframe gap (I2 sets)
  wire          idle_1_detected;             // last transmitted codegroup is D5.6
                                             // i.e. the second group in I1 ordered set
  wire          end_gap_pulse;               // pulse indicating the last ordered set
                                             // I2 within the IFG

  integer       i;                           // loop index

  reg           trig_from_pcs_rx;            // 1 cycle pulse for triggering another tb

  reg   [9:0]   tx_group_delayed;            // delayed tx_group for PMA loopback
  reg           loop_force_sync;             // force resync in PMA loopback
  reg           trig_from_pcs_tx_stored;     // stores trigger generated from tb_pcs_tx

  reg           cur_i_disp;                  // holds the current running disparity

  // Link Fault Signaling (802.3bz/802.3cb)
  reg           rx_clk_half;                 // rx_clk at half speed
  wire          rx_clk_half_trig;            // trigger for rx_clk_half generation
  reg           rx_clk_half_trig_reg;        // needed to hold the rx_clk_half_trig to 1
  reg  [9:0]    rx_group_prev;               // holds the previous value of rx_group
  reg  [19:0]   rx_group_buffer_prev;        // holds the previous value of rx_group_buffer
  wire [19:0]   rx_group_buffer;             // a buffer to hold rx_group codegroups in couples
  wire          d0_0_k28_5;                  // current rx_group_buffer is /D0.0/K28.5/
  wire          d0_6_k28_5;                  // current rx_group_buffer is /D0.6/K28.5/
  wire          d16_6_k28_5;                 // current rx_group_buffer is /D16.6/K28.5/
  wire          d0_7_k28_5;                  // current rx_group_buffer is /D0.7/K28.5/
  wire          d16_7_k28_5;                 // current rx_group_buffer is /D16.7/K28.5/
  wire          q_lfs_w0_detected;           // detect W0 of a Link Fault /Q/
  wire          q_lfs_w1_detected;           // detect W1 of a Link Fault /Q/
  wire          q_lfs_w2_detected;           // detect W2 of a Link Fault /Q/
  wire          q_lfs_w3_detected;           // detect W3 of a Link Fault /Q/
  wire          q_lfs_detection_en;          // asserted if the Link Fault /Q/ decoding process is running
  reg  [1:0]    link_fault_char_count;       // counts codegroup couples belonging to a /Q/ ordered set
  reg  [1:0]    link_fault_type_prev;        // store the previous link fault type
  reg  [1:0]    link_fault_type;             // store the link fault type
  reg  [31:0]   half_col_cnt;                // a count of the number of half columns received not containing a fault sequence
  reg  [31:0]   seq_cnt;                     // a count of the number of /Q/ ordered sets of the same type
  reg  [1:0]    link_fault_reg;              // convenience reg to assign link_fault output

  // Notable D Charachters, reversed - i.e. from j (LSB) to a (MSB)
  parameter CONST_D0_0_P_REV  = 10'h346; // +ve disp
  parameter CONST_D0_0_N_REV  = 10'h0b9; // -ve disp
  parameter CONST_D16_2_P_REV = 10'h289; // +ve disp
  parameter CONST_D16_2_N_REV = 10'h2b6; // -ve disp
  parameter CONST_D0_6_P_REV  = 10'h186; // +ve disp
  parameter CONST_D0_6_N_REV  = 10'h1b9; // -ve disp
  parameter CONST_D5_6_REV    = 10'h1a5; // +/-ve disp
  parameter CONST_D16_6_P_REV = 10'h189; // +ve disp
  parameter CONST_D16_6_N_REV = 10'h1b6; // -ve disp
  parameter CONST_D0_7_P_REV  = 10'h1c6; // +ve disp
  parameter CONST_D0_7_N_REV  = 10'h239; // -ve disp
  parameter CONST_D16_7_P_REV = 10'h1c9; // +ve disp
  parameter CONST_D16_7_N_REV = 10'h236; // -ve disp

  // Notable K Charachters, reversed - i.e. from j (LSB) to a (MSB)
  parameter CONST_K28_5_P_REV = 10'h283; // +ve disp
  parameter CONST_K28_5_N_REV = 10'h17c; // -ve disp
  parameter CONST_K23_7_P_REV = 10'h3a8; // +ve disp
  parameter CONST_K23_7_N_REV = 10'h057; // -ve disp


// Initialize pinsets test_memory - Read the test case file and load contents
//                                  into the memory
//-------------------------------
initial
   begin
      for (i=1; i<=16384; i=i+1)
         pcs_rx_vector_mem[i] = {16{1'b0}};

      $readmemh("./files/tb_pcs_rx.data", pcs_rx_vector_mem);
      if (pcs_rx_vector_mem[1] == 16'hx)
         begin
            $display("\n No pcs_rx data file read \n");
            $stop;
         end
   end

 assign pcs_rx_vector = pcs_rx_vector_mem[pcs_rx_index];
 assign pcs_rx_vector_nxt = pcs_rx_vector_mem[pcs_rx_index+1];
 assign pcs_rx_ctrl = pcs_rx_vector[15:12];
 assign pcs_rx_ctrl_nxt = pcs_rx_vector_nxt[15:12];

 assign pcs_rx_done = ~|(pcs_rx_ctrl);   // stop trigger = 0x
//-------------------------------


// Invert codegroup
//-------------------------------
always @(rx_group)
   for (i=0; i<=9; i=i+1)
      reversed_rx_group[i] <= rx_group[9-i];
//-------------------------------


// Drive the rx_group output.
// The rx_group received from the phy must be delivered to the gem_pcs
// with flipped contents, i.e. j:a (and not a:j as it appears in the
// tables of the i3e spec; refer to  clause 36.2.4 8b/10b transmission code)
//-------------------------------
always @(posedge rx_clk or negedge reset_tb)
   if (~reset_tb)
   begin
      rx_group   <= CONST_K23_7_N_REV; // Same reset value as tx_code_group (DUT)
      cur_i_disp <= 1'b0;
   end

   else if (ewrap & loop_force_sync)
      rx_group <= tx_group_delayed; // PMA loopback mode

   else if (ewrap & ~loop_force_sync)
      rx_group <= tx_group;         // PMA loopback mode

   else if (keep_idle_2)
   begin
     if (idle_2_k285) // Just done K28.5
     begin
       if (keep_idle_i1)  // I1 inverts disparity (keeps K change)
       begin
         cur_i_disp <= cur_i_disp;
         rx_group   <= CONST_D5_6_REV;
       end
       else         // I2 preserves
       begin
         cur_i_disp <= ~cur_i_disp;
         if (cur_i_disp)
           rx_group   <= CONST_D16_2_P_REV;
         else
           rx_group   <= CONST_D16_2_N_REV;
       end
     end
     else
     begin
       cur_i_disp <= ~cur_i_disp;
       if (cur_i_disp)
         rx_group   <= CONST_K28_5_P_REV;
       else
         rx_group   <= CONST_K28_5_N_REV;
     end
   end

   else
   begin
      cur_i_disp  <= 1'b0;
      for (i=0; i<=9; i=i+1)
         rx_group[i] <= pcs_rx_vector[9-i]; // drive group implied from test case
   end
//-------------------------------


// Drive controls to form I2 ordered set while waiting for trigger event
//-------------------------------
always @(posedge rx_clk or negedge reset_tb)
   if (~reset_tb)
     begin
      idle_2_k285 <= 1'b0;   // must be cleared during reset in order to
                             // put rx_group k28.5 immediately after reset
     end
   else if (~synch_trigger)
     begin
      idle_2_k285 <= ~idle_2_k285;   // put I2, but toggle b/n K28.5 and D16.2
     end
   else
     begin
      idle_2_k285 <= 1'b0;
     end
//-------------------------------
   assign keep_idle_2 = ~synch_trigger;


// delay tx_group for synchronisation
//-------------------------------
always @(posedge rx_clk or negedge reset_tb)
   if (~reset_tb)
     begin
      tx_group_delayed <= 10'h057;
      loop_force_sync  <= 1'b0;
     end
   else
     begin
      tx_group_delayed <= tx_group;
      if (idle_2_k285 & (tx_group == 10'h17c))
         loop_force_sync  <= 1'b1;
      else if (~idle_2_k285 & (tx_group == 10'h17c))
         loop_force_sync  <= 1'b0;
     end
//-------------------------------


// Handle trigger events and synchronize test vector application
//-------------------------------
   assign trig_event = pcs_rx_trig & pcs_rx_ctrl==4'h1
                     | int_pulse & pcs_rx_ctrl==4'h2
                     | trig_from_apb & pcs_rx_ctrl==4'h3
                     | end_gap_pulse & pcs_rx_ctrl==4'h6
                     | trig_from_pcs_tx_stored & pcs_rx_ctrl_nxt==4'h7
                     | trig_from_pcs_tx & pcs_rx_ctrl==4'h7;

always @(posedge reset_tb or posedge rx_clk)
   if (~reset_tb)
     begin
      latched_trig_event <= 1'b0;
      synch_trigger <= 1'b0;
     end
   else if (trig_event & keep_idle_2 & idle_2_k285)  // trig event during 1st
     begin                                           // I2 code group
      synch_trigger <= 1'b1;
      latched_trig_event <= 1'b0;
     end
   else if (trig_event & keep_idle_2 & ~idle_2_k285)  // latch trig event during 2nd
     begin                                            // I2 code group
      latched_trig_event <= 1'b1;
     end
   else if (keep_idle_2 & idle_2_k285 & latched_trig_event)  // trig during 1st
     begin                                                   // I2 code group
      synch_trigger <= 1'b1;
      latched_trig_event <= 1'b0;
     end
   else if (~keep_idle_2 & trig_event)               // trig immediately
     begin                                           // if not transmitting idles
      synch_trigger <= 1'b1;
      latched_trig_event <= 1'b0;
     end
   else if (pcs_rx_ctrl_nxt != 4'h4 & pcs_rx_ctrl_nxt != 4'h5)
     begin
      synch_trigger <= 1'b0;
     end

   assign rx_in_progress = synch_trigger;
//-------------------------------


// Latch trigger generated in tb_pcs_rx
//-------------------------------
   always @(reset_tb or posedge rx_clk)
   if (~reset_tb)
         trig_from_pcs_tx_stored  = 1'b0;

   else if ((trig_from_pcs_tx_stored & pcs_rx_ctrl_nxt==4'h7)
              | (trig_from_pcs_tx & pcs_rx_ctrl==4'h7))
         trig_from_pcs_tx_stored = 1'b0;
   else if (trig_from_pcs_tx)
         trig_from_pcs_tx_stored = 1'b1;
//-------------------------------


//generate the index
//-------------------------------
always @(posedge rx_clk or negedge reset_tb)
   if (~reset_tb)
      pcs_rx_index <= 1;
   else if (synch_trigger)
      pcs_rx_index <= pcs_rx_index + 1;
//-------------------------------


//count the interframe gap time - 12 rx_clock periods (96ns each)
//-------------------------------
always @(posedge rx_clk or negedge reset_tb)
   if (~reset_tb)
      gap_timer <= 5;
   else if (gap_timer==0)
      gap_timer <= 5;
   else if (synch_trigger)
      gap_timer <= 5;
   else if (keep_idle_2 & idle_1_detected & idle_2_k285)
      gap_timer <= gap_timer - 2;
   else if (keep_idle_2 & idle_2_k285)
      gap_timer <= gap_timer - 1;

   assign idle_1_detected = rx_group==CONST_D5_6_REV; // D5.6 for both rd- & rd+
                                                      // rx_group is j:a
   assign idle_1_received = idle_1_detected;   // this is not really I1
                                               // but D5.6 detected at any time
                                               // I1 however is important when
                                               // synch_trig is deasserted and
                                               // the last codegroup was D5.6

   assign end_gap_pulse = gap_timer==0;
//-------------------------------


// generate one cycle pulse for triggering another transactor
// if the next test vector control group is requiring so
//-------------------------------
always @(negedge rx_clk or negedge reset_tb)
   if (~reset_tb)
      trig_from_pcs_rx <= 1'b0;
   else if (synch_trigger & pcs_rx_ctrl_nxt==5)
      trig_from_pcs_rx <= 1'b1;
   else
      trig_from_pcs_rx <= 1'b0;
//-------------------------------


// Logic for Link Fault Signaling (802.3bz/802.3cb).
// Drives the Link Fault status indicator based on the behavior of the LFSM
// (IEEE 802.3 clause 46.3.4.3). In order to do this it must detect and count
// Link Fault /Q/ ordered sets.
//-------------------------------
// Create a trigger for rx_clk_half when reset_tb is asserted and rx_group goes
// from K23.7 (reset) to K28.5
always @(posedge rx_clk or negedge reset_tb) begin
  if (~reset_tb) begin
    rx_clk_half_trig_reg   <= 1'b0;
  end else begin
    if (rx_group_prev == CONST_K23_7_N_REV && rx_group == CONST_K28_5_N_REV) begin
      rx_clk_half_trig_reg <= 1'b1;
    end
  end
end
assign rx_clk_half_trig = (rx_group_prev == CONST_K23_7_N_REV && rx_group == CONST_K28_5_N_REV) || rx_clk_half_trig_reg;

// Create rx_clk_half
always @(posedge rx_clk or negedge reset_tb) begin
  if (~reset_tb) begin
    rx_clk_half   <= 1'b0;
  end else begin
    if (~rx_clk_half_trig) begin
      rx_clk_half <= 1'b0;
    end else begin
      rx_clk_half <= rx_clk_half + 1'b1;
    end
  end
end

// Hold previous values of rx_group and rx_group_buffer
always @(posedge rx_clk or negedge reset_tb) begin
  if (~reset_tb) begin
    rx_group_prev        <= 10'h0;
    rx_group_buffer_prev <= 20'h0;
  end else begin
    rx_group_prev        <= rx_group;
    rx_group_buffer_prev <= rx_group_buffer;
  end
end

// Assign rx_group_buffer when rx_clk_half goes high
assign rx_group_buffer = (rx_clk_half == 1'b1) ? {rx_group, rx_group_prev} : rx_group_buffer_prev;

// Drive the output
assign link_fault = link_fault_reg;

// Detect useful code group couples
assign d0_0_k28_5  =  (rx_group_buffer == {CONST_D0_0_P_REV , CONST_K28_5_N_REV} ||
                       rx_group_buffer == {CONST_D0_0_N_REV , CONST_K28_5_P_REV});
assign d0_6_k28_5  =  (rx_group_buffer == {CONST_D0_6_P_REV , CONST_K28_5_N_REV} ||
                       rx_group_buffer == {CONST_D0_6_N_REV , CONST_K28_5_P_REV});
assign d16_6_k28_5  = (rx_group_buffer == {CONST_D16_6_P_REV, CONST_K28_5_N_REV} ||
                       rx_group_buffer == {CONST_D16_6_N_REV, CONST_K28_5_P_REV});
assign d0_7_k28_5  =  (rx_group_buffer == {CONST_D0_7_P_REV , CONST_K28_5_N_REV} ||
                       rx_group_buffer == {CONST_D0_7_N_REV , CONST_K28_5_P_REV});
assign d16_7_k28_5  = (rx_group_buffer == {CONST_D16_7_P_REV, CONST_K28_5_N_REV} ||
                       rx_group_buffer == {CONST_D16_7_N_REV, CONST_K28_5_P_REV});

// Detect a /K28.5/D0.0/ ordered set on W0
assign q_lfs_w0_detected = (d0_0_k28_5) && (link_fault_char_count == 3'h0);

// Detect a /K28.5/D0.6/ ordered set on W1
assign q_lfs_w1_detected = (d0_6_k28_5) && (link_fault_char_count == 3'h1);

// Detect a Link Fault Type /K28.5/Dxx.y/ ordered set on W2
assign q_lfs_w2_detected = (d0_6_k28_5 || d16_6_k28_5 || d0_7_k28_5 || d16_7_k28_5) && (link_fault_char_count == 3'h2);

// Detect a /K28.5/D0.0/ ordered set on W3
assign q_lfs_w3_detected = (d0_0_k28_5) && (link_fault_char_count == 3'h3);

// While the /Q/ detection is in place this signal is high
assign q_lfs_detection_en = q_lfs_w0_detected ||
                            q_lfs_w1_detected ||
                            q_lfs_w2_detected ||
                            q_lfs_w3_detected;

// Detect a Link Fault /Q/ ordered set
always @(posedge rx_clk_half or negedge reset_tb) begin
  if (~reset_tb) begin
    link_fault_char_count   <= 2'b00;
    link_fault_type_prev    <= 2'b00;
    link_fault_type         <= 2'b00;
  end else begin
    if (q_lfs_w0_detected || q_lfs_w1_detected) begin
      link_fault_char_count <= link_fault_char_count + 2'b01;
    end else if (q_lfs_w2_detected) begin
      link_fault_char_count <= link_fault_char_count + 2'b01;
      link_fault_type_prev  <= link_fault_type;
      if (d0_6_k28_5) begin
        link_fault_type     <= 2'b00; // Link OK
      end else if (d16_6_k28_5) begin
        link_fault_type     <= 2'b01; // Local Fault
      end else if (d0_7_k28_5) begin
        link_fault_type     <= 2'b10; // Remote Fault
      end else if (d16_7_k28_5) begin
        link_fault_type     <= 2'b11; // Link Interruption
      end
    end else begin
      link_fault_char_count <= 2'b00;
    end
  end
end

// Count columns and Link Fault /Q/ ordered sets
always @(posedge rx_clk_half or negedge reset_tb) begin
  if (~reset_tb) begin
    seq_cnt          <= 32'd0;
    half_col_cnt     <= 32'd0;
  end else begin
    if (q_lfs_w3_detected) begin
      if (link_fault_type_prev != link_fault_type) begin
        seq_cnt      <= 32'd1;
        half_col_cnt <= 32'd0;
      end else begin
        seq_cnt      <= seq_cnt + 32'd1;
      end
    end else if (!q_lfs_detection_en) begin
      if (half_col_cnt > 32'd255) begin
        seq_cnt      <= 32'd0;
        half_col_cnt <= 32'd0;
      end else begin
        half_col_cnt <= half_col_cnt + {30'd0, link_fault_char_count} + 32'd1;
      end
    end
  end
end

// Drive the Link Fault status indicator
always @(posedge rx_clk_half or negedge reset_tb) begin
  if (~reset_tb) begin
    link_fault_reg   <= 2'b00;
  end else begin
    if (half_col_cnt > 32'd255) begin
      link_fault_reg <= 2'b00;
    end else if (seq_cnt >= 32'd3 && q_lfs_w3_detected && (link_fault_type == link_fault_type_prev)) begin
      link_fault_reg <= link_fault_type;
    end
  end
end
//-------------------------------

endmodule

