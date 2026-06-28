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
 * edd_rx.c
 * Ethernet DMA MAC Driver
 *
 * Rx-related functions source file
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

/* hold offsets to specific address registers, relative to regbase */
volatile uint32_t* const specAddBottomReg[32] = {
    CEDI_RegOff(spec_add1_bottom),
    CEDI_RegOff(spec_add2_bottom),
    CEDI_RegOff(spec_add3_bottom),
    CEDI_RegOff(spec_add4_bottom),
    CEDI_RegOff(spec_add5_bottom),
    CEDI_RegOff(spec_add6_bottom),
    CEDI_RegOff(spec_add7_bottom),
    CEDI_RegOff(spec_add8_bottom),
    CEDI_RegOff(spec_add9_bottom),
    CEDI_RegOff(spec_add10_bottom),
    CEDI_RegOff(spec_add11_bottom),
    CEDI_RegOff(spec_add12_bottom),
    CEDI_RegOff(spec_add13_bottom),
    CEDI_RegOff(spec_add14_bottom),
    CEDI_RegOff(spec_add15_bottom),
    CEDI_RegOff(spec_add16_bottom),
    CEDI_RegOff(spec_add17_bottom),
    CEDI_RegOff(spec_add18_bottom),
    CEDI_RegOff(spec_add19_bottom),
    CEDI_RegOff(spec_add20_bottom),
    CEDI_RegOff(spec_add21_bottom),
    CEDI_RegOff(spec_add22_bottom),
    CEDI_RegOff(spec_add23_bottom),
    CEDI_RegOff(spec_add24_bottom),
    CEDI_RegOff(spec_add25_bottom),
    CEDI_RegOff(spec_add26_bottom),
    CEDI_RegOff(spec_add27_bottom),
    CEDI_RegOff(spec_add28_bottom),
    CEDI_RegOff(spec_add29_bottom),
    CEDI_RegOff(spec_add30_bottom),
    CEDI_RegOff(spec_add31_bottom),
    CEDI_RegOff(spec_add32_bottom)
};

static volatile uint32_t* const specAddTopReg[32] = {
    CEDI_RegOff(spec_add1_top),
    CEDI_RegOff(spec_add2_top),
    CEDI_RegOff(spec_add3_top),
    CEDI_RegOff(spec_add4_top),
    CEDI_RegOff(spec_add5_top),
    CEDI_RegOff(spec_add6_top),
    CEDI_RegOff(spec_add7_top),
    CEDI_RegOff(spec_add8_top),
    CEDI_RegOff(spec_add9_top),
    CEDI_RegOff(spec_add10_top),
    CEDI_RegOff(spec_add11_top),
    CEDI_RegOff(spec_add12_top),
    CEDI_RegOff(spec_add13_top),
    CEDI_RegOff(spec_add14_top),
    CEDI_RegOff(spec_add15_top),
    CEDI_RegOff(spec_add16_top),
    CEDI_RegOff(spec_add17_top),
    CEDI_RegOff(spec_add18_top),
    CEDI_RegOff(spec_add19_top),
    CEDI_RegOff(spec_add20_top),
    CEDI_RegOff(spec_add21_top),
    CEDI_RegOff(spec_add22_top),
    CEDI_RegOff(spec_add23_top),
    CEDI_RegOff(spec_add24_top),
    CEDI_RegOff(spec_add25_top),
    CEDI_RegOff(spec_add26_top),
    CEDI_RegOff(spec_add27_top),
    CEDI_RegOff(spec_add28_top),
    CEDI_RegOff(spec_add29_top),
    CEDI_RegOff(spec_add30_top),
    CEDI_RegOff(spec_add31_top),
    CEDI_RegOff(spec_add32_top)
};

static volatile uint32_t* const receivePtrReg[15] = {
    CEDI_RegOff(receive_q1_ptr),
    CEDI_RegOff(receive_q2_ptr),
    CEDI_RegOff(receive_q3_ptr),
    CEDI_RegOff(receive_q4_ptr),
    CEDI_RegOff(receive_q5_ptr),
    CEDI_RegOff(receive_q6_ptr),
    CEDI_RegOff(receive_q7_ptr),
    CEDI_RegOff(receive_q8_ptr),
    CEDI_RegOff(receive_q9_ptr),
    CEDI_RegOff(receive_q10_ptr),
    CEDI_RegOff(receive_q11_ptr),
    CEDI_RegOff(receive_q12_ptr),
    CEDI_RegOff(receive_q13_ptr),
    CEDI_RegOff(receive_q14_ptr),
    CEDI_RegOff(receive_q15_ptr)
};

/* hold offsets to type_2 compare registers, relative to regbase */
static volatile uint32_t* const type2CompareWord0Reg[32] = {
    CEDI_RegOff(type2_compare_0_word_0),
    CEDI_RegOff(type2_compare_1_word_0),
    CEDI_RegOff(type2_compare_2_word_0),
    CEDI_RegOff(type2_compare_3_word_0),
    CEDI_RegOff(type2_compare_4_word_0),
    CEDI_RegOff(type2_compare_5_word_0),
    CEDI_RegOff(type2_compare_6_word_0),
    CEDI_RegOff(type2_compare_7_word_0),
    CEDI_RegOff(type2_compare_8_word_0),
    CEDI_RegOff(type2_compare_9_word_0),
    CEDI_RegOff(type2_compare_10_word_0),
    CEDI_RegOff(type2_compare_11_word_0),
    CEDI_RegOff(type2_compare_12_word_0),
    CEDI_RegOff(type2_compare_13_word_0),
    CEDI_RegOff(type2_compare_14_word_0),
    CEDI_RegOff(type2_compare_15_word_0),
    CEDI_RegOff(type2_compare_16_word_0),
    CEDI_RegOff(type2_compare_17_word_0),
    CEDI_RegOff(type2_compare_18_word_0),
    CEDI_RegOff(type2_compare_19_word_0),
    CEDI_RegOff(type2_compare_20_word_0),
    CEDI_RegOff(type2_compare_21_word_0),
    CEDI_RegOff(type2_compare_22_word_0),
    CEDI_RegOff(type2_compare_23_word_0),
    CEDI_RegOff(type2_compare_24_word_0),
    CEDI_RegOff(type2_compare_25_word_0),
    CEDI_RegOff(type2_compare_26_word_0),
    CEDI_RegOff(type2_compare_27_word_0),
    CEDI_RegOff(type2_compare_28_word_0),
    CEDI_RegOff(type2_compare_29_word_0),
    CEDI_RegOff(type2_compare_30_word_0),
    CEDI_RegOff(type2_compare_31_word_0)
};

static volatile uint32_t* const type2CompareWord1Reg[32] = {
    CEDI_RegOff(type2_compare_0_word_1),
    CEDI_RegOff(type2_compare_1_word_1),
    CEDI_RegOff(type2_compare_2_word_1),
    CEDI_RegOff(type2_compare_3_word_1),
    CEDI_RegOff(type2_compare_4_word_1),
    CEDI_RegOff(type2_compare_5_word_1),
    CEDI_RegOff(type2_compare_6_word_1),
    CEDI_RegOff(type2_compare_7_word_1),
    CEDI_RegOff(type2_compare_8_word_1),
    CEDI_RegOff(type2_compare_9_word_1),
    CEDI_RegOff(type2_compare_10_word_1),
    CEDI_RegOff(type2_compare_11_word_1),
    CEDI_RegOff(type2_compare_12_word_1),
    CEDI_RegOff(type2_compare_13_word_1),
    CEDI_RegOff(type2_compare_14_word_1),
    CEDI_RegOff(type2_compare_15_word_1),
    CEDI_RegOff(type2_compare_16_word_1),
    CEDI_RegOff(type2_compare_17_word_1),
    CEDI_RegOff(type2_compare_18_word_1),
    CEDI_RegOff(type2_compare_19_word_1),
    CEDI_RegOff(type2_compare_20_word_1),
    CEDI_RegOff(type2_compare_21_word_1),
    CEDI_RegOff(type2_compare_22_word_1),
    CEDI_RegOff(type2_compare_23_word_1),
    CEDI_RegOff(type2_compare_24_word_1),
    CEDI_RegOff(type2_compare_25_word_1),
    CEDI_RegOff(type2_compare_26_word_1),
    CEDI_RegOff(type2_compare_27_word_1),
    CEDI_RegOff(type2_compare_28_word_1),
    CEDI_RegOff(type2_compare_29_word_1),
    CEDI_RegOff(type2_compare_30_word_1),
    CEDI_RegOff(type2_compare_31_word_1)
};

static volatile uint32_t* const type1ScreeningReg[16] = {
    CEDI_RegOff(screening_type_1_register_0),
    CEDI_RegOff(screening_type_1_register_1),
    CEDI_RegOff(screening_type_1_register_2),
    CEDI_RegOff(screening_type_1_register_3),
    CEDI_RegOff(screening_type_1_register_4),
    CEDI_RegOff(screening_type_1_register_5),
    CEDI_RegOff(screening_type_1_register_6),
    CEDI_RegOff(screening_type_1_register_7),
    CEDI_RegOff(screening_type_1_register_8),
    CEDI_RegOff(screening_type_1_register_9),
    CEDI_RegOff(screening_type_1_register_10),
    CEDI_RegOff(screening_type_1_register_11),
    CEDI_RegOff(screening_type_1_register_12),
    CEDI_RegOff(screening_type_1_register_13),
    CEDI_RegOff(screening_type_1_register_14),
    CEDI_RegOff(screening_type_1_register_15)
};

static volatile uint32_t* const type2ScreeningReg[16] = {
    CEDI_RegOff(screening_type_2_register_0),
    CEDI_RegOff(screening_type_2_register_1),
    CEDI_RegOff(screening_type_2_register_2),
    CEDI_RegOff(screening_type_2_register_3),
    CEDI_RegOff(screening_type_2_register_4),
    CEDI_RegOff(screening_type_2_register_5),
    CEDI_RegOff(screening_type_2_register_6),
    CEDI_RegOff(screening_type_2_register_7),
    CEDI_RegOff(screening_type_2_register_8),
    CEDI_RegOff(screening_type_2_register_9),
    CEDI_RegOff(screening_type_2_register_10),
    CEDI_RegOff(screening_type_2_register_11),
    CEDI_RegOff(screening_type_2_register_12),
    CEDI_RegOff(screening_type_2_register_13),
    CEDI_RegOff(screening_type_2_register_14),
    CEDI_RegOff(screening_type_2_register_15)
};

static volatile uint32_t* const type2ScreeningEthertypeReg[8] = {
    CEDI_RegOff(screening_type_2_ethertype_reg_0),
    CEDI_RegOff(screening_type_2_ethertype_reg_1),
    CEDI_RegOff(screening_type_2_ethertype_reg_2),
    CEDI_RegOff(screening_type_2_ethertype_reg_3),
    CEDI_RegOff(screening_type_2_ethertype_reg_4),
    CEDI_RegOff(screening_type_2_ethertype_reg_5),
    CEDI_RegOff(screening_type_2_ethertype_reg_6),
    CEDI_RegOff(screening_type_2_ethertype_reg_7),
};


static volatile uint32_t* const rxQueueFlushReg[16] = {
    CEDI_RegOff(rx_q0_flush),
    CEDI_RegOff(rx_q1_flush),
    CEDI_RegOff(rx_q2_flush),
    CEDI_RegOff(rx_q3_flush),
    CEDI_RegOff(rx_q4_flush),
    CEDI_RegOff(rx_q5_flush),
    CEDI_RegOff(rx_q6_flush),
    CEDI_RegOff(rx_q7_flush),
    CEDI_RegOff(rx_q8_flush),
    CEDI_RegOff(rx_q9_flush),
    CEDI_RegOff(rx_q10_flush),
    CEDI_RegOff(rx_q11_flush),
    CEDI_RegOff(rx_q12_flush),
    CEDI_RegOff(rx_q13_flush),
    CEDI_RegOff(rx_q14_flush),
    CEDI_RegOff(rx_q15_flush),
};

static volatile uint32_t* const scr2RateLimitReg[16] = {
    CEDI_RegOff(scr2_reg0_rate_limit),
    CEDI_RegOff(scr2_reg1_rate_limit),
    CEDI_RegOff(scr2_reg2_rate_limit),
    CEDI_RegOff(scr2_reg3_rate_limit),
    CEDI_RegOff(scr2_reg4_rate_limit),
    CEDI_RegOff(scr2_reg5_rate_limit),
    CEDI_RegOff(scr2_reg6_rate_limit),
    CEDI_RegOff(scr2_reg7_rate_limit),
    CEDI_RegOff(scr2_reg8_rate_limit),
    CEDI_RegOff(scr2_reg9_rate_limit),
    CEDI_RegOff(scr2_reg10_rate_limit),
    CEDI_RegOff(scr2_reg11_rate_limit),
    CEDI_RegOff(scr2_reg12_rate_limit),
    CEDI_RegOff(scr2_reg13_rate_limit),
    CEDI_RegOff(scr2_reg14_rate_limit),
    CEDI_RegOff(scr2_reg15_rate_limit),
};




/******************************************************************************
 * Private Driver functions
 *****************************************************************************/

static void getNumScreenRegs(const CEDI_PrivateData *pD, CEDI_NumScreeners *regNums)
{
    regNums->type1ScrRegs = pD->hwCfg.num_type1_screeners;
    regNums->type2ScrRegs = pD->hwCfg.num_type2_screeners;
    regNums->ethtypeRegs = pD->hwCfg.num_scr2_ethtype_regs;
    regNums->compareRegs = pD->hwCfg.num_scr2_compare_regs;
}

