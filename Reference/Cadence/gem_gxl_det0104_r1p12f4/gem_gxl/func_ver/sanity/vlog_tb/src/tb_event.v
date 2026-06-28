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
//   Filename:           tb_event.v
//   Module Name:        tb_event
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
//   Description : Signals events to the rest of the testbench
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_event (
   reset_tb,
   clk_tb,
   pclk,
   ethernet_int,
   ethernet_int_q1,
   ethernet_int_q2,
   ethernet_int_q3,
   ethernet_int_q4,
   ethernet_int_q5,
   ethernet_int_q6,
   ethernet_int_q7,
   ethernet_int_q8,
   ethernet_int_q9,
   ethernet_int_q10,
   ethernet_int_q11,
   ethernet_int_q12,
   ethernet_int_q13,
   ethernet_int_q14,
   ethernet_int_q15,
   emac_ethernet_int,
   mmsl_int,
   asf_int_nonfatal,
   asf_int_fatal,
   emac_asf_int_nonfatal,
   emac_asf_int_fatal,
   int_pulse,
   int_pulse_q1,
   int_pulse_q2,
   int_pulse_q3,
   int_pulse_q4,
   int_pulse_q5,
   int_pulse_q6,
   int_pulse_q7,
   int_pulse_q8,
   int_pulse_q9,
   int_pulse_q10,
   int_pulse_q11,
   int_pulse_q12,
   int_pulse_q13,
   int_pulse_q14,
   int_pulse_q15,
   int_pulse_emac,
   int_pulse_mmsl,
   int_pulse_asf_nonfatal,
   int_pulse_asf_fatal,
   int_pulse_emac_asf_nonfatal,
   int_pulse_emac_asf_fatal,
   int_clock_pulse,
   int_clock_pulse_q1,
   int_clock_pulse_q2,
   int_clock_pulse_q3,
   int_clock_pulse_q4,
   int_clock_pulse_q5,
   int_clock_pulse_q6,
   int_clock_pulse_q7,
   int_clock_pulse_q8,
   int_clock_pulse_q9,
   int_clock_pulse_q10,
   int_clock_pulse_q11,
   int_clock_pulse_q12,
   int_clock_pulse_q13,
   int_clock_pulse_q14,
   int_clock_pulse_q15,
   int_clock_pulse_emac,
   int_clock_pulse_mmsl,
   int_clock_pulse_asf_nonfatal,
   int_clock_pulse_asf_fatal,
   int_clock_pulse_emac_asf_nonfatal,
   int_clock_pulse_emac_asf_fatal,
   count,
   rx_trig,
   pcs_rx_trig,
   apb_trig,
   pins_drive_trig,
   pins_check_trig,
   filter_drive_trig,
   end_trig,
   apb_int_status_read,
   apb_int_q1_status_read,
   apb_int_q2_status_read,
   apb_int_q3_status_read,
   apb_int_q4_status_read,
   apb_int_q5_status_read,
   apb_int_q6_status_read,
   apb_int_q7_status_read,
   apb_int_q8_status_read,
   apb_int_q9_status_read,
   apb_int_q10_status_read,
   apb_int_q11_status_read,
   apb_int_q12_status_read,
   apb_int_q13_status_read,
   apb_int_q14_status_read,
   apb_int_q15_status_read,
   apb_emac_int_status_read,
   apb_mmsl_int_status_read,
   apb_asf_int_nonfatal_status_read,
   apb_asf_int_fatal_status_read,
   apb_emac_asf_int_nonfatal_status_read,
   apb_emac_asf_int_fatal_status_read
);

