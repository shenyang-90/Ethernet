//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Description:
// This file contains the configuration object for the cdn_demo UVC.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_CONFIG_OBJECT_SV
`define CDN_DEMO_CONFIG_OBJECT_SV

//----------------------------------------------------------------------------
// Class: cdn_demo_config_object
// The purpose of this base demo config class is to provide the functionality
// that is needed for the base demoTB environment, such as control for the clock
// periods and AXI/APB configuration (Note. The AXI/APB VIP is instantiated by
// default in the base demoTB package). Protocol specific configuration can
// then build upon this base config object to provide protocol specif config.
//----------------------------------------------------------------------------
class cdn_demo_config_object extends uvm_object;

  //------------------------------------------------------------------------
  // CONFIGURATION MEMBERS
  //------------------------------------------------------------------------

  // Randomize the clock periods - note clock0 is typically used for the
  // system clock
  rand integer unsigned clk0_period; // in ps!
  rand integer unsigned clk1_period; // in ps!
  rand integer unsigned clk2_period; // in ps!
  rand integer unsigned clk3_period; // in ps!
  constraint c_clk0_period { soft clk0_period inside {[1000:4000]};}
  constraint c_clk1_period { soft clk1_period inside {5000};}
  constraint c_clk2_period { soft clk2_period inside {[2000:50000]};}
  constraint c_clk3_period { soft clk3_period inside {[2000:50000]};}

  //------------------------------------------------------------------------
  // System Side Config
  //------------------------------------------------------------------------

  // AXI Config
  // AXI Spec Version configuration
  cdnAxiCfgSpecVerT amba_spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA4;

  // Variable: master_axi_max_num_outstanding_wr
  // AXI Maximum Number of outstanding write transactions for master AXI VIP
  bit [5:0] master_axi_max_num_outstanding_wr;

  // Variable: master_axi_max_num_outstanding_rd
  // AXI Maximum Number of outstanding read transactions for master AXI VIP
  bit [5:0] master_axi_max_num_outstanding_rd;

  // Variable: slave_axi_max_num_outstanding_wr
  // AXI Maximum Number of outstanding write transactions for slave AXI VIP
  bit [5:0] slave_axi_max_num_outstanding_wr;

  // Variable: slave_axi_max_num_outstanding_rd
  // AXI Maximum Number of outstanding read transactions for slave AXI VIP
  bit [5:0] slave_axi_max_num_outstanding_rd;

  // Variable: has_active_apb
  // This control knob enables the active APB VIP instance.
  // This is normally set to 1 by default.
  // If you are adding your own bus bridges then you probably want to disable
  // the active apb VIP by setting this to 0.
  bit has_active_apb;

  // Variable: has_passive_apb
  // This control knob enables the passive APB VIP instance.
  // This is normally set to 1 by default and should normally always be set.
  bit has_passive_apb;

  // Variable: has_active_axi
  // This control knob enables the active AXI VIP instance.
  // This is normally set to 1 by default.
  // If you are adding your own bus bridges then you probably want to disable
  // the active axi VIP by setting this to 0.
  bit has_active_axi;

  // Variable: has_passive_axi
  // This control knob enables the passive AXI VIP instance.
  // This is normally set to 1 by default and should normally always be set.
  bit has_passive_axi;    

  // Variable: pass_fail_message_en
  // Enable/Disable pass/fail message at end of simulation.
  // Default is set to 1 for pass/fail banners to be displayed.
  // Note that If you are using the gen_stand_alone_regression_script.pl to
  // generate a regression script that then uses the check_for_pass.pl
  // script; then you MUST have this control enabled or else you will
  // get all tests returning as "unknown" because the check_for_pass.pl
  // script checks for the full pass/fail banners.
  bit pass_fail_message_en;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------

  `uvm_object_utils_begin(cdn_demo_config_object)
    `uvm_field_int(clk0_period, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(clk1_period, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(clk2_period, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(clk3_period, UVM_DEFAULT | UVM_BIN)
    `uvm_field_enum(cdnAxiCfgSpecVerT, amba_spec_ver, UVM_DEFAULT)
    `uvm_field_int(master_axi_max_num_outstanding_wr, UVM_DEFAULT)
    `uvm_field_int(master_axi_max_num_outstanding_rd, UVM_DEFAULT)
    `uvm_field_int(slave_axi_max_num_outstanding_wr, UVM_DEFAULT)
    `uvm_field_int(slave_axi_max_num_outstanding_rd, UVM_DEFAULT)
    `uvm_field_int(has_active_apb, UVM_DEFAULT)
    `uvm_field_int(has_passive_apb, UVM_DEFAULT)
    `uvm_field_int(has_active_axi, UVM_DEFAULT)
    `uvm_field_int(has_passive_axi, UVM_DEFAULT)
    `uvm_field_int(pass_fail_message_en, UVM_DEFAULT)
  `uvm_object_utils_end

  //------------------------------------------------------------------------
  // Function: New
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  function new (string name = "cdn_demo_config_object");
    super.new(name);
   // VE config
    has_active_apb  = 1;
    has_passive_apb = 1;
    has_active_axi  = 1;
    has_passive_axi = 1;    
    pass_fail_message_en = 1;
    master_axi_max_num_outstanding_wr = 2;
    master_axi_max_num_outstanding_rd = 2;
    slave_axi_max_num_outstanding_wr = 2;
    slave_axi_max_num_outstanding_rd = 2;

  endfunction : new


endclass : cdn_demo_config_object

`endif

