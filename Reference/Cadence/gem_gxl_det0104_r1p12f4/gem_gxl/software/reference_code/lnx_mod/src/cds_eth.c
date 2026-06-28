/***********************************************************************
 *
 * Cadence Ethernet MAC (GEM/XGM) reference driver
 *
 * Copyright (C) 2014-2017 Cadence Design Systems
 * All rights reserved
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 ***********************************************************************
 * Configured for GEM_GXL
 **********************************************************************/


#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/module.h>
#ifdef EDD_PCI_NIC
#include <linux/pci.h>
#else
#include <linux/platform_device.h>
#endif
#include <linux/netdevice.h>
#include <linux/clocksource.h>
#include <linux/etherdevice.h>
#include <linux/dma-mapping.h>
#include <linux/if.h>
#include <linux/phy.h>
#include <linux/time.h>
#include <linux/ptp_clock_kernel.h>
#include <linux/ip.h>
#include <linux/of_net.h>
#include <linux/version.h>
#include <linux/sockios.h>
#include <linux/jiffies.h>
#include <linux/net_tstamp.h>
#include <linux/tcp.h>
#include <linux/string.h>

#include "cdn_errno.h"
#include "cedi.h"
#include "cds_eth.h"
#include "edd_ioctl.h"


/***********************************************************************
 * Helper and internal functions
 **********************************************************************/

static uint8_t ns_increment = 25;
static uint32_t subns_increment = 0;
static uint32_t tsu_freq = 0;

/*
module_param(ns_increment, byte, S_IRUGO);
module_param(subns_increment, ushort, S_IRUGO);
*/
module_param(tsu_freq, uint, S_IRUGO);
MODULE_PARM_DESC(tsu_freq, "\n"
              "\tTSU clock frequency [Hz].\n");

#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)

static void add_hwtstamp(struct skb_shared_hwtstamps *hwtstamps,
			 u32 secs, u32 nsecs)
{
    hwtstamps->hwtstamp = ktime_set(secs, nsecs);
}
#endif



//#define VERBOSE_DEBUG
#ifdef VVVERBOSE_DEBUG
static void cgrd_dump_buf(char *str, uint8_t qNum, void *bp, uint32_t len) {
    int i;
    u8 *buf = bp;

    pr_debug("    Buffer dump: %s: queue=%u, addr=%p, len=%u\n", str, qNum, bp, len);
    for (i = 0; i < ((len+15) / 16); ++i) {
        pr_debug("    %02x%02x%02x%02x  %02x%02x%02x%02x  %02x%02x%02x%02x  %02x%02x%02x%02x\n",
                buf[0], buf[1], buf[2], buf[3], buf[4], buf[5], buf[6], buf[7],
                buf[8], buf[9], buf[10], buf[11], buf[12], buf[13], buf[14], buf[15]);
        buf += 16;
    }
}
#else
#ifdef VVERBOSE_DEBUG
static void cgrd_dump_buf(char *str, uint8_t qNum, void *bp, uint32_t len) {
    pr_debug("    Buffer dump: %s: queue=%u, addr=%p, len=%u\n", str, qNum, bp, len);
}
#else
#ifdef VERBOSE_DEBUG
static void cgrd_dump_buf(char *str, uint8_t qNum, void *bp, uint32_t len) {
    pr_debug("    Buffer dump: %s: queue=%u, addr=%p, len=%u\n", str, qNum, bp, len);
}
#else
#define cgrd_dump_buf(str, qNum, bp, len)
#endif
#endif
#endif

#ifdef DEBUG
static ssize_t cgrd_show_test_config(struct device *dev,
        struct device_attribute *attr, char *buf) {
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    return scnprintf(buf, PAGE_SIZE, "0x%X\n", priv->test_config);
}

static ssize_t cgrd_store_test_config(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t count) {
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned long test_config = simple_strtoul(buf, NULL, 0);

    priv->test_config = test_config;
    return count;
}

DEVICE_ATTR(test_config, S_IWUSR | S_IRUGO,
        cgrd_show_test_config, cgrd_store_test_config);
#endif


static void cgrd_get_cbs_shaping(struct cgrd_priv *priv, u8 prio) {
    uint32_t hw_idle_slope;
    uint32_t bw_pct;
    uint32_t res;
    u8 queue;
    struct net_device *ndev = priv->netdev;

    if (prio)
        queue = priv->num_tx_q - 2;
    else
        queue = priv->num_tx_q - 1;

    res = priv->eddObj->getCbsIdleSlope(priv->corePriv, queue, &hw_idle_slope);
    if (0 != res) {
        netdev_err(ndev, "Unable to read HW shaping "
                "parameters for queue %u!\n",
                priv->num_tx_q - prio - 1);
        return;
    }

    switch (priv->speed) {
    default:
    case SPEED_10:
        hw_idle_slope /= PCT(EMAC_PORT_XMIT_RATE_10M);
        break;
    case SPEED_100:
        hw_idle_slope /= PCT(EMAC_PORT_XMIT_RATE_100M);
        break;
    case SPEED_1000:
    case SPEED_2500: // same for 1000M and 2500M
        hw_idle_slope /= PCT(EMAC_PORT_XMIT_RATE_1000M);
        break;
    }
    netdev_dbg(priv->netdev, "%s: hw_pct=%Xh\n",
            __func__,  hw_idle_slope);
    bw_pct = priv->cbs[prio].bw_pct;
    if (hw_idle_slope != bw_pct) {
        netdev_warn(ndev, "Driver HW Shaping percent setting "
                "of %u differs from register setting of %u\n",
                bw_pct, hw_idle_slope);
        priv->cbs[prio].bw_pct = hw_idle_slope;
    }
}

static void cgrd_set_cbs_shaping(struct cgrd_priv *priv, u8 prio) {
    uint32_t idle_slope;
    uint32_t res;
    u8 queue;
    struct net_device *ndev = priv->netdev;

    if(priv->num_tx_q < 2)
        return;

    if (prio)
        queue = priv->num_tx_q - 2;
    else
        queue = priv->num_tx_q - 1;

    switch (priv->speed) {
    default:
    case SPEED_10:
        idle_slope = PCT(EMAC_PORT_XMIT_RATE_10M);
        break;
    case SPEED_100:
        idle_slope = PCT(EMAC_PORT_XMIT_RATE_100M);
        break;
    case SPEED_1000:
    case SPEED_2500: // same for 1000M and 2500M
        idle_slope = PCT(EMAC_PORT_XMIT_RATE_1000M);
        break;
    }
    idle_slope *= priv->cbs[prio].bw_pct;
    res = priv->eddObj->setCbsIdleSlope(priv->corePriv, queue, idle_slope);
    if (0 != res)
        netdev_err(ndev, "Unable to set HW shaping "
                "parameters for queue %u!\n", queue);
}

static ssize_t cgrd_show_queue_sched_type(struct device *dev, char *buf, u8 queue) {
    uint32_t res;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    CEDI_TxSchedType schedType;

    res = priv->eddObj->getTxQueueScheduler(priv->corePriv, queue, &schedType);
    if (0 != res) {
        netdev_err(ndev, "Unable to read HW shaping "
                "scheduler type for queue %u!\n",queue);
        return 0;
    }
    return scnprintf(buf, PAGE_SIZE, "%d\n", schedType);
}

static ssize_t cgrd_store_queue_sched_type(struct device *dev, const char *buf,
        u8 queue, size_t count) {
    uint32_t res;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    CEDI_TxSchedType schedType;
    if (sysfs_streq("0", buf))
        schedType = CEDI_TX_SCHED_TYPE_FIXED;
    else if (sysfs_streq("1", buf))
        schedType = CEDI_TX_SCHED_TYPE_CBS;
    else if (sysfs_streq("2", buf))
        schedType = CEDI_TX_SCHED_TYPE_DWRR;
    else if (sysfs_streq("3", buf))
        schedType = CEDI_TX_SCHED_TYPE_ETS;
    else
    {
        netdev_err(ndev, "Invalid value of scheduler type for queue %u\n",queue);
        return -EINVAL;
    }

    res = priv->eddObj->setTxQueueScheduler(priv->corePriv, queue, schedType);
    if (res)
    {
        netdev_err(ndev, "Unable to set scheduler type for queue %u\n",queue);
        return -EINVAL;
    }
    return count;
}

static ssize_t cgrd_show_queue_sched_value(struct device *dev, char *buf, u8 queue) {
    uint32_t res;
    u8 value = 0;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    CEDI_TxSchedType schedType;

    res = priv->eddObj->getTxQueueScheduler(priv->corePriv, queue, &schedType);
    if (0 != res) {
        netdev_err(ndev, "Unable to read HW shaping "
                "scheduler type for queue %u!\n",queue);
        return 0;
    }

    switch(schedType) {
    case CEDI_TX_SCHED_TYPE_CBS:
        if (queue == priv->num_tx_q - 1)
        {
            cgrd_get_cbs_shaping(priv, PRIO_HI);
            value = priv->cbs[PRIO_HI].bw_pct;
        }
        else if (queue == priv->num_tx_q - 2)
        {
            cgrd_get_cbs_shaping(priv, PRIO_2ND);
            value = priv->cbs[PRIO_2ND].bw_pct;
        }
        else
        {
            netdev_err(ndev, "CBS is incorrect algorithm for queue %u\n",queue);
            return 0;
        }
        break;
    case CEDI_TX_SCHED_TYPE_DWRR:
        res = priv->eddObj->getDwrrWeighting(priv->corePriv, queue, &value);
        if (res)
        {
            netdev_err(ndev, "Unable to get DWRR weighting value "
                    "for queue %u\n",queue);
            return 0;
        }
        break;
    case CEDI_TX_SCHED_TYPE_ETS:
        res = priv->eddObj->getEtsBandAlloc(priv->corePriv, queue, &value);
        if (res)
        {
            netdev_err(ndev, "Unable to get DWRR weighting value "
                    "for queue %u\n",queue);
            return 0;
        }
        break;
    case CEDI_TX_SCHED_TYPE_FIXED:
        netdev_warn(ndev, "Queue %u has fixed priority "
                "and thus no scheduler algorithm value.\n",queue);
            return 0;
        break;
    default:
        netdev_err(ndev, "Queue %u has invalid scheduler type set.\n",queue);
        return 0;
    }
    return scnprintf(buf, PAGE_SIZE, "%u\n", value);
}

static ssize_t cgrd_store_queue_sched_value(struct device *dev, const char *buf,
        u8 queue, size_t count) {
    uint32_t res;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    CEDI_TxSchedType schedType;
    unsigned long value = simple_strtoul(buf, NULL, 0);

    res = priv->eddObj->getTxQueueScheduler(priv->corePriv, queue, &schedType);
    if (0 != res) {
        netdev_err(ndev, "Unable to read HW shaping "
                "scheduler type for queue %u!\n",queue);
        return -EINVAL;
    }

    switch(schedType) {
    case CEDI_TX_SCHED_TYPE_CBS:
        if (value > 100)
        {
            netdev_err(ndev,"Value for CBS algorithm can not be greater than 100\n");
            return -EINVAL;
        }
        if (queue == priv->num_tx_q - 1)
        {
            priv->cbs[PRIO_HI].bw_pct = value;
            cgrd_set_cbs_shaping(priv, PRIO_HI);
        }
        else if (queue == priv->num_tx_q - 2)
        {
            priv->cbs[PRIO_2ND].bw_pct = value;
            cgrd_set_cbs_shaping(priv, PRIO_2ND);
        }
        else
        {
            netdev_err(ndev, "CBS is incorrect algorithm for queue %u\n",queue);
            return -EINVAL;
        }
        break;
    case CEDI_TX_SCHED_TYPE_DWRR:
        if (value > 255)
        {
            netdev_err(ndev,"Value for DWRR algorithm can not be greater than 255\n");
            return -EINVAL;
        }
        res = priv->eddObj->setDwrrWeighting(priv->corePriv, queue, value);
        if (res)
        {
            netdev_err(ndev, "Unable to set DWRR weighting value "
                    "for queue %u\n",queue);
            return -EINVAL;
        }
        break;
    case CEDI_TX_SCHED_TYPE_ETS:
        if (value > 100)
        {
            netdev_err(ndev,"Value for ETS algorithm can not be greater than 100\n");
            return -EINVAL;
        }
        res = priv->eddObj->setEtsBandAlloc(priv->corePriv, queue, value);
        if (res)
        {
            netdev_err(ndev, "Unable to set ETS value for queue %u\n",queue);
            return -EINVAL;
        }
        break;
    case CEDI_TX_SCHED_TYPE_FIXED:
        netdev_warn(ndev, "Queue %u has fixed priority "
                "and thus no scheduler algorithm value.\n",queue);
        return -EINVAL;
        break;
    default:
        netdev_err(ndev, "Queue %u has invalid scheduler type set.\n",queue);
        return -EINVAL;
    }
    return count;
}

/* traffic shaping algorithm selection through sysfs*/

#define SCHED_TYPE_ATTR(Q)                                                  \
    static ssize_t cgrd_show_queue_##Q##_sched_type(struct device *dev,     \
            struct device_attribute *attr, char *buf) {                     \
        return cgrd_show_queue_sched_type(dev, buf, Q);                     \
    }                                                                       \
                                                                            \
    static ssize_t cgrd_store_queue_##Q##_sched_type(struct device *dev,    \
            struct device_attribute *attr, const char *buf, size_t count) { \
        return cgrd_store_queue_sched_type(dev, buf, Q, count);             \
    }                                                                       \
                                                                            \
    DEVICE_ATTR(queue_##Q##_sched_type, S_IWUSR | S_IRUGO,                  \
            cgrd_show_queue_##Q##_sched_type, cgrd_store_queue_##Q##_sched_type); \

SCHED_TYPE_ATTR(0);
SCHED_TYPE_ATTR(1);
SCHED_TYPE_ATTR(2);
SCHED_TYPE_ATTR(3);
SCHED_TYPE_ATTR(4);
SCHED_TYPE_ATTR(5);
SCHED_TYPE_ATTR(6);
SCHED_TYPE_ATTR(7);
SCHED_TYPE_ATTR(8);
SCHED_TYPE_ATTR(9);
SCHED_TYPE_ATTR(10);
SCHED_TYPE_ATTR(11);
SCHED_TYPE_ATTR(12);
SCHED_TYPE_ATTR(13);
SCHED_TYPE_ATTR(14);
SCHED_TYPE_ATTR(15);


static struct device_attribute* get_scheduler_type_attrs(void)
{
    static struct device_attribute scheduler_type_attrs[16];

    scheduler_type_attrs[0] = dev_attr_queue_0_sched_type;
    scheduler_type_attrs[1] = dev_attr_queue_1_sched_type;
    scheduler_type_attrs[2] = dev_attr_queue_2_sched_type;
    scheduler_type_attrs[3] = dev_attr_queue_3_sched_type;
    scheduler_type_attrs[4] = dev_attr_queue_4_sched_type;
    scheduler_type_attrs[5] = dev_attr_queue_5_sched_type;
    scheduler_type_attrs[6] = dev_attr_queue_6_sched_type;
    scheduler_type_attrs[7] = dev_attr_queue_7_sched_type;
    scheduler_type_attrs[8] = dev_attr_queue_8_sched_type;
    scheduler_type_attrs[9] = dev_attr_queue_9_sched_type;
    scheduler_type_attrs[10] = dev_attr_queue_10_sched_type;
    scheduler_type_attrs[11] = dev_attr_queue_11_sched_type;
    scheduler_type_attrs[12] = dev_attr_queue_12_sched_type;
    scheduler_type_attrs[13] = dev_attr_queue_13_sched_type;
    scheduler_type_attrs[14] = dev_attr_queue_14_sched_type;
    scheduler_type_attrs[15] = dev_attr_queue_15_sched_type;

    return scheduler_type_attrs;
}
/* end of traffic shaping algorithm selection */

/* traffic shaping algorithm values through sysfs*/

#define SCHED_VALUE_ATTR(Q)                                              \
static ssize_t cgrd_show_queue_##Q##_sched_value(struct device *dev,     \
        struct device_attribute *attr, char *buf) {                      \
    return cgrd_show_queue_sched_value(dev, buf, Q);                     \
}                                                                        \
                                                                         \
static ssize_t cgrd_store_queue_##Q##_sched_value(struct device *dev,    \
        struct device_attribute *attr, const char *buf, size_t count) {  \
    return cgrd_store_queue_sched_value(dev, buf, Q, count);             \
}                                                                        \
                                                                         \
DEVICE_ATTR(queue_##Q##_sched_value, S_IWUSR | S_IRUGO,                  \
        cgrd_show_queue_##Q##_sched_value, cgrd_store_queue_##Q##_sched_value); \

SCHED_VALUE_ATTR(0);
SCHED_VALUE_ATTR(1);
SCHED_VALUE_ATTR(2);
SCHED_VALUE_ATTR(3);
SCHED_VALUE_ATTR(4);
SCHED_VALUE_ATTR(5);
SCHED_VALUE_ATTR(6);
SCHED_VALUE_ATTR(7);
SCHED_VALUE_ATTR(8);
SCHED_VALUE_ATTR(9);
SCHED_VALUE_ATTR(10);
SCHED_VALUE_ATTR(11);
SCHED_VALUE_ATTR(12);
SCHED_VALUE_ATTR(13);
SCHED_VALUE_ATTR(14);
SCHED_VALUE_ATTR(15);

static struct device_attribute* get_scheduler_value_attrs(void)
{
    static struct device_attribute scheduler_value_attrs[16];

    scheduler_value_attrs[0] = dev_attr_queue_0_sched_value;
    scheduler_value_attrs[1] = dev_attr_queue_1_sched_value;
    scheduler_value_attrs[2] = dev_attr_queue_2_sched_value;
    scheduler_value_attrs[3] = dev_attr_queue_3_sched_value;
    scheduler_value_attrs[4] = dev_attr_queue_4_sched_value;
    scheduler_value_attrs[5] = dev_attr_queue_5_sched_value;
    scheduler_value_attrs[6] = dev_attr_queue_6_sched_value;
    scheduler_value_attrs[7] = dev_attr_queue_7_sched_value;
    scheduler_value_attrs[8] = dev_attr_queue_8_sched_value;
    scheduler_value_attrs[9] = dev_attr_queue_9_sched_value;
    scheduler_value_attrs[10] = dev_attr_queue_10_sched_value;
    scheduler_value_attrs[11] = dev_attr_queue_11_sched_value;
    scheduler_value_attrs[12] = dev_attr_queue_12_sched_value;
    scheduler_value_attrs[13] = dev_attr_queue_13_sched_value;
    scheduler_value_attrs[14] = dev_attr_queue_14_sched_value;
    scheduler_value_attrs[15] = dev_attr_queue_15_sched_value;

    return scheduler_value_attrs;
}

/* end of traffic shaping algorithm values */

/* EnST (802.1Qbv) control */

static ssize_t cgrd_show_queue_enst_enable(struct device *dev, char *buf, u8 queue) {
    u8 enabled;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    enabled = priv->enstEnabled[queue];

    return scnprintf(buf, PAGE_SIZE, "%d\n", enabled);
}

static ssize_t cgrd_store_queue_enst_enable(struct device *dev,
        const char *buf, u8 queue, size_t count) {
    unsigned long value = simple_strtoul(buf, NULL, 0);
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    if (value ==  0)
    {
        priv->enstEnabled[queue] = 0;
        priv->enstDirty = 1;
    }
    else if (value == 1)
    {
        priv->enstEnabled[queue] = 1;
        priv->enstDirty = 1;
    }
    else
        return -EINVAL;
    return count;
}

static ssize_t cgrd_show_queue_start_time_s(struct device *dev, char *buf,
        u8 queue) {
    u8 seconds;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    seconds = priv->enstTimeConfig[queue].startTimeS;
    return scnprintf(buf, PAGE_SIZE, "%d\n", seconds);
}

static ssize_t cgrd_show_queue_start_time_ns(struct device *dev, char *buf,
        u8 queue) {
    uint32_t nanosecs;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    nanosecs = priv->enstTimeConfig[queue].startTimeNs;
    return scnprintf(buf, PAGE_SIZE, "%d\n", nanosecs);
}

static ssize_t cgrd_store_queue_start_time_s(struct device *dev,
        const char *buf, u8 queue, size_t count) {
    unsigned long value = simple_strtoul(buf, NULL, 0);
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    if (value > 3)
    {
        netdev_err(ndev, "Value for EnST start time (seconds) "
                "can not be greater than 3\n");
        return -EINVAL;
    }
    priv->enstTimeConfig[queue].startTimeS = value;
    priv->enstDirty = 1;
    return count;
}

static ssize_t cgrd_store_queue_start_time_ns(struct device *dev,
        const char *buf, u8 queue, size_t count) {
    unsigned long value = simple_strtoul(buf, NULL, 0);
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    if (value >= 1000000000)
    {
        netdev_err(ndev, "Value for EnST start time (nanoseconds) "
                "has to be less that 1,000,000,000\n");
        return -EINVAL;
    }
    priv->enstTimeConfig[queue].startTimeNs = value;
    priv->enstDirty = 1;
    return count;
}

static ssize_t cgrd_show_queue_on_time(struct device *dev, char *buf,
        u8 queue) {
    uint32_t bytes;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    bytes = priv->enstTimeConfig[queue].onTime;
    return scnprintf(buf, PAGE_SIZE, "%d\n", bytes);
}

static ssize_t cgrd_store_queue_on_time(struct device *dev,
        const char *buf, u8 queue, size_t count) {
    unsigned long value = simple_strtoul(buf, NULL, 0);
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    if (value > 131071)
    {
        netdev_err(ndev, "Value for EnST on time "
                "can not be greater than 131,071\n");
        return -EINVAL;
    }
    priv->enstTimeConfig[queue].onTime = value;
    priv->enstDirty = 1;
    return count;
}

static ssize_t cgrd_show_queue_off_time(struct device *dev, char *buf,
        u8 queue) {
    uint32_t bytes;
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    bytes = priv->enstTimeConfig[queue].offTime;
    return scnprintf(buf, PAGE_SIZE, "%d\n", bytes);
}

static ssize_t cgrd_store_queue_off_time(struct device *dev,
        const char *buf, u8 queue, size_t count) {
    unsigned long value = simple_strtoul(buf, NULL, 0);
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);

    if (value > 131071)
    {
        netdev_err(ndev, "Value for EnST off time "
                "can not be greater than 131,071\n");
        return -EINVAL;
    }
    priv->enstTimeConfig[queue].offTime = value;
    priv->enstDirty = 1;
    return count;
}


