/******************************************************************************
 * copyright (C) 2014-2016 Cadence Design Systems
 * All rights reserved.
 ******************************************************************************
 *
 * Support Functions/declarations for Ethernet MAC Driver functional testing
 *
 *****************************************************************************/

#include "cdn_errno.h"

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
#include "log.h"
#include "cedi.h"
#include "edd_int.h"
#include "edd_test_supp.h"

#define NS_PER_SEC          (1000000000)

/* Register base addresses, replaced with mappings when in kernel. */
#ifdef EMAC_REGS_BASE_ADDRESS1
  void *emac_reg_base[2] = {(void *)EMAC_REG_BASE_ADDRESS0, (void *)EMAC_REG_BASE_ADDRESS1};
#else
  void *emac_reg_base[1] = {(void *)EMAC_REG_BASE_ADDRESS0};
#endif

CEDI_PrivateData *privData[2];
CEDI_Statistics *statRegs[2];
CEDI_OBJ *emacObj[2];

CEDI_BuffAddr aBuf[CEDI_MAX_RX_QUEUES][MAX_TEST_RBQ_LENGTH+1]; /* initial rx buffers */
CEDI_BuffAddr nBuf[CEDI_MAX_RX_QUEUES][MAX_TEST_RBQ_LENGTH+1]; /* new rx buffers to swap in */
uint16_t rxBufLenBytes[CEDI_MAX_RX_QUEUES], oldIndex[CEDI_MAX_RX_QUEUES], newIndex[CEDI_MAX_RX_QUEUES];
uint8_t txBuffer[MAX_JUMBO_FRAME_LENGTH+3];
uint8_t rxBuffer[MAX_JUMBO_FRAME_LENGTH];
uint16_t loopTDummy;

/* vars used by callbacks for interrupt moderation test */
uint8_t txTiming = 0;
uint8_t rxTiming = 0;
uint8_t timerMac = 0;
CEDI_1588TimerVal startTx, startRx;
int txDelay, rxDelay;
CEDI_1588TimerVal timeTxComplete, timeRxFrame;


/* callback event counters and "old" ones for detecting callback */
uint32_t phyManCompleteCount[2];
uint32_t oldPhyManCompleteCount[2];
uint32_t mdioReadData[2];   /* set top bit if read, save read data in lower 16 bits */

uint32_t rxFrameCount[2][CEDI_MAX_RX_QUEUES];
uint32_t oldRxFrameCount[2][CEDI_MAX_RX_QUEUES];
uint32_t rxUsedRead[2][CEDI_MAX_RX_QUEUES];
uint32_t oldRxUsedRead[2][CEDI_MAX_RX_QUEUES];
uint32_t rxOverrun[2][CEDI_MAX_RX_QUEUES];
uint32_t oldRxOverrun[2][CEDI_MAX_RX_QUEUES];
uint32_t txUsedRead[2];
uint32_t oldTxUsedRead[2];
uint32_t txFrComplete[2][CEDI_MAX_TX_QUEUES];
uint32_t oldTxFrComplete[2][CEDI_MAX_TX_QUEUES];
/* params for Tx frame complete - */
uint32_t txFrBufAddr[2][CEDI_MAX_TX_QUEUES];
uint32_t txCbDescStat[2][CEDI_MAX_TX_QUEUES];
uint32_t txUnderrun[2];
uint32_t oldTxUnderrun[2];
uint32_t txRetryExc[2][CEDI_MAX_TX_QUEUES];
uint32_t oldTxRetryExc[2][CEDI_MAX_TX_QUEUES];
uint32_t txFrCorr[2][CEDI_MAX_TX_QUEUES];
uint32_t oldTxFrCorr[2][CEDI_MAX_TX_QUEUES];
uint32_t hrespNotOk[2][CEDI_MAX_TX_QUEUES];
uint32_t oldHrespNotOk[2][CEDI_MAX_TX_QUEUES];
uint32_t rxPauseFrNonZQ[2];
uint32_t oldRxPauseFrNonZQ[2];
uint32_t pauseTimeZero[2];
uint32_t oldPauseTimeZero[2];
uint32_t txPauseFr[2];
uint32_t oldTxPauseFr[2];
uint32_t ptpTxSyncFr[2];
uint32_t oldPtpTxSyncFr[2];
uint32_t ptpTxDelayReqFr[2];
uint32_t oldPtpTxDelayReqFr[2];
uint32_t ptpRxSyncFr[2];
uint32_t oldPtpRxSyncFr[2];
uint32_t ptpRxDelayReqFr[2];
uint32_t oldPtpRxDelayReqFr[2];
uint32_t ptpTxPDelReqFr[2];
uint32_t oldPtpTxPDelReqFr[2];
uint32_t ptpTxPDelRspFr[2];
uint32_t oldPtpTxPDelRspFr[2];
uint32_t ptpRxPDelReqFr[2];
uint32_t oldPtpRxPDelReqFr[2];
uint32_t ptpRxPDelRspFr[2];
uint32_t oldPtpRxPDelRspFr[2];
CEDI_1588TimerVal ptpFrTime[2];
uint32_t tsuSecsInc[2];
uint32_t oldTsuSecsInc[2];
uint32_t tsuTimeMatch[2];
uint32_t oldTsuTimeMatch[2];
uint32_t pcsAnPageRx[2];
uint32_t oldPcsAnPageRx[2];
CEDI_LpPageRx pcsAnLpPage[2];
CEDI_AnNextPage pcsAnNextPage[2];
uint32_t pcsAnComplete[2];
uint32_t oldPcsAnComplete[2];
CEDI_NetAnStatus pcsNetStat[2];
uint32_t pcsLinkChange[2];
uint32_t oldPcsLinkChange[2];
uint8_t pcsLinkState[2];
uint32_t lpiIndChange[2];
uint32_t oldLpiIndChange[2];
uint32_t wakeOnLanEvent[2];
uint32_t oldWakeOnLanEvent[2];
uint32_t extInputEvent[2];
uint32_t oldExtInputEvent[2];
uint32_t EccRxNcrr[2];
uint32_t EccTxNcrr[2];

#ifdef __BARE_METAL__
long NCPS_freeHWMem(uintptr_t addr) {

//  printf("### NCPS_freeHWMem frees ###  block   @ %08X\n", addr);
  free((void *)addr);
  return addr;
}
#endif

/* return the number of priority queues available in the h/w config */
uint8_t cfgHwQs(uint8_t emacInst) {
    uint8_t qCount = 1;
    uint32_t reg = CPS_UncachedRead32(&(
            ((struct emac_regs *)emac_reg_base[emacInst])->designcfg_debug6 ));

    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE1__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE2__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE3__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE4__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE5__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE6__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE7__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE8__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE9__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE10__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE11__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE12__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE13__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE14__READ(reg)) qCount++;
    if (EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE15__READ(reg)) qCount++;
    return qCount;
}

void printTxDescList( cddcOp *cInst, void *pD, uint8_t qNum)
{
#ifdef EDD_DBG_LOG
  uint32_t i,j, wd[6];
  uint32_t numWd;
  txQueue_t *txQ;
  txDesc *thisDesc;

  cInst->printf("\n---  Tx Descriptor List Queue %u  ---\n", qNum);
  txQ = &CEDI_PdVar(txQueue)[qNum];
  thisDesc = txQ->bdBase;
  numWd = (CEDI_PdVar(txDescriptorSize))>>CEDI_BYTES_PER_WORD_SHIFT;
  for (i=0; i<(CEDI_PdVar(cfg).txQLen)[qNum]+1; i++) {

	cInst->printf("d%3u ",i);

	for(j=0;j<numWd;j++){
	  wd[j] = CPS_UncachedRead32(&thisDesc->word[j]);
	  cInst->printf("wd%u:%08X  ",j,wd[j]);
	}

	cInst->printf("u:%u w:%u"\
			"  l:%u tsV:%u len:%4u %s%s\n",
			(wd[1] & CEDI_TXD_USED)?1:0, (wd[1] & CEDI_TXD_WRAP)?1:0,
			(wd[1] & CEDI_TXD_LAST_BUF)?1:0, (wd[1] & CEDI_TXD_TS_VALID)?1:0,
			wd[1] & CEDI_TXD_LMASK,
              (thisDesc==txQ->bdTail)?"<--tail":"",
              (thisDesc==txQ->bdHead)?"<--head":"");

      thisDesc = (txDesc *)
    		  (((uintptr_t)thisDesc) + (CEDI_PdVar(rxDescriptorSize)));
  }
  //cInst->printf("\n");
#endif
}