/* check if queue is used in screening, if it used then disable screening for that queue */
static uint32_t QueueCheckAndDisableScreening(CEDI_PrivateData *pD, uint8_t queueIdx)
{
    uint8_t i;
    CEDI_NumScreeners numScreeners;
    CEDI_T1Screen t1S;
    CEDI_T2Screen t2S;
    uint32_t status = 0;

    getNumScreenRegs(pD, &numScreeners);

    for (i = 0; i < numScreeners.type1ScrRegs; i++){
        status = emacGetType1ScreenReg(pD, i, &t1S);
        if (0 == status) {
            if ((queueIdx == t1S.qNum) && (t1S.udpEnable || t1S.dstcEnable)){
                t1S.udpEnable = 0;
                t1S.dstcEnable = 0;
                status = emacSetType1ScreenReg(pD, i, &t1S);
            }
        }
    }

    if (0 == status) {
        for (i = 0; i < numScreeners.type2ScrRegs; i++){
            status = emacGetType2ScreenReg(pD, i, &t2S);
            if (0 == status) {
                if ((queueIdx == t2S.qNum) && (t2S.vlanEnable || t2S.eTypeEnable
                                               || t2S.compAEnable || t2S.compBEnable
                                               || t2S.compCEnable)){
                    t2S.vlanEnable = 0;
                    t2S.eTypeEnable = 0;
                    t2S.compAEnable = 0;
                    t2S.compBEnable = 0;
                    t2S.compCEnable = 0;
                    status = emacSetType2ScreenReg(pD, i, &t2S);
                    if (0 != status) {
                        break;
                    }
                }
            }
        }
    }

    return (status);
}

static void enableRxQs(CEDI_PrivateData *pD, uint8_t numQueues)
{
    uint32_t regTmp;
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    for (i = numQueues-1; i > 0; i--) {
        regPtr = receivePtrReg[i-1];
        addRegBase(pD, &regPtr);
        regTmp = CPS_UncachedRead32(regPtr);
        EMAC_REGS__RECEIVE_Q_PTR__DMA_RX_DIS_Q__MODIFY(regTmp, 0);
        CPS_UncachedWrite32(regPtr, regTmp);
    }
}

static void disableRxQs(CEDI_PrivateData *pD, uint8_t numQueues)
{
    uint32_t regTmp;
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    if (numQueues > 0) {
        for (i = numQueues; i < pD->cfg.rxQs; i++)
        {
            regPtr = receivePtrReg[i-1];
            addRegBase(pD, &regPtr);
            regTmp = CPS_UncachedRead32(regPtr);
            EMAC_REGS__RECEIVE_Q_PTR__DMA_RX_DIS_Q__MODIFY(regTmp, 1);
            CPS_UncachedWrite32(regPtr, regTmp);
        }
    }
}

static void getJumboFrameRxMaxLen(CEDI_PrivateData *pD, uint16_t *length)
{

    *length=EMAC_REGS__JUMBO_MAX_LENGTH__JUMBO_MAX_LENGTH__READ(
            CPS_UncachedRead32(&(pD->regs->jumbo_max_length)));

}

static void get1536ByteFramesRx(CEDI_PrivateData *pD, uint8_t *enable)
{
    *enable= EMAC_REGS__NETWORK_CONFIG__RECEIVE_1536_BYTE_FRAMES__READ(
            CPS_UncachedRead32(&(pD->regs->network_config)));
}

/******************************************************************************
 * Driver API functions
 *****************************************************************************/

/* Identify max Rx pkt size for queues - determined by size of Rx packet buffer
 * (if using full store & forward mode), and the current maximum frame size,
 * e.g. 1518, 1536 or jumbo frame.
 * @param pD - driver private state info specific to this instance
 * @param maxSize - pointer for returning max frame size, same for each Rx queue
 * @return 0 if successful
 * @return EINVAL if invalid parameters
 */

uint32_t emacGetJumboFrameRxMaxLen(CEDI_PrivateData *pD, uint16_t *length)
{
    uint32_t status = 0;
    if ((pD==NULL)||(length==NULL)) {
        status = EINVAL;
    } else {
        getJumboFrameRxMaxLen(pD, length);
    }
    return (status);
}

uint32_t emacGet1536ByteFramesRx(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0;
    if ((pD==NULL)||(enable==NULL)) {
        status = EINVAL;
    } else {
        get1536ByteFramesRx(pD, enable);
    }

    return (status);
}

uint32_t emacCalcMaxRxFrameSize(CEDI_PrivateData *pD, uint32_t *maxSize) {
    uint32_t status = 0;
    uint16_t ram_word_size, ram_addr_bits;
    uint32_t ram_size_shift, ram_size, max_size, tmp;
    uint8_t enabled = 0;
    uint16_t length;

    if ((pD==NULL) || (maxSize==NULL)) {
        status = EINVAL;
    } else {
        getJumboFramesRx(pD, &enabled);

        if (0 != enabled) {
            getJumboFrameRxMaxLen(pD, &length);
            max_size = length;
        } else {
            get1536ByteFramesRx(pD, &enabled);
            if (0 != enabled) {
                max_size = 1536;
            } else {
                max_size = 1518;
            }
        }
    }

    if (0 == status) {
        if (0!=emacGetRxPartialStFwd(pD, &tmp, &enabled)) {
            status = EINVAL;
        }
    }

    if (0 == status) {
    if ((!enabled) && pD->hwCfg.rx_pkt_buffer)
    {
            // What is word size of SRAM in bytes
            ram_word_size = (pD->hwCfg.rx_pbuf_data >> 1)+1;
            ram_addr_bits = pD->hwCfg.rx_pbuf_addr;
            ram_size_shift = (uint32_t)ram_addr_bits + (uint32_t)ram_word_size + 1;

            if(ram_size_shift < 32)
            {
                ram_size = (1<<ram_size_shift) - 96;
                vDbgMsg(DBG_GEN_MSG, 10, "RAM size = %u\n", ram_size);
            } else {
                status = EINVAL;
            }

            if (0 == status) {
                if (ram_size<max_size) {
                    max_size = ram_size;
                }
            }
        }
        if (0 == status) {
            vDbgMsg(DBG_GEN_MSG, 10, "Max Rx frame size = %u\n", max_size);

            *maxSize = max_size;
        }
    }
    return (status);
}

/* Add a buffer (size determined by rxBufLength in CEDI_Config) to the end of
 * the receive buffer queue.  This function is intended to be used during
 * setting up the receive buffers, and should not be called while Rx is
 * enabled or unread data remains in the queue.
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of the Rx queue (range 0 to rxQs-1)
 * @param buf - pointer to struct for virtual and physical addresses of buffer.
 *      Physical address checked for word-alignment in 64/128-bit width cases.
 * @param init - if <>0 then initialise the buffer data to all zeros
 * @return 0 if successful, EINVAL if invalid queueNum, buffer alignment, or
 *    bufStart pointer/addresses
 */
uint32_t emacAddRxBuf(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_BuffAddr *buf, uint8_t init)
{
    uint32_t status = 0;
    uint32_t tmp, bufLenWords;
    rxQueue_t *rxQ;

    if (pD == NULL)  {
        status = EINVAL;
    }

    if (0 == status) {
        if (queueNum>=pD->rxQs) {
            vDbgMsg(DBG_GEN_MSG, 5, "Error: Invalid Rx queue number: %u\n", queueNum);
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((buf==NULL) || (buf->vAddr==0) || (buf->pAddr==0)) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: NULL buf parameter");
            status = EINVAL;
        }
    }

    if (0 == status) {
        rxQ = &(pD->rxQueue[queueNum]);

        if (rxQ->numRxBufs>=((pD->cfg).rxQLen[queueNum])) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: Rx descriptor list full");
            status = EINVAL;
        }
    }

    if (0 == status) {
        /* alignment checking */
        switch (pD->cfg.dmaBusWidth) {
        case CEDI_DMA_BUS_WIDTH_32:
            tmp = 4; break;
        case CEDI_DMA_BUS_WIDTH_64:
            tmp = 8; break;
        case CEDI_DMA_BUS_WIDTH_128:
            tmp = 16; break;
        default: tmp = 4; break;
        }
        if (0 != ((buf->pAddr)%tmp)) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: Rx buffer not word-aligned");
            status = EINVAL;
        }
    }

    if (0 == status) {
        /* save virtual address */
        *(rxQ->rxEndVA) = buf->vAddr;

        bufLenWords = (uint32_t)(pD->cfg.rxBufLength[queueNum])<<4;
        if (0 != init) {
            for (tmp=0; tmp<bufLenWords; tmp++) {

                CPS_UncachedWrite32((uintptrToPtrU32(buf->vAddr))+tmp, 0);
            }
        }

        /* clear wrap & used on old end, add new buffer */
        CPS_UncachedWrite32(&(rxQ->rxDescEnd->word[0]),
                                buf->pAddr & CEDI_RXD_ADDR_MASK);
        /* upper 32 bits if 64 bit addressing */
        if (0 != pD->cfg.dmaAddrBusWidth) {
#ifdef CEDI_64B_COMPILE
            /* 64-bit addressing */
            CPS_UncachedWrite32(&(rxQ->rxDescEnd->word[2]),
                                 (buf->pAddr & 0xFFFFFFFF00000000)>>32);
#else
            /* 32-bit addressing */
                /* include only for test use */
                /* copy in faked upper 32 bits for testing in 32-bit env. */
            CPS_UncachedWrite32(&(rxQ->rxDescEnd->word[2]),
                                 pD->cfg.upper32BuffRxQAddr);
    #endif
        }

        /* put known pattern into word[1] for debugging */
        CPS_UncachedWrite32(&(rxQ->rxDescEnd->word[1]), CEDI_RXD_EMPTY);

        /* inc end & stop pointer */
        moveRxDescAddr(&(rxQ->rxDescEnd), pD->rxDescriptorSize);
        rxQ->rxDescStop = rxQ->rxDescEnd;

        /* inc VA end & stop pointers & buffer count */
        rxQ->rxEndVA++;
        rxQ->rxStopVA++;
        *(rxQ->rxStopVA) = 0;
        rxQ->numRxBufs++;

        /* write new end(-stop) descriptor */
        CPS_UncachedWrite32(&(rxQ->rxDescEnd->word[0]),
                                 CEDI_RXD_WRAP | CEDI_RXD_USED );

    }
    return (status);
}

/* Get the number of useable buffers/descriptors present in the specified
 * Rx queue, excluding the end-stop descriptor.
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of the Rx queue (range 0 to rxQs-1)
 * @param numBufs - pointer for returning number of descriptors
 * @return 0 if successful
 * @return EINVAL if invalid parameter
 */
uint32_t emacNumRxBufs(const CEDI_PrivateData *pD, uint8_t queueNum, uint16_t *numBufs)
{
    uint32_t status = 0;
    if ((pD==NULL) || (numBufs==NULL)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (queueNum>=pD->rxQs) {
            status = EINVAL;
        }
    }
    if (0 == status) {
        *numBufs = (pD->rxQueue[queueNum]).numRxBufs;
    }
    return (status);
}

/* Get the number of buffers/descriptors marked "used" in the specified Rx
 *   queue (excluding unuseable end-stop), i.e. those holding unread data.
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of the Rx queue (range 0 to rxQs-1)
 * @return number of used buffers
 * @return 0 if invalid parameter
 */
uint32_t emacNumRxUsed(CEDI_PrivateData *pD, uint8_t queueNum)
{
    uint32_t retVal = 1;
    uint32_t tmp, thisWd, count=0;
    rxDesc *thisDesc;
    rxQueue_t *rxQ;

    if ((pD==NULL) || (queueNum>=pD->rxQs)) {
        retVal = 0;
    }

    if (retVal == 1)
    {
        rxQ = &(pD->rxQueue[queueNum]);
        /* count forward from tail, until used not set */
        thisDesc =  rxQ->rxDescTail;
        for (tmp = 0; tmp<rxQ->numRxBufs; tmp++)
        {
            thisWd = CPS_UncachedRead32(&(thisDesc->word[0]));
            if (0 != (thisWd & CEDI_RXD_USED)) {
                count++;
            } else {
                break;
            }
            if (0 != (thisWd & CEDI_RXD_WRAP)) {
                thisDesc = rxQ->rxDescStart;
            } else {
                moveRxDescAddr(&thisDesc, (pD->rxDescriptorSize));
            }
        }
        retVal = count;
    }
    return (retVal);
}

/**
 * Read first unread descriptor (at tail of queue): if new data is available
 * it swaps out the buffer and replaces it with a new one, clears the
 * descriptor for re-use, then updates the driver queue-pointer.
 * Checks for Start Of Frame (SOF) and End Of Frame (EOF) flags in the
 * descriptors, passing back in return value.
 * If EOF set, the descriptor status is returned via rxDescStat.
 * @param[in] pD driver private state info specific to this instance
 * @param[in] queueNum
 *   number of the Rx queue
 * @param[in,out] buf pointer to address of memory for new buffer to add to Rx
 *   descriptor queue, if data is available the buffer addresses for this are
 *   returned in buf, else if no data available the new buffer can be re-used.
 *   Physical address of buffer is checked for word-alignment in 64/128-bit
 *   width cases.
 * @param[in] init if >0 then initialise the (new) buffer data to all zeros.
 *    Ignored if no data available.
 * @param[out] descData pointer for returning status & descriptor data
 *   Struct fields:
 *
 *    uint32_t rxDescStat  - Rx descriptor status word
 *
 *    uint8_t status    - Rx data status, one of the following values:
 *      CEDI_RXDATA_SOF_EOF  :data available, single-buffer frame (SOF & EOF
 *                            set)
 *      CEDI_RXDATA_SOF_ONLY :data available, start of multi-buffer frame
 *      CEDI_RXDATA_NO_FLAG  :data available, intermediate buffer of multi-
 *                            buffer frame
 *      CEDI_RXDATA_EOF_ONLY :data available, end of multi-buffer frame
 *      CEDI_RXDATA_NODATA   :no data available
 *
 *    CEDI_TimeStampData rxTsData - Rx descriptor timestamp when valid
 *                                  (rxTsData->tsValid will be set to 1)
 *
 * @return 0 if successful,
 * @return EINVAL if invalid queueNum, buf, rxDescStat or
 *    status parameters
 */
