/******************************************************************************
 * copyright (C) 2014-2016 Cadence Design Systems
 * All rights reserved.
 ******************************************************************************
 * edd_tx.c
 * Ethernet DMA MAC Driver
 *
 * Tx-related functions source file
 *****************************************************************************/

#include "cdn_stdint.h"
#include "cdn_errno.h"
#include "log.h"

// If running over UVM-SV use cdn_demo.h and cdn_gem_demo.h libraries.
// If running over CSP use csp.h and cps.h libraries.
#ifdef CDN_DEMO_TB
  #include "cdn_demo.h"
  #include "cdn_gem_demo.h"
#else
  #include "csp.h"
  #include "cps.h"
#endif

#include "emac_regs.h"
#include "cedi.h"
#include "edd_int.h"


/******************************************************************************
 * Private Driver functions
 *****************************************************************************/

/* move descriptor pointer bd and virtual address pointer vp on to next in ring.
 * stat should be the status (word 1) of current descriptor */
static void inc_txbd(void *pD, uint32_t stat, txDesc **bd, uintptr_t **vp,
                        txQueue_t *txQ) {
    if (stat & CEDI_TXD_WRAP) {
        *bd = txQ->bdBase;
        *vp = txQ->vAddrList;
    } else {
        *bd = (txDesc *) (((uintptr_t)(*bd))+(CEDI_PdVar(txDescriptorSize)));
        ++(*vp);
    }
}

/* move descriptor and virtual address pointers back to previous in ring */
static void dec_txbd(void *pD, txDesc **bd, uintptr_t **vp, txQueue_t *txQ) {
    if (*bd==txQ->bdBase) {
        *bd = (txDesc *)(((uintptr_t)(*bd))+
                            (txQ->descMax-1)*(CEDI_PdVar(txDescriptorSize)));
        *vp += (txQ->descMax-1);
    } else {
        *bd = (txDesc *)(((uintptr_t)(*bd))-(CEDI_PdVar(txDescriptorSize)));
        --(*vp);
    }
}

/******************************************************************************
 * Driver API functions
 *****************************************************************************/

/**
 * Identify max Tx pkt size for queues. When using full store & forward packet
 * buffering, this is based on the sram size for each queue, otherwise it is
 * limited by an internal counter to 16kB.
 * @param pD - driver private state info specific to this instance
 * @param maxTxSize - pointer for returning array of sizes for queues
 * @return 0 if successful
 * @return EINVAL if any parameter =NULL
 */
uint32_t emacCalcMaxTxFrameSize(void *pD, CEDI_FrameSize *maxTxSize) {
    uint32_t i, watermark;
    uint16_t ram_word_size, ram_addr_bits, burst_len;
    uint16_t ram_size, num_segments, size_per_segment, tx_overhead;
    uint32_t num_segments_q[CEDI_MAX_TX_QUEUES];
    uint8_t enabled = 0;
    uint32_t ret;

    if ((pD==NULL) || (maxTxSize==NULL)) return EINVAL;

    if (0!=(ret = emacGetTxPartialStFwd(pD, &watermark, &enabled)))
        return ret;

    if (!(enabled) && CEDI_PdVar(hwCfg).tx_pkt_buffer)
    {
        // What is word size of SRAM in bytes
        ram_word_size = (CEDI_PdVar(hwCfg).tx_pbuf_data >> 1)+1;
        //vDbgMsg(DBG_GEN_MSG, 10, "RAM word size = %u (x32 bits)\n", CEDI_PdVar(hwCfg).tx_pbuf_data);
        ram_addr_bits = CEDI_PdVar(hwCfg).tx_pbuf_addr;
        //vDbgMsg(DBG_GEN_MSG, 10, "RAM Tx addr bits = %u\n", ram_addr_bits);

        ram_size = ram_addr_bits + ram_word_size + 1;
        vDbgMsg(DBG_GEN_MSG, 10, "RAM size = %u\n", 1<<ram_size);

        // how many segments are there ?
        num_segments = CEDI_PdVar(hwCfg).tx_pbuf_queue_segment_size;
        /* this is number of address lines used for segment selection,
         * e.g. if =3, there are 2^3 = 8 segments */
        vDbgMsg(DBG_GEN_MSG, 10, "Num segments = %u\n", 1<<num_segments);

        size_per_segment  = (ram_size - num_segments);
                                                  /* again, as a power of 2 */
        vDbgMsg(DBG_GEN_MSG, 10, "RAM Size per segment = %u\n",
                1<<size_per_segment);

        num_segments_q[0] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q0;
        num_segments_q[1] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q1;
        num_segments_q[2] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q2;
        num_segments_q[3] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q3;
        num_segments_q[4] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q4;
        num_segments_q[5] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q5;
        num_segments_q[6] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q6;
        num_segments_q[7] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q7;
        num_segments_q[8] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q8;
        num_segments_q[9] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q9;
        num_segments_q[10] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q10;
        num_segments_q[11] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q11;
        num_segments_q[12] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q12;
        num_segments_q[13] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q13;
        num_segments_q[14] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q14;
        num_segments_q[15] = CEDI_PdVar(hwCfg).tx_pbuf_num_segments_q15;

        if (CEDI_PdVar(hwCfg).moduleRev >= 0x0109){
            CEDI_SegmentsPerQueue cpq[16];
            int i;
            ret = DoGetSegAlloc(pD, cpq, 16);
            for(i = 0; i < 16; i++){
                num_segments_q[i] = (uint32_t)cpq[i];
            }
            //ret = DoGetSegAlloc(pD, (CEDI_SegmentsPerQueue *)&num_segments_q[0], 16);
            if (ret)
                return ret;
        }

        vDbgMsg(DBG_GEN_MSG, 10,
                "number segments  Q0 = %u, Q1 = %u, Q2 = %u, Q3 = %u,\n",
                num_segments_q[0], num_segments_q[1], num_segments_q[2],
                num_segments_q[3]);
        vDbgMsg(DBG_GEN_MSG, 10,
                "number segments  Q4 = %u, Q5 = %u, Q6 = %u, Q7 = %u,\n",
                num_segments_q[4], num_segments_q[5], num_segments_q[6],
                num_segments_q[7]);

        burst_len = EMAC_REGS__DMA_CONFIG__AMBA_BURST_LENGTH__READ(
                        CPS_UncachedRead32(CEDI_RegAddr(dma_config)));
        switch (burst_len) {
         case CEDI_AMBD_BURST_LEN_8:
                 tx_overhead = ((CEDI_PdVar(hwCfg).tx_pbuf_data << 5)/8)*26;
                 break;
         case CEDI_AMBD_BURST_LEN_16:
                 tx_overhead = ((CEDI_PdVar(hwCfg).tx_pbuf_data << 5)/8)*46;
                 break;
         case CEDI_AMBD_BURST_LEN_1:
         case CEDI_AMBD_BURST_LEN_4:
         default:
                 tx_overhead = ((CEDI_PdVar(hwCfg).tx_pbuf_data << 5)/8)*16;
        }

        for (i=0; i<CEDI_MAX_TX_QUEUES; i++) {
            if (i<CEDI_PdVar(txQs)) {
                maxTxSize->FrameSize[i] =
                   (1 << (num_segments_q[i] + size_per_segment)) - tx_overhead;
                /* add in some extra overhead */
                maxTxSize->FrameSize[i] = (maxTxSize->FrameSize[i]*9)/10;
            }
            else
                maxTxSize->FrameSize[i] = 0;
        }
    }
    else
        for (i=0; i<CEDI_MAX_TX_QUEUES; i++)
            if (i<CEDI_PdVar(txQs))
                maxTxSize->FrameSize[i] = CEDI_TXD_LMASK;
            else
                maxTxSize->FrameSize[i] = 0;

    vDbgMsg(DBG_GEN_MSG, 10,
            "max_frm_size_Q0 = %u, Q1 = %u, Q2 = %u, Q3 = %u,\n",
            maxTxSize->FrameSize[0], maxTxSize->FrameSize[1],
            maxTxSize->FrameSize[2], maxTxSize->FrameSize[3]);
    vDbgMsg(DBG_GEN_MSG, 10,
            "max_frm_size_Q4 = %u, Q5 = %u, Q6 = %u, Q7 = %u,\n",
            maxTxSize->FrameSize[4], maxTxSize->FrameSize[5],
            maxTxSize->FrameSize[6], maxTxSize->FrameSize[7]);
    return 0;
}


/* Add a buffer containing Tx data to the end of the transmit queue.
 * Use repeated calls for multi-buffer frames, setting lastBuffer on the
 * last call, to indicate the end of the frame.
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of Tx queue
 * @param bufAdd - pointer to struct for virtual and physical addresses of
 *              start of data buffer
 * @param length - length of data in buffer
 * @param flags - bit-flags specifying last buffer/auto CRC/auto-start
 * @return 0 if successful
 * @return EINVAL if invalid queueNum, length or buffer alignment, NULL
 *      pointers or buffer addresses
 * @return ENOENT if no available descriptors
 */
uint32_t emacQueueTxBuf(void *pD, uint8_t queueNum, CEDI_BuffAddr *bufAdd,
        uint32_t length, uint8_t flags)
{
    txQueue_t *txQ;
    txDesc *freeDesc;
    txDesc *bd1stBuf;
    uint32_t stat, ncr;
    uint16_t nFree;

    if ((pD==NULL) || (queueNum>=CEDI_PdVar(txQs)) || (bufAdd==NULL)
            || (bufAdd->pAddr==0))
        return EINVAL;

//    vDbgMsg(DBG_GEN_MSG, 10, "%s entered\n", __func__);

    txQ = &CEDI_PdVar(txQueue)[queueNum];
    freeDesc = txQ->bdHead;
    bd1stBuf = txQ->bd1stBuf;

    if (!length || (length > CEDI_TXD_LMASK)) {
        vDbgMsg(DBG_GEN_MSG, 5, "Error: bad length specified: %u\n", length);
        return EINVAL;
    }

    if (emacTxDescFree(pD, queueNum, &nFree)) return EINVAL;
    if (!nFree) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: insufficient buffer descriptors");
        return ENOENT;
    }

    /* preserve wrap bit if present in status word */
    stat = CPS_UncachedRead32(&freeDesc->word[1]) & CEDI_TXD_WRAP;
    stat |= ((flags & CEDI_TXB_LAST_BUFF)?CEDI_TXD_LAST_BUF:0)
            | ((flags & CEDI_TXB_NO_AUTO_CRC)?CEDI_TXD_NO_AUTO_CRC:0) | length;

    /* Handle a multi-buffer frame */
    if (!(flags & CEDI_TXB_LAST_BUFF) && (NULL == bd1stBuf)) {
        /* This is the 1st buf of several; prevent it from going and remember its BD. */
        stat |= CEDI_TXD_USED;
        txQ->bd1stBuf = freeDesc;
    }

    *txQ->vHead = bufAdd->vAddr;
    CPS_UncachedWrite32(&freeDesc->word[0], bufAdd->pAddr & 0xFFFFFFFF);
    /* upper 32 bits if 64 bit addressing */
    if (CEDI_PdVar(cfg).dmaAddrBusWidth) {
#ifdef CEDI_64B_COMPILE
        /* 64-bit addressing */
        CPS_UncachedWrite32(&freeDesc->word[2],
                             (bufAdd->pAddr & 0xFFFFFFFF00000000)>>32);
#else
        /* 32-bit addressing */
#endif
    }
    CPS_UncachedWrite32(&freeDesc->word[1], stat);

    if ((flags & CEDI_TXB_LAST_BUFF) && (NULL != bd1stBuf)) {
        /* Last buffer of a multibuffer frame is in place, 1st buffer can go. */
        CPS_UncachedWrite32(&bd1stBuf->word[1],
            CPS_UncachedRead32(&bd1stBuf->word[1]) & ~CEDI_TXD_USED);
        txQ->bd1stBuf = NULL;
    }

    --txQ->descFree;
    if (emacTxDescFree(pD, queueNum, &nFree)) return EINVAL;
    vDbgMsg(DBG_GEN_MSG, 15, "len=%u, queue=%u, txbdHead=%p, buffV=%p, buffP=%p, descFree=%u\n",
            length, queueNum, freeDesc, (void *)bufAdd->vAddr, (void *)bufAdd->pAddr, nFree);
    inc_txbd(pD, stat, &freeDesc, &txQ->vHead, txQ);
    txQ->bdHead = freeDesc;

    /* set going if complete frame queued */
    if ((flags & CEDI_TXB_LAST_BUFF) && !(flags & CEDI_TXB_NO_AUTO_START)) {
        ncr = CPS_UncachedRead32(CEDI_RegAddr(network_control));
        EMAC_REGS__NETWORK_CONTROL__TX_START_PCLK__SET(ncr);
        CPS_UncachedWrite32(CEDI_RegAddr(network_control), ncr);
    }

    return 0;
}

