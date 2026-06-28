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
//   Filename:           tb_filter.v
//   Module Name:        tb_filter
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
//   Description    : This module checks the external address matching functionality.
//
//------------------------------------------------------------------------------


module tb_filter (

   reset_tb,
   mac_rx_clk,
   tbi_rx_clk,

   count,
   trig_from_apb,
   int_pulse,
   filter_drive_trig,
   rx_group,
   tbi,

   filter_done,
   filter_fail,

   rx_dv,

   ext_da,
   ext_da_stb,
   ext_sa,
   ext_sa_stb,
   ext_type,
   ext_type_stb,
   ext_vid,
   ext_vid_stb,
   ext_ip_sa,
   ext_ip_sa_stb,
   ext_ip_da,
   ext_ip_da_stb,
   ext_source_port,
   ext_sp_stb,
   ext_dest_port,
   ext_dp_stb,
   ext_ipv6,
   sync_frame_rx,
   delay_req_rx,
   pdelay_req_rx,
   pdelay_resp_rx,
   ext_vlan_tag1_stb,
   ext_vlan_tag1,
   ext_vlan_tag2_stb,
   ext_vlan_tag2,
   ext_match1,
   ext_match2,
   ext_match3,
   ext_match4
);

// -----------------------------------------------------------------------------
// Declare inputs and outputs
// -----------------------------------------------------------------------------
   // system signals
   input          reset_tb;            // testbench reset
   input          mac_rx_clk;          // rx_clk to MAC
   input          tbi_rx_clk;          // rx_clk to PCS

   // testbench control signals
   input   [23:0] count;               // current value of event count
   input          trig_from_apb;       // trigger from apb activity
   input          int_pulse;           // interrupt trigger
   input          filter_drive_trig;   // drive filter pin trigger from tb_event
   input    [9:0] rx_group;            // used to detect EOP in TBI mode
   input          tbi;                 // selects tbi mode

   output         filter_done;         // filter tb complete
   output         filter_fail;         // filter tb failed

   // rx_dv
   input          rx_dv;               // used for detecting rx EOF

   // filter interface signals
   input   [47:0] ext_da;              // stored destination address from the
                                       // receive data
   input          ext_da_stb;          // set when destination address valid
   input   [47:0] ext_sa;              // stored source address from the
                                       // receive data
   input          ext_sa_stb;          // set when source address valid
   input   [15:0] ext_type;            // stored length field from the
                                       // receive frame
   input          ext_type_stb;        // length/TypeID field valid
   input   [15:0] ext_vid;             // stored VLAN ID from the rxed frame
   input          ext_vid_stb;         // VLAN ID field valid strobe
   input  [127:0] ext_ip_sa;           // IP source address
   input          ext_ip_sa_stb;       // IP source address valid strobe
   input  [127:0] ext_ip_da;           // IP destination address
   input          ext_ip_da_stb;       // IP destination address valid strobe
   input   [15:0] ext_source_port;     // source port number
   input          ext_sp_stb;          // validates source port number
   input   [15:0] ext_dest_port;       // destination port number
   input          ext_dp_stb;          // validates destination port number
   input          ext_ipv6;            // high for ipv6

   input          ext_vlan_tag1_stb;   // VLAN tag (full 32 bits) - 1st if using stacked vlan
   input   [31:0] ext_vlan_tag1;       // VLAN tag (full 32 bits) - 1st if using stacked vlan
   input          ext_vlan_tag2_stb;   // VLAN tag (full 32 bits) - 2nd if using stacked vlan
   input   [31:0] ext_vlan_tag2;       // VLAN tag (full 32 bits) - 2nd if using stacked vlan
   input          sync_frame_rx;       // asserted if PTP sync frame is detected
   input          delay_req_rx;        // asserted if PTP delay_req is detected
   input          pdelay_req_rx;       // asserted if PTP pdelay_req is detected
   input          pdelay_resp_rx;      // asserted if PTP pdelay_resp is detected

   output         ext_match1;          // external address match
   output         ext_match2;          // external address match
   output         ext_match3;          // external address match
   output         ext_match4;          // external address match