void printRxDescList(cddcOp *cInst, void *pD, uint8_t qNum)
{
#ifdef EDD_DBG_LOG
  uint32_t i,j,len,numWd,wd[6];
  rxDesc* descCounter;
  uintptr_t *thisVP = CEDI_PdVar(rxQueue[qNum]).rxBufVAddr;

  numWd = (CEDI_PdVar(rxDescriptorSize))>>CEDI_BYTES_PER_WORD_SHIFT;
  cInst->printf("\n---  Rx Descriptor List Queue %u  ---\n", qNum);
  for (i=0; i<=(CEDI_PdVar(cfg).rxQLen)[qNum]; i++) {

	  descCounter = (rxDesc*)((uint32_t)(CEDI_PdVar(rxQueue[qNum]).rxDescStart)
	                              + i*(CEDI_PdVar(rxDescriptorSize)));
	  cInst->printf("d%3u ",i);

	  for(j=0;j<numWd;j++){
		  wd[j] = CPS_UncachedRead32((uint32_t *) &(descCounter->word[j]));
		  cInst->printf("wd%u:%08X  ",j,wd[j]);
	  }

	  len = wd[1] & CEDI_RXD_LEN_MASK;
      if (EMAC_REGS__NETWORK_CONFIG__JUMBO_FRAMES__READ(
              CPS_UncachedRead32(CEDI_RegAddr(network_config))))
		  len |= (wd[1] & CEDI_RXD_LEN13_FCS_STAT);

	  cInst->printf("u:%u w:%u s:%u e:%u  add:%08X tsv:%u len:%4u  %s\n",
			  (wd[0] & CEDI_RXD_USED)?1:0, (wd[0] & CEDI_RXD_WRAP)?1:0,
			  (wd[1] & CEDI_RXD_SOF)?1:0, (wd[1] & CEDI_RXD_EOF)?1:0,
			  wd[0] & CEDI_RXD_ADDR_MASK,(wd[0] & CEDI_RXD_TS_VALID)?1:0,len,
              (thisVP==(CEDI_PdVar(rxQueue[qNum]).rxTailVA))?"<-tail":"");


      if ((wd[0] & CEDI_RXD_USED) && (wd[1] & CEDI_RXD_EOF)){
          cInst->printf("  fcsErr:%u cfi:%u vPri:%u pTag:%u vTag:%u "\
                        "tyReg:%u tyMat:%u sReg:%u sAdd:%u ext:%u uni:%u "\
                        "mul:%u brd:%u\n",
              (wd[1] & CEDI_RXD_LEN13_FCS_STAT)?1:0, (wd[1] & CEDI_RXD_CFI)?1:0,
              (wd[1] & CEDI_RXD_VLAN_PRI_MASK)>>CEDI_RXD_VLAN_PRI_SHIFT,
              (wd[1] & CEDI_RXD_PRI_TAG)?1:0, (wd[1] & CEDI_RXD_VLAN_TAG)?1:0,
              (wd[1] & CEDI_RXD_TYP_IDR_CHK_STA_MASK)>>CEDI_RXD_TYP_IDR_CHK_STA_SHIFT,
              (wd[1] & CEDI_RXD_TYP_MAT_SNP_NCFI)?1:0,
              (wd[1] & CEDI_RXD_SPEC_REG_MASK)>>CEDI_RXD_SPEC_REG_SHIFT,
              (wd[1] & CEDI_RXD_SPEC_ADD_MAT)?1:0, (wd[1] & CEDI_RXD_EXT_ADD_MAT)?1:0,
              (wd[1] & CEDI_RXD_UNI_HASH_MAT)?1:0,
              (wd[1] & CEDI_RXD_MULTI_HASH_MAT)?1:0,
              (wd[1] & CEDI_RXD_BROADCAST_DET)?1:0);
      }
#ifdef EMAC_REGS__DMA_CONFIG__HDR_DATA_SPLITTING_EN__READ
      else     /* show header-split flags when relevant */
       if (CEDI_PdVar(hwCfg).hdr_split && (wd[0] & CEDI_RXD_USED) && !(wd[1] & CEDI_RXD_EOF)
           && EMAC_REGS__DMA_CONFIG__HDR_DATA_SPLITTING_EN__READ(
                CPS_UncachedRead32(CEDI_RegAddr(dma_config))))
          cInst->printf("                                   hdr:%u eoh:%u\n",
                        (wd[1] & CEDI_RXD_HDR)?1:0, (wd[1] & CEDI_RXD_EOH)?1:0);
#endif

#if 0
      /* add start of buffer contents if used - relies on virtual address lists */
      if (wd[0] & CEDI_RXD_USED) {
          cInst->printf("    d[0]=0x%08X d[1]=0x%08X d[2]=0x%08X d[3]=0x%08X\n",
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+1),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+2),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+3));
          cInst->printf("    d[4]=0x%08X d[5]=0x%08X d[6]=0x%08X d[7]=0x%08X\n",
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+4),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+5),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+6),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+7));
          cInst->printf("    d[12]=0x%08X d[13]=0x%08X d[14]=0x%08X d[15]=0x%08X\n",
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+12),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+13),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+14),
                  CPS_UncachedRead32((uint32_t *)((CEDI_PdVar(rxQueue[qNum]).rxBufVAddr)[i])+15));
      }
#endif
      thisVP++;
  }
  //cInst->printf("\n");
#endif  // EDD_DBG_LOG
}

void printRxVAddrList(cddcOp *cInst, void *pD, uint8_t qNum)
{
#ifdef EDD_DBG_LOG
  uint32_t i;
  uintptr_t *thisVP = CEDI_PdVar(rxQueue[qNum]).rxBufVAddr;

  cInst->printf("---  Rx Buffer Virtual Addresses List Queue %u  ---\n", qNum);
  for (i=0; i<=(CEDI_PdVar(cfg).rxQLen)[qNum]; i++) {
      cInst->printf("d%3u  virt: %08X  %s\n", i,
              (CEDI_PdVar(rxQueue[qNum].rxBufVAddr)[i]),
              (thisVP==(CEDI_PdVar(rxQueue[qNum]).rxTailVA))?"<-tail":"");
      thisVP++;
  }
#endif
}

void printNetControlReg(cddcOp *cInst, void *pD)
{
  uint32_t reg = CPS_UncachedRead32(CEDI_RegAddr(network_control));

  cInst->printf("\nNetCtrlReg (regBase %08X) - loop:%u lbkloc:%u rxEn:%u txEn:%u mdioEn:%u "\
          "wrStat:%u bPres:%u\n               rdSnap:%u rxTStmp:%u enRxPfc:%u enLpi:%u"\
          " uniPtp:%u altSgmii:%u wrUdpOff:%u extTsu:%u oneStepSync:%u pfcCtrl:%u\n",
          CEDI_PdVar(cfg).regBase,
          EMAC_REGS__NETWORK_CONTROL__LOOPBACK__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__LOOPBACK_LOCAL__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__ENABLE_RECEIVE__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__ENABLE_TRANSMIT__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__MAN_PORT_EN__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__STATS_WRITE_EN__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__BACK_PRESSURE__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__STATS_READ_SNAP__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__STORE_RX_TS__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__PFC_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__TX_LPI_EN__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__PTP_UNICAST_ENA__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__ALT_SGMII_MODE__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__STORE_UDP_OFFSET__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__EXT_TSU_PORT_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__ONE_STEP_SYNC_MODE__READ(reg),
          EMAC_REGS__NETWORK_CONTROL__PFC_CTRL__READ(reg));
}

