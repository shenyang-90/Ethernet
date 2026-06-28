/**********************************************************************
 * copyright (C) 2014-2015 Cadence Design Systems
 * All rights reserved.
 ***********************************************************************
 * cps_linux.c
 * Cadence Platform Services (CPS) implementation
 *
 * GEM linux version
 ***********************************************************************/

#include <asm/io.h>
#include "cps.h"
#include "cdn_stdint.h"

/****************************************************************************
 Only making use of 32-bit reads & writes, plus 16-bit read/writes in
 functional tests
****************************************************************************/

/* see cps.h */
uint32_t CPS_ProbeLocks(uint32_t lockCount) {
    return 0;
}

/* see cps.h */
uint32_t CPS_InitLock(CPS_LockHandle* lock) {
    return 0;
}

/* see cps.h */
void CPS_FreeLock(CPS_LockHandle lock) {
    return;
}

/* see cps.h */
uint32_t CPS_Lock(CPS_LockHandle lock) {
    return 0;
}

/* see cps.h */
uint32_t CPS_Unlock(CPS_LockHandle lock) {
    return 0;
}

/* see cps.h */
uint16_t CPS_UncachedRead16(volatile uint16_t* address) {
    return ioread16((void __iomem *)address);
}

/* see cps.h */
uint32_t CPS_UncachedRead32(volatile uint32_t* address) {
    return ioread32((void __iomem *)address);
}

/* see cps.h */
void CPS_UncachedWrite16(volatile uint16_t* address, uint16_t value) {
    iowrite16(value, (void __iomem *)address);
}

/* see cps.h */
void CPS_UncachedWrite32(volatile uint32_t* address, uint32_t value) {
    iowrite32(value, (void __iomem *)address);
}
