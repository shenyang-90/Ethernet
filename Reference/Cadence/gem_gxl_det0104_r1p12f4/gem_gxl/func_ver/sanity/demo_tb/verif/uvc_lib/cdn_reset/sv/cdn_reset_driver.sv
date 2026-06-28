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
// This file defines the driver (BFM) for the cdn_reset UVC.
//----------------------------------------------------------------------------

`ifndef CDN_RESET_DRIVER_SV
`define CDN_RESET_DRIVER_SV

class cdn_reset_driver extends uvm_driver #(cdn_reset_transfer);

    //------------------------------------------------------------------------
    // INTERFACE.
    //------------------------------------------------------------------------

    // The virtual interface used to drive and view HDL signals.
    protected virtual cdn_reset_if reset_if;

    //------------------------------------------------------------------------
    // CONTROL SWITCHES
    //------------------------------------------------------------------------
    // If set to 1 then the initial driven value will be equal to active reset
    bit assert_reset_at_sim_start = 0;
    
    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils_begin(cdn_reset_driver)
        `uvm_field_int(assert_reset_at_sim_start, UVM_ALL_ON)
    `uvm_component_utils_end

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // Extend build_phase to attach the virtual interface
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!uvm_config_db#(virtual cdn_reset_if)::get(this, "", "reset_if", reset_if))
         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".reset_if"})
    endfunction: build_phase

    //------------------------------------------------------------------------
    // DEFINE TASKS
    //------------------------------------------------------------------------

    // The run_phase task for this class will be started automatically during
    // the run phase
    virtual task run_phase(uvm_phase phase);

        uvm_report_info(get_type_name(),"Starting the driver run task",
                        UVM_HIGH);

        if (assert_reset_at_sim_start) begin
            reset_if.sig_reset = `ASSERTED_RESET_VALUE;
        end
        else begin
            reset_if.sig_reset = `DEASSERTED_RESET_VALUE;
        end
        
        fork
            bfm_driver();
        join
    endtask : run_phase

    // This task gets a transfer from the sequencer and does the actual signal
    // toggling to implement the current transfer.
    virtual protected task bfm_driver();

        uvm_report_info(get_type_name(),"Starting the bfm_driver task",
                        UVM_HIGH);

        forever begin
        @(posedge reset_if.sig_clock);

            // Get the next transaction from the sequence driver.
            seq_item_port.get_next_item(req);
            
            uvm_report_info(get_type_name(), "Asserting reset.", UVM_HIGH);

            // Call the bfm body to drive the actual signals using
            // the current transfer.
            bfm_body(req);

            uvm_report_info(get_type_name(), "Deasserting reset.", UVM_HIGH);

            seq_item_port.item_done();
        end        
    endtask : bfm_driver


    // This TASK enables the BFM functionality to be replaced or extended 
    // easily.
    virtual task bfm_body(cdn_reset_transfer current_transfer);
        for (int unsigned i = 0; i < current_transfer.reset_duration; i++) begin
            reset_if.sig_reset = `ASSERTED_RESET_VALUE;
            @(posedge reset_if.sig_clock);
        end
        reset_if.sig_reset = `DEASSERTED_RESET_VALUE;
   endtask : bfm_body

endclass : cdn_reset_driver

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