/* Add a buffer containing Tx data to the end of the transmit queue.
 * Use repeated calls for multi-buffer frames, setting lastBuffer on the
 * last call, to indicate the end of the frame.
 * @param pD - driver private state info specific to this instance
 * @param prm - pointer to struct of parameters
 * @return 0 if successful
 * @return EINVAL if invalid queueNum, length or buffer alignment, NULL
 *      pointers or buffer addresses, or prm->flags specifies
 *      CEDI_TXB_LAST_BUFF as well as CEDI_TXB_TCP_ENCAP or CEDI_TXB_UDP_ENCAP
 * @return ENOENT if no available descriptors
 */
uint32_t emacQTxBuf(void *pD, CEDI_qTxBufParams *prm)
{
    txQueue_t *txQ;
    txDesc *freeDesc;
    txDesc *bd1stBuf;
    uint32_t stat, ncr;
    uint16_t nFree;

    if ((pD==NULL) || (prm->queueNum>=CEDI_PdVar(txQs))
            || (prm->bufAdd==NULL)
            || (prm->bufAdd->pAddr==0))
        return EINVAL;

//    vDbgMsg(DBG_GEN_MSG, 10, "%s entered\n", __func__);

    txQ = &CEDI_PdVar(txQueue)[prm->queueNum];
    freeDesc = txQ->bdHead;
    bd1stBuf = txQ->bd1stBuf;

    if (!prm->length || (prm->length > CEDI_TXD_LMASK)) {
        vDbgMsg(DBG_GEN_MSG, 5, "Error: bad length specified: %u\n",
                prm->length);
        return EINVAL;
    }

    if (emacTxDescFree(pD, prm->queueNum, &nFree)) return EINVAL;
    if (!nFree) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: insufficient buffer descriptors");
        return ENOENT;
    }

    if (NULL!=bd1stBuf) {     /* inc counter after 1st in frame */
        txQ->descNum++;
    }

    /* preserve wrap bit if present in status word */
    stat = CPS_UncachedRead32(&freeDesc->word[1]) & CEDI_TXD_WRAP;
    stat |= ((prm->flags & CEDI_TXB_LAST_BUFF)?CEDI_TXD_LAST_BUF:0)
            | ((prm->flags & CEDI_TXB_NO_AUTO_CRC)?CEDI_TXD_NO_AUTO_CRC:0)
            | prm->length
            | ((txQ->descNum>=1)?
                ((prm->mssMfs << CEDI_TXD_MSSMFS_SHIFT) & CEDI_TXD_MSSMFS_MASK):0);
                                // only set MSS/MFS on second or later descriptor
//    vDbgMsg(DBG_GEN_MSG, 10, "descNum = %u, desc wd1 = 0x%08X, mss = %u\n",
//            txQ->descNum, stat, (stat>>16) & 0x3FFF);

    /* Handle a multi-buffer frame */
    if (!(prm->flags & CEDI_TXB_LAST_BUFF) && (NULL==bd1stBuf)) {
        /* This is the 1st buf of several; prevent it from going and remember its BD. */
        stat |= CEDI_TXD_USED
         /* Also use this condition to set encapsulation flags & TCP stream -
          * must not set stream if TSO bit clear */
                | ((prm->flags & CEDI_TXB_TCP_ENCAP)?
                        /* TSO settings */
                   (CEDI_TXD_TSO_ENABLE|
                    (((prm->tcpStream)<<CEDI_TXD_STREAM_SHIFT)
                        & CEDI_TXD_STREAM_MASK)|
                    ((prm->flags & CEDI_TXB_TSO_AUTO_SEQ)?CEDI_TXD_AUTOSEQ_SEL:0)) :
                        /* UFO bit only */
                  ((prm->flags & CEDI_TXB_UDP_ENCAP)?CEDI_TXD_UFO_ENABLE:0));
        txQ->bd1stBuf = freeDesc;
    }

    *txQ->vHead = prm->bufAdd->vAddr;
    CPS_UncachedWrite32(&freeDesc->word[0], prm->bufAdd->pAddr & 0xFFFFFFFF);

    /* upper 32 bits if 64 bit addressing */
    if (CEDI_PdVar(cfg).dmaAddrBusWidth) {
#ifdef CEDI_64B_COMPILE
        /* 64-bit addressing */
        CPS_UncachedWrite32(&freeDesc->word[2],
                             (prm->bufAdd->pAddr & 0xFFFFFFFF00000000)>>32);
#else
#endif
    }
    CPS_UncachedWrite32(&freeDesc->word[1], stat);


    if ((prm->flags & CEDI_TXB_LAST_BUFF) && (NULL!=bd1stBuf)) {
        /* Last buffer of a multibuffer frame is in place, 1st buffer can go. */
        CPS_UncachedWrite32(&bd1stBuf->word[1],
            CPS_UncachedRead32(&bd1stBuf->word[1]) & ~CEDI_TXD_USED);
        /* vDbgMsg(DBG_GEN_MSG, 10,
                "set multi-buffer go: 1stBuf=%p, wd1=%08X, transmit queue ptr=%08X\n",
                bd1stBuf, CPS_UncachedRead32(&bd1stBuf->word[1]),
                CPS_UncachedRead32(CEDI_RegAddr(transmit_q_ptr)));*/
        txQ->bd1stBuf = NULL;
        txQ->descNum = 0;
    }

    --txQ->descFree;
    /* if (emacTxDescFree(pD, prm->queueNum, &nFree)) return EINVAL;
    vDbgMsg(DBG_GEN_MSG, 10,
            "len=%u, queue=%u, txbdHead=%p, buffV=%p, buffP=%p, wd1=%08X, descFree=%u\n",
            prm->length, prm->queueNum, freeDesc,
            (void *)prm->bufAdd->vAddr,
            (void *)prm->bufAdd->pAddr,
         CPS_UncachedRead32(&freeDesc->word[1]), nFree);*/
    inc_txbd(pD, stat, &freeDesc, &txQ->vHead, txQ);
    txQ->bdHead = freeDesc;

    /* set going if complete frame queued */
    if ((prm->flags & CEDI_TXB_LAST_BUFF) && !(prm->flags & CEDI_TXB_NO_AUTO_START)) {
          ncr = CPS_UncachedRead32(CEDI_RegAddr(network_control));
          EMAC_REGS__NETWORK_CONTROL__TX_START_PCLK__SET(ncr);
          CPS_UncachedWrite32(CEDI_RegAddr(network_control), ncr);
    }

    return 0;
}

/* Remove buffer from head of transmit queue in case of error during queueing
 * and free the corresponding descriptor.
 * Caller must have knowledge of queueing status, i.e. that frame has not been
 * completed for transmission (first used bit still set) and how many
 * descriptors have been queued for untransmitted frame.
 * @param pD - driver private state info specific to this instance
 * @param prm - pointer to struct of parameters to return
 * @return 0 if successful
 * @return EINVAL if invalid queueNum or NULL parameters
 * @return ENOENT if no unfree descriptors in queue
 */
uint32_t emacDeQTxBuf(void *pD, CEDI_qTxBufParams *prm)
{
    txQueue_t *txQ;
    txDesc *descToFree;
    uint32_t stat;

    if ((pD==NULL) || (prm==NULL) || (prm->bufAdd==NULL) ||
            (prm->queueNum>=CEDI_PdVar(txQs)))
        return EINVAL;

//    vDbgMsg(DBG_GEN_MSG, 10, "%s entered\n", __func__);

    txQ = &CEDI_PdVar(txQueue)[prm->queueNum];
    descToFree = txQ->bdHead;

    /* Check if any in queue */
    if (txQ->bdTail==txQ->bdHead)
        return ENOENT;

    /* unwind head pointers */
    dec_txbd(pD, &descToFree, &txQ->vHead, txQ);
    txQ->bdHead = descToFree;

    /* get virtual address */
    prm->bufAdd->vAddr = *txQ->vHead;

    /* get phys address */
    prm->bufAdd->pAddr = CPS_UncachedRead32(&descToFree->word[0]);
#ifdef CEDI_64B_COMPILE
    /* upper 32 bits if 64 bit addressing */
    if (CEDI_PdVar(cfg).dmaAddrBusWidth) {
        prm->bufAdd->pAddr |= (CPS_UncachedRead32(&descToFree->word[2])<<32);
    }
#endif

    /* get length */
    stat = CPS_UncachedRead32(&descToFree->word[1]);
    prm->length = stat & CEDI_TXD_LEN_MASK;
    /* set used bit */
    CPS_UncachedWrite32(&descToFree->word[1], stat | CEDI_TXD_USED);

    if (txQ->descNum>0)
        txQ->descNum--;

    ++txQ->descFree;

    return 0;
}

/* Get number of free descriptors in specified Tx queue
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of Tx queue
 * @param numFree - pointer for returning number of free descriptors
 * @return 0 if successful
 * @return EINVAL if invalid parameter
 */
uint32_t emacTxDescFree(void *pD, uint8_t queueNum, uint16_t *numFree)
{
    if ((pD==NULL) || (numFree==NULL) || (queueNum>=CEDI_PdVar(txQs)))
        return EINVAL;
    *numFree = CEDI_PdVar(txQueue)[queueNum].descFree;
    return 0;
}

/*
 * Read Tx descriptor queue and free used descriptor.
 *
 * @param[in] pD driver private state info specific to this instance
 * @param[in] queueNum number of Tx queue
 *    $RANGE $FROM 0 $TO CEDI_Config.txQs-1$
 * @param[out] descData pointer for returning status & descriptor data
 *   Struct fields:
 *
 *    CEDI_BuffAddr bufAdd - addresses of buffer freed up
 *
 *    uint32_t txDescStat - descriptor status word. Only valid if first
 *                           buffer of frame.
 *
 *    uint8_t status  - descriptor queue status, one of the following values:
 *      CEDI_TXDATA_1ST_NOT_LAST :a first descriptor was freed,
 *                               frame not finished:
 *                               bufAdd & txDescStat are valid
 *      CEDI_TXDATA_1ST_AND_LAST :a first descriptor was freed,
 *                               frame is finished:
 *                               bufAdd & txDescStat are valid
 *      CEDI_TXDATA_MID_BUFFER   :a descriptor was freed,
 *                               (not first in frame),
 *                               frame not finished: bufAdd valid,
 *                               txDescStat not valid
 *      CEDI_TXDATA_LAST_BUFFER  :a descriptor was freed, frame is finished:
 *                               bufAdd valid, txDescStat not valid
 *      CEDI_TXDATA_NONE_FREED   :no used descriptor to free:
 *                               bufAdd & txDescStat not valid
 *
 *    CEDI_TimeStampData txTsData - Tx descriptor timestamp when valid
 *                                  (txTsData->tsValid will be set to 1).
 * @return 0 if successful (and status is set),
 * @return ENOENT if the queue is empty (status = CEDI_TXDATA_NONE_FREED), or
 * @return EIO if an incomplete frame was detected (no lastBuffer flag in
 *          queue)
 * @return EINVAL if any parameter invalid
 */
