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
// The purpose of this file is to encapsulate all ram integration
// instantiations and connectivity, to abstract the ram integration work
// outside of the top level cdn_demo_module_top level.
//----------------------------------------------------------------------------


// Inputs to MASTER APB Bank
parameter NUM_SRAM              = 4;
parameter NUM_DP1R1W            = 4;
parameter NUM_DP2R2W            = 0;
parameter NUM_RF                = 0;
parameter NUM_SRAM_BE           = 2;
parameter NUM_DP1R1W_BE         = 0;
parameter NUM_DP2R2W_BE         = 0;
parameter NUM_RF_BE             = 0;

// Ram parameters

// SRAM
parameter SRAM0_READ_DELAY      = 1;
parameter SRAM1_READ_DELAY      = 1;
parameter SRAM0_ADDR_WD         = 10;
parameter SRAM1_ADDR_WD         = 10;
parameter SRAM0_DEPTH           = 50;   //1<<SRAM0_ADDR_WD;
parameter SRAM1_DEPTH           = 800;  //1<<SRAM1_ADDR_WD;
parameter SRAM0_DATA_WD         = 124;
parameter SRAM1_DATA_WD         = 104;
parameter SRAM0_HOLDDATA        = 0;
parameter SRAM1_HOLDDATA        = 1;
// SRAM_2S
parameter SRAM2_READ_DELAY      = 1;
parameter SRAM3_READ_DELAY      = 1;
parameter SRAM2_ADDR_WD         = 8;
parameter SRAM3_ADDR_WD         = 6;
parameter SRAM2_DEPTH           = 1<<SRAM2_ADDR_WD;
parameter SRAM3_DEPTH           = 1<<SRAM3_ADDR_WD;
parameter SRAM2_DATA_WD         = 256;
parameter SRAM3_DATA_WD         = 16;
// DP1R1W
parameter DP1R1W0_READ_DELAY    = 0;
parameter DP1R1W1_READ_DELAY    = 0;
parameter DP1R1W0_ADDR_WD       = 5;
parameter DP1R1W1_ADDR_WD       = 8;
parameter DP1R1W0_DEPTH         = 1<<DP1R1W0_ADDR_WD;
parameter DP1R1W1_DEPTH         = 1<<DP1R1W1_ADDR_WD;
parameter DP1R1W0_DATA_WD       = 114;
parameter DP1R1W1_DATA_WD       = 100;
parameter DP1R1W0_HOLDDATA      = 0;
parameter DP1R1W1_HOLDDATA      = 1;
// DP1R1W_2S
parameter DP1R1W2_READ_DELAY    = 1;
parameter DP1R1W3_READ_DELAY    = 1;
parameter DP1R1W2_ADDR_WD       = 8;
parameter DP1R1W3_ADDR_WD       = 6;
parameter DP1R1W2_DEPTH         = 1<<DP1R1W2_ADDR_WD;
parameter DP1R1W3_DEPTH         = 1<<DP1R1W3_ADDR_WD;
parameter DP1R1W2_DATA_WD       = 256;
parameter DP1R1W3_DATA_WD       = 16;
// SRAM_BE
parameter SRAM_BE_0_READ_DELAY  = 0;
parameter SRAM_BE_1_READ_DELAY  = 0;
parameter SRAM_BE_0_ADDR_WD     = 12;
parameter SRAM_BE_1_ADDR_WD     = 4;
parameter SRAM_BE_0_DEPTH       = 1<<SRAM_BE_0_ADDR_WD;
parameter SRAM_BE_1_DEPTH       = 1<<SRAM_BE_1_ADDR_WD;
parameter SRAM_BE_0_DATA_WD     = 16;
parameter SRAM_BE_1_DATA_WD     = 32;

//--------------------------------------
// SRAM
//--------------------------------------
//sram0
wire                        sram0_clk;
wire    [SRAM0_ADDR_WD-1:0] sram0_addr;
wire    [SRAM0_DATA_WD-1:0] sram0_din;
wire    [SRAM0_DATA_WD-1:0] sram0_dout;
wire                        sram0_en;
wire                        sram0_we;
//sram1
wire                        sram1_clk;
wire    [SRAM1_ADDR_WD-1:0] sram1_addr;
wire    [SRAM1_DATA_WD-1:0] sram1_din;
wire    [SRAM1_DATA_WD-1:0] sram1_dout;
wire                        sram1_en;
wire                        sram1_we;
//--------------------------------------
// SRAM_2S
//--------------------------------------
//sram2_2s_0
wire                        sram2_clk;
wire    [SRAM2_ADDR_WD-1:0] sram2_addr;
wire    [SRAM2_DATA_WD-1:0] sram2_din;
wire    [SRAM2_DATA_WD-1:0] sram2_dout;
wire                        sram2_en;
wire                        sram2_we;
//sram3_2s_1
wire                        sram3_clk;
wire    [SRAM3_ADDR_WD-1:0] sram3_addr;
wire    [SRAM3_DATA_WD-1:0] sram3_din;
wire    [SRAM3_DATA_WD-1:0] sram3_dout;
wire                        sram3_en;
wire                        sram3_we;

