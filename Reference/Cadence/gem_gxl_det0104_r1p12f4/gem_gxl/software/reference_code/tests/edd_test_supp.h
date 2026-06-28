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
 * edd_test_supp.h
 * Declarations for Ethernet MAC Driver test support functions
 *
 ***********************************************************************/
#ifndef _EDD_TEST_SUPP_H_
#define _EDD_TEST_SUPP_H_

#include <stdlib.h>
#include <string.h>
#include "cps.h"
#include "emac_regs.h"
#include "edd_int.h"
#include "cedi.h"
#include "edd_test_stubs.h"

/* macros depending on cfg, cInst, passed in local scope
 */
#define printFailed do {\
    cInst->printf("\n***  Test \"%s\" Failed  ***\n", __func__);\
  } while (0)

#define printSuccess do {\
    cInst->printf("\n***  Test \"%s\" Completed Successfully  ***\n", __func__);\
  } while (0)

#define printSkipped(reason) do {\
    cInst->printf("\n***  Test \"%s\" Completed  - Skipped because %s  ***\n", __func__, reason);\
  } while (0)

#define printNotSupp(reason) do {\
    cInst->printf("\n***  Test \"%s\" Completed  - Not supported: %s  ***\n", __func__, reason);\
  } while (0)


/* IP Base addresses - re-define as appropriate for your hardware platform */
#define EMAC_REG_BASE_ADDRESS0  0xfff30000
#define EMAC_REG_BASE_ADDRESS1  0xfff32000




#define RXQ_SIZE                (12)
#define TXQ_SIZE                (12)

/* Not a fixed limit - used for sizing test buffers */
#define MAX_TEST_RBQ_LENGTH (1000)


/* use test globals with this */
#define regAddr(gem, regname)  (&(privData[gem]->regs->regname))
#define eRegAddr(gem, regname) (&(eMacPrivData[gem]->regs->regname))

/**********************  Test support macros *********************************/

#define EMAC_NUM(pDat)    (((((CEDI_PrivateData *)pDat)->cfg).regBase)==(uintptr_t)emac_reg_base[0])?0:1

#define validateUint(val,exp,teststr,varstr) \
        do { if (val!=exp) { cInst->printf("***** Error %s - %s = %u, expected %u\n",\
                teststr, varstr, val, exp);\
                passed = 0;}} while(0);

#define validateXint(val,exp,teststr,varstr) \
        do { if (val!=exp) { cInst->printf("***** Error %s - %s = 0x%08X, expected 0x%08X\n",\
                teststr, varstr, val, exp);\
                passed = 0;}} while(0)

#define validateNUint(val,exp,teststr,varstr) \
        do { if (val==exp) { cInst->printf("***** Error %s - %s = %u, expected not equal to  %u\n",\
                teststr, varstr, val, exp);\
                passed = 0;}} while(0)

#define validatePtr(val,exp,teststr,varstr) \
        do { if (val!=exp) { cInst->printf("***** Error %s - %s = %p, expected %p\n",\
                teststr, varstr, val, exp);\
                passed = 0;}} while(0)

#define byte0(uint) (uint & 0xFF)
#define byte1(uint) ((uint & 0xFF00)>>8)
#define byte2(uint) ((uint & 0xFF0000)>>16)
#define byte3(uint) ((uint & 0xFF000000)>>24)

/* 32-bit word struct as bytes - MSByte first, ie. tx order */
typedef struct {
    uint8_t byte3;
    uint8_t byte2;
    uint8_t byte1;
    uint8_t byte0;
} word32b_t;

#define word32val(wd32b) ((wd32b.byte3<<24)+(wd32b.byte2<<16)+(wd32b.byte1<<8)+wd32b.byte0)


/* Ethernet frame structs */
/* simplest form, with Type/Len after source address */
typedef struct {
    CEDI_MacAddress dest;
    CEDI_MacAddress srce;
    uint8_t typeLenMsb;     /* ensure MSB-first format */
    uint8_t typeLenLsb;
} ethHdr_t;

