//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the sequencer class of the cdn_axi_vip UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_axi_vip_sequencer.sv
 * 
 * This file contains the sequencer class of the cdn_axi_vip UVC.
 */

`ifndef CDN_AXI_VIP_SEQUENCER_SV
`define CDN_AXI_VIP_SEQUENCER_SV

/*
 * Class: cdn_axi_vip_sequencer
 * 
 * This class extends the cdnAxiUvmSequencer class supplied by the VIP.
 * It does not do anything extra but is a placeholder to complete this
 * derived UVC.
 */
class cdn_axi_vip_sequencer extends cdnAxiUvmSequencer;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------
  `uvm_component_utils(cdn_axi_vip_sequencer)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_axi_vip_sequencer objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new


endclass : cdn_axi_vip_sequencer

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
