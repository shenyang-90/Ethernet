//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
//
// The purpose of this file is to provide an example top level dut file that
// instantiates the cdn_demo_ram_integration_stub_bfm. This is again only
// an example and the purpose is to highlight to a protocol integrator how
// to hook up the cdn_demo_ram_integration_stub_bfm. This example has a "DUT"
// with four functional ports - SRAM, DP1R1W, APB and AXI. The AXI port is unused
// in the design and the outputs are therefore tied low. The SRAM, DP1R1W and APB ports
// are connected accordingly. When a protocol specific version is used instead
// the module name should be the same as the actual DUT top level to allow
// seamless switching (no ifdefs, parameters, etc) between normal and RAM
// integration testing.
//----------------------------------------------------------------------------

module cdn_demo_top #(

   // Inputs to MASTER APB Bank
   parameter NUM_SRAM             = 4,
   parameter NUM_DP1R1W           = 4,
   parameter NUM_DP2R2W           = 0,
   parameter NUM_RF               = 0,
   parameter NUM_SRAM_BE          = 2,
   parameter NUM_DP1R1W_BE        = 0,
   parameter NUM_DP2R2W_BE        = 0,
   parameter NUM_RF_BE            = 0,

   // Ram parameters
   parameter SRAM0_READ_DELAY     = 0,
   parameter SRAM1_READ_DELAY     = 0,
   parameter SRAM2_READ_DELAY     = 0,
   parameter SRAM3_READ_DELAY     = 0,
   parameter SRAM0_ADDR_WD        = 1,
   parameter SRAM1_ADDR_WD        = 1,
   parameter SRAM2_ADDR_WD        = 1,
   parameter SRAM3_ADDR_WD        = 1,
   parameter SRAM0_DEPTH          = 1,
   parameter SRAM1_DEPTH          = 1,
   parameter SRAM2_DEPTH          = 1,
   parameter SRAM3_DEPTH          = 1,
   parameter SRAM0_DATA_WD        = 1,
   parameter SRAM1_DATA_WD        = 1,
   parameter SRAM2_DATA_WD        = 1,
   parameter SRAM3_DATA_WD        = 1,
   parameter SRAM0_HOLDDATA       = 0,
   parameter SRAM1_HOLDDATA       = 0,

   parameter DP1R1W0_READ_DELAY   = 0,
   parameter DP1R1W1_READ_DELAY   = 0,
   parameter DP1R1W2_READ_DELAY   = 0,
   parameter DP1R1W3_READ_DELAY   = 0,
   parameter DP1R1W0_ADDR_WD      = 1,
   parameter DP1R1W1_ADDR_WD      = 1,
   parameter DP1R1W2_ADDR_WD      = 1,
   parameter DP1R1W3_ADDR_WD      = 1,
   parameter DP1R1W0_DEPTH        = 1,
   parameter DP1R1W1_DEPTH        = 1,
   parameter DP1R1W2_DEPTH        = 1,
   parameter DP1R1W3_DEPTH        = 1,
   parameter DP1R1W0_DATA_WD      = 1,
   parameter DP1R1W1_DATA_WD      = 1,
   parameter DP1R1W2_DATA_WD      = 1,
   parameter DP1R1W3_DATA_WD      = 1,
   parameter DP1R1W0_HOLDDATA     = 0,
   parameter DP1R1W1_HOLDDATA     = 0,

   parameter SRAM_BE_0_READ_DELAY = 0,
   parameter SRAM_BE_1_READ_DELAY = 0,
   parameter SRAM_BE_0_ADDR_WD    = 1,
   parameter SRAM_BE_1_ADDR_WD    = 1,
   parameter SRAM_BE_0_DEPTH      = 1,
   parameter SRAM_BE_1_DEPTH      = 1,
   parameter SRAM_BE_0_DATA_WD    = 1,
   parameter SRAM_BE_1_DATA_WD    = 1

) (

   // APB bank
   pclk,
   presetn,
   paddr,
   pready,
   pwdata,
   prdata,
   pwrite,
   penable,
   psel,
   pstrb,
   pslverr,
   pprot,

   interrupt,

   // SRAM x 4 Interface
   //sram0
   sram0_clk,
   sram0_addr,
   sram0_din,
   sram0_en,
   sram0_we,
   sram0_dout,
   //sram1
   sram1_clk,
   sram1_addr,
   sram1_din,
   sram1_en,
   sram1_we,
   sram1_dout,
   //sram2_2s_0
   sram2_clk,
   sram2_addr,
   sram2_din,
   sram2_en,
   sram2_we,
   sram2_dout,
   //sram3_2s_1
   sram3_clk,
   sram3_addr,
   sram3_din,
   sram3_en,
   sram3_we,
   sram3_dout,

   // DP1R1W x 4 Interface
   //dp1r1w0
   dp1r1w0_clka,
   dp1r1w0_clkb,
   dp1r1w0_addra,
   dp1r1w0_addrb,
   dp1r1w0_dina,
   dp1r1w0_doutb,
   dp1r1w0_ena,
   dp1r1w0_enb,
   dp1r1w0_wea,
   //dp1r1w1
   dp1r1w1_clka,
   dp1r1w1_clkb,
   dp1r1w1_addra,
   dp1r1w1_addrb,
   dp1r1w1_dina,
   dp1r1w1_doutb,
   dp1r1w1_ena,
   dp1r1w1_enb,
   dp1r1w1_wea,
   //dp1r1w2_2s_0
   dp1r1w2_clka,
   dp1r1w2_clkb,
   dp1r1w2_addra,
   dp1r1w2_addrb,
   dp1r1w2_dina,
   dp1r1w2_doutb,
   dp1r1w2_ena,
   dp1r1w2_enb,
   dp1r1w2_wea,
   //dp1r1w3_2s_1
   dp1r1w3_clka,
   dp1r1w3_clkb,
   dp1r1w3_addra,
   dp1r1w3_addrb,
   dp1r1w3_dina,
   dp1r1w3_doutb,
   dp1r1w3_ena,
   dp1r1w3_enb,
   dp1r1w3_wea,

   // SRAM_BE x 2 Interface
   //sram_be_0
   sram_be_0_clk,
   sram_be_0_addr,
   sram_be_0_din,
   sram_be_0_ben,
   sram_be_0_en,
   sram_be_0_we,
   sram_be_0_dout,
   //sram_be_1
   sram_be_1_clk,
   sram_be_1_addr,
   sram_be_1_din,
   sram_be_1_ben,
   sram_be_1_en,
   sram_be_1_we,
   sram_be_1_dout,

   // ---- AXI ----

   // AXI AW channel signals (Write address channel)
   awuser,
   awid,
   awaddr,
   awlen,
   awsize,
   awburst,
   awlock,
   awcache,
   awprot,
   awqos,
   awregion,
   awvalid,
   awready,

   // AXI W  channel signals (Write data channel)
   wuser,
   wdata,
   wstrb,
   wlast,
   wvalid,
   wready,
    // AXI B  channel signals (Write response channel)
   buser,
   bresp,
   bvalid,
   bready,

    // AXI AR channel signals (Read address channel)
   arid,
   araddr,
   arlen,
   arsize,
   arburst,
   arlock,
   arcache,
   arprot,
   arqos,
   arregion,
   arvalid,
   arready,

    // AXI R  channel signals (Read data channel)
   rid,
   rdata,
   rresp,
   rlast,
   rvalid,
   rready

);

   //--------------------------------------------------------------------
   //                     P A R A M E T E R S
   //--------------------------------------------------------------------

   `include "cdn_demo_params.sv"

   //--------------------------------------------------------------------
   //             INTERFACE DESCRIPTION
   //--------------------------------------------------------------------

   // APB bank
   input pclk;
   input presetn;
   input [APB_PADDR_WD-1:0] paddr;
   output reg pready;
   input [31:0] pwdata;
   output [31:0] prdata;
   input pwrite;
   input penable;
   input psel;
   input [3:0] pstrb;
   output pslverr;
   input [APB_PPROT_WD-1:0] pprot;

   output interrupt;

   // SRAM x 4 Interface
   //sram0
   input                      sram0_clk;
   output [SRAM0_ADDR_WD-1:0] sram0_addr;
   output [SRAM0_DATA_WD-1:0] sram0_din;
   output                     sram0_en;
   output                     sram0_we;
   input  [SRAM0_DATA_WD-1:0] sram0_dout;
   //sram1
   input                      sram1_clk;
   output [SRAM1_ADDR_WD-1:0] sram1_addr;
   output [SRAM1_DATA_WD-1:0] sram1_din;
   output                     sram1_en;
   output                     sram1_we;
   input  [SRAM1_DATA_WD-1:0] sram1_dout;
   //sram2_2s_0
   input                      sram2_clk;
   output [SRAM2_ADDR_WD-1:0] sram2_addr;
   output [SRAM2_DATA_WD-1:0] sram2_din;
   output                     sram2_en;
   output                     sram2_we;
   input  [SRAM2_DATA_WD-1:0] sram2_dout;
   //sram3_2s_1
   input                      sram3_clk;
   output [SRAM3_ADDR_WD-1:0] sram3_addr;
   output [SRAM3_DATA_WD-1:0] sram3_din;
   output                     sram3_en;
   output                     sram3_we;
   input  [SRAM3_DATA_WD-1:0] sram3_dout;

   // DP1R1W x 4 Interface
   //dp1r1w0
   input                        dp1r1w0_clka;
   input                        dp1r1w0_clkb;
   output [DP1R1W0_ADDR_WD-1:0] dp1r1w0_addra;
   output [DP1R1W0_ADDR_WD-1:0] dp1r1w0_addrb;
   output [DP1R1W0_DATA_WD-1:0] dp1r1w0_dina;
   input  [DP1R1W0_DATA_WD-1:0] dp1r1w0_doutb;
   output                       dp1r1w0_ena;
   output                       dp1r1w0_enb;
   output                       dp1r1w0_wea;
   //dp1r1w1
   input                        dp1r1w1_clka;
   input                        dp1r1w1_clkb;
   output [DP1R1W1_ADDR_WD-1:0] dp1r1w1_addra;
   output [DP1R1W1_ADDR_WD-1:0] dp1r1w1_addrb;
   output [DP1R1W1_DATA_WD-1:0] dp1r1w1_dina;
   input  [DP1R1W1_DATA_WD-1:0] dp1r1w1_doutb;
   output                       dp1r1w1_ena;
   output                       dp1r1w1_enb;
   output                       dp1r1w1_wea;
   //dp1r1w2_2s_0
   input                        dp1r1w2_clka;
   input                        dp1r1w2_clkb;
   output [DP1R1W2_ADDR_WD-1:0] dp1r1w2_addra;
   output [DP1R1W2_ADDR_WD-1:0] dp1r1w2_addrb;
   output [DP1R1W2_DATA_WD-1:0] dp1r1w2_dina;
   input  [DP1R1W2_DATA_WD-1:0] dp1r1w2_doutb;
   output                       dp1r1w2_ena;
   output                       dp1r1w2_enb;
   output                       dp1r1w2_wea;
   //dp1r1w3_2s_1
   input                        dp1r1w3_clka;
   input                        dp1r1w3_clkb;
   output [DP1R1W3_ADDR_WD-1:0] dp1r1w3_addra;
   output [DP1R1W3_ADDR_WD-1:0] dp1r1w3_addrb;
   output [DP1R1W3_DATA_WD-1:0] dp1r1w3_dina;
   input  [DP1R1W3_DATA_WD-1:0] dp1r1w3_doutb;
   output                       dp1r1w3_ena;
   output                       dp1r1w3_enb;
   output                       dp1r1w3_wea;

   // SRAM_BE x 2 Interface
   //sram_be_0
   input                            sram_be_0_clk;
   output [SRAM_BE_0_ADDR_WD-1  :0] sram_be_0_addr;
   output [SRAM_BE_0_DATA_WD-1  :0] sram_be_0_din;
   output [SRAM_BE_0_DATA_WD/8-1:0] sram_be_0_ben;
   output                           sram_be_0_en;
   output                           sram_be_0_we;
   input  [SRAM_BE_0_DATA_WD-1  :0] sram_be_0_dout;
   //sram_be_1
   input                            sram_be_1_clk;
   output [SRAM_BE_1_ADDR_WD-1  :0] sram_be_1_addr;
   output [SRAM_BE_1_DATA_WD-1  :0] sram_be_1_din;
   output [SRAM_BE_1_DATA_WD/8-1:0] sram_be_1_ben;
   output                           sram_be_1_en;
   output                           sram_be_1_we;
   input  [SRAM_BE_1_DATA_WD-1  :0] sram_be_1_dout;

   // ---- AXI ----

   // AXI AW channel signals (Write address channel)
   output [AXI_USER_WD-1:0] awuser;
   output [AXI_ID_WD-1:0] awid;
   output [AXI_ADDR_WD-1:0] awaddr;
   output [AXI_LEN_WD-1:0] awlen;
   output [AXI_SIZE_WD-1:0] awsize;
   output [AXI_BURST_WD-1:0] awburst;
   output [AXI_LOCK_WD-1:0] awlock;
   output [AXI_CACHE_WD-1:0] awcache;
   output [AXI_PROT_WD-1:0] awprot;
   output [AXI_QOS_WD-1:0] awqos;
   output [AXI_REGION_WD-1:0] awregion;
   output awvalid;
   input awready;

   // AXI W  channel signals (Write data channel)
   output [AXI_USER_WD-1:0] wuser;
   output [AXI_DATA_WD-1:0] wdata;
   output [AXI_STRB_WD-1:0] wstrb;
   output wlast;
   output wvalid;
   input wready;
    // AXI B  channel signals (Write response channel)
   input [AXI_USER_WD-1:0] buser;
   input [AXI_RESP_WD-1:0] bresp;
   input bvalid;
   output bready;

    // AXI AR channel signals (Read address channel)
   output [AXI_ID_WD-1:0] arid;
   output [AXI_ADDR_WD-1:0] araddr;
   output [AXI_LEN_WD-1:0] arlen;
   output [AXI_SIZE_WD-1:0] arsize;
   output [AXI_BURST_WD-1:0] arburst;
   output [AXI_LOCK_WD-1:0] arlock;
   output [AXI_CACHE_WD-1:0] arcache;
   output [AXI_PROT_WD-1:0] arprot;
   output [AXI_QOS_WD-1:0] arqos;
   output [AXI_REGION_WD-1:0] arregion;
   output arvalid;
   input arready;

    // AXI R  channel signals (Read data channel)
   input [AXI_ID_WD-1:0] rid;
   input [AXI_DATA_WD-1:0] rdata;
   input [AXI_RESP_WD-1:0] rresp;
   input rlast;
   input rvalid;
   output rready;


   // Tie off the unused AXI I/F
   assign araddr = {AXI_ADDR_WD{1'b0}};
   assign arburst = {AXI_BURST_WD{1'b0}};
   assign arcache = {AXI_CACHE_WD{1'b0}};
   assign aresetn = 1'b0;
   assign arid = {AXI_ID_WD{1'b0}};
   assign arlen = {AXI_LEN_WD{1'b0}};
   assign arlock = 1'b0;
   assign arprot = {AXI_PROT_WD{1'b0}};
   assign arqos = {AXI_QOS_WD{1'b0}};
   assign arregion = {AXI_REGION_WD{1'b0}};
   assign arsize = {AXI_SIZE_WD{1'b0}};
   assign aruser = {AXI_USER_WD{1'b0}};
   assign arvalid = 1'b0;
   assign awaddr = {AXI_ADDR_WD{1'b0}};
   assign awburst = {AXI_BURST_WD{1'b0}};
   assign awcache = {AXI_CACHE_WD{1'b0}};
   assign awid = {AXI_ID_WD{1'b0}};
   assign awlen = {AXI_LEN_WD{1'b0}};
   assign awlock = 1'b0;
   assign awprot = {AXI_PROT_WD{1'b0}};
   assign awqos = {AXI_QOS_WD{1'b0}};
   assign awregion = {AXI_REGION_WD{1'b0}};
   assign awsize = {AXI_SIZE_WD{1'b0}};
   assign awuser = {AXI_USER_WD{1'b0}};
   assign awvalid = 1'b0;
   assign bready = 1'b0;
   assign rready = 1'b0;
   assign wdata = {AXI_DATA_WD{1'b0}};
   assign wlast = 1'b0;
   assign wstrb = {AXI_STRB_WD{1'b0}};
   assign wuser = {AXI_USER_WD{1'b0}};
   assign wvalid = 1'b0;

   //--------------------------------------
   // STUB BFM
   //--------------------------------------
   cdn_demo_ram_integration_stub_bfm
   #(
     .APB_PADDR_WD (13),
     .APB_PPROT_WD (3),

     // Inputs to MASTER APB Bank
     .NUM_SRAM              (NUM_SRAM),
     .NUM_DP1R1W            (NUM_DP1R1W),
     .NUM_DP2R2W            (NUM_DP2R2W),
     .NUM_RF                (NUM_RF),
     .NUM_SRAM_BE           (NUM_SRAM_BE),
     .NUM_DP1R1W_BE         (NUM_DP1R1W_BE),
     .NUM_DP2R2W_BE         (NUM_DP2R2W_BE),
     .NUM_RF_BE             (NUM_RF_BE),

     // Ram parameters
     .SRAM0_READ_DELAY      (SRAM0_READ_DELAY),
     .SRAM1_READ_DELAY      (SRAM1_READ_DELAY),
     .SRAM2_READ_DELAY      (SRAM2_READ_DELAY),
     .SRAM3_READ_DELAY      (SRAM3_READ_DELAY),
     .SRAM0_ADDR_WD         (SRAM0_ADDR_WD),
     .SRAM1_ADDR_WD         (SRAM1_ADDR_WD),
     .SRAM2_ADDR_WD         (SRAM2_ADDR_WD),
     .SRAM3_ADDR_WD         (SRAM3_ADDR_WD),
     .SRAM0_DEPTH           (SRAM0_DEPTH),
     .SRAM1_DEPTH           (SRAM1_DEPTH),
     .SRAM2_DEPTH           (SRAM2_DEPTH),
     .SRAM3_DEPTH           (SRAM3_DEPTH),
     .SRAM0_DATA_WD         (SRAM0_DATA_WD),
     .SRAM1_DATA_WD         (SRAM1_DATA_WD),
     .SRAM2_DATA_WD         (SRAM2_DATA_WD),
     .SRAM3_DATA_WD         (SRAM3_DATA_WD),
     .SRAM0_HOLDDATA        (SRAM0_HOLDDATA),
     .SRAM1_HOLDDATA        (SRAM1_HOLDDATA),

     .DP1R1W0_READ_DELAY    (DP1R1W0_READ_DELAY),
     .DP1R1W1_READ_DELAY    (DP1R1W1_READ_DELAY),
     .DP1R1W2_READ_DELAY    (DP1R1W2_READ_DELAY),
     .DP1R1W3_READ_DELAY    (DP1R1W3_READ_DELAY),
     .DP1R1W0_ADDR_WD       (DP1R1W0_ADDR_WD),
     .DP1R1W1_ADDR_WD       (DP1R1W1_ADDR_WD),
     .DP1R1W2_ADDR_WD       (DP1R1W2_ADDR_WD),
     .DP1R1W3_ADDR_WD       (DP1R1W3_ADDR_WD),
     .DP1R1W0_DEPTH         (DP1R1W0_DEPTH),
     .DP1R1W1_DEPTH         (DP1R1W1_DEPTH),
     .DP1R1W2_DEPTH         (DP1R1W2_DEPTH),
     .DP1R1W3_DEPTH         (DP1R1W3_DEPTH),
     .DP1R1W0_DATA_WD       (DP1R1W0_DATA_WD),
     .DP1R1W1_DATA_WD       (DP1R1W1_DATA_WD),
     .DP1R1W2_DATA_WD       (DP1R1W2_DATA_WD),
     .DP1R1W3_DATA_WD       (DP1R1W3_DATA_WD),
     .DP1R1W0_HOLDDATA      (DP1R1W0_HOLDDATA),
     .DP1R1W1_HOLDDATA      (DP1R1W1_HOLDDATA),

     .SRAM_BE_0_READ_DELAY  (SRAM_BE_0_READ_DELAY),
     .SRAM_BE_1_READ_DELAY  (SRAM_BE_1_READ_DELAY),
     .SRAM_BE_0_ADDR_WD     (SRAM_BE_0_ADDR_WD),
     .SRAM_BE_1_ADDR_WD     (SRAM_BE_1_ADDR_WD),
     .SRAM_BE_0_DEPTH       (SRAM_BE_0_DEPTH),
     .SRAM_BE_1_DEPTH       (SRAM_BE_1_DEPTH),
     .SRAM_BE_0_DATA_WD     (SRAM_BE_0_DATA_WD),
     .SRAM_BE_1_DATA_WD     (SRAM_BE_1_DATA_WD)

   )
   u_cdn_demo_ram_integration_stub_bfm (
     .pclk             (pclk),
     .presetn          (presetn),
     .paddr            (paddr[12:0]),
     .pprot            (3'd0),
     .psel             (psel),
     .penable          (penable),
     .pwrite           (pwrite),
     .pwdata           (pwdata),
     .pstrb            (4'hf),
     .pready           (pready),
     .prdata           (prdata),
     .pslverr          (pslverr),

     .interrupt        (interrupt),

     //------------------------------------
     // SRAM
     //------------------------------------
     //sram0
     .sram0_clk          (sram0_clk),
     .sram0_addr         (sram0_addr),
     .sram0_din          (sram0_din),
     .sram0_en           (sram0_en),
     .sram0_we           (sram0_we),
     .sram0_dout         (sram0_dout),
     //sram1
     .sram1_clk          (sram1_clk),
     .sram1_addr         (sram1_addr),
     .sram1_din          (sram1_din),
     .sram1_en           (sram1_en),
     .sram1_we           (sram1_we),
     .sram1_dout         (sram1_dout),
     //sram2
     .sram2_clk          (sram2_clk),
     .sram2_addr         (sram2_addr),
     .sram2_din          (sram2_din),
     .sram2_en           (sram2_en),
     .sram2_we           (sram2_we),
     .sram2_dout         (sram2_dout),
     //sram3
     .sram3_clk          (sram3_clk),
     .sram3_addr         (sram3_addr),
     .sram3_din          (sram3_din),
     .sram3_en           (sram3_en),
     .sram3_we           (sram3_we),
     .sram3_dout         (sram3_dout),
     //sram4
     .sram4_clk          (1'b0),
     .sram4_addr         (),
     .sram4_din          (),
     .sram4_en           (),
     .sram4_we           (),
     .sram4_dout         (1'b0),
     //sram5
     .sram5_clk          (1'b0),
     .sram5_addr         (),
     .sram5_din          (),
     .sram5_en           (),
     .sram5_we           (),
     .sram5_dout         (1'b0),
     //sram6
     .sram6_clk          (1'b0),
     .sram6_addr         (),
     .sram6_din          (),
     .sram6_en           (),
     .sram6_we           (),
     .sram6_dout         (1'b0),
     //sram7
     .sram7_clk          (1'b0),
     .sram7_addr         (),
     .sram7_din          (),
     .sram7_en           (),
     .sram7_we           (),
     .sram7_dout         (1'b0),
     //sram8
     .sram8_clk          (1'b0),
     .sram8_addr         (),
     .sram8_din          (),
     .sram8_en           (),
     .sram8_we           (),
     .sram8_dout         (1'b0),
     //sram9
     .sram9_clk          (1'b0),
     .sram9_addr         (),
     .sram9_din          (),
     .sram9_en           (),
     .sram9_we           (),
     .sram9_dout         (1'b0),
     //sram10
     .sram10_clk         (1'b0),
     .sram10_addr        (),
     .sram10_din         (),
     .sram10_en          (),
     .sram10_we          (),
     .sram10_dout        (1'b0),
     //sram11
     .sram11_clk         (1'b0),
     .sram11_addr        (),
     .sram11_din         (),
     .sram11_en          (),
     .sram11_we          (),
     .sram11_dout        (1'b0),
     //sram12
     .sram12_clk         (1'b0),
     .sram12_addr        (),
     .sram12_din         (),
     .sram12_en          (),
     .sram12_we          (),
     .sram12_dout        (1'b0),
     //sram13
     .sram13_clk         (1'b0),
     .sram13_addr        (),
     .sram13_din         (),
     .sram13_en          (),
     .sram13_we          (),
     .sram13_dout        (1'b0),
     //sram14
     .sram14_clk         (1'b0),
     .sram14_addr        (),
     .sram14_din         (),
     .sram14_en          (),
     .sram14_we          (),
     .sram14_dout        (1'b0),
     //sram15
     .sram15_clk         (1'b0),
     .sram15_addr        (),
     .sram15_din         (),
     .sram15_en          (),
     .sram15_we          (),
     .sram15_dout        (1'b0),
     //sram16
     .sram16_clk         (1'b0),
     .sram16_addr        (),
     .sram16_din         (),
     .sram16_en          (),
     .sram16_we          (),
     .sram16_dout        (1'b0),
     //sram17
     .sram17_clk         (1'b0),
     .sram17_addr        (),
     .sram17_din         (),
     .sram17_en          (),
     .sram17_we          (),
     .sram17_dout        (1'b0),
     //sram18
     .sram18_clk         (1'b0),
     .sram18_addr        (),
     .sram18_din         (),
     .sram18_en          (),
     .sram18_we          (),
     .sram18_dout        (1'b0),
     //sram19
     .sram19_clk         (1'b0),
     .sram19_addr        (),
     .sram19_din         (),
     .sram19_en          (),
     .sram19_we          (),
     .sram19_dout        (1'b0),
     //sram20
     .sram20_clk         (1'b0),
     .sram20_addr        (),
     .sram20_din         (),
     .sram20_en          (),
     .sram20_we          (),
     .sram20_dout        (1'b0),
     //sram21
     .sram21_clk         (1'b0),
     .sram21_addr        (),
     .sram21_din         (),
     .sram21_en          (),
     .sram21_we          (),
     .sram21_dout        (1'b0),
     //sram22
     .sram22_clk         (1'b0),
     .sram22_addr        (),
     .sram22_din         (),
     .sram22_en          (),
     .sram22_we          (),
     .sram22_dout        (1'b0),
     //sram23
     .sram23_clk         (1'b0),
     .sram23_addr        (),
     .sram23_din         (),
     .sram23_en          (),
     .sram23_we          (),
     .sram23_dout        (1'b0),
     //sram24
     .sram24_clk         (1'b0),
     .sram24_addr        (),
     .sram24_din         (),
     .sram24_en          (),
     .sram24_we          (),
     .sram24_dout        (1'b0),
     //sram25
     .sram25_clk         (1'b0),
     .sram25_addr        (),
     .sram25_din         (),
     .sram25_en          (),
     .sram25_we          (),
     .sram25_dout        (1'b0),
     //sram26
     .sram26_clk         (1'b0),
     .sram26_addr        (),
     .sram26_din         (),
     .sram26_en          (),
     .sram26_we          (),
     .sram26_dout        (1'b0),
     //sram27
     .sram27_clk         (1'b0),
     .sram27_addr        (),
     .sram27_din         (),
     .sram27_en          (),
     .sram27_we          (),
     .sram27_dout        (1'b0),
     //sram28
     .sram28_clk         (1'b0),
     .sram28_addr        (),
     .sram28_din         (),
     .sram28_en          (),
     .sram28_we          (),
     .sram28_dout        (1'b0),
     //sram29
     .sram29_clk         (1'b0),
     .sram29_addr        (),
     .sram29_din         (),
     .sram29_en          (),
     .sram29_we          (),
     .sram29_dout        (1'b0),
     //sram30
     .sram30_clk         (1'b0),
     .sram30_addr        (),
     .sram30_din         (),
     .sram30_en          (),
     .sram30_we          (),
     .sram30_dout        (1'b0),
     //sram31
     .sram31_clk         (1'b0),
     .sram31_addr        (),
     .sram31_din         (),
     .sram31_en          (),
     .sram31_we          (),
     .sram31_dout        (1'b0),
     //------------------------------------
     // DP1R1W
     //------------------------------------
     //dp1r1w0
     .dp1r1w0_clka       (dp1r1w0_clka),
     .dp1r1w0_clkb       (dp1r1w0_clkb),
     .dp1r1w0_addra      (dp1r1w0_addra),
     .dp1r1w0_addrb      (dp1r1w0_addrb),
     .dp1r1w0_dina       (dp1r1w0_dina),
     .dp1r1w0_doutb      (dp1r1w0_doutb),
     .dp1r1w0_ena        (dp1r1w0_ena),
     .dp1r1w0_enb        (dp1r1w0_enb),
     .dp1r1w0_wea        (dp1r1w0_wea),
     //dp1r1w1
     .dp1r1w1_clka       (dp1r1w1_clka),
     .dp1r1w1_clkb       (dp1r1w1_clkb),
     .dp1r1w1_addra      (dp1r1w1_addra),
     .dp1r1w1_addrb      (dp1r1w1_addrb),
     .dp1r1w1_dina       (dp1r1w1_dina),
     .dp1r1w1_doutb      (dp1r1w1_doutb),
     .dp1r1w1_ena        (dp1r1w1_ena),
     .dp1r1w1_enb        (dp1r1w1_enb),
     .dp1r1w1_wea        (dp1r1w1_wea),
     //dp1r1w2
     .dp1r1w2_clka       (dp1r1w2_clka),
     .dp1r1w2_clkb       (dp1r1w2_clkb),
     .dp1r1w2_addra      (dp1r1w2_addra),
     .dp1r1w2_addrb      (dp1r1w2_addrb),
     .dp1r1w2_dina       (dp1r1w2_dina),
     .dp1r1w2_doutb      (dp1r1w2_doutb),
     .dp1r1w2_ena        (dp1r1w2_ena),
     .dp1r1w2_enb        (dp1r1w2_enb),
     .dp1r1w2_wea        (dp1r1w2_wea),
     //dp1r1w3
     .dp1r1w3_clka       (dp1r1w3_clka),
     .dp1r1w3_clkb       (dp1r1w3_clkb),
     .dp1r1w3_addra      (dp1r1w3_addra),
     .dp1r1w3_addrb      (dp1r1w3_addrb),
     .dp1r1w3_dina       (dp1r1w3_dina),
     .dp1r1w3_doutb      (dp1r1w3_doutb),
     .dp1r1w3_ena        (dp1r1w3_ena),
     .dp1r1w3_enb        (dp1r1w3_enb),
     .dp1r1w3_wea        (dp1r1w3_wea),
     //dp1r1w4
     .dp1r1w4_clka       (1'b0),
     .dp1r1w4_clkb       (1'b0),
     .dp1r1w4_addra      (),
     .dp1r1w4_addrb      (),
     .dp1r1w4_dina       (),
     .dp1r1w4_doutb      (1'b0),
     .dp1r1w4_ena        (),
     .dp1r1w4_enb        (),
     .dp1r1w4_wea        (),
     //dp1r1w5
     .dp1r1w5_clka       (1'b0),
     .dp1r1w5_clkb       (1'b0),
     .dp1r1w5_addra      (),
     .dp1r1w5_addrb      (),
     .dp1r1w5_dina       (),
     .dp1r1w5_doutb      (1'b0),
     .dp1r1w5_ena        (),
     .dp1r1w5_enb        (),
     .dp1r1w5_wea        (),
     //dp1r1w6
     .dp1r1w6_clka       (1'b0),
     .dp1r1w6_clkb       (1'b0),
     .dp1r1w6_addra      (),
     .dp1r1w6_addrb      (),
     .dp1r1w6_dina       (),
     .dp1r1w6_doutb      (1'b0),
     .dp1r1w6_ena        (),
     .dp1r1w6_enb        (),
     .dp1r1w6_wea        (),
     //dp1r1w7
     .dp1r1w7_clka       (1'b0),
     .dp1r1w7_clkb       (1'b0),
     .dp1r1w7_addra      (),
     .dp1r1w7_addrb      (),
     .dp1r1w7_dina       (),
     .dp1r1w7_doutb      (1'b0),
     .dp1r1w7_ena        (),
     .dp1r1w7_enb        (),
     .dp1r1w7_wea        (),
     //dp1r1w8
     .dp1r1w8_clka       (1'b0),
     .dp1r1w8_clkb       (1'b0),
     .dp1r1w8_addra      (),
     .dp1r1w8_addrb      (),
     .dp1r1w8_dina       (),
     .dp1r1w8_doutb      (1'b0),
     .dp1r1w8_ena        (),
     .dp1r1w8_enb        (),
     .dp1r1w8_wea        (),
     //dp1r1w9
     .dp1r1w9_clka       (1'b0),
     .dp1r1w9_clkb       (1'b0),
     .dp1r1w9_addra      (),
     .dp1r1w9_addrb      (),
     .dp1r1w9_dina       (),
     .dp1r1w9_doutb      (1'b0),
     .dp1r1w9_ena        (),
     .dp1r1w9_enb        (),
     .dp1r1w9_wea        (),
     //dp1r1w10
     .dp1r1w10_clka      (1'b0),
     .dp1r1w10_clkb      (1'b0),
     .dp1r1w10_addra     (),
     .dp1r1w10_addrb     (),
     .dp1r1w10_dina      (),
     .dp1r1w10_doutb     (1'b0),
     .dp1r1w10_ena       (),
     .dp1r1w10_enb       (),
     .dp1r1w10_wea       (),
     //dp1r1w11
     .dp1r1w11_clka      (1'b0),
     .dp1r1w11_clkb      (1'b0),
     .dp1r1w11_addra     (),
     .dp1r1w11_addrb     (),
     .dp1r1w11_dina      (),
     .dp1r1w11_doutb     (1'b0),
     .dp1r1w11_ena       (),
     .dp1r1w11_enb       (),
     .dp1r1w11_wea       (),
     //dp1r1w12
     .dp1r1w12_clka      (1'b0),
     .dp1r1w12_clkb      (1'b0),
     .dp1r1w12_addra     (),
     .dp1r1w12_addrb     (),
     .dp1r1w12_dina      (),
     .dp1r1w12_doutb     (1'b0),
     .dp1r1w12_ena       (),
     .dp1r1w12_enb       (),
     .dp1r1w12_wea       (),
     //dp1r1w13
     .dp1r1w13_clka      (1'b0),
     .dp1r1w13_clkb      (1'b0),
     .dp1r1w13_addra     (),
     .dp1r1w13_addrb     (),
     .dp1r1w13_dina      (),
     .dp1r1w13_doutb     (1'b0),
     .dp1r1w13_ena       (),
     .dp1r1w13_enb       (),
     .dp1r1w13_wea       (),
     //dp1r1w14
     .dp1r1w14_clka      (1'b0),
     .dp1r1w14_clkb      (1'b0),
     .dp1r1w14_addra     (),
     .dp1r1w14_addrb     (),
     .dp1r1w14_dina      (),
     .dp1r1w14_doutb     (1'b0),
     .dp1r1w14_ena       (),
     .dp1r1w14_enb       (),
     .dp1r1w14_wea       (),
     //dp1r1w15
     .dp1r1w15_clka      (1'b0),
     .dp1r1w15_clkb      (1'b0),
     .dp1r1w15_addra     (),
     .dp1r1w15_addrb     (),
     .dp1r1w15_dina      (),
     .dp1r1w15_doutb     (1'b0),
     .dp1r1w15_ena       (),
     .dp1r1w15_enb       (),
     .dp1r1w15_wea       (),
     //dp1r1w16
     .dp1r1w16_clka      (1'b0),
     .dp1r1w16_clkb      (1'b0),
     .dp1r1w16_addra     (),
     .dp1r1w16_addrb     (),
     .dp1r1w16_dina      (),
     .dp1r1w16_doutb     (1'b0),
     .dp1r1w16_ena       (),
     .dp1r1w16_enb       (),
     .dp1r1w16_wea       (),
     //dp1r1w17
     .dp1r1w17_clka      (1'b0),
     .dp1r1w17_clkb      (1'b0),
     .dp1r1w17_addra     (),
     .dp1r1w17_addrb     (),
     .dp1r1w17_dina      (),
     .dp1r1w17_doutb     (1'b0),
     .dp1r1w17_ena       (),
     .dp1r1w17_enb       (),
     .dp1r1w17_wea       (),
     //dp1r1w18
     .dp1r1w18_clka      (1'b0),
     .dp1r1w18_clkb      (1'b0),
     .dp1r1w18_addra     (),
     .dp1r1w18_addrb     (),
     .dp1r1w18_dina      (),
     .dp1r1w18_doutb     (1'b0),
     .dp1r1w18_ena       (),
     .dp1r1w18_enb       (),
     .dp1r1w18_wea       (),
     //dp1r1w19
     .dp1r1w19_clka      (1'b0),
     .dp1r1w19_clkb      (1'b0),
     .dp1r1w19_addra     (),
     .dp1r1w19_addrb     (),
     .dp1r1w19_dina      (),
     .dp1r1w19_doutb     (1'b0),
     .dp1r1w19_ena       (),
     .dp1r1w19_enb       (),
     .dp1r1w19_wea       (),
     //dp1r1w20
     .dp1r1w20_clka      (1'b0),
     .dp1r1w20_clkb      (1'b0),
     .dp1r1w20_addra     (),
     .dp1r1w20_addrb     (),
     .dp1r1w20_dina      (),
     .dp1r1w20_doutb     (1'b0),
     .dp1r1w20_ena       (),
     .dp1r1w20_enb       (),
     .dp1r1w20_wea       (),
     //dp1r1w21
     .dp1r1w21_clka      (1'b0),
     .dp1r1w21_clkb      (1'b0),
     .dp1r1w21_addra     (),
     .dp1r1w21_addrb     (),
     .dp1r1w21_dina      (),
     .dp1r1w21_doutb     (1'b0),
     .dp1r1w21_ena       (),
     .dp1r1w21_enb       (),
     .dp1r1w21_wea       (),
     //dp1r1w22
     .dp1r1w22_clka      (1'b0),
     .dp1r1w22_clkb      (1'b0),
     .dp1r1w22_addra     (),
     .dp1r1w22_addrb     (),
     .dp1r1w22_dina      (),
     .dp1r1w22_doutb     (1'b0),
     .dp1r1w22_ena       (),
     .dp1r1w22_enb       (),
     .dp1r1w22_wea       (),
     //dp1r1w23
     .dp1r1w23_clka      (1'b0),
     .dp1r1w23_clkb      (1'b0),
     .dp1r1w23_addra     (),
     .dp1r1w23_addrb     (),
     .dp1r1w23_dina      (),
     .dp1r1w23_doutb     (1'b0),
     .dp1r1w23_ena       (),
     .dp1r1w23_enb       (),
     .dp1r1w23_wea       (),
     //dp1r1w24
     .dp1r1w24_clka      (1'b0),
     .dp1r1w24_clkb      (1'b0),
     .dp1r1w24_addra     (),
     .dp1r1w24_addrb     (),
     .dp1r1w24_dina      (),
     .dp1r1w24_doutb     (1'b0),
     .dp1r1w24_ena       (),
     .dp1r1w24_enb       (),
     .dp1r1w24_wea       (),
     //dp1r1w25
     .dp1r1w25_clka      (1'b0),
     .dp1r1w25_clkb      (1'b0),
     .dp1r1w25_addra     (),
     .dp1r1w25_addrb     (),
     .dp1r1w25_dina      (),
     .dp1r1w25_doutb     (1'b0),
     .dp1r1w25_ena       (),
     .dp1r1w25_enb       (),
     .dp1r1w25_wea       (),
     //dp1r1w26
     .dp1r1w26_clka      (1'b0),
     .dp1r1w26_clkb      (1'b0),
     .dp1r1w26_addra     (),
     .dp1r1w26_addrb     (),
     .dp1r1w26_dina      (),
     .dp1r1w26_doutb     (1'b0),
     .dp1r1w26_ena       (),
     .dp1r1w26_enb       (),
     .dp1r1w26_wea       (),
     //dp1r1w27
     .dp1r1w27_clka      (1'b0),
     .dp1r1w27_clkb      (1'b0),
     .dp1r1w27_addra     (),
     .dp1r1w27_addrb     (),
     .dp1r1w27_dina      (),
     .dp1r1w27_doutb     (1'b0),
     .dp1r1w27_ena       (),
     .dp1r1w27_enb       (),
     .dp1r1w27_wea       (),
     //dp1r1w28
     .dp1r1w28_clka      (1'b0),
     .dp1r1w28_clkb      (1'b0),
     .dp1r1w28_addra     (),
     .dp1r1w28_addrb     (),
     .dp1r1w28_dina      (),
     .dp1r1w28_doutb     (1'b0),
     .dp1r1w28_ena       (),
     .dp1r1w28_enb       (),
     .dp1r1w28_wea       (),
     //dp1r1w29
     .dp1r1w29_clka      (1'b0),
     .dp1r1w29_clkb      (1'b0),
     .dp1r1w29_addra     (),
     .dp1r1w29_addrb     (),
     .dp1r1w29_dina      (),
     .dp1r1w29_doutb     (1'b0),
     .dp1r1w29_ena       (),
     .dp1r1w29_enb       (),
     .dp1r1w29_wea       (),
     //dp1r1w30
     .dp1r1w30_clka      (1'b0),
     .dp1r1w30_clkb      (1'b0),
     .dp1r1w30_addra     (),
     .dp1r1w30_addrb     (),
     .dp1r1w30_dina      (),
     .dp1r1w30_doutb     (1'b0),
     .dp1r1w30_ena       (),
     .dp1r1w30_enb       (),
     .dp1r1w30_wea       (),
     //dp1r1w31
     .dp1r1w31_clka      (1'b0),
     .dp1r1w31_clkb      (1'b0),
     .dp1r1w31_addra     (),
     .dp1r1w31_addrb     (),
     .dp1r1w31_dina      (),
     .dp1r1w31_doutb     (1'b0),
     .dp1r1w31_ena       (),
     .dp1r1w31_enb       (),
     .dp1r1w31_wea       (),
     //------------------------------------
     // SRAM_BE
     //------------------------------------
    //sram_be_0
     .sram_be_0_clk          (sram_be_0_clk),
     .sram_be_0_addr         (sram_be_0_addr),
     .sram_be_0_din          (sram_be_0_din),
     .sram_be_0_ben          (sram_be_0_ben),
     .sram_be_0_en           (sram_be_0_en),
     .sram_be_0_we           (sram_be_0_we),
     .sram_be_0_dout         (sram_be_0_dout),
    //sram_be_1
     .sram_be_1_clk          (sram_be_1_clk),
     .sram_be_1_addr         (sram_be_1_addr),
     .sram_be_1_din          (sram_be_1_din),
     .sram_be_1_ben          (sram_be_1_ben),
     .sram_be_1_en           (sram_be_1_en),
     .sram_be_1_we           (sram_be_1_we),
     .sram_be_1_dout         (sram_be_1_dout),
     //sram_be_2
     .sram_be_2_clk          (1'b0),
     .sram_be_2_addr         (),
     .sram_be_2_din          (),
     .sram_be_2_ben          (),
     .sram_be_2_en           (),
     .sram_be_2_we           (),
     .sram_be_2_dout         (8'h0),
     //sram_be_3
     .sram_be_3_clk          (1'b0),
     .sram_be_3_addr         (),
     .sram_be_3_din          (),
     .sram_be_3_ben          (),
     .sram_be_3_en           (),
     .sram_be_3_we           (),
     .sram_be_3_dout         (8'h0),
     //sram_be_4
     .sram_be_4_clk          (1'b0),
     .sram_be_4_addr         (),
     .sram_be_4_din          (),
     .sram_be_4_ben          (),
     .sram_be_4_en           (),
     .sram_be_4_we           (),
     .sram_be_4_dout         (8'h0),
     //sram_be_5
     .sram_be_5_clk          (1'b0),
     .sram_be_5_addr         (),
     .sram_be_5_din          (),
     .sram_be_5_ben          (),
     .sram_be_5_en           (),
     .sram_be_5_we           (),
     .sram_be_5_dout         (8'h0),
     //sram_be_6
     .sram_be_6_clk          (1'b0),
     .sram_be_6_addr         (),
     .sram_be_6_din          (),
     .sram_be_6_ben          (),
     .sram_be_6_en           (),
     .sram_be_6_we           (),
     .sram_be_6_dout         (8'h0),
     //sram_be_7
     .sram_be_7_clk          (1'b0),
     .sram_be_7_addr         (),
     .sram_be_7_din          (),
     .sram_be_7_ben          (),
     .sram_be_7_en           (),
     .sram_be_7_we           (),
     .sram_be_7_dout         (8'h0),
     //sram_be_8
     .sram_be_8_clk          (1'b0),
     .sram_be_8_addr         (),
     .sram_be_8_din          (),
     .sram_be_8_ben          (),
     .sram_be_8_en           (),
     .sram_be_8_we           (),
     .sram_be_8_dout         (8'h0),
     //sram_be_9
     .sram_be_9_clk          (1'b0),
     .sram_be_9_addr         (),
     .sram_be_9_din          (),
     .sram_be_9_ben          (),
     .sram_be_9_en           (),
     .sram_be_9_we           (),
     .sram_be_9_dout         (8'h0),
     //sram_be_10
     .sram_be_10_clk         (1'b0),
     .sram_be_10_addr        (),
     .sram_be_10_din         (),
     .sram_be_10_ben         (),
     .sram_be_10_en          (),
     .sram_be_10_we          (),
     .sram_be_10_dout        (8'h0),
     //sram_be_11
     .sram_be_11_clk         (1'b0),
     .sram_be_11_addr        (),
     .sram_be_11_din         (),
     .sram_be_11_ben         (),
     .sram_be_11_en          (),
     .sram_be_11_we          (),
     .sram_be_11_dout        (8'h0),
     //sram_be_12
     .sram_be_12_clk         (1'b0),
     .sram_be_12_addr        (),
     .sram_be_12_din         (),
     .sram_be_12_ben         (),
     .sram_be_12_en          (),
     .sram_be_12_we          (),
     .sram_be_12_dout        (8'h0),
     //sram_be_13
     .sram_be_13_clk         (1'b0),
     .sram_be_13_addr        (),
     .sram_be_13_din         (),
     .sram_be_13_ben         (),
     .sram_be_13_en          (),
     .sram_be_13_we          (),
     .sram_be_13_dout        (8'h0),
     //sram_be_14
     .sram_be_14_clk         (1'b0),
     .sram_be_14_addr        (),
     .sram_be_14_din         (),
     .sram_be_14_ben         (),
     .sram_be_14_en          (),
     .sram_be_14_we          (),
     .sram_be_14_dout        (8'h0),
     //sram_be_15
     .sram_be_15_clk         (1'b0),
     .sram_be_15_addr        (),
     .sram_be_15_din         (),
     .sram_be_15_ben         (),
     .sram_be_15_en          (),
     .sram_be_15_we          (),
     .sram_be_15_dout        (8'h0),
     //sram_be_16
     .sram_be_16_clk         (1'b0),
     .sram_be_16_addr        (),
     .sram_be_16_din         (),
     .sram_be_16_ben         (),
     .sram_be_16_en          (),
     .sram_be_16_we          (),
     .sram_be_16_dout        (8'h0),
     //sram_be_17
     .sram_be_17_clk         (1'b0),
     .sram_be_17_addr        (),
     .sram_be_17_din         (),
     .sram_be_17_ben         (),
     .sram_be_17_en          (),
     .sram_be_17_we          (),
     .sram_be_17_dout        (8'h0),
     //sram_be_18
     .sram_be_18_clk         (1'b0),
     .sram_be_18_addr        (),
     .sram_be_18_din         (),
     .sram_be_18_ben         (),
     .sram_be_18_en          (),
     .sram_be_18_we          (),
     .sram_be_18_dout        (8'h0),
     //sram_be_19
     .sram_be_19_clk         (1'b0),
     .sram_be_19_addr        (),
     .sram_be_19_din         (),
     .sram_be_19_ben         (),
     .sram_be_19_en          (),
     .sram_be_19_we          (),
     .sram_be_19_dout        (8'h0),
     //sram_be_20
     .sram_be_20_clk         (1'b0),
     .sram_be_20_addr        (),
     .sram_be_20_din         (),
     .sram_be_20_ben         (),
     .sram_be_20_en          (),
     .sram_be_20_we          (),
     .sram_be_20_dout        (8'h0),
     //sram_be_21
     .sram_be_21_clk         (1'b0),
     .sram_be_21_addr        (),
     .sram_be_21_din         (),
     .sram_be_21_ben         (),
     .sram_be_21_en          (),
     .sram_be_21_we          (),
     .sram_be_21_dout        (8'h0),
     //sram_be_22
     .sram_be_22_clk         (1'b0),
     .sram_be_22_addr        (),
     .sram_be_22_din         (),
     .sram_be_22_ben         (),
     .sram_be_22_en          (),
     .sram_be_22_we          (),
     .sram_be_22_dout        (8'h0),
     //sram_be_23
     .sram_be_23_clk         (1'b0),
     .sram_be_23_addr        (),
     .sram_be_23_din         (),
     .sram_be_23_ben         (),
     .sram_be_23_en          (),
     .sram_be_23_we          (),
     .sram_be_23_dout        (8'h0),
     //sram_be_24
     .sram_be_24_clk         (1'b0),
     .sram_be_24_addr        (),
     .sram_be_24_din         (),
     .sram_be_24_ben         (),
     .sram_be_24_en          (),
     .sram_be_24_we          (),
     .sram_be_24_dout        (8'h0),
     //sram_be_25
     .sram_be_25_clk         (1'b0),
     .sram_be_25_addr        (),
     .sram_be_25_din         (),
     .sram_be_25_ben         (),
     .sram_be_25_en          (),
     .sram_be_25_we          (),
     .sram_be_25_dout        (8'h0),
     //sram_be_26
     .sram_be_26_clk         (1'b0),
     .sram_be_26_addr        (),
     .sram_be_26_din         (),
     .sram_be_26_ben         (),
     .sram_be_26_en          (),
     .sram_be_26_we          (),
     .sram_be_26_dout        (8'h0),
     //sram_be_27
     .sram_be_27_clk         (1'b0),
     .sram_be_27_addr        (),
     .sram_be_27_din         (),
     .sram_be_27_ben         (),
     .sram_be_27_en          (),
     .sram_be_27_we          (),
     .sram_be_27_dout        (8'h0),
     //sram_be_28
     .sram_be_28_clk         (1'b0),
     .sram_be_28_addr        (),
     .sram_be_28_din         (),
     .sram_be_28_ben         (),
     .sram_be_28_en          (),
     .sram_be_28_we          (),
     .sram_be_28_dout        (8'h0),
     //sram_be_29
     .sram_be_29_clk         (1'b0),
     .sram_be_29_addr        (),
     .sram_be_29_din         (),
     .sram_be_29_ben         (),
     .sram_be_29_en          (),
     .sram_be_29_we          (),
     .sram_be_29_dout        (8'h0),
     //sram_be_30
     .sram_be_30_clk         (1'b0),
     .sram_be_30_addr        (),
     .sram_be_30_din         (),
     .sram_be_30_ben         (),
     .sram_be_30_en          (),
     .sram_be_30_we          (),
     .sram_be_30_dout        (8'h0),
     //sram_be_31
     .sram_be_31_clk         (1'b0),
     .sram_be_31_addr        (),
     .sram_be_31_din         (),
     .sram_be_31_ben         (),
     .sram_be_31_en          (),
     .sram_be_31_we          (),
     .sram_be_31_dout        (8'h0)
    );

endmodule
