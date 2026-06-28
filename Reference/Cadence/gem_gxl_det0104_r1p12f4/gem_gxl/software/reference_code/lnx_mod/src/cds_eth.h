/***********************************************************************
 *
 * Cadence Ethernet MAC (GEM/XGM) reference driver declarations
 *
 * Copyright (C) 2014-2016 Cadence Design Systems
 * All rights reserved
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * cds_eth.h
 *
 ***********************************************************************/

#ifndef CDS_ETH_H_
#define CDS_ETH_H_

#ifdef DEBUG
#define _HAVE_DBG_LOG_INT_ 1
#include "log.h"
#endif /* DEBUG */

#if defined(NIC_BR)
  #define EMAC_PHY_ADR  0
#elif defined(NIC_FPGA)
  #define EMAC_PHY_ADR  7
  #define EMAC_MDIO
#else
  #define EMAC_PHY_ADR  31
#endif

#if defined(NIC_BR)
  #define EMAC_IF_TYPE   CEDI_IFSP_100M_MII
#elif defined(EMAC_SELECT_SGMII)
  #define EMAC_IF_TYPE   CEDI_IFSP_1000M_SGMII
#else
  #define EMAC_IF_TYPE   CEDI_IFSP_1000M_GMII
#endif

#define EMAC_PHY_MASK   (~(1 << EMAC_PHY_ADR))
#ifdef EMAC_SELECT_SGMII
#define EMAC_PHY_MODE    PHY_INTERFACE_MODE_SGMII
#else
#define EMAC_PHY_MODE   PHY_INTERFACE_MODE_GMII
#endif

#define MAXNUM_RX_Q         8
#define MAXNUM_TX_Q         8
#define RX_Q_SZ             256
#define TX_Q_SZ             256
#define IP_HDR_ALIGN        2
//#define RX_BUF_SZ           (10240 - IP_HDR_ALIGN)     /* allow for max MTU */
#define RX_BUF_SZ           (16322 - IP_HDR_ALIGN)     /* require 16K for RSC */
#define MAX_MTU             10000
#define MIN_MTU             68
#define WOL_SUPPORTED_MASK  (WAKE_ARP | WAKE_MAGIC | WAKE_MCAST | WAKE_UCAST)
#define FREE_SKB_TIMEOUT    20000
#define TX_MAX_BUF_SIZE     10000   /* keep a margin less than absolute max */
#define UDP_CHK_OFFS        6       /* from start of UDP header */

#define DRV_NAME "cds_mac"
#define DEV_NAME "cdsmac"

#define VENDOR_ID 0x17cd
#define DEVICE_ID 0xe007

#define NAPI_WEIGHT                 64
#define EMAC_PORT_XMIT_RATE_10M     (2500 * 1000)
#define EMAC_PORT_XMIT_RATE_100M    (25 * 1000 * 1000)
#define EMAC_PORT_XMIT_RATE_1000M   (125 * 1000 * 1000)
#define ETH_TYPE_IPV4               0x0800
#define INT_DLY_NS_UNIT             800
#define EMAC_MAX_INT_DLY_NS         (255 * INT_DLY_NS_UNIT)

#define EMAC_SUB_NS_INCR_MSB_SIZE 16
#define EMAC_SUB_NS_INCR_MSB_MASK (((1 << EMAC_SUB_NS_INCR_MSB_SIZE) - 1))
#define EMAC_SUB_NS_INCR_LSB_SIZE 8
#define EMAC_SUB_NS_INCR_LSB_MASK (((1 << EMAC_SUB_NS_INCR_LSB_SIZE) - 1))
#define EMAC_SUB_NS_INCR_SIZE     (EMAC_SUB_NS_INCR_MSB_SIZE + EMAC_SUB_NS_INCR_LSB_SIZE)

#define PCT(x) (((x) + 50) / 100)
enum {
    PRIO_HI,
    PRIO_2ND
};

#if RX_Q_SZ > CEDI_MAX_RBQ_LENGTH
#undef RX_Q_SZ
#define RX_Q_SZ     CEDI_MAX_RBQ_LENGTH
#endif
#if TX_Q_SZ > CEDI_MAX_TBQ_LENGTH
#undef TX_Q_SZ
#define TX_Q_SZ     CEDI_MAX_TBQ_LENGTH
#endif

#ifdef EDD_PCI_NIC
static struct pci_device_id dev_id_table[] = {
        { PCI_DEVICE(VENDOR_ID, DEVICE_ID), },
        { 0, }
};
#endif

enum {
    EMAC_IRQ_DISABLE,
    EMAC_IRQ_ENABLE
};

/* Test configuration bit positions */
enum {
    TEST_CONFIG_KILL_IP_CSUM,
};
#define TEST_CONFIG_BIT(num) (1 << TEST_CONFIG_##num)

/* macro to recover our private data using the core's private data pointer */
#define RECOVER_PRIV(pD) ((void*)*((CEDI_PrivateData **)(pD) - 1))

struct map_info {
    struct sk_buff  *skb;
    dma_addr_t  dmap;
};

struct desc_info {
    uint32_t        allocSize;  /* size of combined descriptor area */
    void            *cpuStart;  /* descriptor area virtual address  */
    dma_addr_t      dmaStart;   /* descriptor area physical address */
};

