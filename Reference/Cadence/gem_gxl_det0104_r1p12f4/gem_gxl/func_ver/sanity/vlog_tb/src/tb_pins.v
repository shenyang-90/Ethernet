//------------------------------------------------------------------------------
// Copyright (c) 2000-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_pins.v
//   Module Name:        tb_pins
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
//   Description : System on Chip Kernel testbench ethernet module
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_pins (

   reset_tb,
   clk_tb,

   loopback,
   half_duplex,
   ethernet_int,
   speed,
   mii_select,
   `ifdef gem_user_io
   user_out,
   `endif // gem_user_io
   wol,
   en_cdet,
   ewrap,
   sof_tx,
   sync_frame_tx,
   delay_req_tx,
   pdelay_req_tx,
   pdelay_resp_tx,
   sof_rx,
   sync_frame_rx,
   delay_req_rx,
   pdelay_req_rx,
   pdelay_resp_rx,
   pfc_negotiate,
   rx_pfc_paused,
   `ifdef edma_tsu
   edma_tsu_inc_ctrl,
   edma_tsu_ms,
   tsu_timer_cmp_val,
   `endif // edma_tsu

   ext_interrupt_int,
   eam,
   drive_reset,
   drive_crs,
   tx_en_crs,
   col_sqe_en,
   tx_pause,
   tx_pause_zero,
   tx_pfc_sel,
   tx_pfc_pause,
   tx_pfc_pause_zero,
   trigger_dma_tx_start,
   pcs_cal_bypass,
   pcs_cgalign_bypass,
   signal_detect,
   force_rx_er,
   force_back_pressure,
   `ifdef gem_user_io
   user_in,
   `endif // gem_user_io
   tb_rx_bit_slip,
   keep_idle_i1,
   tb_mode_2_5g,
   amba_par_err_inj,
   // ASF comman output error indications
`ifdef edma_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
   asf_sram_corr_err,
   `endif
   `ifdef gem_asf_dap_prot
   asf_sram_uncorr_err,
   `endif
`endif
   `ifdef gem_asf_integrity_prot
   asf_integrity_err,
   `endif
   `ifdef gem_asf_dap_prot
   asf_dap_err,
   `endif
   `ifdef gem_asf_csr_prot
   asf_csr_err,
   `endif
   asf_trans_to_err,
   asf_protocol_err,
   // ASF and fatal and non-fatal interrupts
   asf_int_nonfatal,
   asf_int_fatal,

   `ifdef gem_has_802p3_br
   // ASF comman output error indications for emac
`ifdef edma_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
   emac_asf_sram_corr_err,
   `endif
   `ifdef gem_asf_dap_prot
   emac_asf_sram_uncorr_err,
   `endif
`endif
   `ifdef gem_asf_integrity_prot
   emac_asf_integrity_err,
   `endif
   `ifdef gem_asf_dap_prot
   emac_asf_dap_err,
   `endif
   `ifdef gem_asf_csr_prot
   emac_asf_csr_err,
   `endif
   emac_asf_trans_to_err,
   emac_asf_protocol_err,
   // ASF and fatal and non-fatal interrupts for emac
   emac_asf_int_nonfatal,
   emac_asf_int_fatal,
   `endif
   count,
   trig_from_apb,
   pins_check_trig,
   pins_drive_trig,
   int_pulse,
   pins_done,
   pins_fail

);

