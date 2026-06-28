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
// The purpose of this file is to implement a customer dut wrapper, where a
// customer instantiates the top level of the IP and has propriety wrapper
// logic around the IP instantiation, such as bus bridges.
//
//----------------------------------------------------------------------------

module customer_wrapper #(

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

  //--------------------------------------
  // Demo Top Level Module
  //--------------------------------------

  cdn_demo_top #(

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

  ) u_cdn_demo_top ( 

    //------------------------------------
    // APB
    //------------------------------------
    .pclk(pclk),
    .presetn(presetn),
    .paddr(paddr),
    .pprot(pprot),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .pstrb(pstrb),
    .pready(pready),
    .prdata(prdata),
    .pslverr(pslverr),

    .interrupt(interrupt),

    //------------------------------------
    // SRAM
    //------------------------------------
    //sram0
    .sram0_clk  (sram0_clk),
    .sram0_addr (sram0_addr),
    .sram0_din  (sram0_din),
    .sram0_en   (sram0_en),
    .sram0_we   (sram0_we),
    .sram0_dout (sram0_dout),
    //sram1
    .sram1_clk  (sram1_clk),
    .sram1_addr (sram1_addr),
    .sram1_din  (sram1_din),
    .sram1_en   (sram1_en),
    .sram1_we   (sram1_we),
    .sram1_dout (sram1_dout),
    //------------------------------------
    // SRAM_2S
    //------------------------------------
    //sram2_2s_0
    .sram2_clk  (sram2_clk),
    .sram2_addr (sram2_addr),
    .sram2_din  (sram2_din),
    .sram2_en   (sram2_en),
    .sram2_we   (sram2_we),
    .sram2_dout (sram2_dout),
    //sram3_2s_1
    .sram3_clk  (sram3_clk),
    .sram3_addr (sram3_addr),
    .sram3_din  (sram3_din),
    .sram3_en   (sram3_en),
    .sram3_we   (sram3_we),
    .sram3_dout (sram3_dout),

    //------------------------------------
    // DP1R1W
    //------------------------------------
    //dp1r1w0
    .dp1r1w0_clka   (dp1r1w0_clka),
    .dp1r1w0_clkb   (dp1r1w0_clkb),
    .dp1r1w0_addra  (dp1r1w0_addra),
    .dp1r1w0_addrb  (dp1r1w0_addrb),
    .dp1r1w0_dina   (dp1r1w0_dina),
    .dp1r1w0_doutb  (dp1r1w0_doutb),
    .dp1r1w0_ena    (dp1r1w0_ena),
    .dp1r1w0_enb    (dp1r1w0_enb),
    .dp1r1w0_wea    (dp1r1w0_wea),
    //dp1r1w1
    .dp1r1w1_clka   (dp1r1w1_clka),
    .dp1r1w1_clkb   (dp1r1w1_clkb),
    .dp1r1w1_addra  (dp1r1w1_addra),
    .dp1r1w1_addrb  (dp1r1w1_addrb),
    .dp1r1w1_dina   (dp1r1w1_dina),
    .dp1r1w1_doutb  (dp1r1w1_doutb),
    .dp1r1w1_ena    (dp1r1w1_ena),
    .dp1r1w1_enb    (dp1r1w1_enb),
    .dp1r1w1_wea    (dp1r1w1_wea),
    //------------------------------------
    // DP1R1W_2S
    //------------------------------------
    //dp1r1w2_2s_0
    .dp1r1w2_clka   (dp1r1w2_clka),
    .dp1r1w2_clkb   (dp1r1w2_clkb),
    .dp1r1w2_addra  (dp1r1w2_addra),
    .dp1r1w2_addrb  (dp1r1w2_addrb),
    .dp1r1w2_dina   (dp1r1w2_dina),
    .dp1r1w2_doutb  (dp1r1w2_doutb),
    .dp1r1w2_ena    (dp1r1w2_ena),
    .dp1r1w2_enb    (dp1r1w2_enb),
    .dp1r1w2_wea    (dp1r1w2_wea),
    //dp1r1w3_2s_1
    .dp1r1w3_clka   (dp1r1w3_clka),
    .dp1r1w3_clkb   (dp1r1w3_clkb),
    .dp1r1w3_addra  (dp1r1w3_addra),
    .dp1r1w3_addrb  (dp1r1w3_addrb),
    .dp1r1w3_dina   (dp1r1w3_dina),
    .dp1r1w3_doutb  (dp1r1w3_doutb),
    .dp1r1w3_ena    (dp1r1w3_ena),
    .dp1r1w3_enb    (dp1r1w3_enb),
    .dp1r1w3_wea    (dp1r1w3_wea),

    //------------------------------------
    // SRAM_BE
    //------------------------------------
    //sram_be_0
    .sram_be_0_clk  (sram_be_0_clk),
    .sram_be_0_addr (sram_be_0_addr),
    .sram_be_0_din  (sram_be_0_din),
    .sram_be_0_ben  (sram_be_0_ben),
    .sram_be_0_en   (sram_be_0_en),
    .sram_be_0_we   (sram_be_0_we),
    .sram_be_0_dout (sram_be_0_dout),
    //sram_be_1
    .sram_be_1_clk  (sram_be_1_clk),
    .sram_be_1_addr (sram_be_1_addr),
    .sram_be_1_din  (sram_be_1_din),
    .sram_be_1_ben  (sram_be_1_ben),
    .sram_be_1_en   (sram_be_1_en),
    .sram_be_1_we   (sram_be_1_we),
    .sram_be_1_dout (sram_be_1_dout),

    //------------------------------------
    // AXI I/F
    //------------------------------------
    .awuser(awuser),
    .awid(awid),
    .awaddr(awaddr),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),
    .awlock(awlock),
    .awcache(awcache),
    .awprot(awprot),
    .awqos(awqos),
    .awregion(awregion),
    .awvalid(awvalid),
    .awready(awready),
    
    // AXI W  channel signals (Write data channel)
    .wuser(wuser),
    .wdata(wdata),
    .wstrb(wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),
     // AXI B  channel signals (Write response channel)
    .buser(buser),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready),
    
    // AXI AR channel signals (Read address channel)
    .arid(arid),
    .araddr(araddr),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),
    .arlock(arlock),
    .arcache(arcache),
    .arprot(arprot),
    .arqos(arqos),
    .arregion(arregion),
    .arvalid(arvalid),
    .arready(arready),
    
     // AXI R  channel signals (Read data channel)
    .rid(rid),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready)

  );

endmodule

