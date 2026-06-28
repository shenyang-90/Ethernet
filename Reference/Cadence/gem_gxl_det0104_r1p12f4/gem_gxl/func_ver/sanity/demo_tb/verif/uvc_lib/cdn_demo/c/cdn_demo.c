//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// See header file for full details.
//----------------------------------------------------------------------------

//#define CDN_DEMO_DEBUG

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <inttypes.h>
#include <assert.h>
#include "cdn_demo.h"


#ifdef CDN_DEMO_DEBUG
#  include <unistd.h>
#  include <execinfo.h>
#endif //#ifdef CDN_DEMO_DEBUG

#ifndef _HAVE_DBG_LOG_INT_
  unsigned int g_dbg_log_lvl = 1;
  unsigned int g_dbg_log_cnt = 0;
  unsigned int g_dbg_state = 0;
  unsigned int g_dbg_enable_log = 0xffffffff;
#endif


static int      s_verbosity  = 1;

/** Function pointer which is used to discriminate if CPS_UncachedRead32 and
 *  CPS_UncachedWrite32 accesses are directed to a register or to a DMA
 *  descriptor.
 *  Protocols should connect it to an actual implementation if needed.
 */
cdn_demo_is_addr_inside_hw_map          fptr_is_addr_inside_hw_map  = NULL;

/** Pointer to address re-maping routine (maps physical address to pointer)
 * \remarks See type description for parameters / return value reference
 */
cdn_demo_remap_addr_proc_t              g_remap_addr_proc           = NULL;


/** Macro for re-mapping physical address to logical pointer
 * \remarks See type description for parameters / return value reference
 */
#define GET_LOG_ADDR(phys_addr,bytes_count) \
  (g_remap_addr_proc != NULL ? g_remap_addr_proc((phys_addr),(bytes_count)) : (void*)(phys_addr))



/** Pointer to physical address query routine
 * \remarks See type description for parameters / return value reference
 */
cdn_demo_query_phys_addr_proc_t         s_query_phys_addr_proc      = NULL;


  /** Pointer to function that queries for SFR name
   * \remarks
   */
cdn_demo_query_sfr_name_proc_t          s_query_sfr_name_proc       = NULL;


/** Pointer to function that returns current simulation time
 * \return Current simulation time (expressed in nanoseconds; returned as 64bit value)
 */
cdn_demo_get_sim_time_ns_long_proc_t    s_get_sim_time_ns_long_proc = NULL;


/** Macro intended to be a CDN_DEMO_TB wraper for platform-specific printf
 * \param ... printf() arguments
 * \return Number of characters actually printed (same as for printf())
 */
#ifndef CDN_DEMO_PRINTF
#  define CDN_DEMO_PRINTF(...)      vpi_printf(__VA_ARGS__)
#endif


/** Prints message header (time etc.) */
#define CDN_DEMO_PRINT_MSG_HDR \
          {                                                     \
            int64_t time_ns = cdn_demo_get_sim_time_ns_long();  \
            if (time_ns >= 0)                                   \
              CDN_DEMO_PRINTF("@%" PRId64 "ns: ", time_ns);     \
          }


/** Prints debug message
 * \param verb Verbosity level (<=0 - print always, other - depends on local verbosity level)
 */
#ifdef CDN_DEMO_DEBUG

#  define CDN_DEMO_MSG(verb,...)                        \
            {                                           \
              if ((verb) <= 0 || (verb) <= s_verbosity) \
              {                                         \
                CDN_DEMO_PRINT_MSG_HDR                  \
                CDN_DEMO_PRINTF(__VA_ARGS__);           \
              }                                         \
            }

#  define CDN_DEMO_MEM_ACC_MSG(verb,fun_name,phys_addr,log_ptr,byte_size,...)   \
            {                                                                   \
              if ((verb) <= 0 || (verb) <= s_verbosity)                         \
              {                                                                 \
                describe_mem_access((fun_name),(phys_addr),(log_ptr),(byte_size));  \
                CDN_DEMO_PRINT_MSG_HDR                                          \
                CDN_DEMO_PRINTF(__VA_ARGS__);                                   \
              }                                                                 \
            }

#else

#  define CDN_DEMO_MSG(verb,...)                                                {}
#  define CDN_DEMO_MEM_ACC_MSG(verb,fun_name,phys_addr,log_ptr,byte_size,...)   {}

#endif



/** Sets verbosity level for CDN_DEMO
 * \param new_verbosity New verbosity level
 * \return void
 */
void cdn_demo_set_verbosity(int new_verbosity)
{
  if (new_verbosity < 0)
    return;

  CDN_DEMO_MSG(1, "[cdn_demo_set_verbosity] Setting verbosity to %d\n", new_verbosity);

  s_verbosity = new_verbosity;

} //void cdn_demo_set_verbosity(...




