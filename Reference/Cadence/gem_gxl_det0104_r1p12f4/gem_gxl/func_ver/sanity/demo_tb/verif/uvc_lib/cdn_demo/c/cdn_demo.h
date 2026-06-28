//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
/**
//
// @page Miscellaneous
// @subpage cdn_demo common functions
//
// Description:
// ***********
// The purpose of this module is to provide C functionality needed for the
// underlying UVM/SV environment to operate - e.g. to implement the necessary
// DPI-C calls. In addition, the conventions used here align with the
// conventions from CSP and CPS (Cadence Platform Services). Typical examples
// within this file are:
//
// - cdn_demo_irq_handler
// - cdn_demo_write?, cdn_demo_read? - read/write to system memory
// - CPS_UncachedRead32, CPS_UncachedWrite32 - read/write to a regiter
//
*/
//----------------------------------------------------------------------------

#ifndef _CDN_DEMO_H_
   #define _CDN_DEMO_H_

  #include <stdio.h>
   #include <stdint.h>

  /** Type def. for a function pointer which is used to discriminate if
   *  CPS_UncachedRead32 and CPS_UncachedWrite32 accesses are directed to a
   *  register or to a DMA descriptor.
   */
  typedef int (*cdn_demo_is_addr_inside_hw_map) (uint32_t addr);

  /** irq_handler implementation - tests implement the irq_handler if it is
   * needed.
   */
  void (*irq_handler) (void* DeviceID);

  /** The underlying UVM/SV imports this function and calls it at an
   * interrupt.
   */
  void cdn_demo_irq_handler(void* DeviceID);

  /** set_config implementation - tests implement the set_config if it is
   * needed.
   */
  void (*set_config) ();

  /** The underlying UVM/SV imports this function and calls it at
   * set_config.
   */
  void cdn_demo_set_config();

   #define fprintf vpi_fprintf
   #define printf vpi_printf