#define ENST_ENABLE_ATTR(Q)                                                 \
    static ssize_t cgrd_show_queue_##Q##_enst_enable(struct device *dev,    \
            struct device_attribute *attr, char *buf) {                     \
        return cgrd_show_queue_enst_enable(dev, buf, Q);                    \
}                                                                           \
                                                                            \
    static ssize_t cgrd_store_queue_##Q##_enst_enable(struct device *dev,   \
            struct device_attribute *attr, const char *buf, size_t count) { \
        return cgrd_store_queue_enst_enable(dev, buf, Q, count);            \
}                                                                           \
                                                                            \
    DEVICE_ATTR(queue_##Q##_enst_enable, S_IWUSR | S_IRUGO,                 \
            cgrd_show_queue_##Q##_enst_enable, cgrd_store_queue_##Q##_enst_enable); \

/* -------------------------------------------------------------------------*/
#define ENST_START_TIME_S_ATTR(Q)                                           \
    static ssize_t cgrd_show_queue_##Q##_start_time_s(struct device *dev,   \
            struct device_attribute *attr, char *buf) {                     \
        return cgrd_show_queue_start_time_s(dev, buf, Q);                   \
}                                                                           \
                                                                            \
    static ssize_t cgrd_store_queue_##Q##_start_time_s(struct device *dev,  \
            struct device_attribute *attr, const char *buf, size_t count) { \
        return cgrd_store_queue_start_time_s(dev, buf, Q, count);           \
}                                                                           \
                                                                            \
    DEVICE_ATTR(queue_##Q##_start_time_s, S_IWUSR | S_IRUGO,                \
            cgrd_show_queue_##Q##_start_time_s, cgrd_store_queue_##Q##_start_time_s); \

/* -------------------------------------------------------------------------*/
#define ENST_START_TIME_NS_ATTR(Q)                                          \
    static ssize_t cgrd_show_queue_##Q##_start_time_ns(struct device *dev,  \
            struct device_attribute *attr, char *buf) {                     \
        return cgrd_show_queue_start_time_ns(dev, buf, Q);                  \
}                                                                           \
                                                                            \
    static ssize_t cgrd_store_queue_##Q##_start_time_ns(struct device *dev, \
            struct device_attribute *attr, const char *buf, size_t count) { \
        return cgrd_store_queue_start_time_ns(dev, buf, Q, count);          \
}                                                                           \
                                                                            \
    DEVICE_ATTR(queue_##Q##_start_time_ns, S_IWUSR | S_IRUGO,               \
            cgrd_show_queue_##Q##_start_time_ns, cgrd_store_queue_##Q##_start_time_ns); \

/* -------------------------------------------------------------------------*/
#define ENST_ON_TIME_ATTR(Q)                                                \
    static ssize_t cgrd_show_queue_##Q##_on_time(struct device *dev,        \
            struct device_attribute *attr, char *buf) {                     \
        return cgrd_show_queue_on_time(dev, buf, Q);                        \
}                                                                           \
                                                                            \
    static ssize_t cgrd_store_queue_##Q##_on_time(struct device *dev,       \
            struct device_attribute *attr, const char *buf, size_t count) { \
        return cgrd_store_queue_on_time(dev, buf, Q, count);                \
}                                                                           \
                                                                            \
    DEVICE_ATTR(queue_##Q##_on_time, S_IWUSR | S_IRUGO,                     \
            cgrd_show_queue_##Q##_on_time, cgrd_store_queue_##Q##_on_time); \

/* -------------------------------------------------------------------------*/
#define ENST_OFF_TIME_ATTR(Q)                                               \
    static ssize_t cgrd_show_queue_##Q##_off_time(struct device *dev,       \
            struct device_attribute *attr, char *buf) {                     \
        return cgrd_show_queue_off_time(dev, buf, Q);                       \
}                                                                           \
                                                                            \
    static ssize_t cgrd_store_queue_##Q##_off_time(struct device *dev,      \
            struct device_attribute *attr, const char *buf, size_t count) { \
        return cgrd_store_queue_off_time(dev, buf, Q, count);               \
}                                                                           \
                                                                            \
    DEVICE_ATTR(queue_##Q##_off_time, S_IWUSR | S_IRUGO,                    \
            cgrd_show_queue_##Q##_off_time, cgrd_store_queue_##Q##_off_time); \

/* -------------------------------------------------------------------------*/
#define ENST_ATTRS(Q)             \
    ENST_ENABLE_ATTR(Q)           \
    ENST_START_TIME_S_ATTR(Q)     \
    ENST_START_TIME_NS_ATTR(Q)    \
    ENST_ON_TIME_ATTR(Q)          \
    ENST_OFF_TIME_ATTR(Q)         \

ENST_ATTRS(0);
ENST_ATTRS(1);
ENST_ATTRS(2);
ENST_ATTRS(3);
ENST_ATTRS(4);
ENST_ATTRS(5);
ENST_ATTRS(6);
ENST_ATTRS(7);
ENST_ATTRS(8);
ENST_ATTRS(9);
ENST_ATTRS(10);
ENST_ATTRS(11);
ENST_ATTRS(12);
ENST_ATTRS(13);
ENST_ATTRS(14);
ENST_ATTRS(15);

static struct device_attribute* get_enst_enable_attrs(void)
{
    static struct device_attribute enst_enable_attrs[16];

    enst_enable_attrs[0] = dev_attr_queue_0_enst_enable;
    enst_enable_attrs[1] = dev_attr_queue_1_enst_enable;
    enst_enable_attrs[2] = dev_attr_queue_2_enst_enable;
    enst_enable_attrs[3] = dev_attr_queue_3_enst_enable;
    enst_enable_attrs[4] = dev_attr_queue_4_enst_enable;
    enst_enable_attrs[5] = dev_attr_queue_5_enst_enable;
    enst_enable_attrs[6] = dev_attr_queue_6_enst_enable;
    enst_enable_attrs[7] = dev_attr_queue_7_enst_enable;
    enst_enable_attrs[8] = dev_attr_queue_8_enst_enable;
    enst_enable_attrs[9] = dev_attr_queue_9_enst_enable;
    enst_enable_attrs[10] = dev_attr_queue_10_enst_enable;
    enst_enable_attrs[11] = dev_attr_queue_11_enst_enable;
    enst_enable_attrs[12] = dev_attr_queue_12_enst_enable;
    enst_enable_attrs[13] = dev_attr_queue_13_enst_enable;
    enst_enable_attrs[14] = dev_attr_queue_14_enst_enable;
    enst_enable_attrs[15] = dev_attr_queue_15_enst_enable;

    return enst_enable_attrs;
}

static struct device_attribute* get_start_time_s_attrs(void)
{
    static struct device_attribute start_time_s_attrs[16];

    start_time_s_attrs[0] = dev_attr_queue_0_start_time_s;
    start_time_s_attrs[1] = dev_attr_queue_1_start_time_s;
    start_time_s_attrs[2] = dev_attr_queue_2_start_time_s;
    start_time_s_attrs[3] = dev_attr_queue_3_start_time_s;
    start_time_s_attrs[4] = dev_attr_queue_4_start_time_s;
    start_time_s_attrs[5] = dev_attr_queue_5_start_time_s;
    start_time_s_attrs[6] = dev_attr_queue_6_start_time_s;
    start_time_s_attrs[7] = dev_attr_queue_7_start_time_s;
    start_time_s_attrs[8] = dev_attr_queue_8_start_time_s;
    start_time_s_attrs[9] = dev_attr_queue_9_start_time_s;
    start_time_s_attrs[10] = dev_attr_queue_10_start_time_s;
    start_time_s_attrs[11] = dev_attr_queue_11_start_time_s;
    start_time_s_attrs[12] = dev_attr_queue_12_start_time_s;
    start_time_s_attrs[13] = dev_attr_queue_13_start_time_s;
    start_time_s_attrs[14] = dev_attr_queue_14_start_time_s;
    start_time_s_attrs[15] = dev_attr_queue_15_start_time_s;

    return start_time_s_attrs;
}

static struct device_attribute* get_start_time_ns_attrs(void)
{
    static struct device_attribute start_time_ns_attrs[16];

    start_time_ns_attrs[0] = dev_attr_queue_0_start_time_ns;
    start_time_ns_attrs[1] = dev_attr_queue_1_start_time_ns;
    start_time_ns_attrs[2] = dev_attr_queue_2_start_time_ns;
    start_time_ns_attrs[3] = dev_attr_queue_3_start_time_ns;
    start_time_ns_attrs[4] = dev_attr_queue_4_start_time_ns;
    start_time_ns_attrs[5] = dev_attr_queue_5_start_time_ns;
    start_time_ns_attrs[6] = dev_attr_queue_6_start_time_ns;
    start_time_ns_attrs[7] = dev_attr_queue_7_start_time_ns;
    start_time_ns_attrs[8] = dev_attr_queue_8_start_time_ns;
    start_time_ns_attrs[9] = dev_attr_queue_9_start_time_ns;
    start_time_ns_attrs[10] = dev_attr_queue_10_start_time_ns;
    start_time_ns_attrs[11] = dev_attr_queue_11_start_time_ns;
    start_time_ns_attrs[12] = dev_attr_queue_12_start_time_ns;
    start_time_ns_attrs[13] = dev_attr_queue_13_start_time_ns;
    start_time_ns_attrs[14] = dev_attr_queue_14_start_time_ns;
    start_time_ns_attrs[15] = dev_attr_queue_15_start_time_ns;

    return start_time_ns_attrs;
}

static struct device_attribute* get_on_time_attrs(void)
{
    static struct device_attribute on_time_attrs[16];

    on_time_attrs[0] = dev_attr_queue_0_on_time;
    on_time_attrs[1] = dev_attr_queue_1_on_time;
    on_time_attrs[2] = dev_attr_queue_2_on_time;
    on_time_attrs[3] = dev_attr_queue_3_on_time;
    on_time_attrs[4] = dev_attr_queue_4_on_time;
    on_time_attrs[5] = dev_attr_queue_5_on_time;
    on_time_attrs[6] = dev_attr_queue_6_on_time;
    on_time_attrs[7] = dev_attr_queue_7_on_time;
    on_time_attrs[8] = dev_attr_queue_8_on_time;
    on_time_attrs[9] = dev_attr_queue_9_on_time;
    on_time_attrs[10] = dev_attr_queue_10_on_time;
    on_time_attrs[11] = dev_attr_queue_11_on_time;
    on_time_attrs[12] = dev_attr_queue_12_on_time;
    on_time_attrs[13] = dev_attr_queue_13_on_time;
    on_time_attrs[14] = dev_attr_queue_14_on_time;
    on_time_attrs[15] = dev_attr_queue_15_on_time;

    return on_time_attrs;
}

static struct device_attribute* get_off_time_attrs(void)
{
    static struct device_attribute off_time_attrs[16];

    off_time_attrs[0] = dev_attr_queue_0_off_time;
    off_time_attrs[1] = dev_attr_queue_1_off_time;
    off_time_attrs[2] = dev_attr_queue_2_off_time;
    off_time_attrs[3] = dev_attr_queue_3_off_time;
    off_time_attrs[4] = dev_attr_queue_4_off_time;
    off_time_attrs[5] = dev_attr_queue_5_off_time;
    off_time_attrs[6] = dev_attr_queue_6_off_time;
    off_time_attrs[7] = dev_attr_queue_7_off_time;
    off_time_attrs[8] = dev_attr_queue_8_off_time;
    off_time_attrs[9] = dev_attr_queue_9_off_time;
    off_time_attrs[10] = dev_attr_queue_10_off_time;
    off_time_attrs[11] = dev_attr_queue_11_off_time;
    off_time_attrs[12] = dev_attr_queue_12_off_time;
    off_time_attrs[13] = dev_attr_queue_13_off_time;
    off_time_attrs[14] = dev_attr_queue_14_off_time;
    off_time_attrs[15] = dev_attr_queue_15_off_time;

    return off_time_attrs;
}

static ssize_t apply_enst_settings(struct cgrd_priv *priv)
{
    ssize_t error = 0, res;
    u8 i, enst_first_q, enst_last_q;
    if (priv->hwCfg.numQueues>7)
        enst_first_q = priv->hwCfg.numQueues - 8;
    else
        enst_first_q = 0;
    enst_last_q = priv->num_tx_q - 1;
    for (i = enst_first_q; i <= enst_last_q; i++)
    {
        res = priv->eddObj->setEnstEnable(priv->corePriv, i, 0);
        if (res)
            error = res;
    }
    for (i = enst_first_q; i <= enst_last_q; i++)
    {
        res = priv->eddObj->setEnstTimeConfig(priv->corePriv, i,
                &(priv->enstTimeConfig[i]));
        if (res)
            error = res;
        res = priv->eddObj->setEnstEnable(priv->corePriv, i,
                priv->enstEnabled[i]);
        if (res)
            error = res;
    }
    if (!error)
        priv->enstDirty = 0;
    return error;
}

static ssize_t read_enst_settings(struct cgrd_priv *priv)
{
    ssize_t error = 0, res;
    u8 i, enst_first_q, enst_last_q;
    if (priv->hwCfg.numQueues>7)
        enst_first_q = priv->hwCfg.numQueues - 8;
    else
        enst_first_q = 0;
    enst_last_q = priv->num_tx_q - 1;
    for (i = enst_first_q; i <= enst_last_q; i++)
    {
        res = priv->eddObj->getEnstEnable(priv->corePriv, i,
                &(priv->enstEnabled[i]));
        if (res)
            error = res;
        res = priv->eddObj->getEnstTimeConfig(priv->corePriv, i,
                &(priv->enstTimeConfig[i]));
        if (res)
            error = res;
    }
    if (!error)
        priv->enstDirty = 0;
    return error;
}

static ssize_t cgrd_show_enst_apply_setings(struct device *dev,
        struct device_attribute *attr, char *buf) {
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    if (priv->enstDirty)
        return scnprintf(buf, PAGE_SIZE, "1\n");
    else
        return scnprintf(buf, PAGE_SIZE, "0\n");
}

static ssize_t cgrd_store_enst_apply_setings(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t count) {
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    ssize_t res = 0;
    unsigned long value = simple_strtoul(buf, NULL, 0);
    if (value > 1)
        return -EINVAL;
    if (value)
    {
        res = apply_enst_settings(priv);
    }
    if (!res)
        res = count;
    return res;
}

DEVICE_ATTR(enst_apply_settings, S_IWUSR | S_IRUGO,
        cgrd_show_enst_apply_setings, cgrd_store_enst_apply_setings);

static ssize_t cgrd_show_enst_read_setings(struct device *dev,
        struct device_attribute *attr, char *buf) {
    /* dummy function */
    return 0;
}

static ssize_t cgrd_store_enst_read_setings(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t count) {
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    ssize_t res = 0;
    unsigned long value = simple_strtoul(buf, NULL, 0);
    if (value > 1)
        return -EINVAL;
    if (value)
    {
        res = read_enst_settings(priv);
    }
    if (!res)
        res = count;
    return res;
}

DEVICE_ATTR(enst_read_settings, S_IWUSR | S_IRUGO,
        cgrd_show_enst_read_setings, cgrd_store_enst_read_setings);

/* End of EnST (802.1Qbv) control */

static ssize_t cgrd_show_tsu_timer(struct device *dev,
        struct device_attribute *attr, char *buf) {
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    ssize_t res = 0;
    struct CEDI_1588TimerVal timer;
    uint64_t seconds;

    res = priv->eddObj->get1588Timer(priv->corePriv, &timer);
    if(res)
        return res;

    seconds = timer.secsUpper;
    seconds = seconds << 32;
    seconds += timer.secsLower;
    return scnprintf(buf, PAGE_SIZE, "%llu : %d\n", seconds, timer.nanosecs);
}

static ssize_t cgrd_store_tsu_timer(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t count) {
    struct net_device *ndev = to_net_dev(dev);
    struct cgrd_priv *priv = netdev_priv(ndev);
    ssize_t res = 0, res2 = 0;
    struct CEDI_1588TimerVal timer;

    if (sysfs_streq("1", buf))
    {
        /* stop and clear */
        CEDI_TimerIncrement incSettings;
        memset(&incSettings, 0, sizeof(CEDI_TimerIncrement));
        incSettings.nanoSecsInc = 0;
        incSettings.altNanoSInc = 0;
        incSettings.altIncCount = 0;
        incSettings.subNsInc = 0;
        res = priv->eddObj->set1588TimerInc(priv->corePriv,&incSettings);

        timer.secsUpper = 0;
        timer.secsLower = 0;
        timer.nanosecs = 0;

        res2 = priv->eddObj->set1588Timer(priv->corePriv, &timer);
        if(res) return -res;
        if(res2) return -res2;
    }
    else if (sysfs_streq("2", buf))
    {
        CEDI_TimerIncrement incSettings;
        memset(&incSettings, 0, sizeof(CEDI_TimerIncrement));
        incSettings.nanoSecsInc = ns_increment;
        incSettings.altNanoSInc = 0;
        incSettings.altIncCount = 0;
        incSettings.subNsInc = (subns_increment >> EMAC_SUB_NS_INCR_LSB_SIZE) &
                               EMAC_SUB_NS_INCR_MSB_MASK;
        incSettings.lsbSubNsInc = subns_increment &
                                  EMAC_SUB_NS_INCR_LSB_MASK;
        res = priv->eddObj->set1588TimerInc(priv->corePriv,&incSettings);
        if(res) return -res;
    }
    else
    {
        netdev_err(ndev, "Invalid operation for setting TSU timer.\n"
        "1: stop and clear, 2: run\n");
        return -EINVAL;
    }

    return count;
}

DEVICE_ATTR(tsu_value, S_IWUSR | S_IRUGO,
        cgrd_show_tsu_timer, cgrd_store_tsu_timer);

static void cgrd_create_shaping_sysfs(struct cgrd_priv *priv)
{
    struct net_device *ndev = priv->netdev;

    u8 i;
    u8 enst_supported = 0, enst_first_q, enst_last_q;
    struct device_attribute *scheduler_type_attrs = get_scheduler_type_attrs();
    struct device_attribute *scheduler_value_attrs = get_scheduler_value_attrs();

    struct device_attribute *enst_enable_attrs = get_enst_enable_attrs();
    struct device_attribute *enst_start_time_s_attrs = get_start_time_s_attrs();
    struct device_attribute *enst_start_time_ns_attrs = get_start_time_ns_attrs();
    struct device_attribute *enst_on_time_attrs = get_on_time_attrs();
    struct device_attribute *enst_off_time_attrs = get_off_time_attrs();

    if(priv->num_tx_q > 1)
    {
        priv -> sysfsCreated = 1;

        for (i = 0; i < priv->num_tx_q; i++)
        {
            device_create_file(&ndev->dev,  &(scheduler_type_attrs[i]));
            device_create_file(&ndev->dev,  &(scheduler_value_attrs[i]));
        }
        priv->eddObj->getEnstSupported(priv->corePriv, &enst_supported);
        if (enst_supported)
        {
            if (priv->hwCfg.numQueues>7)
                enst_first_q = priv->hwCfg.numQueues - 8;
            else
                enst_first_q = 0;

            enst_last_q = priv->num_tx_q - 1;
            for (i = enst_first_q; i <= enst_last_q; i++)
            {
                device_create_file(&ndev->dev,  &(enst_enable_attrs[i]));
                device_create_file(&ndev->dev,  &(enst_start_time_s_attrs[i]));
                device_create_file(&ndev->dev,  &(enst_start_time_ns_attrs[i]));
                device_create_file(&ndev->dev,  &(enst_on_time_attrs[i]));
                device_create_file(&ndev->dev,  &(enst_off_time_attrs[i]));
            }
            device_create_file(&ndev->dev, &(dev_attr_enst_apply_settings));
            device_create_file(&ndev->dev, &(dev_attr_enst_read_settings));

            read_enst_settings(priv);
        }
    }
}

static void cgrd_remove_shaping_sysfs(struct cgrd_priv *priv)
{
    struct net_device *ndev = priv->netdev;

    u8 i;
    u8 enst_supported = 0, enst_first_q, enst_last_q;
    struct device_attribute *scheduler_type_attrs = get_scheduler_type_attrs();
    struct device_attribute *scheduler_value_attrs = get_scheduler_value_attrs();

    struct device_attribute *enst_enable_attrs = get_enst_enable_attrs();
    struct device_attribute *enst_start_time_s_attrs = get_start_time_s_attrs();
    struct device_attribute *enst_start_time_ns_attrs = get_start_time_ns_attrs();
    struct device_attribute *enst_on_time_attrs = get_on_time_attrs();
    struct device_attribute *enst_off_time_attrs = get_off_time_attrs();

    if (priv->num_tx_q > 1)
    {
        if (!(priv->sysfsCreated))
            return;

        for (i = 0; i < priv->num_tx_q; i++)
        {
            device_remove_file(&ndev->dev,  &(scheduler_type_attrs[i]));
            device_remove_file(&ndev->dev,  &(scheduler_value_attrs[i]));
        }
        priv->eddObj->getEnstSupported(priv->corePriv, &enst_supported);
        if (enst_supported)
        {
            if (priv->hwCfg.numQueues>7)
                enst_first_q = priv->hwCfg.numQueues - 8;
            else
                enst_first_q = 0;
            enst_last_q = priv->num_tx_q - 1;
            for (i = enst_first_q; i <= enst_last_q; i++)
            {
                device_remove_file(&ndev->dev,  &(enst_enable_attrs[i]));
                device_remove_file(&ndev->dev,  &(enst_start_time_s_attrs[i]));
                device_remove_file(&ndev->dev,  &(enst_start_time_ns_attrs[i]));
                device_remove_file(&ndev->dev,  &(enst_on_time_attrs[i]));
                device_remove_file(&ndev->dev,  &(enst_off_time_attrs[i]));
            }
            device_remove_file(&ndev->dev, &(dev_attr_enst_apply_settings));
            device_remove_file(&ndev->dev, &(dev_attr_enst_read_settings));
        }
    }
}

static void cgrd_free_mapped_rx_buf(
        struct cgrd_priv *priv, struct map_info *mbuf) {
    struct sk_buff *skb = mbuf->skb;
    dma_addr_t dmap = mbuf->dmap;

    if (skb) {
        if (dmap) {
            dma_unmap_single(priv->dev_p,
                    dmap, RX_BUF_SZ + IP_HDR_ALIGN, DMA_FROM_DEVICE);
            mbuf->dmap = 0;
        }
        dev_kfree_skb(skb);
        mbuf->skb = NULL;
    }
}

static struct sk_buff *cgrd_alloc_mapped_rx_buf(
        struct cgrd_priv *priv, dma_addr_t *dmap_p) {

    struct sk_buff *skb = netdev_alloc_skb(priv->netdev,
                                            RX_BUF_SZ + IP_HDR_ALIGN);

    if (!skb) {
        netdev_err(priv->netdev,
                "%s: netdev_alloc_skb() failed!\n", __func__);
        return NULL;
    }

    *dmap_p = dma_map_single(priv->dev_p, skb->data,
                                RX_BUF_SZ + IP_HDR_ALIGN, DMA_FROM_DEVICE);

//    if (!priv->hwCfg.pbuf_rsc)
//        skb_reserve(skb, IP_HDR_ALIGN);	/* To align IP header */
        /* rxBufOffset doesn't work if pbuf_rsc defined */

    if (!*dmap_p) {
        netdev_err(priv->netdev, "%s: dma_map_single() failed!\n", __func__);
        dev_kfree_skb(skb);
        return NULL;
    }
    if (dma_mapping_error(priv->dev_p, *dmap_p)) {
        netdev_err(priv->netdev,
                "%s: ***  Error mapping DMA buffer!!!\n", __func__);
        dev_kfree_skb(skb);
        return NULL;
    }

    return skb;
}

#ifdef DEBUG

static void cgrd_tx_queue_dump(struct cgrd_priv *priv, uint8_t qNum) {
    int i, dWords;
    u32 *dwd, pAddr;
    uint16_t dSize;

    /* Tx ring qN */
    dSize = priv->txDesc.allocSize/((TX_Q_SZ+1)*priv->num_tx_q);
    pr_debug("  Tx ring queue %u: descSize=%u\n", qNum, dSize);
    dWords = dSize/sizeof(uint32_t);

    dwd = priv->txDesc.cpuStart + qNum*dSize*(TX_Q_SZ+1);
    pAddr = priv->txDesc.dmaStart + dSize*(TX_Q_SZ+1);
    for (i = 0; i < (TX_Q_SZ+1); i++) {    /* include extra end-stop descriptor */
        switch(dWords) {
         case(6): pr_debug(" %04u (%08X):  %08X %08X  %08X %08X  %08X %08X\n", i, pAddr,
                        dwd[0], dwd[1], dwd[2], dwd[3], dwd[4], dwd[5]); break;
         case(4): pr_debug(" %04u (%08X):  %08X %08X  %08X %08X\n", i, pAddr,
                              dwd[0], dwd[1], dwd[2], dwd[3]); break;
         case(2):
         default: pr_debug(" %04u (%08X):  %08X %08X\n", i, pAddr, dwd[0], dwd[1]); break;
        }
        dwd += dWords;
        pAddr += dSize;
    }
    pr_debug("\n");
}

static void cgrd_rx_queue_dump(struct cgrd_priv *priv, uint8_t qNum) {
    int i, dWords;
    u32 *dwd, pAddr;
    uint16_t dSize;

    /* Rx ring qN */
    dSize = priv->rxDesc.allocSize/((RX_Q_SZ+1)*priv->num_rx_q);
    pr_debug("  Rx ring queue %u: descSize=%u\n", qNum, dSize);
    dWords = dSize/sizeof(uint32_t);

    dwd = priv->rxDesc.cpuStart + qNum*dSize*(RX_Q_SZ+1);
    pAddr = priv->rxDesc.dmaStart + dSize*(RX_Q_SZ+1);
    for (i = 0; i < (RX_Q_SZ+1); i++) {    /* include extra end-stop descriptor */
        switch(dWords) {
         case(6): pr_debug(" %04u (%08X):  %08X %08X  %08X %08X  %08X %08X\n", i, pAddr,
                        dwd[0], dwd[1], dwd[2], dwd[3], dwd[4], dwd[5]); break;
         case(4): pr_debug(" %04u (%08X):  %08X %08X  %08X %08X\n", i, pAddr,
                              dwd[0], dwd[1], dwd[2], dwd[3]); break;
         case(2):
         default: pr_debug(" %04u (%08X):  %08X %08X\n", i, pAddr, dwd[0], dwd[1]); break;
        }
        dwd += dWords;
        pAddr += dSize;
    }
    pr_debug("\n");
}

static void cgrd_dump_regs(struct cgrd_priv *priv) {
    int r1, r2;

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x000, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x004, &r2);
    pr_debug("     network_control(0x000) = %08X      network_config(0x004) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x008, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x010, &r2);
    pr_debug("      network_status(0x008) = %08X          dma_config(0x010) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x018, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x01C, &r2);
    pr_debug("       receive_q_ptr(0x018) = %08X      transmit_q_ptr(0x01C) = %08X\n", r1, r2);

    if (priv->num_rx_q>1) {
        priv->eddObj->readReg(priv->corePriv, (uint16_t)0x480, &r1);
        priv->eddObj->readReg(priv->corePriv, (uint16_t)0x440, &r2);
        pr_debug("      receive_q1_ptr(0x480) = %08X     transmit_q1_ptr(0x440) = %08X\n", r1, r2);
    }

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x014, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x020, &r2);
    pr_debug("     transmit_status(0x014) = %08X      receive_status(0x020) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x034, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x038, &r2);
    pr_debug("      phy_management(0x034) = %08X          pause_time(0x038) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x03c, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x040, &r2);
    pr_debug("    tx_pause_quantum(0x03c) = %08X      pbuf_txcutthru(0x040) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x044, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x048, &r2);
    pr_debug("      pbuf_rxcutthru(0x044) = %08X    jumbo_max_length(0x048) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x054, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x058, &r2);
    pr_debug("    axi_max_pipeline(0x054) = %08X         rsc_control(0x058) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x05C, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x060, &r2);
    pr_debug("      int_moderation(0x05C) = %08X       sys_wake_time(0x060) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x080, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x084, &r2);
    pr_debug("         hash_bottom(0x080) = %08X            hash_top(0x084) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x088, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x08C, &r2);
    pr_debug("    spec_add1_bottom(0x088) = %08X       spec_add1_top(0x08C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x090, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x094, &r2);
    pr_debug("    spec_add2_bottom(0x090) = %08X       spec_add2_top(0x094) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x098, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x09C, &r2);
    pr_debug("    spec_add3_bottom(0x098) = %08X       spec_add3_top(0x09C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0A0, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0A4, &r2);
    pr_debug("    spec_add4_bottom(0x0A0) = %08X       spec_add4_top(0x0A4) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x034, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x038, &r2);
    pr_debug("        wol_register(0x0B8) = %08X       stretch_ratio(0x0BC) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0C0, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0C4, &r2);
    pr_debug("        stacked_vlan(0x0C0) = %08X        tx_pfc_pause(0x0C4) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0C8, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0CC, &r2);
    pr_debug("    mask_add1_bottom(0x0C8) = %08X       mask_add1_top(0x0CC) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0D0, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0D4, &r2);
    pr_debug("    dma_addr_or_mask(0x0D0) = %08X      rx_ptp_unicast(0x0D4) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0D8, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0DC, &r2);
    pr_debug("      tx_ptp_unicast(0x0D8) = %08X        tsu_nsec_cmp(0x0DC) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0D0, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0D4, &r2);
    pr_debug("    dma_addr_or_mask(0x0D0) = %08X      rx_ptp_unicast(0x0D4) = %08X\n", r1, r2);

    /* Tx q0 pbuf fill level */
    priv->eddObj->writeReg(priv->corePriv, (uint16_t)0x0F8, 0x00);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0F8, &r1);
    /* Rx q0 pbuf fill level */
    priv->eddObj->writeReg(priv->corePriv, (uint16_t)0x0F8, 0x01);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0F8, &r2);
    pr_debug(" txq0 dpram_fill_dbg(0x0F8) = %08X rxq0 dpram_fill_dbg(0x0F8) = %08X\n", r1, r2);

    /* Tx q1 pbuf fill level */
    priv->eddObj->writeReg(priv->corePriv, (uint16_t)0x0F8, 0x10);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0F8, &r1);
    /* Rx q1 pbuf fill level */
    priv->eddObj->writeReg(priv->corePriv, (uint16_t)0x0F8, 0x11);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0F8, &r2);
    pr_debug(" txq1 dpram_fill_dbg(0x0F8) = %08X rxq1 dpram_fill_dbg(0x0F8) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x0FC, &r1);
    pr_debug("        revision_reg(0x0D0) = %08X\n", r1);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x100, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x104, &r2);
    pr_debug("  octets_txed_bottom(0x100) = %08X    octets_txed_top(0x104) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x108, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x10C, &r2);
    pr_debug("      frames_txed_ok(0x108) = %08X     broadcast_txed(0x10C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x110, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x114, &r2);
    pr_debug("      multicast_txed(0x110) = %08X  pause_frames_txed(0x114) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x118, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x11C, &r2);
    pr_debug("      frames_txed_64(0x118) = %08X     frames_txed_65(0x11C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x120, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x124, &r2);
    pr_debug("     frames_txed_128(0x120) = %08X    frames_txed_256(0x124) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x128, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x12C, &r2);
    pr_debug("     frames_txed_512(0x128) = %08X   frames_txed_1024(0x12C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x130, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x134, &r2);
    pr_debug("    frames_txed_1519(0x130) = %08X       tx_underruns(0x134) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x138, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x13C, &r2);
    pr_debug("   single_collisions(0x138) = %08X multiple_collisions(0x13C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x140, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x144, &r2);
    pr_debug("excessive_collisions(0x140) = %08X    late_collisions(0x144) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x148, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x14C, &r2);
    pr_debug("     deferred_frames(0x148) = %08X         crs_errors(0x14C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x150, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x154, &r2);
    pr_debug("  octets_rxed_bottom(0x150) = %08X    octets_rxed_top(0x154) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x158, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x15C, &r2);
    pr_debug("      frames_rxed_ok(0x158) = %08X     broadcast_rxed(0x15C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x160, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x164, &r2);
    pr_debug("      multicast_rxed(0x160) = %08X  pause_frames_rxed(0x164) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x168, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x16C, &r2);
    pr_debug("      frames_rxed_64(0x168) = %08X     frames_rxed_65(0x16C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x170, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x174, &r2);
    pr_debug("     frames_rxed_128(0x170) = %08X    frames_rxed_256(0x174) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x150, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x154, &r2);
    pr_debug("  octets_rxed_bottom(0x150) = %08X    octets_rxed_top(0x154) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x158, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x15C, &r2);
    pr_debug("      frames_rxed_ok(0x158) = %08X     broadcast_rxed(0x15C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x160, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x164, &r2);
    pr_debug("      multicast_rxed(0x160) = %08X  pause_frames_rxed(0x164) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x168, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x16C, &r2);
    pr_debug("      frames_rxed_64(0x168) = %08X     frames_rxed_65(0x16C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x170, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x174, &r2);
    pr_debug("     frames_rxed_128(0x170) = %08X    frames_rxed_256(0x174) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x178, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x17C, &r2);
    pr_debug("     frames_rxed_512(0x178) = %08X   frames_rxed_1024(0x17C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x180, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x184, &r2);
    pr_debug("    frames_rxed_1519(0x180) = %08X   undersize_frames(0x184) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x188, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x18C, &r2);
    pr_debug(" excessive_rx_length(0x188) = %08X         rx_jabbers(0x18C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x190, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x194, &r2);
    pr_debug("          fcs_errors(0x190) = %08X   rx_length_errors(0x194) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x198, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x19C, &r2);
    pr_debug("    rx_symbol_errors(0x198) = %08X   alignment_errors(0x19C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x1A0, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x1A4, &r2);
    pr_debug("  rx_resource_errors(0x1A0) = %08X        rx_overruns(0x1A4) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x1A8, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x1AC, &r2);
    pr_debug("     rx_ip_ck_errors(0x1A8) = %08X   rx_tcp_ck_errors(0x1AC) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x1B0, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x1B4, &r2);
    pr_debug("    rx_udp_ck_errors(0x1B0) = %08X  auto_flushed_pkts(0x1B4) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x200, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x204, &r2);
    pr_debug("         pcs_control(0x200) = %08X         pcs_status(0x204) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x208, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x20C, &r2);
    pr_debug("      pcs_phy_top_id(0x208) = %08X     pcs_phy_bot_id(0x20C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x280, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x284, &r2);
    pr_debug("    designcfg_debug1(0x280) = %08X   designcfg_debug2(0x284) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x288, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x28C, &r2);
    pr_debug("    designcfg_debug3(0x288) = %08X   designcfg_debug4(0x28C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x290, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x294, &r2);
    pr_debug("    designcfg_debug5(0x290) = %08X   designcfg_debug6(0x294) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x298, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x29C, &r2);
    pr_debug("    designcfg_debug7(0x298) = %08X   designcfg_debug8(0x29C) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x2A0, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x2A4, &r2);
    pr_debug("    designcfg_debug9(0x2A0) = %08X  designcfg_debug10(0x2A4) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x4C8, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x4CC, &r2);
    pr_debug("upper_tx_q_base_addr(0x4C8) = %08X      tx_bd_control(0x4CC) = %08X\n", r1, r2);

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x4D4, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x4D0, &r2);
    pr_debug("upper_rx_q_base_addr(0x4D4) = %08X      rx_bd_control(0x4D0) = %08X\n", r1, r2);
}

static void cgrd_dump_regs_and_tx_queue(struct cgrd_priv *priv, uint8_t qNum) {
    int r1, r2;

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x024, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x030, &r2);
    pr_debug("\n    Debug dump: q0  isr=%08X, imr=%08X\n", r1, r2);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x400, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x640, &r2);
    pr_debug("\n                q1: isr=%08X, imr=%08X\n", r1, r2);

    cgrd_tx_queue_dump(priv, qNum);

    cgrd_dump_regs(priv);
}

static void cgrd_dump_regs_and_rx_queue(struct cgrd_priv *priv, uint8_t qNum) {
    int r1, r2;

    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x024, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x030, &r2);
    pr_debug("\n    Debug dump: q0  isr=%08X, imr=%08X\n", r1, r2);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x400, &r1);
    priv->eddObj->readReg(priv->corePriv, (uint16_t)0x640, &r2);
    pr_debug("\n                q1: isr=%08X, imr=%08X\n", r1, r2);

    cgrd_rx_queue_dump(priv, qNum);

    cgrd_dump_regs(priv);
}

#else
#define cgrd_dump_regs_and_tx_queue(priv, qNum)
#define cgrd_dump_regs_and_rx_queue(priv, qNum)
#endif


void cgrd_reset_rx_state(struct cgrd_priv *priv, uint8_t qNum) {
    priv->rx_frag[qNum].head_skb = NULL;
    priv->rx_frag[qNum].tail_skb = NULL;
    priv->fr_sub_len[qNum] = 0;
}

/**
 * Receive a frame from the queue
 * @param   priv        Pointer to core private data
 * @param   qNum        Number of the RX queue.
 * @return          Number of frames processed
 */
static u32 cgrd_receive(struct cgrd_priv *priv, uint8_t qNum) {
    struct net_device *ndev = priv->netdev;
    struct map_info *pReady = &priv->rxReady[qNum];
    struct sk_buff *this_skb;
    struct sk_buff *rx_skb, *head, *tail;
    uint32_t result;
    CEDI_RxDescData descDat;
    CEDI_BuffAddr tmp_buf;
    CEDI_RxDescStat rdstat;
    uint32_t count = 0;

    while (true) {  /* read until none available */

        /* new skb to replace the one containing received data */
        this_skb = pReady->skb;
        tmp_buf.vAddr = (uintptr_t)this_skb;
        tmp_buf.pAddr = pReady->dmap;

        /* Read the packet, exchanging buffers with the core driver */
        result = -priv->eddObj->readRxBuf(priv->corePriv, qNum,
                                            &tmp_buf, 0, &descDat);

        /* Hard failure */
        if (result) {
            netdev_err(ndev, "*** Error - readRxBuf failure !!!!\n");
            return count;
        }

        if (CEDI_RXDATA_NODATA == descDat.status)
            return count;

        /* check returned buffer */
        rx_skb = (void *)tmp_buf.vAddr;

        /* If HW has not replaced the buffer, nothing to read */
        if (this_skb==rx_skb)
            return count;

        /* error in returning skb address */
        if ((rx_skb==NULL) || (rx_skb==0)) {
            netdev_err(ndev, "*** Error - returned rx_skb = %p\n", rx_skb);
            return count;
        }

        /* Alloc a new ready buffer to replace the one we consumed */
        pReady->skb = cgrd_alloc_mapped_rx_buf(priv, &pReady->dmap);
        if (!pReady->skb) {
            /* if we couldn't alloc, recycle the received one. */
            netdev_err(ndev, "*** Error - failed to alloc new Rx buffer! (dropping frame)\n");
            pReady->skb = rx_skb;
            pReady->dmap = tmp_buf.pAddr;
            ++ndev->stats.rx_dropped;
            return count;
        }
/*        netdev_dbg(ndev, "%s New Spare Rx buffer: q=%u skb=%p dmap=%p\n",
                    __func__, qNum, (void *)pReady->skb, (void *)pReady->dmap);*/

        /* Unmap the received buffer */
        dma_unmap_single(priv->dev_p,
                (dma_addr_t)tmp_buf.pAddr, RX_BUF_SZ + IP_HDR_ALIGN, DMA_FROM_DEVICE);

        priv->eddObj->getRxDescStat(priv->corePriv, descDat.rxDescStat, &rdstat);

        head = priv->rx_frag[qNum].head_skb;
        tail = priv->rx_frag[qNum].tail_skb;
        /* Discard if out-of-sequence or header split across buffers */
        if (((head==NULL)   /* first frame buffer */
                && ((!rdstat.sof) || (rdstat.header && !rdstat.eoh)))
                                                /* only accept whole header buffers */
            || ((head!=NULL) && (rdstat.sof)))     /* new start before EOF */
        {
            netdev_err(ndev, "Incomplete frame received! (head_skb=%p sof=%u hdr=%u eoh=%u)\n",
                        (void *)head, (u32)rdstat.sof,
                        (u32)rdstat.header, (u32)rdstat.eoh);
            //cgrd_dump_regs_and_rx_queue(priv, qNum);
            //netdev_dbg(ndev, "%s: queue=%u  hdr:%u  eoh:%u  len=%u\n",
            //           __func__, qNum, rdstat.header, rdstat.eoh, rdstat.bufLen);
            //cgrd_dump_buf("    received data", qNum, rx_skb->data, rdstat.bufLen);

            ++ndev->stats.rx_dropped;
            dev_kfree_skb(rx_skb);              /* free buffers already rx'd */
            this_skb = head;
            while (this_skb!=NULL) {
                rx_skb = this_skb;
                this_skb = skb_shinfo(rx_skb)->frag_list;
                dev_kfree_skb(rx_skb);
            }
            cgrd_reset_rx_state(priv, qNum);
            continue;

        }

        /* buffer lengths returned by readRxBuf: eoh => header size,
         *  eof => frame size, else length is rxBufLen */
        if (rdstat.eoh)
            rdstat.bufLen -= priv->fr_sub_len[qNum];
        else if (rdstat.eof)
            rdstat.bufLen -= priv->fr_sub_len[qNum];
        else
            rdstat.bufLen = priv->rxBufLen[qNum];

#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
	if (descDat.rxTsData.tsValid){
	    add_hwtstamp(skb_hwtstamps(rx_skb), descDat.rxTsData.tsSecs,descDat.rxTsData.tsNanoSec);
	}
#endif

	skb_put(rx_skb, rdstat.bufLen);
	//skb_put(rx_skb, rdstat.bufLen - 4); /* Subtract the size of the CRC */
        rx_skb->dev = ndev;

        //  save descData in cb including timestamp
        memcpy(&(rx_skb->cb[0]), &descDat, sizeof(CEDI_RxDescData));

        if (head==NULL) {
            //netdev_dbg(ndev, "%s: first buffer queue=%u  skb=%p\n", __func__, qNum, rx_skb);
            /* set protocol from first buffer */
            rx_skb->protocol = eth_type_trans(rx_skb, ndev);
            // start fragment list, ie. head_skb=skb, tail_skb=skb
            priv->rx_frag[qNum].head_skb = rx_skb;
            priv->rx_frag[qNum].tail_skb = rx_skb;
            head = priv->rx_frag[qNum].head_skb;
            tail = priv->rx_frag[qNum].tail_skb;
        }
        else {  /* not first buffer in frame */
            //netdev_dbg(ndev, "%s: later buffer queue=%u  skb=%p\n", __func__, qNum, rx_skb);
            //  add to fragment list, first skb->frag_list=skb, else tail->next=skb
            if (skb_shinfo(head)->frag_list==NULL)
                skb_shinfo(head)->frag_list = rx_skb;
            else
                tail->next = rx_skb;
            // new tail
            priv->rx_frag[qNum].tail_skb = rx_skb;
            //  increment len & data_len
            head->len += rdstat.bufLen;
            head->data_len += rdstat.bufLen;
            head->truesize += rdstat.bufLen;
        }

        netdev_dbg(ndev, "%s: queue=%u  buflen=%u  eof=%u  chkOffStat=%u\n",
                        __func__, qNum, rdstat.bufLen, rdstat.eof, rdstat.chkOffStat);
        //cgrd_dump_buf("    received data", qNum, rx_skb->data, rdstat.bufLen);

        if (rdstat.eof) {
            /**
             * TCP, UDP: tell stack that we've checked everything.
             * For non-TCP/UDP just let the stack check the IP hdr.
             */
            if (rdstat.chkOffStat >= 2) {
                priv->rx_frag[qNum].head_skb->ip_summed = CHECKSUM_UNNECESSARY;
            }

            count++;
                /* send complete frame up the stack */
            /*netdev_dbg(ndev, "%s: sending up frame on queue %u  skb=%p  skb->len=%u"\
                         "  skb->data_len=%u  frag_list=%p  frag_list->len=%u\n",
                         __func__,
                         qNum,
                         head,
                         head->len,
                         head->data_len,
                         skb_shinfo(head)->frag_list,
                         (skb_shinfo(head)->frag_list==NULL)?0:skb_shinfo(head)->frag_list->len);*/

            netif_receive_skb(head);
//            if (NET_RX_SUCCESS != (result=netif_receive_skb(head)))
//                netdev_dbg(ndev, "*** netif_receive_skb returned %u\n", result);

            //    reset state
            cgrd_reset_rx_state(priv, qNum);

            //netdev_dbg(ndev, "%s: after eof, head=%p  tail=%p\n",
            //                    __func__, priv->rx_frag[qNum].head_skb, priv->rx_frag[qNum].tail_skb);
        }
        else
            priv->fr_sub_len[qNum] += rdstat.bufLen;
    }

    /* shouldn't reach here */
    netdev_err(ndev, "*** Error exit from receive loop!!!)\n");

    return count;
}

/**
 * Check writeback status of freed Tx descriptor
 * @param   priv        Pointer to core private data
 * @param   descDat     status read from descriptor
 */
static int cgrd_check_tx_wrback(struct cgrd_priv *priv, CEDI_TxDescData descDat) {
    struct net_device *ndev = priv->netdev;
    CEDI_TxDescStat txDStat;
    int ret = 0;

    /* Check write-back descriptor status */
    priv->eddObj->getTxDescStat(priv->corePriv, descDat.txDescStat, &txDStat);
    if ((txDStat.chkOffErr) || (txDStat.lateColl) || (txDStat.frameCorr)
                  || (txDStat.txUnderrun) || (txDStat.retryExc)) {
        if (txDStat.chkOffErr) {
//               netdev_dbg(ndev, "%s: Tx checksum offload status = %u!\n",
//                                              __func__, txDStat.chkOffErr);
            switch (txDStat.chkOffErr) {
             case CEDI_TXD_CHKOFF_VLAN_HDR_ERR:
                netdev_err(ndev, "   ***  Tx chksum off error - VLAN header error\n");
                break;
             case CEDI_TXD_CHKOFF_SNAP_HDR_ERR:
                netdev_err(ndev, "   ***  Tx chksum off error - SNAP header error\n");
                break;
             case CEDI_TXD_CHKOFF_INVALID_IP:
                netdev_err(ndev, "   ***  Tx chksum off error - Invalid IP packet\n");
                break;
//            case CEDI_TXD_CHKOFF_INVALID_PKT:
//               netdev_err(ndev, "   ***  Tx chksum off error - Invalid packet - not VLAN, SNAP or IP\n");
//               break;
             case CEDI_TXD_CHKOFF_PKT_FRAGMENT:
                netdev_dbg(ndev, "%s",
                        "   Tx writeback status: Non-supported packet fragmentation (IPv4 checksum generated)\n");
                break;
//            case CEDI_TXD_CHKOFF_NON_TCP_UDP:
//               netdev_err(ndev, "   ***  Tx chksum off error - Non TCP or UDP packet\n");
//               break;
             case CEDI_TXD_CHKOFF_PREM_END_PKT:
                netdev_err(ndev, "   ***  Tx chksum off error - Premature end of packet\n");
                break;
            }
        }
        if (txDStat.lateColl) {
            netdev_err(ndev, "*** Tx late collision error!\n");
            ret = 1;
        }
        if (txDStat.frameCorr) {
            netdev_err(ndev, "*** Tx frame corruption error! wd1=0x%08X\n", descDat.txDescStat);
            ret = 1;
        }
        if (txDStat.txUnderrun) {
            netdev_err(ndev, "*** Tx frame underrun error!\n");
            ret = 1;
        }
        if (txDStat.retryExc) {
            netdev_err(ndev, "*** Tx retry limit exceeded, Tx error detected!\n");
            ret = 1;
        }
    }
    return ret;
}

/**
 * Free any completed descriptors on this queue
 * @param	priv		Pointer to core private data
 * @param	qNum		Tx queue index
 * @return			Number of frames processed
 */
static u32 cgrd_tx_complete(struct cgrd_priv *priv, uint8_t qNum, uint8_t irq_spinlocked) {
    struct net_device *ndev = priv->netdev;
    uint32_t result, lso = 0;
    CEDI_TxDescData descDat;
    struct sk_buff *skb = NULL;
    unsigned int len, info;
    unsigned int descs = 0, nr_frags = 0;
    unsigned int desc = 0;  /* descriptor-count within an skb*/
    unsigned int tout = FREE_SKB_TIMEOUT;
    CEDI_BuffAddr tmp_buf;
    u32 skb_freed = 0;
    int err=0;
    unsigned long flags;

    while (tout) {
        if (!irq_spinlocked)
            spin_lock_irqsave(&priv->lock, flags);
        result = -priv->eddObj->freeTxDesc(priv->corePriv, qNum, &descDat);
        if (!irq_spinlocked)
            spin_unlock_irqrestore(&priv->lock, flags);
        if (0 != result) {
            if ((result==-EIO) || (result==-EINVAL))
                netdev_err(ndev, "%s: freeTxDesc returned error :%d\n",
                        __func__, -result);
            break;
        }
        if (CEDI_TXDATA_NONE_FREED==descDat.status) {
            break;
        }
        tmp_buf = descDat.bufAdd;
        if (!tmp_buf.pAddr) {
            netdev_err(ndev, "%s: Bad pAddr!\n", __func__);
            break;
        }

        /* handle first descriptor of sk_buff */
        if (!skb) {
            err = cgrd_check_tx_wrback(priv, descDat);

            skb = (void *)tmp_buf.vAddr;
            if (!skb) {
                netdev_err(ndev, "*** %s: Bad skb! (==0)\n", __func__);
                break;
            }
            descs = skb->cb[0];
            if (!descs) {
                netdev_err(ndev, "*** %s: No descriptors!\n", __func__);
                break;
            }
            nr_frags = skb_shinfo(skb)->nr_frags;
            lso = skb_is_gso(skb);
/*            netdev_dbg(ndev, "%s: handling first skb desc: skb=%p lso=%u"\
                                " frags=%u descs=%u\n",
                      __func__, skb, lso, nr_frags, descs);*/
            info = 0;

#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
	    /* check for timestamp */
	    if (descDat.txTsData.tsValid) {
		struct skb_shared_hwtstamps shhwtstamps;

		shhwtstamps.hwtstamp = ktime_set(descDat.txTsData.tsSecs,
						  descDat.txTsData.tsNanoSec);
		skb_tstamp_tx(skb, &shhwtstamps);
	    }
#endif

	}
        else {
//            netdev_dbg(ndev, "%s: Later desc: lso=%u\n", __func__, lso);
            info = tmp_buf.vAddr;
//            if (lso)
//                netdev_dbg(ndev, "%s: LSO desc %u  MSS=%u\n", __func__, desc,
//                     (descDat.txDescStat>>16) & 0x3FFF);
        }

        len = descDat.txDescStat & CEDI_TXD_LMASK;
//        netdev_dbg(ndev, "%s: desc %u, info=0x%08X\n", __func__, desc, info);
        if (desc!=TX_DESC(info)) {
            netdev_err(ndev, "*** %s: Descriptor number error on d%u: read %u!\n",
                        __func__, desc, TX_DESC(info));
            break;
        }

        /* unmap buffer */
        if (PAGE_MAPPED(info)) {
            if (err) {
                netdev_dbg(ndev, "%s: TxErr - unmapping page buffer pAddr=%p\n",
                                    __func__, (void *)tmp_buf.pAddr);
                err = 0;
            }
            dma_unmap_page(priv->dev_p, (dma_addr_t)tmp_buf.pAddr,
                            len, DMA_TO_DEVICE);
            page_map--;
        }
        else {
            if (err) {
                netdev_dbg(ndev, "%s: TxErr - Unmapping single buffer pAddr=%p\n",
                                __func__, (void *)tmp_buf.pAddr);
                err = 0;
            }
            dma_unmap_single(priv->dev_p, (dma_addr_t)tmp_buf.pAddr,
                            len, DMA_TO_DEVICE);
            sgl_map--;
        }

        /* check descriptor frame status */
        if ((desc==0) && (descs==1)) {
            if (CEDI_TXDATA_1ST_AND_LAST!=descDat.status) {
                netdev_err(ndev,
                    "%s: Bad single desc! - freeTxDesc returned %u\n",
                    __func__, descDat.status);
                break;
            }
        }
        else if ((desc==0) && (descs>1)) {
            if (CEDI_TXDATA_1ST_NOT_LAST!=descDat.status) {
                netdev_err(ndev,
                    "%s: Bad first desc! - freeTxDesc returned %u\n",
                    __func__, descDat.status);
                break;
            }
        } else if ((desc>0) && (desc<descs-1)) {
            if (CEDI_TXDATA_MID_BUFFER!=descDat.status) {
                netdev_err(ndev,
                    "%s: Bad mid desc! (desc %u, frag %u) - "\
                    "freeTxDesc returned %u\n",
                    __func__, desc, TX_FRAG(info), descDat.status);
                break;
            }
        } else {
            if (CEDI_TXDATA_LAST_BUFFER!=descDat.status) {
                netdev_err(ndev,
                    "%s: Bad last desc! (desc %u, frag %u) - "\
                    "freeTxDesc returned %u\n",
                    __func__, desc, TX_FRAG(info), descDat.status);
                break;
            }
        }
        desc++;

        if (desc==descs) {
            /*netdev_dbg(ndev, "%s: skb finished: lso=%u descs=%u frags=%u\n",
                                __func__, lso, descs, nr_frags);*/
            dev_kfree_skb(skb);
            skb = NULL;
            desc = 0;
            ++skb_freed;
//            netdev_dbg(ndev, "%s: txbuf freed on qNum=%u\n", __func__, qNum);
        }

        tout--;
    }   /* while(tout) */

    if (skb!=NULL)
        netdev_err(ndev, "%s: Error: timeout while handling skb %p!\n", __func__, skb);

    return skb_freed;
}

/**
 * Enable or disable network traffic interrupts
 * @param priv		Private data for this device instance
 * @param enable	Nonzero to enable interrupts
 */
static void cgrd_irq_control(struct cgrd_priv *priv, int enable) {
    u32 qNum;

    for (qNum = priv->num_rx_q; qNum > 0; ) {
        --qNum;
        priv->eddObj->setEventEnable(priv->corePriv,
                    qNum?(CEDI_EVSET_TX_RX_EVENTS & CEDI_EVSET_ALL_QN_EVENTS)\
                        :CEDI_EVSET_TX_RX_EVENTS,
                                enable, qNum);
    }
}

/**
 * The NAPI Rx poll routine. We try to guarantee each priority level an
 * even share of the total bandwidth using a simple round-robin approach
 * in order to prevent starvation, with high priority getting first chance
 * at any excess bandwidth.
 * @param napi		points to kernel-defined NAPI control struct
 * @param budget	Number of packets to try to service this quantum.
 */
static int cgrd_poll(struct napi_struct *napi, int budget) {
    struct cgrd_priv *priv = container_of(napi, struct cgrd_priv, napi);
    unsigned int qNum;
    u32 per_prio_budget = budget / priv->num_rx_q;
    u32 per_prio_processed = 0;
    u32 processed = 0, frRead;
    u32 prio_full = 0;

    /* start from highest prio */
    for (qNum = priv->num_tx_q; qNum > 0; ) {
        --qNum;
        if (cgrd_tx_complete(priv, qNum, 0)) {
            /* Restart the queue if it was previously full */
            if (__netif_subqueue_stopped(priv->netdev, qNum))
                netif_wake_subqueue(priv->netdev, qNum);
        }
    }

    qNum = priv->num_rx_q - 1;	/* start from highest prio */
    for (;;) {
        if (0 != (frRead = cgrd_receive(priv, qNum))) {
            processed += frRead;
            if (processed >= budget)
                break;
            per_prio_processed += frRead;
            if (per_prio_processed < per_prio_budget)
                continue;
            prio_full = 1;
        }
        per_prio_processed = 0;
        if (qNum > 0) {
            --qNum;
            continue;
        }
        /* If none of the queues reached quota, we're done. */
        if (!prio_full)
            break;
        /* Else walk the queues again */
        prio_full = 0;
        qNum = priv->num_rx_q - 1;
    }
    if (processed < budget) {
        napi_complete(napi);
        /* re-enable interrupts */
        cgrd_irq_control(priv, EMAC_IRQ_ENABLE);
    }
    return processed;
}

/***********************************************************************
 * MDIO init and access functions
 **********************************************************************/

/**
 * Read the contents of a PHY register
 * @param	bus	Pointer to bus on which the PHY is registered
 * @param	phy_id	The PHY ID on this bus
 * @param	regnum	The PHY's register number.
 *
 * @return	The register contents
 */
static int cgrd_mdio_read(struct mii_bus *bus, int phy_id, int regnum) {
    struct cgrd_priv *priv = bus->priv;
    int result;
    uint16_t data;

#ifdef EMAC_SELECT_SGMII
    uint32_t data32;

    /* make our PCS regs look like a PHY */
    
    result = priv->eddObj->readReg(priv->corePriv,
                                   (uint16_t)0x200+(regnum<<2),
                                   &data32);
    data = data32 & 0xffff;
#else
    if (regnum & MII_ADDR_C45) {
        uint8_t dev_type = (regnum >> 16) & 0x1f;

        regnum &= 0x0ffff;
        priv->eddObj->phyStartMdioWrite(priv->corePriv,
                CEDI_MDIO_FLG_CLAUSE_45 | CEDI_MDIO_FLG_SET_ADDR,
                phy_id, dev_type, regnum);
        while (!priv->eddObj->getMdioIdle(priv->corePriv))
            cpu_relax();
        priv->eddObj->phyStartMdioRead(priv->corePriv,
                CEDI_MDIO_FLG_CLAUSE_45, phy_id, dev_type);
    } else {
        priv->eddObj->phyStartMdioRead(priv->corePriv,
                0, phy_id, regnum);
    }
    while (!priv->eddObj->getMdioIdle(priv->corePriv))
        cpu_relax();
    result = priv->eddObj->getMdioReadData(priv->corePriv, &data);
#endif
//    netdev_dbg(priv->netdev, "%s: phy %u reg_add %xh contains %Xh\n",
//            __func__, phy_id, regnum, data);
    return (int)data;
}

/**
 * Write to a PHY register
 * @param	bus	Pointer to bus on which the PHY is registered
 * @param	phy_id	The PHY ID on this bus
 * @param	regnum	The PHY's register number.
 * @param	value	The value to be written.
 *
 * @return	Result (always zero?)
 */
static int cgrd_mdio_write(struct mii_bus *bus,
        int phy_id, int regnum, u16 value) {
    struct cgrd_priv *priv = bus->priv;

    netdev_dbg(priv->netdev, "%s: phy %u reg_add %xh value %xh\n",
            __func__, phy_id, regnum, value);
#ifdef EMAC_SELECT_SGMII
    /* make our PCS regs look like a PHY */
    
    priv->eddObj->writeReg(priv->corePriv,
                           (uint16_t)0x200+(regnum<<2),
                           (uint32_t)value);
#else
    if (regnum & MII_ADDR_C45) {
        uint8_t dev_type = (regnum >> 16) & 0x1f;

        regnum &= 0x0ffff;
        priv->eddObj->phyStartMdioWrite(priv->corePriv,
                CEDI_MDIO_FLG_CLAUSE_45 | CEDI_MDIO_FLG_SET_ADDR,
                phy_id, dev_type, regnum);
        while (!priv->eddObj->getMdioIdle(priv->corePriv))
            cpu_relax();
        priv->eddObj->phyStartMdioWrite(priv->corePriv,
                CEDI_MDIO_FLG_CLAUSE_45, phy_id, dev_type, value);
    } else {
        priv->eddObj->phyStartMdioWrite(priv->corePriv,
                0, phy_id, regnum, value);
    }
    while (!priv->eddObj->getMdioIdle(priv->corePriv))
        cpu_relax();
#endif
    return 0;
}

/**
 * Reset the bus
 * @param	bus	Pointer to bus on which the PHY is registered
 *
 * @return	Result (always zero?)
 */
static int cgrd_mdio_reset(struct mii_bus *bus) {
    return 0;
}

/**
 * Unregister and free mdio bus resources
 * @param	priv	pointer to private data
 */
static void cgrd_mdio_destroy(struct cgrd_priv *priv) {
    struct mii_bus *mbus = priv->mii_bus;

    if (mbus) {
        mdiobus_unregister(mbus);
        if (mbus->irq)
            kfree(mbus->irq);
        mdiobus_free(mbus);
        priv->mii_bus = NULL;
    }
}

/**
 * Register an MDIO bus and probe for PHY devices.
 * @param	priv	pointer to private data
 *
 * @return	0 if successful
 */
static int cgrd_mdio_init(struct cgrd_priv *priv) {
    int result = -ENOMEM;
    struct mii_bus *mbus;
    u32 ix;

    priv->mii_bus = mbus = mdiobus_alloc();
    if (NULL == mbus)
        goto mii_out;

    mbus->name = "EMAC MII bus";
    mbus->read = &cgrd_mdio_read;
    mbus->write = &cgrd_mdio_write;
    mbus->reset = &cgrd_mdio_reset;
    snprintf(mbus->id, MII_BUS_ID_SIZE, "%s", priv->netdev->name);
    mbus->priv = priv;
    mbus->parent = &priv->netdev->dev;
    mbus->phy_mask = EMAC_PHY_MASK;
    mbus->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
    if (NULL == mbus->irq)
        goto mii_out;
    for (ix = 0; ix < PHY_MAX_ADDR; ++ix)
        mbus->irq[ix] = PHY_POLL;

    dev_set_drvdata(&priv->netdev->dev, mbus);
    if (mdiobus_register(mbus))
        goto mii_out;
    return 0;

    mii_out:
    cgrd_mdio_destroy(priv);
    return result;
}

/***********************************************************************
 * PHY access functions
 **********************************************************************/

/**
 * Called by PHY subsystem whenever it thinks link status may have changed.
 *
 * @param	ndev		Device instance data
 */
static void cgrd_link_changed(struct net_device *ndev) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct phy_device *phydev = priv->phydev;
    unsigned long flags;
    unsigned int changed = 0;
    uint32_t ours, theirs;
    unsigned int qNum;

    spin_lock_irqsave(&priv->lock, flags);
//    netdev_dbg(ndev, "cgrd_link_changed called\n");

    if (phydev->link) {
        if (priv->speed != phydev->speed) {
            CEDI_IfSpeed ifSpeed;

            switch (phydev->speed) {
            default:
            case SPEED_10:
                ifSpeed = CEDI_SPEED_10M;
                break;
            case SPEED_100:
                ifSpeed = CEDI_SPEED_100M;
                break;
            case SPEED_1000:
                ifSpeed = CEDI_SPEED_1000M;
                break;
            case SPEED_2500:
                ifSpeed = CEDI_SPEED_2500M;
            }
            priv->eddObj->setIfSpeed(priv->corePriv, ifSpeed);
            priv->speed = phydev->speed;
            changed = 1;
        }
        if (priv->duplex != phydev->duplex) {
            priv->eddObj->setFullDuplex(priv->corePriv,
                    (DUPLEX_HALF != phydev->duplex) );
            priv->duplex = phydev->duplex;
            changed = 1;
        }
    }
    if (phydev->link != priv->link) {
        if (!phydev->link) {
            priv->speed = 0;
            priv->duplex = -1;
        }
        priv->link = phydev->link;
        changed = 1;
    }
    if (changed) {
        phy_print_status(phydev);
        if (phydev->link) {
            cgrd_set_cbs_shaping(priv, PRIO_HI);
            cgrd_set_cbs_shaping(priv, PRIO_2ND);
            /* when Rx reset, queue pointers for queue>0 will be reset */
            if (priv->num_rx_q>1) {
                for (qNum=1; qNum<priv->num_rx_q; qNum++);
                    priv->eddObj->resetRxQ(priv->corePriv, qNum, 1);
            }
            priv->eddObj->enableRx(priv->corePriv);
            netif_carrier_on(ndev);
            netdev_dbg(ndev, "Link up or changed\n");
            	    /* rx pause resolution function */
#ifdef EMAC_SELECT_SGMII
            priv->eddObj->readReg(priv->corePriv,
                                  (uint16_t)0x210,
                                  &ours);
            priv->eddObj->readReg(priv->corePriv,
                                  (uint16_t)0x214,
                                  &theirs);
            priv->eddObj->setPauseEnable(priv->corePriv,
					 (((ours & 0x180)==0x080) && ((theirs & 0x080)==0x080)) ||
					 (((ours & 0x180)==0x180) && ((theirs & 0x180)!=0)));
#else
            ours = cgrd_mdio_read(phydev->bus, 7, 4);
            theirs = cgrd_mdio_read(phydev->bus, 7, 5);
            priv->eddObj->setPauseEnable(priv->corePriv,
					 (((ours & 0xc00)==0x400) && ((theirs & 0x400)==0x400)) ||
					 (((ours & 0xc00)==0xc00) && ((theirs & 0xc00)!=0)));
	                //priv->eddObj->setPauseEnable(priv->corePriv, 0!=phydev->pause);
#endif
        } else {
            netif_carrier_off(ndev);
            priv->eddObj->disableRx(priv->corePriv);
            netdev_dbg(ndev, "Link down\n");
        }
    }
    spin_unlock_irqrestore(&priv->lock, flags);
}

/**
 * Locate and bind to a PHY
 * @param	priv	pointer to private data
 * @return	nonzero if bind failed
 */
static int cgrd_phy_probe(struct cgrd_priv *priv) {
    struct phy_device *phydev;
    int result = -ENODEV;
    struct net_device *ndev = priv->netdev;

    phydev = phy_find_first(priv->mii_bus);
    if (NULL == phydev) {
        netdev_err(ndev, "No PHY found!\n");
        goto done;
    }
    result = phy_connect_direct(ndev, phydev,
#if LINUX_VERSION_CODE < KERNEL_VERSION(3,9,0)
            cgrd_link_changed, 0, EMAC_PHY_MODE);
#else
            cgrd_link_changed, EMAC_PHY_MODE);
#endif
    if (result) {
        netdev_err(ndev, "Connect to PHY failed!\n");
        goto done;
    }
    netdev_dbg(ndev, "PHY supported features=%Xh\n", phydev->supported);
    netdev_dbg(ndev, "PHY advertising features=%Xh\n", phydev->advertising);
#ifndef EMAC_MDIO
    /* don't want to mess with these if there is a real PHY */
    phydev->supported = PHY_GBIT_FEATURES;
    phydev->supported |= SUPPORTED_Pause;
    phydev->supported |= SUPPORTED_2500baseX_Full;
    netdev_dbg(ndev, "PHY forced features=%Xh\n", phydev->supported);
    phydev->advertising = phydev->supported;
#endif

#ifdef NIC_BR
    // reset PHY
    cgrd_mdio_write(priv->mii_bus, 0, 0, 0x8000);
    // enable expansion register 0x0e
    cgrd_mdio_write(priv->mii_bus, 0, 0x17, 0x0f0e);
    // write it -- set [11] to enable MII-Lite
    cgrd_mdio_write(priv->mii_bus, 0, 0x15, 0x0800);
    // disable expansion
    cgrd_mdio_write(priv->mii_bus, 0, 0x17, 0x0);
    // shadow reg 111 -- clear [7] put into MII mode (tx_clk comes from PHY)
    cgrd_mdio_write(priv->mii_bus, 0, 0x18, 0x8167);
    // set [12]=0 & speed=100M & master enable
    cgrd_mdio_write(priv->mii_bus, 0, 0, 0x0208);
    // set LED1 to LINKSPD2, LED2 (orage LED) to INTR
    cgrd_mdio_write(priv->mii_bus, 0, 0x1c, 0xb461);
    // set LED3 to ACTIVITY, LED4 to XMIT
    cgrd_mdio_write(priv->mii_bus, 0, 0x1c, 0xb823);
    // clear write enable on register 0x1c
    cgrd_mdio_write(priv->mii_bus, 0, 0x1c, 0x0000);
#endif

    priv->phydev = phydev;
    priv->link = 0;
    priv->speed = 0;
    priv->duplex = -1;
    result = 0;
    done:
    return result;
}



/***********************************************************************
 * EMAC Interrupt callbacks
 **********************************************************************/

/**
 * An MDIO operation completed.
 * @param	pD		Pointer to core private data
 * @param	read		Read/write flag (1=write)
 * @param	readData	Read data
 */
static void cgrd_ev_phyManComplete(CEDI_PrivateData *pD,
        uint8_t read, uint16_t readData) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    /* Not used */
}

/**
 * Frame Received interrupt occurred.
 * Note qNum is ignored, since we must disable interrupts on all
 * queues before scheduling NAPI.
 *
 * @param	pD		Pointer to core private data
 * @param	qNum		Number of the RX queue.
 */
static void cgrd_ev_rxFrame(CEDI_PrivateData *pD, uint8_t qNum) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    if (likely(napi_schedule_prep(&priv->napi))) {
        cgrd_irq_control(priv, EMAC_IRQ_DISABLE);
        __napi_schedule(&priv->napi);
    }
}

/**
 * Frame Rx Error interrupt occurred.
 * @param	pD		Pointer to core private data
 * @param	error		Error type:
 *	CEDI_EV_RX_USED_READ	- Descriptor ring full
 *	CEDI_EV_RX_OVERRUN	- Rx Overrun
 * @param	qNum		RX queue index
 */
static void cgrd_ev_rxError(CEDI_PrivateData *pD, uint32_t error, uint8_t qNum) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);
    struct net_device *ndev = priv->netdev;

    netdev_err(ndev, "%s: error=%08Xh  queue=%u\n", __func__, error, qNum);

    if (error & CEDI_EV_RX_USED_READ)
        cgrd_dump_regs_and_rx_queue(priv, qNum);

//    if (likely(napi_schedule_prep(&priv->napi))) {
//        cgrd_irq_control(priv, EMAC_IRQ_DISABLE);
//        __napi_schedule(&priv->napi);
//    }
}

/**
 * Transmit event occurred
 * @param	pD		Pointer to core private data
 * @param	event		Event mask containing:
 *	CEDI_EV_TX_COMPLETE	- Frame transmitted successfully
 *	CEDI_EV_TX_USED_READ	- Descriptor ring empty
 * @param	qNum		Tx queue index
 */
static void cgrd_ev_txEvent(CEDI_PrivateData *pD, uint32_t event, uint8_t qNum) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    if (likely(napi_schedule_prep(&priv->napi))) {
        cgrd_irq_control(priv, EMAC_IRQ_DISABLE);
        __napi_schedule(&priv->napi);
    }
}

/**
 * Transmit error occurred
 * @param	pD		Pointer to core private data
 * @param	error		Error type:
 *	CEDI_EV_TX_UNDERRUN	- Tx underrun
 *	CEDI_EV_TX_RETRY_EX_LATE_COLL	- Retry limit exceeded
 *	CEDI_EV_TX_FR_CORRUPT		- Tx frame corruption
 * @param	qNum		Tx queue index
 */
static void cgrd_ev_txError(CEDI_PrivateData *pD, uint32_t error, uint8_t qNum) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_err(priv->netdev, "%s error=%08Xh\n", __func__, error);
    cgrd_dump_regs_and_tx_queue(priv, qNum);

    if (error & CEDI_EV_TX_FR_CORRUPT) {
        netif_stop_subqueue(priv->netdev, qNum);
        cgrd_tx_complete(priv, qNum, 1);
        priv->eddObj->resetTxQ(priv->corePriv,qNum);
        priv->eddObj->startTx(priv->corePriv);
        
        sgl_map = 0;
        page_map = 0;
        netdev_dbg(priv->netdev, "%s TxQ %u reset & Tx restarted\n",
                    __func__, qNum);
        netif_wake_subqueue(priv->netdev, qNum);
    }
    else if (likely(napi_schedule_prep(&priv->napi))) {
        cgrd_irq_control(priv, EMAC_IRQ_DISABLE);
        __napi_schedule(&priv->napi);
    }
}

/**
 * Hresp not OK error
 * @param	pD	Pointer to core private data
 * @param	qNum	Tx queue index
 */
static void cgrd_ev_hrespError(CEDI_PrivateData *pD, uint8_t qNum) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_dbg(priv->netdev, "%s\n", __func__);
    if (likely(napi_schedule_prep(&priv->napi))) {
        cgrd_irq_control(priv, EMAC_IRQ_DISABLE);
        __napi_schedule(&priv->napi);
    }
}

/**
 * PCS auto-negotiation page received
 * @param	pD		Pointer to core private data
 * @param	pageRx		Struct containing the link partner base
 *				or next page data
 */
static void cgrd_ev_lpPageRx(CEDI_PrivateData *pD, CEDI_LpPageRx *pageRx) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    /* Not used */
}

/**
 * PCS auto-negotiation is complete
 * @param	pD		Pointer to core private data
 * @param	netStat		Struct containing link resolution status
 */
static void cgrd_ev_anComplete(CEDI_PrivateData *pD, CEDI_NetAnStatus *netStat) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    /* Not used */
}

/**
 * PCS event detected
 * @param	pD		Pointer to core private data
 * @param	linkState	Link synchronization status.
 * 				If auto-negotiation is enabled:
 *				0:	link is down
 *				<>0:	link is up
 *
 */
static void cgrd_ev_linkChange(CEDI_PrivateData *pD, uint8_t linkState) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    /* Not used */
}

/**
 * Pause event detected
 * @param	pD		Pointer to core private data
 * @param	event		Event type:
 *	CEDI_EV_PAUSE_FRAME_TX	- Pause frame transmitted
 *	CEDI_EV_PAUSE_TIME_ZERO	- Pause time zero or zero quantum rx
 *	CEDI_EV_PAUSE_NZ_QU_RX	- Nonzero quantum received
 */
static void cgrd_ev_pauseEvent(CEDI_PrivateData *pD, uint32_t event) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
}

/**
 * PTP primary frame has been transmitted
 * @param   pD      Pointer to core private data
 * @param   frType      PTP frame type:
 *  CEDI_EV_PTP_TX_DLY_REQ   - Delay_req
 *  CEDI_EV_PTP_TX_SYNC      - Sync
 * @param   time        PTP timer value
 */
static void cgrd_ev_ptpPriFrameTx(CEDI_PrivateData *pD,
        uint32_t frType        , CEDI_1588TimerVal *time) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);
    struct ptp_clock_event ev;

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    memset(&ev, 0, sizeof(ev));
    ev.type = PTP_CLOCK_EXTTS;
    ev.index = 0;
    ev.timestamp = ((u64)time->secsUpper << 32) | time->secsLower;
    ev.timestamp *= 1000000000;
    ev.timestamp += time->nanosecs;
    ptp_clock_event(priv->ptp_clk, &ev);
}

/**
 * PTP peer frame has been transmitted
 * @param   pD      Pointer to core private data
 * @param   frType      PTP frame type:
 *  CEDI_EV_PTP_TX_PDLY_REQ  - Pdelay_req
 *  CEDI_EV_PTP_TX_PDLY_RSP  - Pdelay_resp
 * @param   time        PTP timer value
 */
static void cgrd_ev_ptpPeerFrameTx(CEDI_PrivateData *pD,
        uint32_t frType        , CEDI_1588TimerVal *time) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);
    struct ptp_clock_event ev;

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    memset(&ev, 0, sizeof(ev));
    ev.type = PTP_CLOCK_EXTTS;
    ev.index = 0;
    ev.timestamp = ((u64)time->secsUpper << 32) | time->secsLower;
    ev.timestamp *= 1000000000;
    ev.timestamp += time->nanosecs;
    ptp_clock_event(priv->ptp_clk, &ev);
}

/**
 * PTP primary frame has been received
 * @param   pD      Pointer to core private data
 * @param   frType      PTP frame type:
 *  CEDI_EV_PTP_RX_DLY_REQ   - Delay_req
 *  CEDI_EV_PTP_RX_SYNC      - Sync
 * @param   time        PTP timer value
 */
static void cgrd_ev_ptpPriFrameRx(CEDI_PrivateData *pD,
        uint32_t frType        , CEDI_1588TimerVal *time) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);
    struct ptp_clock_event ev;

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    memset(&ev, 0, sizeof(ev));
    ev.type = PTP_CLOCK_EXTTS;
    ev.index = 0;
    ev.timestamp = ((u64)time->secsUpper << 32) | time->secsLower;
    ev.timestamp *= 1000000000;
    ev.timestamp += time->nanosecs;
    ptp_clock_event(priv->ptp_clk, &ev);
}

/**
 * PTP peer frame has been received
 * @param   pD      Pointer to core private data
 * @param   frType      PTP frame type:
 *  CEDI_EV_PTP_RX_PDLY_REQ  - Pdelay_req
 *  CEDI_EV_PTP_RX_PDLY_RSP  - Pdelay_resp
 * @param   time        PTP timer value
 */
static void cgrd_ev_ptpPeerFrameRx(CEDI_PrivateData *pD,
        uint32_t frType        , CEDI_1588TimerVal *time) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);
    struct ptp_clock_event ev;

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    memset(&ev, 0, sizeof(ev));
    ev.type = PTP_CLOCK_EXTTS;
    ev.index = 0;
    ev.timestamp = ((u64)time->secsUpper << 32) | time->secsLower;
    ev.timestamp *= 1000000000;
    ev.timestamp += time->nanosecs;
    ptp_clock_event(priv->ptp_clk, &ev);
}

/**
 * Time stamp unit event has occurred.
 * @param	pD		Pointer to core private data
 * @param	event		Event type:
 *	CEDI_EV_TSU_SEC_INC	- TSU seconds register increment
 *	CEDI_EV_TSU_TIME_MATCH	- TSU timer count match
 */
static void cgrd_ev_tsuEvent(CEDI_PrivateData *pD, uint32_t event) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);
    struct ptp_clock_event ev;

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    memset(&ev, 0, sizeof(ev));
    if (event & CEDI_EV_TSU_SEC_INC) {
        ev.type = PTP_CLOCK_PPS;
        ptp_clock_event(priv->ptp_clk, &ev);
    }
}

/**
 * LPI indication status bit has changed.
 * @param	pD		Pointer to core private data
 */
static void cgrd_ev_lpiStatus(CEDI_PrivateData *pD) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    /* Not used */
}

/**
 * Wake on LAN event detected.
 * @param	pD		Pointer to core private data
 */
static void cgrd_ev_wolEvent(CEDI_PrivateData *pD) {
    struct cgrd_priv *priv = RECOVER_PRIV(pD);

    netdev_dbg(priv->netdev, "entered %s\n", __func__);
}

static CEDI_Callbacks core_callbacks = {
        .phyManComplete = cgrd_ev_phyManComplete,
        .rxFrame        = cgrd_ev_rxFrame,
        .rxError        = cgrd_ev_rxError,
        .txEvent        = cgrd_ev_txEvent,
        .txError        = cgrd_ev_txError,
        .hrespError     = cgrd_ev_hrespError,
        .lpPageRx       = cgrd_ev_lpPageRx,
        .anComplete     = cgrd_ev_anComplete,
        .linkChange     = cgrd_ev_linkChange,
        .pauseEvent     = cgrd_ev_pauseEvent,
        .ptpPriFrameTx  = cgrd_ev_ptpPriFrameTx,
        .ptpPeerFrameTx = cgrd_ev_ptpPeerFrameTx,
        .ptpPriFrameRx  = cgrd_ev_ptpPriFrameRx,
        .ptpPeerFrameRx = cgrd_ev_ptpPeerFrameRx,
        .tsuEvent       = cgrd_ev_tsuEvent,
        .lpiStatus      = cgrd_ev_lpiStatus,
        .wolEvent       = cgrd_ev_wolEvent,
};

/***********************************************************************
 * EMAC PTP driver
 **********************************************************************/

#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
/**
 * Adjusts the 1588 clock frequency by a requested fraction
 * in +/- ppb.
 * @param	ptp	PTP clock instance data
 * @param	ppb	Amount to adjust frequency
 *
 * @return	0 = success
 */
static int cprd_adjfreq(struct ptp_clock_info *ptp, s32 ppb) {
    struct cgrd_priv *priv;
    CEDI_TimerIncrement incSettings;
    u64	period;
    u64	temp;

    priv = container_of(ptp, struct cgrd_priv, ptp_info);
    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    memset(&incSettings, 0, sizeof(CEDI_TimerIncrement));
    priv->eddObj->get1588TimerInc(priv->corePriv, &incSettings);

    /* Adjustment is relative to base frequency */
    period = (u64)(ns_increment << EMAC_SUB_NS_INCR_SIZE) | subns_increment;

    temp = (u64)(1000000000 + ppb) * period;
    period = div_u64(temp + 500000000, 1000000000);
    incSettings.nanoSecsInc = (uint8_t)(period >> EMAC_SUB_NS_INCR_SIZE);
    incSettings.subNsInc = (uint16_t)((period >> EMAC_SUB_NS_INCR_LSB_SIZE) &
                               EMAC_SUB_NS_INCR_MSB_MASK);
    incSettings.lsbSubNsInc = (uint8_t)(period & EMAC_SUB_NS_INCR_LSB_MASK);
    incSettings.altIncCount = 0;
    return -priv->eddObj->set1588TimerInc(priv->corePriv, &incSettings);
}

/**
 * Atomically shifts the EMAC device current time in +/- nanoseconds
 * @param	ptp	PTP clock instance data
 * @param	delta	Amount to shift time
 *
 * @return	0 = success
 */
static int cprd_adjtime(struct ptp_clock_info *ptp, s64 delta) {
    struct cgrd_priv *priv;

    priv = container_of(ptp, struct cgrd_priv, ptp_info);

    /* For small adjustments, use adjust1588Timer */
    if (delta < 0x40000000LL && delta > -0x40000000LL  ) {
	return -priv->eddObj->adjust1588Timer(priv->corePriv, (int32_t)delta);
    } else
    {
	CEDI_1588TimerVal egdTime;
	int64_t newTime;

	priv->eddObj->get1588Timer(priv->corePriv, &egdTime);

	newTime = (int64_t) egdTime.nanosecs + (int64_t)(egdTime.secsLower * 1000000000LL);
	newTime += delta;

        egdTime.secsUpper = 0;
        egdTime.secsLower = div_u64(newTime,1000000000);
        egdTime.nanosecs = newTime - (1000000000 * egdTime.secsLower) ;
        return -priv->eddObj->set1588Timer(priv->corePriv, &egdTime);
    }
}

/**
 * Returns the current 1588 time from the EMAC registers.
 * @param	ptp	PTP clock instance data
 * @param	ts	Struct to receive current time
 *
 * @return	0 = success
 */
static int cprd_gettime(struct ptp_clock_info *ptp, struct timespec *ts) {
    struct cgrd_priv *priv;
    CEDI_1588TimerVal egdTime;
    int result;

    priv = container_of(ptp, struct cgrd_priv, ptp_info);
    netdev_dbg(priv->netdev, "entered %s\n", __func__);
    result = -priv->eddObj->get1588Timer(priv->corePriv, &egdTime);
    ts->tv_sec = egdTime.secsLower;
    ts->tv_nsec = egdTime.nanosecs;
    return result;
}

/**
 * Overwrite the EMAC 1588 time
 * @param	ptp	PTP clock instance data
 * @param	ts	New time to be written
 *
 * @return	0 = success
 */
static int cprd_settime(struct ptp_clock_info *ptp, const struct timespec *ts) {
    struct cgrd_priv *priv;
    CEDI_1588TimerVal egdTime;

    priv = container_of(ptp, struct cgrd_priv, ptp_info);
    netdev_dbg(priv->netdev, "entered %s\n", __func__);

    egdTime.secsUpper = 0;
    egdTime.secsLower = ts->tv_sec;
    egdTime.nanosecs = ts->tv_nsec;
    return -priv->eddObj->set1588Timer(priv->corePriv, &egdTime);
}

/**
 * Enable or disable a PTP ancillary feature
 * @param	ptp		PTP clock instance data
 * @param	request		Feature to change:
 *				- PTP_CLK_REQ_EXTTS
 *				- PTP_CLK_REQ_PEROUT
 *				- PTP_CLK_REQ_PPS
 * @param	on		0=disable, 1=enable
 *
 * @return	0 = success
 */
static int cprd_enable(struct ptp_clock_info *ptp,
        struct ptp_clock_request *request, int on) {
    int result = -EOPNOTSUPP;
    struct cgrd_priv *priv;
    unsigned long flags;

    priv = container_of(ptp, struct cgrd_priv, ptp_info);
    netdev_dbg(priv->netdev, "entered %s\n", __func__);

    switch (request->type) {
    case PTP_CLK_REQ_EXTTS:
        if (request->extts.index >= ptp->n_ext_ts) {
            result = -EINVAL;
            break;
        }
        spin_lock_irqsave(&priv->lock, flags);
        /* enable or disable the timestamp event */
        priv->eddObj->setEventEnable(priv->corePriv,
                CEDI_EV_TSU_TIME_MATCH, on, 0);
        spin_unlock_irqrestore(&priv->lock, flags);
        break;
    case PTP_CLK_REQ_PEROUT:
        break;
    case PTP_CLK_REQ_PPS:
        spin_lock_irqsave(&priv->lock, flags);
        /* enable or disable periodic pulse event */
        priv->eddObj->setEventEnable(priv->corePriv,
                CEDI_EV_TSU_SEC_INC, on, 0);
        spin_unlock_irqrestore(&priv->lock, flags);
        break;
    }
    return result;
}

static const struct ptp_clock_info cprd_init_info = {
        .owner		= THIS_MODULE,
        .name		= "EMAC Clock",
        .max_adj	= (64 * 1000 * 1000), //MAX_PPB,
        .n_alarm	= 1, //N_PTP_ALARM,
        .n_ext_ts	= 1, //N_EXT_TS,
        .n_per_out	= 0,
        .pps		= 1,
        .adjfreq	= cprd_adjfreq,
        .adjtime	= cprd_adjtime,
        .gettime	= cprd_gettime,
        .settime	= cprd_settime,
        .enable		= cprd_enable,
};

/**
 * Un-register this device from the PTP class driver.
 * @param	priv		Device private data
 */
static void cprd_remove(struct cgrd_priv *priv) {
    if (priv->ptp_clk) {
        ptp_clock_unregister(priv->ptp_clk);
        priv->ptp_clk = NULL;
        netdev_dbg(priv->netdev, "PTP driver unregistered\n");
    }
}

/**
 * Register this device with the PTP class driver.
 * @param	priv		Device private data
 *
 * @return	0 = success, -ENODEV = failed
 */
static int cprd_probe(struct cgrd_priv *priv) {
    netdev_dbg(priv->netdev, "%s: registering PTP driver\n", __func__);
    priv->ptp_info = cprd_init_info;	/* struct copy */

#if LINUX_VERSION_CODE < KERNEL_VERSION(3,7,0)
    priv->ptp_clk = ptp_clock_register(&priv->ptp_info);
#else
    priv->ptp_clk = ptp_clock_register(&priv->ptp_info, priv->dev_p);
#endif
    if (NULL == priv->ptp_clk) {
        netdev_err(priv->netdev, "Couldn't register PTP driver\n");
        return -ENODEV;
    }
    return 0;
}

int cgrd_ptp_get_ts_config(struct net_device *ndev, struct ifreq *ifr)
{
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct hwtstamp_config *config = &priv->ts_config;

    return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
	-EFAULT : 0;
}

int cgrd_ptp_set_ts_config(struct net_device *ndev, struct ifreq *ifr)
{
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct hwtstamp_config *config = &priv->ts_config;
    CEDI_TxTsMode txMode = 0;
    CEDI_RxTsMode rxMode = 0;

    if (copy_from_user(config, ifr->ifr_data, sizeof(*config)))
	return -EFAULT;

    /* reserved for future extensions */
    if (config->flags)
	return -EINVAL;

    switch (config->tx_type) {
    case HWTSTAMP_TX_OFF:
	break;
    case HWTSTAMP_TX_ONESTEP_SYNC:
	if (EOK!=priv->eddObj->set1588OneStepTxSyncEnable(priv->corePriv,1))
	    return -ERANGE;
	// FALLTHROUGH
    case HWTSTAMP_TX_ON:
		// enable timestamping for all frames initiallly
	txMode = CEDI_TX_TS_ALL;
	break;
    default:
	return -ERANGE;
    }

    switch (config->rx_filter) {
    case HWTSTAMP_FILTER_NONE:
	break;
    case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
	break;
    case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
	break;
    case HWTSTAMP_FILTER_PTP_V2_EVENT:
    case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
    case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
    case HWTSTAMP_FILTER_PTP_V2_SYNC:
    case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
    case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
    case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
    case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
    case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
	rxMode =  CEDI_RX_TS_PTP_ALL;
        config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
        break;
    case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
    case HWTSTAMP_FILTER_ALL:
	rxMode = CEDI_RX_TS_ALL;
        config->rx_filter = HWTSTAMP_FILTER_ALL;
        break;
    default:
        config->rx_filter = HWTSTAMP_FILTER_NONE;
        return -ERANGE;
    }

    {
        CEDI_TimerIncrement incSettings;
        CEDI_1588TimerVal egdTime;
	struct timespec ts;

        /* reset the ns time counter */
	ts = ns_to_timespec(ktime_to_ns(ktime_get_real()));
        egdTime.secsUpper = 0;
        egdTime.secsLower = ts.tv_sec;
        egdTime.nanosecs = ts.tv_nsec;
        priv->eddObj->set1588Timer(priv->corePriv,&egdTime);

        memset(&incSettings, 0, sizeof(CEDI_TimerIncrement));
        incSettings.nanoSecsInc = ns_increment;
        incSettings.altNanoSInc = 0;
        incSettings.altIncCount = 0;
        incSettings.subNsInc = (subns_increment >> EMAC_SUB_NS_INCR_LSB_SIZE) &
                               EMAC_SUB_NS_INCR_MSB_MASK;
        incSettings.lsbSubNsInc = subns_increment &
                                  EMAC_SUB_NS_INCR_LSB_MASK;
        priv->eddObj->set1588TimerInc(priv->corePriv,&incSettings);
    }

    /* set h/w timestamping on Tx & Rx */
    if (EOK!=priv->eddObj->setDescTimeStampMode(priv->corePriv,
                                txMode, rxMode))
        return -ERANGE;
    return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
	-EFAULT : 0;
}



#else /* def CONFIG_PTP_1588_CLOCK */
#define cprd_remove(priv)
#define cprd_probe(priv) 0
#endif /* def CONFIG_PTP_1588_CLOCK */

/***********************************************************************
 * EMAC Ethernet driver
 **********************************************************************/

static int cgrd_ring_alloc(struct cgrd_priv *priv, struct desc_info *dp,
        u32 q_sz, u32 num_q, size_t descAllocSize) {
    struct net_device *ndev = priv->netdev;

    netdev_dbg(ndev, "%s dp=%p, descAllocSize=%Xh\n", __func__, dp,
                        (unsigned int)descAllocSize);
    dp->allocSize = descAllocSize;
    dp->cpuStart = dma_alloc_coherent(priv->dev_p,
            descAllocSize, &dp->dmaStart, GFP_KERNEL);
    if (!dp->cpuStart) {
        netdev_err(ndev, "dma_alloc_coherent failed\n");
        return -ENOMEM;
    }
    netdev_dbg(ndev, "cgrd_ring_alloc sz=%Xh virt=%p phy=%p\n",
                (unsigned int)descAllocSize, dp->cpuStart,
                (void *)(uintptr_t)dp->dmaStart);
    return 0;
}


static void cgrd_ring_dealloc(struct cgrd_priv *priv, struct desc_info *dp) {
    struct net_device *ndev = priv->netdev;

    netdev_dbg(ndev, "dma_free_coherent sz=%Xh virt=%p phy=%p\n",
            dp->allocSize, dp->cpuStart, (void *)(uintptr_t)dp->dmaStart);
    if (dp->allocSize && dp->cpuStart && dp->dmaStart)
        dma_free_coherent(priv->dev_p,
                dp->allocSize, dp->cpuStart, dp->dmaStart);
    dp->cpuStart = NULL;
    dp->dmaStart = 0;
}

/**
 * Undoes cgrd_charge_rx_ring().
 */
static void cgrd_clear_rx_ring(struct cgrd_priv *priv, u32 qNum) {
    CEDI_BuffAddr bufInfo;
    struct map_info mapInfo;
    struct map_info *pReady = &priv->rxReady[qNum];
    struct net_device *ndev = priv->netdev;

    netdev_dbg(ndev, "%s entered\n", __func__);

    if (pReady)
        cgrd_free_mapped_rx_buf(priv, pReady);
    while (0 == priv->eddObj->removeRxBuf(priv->corePriv, qNum, &bufInfo)) {
        mapInfo.skb = (void *)bufInfo.vAddr;
        mapInfo.dmap = bufInfo.pAddr;
        cgrd_free_mapped_rx_buf(priv, &mapInfo);
    }
}


/**
 * Pre-charge rx skb and descriptor rings with allocated and mapped
 * buffers.
 */
static int cgrd_charge_rx_ring(struct cgrd_priv *priv, u32 qNum) {
    int result = 0;
    dma_addr_t dmap;
    struct sk_buff *skb;
    struct net_device *ndev = priv->netdev;
    CEDI_BuffAddr tmp_buf;
    u32 ix;
    struct map_info *pReady = &priv->rxReady[qNum];

    netdev_dbg(ndev, "%s entered\n", __func__);
    for (ix = 0; ix < RX_Q_SZ; ++ix) {
        skb = cgrd_alloc_mapped_rx_buf(priv, &dmap);
        if (!skb) {
            netdev_err(ndev,
                    "%s: cgrd_alloc_mapped_rx_buff failed, queue %u desc %u\n",
                    __func__, qNum, ix);
            result = -ENOMEM;
            break;
        }
        tmp_buf.vAddr = (uintptr_t)skb;
        tmp_buf.pAddr = dmap;
        /*netdev_dbg(ndev, "%s q=%u skb=%p dmap=%p\n",
                    __func__, qNum, (void *)tmp_buf.vAddr, (void *)tmp_buf.pAddr);*/

        result = -priv->eddObj->addRxBuf(priv->corePriv,
                qNum, &tmp_buf, 0);
        if (0 != result) {
            netdev_err(ndev, "%s: addRxBuf failed, queue %u desc %u\n",
                    __func__, qNum, ix);
            break;
        }
    }
    /* Allocate and map extra skb to replace next received buf */
    pReady->skb = skb = cgrd_alloc_mapped_rx_buf(priv, &pReady->dmap);
    if (!skb) {
        netdev_err(ndev,
              "%s: first spare cgrd_alloc_mapped_rx_buff failed\n", __func__);
        result = -ENOMEM;
    }
    /*netdev_dbg(ndev, "%s Spare Rx buf: q=%u skb=%p dmap=%p\n",
                __func__, qNum, (void *)skb, (void *)pReady->dmap);*/
    /* initialise fragment list */
    cgrd_reset_rx_state(priv, qNum);

    return result;
}

static void cgrd_destroy_core(struct cgrd_priv *priv) {
    CEDI_OBJ *eddObj = priv->eddObj;

    if (eddObj && eddObj->destroy && priv->corePriv)
        eddObj->destroy(priv->corePriv);
    kfree(priv->statsRegs);
    priv->statsRegs = NULL;

    cgrd_ring_dealloc(priv, &priv->rxDesc);
    cgrd_ring_dealloc(priv, &priv->txDesc);

    /* free private data allocated for core driver */
    if (priv->corePriv) {
        void **tmp = (void**)priv->corePriv;
        kfree(tmp - 1);
        priv->corePriv = NULL;
    }
}

static int cgrd_probe_core(CEDI_Config *cfg_p, CEDI_SysReq *req_p) {
    int result = -ENODEV;
    CEDI_OBJ *eddObj = CEDI_GetInstance();
    uint32_t qNum;

    if (cfg_p && req_p && eddObj && eddObj->probe) {
        for (qNum = 0; qNum < MAXNUM_RX_Q; ++qNum)
            cfg_p->rxQLen[qNum] = RX_Q_SZ;
        for (qNum = 0; qNum < MAXNUM_TX_Q; ++qNum)
            cfg_p->txQLen[qNum] = TX_Q_SZ;
        result = -eddObj->probe(cfg_p, req_p);
    }
    return result;
}

static int cgrd_init_core(struct cgrd_priv *priv) {
    int result = -ENODEV;
    struct net_device *ndev = priv->netdev;
    CEDI_OBJ *eddObj;
    CEDI_Config cfg;
    CEDI_SysReq req;
    void **pPrivContainer;
    uint32_t qNum;

    eddObj = priv->eddObj = CEDI_GetInstance();
    if (!eddObj || !eddObj->probe) {
        netdev_err(ndev, "No core driver found, aborting\n");
        goto init_core_err;
    }
    memset(&cfg, 0, sizeof(cfg));
    /* Set config fields which determine descriptor size before probe call */
    cfg.regBase = (uintptr_t)priv->regmap;
    cfg.rxQs = priv->num_rx_q;
    cfg.txQs = priv->num_tx_q;
    cfg.dmaAddrBusWidth = priv->dmaAddr64;     // 0 =32b , 1=64b

#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
    // use descriptor timestamps for HW TS support
    cfg.enTxExtBD = 1;
    cfg.enRxExtBD = 1;
#else
    cfg.enTxExtBD = 0;
    cfg.enRxExtBD = 0;
#endif

    result = cgrd_probe_core(&cfg, &req);
    if (result) {
        netdev_err(ndev, "Core driver probe failed (returned %u), aborting\n",
                            result);
        goto init_core_err;
    }
    netdev_dbg(ndev, "privDataSize = %Xh\n", req.privDataSize);
    netdev_dbg(ndev, "statsSize = %Xh\n", req.statsSize);
    netdev_dbg(ndev, "txDescListSize = %Xh\n", req.txDescListSize);
    netdev_dbg(ndev, "rxDescListSize = %Xh\n", req.rxDescListSize);
    netdev_dbg(ndev, "rxQs = %Xh\n", cfg.rxQs);
    netdev_dbg(ndev, "txQs = %Xh\n", cfg.txQs);

    /* Alloc resources and init. */
    /* Alloc space for core driver private data */
    result = -ENOMEM;
    pPrivContainer = kzalloc(req.privDataSize + sizeof(void *), GFP_KERNEL);
    if (NULL == pPrivContainer) {
        netdev_err(ndev, "kzalloc failed, aborting\n");
        goto init_core_err;
    }
    /* reserve 1st word to recover our private data */
    *pPrivContainer = priv;
    /* The rest is core driver's private data */
    priv->corePriv = (CEDI_PrivateData*)(pPrivContainer + 1);

    /* Alloc rx and tx descriptor rings */
    result = -ENOMEM;
    if (cgrd_ring_alloc(priv, &priv->rxDesc, RX_Q_SZ, priv->num_rx_q, req.rxDescListSize))
        goto init_core_err;
                               // allow for extra Tx descriptor
    if (cgrd_ring_alloc(priv, &priv->txDesc, TX_Q_SZ, priv->num_tx_q, req.txDescListSize))
        goto init_core_err;

    /* Alloc remaining resources requested by probe() */
    priv->statsRegs = kzalloc(req.statsSize, GFP_KERNEL);
    if (!priv->statsRegs)
        goto init_core_err;


    /* First-time settings */
    cfg.dmaEndianism = 0;
#ifdef EDD_PCI_NIC
    cfg.dmaBusWidth = CEDI_DMA_BUS_WIDTH_128;
#else
    cfg.dmaBusWidth = CEDI_DMA_BUS_WIDTH_64;
#endif
    cfg.intrEnable = CEDI_EV_TX_COMPLETE | CEDI_EV_TX_USED_READ |
            CEDI_EV_TX_UNDERRUN |
            CEDI_EV_TX_RETRY_EX_LATE_COLL |
            CEDI_EV_TX_FR_CORRUPT | CEDI_EV_RX_COMPLETE |
            CEDI_EV_RX_USED_READ | CEDI_EV_RX_OVERRUN |
            CEDI_EV_HRESP_NOT_OK;
    cfg.txQAddr = (uintptr_t)priv->txDesc.cpuStart;
    cfg.txQPhyAddr = (uint32_t)(priv->txDesc.dmaStart & 0xFFFFFFFF);
    cfg.rxQAddr = (uintptr_t)priv->rxDesc.cpuStart;
    cfg.rxQPhyAddr = (uint32_t)(priv->rxDesc.dmaStart & 0xFFFFFFFF);
    if (priv->dmaAddr64) {
        cfg.upper32BuffTxQAddr =
                (priv->txDesc.dmaStart & 0xFFFFFFFF00000000) >> 32;
        cfg.upper32BuffRxQAddr =
                (priv->rxDesc.dmaStart & 0xFFFFFFFF00000000) >> 32;
    }
    else {
        cfg.upper32BuffTxQAddr = 0x00000000;
        cfg.upper32BuffRxQAddr = 0x00000000;
    }
    for (qNum = 0; qNum < priv->num_rx_q; ++qNum) {
        priv->rxBufLen[qNum] = RX_BUF_SZ;
        cfg.rxBufLength[qNum] = priv->rxBufLen[qNum] / 64;
    }
    cfg.txPktBufSize = 1;
    cfg.rxPktBufSize = 3;
    cfg.dmaDataBurstLen = CEDI_DMA_DBUR_LEN_4;
    cfg.dmaCfgFlags = 0;
    cfg.enableMdio = 1;
    cfg.mdcPclkDiv = CEDI_MDC_DIV_BY_32;
    cfg.ifTypeSel = EMAC_IF_TYPE;
    cfg.altSgmiiEn = 0;
    cfg.fullDuplex = 1;
    cfg.enRxHalfDupTx = 0;
    cfg.extAddrMatch = 0;
//    if (!priv->hwCfg.pbuf_rsc) 		/* rxBufOffset doesn't work if pbuf_rsc */
//      cfg.rxBufOffset = IP_HDR_ALIGN;
    cfg.rxLenErrDisc = 0;
    cfg.disCopyPause = 0;
    cfg.uniDirEnable = 0;
    if (ndev->features & NETIF_F_IP_CSUM)
        cfg.chkSumOffEn = CEDI_CFG_CHK_OFF_TX;
    if (ndev->features & NETIF_F_RXCSUM)
        cfg.chkSumOffEn |= CEDI_CFG_CHK_OFF_RX;
    cfg.rx1536ByteEn = 0;
    cfg.rxJumboFrEn = 0;
    cfg.enRxBadPreamble = 0;
    cfg.ignoreIpgRxEr = 0;
    cfg.storeUdpTcpOffset = 0;
    cfg.enExtTsuPort = 0;
    cfg.aw2wMaxPipeline = 4;
#if defined(CEDI_64B_COMPILE) && defined(EDD_PCI_NIC)
    cfg.ar2rMaxPipeline = 2;
#else
    cfg.ar2rMaxPipeline = 4;
#endif
    cfg.pfcMultiQuantum = 0;
    cfg.statsRegs = (uintptr_t)priv->statsRegs;

    result = -eddObj->init(priv->corePriv, &cfg, &core_callbacks);
    if (result) {
        netdev_err(ndev, "Core driver init failed, returned %u\n", -result);
        goto init_core_err;
    }

    // get hw cfg
    eddObj->getDesignConfig(priv->corePriv, &(priv->hwCfg));
    // default to remove CRC from rx packet
    eddObj->setFcsRemove(priv->corePriv, 1);
    return 0;

    init_core_err:
    cgrd_destroy_core(priv);
    return result;
}

/**
 * Ethtool get_settings handler
 * @param	ndev	Device instance data
 * @param	cmd	ethtool command description
 * @return	0	Call was successful
 * @return 	<0	Call failed
 */
static int cgrd_et_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd) {
    struct cgrd_priv *priv = netdev_priv(ndev);

    if (NULL == priv->phydev)
        return -ENODEV;
    return phy_ethtool_gset(priv->phydev, cmd);
}

/**
 * Ethtool set_settings handler
 * @param	ndev	Device instance data
 * @param	cmd	ethtool command description
 * @return	0	Call was successful
 * @return 	<0	Call failed
 */
static int cgrd_et_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd) {
    struct cgrd_priv *priv = netdev_priv(ndev);

    if (NULL == priv->phydev)
        return -ENODEV;
    netdev_dbg(ndev, "entered %s ndev=%p\n", __func__, ndev);

    return phy_ethtool_sset(priv->phydev, cmd);
}

/**
 * Ethtool get_drvinfo handler
 * @param	ndev	Device instance data
 * @param	di	driver info struct
 */
static void cgrd_et_get_drvinfo(struct net_device *ndev, struct ethtool_drvinfo *di) {
    struct cgrd_priv *priv = netdev_priv(ndev);

    strncpy(di->driver, priv->dev_p->driver->name, sizeof(di->driver));
    strncpy(di->version, "0.1", sizeof(di->version));
    strncpy(di->fw_version, "0.1", sizeof(di->fw_version));
    strncpy(di->bus_info, dev_name(priv->dev_p), sizeof(di->bus_info));
}

#ifdef CONFIG_PM
/**
 * Ethtool get_wol handler
 * @param	ndev	Device instance data
 * @param	wi	Wake on Lan configuration info
 */
static void cgrd_et_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wi) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned long flags;
    CEDI_WakeOnLanReg reg;

    spin_lock_irqsave(&priv->lock, flags);
    priv->eddObj->getWakeOnLanReg(priv->corePriv, &reg);
    spin_unlock_irqrestore(&priv->lock, flags);
    wi->supported = WOL_SUPPORTED_MASK;
    if (reg.arpEn)
        wi->wolopts |= WAKE_ARP;
    if (reg.magPktEn)
        wi->wolopts |= WAKE_MAGIC;
    if (reg.multiHashEn)
        wi->wolopts |= WAKE_MCAST;
    if (reg.specAd1En)
        wi->wolopts |= WAKE_UCAST;
}

/**
 * Ethtool set_wol handler
 * @param	ndev	Device instance data
 * @param	wi	Wake on Lan configuration info
 * @return	0	Call was successful
 * @return 	<0	Call failed
 */
static int cgrd_et_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wi) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned long flags;
    CEDI_WakeOnLanReg reg = {0};

    if (wi->wolopts & ~WOL_SUPPORTED_MASK)
        return -EOPNOTSUPP;
    reg.arpEn = (0 != (wi->wolopts & WAKE_ARP));
    reg.magPktEn = (0 != (wi->wolopts & WAKE_MAGIC));
    reg.multiHashEn = (0 != (wi->wolopts & WAKE_MCAST));
    reg.specAd1En = (0 != (wi->wolopts & WAKE_UCAST));
    spin_lock_irqsave(&priv->lock, flags);
    priv->eddObj->setWakeOnLanReg(priv->corePriv, &reg);
    spin_unlock_irqrestore(&priv->lock, flags);
    return 0;
}
#endif /* def CONFIG_PM */

/**
 * Ethtool get_ringparam handler
 * @param	ndev	Device instance data
 * @param	rp	struct describing the size of buffer/descriptor rings
 */
static void cgrd_et_get_ringparam(struct net_device *ndev, struct ethtool_ringparam *rp) {
    rp->rx_max_pending = RX_Q_SZ;
    rp->rx_mini_max_pending = RX_Q_SZ;
    rp->rx_jumbo_max_pending = RX_Q_SZ;
    rp->tx_max_pending = TX_Q_SZ;
    rp->rx_pending = RX_Q_SZ;
    rp->rx_mini_pending = RX_Q_SZ;
    rp->rx_jumbo_pending = RX_Q_SZ;
    rp->tx_pending = TX_Q_SZ;
}

/**
 * Ethtool get_pauseparam handler
 * @param	ndev	Device instance data
 * @param	pp	Pause enable settings
 */
static void cgrd_et_get_pauseparam(struct net_device *ndev, struct ethtool_pauseparam *pp) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned long flags;
    uint8_t enabled;

    spin_lock_irqsave(&priv->lock, flags);
    priv->eddObj->getPauseEnable(priv->corePriv, &enabled);
    pp->tx_pause = enabled;
    spin_unlock_irqrestore(&priv->lock, flags);
}

/**
 * Ethtool set_pauseparam handler
 * @param	ndev	Device instance data
 * @param	pp	Pause enable settings
 * @return	0 - always successful
 */
static int cgrd_et_set_pauseparam(struct net_device *ndev, struct ethtool_pauseparam *pp) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned long flags;

    if (netif_running(ndev))
        return -EFAULT;
    spin_lock_irqsave(&priv->lock, flags);
    priv->eddObj->setPauseEnable(priv->corePriv, 0 != pp->tx_pause);
    spin_unlock_irqrestore(&priv->lock, flags);
    return 0;
}

/**
 * Update device statistics.
 */
static void cgrd_update_stats(struct cgrd_priv *priv) {
  struct cgrd_stats *stats = &priv->stats;
  CEDI_Statistics *statsRegs;

  /* If core driver inited, call read_stats() */
  if (priv->statsRegs &&
      (0 == priv->eddObj->readStats(priv->corePriv))) {
    statsRegs = priv->statsRegs;

    stats->octetsTx += statsRegs->octetsTxLo |
      ((__u64)statsRegs->octetsTxHi << 32);
    stats->framesTx += statsRegs->framesTx;
    stats->broadcastTx += statsRegs->broadcastTx;
    stats->multicastTx += statsRegs->multicastTx;
    stats->pauseFrTx += statsRegs->pauseFrTx;
    stats->fr64byteTx += statsRegs->fr64byteTx;
    stats->fr65_127byteTx += statsRegs->fr65_127byteTx;
    stats->fr128_255byteTx += statsRegs->fr128_255byteTx;
    stats->fr256_511byteTx += statsRegs->fr256_511byteTx;
    stats->fr512_1023byteTx += statsRegs->fr512_1023byteTx;
    stats->fr1024_1518byteTx += statsRegs->fr1024_1518byteTx;
    stats->fr1519_byteTx += statsRegs->fr1519_byteTx;
    stats->underrunFrTx += statsRegs->underrunFrTx;
    stats->singleCollFrTx += statsRegs->singleCollFrTx;
    stats->multiCollFrTx += statsRegs->multiCollFrTx;
    stats->excessCollFrTx += statsRegs->excessCollFrTx;
    stats->lateCollFrTx += statsRegs->lateCollFrTx;
    stats->deferredFrTx += statsRegs->deferredFrTx;
    stats->carrSensErrsTx += statsRegs->carrSensErrsTx;
    stats->octetsRx += statsRegs->octetsRxLo |
      ((__u64)statsRegs->octetsRxHi << 32);
    stats->framesRx += statsRegs->framesRx;
    stats->broadcastRx += statsRegs->broadcastRx;
    stats->multicastRx += statsRegs->multicastRx;
    stats->pauseFrRx += statsRegs->pauseFrRx;
    stats->fr64byteRx += statsRegs->fr64byteRx;
    stats->fr65_127byteRx += statsRegs->fr65_127byteRx;
    stats->fr128_255byteRx += statsRegs->fr128_255byteRx;
    stats->fr256_511byteRx += statsRegs->fr256_511byteRx;
    stats->fr512_1023byteRx += statsRegs->fr512_1023byteRx;
    stats->fr1024_1518byteRx += statsRegs->fr1024_1518byteRx;
    stats->fr1519_byteRx += statsRegs->fr1519_byteRx;
    stats->undersizeFrRx += statsRegs->undersizeFrRx;
    stats->oversizeFrRx += statsRegs->oversizeFrRx;
    stats->jabbersRx += statsRegs->jabbersRx;
    stats->fcsErrorsRx += statsRegs->fcsErrorsRx;
    stats->lenChkErrRx += statsRegs->lenChkErrRx;
    stats->rxSymbolErrs += statsRegs->rxSymbolErrs;
    stats->alignErrsRx += statsRegs->alignErrsRx;
    stats->rxResourcErrs += statsRegs->rxResourcErrs;
    stats->overrunFrRx += statsRegs->overrunFrRx;
    stats->ipChksumErrs += statsRegs->ipChksumErrs;
    stats->tcpChksumErrs += statsRegs->tcpChksumErrs;
    stats->udpChksumErrs += statsRegs->udpChksumErrs;
    stats->dmaRxPBufFlush += statsRegs->dmaRxPBufFlush;
  }
}

static const char cgrd_et_stringset[][ETH_GSTRING_LEN] = {
  "octetsTx",
  "framesTx",
  "broadcastTx",
  "multicastTx",
  "pauseFrTx",
  "fr64byteTx",
  "fr65_127byteTx",
  "fr128_255byteTx",
  "fr256_511byteTx",
  "fr512_1023byteTx",
  "fr1024_1518byteTx",
  "fr1519_byteTx",
  "underrunFrTx",
  "singleCollFrTx",
  "multiCollFrTx",
  "excessCollFrTx",
  "lateCollFrTx",
  "deferredFrTx",
  "carrSensErrsTx",
  "octetsRx",
  "framesRx",
  "broadcastRx",
  "multicastRx",
  "pauseFrRx",
  "fr64byteRx",
  "fr65_127byteRx",
  "fr128_255byteRx",
  "fr256_511byteRx",
  "fr512_1023byteRx",
  "fr1024_1518byteRx",
  "fr1519_byteRx",
  "undersizeFrRx",
  "oversizeFrRx",
  "jabbersRx",
  "fcsErrorsRx",
  "lenChkErrRx",
  "rxSymbolErrs",
  "alignErrsRx",
  "rxResourcErrs",
  "overrunFrRx",
  "ipChksumErrs",
  "tcpChksumErrs",
  "udpChksumErrs",
  "dmaRxPBufFlush",
};
#define CGRD_ET_N_STATS ARRAY_SIZE(cgrd_et_stringset)

/**
 * Ethtool get_sset_count handler
 * @param  ndev      Device instance data
 * @param  stringset Ethtool stringset type select
 * @return Number of strings of selected type or -EINVAL
 */
static int cgrd_et_get_sset_count(struct net_device *ndev, int stringset) {
  if (stringset == ETH_SS_STATS)
    return CGRD_ET_N_STATS;
  else
    return -EINVAL;
}

/**
 * Ethtool get_strings handler
 * @param ndev      Device instance data
 * @param stringset Ethtool stringset type select
 * @param strings   String data
 */
static void cgrd_et_get_strings(struct net_device *ndev,
                                u32 stringset, u8 *strings) {
  if (stringset == ETH_SS_STATS)
    memcpy(strings, &cgrd_et_stringset, sizeof(cgrd_et_stringset));
}

/**
 * Ethtool get_ethtool_stats handler
 * @param ndev      Device instance data
 * @param et_stats  Ethtool stats structure
 * @param et_values Array of stats values
 */
static void cgrd_et_get_ethtool_stats(struct net_device *ndev,
                                        struct ethtool_stats *et_stats,
                                        u64 *et_values) {
  struct cgrd_priv *priv = netdev_priv(ndev);
  struct cgrd_stats *stats = &priv->stats;

  et_stats->n_stats = CGRD_ET_N_STATS;
  cgrd_update_stats(priv);
  memcpy(et_values, stats, sizeof(struct cgrd_stats));
}

static int cgrd_get_coalesce(struct net_device *ndev,
                              struct ethtool_coalesce *ec)
{
    struct cgrd_priv *priv = netdev_priv(ndev);
    uint8_t get_rx_val, get_tx_val;
    uint8_t set_rx_thresh_val, set_tx_thresh_val;

    priv->eddObj->getIntrptModerate(priv->corePriv,
                                    &get_tx_val, &get_rx_val);

    priv->eddObj->getIntrptModerateThreshold(priv->corePriv,
                                    &set_tx_thresh_val, &set_rx_thresh_val);

    ec->tx_coalesce_usecs = (get_tx_val * INT_DLY_NS_UNIT)/1000;
    ec->rx_coalesce_usecs = (get_rx_val * INT_DLY_NS_UNIT)/1000;

    ec->rx_max_coalesced_frames = set_rx_thresh_val;
    ec->tx_max_coalesced_frames = set_tx_thresh_val;

    netdev_dbg(ndev, "%s regvals: tx=%u  rx=%u\n",
                __func__, get_tx_val, get_rx_val);

    return 0;
}

static int cgrd_set_coalesce(struct net_device *ndev,
                              struct ethtool_coalesce *ec)
{
    struct cgrd_priv *priv = netdev_priv(ndev);
    uint8_t set_rx_val, set_tx_val;
    uint8_t set_rx_thresh_val, set_tx_thresh_val;

    if ((ec->tx_coalesce_usecs*1000 > (EMAC_MAX_INT_DLY_NS)) ||
        (ec->rx_coalesce_usecs*1000 > (EMAC_MAX_INT_DLY_NS)))
        return -EINVAL;

    set_tx_val = (uint8_t)(((ec->tx_coalesce_usecs*1000 + (INT_DLY_NS_UNIT>>1))
                                              /INT_DLY_NS_UNIT) & 0xFF);

    set_rx_val = (uint8_t)(((ec->rx_coalesce_usecs*1000 + (INT_DLY_NS_UNIT>>1))
                                              /INT_DLY_NS_UNIT) & 0xFF);

    set_rx_thresh_val = (uint8_t)ec->rx_max_coalesced_frames;
    set_tx_thresh_val = (uint8_t)ec->tx_max_coalesced_frames;

    /* setting all tx_val, rx_val,
     * tx_thresh_val and rx_thresh_val to zero is illegal */
    if ((set_rx_thresh_val == 0) && (set_tx_thresh_val == 0)
        && (set_tx_val == 0) && (set_rx_val == 0)) {
        set_rx_thresh_val = set_tx_thresh_val = 1;
    }

    priv->eddObj->setIntrptModerateThreshold(priv->corePriv,
                                    set_tx_thresh_val, set_rx_thresh_val);

    priv->eddObj->setIntrptModerate(priv->corePriv,
                                    set_tx_val, set_rx_val);

    netdev_dbg(ndev, "%s regvals: tx=%u  rx=%u, tx_thres=%u rx_thres=%u\n",
                __func__, set_tx_val, set_rx_val,
                set_tx_thresh_val, set_rx_thresh_val);

    return 0;
}

static void print_flow_list(struct net_device *ndev,
                            struct cgrd_priv *priv) {
    struct etht_fs_cont *item;
    struct ethtool_rx_flow_spec *fs;
    struct ethtool_tcpip4_spec *tp4sp;

    netdev_dbg(ndev, "RX flow spec list: (%u entries, max=%u)\n",
                priv->rx_fs_list.count, priv->maxNtups);

    list_for_each_entry(item, &priv->rx_fs_list.list, list) {
        fs = &item->fs;
        tp4sp = &(fs->h_u.tcp_ip4_spec);
        netdev_dbg(ndev, "  loc=%u type=%u queue=%u srcip=%08X dstip=%08X sprt=%u dprt=%u\n",
            fs->location, fs->flow_type, (int)(fs->ring_cookie), htonl(tp4sp->ip4src),
                htonl(tp4sp->ip4dst), htons(tp4sp->psrc), htons(tp4sp->pdst));
    }
}

static int program_scrn_and_compares(struct net_device *ndev,
                                    struct ethtool_rx_flow_spec *fs) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    CEDI_T2Compare compVal;
    CEDI_T2Screen scrnVal;
    uint16_t index = fs->location*3;    /* index of 1st compare reg */
    struct ethtool_tcpip4_spec *tp4sp_v, *tp4sp_m;

    tp4sp_v = &(fs->h_u.tcp_ip4_spec); /* field values */
    tp4sp_m = &(fs->m_u.tcp_ip4_spec); /* field masks: b=1 => match bit */

    if (tp4sp_m->ip4src == 0xFFFFFFFF) { /* ignore field if any masking set */
    memset(&compVal, 0, sizeof(compVal));
    compVal.disableMask = 1;    /* 32-bit compare */
    /* src IP - offset 12 bytes after ethertype */
    compVal.offsetPosition = CEDI_T2COMP_OFF_ETYPE;
    compVal.offsetVal = 12;
    /* 1st compare reg - IP source address */
        compVal.compMask = tp4sp_v->ip4src & 0x0000FFFF;
        compVal.compValue = (tp4sp_v->ip4src & 0xFFFF0000) >> 16;
        if (0
                != (priv->eddObj->setType2CompareReg(priv->corePriv, index,
                        &compVal)))
        return -EINVAL;
    }

    if (tp4sp_m->ip4dst == 0xFFFFFFFF) { /* ignore field if any masking set */
        memset(&compVal, 0, sizeof(compVal));
        compVal.disableMask = 1; /* 32-bit compare */
    /* 2nd compare reg - IP destination address, offset 16 bytes */
        compVal.offsetPosition = CEDI_T2COMP_OFF_ETYPE;
        compVal.offsetVal = 16;
        compVal.compMask = tp4sp_v->ip4dst & 0x0000FFFF;
        compVal.compValue = (tp4sp_v->ip4dst & 0xFFFF0000) >> 16;
        if (0
                != (priv->eddObj->setType2CompareReg(priv->corePriv, index + 1,
                        &compVal)))
        return -EINVAL;
    }

    if ((tp4sp_m->psrc==0xFFFF) || (tp4sp_m->pdst==0xFFFF)) {
        /* ignore both port fields if masking set in both */
        memset(&compVal, 0, sizeof(compVal));
        /* 3rd compare reg - source port, dest port, immed. after IP header */
        if ((tp4sp_m->psrc==0xFFFF) && (tp4sp_m->pdst==0xFFFF)) {
            compVal.disableMask = 1; /* 32-bit compare */
            compVal.offsetPosition = CEDI_T2COMP_OFF_IPHDR;
            compVal.offsetVal = 0;
            compVal.compMask = tp4sp_v->psrc;
            compVal.compValue = tp4sp_v->pdst;
        } else {
            compVal.disableMask = 0; /* only one port definition: use 16-bit compare */
            compVal.compMask = 0xFFFF;
            compVal.offsetPosition = CEDI_T2COMP_OFF_IPHDR;
            if (tp4sp_m->psrc == 0xFFFF) { /* src port */
                compVal.offsetVal = 0;
                compVal.compValue = tp4sp_v->psrc;
            }
            else /* dst port */
            {
                compVal.offsetVal = 2;
                compVal.compValue = tp4sp_v->pdst;
            }
        }
        if (0!=(priv->eddObj->setType2CompareReg(priv->corePriv, index + 2,
                        &compVal)))
        return -EINVAL;
    }

    memset(&scrnVal, 0, sizeof(scrnVal));
    scrnVal.qNum = ((int)(fs->ring_cookie) & 0xFF);
    scrnVal.vlanEnable = 0;
    scrnVal.eTypeEnable = 0;        /* enable with enable_flow_filters */
    scrnVal.ethTypeIndex = 0;       /* already defined in enet_open */
    scrnVal.compAEnable = 0;
    scrnVal.compAIndex = index;
    scrnVal.compBEnable = 0;
    scrnVal.compBIndex = index+1;
    scrnVal.compCEnable = 0;
    scrnVal.compCIndex = index+2;
    if (0!=(priv->eddObj->setType2ScreenReg(priv->corePriv,
                                            fs->location, &scrnVal)))
        return -EINVAL;

    return 0;
}

/**
 * Get Rx flow filter spec from list
 * @param ndev      Device instance data
 * @param cmd       Ethtool command input structure
 */
static int cgrd_get_flow_entry(struct net_device *ndev,
                                struct ethtool_rxnfc *cmd) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct etht_fs_cont *item;
    int ret = -EINVAL;

    netdev_dbg(ndev, "Entered %s\n", __func__);

    list_for_each_entry(item, &priv->rx_fs_list.list, list) {
        if (item->fs.location==cmd->fs.location) {
            memcpy(&cmd->fs, &item->fs, sizeof(cmd->fs));
            ret = 0;
            break;
        }
    }
    return ret;
};

/**
 * Get all Rx flow filter specs
 * @param ndev      Device instance data
 * @param cmd       Ethtool command input structure
 * @param rule_locs pointer to array of item location numbers
 */
static int cgrd_get_all_flow_entries(struct net_device *ndev,
                                        struct ethtool_rxnfc *cmd,
                                        u32 *rule_locs) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct etht_fs_cont *item;
    uint32_t i = 0;

    netdev_dbg(ndev, "Entered %s\n", __func__);
    print_flow_list(ndev, priv);

    list_for_each_entry(item, &priv->rx_fs_list.list, list) {
        if (i==cmd->rule_cnt)
            return -EMSGSIZE;
        rule_locs[i] = item->fs.location;
        i++;
    }
    cmd->data = priv->maxNtups;
    cmd->rule_cnt = i;

    return 0;
};

/**
 *  Enable RSC if any flow filters defined and LRO & NTUPLE both on,
 *  else disable it.  Need to pass in new features set for calling
 *  within set_features
 */
static void update_rsc_state(struct net_device *ndev,
#if LINUX_VERSION_CODE < KERNEL_VERSION(3,3,0)
                                u32 feat) {
#else
                                netdev_features_t feat) {
#endif

    struct cgrd_priv *priv = netdev_priv(ndev);
    struct etht_fs_cont *item;
    uint8_t any_enabled = 0, enable, jumbo;
    int ret;
    unsigned long flags;

    enable = ((feat & NETIF_F_NTUPLE) && (feat & NETIF_F_LRO))?1:0;
    if (priv->rx_fs_list.count) {
        list_for_each_entry(item, &priv->rx_fs_list.list, list) {
            if (EOK!=(ret=priv->eddObj->setRscEnable(priv->corePriv,
                                        (int)(item->fs.ring_cookie), enable)))
                netdev_err(ndev, "RSC not enabled for queue %u, call returned %u\n",
                                        (int)(item->fs.ring_cookie), ret);
            else {
                any_enabled = enable;
                netdev_dbg(ndev, "%s - RSC %sabled for queue %u\n",
                            __func__, enable?"en":"dis", (int)(item->fs.ring_cookie));
            }
        }
    }
    /* Don't enable jumbo mode for RSC -> disable unless not RSC and large MTU */
    enable = (!any_enabled) && (ndev->mtu>1500);
    priv->eddObj->getJumboFramesRx(priv->corePriv, &jumbo);
    /* and don't touch if already in the state we want */
    if ((jumbo && !enable) || (!jumbo && enable)) {
        spin_lock_irqsave(&priv->lock, flags);
        priv->eddObj->setJumboFramesRx(priv->corePriv, enable);
        spin_unlock_irqrestore(&priv->lock, flags);
    }
    /* Need to enable header-data splitting also */
//    priv->eddObj->setHdrDataSplit(priv->corePriv, any_enabled);
}

/**
 * En/Disable queue screening for each Rx queue with a defined flow filter spec
 * @param ndev      Device instance data
 * @param enable    Set non-zero to enable, =0 to disable
 */
static void cgrd_enable_flow_filters(struct net_device *ndev,
                                      uint8_t enable) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct etht_fs_cont *item;
    struct ethtool_rx_flow_spec *fs;
    CEDI_T2Screen scrnVal;
    struct ethtool_tcpip4_spec *tp4sp_m;

    netdev_dbg(ndev, "Entered %s, enable=%u\n", __func__, enable);
    list_for_each_entry(item, &priv->rx_fs_list.list, list) {
        fs = &item->fs;
        netdev_dbg(ndev, "item->fs.type=%u  item->fs.location=%u  queue=%u\n",
                    fs->flow_type, fs->location, (int)(fs->ring_cookie));
        if (0!=(priv->eddObj->getType2ScreenReg(priv->corePriv,
                                        fs->location, &scrnVal)))
            continue;
        /* en/disable screener regs for the flow entry */
        scrnVal.eTypeEnable = enable?1:0;
        /* only enable fields with no masking */
        tp4sp_m = &(fs->m_u.tcp_ip4_spec); /* field masks */
        netdev_dbg(ndev,
                "%s  - src IP mask = %08X  dst IP mask = %08X  psrc mask = %04X  pdst mask = %04X\n",
                __func__, tp4sp_m->ip4src, tp4sp_m->ip4dst, tp4sp_m->psrc, tp4sp_m->pdst);
        if (enable && (tp4sp_m->ip4src==0xFFFFFFFF))
            scrnVal.compAEnable = 1;
        else
            scrnVal.compAEnable = 0;

        if (enable && (tp4sp_m->ip4dst==0xFFFFFFFF))
            scrnVal.compBEnable = 1;
        else
            scrnVal.compBEnable = 0;

        if (enable && ((tp4sp_m->psrc==0xFFFF) || (tp4sp_m->pdst==0xFFFF)))
            scrnVal.compCEnable = 1;
        else
            scrnVal.compCEnable = 0;

        priv->eddObj->setType2ScreenReg(priv->corePriv, fs->location, &scrnVal);
    }
};

/**
 * Add Rx flow filter to list
 * @param ndev      Device instance data
 * @param cmd       Ethtool command input structure
 */
static int cgrd_add_flow_entry(struct net_device *ndev,
                                struct ethtool_rxnfc *cmd) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct ethtool_rx_flow_spec *fs = &cmd->fs;
    struct etht_fs_cont *item, *newfs;
    int ret = -EINVAL;
    uint8_t en;

    netdev_dbg(ndev, "Entered %s\n", __func__);
    newfs = kmalloc(sizeof(*newfs), GFP_KERNEL);
    if (newfs == NULL)
        return -ENOMEM;
    memcpy(&newfs->fs, fs, sizeof(newfs->fs));

    netdev_dbg(ndev, "Adding flow filter entry, type=%u, queue=%u, loc=%u,"\
            " src=%08X dst=%08X ps=%u pd=%u\n",
            fs->flow_type, (int)fs->ring_cookie, fs->location,
            htonl(fs->h_u.tcp_ip4_spec.ip4src), htonl(fs->h_u.tcp_ip4_spec.ip4dst),
            htons(fs->h_u.tcp_ip4_spec.psrc), htons(fs->h_u.tcp_ip4_spec.pdst));

    /* find correct place to add in list */
    if (list_empty(&priv->rx_fs_list.list)) {
        list_add(&newfs->list, &priv->rx_fs_list.list);
        goto prog_hw;

    } else {
        list_for_each_entry(item, &priv->rx_fs_list.list, list) {
            if (item->fs.location > fs->location) {
                list_add_tail(&newfs->list, &item->list);
                goto prog_hw;
            }
            if (item->fs.location == fs->location) {
                netdev_err(ndev, "Rule not added: location %d not free!\n",
                            fs->location);
                ret = -EBUSY;
                goto drop;
            }
        }
        list_add_tail(&newfs->list, &priv->rx_fs_list.list);
    }

prog_hw:
    /* program screener regs with new filespec */
    netdev_dbg(ndev, "Programming screener&compares\n");
    if (0!=program_scrn_and_compares(ndev, fs)) {
        list_del(&newfs->list);
        netdev_err(ndev, "Rule not added: Error programming screener in h/w!\n");
        ret = -EINVAL;
        goto drop;
    } else
        priv->rx_fs_list.count++;
    /* enable filtering if NTUPLE on */
    if (ndev->features & NETIF_F_NTUPLE)
        cgrd_enable_flow_filters(ndev, 1);
    /* enable RSC if LRO & NTUPLE on */
    update_rsc_state(ndev, ndev->features);

    priv->eddObj->getRscEnable(priv->corePriv, (int)fs->ring_cookie, &en);
    netdev_dbg(ndev, "Finished %s: queue=%u  RSC enable: %u\n", __func__, (int)fs->ring_cookie, en);

    return 0;

drop:
    kfree(newfs);
    return ret;
}

/**
 * Delete Rx flow filter spec from list
 * @param ndev      Device instance data
 * @param cmd       Ethtool command input structure
 */
static int cgrd_del_flow_entry(struct net_device *ndev,
                                struct ethtool_rxnfc *cmd) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct etht_fs_cont *item;
    struct ethtool_rx_flow_spec *fs;
    CEDI_T2Screen scrnVal;
    u32 ret = -EINVAL;

    netdev_dbg(ndev, "Entered %s\n", __func__);

    if (list_empty(&priv->rx_fs_list.list))
         return ret;

    list_for_each_entry(item, &priv->rx_fs_list.list, list) {
        if (item->fs.location==cmd->fs.location) {
            /* disable screener regs for the flow entry */
            fs = &(item->fs);
            netdev_dbg(ndev, "Deleting flow filter entry, type=%u, queue=%u, loc=%u,"\
                    " src=%08X dst=%08X ps=%u pd=%u\n",
                    fs->flow_type, (int)fs->ring_cookie, fs->location,
                    htonl(fs->h_u.tcp_ip4_spec.ip4src), htonl(fs->h_u.tcp_ip4_spec.ip4dst),
                    htons(fs->h_u.tcp_ip4_spec.psrc), htons(fs->h_u.tcp_ip4_spec.pdst));
            scrnVal.qNum = (uint8_t)item->fs.ring_cookie;
            scrnVal.vlanEnable = 0;
            scrnVal.eTypeEnable = 0;
            scrnVal.compAEnable = 0;
            scrnVal.compBEnable = 0;
            scrnVal.compCEnable = 0;
            priv->eddObj->setType2ScreenReg(priv->corePriv, fs->location, &scrnVal);
            priv->eddObj->setRscEnable(priv->corePriv, (int)(fs->ring_cookie), 0);
            list_del(&item->list);
            kfree(item);
            priv->rx_fs_list.count--;
            ret = 0;
            break;
        }
    }
  
    update_rsc_state(ndev, ndev->features);

    return ret;
};

/**
 * Ethtool get_rxnfc handler
 * @param ndev      Device instance data
 * @param cmd       Ethtool command input structure
 * @param rule_locs flow class rule location
 */
static int cgrd_et_get_rxnfc(struct net_device *ndev,
                                struct ethtool_rxnfc *cmd,
                                u32 *rule_locs) {
  struct cgrd_priv *priv = netdev_priv(ndev);
  int ret = -EOPNOTSUPP;
  netdev_dbg(ndev, "Entered %s\n", __func__);

    switch (cmd->cmd) {
    case ETHTOOL_GRXRINGS:
        cmd->data = priv->num_rx_q;
        ret = 0;
        break;
    case ETHTOOL_GRXCLSRLCNT:
        netdev_dbg(ndev, "Recvd GRXCLSRLCNT cmd\n");
        cmd->rule_cnt = priv->rx_fs_list.count;
        ret = 0;
        break;
    case ETHTOOL_GRXCLSRULE:
        netdev_dbg(ndev, "Recvd GRXCLSRULE cmd\n");
        ret = cgrd_get_flow_entry(ndev, cmd);
        break;
    case ETHTOOL_GRXCLSRLALL:
        netdev_dbg(ndev, "Recvd GRXCLSRLALL cmd\n");
        ret = cgrd_get_all_flow_entries(ndev, cmd, rule_locs);
        break;
    default:
        break;
    }

    return ret;
}

/**
 * Ethtool set_rxnfc handler
 * @param ndev      Device instance data
 * @param cmd       Ethtool command input structure
 */
static int cgrd_et_set_rxnfc(struct net_device *ndev,
                                struct ethtool_rxnfc *cmd) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned long flags;
    int ret = -EOPNOTSUPP;

    netdev_dbg(ndev, "Entered %s, cmd->cmd=%u\n", __func__, cmd->cmd);
    spin_lock_irqsave(&priv->rx_fs_lock, flags);

    switch (cmd->cmd) {
    case ETHTOOL_SRXNTUPLE:
        netdev_dbg(ndev, "Recvd SRXNTUPLE cmd\n");
        break;
    case ETHTOOL_SRXCLSRLINS:
        netdev_dbg(ndev, "Recvd SRXCLSRLINS cmd\n");
        if ((cmd->fs.location>=priv->maxNtups) ||
            (cmd->fs.ring_cookie>=priv->num_rx_q)) {  /* also rejects RX_CLS_FLOW_DISC */
            ret = -EINVAL;
            break;
        }
        ret = cgrd_add_flow_entry(ndev, cmd);
        break;
    case ETHTOOL_SRXCLSRLDEL:
        netdev_dbg(ndev, "Recvd SRXCLSRLDEL cmd\n");
        ret = cgrd_del_flow_entry(ndev, cmd);
        break;
    default:
        break;
    }

    spin_unlock_irqrestore(&priv->rx_fs_lock, flags);
    return ret;
}

#if LINUX_VERSION_CODE > KERNEL_VERSION(3,5,0)
 /**
+ * Ethtool get_ts_info (timestamping) handler
+ * @param ndev      Device instance data
+ * @param info      Ethtool time-stamp info structure
+ */
int cgrd_et_get_ts_info(struct net_device *ndev, struct ethtool_ts_info *info)
{
    struct cgrd_priv *priv = netdev_priv(ndev);

        info->phc_index = ptp_clock_index(priv->ptp_clk);
    info->so_timestamping =
        SOF_TIMESTAMPING_TX_SOFTWARE |
        SOF_TIMESTAMPING_RX_SOFTWARE |
        SOF_TIMESTAMPING_TX_HARDWARE |
        SOF_TIMESTAMPING_RX_HARDWARE |
        SOF_TIMESTAMPING_RAW_HARDWARE |
        SOF_TIMESTAMPING_SOFTWARE;
    info->tx_types =
            (1 << HWTSTAMP_TX_ONESTEP_SYNC) |
            (1 << HWTSTAMP_TX_OFF) |
            (1 << HWTSTAMP_TX_ON);
    info->rx_filters = 1 << HWTSTAMP_FILTER_NONE;
    info->rx_filters |= 1 << HWTSTAMP_FILTER_ALL;
    return 0;
}
#endif

/**
 * ethtool function pointer table
 */
static const struct ethtool_ops cgrd_ethtool_ops = {
        .get_settings       = cgrd_et_get_settings,
        .set_settings       = cgrd_et_set_settings,
        .get_drvinfo        = cgrd_et_get_drvinfo,
#ifdef CONFIG_PM
        .get_wol            = cgrd_et_get_wol,
        .set_wol            = cgrd_et_set_wol,
#endif /* CONFIG_PM */
        .get_link           = ethtool_op_get_link,
        .get_ringparam      = cgrd_et_get_ringparam,
        .get_pauseparam     = cgrd_et_get_pauseparam,
        .set_pauseparam     = cgrd_et_set_pauseparam,
        .get_sset_count     = cgrd_et_get_sset_count,
        .get_strings        = cgrd_et_get_strings,
        .get_ethtool_stats  = cgrd_et_get_ethtool_stats,
#if LINUX_VERSION_CODE > KERNEL_VERSION(3,5,0)
        .get_ts_info        = cgrd_et_get_ts_info,
#endif
        .get_coalesce       = cgrd_get_coalesce,
        .set_coalesce       = cgrd_set_coalesce,
        .get_rxnfc          = cgrd_et_get_rxnfc,
        .set_rxnfc          = cgrd_et_set_rxnfc,
};

/**
 * An interrupt handler to be registered during cgrd__probe() execution.
 * This in turn calls the core interrupt handler.
 * @param	irq		Device IRQ number
 * @param	dev_id		Device instance data
 *
 * @return	IRQ_NONE		IRQ not from this device
 *		IRQ_HANDLED		IRQ was handled by this device
 *		IRQ_WAKE_THREAD		Requests to wake the handler thread
 */
static irqreturn_t cgrd_interrupt(int irq, void *dev_id) {
    struct net_device *ndev = dev_id;
    struct cgrd_priv *priv = netdev_priv(ndev);
    uint32_t result;

    spin_lock(&priv->lock);
    result = priv->eddObj->isr(priv->corePriv);
    spin_unlock(&priv->lock);
    if (result!=0)
        return IRQ_NONE;
    return IRQ_HANDLED;
}

/**
 * Returns device statistics.  Driver must update a private ndo_get_stats
 * structure and return a pointer to it in dev->stats. Should be atomic.
 * @param   ndev Struct describing MAC device attached to a PHY.
 * @param   storage struct for copying statistics to for return
 * @return  A pointer to device stats
 */
static struct rtnl_link_stats64 *cgrd_get_stats64(
        struct net_device *ndev, struct rtnl_link_stats64* storage) {
    struct cgrd_priv *priv = netdev_priv(ndev);
  struct cgrd_stats *stats = &priv->stats;

  netdev_dbg(ndev, "entered %s ndev=%p\n", __func__, ndev);
  cgrd_update_stats(priv);
    /* If core driver inited, call read_stats() */

  storage->rx_length_errors = (__u64)stats->undersizeFrRx +
    stats->oversizeFrRx + stats->jabbersRx +
    stats->lenChkErrRx;
  storage->rx_over_errors = stats->rxResourcErrs;
  storage->rx_crc_errors = (__u64)stats->fcsErrorsRx +
    stats->ipChksumErrs + stats->tcpChksumErrs +
    stats->udpChksumErrs;
  storage->rx_frame_errors = (__u64)stats->rxSymbolErrs +
    stats->alignErrsRx;
  storage->rx_fifo_errors = (__u64)stats->overrunFrRx +
    stats->dmaRxPBufFlush;
        //netdev_dbg(ndev, "entered %s ndev=%p\n", __func__, ndev);
  storage->tx_aborted_errors = stats->excessCollFrTx;
  storage->tx_carrier_errors = stats->carrSensErrsTx;
  storage->tx_fifo_errors = stats->underrunFrTx;
  storage->tx_window_errors = stats->lateCollFrTx;

  storage->rx_packets = stats->framesRx;
  storage->tx_packets = stats->framesTx;
  storage->rx_bytes = stats->octetsRx;
  storage->tx_bytes = stats->octetsTx;
  storage->rx_errors = storage->rx_length_errors +
    storage->rx_over_errors + storage->rx_crc_errors +
    storage->rx_frame_errors + storage->rx_fifo_errors;
  storage->tx_errors = storage->tx_aborted_errors +
    storage->tx_carrier_errors + storage->tx_fifo_errors +
    storage->tx_window_errors + stats->deferredFrTx;
//  storage->tx_dropped = ndev->stats.tx_dropped;
//  storage->rx_dropped = ndev->stats.rx_dropped;
  storage->multicast = stats->multicastRx;
  storage->collisions = (__u64)stats->singleCollFrTx +
    stats->multiCollFrTx;
    return storage;
}

/**
 * Normally passed through to phy_mii_ioctl() if the device is working
 * properly.  May need to handle SIOCHWTSTAMP in order to control PTP
 * timestamping.
 * EMAC h/w register r/w commands added.
 * @param	dev	Device instance data
 * @param	ifr	Command data
 * @param	cmd	Command code
 *
 * @return	-EINVAL, -ENODEV, or the result of phy_mii_ioctl()
 */
static int cgrd_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct emac_diag_d *rwDat;

    netdev_dbg(ndev, "entered %s ndev=%p\n", __func__, ndev);

#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
#   if defined(SIOCGHWTSTAMP)
    if (cmd==SIOCGHWTSTAMP)
	return cgrd_ptp_get_ts_config(ndev, ifr);
#   endif

    if (cmd==SIOCSHWTSTAMP)
	return cgrd_ptp_set_ts_config(ndev, ifr);
#endif


    /* handle EMAC diagnostic r/w commands */
    if ((cmd==CDSMAC_IOCTL_RD) && (priv->corePriv)) {
        rwDat = (struct emac_diag_d *)(ifr->ifr_ifru.ifru_data);

        if (EINVAL==(priv->eddObj->readReg(priv->corePriv,
                                (uint16_t)rwDat->addr_offs,
                                &(rwDat->reg_data))))
            return -EINVAL;
        else
            return 0;
    }
    else if ((cmd==CDSMAC_IOCTL_WR) && (priv->corePriv)) {
        rwDat = (struct emac_diag_d *)(ifr->ifr_ifru.ifru_data);
        if (EINVAL==(priv->eddObj->writeReg(priv->corePriv,
                                (uint16_t)rwDat->addr_offs,
                                rwDat->reg_data)))
            return -EINVAL;
        else
            return 0;
    }
    else if (cmd==CDSMAC_IOCTL_DBG_DUMP) {
    /* do a debug dump */
        rwDat = (struct emac_diag_d *)(ifr->ifr_ifru.ifru_data);
        cgrd_dump_regs_and_rx_queue(priv, rwDat->reg_data % priv->num_rx_q);
        //cgrd_dump_regs_and_tx_queue(priv, rwDat->reg_data % priv->num_tx_q);
        return 0;
    }

    if (!netif_running(ndev))
        return -EINVAL;
    if (!priv->phydev)
        return -ENODEV;
    return phy_mii_ioctl(priv->phydev, ifr, cmd);
}

/**
 * Validate MTU setting.
 */
static int cgrd_change_mtu(struct net_device *ndev, int mtu) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    int result = 0;

    //netdev_dbg(ndev, "entered %s mtu=%d\n", __func__, mtu);
    if ((mtu < MIN_MTU) || (mtu > MAX_MTU))
        result = -EINVAL;
    if (mtu <= 1500) {
        netdev_dbg(ndev, "disabling jumboFramesRx\n");
        priv->eddObj->setJumboFramesRx(priv->corePriv, 0);
    }
    //netdev_dbg(ndev, "setting jumboFrameRxMaxLen to %u\n", mtu + 18);
    priv->eddObj->setJumboFrameRxMaxLen(priv->corePriv, mtu + 18);
    if ((mtu > 1500)
            && !((ndev->features & NETIF_F_NTUPLE)
                    && (ndev->features & NETIF_F_LRO))) {
            /* prevent change of mtu from enabling jumbo mode if RSC */
        netdev_dbg(ndev, "enabling jumboFramesRx\n");
        priv->eddObj->setJumboFramesRx(priv->corePriv, 1);
    }
    ndev->mtu = mtu;
    return result;
}

#ifdef CONFIG_NET_POLL_CONTROLLER
/**
 * Polling "interrupt" handler.  Can be called when interrupts are disabled.
 * @param	ndev	Device instance data
 */
static void cgrd_netpoll(struct net_device *ndev) {
    unsigned long flags;

    netdev_dbg(ndev, "entered %s ndev=%p\n", __func__, ndev);
    local_irq_save(flags);
    cgrd_interrupt(ndev->irq, ndev);
    local_irq_restore(flags);
}
#endif

/**
 * Respond to changes in the NETIF_F_ features set.
 * @param	ndev		Device instance data
 * @param	features	New values for NETIF_F_ features
 *
 * @return	0:	No change
 *		>0:	Valid change?
 *		<0:	Error
 */
static int cgrd_set_features(struct net_device *ndev,
#if LINUX_VERSION_CODE < KERNEL_VERSION(3,3,0)
                                u32 features) {
#else
                                netdev_features_t features) {
#endif
    struct cgrd_priv *priv = netdev_priv(ndev);
    u64 diffs = features ^ ndev->features;
    u64 turnOn;
    int result = -ENODEV;

    netdev_info(ndev, "%s entered\n", __func__);
    netdev_dbg(ndev, "    old features=%lXh new features=%lXh\n",
            (long unsigned int)ndev->features, (long unsigned int)features);
    if (!priv || !priv->eddObj)
        return result;
    result = 0;

    if (diffs & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)) {
        u64 feat = features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);

        /* Handles IPv4 TCP and UDP */
        priv->eddObj->setTxChecksumOffload(priv->corePriv, 0 != feat);
    }
    if (diffs & NETIF_F_RXCSUM) {
        /* Receive checksum offload */
        priv->eddObj->setRxChecksumOffload(priv->corePriv,
                0 != (features & NETIF_F_RXCSUM));
    }
    if (diffs & NETIF_F_NTUPLE) {
        turnOn = features & NETIF_F_NTUPLE;
        netdev_dbg(ndev, "   NETIF_F_NTUPLE turning %s\n", turnOn?"on":"off" );
        cgrd_enable_flow_filters(ndev, turnOn?1:0);
        update_rsc_state(ndev, features);
    }

    if (diffs & NETIF_F_LRO) {
        turnOn = features & NETIF_F_LRO;
        netdev_dbg(ndev, "   NETIF_F_LRO turning %s\n", turnOn?"on":"off" );
        update_rsc_state(ndev, features);
    }
    return result;
}

