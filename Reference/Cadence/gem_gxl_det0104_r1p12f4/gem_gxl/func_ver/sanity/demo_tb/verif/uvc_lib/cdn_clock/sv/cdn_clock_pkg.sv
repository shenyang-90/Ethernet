//----------------------------------------------------------------------------
// Project    : cdn_clock UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description: 
// This file is the top level file which imports all of the components of the
// UVC and declares them as a package.
//----------------------------------------------------------------------------

`ifndef CDN_CLOCK_PKG_SV
`define CDN_CLOCK_PKG_SV

`timescale 1ns / 1ps
  
package cdn_clock_pkg;

    //------------------------------------------------------------------------
    // IMPORT UVM PACKAGE
    //------------------------------------------------------------------------
    // UVM class library compiled in a package
    import uvm_pkg::*;

    // Bring in the rest of the library (macros)
    `include "uvm_macros.svh"

    //------------------------------------------------------------------------
    // Import the files which comprise this UVC
    //------------------------------------------------------------------------
    `include "cdn_clock_monitor.sv"
    `include "cdn_clock_driver.sv"
    `include "cdn_clock_agent.sv"

endpackage : cdn_clock_pkg

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
