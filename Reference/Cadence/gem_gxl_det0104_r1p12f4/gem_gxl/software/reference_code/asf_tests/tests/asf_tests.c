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
 * tests.c
 * Contains implementation of tests
 *****************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "cdn_errno.h"
#include "asf_if.h"
#include "asf_priv.h"
#include "asf_trace.h"
#include "asf_common.h"
#include "cps.h"


/**
 * Test BIST1
 * Test uses ASF_SelfTest function and is intended to checking whether
 * all emulated event will be reported.
 * @param[in] privateData Driver state info specific to this instance.
 * @return function returns:
 *        EOK on success
 *        ENOTSUP - test failed if one of features are not supported
 *        EINVAL -  test failed - incorrect parameter
 *        EPROTO -  test failed - timeout error detected
*/
uint32_t ASF_testBIST1(ASF_PrivateData *priv) {
    uint32_t ret =0;

    //all fault condition will be generated one by one
    ret  = ASF_SelfTest(priv);
    return ret;
}

/**
 * Test BIST2
 * test uses function ASF_TestEvent to trigger all emulated fault events.
 * @param[in] privateData Driver state info specific to this instance.
 * @return function returns:
 *        EOK on success
 *        EINVAL -  test failed - incorrect parameter
 *        EPROTO -  test failed - timeout error or interrupt is not enabled
 */
uint32_t ASF_testBIST2(ASF_PrivateData *priv) {
    uint32_t ret =0;
    uint32_t i =0;
    ASF_StatInfo stats;

    ASF_EnableAllEvents(priv);

    for(i=0; i <= ASF_INTEGRITY; i++) {
        ret = ASF_CheckIfASFSupported(priv, (ASF_EventErrorType)i);
        if(ret == EOK) {
            ret = ASF_TestEvent(priv, (ASF_EventErrorType)i);

            ret = ASF_GetStatistic(priv, &stats);
            ASF_TraceExtendedStatInfo(&stats);
        }
    }
    ASF_DisableAllEvents(priv);
    return ret;
}

/**
 * TEST: ASF_DisableAllEvents
 * Function tests if DisableAllEvents function work correct.
 * Test disable detection of all events, then starts generating
 * of all event by using ASF_TestEvent function.
 * For each emulated event function should receive timeout error.
 * @param[in] privateData Driver state info specific to this instance.
 * @return function returns:
 *        EOK on success
 *        EINVAL -  test failed
*/
uint32_t ASF_testDisableAllEventsFunc(ASF_PrivateData *priv) {
    uint32_t i = 0;
    uint32_t ret = 0;

    //disable all interrupts
    ASF_DisableAllEvents(priv);

    //checking if all interrupts are disabled
    for(i=0; i <= ASF_INTEGRITY; i++) {
        ret = ASF_CheckIfASFSupported(priv, (ASF_EventErrorType)i);
        //only for supported features
        if(ret == EOK) {
             ret = ASF_TestEvent(priv, (ASF_EventErrorType)i);
             /*interrupt are disabled so we should  get EPROTO error code*/
             if(ret == EPROTO) {
                 continue;
             } else {
                 return EINVAL; //test failed
             }
        }
    }
    return EOK;
}

/**
 * TEST: ASF_EnableAllEvents
 * Function disables detection all events then checks if all events were
 * disabled. In next step enables all events. After enabling events
 * function trigger all events and checks whether they were reported
 * @param[in] privateData Driver state info specific to this instance.
 * @return function returns:
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testEnableAllEventsFunc(ASF_PrivateData *priv) {
    uint32_t i = 0;
    uint32_t ret = 0;

    //disable all interrupts and check if are disabled
    if(ASF_testDisableAllEventsFunc(priv) != EOK)
        return EINVAL; //test failed


    if(ASF_EnableAllEvents(priv) != EOK)
        return EINVAL; //test failed

    //checking if all interrupts are enabled
    for(i=0; i <= ASF_INTEGRITY; i++) {
        ret = ASF_CheckIfASFSupported(priv, (ASF_EventErrorType)i);
        //only for supported features
        if(ret == EOK) {
             ret = ASF_TestEvent(priv, (ASF_EventErrorType)i);
             /*interrupt are disabled so we should  get EPROTO error code*/
             if(ret == EOK) {
                 continue;
             } else {
                 return EINVAL; //test failed
             }
        }
    }
    return EOK;
}

