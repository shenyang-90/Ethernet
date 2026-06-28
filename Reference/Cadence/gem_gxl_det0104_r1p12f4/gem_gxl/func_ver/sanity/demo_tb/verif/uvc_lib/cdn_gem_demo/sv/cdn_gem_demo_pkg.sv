//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
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
 * File: cdn_gem_demo_pkg.sv
 *
 * This file contains the package for the cdn_gem_demo UVC.
 */

`ifndef CDN_GEM_DEMO_PKG_SV
  `define CDN_GEM_DEMO_PKG_SV

/*
 * Function: cdn_gem_demo_pkg
 *
 * This is the package for cdn_gem_demo UVC.
 *
 * Imported packages:-
 * - UVM class library.
 * - The generic Denali Mem interface.
 * - Reset and clock packages.
 * - Needed VIP packages and base classes.
 * - The cdn_demo UVC package.
 *
 * Included code:-
 * - UVM macros.
 * - The remaining files that make the cdn_enet UVC package.
 */
package cdn_gem_demo_pkg;

  //------------------------------------------------------------------------
  // IMPORT UVM PACKAGE
  //------------------------------------------------------------------------

  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros)
  `include "uvm_macros.svh"

  //------------------------------------------------------------------------
  // VIPs Related Import
  //------------------------------------------------------------------------

  // Import the generic Denali Mem interface
  import DenaliSvMem::*;

  // Import reset and clock UVC packages
  import cdn_reset_pkg::*;
  import cdn_clock_pkg::*;

  // Import APB VIP related
  import DenaliSvCdn_apb::*;
  import cdnApbUvm::*;
  import cdn_apb_vip_pkg::*;

  // Import AXI VIP related
  import DenaliSvCdn_axi::*;
  import cdnAxiUvm::*;
  import cdn_axi_vip_pkg::*;

  // Import ENET VIP related
  import DenaliSvEnet::*;
  import cdnEnetUvm::*;
  import cdn_enet_vip_pkg::*;

  //------------------------------------------------------------------------
  // cdn_demo UVC Package Import
  //------------------------------------------------------------------------

  import cdn_demo_pkg::*;

  //------------------------------------------------------------------------
  // Import the files which comprise this Module UVC
  //------------------------------------------------------------------------

  // GEM register definitions
  import cdns_uvm_pkg::*;
  import cdns_uvm_addons::*;
  `include "gem_regmodel.sv"

  // GEM DEMO UVC SV
  `include "cdn_gem_demo_defines.svh"
  `include "cdn_gem_demo_interface_adapter.sv"
  `include "cdn_gem_demo_sb.sv"
  `include "cdn_gem_demo_config_object.sv"
  `include "cdn_gem_demo_virtual_sequencer.sv"
  `include "cdn_gem_demo_virtual_seq_lib.sv"
  `include "cdn_gem_demo_tests_virtual_seq_lib.sv"
  `include "cdn_gem_demo_env.sv"

endpackage : cdn_gem_demo_pkg

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
