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
//   Filename:           tb_rx.v
//   Module Name:        tb_rx
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
// Description : System on Chip Kernel testbench ethernet module
//              This modules transmits a frame which is received
//              by the chip.
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_rx (
   reset_tb,
   rx_clk,
   rxd,
   rx_dv,
   rx_er,
   gigabit,
   tbi,
   rx_trig,
   int_pulse,
   trig_from_apb,
   rx_done
   );


// -----------------------------------------------------------------------------
// Declare inputs and outputs
// -----------------------------------------------------------------------------
   input          reset_tb;            // testbench reset (active low)
   input          rx_clk;              // receive clock from the PHY
   output   [7:0] rxd;                 // receive data from the PHY
   output         rx_dv;               // receive data valid signal from the PHY
   output         rx_er;               // receive error signal from the PHY
   input          gigabit;             // high for gigabit operation
   input          tbi;                 // high for ten bit operation
   input          rx_trig;             // event trigger for tb_rx
   input          int_pulse;           // interrupt trigger
   input          trig_from_apb;       // APB transactor trigger
   output         rx_done;             // All tb_rx activity complete


// -----------------------------------------------------------------------------
// Declare internal signals
// -----------------------------------------------------------------------------

   // RXD array for holding test file data
   reg     [41:0] rxd_vector_reg[1:(80*16383)]; // fix to 80 max frames.
                                       // Receive data array
   integer        rxd_index;           // index to current rxd_vector_reg
   integer        k;                   // loop variable for initialising array
   wire    [41:0] rxd_vector;          // current rxd_vector_reg
   wire     [7:0] rx_send;             // next byte of data for rxd output
   wire     [3:0] rx_control;          // current testbench 10/100 control field
   wire     [7:0] giga_control;        // current testbench gigabit control

   // Trigger generation of new RX frame and code error
   reg            rx_trig_ack;         // clears rx_enable
   reg            rx_enable;           // triggers frame transmission
   reg            do_code_error;       // Perform a code error (assert rx_er).

   // carrier extension counter signals
   wire     [9:0] giga_extend_amount;  // amount to extend frame to (bytes)
   reg            start_ext_time_512;  // start extend to 512 bytes (gigabit)
   reg            start_ext_time_x;    // start extend to x bytes (gigabit)
   wire           do_carr_ext;         // do a carrier extended frame
   integer        ext_time;            // carrier extension counter
   reg            ext_time_trig;       // carrier extension complete
   reg            do_ext_err;          // do a carrier extension error
   wire     [9:0] giga_ext_err_byte;   // byte on which to produce ext error
   reg      [9:0] giga_ext_err_saved;  // saved giga_ext_err_byte

   // burst mode counter signals
   reg            start_burst_mode_x;  // start burst with extension to x byte
   reg            start_burst_mode;    // start burst with extension to 512 byte
   reg            do_burst;            // do a burst frame

   // Inter frame gap counter signals
   reg            start_gap_timer;     // start IFG timer
   integer        gap_time;            // Interframe gap counter
   wire           gap_time_trig;       // IFG count complete

   // RX MII/GMII interface outputs
   reg            rx_dv;               // receive data valid signal from the PHY
   reg            rx_dv_delay;         // delayed rx_dv
   reg      [7:0] rxd;                 // receive data from PHY to DUT

   // Bit control signals
   integer        crc_index;           // determines bit position in byte for
                                       // controlling nibbles in 10/100 mode
                                       // and for generating CRC
   integer        bit_count;           // Used to ensure 32bits of CRC appended
   reg            preamble_over;       // indicates when preamble has been txed

   // CRC generation signals
   reg     [31:0] crc_rxtb;            // current CRC value
   wire    [31:0] rxtb_str_out0;       // output of stripe 0
   wire    [31:0] rxtb_str_out1;       // output of stripe 1
   wire    [31:0] rxtb_str_out2;       // output of stripe 2
   wire    [31:0] rxtb_str_out3;       // output of stripe 3
   wire    [31:0] rxtb_str_out4;       // output of stripe 4
   wire    [31:0] rxtb_str_out5;       // output of stripe 5
   wire    [31:0] rxtb_str_out6;       // output of stripe 6
   wire    [31:0] rxtb_str_out7;       // output of stripe 7



