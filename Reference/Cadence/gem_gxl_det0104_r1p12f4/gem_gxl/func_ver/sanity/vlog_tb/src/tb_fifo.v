//------------------------------------------------------------------------------
// Copyright (c) 2002-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_fifo.v
//   Module Name:        tb_fifo
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
// Description : This testbench block provides stimulus and checking for
//              the FIFO interfaces. Read and write operations are tested
//              separately. The stimulus and check data is loaded from
//              files that have been created with the Perl program
//              trans_eth.pl
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_fifo
  (
   reset_tb,
   dma_bus_width,
   fifo_latency,
   fifo_under_delay,
   fifo_status_delay,
   fifo_over_delay,

   // Read i/f
   tx_clk,
   tx_r_rd,
   tx_r_data,
   tx_r_mod,
   tx_r_eop,
   tx_r_sop,
   tx_r_err,
   tx_r_valid,
   tx_r_data_rdy,
   tx_r_control,
   tx_r_underflow,
   tx_r_flushed,
   tx_r_status,
   dma_tx_status_tog,
   dma_tx_end_tog,

   // Write i/f
   rx_clk,
   rx_w_data,
   rx_w_mod,
   rx_w_eop,
   rx_w_sop,
   rx_w_err,
   rx_w_flush,
   rx_w_wr,
   rx_w_queue,
   rx_status,
   rx_w_overflow,

   trig_from_apb,
   int_pulse,

   fifo_done,
   fifo_fail

   );

// -----------------------------------------------------------------------------
// Declare inputs and outputs
// -----------------------------------------------------------------------------
   input          reset_tb;
   input    [1:0] dma_bus_width;       // encoding for DMA bus width
   input    [3:0] fifo_latency;        // FIFO latency on a read
   input    [3:0] fifo_under_delay;    // FIFO underflow latency on a read
   input    [3:0] fifo_status_delay;   // FIFO delay for status handshaking
   input    [3:0] fifo_over_delay;     // FIFO overflow latency on a write

   // Read Interface
   input          tx_clk;              // Read clock
   input    [`edma_queues-1:0]  tx_r_rd;        // Read Strobe
   output [127:0] tx_r_data;           // Read Data (128 bit)
   output   [3:0] tx_r_mod;            // Modulo
   output         tx_r_eop;            // End of packet indicator
   output         tx_r_sop;            // Start of packet indicator
   output         tx_r_err;            // Error indicator
   output         tx_r_valid;          // Valid Data flag
   output   [`edma_queues-1:0]  tx_r_data_rdy;  // 1 or more packets are in FIFO
   output         tx_r_control;        // tx read in-line control
   output         tx_r_underflow;      // signals tx fifo underrun condition.
   output         tx_r_flushed;        // tx fifo has been flushed.
   input    [3:0] tx_r_status;         // tx status written to in-line word
   output         dma_tx_status_tog;   // toggle acknowledge for tx_r_status
   input          dma_tx_end_tog;      // Toggled when tx_r_status is valid

   // Write Interface
   input          rx_clk;              // Write clock
   input  [127:0] rx_w_data;           // Write Data (128 bit)
   input    [3:0] rx_w_mod;            // Modulo
   input          rx_w_eop;            // End of packet indicator
   input          rx_w_sop;            // Start of packet indicator
   input          rx_w_err;            // Error indicator
   input          rx_w_flush;          // fifo flush from the mac (not used)
   input          rx_w_wr;             // Write Strobe
   input   [44:0] rx_status;           // Status valid at EOP
   input   [3:0]  rx_w_queue;          // Queue valid at EOP
   output         rx_w_overflow;       // RX FIFO overflow

   input          trig_from_apb;       // Trigger to start test
   input          int_pulse;           // Interrupt pulse

   // test bench reporting stuff
   output         fifo_done;           // Test Complete
   output         fifo_fail;           // Test Failure Flag


// -----------------------------------------------------------------------------
// Declare parameters
// -----------------------------------------------------------------------------

   // parameters for state machine states
   parameter      wait_for_apb_trg   = 2'b00; // waiting for a trigger
   parameter      wait_for_valid     = 2'b01; // waiting for first valid
   parameter      output_data        = 2'b10; // data state