uint32_t emacReadRxBuf(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_BuffAddr *buf,
                        uint8_t init, CEDI_RxDescData *descData)
{
    uint32_t status = 0;
    uint32_t tmp, bufLenWords, descWd0;
    CEDI_BuffAddr oldbuf;
    uint8_t wdNum, tailWrap;
    uint32_t tsLowerWd, tsUpperWd;
    rxQueue_t *rxQ;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if (buf==NULL) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: NULL buf parameter");
            status = EINVAL;
        }
    }

        if (0 == status) {
        if (descData==NULL) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: NULL descData parameter");
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (queueNum>=pD->rxQs) {
            vDbgMsg(DBG_GEN_MSG, 5, "Error: Invalid Rx queue number - %u\n", queueNum);
            status = EINVAL;
        }
    }

    if (0 == status) {
        if ((buf->vAddr==0) || (buf->pAddr==0)) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: NULL buf address");
            status = EINVAL;
        }
    }

    if (0 == status) {
        /* alignment checking for new buffer */
        switch (pD->cfg.dmaBusWidth) {
        case CEDI_DMA_BUS_WIDTH_32:
            tmp = 4; break;
        case CEDI_DMA_BUS_WIDTH_64:
            tmp = 8; break;
        case CEDI_DMA_BUS_WIDTH_128:
            tmp = 16; break;
        default: tmp = 4; break;
        }
        if (0 != ((buf->pAddr)%tmp)) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: Rx buffer not word-aligned");
            status = EINVAL;
        }
    }

    if (0 == status) {
        rxQ = &(pD->rxQueue[queueNum]);

        /* get first descriptor & test used bit */
        descWd0 = CPS_UncachedRead32(&(rxQ->rxDescTail->word[0]));

        if (0 != (descWd0 & CEDI_RXD_USED)) {
            /* new data received - read & process descriptor */

            /* get old physical address */
            oldbuf.pAddr = (uintptr_t)descWd0 & CEDI_RXD_ADDR_MASK;
            /* upper 32 bits if 64 bit addressing */
            if (0 != pD->cfg.dmaAddrBusWidth) {
                oldbuf.pAddr |= ((uint64_t)CPS_UncachedRead32(
                                            &(rxQ->rxDescTail->word[2])))<<32;
            }

            /* get old virtual address & clear from list */
            oldbuf.vAddr = *(rxQ->rxTailVA);
            *(rxQ->rxTailVA) = 0;

            /* save new virtual address */
            *(rxQ->rxStopVA) = buf->vAddr;

            bufLenWords = (uint32_t)(pD->cfg.rxBufLength[queueNum])<<4;
            if (0 != init) {
                for (tmp=0; tmp<bufLenWords; tmp++) {
                    CPS_UncachedWrite32(uintptrToPtrU32((buf->vAddr)+((uintptr_t)tmp*4)), 0);
                }
            }

            /* read Rx status */
            descData->rxDescStat = CPS_UncachedRead32(&(rxQ->rxDescTail->word[1]));

            /* extract timestamp if available */
            if ((pD->cfg.enRxExtBD) && (descWd0 & CEDI_RXD_TS_VALID)) {
            uint32_t reg;
                descData->rxTsData.tsValid = 1;
                            // position depends on 32/64 bit addr
                wdNum = (0 != (pD->cfg.dmaAddrBusWidth))?4:2;

                tsLowerWd = CPS_UncachedRead32(&(rxQ->rxDescTail->word[wdNum]));
                tsUpperWd = CPS_UncachedRead32(&(rxQ->rxDescTail->word[wdNum+1]));

                descData->rxTsData.tsNanoSec = tsLowerWd & CEDI_TS_NANO_SEC_MASK;
                descData->rxTsData.tsSecs =
                        (((tsUpperWd & CEDI_TS_SEC1_MASK)<<CEDI_TS_SEC1_POS_SHIFT)
                            | (tsLowerWd >> CEDI_TS_SEC0_SHIFT));

            /* The timestamp only contains lower few bits of seconds, so add value from 1588 timer */
            reg =  CPS_UncachedRead32(&(pD->regs->tsu_timer_sec));
            /* If the top bit is set in the timestamp, but not in 1588 timer, it has rolled over, so subtract max size */
            if ((descData->rxTsData.tsSecs & (CEDI_TS_SEC_TOP>>1)) && (!(reg & (CEDI_TS_SEC_TOP>>1)))) {
                descData->rxTsData.tsSecs -= (CEDI_TS_SEC_TOP<<1);

            }
            descData->rxTsData.tsSecs += ((uint32_t)(~CEDI_TS_SEC_MASK) & EMAC_REGS__TSU_TIMER_SEC__TIMER__READ(reg));
        } else {
            descData->rxTsData.tsValid = 0;
        }

            /* save this for later */
            tailWrap = descWd0 & CEDI_RXD_WRAP;

                    /* write back to descriptors */
            CPS_UncachedWrite32(&(rxQ->rxDescTail->word[1]), CEDI_RXD_EMPTY);
            /* zero buf physical address & set used - this will be new end-stop */
            CPS_UncachedWrite32(&(rxQ->rxDescTail->word[0]),
                                    CEDI_RXD_USED | ((0 != tailWrap)?CEDI_RXD_WRAP:0));

            /* handle old "stop" descriptor now */
            /* insert new buf physical address & clear used */
            descWd0 = CPS_UncachedRead32(&(rxQ->rxDescStop->word[0]));
            descWd0 = ((uint32_t)(buf->pAddr) & (uint32_t)CEDI_RXD_ADDR_MASK) |
                        (descWd0 & (uint32_t)CEDI_RXD_WRAP);
            CPS_UncachedWrite32(&(rxQ->rxDescStop->word[0]), descWd0);
            /* upper 32 bits if 64 bit addressing */
            if (0 != pD->cfg.dmaAddrBusWidth) {
#ifdef CEDI_64B_COMPILE
                /* 64-bit addressing */
                CPS_UncachedWrite32(&(rxQ->rxDescStop->word[2]),
                                 (buf->pAddr & 0xFFFFFFFF00000000)>>32);
#else
                /* 32-bit addressing */
                /* include only for test use */
                    /* copy in faked upper 32 bits for testing in 32-bit env. */
                CPS_UncachedWrite32(&(rxQ->rxDescStop->word[2]),
                                         pD->cfg.upper32BuffRxQAddr);
#endif
            }

            /* update pointers */
            rxQ->rxDescStop = rxQ->rxDescTail;
            rxQ->rxStopVA = rxQ->rxTailVA;
            if (0 != tailWrap) {
                rxQ->rxDescTail = rxQ->rxDescStart;
                rxQ->rxTailVA = rxQ->rxBufVAddr;
            }
            else {
                moveRxDescAddr(&(rxQ->rxDescTail), pD->rxDescriptorSize);
                rxQ->rxTailVA++;
            }

            /* return old buffer addresses */
            buf->pAddr = oldbuf.pAddr;
            buf->vAddr = oldbuf.vAddr;


            /* work out read frame status */
            if (0 != ((descData->rxDescStat) & CEDI_RXD_SOF)) {
                if (0 != ((descData->rxDescStat) & CEDI_RXD_EOF)) {
                    descData->status = CEDI_RXDATA_SOF_EOF;
                } else {
                    descData->status = CEDI_RXDATA_SOF_ONLY;
                }
            }
            else
            {
                if (0 != ((descData->rxDescStat) & CEDI_RXD_EOF)) {
                    descData->status = CEDI_RXDATA_EOF_ONLY;
                } else {
                    descData->status = CEDI_RXDATA_NO_FLAG;
                }
            }
        } else {
            descData->status = CEDI_RXDATA_NODATA;
        }
    }

    return (status);
}

/* Decode the Rx descriptor status into a bit-field struct
 * @param pD - driver private state info specific to this instance
 * @param rxDStatWord - Rx descriptor status word
 * @param rxDStat - pointer to bit-field struct for decoded status fields
 */
void emacGetRxDescStat(CEDI_PrivateData *pD, uint32_t rxDStatWord, CEDI_RxDescStat *rxDStat)
{
    uint32_t network_config, dma_config, wd1;

    if ((NULL!=pD) && (NULL!=rxDStat)) {
        network_config = CPS_UncachedRead32(&(pD->regs->network_config));
        dma_config = CPS_UncachedRead32(&(pD->regs->dma_config));

        wd1 = rxDStatWord;
        rxDStat->bufLen = wd1 & CEDI_RXD_LEN_MASK;
        if (EMAC_REGS__NETWORK_CONFIG__JUMBO_FRAMES__READ(network_config) ||
            (EMAC_REGS__NETWORK_CONFIG__IGNORE_RX_FCS__READ(network_config)==0)) {
            rxDStat->bufLen |= wd1 & CEDI_RXD_LEN13_FCS_STAT;
            rxDStat->fcsStatus = 0;
        } else {
            rxDStat->fcsStatus = (0 != (wd1 & CEDI_RXD_LEN13_FCS_STAT))?1:0;
        }

        rxDStat->sof = (0 != (wd1 & CEDI_RXD_SOF))?1:0;
        rxDStat->eof = (0 != (wd1 & CEDI_RXD_EOF))?1:0;

        if (0 != EMAC_REGS__DMA_CONFIG__HDR_DATA_SPLITTING_EN__READ(dma_config)) {
            rxDStat->header = ((!rxDStat->eof) && (wd1 & CEDI_RXD_HDR))?1:0;
        } else
        {
            rxDStat->header = 0;
        }

        rxDStat->eoh = ((!rxDStat->eof) && (wd1 & CEDI_RXD_EOH))?1:0;
        rxDStat->vlanTagDet = (0 != (wd1 & CEDI_RXD_VLAN_TAG))?1:0;

        rxDStat->cfi = 0;
        rxDStat->crc = 0;
        if (0 != (wd1 & CEDI_RXD_EOF)) {
#ifdef EMAC_REGS__DMA_CONFIG__CRC_ERROR_REPORT__READ
            if (0 != EMAC_REGS__DMA_CONFIG__CRC_ERROR_REPORT__READ(dma_config)) {
                rxDStat->crc = (0 != (wd1 & CEDI_RXD_CRC))? 1 : 0;
            } else
#endif
            {
                rxDStat->cfi = ((wd1 & CEDI_RXD_CFI) && rxDStat->vlanTagDet)?1:0;
            }
        }

        if (0 != rxDStat->vlanTagDet) {
            rxDStat->vlanPri =
                    (wd1 & CEDI_RXD_VLAN_PRI_MASK)>>CEDI_RXD_VLAN_PRI_SHIFT;
        } else {
            rxDStat->vlanPri = 0;
        }
        rxDStat->priTagDet = (0 != (wd1 & CEDI_RXD_PRI_TAG))?1:0;
        if (0 != EMAC_REGS__NETWORK_CONFIG__RECEIVE_CHECKSUM_OFFLOAD_ENABLE__READ(network_config)) {
            rxDStat->chkOffStat = (wd1 & CEDI_RXD_TYP_IDR_CHK_STA_MASK)\
                                        >>CEDI_RXD_TYP_IDR_CHK_STA_SHIFT;
            rxDStat->snapNoVlanCfi = (0 != (wd1 & CEDI_RXD_TYP_MAT_SNP_NCFI))?1:0;
            rxDStat->typeMatchReg = 0;
            rxDStat->typeIdMatch = 0;
        }
        else {
            rxDStat->chkOffStat = 0;
            rxDStat->snapNoVlanCfi = 0;
            rxDStat->typeMatchReg = (wd1 & CEDI_RXD_TYP_IDR_CHK_STA_MASK)\
                                        >>CEDI_RXD_TYP_IDR_CHK_STA_SHIFT;
            rxDStat->typeIdMatch = (0 != (wd1 & CEDI_RXD_TYP_MAT_SNP_NCFI))?1:0;
        }

        rxDStat->specAddReg = (wd1 & CEDI_RXD_SPEC_REG_MASK)\
                                    >>CEDI_RXD_SPEC_REG_SHIFT;
        if (pD->hwCfg.rx_pkt_buffer &&
                (pD->hwCfg.num_spec_add_filters>4))
        {   /* extra spec. addr matching variation */
            rxDStat->specAddReg += (((0 != ((wd1 & CEDI_RXD_SPEC_ADD_MAT)))?1:0) << 2);
            rxDStat->specAddMatch = (0 != (wd1 & CEDI_RXD_EXT_ADD_MAT))?1:0;
            rxDStat->extAddrMatch = 0;
        }
        else
        {
            rxDStat->specAddMatch = (0 != (wd1 & CEDI_RXD_SPEC_ADD_MAT))?1:0;
            rxDStat->extAddrMatch = (0 != (wd1 & CEDI_RXD_EXT_ADD_MAT))?1:0;
        }
        rxDStat->uniHashMatch = (0 != (wd1 & CEDI_RXD_UNI_HASH_MAT))?1:0;
        rxDStat->multiHashMatch = (0 != (wd1 & CEDI_RXD_MULTI_HASH_MAT))?1:0;
        rxDStat->broadcast = (0 != (wd1 & CEDI_RXD_BROADCAST_DET))?1:0;
    }
}

/* Provide the size of descriptor calculated for the current configuration.
 * @param pD - driver private state info specific to this instance
 * @param rxDescSize - pointer to Rx descriptor Size
 */
void emacGetRxDescSize(const CEDI_PrivateData *pD, uint32_t *rxDescSize)
{
    if ((pD!=NULL) && (rxDescSize!=NULL)) {
        *rxDescSize = pD->rxDescriptorSize;
    }
}

/* Get state of receiver
 * @param pD - driver private state info specific to this instance
 * @return 1 if enabled
 * @return 0 if disabled or pD==NULL
 */
uint32_t emacRxEnabled(CEDI_PrivateData *pD)
{
    uint32_t retVal;
    uint32_t reg;
    if (pD==NULL) {
        retVal = 0;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        retVal = (EMAC_REGS__NETWORK_CONTROL__ENABLE_RECEIVE__READ(reg));
    }
    return (retVal);
}

/* Enable the receive circuit.
 * @param pD - driver private state info specific to this instance
 */
void emacEnableRx(CEDI_PrivateData *pD)
{
    uint32_t reg;
    if (pD!=NULL) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__ENABLE_RECEIVE__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
}

/* Disable the receive circuit.
 * @param pD - driver private state info specific to this instance
 */
