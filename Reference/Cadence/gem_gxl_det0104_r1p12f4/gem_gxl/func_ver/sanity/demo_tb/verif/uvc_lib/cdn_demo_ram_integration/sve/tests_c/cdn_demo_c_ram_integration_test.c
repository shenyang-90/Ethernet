//------------------------------------------------------------------------------
// File      : cdn_demo_c_ram_integration_test.c
// Author    : smckelvi@cadence.com
// Date      : 22nd April, 2017
//------------------------------------------------------------------------------
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
//------------------------------------------------------------------------------
//
/**
// @page cdn_demo_c_ram_integration_test
//
// Description
// ***********
// 
// The purpose of this test is to perform a thorough RAM integration test for
// all RAMs that are connected to the DUT. The test reads the RAM integration
// stub BFM to determine the number and type of RAMs present. Once the
// configuration is known then the test performs full RAM testing. The testing
// performed is as follows:
// - Walking zeros (set bit [5]) on address and data buses
// - Walkings ones (set bit [6]) on address and data buses
// - Unique data   (set bit [7]) to each location then read back.
// The RAM is reset before running test when bit [3] of CTRL_REG is set.
//
//  APB_BANK_REG:
//  +-------------------------------------------------------+
//  |          bits of CONTROL and STATUS register          |
//  +------+------+------+------#------+------+------+------+
//  |  7   |  6   |  5   |  4   #  3   |  2   |  1   |  0   |
//  +------+------+------+------#------+------+------+------+
//  | DATA |  W1  |  W0  | RUN  # RST  | DONE | PASS | CLR  |
//  +------+------+------+------#------+------+------+------+
//  |      algorithm     |   trigger   |       status       |
//  +--------------------+-------------+--------------------+
*/
//------------------------------------------------------------------------------

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <inttypes.h>
#include <assert.h>
#include "cdn_demo.h"
#include "cdn_ram_stub_addr_map.h"
#include "cdn_ram_stub_addr_map_macro.h"

#define CDN_RAM_INTEGRATION_STUB_BASE_ADDR 0x10000000

struct cdn_ram_stub_addr_map *ram_regs = (struct cdn_ram_stub_addr_map*)CDN_RAM_INTEGRATION_STUB_BASE_ADDR;

// Common Function Pointers
extern void (*irq_handler) (void* DeviceID);

//------------------------------------------------------------------------------
/** Interrupt handler - effectively does nothing in this test but is included
 * as an example reference to detail how to connect the interrupt handler
 */
void _irq_handler(void* DeviceID)
{
  csp_printf_info("cdn_demo_c_ram_integration_test irq_handler");
}

//------------------------------------------------------------------------------
/**
// The main body of this test is straightforward and contains the following
// steps:
// 1. Read and report the number of RAM types.
// 2. Start the RAM algorithms for all RAMs.
// 3. Status poll while the RAM algorithm is not complete.
// 4. Report a pass or fail for the RAM algorithm.
*/

int main(int argc, char ** _argv)
{

  uint32_t _data=0;
  int status_done=0;
  int status_pass=0;
  char _str[1024];

  irq_handler = &_irq_handler;

  csp_printf_info("**************************************");
  csp_printf_info("*                                    *");
  csp_printf_info("*    RAM Integration Test   start    *");
  csp_printf_info("*                                    *");
  csp_printf_info("**************************************");

  csp_printf_info("Reading and reporting number of RAM types");

  _data = csp_read32( &ram_regs->master_apb_reg_block.NUM_OF_SRAM);
  sprintf(_str, "NUM_OF_SRAM         : %d", _data);
  csp_printf_info(_str);
  _data = csp_read32( &ram_regs->master_apb_reg_block.NUM_OF_DP1R1W);
  sprintf(_str, "NUM_OF_DP1R1W       : %d", _data);
  csp_printf_info(_str);
  _data = csp_read32( &ram_regs->master_apb_reg_block.NUM_OF_DP2R2W);
  sprintf(_str, "NUM_OF_DP2R2W       : %d", _data);
  csp_printf_info(_str);
  _data = csp_read32( &ram_regs->master_apb_reg_block.NUM_OF_SRAM_BE);
  sprintf(_str, "NUM_OF_SRAM_BE      : %d", _data);
  csp_printf_info(_str);

  csp_printf_info("MASTER APB BANK - read CTRL_REG");
  _data = csp_read32( &ram_regs->master_apb_reg_block.MASTER_CTRL_REG);
  csp_printf_info("Run all algorithms, reset all RAMs, start testing of all RAMs");
  csp_write32( &ram_regs->master_apb_reg_block.MASTER_CTRL_REG, 0x000000F8);

  // Status polling
  do {
    _data = csp_read32( &ram_regs->master_apb_reg_block.MASTER_CTRL_REG);
    csp_printf_info("[cdn_demo_c_ram_integration_test] TEST all RAMs is RUNNING");
    csp_delay_us(1);
  }
  while ((status_done = APB_BANK_REG__RUNNING_DONE_STATUS_FLAG__READ(_data)) == 0);
  csp_printf_info("[cdn_demo_c_ram_integration_test] TEST all RAMs DONE");

  // Check if test PASS
  status_pass = APB_BANK_REG__PASS_FAIL_STATUS_FLAG__READ(_data);
  if (status_pass == 1) {
    csp_printf_info("[cdn_demo_c_ram_integration_test] TEST all RAMs PASS");
  }
  else {
    csp_printf_error("[cdn_demo_c_ram_integration_test] TEST all RAMs FAIL - Incorrect Data");
  }

  csp_printf_info("**************************************");
  csp_printf_info("*                                    *");
  csp_printf_info("*     RAM Integration Test   end     *");
  csp_printf_info("*                                    *");
  csp_printf_info("**************************************");

   return 0;
}