// -----------------------------------------------------------------------------
// Declare internal signals
// -----------------------------------------------------------------------------

   // detect triggers
   reg            trig_from_apb_lat;   // latch apb trigger for clock domain
   reg            int_pulse_lat;       // latch interrupt pulse for clock domain
   reg            trig;                // an expected trigger has been seen
   reg            trig_from_apb_wr_lat;// latch apb trigger for clock domain
   reg            int_pulse_wr_lat;    // latch interrupt pulse for clock domain
   reg            trig_wr;             // an expected trigger has been seen (wr)
   reg            rx_w_overflow;       // RX FIFO overflow
   wire           rx_w_overflow_prdelay;       // RX FIFO overflow

   // array for test file data
   reg     [59:0] fifo_rd_vector_reg [0:100000];
                                       // array for read data
   integer        fifo_rd_index;       // index for current fifo_rd_vector_reg
  `ifdef gem_fifo_8b_if
   reg [1:0]      fifo_rd_sub_index;
  `endif
   integer        j;                   // loop variable for read array
   wire    [59:0] fifo_rd_vector;      // bit-select reg for read data[31:0]
   wire    [59:0] fifo_rd_vector2;     // bit-select reg for read data[63:32]
   wire    [59:0] fifo_rd_vector3;     // bit-select reg for read data[95:64]
   wire    [59:0] fifo_rd_vector4;     // bit-select reg for read data[127:96]
   reg     [59:0] fifo_rd_vector_st;   // read data for checking fifo status
   wire     [7:0] fifo_rd_ctrl;        // FIFO interface signal control
   wire     [7:0] fifo_rd_status;      // status bits
   wire     [3:0] fifo_rd_tb_ctrl;     // Testbench control bits
   wire           wait_for_int;        // wait for interrupt trigger
   wire           wait_for_apb;        // wait for apb trigger
   wire           wait_for_sta;        // wait for status trigger
   wire           fifo_rd_not_ok;      // Decide if an error with read- not used
   reg            fifo_rd_done;        // indicates test end
   wire     [3:0] fifo_rd_queue;

   // read FIFO state mechine
   reg      [1:0] current_state;       // cs of state machine
   reg      [1:0] next_state;          // ns of state machine

   // detect status of read FIFO
   reg            p_dma_tx_end_tog;    // delayed dma_tx_end_tog for edge detect
   reg      [3:0] p_tx_r_status;       // sampled read status at dma_tx_end_tog
   reg            tx_status_update;    // time to toggle back dma_tx_status_tog
   integer        m;                   // loop variable for tx_status_update
   reg            dma_tx_status_tog;   // status taken toggle handshake
   reg            dma_tx_status_del;   // delayed status taken toggle
   reg            tx_end_frm_occurred; // a tx frame ended
   reg            underflow_saved;     // save tx fifo underrun required
   wire           do_underflow;        // Is tx underflow required?
   reg            underflow_occurred;  // underflow
   reg            coll_occurred;       // collision occurred
   reg            late_coll_occurred;  // late collision occurred
   reg            toomanyrtry_occurred;// too may retries

   // delays for read valid latency
   reg            tx_r_rd_delay1;      // first stage of variable latency
   reg            tx_r_rd_delay2;      // second stage of variable latency
   reg            tx_r_rd_delay3;      // third stage of variable latency
   reg            tx_r_rd_delay4;      // fourth stage of variable latency
   reg            tx_r_rd_delay5;      // fifth stage of variable latency
   reg            tx_r_rd_delay6;      // sixth stage of variable latency
   reg            tx_r_rd_delay7;      // seventh stage of variable latency
   wire           valid_read;          // decoded read for asserting valid

   // signals for random flush delay
   reg      [4:0] clk_cnt;             // delay count
   reg      [4:0] clk_delay;           // delay value

   // FIFO read outputs
   reg    [127:0] tx_r_data;           // Read Data (64 bit)
   reg      [3:0] tx_r_mod;            // Modulo
   reg            tx_r_eop;            // End of packet indicator
   reg            tx_r_sop;            // Start of packet indicator
   reg            tx_r_err;            // Error indicator
   reg   [`edma_queues-1:0] tx_r_data_rdy;       // 1 or more packets are in FIFO
   reg            tx_r_data_rdy_del;   // delayed tx_r_data_rdy
   reg            tx_r_control;        // TX read in-line control
   wire           tx_r_underflow;      // signals tx fifo underrun.
   reg            tx_r_flushed;        // tx fifo has been flushed.

   // write FIFO array for test file data
   reg     [99:0] fifo_wr_vector_reg [0:100000];
                                       // array for holding write data
  `ifdef gem_fifo_8b_if
   reg [1:0]      fifo_wr_sub_index;   // index to current fifo_wr_vector_reg
  `endif
   integer        fifo_wr_index;       // index to current fifo_wr_vector_reg
   integer        k;                   // loop variable for write array
   wire    [99:0] fifo_wr_vector;      // bit-select reg for  write data[31:0]
   wire    [99:0] fifo_wr_vector2;     // bit-select reg for  write data[63:32]
   wire    [99:0] fifo_wr_vector3;     // bit-select reg for  write data[95:64]
   wire    [99:0] fifo_wr_vector4;     // bit-select reg for  write data[127:96]
   wire    [47:0] fifo_wr_status;      // expect write status
   wire     [3:0] fifo_wr_queue;       // bit select for write queue
   wire     [3:0] fifo_wr_tb_ctrl;     // write FIFO Testbench control bits
   wire           fifo_wr_int;         // increment pointer when interrupt
   wire           fifo_wr_apb;         // increment pointer when apb trigger
   wire           fifo_wr_done;        // indicates test end

   // write FIFO outputs
   reg    [127:0] fifo_wr_data;        // write data
   wire     [3:0] fifo_wr_mod;         // Modulo
   wire           fifo_wr_eop;         // End of packet indicator
   wire           fifo_wr_sop;         // Start of packet indicator
   wire           fifo_wr_err;         // Error indicator
   wire           fifo_wr_wr;          // Write strobe

   // delays for overflow
   reg            rx_w_wr_delay1;      // first stage of variable latency
   reg            rx_w_wr_delay2;      // second stage of variable latency
   reg            rx_w_wr_delay3;      // third stage of variable latency
   reg            rx_w_wr_delay4;      // fourth stage of variable latency
   reg            rx_w_wr_delay5;      // fifth stage of variable latency
   reg            rx_w_wr_delay6;      // sixth stage of variable latency
   reg            rx_w_wr_delay7;      // seventh stage of variable latency

   // testbench fail indications
   reg            sta_fail;            // status check failed on write
   reg            eop_fail;            // eop not seen when expected on write
   reg            sop_fail;            // sop not seen when expected on write
   reg            err_fail;            // err not seen when expected on write
   reg            mod_fail;            // expected mod value not seen on write
   reg            wr_data_fail;        // expected data value not seen on write
   reg            tx_stat_fail;        // status check failed on read
   wire           fifo_fail;           // any of the above failures are ture


// -----------------------------------------------------------------------------
// Detect triggers in tx_clk domain
// -----------------------------------------------------------------------------

   // wait for interrupt or apb triggers (TX read side)
   always @(reset_tb or trig_from_apb or int_pulse or trig)
      if (trig | ~reset_tb)
      begin
         trig_from_apb_lat = 1'b0;
         int_pulse_lat = 1'b0;
      end
      else
      begin
         if (trig_from_apb)
            trig_from_apb_lat = 1'b1;
         if (int_pulse)
            int_pulse_lat = 1'b1;
      end

   // trigger once waiting and seen a new input trigger (TX read side)
   always@(negedge reset_tb or posedge tx_clk)
      if(~reset_tb)
         trig <= 1'd0;
      else
         trig <= ((trig_from_apb_lat & wait_for_apb) |
                  (int_pulse_lat & wait_for_int) &
                  ~fifo_done);



   // wait for interrupt or apb triggers (RX write side)
   always @(reset_tb or trig_from_apb or int_pulse or trig_wr)
      if (trig_wr | ~reset_tb)
      begin
         trig_from_apb_wr_lat = 1'b0;
         int_pulse_wr_lat = 1'b0;
      end
      else
      begin
         if (trig_from_apb)
            trig_from_apb_wr_lat = 1'b1;
         if (int_pulse)
            int_pulse_wr_lat = 1'b1;
      end

   // trigger once waiting and seen a new input trigger (RX write side)
   always@(negedge reset_tb or posedge rx_clk)
      if(~reset_tb)
         trig_wr <= 1'd0;
      else
         trig_wr <= ((trig_from_apb_wr_lat & fifo_wr_apb) |
                     (int_pulse_wr_lat & fifo_wr_int) &
                     ~fifo_done);


// -----------------------------------------------------------------------------
// Initialise read data array
// -----------------------------------------------------------------------------

   // read FIFO array
   initial
   begin
      for (j=0; j<=1023; j=j+1)
         fifo_rd_vector_reg[j] = 60'b0;

      $readmemh("./files/tb_fifo_rd.data",fifo_rd_vector_reg);
      if (fifo_rd_vector_reg[0] === 60'hx)
         $display("\n No fifo read data file read \n");
   end

   // reference next four words for building up 128 bit data
   assign fifo_rd_vector     = fifo_rd_vector_reg[fifo_rd_index];
   assign fifo_rd_vector2    = fifo_rd_vector_reg[fifo_rd_index+1];
   assign fifo_rd_vector3    = fifo_rd_vector_reg[fifo_rd_index+2];
   assign fifo_rd_vector4    = fifo_rd_vector_reg[fifo_rd_index+3];

   // extarct status and control from current word in array
   assign fifo_rd_status     = fifo_rd_vector_st[51:44];
   assign fifo_rd_ctrl       = fifo_rd_vector[43:36];
   assign fifo_rd_tb_ctrl    = fifo_rd_vector[55:52];
   assign fifo_rd_queue      = fifo_rd_vector[59:56];

   // decode testbench control
   assign fifo_rd_not_ok     = (fifo_rd_tb_ctrl == 4'h1);
   assign wait_for_int       = (fifo_rd_tb_ctrl == 4'h2);
   assign wait_for_apb       = (fifo_rd_tb_ctrl == 4'h3);
   assign wait_for_sta       = (fifo_rd_tb_ctrl == 4'h4);


   // synchronous process to set fifo_rd_done
   always@(negedge reset_tb or posedge tx_clk)
   begin
      if(~reset_tb)
         fifo_rd_done <= 1'b0;
      else if (fifo_rd_tb_ctrl == 4'hf)
         fifo_rd_done <= 1'b1;
      else
         fifo_rd_done <=  fifo_rd_done;
   end


// -----------------------------------------------------------------------------
// Keep track of index value for read array
// -----------------------------------------------------------------------------
`ifdef gem_fifo_8b_if
wire [1:0] nxt_fifo_rd_sub_index;
assign nxt_fifo_rd_sub_index = (fifo_rd_sub_index + 2'h1);
`endif
   // synchronous process to determine value of index
   always@(negedge reset_tb or posedge tx_clk)
   begin
      if(~reset_tb)
      begin
         fifo_rd_index <= 0;
        `ifdef gem_fifo_8b_if
         fifo_rd_sub_index <= 2'b00;
        `endif
      end
      else if(((current_state == wait_for_valid) & valid_read) |
              ((current_state == output_data) & valid_read))
      begin
         // decide how many to advance depending on how many get checked
        `ifdef gem_fifo_8b_if
          // If full word or EOP/ERR/underflow
          if (( fifo_rd_sub_index == 3) |
              ((fifo_rd_ctrl[0] | fifo_rd_ctrl[2]) & fifo_rd_vector[35:32] == nxt_fifo_rd_sub_index[1:0]) |
                fifo_rd_ctrl[4])
          begin
            fifo_rd_sub_index <= 0;
            fifo_rd_index <= !fifo_rd_done ? fifo_rd_index + 1 : fifo_rd_index;
            $display("            FIFO TX READ DATA                                  %h",tx_r_data[31:0]);
          end
          else
            fifo_rd_sub_index <= fifo_rd_sub_index + 1;
        `else
          case (dma_bus_width)
            2'b00   : begin // 32 bit mode
                         fifo_rd_index <= fifo_rd_index + 1;
                         $display("            FIFO TX READ DATA                                  %h",tx_r_data[31:0]);
                      end
            2'b01   : begin // 64 bit mode
                         fifo_rd_index <= fifo_rd_index + 2;
                         $display("            FIFO TX READ DATA                                  %h",tx_r_data[63:0]);
                      end
            default : begin // 128 bit mode
                         fifo_rd_index <= fifo_rd_index + 4;
                         $display("            FIFO TX READ DATA                                  %h",tx_r_data[127:0]);
                      end
          endcase
        `endif

      end
      else if (wait_for_sta & (dma_tx_status_tog ^ dma_tx_status_del))
      begin
        `ifdef gem_fifo_8b_if
          if (( fifo_rd_sub_index == 3) |
              ((fifo_rd_ctrl[0] | fifo_rd_ctrl[2]) & fifo_rd_vector[35:32] == nxt_fifo_rd_sub_index[1:0]) |
                fifo_rd_ctrl[4])
          begin
            fifo_rd_sub_index <= 0;
            fifo_rd_index <= fifo_rd_index + 1;
          end
          else
            fifo_rd_sub_index <= fifo_rd_sub_index + 1;
        `else
          case (dma_bus_width)
            2'b00   : fifo_rd_index <= fifo_rd_index + 1; // 32 bit mode
            2'b01   : fifo_rd_index <= fifo_rd_index + 2; // 64 bit mode
            default : fifo_rd_index <= fifo_rd_index + 4; // 128 bit mode
          endcase
        `endif
      end
   end


// -----------------------------------------------------------------------------
// state machine for FIFO reads
// -----------------------------------------------------------------------------
   // combinatorial process to determine next_state and comb_index value
   always@(trig or valid_read or tx_r_eop or tx_r_data_rdy or current_state or
           tx_r_err or tx_r_underflow)
   begin
      case(current_state)
         wait_for_apb_trg:
         begin
            if(trig)
               next_state = wait_for_valid;
            else
               next_state = wait_for_apb_trg;
         end

         wait_for_valid:
         begin
            if(valid_read)
               next_state = output_data;
            else
               next_state    = wait_for_valid;
         end

         output_data:
         begin
            if((tx_r_eop | tx_r_err | tx_r_underflow) & (~tx_r_data_rdy[fifo_rd_queue] ))
               next_state = wait_for_apb_trg;
            else
               next_state = output_data;
         end

         default:
            next_state = wait_for_apb_trg;
      endcase
   end


   // synchronous process to assign current_state
   always@(negedge reset_tb or posedge tx_clk)
   begin
      if(~reset_tb)
         current_state <= wait_for_apb_trg;
      else
         current_state <= next_state;
   end


// -----------------------------------------------------------------------------
// Decode state machine for FIFO read outputs
// -----------------------------------------------------------------------------
   // combinatorial process to control outputs
   always@(current_state or valid_read or fifo_rd_vector or fifo_rd_ctrl
           or dma_bus_width or fifo_rd_vector2 or fifo_rd_vector3
           or fifo_rd_vector4 or tx_r_data_rdy_del
   `ifdef gem_fifo_8b_if
    or fifo_rd_sub_index)
   `else
    )
   `endif
   begin
      case(current_state)
         wait_for_apb_trg:
         begin
            tx_r_mod            = 4'd0;
            tx_r_eop            = 1'd0;
            tx_r_sop            = 1'd0;
            tx_r_err            = 1'd0;
            tx_r_data_rdy       = 1'd0;
            tx_r_control        = 1'd0;
            tx_r_data           = 128'd0;
            underflow_saved     = 1'b0;
         end

         wait_for_valid:
         begin
            if(valid_read)
            begin
               tx_r_mod                     = fifo_rd_vector[35:32];
               tx_r_data_rdy[fifo_rd_queue] = fifo_rd_ctrl[3];
               underflow_saved              = fifo_rd_ctrl[4];

               // drive fifo_rd_data with correct width of data
              `ifdef gem_fifo_8b_if
                tx_r_sop           = fifo_rd_ctrl[1] & fifo_rd_sub_index == 0;
                tx_r_control       = fifo_rd_ctrl[6] & fifo_rd_sub_index == 0;
                if (fifo_rd_vector[35:32] == 4'h0)
                begin
                  tx_r_eop         = fifo_rd_ctrl[0] & fifo_rd_sub_index == 3;
                  tx_r_err         = fifo_rd_ctrl[2] & fifo_rd_sub_index == 3;
                end
                else
                begin
                  tx_r_eop         = fifo_rd_ctrl[0] & fifo_rd_sub_index == fifo_rd_vector[35:32] - 1;
                  tx_r_err         = fifo_rd_ctrl[2] & fifo_rd_sub_index == fifo_rd_vector[35:32] - 1;
                end
                case (fifo_rd_sub_index)
                0:tx_r_data = {120'b0, fifo_rd_vector[7:0]};// 8 bit
                1:tx_r_data = {120'b0, fifo_rd_vector[15:8]};// 8 bit
                2:tx_r_data = {120'b0, fifo_rd_vector[23:16]};// 8 bit
                3:tx_r_data = {120'b0, fifo_rd_vector[31:24]};// 8 bit
                endcase
              `else
                tx_r_sop            = fifo_rd_ctrl[1];
                tx_r_eop            = fifo_rd_ctrl[0];
                tx_r_err            = fifo_rd_ctrl[2];
                tx_r_control        = fifo_rd_ctrl[6];
                case (dma_bus_width)
                  2'b00   : tx_r_data = {96'b0, fifo_rd_vector[31:0]};// 32 bit
                  2'b01   : tx_r_data = {64'b0,                       // 64 bit
                                         fifo_rd_vector2[31:0],
                                         fifo_rd_vector[31:0]};
                  default : tx_r_data = {fifo_rd_vector4[31:0],       // 128 bit
                                         fifo_rd_vector3[31:0],
                                         fifo_rd_vector2[31:0],
                                         fifo_rd_vector[31:0]};
               endcase
              `endif
            end

            else
            begin
               tx_r_mod                     = 4'd0;
               tx_r_eop                     = 1'd0;
               tx_r_sop                     = 1'd0;
               tx_r_err                     = 1'd0;
               // If force RDY low bit is set then use delayed version
               tx_r_data_rdy[fifo_rd_queue] = (fifo_rd_ctrl[7])?tx_r_data_rdy_del : 1'b1;
               tx_r_control                 = 1'd0;
               tx_r_data                    = 128'd0;
               underflow_saved              = underflow_saved;
            end
         end

         output_data:
         begin
            if(valid_read)
            begin
               tx_r_mod                     = fifo_rd_vector[35:32];
               tx_r_eop                     = fifo_rd_ctrl[0];
               tx_r_sop                     = fifo_rd_ctrl[1];
               tx_r_err                     = fifo_rd_ctrl[2];
               tx_r_data_rdy[fifo_rd_queue] = fifo_rd_ctrl[3];
               underflow_saved              = fifo_rd_ctrl[4];
               tx_r_control                 = fifo_rd_ctrl[6];

               // drive fifo_rd_data with correct width of data
              `ifdef gem_fifo_8b_if
                tx_r_sop           = fifo_rd_ctrl[1] & fifo_rd_sub_index == 0;
                tx_r_control       = fifo_rd_ctrl[6] & fifo_rd_sub_index == 0;
                if (fifo_rd_vector[35:32] == 4'h0)
                begin
                  tx_r_eop         = fifo_rd_ctrl[0] & fifo_rd_sub_index == 3;
                  tx_r_err         = fifo_rd_ctrl[2] & fifo_rd_sub_index == 3;
                end
                else
                begin
                  tx_r_eop         = fifo_rd_ctrl[0] & fifo_rd_sub_index == fifo_rd_vector[35:32] - 1;
                  tx_r_err         = fifo_rd_ctrl[2] & fifo_rd_sub_index == fifo_rd_vector[35:32] - 1;
                end
                case (fifo_rd_sub_index)
                2'h0:tx_r_data = {120'b0, fifo_rd_vector[7:0]};// 8 bit
                2'h1:tx_r_data = {120'b0, fifo_rd_vector[15:8]};// 8 bit
                2'h2:tx_r_data = {120'b0, fifo_rd_vector[23:16]};// 8 bit
                2'h3:tx_r_data = {120'b0, fifo_rd_vector[31:24]};// 8 bit
                endcase
              `else
                tx_r_sop            = fifo_rd_ctrl[1];
                tx_r_eop            = fifo_rd_ctrl[0];
                tx_r_err            = fifo_rd_ctrl[2];
                tx_r_control        = fifo_rd_ctrl[6];
                case (dma_bus_width)
                 2'b00   : tx_r_data = {96'b0, fifo_rd_vector[31:0]};// 32 bit
                 2'b01   : tx_r_data = {64'b0,                       // 64 bit
                                        fifo_rd_vector2[31:0],
                                        fifo_rd_vector[31:0]};
                 default : tx_r_data = {fifo_rd_vector4[31:0],       // 128 bit
                                        fifo_rd_vector3[31:0],
                                        fifo_rd_vector2[31:0],
                                        fifo_rd_vector[31:0]};
                endcase
              `endif
            end

            else
            begin
               tx_r_mod                     = 4'd0;
               tx_r_eop                     = 1'd0;
               tx_r_sop                     = 1'd0;
               tx_r_err                     = 1'd0;
               // If force RDY low bit is set then use delayed version
               tx_r_data_rdy[fifo_rd_queue] = (fifo_rd_ctrl[7])? tx_r_data_rdy_del : tx_r_data_rdy[fifo_rd_queue];
               tx_r_control                 = 1'd0;
               tx_r_data                    = 128'd0;
               underflow_saved              = underflow_saved;
            end
         end

         default:
         begin
            tx_r_mod                      = 4'd0;
            tx_r_data                     = 128'd0;
            tx_r_eop                      = 1'd0;
            tx_r_sop                      = 1'd0;
            tx_r_err                      = 1'd0;
            tx_r_data_rdy[fifo_rd_queue]  = 1'd1;
            tx_r_control                  = 1'd0;
            underflow_saved               = underflow_saved;
         end
      endcase
   end


