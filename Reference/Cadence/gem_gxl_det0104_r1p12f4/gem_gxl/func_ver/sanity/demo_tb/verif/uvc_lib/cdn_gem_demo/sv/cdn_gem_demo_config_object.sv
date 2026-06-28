//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the configuration object for the cdn_gem_demo UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_config_object.sv
 * 
 * This file defines the configuration object class for the cdn_demo UVC.
 */

`ifndef CDN_GEM_DEMO_CONFIG_OBJECT_SV
  `define CDN_GEM_DEMO_CONFIG_OBJECT_SV

/*
 * Class: cdn_gem_demo_config_object
 * 
 * This is the configuration object class for the cdn_gem_demo UVC.
 * It overrides clock setup as made in the base class.
 */
class cdn_gem_demo_config_object extends cdn_demo_config_object;

  //------------------------------------------------------------------------
  // CONFIGURATION MEMBERS
  //------------------------------------------------------------------------

  /*
   * Variable: denali_error_check_en
   * 
   * Enable (1) or disable (0) PureSpec *Denali* Error checks.
   */
  bit denali_error_check_en;

  //------------------------------------------------------------------------
  // CONSTRAINTS
  //------------------------------------------------------------------------

  // Set clock periods
  constraint c_clk0_period { clk0_period == 8000;   } // 125 MHz
  constraint c_clk1_period { clk1_period == 20000;  } // 50 MHz 
  constraint c_clk2_period { clk2_period == 40000;  } // 25 MHz 
  constraint c_clk3_period { clk3_period == 400000; } // 2.5 MHz

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_config_object)
    `uvm_field_int(denali_error_check_en, UVM_DEFAULT)
  `uvm_object_utils_end

  //------------------------------------------------------------------------
  // CONSTRUCTOR
  //------------------------------------------------------------------------

  /*
   * Constructor: new
   * 
   * The class constructor.
   * It is used to construct cdn_gem_demo_config_object objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new (string name = "cdn_gem_demo_config_object");
    super.new(name);
    denali_error_check_en = 1;
  endfunction : new

endclass : cdn_gem_demo_config_object

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