/* VLan tag form, with VLAN tag after source address */
typedef struct {
    CEDI_MacAddress dest;
    CEDI_MacAddress srce;
    uint8_t vLanTpIdMsb;     /* ensure MSB-first format */
    uint8_t vLanTpIdLsb;
    uint8_t vLanTciMsb;
    uint8_t vLanTciLsb;
} ethHdr2_t;

/* Stacked VLan tag form, with two VLAN tags after source address */
typedef struct {
    CEDI_MacAddress dest;
    CEDI_MacAddress srce;
    uint8_t vLan1TpIdMsb;     /* ensure MSB-first format */
    uint8_t vLan1TpIdLsb;
    uint8_t vLan1TciMsb;
    uint8_t vLan1TciLsb;
    uint8_t vLan2TpIdMsb;
    uint8_t vLan2TpIdLsb;
    uint8_t vLan2TciMsb;
    uint8_t vLan2TciLsb;
} ethHdr3_t;

/** IPv4 address */
typedef struct {
    uint8_t byte[4];    /* byte[0] for first, i.e. top-level field */
} CEDI_IPv4Add;

/* IPv4 header */
typedef struct {
    uint8_t     ihlVers;    /* = 0x54 */
    uint8_t     dsCp;       /* lower 6 bits, ignoring ECN use of b6 & b7 */
    uint8_t     lengthMsb;  /* min 20 for header only */
    uint8_t     lengthLsb;
    uint16_t    iD;         /* identification */
    uint16_t    flgsFragOffset;
    uint8_t     ttL;
    uint8_t     prot;
    uint16_t    hdrChksum;
    CEDI_IPv4Add srcAddr;
    CEDI_IPv4Add dstAddr;
} iPv4Hdr_t;

/* UDP header */
typedef struct {
    uint8_t     srcPortMsb;    /* source port number */
    uint8_t     srcPortLsb;
    uint8_t     dstPortMsb;    /* destination port number */
    uint8_t     dstPortLsb;
    uint8_t     lengthMsb;     /* length inc. header */
    uint8_t     lengthLsb;
    uint8_t     chkSumMsb;     /* CRC of header+data */
    uint8_t     chkSumLsb;
} udpHdr_t;

#pragma pack(push,1)    /* ensure byte-alignment for fields */
/* PTP frame, IPv4, 1588 v1 */
typedef struct {
    /* ethernet header */
    CEDI_MacAddress dest;       /* bytes 0-5 */
    CEDI_MacAddress srce;       /* bytes 6-11 */
    uint8_t     typeLenMsb;     /* MSB = 0x08 */
    uint8_t     typeLenLsb;     /* LSB = 0x00 */
    /* IP header */
    uint8_t     ihlVers;        /* = 0x45     byte 14 */
    uint8_t     dsCp;           /* byte 15 */
    uint8_t     lengthMsb;      /* byte 16 */
    uint8_t     lengthLsb;      /* byte 17 */
    uint16_t    iD;             /* bytes 18-19 */
    uint16_t    flgsFragOffset; /* bytes 20-21 */
    uint8_t     ttL;            /* byte 22 */
    uint8_t     prot;           /* = 0x11, UDP   byte 23 */
    uint8_t     hdrChksum[2];   /* bytes 24-25 */
    CEDI_IPv4Add srcAddr;       /* bytes 26-29 */
    CEDI_IPv4Add dstAddr;       /* = 0xE0000181/82/83/84) bytes 30-33 */
    /* UDP header */
    uint8_t     srcPortMsb;     /* source port number   byte 34 */
    uint8_t     srcPortLsb;     /* byte 35 */
    uint8_t     dstPortMsb;     /* = 0x01   destination port number   byte 36 */
    uint8_t     dstPortLsb;     /* = 0x3F      byte 37 */
    uint8_t     udpLenMsb;      /* length inc. header    byte 38 */
    uint8_t     udpLenLsb;      /* byte 39 */
    uint8_t     chkSumMsb;      /* CRC of header+data     byte 40 */
    uint8_t     chkSumLsb;      /* byte 41 */
    /* PTP message */
    uint8_t     ptpVers[2];     /* version PTP  = 0x0001   bytes 42-43 */
    uint8_t     netVers[2];     /* version network  bytes 44-45 */
    uint8_t     subDom[16];     /* subdomain   bytes 46-61 */
    uint8_t     msgTyp;         /* message type =0x01 for event, 0x02 for general  byte 62 */
    uint8_t     srcTech;        /* source comms technology  byte 63 */
    uint8_t     srcUuid[6];     /* source Uuid  byte 64-69 */
    uint8_t     srcPort[2];     /* source port ID  bytes 70-71 */
    uint8_t     seqId[2];       /* sequence ID    bytes 72-73 */
    uint8_t     ptpCtrl;        /* = 0x00 for sync, 0x01 for dlyReq   byte 74 */
    uint8_t     resvd3;         /* byte 75 */
    uint8_t     flags[2];       /* bytes 76-77 */
    uint8_t     resvd4[4];      /* bytes 78-81 */
    uint8_t     timeSec[4];     /* timeStamp seconds   bytes 82-85 */
    uint8_t     timeNsec[4];    /* timeStamp nanoseconds   bytes 86-89 */
    uint8_t     padding[78];    /* fields for sync/delay_req formats   bytes 90-167 */
} ptpV1Frame;