/**
 * From GEM_GXL_UserGuide.pdf:
 *
 * The hash address register is 64 bits long and takes up two locations in the
 * memory map. The least significant bits are stored in hash register bottom
 * and the most significant bits in hash register top.
 *
 * The unicast hash enable and the multicast hash enable bits in the network
 * configuration register enable the reception of hash matched frames. The
 * destination address is reduced to a 6 bit index into the 64 bit hash
 * register using the following hash function. The hash function is an XOR of
 * every sixth bit of the destination address.
 *
 * hash_index[05] = da[05] ^ da[11] ^ da[17] ^ da[23] ^ da[29] ^ da[35] ^ da[41] ^ da[47]
 * hash_index[04] = da[04] ^ da[10] ^ da[16] ^ da[22] ^ da[28] ^ da[34] ^ da[40] ^ da[46]
 * hash_index[03] = da[03] ^ da[09] ^ da[15] ^ da[21] ^ da[27] ^ da[33] ^ da[39] ^ da[45]
 * hash_index[02] = da[02] ^ da[08] ^ da[14] ^ da[20] ^ da[26] ^ da[32] ^ da[38] ^ da[44]
 * hash_index[01] = da[01] ^ da[07] ^ da[13] ^ da[19] ^ da[25] ^ da[31] ^ da[37] ^ da[43]
 * hash_index[00] = da[00] ^ da[06] ^ da[12] ^ da[18] ^ da[24] ^ da[30] ^ da[36] ^ da[42]
 *
 * da[0] represents the least significant bit of the first byte received, that
 * is, the multicast/unicast indicator, and da[47] represents the most
 * significant bit of the last byte received.
 *
 * If the hash index points to a bit that is set in the hash register then the
 * frame will be matched according to whether the frame is multicast or unicast.
 *
 * A multicast match will be signalled if the multicast hash enable bit is set,
 * da[0] is logic 1 and the hash index points to a bit set in the hash register.
 *
 * A unicast match will be signalled if the unicast hash enable bit is set,
 * da[0] is logic 0 and the hash index points to a bit set in the hash register.
 *
 * To receive all multicast frames, the hash register should be set with all
 * ones and the multicast hash enable bit should be set in the network
 * configuration register.
 */
