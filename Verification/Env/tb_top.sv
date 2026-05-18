//============================================================================
// tb_top.sv - Unified Testbench Top
// Description: All UVM and non-UVM testcases reuse this tb_top
// Mode: +define+UVM for UVM mode
//============================================================================

`timescale 1ns/1ps

module tb_top;

    // Clock & Reset
    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #100 rst_n = 1;
    end

    // TODO: Instantiate DUT

    // Waveform Dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end

    // Timeout
    initial begin
        #1000000;
        $display("[TB_TOP] Simulation timeout!");
        $finish;
    end

`ifdef UVM
    import uvm_pkg::*;
    initial begin
        $display("[TB_TOP] UVM mode enabled");
        run_test();
    end
`endif

endmodule