/* PTP Event message frame, IPv4, 1588 v2 */
typedef struct {
    /* ethernet header */
    CEDI_MacAddress dest;       /* bytes 0-5 */
    CEDI_MacAddress srce;       /* bytes 6-11 */
    uint8_t     typeLenMsb;     /* MSB = 0x08 */
    uint8_t     typeLenLsb;     /* LSB = 0x00 */
    /* IP header */
    uint8_t     ihlVers;        /* = 0x45     byte 14 */
    uint8_t     dsCp;           /* byte 15 */
    uint8_t     lengthMsb;      /* byte 16 */
    uint8_t     lengthLsb;      /* byte 17 */
    uint16_t    iD;             /* bytes 18-19 */
    uint16_t    flgsFragOffset; /* bytes 20-21 */
    uint8_t     ttL;            /* byte 22 */
    uint8_t     prot;           /* = 0x11, UDP   byte 23 */
    uint8_t     hdrChksum[2];   /* bytes 24-25 */
    CEDI_IPv4Add srcAddr;       /* bytes 26-29 */
    CEDI_IPv4Add dstAddr;       /* = 0xE0000181/82/83/84) bytes 30-33 */
    /* UDP header */
    uint8_t     srcPortMsb;     /* source port number   byte 34 */
    uint8_t     srcPortLsb;     /* byte 35 */
    uint8_t     dstPortMsb;     /* = 0x01   destination port number   byte 36 */
    uint8_t     dstPortLsb;     /* = 0x3F      byte 37 */
    uint8_t     udpLenMsb;      /* length inc. header    byte 38 */
    uint8_t     udpLenLsb;      /* byte 39 */
    uint8_t     chkSumMsb;      /* CRC of header+data     byte 40 */
    uint8_t     chkSumLsb;      /* byte 41 */
    /* PTP message header */
    uint8_t     trSpec_MsgType; /* transport-specific upper nibble, messageType lower nibble:
                                   00 for sync, 02 for Pdelay_req, 03 for Pdelay_resp  byte 42 */
    uint8_t     ptpVers;        /* = 0x02   byte 43 */
    uint8_t     msgLenMsb;      /* length of PTP message, =34 bytes + message after header  bytes 44-45 */
    uint8_t     msgLenLsb;
    uint8_t     domNum;         /* domain number    byte 46 */
    uint8_t     resvd1;         /* byte 47 */
    uint8_t     flagField[2];   /* bytes 48-49 */
    uint8_t     correct[8];     /* correction field   bytes 50-57 */
    uint8_t     resvd2[4];      /* bytes 58-61 */
    uint8_t     srcPrtId[10];   /* source port identity   bytes 62-71 */
    uint8_t     seqId[2];       /* sequence ID    bytes 72-73 */
    uint8_t     control;        /* control, dep on msgType   byte 74 */
    uint8_t     logMsgInt;      /* log message interval   byte 75 */
    /* PTP Event message */
    uint8_t     timestamp[10];  /* origin/receive timestamp      bytes 76-85 */
    uint8_t     reqPortId[10];  /* used for delay_resp/pdelay_resp formats   bytes 86-95*/
} ptpV2Frame;

