//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : bsidelko@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// sp_ram_2s: Parameterized Single-port RAM model (2STAGE)
// Use for simulation only
//----------------------------------------------------------------------------

module sp_ram_2s #
  (parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 256,
   parameter WORD_COUNT = 256)
  (
   clock,
   reset_n,
   write_data,
   address,
   write_enable,
   read_data,
   read_enable
   );
   localparam INPUT_FLOPS = 1;// 1 - input flop 0-output flop
   input                   clock;
   input                   reset_n;
   input [DATA_WIDTH-1:0]  write_data;
   input [ADDR_WIDTH-1:0]  address;
   input                   write_enable;

   output [DATA_WIDTH-1:0] read_data;
   input                   read_enable;

   reg [DATA_WIDTH-1:0]    read_data_r;

  reg [DATA_WIDTH-1:0]     write_data_reg;
  reg [ADDR_WIDTH-1:0]     write_addr_reg;
  reg [ADDR_WIDTH-1:0]     read_addr_reg;
  reg                      write_enable_reg;
  reg                      read_enable_reg;
  reg [DATA_WIDTH-1:0]     read_data_reg;

  reg [DATA_WIDTH-1:0]     mem_array[WORD_COUNT-1:0];

  assign read_data = read_data_r;
  generate
     if(INPUT_FLOPS == 1 )begin:input_flops
        always @(posedge clock)
          if (!reset_n)
            begin
               write_data_reg <= {DATA_WIDTH{1'b0}};
               write_addr_reg <= {ADDR_WIDTH{1'b0}};
               write_enable_reg <= 1'b0;

            end
          else
            begin
               write_data_reg <= write_data;
               write_addr_reg <= address;
               write_enable_reg <= write_enable;

            end // else: !if(reset)
        always @(posedge clock)
          if (!reset_n)
            begin
               read_enable_reg <= 1'b0;
               read_addr_reg <= {ADDR_WIDTH{1'b0}};
            end
          else
            begin
               read_enable_reg <= read_enable;
               read_addr_reg <= address;
            end // else: !if(reset)
        always @(posedge clock)
          if (write_enable_reg)
            mem_array[write_addr_reg] <= write_data_reg;


        always @(posedge clock)
          if (read_enable_reg)
            read_data_reg <= mem_array[read_addr_reg];
          else
            read_data_reg <= {DATA_WIDTH{1'b0}};

        always @(*)begin
           read_data_r  = read_data_reg;
        end

     end // block: input_flops
     else begin:output_flops
        always @(posedge clock)
          if (write_enable)
            mem_array[address] <= write_data;


        always @(posedge clock)
          if (read_enable)
            read_data_reg <= mem_array[address];
          else
            read_data_reg <= {DATA_WIDTH{1'b0}};

        always @(posedge clock)
          read_data_r  <= read_data_reg;
     end
  endgenerate
 endmodule // sp_ram_2s
