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
 * edd_tx.c
 * Ethernet DMA MAC Driver
 *
 * Tx-related functions source file
 *****************************************************************************/

#include "cdn_stdint.h"
#include "cdn_errno.h"
#include "log.h"
#include "cps.h"
#include "emac_regs.h"
#include "cedi.h"
#include "edd_int.h"

/******************************************************************************
 * Register addresses tables
 *****************************************************************************/
volatile uint32_t* const transmitPtrReg[15] = {
    CEDI_RegOff(transmit_q1_ptr),
    CEDI_RegOff(transmit_q2_ptr),
    CEDI_RegOff(transmit_q3_ptr),
    CEDI_RegOff(transmit_q4_ptr),
    CEDI_RegOff(transmit_q5_ptr),
    CEDI_RegOff(transmit_q6_ptr),
    CEDI_RegOff(transmit_q7_ptr),
    CEDI_RegOff(transmit_q8_ptr),
    CEDI_RegOff(transmit_q9_ptr),
    CEDI_RegOff(transmit_q10_ptr),
    CEDI_RegOff(transmit_q11_ptr),
    CEDI_RegOff(transmit_q12_ptr),
    CEDI_RegOff(transmit_q13_ptr),
    CEDI_RegOff(transmit_q14_ptr),
    CEDI_RegOff(transmit_q15_ptr)
};
static volatile uint32_t* const enstStartTimeReg[8] = {
    CEDI_RegOff(enst_start_time_q8),
    CEDI_RegOff(enst_start_time_q9),
    CEDI_RegOff(enst_start_time_q10),
    CEDI_RegOff(enst_start_time_q11),
    CEDI_RegOff(enst_start_time_q12),
    CEDI_RegOff(enst_start_time_q13),
    CEDI_RegOff(enst_start_time_q14),
    CEDI_RegOff(enst_start_time_q15)
};

static volatile uint32_t* const enstOnTimeReg[8] = {
    CEDI_RegOff(enst_on_time_q8),
    CEDI_RegOff(enst_on_time_q9),
    CEDI_RegOff(enst_on_time_q10),
    CEDI_RegOff(enst_on_time_q11),
    CEDI_RegOff(enst_on_time_q12),
    CEDI_RegOff(enst_on_time_q13),
    CEDI_RegOff(enst_on_time_q14),
    CEDI_RegOff(enst_on_time_q15)
};

static volatile uint32_t* const enstOffTimeReg[8] = {
    CEDI_RegOff(enst_off_time_q8),
    CEDI_RegOff(enst_off_time_q9),
    CEDI_RegOff(enst_off_time_q10),
    CEDI_RegOff(enst_off_time_q11),
    CEDI_RegOff(enst_off_time_q12),
    CEDI_RegOff(enst_off_time_q13),
    CEDI_RegOff(enst_off_time_q14),
    CEDI_RegOff(enst_off_time_q15)
};


/******************************************************************************
 * Private Driver functions
 *****************************************************************************/

/* Adds value of offset (which may be positive or negative) to Tx descriptor
 * pointer, in-place. Offset should have relatively small absolute value.
 * This function intentionally violates MISRA C rules, to allow pointer
 * casts and manipulations required for driver operation. */
static void moveTxDescAddr(txDesc **ptr, int32_t offset)
{
    *ptr = (txDesc *)(((uintptr_t)*ptr) + offset);
}


/* move descriptor pointer bd and virtual address pointer vp on to next in ring.
 * stat should be the status (word 1) of current descriptor */
static void inc_txbd(const CEDI_PrivateData *pD, uint32_t stat, txDesc **bd, uintptr_t **vp,
                        const txQueue_t *txQ) {
    if (0 != (stat & CEDI_TXD_WRAP)) {
        *bd = txQ->bdBase;
        *vp = txQ->vAddrList;
    } else {
        moveTxDescAddr(bd, pD->txDescriptorSize);
        ++(*vp);
    }
}

/* move descriptor and virtual address pointers back to previous in ring */
static void dec_txbd(const CEDI_PrivateData *pD, txDesc **bd, uintptr_t **vp, const txQueue_t *txQ) {
    if (*bd==txQ->bdBase) {
        moveTxDescAddr(bd, (txQ->descMax-1)*(pD->txDescriptorSize));
        *vp += (txQ->descMax-1);
    } else {
        moveTxDescAddr(bd, -(pD->txDescriptorSize));
        --(*vp);
    }
}

static void enableTxQs(CEDI_PrivateData *pD, uint8_t numQueues)
{
    uint32_t regTmp;
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    for (i = numQueues-1; i > 0; i--) {
        regPtr = transmitPtrReg[i-1];
        addRegBase(pD, &regPtr);
        regTmp = CPS_UncachedRead32(regPtr);
        EMAC_REGS__TRANSMIT_Q_PTR__DMA_TX_DIS_Q__MODIFY(regTmp, 0);
        CPS_UncachedWrite32(regPtr, regTmp);
    }
}

static void disableTxQs(CEDI_PrivateData *pD, uint8_t numQueues)
{
    uint32_t regTmp;
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    if (numQueues > 0) {
        for (i = numQueues; i < pD->cfg.txQs; i++)
        {
            regPtr = transmitPtrReg[i-1];
            addRegBase(pD, &regPtr);
            regTmp = CPS_UncachedRead32(regPtr);
            EMAC_REGS__TRANSMIT_Q_PTR__DMA_TX_DIS_Q__MODIFY(regTmp, 1);
            CPS_UncachedWrite32(regPtr, regTmp);
        }
    }
}