// -----------------------------------------------------------------------------
// Declare internal signals
// -----------------------------------------------------------------------------

   // filter pin checking array, for holding test file data
   reg    [559:0] filter_check_vector_reg[1:64];
                                       // array for holding checking test data
   integer        filter_check_index;  // index to filter_check_vector_reg
   wire   [559:0] filter_check_vector; // current filter_check_vector_reg word
   wire    [15:0] filter_check_control;// determines checks performed

   // filter pin driving array, for holding test file data
   reg     [10:0] filter_drive_vector_reg[1:64];
                                       // array for holding driving test data
   integer        filter_drive_index;  // index to filter_drive_vector_reg
   integer        j;                   // loop variable for array initialisation
   wire    [10:0] filter_drive_vector; // current filter_drive_vector_reg word
   wire     [2:0] filter_drive_control;// determines trigger for driving cycle

   // detect triggers from testbench for filter driving
   reg            trig_from_apb_latch; // latches trig_from_apb signal
   reg            trig_from_apb_ack;   // clears trig_from_apb_latch
   reg            int_pulse_latch;     // latches int_pulse signal
   reg            int_pulse_ack;       // clears int_pulse_latch
   reg            filterd_trig_latch;  // latches filter_drive_trig signal
   reg            filterd_trig_ack;    // clears filter_drive_trig signal
   reg            drive_filter;        // initiates a filter driving cycle

   // filter driving outputs
   reg            ext_match1;          // external address match1 output
   reg            ext_match2;          // external address match2 output
   reg            ext_match3;          // external address match3 output
   reg            ext_match4;          // external address match4 output

   // seqeunce checking of filter inputs
   wire           check_da;            // initiates a filter checking cycle
   wire           check_sa;            // initiates a filter checking cycle
   wire           check_type;          // initiates a filter checking cycle
   wire           check_vid;           // initiates a filter checking cycle
   wire           check_ipsa;          // initiates a filter checking cycle
   wire           check_ipda;          // initiates a filter checking cycle
   wire           check_ptp_sync_frame;  // initiates a filter checking cycle
   wire           check_ptp_delay_req; // initiates a filter checking cycle
   wire           check_ipv6sa;        // initiates a filter checking cycle
   wire           check_ipv6da;        // initiates a filter checking cycle
   wire           check_vlan1;         // initiates a filter checking cycle
   wire           check_vlan2;         // initiates a filter checking cycle
   wire           check_sp;            // initiates a filter checking cycle
   wire           check_dp;            // initiates a filter checking cycle
   reg            da_checked;          // filter checking cycle complete
   reg            sa_checked;          // filter checking cycle complete
   reg            type_checked;        // filter checking cycle complete
   reg            vid_checked;         // filter checking cycle complete
   reg            ipsa_checked;        // filter checking cycle complete
   reg            ipda_checked;        // filter checking cycle complete
   reg            ptp_sync_frame_checked; // filter checking cycle complete
   reg            ptp_delay_req_checked;  // filter checking cycle complete
   reg            ipv6sa_checked;      // filter checking cycle complete
   reg            ipv6da_checked;      // filter checking cycle complete
   reg            vlan1_checked;       // filter checking cycle complete
   reg            vlan2_checked;       // filter checking cycle complete
   reg            sp_checked;          // filter checking cycle complete
   reg            dp_checked;          // filter checking cycle complete
   reg            rx_dv_del;           // used for detecting rx eof
   reg            rx_eof_tbi_del;      // used for detecting rx eof in tbi mode
   wire           rx_eof_tbi;          // used for detecting rx eof in tbi mode
   wire           rx_eof;              // pulse indicating end of rx frame
   wire           rx_clk;              // rx_clk

   // tb_filter reporting
   wire           filter_done;         // both drive and check complete
   reg            filter_fail;         // tb_filter failed checkin


   // assign rx_clk. Need to use tbi_rx_clk in TBI mode to properly
   // synchronise to rx_group.
   // Need to use mac_rx_clk when not in TBI mode so that timings work
   // properly in filter test scenario
   assign rx_clk = tbi ? tbi_rx_clk : mac_rx_clk;

   // detect rx eof in tbi mode by looking for K29.7 the EPD/T symbol
   assign rx_eof_tbi = (rx_group == 10'h05d) | (rx_group == 10'h3a2);

   // assign rx_eof
   assign rx_eof = (rx_dv_del & ~rx_dv) | (rx_eof_tbi & ~rx_eof_tbi_del);


