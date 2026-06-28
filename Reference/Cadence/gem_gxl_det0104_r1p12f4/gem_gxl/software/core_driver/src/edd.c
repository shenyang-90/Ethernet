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
 * edd.c
 * Ethernet DMA MAC Driver,
 * for GEM GXL core part no. IP7014, from rev 1p05 up
 * for GEM XL  core part no. IP7012, from rev 1p01 up
 * and XGM GXL core part no. IP716,  from rev 1p01 up
 *
 * Main source file
 *****************************************************************************/

#include "cdn_stdint.h"
#include "cdn_errno.h"
#include "log.h"
#include "cps.h"
#include "emac_regs.h"
#include "cedi.h"
#include "edd_int.h"

extern volatile uint32_t* const specAddBottomReg[32];

/******************************************************************************
 * Register addresses tables
 *****************************************************************************/
static volatile uint32_t* const intDisableReg[15] = {
    CEDI_RegOff(int_q1_disable),
    CEDI_RegOff(int_q2_disable),
    CEDI_RegOff(int_q3_disable),
    CEDI_RegOff(int_q4_disable),
    CEDI_RegOff(int_q5_disable),
    CEDI_RegOff(int_q6_disable),
    CEDI_RegOff(int_q7_disable),
    CEDI_RegOff(int_q8_disable),
    CEDI_RegOff(int_q9_disable),
    CEDI_RegOff(int_q10_disable),
    CEDI_RegOff(int_q11_disable),
    CEDI_RegOff(int_q12_disable),
    CEDI_RegOff(int_q13_disable),
    CEDI_RegOff(int_q14_disable),
    CEDI_RegOff(int_q15_disable)
};

static volatile uint32_t* const intStatusReg[15] = {
    CEDI_RegOff(int_q1_status),
    CEDI_RegOff(int_q2_status),
    CEDI_RegOff(int_q3_status),
    CEDI_RegOff(int_q4_status),
    CEDI_RegOff(int_q5_status),
    CEDI_RegOff(int_q6_status),
    CEDI_RegOff(int_q7_status),
    CEDI_RegOff(int_q8_status),
    CEDI_RegOff(int_q9_status),
    CEDI_RegOff(int_q10_status),
    CEDI_RegOff(int_q11_status),
    CEDI_RegOff(int_q12_status),
    CEDI_RegOff(int_q13_status),
    CEDI_RegOff(int_q14_status),
    CEDI_RegOff(int_q15_status)
};

static volatile uint32_t* const frerControlRegA[16] = {
    CEDI_RegOff(frer_control_1_a),
    CEDI_RegOff(frer_control_2_a),
    CEDI_RegOff(frer_control_3_a),
    CEDI_RegOff(frer_control_4_a),
    CEDI_RegOff(frer_control_5_a),
    CEDI_RegOff(frer_control_6_a),
    CEDI_RegOff(frer_control_7_a),
    CEDI_RegOff(frer_control_8_a),
    CEDI_RegOff(frer_control_9_a),
    CEDI_RegOff(frer_control_10_a),
    CEDI_RegOff(frer_control_11_a),
    CEDI_RegOff(frer_control_12_a),
    CEDI_RegOff(frer_control_13_a),
    CEDI_RegOff(frer_control_14_a),
    CEDI_RegOff(frer_control_15_a),
    CEDI_RegOff(frer_control_16_a)
};

static volatile uint32_t* const frerControlRegB[16] = {
    CEDI_RegOff(frer_control_1_b),
    CEDI_RegOff(frer_control_2_b),
    CEDI_RegOff(frer_control_3_b),
    CEDI_RegOff(frer_control_4_b),
    CEDI_RegOff(frer_control_5_b),
    CEDI_RegOff(frer_control_6_b),
    CEDI_RegOff(frer_control_7_b),
    CEDI_RegOff(frer_control_8_b),
    CEDI_RegOff(frer_control_9_b),
    CEDI_RegOff(frer_control_10_b),
    CEDI_RegOff(frer_control_11_b),
    CEDI_RegOff(frer_control_12_b),
    CEDI_RegOff(frer_control_13_b),
    CEDI_RegOff(frer_control_14_b),
    CEDI_RegOff(frer_control_15_b),
    CEDI_RegOff(frer_control_16_b)
};




/******************************************************************************
 * Initial static declarations
 *****************************************************************************/
static struct emac_regs *getMmslRegs(CEDI_PrivateData *pD);

/******************************************************************************
 * Private Driver functions
 *****************************************************************************/

static uint8_t CmpBuffs(void *buf1, void *buf2, uint32_t size)
{
    uint8_t *buf18 = buf1;
    uint8_t *buf28 = buf2;
    int i;
    uint8_t result = 0;

    for (i = 0; i < size; i++){
	if(buf18[i] != buf28[i]){
	    result = 1;
	}
    }
    return result;
}

static uint8_t WriteRegAndVerify(volatile uint32_t* address, uint32_t value)
{
    uint32_t reg;

    CPS_UncachedWrite32(address, value);
    reg = CPS_UncachedRead32(address);

    if (reg == value){
	return 0;
    }
    else {
	vDbgMsg(DBG_GEN_MSG, 5,
		"Error: Register %p verification failed, written:%08x read:%08x \n",
		address, value, reg);
	return 1;
    }
}

static uint8_t WriteRegAndVerifyMasked(volatile uint32_t* address,
				       uint32_t value, uint32_t mask)
{
    uint32_t reg;
    CPS_UncachedWrite32(address, value);
    reg = CPS_UncachedRead32(address);

    value &= mask;
    reg &= mask;

    if (reg == value){
	return 0;
    }
    else {
	vDbgMsg(DBG_GEN_MSG, 5,
		"Error: Register %p verification failed, written:%08x read:%08x \n",
		address, value, reg);
	return 1;
    }
}

uint8_t IsGem1p09(const CEDI_PrivateData *pD)
{
    uint8_t result = 0U;
    switch(pD->hwCfg.moduleId){
    case GEM_GXL_MODULE_ID_V0:
        if (pD->hwCfg.moduleRev >= 0x0109U) {
            result = 1U;
        } else {
            result = 0U;
        }
        break;
    case GEM_GXL_MODULE_ID_V1:
    case GEM_GXL_MODULE_ID_V2:
    case GEM_AUTO_MODULE_ID_V0:
    case GEM_AUTO_MODULE_ID_V1:
        result = 1U;
        break;
    default:
        result = 0U;
        break;
    }
    return (result);
}

static uint8_t IsGem1p11_(uint16_t moduleId, uint16_t moduleRev)
{
    int isSupported = 0;

    switch (moduleId){
    case GEM_GXL_MODULE_ID_V0:
    case GEM_GXL_MODULE_ID_V1:
    case GEM_GXL_MODULE_ID_V2:
    case GEM_AUTO_MODULE_ID_V0:
    case GEM_AUTO_MODULE_ID_V1:
	if (moduleRev >= 0x010B)
	    isSupported = 1;
	break;
    }
    return isSupported;
}

uint8_t IsGem1p11(const CEDI_PrivateData* pD)
{
    return IsGem1p11_(pD->hwCfg.moduleId, pD->hwCfg.moduleRev);
}

uint8_t IsGem1p12(const CEDI_PrivateData* pD)
{
    uint8_t isSupported = 0;

    switch (pD->hwCfg.moduleId){
    case GEM_GXL_MODULE_ID_V0:
    case GEM_GXL_MODULE_ID_V1:
    case GEM_GXL_MODULE_ID_V2:
    case GEM_AUTO_MODULE_ID_V0:
    case GEM_AUTO_MODULE_ID_V1:
    if (pD->hwCfg.moduleRev >= 0x010CU) {
        isSupported = 1;
    }
    break;
    default:
    // default
    break;
    }
    return isSupported;
}

uint8_t IsEnstSupported(const CEDI_PrivateData *pD)
{
    uint8_t result = 0U;
    switch(pD->hwCfg.moduleId){
    case GEM_GXL_MODULE_ID_V1:
    case GEM_GXL_MODULE_ID_V2:
    case GEM_AUTO_MODULE_ID_V0:
    case GEM_AUTO_MODULE_ID_V1:
        result = ((pD->hwCfg.exclude_qbv) == 0U)? 1U : 0U ;
        break;
    default:
        result = 0U;
        break;
    }
    return (result);
}

static uint8_t is2p5GSupported(const CEDI_PrivateData *pD)
{
    uint8_t result;
    if (pD->hwCfg.moduleId == GEM_GXL_MODULE_ID_V2) {
        result = 1U;
    } else if (pD->hwCfg.moduleId == GEM_AUTO_MODULE_ID_V1) {
        result = 1U;
    } else {
        result = 0U;
    }
    return (result);
}

uint8_t IsLockupSupported(void *pD)
{
    return IsGem1p11(pD);
}

/* align value of "size" to size of pointer and return it.*/
static uint32_t alignedToPtr(uint32_t size)
{
    uint8_t alignment = (uint8_t) (sizeof(uintptr_t));
    uint8_t misalignment = ((alignment - 1U) & (uint8_t)size);
    uint32_t aligned = size;
    if (0U != misalignment) {
        aligned += alignment;
        aligned -= misalignment;
    }
    return (aligned);
}


uint8_t isIntrptModerateThresholdSupported(const CEDI_PrivateData* pD)
{
    uint8_t isSupported = IsGem1p11(pD);

    if (pD->hwCfg.intrpt_mod==0)
	isSupported = 0;

    return isSupported;
}

/* These functions intentionally violate MISRA C rules, to allow pointer
 * casts and/or manipulations required for driver operation. */

/* Adds register base address to offset, in-place */
void addRegBase(const CEDI_PrivateData *pD, volatile uint32_t **ptr)
{
    *ptr = (volatile uint32_t*)((volatile uint8_t*)(*ptr) +
                    pD->cfg.regBase);
}

/* Casts unsigned integer (as uintptr_t) to pointer.
 * Purpose of each call of this function should be known. */
uint32_t *uintptrToPtrU32(uintptr_t addr)
{
    return ((uint32_t *)addr);
}

/* Casts registers base address, represented as integer, to pointer to struct */
static struct emac_regs *regBaseToPtr(uintptr_t regBase)
{
    return ((struct emac_regs *)regBase);
}

/* Calculates address to be used as beginning of TX/RX descriptor address list
 * in memory allocated by user, after private data (pD).
 * Second parameter defines offset, relative to pD. */
static uintptr_t *calcDescListStartAddr(CEDI_PrivateData *pD, uint32_t offset)
{
    return ((uintptr_t *)((uint8_t *)pD + offset));
}

/* Casts Rx descriptor virtual address, represented as integer,
 * to pointer of sppropriate rxDesc* type */
rxDesc *rxDescAddrToPtr(uintptr_t descAddr)
{
    return ((rxDesc *)descAddr);
}

/* Adds value of offset (which may be positive or negative) to Rx descriptor
 * pointer, in-place. Offset should have relatively small absolute value */
void moveRxDescAddr(rxDesc **ptr, int32_t offset)
{
    if (offset > ((int32_t)0) ) {
        *ptr = (rxDesc *)(((uintptr_t)*ptr) + (uintptr_t) offset);
    } else {
        *ptr = (rxDesc *)(((uintptr_t)*ptr) - ((uintptr_t) (offset*(-1))));
    }
}

/* end of pointer-related functions. */

void getJumboFramesRx(const CEDI_PrivateData *pD, uint8_t *enable)
{
    *enable= (uint8_t) (EMAC_REGS__NETWORK_CONFIG__JUMBO_FRAMES__READ(
            CPS_UncachedRead32(&(pD->regs->network_config))));
}

static void getFullDuplex(const CEDI_PrivateData *pD, uint8_t *enable)
{
    *enable= (uint8_t) (EMAC_REGS__NETWORK_CONFIG__FULL_DUPLEX__READ(
            CPS_UncachedRead32(&(pD->regs->network_config))));

}

static struct emac_regs *getMmslRegs(CEDI_PrivateData *pD)
{
    CEDI_PrivateData *ppD;
    if (pD->macType == CEDI_MAC_TYPE_EMAC) {
        ppD = pD->otherMac;
    } else {
        ppD = pD;
    }
    return (ppD->regs);

}

/* Calculate the descriptor sizes (in bytes) for a given DMA config */
static void calcDescriptorSizes(const CEDI_Config *config,
                                uint16_t *txDescSize,
                                uint16_t *rxDescSize) {

    /* use 1 contiguous block for Tx descriptor lists
     * and another contiguous block for Rx descriptor lists */
    *txDescSize = CEDI_TWO_BD_WORD_SIZE;
    *rxDescSize = CEDI_TWO_BD_WORD_SIZE;

    if (0U != config->dmaAddrBusWidth)  // DMA address bus width. 0 =32b , 1=64b
    {
         *txDescSize += CEDI_TWO_BD_WORD_SIZE;
         *rxDescSize += CEDI_TWO_BD_WORD_SIZE;
    }

    if (0U != config->enTxExtBD){
        *txDescSize += CEDI_TWO_BD_WORD_SIZE;
    }

    if (0U != config->enRxExtBD){
        *rxDescSize += CEDI_TWO_BD_WORD_SIZE;
    }
}

static uint32_t numTxDescriptors(const CEDI_Config *config)
{
    uint16_t i;
    uint32_t sumTxDesc = 0U;

    for (i=0U; i<config->txQs; i++) {
        /* allow 1 extra for "endstop" descriptor */
        sumTxDesc += ((uint32_t)((config->txQLen)[i])+CEDI_MIN_TXBD);
    }
    return (sumTxDesc);
}

static uint32_t numRxDescriptors(const CEDI_Config *config)
{
    uint16_t i;
    uint32_t sumRxDesc = 0U;

    for (i=0U; i<config->rxQs; i++) {
        /* allow 1 extra for "endstop" descriptor */
        sumRxDesc += ((uint32_t)((config->rxQLen)[i])+CEDI_MIN_RXBD);
    }
    return (sumRxDesc);
}

static uint32_t initTxDescLists(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    uint8_t q;
    uint32_t offset;

    /* set start of Tx vAddr lists - place in pD block after
     * privateData struct */
    offset = alignedToPtr((uint32_t) sizeof(CEDI_PrivateData));

    pD->txQueue[0U].vAddrList = calcDescListStartAddr(pD, offset);
    for (q=0U; q<pD->txQs; q++) {
        if (0U != emacResetTxQ(pD, q)) {
            status = EINVAL;
            break;
        }
    }

    return (status);
}

/* Initialise Rx descriptor lists - also in pD block, after the Tx ones */
static uint32_t initRxDescLists(CEDI_PrivateData *pD)
{
    uint8_t q;
    uint32_t pAddr, i, status = 0U;
    uint32_t offset;
    uintptr_t vAddr;
    rxQueue_t *rxQ;
    rxDesc* descPtr;

    /* set start of Rx vAddr lists after Tx lists */
    offset = ((uint32_t) (alignedToPtr((uint16_t)sizeof(CEDI_PrivateData))) +
                ((uint16_t)sizeof(uintptr_t))*(numTxDescriptors(&(pD->cfg))));
    pD->rxQueue[0U].rxBufVAddr = calcDescListStartAddr(pD, offset);

    for (q=0U; q<pD->cfg.rxQs; q++) {

        rxQ = &(pD->rxQueue[q]);
        rxQ->numRxDesc = pD->cfg.rxQLen[q] + CEDI_MIN_RXBD;

        emacFindQBaseAddr(pD, q, rxQ, &pAddr, &vAddr);
        rxQ->rxDescStart = rxDescAddrToPtr(vAddr);

        /* initialise the descriptors */
        descPtr = rxQ->rxDescStart;
        for (i = 0U; i<rxQ->numRxDesc; i++) {
            CPS_UncachedWrite32((uint32_t *)
                    &descPtr->word[0U], (uint32_t)((0U != i)?0U:(CEDI_RXD_WRAP|CEDI_RXD_USED)));
            CPS_UncachedWrite32((uint32_t *)
                    &(descPtr->word[1U]), CEDI_RXD_EMPTY);
            moveRxDescAddr(&descPtr, pD->rxDescriptorSize);
        }

        if (0U!=emacResetRxQ(pD, q, 0U)) {
            status = EINVAL;
            break;
        }
    }

    return (status);
}

/* return the number of priority queues available in the h/w config */
static uint8_t maxHwQs(struct emac_regs *regBase) {
    uint8_t qCount = 1U;
    uint32_t reg = CPS_UncachedRead32(&(regBase->designcfg_debug6));
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE1__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE2__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE3__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE4__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE5__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE6__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE7__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE8__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE9__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE10__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE11__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE12__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE13__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE14__READ(reg)) {
        qCount++;
    }
    if (0U != EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE15__READ(reg)) {
        qCount++;
    }
    return (qCount);
}

static void disableAllInterrupts(const CEDI_PrivateData *pD)
{
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    for (i = 1U; i < pD->numQs; i++) {
        regPtr = intDisableReg[i-1U];
        addRegBase(pD, &regPtr);
        CPS_UncachedWrite32(regPtr, 0xFFFFFFFFU);
    }
    CPS_UncachedWrite32(&(pD->regs->int_disable), 0xFFFFFFFFU);
}

static void clearAllInterruptsByWrite(const CEDI_PrivateData *pD)
{
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    for (i = 1U; i < pD->numQs; i++) {
        regPtr = intStatusReg[i-1U];
        addRegBase(pD, &regPtr);
        CPS_UncachedWrite32(regPtr, 0xFFFFFFFFU);
    }
    CPS_UncachedWrite32(&(pD->regs->int_status), 0xFFFFFFFFU);
}

static void clearAllInterruptsByRead(const CEDI_PrivateData *pD)
{
    uint32_t reg = CPS_UncachedRead32(&(pD->regs->int_status));
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    for (i = 1U; i < pD->numQs; i++) {
        regPtr = intStatusReg[i-1U];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);
    }

}

static void clearAllInterrupts(const CEDI_PrivateData *pD)
{
    if (0U==pD->hwCfg.irq_read_clear) {
        clearAllInterruptsByWrite(pD);
    }
    else {
        clearAllInterruptsByRead(pD);
    }
}

/* Return all registers to reset values */
static uint32_t initAllRegs(const CEDI_PrivateData *pD)
{
    uint32_t status = 0;
    status |= WriteRegAndVerify(&(pD->regs->network_control), 0U);
    status |= WriteRegAndVerify(&(pD->regs->network_config), 0U);
    if (0!=pD->hwCfg.user_io)
	status |= WriteRegAndVerify(&(pD->regs->user_io_register), 0U);
    CPS_UncachedWrite32(&(pD->regs->transmit_status), 0U);
    status |= WriteRegAndVerify(&(pD->regs->receive_q_ptr), 0U);
    status |= WriteRegAndVerify(&(pD->regs->transmit_q_ptr), 0U);
    CPS_UncachedWrite32(&(pD->regs->receive_status), 0U);
    CPS_UncachedWrite32(&(pD->regs->int_disable), 0xFFFFFFFFU);
    status |= WriteRegAndVerify(&(pD->regs->phy_management), 0U);

    status |= WriteRegAndVerify(&(pD->regs->pbuf_txcutthru),
				((1 << pD->hwCfg.tx_pbuf_addr) - 1));
    status |= WriteRegAndVerify(&(pD->regs->pbuf_rxcutthru),
				((1 << pD->hwCfg.rx_pbuf_addr) - 1));

    status |= WriteRegAndVerify(&(pD->regs->jumbo_max_length), 0x00002800U);
    if (pD->hwCfg.ext_fifo_interface != 0){
	if (CEDI_MAC_TYPE_EMAC != pD->macType)
	    status |= WriteRegAndVerify(&(pD->regs->external_fifo_interface), 0U);
    }
    status |= WriteRegAndVerify(&(pD->regs->axi_max_pipeline), 0x00000101U);
    if ((CEDI_MAC_TYPE_EMAC != pD->macType) && (pD->hwCfg.pbuf_rsc != 0)) {
        status |= WriteRegAndVerify(&(pD->regs->rsc_control), 0U);
    }
    status |= WriteRegAndVerify(&(pD->regs->int_moderation), 0U);
    status |= WriteRegAndVerify(&(pD->regs->sys_wake_time), 0U);
    status |= WriteRegAndVerify(&(pD->regs->hash_bottom), 0U);
    status |= WriteRegAndVerify(&(pD->regs->hash_top), 0U);
    status |= WriteRegAndVerify(&(pD->regs->wol_register), 0U);
    status |= WriteRegAndVerify(&(pD->regs->stretch_ratio), 0U);
    status |= WriteRegAndVerify(&(pD->regs->stacked_vlan), 0U);
    status |= WriteRegAndVerify(&(pD->regs->tx_pfc_pause), 0U);
    status |= WriteRegAndVerify(&(pD->regs->mask_add1_bottom), 0U);
    status |= WriteRegAndVerify(&(pD->regs->mask_add1_top), 0U);
    status |= WriteRegAndVerify(&(pD->regs->dma_addr_or_mask), 0U);
    status |= WriteRegAndVerify(&(pD->regs->rx_ptp_unicast), 0U);
    status |= WriteRegAndVerify(&(pD->regs->tx_ptp_unicast), 0U);
    status |= WriteRegAndVerify(&(pD->regs->tsu_nsec_cmp), 0U);
    status |= WriteRegAndVerify(&(pD->regs->tsu_sec_cmp), 0U);
    status |= WriteRegAndVerify(&(pD->regs->tsu_msb_sec_cmp), 0U);
    status |= WriteRegAndVerify(&(pD->regs->dpram_fill_dbg), 0U);
    if (0U == pD->hwCfg.no_pcs){
	if (pD->macType != CEDI_MAC_TYPE_EMAC){
	uint32_t mask = (EMAC_REGS__PCS_CONTROL__COLLISION_TEST__MASK
	    | EMAC_REGS__PCS_CONTROL__RESTART_AUTO_NEG__MASK
	    | EMAC_REGS__PCS_CONTROL__ENABLE_AUTO_NEG__MASK
	    | EMAC_REGS__PCS_CONTROL__LOOPBACK_MODE__MASK);

	status |= WriteRegAndVerifyMasked(&(pD->regs->pcs_control), 0U, mask);
	status |= WriteRegAndVerify(&(pD->regs->pcs_an_adv), 0U);
	status |= WriteRegAndVerify(&(pD->regs->pcs_an_np_tx), 0U);
	}
    }
    if (pD->hwCfg.pfc_multi_quantum == 0){
	status |= WriteRegAndVerify(&(pD->regs->tx_pause_quantum), 0x0000FFFFU);
    }
    else {
	status |= WriteRegAndVerify(&(pD->regs->tx_pause_quantum), 0xFFFFFFFFU);
	status |= WriteRegAndVerify(&(pD->regs->tx_pause_quantum1), 0xFFFFFFFFU);
	status |= WriteRegAndVerify(&(pD->regs->tx_pause_quantum2), 0xFFFFFFFFU);
	status |= WriteRegAndVerify(&(pD->regs->tx_pause_quantum3), 0xFFFFFFFFU);
    }

    CPS_UncachedWrite32(&(pD->regs->rx_lpi), 0U);
    CPS_UncachedWrite32(&(pD->regs->rx_lpi_time), 0U);
    CPS_UncachedWrite32(&(pD->regs->tx_lpi), 0U);
    CPS_UncachedWrite32(&(pD->regs->tx_lpi_time), 0U);
    status |= WriteRegAndVerify(&(pD->regs->dpram_fill_dbg), 0U);
    status |= WriteRegAndVerify(&(pD->regs->cbs_control), 0U);
    status |= WriteRegAndVerify(&(pD->regs->cbs_idleslope_q_a), 0U);
    status |= WriteRegAndVerify(&(pD->regs->cbs_idleslope_q_b), 0U);

    if (pD->hwCfg.dma_addr_width != 0){
	status |= WriteRegAndVerify(&(pD->regs->upper_tx_q_base_addr), 0U);
	status |= WriteRegAndVerify(&(pD->regs->upper_rx_q_base_addr), 0U);
    }

    status |= WriteRegAndVerify(&(pD->regs->tx_bd_control), 0U);
    status |= WriteRegAndVerify(&(pD->regs->rx_bd_control), 0U);
    return status;
}

/* Check the selected callback(s) have non-NULL call addresses.
 * Test all events selected, returning any with NULL callbacks.
 * @param checkSelection - bit-flags defining callback selection
 * @return 0 if all OK (not NULL)
 * @return OR'd combination of events whose cb function pointers are NULL
 */
static uint32_t callbacksNullCheck(const CEDI_PrivateData *pD, uint32_t checkSelection)
{
    uint32_t nullCbEvents = 0U;
    uint32_t selection = checkSelection;

    /* Helper, internal struct for callback checking */
    struct SelectionCheck {
        uint32_t flags;
        void *ptr;
    };

    struct SelectionCheck check[] = {
        { ((uint32_t)CEDI_EV_TX_COMPLETE | (uint32_t)CEDI_EV_TX_USED_READ), pD->cb.txEvent },
        { ((uint32_t)CEDI_EV_RX_COMPLETE), pD->cb.rxFrame },        { ((uint32_t)CEDI_EV_TX_UNDERRUN | (uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL | (uint32_t)CEDI_EV_TX_FR_CORRUPT), pD->cb.txError },
        { ((uint32_t)CEDI_EV_RX_USED_READ | (uint32_t)CEDI_EV_RX_OVERRUN), pD->cb.rxError },
        { ((uint32_t)CEDI_EV_MAN_FRAME), pD->cb.phyManComplete },
        { ((uint32_t)CEDI_EV_HRESP_NOT_OK), pD->cb.hrespError },
        { ((uint32_t)CEDI_EV_PCS_LP_PAGE_RX), pD->cb.lpPageRx },
        { ((uint32_t)CEDI_EV_PCS_AN_COMPLETE), pD->cb.anComplete },
        { ((uint32_t)CEDI_EV_PCS_LINK_CHANGE_DET), pD->cb.linkChange },
        { ((uint32_t)CEDI_EV_PAUSE_FRAME_TX | (uint32_t)CEDI_EV_PAUSE_TIME_ZERO | (uint32_t)CEDI_EV_PAUSE_NZ_QU_RX), pD->cb.pauseEvent },
        { ((uint32_t)CEDI_EV_LPI_CH_RX), pD->cb.lpiStatus },
        { ((uint32_t)CEDI_EV_WOL_RX), pD->cb.wolEvent },
        { ((uint32_t)CEDI_EV_EXT_INTR), pD->cb.extInpIntr },
        { ((uint32_t)CEDI_EV_PTP_TX_DLY_REQ | (uint32_t)CEDI_EV_PTP_TX_SYNC), pD->cb.ptpPriFrameTx },
        { ((uint32_t)CEDI_EV_PTP_TX_PDLY_REQ | (uint32_t)CEDI_EV_PTP_TX_PDLY_RSP), pD->cb.ptpPeerFrameTx },
        { ((uint32_t)CEDI_EV_PTP_RX_DLY_REQ | (uint32_t)CEDI_EV_PTP_RX_SYNC), pD->cb.ptpPriFrameRx },
        { ((uint32_t)CEDI_EV_PTP_RX_PDLY_REQ | (uint32_t)CEDI_EV_PTP_RX_PDLY_RSP), pD->cb.ptpPeerFrameRx },
        { ((uint32_t)CEDI_EV_TSU_SEC_INC | (uint32_t)CEDI_EV_TSU_TIME_MATCH), pD->cb.tsuEvent },
        { ((uint32_t)CEDI_EV_RX_LOCKUP | (uint32_t)CEDI_EV_TX_LOCKUP), pD->cb.lockupEvent },

        { (0U), (0U) }
    };

    struct SelectionCheck *ptr_check = check;
    while ((ptr_check->flags != 0U) && (selection != 0U)) {
        if (((selection & ptr_check->flags) != 0U) && (ptr_check->ptr == NULL)) {
            nullCbEvents |= ptr_check->flags;
            selection &= ~ptr_check->flags;
        }
        ptr_check++;
    }

    return (nullCbEvents);
}

/* initializing the upper 32 bit buffer queue base addresses from config */
static uint32_t initUpper32BuffQAddr(CEDI_PrivateData *pD)
{
    uint32_t regData;
    uint32_t status = 0;

    regData = 0U;

    if (pD->hwCfg.dma_addr_width != 0){
	EMAC_REGS__UPPER_TX_Q_BASE_ADDR__UPPER_TX_Q_BASE_ADDR__MODIFY(
	    regData, pD->cfg.upper32BuffTxQAddr);

	status |= WriteRegAndVerify(&(pD->regs->upper_tx_q_base_addr), regData);

	regData = 0U;
	EMAC_REGS__UPPER_RX_Q_BASE_ADDR__UPPER_RX_Q_BASE_ADDR__MODIFY(
	    regData, pD->cfg.upper32BuffRxQAddr);

	status |= WriteRegAndVerify(&(pD->regs->upper_rx_q_base_addr), regData);
    }

    return status;
}

/* Initialise axi_max_pipeline register from config struct */
static uint32_t initAxiMaxPipelineReg(CEDI_PrivateData *pD)
{
    CEDI_Config *config = &(pD->cfg);
    uint32_t regData, axiPipelineFifoDepth;
    uint8_t status = 0;

    regData = CPS_UncachedRead32(&(pD->regs->axi_max_pipeline));
    if (pD->hwCfg.axi_access_pipeline_bits > 31U) {
	vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
		"*** Warning: Incorrect axi_access_pipeline_bits was read from"\
		"hardware register, setting axiPipelineFifoDepth to aw2wMaxPipeline");
	axiPipelineFifoDepth = (config->aw2wMaxPipeline);
    } else {
        axiPipelineFifoDepth = (uint32_t)((uint32_t)1U<<(uint32_t)pD->hwCfg.axi_access_pipeline_bits);
    }

    /* value of max pipeline must be >0 and not greater than fifo depth
     * (2^axi_access_pipeline) */
    if ((pD->hwCfg.axi != 0U) && (config->aw2wMaxPipeline==0U)) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
            "*** Warning: aw2wMaxPipeline requested value = 0, increasing to 1");
        config->aw2wMaxPipeline = 1U;
    } else {
        if ((config->aw2wMaxPipeline) > axiPipelineFifoDepth) {
            vDbgMsg(DBG_GEN_MSG, 5, "*** Warning: aw2wMaxPipeline requested"\
                "value (%u) greater than fifo depth (%u), reducing to %u\n",
                config->aw2wMaxPipeline, axiPipelineFifoDepth, axiPipelineFifoDepth);
            config->aw2wMaxPipeline = (uint8_t)axiPipelineFifoDepth;
        }
    }
    EMAC_REGS__AXI_MAX_PIPELINE__AW2W_MAX_PIPELINE__MODIFY(
                                    regData, config->aw2wMaxPipeline);

    if ((pD->hwCfg.axi != 0U) && (config->ar2rMaxPipeline==0U)) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
            "*** Warning: ar2rMaxPipeline requested value = 0, increasing to 1");
        config->ar2rMaxPipeline = 1U;
    } else {
        if ((config->ar2rMaxPipeline) > axiPipelineFifoDepth) {
            vDbgMsg(DBG_GEN_MSG, 5, "*** Warning: ar2rMaxPipeline requested"\
                "value (%u) greater than fifo depth (%u), reducing to %u\n",
                config->ar2rMaxPipeline, axiPipelineFifoDepth, axiPipelineFifoDepth);
            config->ar2rMaxPipeline = (uint8_t)axiPipelineFifoDepth;
        }
    }
    EMAC_REGS__AXI_MAX_PIPELINE__AR2R_MAX_PIPELINE__MODIFY(
                                    regData, config->ar2rMaxPipeline);

    status = WriteRegAndVerify(&(pD->regs->axi_max_pipeline), regData);

    return status;
}

/* Initialise Network Control register from config struct */
static uint32_t initNetControlReg(const CEDI_PrivateData *pD)
{
    const CEDI_Config *config = &(pD->cfg);
    uint32_t regTmp, regTmp2;

    /* Disable everything first to be safe */
    regTmp = 0U;
    CPS_UncachedWrite32(&(pD->regs->network_control), regTmp);

    if (0U != config->enableMdio) {
        EMAC_REGS__NETWORK_CONTROL__MAN_PORT_EN__SET(regTmp);
    }

    if (0U != config->altSgmiiEn) {
        EMAC_REGS__NETWORK_CONTROL__ALT_SGMII_MODE__SET(regTmp);
    }

#ifdef EMAC_REGS__NETWORK_CONTROL__TWO_PT_FIVE_GIG__MODIFY
    if ((config->ifTypeSel==CEDI_IFSP_2500M_SGMII)
        || (config->ifTypeSel==CEDI_IFSP_2500BASE_X)) {
        EMAC_REGS__NETWORK_CONTROL__TWO_PT_FIVE_GIG__MODIFY(regTmp, 1U);
    } else {
        EMAC_REGS__NETWORK_CONTROL__TWO_PT_FIVE_GIG__MODIFY(regTmp, 0U);
    }
#endif


    if (0U != config->storeUdpTcpOffset) {
        EMAC_REGS__NETWORK_CONTROL__STORE_UDP_OFFSET__SET(regTmp);
    }

    /* for ext. TSU require tsu configured */
    if (((config->enExtTsuPort) != 0U) && (pD->hwCfg.tsu != 0U)) {
        EMAC_REGS__NETWORK_CONTROL__EXT_TSU_PORT_ENABLE__SET(regTmp);
    }
    /* pfc multi quantum functionality */
    if(0U != config->pfcMultiQuantum) {
    	EMAC_REGS__NETWORK_CONTROL__PFC_CTRL__SET(regTmp);
    }
    /* clear stats */
    EMAC_REGS__NETWORK_CONTROL__CLEAR_ALL_STATS_REGS__SET(regTmp);

    CPS_UncachedWrite32(&(pD->regs->network_control), regTmp);
    regTmp2 = CPS_UncachedRead32(&(pD->regs->network_control));

    // clear write only bit
    regTmp &= ~EMAC_REGS__NETWORK_CONTROL__CLEAR_ALL_STATS_REGS__MASK;
    regTmp2 &= ~EMAC_REGS__NETWORK_CONTROL__CLEAR_ALL_STATS_REGS__MASK;

    if (regTmp != regTmp2){
	vDbgMsg(DBG_GEN_MSG, 5,
		"Error: Register %p verification failed, written:%08x read:%08x \n",
		&(pD->regs->network_control), regTmp, regTmp2);
	return EIO;
    }

    return 0;
}

/* Initialise DMA Config register from config struct */
static uint32_t initDmaConfigReg(const CEDI_PrivateData *pD)
{
    const CEDI_Config *config = &(pD->cfg);
    uint32_t regTmp = 0U, tmp1;

    switch(config->dmaDataBurstLen) {
    case CEDI_DMA_DBUR_LEN_1:
        tmp1 = CEDI_AMBD_BURST_LEN_1;
        break;
    case CEDI_DMA_DBUR_LEN_4:
        tmp1 = CEDI_AMBD_BURST_LEN_4;
        break;
    case CEDI_DMA_DBUR_LEN_8:
        tmp1 = CEDI_AMBD_BURST_LEN_8;
        break;
    case CEDI_DMA_DBUR_LEN_16:
        tmp1 = CEDI_AMBD_BURST_LEN_16;
        break;
    default:
        tmp1 = CEDI_AMBD_BURST_LEN_4;
        break;
    }
    EMAC_REGS__DMA_CONFIG__AMBA_BURST_LENGTH__MODIFY(regTmp, tmp1);

    if (0U != (config->dmaEndianism & (uint8_t)CEDI_END_SWAP_DESC)) {
        EMAC_REGS__DMA_CONFIG__ENDIAN_SWAP_MANAGEMENT__SET(regTmp);
    }
    if (0U != (config->dmaEndianism & (uint8_t)CEDI_END_SWAP_DATA)) {
        EMAC_REGS__DMA_CONFIG__ENDIAN_SWAP_PACKET__SET(regTmp);
    }

    EMAC_REGS__DMA_CONFIG__RX_PBUF_SIZE__MODIFY(regTmp, config->rxPktBufSize);
    EMAC_REGS__DMA_CONFIG__TX_PBUF_SIZE__MODIFY(regTmp, config->txPktBufSize);

    if (0U != (config->chkSumOffEn & (uint8_t)CEDI_CFG_CHK_OFF_TX)) {
        EMAC_REGS__DMA_CONFIG__TX_PBUF_TCP_EN__SET(regTmp);
    }

    EMAC_REGS__DMA_CONFIG__RX_BUF_SIZE__MODIFY(regTmp, config->rxBufLength[0U]);

    if (0U != (config->dmaCfgFlags & (uint8_t)CEDI_CFG_DMA_DISC_RXP)) {
        EMAC_REGS__DMA_CONFIG__FORCE_DISCARD_ON_ERR__SET(regTmp);
    }

    if (0U != (config->dmaCfgFlags & (uint8_t)CEDI_CFG_DMA_FRCE_RX_BRST)) {
        EMAC_REGS__DMA_CONFIG__FORCE_MAX_AMBA_BURST_RX__SET(regTmp);
    }

    if (0U != (config->dmaCfgFlags & (uint8_t)CEDI_CFG_DMA_FRCE_TX_BRST)) {
        EMAC_REGS__DMA_CONFIG__FORCE_MAX_AMBA_BURST_TX__SET(regTmp);
    }

    if (0U != config->dmaAddrBusWidth) {
  	   EMAC_REGS__DMA_CONFIG__DMA_ADDR_BUS_WIDTH_1__SET(regTmp);
    }

    if (0U != config->enTxExtBD) {
  	    EMAC_REGS__DMA_CONFIG__TX_BD_EXTENDED_MODE_EN__SET(regTmp);
    }

    if (0U != config->enRxExtBD) {
  	    EMAC_REGS__DMA_CONFIG__RX_BD_EXTENDED_MODE_EN__SET(regTmp);
    }

    return WriteRegAndVerify(&(pD->regs->dma_config), regTmp);
}

