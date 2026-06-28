//------------------------------------------------------------------------------
// File      : cdn_gem_demo_c_int_enet_loopback_test.c
// Author    : bemanuel@cadence.com
// Date      : 3rd July, 2017
//------------------------------------------------------------------------------
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
//------------------------------------------------------------------------------

/*! \file map_system_memory.h
 *  \brief This file is used to set the hardware address map for the C layer in
 *         the demo TB UVM/SV env.
 */

#ifndef _system_memory_H_
  #define _system_memory_H_

  /*! The registers base address (instance 0). */
  #define EMAC0_REGS_BASE 0xfff30000
  
  /*! The DUT register bank size (instance 0). */
  #define EMAC0_REGS_SIZE 0x1FFF
  
  /*! The DUT register bank base address (instance 1). */
  #define EMAC1_REGS_BASE 0xfff32000

  /*! The DUT register bank size (instance 1). */
  #define EMAC1_REGS_SIZE 0x1FFF

#endif

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------

