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
 * edd_int.h
 * Private declarations for Ethernet DMA-MAC Driver
 *
 ***********************************************************************/
#ifndef EDD_INT_H
#define EDD_INT_H

#include "cedi.h"


/******************************************************************************
 * Private Constants
 *****************************************************************************/

#define GEM_GXL_MODULE_ID_V0    (0x0007U)
#define GEM_GXL_MODULE_ID_V1    (0x0107U)
#define GEM_GXL_MODULE_ID_V2    (0x000AU)
#define GEM_XL_MODULE_ID        (0x0008U)
#define GEM_AUTO_MODULE_ID_V0   (0x0207U)
#define GEM_AUTO_MODULE_ID_V1   (0x020AU)

#define XGM_GXL_MODULE_ID       (0x000BU)

#define OFFLOADS_GEM_GXL_REV    (0x0107U)

#define CEDI_MIN_TXBD           1U
#define CEDI_MIN_RXBD           1U

#define MAX_JUMBO_FRAME_LENGTH  (16383U)

/* Tx Descriptor flags/status - word 1 only */
#define CEDI_TXD_LAST_BUF       (1UL << 15U)
#define CEDI_TXD_NO_AUTO_CRC    (1UL << 16U)
#define CEDI_TXD_UFO_ENABLE     (1UL << 17U)
#define CEDI_TXD_TSO_ENABLE     (1UL << 18U)
#define CEDI_TXD_AUTOSEQ_SEL    (1UL << 19U)
#define CEDI_TXD_CHKOFF_SHIFT   (20U)
#define CEDI_TXD_CHKOFF_MASK    (7UL << CEDI_TXD_CHKOFF_SHIFT)
#define CEDI_TXD_TS_VALID       (1UL << 23U)
#define CEDI_TXD_STREAM_SHIFT   (24U)
#define CEDI_TXD_STREAM_MASK    (3UL << CEDI_TXD_STREAM_SHIFT)
#define CEDI_TXD_LATE_COLL      (1UL << 26U)
#define CEDI_TXD_FR_CORR        (1UL << 27U)
#define CEDI_TXD_UNDERRUN       (1UL << 28U)
#define CEDI_TXD_RETRY_EXC      (1UL << 29U)
#define CEDI_TXD_WRAP           (1UL << 30U)
#define CEDI_TXD_USED           (1UL << 31U)
/* MSS/MFS only used on word 1 of 2nd descriptor */
#define CEDI_TXD_MSSMFS_SHIFT   (16U)
#define CEDI_TXD_MSSMFS_MASK    (0x3FFFUL << CEDI_TXD_MSSMFS_SHIFT)
#define CEDI_TXD_LEN_MASK       ((1UL << 14U) - 1U)

/* Rx Descriptor flags - word 0 */
#define CEDI_RXD_USED        (1UL << 0U)
#define CEDI_RXD_WRAP        (1UL << 1U)
#define CEDI_RXD_TS_VALID    (1UL << 2U)
#define CEDI_RXD_ADDR_MASK   (0xFFFFFFFCU)
#define CEDI_RXD_ADDR_SHIFT  (2U)

/* Rx Descriptor flags/status - word 1 */
#define CEDI_RXD_LEN_MASK        ((1UL << 13U) - 1U)
/*** need to include bit 13 if jumbo frames enabled ***/
#define CEDI_RXD_LEN13_FCS_STAT  (1UL << 13U)
#define CEDI_RXD_SOF             (1UL << 14U)
#define CEDI_RXD_EOF             (1UL << 15U)
#define CEDI_RXD_CFI             (1UL << 16U)
#define CEDI_RXD_VLAN_PRI_SHIFT  (17U)
#define CEDI_RXD_VLAN_PRI_MASK   (7UL << CEDI_RXD_VLAN_PRI_SHIFT)
/* if header-data splitting, these definitions are valid when not EOF: */
#define CEDI_RXD_HDR             (1UL << 16U)  /* header buffer */
#define CEDI_RXD_EOH             (1UL << 17U)  /* end of header */

/* CRC error when  reporting bad FCS in bit 16 of word 1 of the receive buffer descriptor is enabled*/
#define CEDI_RXD_CRC             (1UL << 16U)

#define CEDI_RXD_PRI_TAG         (1UL << 20U)
#define CEDI_RXD_VLAN_TAG        (1UL << 21U)
                // either Type ID match register or
                // (if Rx chksum offload enabled) checksum status
