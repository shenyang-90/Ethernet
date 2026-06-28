//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2013 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description: 
// This file is the top level file which imports all of the components of the
// UVC and declares them as a package.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_PKG_SV
`define CDN_DEMO_PKG_SV

package cdn_demo_pkg;

   //------------------------------------------------------------------------
   // IMPORT UVM PACKAGE
   //------------------------------------------------------------------------
   // UVM class library compiled in a package
   import uvm_pkg::*;
   import cdns_uvm_pkg::*;

   // Bring in the rest of the library (macros)
   `include "uvm_macros.svh"

   // Import the required UVC packages
   import cdn_reset_pkg::*;
   import cdn_clock_pkg::*;

   // Import the DDVAPI CDN_APB SV interface and the generic Mem interface
   import DenaliSvCdn_apb::*;
   import DenaliSvCdn_axi::*;
   import DenaliSvMem::*; 

   // Include the VIP UVM base classes
   import cdnApbUvm::*;   
   import cdnAxiUvm::*;  

   // Import Local UVC packages
   import cdn_axi_vip_pkg::*;
   import cdn_apb_vip_pkg::*;

   //------------------------------------------------------------------------
   // Import the files which comprise this Module UVC
   //------------------------------------------------------------------------

   typedef class cdn_demo_env;

   `include "cdn_demo_defines.svh"
   `include "cdn_ram_stub_regs_map.sv"
   `include "cdn_reset_sequence_lib.sv"
   `include "cdn_demo_misc_signals_driver.sv"
   `include "cdn_demo_virtual_sequencer.sv"
   `include "cdn_demo_sys_bus_reg_adapter.sv"
   `include "cdn_demo_sys_bus_memory_adapter.sv"
   `include "cdn_demo_sequence_lib.sv"
   `include "cdn_demo_config_object.sv"
   `include "cdn_demo_report_catcher.sv"
   `include "cdn_demo_env.sv"

endpackage : cdn_demo_pkg

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
