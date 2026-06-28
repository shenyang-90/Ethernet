// -----------------------------------------------------------------------------
// ---
// ---                  (C) COPYRIGHT 2010 Fresco Logic, Inc.
// ---                            ALL RIGHTS RESERVED
// ---
// ---  This software and the associated documentation are confidential and
// ---  proprietary to Fresco Logic, Inc.  Your use or disclosure of this
// ---  software is subject to the terms and conditions of a written
// ---  license agreement between you, or your company, and Fresco Logic, Inc.
// ---
// ---  The entire notice above must be reproduced on all authorized copies.
// ---
// ---  RCS information:
// ---    Author: The Fresco Team
// ---    $Date: 2011-06-24 11:09:30 -0700 (Fri, 24 Jun 2011) $
// ---    $Revision: 15031 $
// ---
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// --- Module description:
// --- This is a RAM model for a one port RAM.
// --- This model can perform either synchronous or asynchronous outputs when reads
// --- Customer can replace this model to their vendor specific RAM
// -------------------------------------------------

//`include "cdns_timescale.vh"
module ram_1p (
    clk,
    addr,
    din,
    dout,
    en,
    we
);
// ============================ parameters =====================================
parameter WD = 8;    // Width of RAM
parameter PW = 12;   // Size of address
parameter DP = (1<<PW); // Depth of RAM, normally it is defaulted to full address size allowed
parameter MEMHOLDDATA = 0; // Read will hold the output value when not enabled
parameter INIT = 3;           // initialize ram w/ random pattern

`ifdef TP
   localparam TP = `TP;
`else
   localparam TP = 1;
`endif

// ============================ IO =============================================
  input                                     [PW-1:0] addr;
  input                                              clk;
  input                                     [WD-1:0] din;
  input                                              en;
  input                                              we;
  output                                    [WD-1:0] dout;

// ============================ Internal Signal Declaration ====================
reg  [WD-1:0]          mem [0:DP-1];   // The memory array
wire [WD-1:0]          dout;
reg  [WD-1:0]          sync_dout;

// ============================ optional Init ==================================
// pragma coverage off
`ifdef FL_SIMULATE_ON
int unsigned rnd_seed;
reg [WD-1:0] init_value;
initial begin
  `ifdef USB_RND_SEED_VAL;
  rnd_seed = `USB_RND_SEED_VAL;
  `else
  rnd_seed = 1;
  `endif
  if (INIT == 2) begin
    int unsigned  index;
    int unsigned byte_num;
    $display ("Initializing RAM 1P at %m with an incrementing byte pattern (Depth=%0d).", DP);
    for (index=0; (index < (DP)); index=index+1) begin
      reg [7:0] byte_value;
      init_value = 0;
      for (byte_num=0; byte_num<(WD/8); byte_num++) begin
        byte_value = ((byte_num+(index*WD/8)+1)%256);
        init_value |= (byte_value) << (byte_num*8);
      end
      mem[(index)] = init_value;
    end
  end else if (INIT == 3) begin
    int unsigned  index;
    int unsigned byte_num;
    $display ("Initializing RAM 1P at %m with a random  byte pattern (Depth=%0d).", DP);
    for (index=0; (index < (DP)); index=index+1) begin
      init_value = {$random(rnd_seed), $random(rnd_seed)};
      mem[(index)] = init_value;
    end
  end
  // Randomize init_value one last time to be used as the data output value when Read Enable is not asserted.
  init_value = {$random(rnd_seed), $random(rnd_seed)};
end
`endif  // !FL_SIMULATE_ON
// pragma coverage on

// ============================ Design =========================================
// RAM Reads/Writes
always @(posedge clk)
begin : RAM_ALWAYS
   integer i;
   if (en) begin
`ifdef FPGA_DEMO
      sync_dout <= #TP mem[addr];        // use this method to infer FPGA models
`else
      for (i = 0 ; i < DP ; i=i+1)     // use this method for synthesis/LINT (especially for non power of 2 RAMs)
        if (i[PW-1:0] == addr)
          sync_dout <= #TP mem[i];
`endif
      if (we) begin
`ifdef FPGA_DEMO
         mem[addr]       <= #TP din;     // use this method to infer FPGA models
`else
         for (i = 0 ; i < DP ; i=i+1)   // use this method for synthesis/LINT (especially for non power of 2 RAMs)
           if (i[PW-1:0] == addr)
             mem[i]      <= #TP din;
`endif
      end
   end else
     if (MEMHOLDDATA)
       sync_dout <= #TP sync_dout;
     else
// pragma coverage off
`ifndef FL_SIMULATE_ON
       sync_dout            <= #TP {WD{1'b0}};
`else   // FL_SIMULATE_ON
        // Use the randomized value for simulations.
       sync_dout       <= #TP init_value;
   if (en & we & (addr >= DP))
        $display("%t: Memory (%m) write address error. Address is %x, Max is %x", $time, addr, DP-1);
   if ((addr >= DP) && en)
     $display("%t: Memory (%m) read address error. Address is %x, Max is %x", $time, addr, DP-1);
`endif  // !FL_SIMULATE_ON
// pragma coverage on
end

assign dout = sync_dout;

endmodule

