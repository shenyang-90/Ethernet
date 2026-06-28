//------------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
// Description :
// If we are using C based stimulus then include the C based DPI connections
//------------------------------------------------------------------------------

/*
 * File: cdn_protocol_demo_module_top_c_dpi.sv
 *
 * This file contains the protocol-specific extension of the DPI-C interface.
 */

`ifndef CDN_PROTOCOL_DEMO_MODULE_TOP_C_DPI_SV
  `define CDN_PROTOCOL_DEMO_MODULE_TOP_C_DPI_SV

//--------------------------------------
// REQUIRED PACKAGES
//--------------------------------------

// UVM class library compiled in a package
import uvm_pkg::*;

// Bring in the rest of the library (macros)
`include "uvm_macros.svh"

//----------------------------------
// EXPORT/DEFINITION
//----------------------------------

export "DPI-C" task send_line_transaction;

/*
 * Function: send_line_transaction
 *
 * SystemVerilog task.
 * Sends an Ethernet transaction.
 * This task is exported to C via the DPI.
 */
task send_line_transaction();
  cdn_gem_demo_pkg::cdn_gem_demo_virtual_sequencer p_vseqr;
  static cdn_gem_demo_pkg::cdn_gem_demo_line_1pkt_seq seq = cdn_gem_demo_pkg::cdn_gem_demo_line_1pkt_seq::type_id::create();
  // Cast the virtual sequencer pointer
  if (!$cast(p_vseqr, uvm_top.find("*virtual_sequencer")))
    `uvm_fatal("cdn_demo_module_top", "Cast of p_virtual_sequencer has not worked")
  // Start the sequence on the sequencer
  `uvm_info("cdn_demo_module_top", "[send_line_transaction] Before seq.start", UVM_DEBUG);
  seq.start(p_vseqr);
  `uvm_info("cdn_demo_module_top", "[send_line_transaction] After seq.start", UVM_DEBUG);
endtask : send_line_transaction

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