#define CEDI_RXD_TYP_IDR_CHK_STA_SHIFT (22U)
#define CEDI_RXD_TYP_IDR_CHK_STA_MASK (3UL << CEDI_RXD_TYP_IDR_CHK_STA_SHIFT)
                // either Type ID matched or
                // (if Rx chksum offload enabled) SNAP encoded and no CFI
#define CEDI_RXD_TYP_MAT_SNP_NCFI   (1UL << 24)
#define CEDI_RXD_SPEC_REG_SHIFT     (25U)
#define CEDI_RXD_SPEC_REG_MASK      (3UL << CEDI_RXD_SPEC_REG_SHIFT)
#define CEDI_RXD_SPEC_ADD_MAT       (1UL << 27U)
#define CEDI_RXD_EXT_ADD_MAT        (1UL << 28U)
#define CEDI_RXD_UNI_HASH_MAT       (1UL << 29U)
#define CEDI_RXD_MULTI_HASH_MAT     (1UL << 30U)
#define CEDI_RXD_BROADCAST_DET      (1UL << 31U)

/* For Tx/Rx time stamp extraction from descriptor words*/
#define CEDI_TS_NANO_SEC_MASK       (0x3FFFFFFFU)
#define CEDI_TS_SEC0_SHIFT          (30U)
#define CEDI_TS_SEC1_MASK           (0x0FU)
#define CEDI_TS_SEC1_POS_SHIFT      (2U)
#define CEDI_TS_SEC_WIDTH           (6U)
#define CEDI_TS_SEC_TOP             (1UL << CEDI_TS_SEC_WIDTH)
#define CEDI_TS_SEC_MASK            (CEDI_TS_SEC_TOP - 1U)

/* For Tx time launch time configuration in descriptor words */
#define CEDI_TLT_NANO_SEC_MASK      (0x3FFFFFFFU)
#define CEDI_TLT_SECS_SHIFT         (30U)
#define CEDI_TLT_UTLT		    (1UL << 31)

/* Offset of registers for Express MAC relative to Preemptive MAC. */
#define CEDI_EXPRESS_MAC_REGS_OFFSET 0x1000U

/* Offset of registers for ASF relative to MAC registers */
#define CEDI_ASF_REGS_OFFSET	     0xE00U

#define CEDI_RXD_EMPTY              (0xFFAA0000U)

#define CEDI_PHY_ADDR_OP             (0U)
#define CEDI_PHY_WRITE_OP            (1U)
#define CEDI_PHY_CL22_READ_OP        (2U)
#define CEDI_PHY_CL45_READ_INC_OP    (2U)
#define CEDI_PHY_CL45_READ_OP        (3U)


#define CEDI_TWO_BD_WORD_SIZE        (8U)    // Size required for two buffer descriptor word (in bytes).
#define CEDI_BYTES_PER_WORD_SHIFT    (2U)    // Shift variable for number of bytes in a word
#define CEDI_DESC_WORD_NUM_MAX       (6U)    // Maximum number of words allowed in a descriptor.

#define CEDI_AMBD_BURST_LEN_1     (0x01U)    // for CEDI_DMA_DBUR_LEN_1
#define CEDI_AMBD_BURST_LEN_4     (0x04U)    // for CEDI_DMA_DBUR_LEN_4
#define CEDI_AMBD_BURST_LEN_8     (0x08U)    // for CEDI_DMA_DBUR_LEN_8
#define CEDI_AMBD_BURST_LEN_16    (0x10U)    // for CEDI_DMA_DBUR_LEN_16

/******************************************************************************
 * Local macros - assume pD is privateData parameter in function scope, and
 * cfg has been initialised with register base address
 *****************************************************************************/


/**
* Obtains register offset from base address of the emac_regs structure.
* REG_NAME_ is the name of the field from emac_regs structure.
*  e.g. spec_add1_bottom
*/
# define CEDI_RegOff(REG_NAME_) \
    (&((struct emac_regs*)0)->REG_NAME_)


/******************************************************************************
 * Types
 *****************************************************************************/

/* Tx Descriptor defs */
typedef struct {
    uint32_t word[CEDI_DESC_WORD_NUM_MAX];
} txDesc;

