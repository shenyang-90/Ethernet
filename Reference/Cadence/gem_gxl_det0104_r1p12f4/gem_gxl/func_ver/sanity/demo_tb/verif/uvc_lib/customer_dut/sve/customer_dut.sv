//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
//
// The purpose of this file it to detail the customer part of the extended
// base IP TB. The idea for this file is an example customer environment where
// the customer extends the TB and add customer specific information, such as
// propriety bus bridges.
//
//----------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Import our customer package containing all customer specific factory overrides
//------------------------------------------------------------------------------
import customer_pkg::*;

//------------------------------------------------------------------------------
// Include customer specific UVC interfaces
//------------------------------------------------------------------------------
// Note that the interfaces for this example are already included in the base
// demo TB.

//------------------------------------------------------------------------------
// Include customer specific tests.
//------------------------------------------------------------------------------
`include "customer_test_lib.sv"

//------------------------------------------------------------------------------
// Customer sys bus interface instance
//------------------------------------------------------------------------------
cdn_axi_vip_if customer_sys_bus_if   (clk0,rst1_n);

//------------------------------------------------------------------------------
// Customer register bus interfaces
//------------------------------------------------------------------------------
cdnApb4Interface #(.NUM_OF_SLAVES(`CDN_DEMO_APB_NUM_OF_SLAVES),.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH),.DATA_WIDTH(32)) customer_reg_bus_if (clk0,rst0_n);
`createCdnApb4SlaveInterface(customer_reg_bus_if,0,`CDN_DEMO_APB_ADDRESS_WIDTH)
`createCdnApb4SlaveInterface(customer_reg_bus_if,1,`CDN_DEMO_APB_ADDRESS_WIDTH)

//------------------------------------------------------------------------------
// For passive mode, connect the AXI and APB SV IFs from the main demo_tb to
// the correct signals down at the bridge level.
// remember that the AXI IF is already connected to tb signals, it is these signals
// we need to connect to as they currently are not connected due to the DUT
// being replaced with CUSTOMER_DUT. Having this connection allows the
// customer to see the AXI side of the instantiated bridge, which can aid
// debug.
//------------------------------------------------------------------------------
  assign awvalid  = u_customer_wrapper.awvalid;
  assign awaddr   = u_customer_wrapper.awaddr;
  assign awlen    = u_customer_wrapper.awlen;
  assign awsize   = u_customer_wrapper.awsize;
  assign awburst  = u_customer_wrapper.awburst;
  assign awlock   = u_customer_wrapper.awlock;
  assign awcache  = u_customer_wrapper.awcache;
  assign awprot   = u_customer_wrapper.awprot;
  assign awregion = u_customer_wrapper.awregion;
  assign awqos    = u_customer_wrapper.awqos;
  assign awid     = u_customer_wrapper.awid;
  assign awready  = u_customer_wrapper.awready;
  assign wvalid   = u_customer_wrapper.wvalid;
  assign wlast    = u_customer_wrapper.wlast;
  assign wdata    = u_customer_wrapper.wdata;
  assign wstrb    = u_customer_wrapper.wstrb;
  assign wready   = u_customer_wrapper.wready;
  assign wuser    = u_customer_wrapper.wuser;
  assign bvalid   = u_customer_wrapper.bvalid;
  assign bresp    = u_customer_wrapper.bresp;
  assign bready   = u_customer_wrapper.bready;
  assign arvalid  = u_customer_wrapper.arvalid;
  assign araddr   = u_customer_wrapper.araddr;
  assign arlen    = u_customer_wrapper.arlen;
  assign arsize   = u_customer_wrapper.arsize;
  assign arburst  = u_customer_wrapper.arburst;
  assign arlock   = u_customer_wrapper.arlock;
  assign arcache  = u_customer_wrapper.arcache;
  assign arprot   = u_customer_wrapper.arprot;
  assign arregion = u_customer_wrapper.arregion;
  assign arqos    = u_customer_wrapper.arqos;
  assign arid     = u_customer_wrapper.arid;
  assign arready  = u_customer_wrapper.arready;
  assign rvalid   = u_customer_wrapper.rvalid;
  assign rlast    = u_customer_wrapper.rlast;
  assign rdata    = u_customer_wrapper.rdata;
  assign rresp    = u_customer_wrapper.rresp;
  assign rid      = u_customer_wrapper.rid;
  assign rready   = u_customer_wrapper.rready;

// APB for passive mode
  assign apb_reg_if_slave0.paddr   = u_customer_wrapper.paddr;
  assign apb_reg_if_slave0.pready  = u_customer_wrapper.pready;
  assign apb_reg_if_slave0.pwdata  = u_customer_wrapper.pwdata;
  assign apb_reg_if_slave0.prdata  = u_customer_wrapper.prdata;
  assign apb_reg_if_slave0.pwrite  = u_customer_wrapper.pwrite;
  assign apb_reg_if_slave0.penable = u_customer_wrapper.penable;
  assign apb_reg_if_slave0.psel    = u_customer_wrapper.psel;
  assign apb_reg_if_slave0.pstrb   = u_customer_wrapper.pstrb;
  assign apb_reg_if_slave0.pslverr = u_customer_wrapper.pslverr;
  assign apb_reg_if_slave0.pprot   = u_customer_wrapper.pprot;

