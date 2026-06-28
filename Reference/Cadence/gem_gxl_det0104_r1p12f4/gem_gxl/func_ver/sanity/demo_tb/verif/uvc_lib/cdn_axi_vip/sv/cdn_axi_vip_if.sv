//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains definition of AXI interface used by AXI VIP in
// communication with AXI wrapper inside of the delivery TB.
// Since the xHCI supports both AXI3 and 4 we had to customize the interface
// depending on the chosen configuration at upper level.
//----------------------------------------------------------------------------

`timescale 1ps/1ps
interface cdn_axi_vip_if
#(
  parameter int unsigned ADDR_WIDTH   = `CDN_AXI_VIP_ADDR_W,
  parameter int unsigned DATA_WIDTH   = `CDN_AXI_VIP_DATA_W,
  parameter int unsigned ID_WIDTH     = `CDN_AXI_VIP_ID_W,
  parameter int unsigned LOCK_WIDTH   = `CDN_AXI_VIP_LOCK_W,
  parameter int unsigned LENGTH_WIDTH = `CDN_AXI_VIP_LENGTH_W,
  parameter int unsigned USER_WIDTH   = `CDN_AXI_VIP_USER_W
)

`ifndef CDN_AXI_LPI_SUPPORT_INTERFACE
  (aclk, aresetn );
  input aclk;
  input aresetn;
`else
  (lpi_clk, aresetn );
  input lpi_clk;
  input aresetn;

  wire csysreq;
  wire csysack;
  wire cactive;
  wire aclk;
`endif
  wire awvalid;
  wire [ADDR_WIDTH-1:0] awaddr;
  wire [LENGTH_WIDTH-1:0] awlen;
  wire [2:0] awsize;
  wire [1:0] awburst;
`ifdef AXI_MASTER_WRAPPER_AXI3_PORTS
  wire [LOCK_WIDTH-1:0] awlock;
`else
  wire awlock;
`endif
  wire [3:0] awcache;
  wire [2:0] awprot;
  wire [3:0] awregion;
  wire [3:0] awqos;
  wire [ID_WIDTH-1:0] awid;
  wire awready;
  wire [USER_WIDTH-1:0] awuser;
  wire wvalid;
  wire wlast;
  wire [DATA_WIDTH-1:0] wdata;
  wire [(DATA_WIDTH/8)-1:0] wstrb;
  wire wready;
`ifdef AXI_MASTER_WRAPPER_AXI3_PORTS
  wire [ID_WIDTH-1:0] wid;
`endif
  wire [USER_WIDTH-1:0] wuser;
  wire bvalid;
  wire [1:0] bresp;
  wire [ID_WIDTH-1:0] bid;
  wire bready;
  wire [USER_WIDTH-1:0] buser;
  wire arvalid;
  wire [ADDR_WIDTH-1:0] araddr;
  wire [LENGTH_WIDTH-1:0] arlen;
  wire [2:0] arsize;
  wire [1:0] arburst;
`ifdef AXI_MASTER_WRAPPER_AXI3_PORTS
  wire [LOCK_WIDTH-1:0] arlock;