/* 802.3 pause frame */
typedef struct {
    CEDI_MacAddress dest;
    CEDI_MacAddress srce;
    uint8_t typeLenMsb;     /* = 0x88 type: MAC control frame */
    uint8_t typeLenLsb;     /* = 0x08 */
    uint8_t opcodeMsb;      /* = 0x00 Pause opcode */
    uint8_t opcodeLsb;      /* = 0x01 */
    uint8_t pauseTimeMsb;
    uint8_t pauseTimeLsb;
    uint8_t padding[46];
} pauseFr_t;

/* basic TCP frame, IPv4 */
typedef struct {
    /* ethernet header */
    CEDI_MacAddress dest;       /* bytes 0-5 */
    CEDI_MacAddress srce;       /* bytes 6-11 */
    uint8_t     typeLenMsb;     /* MSB = 0x08   byte 12 */
    uint8_t     typeLenLsb;     /* LSB = 0x00   byte 13 */
    /* IP header */
    uint8_t     ihlVers;        /* = 0x45     byte 14 */
    uint8_t     dsCp;           /* byte 15 */
    uint8_t     frLengthMsb;    /* byte 16 */
    uint8_t     frLengthLsb;    /* byte 17 */
    uint8_t     idMsb;          /* byte 18 */
    uint8_t     idLsb;          /* byte 19 */
    uint8_t     flgsFrOffsMsb;  /* IP Flags, b7-b5, fragment offset MSB b4-b0  byte 20 */
    uint8_t     fragOffsLsb;    /* fragment offset LSB  byte 21 */
    uint8_t     ttL;            /* byte 22 */
    uint8_t     prot;           /* = 0x06, TCP   byte 23 */
    uint8_t     hdrChksumMsb;   /* byte 24 */
    uint8_t     hdrChksumLsb;   /* byte 25 */
    CEDI_IPv4Add srcIpAddr;     /* byte 26-29 */
    CEDI_IPv4Add dstIpAddr;     /* byte 30-33 */
    /* TCP header */
    uint8_t     srcPortMsb;     /* source port number  byte 34 */
    uint8_t     srcPortLsb;     /* source port number  byte 35 */
    uint8_t     dstPortMsb;     /* destination port number  byte 36 */
    uint8_t     dstPortLsb;     /* destination port number  byte 37 */
    word32b_t   seqNum;         /* sequence number  bytes 38-41 */
    word32b_t   ackNum;         /* ACK number       bytes 42-45 */
    uint8_t     datOffsFlgsMsb; /* TCP flags MSB (b1),  Data offset bits 7-4  byte 46 */
    uint8_t     tcpFlagsLsb;    /* TCP flags LSB   byte 47 */
    uint8_t     windowSizeMsb;  /* byte 48 */
    uint8_t     windowSizeLsb;  /* byte 49 */
    uint8_t     tcpChksumMsb;   /* byte 50 */
    uint8_t     tcpChksumLsb;   /* byte 51 */
    uint8_t     urgentPtrMsb;   /* byte 52 */
    uint8_t     urgentPtrLsb;   /* byte 53 */
//    uint32_t    dataStart;      /* start of data  byte54-> */
} tcpHeader1_t;