uint32_t emacFreeTxDesc(void *pD, uint8_t queueNum, CEDI_TxDescData *descData)
{
    txQueue_t *txQ;
    //uint16_t nFree = 0;
    txDesc *freedDesc;
    uint8_t wdNum;
    uint32_t tsLowerWd, tsUpperWd;
//    uintptr_t *nextV;
//    txDesc *nextD;
//    uint32_t wd1_1, wd1_2, wd1_3, wd1_4, wd1_5;

    if ((pD==NULL) || (descData==NULL))
        return EINVAL;
    if (queueNum>=CEDI_PdVar(txQs))
        return EINVAL;

//    vDbgMsg(DBG_GEN_MSG, 10, "%s entered\n", __func__);
    txQ = &CEDI_PdVar(txQueue)[queueNum];

    /* Check if any to free */
    if (txQ->bdTail == txQ->bdHead)
    {
        descData->status = CEDI_TXDATA_NONE_FREED;
        return ENOENT;
    }

    /* Free next used descriptor in this frame */
    descData->txDescStat = CPS_UncachedRead32(&(txQ->bdTail->word[1]));
    if (txQ->firstToFree)
    {
        /* look ahead to next desc */
      /*  nextD = txQ->bdTail;
        nextV = txQ->vTail;
        inc_txbd(pD, descData->txDescStat, &nextD, &nextV, txQ);
        wd1_1 = CPS_UncachedRead32(&(nextD->word[1]));
        inc_txbd(pD, descData->txDescStat, &nextD, &nextV, txQ);
        wd1_2 = CPS_UncachedRead32(&(nextD->word[1]));
        inc_txbd(pD, descData->txDescStat, &nextD, &nextV, txQ);
        wd1_3 = CPS_UncachedRead32(&(nextD->word[1]));
        inc_txbd(pD, descData->txDescStat, &nextD, &nextV, txQ);
        wd1_4 = CPS_UncachedRead32(&(nextD->word[1]));
        inc_txbd(pD, descData->txDescStat, &nextD, &nextV, txQ);
        wd1_5 = CPS_UncachedRead32(&(nextD->word[1]));
        vDbgMsg(DBG_GEN_MSG, 10,
                " testing desc:  queue=%u, txBdTail=%p, wd1(0)=%08X,"\
          " wd1(1)=%08X, wd1(2)=%08X, wd1(3)=%08X, wd1(4)=%08X, wd1(5)=%08X\n",
          queueNum, txQ->bdTail, descData->txDescStat, wd1_1, wd1_2,
          wd1_3, wd1_4, wd1_5);*/

        /* Only test used bit state for first buffer in frame. */
        if(!(descData->txDescStat & CEDI_TXD_USED)) {
            descData->status = CEDI_TXDATA_NONE_FREED;
            return 0;
        }

        /* extract timestamp if available */
        if ((CEDI_PdVar(cfg).enTxExtBD) &&
                (descData->txDescStat & CEDI_TXD_TS_VALID))
        {
	    uint32_t reg;
            descData->txTsData.tsValid = 1;
	    // position depends on 32/64 bit addr
            wdNum = (CEDI_PdVar(cfg).dmaAddrBusWidth)?4:2;
            tsLowerWd = CPS_UncachedRead32(&(txQ->bdTail->word[wdNum]));
            tsUpperWd = CPS_UncachedRead32(&(txQ->bdTail->word[wdNum+1]));

            descData->txTsData.tsNanoSec = tsLowerWd & CEDI_TS_NANO_SEC_MASK;
            descData->txTsData.tsSecs = ((tsUpperWd & CEDI_TS_SEC1_MASK)
                                            <<CEDI_TS_SEC1_POS_SHIFT)
                                           | (tsLowerWd >> CEDI_TS_SEC0_SHIFT);

	    /* The timestamp only contains lower few bits of seconds, so add value from 1588 timer */
	    reg =  CPS_UncachedRead32(CEDI_RegAddr(tsu_timer_sec));
	    /* If the top bit is set in the timestamp, but not in 1588 timer, it has rolled over, so subtract max size */
	    if ((descData->txTsData.tsSecs & (CEDI_TS_SEC_TOP>>1)) && !(reg & (CEDI_TS_SEC_TOP>>1))) {
		descData->txTsData.tsSecs -= CEDI_TS_SEC_TOP;
	    }
	    descData->txTsData.tsSecs += ((~CEDI_TS_SEC_MASK) & EMAC_REGS__TSU_TIMER_SEC__TIMER__READ(reg));
	}
	else{
	    descData->txTsData.tsValid = 0;

	}

	if (descData->txDescStat & CEDI_TXD_LAST_BUF)
	    descData->status = CEDI_TXDATA_1ST_AND_LAST;
	else {
	    txQ->firstToFree = 0;
	    descData->status = CEDI_TXDATA_1ST_NOT_LAST;
	}
    }
    else
    {
        /* set later used bits in frame, for consistency */
        CPS_UncachedWrite32(&(txQ->bdTail->word[1]),
                                descData->txDescStat | CEDI_TXD_USED);
        if (descData->txDescStat & CEDI_TXD_LAST_BUF) {
            descData->status = CEDI_TXDATA_LAST_BUFFER;
            txQ->firstToFree = 1;
        }
        else
            descData->status = CEDI_TXDATA_MID_BUFFER;
    }

    descData->bufAdd.pAddr = CPS_UncachedRead32(&(txQ->bdTail->word[0]));
    /* upper 32 bits if 64 bit addressing */
    if ((CEDI_PdVar(cfg).dmaAddrBusWidth) &&
                (sizeof(descData->bufAdd.pAddr)==sizeof(uint64_t)))
        descData->bufAdd.pAddr |=
                ((uint64_t)CPS_UncachedRead32(&(txQ->bdTail->word[2])))<<32;

    descData->bufAdd.vAddr = *txQ->vTail;
    freedDesc = txQ->bdTail;

    /* move queue pointers on */
    inc_txbd(pD, descData->txDescStat, &txQ->bdTail, &txQ->vTail, txQ);
    ++txQ->descFree;
    /*if (0==emacTxDescFree(pD, queueNum, &nFree))
        vDbgMsg(DBG_GEN_MSG, 15,
            " free desc:  queue=%u, txBdTail=%p, buffV=%p, buffP=%p, length=%u, descFree=%u\n",
            queueNum, freedDesc, (void *)descData->bufAdd.vAddr,
            (void *)descData->bufAdd.pAddr, descData->txDescStat & CEDI_TXD_LMASK, nFree);*/

    /* paranoid - empty and no last buffer flag (on last freed)? */
    if ((0==(descData->txDescStat & CEDI_TXD_LAST_BUF)) &&
            (txQ->descFree==txQ->descMax-CEDI_MIN_TXBD)) {
        vDbgMsg(DBG_GEN_MSG, 5,
                "Error: txQueue %u: LAST bit of frame not found!\n", queueNum);
        txQ->firstToFree = 1;
        return EIO;
    }

    return 0;
}

/* Decode the Tx descriptor status into a bit-field struct
 * @param pD - driver private state info specific to this instance
 * @param txDStatWord - Tx descriptor status word
 * @param txDStat - pointer to bit-field struct for decoded status fields
 */
void emacGetTxDescStat(void *pD, uint32_t txDStatWord, CEDI_TxDescStat *txDStat)
{
    uint32_t wd1;

    if ((NULL==pD) || (NULL==txDStat))
      return;

    wd1 = txDStatWord;
    txDStat->chkOffErr = (wd1 & CEDI_TXD_CHKOFF_MASK) >> CEDI_TXD_CHKOFF_SHIFT;
    txDStat->lateColl = (wd1 & CEDI_TXD_LATE_COLL)?1:0;
    txDStat->frameCorr = (wd1 & CEDI_TXD_FR_CORR)?1:0;
    txDStat->txUnderrun = (wd1 & CEDI_TXD_UNDERRUN)?1:0;
    txDStat->retryExc = (wd1 & CEDI_TXD_RETRY_EXC)?1:0;
}

/* Provide the size of descriptor calculated for the current configuration.
 * @param pD - driver private state info specific to this instance
 * @param txDescSize - pointer to Tx descriptor Size
 */
void emacGetTxDescSize(void *pD, uint32_t *txDescSize)
{
    if ((pD==NULL)||(txDescSize==NULL)) return;
    *txDescSize = CEDI_PdVar(txDescriptorSize);
}

/* Reset transmit buffer queue. Any untransmitted buffer data will be
 * discarded and must be re-queued.  Transmission must be disabled
 * before calling this function.
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of Tx queue
 * @return 0 if successful
 * @return EINVAL if invalid parameter
 */
