/******************************************************************************
 * Copyright (C) 2014-2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 *
 * The material contained herein is the proprietary and confidential
 * information of Cadence or its licensors, and is supplied subject to, and may
 * be used only by Cadence's customer in accordance with a previously executed
 * license and maintenance agreement between Cadence and that customer.
 *
 ******************************************************************************
 *
 * Reference Test Code for Ethernet GEM Driver, based on the Cadence Test
 * environment with 2 GEM instances connected back-to-back.
 * loopbackTest only uses one instance.
 *
 *****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "cdn_errno.h"
#include "cps.h"
#include "emac_regs.h"
#include "log.h"
#include "cedi.h"
#include "edd_int.h"
#include "edd_test_supp.h"

extern CEDI_Callbacks core_callbacks;

extern CEDI_PrivateData *privData[2];
extern CEDI_OBJ *emacObj[2];

extern CEDI_BuffAddr aBuf[CEDI_MAX_RX_QUEUES][MAX_TEST_RBQ_LENGTH]; /* initial rx buffers */
extern CEDI_BuffAddr nBuf[CEDI_MAX_RX_QUEUES][MAX_TEST_RBQ_LENGTH]; /* new rx buffers to swap in */
extern uint16_t rxBufLenBytes[CEDI_MAX_RX_QUEUES], oldIndex[CEDI_MAX_RX_QUEUES], newIndex[CEDI_MAX_RX_QUEUES];
extern uint8_t txBuffer[MAX_JUMBO_FRAME_LENGTH+3];
extern uint8_t rxBuffer[MAX_JUMBO_FRAME_LENGTH];

extern uint32_t rxFrameCount[2][CEDI_MAX_RX_QUEUES];
extern uint32_t oldRxFrameCount[2][CEDI_MAX_RX_QUEUES];
extern uint32_t rxUsedRead[2][CEDI_MAX_RX_QUEUES];
extern uint32_t oldRxUsedRead[2][CEDI_MAX_RX_QUEUES];
extern uint32_t rxOverrun[2][CEDI_MAX_RX_QUEUES];
extern uint32_t oldRxOverrun[2][CEDI_MAX_RX_QUEUES];
extern uint32_t txUsedRead[2];
extern uint32_t oldTxUsedRead[2];
extern uint32_t txFrComplete[2][CEDI_MAX_TX_QUEUES];
extern uint32_t oldTxFrComplete[2][CEDI_MAX_TX_QUEUES];
/* params for Tx frame complete - */
extern uint32_t txFrBufAddr[2][CEDI_MAX_TX_QUEUES];
extern uint32_t txCbDescStat[2][CEDI_MAX_TX_QUEUES];
extern uint32_t txUnderrun[2];
extern uint32_t oldTxUnderrun[2];
extern uint32_t txRetryExc[2][CEDI_MAX_TX_QUEUES];
extern uint32_t oldTxRetryExc[2][CEDI_MAX_TX_QUEUES];
extern uint32_t txFrCorr[2][CEDI_MAX_TX_QUEUES];
extern uint32_t oldTxFrCorr[2][CEDI_MAX_TX_QUEUES];
extern uint32_t hrespNotOk[2][CEDI_MAX_TX_QUEUES];
extern uint32_t oldHrespNotOk[2][CEDI_MAX_TX_QUEUES];


/***********************************************************************
 * MAC Test Functions
 **********************************************************************/

/**
 * txRxTest  -start_defn-
 *
 * Simple tx-rx of single-buffer frame from GEM 0 to GEM 1.
 * Promiscuous mode, ignore preamble & FCS on Rx;
 * no events/isr calls, simply monitor Tx & Rx status registers.
 * Unformatted frame data, no headers.
 * Validates rx buffer status, tx/rx statistics and prints out start of
 * data and all statistics.
 */
void txRxTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv )
{
    uint32_t result, bufLenBytes, i, qNum;
    int passed = 1, txLen, flags;
    cddcOp *cInst = (cddcOp *)cddcInst;
    CEDI_BuffAddr dataBuf;
    CEDI_RxDescData rxDescDat;
    CEDI_TxStatus txStatus;
    uint32_t rawRxStatus;
    uint32_t oldRxStatus = 0;
    uint8_t rxOk = 0, tmp;
    char PStr[40];
    CEDI_FrameSize maxTxFrSize;

    const int emacA = 0;
    const int emacB = 1;
    /* Use instance A for Tx, instance B for Rx */

    cInst->printf("\n_________________________  Tx-Rx Test  __________________________\n");

    if (0!=(result=testSetup( cInst, emacA, TXQ_SIZE, RXQ_SIZE, 2048, NULL))) {
        cInst->printf("Creating Obj 0 - Invalid return value: %d\n", result);
        printFailed;
        return;
    }

    if (0!=(result=testSetup( cInst, emacB, TXQ_SIZE, RXQ_SIZE, 2048, NULL))) {
        cInst->printf("Creating Obj 1 - Invalid return value: %d\n", result);
        printFailed;
        return;
    }

    /* prepare Rx */
    qNum = 0;
    bufLenBytes = privData[emacB]->cfg.rxBufLength[qNum]<<6;
    cInst->printf("Rx bufLen[q%u] = %d bytes\n", qNum, bufLenBytes);

    for (i=0; i<RXQ_SIZE; i++) {
        /* Allocate some buffers */
        if (0!=allocBuffer(bufLenBytes, 0xFAFA0000, &aBuf[qNum][i])) {
            cInst->printf("Error allocating Rx buffer\[\%u]\n", i);
            printFailed;
            return;
        }

        if (0!=(result = emacObj[emacB]->addRxBuf(privData[emacB], qNum, &aBuf[qNum][i], 0)))
        {
            cInst->printf("error in AddRxBuf call: returned %u\n", result);
            printFailed;
            return;
        }
    }
    /* try to accept any old rubbish */
    emacObj[emacB]->setCopyAllFrames(privData[emacB], 1);
    emacObj[emacB]->setRxBadPreamble(privData[emacB], 1);
    emacObj[emacB]->setIgnoreFcsRx(privData[emacB], 1);

    /* disable all events - reading Tx/Rx status regs only */
    emacObj[emacA]->setEventEnable(privData[emacA], CEDI_EVSET_ALL_Q0_EVENTS, 0, CEDI_ALL_QUEUES);
    emacObj[emacB]->setEventEnable(privData[emacB], CEDI_EVSET_ALL_Q0_EVENTS, 0, CEDI_ALL_QUEUES);

    printNetConfigReg(cInst, privData[emacB]);
    printNetControlReg(cInst, privData[emacB]);
    /* start Rx MAC + enable Rx */
    emacObj[emacB]->start(privData[emacB]);
    emacObj[emacB]->enableRx(privData[emacB]);


    /* prepare Tx */
    emacObj[emacA]->start(privData[emacA]);
    emacObj[emacA]->enableTx(privData[emacA]);

    txLen = 64;

    /* Allocate a data buffer and fill with pattern */
    if (0!=allocBuffer(txLen, 0xAA550000, &dataBuf)) {
        cInst->printf("Error allocating Tx data buffer\n");
        printFailed;
        return;
    }

    emacObj[emacA]->calcMaxTxFrameSize(privData[emacA], &maxTxFrSize);
    if (txLen>maxTxFrSize.FrameSize[0])
        txLen = maxTxFrSize.FrameSize[0];

    /* Show status before starting */
    printTxStatus(cInst, emacA);
    printTxDescList(cInst, privData[emacA], 0);
    printRxStatus(cInst, emacB);
    cInst->printf("MAC%u ISR reads %08X, MAC%u ISR reads %08X\n",
            emacA, CPS_UncachedRead32(regAddr(emacA, int_status)),
            emacB, CPS_UncachedRead32(regAddr(emacB, int_status)));
    cInst->printf("MAC%u Frames Txd OK = %u    MAC%u Frames Rxd OK = %u\n",
            emacA, CPS_UncachedRead32(regAddr(emacA, frames_txed_ok)),
            emacB, CPS_UncachedRead32(regAddr(emacB, frames_rxed_ok)));

    flags = CEDI_TXB_NO_AUTO_CRC|CEDI_TXB_LAST_BUFF;

    result = emacObj[emacA]->queueTxBuf(privData[emacA], 0, &dataBuf, txLen, flags);

    /* print start of Tx data */
    cInst->printf("Tx: d[0]=0x%08X d[1]=0x%08X d[2]=0x%08X d[3]=0x%08X d[4]=0x%08X d[5]=0x%08X\n",
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+1),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+2),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+3),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+4),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+5));

    if (0 != result) {
        cInst->printf("queueTxBuf(): Invalid return value: %d\n", result);
        goto done;
    }
    printTxDescList(cInst, privData[emacA], 0);

    /* now wait rx status to show frame received */
    for (i = 10000; i && !rxOk; --i) {
        emacObj[emacA]->getTxStatus(privData[emacA], &txStatus);
        if (txStatus.usedBitRead || txStatus.txComplete) {
            printTxStatus(cInst, emacA);
            cInst->printf("MAC%u ISR reads %08X, MAC%u ISR reads %08X\n",
                    emacA, CPS_UncachedRead32(regAddr(emacA, int_status)),
                    emacB, CPS_UncachedRead32(regAddr(emacB, int_status)));
            emacObj[emacA]->clearTxStatus(privData[emacA],
                  (txStatus.txComplete?CEDI_TXS_TX_COMPLETE:0) |
                  (txStatus.collisionOcc?CEDI_TXS_COLLISION:0) |
                  (txStatus.hRespNotOk?CEDI_TXS_HRESP_ERR:0) |
                  (txStatus.lateCollision?CEDI_TXS_LATE_COLL:0) |
                  (txStatus.retryLimExc?CEDI_TXS_RETRY_EXC:0) |
                  (txStatus.txFrameErr?CEDI_TXS_FRAME_ERR:0) |
                  (txStatus.txUnderRun?CEDI_TXS_UNDERRUN:0) |
                  (txStatus.usedBitRead?CEDI_TXS_USED_READ:0));
            printTxDescList(cInst, privData[emacA], 0);
        }

        rawRxStatus = CPS_UncachedRead32(regAddr(emacB, receive_status));
        if (oldRxStatus != rawRxStatus) {
            printRxStatus(cInst, emacB);
            if (EMAC_REGS__RECEIVE_STATUS__FRAME_RECEIVED__READ(rawRxStatus)) {

                printRxDescList( cInst, privData[emacB], 0);
                printRxVAddrList( cInst, privData[emacB], 0);
                cInst->printf("--> Frame Rx, now readRxBuf\n");
                /* Allocate another buffer to swap in */
                if (0!=allocBuffer(bufLenBytes, 0xABCD0000, &nBuf[0][0])) {
                    cInst->printf("Error allocating new Rx buffer\[\%u]\n", 0);
                    passed = 0;
                    goto done;
                }
                /* update descriptor reference */
                aBuf[0][0].vAddr = nBuf[0][0].vAddr;
                aBuf[0][0].pAddr = nBuf[0][0].pAddr;
                result = emacObj[emacB]->readRxBuf(privData[emacB], 0, &nBuf[0][0], 0, &rxDescDat);
                validateUint(result, 0, "ReadRxBuf", "first read result");
                validateUint(rxDescDat.status, CEDI_RXDATA_SOF_EOF, "ReadRxBuf", "first call readStatus");

                oldRxStatus = rawRxStatus;
                emacObj[emacB]->clearRxStatus(privData[emacB], rawRxStatus);
                rxOk = 1;
            }
        }
    }
    cInst->printf("MAC%u ISR reads %08X, MAC%u ISR reads %08X\n",
            emacA, CPS_UncachedRead32(regAddr(emacA, int_status)),
            emacB, CPS_UncachedRead32(regAddr(emacB, int_status)));
    cInst->printf("MAC%u Frames Txd OK = %u    MAC%u Frames Rxd OK = %u\n",
            emacA, CPS_UncachedRead32(regAddr(emacA, frames_txed_ok)),
            emacB, CPS_UncachedRead32(regAddr(emacB, frames_rxed_ok)));
    printRxDescList( cInst, privData[emacB], 0);
    printRxVAddrList( cInst, privData[emacB], 0);
    if (!i) {
        cInst->printf("transmit or receive timed out.\n");
        passed = 0;
    }
    else {
        /* Print start of Q0 nBuf[] */
        for (tmp=0; tmp<8; tmp+=4)
            cInst->printf("nBuf\[\%u] = 0x%08X offs=%u  0x%08X offs=%u  0x%08X offs=%u  0x%08X offs=%u\n", 0,
                    CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+tmp), tmp,
                    CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+tmp+1), tmp+1,
                    CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+tmp+2), tmp+2,
                    CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+tmp+3), tmp+3);

        if (0!=(result=emacObj[emacA]->readStats(privData[emacA])))
            cInst->printf("Error reading statistics registers MAC%u: returned %u\n", emacA, result);
        else
            printStatsCopy(cInst, privData[emacA]);
        if (0!=(result=emacObj[emacA]->readStats(privData[emacB])))
            cInst->printf("Error reading statistics registers MAC%u: returned %u\n", emacB, result);
        else
            printStatsCopy(cInst, privData[emacB]);

        /* Check tx/rx stats */
        sprintf(PStr, "MAC%u", emacA);
        validateUint(((CEDI_Statistics *)(privData[emacA]->cfg.statsRegs))->octetsTxLo,
                txLen, PStr, "stats.octetsTxLo");
        validateUint(((CEDI_Statistics *)(privData[emacA]->cfg.statsRegs))->octetsTxHi,
                0, PStr, "stats.octetsTxHi");

        sprintf(PStr, "MAC%u", emacB);
        validateUint(((CEDI_Statistics *)(privData[emacB]->cfg.statsRegs))->octetsRxLo,
                txLen, PStr, "stats.octetsRxLo");
        validateUint(((CEDI_Statistics *)(privData[emacB]->cfg.statsRegs))->octetsRxHi,
                0, PStr, "stats.octetsRxHi");
    }

done:
    emacObj[emacA]->stop(privData[emacA]);
    emacObj[emacB]->stop(privData[emacB]);

    /* Free Rx buffers */
    for (qNum = 0; qNum<1; qNum++) {
        for (i=0; i<RXQ_SIZE; i++) {
            if (aBuf[qNum][i].vAddr!=(result=NCPS_freeHWMem((uint32_t)aBuf[qNum][i].vAddr))) {
                cInst->printf("Error freeing Rx buffer\[\%u]\[\%u]: returned %08X\n", qNum, i, result);
            }
        }
    }
    if (dataBuf.vAddr!=(result=NCPS_freeHWMem((uint32_t)dataBuf.vAddr))) {
        cInst->printf("Error freeing Rx buffer\[\%u]\[\%u]: returned %08X\n", qNum, i, result);
    }

    testTearDown( cInst, emacA);
    testTearDown( cInst, emacB);

    if (passed) printSuccess;
    else printFailed;
}
/* txRxTest  -end_defn-  */

