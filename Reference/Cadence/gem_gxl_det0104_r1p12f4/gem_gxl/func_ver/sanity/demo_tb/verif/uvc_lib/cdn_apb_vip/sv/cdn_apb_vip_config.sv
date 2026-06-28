//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the configuration class of the cdn_apb UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_conifg.sv
 * 
 * This file contains the configuration class of the cdn_apb UVC.
 */

`ifndef CDN_APB_VIP_CONFIG_SV
`define CDN_APB_VIP_CONFIG_SV

/*
 * Class: cdn_apb_vip_config
 * 
 * This class extends the cdnApbUvmConfig class supplied by the VIP.
 * It does not do anything extra but is a placeholder to complete this
 * derived UVC.
 */
class cdn_apb_vip_config extends cdnApbUvmConfig;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------
  
  `uvm_object_utils(cdn_apb_vip_config)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_apb_vip_config objects.
   * 
   * Parameters:
   * 
   *    name - The name of the class to construct.
   */
  function new(string name = "cdn_apb_vip_config");
    super.new(name);
  endfunction : new

endclass : cdn_apb_vip_config

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
