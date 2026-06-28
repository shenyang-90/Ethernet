//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : bsidelko@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// The purpose of this file is to provide a test for RAM.
// The test performs full RAM testing. The testing performed is as follows:
// - Walking zeros on address and data buses
// - Walkings ones on address and data buses
// - Unique data to each location then read back.
// The RAM is reset before running test when bit [3] of CTRL_REG is set.
//
//  APB_BANK_REG:
//  +-------------------------------------------------------+
//   |         bits of CONTROL and STATUS register          |
//  +------+------+------+------#------+------+------+------+
//  |  7   |  6   |  5   |  4   #  3   |  2   |  1   |  0   |
//  +------+------+------+------#------+------+------+------+
//  | DATA |  W1  |  W0  | RUN  # RST  | DONE | PASS | CLR  |
//  +------+------+------+------#------+------+------+------+
//  |      algorithm     |   trigger   |       status       |
//  +--------------------+-------------+--------------------+
//----------------------------------------------------------------------------

`include "cdn_ram_stub_addr_map.vh"

`include "cdn_demo_ram_integration_sram_intf.sv"
`include "cdn_demo_ram_integration_dp1r1w_intf.sv"
`include "cdn_demo_ram_integration_sram_be_intf.sv"

module cdn_demo_ram_integration_stub_bfm # (
  
  parameter DEBUG_LEVEL = 0,

  parameter APB_PADDR_WD = 13,
  parameter APB_PPROT_WD = 3,

  // Inputs to MASTER APB Bank
  parameter NUM_SRAM         = 1,  //(0..31)
  parameter NUM_DP1R1W       = 1,  //(0..31)
  parameter NUM_DP2R2W       = 0,  //(0..31)
  parameter NUM_RF           = 0,  //(0..31)
  parameter NUM_SRAM_BE      = 1,  //(0..31)
  parameter NUM_DP1R1W_BE    = 0,  //(0..31)
  parameter NUM_DP2R2W_BE    = 0,  //(0..31)
  parameter NUM_RF_BE        = 0,  //(0..31)

  // Width of Address and Data buses, Depth of RAM (normally it is defaulted to full address size allowed)
  // for considered type of RAM blocks.

  // SRAM NAME (STRING)
  parameter SRAM0_NAME   = "0",
  parameter SRAM1_NAME   = "1",
  parameter SRAM2_NAME   = "2",
  parameter SRAM3_NAME   = "3",
  parameter SRAM4_NAME   = "4",
  parameter SRAM5_NAME   = "5",
  parameter SRAM6_NAME   = "6",
  parameter SRAM7_NAME   = "7",
  parameter SRAM8_NAME   = "8",
  parameter SRAM9_NAME   = "9",
  parameter SRAM10_NAME  = "10",
  parameter SRAM11_NAME  = "11",
  parameter SRAM12_NAME  = "12",
  parameter SRAM13_NAME  = "13",
  parameter SRAM14_NAME  = "14",
  parameter SRAM15_NAME  = "15",
  parameter SRAM16_NAME  = "16",
  parameter SRAM17_NAME  = "17",
  parameter SRAM18_NAME  = "18",
  parameter SRAM19_NAME  = "19",
  parameter SRAM20_NAME  = "20",
  parameter SRAM21_NAME  = "21",
  parameter SRAM22_NAME  = "22",
  parameter SRAM23_NAME  = "23",
  parameter SRAM24_NAME  = "24",
  parameter SRAM25_NAME  = "25",
  parameter SRAM26_NAME  = "26",
  parameter SRAM27_NAME  = "27",
  parameter SRAM28_NAME  = "28",
  parameter SRAM29_NAME  = "29",
  parameter SRAM30_NAME  = "30",
  parameter SRAM31_NAME  = "31",
  // SRAM READ DELAY (number of clock cycles)
  parameter SRAM0_READ_DELAY  = 0,
  parameter SRAM1_READ_DELAY  = 0,
  parameter SRAM2_READ_DELAY  = 0,
  parameter SRAM3_READ_DELAY  = 0,
  parameter SRAM4_READ_DELAY  = 0,
  parameter SRAM5_READ_DELAY  = 0,
  parameter SRAM6_READ_DELAY  = 0,
  parameter SRAM7_READ_DELAY  = 0,
  parameter SRAM8_READ_DELAY  = 0,
  parameter SRAM9_READ_DELAY  = 0,
  parameter SRAM10_READ_DELAY = 0,
  parameter SRAM11_READ_DELAY = 0,
  parameter SRAM12_READ_DELAY = 0,
  parameter SRAM13_READ_DELAY = 0,
  parameter SRAM14_READ_DELAY = 0,
  parameter SRAM15_READ_DELAY = 0,
  parameter SRAM16_READ_DELAY = 0,
  parameter SRAM17_READ_DELAY = 0,
  parameter SRAM18_READ_DELAY = 0,
  parameter SRAM19_READ_DELAY = 0,
  parameter SRAM20_READ_DELAY = 0,
  parameter SRAM21_READ_DELAY = 0,
  parameter SRAM22_READ_DELAY = 0,
  parameter SRAM23_READ_DELAY = 0,
  parameter SRAM24_READ_DELAY = 0,
  parameter SRAM25_READ_DELAY = 0,
  parameter SRAM26_READ_DELAY = 0,
  parameter SRAM27_READ_DELAY = 0,
  parameter SRAM28_READ_DELAY = 0,
  parameter SRAM29_READ_DELAY = 0,
  parameter SRAM30_READ_DELAY = 0,
  parameter SRAM31_READ_DELAY = 0,
  // SRAM ADDRESS WIDTH
  parameter SRAM0_ADDR_WD   = 1,
  parameter SRAM1_ADDR_WD   = 1,
  parameter SRAM2_ADDR_WD   = 1,
  parameter SRAM3_ADDR_WD   = 1,
  parameter SRAM4_ADDR_WD   = 1,
  parameter SRAM5_ADDR_WD   = 1,
  parameter SRAM6_ADDR_WD   = 1,
  parameter SRAM7_ADDR_WD   = 1,
  parameter SRAM8_ADDR_WD   = 1,
  parameter SRAM9_ADDR_WD   = 1,
  parameter SRAM10_ADDR_WD  = 1,
  parameter SRAM11_ADDR_WD  = 1,
  parameter SRAM12_ADDR_WD  = 1,
  parameter SRAM13_ADDR_WD  = 1,
  parameter SRAM14_ADDR_WD  = 1,
  parameter SRAM15_ADDR_WD  = 1,
  parameter SRAM16_ADDR_WD  = 1,
  parameter SRAM17_ADDR_WD  = 1,
  parameter SRAM18_ADDR_WD  = 1,
  parameter SRAM19_ADDR_WD  = 1,
  parameter SRAM20_ADDR_WD  = 1,
  parameter SRAM21_ADDR_WD  = 1,
  parameter SRAM22_ADDR_WD  = 1,
  parameter SRAM23_ADDR_WD  = 1,
  parameter SRAM24_ADDR_WD  = 1,
  parameter SRAM25_ADDR_WD  = 1,
  parameter SRAM26_ADDR_WD  = 1,
  parameter SRAM27_ADDR_WD  = 1,
  parameter SRAM28_ADDR_WD  = 1,
  parameter SRAM29_ADDR_WD  = 1,
  parameter SRAM30_ADDR_WD  = 1,
  parameter SRAM31_ADDR_WD  = 1,
  // SRAM DATA WIDTH
  parameter SRAM0_DATA_WD   = 1,
  parameter SRAM1_DATA_WD   = 1,
  parameter SRAM2_DATA_WD   = 1,
  parameter SRAM3_DATA_WD   = 1,
  parameter SRAM4_DATA_WD   = 1,
  parameter SRAM5_DATA_WD   = 1,
  parameter SRAM6_DATA_WD   = 1,
  parameter SRAM7_DATA_WD   = 1,
  parameter SRAM8_DATA_WD   = 1,
  parameter SRAM9_DATA_WD   = 1,
  parameter SRAM10_DATA_WD  = 1,
  parameter SRAM11_DATA_WD  = 1,
  parameter SRAM12_DATA_WD  = 1,
  parameter SRAM13_DATA_WD  = 1,
  parameter SRAM14_DATA_WD  = 1,
  parameter SRAM15_DATA_WD  = 1,
  parameter SRAM16_DATA_WD  = 1,
  parameter SRAM17_DATA_WD  = 1,
  parameter SRAM18_DATA_WD  = 1,
  parameter SRAM19_DATA_WD  = 1,
  parameter SRAM20_DATA_WD  = 1,
  parameter SRAM21_DATA_WD  = 1,
  parameter SRAM22_DATA_WD  = 1,
  parameter SRAM23_DATA_WD  = 1,
  parameter SRAM24_DATA_WD  = 1,
  parameter SRAM25_DATA_WD  = 1,
  parameter SRAM26_DATA_WD  = 1,
  parameter SRAM27_DATA_WD  = 1,
  parameter SRAM28_DATA_WD  = 1,
  parameter SRAM29_DATA_WD  = 1,
  parameter SRAM30_DATA_WD  = 1,
  parameter SRAM31_DATA_WD  = 1,
  // SRAM DEPTH of RAM
  parameter SRAM0_DEPTH  = (1<<SRAM0_ADDR_WD ),
  parameter SRAM1_DEPTH  = (1<<SRAM1_ADDR_WD ),
  parameter SRAM2_DEPTH  = (1<<SRAM2_ADDR_WD ),
  parameter SRAM3_DEPTH  = (1<<SRAM3_ADDR_WD ),
  parameter SRAM4_DEPTH  = (1<<SRAM4_ADDR_WD ),
  parameter SRAM5_DEPTH  = (1<<SRAM5_ADDR_WD ),
  parameter SRAM6_DEPTH  = (1<<SRAM6_ADDR_WD ),
  parameter SRAM7_DEPTH  = (1<<SRAM7_ADDR_WD ),
  parameter SRAM8_DEPTH  = (1<<SRAM8_ADDR_WD ),
  parameter SRAM9_DEPTH  = (1<<SRAM9_ADDR_WD ),
  parameter SRAM10_DEPTH = (1<<SRAM10_ADDR_WD),
  parameter SRAM11_DEPTH = (1<<SRAM11_ADDR_WD),
  parameter SRAM12_DEPTH = (1<<SRAM12_ADDR_WD),
  parameter SRAM13_DEPTH = (1<<SRAM13_ADDR_WD),
  parameter SRAM14_DEPTH = (1<<SRAM14_ADDR_WD),
  parameter SRAM15_DEPTH = (1<<SRAM15_ADDR_WD),
  parameter SRAM16_DEPTH = (1<<SRAM16_ADDR_WD),
  parameter SRAM17_DEPTH = (1<<SRAM17_ADDR_WD),
  parameter SRAM18_DEPTH = (1<<SRAM18_ADDR_WD),
  parameter SRAM19_DEPTH = (1<<SRAM19_ADDR_WD),
  parameter SRAM20_DEPTH = (1<<SRAM20_ADDR_WD),
  parameter SRAM21_DEPTH = (1<<SRAM21_ADDR_WD),
  parameter SRAM22_DEPTH = (1<<SRAM22_ADDR_WD),
  parameter SRAM23_DEPTH = (1<<SRAM23_ADDR_WD),
  parameter SRAM24_DEPTH = (1<<SRAM24_ADDR_WD),
  parameter SRAM25_DEPTH = (1<<SRAM25_ADDR_WD),
  parameter SRAM26_DEPTH = (1<<SRAM26_ADDR_WD),
  parameter SRAM27_DEPTH = (1<<SRAM27_ADDR_WD),
  parameter SRAM28_DEPTH = (1<<SRAM28_ADDR_WD),
  parameter SRAM29_DEPTH = (1<<SRAM29_ADDR_WD),
  parameter SRAM30_DEPTH = (1<<SRAM30_ADDR_WD),
  parameter SRAM31_DEPTH = (1<<SRAM31_ADDR_WD),
  // SRAM HOLD DATA
  parameter SRAM0_HOLDDATA   = 0,
  parameter SRAM1_HOLDDATA   = 0,
  parameter SRAM2_HOLDDATA   = 0,
  parameter SRAM3_HOLDDATA   = 0,
  parameter SRAM4_HOLDDATA   = 0,
  parameter SRAM5_HOLDDATA   = 0,
  parameter SRAM6_HOLDDATA   = 0,
  parameter SRAM7_HOLDDATA   = 0,
  parameter SRAM8_HOLDDATA   = 0,
  parameter SRAM9_HOLDDATA   = 0,
  parameter SRAM10_HOLDDATA  = 0,
  parameter SRAM11_HOLDDATA  = 0,
  parameter SRAM12_HOLDDATA  = 0,
  parameter SRAM13_HOLDDATA  = 0,
  parameter SRAM14_HOLDDATA  = 0,
  parameter SRAM15_HOLDDATA  = 0,
  parameter SRAM16_HOLDDATA  = 0,
  parameter SRAM17_HOLDDATA  = 0,
  parameter SRAM18_HOLDDATA  = 0,
  parameter SRAM19_HOLDDATA  = 0,
  parameter SRAM20_HOLDDATA  = 0,
  parameter SRAM21_HOLDDATA  = 0,
  parameter SRAM22_HOLDDATA  = 0,
  parameter SRAM23_HOLDDATA  = 0,
  parameter SRAM24_HOLDDATA  = 0,
  parameter SRAM25_HOLDDATA  = 0,
  parameter SRAM26_HOLDDATA  = 0,
  parameter SRAM27_HOLDDATA  = 0,
  parameter SRAM28_HOLDDATA  = 0,
  parameter SRAM29_HOLDDATA  = 0,
  parameter SRAM30_HOLDDATA  = 0,
  parameter SRAM31_HOLDDATA  = 0,

  // DP1R1W NAME (STRING)
  parameter DP1R1W0_NAME   = "0",
  parameter DP1R1W1_NAME   = "1",
  parameter DP1R1W2_NAME   = "2",
  parameter DP1R1W3_NAME   = "3",
  parameter DP1R1W4_NAME   = "4",
  parameter DP1R1W5_NAME   = "5",
  parameter DP1R1W6_NAME   = "6",
  parameter DP1R1W7_NAME   = "7",
  parameter DP1R1W8_NAME   = "8",
  parameter DP1R1W9_NAME   = "9",
  parameter DP1R1W10_NAME  = "10",
  parameter DP1R1W11_NAME  = "11",
  parameter DP1R1W12_NAME  = "12",
  parameter DP1R1W13_NAME  = "13",
  parameter DP1R1W14_NAME  = "14",
  parameter DP1R1W15_NAME  = "15",
  parameter DP1R1W16_NAME  = "16",
  parameter DP1R1W17_NAME  = "17",
  parameter DP1R1W18_NAME  = "18",
  parameter DP1R1W19_NAME  = "19",
  parameter DP1R1W20_NAME  = "20",
  parameter DP1R1W21_NAME  = "21",
  parameter DP1R1W22_NAME  = "22",
  parameter DP1R1W23_NAME  = "23",
  parameter DP1R1W24_NAME  = "24",
  parameter DP1R1W25_NAME  = "25",
  parameter DP1R1W26_NAME  = "26",
  parameter DP1R1W27_NAME  = "27",
  parameter DP1R1W28_NAME  = "28",
  parameter DP1R1W29_NAME  = "29",
  parameter DP1R1W30_NAME  = "30",
  parameter DP1R1W31_NAME  = "31",
  // DP1R1W READ DELAY (number of clock cycles)
  parameter DP1R1W0_READ_DELAY  = 0,
  parameter DP1R1W1_READ_DELAY  = 0,
  parameter DP1R1W2_READ_DELAY  = 0,
  parameter DP1R1W3_READ_DELAY  = 0,
  parameter DP1R1W4_READ_DELAY  = 0,
  parameter DP1R1W5_READ_DELAY  = 0,
  parameter DP1R1W6_READ_DELAY  = 0,
  parameter DP1R1W7_READ_DELAY  = 0,
  parameter DP1R1W8_READ_DELAY  = 0,
  parameter DP1R1W9_READ_DELAY  = 0,
  parameter DP1R1W10_READ_DELAY = 0,
  parameter DP1R1W11_READ_DELAY = 0,
  parameter DP1R1W12_READ_DELAY = 0,
  parameter DP1R1W13_READ_DELAY = 0,
  parameter DP1R1W14_READ_DELAY = 0,
  parameter DP1R1W15_READ_DELAY = 0,
  parameter DP1R1W16_READ_DELAY = 0,
  parameter DP1R1W17_READ_DELAY = 0,
  parameter DP1R1W18_READ_DELAY = 0,
  parameter DP1R1W19_READ_DELAY = 0,
  parameter DP1R1W20_READ_DELAY = 0,
  parameter DP1R1W21_READ_DELAY = 0,
  parameter DP1R1W22_READ_DELAY = 0,
  parameter DP1R1W23_READ_DELAY = 0,
  parameter DP1R1W24_READ_DELAY = 0,
  parameter DP1R1W25_READ_DELAY = 0,
  parameter DP1R1W26_READ_DELAY = 0,
  parameter DP1R1W27_READ_DELAY = 0,
  parameter DP1R1W28_READ_DELAY = 0,
  parameter DP1R1W29_READ_DELAY = 0,
  parameter DP1R1W30_READ_DELAY = 0,
  parameter DP1R1W31_READ_DELAY = 0,
  // DP1R1W ADDRESS WIDTH
  parameter DP1R1W0_ADDR_WD  = 1,
  parameter DP1R1W1_ADDR_WD  = 1,
  parameter DP1R1W2_ADDR_WD  = 1,
  parameter DP1R1W3_ADDR_WD  = 1,
  parameter DP1R1W4_ADDR_WD  = 1,
  parameter DP1R1W5_ADDR_WD  = 1,
  parameter DP1R1W6_ADDR_WD  = 1,
  parameter DP1R1W7_ADDR_WD  = 1,
  parameter DP1R1W8_ADDR_WD  = 1,
  parameter DP1R1W9_ADDR_WD  = 1,
  parameter DP1R1W10_ADDR_WD = 1,
  parameter DP1R1W11_ADDR_WD = 1,
  parameter DP1R1W12_ADDR_WD = 1,
  parameter DP1R1W13_ADDR_WD = 1,
  parameter DP1R1W14_ADDR_WD = 1,
  parameter DP1R1W15_ADDR_WD = 1,
  parameter DP1R1W16_ADDR_WD = 1,
  parameter DP1R1W17_ADDR_WD = 1,
  parameter DP1R1W18_ADDR_WD = 1,
  parameter DP1R1W19_ADDR_WD = 1,
  parameter DP1R1W20_ADDR_WD = 1,
  parameter DP1R1W21_ADDR_WD = 1,
  parameter DP1R1W22_ADDR_WD = 1,
  parameter DP1R1W23_ADDR_WD = 1,
  parameter DP1R1W24_ADDR_WD = 1,
  parameter DP1R1W25_ADDR_WD = 1,
  parameter DP1R1W26_ADDR_WD = 1,
  parameter DP1R1W27_ADDR_WD = 1,
  parameter DP1R1W28_ADDR_WD = 1,
  parameter DP1R1W29_ADDR_WD = 1,
  parameter DP1R1W30_ADDR_WD = 1,
  parameter DP1R1W31_ADDR_WD = 1,
  // DP1R1W DATA WIDTH
  parameter DP1R1W0_DATA_WD  = 1,
  parameter DP1R1W1_DATA_WD  = 1,
  parameter DP1R1W2_DATA_WD  = 1,
  parameter DP1R1W3_DATA_WD  = 1,
  parameter DP1R1W4_DATA_WD  = 1,
  parameter DP1R1W5_DATA_WD  = 1,
  parameter DP1R1W6_DATA_WD  = 1,
  parameter DP1R1W7_DATA_WD  = 1,
  parameter DP1R1W8_DATA_WD  = 1,
  parameter DP1R1W9_DATA_WD  = 1,
  parameter DP1R1W10_DATA_WD = 1,
  parameter DP1R1W11_DATA_WD = 1,
  parameter DP1R1W12_DATA_WD = 1,
  parameter DP1R1W13_DATA_WD = 1,
  parameter DP1R1W14_DATA_WD = 1,
  parameter DP1R1W15_DATA_WD = 1,
  parameter DP1R1W16_DATA_WD = 1,
  parameter DP1R1W17_DATA_WD = 1,
  parameter DP1R1W18_DATA_WD = 1,
  parameter DP1R1W19_DATA_WD = 1,
  parameter DP1R1W20_DATA_WD = 1,
  parameter DP1R1W21_DATA_WD = 1,
  parameter DP1R1W22_DATA_WD = 1,
  parameter DP1R1W23_DATA_WD = 1,
  parameter DP1R1W24_DATA_WD = 1,
  parameter DP1R1W25_DATA_WD = 1,
  parameter DP1R1W26_DATA_WD = 1,
  parameter DP1R1W27_DATA_WD = 1,
  parameter DP1R1W28_DATA_WD = 1,
  parameter DP1R1W29_DATA_WD = 1,
  parameter DP1R1W30_DATA_WD = 1,
  parameter DP1R1W31_DATA_WD = 1,
  // DP1R1W DEPTH of RAM
  parameter DP1R1W0_DEPTH  = (1<<DP1R1W0_ADDR_WD ),
  parameter DP1R1W1_DEPTH  = (1<<DP1R1W1_ADDR_WD ),
  parameter DP1R1W2_DEPTH  = (1<<DP1R1W2_ADDR_WD ),
  parameter DP1R1W3_DEPTH  = (1<<DP1R1W3_ADDR_WD ),
  parameter DP1R1W4_DEPTH  = (1<<DP1R1W4_ADDR_WD ),
  parameter DP1R1W5_DEPTH  = (1<<DP1R1W5_ADDR_WD ),
  parameter DP1R1W6_DEPTH  = (1<<DP1R1W6_ADDR_WD ),
  parameter DP1R1W7_DEPTH  = (1<<DP1R1W7_ADDR_WD ),
  parameter DP1R1W8_DEPTH  = (1<<DP1R1W8_ADDR_WD ),
  parameter DP1R1W9_DEPTH  = (1<<DP1R1W9_ADDR_WD ),
  parameter DP1R1W10_DEPTH = (1<<DP1R1W10_ADDR_WD),
  parameter DP1R1W11_DEPTH = (1<<DP1R1W11_ADDR_WD),
  parameter DP1R1W12_DEPTH = (1<<DP1R1W12_ADDR_WD),
  parameter DP1R1W13_DEPTH = (1<<DP1R1W13_ADDR_WD),
  parameter DP1R1W14_DEPTH = (1<<DP1R1W14_ADDR_WD),
  parameter DP1R1W15_DEPTH = (1<<DP1R1W15_ADDR_WD),
  parameter DP1R1W16_DEPTH = (1<<DP1R1W16_ADDR_WD),
  parameter DP1R1W17_DEPTH = (1<<DP1R1W17_ADDR_WD),
  parameter DP1R1W18_DEPTH = (1<<DP1R1W18_ADDR_WD),
  parameter DP1R1W19_DEPTH = (1<<DP1R1W19_ADDR_WD),
  parameter DP1R1W20_DEPTH = (1<<DP1R1W20_ADDR_WD),
  parameter DP1R1W21_DEPTH = (1<<DP1R1W21_ADDR_WD),
  parameter DP1R1W22_DEPTH = (1<<DP1R1W22_ADDR_WD),
  parameter DP1R1W23_DEPTH = (1<<DP1R1W23_ADDR_WD),
  parameter DP1R1W24_DEPTH = (1<<DP1R1W24_ADDR_WD),
  parameter DP1R1W25_DEPTH = (1<<DP1R1W25_ADDR_WD),
  parameter DP1R1W26_DEPTH = (1<<DP1R1W26_ADDR_WD),
  parameter DP1R1W27_DEPTH = (1<<DP1R1W27_ADDR_WD),
  parameter DP1R1W28_DEPTH = (1<<DP1R1W28_ADDR_WD),
  parameter DP1R1W29_DEPTH = (1<<DP1R1W29_ADDR_WD),
  parameter DP1R1W30_DEPTH = (1<<DP1R1W30_ADDR_WD),
  parameter DP1R1W31_DEPTH = (1<<DP1R1W31_ADDR_WD),
  // DP1R1W HOLD DATA
  parameter DP1R1W0_HOLDDATA   = 0,
  parameter DP1R1W1_HOLDDATA   = 0,
  parameter DP1R1W2_HOLDDATA   = 0,
  parameter DP1R1W3_HOLDDATA   = 0,
  parameter DP1R1W4_HOLDDATA   = 0,
  parameter DP1R1W5_HOLDDATA   = 0,
  parameter DP1R1W6_HOLDDATA   = 0,
  parameter DP1R1W7_HOLDDATA   = 0,
  parameter DP1R1W8_HOLDDATA   = 0,
  parameter DP1R1W9_HOLDDATA   = 0,
  parameter DP1R1W10_HOLDDATA  = 0,
  parameter DP1R1W11_HOLDDATA  = 0,
  parameter DP1R1W12_HOLDDATA  = 0,
  parameter DP1R1W13_HOLDDATA  = 0,
  parameter DP1R1W14_HOLDDATA  = 0,
  parameter DP1R1W15_HOLDDATA  = 0,
  parameter DP1R1W16_HOLDDATA  = 0,
  parameter DP1R1W17_HOLDDATA  = 0,
  parameter DP1R1W18_HOLDDATA  = 0,
  parameter DP1R1W19_HOLDDATA  = 0,
  parameter DP1R1W20_HOLDDATA  = 0,
  parameter DP1R1W21_HOLDDATA  = 0,
  parameter DP1R1W22_HOLDDATA  = 0,
  parameter DP1R1W23_HOLDDATA  = 0,
  parameter DP1R1W24_HOLDDATA  = 0,
  parameter DP1R1W25_HOLDDATA  = 0,
  parameter DP1R1W26_HOLDDATA  = 0,
  parameter DP1R1W27_HOLDDATA  = 0,
  parameter DP1R1W28_HOLDDATA  = 0,
  parameter DP1R1W29_HOLDDATA  = 0,
  parameter DP1R1W30_HOLDDATA  = 0,
  parameter DP1R1W31_HOLDDATA  = 0,

  // DP2R2W NAME (STRING)
  parameter DP2R2W0_NAME   = "0",
  parameter DP2R2W1_NAME   = "1",
  parameter DP2R2W2_NAME   = "2",
  parameter DP2R2W3_NAME   = "3",
  parameter DP2R2W4_NAME   = "4",
  parameter DP2R2W5_NAME   = "5",
  parameter DP2R2W6_NAME   = "6",
  parameter DP2R2W7_NAME   = "7",
  parameter DP2R2W8_NAME   = "8",
  parameter DP2R2W9_NAME   = "9",
  parameter DP2R2W10_NAME  = "10",
  parameter DP2R2W11_NAME  = "11",
  parameter DP2R2W12_NAME  = "12",
  parameter DP2R2W13_NAME  = "13",
  parameter DP2R2W14_NAME  = "14",
  parameter DP2R2W15_NAME  = "15",
  parameter DP2R2W16_NAME  = "16",
  parameter DP2R2W17_NAME  = "17",
  parameter DP2R2W18_NAME  = "18",
  parameter DP2R2W19_NAME  = "19",
  parameter DP2R2W20_NAME  = "20",
  parameter DP2R2W21_NAME  = "21",
  parameter DP2R2W22_NAME  = "22",
  parameter DP2R2W23_NAME  = "23",
  parameter DP2R2W24_NAME  = "24",
  parameter DP2R2W25_NAME  = "25",
  parameter DP2R2W26_NAME  = "26",
  parameter DP2R2W27_NAME  = "27",
  parameter DP2R2W28_NAME  = "28",
  parameter DP2R2W29_NAME  = "29",
  parameter DP2R2W30_NAME  = "30",
  parameter DP2R2W31_NAME  = "31",
  // DP2R2W READ DELAY (number of clock cycles)
  parameter DP2R2W0_READ_DELAY  = 0,
  parameter DP2R2W1_READ_DELAY  = 0,
  parameter DP2R2W2_READ_DELAY  = 0,
  parameter DP2R2W3_READ_DELAY  = 0,
  parameter DP2R2W4_READ_DELAY  = 0,
  parameter DP2R2W5_READ_DELAY  = 0,
  parameter DP2R2W6_READ_DELAY  = 0,
  parameter DP2R2W7_READ_DELAY  = 0,
  parameter DP2R2W8_READ_DELAY  = 0,
  parameter DP2R2W9_READ_DELAY  = 0,
  parameter DP2R2W10_READ_DELAY = 0,
  parameter DP2R2W11_READ_DELAY = 0,
  parameter DP2R2W12_READ_DELAY = 0,
  parameter DP2R2W13_READ_DELAY = 0,
  parameter DP2R2W14_READ_DELAY = 0,
  parameter DP2R2W15_READ_DELAY = 0,
  parameter DP2R2W16_READ_DELAY = 0,
  parameter DP2R2W17_READ_DELAY = 0,
  parameter DP2R2W18_READ_DELAY = 0,
  parameter DP2R2W19_READ_DELAY = 0,
  parameter DP2R2W20_READ_DELAY = 0,
  parameter DP2R2W21_READ_DELAY = 0,
  parameter DP2R2W22_READ_DELAY = 0,
  parameter DP2R2W23_READ_DELAY = 0,
  parameter DP2R2W24_READ_DELAY = 0,
  parameter DP2R2W25_READ_DELAY = 0,
  parameter DP2R2W26_READ_DELAY = 0,
  parameter DP2R2W27_READ_DELAY = 0,
  parameter DP2R2W28_READ_DELAY = 0,
  parameter DP2R2W29_READ_DELAY = 0,
  parameter DP2R2W30_READ_DELAY = 0,
  parameter DP2R2W31_READ_DELAY = 0,
  // DP2R2W ADDRESS WIDTH
  parameter DP2R2W0_ADDR_WD  = 1,
  parameter DP2R2W1_ADDR_WD  = 1,
  parameter DP2R2W2_ADDR_WD  = 1,
  parameter DP2R2W3_ADDR_WD  = 1,
  parameter DP2R2W4_ADDR_WD  = 1,
  parameter DP2R2W5_ADDR_WD  = 1,
  parameter DP2R2W6_ADDR_WD  = 1,
  parameter DP2R2W7_ADDR_WD  = 1,
  parameter DP2R2W8_ADDR_WD  = 1,
  parameter DP2R2W9_ADDR_WD  = 1,
  parameter DP2R2W10_ADDR_WD = 1,
  parameter DP2R2W11_ADDR_WD = 1,
  parameter DP2R2W12_ADDR_WD = 1,
  parameter DP2R2W13_ADDR_WD = 1,
  parameter DP2R2W14_ADDR_WD = 1,
  parameter DP2R2W15_ADDR_WD = 1,
  parameter DP2R2W16_ADDR_WD = 1,
  parameter DP2R2W17_ADDR_WD = 1,
  parameter DP2R2W18_ADDR_WD = 1,
  parameter DP2R2W19_ADDR_WD = 1,
  parameter DP2R2W20_ADDR_WD = 1,
  parameter DP2R2W21_ADDR_WD = 1,
  parameter DP2R2W22_ADDR_WD = 1,
  parameter DP2R2W23_ADDR_WD = 1,
  parameter DP2R2W24_ADDR_WD = 1,
  parameter DP2R2W25_ADDR_WD = 1,
  parameter DP2R2W26_ADDR_WD = 1,
  parameter DP2R2W27_ADDR_WD = 1,
  parameter DP2R2W28_ADDR_WD = 1,
  parameter DP2R2W29_ADDR_WD = 1,
  parameter DP2R2W30_ADDR_WD = 1,
  parameter DP2R2W31_ADDR_WD = 1,
  // DP2R2W DATA WIDTH
  parameter DP2R2W0_DATA_WD  = 1,
  parameter DP2R2W1_DATA_WD  = 1,
  parameter DP2R2W2_DATA_WD  = 1,
  parameter DP2R2W3_DATA_WD  = 1,
  parameter DP2R2W4_DATA_WD  = 1,
  parameter DP2R2W5_DATA_WD  = 1,
  parameter DP2R2W6_DATA_WD  = 1,
  parameter DP2R2W7_DATA_WD  = 1,
  parameter DP2R2W8_DATA_WD  = 1,
  parameter DP2R2W9_DATA_WD  = 1,
  parameter DP2R2W10_DATA_WD = 1,
  parameter DP2R2W11_DATA_WD = 1,
  parameter DP2R2W12_DATA_WD = 1,
  parameter DP2R2W13_DATA_WD = 1,
  parameter DP2R2W14_DATA_WD = 1,
  parameter DP2R2W15_DATA_WD = 1,
  parameter DP2R2W16_DATA_WD = 1,
  parameter DP2R2W17_DATA_WD = 1,
  parameter DP2R2W18_DATA_WD = 1,
  parameter DP2R2W19_DATA_WD = 1,
  parameter DP2R2W20_DATA_WD = 1,
  parameter DP2R2W21_DATA_WD = 1,
  parameter DP2R2W22_DATA_WD = 1,
  parameter DP2R2W23_DATA_WD = 1,
  parameter DP2R2W24_DATA_WD = 1,
  parameter DP2R2W25_DATA_WD = 1,
  parameter DP2R2W26_DATA_WD = 1,
  parameter DP2R2W27_DATA_WD = 1,
  parameter DP2R2W28_DATA_WD = 1,
  parameter DP2R2W29_DATA_WD = 1,
  parameter DP2R2W30_DATA_WD = 1,
  parameter DP2R2W31_DATA_WD = 1,
  // DP2R2W DEPTH of RAM
  parameter DP2R2W0_DEPTH  = (1<<DP2R2W0_ADDR_WD ),
  parameter DP2R2W1_DEPTH  = (1<<DP2R2W1_ADDR_WD ),
  parameter DP2R2W2_DEPTH  = (1<<DP2R2W2_ADDR_WD ),
  parameter DP2R2W3_DEPTH  = (1<<DP2R2W3_ADDR_WD ),
  parameter DP2R2W4_DEPTH  = (1<<DP2R2W4_ADDR_WD ),
  parameter DP2R2W5_DEPTH  = (1<<DP2R2W5_ADDR_WD ),
  parameter DP2R2W6_DEPTH  = (1<<DP2R2W6_ADDR_WD ),
  parameter DP2R2W7_DEPTH  = (1<<DP2R2W7_ADDR_WD ),
  parameter DP2R2W8_DEPTH  = (1<<DP2R2W8_ADDR_WD ),
  parameter DP2R2W9_DEPTH  = (1<<DP2R2W9_ADDR_WD ),
  parameter DP2R2W10_DEPTH = (1<<DP2R2W10_ADDR_WD),
  parameter DP2R2W11_DEPTH = (1<<DP2R2W11_ADDR_WD),
  parameter DP2R2W12_DEPTH = (1<<DP2R2W12_ADDR_WD),
  parameter DP2R2W13_DEPTH = (1<<DP2R2W13_ADDR_WD),
  parameter DP2R2W14_DEPTH = (1<<DP2R2W14_ADDR_WD),
  parameter DP2R2W15_DEPTH = (1<<DP2R2W15_ADDR_WD),
  parameter DP2R2W16_DEPTH = (1<<DP2R2W16_ADDR_WD),
  parameter DP2R2W17_DEPTH = (1<<DP2R2W17_ADDR_WD),
  parameter DP2R2W18_DEPTH = (1<<DP2R2W18_ADDR_WD),
  parameter DP2R2W19_DEPTH = (1<<DP2R2W19_ADDR_WD),
  parameter DP2R2W20_DEPTH = (1<<DP2R2W20_ADDR_WD),
  parameter DP2R2W21_DEPTH = (1<<DP2R2W21_ADDR_WD),
  parameter DP2R2W22_DEPTH = (1<<DP2R2W22_ADDR_WD),
  parameter DP2R2W23_DEPTH = (1<<DP2R2W23_ADDR_WD),
  parameter DP2R2W24_DEPTH = (1<<DP2R2W24_ADDR_WD),
  parameter DP2R2W25_DEPTH = (1<<DP2R2W25_ADDR_WD),
  parameter DP2R2W26_DEPTH = (1<<DP2R2W26_ADDR_WD),
  parameter DP2R2W27_DEPTH = (1<<DP2R2W27_ADDR_WD),
  parameter DP2R2W28_DEPTH = (1<<DP2R2W28_ADDR_WD),
  parameter DP2R2W29_DEPTH = (1<<DP2R2W29_ADDR_WD),
  parameter DP2R2W30_DEPTH = (1<<DP2R2W30_ADDR_WD),
  parameter DP2R2W31_DEPTH = (1<<DP2R2W31_ADDR_WD),
  // DP2R2W HOLD DATA
  parameter DP2R2W0_HOLDDATA   = 0,
  parameter DP2R2W1_HOLDDATA   = 0,
  parameter DP2R2W2_HOLDDATA   = 0,
  parameter DP2R2W3_HOLDDATA   = 0,
  parameter DP2R2W4_HOLDDATA   = 0,
  parameter DP2R2W5_HOLDDATA   = 0,
  parameter DP2R2W6_HOLDDATA   = 0,
  parameter DP2R2W7_HOLDDATA   = 0,
  parameter DP2R2W8_HOLDDATA   = 0,
  parameter DP2R2W9_HOLDDATA   = 0,
  parameter DP2R2W10_HOLDDATA  = 0,
  parameter DP2R2W11_HOLDDATA  = 0,
  parameter DP2R2W12_HOLDDATA  = 0,
  parameter DP2R2W13_HOLDDATA  = 0,
  parameter DP2R2W14_HOLDDATA  = 0,
  parameter DP2R2W15_HOLDDATA  = 0,
  parameter DP2R2W16_HOLDDATA  = 0,
  parameter DP2R2W17_HOLDDATA  = 0,
  parameter DP2R2W18_HOLDDATA  = 0,
  parameter DP2R2W19_HOLDDATA  = 0,
  parameter DP2R2W20_HOLDDATA  = 0,
  parameter DP2R2W21_HOLDDATA  = 0,
  parameter DP2R2W22_HOLDDATA  = 0,
  parameter DP2R2W23_HOLDDATA  = 0,
  parameter DP2R2W24_HOLDDATA  = 0,
  parameter DP2R2W25_HOLDDATA  = 0,
  parameter DP2R2W26_HOLDDATA  = 0,
  parameter DP2R2W27_HOLDDATA  = 0,
  parameter DP2R2W28_HOLDDATA  = 0,
  parameter DP2R2W29_HOLDDATA  = 0,
  parameter DP2R2W30_HOLDDATA  = 0,
  parameter DP2R2W31_HOLDDATA  = 0,

  // RF NAME (STRING)
  parameter RF0_NAME   = "0",
  parameter RF1_NAME   = "1",
  parameter RF2_NAME   = "2",
  parameter RF3_NAME   = "3",
  parameter RF4_NAME   = "4",
  parameter RF5_NAME   = "5",
  parameter RF6_NAME   = "6",
  parameter RF7_NAME   = "7",
  parameter RF8_NAME   = "8",
  parameter RF9_NAME   = "9",
  parameter RF10_NAME  = "10",
  parameter RF11_NAME  = "11",
  parameter RF12_NAME  = "12",
  parameter RF13_NAME  = "13",
  parameter RF14_NAME  = "14",
  parameter RF15_NAME  = "15",
  parameter RF16_NAME  = "16",
  parameter RF17_NAME  = "17",
  parameter RF18_NAME  = "18",
  parameter RF19_NAME  = "19",
  parameter RF20_NAME  = "20",
  parameter RF21_NAME  = "21",
  parameter RF22_NAME  = "22",
  parameter RF23_NAME  = "23",
  parameter RF24_NAME  = "24",
  parameter RF25_NAME  = "25",
  parameter RF26_NAME  = "26",
  parameter RF27_NAME  = "27",
  parameter RF28_NAME  = "28",
  parameter RF29_NAME  = "29",
  parameter RF30_NAME  = "30",
  parameter RF31_NAME  = "31",
  // RF READ DELAY (number of clock cycles)
  parameter RF0_READ_DELAY  = 0,
  parameter RF1_READ_DELAY  = 0,
  parameter RF2_READ_DELAY  = 0,
  parameter RF3_READ_DELAY  = 0,
  parameter RF4_READ_DELAY  = 0,
  parameter RF5_READ_DELAY  = 0,
  parameter RF6_READ_DELAY  = 0,
  parameter RF7_READ_DELAY  = 0,
  parameter RF8_READ_DELAY  = 0,
  parameter RF9_READ_DELAY  = 0,
  parameter RF10_READ_DELAY = 0,
  parameter RF11_READ_DELAY = 0,
  parameter RF12_READ_DELAY = 0,
  parameter RF13_READ_DELAY = 0,
  parameter RF14_READ_DELAY = 0,
  parameter RF15_READ_DELAY = 0,
  parameter RF16_READ_DELAY = 0,
  parameter RF17_READ_DELAY = 0,
  parameter RF18_READ_DELAY = 0,
  parameter RF19_READ_DELAY = 0,
  parameter RF20_READ_DELAY = 0,
  parameter RF21_READ_DELAY = 0,
  parameter RF22_READ_DELAY = 0,
  parameter RF23_READ_DELAY = 0,
  parameter RF24_READ_DELAY = 0,
  parameter RF25_READ_DELAY = 0,
  parameter RF26_READ_DELAY = 0,
  parameter RF27_READ_DELAY = 0,
  parameter RF28_READ_DELAY = 0,
  parameter RF29_READ_DELAY = 0,
  parameter RF30_READ_DELAY = 0,
  parameter RF31_READ_DELAY = 0,
  // RF ADDRESS WIDTH
  parameter RF0_ADDR_WD   = 1,
  parameter RF1_ADDR_WD   = 1,
  parameter RF2_ADDR_WD   = 1,
  parameter RF3_ADDR_WD   = 1,
  parameter RF4_ADDR_WD   = 1,
  parameter RF5_ADDR_WD   = 1,
  parameter RF6_ADDR_WD   = 1,
  parameter RF7_ADDR_WD   = 1,
  parameter RF8_ADDR_WD   = 1,
  parameter RF9_ADDR_WD   = 1,
  parameter RF10_ADDR_WD  = 1,
  parameter RF11_ADDR_WD  = 1,
  parameter RF12_ADDR_WD  = 1,
  parameter RF13_ADDR_WD  = 1,
  parameter RF14_ADDR_WD  = 1,
  parameter RF15_ADDR_WD  = 1,
  parameter RF16_ADDR_WD  = 1,
  parameter RF17_ADDR_WD  = 1,
  parameter RF18_ADDR_WD  = 1,
  parameter RF19_ADDR_WD  = 1,
  parameter RF20_ADDR_WD  = 1,
  parameter RF21_ADDR_WD  = 1,
  parameter RF22_ADDR_WD  = 1,
  parameter RF23_ADDR_WD  = 1,
  parameter RF24_ADDR_WD  = 1,
  parameter RF25_ADDR_WD  = 1,
  parameter RF26_ADDR_WD  = 1,
  parameter RF27_ADDR_WD  = 1,
  parameter RF28_ADDR_WD  = 1,
  parameter RF29_ADDR_WD  = 1,
  parameter RF30_ADDR_WD  = 1,
  parameter RF31_ADDR_WD  = 1,
  // RF DATA WIDTH
  parameter RF0_DATA_WD   = 1,
  parameter RF1_DATA_WD   = 1,
  parameter RF2_DATA_WD   = 1,
  parameter RF3_DATA_WD   = 1,
  parameter RF4_DATA_WD   = 1,
  parameter RF5_DATA_WD   = 1,
  parameter RF6_DATA_WD   = 1,
  parameter RF7_DATA_WD   = 1,
  parameter RF8_DATA_WD   = 1,
  parameter RF9_DATA_WD   = 1,
  parameter RF10_DATA_WD  = 1,
  parameter RF11_DATA_WD  = 1,
  parameter RF12_DATA_WD  = 1,
  parameter RF13_DATA_WD  = 1,
  parameter RF14_DATA_WD  = 1,
  parameter RF15_DATA_WD  = 1,
  parameter RF16_DATA_WD  = 1,
  parameter RF17_DATA_WD  = 1,
  parameter RF18_DATA_WD  = 1,
  parameter RF19_DATA_WD  = 1,
  parameter RF20_DATA_WD  = 1,
  parameter RF21_DATA_WD  = 1,
  parameter RF22_DATA_WD  = 1,
  parameter RF23_DATA_WD  = 1,
  parameter RF24_DATA_WD  = 1,
  parameter RF25_DATA_WD  = 1,
  parameter RF26_DATA_WD  = 1,
  parameter RF27_DATA_WD  = 1,
  parameter RF28_DATA_WD  = 1,
  parameter RF29_DATA_WD  = 1,
  parameter RF30_DATA_WD  = 1,
  parameter RF31_DATA_WD  = 1,
  // RF DEPTH of RAM
  parameter RF0_DEPTH  = (1<<RF0_ADDR_WD ),
  parameter RF1_DEPTH  = (1<<RF1_ADDR_WD ),
  parameter RF2_DEPTH  = (1<<RF2_ADDR_WD ),
  parameter RF3_DEPTH  = (1<<RF3_ADDR_WD ),
  parameter RF4_DEPTH  = (1<<RF4_ADDR_WD ),
  parameter RF5_DEPTH  = (1<<RF5_ADDR_WD ),
  parameter RF6_DEPTH  = (1<<RF6_ADDR_WD ),
  parameter RF7_DEPTH  = (1<<RF7_ADDR_WD ),
  parameter RF8_DEPTH  = (1<<RF8_ADDR_WD ),
  parameter RF9_DEPTH  = (1<<RF9_ADDR_WD ),
  parameter RF10_DEPTH = (1<<RF10_ADDR_WD),
  parameter RF11_DEPTH = (1<<RF11_ADDR_WD),
  parameter RF12_DEPTH = (1<<RF12_ADDR_WD),
  parameter RF13_DEPTH = (1<<RF13_ADDR_WD),
  parameter RF14_DEPTH = (1<<RF14_ADDR_WD),
  parameter RF15_DEPTH = (1<<RF15_ADDR_WD),
  parameter RF16_DEPTH = (1<<RF16_ADDR_WD),
  parameter RF17_DEPTH = (1<<RF17_ADDR_WD),
  parameter RF18_DEPTH = (1<<RF18_ADDR_WD),
  parameter RF19_DEPTH = (1<<RF19_ADDR_WD),
  parameter RF20_DEPTH = (1<<RF20_ADDR_WD),
  parameter RF21_DEPTH = (1<<RF21_ADDR_WD),
  parameter RF22_DEPTH = (1<<RF22_ADDR_WD),
  parameter RF23_DEPTH = (1<<RF23_ADDR_WD),
  parameter RF24_DEPTH = (1<<RF24_ADDR_WD),
  parameter RF25_DEPTH = (1<<RF25_ADDR_WD),
  parameter RF26_DEPTH = (1<<RF26_ADDR_WD),
  parameter RF27_DEPTH = (1<<RF27_ADDR_WD),
  parameter RF28_DEPTH = (1<<RF28_ADDR_WD),
  parameter RF29_DEPTH = (1<<RF29_ADDR_WD),
  parameter RF30_DEPTH = (1<<RF30_ADDR_WD),
  parameter RF31_DEPTH = (1<<RF31_ADDR_WD),
  // RF HOLD DATA
  parameter RF0_HOLDDATA   = 0,
  parameter RF1_HOLDDATA   = 0,
  parameter RF2_HOLDDATA   = 0,
  parameter RF3_HOLDDATA   = 0,
  parameter RF4_HOLDDATA   = 0,
  parameter RF5_HOLDDATA   = 0,
  parameter RF6_HOLDDATA   = 0,
  parameter RF7_HOLDDATA   = 0,
  parameter RF8_HOLDDATA   = 0,
  parameter RF9_HOLDDATA   = 0,
  parameter RF10_HOLDDATA  = 0,
  parameter RF11_HOLDDATA  = 0,
  parameter RF12_HOLDDATA  = 0,
  parameter RF13_HOLDDATA  = 0,
  parameter RF14_HOLDDATA  = 0,
  parameter RF15_HOLDDATA  = 0,
  parameter RF16_HOLDDATA  = 0,
  parameter RF17_HOLDDATA  = 0,
  parameter RF18_HOLDDATA  = 0,
  parameter RF19_HOLDDATA  = 0,
  parameter RF20_HOLDDATA  = 0,
  parameter RF21_HOLDDATA  = 0,
  parameter RF22_HOLDDATA  = 0,
  parameter RF23_HOLDDATA  = 0,
  parameter RF24_HOLDDATA  = 0,
  parameter RF25_HOLDDATA  = 0,
  parameter RF26_HOLDDATA  = 0,
  parameter RF27_HOLDDATA  = 0,
  parameter RF28_HOLDDATA  = 0,
  parameter RF29_HOLDDATA  = 0,
  parameter RF30_HOLDDATA  = 0,
  parameter RF31_HOLDDATA  = 0,

  // SRAM_BE NAME (STRING)
  parameter SRAM_BE_0_NAME   = "0",
  parameter SRAM_BE_1_NAME   = "1",
  parameter SRAM_BE_2_NAME   = "2",
  parameter SRAM_BE_3_NAME   = "3",
  parameter SRAM_BE_4_NAME   = "4",
  parameter SRAM_BE_5_NAME   = "5",
  parameter SRAM_BE_6_NAME   = "6",
  parameter SRAM_BE_7_NAME   = "7",
  parameter SRAM_BE_8_NAME   = "8",
  parameter SRAM_BE_9_NAME   = "9",
  parameter SRAM_BE_10_NAME  = "10",
  parameter SRAM_BE_11_NAME  = "11",
  parameter SRAM_BE_12_NAME  = "12",
  parameter SRAM_BE_13_NAME  = "13",
  parameter SRAM_BE_14_NAME  = "14",
  parameter SRAM_BE_15_NAME  = "15",
  parameter SRAM_BE_16_NAME  = "16",
  parameter SRAM_BE_17_NAME  = "17",
  parameter SRAM_BE_18_NAME  = "18",
  parameter SRAM_BE_19_NAME  = "19",
  parameter SRAM_BE_20_NAME  = "20",
  parameter SRAM_BE_21_NAME  = "21",
  parameter SRAM_BE_22_NAME  = "22",
  parameter SRAM_BE_23_NAME  = "23",
  parameter SRAM_BE_24_NAME  = "24",
  parameter SRAM_BE_25_NAME  = "25",
  parameter SRAM_BE_26_NAME  = "26",
  parameter SRAM_BE_27_NAME  = "27",
  parameter SRAM_BE_28_NAME  = "28",
  parameter SRAM_BE_29_NAME  = "29",
  parameter SRAM_BE_30_NAME  = "30",
  parameter SRAM_BE_31_NAME  = "31",
  // SRAM_BE READ DELAY (number of clock cycles)
  parameter SRAM_BE_0_READ_DELAY  = 0,
  parameter SRAM_BE_1_READ_DELAY  = 0,
  parameter SRAM_BE_2_READ_DELAY  = 0,
  parameter SRAM_BE_3_READ_DELAY  = 0,
  parameter SRAM_BE_4_READ_DELAY  = 0,
  parameter SRAM_BE_5_READ_DELAY  = 0,
  parameter SRAM_BE_6_READ_DELAY  = 0,
  parameter SRAM_BE_7_READ_DELAY  = 0,
  parameter SRAM_BE_8_READ_DELAY  = 0,
  parameter SRAM_BE_9_READ_DELAY  = 0,
  parameter SRAM_BE_10_READ_DELAY = 0,
  parameter SRAM_BE_11_READ_DELAY = 0,
  parameter SRAM_BE_12_READ_DELAY = 0,
  parameter SRAM_BE_13_READ_DELAY = 0,
  parameter SRAM_BE_14_READ_DELAY = 0,
  parameter SRAM_BE_15_READ_DELAY = 0,
  parameter SRAM_BE_16_READ_DELAY = 0,
  parameter SRAM_BE_17_READ_DELAY = 0,
  parameter SRAM_BE_18_READ_DELAY = 0,
  parameter SRAM_BE_19_READ_DELAY = 0,
  parameter SRAM_BE_20_READ_DELAY = 0,
  parameter SRAM_BE_21_READ_DELAY = 0,
  parameter SRAM_BE_22_READ_DELAY = 0,
  parameter SRAM_BE_23_READ_DELAY = 0,
  parameter SRAM_BE_24_READ_DELAY = 0,
  parameter SRAM_BE_25_READ_DELAY = 0,
  parameter SRAM_BE_26_READ_DELAY = 0,
  parameter SRAM_BE_27_READ_DELAY = 0,
  parameter SRAM_BE_28_READ_DELAY = 0,
  parameter SRAM_BE_29_READ_DELAY = 0,
  parameter SRAM_BE_30_READ_DELAY = 0,
  parameter SRAM_BE_31_READ_DELAY = 0,
  // SRAM_BE ADDRESS WIDTH
  parameter SRAM_BE_0_ADDR_WD   = 1,
  parameter SRAM_BE_1_ADDR_WD   = 1,
  parameter SRAM_BE_2_ADDR_WD   = 1,
  parameter SRAM_BE_3_ADDR_WD   = 1,
  parameter SRAM_BE_4_ADDR_WD   = 1,
  parameter SRAM_BE_5_ADDR_WD   = 1,
  parameter SRAM_BE_6_ADDR_WD   = 1,
  parameter SRAM_BE_7_ADDR_WD   = 1,
  parameter SRAM_BE_8_ADDR_WD   = 1,
  parameter SRAM_BE_9_ADDR_WD   = 1,
  parameter SRAM_BE_10_ADDR_WD  = 1,
  parameter SRAM_BE_11_ADDR_WD  = 1,
  parameter SRAM_BE_12_ADDR_WD  = 1,
  parameter SRAM_BE_13_ADDR_WD  = 1,
  parameter SRAM_BE_14_ADDR_WD  = 1,
  parameter SRAM_BE_15_ADDR_WD  = 1,
  parameter SRAM_BE_16_ADDR_WD  = 1,
  parameter SRAM_BE_17_ADDR_WD  = 1,
  parameter SRAM_BE_18_ADDR_WD  = 1,
  parameter SRAM_BE_19_ADDR_WD  = 1,
  parameter SRAM_BE_20_ADDR_WD  = 1,
  parameter SRAM_BE_21_ADDR_WD  = 1,
  parameter SRAM_BE_22_ADDR_WD  = 1,
  parameter SRAM_BE_23_ADDR_WD  = 1,
  parameter SRAM_BE_24_ADDR_WD  = 1,
  parameter SRAM_BE_25_ADDR_WD  = 1,
  parameter SRAM_BE_26_ADDR_WD  = 1,
  parameter SRAM_BE_27_ADDR_WD  = 1,
  parameter SRAM_BE_28_ADDR_WD  = 1,
  parameter SRAM_BE_29_ADDR_WD  = 1,
  parameter SRAM_BE_30_ADDR_WD  = 1,
  parameter SRAM_BE_31_ADDR_WD  = 1,
  // SRAM_BE DATA WIDTH
  parameter SRAM_BE_0_DATA_WD   = 8,
  parameter SRAM_BE_1_DATA_WD   = 8,
  parameter SRAM_BE_2_DATA_WD   = 8,
  parameter SRAM_BE_3_DATA_WD   = 8,
  parameter SRAM_BE_4_DATA_WD   = 8,
  parameter SRAM_BE_5_DATA_WD   = 8,
  parameter SRAM_BE_6_DATA_WD   = 8,
  parameter SRAM_BE_7_DATA_WD   = 8,
  parameter SRAM_BE_8_DATA_WD   = 8,
  parameter SRAM_BE_9_DATA_WD   = 8,
  parameter SRAM_BE_10_DATA_WD  = 8,
  parameter SRAM_BE_11_DATA_WD  = 8,
  parameter SRAM_BE_12_DATA_WD  = 8,
  parameter SRAM_BE_13_DATA_WD  = 8,
  parameter SRAM_BE_14_DATA_WD  = 8,
  parameter SRAM_BE_15_DATA_WD  = 8,
  parameter SRAM_BE_16_DATA_WD  = 8,
  parameter SRAM_BE_17_DATA_WD  = 8,
  parameter SRAM_BE_18_DATA_WD  = 8,
  parameter SRAM_BE_19_DATA_WD  = 8,
  parameter SRAM_BE_20_DATA_WD  = 8,
  parameter SRAM_BE_21_DATA_WD  = 8,
  parameter SRAM_BE_22_DATA_WD  = 8,
  parameter SRAM_BE_23_DATA_WD  = 8,
  parameter SRAM_BE_24_DATA_WD  = 8,
  parameter SRAM_BE_25_DATA_WD  = 8,
  parameter SRAM_BE_26_DATA_WD  = 8,
  parameter SRAM_BE_27_DATA_WD  = 8,
  parameter SRAM_BE_28_DATA_WD  = 8,
  parameter SRAM_BE_29_DATA_WD  = 8,
  parameter SRAM_BE_30_DATA_WD  = 8,
  parameter SRAM_BE_31_DATA_WD  = 8,
  // SRAM_BE DEPTH of RAM
  parameter SRAM_BE_0_DEPTH  = (1<<SRAM_BE_0_ADDR_WD ),
  parameter SRAM_BE_1_DEPTH  = (1<<SRAM_BE_1_ADDR_WD ),
  parameter SRAM_BE_2_DEPTH  = (1<<SRAM_BE_2_ADDR_WD ),
  parameter SRAM_BE_3_DEPTH  = (1<<SRAM_BE_3_ADDR_WD ),
  parameter SRAM_BE_4_DEPTH  = (1<<SRAM_BE_4_ADDR_WD ),
  parameter SRAM_BE_5_DEPTH  = (1<<SRAM_BE_5_ADDR_WD ),
  parameter SRAM_BE_6_DEPTH  = (1<<SRAM_BE_6_ADDR_WD ),
  parameter SRAM_BE_7_DEPTH  = (1<<SRAM_BE_7_ADDR_WD ),
  parameter SRAM_BE_8_DEPTH  = (1<<SRAM_BE_8_ADDR_WD ),
  parameter SRAM_BE_9_DEPTH  = (1<<SRAM_BE_9_ADDR_WD ),
  parameter SRAM_BE_10_DEPTH = (1<<SRAM_BE_10_ADDR_WD),
  parameter SRAM_BE_11_DEPTH = (1<<SRAM_BE_11_ADDR_WD),
  parameter SRAM_BE_12_DEPTH = (1<<SRAM_BE_12_ADDR_WD),
  parameter SRAM_BE_13_DEPTH = (1<<SRAM_BE_13_ADDR_WD),
  parameter SRAM_BE_14_DEPTH = (1<<SRAM_BE_14_ADDR_WD),
  parameter SRAM_BE_15_DEPTH = (1<<SRAM_BE_15_ADDR_WD),
  parameter SRAM_BE_16_DEPTH = (1<<SRAM_BE_16_ADDR_WD),
  parameter SRAM_BE_17_DEPTH = (1<<SRAM_BE_17_ADDR_WD),
  parameter SRAM_BE_18_DEPTH = (1<<SRAM_BE_18_ADDR_WD),
  parameter SRAM_BE_19_DEPTH = (1<<SRAM_BE_19_ADDR_WD),
  parameter SRAM_BE_20_DEPTH = (1<<SRAM_BE_20_ADDR_WD),
  parameter SRAM_BE_21_DEPTH = (1<<SRAM_BE_21_ADDR_WD),
  parameter SRAM_BE_22_DEPTH = (1<<SRAM_BE_22_ADDR_WD),
  parameter SRAM_BE_23_DEPTH = (1<<SRAM_BE_23_ADDR_WD),
  parameter SRAM_BE_24_DEPTH = (1<<SRAM_BE_24_ADDR_WD),
  parameter SRAM_BE_25_DEPTH = (1<<SRAM_BE_25_ADDR_WD),
  parameter SRAM_BE_26_DEPTH = (1<<SRAM_BE_26_ADDR_WD),
  parameter SRAM_BE_27_DEPTH = (1<<SRAM_BE_27_ADDR_WD),
  parameter SRAM_BE_28_DEPTH = (1<<SRAM_BE_28_ADDR_WD),
  parameter SRAM_BE_29_DEPTH = (1<<SRAM_BE_29_ADDR_WD),
  parameter SRAM_BE_30_DEPTH = (1<<SRAM_BE_30_ADDR_WD),
  parameter SRAM_BE_31_DEPTH = (1<<SRAM_BE_31_ADDR_WD),
  // SRAM_BE HOLD DATA
  parameter SRAM_BE_0_HOLDDATA   = 0,
  parameter SRAM_BE_1_HOLDDATA   = 0,
  parameter SRAM_BE_2_HOLDDATA   = 0,
  parameter SRAM_BE_3_HOLDDATA   = 0,
  parameter SRAM_BE_4_HOLDDATA   = 0,
  parameter SRAM_BE_5_HOLDDATA   = 0,
  parameter SRAM_BE_6_HOLDDATA   = 0,
  parameter SRAM_BE_7_HOLDDATA   = 0,
  parameter SRAM_BE_8_HOLDDATA   = 0,
  parameter SRAM_BE_9_HOLDDATA   = 0,
  parameter SRAM_BE_10_HOLDDATA  = 0,
  parameter SRAM_BE_11_HOLDDATA  = 0,
  parameter SRAM_BE_12_HOLDDATA  = 0,
  parameter SRAM_BE_13_HOLDDATA  = 0,
  parameter SRAM_BE_14_HOLDDATA  = 0,
  parameter SRAM_BE_15_HOLDDATA  = 0,
  parameter SRAM_BE_16_HOLDDATA  = 0,
  parameter SRAM_BE_17_HOLDDATA  = 0,
  parameter SRAM_BE_18_HOLDDATA  = 0,
  parameter SRAM_BE_19_HOLDDATA  = 0,
  parameter SRAM_BE_20_HOLDDATA  = 0,
  parameter SRAM_BE_21_HOLDDATA  = 0,
  parameter SRAM_BE_22_HOLDDATA  = 0,
  parameter SRAM_BE_23_HOLDDATA  = 0,
  parameter SRAM_BE_24_HOLDDATA  = 0,
  parameter SRAM_BE_25_HOLDDATA  = 0,
  parameter SRAM_BE_26_HOLDDATA  = 0,
  parameter SRAM_BE_27_HOLDDATA  = 0,
  parameter SRAM_BE_28_HOLDDATA  = 0,
  parameter SRAM_BE_29_HOLDDATA  = 0,
  parameter SRAM_BE_30_HOLDDATA  = 0,
  parameter SRAM_BE_31_HOLDDATA  = 0,

  // DP1R1W_BE NAME (STRING)
  parameter DP1R1W_BE_0_NAME   = "0",
  parameter DP1R1W_BE_1_NAME   = "1",
  parameter DP1R1W_BE_2_NAME   = "2",
  parameter DP1R1W_BE_3_NAME   = "3",
  parameter DP1R1W_BE_4_NAME   = "4",
  parameter DP1R1W_BE_5_NAME   = "5",
  parameter DP1R1W_BE_6_NAME   = "6",
  parameter DP1R1W_BE_7_NAME   = "7",
  parameter DP1R1W_BE_8_NAME   = "8",
  parameter DP1R1W_BE_9_NAME   = "9",
  parameter DP1R1W_BE_10_NAME  = "10",
  parameter DP1R1W_BE_11_NAME  = "11",
  parameter DP1R1W_BE_12_NAME  = "12",
  parameter DP1R1W_BE_13_NAME  = "13",
  parameter DP1R1W_BE_14_NAME  = "14",
  parameter DP1R1W_BE_15_NAME  = "15",
  parameter DP1R1W_BE_16_NAME  = "16",
  parameter DP1R1W_BE_17_NAME  = "17",
  parameter DP1R1W_BE_18_NAME  = "18",
  parameter DP1R1W_BE_19_NAME  = "19",
  parameter DP1R1W_BE_20_NAME  = "20",
  parameter DP1R1W_BE_21_NAME  = "21",
  parameter DP1R1W_BE_22_NAME  = "22",
  parameter DP1R1W_BE_23_NAME  = "23",
  parameter DP1R1W_BE_24_NAME  = "24",
  parameter DP1R1W_BE_25_NAME  = "25",
  parameter DP1R1W_BE_26_NAME  = "26",
  parameter DP1R1W_BE_27_NAME  = "27",
  parameter DP1R1W_BE_28_NAME  = "28",
  parameter DP1R1W_BE_29_NAME  = "29",
  parameter DP1R1W_BE_30_NAME  = "30",
  parameter DP1R1W_BE_31_NAME  = "31",
  // DP1R1W_BE READ DELAY (number of clock cycles)
  parameter DP1R1W_BE_0_READ_DELAY  = 0,
  parameter DP1R1W_BE_1_READ_DELAY  = 0,
  parameter DP1R1W_BE_2_READ_DELAY  = 0,
  parameter DP1R1W_BE_3_READ_DELAY  = 0,
  parameter DP1R1W_BE_4_READ_DELAY  = 0,
  parameter DP1R1W_BE_5_READ_DELAY  = 0,
  parameter DP1R1W_BE_6_READ_DELAY  = 0,
  parameter DP1R1W_BE_7_READ_DELAY  = 0,
  parameter DP1R1W_BE_8_READ_DELAY  = 0,
  parameter DP1R1W_BE_9_READ_DELAY  = 0,
  parameter DP1R1W_BE_10_READ_DELAY = 0,
  parameter DP1R1W_BE_11_READ_DELAY = 0,
  parameter DP1R1W_BE_12_READ_DELAY = 0,
  parameter DP1R1W_BE_13_READ_DELAY = 0,
  parameter DP1R1W_BE_14_READ_DELAY = 0,
  parameter DP1R1W_BE_15_READ_DELAY = 0,
  parameter DP1R1W_BE_16_READ_DELAY = 0,
  parameter DP1R1W_BE_17_READ_DELAY = 0,
  parameter DP1R1W_BE_18_READ_DELAY = 0,
  parameter DP1R1W_BE_19_READ_DELAY = 0,
  parameter DP1R1W_BE_20_READ_DELAY = 0,
  parameter DP1R1W_BE_21_READ_DELAY = 0,
  parameter DP1R1W_BE_22_READ_DELAY = 0,
  parameter DP1R1W_BE_23_READ_DELAY = 0,
  parameter DP1R1W_BE_24_READ_DELAY = 0,
  parameter DP1R1W_BE_25_READ_DELAY = 0,
  parameter DP1R1W_BE_26_READ_DELAY = 0,
  parameter DP1R1W_BE_27_READ_DELAY = 0,
  parameter DP1R1W_BE_28_READ_DELAY = 0,
  parameter DP1R1W_BE_29_READ_DELAY = 0,
  parameter DP1R1W_BE_30_READ_DELAY = 0,
  parameter DP1R1W_BE_31_READ_DELAY = 0,
  // DP1R1W_BE ADDRESS WIDTH
  parameter DP1R1W_BE_0_ADDR_WD  = 1,
  parameter DP1R1W_BE_1_ADDR_WD  = 1,
  parameter DP1R1W_BE_2_ADDR_WD  = 1,
  parameter DP1R1W_BE_3_ADDR_WD  = 1,
  parameter DP1R1W_BE_4_ADDR_WD  = 1,
  parameter DP1R1W_BE_5_ADDR_WD  = 1,
  parameter DP1R1W_BE_6_ADDR_WD  = 1,
  parameter DP1R1W_BE_7_ADDR_WD  = 1,
  parameter DP1R1W_BE_8_ADDR_WD  = 1,
  parameter DP1R1W_BE_9_ADDR_WD  = 1,
  parameter DP1R1W_BE_10_ADDR_WD = 1,
  parameter DP1R1W_BE_11_ADDR_WD = 1,
  parameter DP1R1W_BE_12_ADDR_WD = 1,
  parameter DP1R1W_BE_13_ADDR_WD = 1,
  parameter DP1R1W_BE_14_ADDR_WD = 1,
  parameter DP1R1W_BE_15_ADDR_WD = 1,
  parameter DP1R1W_BE_16_ADDR_WD = 1,
  parameter DP1R1W_BE_17_ADDR_WD = 1,
  parameter DP1R1W_BE_18_ADDR_WD = 1,
  parameter DP1R1W_BE_19_ADDR_WD = 1,
  parameter DP1R1W_BE_20_ADDR_WD = 1,
  parameter DP1R1W_BE_21_ADDR_WD = 1,
  parameter DP1R1W_BE_22_ADDR_WD = 1,
  parameter DP1R1W_BE_23_ADDR_WD = 1,
  parameter DP1R1W_BE_24_ADDR_WD = 1,
  parameter DP1R1W_BE_25_ADDR_WD = 1,
  parameter DP1R1W_BE_26_ADDR_WD = 1,
  parameter DP1R1W_BE_27_ADDR_WD = 1,
  parameter DP1R1W_BE_28_ADDR_WD = 1,
  parameter DP1R1W_BE_29_ADDR_WD = 1,
  parameter DP1R1W_BE_30_ADDR_WD = 1,
  parameter DP1R1W_BE_31_ADDR_WD = 1,
  // DP1R1W_BE DATA WIDTH
  parameter DP1R1W_BE_0_DATA_WD  = 8,
  parameter DP1R1W_BE_1_DATA_WD  = 8,
  parameter DP1R1W_BE_2_DATA_WD  = 8,
  parameter DP1R1W_BE_3_DATA_WD  = 8,
  parameter DP1R1W_BE_4_DATA_WD  = 8,
  parameter DP1R1W_BE_5_DATA_WD  = 8,
  parameter DP1R1W_BE_6_DATA_WD  = 8,
  parameter DP1R1W_BE_7_DATA_WD  = 8,
  parameter DP1R1W_BE_8_DATA_WD  = 8,
  parameter DP1R1W_BE_9_DATA_WD  = 8,
  parameter DP1R1W_BE_10_DATA_WD = 8,
  parameter DP1R1W_BE_11_DATA_WD = 8,
  parameter DP1R1W_BE_12_DATA_WD = 8,
  parameter DP1R1W_BE_13_DATA_WD = 8,
  parameter DP1R1W_BE_14_DATA_WD = 8,
  parameter DP1R1W_BE_15_DATA_WD = 8,
  parameter DP1R1W_BE_16_DATA_WD = 8,
  parameter DP1R1W_BE_17_DATA_WD = 8,
  parameter DP1R1W_BE_18_DATA_WD = 8,
  parameter DP1R1W_BE_19_DATA_WD = 8,
  parameter DP1R1W_BE_20_DATA_WD = 8,
  parameter DP1R1W_BE_21_DATA_WD = 8,
  parameter DP1R1W_BE_22_DATA_WD = 8,
  parameter DP1R1W_BE_23_DATA_WD = 8,
  parameter DP1R1W_BE_24_DATA_WD = 8,
  parameter DP1R1W_BE_25_DATA_WD = 8,
  parameter DP1R1W_BE_26_DATA_WD = 8,
  parameter DP1R1W_BE_27_DATA_WD = 8,
  parameter DP1R1W_BE_28_DATA_WD = 8,
  parameter DP1R1W_BE_29_DATA_WD = 8,
  parameter DP1R1W_BE_30_DATA_WD = 8,
  parameter DP1R1W_BE_31_DATA_WD = 8,
  // DP1R1W_BE DEPTH of RAM
  parameter DP1R1W_BE_0_DEPTH  = (1<<DP1R1W_BE_0_ADDR_WD ),
  parameter DP1R1W_BE_1_DEPTH  = (1<<DP1R1W_BE_1_ADDR_WD ),
  parameter DP1R1W_BE_2_DEPTH  = (1<<DP1R1W_BE_2_ADDR_WD ),
  parameter DP1R1W_BE_3_DEPTH  = (1<<DP1R1W_BE_3_ADDR_WD ),
  parameter DP1R1W_BE_4_DEPTH  = (1<<DP1R1W_BE_4_ADDR_WD ),
  parameter DP1R1W_BE_5_DEPTH  = (1<<DP1R1W_BE_5_ADDR_WD ),
  parameter DP1R1W_BE_6_DEPTH  = (1<<DP1R1W_BE_6_ADDR_WD ),
  parameter DP1R1W_BE_7_DEPTH  = (1<<DP1R1W_BE_7_ADDR_WD ),
  parameter DP1R1W_BE_8_DEPTH  = (1<<DP1R1W_BE_8_ADDR_WD ),
  parameter DP1R1W_BE_9_DEPTH  = (1<<DP1R1W_BE_9_ADDR_WD ),
  parameter DP1R1W_BE_10_DEPTH = (1<<DP1R1W_BE_10_ADDR_WD),
  parameter DP1R1W_BE_11_DEPTH = (1<<DP1R1W_BE_11_ADDR_WD),
  parameter DP1R1W_BE_12_DEPTH = (1<<DP1R1W_BE_12_ADDR_WD),
  parameter DP1R1W_BE_13_DEPTH = (1<<DP1R1W_BE_13_ADDR_WD),
  parameter DP1R1W_BE_14_DEPTH = (1<<DP1R1W_BE_14_ADDR_WD),
  parameter DP1R1W_BE_15_DEPTH = (1<<DP1R1W_BE_15_ADDR_WD),
  parameter DP1R1W_BE_16_DEPTH = (1<<DP1R1W_BE_16_ADDR_WD),
  parameter DP1R1W_BE_17_DEPTH = (1<<DP1R1W_BE_17_ADDR_WD),
  parameter DP1R1W_BE_18_DEPTH = (1<<DP1R1W_BE_18_ADDR_WD),
  parameter DP1R1W_BE_19_DEPTH = (1<<DP1R1W_BE_19_ADDR_WD),
  parameter DP1R1W_BE_20_DEPTH = (1<<DP1R1W_BE_20_ADDR_WD),
  parameter DP1R1W_BE_21_DEPTH = (1<<DP1R1W_BE_21_ADDR_WD),
  parameter DP1R1W_BE_22_DEPTH = (1<<DP1R1W_BE_22_ADDR_WD),
  parameter DP1R1W_BE_23_DEPTH = (1<<DP1R1W_BE_23_ADDR_WD),
  parameter DP1R1W_BE_24_DEPTH = (1<<DP1R1W_BE_24_ADDR_WD),
  parameter DP1R1W_BE_25_DEPTH = (1<<DP1R1W_BE_25_ADDR_WD),
  parameter DP1R1W_BE_26_DEPTH = (1<<DP1R1W_BE_26_ADDR_WD),
  parameter DP1R1W_BE_27_DEPTH = (1<<DP1R1W_BE_27_ADDR_WD),
  parameter DP1R1W_BE_28_DEPTH = (1<<DP1R1W_BE_28_ADDR_WD),
  parameter DP1R1W_BE_29_DEPTH = (1<<DP1R1W_BE_29_ADDR_WD),
  parameter DP1R1W_BE_30_DEPTH = (1<<DP1R1W_BE_30_ADDR_WD),
  parameter DP1R1W_BE_31_DEPTH = (1<<DP1R1W_BE_31_ADDR_WD),
  // DP1R1W_BE HOLD DATA
  parameter DP1R1W_BE_0_HOLDDATA   = 0,
  parameter DP1R1W_BE_1_HOLDDATA   = 0,
  parameter DP1R1W_BE_2_HOLDDATA   = 0,
  parameter DP1R1W_BE_3_HOLDDATA   = 0,
  parameter DP1R1W_BE_4_HOLDDATA   = 0,
  parameter DP1R1W_BE_5_HOLDDATA   = 0,
  parameter DP1R1W_BE_6_HOLDDATA   = 0,
  parameter DP1R1W_BE_7_HOLDDATA   = 0,
  parameter DP1R1W_BE_8_HOLDDATA   = 0,
  parameter DP1R1W_BE_9_HOLDDATA   = 0,
  parameter DP1R1W_BE_10_HOLDDATA  = 0,
  parameter DP1R1W_BE_11_HOLDDATA  = 0,
  parameter DP1R1W_BE_12_HOLDDATA  = 0,
  parameter DP1R1W_BE_13_HOLDDATA  = 0,
  parameter DP1R1W_BE_14_HOLDDATA  = 0,
  parameter DP1R1W_BE_15_HOLDDATA  = 0,
  parameter DP1R1W_BE_16_HOLDDATA  = 0,
  parameter DP1R1W_BE_17_HOLDDATA  = 0,
  parameter DP1R1W_BE_18_HOLDDATA  = 0,
  parameter DP1R1W_BE_19_HOLDDATA  = 0,
  parameter DP1R1W_BE_20_HOLDDATA  = 0,
  parameter DP1R1W_BE_21_HOLDDATA  = 0,
  parameter DP1R1W_BE_22_HOLDDATA  = 0,
  parameter DP1R1W_BE_23_HOLDDATA  = 0,
  parameter DP1R1W_BE_24_HOLDDATA  = 0,
  parameter DP1R1W_BE_25_HOLDDATA  = 0,
  parameter DP1R1W_BE_26_HOLDDATA  = 0,
  parameter DP1R1W_BE_27_HOLDDATA  = 0,
  parameter DP1R1W_BE_28_HOLDDATA  = 0,
  parameter DP1R1W_BE_29_HOLDDATA  = 0,
  parameter DP1R1W_BE_30_HOLDDATA  = 0,
  parameter DP1R1W_BE_31_HOLDDATA  = 0,

  // DP2R2W_BE NAME (STRING)
  parameter DP2R2W_BE_0_NAME   = "0",
  parameter DP2R2W_BE_1_NAME   = "1",
  parameter DP2R2W_BE_2_NAME   = "2",
  parameter DP2R2W_BE_3_NAME   = "3",
  parameter DP2R2W_BE_4_NAME   = "4",
  parameter DP2R2W_BE_5_NAME   = "5",
  parameter DP2R2W_BE_6_NAME   = "6",
  parameter DP2R2W_BE_7_NAME   = "7",
  parameter DP2R2W_BE_8_NAME   = "8",
  parameter DP2R2W_BE_9_NAME   = "9",
  parameter DP2R2W_BE_10_NAME  = "10",
  parameter DP2R2W_BE_11_NAME  = "11",
  parameter DP2R2W_BE_12_NAME  = "12",
  parameter DP2R2W_BE_13_NAME  = "13",
  parameter DP2R2W_BE_14_NAME  = "14",
  parameter DP2R2W_BE_15_NAME  = "15",
  parameter DP2R2W_BE_16_NAME  = "16",
  parameter DP2R2W_BE_17_NAME  = "17",
  parameter DP2R2W_BE_18_NAME  = "18",
  parameter DP2R2W_BE_19_NAME  = "19",
  parameter DP2R2W_BE_20_NAME  = "20",
  parameter DP2R2W_BE_21_NAME  = "21",
  parameter DP2R2W_BE_22_NAME  = "22",
  parameter DP2R2W_BE_23_NAME  = "23",
  parameter DP2R2W_BE_24_NAME  = "24",
  parameter DP2R2W_BE_25_NAME  = "25",
  parameter DP2R2W_BE_26_NAME  = "26",
  parameter DP2R2W_BE_27_NAME  = "27",
  parameter DP2R2W_BE_28_NAME  = "28",
  parameter DP2R2W_BE_29_NAME  = "29",
  parameter DP2R2W_BE_30_NAME  = "30",
  parameter DP2R2W_BE_31_NAME  = "31",
  // DP2R2W_BE READ DELAY (number of clock cycles)
  parameter DP2R2W_BE_0_READ_DELAY  = 0,
  parameter DP2R2W_BE_1_READ_DELAY  = 0,
  parameter DP2R2W_BE_2_READ_DELAY  = 0,
  parameter DP2R2W_BE_3_READ_DELAY  = 0,
  parameter DP2R2W_BE_4_READ_DELAY  = 0,
  parameter DP2R2W_BE_5_READ_DELAY  = 0,
  parameter DP2R2W_BE_6_READ_DELAY  = 0,
  parameter DP2R2W_BE_7_READ_DELAY  = 0,
  parameter DP2R2W_BE_8_READ_DELAY  = 0,
  parameter DP2R2W_BE_9_READ_DELAY  = 0,
  parameter DP2R2W_BE_10_READ_DELAY = 0,
  parameter DP2R2W_BE_11_READ_DELAY = 0,
  parameter DP2R2W_BE_12_READ_DELAY = 0,
  parameter DP2R2W_BE_13_READ_DELAY = 0,
  parameter DP2R2W_BE_14_READ_DELAY = 0,
  parameter DP2R2W_BE_15_READ_DELAY = 0,
  parameter DP2R2W_BE_16_READ_DELAY = 0,
  parameter DP2R2W_BE_17_READ_DELAY = 0,
  parameter DP2R2W_BE_18_READ_DELAY = 0,
  parameter DP2R2W_BE_19_READ_DELAY = 0,
  parameter DP2R2W_BE_20_READ_DELAY = 0,
  parameter DP2R2W_BE_21_READ_DELAY = 0,
  parameter DP2R2W_BE_22_READ_DELAY = 0,
  parameter DP2R2W_BE_23_READ_DELAY = 0,
  parameter DP2R2W_BE_24_READ_DELAY = 0,
  parameter DP2R2W_BE_25_READ_DELAY = 0,
  parameter DP2R2W_BE_26_READ_DELAY = 0,
  parameter DP2R2W_BE_27_READ_DELAY = 0,
  parameter DP2R2W_BE_28_READ_DELAY = 0,
  parameter DP2R2W_BE_29_READ_DELAY = 0,
  parameter DP2R2W_BE_30_READ_DELAY = 0,
  parameter DP2R2W_BE_31_READ_DELAY = 0,
  // DP2R2W_BE ADDRESS WIDTH
  parameter DP2R2W_BE_0_ADDR_WD  = 1,
  parameter DP2R2W_BE_1_ADDR_WD  = 1,
  parameter DP2R2W_BE_2_ADDR_WD  = 1,
  parameter DP2R2W_BE_3_ADDR_WD  = 1,
  parameter DP2R2W_BE_4_ADDR_WD  = 1,
  parameter DP2R2W_BE_5_ADDR_WD  = 1,
  parameter DP2R2W_BE_6_ADDR_WD  = 1,
  parameter DP2R2W_BE_7_ADDR_WD  = 1,
  parameter DP2R2W_BE_8_ADDR_WD  = 1,
  parameter DP2R2W_BE_9_ADDR_WD  = 1,
  parameter DP2R2W_BE_10_ADDR_WD = 1,
  parameter DP2R2W_BE_11_ADDR_WD = 1,
  parameter DP2R2W_BE_12_ADDR_WD = 1,
  parameter DP2R2W_BE_13_ADDR_WD = 1,
  parameter DP2R2W_BE_14_ADDR_WD = 1,
  parameter DP2R2W_BE_15_ADDR_WD = 1,
  parameter DP2R2W_BE_16_ADDR_WD = 1,
  parameter DP2R2W_BE_17_ADDR_WD = 1,
  parameter DP2R2W_BE_18_ADDR_WD = 1,
  parameter DP2R2W_BE_19_ADDR_WD = 1,
  parameter DP2R2W_BE_20_ADDR_WD = 1,
  parameter DP2R2W_BE_21_ADDR_WD = 1,
  parameter DP2R2W_BE_22_ADDR_WD = 1,
  parameter DP2R2W_BE_23_ADDR_WD = 1,
  parameter DP2R2W_BE_24_ADDR_WD = 1,
  parameter DP2R2W_BE_25_ADDR_WD = 1,
  parameter DP2R2W_BE_26_ADDR_WD = 1,
  parameter DP2R2W_BE_27_ADDR_WD = 1,
  parameter DP2R2W_BE_28_ADDR_WD = 1,
  parameter DP2R2W_BE_29_ADDR_WD = 1,
  parameter DP2R2W_BE_30_ADDR_WD = 1,
  parameter DP2R2W_BE_31_ADDR_WD = 1,
  // DP2R2W_BE DATA WIDTH
  parameter DP2R2W_BE_0_DATA_WD  = 8,
  parameter DP2R2W_BE_1_DATA_WD  = 8,
  parameter DP2R2W_BE_2_DATA_WD  = 8,
  parameter DP2R2W_BE_3_DATA_WD  = 8,
  parameter DP2R2W_BE_4_DATA_WD  = 8,
  parameter DP2R2W_BE_5_DATA_WD  = 8,
  parameter DP2R2W_BE_6_DATA_WD  = 8,
  parameter DP2R2W_BE_7_DATA_WD  = 8,
  parameter DP2R2W_BE_8_DATA_WD  = 8,
  parameter DP2R2W_BE_9_DATA_WD  = 8,
  parameter DP2R2W_BE_10_DATA_WD = 8,
  parameter DP2R2W_BE_11_DATA_WD = 8,
  parameter DP2R2W_BE_12_DATA_WD = 8,
  parameter DP2R2W_BE_13_DATA_WD = 8,
  parameter DP2R2W_BE_14_DATA_WD = 8,
  parameter DP2R2W_BE_15_DATA_WD = 8,
  parameter DP2R2W_BE_16_DATA_WD = 8,
  parameter DP2R2W_BE_17_DATA_WD = 8,
  parameter DP2R2W_BE_18_DATA_WD = 8,
  parameter DP2R2W_BE_19_DATA_WD = 8,
  parameter DP2R2W_BE_20_DATA_WD = 8,
  parameter DP2R2W_BE_21_DATA_WD = 8,
  parameter DP2R2W_BE_22_DATA_WD = 8,
  parameter DP2R2W_BE_23_DATA_WD = 8,
  parameter DP2R2W_BE_24_DATA_WD = 8,
  parameter DP2R2W_BE_25_DATA_WD = 8,
  parameter DP2R2W_BE_26_DATA_WD = 8,
  parameter DP2R2W_BE_27_DATA_WD = 8,
  parameter DP2R2W_BE_28_DATA_WD = 8,
  parameter DP2R2W_BE_29_DATA_WD = 8,
  parameter DP2R2W_BE_30_DATA_WD = 8,
  parameter DP2R2W_BE_31_DATA_WD = 8,
  // DP2R2W_BE DEPTH of RAM
  parameter DP2R2W_BE_0_DEPTH  = (1<<DP2R2W_BE_0_ADDR_WD ),
  parameter DP2R2W_BE_1_DEPTH  = (1<<DP2R2W_BE_1_ADDR_WD ),
  parameter DP2R2W_BE_2_DEPTH  = (1<<DP2R2W_BE_2_ADDR_WD ),
  parameter DP2R2W_BE_3_DEPTH  = (1<<DP2R2W_BE_3_ADDR_WD ),
  parameter DP2R2W_BE_4_DEPTH  = (1<<DP2R2W_BE_4_ADDR_WD ),
  parameter DP2R2W_BE_5_DEPTH  = (1<<DP2R2W_BE_5_ADDR_WD ),
  parameter DP2R2W_BE_6_DEPTH  = (1<<DP2R2W_BE_6_ADDR_WD ),
  parameter DP2R2W_BE_7_DEPTH  = (1<<DP2R2W_BE_7_ADDR_WD ),
  parameter DP2R2W_BE_8_DEPTH  = (1<<DP2R2W_BE_8_ADDR_WD ),
  parameter DP2R2W_BE_9_DEPTH  = (1<<DP2R2W_BE_9_ADDR_WD ),
  parameter DP2R2W_BE_10_DEPTH = (1<<DP2R2W_BE_10_ADDR_WD),
  parameter DP2R2W_BE_11_DEPTH = (1<<DP2R2W_BE_11_ADDR_WD),
  parameter DP2R2W_BE_12_DEPTH = (1<<DP2R2W_BE_12_ADDR_WD),
  parameter DP2R2W_BE_13_DEPTH = (1<<DP2R2W_BE_13_ADDR_WD),
  parameter DP2R2W_BE_14_DEPTH = (1<<DP2R2W_BE_14_ADDR_WD),
  parameter DP2R2W_BE_15_DEPTH = (1<<DP2R2W_BE_15_ADDR_WD),
  parameter DP2R2W_BE_16_DEPTH = (1<<DP2R2W_BE_16_ADDR_WD),
  parameter DP2R2W_BE_17_DEPTH = (1<<DP2R2W_BE_17_ADDR_WD),
  parameter DP2R2W_BE_18_DEPTH = (1<<DP2R2W_BE_18_ADDR_WD),
  parameter DP2R2W_BE_19_DEPTH = (1<<DP2R2W_BE_19_ADDR_WD),
  parameter DP2R2W_BE_20_DEPTH = (1<<DP2R2W_BE_20_ADDR_WD),
  parameter DP2R2W_BE_21_DEPTH = (1<<DP2R2W_BE_21_ADDR_WD),
  parameter DP2R2W_BE_22_DEPTH = (1<<DP2R2W_BE_22_ADDR_WD),
  parameter DP2R2W_BE_23_DEPTH = (1<<DP2R2W_BE_23_ADDR_WD),
  parameter DP2R2W_BE_24_DEPTH = (1<<DP2R2W_BE_24_ADDR_WD),
  parameter DP2R2W_BE_25_DEPTH = (1<<DP2R2W_BE_25_ADDR_WD),
  parameter DP2R2W_BE_26_DEPTH = (1<<DP2R2W_BE_26_ADDR_WD),
  parameter DP2R2W_BE_27_DEPTH = (1<<DP2R2W_BE_27_ADDR_WD),
  parameter DP2R2W_BE_28_DEPTH = (1<<DP2R2W_BE_28_ADDR_WD),
  parameter DP2R2W_BE_29_DEPTH = (1<<DP2R2W_BE_29_ADDR_WD),
  parameter DP2R2W_BE_30_DEPTH = (1<<DP2R2W_BE_30_ADDR_WD),
  parameter DP2R2W_BE_31_DEPTH = (1<<DP2R2W_BE_31_ADDR_WD),
  // DP2R2W_BE HOLD DATA
  parameter DP2R2W_BE_0_HOLDDATA   = 0,
  parameter DP2R2W_BE_1_HOLDDATA   = 0,
  parameter DP2R2W_BE_2_HOLDDATA   = 0,
  parameter DP2R2W_BE_3_HOLDDATA   = 0,
  parameter DP2R2W_BE_4_HOLDDATA   = 0,
  parameter DP2R2W_BE_5_HOLDDATA   = 0,
  parameter DP2R2W_BE_6_HOLDDATA   = 0,
  parameter DP2R2W_BE_7_HOLDDATA   = 0,
  parameter DP2R2W_BE_8_HOLDDATA   = 0,
  parameter DP2R2W_BE_9_HOLDDATA   = 0,
  parameter DP2R2W_BE_10_HOLDDATA  = 0,
  parameter DP2R2W_BE_11_HOLDDATA  = 0,
  parameter DP2R2W_BE_12_HOLDDATA  = 0,
  parameter DP2R2W_BE_13_HOLDDATA  = 0,
  parameter DP2R2W_BE_14_HOLDDATA  = 0,
  parameter DP2R2W_BE_15_HOLDDATA  = 0,
  parameter DP2R2W_BE_16_HOLDDATA  = 0,
  parameter DP2R2W_BE_17_HOLDDATA  = 0,
  parameter DP2R2W_BE_18_HOLDDATA  = 0,
  parameter DP2R2W_BE_19_HOLDDATA  = 0,
  parameter DP2R2W_BE_20_HOLDDATA  = 0,
  parameter DP2R2W_BE_21_HOLDDATA  = 0,
  parameter DP2R2W_BE_22_HOLDDATA  = 0,
  parameter DP2R2W_BE_23_HOLDDATA  = 0,
  parameter DP2R2W_BE_24_HOLDDATA  = 0,
  parameter DP2R2W_BE_25_HOLDDATA  = 0,
  parameter DP2R2W_BE_26_HOLDDATA  = 0,
  parameter DP2R2W_BE_27_HOLDDATA  = 0,
  parameter DP2R2W_BE_28_HOLDDATA  = 0,
  parameter DP2R2W_BE_29_HOLDDATA  = 0,
  parameter DP2R2W_BE_30_HOLDDATA  = 0,
  parameter DP2R2W_BE_31_HOLDDATA  = 0,

  // RF_BE NAME (STRING)
  parameter RF_BE_0_NAME   = "0",
  parameter RF_BE_1_NAME   = "1",
  parameter RF_BE_2_NAME   = "2",
  parameter RF_BE_3_NAME   = "3",
  parameter RF_BE_4_NAME   = "4",
  parameter RF_BE_5_NAME   = "5",
  parameter RF_BE_6_NAME   = "6",
  parameter RF_BE_7_NAME   = "7",
  parameter RF_BE_8_NAME   = "8",
  parameter RF_BE_9_NAME   = "9",
  parameter RF_BE_10_NAME  = "10",
  parameter RF_BE_11_NAME  = "11",
  parameter RF_BE_12_NAME  = "12",
  parameter RF_BE_13_NAME  = "13",
  parameter RF_BE_14_NAME  = "14",
  parameter RF_BE_15_NAME  = "15",
  parameter RF_BE_16_NAME  = "16",
  parameter RF_BE_17_NAME  = "17",
  parameter RF_BE_18_NAME  = "18",
  parameter RF_BE_19_NAME  = "19",
  parameter RF_BE_20_NAME  = "20",
  parameter RF_BE_21_NAME  = "21",
  parameter RF_BE_22_NAME  = "22",
  parameter RF_BE_23_NAME  = "23",
  parameter RF_BE_24_NAME  = "24",
  parameter RF_BE_25_NAME  = "25",
  parameter RF_BE_26_NAME  = "26",
  parameter RF_BE_27_NAME  = "27",
  parameter RF_BE_28_NAME  = "28",
  parameter RF_BE_29_NAME  = "29",
  parameter RF_BE_30_NAME  = "30",
  parameter RF_BE_31_NAME  = "31",
  // RF_BE READ DELAY (number of clock cycles)
  parameter RF_BE_0_READ_DELAY  = 0,
  parameter RF_BE_1_READ_DELAY  = 0,
  parameter RF_BE_2_READ_DELAY  = 0,
  parameter RF_BE_3_READ_DELAY  = 0,
  parameter RF_BE_4_READ_DELAY  = 0,
  parameter RF_BE_5_READ_DELAY  = 0,
  parameter RF_BE_6_READ_DELAY  = 0,
  parameter RF_BE_7_READ_DELAY  = 0,
  parameter RF_BE_8_READ_DELAY  = 0,
  parameter RF_BE_9_READ_DELAY  = 0,
  parameter RF_BE_10_READ_DELAY = 0,
  parameter RF_BE_11_READ_DELAY = 0,
  parameter RF_BE_12_READ_DELAY = 0,
  parameter RF_BE_13_READ_DELAY = 0,
  parameter RF_BE_14_READ_DELAY = 0,
  parameter RF_BE_15_READ_DELAY = 0,
  parameter RF_BE_16_READ_DELAY = 0,
  parameter RF_BE_17_READ_DELAY = 0,
  parameter RF_BE_18_READ_DELAY = 0,
  parameter RF_BE_19_READ_DELAY = 0,
  parameter RF_BE_20_READ_DELAY = 0,
  parameter RF_BE_21_READ_DELAY = 0,
  parameter RF_BE_22_READ_DELAY = 0,
  parameter RF_BE_23_READ_DELAY = 0,
  parameter RF_BE_24_READ_DELAY = 0,
  parameter RF_BE_25_READ_DELAY = 0,
  parameter RF_BE_26_READ_DELAY = 0,
  parameter RF_BE_27_READ_DELAY = 0,
  parameter RF_BE_28_READ_DELAY = 0,
  parameter RF_BE_29_READ_DELAY = 0,
  parameter RF_BE_30_READ_DELAY = 0,
  parameter RF_BE_31_READ_DELAY = 0,
  // RF_BE ADDRESS WIDTH
  parameter RF_BE_0_ADDR_WD   = 1,
  parameter RF_BE_1_ADDR_WD   = 1,
  parameter RF_BE_2_ADDR_WD   = 1,
  parameter RF_BE_3_ADDR_WD   = 1,
  parameter RF_BE_4_ADDR_WD   = 1,
  parameter RF_BE_5_ADDR_WD   = 1,
  parameter RF_BE_6_ADDR_WD   = 1,
  parameter RF_BE_7_ADDR_WD   = 1,
  parameter RF_BE_8_ADDR_WD   = 1,
  parameter RF_BE_9_ADDR_WD   = 1,
  parameter RF_BE_10_ADDR_WD  = 1,
  parameter RF_BE_11_ADDR_WD  = 1,
  parameter RF_BE_12_ADDR_WD  = 1,
  parameter RF_BE_13_ADDR_WD  = 1,
  parameter RF_BE_14_ADDR_WD  = 1,
  parameter RF_BE_15_ADDR_WD  = 1,
  parameter RF_BE_16_ADDR_WD  = 1,
  parameter RF_BE_17_ADDR_WD  = 1,
  parameter RF_BE_18_ADDR_WD  = 1,
  parameter RF_BE_19_ADDR_WD  = 1,
  parameter RF_BE_20_ADDR_WD  = 1,
  parameter RF_BE_21_ADDR_WD  = 1,
  parameter RF_BE_22_ADDR_WD  = 1,
  parameter RF_BE_23_ADDR_WD  = 1,
  parameter RF_BE_24_ADDR_WD  = 1,
  parameter RF_BE_25_ADDR_WD  = 1,
  parameter RF_BE_26_ADDR_WD  = 1,
  parameter RF_BE_27_ADDR_WD  = 1,
  parameter RF_BE_28_ADDR_WD  = 1,
  parameter RF_BE_29_ADDR_WD  = 1,
  parameter RF_BE_30_ADDR_WD  = 1,
  parameter RF_BE_31_ADDR_WD  = 1,
  // RF_BE DATA WIDTH
  parameter RF_BE_0_DATA_WD   = 8,
  parameter RF_BE_1_DATA_WD   = 8,
  parameter RF_BE_2_DATA_WD   = 8,
  parameter RF_BE_3_DATA_WD   = 8,
  parameter RF_BE_4_DATA_WD   = 8,
  parameter RF_BE_5_DATA_WD   = 8,
  parameter RF_BE_6_DATA_WD   = 8,
  parameter RF_BE_7_DATA_WD   = 8,
  parameter RF_BE_8_DATA_WD   = 8,
  parameter RF_BE_9_DATA_WD   = 8,
  parameter RF_BE_10_DATA_WD  = 8,
  parameter RF_BE_11_DATA_WD  = 8,
  parameter RF_BE_12_DATA_WD  = 8,
  parameter RF_BE_13_DATA_WD  = 8,
  parameter RF_BE_14_DATA_WD  = 8,
  parameter RF_BE_15_DATA_WD  = 8,
  parameter RF_BE_16_DATA_WD  = 8,
  parameter RF_BE_17_DATA_WD  = 8,
  parameter RF_BE_18_DATA_WD  = 8,
  parameter RF_BE_19_DATA_WD  = 8,
  parameter RF_BE_20_DATA_WD  = 8,
  parameter RF_BE_21_DATA_WD  = 8,
  parameter RF_BE_22_DATA_WD  = 8,
  parameter RF_BE_23_DATA_WD  = 8,
  parameter RF_BE_24_DATA_WD  = 8,
  parameter RF_BE_25_DATA_WD  = 8,
  parameter RF_BE_26_DATA_WD  = 8,
  parameter RF_BE_27_DATA_WD  = 8,
  parameter RF_BE_28_DATA_WD  = 8,
  parameter RF_BE_29_DATA_WD  = 8,
  parameter RF_BE_30_DATA_WD  = 8,
  parameter RF_BE_31_DATA_WD  = 8,
  // RF_BE DEPTH of RAM
  parameter RF_BE_0_DEPTH  = (1<<RF_BE_0_ADDR_WD ),
  parameter RF_BE_1_DEPTH  = (1<<RF_BE_1_ADDR_WD ),
  parameter RF_BE_2_DEPTH  = (1<<RF_BE_2_ADDR_WD ),
  parameter RF_BE_3_DEPTH  = (1<<RF_BE_3_ADDR_WD ),
  parameter RF_BE_4_DEPTH  = (1<<RF_BE_4_ADDR_WD ),
  parameter RF_BE_5_DEPTH  = (1<<RF_BE_5_ADDR_WD ),
  parameter RF_BE_6_DEPTH  = (1<<RF_BE_6_ADDR_WD ),
  parameter RF_BE_7_DEPTH  = (1<<RF_BE_7_ADDR_WD ),
  parameter RF_BE_8_DEPTH  = (1<<RF_BE_8_ADDR_WD ),
  parameter RF_BE_9_DEPTH  = (1<<RF_BE_9_ADDR_WD ),
  parameter RF_BE_10_DEPTH = (1<<RF_BE_10_ADDR_WD),
  parameter RF_BE_11_DEPTH = (1<<RF_BE_11_ADDR_WD),
  parameter RF_BE_12_DEPTH = (1<<RF_BE_12_ADDR_WD),
  parameter RF_BE_13_DEPTH = (1<<RF_BE_13_ADDR_WD),
  parameter RF_BE_14_DEPTH = (1<<RF_BE_14_ADDR_WD),
  parameter RF_BE_15_DEPTH = (1<<RF_BE_15_ADDR_WD),
  parameter RF_BE_16_DEPTH = (1<<RF_BE_16_ADDR_WD),
  parameter RF_BE_17_DEPTH = (1<<RF_BE_17_ADDR_WD),
  parameter RF_BE_18_DEPTH = (1<<RF_BE_18_ADDR_WD),
  parameter RF_BE_19_DEPTH = (1<<RF_BE_19_ADDR_WD),
  parameter RF_BE_20_DEPTH = (1<<RF_BE_20_ADDR_WD),
  parameter RF_BE_21_DEPTH = (1<<RF_BE_21_ADDR_WD),
  parameter RF_BE_22_DEPTH = (1<<RF_BE_22_ADDR_WD),
  parameter RF_BE_23_DEPTH = (1<<RF_BE_23_ADDR_WD),
  parameter RF_BE_24_DEPTH = (1<<RF_BE_24_ADDR_WD),
  parameter RF_BE_25_DEPTH = (1<<RF_BE_25_ADDR_WD),
  parameter RF_BE_26_DEPTH = (1<<RF_BE_26_ADDR_WD),
  parameter RF_BE_27_DEPTH = (1<<RF_BE_27_ADDR_WD),
  parameter RF_BE_28_DEPTH = (1<<RF_BE_28_ADDR_WD),
  parameter RF_BE_29_DEPTH = (1<<RF_BE_29_ADDR_WD),
  parameter RF_BE_30_DEPTH = (1<<RF_BE_30_ADDR_WD),
  parameter RF_BE_31_DEPTH = (1<<RF_BE_31_ADDR_WD),
  // RF_BE HOLD DATA
  parameter RF_BE_0_HOLDDATA   = 0,
  parameter RF_BE_1_HOLDDATA   = 0,
  parameter RF_BE_2_HOLDDATA   = 0,
  parameter RF_BE_3_HOLDDATA   = 0,
  parameter RF_BE_4_HOLDDATA   = 0,
  parameter RF_BE_5_HOLDDATA   = 0,
  parameter RF_BE_6_HOLDDATA   = 0,
  parameter RF_BE_7_HOLDDATA   = 0,
  parameter RF_BE_8_HOLDDATA   = 0,
  parameter RF_BE_9_HOLDDATA   = 0,
  parameter RF_BE_10_HOLDDATA  = 0,
  parameter RF_BE_11_HOLDDATA  = 0,
  parameter RF_BE_12_HOLDDATA  = 0,
  parameter RF_BE_13_HOLDDATA  = 0,
  parameter RF_BE_14_HOLDDATA  = 0,
  parameter RF_BE_15_HOLDDATA  = 0,
  parameter RF_BE_16_HOLDDATA  = 0,
  parameter RF_BE_17_HOLDDATA  = 0,
  parameter RF_BE_18_HOLDDATA  = 0,
  parameter RF_BE_19_HOLDDATA  = 0,
  parameter RF_BE_20_HOLDDATA  = 0,
  parameter RF_BE_21_HOLDDATA  = 0,
  parameter RF_BE_22_HOLDDATA  = 0,
  parameter RF_BE_23_HOLDDATA  = 0,
  parameter RF_BE_24_HOLDDATA  = 0,
  parameter RF_BE_25_HOLDDATA  = 0,
  parameter RF_BE_26_HOLDDATA  = 0,
  parameter RF_BE_27_HOLDDATA  = 0,
  parameter RF_BE_28_HOLDDATA  = 0,
  parameter RF_BE_29_HOLDDATA  = 0,
  parameter RF_BE_30_HOLDDATA  = 0,
  parameter RF_BE_31_HOLDDATA  = 0
 ) (

  // APB bank
  input                     pclk,
  input                     presetn,
  input  [APB_PADDR_WD-1:0] paddr,
  output reg                pready,
  input              [31:0] pwdata,
  output reg         [31:0] prdata,
  input                     pwrite,
  input                     penable,
  input                     psel,
  input               [3:0] pstrb,
  output                    pslverr,
  input  [APB_PPROT_WD-1:0] pprot,

  output                    interrupt,

  //**********
  // RAM IFs
  //**********

  //--------------------------------------
  // SRAM
  //--------------------------------------
  //sram0
  input                             sram0_clk,
  output reg    [SRAM0_ADDR_WD-1:0] sram0_addr,
  output reg    [SRAM0_DATA_WD-1:0] sram0_din,
  input         [SRAM0_DATA_WD-1:0] sram0_dout,
  output reg                        sram0_en,
  output reg                        sram0_we,
  //sram1
  input                             sram1_clk,
  output reg    [SRAM1_ADDR_WD-1:0] sram1_addr,
  output reg    [SRAM1_DATA_WD-1:0] sram1_din,
  input         [SRAM1_DATA_WD-1:0] sram1_dout,
  output reg                        sram1_en,
  output reg                        sram1_we,
  //sram2
  input                             sram2_clk,
  output reg    [SRAM2_ADDR_WD-1:0] sram2_addr,
  output reg    [SRAM2_DATA_WD-1:0] sram2_din,
  input         [SRAM2_DATA_WD-1:0] sram2_dout,
  output reg                        sram2_en,
  output reg                        sram2_we,
  //sram3
  input                             sram3_clk,
  output reg    [SRAM3_ADDR_WD-1:0] sram3_addr,
  output reg    [SRAM3_DATA_WD-1:0] sram3_din,
  input         [SRAM3_DATA_WD-1:0] sram3_dout,
  output reg                        sram3_en,
  output reg                        sram3_we,
  //sram4
  input                             sram4_clk,
  output reg    [SRAM4_ADDR_WD-1:0] sram4_addr,
  output reg    [SRAM4_DATA_WD-1:0] sram4_din,
  input         [SRAM4_DATA_WD-1:0] sram4_dout,
  output reg                        sram4_en,
  output reg                        sram4_we,
  //sram5
  input                             sram5_clk,
  output reg    [SRAM5_ADDR_WD-1:0] sram5_addr,
  output reg    [SRAM5_DATA_WD-1:0] sram5_din,
  input         [SRAM5_DATA_WD-1:0] sram5_dout,
  output reg                        sram5_en,
  output reg                        sram5_we,
  //sram6
  input                             sram6_clk,
  output reg    [SRAM6_ADDR_WD-1:0] sram6_addr,
  output reg    [SRAM6_DATA_WD-1:0] sram6_din,
  input         [SRAM6_DATA_WD-1:0] sram6_dout,
  output reg                        sram6_en,
  output reg                        sram6_we,
  //sram7
  input                             sram7_clk,
  output reg    [SRAM7_ADDR_WD-1:0] sram7_addr,
  output reg    [SRAM7_DATA_WD-1:0] sram7_din,
  input         [SRAM7_DATA_WD-1:0] sram7_dout,
  output reg                        sram7_en,
  output reg                        sram7_we,
  //sram8
  input                             sram8_clk,
  output reg    [SRAM8_ADDR_WD-1:0] sram8_addr,
  output reg    [SRAM8_DATA_WD-1:0] sram8_din,
  input         [SRAM8_DATA_WD-1:0] sram8_dout,
  output reg                        sram8_en,
  output reg                        sram8_we,
  //sram9
  input                             sram9_clk,
  output reg    [SRAM9_ADDR_WD-1:0] sram9_addr,
  output reg    [SRAM9_DATA_WD-1:0] sram9_din,
  input         [SRAM9_DATA_WD-1:0] sram9_dout,
  output reg                        sram9_en,
  output reg                        sram9_we,
  //sram10
  input                             sram10_clk,
  output reg   [SRAM10_ADDR_WD-1:0] sram10_addr,
  output reg   [SRAM10_DATA_WD-1:0] sram10_din,
  input        [SRAM10_DATA_WD-1:0] sram10_dout,
  output reg                        sram10_en,
  output reg                        sram10_we,
  //sram11
  input                             sram11_clk,
  output reg   [SRAM11_ADDR_WD-1:0] sram11_addr,
  output reg   [SRAM11_DATA_WD-1:0] sram11_din,
  input        [SRAM11_DATA_WD-1:0] sram11_dout,
  output reg                        sram11_en,
  output reg                        sram11_we,
  //sram12
  input                             sram12_clk,
  output reg   [SRAM12_ADDR_WD-1:0] sram12_addr,
  output reg   [SRAM12_DATA_WD-1:0] sram12_din,
  input        [SRAM12_DATA_WD-1:0] sram12_dout,
  output reg                        sram12_en,
  output reg                        sram12_we,
  //sram13
  input                             sram13_clk,
  output reg   [SRAM13_ADDR_WD-1:0] sram13_addr,
  output reg   [SRAM13_DATA_WD-1:0] sram13_din,
  input        [SRAM13_DATA_WD-1:0] sram13_dout,
  output reg                        sram13_en,
  output reg                        sram13_we,
  //sram14
  input                             sram14_clk,
  output reg   [SRAM14_ADDR_WD-1:0] sram14_addr,
  output reg   [SRAM14_DATA_WD-1:0] sram14_din,
  input        [SRAM14_DATA_WD-1:0] sram14_dout,
  output reg                        sram14_en,
  output reg                        sram14_we,
  //sram15
  input                             sram15_clk,
  output reg   [SRAM15_ADDR_WD-1:0] sram15_addr,
  output reg   [SRAM15_DATA_WD-1:0] sram15_din,
  input        [SRAM15_DATA_WD-1:0] sram15_dout,
  output reg                        sram15_en,
  output reg                        sram15_we,
  //sram16
  input                             sram16_clk,
  output reg   [SRAM16_ADDR_WD-1:0] sram16_addr,
  output reg   [SRAM16_DATA_WD-1:0] sram16_din,
  input        [SRAM16_DATA_WD-1:0] sram16_dout,
  output reg                        sram16_en,
  output reg                        sram16_we,
  //sram17
  input                             sram17_clk,
  output reg   [SRAM17_ADDR_WD-1:0] sram17_addr,
  output reg   [SRAM17_DATA_WD-1:0] sram17_din,
  input        [SRAM17_DATA_WD-1:0] sram17_dout,
  output reg                        sram17_en,
  output reg                        sram17_we,
  //sram18
  input                             sram18_clk,
  output reg   [SRAM18_ADDR_WD-1:0] sram18_addr,
  output reg   [SRAM18_DATA_WD-1:0] sram18_din,
  input        [SRAM18_DATA_WD-1:0] sram18_dout,
  output reg                        sram18_en,
  output reg                        sram18_we,
  //sram19
  input                             sram19_clk,
  output reg   [SRAM19_ADDR_WD-1:0] sram19_addr,
  output reg   [SRAM19_DATA_WD-1:0] sram19_din,
  input        [SRAM19_DATA_WD-1:0] sram19_dout,
  output reg                        sram19_en,
  output reg                        sram19_we,
  //sram20
  input                             sram20_clk,
  output reg   [SRAM20_ADDR_WD-1:0] sram20_addr,
  output reg   [SRAM20_DATA_WD-1:0] sram20_din,
  input        [SRAM20_DATA_WD-1:0] sram20_dout,
  output reg                        sram20_en,
  output reg                        sram20_we,
  //sram21
  input                             sram21_clk,
  output reg   [SRAM21_ADDR_WD-1:0] sram21_addr,
  output reg   [SRAM21_DATA_WD-1:0] sram21_din,
  input        [SRAM21_DATA_WD-1:0] sram21_dout,
  output reg                        sram21_en,
  output reg                        sram21_we,
  //sram22
  input                             sram22_clk,
  output reg   [SRAM22_ADDR_WD-1:0] sram22_addr,
  output reg   [SRAM22_DATA_WD-1:0] sram22_din,
  input        [SRAM22_DATA_WD-1:0] sram22_dout,
  output reg                        sram22_en,
  output reg                        sram22_we,
  //sram23
  input                             sram23_clk,
  output reg   [SRAM23_ADDR_WD-1:0] sram23_addr,
  output reg   [SRAM23_DATA_WD-1:0] sram23_din,
  input        [SRAM23_DATA_WD-1:0] sram23_dout,
  output reg                        sram23_en,
  output reg                        sram23_we,
  //sram24
  input                             sram24_clk,
  output reg   [SRAM24_ADDR_WD-1:0] sram24_addr,
  output reg   [SRAM24_DATA_WD-1:0] sram24_din,
  input        [SRAM24_DATA_WD-1:0] sram24_dout,
  output reg                        sram24_en,
  output reg                        sram24_we,
  //sram25
  input                             sram25_clk,
  output reg   [SRAM25_ADDR_WD-1:0] sram25_addr,
  output reg   [SRAM25_DATA_WD-1:0] sram25_din,
  input        [SRAM25_DATA_WD-1:0] sram25_dout,
  output reg                        sram25_en,
  output reg                        sram25_we,
  //sram26
  input                             sram26_clk,
  output reg   [SRAM26_ADDR_WD-1:0] sram26_addr,
  output reg   [SRAM26_DATA_WD-1:0] sram26_din,
  input        [SRAM26_DATA_WD-1:0] sram26_dout,
  output reg                        sram26_en,
  output reg                        sram26_we,
  //sram27
  input                             sram27_clk,
  output reg   [SRAM27_ADDR_WD-1:0] sram27_addr,
  output reg   [SRAM27_DATA_WD-1:0] sram27_din,
  input        [SRAM27_DATA_WD-1:0] sram27_dout,
  output reg                        sram27_en,
  output reg                        sram27_we,
  //sram28
  input                             sram28_clk,
  output reg   [SRAM28_ADDR_WD-1:0] sram28_addr,
  output reg   [SRAM28_DATA_WD-1:0] sram28_din,
  input        [SRAM28_DATA_WD-1:0] sram28_dout,
  output reg                        sram28_en,
  output reg                        sram28_we,
  //sram29
  input                             sram29_clk,
  output reg   [SRAM29_ADDR_WD-1:0] sram29_addr,
  output reg   [SRAM29_DATA_WD-1:0] sram29_din,
  input        [SRAM29_DATA_WD-1:0] sram29_dout,
  output reg                        sram29_en,
  output reg                        sram29_we,
  //sram30
  input                             sram30_clk,
  output reg   [SRAM30_ADDR_WD-1:0] sram30_addr,
  output reg   [SRAM30_DATA_WD-1:0] sram30_din,
  input        [SRAM30_DATA_WD-1:0] sram30_dout,
  output reg                        sram30_en,
  output reg                        sram30_we,
  //sram31
  input                             sram31_clk,
  output reg   [SRAM31_ADDR_WD-1:0] sram31_addr,
  output reg   [SRAM31_DATA_WD-1:0] sram31_din,
  input        [SRAM31_DATA_WD-1:0] sram31_dout,
  output reg                        sram31_en,
  output reg                        sram31_we,

  //--------------------------------------
  // DP1R1W
  //--------------------------------------
  //dp1r1w0
  input                             dp1r1w0_clka,
  input                             dp1r1w0_clkb,
  output reg  [DP1R1W0_ADDR_WD-1:0] dp1r1w0_addra,
  output reg  [DP1R1W0_ADDR_WD-1:0] dp1r1w0_addrb,
  output reg  [DP1R1W0_DATA_WD-1:0] dp1r1w0_dina,
  input       [DP1R1W0_DATA_WD-1:0] dp1r1w0_doutb,
  output reg                        dp1r1w0_ena,
  output reg                        dp1r1w0_enb,
  output reg                        dp1r1w0_wea,
  //dp1r1w1
  input                             dp1r1w1_clka,
  input                             dp1r1w1_clkb,
  output reg  [DP1R1W1_ADDR_WD-1:0] dp1r1w1_addra,
  output reg  [DP1R1W1_ADDR_WD-1:0] dp1r1w1_addrb,
  output reg  [DP1R1W1_DATA_WD-1:0] dp1r1w1_dina,
  input       [DP1R1W1_DATA_WD-1:0] dp1r1w1_doutb,
  output reg                        dp1r1w1_ena,
  output reg                        dp1r1w1_enb,
  output reg                        dp1r1w1_wea,
  //dp1r1w2
  input                             dp1r1w2_clka,
  input                             dp1r1w2_clkb,
  output reg  [DP1R1W2_ADDR_WD-1:0] dp1r1w2_addra,
  output reg  [DP1R1W2_ADDR_WD-1:0] dp1r1w2_addrb,
  output reg  [DP1R1W2_DATA_WD-1:0] dp1r1w2_dina,
  input       [DP1R1W2_DATA_WD-1:0] dp1r1w2_doutb,
  output reg                        dp1r1w2_ena,
  output reg                        dp1r1w2_enb,
  output reg                        dp1r1w2_wea,
  //dp1r1w3
  input                             dp1r1w3_clka,
  input                             dp1r1w3_clkb,
  output reg  [DP1R1W3_ADDR_WD-1:0] dp1r1w3_addra,
  output reg  [DP1R1W3_ADDR_WD-1:0] dp1r1w3_addrb,
  output reg  [DP1R1W3_DATA_WD-1:0] dp1r1w3_dina,
  input       [DP1R1W3_DATA_WD-1:0] dp1r1w3_doutb,
  output reg                        dp1r1w3_ena,
  output reg                        dp1r1w3_enb,
  output reg                        dp1r1w3_wea,
  //dp1r1w4
  input                             dp1r1w4_clka,
  input                             dp1r1w4_clkb,
  output reg  [DP1R1W4_ADDR_WD-1:0] dp1r1w4_addra,
  output reg  [DP1R1W4_ADDR_WD-1:0] dp1r1w4_addrb,
  output reg  [DP1R1W4_DATA_WD-1:0] dp1r1w4_dina,
  input       [DP1R1W4_DATA_WD-1:0] dp1r1w4_doutb,
  output reg                        dp1r1w4_ena,
  output reg                        dp1r1w4_enb,
  output reg                        dp1r1w4_wea,
  //dp1r1w5
  input                             dp1r1w5_clka,
  input                             dp1r1w5_clkb,
  output reg  [DP1R1W5_ADDR_WD-1:0] dp1r1w5_addra,
  output reg  [DP1R1W5_ADDR_WD-1:0] dp1r1w5_addrb,
  output reg  [DP1R1W5_DATA_WD-1:0] dp1r1w5_dina,
  input       [DP1R1W5_DATA_WD-1:0] dp1r1w5_doutb,
  output reg                        dp1r1w5_ena,
  output reg                        dp1r1w5_enb,
  output reg                        dp1r1w5_wea,
  //dp1r1w6
  input                             dp1r1w6_clka,
  input                             dp1r1w6_clkb,
  output reg  [DP1R1W6_ADDR_WD-1:0] dp1r1w6_addra,
  output reg  [DP1R1W6_ADDR_WD-1:0] dp1r1w6_addrb,
  output reg  [DP1R1W6_DATA_WD-1:0] dp1r1w6_dina,
  input       [DP1R1W6_DATA_WD-1:0] dp1r1w6_doutb,
  output reg                        dp1r1w6_ena,
  output reg                        dp1r1w6_enb,
  output reg                        dp1r1w6_wea,
  //dp1r1w7
  input                             dp1r1w7_clka,
  input                             dp1r1w7_clkb,
  output reg  [DP1R1W7_ADDR_WD-1:0] dp1r1w7_addra,
  output reg  [DP1R1W7_ADDR_WD-1:0] dp1r1w7_addrb,
  output reg  [DP1R1W7_DATA_WD-1:0] dp1r1w7_dina,
  input       [DP1R1W7_DATA_WD-1:0] dp1r1w7_doutb,
  output reg                        dp1r1w7_ena,
  output reg                        dp1r1w7_enb,
  output reg                        dp1r1w7_wea,
  //dp1r1w8
  input                             dp1r1w8_clka,
  input                             dp1r1w8_clkb,
  output reg  [DP1R1W8_ADDR_WD-1:0] dp1r1w8_addra,
  output reg  [DP1R1W8_ADDR_WD-1:0] dp1r1w8_addrb,
  output reg  [DP1R1W8_DATA_WD-1:0] dp1r1w8_dina,
  input       [DP1R1W8_DATA_WD-1:0] dp1r1w8_doutb,
  output reg                        dp1r1w8_ena,
  output reg                        dp1r1w8_enb,
  output reg                        dp1r1w8_wea,
  //dp1r1w9
  input                             dp1r1w9_clka,
  input                             dp1r1w9_clkb,
  output reg  [DP1R1W9_ADDR_WD-1:0] dp1r1w9_addra,
  output reg  [DP1R1W9_ADDR_WD-1:0] dp1r1w9_addrb,
  output reg  [DP1R1W9_DATA_WD-1:0] dp1r1w9_dina,
  input       [DP1R1W9_DATA_WD-1:0] dp1r1w9_doutb,
  output reg                        dp1r1w9_ena,
  output reg                        dp1r1w9_enb,
  output reg                        dp1r1w9_wea,
  //dp1r1w10
  input                             dp1r1w10_clka,
  input                             dp1r1w10_clkb,
  output reg [DP1R1W10_ADDR_WD-1:0] dp1r1w10_addra,
  output reg [DP1R1W10_ADDR_WD-1:0] dp1r1w10_addrb,
  output reg [DP1R1W10_DATA_WD-1:0] dp1r1w10_dina,
  input      [DP1R1W10_DATA_WD-1:0] dp1r1w10_doutb,
  output reg                        dp1r1w10_ena,
  output reg                        dp1r1w10_enb,
  output reg                        dp1r1w10_wea,
  //dp1r1w11
  input                             dp1r1w11_clka,
  input                             dp1r1w11_clkb,
  output reg [DP1R1W11_ADDR_WD-1:0] dp1r1w11_addra,
  output reg [DP1R1W11_ADDR_WD-1:0] dp1r1w11_addrb,
  output reg [DP1R1W11_DATA_WD-1:0] dp1r1w11_dina,
  input      [DP1R1W11_DATA_WD-1:0] dp1r1w11_doutb,
  output reg                        dp1r1w11_ena,
  output reg                        dp1r1w11_enb,
  output reg                        dp1r1w11_wea,
  //dp1r1w12
  input                             dp1r1w12_clka,
  input                             dp1r1w12_clkb,
  output reg [DP1R1W12_ADDR_WD-1:0] dp1r1w12_addra,
  output reg [DP1R1W12_ADDR_WD-1:0] dp1r1w12_addrb,
  output reg [DP1R1W12_DATA_WD-1:0] dp1r1w12_dina,
  input      [DP1R1W12_DATA_WD-1:0] dp1r1w12_doutb,
  output reg                        dp1r1w12_ena,
  output reg                        dp1r1w12_enb,
  output reg                        dp1r1w12_wea,
  //dp1r1w13
  input                             dp1r1w13_clka,
  input                             dp1r1w13_clkb,
  output reg [DP1R1W13_ADDR_WD-1:0] dp1r1w13_addra,
  output reg [DP1R1W13_ADDR_WD-1:0] dp1r1w13_addrb,
  output reg [DP1R1W13_DATA_WD-1:0] dp1r1w13_dina,
  input      [DP1R1W13_DATA_WD-1:0] dp1r1w13_doutb,
  output reg                        dp1r1w13_ena,
  output reg                        dp1r1w13_enb,
  output reg                        dp1r1w13_wea,
  //dp1r1w14
  input                             dp1r1w14_clka,
  input                             dp1r1w14_clkb,
  output reg [DP1R1W14_ADDR_WD-1:0] dp1r1w14_addra,
  output reg [DP1R1W14_ADDR_WD-1:0] dp1r1w14_addrb,
  output reg [DP1R1W14_DATA_WD-1:0] dp1r1w14_dina,
  input      [DP1R1W14_DATA_WD-1:0] dp1r1w14_doutb,
  output reg                        dp1r1w14_ena,
  output reg                        dp1r1w14_enb,
  output reg                        dp1r1w14_wea,
  //dp1r1w15
  input                             dp1r1w15_clka,
  input                             dp1r1w15_clkb,
  output reg [DP1R1W15_ADDR_WD-1:0] dp1r1w15_addra,
  output reg [DP1R1W15_ADDR_WD-1:0] dp1r1w15_addrb,
  output reg [DP1R1W15_DATA_WD-1:0] dp1r1w15_dina,
  input      [DP1R1W15_DATA_WD-1:0] dp1r1w15_doutb,
  output reg                        dp1r1w15_ena,
  output reg                        dp1r1w15_enb,
  output reg                        dp1r1w15_wea,
  //dp1r1w16
  input                             dp1r1w16_clka,
  input                             dp1r1w16_clkb,
  output reg [DP1R1W16_ADDR_WD-1:0] dp1r1w16_addra,
  output reg [DP1R1W16_ADDR_WD-1:0] dp1r1w16_addrb,
  output reg [DP1R1W16_DATA_WD-1:0] dp1r1w16_dina,
  input      [DP1R1W16_DATA_WD-1:0] dp1r1w16_doutb,
  output reg                        dp1r1w16_ena,
  output reg                        dp1r1w16_enb,
  output reg                        dp1r1w16_wea,
  //dp1r1w17
  input                             dp1r1w17_clka,
  input                             dp1r1w17_clkb,
  output reg [DP1R1W17_ADDR_WD-1:0] dp1r1w17_addra,
  output reg [DP1R1W17_ADDR_WD-1:0] dp1r1w17_addrb,
  output reg [DP1R1W17_DATA_WD-1:0] dp1r1w17_dina,
  input      [DP1R1W17_DATA_WD-1:0] dp1r1w17_doutb,
  output reg                        dp1r1w17_ena,
  output reg                        dp1r1w17_enb,
  output reg                        dp1r1w17_wea,
  //dp1r1w18
  input                             dp1r1w18_clka,
  input                             dp1r1w18_clkb,
  output reg [DP1R1W18_ADDR_WD-1:0] dp1r1w18_addra,
  output reg [DP1R1W18_ADDR_WD-1:0] dp1r1w18_addrb,
  output reg [DP1R1W18_DATA_WD-1:0] dp1r1w18_dina,
  input      [DP1R1W18_DATA_WD-1:0] dp1r1w18_doutb,
  output reg                        dp1r1w18_ena,
  output reg                        dp1r1w18_enb,
  output reg                        dp1r1w18_wea,
  //dp1r1w19
  input                             dp1r1w19_clka,
  input                             dp1r1w19_clkb,
  output reg [DP1R1W19_ADDR_WD-1:0] dp1r1w19_addra,
  output reg [DP1R1W19_ADDR_WD-1:0] dp1r1w19_addrb,
  output reg [DP1R1W19_DATA_WD-1:0] dp1r1w19_dina,
  input      [DP1R1W19_DATA_WD-1:0] dp1r1w19_doutb,
  output reg                        dp1r1w19_ena,
  output reg                        dp1r1w19_enb,
  output reg                        dp1r1w19_wea,
  //dp1r1w20
  input                             dp1r1w20_clka,
  input                             dp1r1w20_clkb,
  output reg [DP1R1W20_ADDR_WD-1:0] dp1r1w20_addra,
  output reg [DP1R1W20_ADDR_WD-1:0] dp1r1w20_addrb,
  output reg [DP1R1W20_DATA_WD-1:0] dp1r1w20_dina,
  input      [DP1R1W20_DATA_WD-1:0] dp1r1w20_doutb,
  output reg                        dp1r1w20_ena,
  output reg                        dp1r1w20_enb,
  output reg                        dp1r1w20_wea,
  //dp1r1w21
  input                             dp1r1w21_clka,
  input                             dp1r1w21_clkb,
  output reg [DP1R1W21_ADDR_WD-1:0] dp1r1w21_addra,
  output reg [DP1R1W21_ADDR_WD-1:0] dp1r1w21_addrb,
  output reg [DP1R1W21_DATA_WD-1:0] dp1r1w21_dina,
  input      [DP1R1W21_DATA_WD-1:0] dp1r1w21_doutb,
  output reg                        dp1r1w21_ena,
  output reg                        dp1r1w21_enb,
  output reg                        dp1r1w21_wea,
  //dp1r1w22
  input                             dp1r1w22_clka,
  input                             dp1r1w22_clkb,
  output reg [DP1R1W22_ADDR_WD-1:0] dp1r1w22_addra,
  output reg [DP1R1W22_ADDR_WD-1:0] dp1r1w22_addrb,
  output reg [DP1R1W22_DATA_WD-1:0] dp1r1w22_dina,
  input      [DP1R1W22_DATA_WD-1:0] dp1r1w22_doutb,
  output reg                        dp1r1w22_ena,
  output reg                        dp1r1w22_enb,
  output reg                        dp1r1w22_wea,
  //dp1r1w23
  input                             dp1r1w23_clka,
  input                             dp1r1w23_clkb,
  output reg [DP1R1W23_ADDR_WD-1:0] dp1r1w23_addra,
  output reg [DP1R1W23_ADDR_WD-1:0] dp1r1w23_addrb,
  output reg [DP1R1W23_DATA_WD-1:0] dp1r1w23_dina,
  input      [DP1R1W23_DATA_WD-1:0] dp1r1w23_doutb,
  output reg                        dp1r1w23_ena,
  output reg                        dp1r1w23_enb,
  output reg                        dp1r1w23_wea,
  //dp1r1w24
  input                             dp1r1w24_clka,
  input                             dp1r1w24_clkb,
  output reg [DP1R1W24_ADDR_WD-1:0] dp1r1w24_addra,
  output reg [DP1R1W24_ADDR_WD-1:0] dp1r1w24_addrb,
  output reg [DP1R1W24_DATA_WD-1:0] dp1r1w24_dina,
  input      [DP1R1W24_DATA_WD-1:0] dp1r1w24_doutb,
  output reg                        dp1r1w24_ena,
  output reg                        dp1r1w24_enb,
  output reg                        dp1r1w24_wea,
  //dp1r1w25
  input                             dp1r1w25_clka,
  input                             dp1r1w25_clkb,
  output reg [DP1R1W25_ADDR_WD-1:0] dp1r1w25_addra,
  output reg [DP1R1W25_ADDR_WD-1:0] dp1r1w25_addrb,
  output reg [DP1R1W25_DATA_WD-1:0] dp1r1w25_dina,
  input      [DP1R1W25_DATA_WD-1:0] dp1r1w25_doutb,
  output reg                        dp1r1w25_ena,
  output reg                        dp1r1w25_enb,
  output reg                        dp1r1w25_wea,
  //dp1r1w26
  input                             dp1r1w26_clka,
  input                             dp1r1w26_clkb,
  output reg [DP1R1W26_ADDR_WD-1:0] dp1r1w26_addra,
  output reg [DP1R1W26_ADDR_WD-1:0] dp1r1w26_addrb,
  output reg [DP1R1W26_DATA_WD-1:0] dp1r1w26_dina,
  input      [DP1R1W26_DATA_WD-1:0] dp1r1w26_doutb,
  output reg                        dp1r1w26_ena,
  output reg                        dp1r1w26_enb,
  output reg                        dp1r1w26_wea,
  //dp1r1w27
  input                             dp1r1w27_clka,
  input                             dp1r1w27_clkb,
  output reg [DP1R1W27_ADDR_WD-1:0] dp1r1w27_addra,
  output reg [DP1R1W27_ADDR_WD-1:0] dp1r1w27_addrb,
  output reg [DP1R1W27_DATA_WD-1:0] dp1r1w27_dina,
  input      [DP1R1W27_DATA_WD-1:0] dp1r1w27_doutb,
  output reg                        dp1r1w27_ena,
  output reg                        dp1r1w27_enb,
  output reg                        dp1r1w27_wea,
  //dp1r1w28
  input                             dp1r1w28_clka,
  input                             dp1r1w28_clkb,
  output reg [DP1R1W28_ADDR_WD-1:0] dp1r1w28_addra,
  output reg [DP1R1W28_ADDR_WD-1:0] dp1r1w28_addrb,
  output reg [DP1R1W28_DATA_WD-1:0] dp1r1w28_dina,
  input      [DP1R1W28_DATA_WD-1:0] dp1r1w28_doutb,
  output reg                        dp1r1w28_ena,
  output reg                        dp1r1w28_enb,
  output reg                        dp1r1w28_wea,
  //dp1r1w29
  input                             dp1r1w29_clka,
  input                             dp1r1w29_clkb,
  output reg [DP1R1W29_ADDR_WD-1:0] dp1r1w29_addra,
  output reg [DP1R1W29_ADDR_WD-1:0] dp1r1w29_addrb,
  output reg [DP1R1W29_DATA_WD-1:0] dp1r1w29_dina,
  input      [DP1R1W29_DATA_WD-1:0] dp1r1w29_doutb,
  output reg                        dp1r1w29_ena,
  output reg                        dp1r1w29_enb,
  output reg                        dp1r1w29_wea,
  //dp1r1w30
  input                             dp1r1w30_clka,
  input                             dp1r1w30_clkb,
  output reg [DP1R1W30_ADDR_WD-1:0] dp1r1w30_addra,
  output reg [DP1R1W30_ADDR_WD-1:0] dp1r1w30_addrb,
  output reg [DP1R1W30_DATA_WD-1:0] dp1r1w30_dina,
  input      [DP1R1W30_DATA_WD-1:0] dp1r1w30_doutb,
  output reg                        dp1r1w30_ena,
  output reg                        dp1r1w30_enb,
  output reg                        dp1r1w30_wea,
  //dp1r1w31
  input                             dp1r1w31_clka,
  input                             dp1r1w31_clkb,
  output reg [DP1R1W31_ADDR_WD-1:0] dp1r1w31_addra,
  output reg [DP1R1W31_ADDR_WD-1:0] dp1r1w31_addrb,
  output reg [DP1R1W31_DATA_WD-1:0] dp1r1w31_dina,
  input      [DP1R1W31_DATA_WD-1:0] dp1r1w31_doutb,
  output reg                        dp1r1w31_ena,
  output reg                        dp1r1w31_enb,
  output reg                        dp1r1w31_wea,

  //--------------------------------------
  // SRAM with byte enables
  //--------------------------------------
  //sram_be_0
  input                                 sram_be_0_clk,
  output reg    [SRAM_BE_0_ADDR_WD-1:0] sram_be_0_addr,
  output reg    [SRAM_BE_0_DATA_WD-1:0] sram_be_0_din,
  input         [SRAM_BE_0_DATA_WD-1:0] sram_be_0_dout,
  output reg  [SRAM_BE_0_DATA_WD/8-1:0] sram_be_0_ben,
  output reg                            sram_be_0_en,
  output reg                            sram_be_0_we,
  //sram_be_1
  input                                 sram_be_1_clk,
  output reg    [SRAM_BE_1_ADDR_WD-1:0] sram_be_1_addr,
  output reg    [SRAM_BE_1_DATA_WD-1:0] sram_be_1_din,
  input         [SRAM_BE_1_DATA_WD-1:0] sram_be_1_dout,
  output reg  [SRAM_BE_1_DATA_WD/8-1:0] sram_be_1_ben,
  output reg                            sram_be_1_en,
  output reg                            sram_be_1_we,
  //sram_be_2
  input                                 sram_be_2_clk,
  output reg    [SRAM_BE_2_ADDR_WD-1:0] sram_be_2_addr,
  output reg    [SRAM_BE_2_DATA_WD-1:0] sram_be_2_din,
  input         [SRAM_BE_2_DATA_WD-1:0] sram_be_2_dout,
  output reg  [SRAM_BE_2_DATA_WD/8-1:0] sram_be_2_ben,
  output reg                            sram_be_2_en,
  output reg                            sram_be_2_we,
  //sram_be_3
  input                                 sram_be_3_clk,
  output reg    [SRAM_BE_3_ADDR_WD-1:0] sram_be_3_addr,
  output reg    [SRAM_BE_3_DATA_WD-1:0] sram_be_3_din,
  input         [SRAM_BE_3_DATA_WD-1:0] sram_be_3_dout,
  output reg  [SRAM_BE_3_DATA_WD/8-1:0] sram_be_3_ben,
  output reg                            sram_be_3_en,
  output reg                            sram_be_3_we,
  //sram_be_4
  input                                 sram_be_4_clk,
  output reg    [SRAM_BE_4_ADDR_WD-1:0] sram_be_4_addr,
  output reg    [SRAM_BE_4_DATA_WD-1:0] sram_be_4_din,
  input         [SRAM_BE_4_DATA_WD-1:0] sram_be_4_dout,
  output reg  [SRAM_BE_4_DATA_WD/8-1:0] sram_be_4_ben,
  output reg                            sram_be_4_en,
  output reg                            sram_be_4_we,
  //sram_be_5
  input                                 sram_be_5_clk,
  output reg    [SRAM_BE_5_ADDR_WD-1:0] sram_be_5_addr,
  output reg    [SRAM_BE_5_DATA_WD-1:0] sram_be_5_din,
  input         [SRAM_BE_5_DATA_WD-1:0] sram_be_5_dout,
  output reg  [SRAM_BE_5_DATA_WD/8-1:0] sram_be_5_ben,
  output reg                            sram_be_5_en,
  output reg                            sram_be_5_we,
  //sram_be_6
  input                                 sram_be_6_clk,
  output reg    [SRAM_BE_6_ADDR_WD-1:0] sram_be_6_addr,
  output reg    [SRAM_BE_6_DATA_WD-1:0] sram_be_6_din,
  input         [SRAM_BE_6_DATA_WD-1:0] sram_be_6_dout,
  output reg  [SRAM_BE_6_DATA_WD/8-1:0] sram_be_6_ben,
  output reg                            sram_be_6_en,
  output reg                            sram_be_6_we,
  //sram_be_7
  input                                 sram_be_7_clk,
  output reg    [SRAM_BE_7_ADDR_WD-1:0] sram_be_7_addr,
  output reg    [SRAM_BE_7_DATA_WD-1:0] sram_be_7_din,
  input         [SRAM_BE_7_DATA_WD-1:0] sram_be_7_dout,
  output reg  [SRAM_BE_7_DATA_WD/8-1:0] sram_be_7_ben,
  output reg                            sram_be_7_en,
  output reg                            sram_be_7_we,
  //sram_be_8
  input                                 sram_be_8_clk,
  output reg    [SRAM_BE_8_ADDR_WD-1:0] sram_be_8_addr,
  output reg    [SRAM_BE_8_DATA_WD-1:0] sram_be_8_din,
  input         [SRAM_BE_8_DATA_WD-1:0] sram_be_8_dout,
  output reg  [SRAM_BE_8_DATA_WD/8-1:0] sram_be_8_ben,
  output reg                            sram_be_8_en,
  output reg                            sram_be_8_we,
  //sram_be_9
  input                                 sram_be_9_clk,
  output reg    [SRAM_BE_9_ADDR_WD-1:0] sram_be_9_addr,
  output reg    [SRAM_BE_9_DATA_WD-1:0] sram_be_9_din,
  input         [SRAM_BE_9_DATA_WD-1:0] sram_be_9_dout,
  output reg  [SRAM_BE_9_DATA_WD/8-1:0] sram_be_9_ben,
  output reg                            sram_be_9_en,
  output reg                            sram_be_9_we,
  //sram_be_10
  input                                 sram_be_10_clk,
  output reg   [SRAM_BE_10_ADDR_WD-1:0] sram_be_10_addr,
  output reg   [SRAM_BE_10_DATA_WD-1:0] sram_be_10_din,
  input        [SRAM_BE_10_DATA_WD-1:0] sram_be_10_dout,
  output reg [SRAM_BE_10_DATA_WD/8-1:0] sram_be_10_ben,
  output reg                            sram_be_10_en,
  output reg                            sram_be_10_we,
  //sram_be_11
  input                                 sram_be_11_clk,
  output reg   [SRAM_BE_11_ADDR_WD-1:0] sram_be_11_addr,
  output reg   [SRAM_BE_11_DATA_WD-1:0] sram_be_11_din,
  input        [SRAM_BE_11_DATA_WD-1:0] sram_be_11_dout,
  output reg [SRAM_BE_11_DATA_WD/8-1:0] sram_be_11_ben,
  output reg                            sram_be_11_en,
  output reg                            sram_be_11_we,
  //sram_be_12
  input                                 sram_be_12_clk,
  output reg   [SRAM_BE_12_ADDR_WD-1:0] sram_be_12_addr,
  output reg   [SRAM_BE_12_DATA_WD-1:0] sram_be_12_din,
  input        [SRAM_BE_12_DATA_WD-1:0] sram_be_12_dout,
  output reg [SRAM_BE_12_DATA_WD/8-1:0] sram_be_12_ben,
  output reg                            sram_be_12_en,
  output reg                            sram_be_12_we,
  //sram_be_13
  input                                 sram_be_13_clk,
  output reg   [SRAM_BE_13_ADDR_WD-1:0] sram_be_13_addr,
  output reg   [SRAM_BE_13_DATA_WD-1:0] sram_be_13_din,
  input        [SRAM_BE_13_DATA_WD-1:0] sram_be_13_dout,
  output reg [SRAM_BE_13_DATA_WD/8-1:0] sram_be_13_ben,
  output reg                            sram_be_13_en,
  output reg                            sram_be_13_we,
  //sram_be_14
  input                                 sram_be_14_clk,
  output reg   [SRAM_BE_14_ADDR_WD-1:0] sram_be_14_addr,
  output reg   [SRAM_BE_14_DATA_WD-1:0] sram_be_14_din,
  input        [SRAM_BE_14_DATA_WD-1:0] sram_be_14_dout,
  output reg [SRAM_BE_14_DATA_WD/8-1:0] sram_be_14_ben,
  output reg                            sram_be_14_en,
  output reg                            sram_be_14_we,
  //sram_be_15
  input                                 sram_be_15_clk,
  output reg   [SRAM_BE_15_ADDR_WD-1:0] sram_be_15_addr,
  output reg   [SRAM_BE_15_DATA_WD-1:0] sram_be_15_din,
  input        [SRAM_BE_15_DATA_WD-1:0] sram_be_15_dout,
  output reg [SRAM_BE_15_DATA_WD/8-1:0] sram_be_15_ben,
  output reg                            sram_be_15_en,
  output reg                            sram_be_15_we,
  //sram_be_16
  input                                 sram_be_16_clk,
  output reg   [SRAM_BE_16_ADDR_WD-1:0] sram_be_16_addr,
  output reg   [SRAM_BE_16_DATA_WD-1:0] sram_be_16_din,
  input        [SRAM_BE_16_DATA_WD-1:0] sram_be_16_dout,
  output reg [SRAM_BE_16_DATA_WD/8-1:0] sram_be_16_ben,
  output reg                            sram_be_16_en,
  output reg                            sram_be_16_we,
  //sram_be_17
  input                                 sram_be_17_clk,
  output reg   [SRAM_BE_17_ADDR_WD-1:0] sram_be_17_addr,
  output reg   [SRAM_BE_17_DATA_WD-1:0] sram_be_17_din,
  input        [SRAM_BE_17_DATA_WD-1:0] sram_be_17_dout,
  output reg [SRAM_BE_17_DATA_WD/8-1:0] sram_be_17_ben,
  output reg                            sram_be_17_en,
  output reg                            sram_be_17_we,
  //sram_be_18
  input                                 sram_be_18_clk,
  output reg   [SRAM_BE_18_ADDR_WD-1:0] sram_be_18_addr,
  output reg   [SRAM_BE_18_DATA_WD-1:0] sram_be_18_din,
  input        [SRAM_BE_18_DATA_WD-1:0] sram_be_18_dout,
  output reg [SRAM_BE_18_DATA_WD/8-1:0] sram_be_18_ben,
  output reg                            sram_be_18_en,
  output reg                            sram_be_18_we,
  //sram_be_19
  input                                 sram_be_19_clk,
  output reg   [SRAM_BE_19_ADDR_WD-1:0] sram_be_19_addr,
  output reg   [SRAM_BE_19_DATA_WD-1:0] sram_be_19_din,
  input        [SRAM_BE_19_DATA_WD-1:0] sram_be_19_dout,
  output reg [SRAM_BE_19_DATA_WD/8-1:0] sram_be_19_ben,
  output reg                            sram_be_19_en,
  output reg                            sram_be_19_we,
  //sram_be_20
  input                                 sram_be_20_clk,
  output reg   [SRAM_BE_20_ADDR_WD-1:0] sram_be_20_addr,
  output reg   [SRAM_BE_20_DATA_WD-1:0] sram_be_20_din,
  input        [SRAM_BE_20_DATA_WD-1:0] sram_be_20_dout,
  output reg [SRAM_BE_20_DATA_WD/8-1:0] sram_be_20_ben,
  output reg                            sram_be_20_en,
  output reg                            sram_be_20_we,
  //sram_be_21
  input                                 sram_be_21_clk,
  output reg   [SRAM_BE_21_ADDR_WD-1:0] sram_be_21_addr,
  output reg   [SRAM_BE_21_DATA_WD-1:0] sram_be_21_din,
  input        [SRAM_BE_21_DATA_WD-1:0] sram_be_21_dout,
  output reg [SRAM_BE_21_DATA_WD/8-1:0] sram_be_21_ben,
  output reg                            sram_be_21_en,
  output reg                            sram_be_21_we,
  //sram_be_22
  input                                 sram_be_22_clk,
  output reg   [SRAM_BE_22_ADDR_WD-1:0] sram_be_22_addr,
  output reg   [SRAM_BE_22_DATA_WD-1:0] sram_be_22_din,
  input        [SRAM_BE_22_DATA_WD-1:0] sram_be_22_dout,
  output reg [SRAM_BE_22_DATA_WD/8-1:0] sram_be_22_ben,
  output reg                            sram_be_22_en,
  output reg                            sram_be_22_we,
  //sram_be_23
  input                                 sram_be_23_clk,
  output reg   [SRAM_BE_23_ADDR_WD-1:0] sram_be_23_addr,
  output reg   [SRAM_BE_23_DATA_WD-1:0] sram_be_23_din,
  input        [SRAM_BE_23_DATA_WD-1:0] sram_be_23_dout,
  output reg [SRAM_BE_23_DATA_WD/8-1:0] sram_be_23_ben,
  output reg                            sram_be_23_en,
  output reg                            sram_be_23_we,
  //sram_be_24
  input                                 sram_be_24_clk,
  output reg   [SRAM_BE_24_ADDR_WD-1:0] sram_be_24_addr,
  output reg   [SRAM_BE_24_DATA_WD-1:0] sram_be_24_din,
  input        [SRAM_BE_24_DATA_WD-1:0] sram_be_24_dout,
  output reg [SRAM_BE_24_DATA_WD/8-1:0] sram_be_24_ben,
  output reg                            sram_be_24_en,
  output reg                            sram_be_24_we,
  //sram_be_25
  input                                 sram_be_25_clk,
  output reg   [SRAM_BE_25_ADDR_WD-1:0] sram_be_25_addr,
  output reg   [SRAM_BE_25_DATA_WD-1:0] sram_be_25_din,
  input        [SRAM_BE_25_DATA_WD-1:0] sram_be_25_dout,
  output reg [SRAM_BE_25_DATA_WD/8-1:0] sram_be_25_ben,
  output reg                            sram_be_25_en,
  output reg                            sram_be_25_we,
  //sram_be_26
  input                                 sram_be_26_clk,
  output reg   [SRAM_BE_26_ADDR_WD-1:0] sram_be_26_addr,
  output reg   [SRAM_BE_26_DATA_WD-1:0] sram_be_26_din,
  input        [SRAM_BE_26_DATA_WD-1:0] sram_be_26_dout,
  output reg [SRAM_BE_26_DATA_WD/8-1:0] sram_be_26_ben,
  output reg                            sram_be_26_en,
  output reg                            sram_be_26_we,
  //sram_be_27
  input                                 sram_be_27_clk,
  output reg   [SRAM_BE_27_ADDR_WD-1:0] sram_be_27_addr,
  output reg   [SRAM_BE_27_DATA_WD-1:0] sram_be_27_din,
  input        [SRAM_BE_27_DATA_WD-1:0] sram_be_27_dout,
  output reg [SRAM_BE_27_DATA_WD/8-1:0] sram_be_27_ben,
  output reg                            sram_be_27_en,
  output reg                            sram_be_27_we,
  //sram_be_28
  input                                 sram_be_28_clk,
  output reg   [SRAM_BE_28_ADDR_WD-1:0] sram_be_28_addr,
  output reg   [SRAM_BE_28_DATA_WD-1:0] sram_be_28_din,
  input        [SRAM_BE_28_DATA_WD-1:0] sram_be_28_dout,
  output reg [SRAM_BE_28_DATA_WD/8-1:0] sram_be_28_ben,
  output reg                            sram_be_28_en,
  output reg                            sram_be_28_we,
  //sram_be_29
  input                                 sram_be_29_clk,
  output reg   [SRAM_BE_29_ADDR_WD-1:0] sram_be_29_addr,
  output reg   [SRAM_BE_29_DATA_WD-1:0] sram_be_29_din,
  input        [SRAM_BE_29_DATA_WD-1:0] sram_be_29_dout,
  output reg [SRAM_BE_29_DATA_WD/8-1:0] sram_be_29_ben,
  output reg                            sram_be_29_en,
  output reg                            sram_be_29_we,
  //sram_be_30
  input                                 sram_be_30_clk,
  output reg   [SRAM_BE_30_ADDR_WD-1:0] sram_be_30_addr,
  output reg   [SRAM_BE_30_DATA_WD-1:0] sram_be_30_din,
  input        [SRAM_BE_30_DATA_WD-1:0] sram_be_30_dout,
  output reg [SRAM_BE_30_DATA_WD/8-1:0] sram_be_30_ben,
  output reg                            sram_be_30_en,
  output reg                            sram_be_30_we,
  //sram_be_31
  input                                 sram_be_31_clk,
  output reg   [SRAM_BE_31_ADDR_WD-1:0] sram_be_31_addr,
  output reg   [SRAM_BE_31_DATA_WD-1:0] sram_be_31_din,
  input        [SRAM_BE_31_DATA_WD-1:0] sram_be_31_dout,
  output reg [SRAM_BE_31_DATA_WD/8-1:0] sram_be_31_ben,
  output reg                            sram_be_31_en,
  output reg                            sram_be_31_we

);

`include "cdn_demo_ram_integration_stub_bfm_params.sv"


  //********************************************************************
  //                 S I G N A L   D E C L A R A T I O N
  //********************************************************************

  // SRAM
  reg                [31:0] sram_clk;
  reg    [SRAM_ADDR_WD-1:0] sram_addr;
  reg    [SRAM_DATA_WD-1:0] sram_din;
  reg    [SRAM_DATA_WD-1:0] sram_dout;
  reg                [31:0] sram_en;
  reg                [31:0] sram_we;

  // DP1R1W
  reg                [31:0] dp1r1w_clka;
  reg                [31:0] dp1r1w_clkb;
  reg  [DP1R1W_ADDR_WD-1:0] dp1r1w_addra;
  reg  [DP1R1W_ADDR_WD-1:0] dp1r1w_addrb;
  reg  [DP1R1W_DATA_WD-1:0] dp1r1w_dina;
  reg  [DP1R1W_DATA_WD-1:0] dp1r1w_doutb;
  reg                [31:0] dp1r1w_ena;
  reg                [31:0] dp1r1w_enb;
  reg                [31:0] dp1r1w_wea;

  // SRAM_BE
  reg                   [31:0] sram_be_clk;
  reg    [SRAM_BE_ADDR_WD-1:0] sram_be_addr;
  reg    [SRAM_BE_DATA_WD-1:0] sram_be_din;
  reg    [SRAM_BE_DATA_WD-1:0] sram_be_dout;
  reg  [SRAM_BE_DATA_WD/8-1:0] sram_be_ben;
  reg                   [31:0] sram_be_en;
  reg                   [31:0] sram_be_we;

  //------------------------------------
  // Other signals
  //------------------------------------
  reg [31:0] default_reg;

  //------------------------------------
  // MASTER APB Bank Registers
  //------------------------------------
  reg [31:0] master_ctrl_reg;
  //
  reg [31:0] num_sram_reg;
  reg [31:0] num_dp1r1w_reg;
  reg [31:0] num_dp2r2w_reg;
  reg [31:0] num_rf_reg;
  //
  reg [31:0] num_sram_be_reg;
  reg [31:0] num_dp1r1w_be_reg;
  reg [31:0] num_dp2r2w_be_reg;
  reg [31:0] num_rf_be_reg;

  //------------------------------------
  // Test function APB Bank Registers
  //------------------------------------
  reg [31:0] [31:0] ctrl_reg_sram;
  reg [31:0] [31:0] ctrl_reg_dp1r1w;
  reg [31:0] [31:0] ctrl_reg_dp2r2w;
  reg [31:0] [31:0] ctrl_reg_rf;
  //
  reg [31:0] [31:0] ctrl_reg_sram_be;
  reg [31:0] [31:0] ctrl_reg_dp1r1w_be;
  reg [31:0] [31:0] ctrl_reg_dp2r2w_be;
  reg [31:0] [31:0] ctrl_reg_rf_be;

  //------------------------------------
  // error counter
  //------------------------------------
  reg [31:0] [31:0] err_cnt_sram;
  reg [31:0] [31:0] err_cnt_dp1r1w;
  reg [31:0] [31:0] err_cnt_dp2r2w;
  reg [31:0] [31:0] err_cnt_rf;
  reg [31:0] [31:0] err_cnt_sram_be;
  reg [31:0] [31:0] err_cnt_dp1r1w_be;
  reg [31:0] [31:0] err_cnt_dp2r2w_be;
  reg [31:0] [31:0] err_cnt_rf_be;

  //------------------------------------
  // bits of CONTROL and STATUS regs
  //------------------------------------
  // STATUS[0]: CLEAR status flag
  wire       status_clear_master;
  reg [31:0] status_clear_sram;
  reg [31:0] status_clear_dp1r1w;
  reg [31:0] status_clear_dp2r2w;
  reg [31:0] status_clear_rf;
  reg [31:0] status_clear_sram_be;
  reg [31:0] status_clear_dp1r1w_be;
  reg [31:0] status_clear_dp2r2w_be;
  reg [31:0] status_clear_rf_be;
  //
  // STATUS[1]: PASS/FAIL status flag
  wire       status_test_pass_master;
  reg [31:0] status_test_pass_sram;
  reg [31:0] status_test_pass_dp1r1w;
  reg [31:0] status_test_pass_dp2r2w;
  reg [31:0] status_test_pass_rf;
  reg [31:0] status_test_pass_sram_be;
  reg [31:0] status_test_pass_dp1r1w_be;
  reg [31:0] status_test_pass_dp2r2w_be;
  reg [31:0] status_test_pass_rf_be;
  //
  // STATUS[2]: RUNNING/DONE status flag
  wire       status_test_done_master;
  reg [31:0] status_test_done_sram;
  reg [31:0] status_test_done_dp1r1w;
  reg [31:0] status_test_done_dp2r2w;
  reg [31:0] status_test_done_rf;
  reg [31:0] status_test_done_sram_be;
  reg [31:0] status_test_done_dp1r1w_be;
  reg [31:0] status_test_done_dp2r2w_be;
  reg [31:0] status_test_done_rf_be;
  //
  // CONTROL[3]: RESET/SCRUB RAM
  reg [31:0] reset_sram;
  reg [31:0] reset_dp1r1w;
  reg [31:0] reset_dp2r2w;
  reg [31:0] reset_rf;
  reg [31:0] reset_sram_be;
  reg [31:0] reset_dp1r1w_be;
  reg [31:0] reset_dp2r2w_be;
  reg [31:0] reset_rf_be;
  //
  // CONTROL[4]: START TRIGGER
  reg [31:0] test_start_sram;
  reg [31:0] test_start_dp1r1w;
  reg [31:0] test_start_dp2r2w;
  reg [31:0] test_start_rf;
  reg [31:0] test_start_sram_be;
  reg [31:0] test_start_dp1r1w_be;
  reg [31:0] test_start_dp2r2w_be;
  reg [31:0] test_start_rf_be;
  //
  // CONTROL[5]: Algorithm Walking 0
  reg [31:0] algorithm_w0_sram;
  reg [31:0] algorithm_w0_dp1r1w;
  reg [31:0] algorithm_w0_dp2r2w;
  reg [31:0] algorithm_w0_rf;
  reg [31:0] algorithm_w0_sram_be;
  reg [31:0] algorithm_w0_dp1r1w_be;
  reg [31:0] algorithm_w0_dp2r2w_be;
  reg [31:0] algorithm_w0_rf_be;
  //
  // CONTROL[6]: Algorithm Walking 1
  reg [31:0] algorithm_w1_sram;
  reg [31:0] algorithm_w1_dp1r1w;
  reg [31:0] algorithm_w1_dp2r2w;
  reg [31:0] algorithm_w1_rf;
  reg [31:0] algorithm_w1_sram_be;
  reg [31:0] algorithm_w1_dp1r1w_be;
  reg [31:0] algorithm_w1_dp2r2w_be;
  reg [31:0] algorithm_w1_rf_be;
  //
  // CONTROL[7]: Algorithm unique data
  reg [31:0] algorithm_data_sram;
  reg [31:0] algorithm_data_dp1r1w;
  reg [31:0] algorithm_data_dp2r2w;
  reg [31:0] algorithm_data_rf;
  reg [31:0] algorithm_data_sram_be;
  reg [31:0] algorithm_data_dp1r1w_be;
  reg [31:0] algorithm_data_dp2r2w_be;
  reg [31:0] algorithm_data_rf_be;



  //********************************************************************
  //                 F U N C T I O N A L    P A R T
  //********************************************************************

  //------------------------------------
  // SRAM
  //------------------------------------
  // clk
  assign sram_clk = {sram31_clk,
                     sram30_clk,
                     sram29_clk,
                     sram28_clk,
                     sram27_clk,
                     sram26_clk,
                     sram25_clk,
                     sram24_clk,
                     sram23_clk,
                     sram22_clk,
                     sram21_clk,
                     sram20_clk,
                     sram19_clk,
                     sram18_clk,
                     sram17_clk,
                     sram16_clk,
                     sram15_clk,
                     sram14_clk,
                     sram13_clk,
                     sram12_clk,
                     sram11_clk,
                     sram10_clk,
                     sram9_clk,
                     sram8_clk,
                     sram7_clk,
                     sram6_clk,
                     sram5_clk,
                     sram4_clk,
                     sram3_clk,
                     sram2_clk,
                     sram1_clk,
                     sram0_clk};

  //addr
  assign sram0_addr  = sram_addr[0                   +: SRAM0_ADDR_WD];
  assign sram1_addr  = sram_addr[SRAM1_ADDR_WD_START +: SRAM1_ADDR_WD];
  assign sram2_addr  = sram_addr[SRAM2_ADDR_WD_START +: SRAM2_ADDR_WD];
  assign sram3_addr  = sram_addr[SRAM3_ADDR_WD_START +: SRAM3_ADDR_WD];
  assign sram4_addr  = sram_addr[SRAM4_ADDR_WD_START +: SRAM4_ADDR_WD];
  assign sram5_addr  = sram_addr[SRAM5_ADDR_WD_START +: SRAM5_ADDR_WD];
  assign sram6_addr  = sram_addr[SRAM6_ADDR_WD_START +: SRAM6_ADDR_WD];
  assign sram7_addr  = sram_addr[SRAM7_ADDR_WD_START +: SRAM7_ADDR_WD];
  assign sram8_addr  = sram_addr[SRAM8_ADDR_WD_START +: SRAM8_ADDR_WD];
  assign sram9_addr  = sram_addr[SRAM9_ADDR_WD_START +: SRAM9_ADDR_WD];
  assign sram10_addr = sram_addr[SRAM10_ADDR_WD_START+: SRAM10_ADDR_WD];
  assign sram11_addr = sram_addr[SRAM11_ADDR_WD_START+: SRAM11_ADDR_WD];
  assign sram12_addr = sram_addr[SRAM12_ADDR_WD_START+: SRAM12_ADDR_WD];
  assign sram13_addr = sram_addr[SRAM13_ADDR_WD_START+: SRAM13_ADDR_WD];
  assign sram14_addr = sram_addr[SRAM14_ADDR_WD_START+: SRAM14_ADDR_WD];
  assign sram15_addr = sram_addr[SRAM15_ADDR_WD_START+: SRAM15_ADDR_WD];
  assign sram16_addr = sram_addr[SRAM16_ADDR_WD_START+: SRAM16_ADDR_WD];
  assign sram17_addr = sram_addr[SRAM17_ADDR_WD_START+: SRAM17_ADDR_WD];
  assign sram18_addr = sram_addr[SRAM18_ADDR_WD_START+: SRAM18_ADDR_WD];
  assign sram19_addr = sram_addr[SRAM19_ADDR_WD_START+: SRAM19_ADDR_WD];
  assign sram20_addr = sram_addr[SRAM20_ADDR_WD_START+: SRAM20_ADDR_WD];
  assign sram21_addr = sram_addr[SRAM21_ADDR_WD_START+: SRAM21_ADDR_WD];
  assign sram22_addr = sram_addr[SRAM22_ADDR_WD_START+: SRAM22_ADDR_WD];
  assign sram23_addr = sram_addr[SRAM23_ADDR_WD_START+: SRAM23_ADDR_WD];
  assign sram24_addr = sram_addr[SRAM24_ADDR_WD_START+: SRAM24_ADDR_WD];
  assign sram25_addr = sram_addr[SRAM25_ADDR_WD_START+: SRAM25_ADDR_WD];
  assign sram26_addr = sram_addr[SRAM26_ADDR_WD_START+: SRAM26_ADDR_WD];
  assign sram27_addr = sram_addr[SRAM27_ADDR_WD_START+: SRAM27_ADDR_WD];
  assign sram28_addr = sram_addr[SRAM28_ADDR_WD_START+: SRAM28_ADDR_WD];
  assign sram29_addr = sram_addr[SRAM29_ADDR_WD_START+: SRAM29_ADDR_WD];
  assign sram30_addr = sram_addr[SRAM30_ADDR_WD_START+: SRAM30_ADDR_WD];
  assign sram31_addr = sram_addr[SRAM31_ADDR_WD_START+: SRAM31_ADDR_WD];

  // din
  assign sram0_din  = sram_din[0                   +: SRAM0_DATA_WD];
  assign sram1_din  = sram_din[SRAM1_DATA_WD_START +: SRAM1_DATA_WD];
  assign sram2_din  = sram_din[SRAM2_DATA_WD_START +: SRAM2_DATA_WD];
  assign sram3_din  = sram_din[SRAM3_DATA_WD_START +: SRAM3_DATA_WD];
  assign sram4_din  = sram_din[SRAM4_DATA_WD_START +: SRAM4_DATA_WD];
  assign sram5_din  = sram_din[SRAM5_DATA_WD_START +: SRAM5_DATA_WD];
  assign sram6_din  = sram_din[SRAM6_DATA_WD_START +: SRAM6_DATA_WD];
  assign sram7_din  = sram_din[SRAM7_DATA_WD_START +: SRAM7_DATA_WD];
  assign sram8_din  = sram_din[SRAM8_DATA_WD_START +: SRAM8_DATA_WD];
  assign sram9_din  = sram_din[SRAM9_DATA_WD_START +: SRAM9_DATA_WD];
  assign sram10_din = sram_din[SRAM10_DATA_WD_START+: SRAM10_DATA_WD];
  assign sram11_din = sram_din[SRAM11_DATA_WD_START+: SRAM11_DATA_WD];
  assign sram12_din = sram_din[SRAM12_DATA_WD_START+: SRAM12_DATA_WD];
  assign sram13_din = sram_din[SRAM13_DATA_WD_START+: SRAM13_DATA_WD];
  assign sram14_din = sram_din[SRAM14_DATA_WD_START+: SRAM14_DATA_WD];
  assign sram15_din = sram_din[SRAM15_DATA_WD_START+: SRAM15_DATA_WD];
  assign sram16_din = sram_din[SRAM16_DATA_WD_START+: SRAM16_DATA_WD];
  assign sram17_din = sram_din[SRAM17_DATA_WD_START+: SRAM17_DATA_WD];
  assign sram18_din = sram_din[SRAM18_DATA_WD_START+: SRAM18_DATA_WD];
  assign sram19_din = sram_din[SRAM19_DATA_WD_START+: SRAM19_DATA_WD];
  assign sram20_din = sram_din[SRAM20_DATA_WD_START+: SRAM20_DATA_WD];
  assign sram21_din = sram_din[SRAM21_DATA_WD_START+: SRAM21_DATA_WD];
  assign sram22_din = sram_din[SRAM22_DATA_WD_START+: SRAM22_DATA_WD];
  assign sram23_din = sram_din[SRAM23_DATA_WD_START+: SRAM23_DATA_WD];
  assign sram24_din = sram_din[SRAM24_DATA_WD_START+: SRAM24_DATA_WD];
  assign sram25_din = sram_din[SRAM25_DATA_WD_START+: SRAM25_DATA_WD];
  assign sram26_din = sram_din[SRAM26_DATA_WD_START+: SRAM26_DATA_WD];
  assign sram27_din = sram_din[SRAM27_DATA_WD_START+: SRAM27_DATA_WD];
  assign sram28_din = sram_din[SRAM28_DATA_WD_START+: SRAM28_DATA_WD];
  assign sram29_din = sram_din[SRAM29_DATA_WD_START+: SRAM29_DATA_WD];
  assign sram30_din = sram_din[SRAM30_DATA_WD_START+: SRAM30_DATA_WD];
  assign sram31_din = sram_din[SRAM31_DATA_WD_START+: SRAM31_DATA_WD];

  // en
  assign sram0_en  = sram_en[0];
  assign sram1_en  = sram_en[1];
  assign sram2_en  = sram_en[2];
  assign sram3_en  = sram_en[3];
  assign sram4_en  = sram_en[4];
  assign sram5_en  = sram_en[5];
  assign sram6_en  = sram_en[6];
  assign sram7_en  = sram_en[7];
  assign sram8_en  = sram_en[8];
  assign sram9_en  = sram_en[9];
  assign sram10_en = sram_en[10];
  assign sram11_en = sram_en[11];
  assign sram12_en = sram_en[12];
  assign sram13_en = sram_en[13];
  assign sram14_en = sram_en[14];
  assign sram15_en = sram_en[15];
  assign sram16_en = sram_en[16];
  assign sram17_en = sram_en[17];
  assign sram18_en = sram_en[18];
  assign sram19_en = sram_en[19];
  assign sram20_en = sram_en[20];
  assign sram21_en = sram_en[21];
  assign sram22_en = sram_en[22];
  assign sram23_en = sram_en[23];
  assign sram24_en = sram_en[24];
  assign sram25_en = sram_en[25];
  assign sram26_en = sram_en[26];
  assign sram27_en = sram_en[27];
  assign sram28_en = sram_en[28];
  assign sram29_en = sram_en[29];
  assign sram30_en = sram_en[30];
  assign sram31_en = sram_en[31];

  // we
  assign sram0_we  = sram_we[0];
  assign sram1_we  = sram_we[1];
  assign sram2_we  = sram_we[2];
  assign sram3_we  = sram_we[3];
  assign sram4_we  = sram_we[4];
  assign sram5_we  = sram_we[5];
  assign sram6_we  = sram_we[6];
  assign sram7_we  = sram_we[7];
  assign sram8_we  = sram_we[8];
  assign sram9_we  = sram_we[9];
  assign sram10_we = sram_we[10];
  assign sram11_we = sram_we[11];
  assign sram12_we = sram_we[12];
  assign sram13_we = sram_we[13];
  assign sram14_we = sram_we[14];
  assign sram15_we = sram_we[15];
  assign sram16_we = sram_we[16];
  assign sram17_we = sram_we[17];
  assign sram18_we = sram_we[18];
  assign sram19_we = sram_we[19];
  assign sram20_we = sram_we[20];
  assign sram21_we = sram_we[21];
  assign sram22_we = sram_we[22];
  assign sram23_we = sram_we[23];
  assign sram24_we = sram_we[24];
  assign sram25_we = sram_we[25];
  assign sram26_we = sram_we[26];
  assign sram27_we = sram_we[27];
  assign sram28_we = sram_we[28];
  assign sram29_we = sram_we[29];
  assign sram30_we = sram_we[30];
  assign sram31_we = sram_we[31];

  // dout
  assign sram_dout = {sram31_dout,
                      sram30_dout,
                      sram29_dout,
                      sram28_dout,
                      sram27_dout,
                      sram26_dout,
                      sram25_dout,
                      sram24_dout,
                      sram23_dout,
                      sram22_dout,
                      sram21_dout,
                      sram20_dout,
                      sram19_dout,
                      sram18_dout,
                      sram17_dout,
                      sram16_dout,
                      sram15_dout,
                      sram14_dout,
                      sram13_dout,
                      sram12_dout,
                      sram11_dout,
                      sram10_dout,
                      sram9_dout,
                      sram8_dout,
                      sram7_dout,
                      sram6_dout,
                      sram5_dout,
                      sram4_dout,
                      sram3_dout,
                      sram2_dout,
                      sram1_dout,
                      sram0_dout};

  //------------------------------------
  // DP1R1W
  //------------------------------------
  // clka
  assign dp1r1w_clka = {dp1r1w31_clka,
                        dp1r1w30_clka,
                        dp1r1w29_clka,
                        dp1r1w28_clka,
                        dp1r1w27_clka,
                        dp1r1w26_clka,
                        dp1r1w25_clka,
                        dp1r1w24_clka,
                        dp1r1w23_clka,
                        dp1r1w22_clka,
                        dp1r1w21_clka,
                        dp1r1w20_clka,
                        dp1r1w19_clka,
                        dp1r1w18_clka,
                        dp1r1w17_clka,
                        dp1r1w16_clka,
                        dp1r1w15_clka,
                        dp1r1w14_clka,
                        dp1r1w13_clka,
                        dp1r1w12_clka,
                        dp1r1w11_clka,
                        dp1r1w10_clka,
                        dp1r1w9_clka,
                        dp1r1w8_clka,
                        dp1r1w7_clka,
                        dp1r1w6_clka,
                        dp1r1w5_clka,
                        dp1r1w4_clka,
                        dp1r1w3_clka,
                        dp1r1w2_clka,
                        dp1r1w1_clka,
                        dp1r1w0_clka};
  // clkb
  assign dp1r1w_clkb = {dp1r1w31_clkb,
                        dp1r1w30_clkb,
                        dp1r1w29_clkb,
                        dp1r1w28_clkb,
                        dp1r1w27_clkb,
                        dp1r1w26_clkb,
                        dp1r1w25_clkb,
                        dp1r1w24_clkb,
                        dp1r1w23_clkb,
                        dp1r1w22_clkb,
                        dp1r1w21_clkb,
                        dp1r1w20_clkb,
                        dp1r1w19_clkb,
                        dp1r1w18_clkb,
                        dp1r1w17_clkb,
                        dp1r1w16_clkb,
                        dp1r1w15_clkb,
                        dp1r1w14_clkb,
                        dp1r1w13_clkb,
                        dp1r1w12_clkb,
                        dp1r1w11_clkb,
                        dp1r1w10_clkb,
                        dp1r1w9_clkb,
                        dp1r1w8_clkb,
                        dp1r1w7_clkb,
                        dp1r1w6_clkb,
                        dp1r1w5_clkb,
                        dp1r1w4_clkb,
                        dp1r1w3_clkb,
                        dp1r1w2_clkb,
                        dp1r1w1_clkb,
                        dp1r1w0_clkb};

  // addra
  assign dp1r1w0_addra   = dp1r1w_addra[0                     +: DP1R1W0_ADDR_WD ];
  assign dp1r1w1_addra   = dp1r1w_addra[DP1R1W1_ADDR_WD_START +: DP1R1W1_ADDR_WD ];
  assign dp1r1w2_addra   = dp1r1w_addra[DP1R1W2_ADDR_WD_START +: DP1R1W2_ADDR_WD ];
  assign dp1r1w3_addra   = dp1r1w_addra[DP1R1W3_ADDR_WD_START +: DP1R1W3_ADDR_WD ];
  assign dp1r1w4_addra   = dp1r1w_addra[DP1R1W4_ADDR_WD_START +: DP1R1W4_ADDR_WD ];
  assign dp1r1w5_addra   = dp1r1w_addra[DP1R1W5_ADDR_WD_START +: DP1R1W5_ADDR_WD ];
  assign dp1r1w6_addra   = dp1r1w_addra[DP1R1W6_ADDR_WD_START +: DP1R1W6_ADDR_WD ];
  assign dp1r1w7_addra   = dp1r1w_addra[DP1R1W7_ADDR_WD_START +: DP1R1W7_ADDR_WD ];
  assign dp1r1w8_addra   = dp1r1w_addra[DP1R1W8_ADDR_WD_START +: DP1R1W8_ADDR_WD ];
  assign dp1r1w9_addra   = dp1r1w_addra[DP1R1W9_ADDR_WD_START +: DP1R1W9_ADDR_WD ];
  assign dp1r1w10_addra  = dp1r1w_addra[DP1R1W10_ADDR_WD_START+: DP1R1W10_ADDR_WD];
  assign dp1r1w11_addra  = dp1r1w_addra[DP1R1W11_ADDR_WD_START+: DP1R1W11_ADDR_WD];
  assign dp1r1w12_addra  = dp1r1w_addra[DP1R1W12_ADDR_WD_START+: DP1R1W12_ADDR_WD];
  assign dp1r1w13_addra  = dp1r1w_addra[DP1R1W13_ADDR_WD_START+: DP1R1W13_ADDR_WD];
  assign dp1r1w14_addra  = dp1r1w_addra[DP1R1W14_ADDR_WD_START+: DP1R1W14_ADDR_WD];
  assign dp1r1w15_addra  = dp1r1w_addra[DP1R1W15_ADDR_WD_START+: DP1R1W15_ADDR_WD];
  assign dp1r1w16_addra  = dp1r1w_addra[DP1R1W16_ADDR_WD_START+: DP1R1W16_ADDR_WD];
  assign dp1r1w17_addra  = dp1r1w_addra[DP1R1W17_ADDR_WD_START+: DP1R1W17_ADDR_WD];
  assign dp1r1w18_addra  = dp1r1w_addra[DP1R1W18_ADDR_WD_START+: DP1R1W18_ADDR_WD];
  assign dp1r1w19_addra  = dp1r1w_addra[DP1R1W19_ADDR_WD_START+: DP1R1W19_ADDR_WD];
  assign dp1r1w20_addra  = dp1r1w_addra[DP1R1W20_ADDR_WD_START+: DP1R1W20_ADDR_WD];
  assign dp1r1w21_addra  = dp1r1w_addra[DP1R1W21_ADDR_WD_START+: DP1R1W21_ADDR_WD];
  assign dp1r1w22_addra  = dp1r1w_addra[DP1R1W22_ADDR_WD_START+: DP1R1W22_ADDR_WD];
  assign dp1r1w23_addra  = dp1r1w_addra[DP1R1W23_ADDR_WD_START+: DP1R1W23_ADDR_WD];
  assign dp1r1w24_addra  = dp1r1w_addra[DP1R1W24_ADDR_WD_START+: DP1R1W24_ADDR_WD];
  assign dp1r1w25_addra  = dp1r1w_addra[DP1R1W25_ADDR_WD_START+: DP1R1W25_ADDR_WD];
  assign dp1r1w26_addra  = dp1r1w_addra[DP1R1W26_ADDR_WD_START+: DP1R1W26_ADDR_WD];
  assign dp1r1w27_addra  = dp1r1w_addra[DP1R1W27_ADDR_WD_START+: DP1R1W27_ADDR_WD];
  assign dp1r1w28_addra  = dp1r1w_addra[DP1R1W28_ADDR_WD_START+: DP1R1W28_ADDR_WD];
  assign dp1r1w29_addra  = dp1r1w_addra[DP1R1W29_ADDR_WD_START+: DP1R1W29_ADDR_WD];
  assign dp1r1w30_addra  = dp1r1w_addra[DP1R1W30_ADDR_WD_START+: DP1R1W30_ADDR_WD];
  assign dp1r1w31_addra  = dp1r1w_addra[DP1R1W31_ADDR_WD_START+: DP1R1W31_ADDR_WD];

  // addrb
  assign dp1r1w0_addrb   = dp1r1w_addrb[0                     +: DP1R1W0_ADDR_WD ];
  assign dp1r1w1_addrb   = dp1r1w_addrb[DP1R1W1_ADDR_WD_START +: DP1R1W1_ADDR_WD ];
  assign dp1r1w2_addrb   = dp1r1w_addrb[DP1R1W2_ADDR_WD_START +: DP1R1W2_ADDR_WD ];
  assign dp1r1w3_addrb   = dp1r1w_addrb[DP1R1W3_ADDR_WD_START +: DP1R1W3_ADDR_WD ];
  assign dp1r1w4_addrb   = dp1r1w_addrb[DP1R1W4_ADDR_WD_START +: DP1R1W4_ADDR_WD ];
  assign dp1r1w5_addrb   = dp1r1w_addrb[DP1R1W5_ADDR_WD_START +: DP1R1W5_ADDR_WD ];
  assign dp1r1w6_addrb   = dp1r1w_addrb[DP1R1W6_ADDR_WD_START +: DP1R1W6_ADDR_WD ];
  assign dp1r1w7_addrb   = dp1r1w_addrb[DP1R1W7_ADDR_WD_START +: DP1R1W7_ADDR_WD ];
  assign dp1r1w8_addrb   = dp1r1w_addrb[DP1R1W8_ADDR_WD_START +: DP1R1W8_ADDR_WD ];
  assign dp1r1w9_addrb   = dp1r1w_addrb[DP1R1W9_ADDR_WD_START +: DP1R1W9_ADDR_WD ];
  assign dp1r1w10_addrb  = dp1r1w_addrb[DP1R1W10_ADDR_WD_START+: DP1R1W10_ADDR_WD];
  assign dp1r1w11_addrb  = dp1r1w_addrb[DP1R1W11_ADDR_WD_START+: DP1R1W11_ADDR_WD];
  assign dp1r1w12_addrb  = dp1r1w_addrb[DP1R1W12_ADDR_WD_START+: DP1R1W12_ADDR_WD];
  assign dp1r1w13_addrb  = dp1r1w_addrb[DP1R1W13_ADDR_WD_START+: DP1R1W13_ADDR_WD];
  assign dp1r1w14_addrb  = dp1r1w_addrb[DP1R1W14_ADDR_WD_START+: DP1R1W14_ADDR_WD];
  assign dp1r1w15_addrb  = dp1r1w_addrb[DP1R1W15_ADDR_WD_START+: DP1R1W15_ADDR_WD];
  assign dp1r1w16_addrb  = dp1r1w_addrb[DP1R1W16_ADDR_WD_START+: DP1R1W16_ADDR_WD];
  assign dp1r1w17_addrb  = dp1r1w_addrb[DP1R1W17_ADDR_WD_START+: DP1R1W17_ADDR_WD];
  assign dp1r1w18_addrb  = dp1r1w_addrb[DP1R1W18_ADDR_WD_START+: DP1R1W18_ADDR_WD];
  assign dp1r1w19_addrb  = dp1r1w_addrb[DP1R1W19_ADDR_WD_START+: DP1R1W19_ADDR_WD];
  assign dp1r1w20_addrb  = dp1r1w_addrb[DP1R1W20_ADDR_WD_START+: DP1R1W20_ADDR_WD];
  assign dp1r1w21_addrb  = dp1r1w_addrb[DP1R1W21_ADDR_WD_START+: DP1R1W21_ADDR_WD];
  assign dp1r1w22_addrb  = dp1r1w_addrb[DP1R1W22_ADDR_WD_START+: DP1R1W22_ADDR_WD];
  assign dp1r1w23_addrb  = dp1r1w_addrb[DP1R1W23_ADDR_WD_START+: DP1R1W23_ADDR_WD];
  assign dp1r1w24_addrb  = dp1r1w_addrb[DP1R1W24_ADDR_WD_START+: DP1R1W24_ADDR_WD];
  assign dp1r1w25_addrb  = dp1r1w_addrb[DP1R1W25_ADDR_WD_START+: DP1R1W25_ADDR_WD];
  assign dp1r1w26_addrb  = dp1r1w_addrb[DP1R1W26_ADDR_WD_START+: DP1R1W26_ADDR_WD];
  assign dp1r1w27_addrb  = dp1r1w_addrb[DP1R1W27_ADDR_WD_START+: DP1R1W27_ADDR_WD];
  assign dp1r1w28_addrb  = dp1r1w_addrb[DP1R1W28_ADDR_WD_START+: DP1R1W28_ADDR_WD];
  assign dp1r1w29_addrb  = dp1r1w_addrb[DP1R1W29_ADDR_WD_START+: DP1R1W29_ADDR_WD];
  assign dp1r1w30_addrb  = dp1r1w_addrb[DP1R1W30_ADDR_WD_START+: DP1R1W30_ADDR_WD];
  assign dp1r1w31_addrb  = dp1r1w_addrb[DP1R1W31_ADDR_WD_START+: DP1R1W31_ADDR_WD];

  // dina
  assign dp1r1w0_dina   = dp1r1w_dina[0                     +: DP1R1W0_DATA_WD ];
  assign dp1r1w1_dina   = dp1r1w_dina[DP1R1W1_DATA_WD_START +: DP1R1W1_DATA_WD ];
  assign dp1r1w2_dina   = dp1r1w_dina[DP1R1W2_DATA_WD_START +: DP1R1W2_DATA_WD ];
  assign dp1r1w3_dina   = dp1r1w_dina[DP1R1W3_DATA_WD_START +: DP1R1W3_DATA_WD ];
  assign dp1r1w4_dina   = dp1r1w_dina[DP1R1W4_DATA_WD_START +: DP1R1W4_DATA_WD ];
  assign dp1r1w5_dina   = dp1r1w_dina[DP1R1W5_DATA_WD_START +: DP1R1W5_DATA_WD ];
  assign dp1r1w6_dina   = dp1r1w_dina[DP1R1W6_DATA_WD_START +: DP1R1W6_DATA_WD ];
  assign dp1r1w7_dina   = dp1r1w_dina[DP1R1W7_DATA_WD_START +: DP1R1W7_DATA_WD ];
  assign dp1r1w8_dina   = dp1r1w_dina[DP1R1W8_DATA_WD_START +: DP1R1W8_DATA_WD ];
  assign dp1r1w9_dina   = dp1r1w_dina[DP1R1W9_DATA_WD_START +: DP1R1W9_DATA_WD ];
  assign dp1r1w10_dina  = dp1r1w_dina[DP1R1W10_DATA_WD_START+: DP1R1W10_DATA_WD];
  assign dp1r1w11_dina  = dp1r1w_dina[DP1R1W11_DATA_WD_START+: DP1R1W11_DATA_WD];
  assign dp1r1w12_dina  = dp1r1w_dina[DP1R1W12_DATA_WD_START+: DP1R1W12_DATA_WD];
  assign dp1r1w13_dina  = dp1r1w_dina[DP1R1W13_DATA_WD_START+: DP1R1W13_DATA_WD];
  assign dp1r1w14_dina  = dp1r1w_dina[DP1R1W14_DATA_WD_START+: DP1R1W14_DATA_WD];
  assign dp1r1w15_dina  = dp1r1w_dina[DP1R1W15_DATA_WD_START+: DP1R1W15_DATA_WD];
  assign dp1r1w16_dina  = dp1r1w_dina[DP1R1W16_DATA_WD_START+: DP1R1W16_DATA_WD];
  assign dp1r1w17_dina  = dp1r1w_dina[DP1R1W17_DATA_WD_START+: DP1R1W17_DATA_WD];
  assign dp1r1w18_dina  = dp1r1w_dina[DP1R1W18_DATA_WD_START+: DP1R1W18_DATA_WD];
  assign dp1r1w19_dina  = dp1r1w_dina[DP1R1W19_DATA_WD_START+: DP1R1W19_DATA_WD];
  assign dp1r1w20_dina  = dp1r1w_dina[DP1R1W20_DATA_WD_START+: DP1R1W20_DATA_WD];
  assign dp1r1w21_dina  = dp1r1w_dina[DP1R1W21_DATA_WD_START+: DP1R1W21_DATA_WD];
  assign dp1r1w22_dina  = dp1r1w_dina[DP1R1W22_DATA_WD_START+: DP1R1W22_DATA_WD];
  assign dp1r1w23_dina  = dp1r1w_dina[DP1R1W23_DATA_WD_START+: DP1R1W23_DATA_WD];
  assign dp1r1w24_dina  = dp1r1w_dina[DP1R1W24_DATA_WD_START+: DP1R1W24_DATA_WD];
  assign dp1r1w25_dina  = dp1r1w_dina[DP1R1W25_DATA_WD_START+: DP1R1W25_DATA_WD];
  assign dp1r1w26_dina  = dp1r1w_dina[DP1R1W26_DATA_WD_START+: DP1R1W26_DATA_WD];
  assign dp1r1w27_dina  = dp1r1w_dina[DP1R1W27_DATA_WD_START+: DP1R1W27_DATA_WD];
  assign dp1r1w28_dina  = dp1r1w_dina[DP1R1W28_DATA_WD_START+: DP1R1W28_DATA_WD];
  assign dp1r1w29_dina  = dp1r1w_dina[DP1R1W29_DATA_WD_START+: DP1R1W29_DATA_WD];
  assign dp1r1w30_dina  = dp1r1w_dina[DP1R1W30_DATA_WD_START+: DP1R1W30_DATA_WD];
  assign dp1r1w31_dina  = dp1r1w_dina[DP1R1W31_DATA_WD_START+: DP1R1W31_DATA_WD];

  // ena
  assign dp1r1w0_ena   = dp1r1w_ena[0];
  assign dp1r1w1_ena   = dp1r1w_ena[1];
  assign dp1r1w2_ena   = dp1r1w_ena[2];
  assign dp1r1w3_ena   = dp1r1w_ena[3];
  assign dp1r1w4_ena   = dp1r1w_ena[4];
  assign dp1r1w5_ena   = dp1r1w_ena[5];
  assign dp1r1w6_ena   = dp1r1w_ena[6];
  assign dp1r1w7_ena   = dp1r1w_ena[7];
  assign dp1r1w8_ena   = dp1r1w_ena[8];
  assign dp1r1w9_ena   = dp1r1w_ena[9];
  assign dp1r1w10_ena  = dp1r1w_ena[10];
  assign dp1r1w11_ena  = dp1r1w_ena[11];
  assign dp1r1w12_ena  = dp1r1w_ena[12];
  assign dp1r1w13_ena  = dp1r1w_ena[13];
  assign dp1r1w14_ena  = dp1r1w_ena[14];
  assign dp1r1w15_ena  = dp1r1w_ena[15];
  assign dp1r1w16_ena  = dp1r1w_ena[16];
  assign dp1r1w17_ena  = dp1r1w_ena[17];
  assign dp1r1w18_ena  = dp1r1w_ena[18];
  assign dp1r1w19_ena  = dp1r1w_ena[19];
  assign dp1r1w20_ena  = dp1r1w_ena[20];
  assign dp1r1w21_ena  = dp1r1w_ena[21];
  assign dp1r1w22_ena  = dp1r1w_ena[22];
  assign dp1r1w23_ena  = dp1r1w_ena[23];
  assign dp1r1w24_ena  = dp1r1w_ena[24];
  assign dp1r1w25_ena  = dp1r1w_ena[25];
  assign dp1r1w26_ena  = dp1r1w_ena[26];
  assign dp1r1w27_ena  = dp1r1w_ena[27];
  assign dp1r1w28_ena  = dp1r1w_ena[28];
  assign dp1r1w29_ena  = dp1r1w_ena[29];
  assign dp1r1w30_ena  = dp1r1w_ena[30];
  assign dp1r1w31_ena  = dp1r1w_ena[31];

  // enb
  assign dp1r1w0_enb   = dp1r1w_enb[0];
  assign dp1r1w1_enb   = dp1r1w_enb[1];
  assign dp1r1w2_enb   = dp1r1w_enb[2];
  assign dp1r1w3_enb   = dp1r1w_enb[3];
  assign dp1r1w4_enb   = dp1r1w_enb[4];
  assign dp1r1w5_enb   = dp1r1w_enb[5];
  assign dp1r1w6_enb   = dp1r1w_enb[6];
  assign dp1r1w7_enb   = dp1r1w_enb[7];
  assign dp1r1w8_enb   = dp1r1w_enb[8];
  assign dp1r1w9_enb   = dp1r1w_enb[9];
  assign dp1r1w10_enb  = dp1r1w_enb[10];
  assign dp1r1w11_enb  = dp1r1w_enb[11];
  assign dp1r1w12_enb  = dp1r1w_enb[12];
  assign dp1r1w13_enb  = dp1r1w_enb[13];
  assign dp1r1w14_enb  = dp1r1w_enb[14];
  assign dp1r1w15_enb  = dp1r1w_enb[15];
  assign dp1r1w16_enb  = dp1r1w_enb[16];
  assign dp1r1w17_enb  = dp1r1w_enb[17];
  assign dp1r1w18_enb  = dp1r1w_enb[18];
  assign dp1r1w19_enb  = dp1r1w_enb[19];
  assign dp1r1w20_enb  = dp1r1w_enb[20];
  assign dp1r1w21_enb  = dp1r1w_enb[21];
  assign dp1r1w22_enb  = dp1r1w_enb[22];
  assign dp1r1w23_enb  = dp1r1w_enb[23];
  assign dp1r1w24_enb  = dp1r1w_enb[24];
  assign dp1r1w25_enb  = dp1r1w_enb[25];
  assign dp1r1w26_enb  = dp1r1w_enb[26];
  assign dp1r1w27_enb  = dp1r1w_enb[27];
  assign dp1r1w28_enb  = dp1r1w_enb[28];
  assign dp1r1w29_enb  = dp1r1w_enb[29];
  assign dp1r1w30_enb  = dp1r1w_enb[30];
  assign dp1r1w31_enb  = dp1r1w_enb[31];

  // wea
  assign dp1r1w0_wea   = dp1r1w_wea[0];
  assign dp1r1w1_wea   = dp1r1w_wea[1];
  assign dp1r1w2_wea   = dp1r1w_wea[2];
  assign dp1r1w3_wea   = dp1r1w_wea[3];
  assign dp1r1w4_wea   = dp1r1w_wea[4];
  assign dp1r1w5_wea   = dp1r1w_wea[5];
  assign dp1r1w6_wea   = dp1r1w_wea[6];
  assign dp1r1w7_wea   = dp1r1w_wea[7];
  assign dp1r1w8_wea   = dp1r1w_wea[8];
  assign dp1r1w9_wea   = dp1r1w_wea[9];
  assign dp1r1w10_wea  = dp1r1w_wea[10];
  assign dp1r1w11_wea  = dp1r1w_wea[11];
  assign dp1r1w12_wea  = dp1r1w_wea[12];
  assign dp1r1w13_wea  = dp1r1w_wea[13];
  assign dp1r1w14_wea  = dp1r1w_wea[14];
  assign dp1r1w15_wea  = dp1r1w_wea[15];
  assign dp1r1w16_wea  = dp1r1w_wea[16];
  assign dp1r1w17_wea  = dp1r1w_wea[17];
  assign dp1r1w18_wea  = dp1r1w_wea[18];
  assign dp1r1w19_wea  = dp1r1w_wea[19];
  assign dp1r1w20_wea  = dp1r1w_wea[20];
  assign dp1r1w21_wea  = dp1r1w_wea[21];
  assign dp1r1w22_wea  = dp1r1w_wea[22];
  assign dp1r1w23_wea  = dp1r1w_wea[23];
  assign dp1r1w24_wea  = dp1r1w_wea[24];
  assign dp1r1w25_wea  = dp1r1w_wea[25];
  assign dp1r1w26_wea  = dp1r1w_wea[26];
  assign dp1r1w27_wea  = dp1r1w_wea[27];
  assign dp1r1w28_wea  = dp1r1w_wea[28];
  assign dp1r1w29_wea  = dp1r1w_wea[29];
  assign dp1r1w30_wea  = dp1r1w_wea[30];
  assign dp1r1w31_wea  = dp1r1w_wea[31];

  // dout
  assign dp1r1w_doutb = {dp1r1w31_doutb,
                         dp1r1w30_doutb,
                         dp1r1w29_doutb,
                         dp1r1w28_doutb,
                         dp1r1w27_doutb,
                         dp1r1w26_doutb,
                         dp1r1w25_doutb,
                         dp1r1w24_doutb,
                         dp1r1w23_doutb,
                         dp1r1w22_doutb,
                         dp1r1w21_doutb,
                         dp1r1w20_doutb,
                         dp1r1w19_doutb,
                         dp1r1w18_doutb,
                         dp1r1w17_doutb,
                         dp1r1w16_doutb,
                         dp1r1w15_doutb,
                         dp1r1w14_doutb,
                         dp1r1w13_doutb,
                         dp1r1w12_doutb,
                         dp1r1w11_doutb,
                         dp1r1w10_doutb,
                         dp1r1w9_doutb,
                         dp1r1w8_doutb,
                         dp1r1w7_doutb,
                         dp1r1w6_doutb,
                         dp1r1w5_doutb,
                         dp1r1w4_doutb,
                         dp1r1w3_doutb,
                         dp1r1w2_doutb,
                         dp1r1w1_doutb,
                         dp1r1w0_doutb};

  //------------------------------------
  // SRAM_BE
  //------------------------------------
  // clk
  assign sram_be_clk = {sram_be_31_clk,
                        sram_be_30_clk,
                        sram_be_29_clk,
                        sram_be_28_clk,
                        sram_be_27_clk,
                        sram_be_26_clk,
                        sram_be_25_clk,
                        sram_be_24_clk,
                        sram_be_23_clk,
                        sram_be_22_clk,
                        sram_be_21_clk,
                        sram_be_20_clk,
                        sram_be_19_clk,
                        sram_be_18_clk,
                        sram_be_17_clk,
                        sram_be_16_clk,
                        sram_be_15_clk,
                        sram_be_14_clk,
                        sram_be_13_clk,
                        sram_be_12_clk,
                        sram_be_11_clk,
                        sram_be_10_clk,
                        sram_be_9_clk,
                        sram_be_8_clk,
                        sram_be_7_clk,
                        sram_be_6_clk,
                        sram_be_5_clk,
                        sram_be_4_clk,
                        sram_be_3_clk,
                        sram_be_2_clk,
                        sram_be_1_clk,
                        sram_be_0_clk};

  //addr
  assign sram_be_0_addr  = sram_be_addr[0                       +: SRAM_BE_0_ADDR_WD];
  assign sram_be_1_addr  = sram_be_addr[SRAM_BE_1_ADDR_WD_START +: SRAM_BE_1_ADDR_WD];
  assign sram_be_2_addr  = sram_be_addr[SRAM_BE_2_ADDR_WD_START +: SRAM_BE_2_ADDR_WD];
  assign sram_be_3_addr  = sram_be_addr[SRAM_BE_3_ADDR_WD_START +: SRAM_BE_3_ADDR_WD];
  assign sram_be_4_addr  = sram_be_addr[SRAM_BE_4_ADDR_WD_START +: SRAM_BE_4_ADDR_WD];
  assign sram_be_5_addr  = sram_be_addr[SRAM_BE_5_ADDR_WD_START +: SRAM_BE_5_ADDR_WD];
  assign sram_be_6_addr  = sram_be_addr[SRAM_BE_6_ADDR_WD_START +: SRAM_BE_6_ADDR_WD];
  assign sram_be_7_addr  = sram_be_addr[SRAM_BE_7_ADDR_WD_START +: SRAM_BE_7_ADDR_WD];
  assign sram_be_8_addr  = sram_be_addr[SRAM_BE_8_ADDR_WD_START +: SRAM_BE_8_ADDR_WD];
  assign sram_be_9_addr  = sram_be_addr[SRAM_BE_9_ADDR_WD_START +: SRAM_BE_9_ADDR_WD];
  assign sram_be_10_addr = sram_be_addr[SRAM_BE_10_ADDR_WD_START+: SRAM_BE_10_ADDR_WD];
  assign sram_be_11_addr = sram_be_addr[SRAM_BE_11_ADDR_WD_START+: SRAM_BE_11_ADDR_WD];
  assign sram_be_12_addr = sram_be_addr[SRAM_BE_12_ADDR_WD_START+: SRAM_BE_12_ADDR_WD];
  assign sram_be_13_addr = sram_be_addr[SRAM_BE_13_ADDR_WD_START+: SRAM_BE_13_ADDR_WD];
  assign sram_be_14_addr = sram_be_addr[SRAM_BE_14_ADDR_WD_START+: SRAM_BE_14_ADDR_WD];
  assign sram_be_15_addr = sram_be_addr[SRAM_BE_15_ADDR_WD_START+: SRAM_BE_15_ADDR_WD];
  assign sram_be_16_addr = sram_be_addr[SRAM_BE_16_ADDR_WD_START+: SRAM_BE_16_ADDR_WD];
  assign sram_be_17_addr = sram_be_addr[SRAM_BE_17_ADDR_WD_START+: SRAM_BE_17_ADDR_WD];
  assign sram_be_18_addr = sram_be_addr[SRAM_BE_18_ADDR_WD_START+: SRAM_BE_18_ADDR_WD];
  assign sram_be_19_addr = sram_be_addr[SRAM_BE_19_ADDR_WD_START+: SRAM_BE_19_ADDR_WD];
  assign sram_be_20_addr = sram_be_addr[SRAM_BE_20_ADDR_WD_START+: SRAM_BE_20_ADDR_WD];
  assign sram_be_21_addr = sram_be_addr[SRAM_BE_21_ADDR_WD_START+: SRAM_BE_21_ADDR_WD];
  assign sram_be_22_addr = sram_be_addr[SRAM_BE_22_ADDR_WD_START+: SRAM_BE_22_ADDR_WD];
  assign sram_be_23_addr = sram_be_addr[SRAM_BE_23_ADDR_WD_START+: SRAM_BE_23_ADDR_WD];
  assign sram_be_24_addr = sram_be_addr[SRAM_BE_24_ADDR_WD_START+: SRAM_BE_24_ADDR_WD];
  assign sram_be_25_addr = sram_be_addr[SRAM_BE_25_ADDR_WD_START+: SRAM_BE_25_ADDR_WD];
  assign sram_be_26_addr = sram_be_addr[SRAM_BE_26_ADDR_WD_START+: SRAM_BE_26_ADDR_WD];
  assign sram_be_27_addr = sram_be_addr[SRAM_BE_27_ADDR_WD_START+: SRAM_BE_27_ADDR_WD];
  assign sram_be_28_addr = sram_be_addr[SRAM_BE_28_ADDR_WD_START+: SRAM_BE_28_ADDR_WD];
  assign sram_be_29_addr = sram_be_addr[SRAM_BE_29_ADDR_WD_START+: SRAM_BE_29_ADDR_WD];
  assign sram_be_30_addr = sram_be_addr[SRAM_BE_30_ADDR_WD_START+: SRAM_BE_30_ADDR_WD];
  assign sram_be_31_addr = sram_be_addr[SRAM_BE_31_ADDR_WD_START+: SRAM_BE_31_ADDR_WD];

  // din
  assign sram_be_0_din  = sram_be_din[0                       +: SRAM_BE_0_DATA_WD];
  assign sram_be_1_din  = sram_be_din[SRAM_BE_1_DATA_WD_START +: SRAM_BE_1_DATA_WD];
  assign sram_be_2_din  = sram_be_din[SRAM_BE_2_DATA_WD_START +: SRAM_BE_2_DATA_WD];
  assign sram_be_3_din  = sram_be_din[SRAM_BE_3_DATA_WD_START +: SRAM_BE_3_DATA_WD];
  assign sram_be_4_din  = sram_be_din[SRAM_BE_4_DATA_WD_START +: SRAM_BE_4_DATA_WD];
  assign sram_be_5_din  = sram_be_din[SRAM_BE_5_DATA_WD_START +: SRAM_BE_5_DATA_WD];
  assign sram_be_6_din  = sram_be_din[SRAM_BE_6_DATA_WD_START +: SRAM_BE_6_DATA_WD];
  assign sram_be_7_din  = sram_be_din[SRAM_BE_7_DATA_WD_START +: SRAM_BE_7_DATA_WD];
  assign sram_be_8_din  = sram_be_din[SRAM_BE_8_DATA_WD_START +: SRAM_BE_8_DATA_WD];
  assign sram_be_9_din  = sram_be_din[SRAM_BE_9_DATA_WD_START +: SRAM_BE_9_DATA_WD];
  assign sram_be_10_din = sram_be_din[SRAM_BE_10_DATA_WD_START+: SRAM_BE_10_DATA_WD];
  assign sram_be_11_din = sram_be_din[SRAM_BE_11_DATA_WD_START+: SRAM_BE_11_DATA_WD];
  assign sram_be_12_din = sram_be_din[SRAM_BE_12_DATA_WD_START+: SRAM_BE_12_DATA_WD];
  assign sram_be_13_din = sram_be_din[SRAM_BE_13_DATA_WD_START+: SRAM_BE_13_DATA_WD];
  assign sram_be_14_din = sram_be_din[SRAM_BE_14_DATA_WD_START+: SRAM_BE_14_DATA_WD];
  assign sram_be_15_din = sram_be_din[SRAM_BE_15_DATA_WD_START+: SRAM_BE_15_DATA_WD];
  assign sram_be_16_din = sram_be_din[SRAM_BE_16_DATA_WD_START+: SRAM_BE_16_DATA_WD];
  assign sram_be_17_din = sram_be_din[SRAM_BE_17_DATA_WD_START+: SRAM_BE_17_DATA_WD];
  assign sram_be_18_din = sram_be_din[SRAM_BE_18_DATA_WD_START+: SRAM_BE_18_DATA_WD];
  assign sram_be_19_din = sram_be_din[SRAM_BE_19_DATA_WD_START+: SRAM_BE_19_DATA_WD];
  assign sram_be_20_din = sram_be_din[SRAM_BE_20_DATA_WD_START+: SRAM_BE_20_DATA_WD];
  assign sram_be_21_din = sram_be_din[SRAM_BE_21_DATA_WD_START+: SRAM_BE_21_DATA_WD];
  assign sram_be_22_din = sram_be_din[SRAM_BE_22_DATA_WD_START+: SRAM_BE_22_DATA_WD];
  assign sram_be_23_din = sram_be_din[SRAM_BE_23_DATA_WD_START+: SRAM_BE_23_DATA_WD];
  assign sram_be_24_din = sram_be_din[SRAM_BE_24_DATA_WD_START+: SRAM_BE_24_DATA_WD];
  assign sram_be_25_din = sram_be_din[SRAM_BE_25_DATA_WD_START+: SRAM_BE_25_DATA_WD];
  assign sram_be_26_din = sram_be_din[SRAM_BE_26_DATA_WD_START+: SRAM_BE_26_DATA_WD];
  assign sram_be_27_din = sram_be_din[SRAM_BE_27_DATA_WD_START+: SRAM_BE_27_DATA_WD];
  assign sram_be_28_din = sram_be_din[SRAM_BE_28_DATA_WD_START+: SRAM_BE_28_DATA_WD];
  assign sram_be_29_din = sram_be_din[SRAM_BE_29_DATA_WD_START+: SRAM_BE_29_DATA_WD];
  assign sram_be_30_din = sram_be_din[SRAM_BE_30_DATA_WD_START+: SRAM_BE_30_DATA_WD];
  assign sram_be_31_din = sram_be_din[SRAM_BE_31_DATA_WD_START+: SRAM_BE_31_DATA_WD];

  // ben
  assign sram_be_0_ben  = sram_be_ben[0                         +: SRAM_BE_0_DATA_WD/8];
  assign sram_be_1_ben  = sram_be_ben[SRAM_BE_1_DATA_WD_START/8 +: SRAM_BE_1_DATA_WD/8];
  assign sram_be_2_ben  = sram_be_ben[SRAM_BE_2_DATA_WD_START/8 +: SRAM_BE_2_DATA_WD/8];
  assign sram_be_3_ben  = sram_be_ben[SRAM_BE_3_DATA_WD_START/8 +: SRAM_BE_3_DATA_WD/8];
  assign sram_be_4_ben  = sram_be_ben[SRAM_BE_4_DATA_WD_START/8 +: SRAM_BE_4_DATA_WD/8];
  assign sram_be_5_ben  = sram_be_ben[SRAM_BE_5_DATA_WD_START/8 +: SRAM_BE_5_DATA_WD/8];
  assign sram_be_6_ben  = sram_be_ben[SRAM_BE_6_DATA_WD_START/8 +: SRAM_BE_6_DATA_WD/8];
  assign sram_be_7_ben  = sram_be_ben[SRAM_BE_7_DATA_WD_START/8 +: SRAM_BE_7_DATA_WD/8];
  assign sram_be_8_ben  = sram_be_ben[SRAM_BE_8_DATA_WD_START/8 +: SRAM_BE_8_DATA_WD/8];
  assign sram_be_9_ben  = sram_be_ben[SRAM_BE_9_DATA_WD_START/8 +: SRAM_BE_9_DATA_WD/8];
  assign sram_be_10_ben = sram_be_ben[SRAM_BE_10_DATA_WD_START/8+: SRAM_BE_10_DATA_WD/8];
  assign sram_be_11_ben = sram_be_ben[SRAM_BE_11_DATA_WD_START/8+: SRAM_BE_11_DATA_WD/8];
  assign sram_be_12_ben = sram_be_ben[SRAM_BE_12_DATA_WD_START/8+: SRAM_BE_12_DATA_WD/8];
  assign sram_be_13_ben = sram_be_ben[SRAM_BE_13_DATA_WD_START/8+: SRAM_BE_13_DATA_WD/8];
  assign sram_be_14_ben = sram_be_ben[SRAM_BE_14_DATA_WD_START/8+: SRAM_BE_14_DATA_WD/8];
  assign sram_be_15_ben = sram_be_ben[SRAM_BE_15_DATA_WD_START/8+: SRAM_BE_15_DATA_WD/8];
  assign sram_be_16_ben = sram_be_ben[SRAM_BE_16_DATA_WD_START/8+: SRAM_BE_16_DATA_WD/8];
  assign sram_be_17_ben = sram_be_ben[SRAM_BE_17_DATA_WD_START/8+: SRAM_BE_17_DATA_WD/8];
  assign sram_be_18_ben = sram_be_ben[SRAM_BE_18_DATA_WD_START/8+: SRAM_BE_18_DATA_WD/8];
  assign sram_be_19_ben = sram_be_ben[SRAM_BE_19_DATA_WD_START/8+: SRAM_BE_19_DATA_WD/8];
  assign sram_be_20_ben = sram_be_ben[SRAM_BE_20_DATA_WD_START/8+: SRAM_BE_20_DATA_WD/8];
  assign sram_be_21_ben = sram_be_ben[SRAM_BE_21_DATA_WD_START/8+: SRAM_BE_21_DATA_WD/8];
  assign sram_be_22_ben = sram_be_ben[SRAM_BE_22_DATA_WD_START/8+: SRAM_BE_22_DATA_WD/8];
  assign sram_be_23_ben = sram_be_ben[SRAM_BE_23_DATA_WD_START/8+: SRAM_BE_23_DATA_WD/8];
  assign sram_be_24_ben = sram_be_ben[SRAM_BE_24_DATA_WD_START/8+: SRAM_BE_24_DATA_WD/8];
  assign sram_be_25_ben = sram_be_ben[SRAM_BE_25_DATA_WD_START/8+: SRAM_BE_25_DATA_WD/8];
  assign sram_be_26_ben = sram_be_ben[SRAM_BE_26_DATA_WD_START/8+: SRAM_BE_26_DATA_WD/8];
  assign sram_be_27_ben = sram_be_ben[SRAM_BE_27_DATA_WD_START/8+: SRAM_BE_27_DATA_WD/8];
  assign sram_be_28_ben = sram_be_ben[SRAM_BE_28_DATA_WD_START/8+: SRAM_BE_28_DATA_WD/8];
  assign sram_be_29_ben = sram_be_ben[SRAM_BE_29_DATA_WD_START/8+: SRAM_BE_29_DATA_WD/8];
  assign sram_be_30_ben = sram_be_ben[SRAM_BE_30_DATA_WD_START/8+: SRAM_BE_30_DATA_WD/8];
  assign sram_be_31_ben = sram_be_ben[SRAM_BE_31_DATA_WD_START/8+: SRAM_BE_31_DATA_WD/8];

  // en
  assign sram_be_0_en  = sram_be_en[0];
  assign sram_be_1_en  = sram_be_en[1];
  assign sram_be_2_en  = sram_be_en[2];
  assign sram_be_3_en  = sram_be_en[3];
  assign sram_be_4_en  = sram_be_en[4];
  assign sram_be_5_en  = sram_be_en[5];
  assign sram_be_6_en  = sram_be_en[6];
  assign sram_be_7_en  = sram_be_en[7];
  assign sram_be_8_en  = sram_be_en[8];
  assign sram_be_9_en  = sram_be_en[9];
  assign sram_be_10_en = sram_be_en[10];
  assign sram_be_11_en = sram_be_en[11];
  assign sram_be_12_en = sram_be_en[12];
  assign sram_be_13_en = sram_be_en[13];
  assign sram_be_14_en = sram_be_en[14];
  assign sram_be_15_en = sram_be_en[15];
  assign sram_be_16_en = sram_be_en[16];
  assign sram_be_17_en = sram_be_en[17];
  assign sram_be_18_en = sram_be_en[18];
  assign sram_be_19_en = sram_be_en[19];
  assign sram_be_20_en = sram_be_en[20];
  assign sram_be_21_en = sram_be_en[21];
  assign sram_be_22_en = sram_be_en[22];
  assign sram_be_23_en = sram_be_en[23];
  assign sram_be_24_en = sram_be_en[24];
  assign sram_be_25_en = sram_be_en[25];
  assign sram_be_26_en = sram_be_en[26];
  assign sram_be_27_en = sram_be_en[27];
  assign sram_be_28_en = sram_be_en[28];
  assign sram_be_29_en = sram_be_en[29];
  assign sram_be_30_en = sram_be_en[30];
  assign sram_be_31_en = sram_be_en[31];

  // we
  assign sram_be_0_we  = sram_be_we[0];
  assign sram_be_1_we  = sram_be_we[1];
  assign sram_be_2_we  = sram_be_we[2];
  assign sram_be_3_we  = sram_be_we[3];
  assign sram_be_4_we  = sram_be_we[4];
  assign sram_be_5_we  = sram_be_we[5];
  assign sram_be_6_we  = sram_be_we[6];
  assign sram_be_7_we  = sram_be_we[7];
  assign sram_be_8_we  = sram_be_we[8];
  assign sram_be_9_we  = sram_be_we[9];
  assign sram_be_10_we = sram_be_we[10];
  assign sram_be_11_we = sram_be_we[11];
  assign sram_be_12_we = sram_be_we[12];
  assign sram_be_13_we = sram_be_we[13];
  assign sram_be_14_we = sram_be_we[14];
  assign sram_be_15_we = sram_be_we[15];
  assign sram_be_16_we = sram_be_we[16];
  assign sram_be_17_we = sram_be_we[17];
  assign sram_be_18_we = sram_be_we[18];
  assign sram_be_19_we = sram_be_we[19];
  assign sram_be_20_we = sram_be_we[20];
  assign sram_be_21_we = sram_be_we[21];
  assign sram_be_22_we = sram_be_we[22];
  assign sram_be_23_we = sram_be_we[23];
  assign sram_be_24_we = sram_be_we[24];
  assign sram_be_25_we = sram_be_we[25];
  assign sram_be_26_we = sram_be_we[26];
  assign sram_be_27_we = sram_be_we[27];
  assign sram_be_28_we = sram_be_we[28];
  assign sram_be_29_we = sram_be_we[29];
  assign sram_be_30_we = sram_be_we[30];
  assign sram_be_31_we = sram_be_we[31];

  // dout
  assign sram_be_dout = {sram_be_31_dout,
                         sram_be_30_dout,
                         sram_be_29_dout,
                         sram_be_28_dout,
                         sram_be_27_dout,
                         sram_be_26_dout,
                         sram_be_25_dout,
                         sram_be_24_dout,
                         sram_be_23_dout,
                         sram_be_22_dout,
                         sram_be_21_dout,
                         sram_be_20_dout,
                         sram_be_19_dout,
                         sram_be_18_dout,
                         sram_be_17_dout,
                         sram_be_16_dout,
                         sram_be_15_dout,
                         sram_be_14_dout,
                         sram_be_13_dout,
                         sram_be_12_dout,
                         sram_be_11_dout,
                         sram_be_10_dout,
                         sram_be_9_dout,
                         sram_be_8_dout,
                         sram_be_7_dout,
                         sram_be_6_dout,
                         sram_be_5_dout,
                         sram_be_4_dout,
                         sram_be_3_dout,
                         sram_be_2_dout,
                         sram_be_1_dout,
                         sram_be_0_dout};

  //------------------------------------
  // error counter
  //------------------------------------
  initial
  begin
    for (int ii=0; ii<32; ii++) begin
      err_cnt_sram        [ii] = {32{1'b0}};
      err_cnt_dp1r1w      [ii] = {32{1'b0}};
      err_cnt_dp2r2w      [ii] = {32{1'b0}};
      err_cnt_rf          [ii] = {32{1'b0}};
      err_cnt_sram_be     [ii] = {32{1'b0}};
      err_cnt_dp1r1w_be   [ii] = {32{1'b0}};
      err_cnt_dp2r2w_be   [ii] = {32{1'b0}};
      err_cnt_rf_be       [ii] = {32{1'b0}};
    end
  end

  //------------------------------------
  // status/control
  //------------------------------------
  initial
  begin
    for (int ii=0; ii<32; ii++) begin
      // STATUS[0]: CLEAR status flag
      status_clear_sram[ii]         = 1'b1;
      status_clear_dp1r1w[ii]       = 1'b1;
      status_clear_dp2r2w[ii]       = 1'b1;
      status_clear_rf[ii]           = 1'b1;
      status_clear_sram_be[ii]      = 1'b1;
      status_clear_dp1r1w_be[ii]    = 1'b1;
      status_clear_dp2r2w_be[ii]    = 1'b1;
      status_clear_rf_be[ii]        = 1'b1;

      // STATUS[1]: PASS/FAIL status flag
      status_test_pass_sram[ii]         = 1'b1;
      status_test_pass_dp1r1w[ii]       = 1'b1;
      status_test_pass_dp2r2w[ii]       = 1'b1;
      status_test_pass_rf[ii]           = 1'b1;
      status_test_pass_sram_be[ii]      = 1'b1;
      status_test_pass_dp1r1w_be[ii]    = 1'b1;
      status_test_pass_dp2r2w_be[ii]    = 1'b1;
      status_test_pass_rf_be[ii]        = 1'b1;

      // STATUS[2]: RUNNING/DONE status flag
      status_test_done_sram[ii]         = 1'b1;
      status_test_done_dp1r1w[ii]       = 1'b1;
      status_test_done_dp2r2w[ii]       = 1'b1;
      status_test_done_rf[ii]           = 1'b1;
      status_test_done_sram_be[ii]      = 1'b1;
      status_test_done_dp1r1w_be[ii]    = 1'b1;
      status_test_done_dp2r2w_be[ii]    = 1'b1;
      status_test_done_rf_be[ii]        = 1'b1;

      // CONTROL[3]: RESET/SCRUB RAM
      reset_sram[ii]         = 1'b0;
      reset_dp1r1w[ii]       = 1'b0;
      reset_dp2r2w[ii]       = 1'b0;
      reset_rf[ii]           = 1'b0;
      reset_sram_be[ii]      = 1'b0;
      reset_dp1r1w_be[ii]    = 1'b0;
      reset_dp2r2w_be[ii]    = 1'b0;
      reset_rf_be[ii]        = 1'b0;

      // CONTROL[4]: START TRIGGER
      test_start_sram[ii]         = 1'b0;
      test_start_dp1r1w[ii]       = 1'b0;
      test_start_dp2r2w[ii]       = 1'b0;
      test_start_rf[ii]           = 1'b0;
      test_start_sram_be[ii]      = 1'b0;
      test_start_dp1r1w_be[ii]    = 1'b0;
      test_start_dp2r2w_be[ii]    = 1'b0;
      test_start_rf_be[ii]        = 1'b0;

      // CONTROL[5]: Algorithm Walking 0
      algorithm_w0_sram[ii]         = 1'b0;
      algorithm_w0_dp1r1w[ii]       = 1'b0;
      algorithm_w0_dp2r2w[ii]       = 1'b0;
      algorithm_w0_rf[ii]           = 1'b0;
      algorithm_w0_sram_be[ii]      = 1'b0;
      algorithm_w0_dp1r1w_be[ii]    = 1'b0;
      algorithm_w0_dp2r2w_be[ii]    = 1'b0;
      algorithm_w0_rf_be[ii]        = 1'b0;

      // CONTROL[6]: Algorithm Walking 1
      algorithm_w1_sram[ii]         = 1'b0;
      algorithm_w1_dp1r1w[ii]       = 1'b0;
      algorithm_w1_dp2r2w[ii]       = 1'b0;
      algorithm_w1_rf[ii]           = 1'b0;
      algorithm_w1_sram_be[ii]      = 1'b0;
      algorithm_w1_dp1r1w_be[ii]    = 1'b0;
      algorithm_w1_dp2r2w_be[ii]    = 1'b0;
      algorithm_w1_rf_be[ii]        = 1'b0;

      // CONTROL[7]: Algorithm unique data
      algorithm_data_sram[ii]         = 1'b0;
      algorithm_data_dp1r1w[ii]       = 1'b0;
      algorithm_data_dp2r2w[ii]       = 1'b0;
      algorithm_data_rf[ii]           = 1'b0;
      algorithm_data_sram_be[ii]      = 1'b0;
      algorithm_data_dp1r1w_be[ii]    = 1'b0;
      algorithm_data_dp2r2w_be[ii]    = 1'b0;
      algorithm_data_rf_be[ii]        = 1'b0;
    end

  end // initial





  //
  assign status_clear_master =
                               (&status_clear_sram        ) &
                               (&status_clear_dp1r1w      ) &
                               (&status_clear_dp2r2w      ) &
                               (&status_clear_rf          ) &
                               (&status_clear_sram_be     ) &
                               (&status_clear_dp1r1w_be   ) &
                               (&status_clear_dp2r2w_be   ) &
                               (&status_clear_rf_be       );

  //
  assign status_test_pass_master =
                                   (&status_test_pass_sram        ) &
                                   (&status_test_pass_dp1r1w      ) &
                                   (&status_test_pass_dp2r2w      ) &
                                   (&status_test_pass_rf          ) &
                                   (&status_test_pass_sram_be     ) &
                                   (&status_test_pass_dp1r1w_be   ) &
                                   (&status_test_pass_dp2r2w_be   ) &
                                   (&status_test_pass_rf_be       );

  //
  assign status_test_done_master =
                                   (&status_test_done_sram        ) &
                                   (&status_test_done_dp1r1w      ) &
                                   (&status_test_done_dp2r2w      ) &
                                   (&status_test_done_rf          ) &
                                   (&status_test_done_sram_be     ) &
                                   (&status_test_done_dp1r1w_be   ) &
                                   (&status_test_done_dp2r2w_be   ) &
                                   (&status_test_done_rf_be       );

  always @(*)
  begin
    for (int ii=0; ii<32; ii++) begin
      reset_sram[ii]         = (master_ctrl_reg[3] | ctrl_reg_sram[ii][3]);
      reset_dp1r1w[ii]       = (master_ctrl_reg[3] | ctrl_reg_dp1r1w[ii][3]);
      reset_dp2r2w[ii]       = (master_ctrl_reg[3] | ctrl_reg_dp2r2w[ii][3]);
      reset_rf[ii]           = (master_ctrl_reg[3] | ctrl_reg_rf[ii][3]);
      reset_sram_be[ii]      = (master_ctrl_reg[3] | ctrl_reg_sram_be[ii][3]);
      reset_dp1r1w_be[ii]    = (master_ctrl_reg[3] | ctrl_reg_dp1r1w_be[ii][3]);
      reset_dp2r2w_be[ii]    = (master_ctrl_reg[3] | ctrl_reg_dp2r2w_be[ii][3]);
      reset_rf_be[ii]        = (master_ctrl_reg[3] | ctrl_reg_rf_be[ii][3]);
    end
  end

  always @(*)
  begin
    for (int ii=0; ii<32; ii++) begin
      test_start_sram[ii]         = (master_ctrl_reg[4] | ctrl_reg_sram[ii][4]);
      test_start_dp1r1w[ii]       = (master_ctrl_reg[4] | ctrl_reg_dp1r1w[ii][4]);
      test_start_dp2r2w[ii]       = (master_ctrl_reg[4] | ctrl_reg_dp2r2w[ii][4]);
      test_start_rf[ii]           = (master_ctrl_reg[4] | ctrl_reg_rf[ii][4]);
      test_start_sram_be[ii]      = (master_ctrl_reg[4] | ctrl_reg_sram_be[ii][4]);
      test_start_dp1r1w_be[ii]    = (master_ctrl_reg[4] | ctrl_reg_dp1r1w_be[ii][4]);
      test_start_dp2r2w_be[ii]    = (master_ctrl_reg[4] | ctrl_reg_dp2r2w_be[ii][4]);
      test_start_rf_be[ii]        = (master_ctrl_reg[4] | ctrl_reg_rf_be[ii][4]);
    end
  end

  always @(*)
  begin
    for (int ii=0; ii<32; ii++) begin
      algorithm_w0_sram[ii]         = (master_ctrl_reg[5] | ctrl_reg_sram[ii][5]);
      algorithm_w0_dp1r1w[ii]       = (master_ctrl_reg[5] | ctrl_reg_dp1r1w[ii][5]);
      algorithm_w0_dp2r2w[ii]       = (master_ctrl_reg[5] | ctrl_reg_dp2r2w[ii][5]);
      algorithm_w0_rf[ii]           = (master_ctrl_reg[5] | ctrl_reg_rf[ii][5]);
      algorithm_w0_sram_be[ii]      = (master_ctrl_reg[5] | ctrl_reg_sram_be[ii][5]);
      algorithm_w0_dp1r1w_be[ii]    = (master_ctrl_reg[5] | ctrl_reg_dp1r1w_be[ii][5]);
      algorithm_w0_dp2r2w_be[ii]    = (master_ctrl_reg[5] | ctrl_reg_dp2r2w_be[ii][5]);
      algorithm_w0_rf_be[ii]        = (master_ctrl_reg[5] | ctrl_reg_rf_be[ii][5]);
    end
  end

  always @(*)
  begin
    for (int ii=0; ii<32; ii++) begin
      algorithm_w1_sram[ii]         = (master_ctrl_reg[6] | ctrl_reg_sram[ii][6]);
      algorithm_w1_dp1r1w[ii]       = (master_ctrl_reg[6] | ctrl_reg_dp1r1w[ii][6]);
      algorithm_w1_dp2r2w[ii]       = (master_ctrl_reg[6] | ctrl_reg_dp2r2w[ii][6]);
      algorithm_w1_rf[ii]           = (master_ctrl_reg[6] | ctrl_reg_rf[ii][6]);
      algorithm_w1_sram_be[ii]      = (master_ctrl_reg[6] | ctrl_reg_sram_be[ii][6]);
      algorithm_w1_dp1r1w_be[ii]    = (master_ctrl_reg[6] | ctrl_reg_dp1r1w_be[ii][6]);
      algorithm_w1_dp2r2w_be[ii]    = (master_ctrl_reg[6] | ctrl_reg_dp2r2w_be[ii][6]);
      algorithm_w1_rf_be[ii]        = (master_ctrl_reg[6] | ctrl_reg_rf_be[ii][6]);
    end
  end

  always @(*)
  begin
    for (int ii=0; ii<32; ii++) begin
      algorithm_data_sram[ii]         = (master_ctrl_reg[7] | ctrl_reg_sram[ii][7]);
      algorithm_data_dp1r1w[ii]       = (master_ctrl_reg[7] | ctrl_reg_dp1r1w[ii][7]);
      algorithm_data_dp2r2w[ii]       = (master_ctrl_reg[7] | ctrl_reg_dp2r2w[ii][7]);
      algorithm_data_rf[ii]           = (master_ctrl_reg[7] | ctrl_reg_rf[ii][7]);
      algorithm_data_sram_be[ii]      = (master_ctrl_reg[7] | ctrl_reg_sram_be[ii][7]);
      algorithm_data_dp1r1w_be[ii]    = (master_ctrl_reg[7] | ctrl_reg_dp1r1w_be[ii][7]);
      algorithm_data_dp2r2w_be[ii]    = (master_ctrl_reg[7] | ctrl_reg_dp2r2w_be[ii][7]);
      algorithm_data_rf_be[ii]        = (master_ctrl_reg[7] | ctrl_reg_rf_be[ii][7]);
    end
  end



  //------------------------------------
  // registers
  //------------------------------------
  always @(posedge pclk or negedge presetn)
  begin : REG_PROC
    if (~presetn) begin
      prdata            <= 32'd0;
      pready            <= 1'b0;

      default_reg       <= 32'hDEADC0DE;

      master_ctrl_reg       <= 32'd0;

      num_sram_reg          <= 32'd0;
      num_dp1r1w_reg        <= 32'd0;
      num_dp2r2w_reg        <= 32'd0;
      num_rf_reg            <= 32'd0;
      num_sram_be_reg       <= 32'd0;
      num_dp1r1w_be_reg     <= 32'd0;
      num_dp2r2w_be_reg     <= 32'd0;
      num_rf_be_reg         <= 32'd0;

      for (int ii=0; ii<32; ii++) begin
        ctrl_reg_sram         [ii] = {32{1'b0}};
        ctrl_reg_dp1r1w       [ii] = {32{1'b0}};
        ctrl_reg_dp2r2w       [ii] = {32{1'b0}};
        ctrl_reg_rf           [ii] = {32{1'b0}};
        ctrl_reg_sram_be      [ii] = {32{1'b0}};
        ctrl_reg_dp1r1w_be    [ii] = {32{1'b0}};
        ctrl_reg_dp2r2w_be    [ii] = {32{1'b0}};
        ctrl_reg_rf_be        [ii] = {32{1'b0}};
      end

    end
    else begin
      // write to regs number of RAMs
      num_sram_reg          <= NUM_SRAM;
      num_dp1r1w_reg        <= NUM_DP1R1W;
      num_dp2r2w_reg        <= NUM_DP2R2W;
      num_rf_reg            <= NUM_RF;
      num_sram_be_reg       <= NUM_SRAM_BE;
      num_dp1r1w_be_reg     <= NUM_DP1R1W_BE;
      num_dp2r2w_be_reg     <= NUM_DP2R2W_BE;
      num_rf_be_reg         <= NUM_RF_BE;

      // STATUS[0]: CLEAR status flag
      master_ctrl_reg[0]              <= status_clear_master;
      for (int ii=0; ii<32; ii++) begin
        ctrl_reg_sram[ii][0]          <= status_clear_sram[ii];
        ctrl_reg_dp1r1w[ii][0]        <= status_clear_dp1r1w[ii];
        ctrl_reg_dp2r2w[ii][0]        <= status_clear_dp2r2w[ii];
        ctrl_reg_rf[ii][0]            <= status_clear_rf[ii];
        ctrl_reg_sram_be[ii][0]       <= status_clear_sram_be[ii];
        ctrl_reg_dp1r1w_be[ii][0]     <= status_clear_dp1r1w_be[ii];
        ctrl_reg_dp2r2w_be[ii][0]     <= status_clear_dp2r2w_be[ii];
        ctrl_reg_rf_be[ii][0]         <= status_clear_rf_be[ii];
      end

      // STATUS[1]: PASS/FAIL status flag
      master_ctrl_reg[1]              <= status_test_pass_master;
      for (int ii=0; ii<32; ii++) begin
        ctrl_reg_sram[ii][1]          <= status_test_pass_sram[ii];
        ctrl_reg_dp1r1w[ii][1]        <= status_test_pass_dp1r1w[ii];
        ctrl_reg_dp2r2w[ii][1]        <= status_test_pass_dp2r2w[ii];
        ctrl_reg_rf[ii][1]            <= status_test_pass_rf[ii];
        ctrl_reg_sram_be[ii][1]       <= status_test_pass_sram_be[ii];
        ctrl_reg_dp1r1w_be[ii][1]     <= status_test_pass_dp1r1w_be[ii];
        ctrl_reg_dp2r2w_be[ii][1]     <= status_test_pass_dp2r2w_be[ii];
        ctrl_reg_rf_be[ii][1]         <= status_test_pass_rf_be[ii];
      end

      // STATUS[2]: RUNNING/DONE status flag
      master_ctrl_reg[2]              <= status_test_done_master;
      for (int ii=0; ii<32; ii++) begin
        ctrl_reg_sram[ii][2]          <= status_test_done_sram[ii];
        ctrl_reg_dp1r1w[ii][2]        <= status_test_done_dp1r1w[ii];
        ctrl_reg_dp2r2w[ii][2]        <= status_test_done_dp2r2w[ii];
        ctrl_reg_rf[ii][2]            <= status_test_done_rf[ii];
        ctrl_reg_sram_be[ii][2]       <= status_test_done_sram_be[ii];
        ctrl_reg_dp1r1w_be[ii][2]     <= status_test_done_dp1r1w_be[ii];
        ctrl_reg_dp2r2w_be[ii][2]     <= status_test_done_dp2r2w_be[ii];
        ctrl_reg_rf_be[ii][2]         <= status_test_done_rf_be[ii];
      end

      // clearing up RESET/SCRUB bit
      // CONTROL[3]: RESET/SCRUB RAM
      if (master_ctrl_reg[3]              == 1'b1)  master_ctrl_reg[3]           <= 1'b0;
      for (int ii=0; ii<32; ii++) begin
        if (ctrl_reg_sram[ii][3]          == 1'b1)  ctrl_reg_sram[ii][3]         <= 1'b0;
        if (ctrl_reg_dp1r1w[ii][3]        == 1'b1)  ctrl_reg_dp1r1w[ii][3]       <= 1'b0;
        if (ctrl_reg_dp2r2w[ii][3]        == 1'b1)  ctrl_reg_dp2r2w[ii][3]       <= 1'b0;
        if (ctrl_reg_rf[ii][3]            == 1'b1)  ctrl_reg_rf[ii][3]           <= 1'b0;
        if (ctrl_reg_sram_be[ii][3]       == 1'b1)  ctrl_reg_sram_be[ii][3]      <= 1'b0;
        if (ctrl_reg_dp1r1w_be[ii][3]     == 1'b1)  ctrl_reg_dp1r1w_be[ii][3]    <= 1'b0;
        if (ctrl_reg_dp2r2w_be[ii][3]     == 1'b1)  ctrl_reg_dp2r2w_be[ii][3]    <= 1'b0;
        if (ctrl_reg_rf_be[ii][3]         == 1'b1)  ctrl_reg_rf_be[ii][3]        <= 1'b0;
      end

      // clearing up START bit
      // CONTROL[4]: START trigger
      if (master_ctrl_reg[4]              == 1'b1)  master_ctrl_reg[4]           <= 1'b0;
      for (int ii=0; ii<32; ii++) begin
        if (ctrl_reg_sram[ii][4]          == 1'b1)  ctrl_reg_sram[ii][4]         <= 1'b0;
        if (ctrl_reg_dp1r1w[ii][4]        == 1'b1)  ctrl_reg_dp1r1w[ii][4]       <= 1'b0;
        if (ctrl_reg_dp2r2w[ii][4]        == 1'b1)  ctrl_reg_dp2r2w[ii][4]       <= 1'b0;
        if (ctrl_reg_rf[ii][4]            == 1'b1)  ctrl_reg_rf[ii][4]           <= 1'b0;
        if (ctrl_reg_sram_be[ii][4]       == 1'b1)  ctrl_reg_sram_be[ii][4]      <= 1'b0;
        if (ctrl_reg_dp1r1w_be[ii][4]     == 1'b1)  ctrl_reg_dp1r1w_be[ii][4]    <= 1'b0;
        if (ctrl_reg_dp2r2w_be[ii][4]     == 1'b1)  ctrl_reg_dp2r2w_be[ii][4]    <= 1'b0;
        if (ctrl_reg_rf_be[ii][4]         == 1'b1)  ctrl_reg_rf_be[ii][4]        <= 1'b0;
      end

      // address decoder

      if (psel) begin
        // WRITE to REGS
        if (pwrite) begin
          case (paddr[APB_PADDR_WD-1:0])
            //MASTER APB Bank
            `MASTER_APB_REG_BLOCK_MASTER_CTRL_REG_REG_ADDR          : master_ctrl_reg     <= pwdata;
            //TEST FUNCTION APB Bank
            //  SRAM_CTRL_REG 0-31
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG0_REG_ADDR       : ctrl_reg_sram[0]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG1_REG_ADDR       : ctrl_reg_sram[1]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG2_REG_ADDR       : ctrl_reg_sram[2]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG3_REG_ADDR       : ctrl_reg_sram[3]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG4_REG_ADDR       : ctrl_reg_sram[4]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG5_REG_ADDR       : ctrl_reg_sram[5]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG6_REG_ADDR       : ctrl_reg_sram[6]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG7_REG_ADDR       : ctrl_reg_sram[7]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG8_REG_ADDR       : ctrl_reg_sram[8]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG9_REG_ADDR       : ctrl_reg_sram[9]    <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG10_REG_ADDR      : ctrl_reg_sram[10]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG11_REG_ADDR      : ctrl_reg_sram[11]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG12_REG_ADDR      : ctrl_reg_sram[12]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG13_REG_ADDR      : ctrl_reg_sram[13]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG14_REG_ADDR      : ctrl_reg_sram[14]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG15_REG_ADDR      : ctrl_reg_sram[15]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG16_REG_ADDR      : ctrl_reg_sram[16]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG17_REG_ADDR      : ctrl_reg_sram[17]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG18_REG_ADDR      : ctrl_reg_sram[18]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG19_REG_ADDR      : ctrl_reg_sram[19]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG20_REG_ADDR      : ctrl_reg_sram[20]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG21_REG_ADDR      : ctrl_reg_sram[21]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG22_REG_ADDR      : ctrl_reg_sram[22]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG23_REG_ADDR      : ctrl_reg_sram[23]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG24_REG_ADDR      : ctrl_reg_sram[24]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG25_REG_ADDR      : ctrl_reg_sram[25]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG26_REG_ADDR      : ctrl_reg_sram[26]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG27_REG_ADDR      : ctrl_reg_sram[27]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG28_REG_ADDR      : ctrl_reg_sram[28]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG29_REG_ADDR      : ctrl_reg_sram[29]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG30_REG_ADDR      : ctrl_reg_sram[30]   <= pwdata;
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG31_REG_ADDR      : ctrl_reg_sram[31]   <= pwdata;
            //  DP1R1W_CTRL_REG 0-31
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG0_REG_ADDR   : ctrl_reg_dp1r1w[0]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG1_REG_ADDR   : ctrl_reg_dp1r1w[1]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG2_REG_ADDR   : ctrl_reg_dp1r1w[2]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG3_REG_ADDR   : ctrl_reg_dp1r1w[3]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG4_REG_ADDR   : ctrl_reg_dp1r1w[4]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG5_REG_ADDR   : ctrl_reg_dp1r1w[5]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG6_REG_ADDR   : ctrl_reg_dp1r1w[6]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG7_REG_ADDR   : ctrl_reg_dp1r1w[7]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG8_REG_ADDR   : ctrl_reg_dp1r1w[8]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG9_REG_ADDR   : ctrl_reg_dp1r1w[9]  <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG10_REG_ADDR  : ctrl_reg_dp1r1w[10] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG11_REG_ADDR  : ctrl_reg_dp1r1w[11] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG12_REG_ADDR  : ctrl_reg_dp1r1w[12] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG13_REG_ADDR  : ctrl_reg_dp1r1w[13] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG14_REG_ADDR  : ctrl_reg_dp1r1w[14] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG15_REG_ADDR  : ctrl_reg_dp1r1w[15] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG16_REG_ADDR  : ctrl_reg_dp1r1w[16] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG17_REG_ADDR  : ctrl_reg_dp1r1w[17] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG18_REG_ADDR  : ctrl_reg_dp1r1w[18] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG19_REG_ADDR  : ctrl_reg_dp1r1w[19] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG20_REG_ADDR  : ctrl_reg_dp1r1w[20] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG21_REG_ADDR  : ctrl_reg_dp1r1w[21] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG22_REG_ADDR  : ctrl_reg_dp1r1w[22] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG23_REG_ADDR  : ctrl_reg_dp1r1w[23] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG24_REG_ADDR  : ctrl_reg_dp1r1w[24] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG25_REG_ADDR  : ctrl_reg_dp1r1w[25] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG26_REG_ADDR  : ctrl_reg_dp1r1w[26] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG27_REG_ADDR  : ctrl_reg_dp1r1w[27] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG28_REG_ADDR  : ctrl_reg_dp1r1w[28] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG29_REG_ADDR  : ctrl_reg_dp1r1w[29] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG30_REG_ADDR  : ctrl_reg_dp1r1w[30] <= pwdata;
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG31_REG_ADDR  : ctrl_reg_dp1r1w[31] <= pwdata;
            //  DP2R2W_CTRL_REG 0-31
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG0_REG_ADDR   : ctrl_reg_dp2r2w[0]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG1_REG_ADDR   : ctrl_reg_dp2r2w[1]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG2_REG_ADDR   : ctrl_reg_dp2r2w[2]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG3_REG_ADDR   : ctrl_reg_dp2r2w[3]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG4_REG_ADDR   : ctrl_reg_dp2r2w[4]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG5_REG_ADDR   : ctrl_reg_dp2r2w[5]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG6_REG_ADDR   : ctrl_reg_dp2r2w[6]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG7_REG_ADDR   : ctrl_reg_dp2r2w[7]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG8_REG_ADDR   : ctrl_reg_dp2r2w[8]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG9_REG_ADDR   : ctrl_reg_dp2r2w[9]  <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG10_REG_ADDR  : ctrl_reg_dp2r2w[10] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG11_REG_ADDR  : ctrl_reg_dp2r2w[11] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG12_REG_ADDR  : ctrl_reg_dp2r2w[12] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG13_REG_ADDR  : ctrl_reg_dp2r2w[13] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG14_REG_ADDR  : ctrl_reg_dp2r2w[14] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG15_REG_ADDR  : ctrl_reg_dp2r2w[15] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG16_REG_ADDR  : ctrl_reg_dp2r2w[16] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG17_REG_ADDR  : ctrl_reg_dp2r2w[17] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG18_REG_ADDR  : ctrl_reg_dp2r2w[18] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG19_REG_ADDR  : ctrl_reg_dp2r2w[19] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG20_REG_ADDR  : ctrl_reg_dp2r2w[20] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG21_REG_ADDR  : ctrl_reg_dp2r2w[21] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG22_REG_ADDR  : ctrl_reg_dp2r2w[22] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG23_REG_ADDR  : ctrl_reg_dp2r2w[23] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG24_REG_ADDR  : ctrl_reg_dp2r2w[24] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG25_REG_ADDR  : ctrl_reg_dp2r2w[25] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG26_REG_ADDR  : ctrl_reg_dp2r2w[26] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG27_REG_ADDR  : ctrl_reg_dp2r2w[27] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG28_REG_ADDR  : ctrl_reg_dp2r2w[28] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG29_REG_ADDR  : ctrl_reg_dp2r2w[29] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG30_REG_ADDR  : ctrl_reg_dp2r2w[30] <= pwdata;
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG31_REG_ADDR  : ctrl_reg_dp2r2w[31] <= pwdata;
            //  RF_CTRL_REG 0-31
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG0_REG_ADDR           : ctrl_reg_rf[0]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG1_REG_ADDR           : ctrl_reg_rf[1]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG2_REG_ADDR           : ctrl_reg_rf[2]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG3_REG_ADDR           : ctrl_reg_rf[3]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG4_REG_ADDR           : ctrl_reg_rf[4]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG5_REG_ADDR           : ctrl_reg_rf[5]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG6_REG_ADDR           : ctrl_reg_rf[6]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG7_REG_ADDR           : ctrl_reg_rf[7]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG8_REG_ADDR           : ctrl_reg_rf[8]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG9_REG_ADDR           : ctrl_reg_rf[9]      <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG10_REG_ADDR          : ctrl_reg_rf[10]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG11_REG_ADDR          : ctrl_reg_rf[11]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG12_REG_ADDR          : ctrl_reg_rf[12]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG13_REG_ADDR          : ctrl_reg_rf[13]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG14_REG_ADDR          : ctrl_reg_rf[14]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG15_REG_ADDR          : ctrl_reg_rf[15]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG16_REG_ADDR          : ctrl_reg_rf[16]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG17_REG_ADDR          : ctrl_reg_rf[17]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG18_REG_ADDR          : ctrl_reg_rf[18]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG19_REG_ADDR          : ctrl_reg_rf[19]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG20_REG_ADDR          : ctrl_reg_rf[20]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG21_REG_ADDR          : ctrl_reg_rf[21]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG22_REG_ADDR          : ctrl_reg_rf[22]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG23_REG_ADDR          : ctrl_reg_rf[23]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG24_REG_ADDR          : ctrl_reg_rf[24]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG25_REG_ADDR          : ctrl_reg_rf[25]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG26_REG_ADDR          : ctrl_reg_rf[26]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG27_REG_ADDR          : ctrl_reg_rf[27]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG28_REG_ADDR          : ctrl_reg_rf[28]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG29_REG_ADDR          : ctrl_reg_rf[29]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG30_REG_ADDR          : ctrl_reg_rf[30]     <= pwdata;
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG31_REG_ADDR          : ctrl_reg_rf[31]     <= pwdata;

            //  SRAM_BE_CTRL_REG 0-31
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG0_REG_ADDR       : ctrl_reg_sram_be[0]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG1_REG_ADDR       : ctrl_reg_sram_be[1]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG2_REG_ADDR       : ctrl_reg_sram_be[2]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG3_REG_ADDR       : ctrl_reg_sram_be[3]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG4_REG_ADDR       : ctrl_reg_sram_be[4]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG5_REG_ADDR       : ctrl_reg_sram_be[5]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG6_REG_ADDR       : ctrl_reg_sram_be[6]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG7_REG_ADDR       : ctrl_reg_sram_be[7]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG8_REG_ADDR       : ctrl_reg_sram_be[8]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG9_REG_ADDR       : ctrl_reg_sram_be[9]    <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG10_REG_ADDR      : ctrl_reg_sram_be[10]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG11_REG_ADDR      : ctrl_reg_sram_be[11]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG12_REG_ADDR      : ctrl_reg_sram_be[12]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG13_REG_ADDR      : ctrl_reg_sram_be[13]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG14_REG_ADDR      : ctrl_reg_sram_be[14]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG15_REG_ADDR      : ctrl_reg_sram_be[15]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG16_REG_ADDR      : ctrl_reg_sram_be[16]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG17_REG_ADDR      : ctrl_reg_sram_be[17]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG18_REG_ADDR      : ctrl_reg_sram_be[18]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG19_REG_ADDR      : ctrl_reg_sram_be[19]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG20_REG_ADDR      : ctrl_reg_sram_be[20]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG21_REG_ADDR      : ctrl_reg_sram_be[21]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG22_REG_ADDR      : ctrl_reg_sram_be[22]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG23_REG_ADDR      : ctrl_reg_sram_be[23]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG24_REG_ADDR      : ctrl_reg_sram_be[24]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG25_REG_ADDR      : ctrl_reg_sram_be[25]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG26_REG_ADDR      : ctrl_reg_sram_be[26]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG27_REG_ADDR      : ctrl_reg_sram_be[27]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG28_REG_ADDR      : ctrl_reg_sram_be[28]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG29_REG_ADDR      : ctrl_reg_sram_be[29]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG30_REG_ADDR      : ctrl_reg_sram_be[30]   <= pwdata;
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG31_REG_ADDR      : ctrl_reg_sram_be[31]   <= pwdata;
            //  DP1R1W_BE_CTRL_REG 0-31
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG0_REG_ADDR   : ctrl_reg_dp1r1w_be[0]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG1_REG_ADDR   : ctrl_reg_dp1r1w_be[1]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG2_REG_ADDR   : ctrl_reg_dp1r1w_be[2]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG3_REG_ADDR   : ctrl_reg_dp1r1w_be[3]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG4_REG_ADDR   : ctrl_reg_dp1r1w_be[4]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG5_REG_ADDR   : ctrl_reg_dp1r1w_be[5]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG6_REG_ADDR   : ctrl_reg_dp1r1w_be[6]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG7_REG_ADDR   : ctrl_reg_dp1r1w_be[7]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG8_REG_ADDR   : ctrl_reg_dp1r1w_be[8]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG9_REG_ADDR   : ctrl_reg_dp1r1w_be[9]  <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG10_REG_ADDR  : ctrl_reg_dp1r1w_be[10] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG11_REG_ADDR  : ctrl_reg_dp1r1w_be[11] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG12_REG_ADDR  : ctrl_reg_dp1r1w_be[12] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG13_REG_ADDR  : ctrl_reg_dp1r1w_be[13] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG14_REG_ADDR  : ctrl_reg_dp1r1w_be[14] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG15_REG_ADDR  : ctrl_reg_dp1r1w_be[15] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG16_REG_ADDR  : ctrl_reg_dp1r1w_be[16] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG17_REG_ADDR  : ctrl_reg_dp1r1w_be[17] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG18_REG_ADDR  : ctrl_reg_dp1r1w_be[18] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG19_REG_ADDR  : ctrl_reg_dp1r1w_be[19] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG20_REG_ADDR  : ctrl_reg_dp1r1w_be[20] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG21_REG_ADDR  : ctrl_reg_dp1r1w_be[21] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG22_REG_ADDR  : ctrl_reg_dp1r1w_be[22] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG23_REG_ADDR  : ctrl_reg_dp1r1w_be[23] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG24_REG_ADDR  : ctrl_reg_dp1r1w_be[24] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG25_REG_ADDR  : ctrl_reg_dp1r1w_be[25] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG26_REG_ADDR  : ctrl_reg_dp1r1w_be[26] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG27_REG_ADDR  : ctrl_reg_dp1r1w_be[27] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG28_REG_ADDR  : ctrl_reg_dp1r1w_be[28] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG29_REG_ADDR  : ctrl_reg_dp1r1w_be[29] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG30_REG_ADDR  : ctrl_reg_dp1r1w_be[30] <= pwdata;
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG31_REG_ADDR  : ctrl_reg_dp1r1w_be[31] <= pwdata;
            //  DP2R2W_BE_CTRL_REG 0-31
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG0_REG_ADDR   : ctrl_reg_dp2r2w_be[0]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG1_REG_ADDR   : ctrl_reg_dp2r2w_be[1]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG2_REG_ADDR   : ctrl_reg_dp2r2w_be[2]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG3_REG_ADDR   : ctrl_reg_dp2r2w_be[3]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG4_REG_ADDR   : ctrl_reg_dp2r2w_be[4]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG5_REG_ADDR   : ctrl_reg_dp2r2w_be[5]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG6_REG_ADDR   : ctrl_reg_dp2r2w_be[6]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG7_REG_ADDR   : ctrl_reg_dp2r2w_be[7]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG8_REG_ADDR   : ctrl_reg_dp2r2w_be[8]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG9_REG_ADDR   : ctrl_reg_dp2r2w_be[9]  <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG10_REG_ADDR  : ctrl_reg_dp2r2w_be[10] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG11_REG_ADDR  : ctrl_reg_dp2r2w_be[11] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG12_REG_ADDR  : ctrl_reg_dp2r2w_be[12] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG13_REG_ADDR  : ctrl_reg_dp2r2w_be[13] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG14_REG_ADDR  : ctrl_reg_dp2r2w_be[14] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG15_REG_ADDR  : ctrl_reg_dp2r2w_be[15] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG16_REG_ADDR  : ctrl_reg_dp2r2w_be[16] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG17_REG_ADDR  : ctrl_reg_dp2r2w_be[17] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG18_REG_ADDR  : ctrl_reg_dp2r2w_be[18] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG19_REG_ADDR  : ctrl_reg_dp2r2w_be[19] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG20_REG_ADDR  : ctrl_reg_dp2r2w_be[20] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG21_REG_ADDR  : ctrl_reg_dp2r2w_be[21] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG22_REG_ADDR  : ctrl_reg_dp2r2w_be[22] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG23_REG_ADDR  : ctrl_reg_dp2r2w_be[23] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG24_REG_ADDR  : ctrl_reg_dp2r2w_be[24] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG25_REG_ADDR  : ctrl_reg_dp2r2w_be[25] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG26_REG_ADDR  : ctrl_reg_dp2r2w_be[26] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG27_REG_ADDR  : ctrl_reg_dp2r2w_be[27] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG28_REG_ADDR  : ctrl_reg_dp2r2w_be[28] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG29_REG_ADDR  : ctrl_reg_dp2r2w_be[29] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG30_REG_ADDR  : ctrl_reg_dp2r2w_be[30] <= pwdata;
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG31_REG_ADDR  : ctrl_reg_dp2r2w_be[31] <= pwdata;
            //  RF_BE_CTRL_REG 0-31
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG0_REG_ADDR           : ctrl_reg_rf_be[0]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG1_REG_ADDR           : ctrl_reg_rf_be[1]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG2_REG_ADDR           : ctrl_reg_rf_be[2]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG3_REG_ADDR           : ctrl_reg_rf_be[3]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG4_REG_ADDR           : ctrl_reg_rf_be[4]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG5_REG_ADDR           : ctrl_reg_rf_be[5]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG6_REG_ADDR           : ctrl_reg_rf_be[6]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG7_REG_ADDR           : ctrl_reg_rf_be[7]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG8_REG_ADDR           : ctrl_reg_rf_be[8]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG9_REG_ADDR           : ctrl_reg_rf_be[9]      <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG10_REG_ADDR          : ctrl_reg_rf_be[10]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG11_REG_ADDR          : ctrl_reg_rf_be[11]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG12_REG_ADDR          : ctrl_reg_rf_be[12]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG13_REG_ADDR          : ctrl_reg_rf_be[13]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG14_REG_ADDR          : ctrl_reg_rf_be[14]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG15_REG_ADDR          : ctrl_reg_rf_be[15]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG16_REG_ADDR          : ctrl_reg_rf_be[16]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG17_REG_ADDR          : ctrl_reg_rf_be[17]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG18_REG_ADDR          : ctrl_reg_rf_be[18]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG19_REG_ADDR          : ctrl_reg_rf_be[19]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG20_REG_ADDR          : ctrl_reg_rf_be[20]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG21_REG_ADDR          : ctrl_reg_rf_be[21]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG22_REG_ADDR          : ctrl_reg_rf_be[22]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG23_REG_ADDR          : ctrl_reg_rf_be[23]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG24_REG_ADDR          : ctrl_reg_rf_be[24]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG25_REG_ADDR          : ctrl_reg_rf_be[25]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG26_REG_ADDR          : ctrl_reg_rf_be[26]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG27_REG_ADDR          : ctrl_reg_rf_be[27]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG28_REG_ADDR          : ctrl_reg_rf_be[28]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG29_REG_ADDR          : ctrl_reg_rf_be[29]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG30_REG_ADDR          : ctrl_reg_rf_be[30]     <= pwdata;
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG31_REG_ADDR          : ctrl_reg_rf_be[31]     <= pwdata;

            default : default_reg <= pwdata;
          endcase
        end
        // READ from REGS
        else begin
          case (paddr[APB_PADDR_WD-1:0])
            //MASTER APB Bank
            //  MASTER CONTROL
            `MASTER_APB_REG_BLOCK_MASTER_CTRL_REG_REG_ADDR          : prdata  <=  master_ctrl_reg;
            //  NUMBER OF RAMs
            `MASTER_APB_REG_BLOCK_NUM_OF_SRAM_REG_ADDR              : prdata  <=  num_sram_reg;
            `MASTER_APB_REG_BLOCK_NUM_OF_DP1R1W_REG_ADDR            : prdata  <=  num_dp1r1w_reg;
            `MASTER_APB_REG_BLOCK_NUM_OF_DP2R2W_REG_ADDR            : prdata  <=  num_dp2r2w_reg;
            `MASTER_APB_REG_BLOCK_NUM_OF_RF_REG_ADDR                : prdata  <=  num_rf_reg;
            `MASTER_APB_REG_BLOCK_NUM_OF_SRAM_BE_REG_ADDR           : prdata  <=  num_sram_be_reg;
            `MASTER_APB_REG_BLOCK_NUM_OF_DP1R1W_BE_REG_ADDR         : prdata  <=  num_dp1r1w_be_reg;
            `MASTER_APB_REG_BLOCK_NUM_OF_DP2R2W_BE_REG_ADDR         : prdata  <=  num_dp2r2w_be_reg;
            `MASTER_APB_REG_BLOCK_NUM_OF_RF_BE_REG_ADDR             : prdata  <=  num_rf_be_reg;
            //TEST FUNCTION APB Bank
            //  SRAM_CTRL_REG 0-31
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG0_REG_ADDR       : prdata  <=  ctrl_reg_sram[0];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG1_REG_ADDR       : prdata  <=  ctrl_reg_sram[1];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG2_REG_ADDR       : prdata  <=  ctrl_reg_sram[2];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG3_REG_ADDR       : prdata  <=  ctrl_reg_sram[3];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG4_REG_ADDR       : prdata  <=  ctrl_reg_sram[4];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG5_REG_ADDR       : prdata  <=  ctrl_reg_sram[5];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG6_REG_ADDR       : prdata  <=  ctrl_reg_sram[6];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG7_REG_ADDR       : prdata  <=  ctrl_reg_sram[7];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG8_REG_ADDR       : prdata  <=  ctrl_reg_sram[8];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG9_REG_ADDR       : prdata  <=  ctrl_reg_sram[9];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG10_REG_ADDR      : prdata  <=  ctrl_reg_sram[10];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG11_REG_ADDR      : prdata  <=  ctrl_reg_sram[11];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG12_REG_ADDR      : prdata  <=  ctrl_reg_sram[12];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG13_REG_ADDR      : prdata  <=  ctrl_reg_sram[13];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG14_REG_ADDR      : prdata  <=  ctrl_reg_sram[14];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG15_REG_ADDR      : prdata  <=  ctrl_reg_sram[15];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG16_REG_ADDR      : prdata  <=  ctrl_reg_sram[16];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG17_REG_ADDR      : prdata  <=  ctrl_reg_sram[17];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG18_REG_ADDR      : prdata  <=  ctrl_reg_sram[18];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG19_REG_ADDR      : prdata  <=  ctrl_reg_sram[19];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG20_REG_ADDR      : prdata  <=  ctrl_reg_sram[20];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG21_REG_ADDR      : prdata  <=  ctrl_reg_sram[21];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG22_REG_ADDR      : prdata  <=  ctrl_reg_sram[22];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG23_REG_ADDR      : prdata  <=  ctrl_reg_sram[23];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG24_REG_ADDR      : prdata  <=  ctrl_reg_sram[24];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG25_REG_ADDR      : prdata  <=  ctrl_reg_sram[25];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG26_REG_ADDR      : prdata  <=  ctrl_reg_sram[26];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG27_REG_ADDR      : prdata  <=  ctrl_reg_sram[27];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG28_REG_ADDR      : prdata  <=  ctrl_reg_sram[28];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG29_REG_ADDR      : prdata  <=  ctrl_reg_sram[29];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG30_REG_ADDR      : prdata  <=  ctrl_reg_sram[30];
            `SRAM_TEST_FUNC_REG_BLOCK_SRAM_CTRL_REG31_REG_ADDR      : prdata  <=  ctrl_reg_sram[31];
            //  DP1R1W_CTRL_REG 0-31
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG0_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[0];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG1_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[1];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG2_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[2];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG3_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[3];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG4_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[4];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG5_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[5];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG6_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[6];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG7_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[7];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG8_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[8];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG9_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w[9];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG10_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[10];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG11_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[11];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG12_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[12];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG13_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[13];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG14_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[14];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG15_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[15];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG16_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[16];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG17_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[17];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG18_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[18];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG19_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[19];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG20_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[20];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG21_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[21];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG22_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[22];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG23_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[23];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG24_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[24];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG25_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[25];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG26_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[26];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG27_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[27];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG28_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[28];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG29_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[29];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG30_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[30];
            `DP1R1W_TEST_FUNC_REG_BLOCK_DP1R1W_CTRL_REG31_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w[31];
            //  DP2R2W_CTRL_REG 0-31
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG0_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[0];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG1_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[1];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG2_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[2];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG3_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[3];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG4_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[4];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG5_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[5];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG6_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[6];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG7_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[7];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG8_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[8];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG9_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w[9];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG10_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[10];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG11_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[11];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG12_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[12];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG13_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[13];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG14_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[14];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG15_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[15];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG16_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[16];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG17_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[17];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG18_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[18];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG19_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[19];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG20_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[20];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG21_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[21];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG22_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[22];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG23_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[23];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG24_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[24];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG25_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[25];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG26_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[26];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG27_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[27];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG28_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[28];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG29_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[29];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG30_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[30];
            `DP2R2W_TEST_FUNC_REG_BLOCK_DP2R2W_CTRL_REG31_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w[31];
            //  RF_CTRL_REG 0-31
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG0_REG_ADDR           : prdata  <=  ctrl_reg_rf[0];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG1_REG_ADDR           : prdata  <=  ctrl_reg_rf[1];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG2_REG_ADDR           : prdata  <=  ctrl_reg_rf[2];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG3_REG_ADDR           : prdata  <=  ctrl_reg_rf[3];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG4_REG_ADDR           : prdata  <=  ctrl_reg_rf[4];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG5_REG_ADDR           : prdata  <=  ctrl_reg_rf[5];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG6_REG_ADDR           : prdata  <=  ctrl_reg_rf[6];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG7_REG_ADDR           : prdata  <=  ctrl_reg_rf[7];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG8_REG_ADDR           : prdata  <=  ctrl_reg_rf[8];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG9_REG_ADDR           : prdata  <=  ctrl_reg_rf[9];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG10_REG_ADDR          : prdata  <=  ctrl_reg_rf[10];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG11_REG_ADDR          : prdata  <=  ctrl_reg_rf[11];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG12_REG_ADDR          : prdata  <=  ctrl_reg_rf[12];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG13_REG_ADDR          : prdata  <=  ctrl_reg_rf[13];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG14_REG_ADDR          : prdata  <=  ctrl_reg_rf[14];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG15_REG_ADDR          : prdata  <=  ctrl_reg_rf[15];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG16_REG_ADDR          : prdata  <=  ctrl_reg_rf[16];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG17_REG_ADDR          : prdata  <=  ctrl_reg_rf[17];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG18_REG_ADDR          : prdata  <=  ctrl_reg_rf[18];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG19_REG_ADDR          : prdata  <=  ctrl_reg_rf[19];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG20_REG_ADDR          : prdata  <=  ctrl_reg_rf[20];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG21_REG_ADDR          : prdata  <=  ctrl_reg_rf[21];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG22_REG_ADDR          : prdata  <=  ctrl_reg_rf[22];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG23_REG_ADDR          : prdata  <=  ctrl_reg_rf[23];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG24_REG_ADDR          : prdata  <=  ctrl_reg_rf[24];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG25_REG_ADDR          : prdata  <=  ctrl_reg_rf[25];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG26_REG_ADDR          : prdata  <=  ctrl_reg_rf[26];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG27_REG_ADDR          : prdata  <=  ctrl_reg_rf[27];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG28_REG_ADDR          : prdata  <=  ctrl_reg_rf[28];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG29_REG_ADDR          : prdata  <=  ctrl_reg_rf[29];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG30_REG_ADDR          : prdata  <=  ctrl_reg_rf[30];
            `RF_TEST_FUNC_REG_BLOCK_RF_CTRL_REG31_REG_ADDR          : prdata  <=  ctrl_reg_rf[31];

            //  SRAM_BE_CTRL_REG 0-31
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG0_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[0];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG1_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[1];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG2_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[2];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG3_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[3];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG4_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[4];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG5_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[5];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG6_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[6];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG7_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[7];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG8_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[8];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG9_REG_ADDR       : prdata  <=  ctrl_reg_sram_be[9];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG10_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[10];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG11_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[11];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG12_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[12];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG13_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[13];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG14_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[14];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG15_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[15];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG16_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[16];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG17_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[17];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG18_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[18];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG19_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[19];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG20_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[20];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG21_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[21];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG22_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[22];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG23_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[23];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG24_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[24];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG25_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[25];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG26_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[26];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG27_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[27];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG28_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[28];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG29_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[29];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG30_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[30];
            `SRAM_BE_TEST_FUNC_REG_BLOCK_SRAM_BE_CTRL_REG31_REG_ADDR      : prdata  <=  ctrl_reg_sram_be[31];
            //  DP1R1W_BE_CTRL_REG 0-31
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG0_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[0];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG1_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[1];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG2_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[2];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG3_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[3];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG4_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[4];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG5_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[5];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG6_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[6];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG7_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[7];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG8_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[8];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG9_REG_ADDR   : prdata  <=  ctrl_reg_dp1r1w_be[9];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG10_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[10];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG11_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[11];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG12_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[12];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG13_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[13];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG14_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[14];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG15_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[15];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG16_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[16];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG17_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[17];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG18_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[18];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG19_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[19];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG20_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[20];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG21_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[21];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG22_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[22];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG23_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[23];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG24_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[24];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG25_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[25];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG26_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[26];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG27_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[27];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG28_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[28];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG29_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[29];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG30_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[30];
            `DP1R1W_BE_TEST_FUNC_REG_BLOCK_DP1R1W_BE_CTRL_REG31_REG_ADDR  : prdata  <=  ctrl_reg_dp1r1w_be[31];
            //  DP2R2W_BE_CTRL_REG 0-31
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG0_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[0];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG1_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[1];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG2_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[2];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG3_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[3];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG4_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[4];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG5_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[5];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG6_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[6];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG7_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[7];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG8_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[8];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG9_REG_ADDR   : prdata  <=  ctrl_reg_dp2r2w_be[9];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG10_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[10];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG11_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[11];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG12_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[12];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG13_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[13];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG14_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[14];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG15_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[15];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG16_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[16];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG17_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[17];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG18_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[18];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG19_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[19];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG20_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[20];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG21_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[21];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG22_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[22];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG23_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[23];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG24_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[24];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG25_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[25];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG26_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[26];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG27_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[27];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG28_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[28];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG29_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[29];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG30_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[30];
            `DP2R2W_BE_TEST_FUNC_REG_BLOCK_DP2R2W_BE_CTRL_REG31_REG_ADDR  : prdata  <=  ctrl_reg_dp2r2w_be[31];
            //  RF_BE_CTRL_REG 0-31
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG0_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[0];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG1_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[1];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG2_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[2];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG3_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[3];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG4_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[4];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG5_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[5];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG6_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[6];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG7_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[7];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG8_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[8];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG9_REG_ADDR           : prdata  <=  ctrl_reg_rf_be[9];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG10_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[10];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG11_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[11];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG12_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[12];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG13_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[13];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG14_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[14];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG15_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[15];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG16_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[16];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG17_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[17];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG18_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[18];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG19_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[19];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG20_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[20];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG21_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[21];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG22_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[22];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG23_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[23];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG24_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[24];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG25_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[25];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG26_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[26];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG27_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[27];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG28_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[28];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG29_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[29];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG30_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[30];
            `RF_BE_TEST_FUNC_REG_BLOCK_RF_BE_CTRL_REG31_REG_ADDR          : prdata  <=  ctrl_reg_rf_be[31];

            default : prdata  <=  default_reg;
          endcase
        end
        pready <= 1'b1;
      end //psel
      else begin
        prdata <= 32'd0;
        pready <= 1'b0;
      end
    end

  end // REG_PROC

  assign pslverr = 1'b0;
  assign interrupt = 1'b0;



  //------------------------------------
  // INTERFACEs SRAM
  //------------------------------------
  // sram_intf[0..31]
  genvar i0;
  generate
    for (i0=0; i0<NUM_SRAM; i0++) begin : test_sram_blk
      cdn_demo_ram_integration_sram_intf #(SRAM_ADDR_WD_ARRAY[i0], SRAM_DATA_WD_ARRAY[i0]) sram_intf  (sram_clk[i0]);
      assign sram_addr[SRAM_ADDR_WD_START_ARRAY[i0] +: SRAM_ADDR_WD_ARRAY[i0]] = sram_intf.addr;  // Address    (input)
      assign sram_din [SRAM_DATA_WD_START_ARRAY[i0] +: SRAM_DATA_WD_ARRAY[i0]] = sram_intf.din;   // Write Data (input)
      assign sram_en[i0]                                                       = sram_intf.en;    // Enable     (input)
      assign sram_we[i0]                                                       = sram_intf.we;    // Direction  (input)
      assign sram_intf.dout = sram_dout[SRAM_DATA_WD_START_ARRAY[i0] +: SRAM_DATA_WD_ARRAY[i0]];  // Read Data  (output)
    end
  endgenerate
  genvar j0;
  generate
    for (j0=NUM_SRAM; j0<32; j0++) begin : sram_tieoffs
      assign sram_addr[SRAM_ADDR_WD_START_ARRAY[j0] +: SRAM_ADDR_WD_ARRAY[j0]] = 0;  // Address    (input)
      assign sram_din [SRAM_DATA_WD_START_ARRAY[j0] +: SRAM_DATA_WD_ARRAY[j0]] = 0;  // Write Data (input)
      assign sram_en[j0]                                                       = 0;  // Enable     (input)
      assign sram_we[j0]                                                       = 0;  // Direction  (input)
    end
  endgenerate

  //------------------------------------
  // INTERFACEs DP1R1W
  //------------------------------------
  // dp1r1w_intf[0..31]
  genvar i1;
  generate
    for (i1=0; i1<NUM_DP1R1W; i1++) begin : test_dp1r1w_blk
      cdn_demo_ram_integration_dp1r1w_intf #(DP1R1W_ADDR_WD_ARRAY[i1], DP1R1W_DATA_WD_ARRAY[i1]) dp1r1w_intf  (dp1r1w_clka[i1], dp1r1w_clkb[i1]);
      assign dp1r1w_addra[DP1R1W_ADDR_WD_START_ARRAY[i1] +: DP1R1W_ADDR_WD_ARRAY[i1]] = dp1r1w_intf.addra;   // Address    (input)
      assign dp1r1w_addrb[DP1R1W_ADDR_WD_START_ARRAY[i1] +: DP1R1W_ADDR_WD_ARRAY[i1]] = dp1r1w_intf.addrb;   // Address    (input)
      assign dp1r1w_dina [DP1R1W_DATA_WD_START_ARRAY[i1] +: DP1R1W_DATA_WD_ARRAY[i1]] = dp1r1w_intf.dina;    // Write Data (input)
      assign dp1r1w_ena[i1]                                                           = dp1r1w_intf.ena;     // Enable     (input)
      assign dp1r1w_enb[i1]                                                           = dp1r1w_intf.enb;     // Enable     (input)
      assign dp1r1w_wea[i1]                                                           = dp1r1w_intf.wea;     // Direction  (input)
      assign dp1r1w_intf.doutb = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[i1] +: DP1R1W_DATA_WD_ARRAY[i1]];   // Read Data  (output)
    end
  endgenerate
  genvar j1;
  generate
    for (j1=NUM_DP1R1W; j1<32; j1++) begin : dp1r1w_tieoffs
      assign dp1r1w_addra[DP1R1W_ADDR_WD_START_ARRAY[j1] +: DP1R1W_ADDR_WD_ARRAY[j1]] = 0;   // Address    (input)
      assign dp1r1w_addrb[DP1R1W_ADDR_WD_START_ARRAY[j1] +: DP1R1W_ADDR_WD_ARRAY[j1]] = 0;   // Address    (input)
      assign dp1r1w_dina [DP1R1W_DATA_WD_START_ARRAY[j1] +: DP1R1W_DATA_WD_ARRAY[j1]] = 0;   // Write Data (input)
      assign dp1r1w_ena[j1]                                                           = 0;   // Enable     (input)
      assign dp1r1w_enb[j1]                                                           = 0;   // Enable     (input)
      assign dp1r1w_wea[j1]                                                           = 0;   // Direction  (input)
    end
  endgenerate

  //------------------------------------
  // INTERFACEs SRAM (BE) with byte enables
  //------------------------------------
  // sram_be_intf[0..31]
  genvar i2;
  generate
    for (i2=0; i2<NUM_SRAM_BE; i2++) begin : test_sram_be_blk
      cdn_demo_ram_integration_sram_be_intf #(SRAM_BE_ADDR_WD_ARRAY[i2], SRAM_BE_DATA_WD_ARRAY[i2]) sram_be_intf  (sram_be_clk[i2]);
      assign sram_be_addr[SRAM_BE_ADDR_WD_START_ARRAY[i2]   +: SRAM_BE_ADDR_WD_ARRAY[i2]]   = sram_be_intf.addr; // Address     (input)
      assign sram_be_din [SRAM_BE_DATA_WD_START_ARRAY[i2]   +: SRAM_BE_DATA_WD_ARRAY[i2]]   = sram_be_intf.din;  // Write Data  (input)
      assign sram_be_ben [SRAM_BE_DATA_WD_START_ARRAY[i2]/8 +: SRAM_BE_DATA_WD_ARRAY[i2]/8] = sram_be_intf.ben;  // Byte Enable (input)
      assign sram_be_en[i2]                                                                 = sram_be_intf.en;   // Enable      (input)
      assign sram_be_we[i2]                                                                 = sram_be_intf.we;   // Direction   (input)
      assign sram_be_intf.dout = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[i2] +: SRAM_BE_DATA_WD_ARRAY[i2]];     // Read Data   (output)
    end
  endgenerate
  genvar j2;
  generate
    for (j2=NUM_SRAM_BE; j2<32; j2++) begin : sram_be_tieoffs
      assign sram_be_addr[SRAM_BE_ADDR_WD_START_ARRAY[j2]   +: SRAM_BE_ADDR_WD_ARRAY[j2]]    = 0;  // Address     (input)
      assign sram_be_din [SRAM_BE_DATA_WD_START_ARRAY[j2]   +: SRAM_BE_DATA_WD_ARRAY[j2]]    = 0;  // Write Data  (input)
      assign sram_be_ben [SRAM_BE_DATA_WD_START_ARRAY[j2]/8 +: SRAM_BE_DATA_WD_ARRAY[j2]/8]  = 0;  // Byte Enable (input)
      assign sram_be_en[j2]                                                                  = 0;  // Enable      (input)
      assign sram_be_we[j2]                                                                  = 0;  // Direction   (input)
    end
  endgenerate

  //------------------------------------
  // check if data correct
  //------------------------------------
  task check_data (input logic [127:0] addr_ch, input logic [1023:0] wdata_ch, rdata_ch, input string str_ch, output int err_status);
    if (wdata_ch != rdata_ch) begin
      err_status = 1;
      read_check : assert (wdata_ch === rdata_ch)
        else $error(">>>> %s - memory read error, wdata_ch = %x, rdata_ch = %x", str_ch, wdata_ch, rdata_ch);
    end
    else begin
      err_status = 0;
    end
  endtask // check_data

  //------------------------------------
  // Function get_smallest_of
  // Return the smallest value from the two
  // inputs
  //------------------------------------
  function int get_smallest_of(int a, int b);
    if (a<=b)
      return a;
    else
      return b;
  endfunction : get_smallest_of

  //------------------------------------
  // Function random_data
  // Return the 1024-bit random number
  //------------------------------------
  function logic[1023:0] random_data (integer DATA_WD);
    begin
      random_data = {1024{1'b0}};
      for (int ii=0; ii < DATA_WD; ii++) begin
        random_data[ii] = $urandom;
      end
    end
  endfunction : random_data


  //------------------------------------
  // SRAM test
  //------------------------------------
  // SRAM[0..31]
  genvar jj;
  generate
    for (jj=0; jj<NUM_SRAM; jj++) begin : SRAM_TEST
      initial
      begin
      static int ram_index = jj;
      localparam READ_DELAY = (jj == 0 ) ? SRAM0_READ_DELAY
                            : (jj == 1 ) ? SRAM1_READ_DELAY
                            : (jj == 2 ) ? SRAM2_READ_DELAY
                            : (jj == 3 ) ? SRAM3_READ_DELAY
                            : (jj == 4 ) ? SRAM4_READ_DELAY
                            : (jj == 5 ) ? SRAM5_READ_DELAY
                            : (jj == 6 ) ? SRAM6_READ_DELAY
                            : (jj == 7 ) ? SRAM7_READ_DELAY
                            : (jj == 8 ) ? SRAM8_READ_DELAY
                            : (jj == 9 ) ? SRAM9_READ_DELAY
                            : (jj == 10) ? SRAM10_READ_DELAY
                            : (jj == 11) ? SRAM11_READ_DELAY
                            : (jj == 12) ? SRAM12_READ_DELAY
                            : (jj == 13) ? SRAM13_READ_DELAY
                            : (jj == 14) ? SRAM14_READ_DELAY
                            : (jj == 15) ? SRAM15_READ_DELAY
                            : (jj == 16) ? SRAM16_READ_DELAY
                            : (jj == 17) ? SRAM17_READ_DELAY
                            : (jj == 18) ? SRAM18_READ_DELAY
                            : (jj == 19) ? SRAM19_READ_DELAY
                            : (jj == 20) ? SRAM20_READ_DELAY
                            : (jj == 21) ? SRAM21_READ_DELAY
                            : (jj == 22) ? SRAM22_READ_DELAY
                            : (jj == 23) ? SRAM23_READ_DELAY
                            : (jj == 24) ? SRAM24_READ_DELAY
                            : (jj == 25) ? SRAM25_READ_DELAY
                            : (jj == 26) ? SRAM26_READ_DELAY
                            : (jj == 27) ? SRAM27_READ_DELAY
                            : (jj == 28) ? SRAM28_READ_DELAY
                            : (jj == 29) ? SRAM29_READ_DELAY
                            : (jj == 30) ? SRAM30_READ_DELAY
                            : (jj == 31) ? SRAM31_READ_DELAY
                            /* default */   : 0 ;
      localparam ADDR_WD = (jj == 0 ) ? SRAM0_ADDR_WD
                         : (jj == 1 ) ? SRAM1_ADDR_WD
                         : (jj == 2 ) ? SRAM2_ADDR_WD
                         : (jj == 3 ) ? SRAM3_ADDR_WD
                         : (jj == 4 ) ? SRAM4_ADDR_WD
                         : (jj == 5 ) ? SRAM5_ADDR_WD
                         : (jj == 6 ) ? SRAM6_ADDR_WD
                         : (jj == 7 ) ? SRAM7_ADDR_WD
                         : (jj == 8 ) ? SRAM8_ADDR_WD
                         : (jj == 9 ) ? SRAM9_ADDR_WD
                         : (jj == 10) ? SRAM10_ADDR_WD
                         : (jj == 11) ? SRAM11_ADDR_WD
                         : (jj == 12) ? SRAM12_ADDR_WD
                         : (jj == 13) ? SRAM13_ADDR_WD
                         : (jj == 14) ? SRAM14_ADDR_WD
                         : (jj == 15) ? SRAM15_ADDR_WD
                         : (jj == 16) ? SRAM16_ADDR_WD
                         : (jj == 17) ? SRAM17_ADDR_WD
                         : (jj == 18) ? SRAM18_ADDR_WD
                         : (jj == 19) ? SRAM19_ADDR_WD
                         : (jj == 20) ? SRAM20_ADDR_WD
                         : (jj == 21) ? SRAM21_ADDR_WD
                         : (jj == 22) ? SRAM22_ADDR_WD
                         : (jj == 23) ? SRAM23_ADDR_WD
                         : (jj == 24) ? SRAM24_ADDR_WD
                         : (jj == 25) ? SRAM25_ADDR_WD
                         : (jj == 26) ? SRAM26_ADDR_WD
                         : (jj == 27) ? SRAM27_ADDR_WD
                         : (jj == 28) ? SRAM28_ADDR_WD
                         : (jj == 29) ? SRAM29_ADDR_WD
                         : (jj == 30) ? SRAM30_ADDR_WD
                         : (jj == 31) ? SRAM31_ADDR_WD
                         /* default */   : 1 ;
      localparam DATA_WD = (jj == 0 ) ? SRAM0_DATA_WD
                         : (jj == 1 ) ? SRAM1_DATA_WD
                         : (jj == 2 ) ? SRAM2_DATA_WD
                         : (jj == 3 ) ? SRAM3_DATA_WD
                         : (jj == 4 ) ? SRAM4_DATA_WD
                         : (jj == 5 ) ? SRAM5_DATA_WD
                         : (jj == 6 ) ? SRAM6_DATA_WD
                         : (jj == 7 ) ? SRAM7_DATA_WD
                         : (jj == 8 ) ? SRAM8_DATA_WD
                         : (jj == 9 ) ? SRAM9_DATA_WD
                         : (jj == 10) ? SRAM10_DATA_WD
                         : (jj == 11) ? SRAM11_DATA_WD
                         : (jj == 12) ? SRAM12_DATA_WD
                         : (jj == 13) ? SRAM13_DATA_WD
                         : (jj == 14) ? SRAM14_DATA_WD
                         : (jj == 15) ? SRAM15_DATA_WD
                         : (jj == 16) ? SRAM16_DATA_WD
                         : (jj == 17) ? SRAM17_DATA_WD
                         : (jj == 18) ? SRAM18_DATA_WD
                         : (jj == 19) ? SRAM19_DATA_WD
                         : (jj == 20) ? SRAM20_DATA_WD
                         : (jj == 21) ? SRAM21_DATA_WD
                         : (jj == 22) ? SRAM22_DATA_WD
                         : (jj == 23) ? SRAM23_DATA_WD
                         : (jj == 24) ? SRAM24_DATA_WD
                         : (jj == 25) ? SRAM25_DATA_WD
                         : (jj == 26) ? SRAM26_DATA_WD
                         : (jj == 27) ? SRAM27_DATA_WD
                         : (jj == 28) ? SRAM28_DATA_WD
                         : (jj == 29) ? SRAM29_DATA_WD
                         : (jj == 30) ? SRAM30_DATA_WD
                         : (jj == 31) ? SRAM31_DATA_WD
                         /* default */   : 1 ;
      localparam DEPTH   = (jj == 0 ) ? SRAM0_DEPTH
                         : (jj == 1 ) ? SRAM1_DEPTH
                         : (jj == 2 ) ? SRAM2_DEPTH
                         : (jj == 3 ) ? SRAM3_DEPTH
                         : (jj == 4 ) ? SRAM4_DEPTH
                         : (jj == 5 ) ? SRAM5_DEPTH
                         : (jj == 6 ) ? SRAM6_DEPTH
                         : (jj == 7 ) ? SRAM7_DEPTH
                         : (jj == 8 ) ? SRAM8_DEPTH
                         : (jj == 9 ) ? SRAM9_DEPTH
                         : (jj == 10) ? SRAM10_DEPTH
                         : (jj == 11) ? SRAM11_DEPTH
                         : (jj == 12) ? SRAM12_DEPTH
                         : (jj == 13) ? SRAM13_DEPTH
                         : (jj == 14) ? SRAM14_DEPTH
                         : (jj == 15) ? SRAM15_DEPTH
                         : (jj == 16) ? SRAM16_DEPTH
                         : (jj == 17) ? SRAM17_DEPTH
                         : (jj == 18) ? SRAM18_DEPTH
                         : (jj == 19) ? SRAM19_DEPTH
                         : (jj == 20) ? SRAM20_DEPTH
                         : (jj == 21) ? SRAM21_DEPTH
                         : (jj == 22) ? SRAM22_DEPTH
                         : (jj == 23) ? SRAM23_DEPTH
                         : (jj == 24) ? SRAM24_DEPTH
                         : (jj == 25) ? SRAM25_DEPTH
                         : (jj == 26) ? SRAM26_DEPTH
                         : (jj == 27) ? SRAM27_DEPTH
                         : (jj == 28) ? SRAM28_DEPTH
                         : (jj == 29) ? SRAM29_DEPTH
                         : (jj == 30) ? SRAM30_DEPTH
                         : (jj == 31) ? SRAM31_DEPTH
                         /* default */   : 1<<ADDR_WD ;
      localparam HOLDDATA = (jj == 0 ) ? SRAM0_HOLDDATA
                          : (jj == 1 ) ? SRAM1_HOLDDATA
                          : (jj == 2 ) ? SRAM2_HOLDDATA
                          : (jj == 3 ) ? SRAM3_HOLDDATA
                          : (jj == 4 ) ? SRAM4_HOLDDATA
                          : (jj == 5 ) ? SRAM5_HOLDDATA
                          : (jj == 6 ) ? SRAM6_HOLDDATA
                          : (jj == 7 ) ? SRAM7_HOLDDATA
                          : (jj == 8 ) ? SRAM8_HOLDDATA
                          : (jj == 9 ) ? SRAM9_HOLDDATA
                          : (jj == 10) ? SRAM10_HOLDDATA
                          : (jj == 11) ? SRAM11_HOLDDATA
                          : (jj == 12) ? SRAM12_HOLDDATA
                          : (jj == 13) ? SRAM13_HOLDDATA
                          : (jj == 14) ? SRAM14_HOLDDATA
                          : (jj == 15) ? SRAM15_HOLDDATA
                          : (jj == 16) ? SRAM16_HOLDDATA
                          : (jj == 17) ? SRAM17_HOLDDATA
                          : (jj == 18) ? SRAM18_HOLDDATA
                          : (jj == 19) ? SRAM19_HOLDDATA
                          : (jj == 20) ? SRAM20_HOLDDATA
                          : (jj == 21) ? SRAM21_HOLDDATA
                          : (jj == 22) ? SRAM22_HOLDDATA
                          : (jj == 23) ? SRAM23_HOLDDATA
                          : (jj == 24) ? SRAM24_HOLDDATA
                          : (jj == 25) ? SRAM25_HOLDDATA
                          : (jj == 26) ? SRAM26_HOLDDATA
                          : (jj == 27) ? SRAM27_HOLDDATA
                          : (jj == 28) ? SRAM28_HOLDDATA
                          : (jj == 29) ? SRAM29_HOLDDATA
                          : (jj == 30) ? SRAM30_HOLDDATA
                          : (jj == 31) ? SRAM31_HOLDDATA
                          /* default */   : 1 ;
      reg [ADDR_WD-1:0] addr;
      reg [DATA_WD-1:0] wdata;
      reg [DATA_WD-1:0] rdata;
      static int err_sts = 0;

      @(posedge presetn);
      forever begin
        @(test_start_sram[ram_index] == 1'b1);
        // status flag
        status_clear_sram[ram_index]     = 0;
        status_test_done_sram[ram_index] = 0;
        status_test_pass_sram[ram_index] = 0;

        //**************************************************************
        // RESET
        //**************************************************************
        if (reset_sram[ram_index]==1'b1) begin
          static string str_rst = $psprintf(">>>> SRAM[%s]: RESET",SRAM_NAME[jj]);
          wdata = {DATA_WD{1'b0}};

          //------------------------------
          // Walking 1 on ADDR, DATA=0..0
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting RESET Walking 1 on ADDR, DATA=0 test on SRAM[%s]",SRAM_NAME[jj]);
          for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
            addr  = ii[ADDR_WD-1:0];
            if (addr < DEPTH) begin
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end

          test_sram_blk[jj].sram_intf.delay(10);
          //------------------------------
          // Walking 0 on ADDR, DATA=0..0
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting RESET Walking 0 on ADDR, DATA=0 test on SRAM[%s]",SRAM_NAME[jj]);
          for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
            addr  = ~(ii[ADDR_WD-1:0]);
            if (addr < DEPTH) begin
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end

          test_sram_blk[jj].sram_intf.delay(10);
          //------------------------------
          // DATA
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting RESET DATA test on SRAM[%s]",SRAM_NAME[jj]);
          if ((1<<ADDR_WD) < (1<<6)) begin    // < 64
            for (int ii=0; ii<(1<<ADDR_WD); ii++) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
                test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end
          end
          else if ((1<<ADDR_WD) >= (1<<6)) begin   // >= 64
            for (int ii=0; ii<(1<<6); ii++) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
                test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<6)) begin   // >= 64 // <= 4 096
            for (int ii=(1<<6); ii<get_smallest_of(DEPTH,(1<<12)); ii=ii+(1<<6)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end
          if ((1<<ADDR_WD) >= (1<<12)) begin  // >= 4 096 // <= 262 144
            for (int ii=(1<<12); ii<get_smallest_of(DEPTH,(1<<18)); ii=ii+(1<<12)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end
          if ((1<<ADDR_WD) >= (1<<18)) begin  // >= 262 144 // <= 16 777 216
            for (int ii=(1<<18); ii<get_smallest_of(DEPTH,(1<<24)); ii=ii+(1<<18)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end
          if ((1<<ADDR_WD) >= (1<<24)) begin  // >= 16 777 216  // <= 1 073 741 824
            for (int ii=(1<<24); ii<get_smallest_of(DEPTH,(1<<30)); ii=ii+(1<<24)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end
          if ((1<<ADDR_WD) >= (1<<30)) begin  // >= 1 073 741 824  // <= 68 719 476 735
            for (int ii=(1<<30); ii<get_smallest_of(DEPTH,(1<<36)); ii=ii+(1<<30)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end

          // STATUS: clear
          status_clear_sram[ram_index] = 1;
        end // if (reset_sram[ram_index]==1'b1)


        //**************************************************************
        // Walking 1
        //**************************************************************
        if (algorithm_w1_sram[ram_index]==1'b1) begin
          static string str_w1a = $psprintf(">>>> SRAM[%s]: Walking 1 ADDR",SRAM_NAME[jj]);
          static string str_w1d = $psprintf(">>>> SRAM[%s]: Walking 1 DATA",SRAM_NAME[jj]);

          test_sram_blk[jj].sram_intf.delay(20);
          //------------------------------
          // Walking 1 on ADDR bus
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting Walking 1 on SRAM bus test on DP1R1W[%s]",SRAM_NAME[jj]);
          for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
            addr  = ii[ADDR_WD-1:0];  // walking 1
            if (addr < DEPTH) begin
              wdata = random_data(DATA_WD)[DATA_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                              // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                          // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_w1a, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;      // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(3);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_w1a, err_sts);                         // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
              //
              wdata = {DATA_WD{1'b0}};  // DATA=0..0
              test_sram_blk[jj].sram_intf.write(addr,wdata);                              // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                          // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_w1a, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;      // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(4);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_w1a, err_sts);                         // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end
          end // Walking 1 on ADDR bus

          test_sram_blk[jj].sram_intf.delay(10);
          //------------------------------
          // Walking 1 on DATA bus
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting Walking 1 on DATA bus test on SRAM[%s]",SRAM_NAME[jj]);
          for (reg [1024:0] ii=1; ii<(1<<DATA_WD); ii=ii<<1) begin
            addr  = {ADDR_WD{1'b0}};  // ADDR=0..0
            wdata = ii[DATA_WD-1:0];  // walking 1
            test_sram_blk[jj].sram_intf.write(addr,wdata);                              // WRITE
            test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                          // READ
            rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
            check_data(addr, wdata, rdata, str_w1d, err_sts);                           // CHECK_DATA
            if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;      // ERR_STS
            if (HOLDDATA==1) begin
              test_sram_blk[jj].sram_intf.delay(3);
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_w1d, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end // Walking 1 on DATA bus
        end // if (algorithm_w1_sram[ram_index]==1'b1)


        //**************************************************************
        // Walking 0
        //**************************************************************
        if (algorithm_w0_sram[ram_index]==1'b1) begin
          static string str_w0a = $psprintf(">>>> SRAM[%s]: Walking 0 ADDR",SRAM_NAME[jj]);
          static string str_w0d = $psprintf(">>>> SRAM[%s]: Walking 0 DATA",SRAM_NAME[jj]);

          test_sram_blk[jj].sram_intf.delay(20);
          //------------------------------
          // Walking 0 on ADDR bus
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting Walking 0 on ADDR bus test on SRAM[%s]",SRAM_NAME[jj]);
          for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
            addr  = ~(ii[ADDR_WD-1:0]); // walking 0
            if (addr < DEPTH) begin
              wdata = random_data(DATA_WD)[DATA_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                              // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                          // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_w0a, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;      // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(3);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_w0a, err_sts);                         // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
              //
              wdata = {DATA_WD{1'b0}};  // DATA=0..0
              test_sram_blk[jj].sram_intf.write(addr,wdata);                              // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                          // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_w0a, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;      // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(4);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_w0a, err_sts);                         // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end
          end // Walking 0 on ADDR bus

          test_sram_blk[jj].sram_intf.delay(10);
          //------------------------------
          // Walking 0 on DATA bus
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting Walking 0 on DATA bus test on SRAM[%s]",SRAM_NAME[jj]);
          for (reg [1024:0] ii=1; ii<(1<<DATA_WD); ii=ii<<1) begin
            addr  = {ADDR_WD{1'b0}};    // ADDR=0..0
            wdata = ~(ii[DATA_WD-1:0]); // walking 0
            test_sram_blk[jj].sram_intf.write(addr,wdata);                              // WRITE
            test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                          // READ
            rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
            check_data(addr, wdata, rdata, str_w0d, err_sts);                           // CHECK_DATA
            if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;      // ERR_STS
            if (HOLDDATA==1) begin
              test_sram_blk[jj].sram_intf.delay(3);
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_w0d, err_sts);                         // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
            end
          end // Walking 0 on DATA bus
        end // if (algorithm_w0_sram[ram_index]==1'b1)


        //**************************************************************
        // Unique DATA
        //**************************************************************
        if (algorithm_data_sram[ram_index]==1'b1) begin
          static string str_data = $psprintf(">>>> SRAM[%s]: Unique DATA",SRAM_NAME[jj]);

          test_sram_blk[jj].sram_intf.delay(20);
          if (DEBUG_LEVEL>=1) $display("Starting Unique DATA test on SRAM[%s]",SRAM_NAME[jj]);
          if ((1<<ADDR_WD) < (1<<6)) begin    // < 64
            for (int ii=0; ii<(1<<ADDR_WD); ii++) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
                test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_blk[jj].sram_intf.delay(3);
                  rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                  if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
                end
              end
            end
          end
          else if ((1<<ADDR_WD) >= (1<<6)) begin   // >= 64
            for (int ii=0; ii<(1<<6); ii++) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
                test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_blk[jj].sram_intf.delay(3);
                  rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                  if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
                end
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<6)) begin  // >= 64 // <= 4 096
            test_sram_blk[jj].sram_intf.delay(5);
            for (int ii=(1<<6); ii<get_smallest_of(DEPTH,(1<<12)); ii=ii+(1<<6)) begin
              addr  = ii[ADDR_WD-1:0];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(3);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<12)) begin  // >= 4 096 // <= 262 144
            test_sram_blk[jj].sram_intf.delay(5);
            for (int ii=(1<<12); ii<get_smallest_of(DEPTH,(1<<18)); ii=ii+(1<<12)) begin
              addr  = ii[ADDR_WD-1:0];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(3);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<18)) begin  // >= 262 144 // <= 16 777 216
            test_sram_blk[jj].sram_intf.delay(5);
            for (int ii=(1<<18); ii<get_smallest_of(DEPTH,(1<<24)); ii=ii+(1<<18)) begin
              addr  = ii[ADDR_WD-1:0];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(3);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<24)) begin  // >= 16 777 216  // <= 1 073 741 824
            test_sram_blk[jj].sram_intf.delay(5);
            for (int ii=(1<<24); ii<get_smallest_of(DEPTH,(1<<30)); ii=ii+(1<<24)) begin
              addr  = ii[ADDR_WD-1:0];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(3);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<30)) begin  // >= 1 073 741 824  // <= 68 719 476 735
            test_sram_blk[jj].sram_intf.delay(5);
            for (int ii=(1<<30); ii<get_smallest_of(DEPTH,(1<<36)); ii=ii+(1<<30)) begin
              addr  = ii[ADDR_WD-1:0];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];
              test_sram_blk[jj].sram_intf.write(addr,wdata);                            // WRITE
              test_sram_blk[jj].sram_intf.read(addr,READ_DELAY);                        // READ
              rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
              check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
              if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_blk[jj].sram_intf.delay(3);
                rdata = sram_dout[SRAM_DATA_WD_START_ARRAY[jj] +: SRAM_DATA_WD_ARRAY[jj]];
                check_data(addr, wdata, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram[ram_index] = err_cnt_sram[ram_index] + 1;    // ERR_STS
              end
            end //for
          end //if ((1<<ADDR_WD) >= (1<<30))

        end //if (algorithm_data_sram[ram_index]==1'b1)

        // STATUS: test DONE
        status_test_done_sram[ram_index] = 1;

        // STATUS: test PASS
        if (err_cnt_sram[ram_index] == 0) begin
          status_test_pass_sram[ram_index] = 1;
        end
        else begin
          status_test_pass_sram[ram_index] = 0;
        end
      end // forever
      end // initial
    end //for SRAM[0..31]
  endgenerate



  //------------------------------------
  // DP1R1W test
  //------------------------------------
  // DP1R1W[0..31]
  genvar kk;
  generate
    for (kk=0; kk<NUM_DP1R1W; kk++) begin : DP1R1W_TEST
      initial
      begin
      static int ram_index = kk;
      localparam READ_DELAY = (kk == 0 ) ? DP1R1W0_READ_DELAY
                            : (kk == 1 ) ? DP1R1W1_READ_DELAY
                            : (kk == 2 ) ? DP1R1W2_READ_DELAY
                            : (kk == 3 ) ? DP1R1W3_READ_DELAY
                            : (kk == 4 ) ? DP1R1W4_READ_DELAY
                            : (kk == 5 ) ? DP1R1W5_READ_DELAY
                            : (kk == 6 ) ? DP1R1W6_READ_DELAY
                            : (kk == 7 ) ? DP1R1W7_READ_DELAY
                            : (kk == 8 ) ? DP1R1W8_READ_DELAY
                            : (kk == 9 ) ? DP1R1W9_READ_DELAY
                            : (kk == 10) ? DP1R1W10_READ_DELAY
                            : (kk == 11) ? DP1R1W11_READ_DELAY
                            : (kk == 12) ? DP1R1W12_READ_DELAY
                            : (kk == 13) ? DP1R1W13_READ_DELAY
                            : (kk == 14) ? DP1R1W14_READ_DELAY
                            : (kk == 15) ? DP1R1W15_READ_DELAY
                            : (kk == 16) ? DP1R1W16_READ_DELAY
                            : (kk == 17) ? DP1R1W17_READ_DELAY
                            : (kk == 18) ? DP1R1W18_READ_DELAY
                            : (kk == 19) ? DP1R1W19_READ_DELAY
                            : (kk == 20) ? DP1R1W20_READ_DELAY
                            : (kk == 21) ? DP1R1W21_READ_DELAY
                            : (kk == 22) ? DP1R1W22_READ_DELAY
                            : (kk == 23) ? DP1R1W23_READ_DELAY
                            : (kk == 24) ? DP1R1W24_READ_DELAY
                            : (kk == 25) ? DP1R1W25_READ_DELAY
                            : (kk == 26) ? DP1R1W26_READ_DELAY
                            : (kk == 27) ? DP1R1W27_READ_DELAY
                            : (kk == 28) ? DP1R1W28_READ_DELAY
                            : (kk == 29) ? DP1R1W29_READ_DELAY
                            : (kk == 30) ? DP1R1W30_READ_DELAY
                            : (kk == 31) ? DP1R1W31_READ_DELAY
                            /* default */   : 0 ;
      localparam ADDR_WD = (kk == 0 ) ? DP1R1W0_ADDR_WD
                         : (kk == 1 ) ? DP1R1W1_ADDR_WD
                         : (kk == 2 ) ? DP1R1W2_ADDR_WD
                         : (kk == 3 ) ? DP1R1W3_ADDR_WD
                         : (kk == 4 ) ? DP1R1W4_ADDR_WD
                         : (kk == 5 ) ? DP1R1W5_ADDR_WD
                         : (kk == 6 ) ? DP1R1W6_ADDR_WD
                         : (kk == 7 ) ? DP1R1W7_ADDR_WD
                         : (kk == 8 ) ? DP1R1W8_ADDR_WD
                         : (kk == 9 ) ? DP1R1W9_ADDR_WD
                         : (kk == 10) ? DP1R1W10_ADDR_WD
                         : (kk == 11) ? DP1R1W11_ADDR_WD
                         : (kk == 12) ? DP1R1W12_ADDR_WD
                         : (kk == 13) ? DP1R1W13_ADDR_WD
                         : (kk == 14) ? DP1R1W14_ADDR_WD
                         : (kk == 15) ? DP1R1W15_ADDR_WD
                         : (kk == 16) ? DP1R1W16_ADDR_WD
                         : (kk == 17) ? DP1R1W17_ADDR_WD
                         : (kk == 18) ? DP1R1W18_ADDR_WD
                         : (kk == 19) ? DP1R1W19_ADDR_WD
                         : (kk == 20) ? DP1R1W20_ADDR_WD
                         : (kk == 21) ? DP1R1W21_ADDR_WD
                         : (kk == 22) ? DP1R1W22_ADDR_WD
                         : (kk == 23) ? DP1R1W23_ADDR_WD
                         : (kk == 24) ? DP1R1W24_ADDR_WD
                         : (kk == 25) ? DP1R1W25_ADDR_WD
                         : (kk == 26) ? DP1R1W26_ADDR_WD
                         : (kk == 27) ? DP1R1W27_ADDR_WD
                         : (kk == 28) ? DP1R1W28_ADDR_WD
                         : (kk == 29) ? DP1R1W29_ADDR_WD
                         : (kk == 30) ? DP1R1W30_ADDR_WD
                         : (kk == 31) ? DP1R1W31_ADDR_WD
                         /* default */   : 1 ;
      localparam DATA_WD = (kk == 0 ) ? DP1R1W0_DATA_WD
                         : (kk == 1 ) ? DP1R1W1_DATA_WD
                         : (kk == 2 ) ? DP1R1W2_DATA_WD
                         : (kk == 3 ) ? DP1R1W3_DATA_WD
                         : (kk == 4 ) ? DP1R1W4_DATA_WD
                         : (kk == 5 ) ? DP1R1W5_DATA_WD
                         : (kk == 6 ) ? DP1R1W6_DATA_WD
                         : (kk == 7 ) ? DP1R1W7_DATA_WD
                         : (kk == 8 ) ? DP1R1W8_DATA_WD
                         : (kk == 9 ) ? DP1R1W9_DATA_WD
                         : (kk == 10) ? DP1R1W10_DATA_WD
                         : (kk == 11) ? DP1R1W11_DATA_WD
                         : (kk == 12) ? DP1R1W12_DATA_WD
                         : (kk == 13) ? DP1R1W13_DATA_WD
                         : (kk == 14) ? DP1R1W14_DATA_WD
                         : (kk == 15) ? DP1R1W15_DATA_WD
                         : (kk == 16) ? DP1R1W16_DATA_WD
                         : (kk == 17) ? DP1R1W17_DATA_WD
                         : (kk == 18) ? DP1R1W18_DATA_WD
                         : (kk == 19) ? DP1R1W19_DATA_WD
                         : (kk == 20) ? DP1R1W20_DATA_WD
                         : (kk == 21) ? DP1R1W21_DATA_WD
                         : (kk == 22) ? DP1R1W22_DATA_WD
                         : (kk == 23) ? DP1R1W23_DATA_WD
                         : (kk == 24) ? DP1R1W24_DATA_WD
                         : (kk == 25) ? DP1R1W25_DATA_WD
                         : (kk == 26) ? DP1R1W26_DATA_WD
                         : (kk == 27) ? DP1R1W27_DATA_WD
                         : (kk == 28) ? DP1R1W28_DATA_WD
                         : (kk == 29) ? DP1R1W29_DATA_WD
                         : (kk == 30) ? DP1R1W30_DATA_WD
                         : (kk == 31) ? DP1R1W31_DATA_WD
                         /* default */   : 1 ;
      localparam DEPTH   = (kk == 0 ) ? DP1R1W0_DEPTH
                         : (kk == 1 ) ? DP1R1W1_DEPTH
                         : (kk == 2 ) ? DP1R1W2_DEPTH
                         : (kk == 3 ) ? DP1R1W3_DEPTH
                         : (kk == 4 ) ? DP1R1W4_DEPTH
                         : (kk == 5 ) ? DP1R1W5_DEPTH
                         : (kk == 6 ) ? DP1R1W6_DEPTH
                         : (kk == 7 ) ? DP1R1W7_DEPTH
                         : (kk == 8 ) ? DP1R1W8_DEPTH
                         : (kk == 9 ) ? DP1R1W9_DEPTH
                         : (kk == 10) ? DP1R1W10_DEPTH
                         : (kk == 11) ? DP1R1W11_DEPTH
                         : (kk == 12) ? DP1R1W12_DEPTH
                         : (kk == 13) ? DP1R1W13_DEPTH
                         : (kk == 14) ? DP1R1W14_DEPTH
                         : (kk == 15) ? DP1R1W15_DEPTH
                         : (kk == 16) ? DP1R1W16_DEPTH
                         : (kk == 17) ? DP1R1W17_DEPTH
                         : (kk == 18) ? DP1R1W18_DEPTH
                         : (kk == 19) ? DP1R1W19_DEPTH
                         : (kk == 20) ? DP1R1W20_DEPTH
                         : (kk == 21) ? DP1R1W21_DEPTH
                         : (kk == 22) ? DP1R1W22_DEPTH
                         : (kk == 23) ? DP1R1W23_DEPTH
                         : (kk == 24) ? DP1R1W24_DEPTH
                         : (kk == 25) ? DP1R1W25_DEPTH
                         : (kk == 26) ? DP1R1W26_DEPTH
                         : (kk == 27) ? DP1R1W27_DEPTH
                         : (kk == 28) ? DP1R1W28_DEPTH
                         : (kk == 29) ? DP1R1W29_DEPTH
                         : (kk == 30) ? DP1R1W30_DEPTH
                         : (kk == 31) ? DP1R1W31_DEPTH
                         /* default */   : 1 ;
      localparam HOLDDATA = (kk == 0 ) ? DP1R1W0_HOLDDATA
                          : (kk == 1 ) ? DP1R1W1_HOLDDATA
                          : (kk == 2 ) ? DP1R1W2_HOLDDATA
                          : (kk == 3 ) ? DP1R1W3_HOLDDATA
                          : (kk == 4 ) ? DP1R1W4_HOLDDATA
                          : (kk == 5 ) ? DP1R1W5_HOLDDATA
                          : (kk == 6 ) ? DP1R1W6_HOLDDATA
                          : (kk == 7 ) ? DP1R1W7_HOLDDATA
                          : (kk == 8 ) ? DP1R1W8_HOLDDATA
                          : (kk == 9 ) ? DP1R1W9_HOLDDATA
                          : (kk == 10) ? DP1R1W10_HOLDDATA
                          : (kk == 11) ? DP1R1W11_HOLDDATA
                          : (kk == 12) ? DP1R1W12_HOLDDATA
                          : (kk == 13) ? DP1R1W13_HOLDDATA
                          : (kk == 14) ? DP1R1W14_HOLDDATA
                          : (kk == 15) ? DP1R1W15_HOLDDATA
                          : (kk == 16) ? DP1R1W16_HOLDDATA
                          : (kk == 17) ? DP1R1W17_HOLDDATA
                          : (kk == 18) ? DP1R1W18_HOLDDATA
                          : (kk == 19) ? DP1R1W19_HOLDDATA
                          : (kk == 20) ? DP1R1W20_HOLDDATA
                          : (kk == 21) ? DP1R1W21_HOLDDATA
                          : (kk == 22) ? DP1R1W22_HOLDDATA
                          : (kk == 23) ? DP1R1W23_HOLDDATA
                          : (kk == 24) ? DP1R1W24_HOLDDATA
                          : (kk == 25) ? DP1R1W25_HOLDDATA
                          : (kk == 26) ? DP1R1W26_HOLDDATA
                          : (kk == 27) ? DP1R1W27_HOLDDATA
                          : (kk == 28) ? DP1R1W28_HOLDDATA
                          : (kk == 29) ? DP1R1W29_HOLDDATA
                          : (kk == 30) ? DP1R1W30_HOLDDATA
                          : (kk == 31) ? DP1R1W31_HOLDDATA
                          /* default */   : 1 ;
        reg [ADDR_WD-1:0] addr;
        reg [DATA_WD-1:0] wdata;
        reg [DATA_WD-1:0] rdata;
        static int err_sts = 0;

        @(posedge presetn);
        forever begin
          @(test_start_dp1r1w[ram_index] == 1'b1);
          // status flag
          status_clear_dp1r1w[ram_index]     = 0;
          status_test_done_dp1r1w[ram_index] = 0;
          status_test_pass_dp1r1w[ram_index] = 0;

          //**************************************************************
          // RESET
          //**************************************************************
          if (reset_dp1r1w[ram_index]==1'b1) begin
            static string str_rst = $psprintf(">>>> DP1R1W[%s]: RESET",DP1R1W_NAME[kk]);
            wdata = {DATA_WD{1'b0}};

            //------------------------------
            // Walking 1 on ADDR, DATA=0..0
            //------------------------------
            if (DEBUG_LEVEL>=1) $display("Starting RESET Walking 1 on ADDR, DATA=0 test on DP1R1W[%s]",DP1R1W_NAME[kk]);
            for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              end
            end

            test_dp1r1w_blk[kk].dp1r1w_intf.delay(10);
            //------------------------------
            // Walking 0 on ADDR, DATA=0..0
            //------------------------------
            if (DEBUG_LEVEL>=1) $display("Starting RESET Walking 0 on ADDR, DATA=0 test on DP1R1W[%s]",DP1R1W_NAME[kk]);
            for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
              addr  = ~(ii[ADDR_WD-1:0]);
              if (addr < DEPTH) begin
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              end
            end

            test_dp1r1w_blk[kk].dp1r1w_intf.delay(10);
            //------------------------------
            // DATA
            //------------------------------
            if (DEBUG_LEVEL>=1) $display("Starting RESET DATA test on DP1R1W[%s]",DP1R1W_NAME[kk]);
            if ((1<<ADDR_WD) < (1<<6)) begin    // < 64
              for (int ii=0; ii<(1<<ADDR_WD); ii++) begin
                addr  = ii[ADDR_WD-1:0];
                if (addr < DEPTH) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                  test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                end
              end
            end
            else if ((1<<ADDR_WD) >= (1<<6)) begin   // >= 64
              for (int ii=0; ii<(1<<6); ii++) begin
                addr  = ii[ADDR_WD-1:0];
                if (addr < DEPTH) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                  test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                end
              end
            end
            if ((1<<ADDR_WD) >= (1<<6)) begin   // >= 64 // <= 4 096
              for (int ii=(1<<6); ii<get_smallest_of(DEPTH,(1<<12)); ii=ii+(1<<6)) begin
                addr  = ii[ADDR_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              end
            end
            if ((1<<ADDR_WD) >= (1<<12)) begin  // >= 4 096 // <= 262 144
              for (int ii=(1<<12); ii<get_smallest_of(DEPTH,(1<<18)); ii=ii+(1<<12)) begin
                addr  = ii[ADDR_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              end
            end
            if ((1<<ADDR_WD) >= (1<<18)) begin  // >= 262 144 // <= 16 777 216
              for (int ii=(1<<18); ii<get_smallest_of(DEPTH,(1<<24)); ii=ii+(1<<18)) begin
                addr  = ii[ADDR_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              end
            end
            if ((1<<ADDR_WD) >= (1<<24)) begin  // >= 16 777 216  // <= 1 073 741 824
              for (int ii=(1<<24); ii<get_smallest_of(DEPTH,(1<<30)); ii=ii+(1<<24)) begin
                addr  = ii[ADDR_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              end
            end
            if ((1<<ADDR_WD) >= (1<<30)) begin  // >= 1 073 741 824  // <= 68 719 476 735
              for (int ii=(1<<30); ii<get_smallest_of(DEPTH,(1<<36)); ii=ii+(1<<30)) begin
                addr  = ii[ADDR_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              end
            end

            // STATUS: clear
            status_clear_dp1r1w[ram_index] = 1;
          end // if (reset_dp1r1w[ram_index]==1'b1)


          //**************************************************************
          // Walking 1
          //**************************************************************
          if (algorithm_w1_dp1r1w[ram_index]==1'b1) begin
            static string str_w1a = $psprintf(">>>> DP1R1W[%s]: Walking 1 ADDR",DP1R1W_NAME[kk]);
            static string str_w1d = $psprintf(">>>> DP1R1W[%s]: Walking 1 DATA",DP1R1W_NAME[kk]);

            test_dp1r1w_blk[kk].dp1r1w_intf.delay(20);
            //------------------------------
            // Walking 1 on ADDR bus
            //------------------------------
            if (DEBUG_LEVEL>=1) $display("Starting Walking 1 on ADDR bus test on DP1R1W[%s]",DP1R1W_NAME[kk]);
            for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
              addr  = ii[ADDR_WD-1:0];  // walking 1
              if (addr < DEPTH) begin
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_w1a, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_w1a, err_sts);                               // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
                //
                wdata = {DATA_WD{1'b0}};  // DATA=0..0
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_w1a, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(4);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_w1a, err_sts);                               // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
              end
            end // Walking 1 on ADDR bus

            test_dp1r1w_blk[kk].dp1r1w_intf.delay(10);
            //------------------------------
            // Walking 1 on DATA bus
            //------------------------------
            if (DEBUG_LEVEL>=1) $display("Starting Walking 1 on DATA bus test on DP1R1W[%s]",DP1R1W_NAME[kk]);
            for (reg [1024:0] ii=1; ii<(1<<DATA_WD); ii=ii<<1) begin
              addr  = {ADDR_WD{1'b0}};  // ADDR=0..0
              wdata = ii[DATA_WD-1:0];  // walking 1
              test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
              test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
              rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
              check_data(addr, wdata, rdata, str_w1d, err_sts);                                 // CHECK_DATA
              if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              if (HOLDDATA==1) begin
                test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_w1d, err_sts);                               // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
              end
            end // Walking 1 on DATA bus
          end // if (algorithm_w1_dp1r1w[ram_index]==1'b1)


          //**************************************************************
          // Walking 0
          //**************************************************************
          if (algorithm_w0_dp1r1w[ram_index]==1'b1) begin
            static string str_w0a = $psprintf(">>>> DP1R1W[%s]: Walking 0 ADDR",DP1R1W_NAME[kk]);
            static string str_w0d = $psprintf(">>>> DP1R1W[%s]: Walking 0 DATA",DP1R1W_NAME[kk]);

            test_dp1r1w_blk[kk].dp1r1w_intf.delay(20);
            //------------------------------
            // Walking 0 on ADDR bus
            //------------------------------
            if (DEBUG_LEVEL>=1) $display("Starting Walking 0 on ADDR bus test on DP1R1W[%s]",DP1R1W_NAME[kk]);
            for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
              addr  = ~(ii[ADDR_WD-1:0]); // walking 0
              if (addr < DEPTH) begin
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_w0a, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_w0a, err_sts);                               // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
                //
                wdata = {DATA_WD{1'b0}};  // DATA=0..0
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                               // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_w0a, err_sts);                                 // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(4);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_w0a, err_sts);                               // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
              end
            end // Walking 0 on ADDR bus

            test_dp1r1w_blk[kk].dp1r1w_intf.delay(10);
            //------------------------------
            // Walking 0 on DATA bus
            //------------------------------
            if (DEBUG_LEVEL>=1) $display("Starting Walking 0 on DATA bus test on DP1R1W[%s]",DP1R1W_NAME[kk]);
            for (reg [1024:0] ii=1; ii<(1<<DATA_WD); ii=ii<<1) begin
              addr  = {ADDR_WD{1'b0}};    // ADDR=0..0
              wdata = ~(ii[DATA_WD-1:0]); // walking 0
              test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
              test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
              rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
              check_data(addr, wdata, rdata, str_w0d, err_sts);                                 // CHECK_DATA
              if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
              if (HOLDDATA==1) begin
                test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_w0d, err_sts);                               // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
              end
            end // Walking 0 on DATA bus
          end // if (algorithm_w0_dp1r1w[ram_index]==1'b1)


          //**************************************************************
          // Unique DATA
          //**************************************************************
          if (algorithm_data_dp1r1w[ram_index]==1'b1) begin
            static string str_data = $psprintf(">>>> DP1R1W[%s]: Unique DATA",DP1R1W_NAME[kk]);

            test_dp1r1w_blk[kk].dp1r1w_intf.delay(20);
            if (DEBUG_LEVEL>=1) $display("Starting Unique DATA test on DP1R1W[%s]",DP1R1W_NAME[kk]);
            if ((1<<ADDR_WD) < (1<<6)) begin          // < 64
              for (int ii=0; ii<(1<<ADDR_WD); ii++) begin
                addr  = ii[ADDR_WD-1:0];
                if (addr < DEPTH) begin
                  wdata = random_data(DATA_WD)[DATA_WD-1:0];
                  test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                  test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                                // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                  if (HOLDDATA==1) begin
                    test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                    rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                    check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                    if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                  end
                end
              end
            end
            else if ((1<<ADDR_WD) >= (1<<6)) begin    // >= 64
              for (int ii=0; ii<(1<<6); ii++) begin
                addr  = ii[ADDR_WD-1:0];
                if (addr < DEPTH) begin
                  wdata = random_data(DATA_WD)[DATA_WD-1:0];
                  test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                  test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                                // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                  if (HOLDDATA==1) begin
                    test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                    rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                    check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                    if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                  end
                end
              end
            end
            if ((1<<ADDR_WD) >= (1<<6)) begin  // >= 64 // <= 4 096
              test_dp1r1w_blk[kk].dp1r1w_intf.delay(5);
              for (int ii=(1<<6); ii<get_smallest_of(DEPTH,(1<<12)); ii=ii+(1<<6)) begin
                addr  = ii[ADDR_WD-1:0];
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_data, err_sts);                                // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
              end
            end
            if ((1<<ADDR_WD) >= (1<<12)) begin  // >= 4 096 // <= 262 144
              test_dp1r1w_blk[kk].dp1r1w_intf.delay(5);
              for (int ii=(1<<12); ii<get_smallest_of(DEPTH,(1<<18)); ii=ii+(1<<12)) begin
                addr  = ii[ADDR_WD-1:0];
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_data, err_sts);                                // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
              end
            end
            if ((1<<ADDR_WD) >= (1<<18)) begin  // >= 262 144 // <= 16 777 216
              test_dp1r1w_blk[kk].dp1r1w_intf.delay(5);
              for (int ii=(1<<18); ii<get_smallest_of(DEPTH,(1<<24)); ii=ii+(1<<18)) begin
                addr  = ii[ADDR_WD-1:0];
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_data, err_sts);                                // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
              end
            end
            if ((1<<ADDR_WD) >= (1<<24)) begin  // >= 16 777 216  // <= 1 073 741 824
              test_dp1r1w_blk[kk].dp1r1w_intf.delay(5);
              for (int ii=(1<<24); ii<get_smallest_of(DEPTH,(1<<30)); ii=ii+(1<<24)) begin
                addr  = ii[ADDR_WD-1:0];
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_data, err_sts);                                // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
              end
            end
            if ((1<<ADDR_WD) >= (1<<30)) begin  // >= 1 073 741 824  // <= 68 719 476 735
              test_dp1r1w_blk[kk].dp1r1w_intf.delay(5);
              for (int ii=(1<<30); ii<get_smallest_of(DEPTH,(1<<36)); ii=ii+(1<<30)) begin
                addr  = ii[ADDR_WD-1:0];
                wdata = random_data(DATA_WD)[DATA_WD-1:0];
                test_dp1r1w_blk[kk].dp1r1w_intf.write(addr,wdata);                                // WRITE
                test_dp1r1w_blk[kk].dp1r1w_intf.read(addr,READ_DELAY);                            // READ
                rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                check_data(addr, wdata, rdata, str_data, err_sts);                                // CHECK_DATA
                if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;        // ERR_STS
                if (HOLDDATA==1) begin
                  test_dp1r1w_blk[kk].dp1r1w_intf.delay(3);
                  rdata = dp1r1w_doutb[DP1R1W_DATA_WD_START_ARRAY[kk] +: DP1R1W_DATA_WD_ARRAY[kk]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                  if (err_sts==1) err_cnt_dp1r1w[ram_index] = err_cnt_dp1r1w[ram_index] + 1;      // ERR_STS
                end
              end //for
            end //if ((1<<ADDR_WD) >= 1<<30)

          end // if (algorithm_data_dp1r1w[ram_index]==1'b1)

          // STATUS: test DONE
          status_test_done_dp1r1w[ram_index] = 1;

          // STATUS: test PASS
          if (err_cnt_dp1r1w[ram_index] == 0) begin
            status_test_pass_dp1r1w[ram_index] = 1;
          end
          else begin
            status_test_pass_dp1r1w[ram_index] = 0;
          end

        end // forever
      end // initial
    end //for DP1R1W[0..31]
  endgenerate



  //------------------------------------
  // SRAM_BE test
  //------------------------------------
  // SRAM_BE[0..31]
  genvar jj2;
  generate
    for (jj2=0; jj2<NUM_SRAM_BE; jj2++) begin : SRAM_BE_TEST
      initial
      begin
      static int ram_index = jj2;
      localparam READ_DELAY = (jj2 == 0 ) ? SRAM_BE_0_READ_DELAY
                            : (jj2 == 1 ) ? SRAM_BE_1_READ_DELAY
                            : (jj2 == 2 ) ? SRAM_BE_2_READ_DELAY
                            : (jj2 == 3 ) ? SRAM_BE_3_READ_DELAY
                            : (jj2 == 4 ) ? SRAM_BE_4_READ_DELAY
                            : (jj2 == 5 ) ? SRAM_BE_5_READ_DELAY
                            : (jj2 == 6 ) ? SRAM_BE_6_READ_DELAY
                            : (jj2 == 7 ) ? SRAM_BE_7_READ_DELAY
                            : (jj2 == 8 ) ? SRAM_BE_8_READ_DELAY
                            : (jj2 == 9 ) ? SRAM_BE_9_READ_DELAY
                            : (jj2 == 10) ? SRAM_BE_10_READ_DELAY
                            : (jj2 == 11) ? SRAM_BE_11_READ_DELAY
                            : (jj2 == 12) ? SRAM_BE_12_READ_DELAY
                            : (jj2 == 13) ? SRAM_BE_13_READ_DELAY
                            : (jj2 == 14) ? SRAM_BE_14_READ_DELAY
                            : (jj2 == 15) ? SRAM_BE_15_READ_DELAY
                            : (jj2 == 16) ? SRAM_BE_16_READ_DELAY
                            : (jj2 == 17) ? SRAM_BE_17_READ_DELAY
                            : (jj2 == 18) ? SRAM_BE_18_READ_DELAY
                            : (jj2 == 19) ? SRAM_BE_19_READ_DELAY
                            : (jj2 == 20) ? SRAM_BE_20_READ_DELAY
                            : (jj2 == 21) ? SRAM_BE_21_READ_DELAY
                            : (jj2 == 22) ? SRAM_BE_22_READ_DELAY
                            : (jj2 == 23) ? SRAM_BE_23_READ_DELAY
                            : (jj2 == 24) ? SRAM_BE_24_READ_DELAY
                            : (jj2 == 25) ? SRAM_BE_25_READ_DELAY
                            : (jj2 == 26) ? SRAM_BE_26_READ_DELAY
                            : (jj2 == 27) ? SRAM_BE_27_READ_DELAY
                            : (jj2 == 28) ? SRAM_BE_28_READ_DELAY
                            : (jj2 == 29) ? SRAM_BE_29_READ_DELAY
                            : (jj2 == 30) ? SRAM_BE_30_READ_DELAY
                            : (jj2 == 31) ? SRAM_BE_31_READ_DELAY
                            /* default */   : 0 ;
      localparam ADDR_WD = (jj2 == 0 ) ? SRAM_BE_0_ADDR_WD
                         : (jj2 == 1 ) ? SRAM_BE_1_ADDR_WD
                         : (jj2 == 2 ) ? SRAM_BE_2_ADDR_WD
                         : (jj2 == 3 ) ? SRAM_BE_3_ADDR_WD
                         : (jj2 == 4 ) ? SRAM_BE_4_ADDR_WD
                         : (jj2 == 5 ) ? SRAM_BE_5_ADDR_WD
                         : (jj2 == 6 ) ? SRAM_BE_6_ADDR_WD
                         : (jj2 == 7 ) ? SRAM_BE_7_ADDR_WD
                         : (jj2 == 8 ) ? SRAM_BE_8_ADDR_WD
                         : (jj2 == 9 ) ? SRAM_BE_9_ADDR_WD
                         : (jj2 == 10) ? SRAM_BE_10_ADDR_WD
                         : (jj2 == 11) ? SRAM_BE_11_ADDR_WD
                         : (jj2 == 12) ? SRAM_BE_12_ADDR_WD
                         : (jj2 == 13) ? SRAM_BE_13_ADDR_WD
                         : (jj2 == 14) ? SRAM_BE_14_ADDR_WD
                         : (jj2 == 15) ? SRAM_BE_15_ADDR_WD
                         : (jj2 == 16) ? SRAM_BE_16_ADDR_WD
                         : (jj2 == 17) ? SRAM_BE_17_ADDR_WD
                         : (jj2 == 18) ? SRAM_BE_18_ADDR_WD
                         : (jj2 == 19) ? SRAM_BE_19_ADDR_WD
                         : (jj2 == 20) ? SRAM_BE_20_ADDR_WD
                         : (jj2 == 21) ? SRAM_BE_21_ADDR_WD
                         : (jj2 == 22) ? SRAM_BE_22_ADDR_WD
                         : (jj2 == 23) ? SRAM_BE_23_ADDR_WD
                         : (jj2 == 24) ? SRAM_BE_24_ADDR_WD
                         : (jj2 == 25) ? SRAM_BE_25_ADDR_WD
                         : (jj2 == 26) ? SRAM_BE_26_ADDR_WD
                         : (jj2 == 27) ? SRAM_BE_27_ADDR_WD
                         : (jj2 == 28) ? SRAM_BE_28_ADDR_WD
                         : (jj2 == 29) ? SRAM_BE_29_ADDR_WD
                         : (jj2 == 30) ? SRAM_BE_30_ADDR_WD
                         : (jj2 == 31) ? SRAM_BE_31_ADDR_WD
                         /* default */   : 1 ;
      localparam DATA_WD = (jj2 == 0 ) ? SRAM_BE_0_DATA_WD
                         : (jj2 == 1 ) ? SRAM_BE_1_DATA_WD
                         : (jj2 == 2 ) ? SRAM_BE_2_DATA_WD
                         : (jj2 == 3 ) ? SRAM_BE_3_DATA_WD
                         : (jj2 == 4 ) ? SRAM_BE_4_DATA_WD
                         : (jj2 == 5 ) ? SRAM_BE_5_DATA_WD
                         : (jj2 == 6 ) ? SRAM_BE_6_DATA_WD
                         : (jj2 == 7 ) ? SRAM_BE_7_DATA_WD
                         : (jj2 == 8 ) ? SRAM_BE_8_DATA_WD
                         : (jj2 == 9 ) ? SRAM_BE_9_DATA_WD
                         : (jj2 == 10) ? SRAM_BE_10_DATA_WD
                         : (jj2 == 11) ? SRAM_BE_11_DATA_WD
                         : (jj2 == 12) ? SRAM_BE_12_DATA_WD
                         : (jj2 == 13) ? SRAM_BE_13_DATA_WD
                         : (jj2 == 14) ? SRAM_BE_14_DATA_WD
                         : (jj2 == 15) ? SRAM_BE_15_DATA_WD
                         : (jj2 == 16) ? SRAM_BE_16_DATA_WD
                         : (jj2 == 17) ? SRAM_BE_17_DATA_WD
                         : (jj2 == 18) ? SRAM_BE_18_DATA_WD
                         : (jj2 == 19) ? SRAM_BE_19_DATA_WD
                         : (jj2 == 20) ? SRAM_BE_20_DATA_WD
                         : (jj2 == 21) ? SRAM_BE_21_DATA_WD
                         : (jj2 == 22) ? SRAM_BE_22_DATA_WD
                         : (jj2 == 23) ? SRAM_BE_23_DATA_WD
                         : (jj2 == 24) ? SRAM_BE_24_DATA_WD
                         : (jj2 == 25) ? SRAM_BE_25_DATA_WD
                         : (jj2 == 26) ? SRAM_BE_26_DATA_WD
                         : (jj2 == 27) ? SRAM_BE_27_DATA_WD
                         : (jj2 == 28) ? SRAM_BE_28_DATA_WD
                         : (jj2 == 29) ? SRAM_BE_29_DATA_WD
                         : (jj2 == 30) ? SRAM_BE_30_DATA_WD
                         : (jj2 == 31) ? SRAM_BE_31_DATA_WD
                         /* default */   : 1 ;
      localparam DEPTH   = (jj2 == 0 ) ? SRAM_BE_0_DEPTH
                         : (jj2 == 1 ) ? SRAM_BE_1_DEPTH
                         : (jj2 == 2 ) ? SRAM_BE_2_DEPTH
                         : (jj2 == 3 ) ? SRAM_BE_3_DEPTH
                         : (jj2 == 4 ) ? SRAM_BE_4_DEPTH
                         : (jj2 == 5 ) ? SRAM_BE_5_DEPTH
                         : (jj2 == 6 ) ? SRAM_BE_6_DEPTH
                         : (jj2 == 7 ) ? SRAM_BE_7_DEPTH
                         : (jj2 == 8 ) ? SRAM_BE_8_DEPTH
                         : (jj2 == 9 ) ? SRAM_BE_9_DEPTH
                         : (jj2 == 10) ? SRAM_BE_10_DEPTH
                         : (jj2 == 11) ? SRAM_BE_11_DEPTH
                         : (jj2 == 12) ? SRAM_BE_12_DEPTH
                         : (jj2 == 13) ? SRAM_BE_13_DEPTH
                         : (jj2 == 14) ? SRAM_BE_14_DEPTH
                         : (jj2 == 15) ? SRAM_BE_15_DEPTH
                         : (jj2 == 16) ? SRAM_BE_16_DEPTH
                         : (jj2 == 17) ? SRAM_BE_17_DEPTH
                         : (jj2 == 18) ? SRAM_BE_18_DEPTH
                         : (jj2 == 19) ? SRAM_BE_19_DEPTH
                         : (jj2 == 20) ? SRAM_BE_20_DEPTH
                         : (jj2 == 21) ? SRAM_BE_21_DEPTH
                         : (jj2 == 22) ? SRAM_BE_22_DEPTH
                         : (jj2 == 23) ? SRAM_BE_23_DEPTH
                         : (jj2 == 24) ? SRAM_BE_24_DEPTH
                         : (jj2 == 25) ? SRAM_BE_25_DEPTH
                         : (jj2 == 26) ? SRAM_BE_26_DEPTH
                         : (jj2 == 27) ? SRAM_BE_27_DEPTH
                         : (jj2 == 28) ? SRAM_BE_28_DEPTH
                         : (jj2 == 29) ? SRAM_BE_29_DEPTH
                         : (jj2 == 30) ? SRAM_BE_30_DEPTH
                         : (jj2 == 31) ? SRAM_BE_31_DEPTH
                         /* default */   : 1<<ADDR_WD ;
      localparam HOLDDATA = (jj2 == 0 ) ? SRAM_BE_0_HOLDDATA
                          : (jj2 == 1 ) ? SRAM_BE_1_HOLDDATA
                          : (jj2 == 2 ) ? SRAM_BE_2_HOLDDATA
                          : (jj2 == 3 ) ? SRAM_BE_3_HOLDDATA
                          : (jj2 == 4 ) ? SRAM_BE_4_HOLDDATA
                          : (jj2 == 5 ) ? SRAM_BE_5_HOLDDATA
                          : (jj2 == 6 ) ? SRAM_BE_6_HOLDDATA
                          : (jj2 == 7 ) ? SRAM_BE_7_HOLDDATA
                          : (jj2 == 8 ) ? SRAM_BE_8_HOLDDATA
                          : (jj2 == 9 ) ? SRAM_BE_9_HOLDDATA
                          : (jj2 == 10) ? SRAM_BE_10_HOLDDATA
                          : (jj2 == 11) ? SRAM_BE_11_HOLDDATA
                          : (jj2 == 12) ? SRAM_BE_12_HOLDDATA
                          : (jj2 == 13) ? SRAM_BE_13_HOLDDATA
                          : (jj2 == 14) ? SRAM_BE_14_HOLDDATA
                          : (jj2 == 15) ? SRAM_BE_15_HOLDDATA
                          : (jj2 == 16) ? SRAM_BE_16_HOLDDATA
                          : (jj2 == 17) ? SRAM_BE_17_HOLDDATA
                          : (jj2 == 18) ? SRAM_BE_18_HOLDDATA
                          : (jj2 == 19) ? SRAM_BE_19_HOLDDATA
                          : (jj2 == 20) ? SRAM_BE_20_HOLDDATA
                          : (jj2 == 21) ? SRAM_BE_21_HOLDDATA
                          : (jj2 == 22) ? SRAM_BE_22_HOLDDATA
                          : (jj2 == 23) ? SRAM_BE_23_HOLDDATA
                          : (jj2 == 24) ? SRAM_BE_24_HOLDDATA
                          : (jj2 == 25) ? SRAM_BE_25_HOLDDATA
                          : (jj2 == 26) ? SRAM_BE_26_HOLDDATA
                          : (jj2 == 27) ? SRAM_BE_27_HOLDDATA
                          : (jj2 == 28) ? SRAM_BE_28_HOLDDATA
                          : (jj2 == 29) ? SRAM_BE_29_HOLDDATA
                          : (jj2 == 30) ? SRAM_BE_30_HOLDDATA
                          : (jj2 == 31) ? SRAM_BE_31_HOLDDATA
                          /* default */   : 1 ;
      reg [ADDR_WD-1:0] addr;
      reg [DATA_WD-1:0] wdata;
      reg [DATA_WD-1:0] rdata;
      static int err_sts = 0;
      reg [DATA_WD/8-1:0] be;
      reg [DATA_WD  -1:0] rdata_cmp;

      @(posedge presetn);
      forever begin
        @(test_start_sram_be[ram_index] == 1'b1);
        // status flag
        status_clear_sram_be[ram_index]     = 0;
        status_test_done_sram_be[ram_index] = 0;
        status_test_pass_sram_be[ram_index] = 0;

        //**************************************************************
        // RESET
        //**************************************************************
        if (reset_sram_be[ram_index]==1'b1) begin
          static string str_rst = $psprintf(">>>> SRAM_BE[%s]: RESET",SRAM_BE_NAME[jj2]);
          wdata = {DATA_WD{1'b0}};

          //------------------------------
          // Walking 1 on ADDR, DATA=0..0
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting RESET Walking 1 on ADDR, DATA=0 test on SRAM_BE[%s]",SRAM_BE_NAME[jj2]);
          for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
            addr  = ii[ADDR_WD-1:0];
            if (addr < DEPTH) begin
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
            end
          end

          test_sram_be_blk[jj2].sram_be_intf.delay(10);
          //------------------------------
          // Walking 0 on ADDR, DATA=0..0
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting RESET Walking 0 on ADDR, DATA=0 test on SRAM_BE[%s]",SRAM_BE_NAME[jj2]);
          for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
            addr  = ~(ii[ADDR_WD-1:0]);
            if (addr < DEPTH) begin
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
            end
          end

          test_sram_be_blk[jj2].sram_be_intf.delay(10);
          //------------------------------
          // DATA
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting RESET DATA test on SRAM_BE[%s]",SRAM_BE_NAME[jj2]);
          if ((1<<ADDR_WD) < (1<<6)) begin    // < 64
            for (int ii=0; ii<(1<<ADDR_WD); ii++) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
              end
            end
          end
          else if ((1<<ADDR_WD) >= (1<<6)) begin   // >= 64
            for (int ii=0; ii<(1<<6); ii++) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<6)) begin   // >= 64 // <= 4 096
            for (int ii=(1<<6); ii<get_smallest_of(DEPTH,(1<<12)); ii=ii+(1<<6)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
            end
          end
          if ((1<<ADDR_WD) >= (1<<12)) begin  // >= 4 096 // <= 262 144
            for (int ii=(1<<12); ii<get_smallest_of(DEPTH,(1<<18)); ii=ii+(1<<12)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
            end
          end
          if ((1<<ADDR_WD) >= (1<<18)) begin  // >= 262 144 // <= 16 777 216
            for (int ii=(1<<18); ii<get_smallest_of(DEPTH,(1<<24)); ii=ii+(1<<18)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
            end
          end
          if ((1<<ADDR_WD) >= (1<<24)) begin  // >= 16 777 216  // <= 1 073 741 824
            for (int ii=(1<<24); ii<get_smallest_of(DEPTH,(1<<30)); ii=ii+(1<<24)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
            end
          end
          if ((1<<ADDR_WD) >= (1<<30)) begin  // >= 1 073 741 824  // <= 68 719 476 735
            for (int ii=(1<<30); ii<get_smallest_of(DEPTH,(1<<36)); ii=ii+(1<<30)) begin
              addr  = ii[ADDR_WD-1:0];
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});   // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                   // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_rst, err_sts);                           // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
            end
          end

          // STATUS: clear
          status_clear_sram_be[ram_index] = 1;
        end // if (reset_sram_be[ram_index]==1'b1)


        //**************************************************************
        // Walking 1
        //**************************************************************
        if (algorithm_w1_sram_be[ram_index]==1'b1) begin
          static string str_w1a = $psprintf(">>>> SRAM_BE[%s]: Walking 1 ADDR",SRAM_BE_NAME[jj2]);
          static string str_w1d = $psprintf(">>>> SRAM_BE[%s]: Walking 1 DATA",SRAM_BE_NAME[jj2]);

          test_sram_be_blk[jj2].sram_be_intf.delay(20);
          //------------------------------
          // Walking 1 on ADDR bus
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting Walking 1 on SRAM bus test on SRAM_BE[%s]",SRAM_BE_NAME[jj2]);
          for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
            addr  = ii[ADDR_WD-1:0];  // walking 1
            if (addr < DEPTH) begin
              // read data (address = addr)
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
              for (int n=0; n<(DATA_WD/8); n++) begin
                be = {(DATA_WD/8){1'b0}};
                be[n] = 1'b1;
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, rdata_cmp, rdata, str_w1a, err_sts);                         // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_w1a, err_sts);                       // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                end
              end
              // check if rdata = wdata
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_w1a, err_sts);                               // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(3);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_w1a, err_sts);                             // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
              //
              wdata = {DATA_WD{1'b0}};  // DATA=0..0
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});       // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_w1a, err_sts);                               // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(4);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_w1a, err_sts);                             // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
            end
          end // Walking 1 on ADDR bus

          test_sram_be_blk[jj2].sram_be_intf.delay(10);
          //------------------------------
          // Walking 1 on DATA bus
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting Walking 1 on DATA bus test on SRAM_BE[%s]",SRAM_BE_NAME[jj2]);
          for (reg [1024:0] ii=1; ii<(1<<DATA_WD); ii=ii<<1) begin
            addr  = {ADDR_WD{1'b0}};  // ADDR=0..0
            wdata = ii[DATA_WD-1:0];  // walking 1
            test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});       // WRITE
            test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
            rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
            check_data(addr, wdata, rdata, str_w1d, err_sts);                               // CHECK_DATA
            if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
            if (HOLDDATA==1) begin
              test_sram_be_blk[jj2].sram_be_intf.delay(3);
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_w1d, err_sts);                             // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
            end
          end // Walking 1 on DATA bus
        end // if (algorithm_w1_sram_be[ram_index]==1'b1)


        //**************************************************************
        // Walking 0
        //**************************************************************
        if (algorithm_w0_sram_be[ram_index]==1'b1) begin
          static string str_w0a = $psprintf(">>>> SRAM_BE[%s]: Walking 0 ADDR",SRAM_BE_NAME[jj2]);
          static string str_w0d = $psprintf(">>>> SRAM_BE[%s]: Walking 0 DATA",SRAM_BE_NAME[jj2]);

          test_sram_be_blk[jj2].sram_be_intf.delay(20);
          //------------------------------
          // Walking 0 on ADDR bus
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting Walking 0 on ADDR bus test on SRAM_BE[%s]",SRAM_BE_NAME[jj2]);
          for (int ii=1; ii<(1<<ADDR_WD); ii=ii<<1) begin
            addr  = ~(ii[ADDR_WD-1:0]); // walking 0
            if (addr < DEPTH) begin
              // read data (address = addr)
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
              for (int n=0; n<(DATA_WD/8); n++) begin
                be = {(DATA_WD/8){1'b0}};
                be[n] = 1'b1;
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, rdata_cmp, rdata, str_w0a, err_sts);                         // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_w0a, err_sts);                       // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                end
              end
              // check if rdata = wdata
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_w0a, err_sts);                               // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(3);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_w0a, err_sts);                             // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
              //
              wdata = {DATA_WD{1'b0}};  // DATA=0..0
              test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});       // WRITE
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_w0a, err_sts);                               // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(4);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_w0a, err_sts);                             // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
            end
          end // Walking 0 on ADDR bus

          test_sram_be_blk[jj2].sram_be_intf.delay(10);
          //------------------------------
          // Walking 0 on DATA bus
          //------------------------------
          if (DEBUG_LEVEL>=1) $display("Starting Walking 0 on DATA bus test on SRAM_BE[%s]",SRAM_BE_NAME[jj2]);
          for (reg [1024:0] ii=1; ii<(1<<DATA_WD); ii=ii<<1) begin
            addr  = {ADDR_WD{1'b0}};    // ADDR=0..0
            wdata = ~(ii[DATA_WD-1:0]); // walking 0
            test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,{(DATA_WD/8){1'b1}});       // WRITE
            test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
            rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
            check_data(addr, wdata, rdata, str_w0d, err_sts);                               // CHECK_DATA
            if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
            if (HOLDDATA==1) begin
              test_sram_be_blk[jj2].sram_be_intf.delay(3);
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_w0d, err_sts);                             // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
            end
          end // Walking 0 on DATA bus
        end // if (algorithm_w0_sram_be[ram_index]==1'b1)


        //**************************************************************
        // Unique DATA
        //**************************************************************
        if (algorithm_data_sram_be[ram_index]==1'b1) begin
          static string str_data = $psprintf(">>>> SRAM_BE[%s]: Unique DATA",SRAM_BE_NAME[jj2]);

          test_sram_be_blk[jj2].sram_be_intf.delay(20);
          if (DEBUG_LEVEL>=1) $display("Starting Unique DATA test on SRAM_BE[%s]",SRAM_BE_NAME[jj2]);
          if ((1<<ADDR_WD) < (1<<6)) begin    // < 64
            for (int ii=0; ii<(1<<ADDR_WD); ii++) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                // read data (address = addr)
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
                rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
                for (int n=0; n<(DATA_WD/8); n++) begin
                  be = {(DATA_WD/8){1'b0}};
                  be[n] = 1'b1;
                  test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                  rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                  test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_data, err_sts);                        // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                  if (HOLDDATA==1) begin
                    test_sram_be_blk[jj2].sram_be_intf.delay(3);
                    rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                    check_data(addr, rdata_cmp, rdata, str_data, err_sts);                      // CHECK_DATA
                    if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                  end
                end
                // check if rdata = wdata
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                            // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                end
              end
            end
          end
          else if ((1<<ADDR_WD) >= (1<<6)) begin   // >= 64
            for (int ii=0; ii<(1<<6); ii++) begin
              addr  = ii[ADDR_WD-1:0];
              if (addr < DEPTH) begin
                // read data (address = addr)
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
                rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
                for (int n=0; n<(DATA_WD/8); n++) begin
                  be = {(DATA_WD/8){1'b0}};
                  be[n] = 1'b1;
                  test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                  rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                  test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_data, err_sts);                        // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                  if (HOLDDATA==1) begin
                    test_sram_be_blk[jj2].sram_be_intf.delay(3);
                    rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                    check_data(addr, rdata_cmp, rdata, str_data, err_sts);                      // CHECK_DATA
                    if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                  end
                end
                // check if rdata = wdata
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, wdata, rdata, str_data, err_sts);                            // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                end
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<6)) begin  // >= 64 // <= 4 096
            test_sram_be_blk[jj2].sram_be_intf.delay(5);
            for (int ii=(1<<6); ii<get_smallest_of(DEPTH,(1<<12)); ii=ii+(1<<6)) begin
              addr  = ii[ADDR_WD-1:0];
              // read data (address = addr)
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
              for (int n=0; n<(DATA_WD/8); n++) begin
                be = {(DATA_WD/8){1'b0}};
                be[n] = 1'b1;
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, rdata_cmp, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_data, err_sts);                      // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                end
              end
              // check if rdata = wdata
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(3);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_data, err_sts);                            // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<12)) begin  // >= 4 096 // <= 262 144
            test_sram_be_blk[jj2].sram_be_intf.delay(5);
            for (int ii=(1<<12); ii<get_smallest_of(DEPTH,(1<<18)); ii=ii+(1<<12)) begin
              addr  = ii[ADDR_WD-1:0];
              // read data (address = addr)
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
              for (int n=0; n<(DATA_WD/8); n++) begin
                be = {(DATA_WD/8){1'b0}};
                be[n] = 1'b1;
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, rdata_cmp, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_data, err_sts);                      // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                end
              end
              // check if rdata = wdata
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(3);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_data, err_sts);                            // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<18)) begin  // >= 262 144 // <= 16 777 216
            test_sram_be_blk[jj2].sram_be_intf.delay(5);
            for (int ii=(1<<18); ii<get_smallest_of(DEPTH,(1<<24)); ii=ii+(1<<18)) begin
              addr  = ii[ADDR_WD-1:0];
              // read data (address = addr)
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
              for (int n=0; n<(DATA_WD/8); n++) begin
                be = {(DATA_WD/8){1'b0}};
                be[n] = 1'b1;
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, rdata_cmp, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_data, err_sts);                      // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                end
              end
              // check if rdata = wdata
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(3);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_data, err_sts);                            // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<24)) begin  // >= 16 777 216  // <= 1 073 741 824
            test_sram_be_blk[jj2].sram_be_intf.delay(5);
            for (int ii=(1<<24); ii<get_smallest_of(DEPTH,(1<<30)); ii=ii+(1<<24)) begin
              addr  = ii[ADDR_WD-1:0];
              // read data (address = addr)
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
              for (int n=0; n<(DATA_WD/8); n++) begin
                be = {(DATA_WD/8){1'b0}};
                be[n] = 1'b1;
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, rdata_cmp, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_data, err_sts);                      // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                end
              end
              // check if rdata = wdata
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(3);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_data, err_sts);                            // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
            end
          end
          if ((1<<ADDR_WD) >= (1<<30)) begin  // >= 1 073 741 824  // <= 68 719 476 735
            test_sram_be_blk[jj2].sram_be_intf.delay(5);
            for (int ii=(1<<30); ii<get_smallest_of(DEPTH,(1<<36)); ii=ii+(1<<30)) begin
              addr  = ii[ADDR_WD-1:0];
              // read data (address = addr)
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata_cmp = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              wdata = random_data(DATA_WD)[DATA_WD-1:0];  // data to write
              for (int n=0; n<(DATA_WD/8); n++) begin
                be = {(DATA_WD/8){1'b0}};
                be[n] = 1'b1;
                test_sram_be_blk[jj2].sram_be_intf.write(addr,wdata,be);                      // WRITE
                rdata_cmp[n*8 +: 8] = wdata[n*8 +: 8];
                test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                     // READ
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, rdata_cmp, rdata, str_data, err_sts);                        // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
                if (HOLDDATA==1) begin
                  test_sram_be_blk[jj2].sram_be_intf.delay(3);
                  rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                  check_data(addr, rdata_cmp, rdata, str_data, err_sts);                      // CHECK_DATA
                  if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;// ERR_STS
                end
              end
              // check if rdata = wdata
              test_sram_be_blk[jj2].sram_be_intf.read(addr,READ_DELAY);                       // READ
              rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
              check_data(addr, wdata, rdata, str_data, err_sts);                              // CHECK_DATA
              if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;    // ERR_STS
              if (HOLDDATA==1) begin
                test_sram_be_blk[jj2].sram_be_intf.delay(3);
                rdata = sram_be_dout[SRAM_BE_DATA_WD_START_ARRAY[jj2] +: SRAM_BE_DATA_WD_ARRAY[jj2]];
                check_data(addr, wdata, rdata, str_data, err_sts);                            // CHECK_DATA
                if (err_sts==1) err_cnt_sram_be[ram_index] = err_cnt_sram_be[ram_index] + 1;  // ERR_STS
              end
            end //for
          end //if ((1<<ADDR_WD) >= (1<<30))

        end //if (algorithm_data_sram_be[ram_index]==1'b1)

        // STATUS: test DONE
        status_test_done_sram_be[ram_index] = 1;

        // STATUS: test PASS
        if (err_cnt_sram_be[ram_index] == 0) begin
          status_test_pass_sram_be[ram_index] = 1;
        end
        else begin
          status_test_pass_sram_be[ram_index] = 0;
        end
      end // forever
      end // initial
    end //for SRAM_BE[0..31]
  endgenerate

endmodule

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