/**
 * TEST ASF_EnableEvent
 * Function tests ASF_EnableEvent function. At the beginning function
 * disables all events. In next step in loop enables single event,
 * trigger enabled event and  checks if correct event was detected.
 * In nested loop function tests if  all disabled events returns EPROTO error code.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testEnableEventFunc(ASF_PrivateData *priv) {
    uint8_t i = 0, j = 0;
    uint32_t ret = 0;

    //disable all interrupts and check if are disabled
    if(ASF_testDisableAllEventsFunc(priv) != EOK)
        return EINVAL; //test failed

    //enable handling all features - one by one
    for(i=0; i <= ASF_INTEGRITY; i++) {
        ret = ASF_CheckIfASFSupported(priv, (ASF_EventErrorType)i);
        //only for supported features
        if(ret == EOK) {
            //enable features
            if(ASF_EnableEvent(priv, (ASF_EventErrorType)i) != EOK)
                return EINVAL; //test failed

            //trigger event
            ret = ASF_TestEvent(priv, (ASF_EventErrorType)i);
            /*tested feature is enabled so function should get EOK code*/
            if(ret != EOK) {
                return EINVAL; //test failed
            }

            //check if all others features are disabled
            for(j=0; j <= ASF_INTEGRITY; j++) {
                if(j == i) {
                    continue;
                }

                ret = ASF_TestEvent(priv, (ASF_EventErrorType)j);
                if(ret != EPROTO) {
                    return EINVAL;  //test failed
                }
            }

            if(ASF_DisableEvent(priv, (ASF_EventErrorType)i) != EOK)
                return EINVAL; //test failed
        }
    }
    return EOK;
}

/**
 * TEST ASF_SetEventAsNonFatal
 * Function tests ASF_SetEventAsNonFatal function for given instance.
 * Function enables and sets all events as fatal. Then one by one set
 * single event as non fatal and trigger events, and checks if generated
 * events are correct.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] instId Instance driver ID
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL - test failed
 */
uint32_t ASF_testSetEventAsNonFatalFunc(ASF_PrivateData *priv, uint8_t instId) {
    uint8_t i = 0, j = 0;
    uint32_t ret = EOK;

    if(instId >= ASF_INSTANCE_NUMBER) {
        return EINVAL;
    }

    if(ASF_EnableAllEvents(priv) != EOK) {
      return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }

    //set one by one faults as fatal, trigger event and check
    // if received event is reported as non fatal.
    for(i =0; i<= ASF_INTEGRITY; i++) {
        //set event type "i" as nonFatal
        ret = ASF_SetEventAsNonFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }

        //trigger all events - only one can be reported as non fatal
        for(j =0; j<= ASF_INTEGRITY; j++) {
            //clear place for holding reported event object
            ASF_clearEventInfoObj(priv);

            //trigger event
            ret = ASF_TestEvent(priv, (ASF_EventErrorType)j);

            if(ret == EOK) {
                ASF_EventInfo *event = &asfInstances[instId].lastReportedEvent;

                if(!asfInstances[instId].eventChanged) {
                    //e.g babble interrupt
                   //return EINVAL; //test failed
                   continue;
                }

                //if expect non Fatal interrupt
                if(i == j) {
                    ret = ASF_checkEventObj(event,
                                       NULL,
                                       NULL,
                                      (ASF_EventErrorType)j,
                                      0);
                   if(ret != EOK)
                       return EINVAL; //test failed
               } else {
                   ret = ASF_checkEventObj(event,
                                       NULL,
                                       NULL,
                                      (ASF_EventErrorType)j,
                                      1);
                   if(ret != EOK)
                       return EINVAL; //test failed
                }

            } else  {
                return EINVAL; //test failed
            }

        }
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);

    }
    return ret;
}