// -----------------------------------------------------------------------------
// tx_r_data_rdy output control
// -----------------------------------------------------------------------------

   // delay tx_r_data_rdy and force low if control bit is set.
   // Delayed version used so that tx_r_data_rdy is there for at least one clock
   always@(negedge reset_tb or posedge tx_clk)
      if (~reset_tb)
         tx_r_data_rdy_del <= 1'b0;
      else
         tx_r_data_rdy_del <= tx_r_data_rdy[fifo_rd_queue]  & ~fifo_rd_ctrl[7];


// -----------------------------------------------------------------------------
// Read FIFO underflow output
// -----------------------------------------------------------------------------

   // decide whether to do an underflow. If underflow delay is greater than
   // the read valid latency then use saved version as read index has
   // incremented by now.
   assign do_underflow = (fifo_under_delay > fifo_latency)? underflow_saved :
                                                            fifo_rd_ctrl[4];

   // delay tx_r_underflow by delay specified by fifo_under_delay from tx_r_rd
   assign tx_r_underflow =
                       (fifo_under_delay == 7) ? tx_r_rd_delay7 & do_underflow :
                       (fifo_under_delay == 6) ? tx_r_rd_delay6 & do_underflow :
                       (fifo_under_delay == 5) ? tx_r_rd_delay5 & do_underflow :
                       (fifo_under_delay == 4) ? tx_r_rd_delay4 & do_underflow :
                       (fifo_under_delay == 3) ? tx_r_rd_delay3 & do_underflow :
                       (fifo_under_delay == 2) ? tx_r_rd_delay2 & do_underflow :
                       (fifo_under_delay == 1) ? tx_r_rd_delay1 & do_underflow :
                       |tx_r_rd  & do_underflow;