static void txDescFree(const CEDI_PrivateData *pD, uint8_t queueNum, uint16_t *numFree)
{
    *numFree = pD->txQueue[queueNum].descFree;
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
uint32_t emacCalcMaxTxFrameSize(CEDI_PrivateData *pD, CEDI_FrameSize *maxTxSize)
{
    uint32_t status = 0;
    uint32_t i, watermark;
    uint16_t ram_word_size, ram_addr_bits, burst_len;
    uint16_t ram_size, num_segments, size_per_segment, tx_overhead;
    uint32_t num_segments_q[CEDI_MAX_TX_QUEUES];
    uint32_t frameSizeShift;
    uint8_t enabled = 0;


    if ((pD==NULL) || (maxTxSize==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        status = emacGetTxPartialStFwd(pD, &watermark, &enabled);
    }

    if (0 == status) {
        if ((!enabled) && pD->hwCfg.tx_pkt_buffer)
        {
            // What is word size of SRAM in bytes
            ram_word_size = (pD->hwCfg.tx_pbuf_data >> 1)+1;
            ram_addr_bits = pD->hwCfg.tx_pbuf_addr;

            ram_size = ram_addr_bits + ram_word_size + 1;
            vDbgMsg(DBG_GEN_MSG, 10, "RAM size = %u\n", 1<<ram_size);

            // how many segments are there ?
            num_segments = pD->hwCfg.tx_pbuf_queue_segment_size;
            /* this is number of address lines used for segment selection,
             * e.g. if =3, there are 2^3 = 8 segments */
            vDbgMsg(DBG_GEN_MSG, 10, "Num segments = %u\n", 1<<num_segments);

            size_per_segment  = (ram_size - num_segments);
                                                      /* again, as a power of 2 */
            vDbgMsg(DBG_GEN_MSG, 10, "RAM Size per segment = %u\n",
                    1<<size_per_segment);

            num_segments_q[0] = pD->hwCfg.tx_pbuf_num_segments_q0;
            num_segments_q[1] = pD->hwCfg.tx_pbuf_num_segments_q1;
            num_segments_q[2] = pD->hwCfg.tx_pbuf_num_segments_q2;
            num_segments_q[3] = pD->hwCfg.tx_pbuf_num_segments_q3;
            num_segments_q[4] = pD->hwCfg.tx_pbuf_num_segments_q4;
            num_segments_q[5] = pD->hwCfg.tx_pbuf_num_segments_q5;
            num_segments_q[6] = pD->hwCfg.tx_pbuf_num_segments_q6;
            num_segments_q[7] = pD->hwCfg.tx_pbuf_num_segments_q7;
            num_segments_q[8] = pD->hwCfg.tx_pbuf_num_segments_q8;
            num_segments_q[9] = pD->hwCfg.tx_pbuf_num_segments_q9;
            num_segments_q[10] = pD->hwCfg.tx_pbuf_num_segments_q10;
            num_segments_q[11] = pD->hwCfg.tx_pbuf_num_segments_q11;
            num_segments_q[12] = pD->hwCfg.tx_pbuf_num_segments_q12;
            num_segments_q[13] = pD->hwCfg.tx_pbuf_num_segments_q13;
            num_segments_q[14] = pD->hwCfg.tx_pbuf_num_segments_q14;
            num_segments_q[15] = pD->hwCfg.tx_pbuf_num_segments_q15;

            if (pD->hwCfg.moduleRev >= 0x0109){
		uint32_t status_;
                CEDI_SegmentsPerQueue cpq[CEDI_MAX_TX_QUEUES] = {0};
                status_ = DoGetSegAlloc(pD, cpq, pD->txQs);
		if (0 == status_){
		    for(i = 0; i < pD->txQs; i++){
			num_segments_q[i] = (uint32_t)cpq[i];
		    }
		    /* if feature is not supported it is not an error */
		} else  if (ENOTSUP != status_) {
		    status = status_;
		}
	    }

            if (0 == status)
            {
                vDbgMsg(DBG_GEN_MSG, 10,
                        "number segments  Q0 = %u, Q1 = %u, Q2 = %u, Q3 = %u, \n",
                        num_segments_q[0], num_segments_q[1], num_segments_q[2],
                        num_segments_q[3]);
                vDbgMsg(DBG_GEN_MSG, 10,
                        "number segments  Q4 = %u, Q5 = %u, Q6 = %u, Q7 = %u, \n",
                        num_segments_q[4], num_segments_q[5], num_segments_q[6],
                        num_segments_q[7]);

                burst_len = EMAC_REGS__DMA_CONFIG__AMBA_BURST_LENGTH__READ(
                                CPS_UncachedRead32(&(pD->regs->dma_config)));
                switch (burst_len) {
                    case CEDI_AMBD_BURST_LEN_8:
                        tx_overhead = ((pD->hwCfg.tx_pbuf_data << 5)/8)*26;
                        break;
                    case CEDI_AMBD_BURST_LEN_16:
                        tx_overhead = ((pD->hwCfg.tx_pbuf_data << 5)/8)*46;
                        break;
                    case CEDI_AMBD_BURST_LEN_1:
                    case CEDI_AMBD_BURST_LEN_4:
                    default:
                        tx_overhead = ((pD->hwCfg.tx_pbuf_data << 5)/8)*16;
                        break;
                }

                for (i=0; i<CEDI_MAX_TX_QUEUES; i++) {
                    if (i<pD->txQs) {
                        frameSizeShift = num_segments_q[i] + (uint32_t)size_per_segment;
                        if (frameSizeShift < 32) {
                            maxTxSize->FrameSize[i] = (1 << frameSizeShift) - tx_overhead;
                        } else {
                            status = EINVAL;
                        }
                        /* add in some extra overhead */
                        if (0 == status) {
                            maxTxSize->FrameSize[i] = (maxTxSize->FrameSize[i]*9)/10;
                        }
                    } else {
                        maxTxSize->FrameSize[i] = 0;
                    }
                }
            }
        }
        else
        {
            for (i=0; i<CEDI_MAX_TX_QUEUES; i++) {
                if (i<pD->txQs) {
                    maxTxSize->FrameSize[i] = CEDI_TXD_LMASK;
                } else {
                    maxTxSize->FrameSize[i] = 0;
                }
            }
        }
    }

    if (0 == status) {
        vDbgMsg(DBG_GEN_MSG, 10,
                "max_frm_size_Q0 = %u, Q1 = %u, Q2 = %u, Q3 = %u,\n",
                maxTxSize->FrameSize[0], maxTxSize->FrameSize[1],
                maxTxSize->FrameSize[2], maxTxSize->FrameSize[3]);
        vDbgMsg(DBG_GEN_MSG, 10,
                "max_frm_size_Q4 = %u, Q5 = %u, Q6 = %u, Q7 = %u,\n",
                maxTxSize->FrameSize[4], maxTxSize->FrameSize[5],
                maxTxSize->FrameSize[6], maxTxSize->FrameSize[7]);
    }
    return (status);
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
uint32_t emacQueueTxBuf(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_BuffAddr *bufAdd,
        uint32_t length, uint8_t flags)
{
    uint32_t status = 0;
    txQueue_t *txQ;
    txDesc *freeDesc;
    txDesc *bd1stBuf;
    uint32_t stat, ncr;
    uint16_t nFree;

    if ((pD==NULL) || (queueNum>=pD->txQs) || (bufAdd==NULL)
            || (bufAdd->pAddr==0)) {
        status = EINVAL;
    }

    if (0 == status) {
        txQ = &(pD->txQueue[queueNum]);
        freeDesc = txQ->bdHead;
        bd1stBuf = txQ->bd1stBuf;

        if ((!length) || (length > CEDI_TXD_LMASK)) {
            vDbgMsg(DBG_GEN_MSG, 5, "Error: bad length specified: %u\n", length);
            status = EINVAL;
        }
    }

    if (0 == status) {
        txDescFree(pD, queueNum, &nFree);
        if (0 == nFree) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: insufficient buffer descriptors");
            status = ENOENT;
        }
    }

    if (0 == status) {
        /* preserve wrap bit if present in status word */
        stat = CPS_UncachedRead32(&freeDesc->word[1]) & CEDI_TXD_WRAP;
        stat |= ((0 != (flags & CEDI_TXB_LAST_BUFF))?CEDI_TXD_LAST_BUF:0)
                | ((0 != (flags & CEDI_TXB_NO_AUTO_CRC))?CEDI_TXD_NO_AUTO_CRC:0)
                | length;

        /* Handle a multi-buffer frame */
        if ((!(flags & CEDI_TXB_LAST_BUFF)) && (NULL == bd1stBuf)) {
            /* This is the 1st buf of several; prevent it from going and remember its BD. */
            stat |= CEDI_TXD_USED;
            txQ->bd1stBuf = freeDesc;
        }

        *txQ->vHead = bufAdd->vAddr;
        CPS_UncachedWrite32(&freeDesc->word[0], bufAdd->pAddr & 0xFFFFFFFFU);
        /* upper 32 bits if 64 bit addressing */
        if (0 != pD->cfg.dmaAddrBusWidth) {
#ifdef CEDI_64B_COMPILE
            /* 64-bit addressing */
            CPS_UncachedWrite32(&freeDesc->word[2],
                                 (bufAdd->pAddr & 0xFFFFFFFF00000000)>>32);
#else
            /* 32-bit addressing */
            /* include only for test use */
                /* copy in faked upper 32 bits for testing in 32-bit env. */
            CPS_UncachedWrite32(&freeDesc->word[2],
                                 pD->cfg.upper32BuffTxQAddr);
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
        txDescFree(pD, queueNum, &nFree);
        vDbgMsg(DBG_GEN_MSG, 15, "len=%u, queue=%u, txbdHead=%p, buffV=%p, buffP=%p, descFree=%u\n",
                length, queueNum, freeDesc, (void *)bufAdd->vAddr, (void *)bufAdd->pAddr, nFree);
        inc_txbd(pD, stat, &freeDesc, &txQ->vHead, txQ);
        txQ->bdHead = freeDesc;

        /* set going if complete frame queued */
        if ((flags & CEDI_TXB_LAST_BUFF) && (!(flags & CEDI_TXB_NO_AUTO_START))) {
            ncr = CPS_UncachedRead32(&(pD->regs->network_control));
            EMAC_REGS__NETWORK_CONTROL__TRANSMIT_START__SET(ncr);
            CPS_UncachedWrite32(&(pD->regs->network_control), ncr);
        }
    }
    return (status);
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
uint32_t emacQTxBuf(CEDI_PrivateData *pD, CEDI_qTxBufParams *prm)
{
    uint32_t status = 0;
    txQueue_t *txQ;
    txDesc *freeDesc;
    txDesc *bd1stBuf;
    uint32_t stat, ncr;
    uint32_t mssMfsStats;
    uint32_t tcpStreamShifted;
    uint16_t nFree;

    if ((pD==NULL) || (prm==NULL)
            || (prm->queueNum>=pD->txQs)
            || (prm->bufAdd==NULL)
            || (prm->bufAdd->pAddr==0)) {
        status = EINVAL;
    }

    if (0 == status) {
        txQ = &(pD->txQueue[prm->queueNum]);
        freeDesc = txQ->bdHead;
        bd1stBuf = txQ->bd1stBuf;

        if ((!prm->length) || (prm->length > CEDI_TXD_LMASK)) {
            vDbgMsg(DBG_GEN_MSG, 5, "Error: bad length specified: %u\n",
                    prm->length);
            status = EINVAL;
        }
    }

    if (0 == status) {
        txDescFree(pD, prm->queueNum, &nFree);
        if (0 == nFree) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: insufficient buffer descriptors");
            status = ENOENT;
        }
    }

    if (0 == status) {
	if (prm->flags & CEDI_TXB_ENABLE_TLT){
	    if (0 == IsGem1p11(pD)){
		status = ENOTSUP;
		vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: Time base scheduling is not supported in your version of GEM");
	    }
	    else if (0 == pD->cfg.enTxExtBD){
		status = ENOTSUP;
		vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: TX extended BD mode is not enabled");
	    }
	}
    }

    if (0 == status) {
        if (NULL!=bd1stBuf) {     /* inc counter after 1st in frame */
            txQ->descNum++;
        }

        mssMfsStats = ((uint32_t)(prm->mssMfs) << CEDI_TXD_MSSMFS_SHIFT) & (uint32_t)CEDI_TXD_MSSMFS_MASK;

        /* preserve wrap bit if present in status word */
        stat = CPS_UncachedRead32(&freeDesc->word[1]) & CEDI_TXD_WRAP;
        stat |= ((0 != (prm->flags & CEDI_TXB_LAST_BUFF))?CEDI_TXD_LAST_BUF:0)
                | ((0 != (prm->flags & CEDI_TXB_NO_AUTO_CRC))?CEDI_TXD_NO_AUTO_CRC:0)
                | prm->length
                | ((txQ->descNum>=1) ? mssMfsStats : 0);
                                    // only set MSS/MFS on second or later descriptor

        /* Handle a multi-buffer frame */
        tcpStreamShifted = ((uint32_t)(prm->tcpStream)<<CEDI_TXD_STREAM_SHIFT);
        if ((!(prm->flags & CEDI_TXB_LAST_BUFF)) && (NULL==bd1stBuf)) {
            /* This is the 1st buf of several; prevent it from going and remember its BD. */
            stat |= CEDI_TXD_USED
             /* Also use this condition to set encapsulation flags & TCP stream -
              * must not set stream if TSO bit clear */
                    | ((0 != (prm->flags & CEDI_TXB_TCP_ENCAP))?
                            /* TSO settings */
                        (CEDI_TXD_TSO_ENABLE|
                          (tcpStreamShifted & CEDI_TXD_STREAM_MASK)|
                          ((0 != (prm->flags & CEDI_TXB_TSO_AUTO_SEQ))?CEDI_TXD_AUTOSEQ_SEL:0)) :
                            /* UFO bit only */
                      ((0 != (prm->flags & CEDI_TXB_UDP_ENCAP))?CEDI_TXD_UFO_ENABLE:0));
            txQ->bd1stBuf = freeDesc;
        }

        *txQ->vHead = prm->bufAdd->vAddr;
        CPS_UncachedWrite32(&freeDesc->word[0], prm->bufAdd->pAddr & 0xFFFFFFFFU);

        /* upper 32 bits if 64 bit addressing */
        if (0 != pD->cfg.dmaAddrBusWidth) {
#ifdef CEDI_64B_COMPILE
            /* 64-bit addressing */
            CPS_UncachedWrite32(&freeDesc->word[2],
                                 (prm->bufAdd->pAddr & 0xFFFFFFFF00000000)>>32);
#else
            /* include only for test use */
                /* copy in faked upper 32 bits for testing in 32-bit env. */
            CPS_UncachedWrite32(&freeDesc->word[2],
                                 pD->cfg.upper32BuffTxQAddr);
#endif
        }
        CPS_UncachedWrite32(&freeDesc->word[1], stat);

	if (prm->flags & CEDI_TXB_ENABLE_TLT){
	    uint8_t wdNum;
	    uint32_t tlt = prm->launchTime.nanoSecs & CEDI_TLT_NANO_SEC_MASK;
	    tlt |= (prm->launchTime.secs >> CEDI_TLT_SECS_SHIFT);

	    // position depends on 32/64 bit addr
	    wdNum = (0 != (pD->cfg.dmaAddrBusWidth))?4:2;
	    CPS_UncachedWrite32(&(freeDesc->word[wdNum]), tlt);
	    CPS_UncachedWrite32(&(freeDesc->word[wdNum+1]), CEDI_TLT_UTLT);
	}

	if ((prm->flags & CEDI_TXB_LAST_BUFF) && (NULL!=bd1stBuf)) {
	    /* Last buffer of a multibuffer frame is in place, 1st buffer can go. */
	    CPS_UncachedWrite32(&bd1stBuf->word[1],
				CPS_UncachedRead32(&bd1stBuf->word[1]) & ~CEDI_TXD_USED);
	    txQ->bd1stBuf = NULL;
	    txQ->descNum = 0;
	}

	--txQ->descFree;
        inc_txbd(pD, stat, &freeDesc, &txQ->vHead, txQ);
        txQ->bdHead = freeDesc;

        /* set going if complete frame queued */
        if ((prm->flags & CEDI_TXB_LAST_BUFF) && (!(prm->flags & CEDI_TXB_NO_AUTO_START))) {
              ncr = CPS_UncachedRead32(&(pD->regs->network_control));
            EMAC_REGS__NETWORK_CONTROL__TRANSMIT_START__SET(ncr);
              CPS_UncachedWrite32(&(pD->regs->network_control), ncr);
        }
    }
    return (status);
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
uint32_t emacDeQTxBuf(CEDI_PrivateData *pD, CEDI_qTxBufParams *prm)
{
    uint32_t status = 0;
    txQueue_t *txQ;
    txDesc *descToFree;
    uint32_t stat;

    if ((pD==NULL) || (prm==NULL) || (prm->bufAdd==NULL) ||
            (prm->queueNum>=pD->txQs)) {
        status = EINVAL;
    }

    if (0 == status) {
        txQ = &(pD->txQueue[prm->queueNum]);
        descToFree = txQ->bdHead;

    /* Check if any in queue */
        if (txQ->bdTail==txQ->bdHead) {
            status = ENOENT;
        }
    }

    if (0 == status) {
        /* unwind head pointers */
        dec_txbd(pD, &descToFree, &txQ->vHead, txQ);
        txQ->bdHead = descToFree;

        /* get virtual address */
        prm->bufAdd->vAddr = *txQ->vHead;

        /* get phys address */
        prm->bufAdd->pAddr = CPS_UncachedRead32(&descToFree->word[0]);
#ifdef CEDI_64B_COMPILE
        /* upper 32 bits if 64 bit addressing */
        if (0 != pD->cfg.dmaAddrBusWidth) {
            prm->bufAdd->pAddr |= (CPS_UncachedRead32(&descToFree->word[2])<<32);
        }
#endif

        /* get length */
        stat = CPS_UncachedRead32(&descToFree->word[1]);
        prm->length = stat & CEDI_TXD_LEN_MASK;
        /* set used bit */
        CPS_UncachedWrite32(&descToFree->word[1], stat | CEDI_TXD_USED);

        if (txQ->descNum>0) {
            txQ->descNum--;
        }

        ++txQ->descFree;
    }

    return (status);
}

/* Get number of free descriptors in specified Tx queue
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of Tx queue
 * @param numFree - pointer for returning number of free descriptors
 * @return 0 if successful
 * @return EINVAL if invalid parameter
 */
uint32_t emacTxDescFree(const CEDI_PrivateData *pD, uint8_t queueNum, uint16_t *numFree)
{
    uint32_t status = 0;
    if ((pD==NULL) || (numFree==NULL) || (queueNum>=pD->txQs)) {
        status = EINVAL;
    } else {
        txDescFree(pD, queueNum, numFree);
    }
    return (status);
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
uint32_t emacFreeTxDesc(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_TxDescData *descData)
{
    uint32_t status = 0;
    txQueue_t *txQ;
    txDesc *freedDesc;
    uint8_t wdNum;
    uint32_t tsLowerWd, tsUpperWd;

    if ((pD==NULL) || (descData==NULL)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (queueNum>=pD->txQs) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        txQ = &(pD->txQueue[queueNum]);
        /* Check if any to free */
        if (txQ->bdTail == txQ->bdHead)
        {
            descData->status = CEDI_TXDATA_NONE_FREED;
            status = ENOENT;
        }
    }

    if (0 == status) {
        /* check, if there is no incomplete multi-buffer frame still to be completed */
        if (txQ->bd1stBuf == txQ->bdTail) {
            descData->status = CEDI_TXDATA_NONE_FREED;
            status = EAGAIN;
        }
    }

    if (0 == status) {
        /* Free next used descriptor in this frame */
        descData->txDescStat = CPS_UncachedRead32(&(txQ->bdTail->word[1]));
        if (0 != txQ->firstToFree)
        {
            /* look ahead to next desc */

            /* Only test used bit state for first buffer in frame. */
            if (0 == (descData->txDescStat & CEDI_TXD_USED)) {
                descData->status = CEDI_TXDATA_NONE_FREED;
                status = EAGAIN;
            }

            if (0 == status) {
                /* extract timestamp if available */
                if ((pD->cfg.enTxExtBD) &&
                        (descData->txDescStat & CEDI_TXD_TS_VALID))
                {
                    uint32_t reg;
                        descData->txTsData.tsValid = 1;
                    // position depends on 32/64 bit addr
                        wdNum = (0 != (pD->cfg.dmaAddrBusWidth))?4:2;
                        tsLowerWd = CPS_UncachedRead32(&(txQ->bdTail->word[wdNum]));
                        tsUpperWd = CPS_UncachedRead32(&(txQ->bdTail->word[wdNum+1]));

                        descData->txTsData.tsNanoSec = tsLowerWd & CEDI_TS_NANO_SEC_MASK;
                        descData->txTsData.tsSecs = ((tsUpperWd & CEDI_TS_SEC1_MASK)
                                                        <<CEDI_TS_SEC1_POS_SHIFT)
                                                       | (tsLowerWd >> CEDI_TS_SEC0_SHIFT);

                            /* The timestamp only contains lower few bits of seconds, so add value from 1588 timer */
                    reg =  CPS_UncachedRead32(&(pD->regs->tsu_timer_sec));
                    /* If the top bit is set in the timestamp, but not in 1588 timer, it has rolled over, so subtract max size */
                    if ((descData->txTsData.tsSecs & (CEDI_TS_SEC_TOP>>1)) && (!(reg & (CEDI_TS_SEC_TOP>>1)))) {
                        descData->txTsData.tsSecs -= CEDI_TS_SEC_TOP;
                    }
                    descData->txTsData.tsSecs += ((uint32_t)(~CEDI_TS_SEC_MASK) & EMAC_REGS__TSU_TIMER_SEC__TIMER__READ(reg));
                        }
                else {
                    descData->txTsData.tsValid = 0;
                }

                if (0 != (descData->txDescStat & CEDI_TXD_LAST_BUF)) {
                    descData->status = CEDI_TXDATA_1ST_AND_LAST;
                } else {
                    txQ->firstToFree = 0;
                    descData->status = CEDI_TXDATA_1ST_NOT_LAST;
                }
            }
        }
        else
        {
            /* set later used bits in frame, for consistency */
            CPS_UncachedWrite32(&(txQ->bdTail->word[1]),
                                    descData->txDescStat | CEDI_TXD_USED);
            if (0 != (descData->txDescStat & CEDI_TXD_LAST_BUF)) {
                descData->status = CEDI_TXDATA_LAST_BUFFER;
                txQ->firstToFree = 1;
            } else {
                descData->status = CEDI_TXDATA_MID_BUFFER;
            }
        }
    }

    if (0 == status) {
        descData->bufAdd.pAddr = CPS_UncachedRead32(&(txQ->bdTail->word[0]));
        /* upper 32 bits if 64 bit addressing */
        if ((pD->cfg.dmaAddrBusWidth) &&
                    (sizeof(descData->bufAdd.pAddr)==sizeof(uint64_t))) {
            descData->bufAdd.pAddr |=
                    ((uint64_t)CPS_UncachedRead32(&(txQ->bdTail->word[2])))<<32;
        }

        descData->bufAdd.vAddr = *txQ->vTail;
        freedDesc = txQ->bdTail;

        /* move queue pointers on */
        inc_txbd(pD, descData->txDescStat, &txQ->bdTail, &txQ->vTail, txQ);
        ++txQ->descFree;

        /* paranoid - empty and no last buffer flag (on last freed)? */
        if ((0==((descData->txDescStat) & CEDI_TXD_LAST_BUF)) &&
                ((txQ->descFree)==((txQ->descMax)-CEDI_MIN_TXBD))) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "Error: txQueue %u: LAST bit of frame not found!\n", queueNum);
            txQ->firstToFree = 1;
            status = EIO;
        }
    }

    if (EAGAIN == status) {
        status = 0;
    }
    return (status);
}

/* Decode the Tx descriptor status into a bit-field struct
 * @param pD - driver private state info specific to this instance
 * @param txDStatWord - Tx descriptor status word
 * @param txDStat - pointer to bit-field struct for decoded status fields
 */
void emacGetTxDescStat(const CEDI_PrivateData *pD, uint32_t txDStatWord, CEDI_TxDescStat *txDStat)
{
    uint32_t wd1;

    if ((NULL!=pD) && (NULL!=txDStat)) {

        wd1 = txDStatWord;
        txDStat->chkOffErr = (wd1 & CEDI_TXD_CHKOFF_MASK) >> CEDI_TXD_CHKOFF_SHIFT;
        txDStat->lateColl = (0 != (wd1 & CEDI_TXD_LATE_COLL))?1:0;
        txDStat->frameCorr = (0 != (wd1 & CEDI_TXD_FR_CORR))?1:0;
        txDStat->txUnderrun = (0 != (wd1 & CEDI_TXD_UNDERRUN))?1:0;
        txDStat->retryExc = (0 != (wd1 & CEDI_TXD_RETRY_EXC))?1:0;
    }
}

/* Provide the size of descriptor calculated for the current configuration.
 * @param pD - driver private state info specific to this instance
 * @param txDescSize - pointer to Tx descriptor Size
 */
void emacGetTxDescSize(const CEDI_PrivateData *pD, uint32_t *txDescSize)
{
    if ((pD!=NULL) && (txDescSize!=NULL)) {
        *txDescSize = pD->txDescriptorSize;
    }
}

/* Reset transmit buffer queue. Any untransmitted buffer data will be
 * discarded and must be re-queued.  Transmission must be disabled
 * before calling this function.
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of Tx queue
 * @return 0 if successful
 * @return EINVAL if invalid parameter
 */
uint32_t emacResetTxQ(CEDI_PrivateData *pD, uint8_t queueNum)
{
    uint32_t status = 0;
    uint32_t regTmp;
    txQueue_t *txQ;
    txDesc *descStartPerQ;
    uint32_t pAddr;
    uintptr_t vAddr;
    uint16_t q, i;
    uint32_t sumTxDescSize;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (queueNum>=pD->txQs)) {
        status = EINVAL;
    }

    if (0 == status) {
        txQ = &(pD->txQueue[queueNum]);
        txQ->descFree = pD->cfg.txQLen[queueNum];
        txQ->descMax = txQ->descFree + CEDI_MIN_TXBD;
        vAddr = pD->cfg.txQAddr;
        pAddr = pD->cfg.txQPhyAddr;
        q = 0;
        sumTxDescSize = (uint32_t)(txQ->descMax) * (uint32_t)(pD->txDescriptorSize);
        /* find start addresses for this txQ */
        if (queueNum>0) {
            txQ->vAddrList = pD->txQueue[0].vAddrList;
        }
        while (q<queueNum) {
            vAddr += (uintptr_t)sumTxDescSize;
            pAddr += sumTxDescSize;
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
                    CEDI_TXD_USED | ((i==((txQ->descMax)-1))?CEDI_TXD_WRAP:0));
            moveTxDescAddr(&descStartPerQ, (pD->txDescriptorSize));
        }

        if (q == 0) {
            regTmp = CPS_UncachedRead32(&(pD->regs->transmit_q_ptr));
            EMAC_REGS__TRANSMIT_Q_PTR__DMA_TX_Q_PTR__MODIFY(regTmp, pAddr>>2);
            CPS_UncachedWrite32(&(pD->regs->transmit_q_ptr), regTmp);
        }
        else {
            regPtr = transmitPtrReg[q-1];
            addRegBase(pD, &regPtr);
            regTmp = CPS_UncachedRead32(regPtr);
            EMAC_REGS__TRANSMIT_Q_PTR__DMA_TX_Q_PTR__MODIFY(regTmp, pAddr>>2);
            CPS_UncachedWrite32(regPtr, regTmp);
        }
    }
    return (status);
}

/* Enable & start the transmit circuit. Not required during normal
 * operation, as queueTxBuf will automatically start Tx when complete frame
 * has been queued, but may be used to restart after a Tx error.
 * @param pD - driver private state info specific to this instance
 * @return 0 if successful
 * @return ECANCELED if no entries in buffer
 * @return EINVAL if invalid parameter
 */
uint32_t emacStartTx(CEDI_PrivateData *pD)
{
    uint32_t status = 0;
    uint32_t qNum;
    uint8_t ok = 0;
    txQueue_t *txQ;
    uint32_t ncr;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered\n", __func__);

        if (0 == emacGetTxEnabled(pD)) {
            emacEnableTx(pD);
        }

        /* if anything to transmit, start transmission */
        for (qNum = 0; qNum < pD->txQs; ++qNum) {
            txQ = &(pD->txQueue[qNum]);
            if (txQ->bdHead != txQ->bdTail) {
                ok = 1;
                break;
            }
        }
        if (0 == ok) {
            status = ECANCELED;
        } else {
            ncr = CPS_UncachedRead32(&(pD->regs->network_control));
            EMAC_REGS__NETWORK_CONTROL__TRANSMIT_START__SET(ncr);
            CPS_UncachedWrite32(&(pD->regs->network_control), ncr);
        }
    }
    return (status);
}

