//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the cdn_apb_vip UVC environment layer.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_env.sv
 *
 * This file contains the cdn_apb_vip UVC environment layer.
 */

`ifndef CDN_APB_VIP_ENV_SV
`define CDN_APB_VIP_ENV_SV

/*
 * Class: cdn_apb_vip_env
 *
 * This is the cdn_apb_vip UVC environment layer for the demo testbench.
 * Note that the "normal" VIP way of doing things is to have an active component
 * connected to the DUT, and a passive component of the opposite type which
 * monitors the interface and ensures protocol compliance. So in a normal
 * application, there will be a single master and one or more slave agents,
 * with either the master or the slave components being passive.
 * This UVC is written for a single interface, and for the agents to be of the
 * same type (i.e. either active master or active slaves). If an additional APB
 * interface is required then the UVC should be instantiated again.
 */
class cdn_apb_vip_env#(int NUM_OF_SLAVES=1, ADDRESS_WIDTH=32, DATA_WIDTH=32) extends uvm_env;

  //------------------------------------------------------------------------
  // CONTROL MEMBER VARIABLES
  //------------------------------------------------------------------------

  /*
   * Variable: is_master
   *
   * This variable determines whether an active master or an active slave is
   * used for the UVC.
   */
  bit is_master = 1;

  /*
   * Variable: is_active
   *
   * This control knob enabled the complete APB env to be switching into passive
   * mode, i.e. only the passive agents are present.
   */
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  /*
   * Variable: base_apb_cfg
   *
   * Base config object for passing to agents. If this is not set a default
   * config object will be created.
   */
  cdn_apb_vip_config base_apb_cfg;

  //------------------------------------------------------------------------
  // COMPONENTS
  //------------------------------------------------------------------------

  /*
   * Variable: master_agents
   *
   * This variable is an handle to the master agent.
   */
  cdn_apb_vip_master_agent#(NUM_OF_SLAVES, ADDRESS_WIDTH, DATA_WIDTH) master_agent;

  /*
   * Variable: slave_agents
   *
   * This variable is an handle to slave agents.
   */
  cdn_apb_vip_slave_agent#(ADDRESS_WIDTH, DATA_WIDTH) slave_agent[];

  /*
   * Variable: master_apb_cfg
   *
   * Config objects for the master agent.
   */
  cdn_apb_vip_config master_apb_cfg;

  /*
   * Variable: slave_apb_cfg
   *
   * Config objects for slave agents.
   */
  cdn_apb_vip_config slave_apb_cfg[];

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------

  `uvm_component_param_utils_begin(cdn_apb_vip_env#(NUM_OF_SLAVES, ADDRESS_WIDTH, DATA_WIDTH))
    `uvm_field_int(is_master, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_component_utils_end

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_apb_vip_env objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name = "cdn_apb_vip_env", uvm_component parent = null);
    super.new(name, parent);
    slave_agent   = new[NUM_OF_SLAVES];
    slave_apb_cfg = new[NUM_OF_SLAVES];
    factory.set_type_override_by_type(cdnApbUvmSequencer::get_type(), cdn_apb_vip_sequencer::get_type());
    factory.set_type_override_by_type(cdnApbUvmDriver::get_type(), cdn_apb_vip_driver::get_type());
    factory.set_type_override_by_type(cdnApbUvmMonitor::get_type(), cdn_apb_vip_monitor::get_type());
    factory.set_type_override_by_type(cdnApbUvmConfig::get_type(), cdn_apb_vip_config::get_type());
    factory.set_type_override_by_type(cdnApbUvmCoverage::get_type(), cdn_apb_vip_coverage::get_type());
    factory.set_type_override_by_type(cdnApbUvmInstance::get_type(), cdn_apb_vip_instance::get_type());
  endfunction : new

  /*
   * Method: build_phase
   *
   * This UVM phase is used for building the testbench component hierarchy.
   * For cdn_apb_vip_env, it constructs and configures active master and passive
   * slave agents.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void build_phase(uvm_phase phase);
    bit [63:0] base_addr          = 64'h0;
    bit [63:0] end_addr           = 64'h000_0000_0fff_ffff;
    bit [63:0] default_addr_range = 64'h0;

    // Call the parent build phase
    super.build_phase(phase);

    // Get base config object, if it's been passed to the UVC
    if (!uvm_config_db#(cdn_apb_vip_config)::get(this, "", "base_apb_cfg", base_apb_cfg)) begin
      `uvm_info(get_type_name(), "[APB config] base_apb_cfg not passed to UVC: creating local copy", UVM_LOW)
      base_apb_cfg = cdn_apb_vip_config::type_id::create("base_apb_cfg", this);
      base_apb_cfg.addr_width                = ADDRESS_WIDTH;
      base_apb_cfg.data_width                = DATA_WIDTH;
      base_apb_cfg.verbosity                 = CDN_APB_CFG_MESSAGEVERBOSITY_LOW;
      base_apb_cfg.endianity                 = CDN_APB_CFG_ENDIANITY_LITTLE;
      base_apb_cfg.enable_tracker            = 0;
      base_apb_cfg.check_prdata_for_x_and_z  = 0;
      `ifdef CDN_APB_VIP_IF_APB4
        base_apb_cfg.use_apb_amba4_extension = 1;
      `endif
      // Large timeout value required for when we have an 800MHz APB clock
      base_apb_cfg.transfer_timeout          = 10000;
      base_apb_cfg.use_memory                = 0;
    end

    //---------------
    // Master Config
    //---------------

    if (!is_master || is_active == UVM_ACTIVE) begin
      if (!$cast(master_apb_cfg, base_apb_cfg.clone())) begin
        `uvm_fatal(get_type_name(), "Could not clone base_apb_cfg for master")
      end
      master_apb_cfg.is_active               = is_master ? UVM_ACTIVE : UVM_PASSIVE;
      master_apb_cfg.DeviceType              = CDN_APB_CFG_MASTER;
      master_apb_cfg.number_of_slaves        = NUM_OF_SLAVES;
      master_apb_cfg.reset_signals_sim_start = is_master;
      for (int i=0; i<NUM_OF_SLAVES; i++) begin
        // Base Address
        if (!uvm_config_db#(bit [63:0])::get(this, "", $psprintf("base_addr[%0d]", i), base_addr)) begin
          `uvm_warning(get_type_name(),
            $psprintf("[APB config] Adding slave to master segment using default, base address not set | base_addr[%0d] = 0x%0h",
            i, base_addr))
        end else begin
          `uvm_info(get_type_name(),
            $psprintf("[APB config] Adding slave to master segment | base_addr[%0d] = 0x%0h",
            i, base_addr), UVM_LOW);
        end
        // End Address
        if (!uvm_config_db#(bit [63:0])::get(this, "", $psprintf("end_addr[%0d]", i), end_addr)) begin
          `uvm_warning(get_type_name(),
            $psprintf("[APB config] Adding slave to master segment using default, end address not set | end_addr[%0d] = 0x%0h",
            i, end_addr))
        end else begin
          `uvm_info(get_type_name(),
            $psprintf("[APB config] Adding slave to master segment | end_addr[%0d] = 0x%0h",
            i, end_addr), UVM_LOW);
        end
        master_apb_cfg.addToAddressSegments(base_addr, end_addr, i);
        // Calculate the next address, in case not provided to UVC
        default_addr_range = end_addr  - base_addr + 1;
        base_addr          = base_addr + default_addr_range;
        end_addr           = end_addr  + default_addr_range;
      end
      // Set config
      uvm_config_object::set(this, "master_agent","cfg", master_apb_cfg);
      // Create agent
      master_agent = cdn_apb_vip_master_agent#(NUM_OF_SLAVES, ADDRESS_WIDTH, DATA_WIDTH)::type_id::create("master_agent", this);
    end

    //-----------------
    // Slave Configs
    //-----------------

    if (is_master || is_active == UVM_ACTIVE) begin
      for (int i=0; i<NUM_OF_SLAVES; i++) begin
        if (!$cast(slave_apb_cfg[i], base_apb_cfg.clone())) begin
          `uvm_fatal(get_type_name(), "Could not clone base_apb_cfg for slave")
        end
        slave_apb_cfg[i].is_active               = is_master ? UVM_PASSIVE : UVM_ACTIVE;
        slave_apb_cfg[i].DeviceType              = CDN_APB_CFG_SLAVE;
        slave_apb_cfg[i].number_of_slaves        = 1;
        slave_apb_cfg[i].reset_signals_sim_start = !is_master;
        // Set config
        uvm_config_object::set(this, $psprintf("slave_agent[%0d]", i), "cfg", slave_apb_cfg[i]);
        // Create agent
        slave_agent[i] = cdn_apb_vip_slave_agent#(ADDRESS_WIDTH, DATA_WIDTH)::type_id::create($psprintf("slave_agent[%0d]", i), this);
      end
    end
  endfunction : build_phase

  /*
   * Method: end_of_elaboration_phase
   *
   * This UVM phase is related to post-elaboration activities.
   * For cdn_apb_vip_env, it enables callbacks for error and transfer ended from
   * the passive agents.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(), "Setting callbacks", UVM_DEBUG)
    // Enable PureSpec callbacks. Comment / Uncomment as necessary
    // Passive agents
    if (is_master) begin
      void'(master_agent.inst.setCallback( DENALI_CDN_APB_CB_Error));
      void'(master_agent.inst.setCallback( DENALI_CDN_APB_CB_MonTransferEnded));
      master_agent.regInst.writeReg(DENALI_CDN_APB_REG_UseMemory, 0);
      // Setting not to check for X/Z on any APB bus signal via regInst
      // (including prdata), as config object settings do no work below VIPCAT
      // 11.30.51 (see support ticket: 46199834):
      master_agent.regInst.writeReg(DENALI_CDN_APB_REG_CheckForXAndZ, 0);
      master_agent.regInst.writeReg(DENALI_CDN_APB_REG_CheckPrdataForXAndZ, 0);
    end else begin
      for (int i=0; i<NUM_OF_SLAVES; i++) begin
        void'(slave_agent[i].inst.setCallback( DENALI_CDN_APB_CB_Error));
        void'(slave_agent[i].inst.setCallback( DENALI_CDN_APB_CB_MonTransferEnded));
        // Setting use_memory=0 from config object is broken for VIPCAT
        // 11.30.043. Using VIP register write instead:
        slave_agent[i].regInst.writeReg(DENALI_CDN_APB_REG_UseMemory, 0);
        // Setting not to check for X/Z on any APB bus signal via regInst
        // (including prdata), as config object settings do no work below VIPCAT
        // 11.30.51 (see support ticket: 46199834):
        slave_agent[i].regInst.writeReg(DENALI_CDN_APB_REG_CheckForXAndZ, 0);
        slave_agent[i].regInst.writeReg(DENALI_CDN_APB_REG_CheckPrdataForXAndZ, 0);
        //if (i>=1) begin
        //  slave_agent[i].regInst.writeReg(DENALI_CDN_APB_REG_DisableAgent, 1);
        //end
      end
    end
    `uvm_info(get_type_name(), "Setting callbacks ... DONE", UVM_DEBUG)
  endfunction : end_of_elaboration_phase

endclass : cdn_apb_vip_env

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
