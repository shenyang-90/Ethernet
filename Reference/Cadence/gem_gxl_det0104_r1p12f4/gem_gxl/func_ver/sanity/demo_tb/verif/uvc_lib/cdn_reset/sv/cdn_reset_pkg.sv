//----------------------------------------------------------------------------
// Project    : cdn_reset UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file is the top level file which imports all of the components of the
// UVC and declares them as a package.
//----------------------------------------------------------------------------

`ifndef CDN_RESET_PKG_SV
`define CDN_RESET_PKG_SV

package cdn_reset_pkg;

    //------------------------------------------------------------------------
    // IMPORT UVM PACKAGE
    //------------------------------------------------------------------------
 
    // UVM class library compiled in a package
    import uvm_pkg::*;

    // Bring in the rest of the library (macros)
    `include "uvm_macros.svh"

    //------------------------------------------------------------------------
    // Import the files which comprise this OVC
    //------------------------------------------------------------------------
    
    `include "cdn_reset_defines.svh"
    `include "cdn_reset_transfer.sv"
    `include "cdn_reset_monitor.sv"
    `include "cdn_reset_sequencer.sv"
    `include "cdn_reset_driver.sv"
    `include "cdn_reset_agent.sv"
    `include "cdn_reset_env.sv"
    `include "cdn_reset_sequence_lib.sv"
    `include "cdn_reset_scoreboard.sv"

endpackage : cdn_reset_pkg

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