/* Halt transmission as soon as current frame Tx has finished
 * @param pD - driver private state info specific to this instance
 */
void emacStopTx(CEDI_PrivateData *pD)
{
    uint32_t ncr;

    if (pD!=NULL) {
        ncr = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__TRANSMIT_HALT__SET(ncr);
        CPS_UncachedWrite32(&(pD->regs->network_control), ncr);
    }
}

/* Immediately disable transmission without waiting for completion.
 * Since the EMAC will reset to point to the start of transmit descriptor
 * list, the buffer queues may have to be reset after this call.
 * @param pD - driver private state info specific to this instance
 */
void emacAbortTx(CEDI_PrivateData *pD)
{
    uint32_t ncr;

    if (pD!=NULL) {
        ncr = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__ENABLE_TRANSMIT__CLR(ncr);
        CPS_UncachedWrite32(&(pD->regs->network_control), ncr);
    }
}

/* Get state of transmitter
 * @param pD - driver private state info specific to this instance
 * @return 1 if active
 * @return 0 if idle or pD==NULL
 */
uint32_t emacTransmitting(CEDI_PrivateData *pD)
{
    uint32_t retVal;
    if (pD==NULL) {
        retVal = 0;
    } else {
        retVal = EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_GO__READ(
                CPS_UncachedRead32(&(pD->regs->transmit_status)));
    }
    return (retVal);
}

