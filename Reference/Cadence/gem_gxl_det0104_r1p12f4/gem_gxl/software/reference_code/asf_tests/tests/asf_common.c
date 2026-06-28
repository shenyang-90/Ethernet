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
 * asf_common.c
 * Common helper Functions for tests
 *****************************************************************************/
#include <string.h>
#include <stdio.h>
#include "cdn_errno.h"
#include "asf_priv.h"
#include "asf_if.h"
#include "asf_common.h"

extern ASF_Instance asfInstances[];
extern ASF_Callbacks callback;

uint8_t getInstanceId(ASF_PrivateData *privetData) {
    uint8_t i=0;
    for(i=0; i < ASF_INSTANCE_NUMBER; i++) {
        if(&asfInstances[i].priv == privetData) {
            return i;
        }
    }
    return 0;
}

void ASF_clearEventInfoObj(ASF_PrivateData *priv) {
    uint8_t id = getInstanceId(priv);
    
    memset((void*)&asfInstances[id].lastReportedEvent, 0, sizeof(asfInstances[id].lastReportedEvent));
    asfInstances[id].eventChanged = 0;
}

uint32_t ASF_checkEventObj(ASF_EventInfo *event, 
                          const char *expectedVersion, 
                          const char *expectedName, 
                          const ASF_EventErrorType expectedErrorCode,
                          const uint8_t expectedFatalEvent) {
    
    if(expectedVersion) {
        if(!strcmp((char*)event->version, expectedVersion)) 
            return EINVAL;
    }

    if(expectedName) {
        if(!strcmp((char*)event->name, expectedName)) 
            return EINVAL;
    }
    
    if(event->eventErrorCode != expectedErrorCode)
      return EINVAL;
      
    if(event->fatalEvent != expectedFatalEvent)
      return EINVAL;
  
    return EOK;          
}


void copyLastEventObject(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo){
    uint8_t id = getInstanceId(privetData) ;
    asfInstances[id].eventChanged = 1;
    asfInstances[id].lastReportedEvent = *eventInfo;
}

void ASF_ClearSingleInstance(ASF_Instance * inst) {
    
    ASF_Stop(&inst->priv);
    ASF_Destroy(&inst->priv);
}

void ASF_ClearAllInstance() {
  uint8_t i; 
  
  /*Initialize all ASF inctance*/
  for(i=0; i < ASF_INSTANCE_NUMBER; i++) {    
    ASF_ClearSingleInstance(&asfInstances[i]);    
  }
 
}

uint32_t ASF_InitSingleInstance(ASF_Instance * inst) {
    ASF_SysReq memReq;  

    uint32_t ret;
  
    inst->status = 0;	   
    memset(&memReq,0,sizeof(memReq));
 
    if ((ret= ASF_Probe(&inst->config, &memReq)))  {
        inst->status = TEST_ERR_PROBE;
        return inst->status;
    }
    
    /*Clear privateData memory*/
    memset(&inst->priv,0,sizeof(ASF_PrivateData));
    
    //set all parameters:
    ret = ASF_Init(&inst->priv, &inst->config, &callback);

    if (ret != 0) {
        inst->status = TEST_ERR_INIT;	
    } 
  
    return inst->status;
}

uint32_t ASf_InitAllInstances(ASF_StatInfo * stat) {
  uint8_t i; 
  uint32_t ret=0;
  
  /*Initialize all ASF inctance*/
  for(i=0; i < ASF_INSTANCE_NUMBER; i++) {
    ret = ASF_InitSingleInstance(&asfInstances[i]);
    if(ret) {
      /*Error detected druing initialization this ASF instance*/
      continue;
    }
  }
  return ret;
}

uint32_t ASF_CompareStatisticObj(ASF_StatInfo *stat1, ASF_StatInfo *stat2) {
    /** Name of controller associated with ASF module. */
    if(!strcmp((char*)stat1->name, (char*)stat2->name))
        return EINVAL;
    
    if(!strcmp((char*)stat1->name, (char*)stat2->name))
        return EINVAL;

    if(stat1->integrityErrCounter != stat2->integrityErrCounter)
        return EINVAL;      
    
    if(stat1->configStatusErrCounter != stat2->configStatusErrCounter)
        return EINVAL;      

    if(stat1->dataAdressParityErrCounter != stat2->dataAdressParityErrCounter)
        return EINVAL;      
  
    if(stat1->sramUncorrectableErrCounter != stat2->sramUncorrectableErrCounter)
        return EINVAL;      

    if(stat1->sramCorrectableErrCounter != stat2->sramCorrectableErrCounter)
        return EINVAL;      

    if(stat1->allProtocolErrCounter != stat2->allProtocolErrCounter)
        return EINVAL;      

    if(stat1->allTimeoutErrCounter != stat2->allTimeoutErrCounter)
        return EINVAL;      
    
    //TODO: compare lastSramCorrectableErr, lastSramUncorrectableErr, protocolErrCounter and timeoutErrCounter
    return EOK;
};  
