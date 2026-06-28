//------------------------------------------------------------------------------
//
//            CADENCE                    Copyright (c) 2015
//                                       Cadence Design Systems, Inc.
//                                       All rights reserved.
//
//  This work may not be copied, modified, re-published, uploaded, executed, or
//  distributed in any way, in any medium, whether in whole or in part, without
//  prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
// pragma cdn_vip_model -class cdn_apb

`ifndef CDN_APB_INTERFACE_SV
`define CDN_APB_INTERFACE_SV

`ifndef DENALI_SV_NO_TIMESCALE
   `timescale 1ps/1ps
`endif

`include "cdnApbMacros.sv"

interface cdn_apb_vip_if #(parameter NUM_OF_SLAVES=1,parameter ADDRESS_WIDTH=32,parameter DATA_WIDTH=32);

  // Need different interfaces types because PSUI VIP uses this interface to drive signals from VIP core.

  // signal: psel
  tri0  psel;
  // signal: clk
  logic clk;
  // signal: resetn
  logic resetn;
  // signal: paddr
  tri0 [31:0] paddr;
  // signal: penable
  tri0        penable;
  // signal: pwrite
  tri0        pwrite;
  // signal: pwdata
  tri0 [31:0] pwdata;
  // signal: pstrb
  logic [3:0] pstrb;
  // signal: pprot
  logic [2:0] pprot;
  // signal: pready
  // Holds the pready that the master receives from the slave after slave mux.
  logic       pready;
  // signal: prdata
  // Holds the prdata that the master receives from the slave after slave mux.
  logic [31:0] prdata;
  // signal: pslverr
  // Holds the slave error that the master receives from the slave after slave mux.
  logic        pslverr;


  reg [ADDRESS_WIDTH-1:0] den_paddr = '{default:'bz};
  reg                     den_penable = 'bz;
  reg                     den_pwrite = 'bz;
  reg [DATA_WIDTH-1:0]    den_pwdata = '{default:'bz};
  reg                     den_psel0 = 'bz;


  assign paddr = den_paddr;
  assign penable = den_penable;
  assign pwrite = den_pwrite;
  assign pwdata = den_pwdata;
  assign psel = den_psel0;

  function automatic string getPath();
    string getDutInterfacePath;
    int    length;
    $sformat(getDutInterfacePath,"%m");
    length = getDutInterfacePath.len() - 9;
    $sformat(getPath,"%s",getDutInterfacePath.substr(0,length));
  endfunction : getPath

endinterface // cdn_apb_vip_if

`endif

//------------------------------------------------------------------------------
// End of file
//------------------------------------------------------------------------------
