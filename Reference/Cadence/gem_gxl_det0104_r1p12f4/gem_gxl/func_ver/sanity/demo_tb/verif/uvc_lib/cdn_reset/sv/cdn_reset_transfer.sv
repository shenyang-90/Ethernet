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
// This file defines the basic transfer item for the cdn_reset OVC.
//----------------------------------------------------------------------------

`ifndef CDN_RESET_TRANSFER_SV
`define CDN_RESET_TRANSFER_SV

class cdn_reset_transfer extends uvm_sequence_item;

    //------------------------------------------------------------------------
    // CONTROL MEMBER VARIABLES.
    //------------------------------------------------------------------------

    // Reset Duration in clock cycles.
    rand int unsigned reset_duration;

    //------------------------------------------------------------------------
    // CONSTRAINT BLOCKS.
    //------------------------------------------------------------------------

    constraint reset_duration_c {
        reset_duration inside {[1:1000]};
    }

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The field marcos are required for packing/unpacking and checking.
    `uvm_object_utils_begin(cdn_reset_transfer)
        `uvm_field_int(reset_duration,UVM_ALL_ON)
    `uvm_object_utils_end

    //------------------------------------------------------------------------
    // STATUS MEMBER VARIABLES.
    //------------------------------------------------------------------------

    // The monitor should update this member variable with the simulation time
    // value when this packet is observed.
    // This is useful for checking DUT latencies.
    time observation_time = 0;
   
    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------
    function new (string name = "cdn_reset_transfer_inst");
        super.new(name);
    endfunction : new
    
endclass : cdn_reset_transfer

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
