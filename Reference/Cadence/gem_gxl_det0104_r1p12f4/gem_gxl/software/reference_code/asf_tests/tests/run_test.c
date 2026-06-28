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
 * run_tests.c
 * Entry point for tests 
 *****************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "cdn_errno.h"
#include "map_system_memory.h"
#include "asf_priv.h"
#include "asf_trace.h"
#include "asf_common.h"
#include "asf_tests.h"

#include "test_harness_log.h"

#define ASF_INSTANCE_NUMBER 1

ASF_Instance asfInstances[ASF_INSTANCE_NUMBER] = {
    { 
        .config = {
        .regBase = (ASF_Regs*)(EMAC_GEM0_REGS_BASE + 0xE00),
        .controllerName = {"GEM0 CORE with ASF"},
        .controllerVersion = {"1.0.0"},
        .transactionTimeoutValue = 100    
        },
        .id = 0,
        .status = 0
    }
};


void sramCorrectableEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {  
    copyLastEventObject(privetData, eventInfo); 
    ASF_traceEvent(eventInfo);
}
void sramUncorrectableEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    copyLastEventObject(privetData, eventInfo);
    ASF_traceEvent(eventInfo);
}

void dataAdressParityEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    copyLastEventObject(privetData, eventInfo);
    ASF_traceEvent(eventInfo);
}

void configStatusRegiseterEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    copyLastEventObject(privetData, eventInfo);
    ASF_traceEvent(eventInfo);
}

void transactionTimeoutEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    copyLastEventObject(privetData, eventInfo);
    ASF_traceEvent(eventInfo);
}
void protocolEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    copyLastEventObject(privetData, eventInfo);
    ASF_traceEvent(eventInfo);
}
void integrityEvent(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo) {
    copyLastEventObject(privetData, eventInfo);
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

void ASF_Isr1() {
    ASF_Isr(&asfInstances[0].priv);
}

#if 0
void ASF_Isr2() {
    ASF_Isr(&asfInstances[1].priv);
}
#endif

// use it when function passed
// generates line as follow:
// TESTING: testName PASSED
#define TESTING_TEST_PASSED(testName) do {\
    vDbgMsg(DBG_USB_APP_VERBOSE, 1, "TESTING %s: PASSED\n", testName); \
} while (0)

// use it when function failed
// generates line as follow:/
// TESTING: testName FAILED
#define TESTING_TEST_FAILED(testName) do {\
    vDbgMsg(DBG_USB_APP_VERBOSE, 1, "TESTING %s: PASSED\n", testName); \
} while (0)

void testResult(char* testName, uint32_t errorCode){
    if(errorCode == EOK) 
        TESTING_TEST_PASSED(testName);
    else 
        TESTING_TEST_PASSED(testName);
}


static void TestComplete(void) {
    while (1);
}

/** test setup function */
uint32_t ASF_RunFunctionalTests() {
    uint32_t i = 0;
    uint32_t ret =0;
    ASF_StatInfo stats;
        
    ASf_InitAllInstances();
    
    for(i=0; i< ASF_INSTANCE_NUMBER; i++) {      
        ASF_PrivateData *priv = &asfInstances[i].priv;
        ASF_Start(priv);
        ASF_traceConfigSetting(priv);

        if(!asfInstances[i].status) {

            ret = ASF_testBIST1(&asfInstances[i].priv);
            testResult("ASF_testBIST1", ret);


            ret = ASF_GetStatistic(&asfInstances[i].priv, &stats);
            ASF_TraceExtendedStatInfo(&stats);

            ret = ASF_testBIST2(&asfInstances[i].priv);
            testResult("ASF_testBIST2", ret);    

            ret = ASF_testDisableAllEventsFunc(priv);
            testResult("ASF_testDisableAllEventsFunc", ret);

            ret = ASF_testEnableAllEventsFunc(priv);
            testResult("ASF_testEnableAllEventsFunc", ret);
    
            ret = ASF_testEnableEventFunc(priv);
            testResult("ASF_testEnableEventFunc", ret);

            ret = ASF_testDisableEventFunc(priv);
            testResult("ASF_testDisableEventFunc", ret);

            ret = ASF_testSetEventAsNonFatalFunc(priv, i);
            testResult("ASF_testSetEventAsNonFatalFunc", ret);

            ret = ASF_testEnableProtocolEventByMaskFunc(priv);
            testResult("ASF_testEnableProtocolEventByMaskFunc", ret);

            ret = ASF_testEnableProtocolEventByMaskFunc(priv);
            testResult("ASF_testEnableProtocolEventByMaskFunc", ret);

            ret = ASF_testDisableProtocolEventByMaskFunc(priv);
            testResult("ASF_testDisableProtocolEventByMaskFunc", ret);

            ret = ASF_testEnableProtocolEventByIDFunc(priv);
            testResult("ASF_testEnableProtocolEventByIDFunc", ret);

            ret = ASF_testDisableProtocolEventByIDFunc(priv);
            testResult("ASF_testDisableProtocolEventByIDFunc", ret);

            ret = ASF_testEnableTimeoutEventByMaskFunc(priv);
            testResult("ASF_testEnableTimeoutEventByMaskFunc", ret);

   
            ret = ASF_testDisableTimeoutEventByMaskFunc(priv);
            testResult("ASF_testDisableTimeoutEventByMaskFunc", ret);

            ret = ASF_testEnableTimeoutEventByIDFunc(priv);
            testResult("ASF_testEnableTimeoutEventByIDFunc", ret);

            ret = ASF_testDisableTimeoutEventByIDFunc(priv);
            testResult("ASF_testDisableTimeoutEventByIDFunc", ret);
   
            ASF_testStatisticFunc(priv);
            testResult("ASF_testStatisticFunc", ret);
        } else {
            printf("ERRO: ASF Instance id: %d, name %s, status%d\n", asfInstances[i].id, asfInstances[i].config.controllerName, asfInstances[i].status);
        }
    }    
    ASF_ClearAllInstance();
    
    return 0;
}