// -----------------------------------------------------------------------------
// Declare inputs and outputs
// -----------------------------------------------------------------------------

   // system inputs
   input          reset_tb;            // testbench active low reset
   input          clk_tb;              // testbench clock

   // pins to be checked
   input          loopback;            // loopback signal to the PHY
   input          half_duplex;         // half duplex signal to the PHY
   input          ethernet_int;        // ethernet MAC interrupt signal
   input          speed;               // 10/100M indicator.
   `ifdef gem_user_io
   input  [(`gem_user_out_width - 1):0]// programmable user outputs
                  user_out;            // from top level
   `endif // gem_user_io
   input          wol;                 // Wake-on_LAN output
   input          en_cdet;             // Enable comma alignment in PMA.
   input          ewrap;               // Enable PHY loopback
   input          sof_tx;              // asserted on SFD deasserted at EOF
   input          sync_frame_tx;       // asserted if PTP sync frame is detected
   input          delay_req_tx;        // asserted if PTP delay_req is detected
   input          pdelay_req_tx;       // asserted if PTP pdelay_req is detected
   input          pdelay_resp_tx;      // asserted if PTP pdelay_resp is detected
   input          sof_rx;              // asserted on SFD deasserted at EOF
   input          sync_frame_rx;       // asserted if PTP sync frame is detected
   input          delay_req_rx;        // asserted if PTP delay_req is detected
   input          pdelay_req_rx;       // asserted if PTP pdelay_req is detected
   input          pdelay_resp_rx;      // asserted if PTP pdelay_resp is detected
   input          pfc_negotiate;       // indicates a received PFC
                                       // pause frame

   input [7:0]    rx_pfc_paused;       // each bit is set when PFC frame has
                                       // been received and the associated
                                       // PFC counter != 0
   `ifdef edma_tsu
   output   [1:0] edma_tsu_inc_ctrl;    // controls TSU timer increment
   output         edma_tsu_ms;          // TSU master/slave select
   input          tsu_timer_cmp_val;   // TSU timer comparison valid
   `endif // edma_tsu

   // pins to be driven
   output         mii_select;          // choose mii or rmii I/F
                                       // 0 - rmii, 1 - mii (default to 1)
   output         ext_interrupt_int;   // external interrupt to the MAC
   output         eam;                 // external address match
   output         drive_reset;         // reset control
   output         drive_crs;           // carrier sense
   output         tx_en_crs;           // drives carrier sense during transmit
   output         col_sqe_en;          // causes col to be driven at end of tx
   output         tx_pause;            // transmit pause frame. If toggled
                                       // causes a pause frame to be txed
   output         tx_pause_zero;       // use zero quantum in tx pause frame
   output         tx_pfc_sel;          // When set to 0, transmit 802.3
                                       // pause frame
                                       // When set to 1, transmit PFC
                                       // pause frame

   output    [7:0] tx_pfc_pause;       // priority enable vector of the
                                       // PFC pause frame
   output    [7:0] tx_pfc_pause_zero;  // When set to 1, PFC pause frame
                                       // has zero pause quantum
                                       // When set to 0, PFC pause frame
                                       // has the value of transmit pause
   output          trigger_dma_tx_start;  //
   output         pcs_cal_bypass;      // Bypass comma alignment function
   output         pcs_cgalign_bypass;  // Bypass codegroup alignment function
   output         signal_detect;       // Valid link detected from PMD.
   output         force_rx_er;         // force rx_er high
   output         force_back_pressure; // External back pressure
   `ifdef gem_user_io
   output [(`gem_user_in_width - 1):0] // programmable user inputs
                  user_in;             // to top level
   `endif // gem_user_io

   output [7:0]   tb_rx_bit_slip;
   output         keep_idle_i1;
   output         tb_mode_2_5g;        // Set up for 2.5G SGMII

   output         amba_par_err_inj;   // Force parity error on rdata

   // ASF comman output error indications
`ifdef edma_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
   input         asf_sram_corr_err;             // SRAM correctable error indication
   `endif
   `ifdef gem_asf_dap_prot
   input         asf_sram_uncorr_err;           // SRAM uncorrectable error indication
   `endif
`endif
   `ifdef gem_asf_integrity_prot
   input         asf_integrity_err;             // Integrity error indication
   `endif
   `ifdef gem_asf_dap_prot
   input         asf_dap_err;                   // Data and Address Paths error indication
   `endif
   `ifdef gem_asf_csr_prot
   input         asf_csr_err;                   // Configuration and Status Registers error indication
   `endif
   input         asf_trans_to_err;              // Transaction Timeouts indication
   input         asf_protocol_err;              // Protocol error indication
   // ASF and fatal and non-fatal interrupts
   input         asf_int_nonfatal;              // ASF non-fatal interrupt
   input         asf_int_fatal;                 // ASF fatal interrupt

   `ifdef gem_has_802p3_br
   // ASF comman output error indications for emac
`ifdef edma_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
   input         emac_asf_sram_corr_err;        // SRAM correctable error indication
   `endif
   `ifdef gem_asf_dap_prot
   input         emac_asf_sram_uncorr_err;      // SRAM uncorrectable error indication
   `endif
`endif
   `ifdef gem_asf_integrity_prot
   input         emac_asf_integrity_err;        // Integrity error indication
   `endif
   `ifdef gem_asf_dap_prot
   input         emac_asf_dap_err;              // Data and Address Paths error indication
   `endif
   `ifdef gem_asf_csr_prot
   input         emac_asf_csr_err;              // Configuration and Status Registers error indication
   `endif
   input         emac_asf_trans_to_err;         // Transaction Timeouts indication
   input         emac_asf_protocol_err;         // Protocol error indication
   // ASF and fatal and non-fatal interrupts for emac
   input         emac_asf_int_nonfatal;         // ASF non-fatal interrupt
   input         emac_asf_int_fatal;            // ASF fatal interrupt
   `endif

   // control stuff
   input  [23:0]  count;               // event count value for reporting
   input          trig_from_apb;       // trigger from apb activity
   input          pins_check_trig;     // trigger for pin checking
   input          pins_drive_trig;     // trigger for pin driving
   input          int_pulse;           // trigger from an interrupt
   output         pins_done;           // tb_pins all done (checking & driving)
   output         pins_fail;           // tb_pins has failed checking

// -----------------------------------------------------------------------------
// Declare internal signals
// -----------------------------------------------------------------------------

   // test data arrays, initialised from test data files
   integer        j;                   // loop variable used for arrays
   reg     [94:0] pins_check_vector_reg[1:500];
                                       // array for holding pin checking data
   integer        pins_check_index;    // pointer to current pins_check_vector
   wire    [94:0] pins_check_vector;   // current pins_check_vector_reg
   wire    [94:0] pins_check_vector_nxt;// next pins_check_vector_reg
   wire     [2:0] pins_check_control;  // determines what will trigger
                                       // a pin checking cycle
   wire     [2:0] pins_check_control_nxt;// Next pins_check_control
   reg     [81:0] pins_drive_vector_reg[1:500];
                                       // array for holding pin driving data
   integer        pins_drive_index;    // pointer to current pins_drive_vector
   wire    [81:0] pins_drive_vector;   // current pins_drive_vector_reg
   wire     [2:0] pins_drive_control;  // determines what will trigger
                                       // a pin driving cycle

   // trigger synchronisation and detection
   reg            trig_from_apb_latch; // latches trig_from_apb signal
   reg            trig_from_apb_ack1;  // clears trig_from_apb_latch
   reg            trig_from_apb_ack2;  // clears trig_from_apb_latch
   reg            check_pins;          // initiates a pin checking cycle
   reg            drive_pins;          // initiates a pin driving cycle

   // output registers for pins driving
   reg            mii_select;          // selects mii or rmii i/f
   reg            ext_interrupt_int;   // external interrupt to the MAC
   reg            eam;                 // external address match
   reg            drive_reset;         // reset control
   reg            drive_crs;           // carrier sense
   reg            tx_en_crs;           // drives carrier sense during transmit
   reg            col_sqe_en;          // causes col to be driven at end of tx
   reg            tx_pause;            // transmit pause frame. If toggled
                                       // causes a pause frame to be txed
   reg            tx_pause_zero;       // use zero quantum in tx pause frame
   reg            tx_pfc_sel;          // When set to 0, transmit 802.3
                                       // pause frame
                                       // When set to 1, transmit PFC
                                       // pause frame

   reg    [7:0]   tx_pfc_pause;        // priority enable vector of the
                                       // PFC pause frame
   reg    [7:0]   tx_pfc_pause_zero;   // When set to 1, PFC pause frame
                                       // has zero pause quantum
                                       // When set to 0, PFC pause frame
                                       // has the value of transmit pause
   reg            trigger_dma_tx_start;   // Trigger the TX START mechanism
   reg            pcs_cal_bypass;      // Bypass comma alignment function
   reg            pcs_cgalign_bypass;  // Bypass codegroup alignment function
   reg            signal_detect;       // Valid link detected from PMD.
   reg            force_rx_er;         // force rx_er high
   reg            force_back_pressure; // force ext back pressure
   `ifdef gem_user_io
   reg [(`gem_user_in_width - 1):0]    // programmable user inputs
                  user_in;             // to top level
   `endif // gem_user_io
   `ifdef edma_tsu
   reg      [1:0] edma_tsu_inc_ctrl;    // controls TSU timer increment
   reg            edma_tsu_ms;          // TSU master/slave select
   `endif // edma_tsu

   reg      [7:0] tb_rx_bit_slip;
   reg            keep_idle_i1;
   reg            tb_mode_2_5g;

   reg            amba_par_err_inj;

   // testbecnh reporting to top level testbench
   wire           pins_done;           // tb_pins all done (checking & driving)
   reg            pins_fail;           // tb_pins has failed checking



// -----------------------------------------------------------------------------
// initialise arrays from test file
// -----------------------------------------------------------------------------

  // read pins data
  initial
     begin
        for (j=1; j<=500; j=j+1)
         begin
           pins_check_vector_reg[j] = 73'b0;
           pins_drive_vector_reg[j] = 82'b0;
         end

        $readmemb("./files/tb_check_pins.data",pins_check_vector_reg);
        $readmemb("./files/tb_drive_pins.data",pins_drive_vector_reg);

        if (pins_check_vector_reg[1] === 73'hx)
           begin
              $display("\n No check pins data file read \n");
           end
        if (pins_drive_vector_reg[1] === 82'hx)
           begin
              $display("\n No drive pins data file read \n");
           end
    end

// -----------------------------------------------------------------------------
// Decode current vectors
// -----------------------------------------------------------------------------

   // get current vectors using index value
   assign pins_check_vector = pins_check_vector_reg[pins_check_index];
   assign pins_drive_vector = pins_drive_vector_reg[pins_drive_index];

   // Next vector look ahead for pins check
   assign pins_check_vector_nxt = pins_check_vector_reg[pins_check_index+1];

   // control triggers
   // 0  end-stop
   // 1  wait for trigger
   // 2  wait for interrupt
   // 3  wait for APB trigger
   // 4  keep going
   assign pins_drive_control      = pins_drive_vector[81:79];
   assign pins_check_control      = pins_check_vector[94:92];
   assign pins_check_control_nxt  = pins_check_vector_nxt[94:92];


   // signal when all checking and driving done
   assign pins_done = (pins_check_control == 3'b000) & // checking complete
                      (pins_drive_control == 3'b000);  // driving complete


// -----------------------------------------------------------------------------
// Maintain index to arrays
// -----------------------------------------------------------------------------

   // When check is performed get next vector by incrementing index to array
   always @( negedge (reset_tb) or posedge (clk_tb) )
   begin
      if (~reset_tb)
         pins_check_index <= 1;
      else if (check_pins)
         pins_check_index <= pins_check_index + 1;
   end


   // When drive is performed get next vector by incrementing index to array
   always @( negedge (reset_tb) or posedge (clk_tb) )
   begin
      if (~reset_tb)
         pins_drive_index <= 1;
      else if (drive_pins)
         pins_drive_index <= pins_drive_index + 1;
   end



// -----------------------------------------------------------------------------
// Detect triggers and use to generate new drive or check
// -----------------------------------------------------------------------------

   // synchronise trig_from_apb signal pulse
   always @(trig_from_apb or trig_from_apb_ack1 or trig_from_apb_ack2 or
            reset_tb)
   if (~reset_tb)
      trig_from_apb_latch = 1'b0;
   else if (trig_from_apb_ack1 | trig_from_apb_ack2)
      trig_from_apb_latch = 1'b0;
   else if (trig_from_apb)
      trig_from_apb_latch = 1'b1;


   // pin checking control
   always @( negedge (reset_tb) or posedge (clk_tb) )
   if (~reset_tb)
      begin
         check_pins         <= 1'b0;
         trig_from_apb_ack1 <= 1'b0;
      end
   else if (pins_check_trig & (pins_check_control == 3'b001))
      begin
         check_pins <= 1'b1;
         $display("Checking pins because event count has reached:- %d",count);
      end
   else if (int_pulse & (pins_check_control == 3'b010))
      begin
         check_pins <= 1'b1;
         $display("Checking pins because interrupt occured at:- %d",count);
      end
   else if (trig_from_apb_latch & (pins_check_control == 3'b011))
      begin
         check_pins <= 1'b1;
         $display("Checking pins because of trigger from APB activity at count %d",count);
         trig_from_apb_ack1 <= 1'b1;
      end
   else if (check_pins & pins_check_control_nxt == 3'b100)
      begin
         // continue checking until new wait control found
         check_pins <= 1'b1;
      end
   else
      begin
         check_pins         <= 1'b0;
         trig_from_apb_ack1 <= 1'b0;
      end


   // pin driving control
   always @( negedge (reset_tb) or posedge (clk_tb) )
   if (~reset_tb)
      begin
         drive_pins         <= 1'b0;
         trig_from_apb_ack2 <= 1'b0;
      end
   else if (pins_drive_trig & (pins_drive_control == 3'b001))
      begin
         drive_pins <= 1'b1;
         $display("Driving pins because event count has reached:- %d",count);
      end
   else if (int_pulse & (pins_drive_control == 3'b010))
      begin
         drive_pins <= 1'b1;
         $display("Driving pins because interrupt occured at:- %d",count);
      end
   else if (trig_from_apb_latch & (pins_drive_control == 3'b011))
      begin
         drive_pins <= 1'b1;
         $display("Driving pins because of trigger from APB activity at count %d",count);
         trig_from_apb_ack2 <= 1'b1;
      end
   else
      begin
         drive_pins         <= 1'b0;
         trig_from_apb_ack2 <= 1'b0;
      end



// -----------------------------------------------------------------------------
// Check input pins when commanded
// -----------------------------------------------------------------------------

   // Check pins
   always @( negedge (reset_tb) or posedge (clk_tb) )
   begin
      if (~reset_tb)
         pins_fail        <= 1'b0;

      else if (check_pins)
         begin

            // loopback pin check
            if (pins_check_vector[0] & (loopback !== pins_check_vector[1]))
               begin
                  $display(" **** ERROR read loopback pin     expected :- %h  got :- %h",pins_check_vector[1],loopback);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[0])
               begin
                  $display("       good read loopback pin     expected :- %h  got :- %h",pins_check_vector[1],loopback);
               end

            // The half duplex pin doesn't exist for xgm, so ignore
            // half_duplex pin check
            `ifndef xgm
            if (pins_check_vector[2] & (half_duplex !== pins_check_vector[3]))
               begin
                  $display(" **** ERROR read half_duplex pin  expected :- %h  got :- %h",pins_check_vector[3],half_duplex);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[2])
               begin
                  $display("       good read half_duplex pin  expected :- %h  got :- %h",pins_check_vector[3],half_duplex);
               end
            `endif

            // loopback pin ethernet_int
            if (pins_check_vector[4] & (ethernet_int !== pins_check_vector[5]))
               begin
                  $display(" **** ERROR read ethernet_int pin expected :- %h  got :- %h",pins_check_vector[5],ethernet_int);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[4])
               begin
                  $display("       good read ethernet_int pin expected :- %h  got :- %h",pins_check_vector[5],ethernet_int);
               end

            // speed pin check
            // The speed pin doesn't exist for xgm, so ignore
            // half_duplex pin check
            `ifndef xgm
            if (pins_check_vector[6] & (speed !== pins_check_vector[7]))
               begin
                  $display(" **** ERROR read speed pin expected :- %h  got :- %h",pins_check_vector[7],speed);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[6])
               begin
                  $display("       good read speed pin expected :- %h  got :- %h",pins_check_vector[7],speed);
               end
            `endif

            `ifdef gem_user_io
            // user_out pin check
            if (pins_check_vector[8] & (user_out !== pins_check_vector[16:9]))
               begin
                  $display(" **** ERROR read user_out pins expected :- %h  got :- %h",pins_check_vector[16:9],user_out);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[8])
               begin
                  $display("       good read user_out pins expected :- %h  got :- %h",pins_check_vector[16:9],user_out);
               end
            `endif // gem_user_io

            // wol pin check
            if (pins_check_vector[17] & (wol !== pins_check_vector[18]))
               begin
                  $display(" **** ERROR read wol pin expected :- %h  got :- %h. %0dns.",pins_check_vector[18],wol, $time);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[17])
               begin
                  $display("       good read wol pin expected :- %h  got :- %h",pins_check_vector[18],wol);
               end

            // en_cdet pin check
            if (pins_check_vector[19] & (en_cdet !== pins_check_vector[20]))
               begin
                  $display(" **** ERROR read en_cdet pin expected :- %h  got :- %h",pins_check_vector[20],en_cdet);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[19])
               begin
                  $display("       good read en_cdet pin expected :- %h  got :- %h",pins_check_vector[20],en_cdet);
               end

            // sof_tx pin check
            if (pins_check_vector[21] & (sof_tx !== pins_check_vector[22]))
               begin
                  $display(" **** ERROR read sof_tx pin expected :- %h  got :- %h. %0dns.",pins_check_vector[22],sof_tx, $time);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[21])
               begin
                  $display("       good read sof_tx pin expected :- %h  got :- %h",pins_check_vector[22],sof_tx);
               end

            // sync_frame_tx pin check
            if (pins_check_vector[23] & (sync_frame_tx !== pins_check_vector[24]))
               begin
                  $display(" **** ERROR read sync_frame_tx pin expected :- %h  got :- %h",pins_check_vector[24],sync_frame_tx);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[23])
               begin
                  $display("       good read sync_frame_tx pin expected :- %h  got :- %h",pins_check_vector[24],sync_frame_tx);
               end

            // delay_req_tx pin check
            if (pins_check_vector[25] & (delay_req_tx !== pins_check_vector[26]))
               begin
                  $display(" **** ERROR read delay_req_tx pin expected :- %h  got :- %h",pins_check_vector[26],delay_req_tx);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[25])
               begin
                  $display("       good read delay_req_tx pin expected :- %h  got :- %h",pins_check_vector[26],delay_req_tx);
               end

            // sof_rx pin check
            if (pins_check_vector[27] & (sof_rx !== pins_check_vector[28]))
               begin
                  $display(" **** ERROR read sof_rx pin expected :- %h  got :- %h. %0dns.",pins_check_vector[28],sof_rx, $time);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[27])
               begin
                  $display("       good read sof_rx pin expected :- %h  got :- %h",pins_check_vector[28],sof_rx);
               end

            // sync_frame_rx pin check
            if (pins_check_vector[29] & (sync_frame_rx !== pins_check_vector[30]))
               begin
                  $display(" **** ERROR read sync_frame_rx pin expected :- %h  got :- %h",pins_check_vector[30],sync_frame_rx);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[29])
               begin
                  $display("       good read sync_frame_rx pin expected :- %h  got :- %h",pins_check_vector[30],sync_frame_rx);
               end

            // delay_req_rx pin check
            if (pins_check_vector[31] & (delay_req_rx !== pins_check_vector[32]))
               begin
                  $display(" **** ERROR read delay_req_rx pin expected :- %h  got :- %h",pins_check_vector[32],delay_req_rx);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[31])
               begin
                  $display("       good read delay_req_rx pin expected :- %h  got :- %h",pins_check_vector[32],delay_req_rx);
               end

            // pfc_negotiate pin check
            if (pins_check_vector[33] & (pfc_negotiate !== pins_check_vector[34]))
               begin
                  $display(" **** ERROR read pfc_negotiate pin expected :- %h  got :- %h",pins_check_vector[34],pfc_negotiate);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[33])
               begin
                  $display("       good read pfc_negotiate pin expected :- %h  got :- %h",pins_check_vector[34],pfc_negotiate);
               end

            // rx_pfc_paused pin check
            if (pins_check_vector[35] & (rx_pfc_paused !== pins_check_vector[43:36]))
               begin
                  $display(" **** ERROR read rx_pfc_paused pin expected :- %h  got :- %h",pins_check_vector[43:36],rx_pfc_paused);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[35])
               begin
                  $display("       good read rx_pfc_paused pin expected :- %h  got :- %h",pins_check_vector[43:36],rx_pfc_paused);
               end

            // pdelay_req_tx pin check
            if (pins_check_vector[44] & (pdelay_req_tx !== pins_check_vector[45]))
               begin
                  $display(" **** ERROR read pdelay_req_tx pin expected :- %h  got :- %h",pins_check_vector[45],pdelay_req_tx);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[44])
               begin
                  $display("       good read pdelay_req_tx pin expected :- %h  got :- %h",pins_check_vector[45],pdelay_req_tx);
               end

            // pdelay_resp_tx pin check
            if (pins_check_vector[46] & (pdelay_resp_tx !== pins_check_vector[47]))
               begin
                  $display(" **** ERROR read pdelay_resp_tx pin expected :- %h  got :- %h",pins_check_vector[47],pdelay_resp_tx);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[46])
               begin
                  $display("       good read pdelay_resp_tx pin expected :- %h  got :- %h",pins_check_vector[47],pdelay_resp_tx);
               end

            // pdelay_req_rx pin check
            if (pins_check_vector[48] & (pdelay_req_rx !== pins_check_vector[49]))
               begin
                  $display(" **** ERROR read pdelay_req_rx pin expected :- %h  got :- %h",pins_check_vector[49],pdelay_req_rx);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[48])
               begin
                  $display("       good read pdelay_req_rx pin expected :- %h  got :- %h",pins_check_vector[49],pdelay_req_rx);
               end

            // pdelay_resp_rx pin check
            if (pins_check_vector[50] & (pdelay_resp_rx !== pins_check_vector[51]))
               begin
                  $display(" **** ERROR read pdelay_resp_rx pin expected :- %h  got :- %h",pins_check_vector[51],pdelay_resp_rx);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[50])
               begin
                  $display("       good read pdelay_resp_rx pin expected :- %h  got :- %h",pins_check_vector[51],pdelay_resp_rx);
               end

   `ifdef edma_tsu
            // tsu_timer_cmp_val pin check
            if (pins_check_vector[52] & (tsu_timer_cmp_val !== pins_check_vector[53]))
               begin
                  $display(" **** ERROR read tsu_timer_cmp_val pin expected :- %h  got :- %h",pins_check_vector[53],tsu_timer_cmp_val);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[52])
               begin
                  $display("       good read tsu_timer_cmp_val pin expected :- %h  got :- %h",pins_check_vector[53],tsu_timer_cmp_val);
               end
   `endif // edma_tsu

            // tsu_timer_cmp_val pin check
            if (pins_check_vector[54] & (ewrap !== pins_check_vector[55]))
               begin
                  $display(" **** ERROR read ewrap pin expected :- %h  got :- %h",pins_check_vector[55],ewrap);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[54])
               begin
                  $display("       good read ewrap pin expected :- %h  got :- %h",pins_check_vector[55],ewrap);
               end

`ifdef edma_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
            // asf_sram_corr_err pin check
            if (pins_check_vector[56] & (asf_sram_corr_err !== pins_check_vector[57]))
               begin
                  $display(" **** ERROR read asf_sram_corr_err pin expected :- %h  got :- %h",pins_check_vector[57],asf_sram_corr_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[56])
               begin
                  $display("       good read asf_sram_corr_err pin expected :- %h  got :- %h",pins_check_vector[57],asf_sram_corr_err);
               end
   `endif // gem_asf_ecc_sram

   `ifdef gem_asf_dap_prot
            // asf_sram_uncorr_err pin check
            if (pins_check_vector[58] & (asf_sram_uncorr_err !== pins_check_vector[59]))
               begin
                  $display(" **** ERROR read asf_sram_uncorr_err pin expected :- %h  got :- %h",pins_check_vector[59],asf_sram_uncorr_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[58])
               begin
                  $display("       good read asf_sram_uncorr_err pin expected :- %h  got :- %h",pins_check_vector[59],asf_sram_uncorr_err);
               end
   `endif // gem_asf_ecc_sram
`endif

   `ifdef gem_asf_dap_prot
            // asf_dap_err pin check
            if (pins_check_vector[60] & (asf_dap_err !== pins_check_vector[61]))
               begin
                  $display(" **** ERROR read asf_dap_err pin expected :- %h  got :- %h",pins_check_vector[61],asf_dap_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[60])
               begin
                  $display("       good read asf_dap_err pin expected :- %h  got :- %h",pins_check_vector[61],asf_dap_err);
               end
   `endif // gem_asf_dap_prot

   `ifdef gem_asf_csr_prot
            // asf_csr_err pin check
            if (pins_check_vector[62] & (asf_csr_err !== pins_check_vector[63]))
               begin
                  $display(" **** ERROR read asf_csr_err pin expected :- %h  got :- %h",pins_check_vector[63],asf_csr_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[62])
               begin
                  $display("       good read asf_csr_err pin expected :- %h  got :- %h",pins_check_vector[63],asf_csr_err);
               end
   `endif // gem_asf_csr_prot

            // asf_trans_to_err pin check
            if (pins_check_vector[64] & (asf_trans_to_err !== pins_check_vector[65]))
               begin
                  $display(" **** ERROR read asf_trans_to_err pin expected :- %h  got :- %h",pins_check_vector[65],asf_trans_to_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[64])
               begin
                  $display("       good read asf_trans_to_err pin expected :- %h  got :- %h",pins_check_vector[65],asf_trans_to_err);
               end
            // asf_protocol_err pin check
            if (pins_check_vector[66] & (asf_protocol_err !== pins_check_vector[67]))
               begin
                  $display(" **** ERROR read asf_protocol_err pin expected :- %h  got :- %h",pins_check_vector[67],asf_protocol_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[66])
               begin
                  $display("       good read asf_protocol_err pin expected :- %h  got :- %h",pins_check_vector[67],asf_protocol_err);
               end