/* basic UDP frame, IPv4 */
typedef struct {
    /* ethernet header */
    CEDI_MacAddress dest;       /* bytes 0-5 */
    CEDI_MacAddress srce;       /* bytes 6-11 */
    uint8_t     typeLenMsb;     /* MSB = 0x08 */
    uint8_t     typeLenLsb;     /* LSB = 0x00 */
    /* IP header */
    uint8_t     ihlVers;        /* = 0x45   byte 14 */
    uint8_t     dsCp;           /* byte 15 */
    uint8_t     frLengthMsb;    /* byte 16 */
    uint8_t     frLengthLsb;    /* byte 17 */
    uint8_t     idMsb;          /* byte 18 */
    uint8_t     idLsb;          /* byte 19 */
    uint8_t     flgsFrOffsMsb;  /* byte 20 */
    uint8_t     fragOffsLsb;    /* byte 21 */
    uint8_t     ttL;            /* byte 22 */
    uint8_t     prot;           /* = 0x11, UDP   byte 23 */
    uint8_t     hdrChksumMsb;   /* byte 24 */
    uint8_t     hdrChksumLsb;   /* byte 25 */
    CEDI_IPv4Add srcIpAddr;     /* bytes 26-29 */
    CEDI_IPv4Add dstIpAddr;     /* bytes 30-33 */
    /* UDP header */
    uint8_t     srcPortMsb;     /* source port number  byte 34 */
    uint8_t     srcPortLsb;     /* source port number  byte 35 */
    uint8_t     dstPortMsb;     /* destination port number  byte 36 */
    uint8_t     dstPortLsb;     /* destination port number  byte 37 */
    uint8_t     udpLengthMsb;   /* UDP header+data  byte 38 */
    uint8_t     udpLengthLsb;   /* UDP header+data  byte 39 */
    uint8_t     udpChksumMsb;   /* byte 40 */
    uint8_t     udpChksumLsb;   /* byte 41 */
//    uint32_t    dataStart;      /* start of data  byte42-> */
} udpHeader1_t;

#pragma pack(pop)       /* restore previous alignment */

/* initTcpUdpHeader parameters - for UDP or TCP header */
typedef struct {
    CEDI_MacAddress srcMac;
    CEDI_MacAddress dstMac;
    uint16_t dataLen;
    uint16_t id;
    CEDI_IPv4Add srcIpAddr;
    CEDI_IPv4Add dstIpAddr;
    uint16_t srcPort;           /* TCP or UDP */
    uint16_t dstPort;           /* TCP or UDP */
    uint32_t seqNum;            /* TCP */
    uint32_t ackNum;            /* TCP */
    uint16_t flags;             /* TCP */
    uint16_t window;            /* TCP */
    uint16_t udpLength;         /* UDP */
    uint16_t udpChksum;         /* UDP */
} tcpUdpParams_t;


/**************************  Test support functions  *************************/

/**
 * testSetup
 *
 * Initialisation of driver for one of the two GEM instances in the VSP test
 * wrapper.
 * Calls probe and init functions to provide inital setup for test cases.
 * Test can either provide a specific configuration (used for both instances),
 * or if cfgPtr==NULL, the initConfig function will be used as a standard
 * initialisation, using the txQSize, rxQSize and rxBufLenBytes parameters.
 * In this case, the maximum number of Tx & Rx queues will be configured.
 * If PCS is present and MII/GMII interface selected, this will be changed to
 * 1000BASE_X.
 *
 * @param cInst CDDC instance, for debug output
 * @param objInst GEM instance: 0 or 1
 * @param txQSize - number of descriptors per Tx queue, used if cfgPtr==NULL
 * @param rxQSize - number of descriptors per Rx queue, used if cfgPtr==NULL
 * @param rxBufLenBytes - size of Rx buffers to use, if cfgPtr==NULL
 * @param cfgPtr - defines the configuration to initialise the driver and h/w
 * @return 0 for success
 * @return 1 if probe call returns error or private data malloc fails
 * @return 2 if Rx descriptors' HWMem alloc fails
 * @return 3 if Tx descriptors' HWMem alloc fails
 * @return 4 if init call returns error
 */
