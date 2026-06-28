//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the cdn_axi_vip UVC configuration user class.
//----------------------------------------------------------------------------

/*
 * File: cdn_axi_vip_config.sv
 * 
 * This file contains the cdn_axi_vip UVC configuration user class.
 */

`ifndef CDN_AXI_VIP_CFG_SV
`define CDN_AXI_VIP_CFG_SV

/*
 * Class: cdn_axi_vip_config
 * 
 * This is the cdn_axi_vip UVC configuration user class.
 */
class cdn_axi_vip_config extends cdnAxiUvmConfig;

  //----------------------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------------------- 

  `uvm_object_utils_begin(cdn_axi_vip_config)  
  `uvm_object_utils_end

  //----------------------------------------------
  // CONSTRUCTOR
  //---------------------------------------------- 

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_axi_vip_config objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   */
  function new(string name = "cdn_axi_vip_config");
    super.new(name);
    // set feature values
    spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA4;
    spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_BASE;
    spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_FULL;  
  endfunction : new
  
endclass

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
