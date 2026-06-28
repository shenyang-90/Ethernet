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
// This file contains default sequences for the cdn_reset UVC.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// SEQUENCE NAME: random_reset_stream_seq
//----------------------------------------------------------------------------
// DESCRIPTION:
// This sequence emulates a stream of legal resets. With the ability to
// change the reset duration.
//----------------------------------------------------------------------------
class random_reset_stream_seq extends uvm_sequence #(cdn_reset_pkg::cdn_reset_transfer);

    //------------------------------------------------------------------------
    // CONTROL MEMBER VARIABLES
    //------------------------------------------------------------------------

    // This member variable controls the number of resets to be done by
    // this sequence.
    rand int unsigned number_of_resets;

    // This field provides control over the gap between resets in clock
    // cycles.
    bit reset_gap_random = 1;

    // This field provides control over the max number of clock cycles
    // between resets.
    // Only valid when the control variable reset_gap_random is 1.
    int unsigned reset_gap_size_max = 100;

    // This member variable provides control over the min number of clock
    // cycles between resets.
    // Only valid when the control variable reset_gap_random is 1.
    int unsigned reset_gap_size_min = 1;

    //------------------------------------------------------------------------
    // CONSTRAINTS
    //------------------------------------------------------------------------
    constraint random_reset_stream_seq_c {
        number_of_resets inside {[1:100]};
    }

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    // Extend the new method and register the sequence name
    function new(string name="random_reset_stream_seq");
        super.new(name);
    endfunction

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------
    `uvm_object_param_utils_begin(random_reset_stream_seq)
        `uvm_field_int(number_of_resets, UVM_ALL_ON)
        `uvm_field_int(reset_gap_random, UVM_ALL_ON)
        `uvm_field_int(reset_gap_size_max, UVM_ALL_ON)
        `uvm_field_int(reset_gap_size_min, UVM_ALL_ON)
    `uvm_object_utils_end
    `uvm_declare_p_sequencer(cdn_reset_pkg::cdn_reset_sequencer)

    //------------------------------------------------------------------------
    // SEQUENCE PRE BODY TCM
    //------------------------------------------------------------------------
    virtual task pre_body();
       uvm_test_done.raise_objection(this);
    endtask : pre_body

    //------------------------------------------------------------------------
    // SEQUENCE BODY TCM
    //------------------------------------------------------------------------
    virtual task body();
      p_sequencer.uvm_report_info(get_type_name(), $psprintf("%s starting...", get_sequence_path()), UVM_HIGH);
      for (int i = 1; i < number_of_resets+1; i++) begin
        p_sequencer.uvm_report_info(get_type_name(), $psprintf("Sending Reset Number  %0d of %0d.",i,number_of_resets), UVM_HIGH);
        `uvm_do_with(req, {reset_duration inside {[1:150]};})
          if (reset_gap_random == 1 & i > 1) begin
            int unsigned gap_size;
            gap_size = $urandom_range(reset_gap_size_max,reset_gap_size_min);
            p_sequencer.uvm_report_info(get_type_name(), $psprintf("Sending Reset Gap of %0d clock cycles.", gap_size), UVM_HIGH);
            #(`CLOCK_PERIOD*gap_size);
          end
      end
      p_sequencer.uvm_report_info(get_type_name(), $psprintf("%s ending...",get_sequence_path()), UVM_HIGH);
    endtask

    //------------------------------------------------------------------------
    // SEQUENCE POST BODY TCM
    //------------------------------------------------------------------------
    virtual task post_body();
       uvm_test_done.drop_objection(this);
    endtask : post_body

endclass : random_reset_stream_seq

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