void printNetConfigReg(cddcOp *cInst, void *pD)
{
  uint32_t reg = CPS_UncachedRead32(CEDI_RegAddr(network_config));

  cInst->printf("\nNetwork Config Reg (regBase %08X)-\n"\
          "         speed:%7s  fulldup:%u      vlanOnly:%u         jumbo:%u\n"\
          "       copyAll:%u        noBroad:%u       multiEn:%u     unicastEn:%u\n"\
          "        rx1536:%u       extAddEn:%u    gigabit_En:%u        pcsSel:%u\n"\
          "     retryTest:%u        pauseEn:%u     rxBufOffs:%u  rxLenErrDisc:%u\n"\
          "     fcsRemove:%u      mdcClkDiv:%u     dBusWidth:%u  disCopyPause:%u\n"\
          "    rxChkOffEn:%u  rxHalfDupTxEn:%u   ignoreRxCrc:%u       sgmiiEn:%u\n"\
          "    ipgStretch:%u  rxBadPreamble:%u  ignoreIpgErr:%u      uniDirEn:%u\n",
          CEDI_PdVar(cfg).regBase,
          EMAC_REGS__NETWORK_CONFIG__SPEED__READ(reg)?"100Mbps":"10Mbps ",
          EMAC_REGS__NETWORK_CONFIG__FULL_DUPLEX__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__DISCARD_NON_VLAN_FRAMES__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__JUMBO_FRAMES__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__COPY_ALL_FRAMES__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__NO_BROADCAST__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__MULTICAST_HASH_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__UNICAST_HASH_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__RECEIVE_1536_BYTE_FRAMES__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__EXTERNAL_ADDRESS_MATCH_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__GIGABIT_MODE_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__PCS_SELECT__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__RETRY_TEST__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__PAUSE_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__RECEIVE_BUFFER_OFFSET__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__LENGTH_FIELD_ERROR_FRAME_DISCARD__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__FCS_REMOVE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__MDC_CLOCK_DIVISION__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__DATA_BUS_WIDTH__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__DISABLE_COPY_OF_PAUSE_FRAMES__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__RECEIVE_CHECKSUM_OFFLOAD_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__EN_HALF_DUPLEX_RX__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__IGNORE_RX_FCS__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__SGMII_MODE_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__IPG_STRETCH_ENABLE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__NSP_CHANGE__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__IGNORE_IPG_RX_ER__READ(reg),
          EMAC_REGS__NETWORK_CONFIG__UNI_DIRECTION_ENABLE__READ(reg)
          );
}


void printNetStatusReg(cddcOp *cInst, void *pD)
{
  uint32_t reg = CPS_UncachedRead32(CEDI_RegAddr(network_status));

  cInst->printf("\nNetwork Status Reg = %08X\n", reg);
}

void printDmaConfigReg(cddcOp *cInst, void *pD)
{
  uint32_t reg = CPS_UncachedRead32(CEDI_RegAddr(dma_config));

  cInst->printf("\nDMA Config Reg = %08X\n", reg);
}

void printTxStatus(cddcOp *cInst, uint8_t emacInst)
{
    uint32_t reg = CPS_UncachedRead32(regAddr(emacInst, transmit_status));
    if (!reg)
        cInst->printf("MAC%u TxStatus = (all clear)\n", emacInst);
    else {
        cInst->printf("MAC%u TxStatus: %s %s %s %s %s %s %s %s %s\n",
                emacInst,
                EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_COMPLETE__READ(reg)?"txFrComplete":"",
                EMAC_REGS__TRANSMIT_STATUS__USED_BIT_READ__READ(reg)?"usedRead":"",
                EMAC_REGS__TRANSMIT_STATUS__COLLISION_OCCURRED__READ(reg)?"collision":"",
                EMAC_REGS__TRANSMIT_STATUS__RETRY_LIMIT_EXCEEDED__READ(reg)?"retryExceeded":"",
                EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_GO__READ(reg)?"txActive":"",
                EMAC_REGS__TRANSMIT_STATUS__AMBA_ERROR__READ(reg)?"frameErr":"",
                EMAC_REGS__TRANSMIT_STATUS__TRANSMIT_UNDER_RUN__READ(reg)?"txUnderrun":"",
                EMAC_REGS__TRANSMIT_STATUS__LATE_COLLISION_OCCURRED__READ(reg)?"lateColl":"",
                EMAC_REGS__TRANSMIT_STATUS__RESP_NOT_OK__READ(reg)?"HrespNotOk":"");
    }
}

void printRxStatus(cddcOp *cInst, uint8_t emacInst)
{
    CEDI_RxStatus rxStatus;
    uint32_t set = emacObj[emacInst]->getRxStatus(privData[emacInst], &rxStatus);
    if (!set)
        cInst->printf("MAC%u RxStatus = (all clear)\n", emacInst);
    else
        cInst->printf("MAC%u RxStatus = %s %s %s %s\n",
            emacInst,
            rxStatus.buffNotAvail?"bufNotAvail":"",
            rxStatus.frameRx?"rxFrame":"",
            rxStatus.rxOverrun?"rxOverrun":"",
            rxStatus.hRespNotOk?"HrespNotOk":"");
}