void emacDisableRx(CEDI_PrivateData *pD)
{
    uint32_t reg;
    if (pD!=NULL) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__ENABLE_RECEIVE__CLR(reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
}

/* Remove a buffer from the end of the receive buffer queue.  This function is
 * intended to be used when shutting down the driver, prior to deallocating the
 * receive buffers, and should not be called while Rx is enabled or unread
 * data remains in the queue.
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of the Rx queue (range 0 to rxQs-1)
 * @param buf - pointer to struct for returning virtual and physical addresses
 *  of buffer.
 * @return 0 if successful
 * @return EINVAL if invalid queueNum, ENOENT if no buffers left to free
 */
uint32_t emacRemoveRxBuf(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_BuffAddr *buf)
{
    uint32_t status = 0;
    uint32_t tmp;
    rxQueue_t *rxQ;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if (queueNum>=pD->rxQs) {
            vDbgMsg(DBG_GEN_MSG, 5, "Error: Invalid Rx queue number: %u\n", queueNum);
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (buf==NULL) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: NULL buf parameter");
            status = EINVAL;
        }
    }

    if (0 == status) {
        rxQ = &(pD->rxQueue[queueNum]);

        if (0==rxQ->numRxBufs) {
            status = ENOENT;
        }
    }

    if (0 == status) {
        /* skip "stop" descriptor since no buffer there */
        if ((rxQ->rxDescEnd==rxQ->rxDescStop) && (rxQ->rxDescEnd!=rxQ->rxDescStart))
        {
            moveRxDescAddr(&(rxQ->rxDescEnd), -(pD->rxDescriptorSize));
            rxQ->rxEndVA--;
        }

        /* get physical address */
        buf->pAddr = (uintptr_t)CPS_UncachedRead32(&(rxQ->rxDescEnd->word[0]))
                                                & CEDI_RXD_ADDR_MASK;
        /* get virtual address */
        buf->vAddr = *(rxQ->rxEndVA);

        /* dec end/tail pointers unless already at start of list */
        if (rxQ->rxDescEnd!=rxQ->rxDescStart) {
            moveRxDescAddr(&(rxQ->rxDescEnd), -(pD->rxDescriptorSize));
            rxQ->rxEndVA--;

            /* set wrap on new end descriptor */
            tmp = CPS_UncachedRead32(&(rxQ->rxDescEnd->word[0]));
            CPS_UncachedWrite32(&(rxQ->rxDescEnd->word[0]), tmp | CEDI_RXD_WRAP);
        }
        rxQ->numRxBufs--;
    }

    return (status);
}

void emacFindQBaseAddr(const CEDI_PrivateData *pD, uint8_t queueNum, rxQueue_t *rxQ,
                        uint32_t *pAddr, uintptr_t *vAddr) {
    uint8_t q = 0;
    uint32_t sumRxDescSize;
    /* find start addresses for this rxQ */
    *vAddr = pD->cfg.rxQAddr;
    *pAddr = pD->cfg.rxQPhyAddr;

    sumRxDescSize = (uint32_t)(rxQ->numRxDesc) * (uint32_t)(pD->rxDescriptorSize);

    if (queueNum>0) {
        rxQ->rxBufVAddr = (pD->rxQueue[0].rxBufVAddr);
    }
    while (q<queueNum) {
        *vAddr += (uintptr_t)sumRxDescSize;
        *pAddr += sumRxDescSize;
        rxQ->rxBufVAddr += rxQ->numRxDesc;
        q++;
    }
    vDbgMsg(DBG_GEN_MSG, 10, "%s: base address Q%u virt=%08lX phys=%08X vAddrList=%p\n",
            __func__, queueNum, *vAddr, *pAddr, rxQ->rxBufVAddr);
}
/* Reset Rx buffer descriptor list/ buffer virtual address list to initial
 * empty state, clearing all descriptors.  For use by init or after a fatal
 * error. Disables receive circuit.
 * @param pD - driver private state info specific to this instance
 * @param queueNum - number of the Rx queue (range 0 to rxQs-1)
 * @param ptrsOnly - if =1, then reset pointers and clearing used bits only
 *          after a link down/up event (assume buffers already assigned)
 *          if =0, initialise all list fields for this queue, including
 *          clearing buffer addresses
 * @return 0 if successful
 * @return EINVAL if invalid parameter
 */
uint32_t emacResetRxQ(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t ptrsOnly)
{
    uint32_t status = 0;
    uint32_t regTmp;
    uint16_t i;
    uint32_t pAddr;
    uintptr_t vAddr;
    rxDesc* descPtr;
    rxQueue_t *rxQ;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (ptrsOnly>1)) {
        status = EINVAL;
    }
    if (0 == status ) {
        if (queueNum>=pD->rxQs) {
            status = EINVAL;
        }
    }
    if (0 == status ) {
        emacDisableRx(pD);

        rxQ = &(pD->rxQueue[queueNum]);
        emacFindQBaseAddr(pD, queueNum, rxQ, &pAddr, &vAddr);

        /* want the virtual addresses here: */
        if (0 != ptrsOnly) {
            if (rxQ->rxDescStop!=rxQ->rxDescEnd) {
            /* copy buffer addresses from new "stop" descriptor to old one,
             * before reset pointers */
                CPS_UncachedWrite32((uint32_t *)&(rxQ->rxDescStop->word[0]),
                    CPS_UncachedRead32((uint32_t *)&(rxQ->rxDescEnd->word[0])));
                *(rxQ->rxStopVA) = *(rxQ->rxEndVA);
            }
        }
        else
        {
            rxQ->rxDescStart = rxDescAddrToPtr(vAddr);
            rxQ->rxDescEnd = rxDescAddrToPtr(vAddr);
        }
        rxQ->rxDescStop = rxDescAddrToPtr(vAddr);
        rxQ->rxDescTail = rxDescAddrToPtr(vAddr);
        rxQ->rxTailVA = rxQ->rxBufVAddr;
        rxQ->rxStopVA = rxQ->rxBufVAddr;
        if (0 == ptrsOnly) {
            rxQ->rxEndVA = rxQ->rxBufVAddr;
            *(rxQ->rxStopVA) = 0;
            rxQ->numRxBufs = 0;
        }

        /* full reset: clear used flags except stop & set wrap flag, only expand
         * available size as buffers are added - if ptrsOnly, then buffers already
         * in ring, preserve addresses & only clear used bits/wd1  */
        descPtr = rxQ->rxDescStart;
        for (i = 0; i<rxQ->numRxDesc; i++) {
            if (0 != ptrsOnly) {
                if (rxQ->rxDescStop==rxQ->rxDescEnd) {
                    CPS_UncachedWrite32((uint32_t *)&(rxQ->rxDescStop->word[0]),
                                              CEDI_RXD_WRAP|CEDI_RXD_USED );
                    CPS_UncachedWrite32(&(rxQ->rxDescStop->word[1]), CEDI_RXD_EMPTY);
                    *(rxQ->rxStopVA) = 0;
                }
                else
                {
                    pAddr = CPS_UncachedRead32((uint32_t *)&(rxQ->rxDescStop->word[0]));
                    CPS_UncachedWrite32((uint32_t *)&(rxQ->rxDescStop->word[0]),
                                        pAddr & ~(CEDI_RXD_WRAP|CEDI_RXD_USED));
                    CPS_UncachedWrite32(&(rxQ->rxDescStop->word[1]), CEDI_RXD_EMPTY);
                    /* inc stop pointer */
                    moveRxDescAddr(&(rxQ->rxDescStop), pD->rxDescriptorSize);
                    /* inc VA stop pointer */
                    rxQ->rxStopVA++;
                }
            }
            else {
                CPS_UncachedWrite32((uint32_t *)
                        &(descPtr->word[0]), (0 != i)?0:(CEDI_RXD_WRAP|CEDI_RXD_USED));
                CPS_UncachedWrite32((uint32_t *)
                        &(descPtr->word[1]), CEDI_RXD_EMPTY);
                moveRxDescAddr(&descPtr, pD->rxDescriptorSize);
            }
        }

        if (0 == ptrsOnly) {
            if (queueNum == 0) {
                regTmp = CPS_UncachedRead32(&(pD->regs->receive_q_ptr));
                /* write hardware base address register */\
                EMAC_REGS__RECEIVE_Q_PTR__DMA_RX_Q_PTR__MODIFY(regTmp, (pAddr >> 2));\
                CPS_UncachedWrite32(&(pD->regs->receive_q_ptr), regTmp);\
            }
                else {
                regPtr = receivePtrReg[queueNum-1];
                addRegBase(pD, &regPtr);
                regTmp = CPS_UncachedRead32(regPtr);
                EMAC_REGS__RECEIVE_Q_PTR__DMA_RX_Q_PTR__MODIFY(regTmp, pAddr>>2);
                CPS_UncachedWrite32(regPtr, regTmp);
            }
            }
    }
    return (status);
}

/* Return the content of EMAC receive status register
 * @param pD - driver private state info specific to this instance
 * @param status - pointer to struct with fields for each flag
 * @return =1 if any flags set, =0 if not or status=NULL.
 */
uint32_t emacGetRxStatus(CEDI_PrivateData *pD, CEDI_RxStatus *status)
{
    uint32_t retVal;
    uint32_t reg;
    if ((pD==NULL)||(status==NULL)) {
        retVal = 0;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->receive_status));

        status->buffNotAvail =
                EMAC_REGS__RECEIVE_STATUS__BUFFER_NOT_AVAILABLE__READ(reg);
        status->frameRx =
                EMAC_REGS__RECEIVE_STATUS__FRAME_RECEIVED__READ(reg);
        status->rxOverrun =
                EMAC_REGS__RECEIVE_STATUS__RECEIVE_OVERRUN__READ(reg);
        status->hRespNotOk =
                EMAC_REGS__RECEIVE_STATUS__RESP_NOT_OK__READ(reg);
        retVal = (0 != reg)?1:0;
    }

    return (retVal);
}

/* Reset the bits of EMAC receive status register as selected in resetStatus
 * @param pD - driver private state info specific to this instance
 * @param resetStatus - OR'd combination of CEDI_RXS_ bit-fields
 */
void emacClearRxStatus(CEDI_PrivateData *pD, uint32_t resetStatus)
{
    uint32_t reg = 0;
    if (pD!=NULL) {

        if (0 != (resetStatus & CEDI_RXS_NO_BUFF)) {
            reg |= CEDI_RXS_NO_BUFF;
        }

        if (0 != (resetStatus & CEDI_RXS_FRAME_RX)) {
            reg |= CEDI_RXS_FRAME_RX;
        }

        if (0 != (resetStatus & CEDI_RXS_OVERRUN)) {
            reg |= CEDI_RXS_OVERRUN;
        }

        if (0 != (resetStatus & CEDI_RXS_HRESP_ERR)) {
            reg |= CEDI_RXS_HRESP_ERR;
        }

        CPS_UncachedWrite32(&(pD->regs->receive_status), reg);
    }
}

/**
 *  Enable/disable header-data split feature.
 *  When enabled, frame L2/L3/L4 headers will written to separate
 *  buffer, before data starts in a second buffer (if not zero payload)
 */
uint32_t emacSetHdrDataSplit(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0;
    uint32_t reg;
    if ((pD==NULL) || (enable>1)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.hdr_split==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        reg = CPS_UncachedRead32(&(pD->regs->dma_config));
        if (0 != enable) {
            EMAC_REGS__DMA_CONFIG__HDR_DATA_SPLITTING_EN__SET(reg);
        } else {
            EMAC_REGS__DMA_CONFIG__HDR_DATA_SPLITTING_EN__CLR(reg);
        }

        CPS_UncachedWrite32(&(pD->regs->dma_config), reg);
    }
    return (status);
}

/**
 * Read enable/disable status for header-data split feature
 */
uint32_t emacGetHdrDataSplit(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.hdr_split==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        *enable = EMAC_REGS__DMA_CONFIG__HDR_DATA_SPLITTING_EN__READ(
                    CPS_UncachedRead32(&(pD->regs->dma_config)));
    }
    return (status);
}

/**
 *  Enable/disable Receive Segment Coalescing function.
 *  When enabled, consecutive TCP/IP frames on a priority queue
 *  will be combined to form a single large frame
 */
uint32_t emacSetRscEnable(CEDI_PrivateData *pD, uint8_t queue, uint8_t enable)
{
    uint32_t status = 0;
    uint32_t reg, enableField;
    uint8_t queueShift;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.pbuf_rsc==0) {
            status = ENOTSUP;
        }
    }
    if (0 == status) {
        if ((queue<1) || (queue>=(pD->rxQs)) || (enable>1)) {
            status = EINVAL;
        }
    }
    if (0 == status) {
        if (CEDI_MAC_TYPE_EMAC == pD->macType) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        queueShift = queue-1;

        reg = CPS_UncachedRead32(&(pD->regs->rsc_control));
        enableField = EMAC_REGS__RSC_CONTROL__RSC_CONTROL__READ(reg);

        if (queueShift < 15) {
            if (0 != enable) {
                enableField |= (1 << queueShift);
            } else {
                enableField &= ~(1 << queueShift);
            }
        }

        EMAC_REGS__RSC_CONTROL__RSC_CONTROL__MODIFY(reg, enableField);
        CPS_UncachedWrite32(&(pD->regs->rsc_control), reg);
    }

    return (status);
}

/**
 * Read enabled status of RSC on a specified priority queue
 */
uint32_t emacGetRscEnable(CEDI_PrivateData *pD, uint8_t queue, uint8_t *enable)
{
    uint32_t status = 0;
    uint32_t reg;
    uint8_t queueShift;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    }
    if (0 == status) {
        if ((queue<1) || (queue>=(pD->rxQs)) || (CEDI_MAC_TYPE_EMAC == pD->macType)) {
            status = EINVAL;
        }
    }
    if (0 == status) {
        if (pD->hwCfg.pbuf_rsc==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        queueShift = queue-1;

        reg = CPS_UncachedRead32(&(pD->regs->rsc_control));
        if (queueShift < 15) {
            *enable = (0 != (EMAC_REGS__RSC_CONTROL__RSC_CONTROL__READ(reg)
                                & (1<<queueShift)))?1:0;
        }
    }

    return (status);
}

/**
 *  Set/Clear Mask of Receive Segment Coalescing disabling.
 *  When mask is set and RSC is enabled, the RSC operation is not
 *  disabled by receipt of frame with an end-coalesce flag set
 *  (SYN/FIN/RST/URG)
 */