/* Initialise Network Config register from config struct */
static uint32_t initNetConfigReg(const CEDI_PrivateData *pD)
{
    const CEDI_Config *config = &(pD->cfg);
    uint32_t regTmp = 0U;

    if ((config->ifTypeSel==CEDI_IFSP_1000M_GMII) ||
            (config->ifTypeSel==CEDI_IFSP_1000M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_1000BASE_X)  ||
            (config->ifTypeSel==CEDI_IFSP_2500M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_2500BASE_X)) {
        EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__SET(regTmp);
    }

    if ((config->ifTypeSel==CEDI_IFSP_10M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_100M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_1000M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_1000BASE_X)  ||
            (config->ifTypeSel==CEDI_IFSP_2500M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_2500BASE_X)) {
        EMAC_REGS__NETWORK_CONFIG__PCS_SELECT__SET(regTmp);
    }

    if ((config->ifTypeSel==CEDI_IFSP_10M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_100M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_1000M_SGMII) ||
            (config->ifTypeSel==CEDI_IFSP_2500M_SGMII)) {
        EMAC_REGS__NETWORK_CONFIG__SGMII_MODE_ENABLE__SET(regTmp);
    }

    if (0U != config->uniDirEnable) {
        EMAC_REGS__NETWORK_CONFIG__UNI_DIRECTION_ENABLE__SET(regTmp);
    }

    if ((config->ifTypeSel != CEDI_IFSP_10M_MII) &&
            (config->ifTypeSel != CEDI_IFSP_10M_SGMII)) {
        EMAC_REGS__NETWORK_CONFIG__SPEED__SET(regTmp);
    }

    if (0U != config->fullDuplex) {
        EMAC_REGS__NETWORK_CONFIG__FULL_DUPLEX__SET(regTmp);
    }

    if (0U != config->enRxHalfDupTx) {
        EMAC_REGS__NETWORK_CONFIG__EN_HALF_DUPLEX_RX__SET(regTmp);
    }

    if (0U != config->ignoreIpgRxEr) {
        EMAC_REGS__NETWORK_CONFIG__IGNORE_IPG_RX_ER__SET(regTmp);
    }

    if (0U != config->enRxBadPreamble) {
        EMAC_REGS__NETWORK_CONFIG__NSP_CHANGE__SET(regTmp);
    }

    if (0U != config->rxJumboFrEn) {
        EMAC_REGS__NETWORK_CONFIG__JUMBO_FRAMES__SET(regTmp);
    }

    if (0U != config->rx1536ByteEn) {
        EMAC_REGS__NETWORK_CONFIG__RECEIVE_1536_BYTE_FRAMES__SET(regTmp);
    }

    if (0U != config->extAddrMatch) {
        EMAC_REGS__NETWORK_CONFIG__EXTERNAL_ADDRESS_MATCH_ENABLE__SET(regTmp);
    }

    EMAC_REGS__NETWORK_CONFIG__RECEIVE_BUFFER_OFFSET__MODIFY(regTmp,
            config->rxBufOffset);

    if (0U != config->rxLenErrDisc) {
        EMAC_REGS__NETWORK_CONFIG__LENGTH_FIELD_ERROR_FRAME_DISCARD__SET(
                regTmp);
    }

    EMAC_REGS__NETWORK_CONFIG__MDC_CLOCK_DIVISION__MODIFY(regTmp,
            config->mdcPclkDiv);

    EMAC_REGS__NETWORK_CONFIG__DATA_BUS_WIDTH__MODIFY(regTmp,
            config->dmaBusWidth);

    if (0U != config->disCopyPause) {
        EMAC_REGS__NETWORK_CONFIG__DISABLE_COPY_OF_PAUSE_FRAMES__SET(regTmp);
    }

    if (0U != (config->chkSumOffEn & CEDI_CFG_CHK_OFF_RX)) {
        EMAC_REGS__NETWORK_CONFIG__RECEIVE_CHECKSUM_OFFLOAD_ENABLE__SET(regTmp);
    }

    return WriteRegAndVerify(&(pD->regs->network_config), regTmp);
}


/* set Rx buffer sizes for Q>0 */
static uint32_t setRxQBufferSizes(const CEDI_PrivateData *pD, const CEDI_Config *config)
{
    uint32_t reg, q;
    volatile uint32_t *regPtr = NULL;
    uint32_t status = 0;

    volatile uint32_t* const dmaRxbufSizeReg[15U] = {
        CEDI_RegOff(dma_rxbuf_size_q1),
        CEDI_RegOff(dma_rxbuf_size_q2),
        CEDI_RegOff(dma_rxbuf_size_q3),
        CEDI_RegOff(dma_rxbuf_size_q4),
        CEDI_RegOff(dma_rxbuf_size_q5),
        CEDI_RegOff(dma_rxbuf_size_q6),
        CEDI_RegOff(dma_rxbuf_size_q7),
        CEDI_RegOff(dma_rxbuf_size_q8),
        CEDI_RegOff(dma_rxbuf_size_q9),
        CEDI_RegOff(dma_rxbuf_size_q10),
        CEDI_RegOff(dma_rxbuf_size_q11),
        CEDI_RegOff(dma_rxbuf_size_q12),
        CEDI_RegOff(dma_rxbuf_size_q13),
        CEDI_RegOff(dma_rxbuf_size_q14),
        CEDI_RegOff(dma_rxbuf_size_q15)
    };

    if (pD->cfg.rxQs>1U) {
        for (q=1U; q<pD->cfg.rxQs; q++) {
            reg = 0U;
            EMAC_REGS__DMA_RXBUF_SIZE_Q__DMA_RX_Q_BUF_SIZE__MODIFY(
                                    reg, config->rxBufLength[q]);
            regPtr = dmaRxbufSizeReg[q-1U];
            addRegBase(pD, &regPtr);
            if (WriteRegAndVerify(regPtr, reg))
		status = EIO;
        }
    }
    return status;
}

/*****************  Hardware Revision Compatibility Tests  *******************/

/* Return non-zero if h/w includes stateless offloads */
static uint32_t offloadsSupport(const CEDI_PrivateData *pD)
{
    uint32_t result;
    if (0U != (((pD->hwCfg.moduleId==GEM_GXL_MODULE_ID_V0)
        && (pD->hwCfg.moduleRev>=OFFLOADS_GEM_GXL_REV))
	|| (pD->hwCfg.moduleId==GEM_GXL_MODULE_ID_V1)
	|| (pD->hwCfg.moduleId==GEM_GXL_MODULE_ID_V2)
        || (pD->hwCfg.moduleId==GEM_AUTO_MODULE_ID_V0)
        || (pD->hwCfg.moduleId==GEM_AUTO_MODULE_ID_V1))) {

        result = 1U;

    }
    else {

        result = 0U;
    }
    return result;
}

/* Return non-zero if h/w includes 24bit sub-ns timer increment resolution */
uint32_t subNsTsuInc24bSupport(const CEDI_PrivateData *pD)
{
     uint32_t result;
     if (pD==NULL) {
        result = 0U;
     } else {
     /* resolution increase came in at r1p06f2 */
        if (0U != ((pD->hwCfg.moduleId==GEM_GXL_MODULE_ID_V0)
            && (pD->hwCfg.moduleRev==0x0106U)
            && (pD->hwCfg.fixNumber>=2U))
            || ((pD->hwCfg.moduleId==GEM_GXL_MODULE_ID_V0)
            && (pD->hwCfg.moduleRev>0x0106U))
 	    || (pD->hwCfg.moduleId>=GEM_GXL_MODULE_ID_V1)
 	    || (pD->hwCfg.moduleId>=GEM_GXL_MODULE_ID_V2)
            || (pD->hwCfg.moduleId==GEM_AUTO_MODULE_ID_V0)
            || (pD->hwCfg.moduleId==GEM_AUTO_MODULE_ID_V1)) {

            result = 1U;

        } else {

            result = 0U;
        }
    }
    return (result);
}

/* Read DesignConfig Debug registers into privateData for faster access.
 * pD must point to a privateData struct with cfg.regBase set */
static void readDesignConfig(CEDI_PrivateData *pD)
{
    uint32_t reg;
    uint8_t cond;

    /* read in revision & number of queues, which are also set by defs file */
    pD->hwCfg.numQueues = maxHwQs(pD->regs);

    reg = CPS_UncachedRead32(&(pD->regs->revision_reg));

    pD->hwCfg.moduleId =(uint16_t)
            EMAC_REGS__REVISION_REG__MODULE_IDENTIFICATION_NUMBER__READ(reg);
    pD->hwCfg.moduleRev =(uint16_t)
            EMAC_REGS__REVISION_REG__MODULE_REVISION__READ(reg);
    pD->hwCfg.fixNumber =(uint8_t)
#ifdef EMAC_REGS__REVISION_REG__FIX_NUMBER__READ
            EMAC_REGS__REVISION_REG__FIX_NUMBER__READ(reg);
#else
            0;
#endif

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug1));
    pD->hwCfg.no_pcs =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__NO_PCS__READ(reg);
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__SERDES__READ
    pD->hwCfg.serdes =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__SERDES__READ(reg);
#endif
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__RDC_50__READ
    pD->hwCfg.RDC_50 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__RDC_50__READ(reg);
#endif
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__TDC_50__READ
    pD->hwCfg.TDC_50 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__TDC_50__READ(reg);
#endif
    pD->hwCfg.int_loopback =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__INT_LOOPBACK__READ(reg);
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__NO_INT_LOOPBACK__READ
    pD->hwCfg.no_int_loopback =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__NO_INT_LOOPBACK__READ(reg);
#else
    pD->hwCfg.no_int_loopback = !(pD->hwCfg.int_loopback);
#endif
    pD->hwCfg.ext_fifo_interface =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__EXT_FIFO_INTERFACE__READ(reg);

#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__APB_REV1__READ
    pD->hwCfg.apb_rev1 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__APB_REV1__READ(reg);
#endif
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__APB_REV2__READ
    pD->hwCfg.apb_rev2 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__APB_REV2__READ(reg);
#endif
    pD->hwCfg.user_io =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__USER_IO__READ(reg);
    pD->hwCfg.user_out_width =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__USER_OUT_WIDTH__READ(reg);
    pD->hwCfg.user_in_width =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__USER_IN_WIDTH__READ(reg);
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__NO_SCAN_PINS__READ
    pD->hwCfg.no_scan_pins =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__NO_SCAN_PINS__READ(reg);
#endif
    pD->hwCfg.no_stats =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__NO_STATS__READ(reg);
    pD->hwCfg.no_snapshot =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__NO_SNAPSHOT__READ(reg);
    pD->hwCfg.irq_read_clear =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__IRQ_READ_CLEAR__READ(reg);
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__EXCLUDE_CBS__READ
    /* need both compile-time test for macro and runtime test for feature
       support, to allow regression against older h/w */
    if (0U != offloadsSupport(pD)) {
        pD->hwCfg.exclude_cbs =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__EXCLUDE_CBS__READ(reg);
    }
#else
    pD->hwCfg.exclude_cbs = 1U;
#endif

#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__EXCLUDE_QBV__READ
        pD->hwCfg.exclude_qbv =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__EXCLUDE_QBV__READ(reg);
#else
        pD->hwCfg.exclude_qbv = 1U;

#endif

    pD->hwCfg.dma_bus_width =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__DMA_BUS_WIDTH__READ(reg);
    pD->hwCfg.axi_cache_value =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG1__AXI_CACHE_VALUE__READ(reg);

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug2));
    pD->hwCfg.jumbo_max_length =(uint16_t)
            EMAC_REGS__DESIGNCFG_DEBUG2__JUMBO_MAX_LENGTH__READ(reg);
    pD->hwCfg.hprot_value =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG2__HPROT_VALUE__READ(reg);
    pD->hwCfg.rx_pkt_buffer =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG2__RX_PKT_BUFFER__READ(reg);
    pD->hwCfg.tx_pkt_buffer =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG2__TX_PKT_BUFFER__READ(reg);
    pD->hwCfg.rx_pbuf_addr =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG2__RX_PBUF_ADDR__READ(reg);
    pD->hwCfg.tx_pbuf_addr =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG2__TX_PBUF_ADDR__READ(reg);
    pD->hwCfg.axi =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG2__AXI__READ(reg);

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug3));
    pD->hwCfg.num_spec_add_filters =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG3__NUM_SPEC_ADD_FILTERS__READ(reg);

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug5));
    pD->hwCfg.rx_fifo_cnt_width =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__RX_FIFO_CNT_WIDTH__READ(reg);
    pD->hwCfg.tx_fifo_cnt_width =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__TX_FIFO_CNT_WIDTH__READ(reg);
    pD->hwCfg.tsu =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__TSU__READ(reg);
    pD->hwCfg.phy_ident =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__PHY_IDENT__READ(reg);
    pD->hwCfg.dma_bus_width_def =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__DMA_BUS_WIDTH_DEF__READ(reg);
    pD->hwCfg.mdc_clock_div =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__MDC_CLOCK_DIV__READ(reg);
    pD->hwCfg.endian_swap_def =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__ENDIAN_SWAP_DEF__READ(reg);
    pD->hwCfg.rx_pbuf_size_def =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__RX_PBUF_SIZE_DEF__READ(reg);
    pD->hwCfg.tx_pbuf_size_def =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__TX_PBUF_SIZE_DEF__READ(reg);
    pD->hwCfg.rx_buffer_length_def =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__RX_BUFFER_LENGTH_DEF__READ(reg);
    pD->hwCfg.tsu_clk =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__TSU_CLK__READ(reg);
    pD->hwCfg.axi_prot_value =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG5__AXI_PROT_VALUE__READ(reg);

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug6));
    pD->hwCfg.tx_pbuf_queue_segment_size =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG6__TX_PBUF_QUEUE_SEGMENT_SIZE__READ(reg);
    pD->hwCfg.ext_tsu_timer =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG6__EXT_TSU_TIMER__READ(reg);
    pD->hwCfg.tx_add_fifo_if =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG6__TX_ADD_FIFO_IF__READ(reg);
    pD->hwCfg.host_if_soft_select =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG6__HOST_IF_SOFT_SELECT__READ(reg);
    pD->hwCfg.dma_addr_width =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG6__DMA_ADDR_WIDTH_IS_64B__READ(reg);
	pD->hwCfg.pfc_multi_quantum =(uint8_t)
			EMAC_REGS__DESIGNCFG_DEBUG6__PFC_MULTI_QUANTUM__READ(reg);
	/* Offloads features: first available in GEM_GXL rev 1p07- */
    if (0U != offloadsSupport(pD)) {
#ifdef EMAC_REGS__DESIGNCFG_DEBUG6__PBUF_LSO__READ
        pD->hwCfg.pbuf_lso = (uint8_t)
                (EMAC_REGS__DESIGNCFG_DEBUG6__PBUF_LSO__READ(reg));
#else
        pD->hwCfg.pbuf_lso = 0U;
#endif
#ifdef EMAC_REGS__DESIGNCFG_DEBUG6__PBUF_RSC__READ
        pD->hwCfg.pbuf_rsc =(uint8_t)
                EMAC_REGS__DESIGNCFG_DEBUG6__PBUF_RSC__READ(reg);
#else
        pD->hwCfg.pbuf_rsc = 0U;
#endif
        pD->hwCfg.intrpt_mod = 1U;
        pD->hwCfg.hdr_split = 1U;
    } else {
        pD->hwCfg.pbuf_lso = 0U;
        pD->hwCfg.pbuf_rsc = 0U;
        pD->hwCfg.intrpt_mod = 0U;
        pD->hwCfg.hdr_split = 0U;
    }
    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug7));
    pD->hwCfg.tx_pbuf_num_segments_q0 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q0__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q1 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q1__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q2 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q2__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q3 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q3__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q4 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q4__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q5 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q5__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q6 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q6__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q7 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q7__READ(reg);

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug8));
    pD->hwCfg.num_type1_screeners =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG8__NUM_TYPE1_SCREENERS__READ(reg);
    pD->hwCfg.num_type2_screeners =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG8__NUM_TYPE2_SCREENERS__READ(reg);
    pD->hwCfg.num_scr2_ethtype_regs =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG8__NUM_SCR2_ETHTYPE_REGS__READ(reg);
    pD->hwCfg.num_scr2_compare_regs =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG8__NUM_SCR2_COMPARE_REGS__READ(reg);

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug9));
    pD->hwCfg.tx_pbuf_num_segments_q8 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q8__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q9 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q9__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q10 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q10__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q11 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q11__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q12 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q12__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q13 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q13__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q14 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q14__READ(reg);
    pD->hwCfg.tx_pbuf_num_segments_q15 =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q15__READ(reg);

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug10));
    pD->hwCfg.axi_access_pipeline_bits =(uint8_t)
          EMAC_REGS__DESIGNCFG_DEBUG10__AXI_ACCESS_PIPELINE_BITS__READ(reg);
    pD->hwCfg.rx_pbuf_data =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG10__RX_PBUF_DATA__READ(reg);
    pD->hwCfg.tx_pbuf_data =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG10__TX_PBUF_DATA__READ(reg);

    reg = CPS_UncachedRead32(&(pD->regs->designcfg_debug12));
    cond = (uint8_t)EMAC_REGS__DESIGNCFG_DEBUG12__GEM_HAS_CB__READ(reg);
    pD->hwCfg.num_cb_streams = 0U;
    if (0U != cond) {
        pD->hwCfg.num_cb_streams =(uint8_t)
            EMAC_REGS__DESIGNCFG_DEBUG12__GEM_NUM_CB_STREAMS__READ(reg);
    }
    pD->hwCfg.lockup_supported = IsLockupSupported(pD);

}


/* Handle interrupts related to autonegotiation process */
static void handleAutoNegInterrupts(CEDI_PrivateData *pD, uint32_t isrReg)
{
    uint32_t retVal, regVal;
    uint8_t linkState;
    CEDI_AnNextPage nullNp;

    /************************* AN LP Page Rx ***************************/
    if (0U != EMAC_REGS__INT_STATUS__PCS_LINK_PARTNER_PAGE_RECEIVED__READ(isrReg))
    {
        if (0U != pD->basePageExp) {
            pD->lpPageRx.nextPage = 0U;
            /* Read base page data */
            retVal = emacGetLpAbilityPage(pD,
                        &(pD->lpPageRx.lpPageDat.lpBasePage));
            if (0U != retVal) {
                vDbgMsg(DBG_GEN_MSG, 10,
                    "ISR: General interrupts: emacGetLpAbilityPage "\
                    "returned with code: %u\n", retVal);
            }
        }
        else {
            pD->lpPageRx.nextPage = 1;
            /* Read next page data */
            retVal = emacGetLpNextPage(pD,
                        &(pD->lpPageRx.lpPageDat.lpNextPage));
            if (0U != retVal) {
                vDbgMsg(DBG_GEN_MSG, 10,
                    "ISR: General interrupts: emacGetLpNextPage "\
                    "returned with code: %u\n", retVal);
            }
        }

        vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) AN Link Partner %s Page Rx\n",
                (uint32_t)pD->cfg.regBase,
                (0U != pD->basePageExp)?"Base":"Next");
        if (0U != pD->basePageExp) {
            vDbgMsg(DBG_GEN_MSG, 10, "LpNextPage: %u  LpAck: %u  FullDuplex: %u  HalfDuplex: %u  Pause Capability: %u RemoteFault: %u\n",
                    pD->lpPageRx.lpPageDat.lpBasePage.ablInfo.defLpAbl.lpNextPage,
                    pD->lpPageRx.lpPageDat.lpBasePage.ablInfo.defLpAbl.lpAck,
                    pD->lpPageRx.lpPageDat.lpBasePage.ablInfo.defLpAbl.fullDuplex,
                    pD->lpPageRx.lpPageDat.lpBasePage.ablInfo.defLpAbl.halfDuplex,
                    pD->lpPageRx.lpPageDat.lpBasePage.ablInfo.defLpAbl.pauseCap,
                    pD->lpPageRx.lpPageDat.lpBasePage.ablInfo.defLpAbl.remFlt);
        }

        /* write Null message next page as default, can be overridden in callback or later */
        nullNp.ack2 = 0U;
        nullNp.message = 0x001U;
        nullNp.msgPage = 1U;
        nullNp.np = 0U;
        retVal = emacSetNextPageTx(pD, &nullNp);
        if (0U != retVal) {
            vDbgMsg(DBG_GEN_MSG, 10,
                "ISR: General interrupts: emacSetNextPageTx "\
                "returned with code: %u\n", retVal);
        }

        (*(pD->cb.lpPageRx))(pD, &(pD->lpPageRx));

        pD->basePageExp = 0U;
    }

    /************************* AN Complete *****************************/
    if (0U != EMAC_REGS__INT_STATUS__PCS_AUTO_NEGOTIATION_COMPLETE__READ(isrReg))
    {
        pD->basePageExp = 1U;
        pD->autoNegActive = 0U;

        regVal = CPS_UncachedRead32(&(pD->regs->network_status));
        pD->anStatus.duplexRes =(uint8_t)
                EMAC_REGS__NETWORK_STATUS__MAC_FULL_DUPLEX__READ(regVal);
        pD->anStatus.linkState =(uint8_t)
                EMAC_REGS__NETWORK_STATUS__PCS_LINK_STATE__READ(regVal);
        pD->anStatus.pauseRxRes =(uint8_t)
                EMAC_REGS__NETWORK_STATUS__MAC_PAUSE_RX_EN__READ(regVal);
        pD->anStatus.pauseTxRes =(uint8_t)
                EMAC_REGS__NETWORK_STATUS__MAC_PAUSE_TX_EN__READ(regVal);

        vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) Auto-negotiation Complete\n",
                (uint32_t)pD->cfg.regBase);

        (*(pD->cb.anComplete))(pD, &(pD->anStatus));
    }

    /*********************** Link State Change *************************/
    if (0U != EMAC_REGS__INT_STATUS__LINK_CHANGE__READ(isrReg))
    {
        if (0U != pD->autoNegActive) {
            retVal = emacGetLinkStatus(pD, &linkState);
            if (0U != retVal) {
                vDbgMsg(DBG_GEN_MSG, 10,
                    "ISR: General interrupts: emacGetLinkStatus "\
                    "returned with code: %u\n", retVal);
            }
        }
        else {
            linkState = (uint8_t)EMAC_REGS__NETWORK_STATUS__PCS_LINK_STATE__READ(
                    CPS_UncachedRead32(&(pD->regs->network_status)));
        }

        vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) Link State changed - state = %u\n",
                (uint32_t)pD->cfg.regBase, linkState);

        (*(pD->cb.linkChange))(pD, linkState);
    }
}

/* Interrupts related to Q0 and entire core.
 * Also applies to Express MAC */
static void handleGeneralInterupts(CEDI_PrivateData *pD, uint8_t *handled)
{
    uint32_t isrReg, regVal;
    uint32_t events = 0;
    uint16_t dat16;
    uint8_t  qNum=0U, cond1, cond2, cond3;


    /* test for any ISR bits set */
    /* read Interrupt Status Register */
    isrReg = CPS_UncachedRead32(&(pD->regs->int_status));

    if (0U != isrReg) {

        *handled = 1;

        /* do clear-write if required */
        if (0U==pD->hwCfg.irq_read_clear) {
            CPS_UncachedWrite32(&(pD->regs->int_status), isrReg);
        }

        /*** test all intr status bits & do associated callbacks ***/

        /************************ PHY MDIO Frame Tx'd **********************/
        if (0U != EMAC_REGS__INT_STATUS__MANAGEMENT_FRAME_SENT__READ(isrReg))
        {
            regVal = CPS_UncachedRead32(&(pD->regs->phy_management));
            cond1 = (EMAC_REGS__PHY_MANAGEMENT__OPERATION__READ(regVal)==2U)?1U:0U;
            dat16 =(uint16_t) (EMAC_REGS__PHY_MANAGEMENT__PHY_WRITE_READ_DATA__READ(regVal));
            vDbgMsg(DBG_GEN_MSG, 10,
                    "EMAC (0x%08X) PHY Management Frame sent to PHY(0x%02X) "\
                    "reg=0x%02X - %s operation, data=0x%04X\n",
                    (uint32_t)(pD->cfg).regBase,
                    EMAC_REGS__PHY_MANAGEMENT__PHY_ADDRESS__READ(regVal),
                    EMAC_REGS__PHY_MANAGEMENT__REGISTER_ADDRESS__READ(regVal),
                    (0U != cond1)?"read":"write",
                            dat16);

            (*(pD->cb.phyManComplete))(pD, cond1, dat16);
        }
        /****************************** TxEvent ****************************/

        cond1 =(uint8_t)EMAC_REGS__INT_STATUS__TX_USED_BIT_READ__READ(isrReg);
        cond2 = (uint8_t)EMAC_REGS__INT_STATUS__TRANSMIT_COMPLETE__READ(isrReg);
        if ((0U != cond1) || (0U !=cond2))
        {
            events = (0U != cond1)?((uint32_t)CEDI_EV_TX_USED_READ):0U;
            events |= (0U != cond2)?((uint32_t)CEDI_EV_TX_COMPLETE):0U;

            /* report both events in one callback call */


            (*(pD->cb.txEvent))(pD, events, qNum);
        }

        /****************************** TxError ****************************/

        cond1 = (uint8_t)EMAC_REGS__INT_STATUS__TRANSMIT_UNDER_RUN__READ(isrReg);
        cond2 = (uint8_t)EMAC_REGS__INT_STATUS__RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION__READ(isrReg);
        cond3 =(uint8_t) EMAC_REGS__INT_STATUS__AMBA_ERROR__READ(isrReg);

        if ((0U != cond1) || (0U != cond2) || (0U != cond3))
        {
            events = (0U != cond1)?(uint32_t)CEDI_EV_TX_UNDERRUN:0U;
            events |= (0U != cond2)?(uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL:0U;
            events |= (0U != cond3)?(uint32_t)CEDI_EV_TX_FR_CORRUPT:0U;
    #ifdef DEBUG
            /* read Q ptr for debug */
            regVal = CPS_UncachedRead32(&(pD->regs->transmit_q_ptr));
            vDbgMsg(DBG_GEN_MSG, 10,
            "EMAC (0x%08X) Tx Error:0x%08X queue:%u tx_q_ptr:"\
            "0x%08X  isr0=%08X\n", (uint32_t)pD->cfg.regBase,
            events, qNum, regVal, isrReg);
    #endif
           (*(pD->cb.txError))(pD, events, qNum);
        }


        /*************************** RxFrame *******************************/
        if (0U != EMAC_REGS__INT_STATUS__RECEIVE_COMPLETE__READ(isrReg))
        {
            (*(pD->cb.rxFrame))(pD, qNum);
        }

        /*************************** RxError *******************************/

        cond1 = (uint8_t)(EMAC_REGS__INT_STATUS__RX_USED_BIT_READ__READ(isrReg));
        cond2 = (uint8_t)(EMAC_REGS__INT_STATUS__RECEIVE_OVERRUN__READ(isrReg));

        if ((0U != cond1) || (0U != cond2))
        {
            events = (0U != cond1)?(uint32_t)CEDI_EV_RX_USED_READ:0U;
            events |= (0U != cond2)?(uint32_t)CEDI_EV_RX_OVERRUN:0U;

            vDbgMsg(DBG_GEN_MSG, 10,
                    "EMAC (0x%08X) Rx Error:0x%08X queue:%u\n",
                    (uint32_t)pD->cfg.regBase, events, qNum);
            (*(pD->cb.rxError))(pD, events, qNum);
        }

        /************************ HResp not OK Event ***********************/
        if (0U != EMAC_REGS__INT_STATUS__RESP_NOT_OK__READ(isrReg))
        {
            DbgMsg(DBG_GEN_MSG, 10,
                    "EMAC (0x%08X) HResp not OK, queue:%u\n",
                    (uint32_t)pD->cfg.regBase, qNum);

            (*(pD->cb.hrespError))(pD, qNum);
        }

        handleAutoNegInterrupts(pD, isrReg);

        /************************ Pause Event ******************************/
        cond1 = (uint8_t)(EMAC_REGS__INT_STATUS__PAUSE_FRAME_TRANSMITTED__READ(isrReg));
        cond2 = (uint8_t)(EMAC_REGS__INT_STATUS__PAUSE_TIME_ELAPSED__READ(isrReg));
        cond3 = (uint8_t)(EMAC_REGS__INT_STATUS__PAUSE_FRAME_WITH_NON_ZERO_PAUSE_QUANTUM_RECEIVED__READ(isrReg));

        if ((0U != cond1) || (0U !=  cond2) || (0U != cond3))
        {
            events = (0U != cond1)?(uint32_t)CEDI_EV_PAUSE_FRAME_TX:0U;
            events |= (0U != cond2)?(uint32_t)CEDI_EV_PAUSE_TIME_ZERO:0U;
            events |= (0U != cond3)?(uint32_t)CEDI_EV_PAUSE_NZ_QU_RX:0U;

            vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) Pause Event, type:0x%08X\n",
                    (uint32_t)pD->cfg.regBase, events);

            (*(pD->cb.pauseEvent))(pD, events);
        }

        /***************** PTP Primary Frame Tx Event **********************/
        cond1 = (uint8_t)(EMAC_REGS__INT_STATUS__PTP_DELAY_REQ_FRAME_TRANSMITTED__READ(isrReg));
        cond2 = (uint8_t)(EMAC_REGS__INT_STATUS__PTP_SYNC_FRAME_TRANSMITTED__READ(isrReg));

        if ((0U != cond1) || (0U !=cond2))
        {
            events = (0U != cond1)?(uint32_t)CEDI_EV_PTP_TX_DLY_REQ:0U;
            events |= (0U != cond2)?(uint32_t)CEDI_EV_PTP_TX_SYNC:0U;

            vDbgMsg(DBG_GEN_MSG, 10,
                    "EMAC (0x%08X) PTP Primary Frame Tx, type:0x%08X\n",
                    (uint32_t)pD->cfg.regBase, events);

            if (0U!=emacGetPtpFrameTxTime(pD, &(pD->ptpTime))) {
                pD->ptpTime.secsUpper = 0U;
                pD->ptpTime.secsLower = 0U;
                pD->ptpTime.nanosecs = 0U;
            }
            (*(pD->cb.ptpPriFrameTx))(pD, events, &(pD->ptpTime));
        }

        /******************* PTP Peer Frame Tx Event ***********************/
        cond1 =(uint8_t)(EMAC_REGS__INT_STATUS__PTP_PDELAY_REQ_FRAME_TRANSMITTED__READ(isrReg));
        cond2 =(uint8_t)(EMAC_REGS__INT_STATUS__PTP_PDELAY_RESP_FRAME_TRANSMITTED__READ(isrReg));

        if ((0U != cond1) || (0U !=cond2))
        {
            events = (0U != cond1)?(uint32_t)CEDI_EV_PTP_TX_PDLY_REQ:0U;
            events |= (0U != cond2)?(uint32_t)CEDI_EV_PTP_TX_PDLY_RSP:0U;

            vDbgMsg(DBG_GEN_MSG, 10,
                    "EMAC (0x%08X) PTP Peer Frame Tx, type:0x%08X\n",
                    (uint32_t)pD->cfg.regBase, events);

            if (0U!=emacGetPtpPeerFrameTxTime(pD, &(pD->ptpTime))) {
                pD->ptpTime.secsUpper = 0U;
                pD->ptpTime.secsLower = 0U;
                pD->ptpTime.nanosecs = 0U;
            }
            (*(pD->cb.ptpPeerFrameTx))(pD, events, &(pD->ptpTime));
        }

        /***************** PTP Primary Frame Rx Event **********************/
        cond1 =(uint8_t)(EMAC_REGS__INT_STATUS__PTP_DELAY_REQ_FRAME_RECEIVED__READ(isrReg));
        cond2 =(uint8_t) (EMAC_REGS__INT_STATUS__PTP_SYNC_FRAME_RECEIVED__READ(isrReg));

        if ((0U != cond1) || (0U !=cond2))
        {
            events = (0U != cond1)?(uint32_t)CEDI_EV_PTP_RX_DLY_REQ:0U;
            events |= (0U != cond2)?(uint32_t)CEDI_EV_PTP_RX_SYNC:0U;

            vDbgMsg(DBG_GEN_MSG, 10,
                    "EMAC (0x%08X) PTP Primary Frame Rx, type:0x%08X\n",
                    (uint32_t)pD->cfg.regBase, events);

            if (0U!=emacGetPtpFrameRxTime(pD, &(pD->ptpTime))) {
                pD->ptpTime.secsUpper = 0U;
                pD->ptpTime.secsLower = 0U;
                pD->ptpTime.nanosecs = 0U;
            }
            (*(pD->cb.ptpPriFrameRx))(pD, events, &(pD->ptpTime));
        }

        /******************* PTP Peer Frame Rx Event ***********************/
        cond1 =(uint8_t) (EMAC_REGS__INT_STATUS__PTP_PDELAY_REQ_FRAME_RECEIVED__READ(isrReg));
        cond2 =(uint8_t) (EMAC_REGS__INT_STATUS__PTP_PDELAY_RESP_FRAME_RECEIVED__READ(isrReg));

        if ((0U != cond1) || (0U !=cond2))
        {
            events = (0U != cond1)?(uint32_t)CEDI_EV_PTP_RX_PDLY_REQ:0U;
            events |= (0U != cond2)?(uint32_t)CEDI_EV_PTP_RX_PDLY_RSP:0U;

            vDbgMsg(DBG_GEN_MSG, 10,
                    "EMAC (0x%08X) PTP Peer Frame Rx, type:0x%08X\n",
                    (uint32_t)pD->cfg.regBase, events);

            if (0U!=emacGetPtpPeerFrameRxTime(pD, &(pD->ptpTime))) {
                pD->ptpTime.secsUpper = 0U;
                pD->ptpTime.secsLower = 0U;
                pD->ptpTime.nanosecs = 0U;
            }
            (*(pD->cb.ptpPeerFrameRx))(pD, events, &(pD->ptpTime));
        }

        /************************* Lockup detect Event *******************************/
	 if(EMAC_REGS__INT_STATUS__TX_LOCKUP_DETECTED__READ(isrReg) != 0)
	    events = CEDI_EV_TX_LOCKUP;
	 if(EMAC_REGS__INT_STATUS__RX_LOCKUP_DETECTED__READ(isrReg) != 0)
	    events |= CEDI_EV_RX_LOCKUP;

	 if (events & (CEDI_EV_TX_LOCKUP | CEDI_EV_RX_LOCKUP)){
	     vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) Lockup Event, type:0x%08X\n",
		     (uint32_t)pD->cfg.regBase, events);
	     (*(pD->cb.lockupEvent))(pD, events);
	 }


        /************************* TSU Event *******************************/
        cond1 =(uint8_t)(EMAC_REGS__INT_STATUS__TSU_SECONDS_REGISTER_INCREMENT__READ(isrReg));
        cond2 =(uint8_t)(EMAC_REGS__INT_STATUS__TSU_TIMER_COMPARISON_INTERRUPT__READ(isrReg));

        if ((0U != cond1) || (0U !=cond2))
        {
            events = (0U != cond1)?(uint32_t)CEDI_EV_TSU_SEC_INC:0U;
            events |= (0U != cond2)?(uint32_t)CEDI_EV_TSU_TIME_MATCH:0U;

            vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) TSU Event, type:0x%08X\n",
                    (uint32_t)pD->cfg.regBase, events);

            (*(pD->cb.tsuEvent))(pD, events);
        }

        /************************* LPI Status Change ***********************/
        if (0U != EMAC_REGS__INT_STATUS__RECEIVE_LPI_INDICATION_STATUS_BIT_CHANGE__READ(isrReg))
        {
            vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) LPI Status change Event\n",

                    (uint32_t)pD->cfg.regBase);

            (*(pD->cb.lpiStatus))(pD);
        }

        /************************* Wake On LAN Event ***********************/
        if (0U != EMAC_REGS__INT_STATUS__WOL_INTERRUPT__READ(isrReg))
        {
            vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) Wake on LAN Event\n",
                    (uint32_t)pD->cfg.regBase);

            (*(pD->cb.wolEvent))(pD);
        }

        /****************** External Input Interrupt Event *****************/
        if (0U != EMAC_REGS__INT_STATUS__EXTERNAL_INTERRUPT__READ(isrReg))
        {
            vDbgMsg(DBG_GEN_MSG, 10, "EMAC (0x%08X) External Input Interrupt\n",
                    (uint32_t)pD->cfg.regBase);

            (*(pD->cb.extInpIntr))(pD);
        }

    }
}

static void readQueueIsrReg(const CEDI_PrivateData *pD, uint8_t qNum, uint32_t *isrReg)
{
    volatile uint32_t *regPtr = NULL;

    if (qNum > 0U)
    {
        regPtr = intStatusReg[qNum-1U];
        addRegBase(pD, &regPtr);
        *isrReg = CPS_UncachedRead32(regPtr);
    }
}