// -----------------------------------------------------------------------------
// Define inputs and outputs
// -----------------------------------------------------------------------------
   input          reset_tb;            // testbench reset
   input          clk_tb;              // testbench clock
   input          pclk;
   input          ethernet_int;        // interrupt signal from DUT
   input          ethernet_int_q1;     // interrupt signal from DUT
   input          ethernet_int_q2;     // interrupt signal from DUT
   input          ethernet_int_q3;     // interrupt signal from DUT
   input          ethernet_int_q4;     // interrupt signal from DUT
   input          ethernet_int_q5;     // interrupt signal from DUT
   input          ethernet_int_q6;     // interrupt signal from DUT
   input          ethernet_int_q7;     // interrupt signal from DUT
   input          ethernet_int_q8;     // interrupt signal from DUT
   input          ethernet_int_q9;     // interrupt signal from DUT
   input          ethernet_int_q10;    // interrupt signal from DUT
   input          ethernet_int_q11;    // interrupt signal from DUT
   input          ethernet_int_q12;    // interrupt signal from DUT
   input          ethernet_int_q13;    // interrupt signal from DUT
   input          ethernet_int_q14;    // interrupt signal from DUT
   input          ethernet_int_q15;    // interrupt signal from DUT
   input          emac_ethernet_int;   // ethernet mac interrupt signal.
   input          mmsl_int;            // MMSL interrupt pin
   input          asf_int_nonfatal;    // ASF non-fatal interrupt
   input          asf_int_fatal;       // ASF fatal interrupt
   input          emac_asf_int_nonfatal;// ASF non-fatal interrupt
   input          emac_asf_int_fatal;   // ASF fatal interrupt
   input          apb_int_status_read; // signals when an apb read is done
   input          apb_int_q1_status_read; // signals when an apb read is done
   input          apb_int_q2_status_read; // signals when an apb read is done
   input          apb_int_q3_status_read; // signals when an apb read is done
   input          apb_int_q4_status_read; // signals when an apb read is done
   input          apb_int_q5_status_read; // signals when an apb read is done
   input          apb_int_q6_status_read; // signals when an apb read is done
   input          apb_int_q7_status_read; // signals when an apb read is done
   input          apb_int_q8_status_read; // signals when an apb read is done
   input          apb_int_q9_status_read; // signals when an apb read is done
   input          apb_int_q10_status_read; // signals when an apb read is done
   input          apb_int_q11_status_read; // signals when an apb read is done
   input          apb_int_q12_status_read; // signals when an apb read is done
   input          apb_int_q13_status_read; // signals when an apb read is done
   input          apb_int_q14_status_read; // signals when an apb read is done
   input          apb_int_q15_status_read; // signals when an apb read is done
   input          apb_emac_int_status_read; // signals when an apb read is done
   input          apb_mmsl_int_status_read; // signals when an apb read is done
   input          apb_asf_int_nonfatal_status_read;      // signals when an apb read is done
   input          apb_asf_int_fatal_status_read;         // signals when an apb read is done
   input          apb_emac_asf_int_nonfatal_status_read; // signals when an apb read is done
   input          apb_emac_asf_int_fatal_status_read;    // signals when an apb read is done
   output         int_pulse;           // pulse when new interrupt seen
   output         int_pulse_q1;        // pulse when new interrupt seen
   output         int_pulse_q2;        // pulse when new interrupt seen
   output         int_pulse_q3;        // pulse when new interrupt seen
   output         int_pulse_q4;        // pulse when new interrupt seen
   output         int_pulse_q5;        // pulse when new interrupt seen
   output         int_pulse_q6;        // pulse when new interrupt seen
   output         int_pulse_q7;        // pulse when new interrupt seen
   output         int_pulse_q8;        // pulse when new interrupt seen
   output         int_pulse_q9;        // pulse when new interrupt seen
   output         int_pulse_q10;       // pulse when new interrupt seen
   output         int_pulse_q11;       // pulse when new interrupt seen
   output         int_pulse_q12;       // pulse when new interrupt seen
   output         int_pulse_q13;       // pulse when new interrupt seen
   output         int_pulse_q14;       // pulse when new interrupt seen
   output         int_pulse_q15;       // pulse when new interrupt seen
   output         int_pulse_emac;      // pulse when new interrupt seen
   output         int_pulse_mmsl;      // pulse when new interrupt seen
   output         int_pulse_asf_nonfatal;      // pulse when new interrupt seen
   output         int_pulse_asf_fatal;         // pulse when new interrupt seen
   output         int_pulse_emac_asf_nonfatal; // pulse when new interrupt seen
   output         int_pulse_emac_asf_fatal;    // pulse when new interrupt seen
   output         int_clock_pulse;     // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q1;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q2;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q3;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q4;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q5;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q6;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q7;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q8;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q9;  // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q10; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q11; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q12; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q13; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q14; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_q15; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_emac; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_mmsl; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_asf_nonfatal; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_asf_fatal; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_emac_asf_nonfatal; // Single clock pulse when new interrupt seen
   output         int_clock_pulse_emac_asf_fatal; // Single clock pulse when new interrupt seen
   output  [23:0] count;               // Current value of testbench event count
   output         rx_trig;             // trigger to tb_rx
   output         pcs_rx_trig;         // trigger to tb_pcs_rx
   output         apb_trig;            // trigger to tb_apb
   output         pins_drive_trig;     // trigger to tb_pins (driving)
   output         pins_check_trig;     // trigger to tb_pins (checking)
   output         filter_drive_trig;   // trigger to tb_filter (driving)
   output         end_trig;            // force end of simulation


