//----------------------------------------------------------------------------
// Project    : cdn_clock UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description: 
// This file defines the basic interface for the cdn_clock UVC.
//----------------------------------------------------------------------------

`ifndef CDN_CLOCK_IF_SV
`define CDN_CLOCK_IF_SV

interface cdn_clock_if ();

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

    // This signal is the multiple clock signal for this interface.
    logic sig_clock_0;
    logic sig_clock_1;
    logic sig_clock_2;
    logic sig_clock_3;
    logic sig_clock_4;
    logic sig_clock_5;
    logic sig_clock_6;
    logic sig_clock_7;
    logic sig_clock_8;
    logic sig_clock_9;

    // TODO: Write signal level checkers in SVA.


endinterface : cdn_clock_if

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