/**
 * TEST ASF_DisableEvent.
 * Function tests ASF_DisableEvent function. At the beginning function
 * enable all events. Then disables one by one only single event and verify
 * if it was disabled.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
 uint32_t ASF_testDisableEventFunc(ASF_PrivateData *priv) {
    uint8_t i = 0, j = 0;
    uint32_t ret = 0;

    if(ASF_testEnableAllEventsFunc(priv) != EOK) {
        return EINVAL; //test failed
    }

   //enable handling all features - one by one
    for(i=0; i <= ASF_INTEGRITY; i++) {
        ret = ASF_CheckIfASFSupported(priv, (ASF_EventErrorType)i);
        //only for supported features
        if(ret == EOK) {
            //enable features
            if(ASF_DisableEvent(priv, (ASF_EventErrorType)i) != EOK)
                return EINVAL; //test failed

            //trigger event
            ret = ASF_TestEvent(priv, (ASF_EventErrorType)i);
            /*tested feature  is disabled so we should  get EPROTO error code*/
            if(ret == EOK) {
                return EINVAL; //test failed
            }

            //check if all others features are enabled
            for(j=0; j <= ASF_INTEGRITY; j++) {
                if(j == i) {
                    continue;
                }

                ret = ASF_TestEvent(priv, (ASF_EventErrorType)j);
                if(ret != EOK) {
                    return EINVAL;  //test failed
               }
            }

            //enable again interrupt
            if(ASF_EnableEvent(priv, (ASF_EventErrorType)i) != EOK)
                return EINVAL; //test failed

        }
    }

return EOK;
}

/**
 * TEST ASF_EnableProtocolEventByMask.
 * Function tests ASF_EnableProtocolEventByMask function.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testEnableProtocolEventByMaskFunc(ASF_PrivateData *priv) {
    uint8_t i = 0;
    uint32_t supported =0;
    uint32_t notSupported =0;
    uint32_t reg =0;
    uint32_t expected=0;
    uint32_t ret = EOK;
    uint32_t flag = 0;
    uint32_t mask = 0;
    if(ASF_EnableAllEvents(priv) != EOK) {
         return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }


    ret = ASF_GetSupportedProtocolErrors(priv, &flag);
    supported = flag;
    notSupported = ~supported;
    if(ret != EOK) {
        return EINVAL;
    }

    /*Disable all interrupts*/
    if(ASF_DisableProtocolEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    /*Incorrect situation - function should return ENOTSUP*/
    if(ASF_EnableProtocolEventByMask(priv, notSupported) != ENOTSUP) {
        return EINVAL;
    }

    /* correct situation, but function should enable only supported events
    */
    if(ASF_EnableProtocolEventByMask(priv, notSupported | supported) != EOK) {
        return EINVAL;
    }


    /** correct situation - enable all supported interrupts */
    if(ASF_EnableProtocolEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    //firmware can't use in this place ASF_TestEvent function so
    // test function checks only if interrupts was enabled
    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);

    expected = ~flag & supported;

    if(reg  != expected) {
        return EINVAL;
    }

    if(ASF_DisableProtocolEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
    if(reg != supported) {
        return EINVAL;
    }

    flag =0;
    for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
        mask = 1 << i;

        flag = flag | mask;
        ret = ASF_EnableProtocolEventByMask(priv, mask);
        if(supported & mask) {
            if(ret != EOK) {
                return EINVAL;
            }
        } else {
            if(ret != ENOTSUP) {
                return EINVAL;
            }
        }
       reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
       expected = ~flag & supported;

       if(reg  != expected) {
           return EINVAL;
       }
    }

    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
    //all interrupts should be enabled
    expected = 0;
    if(reg  != expected) {
        return EINVAL;
    }

    return ret;
}


