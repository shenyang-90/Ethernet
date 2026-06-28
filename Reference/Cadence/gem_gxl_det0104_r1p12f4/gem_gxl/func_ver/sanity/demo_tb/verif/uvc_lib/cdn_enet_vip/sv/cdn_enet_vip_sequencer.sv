/**************************************************************************
 File name    : cdn_enet_vip_sequencer
 Title        : User Sequencer
 Project      : Ethernet 
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This extended class shows how user can add more properties
                to the base sequencer "cdnEnetUvmSequencer".
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_sequencer.sv
 * 
 * This file contains the Sequencer class for the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_UVM_USER_SEQUENCER_SV
`define CDN_ENET_UVM_USER_SEQUENCER_SV

/*
 * Class: cdn_enet_vip_sequencer
 * 
 * This extended class shows how user can add more properties to the base
 * sequencer "cdnEnetUvmSequencer".
 */
class cdn_enet_vip_sequencer extends cdnEnetUvmSequencer;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  
  `uvm_component_utils(cdn_enet_vip_sequencer)

  //------------------------------------------------------------------------
  // CONSTRUCTOR.
  //------------------------------------------------------------------------

  /*
   * Constructor: new
   * 
   * The class constructor.
   * It is used to construct cdn_enet_vip_sequencer objects.
   * 
   * Parameters:
   * 
   *     name   - The name of the class to construct.
   *     parent - The parent class.
   */
  function new (string name, uvm_component parent);
      super.new(name, parent);
  endfunction : new

endclass : cdn_enet_vip_sequencer

`endif //CDN_ENET_UVM_USER_SEQUENCER_SV

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