//--------------------------------------
// DP1R1W
//--------------------------------------
//dp1r1w0
wire                        dp1r1w0_clka;
wire                        dp1r1w0_clkb;
wire  [DP1R1W0_ADDR_WD-1:0] dp1r1w0_addra;
wire  [DP1R1W0_ADDR_WD-1:0] dp1r1w0_addrb;
wire  [DP1R1W0_DATA_WD-1:0] dp1r1w0_dina;
wire  [DP1R1W0_DATA_WD-1:0] dp1r1w0_doutb;
wire                        dp1r1w0_ena;
wire                        dp1r1w0_enb;
wire                        dp1r1w0_wea;
//dp1r1w1
wire                        dp1r1w1_clka;
wire                        dp1r1w1_clkb;
wire  [DP1R1W1_ADDR_WD-1:0] dp1r1w1_addra;
wire  [DP1R1W1_ADDR_WD-1:0] dp1r1w1_addrb;
wire  [DP1R1W1_DATA_WD-1:0] dp1r1w1_dina;
wire  [DP1R1W1_DATA_WD-1:0] dp1r1w1_doutb;
wire                        dp1r1w1_ena;
wire                        dp1r1w1_enb;
wire                        dp1r1w1_wea;
//--------------------------------------
// DP1R1W_2S
//--------------------------------------
//dp1r1w2_2s_0
wire                        dp1r1w2_clka;
wire                        dp1r1w2_clkb;
wire  [DP1R1W2_ADDR_WD-1:0] dp1r1w2_addra;
wire  [DP1R1W2_ADDR_WD-1:0] dp1r1w2_addrb;
wire  [DP1R1W2_DATA_WD-1:0] dp1r1w2_dina;
wire  [DP1R1W2_DATA_WD-1:0] dp1r1w2_doutb;
wire                        dp1r1w2_ena;
wire                        dp1r1w2_enb;
wire                        dp1r1w2_wea;
//dp1r1w3_2s_1
wire                        dp1r1w3_clka;
wire                        dp1r1w3_clkb;
wire  [DP1R1W3_ADDR_WD-1:0] dp1r1w3_addra;
wire  [DP1R1W3_ADDR_WD-1:0] dp1r1w3_addrb;
wire  [DP1R1W3_DATA_WD-1:0] dp1r1w3_dina;
wire  [DP1R1W3_DATA_WD-1:0] dp1r1w3_doutb;
wire                        dp1r1w3_ena;
wire                        dp1r1w3_enb;
wire                        dp1r1w3_wea;

//--------------------------------------
// SRAM_BE
//--------------------------------------
//sram_be_0
wire                            sram_be_0_clk;
wire  [SRAM_BE_0_ADDR_WD-1  :0] sram_be_0_addr;
wire  [SRAM_BE_0_DATA_WD-1  :0] sram_be_0_din;
wire  [SRAM_BE_0_DATA_WD-1  :0] sram_be_0_dout;
wire  [SRAM_BE_0_DATA_WD/8-1:0] sram_be_0_ben;
wire                            sram_be_0_en;
wire                            sram_be_0_we;
//sram_be_1
wire                            sram_be_1_clk;
wire  [SRAM_BE_1_ADDR_WD-1  :0] sram_be_1_addr;
wire  [SRAM_BE_1_DATA_WD-1  :0] sram_be_1_din;
wire  [SRAM_BE_1_DATA_WD-1  :0] sram_be_1_dout;
wire  [SRAM_BE_1_DATA_WD/8-1:0] sram_be_1_ben;
wire                            sram_be_1_en;
wire                            sram_be_1_we;

//--------------------------------------
// clocks of RAMs
//--------------------------------------
// SRAM
assign sram0_clk = clk0;
assign sram1_clk = clk1;
// SRAM_2S
assign sram2_clk = clk0;
assign sram3_clk = clk1;

// DP1R1W
assign dp1r1w0_clka = clk1;
assign dp1r1w0_clkb = clk2;
assign dp1r1w1_clka = clk1;
assign dp1r1w1_clkb = clk2;
// DP1R1W_2S
assign dp1r1w2_clka = clk1;
assign dp1r1w2_clkb = clk2;
assign dp1r1w3_clka = clk1;
assign dp1r1w3_clkb = clk2;

