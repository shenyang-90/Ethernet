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
//   Filename:           tb_mdio.v
//   Module Name:        tb_mdio
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
//   Description    : This module exercises the MDIO interface
//
//------------------------------------------------------------------------------


module tb_mdio (
   reset_tb,

   mdc,
   mdio_in,
   mdio_out,
   mdio_en,

   mdio_done,
   mdio_fail
);

   parameter p_idle_wait = 1;

// -----------------------------------------------------------------------------
// Declare inputs and outputs
// -----------------------------------------------------------------------------
   input          reset_tb;            // testbench reset
   input          mdc;                 // management data clock
   output         mdio_in;             // management data input
   input          mdio_out;            // management data output
   input          mdio_en;             // management data output enable
   output         mdio_done;           // tb_mdio has finished
   output         mdio_fail;           // tb_mdio has failed


// -----------------------------------------------------------------------------
// Declare internal signals
// -----------------------------------------------------------------------------

   // array for storing test file data
   reg      [4:0] mdio_vector_reg[1:1024];
                                       // array for storing test file data
   integer        mdio_index;          // index to current mdio_vector_reg
   reg            inc_mdio_index;      // increment mdio_index
   integer        j;                   // loop variable for mdio_vector_reg
   wire     [4:0] mdio_vector;         // current mdio_vector_reg word

   // mdio data checks and driving of read data
   wire           mdio_data;           // expected write data or read data
   reg            mdio_in;             // management data input
   reg     [63:0] store_mdio_actual;   // a store of the data driven on MDIO
   reg     [63:0] store_mdio_expected; // a store of the data expected on MDIO
   integer        count_mdio;          // a count of the data driven on MDIO
   wire           mdio_read_detected;  // read detected
   wire           mdio_write_detected; // write detected
   integer        wait_idle;           // wait for idle bit before beginning count

   // testbench reporting
   reg            mdio_out_fail;       // tb_mdio has failed data write checking
   reg            mdio_en_fail;        // tb_mdio has failed enable checking


