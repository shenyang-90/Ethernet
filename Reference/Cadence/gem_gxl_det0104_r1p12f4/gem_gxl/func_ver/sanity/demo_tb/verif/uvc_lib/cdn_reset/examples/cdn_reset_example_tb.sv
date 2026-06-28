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
// This file contains an example top level env (testbench) with an instance of
// the UVC env, which contains two agents (one active and one passive).
//----------------------------------------------------------------------------

`ifndef CDN_RESET_EXAMPLE_ENV_SV
`define CDN_RESET_EXAMPLE_ENV_SV

`include "cdn_reset_sequence_lib.sv"
`include "cdn_reset_scoreboard.sv"

class cdn_reset_example_env extends uvm_env;

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils(cdn_reset_example_env)

    //------------------------------------------------------------------------
    // COMPONENTS.
    //------------------------------------------------------------------------

    // Add an instance of the cdn_reset OVC env
    cdn_reset_env reset_env;

    // Add an instance of the cdn_reset scoreboard
    cdn_reset_scoreboard scoreboard;

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // Extend the build method to build the env with the correct number of
    // agents.
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(int)::set(this,"reset_env", "number_of_agents", 2);
        reset_env = cdn_reset_env::type_id::create("reset_env", this);
        // Configure the second agent to be passive.
        uvm_config_db#(int)::set(this,"reset_env.agents[1]", "is_active", UVM_PASSIVE);

        // Create the scoreboard
        scoreboard = cdn_reset_scoreboard::type_id::create("scoreboard", this);

        // Assign interface for reset_env.agents[0];
        uvm_config_db#(virtual cdn_reset_if)::set(this, "reset_env.agents[0].driver","reset_if",cdn_reset_tb.reset_in);
        uvm_config_db#(virtual cdn_reset_if)::set(this, "reset_env.agents[0].monitor","reset_if",cdn_reset_tb.reset_in);

        // Assign interface for reset_env.agents[1];
        uvm_config_db#(virtual cdn_reset_if)::set(this, "reset_env.agents[1].driver","reset_if",cdn_reset_tb.reset_out);
        uvm_config_db#(virtual cdn_reset_if)::set(this, "reset_env.agents[1].monitor","reset_if",cdn_reset_tb.reset_out);
    
    endfunction : build_phase

    // Extend the connect_phase method to connect up the virtual interfaces.
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Attach the active monitor to the scoreboard
        reset_env.agents[0].monitor.current_transfer_port.connect(scoreboard.current_transfer_dut_input_export);
        // Attach the passive monitor to the scoreboard
        reset_env.agents[1].monitor.current_transfer_port.connect(scoreboard.current_transfer_dut_output_export);

    endfunction : connect_phase

endclass : cdn_reset_example_env 

`endif
//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
