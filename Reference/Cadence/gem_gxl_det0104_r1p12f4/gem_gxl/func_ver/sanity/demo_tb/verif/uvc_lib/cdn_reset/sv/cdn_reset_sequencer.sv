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
// This file creates an UVM compliant sequencer.
//----------------------------------------------------------------------------

`ifndef CDN_RESET_SEQUENCER_SV
`define CDN_RESET_SEQUENCER_SV

class cdn_reset_sequencer extends uvm_sequencer #(cdn_reset_transfer);

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------
    `uvm_component_utils(cdn_reset_sequencer)

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method and register the transfer item.
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : cdn_reset_sequencer

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