// -----------------------------------------------------------------------------
// Initialise array from test file data
// -----------------------------------------------------------------------------

   // read mdio data from file
   initial
      begin
         for (j=1; j<=1024; j=j+1)
            mdio_vector_reg[j] = 5'b0;

         $readmemh("./files/tb_mdio.data",mdio_vector_reg);
         if (mdio_vector_reg[1] === 5'bx)
            $display("\n No mdio data file read \n");
      end


   // decode current vector
   assign mdio_vector = mdio_vector_reg[mdio_index];
   assign mdio_done   = mdio_vector[4];
   assign mdio_data   = mdio_vector[(count_mdio % 4)];



// -----------------------------------------------------------------------------
// index to array
// -----------------------------------------------------------------------------
   // update index to array
   always @( negedge (reset_tb) or posedge (mdc) )
   begin
      if (~reset_tb)
         inc_mdio_index <= 1'b0;
      else if ((count_mdio % 4) == 0)
         inc_mdio_index <= 1'b1;
      else
         inc_mdio_index <= 1'b0;
   end

   // increment mdio_index on negedge of mdc to make sure mdio_in
   // is driven correctly
   always @( negedge (reset_tb) or negedge (mdc) )
   begin
      if (~reset_tb)
         mdio_index <= 1;
      else if (inc_mdio_index)
         mdio_index <= mdio_index + 1;
   end


// -----------------------------------------------------------------------------
// Deserialise mdio_out input
// -----------------------------------------------------------------------------

   // Count 64 bit times
   always @( negedge (reset_tb) or negedge (mdc) )
   begin
      if (~reset_tb)
      begin
         count_mdio <= 63;
         wait_idle  <= p_idle_wait;
      end
      else
      begin
         // decrement count whilst count is not zero
         if ((count_mdio > 0) & (count_mdio < 64))
            count_mdio <= count_mdio - 1;

         else if (wait_idle > 0)
         begin
            count_mdio <= 65;
            wait_idle <= wait_idle - 1;
         end

         // otherwise reset counter and start over
         else
            begin
               count_mdio <= 63;
               wait_idle <= p_idle_wait;
               $display("\n  Detected PHY management frame of:-  %h",store_mdio_actual);
               $display("  Expected PHY management frame of:-  %h\n",store_mdio_expected);
            end
      end
   end

   // Deserialise mdio_out input
   always @( negedge (reset_tb) or posedge (mdc) )
   begin
      if (~reset_tb)
         store_mdio_actual <= 64'b0;
      else
         store_mdio_actual[count_mdio] <= mdio_out;
   end


   // detect if read or write
   assign mdio_read_detected  =
                  // clause 22 PHY read....
                  (store_mdio_actual[29] & ~store_mdio_actual[28]) |
                  // or clause 45 PHY read
                  (~store_mdio_actual[31] & ~store_mdio_actual[30] &
                    store_mdio_actual[29] & store_mdio_actual[28]);

   assign mdio_write_detected = ~store_mdio_actual[29] &  store_mdio_actual[28];

   // Detect read or write and ouput messgae to screen / log file
   always @(negedge (mdc) )
   begin
      // detect a read operation
      if (mdio_read_detected & (count_mdio == 16))
         $display("\n PHY Management read operation\n");

      // detect a write operation
      if (mdio_write_detected & (count_mdio == 16))
         $display("\n PHY Management write operation\n");
   end


// -----------------------------------------------------------------------------
// Sample and store data and compare against expected
// -----------------------------------------------------------------------------

   // Store any data driven onto MDIO in store_mdio_actual shift register.
   always @( negedge (reset_tb) or posedge (mdc) )
   begin
      if (~reset_tb)
         store_mdio_expected <= 64'b0;

      // read operation so no expect write data
      else if (mdio_read_detected & (count_mdio < 16))
         store_mdio_expected[count_mdio] <= 1'bx;

      // write operation, so store data for comparing
      else
         store_mdio_expected[count_mdio] <= mdio_data;
   end

   // check stored data
   always @( negedge (reset_tb) or posedge (mdc) )
   begin
      if (~reset_tb)
         begin
            mdio_out_fail <= 1'b0;
         end
      else
         begin
            if ((mdio_out === mdio_data) & mdio_en)
               begin
                  // $display("      good mdio_out ---- expected:-  %h  got:-  %h",mdio_data,mdio_out);
                  mdio_out_fail <= 1'b0;
               end
            else if (mdio_en)
               begin
                  $display(" **** bad mdio_out ----- expected:-  %h  got:-  %h ",mdio_data,mdio_out);
                  mdio_out_fail <= 1'b1;
               end
         end
   end


// -----------------------------------------------------------------------------
// Drive read data back onto mdio_in
// -----------------------------------------------------------------------------

   // drive mdio_in. If data portion of a PHY management read drive from
   // mdio_data
   always @(store_mdio_actual or count_mdio or mdio_data or mdio_en or mdio_out)
      if (~store_mdio_actual[29] | (count_mdio > 18))
         begin
            if (count_mdio < 63)
               begin
                  mdio_in = mdio_out;
                  if (mdio_en != 1'b1)
                     begin
                        $display(" ***** bad mdio_en - expected it to be high");
                        mdio_en_fail = 1'b1;
                     end
                  else
                     mdio_en_fail = 1'b0;
               end
            else
               begin
                  mdio_in      = 1'b1; // PHY's pull up register drives 1
                  mdio_en_fail = 1'b0;
               end
         end
      else
         begin
            if ((mdio_en != 1'b0) & (count_mdio < 17))
               // don't do 17 even though mdio_en is low here
               begin
                  $display(" ***** bad mdio_en - expected it to be low during read data");
                  mdio_en_fail = 1'b1;
               end
            else
               mdio_en_fail = 1'b0;

            if (count_mdio == 16)
               // PHY must drive zero during second bit time of turnaround
               mdio_in = 1'b0;
            else
               mdio_in = mdio_data;
         end


// -----------------------------------------------------------------------------
// Drive faiure back to top level testbench
// -----------------------------------------------------------------------------
   assign mdio_fail = mdio_out_fail | mdio_en_fail;



endmodule

