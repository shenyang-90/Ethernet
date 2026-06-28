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
// This file contains some dummy DUT for testing the cdn_reset UVC.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Required timescale for sequence delays.
//----------------------------------------------------------------------------
`timescale 1ns / 1ps

// Bring in the rest of the library (macros)
`include "uvm_macros.svh"

//----------------------------------------------------------------------------
// Required modules, interfaces and packages
//----------------------------------------------------------------------------

`include "cdn_reset_if.sv"
`include "cdn_reset_pkg.sv"

//----------------------------------------------------------------------------
// Create the testbench.
//----------------------------------------------------------------------------

module cdn_reset_tb;

    //------------------------------------------------------------------------
    // Import Packages
    //------------------------------------------------------------------------
    // Import UVM Package
    import uvm_pkg::*;

    // Import the cdn_reset OVC Package
    import cdn_reset_pkg::*;

    //------------------------------------------------------------------------
    // Add the test library
    //------------------------------------------------------------------------
    `include "cdn_reset_test_lib.sv"

    //------------------------------------------------------------------------
    // Other testbench signals
    //------------------------------------------------------------------------
    logic tb_clk;

    logic delayed_reset;

    //------------------------------------------------------------------------
    // Add two instances of the RESET interface (one for in and one for out).
    //------------------------------------------------------------------------
    cdn_reset_if reset_in(tb_clk);
    cdn_reset_if reset_out(tb_clk);

    //------------------------------------------------------------------------
    // Start the run_test phase
    //------------------------------------------------------------------------
    initial begin
        run_test();
    end

    //------------------------------------------------------------------------
    // Simple Reset Generator
    //------------------------------------------------------------------------
    initial begin
        tb_clk = 1'b0;
    end

    //------------------------------------------------------------------------
    // Simple Clock Generator
    //------------------------------------------------------------------------
    always begin
        #10 tb_clk = ~tb_clk;
    end

    //------------------------------------------------------------------------
    // DUT behaviour is just a feed through wires
    //------------------------------------------------------------------------
    always @(posedge tb_clk)begin
        delayed_reset = reset_in.sig_reset;
        reset_out.sig_reset <= delayed_reset;
    end

endmodule

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