// -----------------------------------------------------------------------------
// Initialise array with test file data and decode
// -----------------------------------------------------------------------------

  // read filter data
  // filter_check_vector_reg initialised as follows:
  //    47:0   =  Destination Address
  //    95:48  =  Source Address
  //   111:96  =  TypeID field
  //   127:112 =  VID field
  //   159:128 =  IP Source Address field
  //   191:160 =  IP Destination Address field
  //   319:192 =  IPv6 Source Address field
  //   447:320 =  IPv6 Destination Address field
  //   479:448 =  VLAN 1 tag
  //   511:480 =  VLAN 2 tag
  //   527:512 =  source port tag
  //   543:528 =  destination port tag
  //   559:544 =  TB Control field
  // filter_drive_vector_reg initialised as follows:
  //       0   =  Drive ext_match1
  //       1   =  Value for ext_match1
  //       2   =  Drive ext_match2
  //       3   =  Value for ext_match2
  //       4   =  Drive ext_match3
  //       5   =  Value for ext_match3
  //       6   =  Drive ext_match4
  //       7   =  Value for ext_match4
  //    10:8   =  TB Control field
  initial
     begin
        for (j=1; j<=64; j=j+1)
           begin
              filter_check_vector_reg[j] = 560'b0;
              filter_drive_vector_reg[j] = 11'b0;
           end

        $readmemh("./files/tb_check_filter.data",filter_check_vector_reg);
        $readmemb("./files/tb_drive_filter.data",filter_drive_vector_reg);

    /*    if (filter_check_vector_reg[1] === 524'hx)
           begin
              $display("\n No check filter data file read \n");
           end
        if (filter_drive_vector_reg[1] === 11'hx)
           begin
              $display("\n No drive filter data file read \n");
           end */
    end

   assign filter_check_vector = filter_check_vector_reg[filter_check_index];
   assign filter_drive_vector = filter_drive_vector_reg[filter_drive_index];


   // filter drive control triggers
   // 0  end-stop
   // 1  wait for trigger
   // 2  wait for interrupt
   // 3  wait for APB trigger
   // 4  keep going
   assign filter_drive_control = filter_drive_vector[10:8];

   // filter checking control
   assign filter_check_control = filter_check_vector[559:544];
   assign check_da   = (filter_check_control[0] == 1'b1);
   assign check_sa   = (filter_check_control[1] == 1'b1);
   assign check_type = (filter_check_control[2] == 1'b1);
   assign check_vid  = (filter_check_control[3] == 1'b1);
   assign check_ipsa = (filter_check_control[4] == 1'b1);
   assign check_ipda = (filter_check_control[5] == 1'b1);
   assign check_ptp_sync_frame = (filter_check_control[6] == 1'b1);
   assign check_ptp_delay_req = (filter_check_control[7] == 1'b1);
   assign check_ipv6sa = (filter_check_control[8] == 1'b1);
   assign check_ipv6da = (filter_check_control[9] == 1'b1);
   assign check_vlan1 = (filter_check_control[10] == 1'b1);
   assign check_vlan2 = (filter_check_control[11] == 1'b1);
   assign check_sp    = (filter_check_control[12] == 1'b1);
   assign check_dp    = (filter_check_control[13] == 1'b1);


   // inform upper testbench that tb_filter has completed
   assign filter_done = (filter_check_control == 16'h0000) &
                        (filter_drive_control == 3'b000);


// -----------------------------------------------------------------------------
// Detect triggers
// -----------------------------------------------------------------------------

   // synchronise apb trigger signal to rx_clk domain
   always @(posedge trig_from_apb or posedge trig_from_apb_ack or reset_tb)
   if (~reset_tb | trig_from_apb_ack)
      trig_from_apb_latch = 1'b0;
   else if (trig_from_apb)
      trig_from_apb_latch = 1'b1;

   // synchronise int trigger signal to rx_clk domain
   always @(posedge int_pulse or posedge int_pulse_ack or reset_tb)
   if (~reset_tb | int_pulse_ack)
      int_pulse_latch = 1'b0;
   else if (int_pulse)
      int_pulse_latch = 1'b1;

   // synchronise filter_drive_trig signal to rx_clk domain
   always @(posedge filter_drive_trig or posedge filterd_trig_ack or reset_tb)
   if (~reset_tb | filterd_trig_ack)
      filterd_trig_latch = 1'b0;
   else if (filter_drive_trig)
      filterd_trig_latch = 1'b1;



   // filter driving control
   always @( negedge (reset_tb) or posedge (rx_clk) )
   if (~reset_tb)
      begin
         drive_filter      <= 1'b0;
         trig_from_apb_ack <= 1'b0;
         int_pulse_ack     <= 1'b0;
         filterd_trig_ack  <= 1'b0;
      end
  else if (filterd_trig_latch  & (filter_drive_control == 3'b001))
      begin
         drive_filter      <= 1'b1;
         filterd_trig_ack  <= 1'b1;

         $display("Driving filter because time trigger occured at:- %d",count);
      end
   else if (int_pulse_latch & (filter_drive_control == 3'b010))
      begin
         drive_filter      <= 1'b1;
         int_pulse_ack     <= 1'b1;
         $display("Driving filter because interrupt occured at:- %d",count);
      end
   else if (trig_from_apb_latch & (filter_drive_control == 3'b011))
      begin
         drive_filter      <= 1'b1;
         trig_from_apb_ack <= 1'b1;
         $display("Driving filter because of trigger from APB activity at count %d",count);
      end
   else
      begin
         drive_filter      <= 1'b0;
         trig_from_apb_ack <= 1'b0;
         int_pulse_ack     <= 1'b0;
         filterd_trig_ack  <= 1'b0;
      end


// -----------------------------------------------------------------------------
// Drive filter outputs
// -----------------------------------------------------------------------------

   // Drive filter
   reg ext_match1_tmp,ext_match2_tmp,ext_match3_tmp,ext_match4_tmp;
   always @( negedge (reset_tb) or posedge (rx_clk) )
   begin
      if (~reset_tb)
         begin
            filter_drive_index <= 1;
            ext_match1_tmp <= 1'b0;
            ext_match2_tmp <= 1'b0;
            ext_match3_tmp <= 1'b0;
            ext_match4_tmp <= 1'b0;
         end
      else if (drive_filter)
         begin
            if (filter_drive_vector[0])
               begin
                  $display("Driving ext_match1 pin with :- %h",filter_drive_vector[1]);
                  ext_match1_tmp <= filter_drive_vector[1];
               end
            if (filter_drive_vector[2])
               begin
                  $display("Driving ext_match2 pin with :- %h",filter_drive_vector[3]);
                  ext_match2_tmp <= filter_drive_vector[3];
               end
            if (filter_drive_vector[4])
               begin
                  $display("Driving ext_match3 pin with :- %h",filter_drive_vector[5]);
                  ext_match3_tmp <= filter_drive_vector[5];
               end
            if (filter_drive_vector[6])
               begin
                  $display("Driving ext_match4 pin with :- %h",filter_drive_vector[7]);
                  ext_match4_tmp <= filter_drive_vector[7];
               end
            filter_drive_index <= filter_drive_index + 1;
         end
   end

   initial begin
     ext_match1 <= 1'b0;
     ext_match2 <= 1'b0;
     ext_match3 <= 1'b0;
     ext_match4 <= 1'b0;
   end

   always @( negedge rx_clk)
   begin
     ext_match1 <= ext_match1_tmp;
     ext_match2 <= ext_match2_tmp;
     ext_match3 <= ext_match3_tmp;
     ext_match4 <= ext_match4_tmp;
   end

// -----------------------------------------------------------------------------
// Check filter inputs
// -----------------------------------------------------------------------------

   // detect rx eof
   always @( negedge (reset_tb) or posedge (rx_clk) )
   begin
      if (~reset_tb)
         begin
            rx_dv_del <= 1'b0;
            rx_eof_tbi_del <= 1'b0;
        end
      else
         begin
            rx_dv_del <= rx_dv;
            rx_eof_tbi_del <= (rx_group == 10'h05d) | (rx_group == 10'h3a2);
         end
   end

   // Check filter
   always @( negedge (reset_tb) or posedge (rx_clk) )
   begin
      if (~reset_tb)
         begin
            filter_check_index <= 1;
            filter_fail        <= 1'b0;
            da_checked         <= 1'b0;
            sa_checked         <= 1'b0;
            type_checked       <= 1'b0;
            vid_checked        <= 1'b0;
            ipsa_checked       <= 1'b0;
            ipda_checked       <= 1'b0;
            ipv6sa_checked     <= 1'b0;
            ipv6da_checked     <= 1'b0;
            vlan1_checked      <= 1'b0;
            vlan2_checked      <= 1'b0;
            ptp_sync_frame_checked <= 1'b0;
            ptp_delay_req_checked <= 1'b0;
            sp_checked         <= 1'b0;
            dp_checked         <= 1'b0;
         end
      else if (|filter_check_control)
         begin
            if (check_da & ext_da_stb & (ext_da !== filter_check_vector[47:0]))
               begin
                  $display(" **** ERROR read ext_da pin     expected :- %h  got :- %h",filter_check_vector[47:0],ext_da);
                  filter_fail <= 1'b1;
                  da_checked  <= 1'b1;
               end
            else if (check_da & ext_da_stb & ~da_checked)
               begin
                  $display("       good read ext_da pin     expected :- %h  got :- %h",filter_check_vector[47:0],ext_da);
                  da_checked  <= 1'b1;
               end

            if (check_sa & ext_sa_stb & (ext_sa !== filter_check_vector[95:48]))
               begin
                  $display(" **** ERROR read ext_sa pin     expected :- %h  got :- %h",filter_check_vector[95:48],ext_sa);
                  filter_fail <= 1'b1;
                  sa_checked  <= 1'b1;
               end
            else if (check_sa & ext_sa_stb & ~sa_checked)
               begin
                  $display("       good read ext_sa pin     expected :- %h  got :- %h",filter_check_vector[95:48],ext_sa);
                  sa_checked  <= 1'b1;
               end

            if (check_type & ext_type_stb & (ext_type !== filter_check_vector[111:96]))
               begin
                  $display(" **** ERROR read ext_type pin     expected :- %h  got :- %h",filter_check_vector[111:96],ext_type);
                  filter_fail  <= 1'b1;
                  type_checked <= 1'b1;
               end
            else if (check_type & ext_type_stb & ~type_checked)
               begin
                  $display("       good read ext_type pin     expected :- %h  got :- %h",filter_check_vector[111:96],ext_type);
                  type_checked <= 1'b1;
               end

            if (check_vid & ext_vid_stb & (ext_vid !== filter_check_vector[127:112]))
               begin
                  $display(" **** ERROR read ext_vid pin     expected :- %h  got :- %h",filter_check_vector[127:112],ext_vid);
                  filter_fail <= 1'b1;
                  vid_checked <= 1'b1;
               end
            else if (check_vid & ext_vid_stb & ~vid_checked)
               begin
                  $display("       good read ext_vid pin     expected :- %h  got :- %h",filter_check_vector[127:112],ext_vid);
                  vid_checked <= 1'b1;
               end

            if (check_ipsa & ext_ip_sa_stb & (ext_ip_sa[31:0] !== filter_check_vector[159:128]))
               begin
                  $display(" **** ERROR read ext_ip_sa pin     expected :- %h  got :- %h",filter_check_vector[159:128],ext_ip_sa[31:0]);
                  filter_fail <= 1'b1;
                  ipsa_checked <= 1'b1;
               end
            else if (check_ipsa & ext_ip_sa_stb & ~ipsa_checked)
               begin
                  $display("       good read ext_ip_sa pin     expected :- %h  got :- %h",filter_check_vector[159:128],ext_ip_sa[31:0]);
                  ipsa_checked <= 1'b1;
                  if (ext_ipv6)
                     begin
                       $display(" **** ERROR read ext_ipv6 pin high when it should have been low for ipv4");
                       filter_fail <= 1'b1;
                     end
               end

            if (check_ipda & ext_ip_da_stb & (ext_ip_da[31:0] !== filter_check_vector[191:160]))
               begin
                  $display(" **** ERROR read ext_ip_da pin     expected :- %h  got :- %h",filter_check_vector[191:160],ext_ip_da[31:0]);
                  filter_fail <= 1'b1;
                  ipda_checked <= 1'b1;
               end
            else if (check_ipda & ext_ip_da_stb & ~ipda_checked)
               begin
                  $display("       good read ext_ip_da pin     expected :- %h  got :- %h",filter_check_vector[191:160],ext_ip_da[31:0]);
                  ipda_checked <= 1'b1;
               end


            if (check_ptp_sync_frame & sync_frame_rx & ~ptp_sync_frame_checked & rx_dv)
               begin
                  $display(" receive PTP sync frame detected");
                  ptp_sync_frame_checked <= 1'b1;
               end


            if (check_ptp_delay_req & delay_req_rx & ~ptp_delay_req_checked & rx_dv)
               begin
                  $display(" receive PTP delay request frame detected");
                  ptp_delay_req_checked <= 1'b1;
               end

            if (check_ipv6sa & ext_ip_sa_stb & (ext_ip_sa[127:0] !== filter_check_vector[319:192]))
               begin
                  $display(" **** ERROR read ext_ip_sa pin     expected :- %h  got :- %h",filter_check_vector[319:192],ext_ip_sa);
                  filter_fail <= 1'b1;
                  ipv6sa_checked <= 1'b1;
               end
            else if (check_ipv6sa & ext_ip_sa_stb & ~ipv6sa_checked)
               begin
                  $display("       good read ext_ip_sa pin     expected :- %h  got :- %h",filter_check_vector[319:192],ext_ip_sa);
                  ipv6sa_checked <= 1'b1;
                  if (~ext_ipv6)
                     begin
                       $display(" **** ERROR read ext_ipv6 pin low when it should have been high for ipv6");
                       filter_fail <= 1'b1;
                     end
               end

            if (check_ipv6da & ext_ip_da_stb & (ext_ip_da[127:0] !== filter_check_vector[447:320]))
               begin
                  $display(" **** ERROR read ext_ip_da pin     expected :- %h  got :- %h",filter_check_vector[447:320],ext_ip_da);
                  filter_fail <= 1'b1;
                  ipv6da_checked <= 1'b1;
               end
            else if (check_ipv6da & ext_ip_da_stb & ~ipv6da_checked)
               begin
                  $display("       good read ext_ip_da pin     expected :- %h  got :- %h",filter_check_vector[447:320],ext_ip_da);
                  ipv6da_checked <= 1'b1;
               end

            if (check_vlan1 & ext_vlan_tag1_stb & (ext_vlan_tag1 !== filter_check_vector[479:448]))
               begin
                  $display(" **** ERROR read ext_vlan_tag1 pin     expected :- %h  got :- %h",filter_check_vector[479:448],ext_vlan_tag1);
                  filter_fail <= 1'b1;
                  vlan1_checked <= 1'b1;
               end
            else if (check_vlan1 & ext_vlan_tag1_stb & ~vlan1_checked)
               begin
                  $display("       good read ext_vlan_tag1 pin     expected :- %h  got :- %h",filter_check_vector[479:448],ext_vlan_tag1);
                  vlan1_checked <= 1'b1;
               end

            if (check_vlan2 & ext_vlan_tag2_stb & (ext_vlan_tag2 !== filter_check_vector[511:480]))
               begin
                  $display(" **** ERROR read ext_vlan_tag2 pin     expected :- %h  got :- %h",filter_check_vector[511:480],ext_vlan_tag2);
                  filter_fail <= 1'b1;
                  vlan2_checked <= 1'b1;
               end
            else if (check_vlan2 & ext_vlan_tag2_stb & ~vlan2_checked)
               begin
                  $display("       good read ext_vlan_tag2 pin     expected :- %h  got :- %h",filter_check_vector[511:480],ext_vlan_tag2);
                  vlan2_checked <= 1'b1;
               end

            if (check_sp & ext_sp_stb & (ext_source_port !== filter_check_vector[527:512]))
               begin
                  $display(" **** ERROR read ext_source_port pin     expected :- %h  got :- %h",filter_check_vector[527:512],ext_source_port);
                  filter_fail <= 1'b1;
                  sp_checked <= 1'b1;
               end
            else if (check_sp & ext_sp_stb & ~sp_checked)
               begin
                  $display("       good read ext_source_port pin     expected :- %h  got :- %h",filter_check_vector[527:512],ext_source_port);
                  sp_checked <= 1'b1;
               end

            if (check_dp & ext_dp_stb & (ext_dest_port !== filter_check_vector[543:528]))
               begin
                  $display(" **** ERROR read ext_dest_port pin     expected :- %h  got :- %h",filter_check_vector[543:528],ext_dest_port);
                  filter_fail <= 1'b1;
                  dp_checked <= 1'b1;
               end
            else if (check_dp & ext_dp_stb & ~dp_checked)
               begin
                  $display("       good read ext_dest_port pin     expected :- %h  got :- %h",filter_check_vector[543:528],ext_dest_port);
                  dp_checked <= 1'b1;
               end

           // increment to next check at rx_eof
            if (rx_eof)
               begin
                  if (check_da & ~da_checked)
                     begin
                        $display(" ***** ext_da_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_sa & ~sa_checked)
                     begin
                        $display(" ***** ext_sa_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_type & ~type_checked)
                     begin
                        $display(" ***** ext_type_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_vid & ~vid_checked)
                     begin
                        $display(" ***** ext_vid_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_ipsa & ~ipsa_checked)
                     begin
                        $display(" ***** ext_ip_sa_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_ipda & ~ipda_checked)
                     begin
                        $display(" ***** ext_ip_da_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_ptp_sync_frame & ~sync_frame_rx)
                     begin
                        $display(" ***** receive PTP sync frame not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (~check_ptp_sync_frame & sync_frame_rx)
                     begin
                        $display(" ***** unexpected sync_frame_rx assertion (add ptp_sync 1 to filterc) *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_ptp_delay_req & ~delay_req_rx)
                     begin
                        $display(" ***** receive PTP delay request frame not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (~check_ptp_delay_req & delay_req_rx)
                     begin
                        $display(" ***** unexpected  delay_req_rx assertion (add ptp_delay_req 1 to filterc) *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_ipv6sa & ~ipv6sa_checked)
                     begin
                        $display(" ***** ext_ip_sa_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_ipv6da & ~ipv6da_checked)
                     begin
                        $display(" ***** ext_ip_da_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_vlan1 & ~vlan1_checked)
                     begin
                        $display(" ***** ext_vlan1_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_vlan2 & ~vlan2_checked)
                     begin
                        $display(" ***** ext_vlan2_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_sp & ~sp_checked)
                     begin
                        $display(" ***** ext_sp_stb not detected *****");
                        filter_fail <= 1'b1;
                     end
                  if (check_dp & ~dp_checked)
                     begin
                        $display(" ***** ext_dp_stb not detected *****");
                        filter_fail <= 1'b1;
                     end

                   filter_check_index <= filter_check_index + 1;
                   da_checked   <= 1'b0;
                   sa_checked   <= 1'b0;
                   type_checked <= 1'b0;
                   vid_checked  <= 1'b0;
                   ipsa_checked <= 1'b0;
                   ipda_checked <= 1'b0;
                   ipv6sa_checked <= 1'b0;
                   ipv6da_checked <= 1'b0;
                   vlan1_checked <= 1'b0;
                   vlan2_checked <= 1'b0;
                   sp_checked <= 1'b0;
                   dp_checked <= 1'b0;
                   ptp_sync_frame_checked <= 1'b0;
                   ptp_delay_req_checked <= 1'b0;
                end
         end
      else
         begin
            filter_fail  <= 1'b0;
            da_checked   <= 1'b0;
            sa_checked   <= 1'b0;
            type_checked <= 1'b0;
            vid_checked  <= 1'b0;
            ipsa_checked <= 1'b0;
            ipda_checked <= 1'b0;
            ptp_sync_frame_checked <= 1'b0;
            ptp_delay_req_checked <= 1'b0;
            ipv6sa_checked <= 1'b0;
            ipv6da_checked <= 1'b0;
            vlan1_checked <= 1'b0;
            vlan2_checked <= 1'b0;
            dp_checked   <= 1'b0;
            sp_checked   <= 1'b0;
         end
   end
assign all_checked =  ~(da_checked ^ check_da) &
                      ~(sa_checked    ^ check_sa) &
                      ~(type_checked  ^ check_type) &
                      ~(vid_checked   ^ check_vid) &
                      ~(ipsa_checked  ^ check_ipsa) &
                      ~(ipda_checked  ^ check_ipda) &
                      ~(ptp_sync_frame_checked ^ check_ptp_sync_frame) &
                      ~(ptp_delay_req_checked ^ check_ptp_delay_req) &
                      ~(ipv6sa_checked ^ check_ipv6sa) &
                      ~(ipv6da_checked ^ check_ipv6da) &
                      ~(vlan1_checked ^ check_vlan1) &
                      ~(vlan2_checked ^ check_vlan2) &
                      ~(sp_checked ^ check_sp) &
                      ~(dp_checked ^ check_dp);

endmodule
