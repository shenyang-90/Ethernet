//------------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
/**
//
// @page Miscellaneous
// @subpage cdn_gem_demo common functions
//
// Description:
// ***********
// The purpose of this module is to provide GEM_GXL-specific functions needed by
// the underlying UVM/SV environment to run C tests - e.g. to implement the 
// necessary DPI-C calls, implement driver API, etc.
*/
//----------------------------------------------------------------------------

/*! \file cdn_gem_demo.h
 *  \brief Implement GEM_GXL-specific functions needed by the underlying UVM/SV
 *         environment to run C tests.
 */

#ifndef _CDN_GEM_DEMO_H_
  #define _CDN_GEM_DEMO_H_

//------------------------------------
// Extern functions
//------------------------------------

  /*! \fn extern int send_line_transaction ();
   *  \brief SystemVerilog task.
   *         Send an Ethernet packet from the line side.
   */
  extern int send_line_transaction ();

//------------------------------------
// Implemented functions
//------------------------------------

//-----------------
// CPS API
//-----------------

  /*! \fn uint16_t CPS_UncachedRead16(volatile uint16_t* address);
   *  \brief Readz a short, bypassing the cache.
   *         Returns the read value.
   *  \param address The address.
   */
  uint16_t CPS_UncachedRead16(volatile uint16_t* address);

  /*! \fn void CPS_UncachedWrite16(volatile uint16_t* address, uint16_t value);
   *  \brief Write a short to memory, bypassing the cache
   *  \param address The address.
   *  \param value The short to write.
   */
  void CPS_UncachedWrite16(volatile uint16_t* address, uint16_t value);

  /*! \fn void CPS_WritePhysAddress32(volatile uint32_t* location, uint32_t addrValue);
   *  \brief Write a (32-bit) address value to memory, bypassing the cache.
   *         This function is for writing an address value, i.e. something that
   *         will be treated as an address by hardware, and therefore might need
   *         to be translated to a physical bus address.
   *  \param location The (CPU) location where to write the address value.
   *  \param addrValue The address value to write.
   */
  void CPS_WritePhysAddress32(volatile uint32_t* location, uint32_t addrValue);

//-----------------
// DEMO TB API
//-----------------

  /*! \fn void cdn_demo_printf_error(const char* format, ...)
   *  \brief Prints a formatted error message.
   *  \param format The formatted message.
   */
  void cdn_demo_printf_error(const char* format, ...);

  /*! \fn void cdn_demo_printf_warning(const char* format, ...)
   *  \brief Prints a formatted warning message.
   *  \param format The formatted message.
   */
  void cdn_demo_printf_warning(const char* format, ...);

  /*! \fn void cdn_demo_printf_info(const char* format, ...)
   *  \brief Prints a formatted info message.
   *  \param format The formatted message.
   */
  void cdn_demo_printf_info(const char* format, ...);

  /*! \fn void cdn_demo_printf_debug(const char* format, ...)
   *  \brief Prints a formatted debug message.
   *  \param format The formatted message.
   */
  void cdn_demo_printf_debug(const char* format, ...);

//-----------------
// Utils
//-----------------

  /*! \fn is_address_inside_hw_map(uint32_t address)
   *  \brief Check if `address` is inside the hardware memory map (registers),
   *         to avoid sending software-specific accesses (DMA descriptors) to the 
   *         system bus.
   */
  int is_addr_inside_hw_map(uint32_t address);


#endif // _CDN_GEM_DEMO_H_

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------

