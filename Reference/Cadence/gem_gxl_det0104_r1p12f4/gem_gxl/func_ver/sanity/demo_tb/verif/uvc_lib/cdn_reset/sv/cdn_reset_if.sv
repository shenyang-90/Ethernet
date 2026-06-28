//----------------------------------------------------------------------------
// Project    : cdn_reset UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file defines the basic interface for the cdn_reset UVC.
//----------------------------------------------------------------------------

interface cdn_reset_if (input sig_clock);

    //------------------------------------------------------------------------
    // IMPORT OVM PACKAGE
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

    // This signal is the reset signal for this interface.
    logic sig_reset;

    // TODO: Write signal level checkers in SVA.

endinterface : cdn_reset_if

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
