//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description: 
// This file contains the cdn_axi_vip UVC user agent classes.
//----------------------------------------------------------------------------

/*
 * File: cdn_axi_vip_agent.sv
 * 
 * This file contains the cdn_axi_vip UVC agent class.
 */

`ifndef CDN_AXI_VIP_AGENT_SV
`define CDN_AXI_VIP_AGENT_SV

/*
 * Class: cdn_axi_vip_agent
 * 
 * This is the base agent class for the cdn_axi_vip UVC.
 */
class cdn_axi_vip_agent
#(
  int unsigned ADDR_WIDTH   =`CDN_AXI_VIP_ADDR_W, 
  int unsigned DATA_WIDTH   =`CDN_AXI_VIP_DATA_W, 
  int unsigned ID_WIDTH     =`CDN_AXI_VIP_ID_W, 
  int unsigned LOCK_WIDTH   =`CDN_AXI_VIP_LOCK_W, 
  int unsigned LENGTH_WIDTH =`CDN_AXI_VIP_LENGTH_W, 
  int unsigned USER_WIDTH   =`CDN_AXI_VIP_USER_W
) extends cdnAxiUvmAgent;
  
  //----------------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------------  
  
  `uvm_component_param_utils_begin(cdn_axi_vip_agent#(.ADDR_WIDTH(ADDR_WIDTH),
                                                      .DATA_WIDTH(DATA_WIDTH),
                                                      .ID_WIDTH(ID_WIDTH),
                                                      .LOCK_WIDTH(LOCK_WIDTH),
                                                      .LENGTH_WIDTH(LENGTH_WIDTH),
                                                      .USER_WIDTH(USER_WIDTH)))        
  `uvm_component_utils_end

  //----------------------------------------------
  // VIRTUAL INTERFACE DECLARATION
  //----------------------------------------------

  `ifndef CDN_AXI_USING_CLOCKING_BLOCK
    `cdnAxiDeclareVif(virtual cdn_axi_vip_if #(.ADDR_WIDTH(ADDR_WIDTH),
                                               .DATA_WIDTH(DATA_WIDTH),
                                               .ID_WIDTH(ID_WIDTH),
                                               .LOCK_WIDTH(LOCK_WIDTH),
                                               .LENGTH_WIDTH(LENGTH_WIDTH),
                                               .USER_WIDTH(USER_WIDTH)))
  `endif

  //----------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //----------------------------------------------  
  
  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_axi_vip_agent objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new (string name = "cdn_axi_vip_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : cdn_axi_vip_agent

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