// -----------------------------------------------------------------------------
// Delay tx_r_valid from tx_r_rd/ latency is defined by fifo_latency signal.
// -----------------------------------------------------------------------------

   // Generate parameterised stage pipeline for read data
   always @ (negedge reset_tb or posedge tx_clk )
   begin
     if (~reset_tb)
     begin
       tx_r_rd_delay1 <= 1'b0;
       tx_r_rd_delay2 <= 1'b0;
       tx_r_rd_delay3 <= 1'b0;
       tx_r_rd_delay4 <= 1'b0;
       tx_r_rd_delay5 <= 1'b0;
       tx_r_rd_delay6 <= 1'b0;
       tx_r_rd_delay7 <= 1'b0;
     end
     else
     begin
       tx_r_rd_delay1 <= |tx_r_rd ;
       tx_r_rd_delay2 <= tx_r_rd_delay1;
       tx_r_rd_delay3 <= tx_r_rd_delay2;
       tx_r_rd_delay4 <= tx_r_rd_delay3;
       tx_r_rd_delay5 <= tx_r_rd_delay4;
       tx_r_rd_delay6 <= tx_r_rd_delay5;
       tx_r_rd_delay7 <= tx_r_rd_delay6;
     end
   end


   assign valid_read = (fifo_latency == 7) ? tx_r_rd_delay7 :
                       (fifo_latency == 6) ? tx_r_rd_delay6 :
                       (fifo_latency == 5) ? tx_r_rd_delay5 :
                       (fifo_latency == 4) ? tx_r_rd_delay4 :
                       (fifo_latency == 3) ? tx_r_rd_delay3 :
                       (fifo_latency == 2) ? tx_r_rd_delay2 :
                       (fifo_latency == 1) ? tx_r_rd_delay1 :
                       tx_r_rd;

   assign tx_r_valid = valid_read;