/**
 * cbTxRxTest  -start_defn-
 *
 * Tx-Rx with Callbacks Test
 * Single buffer/frame tx-rx using isr & callbacks.
 *
 * Tx on highest priority queue available (or enter qNum as command parameter).
 * Frame is 256 bytes or reduced if necessary to fit packet buffer.
 * Arbitrary data, no frame headers, CRC auto-generated.
 *
 * Rx buffer 2048 bytes, promiscuous mode.
 *
 * Call isr() on both sides, waiting for Tx Complete & Rx Complete events,
 * and accepting Tx Used Read - any other events will cause an error.
 *
 * Validate basic Tx & Rx statistics and data content.
 */
void cbTxRxTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv )
{
#define CEDI_READ_ISR_QN_CASE(Q) \
        case Q: result = CPS_UncachedRead32(regAddr(emacA, int_q##Q##_status)); break;

    uint32_t result, bufLenBytes, i, j, q, txQNum, numRxQs;
    uint8_t txOk = 0;
    uint8_t rxOk = 0;
    int passed = 1;
    cddcOp *cInst = (cddcOp *)cddcInst;
    CEDI_BuffAddr dataBuf;
    uint32_t dataLen;
    uint32_t readStatus, rxDescStat;
    CEDI_TxStatus txStatus;
    CEDI_RxDescData rxDescDat;
    CEDI_RxStatus rxStatus;
    uint32_t dataRead, expected;
    char PStr[40];
    CEDI_FrameSize maxTxFrSize;

    const int emacA = 0;
    const int emacB = 1;
    /* Use instance A for Tx, instance B for Rx */

    cInst->printf("\n_________________________  Callback Tx-Rx Test  __________________________\n");

    zeroCallbackCounters();

    txQNum = CEDI_MAX_TX_QUEUES-1;

    if (0!=(result=testSetup( cInst, emacA, TXQ_SIZE, RXQ_SIZE, 2048, NULL))) {
        cInst->printf("Creating Obj 0 - Invalid return value: %d\n", result);
        printFailed;
        return;
    }

    if (0!=(result=testSetup( cInst, emacB, TXQ_SIZE, RXQ_SIZE, 2048, NULL))) {
        cInst->printf("Creating Obj 1 - Invalid return value: %d\n", result);
        printFailed;
        return;
    }

    /* prepare Rx */
    if (txQNum>cfgHwQs(emacA)-1)     /* limit tx queue to available Qs */
        txQNum = cfgHwQs(emacA)-1;
    numRxQs = cfgHwQs(emacB);   /* how many Rx queues there are */

    for (q=0; q<numRxQs; q++) {
        bufLenBytes = privData[emacB]->cfg.rxBufLength[q]<<6;
        cInst->printf("Rx bufLen(q%u) = %d bytes\n", q, bufLenBytes);

        for (i=0; i<RXQ_SIZE; i++) {
            /* Allocate some buffers */
            if (0!=allocBuffer(bufLenBytes, 0xFAFA0000, &aBuf[q][i])) {
                cInst->printf("Error allocating Rx buffer\[\%u]\[\%u]\n", q, i);
                printFailed;
                return;
            }

            if (0!=(result = emacObj[emacB]->addRxBuf(privData[emacB], q, &aBuf[q][i], 0)))
            {
                cInst->printf("error in AddRxBuf call: returned %u\n", result);
                printFailed;
                return;
            }
        }
    }
    /* accept without specific address */
    emacObj[emacB]->setCopyAllFrames(privData[emacB], 1);
    printNetConfigReg(cInst, privData[emacB]);
    printNetControlReg(cInst, privData[emacB]);
    /* start Rx MAC + enable Rx */
    emacObj[emacB]->start(privData[emacB]);
    emacObj[emacB]->enableRx(privData[emacB]);

    dataLen = 256;
    emacObj[emacA]->calcMaxTxFrameSize(privData[emacA], &maxTxFrSize);
    if (dataLen>maxTxFrSize.FrameSize[txQNum]-10)
        dataLen = maxTxFrSize.FrameSize[txQNum]-10;

    /* prepare Tx */
    emacObj[emacA]->start(privData[emacA]);

    /* Allocate a data buffer and fill with pattern */
    if (0!=allocBuffer(dataLen, 0xAA550000, &dataBuf)) {
        cInst->printf("Error allocating Tx data buffer\n");
        printFailed;
        return;
    }

    /* Show status before starting */
    printTxStatus(cInst, emacA);
    printRxStatus(cInst, emacB);
    switch(txQNum) {
    case 0: result = CPS_UncachedRead32(regAddr(emacA, int_status)); break;
        CEDI_READ_ISR_QN_CASE(1)
        CEDI_READ_ISR_QN_CASE(2)
        CEDI_READ_ISR_QN_CASE(3)
        CEDI_READ_ISR_QN_CASE(4)
        CEDI_READ_ISR_QN_CASE(5)
        CEDI_READ_ISR_QN_CASE(6)
        CEDI_READ_ISR_QN_CASE(7)
        CEDI_READ_ISR_QN_CASE(8)
        CEDI_READ_ISR_QN_CASE(9)
        CEDI_READ_ISR_QN_CASE(10)
        CEDI_READ_ISR_QN_CASE(11)
        CEDI_READ_ISR_QN_CASE(12)
        CEDI_READ_ISR_QN_CASE(13)
        CEDI_READ_ISR_QN_CASE(14)
        CEDI_READ_ISR_QN_CASE(15)
    }
    cInst->printf("MAC%u ISR%u reads %08X, MAC%u ISR0 reads %08X\n", emacA,
        txQNum, result, emacB, CPS_UncachedRead32(regAddr(emacB, int_status)));
    cInst->printf("MAC%u Frames Txd OK = %u    MAC%u Frames Rxd OK = %u\n",
            emacA, CPS_UncachedRead32(regAddr(emacA, frames_txed_ok)),
            emacB, CPS_UncachedRead32(regAddr(emacB, frames_rxed_ok)));

    result = emacObj[emacA]->queueTxBuf(privData[emacA], txQNum, &dataBuf,
            dataLen, CEDI_TXB_LAST_BUFF);
    printTxDescList(cInst, privData[emacA], txQNum);

    /* print start of Tx data */
    cInst->printf("Tx: d[0]=0x%08X d[1]=0x%08X d[2]=0x%08X d[3]=0x%08X\n",
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+1),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+2),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+3));
    cInst->printf("Tx: d[4]=0x%08X d[5]=0x%08X d[6]=0x%08X d[7]=0x%08X\n",
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+4),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+5),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+6),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+7));
    cInst->printf("Tx: d[32]=0x%08X d[33]=0x%08X d[34]=0x%08X d[35]=0x%08X\n",
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+32),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+33),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+34),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+35));


    if (0 != result) {
        cInst->printf("queueTxBuf(): Invalid return value: %d\n", result);
        passed = 0;
        goto done;
    }
    for (q=0; q<numRxQs; q++)
        cInst->printf("rxFrameCount\[\%u]\[\%u]=%u, oldRxFrameCount\[\%u]\[\%u]=%u\n",
            emacB, q, rxFrameCount[emacB][q], emacB, q, oldRxFrameCount[emacB][q]);

    /* now wait for tx & rx callbacks to be detected */
    for (i = 1000; (!txOk || !rxOk) && i; --i) {

        emacObj[emacA]->isr(privData[emacA]);

        if (txFrComplete[emacA][txQNum]>oldTxFrComplete[emacA][txQNum]) {
            txOk = 1;
            printTxStatus(cInst, emacA);
            if (emacObj[emacA]->getTxStatus(privData[emacA], &txStatus))
                emacObj[emacA]->clearTxStatus(privData[emacA],
                  (txStatus.txComplete?CEDI_TXS_TX_COMPLETE:0) |
                  (txStatus.collisionOcc?CEDI_TXS_COLLISION:0) |
                  (txStatus.hRespNotOk?CEDI_TXS_HRESP_ERR:0) |
                  (txStatus.lateCollision?CEDI_TXS_LATE_COLL:0) |
                  (txStatus.retryLimExc?CEDI_TXS_RETRY_EXC:0) |
                  (txStatus.txFrameErr?CEDI_TXS_FRAME_ERR:0) |
                  (txStatus.txUnderRun?CEDI_TXS_UNDERRUN:0) |
                  (txStatus.usedBitRead?CEDI_TXS_USED_READ:0));
            printTxDescList(cInst, privData[emacA], 0);
            oldTxFrComplete[emacA][txQNum]++;
        }
        if (txUsedRead[emacA]>oldTxUsedRead[emacA])
            oldTxUsedRead[emacA]++;

        emacObj[emacB]->isr(privData[emacB]);

        for (q=0; q<numRxQs; q++) {
            /* check for rxFrame callback */
            if (rxFrameCount[emacB][q]>oldRxFrameCount[emacB][q]) {
                cInst->printf("--> Frame Rx\n");
                printRxStatus(cInst, emacB);
                /* Allocate another buffer to swap in */
                bufLenBytes = privData[emacB]->cfg.rxBufLength[q]<<6;
                if (0!=allocBuffer(bufLenBytes, 0xABCD0000, &nBuf[q][0])) {
                    cInst->printf("Error allocating new Rx buffer\[\%u]\n", q);
                    printFailed;
                    goto done;
                }
                /* update descriptor reference */
                aBuf[q][0].vAddr = nBuf[q][0].vAddr;
                aBuf[q][0].pAddr = nBuf[q][0].pAddr;

                printRxDescList( cInst, privData[emacB], 0);
                printRxVAddrList( cInst, privData[emacB], 0);

                result = emacObj[emacB]->readRxBuf(privData[emacB], q, &nBuf[q][0], 0, &rxDescDat);
                rxOk = rxFrameCount[emacB][0];
                validateUint(result, 0, "ReadRxBuf", "first read result");
                validateUint(rxDescDat.status, CEDI_RXDATA_SOF_EOF, "ReadRxBuf", "first call readStatus");

                emacObj[emacB]->getRxStatus(privData[emacB], &rxStatus);
                if (rxStatus.frameRx)
                    emacObj[emacB]->clearRxStatus(privData[emacB], CEDI_RXS_FRAME_RX);
                oldRxFrameCount[emacB][q]++;
            }
        }
        if (detectCallback(cInst, emacA)) {
            cInst->printf("**** Error - Unexpected MAC%u callback detected ****\n", emacA);
            passed = 0;
//            goto done;
        }
        if (detectCallback(cInst, emacB)) {
            cInst->printf("**** Error - Unexpected MAC%u callback detected ****\n", emacB);
            passed = 0;
//            goto done;
        }
    }
    for (q=0; q<numRxQs; q++)
        cInst->printf("rxFrameCount\[\%u]\[\%u]=%u, oldRxFrameCount\[\%u]\[\%u]=%u\n",
            emacB, q, rxFrameCount[emacB][q], emacB, q, oldRxFrameCount[emacB][q]);

    if (0!=(result=emacObj[emacA]->readStats(privData[emacA])))
        cInst->printf("Error reading statistics registers MAC%u: returned %u\n", emacA, result);
    else
        printStatsCopy(cInst, privData[emacA]);
    if (0!=(result=emacObj[emacA]->readStats(privData[emacB])))
        cInst->printf("Error reading statistics registers MAC%u: returned %u\n", emacB, result);
    else
        printStatsCopy(cInst, privData[emacB]);

    sprintf(PStr, "MAC%u", emacA);
    validateUint(((CEDI_Statistics *)(privData[emacA]->cfg.statsRegs))->octetsTxLo,
                dataLen+4, PStr, "stats.octetsTxLo");
    validateUint(((CEDI_Statistics *)(privData[emacA]->cfg.statsRegs))->octetsTxHi,
                0, PStr, "stats.octetsTxHi");
    validateUint(((CEDI_Statistics *)(privData[emacA]->cfg.statsRegs))->framesTx,
                1, PStr, "stats.framesTx");

    sprintf(PStr, "MAC%u", emacB);
    validateUint(((CEDI_Statistics *)(privData[emacB]->cfg.statsRegs))->octetsRxLo,
                dataLen+4, PStr, "stats.octetsRxLo");
    validateUint(((CEDI_Statistics *)(privData[emacB]->cfg.statsRegs))->octetsRxHi,
                0, PStr, "stats.octetsRxHi");
    validateUint(((CEDI_Statistics *)(privData[emacB]->cfg.statsRegs))->framesRx,
                1, PStr, "stats.framesRx");

    /* introduce deliberate data error */
