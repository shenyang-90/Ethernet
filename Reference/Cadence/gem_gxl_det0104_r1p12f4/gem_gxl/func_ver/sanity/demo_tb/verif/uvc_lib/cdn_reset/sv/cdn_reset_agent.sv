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
// This file contains the detailed description of the cdn_reset UVC agent.
//----------------------------------------------------------------------------

`ifndef CDN_RESET_AGENT_SV
`define CDN_RESET_AGENT_SV

class cdn_reset_agent extends uvm_agent;

    //------------------------------------------------------------------------
    // MEMBER VARIABLES.
    //------------------------------------------------------------------------

    // This member variable is an identifier for the agent.
    protected int agent_id;

    //------------------------------------------------------------------------
    // CONTROL MEMBER VARIABLES.
    //------------------------------------------------------------------------

    // This member variable controls if the agent is active or passive.
    protected uvm_active_passive_enum is_active = UVM_ACTIVE;

    //------------------------------------------------------------------------
    // COMPONENTS.
    //------------------------------------------------------------------------

    cdn_reset_driver driver;
    cdn_reset_sequencer sequencer;
    cdn_reset_monitor monitor;

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils_begin(cdn_reset_agent)
        `uvm_field_int(agent_id, UVM_ALL_ON)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_component_utils_end

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // Extend the build_phase method to create the monitor (for both active 
    // and passive agents) and create the sequencer and driver for the active
    // agent instance.
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = cdn_reset_monitor::type_id::create("monitor", this);
        if(is_active == UVM_ACTIVE) begin
            sequencer = cdn_reset_sequencer::type_id::create("sequencer", this);
            driver = cdn_reset_driver::type_id::create("driver", this);
        end
    endfunction : build_phase

    // Extend the connect_phase method to connect the TLM port between the
    // sequencer and the driver.
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction : connect_phase

endclass : cdn_reset_agent

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
