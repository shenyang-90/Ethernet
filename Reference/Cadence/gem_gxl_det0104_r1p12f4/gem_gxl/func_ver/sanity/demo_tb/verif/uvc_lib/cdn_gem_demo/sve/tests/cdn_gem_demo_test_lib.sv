//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file contains the UVM test library for the cdn_gem_demo UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_test_lib.sv
 *
 * This file contains the UVM tests library for the cdn_gem_demo UVC.
 * Tests are included from individual files.
 */

`ifndef CDN_GEM_DEMO_TEST_LIB_SV
  `define CDN_GEM_DEMO_TEST_LIB_SV

// BASE TEST
`include "cdn_gem_demo_base_test.sv"

// USE CASES
`include "cdn_gem_demo_uc_enet_rx_1pkt_test.sv"
`include "cdn_gem_demo_uc_enet_rx_3pkts_test.sv"
`include "cdn_gem_demo_uc_enet_tx_1pkt_test.sv"
`include "cdn_gem_demo_uc_enet_tx_2pkts_test.sv"
`include "cdn_gem_demo_uc_enet_tx_q_fixed_test.sv"

// REGISTERS
`include "cdn_gem_demo_uvm_reg_reset_test.sv"
`include "cdn_gem_demo_uvm_reg_bit_bash_test.sv"
`include "cdn_gem_demo_uvm_reg_aliasing_test.sv"
`include "cdn_gem_demo_uvm_reg_read_all_test.sv"
`include "cdn_gem_demo_uvm_reg_write_all_test.sv"
`include "cdn_gem_demo_uvm_reg_write_follow_read_test.sv"

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
