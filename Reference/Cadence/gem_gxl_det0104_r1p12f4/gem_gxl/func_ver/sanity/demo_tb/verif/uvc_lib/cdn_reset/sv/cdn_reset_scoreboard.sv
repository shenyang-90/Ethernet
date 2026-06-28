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
// This file defines a basic point to point scoreboard for the cdn_reset UVC.
//----------------------------------------------------------------------------

`ifndef CDN_RESET_SCOREBOARD_SV
`define CDN_RESET_SCOREBOARD_SV

class cdn_reset_scoreboard extends uvm_scoreboard;

    //------------------------------------------------------------------------
    // TLM Ports.
    //------------------------------------------------------------------------

    `uvm_analysis_imp_decl(_dut_input_port)
    `uvm_analysis_imp_decl(_dut_output_port)

    // Implementation of the analysis port for the current_transfer in the dut_input direction.
    uvm_analysis_imp_dut_input_port#(cdn_reset_transfer, cdn_reset_scoreboard) current_transfer_dut_input_export;

    // Implementation of the analysis port for the current_transfer in the dut_output direction.
    uvm_analysis_imp_dut_output_port#(cdn_reset_transfer, cdn_reset_scoreboard) current_transfer_dut_output_export;

    //------------------------------------------------------------------------
    // STATUS MEMBER VARIABLES
    //------------------------------------------------------------------------

    // This member variable contains the number of transfers observed and checked.
    int unsigned number_of_transfers_checked = 0;
    
    // This member variable contains the number of dut_output transfers observed.
    int unsigned number_of_dut_output_transfers = 0;

    // This member variable contains the number of dut_input transfers observed.
    int unsigned number_of_dut_input_transfers = 0;

    // This member variable is a queue of the expected transfers.
    cdn_reset_transfer expected_transfers[$];

    //------------------------------------------------------------------------
    // EVENTS
    //------------------------------------------------------------------------

    // This reset event should be triggered by the env.
    event reset_e;

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils_begin(cdn_reset_scoreboard)
        `uvm_field_int(number_of_transfers_checked,UVM_ALL_ON|UVM_DEC)
        `uvm_field_int(number_of_dut_output_transfers,UVM_ALL_ON|UVM_DEC)
        `uvm_field_int(number_of_dut_input_transfers,UVM_ALL_ON|UVM_DEC)
    `uvm_component_utils_end

    //------------------------------------------------------------------------
    // TASKS
    //------------------------------------------------------------------------

    // On a reset model the dut/protocol behaviour.
    virtual task on_reset_e();
        forever begin
            @reset_e;
            // In this case reset does nothing.
        end
    endtask : on_reset_e

    //------------------------------------------------------------------------
    // METHODS
    //------------------------------------------------------------------------

    // Implement the TLM Analysis port write_dut_input_port() method.
    virtual function void write_dut_input_port(cdn_reset_transfer current_transfer);

        // Quick sanity check.
        if (current_transfer == null) begin
            `uvm_error(get_type_name(),"DUT_INPUT Transfer added to scoreboard is NULL")
        end
        else begin
            uvm_report_info(get_type_name(),"DUT_INPUT Transfer added to scoreboard",UVM_HIGH);

            // Increment the counter for dut_input transfers
            number_of_dut_input_transfers++;

            // The DUT only passes the transfer through to the dut_output side.
            expected_transfers.push_back(current_transfer);
        end
        
    endfunction : write_dut_input_port

    // Implement the TLM Analysis port write_dut_output_port() method.
    virtual function void write_dut_output_port(cdn_reset_transfer current_transfer);
        // Quick sanity check.
        if (current_transfer == null) begin
            `uvm_error(get_type_name(),"DUT_OUTPUT Transfer added to scoreboard is NULL")
        end
        else begin
            uvm_report_info(get_type_name(),
                            "DUT_OUTPUT Transfer added to scoreboard",UVM_HIGH);

            // Increment the counter for dut_output transfers
            number_of_dut_output_transfers++;

            // Check if this transfer is in the expected transfer list.
            if(current_transfer.compare(expected_transfers[0])) begin
                // The transfer was expected so increment the checked counter and delete
                // the transfer from the expected list.
                number_of_transfers_checked++;                
                expected_transfers.delete(0);
            end
            else begin
                uvm_report_info(get_type_name(),$psprintf("Expected Transfer %s",expected_transfers[0].convert2string()));
                uvm_report_info(get_type_name(),$psprintf("Current Transfer %s",current_transfer.convert2string()));
                `uvm_error(get_type_name(),"Current DUT_OUTPUT Transfer was not expected!")
            end
        end        
    endfunction : write_dut_output_port

    //------------------------------------------------------------------------
    // UTILITY METHODS
    //------------------------------------------------------------------------

    //------------------------------------------------------------------------
    // METHOD NAME : get_scoreboard_status
    // METHOD DESCRIPTION : This method can be used to determine the 
    // scoreboard status allowing the test to know if anything is wrong.
    //------------------------------------------------------------------------
    function bit get_scoreboard_status();
        bit result = 0;
        uvm_report_info(get_type_name(),"-----------------------------------------------------",UVM_LOW);
        uvm_report_info(get_type_name(),"-- SCOREBOARD INFO ");
        uvm_report_info(get_type_name(),$psprintf("-- Number of dut_input transfers = %0d",number_of_dut_input_transfers),UVM_LOW);
        uvm_report_info(get_type_name(),$psprintf("-- Number of dut_output transfers = %0d",number_of_dut_output_transfers),UVM_LOW);
        uvm_report_info(get_type_name(),$psprintf("-- Number of expected transfers = %0d",expected_transfers.size()),UVM_LOW);
        uvm_report_info(get_type_name(),$psprintf("-- Number of checked transfers = %0d",number_of_transfers_checked),UVM_LOW);

        if (number_of_dut_input_transfers != number_of_dut_output_transfers || 
            expected_transfers.size() != 0) begin
            uvm_report_info(get_type_name(),"-- Scoreboard is not balanced",UVM_LOW);
            
        end
        else begin
            uvm_report_info(get_type_name(),"-- Scoreboard is balanced",UVM_LOW);
            result = 1;
        end
        uvm_report_info(get_type_name(),"-----------------------------------------------------",UVM_LOW);
        return result;

    endfunction : get_scoreboard_status

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method - Class Constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        // Initialise the TLM analysis port for the input current transfer in dut_input dir.
        current_transfer_dut_input_export = new("current_transfer_dut_input_export", this);
        // Initialise the TLM analysis port for the input current transfer in dut_output dir.
        current_transfer_dut_output_export = new("current_transfer_dut_output_export", this);
    endfunction : new

endclass : cdn_reset_scoreboard

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
