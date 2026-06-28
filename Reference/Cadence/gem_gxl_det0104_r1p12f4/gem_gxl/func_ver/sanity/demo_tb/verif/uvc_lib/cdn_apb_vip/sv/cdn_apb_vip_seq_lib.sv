//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file contains the some basic APB sequences that are required to enable
// the cdn_apb_vip_driver to offer read/write tasks that can be used by
// other sequences as a simple API and/or for the C API layer.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_seq_lib.sv
 * 
 * This file contains the some basic APB sequences that are required to enable
 * the cdn_apb_vip_driver to offer read/write tasks that can be used by
 * other sequences as a simple API and/or for the C API layer.
 */

`ifndef CDN_APB_VIP_SEQ_LIB_SV
`define CDN_APB_VIP_SEQ_LIB_SV

/*
 * Class: cdn_apb_vip_transaction
 * 
 * The cdn_apb_vip_transaction class extends base denaliCdnApbTransaction class.
 */
class cdn_apb_vip_transaction extends denaliCdn_apbTransaction;

  //------------------------------------------------------------------------
  // MEMBER VARIABLES
  //------------------------------------------------------------------------

  /*
   * Variable: cfg
   * 
   * APB configuration object handle.
   */
  cdnApbUvmConfig cfg;

  //------------------------------------------------------------------------
  // CONSTRAINTS
  //------------------------------------------------------------------------

  constraint maxSignalWidth {
    NumberOfSlaves == cfg.number_of_slaves;
  }

  constraint c_ReqDelay {
    ReqDelay inside {[0:100]};
  }

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------

  `uvm_object_utils(cdn_apb_vip_transaction)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  function new(string name = "cdn_apb_vip_transaction");
    super.new(name);
  endfunction : new

  /*
   * Method: pre_randomize
   * 
   * This method is executed prior to item randomization.
   */
  function void pre_randomize();
    cdnApbUvmSequencer seqr;
    super.pre_randomize();
    max_req_delay.constraint_mode(0);
    if (!$cast(seqr,get_sequencer())) begin
      `uvm_fatal(get_type_name(),"failed $cast(seqr,get_sequencer())");
    end
    if (!$cast(cfg,seqr.pAgent.cfg)) begin
      `uvm_fatal(get_type_name(),"failed $cast(cfg,seqr.pAgent.cfg))");
    end
  endfunction

endclass

/*
 * Class: cdn_apb_vip_sequence
 * 
 * This class defines a base sequence for this cdn_apb_vip sequence lib.
 * It mainly adds the UVM objection mechanism into all derived sequences.
 */
class cdn_apb_vip_sequence extends cdnApbUvmSequence;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------
  
  `uvm_object_utils(cdn_apb_vip_sequence)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Function: new
   * 
   * Creates and initializes a new object for this class.
   */
  function new(string name = "cdn_apb_vip_sequence");
    super.new(name);
  endfunction : new

  /*
   * Task: pre_body
   * 
   * Raise an objection before body is run.
   */
  virtual task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this);
    end
  endtask

  /*
   * Task: post_body
   * 
   * Drop the objection raised by pre_body now that body has completed.
   */
  virtual task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this);
    end
  endtask

endclass

/*
 * Class: cdn_apb_vip_write_seq
 * 
 * This sequence performs an APB read Transaction.
 */
class cdn_apb_vip_read_seq extends cdn_apb_vip_sequence;

  /*
   * Variable: trans
   * 
   * The sequence item (transaction) that will be randomized and passed to the
   * driver.
   */
  rand cdn_apb_vip_transaction trans;

  /*
   * Variable: _trans
   * 
   * The response transaction.
   */
  denaliCdn_apbTransaction _trans;

  /*
   * Variable: addr
   * 
   * The address to read.
   */
  rand int addr;

  /*
   * Variable: data
   * 
   * The read data.
   */
  integer data;

  //----------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------------------------------------
  
  `uvm_object_utils_begin(cdn_apb_vip_read_seq)
    `uvm_field_object(trans, UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS.
  //----------------------------------------------------------------------

  /*
   * Method: new
   * 
   * Call the constructor of the parent class.
   */
  function new(string name = "cdn_apb_vip_read_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   * 
   * APB Read Transaction.
   */
  virtual task body();
    p_sequencer.uvm_report_info(get_type_name(), $psprintf("%s starting...", get_sequence_path()),UVM_HIGH);
    `uvm_do_with(trans, {
      trans.Direction == DENALI_CDN_APB_DIRECTION_READ;
      trans.Addr == addr; });
    get_response(_trans);
    data = _trans.Data;
    p_sequencer.uvm_report_info(get_type_name(), $psprintf("%s ending...", get_sequence_path()),UVM_HIGH);
  endtask : body

endclass

/*
 * Class: cdn_apb_vip_write_seq
 * 
 * This sequence performs an APB write Transaction.
 */
class cdn_apb_vip_write_seq extends cdn_apb_vip_sequence;

  //----------------------------------------------------------------------
  // MEMBER VARIABLES
  //----------------------------------------------------------------------

  /*
   * Variable: trans
   * 
   * The sequence item (transaction) that will be randomized and passed to the
   * driver.
   */
  rand cdn_apb_vip_transaction trans;

  /*
   * Variable: _trans
   * 
   * The response transaction.
   */
  denaliCdn_apbTransaction _trans;

  /*
   * Variable: addr
   * 
   * The address to write.
   */
  rand int addr;
  
  /*
   * Variable: data
   * 
   * The data to write.
   */
  rand int data;

  //----------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------------------------------------
  
  `uvm_object_utils_begin(cdn_apb_vip_write_seq)
    `uvm_field_object(trans, UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS.
  //----------------------------------------------------------------------

  /*
   * Method: new
   * 
   * Call the constructor of the parent class.
   */
  function new(string name = "cdn_apb_vip_write_seq");
     super.new(name);
  endfunction : new

  /*
   * Method: body
   * 
   * APB Write Transaction.
   */   
  virtual task body();
    p_sequencer.uvm_report_info(get_type_name(), $psprintf("%s starting...", get_sequence_path()),UVM_HIGH);
    `uvm_do_with(trans,
      {trans.Direction == DENALI_CDN_APB_DIRECTION_WRITE;
      trans.Addr == addr;
      trans.Data == data;
    });
    get_response(_trans);
    p_sequencer.uvm_report_info(get_type_name(), $psprintf("%s ending...", get_sequence_path()),UVM_HIGH);
  endtask : body

endclass

/*
 * Class: cdn_apb_vip_write_no_delay_seq
 * 
 * This sequence performs an APB Write Transaction with no delay.
 */
class cdn_apb_vip_write_no_delay_seq extends cdn_apb_vip_write_seq;

  //----------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------------------------------------
  
  `uvm_object_utils(cdn_apb_vip_write_no_delay_seq)

  //----------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS.
  //----------------------------------------------------------------------

  /*
   * Method: new
   * 
   * Call the constructor of the parent class.
   */
  function new(string name = "cdn_apb_vip_write_no_delay_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   * 
   * APB Write Transaction with no delay.
   */
  virtual task body();
    `uvm_do_with(trans,
      {trans.Direction == DENALI_CDN_APB_DIRECTION_WRITE;
      trans.Addr == addr;
      trans.Data == data;
      trans.ReqDelay == 0;
      trans.Delay == 0;
      trans.ReqResponseDelay == 0;
    });
  endtask : body

endclass

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
