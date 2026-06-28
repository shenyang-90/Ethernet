//----------------------------------------------------------------------------
// Project    : cdn_reset UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CDN_RESET_MONITOR_SV
`define CDN_RESET_MONITOR_SV

class cdn_reset_monitor extends uvm_monitor;

    //------------------------------------------------------------------------
    // INTERFACE.
    //------------------------------------------------------------------------

    // The virtual interface used to view HDL signals.
    virtual cdn_reset_if reset_if;

    //------------------------------------------------------------------------
    // TLM Ports.
    //------------------------------------------------------------------------

    // Analysis port for the current_transfer.
    uvm_analysis_port #(cdn_reset_transfer) current_transfer_port;

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
    `uvm_component_utils_begin(cdn_reset_monitor)
        `uvm_field_int(checks_enable, UVM_ALL_ON)
        `uvm_field_int(coverage_enable, UVM_ALL_ON)
    `uvm_component_utils_end

    //------------------------------------------------------------------------
    // INTERNAL VARIABLES.
    //------------------------------------------------------------------------

    // This variable counts the number of resets observed by this monitor. 
    protected int unsigned reset_counter = 0;

    // This variable counts the number of clock cycles that the resets is 
    // observed for. 
    protected int unsigned reset_duration = 0;

    // This variable is for functions that return a value.
    protected bit ok;

    // This variable contains the currently decoded transfer.
    protected cdn_reset_transfer current_transfer;

    // This variable contains the previous reset signal state.
    protected bit previous_sig_reset_state = `DEASSERTED_RESET_VALUE;

    //------------------------------------------------------------------------
    // EVENTS
    //------------------------------------------------------------------------

    // This event is emitted when the reset has started. 
    event reset_started_e;

    // This event is emitted when the reset has finished. 
    event reset_ended_e;

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
            on_reset_ended();
        join
    endtask : run_phase

    // Function to assign the checks and coverage bits
    task update_vif_enables();
        reset_if.has_checks <= checks_enable;
        reset_if.has_coverage <= coverage_enable;
        forever begin
            @(checks_enable || coverage_enable);
            reset_if.has_checks <= checks_enable;
            reset_if.has_coverage <= coverage_enable;
        end
    endtask : update_vif_enables

    // The monitor task for this class decodes the reset signal and rebuilds
    // the reset transaction and updates the reset counter.
    virtual task monitor();
        uvm_report_info(get_type_name(), "Starting the reset monitoring task", UVM_HIGH);
        forever begin
            @(posedge reset_if.sig_clock);
            if (reset_if.sig_reset == `ASSERTED_RESET_VALUE) begin

                // If the reset duration is zero then this must be the
                // start of a new reset phase. So emit the reset started event
                if (reset_duration == 0) -> reset_started_e;

                // Increment the reset duraction clock cycle counter.
                reset_duration++;

                // Change previous stored signal state
                previous_sig_reset_state = `ASSERTED_RESET_VALUE;
            end
            else if (reset_if.sig_reset == `DEASSERTED_RESET_VALUE) begin
                if (previous_sig_reset_state == `ASSERTED_RESET_VALUE) begin
                     -> reset_ended_e;
                end
                // Change previous stored signal state
                previous_sig_reset_state = `DEASSERTED_RESET_VALUE;
            end
            else begin
                uvm_report_info(get_type_name(),"Reset Signal is undefined!!",UVM_HIGH);
                // Change previous stored signal state
                previous_sig_reset_state = `DEASSERTED_RESET_VALUE;
            end
        end
    endtask : monitor

    // This task updates the reset counter and resets the reset_duration.
    virtual task on_reset_ended();
        forever begin
            @reset_ended_e;

            uvm_report_info(get_type_name(), $psprintf("Reset duration = %0d",reset_duration), UVM_HIGH);

            // Capture the current transfer in a data item for coverage.
            current_transfer = new();

            // Update the observation_time member variable in the 
            // current transfer
            current_transfer.observation_time = $time;

            // Update the observer reset duration in the current transfer
            current_transfer.reset_duration = reset_duration;

            // Send the current transfer to the TLM Analysis port.
            current_transfer_port.write(current_transfer);

            // Reset duration counter.
            reset_duration = 0;

            // Increment number of resets counter
            reset_counter++;

            // Collect coverage
            reset_coverage.sample();
        end
    endtask : on_reset_ended

    //------------------------------------------------------------------------
    // COVERAGE GROUPS
    //------------------------------------------------------------------------

    // This coverage group captures all coverage associated with reset
    // conditions.
    covergroup reset_coverage;
        option.per_instance = 1;

        reset_counter : coverpoint reset_counter {
            ignore_bins no_reset = {0};
            bins Initial_Reset = {1};
            bins Multiple_Resets = {[2:$]};
        }
      
        reset_duration : coverpoint current_transfer.reset_duration {
            bins short_reset = {[0:10]};
            bins long_reset = {[11:100]};
            bins very_long_reset = {[101:$]};
        }

    endgroup : reset_coverage

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method - Class Constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);

        // Initialise the reset coverage group and set its instance name.
        reset_coverage = new();
        reset_coverage.set_inst_name({get_full_name(), ".reset_coverage"});

        // Initialise the TLM analysis port for the current transfer
        current_transfer_port = new("current_transfer_port", this);
    endfunction : new

    // Extend build_phase to attach the virtual interface
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!uvm_config_db#(virtual cdn_reset_if)::get(this, "", "reset_if", reset_if))
         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".reset_if"})
    endfunction: build_phase

endclass : cdn_reset_monitor

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
