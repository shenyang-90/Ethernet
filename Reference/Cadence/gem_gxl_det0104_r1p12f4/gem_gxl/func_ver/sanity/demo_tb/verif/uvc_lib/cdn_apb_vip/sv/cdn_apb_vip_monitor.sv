//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the cdn_apb_vip_monitor class.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_monitor.sv
 * 
 * This file contains the cdn_apb_vip_monitor class.
 */

`ifndef CDN_APB_VIP_MONITOR_SV
`define CDN_APB_VIP_MONITOR_SV

/*
 * Class: cdn_apb_vip_monitor
 * 
 * This class extends the cdnApbUvmMonitor class supplied by the VIP.
 * It does not do anything extra but is a placeholder to complete this derived 
 * UVC.
 */
class cdn_apb_vip_monitor extends cdnApbUvmMonitor;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------

  `uvm_component_utils(cdn_apb_vip_monitor)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_apb_vip_monitor objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name = "cdn_apb_vip_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : cdn_apb_vip_monitor

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