/**
 * TEST ASF_DisableProtocolEventByMask.
 * Function tests ASF_DisableProtocolEventByMask function.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testDisableProtocolEventByMaskFunc(ASF_PrivateData *priv) {
    uint8_t i = 0;
    uint32_t supported =0;
    uint32_t notSupported =0;
    uint32_t reg =0;
    uint32_t expected=0;
    uint32_t ret = EOK;
    uint32_t flag = 0;
    uint32_t mask = 0;

    if(ASF_EnableAllEvents(priv) != EOK) {
         return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }

    ret = ASF_GetSupportedProtocolErrors(priv, &flag);
    supported = flag;
    notSupported = ~supported;
    if(ret != EOK) {
        return EINVAL;
    }

    /*Enable all interrupts*/
    if(ASF_EnableProtocolEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    /*Incorrect situation - function should return ENOTSUP*/
    if(ASF_DisableProtocolEventByMask(priv, notSupported) != ENOTSUP) {
        return EINVAL;
    }

    /* correct situation, but function should enable only supported events
    */
    if(ASF_DisableProtocolEventByMask(priv, notSupported | supported) != EOK) {
        return EINVAL;
    }


    /** correct situation - enable all supported interrupts */
    if(ASF_DisableProtocolEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    //firmware can't use in this place ASF_TestEvent function so
    // test function checks only if interrupts was enabled
    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);

    expected =  supported;
    if(reg  != expected) {
        return EINVAL;
    }

    if(ASF_EnableProtocolEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
    if(reg != 0) {
        return EINVAL;
    }

    flag =0;
    for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
        mask = 1 << i;

	flag = flag | mask;
        ret = ASF_DisableProtocolEventByMask(priv, mask);
        if(supported & mask) {
            if(ret != EOK) {
                return EINVAL;
            }
        } else {
            if(ret != ENOTSUP) {
                return EINVAL;
            }
        }
       reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
       expected = flag & supported;

       if(reg  != expected) {
           return EINVAL;
       }
    }

    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
    //all interrupts should be disabled
    expected = supported;
    if(reg  != expected) {
        return EINVAL;
    }

    return ret;
}


/**
 * TEST ASF_EnableProtocolEventByIDFunc.
 * Function tests ASF_EnableProtocolEventByIDFunc function.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testEnableProtocolEventByIDFunc(ASF_PrivateData *priv) {
    uint8_t i = 0;
    uint32_t supported =0;
    uint32_t notSupported =0;
    uint32_t reg =0;
    uint32_t expected=0;
    uint32_t ret = EOK;
    uint32_t flag = 0;
    uint32_t mask = 0;
    if(ASF_EnableAllEvents(priv) != EOK) {
         return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }


    ret = ASF_GetSupportedProtocolErrors(priv, &flag);
    supported = flag;
    notSupported = ~supported;
    if(ret != EOK) {
        return EINVAL;
    }

    /*Disable all interrupts*/
    if(ASF_DisableProtocolEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    flag =0;
    for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
        mask = 1 << i;

        flag = flag | mask;
        ret = ASF_EnableProtocolEventByID(priv, i);

        if(supported & mask) {
            if(ret != EOK) {
                return EINVAL;
            }
        } else {
            if(ret != ENOTSUP) {
                return EINVAL;
            }
        }
        reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
        expected = ~flag & supported;

        if(reg  != expected) {
           return EINVAL;
        }
    }

    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
    //all interrupts should be enabled
    expected = 0;
    if(reg  != expected) {
        return EINVAL;
    }

    return ret;
}


/**
 * TEST ASF_DisableProtocolEventByIDFunc.
 * Function tests ASF_DisableProtocolEventByIDFunc function.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testDisableProtocolEventByIDFunc(ASF_PrivateData *priv) {
    uint8_t i = 0;
    uint32_t supported =0;
    uint32_t notSupported =0;
    uint32_t reg =0;
    uint32_t expected=0;
    uint32_t ret = EOK;
    uint32_t flag = 0;
    uint32_t mask = 0;

    if(ASF_EnableAllEvents(priv) != EOK) {
         return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }


    ret = ASF_GetSupportedProtocolErrors(priv, &flag);
    supported = flag;
    notSupported = ~supported;
    if(ret != EOK) {
        return EINVAL;
    }

    /*Enable all interrupts*/
    if(ASF_EnableProtocolEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }


    flag =0;
    for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
        mask = 1 << i;

	flag = flag | mask;
        ret = ASF_DisableProtocolEventByID(priv, i);
        if(supported & mask) {
            if(ret != EOK) {
                return EINVAL;
            }
        } else {
            if(ret != ENOTSUP) {
                return EINVAL;
            }
        }
       reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
       expected = flag & supported;
       if(reg  != expected) {
           return EINVAL;
       }
    }

    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);
    //all interrupts should be disabled
    expected = supported;
    if(reg  != expected) {
        return EINVAL;
    }

    return ret;
}