// -----------------------------------------------------------------------------
// Define internal signals
// -----------------------------------------------------------------------------

   // test file array
   integer        j;                   // loop variable for array initialisation
   reg     [31:0] event_vector_reg[1:512];
                                       // tb_event array for test file
   integer        event_index;         // current pointer to event_vector_reg
   wire    [31:0] event_vector;        // current selected event_vector_reg
                                       // 20 lsb are the count, msb's are
                                       // the triggers

   // detect interrupt
   reg            int_detect;          // detect when an interrupt has occurred
   reg            int_detect_del;      // delayed version fro edge detection
   reg            int_pulse;           // new interrupt seen trigger pulse
   reg            int_detect_q1;       // detect when an interrupt has occurred
   reg            int_detect_q1_del;   // delayed version fro edge detection
   reg            int_pulse_q1;        // new interrupt seen trigger pulse
   reg            int_detect_q2;       // detect when an interrupt has occurred
   reg            int_detect_q2_del;   // delayed version fro edge detection
   reg            int_pulse_q2;        // new interrupt seen trigger pulse
   reg            int_detect_q3;       // detect when an interrupt has occurred
   reg            int_detect_q3_del;   // delayed version fro edge detection
   reg            int_pulse_q3;        // new interrupt seen trigger pulse
   reg            int_detect_q4;       // detect when an interrupt has occurred
   reg            int_detect_q4_del;   // delayed version fro edge detection
   reg            int_pulse_q4;        // new interrupt seen trigger pulse
   reg            int_detect_q5;       // detect when an interrupt has occurred
   reg            int_detect_q5_del;   // delayed version fro edge detection
   reg            int_pulse_q5;        // new interrupt seen trigger pulse
   reg            int_detect_q6;       // detect when an interrupt has occurred
   reg            int_detect_q6_del;   // delayed version fro edge detection
   reg            int_pulse_q6;        // new interrupt seen trigger pulse
   reg            int_detect_q7;       // detect when an interrupt has occurred
   reg            int_detect_q7_del;   // delayed version fro edge detection
   reg            int_pulse_q7;        // new interrupt seen trigger pulse
   reg            int_detect_q8;       // detect when an interrupt has occurred
   reg            int_detect_q8_del;   // delayed version fro edge detection
   reg            int_pulse_q8;        // new interrupt seen trigger pulse
   reg            int_detect_q9;       // detect when an interrupt has occurred
   reg            int_detect_q9_del;   // delayed version fro edge detection
   reg            int_pulse_q9;        // new interrupt seen trigger pulse
   reg            int_detect_q10;      // detect when an interrupt has occurred
   reg            int_detect_q10_del;  // delayed version fro edge detection
   reg            int_pulse_q10;       // new interrupt seen trigger pulse
   reg            int_detect_q11;      // detect when an interrupt has occurred
   reg            int_detect_q11_del;  // delayed version fro edge detection
   reg            int_pulse_q11;       // new interrupt seen trigger pulse
   reg            int_detect_q12;      // detect when an interrupt has occurred
   reg            int_detect_q12_del;  // delayed version fro edge detection
   reg            int_pulse_q12;       // new interrupt seen trigger pulse
   reg            int_detect_q13;      // detect when an interrupt has occurred
   reg            int_detect_q13_del;  // delayed version fro edge detection
   reg            int_pulse_q13;       // new interrupt seen trigger pulse
   reg            int_detect_q14;      // detect when an interrupt has occurred
   reg            int_detect_q14_del;  // delayed version fro edge detection
   reg            int_pulse_q14;       // new interrupt seen trigger pulse
   reg            int_detect_q15;      // detect when an interrupt has occurred
   reg            int_detect_q15_del;  // delayed version fro edge detection
   reg            int_pulse_q15;       // new interrupt seen trigger pulse
   reg            int_detect_emac;     // detect when an interrupt has occurred
   reg            int_detect_emac_del; // delayed version fro edge detection
   reg            int_pulse_emac;      // new interrupt seen trigger pulse
   reg            int_detect_mmsl;     // detect when an interrupt has occurred
   reg            int_detect_mmsl_del; // delayed version fro edge detection
   reg            int_pulse_mmsl;      // new interrupt seen trigger pulse
   reg            int_detect_asf_nonfatal; // detect when an interrupt has occurred
   reg            int_detect_asf_nonfatal_del; // delayed version fro edge detection
   reg            int_pulse_asf_nonfatal;      // new interrupt seen trigger pulse
   reg            int_detect_asf_fatal; // detect when an interrupt has occurred
   reg            int_detect_asf_fatal_del; // delayed version fro edge detection
   reg            int_pulse_asf_fatal;      // new interrupt seen trigger pulse
   reg            int_detect_emac_asf_nonfatal;     // detect when an interrupt has occurred
   reg            int_detect_emac_asf_nonfatal_del; // delayed version fro edge detection
   reg            int_pulse_emac_asf_nonfatal;      // new interrupt seen trigger pulse
   reg            int_detect_emac_asf_fatal;        // detect when an interrupt has occurred
   reg            int_detect_emac_asf_fatal_del;    // delayed version fro edge detection
   reg            int_pulse_emac_asf_fatal;         // new interrupt seen trigger pulse

   // testbench event counter
   wire    [23:0] event_count;         // next event count trigger value
   reg     [23:0] count;               // tetsbench event counter

   // triggers to other testbenches
   reg            rx_trig;             // trigger to tb_rx
   reg            pcs_rx_trig;         // trigger to tb_pcs_rx
   reg            apb_trig;            // trigger to tb_apb
   reg            pins_drive_trig;     // trigger to tb_pins (driving)
   reg            pins_check_trig;     // trigger to tb_pins (checking)
   reg            filter_drive_trig;   // trigger to tb_filter (driving)

   // test end trigger
   reg            end_trig;            // force end of simulation

   // Clock cycle pulses (one TB clock) version of the interrupt detects
   reg            int_clock_pulse;
   reg            int_clock_pulse_q1;
   reg            int_clock_pulse_q2;
   reg            int_clock_pulse_q3;
   reg            int_clock_pulse_q4;
   reg            int_clock_pulse_q5;
   reg            int_clock_pulse_q6;
   reg            int_clock_pulse_q7;
   reg            int_clock_pulse_q8;
   reg            int_clock_pulse_q9;
   reg            int_clock_pulse_q10;
   reg            int_clock_pulse_q11;
   reg            int_clock_pulse_q12;
   reg            int_clock_pulse_q13;
   reg            int_clock_pulse_q14;
   reg            int_clock_pulse_q15;
   reg            int_clock_pulse_emac;
   reg            int_clock_pulse_mmsl;
   reg            int_clock_pulse_asf_nonfatal;
   reg            int_clock_pulse_asf_fatal;
   reg            int_clock_pulse_emac_asf_nonfatal;
   reg            int_clock_pulse_emac_asf_fatal;