uint32_t emacResetTxQ(void *pD, uint8_t queueNum)
{
#define CEDI_WR_TXQ_PTR_REG_N_CASE(Q) case Q:\
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(transmit_q##Q##_ptr));\
	EMAC_REGS__TRANSMIT_Q_PTR__DMA_TX_Q_PTR__MODIFY(regTmp, pAddr>>2);\
        CPS_UncachedWrite32(CEDI_RegAddr(transmit_q##Q##_ptr), regTmp);\
        break;

    uint32_t result = 0, regTmp;
    txQueue_t *txQ;
    txDesc *descStartPerQ;
    uint32_t pAddr;
    uintptr_t vAddr;
    uint16_t q, i;

    if ((pD==NULL) || (queueNum>=CEDI_PdVar(txQs)))
        return EINVAL;

    txQ = &CEDI_PdVar(txQueue)[queueNum];
    txQ->descFree = CEDI_PdVar(cfg).txQLen[queueNum];
    txQ->descMax = txQ->descFree + CEDI_MIN_TXBD;
    vAddr = CEDI_PdVar(cfg).txQAddr;
    pAddr = CEDI_PdVar(cfg).txQPhyAddr;
    q = 0;
    /* find start addresses for this txQ */
    if (queueNum>0)
        txQ->vAddrList = CEDI_PdVar(txQueue)[0].vAddrList;
    while (q<queueNum) {
        vAddr += txQ->descMax * (CEDI_PdVar(txDescriptorSize));  //sizeof(txDesc);
        pAddr += txQ->descMax * (CEDI_PdVar(txDescriptorSize));  //sizeof(txDesc);
        txQ->vAddrList += txQ->descMax;
        q++;
    }
    vDbgMsg(DBG_GEN_MSG, 10, "%s: base address Q%u virt=%08lX phys=%08X vAddrList=%p\n",
            __func__, queueNum, vAddr, pAddr, txQ->vAddrList);
    txQ->bdBase = (txDesc *)vAddr;

    txQ->bdTail = txQ->bdBase;
    txQ->bdHead = txQ->bdBase;
    txQ->bd1stBuf = NULL;
    txQ->vHead = txQ->vAddrList;
    txQ->vTail = txQ->vAddrList;
    txQ->firstToFree = 1;
    txQ->descNum = 0;

    /* set used flags & last wrap flag */
    descStartPerQ = txQ->bdBase;
    for (i = 0; i<txQ->descMax; i++) {
        CPS_UncachedWrite32((uint32_t *)&(descStartPerQ->word[0]), 0);
        CPS_UncachedWrite32((uint32_t *)&(descStartPerQ->word[1]),
                CEDI_TXD_USED | (i==(txQ->descMax-1)?CEDI_TXD_WRAP:0));

        descStartPerQ = (txDesc*) (((uintptr_t)(descStartPerQ)) +
                            (CEDI_PdVar(txDescriptorSize)));
    }

    switch (q) {
    case 0:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(transmit_q_ptr));\
	EMAC_REGS__TRANSMIT_Q_PTR__DMA_TX_Q_PTR__MODIFY(regTmp, pAddr>>2);
        CPS_UncachedWrite32(CEDI_RegAddr(transmit_q_ptr), regTmp);
        break;
    CEDI_WR_TXQ_PTR_REG_N_CASE(1);
    CEDI_WR_TXQ_PTR_REG_N_CASE(2);
    CEDI_WR_TXQ_PTR_REG_N_CASE(3);
    CEDI_WR_TXQ_PTR_REG_N_CASE(4);
    CEDI_WR_TXQ_PTR_REG_N_CASE(5);
    CEDI_WR_TXQ_PTR_REG_N_CASE(6);
    CEDI_WR_TXQ_PTR_REG_N_CASE(7);
    CEDI_WR_TXQ_PTR_REG_N_CASE(8);
    CEDI_WR_TXQ_PTR_REG_N_CASE(9);
    CEDI_WR_TXQ_PTR_REG_N_CASE(10);
    CEDI_WR_TXQ_PTR_REG_N_CASE(11);
    CEDI_WR_TXQ_PTR_REG_N_CASE(12);
    CEDI_WR_TXQ_PTR_REG_N_CASE(13);
    CEDI_WR_TXQ_PTR_REG_N_CASE(14);
    CEDI_WR_TXQ_PTR_REG_N_CASE(15);
    }

    return result;
}

/* Enable & start the transmit circuit. Not required during normal
 * operation, as queueTxBuf will automatically start Tx when complete frame
 * has been queued, but may be used to restart after a Tx error.
 * @param pD - driver private state info specific to this instance
 * @return 0 if successful
 * @return ECANCELED if no entries in buffer
 * @return EINVAL if invalid parameter
 */
uint32_t emacStartTx(void *pD)
{
    const CEDI_Config *cfg;
    uint32_t qNum;
    uint8_t ok = 0;
    txQueue_t *txQ;
    uint32_t ncr;

    if (pD==NULL) return EINVAL;

    vDbgMsg(DBG_GEN_MSG, 10, "%s entered\n", __func__);

    cfg = &((CEDI_PrivateData *)pD)->cfg;

    if (!emacGetTxEnabled(pD))
        emacEnableTx(pD);

    /* if anything to transmit, start transmission */
    for (qNum = 0; qNum < CEDI_PdVar(txQs); ++qNum) {
        txQ = &CEDI_PdVar(txQueue)[qNum];
        if (txQ->bdHead != txQ->bdTail) {
            ok = 1;
            break;
        }
    }
    if (!ok)
        return ECANCELED;
    else
    {
        ncr = CPS_UncachedRead32(CEDI_RegAddr(network_control));
        EMAC_REGS__NETWORK_CONTROL__TX_START_PCLK__SET(ncr);
        CPS_UncachedWrite32(CEDI_RegAddr(network_control), ncr);
    }
    return 0;
}

/* Halt transmission as soon as current frame Tx has finished
 * @param pD - driver private state info specific to this instance
 */
void emacStopTx(void *pD)
{
    uint32_t ncr;

    if (!pD) return;
    ncr = CPS_UncachedRead32(CEDI_RegAddr(network_control));
    EMAC_REGS__NETWORK_CONTROL__TX_HALT_PCLK__SET(ncr);
    CPS_UncachedWrite32(CEDI_RegAddr(network_control), ncr);
    return;
}

/* Immediately disable transmission without waiting for completion.
 * Since the EMAC will reset to point to the start of transmit descriptor
 * list, the buffer queues may have to be reset after this call.
 * @param pD - driver private state info specific to this instance
 */
void emacAbortTx(void *pD)
{
    uint32_t ncr;

    if (!pD) return;
    ncr = CPS_UncachedRead32(CEDI_RegAddr(network_control));
    EMAC_REGS__NETWORK_CONTROL__ENABLE_TRANSMIT__CLR(ncr);
    CPS_UncachedWrite32(CEDI_RegAddr(network_control), ncr);
    return;
}

/* Get state of transmitter
 * @param pD - driver private state info specific to this instance
 * @return 1 if active
 * @return 0 if idle or pD==NULL
 */
uint32_t emacTransmitting(void *pD)
{
    if (pD==NULL) return 0;

    return EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_GO__READ(
            CPS_UncachedRead32(CEDI_RegAddr(transmit_status)));
}

/**
 * Enable the transmit circuit.  This will be done automatically
 * when call startTx, but it may be desirable to call this earlier,
 * since some functionality depends on transmit being enabled.
 * @param[in] pD driver private state info specific to this instance
 */
void emacEnableTx(void *pD)
{
    uint32_t ncr;
    if (pD==NULL) return;

    /* Enable the transmitter */
    ncr = CPS_UncachedRead32(CEDI_RegAddr(network_control));
    EMAC_REGS__NETWORK_CONTROL__ENABLE_TRANSMIT__SET(ncr);
    CPS_UncachedWrite32(CEDI_RegAddr(network_control), ncr);
}

/**
 * Get state of transmision enabled
 * @param pD - driver private state info specific to this instance
 * @return 1 if transmission enabled
 * @return 0 if transmission disabled or pD==NULL
 */
uint32_t emacGetTxEnabled(void *pD)
{
    if (pD==NULL) return 0;

    return EMAC_REGS__NETWORK_CONTROL__ENABLE_TRANSMIT__READ(
            CPS_UncachedRead32(CEDI_RegAddr(network_control)));
}

/* Get the content of EMAC transmit status register
 * @param pD - driver private state info specific to this instance
 * @param status - pointer to struct with fields for each flag
 * @return raw status register value, !=0 if any flags set
 */
uint32_t emacGetTxStatus(void *pD, CEDI_TxStatus *status)
{
    uint32_t reg;
    if ((pD==NULL)||(status==NULL))
        return 0;

    reg = CPS_UncachedRead32(CEDI_RegAddr(transmit_status));
//    vDbgMsg(DBG_GEN_MSG, 10, "-----getTxStatus reads 0x%08X ------\n", reg);

    status->txComplete =
            EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_COMPLETE__READ(reg);
    status->usedBitRead =
            EMAC_REGS__TRANSMIT_STATUS__USED_BIT_READ__READ(reg);
    status->collisionOcc =
            EMAC_REGS__TRANSMIT_STATUS__COLLISION_OCCURRED__READ(reg);
    status->retryLimExc =
            EMAC_REGS__TRANSMIT_STATUS__RETRY_LIMIT_EXCEEDED__READ(reg);
    status->lateCollision =
            EMAC_REGS__TRANSMIT_STATUS__LATE_COLLISION_OCCURRED__READ(reg);
    status->txActive =
            EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_GO__READ(reg);
    status->txFrameErr =
            EMAC_REGS__TRANSMIT_STATUS__AMBA_ERROR__READ(reg);
    status->txUnderRun =
            EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_UNDER_RUN__READ(reg);
    status->hRespNotOk =
            EMAC_REGS__TRANSMIT_STATUS__RESP_NOT_OK__READ(reg);
    status->txMacLockup =
            EMAC_REGS__TRANSMIT_STATUS__TX_MAC_LOCKUP_DETECTED__READ(reg);
    status->txDmaLockup =
            EMAC_REGS__TRANSMIT_STATUS__TX_DMA_LOCKUP_DETECTED__READ(reg);

    return reg;
}

/* Reset the bits of EMAC transmit status register as selected in resetStatus
 * @param pD - driver private state info specific to this instance
 * @param resetStatus - OR'd combination of CEDI_TXS_ bit-fields
 */
void emacClearTxStatus(void *pD, uint32_t resetStatus)
{
    uint32_t dst = 0;

    if (!pD) return;
    if (resetStatus & CEDI_TXS_USED_READ)
        EMAC_REGS__TRANSMIT_STATUS__USED_BIT_READ__MODIFY(dst, 1);
    if (resetStatus & CEDI_TXS_COLLISION)
        EMAC_REGS__TRANSMIT_STATUS__COLLISION_OCCURRED__MODIFY(dst, 1);
    if (resetStatus & CEDI_TXS_RETRY_EXC)
        EMAC_REGS__TRANSMIT_STATUS__RETRY_LIMIT_EXCEEDED__MODIFY(dst, 1);
    if (resetStatus & CEDI_TXS_LATE_COLL)
        EMAC_REGS__TRANSMIT_STATUS__LATE_COLLISION_OCCURRED__MODIFY(dst, 1);
    /* txActive not resettable */
    if (resetStatus & CEDI_TXS_FRAME_ERR)
        EMAC_REGS__TRANSMIT_STATUS__AMBA_ERROR__MODIFY(dst, 1);
    if (resetStatus & CEDI_TXS_TX_COMPLETE)
        EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_COMPLETE__MODIFY(dst, 1);
    if (resetStatus & CEDI_TXS_UNDERRUN)
        EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_UNDER_RUN__MODIFY(dst, 1);
    if (resetStatus & CEDI_TXS_HRESP_ERR)
        EMAC_REGS__TRANSMIT_STATUS__RESP_NOT_OK__MODIFY(dst, 1);
    if (dst)
        CPS_UncachedWrite32(CEDI_RegAddr(transmit_status), dst);
}

uint32_t emacSetTxPartialStFwd(void *pD, uint32_t watermark, uint8_t enable)
{
    uint32_t reg;
    if (!pD) return EINVAL;
    if (CEDI_PdVar(hwCfg).tx_pkt_buffer==0)
        return ENOTSUP;
    if (enable>1) return EINVAL;

    if ((enable==1) &&
        ((watermark<0x14) || (watermark>=(1<<CEDI_PdVar(hwCfg).tx_pbuf_addr))))
        return EINVAL;

    reg = CPS_UncachedRead32(CEDI_RegAddr(pbuf_txcutthru));
    if (enable) {
        EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU_THRESHOLD__MODIFY(reg,
                watermark);
        EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU__SET(reg);
    }
    else
        EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU__CLR(reg);

    CPS_UncachedWrite32(CEDI_RegAddr(pbuf_txcutthru), reg);

    return 0;
}

uint32_t emacGetTxPartialStFwd(void *pD, uint32_t *watermark, uint8_t *enable)
{
    uint32_t reg;
    if ((pD==0)||(enable==0)||(watermark==0))
        return EINVAL;
    if (CEDI_PdVar(hwCfg).tx_pkt_buffer==0)
        return ENOTSUP;

    reg = CPS_UncachedRead32(CEDI_RegAddr(pbuf_txcutthru));
    (*enable) = EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU__READ(reg);
    if (*enable)
      (*watermark) = EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU_THRESHOLD__READ(reg);

        return 0;
}


/**
 * Enable credit-based shaping (CBS) on the specified queue.  If already
 * enabled then first disables, sets a new idle slope value for the queue,
 * and re-enables CBS
 * @param[in] pD driver private state info specific to this instance
 * @param[in] qSel if equal 0 selects highest priority queue (queue A),
 *    if equal 1 selects next-highest priority queue (queue B)
 *    $RANGE $FROM 0 $TO 1$
 * @param[in] idleSlope new idle slope value (in bytes/sec)
 * @return 0 if successful
 * @return EINVAL if priority queueing not enabled (i.e. only one Tx queue)
 *      or invalid parameter
 * @return ENOTSUP if CBS has been excluded from h/w config
 * $VALIDFAIL if (CEDI_Config.txQs==1) $EXPECT_RETURN EINVAL $
 */
uint32_t emacEnableCbs(void *pD, uint8_t qSel, uint32_t idleSlope)
{
    uint32_t tmp, ret;
    uint8_t enabled;
    uint32_t reg;

    if (pD==NULL) return EINVAL;

    if (CEDI_PdVar(hwCfg).exclude_cbs==1)
        return ENOTSUP;

    if (CEDI_PdVar(txQs)==1)
        return EINVAL;

    ret = emacGetCbsQSetting(pD, qSel, &enabled, &tmp);
    if (ret!=0)
        return ret;

    if (enabled)
        emacDisableCbs(pD, qSel);

    reg = 0;
    if (qSel) {   /* i.e. queue B */
        EMAC_REGS__CBS_IDLESLOPE_Q_B__IDLESLOPE_B__MODIFY(reg, idleSlope);
        CPS_UncachedWrite32(CEDI_RegAddr(cbs_idleslope_q_b), reg);
    }
    else {
        EMAC_REGS__CBS_IDLESLOPE_Q_A__IDLESLOPE_A__MODIFY(reg, idleSlope);
        CPS_UncachedWrite32(CEDI_RegAddr(cbs_idleslope_q_a), reg);
    }

    reg = CPS_UncachedRead32(CEDI_RegAddr(cbs_control));
    if (qSel)   /* i.e. queue B */
        EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_B__MODIFY(reg, 1);
    else
        EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_A__MODIFY(reg, 1);
    CPS_UncachedWrite32(CEDI_RegAddr(cbs_control), reg);

    return 0;
}

/* Disable CBS on the specified queue
 * @param pD - driver private state info specific to this instance
 * @param qSel - if = 0, selects highest priority queue (queue A), else
 *    selects next-highest priority queue (queue B)
 */
void emacDisableCbs(void *pD, uint8_t qSel)
{
    uint32_t reg;

    if ((!pD) || (qSel>1) || CEDI_PdVar(hwCfg).exclude_cbs) return;
    reg = CPS_UncachedRead32(CEDI_RegAddr(cbs_control));
    if (qSel)   /* i.e. queue B */
        EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_B__MODIFY(reg, 0);
    else
        EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_A__MODIFY(reg, 0);
    CPS_UncachedWrite32(CEDI_RegAddr(cbs_control), reg);
}

/**
 * Read CBS setting for the specified queue.
 * @param[in] pD driver private state info specific to this instance
 * @param[in] qSel if equal 0 selects highest priority queue (queue A),
 *    if equal 1 selects next-highest priority queue (queue B)
 *    $RANGE $FROM 0 $TO 1$
 * @param[out] enable returns: 1 if CBS enabled for the specified queue,
 *    0 if not enabled
 * @param[out] idleSlope pointer for returning the idleSlope value
 *    for selected queue.
 * @return 0 for success.
 * @return EINVAL for invalid pointer.
 * @return ENOTSUP if CBS has been excluded from h/w config
 */
uint32_t emacGetCbsQSetting(void *pD, uint8_t qSel,
               uint8_t *enable, uint32_t *idleSlope)
{
    uint32_t reg, enabled;

    if ((pD==0)||(enable==0)||(idleSlope==0))
        return EINVAL;
    if (CEDI_PdVar(hwCfg).exclude_cbs==1)
        return ENOTSUP;
    if (qSel>1) return EINVAL;

    reg = CPS_UncachedRead32(CEDI_RegAddr(cbs_control));
    if (qSel) { /* i.e. queue B */
        enabled = EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_B__READ(reg);
        if (enabled && (idleSlope!=NULL)) {
            reg = CPS_UncachedRead32(CEDI_RegAddr(cbs_idleslope_q_b));
            *idleSlope = EMAC_REGS__CBS_IDLESLOPE_Q_B__IDLESLOPE_B__READ(reg);
        }
    }
    else {
        enabled = EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_A__READ(reg);
        if (enabled && (idleSlope!=NULL)) {
            reg = CPS_UncachedRead32(CEDI_RegAddr(cbs_idleslope_q_a));
            *idleSlope = EMAC_REGS__CBS_IDLESLOPE_Q_A__IDLESLOPE_A__READ(reg);
        }
    }

    *enable=enabled;
    return 0;
}

/**
 * Enable/disable the inter-packet gap (IPG) stretch function.
 * @param[in] pD driver private state info specific to this instance
 * @param[in] enable if equal 1 then enable IPG stretch, if 0 then disable.
 *    $RANGE $FROM 0 $TO 1$
 * @param[in] multiplier multiplying factor applied to previous Tx frame
 *    length.  Ignored if enable equal 0.
 * @param[in] divisor after multiplying previous frame length, divide by
 *    (divisor+1) - if result>96 bits, this is used for the Tx IPG.
 *    Ignored if enable equal 0.
 * @return EINVAL if pD equal NULL
 * @return 0 if successful.
 */
uint32_t emacSetIpgStretch(void *pD, uint8_t enable, uint8_t multiplier,
        uint8_t divisor)
{
    uint32_t reg;

    if (pD==NULL) return EINVAL;
    if (enable>1) return EINVAL;
    reg = CPS_UncachedRead32(CEDI_RegAddr(network_config));
    if (enable) {
        EMAC_REGS__NETWORK_CONFIG__IPG_STRETCH_ENABLE__SET(reg);
        CPS_UncachedWrite32(CEDI_RegAddr(network_config), reg);
        reg = CPS_UncachedRead32(CEDI_RegAddr(stretch_ratio));
        EMAC_REGS__STRETCH_RATIO__IPG_STRETCH__MODIFY(reg,
                (divisor << 8) | multiplier);
        CPS_UncachedWrite32(CEDI_RegAddr(stretch_ratio), reg);
    }
    else {
        EMAC_REGS__NETWORK_CONFIG__IPG_STRETCH_ENABLE__CLR(reg);
        CPS_UncachedWrite32(CEDI_RegAddr(network_config), reg);
    }
    return 0;
}

/* Read the inter-packet gap (IPG) stretch settings.
 * @param pD - driver private state info specific to this instance
 * @param enabled - pointer for returning enabled state: returns 1 if
 *                 IPG stretch enabled, 0 if disabled.
 * @param multiplier  - pointer for returning IPG multiplying factor.
 * @param divisor  - pointer for returning IPG divisor.
 * @return =0 if successful, EINVAL if any parameter =NULL
 */
uint32_t emacGetIpgStretch(void *pD, uint8_t *enabled, uint8_t *multiplier,
        uint8_t *divisor)
{
    uint32_t reg, stretch;

    if ((pD==NULL) || (enabled==NULL) || (multiplier==NULL) || (divisor==NULL))
        return EINVAL;

    reg = CPS_UncachedRead32(CEDI_RegAddr(network_config));
    if (EMAC_REGS__NETWORK_CONFIG__IPG_STRETCH_ENABLE__READ(reg)) {
        *enabled = 1;
        reg = CPS_UncachedRead32(CEDI_RegAddr(stretch_ratio));
        stretch = EMAC_REGS__STRETCH_RATIO__IPG_STRETCH__READ(reg);
        *multiplier = (stretch & 0xFF);
        *divisor = (stretch >> 8) & 0xFF;
    }
    else {
        *enabled = 0;
        *multiplier = 0;
        *divisor = 0;
    }
    return 0;
}





/* set memory segments per queuee */
uint32_t
DoSetSegAlloc(void *pD, CEDI_SegmentsPerQueue *seqmentsPerQueue, uint8_t numOfQueues)
{
#ifdef EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q15__READ
    uint32_t tx_q_seg_alloc_q0to7, tx_q_seg_alloc_q8to15;

    tx_q_seg_alloc_q0to7 = CPS_UncachedRead32(CEDI_RegAddr(tx_q_seg_alloc_q0to7));
    tx_q_seg_alloc_q8to15 = CPS_UncachedRead32(CEDI_RegAddr(tx_q_seg_alloc_q8to15));

    switch (numOfQueues){
    case 16:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q15__MODIFY(tx_q_seg_alloc_q8to15, seqmentsPerQueue[15]);
        /* Fall through */
    case 15:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q14__MODIFY(tx_q_seg_alloc_q8to15, seqmentsPerQueue[14]);
        /* Fall through */
    case 14:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q13__MODIFY(tx_q_seg_alloc_q8to15, seqmentsPerQueue[13]);
        /* Fall through */
    case 13:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q12__MODIFY(tx_q_seg_alloc_q8to15, seqmentsPerQueue[12]);
        /* Fall through */
    case 12:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q11__MODIFY(tx_q_seg_alloc_q8to15, seqmentsPerQueue[11]);
        /* Fall through */
    case 11:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q10__MODIFY(tx_q_seg_alloc_q8to15, seqmentsPerQueue[10]);
        /* Fall through */
    case 10:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q9__MODIFY(tx_q_seg_alloc_q8to15, seqmentsPerQueue[9]);
        /* Fall through */
    case 9:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q8__MODIFY(tx_q_seg_alloc_q8to15, seqmentsPerQueue[8]);
        /* Fall through */
    case 8:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q7__MODIFY(tx_q_seg_alloc_q0to7, seqmentsPerQueue[7]);
        /* Fall through */
    case 7:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q6__MODIFY(tx_q_seg_alloc_q0to7, seqmentsPerQueue[6]);
        /* Fall through */
    case 6:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q5__MODIFY(tx_q_seg_alloc_q0to7, seqmentsPerQueue[5]);
        /* Fall through */
    case 5:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q4__MODIFY(tx_q_seg_alloc_q0to7, seqmentsPerQueue[4]);
        /* Fall through */
    case 4:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q3__MODIFY(tx_q_seg_alloc_q0to7, seqmentsPerQueue[3]);
        /* Fall through */
    case 3:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q2__MODIFY(tx_q_seg_alloc_q0to7, seqmentsPerQueue[2]);
        /* Fall through */
    case 2:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q1__MODIFY(tx_q_seg_alloc_q0to7, seqmentsPerQueue[1]);
        /* Fall through */
    case 1:
        EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q0__MODIFY(tx_q_seg_alloc_q0to7, seqmentsPerQueue[0]);
        /* Fall through */
        break;
    default:
        return EINVAL;
    }

    CPS_UncachedWrite32(CEDI_RegAddr(tx_q_seg_alloc_q0to7), tx_q_seg_alloc_q0to7);
    CPS_UncachedWrite32(CEDI_RegAddr(tx_q_seg_alloc_q8to15), tx_q_seg_alloc_q8to15);

    return 0;
#endif

    return ENOTSUP;
}

/* get memory segments per queue */
uint32_t
DoGetSegAlloc(void *pD, CEDI_SegmentsPerQueue *seqmentsPerQueue, uint8_t numOfQueues)
{
#ifdef EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q15__READ
    uint32_t tx_q_seg_alloc_q0to7, tx_q_seg_alloc_q8to15;

    tx_q_seg_alloc_q0to7 = CPS_UncachedRead32(CEDI_RegAddr(tx_q_seg_alloc_q0to7));
    tx_q_seg_alloc_q8to15 = CPS_UncachedRead32(CEDI_RegAddr(tx_q_seg_alloc_q8to15));

    switch(numOfQueues){
    case 16:
        seqmentsPerQueue[15] = EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q15__READ(tx_q_seg_alloc_q8to15);
        /* Fall through */
    case 15:
        seqmentsPerQueue[14] = EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q14__READ(tx_q_seg_alloc_q8to15);
        /* Fall through */
    case 14:
        seqmentsPerQueue[13] = EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q13__READ(tx_q_seg_alloc_q8to15);
        /* Fall through */
    case 13:
        seqmentsPerQueue[12] = EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q12__READ(tx_q_seg_alloc_q8to15);
        /* Fall through */
    case 12:
        seqmentsPerQueue[11] = EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q11__READ(tx_q_seg_alloc_q8to15);
        /* Fall through */
    case 11:
        seqmentsPerQueue[10] = EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q10__READ(tx_q_seg_alloc_q8to15);
        /* Fall through */
    case 10:
        seqmentsPerQueue[9] = EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q9__READ(tx_q_seg_alloc_q8to15);
        /* Fall through */
    case 9:
        seqmentsPerQueue[8] = EMAC_REGS__TX_Q_SEG_ALLOC_Q8TO15__SEGMENT_ALLOC_Q8__READ(tx_q_seg_alloc_q8to15);
        /* Fall through */

    case 8:
        seqmentsPerQueue[7] = EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q7__READ(tx_q_seg_alloc_q0to7);
        /* Fall through */
    case 7:
        seqmentsPerQueue[6] = EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q6__READ(tx_q_seg_alloc_q0to7);
        /* Fall through */
    case 6:
        seqmentsPerQueue[5] = EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q5__READ(tx_q_seg_alloc_q0to7);
        /* Fall through */
    case 5:
        seqmentsPerQueue[4] = EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q4__READ(tx_q_seg_alloc_q0to7);
        /* Fall through */
    case 4:
        seqmentsPerQueue[3] = EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q3__READ(tx_q_seg_alloc_q0to7);
        /* Fall through */
    case 3:
        seqmentsPerQueue[2] = EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q2__READ(tx_q_seg_alloc_q0to7);
        /* Fall through */
    case 2:
        seqmentsPerQueue[1] = EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q1__READ(tx_q_seg_alloc_q0to7);
        /* Fall through */
    case 1:
        seqmentsPerQueue[0] = EMAC_REGS__TX_Q_SEG_ALLOC_Q0TO7__SEGMENT_ALLOC_Q0__READ(tx_q_seg_alloc_q0to7);
        /* Fall through */
        break;
    default:
        return EINVAL;
    }

    return 0;
#endif
    return ENOTSUP;
}

/* functions check if sum of segments for each queue does not exceed
 * all segments count. Calculation is made for given queue count.
 * Function also verify if queue size value is proper - does not
 * exceed maximum value */
static uint32_t
CheckSegAlloc(void *pD, CEDI_SegmentsPerQueue *seqmentsPerQueue, uint8_t segAllocCount)
{
    int i;
    uint32_t SegAllocsSummary = 0;

    for (i = 0; i < segAllocCount; i++){
        if (seqmentsPerQueue[i] > CEDI_SEGMENTS_PER_QUEUE_128){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Number of queues to configure are diffrents than active queues\n");
            return EINVAL;
        }
        SegAllocsSummary += (1 << seqmentsPerQueue[i]);
    }

    if (SegAllocsSummary > (1 << CEDI_PdVar(hwCfg).tx_pbuf_queue_segment_size)){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                "Error: Number of segments for all active queues: %d, "
                "is bigger than number of available segments %d\n", SegAllocsSummary,
                 (1 << CEDI_PdVar(hwCfg).tx_pbuf_queue_segment_size));
        return EINVAL;
    }

    return 0;
}

 /** configure number of memory segments used by Tx queue */
uint32_t
emacSetSegAlloc(void *pD, CEDI_QueueSegAlloc *queueSegAlloc)
{
    uint32_t status;
    int i;
    CEDI_SegmentsPerQueue seqmentsPerQueue[CEDI_MAX_TX_QUEUES];

    if ((pD == NULL) || (queueSegAlloc == NULL))
        return EINVAL;

    if (queueSegAlloc->segAllocCount > CEDI_PdVar(cfg).txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Number of queues to configure are bigger than supported queue number\n");
        return EINVAL;
    }

    status = CheckSegAlloc(pD, queueSegAlloc->segAlloc, queueSegAlloc->segAllocCount);
    if (status)
        return status;

    for (i = 0; i < queueSegAlloc->segAllocCount; i++){
        if (i < queueSegAlloc->segAllocCount)
            seqmentsPerQueue[i] = queueSegAlloc->segAlloc[i];
        else
            seqmentsPerQueue[i] = 0;
    }

    return DoSetSegAlloc(pD, seqmentsPerQueue, CEDI_MAX_TX_QUEUES);
}

 /** function gets number of memory segments used by Tx queue */
uint32_t
emacGetAllSegAlloctCount(void *pD, uint32_t *numberOfSegments)
{
    if ((pD == NULL) || (numberOfSegments == NULL))
        return EINVAL;

    *numberOfSegments = (1uL << CEDI_PdVar(hwCfg).tx_pbuf_queue_segment_size);
    return 0;
}

/* get memory segments per queue */
uint32_t
emacGetSegAlloc(void *pD, CEDI_QueueSegAlloc *queueSegAlloc)
{
    uint32_t status;

    if ((pD == NULL) || (queueSegAlloc == NULL))
        return EINVAL;

    if (queueSegAlloc->segAllocCount > CEDI_PdVar(cfg).txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Number of queues to configure are bigger than supported queue number\n");
        return EINVAL;
    }

    status = DoGetSegAlloc(pD, queueSegAlloc->segAlloc, queueSegAlloc->segAllocCount);
    if (status)
        return status;

    return 0;
}

/* set number of active TX queues - Sw dis/enabling of TX priority queues */
uint32_t
emacSetTxQueueNum(void *pD, uint8_t numQueues)
{

#define CEDI_WR_TXQ_DIS_CASE(Q, disable) case Q:\
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(transmit_q##Q##_ptr));\
	EMAC_REGS__TRANSMIT_Q_PTR__DMA_TX_DIS_Q__MODIFY(regTmp, disable);\
        CPS_UncachedWrite32(CEDI_RegAddr(transmit_q##Q##_ptr), regTmp)

    uint32_t regTmp, status;
    CEDI_SegmentsPerQueue seqmentsPerQueue[CEDI_MAX_TX_QUEUES];

    if (pD == NULL)
        return EINVAL;

    /* number of queues cannot be bigger than set during driver initialization */
    if (numQueues >  CEDI_PdVar(cfg).txQs)
        return EINVAL;

    /* at least one queue must be enabled */
    if (numQueues < 1)
        return EINVAL;

    /*  */
    if (numQueues == ((CEDI_PrivateData *)pD)->txQs)
        return 0;

    if (!IsGem1p09(pD)){
        vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                "Warning: changing queue number is not supported\n");
        return ENOTSUP;
    }

#ifdef EMAC_REGS__TRANSMIT_Q_PTR__DMA_TX_DIS_Q__MODIFY
    /* Transmission must be disabled before calling this function */
    if (emacGetTxEnabled(pD))
        return EIO;


    /* get current segment allocation setting */
    status = DoGetSegAlloc(pD, seqmentsPerQueue, numQueues);
    if (status)
        return status;

    /* check if new queue settings make using segments above available segments */
    status = CheckSegAlloc(pD, seqmentsPerQueue, numQueues);
    if (status)
        return status;


    switch(numQueues){
        CEDI_WR_TXQ_DIS_CASE(15, 0);
        CEDI_WR_TXQ_DIS_CASE(14, 0);
        CEDI_WR_TXQ_DIS_CASE(13, 0);
        CEDI_WR_TXQ_DIS_CASE(12, 0);
        CEDI_WR_TXQ_DIS_CASE(11, 0);
        CEDI_WR_TXQ_DIS_CASE(10, 0);
        CEDI_WR_TXQ_DIS_CASE(9, 0);
        CEDI_WR_TXQ_DIS_CASE(8, 0);
        CEDI_WR_TXQ_DIS_CASE(7, 0);
        CEDI_WR_TXQ_DIS_CASE(6, 0);
        CEDI_WR_TXQ_DIS_CASE(5, 0);
        CEDI_WR_TXQ_DIS_CASE(4, 0);
        CEDI_WR_TXQ_DIS_CASE(3, 0);
        CEDI_WR_TXQ_DIS_CASE(2, 0);
        CEDI_WR_TXQ_DIS_CASE(1, 0);
    }

    switch(numQueues){
        CEDI_WR_TXQ_DIS_CASE(1, 1);
        CEDI_WR_TXQ_DIS_CASE(2, 1);
        CEDI_WR_TXQ_DIS_CASE(3, 1);
        CEDI_WR_TXQ_DIS_CASE(4, 1);
        CEDI_WR_TXQ_DIS_CASE(5, 1);
        CEDI_WR_TXQ_DIS_CASE(6, 1);
        CEDI_WR_TXQ_DIS_CASE(7, 1);
        CEDI_WR_TXQ_DIS_CASE(8, 1);
        CEDI_WR_TXQ_DIS_CASE(9, 1);
        CEDI_WR_TXQ_DIS_CASE(10, 1);
        CEDI_WR_TXQ_DIS_CASE(11, 1);
        CEDI_WR_TXQ_DIS_CASE(12, 1);
        CEDI_WR_TXQ_DIS_CASE(13, 1);
        CEDI_WR_TXQ_DIS_CASE(14, 1);
        CEDI_WR_TXQ_DIS_CASE(15, 1);
    }

    /* set new tx priority queues number */
    ((CEDI_PrivateData *)pD)->txQs = numQueues;

    return 0;
#else
    return ENOTSUP;
#endif

}

/* get number of active TX queues */
uint32_t
emacGetTxQueueNum(void *pD, uint8_t *numQueues)
{
    if ((pD == NULL) || (numQueues == NULL))
        return EINVAL;

    *numQueues = ((CEDI_PrivateData *)pD)->txQs;

    return 0;
}

/* select scheduler for TX queue */
uint32_t
emacSetTxQueueScheduler(void *pD, uint8_t queueNum, CEDI_TxSchedType schedType)
{
    uint32_t regTmp;
    uint8_t txQs;

    if (pD == NULL)
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    txQs = ((CEDI_PrivateData *)pD)->txQs;

    if (queueNum >= txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }

    if (schedType > CEDI_TX_SCHED_TYPE_ETS){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Wrong algorithm type\n");
        return EINVAL;
    }

    if ((schedType == CEDI_TX_SCHED_TYPE_CBS) && (txQs > 2)
        && (queueNum < (txQs - 2))){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: CBS can be set only to highest priority queue and second highest priority queue \n");
        return EINVAL;
    }
#ifdef __EMAC_REGS__TX_SCHED_CTRL_MACRO__
    if (!IsGem1p09(pD)) {
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "Feature not supported- current moduleId:%0x , expected is above:%0x \n",
                CEDI_PdVar(hwCfg).moduleId , GEM_GXL_MODULE_ID_V1 );
        return ENOTSUP;
    }

    regTmp = CPS_UncachedRead32(CEDI_RegAddr(tx_sched_ctrl));
    switch(queueNum){
    case 0:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q0__MODIFY(regTmp, schedType);
        break;
    case 1:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q1__MODIFY(regTmp, schedType);
        break;
    case 2:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q2__MODIFY(regTmp, schedType);
        break;
    case 3:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q3__MODIFY(regTmp, schedType);
        break;
    case 4:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q4__MODIFY(regTmp, schedType);
        break;
    case 5:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q5__MODIFY(regTmp, schedType);
        break;
    case 6:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q6__MODIFY(regTmp, schedType);
        break;
    case 7:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q7__MODIFY(regTmp, schedType);
        break;
    case 8:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q8__MODIFY(regTmp, schedType);
        break;
    case 9:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q9__MODIFY(regTmp, schedType);
        break;
    case 10:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q10__MODIFY(regTmp, schedType);
        break;
    case 11:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q11__MODIFY(regTmp, schedType);
        break;
    case 12:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q12__MODIFY(regTmp, schedType);
        break;
    case 13:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q13__MODIFY(regTmp, schedType);
        break;
    case 14:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q14__MODIFY(regTmp, schedType);
        break;
    case 15:
	EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q15__MODIFY(regTmp, schedType);
        break;
    default:
        return EINVAL;
    }

    CPS_UncachedWrite32(CEDI_RegAddr(tx_sched_ctrl), regTmp);

    return 0;
#else
    return ENOTSUP;
#endif
}


/* get select scheduler for TX queue */
uint32_t
emacGetTxQueueScheduler(void *pD, uint8_t queueNum, CEDI_TxSchedType *schedType)
{
    uint32_t regTmp;

    if ((pD == NULL) || (schedType == NULL))
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (queueNum >= ((CEDI_PrivateData *)pD)->txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }


#ifdef __EMAC_REGS__TX_SCHED_CTRL_MACRO__
    regTmp = CPS_UncachedRead32(CEDI_RegAddr(tx_sched_ctrl));
    switch(queueNum){
    case 0:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q0__READ(regTmp);
        break;
    case 1:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q1__READ(regTmp);
        break;
    case 2:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q2__READ(regTmp);
        break;
    case 3:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q3__READ(regTmp);
        break;
    case 4:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q4__READ(regTmp);
        break;
    case 5:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q5__READ(regTmp);
        break;
    case 6:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q6__READ(regTmp);
        break;
    case 7:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q7__READ(regTmp);
        break;
    case 8:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q8__READ(regTmp);
        break;
    case 9:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q9__READ(regTmp);
        break;
    case 10:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q10__READ(regTmp);
        break;
    case 11:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q11__READ(regTmp);
        break;
    case 12:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q12__READ(regTmp);
        break;
    case 13:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q13__READ(regTmp);
        break;
    case 14:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q14__READ(regTmp);
        break;
    case 15:
	*schedType = EMAC_REGS__TX_SCHED_CTRL__TX_SCHED_Q15__READ(regTmp);
        break;
    default:
        return EINVAL;
    }
#else
    return ENOTSUP;
#endif

    return 0;
}

/* configure rate limit for ETS or DWRR scheduler */
static uint32_t
emacSetRateLimit(void *pD, uint8_t queueNum, uint8_t limit)
{
    uint32_t regTmp;

    if (pD == NULL)
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (queueNum >= ((CEDI_PrivateData *)pD)->txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }
#ifdef __EMAC_REGS__BW_RATE_LIMIT_Q0TO3_MACRO__
    if (!IsGem1p09(pD)) {
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "Feature not supported- current moduleId:%0x , expected is above:%0x \n",
                CEDI_PdVar(hwCfg).moduleId , GEM_GXL_MODULE_ID_V1 );
        return ENOTSUP;
    }
    switch(queueNum){
    case 0:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q0to3));
	EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q0__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q0to3), regTmp);
        break;
    case 1:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q0to3));
	EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q1__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q0to3), regTmp);
        break;
    case 2:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q0to3));
	EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q2__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q0to3), regTmp);
        break;
    case 3:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q0to3));
	EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q3__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q0to3), regTmp);
        break;
    case 4:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q4to7));
	EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q4__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q4to7), regTmp);
        break;
    case 5:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q4to7));
	EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q5__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q4to7), regTmp);
        break;
    case 6:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q4to7));
	EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q6__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q4to7), regTmp);
        break;
    case 7:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q4to7));
	EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q7__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q4to7), regTmp);
        break;
    case 8:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q8to11));
	EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q8__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q8to11), regTmp);
        break;
    case 9:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q8to11));
	EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q9__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q8to11), regTmp);
        break;
    case 10:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q8to11));
	EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q10__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q8to11), regTmp);
        break;
    case 11:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q8to11));
	EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q11__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q8to11), regTmp);
        break;
    case 12:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q12to15));
	EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q12__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q12to15), regTmp);
        break;
    case 13:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q12to15));
	EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q13__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q12to15), regTmp);
        break;
    case 14:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q12to15));
	EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q14__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q12to15), regTmp);
        break;
    case 15:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q12to15));
	EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q15__MODIFY(regTmp, limit);
        CPS_UncachedWrite32(CEDI_RegAddr(bw_rate_limit_q12to15), regTmp);
        break;
    default:
        return EINVAL;
    }


    return EOK;