`else
  wire arlock;
`endif
  wire [3:0] arcache;
  wire [2:0] arprot;
  wire [3:0] arregion;
  wire [3:0] arqos;
  wire [ID_WIDTH-1:0] arid;
  wire arready;
  wire [USER_WIDTH-1:0] aruser;
  wire rvalid;
  wire rlast;
  wire [DATA_WIDTH-1:0] rdata;
  wire [1:0] rresp;
  wire [ID_WIDTH-1:0] rid;
  wire rready;
  wire [USER_WIDTH-1:0] ruser;

  modport activeMaster (
    input aclk,
    input aresetn,
`ifdef CDN_AXI_LPI_SUPPORT_INTERFACE
    input lpi_clk,
    input csysreq,
    output csysack,
    output cactive,
`endif
    output awvalid,
    output awaddr,
    output awlen,
    output awsize,
    output awburst,
    output awlock,
    output awcache,
    output awprot,
    output awregion,
    output awqos,
    output awid,
    input awready,
    output awuser,
    output wvalid,
    output wlast,
    output wdata,
    output wstrb,
    input wready,
`ifdef AXI_MASTER_WRAPPER_AXI3_PORTS
    output wid,
`endif
    output wuser,
    input bvalid,
    input bresp,
    input bid,
    output bready,
    input buser,
    output arvalid,
    output araddr,
    output arlen,
    output arsize,
    output arburst,
    output arlock,
    output arcache,
    output arprot,
    output arregion,
    output arqos,
    output arid,
    input arready,
    output aruser,
    input rvalid,
    input rlast,
    input rdata,
    input rresp,
    input rid,
    output rready,
    input ruser
  );

  modport activeSlave (
    input aclk,
    input aresetn,
`ifdef CDN_AXI_LPI_SUPPORT_INTERFACE
    input lpi_clk,
    input csysreq,
    output csysack,
    output cactive,
`endif
    input awvalid,
    input awaddr,
    input awlen,
    input awsize,
    input awburst,
    input awlock,
    input awcache,
    input awprot,
    input awregion,
    input awqos,
    input  awid,
    output awready,
    input awuser,
    input wvalid,
    input wlast,
    input wdata,
    input wstrb,
    output wready,
`ifdef AXI_MASTER_WRAPPER_AXI3_PORTS
    input wid,
`endif
    input wuser,
    output bvalid,
    output bresp,
    output bid,
    input bready,
    output buser,
    input arvalid,
    input araddr,
    input arlen,
    input arsize,
    input arburst,
    input arlock,
    input arcache,
    input arprot,
    input arregion,
    input arqos,
    input arid,
    output arready,
    input aruser,
    output rvalid,
    output rlast,
    output rdata,
    output rresp,
    output rid,
    input rready,
    output ruser
  );

  modport passiveMaster (
    input aclk,
    input aresetn,
`ifdef CDN_AXI_LPI_SUPPORT_INTERFACE
    input lpi_clk,
    input csysreq,
    input csysack,
    input cactive,
`endif
    input awvalid,
    input awaddr,
    input awlen,
    input awsize,
    input awburst,
    input awlock,
    input awcache,
    input awprot,
    input awregion,
    input awqos,
    input awid,
    input awready,
    input awuser,
    input wvalid,
    input wlast,
    input wdata,
    input wstrb,
    input wready,
`ifdef AXI_MASTER_WRAPPER_AXI3_PORTS
    input wid,
`endif
    input wuser,
    input bvalid,
    input bresp,
    input bid,
    input bready,
    input buser,
    input arvalid,
    input araddr,
    input arlen,
    input arsize,
    input arburst,
    input arlock,
    input arcache,
    input arprot,
    input arregion,
    input arqos,
    input arid,
    input arready,
    input aruser,
    input rvalid,
    input rlast,
    input rdata,
    input rresp,
    input rid,
    input rready,
    input ruser
  );

  modport passiveSlave (
    input aclk,
    input aresetn,
`ifdef CDN_AXI_LPI_SUPPORT_INTERFACE
    input lpi_clk,
    input csysreq,
    input csysack,
    input cactive,
`endif
    input awvalid,
    input awaddr,
    input awlen,
    input awsize,
    input awburst,
    input awlock,
    input awcache,
    input awprot,
    input awregion,
    input awqos,
    input awid,
    input awready,
    input awuser,
    input wvalid,
    input wlast,
    input wdata,
    input wstrb,
    input wready,
`ifdef AXI_MASTER_WRAPPER_AXI3_PORTS
    input wid,
`endif
    input wuser,
    input bvalid,
    input bresp,
    input bid,
    input bready,
    input buser,
    input arvalid,
    input araddr,
    input arlen,
    input arsize,
    input arburst,
    input arlock,
    input arcache,
    input arprot,
    input arregion,
    input arqos,
    input arid,
    input arready,
    input aruser,
    input rvalid,
    input rlast,
    input rdata,
    input rresp,
    input rid,
    input rready,
    input ruser
  );