// -----------------------------------------------------------------------------
// initialise arrays from test files
// -----------------------------------------------------------------------------

  // read event data
  initial
     begin
        for (j=1; j<=512; j=j+1)
           event_vector_reg[j] = 32'b0;

        $readmemh("./files/tb_event.data",event_vector_reg);
        if (event_vector_reg[1] === 32'hxxxxxxxx)
           begin
              $display("\n No event data file read \n");
           end
        else
           begin
              // $display("Read event data file");
           end
    end

   // decode from array to make referencing easier
   assign event_vector = event_vector_reg[event_index];
   assign event_count  = event_vector[23:0] - 24'h000001;


// -----------------------------------------------------------------------------
// Detect interrupt
// -----------------------------------------------------------------------------

   // Generate an interrupt detect signal that is latched until
   // there is an apb read of the interrupt status register. The apb read
   // resets the interrupt detect signal.
   always @( negedge (reset_tb) or ethernet_int or apb_int_status_read)
      if (~reset_tb)
         int_detect <= 0;
      else if  (apb_int_status_read)
         int_detect <= 0;
      else if  (ethernet_int)
         int_detect <= 1;
      else
         int_detect <= int_detect;
   always @( negedge (reset_tb) or ethernet_int_q15 or apb_int_q15_status_read)
      if (~reset_tb)
         int_detect_q15 <= 0;
      else if  (apb_int_q15_status_read)
         int_detect_q15 <= 0;
      else if  (ethernet_int_q15)
         int_detect_q15 <= 1;
      else
         int_detect_q15 <= int_detect_q15;
   always @( negedge (reset_tb) or ethernet_int_q14 or apb_int_q14_status_read)
      if (~reset_tb)
         int_detect_q14 <= 0;
      else if  (apb_int_q14_status_read)
         int_detect_q14 <= 0;
      else if  (ethernet_int_q14)
         int_detect_q14 <= 1;
      else
         int_detect_q14 <= int_detect_q14;
   always @( negedge (reset_tb) or ethernet_int_q13 or apb_int_q13_status_read)
      if (~reset_tb)
         int_detect_q13 <= 0;
      else if  (apb_int_q13_status_read)
         int_detect_q13 <= 0;
      else if  (ethernet_int_q13)
         int_detect_q13 <= 1;
      else
         int_detect_q13 <= int_detect_q13;
   always @( negedge (reset_tb) or ethernet_int_q12 or apb_int_q12_status_read)
      if (~reset_tb)
         int_detect_q12 <= 0;
      else if  (apb_int_q12_status_read)
         int_detect_q12 <= 0;
      else if  (ethernet_int_q12)
         int_detect_q12 <= 1;
      else
         int_detect_q12 <= int_detect_q12;
   always @( negedge (reset_tb) or ethernet_int_q11 or apb_int_q11_status_read)
      if (~reset_tb)
         int_detect_q11 <= 0;
      else if  (apb_int_q11_status_read)
         int_detect_q11 <= 0;
      else if  (ethernet_int_q11)
         int_detect_q11 <= 1;
      else
         int_detect_q11 <= int_detect_q11;
   always @( negedge (reset_tb) or ethernet_int_q10 or apb_int_q10_status_read)
      if (~reset_tb)
         int_detect_q10 <= 0;
      else if  (apb_int_q10_status_read)
         int_detect_q10 <= 0;
      else if  (ethernet_int_q10)
         int_detect_q10 <= 1;
      else
         int_detect_q10 <= int_detect_q10;
   always @( negedge (reset_tb) or ethernet_int_q9 or apb_int_q9_status_read)
      if (~reset_tb)
         int_detect_q9 <= 0;
      else if  (apb_int_q9_status_read)
         int_detect_q9 <= 0;
      else if  (ethernet_int_q9)
         int_detect_q9 <= 1;
      else
         int_detect_q9 <= int_detect_q9;
   always @( negedge (reset_tb) or ethernet_int_q8 or apb_int_q8_status_read)
      if (~reset_tb)
         int_detect_q8 <= 0;
      else if  (apb_int_q8_status_read)
         int_detect_q8 <= 0;
      else if  (ethernet_int_q8)
         int_detect_q8 <= 1;
      else
         int_detect_q8 <= int_detect_q8;
   always @( negedge (reset_tb) or ethernet_int_q7 or apb_int_q7_status_read)
      if (~reset_tb)
         int_detect_q7 <= 0;
      else if  (apb_int_q7_status_read)
         int_detect_q7 <= 0;
      else if  (ethernet_int_q7)
         int_detect_q7 <= 1;
      else
         int_detect_q7 <= int_detect_q7;
   always @( negedge (reset_tb) or ethernet_int_q6 or apb_int_q6_status_read)
      if (~reset_tb)
         int_detect_q6 <= 0;
      else if  (apb_int_q6_status_read)
         int_detect_q6 <= 0;
      else if  (ethernet_int_q6)
         int_detect_q6 <= 1;
      else
         int_detect_q6 <= int_detect_q6;
   always @( negedge (reset_tb) or ethernet_int_q5 or apb_int_q5_status_read)
      if (~reset_tb)
         int_detect_q5 <= 0;
      else if  (apb_int_q5_status_read)
         int_detect_q5 <= 0;
      else if  (ethernet_int_q5)
         int_detect_q5 <= 1;
      else
         int_detect_q5 <= int_detect_q5;
   always @( negedge (reset_tb) or ethernet_int_q4 or apb_int_q4_status_read)
      if (~reset_tb)
         int_detect_q4 <= 0;
      else if  (apb_int_q4_status_read)
         int_detect_q4 <= 0;
      else if  (ethernet_int_q4)
         int_detect_q4 <= 1;
      else
         int_detect_q4 <= int_detect_q4;
   always @( negedge (reset_tb) or ethernet_int_q3 or apb_int_q3_status_read)
      if (~reset_tb)
         int_detect_q3 <= 0;
      else if  (apb_int_q3_status_read)
         int_detect_q3 <= 0;
      else if  (ethernet_int_q3)
         int_detect_q3 <= 1;
      else
         int_detect_q3 <= int_detect_q3;
   always @( negedge (reset_tb) or ethernet_int_q2 or apb_int_q2_status_read)
      if (~reset_tb)
         int_detect_q2 <= 0;
      else if  (apb_int_q2_status_read)
         int_detect_q2 <= 0;
      else if  (ethernet_int_q2)
         int_detect_q2 <= 1;
      else
         int_detect_q2 <= int_detect_q2;
   always @( negedge (reset_tb) or ethernet_int_q1 or apb_int_q1_status_read)
      if (~reset_tb)
         int_detect_q1 <= 0;
      else if  (apb_int_q1_status_read)
         int_detect_q1 <= 0;
      else if  (ethernet_int_q1)
         int_detect_q1 <= 1;
      else
         int_detect_q1 <= int_detect_q1;
   always @( negedge (reset_tb) or emac_ethernet_int or apb_emac_int_status_read)
      if (~reset_tb)
         int_detect_emac <= 0;
      else if  (apb_emac_int_status_read)
         int_detect_emac <= 0;
      else if  (emac_ethernet_int)
         int_detect_emac <= 1;
      else
         int_detect_emac <= int_detect_emac;
   always @( negedge (reset_tb) or mmsl_int or apb_mmsl_int_status_read)
      if (~reset_tb)
         int_detect_mmsl <= 0;
      else if  (apb_mmsl_int_status_read)
         int_detect_mmsl <= 0;
      else if  (mmsl_int)
         int_detect_mmsl <= 1;
      else
         int_detect_mmsl <= int_detect_mmsl;
   always @( negedge (reset_tb) or asf_int_nonfatal or apb_asf_int_nonfatal_status_read)
      if (~reset_tb)
         int_detect_asf_nonfatal <= 0;
      else if  (apb_asf_int_nonfatal_status_read)
         int_detect_asf_nonfatal <= 0;
      else if  (asf_int_nonfatal)
         int_detect_asf_nonfatal <= 1;
      else
         int_detect_asf_nonfatal <= int_detect_asf_nonfatal;
   always @( negedge (reset_tb) or asf_int_fatal or apb_asf_int_fatal_status_read)
      if (~reset_tb)
         int_detect_asf_fatal <= 0;
      else if  (apb_asf_int_fatal_status_read)
         int_detect_asf_fatal <= 0;
      else if  (asf_int_fatal)
         int_detect_asf_fatal <= 1;
      else
         int_detect_asf_fatal <= int_detect_asf_fatal;

   always @( negedge (reset_tb) or emac_asf_int_nonfatal or apb_emac_asf_int_nonfatal_status_read)
      if (~reset_tb)
         int_detect_emac_asf_nonfatal <= 0;
      else if  (apb_emac_asf_int_nonfatal_status_read)
         int_detect_emac_asf_nonfatal <= 0;
      else if  (emac_asf_int_nonfatal)
         int_detect_emac_asf_nonfatal <= 1;
      else
         int_detect_emac_asf_nonfatal <= int_detect_emac_asf_nonfatal;
   always @( negedge (reset_tb) or emac_asf_int_fatal or apb_emac_asf_int_fatal_status_read)
      if (~reset_tb)
         int_detect_emac_asf_fatal <= 0;
      else if  (apb_emac_asf_int_fatal_status_read)
         int_detect_emac_asf_fatal <= 0;
      else if  (emac_asf_int_fatal)
         int_detect_emac_asf_fatal <= 1;
      else
         int_detect_emac_asf_fatal <= int_detect_emac_asf_fatal;

   reg          apb_int_status_read_fe;
   reg          apb_int_q1_status_read_fe;
   reg          apb_int_q2_status_read_fe;
   reg          apb_int_q3_status_read_fe;
   reg          apb_int_q4_status_read_fe;
   reg          apb_int_q5_status_read_fe;
   reg          apb_int_q6_status_read_fe;
   reg          apb_int_q7_status_read_fe;
   reg          apb_int_q8_status_read_fe;
   reg          apb_int_q9_status_read_fe;
   reg          apb_int_q10_status_read_fe;
   reg          apb_int_q11_status_read_fe;
   reg          apb_int_q12_status_read_fe;
   reg          apb_int_q13_status_read_fe;
   reg          apb_int_q14_status_read_fe;
   reg          apb_int_q15_status_read_fe;
   reg          apb_emac_int_status_read_fe;
   reg          apb_mmsl_int_status_read_fe;
   reg          apb_asf_int_nonfatal_status_read_fe;
   reg          apb_asf_int_fatal_status_read_fe;
   reg          apb_emac_asf_int_nonfatal_status_read_fe;
   reg          apb_emac_asf_int_fatal_status_read_fe;
   reg          apb_int_status_read_lat;
   reg          apb_int_q1_status_read_lat;
   reg          apb_int_q2_status_read_lat;
   reg          apb_int_q3_status_read_lat;
   reg          apb_int_q4_status_read_lat;
   reg          apb_int_q5_status_read_lat;
   reg          apb_int_q6_status_read_lat;
   reg          apb_int_q7_status_read_lat;
   reg          apb_int_q8_status_read_lat;
   reg          apb_int_q9_status_read_lat;
   reg          apb_int_q10_status_read_lat;
   reg          apb_int_q11_status_read_lat;
   reg          apb_int_q12_status_read_lat;
   reg          apb_int_q13_status_read_lat;
   reg          apb_int_q14_status_read_lat;
   reg          apb_int_q15_status_read_lat;
   reg          apb_emac_int_status_read_lat;
   reg          apb_mmsl_int_status_read_lat;
   reg          apb_asf_int_nonfatal_status_read_lat;
   reg          apb_asf_int_fatal_status_read_lat;
   reg          apb_emac_asf_int_nonfatal_status_read_lat;
   reg          apb_emac_asf_int_fatal_status_read_lat;
   always @(negedge reset_tb or negedge clk_tb)
      if (~reset_tb)
      begin
        apb_int_status_read_fe  <= 1'b0;
        apb_int_q1_status_read_fe <= 1'b0;
        apb_int_q2_status_read_fe <= 1'b0;
        apb_int_q3_status_read_fe <= 1'b0;
        apb_int_q4_status_read_fe <= 1'b0;
        apb_int_q5_status_read_fe <= 1'b0;
        apb_int_q6_status_read_fe <= 1'b0;
        apb_int_q7_status_read_fe <= 1'b0;
        apb_int_q8_status_read_fe <= 1'b0;
        apb_int_q9_status_read_fe <= 1'b0;
        apb_int_q10_status_read_fe <= 1'b0;
        apb_int_q11_status_read_fe <= 1'b0;
        apb_int_q12_status_read_fe <= 1'b0;
        apb_int_q13_status_read_fe <= 1'b0;
        apb_int_q14_status_read_fe <= 1'b0;
        apb_int_q15_status_read_fe <= 1'b0;
        apb_emac_int_status_read_fe <= 1'b0;
        apb_mmsl_int_status_read_fe <= 1'b0;
        apb_asf_int_nonfatal_status_read_fe <= 1'b0;
        apb_asf_int_fatal_status_read_fe <= 1'b0;
        apb_emac_asf_int_nonfatal_status_read_fe <= 1'b0;
        apb_emac_asf_int_fatal_status_read_fe <= 1'b0;
      end
      else
      begin
        apb_int_status_read_fe    <= apb_int_status_read;
        apb_int_q1_status_read_fe <= apb_int_q1_status_read;
        apb_int_q2_status_read_fe <= apb_int_q2_status_read;
        apb_int_q3_status_read_fe <= apb_int_q3_status_read;
        apb_int_q4_status_read_fe <= apb_int_q4_status_read;
        apb_int_q5_status_read_fe <= apb_int_q5_status_read;
        apb_int_q6_status_read_fe <= apb_int_q6_status_read;
        apb_int_q7_status_read_fe <= apb_int_q7_status_read;
        apb_int_q8_status_read_fe <= apb_int_q8_status_read;
        apb_int_q9_status_read_fe <= apb_int_q9_status_read;
        apb_int_q10_status_read_fe <=apb_int_q10_status_read;
        apb_int_q11_status_read_fe <=apb_int_q11_status_read;
        apb_int_q12_status_read_fe <=apb_int_q12_status_read;
        apb_int_q13_status_read_fe <=apb_int_q13_status_read;
        apb_int_q14_status_read_fe <=apb_int_q14_status_read;
        apb_int_q15_status_read_fe <=apb_int_q15_status_read;
        apb_emac_int_status_read_fe <=apb_emac_int_status_read;
        apb_mmsl_int_status_read_fe <=apb_mmsl_int_status_read;
        apb_asf_int_nonfatal_status_read_fe <= apb_asf_int_nonfatal_status_read;
        apb_asf_int_fatal_status_read_fe <= apb_asf_int_fatal_status_read;
        apb_emac_asf_int_nonfatal_status_read_fe <= apb_emac_asf_int_nonfatal_status_read;
        apb_emac_asf_int_fatal_status_read_fe <= apb_emac_asf_int_fatal_status_read;
      end


   // delay for edge detection
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_status_read)
      if (~reset_tb)
         int_detect_del <= 0;
      else if  (apb_int_status_read)
         int_detect_del <= 0;
      else
         int_detect_del <= int_detect;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_asf_int_nonfatal_status_read)
      if (~reset_tb)
         int_detect_asf_nonfatal_del <= 0;
      else if  (apb_asf_int_nonfatal_status_read)
         int_detect_asf_nonfatal_del <= 0;
      else
         int_detect_asf_nonfatal_del <= int_detect_asf_nonfatal;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_asf_int_fatal_status_read)
      if (~reset_tb)
         int_detect_asf_fatal_del <= 0;
      else if  (apb_asf_int_fatal_status_read)
         int_detect_asf_fatal_del <= 0;
      else
         int_detect_asf_fatal_del <= int_detect_asf_fatal;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_emac_asf_int_nonfatal_status_read)
      if (~reset_tb)
         int_detect_emac_asf_nonfatal_del <= 0;
      else if  (apb_emac_asf_int_nonfatal_status_read)
         int_detect_emac_asf_nonfatal_del <= 0;
      else
         int_detect_emac_asf_nonfatal_del <= int_detect_emac_asf_nonfatal;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_emac_asf_int_fatal_status_read)
      if (~reset_tb)
         int_detect_emac_asf_fatal_del <= 0;
      else if  (apb_emac_asf_int_fatal_status_read)
         int_detect_emac_asf_fatal_del <= 0;
      else
         int_detect_emac_asf_fatal_del <= int_detect_emac_asf_fatal;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_emac_int_status_read)
      if (~reset_tb)
         int_detect_emac_del <= 0;
      else if  (apb_emac_int_status_read)
         int_detect_emac_del <= 0;
      else
         int_detect_emac_del <= int_detect_emac;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_mmsl_int_status_read)
      if (~reset_tb)
         int_detect_mmsl_del <= 0;
      else if  (apb_mmsl_int_status_read)
         int_detect_mmsl_del <= 0;
      else
         int_detect_mmsl_del <= int_detect_mmsl;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q15_status_read)
      if (~reset_tb)
         int_detect_q15_del <= 0;
      else if  (apb_int_q15_status_read)
         int_detect_q15_del <= 0;
      else
         int_detect_q15_del <= int_detect_q15;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q14_status_read)
      if (~reset_tb)
         int_detect_q14_del <= 0;
      else if  (apb_int_q14_status_read)
         int_detect_q14_del <= 0;
      else
         int_detect_q14_del <= int_detect_q14;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q13_status_read)
      if (~reset_tb)
         int_detect_q13_del <= 0;
      else if  (apb_int_q13_status_read)
         int_detect_q13_del <= 0;
      else
         int_detect_q13_del <= int_detect_q13;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q12_status_read)
      if (~reset_tb)
         int_detect_q12_del <= 0;
      else if  (apb_int_q12_status_read)
         int_detect_q12_del <= 0;
      else
         int_detect_q12_del <= int_detect_q12;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q11_status_read)
      if (~reset_tb)
         int_detect_q11_del <= 0;
      else if  (apb_int_q11_status_read)
         int_detect_q11_del <= 0;
      else
         int_detect_q11_del <= int_detect_q11;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q10_status_read)
      if (~reset_tb)
         int_detect_q10_del <= 0;
      else if  (apb_int_q10_status_read)
         int_detect_q10_del <= 0;
      else
         int_detect_q10_del <= int_detect_q10;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q9_status_read)
      if (~reset_tb)
         int_detect_q9_del <= 0;
      else if  (apb_int_q9_status_read)
         int_detect_q9_del <= 0;
      else
         int_detect_q9_del <= int_detect_q9;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q8_status_read)
      if (~reset_tb)
         int_detect_q8_del <= 0;
      else if  (apb_int_q8_status_read)
         int_detect_q8_del <= 0;
      else
         int_detect_q8_del <= int_detect_q8;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q7_status_read)
      if (~reset_tb)
         int_detect_q7_del <= 0;
      else if  (apb_int_q7_status_read)
         int_detect_q7_del <= 0;
      else
         int_detect_q7_del <= int_detect_q7;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q6_status_read)
      if (~reset_tb)
         int_detect_q6_del <= 0;
      else if  (apb_int_q6_status_read)
         int_detect_q6_del <= 0;
      else
         int_detect_q6_del <= int_detect_q6;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q5_status_read)
      if (~reset_tb)
         int_detect_q5_del <= 0;
      else if  (apb_int_q5_status_read)
         int_detect_q5_del <= 0;
      else
         int_detect_q5_del <= int_detect_q5;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q4_status_read)
      if (~reset_tb)
         int_detect_q4_del <= 0;
      else if  (apb_int_q4_status_read)
         int_detect_q4_del <= 0;
      else
         int_detect_q4_del <= int_detect_q4;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q3_status_read)
      if (~reset_tb)
         int_detect_q3_del <= 0;
      else if  (apb_int_q3_status_read)
         int_detect_q3_del <= 0;
      else
         int_detect_q3_del <= int_detect_q3;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q2_status_read)
      if (~reset_tb)
         int_detect_q2_del <= 0;
      else if  (apb_int_q2_status_read)
         int_detect_q2_del <= 0;
      else
         int_detect_q2_del <= int_detect_q2;
   always @(negedge reset_tb or posedge clk_tb or posedge apb_int_q1_status_read)
      if (~reset_tb)
         int_detect_q1_del <= 0;
      else if  (apb_int_q1_status_read)
         int_detect_q1_del <= 0;
      else
         int_detect_q1_del <= int_detect_q1;

   // signal to other testbenches when new interrupt seen
   always @(*)
      if (int_detect & ~int_detect_del & ~apb_int_status_read_fe)
         begin
            int_clock_pulse = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Default Queue)\n");
          `endif
         end
      else
         int_clock_pulse = 1'b0;
   initial begin
      int_pulse = 1'b0;
      forever begin
         @(posedge int_detect);
         int_pulse = 1'b1;
         #1;
         int_pulse = 1'b0;
      end
   end
   always @(*)
      if (int_detect_asf_nonfatal & ~int_detect_asf_nonfatal_del)
         begin
            int_clock_pulse_asf_nonfatal = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet ASF Non-fatal interrupt\n");
          `endif
         end
      else
         int_clock_pulse_asf_nonfatal = 1'b0;
   initial begin
      int_pulse_asf_nonfatal = 1'b0;
      forever begin
         @(posedge int_detect_asf_nonfatal);
         int_pulse_asf_nonfatal = 1'b1;
         #1;
         int_pulse_asf_nonfatal = 1'b0;
      end
   end
   always @(*)
      if (int_detect_asf_fatal & ~int_detect_asf_fatal_del)
         begin
            int_clock_pulse_asf_fatal = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet ASF fatal interrupt\n");
          `endif
         end
      else
         int_clock_pulse_asf_fatal = 1'b0;
   initial begin
      int_pulse_asf_fatal = 1'b0;
      forever begin
         @(posedge int_detect_asf_fatal);
         int_pulse_asf_fatal = 1'b1;
         #1;
         int_pulse_asf_fatal = 1'b0;
      end
   end
   always @(*)
      if (int_detect_emac_asf_nonfatal & ~int_detect_emac_asf_nonfatal_del)
         begin
            int_clock_pulse_emac_asf_nonfatal = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet eMAC ASF Non-fatal interrupt\n");
          `endif
         end
      else
         int_clock_pulse_emac_asf_nonfatal = 1'b0;
   initial begin
      int_pulse_emac_asf_nonfatal = 1'b0;
      forever begin
         @(posedge int_detect_emac_asf_nonfatal);
         int_pulse_emac_asf_nonfatal = 1'b1;
         #1;
         int_pulse_emac_asf_nonfatal = 1'b0;
      end
   end
   always @(*)
      if (int_detect_emac_asf_fatal & ~int_detect_emac_asf_fatal_del)
         begin
            int_clock_pulse_emac_asf_fatal = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet eMAC ASF fatal interrupt\n");
          `endif
         end
      else
         int_clock_pulse_emac_asf_fatal = 1'b0;
   initial begin
      int_pulse_emac_asf_fatal = 1'b0;
      forever begin
         @(posedge int_detect_emac_asf_fatal);
         int_pulse_emac_asf_fatal = 1'b1;
         #1;
         int_pulse_emac_asf_fatal = 1'b0;
      end
   end
   always @(*)
      if (int_detect_emac & ~int_detect_emac_del)
         begin
            int_clock_pulse_emac = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet eMAC interrupt\n");
          `endif
         end
      else
         int_clock_pulse_emac = 1'b0;
   initial begin
      int_pulse_emac = 1'b0;
      forever begin
         @(posedge int_detect_emac);
         int_pulse_emac = 1'b1;
         #1;
         int_pulse_emac = 1'b0;
      end
   end
   always @(*)
      if (int_detect_mmsl & ~int_detect_mmsl_del)
         begin
            int_clock_pulse_mmsl = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an MMSL interrupt\n");
          `endif
         end
      else
         int_clock_pulse_mmsl = 1'b0;
   initial begin
      int_pulse_mmsl = 1'b0;
      forever begin
         @(posedge int_detect_mmsl);
         int_pulse_mmsl = 1'b1;
         #1;
         int_pulse_mmsl = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q15 & ~int_detect_q15_del)
         begin
            int_clock_pulse_q15 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 15)\n");
          `endif
         end
      else
         int_clock_pulse_q15 = 1'b0;
   initial begin
      int_pulse_q15 = 1'b0;
      forever begin
         @(posedge int_detect_q15);
         int_pulse_q15 = 1'b1;
         #1;
         int_pulse_q15 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q14 & ~int_detect_q14_del)
         begin
            int_clock_pulse_q14 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 14)\n");
          `endif
         end
      else
         int_clock_pulse_q14 = 1'b0;
   initial begin
      int_pulse_q14 = 1'b0;
      forever begin
         @(posedge int_detect_q14);
         int_pulse_q14 = 1'b1;
         #1;
         int_pulse_q14 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q13 & ~int_detect_q13_del)
         begin
            int_clock_pulse_q13 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 13)\n");
          `endif
         end
      else
         int_clock_pulse_q13 = 1'b0;
   initial begin
      int_pulse_q13 = 1'b0;
      forever begin
         @(posedge int_detect_q13);
         int_pulse_q13 = 1'b1;
         #1;
         int_pulse_q13 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q12 & ~int_detect_q12_del)
         begin
            int_clock_pulse_q12 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 12)\n");
          `endif
         end
      else
         int_clock_pulse_q12 = 1'b0;
   initial begin
      int_pulse_q12 = 1'b0;
      forever begin
         @(posedge int_detect_q12);
         int_pulse_q12 = 1'b1;
         #1;
         int_pulse_q12 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q11 & ~int_detect_q11_del)
         begin
            int_clock_pulse_q11 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 11)\n");
          `endif
         end
      else
         int_clock_pulse_q11 = 1'b0;
   initial begin
      int_pulse_q11 = 1'b0;
      forever begin
         @(posedge int_detect_q11);
         int_pulse_q11 = 1'b1;
         #1;
         int_pulse_q11 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q10 & ~int_detect_q10_del)
         begin
            int_clock_pulse_q10 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 10)\n");
          `endif
         end
      else
         int_clock_pulse_q10 = 1'b0;
   initial begin
      int_pulse_q10 = 1'b0;
      forever begin
         @(posedge int_detect_q10);
         int_pulse_q10 = 1'b1;
         #1;
         int_pulse_q10 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q9 & ~int_detect_q9_del)
         begin
            int_clock_pulse_q9 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 9)\n");
          `endif
         end
      else
         int_clock_pulse_q9 = 1'b0;
   initial begin
      int_pulse_q9 = 1'b0;
      forever begin
         @(posedge int_detect_q9);
         int_pulse_q9 = 1'b1;
         #1;
         int_pulse_q9 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q8 & ~int_detect_q8_del)
         begin
            int_clock_pulse_q8 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 8)\n");
          `endif
         end
      else
         int_clock_pulse_q8 = 1'b0;
   initial begin
      int_pulse_q8 = 1'b0;
      forever begin
         @(posedge int_detect_q8);
         int_pulse_q8 = 1'b1;
         #1;
         int_pulse_q8 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q7 & ~int_detect_q7_del)
         begin
            int_clock_pulse_q7 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 7)\n");
          `endif
         end
      else
         int_clock_pulse_q7 = 1'b0;
   initial begin
      int_pulse_q7 = 1'b0;
      forever begin
         @(posedge int_detect_q7);
         int_pulse_q7 = 1'b1;
         #1;
         int_pulse_q7 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q6 & ~int_detect_q6_del)
         begin
            int_clock_pulse_q6 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 6)\n");
          `endif
         end
      else
         int_clock_pulse_q6 = 1'b0;
   initial begin
      int_pulse_q6 = 1'b0;
      forever begin
         @(posedge int_detect_q6);
         int_pulse_q6 = 1'b1;
         #1;
         int_pulse_q6 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q5 & ~int_detect_q5_del)
         begin
            int_clock_pulse_q5 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 5)\n");
          `endif
         end
      else
         int_clock_pulse_q5 = 1'b0;
   initial begin
      int_pulse_q5 = 1'b0;
      forever begin
         @(posedge int_detect_q5);
         int_pulse_q5 = 1'b1;
         #1;
         int_pulse_q5 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q4 & ~int_detect_q4_del)
         begin
            int_clock_pulse_q4 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 4)\n");
          `endif
         end
      else
         int_clock_pulse_q4 = 1'b0;
   initial begin
      int_pulse_q4 = 1'b0;
      forever begin
         @(posedge int_detect_q4);
         int_pulse_q4 = 1'b1;
         #1;
         int_pulse_q4 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q3 & ~int_detect_q3_del)
         begin
            int_clock_pulse_q3 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 3)\n");
          `endif
         end
      else
         int_clock_pulse_q3 = 1'b0;
   initial begin
      int_pulse_q3 = 1'b0;
      forever begin
         @(posedge int_detect_q3);
         int_pulse_q3 = 1'b1;
         #1;
         int_pulse_q3 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q2 & ~int_detect_q2_del)
         begin
            int_clock_pulse_q2 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 2)\n");
          `endif
         end
      else
         int_clock_pulse_q2 = 1'b0;
   initial begin
      int_pulse_q2 = 1'b0;
      forever begin
         @(posedge int_detect_q2);
         int_pulse_q2 = 1'b1;
         #1;
         int_pulse_q2 = 1'b0;
      end
   end
   always @(*)
      if (int_detect_q1 & ~int_detect_q1_del)
         begin
            int_clock_pulse_q1 = 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench has detected an ethernet MAC interrupt (Queue 1)\n");
          `endif
         end
      else
         int_clock_pulse_q1 = 1'b0;
   initial begin
      int_pulse_q1 = 1'b0;
      forever begin
         @(posedge int_detect_q1);
         int_pulse_q1 = 1'b1;
         #1;
         int_pulse_q1 = 1'b0;
      end
   end