static void handleQnInterupts(CEDI_PrivateData *pD, uint8_t *handled)
{
    uint32_t isrReg;
    uint32_t events;
    uint8_t  qNum, cond1, cond2, cond3;
    volatile uint32_t *regPtr = NULL;

    /* test for any ISR bits set */

    for (qNum=pD->numQs-1U; qNum>0U; qNum--) {
        /* read Interrupt Status Register */
        readQueueIsrReg(pD, qNum, &isrReg);

        if (0U != isrReg) {

            *handled = 1U;

            /* do clear-write if required */
            if ((0U==pD->hwCfg.irq_read_clear) && (qNum < 16U)) {
                regPtr = intStatusReg[qNum-1U];
                addRegBase(pD, &regPtr);
                CPS_UncachedWrite32(regPtr, isrReg);
            }

            /****************************** TxEvent ****************************/
            cond2 = (uint8_t)EMAC_REGS__INT_Q_STATUS1__TRANSMIT_COMPLETE__READ(isrReg);
            if (0U != cond2)
            {
                events = (0U != cond2)?(uint32_t)CEDI_EV_TX_COMPLETE:0U;

                /* report both events in one callback call */

                (*(pD->cb.txEvent))(pD, events, qNum);
            }

            /****************************** TxError ****************************/

            cond2 = 0U;

            cond2 = (uint8_t)(EMAC_REGS__INT_Q_STATUS1__RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION__READ(
                             isrReg));
            cond3 = (uint8_t)(EMAC_REGS__INT_Q_STATUS1__AMBA_ERROR__READ(isrReg));

            if ( (0U != cond2) || (0U != cond3))
            {
                events = 0U;
                events |= (0U != cond2)?(uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL:0U;
                events |= (0U != cond3)?(uint32_t)CEDI_EV_TX_FR_CORRUPT:0U;

#ifdef DEBUG
                /* read Q ptr for debug */
                if ((qNum > 0U) && (qNum < 16U))
                {
		    uint32_t regVal;
                    regPtr = transmitPtrReg[qNum-1U];
                    addRegBase(pD, &regPtr);
                    regVal = CPS_UncachedRead32(regPtr);

                    vDbgMsg(DBG_GEN_MSG, 10,
                            "EMAC (0x%08X) Tx Error:0x%08X queue:%u tx_q_ptr:"\
                            "0x%08X  isr0=%08X\n", (uint32_t)pD->cfg.regBase,
                            events, qNum, regVal, isrReg);
                }
#endif
                (*(pD->cb.txError))(pD, events, qNum);
            }

            /*************************** RxFrame *******************************/
            if (0U != EMAC_REGS__INT_Q_STATUS1__RECEIVE_COMPLETE__READ(isrReg))
            {
                (*(pD->cb.rxFrame))(pD, qNum);
            }

            /*************************** RxError *******************************/
            cond1 = 0U;
            cond2 = 0U;

            cond1 =(uint8_t)(EMAC_REGS__INT_Q_STATUS1__RX_USED_BIT_READ__READ(isrReg));

	    // for 1p11 GEM release and newer receive overrun is common for all queues
	    if (IsGem1p11(pD) == 1){
		cond2 =(uint8_t)(EMAC_REGS__INT_STATUS__RECEIVE_OVERRUN__READ(isrReg));
	    }

            if ( (0U != cond2) || (0U != cond1))
            {
                events = (0U != cond1)?(uint32_t)CEDI_EV_RX_USED_READ:0U;
                events |= (0U != cond2)?(uint32_t)CEDI_EV_RX_OVERRUN:0U;

                vDbgMsg(DBG_GEN_MSG, 10,
                        "EMAC (0x%08X) Rx Error:0x%08X queue:%u\n",
                        (uint32_t)pD->cfg.regBase, events, qNum);
                (*(pD->cb.rxError))(pD, events, qNum);
            }
            /************************ HResp not OK Event ***********************/
            if (0U != EMAC_REGS__INT_Q_STATUS1__RESP_NOT_OK__READ(isrReg))
            {
                vDbgMsg(DBG_GEN_MSG, 10,
                        "EMAC (0x%08X) HResp not OK, queue:%u\n",
                        (uint32_t)pD->cfg.regBase, qNum);

                (*(pD->cb.hrespError))(pD, qNum);
            }

        }
    } /* for qNum */
}

static void fillEnableQ0ExclusiveEvents(uint32_t events, uint32_t *regVal)
{
    if (0U != (events & (uint32_t)CEDI_EV_MAN_FRAME)) {
        EMAC_REGS__INT_ENABLE__ENABLE_MANAGEMENT_DONE_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_USED_READ)) {
        EMAC_REGS__INT_ENABLE__ENABLE_TRANSMIT_USED_BIT_READ_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_UNDERRUN)) {
        EMAC_REGS__INT_ENABLE__ENABLE_TRANSMIT_BUFFER_UNDER_RUN_INTERRUPT__SET
        (*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PCS_LINK_CHANGE_DET)) {
        EMAC_REGS__INT_ENABLE__ENABLE_LINK_CHANGE_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PCS_AN_COMPLETE)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PCS_AUTO_NEGOTIATION_COMPLETE_INTERRUPT__SET
        (*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PCS_LP_PAGE_RX)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PCS_LINK_PARTNER_PAGE_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TSU_SEC_INC)) {
        EMAC_REGS__INT_ENABLE__ENABLE_TSU_SECONDS_REGISTER_INCREMENT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TSU_TIME_MATCH)) {
        EMAC_REGS__INT_ENABLE__ENABLE_TSU_TIMER_COMPARISON_INTERRUPT__SET(*regVal);
    }


    if (0U != (events & (uint32_t)CEDI_EV_RX_OVERRUN)) {
        EMAC_REGS__INT_ENABLE__ENABLE_RECEIVE_OVERRUN_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PAUSE_NZ_QU_RX)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PAUSE_FRAME_WITH_NON_ZERO_PAUSE_QUANTUM_INTERRUPT__SET
        (*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PAUSE_TIME_ZERO)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PAUSE_TIME_ZERO_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PAUSE_FRAME_TX)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PAUSE_FRAME_TRANSMITTED_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_EXT_INTR)) {
        EMAC_REGS__INT_ENABLE__ENABLE_EXTERNAL_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_RX_DLY_REQ)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PTP_DELAY_REQ_FRAME_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_RX_SYNC)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PTP_SYNC_FRAME_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_TX_DLY_REQ)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PTP_DELAY_REQ_FRAME_TRANSMITTED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_TX_SYNC)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PTP_SYNC_FRAME_TRANSMITTED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_RX_PDLY_REQ)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PTP_PDELAY_REQ_FRAME_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_RX_PDLY_RSP)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PTP_PDELAY_RESP_FRAME_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_TX_PDLY_REQ)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PTP_PDELAY_REQ_FRAME_TRANSMITTED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_TX_PDLY_RSP)) {
        EMAC_REGS__INT_ENABLE__ENABLE_PTP_PDELAY_RESP_FRAME_TRANSMITTED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_LPI_CH_RX)) {
        EMAC_REGS__INT_ENABLE__ENABLE_RX_LPI_INDICATION_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_WOL_RX)) {
        EMAC_REGS__INT_ENABLE__ENABLE_WOL_EVENT_RECEIVED_INTERRUPT__SET(*regVal);
    }


    if (0U != (events & (uint32_t)CEDI_EV_RX_LOCKUP)) {
	 EMAC_REGS__INT_ENABLE__ENABLE_RX_LOCKUP_DETECTED_INTERRUPT__SET
	    (*regVal);
    }
    if (0U != (events & (uint32_t)CEDI_EV_TX_LOCKUP)) {
	 EMAC_REGS__INT_ENABLE__ENABLE_TX_LOCKUP_DETECTED_INTERRUPT__SET
	    (*regVal);
    }
}

static void enableQ0Events(CEDI_PrivateData *pD, uint32_t events)
{
    uint32_t regVal = 0U;

    fillEnableQ0ExclusiveEvents(events, &regVal);

    if (0U != (events & (uint32_t)CEDI_EV_RX_COMPLETE)) {
        EMAC_REGS__INT_ENABLE__ENABLE_RECEIVE_COMPLETE_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_RX_USED_READ)) {
        EMAC_REGS__INT_ENABLE__ENABLE_RECEIVE_USED_BIT_READ_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL)) {
        EMAC_REGS__INT_ENABLE__ENABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT__SET
        (regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_FR_CORRUPT)) {
        EMAC_REGS__INT_ENABLE__ENABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT__SET
        (regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_COMPLETE)) {
        EMAC_REGS__INT_ENABLE__ENABLE_TRANSMIT_COMPLETE_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_HRESP_NOT_OK)) {
        EMAC_REGS__INT_ENABLE__ENABLE_RESP_NOT_OK_INTERRUPT__SET(regVal);
    }


    CPS_UncachedWrite32(&(pD->regs->int_enable), regVal);
}

static void enableQnEvents(const CEDI_PrivateData *pD, uint32_t events, uint8_t queueNum)
{
    uint32_t regVal = 0U;
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    volatile uint32_t* const intEnableReg[15U] = {
        CEDI_RegOff(int_q1_enable),
        CEDI_RegOff(int_q2_enable),
        CEDI_RegOff(int_q3_enable),
        CEDI_RegOff(int_q4_enable),
        CEDI_RegOff(int_q5_enable),
        CEDI_RegOff(int_q6_enable),
        CEDI_RegOff(int_q7_enable),
        CEDI_RegOff(int_q8_enable),
        CEDI_RegOff(int_q9_enable),
        CEDI_RegOff(int_q10_enable),
        CEDI_RegOff(int_q11_enable),
        CEDI_RegOff(int_q12_enable),
        CEDI_RegOff(int_q13_enable),
        CEDI_RegOff(int_q14_enable),
        CEDI_RegOff(int_q15_enable)
    };

    if (0U != (events & (uint32_t)CEDI_EV_RX_COMPLETE)) {
        EMAC_REGS__INT_Q_ENABLE__ENABLE_RECEIVE_COMPLETE_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_RX_USED_READ)) {
        EMAC_REGS__INT_Q_ENABLE__ENABLE_RX_USED_BIT_READ_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL)) {
        EMAC_REGS__INT_Q_ENABLE__ENABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT__SET
        (regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_FR_CORRUPT)) {
        EMAC_REGS__INT_Q_ENABLE__ENABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT__SET
        (regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_COMPLETE)) {
        EMAC_REGS__INT_Q_ENABLE__ENABLE_TRANSMIT_COMPLETE_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_HRESP_NOT_OK)) {
        EMAC_REGS__INT_Q_ENABLE__ENABLE_RESP_NOT_OK_INTERRUPT__SET(regVal);
    }

    /* write to interrupt enable register */
    if (queueNum==CEDI_ALL_QUEUES) {
        for (i = 1U; i < pD->numQs; i++) {
            regPtr = intEnableReg[i-1U];
            addRegBase(pD, &regPtr);
            CPS_UncachedWrite32(regPtr, regVal);
        }
    }
    if (queueNum < 16U) {
        regPtr = intEnableReg[queueNum-1U];
        addRegBase(pD, &regPtr);
        CPS_UncachedWrite32(regPtr, regVal);
    }
}

static void fillDisableQ0ExclusiveEvents(uint32_t events, uint32_t *regVal)
{

    if (0U != (events & (uint32_t)CEDI_EV_MAN_FRAME)) {
        EMAC_REGS__INT_DISABLE__DISABLE_MANAGEMENT_DONE_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_USED_READ)) {
        EMAC_REGS__INT_DISABLE__DISABLE_TRANSMIT_USED_BIT_READ_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_UNDERRUN)) {
        EMAC_REGS__INT_DISABLE__DISABLE_TRANSMIT_BUFFER_UNDER_RUN_INTERRUPT__SET
        (*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PCS_LINK_CHANGE_DET)) {
        EMAC_REGS__INT_DISABLE__DISABLE_LINK_CHANGE_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PCS_AN_COMPLETE)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PCS_AUTO_NEGOTIATION_COMPLETE_INTERRUPT__SET
        (*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PCS_LP_PAGE_RX)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PCS_LINK_PARTNER_PAGE_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TSU_SEC_INC)) {
        EMAC_REGS__INT_DISABLE__DISABLE_TSU_SECONDS_REGISTER_INCREMENT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TSU_TIME_MATCH)) {
        EMAC_REGS__INT_DISABLE__DISABLE_TSU_TIMER_COMPARISON_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_RX_OVERRUN)) {
        EMAC_REGS__INT_DISABLE__DISABLE_RECEIVE_OVERRUN_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PAUSE_NZ_QU_RX)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PAUSE_FRAME_WITH_NON_ZERO_PAUSE_QUANTUM_INTERRUPT__SET
        (*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PAUSE_TIME_ZERO)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PAUSE_TIME_ZERO_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PAUSE_FRAME_TX)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PAUSE_FRAME_TRANSMITTED_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_EXT_INTR)) {
        EMAC_REGS__INT_DISABLE__DISABLE_EXTERNAL_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_RX_DLY_REQ)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PTP_DELAY_REQ_FRAME_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_RX_SYNC)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PTP_SYNC_FRAME_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_TX_DLY_REQ)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PTP_DELAY_REQ_FRAME_TRANSMITTED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_TX_SYNC)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PTP_SYNC_FRAME_TRANSMITTED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_RX_PDLY_REQ)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PTP_PDELAY_REQ_FRAME_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_RX_PDLY_RSP)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PTP_PDELAY_RESP_FRAME_RECEIVED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_TX_PDLY_REQ)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PTP_PDELAY_REQ_FRAME_TRANSMITTED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_PTP_TX_PDLY_RSP)) {
        EMAC_REGS__INT_DISABLE__DISABLE_PTP_PDELAY_RESP_FRAME_TRANSMITTED__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_LPI_CH_RX)) {
        EMAC_REGS__INT_DISABLE__DISABLE_RX_LPI_INDICATION_INTERRUPT__SET(*regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_WOL_RX)) {
        EMAC_REGS__INT_DISABLE__DISABLE_WOL_EVENT_RECEIVED_INTERRUPT__SET(*regVal);
    }


    if (0U != (events & (uint32_t)CEDI_EV_RX_LOCKUP)) {
	 EMAC_REGS__INT_DISABLE__DISABLE_RX_LOCKUP_DETECTED_INTERRUPT__SET
	    (*regVal);
    }
    if (0U != (events & (uint32_t)CEDI_EV_TX_LOCKUP)) {
	 EMAC_REGS__INT_DISABLE__DISABLE_TX_LOCKUP_DETECTED_INTERRUPT__SET
	    (*regVal);
    }
}

static void disableQ0Events(CEDI_PrivateData *pD, uint32_t events)
{
    uint32_t regVal = 0U;

    fillDisableQ0ExclusiveEvents(events, &regVal);

    if (0U != (events & (uint32_t)CEDI_EV_RX_COMPLETE)) {
        EMAC_REGS__INT_DISABLE__DISABLE_RECEIVE_COMPLETE_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_RX_USED_READ)) {
        EMAC_REGS__INT_DISABLE__DISABLE_RECEIVE_USED_BIT_READ_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL)) {
        EMAC_REGS__INT_DISABLE__DISABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT__SET
        (regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_FR_CORRUPT)) {
        EMAC_REGS__INT_DISABLE__DISABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT__SET
        (regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_COMPLETE)) {
        EMAC_REGS__INT_DISABLE__DISABLE_TRANSMIT_COMPLETE_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_HRESP_NOT_OK)) {
        EMAC_REGS__INT_DISABLE__DISABLE_RESP_NOT_OK_INTERRUPT__SET(regVal);
    }

    CPS_UncachedWrite32(&(pD->regs->int_disable), regVal);
}

static void disableQnEvents(const CEDI_PrivateData *pD, uint32_t events, uint8_t queueNum)
{
    uint32_t regVal = 0U;
    volatile uint32_t *regPtr = NULL;
    uint8_t i;

    if (0U != (events & (uint32_t)CEDI_EV_RX_COMPLETE)) {
        EMAC_REGS__INT_Q_DISABLE__DISABLE_RECEIVE_COMPLETE_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_RX_USED_READ)) {
        EMAC_REGS__INT_Q_DISABLE__DISABLE_RX_USED_BIT_READ_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL)) {
        EMAC_REGS__INT_Q_DISABLE__DISABLE_RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT__SET
        (regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_FR_CORRUPT)) {
        EMAC_REGS__INT_Q_DISABLE__DISABLE_TRANSMIT_FRAME_CORRUPTION_DUE_TO_AMBA_ERROR_INTERRUPT__SET
        (regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_TX_COMPLETE)) {
        EMAC_REGS__INT_Q_DISABLE__DISABLE_TRANSMIT_COMPLETE_INTERRUPT__SET(regVal);
    }

    if (0U != (events & (uint32_t)CEDI_EV_HRESP_NOT_OK)) {
        EMAC_REGS__INT_Q_DISABLE__DISABLE_RESP_NOT_OK_INTERRUPT__SET(regVal);
    }

    /* write to interrupt disable register */
    if (queueNum==CEDI_ALL_QUEUES) {
        for (i = 1U; i < pD->numQs; i++) {
            regPtr = intDisableReg[i-1U];
            addRegBase(pD, &regPtr);
            CPS_UncachedWrite32(regPtr, regVal);
        }
    }
    if ((queueNum < 16U) && (queueNum > 0U)) {
        regPtr = intDisableReg[queueNum-1U];
        addRegBase(pD, &regPtr);
        CPS_UncachedWrite32(regPtr, regVal);
    }
}

static void fillGetQ0ExclusiveEventEnable(CEDI_PrivateData *pD, uint32_t *ret, uint32_t regVal)
{
    if (0U != EMAC_REGS__INT_MASK__MANAGEMENT_DONE_INTERRUPT_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_MAN_FRAME;
    }

    if (0U != EMAC_REGS__INT_MASK__TRANSMIT_USED_BIT_READ_INTERRUPT_MASK__READ(
            regVal)) {
        *ret |= (uint32_t)CEDI_EV_TX_USED_READ;
    }

    if (0U != EMAC_REGS__INT_MASK__TRANSMIT_BUFFER_UNDER_RUN_INTERRUPT_MASK__READ(
            regVal))  {
        *ret |= (uint32_t)CEDI_EV_TX_UNDERRUN;
    }

    if (pD->hwCfg.no_pcs == 0){
	if (0U != EMAC_REGS__INT_MASK__LINK_CHANGE_INTERRUPT_MASK__READ(regVal)) {
	    *ret |= (uint32_t)CEDI_EV_PCS_LINK_CHANGE_DET;
	}

	if (0U != EMAC_REGS__INT_MASK__PCS_AUTO_NEGOTIATION_COMPLETE_INTERRUPT_MASK__READ(regVal)) {
	    *ret |= (uint32_t)CEDI_EV_PCS_AN_COMPLETE;
	}

	if (0U != EMAC_REGS__INT_MASK__PCS_LINK_PARTNER_PAGE_MASK__READ(regVal)) {
	    *ret |= (uint32_t)CEDI_EV_PCS_LP_PAGE_RX;
	}
    }

    if (0U != EMAC_REGS__INT_MASK__TSU_SECONDS_REGISTER_INCREMENT_MASK__READ(
									     regVal)) {
	*ret |= (uint32_t)CEDI_EV_TSU_SEC_INC;
    }

    if (0U != EMAC_REGS__INT_MASK__TSU_TIMER_COMPARISON_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_TSU_TIME_MATCH;
    }

    if (0U != EMAC_REGS__INT_MASK__RECEIVE_OVERRUN_INTERRUPT_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_RX_OVERRUN;
    }

    if (0U != EMAC_REGS__INT_MASK__PAUSE_FRAME_WITH_NON_ZERO_PAUSE_QUANTUM_INTERRUPT_MASK__READ(
            regVal)) {
        *ret |= (uint32_t)CEDI_EV_PAUSE_NZ_QU_RX;
    }

    if (0U != EMAC_REGS__INT_MASK__PAUSE_TIME_ZERO_INTERRUPT_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_PAUSE_TIME_ZERO;
    }

    if (0U != EMAC_REGS__INT_MASK__PAUSE_FRAME_TRANSMITTED_INTERRUPT_MASK__READ(
            regVal)) {
        *ret |= (uint32_t)CEDI_EV_PAUSE_FRAME_TX;
    }

    if (0U != EMAC_REGS__INT_MASK__EXTERNAL_INTERRUPT_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_EXT_INTR;
    }

    if (0U != EMAC_REGS__INT_MASK__PTP_DELAY_REQ_FRAME_RECEIVED_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_PTP_RX_DLY_REQ;
    }

    if (0U != EMAC_REGS__INT_MASK__PTP_SYNC_FRAME_RECEIVED_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_PTP_RX_SYNC;
    }

    if (0U != EMAC_REGS__INT_MASK__PTP_DELAY_REQ_FRAME_TRANSMITTED_MASK__READ(
            regVal)) {
        *ret |= (uint32_t)CEDI_EV_PTP_TX_DLY_REQ;
    }

    if (0U != EMAC_REGS__INT_MASK__PTP_SYNC_FRAME_TRANSMITTED_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_PTP_TX_SYNC;
    }

    if (0U != EMAC_REGS__INT_MASK__PTP_PDELAY_REQ_FRAME_RECEIVED_MASK__READ(
            regVal)) {
        *ret |= (uint32_t)CEDI_EV_PTP_RX_PDLY_REQ;
    }

    if (0U != EMAC_REGS__INT_MASK__PTP_PDELAY_RESP_FRAME_RECEIVED_MASK__READ(
            regVal)) {
        *ret |= (uint32_t)CEDI_EV_PTP_RX_PDLY_RSP;
    }

    if (0U != EMAC_REGS__INT_MASK__PTP_PDELAY_REQ_FRAME_TRANSMITTED_MASK__READ(
            regVal)) {
        *ret |= (uint32_t)CEDI_EV_PTP_TX_PDLY_REQ;
    }

    if (0U != EMAC_REGS__INT_MASK__PTP_PDELAY_RESP_FRAME_TRANSMITTED_MASK__READ(
            regVal)) {
        *ret |= (uint32_t)CEDI_EV_PTP_TX_PDLY_RSP;
    }

    if (0U != EMAC_REGS__INT_MASK__RX_LPI_INDICATION_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_LPI_CH_RX;
    }

    if (0U != EMAC_REGS__INT_MASK__WOL_EVENT_RECEIVED_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_WOL_RX;
    }


    if (0U != EMAC_REGS__INT_MASK__RX_LOCKUP_DETECTED_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_RX_LOCKUP;
    }
    if (0U != EMAC_REGS__INT_MASK__TX_LOCKUP_DETECTED_MASK__READ(regVal)) {
        *ret |= (uint32_t)CEDI_EV_TX_LOCKUP;
    }

}

static void getQ0EventEnable(CEDI_PrivateData *pD, uint32_t *events)
{
    uint32_t ret = 0U;
    uint32_t regVal = 0U;
    regVal = ~CPS_UncachedRead32(&(pD->regs->int_mask));

    if (0U == IsGem1p11(pD)){
	regVal &= ~EMAC_REGS__INT_MASK__RX_LOCKUP_DETECTED_MASK__MASK;
	regVal &= ~EMAC_REGS__INT_MASK__TX_LOCKUP_DETECTED_MASK__MASK;
    }
    if (0U != regVal) {

        fillGetQ0ExclusiveEventEnable(pD, &ret, regVal);

        if (0U != EMAC_REGS__INT_MASK__RECEIVE_COMPLETE_INTERRUPT_MASK__READ(regVal)) {
            ret |= (uint32_t)CEDI_EV_RX_COMPLETE;
        }

        if (0U != EMAC_REGS__INT_MASK__RECEIVE_USED_BIT_READ_INTERRUPT_MASK__READ(
                regVal)) {
            ret |= (uint32_t)CEDI_EV_RX_USED_READ;
        }

#ifdef EMAC_REGS__INT_MASK__RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_MASK__READ
        if (0U != EMAC_REGS__INT_MASK__RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_MASK__READ(
                regVal)) {
            ret |= (uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL;
        }
#endif

        if (0U != EMAC_REGS__INT_MASK__AMBA_ERROR_INTERRUPT_MASK__READ(regVal)) {
            ret |= (uint32_t)CEDI_EV_TX_FR_CORRUPT;
        }

        if (0U != EMAC_REGS__INT_MASK__TRANSMIT_COMPLETE_INTERRUPT_MASK__READ(regVal)) {
            ret |= (uint32_t)CEDI_EV_TX_COMPLETE;
        }

        if (0U != EMAC_REGS__INT_MASK__RESP_NOT_OK_INTERRUPT_MASK__READ(regVal)) {
            ret |= (uint32_t)CEDI_EV_HRESP_NOT_OK;
        }

    }
    (*events) = ret;
}

static void getQnEventEnable(const CEDI_PrivateData *pD, uint32_t *events, uint8_t queueNum)
{
    uint32_t ret = 0U;
    uint32_t regVal = 0U;
    volatile uint32_t *regPtr = NULL;

    volatile uint32_t* const intMaskReg[15U] = {
        CEDI_RegOff(int_q1_mask),
        CEDI_RegOff(int_q2_mask),
        CEDI_RegOff(int_q3_mask),
        CEDI_RegOff(int_q4_mask),
        CEDI_RegOff(int_q5_mask),
        CEDI_RegOff(int_q6_mask),
        CEDI_RegOff(int_q7_mask),
        CEDI_RegOff(int_q8_mask),
        CEDI_RegOff(int_q9_mask),
        CEDI_RegOff(int_q10_mask),
        CEDI_RegOff(int_q11_mask),
        CEDI_RegOff(int_q12_mask),
        CEDI_RegOff(int_q13_mask),
        CEDI_RegOff(int_q14_mask),
        CEDI_RegOff(int_q15_mask)
    };

    if (queueNum > 0U)
    {
        regPtr = intMaskReg[queueNum-1U];
        addRegBase(pD, &regPtr);
        regVal = ~CPS_UncachedRead32(regPtr);

        if (0U != regVal) {
            if (0U != EMAC_REGS__INT_Q_MASK__RECEIVE_COMPLETE_INTERRUPT_MASK__READ(
                    regVal)) {
                ret |= (uint32_t)CEDI_EV_RX_COMPLETE;
            }

            if (0U != EMAC_REGS__INT_Q_MASK__RX_USED_INTERRUPT_MASK__READ(
                    regVal)) {
                ret |= (uint32_t)CEDI_EV_RX_USED_READ;
            }

                if (0U != EMAC_REGS__INT_Q_MASK__RETRY_LIMIT_EXCEEDED_OR_LATE_COLLISION_INTERRUPT_MASK__READ(
                    regVal)) {
                ret |= (uint32_t)CEDI_EV_TX_RETRY_EX_LATE_COLL;
            }
    
            if (0U != EMAC_REGS__INT_Q_MASK__AMBA_ERROR_INTERRUPT_MASK__READ(regVal)) {
                ret |= (uint32_t)CEDI_EV_TX_FR_CORRUPT;
            }

            if (0U != EMAC_REGS__INT_Q_MASK__TRANSMIT_COMPLETE_INTERRUPT_MASK__READ(
                    regVal)) {
                ret |= (uint32_t)CEDI_EV_TX_COMPLETE;
            }

            if (0U != EMAC_REGS__INT_Q_MASK__RESP_NOT_OK_INTERRUPT_MASK__READ(regVal)) {
                ret |= (uint32_t)CEDI_EV_HRESP_NOT_OK;
            }
        }
    }
    (*events) = ret;
}

static void setFrerRedundancyTag(const CEDI_FrameEliminationConfig* fec, uint32_t *reg)
{
    if (fec->seqNumIdentification == CEDI_SEQ_NUM_IDEN_TAG) {
        EMAC_REGS__FRER_CONTROL_A__USE_R_TAG__SET(*reg);
    } else {
        if (fec->seqNumIdentification == CEDI_SEQ_NUM_IDEN_OFFSET) {
            EMAC_REGS__FRER_CONTROL_A__USE_R_TAG__CLR(*reg);
        }
    }
}

static void getFrerRedundancyTag(CEDI_FrameEliminationConfig* fec, uint32_t reg)
{
    if (0U != EMAC_REGS__FRER_CONTROL_A__USE_R_TAG__READ(reg)) {
	    fec->seqNumIdentification = CEDI_SEQ_NUM_IDEN_TAG;
	} else {
	    fec->seqNumIdentification = CEDI_SEQ_NUM_IDEN_OFFSET;
    }
}

static void calcNumQueueSegs(const CEDI_PrivateData *pD, uint32_t *numQSegs)
{
    uint8_t i;
    const uint32_t segs[16] = {
        pD->hwCfg.tx_pbuf_num_segments_q0,
        pD->hwCfg.tx_pbuf_num_segments_q1,
        pD->hwCfg.tx_pbuf_num_segments_q2,
        pD->hwCfg.tx_pbuf_num_segments_q3,
        pD->hwCfg.tx_pbuf_num_segments_q4,
        pD->hwCfg.tx_pbuf_num_segments_q5,
        pD->hwCfg.tx_pbuf_num_segments_q6,
        pD->hwCfg.tx_pbuf_num_segments_q7,
        pD->hwCfg.tx_pbuf_num_segments_q8,
        pD->hwCfg.tx_pbuf_num_segments_q9,
        pD->hwCfg.tx_pbuf_num_segments_q10,
        pD->hwCfg.tx_pbuf_num_segments_q11,
        pD->hwCfg.tx_pbuf_num_segments_q12,
        pD->hwCfg.tx_pbuf_num_segments_q13,
        pD->hwCfg.tx_pbuf_num_segments_q14,
        pD->hwCfg.tx_pbuf_num_segments_q15
    };

    *numQSegs = 0U;

    for (i=0U; i<pD->numQs; i++) {
        if (segs[i] < 16U) {
            *numQSegs += 1U<<segs[i];
        } else {
            vDbgMsg(DBG_GEN_MSG, 10, "%s\n",
                    "Warning: Wrong tx_pbuf_num_segments read from hardware "\
                    "register, setting to 15");
            *numQSegs += (uint32_t) 1UL << 15U;
        }
    }
}

static CEDI_PrivateData *initExpressMacPD(CEDI_PrivateData *pD, const CEDI_Config *config)
{
    uint32_t pmacPDSize, pmacTxDescListSize = 0U, pmacRxDescListSize = 0U;
    uint16_t txDescSize, rxDescSize;
    CEDI_PrivateData *epD = NULL;

    pmacPDSize = (uint32_t) alignedToPtr((uint16_t) (sizeof(CEDI_PrivateData)));
    calcDescriptorSizes(config, &txDescSize, &rxDescSize);
    pmacPDSize += (uint32_t) (numTxDescriptors(config) * sizeof(uintptr_t));
    pmacPDSize += (uint32_t) (numRxDescriptors(config) * sizeof(uintptr_t));

    pmacTxDescListSize = numTxDescriptors(config) * txDescSize;
    pmacRxDescListSize = numRxDescriptors(config) * rxDescSize;

    pD->macType = CEDI_MAC_TYPE_PMAC;
    pD->otherMac = (CEDI_PrivateData *)((uint8_t *)pD + pmacPDSize);
    pD->otherMac->macType = CEDI_MAC_TYPE_EMAC;
    pD->otherMac->otherMac = pD;

    epD = pD->otherMac;
    epD->cfg = pD->cfg;
    epD->cfg.regBase += CEDI_EXPRESS_MAC_REGS_OFFSET;
    epD->regs = regBaseToPtr(epD->cfg.regBase);
    epD->cb = pD->cb;
    epD->cfg.rxQs = 1U;
    epD->cfg.txQs = 1U;
    epD->numQs = 1U;
    epD->cfg.rxQLen[0] = epD->cfg.eRxQLen;
    epD->cfg.txQLen[0] = epD->cfg.eTxQLen;

    epD->cfg.txQPhyAddr += pmacTxDescListSize;
    epD->cfg.rxQPhyAddr += pmacRxDescListSize;
    epD->cfg.txQAddr += pmacTxDescListSize;
    epD->cfg.rxQAddr += pmacRxDescListSize;

    /* Check for overflows in lower 32 bits of TX/RX physical addresses */
    if (epD->cfg.txQPhyAddr < config->txQPhyAddr) {
        epD->cfg.upper32BuffTxQAddr++;
    }
    if (epD->cfg.rxQPhyAddr < config->rxQPhyAddr) {
        epD->cfg.upper32BuffRxQAddr++;
    }
    return (epD);
}

static void checkBufferSegmentsDistribution(const CEDI_PrivateData *pD,
                                     uint8_t *hwConfigErr)
{
    uint32_t numTxSegs, numQSegs;
    uint32_t txPbufQSegSize = pD->hwCfg.tx_pbuf_queue_segment_size;
    CEDI_PrivateData *epD = NULL;
    uint32_t eNumTxSegs, eNumQSegs;
    uint32_t eTxPbufQSegSize, eNumQSegsShift;



    /* sanity-check multi-queue packet buffer segments and distribution */
    if ((pD->numQs>1U) && (pD->hwCfg.tx_pkt_buffer != 0U))
    {

        if (txPbufQSegSize >= pD->hwCfg.tx_pbuf_addr) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "Error: H/w configuration specifies Tx segment size %u, "\
                    "must be less than Tx pbuf addr (%u)\n",
                    txPbufQSegSize,
                    pD->hwCfg.tx_pbuf_addr);
            *hwConfigErr = 1U;
        }

        if (txPbufQSegSize < 16U) {
            numTxSegs = 1<<txPbufQSegSize;
        } else {
            vDbgMsg(DBG_GEN_MSG, 10, "%s\n",
                    "Warning: Wrong tx_pbuf_queue_segment_size read from hardware "\
                    "register, using 15 for further checking");
            numTxSegs = 1U << 15U;
        }

        if (numTxSegs<pD->numQs) {
            vDbgMsg(DBG_GEN_MSG, 5, "Error: H/w configuration specifies %u"\
                    " queues but only %u packet buffer segments\n",
                    pD->numQs, numTxSegs);
            *hwConfigErr = 1U;
        }

        calcNumQueueSegs(pD, &numQSegs);

        if (numQSegs>numTxSegs) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "Error: H/w configuration allocates %u Tx packet buffer"\
                    " segments to queues out of %u total\n", numQSegs, numTxSegs);
            *hwConfigErr = 1U;
        }
        if (0U != pD->cfg.incExpressTraffic) {
            epD = pD->otherMac;

            eTxPbufQSegSize = epD->hwCfg.tx_pbuf_queue_segment_size;
            if (eTxPbufQSegSize > 15U) {
                vDbgMsg(DBG_GEN_MSG, 10, "%s\n",
                        "Warning: Wrong tx_pbuf_queue_segment_size read from hardware "\
                        "register (Express MAC), using 15 for further checking");
                eNumTxSegs = 1U << 15U;
            } else {
                eNumTxSegs = 1U << eTxPbufQSegSize;
            }

            eNumQSegsShift = epD->hwCfg.tx_pbuf_num_segments_q0;
            if (eNumQSegsShift > 15U) {
                vDbgMsg(DBG_GEN_MSG, 10, "%s\n",
                        "Warning: Wrong tx_pbuf_num_segments_q0 read from hardware "\
                        "register (Express MAC), using 15 for further checking");
                eNumQSegs = 1U << 15;
            } else {
                eNumQSegs = 1U << eNumQSegsShift;
            }

            if (eNumQSegs>eNumTxSegs) {
                vDbgMsg(DBG_GEN_MSG, 5,
                        "Error: H/w configuration (Express MAC) allocates %u Tx packet buffer"\
                        " segments to queues out of %u total\n", eNumQSegs, eNumTxSegs);
                *hwConfigErr = 1U;
            }
        }
    }
}

static uint32_t setNumQueuesFromConfig(CEDI_PrivateData *pD,
                            const CEDI_Config *config)
{
    CEDI_PrivateData *epD = NULL;
    uint32_t paramErr = 0U;
    pD->numQs = pD->hwCfg.numQueues;
        if ((config->rxQs==0U) || (config->rxQs > pD->numQs) ||
                (config->txQs==0U) || (config->txQs > pD->numQs)) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                    "Error: out-of-range numQs parameter");
            paramErr = 1U;
        }
        pD->rxQs = config->rxQs;
        pD->txQs = config->txQs;
        if (0U != config->incExpressTraffic) {
            epD = pD->otherMac;
            epD->rxQs = epD->cfg.rxQs;
            epD->txQs = epD->cfg.txQs;
        }
    return (paramErr);
}

static uint32_t checkRxQLengths(const CEDI_Config *config)
{
    uint8_t i;
    uint32_t paramErr = 0U;
    for (i=0U; i<config->rxQs; i++) {
        if (config->rxQLen[i]>CEDI_MAX_RBQ_LENGTH) {
            paramErr = 1U;
            vDbgMsg(DBG_GEN_MSG, 5,
                    "Error: out-of-range rxQLen(%u) parameter\n", i);
            break;
        }
    }
    return (paramErr);
}

static uint32_t descAddrNullCheck(const CEDI_Config *config)
{
    uint32_t paramErr = 0U;
    if ((config->txQAddr==0U) ||
                (config->txQPhyAddr==0U) ||
                (config->rxQAddr==0U) ||
                (config->rxQPhyAddr==0U)) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                "Error: NULL Tx or Rx descriptor address parameter");
        paramErr = 1U;
    }
    return (paramErr);
}

