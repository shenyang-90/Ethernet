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
// This file contains the cdn_gem_demo_interface_adapter class.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_interface_adapter.sv
 * 
 * This file contains the cdn_gem_demo_interface_adapter class.
 */

`ifndef CDN_GEM_DEMO_INTERFACE_ADAPTER_SV
  `define CDN_GEM_DEMO_INTERFACE_ADAPTER_SV

/*
 * Class: cdn_gem_demo_interface_adapter
 * 
 * This class is currently just a placeholder that can be used to build
 * abstraction over the line side.
 */
class cdn_gem_demo_interface_adapter extends uvm_component;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------

  `uvm_component_utils(cdn_gem_demo_interface_adapter)

  //------------------------------------------------------------------------
  // CONSTRUCTOR
  //------------------------------------------------------------------------

  /*
   * Constructor: new
   * 
   * The class constructor.
   * It is used to construct cdn_gem_demo_interface_adapter objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name="cdn_gem_demo_interface_adapter", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : cdn_gem_demo_interface_adapter

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