uint32_t emacSetRscClearMask(CEDI_PrivateData *pD, uint8_t setMask)
{
    uint32_t status = 0;
    uint32_t reg;
    if ((pD==NULL) || (setMask>1)) {
        status = EINVAL;
    }
    if (0 == status) {
        if ((pD->hwCfg.pbuf_rsc==0) || (CEDI_MAC_TYPE_EMAC == pD->macType)) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        reg = CPS_UncachedRead32(&(pD->regs->rsc_control));
        if (0 != setMask) {
            reg |= 0x10000U; /* (1 << 16) */
        } else {
            reg &= ~0x10000U; /* (1 << 16) */
        }
        CPS_UncachedWrite32(&(pD->regs->rsc_control), reg);
    }

    return (status);
}

uint32_t emacSetRxPartialStFwd(CEDI_PrivateData *pD, uint32_t watermark, uint8_t enable)
{
    uint32_t status = 0;
    uint32_t reg;
    uint32_t rx_pbuf_addr;
    if ((pD==NULL) || (enable>1)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.rx_pkt_buffer==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        rx_pbuf_addr = pD->hwCfg.rx_pbuf_addr;
        if (rx_pbuf_addr < 16) {
            if (watermark>((1<<rx_pbuf_addr)-1)) {
                status = EINVAL;
            }
        } else {
            vDbgMsg(DBG_GEN_MSG, 10, "%s\n",
                    "Warning: Wrong rx_pbuf_addr read from hardware");
            status = EINVAL;
        }
    }

    if (0 == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pbuf_rxcutthru));
        if (0 != enable) {
            EMAC_REGS__PBUF_RXCUTTHRU__DMA_RX_CUTTHRU_THRESHOLD__MODIFY(reg,
                    watermark);
            EMAC_REGS__PBUF_RXCUTTHRU__DMA_RX_CUTTHRU__SET(reg);
        } else {
            EMAC_REGS__PBUF_RXCUTTHRU__DMA_RX_CUTTHRU__CLR(reg);
        }

        CPS_UncachedWrite32(&(pD->regs->pbuf_rxcutthru), reg);
    }

    return (status);
}

uint32_t emacGetRxPartialStFwd(CEDI_PrivateData *pD, uint32_t *watermark, uint8_t *enable)
{
    uint32_t status = 0;
    uint32_t reg;
    if ((pD==NULL)||(enable==NULL)||(watermark==NULL)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.rx_pkt_buffer==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pbuf_rxcutthru));
        (*enable) = EMAC_REGS__PBUF_RXCUTTHRU__DMA_RX_CUTTHRU__READ(reg);

        if (0 != (*enable)) {
            *watermark =
                    EMAC_REGS__PBUF_RXCUTTHRU__DMA_RX_CUTTHRU_THRESHOLD__READ(reg);
        }
    }

    return (status);
}

/******************************** Rx Filtering ******************************/

  /**
   * Set specific address register to the given address value
   * @param[in] pD driver private state info specific to this instance
   * @param[in] addrNum number of specific address filters,
   *                in range 1 - num_spec_add_filters.
   *    $RANGE $FROM 1 $TO CEDI_DesignCfg.num_spec_add_filters$
   * @param[in] addr pointer to the 6-byte MAC address value to write
   * @param[in] specFilterType flag specifying whether to use MAC source or
   *    destination address to be compared for filtering. Source filter when =1.
   *    $RANGE $FROM 0 $TO 1 $
   * @param[in] byteMask  Bits masking out bytes of specific address from
   *    comparison.  When high, the associated address byte will be ignored.
   *    e.g. LSB of byteMask=1 implies first byte received should not be compared
   *    Ignored if addrNum=1, full bit masking available (SpecificAddr1Mask)
   *    $RANGE $FROM 0 $TO 0x3F $TEST_SUBSET 4 $
   * @return 0 if successful,
   * @return EINVAL if pD, addrNum, specFilterType or byteMask invalid
   * @return ENOTSUP if CEDI_DesignCfg.num_spec_add_filters==0
   */
uint32_t emacSetSpecificAddr(CEDI_PrivateData *pD, uint8_t addrNum, const CEDI_MacAddress *addr,
                            uint8_t specFilterType, uint8_t byteMask)
{
    uint32_t status = 0;
    uint32_t regVal;
    volatile uint32_t *bottomPtr = NULL;
    volatile uint32_t *topPtr = NULL;
    if ((!pD) || (addr==NULL) || (specFilterType>1) || (byteMask>0x3F)) {
        status = EINVAL;
    }
    if (0 == status) {
        if ((!addrNum) || (addrNum>(pD->hwCfg.num_spec_add_filters))) {
            status = EINVAL;
        }
    }
    if (0 == status) {
        if (pD->hwCfg.num_spec_add_filters==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        regVal = 0;

        bottomPtr = specAddBottomReg[addrNum-1];
        addRegBase(pD, &bottomPtr);

        topPtr = specAddTopReg[addrNum-1];
        addRegBase(pD, &topPtr);

        EMAC_REGS__SPEC_ADD_BOTTOM__ADDRESS__MODIFY(regVal,
                          (uint32_t)(addr->byte[0]) +
                          ((uint32_t)(addr->byte[1])<<8) +
                          ((uint32_t)(addr->byte[2])<<16) +
                          ((uint32_t)(addr->byte[3])<<24));
        CPS_UncachedWrite32(bottomPtr, regVal);

        regVal = 0;
        if (1 == addrNum) {
            EMAC_REGS__SPEC_ADD_TOP_NO_MASK__ADDRESS__MODIFY(regVal,
                (uint32_t)(addr->byte[4]) + ((uint32_t)(addr->byte[5])<<8));
            EMAC_REGS__SPEC_ADD_TOP_NO_MASK__FILTER_TYPE__MODIFY(regVal,
                specFilterType);
        } else {
            EMAC_REGS__SPEC_ADD_TOP__ADDRESS__MODIFY(regVal,
                (uint32_t)(addr->byte[4]) + ((uint32_t)(addr->byte[5])<<8));
            EMAC_REGS__SPEC_ADD_TOP__FILTER_TYPE__MODIFY(regVal,
                specFilterType);
            EMAC_REGS__SPEC_ADD_TOP__FILTER_BYTE_MASK__MODIFY(regVal, byteMask);
        }
        CPS_UncachedWrite32(topPtr, regVal);
    }

    return (status);
}

  /**
   * Get the value of a specific address register
   * @param[in] pD driver private state info specific to this instance
   * @param[in] addrNum number of specific address filters, in
   *                range 1 - num_spec_add_filters
   * @param[out] specFilterType flag specifying whether to use MAC source or
   *    destination address for filtering. When set to 1 use source address.
   * @param[out] byteMask Bits masking out bytes of specific address from
   *    comparison.  When high, the associated address byte will be ignored.
   *    e.g. LSB of byteMask=1 implies first byte received should not be compared
   *    Ignored if addrNum=1, full bit masking available (SpecificAddr1Mask)
   * @param[out] addr pointer to a 6-byte MAC address struct for returning the
   *    address value
   * @return 0 if successful
   * @return EINVAL if pD, addrNum, specFilterType or byteMask invalid
   * @return ENOTSUP if CEDI_DesignCfg.num_spec_add_filters==0
   */
uint32_t emacGetSpecificAddr(CEDI_PrivateData *pD, uint8_t addrNum, CEDI_MacAddress *addr,
                        uint8_t *specFilterType, uint8_t *byteMask)
{
    uint32_t status = 0;
    volatile uint32_t *bottomPtr = NULL;
    volatile uint32_t *topPtr = NULL;
    uint32_t regAddrTop, regAddrBottom, regTopVal;

    if ((pD==NULL)||(addr==NULL) || (specFilterType==NULL)||(byteMask==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (pD->hwCfg.num_spec_add_filters==0) {
            status = ENOTSUP;
        }
    }
    if (0 == status) {
        if ((!addrNum) || (addrNum>(pD->hwCfg.num_spec_add_filters))) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        regAddrTop = 0;
        regAddrBottom = 0;

        bottomPtr = specAddBottomReg[addrNum-1];
        addRegBase(pD, &bottomPtr);

        topPtr = specAddTopReg[addrNum-1];
        addRegBase(pD, &topPtr);

        regAddrBottom = EMAC_REGS__SPEC_ADD_BOTTOM__ADDRESS__READ(
            CPS_UncachedRead32(bottomPtr));
        regTopVal = CPS_UncachedRead32(topPtr);
        if (1 == addrNum) {
            regAddrTop = EMAC_REGS__SPEC_ADD_TOP_NO_MASK__ADDRESS__READ(
                regTopVal);
            *specFilterType =
                EMAC_REGS__SPEC_ADD_TOP_NO_MASK__FILTER_TYPE__READ(regTopVal);
            *byteMask = 0;
        } else {
            regAddrTop = EMAC_REGS__SPEC_ADD_TOP__ADDRESS__READ(regTopVal);
            *specFilterType =
                EMAC_REGS__SPEC_ADD_TOP__FILTER_TYPE__READ(regTopVal);
            *byteMask =
                EMAC_REGS__SPEC_ADD_TOP__FILTER_BYTE_MASK__READ(regTopVal);}

        addr->byte[0] = (regAddrBottom & 0xFF);
        addr->byte[1] = ((regAddrBottom>>8) & 0xFF);
        addr->byte[2] = ((regAddrBottom>>16) & 0xFF);
        addr->byte[3] = ((regAddrBottom>>24) & 0xFF);
        addr->byte[4] = (regAddrTop & 0xFF);
        addr->byte[5] = ((regAddrTop>>8) & 0xFF);
    }
    return (status);
}

/* Set the specific address 1 mask register to the given value, allowing
 * address matching against a portion of the specific address 1 register
 * @param pD - driver private state info specific to this instance
 * @param mask - pointer to the address mask value to write
 * @return 0 if successful
 * @return EINVAL if mask=NULL
 * @return ENOTSUP if CEDI_DesignCfg.num_spec_add_filters==0
 */
uint32_t emacSetSpecificAddr1Mask(CEDI_PrivateData *pD, const CEDI_MacAddress *mask)
{
    uint32_t status = 0;
    uint32_t reg;

    if ((pD==NULL) || (mask==NULL)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.num_spec_add_filters==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        reg = 0;
        EMAC_REGS__MASK_ADD1_BOTTOM__ADDRESS_MASK__MODIFY(reg,
                ((uint32_t)(mask->byte[0]) +
                ((uint32_t)(mask->byte[1])<<8) +
                ((uint32_t)(mask->byte[2])<<16) +
                ((uint32_t)(mask->byte[3])<<24)));
        CPS_UncachedWrite32((&(pD->regs->mask_add1_bottom)), reg);
        reg = 0;
        EMAC_REGS__MASK_ADD1_TOP__ADDRESS_MASK__MODIFY(reg,
                (uint32_t)(mask->byte[4]) +
                ((uint32_t)(mask->byte[5])<<8));
        CPS_UncachedWrite32((&(pD->regs->mask_add1_top)), reg);
    }
    return (status);
}

/* Get the value of the specific address 1 mask register
 * @param pD - driver private state info specific to this instance
 * @param mask - pointer to a 6-byte MAC address struct for returning the
 *    mask value
 * @return 0 if successful, EINVAL if addrNum invalid
 * @return ENOTSUP if CEDI_DesignCfg.num_spec_add_filters==0
 */
uint32_t emacGetSpecificAddr1Mask(CEDI_PrivateData *pD, CEDI_MacAddress *mask)
{
    uint32_t status = 0;
    uint32_t reg1, reg2;
    if ((pD==NULL)||(mask==NULL)) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.num_spec_add_filters==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        reg1 = EMAC_REGS__MASK_ADD1_BOTTOM__ADDRESS_MASK__READ(
                CPS_UncachedRead32(&(pD->regs->mask_add1_bottom)));
        reg2 = EMAC_REGS__MASK_ADD1_TOP__ADDRESS_MASK__READ(
                CPS_UncachedRead32(&(pD->regs->mask_add1_top)));

        mask->byte[0] = (reg1 & 0xFF);
        mask->byte[1] = ((reg1>>8) & 0xFF);
        mask->byte[2] = ((reg1>>16) & 0xFF);
        mask->byte[3] = ((reg1>>24) & 0xFF);
        mask->byte[4] = (reg2 & 0xFF);
        mask->byte[5] = ((reg2>>8) & 0xFF);
    }
    return (status);
}

/* Disable the specific address match stored at given register, by writing 0
 * to lower address register
 * @param pD - driver private state info specific to this instance
 * @param addrNum -
 *    number of specific address filters, in range 1 - num_spec_add_filters
 *    $RANGE $FROM 1 $TO CEDI_DesignCfg.num_spec_add_filters$
 * @return 0 if successful
 * @return EINVAL if invalid parameter
 * @return ENOTSUP if CEDI_DesignCfg.num_spec_add_filters==0
 */
uint32_t emacDisableSpecAddr(CEDI_PrivateData *pD, uint8_t addrNum)
{
    uint32_t status = 0;
    volatile uint32_t *bottomPtr = NULL;

    if (pD==NULL) {
        status = EINVAL;
    }
    if (0 == status) {
        if (pD->hwCfg.num_spec_add_filters==0) {
            status = ENOTSUP;
        }
    }
    if (0 == status) {
        if ((!addrNum) || (addrNum>(pD->hwCfg.num_spec_add_filters))) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        bottomPtr = specAddBottomReg[addrNum-1];
        addRegBase(pD, &bottomPtr);

        CPS_UncachedWrite32(bottomPtr, 0);
    }

    return (status);
}

/**
 * En/Disable Type ID match field of the specified register, and set
 * type Id value if enabling
 * @param[in] pD driver private state info specific to this instance
 * @param[in] matchSel number of TypeID Match register, range 1 - 4
 *    $RANGE $FROM 1 $TO 4$
 * @param[in] typeId the Type ID match value to write,
 *    ignored if enable equal 0
 * @param[in] enable if equal 1 enables the type matching for this ID,
 *    if 0 then disables type matching for this ID
 *    $RANGE $FROM 0 $TO 1$
 * @return 0 if successful,
 * @return EINVAL if matchSel invalid
 * $VALIDFAIL if ((enable==0)&&((matchSel<1)||(matchSel>4)))
 *  $EXPECT_RETURN EINVAL $
 */
uint32_t emacSetTypeIdMatch(CEDI_PrivateData *pD, uint8_t matchSel, uint16_t typeId,
        uint8_t enable)
{
    uint32_t status = 0;
    uint32_t regVal = 0;
    if ((pD==NULL) || (matchSel<1) || (matchSel>4) || (enable>1)) {
        status = EINVAL;
    } else {
        switch (matchSel) {
        case 1:
            if (0 != enable) {
                EMAC_REGS__SPEC_TYPE1__ENABLE_COPY__SET(regVal);
                EMAC_REGS__SPEC_TYPE1__MATCH__MODIFY(regVal, typeId);
            }
            CPS_UncachedWrite32(&(pD->regs->spec_type1), regVal);
            break;
        case 2:
            if (0 != enable) {
                EMAC_REGS__SPEC_TYPE2__ENABLE_COPY__SET(regVal);
                EMAC_REGS__SPEC_TYPE2__MATCH__MODIFY(regVal, typeId);
            }
            CPS_UncachedWrite32(&(pD->regs->spec_type2), regVal);
            break;
        case 3:
            if (0 != enable) {
                EMAC_REGS__SPEC_TYPE3__ENABLE_COPY__SET(regVal);
                EMAC_REGS__SPEC_TYPE3__MATCH__MODIFY(regVal, typeId);
            }
            CPS_UncachedWrite32(&(pD->regs->spec_type3), regVal);
            break;
        case 4:
            if (0 != enable) {
                EMAC_REGS__SPEC_TYPE4__ENABLE_COPY__SET(regVal);
                EMAC_REGS__SPEC_TYPE4__MATCH__MODIFY(regVal, typeId);
            }
            CPS_UncachedWrite32(&(pD->regs->spec_type4), regVal);
            break;
        default:
            status = EINVAL;
            break;
        }
    }

    return (status);
}

/* Read the specified Type ID match register settings
 * @param pD - driver private state info specific to this instance
 * @param matchSel  - number of TypeID Match register, range 1 - 4
 * @param typeId - pointer for returning the Type ID match value read,
 *              ignored if disabled
 * @param enabled - pointer for returning enabled status: if value returned <>0
 *             then typeId matching is enabled for this register, else disabled
 * @return 0 if successful, EINVAL if invalid parameter
 */
uint32_t emacGetTypeIdMatch(CEDI_PrivateData *pD, uint8_t matchSel, uint16_t *typeId,
        uint8_t *enabled)
{
    uint32_t status = 0;
    uint32_t regVal = 0;

    if ((pD==NULL) || (matchSel<1) || (matchSel>4) || (enabled==NULL)) {
        status = EINVAL;
    }
    if (0 == status) {
        if ((*enabled) && (typeId==NULL)) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        switch (matchSel) {
        case 1:
            regVal = CPS_UncachedRead32(&(pD->regs->spec_type1));
            *enabled = EMAC_REGS__SPEC_TYPE1__ENABLE_COPY__READ(regVal);
            *typeId = EMAC_REGS__SPEC_TYPE1__MATCH__READ(regVal);
            break;
        case 2:
            regVal = CPS_UncachedRead32(&(pD->regs->spec_type2));
            *enabled = EMAC_REGS__SPEC_TYPE2__ENABLE_COPY__READ(regVal);
            *typeId = EMAC_REGS__SPEC_TYPE2__MATCH__READ(regVal);
            break;
        case 3:
            regVal = CPS_UncachedRead32(&(pD->regs->spec_type3));
            *enabled = EMAC_REGS__SPEC_TYPE3__ENABLE_COPY__READ(regVal);
            *typeId = EMAC_REGS__SPEC_TYPE3__MATCH__READ(regVal);
            break;
        case 4:
            regVal = CPS_UncachedRead32(&(pD->regs->spec_type4));
            *enabled = EMAC_REGS__SPEC_TYPE4__ENABLE_COPY__READ(regVal);
            *typeId = EMAC_REGS__SPEC_TYPE4__MATCH__READ(regVal);
            break;
        default:
            status = EINVAL;
            break;
        }
    }

    return (status);
}

/* En/disable reception of unicast frames when hash register matched
 * @param pD - driver private state info specific to this instance
 * @param enable if<>0, enables reception, else disables
 */
void emacSetUnicastEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0 != enable) {
            EMAC_REGS__NETWORK_CONFIG__UNICAST_HASH_ENABLE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__UNICAST_HASH_ENABLE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

/* Return state of unicast frame matching
 * @param pD - driver private state info specific to this instance
 * @return  =0 if disabled, =1 if enabled
 */
uint32_t emacGetUnicastEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0;
    if ((pD==NULL)||(enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= EMAC_REGS__NETWORK_CONFIG__UNICAST_HASH_ENABLE__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}

/* En/disable reception of multicast frames when hash register matched
 * @param pD - driver private state info specific to this instance
 * @param enable if<>0, enables, else disables
 */
void emacSetMulticastEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0 != enable) {
            EMAC_REGS__NETWORK_CONFIG__MULTICAST_HASH_ENABLE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__MULTICAST_HASH_ENABLE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

/* Return state of multicast frame matching
 * @param pD - driver private state info specific to this instance
 * @return =0 if disabled, =1 if enabled
 */
uint32_t emacGetMulticastEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0;
    if ((pD==NULL)||(enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= EMAC_REGS__NETWORK_CONFIG__MULTICAST_HASH_ENABLE__READ(
            CPS_UncachedRead32(&(pD->regs->network_config)));
    }
    return (status);
}

/* Dis/Enable receipt of broadcast frames
 * @param pD - driver private state info specific to this instance
 * @param reject if =0 broadcasts are accepted, else they are rejected.
 */
void emacSetNoBroadcast(CEDI_PrivateData *pD, uint8_t reject)
{
    uint32_t reg;
    if (pD!=NULL) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0 != reject) {
            EMAC_REGS__NETWORK_CONFIG__NO_BROADCAST__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__NO_BROADCAST__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

/* Return broadcast rejection setting
 * @param pD - driver private state info specific to this instance
 * @return if =0, broadcasts being accepted, else rejected
 */
uint32_t emacGetNoBroadcast(CEDI_PrivateData *pD, uint8_t *reject)
{
    uint32_t status = 0;
    if ((pD==NULL)||(reject==NULL)) {
        status = EINVAL;
    } else {
        *reject= EMAC_REGS__NETWORK_CONFIG__NO_BROADCAST__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}

/* En/Disable receipt of only frames which have been VLAN tagged
 * @param pD - driver private state info specific to this instance
 * @param enable<>0 to reject non-VLAN-tagged frames.
 */
void emacSetVlanOnly(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0 != enable) {
            EMAC_REGS__NETWORK_CONFIG__DISCARD_NON_VLAN_FRAMES__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__DISCARD_NON_VLAN_FRAMES__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

/* Return VLAN-tagged filter setting
 * @param pD - driver private state info specific to this instance
 * @return <>0 if VLAN-only, else accept non-VLAN tagged frames
 */
uint32_t emacGetVlanOnly(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0;
    if ((pD==NULL)||(enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= EMAC_REGS__NETWORK_CONFIG__DISCARD_NON_VLAN_FRAMES__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}

/* En/Disable stacked VLAN processing mode.
 * @param pD - driver private state info specific to this instance
 * @param enable - if <>0 enables stacked VLAN processing, if =0 disables it
 * @param vlanType - sets user defined VLAN type for matching first VLAN tag.
 *    Ignored if enable =0.
 */
void emacSetStackedVlanReg(CEDI_PrivateData *pD, uint8_t enable, uint16_t vlanType)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->stacked_vlan));
        if (0 != enable) {
            EMAC_REGS__STACKED_VLAN__ENABLE_PROCESSING__SET(reg);
            EMAC_REGS__STACKED_VLAN__MATCH__MODIFY(reg, vlanType);
        }
        else
        {
            EMAC_REGS__STACKED_VLAN__ENABLE_PROCESSING__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->stacked_vlan), reg);
    }
}

/* Reads stacked VLAN register settings.
 * @param pD - driver private state info specific to this instance
 * @param enable - pointer for returning Enabled field: =1 if enabled, =0 if
 *    disabled.
 * @param vlanType - pointer for returning VLAN type field
 *
 */
void emacGetStackedVlanReg(CEDI_PrivateData *pD, uint8_t *enable, uint16_t *vlanType)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable!=NULL) && (vlanType!=NULL)) {
        reg = CPS_UncachedRead32(&(pD->regs->stacked_vlan));
        *enable = EMAC_REGS__STACKED_VLAN__ENABLE_PROCESSING__READ(reg);
        *vlanType = EMAC_REGS__STACKED_VLAN__MATCH__READ(reg);
    }
}