static uint32_t checkTxQLengths(const CEDI_Config *config)
{
    uint8_t i;
    uint32_t paramErr = 0U;
    for (i=0U; i<config->txQs; i++) {
        if (config->txQLen[i]>CEDI_MAX_TBQ_LENGTH) {
            paramErr = 1U;
            vDbgMsg(DBG_GEN_MSG, 5,
                    "Error: out-of-range txQLen(%u) parameter\n", i);
            break;
        }
    }
    return (paramErr);
}

static uint32_t checkDmaAddressingWidth(const CEDI_PrivateData *pD,
                             const CEDI_Config *config)
{
    uint32_t paramErr = 0U;
    if ((config->dmaAddrBusWidth != 0U) &&
            (pD->hwCfg.dma_addr_width == 0U))
    {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                "Error: 64-bit DMA addressing not supported in h/w config");
        paramErr = 1U;
    }
    return (paramErr);
}

static uint32_t checkPacketBuffSizes(const CEDI_Config *config)
{
    uint32_t paramErr = 0U;
    uint8_t i;
    paramErr = ((config->txPktBufSize>1U) || (config->rxPktBufSize>3U));
    if (0U == paramErr) {
        for (i=0U; i<config->rxQs; i++) {
            paramErr = (paramErr != 0U) || (config->rxBufLength[i]==0U);
        }
    }
    if (0U != paramErr) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                "Error: Invalid Packet buffer size or Rx buffer length");
    }
    return (paramErr);
}

static uint32_t checkDmaDataBurstLen(const CEDI_Config *config)
{
    uint32_t paramErr = 0U;
    if ((config->dmaDataBurstLen)>CEDI_DMA_DBUR_LEN_16) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                "Error: Requested DMA burst length value out of range");
        paramErr = 1U;
    }
    return (paramErr);
}

static uint32_t checkDmaBusWidth(const CEDI_PrivateData *pD,
                             const CEDI_Config *config)
{
    uint32_t paramErr = 0U;
    uint8_t HwDmaBusWidth = pD->hwCfg.dma_bus_width;
    uint32_t dmaBusWidth;
    uint8_t dmaBusWidthShift = (uint8_t)(config->dmaBusWidth);

    if (dmaBusWidthShift <= (uint8_t)CEDI_DMA_BUS_WIDTH_128) {
        dmaBusWidth = (uint32_t)1UL << dmaBusWidthShift;
    } else {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                "Incorrect dmaBusWidth requested");
        paramErr = 1;
    }
    if (paramErr == 0U) {
        vDbgMsg(DBG_GEN_MSG, 10, "1 << config->dmaBusWidth = %u, "\
                "pD->hwCfg.dma_bus_width = %u\n",
                dmaBusWidth, HwDmaBusWidth);
        if (dmaBusWidth > HwDmaBusWidth) {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                    "Error: Requested DMA bus width greater than h/w allows");
            paramErr = 1U;
        }
    }
    return (paramErr);
}

static uint32_t checkRxBuffDescAlignment(const CEDI_Config *config)
{
    uint32_t paramErr = 0U;
    /* enforce 32- or 64-bit alignment for RX buffers only */
    if (config->dmaBusWidth==CEDI_DMA_BUS_WIDTH_32) {
        paramErr = ((config->rxQPhyAddr) % 4U);
    } else {  /* expect 64-bit word alignment for 64/128-bit bus */
        paramErr = ((config->rxQPhyAddr) % 8U);
    }

    if (0U != paramErr) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                "Error: bad alignment of descriptor list memory");
    }
    return (paramErr);
}

static uint32_t checkInterfaceTypeSelection(const CEDI_PrivateData *pD,
                                 uint8_t *hwConfigErr)
{
    uint32_t paramErr = 0U;
    paramErr = pD->cfg.ifTypeSel>CEDI_IFSP_2500BASE_X;
    if (0U!=paramErr) {
        vDbgMsg(DBG_GEN_MSG, 5,
                "Error: ifTypeSel out of range 0-CEDI_IFSP_2500BASE_X (%u)\n",
                pD->cfg.ifTypeSel);
    }

    if ((paramErr == 0U) && (is2p5GSupported(pD) == 0U)) {
        (*hwConfigErr) = pD->cfg.ifTypeSel>CEDI_IFSP_1000BASE_X;
        if (0U!=(*hwConfigErr)) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "Error: ifTypeSel out of range 0-CEDI_IFSP_1000BASE_X (%u)\n",
                    pD->cfg.ifTypeSel);
        }
    }

    return (paramErr);
}

static uint32_t checkRxBufOffset(const CEDI_PrivateData *pD)
{
    uint32_t paramErr = 0U;
    paramErr = pD->cfg.rxBufOffset>3U;
    if (0U!=paramErr) {
        vDbgMsg(DBG_GEN_MSG, 5,
                "Error: rxBufOffset out of range 0-3 bytes (%u)\n",
                pD->cfg.rxBufOffset);
    }
    return (paramErr);
}

static uint32_t checkMdcPclkdiv(const CEDI_Config *config)
{
    uint32_t paramErr = 0U;
    paramErr = config->mdcPclkDiv>CEDI_MDC_DIV_BY_224;
    if (0U!=paramErr) {
        vDbgMsg(DBG_GEN_MSG, 5,
                "Error: mdcPclkDiv out of range (%u)\n",
                config->mdcPclkDiv);
    }
    return (paramErr);
}

static uint32_t initTxRxDescLists(CEDI_PrivateData *pD, const CEDI_Config *config)
{
    uint32_t status = 0U;
    CEDI_PrivateData *epD = NULL;

    if (0U != config->incExpressTraffic) {
        epD = pD->otherMac;
        calcDescriptorSizes(config, &epD->txDescriptorSize,
                                     &epD->rxDescriptorSize);
    }

    calcDescriptorSizes(config, &(pD->txDescriptorSize),
                                 &(pD->rxDescriptorSize));

    /* DMA config register */
    initDmaConfigReg(pD);

    /* writing the upper 32 bit buffer queue base address from config */
    if (initUpper32BuffQAddr(pD))
	status = EINVAL;

    if (0U == status) {
	if (0U!=initTxDescLists(pD)) {
	    status = EINVAL;
	}
    }

    if (0U == status) {
        if (0U!=initRxDescLists(pD)) {
            status = EINVAL;
        }
    }

    if ((0U != config->incExpressTraffic) && (0U == status)) {
        initDmaConfigReg(epD);

	if (0U == status) {
	    if (initUpper32BuffQAddr(epD))
		status = EIO;
	}

	if (0U == status) {
	    if (0U!=initTxDescLists(epD)) {
		status = EINVAL;
	    }
	}
	if (0U == status) {
            if (0U!=initRxDescLists(epD)) {
                status = EINVAL;
            }
        }
    }
    return (status);
}

static uint32_t initHardwareScreeners(CEDI_PrivateData *pD)
{
    uint32_t retVal = 0;
    CEDI_T1Screen clrT1ScrnRead;
    int i;
    CEDI_T1Screen clrT1Scrn = {0, 0, 0, 0, 0};
    CEDI_T2Screen clrT2Scrn = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    for (i=0; i<((pD->hwCfg.num_type1_screeners)-1); i++) {
	retVal = emacSetType1ScreenReg(pD, i, &clrT1Scrn);
	if (0U != retVal) {
	    vDbgMsg(DBG_GEN_MSG, 10,
		    "Probe: Hardware initialization: emacSetType1ScreenReg "\
		    "returned with code: %u\n", retVal);
	    break;
	}

	retVal = emacGetType1ScreenReg(pD, i, &clrT1ScrnRead);
	if (0U != retVal) {
	    vDbgMsg(DBG_GEN_MSG, 10,
		    "Probe: Hardware initialization: emacGetType1ScreenReg "\
		    "returned with code: %u\n", retVal);
	    break;
	}
	if (CmpBuffs(&clrT1Scrn, &clrT1ScrnRead, sizeof(clrT1Scrn))){
	    retVal = EIO;
	    vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: Written and read screener T1 are different\n");
	    break;
	}
    }

    if (0U == retVal){
	CEDI_T2Screen clrT2ScrnRead;
	for (i=0; i<((pD->hwCfg.num_type2_screeners)-1); i++) {
	    retVal = emacSetType2ScreenReg(pD, i, &clrT2Scrn);
	    if (0U != retVal) {
		vDbgMsg(DBG_GEN_MSG, 10,
			"Probe: Hardware initialization: emacSetType2ScreenReg "\
			"returned with code: %u\n", retVal);
		break;
	    }
	    retVal = emacGetType2ScreenReg(pD, i, &clrT2ScrnRead);
	    if (0U != retVal) {
		vDbgMsg(DBG_GEN_MSG, 10,
			"Probe: Hardware initialization: emacGetType2ScreenReg "\
			"returned with code: %u\n", retVal);
		break;
	    }
	    if (CmpBuffs(&clrT2Scrn, &clrT2ScrnRead, sizeof(clrT2Scrn))){
		retVal = EIO;
		vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: Written and read screener T2 are different\n");
		break;
	    }
	}
    }

    return retVal;
}

static uint32_t initHardwareHashAddr(CEDI_PrivateData *pD)
{
    uint32_t hash1 = 1, hash2 = 1;
    uint32_t retVal = 0;

    retVal = emacSetHashAddr(pD, 0, 0);
    if (0U != retVal) {
	vDbgMsg(DBG_GEN_MSG, 10,
		"Probe: Hardware initialization: emacSetHashAddr "\
		"returned with code: %u\n", retVal);
    }
    if (0U != emacGetHashAddr(pD, &hash1, &hash2)) {
	retVal = EIO;
	vDbgMsg(DBG_GEN_MSG, 10,
		"Probe: Hardware initialization: emacGetHashAddr "\
		"returned with code: %u\n", retVal);
    }
    if ((hash1 != 0) || (hash2 != 0)){
	retVal = EIO;
	vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: Written and read hash address are different\n");
    }

    return retVal;
}

static void SetAutoNegEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg = CPS_UncachedRead32(&(pD->regs->pcs_control));
    if (0U != enable) {
	EMAC_REGS__PCS_CONTROL__ENABLE_AUTO_NEG__SET(reg);
    }
    else
    {
	EMAC_REGS__PCS_CONTROL__ENABLE_AUTO_NEG__CLR(reg);
	pD->autoNegActive = 0U;
    }
    CPS_UncachedWrite32(&(pD->regs->pcs_control), reg);
}

static void GetAutoNegEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t reg = CPS_UncachedRead32(&(pD->regs->pcs_control));
    *enable = (uint8_t) EMAC_REGS__PCS_CONTROL__ENABLE_AUTO_NEG__READ(reg);
}


static uint32_t initHardwareAutoNeg(CEDI_PrivateData *pD)
{
    uint32_t retVal = 0;

    if (0U != EMAC_REGS__NETWORK_CONFIG__PCS_SELECT__READ(
		    CPS_UncachedRead32(&(pD->regs->network_config)))) {

	uint8_t enable;
	SetAutoNegEnable(pD, 0);
	GetAutoNegEnable(pD, &enable);

	if (enable != 0){
	    retVal = EIO;
	    vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: Written and read auto negotiation enable are diffrent\n");
	}

	pD->anLinkStat = 1;
	pD->anRemFault = 0U;
    }

    return retVal;
}


static uint32_t initHardware(CEDI_PrivateData *pD)
{
    uint8_t i;
    uint32_t retVal = 0;
    uint32_t status;

    uint8_t expressTrafficPresent = 0U;
    CEDI_PrivateData *epD = NULL;

    if (0U != pD->cfg.incExpressTraffic) {
        expressTrafficPresent = 1;
        epD = pD->otherMac;
    }
    /* Network control register */
    if (initNetControlReg(pD))
	retVal = EIO;

    /* Network config register */
    if (initNetConfigReg(pD))
	retVal = EIO;

    /* AXI Max pipeline register */
    if (initAxiMaxPipelineReg(pD))
	retVal = EIO;

    if (setRxQBufferSizes(pD, &(pD->cfg)))
	retVal = EIO;

    if (0U != expressTrafficPresent) {
        if (initNetControlReg(epD))
	    retVal = EIO;
        if (initNetConfigReg(epD))
	    retVal = EIO;
        if (initAxiMaxPipelineReg(epD))
	    retVal = EIO;
        if (setRxQBufferSizes(epD, &(epD->cfg)))
	    retVal = EIO;
    }

   /* Ensure specific address registers disabled */
    for (i=1U; i<=pD->hwCfg.num_spec_add_filters; i++) {
	status = emacDisableSpecAddr(pD, i);
	if (0U != status) {
	    retVal = EIO;
	    vDbgMsg(DBG_GEN_MSG, 10,
		    "Probe: Hardware initialization: emacDisableSpecAddr "\
		    "returned with code: %u\n", status);
	}
    }

    /* and screener registers */
    if (0U != initHardwareScreeners(pD))
	retVal = EIO;

    if (0U != expressTrafficPresent){
	for (i=1; i<=epD->hwCfg.num_spec_add_filters; i++) {
	    if (0U != emacDisableSpecAddr(epD, i)){
		retVal = EIO;
		vDbgMsg(DBG_GEN_MSG, 10,
			"Probe: Hardware initialization: emacDisableSpecAddr "\
			"(express MAC) %s\n", "");
	    }
	}

	if (0U != initHardwareScreeners(epD))
	    retVal = EIO;
    }


    /* and hash match register cleared */
    if (initHardwareHashAddr(pD))
	retVal = EIO;

    /* clear statistics */
    status = emacClearStats(pD);
    if ((0U != status) && (ENOTSUP != status)) {
	retVal = EIO;
	vDbgMsg(DBG_GEN_MSG, 10,
		"Probe: Hardware initialization: emacClearStats "\
		"returned with code: %u\n", status);
    }

        /* User outputs */
    status = emacWriteUserOutputs(pD, 0);
    if ((0U != status) && (ENOTSUP != status)) {
	retVal = EIO;
	vDbgMsg(DBG_GEN_MSG, 10,
		"Probe: Hardware initialization: emacWriteUserOutputs "\
		"returned with code: %u\n", status);
    }


    /* PCS - PCS Select is set by initNetConfigReg */
    status = initHardwareAutoNeg(pD);
    if (0U != status)
	retVal = status;

    if (0U != expressTrafficPresent) {
	if (initHardwareHashAddr(epD))
	    retVal = EIO;

	status = emacClearStats(epD);
	if ((0U != status) && (ENOTSUP != status)) {
	    retVal = status;
	    vDbgMsg(DBG_GEN_MSG, 10,
		    "Probe: Hardware initialization: emacClearStats "\
		    "(express MAC) returned with code: %u\n", status);
	}

    }

    /* Transmit Status */
    emacClearTxStatus(pD, CEDI_TXS_USED_READ | CEDI_TXS_COLLISION |
		      CEDI_TXS_RETRY_EXC | CEDI_TXS_FRAME_ERR | CEDI_TXS_TX_COMPLETE |
            CEDI_TXS_UNDERRUN | CEDI_TXS_LATE_COLL | CEDI_TXS_HRESP_ERR);

    /* Receive Status */
    emacClearRxStatus(pD, CEDI_RXS_NO_BUFF | CEDI_RXS_FRAME_RX |
                            CEDI_RXS_OVERRUN | CEDI_RXS_HRESP_ERR);

    if (0U != expressTrafficPresent) {
        emacClearTxStatus(epD, CEDI_TXS_USED_READ | CEDI_TXS_COLLISION |
                CEDI_TXS_RETRY_EXC | CEDI_TXS_FRAME_ERR | CEDI_TXS_TX_COMPLETE |
                CEDI_TXS_UNDERRUN | CEDI_TXS_LATE_COLL | CEDI_TXS_HRESP_ERR);
        emacClearRxStatus(epD, CEDI_RXS_NO_BUFF | CEDI_RXS_FRAME_RX |
                                CEDI_RXS_OVERRUN | CEDI_RXS_HRESP_ERR);
    }

    return retVal;
}

/******************************************************************************
 * Public Driver functions
 * ***************************************************************************/

static uint32_t emacProbe(CEDI_Config *config, CEDI_SysReq *sysReq)
{
    uint32_t regTmp, regVal;
    uint32_t status = 0U;
    uint32_t sumAllDesc;
    uint16_t txDescSize, rxDescSize, sumTxDesc, sumRxDesc;
    struct emac_regs *regAddr;
    uint8_t paramErr = 0, numQs;
    uint16_t i;

    if ((config==NULL) || (sysReq==NULL)) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: NULL parameter supplied");
        status = EINVAL;
    }

    if (0U == status) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered (regBase %p)\n", __func__,
                        (void *)config->regBase);

        if (0U != (config->regBase % sizeof(uint32_t))) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "%s\n", "Error: regBase address not 32-bit aligned");
            status = EINVAL;
        }
    }

    if (0U == status) {
        /* Module ID check */
        regAddr = regBaseToPtr(config->regBase);
        regVal = CPS_UncachedRead32(&(regAddr->revision_reg));
        regTmp = EMAC_REGS__REVISION_REG__MODULE_IDENTIFICATION_NUMBER__READ(
                        regVal);
        if ((regTmp!=GEM_GXL_MODULE_ID_V0) &&
        (regTmp!=GEM_GXL_MODULE_ID_V1) &&
        (regTmp!=GEM_GXL_MODULE_ID_V2) &&
        (regTmp!=GEM_AUTO_MODULE_ID_V0) &&
        (regTmp!=GEM_AUTO_MODULE_ID_V1) &&
              (regTmp!=GEM_XL_MODULE_ID)) {
            vDbgMsg(DBG_GEN_MSG, 10,
              "Warning: Module ID uknown - 0x%04X read, \n",
              regTmp);
        } else {
    #ifdef EMAC_REGS__REVISION_REG__FIX_NUMBER__READ
            vDbgMsg(DBG_GEN_MSG, 10,
                    "Module ID = 0x%03X, design rev = 0x%04X, fix no. = %u\n",
                    regTmp,
                    EMAC_REGS__REVISION_REG__MODULE_REVISION__READ(regVal),
                    EMAC_REGS__REVISION_REG__FIX_NUMBER__READ(regVal)
                    );
    #else
            vDbgMsg(DBG_GEN_MSG, 10, "Module ID = 0x%04X, design rev = 0x%04X\n", regTmp,
                    EMAC_REGS__REVISION_REG__MODULE_REVISION__READ(regVal));
    #endif
        }

        /* required config parameters range checking */
        paramErr = ((config->rxQs==0U) || (config->txQs==0U));

        /* limit numbers of queues to what is available */
        numQs = maxHwQs(regAddr);

        if (config->rxQs>numQs) {
            vDbgMsg(DBG_GEN_MSG, 10,
                "Warning: Too many Rx queues requested (%u), only %u in h/w config\n",
                config->rxQs, numQs);
            config->rxQs = numQs;
        }
        if (config->txQs>numQs) {
            vDbgMsg(DBG_GEN_MSG, 10,
                "Warning: Too many Tx queues requested (%u), only %u in h/w config\n",
                    config->txQs, numQs);
            config->txQs = numQs;
        }

        regTmp = EMAC_REGS__DESIGNCFG_DEBUG6__DMA_ADDR_WIDTH_IS_64B__READ(
                    CPS_UncachedRead32(&(regAddr->designcfg_debug6)));

        // DMA address bus width. 0 =32b , 1=64b
        if ((config->dmaAddrBusWidth) && (!regTmp))
        {
            vDbgMsg(DBG_GEN_MSG, 10, "%s\n",
                      "Warning: 64-bit DMA addressing not supported in h/w config");
            config->dmaAddrBusWidth = 0U;
        }

        for (i=0U; i<config->rxQs; i++)
        {
            if (config->rxQLen[i]>CEDI_MAX_RBQ_LENGTH)
            {
                vDbgMsg(DBG_GEN_MSG, 10,
                    "config->rxQLen(%u) (=%u) greater than maximum limit (%u)\n",
                    i, config->rxQLen[i], CEDI_MAX_RBQ_LENGTH);
                paramErr = 1;
                break;
            }
        }
        if (0U == paramErr) {
            for (i=0U; i<config->txQs; i++)
            {
                if (config->txQLen[i]>CEDI_MAX_TBQ_LENGTH)
                {
                    vDbgMsg(DBG_GEN_MSG, 10,
                        "config->txQLen(%u) (=%u) greater than maximum limit (%u)\n",
                        i, config->txQLen[i], CEDI_MAX_TBQ_LENGTH);
                    paramErr = 1;
                    break;
                }
            }
        }

        if (0U != paramErr)
        {
            vDbgMsg(DBG_GEN_MSG, 5, "%s\n", "Error: parameter out of range");
            status = EINVAL;
        }
    }

    if (0U == status) {
        /* check, if 802.3br is enabled */
        regVal = CPS_UncachedRead32(&(regAddr->designcfg_debug12));
        if (0U == (EMAC_REGS__DESIGNCFG_DEBUG12__GEM_HAS_802P3_BR__READ(regVal))) {
            config->incExpressTraffic = 0U;
        }

        /* required memory allocations */

        /* descriptor list sizes */
        calcDescriptorSizes(config, &txDescSize, &rxDescSize);

        sumTxDesc = (uint16_t) numTxDescriptors(config);
        if (0U != config->incExpressTraffic) {
            sumTxDesc += config->eTxQLen + CEDI_MIN_TXBD;
        }
        sysReq->txDescListSize = (uint32_t)sumTxDesc * (uint32_t)txDescSize;
        vDbgMsg(DBG_GEN_MSG, 10, "txQSize = %u\n", sysReq->txDescListSize);
        vDbgMsg(DBG_GEN_MSG, 10, "txDescSize = %u bytes\n", txDescSize);

        sumRxDesc = (uint16_t) numRxDescriptors(config);
        if (0U != config->incExpressTraffic) {
            sumRxDesc += (uint16_t) config->eRxQLen + CEDI_MIN_RXBD;
        }
        sysReq->rxDescListSize = (uint32_t)sumRxDesc * (uint32_t)rxDescSize;
        vDbgMsg(DBG_GEN_MSG, 10, "rxQSize = %u\n", sysReq->rxDescListSize);
        vDbgMsg(DBG_GEN_MSG, 10, "rxDescSize = %u bytes\n", rxDescSize);

        sumAllDesc = (uint32_t)sumTxDesc + (uint32_t)sumRxDesc;

        /* privateData including vAddr lists */
        sysReq->privDataSize = alignedToPtr((uint32_t)(sizeof(CEDI_PrivateData)))
                                      + ((uint32_t)(sizeof(uintptr_t))*sumAllDesc);
        if (0U != config->incExpressTraffic) {
        /* express mac private data */
        sysReq->privDataSize += alignedToPtr((uint32_t)(sizeof(CEDI_PrivateData)))
            + (((uint32_t)(config->eTxQLen)+CEDI_MIN_TXBD)*(uint32_t)(sizeof(uintptr_t)))
            + (((uint32_t)(config->eRxQLen)+CEDI_MIN_RXBD)*(uint32_t)(sizeof(uintptr_t)));
        }
        vDbgMsg(DBG_GEN_MSG, 10, "privDataSize = %u bytes\n",
                sysReq->privDataSize);
        sysReq->statsSize = (uint32_t) sizeof(CEDI_Statistics);
        vDbgMsg(DBG_GEN_MSG, 10, "statsSize = %u bytes\n",
                sysReq->statsSize);

    }
    return (status);
}

uint32_t emacGetAsfInfo(uintptr_t regBase, CEDI_AsfInfo* asfInfo)
{
    uint32_t asfMask;
    uint16_t moduleId, revision;
    uint32_t reg;
    struct emac_regs *regAddr;
    uint32_t status = 0;
    uint8_t incExpressTraffic = 0;


    asfMask = EMAC_REGS__DESIGNCFG_DEBUG11__ECC_SRAM__MASK
	| EMAC_REGS__DESIGNCFG_DEBUG11__DAP_PROTECTION__MASK
	| EMAC_REGS__DESIGNCFG_DEBUG11__CSR_PROTECTION__MASK
	| EMAC_REGS__DESIGNCFG_DEBUG11__PROTECT_TSU__MASK
	| EMAC_REGS__DESIGNCFG_DEBUG11__ASF_INTEGRITY_PROT__MASK
	| EMAC_REGS__DESIGNCFG_DEBUG11__ASF_TRANS_TO_PROT__MASK
	| EMAC_REGS__DESIGNCFG_DEBUG11__ASF_HOST_PAR__MASK
	| EMAC_REGS__DESIGNCFG_DEBUG11__ASF_PROT_TX_SCHED__MASK;


    if ((regBase == 0) || (asfInfo == NULL))
	status = EINVAL;

    if (0U == status){
	asfInfo->asfCount = 0;
	asfInfo->asfRegBases[0] = 0;
	asfInfo->asfRegBases[1] = 0;

	regAddr = regBaseToPtr(regBase);
	reg = CPS_UncachedRead32(&(regAddr->revision_reg));
	moduleId = EMAC_REGS__REVISION_REG__MODULE_IDENTIFICATION_NUMBER__READ(reg);
	revision = EMAC_REGS__REVISION_REG__MODULE_REVISION__READ(reg);

	if (IsGem1p11_(moduleId, revision) == 0)
	    asfMask = 0;
    }

    if (0U == status){
	reg = CPS_UncachedRead32(&(regAddr->designcfg_debug12));
	incExpressTraffic = EMAC_REGS__DESIGNCFG_DEBUG12__GEM_HAS_802P3_BR__READ(reg);

	reg = CPS_UncachedRead32(&(regAddr->designcfg_debug11));
	if ((reg & asfMask) != 0){
	    asfInfo->asfCount = 1;
	    asfInfo->asfRegBases[0] = regBase + CEDI_ASF_REGS_OFFSET;
	    if (incExpressTraffic){
		asfInfo->asfCount = 2;
		asfInfo->asfRegBases[1] = regBase + CEDI_EXPRESS_MAC_REGS_OFFSET + CEDI_ASF_REGS_OFFSET;
	    }
	}
    }
    return status;
}

uint32_t emacInitCalStatus(uint32_t status, uint32_t paramErr, uint8_t hwConfigErr)
{
    uint32_t result = 0;

    if (0 == status){
	if (0U != hwConfigErr){
	    result = ENOTSUP;
	} else {
	    if (0U != paramErr) {
		result = EINVAL;
	    }
	}
    }
    else
	result = status;

    return result;
}


static uint32_t emacInit(CEDI_PrivateData *pD, const CEDI_Config *config,
		  const CEDI_Callbacks *callbacks)
{
    uint32_t status = 0U;
    uint8_t hwConfigErr = 0U;
    uint32_t paramErr = 0U;
    uint8_t i;
    CEDI_PrivateData *epD = NULL;

    vDbgMsg(DBG_GEN_MSG, 10, "%s entered (regBase %08X)\n", __func__,
            (uint32_t)config->regBase);

    /* parameter validation */
    if ((pD==NULL) || (config==NULL) || (callbacks==NULL))
    {
        vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                "Error: NULL main parameter");
        status = EINVAL;
    }
    if (0U == status) {
        pD->macType = CEDI_MAC_TYPE_MAC;
        pD->otherMac = NULL;

        /* Copy config & callbacks into private data */
        pD->cfg = *config;
        pD->cb = *callbacks;

        pD->regs = regBaseToPtr(pD->cfg.regBase);

        if (0U != pD->cfg.incExpressTraffic) {
            epD = initExpressMacPD(pD, config);
        }

        paramErr = callbacksNullCheck(pD, config->intrEnable);

        if (0U != paramErr) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "Error: Callback =NULL for event(s) 0x%08X\n", paramErr);
        }

        readDesignConfig(pD);
        status = initAllRegs(pD);

        if ((0U != config->incExpressTraffic) && (epD != NULL) && (status == 0)) {
            readDesignConfig(epD);
	    status = initAllRegs(epD);
        }

        if (0U == paramErr) {
            paramErr = setNumQueuesFromConfig(pD, config);
        }

        if (0U == paramErr) {
            paramErr = checkRxQLengths(config);
        }

        if (0U == paramErr) {
            paramErr = descAddrNullCheck(config);
        }

        if (0U == paramErr) {
            paramErr = checkTxQLengths(config);
        }

        if (0U == paramErr)  {
            paramErr = checkDmaAddressingWidth(pD, config);
        }

        if (0U == paramErr)  {
            paramErr = checkPacketBuffSizes(config);
        }

        if (0U == paramErr)  {
            paramErr = checkDmaDataBurstLen(config);
        }

        if (0U == paramErr)  {
            paramErr = checkDmaBusWidth(pD, config);
        }

        if (0U == paramErr)  {
            paramErr = checkRxBuffDescAlignment(config);
        }

        if (0U == paramErr) {
            paramErr = checkInterfaceTypeSelection(pD, &hwConfigErr);
        }

        if (0U == paramErr) {
            paramErr = checkRxBufOffset(pD);
        }

        if (0U == paramErr) {
            paramErr = checkMdcPclkdiv(config);
        }

        if ((paramErr == 0U) && (0U==pD->hwCfg.no_stats)) {
            paramErr = (config->statsRegs==0U);
            if (0U != paramErr) {
                vDbgMsg(DBG_GEN_MSG, 5, "%s",
                        "Error: NULL statistics struct address\n");
            }
        }

        if ((paramErr == 0U) && (0U==pD->hwCfg.pfc_multi_quantum)) {
            paramErr = (config->pfcMultiQuantum == 1U);
            if (0U != paramErr) {
                vDbgMsg(DBG_GEN_MSG, 5, "%s",
                        "Error: pfc Multiple quantum not supported by h/w\n");
            }
        }
        checkBufferSegmentsDistribution(pD, &hwConfigErr);


        /* Need PCS present for these interface types */
        if (0U != ((config->ifTypeSel==CEDI_IFSP_10M_SGMII) ||
                (config->ifTypeSel==CEDI_IFSP_100M_SGMII) ||
                (config->ifTypeSel==CEDI_IFSP_1000M_SGMII) ||
                (config->ifTypeSel==CEDI_IFSP_1000BASE_X)  ||
                (config->ifTypeSel==CEDI_IFSP_2500M_SGMII) ||
                (config->ifTypeSel==CEDI_IFSP_2500BASE_X))
            && (EMAC_REGS__DESIGNCFG_DEBUG1__NO_PCS__READ(
                    CPS_UncachedRead32(&(pD->regs->designcfg_debug1))))) {

            vDbgMsg(DBG_GEN_MSG, 5,
                "Error: config struct specifies interface type (%u) which requires"\
                " PCS but this is not present in EMAC h/w\n", config->ifTypeSel);
            hwConfigErr = 1U;
        }

	status = emacInitCalStatus(status, paramErr, hwConfigErr);
    }

   /****************** Initialise driver internal data ************************/
    if (0U == status) {
        pD->anLinkStat = 0U;
        pD->anRemFault = 0U;
        pD->autoNegActive = 0U;
        pD->basePageExp = 1U;
        for(i=0U; i<(pD->numQs-1); i++) {
            pD->frerEnabled[i] = 0U;
        }
        /* ensure all interrupt sources disabled */
        disableAllInterrupts(pD);
        /* ensure ISRs are cleared */
        clearAllInterrupts(pD);

        if ((0U != config->incExpressTraffic) && (epD != NULL)) {
            epD->anLinkStat = 0U;
            epD->anRemFault = 0U;
            epD->autoNegActive = 0U;
            epD->basePageExp = 1U;
            epD->frerEnabled[0] = 0U;

            disableAllInterrupts(epD);
            clearAllInterrupts(epD);
        }

        /****************** Initialise Tx & Rx descriptor lists ********************/

        status = initTxRxDescLists(pD, config);
    }
    /****************************** Initialise hardware ************************/

    if (0U == status) {
        status = initHardware(pD);
    }

    return (status);
}

static void emacDestroy(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    CEDI_PrivateData *epD = NULL;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType) {
                status = EINVAL;
            } else {
                epD = pD->otherMac;
                if (epD==NULL)  {
                    status = EINVAL;
                }
            }
        }
    }

    if (0U == status) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered (regBase %08X)\n", __func__,
                (uint32_t)pD->cfg.regBase);

        emacAbortTx(pD);
        emacDisableRx(pD);

      /* disable interrupts & ... */
        disableAllInterrupts(pD);

        if (0U != pD->cfg.incExpressTraffic) {
            emacAbortTx(epD);
            emacDisableRx(epD);
            disableAllInterrupts(epD);
        }
    }
}

static uint32_t emacSetEventEnable(CEDI_PrivateData *pD, uint32_t events, uint8_t enable,
        uint8_t queueNum)
{
    uint32_t paramErr;
    uint32_t status = 0U;

    if (pD==NULL) {
        vDbgMsg(DBG_GEN_MSG, 5, "%s", "*** Error: NULL pD parameter\n");
        status = EINVAL;
    }

    if (0U == status) {
        if ((queueNum>=pD->numQs) && (queueNum!=CEDI_ALL_QUEUES)) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "*** Error: Invalid parameter, queueNum: %u\n", queueNum);
            status = EINVAL;
        }
    }
    if (0U == status) {
        if (enable>1) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "*** Error: Invalid parameter, enable: %u\n", enable);
            status = EINVAL;
        }
    }
    /* test for invalid events */
    if (0U == status) {
        if ((events &(~(((queueNum==0U) || (queueNum==CEDI_ALL_QUEUES))
                        ?(uint32_t)CEDI_EVSET_ALL_Q0_EVENTS:(uint32_t)CEDI_EVSET_ALL_QN_EVENTS)))!=0) {
            vDbgMsg(DBG_GEN_MSG, 5,
                    "*** Error: Invalid parameter, events: 0x%08X (queueNum=%u)\n",
                    events, queueNum);
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U != events) {
            if (0U != enable) { /* enable!=0, i.e. enabling specified events */

                paramErr=callbacksNullCheck(pD, events);
                if (0U!=paramErr){
                    vDbgMsg(DBG_GEN_MSG, 5,
                        "*** Error: Callback =NULL for event(s) 0x%08X\n", paramErr);
                    status = EINVAL;
                }
                if (0U == status) {
                    if ((queueNum==0U) || (queueNum==CEDI_ALL_QUEUES)) {
                        enableQ0Events(pD, events);
                    }
                    if (queueNum>0) {
                        enableQnEvents(pD, events, queueNum);
                    }
                }
            }
            else  /* enable==0, i.e. disabling specified events */
            {
                if ((queueNum==0U) || (queueNum==CEDI_ALL_QUEUES)) {
                    disableQ0Events(pD, events);
                }
                if (queueNum>0) {
                    disableQnEvents(pD, events, queueNum);
                }
            }
        }
    }
    return (status);
}

static void emacStart(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    CEDI_PrivateData *epD = NULL;
    uint32_t retVal;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType) {
                status = EINVAL;
            } else {
                epD = pD->otherMac;
                if (epD==NULL)  {
                    status = EINVAL;
                }
            }
        }
    }
    if (0U == status) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered (regBase %08X)\n", __func__,
                (uint32_t)pD->cfg.regBase);

        /* enable events for all queues */
        retVal = emacSetEventEnable(pD, pD->cfg.intrEnable,
                                    1, CEDI_ALL_QUEUES);
        if (0U != retVal) {
            vDbgMsg(DBG_GEN_MSG, 10,
                "emacStart: emacSetEventEnable "\
                "returned with code: %u\n", retVal);
        }
        emacEnableRx(pD);
        emacEnableTx(pD);

        if (0U != pD->cfg.incExpressTraffic) {
            retVal = emacSetEventEnable(epD, pD->cfg.intrEnable, 1, 0);
            if (0U != retVal) {
                vDbgMsg(DBG_GEN_MSG, 10,
                    "emacStart: emacSetEventEnable "\
                    "(express MAC) returned with code: %u\n", retVal);
            }
            emacEnableRx(epD);
            emacEnableTx(epD);
        }
    }
}

static void emacStop(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    uint32_t t;
    CEDI_PrivateData *epD = NULL;
    if (pD==NULL)  {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType) {
                status = EINVAL;
            } else {
                epD = pD->otherMac;
                if (epD==NULL)  {
                    status = EINVAL;
                }
            }
        }
    }

    if (0U == status) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered (regBase %08X)\n", __func__,
                (uint32_t)pD->cfg.regBase);

        /* Halt any Tx after present frame has finished */
        emacStopTx(pD);
        for (t=10000; (t && (emacTransmitting(pD))); t--) {;}
        if (0U != emacTransmitting(pD)) {
            emacAbortTx(pD);
        }

        emacDisableRx(pD);

        if (0U != pD->cfg.incExpressTraffic) {
            emacStopTx(epD);
            for (t=10000; (t && (emacTransmitting(epD))) != 0U; t--) {;}
            if (0U != emacTransmitting(epD)) {
                emacAbortTx(epD);
            }

            emacDisableRx(pD);
        }

        /* disable all interrupt sources */
        disableAllInterrupts(pD);

        if ((0U != pD->cfg.incExpressTraffic) && (epD != NULL)) {
            disableAllInterrupts(epD);
        }
    }
}

