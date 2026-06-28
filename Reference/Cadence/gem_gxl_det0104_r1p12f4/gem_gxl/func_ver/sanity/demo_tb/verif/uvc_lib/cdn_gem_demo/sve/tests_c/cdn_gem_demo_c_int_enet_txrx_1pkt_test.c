//------------------------------------------------------------------------------
// File      : cdn_gem_demo_c_int_enet_txrx_1pkt_test.c
// Author    : bemanuel@cadence.com
// Date      : 3rd July, 2017
//------------------------------------------------------------------------------
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
//------------------------------------------------------------------------------
/*!
// @page cdn_gem_demo_c_int_enet_txrx_1pkt_test
// 
// Description
// ===========
//
// The DUT sends and receive a packet in loopback mode using the Cadence core 
// driver.
//
// 1. Core Driver Initialization.
// 2. DUT Initialization.
//    * If the internal loopback is not available in the design, the external 
//      loopback is enabled by writing to the network control register.
// 3. Send a packet.
// 4. Wait for the packet to be received.
// 5. Print transaction statistics.
//    * Note that in order for this test to run statistic register must be
//      present in the design.
// 6. End the test by freeing buffers.
*/
//------------------------------------------------------------------------------

/*! \file cdn_gem_demo_c_int_enet_txrx_1pkt_test.c
 *  \brief This file defines a Tx-Rx test.
 *         The DUT sends and receive a packet in loopback mode using the Cadence
 *         core driver.
 */

// When using debug verbosity in tests, if _HAVE_DBG_LOG_INT_ is not define the 
// debug variables are declared as extern.
// For UVM-SV, they are instanced in cdn_demo.c if this is the case.
// For CSP, they are not instanced in the CSP source. Therefore, we must have 
// _HAVE_DBG_LOG_INT_ defined here.
#ifndef CDN_DEMO_TB
  #ifdef DEBUG
    #define _HAVE_DBG_LOG_INT_ 1
  #endif
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "cdn_errno.h"
#include "emac_regs.h"
#include "log.h"
#include "cedi.h"
#include "edd_int.h"
#include "edd_test_supp.h"

// If running over UVM-SV use cdn_demo.h and cdn_gem_demo.h libraries.
// If running over CSP use csp.h and cps.h libraries.
#ifdef CDN_DEMO_TB
  #include "cdn_demo.h"
  #include "cdn_gem_demo.h"
#else
  #include "csp.h"
  #include "cps.h"
#endif

#include "cdn_gem_demo_test_supp.h"
#include "map_system_memory.h"

//--------------------------------------
// Typedefs
//--------------------------------------

/* test-environment printf defn for compatibility with Cadence environment */
typedef int    (*env_printf)     (const char *, ...);
typedef struct {
    env_printf     printf;
} envOp;

//--------------------------------------
// Global Variables and Functions
//--------------------------------------

extern CEDI_PrivateData *privData[2];
extern CEDI_OBJ         *emacObj[2];
extern CEDI_BuffAddr    aBuf[CEDI_MAX_RX_QUEUES][MAX_TEST_RBQ_LENGTH]; /* initial rx buffers */
extern CEDI_BuffAddr    nBuf[CEDI_MAX_RX_QUEUES][MAX_TEST_RBQ_LENGTH]; /* new rx buffers to swap in */
extern uint16_t         rxBufLenBytes[CEDI_MAX_RX_QUEUES], oldIndex[CEDI_MAX_RX_QUEUES], newIndex[CEDI_MAX_RX_QUEUES];
extern uint32_t         rxFrameCount[2][CEDI_MAX_RX_QUEUES];
extern uint32_t         txFrComplete[2][CEDI_MAX_TX_QUEUES];

// If running over UVM-SV, use fptr_is_addr_inside_hw_map to correctly implement 
// CSP_UncachedRead32 and CPS_UncachedWrite32 for GEM_GXL
#ifdef CDN_DEMO_TB
  extern cdn_demo_is_addr_inside_hw_map fptr_is_addr_inside_hw_map;
#endif

//--------------------------------------
// Local Variables and Functions
//--------------------------------------

