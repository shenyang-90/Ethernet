//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the cdn_axi_vip UVC driver user class.
//----------------------------------------------------------------------------

/*
 * File: cdn_axi_vip_driver.sv
 *
 * This file contains the cdn_axi_vip UVC driver user class.
 */

`ifndef CDN_AXI_VIP_DRIVER_SV
`define CDN_AXI_VIP_DRIVER_SV

/*
 * Class: cdn_axi_vip_driver
 *
 * This class extends the cdnAxiUvmDriver class supplied by the VIP.
 * It does not do anything extra but is a placeholder to complete this
 * derived UVC.
 */
class cdn_axi_vip_driver extends cdnAxiUvmDriver;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------

   `uvm_component_utils(cdn_axi_vip_driver)

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_axi_vip_driver objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
   function new(string name = "cdn_axi_vip_driver", uvm_component parent = null);
     super.new(name, parent);
   endfunction : new

endclass : cdn_axi_vip_driver

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