/**
 * Enable the transmit circuit.  This will be done automatically
 * when call startTx, but it may be desirable to call this earlier,
 * since some functionality depends on transmit being enabled.
 * @param[in] pD driver private state info specific to this instance
 */
void emacEnableTx(CEDI_PrivateData *pD)
{
    uint32_t ncr;
    if (pD!=NULL) {
        /* Enable the transmitter */
        ncr = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__ENABLE_TRANSMIT__SET(ncr);
        CPS_UncachedWrite32(&(pD->regs->network_control), ncr);
    }
}

/**
 * Get state of transmision enabled
 * @param pD - driver private state info specific to this instance
 * @return 1 if transmission enabled
 * @return 0 if transmission disabled or pD==NULL
 */
uint32_t emacGetTxEnabled(CEDI_PrivateData *pD)
{
  uint32_t retVal;
    if (pD==NULL) {
        retVal = 0;
    } else {
        retVal = (EMAC_REGS__NETWORK_CONTROL__ENABLE_TRANSMIT__READ(
                CPS_UncachedRead32(&(pD->regs->network_control))));
    }

    return (retVal);
}

/* Get the content of EMAC transmit status register
 * @param pD - driver private state info specific to this instance
 * @param status - pointer to struct with fields for each flag
 * @return raw status register value, !=0 if any flags set
 */
uint32_t emacGetTxStatus(CEDI_PrivateData *pD, CEDI_TxStatus *status)
{
    uint32_t reg;
    if ((pD==NULL)||(status==NULL)) {
        reg = 0;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->transmit_status));

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
    }
    return (reg);
}

/* Reset the bits of EMAC transmit status register as selected in resetStatus
 * @param pD - driver private state info specific to this instance
 * @param resetStatus - OR'd combination of CEDI_TXS_ bit-fields
 */
void emacClearTxStatus(CEDI_PrivateData *pD, uint32_t resetStatus)
{
    uint32_t dst = 0;

    if (pD!=NULL) {
        if (0 != (resetStatus & CEDI_TXS_USED_READ)) {
            EMAC_REGS__TRANSMIT_STATUS__USED_BIT_READ__MODIFY(dst, 1);
        }
        if (0 != (resetStatus & CEDI_TXS_COLLISION)) {
            EMAC_REGS__TRANSMIT_STATUS__COLLISION_OCCURRED__MODIFY(dst, 1);
        }
        if (0 != (resetStatus & CEDI_TXS_RETRY_EXC)) {
            EMAC_REGS__TRANSMIT_STATUS__RETRY_LIMIT_EXCEEDED__MODIFY(dst, 1);
        }
        if (0 != (resetStatus & CEDI_TXS_LATE_COLL)) {
            EMAC_REGS__TRANSMIT_STATUS__LATE_COLLISION_OCCURRED__MODIFY(dst, 1);
        }
        /* txActive not resettable */
        if (0 != (resetStatus & CEDI_TXS_FRAME_ERR)) {
            EMAC_REGS__TRANSMIT_STATUS__AMBA_ERROR__MODIFY(dst, 1);
        }
        if (0 != (resetStatus & CEDI_TXS_TX_COMPLETE)) {
            EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_COMPLETE__MODIFY(dst, 1);
        }
        if (0 != (resetStatus & CEDI_TXS_UNDERRUN)) {
            EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_UNDER_RUN__MODIFY(dst, 1);
        }
        if (0 != (resetStatus & CEDI_TXS_HRESP_ERR)) {
            EMAC_REGS__TRANSMIT_STATUS__RESP_NOT_OK__MODIFY(dst, 1);
        }
        if (0 != dst) {
            CPS_UncachedWrite32(&(pD->regs->transmit_status), dst);
        }
    }
}

uint32_t emacSetTxPartialStFwd(CEDI_PrivateData *pD, uint32_t watermark, uint8_t enable)
{
    uint32_t status = 0;
    uint32_t reg;
    uint32_t txPbufAddrShifted;
    uint8_t txPbufAddr;
    if ((pD==NULL) || (enable>1)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.tx_pkt_buffer==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        txPbufAddr = pD->hwCfg.tx_pbuf_addr;
        if (txPbufAddr < 16) {
            txPbufAddrShifted = 1 << txPbufAddr;
        } else {
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "ERROR: Wrong tx_pbuf_num_segments read from hardware register");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((enable==1) &&
            ((watermark<0x14) || (watermark>=txPbufAddrShifted))) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pbuf_txcutthru));
        if (0 != enable) {
            EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU_THRESHOLD__MODIFY(reg,
                    watermark);
            EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU__SET(reg);
        } else {
            EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU__CLR(reg);
        }

        CPS_UncachedWrite32(&(pD->regs->pbuf_txcutthru), reg);
    }

    return (status);
}