typedef struct {
    txDesc      *bdBase;        // base address of descriptor ring
    txDesc      *bdHead;        // first available descriptor
    txDesc      *bdTail;        // first descriptor waiting to be freed
    txDesc      *bd1stBuf;      // first buffer of current frame
    uint16_t    descMax;        // total number of descriptors
    uint16_t    descFree;       // number of descriptors that can accept buffers
    uintptr_t   *vHead;         // virt address corresponding to head BD
    uintptr_t   *vTail;         // end of virt address circular array
    uintptr_t   *vAddrList;     // pointer to virt addresses storage
    uint8_t     firstToFree;    // flag indicating stage of frame clean-up: set
                                // when about to clear first buffer of frame
    uint8_t     descNum;        // descriptor counter used by qTxBuf: stays at 0 until
                                // start 2nd desc of frame, then inc to 1, etc.
} txQueue_t;

/* Rx Descriptor defs */
typedef struct {
    uint32_t word[CEDI_DESC_WORD_NUM_MAX];
} rxDesc;

typedef struct {
    rxDesc *rxDescStart;        // start of Rx descriptor list
    rxDesc *rxDescStop;         // end-stop Rx descriptor, trails behind "Tail";
                                //  always kept "used" but with no buffer
    rxDesc *rxDescTail;         // next Rx descriptor to process (one after end-stop)
    rxDesc *rxDescEnd;          // last descriptor in Rx list
    uint16_t numRxDesc;         // total number of descriptors in the list,
                                //  including unused end-stop
    uint16_t numRxBufs;         // number of useable buffers/descriptors in list
    uintptr_t *rxTailVA;        // tail Rx virtual addr
    uintptr_t *rxStopVA;        // end-stop Rx virtual addr, corr. to rxDescStop
    uintptr_t *rxEndVA;         // end Rx virtual addr
    uintptr_t *rxBufVAddr;      // list of buffer virtual addresses in sync
                            // with physical addresses held in descriptor lists
} rxQueue_t;


/* Driver private data - place the tx & rx virtual address lists after this
 * (with these included in privateData memory requirement) */
struct CEDI_PrivateData {
    CEDI_Config      cfg;            // copy of CEDI_Config info supplied to init
    CEDI_Callbacks   cb;             // pointers to callback functions
    CEDI_DesignCfg   hwCfg;          // copy of DesignCfg Debug registers
    struct emac_regs *regs;          // typed pointer to register devices
    uint8_t         numQs;           // number of Qs in this h/w config.
    uint8_t         txQs;            // number of transmit queues
    uint8_t         rxQs;            // number of receive queues
    txQueue_t txQueue[CEDI_MAX_TX_QUEUES];   // tx queue info
    rxQueue_t rxQueue[CEDI_MAX_RX_QUEUES];   // rx queue info
//    CPS_LockHandle  isrLock;        // lock used during isr calls
    uint8_t         anLinkStat;     // retain link status (low) until read
    uint8_t         anRemFault;     // retain link partner remote fault status
                                    //  (high) until read
    uint8_t         autoNegActive;  // auto-negotiation in progress flag
    uint8_t         basePageExp;    // data expected from link partner: set
                                    // initially to indicate base page, clear
                                    // after first received to denote next page
                                    // expected. Set on start auto-negotiation.
    CEDI_LpPageRx    lpPageRx;       // reserved for passing page Rx in callback
    CEDI_NetAnStatus anStatus;       // reserved for a-n status in callback
    CEDI_1588TimerVal ptpTime;       // reserved for passing ptp event times
//    CPS_LockHandle  autoNegLock;    // lock to protect auto-neg flags and next
                                    // page register when isr writes null
                                    // message page
    uint16_t txDescriptorSize;      // bytes per Tx descriptor
    uint16_t rxDescriptorSize;      // bytes per Rx descriptor

    uint8_t frerEnabled[CEDI_MAX_RX_QUEUES];// flags containing information, whether or not FRER is enabled
    struct CEDI_PrivateData *otherMac; // pointer to second mac (is set only if mac type is pMac or eMac)
    CEDI_MacType macType;           // MAC Type eMac, pMac, mac (default MAC);
};

/************************ Internal Driver objects ****************************/
extern volatile uint32_t* const transmitPtrReg[15];

/*********************** Internal Driver functions ***************************/

