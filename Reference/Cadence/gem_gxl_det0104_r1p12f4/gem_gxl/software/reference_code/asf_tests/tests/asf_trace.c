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
 * asf_trace.c
 * debugging functions source file
 *****************************************************************************/
#include <stdio.h>
#include "cdn_errno.h"
#include "asf_priv.h"
#include "asf_if.h"

char *asf_trace_features[] = {
  "ASF_SRAM_CORRECTABLE",
  "ASF_SRAM_UNCORRECTABLE",
  "ASF_DATA_PARITY",
  "ASF_CONFIGURATION",
  "ASF_TRANSACTION_TIMEOUT",
  "ASF_PROTOCOL",
  "ASF_INTEGRITY",
};

uint32_t ASF_traceConfigSetting(ASF_PrivateData * priv) {
    uint32_t flag = 0;
    uint32_t ret = 0;
    uint32_t i = 0;

    ret = ASF_GetSupportedASF(priv, &flag);
    if(ret) {
      printf("Error func: %s line: %d error code: %d \n", __func__, __LINE__, ret);
      return ret;
    } 
    
    printf("ASF setting for ASF: %s version: %s\n", priv->controllerName, priv->controllerVersion);
    printf("Supported Features %x\n", flag);
    
    for(i=0; i <= ASF_INTEGRITY; i++)  {
        ret = ASF_CheckIfASFSupported(priv, i);
        if(ret == EINVAL) {
            printf("Error func: %s line: %d error code: %d \n", __func__, __LINE__, ret);
            return ret;
        } else { 
            printf("%s : %s\n", asf_trace_features[i], ret == ENOTSUP ? "false" : "true");\
        }
    }
    
    ret = ASF_GetSupportedTimeoutErrors(priv, &flag);
    if(ret) {
          printf("Error func: %s line: %d error code: %d\n", __func__, __LINE__, ret);
          return ret;
    }
    
    printf("ASF Supported Timeout Errors: %08x\n", flag);
    
    ret = ASF_GetSupportedProtocolErrors(priv, &flag);    
    if(ret) {
          printf("Error func: %s line: %d error code: %d\n", __func__, __LINE__, ret);
          return ret;
    }
    
    printf("ASF Supported Protocol Errors: %08x\n", flag);
    return ret;
}

void ASF_TraceSimpleStatInfo(ASF_StatInfo *stat) {
    printf("=================================\n");
    printf("Statistic Info:"); 
    printf("Controller name: %s\n", stat->name); 
    printf("Controller version: %s\n", stat->version);
    printf("integirty error counter: %d\n", stat->integrityErrCounter);
    printf("Protocol error counter: %d\n", stat->allProtocolErrCounter);
    printf("Transaction timoeut error counter: %d\n", stat->allTimeoutErrCounter);
    printf("Configuration and status registers error counter: %d\n", stat->configStatusErrCounter);
    printf("Data and address path parity error counter: %d\n", stat->dataAdressParityErrCounter);
    printf("SRAM uncorectable error counter: %d\n", stat->sramUncorrectableErrCounter);
    printf("SRAM corectable error counter: %d\n", stat->sramCorrectableErrCounter);
}    

void ASF_TraceExtendedStatInfo(ASF_StatInfo *stat) {
    uint32_t i=0;
    
    ASF_TraceSimpleStatInfo(stat);
    
    if(stat->sramCorrectableErrCounter > 0) {
        printf("Detected Sram correctable errors:\n");
        for(i=0; i < ASF_LAST_SRAM_ERROR_ARRAY_SIZE; i++) {
            ASF_sramEventInfo *sram = &stat->lastSramCorrectableErr[i];
            if(sram->sramAddress) {
                printf("SRAM Instance ID: %d, address: %x\n", 
                    sram->sramInstanceId,
                    sram->sramAddress);
            }
        }
    } else {
        printf("No SRAM correctable errors were detected\n");
    }
    
    if(stat->sramUncorrectableErrCounter > 0) {
        printf("Detected Sram uncorrectable errors:\n"); 
        for(i=0; i < ASF_LAST_SRAM_ERROR_ARRAY_SIZE; i++) {
            ASF_sramEventInfo *sram = &stat->lastSramUncorrectableErr[i];
            if(sram->sramAddress) {
                printf("SRAM Instance ID: %d, address: %x\n", 
                    sram->sramInstanceId,
                    (uintptr_t*)sram->sramAddress);
            }
       }
    } else {
        printf("No SRAM uncorrectable errors were detected\n");
    }


    if(stat->allProtocolErrCounter > 0) {
        printf("Detected protocol errors:\n");
        for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
            printf("Error number: %d, counter: %d\n", 
                i,
                stat->protocolErrCounter[i]);
        }
    } else {
      printf("No protocol errors were detected\n");
    }

    if(stat->allTimeoutErrCounter > 0) {
        printf("Detected timeout errors:\n");
        for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
            printf("Error number: %d, counter: %d\n", 
                i,
                stat->timeoutErrCounter[i]);
        }
    } else {
        printf("No timeout errors were detected\n");
    }
    
}

char * ASF_EventErrorTypeToString(ASF_EventErrorType eventErrorCode){
  
    switch(eventErrorCode) {
        case ASF_SRAM_CORRECTABLE:
            return "SRAM correctable error";
        case ASF_SRAM_UNCORRECTABLE: 
            return "SRAM Uncorectable error ";
        case ASF_DATA_PARITY:
            return "Data and address path parity error";
        case ASF_CONFIGURATION:
           return "Configuration and status registers error";
        case ASF_TRANSACTION_TIMEOUT:
            return "Transaction timoeut error";   
        case ASF_PROTOCOL:
            return "Protocol error";
        case ASF_INTEGRITY:
            return "Integrity error";		
    }   
    return "Detected Incorrect error code";
}

void ASF_traceEvent(ASF_EventInfo* eventInfo) {
    ASF_sramInfo *sram = &eventInfo->sramInfo;
    printf("=================================\n");
    printf("Event Info:"); 
    printf("Controller name: %s\n", eventInfo->name); 
    printf("Controller version %s\n", eventInfo->version);
    printf("Error type: %s\n", ASF_EventErrorTypeToString(eventInfo->eventErrorCode));
    printf("Event type: %s\n", eventInfo->fatalEvent ? "fatal" : "non fatal");
    
    switch(eventInfo->eventErrorCode) {
        case ASF_SRAM_CORRECTABLE:
        case ASF_SRAM_UNCORRECTABLE:
            printf("SRAM insance id: %d, address: %x\n", sram->sramFaultInfo.sramInstanceId, 
                  sram->sramFaultInfo.sramAddress);
            printf("Error was corrected: %s\n", sram->sramUncorrectableError ? "no" : "yes");
            printf("uncorrectable error counter value: %d\n", sram->uncorrectableErroCounter);
            printf("correctable error counter value: %d\n", sram->correctableErrorCounter);
            break;
        case ASF_TRANSACTION_TIMEOUT:
        case ASF_PROTOCOL:
            printf("Extended Errror number: %d\n", eventInfo->extendedErrorIdx);
            break;
      default:
        break;
    }
}
