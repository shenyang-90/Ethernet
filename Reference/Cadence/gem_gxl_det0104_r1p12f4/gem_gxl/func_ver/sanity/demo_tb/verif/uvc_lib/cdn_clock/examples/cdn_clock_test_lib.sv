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
// This file contains a test library for the cdn_clock UVC.
//----------------------------------------------------------------------------


`include "cdn_clock_example_tb.sv"


//----------------------------------------------------------------------------
// BASIC TEST
//----------------------------------------------------------------------------

class cdn_clock_basic_test extends uvm_test;


    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils(cdn_clock_basic_test)

    //------------------------------------------------------------------------
    // COMPONENTS
    //------------------------------------------------------------------------

    // Add an instance of the cdn_clock_example_env
    cdn_clock_example_env my_env;

    // Add a printer for logging.
    uvm_table_printer printer;

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method
    function new (string name = "cdn_clock_basic_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // Extend the build_phase method to build the env.
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Enable transaction recording for everything.
        uvm_config_db #(int)::set(this,"*", "recording_detail", UVM_FULL);

        // Create the env
        my_env = cdn_clock_example_env::type_id::create("my_env", this);

        // Create a specific depth printer for printing the created topology
        printer = new();
        printer.knobs.depth = 5;

    endfunction : build_phase

    //------------------------------------------------------------------------
    // TASKS
    //------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        uvm_top.print_topology();        
        phase.raise_objection(this);
        forever begin
            #2000;
            phase.drop_objection(this);
        end
    endtask : run_phase

endclass : cdn_clock_basic_test

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
