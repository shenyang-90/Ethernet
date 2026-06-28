//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2013 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description: 
// This file contains the implementation of the misc signals driver for the
// cdn_demo UVC env. The purpose of this driver is to provied 
// a simple API to the RTL signals that need to be driven via virtual 
// sequences but do not belong to their own UVC.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_MISC_SIGNALS_DRIVER_SV
`define CDN_DEMO_MISC_SIGNALS_DRIVER_SV

class cdn_demo_misc_signals_driver extends uvm_driver;

    //------------------------------------------------------------------------
    // INTERFACE.
    //------------------------------------------------------------------------

    // The virtual interface used to drive and view the misc HDL signals.
    protected virtual cdn_demo_misc_signals_if misc_signals_if;
    
    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils macro provides base virtual methods like 
    // get_type_name and create.

    `uvm_component_utils(cdn_demo_misc_signals_driver)

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method
    function new (string name="cdn_demo_misc_signals_driver", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // Extend build_phase to attach the virtual interface
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual cdn_demo_misc_signals_if)::get(this, "", "misc_signals_if", misc_signals_if))
          `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".misc_signals_if"})
    endfunction: build_phase

    //------------------------------------------------------------------------
    // DEFINE TASKS
    //------------------------------------------------------------------------

    // The run_phase task for this class will be started automatically 
    // during the run phase
    virtual task run_phase(uvm_phase phase);
        uvm_report_info(get_type_name(),
                        "Starting the misc signals driver run task",
                        UVM_HIGH);
    
        forever begin
            @(misc_signals_if.driver_cb);
            if(misc_signals_if.sig_reset == `CDN_DEMO_ACTIVE_RESET_VALUE) begin
                drive_reset_values();
            end
        end
        
    endtask : run_phase

    // Task to drive reset values onto the misc signals that are inputs to 
    // the dut.
    virtual task drive_reset_values();
        misc_signals_if.driver_cb.sig_dut_enable <= `CDN_DEMO_DUT_ENABLE_RESET_VALUE;
        @(misc_signals_if.driver_cb);
    endtask : drive_reset_values

    // Task to drive dut enable misc signal.
    virtual task drive_dut_enable_misc_signal();
        input dut_enable_value;
        begin
            @(misc_signals_if.driver_cb);
            misc_signals_if.driver_cb.sig_dut_enable <= dut_enable_value;
        end
    endtask : drive_dut_enable_misc_signal

endclass : cdn_demo_misc_signals_driver

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
