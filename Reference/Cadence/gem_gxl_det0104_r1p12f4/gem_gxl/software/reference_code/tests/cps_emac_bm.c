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
 * cps_emac_bm.c
 * Cadence Platform Services (CPS) implementation,
 * GEM ARM bare-metal version
 *****************************************************************************/

#ifdef __BARE_METAL__

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "cps.h"

/* see cps.h */
uint8_t CPS_UncachedRead8(volatile uint8_t* address) {
    return *address;
}

/* see cps.h */
uint16_t CPS_UncachedRead16(volatile uint16_t* address) {
    return *address;
}

/* see cps.h */
uint32_t CPS_UncachedRead32(volatile uint32_t* address) {
    uint32_t value = *address;
    return value;
}

/* see cps.h */
void CPS_UncachedWrite8(volatile uint8_t* address, uint8_t value) {
    *address = value;
}

/* see cps.h */
void CPS_UncachedWrite16(volatile uint16_t* address, uint16_t value) {
    *address = value;
}

/* see cps.h */
void CPS_UncachedWrite32(volatile uint32_t* address, uint32_t value) {
    *address = value;
}

/* see cps.h */
void CPS_WritePhysAddress32(volatile uint32_t* location, uint32_t addrValue) {
  *location = addrValue;
}

/* see cps.h */
void CPS_BufferCopy(volatile uint8_t *dst, volatile uint8_t *src, uint32_t size) {
    memcpy((void*)dst, (void*)src, size);
}

/* see cps.h */
uint32_t CPS_InitLock(CPS_LockHandle* lock) {
  return 0;
}

/* see cps.h */
void CPS_FreeLock(CPS_LockHandle lock) {
}

/* see cps.h */
uint32_t CPS_ProbeLocks(uint32_t lockCount) {
  return 0;
}

#endif /* __BARE_METAL__ */