/**
 * TEST ASF_EnableTimoutEventByMask.
 * Function tests ASF_EnableTimeoutEventByMask function.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testEnableTimeoutEventByMaskFunc(ASF_PrivateData *priv) {
    uint8_t i = 0;
    uint32_t supported =0;
    uint32_t notSupported =0;
    uint32_t reg =0;
    uint32_t expected=0;
    uint32_t ret = EOK;
    uint32_t flag = 0;
    uint32_t mask = 0;

    if(ASF_EnableAllEvents(priv) != EOK) {
         return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }

    ret = ASF_GetSupportedTimeoutErrors(priv, &flag);
    supported = flag;
    notSupported = ~supported;
    if(ret != EOK) {
        return EINVAL;
    }

    /*Disable all interrupts*/
    if(ASF_DisableTimeoutEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    /*Incorrect situation - function should return ENOTSUP*/
    if(ASF_EnableTimeoutEventByMask(priv, notSupported) != ENOTSUP) {
        return EINVAL;
    }

    /* correct situation, but function should enable only supported events
    */
    if(ASF_EnableTimeoutEventByMask(priv, notSupported | supported) != EOK) {
        return EINVAL;
    }


    /** correct situation - enable all supported interrupts */
    if(ASF_EnableTimeoutEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    //firmware can't use in this place ASF_TestEvent function so
    // test function checks only if interrupts was enabled
    reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);

    expected = ~flag & supported;

    if(reg  != expected) {
        return EINVAL;
    }

    if(ASF_DisableTimeoutEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
    if(reg != supported) {
        return EINVAL;
    }

    flag =0;
    for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
        mask = 1 << i;

        flag = flag | mask;
        ret = ASF_EnableTimeoutEventByMask(priv, mask);
        if(supported & mask) {
            if(ret != EOK) {
                return EINVAL;
            }
        } else {
            if(ret != ENOTSUP) {
                return EINVAL;
            }
        }
       reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
       expected = ~flag & supported;

       if(reg  != expected) {
           return EINVAL;
       }
    }

    reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
    //all interrupts should be enabled
    expected = 0;
    if(reg  != expected) {
        return EINVAL;
    }

    return ret;
}

