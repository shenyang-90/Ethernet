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
// This file contains an module top level env (testbench) with an instance of
// the module UVC env;
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_module_tb.sv
 * 
 * This file contains the demo_tb protocol-specific UVM testbench.
 */

`ifndef CDN_GEM_DEMO_MODULE_TB_SV
  `define CDN_GEM_DEMO_MODULE_TB_SV

//----------------------------------------------------------------------------
// Include required sequence libraries
//----------------------------------------------------------------------------

/*
 * Class: cdn_gem_demo_module_env
 * 
 * This is the demo_tb protocol-specific testbench.
 * This class sets the interface connection between the ENET VIP envs and the
 * physical interfaces in the top module.
 */
class cdn_gem_demo_module_env extends cdn_demo_module_env;
  
   //------------------------------------------------------------------------
   // COMPONENTS.
   //------------------------------------------------------------------------

   /*
    * Variable: p_demo_env
    * 
    * A pointer to the cdn_demo UVC env to enable hierarchical access.
    */
   cdn_gem_demo_env p_demo_env;

   //------------------------------------------------------------------------
   // UVM AUTOMATION MACROS.
   //------------------------------------------------------------------------

   // The component utils macro provides base virtual methods like
   // get_type_name and create.
   `uvm_component_utils(cdn_gem_demo_module_env)

   //------------------------------------------------------------------------
   // EXTEND OR OVERRIDE BASE METHODS
   //------------------------------------------------------------------------

   /*
    * Method: new
    * 
    * The class constructor.
    * It is used to construct cdn_demo_module_env objects.
    * 
    * Parameters:
    * 
    *    name   - The name of the class to construct.
    *    parent - The parent class.
    */
   function new (string name, uvm_component parent);
     super.new(name, parent);
   endfunction : new

   /*
    * Method: build_phase
    * 
    * This UVM phase is used for building the testbench component hierarchy.
    * For cdn_gem_env, it applies configurations and create protocol UVC objects.
    * 
    * Parameters:
    * 
    *    phase - The UVM phase object.
    */
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     // Connect the cdn_gem_demo UVC env handle to cdn_demo UVC env instance
     $cast(p_demo_env, uvm_top.find("*demo_env"));
     
     //----------
     // ENET VIP
     //----------
     
     `ifdef gem_use_rgmii
       // Set cdn_enet_vip UVC Tx env interfaces
       uvm_config_db#(virtual cdn_enet_vip_rgmii_if)::set(p_demo_env, "enet_env_tx.passive_phy", "vif", cdn_demo_tb.rgmii_if); //.Passive
       // Set cdn_enet_vip UVC Rx env interfaces
       uvm_config_db#(virtual cdn_enet_vip_rgmii_if)::set(p_demo_env, "enet_env_rx.passive_mac", "vif", cdn_demo_tb.rgmii_if); //.Passive
       uvm_config_db#(virtual cdn_enet_vip_rgmii_if)::set(p_demo_env, "enet_env_rx.active_phy", "vif", cdn_demo_tb.rgmii_if); //.Active
     `else
       // Set cdn_enet_vip UVC Tx env interfaces
       uvm_config_db#(virtual cdn_enet_vip_gmii_if)::set(p_demo_env, "enet_env_tx.passive_phy", "vif", cdn_demo_tb.gmii_if); //.Passive
       // Set cdn_enet_vip UVC Rx env interfaces
       uvm_config_db#(virtual cdn_enet_vip_gmii_if)::set(p_demo_env, "enet_env_rx.passive_mac", "vif", cdn_demo_tb.gmii_if); //.Passive
       uvm_config_db#(virtual cdn_enet_vip_gmii_if)::set(p_demo_env, "enet_env_rx.active_phy", "vif", cdn_demo_tb.gmii_if); //.Active
     `endif
   endfunction : build_phase

endclass : cdn_gem_demo_module_env

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
