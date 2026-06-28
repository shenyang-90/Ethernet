//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file contains the package for the cdn_apb_vip UVC which wraps the
// Cadence APB VIP.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_pkg.sv
 *
 * This file contains the package for the cdn_apb_vip UVC, which wraps the
 * Cadence APB VIP.
 */

`ifndef CDN_APB_VIP_PKG_SV
`define CDN_APB_VIP_PKG_SV

/*
 * Function: cdn_apb_vip_pkg
 *
 * This is the package for cdn_apb_vip UVC.
 *
 * Imported packages:-
 * - UVM class library.
 * - DDVAPI CDN_APB SV interface.
 * - Denali generic Mem interface.
 * - APB VIP UVM base classe
 *
 * Included code:-
 * - UVM macros.
 * - The remaining files that make the cdn_apb UVC package.
 */
package cdn_apb_vip_pkg;

  // Define the APB IF type i.e. APB3 or APB4 - default to APB4 unless APB3 has
  // be preset before loading this package.
  // Note that this is done with defines for the virtual interface declaration
  // inside the master/slave agents.
  `ifndef CDN_APB_VIP_IF_APB3
    `ifndef CDN_APB_VIP_SIMPLE_IF
      `define CDN_APB_VIP_IF_APB4
    `endif
  `endif

  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros)
  `include "uvm_macros.svh"

  // Import the DDVAPI CDN_APB SV interface and the generic Mem interface
  import DenaliSvCdn_apb::*;
  import DenaliSvMem::*;

  // Include the VIP UVM base classes
  import cdnApbUvm::*;

  // Bring in the remaing files that make this APB VIP UVC package
  `include "cdn_apb_vip_top.sv"

endpackage : cdn_apb_vip_pkg

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
