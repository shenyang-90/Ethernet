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
// This file contains some dummy DUT for testing the cdn_clock UVC.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Required timescale for sequence delays.
//----------------------------------------------------------------------------
`timescale 1ns / 1fs

//----------------------------------------------------------------------------
// Required modules, interfaces and packages
//----------------------------------------------------------------------------

`include "cdn_clock_if.sv"
`include "cdn_clock_pkg.sv"

//----------------------------------------------------------------------------
// Create the testbench.
//----------------------------------------------------------------------------

module cdn_clock_tb;

    //------------------------------------------------------------------------
    // Import Packages
    //------------------------------------------------------------------------
    // Import UVM Package
    import uvm_pkg::*;

    // Import the cdn_clock UVC Package
    import cdn_clock_pkg::*;

    //------------------------------------------------------------------------
    // Add the test library
    //------------------------------------------------------------------------
    `include "cdn_clock_test_lib.sv"

    //------------------------------------------------------------------------
    // Other TB signals
    //------------------------------------------------------------------------
    logic clk_0;
    logic clk_1;
    logic clk_2;
    logic clk_3;
    logic clk_4;
    logic clk_5;
    logic clk_6;
    logic clk_7;
    logic clk_8;
    logic clk_9;

    //------------------------------------------------------------------------
    // Add one instances of the clock interface.
    //------------------------------------------------------------------------
    cdn_clock_if clock_out();

    //------------------------------------------------------------------------
    // Start the run_test phase
    //------------------------------------------------------------------------
    initial begin
        run_test();
    end

    //------------------------------------------------------------------------
    // DUT behaviour is just a feed through wires
    //------------------------------------------------------------------------
    assign clk_0 = clock_out.sig_clock_0;
    assign clk_1 = clock_out.sig_clock_1;
    assign clk_2 = clock_out.sig_clock_2;
    assign clk_3 = clock_out.sig_clock_3;
    assign clk_4 = clock_out.sig_clock_4;
    assign clk_5 = clock_out.sig_clock_5;
    assign clk_6 = clock_out.sig_clock_6;
    assign clk_7 = clock_out.sig_clock_7;
    assign clk_8 = clock_out.sig_clock_8;
    assign clk_9 = clock_out.sig_clock_9;

endmodule

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
