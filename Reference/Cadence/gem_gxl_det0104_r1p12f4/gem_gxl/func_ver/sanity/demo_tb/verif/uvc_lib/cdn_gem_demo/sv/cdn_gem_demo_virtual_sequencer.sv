//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

/*
 * Class: cdn_gem_demo_virtual_sequencer.sv
 * 
 * This file defines the cdn_gem_demo UVC virtual sequencer class.
 */

`ifndef CDN_GEM_DEMO_VIRTUAL_SEQUENCER_SV
  `define CDN_GEM_DEMO_VIRTUAL_SEQUENCER_SV

/*
 * Class: cdn_gem_demo_virtual_sequencer
 * 
 * This is the cdn_gem_demo UVC virtual sequencer class.
 */
class cdn_gem_demo_virtual_sequencer extends cdn_demo_virtual_sequencer;

  //------------------------------------------------------------------------
  // MEMBER VARIABLES
  //------------------------------------------------------------------------

  /*
   * Variable: enet_seqr
   * 
   * Handle to the cdn_enet_vip sequencer.
   */
  cdn_enet_vip_sequencer enet_seqr;

  /*
   * Variable: p_env
   * 
   * Handle back to the cdn_gem_demo env. This is normally used by sequences via
   * the p_sequencer and gives access to config and monitors.
   */
  cdn_gem_demo_env p_env;

  /*
   * Variable: p_emac_regs0
   * 
   * This is a handle to the register model. This is normally used by sequences 
   * via the p_sequencer and give access to the register model for easier 
   * sequence writing as per uvm_reg methods.
   */
  emac_regs_type p_emac_regs0;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------
  
  `uvm_component_utils_begin(cdn_gem_demo_virtual_sequencer)
    `uvm_field_object(enet_seqr, UVM_DEFAULT|UVM_REFERENCE)
    `uvm_field_object(p_env, UVM_DEFAULT|UVM_REFERENCE)
    `uvm_field_object(p_emac_regs0, UVM_DEFAULT|UVM_REFERENCE)
  `uvm_component_utils_end
  
  //------------------------------------------------------------------------
  // CONSTRUCTOR
  //------------------------------------------------------------------------
  
  /*
   * Constructor: new
   * 
   * The class constructor.
   * It is used to construct cdn_gem_demo_virtual_sequencer objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */  
  function new(string name = "cdn_gem_demo_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //------------------------------------------------------------------------
  // UVM_REG UTILITIES
  //------------------------------------------------------------------------

  /*
   * Method: set_reg_field_value
   * 
   * The following function sets a UVM_REG field value.
   * 
   * Parameters:
   * 
   *     reg_name   - The register name.
   *     field_name - The register field name.
   *     value      - The field value to be set.
   */
  virtual function void set_reg_field_value(string reg_name, string field_name, int unsigned value);
    uvm_reg register;
    uvm_reg_field field;
    int unsigned field_val;
    // Get register
    register = p_emac_regs0.get_reg_by_name(reg_name);
    // Check if register exists
    if (register == null) begin
      `uvm_fatal(get_type_name(), $psprintf("[set_reg_field_value] Cannot find register '%s'", reg_name))
    end
    // Check if field exists
    field = register.get_field_by_name(field_name);
    if (field == null) begin
      `uvm_fatal(get_type_name(), $psprintf("[set_reg_field_value] Cannot find field '%s.%s'", reg_name, field_name))
    end
    // Make sure the value set in the field is of the right size or we get a 
    // UVM_WARNING from UVM_REG
    field_val = ((1<<field.get_n_bits())-1) & value;
    // Set the value of the field to the input value
    field.set(field_val);
  endfunction : set_reg_field_value
  
  /*
   * Method: update_reg
   * 
   * The following task does the actual write to the DUT for the specified
   * register. It effectively wraps the uvm_reg update() method with some
   * checks.
   * 
   * Parameters:
   * 
   *     reg_name - The register name.
   *     status   - The register status.
   */  
  virtual task update_reg(string reg_name, output uvm_status_e status);
    uvm_reg register;
    // Get the register
    register = p_emac_regs0.get_reg_by_name(reg_name);
    // Check if register exists
    if (register == null) begin
      `uvm_fatal(get_type_name(), $psprintf("[update_reg] Cannot find register '%s'", reg_name))
    end
    //Issue a write on the register interface to the DUT
    register.update(status);
  endtask : update_reg
  
  /*
   * Method: read_reg
   * 
   * The following task reads the specified register from the DUT.
   * The register should be specified as a string.
   * 
   * Parameters:
   * 
   *     reg_name - The register name.
   *     value    - The read register value.
   */ 
  virtual task read_reg(string reg_name, output uvm_reg_data_t value);
    uvm_reg       register;
    uvm_reg_field field;
    uvm_status_e  status;
    // Get the register
    register = p_emac_regs0.get_reg_by_name(reg_name);
    // Check if register exists
    if (register == null) begin
      `uvm_fatal(get_type_name(), $psprintf("[read_reg] Cannot find register '%s'", reg_name))
    end
    //Return the read field value 
    register.read(status, value);
    if (status != UVM_IS_OK) begin
      `uvm_fatal(get_type_name(), $psprintf("[read_reg] Read of register %s failed!", reg_name))
    end
    `uvm_info(get_type_name(), $psprintf("[read_reg] Register %s | Value = 0x%0h", reg_name, value), UVM_DEBUG)
  endtask : read_reg
  
  /*
   * Method: write_reg_value
   * 
   * The following task writes a value to the specified DUT register.
   * The register should be specified as a string.
   * 
   * Parameters:
   * 
   *     reg_name - The register name.
   *     value    - The value to write.
   */   
  virtual task write_reg_value(string reg_name, int unsigned value);
    uvm_reg       register;
    uvm_reg_field field;
    uvm_status_e  status;
    // Get the register
    register = p_emac_regs0.get_reg_by_name(reg_name);
    // Check if register exists
    if (register == null) begin
      `uvm_fatal(get_type_name(), $psprintf("[write_reg_value] Cannot find register '%s'", reg_name))
    end
    // Set the value of the field to the input value
    register.write(status, value);
  endtask : write_reg_value

  /*
   * Method: get_reg_field
   * 
   * The following function gets a UVM_REG field from a specified register.
   * 
   * Parameters:
   * 
   *     reg_name   - The register name.
   *     field_name - The register field name.
   */
  virtual function uvm_reg_field get_reg_field(string reg_name, string field_name);
    uvm_reg       register;
    uvm_reg_field field;
    // Get the register and check if exists
    register = p_emac_regs0.get_reg_by_name(reg_name);
    if (register == null) begin
      `uvm_fatal(get_type_name(), $psprintf("[get_reg_field] Cannot find register '%s'", reg_name))
    end
    // Get the field and check if exists
    field = register.get_field_by_name(field_name);
    if (field == null) begin
      `uvm_fatal(get_type_name(), $psprintf("[get_reg_field] Cannot find field '%s.%s'", reg_name, field_name))
    end
    `uvm_info(get_type_name(),
      $psprintf("[get_reg_field] Register '%s' content = \n%s\n", reg_name, register.sprint()),
      UVM_DEBUG)
    `uvm_info(get_type_name(),
      $psprintf("[get_reg_field] Field '%s.%s' content = \n%s\n", reg_name, field_name, register.sprint()),
      UVM_DEBUG)
    //Return the field
    get_reg_field = field;
  endfunction : get_reg_field
  
  /*
   * Method: get_reg_field_value
   * 
   * The following function gets a UVM_REG field value from a specified
   * register.
   * 
   * Parameters:
   * 
   *     reg_name   - The register name.
   *     field_name - The register field name.
   */  
  virtual function uvm_reg_data_t get_reg_field_value(string reg_name, string field_name);
    uvm_reg_field field;  
    // Get the field
    field = get_reg_field(reg_name, field_name);
    //Return the value of the field cast to a bit
    get_reg_field_value = field.get();     
    `uvm_info(get_type_name(),
      $psprintf("[get_reg_field_value] Field '%s.%s' | Value = 0x%0h", reg_name, field_name, get_reg_field_value),
      UVM_DEBUG)
  endfunction : get_reg_field_value

  /*
   * Method: get_reg_field_bit_value
   * 
   * The following function gets a UVM_REG field value from a specified
   * register and returns it casted as a 'bit' type.
   * 
   * Parameters:
   * 
   *     reg_name   - The register name.
   *     field_name - The register field name.
   */ 
  virtual function bit get_reg_field_bit_value(string reg_name, string field_name);
    //Return the value of the field cast to a bit
    get_reg_field_bit_value = bit'(get_reg_field_value(reg_name, field_name));     
    `uvm_info(get_type_name(),
      $psprintf("[get_reg_field_bit_value] Field  value of '%s.%s' = 0x%0h", reg_name, field_name, get_reg_field_bit_value),
      UVM_DEBUG)
  endfunction : get_reg_field_bit_value

endclass : cdn_gem_demo_virtual_sequencer

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