void printDesignCfg(cddcOp *cInst, void *pD)
{
  /* just print registers now - later compare with
   * copied data for testing */
  uint32_t reg;

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug1));
  cInst->printf("\nDesign Config Reg 1 - %08X\n", reg);
  cInst->printf("   no_pcs:%u",
          EMAC_REGS__DESIGNCFG_DEBUG1__NO_PCS__READ(reg));
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__SERDES__READ
  cInst->printf("  serdes:%u  RDC_50:%u  TDC_50:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__SERDES__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__RDC_50__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__TDC_50__READ(reg));
#endif
  cInst->printf("   int_loopback:%u  ext_fifo_interface:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__INT_LOOPBACK__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__EXT_FIFO_INTERFACE__READ(reg));
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__NO_INT_LOOPBACK__READ
  cInst->printf("   no_int_loopback:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__NO_INT_LOOPBACK__READ(reg));
#endif
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__APB_REV1__READ
  cInst->printf("   apb_rev1:%u  apb_rev2:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__APB_REV1__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__APB_REV2__READ(reg));
#endif
  cInst->printf("   user_io:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__USER_IO__READ(reg));
  cInst->printf("   user_out_width:%u  user_in_width:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__USER_OUT_WIDTH__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__USER_IN_WIDTH__READ(reg));
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__NO_SCAN_PINS__READ
  cInst->printf("   no_scan_pins:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__NO_SCAN_PINS__READ(reg));
#endif
  cInst->printf("   no_stats:%u  no_snapshot:%u  irq_read_clear:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__NO_STATS__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__NO_SNAPSHOT__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__IRQ_READ_CLEAR__READ(reg));
#ifdef EMAC_REGS__DESIGNCFG_DEBUG1__EXCLUDE_CBS__READ
  cInst->printf("   exclude_cbs:%u  dma_bus_width:%u  axi_cache_value:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__EXCLUDE_CBS__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__DMA_BUS_WIDTH__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__AXI_CACHE_VALUE__READ(reg));
#else
  cInst->printf("   dma_bus_width:%u  axi_cache_value:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG1__DMA_BUS_WIDTH__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG1__AXI_CACHE_VALUE__READ(reg));
#endif
  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug2));
  cInst->printf("Design Config Reg 2 - %08X\n", reg);
  cInst->printf("   jumbo_max_length:%u  hprot_value:%u  :%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG2__JUMBO_MAX_LENGTH__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG2__HPROT_VALUE__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG2__RX_PKT_BUFFER__READ(reg));
  cInst->printf("   tx_pkt_buffer:%u  rx_pbuf_addr:%u  tx_pbuf_addr:%u  axi:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG2__TX_PKT_BUFFER__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG2__RX_PBUF_ADDR__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG2__TX_PBUF_ADDR__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG2__AXI__READ(reg));

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug3));
  cInst->printf("Design Config Reg 3 - %08X\n", reg);
  cInst->printf("   num_spec_add_filters:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG3__NUM_SPEC_ADD_FILTERS__READ(reg));

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug4));
  cInst->printf("Design Config Reg 4 - %08X\n", reg);

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug5));
  cInst->printf("Design Config Reg 5 - %08X\n", reg);
  cInst->printf("   rx_fifo_cnt_width:%u  tx_fifo_cnt_width:%u  tsu:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG5__RX_FIFO_CNT_WIDTH__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG5__TX_FIFO_CNT_WIDTH__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG5__TSU__READ(reg));
  cInst->printf("   phy_ident:%u  dma_bus_width_def:%u  mdc_clock_div:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG5__PHY_IDENT__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG5__DMA_BUS_WIDTH_DEF__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG5__MDC_CLOCK_DIV__READ(reg));
  cInst->printf("   endian_swap_def:%u  rx_pbuf_size_def:%u  tx_pbuf_size_def:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG5__ENDIAN_SWAP_DEF__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG5__RX_PBUF_SIZE_DEF__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG5__TX_PBUF_SIZE_DEF__READ(reg));
  cInst->printf("   rx_buffer_length_def:%u  tsu_clk:%u  axi_prot_value:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG5__RX_BUFFER_LENGTH_DEF__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG5__TSU_CLK__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG5__AXI_PROT_VALUE__READ(reg));

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug6));
  cInst->printf("Design Config Reg 6 - %08X\n", reg);
  cInst->printf("   dma_priority_queue1:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE1__READ(reg));
  cInst->printf("   dma_priority_queue2:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE2__READ(reg));
  cInst->printf("   dma_priority_queue3:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE3__READ(reg));
  cInst->printf("   dma_priority_queue4:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE4__READ(reg));
  cInst->printf("   dma_priority_queue5:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE5__READ(reg));
  cInst->printf("   dma_priority_queue6:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE6__READ(reg));
  cInst->printf("   dma_priority_queue7:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE7__READ(reg));
  cInst->printf("   dma_priority_queue8:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE8__READ(reg));
  cInst->printf("   dma_priority_queue9:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE9__READ(reg));
  cInst->printf("   dma_priority_queue10:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE10__READ(reg));
  cInst->printf("   dma_priority_queue11:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE11__READ(reg));
  cInst->printf("   dma_priority_queue12:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE12__READ(reg));
  cInst->printf("   dma_priority_queue13:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE13__READ(reg));
  cInst->printf("   dma_priority_queue14:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE14__READ(reg));
  cInst->printf("   dma_priority_queue15:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_PRIORITY_QUEUE15__READ(reg));
  cInst->printf("   tx_pbuf_queue_segment_size:%u\n",
            EMAC_REGS__DESIGNCFG_DEBUG6__TX_PBUF_QUEUE_SEGMENT_SIZE__READ(reg));
  cInst->printf("   ext_tsu_timer:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__EXT_TSU_TIMER__READ(reg));
  cInst->printf("   tx_add_fifo_if:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__TX_ADD_FIFO_IF__READ(reg));
  cInst->printf("   host_if_soft_select:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__HOST_IF_SOFT_SELECT__READ(reg));
  cInst->printf("   emac_dma_addr_width_is_64b:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__DMA_ADDR_WIDTH_IS_64B__READ(reg));
  cInst->printf("   pfc_multi_quantum:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__PFC_MULTI_QUANTUM__READ(reg));
  cInst->printf("   pbuf_lso:0  ");
  cInst->printf("pbuf_rsc:0  ");
  cInst->printf("intrpt_mod:%u  hdr_split:%u\n",
                  CEDI_PdVar(hwCfg).intrpt_mod, CEDI_PdVar(hwCfg).hdr_split);
  cInst->printf("   pbuf_cutthru:%u\n", EMAC_REGS__DESIGNCFG_DEBUG6__PBUF_CUTTHRU__READ(reg));

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug7));
  cInst->printf("Design Config Reg 7 - %08X\n", reg);
  cInst->printf("   tx_pbuf_num_segments_q0:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q0__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q1:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q1__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q2:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q2__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q3:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q3__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q4:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q4__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q5:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q5__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q6:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q6__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q7:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG7__TX_PBUF_NUM_SEGMENTS_Q7__READ(reg));

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug8));
  cInst->printf("Design Config Reg 8 - %08X\n", reg);
  cInst->printf("   num_type1_screeners:%u  num_type2_screeners:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG8__NUM_TYPE1_SCREENERS__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG8__NUM_TYPE2_SCREENERS__READ(reg));
  cInst->printf("   num_scr2_ethtype_regs:%u  num_scr2_compare_regs:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG8__NUM_SCR2_ETHTYPE_REGS__READ(reg),
          EMAC_REGS__DESIGNCFG_DEBUG8__NUM_SCR2_COMPARE_REGS__READ(reg));

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug9));
  cInst->printf("Design Config Reg 9 - %08X\n", reg);
  cInst->printf("   tx_pbuf_num_segments_q8:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q8__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q9:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q9__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q10:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q10__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q11:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q11__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q12:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q12__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q13:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q13__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q14:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q14__READ(reg));
  cInst->printf("   tx_pbuf_num_segments_q15:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG9__TX_PBUF_NUM_SEGMENTS_Q15__READ(reg));

  reg = CPS_UncachedRead32(CEDI_RegAddr(designcfg_debug10));
  cInst->printf("Design Config Reg 10 - %08X\n", reg);
  cInst->printf("   axi_rx_descr_wr_buff_bits:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG10__AXI_RX_DESCR_WR_BUFF_BITS__READ(reg));
  cInst->printf("   axi_tx_descr_wr_buff_bits:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG10__AXI_TX_DESCR_WR_BUFF_BITS__READ(reg));
  cInst->printf("   axi_rx_descr_rd_buff_bits:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG10__AXI_RX_DESCR_RD_BUFF_BITS__READ(reg));
  cInst->printf("   axi_tx_descr_rd_buff_bits:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG10__AXI_TX_DESCR_RD_BUFF_BITS__READ(reg));
  cInst->printf("   axi_access_pipeline_bits:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG10__AXI_ACCESS_PIPELINE_BITS__READ(reg));
  cInst->printf("   rx_pbuf_data:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG10__RX_PBUF_DATA__READ(reg));
  cInst->printf("   tx_pbuf_data:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG10__TX_PBUF_DATA__READ(reg));
  cInst->printf("   emac_bus_width:%u\n",
          EMAC_REGS__DESIGNCFG_DEBUG10__EMAC_BUS_WIDTH__READ(reg));
}

void printStatsCopy(cddcOp *cInst, void *pD)
{
    cInst->printf("\nStatistics regs copy (MAC%u)-\n"\
            "          octetsTx:  0x%08X %08X\n"\
            "          framesTx:%3u        broadcastTx:%u         multicastTx:%u           pauseFrTx:%u  \n"\
            "        fr64byteTx:%u       fr65_127byteTx:%u     fr128_255byteTx:%u     fr256_511byteTx:%u\n"\
            "  fr512_1023byteTx:%u    fr1024_1518byteTx:%u       fr1519_byteTx:%u        underrunFrTx:%u\n"\
            "    singleCollFrTx:%u        multiCollFrTx:%u      excessCollFrTx:%u        lateCollFrTx:%u\n"\
            "      deferredFrTx:%u       carrSensErrsTx:%u\n"\
            "          octetsRx:  0x%08X %08X\n"\
            "          framesRx:%3u        broadcastRx:%u         multicastRx:%u           pauseFrRx:%u  \n"\
            "        fr64byteRx:%u       fr65_127byteRx:%u     fr128_255byteRx:%u     fr256_511byteRx:%u\n"\
            "  fr512_1023byteRx:%u    fr1024_1518byteRx:%u       fr1519_byteRx:%u       undersizeFrRx:%u\n"\
            "      oversizeFrRx:%u            jabbersRx:%u         fcsErrorsRx:%u         lenChkErrRx:%u\n"\
            "      rxSymbolErrs:%u          alignErrsRx:%u       rxResourcErrs:%u         overrunFrRx:%u\n"\
            "      ipChksumErrs:%u        tcpChksumErrs:%u       udpChksumErrs:%u      dmaRxPBufFlush:%u\n",
        (CEDI_PdVar(cfg).regBase==(uintptr_t)emac_reg_base[0])?0:1,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->octetsTxHi,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->octetsTxLo,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->framesTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->broadcastTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->multicastTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->pauseFrTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr64byteTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr65_127byteTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr128_255byteTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr256_511byteTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr512_1023byteTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr1024_1518byteTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr1519_byteTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->underrunFrTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->singleCollFrTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->multiCollFrTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->excessCollFrTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->lateCollFrTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->deferredFrTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->carrSensErrsTx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->octetsRxHi,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->octetsRxLo,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->framesRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->broadcastRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->multicastRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->pauseFrRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr64byteRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr65_127byteRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr128_255byteRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr256_511byteRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr512_1023byteRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr1024_1518byteRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fr1519_byteRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->undersizeFrRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->oversizeFrRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->jabbersRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->fcsErrorsRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->lenChkErrRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->rxSymbolErrs,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->alignErrsRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->rxResourcErrs,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->overrunFrRx,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->ipChksumErrs,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->tcpChksumErrs,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->udpChksumErrs,
        ((CEDI_Statistics *)CEDI_PdVar(cfg).statsRegs)->dmaRxPBufFlush );
}

void zeroCallbackCounters(void) {
    uint32_t i, q;
    for (i=0; i<2; i++) {
        phyManCompleteCount[i] = 0;
        oldPhyManCompleteCount[i] = 0;
        mdioReadData[i] = 0;
        txUsedRead[i] = 0;
        oldTxUsedRead[i] = 0;
        txUnderrun[i] = 0;
        oldTxUnderrun[i] = 0;
        rxPauseFrNonZQ[i] = 0;
        oldRxPauseFrNonZQ[i] = 0;
        pauseTimeZero[i] = 0;
        oldPauseTimeZero[i] = 0;
        txPauseFr[i] = 0;
        oldTxPauseFr[i] = 0;
        ptpTxSyncFr[i] = 0;
        oldPtpTxSyncFr[i] = 0;
        ptpTxDelayReqFr[i] = 0;
        oldPtpTxDelayReqFr[i] = 0;
        ptpRxSyncFr[i] = 0;
        oldPtpRxSyncFr[i] = 0;
        ptpRxDelayReqFr[i] = 0;
        oldPtpRxDelayReqFr[i] = 0;
        ptpTxPDelReqFr[i] = 0;
        oldPtpTxPDelReqFr[i] = 0;
        ptpTxPDelRspFr[i] = 0;
        oldPtpTxPDelRspFr[i] = 0;
        ptpRxPDelReqFr[i] = 0;
        oldPtpRxPDelReqFr[i] = 0;
        ptpRxPDelRspFr[i] = 0;
        oldPtpRxPDelRspFr[i] = 0;
        tsuSecsInc[i] = 0;
        oldTsuSecsInc[i] = 0;
        tsuTimeMatch[i] = 0;
        oldTsuTimeMatch[i] = 0;
        pcsAnPageRx[i] = 0;
        oldPcsAnPageRx[i] = 0;
        memset(&pcsAnLpPage[i], 0, sizeof(CEDI_LpPageRx));
        pcsAnComplete[i] = 0;
        oldPcsAnComplete[i] = 0;
        memset(&pcsNetStat[i], 0, sizeof(CEDI_NetAnStatus));
        pcsLinkChange[i] = 0;
        oldPcsLinkChange[i] = 0;
        pcsLinkState[i] = 0;
        lpiIndChange[i] = 0;
        oldLpiIndChange[i] = 0;
        wakeOnLanEvent[i] = 0;
        oldWakeOnLanEvent[i] = 0;
        extInputEvent[i] = 0;
        oldExtInputEvent[i] = 0;
        EccRxNcrr[i] = 0;
        EccTxNcrr[i] = 0;
        for (q=0; q<CEDI_MAX_TX_QUEUES; q++) {
            rxFrameCount[i][q] = 0;
            oldRxFrameCount[i][q] = 0;
            rxUsedRead[i][q] = 0;
            oldRxUsedRead[i][q] = 0;
            rxOverrun[i][q] = 0;
            oldRxOverrun[i][q] = 0;
            txFrComplete[i][q] = 0;
            oldTxFrComplete[i][q] = 0;
            txRetryExc[i][q] = 0;
            oldTxRetryExc[i][q] = 0;
            txFrCorr[i][q] = 0;
            oldTxFrCorr[i][q] = 0;
            hrespNotOk[i][q] = 0;
            oldHrespNotOk[i][q] = 0;
        }
    }
}

uint32_t detectCallback(cddcOp *cInst, uint8_t mac) {
    uint32_t q;
    uint8_t change = 0;

    if (phyManCompleteCount[mac]>oldPhyManCompleteCount[mac]) {
        oldPhyManCompleteCount[mac]++;
        change = 1;
        cInst->printf("--- MAC%u PHY Management Frame Sent cb counted\n", mac);
    }
    if (txUsedRead[mac]>oldTxUsedRead[mac]) {
        oldTxUsedRead[mac]++;
        change = 1;
        cInst->printf("--- MAC%u txUsedRead cb counted\n", mac);
    }
    if (txUnderrun[mac]>oldTxUnderrun[mac]) {
        oldTxUnderrun[mac]++;
        change = 1;
        cInst->printf("--- MAC%u txUnderrun cb counted\n", mac);
    }
    if (rxPauseFrNonZQ[mac]>oldRxPauseFrNonZQ[mac]) {
        oldRxPauseFrNonZQ[mac]++;
        change = 1;
        cInst->printf("--- MAC%u rxPauseFrNonZeroQuantum cb counted\n", mac);
    }
    if (pauseTimeZero[mac]>oldPauseTimeZero[mac]) {
        oldPauseTimeZero[mac]++;
        change = 1;
        cInst->printf("--- MAC%u pauseTimeZero cb counted\n", mac);
    }
    if (txPauseFr[mac]>oldTxPauseFr[mac]) {
        oldTxPauseFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u txPauseFr cb counted\n", mac);
    }
    if (ptpTxSyncFr[mac]>oldPtpTxSyncFr[mac]) {
        oldPtpTxSyncFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u ptpTxSyncFr cb counted\n", mac);
    }
    if (ptpTxDelayReqFr[mac]>oldPtpTxDelayReqFr[mac]) {
        oldPtpTxDelayReqFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u ptpTxDelayReqFr cb counted\n", mac);
    }
    if (ptpRxSyncFr[mac]>oldPtpRxSyncFr[mac]) {
        oldPtpRxSyncFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u ptpRxSyncFr cb counted\n", mac);
    }
    if (ptpRxDelayReqFr[mac]>oldPtpRxDelayReqFr[mac]) {
        oldPtpRxDelayReqFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u ptpRxDelayReqFr cb counted\n", mac);
    }
    if (ptpTxPDelReqFr[mac]>oldPtpTxPDelReqFr[mac]) {
        oldPtpTxPDelReqFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u ptpTxPDelayReqFr cb counted\n", mac);
    }
    if (ptpTxPDelRspFr[mac]>oldPtpTxPDelRspFr[mac]) {
        oldPtpTxPDelRspFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u ptpTxPDelayRespFr cb counted\n", mac);
    }
    if (ptpRxPDelReqFr[mac]>oldPtpRxPDelReqFr[mac]) {
        oldPtpRxPDelReqFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u ptpRxPDelayReqFr cb counted\n", mac);
    }
    if (ptpRxPDelRspFr[mac]>oldPtpRxPDelRspFr[mac]) {
        oldPtpRxPDelRspFr[mac]++;
        change = 1;
        cInst->printf("--- MAC%u ptpRxPDelayRespFr cb counted\n", mac);
    }
    if (tsuSecsInc[mac]>oldTsuSecsInc[mac]) {
        oldTsuSecsInc[mac]++;
        change = 1;
        cInst->printf("--- MAC%u tsuSecsInc cb counted\n", mac);
    }
    if (tsuTimeMatch[mac]>oldTsuTimeMatch[mac]) {
        oldTsuTimeMatch[mac]++;
        change = 1;
        cInst->printf("--- MAC%u tsuTimeMatch cb counted\n", mac);
    }
    if (pcsAnPageRx[mac]>oldPcsAnPageRx[mac]) {
        oldPcsAnPageRx[mac]++;
        change = 1;
        cInst->printf("--- MAC%u pcsAnPageRx cb counted\n", mac);
    }
    if (pcsAnComplete[mac]>oldPcsAnComplete[mac]) {
        oldPcsAnComplete[mac]++;
        change = 1;
        cInst->printf("--- MAC%u pcsAnComplete cb counted\n", mac);
    }
    if (pcsLinkChange[mac]>oldPcsLinkChange[mac]) {
        oldPcsLinkChange[mac]++;
        change = 1;
        cInst->printf("--- MAC%u pcsLinkChange cb counted\n", mac);
    }
    if (lpiIndChange[mac]>oldLpiIndChange[mac]) {
        oldLpiIndChange[mac]++;
        change = 1;
        cInst->printf("--- MAC%u lpiIndChange cb counted\n", mac);
    }
    if (wakeOnLanEvent[mac]>oldWakeOnLanEvent[mac]) {
        oldWakeOnLanEvent[mac]++;
        change = 1;
        cInst->printf("--- MAC%u wakeOnLanEvent cb counted\n", mac);
    }
    if (extInputEvent[mac]>oldExtInputEvent[mac]) {
        oldExtInputEvent[mac]++;
        change = 1;
        cInst->printf("--- MAC%u extInputEvent cb counted\n", mac);
    }

    for (q=0; q<privData[mac]->numQs; q++) {
        if (rxFrameCount[mac][q]>oldRxFrameCount[mac][q]) {
            change = 1;
            oldRxFrameCount[mac][q]++;
            cInst->printf("--- MAC%u rxFrame cb counted, q=%u\n", mac, q);
        }
        if (rxUsedRead[mac][q]>oldRxUsedRead[mac][q]) {
            oldRxUsedRead[mac][q]++;
            change = 1;
            cInst->printf("--- MAC%u rxUsedRead cb counted, q=%u\n", mac, q);
        }
        if (rxOverrun[mac][q]>oldRxOverrun[mac][q]) {
            oldRxOverrun[mac][q]++;
            change = 1;
            cInst->printf("--- MAC%u rxOverrun cb counted, q=%u\n", mac, q);
        }
        if (txFrComplete[mac][q]>oldTxFrComplete[mac][q]) {
            oldTxFrComplete[mac][q]++;
            change = 1;
            cInst->printf("--- MAC%u txFrComplete cb counted, q=%u\n", mac, q);
        }
        if (txRetryExc[mac][q]>oldTxRetryExc[mac][q]) {
            oldTxRetryExc[mac][q]++;
            change = 1;
            cInst->printf("--- MAC%u txRetryExc cb counted, q=%u\n", mac, q);
        }
        if (txFrCorr[mac][q]>oldTxFrCorr[mac][q]) {
            oldTxFrCorr[mac][q]++;
            change = 1;
            cInst->printf("--- MAC%u txFrCorr cb counted, q=%u\n", mac, q);
        }
        if (hrespNotOk[mac][q]>oldHrespNotOk[mac][q]) {
            oldHrespNotOk[mac][q]++;
            change = 1;
            cInst->printf("--- MAC%u hresp not OK cb counted, q=%u\n", mac, q);
        }
    }
    return change;
}

/* allocate a kernel buffer, fill with an incrementing data pattern and return
 * virtual & physical addresses */
uint32_t allocBuffer(uint32_t bytes, uint32_t fill, CEDI_BuffAddr *buf) {

    uint32_t tmp, blockLen;

    /* round up size to multiple of 32 bits */
    blockLen = 4*(bytes/4 + ((bytes%4)?1:0));

    if (!( buf->vAddr = (uintptr_t)malloc(blockLen)))
        return 1;
//    printf("### allocBuffer reserves ###  %u bytes  @ %08X\n", blockLen, buf->vAddr);

    /* get the physical buffer address */
    CPS_WritePhysAddress32((uint32_t *)buf->vAddr, buf->vAddr);
    buf->pAddr = CPS_UncachedRead32((uint32_t *)buf->vAddr);

    /* --> remove the pattern-filling to speed up regression testing... */
    for (tmp=0; tmp<bytes; tmp+=4)
        CPS_UncachedWrite32((uint32_t *)(buf->vAddr+tmp), fill+tmp); // use pattern for debugging

    return 0;
}

/***********************************************************************
 * MAC Interrupt callbacks
 **********************************************************************/

/**
 * An MDIO operation completed.
 * @param   pD      Pointer to core private data
 * @param   read        read/write flag (1=read)
 * @param   readData    data read, if read==1
 */
static void _ev_phyManComplete(void *pD,
        uint8_t read, uint16_t readData) {
    phyManCompleteCount[EMAC_NUM(pD)]++;
    if (read==1)
        mdioReadData[EMAC_NUM(pD)] = 0x80000000 | readData;
}

/**
 * Frame Received interrupt occurred.
 * @param   pD      Pointer to core private data
 * @param   queueNum    Number of the RX queue.
 */
static void _ev_rxFrame(void *pD, uint8_t queueNum) {
    rxFrameCount[EMAC_NUM(pD)][queueNum]++;
    if (rxTiming) {
        /* record Rx delay from tx frame complete */
        /* do double-read to avoid clock-sync problem */
        emacObj[timerMac]->get1588Timer(privData[timerMac],
                                &timeRxFrame);
        emacObj[timerMac]->get1588Timer(privData[timerMac],
                                &timeRxFrame);
        rxDelay = (timeRxFrame.nanosecs - startRx.nanosecs);
        if (rxDelay<0) rxDelay += NS_PER_SEC;
        rxDelay += (timeRxFrame.secsLower - startRx.secsLower);
        rxTiming = 0;   /* ready to restart timing */
    }
}

/**
 * Frame Rx Error interrupt occurred.
 * @param   pD      Pointer to core private data
 * @param   error       Error type:
 *  CEDI_EV_RX_USED_READ - Descriptor ring full
 *  CEDI_EV_RX_OVERRUN   - Rx Overrun
 * @param   queueNum    RX queue index
 */
static void _ev_rxError(void *pD, uint32_t error, uint8_t queueNum) {
    if (error & CEDI_EV_RX_USED_READ) rxUsedRead[EMAC_NUM(pD)][queueNum]++;
    if (error & CEDI_EV_RX_OVERRUN) rxOverrun[EMAC_NUM(pD)][queueNum]++;
}

/**
 * Transmit event occurred
 * @param   pD      Pointer to core private data
 * @param   event       Event mask containing:
 *  CEDI_EV_TX_COMPLETE  - Frame transmitted successfully
 *  CEDI_EV_TX_USED_READ - Descriptor ring empty
 * @param   queueNum    Tx queue index
 */
static void _ev_txEvent(void *pD, uint32_t event, uint8_t queueNum) {
    //CEDI_1588TimerVal timer;
    if (event & CEDI_EV_TX_USED_READ) txUsedRead[EMAC_NUM(pD)]++;
    if (event & CEDI_EV_TX_COMPLETE) {
        txFrComplete[EMAC_NUM(pD)][queueNum]++;
        if (txTiming) {
            /* record Tx delay since queuing the frame */
            /* do double-read to avoid clock-sync problem */
            emacObj[timerMac]->get1588Timer(privData[timerMac],
                                        &timeTxComplete);
            emacObj[timerMac]->get1588Timer(privData[timerMac],
                                        &timeTxComplete);
            txDelay = (timeTxComplete.nanosecs - startTx.nanosecs);
            if (txDelay<0) txDelay += NS_PER_SEC;
            txDelay += (timeTxComplete.secsLower - startTx.secsLower);
            txTiming = 0;   /* ready to restart timing */
            if (!rxTiming) {
                startRx.nanosecs = timeTxComplete.nanosecs;
                startRx.secsLower = timeTxComplete.secsLower;
                rxTiming = 1;
            }
        }
    }
}

/**
 * Transmit error occurred
 * @param   pD      Pointer to core private data
 * @param   error       Error type:
 *  CEDI_EV_TX_UNDERRUN  - Tx underrun
 *  CEDI_EV_TX_RETRY_EX_LATE_COLL    - Retry limit exceeded
 *  CEDI_EV_TX_FR_CORRUPT        - Tx frame corruption
 * @param   queueNum    Tx queue index
 */
static void _ev_txError(void *pD, uint32_t error, uint8_t queueNum) {
    if (error & CEDI_EV_TX_UNDERRUN) txUnderrun[EMAC_NUM(pD)]++;
    if (error & CEDI_EV_TX_RETRY_EX_LATE_COLL)
        txRetryExc[EMAC_NUM(pD)][queueNum]++;
    if (error & CEDI_EV_TX_FR_CORRUPT) txFrCorr[EMAC_NUM(pD)][queueNum]++;
}

/**
 * A DMA Hresp not OK error has occurred
 * @param   pD          Pointer to core private data
 * @param   queueNum    queue index of Tx or Rx queue being accessed
 */
static void _ev_hrespError(void *pD, uint8_t queueNum) {
    hrespNotOk[EMAC_NUM(pD)][queueNum]++;
}

/**
 * PCS auto-negotiation page received
 * @param   pD      Pointer to core private data
 * @param   nextPage    Nonzero if not the last page
 * @param   pageRx      Struct containing the link partner base
 *              or next page data
 */
static void _ev_lpPageRx(void *pD, CEDI_LpPageRx *pageRx) {
    pcsAnPageRx[EMAC_NUM(pD)]++;
    memcpy(&pcsAnLpPage[EMAC_NUM(pD)], pageRx, sizeof(CEDI_LpPageRx));
}

/**
 * PCS auto-negotiation is complete
 * @param   pD      Pointer to core private data
 * @param   netStat     Struct containing link resolution status
 */
static void _ev_anComplete(void *pD, CEDI_NetAnStatus *netStat) {
    pcsAnComplete[EMAC_NUM(pD)]++;
    memcpy(&pcsNetStat[EMAC_NUM(pD)], netStat, sizeof(CEDI_NetAnStatus));
}

/**
 * PCS event detected
 * @param   pD      Pointer to core private data
 * @param   linkState   Link synchronization status.
 *              If auto-negotiation is enabled:
 *              0:  link is down
 *              <>0:    link is up
 *
 */
static void _ev_linkChange(void *pD, uint8_t linkState) {
    pcsLinkChange[EMAC_NUM(pD)]++;
    pcsLinkState[EMAC_NUM(pD)] = linkState;
}

/**
 * Time stamp unit event has occurred.
 * @param   pD      Pointer to core private data
 * @param   event       Event type:
 *  CEDI_EV_TSU_SEC_INC  - TSU seconds register increment
 *  CEDI_EV_TSU_TIME_MATCH   - TSU timer count match
 */
static void _ev_tsuEvent(void *pD, uint32_t event) {
    if (event & CEDI_EV_TSU_SEC_INC) tsuSecsInc[EMAC_NUM(pD)]++;
    if (event & CEDI_EV_TSU_TIME_MATCH) tsuTimeMatch[EMAC_NUM(pD)]++;
}

/**
 * Pause event detected
 * @param   pD      Pointer to core private data
 * @param   event       Event type:
 *  CEDI_EV_PAUSE_FRAME_TX   - Pause frame transmitted
 *  CEDI_EV_PAUSE_TIME_ZERO  - Pause time zero or zero quantum rx
 *  CEDI_EV_PAUSE_NZ_QU_RX   - Nonzero quantum received
 */
static void _ev_pauseEvent(void *pD, uint32_t event) {
    if (event & CEDI_EV_PAUSE_FRAME_TX) txPauseFr[EMAC_NUM(pD)]++;
    if (event & CEDI_EV_PAUSE_TIME_ZERO) pauseTimeZero[EMAC_NUM(pD)]++;
    if (event & CEDI_EV_PAUSE_NZ_QU_RX) rxPauseFrNonZQ[EMAC_NUM(pD)]++;
}

/**
 * PTP primary frame has been transmitted
 * @param   pD      Pointer to core private data
 * @param   frType      PTP frame type:
 *  CEDI_EV_PTP_TX_DLY_REQ   - Delay_req
 *  CEDI_EV_PTP_TX_SYNC      - Sync
 * @param   time        PTP timer value
 */
static void _ev_ptpPriFrameTx(void *pD,
        uint32_t frType,
        CEDI_1588TimerVal *time) {
    if (frType & CEDI_EV_PTP_TX_SYNC) ptpTxSyncFr[EMAC_NUM(pD)]++;
    if (frType & CEDI_EV_PTP_TX_DLY_REQ) ptpTxDelayReqFr[EMAC_NUM(pD)]++;

    ptpFrTime[EMAC_NUM(pD)].nanosecs = time->nanosecs;
    ptpFrTime[EMAC_NUM(pD)].secsLower = time->secsLower;
    ptpFrTime[EMAC_NUM(pD)].secsUpper = time->secsUpper;
}

/**
 * PTP peer frame has been transmitted
 * @param   pD      Pointer to core private data
 * @param   frType      PTP frame type:
 *  CEDI_EV_PTP_TX_PDLY_REQ  - Pdelay_req
 *  CEDI_EV_PTP_TX_PDLY_RSP  - Pdelay_resp
 * @param   time        PTP timer value
 */
static void _ev_ptpPeerFrameTx(void *pD,
        uint32_t frType,
        CEDI_1588TimerVal *time) {
    if (frType & CEDI_EV_PTP_TX_PDLY_REQ) ptpTxPDelReqFr[EMAC_NUM(pD)]++;
    if (frType & CEDI_EV_PTP_TX_PDLY_RSP) ptpTxPDelRspFr[EMAC_NUM(pD)]++;

    ptpFrTime[EMAC_NUM(pD)].nanosecs = time->nanosecs;
    ptpFrTime[EMAC_NUM(pD)].secsLower = time->secsLower;
    ptpFrTime[EMAC_NUM(pD)].secsUpper = time->secsUpper;
}

/**
 * PTP primary frame has been received
 * @param   pD      Pointer to core private data
 * @param   frType      PTP frame type:
 *  CEDI_EV_PTP_RX_DLY_REQ   - Delay_req
 *  CEDI_EV_PTP_RX_SYNC      - Sync
 * @param   time        PTP timer value
 */
static void _ev_ptpPriFrameRx(void *pD,
        uint32_t frType,
        CEDI_1588TimerVal *time) {
    if (frType & CEDI_EV_PTP_RX_SYNC) ptpRxSyncFr[EMAC_NUM(pD)]++;
    if (frType & CEDI_EV_PTP_RX_DLY_REQ) ptpRxDelayReqFr[EMAC_NUM(pD)]++;

    ptpFrTime[EMAC_NUM(pD)].nanosecs = time->nanosecs;
    ptpFrTime[EMAC_NUM(pD)].secsLower = time->secsLower;
    ptpFrTime[EMAC_NUM(pD)].secsUpper = time->secsUpper;
}

/**
 * PTP peer frame has been received
 * @param   pD      Pointer to core private data
 * @param   frType      PTP frame type:
 *  CEDI_EV_PTP_RX_PDLY_REQ  - Pdelay_req
 *  CEDI_EV_PTP_RX_PDLY_RSP  - Pdelay_resp
 * @param   time        PTP timer value
 */
static void _ev_ptpPeerFrameRx(void *pD,
        uint32_t frType,
        CEDI_1588TimerVal *time) {
    if (frType & CEDI_EV_PTP_RX_PDLY_REQ) ptpRxPDelReqFr[EMAC_NUM(pD)]++;
    if (frType & CEDI_EV_PTP_RX_PDLY_RSP) ptpRxPDelRspFr[EMAC_NUM(pD)]++;

    ptpFrTime[EMAC_NUM(pD)].nanosecs = time->nanosecs;
    ptpFrTime[EMAC_NUM(pD)].secsLower = time->secsLower;
    ptpFrTime[EMAC_NUM(pD)].secsUpper = time->secsUpper;
}

/**
 * LPI indication status bit has changed.
 * @param   pD      Pointer to core private data
 */
static void _ev_lpiStatus(void *pD) {
    lpiIndChange[EMAC_NUM(pD)]++;
}

/**
 * Wake on LAN event detected.
 * @param   pD      Pointer to core private data
 */
static void _ev_wolEvent(void *pD) {
    wakeOnLanEvent[EMAC_NUM(pD)]++;
}

/**
 * External Input Interrupt detected.
 * @param   pD      Pointer to core private data
 */
static void _ev_extInpIntr(void *pD) {
    extInputEvent[EMAC_NUM(pD)]++;
}


static void _ev_rasEvent(void *pD, uint32_t events) {
    if (events & CEDI_RAS_EV_ECC_RX_NCRR_ERR)
        EccRxNcrr[EMAC_NUM(pD)]++;
    if (events & CEDI_RAS_EV_ECC_TX_NCRR_ERR)
        EccTxNcrr[EMAC_NUM(pD)]++;
}

CEDI_Callbacks core_callbacks = {
    .phyManComplete     = _ev_phyManComplete,
    .rxFrame            = _ev_rxFrame,
    .rxError            = _ev_rxError,
    .txEvent            = _ev_txEvent,
    .txError            = _ev_txError,
    .hrespError         = _ev_hrespError,
    .lpPageRx           = _ev_lpPageRx,
    .anComplete         = _ev_anComplete,
    .linkChange         = _ev_linkChange,
    .tsuEvent           = _ev_tsuEvent,
    .pauseEvent         = _ev_pauseEvent,
    .ptpPriFrameTx      = _ev_ptpPriFrameTx,
    .ptpPeerFrameTx     = _ev_ptpPeerFrameTx,
    .ptpPriFrameRx      = _ev_ptpPriFrameRx,
    .ptpPeerFrameRx     = _ev_ptpPeerFrameRx,
    .lpiStatus          = _ev_lpiStatus,
    .wolEvent           = _ev_wolEvent,
    .extInpIntr         = _ev_extInpIntr,
    .rasEvent           = _ev_rasEvent,
};

/* fill up an CEDI_Config struct with common values for testing */
uint32_t initConfig(cddcOp *cInst, uint8_t objInst, uint16_t txQSize,
		uint16_t rxQSize, uint16_t rxBufLenBytes,
		uint32_t intrEvents, CEDI_Config *cfg)
{
    uint8_t i;
    uint8_t numQs;
    uint8_t dma_bus_width;
    uint32_t reg;
    int q;

    if ((cInst==NULL) || (objInst>1) || (cfg==NULL) ||
         (txQSize>CEDI_MAX_TBQ_LENGTH) || (rxQSize>CEDI_MAX_RBQ_LENGTH))
        return EINVAL;

    memset(cfg, 0, sizeof(CEDI_Config));
    numQs = cfgHwQs(objInst);

    cfg->regBase = (uintptr_t)emac_reg_base[objInst];
    cfg->rxQs = numQs;
    cfg->txQs = numQs;
    for (q=0; q<cfg->rxQs; q++) {
        cfg->rxQLen[q] = rxQSize;
    }

    for (q=0; q<cfg->txQs; q++) {
        cfg->txQLen[q] = txQSize;
    }

    for (i=0; i<cfg->rxQs; i++)
        cfg->rxBufLength[i] = rxBufLenBytes >> 6;

    // Configure the correct bus width depending on config debug registers
    reg = CPS_UncachedRead32(&(((struct emac_regs *)emac_reg_base[objInst])->designcfg_debug1));
    dma_bus_width = (reg & 0x0e000000U) >> 25;
    if(dma_bus_width == 1)
      cfg->dmaBusWidth = CEDI_DMA_BUS_WIDTH_32;
    else if (dma_bus_width == 2)
      cfg->dmaBusWidth = CEDI_DMA_BUS_WIDTH_64;
    else if (dma_bus_width == 4)
      cfg->dmaBusWidth = CEDI_DMA_BUS_WIDTH_128;
    //cInst->printf("[initConfig] reg = 0x%x | dma_bus_width = 0x%x | dmaBusWidth = %d", reg, dma_bus_width, cfg->dmaBusWidth);

    /* enable all Tx & Rx interrupts on start */
    cfg->intrEnable = intrEvents;
    cfg->rxPktBufSize = 3;
    cfg->txPktBufSize = 1;
    cfg->dmaDataBurstLen = CEDI_DMA_DBUR_LEN_4;
    cfg->dmaCfgFlags = 0;
    cfg->dmaAddrBusWidth = 0;
    cfg->enTxExtBD = 0;
    cfg->enRxExtBD = 0;
    cfg->aw2wMaxPipeline = 1;
    cfg->ar2rMaxPipeline = 1;
    cfg->pfcMultiQuantum = 0;
    cfg->enableMdio = 0;
    cfg->mdcPclkDiv = CEDI_MDC_DIV_BY_32;
    cfg->ifTypeSel = CEDI_IFSP_1000M_GMII;
//    cfg->ifTypeSel = CEDI_IFSP_1000BASE_X;
//    cfg->ifTypeSel = CEDI_IFSP_1000M_SGMII;
    cfg->altSgmiiEn = 0;
    cfg->fullDuplex = 1;
    cfg->enRxHalfDupTx = 0;
    cfg->extAddrMatch = 0;
    cfg->rxBufOffset = 0;
    cfg->rxLenErrDisc = 0;
    cfg->uniDirEnable = 0;
    cfg->disCopyPause = 0;
    cfg->chkSumOffEn = 0;
    cfg->rx1536ByteEn = 0;
    cfg->rxJumboFrEn = 0;
    cfg->enRxBadPreamble = 0;
    cfg->ignoreIpgRxEr = 0;
    cfg->storeUdpTcpOffset = 0;
    cfg->enExtTsuPort = 0;

    return 0;
}

/**
 * Function allocating required memory for the system.This function should be called
 * after a probe call.
 */
uint32_t allocSysReqMem(cddcOp *cInst, uint8_t objInst, CEDI_SysReq req,CEDI_Config *cfg )
{

    privData[objInst] = malloc(req.privDataSize);
	if (!privData[objInst]) {
		cInst->printf("Unable to allocate space for privData\n");
		return 1;
	}

   /* Allocate Rx descriptor ring */
	cfg->rxQAddr = (uintptr_t)malloc(req.rxDescListSize);
	if (!cfg->rxQAddr) {
		cInst->printf("Unable to allocate space for Rx descriptors\n");
		return 2;
	}

//    cInst->printf("Rx descriptor ring virt addr=%08X\n", cfg->rxQAddr);
    /* now get the physical address */
    CPS_WritePhysAddress32((uint32_t *)cfg->rxQAddr, cfg->rxQAddr);
    cfg->rxQPhyAddr = CPS_UncachedRead32((uint32_t *)cfg->rxQAddr);
//    cInst->printf("Rx descriptor ring phys addr=%08X\n", cfg->rxQPhyAddr);

    /* Allocate Tx descriptor ring */
    cfg->txQAddr = (uintptr_t)malloc(req.txDescListSize);
    if (!cfg->txQAddr) {
        cInst->printf("Unable to allocate space for Tx descriptors\n");
        return 3;
    }
//    cInst->printf("Tx descriptor ring virt addr=%08X\n", cfg->txQAddr);
    /* now get the physical address */
    CPS_WritePhysAddress32((uint32_t *)cfg->txQAddr, cfg->txQAddr);
    cfg->txQPhyAddr = CPS_UncachedRead32((uint32_t *)cfg->txQAddr);
//    cInst->printf("Tx descriptor ring phys addr=%08X\n", cfg->txQPhyAddr);

	statRegs[objInst] = (CEDI_Statistics *)malloc(req.statsSize);
	cfg->statsRegs = (uintptr_t)statRegs[objInst];

	return 0;
}

/**
 * Function calls Probe and init functions to provide inital setup for testcases.
 * Note: cfgPtr could be NULL, which means authorising testSetup to initialise CEDI_Config.
 */
uint32_t testSetup(cddcOp *cInst, uint8_t objInst, uint16_t txQSize,
		uint16_t rxQSize, uint16_t rxBufLenBytes, CEDI_Config *cfgPtr )
{
    uint32_t result;
    uint32_t eventsToEnable;

    CEDI_Config cfg;
    CEDI_SysReq req;

    emacObj[objInst] = CEDI_GetInstance();

    //cInst->printf("\n");

    if (cfgPtr==NULL) {
        memset(&cfg, 0, sizeof(cfg));

        eventsToEnable = CEDI_EVSET_TX_RX_EVENTS;

        /* setup default config */
        if (0 != (result = initConfig(cInst, objInst, txQSize, rxQSize,
                                        rxBufLenBytes, eventsToEnable, &cfg))) {
            cInst->printf("Error in initConfig: returned %d\n", result);
            return result;
        }
    }
    else {
        memcpy(&cfg,cfgPtr,sizeof(cfg));		// copy the additional cfg settings.
    }

    if (0 != (result = emacObj[objInst]->probe(&cfg, &req))) {
        cInst->printf("Invalid return value: %d\n", result);
        return result;
    }

	if (0 != (result = allocSysReqMem(cInst, objInst, req, &cfg))) {
		cInst->printf("Error in allocSysReqMem: returned %d\n", result);
		return result;
	}

	/* if PCS is present, must test using TBI as wrapper is configured differently
	 * (but don't override SGMII if that is selected) */
    if ((0==EMAC_REGS__DESIGNCFG_DEBUG1__NO_PCS__READ(CPS_UncachedRead32(
          &(((struct emac_regs *)emac_reg_base[objInst])->designcfg_debug1)))) &&
          ((cfg.ifTypeSel==CEDI_IFSP_10M_MII) || (cfg.ifTypeSel==CEDI_IFSP_100M_MII)
           || (cfg.ifTypeSel==CEDI_IFSP_1000M_GMII)))
        cfg.ifTypeSel = CEDI_IFSP_1000BASE_X;

    if (0 != (result = emacObj[objInst]->init(privData[objInst], &cfg, &core_callbacks))) {
        cInst->printf("Error in emacObj%u->init: returned %d\n", objInst, result);
        return result;
    }

    return 0;
}

void testTearDown(cddcOp *cInst, uint8_t objInst)
{
    emacObj[objInst]->destroy(privData[objInst]);

    if (privData[objInst])
        free(privData[objInst]);
    privData[objInst] = NULL;

    if (statRegs[objInst])
        free(statRegs[objInst]);
    statRegs[objInst] = NULL;
}

void loopDelay(uint32_t loops)
{
    int j;
    for (j=0; j<loops; j++)
        /* small delay by read to a global var */
        loopTDummy = (uint16_t)CPS_UncachedRead32(regAddr(0,revision_reg));
}