uint32_t emacGetTxPartialStFwd(CEDI_PrivateData *pD, uint32_t *watermark, uint8_t *enable)
{
    uint32_t status = 0;
    uint32_t reg;
    if ((pD==NULL)||(enable==NULL)||(watermark==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (pD->hwCfg.tx_pkt_buffer==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pbuf_txcutthru));
        (*enable) = EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU__READ(reg);
        if (0 != (*enable)) {
            (*watermark) = EMAC_REGS__PBUF_TXCUTTHRU__DMA_TX_CUTTHRU_THRESHOLD__READ(reg);
        }
    }
        return (status);
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
uint32_t emacEnableCbs(CEDI_PrivateData *pD, uint8_t qSel, uint32_t idleSlope)
{
    uint32_t status = 0;
    uint32_t tmp;
    uint8_t enabled;
    uint32_t reg;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if (pD->hwCfg.exclude_cbs==1) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (pD->txQs==1) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        status = emacGetCbsQSetting(pD, qSel, &enabled, &tmp);
    }

    if (0 == status) {
        if (0 != enabled) {
            emacDisableCbs(pD, qSel);
        }

        reg = 0;
        if (0 != qSel) {   /* i.e. queue B */
            EMAC_REGS__CBS_IDLESLOPE_Q_B__IDLESLOPE_B__MODIFY(reg, idleSlope);
            CPS_UncachedWrite32(&(pD->regs->cbs_idleslope_q_b), reg);
        }
        else {
            EMAC_REGS__CBS_IDLESLOPE_Q_A__IDLESLOPE_A__MODIFY(reg, idleSlope);
            CPS_UncachedWrite32(&(pD->regs->cbs_idleslope_q_a), reg);
        }

        reg = CPS_UncachedRead32(&(pD->regs->cbs_control));
        if (0 != qSel)   /* i.e. queue B */ {
            EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_B__MODIFY(reg, 1);
        } else {
            EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_A__MODIFY(reg, 1);
        }
        CPS_UncachedWrite32(&(pD->regs->cbs_control), reg);
    }

    return (status);
}

/* Disable CBS on the specified queue
 * @param pD - driver private state info specific to this instance
 * @param qSel - if = 0, selects highest priority queue (queue A), else
 *    selects next-highest priority queue (queue B)
 */
void emacDisableCbs(CEDI_PrivateData *pD, uint8_t qSel)
{
    uint32_t reg;

    if ((pD != NULL) && (qSel<=1)) {
        if (pD->hwCfg.exclude_cbs == 0) {
            reg = CPS_UncachedRead32(&(pD->regs->cbs_control));
            if (0 != qSel) {  /* i.e. queue B */
                EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_B__MODIFY(reg, 0);
            } else {
                EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_A__MODIFY(reg, 0);
            }
            CPS_UncachedWrite32(&(pD->regs->cbs_control), reg);
        }
    }
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
uint32_t emacGetCbsQSetting(CEDI_PrivateData *pD, uint8_t qSel,
               uint8_t *enable, uint32_t *idleSlope)
{
    uint32_t status = 0;
    uint32_t reg, enabled;

    if ((pD==NULL) || (enable==NULL) || (idleSlope==NULL) || (qSel>1)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (pD->hwCfg.exclude_cbs==1) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        reg = CPS_UncachedRead32(&(pD->regs->cbs_control));
        if (0 != qSel) { /* i.e. queue B */
            enabled = EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_B__READ(reg);
            if (enabled && (idleSlope!=NULL)) {
                reg = CPS_UncachedRead32(&(pD->regs->cbs_idleslope_q_b));
                *idleSlope = EMAC_REGS__CBS_IDLESLOPE_Q_B__IDLESLOPE_B__READ(reg);
            }
        }
        else {
            enabled = EMAC_REGS__CBS_CONTROL__CBS_ENABLE_QUEUE_A__READ(reg);
            if (enabled && (idleSlope!=NULL)) {
                reg = CPS_UncachedRead32(&(pD->regs->cbs_idleslope_q_a));
                *idleSlope = EMAC_REGS__CBS_IDLESLOPE_Q_A__IDLESLOPE_A__READ(reg);
            }
        }
        *enable=enabled;
    }
    return (status);
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
uint32_t emacSetIpgStretch(CEDI_PrivateData *pD, uint8_t enable, uint8_t multiplier,
        uint8_t divisor)
{
    uint32_t status = 0;
    uint32_t reg;

    if ((pD==NULL) || (enable>1)) {
        status = EINVAL;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0 != enable) {
            EMAC_REGS__NETWORK_CONFIG__IPG_STRETCH_ENABLE__SET(reg);
            CPS_UncachedWrite32(&(pD->regs->network_config), reg);
            reg = CPS_UncachedRead32(&(pD->regs->stretch_ratio));
            EMAC_REGS__STRETCH_RATIO__IPG_STRETCH__MODIFY(reg,
                    ((uint32_t)divisor << 8) | multiplier);
            CPS_UncachedWrite32(&(pD->regs->stretch_ratio), reg);
        }
        else {
            EMAC_REGS__NETWORK_CONFIG__IPG_STRETCH_ENABLE__CLR(reg);
            CPS_UncachedWrite32(&(pD->regs->network_config), reg);
        }
    }
    return (status);
}

/* Read the inter-packet gap (IPG) stretch settings.
 * @param pD - driver private state info specific to this instance
 * @param enabled - pointer for returning enabled state: returns 1 if
 *                 IPG stretch enabled, 0 if disabled.
 * @param multiplier  - pointer for returning IPG multiplying factor.
 * @param divisor  - pointer for returning IPG divisor.
 * @return =0 if successful, EINVAL if any parameter =NULL
 */
uint32_t emacGetIpgStretch(CEDI_PrivateData *pD, uint8_t *enabled, uint8_t *multiplier,
        uint8_t *divisor)
{
    uint32_t status = 0;
    uint32_t reg, stretch;

    if ((pD==NULL) || (enabled==NULL) || (multiplier==NULL) || (divisor==NULL)) {
        status = EINVAL;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0 != EMAC_REGS__NETWORK_CONFIG__IPG_STRETCH_ENABLE__READ(reg)) {
            *enabled = 1;
            reg = CPS_UncachedRead32(&(pD->regs->stretch_ratio));
            stretch = EMAC_REGS__STRETCH_RATIO__IPG_STRETCH__READ(reg);
            *multiplier = (stretch & 0xFF);
            *divisor = (stretch >> 8) & 0xFF;
        }
        else {
            *enabled = 0;
            *multiplier = 0;
            *divisor = 0;
        }
    }
    return (status);
}





/* set memory segments per queue */
uint32_t
DoSetSegAlloc(CEDI_PrivateData *pD, const CEDI_SegmentsPerQueue *seqmentsPerQueue, uint8_t numOfQueues)
{
    uint32_t status = 0;
    uint32_t tx_q_seg_alloc_q_lower, tx_q_seg_alloc_q_upper = 0;

    if ((numOfQueues < 1) || (numOfQueues > 16)) {
        status = EINVAL;
    }
    if ((0 == status) && (numOfQueues < 2)) {
        status = ENOTSUP;
    }

    if (0 == status) {
        tx_q_seg_alloc_q_lower = CPS_UncachedRead32(&(pD->regs->tx_q_seg_alloc_q_lower));
        if (numOfQueues > 8)
        {
            tx_q_seg_alloc_q_upper = CPS_UncachedRead32(&(pD->regs->tx_q_seg_alloc_q_upper));
        }

        if (numOfQueues >= 16) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q15__MODIFY(tx_q_seg_alloc_q_upper, seqmentsPerQueue[15]);
        }
        if (numOfQueues >= 15) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q14__MODIFY(tx_q_seg_alloc_q_upper, seqmentsPerQueue[14]);
        }
        if (numOfQueues >= 14) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q13__MODIFY(tx_q_seg_alloc_q_upper, seqmentsPerQueue[13]);
        }
        if (numOfQueues >= 13) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q12__MODIFY(tx_q_seg_alloc_q_upper, seqmentsPerQueue[12]);
        }
        if (numOfQueues >= 12) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q11__MODIFY(tx_q_seg_alloc_q_upper, seqmentsPerQueue[11]);
        }
        if (numOfQueues >= 11) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q10__MODIFY(tx_q_seg_alloc_q_upper, seqmentsPerQueue[10]);
        }
        if (numOfQueues >= 10) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q9__MODIFY(tx_q_seg_alloc_q_upper, seqmentsPerQueue[9]);
        }
        if (numOfQueues >= 9) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q8__MODIFY(tx_q_seg_alloc_q_upper, seqmentsPerQueue[8]);
        }
        if (numOfQueues >= 8) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q7__MODIFY(tx_q_seg_alloc_q_lower, seqmentsPerQueue[7]);
        }
        if (numOfQueues >= 7) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q6__MODIFY(tx_q_seg_alloc_q_lower, seqmentsPerQueue[6]);
        }
        if (numOfQueues >= 6) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q5__MODIFY(tx_q_seg_alloc_q_lower, seqmentsPerQueue[5]);
        }
        if (numOfQueues >= 5) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q4__MODIFY(tx_q_seg_alloc_q_lower, seqmentsPerQueue[4]);
        }
        if (numOfQueues >= 4) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q3__MODIFY(tx_q_seg_alloc_q_lower, seqmentsPerQueue[3]);
        }
        if (numOfQueues >= 3) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q2__MODIFY(tx_q_seg_alloc_q_lower, seqmentsPerQueue[2]);
        }
        if (numOfQueues >= 2) {
            EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q1__MODIFY(tx_q_seg_alloc_q_lower, seqmentsPerQueue[1]);
        }

        EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q0__MODIFY(tx_q_seg_alloc_q_lower, seqmentsPerQueue[0]);

        CPS_UncachedWrite32(&(pD->regs->tx_q_seg_alloc_q_lower), tx_q_seg_alloc_q_lower);
        if (numOfQueues > 8)
        {
            CPS_UncachedWrite32(&(pD->regs->tx_q_seg_alloc_q_upper), tx_q_seg_alloc_q_upper);
        }
    }

    return (status);
}