envOp bmEnv;

//--------------------------------------
// Main
//--------------------------------------

/*! \fn int main(int argc, char ** _argv)
 *  \brief Each C test is a main function.
 *         Multiple main functions are compatible since a test is compiled only 
 *         when it is called and only one test can be called at a time.
 *         Returns 0 if the test passes, 1 otherwise.
 *  \param argc The argument count.
 *  \param _argv The argument value. 
 */
int main(int argc, char ** _argv) {

  /* ----- Setup ----- */

  // If running over UVM-SV, attach fptr_is_addr_inside_hw_map (cdn_demo.h) to 
  // is_addr_inside_hw_map (cdn_gem_demo.h). Also, use the demo TB API printf
  // for logging.
  // If running over CSP, use the standard printf for logging.
  #ifdef CDN_DEMO_TB
    bmEnv.printf = (env_printf)cdn_demo_printf_info;
    fptr_is_addr_inside_hw_map = &is_addr_inside_hw_map;
  #else
    bmEnv.printf = (env_printf)printf;
  #endif

  /* ----- Variables Declaration ----- */

  void *cddcInst = &bmEnv;
  int passed = 1;
  uint32_t result, i, t, qNum;
  cddcOp *cInst = (cddcOp *)cddcInst;
  uint32_t txLen;
  uint8_t txOk, rxOk;
  CEDI_BuffAddr txBuf;
  CEDI_TxDescData txDescDat;
  CEDI_RxDescData rxDescDat;
  CEDI_BuffAddr freeBuf, tmpBuf;
  ethHdr_t header1;
  uint16_t nBufs;
  uint16_t rxBufSizeReq = 1024;
  const int emacA = 0;
  CEDI_MacAddress emacAddr1 = { {100, 0, 1,   2, 3, 4} };
  CEDI_MacAddress emacAddr2 = { {100, 0, 200, 2, 3, 4} };
  //uint32_t reg;

  /* ----- Driver Initialization ----- */

  csp_printf_format_info("TEST STEP 1  | Driver initialization");

  if (0!=(result=testSetup(cInst, emacA, TXQ_SIZE, RXQ_SIZE, rxBufSizeReq, NULL))) {
    csp_printf_format_info("Creating Obj 0 - Invalid return value: %d", result);
    printFailed;
    return 1;
  }

  if (EMAC_REGS__NETWORK_CONFIG__PCS_SELECT__READ(CPS_UncachedRead32(regAddr(emacA, network_config)))) {
    csp_printf_format_info("NOTE: this test is not available when in PCS mode.");
    return 0;
  }
  zeroCallbackCounters();
  qNum = 0;

  /* ----- DUT Initialization ----- */

  csp_printf_format_info("TEST STEP 2  | DUT initialization");

  // Prepare Rx
  rxBufLenBytes[0] = privData[emacA]->cfg.rxBufLength[0]<<6;
  for (i=0; i<privData[emacA]->cfg.rxQLen[0]; i++) {
    // Allocate some buffers
    if (0!=allocBuffer(rxBufLenBytes[0], 0xFAFA0000, &aBuf[0][i])) {
      csp_printf_format_info("Error allocating Rx buffer(%u)", i);
      printFailed;
      return 1;
    }
    if (0!=(result = emacObj[emacA]->addRxBuf(privData[emacA], qNum, &aBuf[0][i], 0))) {
      csp_printf_format_info("error in AddRxBuf call: returned %u", result);
      printFailed;
      return 1;
    }
  }

  // The oldIndex is first swap-in (or "new") buffer in nBuf array
  oldIndex[0] = (privData[emacA]->rxQueue[0].rxTailVA - privData[emacA]->rxQueue[0].rxBufVAddr)/sizeof(uintptr_t);

  // The newIndex is where to add new buffer in nBuf[]
  newIndex[0] = oldIndex[0];

  // Allocate a spare buffer to swap in
  if (0!=allocBuffer(rxBufLenBytes[0], 0xABCD0000, &nBuf[0][newIndex[0]])) {
    csp_printf_format_info("Error allocating new Rx buffer(%u)(%u)", 0, newIndex[0]);
    printFailed;
    return 1;
  }

  // Enable loopback mode
  result = emacObj[emacA]->setLoopback(privData[emacA], CEDI_LOCAL_LOOPBACK);
  if (ENOTSUP == result){
    // If the internal loopback is not available in the current
    // configuration, test can still run since external loopback is enabled in 
    // the testbench by default
    csp_printf_format_info("Internal loopback not available, external loopback is enabled in the testbench by default");
    //reg = CPS_UncachedRead32(regAddr(emacA, network_control));
    //reg = reg + 0x00000001;
    //CPS_UncachedWrite32(regAddr(emacA, network_control), reg);
  }

  emacObj[emacA]->setCopyAllFrames(privData[emacA], 1);

  // Start EMAC + enable Rx & Tx
  emacObj[emacA]->start(privData[emacA]);
  emacObj[emacA]->enableRx(privData[emacA]);
  emacObj[emacA]->enableTx(privData[emacA]);

  // Bare frame without FCS
  txLen = 100;

  // Allocate a buffer for tx frame and fill with pattern
  if (0!=allocBuffer(txLen, 0xBADA5500, &txBuf)) {
    csp_printf_format_info("Error allocating Tx buffer");
    printFailed;
    return 1;
  }

  // Set up frame header
  memset(&header1, 0, sizeof(ethHdr_t));
  memcpy(&header1.dest, &emacAddr2, sizeof(CEDI_MacAddress));
  memcpy(&header1.srce, &emacAddr1, sizeof(CEDI_MacAddress));
  header1.typeLenMsb=0x08;
  header1.typeLenLsb=0x00;

  // Copy into data buffer (16-bit words)
  for (i=0; i<sizeof(ethHdr_t)/sizeof(uint16_t); i++)
    CPS_UncachedWrite16((uint16_t *)(txBuf.vAddr)+i, ((uint16_t *)&header1)[i]);

  /* ----- Transaction ----- */

  csp_printf_format_info("TEST STEP 3  | Sending frame on Q%u", qNum);

  emacObj[emacA]->clearStats(privData[emacA]);
  
  // Queue frame for Tx, using auto-CRC
  result = emacObj[emacA]->queueTxBuf(privData[emacA], qNum, &txBuf, txLen, CEDI_TXB_LAST_BUFF);
  if (0 != result) {
    csp_printf_format_info("queueTxBuf(): Invalid return value: %d", result);
    passed = 0;
    goto done;
  }
  printTxDescList(cInst, privData[emacA], qNum);
  txOk = 0;
  rxOk = 0;

  /* ----- Wait for Transaction Completion ----- */

  csp_printf_format_info("TEST STEP 4  | Waiting for transmission to complete");

  // Now wait for tx frame complete & rx status to clear
  for (t = 300; (!txOk || !rxOk) && t; --t) {
    emacObj[emacA]->isr(privData[emacA]);
    if (!txOk && txFrComplete[emacA][qNum]) {
      if (EINVAL==(result = emacObj[emacA]->freeTxDesc(privData[emacA], qNum, &txDescDat)))
        csp_printf_format_info("Error freeing Tx descriptor: returned %08X", result);
      else if (result==0) {
        txOk = (txDescDat.status==CEDI_TXDATA_1ST_AND_LAST);
      }
    }
    if (!rxOk && rxFrameCount[emacA][0]) {
      // If numRxUsed then call readRxBuf
      if (emacObj[emacA]->numRxUsed(privData[emacA], 0)) {
        printRxDescList(cInst, privData[emacA], 0);
        printRxVAddrList(cInst, privData[emacA], 0);
        // Note new buf until we see if swap in
        tmpBuf.vAddr = nBuf[0][newIndex[0]].vAddr;
        tmpBuf.pAddr = nBuf[0][newIndex[0]].pAddr;
        if (0!=(result = emacObj[emacA]->readRxBuf(privData[emacA], 0, &nBuf[0][newIndex[0]], 0, &rxDescDat))) {
          csp_printf_format_info("Error readRxBuf returned %u", result);
          passed = 0;
          goto done;
        }
        // Data was read
        if (rxDescDat.status!=CEDI_RXDATA_NODATA) {
          rxOk = 1;
          // Update descriptor reference for checking freed buffers
          aBuf[0][newIndex[0]].vAddr = tmpBuf.vAddr;
          aBuf[0][newIndex[0]].pAddr = tmpBuf.pAddr;
          newIndex[0] = (newIndex[0]+1) % privData[emacA]->cfg.rxQLen[0];
          // Allocate another buffer to swap in
          if (0!=allocBuffer(rxBufLenBytes[0], 0xABCD0000, &nBuf[0][newIndex[0]])) {
            csp_printf_format_info("Error allocating new Rx buffer(%u)(%u)", 0, newIndex[0]);
            passed = 0;
            goto done;
          }
        }
      }
    }
  }
  if (!t) {
    if (txOk && !rxOk)
      csp_printf_format_info("Receive timed out.");
    else if (!rxOk && !txOk)
      csp_printf_format_info("Transmit timed out.");
    else
      csp_printf_format_info("Timeout - Transmit not detected! (Rx OK)");
    passed = 0;
  }
  
  /* ----- Printing Statistics ----- */
  
  csp_printf_format_info("TEST STEP 5  | Printing statistics");

  if (0!=(result=emacObj[emacA]->readStats(privData[emacA])))
    csp_printf_format_info("Error reading statistics registers EMAC%u: returned %u", emacA, result);
  printStatsCopy(cInst, privData[emacA]);

  /* ----- Ending Test ----- */
  
  csp_printf_format_info("TEST STEP 6  | Ending Test");
  
  done:
  // Free Rx buffers except initial spare one
  for (; oldIndex[0]!=newIndex[0]; ) {
    if (0==NCPS_freeHWMem((uint32_t)nBuf[0][oldIndex[0]].vAddr)) {
      csp_printf_format_info("Error freeing Rx buffer nBuf(%u)(%u)", 0, oldIndex[0]);
    }
    oldIndex[0] = (oldIndex[0]+1) % privData[emacA]->cfg.rxQLen[0];
  }
  
  // Free Tx buffer
  if (txBuf.vAddr) {
    if (txBuf.vAddr!=(result=NCPS_freeHWMem((uint32_t)txBuf.vAddr)))
      csp_printf_format_info("Error freeing Tx data buffer: returned %08X", result);
  }

  // Disable local loopback mode
  emacObj[emacA]->setLoopback(privData[emacA], CEDI_NO_LOOPBACK);
  emacObj[emacA]->stop(privData[emacA]);

  // Free Rx buffers
  result = 0;
  emacObj[emacA]->numRxBufs(privData[emacA], 0, &nBufs);
  for (i=nBufs-1; result!=ENOENT; i--) {
    // Buffers in descriptor list
    result = emacObj[emacA]->removeRxBuf(privData[emacA], 0, &freeBuf);
    if (result==0) {
      if (0==NCPS_freeHWMem((uint32_t)freeBuf.vAddr)) {
        csp_printf_format_info("Error freeing Rx buffer(%u)(%u)", 0, i);
      }
    }
    else if (result!=ENOENT)
      csp_printf_format_info("Error from removeRxBuf call- result = %u", result);
  }
  
  // Swapped-out or spare Rx buffers
  while (oldIndex[0]!=newIndex[0]) {
    if (0==NCPS_freeHWMem((uint32_t)nBuf[0][oldIndex[0]].vAddr))
      csp_printf_format_info("Error freeing unused Rx buffer nBuf(%u)(%u)", 0, oldIndex[0]);
    oldIndex[0] = (oldIndex[0]+1) % privData[emacA]->cfg.rxQLen[0];
  }
  if (0==NCPS_freeHWMem((uint32_t)nBuf[0][oldIndex[0]].vAddr))
    csp_printf_format_info("Error freeing spare Rx buffer nBuf(%u)(%u)", 0, oldIndex[0]);
  testTearDown(cInst, emacA);

  if(!passed)
    csp_printf_format_error("Test finished with errors!");

  return 0;
}

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------