static uint32_t emacIsr(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    uint32_t isrReg;
    uint8_t handled = 0U;
    CEDI_PrivateData *epD = NULL;

    if (pD==NULL)  {
        status = EINVAL;
    }


    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType) {
                status = EINVAL;
            } else {
                epD = pD->otherMac;
                if (epD==NULL) {
                    status = EINVAL;
                }
            }
        }
    }


    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            isrReg = CPS_UncachedRead32(&(pD->regs->mmsl_int_status));
            if (0U != isrReg)
            {
                handled = 1;
                if (NULL != pD->cb.mmslEvent) {
                    (*(pD->cb.mmslEvent))(pD, isrReg);
                }
                if (0U==pD->hwCfg.irq_read_clear) {
                    CPS_UncachedWrite32(&(pD->regs->mmsl_int_status), isrReg);
                }
            }
            handleGeneralInterupts(epD, &handled);
        }

        handleQnInterupts(pD, &handled);
        handleGeneralInterupts(pD, &handled);

    }

    if (0U == status) {
        if (0U == handled) {
            status = ECANCELED;
        }
    }

    return (status);
}

/**
 * Enable or disable the specified interrupts.
 * @param[in] pD driver private state info specific to this instance
 * @param[in] events
 *    OR'd combination of bit-flags selecting the events to
 *    be enabled or disabled
 * @param[in] enable if equal 1 enable the events, if 0 then disable
 * @param[in] queueNum between 0 and config->rxQs-1, or =CEDI_ALL_QUEUES -
 *    number of Tx or Rx priority queue, relevant to some of
 *    Tx and Rx events:
 *    (uint32_t)CEDI_EV_TX_COMPLETE, (uint32_t)CEDI_EV_TX_FR_CORRUPT,
 *    (uint32_t)CEDI_EV_RX_COMPLETE, (uint32_t)CEDI_EV_RX_USED_READ, (uint32_t)CEDI_EV_RX_OVERRUN,
 *    (uint32_t)CEDI_EV_HRESP_NOT_OK
 *    Must be =0 or CEDI_ALL_QUEUES for other events.
 *    To dis/enable on all available Qs, set queueNum to CEDI_ALL_QUEUES and
 *    set events to (uint32_t)CEDI_EVSET_ALL_Q0_EVENTS.
 * @return EINVAL for invalid pD pointer or enable
 * @return EINVAL for invalid queueNum
 * @return EINVAL for invalid event,
 *    e.g. (uint32_t)CEDI_EV_PAUSE_FRAME_TX when queueNum = 2
 * @return EINVAL for NULL callback for event to be enabled
 * @return 0 for success
 */

static uint32_t emacGetEventEnable(CEDI_PrivateData *pD, uint8_t queueNum, uint32_t *event)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (event==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (queueNum>=pD->numQs) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (queueNum==0) {
            getQ0EventEnable(pD, event);
        }
        else
        {
            getQnEventEnable(pD, event, queueNum);
        }
    }
    return (status);
}

static uint32_t emacSetIntrptModerate(CEDI_PrivateData *pD, uint8_t txIntDelay,
                                        uint8_t rxIntDelay)
{
    uint32_t status = 0U;
    uint32_t reg;
    if (pD==NULL)  {
        status = EINVAL;
    }
    if (0U == status) {
        if ((pD->hwCfg.intrpt_mod==0) && (txIntDelay || rxIntDelay)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->int_moderation));
        EMAC_REGS__INT_MODERATION__TX_INT_MODERATION__MODIFY(reg, txIntDelay);
        EMAC_REGS__INT_MODERATION__RX_INT_MODERATION__MODIFY(reg, rxIntDelay);
        CPS_UncachedWrite32(&(pD->regs->int_moderation), reg);
    }
    return (status);
}

static uint32_t emacGetIntrptModerate(CEDI_PrivateData *pD, uint8_t *txIntDelay,
                                        uint8_t *rxIntDelay)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (txIntDelay==NULL) || (rxIntDelay==NULL)) {
        status = EINVAL;
    } else {
        if (pD->hwCfg.intrpt_mod==0) {
            *txIntDelay = 0U;
            *rxIntDelay = 0U;
        } else {
            reg = CPS_UncachedRead32(&(pD->regs->int_moderation));
            *txIntDelay= (uint8_t) EMAC_REGS__INT_MODERATION__TX_INT_MODERATION__READ(reg);
            *rxIntDelay= (uint8_t) EMAC_REGS__INT_MODERATION__RX_INT_MODERATION__READ(reg);
        }
    }
    return (status);
}

static uint32_t emacSetIfSpeed(CEDI_PrivateData *pD, CEDI_IfSpeed speedSel)
{
    uint32_t status = 0U;
    uint32_t reg;
    uint32_t reg_control;
    CEDI_IfSpeed max_gem_speed;
    CEDI_PrivateData *epD = NULL;


    if (pD==NULL)  {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setIfSpeed can not be called for express MAC.");
                status = EINVAL;
            }
            epD = pD->otherMac;
        }
    }

    if (0U == status) {
        max_gem_speed = CEDI_SPEED_2500M;
        if (0U == is2p5GSupported(pD)) {
            max_gem_speed = CEDI_SPEED_1000M;
        }
        if (speedSel>max_gem_speed) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        reg_control = CPS_UncachedRead32(&(pD->regs->network_control));

        switch (speedSel) {
        case CEDI_SPEED_10M:
            EMAC_REGS__NETWORK_CONFIG__SPEED__CLR(reg);
            EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__CLR(reg);
            break;
        case CEDI_SPEED_100M:
            EMAC_REGS__NETWORK_CONFIG__SPEED__SET(reg);
            EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__CLR(reg);
            break;
        case CEDI_SPEED_1000M:
            EMAC_REGS__NETWORK_CONFIG__SPEED__CLR(reg);
            EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__SET(reg);
            break;
        case CEDI_SPEED_2500M:
            EMAC_REGS__NETWORK_CONFIG__SPEED__CLR(reg);
            EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__SET(reg);
            EMAC_REGS__NETWORK_CONTROL__TWO_PT_FIVE_GIG__SET(reg_control);
            break;
        default:
            status = EINVAL;
            break;
        }
    }

    if (0U == status) {
        if (speedSel != CEDI_SPEED_2500M) {
            EMAC_REGS__NETWORK_CONTROL__TWO_PT_FIVE_GIG__CLR(reg_control);
        }

        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg_control);
        if ((0U != pD->cfg.incExpressTraffic) && (epD != NULL)) {
            reg = CPS_UncachedRead32(&(epD->regs->network_config));
            reg_control = CPS_UncachedRead32(&(epD->regs->network_control));
            EMAC_REGS__NETWORK_CONTROL__TWO_PT_FIVE_GIG__CLR(reg_control);
            switch (speedSel) {
            case CEDI_SPEED_10M:
                EMAC_REGS__NETWORK_CONFIG__SPEED__CLR(reg);
                EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__CLR(reg);
                break;
            case CEDI_SPEED_100M:
                EMAC_REGS__NETWORK_CONFIG__SPEED__SET(reg);
                EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__CLR(reg);
                break;
            case CEDI_SPEED_1000M:
                EMAC_REGS__NETWORK_CONFIG__SPEED__CLR(reg);
                EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__SET(reg);
                break;
            default: /* for CEDI_SPEED_2500M */
                EMAC_REGS__NETWORK_CONFIG__SPEED__CLR(reg);
                EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__SET(reg);
                EMAC_REGS__NETWORK_CONTROL__TWO_PT_FIVE_GIG__SET(reg_control);
                break;
            }
            CPS_UncachedWrite32(&(epD->regs->network_config), reg);
            CPS_UncachedWrite32(&(epD->regs->network_control), reg_control);
        }
    }
    return (status);
}

static uint32_t emacGetIfSpeed(CEDI_PrivateData *pD, CEDI_IfSpeed *speedSel)
{
    uint32_t status = 0U;
    uint32_t reg;
    uint32_t reg_control;

    if ((pD==NULL) || (speedSel==NULL)) {
        status = EINVAL;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        reg_control = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != EMAC_REGS__NETWORK_CONTROL__TWO_PT_FIVE_GIG__READ(reg_control)) {
            *speedSel = CEDI_SPEED_2500M;
        } else
        if (0U != EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__READ(reg)) {
            *speedSel = CEDI_SPEED_1000M;
        } else if (0U != EMAC_REGS__NETWORK_CONFIG__SPEED__READ(reg)) {
            *speedSel = CEDI_SPEED_100M;
        } else {
            *speedSel = CEDI_SPEED_10M;
        }
    }
    return (status);
}

static void emacSetJumboFramesRx(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <= 1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__JUMBO_FRAMES__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__JUMBO_FRAMES__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

static uint32_t emacGetJumboFramesRx(const CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        getJumboFramesRx(pD, enable);
    }

    return (status);
}

static uint32_t emacSetJumboFrameRxMaxLen(CEDI_PrivateData *pD, uint16_t length)
{
    uint32_t status = 0U;
    uint32_t reg;
    uint8_t enabled;
    if ((pD==NULL) || (length>MAX_JUMBO_FRAME_LENGTH) )  {
        status = EINVAL;
    } else {
        getJumboFramesRx(pD, &enabled);
        reg = CPS_UncachedRead32(&(pD->regs->jumbo_max_length));
        if (0U != enabled) {
            emacSetJumboFramesRx(pD, 0);
        }
        EMAC_REGS__JUMBO_MAX_LENGTH__JUMBO_MAX_LENGTH__MODIFY(reg, length);
        CPS_UncachedWrite32(&(pD->regs->jumbo_max_length), reg);
        if (0U != enabled) {
            emacSetJumboFramesRx(pD, 1);
        }
    }
    return (status);
}


static uint32_t emacSetUniDirEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (enable>1)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setUniDirEnable can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__UNI_DIRECTION_ENABLE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__UNI_DIRECTION_ENABLE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
    return (status);
}

static uint32_t emacGetUniDirEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t) EMAC_REGS__NETWORK_CONFIG__UNI_DIRECTION_ENABLE__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }
    return (status);
}

static uint32_t emacSetTxChecksumOffload(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (enable>1)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == pD->hwCfg.tx_pkt_buffer) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered: enable = %u\n",
                                    __func__, enable);

        reg = CPS_UncachedRead32(&(pD->regs->dma_config));
        if (0U != enable) {
            EMAC_REGS__DMA_CONFIG__TX_PBUF_TCP_EN__SET(reg);
        } else {
            EMAC_REGS__DMA_CONFIG__TX_PBUF_TCP_EN__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->dma_config), reg);
    }
    return (status);
}

static uint32_t emacGetTxChecksumOffload(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t)EMAC_REGS__DMA_CONFIG__TX_PBUF_TCP_EN__READ(
                CPS_UncachedRead32(&(pD->regs->dma_config)));
    }
    return (status);
}

static uint32_t emacSetRxBufOffset(CEDI_PrivateData *pD, uint8_t offset)
{
    uint32_t status = 0U;
    uint32_t reg;
    if (pD==NULL)  {
        status = EINVAL;
    }
    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (offset>3)  {
            status = EINVAL;
        }
    }
    if (0U == status) {
        EMAC_REGS__NETWORK_CONFIG__RECEIVE_BUFFER_OFFSET__MODIFY(reg, offset);
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
    return (status);
}

static uint32_t emacGetRxBufOffset(CEDI_PrivateData *pD, uint8_t *offset)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (offset==NULL)) {
        status = EINVAL;
    } else {
        *offset= (uint8_t) EMAC_REGS__NETWORK_CONFIG__RECEIVE_BUFFER_OFFSET__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }
    return (status);
}

static void emacSet1536ByteFramesRx(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__RECEIVE_1536_BYTE_FRAMES__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__RECEIVE_1536_BYTE_FRAMES__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

static void emacSetRxChecksumOffload(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered: enable = %u\n",
                                    __func__, enable);

        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__RECEIVE_CHECKSUM_OFFLOAD_ENABLE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__RECEIVE_CHECKSUM_OFFLOAD_ENABLE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

static uint32_t emacGetRxChecksumOffload(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t) EMAC_REGS__NETWORK_CONFIG__RECEIVE_CHECKSUM_OFFLOAD_ENABLE__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }
    return (status);
}

static void emacSetFcsRemove(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__FCS_REMOVE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__FCS_REMOVE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

static uint32_t emacGetFcsRemove(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t) EMAC_REGS__NETWORK_CONFIG__FCS_REMOVE__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }
    return (status);
}

static uint32_t emacSetRxDmaDataAddrMask(CEDI_PrivateData *pD, uint8_t enableBit,
        uint8_t bitValues)
{
    uint32_t reg = 0U;
    uint32_t status = 0U;

    if ((pD==NULL) || (enableBit>0xf) || (bitValues>0xf))  {
        status = EINVAL;
    }  else {
        EMAC_REGS__DMA_ADDR_OR_MASK__MASK_ENABLE__MODIFY(reg, enableBit);
        EMAC_REGS__DMA_ADDR_OR_MASK__MASK_VALUE__MODIFY(reg, bitValues);
        CPS_UncachedWrite32(&(pD->regs->dma_addr_or_mask), reg);
    }
    return (status);
}

static uint32_t emacGetRxDmaDataAddrMask(CEDI_PrivateData *pD, uint8_t *enableBit,
        uint8_t *bitValues)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (!enableBit) || (!bitValues))  {
        status = EINVAL;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->dma_addr_or_mask));
        *enableBit = (uint8_t)EMAC_REGS__DMA_ADDR_OR_MASK__MASK_ENABLE__READ(reg);
        *bitValues = (uint8_t)EMAC_REGS__DMA_ADDR_OR_MASK__MASK_VALUE__READ(reg);
    }
    return (status);
}

static void emacSetRxBadPreamble(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__NSP_CHANGE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__NSP_CHANGE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

static uint32_t emacGetRxBadPreamble(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t)EMAC_REGS__NETWORK_CONFIG__NSP_CHANGE__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}

static uint32_t emacSetFullDuplex(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    uint32_t status = 0U;
    CEDI_PrivateData *epD = NULL;
    if ((pD==NULL) || (enable>1)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setIfSpeed can not be called for express MAC.");
                status = EINVAL;
            }
            epD = pD->otherMac;
        }
    }
    if (0U == status) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered: set to %s duplex\n",
                __func__, (0U != enable)?"full":"half");

        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__FULL_DUPLEX__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__FULL_DUPLEX__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
        if (0U != pD->cfg.incExpressTraffic) {
            reg = CPS_UncachedRead32(&(epD->regs->network_config));
            if (0U != enable) {
                EMAC_REGS__NETWORK_CONFIG__FULL_DUPLEX__SET(reg);
            } else {
                EMAC_REGS__NETWORK_CONFIG__FULL_DUPLEX__CLR(reg);
            }
            CPS_UncachedWrite32(&(epD->regs->network_config), reg);
        }
    }
    return (status);
}

static uint32_t emacGetFullDuplex(const CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        getFullDuplex(pD, enable);
    }
    return (status);
}

static void emacSetIgnoreFcsRx(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable<=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__IGNORE_RX_FCS__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__IGNORE_RX_FCS__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

static uint32_t emacGetIgnoreFcsRx(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t)EMAC_REGS__NETWORK_CONFIG__IGNORE_RX_FCS__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}

static void emacSetRxHalfDuplexInTx(const CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__EN_HALF_DUPLEX_RX__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__EN_HALF_DUPLEX_RX__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

static uint32_t emacGetRxHalfDuplexInTx(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t) EMAC_REGS__NETWORK_CONFIG__EN_HALF_DUPLEX_RX__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}


static uint32_t emacGetIfCapabilities(const CEDI_PrivateData *pD, uint32_t *cap)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (cap==NULL)) {
        status = EINVAL;
    } else {

        *cap = 0U;

// TODO: temporary detection based on header-data splitting until get LSO-related define
#ifdef EMAC_REGS__DMA_CONFIG__HDR_DATA_SPLITTING_EN__READ
        *cap |= CEDI_CAP_LSO;
#endif
// TODO: RSC, RSS, ...
    }

    return (status);
}

/******************************** Pause Control ******************************/

static void emacSetPauseEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__PAUSE_ENABLE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__PAUSE_ENABLE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }

}

static uint32_t emacGetPauseEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL)||(enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t) EMAC_REGS__NETWORK_CONFIG__PAUSE_ENABLE__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}

static void emacTxPauseFrame(CEDI_PrivateData *pD)
{
    uint32_t reg;
    if (pD!=NULL)  {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__TX_PAUSE_FRAME_REQ__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
}

static void emacTxZeroQPause(CEDI_PrivateData *pD)
{
    uint32_t reg;
    if (pD!=NULL)  {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__TX_PAUSE_FRAME_ZERO__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
}

static uint32_t emacGetRxPauseQuantum(CEDI_PrivateData *pD, uint16_t *value)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (value==NULL)) {
        status = EINVAL;
    } else {
        *value = (uint8_t) EMAC_REGS__PAUSE_TIME__QUANTUM__READ(
                CPS_UncachedRead32(&(pD->regs->pause_time)));
    }
    return (status);
}

static uint32_t emacSetTxPauseQuantum(CEDI_PrivateData *pD, uint16_t value, uint8_t qpriority)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (qpriority >= CEDI_QUANTA_PRIORITY_MAX))  {
        status = EINVAL;
    }

    if (0U == status) {
        if ((pD->hwCfg.pfc_multi_quantum==0)
                            && (qpriority>0)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        switch (qpriority) {
        default:
        case 0:
            reg = CPS_UncachedRead32(&(pD->regs->tx_pause_quantum));
            EMAC_REGS__TX_PAUSE_QUANTUM__QUANTUM__MODIFY(reg, value);
            CPS_UncachedWrite32(&(pD->regs->tx_pause_quantum), reg);
            break;
        case 1:
            reg = CPS_UncachedRead32(&(pD->regs->tx_pause_quantum));
            EMAC_REGS__TX_PAUSE_QUANTUM__QUANTUM_P1__MODIFY(reg, value);
            CPS_UncachedWrite32(&(pD->regs->tx_pause_quantum), reg);
            break;
        case 2:
            reg = CPS_UncachedRead32(&(pD->regs->tx_pause_quantum1));
            EMAC_REGS__TX_PAUSE_QUANTUM1__QUANTUM_P2__MODIFY(reg, value);
            CPS_UncachedWrite32(&(pD->regs->tx_pause_quantum1), reg);
            break;
        case 3:
            reg = CPS_UncachedRead32(&(pD->regs->tx_pause_quantum1));
            EMAC_REGS__TX_PAUSE_QUANTUM1__QUANTUM_P3__MODIFY(reg, value);
            CPS_UncachedWrite32(&(pD->regs->tx_pause_quantum1), reg);
            break;
        case 4:
            reg = CPS_UncachedRead32(&(pD->regs->tx_pause_quantum2));
            EMAC_REGS__TX_PAUSE_QUANTUM2__QUANTUM_P4__MODIFY(reg, value);
            CPS_UncachedWrite32(&(pD->regs->tx_pause_quantum2), reg);
            break;
        case 5:
            reg = CPS_UncachedRead32(&(pD->regs->tx_pause_quantum2));
            EMAC_REGS__TX_PAUSE_QUANTUM2__QUANTUM_P5__MODIFY(reg, value);
            CPS_UncachedWrite32(&(pD->regs->tx_pause_quantum2), reg);
            break;
        case 6:
            reg = CPS_UncachedRead32(&(pD->regs->tx_pause_quantum3));
            EMAC_REGS__TX_PAUSE_QUANTUM3__QUANTUM_P6__MODIFY(reg, value);
            CPS_UncachedWrite32(&(pD->regs->tx_pause_quantum3), reg);
            break;
        case 7:
            reg = CPS_UncachedRead32(&(pD->regs->tx_pause_quantum3));
            EMAC_REGS__TX_PAUSE_QUANTUM3__QUANTUM_P7__MODIFY(reg, value);
            CPS_UncachedWrite32(&(pD->regs->tx_pause_quantum3), reg);
            break;
        }
    }
    return (status);
}

static uint32_t emacGetTxPauseQuantum(CEDI_PrivateData *pD, uint16_t *value, uint8_t qpriority)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (value==NULL) || (qpriority >= CEDI_QUANTA_PRIORITY_MAX)) {
        status = EINVAL;
    }
    if (0U == status) {
        if ((pD->hwCfg.pfc_multi_quantum==0)
                            && (qpriority>0)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        switch(qpriority){
        default:
        case 0:
            *value= (uint16_t)EMAC_REGS__TX_PAUSE_QUANTUM__QUANTUM__READ(
                        CPS_UncachedRead32(&(pD->regs->tx_pause_quantum)));
            break;
        case 1:
            *value= (uint16_t)EMAC_REGS__TX_PAUSE_QUANTUM__QUANTUM_P1__READ(
                        CPS_UncachedRead32(&(pD->regs->tx_pause_quantum)));
            break;
        case 2:
            *value= (uint16_t)EMAC_REGS__TX_PAUSE_QUANTUM1__QUANTUM_P2__READ(
                        CPS_UncachedRead32(&(pD->regs->tx_pause_quantum1)));
            break;
        case 3:
            *value= (uint16_t)EMAC_REGS__TX_PAUSE_QUANTUM1__QUANTUM_P3__READ(
                        CPS_UncachedRead32(&(pD->regs->tx_pause_quantum1)));
            break;
        case 4:
            *value= (uint16_t)EMAC_REGS__TX_PAUSE_QUANTUM2__QUANTUM_P4__READ(
                        CPS_UncachedRead32(&(pD->regs->tx_pause_quantum2)));
            break;
        case 5:
            *value= (uint16_t)EMAC_REGS__TX_PAUSE_QUANTUM2__QUANTUM_P5__READ(
                        CPS_UncachedRead32(&(pD->regs->tx_pause_quantum2)));
            break;
        case 6:
            *value= (uint16_t)EMAC_REGS__TX_PAUSE_QUANTUM3__QUANTUM_P6__READ(
                        CPS_UncachedRead32(&(pD->regs->tx_pause_quantum3)));
            break;
        case 7:
            *value= (uint16_t)EMAC_REGS__TX_PAUSE_QUANTUM3__QUANTUM_P7__READ(
                        CPS_UncachedRead32(&(pD->regs->tx_pause_quantum3)));
            break;
        }
    }

    return (status);
}

static void emacSetCopyPauseDisable(CEDI_PrivateData *pD, uint8_t disable)
{
    uint32_t reg;
    if (pD!=NULL)  {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != disable) {
            EMAC_REGS__NETWORK_CONFIG__DISABLE_COPY_OF_PAUSE_FRAMES__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__DISABLE_COPY_OF_PAUSE_FRAMES__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

static uint32_t emacGetCopyPauseDisable(CEDI_PrivateData *pD, uint8_t *disable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (disable==NULL)) {
        status = EINVAL;
    } else {
        *disable= (uint8_t) EMAC_REGS__NETWORK_CONFIG__DISABLE_COPY_OF_PAUSE_FRAMES__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)));
    }

    return (status);
}

static void emacSetPfcPriorityBasedPauseRx(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__PFC_ENABLE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONTROL__PFC_ENABLE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
}

static uint32_t emacGetPfcPriorityBasedPauseRx(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable = (uint8_t) EMAC_REGS__NETWORK_CONTROL__PFC_ENABLE__READ(
                CPS_UncachedRead32(&(pD->regs->network_control)));
    }
    return (status);
}

static uint32_t emacTxPfcPriorityBasedPause(CEDI_PrivateData *pD)
{
    uint8_t fullDup = 1;
    uint32_t status = 0U;
    uint32_t reg;

    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U == status) {
        getFullDuplex(pD, &fullDup);
        if (0U == fullDup) {
            status = EINVAL;
        }
    }
    if (0U == status) {
        if (0U == emacGetTxEnabled(pD)) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__TRANSMIT_PFC_PRIORITY_BASED_PAUSE_FRAME__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
    return (status);
}

static uint32_t emacSetTxPfcPauseFrameFields(CEDI_PrivateData *pD, uint8_t priEnVector,
            uint8_t zeroQSelVector)
{
    uint32_t status = 0U;
    uint32_t reg = 0U;
    if (pD==NULL)  {
        status = EINVAL;
    } else {
        EMAC_REGS__TX_PFC_PAUSE__VECTOR_ENABLE__MODIFY(reg, priEnVector);
        EMAC_REGS__TX_PFC_PAUSE__VECTOR__MODIFY(reg, zeroQSelVector);
        CPS_UncachedWrite32(&(pD->regs->tx_pfc_pause), reg);
    }
    return (status);
}

static uint32_t emacGetTxPfcPauseFrameFields(CEDI_PrivateData *pD, uint8_t *priEnVector,
            uint8_t *zeroQSelVector)
{
    uint32_t status = 0U;
    uint32_t reg = 0U;
    if ((pD==NULL) || (priEnVector==NULL) || (zeroQSelVector==NULL)) {
        status = EINVAL;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->tx_pfc_pause));
        *priEnVector = (uint8_t) EMAC_REGS__TX_PFC_PAUSE__VECTOR_ENABLE__READ(reg);
        *zeroQSelVector = (uint8_t) EMAC_REGS__TX_PFC_PAUSE__VECTOR__READ(reg);
    }
    return (status);
}

static uint32_t emacSetEnableMultiPfcPauseQuantum(CEDI_PrivateData *pD, uint8_t enMultiPfcPause)
{
    uint32_t status = 0U;
    uint32_t regVal = 0U;
    if ((pD==NULL) || (enMultiPfcPause>1U)) {
        status = EINVAL;
    }

    if (0U == status) {
        if ((pD->hwCfg.pfc_multi_quantum==0U) && (enMultiPfcPause==1U)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        regVal = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__PFC_CTRL__MODIFY(regVal, enMultiPfcPause);

        CPS_UncachedWrite32(&(pD->regs->network_control), regVal);
    }
    return (status);
}

static uint32_t emacGetEnableMultiPfcPauseQuantum(CEDI_PrivateData *pD, uint8_t *enMultiPfcPause)
{
    uint32_t status = 0U;
    uint32_t regVal = 0U;
    if ((pD==NULL) || (enMultiPfcPause==NULL)) {
        status = EINVAL;
    } else {
        regVal = CPS_UncachedRead32(&(pD->regs->network_control));
        *enMultiPfcPause = (uint8_t) EMAC_REGS__NETWORK_CONTROL__PFC_CTRL__READ(regVal);
    }
    return (status);
}


/****************************** Loopback Control *****************************/

/**
 * Enable or disable loop back mode in the EMAC.
 * @param pD - driver private state info specific to this instance
 * @param mode - enum selecting mode enable/disable:
 *    CEDI_SERDES_LOOPBACK :select loopback mode in PHY transceiver, if
 *        available
 *    CEDI_LOCAL_LOOPBACK  :select internal loopback mode. Tx and Rx should be
 *                        :disabled when enabling or disabling this mode.
 *                        :Only available if int_loopback defined.
 *    CEDI_NO_LOOPBACK     :disable loopback mode
 * @return ENOTSUP if CEDI_SERDES_LOOPBACK selected and no_pcs defined, or
 *    if CEDI_LOCAL_LOOPBACK selected and either
 *        (no_int_loopback defined or PCS mode is selected)
 * @return ENOTSUP if CEDI_LOCAL_LOOPBACK selected and no_int_loopback defined
 * @return 0 otherwise.
 */
static uint32_t emacSetLoopback(CEDI_PrivateData *pD, uint8_t mode)
{
    uint32_t reg;
    uint32_t status = 0U;
    uint32_t reg2 = 0;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (mode>CEDI_SERDES_LOOPBACK) {
        status = EINVAL;
    }

    if (0U == status) {
        if ((pD->hwCfg.no_pcs && (mode==CEDI_SERDES_LOOPBACK)) ||
            (pD->hwCfg.no_int_loopback &&
                (mode==CEDI_LOCAL_LOOPBACK))) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if ((EMAC_REGS__NETWORK_CONFIG__PCS_SELECT__READ(
                CPS_UncachedRead32(&(pD->regs->network_config)))) &&
                (mode==CEDI_LOCAL_LOOPBACK)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
	if ( 0U == pD->hwCfg.no_pcs)
	    reg2 = CPS_UncachedRead32(&(pD->regs->pcs_control));
        EMAC_REGS__NETWORK_CONTROL__LOOPBACK__CLR(reg);
        if (mode==CEDI_LOCAL_LOOPBACK) {
            EMAC_REGS__NETWORK_CONTROL__LOOPBACK_LOCAL__SET(reg);
            EMAC_REGS__PCS_CONTROL__LOOPBACK_MODE__CLR(reg2);
        }
        else if (mode==CEDI_SERDES_LOOPBACK) {
            EMAC_REGS__NETWORK_CONTROL__LOOPBACK_LOCAL__CLR(reg);
            EMAC_REGS__PCS_CONTROL__LOOPBACK_MODE__SET(reg2);
        }
        else {  /* CEDI_NO_LOOPBACK */
            EMAC_REGS__NETWORK_CONTROL__LOOPBACK_LOCAL__CLR(reg);
            EMAC_REGS__PCS_CONTROL__LOOPBACK_MODE__CLR(reg2);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
	if ( 0U == pD->hwCfg.no_pcs)
	    CPS_UncachedWrite32(&(pD->regs->pcs_control), reg2);
    }
    return (status);
}

static uint32_t emacGetLoopback(CEDI_PrivateData *pD, uint8_t *mode)
{
    uint32_t status = 0U;
    uint32_t reg;
    uint32_t reg2;
    if ((pD==NULL) || (mode==NULL)) {
        status = EINVAL;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
            reg2 = CPS_UncachedRead32(&(pD->regs->pcs_control));
        if (0U != EMAC_REGS__PCS_CONTROL__LOOPBACK_MODE__READ(reg2)) {
            *mode= CEDI_SERDES_LOOPBACK;
        }
        else
            if (0U != EMAC_REGS__NETWORK_CONTROL__LOOPBACK_LOCAL__READ(reg)) {
            *mode= CEDI_LOCAL_LOOPBACK;
        } else {
            *mode= CEDI_NO_LOOPBACK;
        }
    }

    return (status);
}

/**************************** PTP/1588 Support *******************************/

static void emacSetUnicastPtpDetect(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1U)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__PTP_UNICAST_ENA__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONTROL__PTP_UNICAST_ENA__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
}

static uint32_t emacGetUnicastPtpDetect(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t) EMAC_REGS__NETWORK_CONTROL__PTP_UNICAST_ENA__READ(
                CPS_UncachedRead32(&(pD->regs->network_control)));
    }

    return (status);
}

static uint32_t emacSetPtpRxUnicastIpAddr(CEDI_PrivateData *pD, uint32_t rxAddr)
{
    uint32_t status = 0U;
    uint32_t reg = 0U;
    uint8_t enabled = 0U;
    status = emacGetUnicastPtpDetect(pD, &enabled);

    if ((0U == status) && (0U != enabled)) {
        status = ENOTSUP;
    }

    if (0U == status) {
        EMAC_REGS__RX_PTP_UNICAST__ADDRESS__MODIFY(reg, rxAddr);
        CPS_UncachedWrite32(&(pD->regs->rx_ptp_unicast), reg);
    }
    return (status);
}

static uint32_t emacGetPtpRxUnicastIpAddr(CEDI_PrivateData *pD, uint32_t *rxAddr)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (rxAddr==NULL)) {
        status = EINVAL;
    } else {
        *rxAddr= EMAC_REGS__RX_PTP_UNICAST__ADDRESS__READ(
                CPS_UncachedRead32(&(pD->regs->rx_ptp_unicast)));
    }
    return (status);
}

static uint32_t emacSetPtpTxUnicastIpAddr(CEDI_PrivateData *pD, uint32_t txAddr)
{
    uint32_t reg = 0U;
    uint32_t status = 0U;
    uint8_t enabled = 0U;
    status = emacGetUnicastPtpDetect(pD, &enabled);

    if ((0U == status) && (0U != enabled)) {
        status = ENOTSUP;
    }

        if (0U == status) {
        EMAC_REGS__TX_PTP_UNICAST__ADDRESS__MODIFY(reg, txAddr);
        CPS_UncachedWrite32(&(pD->regs->tx_ptp_unicast), reg);
    }
    return (status);
}

static uint32_t emacGetPtpTxUnicastIpAddr(CEDI_PrivateData *pD, uint32_t *txAddr)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (txAddr==NULL)) {
        status = EINVAL;
    } else {
        *txAddr= EMAC_REGS__TX_PTP_UNICAST__ADDRESS__READ(
                CPS_UncachedRead32(&(pD->regs->tx_ptp_unicast)));
    }
    return (status);
}

static uint32_t emacSet1588Timer(CEDI_PrivateData *pD, const CEDI_1588TimerVal *timeVal)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if ((timeVal->nanosecs)>0x3FFFFFFFU) {
            status = EINVAL;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: set1588Timer can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->tsu_timer_msb_sec));
        EMAC_REGS__TSU_TIMER_MSB_SEC__TIMER__MODIFY(reg, timeVal->secsUpper);
        CPS_UncachedWrite32(&(pD->regs->tsu_timer_msb_sec), reg);
        /* write lower bits 2nd, for synchronised secs update */
        reg = 0U;
        EMAC_REGS__TSU_TIMER_SEC__TIMER__MODIFY(reg, timeVal->secsLower);
        CPS_UncachedWrite32(&(pD->regs->tsu_timer_sec), reg);
        reg = 0U;
        EMAC_REGS__TSU_TIMER_NSEC__TIMER__MODIFY(reg, timeVal->nanosecs);
        CPS_UncachedWrite32(&(pD->regs->tsu_timer_nsec), reg);
    }
    return (status);
}

static uint32_t emacGet1588Timer(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal)
{
    uint32_t status = 0U;
    uint32_t reg, first;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        first = EMAC_REGS__TSU_TIMER_NSEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_timer_nsec)));
        timeVal->secsLower = EMAC_REGS__TSU_TIMER_SEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_timer_sec)));
        timeVal->secsUpper = (uint16_t)EMAC_REGS__TSU_TIMER_MSB_SEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_timer_msb_sec)));
        /* test for nsec rollover */
        reg = CPS_UncachedRead32(&(pD->regs->tsu_timer_nsec));
        if (first>(EMAC_REGS__TSU_TIMER_NSEC__TIMER__READ(reg))) {
            /* if so, use later read & re-read seconds
             * (assume all done within 1s) */
            timeVal->nanosecs = EMAC_REGS__TSU_TIMER_NSEC__TIMER__READ(reg);
            timeVal->secsLower = EMAC_REGS__TSU_TIMER_SEC__TIMER__READ(
                    CPS_UncachedRead32(&(pD->regs->tsu_timer_sec)));
            timeVal->secsUpper = (uint16_t)EMAC_REGS__TSU_TIMER_MSB_SEC__TIMER__READ(
                    CPS_UncachedRead32(&(pD->regs->tsu_timer_msb_sec)));
        } else {
            timeVal->nanosecs = first;
        }
    }

    return (status);
}

static uint32_t emacAdjust1588Timer(CEDI_PrivateData *pD, int32_t nSecAdjust)
{
    uint32_t status = 0U;
    uint32_t reg;
    /* Absolute value */
    uint32_t nSecAdjustAbs;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if ((nSecAdjust<(-0x3FFFFFFF)) || (nSecAdjust>0x3FFFFFFF)) {
            status = EINVAL;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: adjust1588Timer can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = 0U;
        if (nSecAdjust<0) {
            EMAC_REGS__TSU_TIMER_ADJUST__ADD_SUBTRACT__SET(reg);
            nSecAdjustAbs = -nSecAdjust;
        } else {
            nSecAdjustAbs = nSecAdjust;
        }

        EMAC_REGS__TSU_TIMER_ADJUST__INCREMENT_VALUE__MODIFY(reg, nSecAdjustAbs);
        CPS_UncachedWrite32(&(pD->regs->tsu_timer_adjust), reg);
    }
    return (status);
}

static uint32_t emacSet1588TimerInc(CEDI_PrivateData *pD,
                             const CEDI_TimerIncrement *incSettings)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (incSettings==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: set1588TimerInc can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
#ifdef  EMAC_REGS__TSU_TIMER_INCR_SUB_NSEC__SUB_NS_INCR_LSB__MODIFY
        reg = 0U;
        EMAC_REGS__TSU_TIMER_INCR_SUB_NSEC__SUB_NS_INCR__MODIFY(reg,
                           incSettings->subNsInc);
        if (0U != subNsTsuInc24bSupport(pD)) {
            EMAC_REGS__TSU_TIMER_INCR_SUB_NSEC__SUB_NS_INCR_LSB__MODIFY(reg,
                              incSettings->lsbSubNsInc);
        }
        CPS_UncachedWrite32(&(pD->regs->tsu_timer_incr_sub_nsec), reg);

        reg = 0U;
        EMAC_REGS__TSU_TIMER_INCR__NS_INCREMENT__MODIFY(reg,
                            incSettings->nanoSecsInc);
        EMAC_REGS__TSU_TIMER_INCR__ALT_NS_INCR__MODIFY(reg,
                            incSettings->altNanoSInc);
        EMAC_REGS__TSU_TIMER_INCR__NUM_INCS__MODIFY(reg,
                            incSettings->altIncCount);
        CPS_UncachedWrite32(&(pD->regs->tsu_timer_incr), reg);

#else
        reg = 0U;
        EMAC_REGS__TSU_TIMER_INCR_SUB_NSEC__TIMER__MODIFY(reg,
                                                        incSettings->subNsInc);
        CPS_UncachedWrite32(&(pD->regs->tsu_timer_incr_sub_nsec), reg);

        reg = 0U;
        EMAC_REGS__TSU_TIMER_INCR__COUNT__MODIFY(reg, incSettings->nanoSecsInc);
        EMAC_REGS__TSU_TIMER_INCR__ALT_COUNT__MODIFY(reg,
                            incSettings->altNanoSInc);
        EMAC_REGS__TSU_TIMER_INCR__NUM_INCS__MODIFY(reg, incSettings->altIncCount);
        CPS_UncachedWrite32(&(pD->regs->tsu_timer_incr), reg);
#endif
    }

    return (status);
}