//------------------------------------------------------------------------------
// Use factory overrides to replace the key components of the VE with customer specific extensions.
//------------------------------------------------------------------------------
initial begin

  // Override the base demo env components with customer specific components
  factory.set_type_override_by_type(cdn_demo_pkg::cdn_demo_sys_bus_memory_adapter::get_type(), customer_pkg::customer_demo_sys_bus_memory_adapter::get_type());
  factory.set_type_override_by_type(cdn_demo_pkg::cdn_demo_sys_bus_reg_adapter::get_type(), customer_pkg::customer_demo_sys_bus_reg_adapter::get_type());
  factory.set_type_override_by_type(cdn_demo_pkg::cdn_demo_env::get_type(), customer_pkg::customer_demo_env::get_type());

  // Customer sys bus connections
  uvm_config_db#(virtual interface cdn_axi_vip_if)::set(null,"*customer_sys_bus_env.active_slave",  "vif",customer_sys_bus_if);
  uvm_config_db#(virtual interface cdn_axi_vip_if)::set(null,"*customer_sys_bus_env.passive_master","vif",customer_sys_bus_if);

  // Customer reg bus connetions
  uvm_config_db#(virtual interface cdnApb4MasterInterface#(.NUM_OF_SLAVES(`CDN_DEMO_APB_NUM_OF_SLAVES),.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH),.DATA_WIDTH(32)))::set(null,"*customer_reg_bus_env.master_agent", "vif",  customer_reg_bus_if.master);
  uvm_config_db#(virtual interface cdnApb4SlaveInterface#(                                             .ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH)                ))::set(null,"*customer_reg_bus_env.slave_agent[0]", "vif", customer_reg_bus_if_slave0);
  uvm_config_db#(virtual interface cdnApb4SlaveInterface#(                                             .ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH)                ))::set(null,"*customer_reg_bus_env.slave_agent[1]", "vif", customer_reg_bus_if_slave1);

end

//------------------------------------------------------------------------------
// Instance the customer_wrapper and set the parameters for the RAM
// integration block - note the RAM integration block is not used and the
// inputs are tied off to 0, including no connections to any RAMs. This
// difference in the customer environment to the RAM integration testing
// environment allows a specific test to be created to ensure the APB accesses
// to the customer_wrapper work correctly, and will denote that zero RAMs are
// connected.
//------------------------------------------------------------------------------

// Inputs to MASTER APB Bank
parameter NUM_SRAM              = 12;
parameter NUM_DP1R1W            = 7;
parameter NUM_DP2R2W            = 4;
parameter NUM_RF                = 0;
parameter NUM_SRAM_BE           = 1;
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
// Demo Top Level Module
//--------------------------------------

