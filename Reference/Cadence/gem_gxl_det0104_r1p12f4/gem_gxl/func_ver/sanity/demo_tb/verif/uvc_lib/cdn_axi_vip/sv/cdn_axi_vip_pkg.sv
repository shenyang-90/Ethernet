//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the package for the cdn_axi_vip UVC which wraps the 
// Cadence AXI VIP.
//----------------------------------------------------------------------------

/*
 * File: cdn_axi_vip_pkg.sv
 * 
 * This file contains the package for the cdn_axi_vip UVC, which wraps the
 * Cadence AXI VIP.
 */

`ifndef CDN_AXI_VIP_PKG_SV
`define CDN_AXI_VIP_PKG_SV

/*
 * Function: cdn_axi_vip_pkg
 * 
 * This is the package for cdn_axi_vip UVC.
 * 
 * Imported packages:-
 * - UVM class library.
 * - DDVAPI CDN_AXI SV interface.
 * - Denali generic Mem interface.
 * - AXI VIP UVM base classe
 * 
 * Included code:-
 * - DUT defs.
 * - UVM macros.
 * - The remaining files that make the cdn_axi_vip UVC package.
 */
package cdn_axi_vip_pkg;

  // Include the DUT defs
  `include "gem_gxl_defs.v"

  // Define the default AXI ADDRESS width unless already defined.
  // Note that the default value can be overloaded using the 
  // parameters in the env and the interface.
  `ifndef CDN_AXI_VIP_ADDR_W
   `define CDN_AXI_VIP_ADDR_W `gem_dma_addr_width
  `endif

  // Define the default AXI DATA width unless already defined.
  // Note that the default value can be overloaded using the 
  // parameters in the env and the interface.
  `ifndef CDN_AXI_VIP_DATA_W
   `define CDN_AXI_VIP_DATA_W `gem_dma_bus_width
  `endif

  // Define the default AXI LOCK width unless already defined.
  // Note that the default value can be overloaded using the 
  // parameters in the env and the interface.
  `ifndef CDN_AXI_VIP_LOCK_W
   `define CDN_AXI_VIP_LOCK_W 2
  `endif

  // Define the default AXI LENGTH width unless already defined.
  // Note that the default value can be overloaded using the 
  // parameters in the env and the interface.
  `ifndef CDN_AXI_VIP_LENGTH_W
   `define CDN_AXI_VIP_LENGTH_W 8
  `endif

  // Define the default AXI ID width unless already defined.
  // Note that the default value can be overloaded using the 
  // parameters in the env and the interface.
  `ifndef CDN_AXI_VIP_ID_W
   `define CDN_AXI_VIP_ID_W 4
  `endif

  // Define the default AXI USER width unless already defined.
  // Note that the default value can be overloaded using the 
  // parameters in the env and the interface.
  `ifndef CDN_AXI_VIP_USER_W
   `define CDN_AXI_VIP_USER_W 32
  `endif

  // Define support for the AXI3 protocol specification.
  `ifndef AXI_MASTER_WRAPPER_AXI3_PORTS
    `define AXI_MASTER_WRAPPER_AXI3_PORTS
  `endif

  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros)
  `include "uvm_macros.svh"

  // Import the DDVAPI CDN_AXI SV interface and the generic Mem interface
  import DenaliSvCdn_axi::*;
  import DenaliSvMem::*;

  // Include the AXI VIP UVM base classes
  import cdnAxiUvm::*;

  // Bring in the remaining files that make this AXI VIP UVC package
  `include "cdn_axi_vip_top.sv"

endpackage : cdn_axi_vip_pkg

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