static uint32_t emacGet1588TimerInc(CEDI_PrivateData *pD, CEDI_TimerIncrement *incSettings)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (incSettings==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: get1588TimerInc can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
#ifdef  EMAC_REGS__TSU_TIMER_INCR_SUB_NSEC__SUB_NS_INCR_LSB__READ
        reg = CPS_UncachedRead32(&(pD->regs->tsu_timer_incr_sub_nsec));
        incSettings->subNsInc = (uint16_t)
                    EMAC_REGS__TSU_TIMER_INCR_SUB_NSEC__SUB_NS_INCR__READ(reg);
        if (0U != subNsTsuInc24bSupport(pD)) {
            incSettings->lsbSubNsInc = (uint8_t)
                    EMAC_REGS__TSU_TIMER_INCR_SUB_NSEC__SUB_NS_INCR_LSB__READ(reg);
        } else {
            incSettings->lsbSubNsInc = 0U;
        }
        reg = CPS_UncachedRead32(&(pD->regs->tsu_timer_incr));
        incSettings->nanoSecsInc =(uint8_t)
                    EMAC_REGS__TSU_TIMER_INCR__NS_INCREMENT__READ(reg);
        incSettings->altNanoSInc = (uint8_t)
                    EMAC_REGS__TSU_TIMER_INCR__ALT_NS_INCR__READ(reg);
        incSettings->altIncCount = (uint8_t)EMAC_REGS__TSU_TIMER_INCR__NUM_INCS__READ(reg);
#else
        incSettings->subNsInc = (uint16_t)EMAC_REGS__TSU_TIMER_INCR_SUB_NSEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_timer_incr_sub_nsec)));
        incSettings->lsbSubNsInc = 0U;
        reg = CPS_UncachedRead32(&(pD->regs->tsu_timer_incr));
        incSettings->nanoSecsInc = EMAC_REGS__TSU_TIMER_INCR__COUNT__READ(reg);
        incSettings->altNanoSInc = EMAC_REGS__TSU_TIMER_INCR__ALT_COUNT__READ(reg);
        incSettings->altIncCount = (uint8_t)EMAC_REGS__TSU_TIMER_INCR__NUM_INCS__READ(reg);
#endif
    }

    return (status);
}

static uint32_t emacSetTsuTimerCompVal(CEDI_PrivateData *pD,
                                const CEDI_TsuTimerVal *timeVal)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (timeVal->nanosecs>0x003FFFFFU) {
            status = EINVAL;
        }
    }
    if (0U == status) {
        reg = 0U;
        EMAC_REGS__TSU_NSEC_CMP__COMPARISON_VALUE__MODIFY(reg, timeVal->nanosecs);
        CPS_UncachedWrite32(&(pD->regs->tsu_nsec_cmp), reg);
        reg = 0U;
        EMAC_REGS__TSU_SEC_CMP__COMPARISON_VALUE__MODIFY(reg, timeVal->secsLower);
        CPS_UncachedWrite32(&(pD->regs->tsu_sec_cmp), reg);
        reg = 0U;
        EMAC_REGS__TSU_MSB_SEC_CMP__COMPARISON_VALUE__MODIFY(reg, timeVal->secsUpper);
        CPS_UncachedWrite32(&(pD->regs->tsu_msb_sec_cmp), reg);
    }
    return (status);
}

static uint32_t emacGetTsuTimerCompVal(CEDI_PrivateData *pD, CEDI_TsuTimerVal *timeVal)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        timeVal->nanosecs = EMAC_REGS__TSU_NSEC_CMP__COMPARISON_VALUE__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_nsec_cmp)));
        timeVal->secsLower = EMAC_REGS__TSU_SEC_CMP__COMPARISON_VALUE__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_sec_cmp)));
        timeVal->secsUpper = (uint16_t)EMAC_REGS__TSU_MSB_SEC_CMP__COMPARISON_VALUE__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_msb_sec_cmp)));
    }
    return (status);
}

uint32_t emacGetPtpFrameTxTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        timeVal->nanosecs = EMAC_REGS__TSU_PTP_TX_NSEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_ptp_tx_nsec)));
        timeVal->secsLower = EMAC_REGS__TSU_PTP_TX_SEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_ptp_tx_sec)));
        timeVal->secsUpper = (uint16_t)EMAC_REGS__TSU_PTP_TX_MSB_SEC__TIMER_SECONDS__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_ptp_tx_msb_sec)));
    }
    return (status);
}

uint32_t emacGetPtpFrameRxTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        timeVal->nanosecs = EMAC_REGS__TSU_PTP_RX_NSEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_ptp_rx_nsec)));
        timeVal->secsLower = EMAC_REGS__TSU_PTP_RX_SEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_ptp_rx_sec)));
        timeVal->secsUpper = (uint16_t) EMAC_REGS__TSU_PTP_RX_MSB_SEC__TIMER_SECONDS__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_ptp_rx_msb_sec)));
    }
    return (status);
}

uint32_t emacGetPtpPeerFrameTxTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        timeVal->nanosecs = EMAC_REGS__TSU_PEER_TX_NSEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_peer_tx_nsec)));
        timeVal->secsLower = EMAC_REGS__TSU_PEER_TX_SEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_peer_tx_sec)));
        timeVal->secsUpper = (uint16_t)EMAC_REGS__TSU_PEER_TX_MSB_SEC__TIMER_SECONDS__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_peer_tx_msb_sec)));
    }
    return (status);
}

uint32_t emacGetPtpPeerFrameRxTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        timeVal->nanosecs = EMAC_REGS__TSU_PEER_RX_NSEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_peer_rx_nsec)));
        timeVal->secsLower = EMAC_REGS__TSU_PEER_RX_SEC__TIMER__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_peer_rx_sec)));
        timeVal->secsUpper = (uint16_t)EMAC_REGS__TSU_PEER_RX_MSB_SEC__TIMER_SECONDS__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_peer_rx_msb_sec)));
    }
    return (status);
}

uint32_t emacGet1588SyncStrobeTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (timeVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        timeVal->nanosecs = EMAC_REGS__TSU_STROBE_NSEC__STROBE__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_strobe_nsec)));
        timeVal->secsLower = EMAC_REGS__TSU_STROBE_SEC__STROBE__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_strobe_sec)));
        timeVal->secsUpper = (uint16_t)
                EMAC_REGS__TSU_STROBE_MSB_SEC__STROBE__READ(
                CPS_UncachedRead32(&(pD->regs->tsu_strobe_msb_sec)));
    }
    return (status);
}

uint32_t emacSetExtTsuPortEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setExtTsuPortEnable can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        if (0U==pD->hwCfg.ext_tsu_timer) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__EXT_TSU_PORT_ENABLE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONTROL__EXT_TSU_PORT_ENABLE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }

    return (status);
}

uint32_t emacGetExtTsuPortEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        *enable= 0U;
        if (0U==pD->hwCfg.tsu) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getExtTsuPortEnable can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        *enable = (uint8_t) EMAC_REGS__NETWORK_CONTROL__EXT_TSU_PORT_ENABLE__READ(
                CPS_UncachedRead32(&(pD->regs->network_control)));
    }
    return (status);
}

uint32_t emacSet1588OneStepTxSyncEnable(CEDI_PrivateData *pD, uint8_t enable)
{

    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__ONE_STEP_SYNC_MODE__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONTROL__ONE_STEP_SYNC_MODE__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }

    return (status);
}

uint32_t emacGet1588OneStepTxSyncEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable = 0U;
        if (0U != pD->hwCfg.tsu)
        {
            *enable = (uint8_t) EMAC_REGS__NETWORK_CONTROL__ONE_STEP_SYNC_MODE__READ(
                CPS_UncachedRead32(&(pD->regs->network_control)));
        }
    }
    return (status);
}

/****************************** Time Stamping *********************************/

uint32_t emacSetDescTimeStampMode(CEDI_PrivateData *pD, CEDI_TxTsMode txMode,
                                    CEDI_RxTsMode rxMode)
{
    uint32_t status = 0U;
    uint32_t regData;
    CEDI_Config *config;

    if ((pD==NULL) ||
        ((uint8_t)txMode > (uint8_t)CEDI_TX_TS_ALL) ||
        ((uint8_t)rxMode > (uint8_t)CEDI_RX_TS_ALL)) {
        status = EINVAL;
    }

    if (0U == status) {
        config = &(pD->cfg);

        if (((config->enTxExtBD==0) && (txMode!=0))||
                ((config->enRxExtBD==0) && (rxMode!=0)))
        {
            vDbgMsg(DBG_GEN_MSG, 5, "%s", "ERROR: Time stamping not enabled in DMA config ");
            status = EINVAL;
        }
    }

    if (0U == status) {
        regData = CPS_UncachedRead32(&(pD->regs->tx_bd_control));
        EMAC_REGS__TX_BD_CONTROL__TX_BD_TS_MODE__MODIFY(regData, txMode);
        CPS_UncachedWrite32(&(pD->regs->tx_bd_control), regData);

        regData = CPS_UncachedRead32(&(pD->regs->rx_bd_control));
        EMAC_REGS__RX_BD_CONTROL__RX_BD_TS_MODE__MODIFY(regData, rxMode);
        CPS_UncachedWrite32(&(pD->regs->rx_bd_control), regData);
    }

    return (status);
}

uint32_t emacGetDescTimeStampMode(CEDI_PrivateData *pD, CEDI_TxTsMode* txMode,
                                    CEDI_RxTsMode* rxMode)
{
    uint32_t status = 0U;
    uint32_t regData;
    uint32_t mode;
    CEDI_Config *config;

    if ((pD==NULL) || (txMode==NULL) || (rxMode==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        config = &(pD->cfg);

        if ((config->enTxExtBD==0U) || (config->enRxExtBD==0U)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        regData = CPS_UncachedRead32(&(pD->regs->tx_bd_control));
        mode = EMAC_REGS__TX_BD_CONTROL__TX_BD_TS_MODE__READ(regData);
        *txMode = (CEDI_TxTsMode)mode;

        regData = CPS_UncachedRead32(&(pD->regs->rx_bd_control));
        mode = EMAC_REGS__RX_BD_CONTROL__RX_BD_TS_MODE__READ(regData);
        *rxMode = (CEDI_RxTsMode)mode;
    }

    return (status);
}

uint32_t emacSetStoreRxTimeStamp(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__STORE_RX_TS__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONTROL__STORE_RX_TS__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
    return (status);
}

uint32_t emacGetStoreRxTimeStamp(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        *enable = 0U;
        if (0U==pD->hwCfg.tsu) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        *enable = (uint8_t) EMAC_REGS__NETWORK_CONTROL__STORE_RX_TS__READ(
                CPS_UncachedRead32(&(pD->regs->network_control)));
    }
    return (status);
}

/********************** PCS Control/Auto-negotiation *************************/

uint32_t emacResetPcs(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    uint32_t reg;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0U == status) {
        vDbgMsg(DBG_GEN_MSG, 10, "%s entered (regBase %08X)\n", __func__,
                (uint32_t)pD->cfg.regBase);
        if (0U != pD->hwCfg.no_pcs) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: resetPcs can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pcs_control));
        EMAC_REGS__PCS_CONTROL__PCS_SOFTWARE_RESET__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->pcs_control), reg);

        pD->basePageExp = 1U;
        pD->autoNegActive = 0U;
    }

    return (status);
}

uint32_t emacGetPcsReady(CEDI_PrivateData *pD, uint8_t *ready)
{

    uint32_t status = 0U;

    if ((pD==NULL) || (ready==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U != pD->hwCfg.no_pcs) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getPcsReady can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        *ready = (0U==EMAC_REGS__PCS_CONTROL__PCS_SOFTWARE_RESET__READ(
                CPS_UncachedRead32(&(pD->regs->pcs_control))));
    }
    return (status);
}

static uint32_t emacStartAutoNegotiation(CEDI_PrivateData *pD,
                                  const CEDI_AnAdvPage *advDat)
{
    uint32_t status = 0U;
    uint32_t reg;
    uint32_t event;

    if ((pD==NULL) || (advDat==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if ((pD->hwCfg.no_pcs) ||
           (EMAC_REGS__NETWORK_CONFIG__SGMII_MODE_ENABLE__READ(
                CPS_UncachedRead32(&(pD->regs->network_config))))) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: startAutoNegotiation can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        if (0U != pD->autoNegActive) {
            status = EBUSY;
        }
    }

    //check if we have an event for auto negotiation complete:
    if (0U == status) {
        status = emacGetEventEnable(pD, 0, &event);
    }

    if ((0U == status) && ((event & (uint32_t)CEDI_EV_PCS_AN_COMPLETE) == 0)) {
        status = EINVAL;
    }

    if (0U == status) {
        if ((advDat->fullDuplex>1U) || (advDat->halfDuplex>1U) || (advDat->nextPage>1U)
                || (advDat->pauseCap>CEDI_AN_PAUSE_CAP_BOTH)
                || (advDat->remFlt>CEDI_AN_REM_FLT_AN_ERR)) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pcs_control));
        EMAC_REGS__PCS_CONTROL__ENABLE_AUTO_NEG__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->pcs_control), reg);

        status = emacSetAnAdvPage(pD, advDat);
        if (0U != status) {
            vDbgMsg(DBG_GEN_MSG, 10,
                "emacStartAutoNegotiation: emacSetAnAdvPage "\
                "returned with code: %u\n", status);
        }
    }

    if (0U == status) {
        pD->autoNegActive = 1U;
        pD->basePageExp = 1U;

        reg = CPS_UncachedRead32(&(pD->regs->pcs_control));
        EMAC_REGS__PCS_CONTROL__RESTART_AUTO_NEG__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->pcs_control), reg);
    }
    return (status);
}

uint32_t emacSetAutoNegEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    }

    if (0U == status) {
	uint8_t sgmii;
	reg = CPS_UncachedRead32(&(pD->regs->network_config));
	sgmii = EMAC_REGS__NETWORK_CONFIG__SGMII_MODE_ENABLE__READ(reg);
        if (pD->hwCfg.no_pcs || sgmii) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setAutoNegEnable can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        if (((enable) && pD->autoNegActive) != 0U) {
            status = EBUSY;
        }
    }

    if (0U == status) {
	SetAutoNegEnable(pD, enable);
    }

    return (status);
}

uint32_t emacGetAutoNegEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;

    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U != pD->hwCfg.no_pcs) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getAutoNegEnable can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
	GetAutoNegEnable(pD, enable);
    }
    return (status);
}

/* internal utility for reading PCS status & maintaining
 * "read-once" functionality of link status & remote fault
 */
uint32_t readPcsStatus(CEDI_PrivateData *pD) {
    uint32_t reg = CPS_UncachedRead32(&(pD->regs->pcs_status));
    if (0U==EMAC_REGS__PCS_STATUS__LINK_STATUS__READ(reg)) {
        pD->anLinkStat = 0U;
    }
    if (1==EMAC_REGS__PCS_STATUS__REMOTE_FAULT__READ(reg)) {
        pD->anRemFault = 1U;
    }
    return (reg);
}

uint32_t emacGetLinkStatus(CEDI_PrivateData *pD, uint8_t *status)
{
    uint32_t r_status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (status==NULL)) {
        r_status = EINVAL;
    }

    if (0U == r_status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getLinkStatus can not be called for express MAC.");
                r_status = EINVAL;
            }
        }
    }

    if (0U == r_status) {
        reg = readPcsStatus(pD);
        /* return low if this has not been done yet */
        *status = pD->anLinkStat;

        pD->anLinkStat = (uint8_t)
                EMAC_REGS__PCS_STATUS__LINK_STATUS__READ(reg);
    }

    return (r_status);
}

uint32_t emacGetAnRemoteFault(CEDI_PrivateData *pD, uint8_t *status)
{
    uint32_t r_status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (status==NULL)) {
        r_status = EINVAL;
    }

    if (0U == r_status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getAnRemoteFault can not be called for express MAC.");
                r_status = EINVAL;
            }
        }
    }

    if (0U == r_status) {
        reg = readPcsStatus(pD);
        /* return high if this has not been done yet */
        *status = pD->anRemFault;

        pD->anRemFault =(uint8_t)
                EMAC_REGS__PCS_STATUS__REMOTE_FAULT__READ(reg);
    }

    return (r_status);
}

uint32_t emacGetAnComplete(CEDI_PrivateData *pD, uint8_t *status)
{
    uint32_t r_status = 0U;

    if ((pD==NULL) || (status==NULL)) {
        r_status = EINVAL;
    }

    if (0U == r_status) {
        if (0U != pD->hwCfg.no_pcs) {
            r_status = ENOTSUP;
        }
    }

    if (0U == r_status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getAnComplete can not be called for express MAC.");
                r_status = EINVAL;
            }
        }
    }

    if (0U == r_status) {
        *status = (uint8_t)EMAC_REGS__PCS_STATUS__AUTO_NEG_COMPLETE__READ(readPcsStatus(pD));
    }

    return (r_status);
}

uint32_t emacSetAnAdvPage(CEDI_PrivateData *pD, const CEDI_AnAdvPage *advDat)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (advDat==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->hwCfg.no_pcs) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setAnAdvPage can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        if ((advDat->fullDuplex>1U) || (advDat->halfDuplex>1U) || (advDat->nextPage>1U)
                || (advDat->pauseCap>CEDI_AN_PAUSE_CAP_BOTH)
                || (advDat->remFlt>CEDI_AN_REM_FLT_AN_ERR)) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        reg = 0U;
        if (0U != advDat->fullDuplex) {
            EMAC_REGS__PCS_AN_ADV__FULL_DUPLEX__SET(reg);
        }
        if (0U != advDat->halfDuplex) {
            EMAC_REGS__PCS_AN_ADV__HALF_DUPLEX__SET(reg);
        }
        EMAC_REGS__PCS_AN_ADV__PAUSE__MODIFY(reg, advDat->pauseCap);
        EMAC_REGS__PCS_AN_ADV__REMOTE_FAULT__MODIFY(reg, advDat->remFlt);
        if (0U != advDat->nextPage) {
            EMAC_REGS__PCS_AN_ADV__NEXT_PAGE__SET(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->pcs_an_adv), reg);
    }

    return (status);
}

uint32_t emacGetAnAdvPage(CEDI_PrivateData *pD, CEDI_AnAdvPage *advDat)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (advDat==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->hwCfg.no_pcs) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getAnAdvPage can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pcs_an_adv));
        advDat->fullDuplex = (uint8_t)EMAC_REGS__PCS_AN_ADV__FULL_DUPLEX__READ(reg);
        advDat->halfDuplex = (uint8_t)EMAC_REGS__PCS_AN_ADV__HALF_DUPLEX__READ(reg);
        advDat->pauseCap = EMAC_REGS__PCS_AN_ADV__PAUSE__READ(reg);
        advDat->remFlt = EMAC_REGS__PCS_AN_ADV__REMOTE_FAULT__READ(reg);
        advDat->nextPage = (uint8_t)EMAC_REGS__PCS_AN_ADV__NEXT_PAGE__READ(reg);
    }

    return (status);
}

uint32_t emacGetLpAbilityPage(CEDI_PrivateData *pD, CEDI_LpAbilityPage *lpAbl)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (lpAbl==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->hwCfg.no_pcs) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getLpAbilityPage can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pcs_an_lp_base));

        if (0U != EMAC_REGS__NETWORK_CONFIG__SGMII_MODE_ENABLE__READ(
                CPS_UncachedRead32(&(pD->regs->network_config))))
        {
            /* SGMII mode format */
            lpAbl->sgmii = 1U;
            lpAbl->ablInfo.sgmLpAbl.speed =
                    EMAC_REGS__PCS_AN_LP_BASE__SPEED_RESERVED__READ(reg)>>1;
            lpAbl->ablInfo.sgmLpAbl.lpAck = (uint8_t)
                    (EMAC_REGS__PCS_AN_LP_BASE__LINK_PARTNER_ACKNOWLEDGE__READ(reg));
            lpAbl->ablInfo.sgmLpAbl.linkStatus =(uint8_t)
                    (EMAC_REGS__PCS_AN_LP_BASE__LINK_PARTNER_NEXT_PAGE_STATUS__READ(reg));
            lpAbl->ablInfo.sgmLpAbl.duplex =(uint8_t)
                    (EMAC_REGS__PCS_AN_LP_BASE__LINK_PARTNER_REMOTE_FAULT_DUPLEX_MODE__READ(reg));
        }
        else
        {
            /* Default format */
            lpAbl->sgmii = 0U;
            lpAbl->ablInfo.defLpAbl.fullDuplex = (uint8_t)
                    EMAC_REGS__PCS_AN_LP_BASE__LINK_PARTNER_FULL_DUPLEX__READ(reg);
            lpAbl->ablInfo.defLpAbl.halfDuplex = (uint8_t)
                    EMAC_REGS__PCS_AN_LP_BASE__LINK_PARTNER_HALF_DUPLEX__READ(reg);
            lpAbl->ablInfo.defLpAbl.pauseCap =
                    EMAC_REGS__PCS_AN_LP_BASE__PAUSE__READ(reg);
            lpAbl->ablInfo.defLpAbl.lpAck = (uint8_t)
                    EMAC_REGS__PCS_AN_LP_BASE__LINK_PARTNER_ACKNOWLEDGE__READ(reg);
            lpAbl->ablInfo.defLpAbl.remFlt =(uint8_t)
                    EMAC_REGS__PCS_AN_LP_BASE__LINK_PARTNER_REMOTE_FAULT_DUPLEX_MODE__READ(reg);
            lpAbl->ablInfo.defLpAbl.lpNextPage =(uint8_t)
                    EMAC_REGS__PCS_AN_LP_BASE__LINK_PARTNER_NEXT_PAGE_STATUS__READ(reg);
        }
    }

    return (status);
}

uint32_t emacGetPageRx(CEDI_PrivateData *pD)
{
    uint32_t retVal = 1U;
    if (pD==NULL) {
        retVal = 0U;
    }

    if (1U == retVal) {
        if (0U != pD->hwCfg.no_pcs) {
            retVal = 0U;
        }
    }

    if (1U == retVal) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getPageRx can not be called for express MAC.");
                retVal = 0U;
            }
        }
    }

    if (1U == retVal) {
        retVal = (EMAC_REGS__PCS_AN_EXP__PAGE_RECEIVED__READ(
                  CPS_UncachedRead32(&(pD->regs->pcs_an_exp))));
    }

    return (retVal);
}

uint32_t emacSetNextPageTx(CEDI_PrivateData *pD, const CEDI_AnNextPage *npDat)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (npDat==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->hwCfg.no_pcs) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if ((npDat->message>0x7FFU) || (npDat->ack2>1U) || (npDat->msgPage>1U)
                || (npDat->np>1U)) {
            status = EINVAL;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setNextPageTx can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = 0U;
        EMAC_REGS__PCS_AN_NP_TX__MESSAGE__MODIFY(reg, npDat->message);
        if (0U != npDat->ack2) {
            EMAC_REGS__PCS_AN_NP_TX__ACKNOWLEDGE_2__SET(reg);
        }
        if (0U != npDat->msgPage) {
            EMAC_REGS__PCS_AN_NP_TX__MESSAGE_PAGE_INDICATOR__SET(reg);
        }
        if (0U != npDat->np) {
            EMAC_REGS__PCS_AN_NP_TX__NEXT_PAGE_TO_TRANSMIT__SET(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->pcs_an_np_tx), reg);
    }

    return (status);
}

uint32_t emacGetNextPageTx(CEDI_PrivateData *pD, CEDI_AnNextPage *npDat)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (npDat==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getNextPageTx can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pcs_an_np_tx));
        npDat->message = (uint16_t)EMAC_REGS__PCS_AN_NP_TX__MESSAGE__READ(reg);
        npDat->ack2 = (uint8_t)EMAC_REGS__PCS_AN_NP_TX__ACKNOWLEDGE_2__READ(reg);
        npDat->msgPage = (uint8_t)EMAC_REGS__PCS_AN_NP_TX__MESSAGE_PAGE_INDICATOR__READ(reg);
        npDat->np = (uint8_t)EMAC_REGS__PCS_AN_NP_TX__NEXT_PAGE_TO_TRANSMIT__READ(reg);
    }

    return (status);
}

uint32_t emacGetLpNextPage(CEDI_PrivateData *pD, CEDI_LpNextPage *npDat)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (npDat==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getLpNextPage can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pcs_an_lp_np));
        npDat->message = (uint16_t) EMAC_REGS__PCS_AN_LP_NP__MESSAGE__READ(reg);
        npDat->toggle = (uint8_t) EMAC_REGS__PCS_AN_LP_NP__TOGGLE__READ(reg);
        npDat->ack2 = (uint8_t) EMAC_REGS__PCS_AN_LP_NP__ACKNOWLEDGE_2__READ(reg);
        npDat->msgPage = (uint8_t) EMAC_REGS__PCS_AN_LP_NP__MESSAGE_PAGE_INDICATOR__READ(reg);
        npDat->ack = (uint8_t) EMAC_REGS__PCS_AN_LP_NP__ACKNOWLEDGE__READ(reg);
        npDat->np = (uint8_t) EMAC_REGS__PCS_AN_LP_NP__NEXT_PAGE_TO_RECEIVE__READ(reg);
    }

    return (status);
}

/**************************** PHY Management *********************************/

uint32_t emacGetPhyId(CEDI_PrivateData *pD, uint32_t *phyId)
{
    uint32_t status = 0U;
    uint32_t reg, retVal;
    if ((pD==NULL) || (phyId==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getPhyId can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        if(0U != pD->hwCfg.phy_ident) {
            reg = CPS_UncachedRead32(&(pD->regs->pcs_phy_top_id));
            retVal = EMAC_REGS__PCS_PHY_TOP_ID__ID_CODE__READ(reg)<<16U;
            reg = CPS_UncachedRead32(&(pD->regs->pcs_phy_bot_id));
            retVal |= EMAC_REGS__PCS_PHY_BOT_ID__ID_CODE__READ(reg);
            *phyId= retVal;
        } else {
            status = ENOTSUP;
        }
    }

    return (status);
}

uint32_t emacSetMdioEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t ncr;
     if ((pD==NULL) || (enable>1)) {
        status = EINVAL;
     }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setMdioEnable can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        ncr = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__MAN_PORT_EN__SET(ncr);
        } else {
            EMAC_REGS__NETWORK_CONTROL__MAN_PORT_EN__CLR(ncr);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), ncr);
    }
    return (status);
}

uint32_t emacGetMdioEnable(CEDI_PrivateData *pD)
{
    uint32_t retVal = 1U;

    if (pD==NULL) {
        retVal = 0U;
    }
    if (1 == retVal) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getMdioEnable can not be called for express MAC.");
                retVal = 0U;
            }
        }
    }
    if (1U == retVal) {
        retVal = (EMAC_REGS__NETWORK_CONTROL__MAN_PORT_EN__READ(
                CPS_UncachedRead32(&(pD->regs->network_control))));
    }

    return (retVal);
}

/* Initiate a write or set address operation on the MDIO interface.
 * Clause 45 devices require a call to set the register address (if
 * this is changing since last access), and then a write or read
 * operation.
 * The command writes to the shift register, which starts output on
 * the MDIO interface. Write completion is signalled by the
 * phyManComplete callback, or by polling getMdioIdle.
 * @param pD - driver private state info specific to this instance
 * @param flags - combination of 2 bit-flags:
 *        if CEDI_MDIO_FLG_CLAUSE_45 present, specifies clause 45 PHY
 *        (else clause 22).
 *        if CEDI_MDIO_FLG_SET_ADDR present, specifies a set address operation
 *        (else do a write operation)  Ignored if not clause 45.
 * @param phyAddr - PHY address
 * @param devReg - device type (clause 45) or register address (clause 22)
 *           - enum CEDI_MdioDevType is available to specify the device type
 * @param addrData - register address (if CEDI_MDIO_FLG_SET_ADDR) or data to write
 */
uint32_t emacPhyStartMdioWrite(CEDI_PrivateData *pD, uint8_t flags, uint8_t phyAddr,
        uint8_t devReg, uint16_t addrData)
{
    uint32_t status = 0U;
    uint32_t reg;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U != (flags &
            ~(CEDI_MDIO_FLG_CLAUSE_45 |
            CEDI_MDIO_FLG_SET_ADDR))) {
        status = EINVAL;
    }
    if (phyAddr > 0x1FU) {
        status = EINVAL;
    }
    if (devReg > 0x1FU) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: phyStartMdioWrite can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        reg = 0U;
        EMAC_REGS__PHY_MANAGEMENT__PHY_WRITE_READ_DATA__MODIFY(reg, addrData);
        EMAC_REGS__PHY_MANAGEMENT__WRITE10__MODIFY(reg, 2U);
        EMAC_REGS__PHY_MANAGEMENT__REGISTER_ADDRESS__MODIFY(reg, devReg);
        EMAC_REGS__PHY_MANAGEMENT__PHY_ADDRESS__MODIFY(reg, phyAddr);
        if ((flags & CEDI_MDIO_FLG_CLAUSE_45) && (flags & CEDI_MDIO_FLG_SET_ADDR)) {
            EMAC_REGS__PHY_MANAGEMENT__OPERATION__MODIFY(reg, CEDI_PHY_ADDR_OP);
        } else {
            EMAC_REGS__PHY_MANAGEMENT__OPERATION__MODIFY(reg, CEDI_PHY_WRITE_OP);
        }
        if ((flags & CEDI_MDIO_FLG_CLAUSE_45)==0U) {
            EMAC_REGS__PHY_MANAGEMENT__WRITE1__SET(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->phy_management), reg);
    }
    return (status);
}

/* Initiate a read operation on the MDIO interface.  If clause 45, the
 * register address will need to be set by a preceding phyStartMdioWrite
 * call, unless same as for last operation. Completion is signalled by the
 * phyManComplete callback, which will return the read data by a pointer
 * parameter. Alternatively polling getMdioIdle will indicate when
 * the operation completes, then getMdioReadDat will return the data.
 * @param pD - driver private state info specific to this instance
 * @param flags - combination of 2 bit-flags:
 *        if CEDI_MDIO_FLG_CLAUSE_45 present, specifies clause 45 PHY
 *        (else clause 22).
 *        if CEDI_MDIO_FLG_INC_ADDR present, and clause 45, then address will
 *        be incremented after the read operation.
 * @param phyAddr - PHY address
 * @param devReg - device type (clause 45) or register address (clause 22)
 *           - enum CEDI_MdioDevType is available to specify the device type
 */
uint32_t emacPhyStartMdioRead(CEDI_PrivateData *pD, uint8_t flags, uint8_t phyAddr,
        uint8_t devReg)
{
    uint32_t status = 0U;
    uint32_t reg;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U != (flags &
            ~(CEDI_MDIO_FLG_CLAUSE_45 |
            CEDI_MDIO_FLG_INC_ADDR))) {
        status = EINVAL;
    }
    if (phyAddr > 0x1FU) {
        status = EINVAL;
    }
    if (devReg > 0x1FU) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: phyStartMdioRead can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        reg = 0U;
        EMAC_REGS__PHY_MANAGEMENT__WRITE10__MODIFY(reg, 2U);
        EMAC_REGS__PHY_MANAGEMENT__REGISTER_ADDRESS__MODIFY(reg, devReg);
        EMAC_REGS__PHY_MANAGEMENT__PHY_ADDRESS__MODIFY(reg, phyAddr);
        if (0U != (flags & CEDI_MDIO_FLG_CLAUSE_45)) {
            if (0U != (flags & CEDI_MDIO_FLG_INC_ADDR)) {
                EMAC_REGS__PHY_MANAGEMENT__OPERATION__MODIFY(reg,
                        CEDI_PHY_CL45_READ_INC_OP);
            }
            else {
                EMAC_REGS__PHY_MANAGEMENT__OPERATION__MODIFY(reg,
                        CEDI_PHY_CL45_READ_OP);
            }
        } else {
            EMAC_REGS__PHY_MANAGEMENT__OPERATION__MODIFY(reg, CEDI_PHY_CL22_READ_OP);
        }
        if ((flags & CEDI_MDIO_FLG_CLAUSE_45)==0U) {
            EMAC_REGS__PHY_MANAGEMENT__WRITE1__SET(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->phy_management), reg);
    }
    return (status);
}

uint32_t emacGetMdioReadData(CEDI_PrivateData *pD, uint16_t *readData)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (readData==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getMdioReadData can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        *readData = (uint16_t) EMAC_REGS__PHY_MANAGEMENT__PHY_WRITE_READ_DATA__READ(
                CPS_UncachedRead32(&(pD->regs->phy_management)));
    }

    return (status);
}

uint32_t emacGetMdioIdle(CEDI_PrivateData *pD)
{
    uint32_t retVal = 1U;
    if (pD==NULL) {
        retVal = 0U;
    }
    if (retVal == 1U) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getMdioIdle can not be called for express MAC.");
                retVal = 0U;
            }
        }
    }
    if (1U == retVal) {
        retVal = (EMAC_REGS__NETWORK_STATUS__MAN_DONE__READ(
                  CPS_UncachedRead32(&(pD->regs->network_status))));
    }
    return (retVal);
}

/************************* Statistics Registers ******************************/

uint32_t emacReadStats(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    CEDI_Statistics *stats;

    if (pD==NULL) {
        status = EINVAL;
    }

    if (0U == status) {
        stats = ((CEDI_Statistics *)(pD->cfg.statsRegs));

        if (0U != pD->hwCfg.no_stats) {
           status = ENOTSUP;
        }
    }

    if (0U == status) {
        stats->octetsTxLo = CPS_UncachedRead32(&(pD->regs->octets_txed_bottom));
        stats->octetsTxHi = (uint16_t) EMAC_REGS__OCTETS_TXED_TOP__COUNT__READ(
                             CPS_UncachedRead32(&(pD->regs->octets_txed_top)));
        stats->framesTx = CPS_UncachedRead32(&(pD->regs->frames_txed_ok));
        stats->broadcastTx = CPS_UncachedRead32(&(pD->regs->broadcast_txed));
        stats->multicastTx = CPS_UncachedRead32(&(pD->regs->multicast_txed));
        stats->pauseFrTx = (uint16_t)EMAC_REGS__PAUSE_FRAMES_TXED__COUNT__READ(
                            CPS_UncachedRead32(&(pD->regs->pause_frames_txed)));
        stats->fr64byteTx = CPS_UncachedRead32(&(pD->regs->frames_txed_64));
        stats->fr65_127byteTx = CPS_UncachedRead32(&(pD->regs->frames_txed_65));
        stats->fr128_255byteTx = CPS_UncachedRead32(&(pD->regs->frames_txed_128));
        stats->fr256_511byteTx = CPS_UncachedRead32(&(pD->regs->frames_txed_256));
        stats->fr512_1023byteTx = CPS_UncachedRead32(&(pD->regs->frames_txed_512));
        stats->fr1024_1518byteTx =
                                CPS_UncachedRead32(&(pD->regs->frames_txed_1024));
        stats->fr1519_byteTx = CPS_UncachedRead32(&(pD->regs->frames_txed_1519));
            stats->underrunFrTx = (uint16_t)EMAC_REGS__TX_UNDERRUNS__COUNT__READ(
                                CPS_UncachedRead32(&(pD->regs->tx_underruns)));
        stats->singleCollFrTx =
                            CPS_UncachedRead32(&(pD->regs->single_collisions));
        stats->multiCollFrTx =
                            CPS_UncachedRead32(&(pD->regs->multiple_collisions));
        stats->excessCollFrTx = (uint16_t)EMAC_REGS__EXCESSIVE_COLLISIONS__COUNT__READ(
                           CPS_UncachedRead32(&(pD->regs->excessive_collisions)));
        stats->lateCollFrTx = (uint16_t)EMAC_REGS__LATE_COLLISIONS__COUNT__READ(
                                CPS_UncachedRead32(&(pD->regs->late_collisions)));
        stats->carrSensErrsTx = (uint16_t)EMAC_REGS__CRS_ERRORS__COUNT__READ(
                                  CPS_UncachedRead32(&(pD->regs->crs_errors)));
        stats->deferredFrTx = CPS_UncachedRead32(&(pD->regs->deferred_frames));
        stats->alignErrsRx = (uint16_t)EMAC_REGS__ALIGNMENT_ERRORS__COUNT__READ(
                            CPS_UncachedRead32(&(pD->regs->alignment_errors)));
            stats->octetsRxLo = CPS_UncachedRead32(&(pD->regs->octets_rxed_bottom));
        stats->octetsRxHi = (uint16_t)EMAC_REGS__OCTETS_RXED_TOP__COUNT__READ(
                              CPS_UncachedRead32(&(pD->regs->octets_rxed_top)));
        stats->framesRx = CPS_UncachedRead32(&(pD->regs->frames_rxed_ok));
        stats->broadcastRx = CPS_UncachedRead32(&(pD->regs->broadcast_rxed));
        stats->multicastRx = CPS_UncachedRead32(&(pD->regs->multicast_rxed));
        stats->pauseFrRx = (uint16_t)EMAC_REGS__PAUSE_FRAMES_RXED__COUNT__READ(
                            CPS_UncachedRead32(&(pD->regs->pause_frames_rxed)));
        stats->fr64byteRx = CPS_UncachedRead32(&(pD->regs->frames_rxed_64));
        stats->fr65_127byteRx = CPS_UncachedRead32(&(pD->regs->frames_rxed_65));
        stats->fr128_255byteRx = CPS_UncachedRead32(&(pD->regs->frames_rxed_128));
        stats->fr256_511byteRx = CPS_UncachedRead32(&(pD->regs->frames_rxed_256));
        stats->fr512_1023byteRx =
                                CPS_UncachedRead32(&(pD->regs->frames_rxed_512));
        stats->fr1024_1518byteRx =
                                CPS_UncachedRead32(&(pD->regs->frames_rxed_1024));
        stats->fr1519_byteRx =
                                CPS_UncachedRead32(&(pD->regs->frames_rxed_1519));
        stats->undersizeFrRx = (uint16_t)EMAC_REGS__UNDERSIZE_FRAMES__COUNT__READ(
                              CPS_UncachedRead32(&(pD->regs->undersize_frames)));
        stats->oversizeFrRx = (uint16_t)EMAC_REGS__EXCESSIVE_RX_LENGTH__COUNT__READ(
                        CPS_UncachedRead32(&(pD->regs->excessive_rx_length)));
        stats->jabbersRx = (uint16_t)EMAC_REGS__RX_JABBERS__COUNT__READ(
                                CPS_UncachedRead32(&(pD->regs->rx_jabbers)));
        stats->fcsErrorsRx = (uint16_t)EMAC_REGS__FCS_ERRORS__COUNT__READ(
                                CPS_UncachedRead32(&(pD->regs->fcs_errors)));
        stats->lenChkErrRx = (uint16_t)EMAC_REGS__RX_LENGTH_ERRORS__COUNT__READ(
                              CPS_UncachedRead32(&(pD->regs->rx_length_errors)));
        stats->rxSymbolErrs = (uint16_t)EMAC_REGS__RX_SYMBOL_ERRORS__COUNT__READ(
                            CPS_UncachedRead32(&(pD->regs->rx_symbol_errors)));
        stats->rxResourcErrs =
                            CPS_UncachedRead32(&(pD->regs->rx_resource_errors));
        stats->overrunFrRx = (uint16_t)EMAC_REGS__RX_OVERRUNS__COUNT__READ(
                                CPS_UncachedRead32(&(pD->regs->rx_overruns)));
        stats->ipChksumErrs = (uint16_t)EMAC_REGS__RX_IP_CK_ERRORS__COUNT__READ(
                            CPS_UncachedRead32(&(pD->regs->rx_ip_ck_errors)));
        stats->tcpChksumErrs = (uint16_t)EMAC_REGS__RX_TCP_CK_ERRORS__COUNT__READ(
                            CPS_UncachedRead32(&(pD->regs->rx_tcp_ck_errors)));
        stats->udpChksumErrs = (uint16_t)EMAC_REGS__RX_UDP_CK_ERRORS__COUNT__READ(
                            CPS_UncachedRead32(&(pD->regs->rx_udp_ck_errors)));
        stats->dmaRxPBufFlush = (uint16_t)EMAC_REGS__AUTO_FLUSHED_PKTS__COUNT__READ(
                            CPS_UncachedRead32(&(pD->regs->auto_flushed_pkts)));
    }
    return (status);
}

