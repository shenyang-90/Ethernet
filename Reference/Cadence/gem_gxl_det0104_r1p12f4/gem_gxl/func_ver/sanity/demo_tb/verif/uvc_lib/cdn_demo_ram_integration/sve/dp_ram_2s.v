/******************************************************************
  * COPYRIGHT (c) 2000 Denali Software, Inc.  All rights reserved. *
 *  * -------------------------------------------------------------- *
 *  * This code is proprietary and confidential information of       *
 *  * Denali Software. It may not be reproduced, used or transmitted *
 *  * in any form whatsoever without the express and written         *
 *  * permission of Denali Software.                                 *
 *  ******************************************************************
 *  ******************************************************************
 *  *                                                                *
 *  *   Module: dp_ram_2s.v                                          *
 *  *                                                                *
 *  ******************************************************************/

/*---------------------------------------------------------------------------\
|  DESCRIPTION:                                                              |
|  dp_ram_2s: Parameterized Dual-port RAM model with 1 Read, 1 Write port    |
|                                                                            |
|  Use for simulation only                                                   |
|                                                                            |
\---------------------------------------------------------------------------*/

module dp_ram_2s # //cdnPcieTbDp2ClkRamModel #
  (parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 256,
   parameter WORD_COUNT = 256)
  (
   clock_wr,
   clock_rd,
   reset_wr_n,
   reset_rd_n,
   port0_write_data,
   port0_write_address,
   port0_write_enable,
   port1_read_data,
   port1_read_address,
   port1_read_enable
   );
   localparam INPUT_FLOPS = 1;// 1 - input flop 0-output flop
   input                   clock_wr;
   input                   clock_rd;
   input                   reset_wr_n;
   input                   reset_rd_n;
   input [DATA_WIDTH-1:0]  port0_write_data;
   input [ADDR_WIDTH-1:0]  port0_write_address;
   input                   port0_write_enable;

   output [DATA_WIDTH-1:0] port1_read_data;
   input  [ADDR_WIDTH-1:0] port1_read_address;
   input                   port1_read_enable;

   reg [DATA_WIDTH-1:0]    read_data;

  reg [DATA_WIDTH-1:0]     write_data_reg;
  reg [ADDR_WIDTH-1:0]     write_addr_reg;
  reg [ADDR_WIDTH-1:0]     read_addr_reg;
  reg                      write_enable_reg;
  reg                      read_enable_reg;
  reg [DATA_WIDTH-1:0]     read_data_reg;

  reg [DATA_WIDTH-1:0]     mem_array[WORD_COUNT-1:0];

  assign port1_read_data = read_data;
  generate
     if(INPUT_FLOPS == 1 )begin:input_flops
        always @(posedge clock_wr)
          if (!reset_wr_n)
            begin
               write_data_reg <= {DATA_WIDTH{1'b0}};
               write_addr_reg <= {ADDR_WIDTH{1'b0}};
               write_enable_reg <= 1'b0;

            end
          else
            begin
               write_data_reg <= port0_write_data;
               write_addr_reg <= port0_write_address;
               write_enable_reg <= port0_write_enable;

            end // else: !if(reset)
        always @(posedge clock_rd)
          if (!reset_rd_n)
            begin
               read_enable_reg <= 1'b0;
               read_addr_reg <= {ADDR_WIDTH{1'b0}};
            end
          else
            begin
               read_enable_reg <= port1_read_enable;
               read_addr_reg <= port1_read_address;
            end // else: !if(reset)
        always @(posedge clock_wr)
          if (write_enable_reg)
            mem_array[write_addr_reg] <= write_data_reg;


        always @(posedge clock_rd)
          if (read_enable_reg)
            read_data_reg <= mem_array[read_addr_reg];
          else
            read_data_reg <= {DATA_WIDTH{1'b0}};

        always @(*)begin
           read_data  = read_data_reg;
        end

     end // block: input_flops
     else begin:output_flops
        always @(posedge clock_wr)
          if (port0_write_enable)
            mem_array[port0_write_address] <= port0_write_data;


        always @(posedge clock_rd)
          if (port1_read_enable)
            read_data_reg <= mem_array[port1_read_address];
          else
            read_data_reg <= {DATA_WIDTH{1'b0}};

        always @(posedge clock_rd)
          read_data  <= read_data_reg;
     end
  endgenerate
 endmodule // dp_ram_2s
