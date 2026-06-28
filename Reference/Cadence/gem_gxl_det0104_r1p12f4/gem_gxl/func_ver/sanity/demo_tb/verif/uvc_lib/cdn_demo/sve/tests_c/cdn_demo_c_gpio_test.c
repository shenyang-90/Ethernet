//------------------------------------------------------------------------------
// File      : cdn_demo_c_gpio_test.c
// Author    : smckelvi@cadence.com
// Date      : 22nd April, 2017
//------------------------------------------------------------------------------
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
//------------------------------------------------------------------------------
//
// Note. This test explicitly does not have the official "/**" doxygen header
// as this test should not be documented with doxygen and is used to
// demonstrate multiple tests in a vsif only.
//
// @page cdn_demo_c_gpio_test
//
// Description
// ***********
// 
// Very simple test to test the gpio connectivity, where a walking 1 pattern
// is set on each bit of the 64b gpio, and verified to ensure the bit is set
// correctly.
//
//------------------------------------------------------------------------------

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <inttypes.h>
#include <assert.h>
#include "cdn_demo.h"


//------------------------------------------------------------------------------
// gpio test - walking 1 pattern through each bit of the gpio bus, ensuring
// each bit is set correctly.

int main(int argc, char ** _argv)
{

   uint64_t _bitSelect = 0;
   uint64_t _gpio, i;
   char _str[1024];

   // Verify that the gpio bus is all zeros after reset.
   cdn_demo_get_gpio(&_gpio);
   if (_gpio != 0) {
      sprintf(_str, "[test] gpio incorrect after reset. Expected 0x0. Got : %8x%8x", (unsigned int)(_gpio>>32), (unsigned int)_gpio);
      csp_printf_error(_str);
   }

   // Walking 1 pattern
   for (i = 0; i<64; i++) {
      _bitSelect = (uint64_t)1 << i;
      _bitSelect = ~_bitSelect;

      // Set the gpio value
      _gpio = 0xFFFFFFFFFFFFFFFF;
      cdn_demo_set_gpio(_gpio, _bitSelect);

      // Get the gpio value and report
      csp_delay_us(5);
      cdn_demo_get_gpio(&_gpio);
      sprintf(_str, "[test] gpio value : %08x%08x", (unsigned int)(_gpio>>32), (unsigned int)_gpio);
      csp_printf_info(_str);

      // Check the value of the gpio
      if (_gpio != (uint64_t)1 << i) {
         sprintf(_str, "[test] gpio incorrect value. Got : %08x%08x", (unsigned int)(_gpio>>32), (unsigned int)_gpio);
         csp_printf_error(_str);
      }

      // Reset the gpio back to 0
      _gpio = 0x0000000000000000;
      cdn_demo_set_gpio(_gpio, _gpio);
      csp_delay_us(5);
   }

   csp_printf_info("[test] cdn_demo_c_gpio_test test complete.");

   return 0;
}

