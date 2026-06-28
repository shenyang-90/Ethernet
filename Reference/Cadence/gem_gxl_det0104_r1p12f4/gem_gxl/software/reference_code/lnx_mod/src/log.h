/**********************************************************************
 * Copyright (C) 2014-2016 Cadence Design Systems, Inc.
 * All rights reserved.
 ***********************************************************************
 * log.h
 * System wide debug log messaging framework - modified version
 * for Linux kernel, avoiding stdio's printf
 ***********************************************************************/

#ifndef _HAVE_DBG_LOG_
#define _HAVE_DBG_LOG_ 1

//#define _UNCONDITIONAL_LOG_

#if defined(DEBUG) && !defined(CFP_DBG_MSG)
#define CFP_DBG_MSG 1
#endif

#if defined(CFP_DBG_MSG) && !defined(_UNCONDITIONAL_LOG_)
#define _UNCONDITIONAL_LOG_
#endif

#ifdef _UNCONDITIONAL_LOG_
#include <linux/kernel.h>
#endif

/**
 * Modules definitions
 */
#define JXD_MSG            0x00000001
#define NFF_MSG            0x00000002
#define CLIENT_MSG         0x01000000
#define JX_MODEL_MSG       0x00000100
#define NVME_MODEL_MSG     0x00000200
#define CPS_OP             0x00200000

#define DBG_GEN_MSG        0xFFFFFFFF

#ifdef _UNCONDITIONAL_LOG_
  /* module mask: */
  #ifdef _HAVE_DBG_LOG_INT_
    unsigned int g_dbg_enable_log  = 0;
  #else
    extern unsigned int g_dbg_enable_log;
  #endif

  /* level, counter, state: */
  #ifdef _HAVE_DBG_LOG_INT_
    unsigned int g_dbg_log_lvl = 0;
    unsigned int g_dbg_log_cnt = 0;
    unsigned int g_dbg_state = 0;
  #else
    extern unsigned int g_dbg_log_lvl;
    extern unsigned int g_dbg_log_cnt;
    extern unsigned int g_dbg_state;
  #endif

  /**
   * Log level:
   * 0 - critical
   * 5 - warning
   * 10 - fyi
   * 100 - highly verbose
   * 200 - infinite loop debug
   */
#define DBG_CRIT 0
#define DBG_WARN 5
#define DBG_FYI 10
#define DBG_HIVERB 100
#define DBG_INFLOOP 200

  #define DbgMsgSetLvl( x ) (g_dbg_log_lvl = x)
  #define DbgMsgEnableModule( x ) (g_dbg_enable_log |= (x) )
  #define DbgMsgDisableModule( x ) (g_dbg_enable_log &= ~( (unsigned int) (x) ))
  #define DbgMsgClearAll( _x ) ( g_dbg_enable_log = _x )
  #define SetDbgState( _x ) (g_dbg_state = _x )
  #define GetDbgState       (g_dbg_state)
  /*
   * cDbgMsg is reserved for error messages that MUST be part of the binary even if
   * the debug subsystem is turned off. This is reserved for critical error messages.
   */
  #define cDbgMsg( _t, _x, ...) ( ((_x)==  0) || \
                                (((_t) & g_dbg_enable_log) && ((_x) <= g_dbg_log_lvl)) ? \
                                pr_emerg( __VA_ARGS__): 0 )
#else /* _UNCONDITIONAL_LOG_ */
  #define DbgMsgSetLvl( x )
  #define DbgMsgEnableModule( x )
  #define DbgMsgDisableModule( x )
  #define DbgMsgClearAll( _x )
  #define SetDbgState( _x )
  #define GetDbgState

  #define cDbgMsg( _t, _x, ...)
#endif /* _UNCONDITIONAL_LOG_ */


#ifdef CFP_DBG_MSG
  #define DbgMsg( t, x, ...)  cDbgMsg( t, x, __VA_ARGS__ )
  #define vDbgMsg( l, m, n, ...) DbgMsg( l, m, "[%-20.20s %4d %4d]-" n, __func__,\
                                                   __LINE__, g_dbg_log_cnt++, __VA_ARGS__)
  #define cvDbgMsg( l, m, n, ...) cDbgMsg( l, m, "[%-20.20s %4d %4d]-" n, __func__,\
                                                   __LINE__, g_dbg_log_cnt++, __VA_ARGS__)
  /*
   * Complex display elements
   */
  #define vDbgPBar(l, m, n, o ) vDbgMsg( l, m, "[ %8d/%8d ]", n, o )
  #define vDbgUpdatePBar(l, m, n, o ) DbgMsg( l, m, "[ %8d/%8d ]", n, o )
  #define vDbgComplPBar(l,m) DbgMsg(l, m, "\n");
#else
  #define DbgMsg( t, x, ...)
  #define vDbgMsg( l, m, n, ...)
  #define cvDbgMsg( l, m, n, ...)
  #define vDbgPBar(l, m, n, o )
  #define vDbgUpdatePBar(l, m, n, o )
  #define vDbgComplPBar(l,m)
#endif

#endif /* _HAVE_DBG_LOG_ */
