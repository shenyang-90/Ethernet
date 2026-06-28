//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file contains the base test for the cdn_gem_demo UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_base_test.sv
 *
 * This file contains the base test for the cdn_gem_demo UVC.
 */

`ifndef CDN_GEM_DEMO_BASE_TEST_SV
  `define CDN_GEM_DEMO_BASE_TEST_SV

/*
 * test_description: cdn_gem_demo_base_test
 *
 * This is the cdn_gem_demo UVC base test (UVM).
 *
 * Class: cdn_gem_demo_base_test
 *
 * This is the cdn_gem_demo UVC base test (UVM).
 */
class cdn_gem_demo_base_test extends cdn_demo_base_test;

  //------------------------------------------------------------------------
  // COMPONENTS.
  //------------------------------------------------------------------------

  /*
   * Variable: p_sve
   *
   * A pointer to the cdn_demo UVC testbench to enable hierarchical access.
   */
  cdn_gem_demo_module_env p_sve;

  //------------------------------------------------------------------------
  // MEMBER VARIABLES.
  //------------------------------------------------------------------------

  /*
   * Variable: printer
   *
   * A printer for logging and printing the test and VE topology.
   */
  uvm_table_printer printer;

  /*
   * Variable: emac_regs0
   *
   * This is the UVM register bank.
   */
  emac_regs_type emac_regs0;

  /*
   * Variable: base_address
   *
   * A dynamic array to hold APB slave base addresses when these are configured
   * inside the test and its extensions.
   */
  bit [63:0] base_addr[];

  /*
   * Variable: base_address
   *
   * A dynamic array to hold APB slave end addresses when these are configured
   * inside the test and its extensions.
   */
  bit [63:0] end_addr[];

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------

  // The component utils macro provides base virtual methods like
  // get_type_name and create.
  `uvm_component_utils(cdn_gem_demo_base_test)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_base_test objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new (string name = "cdn_gem_demo_base_test", uvm_component parent=null);
    super.new(name, parent);
    base_addr = new[`CDN_DEMO_APB_NUM_OF_SLAVES];
    end_addr  = new[`CDN_DEMO_APB_NUM_OF_SLAVES];
    // Create a specific depth printer for printing the created topology
    printer = new();
    if (get_report_verbosity_level() == UVM_NONE) begin
      printer.knobs.depth = 0;
    end else if (get_report_verbosity_level() == UVM_LOW) begin
      printer.knobs.depth = 3;
    end else if (get_report_verbosity_level() == UVM_MEDIUM) begin
      printer.knobs.depth = 4;
    end else if (get_report_verbosity_level() == UVM_HIGH) begin
      printer.knobs.depth = 5;
    end else begin
      printer.knobs.depth = 6;
    end
    uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
  endfunction : new

  /*
   * Method: build_phase
   *
   * This UVM phase is used for building the testbench component hierarchy.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void build_phase(uvm_phase phase);
    // Override base framework with protocol-specific framework
    factory.set_type_override_by_type(cdn_demo_module_env::get_type(),cdn_gem_demo_module_env::get_type());
    factory.set_type_override_by_type(cdn_demo_env::get_type(),cdn_gem_demo_env::get_type());
    factory.set_type_override_by_type(cdn_demo_virtual_sequencer::get_type(),cdn_gem_demo_virtual_sequencer::get_type());
    factory.set_type_override_by_type(cdn_demo_config_object::get_type(),cdn_gem_demo_config_object::get_type());

    // Call the parent build phase
    super.build_phase(phase);

    // Connect the cdn_gem_demo UVC tesbench handle to the cdn_demo UVC
    // tesbench instance
    $cast(p_sve, uvm_top.find("*sve"));

    //------------
    // UVM_REG
    //------------

    // Create the Ethernet controller register block. Then, build the register
    // map and pass it down to the env in order to configure the default one and
    // enable hook up by the various components.
    emac_regs0 = emac_regs_type::type_id::create("emac_regs0", this);
    emac_regs0.build();
    uvm_config_db#(uvm_reg_block)::set(this,"sve.demo_env","regs0",emac_regs0);

    //------------
    // APB config
    //------------

    // Set the address segments of the APB master agent to match slaves.
    for (int i=0; i<`CDN_DEMO_APB_NUM_OF_SLAVES; i++) begin
      base_addr[i] = 64'h0000_0000_5000_0000 + i*64'h0000_0000_0000_2000;
      end_addr[i]  = 64'h0000_0000_5000_0000 + (i+1)*64'h0000_0000_0000_2000 - 1;
      uvm_config_db#(bit [63:0])::set(this,"sve.demo_env.apb_env", $psprintf("base_addr[%0d]", i), base_addr[i]);
      uvm_config_db#(bit [63:0])::set(this,"sve.demo_env.apb_env", $psprintf("end_addr[%0d]", i), end_addr[i]);
    end
  endfunction : build_phase

  /*
   * Method: connect_phase
   *
   * This UVM phase is used for making connections between components in the
   * hierarchy.
   * For the cdn_gem_demo_base_test, it sets the base address to the UVM_REG
   * default register map to match what configured in the build_phase.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Set the default map for the regs component
    `uvm_info(get_type_name(), $psprintf("[APB config] Setting emac_regs0 bank | base address = 0x%16h", base_addr[0]), UVM_LOW);
    emac_regs0.default_map.set_base_addr(base_addr[0]);
    // Connect the register block to the virtual sequencer
    if(sve.demo_env.is_active == UVM_ACTIVE) begin
      p_sve.p_demo_env.p_virtual_sequencer.p_emac_regs0 = emac_regs0;
    end
  endfunction : connect_phase

  /*
   * Method: end_of_elaboration_phase
   *
   * This UVM phase is related to post-elaboration activities.
   * For the cdn_gem_demo_base_test, it overrides the super method to print out
   * a reduced the VE topology based on the UVM verbosity.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    if (get_report_verbosity_level() > UVM_NONE) begin
      uvm_top.print_topology(printer);
    end
  endfunction : end_of_elaboration_phase

endclass : cdn_gem_demo_base_test

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