#else
    return ENOTSUP;
#endif


}

/* get rate limit for ETS or DWRR scheduler */
static uint32_t
emacGetRateLimit(void *pD, uint8_t queueNum, uint8_t *limit)
{
    uint32_t regTmp;

    if (pD == NULL || limit == NULL)
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (queueNum >= ((CEDI_PrivateData *)pD)->txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }
#ifdef __EMAC_REGS__BW_RATE_LIMIT_Q0TO3_MACRO__
    if (!IsGem1p09(pD)) {
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "Feature not supported- current moduleId:%0x , expected is above:%0x \n",
                CEDI_PdVar(hwCfg).moduleId , GEM_GXL_MODULE_ID_V1 );
        return ENOTSUP;
    }
    switch(queueNum){
    case 0:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q0to3));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q0__READ(regTmp);
        break;
    case 1:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q0to3));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q1__READ(regTmp);
        break;
    case 2:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q0to3));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q2__READ(regTmp);
        break;
    case 3:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q0to3));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q3__READ(regTmp);
        break;
    case 4:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q4to7));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q4__READ(regTmp);
        break;
    case 5:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q4to7));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q5__READ(regTmp);
        break;
    case 6:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q4to7));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q6__READ(regTmp);
        break;
    case 7:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q4to7));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q7__READ(regTmp);
        break;
    case 8:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q8to11));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q8__READ(regTmp);
        break;
    case 9:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q8to11));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q9__READ(regTmp);
        break;
    case 10:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q8to11));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q10__READ(regTmp);
        break;
    case 11:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q8to11));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q11__READ(regTmp);
        break;
    case 12:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q12to15));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q12__READ(regTmp);
        break;
    case 13:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q12to15));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q13__READ(regTmp);
        break;
    case 14:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q12to15));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q14__READ(regTmp);
        break;
    case 15:
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(bw_rate_limit_q12to15));
	*limit = EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q15__READ(regTmp);
        break;
    default:
        return EINVAL;
    }


    return EOK;
