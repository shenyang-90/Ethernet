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
 * main.c
 * Example entry point. 
 * Platform specific file that should be implemented by programmer 
 *****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "cdn_errno.h"

#define _HAVE_DBG_LOG_INT_ 1
#include "log.h"

extern void sampleIsr();
extern uint32_t startExample();

/**
 * register access function - read operation
 */
uint32_t CPS_UncachedRead32(volatile uint32_t* address) {
    return *address;
}

/**
 * register access function - write operation
 */
void CPS_UncachedWrite32(volatile uint32_t* address, uint32_t value) {
    *address = value;
}

/**
 * Function should be registered as ISR function
 */
void ASF_IsrSample(uint32_t num) {
    /**ASF API function responsibles for handlin interrupts*/
    sampleIsr();
}

/**
 * disables interrupts on CPU
 */
void localIrqDisable()
{
}

/**
 * enable interrupts on CPU
 */
void localIrqEnable()
{
}

int main(int argc, char **argv) {
    uint32_t ret = EOK;
    /**In this place programmer should register ASF interrupt*/ 
    
    /*enable interrupts*/
    localIrqEnable();
    DbgMsgSetLvl(10);
    DbgMsgEnableModule(CLIENT_MSG);
    
    
    ret = startExample();
    if(ret != EOK) {
     
    }

    return 0;
}