unsigned int calc_hash_index(unsigned char *mac_addr) {
    unsigned int hash_index = 0;
    u64 da = 0;
    int ix;

    /* Collect the address bits */
    for (ix = 5; ix >= 0; --ix) {
        da = (da << 8) | mac_addr[ix];
    }

    /* calculate the index 6 bits at a time */
    for (ix = 0; ix < 8; ++ix) {
        hash_index ^= da & 0x3F;
        da >>= 6;
    }
    return hash_index;
}


/**
 * Change address list filtering.  This includes setting of multicast list
 * and promiscuous modes.
 * @param	ndev	Device instance data
 */
static void cgrd_set_rx_mode(struct net_device *ndev) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    struct netdev_hw_addr *hw_addr;
    u64 hash = 0;
    uint8_t enable;
    u32 diff = ndev->flags ^ priv->flags;

    netdev_dbg(ndev, "entered %s ndev=%p\n", __func__, ndev);
    netdev_dbg(ndev, "ndev flags=%08X\n", ndev->flags);
    priv->flags = ndev->flags;

    /* call core driver to change config for relevant flags */
    if (diff & IFF_PROMISC) {
        enable = 0 != (ndev->flags & IFF_PROMISC);
        netdev_dbg(ndev, "flags=%xh enable=%xh\n", ndev->flags, enable);
        priv->eddObj->setCopyAllFrames( priv->corePriv, enable);
        netdev_dbg(ndev, "Promiscuous mode %sabled\n", enable ? "en" : "dis");
    }
    if (diff & IFF_ALLMULTI) {
        if (ndev->flags & IFF_ALLMULTI) {
            priv->eddObj->setHashAddr(priv->corePriv, ~0U, ~0U);
            priv->eddObj->setMulticastEnable(priv->corePriv, 1);
            netdev_dbg(ndev, "All multicast RX enabled\n");
        }
    }

    /* We need to treat IFF_MULTICAST regardless of last value, since
       mc adddresses may have changed */
    if ((ndev->flags & IFF_MULTICAST) && !netdev_mc_empty(ndev)) {
        /* Fill in hash here */
        netdev_for_each_mc_addr(hw_addr, ndev) {
            hash |= (u64)1 << calc_hash_index(hw_addr->addr);
        }
        priv->eddObj->setHashAddr(priv->corePriv,
                                  hash >> 32, (u32)hash);
        priv->eddObj->setMulticastEnable(priv->corePriv, 1);
        netdev_dbg(ndev, "Multicast RX enabled, hash=%llxh\n", hash);
    } else {
        priv->eddObj->setHashAddr(priv->corePriv, 0, 0);
        priv->eddObj->setMulticastEnable(priv->corePriv, 0);
        netdev_dbg(ndev, "Multicast RX disabled\n");
    }
}

