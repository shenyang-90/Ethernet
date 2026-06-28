//------------------------------------------------------------------------------
// File      : cdn_demo_c_customer_dut_test.c
// Author    : smckelvi@cadence.com
// Date      : 21st August, 2017
//------------------------------------------------------------------------------
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
//------------------------------------------------------------------------------
//
/**
// @page cdn_demo_c_customer_dut_test
//
// Description
// ***********
// 
// The purpose of this test is to verify the CUSTOMER_DUT configuration where
// instead of the raw cdn_demo_top being instantiated, a customer_wrapper
// pulls in the cdn_demo_top module, and this customer_wrapper has different
// RAM parameter settings, where the number of connected RAMs has varied from
// the default RAM integration testing setting. This tests
// therefore reads the register bank of the cdn_demo_top (note the ram
// integration stub bfm remains within cdn_demo_top) and ensures the number of
// reported RAMs are as per the parameter settings.
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
  csp_printf_info("cdn_demo_c_customer_dut_test irq_handler");
}

//------------------------------------------------------------------------------
/**
// The main body of this test is straightforward and contains the following:
// 1. Read Accesses : read the SRAM parameters from the register bank and
// ensure they are correct.
// 2. Write Access : write to a writeable register and read back to ensure
// writes are additionally working.
*/

int main(int argc, char ** _argv)
{

  uint32_t _data=0;
  char _str[1024];

  irq_handler = &_irq_handler;

  csp_printf_info("Read Access Verification : Verifying RAM types");

  _data = csp_read32( &ram_regs->master_apb_reg_block.NUM_OF_SRAM);
  sprintf(_str, "NUM_OF_SRAM         : %d", _data);
  csp_printf_info(_str);
  if (_data != 12) {
    csp_printf_error("NUM__OF_SRAM Incorrect. Expected 12");
  }

  _data = csp_read32( &ram_regs->master_apb_reg_block.NUM_OF_DP1R1W);
  sprintf(_str, "NUM_OF_DP1R1W : %d", _data);
  csp_printf_info(_str);
  if (_data != 7) {
    csp_printf_error("NUM_OF_DP1R1W Incorrect. Expected 7");
  }

  _data = csp_read32( &ram_regs->master_apb_reg_block.NUM_OF_DP2R2W);
  sprintf(_str, "NUM_OF_DP2R2W       : %d", _data);
  csp_printf_info(_str);
  if (_data != 4) {
    csp_printf_error("NUM_OF_DP2R2W Incorrect. Expected 4");
  }

  _data = csp_read32( &ram_regs->master_apb_reg_block.NUM_OF_SRAM_BE);
  sprintf(_str, "NUM_OF_SRAM_BE      : %d", _data);
  csp_printf_info(_str);
  if (_data != 1) {
    csp_printf_error("NUM_OF_SRAM_BE Incorrect. Expected 1");
  }

  csp_printf_info("Write Access Verification : Writing and reading from a writeable register");
  _data = 0;
  APB_BANK_REG__RAM_ALGORITHM_0__SET(_data);
  APB_BANK_REG__RAM_ALGORITHM_1__SET(_data);
  APB_BANK_REG__RAM_ALGORITHM_DATA__SET(_data);
  csp_write32( &ram_regs->master_apb_reg_block.MASTER_CTRL_REG, _data);

  sprintf(_str, "MASTER_CTRL_REG      : %d", _data);
  csp_printf_info(_str);

  _data = csp_read32( &ram_regs->master_apb_reg_block.MASTER_CTRL_REG);
  if ( APB_BANK_REG__RAM_ALGORITHM_0__READ(_data) &
       APB_BANK_REG__RAM_ALGORITHM_1__READ(_data) &
       APB_BANK_REG__RAM_ALGORITHM_DATA__READ(_data)) {
    csp_printf_info("Write Access Verification : MASTER_CTRL_REG Passed");
  } else {
    csp_printf_error("Write Access Verification : MASTER_CTRL_REG Failed");
  }

  return 0;
}

