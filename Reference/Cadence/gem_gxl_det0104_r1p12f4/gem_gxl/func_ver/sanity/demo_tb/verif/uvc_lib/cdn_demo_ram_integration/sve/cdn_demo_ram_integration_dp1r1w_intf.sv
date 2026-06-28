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
// This file defines the address, data and control interface for the DP1R1W.
//----------------------------------------------------------------------------

interface cdn_demo_ram_integration_dp1r1w_intf #(parameter ADDR_WD=1, parameter DATA_WD=1) (input logic clka, clkb);

`ifdef GLS_SIM
  parameter DELAY = 50;
`else
  parameter DELAY = 0;
`endif

  logic [ADDR_WD-1:0] addra = {ADDR_WD{1'b0}};
  logic [ADDR_WD-1:0] addrb = {ADDR_WD{1'b0}};
  logic [DATA_WD-1:0] dina  = {DATA_WD{1'b0}};
  logic               ena   = 1'b0;
  logic               enb   = 1'b0;
  logic               wea   = 1'b0;
  logic [DATA_WD-1:0] doutb;

  clocking cba @(posedge clka);
    output #DELAY addra;
    output #DELAY dina;
    output #DELAY ena;
    output #DELAY wea;
  endclocking

  clocking cbb @(posedge clkb);
    output #DELAY addrb;
    output #DELAY enb;
    input         doutb;
  endclocking
/*
  modport dp1r1wa (input clka,
                  clocking cba);

  modport dp1r1wb (input clkb,
                  clocking cbb);
*/
  task write (input logic [ADDR_WD-1:0] waddr,
              input logic [DATA_WD-1:0] wdata);
  @(cba);
    cba.addra  <= waddr;
    cba.dina   <= wdata;
    cba.ena    <= 1'b1;
    cba.wea    <= 1'b1;
  @(cba)
    cba.dina   <= {DATA_WD{1'b0}};
    cba.ena    <= 1'b0;
    cba.wea    <= 1'b0;
  endtask

  task read (input logic [ADDR_WD-1:0] raddr, input integer num_clk);
  @(cbb);
    cbb.addrb  <= raddr;
    cbb.enb    <= 1'b1;
  @(cbb);
    cbb.enb    <= 1'b0;
    for (int ii=1; ii <= num_clk; ii++) begin
      @(cbb);
    end
  endtask

  task delay (input integer num_clk);
    for (int ii=1; ii <= num_clk; ii++) begin
      @(cbb);
    end
  endtask

endinterface

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