/** Sets address re-mapping routine (phys. addr. -> pointer)
 * \param remap_proc Pointer to re-mapping routine
 * \return void
 */
void cdn_demo_set_remap_addr_proc(cdn_demo_remap_addr_proc_t remap_proc)
{
  CDN_DEMO_MSG(1, "[cdn_demo_set_remap_addr_proc] Setting routine to 0x%" PRIxPTR "\n",
    (uintptr_t)remap_proc);

  g_remap_addr_proc = remap_proc;

} //void cdn_demo_set_remap_addr_proc(...



/** Sets phys. address query routine
 * \param addr_query_proc Pointer to address query routine
 * \return void
 */
void cdn_demo_set_query_phys_addr_proc(cdn_demo_query_phys_addr_proc_t addr_query_proc)
{
  CDN_DEMO_MSG(1, "[cdn_demo_set_remap_addr_proc] Setting routine to 0x%" PRIxPTR "\n",
    (uintptr_t)addr_query_proc);

  s_query_phys_addr_proc = addr_query_proc;

} //void cdn_demo_set_remap_addr_proc(...


/** SetsSFR name query routine
 * \param sfr_query_proc Pointer to SFR query routine
 * \return void
 */
void cdn_demo_set_query_sfr_name_proc(cdn_demo_query_sfr_name_proc_t sfr_query_proc)
{
  CDN_DEMO_MSG(1, "[cdn_demo_set_query_sfr_name_proc] Setting routine to 0x%" PRIxPTR "\n",
    (uintptr_t)sfr_query_proc);

  s_query_sfr_name_proc = sfr_query_proc;

} //void cdn_demo_set_query_sfr_name_proc(...


/** Sets simulation time obtaining routine (returns simulation time expressed in nanoseconds)
 * \param sim_time_proc Pointer to sim. time routine
 * \return void
 */
void cdn_demo_set_sim_time_ns_long_proc(cdn_demo_get_sim_time_ns_long_proc_t sim_time_proc)
{
  CDN_DEMO_MSG(1, "[cdn_demo_set_sim_time_ns_long_proc] Setting routine to 0x%" PRIxPTR "\n",
    (uintptr_t)sim_time_proc);

  s_get_sim_time_ns_long_proc = sim_time_proc;

} //void cdn_demo_set_sim_time_ns_long_proc(...



#ifdef CDN_DEMO_DEBUG
static void describe_mem_access(const char *fun_name, uint64_t phys_addr, void *log_ptr,
  size_t byte_size)
{
  char tmp_str[256];

  snprintf(tmp_str, sizeof(tmp_str) - 1, "[%s] phys.addr/log.ptr=0x%08x%08x/0x%08x%08x ",
    fun_name,
    (uint32_t)((phys_addr >> 32) & 0xFFFFFFFFull),
    (uint32_t)(phys_addr & 0xFFFFFFFFull),
    (uint32_t)(((uintptr_t)log_ptr >> 32) & (uintptr_t)0xFFFFFFFF),
    (uint32_t)((uintptr_t)log_ptr & (uintptr_t)0xFFFFFFFF)
  );

  CDN_DEMO_PRINTF(tmp_str);

  if (s_query_phys_addr_proc != NULL)
  {
    const char *block_name;
    intptr_t block_offs;
    int status;

    status = s_query_phys_addr_proc(phys_addr, byte_size, &block_name, &block_offs);

    if (status == 0 && block_name != NULL)
      CDN_DEMO_PRINTF("(%s+0x%" PRIxPTR ") ", block_name, block_offs);
  }

} //static void describe_mem_access(...
#endif



#ifdef CDN_DEMO_DEBUG
static void describe_sfr_access(const char *fun_name, uintptr_t sfr_addr, size_t byte_size)
{
  CDN_DEMO_PRINTF("[%s] addr=0x%" PRIxPTR " ", sfr_addr);

  if (s_query_sfr_name_proc != NULL)
  {
    const char *sfr_name = s_query_sfr_name_proc(sfr_addr);

    if (sfr_name != NULL)
      CDN_DEMO_PRINTF("(%s) ", sfr_name);
  }

} //static void describe_sfr_access(...
#endif




void print_backtrace()
{
#ifdef CDN_DEMO_DEBUG
  int i;
  void *stack_frames_arr[200];
  char **lines = NULL;
  int stack_frames_count = backtrace(stack_frames_arr, 200);
  printf("Backtrace:\n");
  lines = backtrace_symbols(stack_frames_arr, stack_frames_count);
  for (i = 0; i < stack_frames_count; i++)
    printf("  %d) %s\n", i, lines[i]);
  free(lines);
  printf("...backtrace end\n");
#endif //#ifdef CDN_DEMO_DEBUG
}