// SRAM_BE
assign sram_be_0_clk = clk0;
assign sram_be_1_clk = clk1;

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
  .pclk(clk0),
  .presetn(rst0_n),
  .paddr(apb_reg_if_slave1.paddr[12:0]),
  .pprot(3'd0),
  .psel(apb_reg_if_slave1.psel),
  .penable(apb_reg_if_slave1.penable),
  .pwrite(apb_reg_if_slave1.pwrite),
  .pwdata(apb_reg_if_slave1.pwdata),
  .pstrb(4'hf),
  .pready(apb_reg_if_slave1.pready),
  .prdata(apb_reg_if_slave1.prdata),
  .pslverr(apb_reg_if_slave1.pslverr),

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
  .awuser(axi_if.awuser),
  .awid(axi_if.awid),
  .awaddr(axi_if.awaddr),
  .awlen(axi_if.awlen),
  .awsize(axi_if.awsize),
  .awburst(axi_if.awburst),
  .awlock(axi_if.awlock),
  .awcache(axi_if.awcache),
  .awprot(axi_if.awprot),
  .awqos(axi_if.awqos),
  .awregion(axi_if.awregion),
  .awvalid(axi_if.awvalid),
  .awready(axi_if.awready),
  
  // AXI W  channel signals (Write data channel)
  .wuser(axi_if.wuser),
  .wdata(axi_if.wdata),
  .wstrb(axi_if.wstrb),
  .wlast(axi_if.wlast),
  .wvalid(axi_if.wvalid),
  .wready(axi_if.wready),
   // AXI B  channel signals (Write response channel)
  .buser(axi_if.buser),
  .bresp(axi_if.bresp),
  .bvalid(axi_if.bvalid),
  .bready(axi_if.bready),
  
  // AXI AR channel signals (Read address channel)
  .arid(axi_if.arid),
  .araddr(axi_if.araddr),
  .arlen(axi_if.arlen),
  .arsize(axi_if.arsize),
  .arburst(axi_if.arburst),
  .arlock(axi_if.arlock),
  .arcache(axi_if.arcache),
  .arprot(axi_if.arprot),
  .arqos(axi_if.arqos),
  .arregion(axi_if.arregion),
  .arvalid(axi_if.arvalid),
  .arready(axi_if.arready),
  
   // AXI R  channel signals (Read data channel)
  .rid(axi_if.rid),
  .rdata(axi_if.rdata),
  .rresp(axi_if.rresp),
  .rlast(axi_if.rlast),
  .rvalid(axi_if.rvalid),
  .rready(axi_if.rready)

);

//--------------------------------------
// SRAM
//--------------------------------------
//sram0
ram_1p
#(
  .WD          (SRAM0_DATA_WD),
  .PW          (SRAM0_ADDR_WD),
  .DP          (SRAM0_DEPTH),
  .MEMHOLDDATA (SRAM0_HOLDDATA),
  .INIT        (3)
)
u_sram0
(
  .clk         (sram0_clk),
  .addr        (sram0_addr),
  .din         (sram0_din),
  .dout        (sram0_dout),
  .en          (sram0_en),
  .we          (sram0_we)
);

//sram1
ram_1p
#(
  .WD          (SRAM1_DATA_WD),
  .PW          (SRAM1_ADDR_WD),
  .DP          (SRAM1_DEPTH),
  .MEMHOLDDATA (SRAM1_HOLDDATA),
  .INIT        (3)
)
u_sram1
(
  .clk         (sram1_clk),
  .addr        (sram1_addr),
  .din         (sram1_din),
  .dout        (sram1_dout),
  .en          (sram1_en),
  .we          (sram1_we)
);

//--------------------------------------
// SRAM_2S
//--------------------------------------
//sram2_2s_0
sp_ram_2s
#(
  .DATA_WIDTH   (SRAM2_DATA_WD),
  .ADDR_WIDTH   (SRAM2_ADDR_WD),
  .WORD_COUNT   (SRAM2_DEPTH)
)
u_sram_2s_0
(
  .clock        (sram2_clk),
  .reset_n      (rst0_n),
  .address      (sram2_addr),
  .write_data   (sram2_din),
  .read_data    (sram2_dout),
  .read_enable  (sram2_en),
  .write_enable (sram2_we)
);

//sram3_2s_1
sp_ram_2s
#(
  .DATA_WIDTH   (SRAM3_DATA_WD),
  .ADDR_WIDTH   (SRAM3_ADDR_WD),
  .WORD_COUNT   (SRAM3_DEPTH)
)
u_sram_2s_1
(
  .clock        (sram3_clk),
  .reset_n      (rst0_n),
  .address      (sram3_addr),
  .write_data   (sram3_din),
  .read_data    (sram3_dout),
  .read_enable  (sram3_en),
  .write_enable (sram3_we)
);