uint32_t emacClearStats(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    uint32_t reg;
    if (pD==NULL) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U != pD->hwCfg.no_stats) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__CLEAR_ALL_STATS_REGS__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
    return (status);

}

uint32_t emacTakeSnapshot(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    uint32_t reg;

    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U == status) {
        if ((pD->hwCfg.no_snapshot != 0U) || (pD->hwCfg.no_stats != 0U)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__STATS_TAKE_SNAP__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
    return (status);
}

uint32_t emacSetReadSnapshot(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    }
    if (0U == status) {
        if ((pD->hwCfg.no_snapshot != 0U) || (pD->hwCfg.no_stats != 0U)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__STATS_READ_SNAP__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONTROL__STATS_READ_SNAP__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
    return (status);
}

uint32_t emacGetReadSnapshot(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (pD->hwCfg.no_snapshot || pD->hwCfg.no_stats) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        *enable = (uint8_t)EMAC_REGS__NETWORK_CONTROL__STATS_READ_SNAP__READ(
                CPS_UncachedRead32(&(pD->regs->network_control)));
    }
    return (status);
}

/************************ WakeOnLAN/EEE Support ******************************/

uint32_t emacSetWakeOnLanReg(CEDI_PrivateData *pD, const CEDI_WakeOnLanReg *regVals)
{
    uint32_t status = 0U;
    uint32_t reg = 0U;

    if ((pD==NULL) || (regVals==NULL) || (regVals->magPktEn>1U) ||
        (regVals->arpEn>1U) || (regVals->specAd1En>1U) || (regVals->multiHashEn>1U)) {
        status = EINVAL;
    } else {
        EMAC_REGS__WOL_REGISTER__ADDR__MODIFY(reg, regVals->wolReqAddr);
        if (0U != regVals->magPktEn) {
            EMAC_REGS__WOL_REGISTER__WOL_MASK_0__SET(reg);
        }
        if (0U != regVals->arpEn) {
            EMAC_REGS__WOL_REGISTER__WOL_MASK_1__SET(reg);
        }
        if (0U != regVals->specAd1En) {
            EMAC_REGS__WOL_REGISTER__WOL_MASK_2__SET(reg);
        }
        if (0U != regVals->multiHashEn) {
            EMAC_REGS__WOL_REGISTER__WOL_MASK_3__SET(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->wol_register), reg);
    }

    return (status);
}

uint32_t emacGetWakeOnLanReg(CEDI_PrivateData *pD, CEDI_WakeOnLanReg *regVals)
{
    uint32_t status = 0U;
    uint32_t reg = 0U;

    if ((pD==NULL) || (regVals==NULL)) {
        status = EINVAL;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->wol_register));
        regVals->wolReqAddr = (uint16_t) EMAC_REGS__WOL_REGISTER__ADDR__READ(reg);
        regVals->magPktEn = (uint8_t) EMAC_REGS__WOL_REGISTER__WOL_MASK_0__READ(reg);
        regVals->arpEn = (uint8_t) EMAC_REGS__WOL_REGISTER__WOL_MASK_1__READ(reg);
        regVals->specAd1En = (uint8_t) EMAC_REGS__WOL_REGISTER__WOL_MASK_2__READ(reg);
        regVals->multiHashEn = (uint8_t) EMAC_REGS__WOL_REGISTER__WOL_MASK_3__READ(reg);
    }
    return (status);
}

uint32_t emacSetLpiTxEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    } else {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__TX_LPI_EN__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONTROL__TX_LPI_EN__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
    return (status);
}

uint32_t emacGetLpiTxEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable = (uint8_t)EMAC_REGS__NETWORK_CONTROL__TX_LPI_EN__READ(
                CPS_UncachedRead32(&(pD->regs->network_control)));
    }
    return (status);
}

uint32_t emacGetLpiStats(CEDI_PrivateData *pD, CEDI_LpiStats *lpiStats)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (lpiStats==NULL)) {
        status = EINVAL;
    } else {
        lpiStats->rxLpiTrans = (uint16_t)EMAC_REGS__RX_LPI__COUNT__READ(
                CPS_UncachedRead32(&(pD->regs->rx_lpi)));
        lpiStats->rxLpiTime = EMAC_REGS__RX_LPI_TIME__LPI_TIME__READ(
                CPS_UncachedRead32(&(pD->regs->rx_lpi_time)));
        lpiStats->txLpiTrans = (uint16_t)EMAC_REGS__TX_LPI__COUNT__READ(
                CPS_UncachedRead32(&(pD->regs->tx_lpi)));
        lpiStats->txLpiTime = EMAC_REGS__TX_LPI_TIME__LPI_TIME__READ(
                CPS_UncachedRead32(&(pD->regs->tx_lpi_time)));
    }
    return (status);
}

/**************************** Design Config **********************************/

uint32_t emacGetDesignConfig(const CEDI_PrivateData *pD, CEDI_DesignCfg *hwCfg)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (hwCfg==NULL)) {
        status = EINVAL;
    } else {
        /* Copy h/w config into user-supplied struct */
        *hwCfg = pD->hwCfg;
    }
    return (status);
}

/**************************** Debug Functionality ****************************/

uint32_t emacSetWriteStatsEnable(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->hwCfg.no_stats) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__STATS_WRITE_EN__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONTROL__STATS_WRITE_EN__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
    return (status);
}

uint32_t emacGetWriteStatsEnable(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->hwCfg.no_stats) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        *enable = (uint8_t)EMAC_REGS__NETWORK_CONTROL__STATS_WRITE_EN__READ(reg);
    }
    return (status);
}

uint32_t emacIncStatsRegs(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    uint32_t reg;

    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->hwCfg.no_stats) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__INC_ALL_STATS_REGS__SET(reg);
        CPS_UncachedWrite32(&(pD->regs->network_control), reg);
    }
    return (status);
}

void emacSetRxBackPressure(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t ncr;
    if ((pD!=NULL) && (enable <=1U)) {
        ncr = CPS_UncachedRead32(&(pD->regs->network_control));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONTROL__BACK_PRESSURE__SET(ncr);
        } else {
            EMAC_REGS__NETWORK_CONTROL__BACK_PRESSURE__CLR(ncr);
        }
        CPS_UncachedWrite32(&(pD->regs->network_control), ncr);
    }
}

uint32_t emacGetRxBackPressure(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t)(EMAC_REGS__NETWORK_CONTROL__BACK_PRESSURE__READ(
                CPS_UncachedRead32(&(pD->regs->network_control))));
    }

    return (status);
}

uint32_t emacSetCollisionTest(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->hwCfg.no_pcs) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setCollisionTest can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pcs_control));
        if (0U != enable) {
            EMAC_REGS__PCS_CONTROL__COLLISION_TEST__SET(reg);
        } else {
            EMAC_REGS__PCS_CONTROL__COLLISION_TEST__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->pcs_control), reg);
    }
    return (status);
}

uint32_t emacGetCollisionTest(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if ((pD->hwCfg.no_pcs != 0U) || (enable==NULL)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getCollisionTest can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->pcs_control));
        *enable = (uint8_t)(EMAC_REGS__PCS_CONTROL__COLLISION_TEST__READ(reg));
    }
    return (status);
}

void emacSetRetryTest(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t reg;
    if ((pD!=NULL) && (enable <=1U)) {
        reg = CPS_UncachedRead32(&(pD->regs->network_config));
        if (0U != enable) {
            EMAC_REGS__NETWORK_CONFIG__RETRY_TEST__SET(reg);
        } else {
            EMAC_REGS__NETWORK_CONFIG__RETRY_TEST__CLR(reg);
        }
        CPS_UncachedWrite32(&(pD->regs->network_config), reg);
    }
}

uint32_t emacGetRetryTest(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (enable==NULL)) {
        status = EINVAL;
    } else {
        *enable= (uint8_t) (EMAC_REGS__NETWORK_CONFIG__RETRY_TEST__READ(
                CPS_UncachedRead32(&(pD->regs->network_config))));
    }

    return (status);
}

uint32_t emacWriteUserOutputs(CEDI_PrivateData *pD, uint16_t outVal)
{
    uint32_t status = 0U;
    uint32_t tmp;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.user_io) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: writeUserOutputs can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        tmp = 0U;
        EMAC_REGS__USER_IO_REGISTER__USER_PROGRAMMABLE_OUTPUTS__MODIFY(
                tmp, outVal);
        CPS_UncachedWrite32(&(pD->regs->user_io_register), tmp);
    }
    return (status);
}

uint32_t emacReadUserOutputs(CEDI_PrivateData *pD, uint16_t *outVal)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (outVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.user_io) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: readUserOutputs can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->user_io_register));
        *outVal = (uint16_t) EMAC_REGS__USER_IO_REGISTER__USER_PROGRAMMABLE_OUTPUTS__READ(reg);
    }
    return (status);
}

uint32_t emacSetUserOutPin(CEDI_PrivateData *pD, uint8_t pin, uint8_t state)
{
    uint32_t status = 0U;
    uint32_t reg, val;
    if (pD==NULL) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.user_io) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (pin>=pD->hwCfg.user_out_width) {
            status = EINVAL;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setUserOutPin can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->user_io_register));
        val = EMAC_REGS__USER_IO_REGISTER__USER_PROGRAMMABLE_OUTPUTS__READ(reg);
        if(pin < 32U) {
            if (0U != state) {
                val |= (1U<<pin);
            }
            else {
                val &= ~(1U<<pin);
            }
        }
        EMAC_REGS__USER_IO_REGISTER__USER_PROGRAMMABLE_OUTPUTS__MODIFY(
                reg, val);
        CPS_UncachedWrite32(&(pD->regs->user_io_register), reg);
    }
    return (status);
}

uint32_t emacReadUserInputs(CEDI_PrivateData *pD, uint16_t *inVal)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD==NULL) || (inVal==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.user_io) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: readUserInputs can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->user_io_register));
        *inVal =(uint16_t)(EMAC_REGS__USER_IO_REGISTER__USER_PROGRAMMABLE_INPUTS__READ(reg));
    }
    return (status);
}

uint32_t emacGetUserInPin(CEDI_PrivateData *pD, uint8_t pin, uint8_t *state)
{
    uint32_t status = 0U;
    uint32_t reg, val;
    if ((pD==NULL) || (state==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U==pD->hwCfg.user_io) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        if (pin>=pD->hwCfg.user_in_width) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->user_io_register));
        val = EMAC_REGS__USER_IO_REGISTER__USER_PROGRAMMABLE_INPUTS__READ(reg);
        if (pin < 32) {
            *state = (0U != (val & (1U<<pin)))?1U:0U;
        } else {
            status = EINVAL;
        }
    }

    return (status);
}


/* enable/disable reporting bad FCS inside RX descriptor  */
uint32_t
emacSetReportingBadFCS(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t regTmp;
    if ((pD == NULL) || (enable > 1U)) {
        status = EINVAL;
    }
#ifdef EMAC_REGS__DMA_CONFIG__CRC_ERROR_REPORT__READ
    if (0U == status) {
        if (0U == IsGem1p09(pD)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        regTmp = CPS_UncachedRead32(&(pD->regs->dma_config));
        EMAC_REGS__DMA_CONFIG__CRC_ERROR_REPORT__MODIFY(regTmp, enable);
        CPS_UncachedWrite32(&(pD->regs->dma_config), regTmp);
    }

#else
    if (0U == status) {
        status = ENOTSUP;
    }
#endif
    return (status);
}

/* get state(enabled/disabled) of reporting bad FCS inside RX descriptor  */
uint32_t
emacGetReportingBadFCS(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    uint32_t regTmp;
    if ((pD == NULL) || (enable == NULL)) {
        status = EINVAL;
    }

#ifdef EMAC_REGS__DMA_CONFIG__CRC_ERROR_REPORT__READ
    if (0U == status) {
        if (0U == IsGem1p09(pD)) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        regTmp = CPS_UncachedRead32(&(pD->regs->dma_config));
        *enable = (uint8_t) (EMAC_REGS__DMA_CONFIG__CRC_ERROR_REPORT__READ(regTmp));
    }
#else
    if (0U == status) {
        status = ENOTSUP;
    }
#endif
    return (status);
}

/* enable/disable single step update correction field of PTP protocol  */
uint32_t
emacSetPtpSingleStep(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t regTmp;
    if ((pD == NULL) || (enable > 1U)) {
        status = EINVAL;
    }

#ifdef EMAC_REGS__NETWORK_CONTROL__OSS_CORRECTION_FIELD__MODIFY
    if (0U == status) {
        if (0U == IsGem1p09(pD)) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        regTmp = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__OSS_CORRECTION_FIELD__MODIFY(regTmp, enable);
        CPS_UncachedWrite32(&(pD->regs->network_control), regTmp);
    }
#else
    if (0U == status) {
        status = ENOTSUP;
    }
#endif
    return (status);
}

/* get state (enable/disable) of single step update
 * correction field of PTP protocol  */
uint32_t
emacGetPtpSingleStep(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    uint32_t regTmp;
    if ((pD == NULL) || (enable == NULL)) {
        status = EINVAL;
    }

#ifdef EMAC_REGS__NETWORK_CONTROL__OSS_CORRECTION_FIELD__MODIFY
    if (0U == status) {
        if (0U == IsGem1p09(pD)) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        regTmp = CPS_UncachedRead32(&(pD->regs->network_control));
        *enable = (uint8_t)EMAC_REGS__NETWORK_CONTROL__OSS_CORRECTION_FIELD__READ(regTmp);
    }
#else
    if (0U == status) {
        status = ENOTSUP;
    }
#endif
    return (status);
}

/* enable/disable feature alowing execution MII operation on RGMII interface */
uint32_t
emacSetMiiOnRgmii(CEDI_PrivateData *pD, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t regTmp;
    if ((pD == NULL) || (enable > 1U)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: setMiiOnRgmii can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

#ifdef EMAC_REGS__NETWORK_CONTROL__SEL_MII_ON_RGMII__MODIFY
    if (0U == status) {
        if (0U == IsGem1p09(pD)) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        regTmp = CPS_UncachedRead32(&(pD->regs->network_control));
        EMAC_REGS__NETWORK_CONTROL__SEL_MII_ON_RGMII__MODIFY(regTmp, enable);
        CPS_UncachedWrite32(&(pD->regs->network_control), regTmp);
    }
#else
    if (0U == status) {
        status = ENOTSUP;
    }
#endif
    return (status);
}

/* get state (enabled/disabled) feature alowing
 * execution MII operation on RGMII interface  */
uint32_t
emacGetMiiOnRgmii(CEDI_PrivateData *pD, uint8_t *enable)
{
    uint32_t status = 0U;
    uint32_t regTmp;
    if ((pD == NULL) || (enable == NULL)) {
        status = EINVAL;
    }

#ifdef EMAC_REGS__NETWORK_CONTROL__SEL_MII_ON_RGMII__MODIFY
    if (0U == status) {
        if (0U == IsGem1p09(pD)) {
            status = ENOTSUP;
        }
    }
    if (0U == status) {
        regTmp = CPS_UncachedRead32(&(pD->regs->network_control));
    *enable = (uint8_t)EMAC_REGS__NETWORK_CONTROL__SEL_MII_ON_RGMII__READ(regTmp);
    }
#else
    if (0U == status) {
        status = ENOTSUP;
    }
#endif
    return (status);
}

static uint32_t emacGetLinkFaultIndication(CEDI_PrivateData *pD, CEDI_LinkFaultIndication *linkFault);

static uint32_t emacGetLinkFaultIndication(CEDI_PrivateData *pD, CEDI_LinkFaultIndication *linkFault)
{
    uint32_t status = 0U;
    uint32_t network_status_reg;

    if ((pD == NULL) || (linkFault == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == IsGem1p12(pD)) {
            status = (uint32_t)ENOTSUP;
        }
    }

    if (0U == status)
    {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType) {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                    "Error: getLinkFaultIndication can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }

    if (0U == status) {
        network_status_reg = CPS_UncachedRead32(&(pD->regs->network_status));
        *linkFault = (CEDI_LinkFaultIndication)EMAC_REGS__NETWORK_STATUS__LINK_FAULT_INDICATION__READ(network_status_reg);
    }

    return (status);
}

static uint32_t emacSetFrameEliminationTagSize(CEDI_PrivateData *pD, CEDI_RedundancyTagSize tagSize);

static uint32_t emacSetFrameEliminationTagSize(CEDI_PrivateData *pD, CEDI_RedundancyTagSize tagSize)
{
    uint32_t status = 0U;
    uint32_t frer_reg;

    if ((pD == NULL) ||
        ((tagSize != CEDI_REDUNDANCY_TAG_SIZE_4) && (tagSize != CEDI_REDUNDANCY_TAG_SIZE_6))) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == IsGem1p12(pD)) {
            status = ((uint8_t)tagSize == (uint8_t)CEDI_REDUNDANCY_TAG_SIZE_4) ? 0U : (uint32_t)ENOTSUP;
        } else {
            frer_reg = CPS_UncachedRead32(&(pD->regs->frer_red_tag));
            EMAC_REGS__FRER_RED_TAG__SIX_BYTE_TAG__MODIFY(frer_reg, (uint32_t)tagSize);
            CPS_UncachedWrite32(&(pD->regs->frer_red_tag), frer_reg);
        }
    }

    return (status);
}

static uint32_t emacGetFrameEliminationTagSize(CEDI_PrivateData *pD, CEDI_RedundancyTagSize *tagSize);

static uint32_t emacGetFrameEliminationTagSize(CEDI_PrivateData *pD, CEDI_RedundancyTagSize *tagSize)
{
    uint32_t status = 0U;
    uint32_t frer_reg;

    if ((pD == NULL) || (tagSize == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        frer_reg = CPS_UncachedRead32(&(pD->regs->frer_red_tag));
        *tagSize = EMAC_REGS__FRER_RED_TAG__SIX_BYTE_TAG__READ(frer_reg);
    }

    return (status);
}

uint32_t emacSetFrameEliminationEnable(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD == NULL) || (enable > 1U)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (queueNum >= pD->rxQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of active RX queues\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (queueNum >= pD->hwCfg.num_cb_streams) {
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of CB streams\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        pD->frerEnabled[queueNum] = enable;

        regPtr = frerControlRegA[queueNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);
        EMAC_REGS__FRER_CONTROL_A__EN_ELIMINATION__MODIFY(reg, enable);
        CPS_UncachedWrite32(regPtr, reg);
    }

    return (status);
}

uint32_t emacGetFrameEliminationEnable(const CEDI_PrivateData *pD, uint8_t queueNum, uint8_t *enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD == NULL) || (enable == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (queueNum >= pD->rxQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of active RX queues\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (queueNum >= pD->hwCfg.num_cb_streams){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of CB streams\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        regPtr = frerControlRegA[queueNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);
        *enable = (uint8_t)EMAC_REGS__FRER_CONTROL_A__EN_ELIMINATION__READ(reg);
    }

    return (status);
}

uint32_t emacSetFrameEliminationSeqRecRstTmrEnable(const CEDI_PrivateData *pD, uint8_t queueNum, uint8_t enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD == NULL) || (enable > 1U)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (queueNum >= pD->rxQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of active RX queues\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (queueNum >= pD->hwCfg.num_cb_streams){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of CB streams\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        regPtr = frerControlRegA[queueNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);
        EMAC_REGS__FRER_CONTROL_A__EN_SEQRECRST_TIMER__MODIFY(reg, enable);
        CPS_UncachedWrite32(regPtr, reg);
    }

    return (status);
}

uint32_t emacGetFrameEliminationSeqRecRstTmrEnable(const CEDI_PrivateData *pD, uint8_t queueNum, uint8_t *enable)
{
    uint32_t status = 0U;
    uint32_t reg;
    volatile uint32_t *regPtr = NULL;

    if ((pD == NULL) || (enable == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (queueNum >= pD->rxQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of active RX queues\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (queueNum >= pD->hwCfg.num_cb_streams){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of CB streams\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        regPtr = frerControlRegA[queueNum];
        addRegBase(pD, &regPtr);
        reg = CPS_UncachedRead32(regPtr);
        *enable = (uint8_t) (EMAC_REGS__FRER_CONTROL_A__EN_SEQRECRST_TIMER__READ(reg));
    }

    return (status);
}

uint32_t emacSetFrameEliminationConfig(const CEDI_PrivateData *pD, uint8_t queueNum, const CEDI_FrameEliminationConfig* fec)
{
    uint32_t status = 0U;
    uint32_t reg;
    volatile uint32_t *regAPtr = NULL;
    volatile uint32_t *regBPtr = NULL;

    if ((pD == NULL) || (fec == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (queueNum >= pD->rxQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of active RX queues\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (queueNum >= pD->hwCfg.num_cb_streams){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of CB streams\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
    /* Configuration values are static - not to be modified, if elimination is enabled */
        if (0U != pD->frerEnabled[queueNum]) {
            status = EINVAL;
        }

        if ((fec->enVectAlg > 1U) || (fec->seqNumIdentification > 1U)) {
            status = EINVAL;
        }

        if ((fec->offsetValue > 511U) || (fec->smemberStream1 > 15U) || (fec->smemberStream2 > 15U)) {
            status = EINVAL;
        }

        if ((fec->seqNumLength > 16U) || (fec->seqRecWindow > 63U)) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        regAPtr = frerControlRegA[queueNum];
        addRegBase(pD, &regAPtr);

        regBPtr = frerControlRegB[queueNum];
        addRegBase(pD, &regBPtr);

        reg = CPS_UncachedRead32(regAPtr);
        EMAC_REGS__FRER_CONTROL_A__EN_VECTOR_REC_ALG__MODIFY(reg, !!fec->enVectAlg);
            setFrerRedundancyTag(fec, &reg);
        EMAC_REGS__FRER_CONTROL_A__OFFSET_VALUE__MODIFY(reg, fec->offsetValue);
        EMAC_REGS__FRER_CONTROL_A__MEMBER_STREAM_1__MODIFY(reg, fec->smemberStream1);
        EMAC_REGS__FRER_CONTROL_A__MEMBER_STREAM_2__MODIFY(reg, fec->smemberStream2);
            CPS_UncachedWrite32(regAPtr, reg);
        reg = CPS_UncachedRead32(regBPtr);
        EMAC_REGS__FRER_CONTROL_B__SEQ_NUM_LENGTH__MODIFY(reg, fec->seqNumLength);
        EMAC_REGS__FRER_CONTROL_B__SEQ_REC_WINDOW__MODIFY(reg, fec->seqRecWindow);
            CPS_UncachedWrite32(regBPtr, reg);
    }

    return (status);
}

uint32_t emacGetFrameEliminationConfig(const CEDI_PrivateData *pD, uint8_t queueNum, CEDI_FrameEliminationConfig* fec)
{
    uint32_t status = 0U;
    uint32_t reg;
    volatile uint32_t *regAPtr = NULL;
    volatile uint32_t *regBPtr = NULL;

    if ((pD == NULL) || (fec == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (queueNum >= pD->rxQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of active RX queues\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (queueNum >= pD->hwCfg.num_cb_streams){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of CB streams\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        regAPtr = frerControlRegA[queueNum];
        addRegBase(pD, &regAPtr);

        regBPtr = frerControlRegB[queueNum];
        addRegBase(pD, &regBPtr);

        reg = CPS_UncachedRead32(regAPtr);
        fec->enVectAlg = (uint8_t)EMAC_REGS__FRER_CONTROL_A__EN_VECTOR_REC_ALG__READ(reg);
        getFrerRedundancyTag(fec, reg);
        fec->offsetValue = (uint16_t)EMAC_REGS__FRER_CONTROL_A__OFFSET_VALUE__READ(reg);
        fec->smemberStream1 = (uint8_t)EMAC_REGS__FRER_CONTROL_A__MEMBER_STREAM_1__READ(reg);
        fec->smemberStream2 = (uint8_t)EMAC_REGS__FRER_CONTROL_A__MEMBER_STREAM_2__READ(reg);
        reg = CPS_UncachedRead32(regBPtr);
        fec->seqNumLength = (uint8_t)EMAC_REGS__FRER_CONTROL_B__SEQ_NUM_LENGTH__READ(reg);
        fec->seqRecWindow = (uint8_t)EMAC_REGS__FRER_CONTROL_B__SEQ_REC_WINDOW__READ(reg);
    }

    return (status);
}

uint32_t emacSetFrameEliminationTagConfig(CEDI_PrivateData *pD, const CEDI_FrameEliminationTagConfig* fetc)
{
    uint32_t status = 0U;
    uint32_t reg;

    if ((pD == NULL) || (fetc == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        if (fetc->enStripRedTag > 1) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->frer_red_tag));
        EMAC_REGS__FRER_RED_TAG__REDUNDANCY_TAG__MODIFY(reg, fetc->redundancyTag);
        EMAC_REGS__FRER_RED_TAG__STRIP_R_TAG__MODIFY(reg, !!fetc->enStripRedTag);
        CPS_UncachedWrite32(&(pD->regs->frer_red_tag), reg);
    }

    return (status);
}

uint32_t emacGetFrameEliminationTagConfig(CEDI_PrivateData *pD, CEDI_FrameEliminationTagConfig* fetc)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD == NULL) || (fetc == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->frer_red_tag));
        fetc->redundancyTag = (uint16_t)EMAC_REGS__FRER_RED_TAG__REDUNDANCY_TAG__READ(reg);
        fetc->enStripRedTag = (uint8_t) EMAC_REGS__FRER_RED_TAG__STRIP_R_TAG__READ(reg);
    }

    return (status);
}

uint32_t emacSetFrameEliminationTimoutConfig(CEDI_PrivateData *pD, uint16_t timeout)
{
    uint32_t status = 0U;
    uint32_t reg;
    if (pD == NULL) {
        status = EINVAL;
    }

    if (0U == status) {
        if (!(pD->hwCfg.num_cb_streams)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->frer_timeout));
        EMAC_REGS__FRER_TIMEOUT__TIMEOUT__MODIFY(reg, timeout);
        CPS_UncachedWrite32(&(pD->regs->frer_red_tag), reg);
    }

    return (status);
}

uint32_t emacGetFrameEliminationStats(const CEDI_PrivateData *pD, uint8_t queueNum, CEDI_FrameEliminationStats* stats)
{
    uint32_t status = 0U;
    uint32_t reg;
    volatile uint32_t *regAPtr = NULL;
    volatile uint32_t *regBPtr = NULL;

    volatile uint32_t* const frerStatisticsRegA[16U] = {
        CEDI_RegOff(frer_statistics_1_a),
        CEDI_RegOff(frer_statistics_2_a),
        CEDI_RegOff(frer_statistics_3_a),
        CEDI_RegOff(frer_statistics_4_a),
        CEDI_RegOff(frer_statistics_5_a),
        CEDI_RegOff(frer_statistics_6_a),
        CEDI_RegOff(frer_statistics_7_a),
        CEDI_RegOff(frer_statistics_8_a),
        CEDI_RegOff(frer_statistics_9_a),
        CEDI_RegOff(frer_statistics_10_a),
        CEDI_RegOff(frer_statistics_11_a),
        CEDI_RegOff(frer_statistics_12_a),
        CEDI_RegOff(frer_statistics_13_a),
        CEDI_RegOff(frer_statistics_14_a),
        CEDI_RegOff(frer_statistics_15_a),
        CEDI_RegOff(frer_statistics_16_a)
    };

    volatile uint32_t* const frerStatisticsRegB[16U] = {
        CEDI_RegOff(frer_statistics_1_b),
        CEDI_RegOff(frer_statistics_2_b),
        CEDI_RegOff(frer_statistics_3_b),
        CEDI_RegOff(frer_statistics_4_b),
        CEDI_RegOff(frer_statistics_5_b),
        CEDI_RegOff(frer_statistics_6_b),
        CEDI_RegOff(frer_statistics_7_b),
        CEDI_RegOff(frer_statistics_8_b),
        CEDI_RegOff(frer_statistics_9_b),
        CEDI_RegOff(frer_statistics_10_b),
        CEDI_RegOff(frer_statistics_11_b),
        CEDI_RegOff(frer_statistics_12_b),
        CEDI_RegOff(frer_statistics_13_b),
        CEDI_RegOff(frer_statistics_14_b),
        CEDI_RegOff(frer_statistics_15_b),
        CEDI_RegOff(frer_statistics_16_b)
    };

    if ((pD == NULL) || (stats == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (queueNum >= pD->rxQs){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of active RX queues\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U == (pD->hwCfg.num_cb_streams)) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (queueNum >= pD->hwCfg.num_cb_streams){
            vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
                "Error: Queue number is bigger than number of CB streams\n");
            status = EINVAL;
        }
    }

    if (0U == status) {
        regAPtr = frerStatisticsRegA[queueNum];
        addRegBase(pD, &regAPtr);

        regBPtr = frerStatisticsRegB[queueNum];
        addRegBase(pD, &regBPtr);

        reg = CPS_UncachedRead32(regAPtr);
        stats->latentErrors = (uint16_t) EMAC_REGS__FRER_STATISTICS_A__LATENT_ERRORS__READ(reg);
        stats->vecRecRogue = (uint16_t) EMAC_REGS__FRER_STATISTICS_A__VEC_REC_ROGUE__READ(reg);
        reg = CPS_UncachedRead32(regBPtr);
        stats->outOfOreder = (uint16_t) EMAC_REGS__FRER_STATISTICS_B__OUT_OF_ORDER__READ(reg);
        stats->seqRstCount = (uint16_t) EMAC_REGS__FRER_STATISTICS_B__SEQRST_COUNT__READ(reg);
    }

    return (status);
}

uint32_t emacGetEmac(CEDI_PrivateData *pD, CEDI_PrivateData **emacPrivateData)
{
    uint32_t status = 0U;
    if ((pD == NULL) || (emacPrivateData == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->cfg.incExpressTraffic)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        switch(pD->macType){
            case CEDI_MAC_TYPE_EMAC:
                *emacPrivateData = pD;
                break;
            case CEDI_MAC_TYPE_PMAC:
                *emacPrivateData = pD->otherMac;
                break;
            default:
                *emacPrivateData = NULL;
                status = ENOTSUP;
                break;
        }
    }
    return (status);

}

uint32_t emacGetPmac(CEDI_PrivateData *pD, CEDI_PrivateData **pmacPrivateData)
{
    uint32_t status = 0U;
    if ((pD == NULL) || (pmacPrivateData == NULL)) {
        status = EINVAL;
    } else {
        switch(pD->macType) {
            case CEDI_MAC_TYPE_EMAC:
                *pmacPrivateData = pD->otherMac;
                break;
            case CEDI_MAC_TYPE_PMAC:
                *pmacPrivateData = pD;
                break;
            default:
                *pmacPrivateData = NULL;
                status = ENOTSUP;
                break;
        }
    }
    return (status);

}

uint32_t emacGetMacType(const CEDI_PrivateData *pD, CEDI_MacType* macType)
{
    uint32_t status = 0U;
    if ((pD == NULL) || (macType == NULL)) {
        status = EINVAL;
    } else {
        *macType = pD->macType;
    }

    return (status);
}

uint32_t emacSetPreemptionConfig(CEDI_PrivateData *pD, const CEDI_PreemptionConfig* preCfg)
{
    uint32_t status = 0U;
    uint32_t reg;
    uint8_t current_ver_enable;
    uint8_t current_add_frag_size;
    uint8_t double_write_required = 0U;
    struct emac_regs *mmslRegs;

    if ((pD == NULL) || (preCfg == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if ((preCfg->routeRxToPmac > 1U) || (preCfg->enPreeption > 1U) || (preCfg->enVerify > 1U)) {
            status = EINVAL;
        }
        if (preCfg->addFragSize > 3U) {
            status = EINVAL;
        }
    }

    if (0U == status) {
        if (0U == (pD->cfg.incExpressTraffic)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        mmslRegs = getMmslRegs(pD);
        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_control));

        current_ver_enable = !(EMAC_REGS__MMSL_CONTROL__VERIFY_DISABLE__READ(reg));
        current_add_frag_size = (uint8_t) EMAC_REGS__MMSL_CONTROL__ADD_FRAG_SIZE__READ(reg);

        if (0U != preCfg->enPreeption)
        {
            if ((current_ver_enable != preCfg->enVerify) || (current_add_frag_size != preCfg->addFragSize)) {
            double_write_required = 1U;
            }
        }

        EMAC_REGS__MMSL_CONTROL__ROUTE_RX_TO_PMAC__MODIFY(reg, preCfg->routeRxToPmac);
        EMAC_REGS__MMSL_CONTROL__PRE_ENABLE__MODIFY(reg, !!preCfg->enPreeption);
        EMAC_REGS__MMSL_CONTROL__VERIFY_DISABLE__MODIFY(reg, !preCfg->enVerify);
        EMAC_REGS__MMSL_CONTROL__ADD_FRAG_SIZE__MODIFY(reg, preCfg->addFragSize);

        if (0U != double_write_required)
        {
            EMAC_REGS__MMSL_CONTROL__PRE_ENABLE__CLR(reg);
            CPS_UncachedWrite32(&(mmslRegs->mmsl_control), reg);
            EMAC_REGS__MMSL_CONTROL__PRE_ENABLE__SET(reg);
        }
        CPS_UncachedWrite32(&(mmslRegs->mmsl_control), reg);
    }

    return (status);
}

uint32_t emacGetPreemptionConfig(CEDI_PrivateData *pD, CEDI_PreemptionConfig* preCfg)
{
    uint32_t status = 0U;
    uint32_t reg;
    struct emac_regs *mmslRegs;

    if ((pD == NULL) || (preCfg == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->cfg.incExpressTraffic)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        mmslRegs = getMmslRegs(pD);
        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_control));
        preCfg->routeRxToPmac = (uint8_t) EMAC_REGS__MMSL_CONTROL__ROUTE_RX_TO_PMAC__READ(reg);
        preCfg->enPreeption = (uint8_t) EMAC_REGS__MMSL_CONTROL__PRE_ENABLE__READ(reg);
        preCfg->enVerify = (uint8_t) (!(EMAC_REGS__MMSL_CONTROL__VERIFY_DISABLE__READ(reg)));
        preCfg->addFragSize = EMAC_REGS__MMSL_CONTROL__ADD_FRAG_SIZE__READ(reg);
    }
    return (status);

}

static uint32_t emacPreemptionRestartVerification(CEDI_PrivateData *pD)
{
    uint32_t status = 0U;
    uint32_t reg;
    struct emac_regs *mmslRegs;

    if (pD == NULL) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == pD->cfg.incExpressTraffic) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        mmslRegs = getMmslRegs(pD);
        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_control));
        EMAC_REGS__MMSL_CONTROL__RESTART_VER__SET(reg);
        CPS_UncachedWrite32(&(mmslRegs->mmsl_control), reg);
    }
    return (status);
}