/* En/Disable copy all frames mode
 * @param pD - driver private state info specific to this instance
 * @param enable - if <>0, enables copy all frames mode, else this is
 *    disabled
 */
void emacSetCopyAllFrames(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0 != enable) {
            EMAC_REGS__NETWORK_CONFIG__COPY_ALL_FRAMES__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__COPY_ALL_FRAMES__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

/* Get "copy all" setting
 * @param pD - driver private state info specific to this instance
 * @return =0 if disabled, =1 if enabled
 */
uint32_t emacGetCopyAllFrames(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0;
    if ((pD==NULL)||(enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= EMAC_REGS__NETWORK_CONFIG__COPY_ALL_FRAMES__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}

/* Set the hash address register.
 * @param pD - driver private state info specific to this instance
 * @param hAddrTop  -  most significant 32 bits of hash register
 * @param hAddrBot  - least significant 32 bits of hash register
 * @return EINVAL if pD=NULL, else 0.
 */
uint32_t emacSetHashAddr(CEDI_PrivateData *pD, uint32_t hAddrTop, uint32_t hAddrBot)
{
    uint32_t status = 0;
    if (pD==NULL)  {
        status = EINVAL;
    } else {
        CPS_UncachedWrite32(&(pD->regs->hash_bottom),
                EMAC_REGS__HASH_BOTTOM__ADDRESS__WRITE(hAddrBot));
        CPS_UncachedWrite32(&(pD->regs->hash_top),
                EMAC_REGS__HASH_TOP__ADDRESS__WRITE(hAddrTop));
    }
    return (status);
}

/* Read the hash address register.
 * @param pD - driver private state info specific to this instance
 * @param hAddrTop  -  pointer for returning most significant 32 bits of
 *    hash register
 * @param hAddrBot  - pointer for returning least significant 32 bits of
 *    hash register
 * @return EINVAL if any parameter =NULL, else 0.
 */
uint32_t emacGetHashAddr(CEDI_PrivateData *pD, uint32_t *hAddrTop, uint32_t *hAddrBot)
{
    uint32_t status = 0;
    if ((pD==NULL) || (hAddrTop==NULL) || (hAddrBot==NULL)) {
        status = EINVAL;
    } else {
        *hAddrBot = EMAC_REGS__HASH_BOTTOM__ADDRESS__READ(
                    CPS_UncachedRead32(&(pD->regs->hash_bottom)));
        *hAddrTop = EMAC_REGS__HASH_TOP__ADDRESS__READ(
                    CPS_UncachedRead32(&(pD->regs->hash_top)));
    }
    return (status);
}

/* Enable/disable discard of frames with length shorter than given in length
 * field
 * @param pD - driver private state info specific to this instance
 * @param enable - if <>1 then enable, else disable.
 */
void emacSetLenErrDiscard(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0 != enable) {
            EMAC_REGS__NETWORK_CONFIG__LENGTH_FIELD_ERROR_FRAME_DISCARD__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__LENGTH_FIELD_ERROR_FRAME_DISCARD__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

/* Read enable/disable status for discard of frames with length shorter than
 * given in length field.
 * @param pD - driver private state info specific to this instance
 * @return 1 if enabled, 0 if disabled.
 */
uint32_t emacGetLenErrDiscard(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= EMAC_REGS__NETWORK_CONFIG__LENGTH_FIELD_ERROR_FRAME_DISCARD__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }
    return (status);
}

/******************************** Rx Priority Queues ******************************/

/* Return the numbers of screener, ethtype & compare registers present
 * @param pD - driver private state info specific to this instance
 * @param regNums - points to a CEDI_NumScreeners struct with the match parameters
 *    to be written
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacGetNumScreenRegs(const CEDI_PrivateData *pD, CEDI_NumScreeners *regNums)
{
    uint32_t status = 0;
    if ((pD==NULL) || (regNums==NULL)) {
        status = EINVAL;
    } else {
        getNumScreenRegs(pD, regNums);
    }
    return (status);
}


/* Write Rx frame matching values to a Type 1 screening register, for allocating
 * to a priority queue.
 * @param pD - driver private state info specific to this instance
 * @param regNum - the Type 1 register number, range 0 to num_type1_screeners-1
 * @param regVals - points to a CEDI_T1Screen struct with the match parameters
 *    to be written
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacSetType1ScreenReg(CEDI_PrivateData *pD, uint8_t regNum, const CEDI_T1Screen *regVals)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (regVals==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (pD->hwCfg.num_type1_screeners==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if ((regNum>=pD->hwCfg.num_type1_screeners) ||
            (regVals->qNum>=pD->rxQs) ||
            (regVals->udpEnable>1) || (regVals->dstcEnable>1)) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        regPtr = type1ScreeningReg[regNum];
        addRegBase(pD, &regPtr);
	reg = CPS_UncachedRead32(regPtr);

        EMAC_REGS__SCREENING_TYPE_1_REGISTER__QUEUE_NUMBER__MODIFY(reg,
                                                                regVals->qNum);
        EMAC_REGS__SCREENING_TYPE_1_REGISTER__DSTC_ENABLE__MODIFY(reg,
                                                            regVals->dstcEnable);
        EMAC_REGS__SCREENING_TYPE_1_REGISTER__DSTC_MATCH__MODIFY(reg,
                                                            regVals->dstcMatch);
        EMAC_REGS__SCREENING_TYPE_1_REGISTER__UDP_PORT_MATCH_ENABLE__MODIFY(reg,
                                                        regVals->udpEnable);
        EMAC_REGS__SCREENING_TYPE_1_REGISTER__UDP_PORT_MATCH__MODIFY(reg,
                                                            regVals->udpPort);

        CPS_UncachedWrite32(regPtr, reg);
    }

    return (status);
}

uint8_t isIngressTrafficSupported(CEDI_PrivateData* pD)
{
    return IsGem1p11(pD);
}

/* Read Rx frame matching values from a Type1 screening register
 * @param pD - driver private state info specific to this instance
 * @param regNum - the Type 1 register number, range 0 to num_type1_screeners-1
 * @param regVals - points to a CEDI_T1Screen struct for returning the match
 *    parameters
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacGetType1ScreenReg(CEDI_PrivateData *pD, uint8_t regNum, CEDI_T1Screen *regVals)
{
    uint32_t status = 0;
    uint32_t reg = 0;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (regVals==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (pD->hwCfg.num_type1_screeners==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type1_screeners) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        regPtr = type1ScreeningReg[regNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);

        regVals->qNum =
                EMAC_REGS__SCREENING_TYPE_1_REGISTER__QUEUE_NUMBER__READ(reg);
        regVals->dstcMatch =
                EMAC_REGS__SCREENING_TYPE_1_REGISTER__DSTC_MATCH__READ(reg);
        regVals->udpPort =
                EMAC_REGS__SCREENING_TYPE_1_REGISTER__UDP_PORT_MATCH__READ(reg);
        regVals->dstcEnable =
                EMAC_REGS__SCREENING_TYPE_1_REGISTER__DSTC_ENABLE__READ(reg);
        regVals->udpEnable =
                EMAC_REGS__SCREENING_TYPE_1_REGISTER__UDP_PORT_MATCH_ENABLE__READ(
                        reg);
    }
    return (status);
}

/* Write Rx frame matching values to a Type 2 screening register, for
 * allocating to a priority queue.
 * @param pD - driver private state info specific to this instance
 * @param regNum - the Type 2 register number, range 0 to num_type2_screeners-1
 * @param regVals - points to a CEDI_T2Screen struct with the match
 *    parameters to be written
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacSetType2ScreenReg(CEDI_PrivateData *pD, uint8_t regNum, const CEDI_T2Screen *regVals)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (regVals==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (pD->hwCfg.num_type2_screeners==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type2_screeners) {
            status = EINVAL;
        }
        if (regVals->qNum>=pD->rxQs) {
            status = EINVAL;
        }

        if (regVals->vlanEnable>1) {
            status = EINVAL;
        }
        if ((0 != regVals->vlanEnable) && (regVals->vlanPriority>=8)) {
            status = EINVAL;
        }

        if (regVals->eTypeEnable>1) {
            status = EINVAL;
        }
        if ((0 != regVals->eTypeEnable) && (regVals->ethTypeIndex>=8)) {
            status = EINVAL;
        }
        if ((0 != regVals->eTypeEnable) &&
                  (regVals->ethTypeIndex>=pD->hwCfg.num_scr2_ethtype_regs)) {
            status = EINVAL;
        }

        if (regVals->compAEnable>1)  {
            status = EINVAL;
        }
        if ((0 != regVals->compAEnable) && (regVals->compAIndex>=32)) {
            status = EINVAL;
        }
        if ((0 != regVals->compAEnable) &&
                  (regVals->compAIndex>=pD->hwCfg.num_scr2_compare_regs)) {
            status = EINVAL;
        }

        if (regVals->compBEnable>1) {
            status = EINVAL;
        }
        if ((0 != regVals->compBEnable) && (regVals->compBIndex>=32)) {
            status = EINVAL;
        }
        if ((0 != regVals->compBEnable) &&
                  (regVals->compBIndex>=pD->hwCfg.num_scr2_compare_regs)) {
            status = EINVAL;
        }

        if (regVals->compCEnable>1) {
            status = EINVAL;
        }
        if ((0 != regVals->compCEnable) && (regVals->compCIndex>=32)) {
            status = EINVAL;
        }
        if ((0 != regVals->compCEnable) &&
                  (regVals->compCIndex>=pD->hwCfg.num_scr2_compare_regs)) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        regPtr = type2ScreeningReg[regNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);

        EMAC_REGS__SCREENING_TYPE_2_REGISTER__QUEUE_NUMBER__MODIFY(reg,
                                                                regVals->qNum);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__VLAN_ENABLE__MODIFY(reg,
                                                        regVals->vlanEnable);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__VLAN_PRIORITY__MODIFY(reg,
                                                        regVals->vlanPriority);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__ETHERTYPE_ENABLE__MODIFY(reg,
                                                        regVals->eTypeEnable);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__ETHERTYPE_REG_INDEX__MODIFY(reg,
                                                        regVals->ethTypeIndex);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_A_ENABLE__MODIFY(reg,
                                                        regVals->compAEnable);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_A__MODIFY(reg,
                                                        regVals->compAIndex);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_B_ENABLE__MODIFY(reg,
                                                        regVals->compBEnable);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_B__MODIFY(reg,
                                                        regVals->compBIndex);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_C_ENABLE__MODIFY(reg,
                                                        regVals->compCEnable);
        EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_C__MODIFY(reg,
                                                        regVals->compCIndex);

        CPS_UncachedWrite32(regPtr, reg);
    }

    return (status);
}

/* Read Rx frame matching values from a Type 2 screening register
 * @param pD - driver private state info specific to this instance
 * @param regNum - the Type 2 register number, range 0 to num_type2_screeners-1
 * @param regVals - points to a CEDI_T2Screen struct for returning the match
 *    parameters
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacGetType2ScreenReg(CEDI_PrivateData *pD, uint8_t regNum, CEDI_T2Screen *regVals)
{
    uint32_t status = 0;
    uint32_t reg = 0;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL)||(regVals==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (pD->hwCfg.num_type2_screeners==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type2_screeners) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        regPtr = type2ScreeningReg[regNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);

        regVals->qNum =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__QUEUE_NUMBER__READ(reg);
        regVals->vlanPriority =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__VLAN_PRIORITY__READ(reg);
        regVals->vlanEnable =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__VLAN_ENABLE__READ(reg);
        regVals->ethTypeIndex =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__ETHERTYPE_REG_INDEX__READ(reg);
        regVals->eTypeEnable =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__ETHERTYPE_ENABLE__READ(reg);
        regVals->compAIndex =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_A__READ(reg);
        regVals->compAEnable =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_A_ENABLE__READ(reg);
        regVals->compBIndex =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_B__READ(reg);
        regVals->compBEnable =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_B_ENABLE__READ(reg);
        regVals->compCIndex =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_C__READ(reg);
        regVals->compCEnable =
                EMAC_REGS__SCREENING_TYPE_2_REGISTER__COMPARE_C_ENABLE__READ(reg);
    }
    return (status);
}

/* Write the ethertype compare value at the given index in the Ethertype
 * registers
 * @param pD - driver private state info specific to this instance
 * @param index - number of screener Type 2 Ethertype compare register to
 *    write, range 0 to num_scr2_ethtype_regs-1
 * @param eTypeVal - Ethertype compare value to write
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacSetType2EthertypeReg(CEDI_PrivateData *pD, uint8_t index, uint16_t eTypeVal)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if ((pD->hwCfg.num_type2_screeners==0) ||
                (pD->hwCfg.num_scr2_ethtype_regs==0)) {
        status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (index>=pD->hwCfg.num_scr2_ethtype_regs) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        reg = 0;
        EMAC_REGS__SCREENING_TYPE_2_ETHERTYPE_REG__COMPARE_VALUE__MODIFY(reg,
                                                                        eTypeVal);

        regPtr = type2ScreeningEthertypeReg[index];
        addRegBase(pD, &regPtr);
        CPS_UncachedWrite32(regPtr, reg);
    }

    return (status);
}

/* Read the ethertype compare value at the given index in the Ethertype
 * registers
 * @param pD - driver private state info specific to this instance
 * @param index - number of screener Type 2 Ethertype compare register to
 *    read, range 0 to num_scr2_ethtype_regs-1
 * @param eTypeVal - pointer for returning the Ethertype compare value
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacGetType2EthertypeReg(CEDI_PrivateData *pD, uint8_t index, uint16_t *eTypeVal)
{
    uint32_t status = 0;
    uint32_t reg = 0;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL)||(eTypeVal==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if ((pD->hwCfg.num_type2_screeners==0) ||
                (pD->hwCfg.num_scr2_ethtype_regs==0)) {
        status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (index>=pD->hwCfg.num_scr2_ethtype_regs) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        regPtr = type2ScreeningEthertypeReg[index];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);

        *eTypeVal = (uint16_t)(
                EMAC_REGS__SCREENING_TYPE_2_ETHERTYPE_REG__COMPARE_VALUE__READ(reg));
    }
    return (status);
}

/* Write the compare value at the given index in the Type 2 compare register
 * @param pD - driver private state info specific to this instance
 * @param index - number of the Type 2 compare register to write, range 0 to
 *    num_scr2_compare_regs-1
 * @param regVals - points to a CEDI_T2Compare struct with the compare
 *    parameters to be written
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacSetType2CompareReg(CEDI_PrivateData *pD, uint8_t index, const CEDI_T2Compare *regVals)
{
    uint32_t status = 0U;
    volatile uint32_t *word0Ptr = NULL;
    volatile uint32_t *word1Ptr = NULL;
    uint32_t reg0, reg1;

    if ((pD==NULL)||(regVals==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if ((pD->hwCfg.num_type2_screeners==0) ||
                (pD->hwCfg.num_scr2_compare_regs==0)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        switch (regVals->offsetPosition){
        case CEDI_T2COMP_OFF_VID_S_TAG:
        case CEDI_T2COMP_OFF_VID_C_TAG:

            if (0U == IsGem1p12(pD)) {
                status = ENOTSUP;
            }

            if (0U == status) {
                word1Ptr = type2CompareWord1Reg[index];
                addRegBase(pD, &word1Ptr);

                reg1 = CPS_UncachedRead32(word1Ptr);
                EMAC_REGS__TYPE2_COMPARE_WORD_1__COMPARE_VLAN_ID__SET(reg1);
                EMAC_REGS__TYPE2_COMPARE_WORD_1__DISABLE_MASK__CLR(reg1);
                reg1 &= ~EMAC_REGS__TYPE2_COMPARE_WORD_1__OFFSET_VALUE__MASK;
                reg1 &= ~EMAC_REGS__TYPE2_COMPARE_WORD_1__COMPARE_OFFSET__MASK;

                /* if S-TAG VID comparison set bit 7 */
                if (regVals->offsetPosition == CEDI_T2COMP_OFF_VID_S_TAG) {
                    reg1 |= EMAC_REGS__TYPE2_COMPARE_WORD_1__COMPARE_OFFSET__WRITE(0x01);
                }

                CPS_UncachedWrite32(word1Ptr, reg1);
            }
        break;

        case CEDI_T2COMP_OFF_SOF:
        case CEDI_T2COMP_OFF_ETYPE:
        case CEDI_T2COMP_OFF_IPHDR:
        case CEDI_T2COMP_OFF_TCPUDP:

            if ((index>=pD->hwCfg.num_scr2_compare_regs)
                || (regVals->offsetVal>0x3F)
                || (regVals->disableMask>1)) {
                status = EINVAL;
            }

            if (0U == status) {
                word0Ptr = type2CompareWord0Reg[index];
                addRegBase(pD, &word0Ptr);

                word1Ptr = type2CompareWord1Reg[index];
                addRegBase(pD, &word1Ptr);

                reg0 = 0;
                reg1 = 0;
                EMAC_REGS__TYPE2_COMPARE_WORD_0__MASK_VALUE__MODIFY(reg0,
                                                                    regVals->compMask);
                EMAC_REGS__TYPE2_COMPARE_WORD_0__COMPARE_VALUE__MODIFY(reg0,
                                                                    regVals->compValue);
                EMAC_REGS__TYPE2_COMPARE_WORD_1__OFFSET_VALUE__MODIFY(reg1,
                                                                    regVals->offsetVal);
                EMAC_REGS__TYPE2_COMPARE_WORD_1__COMPARE_OFFSET__MODIFY(reg1,
                                                                regVals->offsetPosition);
                            EMAC_REGS__TYPE2_COMPARE_WORD_1__DISABLE_MASK__MODIFY(reg1,
                                                                regVals->disableMask);
            
                CPS_UncachedWrite32(word0Ptr, reg0);
                CPS_UncachedWrite32(word1Ptr, reg1);
            }

        break;

        default:
            status = EINVAL;
        break;
        }
    }

    return (status);
}