`ifdef gem_asf_integrity_prot
            // asf_integrity_err pin check
            if (pins_check_vector[68] & (asf_integrity_err !== pins_check_vector[69]))
               begin
                  $display(" **** ERROR read asf_integrity_err pin expected :- %h  got :- %h",pins_check_vector[69],asf_integrity_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[68])
               begin
                  $display("       good read asf_integrity_err pin expected :- %h  got :- %h",pins_check_vector[69],asf_integrity_err);
               end
`endif
            // asf_int_nonfatal pin check
            if (pins_check_vector[70] & (asf_int_nonfatal !== pins_check_vector[71]))
               begin
                  $display(" **** ERROR read asf_int_nonfatal pin expected :- %h  got :- %h",pins_check_vector[71],asf_int_nonfatal);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[70])
               begin
                  $display("       good read asf_int_nonfatal pin expected :- %h  got :- %h",pins_check_vector[71],asf_int_nonfatal);
               end

            // asf_int_fatal pin check
            if (pins_check_vector[72] & (asf_int_fatal !== pins_check_vector[73]))
               begin
                  $display(" **** ERROR read asf_int_fatal pin expected :- %h  got :- %h",pins_check_vector[73],asf_int_fatal);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[72])
               begin
                  $display("       good read asf_int_fatal pin expected :- %h  got :- %h",pins_check_vector[73],asf_int_fatal);
               end

   `ifdef gem_has_802p3_br
`ifdef edma_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
            // emac_asf_sram_corr_err pin check
            if (pins_check_vector[74] & (emac_asf_sram_corr_err !== pins_check_vector[75]))
               begin
                  $display(" **** ERROR read emac_asf_sram_corr_err pin expected :- %h  got :- %h",pins_check_vector[75],emac_asf_sram_corr_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[74])
               begin
                  $display("       good read emac_asf_sram_corr_err pin expected :- %h  got :- %h",pins_check_vector[75],emac_asf_sram_corr_err);
               end
   `endif // gem_asf_ecc_sram

   `ifdef gem_asf_dap_prot
            // emac_asf_sram_uncorr_err pin check
            if (pins_check_vector[76] & (emac_asf_sram_uncorr_err !== pins_check_vector[77]))
               begin
                  $display(" **** ERROR read emac_asf_sram_uncorr_err pin expected :- %h  got :- %h",pins_check_vector[77],emac_asf_sram_uncorr_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[76])
               begin
                  $display("       good read emac_asf_sram_uncorr_err pin expected :- %h  got :- %h",pins_check_vector[77],emac_asf_sram_uncorr_err);
               end
   `endif // gem_asf_ecc_sram
`endif
   `ifdef gem_asf_dap_prot
            // emac_asf_dap_err pin check
            if (pins_check_vector[78] & (emac_asf_dap_err !== pins_check_vector[79]))
               begin
                  $display(" **** ERROR read emac_asf_dap_err pin expected :- %h  got :- %h",pins_check_vector[79],emac_asf_dap_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[78])
               begin
                  $display("       good read emac_asf_dap_err pin expected :- %h  got :- %h",pins_check_vector[79],emac_asf_dap_err);
               end
   `endif // gem_asf_dap_prot

   `ifdef gem_asf_csr_prot
            // emac_asf_csr_err pin check
            if (pins_check_vector[81] & (emac_asf_csr_err !== pins_check_vector[81]))
               begin
                  $display(" **** ERROR read emac_asf_csr_err pin expected :- %h  got :- %h",pins_check_vector[81],emac_asf_csr_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[81])
               begin
                  $display("       good read emac_asf_csr_err pin expected :- %h  got :- %h",pins_check_vector[81],emac_asf_csr_err);
               end
   `endif // gem_asf_csr_prot

            // emac_asf_trans_to_err pin check
            if (pins_check_vector[82] & (emac_asf_trans_to_err !== pins_check_vector[83]))
               begin
                  $display(" **** ERROR read emac_asf_trans_to_err pin expected :- %h  got :- %h",pins_check_vector[83],emac_asf_trans_to_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[82])
               begin
                  $display("       good read emac_asf_trans_to_err pin expected :- %h  got :- %h",pins_check_vector[83],emac_asf_trans_to_err);
               end

            // emac_asf_protocol_err pin check
            if (pins_check_vector[84] & (emac_asf_protocol_err !== pins_check_vector[85]))
               begin
                  $display(" **** ERROR read emac_asf_protocol_err pin expected :- %h  got :- %h",pins_check_vector[85],emac_asf_protocol_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[84])
               begin
                  $display("       good read emac_asf_protocol_err pin expected :- %h  got :- %h",pins_check_vector[85],emac_asf_protocol_err);
               end

