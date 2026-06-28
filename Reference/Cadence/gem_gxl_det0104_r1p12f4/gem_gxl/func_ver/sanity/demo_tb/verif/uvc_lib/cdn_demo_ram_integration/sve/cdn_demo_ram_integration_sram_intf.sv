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
// This file defines the address, data and control interface for the SRAM.
//----------------------------------------------------------------------------

interface cdn_demo_ram_integration_sram_intf #(parameter ADDR_WD=1, parameter DATA_WD=1) (input logic clk);

`ifdef GLS_SIM
  parameter DELAY = 50;
`else
  parameter DELAY = 0;
`endif

  logic [ADDR_WD-1:0] addr = {ADDR_WD{1'b0}};
  logic [DATA_WD-1:0] din  = {DATA_WD{1'b0}};
  logic               en   = 1'b0;
  logic               we   = 1'b0;
  logic [DATA_WD-1:0] dout;

  clocking cb @(posedge clk);
    output #DELAY addr;
    output #DELAY din;
    output #DELAY en;
    output #DELAY we;
    input         dout;
  endclocking
/*
  modport sram (input clk,
                clocking cb);
*/
  task write (input logic [ADDR_WD-1:0] waddr,
              input logic [DATA_WD-1:0] wdata);
  @(cb);
    cb.addr  <= waddr;
    cb.din   <= wdata;
    cb.en    <= 1'b1;
    cb.we    <= 1'b1;
  @(cb);
    cb.din   <= {DATA_WD{1'b0}};
    cb.en    <= 1'b0;
    cb.we    <= 1'b0;
  endtask

  task read (input logic [ADDR_WD-1:0] raddr, input integer num_clk);
  @(cb);
    cb.addr  <= raddr;
    cb.en    <= 1'b1;
    cb.we    <= 1'b0;
  @(cb);
    cb.en    <= 1'b0;
    for (int ii=1; ii <= num_clk; ii++) begin
      @(cb);
    end
  endtask

  task delay (input integer num_clk);
    for (int ii=1; ii <= num_clk; ii++) begin
      @(cb);
    end
  endtask

endinterface

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
