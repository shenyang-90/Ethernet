//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

//`ifndef CUSTOMER_PKG_SV
//`define CUSTOMER_PKG_SV

package customer_pkg;

  //------------------------------------------------------------------------
  // IMPORT UVM PACKAGE
  //------------------------------------------------------------------------
  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros)
  `include "uvm_macros.svh"

  // Import Cadence extenstions for UVM debug capabilities and UVM_REG test
  // extensions
  import cdns_uvm_pkg::*;

  //------------------------------------------------------------------------
  // Import UVC packages for bus interfaces. 
  // For this example we just use the AXI/APB VIPs as a double instance.
  // NOTE that the customer should import their bus UVCs here instead of these
  // APB/APB VIPs.
  //------------------------------------------------------------------------
  // Import Denali VIP packages
  import DenaliSvCdn_apb::*;
  import DenaliSvCdn_axi::*;
  // Import Denali VIP UVC wrapper packages
  import cdnAxiUvm::*;
  import cdnApbUvm::*;
  // Import Local UVC packages that wrap AXI and APB VIPs.
  import cdn_axi_vip_pkg::*;
  import cdn_apb_vip_pkg::*;

  // Import the cdn_demo TB package
  import cdn_demo_pkg::*;

  // Load the files needed for this package
  typedef customer_demo_env;  
  `include "customer_demo_sys_bus_memory_adapter.sv"
  `include "customer_demo_sys_bus_reg_adapter.sv"
  `include "cdn_usb_demo_usbssp_drd_regs.sv"
  `include "customer_demo_reg_map.sv"
  `include "customer_demo_env.sv"

endpackage : customer_pkg

//`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
