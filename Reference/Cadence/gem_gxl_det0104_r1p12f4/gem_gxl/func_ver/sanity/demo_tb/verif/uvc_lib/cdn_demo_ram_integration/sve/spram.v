//------------------------------------------------------------------------------
// Copyright (c) 2016 Cadence Design Systems, Inc.
//
// The information herein (Cadence IP) contains confidential and proprietary
// information of Cadence Design Systems, Inc. Cadence IP may not be modified,
// copied, reproduced, distributed, or disclosed to third parties in any manner,
// medium, or form, in whole or in part, without the prior written consent of
// Cadence Design Systems Inc. Cadence IP is for use by Cadence Design Systems,
// Inc. customers only. Cadence Design Systems, Inc. reserves the right to make
// changes to Cadence IP at any time and without notice.
//------------------------------------------------------------------------------
//
//   Module Name:       spram
//
//   Filename:          spram.v
//
//   Author:            Cadence Design Systems Inc.
//
//------------------------------------------------------------------------------
//   Description:       Synchronous Single Port RAM
//                       - with byte enables
//------------------------------------------------------------------------------

module spram
  # ( //---------------------------- RAM parameters ----------------------------
    parameter   AW = 8,   // Address Width
    parameter   DW = 32,  // Data Width
    parameter   BN = 4    // Byte Number - must match Data Width
    ) //------------------------------------------------------------------------
  (
  input                 clk,
  input                 wen,
  input                 ren,
  input       [BN-1:0]  ben,
  input       [DW-1:0]  wdata,
  input       [AW-1:0]  addr,
  output  reg [DW-1:0]  rdata
  );

  reg [DW-1:0] dataArray [0:((2**AW)-1)];
  integer i;

  always @ (posedge clk)
  begin: spram_be_proc
    // Write
    if (wen)
    begin
      for (i = 0; i < BN; i = i + 1)
      begin
        if (ben[i])
          dataArray[addr][i*8 +: 8] <= wdata[i*8 +: 8];
      end
    end
    // Read
    if (ren)
      rdata <= dataArray[addr];
    else
      rdata <= {DW{1'b0}};
  end

endmodule
