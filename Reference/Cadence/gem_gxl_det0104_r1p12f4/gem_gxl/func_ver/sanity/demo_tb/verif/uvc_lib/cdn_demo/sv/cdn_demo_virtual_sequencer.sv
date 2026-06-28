//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2013 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_VIRTUAL_SEQUENCER_SV
`define CDN_DEMO_VIRTUAL_SEQUENCER_SV

//----------------------------------------------------------------------------
// Class: cdn_demo_virtual_sequencer
// This class performs basic functionality and only contains a reference to
// the apb and axi sequencers.
//----------------------------------------------------------------------------

class cdn_demo_virtual_sequencer extends uvm_sequencer;

   //------------------------------------------------------------------------
   // REFERENCES TO THE OTHER UVC SEQUENCERS.
   //------------------------------------------------------------------------
   // Create a reference to the reset UVC sequencer
   cdn_reset_pkg::cdn_reset_sequencer reset_sequencer;

   //------------------------------------------------------------------------
   // REFERENCE TO THE MISC SIGNALS DRIVER
   //------------------------------------------------------------------------
   // Create a reference to the misc signals driver
   cdn_demo_misc_signals_driver misc_signals_driver;


   //------------------------------------------------------------------------
   // VIP Sequencers
   //------------------------------------------------------------------------

   cdnApbUvmSequencer apb_reg_sequencer;
   cdnAxiUvmSequencer axi_slave_sequencer;

   //------------------------------------------------------------------------
   // UVM AUTOMATION MACROS.
   //------------------------------------------------------------------------
   `uvm_component_utils(cdn_demo_virtual_sequencer)

   //------------------------------------------------------------------------
   // EXTEND OR OVERRIDE BASE METHODS
   //------------------------------------------------------------------------

   //------------------------------------------------------------------------
   // Function: New
   // Creates and initializes a new object for this class.
   //------------------------------------------------------------------------
   function new (string name, uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

endclass : cdn_demo_virtual_sequencer

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
