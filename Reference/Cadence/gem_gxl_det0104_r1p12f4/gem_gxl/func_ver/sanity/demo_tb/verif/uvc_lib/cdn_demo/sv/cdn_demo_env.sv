//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_ENV_SV
`define CDN_DEMO_ENV_SV

//----------------------------------------------------------------------------
// Class: cdn_demo_env
// This class contains the base cdn_demo_env that the user should extend from
// to generate protocol specific environment details. The base class provides
// the following functionality:
// - Instantiates and configures the clock and reset UVCs.
// - Instantiates and configures the AHB and APB UVCs.
// - Instantiates the UVM_REG class. Note. The protocol specific test
//   creates the protocol specific UVM_REG file and adds this class to the
//   config_db. This base env then simply picks up the UVM_REG class from the
//   config_db.
// - Instantiates and configures the AXI adapter layer. This adapter layer
//   can be overwritten by the customer to provide a customer specific adapter
//   layer.
//
//----------------------------------------------------------------------------

class cdn_demo_env extends uvm_env;

   //------------------------------------------------------------------------
   // CONTROL MEMBER VARIABLES.
   //------------------------------------------------------------------------

   // Variable: integration_mode
   // This member variable controls this environment for reuse at the next
   // level of abstraction i.e. stack or sub/system level
   // TODO: You as the developer need to work out what this switch does based
   // on the requirements from the customer. For example it might put all
   // interface UVCs into passive mode and keep the chip facing interface UVC
   // in active mode.
   bit integration_mode = 1;

   // Variable: is_active
   // This member variable controls if the Module UVC env is active or
   // passive i.e. is it a stand alone module level env - UVM_ACTIVE or
   // is it part of a system/sub-system level env - UVM_PASSIVE.
   uvm_active_passive_enum is_active = UVM_ACTIVE;

   // Variable: config_object
   // Config Object for this cdn_demo_tb
   cdn_demo_config_object config_object;

   //------------------------------------------------------------------------
   // COMPONENTS.
   //------------------------------------------------------------------------

   // The misc signals driver is a component of this module level env that
   // is used to drive the misc signals that are not encapsulated with an UVC.
   // It should contain methods that the virtual sequences can use to
   // drive these signals sets.
   cdn_demo_misc_signals_driver misc_signals_driver;

   // The virtual sequencer is a component of this module level env and
   // controls all active UVCs that are instantiated in this environment.
   cdn_demo_virtual_sequencer virtual_sequencer;

   // System adapters - add an abstraction layer that is easy to swap out AXI
   // or APB for an alternate implementation.
   cdn_demo_sys_bus_memory_adapter memory_adapter;
   cdn_demo_sys_bus_reg_adapter reg_adapter;

   // A customer report catcher is required to add the fail message/banner
   // to the demo_tb. This way will catch every fatat/error as it happens i.e.
   // the fail message/banner will be printed before the simualtor exits.
   cdn_demo_report_catcher report_catcher;

   //------------------------------------------------------------------------
   // UVC ENVS.
   //------------------------------------------------------------------------

   // Add an instance of the cdn_clock UVC env
   cdn_clock_pkg::cdn_clock_agent clock_env0;
   cdn_clock_pkg::cdn_clock_agent clock_env1;
   cdn_clock_pkg::cdn_clock_agent clock_env2;
   cdn_clock_pkg::cdn_clock_agent clock_env3;
   cdn_clock_pkg::cdn_clock_agent clock_env_csp_delay_us;

   // Add an instance of the cdn_reset UVC env
   cdn_reset_pkg::cdn_reset_env reset_env0;
   cdn_reset_pkg::cdn_reset_env reset_env1;
   cdn_reset_pkg::cdn_reset_env reset_env2;
   cdn_reset_pkg::cdn_reset_env reset_env3;

   // APB Env
   cdn_apb_vip_env#(.NUM_OF_SLAVES(`CDN_DEMO_APB_NUM_OF_SLAVES),.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH)) apb_env;
   cdn_axi_vip_env#(.ADDR_WIDTH(`CDN_AXI_VIP_ADDR_W), .DATA_WIDTH(`CDN_AXI_VIP_DATA_W),.ID_WIDTH(`CDN_AXI_VIP_ID_W),.LOCK_WIDTH(`CDN_AXI_VIP_LOCK_W),.LENGTH_WIDTH(`CDN_AXI_VIP_LENGTH_W),.USER_WIDTH(`CDN_AXI_VIP_USER_W)) axi_env;

   //------------------------------------------------------------------------
   // Internal Classes
   //------------------------------------------------------------------------

   // uvm_reg register bank for the main control apb bank and an additional
   // regs bank that is most like to be used for the PHY.
   uvm_reg_block regs0;
   uvm_reg_predictor#(denaliCdn_apbTransaction) reg0_predictor;
   uvm_reg_block regs1;
   uvm_reg_predictor#(denaliCdn_apbTransaction) reg1_predictor;

   //------------------------------------------------------------------------
   // UVM AUTOMATION MACROS.
   //------------------------------------------------------------------------

   // The component utils macro provides base virtual methods like
   // get_type_name and create.
   `uvm_component_utils_begin(cdn_demo_env)
      `uvm_field_int(integration_mode, UVM_DEFAULT)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
      `uvm_field_object(config_object, UVM_DEFAULT)
      `uvm_field_object(report_catcher, UVM_DEFAULT)
   `uvm_component_utils_end

   //------------------------------------------------------------------------
   // EXTEND OR OVERRIDE BASE METHODS
   //------------------------------------------------------------------------

   //------------------------------------------------------------------------
   // Function: new
   // Creates and initializes a new object for this class.
   // Also, setups the modified report capture policy for this VE.
   //------------------------------------------------------------------------
   function new (string name, uvm_component parent);
      super.new(name, parent);
      regs0 = null;
      regs1 = null;
      // Setup customer report catcher to print test fail banner on uvm_error or uvm_fatal
      report_catcher = new;
      // Note that null in this add ensures that ALL report captures get replaced with our version
      uvm_report_cb::add(null,report_catcher);
   endfunction : new

   //------------------------------------------------------------------------
   // Function: build_phase
   // Build and configure the clock, reset, apb, axi and adapter UVCs.
   //------------------------------------------------------------------------
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // TODO: Configure the env and UVCs here:

      // Configure the reset env to have one agent.
      uvm_config_db#(int)::set(this,"reset_env0","number_of_agents", 1);
      // Configure the reset agent to be active or passive based on this env..
      uvm_config_db#(int)::set(this,"reset_env0.agents[0]", "is_active", this.is_active);

      // Configure the clock agent to be active or passive based on this env..
      uvm_config_db#(int)::set(this,"clock_env0.agent", "is_active", this.is_active);

      // Get the config object
      if (!uvm_config_db#(cdn_demo_config_object)::get(this, "", "config_object", config_object)) begin
         `uvm_fatal(get_type_name(), "cdn_demo_config_object object not set")
      end

      if(is_active == UVM_ACTIVE) begin
         // Create the virtual sequence driver
         virtual_sequencer = cdn_demo_virtual_sequencer::type_id::create("virtual_sequencer", this);
         // Create the misc signals driver
         misc_signals_driver = cdn_demo_misc_signals_driver::type_id::create("misc_signals_driver", this);
      end

      // Configure clock envs as per the config objects
      uvm_config_db#(int)::set(this,"clock_env0", "clk_ref", config_object.clk0_period);
      uvm_config_db#(int)::set(this,"clock_env0", "clk_div0",  1);
      uvm_config_db#(int)::set(this,"clock_env1", "clk_ref", config_object.clk1_period);
      uvm_config_db#(int)::set(this,"clock_env1", "clk_div0",  1);
      uvm_config_db#(int)::set(this,"clock_env2", "clk_ref", config_object.clk2_period);
      uvm_config_db#(int)::set(this,"clock_env2", "clk_div0",  1);
      uvm_config_db#(int)::set(this,"clock_env3", "clk_ref", config_object.clk3_period);
      uvm_config_db#(int)::set(this,"clock_env3", "clk_div0",  1);

      // ***********************************************************************
      // *************** TEMPORARY TEMPORARY TEMPORARY *************************
      // *************** TEMPORARY TEMPORARY TEMPORARY *************************
      // *************** TEMPORARY TEMPORARY TEMPORARY *************************
      // NOTE. THE CONFIG_DB CALL BELOW IS TEMPORARY ONLY TO SAVE POINTLESS
      // WORKAROUNDS AND IS ONLY NEEDED UNTIL THE CDN_SD4HC_DEMO ALIGNS WITH THE
      // BARE METAL DRIVER.
      // ***********************************************************************
      `ifdef CDN_SD4HC_DEMO
      uvm_config_db#(int)::set(this,"clock_env_csp_delay_us", "clk_ref", 5000);
      `else
      // ***********************************************************************
      // Uses a fixed 1us clock
      uvm_config_db#(int)::set(this,"clock_env_csp_delay_us", "clk_ref", 1_000_000);
      `endif
      uvm_config_db#(int)::set(this,"clock_env_csp_delay_us", "clk_div0",  1);
      // Create the required clock andUVC envs.
      clock_env0 = cdn_clock_pkg::cdn_clock_agent::type_id::create("clock_env0", this);
      clock_env1 = cdn_clock_pkg::cdn_clock_agent::type_id::create("clock_env1", this);
      clock_env2 = cdn_clock_pkg::cdn_clock_agent::type_id::create("clock_env2", this);
      clock_env3 = cdn_clock_pkg::cdn_clock_agent::type_id::create("clock_env3", this);
      clock_env_csp_delay_us = cdn_clock_pkg::cdn_clock_agent::type_id::create("clock_env_csp_delay_us", this);
      reset_env0 = cdn_reset_pkg::cdn_reset_env::type_id::create("reset_env0", this);
      reset_env1 = cdn_reset_pkg::cdn_reset_env::type_id::create("reset_env1", this);
      reset_env2 = cdn_reset_pkg::cdn_reset_env::type_id::create("reset_env2", this);
      reset_env3 = cdn_reset_pkg::cdn_reset_env::type_id::create("reset_env3", this);

      // APB Env
      if (config_object.has_active_apb == 1 || config_object.has_passive_apb == 1) begin
         uvm_config_db#(int)::set(this,"apb_env","is_master",1);
         if (config_object.has_active_apb) begin
            uvm_config_db#(int)::set(this,"apb_env","is_active",UVM_ACTIVE);
         end
         else begin
            uvm_config_db#(int)::set(this,"apb_env","is_active",UVM_PASSIVE);
         end
         apb_env = cdn_apb_vip_env#(.NUM_OF_SLAVES(`CDN_DEMO_APB_NUM_OF_SLAVES),.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH))::type_id::create("apb_env", this);
      end
      // AXI Env
      uvm_config_db#(int)::set(this,"axi_env","has_active_slave_agent",config_object.has_active_axi);
      uvm_config_db#(int)::set(this,"axi_env","has_passive_master_agent",config_object.has_passive_axi);
      if (config_object.has_active_axi == 1 || config_object.has_passive_axi == 1) begin
         axi_env = cdn_axi_vip_env#(.ADDR_WIDTH(`CDN_AXI_VIP_ADDR_W), .DATA_WIDTH(`CDN_AXI_VIP_DATA_W),.ID_WIDTH(`CDN_AXI_VIP_ID_W),.LOCK_WIDTH(`CDN_AXI_VIP_LOCK_W),.LENGTH_WIDTH(`CDN_AXI_VIP_LENGTH_W),.USER_WIDTH(`CDN_AXI_VIP_USER_W))::type_id::create("axi_env", this);
         // Set the AXI spec version
         uvm_config_db#(cdnAxiCfgSpecVerT)::set(this,"axi_env","amba_spec_ver",config_object.amba_spec_ver);
         // And the Number of Outstanding Transactions
         uvm_config_db#(int)::set(this,"axi_env","master_axi_max_num_outstanding_wr",config_object.master_axi_max_num_outstanding_wr);
         uvm_config_db#(int)::set(this,"axi_env","master_axi_max_num_outstanding_rd",config_object.master_axi_max_num_outstanding_rd);
         uvm_config_db#(int)::set(this,"axi_env","slave_axi_max_num_outstanding_wr",config_object.slave_axi_max_num_outstanding_wr);
         uvm_config_db#(int)::set(this,"axi_env","slave_axi_max_num_outstanding_rd",config_object.slave_axi_max_num_outstanding_rd);

     end

      // Create the register model
      if (!uvm_config_db#(uvm_reg_block)::get(this, "", "regs0", regs0)) begin
         `uvm_warning(get_type_name(), "No register block specified")
      end
      else begin
         reg0_predictor = uvm_reg_predictor#(denaliCdn_apbTransaction)::type_id::create("reg0_predictor", this);
      end
      // Create the register model
      if (!uvm_config_db#(uvm_reg_block)::get(this, "", "regs1", regs1)) begin
         `uvm_info(get_type_name(), "No register 1 block (potentially for the PHY) specified", UVM_LOW)
      end
      else begin
         reg1_predictor = uvm_reg_predictor#(denaliCdn_apbTransaction)::type_id::create("reg1_predictor", this);
      end

      // Create the adapters
      reg_adapter = cdn_demo_sys_bus_reg_adapter::type_id::create("reg_adapter", this);
      memory_adapter = cdn_demo_sys_bus_memory_adapter::type_id::create("memory_adapter",this);

   endfunction : build_phase

   //------------------------------------------------------------------------
   // Function: connect_phase
   // Configure the APB/AXI adapaters and set the virtual sequencers
   //------------------------------------------------------------------------
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // TODO: Wire up all sequence drivers (when active) and TLM ports

      if(is_active == UVM_ACTIVE) begin
         // Connecting the reset sequencer to the virtual sequencer.
         virtual_sequencer.reset_sequencer = reset_env0.agents[0].sequencer;

         // Connecting the misc signals driver to the virtual sequencer.
         virtual_sequencer.misc_signals_driver = misc_signals_driver;

         // VIP Sequencers
         if (config_object.has_active_apb == 1)
            virtual_sequencer.apb_reg_sequencer = apb_env.master_agent.sequencer;
         if (config_object.has_active_axi == 1)
            virtual_sequencer.axi_slave_sequencer = axi_env.active_slave.sequencer;
      end

      // Set the default master sequencer to be the APB regs0 master
      if (regs0 != null && regs0.get_parent() == null && config_object.has_passive_apb == 1) begin

         if (config_object.has_active_apb == 1) begin
            // Connect the sequencer to the reg map
            regs0.default_map.set_sequencer(apb_env.master_agent.sequencer, reg_adapter);
         end

         // To get responses, hook up the APB monitor so that transactions are passed back the reg_map
         void'(apb_env.slave_agent[0].inst.setCallback( DENALI_CDN_APB_CB_MonTransferEnded));
         reg0_predictor.map = regs0.default_map;
         reg0_predictor.adapter = reg_adapter;
         apb_env.slave_agent[0].monitor.MonTransferEndedCbPort.connect(reg0_predictor.bus_in);
         regs0.default_map.set_auto_predict(0);
         regs0.default_map.set_check_on_read(0);

      end
      if (regs1 != null && regs1.get_parent() == null && config_object.has_passive_apb == 1) begin

         // Connect the sequencer to the reg map
         if (config_object.has_active_apb == 1) begin
            regs1.default_map.set_sequencer(apb_env.master_agent.sequencer, reg_adapter);
         end

         // To get responses, hook up the APB monitor so that transactions are passed back the reg_map
         void'(apb_env.slave_agent[1].inst.setCallback( DENALI_CDN_APB_CB_MonTransferEnded));
         reg1_predictor.map = regs1.default_map;
         reg1_predictor.adapter = reg_adapter;
         apb_env.slave_agent[1].monitor.MonTransferEndedCbPort.connect(reg1_predictor.bus_in);
         regs1.default_map.set_auto_predict(0);
         regs1.default_map.set_check_on_read(0);

      end
      if (config_object.has_active_apb) begin
        reg_adapter.driver = apb_env.master_agent.driver;
      end

      // Connect the AXI adapter
      if (config_object.has_passive_axi == 1) begin
         axi_env.active_slave.monitor.EndedTransferCbPort.connect(memory_adapter.axi_transfer_imp);
         // Only connect the callbacks if we are using C and want to write to
         // C memory.
         `ifdef CDN_DEMO_C
         void'(axi_env.active_slave.inst.setCallback(DENALI_CDN_AXI_CB_Ended));
         void'(axi_env.active_slave.inst.setCallback(DENALI_CDN_AXI_CB_BeforeSendResponse));
         axi_env.active_slave.monitor.EndedCbPort.connect(memory_adapter.DriverTransactionEnded);
         axi_env.active_slave.monitor.BeforeSendResponseCbPort.connect(memory_adapter.DriverTransactionBeforeSendResponse);
         `endif
         memory_adapter.p_env = this;
      end

   endfunction : connect_phase

   //---------------------------------------------------------------------------
   // Function: check_phase
   // Check if simulation does not end in Zero Time.
   //---------------------------------------------------------------------------
   function void check_phase(uvm_phase phase);

     if($time == 0) begin
       `uvm_fatal("Simulation Activity Check", $sformatf("Error. Test ends in 0 time"));
     end
   endfunction : check_phase


   //---------------------------------------------------------------------------
   // Function: report_phase
   // Report the status at the end of a test using the standard Cadence
   // pass/fail messages.
   //---------------------------------------------------------------------------
   function void report_phase(uvm_phase phase);
     if(config_object.pass_fail_message_en) begin
       var uvm_report_server p_default_report_server = get_report_server();

       if(p_default_report_server.get_severity_count(UVM_ERROR) == 0 && p_default_report_server.get_severity_count(UVM_FATAL) == 0) begin
         `uvm_info(get_type_name(),`CDN_DEMO_TB_PASS_STRING,UVM_NONE)
       end else begin
         // Note that It is unlikely that this part of the else will be executed
         // as the fatals/errors are caught using the report capture
         `uvm_info(get_type_name(),`CDN_DEMO_TB_FAIL_STRING,UVM_NONE)
       end
     end
   endfunction : report_phase

endclass : cdn_demo_env

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