/** struct containing all statistics counters, all 64-bit */
struct cgrd_stats {
    uint64_t octetsTx;
    uint64_t framesTx;
    uint64_t broadcastTx;
    uint64_t multicastTx;
    uint64_t pauseFrTx;
    uint64_t fr64byteTx;
    uint64_t fr65_127byteTx;
    uint64_t fr128_255byteTx;
    uint64_t fr256_511byteTx;
    uint64_t fr512_1023byteTx;
    uint64_t fr1024_1518byteTx;
    uint64_t fr1519_byteTx;
    uint64_t underrunFrTx;
    uint64_t singleCollFrTx;
    uint64_t multiCollFrTx;
    uint64_t excessCollFrTx;
    uint64_t lateCollFrTx;
    uint64_t deferredFrTx;
    uint64_t carrSensErrsTx;
    uint64_t octetsRx;
    uint64_t framesRx;
    uint64_t broadcastRx;
    uint64_t multicastRx;
    uint64_t pauseFrRx;
    uint64_t fr64byteRx;
    uint64_t fr65_127byteRx;
    uint64_t fr128_255byteRx;
    uint64_t fr256_511byteRx;
    uint64_t fr512_1023byteRx;
    uint64_t fr1024_1518byteRx;
    uint64_t fr1519_byteRx;
    uint64_t undersizeFrRx;
    uint64_t oversizeFrRx;
    uint64_t jabbersRx;
    uint64_t fcsErrorsRx;
    uint64_t lenChkErrRx;
    uint64_t rxSymbolErrs;
    uint64_t alignErrsRx;
    uint64_t rxResourcErrs;
    uint64_t overrunFrRx;
    uint64_t ipChksumErrs;
    uint64_t tcpChksumErrs;
    uint64_t udpChksumErrs;
    uint64_t dmaRxPBufFlush;
};

/* rx flow-spec element & list */
struct etht_fs_cont {
    struct ethtool_rx_flow_spec fs;
    struct list_head list;
};

struct rxfs_list {
    struct list_head list;
    unsigned int count;
};

struct rxfrag_list {
    struct sk_buff *head_skb;
    struct sk_buff *tail_skb;
};

struct cgrd_priv {
    struct net_device       *netdev;
#ifdef EDD_PCI_NIC
    struct pci_dev          *pcidev;
#else
    struct platform_device  *platdev;
#endif
    struct device           *dev_p;  /* points to gen.dev.in platdev or pcidev */
    void __iomem            *regmap;
    unsigned int            flags;
    u32                     test_config;
    u32                     num_rx_q;
    u32                     num_tx_q;
    spinlock_t              lock;
    CEDI_OBJ                *eddObj;
    CEDI_PrivateData        *corePriv;
    struct desc_info        rxDesc;
    struct desc_info        txDesc;
    struct map_info         rxReady[MAXNUM_RX_Q];
    struct rxfrag_list      rx_frag[MAXNUM_RX_Q];
    u32                     fr_sub_len[MAXNUM_RX_Q];
    CEDI_DesignCfg          hwCfg;
    u16                     rxBufLen[MAXNUM_RX_Q];  /* size in bytes */
    CEDI_Statistics         *statsRegs;
    struct cgrd_stats       stats;
    struct mii_bus          *mii_bus;
    struct phy_device       *phydev;
    unsigned int            link;
    unsigned int            speed;
    unsigned int            duplex;
    unsigned int            dmaAddr64;
    struct cbs {
        u8          enabled;
        u8          bw_pct;
    } cbs[2];
    CEDI_EnstTimeConfig     enstTimeConfig[16];
    u8                      enstEnabled[16];
    u8                      enstDirty;
    u8                      sysfsCreated;
    struct napi_struct      napi;
    struct ptp_clock_info   ptp_info;
    struct ptp_clock        *ptp_clk;

    struct hwtstamp_config  ts_config;
    /* this is needed especially for cleaning */
    struct cgrd_user_page *userpages;
    /* keeps information on which queue should be used for 1722 packets
     * It is configured using ioctl */

    /* Rx flow-spec ntuple defs */
    unsigned int            maxNtups;
    struct rxfs_list        rx_fs_list;
    spinlock_t              rx_fs_lock;
};


#ifdef DEBUG

#define DBUF_LEN 8192
u8 dbuf[DBUF_LEN];

#endif /* DEBUG */

static void cgrd_irq_control(struct cgrd_priv *priv, int enable);

/* TODO: DEBUG  tx buffer dma map/unmap tracking counters */
int sgl_map = 0, page_map = 0;


/* Tx buffer vAddr fields, excluding first descriptor (==skb, desc #0) :
 * descriptor number in b7-b0,
 * frag number in b15-b8 (only valid if page-mapped)
 * page mapped = b16
 */
#define TX_DESC_MASK        (0x000000FF)
#define TX_FRAG_MASK        (0x0000FF00)
#define TX_FRAG_SHIFT       (8)
#define TX_PAGE_MAPPED      (1<<16)

#define TX_BUF_INFO(desc,frag,pmap) \
                ((desc)+(frag<<TX_FRAG_SHIFT)+(pmap?TX_PAGE_MAPPED:0))
#define TX_DESC(vaddr)      (vaddr & TX_DESC_MASK)
#define TX_FRAG(vaddr)      ((vaddr & TX_FRAG_MASK)>>TX_FRAG_SHIFT)
#define PAGE_MAPPED(vaddr)  (vaddr & TX_PAGE_MAPPED)


#define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))

#undef min
#define min(x,y) (((x)<(y))?(x):(y))


#endif /* CDS_ETH_H_ */