//    CPS_UncachedWrite32((uint32_t *)(nBuf[qNum][0].vAddr)+12, 0x12345678);
    /* compare data buffers */
    for (j = 0; (j < (dataLen / sizeof(uint32_t))) && passed; ++j) {
        sprintf(PStr, "Rx data\[\%u]", j);
        dataRead = CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+j);
        expected = CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+j);
        validateXint(dataRead, expected, PStr, "read");
    }

    printRxDescList( cInst, privData[emacB], 0);
    printRxVAddrList( cInst, privData[emacB], 0);
    if (!i) {
        if (txOk && !rxOk)
            cInst->printf("Receive timed out.\n");
        else if (!rxOk && !txOk)
            cInst->printf("Transmit timed out.\n");
        else
            cInst->printf("Timeout - Transmit not detected! (Rx OK)\n");
        passed = 0;
    }

done:
    emacObj[emacA]->stop(privData[emacA]);
    emacObj[emacB]->stop(privData[emacB]);

    /* Free Rx buffers */
    for (q = 0; q<1; q++) {
        for (i=0; i<RXQ_SIZE; i++) {
            if (aBuf[q][i].vAddr!=(result=NCPS_freeHWMem((uint32_t)aBuf[q][i].vAddr))) {
                cInst->printf("Error freeing Rx buffer\[\%u]\[\%u]: returned %08X\n", q, i, result);
            }
        }
    }
    if (dataBuf.vAddr!=(result=NCPS_freeHWMem((uint32_t)dataBuf.vAddr ))) {
        cInst->printf("Error freeing Tx buffer: returned %08X\n", result);
    }

    testTearDown( cInst, emacA);
    testTearDown( cInst, emacB);

    if (passed) printSuccess;
    else printFailed;
}
/* cbTxRxTest  -end_defn-  */

/**
 * loopbackTest  -start_defn-
 * Test local loopback mode to tx-rx in single GEM instance.
 */
void loopbackTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv )
{
    int passed = 1;     /* any validate__ fail will clear this */
    uint32_t loops;
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

    cInst->printf("\n_________________________  Local Loopback Test  __________________________\n");

    if (0!=(result=testSetup( cInst, emacA, TXQ_SIZE, RXQ_SIZE, rxBufSizeReq, NULL))) {
        cInst->printf("Creating Obj 0 - Invalid return value: %d\n", result);
        printFailed;
        return;
    }

    if (EMAC_REGS__NETWORK_CONFIG__PCS_SELECT__READ(
            CPS_UncachedRead32(regAddr(emacA, network_config)))) {
        printNotSupp("Not available when in PCS mode");
        return;
    }

    zeroCallbackCounters();

    qNum = 0;

    /* prepare Rx */
    rxBufLenBytes[0] = privData[emacA]->cfg.rxBufLength[0]<<6;

    for (i=0; i<privData[emacA]->cfg.rxQLen[0]; i++) {
        /* Allocate some buffers */
        if (0!=allocBuffer(rxBufLenBytes[0], 0xFAFA0000, &aBuf[0][i])) {
            cInst->printf("Error allocating Rx buffer(%u)\n", i);
            printFailed;
            return;
        }

        if (0!=(result = emacObj[emacA]->addRxBuf(privData[emacA], qNum, &aBuf[0][i], 0)))
        {
            cInst->printf("error in AddRxBuf call: returned %u\n", result);
            printFailed;
            return;
        }
    }
    /* oldIndex is first swap-in (or "new") buffer in nBuf array */
    oldIndex[0] = (privData[emacA]->rxQueue[0].rxTailVA -
                 privData[emacA]->rxQueue[0].rxBufVAddr)/sizeof(uintptr_t);
    /* newIndex is where to add new buffer in nBuf[] */
    newIndex[0] = oldIndex[0];

    /* Allocate a spare buffer to swap in */
    if (0!=allocBuffer(rxBufLenBytes[0], 0xABCD0000, &nBuf[0][newIndex[0]])) {
        cInst->printf("Error allocating new Rx buffer(%u)(%u)\n", 0, newIndex[0]);
        printFailed;
        return;
    }

    /* enable local loopback mode */
    result = emacObj[emacA]->setLoopback(privData[emacA], CEDI_LOCAL_LOOPBACK);
    if (ENOTSUP == result){
        printNotSupp("Loopback not available");
        return;
    }

    emacObj[emacA]->setCopyAllFrames(privData[emacA], 1);

    /* start EMAC + enable Rx & Tx */
    emacObj[emacA]->start(privData[emacA]);
    emacObj[emacA]->enableRx(privData[emacA]);
    emacObj[emacA]->enableTx(privData[emacA]);

    txLen = 100;   /* bare frame without FCS */

    /* Allocate a buffer for tx frame and fill with pattern */
    if (0!=allocBuffer(txLen, 0xBADA5500, &txBuf)) {
        cInst->printf("Error allocating Tx buffer\n");
        printFailed;
        return;
    }

    /* set up frame header */
    memset(&header1, 0, sizeof(ethHdr_t));
    memcpy(&header1.dest, &emacAddr2, sizeof(CEDI_MacAddress));
    memcpy(&header1.srce, &emacAddr1, sizeof(CEDI_MacAddress));
    header1.typeLenMsb=0x08;
    header1.typeLenLsb=0x00;

    /* copy into data buffer (16-bit words) */
    for (i=0; i<sizeof(ethHdr_t)/sizeof(uint16_t); i++)
        CPS_UncachedWrite16((uint16_t *)(txBuf.vAddr)+i, ((uint16_t *)&header1)[i]);

    cInst->printf("\n---  Sending frame on Q%u  ---\n\n", qNum);

    emacObj[emacA]->clearStats(privData[emacA]);

    /* Queue frame for Tx, using auto-CRC */
    result = emacObj[emacA]->queueTxBuf(privData[emacA], qNum, &txBuf, txLen, CEDI_TXB_LAST_BUFF);

    if (0 != result) {
        cInst->printf("queueTxBuf(): Invalid return value: %d\n", result);
        passed = 0;
        goto done;
    }

    printTxDescList(cInst, privData[emacA], qNum);
//    printRxDescList(cInst, privData[emacA], 0);
//    printRxVAddrList(cInst, privData[emacA], 0);

    txOk = 0;
    rxOk = 0;

    /* now wait for tx frame complete & rx status to clear */
    for (t = 300; (!txOk || !rxOk) && t; --t) {

        emacObj[emacA]->isr(privData[emacA]);

        if (!txOk && txFrComplete[emacA][qNum]) {
            if (EINVAL==(result = emacObj[emacA]->freeTxDesc(privData[emacA], qNum, &txDescDat)))
                cInst->printf("Error freeing Tx descriptor: returned %08X\n", result);
            else if (result==0) {
                txOk = (txDescDat.status==CEDI_TXDATA_1ST_AND_LAST);
            }
        }

        if (!rxOk && rxFrameCount[emacA][0])
        {
            /* if numRxUsed then call readRxBuf */
            if (emacObj[emacA]->numRxUsed(privData[emacA], 0))
            {
                printRxDescList( cInst, privData[emacA], 0);
                printRxVAddrList( cInst, privData[emacA], 0);

                /* note new buf until we see if swap in */
                tmpBuf.vAddr = nBuf[0][newIndex[0]].vAddr;
                tmpBuf.pAddr = nBuf[0][newIndex[0]].pAddr;

                if (0!=(result = emacObj[emacA]->readRxBuf(privData[emacA], 0,
                                        &nBuf[0][newIndex[0]], 0, &rxDescDat))) {
                    cInst->printf("Error readRxBuf returned %u\n", result);
                    passed = 0;
                    goto done;
                }
                if (rxDescDat.status!=CEDI_RXDATA_NODATA) {    /* data was read */
                    rxOk = 1;
                    /* update descriptor reference for checking freed buffers */
                    aBuf[0][newIndex[0]].vAddr = tmpBuf.vAddr;
                    aBuf[0][newIndex[0]].pAddr = tmpBuf.pAddr;
                    newIndex[0] = (newIndex[0]+1) % privData[emacA]->cfg.rxQLen[0];

                    /* Allocate another buffer to swap in */
                    if (0!=allocBuffer(rxBufLenBytes[0], 0xABCD0000, &nBuf[0][newIndex[0]])) {
                        cInst->printf("Error allocating new Rx buffer(%u)(%u)\n", 0, newIndex[0]);
                        passed = 0;
                        goto done;
                    }
                }
            }
        }
    }

    if (!t) {
        if (txOk && !rxOk)
            cInst->printf("Receive timed out.\n");
        else if (!rxOk && !txOk)
            cInst->printf("Transmit timed out.\n");
        else
            cInst->printf("Timeout - Transmit not detected! (Rx OK)\n");
        passed = 0;
    }

    if (0!=(result=emacObj[emacA]->readStats(privData[emacA])))
        cInst->printf("Error reading statistics registers EMAC%u: returned %u\n", emacA, result);
    printStatsCopy(cInst, privData[emacA]);


    done:
    /* free Rx buffers except initial spare one */
    for (; oldIndex[0]!=newIndex[0]; ) {
        if (0==NCPS_freeHWMem((uint32_t)nBuf[0][oldIndex[0]].vAddr)) {
            cInst->printf("Error freeing Rx buffer nBuf(%u)(%u)\n", 0, oldIndex[0]);
        }
        oldIndex[0] = (oldIndex[0]+1) % privData[emacA]->cfg.rxQLen[0];
    }

    /* free Tx buffer */
    if (txBuf.vAddr) {
        if (txBuf.vAddr!=(result=NCPS_freeHWMem((uint32_t)txBuf.vAddr)))
            cInst->printf("Error freeing Tx data buffer: returned %08X\n", result);
    }

    /* disable local loopback mode */
    emacObj[emacA]->setLoopback(privData[emacA], CEDI_NO_LOOPBACK);

    emacObj[emacA]->stop(privData[emacA]);

    /* Free Rx buffers */
    result = 0;
    emacObj[emacA]->numRxBufs(privData[emacA], 0, &nBufs);
    for (i=nBufs-1; result!=ENOENT; i--) {
        /* buffers in descriptor list */
        result = emacObj[emacA]->removeRxBuf(privData[emacA], 0, &freeBuf);
        if (result==0) {
            if (0==NCPS_freeHWMem((uint32_t)freeBuf.vAddr)) {
                cInst->printf("Error freeing Rx buffer(%u)(%u)\n", 0, i);
            }
        }
        else if (result!=ENOENT)
            cInst->printf("Error from removeRxBuf call- result = %u\n", result);
    }
    /* swapped-out or spare Rx buffers */
    while (oldIndex[0]!=newIndex[0]) {
        if (0==NCPS_freeHWMem((uint32_t)nBuf[0][oldIndex[0]].vAddr))
            cInst->printf("Error freeing unused Rx buffer nBuf(%u)(%u)\n", 0, oldIndex[0]);
        oldIndex[0] = (oldIndex[0]+1) % privData[emacA]->cfg.rxQLen[0];
    }
    if (0==NCPS_freeHWMem((uint32_t)nBuf[0][oldIndex[0]].vAddr))
        cInst->printf("Error freeing spare Rx buffer nBuf(%u)(%u)\n", 0, oldIndex[0]);

    testTearDown( cInst, emacA);

    if (passed) printSuccess;
    else printFailed;
}
/* loopbackTest  -end_defn-  */