// -----------------------------------------------------------------------------
// initialise array from test file
// -----------------------------------------------------------------------------

   // read rx data from file
   initial
      begin
         for (k=1; k<=8192; k=k+1)
            rxd_vector_reg[k] = 42'b0;

         $readmemh("./files/tb_rxd.data",rxd_vector_reg);
         if (rxd_vector_reg[1] === 42'hx)
            $display("\n No rxd data file read \n");
      end


// -----------------------------------------------------------------------------
// Decode current vector
// -----------------------------------------------------------------------------

   // Decode current vector
   assign rxd_vector = rxd_vector_reg[rxd_index];

   // Get next byte to be output on RXD
   assign rx_send = rxd_vector[7:0];

   // Get current control trigger
   // 0  end-stop
   // 1  wait for trigger
   // 2  wait for interrupt
   // 3  wait for APB trigger
   // 4  keep going
   // 5  use testbench to generate CRC
   // 6  wait a gap after last transmission and then send another
   // 7  force rx_er
   // 8  nibble dribble
   assign rx_control = rxd_vector[11:8];

   // Get gigabit control. If no bits set then no additional change.
   // The following bits set have the described changes to the frame.
   // bit
   // [0]  carrier extend
   // [1]  burst data
   // [2]  user defined slot time by extending (65 to 511 bytes)
   // [3]  user defined slot time in burst mode by extending (65 to 511 bytes)
   // [4]  carrier extend error at user defined byte position (64 to 511 bytes)
   assign giga_control = rxd_vector[19:12];

   // Get amount of carrier extension on variable carrier extend
   assign giga_extend_amount = rxd_vector[29:20];

   // get byte for carrier extend error
   assign giga_ext_err_byte = rxd_vector[41:32];

   // testbench all done. Signal to top level testbench
   assign rx_done = (rx_control == 4'b0000) & ~rx_dv_delay & ~rx_dv;



// -----------------------------------------------------------------------------
// Detect triggers for start of frame, carrier extension and bursting.
// -----------------------------------------------------------------------------

   // synchronise rx_trig signal pulse
   always @(reset_tb or rx_trig_ack or rx_trig or rx_control or int_pulse or
            trig_from_apb or gap_time_trig or giga_control or
            giga_extend_amount)

   // reset when testbench reset or when awaiting new trigger
   if(~reset_tb | rx_trig_ack)
      begin
         rx_enable          = 1'b0;
         start_ext_time_512 = 1'b0;
         start_ext_time_x   = 1'b0;
         start_burst_mode   = 1'b0;
         start_burst_mode_x = 1'b0;
      end

   // If valid trigger detected then start generation of new frame
   else if ((     rx_trig  & (rx_control == 4'b0001)) |
            (    int_pulse & (rx_control == 4'b0010)) |
            (trig_from_apb & (rx_control == 4'b0011)) |
            (gap_time_trig & (rx_control == 4'b0110)))
      begin

         // trigger generation of frame
         rx_enable = 1'b1;
         `ifdef debugmsglvl0
         `else
         $display("\n Testbench starting driving RXD frame data.\n");
         `endif

         // start correct timers for type of frame
         // --------------------------------------

         // single gigabit frame extended to 512 bytes to satisfy slotTime
         if (giga_control[0])
            begin
               start_ext_time_512 = 1'b1;
               $display("\n Testbench will extend frame to 512 bytes.\n");
            end

         // Burst gigabit frame with first in burst extended to 512 bytes
         // to satisfy slotTime
         else if (giga_control[1])
            begin
               start_burst_mode = 1'b1;
               $display("\n Testbench will burst this frame with next frame.\n");
            end

         // single gigabit frame extended to user defined X bytes
         else if (giga_control[2] & (giga_extend_amount > 10'h040) &
                  (giga_extend_amount < 10'h200))
            begin
               start_ext_time_x = 1'b1;
               $display("\n Testbench will extend frame to %d bytes.\n", giga_extend_amount);
            end

         // Burst gigabit frame with first in burst extended to user defined
         // X bytes
         else if (giga_control[3] & (giga_extend_amount > 10'h040) &
                  (giga_extend_amount < 10'h200))
            begin
               start_burst_mode_x = 1'b1;
               $display("\n Testbench will burst this frame with next frame");
               $display(" This frame will be extended to %d bytes.\n", giga_extend_amount);
            end

         // otherwise must be a 10/100 frame with no extension or bursting
         else
            begin
               start_ext_time_512 = 1'b0;
               start_ext_time_x   = 1'b0;
               start_burst_mode   = 1'b0;
               start_burst_mode_x = 1'b0;
            end
      end



// -----------------------------------------------------------------------------
// Carrier extension timer (gigabit mode only)
// Used for single gigabit frames or the first frame in a gigabit burst.
// -----------------------------------------------------------------------------

   // extend time for gigabit mode
   // down counter preloaded with byte amount to be extended to, plus one.
   always @(negedge rx_clk or reset_tb)
   begin
      if (~reset_tb)
         begin
            ext_time      <= 0;
            ext_time_trig <= 1'b0;
         end
      else if (start_ext_time_512 | (start_burst_mode & ~do_burst))
         ext_time <= 513;
      else if (start_ext_time_x | (start_burst_mode & ~do_burst))
         ext_time <= giga_extend_amount + 10'h001;
      else if (start_ext_time_x | (start_burst_mode_x & ~do_burst))
         ext_time <= giga_extend_amount + 10'h001;
      else if (ext_time > 0)
         begin

            // start counting once preamble has finished
            if (preamble_over)
               ext_time <= ext_time - 1;

            // generate trigger when count value go through one
            if (ext_time == 1)
               ext_time_trig <= 1'b1;
            else
               ext_time_trig <= 1'b0;
         end
      else
         begin
            ext_time      <= 0;
            ext_time_trig <= 1'b0;
         end
   end


   // Do carrier extend whilst ext_time has not yet decremented to 0.
   assign do_carr_ext = (ext_time > 0);


// -----------------------------------------------------------------------------
// Bursting control
// -----------------------------------------------------------------------------

   // Hold burst triggers until a non burst trigger event occurs
   always @(negedge rx_clk or reset_tb)
      if (~reset_tb)
         do_burst <= 1'b0;
      else
         begin
            // set do_burst when a burst trigger is active
            if (start_burst_mode | start_burst_mode_x)
               do_burst <= 1'b1;

            // end of burst on next trigger that is not a burst
            else if (rx_enable)
               do_burst <= 1'b0;
         end


// -----------------------------------------------------------------------------
// Carrier extension error generation
// -----------------------------------------------------------------------------
   // latch whether to do carrier extension error and value at trigger
   // for new frame
   always @(negedge rx_clk or reset_tb)
      if (~reset_tb)
         begin
            do_ext_err         <= 1'b0;
            giga_ext_err_saved <= 10'b0;
         end
      else if (rx_enable)
         begin
            do_ext_err         <= giga_control[4];
            giga_ext_err_saved <= giga_ext_err_byte;
         end


// -----------------------------------------------------------------------------
// Generate MII/GMII outputs
// -----------------------------------------------------------------------------

   always @(negedge rx_clk or reset_tb)
   begin
      if (~reset_tb)
         begin
            crc_rxtb      <= 32'hffffffff;
            rxd           <= 8'b0;
            rx_trig_ack   <= 1'b0;
            rxd_index     <= 1;
            rx_dv         <= 1'b0;
            bit_count     <= 0;
            preamble_over <= 1'b0;
            crc_index     <= 0;
            do_code_error <= 1'b0;
         end

      // Once triggered continue to drive data on rxd and rx_dv and
      // calculate FCS until we need to wait for a new trigger or need
      // to append CRC or carrier extension
      else if (rx_enable | (rx_control == 4'b0100) |
                           (rx_control == 4'b0111) |
                           (rx_control == 4'b1000) |
                           (rx_control == 4'b1001) |
                           (rx_control == 4'b1010))
         begin
            // bit_count only used in CRC appendin
            bit_count <= 0;

            // Gigabit byte control
            if (gigabit)
               begin
                  // wait until preamble is finished before taking data to
                  // generate CRC
                  if (preamble_over)
                     crc_rxtb <= rxtb_str_out7;
                  else
                     crc_rxtb <= 32'hffffffff;

                  // working in bytes so RX_DV is always high, data is read
                  // in bytes and bit indexes are not required. Also
                  // acknowledge can be returned immediately and array index
                  // incremented to pick up next byte.
                  rx_dv       <= 1'b1;
                  rxd         <= rx_send;
                  bit_count   <= 0;
                  crc_index   <= 0;
                  rx_trig_ack <= 1'b1;
                  rxd_index   <= rxd_index + 1;

                  // detect SFD to deduce when preamble has finished
                  if (rx_send == 8'hd5)
                     preamble_over <= 1'b1;

                  // drive rx_er for code error
                  do_code_error <= (rx_control == 4'b0111) |
                                   (rx_control == 4'b1000) |
                                   (rx_control == 4'b1010);
               end

            // 10/100 nibble control
            else // nibble mode
               begin
                  // wait until preamble is finished before taking data to
                  // generate CRC
                  if (preamble_over)
                     crc_rxtb <= rxtb_str_out3;
                  else
                     crc_rxtb <= 32'hffffffff;

                  // detect if doing an odd number of preamble nibbles,
                  // signified by a 0 in the data in the least significant
                  // nibble of preamble. Keep rx_dv low for this nibble.
                  if (~preamble_over & (rx_send[3:0] == 4'h0) &
                      (crc_index == 0))
                     rx_dv <= 1'b0;
                  else
                     rx_dv <= 1'b1;

                  // nibble of rxd data taken from upper or lower nibble of
                  // rx_send depending whether crc_index is 0 or 4.
                  rxd[3:0] <= {rx_send[crc_index+3],
                               rx_send[crc_index+2],
                               rx_send[crc_index+1],
                               rx_send[crc_index+0]};

                  // If end of current byte (crc_index is already 4 or odd
                  // dribble nibble required) then reset counts and go onto
                  // next byte.
                  if ((crc_index == 4) | (rx_control == 4'b1001) |
                                         (rx_control == 4'b1010))
                     begin
                        crc_index   <= 0;
                        rx_trig_ack <= 1'b1;
                        rxd_index   <= rxd_index + 1;

                        // detect end of preamble
                        if (rx_send == 8'hd5 || rx_send == 8'h19 || rx_send == 8'h07 ||
                            rx_send == 8'he6 || rx_send == 8'h4c || rx_send == 8'h7f ||
                            rx_send == 8'hb3)
                           preamble_over <= 1'b1;
                     end
                  else
                     begin
                        crc_index <= 4;
                     end

                  // drive rx_er for code error
                  do_code_error<= ((rx_control == 4'b0111) & (crc_index == 0)) |
                                  ((rx_control == 4'b1000) & (crc_index == 4)) |
                                  (rx_control == 4'b1010);


               end
         end

      // FCS/CRC requires appending
      else if ((rx_control == 4'b0101) & (bit_count < 32))
         begin
            do_code_error <= 1'b0; // to do code errors in CRC don't use g's

            if (bit_count == 0)
               $display("TestBench automatically generating and appending CRC");

            // If gigabit mode output a byte at a time (4 bytes total)
            if (gigabit)
               begin
                  bit_count <= bit_count + 8;
                  rxd_index <= rxd_index +1;
                  // invert to get the CRC
                  rxd    <= {~crc_rxtb[24-bit_count],
                             ~crc_rxtb[25-bit_count],
                             ~crc_rxtb[26-bit_count],
                             ~crc_rxtb[27-bit_count],
                             ~crc_rxtb[28-bit_count],
                             ~crc_rxtb[29-bit_count],
                             ~crc_rxtb[30-bit_count],
                             ~crc_rxtb[31-bit_count]};
               end // if (gigabit)

            // Else must be 10/100 so do a nibble at a time
            else
               begin
                  bit_count <= bit_count + 4;
                  if ((bit_count+4) % 8 == 0)
                     rxd_index <= rxd_index +1;
                  // invert to get the CRC
                  rxd[3:0] <= {~crc_rxtb[28-bit_count],
                             ~crc_rxtb[29-bit_count],
                             ~crc_rxtb[30-bit_count],
                             ~crc_rxtb[31-bit_count]};
               end
         end

      // Carrier extension required
      else if (do_carr_ext & ~ext_time_trig)
         // carrier extension
         begin
            rx_trig_ack   <= 1'b0;   // clear rx_trig_ack.
            rx_dv         <= 1'b0;
            // check to see if inserting carrier extend error
            if (do_ext_err & (ext_time == (10'd512 - giga_ext_err_saved)))
               rxd        <= 8'h1f;
            else
               rxd        <= 8'h0f;
            bit_count     <= 0;
            crc_rxtb      <= 32'hffffffff;
            preamble_over <= 1'b1;
            crc_index     <= 0;
            do_code_error <= 1'b0;
         end

      // idle or interframe gap
      else
         begin
            rx_trig_ack   <= 1'b0;   // clear rx_trig_ack.
            rx_dv         <= 1'b0;
            rxd           <= (do_burst)? 8'h0f : 8'h00;
            bit_count     <= 0;
            crc_rxtb      <= 32'hffffffff;
            preamble_over <= 1'b0;
            crc_index     <= 0;
            do_code_error <= 1'b0;
         end
   end


   // Signal rx_er output if doing carrier extension, IFG of a burst
   // or a symbol error
   assign rx_er      = do_code_error |
                       (do_carr_ext & ~rx_dv)  |
                       (do_burst & ~rx_dv);



// -----------------------------------------------------------------------------
// Interframe gap timer
// -----------------------------------------------------------------------------

   // delay rx_dv to detect falling edge signifying end of data portion of frame
   always @(negedge rx_clk or reset_tb)
      if (~reset_tb)
         rx_dv_delay <= 1'b0;
      else
         rx_dv_delay <= rx_dv;

   // start interframe gap counter at the end of frame (end of data and
   // carrier extension)
   always @(posedge rx_clk or reset_tb)
      if (~reset_tb)
         start_gap_timer <= 1'b0;
      else if ((rx_dv_delay & ~rx_dv & ~do_carr_ext) | ext_time_trig)
         begin
            start_gap_timer <= 1'b1;
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench finished driving RXD frame data\n");
          `endif
         end
      else if (rx_dv_delay & ~rx_dv & do_carr_ext)
         begin
          `ifdef debugmsglvl0
          `else
            $display("\n Testbench driving carrier extension\n");
          `endif
         end
      else
         begin
            start_gap_timer <= 1'b0;
         end


   // count gap time
   // down counter preloaded with number of nibbles required, minus one.
   always @(negedge rx_clk or reset_tb)
   begin
      if (~reset_tb)
         gap_time      <= 0;
      `ifdef XG
      else if (start_gap_timer)
         gap_time <= 7;
      `endif
      else if (start_gap_timer & gigabit)
         gap_time <= 11;
      else if (start_gap_timer & ~gigabit)
         gap_time <= 23;
      else if (gap_time > 0)
         gap_time <= gap_time - 1;
      else
         gap_time <= 0;
   end

   // trigger as gap_time decrements passes 1
   assign gap_time_trig = (gap_time == 1);

// -----------------------------------------------------------------------------
// CRC stripes for generating CRC to be appended
// -----------------------------------------------------------------------------
   tb_crcgen i_tb_crcgen_rx0(.din(rx_send[crc_index+0]),.stripe_in(crc_rxtb     ),.stripe_out(rxtb_str_out0));
   tb_crcgen i_tb_crcgen_rx1(.din(rx_send[crc_index+1]),.stripe_in(rxtb_str_out0),.stripe_out(rxtb_str_out1));
   tb_crcgen i_tb_crcgen_rx2(.din(rx_send[crc_index+2]),.stripe_in(rxtb_str_out1),.stripe_out(rxtb_str_out2));
   tb_crcgen i_tb_crcgen_rx3(.din(rx_send[crc_index+3]),.stripe_in(rxtb_str_out2),.stripe_out(rxtb_str_out3));
   tb_crcgen i_tb_crcgen_rx4(.din(rx_send[crc_index+4]),.stripe_in(rxtb_str_out3),.stripe_out(rxtb_str_out4));
   tb_crcgen i_tb_crcgen_rx5(.din(rx_send[crc_index+5]),.stripe_in(rxtb_str_out4),.stripe_out(rxtb_str_out5));
   tb_crcgen i_tb_crcgen_rx6(.din(rx_send[crc_index+6]),.stripe_in(rxtb_str_out5),.stripe_out(rxtb_str_out6));
   tb_crcgen i_tb_crcgen_rx7(.din(rx_send[crc_index+7]),.stripe_in(rxtb_str_out6),.stripe_out(rxtb_str_out7));




endmodule