#else
    return ENOTSUP;
#endif


}

/* configure DWRR Weighting of DWRR scheduler */
uint32_t
emacSetDwrrWeighting(void *pD, uint8_t queueNum, uint8_t dwrrWeighting)
{
    CEDI_TxSchedType schedType;

    if (pD == NULL)
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (queueNum >= ((CEDI_PrivateData *)pD)->txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }

    emacGetTxQueueScheduler(pD, queueNum, &schedType);
    if (schedType != CEDI_TX_SCHED_TYPE_DWRR){
        vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                "Warning: Wrong scheduler type is set. Change it to \"CEDI_TX_SCHED_TYPE_DWRR\" \n");
    }

    return emacSetRateLimit(pD, queueNum, dwrrWeighting);
}

/* configure bandwidth allocation of ETS scheduler */
uint32_t
emacSetEtsBandAlloc(void *pD, uint8_t queueNum, uint8_t etsBandAlloc)
{
    CEDI_TxSchedType schedType;

    if (pD == NULL)
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (queueNum >= ((CEDI_PrivateData *)pD)->txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }

    emacGetTxQueueScheduler(pD, queueNum, &schedType);
    if (schedType != CEDI_TX_SCHED_TYPE_ETS){
        vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                "Warning: Wrong scheduler type is set. Change it to \"CEDI_TX_SCHED_TYPE_ETS\" \n");
    }

    return emacSetRateLimit(pD, queueNum, etsBandAlloc);
}