/**
 * emacTxRxTest -start_defn-
 *
 * Test transmitting frames using eMAC, when 802.3br is enabled.
 */
void emacTxRxTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv )
{
    CEDI_PrivateData *eMacPrivData[2];
    cddcOp *cInst = (cddcOp *)cddcInst;
    CEDI_PreemptionConfig preCfg;
    CEDI_MmslStatus mmslStatus;
    CEDI_VerifyStatus oldVerStatus = CEDI_INIT_VERIFICATION;
    uint8_t passed = 1;
    uint32_t txLen = 64, rxLen;
    uint32_t tDat;
    uint32_t flags;
    uint32_t result, bufLenBytes;
    CEDI_BuffAddr dataBuf;
    CEDI_RxDescData rxDescDat;
    CEDI_RxDescStat rxDStat;
    CEDI_TxStatus txStatus;
    uint32_t rawRxStatus;
    uint32_t oldRxStatus = 0;
    uint32_t i, t;
    uint32_t reg;
    uint8_t rxOk = 0;
    uint8_t tmp;
    uint8_t qNum = 0;
    uint8_t verificationPasses = 2;

    /* compiler may try to optimize out txBuffer and rxBuffer */
    volatile uint8_t* vRxB = rxBuffer;
    volatile uint8_t* vTxB = txBuffer;

    const int macA = 0;
    const int macB = 1;
    CEDI_Config cfgA, cfgB;

    uint32_t eventsToEnable;
    char PStr[40];
    CEDI_FrameSize maxTxFrSize;

    /* setup default config for macA/B */
    eventsToEnable = CEDI_EVSET_TX_RX_EVENTS;

    cInst->printf("\n___________________  eMAC Transfer Test  ___________________\n");

    if (0 != (result = initConfig(cInst, macA, TXQ_SIZE, RXQ_SIZE, 2048,
                                    eventsToEnable, &cfgA))) {
        cInst->printf("Error in initConfig for macA: returned %d\n", result);
        printFailed;
        return;
    }

    cfgA.incExpressTraffic = 1;
    cfgA.eTxQLen = TXQ_SIZE;
    cfgA.eRxQLen = RXQ_SIZE;

    if (0 != (result=testSetup(cInst, macA, 0, 0, 0, &cfgA))) {
        cInst->printf("Invalid return value for macA: %d\n", result);
        goto done;
    }

    if (0 != (result = initConfig(cInst, macB, TXQ_SIZE, RXQ_SIZE, 2048,
                                    eventsToEnable, &cfgB))) {
        cInst->printf("Error in initConfig for macB: returned %d\n", result);
        printFailed;
        return;
    }

    cfgB.incExpressTraffic = 1;
    cfgB.eTxQLen = TXQ_SIZE;
    cfgB.eRxQLen = RXQ_SIZE;

    if (0 != (result=testSetup(cInst, macB, 0, 0, 0, &cfgB))) {
        cInst->printf("Invalid return value for macB: %d\n", result);
        goto done;
    }

    if (privData[macA]->cfg.incExpressTraffic == 0)
    {
        printNotSupp("Interspersing Express Traffic is not available or not enabled");
        return;
    }

    if (0 != emacObj[macA]->getEmac(privData[macA], (void*)&eMacPrivData[macA]))
    {
        cInst->printf("Could not get eMAC private data for macA.\n");
        printFailed;
        return;
    }

    if (0 != emacObj[macB]->getEmac(privData[macB], (void*)&eMacPrivData[macB]))
    {
        cInst->printf("Could not get eMAC private data for macB.\n");
        printFailed;
        return;
    }

    bufLenBytes = eMacPrivData[macB]->cfg.rxBufLength[qNum]<<6;
    cInst->printf("Rx bufLen[q%u] = %d bytes\n", qNum, bufLenBytes);

    for (i=0; i<RXQ_SIZE; i++) {
        /* Allocate some buffers */
        if (0!=allocBuffer(bufLenBytes, 0xFAFA0000, &aBuf[qNum][i])) {
            cInst->printf("Error allocating Rx buffer\[\%u]\n", i);
            printFailed;
            return;
        }

        if (0!=(result = emacObj[macB]->addRxBuf(eMacPrivData[macB], qNum, &aBuf[qNum][i], 0)))
        {
            cInst->printf("error in AddRxBuf call: returned %u\n", result);
            printFailed;
            return;
        }
    }

    oldIndex[qNum] = 0;


    /* try to accept any old rubbish */
    emacObj[macB]->setCopyAllFrames(eMacPrivData[macB], 1);
    emacObj[macB]->setRxBadPreamble(eMacPrivData[macB], 1);
    emacObj[macB]->setIgnoreFcsRx(eMacPrivData[macB], 1);

    /* disable all events - reading Tx/Rx status regs only */
    emacObj[macA]->setEventEnable(privData[macA], CEDI_EVSET_ALL_Q0_EVENTS, 0, CEDI_ALL_QUEUES);
    emacObj[macB]->setEventEnable(privData[macB], CEDI_EVSET_ALL_Q0_EVENTS, 0, CEDI_ALL_QUEUES);
    emacObj[macA]->setEventEnable(eMacPrivData[macA], CEDI_EVSET_ALL_Q0_EVENTS, 0, 0);
    emacObj[macB]->setEventEnable(eMacPrivData[macB], CEDI_EVSET_ALL_Q0_EVENTS, 0, 0);

    printNetConfigReg(cInst, eMacPrivData[macB]);
    printNetControlReg(cInst, eMacPrivData[macB]);
    /* start Rx MAC + enable Rx */
    emacObj[macB]->start(privData[macB]);

    /* prepare Tx */
    emacObj[macA]->start(privData[macA]);

    /* Allocate a data buffer and fill with pattern */
    if (0!=allocBuffer(txLen, 0xAA550000, &dataBuf)) {
        cInst->printf("Error allocating Tx data buffer\n");
        printFailed;
        return;
    }

    emacObj[macA]->calcMaxTxFrameSize(eMacPrivData[macA], &maxTxFrSize);
    if (txLen>maxTxFrSize.FrameSize[0])
        txLen = maxTxFrSize.FrameSize[0];

    /* Initiate MMSL */
    preCfg.routeRxToPmac = 0;
    preCfg.enPreeption = 1;
    preCfg.enVerify = 1;
    preCfg.addFragSize = CEDI_FRAG_SIZE_64;
    if (0 != emacObj[macA]->setPreemptionConfig(privData[macA], &preCfg))
    {
        cInst->printf("Error configuring MMSL layer on macA\n");
        printFailed;
        return;
    }
    if (0 != emacObj[macB]->setPreemptionConfig(privData[macB], &preCfg))
    {
        cInst->printf("Error configuring MMSL layer on macB\n");
        printFailed;
        return;
    }

    /* wait for MMSL verification, retry if needed. */

    /**
     * GEM will try to send verification packet and wait 10 ms for a response.
     * It will try such procedure up to 3 times, if necessary.
     * Timeout values ([i, t] loop counters) are dependent on test environment.
     * If loop times out without reaching CEDI_VERIFY_FAIL status,
     * those values may be safely increased.
     */
    while (verificationPasses)
    {
        if (verificationPasses == 1)
        {
            /* restart verification */
            if (0 != emacObj[macA]->preemptionRestartVerification(privData[macA]))
            {
                cInst->printf("Error initiating MMSL verification restart on macA\n");
                printFailed;
                goto done;
            }
            if (0 != emacObj[macB]->preemptionRestartVerification(privData[macB]))
            {
                cInst->printf("Error initiating MMSL verification restart on macB\n");
                printFailed;
                goto done;
            }
            cInst->printf("Warning: MMSL verification restart was required\n");
        }
        i = 3000000;
        t = 1000000;
        while(i)
        {
            i--;
            if (0 != emacObj[macA]->readMmslStatus(privData[macA], &mmslStatus))
            {
                cInst->printf("Error reading MMSL status\n");
                passed = 0;
                goto done;
            }
            if (mmslStatus.verifyStatus == CEDI_VERIFIED)
            {
                break;
            }
            if ((mmslStatus.verifyStatus == CEDI_VERIFY_FAIL) && (i < 2999990))
            {
                verificationPasses--;
                break;
            }
            if (mmslStatus.verifyStatus != oldVerStatus)
                t = 1000000;

            t--;
            if (!t)
            {
                cInst->printf("MMSL verification stuck (with timeout counter at "
                "%d, state at %d)\n", i, (uint8_t)oldVerStatus);
                passed = 0;
                goto done;
            }
            oldVerStatus = mmslStatus.verifyStatus;
        }
        if (mmslStatus.verifyStatus == CEDI_VERIFIED)
        {
            cInst->printf("MMSL verification succeeded\n");
            break;
        }
    }

    if (!verificationPasses)
    {
        cInst->printf("MMSL verification failed\n");
        passed = 0;
        goto done;
    }

    if (!i)
    {
        cInst->printf("MMSL verification timed out\n");
        passed = 0;
        goto done;
    }

    /* Show status before starting */
    printTxStatus(cInst, macA);
    printTxDescList(cInst, eMacPrivData[macA], 0);
    printRxStatus(cInst, macB);
    cInst->printf("MAC%u ISR reads %08X, MAC%u ISR reads %08X\n",
            macA, CPS_UncachedRead32(eRegAddr(macA, int_status)),
            macB, CPS_UncachedRead32(eRegAddr(macB, int_status)));
    cInst->printf("MAC%u Frames Txd OK = %u    MAC%u Frames Rxd OK = %u\n",
            macA, CPS_UncachedRead32(eRegAddr(macA, frames_txed_ok)),
            macB, CPS_UncachedRead32(eRegAddr(macB, frames_rxed_ok)));

    flags = CEDI_TXB_NO_AUTO_CRC|CEDI_TXB_LAST_BUFF;

    result = emacObj[macA]->queueTxBuf(eMacPrivData[macA], 0, &dataBuf, txLen, flags);
    /* print start of Tx data */
    cInst->printf("Tx: d[0]=0x%08X d[1]=0x%08X d[2]=0x%08X d[3]=0x%08X d[4]=0x%08X d[5]=0x%08X\n",
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+1),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+2),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+3),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+4),
            CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+5));

    if (0 != result) {
        cInst->printf("queueTxBuf(): Invalid return value: %d\n", result);
        passed = 0;
        goto done;
    }
    printTxDescList(cInst, eMacPrivData[macA], 0);

    /* now wait rx status to show frame received */
    for (t = 10000; t && !rxOk; --t) {
        emacObj[macA]->getTxStatus(eMacPrivData[macA], &txStatus);
        if (txStatus.usedBitRead || txStatus.txComplete) {
            printTxStatus(cInst, macA);
            cInst->printf("MAC%u ISR reads %08X, MAC%u ISR reads %08X\n",
                    macA, CPS_UncachedRead32(eRegAddr(macA, int_status)),
                    macB, CPS_UncachedRead32(eRegAddr(macB, int_status)));
            emacObj[macA]->clearTxStatus(eMacPrivData[macA],
                  (txStatus.txComplete?CEDI_TXS_TX_COMPLETE:0) |
                  (txStatus.collisionOcc?CEDI_TXS_COLLISION:0) |
                  (txStatus.hRespNotOk?CEDI_TXS_HRESP_ERR:0) |
                  (txStatus.lateCollision?CEDI_TXS_LATE_COLL:0) |
                  (txStatus.retryLimExc?CEDI_TXS_RETRY_EXC:0) |
                  (txStatus.txFrameErr?CEDI_TXS_FRAME_ERR:0) |
                  (txStatus.txUnderRun?CEDI_TXS_UNDERRUN:0) |
                  (txStatus.usedBitRead?CEDI_TXS_USED_READ:0));
            printTxDescList(cInst, eMacPrivData[macA], 0);
        }

        rawRxStatus = CPS_UncachedRead32(eRegAddr(macB, receive_status));
        if (oldRxStatus != rawRxStatus) {
            printRxStatus(cInst, macB);
            if (EMAC_REGS__RECEIVE_STATUS__FRAME_RECEIVED__READ(rawRxStatus)) {

                printRxDescList( cInst, eMacPrivData[macB], 0);
                printRxVAddrList( cInst, eMacPrivData[macB], 0);
                cInst->printf("--> Frame Rxed\n");

                result = emacObj[macB]->readRxBuf(eMacPrivData[macB], 0, &aBuf[qNum][oldIndex[qNum]], 0, &rxDescDat);
                validateUint(result, 0, "ReadRxBuf", "first read result");
                validateUint(rxDescDat.status, CEDI_RXDATA_SOF_EOF, "ReadRxBuf", "first call readStatus");
                emacObj[macB]->getRxDescStat(eMacPrivData[macB], rxDescDat.rxDescStat, &rxDStat);
                rxLen = rxDStat.bufLen;

                /* transfer back from Rx buffer(s) */
                i = 0; /* byte count */
                while (i<(rxLen)) {
                    tDat = CPS_UncachedRead32((uint32_t *)(aBuf[qNum][oldIndex[qNum]].vAddr)+i/sizeof(uint32_t));
                    vRxB[i++] = tDat & 0x000000FF;
                    vRxB[i++] = (tDat & 0x0000FF00)>>8;
                    vRxB[i++] = (tDat & 0x00FF0000)>>16;
                    vRxB[i++] = (tDat & 0xFF000000)>>24;
                }

                oldRxStatus = rawRxStatus;
                emacObj[macB]->clearRxStatus(eMacPrivData[macB], rawRxStatus);
                rxOk = 1;

                /* Allocate another buffer to swap in */
                if (0!=allocBuffer(bufLenBytes, 0xABCD0000, &nBuf[0][0])) {
                    cInst->printf("Error allocating new Rx buffer\[\%u]\n", 0);
                    passed = 0;
                    goto done;
                }
                /* update descriptor reference */
                aBuf[0][0].vAddr = nBuf[0][0].vAddr;
                aBuf[0][0].pAddr = nBuf[0][0].pAddr;

                /* Get transmitted data */
                for (i=0; i<txLen/sizeof(uint32_t); i++)
                    ((uint32_t *)vTxB)[i] = CPS_UncachedRead32((uint32_t *)(dataBuf.vAddr)+i);
                /* compare data */
                if (memcmp((uint8_t *)vTxB, (uint8_t *)vRxB, txLen))
                {
                    cInst->printf("Error: Received data not equal to transmitted\n\n");
                    passed = 0;
                }
            }
        }
    }
    cInst->printf("MAC%u ISR reads %08X, MAC%u ISR reads %08X\n",
            macA, CPS_UncachedRead32(eRegAddr(macA, int_status)),
            macB, CPS_UncachedRead32(eRegAddr(macB, int_status)));
    cInst->printf("MAC%u Frames Txd OK = %u    MAC%u Frames Rxd OK = %u\n",
            macA, CPS_UncachedRead32(eRegAddr(macA, frames_txed_ok)),
            macB, CPS_UncachedRead32(eRegAddr(macB, frames_rxed_ok)));
    printRxDescList( cInst, eMacPrivData[macB], 0);
    printRxVAddrList( cInst, eMacPrivData[macB], 0);
    if (!t) {
        cInst->printf("transmit or receive timed out.\n");
        passed = 0;
    }
    else {
        /* Print start of Q0 nBuf[] */
        for (tmp=0; tmp<8; tmp+=4)
            cInst->printf("nBuf\[\%u] = 0x%08X offs=%u  0x%08X offs=%u  0x%08X offs=%u  0x%08X offs=%u\n", 0,
                    CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+tmp), tmp,
                    CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+tmp+1), tmp+1,
                    CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+tmp+2), tmp+2,
                    CPS_UncachedRead32((uint32_t *)(nBuf[0][0].vAddr)+tmp+3), tmp+3);

        if (0!=(result=emacObj[macA]->readStats(eMacPrivData[macA])))
            cInst->printf("Error reading statistics registers MAC%u: returned %u\n", macA, result);
        else
            printStatsCopy(cInst, eMacPrivData[macA]);
        if (0!=(result=emacObj[macA]->readStats(eMacPrivData[macB])))
            cInst->printf("Error reading statistics registers MAC%u: returned %u\n", macB, result);
        else
            printStatsCopy(cInst, eMacPrivData[macB]);

        /* Check tx/rx stats */
        sprintf(PStr, "MAC%u", macA);
        validateUint(((CEDI_Statistics *)(eMacPrivData[macA]->cfg.statsRegs))->octetsTxLo,
                txLen, PStr, "stats.octetsTxLo");
        validateUint(((CEDI_Statistics *)(eMacPrivData[macA]->cfg.statsRegs))->octetsTxHi,
                0, PStr, "stats.octetsTxHi");

        sprintf(PStr, "MAC%u", macB);
        validateUint(((CEDI_Statistics *)(eMacPrivData[macB]->cfg.statsRegs))->octetsRxLo,
                txLen, PStr, "stats.octetsRxLo");
        validateUint(((CEDI_Statistics *)(eMacPrivData[macB]->cfg.statsRegs))->octetsRxHi,
                0, PStr, "stats.octetsRxHi");
    }