void cdn_demo_write8(uint64_t address, unsigned int val)
{
  uint8_t
    *ptr = GET_LOG_ADDR(address, 1);

  CDN_DEMO_MEM_ACC_MSG(1,"cdn_demo_write8",address,ptr,1,"val=0x%02x\n", val)

  *ptr = val;
}



unsigned int cdn_demo_read8(uint64_t address)
{
  uint8_t
    *ptr = GET_LOG_ADDR(address, 1),
    result;

  CDN_DEMO_MEM_ACC_MSG(1,"cdn_demo_read8",address,ptr,1," ... ")

  result = *ptr;

  CDN_DEMO_MSG(1, " data=0x%02x\n", (unsigned int)result);

  return result;
}



void cdn_demo_write16(uint64_t address, unsigned int val)
{
  uint16_t
    *ptr = GET_LOG_ADDR(address, 2);

  CDN_DEMO_MEM_ACC_MSG(1,"cdn_demo_write16",address,ptr,2,"val=0x%04x\n", val)

  *ptr = val;
}



unsigned int cdn_demo_read16(uint64_t address)
{
  uint16_t
    *ptr = GET_LOG_ADDR(address, 2),
    result;

  CDN_DEMO_MEM_ACC_MSG(1,"cdn_demo_read16",address,ptr,2," ... ")

  result = *ptr;

  CDN_DEMO_MSG(1, " data=0x%04x\n", (unsigned int)result);

  return result;
}


void cdn_demo_write32(uint64_t address, unsigned int val)
{
  uint32_t
    *ptr = GET_LOG_ADDR(address, 4);

  CDN_DEMO_MEM_ACC_MSG(1,"cdn_demo_write32",address,ptr,4,"val=0x%08x\n", val)

  *ptr = val;
}



unsigned int cdn_demo_read32(uint64_t address)
{
  uint32_t
    *ptr = GET_LOG_ADDR(address, 4),
    result;

  CDN_DEMO_MEM_ACC_MSG(1,"cdn_demo_read32",address,ptr,4," ... ")

  result = *ptr;

  CDN_DEMO_MSG(1, " data=0x%08x\n", (unsigned int)result);

  return result;
}



uint32_t CPS_UncachedRead32(volatile uint32_t *address)
{
   unsigned int _result;

  CDN_DEMO_MSG(1, "[CPS_UncachedRead32]  address=0x%" PRIxPTR " ... ",
    (uintptr_t)address);

  if(fptr_is_addr_inside_hw_map == NULL || fptr_is_addr_inside_hw_map((uintptr_t)address) == 1) {
    CDN_DEMO_MSG(1, "[CPS_UncachedRead32] performing HW access | fptr_is_addr_inside_hw_map=0x%" PRIxPTR "\n",
      (uintptr_t)fptr_is_addr_inside_hw_map);
    csp_demo_read32((uintptr_t)address, (unsigned int*)&_result);
  } else {
    CDN_DEMO_MSG(1, "[CPS_UncachedRead32] performing SW access");
    _result = *address;
  }

  CDN_DEMO_MSG(1, " val=0x%08x\n", _result);

  return _result;
}



void CPS_UncachedWrite32(volatile uint32_t *address, uint32_t value)
{
  CDN_DEMO_MSG(1, "[CPS_UncachedWrite32] address=0x%" PRIxPTR " val=0x%08x\n",
    (uintptr_t)address, value);

  if(fptr_is_addr_inside_hw_map == NULL || fptr_is_addr_inside_hw_map((uintptr_t)address) == 1) {
    CDN_DEMO_MSG(1, "[CPS_UncachedWrite32] performing HW access | fptr_is_addr_inside_hw_map=0x%" PRIxPTR "\n",
      (uintptr_t)fptr_is_addr_inside_hw_map);
    csp_demo_write32((uintptr_t)address, (int)value);
  } else {
    CDN_DEMO_MSG(1, "[CPS_UncachedWrite32] performing SW access");
    *address = value;
  }
}



uint32_t csp_read32(volatile uint32_t *addr)
{
   unsigned int _result;

  CDN_DEMO_MSG(1, "[csp_read32]  address=0x%" PRIxPTR " ... ",
    (uintptr_t)addr);

   csp_demo_read32((uintptr_t)addr, (unsigned int*)&_result);

  CDN_DEMO_MSG(1, " val=0x%08x\n", _result);

   return (uint32_t)_result;
}



void csp_write32(volatile uint32_t *addr, uint32_t data)
{
  CDN_DEMO_MSG(1, "[csp_write32] address=0x%" PRIxPTR " val=0x%08x\n",
    (uintptr_t)addr, data);

   csp_demo_write32((uintptr_t)addr, (int)data);
}