/**
 * Set up the number of traffic classes in the device. Always
 * called with the rtnl lock held and netif tx queues stopped.
 * @param	ndev	Device instance data
 * @param	tc	Number of traffic classes
 *
 * @return	0 = successful?
 */
static int cgrd_setup_tc(struct net_device *ndev, u8 num_tc) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    int result = 0;
    u32 txq_avail = priv->num_tx_q;
    int cur_tc = 0;
    int cur_q = 0;
    int nq;

    //netdev_dbg(ndev, "entered %s num_tc=%u\n", __func__, num_tc);
    //netdev_dbg(ndev, "           txq_avail=%u\n", txq_avail);
    if (!num_tc) {
        netdev_reset_tc(ndev);
        goto done;
    }
    result = netdev_set_num_tc(ndev, num_tc);
    if (result)
        goto done;
    while (num_tc && txq_avail) {
        if (num_tc > txq_avail)
            nq = 1;
        else
            nq = txq_avail / num_tc;
        //netdev_dbg(ndev, "txq_avail=%u cur_q=%u num_tc=%u cur_tc=%u\n",
        //	txq_avail, cur_q, num_tc, cur_tc);
        netdev_set_prio_tc_map(ndev, cur_tc, cur_tc);
        netdev_set_tc_queue(ndev, cur_tc, nq, cur_q);
        if (num_tc <= txq_avail) {
            cur_q += nq;
            txq_avail -= nq;
        }
        ++cur_tc;
        --num_tc;
    }
    done:
    if (result)
        netdev_reset_tc(ndev);
    return result;
}

