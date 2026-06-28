//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the cdn_apb_vip UVC user slave agent class.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_slave_agent.sv
 *
 * This file contains the cdn_apb_vip UVC user slave agent class.
 */

`ifndef CDN_APB_VIP_SLAVE_AGENT_SV
`define CDN_APB_VIP_SLAVE_AGENT_SV

/*
 * Class: cdn_apb_vip_slave_agent
 *
 * This is the slave agent class for the cdn_apb_vip UVC.
 */
class cdn_apb_vip_slave_agent #(int ADDRESS_WIDTH=32, DATA_WIDTH=32)  extends cdnApbUvmAgent;

  //------------------------------------------------------------------------
  // INTERFACES
  //------------------------------------------------------------------------

  `ifdef CDN_APB_VIP_SIMPLE_IF
    // Use the VIP macro to instance and configure a simple APB interface with 1 slave
    `cdnApbDeclareVif(virtual interface cdn_apb_vip_if #(.NUM_OF_SLAVES(1), .ADDRESS_WIDTH(32), .DATA_WIDTH(DATA_WIDTH)))
  `endif
  `ifdef CDN_APB_VIP_IF_APB4
    // Use the VIP macro to instance and configure the APB4 slave IF.
    `cdnApbDeclareVif(virtual interface cdnApb4SlaveInterface #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)))
  `endif
  `ifdef CDN_APB_VIP_IF_APB3
    // Use the VIP macro to instance and configure the APB3 slave IF.
    `cdnApbDeclareVif(virtual interface cdnApb3SlaveInterface #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)))
  `endif


  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------

  `uvm_component_param_utils(cdn_apb_vip_slave_agent #(ADDRESS_WIDTH, DATA_WIDTH))

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_apb_vip_slave_agent objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new (string name = "cdn_apb_vip_slave_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  /*
   * Method: end_of_elaboration_phase
   *
   * This UVM phase is related to post-elaboration activities.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase

endclass : cdn_apb_vip_slave_agent

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------