/**
 * TEST ASF_DisableTimoutEventByMask.
 * Function tests ASF_DisableTimeoutEventByMask function.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testDisableTimeoutEventByMaskFunc(ASF_PrivateData *priv) {
    uint8_t i = 0;
    uint32_t supported =0;
    uint32_t notSupported =0;
    uint32_t reg =0;
    uint32_t expected=0;
    uint32_t ret = EOK;
    uint32_t flag = 0;
    uint32_t mask = 0;

    if(ASF_EnableAllEvents(priv) != EOK) {
         return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }

    ret = ASF_GetSupportedTimeoutErrors(priv, &flag);
    supported = flag;
    notSupported = ~supported;
    if(ret != EOK) {
        return EINVAL;
    }

    /*Enable all interrupts*/
    if(ASF_EnableTimeoutEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    /*Incorrect situation - function should return ENOTSUP*/
    if(ASF_DisableTimeoutEventByMask(priv, notSupported) != ENOTSUP) {
        return EINVAL;
    }

    /* correct situation, but function should enable only supported events
    */
    if(ASF_DisableTimeoutEventByMask(priv, notSupported | supported) != EOK) {
        return EINVAL;
    }


    /** correct situation - enable all supported interrupts */
    if(ASF_DisableTimeoutEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    //firmware can't use in this place ASF_TestEvent function so
    // test function checks only if interrupts was enabled
    reg = CPS_UncachedRead32(&priv->regs->protocol_fault_mask);

    expected =  supported;
    if(reg  != expected) {
        return EINVAL;
    }

    if(ASF_EnableTimeoutEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
    if(reg != 0) {
        return EINVAL;
    }

    flag =0;
    for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
        mask = 1 << i;

	flag = flag | mask;
        ret = ASF_DisableTimeoutEventByMask(priv, mask);
        if(supported & mask) {
            if(ret != EOK) {
                return EINVAL;
            }
        } else {
            if(ret != ENOTSUP) {
                return EINVAL;
            }
        }
       reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
       expected = flag & supported;

       if(reg  != expected) {
           return EINVAL;
       }
    }

    reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
    //all interrupts should be disabled
    expected = supported;
    if(reg  != expected) {
        return EINVAL;
    }

    return ret;
}

/**
 * TEST ASF_EnableTimoutEventByID.
 * Function tests ASF_EnableTimeoutEventByID function.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testEnableTimeoutEventByIDFunc(ASF_PrivateData *priv) {
    uint8_t i = 0;
    uint32_t supported =0;
    uint32_t notSupported =0;
    uint32_t reg =0;
    uint32_t expected=0;
    uint32_t ret = EOK;
    uint32_t flag = 0;
    uint32_t mask = 0;
    if(ASF_EnableAllEvents(priv) != EOK) {
         return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }


    ret = ASF_GetSupportedTimeoutErrors(priv, &flag);
    supported = flag;
    notSupported = ~supported;
    if(ret != EOK) {
        return EINVAL;
    }

    /*Disable all interrupts*/
    if(ASF_DisableTimeoutEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }

    flag =0;
    for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
        mask = 1 << i;

        flag = flag | mask;
        ret = ASF_EnableTimeoutEventByID(priv, i);

        if(supported & mask) {
            if(ret != EOK) {
                return EINVAL;
            }
        } else {
            if(ret != ENOTSUP) {
                return EINVAL;
            }
        }
        reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
        expected = ~flag & supported;

        if(reg  != expected) {
           return EINVAL;
        }
    }

    reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
    //all interrupts should be enabled
    expected = 0;
    if(reg  != expected) {
        return EINVAL;
    }

    return ret;
}

/**
 * TEST ASF_DisableTimoutEventByID.
 * Function tests ASF_DisableTimeoutEventByID function.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testDisableTimeoutEventByIDFunc(ASF_PrivateData *priv) {
    uint8_t i = 0;
    uint32_t supported =0;
    uint32_t notSupported =0;
    uint32_t reg =0;
    uint32_t expected=0;
    uint32_t ret = EOK;
    uint32_t flag = 0;
    uint32_t mask = 0;

    if(ASF_EnableAllEvents(priv) != EOK) {
         return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }


    ret = ASF_GetSupportedTimeoutErrors(priv, &flag);
    supported = flag;
    notSupported = ~supported;
    if(ret != EOK) {
        return EINVAL;
    }

    /*Enable all interrupts*/
    if(ASF_EnableTimeoutEventByMask(priv, supported) != EOK) {
        return EINVAL;
    }


    flag =0;
    for(i=0; i < ASF_MAX_NUMBER_EXTENDED_EVENTS; i++) {
        mask = 1 << i;

	flag = flag | mask;
        ret = ASF_DisableTimeoutEventByID(priv, i);
        if(supported & mask) {
            if(ret != EOK) {
                return EINVAL;
            }
        } else {
            if(ret != ENOTSUP) {
                return EINVAL;
            }
        }
       reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
       expected = flag & supported;

       if(reg  != expected) {
           return EINVAL;
       }
    }

    reg = CPS_UncachedRead32(&priv->regs->trans_to_fault_mask);
    //all interrupts should be disabled
    expected = supported;
    if(reg  != expected) {
        return EINVAL;
    }

    return ret;
}


/**
 * Function generate event and update statsExpected object.
 * @param[in] priv Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 * @param[in/out] statsExpected object holding expected results of test.
 * @param[in] numOfEvent triggered event.
 *
 */
