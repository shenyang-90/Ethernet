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
// This file defines the monitor for the cdn_clock UVC.
//----------------------------------------------------------------------------

`ifndef CDN_CLOCK_MONITOR_SV
`define CDN_CLOCK_MONITOR_SV

class cdn_clock_monitor extends uvm_monitor;

    //------------------------------------------------------------------------
    // INTERFACE.
    //------------------------------------------------------------------------

    // The virtual interface used to view HDL signals.
    virtual cdn_clock_if clock_if;

    //------------------------------------------------------------------------
    // CONTROL MEMBER VARIABLES.
    //------------------------------------------------------------------------

    // This member variable enables the protocol checks.
    bit checks_enable = 1;

    // This member variable enables the protocol coverage.
    bit coverage_enable = 1;

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils_begin(cdn_clock_monitor)
        `uvm_field_int(checks_enable, UVM_ALL_ON)
        `uvm_field_int(coverage_enable, UVM_ALL_ON)
    `uvm_component_utils_end

    //------------------------------------------------------------------------
    // INTERNAL VARIABLES.
    //------------------------------------------------------------------------


    //------------------------------------------------------------------------
    // EVENTS
    //------------------------------------------------------------------------

    //------------------------------------------------------------------------
    // DEFINE TASKS
    //------------------------------------------------------------------------

    // The run_phase task for this class will be started automatically during 
    // the run phase
    virtual task run_phase(uvm_phase phase);
        uvm_report_info(get_type_name(), "Starting the run task", UVM_HIGH);
        fork
            update_vif_enables();
            monitor();
        join
    endtask : run_phase

    // Function to assign the checks and coverage bits
    task update_vif_enables();
        clock_if.has_checks <= checks_enable;
        clock_if.has_coverage <= coverage_enable;
        forever begin
            @(checks_enable || coverage_enable);
            clock_if.has_checks <= checks_enable;
            clock_if.has_coverage <= coverage_enable;
        end
    endtask : update_vif_enables

    // The monitor task for this class decodes the clock signal and rebuilds
    // the clock transaction and updates the clock counter.
    virtual task monitor();
        uvm_report_info(get_type_name(), "Starting the clock monitoring task", UVM_HIGH);
    endtask : monitor

    //------------------------------------------------------------------------
    // COVERAGE GROUPS
    //------------------------------------------------------------------------

    // This coverage group captures all coverage associated with clock
    // conditions.
//    covergroup clock_coverage @clock_coverage_e;
//        option.per_instance = 1;
//    endgroup : clock_coverage

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method - Class Constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // Extend build_phase to attach the virtual interface
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!uvm_config_db#(virtual cdn_clock_if)::get(this, "", "clock_if", clock_if))
         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".clock_if"})
    endfunction: build_phase

endclass : cdn_clock_monitor

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