uint32_t testSetup(cddcOp *cInst, uint8_t ojbInst, uint16_t txQSize,
                    uint16_t rxQSize, uint16_t rxBufLenBytes, CEDI_Config *cfgPtr);

/**
 * testTearDown
 *
 * Destroy the driver object and free up memory reserved by testSetup
 * @param cInst CDDC instance, for debug output
 * @param objInst GEM instance: 0 or 1
 */
void testTearDown(cddcOp *cInst, uint8_t objInst);

/**
 * initConfig
 *
 * Intialise a CEDI_Config structure for specified GEM instance, using
 * maximum available Tx & Rx queues, and other values specified by parameters
 * @param cInst CDDC instance, for debug output
 * @param objInst GEM instance: 0 or 1
 * @param txQSize - number of descriptors per Tx queue
 * @param rxQSize - number of descriptors per Rx queue
 * @param rxBufLenBytes - size of Rx buffers to use
 * @param intrEvents - events to enable on start API call
 * @param cfg - pointer to config struct to initialise
 * @return 0 if successful
 * @return EINVAL if invalid parameter
 */
uint32_t initConfig(cddcOp *cInst, uint8_t objInst, uint16_t txQSize,
                    uint16_t rxQSize,uint16_t rxBufLenBytes,
                    uint32_t intrEvents, CEDI_Config *cfg);


uint8_t cfgHwQs(uint8_t emacInst);
void printTxDescList( cddcOp *cInst, CEDI_PrivateData *pD, uint8_t qNum);
void printRxDescList( cddcOp *cInst, CEDI_PrivateData *pD, uint8_t qNum);
void printRxVAddrList(cddcOp *cInst, CEDI_PrivateData *pD, uint8_t qNum);
void printNetControlReg( cddcOp *cInst, CEDI_PrivateData *pD);
void printNetConfigReg( cddcOp *cInst, CEDI_PrivateData *pD);
void printNetStatusReg( cddcOp *cInst, CEDI_PrivateData *pD);
void printDmaConfigReg( cddcOp *cInst, CEDI_PrivateData *pD);
void printDesignCfg( cddcOp *cInst, CEDI_PrivateData *pD);
void printStatsCopy(cddcOp *cInst, CEDI_PrivateData *pD);
void printTxStatus(cddcOp *cInst, uint8_t emacInst);
void printRxStatus(cddcOp *cInst, uint8_t emacInst);
void zeroCallbackCounters(void);
uint32_t detectCallback(cddcOp *cInst, uint8_t gem);
uint32_t allocBuffer(uint32_t bytes, uint32_t fill, CEDI_BuffAddr *buf);

uint32_t allocSysReqMem(cddcOp *cInst, uint8_t objInst, CEDI_SysReq req,
						CEDI_Config *cfg );


/**
 * txRxTest
 * Simple tx-rx of single-buffer frame from GEM 0 to GEM 1.
 * Promiscuous mode, ignore preamble & FCS on Rx;
 * no events/isr calls, simply monitor Tx & Rx status registers.
 * Unformatted frame data, no headers.
 * Validates rx buffer status, tx/rx statistics and prints out start of
 * data and all statistics.
 */
void txRxTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv );

/**
 * cbTxRxTest
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
void cbTxRxTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv );

/**
 * loopbackTest
 * Test local loopback mode to tx-rx in single GEM instance.
 */
void loopbackTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv );

/**
 * Test transmitting frames using eMAC, when 802.3br is enabled
 */
void emacTxRxTest( void *cddcInst, CEDI_PrivateData *pD, char *paramv );


#endif /* multiple inclusion protection */