/* get memory segments per queue */
uint32_t
DoGetSegAlloc(CEDI_PrivateData *pD, CEDI_SegmentsPerQueue *seqmentsPerQueue, uint8_t numOfQueues)
{
    uint32_t status = 0;

    uint32_t tx_q_seg_alloc_q_lower, tx_q_seg_alloc_q_upper = 0;

    if((numOfQueues < 1) || (numOfQueues > 16)) {
        status = EINVAL;
    }
    if ((0 == status) && (numOfQueues < 2)) {
        status = ENOTSUP;
    }

    if (0 == status) {
        tx_q_seg_alloc_q_lower = CPS_UncachedRead32(&(pD->regs->tx_q_seg_alloc_q_lower));
        if (numOfQueues > 8) {
            tx_q_seg_alloc_q_upper = CPS_UncachedRead32(&(pD->regs->tx_q_seg_alloc_q_upper));
        }

        if (numOfQueues >= 16) {
            seqmentsPerQueue[15] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q15__READ(tx_q_seg_alloc_q_upper);
        }
        if (numOfQueues >= 15) {
            seqmentsPerQueue[14] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q14__READ(tx_q_seg_alloc_q_upper);
        }
        if (numOfQueues >= 14) {
            seqmentsPerQueue[13] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q13__READ(tx_q_seg_alloc_q_upper);
        }
        if (numOfQueues >= 13) {
            seqmentsPerQueue[12] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q12__READ(tx_q_seg_alloc_q_upper);
        }
        if (numOfQueues >= 12) {
            seqmentsPerQueue[11] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q11__READ(tx_q_seg_alloc_q_upper);
        }
        if (numOfQueues >= 11) {
            seqmentsPerQueue[10] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q10__READ(tx_q_seg_alloc_q_upper);
        }
        if (numOfQueues >= 10) {
            seqmentsPerQueue[9] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q9__READ(tx_q_seg_alloc_q_upper);
        }
        if (numOfQueues >= 9) {
            seqmentsPerQueue[8] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_UPPER__SEGMENT_ALLOC_Q8__READ(tx_q_seg_alloc_q_upper);
        }
        if (numOfQueues >= 8) {
            seqmentsPerQueue[7] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q7__READ(tx_q_seg_alloc_q_lower);
        }
        if (numOfQueues >= 7) {
            seqmentsPerQueue[6] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q6__READ(tx_q_seg_alloc_q_lower);
        }
        if (numOfQueues >= 6) {
            seqmentsPerQueue[5] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q5__READ(tx_q_seg_alloc_q_lower);
        }
        if (numOfQueues >= 5) {
            seqmentsPerQueue[4] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q4__READ(tx_q_seg_alloc_q_lower);
        }
        if (numOfQueues >= 4) {
            seqmentsPerQueue[3] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q3__READ(tx_q_seg_alloc_q_lower);
        }
        if (numOfQueues >= 3) {
            seqmentsPerQueue[2] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q2__READ(tx_q_seg_alloc_q_lower);
        }
        if (numOfQueues >= 2) {
            seqmentsPerQueue[1] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q1__READ(tx_q_seg_alloc_q_lower);
        }
        seqmentsPerQueue[0] = EMAC_REGS__TX_Q_SEG_ALLOC_Q_LOWER__SEGMENT_ALLOC_Q0__READ(tx_q_seg_alloc_q_lower);
    }

    return (status);
}

/* functions check if sum of segments for each queue does not exceed
 * all segments count. Calculation is made for given queue count.
 * Function also verify if queue size value is proper - does not
 * exceed maximum value */
static uint32_t
CheckSegAlloc(const CEDI_PrivateData *pD, const CEDI_SegmentsPerQueue *seqmentsPerQueue, uint8_t segAllocCount)
{
    uint32_t status = 0;
    uint8_t i;
    uint32_t SegAllocsSummary = 0;
    uint8_t txPbufQSegSizeShift = pD->hwCfg.tx_pbuf_queue_segment_size;
    const uint8_t maxSegsPerQueue = (uint8_t)CEDI_SEGMENTS_PER_QUEUE_128;
    uint8_t currSegsPerQueue;

    for (i = 0; i < segAllocCount; i++){
        currSegsPerQueue = (uint8_t)seqmentsPerQueue[i];
        if (currSegsPerQueue <= maxSegsPerQueue) {
            SegAllocsSummary += (1 << currSegsPerQueue);
        } else {
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Number of queues to configure are different than active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (txPbufQSegSizeShift < 16) {
            if (SegAllocsSummary > (1 << txPbufQSegSizeShift)) {
                vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                        "Error: Number of segments for all active queues: %d, "
                        "is bigger than number of available segments %d\n", SegAllocsSummary,
                         (1 << txPbufQSegSizeShift));
                status = EINVAL;
            }
        } else {
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Wrong tx_pbuf_queue_segment_size read from hardware "\
                    "register.");
            status = EINVAL;
        }
    }

    return (status);
}

 /** configure number of memory segments used by Tx queue */
uint32_t
emacSetSegAlloc(CEDI_PrivateData *pD, const CEDI_QueueSegAlloc *queueSegAlloc)
{
    uint32_t status = 0;
    uint8_t i;
    CEDI_SegmentsPerQueue seqmentsPerQueue[CEDI_MAX_TX_QUEUES] = {0};

    if ((pD == NULL) || (queueSegAlloc == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (queueSegAlloc->segAllocCount > pD->cfg.txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Number of queues to configure are bigger than supported queue number\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        status = CheckSegAlloc(pD, queueSegAlloc->segAlloc, queueSegAlloc->segAllocCount);
    }

    if (0 == status) {
        for (i = 0; i < queueSegAlloc->segAllocCount; i++){
                seqmentsPerQueue[i] = queueSegAlloc->segAlloc[i];
        }
    }

    if (0 == status) {
        status = DoSetSegAlloc(pD, seqmentsPerQueue, pD->cfg.txQs);
    }

    return (status);
}

 /** function gets number of memory segments used by Tx queue */
uint32_t
emacGetAllSegAlloctCount(const CEDI_PrivateData *pD, uint32_t *numberOfSegments)
{
    uint32_t status = 0;
    uint8_t txPbufQSegSizeShift;
    if ((pD == NULL) || (numberOfSegments == NULL)) {
        status = EINVAL;
    } else {
        txPbufQSegSizeShift = pD->hwCfg.tx_pbuf_queue_segment_size;

        if (txPbufQSegSizeShift < 16) {
            *numberOfSegments = (1uL << txPbufQSegSizeShift);
        } else {
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Wrong tx_pbuf_queue_segment_size read from hardware "\
                    "register.");
            status = EINVAL;
        }
    }
    return (status);
}

/* get memory segments per queue */
uint32_t
emacGetSegAlloc(CEDI_PrivateData *pD, CEDI_QueueSegAlloc *queueSegAlloc)
{
    uint32_t status = 0;

    if ((pD == NULL) || (queueSegAlloc == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (queueSegAlloc->segAllocCount > pD->cfg.txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Number of queues to configure are bigger than supported queue number\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        status = DoGetSegAlloc(pD, queueSegAlloc->segAlloc, queueSegAlloc->segAllocCount);
    }

    return (status);
}

/* set number of active TX queues - Sw dis/enabling of TX priority queues */
uint32_t emacSetTxQueueNum(CEDI_PrivateData *pD, uint8_t numQueues)
{
    uint32_t status = 0;
    CEDI_SegmentsPerQueue seqmentsPerQueue[CEDI_MAX_TX_QUEUES];

    if ((pD == NULL) || (numQueues < 1)) {
        status = EINVAL;
    }

    if (0 == status) {
        /* number of queues cannot be bigger than set during driver initialization */
        if (numQueues >  pD->cfg.txQs) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (numQueues == pD->txQs) {
            /* Do nothing */
            status = EAGAIN;
        }
    }

    if (0 == status) {
        if (0 == IsGem1p09(pD)){
            vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                    "Warning: changing queue number is not supported\n");
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        /* Transmission must be disabled before calling this function */
        if (0 != emacGetTxEnabled(pD)) {
            status = EIO;
        }
    }


    if (0 == status) {
        /* get current segment allocation setting */
        status = DoGetSegAlloc(pD, seqmentsPerQueue, numQueues);
    }

    if (0 == status) {
        /* check if new queue settings make using segments above available segments */
        status = CheckSegAlloc(pD, seqmentsPerQueue, numQueues);
    }

    if (0 == status) {
        /* enable all queues with number below numQueues) */
        enableTxQs(pD, numQueues);


        /* disable all queues with number equal to or above numQueues) */
        disableTxQs(pD, numQueues);

        /* set new tx priority queues number */
        pD->txQs = numQueues;
    }

    if (EAGAIN == status) {
        status = 0;
    }

    return (status);
}

/* get number of active TX queues */
uint32_t
emacGetTxQueueNum(const CEDI_PrivateData *pD, uint8_t *numQueues)
{
    uint32_t status = 0;
    if ((pD == NULL) || (numQueues == NULL)) {
        status = EINVAL;
    } else {
        *numQueues = pD->txQs;
    }
    return (status);
}

/* select scheduler for TX queue */
uint32_t
emacSetTxQueueScheduler(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_TxSchedType schedType)
{
    uint32_t status = 0;
    uint32_t regTmp;
    uint8_t txQs;

    if (pD == NULL) {
        status = EINVAL;
    } else {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        txQs = pD->txQs;

        if (queueNum >= txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((uint32_t)schedType > (uint32_t)CEDI_TX_SCHED_TYPE_ETS){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Wrong algorithm type\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((schedType == CEDI_TX_SCHED_TYPE_CBS) && (txQs > 2)
            && (queueNum < (txQs - 2))){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: CBS can be set only to highest priority queue and second highest priority queue \n");
            status = EINVAL;
        }
    }
#ifdef __EMAC_REGS__TX_SCHED_CTRL_MACRO__
    if (0 == status) {
        if (0 == IsGem1p09(pD)) {
                vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "Feature not supported- current moduleId:%0x , expected is above:%0x \n",
                    pD->hwCfg.moduleId , GEM_GXL_MODULE_ID_V1 );
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        regTmp = CPS_UncachedRead32(&(pD->regs->tx_sched_ctrl));
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
            status = EINVAL;
            break;
        }
    }

    if (0 == status) {
        CPS_UncachedWrite32(&(pD->regs->tx_sched_ctrl), regTmp);
    }

#else
    if (0 == status) {
        status = ENOTSUP;
    }
#endif
    return (status);
}


/* get select scheduler for TX queue */
uint32_t
emacGetTxQueueScheduler(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_TxSchedType *schedType)
{
    uint32_t status = 0;
    uint32_t regTmp;

    if ((pD == NULL) || (schedType == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (queueNum >= pD->txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }


#ifdef __EMAC_REGS__TX_SCHED_CTRL_MACRO__
    if (0 == status) {
        regTmp = CPS_UncachedRead32(&(pD->regs->tx_sched_ctrl));
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
            status = EINVAL;
            break;
        }
    }
#else
    if (0 == status) {
        status = ENOTSUP;
    }
#endif

    return (status);
}

/* configure rate limit for ETS or DWRR scheduler */
static uint32_t
emacSetRateLimit(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t limit)
{
    uint32_t status = 0;
    uint32_t regTmp;

    if (pD == NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (queueNum >= pD->txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }
#ifdef __EMAC_REGS__BW_RATE_LIMIT_Q0TO3_MACRO__
    if (0 == status) {
        if (0 == IsGem1p09(pD)) {
                vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "Feature not supported- current moduleId:%0x , expected is above:%0x \n",
                    pD->hwCfg.moduleId , GEM_GXL_MODULE_ID_V1 );
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        switch(queueNum){
        case 0:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q0to3));
        EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q0__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q0to3), regTmp);
            break;
        case 1:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q0to3));
        EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q1__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q0to3), regTmp);
            break;
        case 2:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q0to3));
        EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q2__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q0to3), regTmp);
            break;
        case 3:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q0to3));
        EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q3__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q0to3), regTmp);
            break;
        case 4:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q4to7));
        EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q4__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q4to7), regTmp);
            break;
        case 5:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q4to7));
        EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q5__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q4to7), regTmp);
            break;
        case 6:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q4to7));
        EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q6__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q4to7), regTmp);
            break;
        case 7:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q4to7));
        EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q7__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q4to7), regTmp);
            break;
        case 8:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q8to11));
        EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q8__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q8to11), regTmp);
            break;
        case 9:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q8to11));
        EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q9__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q8to11), regTmp);
            break;
        case 10:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q8to11));
        EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q10__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q8to11), regTmp);
            break;
        case 11:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q8to11));
        EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q11__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q8to11), regTmp);
            break;
        case 12:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q12to15));
        EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q12__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q12to15), regTmp);
            break;
        case 13:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q12to15));
        EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q13__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q12to15), regTmp);
            break;
        case 14:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q12to15));
        EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q14__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q12to15), regTmp);
            break;
        case 15:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q12to15));
        EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q15__MODIFY(regTmp, limit);
            CPS_UncachedWrite32(&(pD->regs->bw_rate_limit_q12to15), regTmp);
            break;
        default:
            status = EINVAL;
            break;
        }
    }