//--------------------------------------
// DP1R1W
//--------------------------------------
//dp1r1w0
ram_2p 
#(
  .WD            (DP1R1W0_DATA_WD),
  .PW            (DP1R1W0_ADDR_WD),
  .DP            (DP1R1W0_DEPTH),
  .MEMHOLDDATA   (DP1R1W0_HOLDDATA),
  .REPORT_ERRORS (1),
  .INIT          (3),
  .INIT_FILE     ("")
)
u_dp1r1w0
(
  .clka          (dp1r1w0_clka),
  .clkb          (dp1r1w0_clkb),
  .addra         (dp1r1w0_addra),
  .addrb         (dp1r1w0_addrb),
  .dina          (dp1r1w0_dina),
  .doutb         (dp1r1w0_doutb),
  .ena           (dp1r1w0_ena),
  .enb           (dp1r1w0_enb),
  .wea           (dp1r1w0_wea)
);

//dp1r1w1
ram_2p 
#(
  .WD            (DP1R1W1_DATA_WD),
  .PW            (DP1R1W1_ADDR_WD),
  .DP            (DP1R1W1_DEPTH),
  .MEMHOLDDATA   (DP1R1W1_HOLDDATA),
  .REPORT_ERRORS (1),
  .INIT          (3),
  .INIT_FILE     ("")
)
u_dp1r1w1
(
  .clka          (dp1r1w1_clka),
  .clkb          (dp1r1w1_clkb),
  .addra         (dp1r1w1_addra),
  .addrb         (dp1r1w1_addrb),
  .dina          (dp1r1w1_dina),
  .doutb         (dp1r1w1_doutb),
  .ena           (dp1r1w1_ena),
  .enb           (dp1r1w1_enb),
  .wea           (dp1r1w1_wea)
);

//--------------------------------------
// DP1R1W_2S
//--------------------------------------
//dp1r1w2_2s_0
dp_ram_2s
#(
  .DATA_WIDTH           (DP1R1W2_DATA_WD),
  .ADDR_WIDTH           (DP1R1W2_ADDR_WD),
  .WORD_COUNT           (DP1R1W2_DEPTH)
)
u_dp1r1w_2s_0
(
  .clock_wr             (dp1r1w2_clka),
  .clock_rd             (dp1r1w2_clkb),
  .reset_wr_n           (rst0_n),
  .reset_rd_n           (rst0_n),
  .port0_write_address  (dp1r1w2_addra),
  .port1_read_address   (dp1r1w2_addrb),
  .port0_write_data     (dp1r1w2_dina),
  .port1_read_data      (dp1r1w2_doutb),
  .port0_write_enable   (dp1r1w2_wea),
  .port1_read_enable    (dp1r1w2_enb)
);

//dp1r1w3_2s_1
dp_ram_2s
#(
  .DATA_WIDTH           (DP1R1W3_DATA_WD),
  .ADDR_WIDTH           (DP1R1W3_ADDR_WD),
  .WORD_COUNT           (DP1R1W3_DEPTH)
)
u_dp1r1w_2s_1
(
  .clock_wr             (dp1r1w3_clka),
  .clock_rd             (dp1r1w3_clkb),
  .reset_wr_n           (rst0_n),
  .reset_rd_n           (rst0_n),
  .port0_write_address  (dp1r1w3_addra),
  .port1_read_address   (dp1r1w3_addrb),
  .port0_write_data     (dp1r1w3_dina),
  .port1_read_data      (dp1r1w3_doutb),
  .port0_write_enable   (dp1r1w3_wea),
  .port1_read_enable    (dp1r1w3_enb)
);

//--------------------------------------
// SRAM_BE
//--------------------------------------
//sram_be_0
spram
#(
  .DW         (SRAM_BE_0_DATA_WD),  // Data Width
  .AW         (SRAM_BE_0_ADDR_WD),  // Address Width
  .BN         (SRAM_BE_0_DATA_WD/8) // Byte Number - must match Data Width
)
u_sram_be_0
(
  .clk        (sram_be_0_clk),
  .addr       (sram_be_0_addr),
  .wdata      (sram_be_0_din),
  .rdata      (sram_be_0_dout),
  .ben        (sram_be_0_ben),
  .ren        (sram_be_0_en),
  .wen        (sram_be_0_we)
);

//sram_be_1
spram
#(
  .DW         (SRAM_BE_1_DATA_WD),  // Data Width
  .AW         (SRAM_BE_1_ADDR_WD),  // Address Width
  .BN         (SRAM_BE_1_DATA_WD/8) // Byte Number - must match Data Width
)
u_sram_be_1
(
  .clk        (sram_be_1_clk),
  .addr       (sram_be_1_addr),
  .wdata      (sram_be_1_din),
  .rdata      (sram_be_1_dout),
  .ben        (sram_be_1_ben),
  .ren        (sram_be_1_en),
  .wen        (sram_be_1_we)
);

