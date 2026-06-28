//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the instance class of the cdn_apb_vip UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_instance.sv
 * 
 * This file contains the instance class of the cdn_apb_vip UVC.
 */

`ifndef CDN_APB_VIP_INSTANCE_SV
`define CDN_APB_VIP_INSTANCE_SV

/*
 * Class: cdn_apb_vip_instance
 * 
 * This class extends the cdnApbUvmInstance class supplied by the VIP.
 * It does not do anything extra but is a placeholder to complete this
 * derived UVC.
 */
class cdn_apb_vip_instance extends cdnApbUvmInstance;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------
  
  `uvm_component_utils(cdn_apb_vip_instance)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_apb_vip_instance objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : cdn_apb_vip_instance

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