/**
 * Transmit a packet
 * @param	skb		Points to socket buff containing packet
 * @param	ndev		Device instance data
 *
 * @return	[NETDEV_TX_OK, NETDEV_TX_BUSY]
 */
static netdev_tx_t cgrd_start_xmit(struct sk_buff *skb,
                                    struct net_device *ndev) {
    netdev_tx_t result = NETDEV_TX_BUSY;
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned int qNum = skb->queue_mapping;
    CEDI_BuffAddr tmp_buf;
    CEDI_qTxBufParams txParams;
    unsigned int nr_frags, lso = 0;
    unsigned int frag, mss, offset = 0, d_offs;
    unsigned int hb_len = skb_headlen(skb);
    int len;
    unsigned int descs = 0, desc = 0;
    unsigned int udp = 0;
    skb_frag_t *fragp;
    unsigned long flags;
    uint16_t nFree;
    uint32_t ret;

    nr_frags = skb_shinfo(skb)->nr_frags;
    spin_lock_irqsave(&priv->lock, flags);
    lso = (0!=(mss = skb_shinfo(skb)->gso_size));
    /* first buffer length */
    if (lso) {
        udp = (IPPROTO_UDP==(((struct iphdr *)((u8 *)skb->data + 14))->protocol));

        if (udp)         /* length of headers */
            /* only queue eth+ip headers separately for UDP */
            txParams.length = skb_transport_offset(skb);
        else
            txParams.length = skb_transport_offset(skb) + tcp_hdrlen(skb);
    } else
    txParams.length = min(hb_len, TX_MAX_BUF_SIZE);

    /* calculate descriptors required */
    if (lso && (hb_len>txParams.length))
                /* extra header descriptor if also payload in first buffer */
        descs = DIV_ROUND_UP((hb_len-txParams.length),TX_MAX_BUF_SIZE) + 1;
    else
        descs = DIV_ROUND_UP(hb_len, TX_MAX_BUF_SIZE);
    /* add on descriptors for fragment buffers */
    for (frag=0; frag<nr_frags; frag++)
        descs += DIV_ROUND_UP(skb_frag_size(&skb_shinfo(skb)->frags[frag]),
                              TX_MAX_BUF_SIZE);

    /* check enough tx ring space available */
    priv->eddObj->txDescFree(priv->corePriv, qNum, &nFree);
    if (descs > nFree) {
        netif_stop_subqueue(ndev, qNum);
        goto tx_out;
    }

    netdev_dbg(ndev, "%s: skb=%p  queue=%u  skb->len=%u  headlen=%u"\
                 "  nr_frags=%u  gso_size=%u  descs=%u\n",
                 __func__, skb, qNum, skb->len, hb_len, nr_frags,
                 skb_shinfo(skb)->gso_size, descs);
    /* save descs in skb cb[0] */
    skb->cb[0] = descs & 0xFF;

    /* set up 1st buffer */
    txParams.queueNum = qNum;
    txParams.mssMfs = 0;
    txParams.tcpStream = 0;
    txParams.bufAdd = &tmp_buf;
    txParams.flags = (descs==1)?CEDI_TXB_LAST_BUFF:0;
    tmp_buf.vAddr = (uintptr_t)skb;    /* note skb for freeing after tx */

    if (lso) {
        if (udp)     /* different handling from tso */
        {
			/* include header and FCS in value given to h/w */
            txParams.mssMfs = mss + skb_transport_offset(skb) + 4;
            /* zero UDP checksum, not calculated by h/w for UFO */
            memset(skb->data + skb_transport_offset(skb) + UDP_CHK_OFFS,
                    0x00, 2);
        }
        else txParams.mssMfs = mss;
                              /* mss only used on data descriptor queueing */

        txParams.flags = udp?CEDI_TXB_UDP_ENCAP:CEDI_TXB_TCP_ENCAP;
        if (hb_len<txParams.length) {
            netdev_err(ndev,
               "%s: ***  Error - LSO headers fragmented!!!\n", __func__);
               /* if this is required, would need to copy to single buffer */
            goto tx_out;
        }
    }


    len = hb_len;
    while (len>0) {     /* queue buffers for first skb buffer */
        /* map first section buffer to hw */
        tmp_buf.pAddr = dma_map_single(priv->dev_p, skb->data + offset,
                                        txParams.length, DMA_TO_DEVICE);
        sgl_map++;
        if (dma_mapping_error(priv->dev_p, tmp_buf.pAddr)) {
            netdev_err(ndev,
               "%s: ***  Error mapping DMA buffer %u (skb=%p len=%u) !!!\n",
               __func__, desc, skb, skb->len);
            tmp_buf.pAddr = 0;
            goto tx_drop;
        }
        /*netdev_dbg(ndev,"%s: buffer %u mapped to tmp_buf.pAddr=%p,"\
                "  (.vAddr=%p)  length=%u  offset=%u\n",
                __func__, desc, (void *)tmp_buf.pAddr,
                (void *)tmp_buf.vAddr, txParams.length, offset);
        cgrd_dump_buf("    transmitting", qNum, skb->data + offset,
                            txParams.length);*/

        /* queue header buffer */
        if ( 0 != (ret=priv->eddObj->qTxBuf(priv->corePriv, &txParams)))
        {
            netdev_err(ndev,"%s: *** Error - queue %u, skb desc %u, offset %u: qTxBuf returned %u\n",
                        __func__, qNum, desc, offset, ret);
            goto tx_drop;
        }
        /* move on to next descriptor */
        desc++;
        len -= txParams.length;
        offset += txParams.length;
        txParams.length = min(len, TX_MAX_BUF_SIZE);
        if (desc==(descs-1))
            txParams.flags |= CEDI_TXB_LAST_BUFF;
        tmp_buf.vAddr = TX_BUF_INFO(desc,0,0);
    }

    d_offs = hb_len;    /* absolute data offset */

    for (frag = 0; frag<nr_frags; ++frag) {
        /* work through next fragment */
        fragp = &skb_shinfo(skb)->frags[frag];
        len = skb_frag_size(fragp);
        offset = 0;

        while (len>0) {     /* queue buffers for frag buffer */
            txParams.length = min(len, TX_MAX_BUF_SIZE);
            /* map buffer to hw */
            tmp_buf.pAddr = skb_frag_dma_map(priv->dev_p,
                              fragp, offset, txParams.length, DMA_TO_DEVICE);
            page_map++;
            if (dma_mapping_error(priv->dev_p, tmp_buf.pAddr)) {
                netdev_err(priv->netdev,
                    "%s: ***  Error mapping DMA buffer for frag %u (skb=%p len=%u desc=%u) !!!\n",
                    __func__, frag, skb, skb->len, desc);
                tmp_buf.pAddr = 0;
                goto tx_drop;
            }
            tmp_buf.vAddr = TX_BUF_INFO(desc,frag,1);
            /*netdev_dbg(ndev,
                    "%s: buffer %u (frag %u) %s mapped to tmp_buf.pAddr=%p,"\
                    "  (.vAddr=0x%08X)  length=%u  offset=%u\n",
                    __func__, desc, frag, PAGE_MAPPED(tmp_buf.vAddr)?"page":"",
                    (void *)tmp_buf.pAddr, (uint32_t)tmp_buf.vAddr,
                    txParams.length, offset);*/
#ifdef VVERBOSE_DEBUG
            skb_copy_bits(skb, d_offs, dbuf, (txParams.length>DBUF_LEN)?DBUF_LEN:txParams.length);
            cgrd_dump_buf("    transmitting", qNum, dbuf,
                           (txParams.length>DBUF_LEN)?DBUF_LEN:txParams.length);
#endif

            /* queue header buffer */
            if ( 0 != (ret=priv->eddObj->qTxBuf(priv->corePriv, &txParams)))
            {
                netdev_err(ndev,
                        "%s: *** Error - frag %u desc %u: qTxBuf returned %u\n",
                        __func__, frag, desc, ret);
                goto tx_drop;
            }

            /* move on to next descriptor */
            desc++;

            len -= txParams.length;
            offset += txParams.length;
            d_offs += txParams.length;
            if (desc==(descs-1))
                txParams.flags |= CEDI_TXB_LAST_BUFF;
        }
    }

    result = NETDEV_TX_OK;
    ndev->trans_start = jiffies;

  tx_out:
    spin_unlock_irqrestore(&priv->lock, flags);

    /*netdev_dbg(ndev, "%s: quitting function:  sgl_map=%u, page_map=%u\n",
                            __func__, sgl_map, page_map);*/

    return result;

  tx_drop:
    /* dequeue and unmap any buffers from this frame */

    if (tmp_buf.pAddr) {  /* was latest buffer already mapped? */
        if (PAGE_MAPPED(tmp_buf.vAddr))
            dma_unmap_page(priv->dev_p, (dma_addr_t)tmp_buf.pAddr,
                            txParams.length, DMA_TO_DEVICE);
        else
            dma_unmap_single(priv->dev_p, (dma_addr_t)tmp_buf.pAddr,
                            txParams.length, DMA_TO_DEVICE);
    }

    result = 0;
    while ((desc--) && (!result)) {
        if (0==(ret = priv->eddObj->deQTxBuf(priv->corePriv, &txParams))) {
            if (PAGE_MAPPED(txParams.bufAdd->vAddr))
                dma_unmap_page(priv->dev_p, (dma_addr_t)txParams.bufAdd->pAddr,
                        txParams.length, DMA_TO_DEVICE);
            else
                dma_unmap_single(priv->dev_p, (dma_addr_t)txParams.bufAdd->pAddr,
                        txParams.length, DMA_TO_DEVICE);
        }
        else
            netdev_err(ndev,
                "%s: *** Error - failed to dequeue Tx buffer: skb=%p len=%u desc=%u ret=%d\n",
                        __func__, skb, skb->len, desc, ret);
    }
    /* and free the sk_buff */
    dev_kfree_skb(skb);
    skb = NULL;

    spin_unlock_irqrestore(&priv->lock, flags);
    /*netdev_dbg(ndev, "%s: quitting after drop:  sgl_map=%u, page_map=%u\n",
                            __func__, sgl_map, page_map);*/

    return NETDEV_TX_OK;
}