done:
    emacObj[macA]->stop(eMacPrivData[macA]);
    emacObj[macB]->stop(eMacPrivData[macB]);

    /* reset MMSL config */
    preCfg.routeRxToPmac = 1;
    preCfg.enPreeption = 0;
    emacObj[macA]->setPreemptionConfig(privData[macA], &preCfg);
    emacObj[macB]->setPreemptionConfig(privData[macB], &preCfg);

    /* Free Rx buffers */
    for (qNum = 0; qNum<1; qNum++) {
        for (i=0; i<RXQ_SIZE; i++) {
            if (aBuf[qNum][i].vAddr!=(result=NCPS_freeHWMem((uint32_t)aBuf[qNum][i].vAddr))) {
                cInst->printf("Error freeing Rx buffer\[\%u]\[\%u]: returned %08X\n", qNum, i, result);
            }
        }
    }
    if (dataBuf.vAddr!=(result=NCPS_freeHWMem((uint32_t)dataBuf.vAddr))) {
        cInst->printf("Error freeing Rx buffer\[\%u]\[\%u]: returned %08X\n", qNum, i, result);
    }

    testTearDown(cInst, macA);
    testTearDown(cInst, macB);

    if (passed) printSuccess;
    else printFailed;
}
/* emacTxRxTest  -end_defn-  */

