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
// This file contains the detailed description of the cdn_reset UVC env.
//----------------------------------------------------------------------------

`ifndef CDN_RESET_ENV_SV
`define CDN_RESET_ENV_SV

class cdn_reset_env extends uvm_env;

    //------------------------------------------------------------------------
    // CONTROL MEMBER VARIABLES.
    //------------------------------------------------------------------------

    // This member variable controls the number of agents required in the env. 
    protected int unsigned number_of_agents;

    //------------------------------------------------------------------------
    // COMPONENTS.
    //------------------------------------------------------------------------

    // This member variable is a list of agents, whose size is determined by 
    // the member variable number_of_agents.
    cdn_reset_agent agents[];

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils_begin(cdn_reset_env)
        `uvm_field_int(number_of_agents, UVM_ALL_ON)
    `uvm_component_utils_end

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // Extend the build_phase method to create the agents.
    function void build_phase(uvm_phase phase);
        string    agent_instance_name;
        super.build_phase(phase);

        agents = new[number_of_agents];

        for(int i = 0; i < number_of_agents; i++) begin
            $sformat(agent_instance_name,"agents[%0d]",i);
            agents[i] = cdn_reset_agent::type_id::create(agent_instance_name, this);
            uvm_config_db#(int)::set(this,{agent_instance_name, "*"}, "agent_id", i);
        end
    endfunction : build_phase

endclass : cdn_reset_env

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