customer_wrapper #(

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

) u_customer_wrapper (

  //------------------------------------
  // APB
  //------------------------------------
  .pclk(clk0),
  .presetn(rst0_n),
  .paddr(customer_reg_bus_if_slave1.paddr[12:0]),
  .pprot(3'd0),
  .psel(customer_reg_bus_if_slave1.psel),
  .penable(customer_reg_bus_if_slave1.penable),
  .pwrite(customer_reg_bus_if_slave1.pwrite),
  .pwdata(customer_reg_bus_if_slave1.pwdata),
  .pstrb(4'hf),
  .pready(customer_reg_bus_if_slave1.pready),
  .prdata(customer_reg_bus_if_slave1.prdata),
  .pslverr(customer_reg_bus_if_slave1.pslverr),

  .interrupt(interrupt),

  //------------------------------------
  // SRAM
  //------------------------------------
  //sram0
  .sram0_clk  (1'b0),
  .sram0_addr (),
  .sram0_din  (),
  .sram0_en   (),
  .sram0_we   (),
  .sram0_dout ({SRAM0_DATA_WD{1'b0}}),
  //sram1
  .sram1_clk  (1'b0),
  .sram1_addr (),
  .sram1_din  (),
  .sram1_en   (),
  .sram1_we   (),
  .sram1_dout ({SRAM1_DATA_WD{1'b0}}),
  //------------------------------------
  // SRAM_2S
  //------------------------------------
  //sram2_2s_0
  .sram2_clk  (1'b0),
  .sram2_addr (),
  .sram2_din  (),
  .sram2_en   (),
  .sram2_we   (),
  .sram2_dout ({SRAM2_DATA_WD{1'b0}}),
  //sram3_2s_1
  .sram3_clk  (1'b0),
  .sram3_addr (),
  .sram3_din  (),
  .sram3_en   (),
  .sram3_we   (),
  .sram3_dout ({SRAM3_DATA_WD{1'b0}}),

  //------------------------------------
  // DP1R1W
  //------------------------------------
  //dp1r1w0
  .dp1r1w0_clka   (1'b0),
  .dp1r1w0_clkb   (1'b0),
  .dp1r1w0_addra  (),
  .dp1r1w0_addrb  (),
  .dp1r1w0_dina   (),
  .dp1r1w0_doutb  ({DP1R1W0_DATA_WD{1'b0}}),
  .dp1r1w0_ena    (),
  .dp1r1w0_enb    (),
  .dp1r1w0_wea    (),
  //dp1r1w1
  .dp1r1w1_clka   (1'b0),
  .dp1r1w1_clkb   (1'b0),
  .dp1r1w1_addra  (),
  .dp1r1w1_addrb  (),
  .dp1r1w1_dina   (),
  .dp1r1w1_doutb  ({DP1R1W1_DATA_WD{1'b0}}),
  .dp1r1w1_ena    (),
  .dp1r1w1_enb    (),
  .dp1r1w1_wea    (),
  //------------------------------------
  // DP1R1W_2S
  //------------------------------------
  //dp1r1w2_2s_0
  .dp1r1w2_clka   (1'b0),
  .dp1r1w2_clkb   (1'b0),
  .dp1r1w2_addra  (),
  .dp1r1w2_addrb  (),
  .dp1r1w2_dina   (),
  .dp1r1w2_doutb  ({DP1R1W2_DATA_WD{1'b0}}),
  .dp1r1w2_ena    (),
  .dp1r1w2_enb    (),
  .dp1r1w2_wea    (),
  //dp1r1w3_2s_1
  .dp1r1w3_clka   (1'b0),
  .dp1r1w3_clkb   (1'b0),
  .dp1r1w3_addra  (),
  .dp1r1w3_addrb  (),
  .dp1r1w3_dina   (),
  .dp1r1w3_doutb  ({DP1R1W3_DATA_WD{1'b0}}),
  .dp1r1w3_ena    (),
  .dp1r1w3_enb    (),
  .dp1r1w3_wea    (),

  //------------------------------------
  // SRAM_BE
  //------------------------------------
  //sram_be_0
  .sram_be_0_clk  (1'b0),
  .sram_be_0_addr (),
  .sram_be_0_din  (),
  .sram_be_0_ben  (),
  .sram_be_0_en   (),
  .sram_be_0_we   (),
  .sram_be_0_dout ({SRAM_BE_0_DATA_WD{1'b0}}),
  //sram_be_1
  .sram_be_1_clk  (1'b0),
  .sram_be_1_addr (),
  .sram_be_1_din  (),
  .sram_be_1_ben  (),
  .sram_be_1_en   (),
  .sram_be_1_we   (),
  .sram_be_1_dout ({SRAM_BE_1_DATA_WD{1'b0}}),

  //------------------------------------
  // AXI I/F
  //------------------------------------
  .awuser(customer_sys_bus_if.awuser),
  .awid(customer_sys_bus_if.awid),
  .awaddr(customer_sys_bus_if.awaddr),
  .awlen(customer_sys_bus_if.awlen),
  .awsize(customer_sys_bus_if.awsize),
  .awburst(customer_sys_bus_if.awburst),
  .awlock(customer_sys_bus_if.awlock),
  .awcache(customer_sys_bus_if.awcache),
  .awprot(customer_sys_bus_if.awprot),
  .awqos(customer_sys_bus_if.awqos),
  .awregion(customer_sys_bus_if.awregion),
  .awvalid(customer_sys_bus_if.awvalid),
  .awready(customer_sys_bus_if.awready),

  // AXI W  channel signals (Write data channel)
  .wuser(customer_sys_bus_if.wuser),
  .wdata(customer_sys_bus_if.wdata),
  .wstrb(customer_sys_bus_if.wstrb),
  .wlast(customer_sys_bus_if.wlast),
  .wvalid(customer_sys_bus_if.wvalid),
  .wready(customer_sys_bus_if.wready),
   // AXI B  channel signals (Write response channel)
  .buser(customer_sys_bus_if.buser),
  .bresp(customer_sys_bus_if.bresp),
  .bvalid(customer_sys_bus_if.bvalid),
  .bready(customer_sys_bus_if.bready),

  // AXI AR channel signals (Read address channel)
  .arid(customer_sys_bus_if.arid),
  .araddr(customer_sys_bus_if.araddr),
  .arlen(customer_sys_bus_if.arlen),
  .arsize(customer_sys_bus_if.arsize),
  .arburst(customer_sys_bus_if.arburst),
  .arlock(customer_sys_bus_if.arlock),
  .arcache(customer_sys_bus_if.arcache),
  .arprot(customer_sys_bus_if.arprot),
  .arqos(customer_sys_bus_if.arqos),
  .arregion(customer_sys_bus_if.arregion),
  .arvalid(customer_sys_bus_if.arvalid),
  .arready(customer_sys_bus_if.arready),

   // AXI R  channel signals (Read data channel)
  .rid(customer_sys_bus_if.rid),
  .rdata(customer_sys_bus_if.rdata),
  .rresp(customer_sys_bus_if.rresp),
  .rlast(customer_sys_bus_if.rlast),
  .rvalid(customer_sys_bus_if.rvalid),
  .rready(customer_sys_bus_if.rready)

);