/**
 * Optional.  Called when transmitter has not made any progress in
 * ndev->watchdog ticks.
 * @param	ndev		Device instance data
 */
static void cgrd_timeout(struct net_device *ndev) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned int qNum;
    unsigned long flags, dly;

    dly = jiffies - ndev->trans_start;
    netdev_dbg(ndev, "%s at %08lx, Tx delay %08lx jiffies / %u us\n",
                        __func__, jiffies, dly, jiffies_to_usecs(dly));
    spin_lock_irqsave(&priv->lock, flags);
    netif_tx_stop_all_queues(ndev);
    napi_disable(&priv->napi);

    /* Stop and reset all transmit queues */
    priv->eddObj->abortTx(priv->corePriv);
    for (qNum = priv->num_tx_q; qNum > 0; ) {
        --qNum;
        cgrd_tx_complete(priv, qNum, 1);
        priv->eddObj->resetTxQ(priv->corePriv, qNum);
        priv->eddObj->startTx(priv->corePriv);
        sgl_map = 0;
        page_map = 0;
    }

    ndev->trans_start = jiffies;
    napi_enable(&priv->napi);
    netif_tx_wake_all_queues(ndev);
    spin_unlock_irqrestore(&priv->lock, flags);
}

/**
 * Called when the device transitions to DOWN.  Calls the
 * core driver stop() routine, which does a graceful stop and disables
 * the interface.
 * @param	ndev		Device instance data
 *
 * @return	0 = successful
 */
