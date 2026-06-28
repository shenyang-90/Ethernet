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
// ---    $Date: 2011-03-28 23:41:20 -0700 (Mon, 28 Mar 2011) $
// ---    $Revision: 13585 $
// ---
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// --- Module description:
// --- This is a RAM model for a two port RAM.
// --- This model can perform either synchronous or asynchronous outputs when reads
// --- Customer can replace this model to their vendor specific RAM
// -----------------------------------------------------------------------------

//`include "cdns_timescale.vh"


module ram_2p (
    clka,
    clkb,
    addra,
    addrb,
    dina,
    doutb,
    ena,
    enb,
    wea
);

// ============================ parameters =====================================
parameter WD = 8;          // Width of RAM
parameter PW = 12;         // Size of address
parameter DP = 1<<PW;    // Depth of RAM, normally it is defaulted to full address size allowed
parameter MEMHOLDDATA = 0 ; // Read will hold the output value when not enabled
parameter REPORT_ERRORS = 1;  // log errors at read and write accesses to the same mem cell (addra==addrb)
parameter INIT = 3;        // initialize ram w/ random pattern
parameter INIT_FILE = "";  // file with ram init values  



// ============================ IO =============================================
  input                                              clka;
  input                                              clkb;
  input                                     [PW-1:0] addra;
  input                                     [PW-1:0] addrb;
  input                                     [WD-1:0] dina;
  input                                              ena;
  input                                              enb;
  input                                              wea;
  output                                    [WD-1:0] doutb;

// ============================ Internal Signal Declaration ====================
reg [WD-1:0]            mem [0:DP-1];   // The memory array
wire [WD-1:0]           doutb;
reg  [WD-1:0]           sync_doutb;


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
  if (INIT == 1) begin
    $display ("Initializing %m with file %s",INIT_FILE);
    $readmemh (INIT_FILE, mem);
  end else if (INIT == 2) begin
    int unsigned  index;
    int unsigned byte_num;
    $display ("Initializing RAM 2P at %m with an incrementing byte pattern (Depth=%0d).", DP);
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
    $display ("Initializing RAM 2P at %m with a random byte pattern (Depth=%0d).", DP);
    for (index=0; (index < (DP)); index=index+1) begin
      init_value = {$random(rnd_seed), $random(rnd_seed)};
      mem[(index)] = init_value;
    end
  end
  // Randomize init_value one last time to be used as the data output value when Read Enable is not asserted.
  init_value = {$random(rnd_seed), $random(rnd_seed)};
end

function void mem_rand_content();
  int unsigned  index;
  int unsigned byte_num;
  $display ("Initializing RAM 2P at %m with a random byte pattern (Depth=%0d).", DP);
  for (index=0; (index < (DP)); index=index+1) begin
    init_value = {$random(rnd_seed), $random(rnd_seed)};
    mem[(index)] = init_value;
  end
endfunction

`endif  // FL_SIMULATE_ON
// pragma coverage on



// ============================ Design =========================================
// RAM Writes
always @(posedge clka)
begin : RAM_WR_ALWAYS
   integer i;
   if (ena & wea) begin
`ifdef FPGA_DEMO 
      mem[addra]       <= dina;        // use this method to infer FPGA models
`else
      for (i = 0 ; i < DP ; i=i+1)         // use this method for synthesis/LINT (especially for non power of 2 RAMs)
        if (i[PW-1:0] == addra)
          mem[i]       <= dina;
`endif
    end
// pragma coverage off
`ifdef FL_DEBUG_ON
    if (ena & wea & (addra >= DP))
        $display("%t: Memory (%m) write address error. Address is %x, Max is %x", $time, addra, DP-1);
`endif  // FL_DEBUG_ON
// pragma coverage on
end


// RAM Reads
always @(posedge clkb)
begin : RAM_RD_ALWAYS
    integer i;
    if (enb) begin
`ifdef FPGA_DEMO
       sync_doutb            <= mem[addrb];        // use this method to infer FPGA models
`else
       for (i = 0 ; i < DP ; i=i+1)                    // use this method for synthesis/LINT (especially for non power of 2 RAMs)
         if (i[PW-1:0] == addrb)
           sync_doutb        <= mem[i];
`endif
    end else
      if (MEMHOLDDATA)
        sync_doutb            <=  sync_doutb;
      else
// pragma coverage off
`ifndef FL_SIMULATE_ON
        sync_doutb            <=  {WD{1'b0}};
`else   // FL_SIMULATE_ON
   // Use the randomized value for simulations.
   sync_doutb            <=  init_value;
   if ((addrb >= DP) && enb)
     $display("%t: Memory (%m) read address error. Address is %x, Max is %x", $time, addrb, DP-1);
`endif // !FL_SIMULATE_ON
// pragma coverage on
end

// pragma coverage off
`ifdef FL_SIMULATE_ON
reg [PW-1:0]         addra_x;
reg [PW-1:0]         addrb_x;
reg                  ena_x;
reg                  enb_x;
reg                  wea_x;
// register these signals with their clocks to ensure settling doesn't cause misfire of this checker
always @(posedge clka)
  begin
     addra_x <=  addra;
     wea_x   <=  wea;
     if (ena)
       ena_x <=  1'b1;
     else
       ena_x <= 1'b0; // no delay (eliminate false asserts for clka=clkb)
  end
always @(posedge clkb)
  begin
     addrb_x <=  addrb;
     if (enb)
       enb_x <=  1'b1;
     else
       enb_x <= 1'b0; // no delay (eliminate false asserts for clka=clkb)
  end

generate
  if(REPORT_ERRORS==1)
  begin : G_REPORT_ERRORS_GENERATE
    always @(wea_x or ena_x or enb_x or addra_x or addrb_x)
    begin
        if ((addrb_x == addra_x) && enb_x && ena_x && wea_x )
            $display("%t: Memory (%m) read/write same address ERROR. Address is %x, Max is %x", $time, addrb_x, DP-1);
    end
  end
endgenerate

`endif  // !FL_SIMULATE_ON
// pragma coverage on

assign doutb = sync_doutb;
endmodule