#else
    if (0 == status) {
        status = ENOTSUP;
    }
#endif
    return (status);
}

/* get rate limit for ETS or DWRR scheduler */
static uint32_t
emacGetRateLimit(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t *limit)
{
    uint32_t status = 0;
    uint32_t regTmp;

    if ((pD == NULL) || (limit == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (queueNum >= pD->txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }
#ifdef __EMAC_REGS__BW_RATE_LIMIT_Q0TO3_MACRO__
    if (0 == status) {
        if (0 == IsGem1p09(pD)) {
                vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "Feature not supported- current moduleId:%0x , expected is above:%0x \n",
                    pD->hwCfg.moduleId , GEM_GXL_MODULE_ID_V1 );
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        switch(queueNum){
        case 0:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q0to3));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q0__READ(regTmp);
            break;
        case 1:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q0to3));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q1__READ(regTmp);
            break;
        case 2:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q0to3));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q2__READ(regTmp);
            break;
        case 3:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q0to3));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q0TO3__DWRR_ETS_WEIGHT_Q3__READ(regTmp);
            break;
        case 4:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q4to7));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q4__READ(regTmp);
            break;
        case 5:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q4to7));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q5__READ(regTmp);
            break;
        case 6:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q4to7));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q6__READ(regTmp);
            break;
        case 7:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q4to7));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q4TO7__DWRR_ETS_WEIGHT_Q7__READ(regTmp);
            break;
        case 8:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q8to11));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q8__READ(regTmp);
            break;
        case 9:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q8to11));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q9__READ(regTmp);
            break;
        case 10:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q8to11));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q10__READ(regTmp);
            break;
        case 11:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q8to11));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q8TO11__DWRR_ETS_WEIGHT_Q11__READ(regTmp);
            break;
        case 12:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q12to15));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q12__READ(regTmp);
            break;
        case 13:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q12to15));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q13__READ(regTmp);
            break;
        case 14:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q12to15));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q14__READ(regTmp);
            break;
        case 15:
        regTmp = CPS_UncachedRead32(&(pD->regs->bw_rate_limit_q12to15));
        *limit = EMAC_REGS__BW_RATE_LIMIT_Q12TO15__DWRR_ETS_WEIGHT_Q15__READ(regTmp);
            break;
        default:
            status = EINVAL;
            break;
        }
    }

#else
    if (0 == status) {
        status = ENOTSUP;
    }
#endif
    return (status);

}

/* configure DWRR Weighting of DWRR scheduler */
uint32_t
emacSetDwrrWeighting(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t dwrrWeighting)
{
    uint32_t status = 0;
    CEDI_TxSchedType schedType = CEDI_TX_SCHED_TYPE_FIXED;

    if (pD == NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (queueNum >= pD->txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (0 == (emacGetTxQueueScheduler(pD, queueNum, &schedType))) {
            if (schedType != CEDI_TX_SCHED_TYPE_DWRR) {
                vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                        "Warning: Wrong scheduler type is set. Change it to \"CEDI_TX_SCHED_TYPE_DWRR\" \n");
            }
        }
        else {
            vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                    "Warning: Could not read queue scheduler type\n");
        }
        status = emacSetRateLimit(pD, queueNum, dwrrWeighting);
    }

    return (status);
}

/* configure bandwidth allocation of ETS scheduler */
uint32_t
emacSetEtsBandAlloc(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t etsBandAlloc)
{
    uint32_t status = 0;
    CEDI_TxSchedType schedType = CEDI_TX_SCHED_TYPE_FIXED;

    if (pD == NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (queueNum >= pD->txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (0 == (emacGetTxQueueScheduler(pD, queueNum, &schedType))) {
            if (schedType != CEDI_TX_SCHED_TYPE_ETS){
                vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                        "Warning: Wrong scheduler type is set. Change it to \"CEDI_TX_SCHED_TYPE_ETS\" \n");
            }
        }
        else {
            vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                    "Warning: Could not read queue scheduler type\n");
        }
        status = (emacSetRateLimit(pD, queueNum, etsBandAlloc));
    }

    return (status);
}

/* get DWRR Weighting of DWRR scheduler */
uint32_t
emacGetDwrrWeighting(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t *dwrrWeighting)
{
    uint32_t status = 0;
    CEDI_TxSchedType schedType = CEDI_TX_SCHED_TYPE_FIXED;

    if ((pD == NULL) || (dwrrWeighting==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (queueNum >= pD->txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to get value from is bigger than number of active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (0 == (emacGetTxQueueScheduler(pD, queueNum, &schedType))) {
            if (schedType != CEDI_TX_SCHED_TYPE_DWRR) {
                vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                        "Warning: \"CEDI_TX_SCHED_TYPE_DWRR\" is not current scheduler type. \n");
            }
        }
        else {
            vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                    "Warning: Could not read queue scheduler type\n");
        }
        status = emacGetRateLimit(pD, queueNum, dwrrWeighting);
    }

    return (status);
}

/* get bandwidth allocation of ETS scheduler */
uint32_t
emacGetEtsBandAlloc(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t *etsBandAlloc)
{
    uint32_t status = 0;
    CEDI_TxSchedType schedType = CEDI_TX_SCHED_TYPE_FIXED;

    if ((pD == NULL) || (etsBandAlloc==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (queueNum >= pD->txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to get value from is bigger than number of active queues\n");
           status = EINVAL;
        }
    }

    if (0 == status) {
        if (0 == (emacGetTxQueueScheduler(pD, queueNum, &schedType))) {
            if (schedType != CEDI_TX_SCHED_TYPE_ETS) {
                vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                        "Warning: \"CEDI_TX_SCHED_TYPE_ETS\" is not current scheduler type. \n");
            }
        }
        else {
            vDbgMsg(DBG_GEN_MSG, DBG_WARN, "%s\n",
                    "Warning: Could not read queue scheduler type\n");
        }
        status = (emacGetRateLimit(pD, queueNum, etsBandAlloc));
    }

    return (status);
}