/* Read the compare value at the given index in the Type 2 compare register
 * @param pD - driver private state info specific to this instance
 * @param index - number of the Type 2 compare register to read, range 0 to
 *    num_scr2_compare_regs-1
 * @param regVals - points to a CEDI_T2Compare struct for returning the
 *    compare parameters
 * @return 0 if successful, EINVAL if parameter invalid
 */
uint32_t emacGetType2CompareReg(CEDI_PrivateData *pD, uint8_t index, CEDI_T2Compare *regVals)
{
    uint32_t status = 0;
    uint32_t reg0 = 0, reg1 = 0;
    uint32_t compareOffset;
    volatile uint32_t *word0Ptr = NULL;
    volatile uint32_t *word1Ptr = NULL;

    if ((pD==NULL)||(regVals==NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if ((pD->hwCfg.num_type2_screeners==0) ||
                (pD->hwCfg.num_scr2_compare_regs==0)) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (index>=pD->hwCfg.num_scr2_compare_regs) {
            status = EINVAL;
        }
    }

    if (0 == status) {
        word0Ptr = type2CompareWord0Reg[index];
        addRegBase(pD, &word0Ptr);

        word1Ptr = type2CompareWord1Reg[index];
        addRegBase(pD, &word1Ptr);

        reg0 = CPS_UncachedRead32(word0Ptr);
        reg1 = CPS_UncachedRead32(word1Ptr);

        compareOffset = EMAC_REGS__TYPE2_COMPARE_WORD_1__COMPARE_OFFSET__READ(reg1);

        regVals->compMask = (uint16_t)(
            EMAC_REGS__TYPE2_COMPARE_WORD_0__MASK_VALUE__READ(reg0));
        regVals->compValue = (uint16_t)(
            EMAC_REGS__TYPE2_COMPARE_WORD_0__COMPARE_VALUE__READ(reg0));
        regVals->offsetVal = (uint8_t)(
            EMAC_REGS__TYPE2_COMPARE_WORD_1__OFFSET_VALUE__READ(reg1));
        regVals->offsetPosition = (CEDI_T2Offset)compareOffset;
        regVals->disableMask = (uint8_t)(
            EMAC_REGS__TYPE2_COMPARE_WORD_1__DISABLE_MASK__READ(reg1));
    }

    return (status);
}

/* set number of active RX queues - Sw dis/enabling of RX priority queues */
uint32_t
emacSetRxQueueNum(CEDI_PrivateData *pD, uint8_t numQueues)
{
    uint32_t status = 0;
    uint8_t i;
#ifdef EMAC_REGS__RECEIVE_Q_PTR__DMA_RX_DIS_Q__MODIFY
    uint32_t retVal;
#endif

    if (pD == NULL) {
        status = EINVAL;
    }

    if (0 == status) {
        if (numQueues >  pD->cfg.rxQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT,
                    "Error: number of queues cannot be bigger than set during "
                    "driver initialization which is %d\n", pD->cfg.rxQs);
            status = EINVAL;
        }
    }

    if (0 == status) {
        if (numQueues < 1){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: at least one queue must be enabled\n");
            status = EINVAL;
        }
    }

    if (0 == status) {
        /* nothing to do. New setting equals current setting. */
        if (numQueues == pD->rxQs) {
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
#ifdef EMAC_REGS__RECEIVE_Q_PTR__DMA_RX_DIS_Q__MODIFY
        if (0 != emacRxEnabled(pD)){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                    "Error: Cannot change number of queues when transmission is not disabled\n");
            status = EIO;
        }

        if (0 == status) {
            /* disable screening for each of queues to disable
             * to ensure frames are not routed to disabled queues*/
            for (i = numQueues - 1; i <  pD->cfg.rxQs; i++){
                retVal = QueueCheckAndDisableScreening(pD, i);
                if (0 != retVal) {
                    vDbgMsg(DBG_GEN_MSG, 10,
                        "emacSetRxQueueNum: QueueCheckAndDisableScreening "\
                        "returned with code: %u for queue %u\n", retVal, i);
                }
            }

            /* enable all queues with number below numQueues) */
            enableRxQs(pD, numQueues);

            /* disable all queues with number equal to or above numQueues) */
            disableRxQs(pD, numQueues);

            /* set new rx priority queues number */
            pD->rxQs = numQueues;
        }
#else
        status = ENOTSUP;
#endif
    }
    if (EAGAIN == status) {
        status = 0;
    }
    return (status);
}