`ifdef CDN_AXI_LPI_SUPPORT_INTERFACE
  modport activeClockController (
    input lpi_clk,
    input aresetn,
    output csysreq,
    input csysack,
    input cactive,
    output aclk
  );

  modport passiveClockController (
    input lpi_clk,
    input aresetn,
    input csysreq,
    input csysack,
    input cactive,
    input aclk
  );

  // Low Power Interface signals
  reg den_csysreq = 'bz;
  assign csysreq = den_csysreq;
  reg den_csysack = 'bz;
  assign csysack = den_csysack;
  reg den_cactive = 'bz;
  assign cactive = den_cactive;
  reg den_aclk = 'bz;
  assign aclk = den_aclk;
`endif

  // Master Drivers
  reg den_awvalid = 'bz;
  assign awvalid = den_awvalid;
  reg [ADDR_WIDTH-1:0] den_awaddr = '{default:'bz};
  assign awaddr = den_awaddr;
  reg [7:0] den_awlen = '{default:'bz};
  assign awlen = den_awlen;
  reg [2:0] den_awsize = '{default:'bz};
  assign awsize = den_awsize;
  reg [1:0] den_awburst = '{default:'bz};
  assign awburst = den_awburst;
  reg den_awlock = 'bz;
  assign awlock = den_awlock;
  reg [3:0] den_awcache = '{default:'bz};
  assign awcache = den_awcache;
  reg [2:0] den_awprot = '{default:'bz};
  assign awprot = den_awprot;
  reg [3:0] den_awregion = '{default:'bz};
  assign awregion = den_awregion;
  reg [3:0] den_awqos = '{default:'bz};
  assign awqos = den_awqos;
  reg [ID_WIDTH-1:0] den_awid = '{default:'bz};
  assign awid = den_awid;
  reg [USER_WIDTH-1:0] den_awuser = '{default:'bz};
  assign awuser = den_awuser;
  reg den_wvalid = 'bz;
  assign wvalid = den_wvalid;
  reg den_wlast = 'bz;
  assign wlast = den_wlast;
  reg [DATA_WIDTH-1:0] den_wdata = '{default:'bz};
  assign wdata = den_wdata;
  reg [(DATA_WIDTH/8)-1:0] den_wstrb = '{default:'bz};
  assign wstrb = den_wstrb;
  reg [USER_WIDTH-1:0] den_wuser = '{default:'bz};
  assign wuser = den_wuser;
  reg den_bready = 'bz;
  assign bready = den_bready;
  reg den_arvalid = 'bz;
  assign arvalid = den_arvalid;
  reg [ADDR_WIDTH-1:0] den_araddr = '{default:'bz};
  assign araddr = den_araddr;
  reg [7:0] den_arlen = '{default:'bz};
  assign arlen = den_arlen;
  reg [2:0] den_arsize = '{default:'bz};
  assign arsize = den_arsize;
  reg [1:0] den_arburst = '{default:'bz};
  assign arburst = den_arburst;
  reg den_arlock = 'bz;
  assign arlock = den_arlock;
  reg [3:0] den_arcache = '{default:'bz};
  assign arcache = den_arcache;
  reg [2:0] den_arprot = '{default:'bz};
  assign arprot = den_arprot;
  reg [3:0] den_arregion = '{default:'bz};
  assign arregion = den_arregion;
  reg [3:0] den_arqos = '{default:'bz};
  assign arqos = den_arqos;
  reg [ID_WIDTH-1:0] den_arid = '{default:'bz};
  assign arid = den_arid;
  reg [USER_WIDTH-1:0] den_aruser = '{default:'bz};
  assign aruser = den_aruser;
  reg den_rready = 'bz;
  assign rready = den_rready;

  // Slave Drivers
  reg den_awready = 'bz;
  assign awready = den_awready;
  reg den_wready = 'bz;
  assign wready = den_wready;
  reg den_bvalid = 'bz;
  assign bvalid = den_bvalid;
  reg [1:0] den_bresp = '{default:'bz};
  assign bresp = den_bresp;
  reg [ID_WIDTH-1:0] den_bid = '{default:'bz};
  assign bid = den_bid;
  reg [USER_WIDTH-1:0] den_buser = '{default:'bz};
  assign buser = den_buser;
  reg den_arready = 'bz;
  assign arready = den_arready;
  reg den_rvalid = 'bz;
  assign rvalid = den_rvalid;
  reg den_rlast = 'bz;
  assign rlast = den_rlast;
  reg [DATA_WIDTH-1:0] den_rdata = '{default:'bz};
  assign rdata = den_rdata;
  reg [1:0] den_rresp = '{default:'bz};
  assign rresp = den_rresp;
  reg [ID_WIDTH-1:0] den_rid = '{default:'bz};
  assign rid = den_rid;
  reg [USER_WIDTH-1:0] den_ruser = '{default:'bz};
  assign ruser = den_ruser;

  function automatic string getPath();
    string getDutInterfacePath;
    int length;
    $sformat(getDutInterfacePath,"%m");
    length = getDutInterfacePath.len() - 9;
    $sformat(getPath,"%s",getDutInterfacePath.substr(0,length));
  endfunction : getPath

endinterface

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