void getJumboFramesRx(const CEDI_PrivateData *pD, uint8_t *enable);
uint8_t IsGem1p09(const CEDI_PrivateData *pD);
uint8_t IsGem1p11(const CEDI_PrivateData *pD);
uint8_t IsGem1p12(const CEDI_PrivateData *pD);
uint8_t IsEnstSupported(const CEDI_PrivateData *pD);
uint32_t subNsTsuInc24bSupport(const CEDI_PrivateData *pD);
void addRegBase(const CEDI_PrivateData *pD, volatile uint32_t **ptr);
uint32_t *uintptrToPtrU32(uintptr_t addr);
rxDesc *rxDescAddrToPtr(uintptr_t descAddr);
void moveRxDescAddr(rxDesc **ptr, int32_t offset);

/* Driver API function prototypes */

uint32_t emacResetPcs(CEDI_PrivateData *pD);

uint32_t emacGetJumboFrameRxMaxLen(CEDI_PrivateData *pD, uint16_t *length);

uint32_t emacGet1536ByteFramesRx(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacSetMdioEnable(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetMdioEnable(CEDI_PrivateData *pD);
uint32_t emacPhyStartMdioWrite(CEDI_PrivateData *pD, uint8_t flags, uint8_t phyAddr,
            uint8_t devReg, uint16_t addrData);
uint32_t emacPhyStartMdioRead(CEDI_PrivateData *pD, uint8_t flags, uint8_t phyAddr,
            uint8_t devReg);
uint32_t emacGetMdioReadData(CEDI_PrivateData *pD, uint16_t *readData);
uint32_t emacGetMdioIdle(CEDI_PrivateData *pD);

uint32_t emacReadStats(CEDI_PrivateData *pD);
uint32_t emacClearStats(CEDI_PrivateData *pD);

uint32_t emacTakeSnapshot(CEDI_PrivateData *pD);
uint32_t emacSetReadSnapshot(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetReadSnapshot(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacSetWakeOnLanReg(CEDI_PrivateData *pD, const CEDI_WakeOnLanReg *regVals);
uint32_t emacGetWakeOnLanReg(CEDI_PrivateData *pD, CEDI_WakeOnLanReg *regVals);

uint32_t emacSetLpiTxEnable(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetLpiTxEnable(CEDI_PrivateData *pD, uint8_t *enable);
uint32_t emacGetLpiStats(CEDI_PrivateData *pD, CEDI_LpiStats *lpiStats);

uint32_t emacGetDesignConfig(const CEDI_PrivateData *pD, CEDI_DesignCfg *hwCfg);

uint32_t emacSetWriteStatsEnable(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetWriteStatsEnable(CEDI_PrivateData *pD, uint8_t *enable);
uint32_t emacIncStatsRegs(CEDI_PrivateData *pD);


uint32_t emacSetStoreRxTimeStamp(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetStoreRxTimeStamp(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacSetAutoNegEnable(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetAutoNegEnable(CEDI_PrivateData *pD, uint8_t *enable);
uint32_t readPcsStatus(CEDI_PrivateData *pD);
uint32_t emacGetPcsReady(CEDI_PrivateData *pD, uint8_t *ready);
uint32_t emacGetLinkStatus(CEDI_PrivateData *pD, uint8_t *status);
uint32_t emacGetAnRemoteFault(CEDI_PrivateData *pD, uint8_t *status);
uint32_t emacGetAnComplete(CEDI_PrivateData *pD, uint8_t *status);
uint32_t emacSetAnAdvPage(CEDI_PrivateData *pD, const CEDI_AnAdvPage *advDat);
uint32_t emacGetAnAdvPage(CEDI_PrivateData *pD, CEDI_AnAdvPage *advDat);
uint32_t emacGetLpAbilityPage(CEDI_PrivateData *pD, CEDI_LpAbilityPage *lpAbl);
uint32_t emacGetPageRx(CEDI_PrivateData *pD);
uint32_t emacGetLpNextPage(CEDI_PrivateData *pD, CEDI_LpNextPage *npDat);
uint32_t emacSetNextPageTx(CEDI_PrivateData *pD, const CEDI_AnNextPage *npDat);
uint32_t emacGetNextPageTx(CEDI_PrivateData *pD, CEDI_AnNextPage *npDat);

uint32_t emacGetPhyId(CEDI_PrivateData *pD, uint32_t *phyId);

uint32_t emacSetCollisionTest(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetCollisionTest(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacSetFrameEliminationEnable(CEDI_PrivateData *pD, uint8_t queueNum,
            uint8_t enable);
uint32_t emacGetFrameEliminationEnable(const CEDI_PrivateData *pD, uint8_t queueNum,
            uint8_t *enable);
uint32_t emacSetFrameEliminationSeqRecRstTmrEnable(const CEDI_PrivateData *pD, uint8_t queueNum,
            uint8_t enable);
uint32_t emacSetFrameEliminationConfig(const CEDI_PrivateData *pD, uint8_t queueNum,
            const CEDI_FrameEliminationConfig* fec);
uint32_t emacGetFrameEliminationConfig(const CEDI_PrivateData *pD, uint8_t queueNum,
            CEDI_FrameEliminationConfig* fec);
uint32_t emacSetFrameEliminationTagConfig(CEDI_PrivateData *pD,
            const CEDI_FrameEliminationTagConfig* fetc);
uint32_t emacGetFrameEliminationTagConfig(CEDI_PrivateData *pD,
            CEDI_FrameEliminationTagConfig* fetc);
uint32_t emacSetFrameEliminationTimoutConfig(CEDI_PrivateData *pD, uint16_t timeout);
uint32_t emacGetFrameEliminationStats(const CEDI_PrivateData *pD, uint8_t queueNum,
            CEDI_FrameEliminationStats* stats);

uint32_t emacGetMacType(const CEDI_PrivateData *pD, CEDI_MacType* macType);
uint32_t emacGetEmac(CEDI_PrivateData *pD, CEDI_PrivateData **emacPrivateData);
uint32_t emacGetPmac(CEDI_PrivateData *pD, CEDI_PrivateData **pmacPrivateData);
uint32_t emacSetPreemptionConfig(CEDI_PrivateData *pD, const CEDI_PreemptionConfig* preCfg);
uint32_t emacGetPreemptionConfig(CEDI_PrivateData *pD, CEDI_PreemptionConfig* preCfg);



uint32_t emacGetPtpFrameTxTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal);
uint32_t emacGetPtpFrameRxTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal);
uint32_t emacGetPtpPeerFrameTxTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal);
uint32_t emacGetPtpPeerFrameRxTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal);
uint32_t emacGet1588SyncStrobeTime(CEDI_PrivateData *pD, CEDI_1588TimerVal *timeVal);
uint32_t emacSetExtTsuPortEnable(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetExtTsuPortEnable(CEDI_PrivateData *pD, uint8_t *enable);
uint32_t emacSet1588OneStepTxSyncEnable(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGet1588OneStepTxSyncEnable(CEDI_PrivateData *pD, uint8_t *enable);
uint32_t emacSetDescTimeStampMode(CEDI_PrivateData *pD, CEDI_TxTsMode txMode,
            CEDI_RxTsMode rxMode);
uint32_t emacGetDescTimeStampMode(CEDI_PrivateData *pD, CEDI_TxTsMode* txMode,
            CEDI_RxTsMode* rxMode);


void emacSetRxBackPressure(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetRxBackPressure(CEDI_PrivateData *pD, uint8_t *enable);

void emacSetRetryTest(CEDI_PrivateData *pD, uint8_t enable);
uint32_t emacGetRetryTest(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacWriteUserOutputs(CEDI_PrivateData *pD, uint16_t outVal);
uint32_t emacReadUserOutputs(CEDI_PrivateData *pD, uint16_t *outVal);
uint32_t emacSetUserOutPin(CEDI_PrivateData *pD, uint8_t pin, uint8_t state);
uint32_t emacReadUserInputs(CEDI_PrivateData *pD, uint16_t *inVal);
uint32_t emacGetUserInPin(CEDI_PrivateData *pD, uint8_t pin, uint8_t *state);



uint32_t emacSetReportingBadFCS(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetReportingBadFCS(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacSetPtpSingleStep(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetPtpSingleStep(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacSetMiiOnRgmii(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetMiiOnRgmii(CEDI_PrivateData *pD, uint8_t *enable);


/****************** API Prototypes for other source modules ******************/

/****************************** edd_tx.c *************************************/

uint32_t emacCalcMaxTxFrameSize(CEDI_PrivateData *pD, CEDI_FrameSize *maxTxSize);

uint32_t emacQueueTxBuf(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_BuffAddr *bufAdd,
        uint32_t length, uint8_t flags);

uint32_t emacQTxBuf(CEDI_PrivateData *pD, CEDI_qTxBufParams *prm);

uint32_t emacDeQTxBuf(CEDI_PrivateData *pD, CEDI_qTxBufParams *prm);

uint32_t emacTxDescFree(const CEDI_PrivateData *pD, uint8_t queueNum, uint16_t *numFree);

uint32_t emacFreeTxDesc(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_TxDescData *descData);

void emacGetTxDescStat(const CEDI_PrivateData *pD, uint32_t txDStatWord, CEDI_TxDescStat *txDStat);

void emacGetTxDescSize(const CEDI_PrivateData *pD, uint32_t *txDescSize);

uint32_t emacResetTxQ(CEDI_PrivateData *pD, uint8_t queueNum);

uint32_t emacStartTx(CEDI_PrivateData *pD);

void emacStopTx(CEDI_PrivateData *pD);

void emacAbortTx(CEDI_PrivateData *pD);

uint32_t emacTransmitting(CEDI_PrivateData *pD);

void emacEnableTx(CEDI_PrivateData *pD);

uint32_t emacGetTxEnabled(CEDI_PrivateData *pD);

uint32_t emacGetTxStatus(CEDI_PrivateData *pD, CEDI_TxStatus *status);

void emacClearTxStatus(CEDI_PrivateData *pD, uint32_t resetStatus);

uint32_t emacSetTxPartialStFwd(CEDI_PrivateData *pD, uint32_t watermark, uint8_t enable);

uint32_t emacGetTxPartialStFwd(CEDI_PrivateData *pD, uint32_t *watermark, uint8_t *enable);

uint32_t emacEnableCbs(CEDI_PrivateData *pD, uint8_t qSel, uint32_t idleSlope);

void emacDisableCbs(CEDI_PrivateData *pD, uint8_t qSel);

uint32_t emacGetCbsQSetting(CEDI_PrivateData *pD, uint8_t qSel,
			   uint8_t *enable, uint32_t *idleSlope);

uint32_t emacSetIpgStretch(CEDI_PrivateData *pD, uint8_t enable, uint8_t multiplier,
        uint8_t divisor);

uint32_t emacGetIpgStretch(CEDI_PrivateData *pD, uint8_t *enabled, uint8_t *multiplier,
        uint8_t *divisor);


uint32_t emacGetAllSegAlloctCount(const CEDI_PrivateData *pD, uint32_t *numberOfSegments);
uint32_t emacGetTxQueueNum(const CEDI_PrivateData *pD, uint8_t *numQueues);

uint32_t
DoSetSegAlloc(CEDI_PrivateData *pD, const CEDI_SegmentsPerQueue *seqmentsPerQueue, uint8_t numOfQueues);

uint32_t
DoGetSegAlloc(CEDI_PrivateData *pD, CEDI_SegmentsPerQueue *seqmentsPerQueue, uint8_t numOfQueues);


uint32_t
emacSetTxQueueNum(CEDI_PrivateData *pD, uint8_t numQueues);

uint32_t
emacSetSegAlloc(CEDI_PrivateData *pD, const CEDI_QueueSegAlloc *queueSegAlloc);

uint32_t
emacGetSegAlloc(CEDI_PrivateData *pD, CEDI_QueueSegAlloc *queueSegAlloc);

uint32_t
emacSetTxQueueScheduler(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_TxSchedType schedType);

uint32_t
emacGetTxQueueScheduler(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_TxSchedType *schedType);

uint32_t
emacSetDwrrWeighting(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t dwrrWeighting);

uint32_t
emacSetEtsBandAlloc(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t etsBandAlloc);

uint32_t
emacGetDwrrWeighting(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t *dwrrWeighting);

uint32_t
emacGetEtsBandAlloc(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t *etsBandAlloc);

uint32_t emacSetEnstTimeConfig(CEDI_PrivateData *pD, uint8_t queueNum,
                               const CEDI_EnstTimeConfig *enstTimeConfig);

uint32_t emacGetEnstTimeConfig(CEDI_PrivateData *pD, uint8_t queueNum,
                               CEDI_EnstTimeConfig *enstTimeConfig);

uint32_t emacSetEnstEnable(CEDI_PrivateData *pD, uint8_t queue, uint8_t enable);

uint32_t emacGetEnstEnable(CEDI_PrivateData *pD, uint8_t queue, uint8_t *enable);

uint32_t emacGetEnstSupported(CEDI_PrivateData *pD, uint8_t *supported);

uint32_t emacSetCbsIdleSlope(CEDI_PrivateData *pD, uint8_t queueNum, uint32_t idleSlope);

uint32_t emacGetCbsIdleSlope(CEDI_PrivateData *pD, uint8_t queueNum, uint32_t *idleSlope);



/****************************** edd_rx.c *************************************/

uint32_t emacCalcMaxRxFrameSize(CEDI_PrivateData *pD, uint32_t *maxSize);

uint32_t emacAddRxBuf(CEDI_PrivateData *pD, uint8_t queueNum,
            CEDI_BuffAddr *buf, uint8_t init);

uint32_t emacNumRxBufs(const CEDI_PrivateData *pD, uint8_t queueNum, uint16_t *numBufs);

uint32_t emacNumRxUsed(CEDI_PrivateData *pD, uint8_t queueNum);

uint32_t emacReadRxBuf(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_BuffAddr *buf,
                            uint8_t init, CEDI_RxDescData *descData);

void emacGetRxDescStat(CEDI_PrivateData *pD, uint32_t rxDStatWord, CEDI_RxDescStat *rxDStat);

void emacGetRxDescSize(const CEDI_PrivateData *pD, uint32_t *rxDescSize);

uint32_t emacRxEnabled(CEDI_PrivateData *pD);

void emacEnableRx(CEDI_PrivateData *pD);

void emacDisableRx(CEDI_PrivateData *pD);

uint32_t emacRemoveRxBuf(CEDI_PrivateData *pD, uint8_t queueNum, CEDI_BuffAddr *buf);

void emacFindQBaseAddr(const CEDI_PrivateData *pD, uint8_t queueNum, rxQueue_t *rxQ,
                        uint32_t *pAddr, uintptr_t *vAddr);

uint32_t emacResetRxQ(CEDI_PrivateData *pD, uint8_t queueNum, uint8_t ptrsOnly);

uint32_t emacGetRxStatus(CEDI_PrivateData *pD, CEDI_RxStatus *status);

void emacClearRxStatus(CEDI_PrivateData *pD, uint32_t resetStatus);

uint32_t emacSetHdrDataSplit(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetHdrDataSplit(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacSetRscEnable(CEDI_PrivateData *pD, uint8_t queue, uint8_t enable);

uint32_t emacGetRscEnable(CEDI_PrivateData *pD, uint8_t queue, uint8_t *enable);

uint32_t emacSetRscClearMask(CEDI_PrivateData *pD, uint8_t setMask);

uint32_t emacSetRxPartialStFwd(CEDI_PrivateData *pD, uint32_t watermark, uint8_t enable);

uint32_t emacGetRxPartialStFwd(CEDI_PrivateData *pD, uint32_t *watermark, uint8_t *enable);

uint32_t emacSetSpecificAddr(CEDI_PrivateData *pD, uint8_t addrNum, const CEDI_MacAddress *addr,
		 uint8_t specFilterType,uint8_t byteMask);

uint32_t emacGetSpecificAddr(CEDI_PrivateData *pD, uint8_t addrNum, CEDI_MacAddress *addr,
		 uint8_t *specFilterType, uint8_t *byteMask);

uint32_t emacSetSpecificAddr1Mask(CEDI_PrivateData *pD, const CEDI_MacAddress *mask);

uint32_t emacGetSpecificAddr1Mask(CEDI_PrivateData *pD, CEDI_MacAddress *mask);

uint32_t emacDisableSpecAddr(CEDI_PrivateData *pD, uint8_t addrNum);

uint32_t emacSetTypeIdMatch(CEDI_PrivateData *pD, uint8_t matchSel, uint16_t typeId,
        uint8_t enable);

uint32_t emacGetTypeIdMatch(CEDI_PrivateData *pD, uint8_t matchSel, uint16_t *typeId,
        uint8_t *enabled);

void emacSetUnicastEnable(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetUnicastEnable(CEDI_PrivateData *pD, uint8_t *enable);

void emacSetMulticastEnable(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetMulticastEnable(CEDI_PrivateData *pD, uint8_t *enable);

void emacSetNoBroadcast(CEDI_PrivateData *pD, uint8_t reject);

uint32_t emacGetNoBroadcast(CEDI_PrivateData *pD, uint8_t *reject);

void emacSetVlanOnly(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetVlanOnly(CEDI_PrivateData *pD, uint8_t *enable);

void emacSetStackedVlanReg(CEDI_PrivateData *pD, uint8_t enable, uint16_t vlanType);

void emacGetStackedVlanReg(CEDI_PrivateData *pD, uint8_t *enable, uint16_t *vlanType);

void emacSetCopyAllFrames(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetCopyAllFrames(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacSetHashAddr(CEDI_PrivateData *pD, uint32_t hAddrTop, uint32_t hAddrBot);

uint32_t emacGetHashAddr(CEDI_PrivateData *pD, uint32_t *hAddrTop, uint32_t *hAddrBot);

void emacSetLenErrDiscard(CEDI_PrivateData *pD, uint8_t enable);

uint32_t emacGetLenErrDiscard(CEDI_PrivateData *pD, uint8_t *enable);

uint32_t emacGetRxQueueNum(const CEDI_PrivateData *pD, uint8_t *numQueues);


uint32_t emacGetNumScreenRegs(const CEDI_PrivateData *pD, CEDI_NumScreeners *regNums);

uint32_t emacSetType1ScreenReg(CEDI_PrivateData *pD, uint8_t regNum, const CEDI_T1Screen *regVals);

uint32_t emacGetType1ScreenReg(CEDI_PrivateData *pD, uint8_t regNum, CEDI_T1Screen *regVals);

uint32_t emacSetType2ScreenReg(CEDI_PrivateData *pD, uint8_t regNum, const CEDI_T2Screen *regVals);

uint32_t emacGetType2ScreenReg(CEDI_PrivateData *pD, uint8_t regNum, CEDI_T2Screen *regVals);

uint32_t emacSetType2EthertypeReg(CEDI_PrivateData *pD, uint8_t index, uint16_t eTypeVal);

uint32_t emacGetType2EthertypeReg(CEDI_PrivateData *pD, uint8_t index, uint16_t *eTypeVal);

uint32_t emacSetType2CompareReg(CEDI_PrivateData *pD, uint8_t index,
        const CEDI_T2Compare *regVals);

uint32_t emacGetType2CompareReg(CEDI_PrivateData *pD, uint8_t index,
        CEDI_T2Compare *regVals);


uint32_t
emacSetRxQueueNum(CEDI_PrivateData *pD, uint8_t numQueues);

uint32_t emacSetType1ScreenRegDropEnable(CEDI_PrivateData* pD, uint8_t regNum,
					 uint8_t enable);

uint32_t emacGetType1ScreenRegDropEnable(CEDI_PrivateData* pD, uint8_t regNum,
					 uint8_t *enable);

uint32_t emacSetType2ScreenRegDropEnable(CEDI_PrivateData* pD, uint8_t regNum,
				     uint8_t enable);

uint32_t emacGetType2ScreenRegDropEnable(CEDI_PrivateData* pD, uint8_t regNum,
				     uint8_t *enable);

uint32_t emacSetRxQFlushConfig(CEDI_PrivateData* pD, uint8_t queueNum,
			       CEDI_RxQFlushConfig* rxQFlushConfig);

uint32_t emacGetRxQFlushConfig(CEDI_PrivateData* pD, uint8_t queueNum,
			       CEDI_RxQFlushConfig* rxQFlushConfig);

uint32_t emacGetRxDmaFlushedPacketsCount(struct CEDI_PrivateData* pD,
					 uint16_t* count);

uint32_t emacSetType2ScreenerRateLimit(struct CEDI_PrivateData* pD, uint8_t regNum,
				       CEDI_Type2ScreenerRateLimit* rateLimit);

uint32_t emacGetType2ScreenerRateLimit(struct CEDI_PrivateData* pD, uint8_t regNum,
				       CEDI_Type2ScreenerRateLimit* rateLimit);

uint32_t emacGetRxType2RateLimitTriggered(struct CEDI_PrivateData* pD,
					  uint16_t* status);

uint32_t emacSetRxWatermark(CEDI_PrivateData* pD, uint16_t rxHighWatermark, uint16_t rxLowWatermark);

uint32_t emacGetRxWatermark(CEDI_PrivateData* pD, uint16_t* rxHighWatermark, uint16_t* rxLowWatermark);



#endif /* multiple inclusion protection */