`ifdef gem_asf_integrity_prot
            // emac_asf_integrity_err pin check
            if (pins_check_vector[86] & (emac_asf_integrity_err !== pins_check_vector[87]))
               begin
                  $display(" **** ERROR read emac_asf_integrity_err pin expected :- %h  got :- %h",pins_check_vector[87],emac_asf_integrity_err);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[86])
               begin
                  $display("       good read emac_asf_integrity_err pin expected :- %h  got :- %h",pins_check_vector[87],emac_asf_integrity_err);
               end
`endif
            // emac_asf_int_nonfatal pin check
            if (pins_check_vector[88] & (emac_asf_int_nonfatal !== pins_check_vector[89]))
               begin
                  $display(" **** ERROR read emac_asf_int_nonfatal pin expected :- %h  got :- %h",pins_check_vector[89],emac_asf_int_nonfatal);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[88])
               begin
                  $display("       good read emac_asf_int_nonfatal pin expected :- %h  got :- %h",pins_check_vector[89],emac_asf_int_nonfatal);
               end

            // emac_asf_int_fatal pin check
            if (pins_check_vector[90] & (emac_asf_int_fatal !== pins_check_vector[91]))
               begin
                  $display(" **** ERROR read emac_asf_int_fatal pin expected :- %h  got :- %h",pins_check_vector[91],emac_asf_int_fatal);
                  pins_fail <= 1'b1;
               end
            else if (pins_check_vector[90])
               begin
                  $display("       good read emac_asf_int_fatal pin expected :- %h  got :- %h",pins_check_vector[91],emac_asf_int_fatal);
               end
   `endif // gem_has_802p3_br


         end
      else
         pins_fail <= 1'b0;
   end


// -----------------------------------------------------------------------------
// Drive output pins when commanded
// -----------------------------------------------------------------------------

   // Drive pins
   always @( negedge (reset_tb) or posedge (clk_tb) )
   begin
      if (~reset_tb)
         begin
            ext_interrupt_int <= 1'b0;
            eam               <= 1'b0;
            drive_reset       <= 1'b1;
            drive_crs         <= 1'b0;
            tx_en_crs         <= 1'b1;
            col_sqe_en        <= 1'b1;
            tx_pause          <= 1'b0;
            tx_pause_zero     <= 1'b0;
            signal_detect     <= 1'b1;
            `ifdef gem_user_io
            user_in           <= {`gem_user_in_width{1'b0}};
            `endif // gem_user_io
            `ifdef edma_tsu
            edma_tsu_inc_ctrl  <= 2'b11;
            edma_tsu_ms        <= 1'b1;
            `endif // edma_tsu
            mii_select        <= 1'b1;
            force_rx_er       <= 1'b0;
            force_back_pressure <= 1'b0;
            tx_pfc_sel        <= 1'b0;
            tx_pfc_pause      <= 8'h00;
            tx_pfc_pause_zero <= 8'h00;
            trigger_dma_tx_start<= 1'b0;
            pcs_cal_bypass      <= 1'b0;
            pcs_cgalign_bypass  <= 1'b0;
            tb_rx_bit_slip      <= 8'h00;
            keep_idle_i1        <= 1'b0;
            tb_mode_2_5g        <= 1'b0;
            amba_par_err_inj    <= 1'b0;
         end
      else if (drive_pins)
         begin

            // drive external interrupt pin
            if (pins_drive_vector[0])
               begin
                  $display("Driving external interrupt with :- %h",pins_drive_vector[1]);
                  ext_interrupt_int <= pins_drive_vector[1];
               end

            // drive eeam pin
            if (pins_drive_vector[2])
               begin
                  $display("Driving eam pin with :- %h",pins_drive_vector[3]);
                  eam <= pins_drive_vector[3];
               end

            // drive n_preset pin
            if (pins_drive_vector[4])
               begin
                  $display("Driving n_preset pin with :- %h",pins_drive_vector[5]);
                  drive_reset <= pins_drive_vector[5];
               end

            // drive crs pin
            if (pins_drive_vector[6])
               begin
                  $display("Driving crs pin with :- %h",pins_drive_vector[7]);
                  drive_crs <= pins_drive_vector[7];
               end

            // drive crs pin when tx_en
            if (pins_drive_vector[8])
               begin
                  if (pins_drive_vector[9])
                     $display("crs pin will be driven when tx_en is asserted to prevent carrier sense errors");
                  else
                     $display("crs pin will not be driven when tx_en is asserted");
                  tx_en_crs <= pins_drive_vector[9];
               end

            // drive coll pin at end of transmit for SQE test
            if (pins_drive_vector[10])
               begin
                  if (pins_drive_vector[11])
                     $display("coll pin will be driven at end of transmit for SQE test");
                  else
                     $display("coll pin will not be driven at end of transmit");
                  col_sqe_en <= pins_drive_vector[11];
               end

            // drive tx_pause pin
            if (pins_drive_vector[12])
               begin
                  $display("Driving tx_pause pin with :- %h",pins_drive_vector[13]);
                  tx_pause <= pins_drive_vector[13];
               end

            // drive tx_pause_zero pin
            if (pins_drive_vector[14])
               begin
                  $display("Driving tx_pause_zero pin with :- %h",pins_drive_vector[15]);
                  tx_pause_zero <= pins_drive_vector[15];
               end

            // drive user_in pin
            `ifdef gem_user_io
            if (pins_drive_vector[16])
               begin
                  $display("Driving user_in pins with :- %h",pins_drive_vector[24:17]);
                  user_in <= pins_drive_vector[24:17];
               end
            `endif // gem_user_io

            // drive external interrupt pin
            if (pins_drive_vector[25])
               begin
                  $display("Driving signal_detect pin with :- %h",pins_drive_vector[26]);
                  signal_detect <= pins_drive_vector[26];
               end
            // drive mii/rmii select
            if (pins_drive_vector[27])
               begin
                  $display("Driving mii_select with :- %h",pins_drive_vector[28]);
                  mii_select <= pins_drive_vector[28];
               end

            `ifdef edma_tsu
            // drive edma_tsu_inc_ctrl
            if (pins_drive_vector[29])
               begin
                  $display("Driving edma_tsu_inc_ctrl pins with :- %h",pins_drive_vector[31:30]);
                  edma_tsu_inc_ctrl <= pins_drive_vector[31:30];
               end

            if (pins_drive_vector[32])
               begin
                  $display("Driving edma_tsu_ms pins with :- %h",pins_drive_vector[33]);
                  edma_tsu_ms <= pins_drive_vector[33];
               end
            `endif // edma_tsu

            if (pins_drive_vector[34])
               begin
                  $display("Driving rx_er pin with :- %h",pins_drive_vector[35]);
                  force_rx_er <= pins_drive_vector[35];
               end

            if (pins_drive_vector[36])
               begin
                  $display("Driving force_back_pressure pin with :- %h",pins_drive_vector[37]);
                  force_back_pressure <= pins_drive_vector[37];
               end

            // drive tx_pfc_sel pin
            if (pins_drive_vector[38])
               begin
                  $display("Driving tx_pfc_sel pin with :- %h",pins_drive_vector[39]);
                  tx_pfc_sel <= pins_drive_vector[39];
               end

            // drive tx_pfc_pause pin
            if (pins_drive_vector[40])
               begin
                  $display("Driving tx_pfc_pause pin with :- %h",pins_drive_vector[48:41]);
                  tx_pfc_pause <= pins_drive_vector[48:41];
               end

            // drive tx_pfc_pause_zero pin
            if (pins_drive_vector[49])
               begin
                  $display("Driving tx_pfc_pause_zero pin with :- %h",pins_drive_vector[57:50]);
                  tx_pfc_pause_zero <= pins_drive_vector[57:50];
               end

            // drive trigger_dma_tx_start pin
            if (pins_drive_vector[58])
               begin
                  $display("Driving trigger_dma_tx_start pin with :- %h",pins_drive_vector[59]);
                  trigger_dma_tx_start <= pins_drive_vector[59];
               end

            // drive pcs_cal_bypass pin
            if (pins_drive_vector[60])
               begin
                  $display("Driving pcs_cal_bypass pin with :- %h",pins_drive_vector[61]);
                  pcs_cal_bypass <= pins_drive_vector[61];
               end

            // drive pcs_cgalign_bypass pin
            if (pins_drive_vector[62])
               begin
                  $display("Driving pcs_cgalign_bypass pin with :- %h",pins_drive_vector[63]);
                  pcs_cgalign_bypass <= pins_drive_vector[63];
               end

            // drive tb_rx_bit_slip pin
            if (pins_drive_vector[64])
               begin
                  $display("Driving tb_rx_bit_slip pin with :- %h",pins_drive_vector[72:65]);
                  tb_rx_bit_slip <= pins_drive_vector[72:65];
               end

            // drive keep_idle_i1 pin
            if (pins_drive_vector[73])
               begin
                  $display("Driving tb keep_idle_i1 pin with :- %h",pins_drive_vector[74]);
                  keep_idle_i1 <= pins_drive_vector[74];
               end

            // drive tb_mode_2_5g pin
            if (pins_drive_vector[75])
               begin
                  $display("Driving tb_mode_2_5g pin with :- %h",pins_drive_vector[76]);
                  tb_mode_2_5g <= pins_drive_vector[76];
               end

            // drive amba_par_err_inj pin
            if (pins_drive_vector[77])
               begin
                  $display("Driving amba_par_err_inj pin with :- %h",pins_drive_vector[78]);
                  amba_par_err_inj <= pins_drive_vector[78];
               end


         end
   end


endmodule