/* get DWRR Weighting of DWRR scheduler */
uint32_t
emacGetDwrrWeighting(void *pD, uint8_t queueNum, uint8_t *dwrrWeighting)
{
    CEDI_TxSchedType schedType;

    if ((pD == NULL) || (dwrrWeighting==NULL))
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (queueNum >= ((CEDI_PrivateData *)pD)->txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to get value from is bigger than number of active queues\n");
        return EINVAL;
    }

    emacGetTxQueueScheduler(pD, queueNum, &schedType);
    if (schedType != CEDI_TX_SCHED_TYPE_DWRR){
        vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                "Warning: \"CEDI_TX_SCHED_TYPE_DWRR\" is not current scheduler type. \n");
    }

    return emacGetRateLimit(pD, queueNum, dwrrWeighting);
}

/* get bandwidth allocation of ETS scheduler */
uint32_t
emacGetEtsBandAlloc(void *pD, uint8_t queueNum, uint8_t *etsBandAlloc)
{
    CEDI_TxSchedType schedType;

    if ((pD == NULL) || (etsBandAlloc==NULL))
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (queueNum >= ((CEDI_PrivateData *)pD)->txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to get value from is bigger than number of active queues\n");
        return EINVAL;
    }

    emacGetTxQueueScheduler(pD, queueNum, &schedType);
    if (schedType != CEDI_TX_SCHED_TYPE_ETS){
        vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                "Warning: \"CEDI_TX_SCHED_TYPE_ETS\" is not current scheduler type. \n");
    }

    return emacGetRateLimit(pD, queueNum, etsBandAlloc);
}