/* configure timing for Enhancement for Scheduled Traffic priority scheduler */
uint32_t
emacSetEnstTimeConfig(CEDI_PrivateData *pD, uint8_t queueNum, const CEDI_EnstTimeConfig *enstTimeConfig)
{
    uint32_t status = 0;
    uint32_t regTmp;
    uint8_t queueIdx, txQs;
    volatile uint32_t *startPtr = NULL;
    volatile uint32_t *onPtr = NULL;
    volatile uint32_t *offPtr = NULL;

    if ((pD == NULL) || (enstTimeConfig == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        txQs = pD->txQs;

        if (queueNum >= txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((txQs > 8) && (queueNum < (txQs - 8))){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                    "Error: Queue number must bigger than %d\n", txQs - 8);
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (enstTimeConfig->startTimeS > 3){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Start time is bigger than maximum supported value: 3\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (enstTimeConfig->startTimeNs >= 0x40000000U){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Start time nano second is bigger than maximum supported value: 0x3FFFFFFF\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (enstTimeConfig->onTime >= 0x20000U){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: On time is bigger than maximum supported value: 0x1FFFF\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (enstTimeConfig->offTime >= 0x20000U){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Off time is bigger than maximum supported value: 0x1FFFF\n");
            status = EINVAL;
        }
    }


#ifdef __EMAC_REGS__ENST_START_TIME_Q8_MACRO__
    if (0 == status) {
        if (IsEnstSupported(pD) == 0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (txQs < 9) {
            queueIdx = queueNum + 8;
        }
        else {
            queueIdx = queueNum + (16 - txQs);
        }

        if (queueIdx >=8) {

            startPtr = enstStartTimeReg[queueIdx - 8];
            addRegBase(pD, &startPtr);

            onPtr = enstOnTimeReg[queueIdx - 8];
            addRegBase(pD, &onPtr);

            offPtr = enstOffTimeReg[queueIdx - 8];
            addRegBase(pD, &offPtr);

            /* Using macros for Q8, since they're all identical. */
            regTmp = CPS_UncachedRead32(startPtr);
            EMAC_REGS__ENST_START_TIME_Q8__START_TIME_NSEC__MODIFY(regTmp,
                        enstTimeConfig->startTimeNs);
            EMAC_REGS__ENST_START_TIME_Q8__START_TIME_SEC__MODIFY(regTmp,
                        enstTimeConfig->startTimeS);
            CPS_UncachedWrite32(startPtr, regTmp);

            regTmp = CPS_UncachedRead32(onPtr);
            EMAC_REGS__ENST_ON_TIME_Q8__ON_TIME__MODIFY(regTmp,
                        enstTimeConfig->onTime);
            CPS_UncachedWrite32(onPtr, regTmp);

            regTmp = CPS_UncachedRead32(offPtr);
            EMAC_REGS__ENST_OFF_TIME_Q8__OFF_TIME__MODIFY(regTmp,
                        enstTimeConfig->offTime);
            CPS_UncachedWrite32(offPtr, regTmp);

        } else {
            status = EINVAL;
        }
    }

#else
    if (0 == status) {
        status = ENOTSUP;
    }
#endif
    return (status);

}

/* get timing configuration of Enhancement for Scheduled Traffic priority scheduler */
uint32_t
emacGetEnstTimeConfig(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_EnstTimeConfig *enstTimeConfig)
{
    uint32_t status = 0;
    uint32_t regTmp;
    uint8_t txQs;
    uint8_t queueIdx;
    volatile uint32_t *startPtr = NULL;
    volatile uint32_t *onPtr = NULL;
    volatile uint32_t *offPtr = NULL;

    if ((pD == NULL) || (enstTimeConfig == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
    txQs = pD->txQs;

        if (queueNum >= txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((txQs > 8) && (queueNum < (txQs - 8))){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                    "Error: Queue number must bigger than %d\n", txQs - 8);
            status = EINVAL;
        }
    }

#ifdef __EMAC_REGS__ENST_START_TIME_Q8_MACRO__
    if (0 == status) {
        if (IsEnstSupported(pD) == 0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (txQs < 9) {
            queueIdx = queueNum + 8;
        }
        else {
            queueIdx = queueNum + (16 - txQs);
        }

        if (queueIdx >=8) {

            startPtr = enstStartTimeReg[queueIdx - 8];
            addRegBase(pD, &startPtr);

            onPtr = enstOnTimeReg[queueIdx - 8];
            addRegBase(pD, &onPtr);

            offPtr = enstOffTimeReg[queueIdx - 8];
            addRegBase(pD, &offPtr);

            /* Using macros for Q8, since they're all identical. */
            regTmp = CPS_UncachedRead32(startPtr);
            enstTimeConfig->startTimeNs = \
                    EMAC_REGS__ENST_START_TIME_Q8__START_TIME_NSEC__READ(regTmp);
            enstTimeConfig->startTimeS = \
                    EMAC_REGS__ENST_START_TIME_Q8__START_TIME_SEC__READ(regTmp);
            regTmp = CPS_UncachedRead32(onPtr);
            enstTimeConfig->onTime = \
                    EMAC_REGS__ENST_ON_TIME_Q8__ON_TIME__READ(regTmp);
            regTmp = CPS_UncachedRead32(offPtr);
            enstTimeConfig->offTime = \
                    EMAC_REGS__ENST_OFF_TIME_Q8__OFF_TIME__READ(regTmp);

        } else {
            status = EINVAL;
        }
    }
#else
    if (0 == status) {
        status = ENOTSUP;
    }
#endif

    return (status);
}

/* enable/disable Scheduled Traffic priority scheduler */
uint32_t
emacSetEnstEnable(CEDI_PrivateData *pD, uint8_t queue, uint8_t enable)
{
    uint32_t status = 0;
    uint32_t regTmp;
    uint8_t queueIdx, txQs;

    if ((pD == NULL) || (enable > 1)) {
        status = EINVAL;
    }

    if (0 == status) {
        txQs = pD->txQs;

        if (queue >= txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((txQs > 8) && (queue < (txQs - 8))){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                    "Error: Queue number must bigger than %d\n", txQs - 8);
            status = EINVAL;
        }
    }


#ifdef __EMAC_REGS__ENST_CONTROL_MACRO__

    if (0 == status) {
        if (IsEnstSupported(pD) == 0) {
            status = ENOTSUP;
        }
    }


    if (0 == status) {
        if (txQs < 9) {
            queueIdx = queue + 8;
        }
        else {
            queueIdx = queue + (16 - txQs);
        }

        regTmp = CPS_UncachedRead32(&(pD->regs->enst_control));
        switch (queueIdx){
        case 8:
            EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q8__MODIFY(regTmp, enable);
            break;
        case 9:
            EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q9__MODIFY(regTmp, enable);
            break;
        case 10:
            EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q10__MODIFY(regTmp, enable);
            break;
        case 11:
            EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q11__MODIFY(regTmp, enable);
            break;
        case 12:
            EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q12__MODIFY(regTmp, enable);
            break;
        case 13:
            EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q13__MODIFY(regTmp, enable);
            break;
        case 14:
            EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q14__MODIFY(regTmp, enable);
            break;
        case 15:
            EMAC_REGS__ENST_CONTROL__ENST_ENABLE_Q15__MODIFY(regTmp, enable);
            break;
        default:
            status = EINVAL;
            break;
        }
	/* to be be backward compatible */
	regTmp |= (uint32_t)!enable << (16 + queue);

        CPS_UncachedWrite32(&(pD->regs->enst_control), regTmp);
    }

#else
    if (0 == status) {
        status = ENOTSUP;
    }
#endif

    return (status);
}

/* get state(enabled/disabled) of Scheduled Traffic priority scheduler.  */
uint32_t
emacGetEnstEnable(CEDI_PrivateData *pD, uint8_t queue, uint8_t *enable)
{
    uint32_t status = 0;
    uint32_t regTmp;
    uint8_t queueIdx, txQs;

    if ((pD == NULL) || (enable == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        txQs = pD->txQs;
        if (queue >= txQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Queue number to configure is bigger than number of active queues\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((txQs > 8) && (queue < (txQs - 8))){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                    "Error: Queue number must bigger than %d\n", txQs - 8);
            status = EINVAL;
        }
    }

#ifdef __EMAC_REGS__ENST_CONTROL_MACRO__
    if (0 == status) {
        if (IsEnstSupported(pD) == 0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (txQs < 9){
            queueIdx = queue + 8;
        }
        else {
            queueIdx = queue + (txQs - 8);
        }

        regTmp = CPS_UncachedRead32(&(pD->regs->enst_control));
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
        default:
            status = EINVAL;
            break;
        }
    }
#else
    if (0 == status) {
        status = ENOTSUP;
    }
#endif

    return (status);
}

/* check, if EnST is supported by core */
uint32_t emacGetEnstSupported(CEDI_PrivateData *pD, uint8_t *supported)
{
    uint32_t status = 0;
    if ((pD==NULL) || (supported==NULL)) {
        status = EINVAL;
    } else {
        *supported = IsEnstSupported(pD);
    }
    return (status);
}

/* function configures idle slope parameter for CBS priority queuing scheduler */
uint32_t emacSetCbsIdleSlope(CEDI_PrivateData *pD, uint8_t queueNum, uint32_t idleSlope)
{
    uint32_t status = 0;
    uint32_t reg;
    CEDI_TxSchedType schedType = CEDI_TX_SCHED_TYPE_FIXED;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }

        if (pD->hwCfg.exclude_cbs==1) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (pD->txQs==1) {
            status = EINVAL;
        }

        if (queueNum >= pD->txQs) {
            status = EINVAL;
        }

        if (queueNum < (pD->txQs - 2)) {
            status = EINVAL;
        }
    }


    if (0 == status) {
        status = emacGetTxQueueScheduler(pD, queueNum, &schedType);
    }

    if (0 == status) {
        if (schedType == CEDI_TX_SCHED_TYPE_CBS){
            status = emacSetTxQueueScheduler(pD, queueNum, CEDI_TX_SCHED_TYPE_FIXED);
        }
    }

    if (0 == status) {
        reg = 0;
        if (queueNum == (pD->txQs - 2)) {   /* i.e. queue B */
            EMAC_REGS__CBS_IDLESLOPE_Q_B__IDLESLOPE_B__MODIFY(reg, idleSlope);
            CPS_UncachedWrite32(&(pD->regs->cbs_idleslope_q_b), reg);
        } else {
            if (queueNum == (pD->txQs - 1)) {   /* i.e. queue A */
                EMAC_REGS__CBS_IDLESLOPE_Q_A__IDLESLOPE_A__MODIFY(reg, idleSlope);
                CPS_UncachedWrite32(&(pD->regs->cbs_idleslope_q_a), reg);
            }
        }

        /* recover CBS scheduler type */
        if (schedType == CEDI_TX_SCHED_TYPE_CBS){
            status = emacSetTxQueueScheduler(pD, queueNum, CEDI_TX_SCHED_TYPE_CBS);
        }
    }

    return (status);
}

/* get configuration of idle slope parameter for CBS priority queuing scheduler */
uint32_t emacGetCbsIdleSlope(CEDI_PrivateData *pD, uint8_t queueNum, uint32_t *idleSlope)
{
    uint32_t status = 0;
    uint32_t reg;

    if ((pD==NULL)||(idleSlope==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if ((CEDI_MAC_TYPE_EMAC == pD->macType) || (pD->hwCfg.exclude_cbs==1)) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if ((pD->txQs==1) || (queueNum >= pD->txQs) ||(queueNum < (pD->txQs - 2))) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (queueNum == (pD->txQs - 2)) {   /* i.e. queue B */
            reg = CPS_UncachedRead32(&(pD->regs->cbs_idleslope_q_b));
            *idleSlope = EMAC_REGS__CBS_IDLESLOPE_Q_B__IDLESLOPE_B__READ(reg);
        } else {
            if (queueNum == (pD->txQs - 1)) {   /* i.e. queue A */
                reg = CPS_UncachedRead32(&(pD->regs->cbs_idleslope_q_a));
                *idleSlope = EMAC_REGS__CBS_IDLESLOPE_Q_A__IDLESLOPE_A__READ(reg);
            }
        }
    }

    return (status);
}