/**
 * asfSimpleTest -start_defn-
 */
#include "asf_priv.h"
#include "asf_obj_if.h"

void sramCorrectableEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    printf("SRAM Correctable Fault Event detected \n");
}
void sramUncorrectableEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    printf("SRAM Uncorrectable Fault Event detected \n");
}

void dataAdressParityEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    printf("Data Address Parity Fault Event detected\n");
}

void configStatusRegiseterEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    printf("Configuration and Status Register Fault Event detected\n");
}

void transactionTimeoutEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
  printf("Transaction Timeout Fault Event detected\n");
}
void protocolEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
  printf("Protocol Fault Event detected\n");
}
void integrityEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
  printf("Integrity Fault Event detected\n");
}


static ASF_Callbacks callback = {
    .sramCorrectableEvent = sramCorrectableEvent,
    .sramUncorrectableEvent = sramUncorrectableEvent,
    .dataAdressParityEvent = dataAdressParityEvent,
    .configStatusRegiseterEvent = configStatusRegiseterEvent,
    .transactionTimeoutEvent = transactionTimeoutEvent,
    .protocolEvent = protocolEvent,
    .integrityEvent = integrityEvent
};

/**
 * Simple ASF test checking how many instances are supported by GEM.
 * Initialize ASF driver if there is at least one ASF module.
 */

void asfSimpleTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv )
{
    cddcOp *cInst = (cddcOp *)cddcInst;
    uint8_t numQs, passed = 1;
    uint32_t reg;
    uint16_t rxBufSizeReq = 1024;
    uint32_t result;
    CEDI_OBJ *emacDrv = CEDI_GetInstance();
    ASF_Config asfCfg;
    ASF_OBJ *asfDrv = ASF_GetInstance();
    ASF_SysReq sysReq;
    ASF_PrivateData *privateData[2];
    char *macNames[] = {"ASF for MAC", "ASF for express MAC"};

    int i;
    const int macA = 0;
    CEDI_AsfInfo asfInfo;

    /* check if ASF is supported by HW and get register base if yes */
    result = emacDrv->getAsfInfo((uintptr_t)EMAC_REG_BASE_ADDRESS0, &asfInfo);
    if (result){
	passed = 0;
	goto done;
    }

    cInst->printf("Number of ASF instances %d \n", asfInfo.asfCount);
    for (i = 0; i < asfInfo.asfCount; i++){
	cInst->printf("ASF%d: %08x\n", i, asfInfo.asfRegBases[i]);
    }

    /* init ASF module/modules
     * if  GEM 802.3br functionality is enabled then two MACs are present inside HW
     * each MAC (pMAC and eMAC) has own ASF module.*/
    for (i = 0; i < asfInfo.asfCount; i++){
	asfCfg.regBase = (void*)asfInfo.asfRegBases[i];
	asfCfg.transactionTimeoutValue = 10;
	strncpy(asfCfg.controllerName, macNames[i], ASF_CONTROLLER_NAME_LEN);
	result = asfDrv->probe(&asfCfg, &sysReq);
	if (result != 0){
	    passed = 0;
	    goto done;
	}
	if ((privateData[i] = (ASF_PrivateData*) malloc((size_t) (sysReq.privDataSize))) == NULL) {
	    printf("Error. Failed to alocate memory for driver private data\n");
	    passed = 0;
	    goto done;
	}

	memset(privateData[i],0,sizeof(ASF_PrivateData));

	// initialize ASF:
	result = asfDrv->init(privateData[i], &asfCfg, &callback);
	if (result != 0){
	    passed = 0;
	    goto done;
	}

	printf("Initializing OK!\n");

	asfDrv->start(privateData[i]);
    }
done:
    if (passed) printSuccess;
    else printFailed;

}
/* asfSimpleTest  -end_defn-  */
