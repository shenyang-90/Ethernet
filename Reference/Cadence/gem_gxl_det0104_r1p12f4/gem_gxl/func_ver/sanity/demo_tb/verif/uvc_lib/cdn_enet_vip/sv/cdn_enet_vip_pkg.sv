//----------------------------------------------------------------------------
// Project    : cdn_enet_vip UVC
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

/*
 * File: cdn_enet_vip_pkg.sv
 *
 * This file contains the package for the cdn_enet UVC,
 * which wraps the cadence Ethernet VIP.
 */

`ifndef CDN_ENET_VIP_PKG_SV
`define CDN_ENET_VIP_PKG_SV

/*
 * Function: cdn_enet_vip_pkg
 *
 * This is the package for cdn_enet_vip UVC.
 *
 * Imported packages:-
 * - UVM class library.
 * - DDVAPI ENET SV interface and the generic Mem interface.
 * - ENET base classes.
 *
 * Included code:-
 * - UVM macros.
 * - The remaining files that make the cdn_enet UVC package.
 */
package cdn_enet_vip_pkg;

  //------------------------------------------------------------------------
  // IMPORT UVM PACKAGE
  //------------------------------------------------------------------------

  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros)
  `include "uvm_macros.svh"

  //------------------------------------------------------------------------
  // Product-Specific VIP Import
  //------------------------------------------------------------------------

  // Import the DDVAPI ENET SV interface and the generic Mem interface
  import DenaliSvEnet::*;
  import DenaliSvMem::*;

  // Include the VIP UVM base classes
  import cdnEnetUvm::*;

  //------------------------------------------------------------------------
  // Import the files which comprise this Module UVC
  //------------------------------------------------------------------------

  // Defines
  `include "cdn_enet_vip_defines.svh"

  // Other files that comprises this UVC
  `include "cdn_enet_vip_top.sv"

endpackage : cdn_enet_vip_pkg

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
