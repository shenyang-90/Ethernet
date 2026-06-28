/******************************************************************************
 * Copyright (C) 2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 *
 * The material contained herein is the proprietary and confidential
 * information of Cadence or its licensors, and is supplied subject to, and may
 * be used only by Cadence's customer in accordance with a previously executed
 * license and maintenance agreement between Cadence and that customer.
 *
 ******************************************************************************
 * asf_regs.h
 * register header file 
 *****************************************************************************/

#ifndef ASF_REGS_H
#define ASF_REGS_H

/**
 *generic macro used for following registers :
 *  - asf_int_status
 *  - asf_int_raw_status
 *  - asf_int_mask
 *  - asf_int_test
 *  - asf_fatal_nonfatal_select
 */
#define ASF_INTEGRITY_MASK (uint32_t)0x40u
#define ASF_INTEGRITY_OFFSET (uint32_t)6u
#define ASF_PROTOCOL_MASK (uint32_t)0x20u
#define ASF_PROTOCOL_OFFSET (uint32_t)5u
#define ASF_TRANS_TO_MASK (uint32_t)0x10u
#define ASF_TRANS_TO_OFFSET (uint32_t)4u
#define ASF_CSR_MASK (uint32_t)0x08u
#define ASF_CSR_OFFSET (uint32_t)3u
#define ASF_DAP_MASK (uint32_t)0x04u
#define ASF_DAP_OFFSET (uint32_t)2u
#define ASF_SRAM_UNCORR_MASK (uint32_t)0x02u
#define ASF_SRAM_UNCORR_OFFSET (uint32_t)1u
#define ASF_SRAM_CORR_MASK   (uint32_t)0x01u
#define ASF_SRAM_CORR_OFFSET (uint32_t)0u

#define ASF_INT_MASK (ASF_INTEGRITY_MASK | \
                ASF_PROTOCOL_MASK        | \
                ASF_TRANS_TO_MASK        | \
                ASF_CSR_MASK             | \
                ASF_DAP_MASK             | \
                ASF_SRAM_UNCORR_MASK     | \
                ASF_SRAM_CORR_MASK)

//asf_sram_corr_fault_status and asf_sram_uncorr_fault_status register
#define ASF_SRAM_F_INST_OFFSET (uint32_t)24u
#define ASF_SRAM_F_INST_MASK ((uint32_t)0xFFu << ASF_SRAM_F_INST_OFFSET)
#define ASF_SRAM_F_ADDR_OFFSET 0
#define ASF_SRAM_F_ADDR_MASK (uint32_t)0xFFFFFFu

//asf_sram_fault_stats
#define ASF_SRAM_F_UNCORR_STATS_OFFSET (uint32_t)16u
#define ASF_SRAM_F_UNCORR_STATS_MASK ((uint32_t)0xFFu << ASF_SRAM_F_UNCORR_STATS_OFFSET)
#define ASF_SRAM_F_CORR_STATS_OFFSET (uint32_t)0u
#define ASF_SRAM_F_CORR_STATS_MASK (uint32_t)0xFFFFu

//asf_sram_fault_stats
#define ASF_TRANS_TO_EN_MASK (uint32_t)0x80000000u
#define ASF_TRANS_TO_CTRL (uint32_t)0xFFFFu

#define ASF_TO_PROTOCOL_MASK (uint32_t)0xFFFFFFFFu

typedef struct ASF_Regs_s {
    uint32_t int_status;
    uint32_t int_raw_status;
    uint32_t int_mask;
    uint32_t int_test;
    uint32_t fatal_nonfatal_select;
    uint32_t reserved1[3];
    uint32_t sram_corr_fault_status;
    uint32_t sram_uncorr_fault_status;
    uint32_t sram_fault_status;
    uint32_t reserved2;
    uint32_t trans_to_ctrl;
    uint32_t trans_to_fault_mask;
    uint32_t trans_to_fault_status;
    uint32_t reserved3;
    uint32_t protocol_fault_mask;
    uint32_t protocol_fault_status;
} ASF_Regs;

#endif /*ASF_REGS_H*/
