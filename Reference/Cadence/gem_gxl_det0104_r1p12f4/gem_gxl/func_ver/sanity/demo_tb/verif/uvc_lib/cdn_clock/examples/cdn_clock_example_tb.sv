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
// This file contains an example top level env (testbench) with an instance of
// the OVC env, which contains two agents (one active and one passive).
//----------------------------------------------------------------------------

`ifndef CDN_CLOCK_EXAMPLE_ENV_SV
`define CDN_CLOCK_EXAMPLE_ENV_SV

class cdn_clock_example_env extends uvm_env;

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils(cdn_clock_example_env)

    //------------------------------------------------------------------------
    // COMPONENTS.
    //------------------------------------------------------------------------

    // Add an instance of the cdn_clock OVC agent
    cdn_clock_agent clock_env;

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // Extend the build_phase method to build the env with the correct number
    // of agents.
    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Assign interface for clock_env.agent;
        uvm_config_db#(virtual cdn_clock_if)::set(this, "clock_env.driver","clock_if",cdn_clock_tb.clock_out);
        uvm_config_db#(virtual cdn_clock_if)::set(this, "clock_env.monitor","clock_if",cdn_clock_tb.clock_out);

        // Configure the definite clock frequency
        uvm_config_db#(int)::set(this, "clock_env", "clk_ref" , 2000);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div0",   10);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div1",   20);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div2",   40);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div3",   80);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div4",  100);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div5",  200);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div6",  400);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div7",  800);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div8",  100);
        uvm_config_db#(int)::set(this, "clock_env", "clk_div9",  100);

        clock_env = cdn_clock_agent::type_id::create("clock_env", this);

    endfunction : build_phase

endclass : cdn_clock_example_env 

`endif
//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
