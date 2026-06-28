//------------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
// Description:
// See header file for full details.
//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <inttypes.h>
#include <assert.h>
#include "cdn_demo.h"
#include "cdn_gem_demo.h"
#include "map_system_memory.h"

//------------------------------------
// CPS API
//------------------------------------

uint16_t CPS_UncachedRead16(volatile uint16_t *address) {
    return *address;
}

//------------------

void CPS_UncachedWrite16(volatile uint16_t *address, uint16_t value) {
    *address = value;
}

//------------------

void CPS_WritePhysAddress32(volatile uint32_t *location, uint32_t addrValue) {
  *location = addrValue;
}

//------------------------------------
// Demo TB API
//------------------------------------

void cdn_demo_printf_error(const char* format, ...) {
    va_list args;
    char buffer[1024];

    va_start(args, format);
    vsprintf(buffer, format, args);
    csp_printf_error(buffer);
    va_end(args);
}

//------------------

void cdn_demo_printf_warning(const char* format, ...) {
    va_list args;
    char buffer[1024];

    va_start(args, format);
    vsprintf(buffer, format, args);
    csp_printf_warning(buffer);
    va_end(args);
}

//------------------

void cdn_demo_printf_info(const char* format, ...) {
    va_list args;
    char buffer[1024];

    va_start(args, format);
    vsprintf(buffer, format, args);
    csp_printf_info(buffer);
    va_end(args);
}

//------------------

void cdn_demo_printf_debug(const char* format, ...) {
    va_list args;
    char buffer[1024];

    va_start(args, format);
    vsprintf(buffer, format, args);
    csp_printf_debug(buffer);
    va_end(args);
}

//------------------------------------
// Utils
//------------------------------------

int is_addr_inside_hw_map(uint32_t address) {
  // The demo TB supports two instances of the EMAC. If the CPS specific C code 
  // is to be reused on a system that has only one instance of the EMAC present,
  // then EMAC1_REGS_BASE will not be present. Using defines to accomodate this.
  if ((address >= EMAC0_REGS_BASE && address < EMAC0_REGS_BASE + EMAC0_REGS_SIZE)
    #ifdef EMAC1_REGS_BASE
   || (address >= EMAC1_REGS_BASE && address < EMAC1_REGS_BASE + EMAC1_REGS_SIZE)
    #endif
  ) return 1;
  else return 0;
}

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------

