//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : kamilp@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_uvm_reg_bit_bash_test.sv
 *
 * This file defines the cdn_gem_demo_uvm_reg_bit_bash_test test.
 */

`ifndef CDN_GEM_DEMO_UVM_REG_BIT_BASH_TEST_SV
  `define CDN_GEM_DEMO_UVM_REG_BIT_BASH_TEST_SV

/*
 * test_description: cdn_gem_demo_uvm_reg_bit_bash_test
 * 
 * This test runs the cdn_gem_demo_uvm_reg_bit_bash_seq sequence, which
 * sequentially walks 0s and 1s, checking that it is appropriately set or
 * cleared, based on the field access policy specified for the field containing
 * the target bit.
 * 
 * Class: cdn_gem_demo_uvm_reg_bit_bash_test
 *
 * This test runs the cdn_gem_demo_uvm_reg_bit_bash_seq sequence, which
 * sequentially walks 0s and 1s, checking that it is appropriately set or
 * cleared, based on the field access policy specified for the field containing
 * the target bit. 
 */
class cdn_gem_demo_uvm_reg_bit_bash_test extends cdn_gem_demo_base_test;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_component_utils(cdn_gem_demo_uvm_reg_bit_bash_test)

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uvm_reg_bit_bash_test objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new (string name = "cdn_gem_demo_uvm_reg_bit_bash_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  /*
   * Method: build_phase
   *
   * This UVM phase is used for building the testbench component hierarchy.
   * For the cdn_gem_demo_uvm_reg_bit_bash_test class, it overrides the default
   * virtual sequence to run the proper one.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void build_phase(uvm_phase phase);
    factory.set_type_override_by_type(normal_operation_seq::get_type(), cdn_gem_demo_uvm_reg_bit_bash_seq::get_type());
    super.build_phase(phase);
  endfunction : build_phase

endclass : cdn_gem_demo_uvm_reg_bit_bash_test
 
`endif
 
//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
 