static uint32_t generateStatsEvents(ASF_PrivateData *priv, ASF_StatInfo *statsExpected, uint32_t numeOfEvent) {
     uint32_t ret =0;
     uint32_t i =0;
     uint32_t eventType =0;

     for(i=0; i <= numeOfEvent; i++) {
        /*generate number from 0 to ASF_INTEGRITY*/
         eventType  = (ASF_EventErrorType)(rand() % (ASF_INTEGRITY));

        ret = ASF_CheckIfASFSupported(priv, (ASF_EventErrorType)eventType);
        //only for supported features
        if(ret == EOK) {
            //trigger event
            ret = ASF_TestEvent(priv, (ASF_EventErrorType)i);
            /*tested feature is enabled so function should get EOK code*/
            if(ret != EOK) {
                return EINVAL; //test failed
            }

            switch(eventType) {
                case ASF_SRAM_CORRECTABLE:
                    statsExpected->sramCorrectableErrCounter++;
                break;
                case ASF_SRAM_UNCORRECTABLE:
                    statsExpected->sramUncorrectableErrCounter++;
                break;
                case ASF_DATA_PARITY:
                    statsExpected->dataAdressParityErrCounter++;
                break;
                case ASF_CONFIGURATION:
                    statsExpected->configStatusErrCounter++;
                break;
                /** this event cannot be used in this test becaouse
                 *  emulated interrupt doesn't update other registers
                 *  related to  for this fault conditions
                */
                case ASF_TRANSACTION_TIMEOUT:
                case ASF_PROTOCOL:
                    continue;
                case ASF_INTEGRITY:
                     statsExpected->integrityErrCounter++;
                break;
                default:
                    return EINVAL;
           }

        }
    }

    return EOK;

}

/**
 * TEST ASF_Statistic.
 * Function tests ASF_ClearStatistic, ASF_RestoreStatistic
 * and ASF_GetStatistic functions.
 * @param[in] privateData Driver state info specific to this instance.
 *        EOK on success
 *        EINVAL -  test failed
 */
uint32_t ASF_testStatisticFunc(ASF_PrivateData *priv) {
    ASF_StatInfo statsExpected;
    ASF_StatInfo statsCurrent;
    uint32_t supportedProtocols = 0;
    uint32_t supportedTimeouts= 0;
    uint32_t numOfIteration = 100;
    time_t t;
    uint32_t ret =0;
    uint8_t i =0;

    /*Initializes random number generator*/
    srand((unsigned) time(&t));


    if(ASF_EnableAllEvents(priv) != EOK) {
      return EINVAL;
    }

    for(i =0; i<= ASF_INTEGRITY; i++) {
        ret = ASF_SetEventAsFatal(priv, (ASF_EventErrorType)i);
        if(ret != EOK) {
            return EINVAL;
        }
    }

    ret = ASF_GetSupportedProtocolErrors(priv, &supportedProtocols);
    if(ret != EOK) {
        return EINVAL;
    }

    ret = ASF_GetSupportedProtocolErrors(priv, &supportedTimeouts);
    if(ret != EOK) {
        return EINVAL;
    }

    /*Disable all interrupts*/
    if(ASF_EnableProtocolEventByMask(priv, supportedProtocols) != EOK) {
        return EINVAL;
    }

    /*Disable all interrupts*/
    if(ASF_EnableTimeoutEventByMask(priv, supportedTimeouts) != EOK) {
        return EINVAL;
    }

    memset(&statsExpected, 0, sizeof(statsExpected));


    strcpy((char*)statsExpected.name, (char*)priv->controllerName);
    strcpy((char*)statsExpected.version, (char*)priv->controllerVersion);

    ASF_GetStatistic(priv, &statsExpected);

    /**clear stat object except name and version fields*/
    if(ASF_ClearStatistic(priv)!= EOK) {
        return EINVAL;
    }

    ret = generateStatsEvents(priv, &statsExpected, numOfIteration);
    if(ret != EOK)
        return EINVAL;

    ASF_GetStatistic(priv, &statsCurrent);
    if(ASF_CompareStatisticObj(&statsExpected, &statsCurrent) != EOK) {
        return EINVAL;
    }

    //clear internal statistic object
    ASF_ClearStatistic(priv);

    //restore statistic object
    ASF_RestoreStatistic(priv, &statsExpected);

    //generate new events
    ret = generateStatsEvents(priv, &statsExpected, numOfIteration);

    //get updated statistic object
    ASF_GetStatistic(priv, &statsCurrent);

    //compare again
    if(ASF_CompareStatisticObj(&statsExpected, &statsCurrent) != EOK) {
        return EINVAL;
    }

    return EOK;

}

