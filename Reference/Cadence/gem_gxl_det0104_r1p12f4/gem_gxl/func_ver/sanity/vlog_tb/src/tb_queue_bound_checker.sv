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
//   Filename:           tb_queue_bound_checker.sv
//   Module Name:        tb_queue_bound_checker
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
//   Description    :
//
// The purpose of this module is to provide an assertion that verifies a
// a priority queue doesn't access an address beyond its address bounds. For
// example, each queue is allocated a number of segments and the queue should
// not access segments outside of its allocated range.
//
//-------------------------------------------------------------------------------


module tb_queue_bound_checker (input [2:0] edma_tx_pbuf_num_segments_q0,
                         input [2:0] edma_tx_pbuf_num_segments_q1,
                         input [2:0] edma_tx_pbuf_num_segments_q2,
                         input [2:0] edma_tx_pbuf_num_segments_q3,
                         input [2:0] edma_tx_pbuf_num_segments_q4,
                         input [2:0] edma_tx_pbuf_num_segments_q5,
                         input [2:0] edma_tx_pbuf_num_segments_q6,
                         input [2:0] edma_tx_pbuf_num_segments_q7,
                         input [2:0] edma_tx_pbuf_num_segments_q8,
                         input [2:0] edma_tx_pbuf_num_segments_q9,
                         input [2:0] edma_tx_pbuf_num_segments_q10,
                         input [2:0] edma_tx_pbuf_num_segments_q11,
                         input [2:0] edma_tx_pbuf_num_segments_q12,
                         input [2:0] edma_tx_pbuf_num_segments_q13,
                         input [2:0] edma_tx_pbuf_num_segments_q14,
                         input [2:0] edma_tx_pbuf_num_segments_q15
                         );

`ifdef dma_priority_queue1

   // -----------------------------------------------------------------------------
   //
   //                   Define the segment bounds
   //
   // -----------------------------------------------------------------------------



   // Constant array to store an array of the upper and lower segment
   // bounds.

   typedef struct {byte upper, lower;} T_QUEUE_BOUND;
   T_QUEUE_BOUND queue_bounds [`edma_queues-1:0];

   always @(*) begin

      byte i;
      for (i=0; i<=`edma_queues; i++)

         if (i==0) begin
            queue_bounds[i].lower = 0;
            begin
              queue_bounds[i].upper = 0;
              queue_bounds[i].upper = (2**edma_tx_pbuf_num_segments_q0)-1;
            end
         end
         else if (i==1) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q1)-1;
            end
         end
         else if (i==2) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            queue_bounds[i].upper = queue_bounds[i].lower;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q2)-1;
            end
         end
         else if (i==3) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q3)-1;
            end
         end
         else if (i==4) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q4)-1;
            end
         end
         else if (i==5) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q5)-1;
            end
         end
         else if (i==6) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q6)-1;
            end
         end
         else if (i==7) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q7)-1;
            end
         end
         else if (i==8) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q8)-1;
            end
         end
         else if (i==9) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q9)-1;
            end
         end
         else if (i==10) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q10)-1;
            end
         end
         else if (i==11) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q11)-1;
            end
         end
         else if (i==12) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q12)-1;
            end
         end
         else if (i==13) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q13)-1;
            end
         end
         else if (i==14) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            begin
              queue_bounds[i].upper = queue_bounds[i].lower;
              queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q14)-1;
            end
         end
         else if (i==15) begin
            queue_bounds[i].lower = queue_bounds[i-1].upper+1;
            queue_bounds[i].upper = queue_bounds[i].lower;
            queue_bounds[i].upper += (2**edma_tx_pbuf_num_segments_q15)-1;
          end
   end



   // -----------------------------------------------------------------------------
   //
   //     Check that a queue is not accessing an incorrect memory location
   //
   // -----------------------------------------------------------------------------



   // Simple function to check that a queue is not accessing an address outside
   // of its range

   function check_queue_bound(logic [3:0] queue,
                        logic [`edma_tx_pbuf_addr:0] address,
                        string error_module);

      check_queue_bound = 1'b0;
      if (!(address[`edma_tx_pbuf_addr-1:`edma_tx_pbuf_addr-`edma_tx_pbuf_queue_segment_size]
            inside {[queue_bounds[queue].lower:queue_bounds[queue].upper]})) begin
         $display("**** Error : Queue %0d accessed an address outwith its segment bounds.", queue);
         $display("             Expected Range : [0x%0x:0x%0x].Got : 0x%0x.",
               {queue_bounds[queue].lower,{`edma_tx_pbuf_addr-`edma_tx_pbuf_queue_segment_size{1'b0}}},
               {queue_bounds[queue].upper,{`edma_tx_pbuf_addr-`edma_tx_pbuf_queue_segment_size{1'b1}}},
               address);
         $display("             Module %s.", error_module);
         check_queue_bound = 1'b1;

      end


   endfunction

wire [3:0] cur_queue;
`ifdef edma_axi
  assign cur_queue = `hier_pbuf_tx_wr.cur_descr_rd_queue;
`else
  assign cur_queue = `hier_pbuf_tx_wr.queue_ptr_dph;
`endif

   // Check the tx_wr and tx_rd modules
   bit trigger_assertion;
   initial begin

      fork

         forever begin
            @(posedge `hier_pbuf_tx_wr.hclk);
            if (`hier_pbuf_tx_wr.tx_ena)
            trigger_assertion = check_queue_bound(cur_queue,
                           `hier_pbuf_tx_wr.tx_addra,
                           "edma_pbuf_tx_wr");

            AP_QUEUE_BOUND_CHECKER : assert ( trigger_assertion == 1'b0 );
            if (trigger_assertion)
            begin
              @(posedge `hier_pbuf_tx_wr.hclk);
              $finish();
            end
         end

/*
         forever begin
            @(posedge `hier_pbuf_tx_rd.tx_r_clk);
            if (`hier_pbuf_tx_rd.tx_enb)
            check_queue_bound(`hier_pbuf_tx_rd.queue_dma,
                           `hier_pbuf_tx_rd.tx_addrb,
                           "edma_pbuf_tx_rd");
         end
*/
      join

   end

`endif

endmodule