/* configure timing for Enhancement for Scheduled Traffic priority scheduler */
uint32_t
emacSetEnstTimeConfig(void *pD, uint8_t queueNum, CEDI_EnstTimeConfig *enstTimeConfig)
{
#define CEDI_WR_ENST_TIMING_CASE(Q, enst) case Q:\
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(enst_start_time_q##Q));\
	EMAC_REGS__ENST_START_TIME_Q##Q##__START_TIME_NSEC__MODIFY(regTmp, enst->startTimeNs);\
	EMAC_REGS__ENST_START_TIME_Q##Q##__START_TIME_SEC__MODIFY(regTmp, enst->startTimeS);\
        CPS_UncachedWrite32(CEDI_RegAddr(enst_start_time_q##Q), regTmp);\
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(enst_on_time_q##Q));\
	EMAC_REGS__ENST_ON_TIME_Q##Q##__ON_TIME__MODIFY(regTmp, enst->onTime);\
        CPS_UncachedWrite32(CEDI_RegAddr(enst_on_time_q##Q), regTmp);\
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(enst_off_time_q##Q));\
	EMAC_REGS__ENST_OFF_TIME_Q##Q##__OFF_TIME__MODIFY(regTmp, enst->offTime);\
        CPS_UncachedWrite32(CEDI_RegAddr(enst_off_time_q##Q), regTmp);\
        break;

    uint32_t regTmp;
    uint8_t queueIdx, txQs;

    if ((pD == NULL) || (enstTimeConfig == NULL))
        return EINVAL;

    txQs = ((CEDI_PrivateData *)pD)->txQs;

    if (queueNum >= txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }

    if ((txQs > 8) && (queueNum < (txQs - 8))){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                "Error: Queue number must bigger than %d\n", txQs - 8);
        return EINVAL;
    }


    if (enstTimeConfig->startTimeS > 3){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Start time is bigger than maximum supported value: 3\n");
        return EINVAL;
    }

    if (enstTimeConfig->startTimeNs >= 0x40000000){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Start time nano second is bigger than maximum supported value: 0x3FFFFFFF\n");
        return EINVAL;
    }

    if (enstTimeConfig->onTime >= 0x200000){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: On time is bigger than maximum supported value: 0x1FFFF\n");
        return EINVAL;
    }

    if (enstTimeConfig->offTime >= 0x200000){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Off time is bigger than maximum supported value: 0x1FFFF\n");
        return EINVAL;
    }


#ifdef __EMAC_REGS__ENST_START_TIME_Q8_MACRO__
    if (IsEnstSupported(pD) == 0)
        return ENOTSUP;


    if (txQs < 9){
        queueIdx = queueNum + 8;
    }
    else {
        queueIdx = queueNum + (txQs - 8);
    }

    switch (queueIdx){
    CEDI_WR_ENST_TIMING_CASE(8, enstTimeConfig);
    CEDI_WR_ENST_TIMING_CASE(9, enstTimeConfig);
    CEDI_WR_ENST_TIMING_CASE(10, enstTimeConfig);
    CEDI_WR_ENST_TIMING_CASE(11, enstTimeConfig);
    CEDI_WR_ENST_TIMING_CASE(12, enstTimeConfig);
    CEDI_WR_ENST_TIMING_CASE(13, enstTimeConfig);
    CEDI_WR_ENST_TIMING_CASE(14, enstTimeConfig);
    CEDI_WR_ENST_TIMING_CASE(15, enstTimeConfig);
    }
#else
    return ENOTSUP;
#endif
    return EOK;

}

/* get timing configuration of Enhancement for Scheduled Traffic priority scheduler */
uint32_t
emacGetEnstTimeConfig(void *pD, uint8_t queueNum, CEDI_EnstTimeConfig *enstTimeConfig)
{
#define CEDI_RD_ENST_TIMING_CASE(Q, enst) case Q:\
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(enst_start_time_q##Q));\
	enst->startTimeNs = EMAC_REGS__ENST_START_TIME_Q##Q##__START_TIME_NSEC__READ(regTmp);\
	enst->startTimeS = EMAC_REGS__ENST_START_TIME_Q##Q##__START_TIME_SEC__READ(regTmp);\
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(enst_on_time_q##Q));\
        enst->onTime = EMAC_REGS__ENST_ON_TIME_Q##Q##__ON_TIME__READ(regTmp);\
	regTmp = CPS_UncachedRead32(CEDI_RegAddr(enst_off_time_q##Q));\
	enst->offTime = EMAC_REGS__ENST_OFF_TIME_Q##Q##__OFF_TIME__READ(regTmp);\
        break;

    uint32_t regTmp;
    uint8_t txQs;
    uint8_t queueIdx;

    if ((pD == NULL) || (enstTimeConfig == NULL))
        return EINVAL;

    txQs = ((CEDI_PrivateData *)pD)->txQs;

    if (queueNum >= txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }

    if ((txQs > 8) && (queueNum < (txQs - 8))){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                "Error: Queue number must bigger than %d\n", txQs - 8);
        return EINVAL;
    }

    if (txQs < 9){
        queueIdx = queueNum + 8;
    }
    else {
        queueIdx = queueNum + (txQs - 8);
    }


#ifdef __EMAC_REGS__ENST_START_TIME_Q8_MACRO__
    if (IsEnstSupported(pD) == 0)
        return ENOTSUP;

    switch (queueIdx){
    CEDI_RD_ENST_TIMING_CASE(8, enstTimeConfig);
    CEDI_RD_ENST_TIMING_CASE(9, enstTimeConfig);
    CEDI_RD_ENST_TIMING_CASE(10, enstTimeConfig);
    CEDI_RD_ENST_TIMING_CASE(11, enstTimeConfig);
    CEDI_RD_ENST_TIMING_CASE(12, enstTimeConfig);
    CEDI_RD_ENST_TIMING_CASE(13, enstTimeConfig);
    CEDI_RD_ENST_TIMING_CASE(14, enstTimeConfig);
    CEDI_RD_ENST_TIMING_CASE(15, enstTimeConfig);
    }
#else
    return ENOTSUP;
#endif

    return EOK;
}

/* enable/disable Scheduled Traffic priority scheduler */
uint32_t
emacSetEnstEnable(void *pD, uint8_t queue, uint8_t enable)
{
    uint32_t regTmp;
    uint8_t queueIdx, txQs;

    if ((pD == NULL) || (enable > 1))
        return EINVAL;

    txQs = ((CEDI_PrivateData *)pD)->txQs;

    if (queue >= txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }

    if ((txQs > 8) && (queue < (txQs - 8))){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                "Error: Queue number must bigger than %d\n", txQs - 8);
        return EINVAL;
    }


#ifdef __EMAC_REGS__ENST_CONTROL_MACRO__

    if (IsEnstSupported(pD) == 0)
        return ENOTSUP;


    if (txQs < 9){
        queueIdx = queue + 8;
    }
    else {
        queueIdx = queue + (txQs - 8);
    }


    regTmp = CPS_UncachedRead32(CEDI_RegAddr(enst_control));
    switch (queueIdx){
    case 8:
        EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q8__MODIFY(regTmp, enable);
        EMAC_REGS__ENST_CONTROL__ENST_DISABLE_Q8__MODIFY(regTmp, !enable);
        break;
    case 9:
        EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q9__MODIFY(regTmp, enable);
        EMAC_REGS__ENST_CONTROL__ENST_DISABLE_Q9__MODIFY(regTmp, !enable);
        break;
    case 10:
        EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q10__MODIFY(regTmp, enable);
        EMAC_REGS__ENST_CONTROL__ENST_DISABLE_Q10__MODIFY(regTmp, !enable);
        break;
    case 11:
        EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q11__MODIFY(regTmp, enable);
        EMAC_REGS__ENST_CONTROL__ENST_DISABLE_Q11__MODIFY(regTmp, !enable);
        break;
    case 12:
        EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q12__MODIFY(regTmp, enable);
        EMAC_REGS__ENST_CONTROL__ENST_DISABLE_Q12__MODIFY(regTmp, !enable);
        break;
    case 13:
        EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q13__MODIFY(regTmp, enable);
        EMAC_REGS__ENST_CONTROL__ENST_DISABLE_Q13__MODIFY(regTmp, !enable);
        break;
    case 14:
        EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q14__MODIFY(regTmp, enable);
        EMAC_REGS__ENST_CONTROL__ENST_DISABLE_Q14__MODIFY(regTmp, !enable);
        break;
    case 15:
        EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q15__MODIFY(regTmp, enable);
        EMAC_REGS__ENST_CONTROL__ENST_DISABLE_Q15__MODIFY(regTmp, !enable);
        break;
    }
    CPS_UncachedWrite32(CEDI_RegAddr(enst_control), regTmp);

    return EOK;
#else
    return ENOTSUP;
#endif
}

/* get state(enabled/disabled) of Scheduled Traffic priority scheduler.  */
uint32_t
emacGetEnstEnable(void *pD, uint8_t queue, uint8_t *enable)
{
    uint32_t regTmp;
    uint8_t queueIdx, txQs;

    if ((pD == NULL) || (enable == NULL))
        return EINVAL;

    txQs = ((CEDI_PrivateData *)pD)->txQs;
    if (queue >= txQs){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number to configure is bigger than number of active queues\n");
        return EINVAL;
    }

    if ((txQs > 8) && (queue < (txQs - 8))){
        vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                "Error: Queue number must bigger than %d\n", txQs - 8);
        return EINVAL;
    }

#ifdef __EMAC_REGS__ENST_CONTROL_MACRO__
    if (IsEnstSupported(pD) == 0)
        return ENOTSUP;

    if (txQs < 9){
        queueIdx = queue + 8;
    }
    else {
        queueIdx = queue + (txQs - 8);
    }

    regTmp = CPS_UncachedRead32(CEDI_RegAddr(enst_control));
    switch (queueIdx){
    case 8:
        *enable = EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q8__READ(regTmp);
        break;
    case 9:
        *enable = EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q9__READ(regTmp);
        break;
    case 10:
        *enable = EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q10__READ(regTmp);
        break;
    case 11:
        *enable = EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q11__READ(regTmp);
        break;
    case 12:
        *enable = EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q12__READ(regTmp);
        break;
    case 13:
        *enable = EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q13__READ(regTmp);
        break;
    case 14:
        *enable = EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q14__READ(regTmp);
        break;
    case 15:
        *enable = EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q15__READ(regTmp);
        break;
    }

    return EOK;
#else
    return ENOTSUP;
#endif
}

/* check, if EnST is supported by core */
uint32_t emacGetEnstSupported(void *pD, uint8_t *supported)
{
    if ((pD==NULL) || (supported==NULL)) return EINVAL;

    *supported = IsEnstSupported(pD);
    return 0;
}

/* function configures idle slope parameter for CBS priority queuing scheduler */
uint32_t emacSetCbsIdleSlope(void *pD, uint8_t queueNum, uint32_t idleSlope)
{
    uint32_t ret, reg;
    CEDI_TxSchedType schedType;

    if (pD==NULL) return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (CEDI_PdVar(hwCfg).exclude_cbs==1)
        return ENOTSUP;

    if (CEDI_PdVar(txQs)==1)
        return EINVAL;

    if (queueNum >= CEDI_PdVar(txQs))
        return EINVAL;

    if (queueNum < (CEDI_PdVar(txQs) - 2))
        return EINVAL;


    ret = emacGetTxQueueScheduler(pD, queueNum, &schedType);
    if (ret!=0)
        return ret;

    if (schedType == CEDI_TX_SCHED_TYPE_CBS){
        ret = emacSetTxQueueScheduler(pD, queueNum, CEDI_TX_SCHED_TYPE_FIXED);
        if (ret!=0)
            return ret;
    }

    reg = 0;
    if (queueNum == (CEDI_PdVar(txQs) - 2)) {   /* i.e. queue B */
        EMAC_REGS__CBS_IDLESLOPE_Q_B__IDLESLOPE_B__MODIFY(reg, idleSlope);
        CPS_UncachedWrite32(CEDI_RegAddr(cbs_idleslope_q_b), reg);
    }
    else if (queueNum == (CEDI_PdVar(txQs) - 1)) {   /* i.e. queue A */
        EMAC_REGS__CBS_IDLESLOPE_Q_A__IDLESLOPE_A__MODIFY(reg, idleSlope);
        CPS_UncachedWrite32(CEDI_RegAddr(cbs_idleslope_q_a), reg);
    }

    /* recover CBS scheduler type */
    if (schedType == CEDI_TX_SCHED_TYPE_CBS){
        ret = emacSetTxQueueScheduler(pD, queueNum, CEDI_TX_SCHED_TYPE_CBS);
        if (ret!=0)
            return ret;
    }

    return 0;
}

/* get configuration of idle slope parameter for CBS priority queuing scheduler */
uint32_t emacGetCbsIdleSlope(void *pD, uint8_t queueNum, uint32_t *idleSlope)
{
    uint32_t reg;

    if ((pD==0)||(idleSlope==0))
        return EINVAL;

    if (CEDI_MAC_TYPE_EMAC == CEDI_PdVar(macType))
        return ENOTSUP;

    if (CEDI_PdVar(hwCfg).exclude_cbs==1)
        return ENOTSUP;

    if (CEDI_PdVar(txQs)==1)
        return EINVAL;

    if (queueNum >= CEDI_PdVar(txQs))
        return EINVAL;

    if (queueNum < (CEDI_PdVar(txQs) - 2))
        return EINVAL;


    if (queueNum == (CEDI_PdVar(txQs) - 2)) {   /* i.e. queue B */
        reg = CPS_UncachedRead32(CEDI_RegAddr(cbs_idleslope_q_b));
        *idleSlope = EMAC_REGS__CBS_IDLESLOPE_Q_B__IDLESLOPE_B__READ(reg);
    }
    else if (queueNum == (CEDI_PdVar(txQs) - 1)) {   /* i.e. queue A */
        reg = CPS_UncachedRead32(CEDI_RegAddr(cbs_idleslope_q_a));
        *idleSlope = EMAC_REGS__CBS_IDLESLOPE_Q_A__IDLESLOPE_A__READ(reg);
    }

    return 0;
}