// -----------------------------------------------------------------------------
// testbench event counter and triggers
// -----------------------------------------------------------------------------

   // after reset count every testbench clock cycle and set triggers when
   // event count value is matched
   always @( negedge (reset_tb) or posedge (clk_tb) )
   begin
      if (~reset_tb)
         begin
            count             <= 24'hFFFFFF;
            rx_trig           <= 1'b0;
            pcs_rx_trig       <= 1'b0;
            apb_trig          <= 1'b0;
            pins_drive_trig   <= 1'b0;
            pins_check_trig   <= 1'b0;
            filter_drive_trig <= 1'b0;
            end_trig          <= 1'b0;
            event_index       <= 1;
         end

      // counter has reach match value so drive appropriate trigger
      else if (count == event_count)
         begin
            // set triggers
            rx_trig           <= event_vector[24];
            pcs_rx_trig       <= event_vector[29];
            apb_trig          <= event_vector[25];
            pins_drive_trig   <= event_vector[26];
            pins_check_trig   <= event_vector[27];
            filter_drive_trig <= event_vector[30];
            end_trig          <= event_vector[28];

            // continue incrementing counts
            count             <= count + 24'h000001;
            event_index       <= event_index + 1;
         end
      else
         begin
            // keep triggers low
            rx_trig           <= 1'b0;
            pcs_rx_trig       <= 1'b0;
            apb_trig          <= 1'b0;
            pins_drive_trig   <= 1'b0;
            pins_check_trig   <= 1'b0;
            filter_drive_trig <= 1'b0;
            end_trig          <= 1'b0;

            // continue incrementing count (but event_index doesn't change)
            count             <= count + 24'h000001;
            event_index       <= event_index;
         end
   end


// -----------------------------------------------------------------------------
// display messages to screen and test log
// -----------------------------------------------------------------------------

   // display message every time a trigger is asserted or every 1000 cycles
   always @( negedge (reset_tb) or posedge (clk_tb) )
   begin
      if (apb_trig | rx_trig | pcs_rx_trig | end_trig |
          ((count % 1000 == 0) & (count != 24'h000000)))
         $display("Event count has reached:- %d",count);
      if (rx_trig)
         $display("Triggering rx activity");
      if (pcs_rx_trig)
         $display("Triggering pcs_rx activity");
      if (apb_trig)
         $display("Triggering register access");
      if (filter_drive_trig)
         $display("Driving external filter pins:- %d",count );
      if (end_trig)
         $display("Forcing end of test case");
   end


endmodule
