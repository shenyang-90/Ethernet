//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2013 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description : This file contains the interface used for misc signals 
// that need to be driven or monitored but do not belong to their own UVC.
//----------------------------------------------------------------------------

interface cdn_demo_misc_signals_if (input sig_clock, input sig_reset, input interrupt);

    //------------------------------------------------------------------------
    // IMPORT UVM PACKAGE
    //------------------------------------------------------------------------
    import uvm_pkg::*;

    //------------------------------------------------------------------------
    // CONTROL MEMBER VARIABLES.
    //------------------------------------------------------------------------

    // This member variable enables the protocol checks for this interface.
    bit has_checks = 1;

    // This member variable enables the protocol coverage for this interface.
    bit has_coverage = 1;

    //------------------------------------------------------------------------
    // INTERFACE SIGNALS.
    //------------------------------------------------------------------------

    // TODO: Add what ever signals are required by the DUT that are not on a
    // common interface UVC.
    bit sig_dut_enable;
    bit sig_dut_ready;


    //------------------------------------------------------------------------
    // CLOCKING BLOCKS & MODPORTS
    //------------------------------------------------------------------------
    clocking driver_cb @ (posedge sig_clock);
      output sig_dut_enable;
    endclocking

    clocking monitor_cb @ (posedge sig_clock);
      input sig_dut_enable;
      input sig_dut_ready;
    endclocking

    //------------------------------------------------------------------------
    // PROTOCOL CHECKERS.
    //------------------------------------------------------------------------

    // SVA Default Clocking
    wire uvm_assert_clk = sig_clock && has_checks;
    wire uvm_cover_clk = sig_clock && has_coverage;

    default clocking master_clk @(posedge uvm_assert_clk);
    endclocking

    // SVA Default Reset
    default disable iff (sig_reset == `CDN_DEMO_ACTIVE_RESET_VALUE);

    // TODO: Add any SVA checks and or coverage required for these signals.
    // This could be a good place to check reset values

    //------------------------------------------------------------------------
    // PROTOCOL-SPECIFIC MISC SIGNALS INTERFACE.
    //------------------------------------------------------------------------

    `ifndef CDN_DEMO_RAM_INTEGRATION_TEST
    `include "cdn_protocol_demo_misc_signals_if.sv"
    `endif                  


endinterface : cdn_demo_misc_signals_if

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
