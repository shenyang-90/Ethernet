//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// sequence_description: normal_operation_seq
// This sequence provide the base sequence for the demoTB and provides basic
// functionality, such as applying the reset.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Class: normal_operation_seq
// See sequence description for more details.
//----------------------------------------------------------------------------

class normal_operation_seq extends uvm_sequence;

    //------------------------------------------------------------------------
    // CONTROL MEMBER VARIABLES
    //------------------------------------------------------------------------

    // TODO: Add control knobs.

    //------------------------------------------------------------------------
    // CONSTRAINTS
    //------------------------------------------------------------------------

    // TODO: Add basic constraints if required.
    
    //------------------------------------------------------------------------
    // REQUIRED SUBSEQUENCES
    //------------------------------------------------------------------------
    random_reset_stream_seq reset_sequence;

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method and register the sequence name
    function new(string name="normal_operation_seq");
        super.new(name);
    endfunction
  
    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------
    `uvm_object_utils(normal_operation_seq)
    `uvm_declare_p_sequencer(cdn_demo_pkg::cdn_demo_virtual_sequencer)
      
    //------------------------------------------------------------------------
    // SEQUENCE BODY TCM
    //------------------------------------------------------------------------
    virtual task body();

        uvm_test_done.raise_objection(this);
        `uvm_info(get_type_name(), {get_sequence_path(), " starting..."}, UVM_LOW)

       //--------------------------------------------------------------------
       // Step 1. Perform an initial reset
       //--------------------------------------------------------------------
       
       // Drive a single random length reset.
       `uvm_do_on_with(reset_sequence, 
                       p_sequencer.reset_sequencer, 
                       {number_of_resets == 1;})

       //--------------------------------------------------------------------
       // Step 2. Configure the DUT - try and do this randomly where it makes
       //         sense. For example using a config class.
       //--------------------------------------------------------------------

       p_sequencer.misc_signals_driver.drive_dut_enable_misc_signal(1);

       //--------------------------------------------------------------------
       // Step 3. DUT Specific Sequences
       //--------------------------------------------------------------------

      `uvm_info(get_type_name(), {get_sequence_path(), " ending..."}, UVM_LOW)
 
 
       uvm_test_done.drop_objection(this);
    endtask

endclass : normal_operation_seq

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