static uint32_t emacSetMmslEventEnable(CEDI_PrivateData *pD, uint32_t events, uint8_t enable)
{
    uint32_t status = 0U;
    struct emac_regs *mmslRegs;

    if ((pD==NULL) || (enable>1U)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->cfg.incExpressTraffic)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        mmslRegs = getMmslRegs(pD);
        if (0U != enable) {
            CPS_UncachedWrite32(&(mmslRegs->mmsl_int_enable), events);
        } else {
            CPS_UncachedWrite32(&(mmslRegs->mmsl_int_disable), events);
        }
    }
    return (status);

}

static uint32_t emacGetMmslEventEnable(CEDI_PrivateData *pD, uint32_t* events)
{
    uint32_t status = 0U;
    uint32_t reg;
    struct emac_regs *mmslRegs;
    /* if additional registers are added, following macro will change
     * and code will no longer compile (which is desired in this case).
     */
    uint32_t mask = ~EMAC_REGS__MMSL_INT_MASK__RESERVED_31_6__MASK;
    if ((pD == NULL) || (events == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->cfg.incExpressTraffic)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        mmslRegs = getMmslRegs(pD);
        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_int_mask));
        *events = (~reg) & mask;
    }
    return (status);
}

static uint32_t emacReadMmslStats(CEDI_PrivateData *pD, CEDI_MmslStats* mmslStats)
{
    uint32_t status = 0U;
    uint32_t reg;
    struct emac_regs *mmslRegs;
    if ((pD == NULL) || (mmslStats == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->cfg.incExpressTraffic)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
    mmslRegs = getMmslRegs(pD);
        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_err_stats));
        mmslStats->assErrorCount = (uint8_t) EMAC_REGS__MMSL_ERR_STATS__ASS_ERROR_COUNT__READ(reg);
        mmslStats->smdErrorCount = (uint8_t)EMAC_REGS__MMSL_ERR_STATS__SMD_ERR_COUNT__READ(reg);

        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_ass_ok_count));
        mmslStats->assOkCount = EMAC_REGS__MMSL_ASS_OK_COUNT__ASS_OK_COUNT__READ(reg);

        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_frag_count_rx));
        mmslStats->fragCountRx = EMAC_REGS__MMSL_FRAG_COUNT_RX__FRAG_COUNT_RX__READ(reg);

        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_frag_count_tx));
        mmslStats->fragCountTx = EMAC_REGS__MMSL_FRAG_COUNT_TX__FRAG_COUNT_TX__READ(reg);
    }
    return (status);
}

static uint32_t emacReadMmslStatus(CEDI_PrivateData *pD, CEDI_MmslStatus* mmslStatus)
{
    uint32_t status = 0U;
    uint32_t reg;
    struct emac_regs *mmslRegs;
    if ((pD == NULL) || (mmslStatus == NULL)) {
        status = EINVAL;
    }

    if (0U == status) {
        if (0U == (pD->cfg.incExpressTraffic)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        mmslRegs = getMmslRegs(pD);
        reg = CPS_UncachedRead32(&(mmslRegs->mmsl_status));
        mmslStatus->preActive = (uint8_t) EMAC_REGS__MMSL_STATUS__PRE_ACTIVE__READ(reg);
        mmslStatus->respondStatus = EMAC_REGS__MMSL_STATUS__RESPOND_STATUS__READ(reg);
        mmslStatus->verifyStatus = EMAC_REGS__MMSL_STATUS__VERIFY_STATUS__READ(reg);

        mmslStatus->events = 0U;
        if (0U != EMAC_REGS__MMSL_STATUS__RCV_R_ERROR__READ(reg)) {
            mmslStatus->events |= CEDI_MMSL_EV_RCV_R_ERR;
        }
        if (0U != EMAC_REGS__MMSL_STATUS__RCV_V_ERROR__READ(reg)) {
            mmslStatus->events |= CEDI_MMSL_EV_RCV_V_ERR;
        }
        if (0U != EMAC_REGS__MMSL_STATUS__SMDS_ERROR__READ(reg)) {
            mmslStatus->events |= CEDI_MMSL_EV_SMDS_ERR;
        }
        if (0U != EMAC_REGS__MMSL_STATUS__SMDC_ERROR__READ(reg)) {
            mmslStatus->events |= CEDI_MMSL_EV_SMDC_ERR;
        }
        if (0U != EMAC_REGS__MMSL_STATUS__FRER_COUNT_ERR__READ(reg)) {
            mmslStatus->events |= CEDI_MMSL_EV_FR_COUNT_ERR;
        }
        if (0U != EMAC_REGS__MMSL_STATUS__SMD_ERROR__READ(reg)) {
            mmslStatus->events |= CEDI_MMSL_EV_SMD_ERR;
        }
    }
    return (status);
}


static uint32_t emacGetMdioInState(CEDI_PrivateData *pD, uint8_t *state)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (state==NULL)) {
        status = EINVAL;
    }
    if (0U == status) {
        if (0U != pD->cfg.incExpressTraffic) {
            if (CEDI_MAC_TYPE_EMAC == pD->macType)
            {
                vDbgMsg(DBG_GEN_MSG, 5, "%s\n",
                        "Error: getMdioInState can not be called for express MAC.");
                status = EINVAL;
            }
        }
    }
    if (0U == status) {
        *state = (uint8_t) (EMAC_REGS__NETWORK_STATUS__MDIO_IN__READ(
                CPS_UncachedRead32(&(pD->regs->network_status))));
    }

    return (status);
}

static uint32_t emacReadReg(const CEDI_PrivateData *pD, uint32_t offs, uint32_t *data)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (data==NULL) || (offs>=sizeof(struct emac_regs))) {
        status = EINVAL;
    } else {
        *data = CPS_UncachedRead32(uintptrToPtrU32(pD->cfg.regBase + offs));
    }
    return (status);
}

static uint32_t emacWriteReg(const CEDI_PrivateData *pD, uint32_t offs, uint32_t data)
{
    uint32_t status = 0U;
    if ((pD==NULL) || (offs>=sizeof(struct emac_regs))) {
        status = EINVAL;
    } else {
        CPS_UncachedWrite32(uintptrToPtrU32(pD->cfg.regBase + offs), data);
    }
    return (status);
}

uint32_t emacSetIntrptModerateThreshold(CEDI_PrivateData* pD,
					uint8_t txIntFrameThreshold,
					uint8_t rxIntFrameThreshold)
{
    uint32_t status = 0U;
    uint32_t reg;
    if (pD == NULL)
	status = EINVAL;

       if (0U == status) {
        if (0U == isIntrptModerateThresholdSupported(pD)) {
            status = ENOTSUP;
        }
    }

    if (0U == status) {
        reg = CPS_UncachedRead32(&(pD->regs->int_moderation));
	/* first clear interrupt moderation */
        EMAC_REGS__INT_MODERATION__TX_INT_MOD_THRESH__MODIFY(reg, 0);
        EMAC_REGS__INT_MODERATION__RX_INT_MOD_THRESH__MODIFY(reg, 0);
        CPS_UncachedWrite32(&(pD->regs->int_moderation), reg);

        EMAC_REGS__INT_MODERATION__TX_INT_MOD_THRESH__MODIFY(reg, txIntFrameThreshold);
        EMAC_REGS__INT_MODERATION__RX_INT_MOD_THRESH__MODIFY(reg, rxIntFrameThreshold);
        CPS_UncachedWrite32(&(pD->regs->int_moderation), reg);
    }

    return status;
}

uint32_t emacGetIntrptModerateThreshold(CEDI_PrivateData* pD,
					uint8_t *txIntFrameThreshold,
					uint8_t *rxIntFrameThreshold)
{
    uint32_t status = 0U;
    uint32_t reg;
    if ((pD == NULL) || (txIntFrameThreshold == NULL)
	|| (rxIntFrameThreshold == NULL))
	status = EINVAL;

    if (0U == status) {
	if (0U == isIntrptModerateThresholdSupported(pD)) {
	    status = ENOTSUP;
	}
    }

    if (0U == status) {
	reg = CPS_UncachedRead32(&(pD->regs->int_moderation));
	*txIntFrameThreshold = EMAC_REGS__INT_MODERATION__TX_INT_MOD_THRESH__READ(reg);
	*rxIntFrameThreshold = EMAC_REGS__INT_MODERATION__RX_INT_MOD_THRESH__READ(reg);
    }

    return status;
}

uint32_t emacSetLockupConfig(CEDI_PrivateData* pD, const CEDI_LockupConfig* lockupCfg)
{
    uint32_t status = 0U;
    uint32_t reg = 0;
    if ((pD==NULL) || (lockupCfg==NULL))
	status = EINVAL;

    if (0U == status) {
	if ((lockupCfg->enLockupRecovery > 1) ||
	    (lockupCfg->enRxMacLockupMon > 1) ||
	    (lockupCfg->enRxDmaLockupMon > 1) ||
	    (lockupCfg->enTxMacLockupMon > 1) ||
	    (lockupCfg->enTxDmaLockupMon > 1) ||
	    (lockupCfg->dmaLockupTime > 0x7FF) ||
	    (lockupCfg->txLockupTime > 0x7FF))
	    status = EINVAL;
    }

    if (0U == status) {
	if (0 == pD->hwCfg.lockup_supported)
	    status = ENOTSUP;
    }

    if (0U == status) {
	EMAC_REGS__LOCKUP_CONFIG__DMA_LOCKUP_TIME__MODIFY(reg, lockupCfg->dmaLockupTime);
	EMAC_REGS__LOCKUP_CONFIG__PRESCALER_VALUE__MODIFY(reg, lockupCfg->prescaler);
	EMAC_REGS__LOCKUP_CONFIG__LOCKUP_RECOVERY_EN__MODIFY(reg, lockupCfg->enLockupRecovery);
	EMAC_REGS__LOCKUP_CONFIG__RX_MAC_LOCKUP_MON_EN__MODIFY(reg, lockupCfg->enRxMacLockupMon);
	EMAC_REGS__LOCKUP_CONFIG__RX_DMA_LOCKUP_MON_EN__MODIFY(reg, lockupCfg->enRxDmaLockupMon);
	EMAC_REGS__LOCKUP_CONFIG__TX_MAC_LOCKUP_MON_EN__MODIFY(reg, lockupCfg->enTxMacLockupMon);
	EMAC_REGS__LOCKUP_CONFIG__TX_DMA_LOCKUP_MON_EN__MODIFY(reg, lockupCfg->enTxDmaLockupMon);
	CPS_UncachedWrite32(&(pD->regs->lockup_config), reg);

	reg = 0;

	EMAC_REGS__MAC_LOCKUP_TIME__RX_MAC_LOCKUP_TIME__MODIFY(reg, lockupCfg->rxLockupTime);
	EMAC_REGS__MAC_LOCKUP_TIME__TX_MAC_LOCKUP_TIME__MODIFY(reg, lockupCfg->txLockupTime);
	CPS_UncachedWrite32(&(pD->regs->mac_lockup_time), reg);

	reg = lockupCfg->enTxDmaTimers & ~EMAC_REGS__LOCKUP_CONFIG3__RESERVED_31_16__MASK;
	CPS_UncachedWrite32(&(pD->regs->lockup_config3), reg);
    }

    return status;
}

uint32_t emacGetLockupConfig(CEDI_PrivateData* pD, CEDI_LockupConfig* lockupCfg)
{
    uint32_t status = 0U;
    uint32_t reg = 0;
    if ((pD==NULL) || (lockupCfg==NULL))
	status = EINVAL;

    if (0U == status) {
	if (0 == pD->hwCfg.lockup_supported)
	    status = ENOTSUP;
    }

    if (0U == status) {
	reg = CPS_UncachedRead32(&(pD->regs->lockup_config));
	lockupCfg->dmaLockupTime = EMAC_REGS__LOCKUP_CONFIG__DMA_LOCKUP_TIME__READ(reg);
	lockupCfg->prescaler = EMAC_REGS__LOCKUP_CONFIG__PRESCALER_VALUE__READ(reg);
	lockupCfg->enLockupRecovery = EMAC_REGS__LOCKUP_CONFIG__LOCKUP_RECOVERY_EN__READ(reg);
	lockupCfg->enRxMacLockupMon = EMAC_REGS__LOCKUP_CONFIG__RX_MAC_LOCKUP_MON_EN__READ(reg);
	lockupCfg->enRxDmaLockupMon = EMAC_REGS__LOCKUP_CONFIG__RX_DMA_LOCKUP_MON_EN__READ(reg);
	lockupCfg->enTxMacLockupMon = EMAC_REGS__LOCKUP_CONFIG__TX_MAC_LOCKUP_MON_EN__READ(reg);
	lockupCfg->enTxDmaLockupMon = EMAC_REGS__LOCKUP_CONFIG__TX_DMA_LOCKUP_MON_EN__READ(reg);

	reg = CPS_UncachedRead32(&(pD->regs->mac_lockup_time));
	lockupCfg->rxLockupTime = EMAC_REGS__MAC_LOCKUP_TIME__RX_MAC_LOCKUP_TIME__READ(reg);
	lockupCfg->txLockupTime = EMAC_REGS__MAC_LOCKUP_TIME__TX_MAC_LOCKUP_TIME__READ(reg);

	reg = CPS_UncachedRead32(&(pD->regs->lockup_config3));
	lockupCfg->enTxDmaTimers = reg & ~EMAC_REGS__LOCKUP_CONFIG3__RESERVED_31_16__MASK;
    }

    return status;
}

uint32_t emacSetAxiQosConfig(CEDI_PrivateData* pD, uint8_t queueNum, CEDI_AxiQosConfig* axiQosConfig)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t* const axiQosReg[4] = {
	CEDI_RegOff(axi_qos_cfg_0),
	CEDI_RegOff(axi_qos_cfg_1),
	CEDI_RegOff(axi_qos_cfg_2),
	CEDI_RegOff(axi_qos_cfg_3),
    };


    if ((pD==NULL) || (axiQosConfig==NULL))
	status = EINVAL;

    if (0U == status){
	if (queueNum > pD->cfg.txQs){
	    vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
		    "Error: Queue number is bigger than supported queue number\n");
	    status = EINVAL;
	}
    }

    if (0U == status){
	if (axiQosConfig->descriptorQos > 0xF)
	    status = EINVAL;
	if (axiQosConfig->dataQos > 0xF)
	    status = EINVAL;
    }

    if (0U == status){
	if (0U == IsGem1p11(pD))
	    status = ENOTSUP;
    }

    if (0U == status){
	volatile uint32_t *regPtr = NULL;

	regPtr = axiQosReg[queueNum >> 2];
	addRegBase(pD, &regPtr);
	reg = CPS_UncachedRead32(regPtr);


	if (queueNum  == 0){
	    EMAC_REGS__AXI_QOS_CFG_0__Q_0_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_0__Q_0_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}

	if (queueNum  == 1){
	    EMAC_REGS__AXI_QOS_CFG_0__Q_1_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_0__Q_1_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 2){
	    EMAC_REGS__AXI_QOS_CFG_0__Q_2_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_0__Q_2_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 3){
	    EMAC_REGS__AXI_QOS_CFG_0__Q_3_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_0__Q_3_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 4){
	    EMAC_REGS__AXI_QOS_CFG_1__Q_4_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_1__Q_4_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 5){
	    EMAC_REGS__AXI_QOS_CFG_1__Q_5_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_1__Q_5_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 6){
	    EMAC_REGS__AXI_QOS_CFG_1__Q_6_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_1__Q_6_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 7){
	    EMAC_REGS__AXI_QOS_CFG_1__Q_7_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_1__Q_7_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 8){
	    EMAC_REGS__AXI_QOS_CFG_2__Q_8_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_2__Q_8_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 9){
	    EMAC_REGS__AXI_QOS_CFG_2__Q_9_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_2__Q_9_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 10){
	    EMAC_REGS__AXI_QOS_CFG_2__Q_10_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_2__Q_10_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 11){
	    EMAC_REGS__AXI_QOS_CFG_2__Q_11_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_2__Q_11_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 12){
	    EMAC_REGS__AXI_QOS_CFG_3__Q_12_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_3__Q_12_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 13){
	    EMAC_REGS__AXI_QOS_CFG_3__Q_13_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_3__Q_13_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 14){
	    EMAC_REGS__AXI_QOS_CFG_3__Q_14_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_3__Q_14_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}
	if (queueNum  == 15){
	    EMAC_REGS__AXI_QOS_CFG_3__Q_15_DESCR_QOS__MODIFY(reg, axiQosConfig->descriptorQos);
	    EMAC_REGS__AXI_QOS_CFG_3__Q_15_DATA_QOS__MODIFY(reg, axiQosConfig->dataQos);
	}

	CPS_UncachedWrite32(regPtr, reg);
    }


    return status;
}

uint32_t emacGetAxiQosConfig(CEDI_PrivateData* pD, uint8_t queueNum, CEDI_AxiQosConfig* axiQosConfig)
{
    uint32_t status = 0;
    uint32_t reg;
    volatile uint32_t* const axiQosReg[4] = {
	CEDI_RegOff(axi_qos_cfg_0),
	CEDI_RegOff(axi_qos_cfg_1),
	CEDI_RegOff(axi_qos_cfg_2),
	CEDI_RegOff(axi_qos_cfg_3),
    };


    if ((pD==NULL) || (axiQosConfig==NULL))
	status = EINVAL;

    if (0U == status){
	if (queueNum > pD->cfg.txQs){
	    vDbgMsg(DBG_GEN_MSG, DBG_CRIT, "%s\n",
		    "Error: Queue number is bigger than supported queue number\n");
	    status = EINVAL;
	}
    }

    if (0U == status){
	if (0U == IsGem1p11(pD))
	    status = ENOTSUP;
    }

    if (0U == status){
	volatile uint32_t *regPtr = NULL;

	regPtr = axiQosReg[queueNum >> 2];
	addRegBase(pD, &regPtr);
	reg = CPS_UncachedRead32(regPtr);


	if (queueNum  == 0){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_0__Q_0_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_0__Q_0_DATA_QOS__READ(reg);
	}

	if (queueNum  == 1){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_0__Q_1_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_0__Q_1_DATA_QOS__READ(reg);
	}
	if (queueNum  == 2){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_0__Q_2_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_0__Q_2_DATA_QOS__READ(reg);
	}
	if (queueNum  == 3){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_0__Q_3_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_0__Q_3_DATA_QOS__READ(reg);
	}
	if (queueNum  == 4){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_1__Q_4_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_1__Q_4_DATA_QOS__READ(reg);
	}
	if (queueNum  == 5){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_1__Q_5_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_1__Q_5_DATA_QOS__READ(reg);
	}
	if (queueNum  == 6){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_1__Q_6_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_1__Q_6_DATA_QOS__READ(reg);
	}
	if (queueNum  == 7){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_1__Q_7_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_1__Q_7_DATA_QOS__READ(reg);
	}
	if (queueNum  == 8){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_2__Q_8_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_2__Q_8_DATA_QOS__READ(reg);
	}
	if (queueNum  == 9){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_2__Q_9_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_2__Q_9_DATA_QOS__READ(reg);
	}
	if (queueNum  == 10){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_2__Q_10_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_2__Q_10_DATA_QOS__READ(reg);
	}
	if (queueNum  == 11){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_2__Q_11_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_2__Q_11_DATA_QOS__READ(reg);
	}
	if (queueNum  == 12){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_3__Q_12_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_3__Q_12_DATA_QOS__READ(reg);
	}
	if (queueNum  == 13){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_3__Q_13_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_3__Q_13_DATA_QOS__READ(reg);
	}
	if (queueNum  == 14){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_3__Q_14_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_3__Q_14_DATA_QOS__READ(reg);
	}
	if (queueNum  == 15){
	    axiQosConfig->descriptorQos = EMAC_REGS__AXI_QOS_CFG_3__Q_15_DESCR_QOS__READ(reg);
	    axiQosConfig->dataQos = EMAC_REGS__AXI_QOS_CFG_3__Q_15_DATA_QOS__READ(reg);
	}
    }

    return status;
}


static CEDI_OBJ EmacDrv = {
    .probe = emacProbe,               // probe
    .init = emacInit,    	         // init
    .destroy = emacDestroy,             // destroy
    .start = emacStart,               // start
    .stop = emacStop,                // stop
    .isr = emacIsr,                 // isr
    .setEventEnable = emacSetEventEnable,
    .getEventEnable = emacGetEventEnable,
    .setIntrptModerate = emacSetIntrptModerate,
    .getIntrptModerate = emacGetIntrptModerate,
    .setIfSpeed = emacSetIfSpeed,
    .getIfSpeed = emacGetIfSpeed,
    .setJumboFramesRx = emacSetJumboFramesRx,
    .getJumboFramesRx = emacGetJumboFramesRx,
    .setJumboFrameRxMaxLen = emacSetJumboFrameRxMaxLen,
    .getJumboFrameRxMaxLen = emacGetJumboFrameRxMaxLen,
    .setUniDirEnable = emacSetUniDirEnable,
    .getUniDirEnable = emacGetUniDirEnable,
    .setTxChecksumOffload = emacSetTxChecksumOffload,
    .getTxChecksumOffload = emacGetTxChecksumOffload,
    .setRxBufOffset = emacSetRxBufOffset,
    .getRxBufOffset = emacGetRxBufOffset,
    .set1536ByteFramesRx = emacSet1536ByteFramesRx,
    .get1536ByteFramesRx = emacGet1536ByteFramesRx,
    .setRxChecksumOffload = emacSetRxChecksumOffload,
    .getRxChecksumOffload = emacGetRxChecksumOffload,
    .setFcsRemove =  emacSetFcsRemove,
    .getFcsRemove =  emacGetFcsRemove,
    .setTxPartialStFwd = emacSetTxPartialStFwd,
    .getTxPartialStFwd = emacGetTxPartialStFwd,
    .setRxPartialStFwd = emacSetRxPartialStFwd,
    .getRxPartialStFwd = emacGetRxPartialStFwd,
    .setRxDmaDataAddrMask = emacSetRxDmaDataAddrMask,
    .getRxDmaDataAddrMask = emacGetRxDmaDataAddrMask,
    .setRxBadPreamble = emacSetRxBadPreamble,
    .getRxBadPreamble = emacGetRxBadPreamble,
    .setFullDuplex = emacSetFullDuplex,
    .getFullDuplex = emacGetFullDuplex,
    .setIgnoreFcsRx = emacSetIgnoreFcsRx,
    .getIgnoreFcsRx = emacGetIgnoreFcsRx,
    .setRxHalfDuplexInTx = emacSetRxHalfDuplexInTx,
    .getRxHalfDuplexInTx = emacGetRxHalfDuplexInTx,
    .getIfCapabilities = emacGetIfCapabilities,
    .setLoopback = emacSetLoopback,
    .getLoopback = emacGetLoopback,

    .calcMaxTxFrameSize = emacCalcMaxTxFrameSize,
    .queueTxBuf = emacQueueTxBuf,
    .qTxBuf = emacQTxBuf,
    .deQTxBuf = emacDeQTxBuf,
    .txDescFree = emacTxDescFree,
    .freeTxDesc = emacFreeTxDesc,
    .getTxDescStat = emacGetTxDescStat,
    .getTxDescSize = emacGetTxDescSize,
    .resetTxQ = emacResetTxQ,
    .startTx = emacStartTx,
    .stopTx = emacStopTx,
    .abortTx = emacAbortTx,
    .transmitting = emacTransmitting,
    .enableTx = emacEnableTx,
    .getTxEnabled = emacGetTxEnabled,
    .getTxStatus = emacGetTxStatus,
    .clearTxStatus = emacClearTxStatus,
    .enableCbs = emacEnableCbs,
    .disableCbs = emacDisableCbs,
    .getCbsQSetting = emacGetCbsQSetting,
    .setIpgStretch = emacSetIpgStretch,
    .getIpgStretch = emacGetIpgStretch,

    .calcMaxRxFrameSize = emacCalcMaxRxFrameSize,
    .addRxBuf = emacAddRxBuf,
    .numRxBufs = emacNumRxBufs,
    .numRxUsed = emacNumRxUsed,
    .readRxBuf = emacReadRxBuf,
    .getRxDescStat = emacGetRxDescStat,
    .getRxDescSize = emacGetRxDescSize,
    .rxEnabled = emacRxEnabled,
    .enableRx = emacEnableRx,
    .disableRx = emacDisableRx,
    .removeRxBuf = emacRemoveRxBuf,
    .resetRxQ = emacResetRxQ,
    .getRxStatus = emacGetRxStatus,
    .clearRxStatus = emacClearRxStatus,
    .setHdrDataSplit = emacSetHdrDataSplit,
    .getHdrDataSplit = emacGetHdrDataSplit,
    .setRscEnable = emacSetRscEnable,
    .getRscEnable = emacGetRscEnable,
    .setRscClearMask = emacSetRscClearMask,
    .setSpecificAddr = emacSetSpecificAddr,
    .getSpecificAddr = emacGetSpecificAddr,
    .setSpecificAddr1Mask = emacSetSpecificAddr1Mask,
    .getSpecificAddr1Mask = emacGetSpecificAddr1Mask,
    .disableSpecAddr = emacDisableSpecAddr,
    .setTypeIdMatch = emacSetTypeIdMatch,
    .getTypeIdMatch = emacGetTypeIdMatch,
    .setUnicastEnable = emacSetUnicastEnable,
    .getUnicastEnable = emacGetUnicastEnable,
    .setMulticastEnable = emacSetMulticastEnable,
    .getMulticastEnable = emacGetMulticastEnable,
    .setNoBroadcast = emacSetNoBroadcast,
    .getNoBroadcast = emacGetNoBroadcast,
    .setVlanOnly = emacSetVlanOnly,
    .getVlanOnly = emacGetVlanOnly,
    .setStackedVlanReg = emacSetStackedVlanReg,
    .getStackedVlanReg = emacGetStackedVlanReg,
    .setCopyAllFrames = emacSetCopyAllFrames,
    .getCopyAllFrames = emacGetCopyAllFrames,
    .setHashAddr = emacSetHashAddr,
    .getHashAddr = emacGetHashAddr,
    .setLenErrDiscard = emacSetLenErrDiscard,
    .getLenErrDiscard = emacGetLenErrDiscard,
    .getNumScreenRegs = emacGetNumScreenRegs,
    .setType1ScreenReg = emacSetType1ScreenReg,
    .getType1ScreenReg = emacGetType1ScreenReg,
    .setType2ScreenReg = emacSetType2ScreenReg,
    .getType2ScreenReg = emacGetType2ScreenReg,
    .setType2EthertypeReg = emacSetType2EthertypeReg,
    .getType2EthertypeReg = emacGetType2EthertypeReg,
    .setType2CompareReg = emacSetType2CompareReg,
    .getType2CompareReg = emacGetType2CompareReg,

    .setPauseEnable = emacSetPauseEnable,
    .getPauseEnable = emacGetPauseEnable,
    .txPauseFrame = emacTxPauseFrame,
    .txZeroQPause = emacTxZeroQPause,
    .getRxPauseQuantum = emacGetRxPauseQuantum,
    .setTxPauseQuantum = emacSetTxPauseQuantum,
    .getTxPauseQuantum = emacGetTxPauseQuantum,
    .setCopyPauseDisable = emacSetCopyPauseDisable,
    .getCopyPauseDisable = emacGetCopyPauseDisable,
    .setPfcPriorityBasedPauseRx = emacSetPfcPriorityBasedPauseRx,
    .getPfcPriorityBasedPauseRx = emacGetPfcPriorityBasedPauseRx,
    .txPfcPriorityBasedPause = emacTxPfcPriorityBasedPause,
    .setTxPfcPauseFrameFields = emacSetTxPfcPauseFrameFields,
    .getTxPfcPauseFrameFields = emacGetTxPfcPauseFrameFields,
    .setEnableMultiPfcPauseQuantum = emacSetEnableMultiPfcPauseQuantum,
    .getEnableMultiPfcPauseQuantum = emacGetEnableMultiPfcPauseQuantum,

    .setUnicastPtpDetect = emacSetUnicastPtpDetect,
    .getUnicastPtpDetect = emacGetUnicastPtpDetect,
    .setPtpRxUnicastIpAddr = emacSetPtpRxUnicastIpAddr,
    .getPtpRxUnicastIpAddr = emacGetPtpRxUnicastIpAddr,
    .setPtpTxUnicastIpAddr = emacSetPtpTxUnicastIpAddr,
    .getPtpTxUnicastIpAddr = emacGetPtpTxUnicastIpAddr,
    .set1588Timer = emacSet1588Timer,
    .get1588Timer = emacGet1588Timer,
    .adjust1588Timer = emacAdjust1588Timer,
    .set1588TimerInc = emacSet1588TimerInc,
    .get1588TimerInc = emacGet1588TimerInc,
    .setTsuTimerCompVal = emacSetTsuTimerCompVal,
    .getTsuTimerCompVal = emacGetTsuTimerCompVal,
    .getPtpFrameTxTime = emacGetPtpFrameTxTime,
    .getPtpFrameRxTime = emacGetPtpFrameRxTime,
    .getPtpPeerFrameTxTime = emacGetPtpPeerFrameTxTime,
    .getPtpPeerFrameRxTime = emacGetPtpPeerFrameRxTime,
    .get1588SyncStrobeTime = emacGet1588SyncStrobeTime,
    .setExtTsuPortEnable = emacSetExtTsuPortEnable,
    .getExtTsuPortEnable = emacGetExtTsuPortEnable,
    .set1588OneStepTxSyncEnable = emacSet1588OneStepTxSyncEnable,
    .get1588OneStepTxSyncEnable = emacGet1588OneStepTxSyncEnable,
    .setDescTimeStampMode = emacSetDescTimeStampMode,
    .getDescTimeStampMode = emacGetDescTimeStampMode,
    .setStoreRxTimeStamp = emacSetStoreRxTimeStamp,
    .getStoreRxTimeStamp = emacGetStoreRxTimeStamp,

    .resetPcs = emacResetPcs,
    .getPcsReady = emacGetPcsReady,
    .startAutoNegotiation = emacStartAutoNegotiation,
    .setAutoNegEnable = emacSetAutoNegEnable,
    .getAutoNegEnable = emacGetAutoNegEnable,
    .getLinkStatus = emacGetLinkStatus,
    .getAnRemoteFault = emacGetAnRemoteFault,
    .getAnComplete = emacGetAnComplete,
    .setAnAdvPage = emacSetAnAdvPage,
    .getAnAdvPage = emacGetAnAdvPage,
    .getLpAbilityPage = emacGetLpAbilityPage,
    .getPageRx = emacGetPageRx,
    .setNextPageTx = emacSetNextPageTx,
    .getNextPageTx = emacGetNextPageTx,
    .getLpNextPage = emacGetLpNextPage,

    .getPhyId = emacGetPhyId,
    .setMdioEnable = emacSetMdioEnable,
    .getMdioEnable = emacGetMdioEnable,
    .phyStartMdioWrite = emacPhyStartMdioWrite,
    .phyStartMdioRead = emacPhyStartMdioRead,
    .getMdioReadData = emacGetMdioReadData,
    .getMdioIdle = emacGetMdioIdle,

    .readStats = emacReadStats,
    .clearStats = emacClearStats,
    .takeSnapshot = emacTakeSnapshot,
    .setReadSnapshot = emacSetReadSnapshot,
    .getReadSnapshot = emacGetReadSnapshot,
    .setWakeOnLanReg = emacSetWakeOnLanReg,
    .getWakeOnLanReg = emacGetWakeOnLanReg,
    .setLpiTxEnable = emacSetLpiTxEnable,
    .getLpiTxEnable = emacGetLpiTxEnable,
    .getLpiStats = emacGetLpiStats,
    .getDesignConfig = emacGetDesignConfig,

    .setWriteStatsEnable = emacSetWriteStatsEnable,
    .getWriteStatsEnable = emacGetWriteStatsEnable,
    .incStatsRegs = emacIncStatsRegs,
    .setRxBackPressure = emacSetRxBackPressure,
    .getRxBackPressure = emacGetRxBackPressure,
    .setCollisionTest = emacSetCollisionTest,
    .getCollisionTest = emacGetCollisionTest,
    .setRetryTest = emacSetRetryTest,
    .getRetryTest = emacGetRetryTest,
    .writeUserOutputs = emacWriteUserOutputs,
    .readUserOutputs = emacReadUserOutputs,
    .setUserOutPin = emacSetUserOutPin,
    .readUserInputs = emacReadUserInputs,
    .getUserInPin = emacGetUserInPin,
    .getMdioInState = emacGetMdioInState,
    .readReg = emacReadReg,
    .writeReg = emacWriteReg,
    .setTxQueueNum = emacSetTxQueueNum,
    .setRxQueueNum = emacSetRxQueueNum,
    .setTxQueueSegAlloc = emacSetSegAlloc,
    .setTxQueueScheduler = emacSetTxQueueScheduler,
    .getTxQueueScheduler = emacGetTxQueueScheduler,
    .setDwrrWeighting = emacSetDwrrWeighting,
    .setEtsBandAlloc = emacSetEtsBandAlloc,
    .getDwrrWeighting = emacGetDwrrWeighting,
    .getEtsBandAlloc = emacGetEtsBandAlloc,
    .setEnstTimeConfig = emacSetEnstTimeConfig,
    .getEnstTimeConfig = emacGetEnstTimeConfig,
    .setEnstEnable = emacSetEnstEnable,
    .getEnstEnable = emacGetEnstEnable,
    .getEnstSupported = emacGetEnstSupported,
    .setReportingBadFCS = emacSetReportingBadFCS,
    .getReportingBadFCS = emacGetReportingBadFCS,
    .setPtpSingleStep = emacSetPtpSingleStep,
    .getPtpSingleStep = emacGetPtpSingleStep,
    .setMiiOnRgmii = emacSetMiiOnRgmii,
    .getMiiOnRgmii = emacGetMiiOnRgmii,
    .setCbsIdleSlope = emacSetCbsIdleSlope,
    .getCbsIdleSlope = emacGetCbsIdleSlope,
    .getLinkFaultIndication = emacGetLinkFaultIndication,
    .setFrameEliminationTagSize = emacSetFrameEliminationTagSize,
    .getFrameEliminationTagSize = emacGetFrameEliminationTagSize,
    .setFrameEliminationEnable = emacSetFrameEliminationEnable,
    .getFrameEliminationEnable = emacGetFrameEliminationEnable,
    .setFrameEliminationSeqRecRstTmrEnable = emacSetFrameEliminationSeqRecRstTmrEnable,
    .getFrameEliminationSeqRecRstTmrEnable = emacGetFrameEliminationSeqRecRstTmrEnable,
    .setFrameEliminationConfig = emacSetFrameEliminationConfig,
    .getFrameEliminationConfig = emacGetFrameEliminationConfig,
    .setFrameEliminationTagConfig = emacSetFrameEliminationTagConfig,
    .getFrameEliminationTagConfig = emacGetFrameEliminationTagConfig,
    .setFrameEliminationTimoutConfig = emacSetFrameEliminationTimoutConfig,
    .getFrameEliminationStats = emacGetFrameEliminationStats,
    .getEmac = emacGetEmac,
    .getPmac = emacGetPmac,
    .getMacType = emacGetMacType,
    .setPreemptionConfig = emacSetPreemptionConfig,
    .getPreemptionConfig = emacGetPreemptionConfig,
    .preemptionRestartVerification = emacPreemptionRestartVerification,
    .setMmslEventEnable = emacSetMmslEventEnable,
    .getMmslEventEnable = emacGetMmslEventEnable,
    .readMmslStats = emacReadMmslStats,
    .readMmslStatus = emacReadMmslStatus,
    .setType1ScreenRegDropEnable = emacSetType1ScreenRegDropEnable,
    .getType1ScreenRegDropEnable = emacGetType1ScreenRegDropEnable,
    .setType2ScreenRegDropEnable = emacSetType2ScreenRegDropEnable,
    .getType2ScreenRegDropEnable = emacGetType2ScreenRegDropEnable,
    .setRxQFlushConfig = emacSetRxQFlushConfig,
    .getRxQFlushConfig = emacGetRxQFlushConfig,
    .getRxDmaFlushedPacketsCount = emacGetRxDmaFlushedPacketsCount,
    .setType2ScreenerRateLimit = emacSetType2ScreenerRateLimit,
    .getType2ScreenerRateLimit = emacGetType2ScreenerRateLimit,
    .getRxType2RateLimitTriggered = emacGetRxType2RateLimitTriggered,
    .setIntrptModerateThreshold = emacSetIntrptModerateThreshold,
    .getIntrptModerateThreshold = emacGetIntrptModerateThreshold,
    .setRxWatermark = emacSetRxWatermark,
    .getRxWatermark = emacGetRxWatermark,
    .setLockupConfig = emacSetLockupConfig,
    .getLockupConfig = emacGetLockupConfig,
    .setAxiQosConfig = emacSetAxiQosConfig,
    .getAxiQosConfig = emacGetAxiQosConfig,
    .getAsfInfo = emacGetAsfInfo,

};

CEDI_OBJ *CEDI_GetInstance(void) {
    return (&EmacDrv);
}

