//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the cdn_axi_vip UVC environment layer.
//----------------------------------------------------------------------------

/*
 * File: cdn_axi_vip_env.sv
 *
 * This file contains the cdn_axi_vip UVC environment layer.
 */

`ifndef CDN_AXI_VIP_ENV_SV
`define CDN_AXI_VIP_ENV_SV

/*
 * Class: cdn_axi_vip_env
 *
 * This is the cdn_axi_vip UVC environment layer for the demo_tb.
 */
class cdn_axi_vip_env
#(
  int unsigned ADDR_WIDTH   = `CDN_AXI_VIP_ADDR_W,
  int unsigned DATA_WIDTH   = `CDN_AXI_VIP_DATA_W,
  int unsigned ID_WIDTH     = `CDN_AXI_VIP_ID_W,
  int unsigned LOCK_WIDTH   = `CDN_AXI_VIP_LOCK_W,
  int unsigned LENGTH_WIDTH = `CDN_AXI_VIP_LENGTH_W,
  int unsigned USER_WIDTH   = `CDN_AXI_VIP_USER_W
) extends uvm_env;

  //----------------------------------------------
  // CONTROL MEMBER VARIABLES
  //----------------------------------------------

  /*
   * Variable: has_active_slave_agent
   *
   * This control knob enables the AXI active slave agent to be generated.
   */
  bit has_active_slave_agent = 1;

  /*
   * Variable: has_passive_master_agent
   *
   * This control knob enables the AXI passive master agent to be generated.
   */
  bit has_passive_master_agent = 1;

  /*
   * Variable: axi_memory_model_initial_value
   *
   * This control knob select the default value of the uninitialized memory
   * model sectors. Valid values are:-
   * - 'h1ff: mark the register as unwritten (default).
   * - 'h0: all zero value
   * - 'h0ff: all one value
   * - 'h0xx: any chosen 8 bit value for xx
   */
  bit [8:0] axi_memory_model_initial_value = 'h1ff;

  //----------------------------------------------
  // REQUIRED COMPONENTS
  //----------------------------------------------

  /*
   * Variable: active_slave
   *
   * This is the active slave agent handle.
   */
  cdn_axi_vip_agent#(.ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH),
                     .ID_WIDTH(ID_WIDTH),
                     .LOCK_WIDTH(LOCK_WIDTH),
                     .LENGTH_WIDTH(LENGTH_WIDTH),
                     .USER_WIDTH(USER_WIDTH)) active_slave;

  /*
   * Variable: passive_master
   *
   * This is the passive master agent handle.
   */
  cdn_axi_vip_agent#(.ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH),
                     .ID_WIDTH(ID_WIDTH),
                     .LOCK_WIDTH(LOCK_WIDTH),
                     .LENGTH_WIDTH(LENGTH_WIDTH),
                     .USER_WIDTH(USER_WIDTH)) passive_master;

  //----------------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------------

  `uvm_component_param_utils_begin(cdn_axi_vip_env#(.ADDR_WIDTH(ADDR_WIDTH),
                                                    .DATA_WIDTH(DATA_WIDTH),
                                                    .ID_WIDTH(ID_WIDTH),
                                                    .LOCK_WIDTH(LOCK_WIDTH),
                                                    .LENGTH_WIDTH(LENGTH_WIDTH),
                                                    .USER_WIDTH(USER_WIDTH)))
    `uvm_field_int(has_active_slave_agent, UVM_DEFAULT)
    `uvm_field_int(has_passive_master_agent, UVM_DEFAULT)
    `uvm_field_int(axi_memory_model_initial_value, UVM_DEFAULT)
  `uvm_component_utils_end

  //----------------------------------------------
  // CONSTRUCTOR
  //----------------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_axi_vip_env objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name = "cdn_axi_vip_env", uvm_component parent = null);
    super.new(name, parent);
    factory.set_type_override_by_type(cdnAxiUvmSequencer::get_type(),cdn_axi_vip_sequencer::get_type());
    factory.set_type_override_by_type(cdnAxiUvmDriver::get_type(),cdn_axi_vip_driver::get_type());
    factory.set_type_override_by_type(cdnAxiUvmMonitor::get_type(),cdn_axi_vip_monitor::get_type());
    factory.set_type_override_by_type(cdnAxiUvmConfig::get_type(),cdn_axi_vip_config::get_type());
    factory.set_type_override_by_type(cdnAxiUvmCoverage::get_type(),cdn_axi_vip_coverage::get_type());
    factory.set_type_override_by_type(cdnAxiUvmInstance::get_type(),cdn_axi_vip_instance::get_type());
    factory.set_type_override_by_type(cdnAxiUvmMemInstance::get_type(),cdn_axi_vip_mem_instance::get_type());
  endfunction : new

  //----------------------------------------------
  // UVM PHASES
  //----------------------------------------------

   /*
    * Method: build_phase
    *
    * This UVM phase is used for building the testbench component hierarchy.
    * For cdn_axi_vip_env, it constructs and configures active and passive slave agents.
    *
    * Parameters:
    *
    *    phase - The UVM phase object.
    */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get the memory model initial value if set otherwise stick with the default.
    void'(uvm_config_db#(int)::get(this, "", "axi_memory_model_initial_value", axi_memory_model_initial_value));
    `uvm_info(get_type_name(), $psprintf("Setting | axi_memory_model_initial_value = 0x%h", axi_memory_model_initial_value), UVM_HIGH);

    // Active Slave
    if (has_active_slave_agent) begin
      active_slave = cdn_axi_vip_agent#(.ADDR_WIDTH(ADDR_WIDTH),
                                        .DATA_WIDTH(DATA_WIDTH),
                                        .ID_WIDTH(ID_WIDTH),
                                        .LOCK_WIDTH(LOCK_WIDTH),
                                        .LENGTH_WIDTH(LENGTH_WIDTH),
                                        .USER_WIDTH(USER_WIDTH))::type_id::create("active_slave", this);
      begin
        cdn_axi_vip_config active_slave_cfg = cdn_axi_vip_config::type_id::create("active_slave_cfg",this);

        // General config
        active_slave_cfg.is_active               = UVM_ACTIVE;
        active_slave_cfg.PortType                = CDN_AXI_CFG_SLAVE;
        active_slave_cfg.verbosity               = CDN_AXI_CFG_MESSAGEVERBOSITY_NONE;
        active_slave_cfg.enable_tracker          = 0;
        active_slave_cfg.reset_signals_sim_start = 1;
        active_slave_cfg.has_tr_recording        = 0;

        // Memory related config
        active_slave_cfg.use_memory              = 1;
        active_slave_cfg.initial_memory_value    = axi_memory_model_initial_value;
        active_slave_cfg.read_data_width         = DATA_WIDTH;
        active_slave_cfg.write_data_width        = DATA_WIDTH;
        active_slave_cfg.addr_width              = ADDR_WIDTH;
        active_slave_cfg.addToMemorySegments(0,(2**ADDR_WIDTH)-1,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);

        // Set config object
        uvm_config_object::set(this,"active_slave", "cfg", active_slave_cfg);
      end
    end

    // Passive Master
    if (has_passive_master_agent) begin
      passive_master = cdn_axi_vip_agent#(.ADDR_WIDTH(ADDR_WIDTH),
                                          .DATA_WIDTH(DATA_WIDTH),
                                          .ID_WIDTH(ID_WIDTH),
                                          .LOCK_WIDTH(LOCK_WIDTH),
                                          .LENGTH_WIDTH(LENGTH_WIDTH),
                                          .USER_WIDTH(USER_WIDTH))::type_id::create("passive_master", this);
      begin
        cdn_axi_vip_config passive_master_cfg = cdn_axi_vip_config::type_id::create("passive_master_cfg",this);

        // General config
        passive_master_cfg.is_active                = UVM_PASSIVE;
        passive_master_cfg.PortType                 = CDN_AXI_CFG_MASTER;
        passive_master_cfg.verbosity                = CDN_AXI_CFG_MESSAGEVERBOSITY_NONE;
        passive_master_cfg.checks_performance_level = CDN_AXI_CFG_CHECKS_PERFORMANCE_LEVEL_HIGH;
        passive_master_cfg.enable_tracker           = 0;
        passive_master_cfg.reset_signals_sim_start  = 1;
        passive_master_cfg.has_tr_recording         = 0;

        // Memory related config
        passive_master_cfg.use_memory               = 0;
        passive_master_cfg.read_data_width          = DATA_WIDTH;
        passive_master_cfg.write_data_width         = DATA_WIDTH;
        passive_master_cfg.addr_width               = ADDR_WIDTH;
        passive_master_cfg.addToMemorySegments(0,(2**ADDR_WIDTH)-1,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);

        // Set config object
        uvm_config_object::set(this,"passive_master", "cfg", passive_master_cfg);
      end
    end
  endfunction : build_phase

  /*
   * Method: end_of_elaboration_phase
   *
   * This UVM phase is related to post-elaboration activities.
   * For cdn_axi_vip_env, it enables callbacks for error
   * and transfer ended from the active slave.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    // Enable PureSpec callbacks. Comment / Uncomment as necessary
    `uvm_info(get_type_name(), "Setting callbacks", UVM_DEBUG);
    void'(active_slave.inst.setCallback(DENALI_CDN_AXI_CB_EndedTransfer));
    // Disable the agents for UVM_REG tests
    `ifdef CDN_GEM_DEMO_UVM_REG_TESTS
      if(has_active_slave_agent)
        active_slave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableAgent, 1);
      if(has_passive_master_agent)
        passive_master.regInst.writeReg(DENALI_CDN_AXI_REG_DisableAgent, 1);
    `endif
    `uvm_info(get_type_name(), "Setting callbacks ... DONE", UVM_DEBUG);
  endfunction : end_of_elaboration_phase

  /*
   * Method: run_phase
   *
   * This UVM phase performs the DUT simulation.
   *
   * Parameters:
   *
   *   phase - The UVM phase object.
   */
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass : cdn_axi_vip_env

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