static int cgrd_close(struct net_device *ndev) {
    struct cgrd_priv *priv = netdev_priv(ndev);
    unsigned long flags;
    u32 qNum;

    netdev_dbg(ndev, "entered %s ndev=%p\n", __func__, ndev);

#ifdef EMAC_MDIO
    if (priv->phydev)
        phy_stop(priv->phydev);
#endif
    napi_disable(&priv->napi);
    netif_tx_stop_all_queues(ndev);
    spin_lock_irqsave(&priv->lock, flags);
    priv->eddObj->stop(priv->corePriv);
    netif_carrier_off(ndev);
    spin_unlock_irqrestore(&priv->lock, flags);

    if (priv->phydev)
        phy_disconnect(priv->phydev);
    cgrd_mdio_destroy(priv);

    for (qNum = 0; qNum < priv->num_rx_q; ++qNum)
        cgrd_clear_rx_ring(priv, qNum);

    cgrd_remove_shaping_sysfs(priv);
    /* Remove the PTP driver */
    cprd_remove(priv);
    /* Teardown the low-level structures */
    cgrd_destroy_core(priv);
    return 0;
}

/**
 * Called when the device transitions to UP. Should call the
 * core driver start() routine.
 * @param	ndev		Device instance data
 *
 * @return	0 (success)
 * @return	-EADDRNOTAVAIL	Bad MAC address
 * @return	-ENODEV		Device not found
 * @return	-ENOMEM		Out of memory
 */
static int cgrd_enet_open(struct net_device *ndev) {
    int result = -ENOMEM;
    struct cgrd_priv *priv = netdev_priv(ndev);
    CEDI_OBJ *eddObj = priv->eddObj;
    uint32_t qNum;
    unsigned long flags;
    u8 enst_supported = 0;
    u64 temp;

    netdev_dbg(ndev, "entered %s ndev=%p\n", __func__, ndev);

    if (!is_valid_ether_addr(ndev->dev_addr))
        return -EADDRNOTAVAIL;

    /* Init the HW here (needed before any registers can be accessed) */
    result = cgrd_init_core(priv);

    if (result)
        goto open_err;

    /* Calculate TSU period from clock */

    if (tsu_freq)
    {
        ns_increment = div_u64(NSEC_PER_SEC, (u64)tsu_freq);
        temp = (NSEC_PER_SEC - ((u64)ns_increment * tsu_freq));
        temp *= (1 << EMAC_SUB_NS_INCR_SIZE);
        subns_increment = div_u64(temp, tsu_freq);
    }
    /* use already set defaults otherwise */

    cgrd_create_shaping_sysfs(priv);

    /* configure 1588 timer for EnST, if needed. */
    priv->eddObj->getEnstSupported(priv->corePriv, &enst_supported);
    if (enst_supported && priv->num_tx_q > 1)
    {
        CEDI_TimerIncrement incSettings;
        memset(&incSettings, 0, sizeof(CEDI_TimerIncrement));
        incSettings.nanoSecsInc = ns_increment;
        incSettings.altNanoSInc = 0;
        incSettings.altIncCount = 0;
        incSettings.subNsInc = (subns_increment >> EMAC_SUB_NS_INCR_LSB_SIZE) &
                               EMAC_SUB_NS_INCR_MSB_MASK;
        incSettings.lsbSubNsInc = subns_increment &
                                  EMAC_SUB_NS_INCR_LSB_MASK;
        priv->eddObj->set1588TimerInc(priv->corePriv,&incSettings);
    }

#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
    /* Connect the PTP driver */
    cprd_probe(priv);
#endif

    /* setup initial MAC address */
    eddObj->setSpecificAddr(priv->corePriv, 1, (void *)ndev->dev_addr, 0, 0);

    /* Pre-charge the RX buffer rings */
    for (qNum = 0; qNum < priv->num_rx_q; ++qNum) {
        result = cgrd_charge_rx_ring(priv, qNum);
        if (result)
            goto open_err;
    }

    /* Init MDIO bus.  Must come after call to eddObj->init() */
    result = cgrd_mdio_init(priv);
    if (result)
        goto open_err;
    /* setup PHY */
    result = cgrd_phy_probe(priv);
    if (result)
        goto open_err;

    /* max Rx flows set by availability of screeners & compare regs:
     * each 4-tuple defn requires 1 T2 screener reg + 3 compare regs */
    priv->maxNtups = (priv->hwCfg.num_scr2_compare_regs/3);
    if (priv->maxNtups > priv->hwCfg.num_type2_screeners)
        priv->maxNtups = priv->hwCfg.num_type2_screeners;
    /* also need one ethtype match to check IPv4 */
    if ((priv->maxNtups>0) && (priv->hwCfg.num_scr2_ethtype_regs>0)) {
        /* program this reg now */
        if (0!=(priv->eddObj->setType2EthertypeReg(priv->corePriv, 0,
                                                    (uint16_t)ETH_TYPE_IPV4))) {
            netdev_err(ndev,
              "%s failed to program Ethertype match reg -> no Rx flow filters\n",
                    __func__);
            priv->maxNtups = 0;
        }
    }
    else
        priv->maxNtups = 0;
    /* set clear mask, to keep RSC enabled permanently */
    eddObj->setRscClearMask(priv->corePriv, 1);


#ifdef EMAC_MDIO
    phy_start(priv->phydev);
#endif
    napi_enable(&priv->napi);

    /* HW enables */
    spin_lock_irqsave(&priv->lock, flags);
    eddObj->start(priv->corePriv);
    spin_unlock_irqrestore(&priv->lock, flags);

#ifndef EMAC_MDIO
    /* Until we have real phy transitions */
    cgrd_set_cbs_shaping(priv, PRIO_HI);
    cgrd_set_cbs_shaping(priv, PRIO_2ND);
    netif_carrier_on(ndev);
#endif
    netif_tx_start_all_queues(ndev);

    return 0;

  open_err:
    cgrd_close(ndev);
    return result;
}

#ifdef CONFIG_PM_SLEEP

static int cgrd_pm_suspend(struct device *dev_p) {
#ifdef EDD_PCI_NIC
    struct pci_dev *pdev =
            container_of(dev_p, struct pci_dev, dev);
    struct net_device *ndev = pci_get_drvdata(pdev);
#else
    struct platform_device *pdev =
            container_of(dev_p, struct platform_device, dev);
    struct net_device *ndev = platform_get_drvdata(pdev);
#endif
    struct cgrd_priv *priv = netdev_priv(ndev);

    netif_device_detach(ndev);
    if (netif_running(ndev)) {
        
        
        napi_disable(&priv->napi);
    }
    return 0;
}

static int cgrd_pm_resume(struct device *dev_p) {
#ifdef EDD_PCI_NIC
    struct pci_dev *pdev =
            container_of(dev_p, struct pci_dev, dev);
    struct net_device *ndev = pci_get_drvdata(pdev);
#else
    struct platform_device *pdev =
            container_of(dev_p, struct platform_device, dev);
    struct net_device *ndev = platform_get_drvdata(pdev);
#endif
    struct cgrd_priv *priv = netdev_priv(ndev);

    if (netif_running(ndev)) {
        
        
        napi_enable(&priv->napi);
    }
    netif_device_attach(ndev);
    return 0;
}

#else
#define cgrd_pm_suspend     NULL
#define cgrd_pm_resume      NULL
#endif /* CONFIG_PM_SLEEP */

static const struct dev_pm_ops cgrd_pm_ops = {
        SET_SYSTEM_SLEEP_PM_OPS(cgrd_pm_suspend, cgrd_pm_resume)
};

/**
 * General ethernet driver operations
 */
static const struct net_device_ops cgrd_device_ops = {
        .ndo_open               = cgrd_enet_open,
        .ndo_stop               = cgrd_close,
        .ndo_start_xmit	        = cgrd_start_xmit,
        .ndo_set_rx_mode        = cgrd_set_rx_mode,
        .ndo_set_mac_address    = eth_mac_addr,
        .ndo_do_ioctl           = cgrd_ioctl,
        .ndo_change_mtu         = cgrd_change_mtu,
        .ndo_tx_timeout         = cgrd_timeout,
        .ndo_get_stats64        = cgrd_get_stats64,
#ifdef CONFIG_NET_POLL_CONTROLLER
        .ndo_poll_controller    = cgrd_netpoll,
#endif
        .ndo_setup_tc           = cgrd_setup_tc,
        .ndo_set_features       = cgrd_set_features,
};

/**
 * Free allocated resources
 * @param	priv	Private instance data
 */
static void cgrd_cleanup(struct cgrd_priv *priv) {
    struct net_device *ndev;

    do {
        if (!priv)
            break;
        ndev = priv->netdev;

        if (ndev->irq > 0) {
            dev_dbg(priv->dev_p, "freeing irq %u\n", ndev->irq);
            free_irq(ndev->irq, ndev);
        }

#ifdef EDD_PCI_NIC

#ifdef EDD_PCI_MSI
            pci_disable_msi(priv->pcidev);
#endif

        if (priv->regmap) {
            iounmap(priv->regmap);
            release_mem_region(pci_resource_start(priv->pcidev, 0),
                    pci_resource_len(priv->pcidev, 0));
            priv->regmap = NULL;
        }
        priv->pcidev = NULL;
#else

        if (priv->regmap)
            iounmap(priv->regmap);
        priv->regmap = NULL;
        priv->platdev = NULL;
#endif

        if (ndev)
            free_netdev(ndev);
        priv->netdev = NULL;
        /* Now priv is no longer valid. */
    } while (0);
}

/**
 * Halt the device, unbind the driver, free all resources.
 * @param	pdev	device instance data
 *
 * @return	0 = success (always)
 */
#ifdef EDD_PCI_NIC
static void cgrd_pci_remove(struct pci_dev *pdev) {
    struct net_device *ndev = pci_get_drvdata(pdev);
#else
static int cgrd_platdev_remove(struct platform_device *pdev) {
    struct net_device *ndev = platform_get_drvdata(pdev);
#endif

    struct device *dev = &pdev->dev;
    struct cgrd_priv *priv;
#ifdef EDD_PCI_NIC
    unsigned long flags;
#endif

    dev_dbg(dev, "%s entered, pdev=%p ndev=%p\n", __func__, pdev, ndev);

    if (ndev) {
        netdev_dbg(ndev, "%s: de-registering net_device\n", __func__);
        priv = netdev_priv(ndev);
        netdev_dbg(ndev, "priv=%p\n", priv);


#ifdef DEBUG
        device_remove_file(&ndev->dev,  &dev_attr_test_config);
#endif
        device_remove_file(&ndev->dev,  &dev_attr_tsu_value);
        cgrd_remove_shaping_sysfs(priv);
        netif_napi_del(&priv->napi);
        unregister_netdev(ndev);

#ifdef EDD_PCI_NIC
        spin_lock_irqsave(&priv->lock, flags);
        pci_disable_device(pdev);
        spin_unlock_irqrestore(&priv->lock, flags);
        pci_set_drvdata(pdev, NULL);
#else
        platform_set_drvdata(pdev, NULL);
#endif

        cgrd_cleanup(priv);
    }

#ifndef EDD_PCI_NIC
    return 0;
#endif
}

/**
* Bind the driver to a device.
#ifdef EDD_PCI_NIC
* @param  pdev  PCI device instance data
* @param  id    PCI device instance ID
#else
* @param  pdev  Platform device instance data
#endif
*
* @return	0 = success
*/
#ifdef EDD_PCI_NIC
static int cgrd_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id) {
#else
static int cgrd_platdev_probe(struct platform_device *pdev) {

    struct resource *memres = NULL;
    const void *of_mac_addr = NULL;
    struct device_node *dn;
#endif
    CEDI_Config cfg;
    CEDI_SysReq req;
    struct net_device *ndev = NULL;
    struct cgrd_priv *priv = NULL;
    int result = -ENODEV;
    struct device *dev = &pdev->dev;
    void __iomem *regmap = NULL;
    unsigned int dmaAddr64 = 0;

    dev_dbg(dev, "%s entered, pdev=%p\n", __func__, pdev);

#ifdef EDD_PCI_NIC
    result = pci_enable_device(pdev);
    if (result < 0) {
      dev_err(dev, "Enabling the PCI device has failed: 0x%04X", result);
      goto probe_exit;
    }

    // set bus master enable bit in Ep's cfg space
    pci_set_master(pdev);

    /* Map BAR0 (BAR0 for 64-bit); registers memory mapped */
    if (check_mem_region(pci_resource_start(pdev, 0),
            pci_resource_len(pdev, 0))) {
        dev_err(dev, "BAR0 memory already in use");
        goto probe_exit;
    }
    dev_dbg(dev, "EMAC physical base addr = 0x%p\n",
            (void *)(uintptr_t)pci_resource_start(pdev, 0));

    request_mem_region(pci_resource_start(pdev, 0),
            pci_resource_len(pdev, 0), DRV_NAME);
    /* Map the virtual address of this device */
    regmap = ioremap_nocache(pci_resource_start(pdev, 0),
            pci_resource_len(pdev, 0));
    if (regmap == NULL) {
        dev_err(dev, "Mapping BAR0 mem map'd registers failed");
        goto probe_err;
    }
    dev_dbg(dev, "EMAC virtual base addr=%p\n", regmap);

    // DMA etc. init stuff here

#ifdef CEDI_64B_COMPILE
    if ((dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))))
        dev_err(dev, "Requesting 64 bit DMA has been rejected");
    else {
        dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
        dmaAddr64 = 1;
    }
#endif
    if (!dmaAddr64) {
        if ((dma_set_mask(&pdev->dev, DMA_BIT_MASK(32)))) {
            dev_err(dev, "Requesting 32 bit DMA has been rejected");
            goto probe_err;
        }
        dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
    }

#else  // not PCI
    /* Get the base address for this device */
    memres = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!memres) {
        dev_err(dev, "get_resource failed, aborting\n");
        goto probe_exit;
    }
    dev_dbg(dev, "reg physical addr=%xh\n", memres->start);

    /* Map the virtual address of this device */
    regmap = ioremap(memres->start, memres->end - memres->start + 1);
    if (!regmap) {
        dev_err(dev, "ioremap failed, aborting\n");
        goto probe_exit;
    }
    dev_dbg(dev, "reg virtual addr=%p\n", regmap);

#endif

    /* Do an initial probe to find the number of HW queues */
    memset(&cfg, 0, sizeof(cfg));
    cfg.regBase = (uintptr_t)regmap;
    cfg.rxQs = MAXNUM_RX_Q;
    cfg.txQs = MAXNUM_TX_Q;
    result = cgrd_probe_core(&cfg, &req);
    if (result)
        goto probe_err;
    dev_dbg(dev, "rxQs = %u\n", cfg.rxQs);
    dev_dbg(dev, "txQs = %u\n", cfg.txQs);

    result = -ENOMEM;
    /* alloc network device */
    ndev = alloc_etherdev_mqs(sizeof *priv, cfg.txQs, cfg.rxQs);
    if (!ndev) {
        dev_err(dev, "alloc_etherdev_mqs failed, aborting\n");
        goto probe_exit;
    }
    dev_dbg(dev, "alloc_etherdev_mqs successful, ndev=%p\n", ndev);

    SET_NETDEV_DEV(ndev, dev);
    priv = netdev_priv(ndev);
    dev_dbg(dev, "priv=%p\n", priv);
    priv->netdev = ndev;
#ifdef EDD_PCI_NIC
    priv->pcidev = pdev;
    ndev->base_addr = pci_resource_start(pdev, 0);
#else
    priv->platdev = pdev;
    ndev->base_addr = memres->start;
#endif
    priv->dev_p = dev;
    priv->regmap = regmap;
    priv->num_rx_q = cfg.rxQs;  /* use max available queues */
    priv->num_tx_q = cfg.txQs;
    priv->dmaAddr64 = dmaAddr64;

    spin_lock_init(&priv->lock);

    /* init interrupts */
#ifdef EDD_PCI_NIC
#ifdef EDD_PCI_MSI
    /* enable MSI interrupts on PCI */
    pci_enable_msi(pdev);
#endif
    ndev->irq = pdev->irq;
#else
    ndev->irq = platform_get_irq(pdev, 0);
    if (ndev->irq <= 0) {
        dev_err(dev, "platform_get_irq failed, aborting\n");
        goto probe_err;
    }
#endif
    dev_dbg(dev, "ndev->irq=%d\n", ndev->irq);
#ifdef EDD_PCI_MSI
    result = request_irq(ndev->irq, cgrd_interrupt, 0, ndev->name, ndev);
#else
    result = request_irq(ndev->irq, cgrd_interrupt, IRQF_SHARED, ndev->name, ndev);
#endif
    if (result) {
        dev_err(dev, "request_irq failed, aborting\n");
        goto probe_err;
    }
    dev_dbg(dev, "irq %u registered\n", ndev->irq);

    /* supported features */
    ndev->hw_features =
            NETIF_F_SG |
            NETIF_F_IP_CSUM |
            NETIF_F_IPV6_CSUM |
            NETIF_F_RXCSUM |
            NETIF_F_TSO |
            NETIF_F_UFO |
            NETIF_F_NTUPLE |
            NETIF_F_LRO;
    /* enabled features */
    ndev->features =
            NETIF_F_SG |
            NETIF_F_IP_CSUM |
            NETIF_F_IPV6_CSUM |
            NETIF_F_RXCSUM |
            NETIF_F_TSO |
            NETIF_F_UFO;

    dev_dbg(dev, "ndev flags=%08X\n", ndev->flags);
    dev_dbg(dev, "ndev features=%08X\n", (uint32_t)ndev->features);

#ifndef EDD_PCI_NIC
    /* Get MAC address from device tree */
    dn = pdev->dev.of_node;
    if (dn && of_device_is_available(dn)) {
        of_mac_addr = of_get_mac_address(dn);
    }
    if (of_mac_addr)
        memcpy(ndev->dev_addr, of_mac_addr, ETH_ALEN);
    if (!is_valid_ether_addr(ndev->dev_addr))
#endif
#ifdef NIC_FPGA
    {
        // 00:30:c5 is Cadence's ID
        ndev->dev_addr[0] = 0x00;
        ndev->dev_addr[1] = 0x30;
        ndev->dev_addr[2] = 0xc5;
#ifdef NIC_2
        ndev->dev_addr[3] = 0x20;
        ndev->dev_addr[4] = 0xe0;
        ndev->dev_addr[5] = 0x08;
#else
        ndev->dev_addr[3] = 0x00;
        ndev->dev_addr[4] = 0xe0;
        ndev->dev_addr[5] = 0x07;
#endif
    }
#else
        random_ether_addr(ndev->dev_addr);
#endif

    ndev->netdev_ops = &cgrd_device_ops;
    ndev->ethtool_ops = &cgrd_ethtool_ops;
    priv->eddObj = CEDI_GetInstance();

    /* init ntuple filtering */
    priv->maxNtups = 0;
    /* init Rx flow definitions */
    INIT_LIST_HEAD(&priv->rx_fs_list.list);
    priv->rx_fs_list.count = 0;
    spin_lock_init(&priv->rx_fs_lock);

    /* Warning: driver may be used immediately after register_netdev */
    result = register_netdev(ndev);
    if (result) {
        dev_err(dev, "register_netdev failed, aborting\n");
        goto probe_err;
    }

#ifdef EDD_PCI_NIC
    pci_set_drvdata(pdev, ndev);
#else
    platform_set_drvdata(pdev, ndev);
#endif
    netif_carrier_off(ndev);
    netif_napi_add(ndev, &priv->napi, cgrd_poll, NAPI_WEIGHT);
    device_create_file(&ndev->dev,  &dev_attr_tsu_value);
#ifdef DEBUG
    device_create_file(&ndev->dev,  &dev_attr_test_config);
#endif

    return 0;

  probe_err:
    cgrd_cleanup(priv);
  probe_exit:
    return result;
}

/* DTS/OpenFirmware match table */
static struct of_device_id cgrd_of_match[] = {
        { .compatible = "cdns,mac", },
        {}
};

MODULE_DEVICE_TABLE(of, cgrd_of_match);

#ifdef EDD_PCI_NIC
static struct pci_driver cgrd_pci_driver = {
        .name     = DRV_NAME,
        .id_table = dev_id_table,
        .probe    = cgrd_pci_probe,
        .remove   = cgrd_pci_remove,
};
#else
static struct platform_driver cgrd_mac_driver = {
        .probe		= cgrd_platdev_probe,
        .remove		= cgrd_platdev_remove,
        .driver		= {
                .name		= DEV_NAME,
                .owner		= THIS_MODULE,
                .pm		= &cgrd_pm_ops,
                .of_match_table	= cgrd_of_match,
        },
};
#endif

/***********************************************************************
 * Module load and unload
 **********************************************************************/


/**
 * Clean up and free all resources.
 */
static void __exit cgrd_exit_module(void) {
#ifdef EDD_PCI_NIC
    pci_unregister_driver(&cgrd_pci_driver);
#else
    platform_driver_unregister(&cgrd_mac_driver);
#endif
    pr_info("cds_mac.ko unloaded\n");
}

/**
 * Register all drivers.
 *
 * @return	0	If successful
 */
static int __init cgrd_init_module(void) {
    int result;

#ifdef VERBOSE_DEBUG
    /* Enable this to see ouput from the core driver */
    DbgMsgSetLvl(10);
    DbgMsgEnableModule(DBG_GEN_MSG);
#else
#ifdef VVERBOSE_DEBUG
    /* Even more debug log from the core driver */
    DbgMsgSetLvl(15);
    DbgMsgEnableModule(DBG_GEN_MSG);
#else
#ifdef VVVERBOSE_DEBUG
    DbgMsgSetLvl(15);
    DbgMsgEnableModule(DBG_GEN_MSG);
#endif
#endif
#endif

#ifdef EDD_PCI_NIC
    // register this driver
    result = pci_register_driver(&cgrd_pci_driver);
    if (result) {
        pr_err("%d: pci_register_driver failed\n", result);
        return result;
    }
#else
    /* Now we can init the driver */
    result = platform_driver_register(&cgrd_mac_driver);
    if (result) {
        pr_err("%d: Unable to register EMAC driver.\n", result);
        return result;
    }
#endif

    pr_info("cds_mac.ko loaded\n");
    return 0;
}

module_init(cgrd_init_module);
module_exit(cgrd_exit_module);

MODULE_AUTHOR("Cadence SCP");
MODULE_DESCRIPTION("Cadence EMAC Reference Driver");
MODULE_LICENSE("GPL");