/* get number of active RX queues */
uint32_t
emacGetRxQueueNum(const CEDI_PrivateData *pD, uint8_t *numQueues)
{
    uint32_t status = 0;
    if ((pD == NULL) || (numQueues == NULL)) {
        status = EINVAL;
    } else {
        *numQueues = pD->rxQs;
    }
    return (status);
}



uint32_t emacSetType1ScreenRegDropEnable(CEDI_PrivateData* pD, uint8_t regNum,
					 uint8_t enable)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
        if (pD->hwCfg.num_type1_screeners==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type1_screeners) {
            status = EINVAL;
        }
    }

   if (0 == status) {
        regPtr = type1ScreeningReg[regNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);

	EMAC_REGS__SCREENING_TYPE_1_REGISTER__DROP_ON_MATCH__MODIFY(reg, enable);
        CPS_UncachedWrite32(regPtr, reg);
    }

    return status;
}

uint32_t emacGetType1ScreenRegDropEnable(CEDI_PrivateData* pD, uint8_t regNum,
					 uint8_t *enable)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (enable == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
        if (pD->hwCfg.num_type1_screeners==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type1_screeners) {
            status = EINVAL;
        }
    }

   if (0 == status) {
        regPtr = type1ScreeningReg[regNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);

	*enable = EMAC_REGS__SCREENING_TYPE_1_REGISTER__DROP_ON_MATCH__READ(reg);
    }

    return status;
}

uint32_t emacSetType2ScreenRegDropEnable(CEDI_PrivateData* pD, uint8_t regNum,
					 uint8_t enable)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
        if (pD->hwCfg.num_type2_screeners==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type2_screeners) {
            status = EINVAL;
        }
    }

   if (0 == status) {
        regPtr = type2ScreeningReg[regNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);

	EMAC_REGS__SCREENING_TYPE_2_REGISTER__DROP_ON_MATCH__MODIFY(reg, enable);
        CPS_UncachedWrite32(regPtr, reg);
    }

    return status;
}

uint32_t emacGetType2ScreenRegDropEnable(CEDI_PrivateData* pD, uint8_t regNum,
					 uint8_t *enable)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (enable == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
        if (pD->hwCfg.num_type2_screeners==0) {
            status = ENOTSUP;
        }
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type2_screeners) {
            status = EINVAL;
        }
    }

   if (0 == status) {
        regPtr = type2ScreeningReg[regNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);

	*enable = EMAC_REGS__SCREENING_TYPE_2_REGISTER__DROP_ON_MATCH__READ(reg);
    }

    return status;
}

uint32_t emacSetRxQFlushConfig(CEDI_PrivateData* pD, uint8_t queueNum,
			       CEDI_RxQFlushConfig* rxQFlushConfig)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (rxQFlushConfig == NULL)) {
        status = EINVAL;
    }


    if (0 == status) {
	if ((rxQFlushConfig->dropAllFrames > 1) || (rxQFlushConfig->dropOnRsrcErr > 1))
	    status = EINVAL;
    }

    if (0 == status) {
	if ((uint32_t)rxQFlushConfig->rxQFlushMode > (uint32_t)CEDI_FLUSH_MODE_LIMIT_FRAME_SIZE){
	    status = EINVAL;
	}
    }

    if (0 == status) {
        if (queueNum>=pD->rxQs) {
            vDbgMsg(DBG_GEN_MSG, 5, "Error: Invalid Rx queue number: %u\n", queueNum);
            status = EINVAL;
        }
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
	regPtr = rxQueueFlushReg[queueNum];
	addRegBase(pD, &regPtr);
	reg = CPS_UncachedRead32(regPtr);


	EMAC_REGS__RX_Q_FLUSH__DROP_ALL_FRAMES__MODIFY(reg, rxQFlushConfig->dropAllFrames);
	EMAC_REGS__RX_Q_FLUSH__DROP_ON_RESOURCE_ERR__MODIFY(reg, rxQFlushConfig->dropOnRsrcErr);

	if (rxQFlushConfig->rxQFlushMode == CEDI_FLUSH_MODE_LIMIT_NUM_BYTES){
	    EMAC_REGS__RX_Q_FLUSH__LIMIT_NUM_BYTES__MODIFY(reg, 1);
	}
	else {
	    EMAC_REGS__RX_Q_FLUSH__LIMIT_NUM_BYTES__MODIFY(reg, 0);
	}

	if (rxQFlushConfig->rxQFlushMode == CEDI_FLUSH_MODE_LIMIT_FRAME_SIZE){
	    EMAC_REGS__RX_Q_FLUSH__LIMIT_FRAME_SIZE__MODIFY(reg, 1);
	}
	else {
	    EMAC_REGS__RX_Q_FLUSH__LIMIT_FRAME_SIZE__MODIFY(reg, 0);
	}

	EMAC_REGS__RX_Q_FLUSH__MAX_VAL__MODIFY(reg, rxQFlushConfig->maxVal);

        CPS_UncachedWrite32(regPtr, reg);
    }

    return status;

}

uint32_t emacGetRxQFlushConfig(CEDI_PrivateData* pD, uint8_t queueNum,
			       CEDI_RxQFlushConfig* rxQFlushConfig)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (rxQFlushConfig == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (queueNum>=pD->rxQs) {
            vDbgMsg(DBG_GEN_MSG, 5, "Error: Invalid Rx queue number: %u\n", queueNum);
            status = EINVAL;
        }
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
	regPtr = rxQueueFlushReg[queueNum];
	addRegBase(pD, &regPtr);
	reg = CPS_UncachedRead32(regPtr);

	rxQFlushConfig->dropAllFrames = EMAC_REGS__RX_Q_FLUSH__DROP_ALL_FRAMES__READ(reg);
	rxQFlushConfig->dropOnRsrcErr = EMAC_REGS__RX_Q_FLUSH__DROP_ON_RESOURCE_ERR__READ(reg);


	if (EMAC_REGS__RX_Q_FLUSH__LIMIT_NUM_BYTES__READ(reg) == 1)
	    rxQFlushConfig->rxQFlushMode = CEDI_FLUSH_MODE_LIMIT_NUM_BYTES;
	else if (EMAC_REGS__RX_Q_FLUSH__LIMIT_FRAME_SIZE__READ(reg) == 1)
	    rxQFlushConfig->rxQFlushMode = CEDI_FLUSH_MODE_LIMIT_FRAME_SIZE;
	else
	    rxQFlushConfig->rxQFlushMode = CEDI_FLUSH_MODE_OFF;

	rxQFlushConfig->maxVal = EMAC_REGS__RX_Q_FLUSH__MAX_VAL__READ(reg);
    }

    return status;
}

uint32_t emacGetRxDmaFlushedPacketsCount(struct CEDI_PrivateData* pD,
					 uint16_t* count)
{
    uint32_t status = 0;
    uint32_t reg;

    if ((pD==NULL) || (count == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
	reg = CPS_UncachedRead32(&(pD->regs->auto_flushed_pkts));

	*count = EMAC_REGS__AUTO_FLUSHED_PKTS__COUNT__READ(reg);
    }

    return status;
}

uint32_t emacSetType2ScreenerRateLimit(struct CEDI_PrivateData* pD, uint8_t regNum,
				       CEDI_Type2ScreenerRateLimit* rateLimit)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (rateLimit == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type2_screeners) {
            status = EINVAL;
        }
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
	regPtr = scr2RateLimitReg[regNum];
	addRegBase(pD, &regPtr);
	reg = CPS_UncachedRead32(regPtr);

	EMAC_REGS__SCR2_RATE_LIMIT__INTERVAL_TIME__MODIFY(reg, rateLimit->intervalTime);
	EMAC_REGS__SCR2_RATE_LIMIT__MAX_RATE_VAL__MODIFY(reg, rateLimit->maxRateVal);

        CPS_UncachedWrite32(regPtr, reg);
    }

    return status;
}

uint32_t emacGetType2ScreenerRateLimit(struct CEDI_PrivateData* pD, uint8_t regNum,
				       CEDI_Type2ScreenerRateLimit* rateLimit)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD==NULL) || (rateLimit == NULL)) {
        status = EINVAL;
    }

    if (0 == status) {
        if (regNum>=pD->hwCfg.num_type2_screeners) {
            status = EINVAL;
        }
    }

    if (0 == status) {
	if (isIngressTrafficSupported(pD) == 0){
	    status = ENOTSUP;
	}
    }

    if (0 == status) {
	regPtr = scr2RateLimitReg[regNum];
	addRegBase(pD, &regPtr);
	reg = CPS_UncachedRead32(regPtr);

	rateLimit->intervalTime = EMAC_REGS__SCR2_RATE_LIMIT__INTERVAL_TIME__READ(reg);
	rateLimit->maxRateVal = EMAC_REGS__SCR2_RATE_LIMIT__MAX_RATE_VAL__READ(reg);
    }

    return status;
}

uint32_t emacGetRxType2RateLimitTriggered(struct CEDI_PrivateData* pD,
					  uint16_t* status)
{
    uint32_t ret = 0;
    uint32_t reg;

    if ((pD==NULL) || (status == NULL)) {
        ret = EINVAL;
    }

    if (0 == ret) {
	if (isIngressTrafficSupported(pD) == 0){
	    ret = ENOTSUP;
	}
    }

    if (0 == ret) {
	reg = CPS_UncachedRead32(&(pD->regs->scr2_rate_status));

	*status = reg & ~EMAC_REGS__SCR2_RATE_STATUS__RESERVED_31_16__MASK;
    }

    return ret;
}


uint32_t emacSetRxWatermark(CEDI_PrivateData* pD, uint16_t rxHighWatermark, uint16_t rxLowWatermark)
{
    uint32_t ret = 0;
    uint32_t reg;

    if (pD==NULL) {
        ret = EINVAL;
    }

    if (0 == ret) {
	if (IsGem1p11(pD) == 0){
	    ret = ENOTSUP;
	}
    }

    if (0 == ret) {
	CPS_UncachedWrite32(&(pD->regs->rx_water_mark), 0);

	reg = EMAC_REGS__RX_WATER_MARK__RX_HIGH_WATERMARK__WRITE(rxHighWatermark);
	reg |= EMAC_REGS__RX_WATER_MARK__RX_LOW_WATERMARK__WRITE(rxLowWatermark);

	CPS_UncachedWrite32(&(pD->regs->rx_water_mark), reg);
    }

    return ret;
}

uint32_t emacGetRxWatermark(CEDI_PrivateData* pD, uint16_t* rxHighWatermark, uint16_t* rxLowWatermark)
{
    uint32_t ret = 0;
    uint32_t reg;

    if ((pD==NULL) || (rxHighWatermark == NULL) || (rxLowWatermark == NULL)) {
        ret = EINVAL;
    }

    if (0 == ret) {
	if (IsGem1p11(pD) == 0){
	    ret = ENOTSUP;
	}
    }

    if (0 == ret) {
	reg = CPS_UncachedRead32(&(pD->regs->rx_water_mark));
	*rxHighWatermark = EMAC_REGS__RX_WATER_MARK__RX_HIGH_WATERMARK__READ(reg);
	*rxLowWatermark |= EMAC_REGS__RX_WATER_MARK__RX_LOW_WATERMARK__READ(reg);
    }

    return ret;
}


