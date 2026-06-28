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
// This file contains a test library for the cdn_reset UVC.
//----------------------------------------------------------------------------

`include "cdn_reset_example_tb.sv"

//----------------------------------------------------------------------------
// BASIC TEST
//----------------------------------------------------------------------------

class cdn_reset_basic_test extends uvm_test;


    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils(cdn_reset_basic_test)

    //------------------------------------------------------------------------
    // COMPONENTS
    //------------------------------------------------------------------------

    // Add an instance of the cdn_reset_example_env
    cdn_reset_example_env my_env;

    // Add a printer for logging.
    uvm_table_printer printer;

    // Add the sequence type to be used as the default.
    random_reset_stream_seq rand_reset_seq;

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method
    function new (string name = "cdn_reset_basic_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // Extend the build_phase method to build the env.
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Enable transaction recording for everything.
        uvm_config_db #(uvm_verbosity)::set(this,"*","recording_detail", UVM_FULL);

        // Ensure that only the random reset sequence from the UVCs sequence lib is used as
        // the default.
        rand_reset_seq = new("rand_reset_seq");
        uvm_config_db #(uvm_sequence_base)::set(this, 
           "*.agents[0].sequencer.run_phase",
           "default_sequence",
           rand_reset_seq);

        // Create the env
        my_env = cdn_reset_example_env::type_id::create("my_env", this);

        // Create a specific depth printer for printing the created topology
        printer = new();
        printer.knobs.depth = 2;

    endfunction : build_phase

    //------------------------------------------------------------------------
    // TASKS
    //------------------------------------------------------------------------

    // Extend run_phase task
    task run_phase(uvm_phase phase);
        uvm_top.print_topology();        
        phase.raise_objection(this,"Raising Test objection for run_phase");
        forever begin
            #200000;
            assert(my_env.scoreboard.get_scoreboard_status()) ;
            phase.drop_objection(this,"Dropping Test objection for run_phase");
        end
    endtask : run_phase

endclass : cdn_reset_basic_test

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
