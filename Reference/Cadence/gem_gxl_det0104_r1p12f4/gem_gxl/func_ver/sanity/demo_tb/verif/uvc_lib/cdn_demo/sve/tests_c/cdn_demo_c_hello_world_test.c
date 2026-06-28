//------------------------------------------------------------------------------
// File      : cdn_demo_c_hello_world_test.c
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
// @page cdn_demo_c_hello_world_test
//
// Description
// ***********
// 
// Very simple test to simply send a "Hello World" and then end.
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
// Print Hello World and then end.

int main(int argc, char ** _argv)
{

   csp_printf_info("Hello World");
   return 0;
}