/*
   #define fprintf(file,format,...) \
      do { vpi_printf(format, __VA_ARGS__); } while (0)
*/

  /** Type def. for pointer to address re-maping routine (maps physical address to pointer)
   * \param phys_addr Physical address (e.g. the one taken directly from DUT DMA bus)
   * \param bytes_count Block size (expressed in bytes; can be zero for non-sized conversion)
   * \return Re-mapped pointer (corresponding to physical address)
   */
  typedef void* (*cdn_demo_remap_addr_proc_t)(uintptr_t phys_addr, size_t bytes_count);

  /** Type def. for pointer to phys. address query routine
   * \param phys_addr Physical address to be queried
   * \param bytes_count Block size (expressed in bytes; can be zero for non-sized query)
   * \param name Place where block name would be stored (can be NULL)
   * \param offset Place where offset within block would be stored (can be NULL)
   * \return Operation status
   */
  typedef int (*cdn_demo_query_phys_addr_proc_t)(uintptr_t phys_addr, size_t bytes_count,
    const char **name, intptr_t *offset);


  /** Type def. for pointer to SFR name query routine
   * \param sfr_addr SFR address to be queried
   * \return String with SFR name (or NULL if not found)
   */
  typedef const char* (*cdn_demo_query_sfr_name_proc_t)(uintptr_t sfr_addr);


  /** Type def. for pointer to function that returns current simulation time
   * \return Current simulation time (expressed in nanoseconds; returned as 64bit value)
   */
  typedef int64_t (*cdn_demo_get_sim_time_ns_long_proc_t)();



  /** Sets verbosity level for CDN_DEMO
   * \param new_verbosity New verbosity level
   * \return void
   */
  void cdn_demo_set_verbosity(int new_verbosity);


  /** Sets address re-mapping routine (phys. addr. -> pointer)
   * \param remap_proc Pointer to re-mapping routine
   * \return void
   */
  void cdn_demo_set_remap_addr_proc(cdn_demo_remap_addr_proc_t remap_proc);


  /** Sets phys. address query routine
   * \param addr_query_proc Pointer to address query routine
   * \return void
   */
  void cdn_demo_set_query_phys_addr_proc(cdn_demo_query_phys_addr_proc_t addr_query_proc);


  /** SetsSFR name query routine
   * \param sfr_query_proc Pointer to SFR query routine
   * \return void
   */
  void cdn_demo_set_query_sfr_name_proc(cdn_demo_query_sfr_name_proc_t sfr_query_proc);


  /** Sets simulation time obtaining routine (returns simulation time expressed in nanoseconds)
   * \param sim_time_proc Pointer to sim. time routine
   * \return void
   */
  void cdn_demo_set_sim_time_ns_long_proc(cdn_demo_get_sim_time_ns_long_proc_t sim_time_proc);



   uint32_t CPS_UncachedRead32(volatile uint32_t *address);
   void CPS_UncachedWrite32(volatile uint32_t *address, uint32_t value);

   uint32_t csp_read32(volatile uint32_t *addr);
   void csp_write32(volatile uint32_t *addr, uint32_t data);

   void cdn_demo_write8(uint64_t addr, unsigned int val);
   unsigned int cdn_demo_read8(uint64_t addr);
   void cdn_demo_write16(uint64_t addr, unsigned int val);
   unsigned int cdn_demo_read16(uint64_t addr);
   void cdn_demo_write32(uint64_t addr, unsigned int val);
   unsigned int cdn_demo_read32(uint64_t addr);


  /** Reads single byte from system memory (without address translation / mapping)
   * \param address Access' base address
   * \param offset Offset of byte to be read (relative to base address)
   * \return Value read from system memory
   */
  unsigned int cdn_demo_read_raw8(void *address, int offset);

  /** Writes single byte to system memory (without address translation / mapping)
   * \param address Access' base address
   * \param offset Offset of byte to be written (relative to base address)
   * \param value Value of byte to be written
   * \return void
   */
  void cdn_demo_write_raw8(void *address, int offset, unsigned int value);


   /** Gets current simulation time (expressed in nanoseconds)
    * \return Current simulation time (expressed in nanoseconds;
    *         returned as 64bit value, negative if not available)
    */
   int64_t cdn_demo_get_sim_time_ns_long();


   extern void csp_demo_read32 (int _a1, unsigned int *_a2);
   extern void csp_demo_write32 (int _a1, int _a2);
   extern int csp_delay_us (int _a1);
   extern void csp_printf_error(const char* msg);
   extern void csp_printf_warning(const char* msg);
   extern void csp_printf_debug(const char* msg);
   extern void csp_printf_info(const char* msg);
   extern void cdn_demo_get_gpio(uint64_t *gpio);
   extern void cdn_demo_set_gpio(uint64_t gpio, uint64_t mask);
   extern int unsigned get_urandom ();

   #ifndef _HAVE_DBG_LOG_INT_
   unsigned int g_dbg_log_lvl;
   unsigned int g_dbg_log_cnt;
   unsigned int g_dbg_state;
   unsigned int g_dbg_enable_log;
   #endif



  // ******** Threading ********

  /** Type def for thread routine
   * \param id Thread ID
   * \param param Parameter to be passed to the thread
   * \return void
   */
  typedef void (*cdn_demo_thread_proc_t)(int id, void *param);


  /** Spawns thread with given parameter
   * \param param Parameter to be passed to the thread
   * \param proc Thread routine pointer
   * \return ID of spawned threads
   */
  extern int cdn_demo_spawn_thread(void *param, cdn_demo_thread_proc_t proc);



  // ******** String based communication ********

  /** Pointer to string listener callback routine (called when string message arrives from SV UVM TB)
   * \param str String received from UVM TB
   * \return void
   */
  typedef void (*cdn_demo_string_listener_cb_proc_t)(const char *str);


  /** Adds string listener callback routine
   * \param cb_proc String listener callback routine
   * \return Number of listeners registered (including this one, negative if error)
   */
  int cdn_demo_add_string_listener(cdn_demo_string_listener_cb_proc_t cb_proc);


  /** Passes string value to the UVM TB (wraps task-like declaration)
   * \param str String to be passed to UVM TB
   * \return void
   */
  void cdn_demo_pass_str_to_tb(const char *str);


  extern int cdn_demo_on_new_str_msg_to_sv_cb(const char *str);


#endif // _CDN_DEMO_H_

