//------------------------------------------------------------------------------
// Copyright (c) 2013-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_fifo_loop.sv
//   Module Name:        tb_fifo_loop
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
// Description    :
//
// The purpose of this file is to provide a FIFO loopback mode of operation,
// where the receive FIFO data is looped back to the transmit FIFO side.
//
// The block effectively functions in store and forward mode, as once a full
// packet is received, the packet will be transmitted. This module uses internal
// queues to implement this feature.
//
//------------------------------------------------------------------------------


module tb_fifo_loop (

   input loopback,

   // TX FIFO Interface
   input tx_clk,
  `ifdef gem_fifo_8b_if
      output logic [7:0] tx_r_data,
  `else
      output logic [127:0] tx_r_data,
   `endif
   output logic [3:0] tx_r_mod,
   output logic tx_r_sop,
   output logic tx_r_eop,
   output tx_r_err,
   input  tx_r_rd,
  `ifdef gem_fifo_8b_if
      input tx_r_fixed_lat,
      input [7:0] tx_enet_data,
  `endif
   output logic tx_r_valid,
   output logic tx_r_data_rdy,
   output tx_r_underflow,
   output tx_r_flushed,
   output tx_r_control,
   input [3:0] tx_r_status,

   // RX FIFO Interface
   input rx_clk,
   input rx_w_wr,
   `ifdef gem_fifo_8b_if
      input [7:0] rx_w_data,
   `else
      input [127:0] rx_w_data,
   `endif
   input [3:0] rx_w_mod,
   input rx_w_sop,
   input rx_w_eop,
   input rx_w_err,
   input rx_w_flush,
   input [44:0] rx_w_status,
   output rx_w_overflow,

   // Status toggles
   input dma_tx_end_tog,
   output dma_tx_status_tog

);



   // -----------------------------------------------------------------------
   //
   //                Internal Signals & Tie Off
   //
   // -----------------------------------------------------------------------


  `ifdef gem_fifo_8b_if
   // ----------------------
   // tx_r_fixed_lat monitor
   // ----------------------
   // The following code monitors the fixed-latency signals and confirms the
   // latency between tx_r_valid and the GMII TX output =~ 8 TX_CLK periods
   // --
   byte txd_q[$];             // Queue to mimic FIFO
   logic [7:0] tx_r_data_d8;  // FIFO data delayed 8 clocks
   logic [7:0] void_data;
   bit tx_r_fixed_lat_err;    // Indicates error in latency
   int txd_q_size;
   int fixed_lat_cnt;
   initial begin
      forever begin:txd_queue
         @(posedge tx_clk);
         // --
         // Push TX FIFO data into FIFO
         // --
         txd_q.push_front(tx_r_data);
         txd_q_size  = txd_q.size();
         // --
         // Don't let queue get too big
         // --
         if (txd_q_size > 20)
            void_data = txd_q.pop_back();
      end
   end
   initial begin
      tx_r_fixed_lat_err   = 0;
      fixed_lat_cnt        = 0;
      forever begin:txd_mon
         @(negedge tx_clk);
         if (tx_r_fixed_lat == 1'b1) begin
            // --
            // Confirm ethernet TXD output matches data from TX FIFO,
            // with fixed 8-cycle dlatency.
            // Only do comparison if we've had at least 8 cycles of
            // tx_r_fixed_lat being high!
            // --
            if (fixed_lat_cnt >=8) begin
               tx_r_data_d8 = txd_q[8];
               if (tx_enet_data != tx_r_data_d8) begin
                  tx_r_fixed_lat_err = 1;
               end else begin
                  tx_r_fixed_lat_err = 0;
               end
            end
            // --
            // Delay until we have tx_r_valid
            // --
            if (tx_r_valid == 1)
               fixed_lat_cnt +=1;
         end else begin
            // --
            // Reset the latency counter
            // --
            fixed_lat_cnt = 0;
         end
      end
   end
  `endif

   reg tx_r_sop_d;      // delayed version of TX SOP
   reg rx_valid_frame;


   // A queue to hold one frame
   `ifdef gem_fifo_8b_if
      typedef struct {
         logic [3:0] mod;
         logic [7:0] data [$];
      } T_FRAME;
   `else
      typedef struct {
         logic [3:0] mod;
         logic [127:0] data [$];
      } T_FRAME;
   `endif

   // A queue of frames
   T_FRAME frame_queue[$];
   // A single queue for the currently received frame. Once a full frame
   // has been received, this frame will be added to the queue.
   T_FRAME frame_rx;

   // Tie off unused outputs. We are only generating basic loopback here - i.e.
   // no underflows or anything like that.
   assign tx_r_err = 1'b0;
   assign tx_r_underflow = 1'b0;
   assign tx_r_flushed = 1'b0;
   assign tx_r_control = 1'b1;
   assign rx_w_overflow = 1'b0;

   assign dma_tx_status_tog = dma_tx_end_tog;


   // -----------------------------------------------------------------------
   //
   //                          Receive
   //
   // -----------------------------------------------------------------------


   initial begin
      rx_valid_frame = 0;
      forever begin
         @(posedge rx_clk);
         if (loopback) begin
            // Is the MAC doing a write.
            if (rx_w_wr) begin
               // --
               // Create a new queue at a sop and set valid fram bit
               // --
               if (rx_w_sop) begin
                  frame_rx.data.push_back(rx_w_data);
                  rx_valid_frame = 1;
               end
               // At an eop push the entire frame to the frame queue.
               else if (rx_w_eop) begin
                  frame_rx.data.push_back(rx_w_data);
                  frame_rx.mod = rx_w_mod;
                  frame_queue.push_back(frame_rx);
                  // Clear the current queue
                  while (frame_rx.data.size!=0)
                     void'(frame_rx.data.pop_front());
                  rx_valid_frame = 0;
               end else begin
                  // --
                  // Add data to the frame queue only if we have received SOP
                  // i.e. valid frame bit is set
                  // --
                  if (rx_valid_frame == 1'b1) begin
                     frame_rx.data.push_back(rx_w_data);
                  end
               end
            end
         end
      end
   end


   // -----------------------------------------------------------------------
   //
   //                         Transmit
   //
   // -----------------------------------------------------------------------



   bit new_frame; // Record if we are about to transmit a new frame
   initial begin

      new_frame = 1;

      // Defaults
      tx_r_data      = 128'd0;
      tx_r_mod       = 4'd0;
      tx_r_sop       = 1'b0;
      tx_r_sop_d     = 1'b0;
      tx_r_eop       = 1'b0;
      tx_r_data_rdy  = 1'b0;
      tx_r_valid     = 1'b0;
      forever begin

         @(posedge tx_clk);
         if (loopback) begin

            // The mac has accepted data
            if (tx_r_valid) begin

               // Have we just sent the last entry in the frame. If so
               // wipe the frame from the queue buffer
               if (tx_r_eop) begin
                  tx_r_data_rdy = 1'b0;
                  tx_r_eop = 1'b0;
                  frame_queue.delete(0);
                  new_frame = 1;
               end

               // The mac has accepted another word, so send the next word
               // to the mac.
               else begin
                  // Send the next data on to the bus
                  tx_r_data = frame_queue[0].data.pop_front();

                  // If we are at an eop then set the eop bit
                  if (frame_queue[0].data.size() == 0)
                     tx_r_eop = 1'b1;

               end

               // --
               // ensure at least 1 cycle wicth
               // pulse before removing SOP
               // --
               if (tx_r_sop_d == 1'b1)
                  tx_r_sop = 1'b0;

            end

            // If we have a new frame to transmit then set the sop
            if (new_frame==1 && frame_queue.size() != 0) begin
               tx_r_data = frame_queue[0].data.pop_front();
               tx_r_sop = 1'b1;
               `ifndef gem_fifo_8b_if
                  tx_r_mod = frame_queue[0].mod;
               `endif
               new_frame = 0;
            end

            // If we have frames to send in the queue then set rdy
            tx_r_data_rdy = frame_queue.size() == 0 ? 1'b0 : 1'b1;
            tx_r_valid = tx_r_rd && frame_queue.size() != 0;
            tx_r_sop_d = tx_r_sop;

         end
      end
   end



endmodule