/** Gets current simulation time (expressed in nanoseconds)
 * \return Current simulation time (expressed in nanoseconds;
 *         returned as 64bit value, negative if not available)
 */
int64_t cdn_demo_get_sim_time_ns_long()
{
  return (s_get_sim_time_ns_long_proc != NULL) ? s_get_sim_time_ns_long_proc() : -1;

} //int64_t cdn_demo_get_sim_time_ns_long()



/** Reads single byte from system memory (without address translation / mapping)
 * \param address Access' base address
 * \param offset Offset of byte to be read (relative to base address)
 * \return Value read from system memory
 */
unsigned int cdn_demo_read_raw8(void *address, int offset)
{
  uint8_t *ptr = (uint8_t*)address + offset;

  return (unsigned int)(*ptr);

} //unsigned int cdn_demo_read_raw8(...



/** Writes single byte to system memory (without address translation / mapping)
 * \param address Access' base address
 * \param offset Offset of byte to be written (relative to base address)
 * \param value Value of byte to be written
 * \return void
 */
void cdn_demo_write_raw8(void *address, int offset, unsigned int value)
{
  uint8_t *ptr = (uint8_t*)address + offset;

  *ptr = (uint8_t)value;

} //void cdn_demo_write_raw8(...

/** ---------------------------------------------------
 * \brief UVM/SV irq_handler
 *
 * The underlying UVM/SV calls this function at an interrupt. The
 * test may implement an irq_handler, but this is not necessary. This
 * function therefore checks if an irq_handler has been implemented, and if
 * so, calls this interrupt handler.
 *
 */

void cdn_demo_irq_handler(void* DeviceID) {
  csp_printf_info("irq_handler callback");
  if (irq_handler != NULL) {
    irq_handler(DeviceID);
  } else {
    csp_printf_info("irq_handler not implemented");
  }
  csp_printf_info("irq_handler callback complete");
}

/** ---------------------------------------------------
 * \brief UVM/SV set_config
 *
 * The underlying UVM/SV imports this function and calls it at
 * set_config. setconfig can be used in a base test at the build_phase
 * to pass uvm_config_db settings to the underlying UVM/SV testbench using
 * the  cdn_demo_pass_str_to_tb function.
 */

void cdn_demo_set_config() {
  printf("set_config callback\n");
  if (set_config != NULL) {
    set_config();
  } else {
    printf("set_config not implemented\n");
  }
  printf("set_config callback complete\n");
}




// ******** Threading ********

/** Internal routine that spawns thread (to be called from SV code)
 * \param id ID of spawned thread
 * \param param Parameter to be passed to the thread
 * \param proc Thread routine
 * \return void
 */
void cdn_demo_launch_thread(int id, void *param, cdn_demo_thread_proc_t proc)
{
  proc(id, param);
}



// ******** String based communication ********

#ifndef CDN_DEMO_MAX_STRING_LISTENERS
#  define CDN_DEMO_MAX_STRING_LISTENERS   16
#endif

/** Array with registered string listeners */
static cdn_demo_string_listener_cb_proc_t   s_cdn_demo_str_listeners[CDN_DEMO_MAX_STRING_LISTENERS];

/** Number of registered string listeners */
static int                                  s_cdn_demo_str_listeners_count = 0;



/** Adds string listener callback routine
 * \param cb_proc String listener callback routine
 * \return Number of listeners registered (including this one, negative if error)
 */
int cdn_demo_add_string_listener(cdn_demo_string_listener_cb_proc_t cb_proc)
{
  if (s_cdn_demo_str_listeners_count >= CDN_DEMO_MAX_STRING_LISTENERS)
    return -1;

  s_cdn_demo_str_listeners[s_cdn_demo_str_listeners_count++] = cb_proc;

  return s_cdn_demo_str_listeners_count;

} //int cdn_demo_add_string_listener(...



/** C-side callback called when new string message arrives from UVM/SV
 * \param str String to be passed to C
 */
int cdn_demo_on_new_str_msg_to_c_cb(const char *str)
{

  if (s_cdn_demo_str_listeners_count < 1)
    printf("[WARNING][cdn_demo_on_new_str_msg_to_c_cb] No string listeners registered !!!\n");

  for (int i = 0; i < s_cdn_demo_str_listeners_count; i++)
    s_cdn_demo_str_listeners[i](/*str*/str);

  return 0;

} //int cdn_demo_on_new_str_msg_to_c_cb(...



/** Passes string value to the UVM TB (wraps task-like declaration)
 * \param str String to be passed to UVM TB
 * \return void
 */
void cdn_demo_pass_str_to_tb(const char *str)
{
  cdn_demo_on_new_str_msg_to_sv_cb(/*str*/str);
}



