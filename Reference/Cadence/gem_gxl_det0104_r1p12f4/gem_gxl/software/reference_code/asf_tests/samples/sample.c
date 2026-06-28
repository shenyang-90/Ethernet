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
 * sample.c
 * Simple demonstration example file
 *****************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "cdn_errno.h"
#include "map_system_memory.h"

#include "asf_priv.h"
#include "asf_trace.h"


static ASF_Config config = {
  .regBase = (ASF_Regs*)(EXAMPLE_ASF_REGS_BASE),
  .controllerName = {"Example CORE with ASF"},
  .controllerVersion = {"1.0.0"},
  .transactionTimeoutValue = 100    
};

static ASF_PrivateData privateData;


static void sramCorrectableEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {  
    ASF_traceEvent(eventInfo);
}

static void sramUncorrectableEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    ASF_traceEvent(eventInfo);
}

static void dataAdressParityEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    ASF_traceEvent(eventInfo);
}

static void configStatusRegiseterEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    ASF_traceEvent(eventInfo);
}

static void transactionTimeoutEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    ASF_traceEvent(eventInfo);
}

static void protocolEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    ASF_traceEvent(eventInfo);
}

static void integrityEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    ASF_traceEvent(eventInfo);
}
    
ASF_Callbacks callback = {
    .sramCorrectableEvent = sramCorrectableEvent,
    .sramUncorrectableEvent = sramUncorrectableEvent,
    .dataAdressParityEvent = dataAdressParityEvent,
    .configStatusRegiseterEvent = configStatusRegiseterEvent,
    .transactionTimeoutEvent = transactionTimeoutEvent,
    .protocolEvent = protocolEvent,
    .integrityEvent = integrityEvent
};

void sampleIsr() {
    ASF_Isr(&privateData);
}


/** test setup function */
uint32_t startExample() {
    ASF_SysReq memReq;  
    uint32_t ret = EOK;
    uint8_t i = 0;
    uint32_t supported =0;
    
    memset(&memReq,0,sizeof(memReq));
 
    if ((ret= ASF_Probe(&config, &memReq)))  {       
        return ret;
    }
    
    /*Clear privateData memory*/
    memset(&privateData,0,sizeof(ASF_PrivateData));
    
    //set all parameters:
    ret = ASF_Init(&privateData, &config, &callback);
    if(ret != EOK) {
        return ret; 
    }
    
    /**Set all events as fatal*/
    for(i =0; i<= ASF_INTEGRITY; i++) {      
        ret = ASF_SetEventAsFatal(&privateData, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }
   
   /**set ASF_SRAM_CORRECTABLE events as non fatal*/
   ret = ASF_SetEventAsNonFatal(&privateData, ASF_SRAM_CORRECTABLE);
   if(ret == EOK)
      return EOK;

   /**enable handling of all supported events*/
   if(ASF_EnableAllEvents(&privateData) != EOK) {
      return EINVAL;
   }
   
   /*gets supported protocol errrors mask */
   if(ret = ASF_GetSupportedProtocolErrors(&privateData, &supported)) {
       return ret;
   }
   
   /*enable detection of protocol errors*/
   if(ASF_EnableProtocolEventByMask(&privateData, supported)) {
        return EINVAL;
   }

   /*gets supported protocol errrors mask */
   if(ret = ASF_GetSupportedTimeoutErrors(&privateData, &supported)) {
       return ret;
   }
   
   /*enable detection of protocol errors*/
   if(ASF_EnableTimeoutEventByMask(&privateData, supported)) {
        return EINVAL;
   }
   
   /*start driver and enable all selected interrupts*/
   ASF_Start(&privateData);
   
   /*initialize other drivers */
   //   ......
   
   ASF_Stop(&privateData);
   
   ASF_Destroy(&privateData);

   return 0;
}
