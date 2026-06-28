//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CUSTOMER_DEMO_ENV_SV
`define CUSTOMER_DEMO_ENV_SV

//------------------------------------------------------------------------
// Class: customer_demo_env
//
// This class defines the top level verification environment for the
// demo TB customer derivative i.e. with customer specific bus UVCs.
// In this example duplicate APB/AXI UVCs are used.
// The config_object.has_[passive|active]_[axi|apb] variables are also set
// here in the build_phase to stop super.build_phase (e.g. the base
// cdn_demo_env) instantiating the AXI and APB components.
//
//------------------------------------------------------------------------

class customer_demo_env extends cdn_demo_env;

  //------------------------------------------------------------------------
  // REQUIRED COMPONENTS
  //------------------------------------------------------------------------

  // Variable: customer_demo_sys_bus_env
  // Customer UVC env for the system bus (i.e. whatever is bridged over AXI).
  cdn_axi_vip_env#(.ADDR_WIDTH(`CDN_AXI_VIP_ADDR_W), .DATA_WIDTH(`CDN_AXI_VIP_DATA_W),.ID_WIDTH(`CDN_AXI_VIP_ID_W),.LOCK_WIDTH(`CDN_AXI_VIP_LOCK_W),.LENGTH_WIDTH(`CDN_AXI_VIP_LENGTH_W),.USER_WIDTH(`CDN_AXI_VIP_USER_W)) customer_sys_bus_env;

  // Variable: customer_reg_bus_env
  // Customer UVC env for the register bus (i.e. whatever is bridged over APB).
  cdn_apb_vip_env#(.NUM_OF_SLAVES(`CDN_DEMO_APB_NUM_OF_SLAVES),.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH)) customer_reg_bus_env;

  // Customer specific reg map - instantiates Cadence reg map at same
  // hierarchy level as some additional customer components.
  customer_demo_reg_map customer_reg_map;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------
  `uvm_component_utils(customer_demo_env)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  // This function also setups the modified report capture policy for this
  // VE.
  //------------------------------------------------------------------------
  function new(string name = "customer_demo_env", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  //------------------------------------------------------------------------
  // Function: build_phase
  // Builds the VE and creates all of the VE components
  //------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    // Get the config object - this is also called by the super.build_phase,
    // but we want to manipulate the has_[active|passive] variables before the
    // super.build_phase. Note super.build_phase is called later in this
    // routine.
    if (!uvm_config_db#(cdn_demo_config_object)::get(this, "", "config_object", config_object)) begin
    `uvm_fatal(get_type_name(), "cdn_demo_config_object object not set")
    end

    // Customer register bus and system bus environments
    customer_reg_bus_env = cdn_apb_vip_env#(.NUM_OF_SLAVES(`CDN_DEMO_APB_NUM_OF_SLAVES),.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH))::type_id::create("customer_reg_bus_env", this);
    customer_sys_bus_env = cdn_axi_vip_env#(.ADDR_WIDTH(`CDN_AXI_VIP_ADDR_W), .DATA_WIDTH(`CDN_AXI_VIP_DATA_W),.ID_WIDTH(`CDN_AXI_VIP_ID_W),.LOCK_WIDTH(`CDN_AXI_VIP_LOCK_W),.LENGTH_WIDTH(`CDN_AXI_VIP_LENGTH_W),.USER_WIDTH(`CDN_AXI_VIP_USER_W))::type_id::create("customer_sys_bus_env", this);

    // Create the customer reg map
    customer_reg_map = customer_demo_reg_map::type_id::create("customer_reg_map", this);
    customer_reg_map.build();

    // Set the Number of Outstanding Transactions. This will be changed by the
    // customer, but the point of the example is to connect a new customer_sys_bus_env. The
    // settings are however just taken from the standard config_object and
    // this will be changed by the customer. The same also applies to the AMBA
    // spec version.
    uvm_config_db#(int)::set(this,"customer_sys_bus_env","master_axi_max_num_outstanding_wr",config_object.master_axi_max_num_outstanding_wr);
    uvm_config_db#(int)::set(this,"customer_sys_bus_env","master_axi_max_num_outstanding_rd",config_object.master_axi_max_num_outstanding_rd);
    uvm_config_db#(int)::set(this,"customer_sys_bus_env","slave_axi_max_num_outstanding_wr",config_object.slave_axi_max_num_outstanding_wr);
    uvm_config_db#(int)::set(this,"customer_sys_bus_env","slave_axi_max_num_outstanding_rd",config_object.slave_axi_max_num_outstanding_rd);
    uvm_config_db#(cdnAxiCfgSpecVerT)::set(this,"customer_sys_bus_env","amba_spec_ver",config_object.amba_spec_ver);

    // Disable the AXI and APB components before calling super.build - this
    // will stop the AXI and APB components being connected, including any
    // associated hook-up
    config_object.has_active_apb = 0;
    config_object.has_passive_apb = 0;
    config_object.has_active_axi = 0;
    config_object.has_passive_axi = 0;

    // Call super.build_phase. For this call the config_object items set above
    // will impact super.build_phase and the AXI/APB components will be built
    // as per the passive/active settings
    super.build_phase(phase);

  endfunction : build_phase

  //------------------------------------------------------------------------
  // Function: connect_phase
  // Connect all of the VE pointers between components and connect TLMs
  // ports.
  //------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);

    customer_demo_sys_bus_memory_adapter _memory_adapter;
    customer_demo_sys_bus_reg_adapter _reg_adapter;

    super.connect_phase(phase);

    // The system and reg base adapters have an override to the customer
    // specific adapters. When the base adapters are created (overridden) they
    // are the specialized customer class but we still need to cast them from the
    // base class type to the specialized customer type when we use them.
    $cast(_reg_adapter, reg_adapter);
    $cast(_memory_adapter, memory_adapter);

    // Connect ports for customer sys bus
    customer_sys_bus_env.active_slave.monitor.EndedTransferCbPort.connect(_memory_adapter.customer_sys_bus_transfer_imp);
    // Only connect the callbacks if we are using C and want to write to
    // C memory.
    `ifdef CDN_DEMO_C
    void'(customer_sys_bus_env.active_slave.inst.setCallback(DENALI_CDN_AXI_CB_Ended));
    void'(customer_sys_bus_env.active_slave.inst.setCallback(DENALI_CDN_AXI_CB_BeforeSendResponse));
    customer_sys_bus_env.active_slave.monitor.EndedCbPort.connect(_memory_adapter.customer_sys_bus_DriverTransactionEnded);
    customer_sys_bus_env.active_slave.monitor.BeforeSendResponseCbPort.connect(_memory_adapter.customer_sys_bus_DriverTransactionBeforeSendResponse);
    `endif

    // Do the reg bus hook-up and call backs for reg1 - these are connected to
    // the customer reg buses, rather than the base Cadence APB connections.
    regs1 = customer_reg_map.cdn_ram_stub_addr_map;
    customer_reg_map.default_map.set_sequencer(customer_reg_bus_env.master_agent.sequencer, _reg_adapter);
    void'(customer_reg_bus_env.slave_agent[1].inst.setCallback(DENALI_CDN_APB_CB_MonTransferEnded));
    reg1_predictor.map = customer_reg_map.default_map;
    reg1_predictor.adapter = _reg_adapter;
    customer_reg_bus_env.slave_agent[1].monitor.MonTransferEndedCbPort.connect(reg1_predictor.bus_in);
    customer_reg_map.default_map.set_auto_predict(0);
    customer_reg_map.default_map.set_check_on_read(0);

    // Connect up the driver and the env to allow the adapters to function
    _reg_adapter.driver = customer_reg_bus_env.master_agent.driver;
    _memory_adapter.p_customer_env = this;

  endfunction : connect_phase

endclass : customer_demo_env

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------

