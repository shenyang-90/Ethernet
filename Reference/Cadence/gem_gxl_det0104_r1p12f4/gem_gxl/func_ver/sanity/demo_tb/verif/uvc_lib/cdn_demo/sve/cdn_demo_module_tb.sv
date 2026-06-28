//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2013 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_MODULE_ENV_SV
`define CDN_DEMO_MODULE_ENV_SV

//----------------------------------------------------------------------------
// Class: cdn_demo_module_env
//
// This class performs the following base functionality:
// - Assign the top level virtual interfaces to the underlying UVCs. This
//   includes the reset, clock, c_dpi, axi, apb and miscellaneous virtual
//   interfaces.
// - Instantiates the demo_env.
//
// For protocol specific functionality this class should be extended to
// provide the protocol specifics. Examples of protocol specific functionality
// can be to instantiated the link side VIP - e.g. instantiate an SDCARD or
// USB UVC.
//
//----------------------------------------------------------------------------

class cdn_demo_module_env extends uvm_env;

   //------------------------------------------------------------------------
   // UVM AUTOMATION MACROS.
   //------------------------------------------------------------------------

   // The component utils macro provides base virtual methods like
   // get_type_name and create.
   `uvm_component_utils(cdn_demo_module_env)

   //------------------------------------------------------------------------
   // COMPONENTS.
   //------------------------------------------------------------------------

   // Add an instance of the cdn_demo UVC env

   cdn_demo_env demo_env;

   //------------------------------------------------------------------------
   // EXTEND OR OVERRIDE BASE METHODS
   //------------------------------------------------------------------------

   //------------------------------------------------------------------------
   // Function: New
   // Creates and initializes a new object for this class.
   //------------------------------------------------------------------------
   function new (string name, uvm_component parent);
       super.new(name, parent);
   endfunction : new

   //------------------------------------------------------------------------
   // Function: build_phase
   // Assign the top level virtual interfaces to the underlying UVCs. This
   // includes the reset, clock, c_dpi, axi, apb and miscellaneous virtual
   // interfaces.
   // Additionally create the demo_env.
   //------------------------------------------------------------------------
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // Assign interface for reset_env.agents[0];
      uvm_config_db#(virtual cdn_reset_if)::set(this, "demo_env.reset_env0.agents[0].driver","reset_if",cdn_demo_tb.reset_if0);
      uvm_config_db#(virtual cdn_reset_if)::set(this, "demo_env.reset_env0.agents[0].monitor","reset_if",cdn_demo_tb.reset_if0);
      uvm_config_db#(virtual cdn_reset_if)::set(this, "demo_env.reset_env1.agents[0].driver","reset_if",cdn_demo_tb.reset_if1);
      uvm_config_db#(virtual cdn_reset_if)::set(this, "demo_env.reset_env1.agents[0].monitor","reset_if",cdn_demo_tb.reset_if1);
      uvm_config_db#(virtual cdn_reset_if)::set(this, "demo_env.reset_env2.agents[0].driver","reset_if",cdn_demo_tb.reset_if2);
      uvm_config_db#(virtual cdn_reset_if)::set(this, "demo_env.reset_env2.agents[0].monitor","reset_if",cdn_demo_tb.reset_if2);
      uvm_config_db#(virtual cdn_reset_if)::set(this, "demo_env.reset_env3.agents[0].driver","reset_if",cdn_demo_tb.reset_if3);
      uvm_config_db#(virtual cdn_reset_if)::set(this, "demo_env.reset_env3.agents[0].monitor","reset_if",cdn_demo_tb.reset_if3);

      // Assign interface for clock_env agent
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env0.driver","clock_if",cdn_demo_tb.clock_if0);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env0.monitor","clock_if",cdn_demo_tb.clock_if0);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env1.driver","clock_if",cdn_demo_tb.clock_if1);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env1.monitor","clock_if",cdn_demo_tb.clock_if1);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env2.driver","clock_if",cdn_demo_tb.clock_if2);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env2.monitor","clock_if",cdn_demo_tb.clock_if2);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env3.driver","clock_if",cdn_demo_tb.clock_if3);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env3.monitor","clock_if",cdn_demo_tb.clock_if3);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env_csp_delay_us.driver","clock_if",cdn_demo_tb.clock_if_csp_delay_us);
      uvm_config_db#(virtual cdn_clock_if)::set(this, "demo_env.clock_env_csp_delay_us.monitor","clock_if",cdn_demo_tb.clock_if_csp_delay_us);

      // Assign the c_dpi interface
      uvm_config_db#(virtual cdn_demo_module_top_c_dpi)::set(null, "", "c_dpi", cdn_demo_tb.c_dpi);

      // Assign interface for misc_signals_if driver and monitor
      uvm_config_db#(virtual cdn_demo_misc_signals_if)::set(this, "demo_env.misc_signals_driver","misc_signals_if",cdn_demo_tb.misc_signals_if);
      uvm_config_db#(virtual cdn_demo_misc_signals_if)::set(this, "demo_env.monitor","misc_signals_if",cdn_demo_tb.misc_signals_if);

      // Assign the APB VIF
      uvm_config_db#(virtual interface cdnApb4MasterInterface#(.NUM_OF_SLAVES(`CDN_DEMO_APB_NUM_OF_SLAVES),.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH),.DATA_WIDTH(32)))::set(this,"demo_env.apb_env.master_agent", "vif", cdn_demo_tb.apb_reg_if.master);
      uvm_config_db#(virtual interface cdnApb4SlaveInterface#(.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH),.DATA_WIDTH(32)))::set(this,"demo_env.apb_env.slave_agent[0]", "vif", cdn_demo_tb.apb_reg_if_slave0);
      uvm_config_db#(virtual interface cdnApb4SlaveInterface#(.ADDRESS_WIDTH(`CDN_DEMO_APB_ADDRESS_WIDTH),.DATA_WIDTH(32)))::set(this,"demo_env.apb_env.slave_agent[1]", "vif", cdn_demo_tb.apb_reg_if_slave1);

      // Assign the AXI VIF
      uvm_config_db#(virtual interface cdn_axi_vip_if)::set(this,"demo_env.axi_env.*", "vif", cdn_demo_tb.axi_if);

       // Create the env.
       demo_env = cdn_demo_env::type_id::create("demo_env", this);

   endfunction : build_phase


endclass : cdn_demo_module_env

`endif
//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