// -----------------------------------------------------------------------------
// Read FIFO status detection
// -----------------------------------------------------------------------------

   // used to detect both edges of dma_tx_status_tog
   // enables tx fifo interface to move check data
   // when trigger is set to (sta).
   always@(negedge reset_tb or posedge tx_clk)
      if(~reset_tb)
         dma_tx_status_del <= 1'b0;
      else
         dma_tx_status_del <= dma_tx_status_tog;


   // asynchronous process to set expected fifo_rd_status
   always@(reset_tb or fifo_rd_index or dma_bus_width)
   begin
      if(~reset_tb)
         fifo_rd_vector_st = 56'b0;
      else
         case (dma_bus_width)
            2'b00   : begin // 32 bit mode
                         if (fifo_rd_index == 0)
                            fifo_rd_vector_st = fifo_rd_vector_reg[0];
                         else
                            fifo_rd_vector_st = fifo_rd_vector_reg[fifo_rd_index-1];
                      end
            2'b01   : begin // 64 bit mode
                         if (fifo_rd_index <= 2)
                            fifo_rd_vector_st = fifo_rd_vector_reg[0];
                         else
                            fifo_rd_vector_st = fifo_rd_vector_reg[fifo_rd_index-2];
                      end
            default : begin // 128 bit mode
                         if (fifo_rd_index <= 4)
                            fifo_rd_vector_st = fifo_rd_vector_reg[0];
                         else
                            fifo_rd_vector_st = fifo_rd_vector_reg[fifo_rd_index-4];
                      end
         endcase
   end


   // detect a change in the status
   always@(negedge reset_tb or posedge tx_clk)
   begin
      if (~reset_tb)
      begin
         coll_occurred        <= 1'b0;
         late_coll_occurred   <= 1'b0;
         toomanyrtry_occurred <= 1'b0;
         underflow_occurred   <= 1'b0;
         tx_end_frm_occurred  <= 1'b0;
         p_tx_r_status        <= 4'b0;
         p_dma_tx_end_tog     <= 1'b0;
      end
      else
      begin
         coll_occurred        <= 1'b0;
         late_coll_occurred   <= 1'b0;
         toomanyrtry_occurred <= 1'b0;
         underflow_occurred   <= 1'b0;
         tx_end_frm_occurred  <= 1'b0;

         if (((tx_r_status[3] == 1'b1) & (p_tx_r_status[3] == 1'b0)) |
             ((tx_r_underflow == 1'b1) & (tx_r_sop == 1'b1)))
            underflow_occurred <= 1'b1;
         if ((tx_r_status[2] == 1'b1) & (p_tx_r_status[2] == 1'b0))
            coll_occurred <= 1'b1;
         if ((tx_r_status[1] == 1'b1) & (p_tx_r_status[1] == 1'b0))
            late_coll_occurred <= 1'b1;
         if ((tx_r_status[0] == 1'b1) & (p_tx_r_status[0] == 1'b0))
            toomanyrtry_occurred <= 1'b1;
         if (dma_tx_end_tog ^ p_dma_tx_end_tog)
            tx_end_frm_occurred <= 1'b1;

         p_tx_r_status      <= tx_r_status;
         p_dma_tx_end_tog   <= dma_tx_end_tog;
      end
   end


   // detect and delay TX status handshaking
   always@(tx_end_frm_occurred or coll_occurred)
   begin
      tx_status_update <= 1'b0;
      if (tx_end_frm_occurred | coll_occurred)
         begin
            // wait for 10 * fifo_status_delay clock cycles
            for (m = 0; m < (fifo_status_delay * 10); m = m + 1)
               @(posedge tx_clk);

            // now pulse handshaking update after delay
            tx_status_update <= 1'b1;
            @(posedge tx_clk);
            tx_status_update <= 1'b0;
         end
   end


   // generate TX status handshaking
   always@(negedge reset_tb or posedge tx_clk)
   begin
      if(~reset_tb)
         dma_tx_status_tog  <= 1'b0;
      else if (tx_status_update)
         dma_tx_status_tog <= ~dma_tx_status_tog;
   end


   // check tx rd status at end of frame
   always@(negedge reset_tb or posedge tx_clk)
   begin
      if(~reset_tb)
      begin
         tx_stat_fail <= 1'b0;
      end
      else if (tx_end_frm_occurred | coll_occurred)
      begin
         if ((fifo_rd_status[3:0] === tx_r_status[3:0]) |
             (fifo_rd_status[3:0] === 4'hx))
            $display("       good TX FIFO STATUS    expected :- %h  got :- %h",fifo_rd_status[3:0],tx_r_status);
         else if (fifo_rd_status[3:0] !== tx_r_status[3:0])
         begin
            $display("\n **** error TX FIFO STATUS IS BAD    expected :- %h  got :-  %h",fifo_rd_status[3:0],tx_r_status);
            tx_stat_fail <= 1'b1;
         end
      end
   end


// -----------------------------------------------------------------------------
// Read FIFO flush. Delay flush assertion by a random amount
// -----------------------------------------------------------------------------

   //behavioural process to assert tx_r_flushed for 1 clk cycle
   always @ (negedge reset_tb or posedge coll_occurred
                              or posedge late_coll_occurred
                              or posedge underflow_occurred
                              or posedge toomanyrtry_occurred)
   begin
      if (~reset_tb)
      begin
         tx_r_flushed = 1'b0;
      end
      else
      begin
         clk_cnt = 0;
         clk_delay = ({$random} % 10) + 10; // a number between 10 & 20

         while (clk_cnt < clk_delay)
         begin
            @(posedge tx_clk);
            clk_cnt = clk_cnt + 1;
         end

         tx_r_flushed = 1'b1;

         @(posedge tx_clk);

         tx_r_flushed = 1'b0;
      end
   end





// -----------------------------------------------------------------------------
// Write FIFO array, initialised with test file data
// -----------------------------------------------------------------------------

   // write array
   initial
      begin
         for (k=0; k<=1023; k=k+1)
            fifo_wr_vector_reg[k] = 100'b0;

         $readmemh("./files/tb_fifo_wr.data",fifo_wr_vector_reg);
         if (fifo_wr_vector_reg[0] === 100'hx)
            $display("\n No fifo write data file read \n");
      end


   assign fifo_wr_vector     = fifo_wr_vector_reg[fifo_wr_index];
   assign fifo_wr_vector2    = fifo_wr_vector_reg[fifo_wr_index+1];
   assign fifo_wr_vector3    = fifo_wr_vector_reg[fifo_wr_index+2];
   assign fifo_wr_vector4    = fifo_wr_vector_reg[fifo_wr_index+3];


   // select data to compare against according to bus width
   always @(dma_bus_width or fifo_wr_vector or fifo_wr_vector2 or
            fifo_wr_vector3 or fifo_wr_vector4
      `ifdef gem_fifo_8b_if
       or fifo_wr_sub_index)
      `else
      )
      `endif
       begin
        `ifdef gem_fifo_8b_if
        fifo_wr_data = {96'b0, fifo_wr_vector[31:0]}; // 32 bits
        `else
         case (dma_bus_width)
            2'b00   : fifo_wr_data = {96'b0, fifo_wr_vector[31:0]}; // 32 bits

            2'b01   : fifo_wr_data = {64'b0,                        // 64 bits
                                      fifo_wr_vector2[31:0],
                                      fifo_wr_vector[31:0]};

            default : fifo_wr_data = {fifo_wr_vector4[31:0],        // 128 bits
                                      fifo_wr_vector3[31:0],
                                      fifo_wr_vector2[31:0],
                                      fifo_wr_vector[31:0]};
         endcase
        `endif
      end
  `ifdef gem_fifo_8b_if
  reg  [127:0] rx_w_data_held;
   always @(rx_w_data or fifo_wr_sub_index)
         case (fifo_wr_sub_index)
         0:rx_w_data_held = {120'd0,rx_w_data[7:0]};// 8 bit
         1:rx_w_data_held = {112'd0,rx_w_data[7:0],rx_w_data_held[7:0]};// 8 bit
         2:rx_w_data_held = {104'd0,rx_w_data[7:0],rx_w_data_held[15:0]};// 8 bit
         3:rx_w_data_held = {96'd0,rx_w_data[7:0],rx_w_data_held[23:0]};// 8 bit
         endcase
  `endif


  `ifdef gem_fifo_8b_if
   wire [3:0] fifo_wr_mod_m1;
   assign fifo_wr_status     = fifo_wr_vector[79:32];
   assign fifo_wr_mod_m1     = fifo_wr_vector[83:80] - 4'h1;
   assign fifo_wr_eop        = fifo_wr_vector[84] & fifo_wr_sub_index == fifo_wr_mod_m1[1:0];
   assign fifo_wr_sop        = fifo_wr_vector[85] & fifo_wr_sub_index == 2'b00;
   assign fifo_wr_mod        = fifo_wr_vector[83:80] & fifo_wr_sub_index == fifo_wr_mod_m1[1:0];
   assign fifo_wr_err        = fifo_wr_vector[86];
   assign fifo_wr_wr         = fifo_wr_vector[87];
   assign fifo_wr_queue      = fifo_wr_vector[95:92];
   assign fifo_wr_tb_ctrl    = fifo_wr_vector[99:96];
  `else
   assign fifo_wr_status     = fifo_wr_vector[79:32];
   assign fifo_wr_mod        = fifo_wr_vector[83:80];
   assign fifo_wr_eop        = fifo_wr_vector[84];
   assign fifo_wr_sop        = fifo_wr_vector[85];
   assign fifo_wr_err        = fifo_wr_vector[86];
   assign fifo_wr_wr         = fifo_wr_vector[87];
   assign fifo_wr_queue      = fifo_wr_vector[95:92];
   assign fifo_wr_tb_ctrl    = fifo_wr_vector[99:96];
  `endif

   // decode tb control
   assign fifo_wr_int        = fifo_wr_tb_ctrl == 4'h1;
   assign fifo_wr_apb        = fifo_wr_tb_ctrl == 4'h2;
   assign fifo_wr_done       = fifo_wr_tb_ctrl == 4'hf;


// -----------------------------------------------------------------------------
// Write FIFO overflow output
// -----------------------------------------------------------------------------

   // delay rx_w_overflow by delay specified by fifo_over_delay from rx_w_wr
   assign rx_w_overflow_prdelay =
                 (fifo_over_delay == 7) ? rx_w_wr_delay7 :
                 (fifo_over_delay == 6) ? rx_w_wr_delay6 :
                 (fifo_over_delay == 5) ? rx_w_wr_delay5 :
                 (fifo_over_delay == 4) ? rx_w_wr_delay4 :
                 (fifo_over_delay == 3) ? rx_w_wr_delay3 :
                 (fifo_over_delay == 2) ? rx_w_wr_delay2 :
                 (fifo_over_delay == 1) ? rx_w_wr_delay1 :
                                          (rx_w_wr | fifo_wr_wr) &
                                             fifo_wr_vector[88];

   // Generate parameterised stage pipeline for overflow
   always @ (negedge reset_tb or posedge rx_clk )
   begin
     if (~reset_tb)
     begin
       rx_w_wr_delay1 <= 1'b0;
       rx_w_wr_delay2 <= 1'b0;
       rx_w_wr_delay3 <= 1'b0;
       rx_w_wr_delay4 <= 1'b0;
       rx_w_wr_delay5 <= 1'b0;
       rx_w_wr_delay6 <= 1'b0;
       rx_w_wr_delay7 <= 1'b0;
     end
     else
     begin
       if (rx_w_overflow & ~fifo_wr_vector[88])
         begin
           rx_w_wr_delay1 <= 1'b0;
           rx_w_wr_delay2 <= 1'b0;
           rx_w_wr_delay3 <= 1'b0;
           rx_w_wr_delay4 <= 1'b0;
           rx_w_wr_delay5 <= 1'b0;
           rx_w_wr_delay6 <= 1'b0;
           rx_w_wr_delay7 <= 1'b0;
         end
       else if (rx_w_wr & fifo_wr_vector[88])
         begin
           rx_w_wr_delay1 <= 1'b1;
         end
       else
         begin
           rx_w_wr_delay1 <= rx_w_wr_delay1;
           rx_w_wr_delay2 <= rx_w_wr_delay1;
           rx_w_wr_delay3 <= rx_w_wr_delay2;
           rx_w_wr_delay4 <= rx_w_wr_delay3;
           rx_w_wr_delay5 <= rx_w_wr_delay4;
           rx_w_wr_delay6 <= rx_w_wr_delay5;
           rx_w_wr_delay7 <= rx_w_wr_delay6;
         end
     end
   end

   initial rx_w_overflow = 1'b0;
   // Delay for GL sims. Note that in 8b FIFO mode, the clock is inverted before entering the design
   // so no need to delay in that case as the inverted clock does the same
   `ifdef gem_fifo_8b_if
   always @ (*) rx_w_overflow <= rx_w_overflow_prdelay;
   `else
   always @ (negedge rx_clk ) rx_w_overflow <= rx_w_overflow_prdelay;
   `endif


// -----------------------------------------------------------------------------
// Write FIFO array index and write data check
// -----------------------------------------------------------------------------

   // synchronous process to control fifo_wr_index and perform data check
   always@(negedge reset_tb or posedge rx_clk)
   begin
      if(~reset_tb)
         begin
            fifo_wr_index <= 0;
            wr_data_fail <= 1'b0;
           `ifdef gem_fifo_8b_if
            fifo_wr_sub_index <= 0;
           `endif
         end

      // wait for valid write to occur before checking data
      else if(rx_w_wr & ~fifo_wr_done)
      begin

         // decide how many to advance depending on how many get checked
        `ifdef gem_fifo_8b_if
          if (fifo_wr_sub_index == 3 | fifo_wr_eop)
          begin
            fifo_wr_sub_index <= 0;
            fifo_wr_index <= fifo_wr_index + 1;
          end
          else
            fifo_wr_sub_index <= fifo_wr_sub_index + 1;
        `else
         case (dma_bus_width)
            2'b00   : fifo_wr_index <= fifo_wr_index + 1;
            2'b01   : fifo_wr_index <= fifo_wr_index + 2;
            default : fifo_wr_index <= fifo_wr_index + 4;
         endcase
        `endif
        `ifdef gem_fifo_8b_if
         if((fifo_wr_sub_index == 3 | fifo_wr_eop) & (fifo_wr_data === rx_w_data_held) | (fifo_wr_data === 128'hx))
           $display("       good RX FIFO WRITE DATA    expected :- %h  got :- %h",fifo_wr_data[31:0],rx_w_data_held[31:0]);
        `else
         if((fifo_wr_data === rx_w_data) | (dma_bus_width == 2'b00 && fifo_wr_data[31:0] === 32'hx) | (dma_bus_width == 2'b01 && fifo_wr_data[63:0] === 64'hx) | (fifo_wr_data[127:0] === 128'hx))
            // decode bus width for reporting to screen
            case (dma_bus_width)
               2'b00   : $display("       good RX FIFO WRITE DATA    expected :- %h  got :- %h",fifo_wr_data[31:0],rx_w_data[31:0]);
               2'b01   : $display("       good RX FIFO WRITE DATA    expected :- %h  got :- %h",fifo_wr_data[63:0],rx_w_data[63:0]);
               default : $display("       good RX FIFO WRITE DATA    expected :- %h  got :- %h",fifo_wr_data[127:0],rx_w_data[127:0]);
            endcase
        `endif
         else
         begin
          `ifdef gem_fifo_8b_if
          if(fifo_wr_sub_index == 3 | fifo_wr_eop)
          begin
            $display("\n **** error RX FIFO WRITE DATA    expected :- %h  got :- %h, time = %0dns",fifo_wr_data[31:0],rx_w_data_held[31:0],$time);
            // decode bus width for reporting to screen
          `else
          begin
            case (dma_bus_width)
               2'b00   : $display("\n **** error RX FIFO WRITE DATA    expected :- %h  got :- %h",fifo_wr_data[31:0],rx_w_data[31:0]);
               2'b01   : $display("\n **** error RX FIFO WRITE DATA    expected :- %h  got :- %h",fifo_wr_data[63:0],rx_w_data[63:0]);
               default : $display("\n **** error RX FIFO WRITE DATA    expected :- %h  got :- %h",fifo_wr_data[127:0],rx_w_data[127:0]);
            endcase
          `endif
            wr_data_fail <= 1'b1;
           end
         end
      end

      // If a trigger seen then increment pointer
      else if(trig_wr)
      begin
        `ifdef gem_fifo_8b_if
          if (fifo_wr_sub_index == 3 | fifo_wr_eop)
          begin
            fifo_wr_sub_index <= 0;
            fifo_wr_index <= fifo_wr_index + 1;
          end
          else
            fifo_wr_sub_index <= fifo_wr_sub_index + 1;
        `else
         // decide how many to advance depending on how many get checked
         case (dma_bus_width)
            2'b00   : fifo_wr_index <= fifo_wr_index + 1;
            2'b01   : fifo_wr_index <= fifo_wr_index + 2;
            default : fifo_wr_index <= fifo_wr_index + 4;
         endcase
        `endif
      end

   end


// -----------------------------------------------------------------------------
// FIFO write MOD check
// -----------------------------------------------------------------------------

   // synchronous process to perform rx_w_mod_check
  `ifndef gem_fifo_8b_if
   always@(negedge reset_tb or posedge rx_clk)
   begin
      if(~reset_tb)
         mod_fail <= 1'b0;
      else
      begin
         if(rx_w_wr & (~fifo_wr_done))
         begin
            if(fifo_wr_eop == 1'b1)
            begin
               if((fifo_wr_mod === rx_w_mod) | (fifo_wr_mod === 4'hx))
                  $display("       good MOD written    expected :- %h  got :- %h",fifo_wr_mod,rx_w_mod);
               else
               begin
                  mod_fail <= 1'b1;
                  $display("\n **** error MOD WRITTEN IS BAD    expected :- %h  got :-  %h, time = %0dns",fifo_wr_mod,rx_w_mod,$time);
               end
            end
         end
      end
   end
  `endif

// -----------------------------------------------------------------------------
// FIFO write EOP check
// -----------------------------------------------------------------------------
   // synchronous process to perform rx_w_eop check
   always@(negedge reset_tb or posedge rx_clk)
   begin
      if(~reset_tb)
         eop_fail <= 1'b0;
      else
      begin
         if(rx_w_wr & (~fifo_wr_done))
         begin
            if((rx_w_eop === fifo_wr_eop) | (fifo_wr_eop === 1'bx))
               $display("       good EOP written    expected :- %h  got :- %h",fifo_wr_eop,rx_w_eop);
            else
            begin
               eop_fail <= 1'b1;
               $display("\n **** error EOP WRITTEN IS BAD    expected :- %h  got :-  %h, time = %0dns",fifo_wr_eop,rx_w_eop,$time);
            end
         end
      end
   end


// -----------------------------------------------------------------------------
// FIFO write SOP check
// -----------------------------------------------------------------------------
   // synchronous process to perform fifo_wr_sop check
   always@(negedge reset_tb or posedge rx_clk)
   begin
      if(~reset_tb)
         sop_fail <= 1'b0;
      else
      begin
         if(rx_w_wr & (~fifo_wr_done))
         begin
            if((rx_w_sop === fifo_wr_sop) | (fifo_wr_sop === 1'bx))
               $display("       good SOP written    expected :- %h  got :- %h",fifo_wr_sop,rx_w_sop);
            else
            begin
               sop_fail <= 1'b1;
               $display("\n **** error SOP WRITTEN IS BAD    expected :- %h  got :-  %h, time = %0dns",fifo_wr_sop,rx_w_sop,$time);
            end
         end
      end
   end


// -----------------------------------------------------------------------------
// FIFO write ERR check
// -----------------------------------------------------------------------------
   // synchronous process to perform rx_w_err check
   always@(negedge reset_tb or posedge rx_clk)
   begin
      if(~reset_tb)
         err_fail <= 1'b0;
      else
      begin
         if(rx_w_wr & (~fifo_wr_done))
         begin
            if(fifo_wr_eop == 1'b1)
            begin
               if((fifo_wr_err === rx_w_err) | (fifo_wr_err === 1'bx))
                  $display("       good ERR written    expected :- %h  got :- %h",fifo_wr_err,rx_w_err);
               else
               begin
                  err_fail <= 1'b1;
                  $display("\n **** error ERR WRITTEN IS BAD    expected :- %h  got :-  %h, time = %0dns",fifo_wr_err,rx_w_err,$time);
               end
            end
         end
      end
   end


// -----------------------------------------------------------------------------
// FIFO write status check
// -----------------------------------------------------------------------------
   // synchronous process to perform rx_status check
   always@(negedge reset_tb or posedge rx_clk)
   begin
      if(~reset_tb)
         sta_fail <= 1'b0;
      else
      begin
         if(rx_w_wr & (~fifo_wr_done))
         begin
            if(fifo_wr_eop == 1'b1)
            begin
               if(  (fifo_wr_status[44:0] === rx_status) | (fifo_wr_status === 48'hx) |
                   ((fifo_wr_status[39:0] === rx_status[39:0]) & (fifo_wr_status[47:40] === 8'hx)))
                  $display("       good RX_STATUS      expected :- %h  got :- %h",fifo_wr_status[44:0],rx_status);
               else
               begin
                  sta_fail <= 1'b1;
                  $display("\n **** error RX_STATUS IS BAD      expected :- %h  got :-  %h",fifo_wr_status[44:0],rx_status);
               end
               if(  (fifo_wr_queue[3:0] === rx_w_queue) | (fifo_wr_queue === 4'hx))
                  $display("       good RX_QUEUE      expected :- %h  got :- %h",fifo_wr_queue[3:0],rx_w_queue);
               else
               begin
                  sta_fail <= 1'b1;
                  $display("\n **** error RX_QUEUE IS BAD      expected :- %h  got :-  %h",fifo_wr_queue[3:0],rx_w_queue);
               end
            end
         end
      end
   end


// -----------------------------------------------------------------------------
// Testbench fail & done reporting
// -----------------------------------------------------------------------------

   // detect any failures and pass to upper testbench
   assign fifo_fail = (sta_fail | eop_fail | sop_fail | mod_fail |
                       err_fail | wr_data_fail | tx_stat_fail);

   // detect when both read and write testbenches are complete.
   assign fifo_done = (fifo_wr_done & fifo_rd_done);


endmodule

