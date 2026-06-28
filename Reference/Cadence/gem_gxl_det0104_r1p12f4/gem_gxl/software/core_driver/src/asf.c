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
 * asf.c
 * ASF Core Driver implementation file.
 *****************************************************************************/
#include "cdn_stdtypes.h"
#include "cdn_errno.h"

#include "log.h"
#include "cps.h"

#include "asf_priv.h"

#define ZERO (uint32_t)0u

#define ASF_TEST_TIMEOUT (uint32_t)50000000
#define ASF_MAX_PROT_TO_EVENTS (uint32_t)32u
#define ASF_SECURITY_TAG (uint32_t)0x01234567


/**
 * Sets the ASF interrupts.
 * @param[in] privateData Driver state info specific to this instance.
 *
 */
static void asfSettingInterrupts(const ASF_PrivateData* privateData) {
    CPS_UncachedWrite32(&privateData->regs->int_mask, privateData->int_mask);
    CPS_UncachedWrite32(&privateData->regs->protocol_fault_mask, privateData->protocols_mask);
    CPS_UncachedWrite32(&privateData->regs->trans_to_fault_mask, privateData->timeouts_mask);
    return;
}

/**
 * Checks if indicated by parameter mask event are set as fatal or non fatal.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] mask indicated selected event.
 * @return EOK if events are set as Fatal else EINVAL.
 *
 * Only one bit should be set in mask during single calling this function.
 */
inline static uint8_t asfCheckIfFatal(ASF_PrivateData* privateData, uint32_t mask) {
    uint8_t result = EOK;

    uint32_t regs = CPS_UncachedRead32(&privateData->regs->fatal_nonfatal_select);

    if((regs & mask) != ZERO) {
        result = EINVAL;
    }
    return result;
}


/**
 *  Handles SRAM Correctable fault condition detected by ASF controller
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 *
 * If sramCorrectableEvent callback has been set then function report this
 * fault to upper layer (user application).
 */
inline static void asfIrqSramCorrectable(ASF_PrivateData* privateData){
    uint32_t temp;
    ASF_EventInfo *eventInfo = &privateData->eventInfo;
    ASF_StatInfo *statistic = &privateData->statistic;

    /** Ffilling eventInfo object,*/
    eventInfo->eventErrorCode = ASF_SRAM_CORRECTABLE;
    eventInfo->fatalEvent = asfCheckIfFatal(privateData, ASF_SRAM_CORR_MASK);

    temp = CPS_UncachedRead32(&privateData->regs->sram_fault_status);
    eventInfo->sramInfo.uncorrectableErroCounter = (uint16_t)(temp >> ASF_SRAM_F_UNCORR_STATS_OFFSET);
    eventInfo->sramInfo.correctableErrorCounter = (uint16_t)(temp & ASF_SRAM_F_CORR_STATS_MASK);
    eventInfo->sramInfo.sramUncorrectableError = 0;

    temp = CPS_UncachedRead32(&privateData->regs->sram_uncorr_fault_status);

    eventInfo->sramInfo.sramFaultInfo.sramAddress = temp & ASF_SRAM_F_CORR_STATS_MASK;
    eventInfo->sramInfo.sramFaultInfo.sramInstanceId =
        (uint8_t)((temp & ASF_SRAM_F_INST_MASK) >> ASF_SRAM_F_INST_OFFSET);

    /** Cclearing interrupt.*/
    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_SRAM_CORR_MASK);

    /** Update statistic data.*/
    temp = statistic->sramCorrectableErrCounter % ASF_LAST_SRAM_ERROR_ARRAY_SIZE;
    statistic->lastSramCorrectableErr[temp].sramAddress =
            eventInfo->sramInfo.sramFaultInfo.sramAddress;
    statistic->lastSramCorrectableErr[temp].sramInstanceId =
            eventInfo->sramInfo.sramFaultInfo.sramInstanceId;

    statistic->sramCorrectableErrCounter++;

    /** Callback to user layer.*/
    if(privateData->callbacks.sramCorrectableEvent != NULL) {
      privateData->callbacks.sramCorrectableEvent(privateData, eventInfo);
    }
}

/**
 * Handles SRAM Uncorrectable fault condition detected by ASF controller
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 *
 * If sramUncorrectableEvent callback has been set then function report this
 * fault to upper layer (user application).
 */
inline static void asfIrqSramUncorrectable(ASF_PrivateData* privateData){
    uint32_t temp;
    ASF_EventInfo *eventInfo = &privateData->eventInfo;
    ASF_StatInfo *statistic = &privateData->statistic;

    /** Filling eventInfo object.*/
    eventInfo->eventErrorCode = ASF_SRAM_UNCORRECTABLE;
    eventInfo->fatalEvent =
            asfCheckIfFatal(privateData, ASF_SRAM_UNCORR_MASK);

    temp = CPS_UncachedRead32(&privateData->regs->sram_fault_status);

    eventInfo->sramInfo.uncorrectableErroCounter = (uint16_t)(temp >> ASF_SRAM_F_UNCORR_STATS_OFFSET);
    eventInfo->sramInfo.correctableErrorCounter = (uint16_t)(temp & ASF_SRAM_F_CORR_STATS_MASK);

    eventInfo->sramInfo.sramUncorrectableError = (uint8_t)1;

    temp = CPS_UncachedRead32(&privateData->regs->sram_corr_fault_status);

    eventInfo->sramInfo.sramFaultInfo.sramAddress = temp & ASF_SRAM_F_CORR_STATS_MASK;
    eventInfo->sramInfo.sramFaultInfo.sramInstanceId =
            (uint8_t)((temp & ASF_SRAM_F_INST_MASK) >> ASF_SRAM_F_INST_OFFSET);

    /** Clearing interrupt.*/
    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_SRAM_UNCORR_MASK);

    /** Update statistic data.*/
    temp = statistic->sramUncorrectableErrCounter % ASF_LAST_SRAM_ERROR_ARRAY_SIZE;
    statistic->lastSramUncorrectableErr[temp].sramAddress =
            eventInfo->sramInfo.sramFaultInfo.sramAddress;
    statistic->lastSramUncorrectableErr[temp].sramInstanceId =
            eventInfo->sramInfo.sramFaultInfo.sramInstanceId;

    statistic->sramUncorrectableErrCounter++;

    /** Callback to user layer.*/
    if(privateData->callbacks.sramUncorrectableEvent != NULL) {
        privateData->callbacks.sramUncorrectableEvent(privateData, eventInfo);
    }
}


/**
 * Handles Data and Address Parity fault condition detected by ASF controller
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 *
 * If dataAddressParityEvent callback has been set then function report this
 * fault to upper layer (user application).
 */
inline static void asfIrqDAP(ASF_PrivateData* privateData) {
    ASF_EventInfo * eventInfo = &privateData->eventInfo;
    /** Filling eventInfo object.*/
    eventInfo->eventErrorCode = ASF_DATA_PARITY;
    eventInfo->fatalEvent =
            asfCheckIfFatal(privateData, ASF_DAP_MASK);

    /** Clearing interrupt.*/
    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_DAP_MASK);

    /** Update statistic data.*/
    privateData->statistic.dataAdressParityErrCounter++;

    /** Callback to user layer.*/
    if(privateData->callbacks.dataAdressParityEvent != NULL) {
        privateData->callbacks.dataAdressParityEvent(privateData, eventInfo);
    }
}

/**
 * Handles Configuration and Status Registers fault condition detected by ASF controller
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 *
 * If configStatusRegisterEvent callback has been set then function report this
 * fault to upper layer (user application).
 */
inline static void asfIrqCSR(ASF_PrivateData* privateData) {
    ASF_EventInfo * eventInfo = &privateData->eventInfo;

    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_CSR_MASK);
    eventInfo->eventErrorCode = ASF_CONFIGURATION;
    eventInfo->fatalEvent = asfCheckIfFatal(privateData, ASF_CSR_MASK);

    /** Clearing interrupt*/
    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_CSR_MASK);

    /** Update statistic data*/
    privateData->statistic.configStatusErrCounter++;

    /** Callback to user layer*/
    if(privateData->callbacks.configStatusRegiseterEvent != NULL) {
        privateData->callbacks.configStatusRegiseterEvent(privateData, eventInfo);
    }
}

/**
 * Handles Transaction  timeouts errors  detected by ASF controller
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 *
 * If transactionTimeoutEvent callback has been set then function report this
 * fault to upper layer (user application).
 */
inline static void asfIrqTransTimeout(ASF_PrivateData* privateData) {
    ASF_StatInfo *statistic = &privateData->statistic;
    ASF_EventInfo * eventInfo = &privateData->eventInfo;
    uint32_t regs = 0;
    uint8_t i = 0;

    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_TRANS_TO_MASK);
    eventInfo->eventErrorCode = ASF_TRANSACTION_TIMEOUT;
    eventInfo->fatalEvent = asfCheckIfFatal(privateData, ASF_TRANS_TO_MASK);

    regs = CPS_UncachedRead32(&privateData->regs->trans_to_fault_status);
    regs = regs & privateData->timeouts_mask;

    for(i = 0; i < ASF_MAX_PROT_TO_EVENTS; i++ ) {
        uint32_t mask;

        mask = (uint32_t)1 << i;

        if((regs & mask) != ZERO) {
            eventInfo->extendedErrorIdx = i;

            /** Clearing interrupt*/
            CPS_UncachedWrite32(&privateData->regs->trans_to_fault_status,
                    mask);

            /** Update statistic data*/
            statistic->timeoutErrCounter[i]++;
            statistic->allTimeoutErrCounter++;

             /** Callback to user layer*/
            if(privateData->callbacks.transactionTimeoutEvent != NULL) {
                privateData->callbacks.transactionTimeoutEvent(privateData, eventInfo);
            }
        }
    }

    /** Clearing interrupt*/
    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_TRANS_TO_MASK);
}

/**
 * Handles Protocols errors  detected by ASF controller
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 *
 * If protocolEvent callback has been set then function report this
 * fault to upper layer (user application).
 */
inline static void asfIrqProtocol(ASF_PrivateData* privateData) {
    ASF_StatInfo *statistic = &privateData->statistic;
    ASF_EventInfo * eventInfo = &privateData->eventInfo;
    uint32_t regs = 0;
    uint8_t i = 0;

    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_PROTOCOL_MASK);
    eventInfo->eventErrorCode = ASF_PROTOCOL;
    eventInfo->fatalEvent = asfCheckIfFatal(privateData, ASF_PROTOCOL_MASK);

    regs = CPS_UncachedRead32(&privateData->regs->protocol_fault_status);
    regs = regs & privateData->protocols_mask;

    for(i = 0; i < ASF_MAX_PROT_TO_EVENTS; i++ ) {
        uint32_t mask;

        mask = (uint32_t)1 << i;
        /** Default state indicates that no protocol errors were detected.
         *  Babble error detected or all protocol interrupt are disabled.
         */
        if((regs & mask) != ZERO) {
            eventInfo->extendedErrorIdx = (uint8_t)i;

            /** Clearing interrupt.*/
            CPS_UncachedWrite32(&privateData->regs->protocol_fault_status,
                    mask);

            /** Update statistic data.*/
            statistic->protocolErrCounter[i]++;
            statistic->allProtocolErrCounter++;

            /** Callback to user layer.*/
            if(privateData->callbacks.protocolEvent != NULL) {
                privateData->callbacks.protocolEvent(privateData, eventInfo);
            }
        }
    }

    /** Clearing interrupt.*/
    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_PROTOCOL_MASK);
}


/**
 * Handles Integrity errors detected by ASF controller
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 *
 * If integrityEvent callback has been set then function report this
 * fault to upper layer (user application).
 */
inline static void asfIrqIntegrity(ASF_PrivateData* privateData) {
    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_INTEGRITY_MASK);
     ASF_EventInfo * eventInfo = &privateData->eventInfo;

    eventInfo->eventErrorCode = ASF_INTEGRITY;
    eventInfo->fatalEvent = asfCheckIfFatal(privateData, ASF_INTEGRITY_MASK);

    /** Clearing interrupt*/
    CPS_UncachedWrite32(&privateData->regs->int_status, ASF_INTEGRITY_MASK);

    /** Update statistic data*/
    privateData->statistic.integrityErrCounter++;

    /** Callback to user layer*/
    if(privateData->callbacks.integrityEvent != NULL) {
        privateData->callbacks.integrityEvent(privateData, eventInfo);
    }
}

/**
 * Zeroed bytes array.
 * @param[in] dest zeroed array.
 * @param[in] size array size.
 */
static void asf_memclear(uint8_t* dest, size_t size) {
    size_t i = 0;

    for(i = 0; i < size; i++) {
        dest[i] = 0x0;
    }
}

/**
 * Copy szie bytes from src to dest.
 * @param[in] dest destination array.
 * @param[in] src source array.
 * @param[in] size number of bytes to be copied.
 */
static void asf_strncpy(uint8_t* dest, const uint8_t* src, uint32_t size) {
    uint8_t i = 0;

    for(i = 0; i < size; i++) {

        dest[i] = src[i];
    }
}

uint32_t ASF_Probe(const ASF_Config* config, ASF_SysReq* sysReq) {
    uint32_t result = 0;

    /** Verify input parameters*/
    if((config == NULL) || (sysReq == NULL)) {
        result = EINVAL;
    } else {
        /** Size of ASF_PrivateData structure. This field inform
         *  upper layer how many memory should be prepared for
         *  driver.
         */
        sysReq->privDataSize = (uint32_t)sizeof(ASF_PrivateData);
    }

    return result;
}


/**
 * Function detects features supported by ASF controller.
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 */
static void detectSupportedFeatures(ASF_PrivateData *privateData) {
    uint8_t  i = 0;
    ASF_Regs* regs  = privateData->regs;

    /** Getting information about supported ASF features. */
    CPS_UncachedWrite32(&regs->int_mask, ASF_INT_MASK);
    privateData->supportedFeatures = CPS_UncachedRead32(&regs->int_mask);

    /** Getting information about supported protocol fault events.*/
    CPS_UncachedWrite32(&regs->protocol_fault_mask, ASF_TO_PROTOCOL_MASK);
    privateData->supportedProtocols = CPS_UncachedRead32(&regs->protocol_fault_mask);

    /** Getting information about supported timeout fault events.*/
    CPS_UncachedWrite32(&regs->trans_to_fault_mask, ASF_TO_PROTOCOL_MASK);
    privateData->supportedTimeouts = CPS_UncachedRead32(&regs->trans_to_fault_mask);


    /** Count the number of supported Protocols and Timeouts events.*/
    for(i = 0; i < ASF_MAX_PROT_TO_EVENTS; i++) {
        uint32_t mask = (uint32_t)1 << i;
        if((privateData->supportedProtocols & mask) != ZERO) {
            privateData->protocolErrCount++;
        }
        if((privateData->supportedTimeouts & mask) != ZERO) {
                privateData->timeoutErrCount++;
        }
    }
}

static void statisticInit(const ASF_PrivateData* privateData, ASF_StatInfo* statInfo) {

    /** Clear statistic object.*/
    asf_memclear((uint8_t*)statInfo, sizeof(*statInfo));

    /** Initialize statistic object.*/
    asf_strncpy(statInfo->name,
            privateData->controllerName,
            ASF_CONTROLLER_NAME_LEN);
    asf_strncpy(statInfo->version,
            privateData->controllerVersion,
            ASF_CONTROLLER_VERSION_LEN);
}


static void eventInfoInit(const ASF_PrivateData* privateData, ASF_EventInfo* eventInfo) {

    /** Clear event information  object.*/
    asf_memclear((uint8_t*)eventInfo, sizeof(*eventInfo));

    /** Initialize eventInfo object.*/
    asf_strncpy(eventInfo->name,
            privateData->controllerName,
            ASF_CONTROLLER_NAME_LEN);
    asf_strncpy(eventInfo->version,
            privateData->controllerVersion,
            ASF_CONTROLLER_VERSION_LEN);

}

uint32_t ASF_Init(ASF_PrivateData* privateData, const ASF_Config* config,
        const ASF_Callbacks* callbacks) {
    uint32_t result = EOK;

    /** check correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (config == NULL)
        || (callbacks == NULL) || (config->regBase == NULL)) {
        result = EINVAL;
    } else {

        privateData->regs = config->regBase;

        /**Copy name and version to private data object.*/
        asf_strncpy(privateData->controllerName,
                config->controllerName,
                ASF_CONTROLLER_NAME_LEN);
        asf_strncpy(privateData->controllerVersion,
                config->controllerVersion,
                ASF_CONTROLLER_VERSION_LEN);

        privateData->tagSecurity = ASF_SECURITY_TAG;
        privateData->callbacks = *callbacks;

        /** Initialize statistic and eventInfo object.*/
        statisticInit(privateData, &privateData->statistic);
        eventInfoInit(privateData, &privateData->eventInfo);

        detectSupportedFeatures(privateData);

        privateData->state = ASF_INITIALISED;

        /** Initialize internal information related to enabled/disabled
         *  interrupts.
         */
        privateData->int_mask = ASF_INT_MASK;
        privateData->protocols_mask = privateData->supportedProtocols;
        privateData->timeouts_mask  = privateData->supportedTimeouts;
    }

    return result;
}


/**
 *  Function stops driver.
 * @param[in] privateData Driver state info specific to this instance.
 * @return void
 *
 * Function Disable all interrupts and set state of driver to ASF_STOPPED.
 */
static void stop(ASF_PrivateData* privateData) {
    privateData->state = ASF_STOPPED;
    CPS_UncachedWrite32(&privateData->regs->int_mask, ASF_INT_MASK);
    CPS_UncachedWrite32(&privateData->regs->protocol_fault_mask, privateData->supportedProtocols);
    CPS_UncachedWrite32(&privateData->regs->trans_to_fault_mask, privateData->supportedTimeouts);
}


void ASF_Stop(ASF_PrivateData* privateData) {

    if((privateData != NULL) && (privateData->tagSecurity == ASF_SECURITY_TAG)) {
        /** Only started driver can be stopped. */
        if(privateData->state == ASF_STARTED) {
           /** Call internal stop function  to disable all interrupts.*/
           stop(privateData);
        }
    }
    return;
}

void ASF_Destroy(ASF_PrivateData* privateData) {

    if((privateData != NULL) && (privateData->tagSecurity == ASF_SECURITY_TAG)) {
        if(privateData->state == ASF_STARTED) {
            /** Stops driver.*/
            stop(privateData);
            /** After this statement ASF will require calling Init() function.*/
            privateData->state = ASF_DESTROYED;
            /* Object has been destroyed and have to be initialized again before use.*/
            privateData->tagSecurity = 0;
        }
    }

    return;
}

void ASF_Start(ASF_PrivateData* privateData) {

    if((privateData != NULL) &&  (privateData->tagSecurity == ASF_SECURITY_TAG)) {
        ASF_States state = privateData->state;
        /** Driver can be started only when previously was initialized or stopped. */
        if((state == ASF_INITIALISED) || (state == ASF_STOPPED)) {
            privateData->state = ASF_STARTED;
            /**Enables early selected interrupts.*/
            asfSettingInterrupts(privateData);
        }
    }
    return;
}

static void analizeInterrupt(ASF_PrivateData* privateData, uint32_t interruptMask) {

    /** If detected SRAM Correctable error.*/
    if((interruptMask & ASF_SRAM_CORR_MASK) != ZERO) {
        asfIrqSramCorrectable(privateData);
    }

    /** If detected SRAM Uncorrectable error.*/
    if((interruptMask & ASF_SRAM_UNCORR_MASK) != ZERO) {
        asfIrqSramUncorrectable(privateData);
    }

    /** If detected data and address parity errors. */
    if((interruptMask & ASF_DAP_MASK) != ZERO) {
        asfIrqDAP(privateData);
    }

    /** If detected configuration and status registers error.*/
    if((interruptMask & ASF_CSR_MASK) != ZERO) {
        asfIrqCSR(privateData);
    }

    /** If detected transaction timeout error.*/
    if((interruptMask & ASF_TRANS_TO_MASK) != ZERO) {
        asfIrqTransTimeout(privateData);
    }

    /** If detected protocol error.*/
    if((interruptMask & ASF_PROTOCOL_MASK) != ZERO) {
        asfIrqProtocol(privateData);
    }

    /** If detected Integrity error.*/
    if((interruptMask & ASF_INTEGRITY_MASK) != ZERO) {
        asfIrqIntegrity(privateData);
    }
}

void ASF_Isr(ASF_PrivateData* privateData)  {

    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        /** Do nothing. */
    } else if (privateData->state < ASF_STARTED) {
        /** Do nothing. */
    } else {
        /** int_status register contain reported faults.*/
        uint32_t regs = CPS_UncachedRead32(&privateData->regs->int_status);

        if((regs & ASF_INT_MASK) != ZERO ) {
            analizeInterrupt(privateData, regs);

            /** Finish test mode.*/
            if(privateData->state == ASF_TEST_MODE_STARTED) {
                privateData->state = ASF_TEST_MODE_COMPLETED;
            }
        }
    }
    return;
}

/**
 *  Checks if selected features is supported by ASF controller
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] asfFeature ASF Features for checking
 * @return EOK on success else
 *        EINVAL for incorrect parameter
 *        ENOTSUP if feature is not supported
 */
static uint32_t checkIfASFSupported(const ASF_PrivateData* privateData,
        ASF_EventErrorType asfFeature) {
    uint32_t result = EOK;
    bool supportedFeatures = false;

    if((uint32_t)asfFeature <= (uint32_t)ASF_INTEGRITY) {
        /** Verify if selected feature is supported by ASF Controller.*/
        supportedFeatures = (privateData->supportedFeatures
            & ((uint32_t)1u << (uint32_t)asfFeature)) != ZERO;

        /** If feature is not supported then function returns ENOTSUP.*/
        if(supportedFeatures == false) {
            result = ENOTSUP;
        }
    } else {
        /** If one of passed to function parameters are invalid then function
         * returns EINVAL.
         */
        result = EINVAL;
    }

    return result;
}

uint32_t ASF_CheckIfASFSupported(const ASF_PrivateData* privateData,
        ASF_EventErrorType asfFeature) {
    uint32_t result = EOK;

    /** Check correctness of parameters. If at least one of given parameter
     * are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG) ) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Calls internal function for checking supported features.*/
        result = checkIfASFSupported(privateData, asfFeature);
    }

    return result;
}

uint32_t ASF_GetSupportedASF(const ASF_PrivateData* privateData, uint32_t* asf_flag) {
    uint32_t result = 0;

    /** Check correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Supported by ASF controller features are detected in ASF_Init function
         *  and is stored in suppportedFeatures field.
         */
        *asf_flag = privateData->supportedFeatures;
    }

    return result;
}

uint32_t ASF_GetSupportedTimeoutErrors(const ASF_PrivateData* privateData, uint32_t* flag) {
    uint32_t result = 0;

    /** Check correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Supported by ASF controller timeouts errors  are detected in ASF_Init function
         *  and is stored in supportedTimeouts field.
         */
        *flag = privateData->supportedTimeouts;
    }

    return result;
}

uint32_t ASF_GetSupportedProtocolErrors(const ASF_PrivateData* privateData, uint32_t* flag)  {
    uint32_t result = 0;

    /** Check correctness of parameters. If at least one of given parameter
     * are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Supported by ASF controller protocol errors  are detected in ASF_Init function
         *  and is stored in supportedProtocols field.
         */
        *flag = privateData->supportedProtocols;
    }

    return result;
}

/**
 * Run individual hardware test.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] eventType
 * @param[in] enable -indicates whether function has enable interrupt or not.
 *
 * If enable parameter is different then zero then function as additionally enable
 * interrupt in int_mask register. If enable is set to 0 then before
 * calling this function interrupt should be enabled. If not then function
 * returns EPROTO error.
 */
static uint32_t priv_asfTestEvent(ASF_PrivateData* privateData,
                                  ASF_EventErrorType eventType,
                                  uint8_t enable) {
    uint32_t result = EPROTO;
    uint32_t mask = 0 ;
    register uint32_t delay = ASF_TEST_TIMEOUT;

    if((uint32_t)eventType <= (uint32_t)ASF_INTEGRITY) {
        mask  = (uint32_t)1 << (uint32_t)eventType;

        privateData->state = ASF_TEST_MODE_STARTED;

        if(enable != ZERO) {
            /** Enable all features.*/
            CPS_UncachedWrite32(&privateData->regs->int_mask, 0x0);
        }

        if((CPS_UncachedRead32(&privateData->regs->int_mask) & mask) == ZERO) {
            /** Start single test.*/
            CPS_UncachedWrite32(&privateData->regs->int_test, mask);

            /** Waiting for test completion.*/
            while(delay > ZERO) {
                delay--;
                if(CPS_UncachedRead32((uint32_t*)&privateData->state) == (uint32_t)ASF_TEST_MODE_COMPLETED) {
                    /** Test completed successfully. */
                    result = EOK;
                    break;
                }
            }
        }

        /** Restore original interrupt settings and driver state.*/
        privateData->state = ASF_STARTED;
        if(enable != ZERO) {
            asfSettingInterrupts(privateData);
        }
    }
    else {
        result = EINVAL;
    }

    return result;
}

uint32_t ASF_TestEvent(ASF_PrivateData* privateData, ASF_EventErrorType eventType) {
    uint32_t result = 0;

    /** Check correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Checks if eventTypes does not exceed the allowed range.*/
        if((uint32_t)eventType <= (uint32_t)ASF_INTEGRITY) {
            result = priv_asfTestEvent(privateData, eventType, 0);
        } else {
            result = EINVAL;
        }
    }

    return result;
}

uint32_t ASF_SelfTest(ASF_PrivateData* privateData )  {
    uint32_t result = 0;
    uint8_t numOfEvents = (uint8_t)ASF_INTEGRITY;

    /** Array used for converting id to ASF_EventErrorType type.*/
    ASF_EventErrorType idToEventErrorType[] = {
        ASF_SRAM_CORRECTABLE,
        ASF_SRAM_UNCORRECTABLE,
        ASF_DATA_PARITY,
        ASF_CONFIGURATION,
        ASF_TRANSACTION_TIMEOUT,
        ASF_PROTOCOL,
        ASF_INTEGRITY,
    };

    /** Check correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        uint8_t i;
        /** Run test one by one for each supported ASF features.*/
        for(i = 0; i <= numOfEvents; i++) {
            result = checkIfASFSupported(privateData, idToEventErrorType[i]);
            if(result == (uint32_t)EOK) {
                result = priv_asfTestEvent(privateData, idToEventErrorType[i], 1);
                if(result == (uint32_t)EPROTO) {
                    break;
                }
            }

        }
    }

    return result;
}

uint32_t ASF_EnableEvent(ASF_PrivateData* privateData, ASF_EventErrorType eventType) {
    uint32_t result = EOK;

    /** Checks correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        uint32_t offset = (uint32_t)eventType;
        uint32_t mask = 0;

        if(offset <= (uint32_t)ASF_INTEGRITY) {
            mask = (uint32_t)1u << offset;
            /*8 Check if requested eventType is supported. */
            result = checkIfASFSupported(privateData, eventType);
        } else {
            result = EINVAL;
        }

        if(result == (uint32_t)EOK) {
            privateData->int_mask &= ~mask;
            /** Update interrupt mask registers.*/
            asfSettingInterrupts(privateData);
        }
    }

    return result;
}

uint32_t ASF_DisableEvent(ASF_PrivateData* privateData, ASF_EventErrorType eventType) {
    uint32_t result = EOK;

    /** Checks correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        uint32_t offset = (uint32_t)eventType;
        uint32_t mask = 0;
        if(offset <= (uint32_t)ASF_INTEGRITY) {
            mask = (uint32_t)1u << offset;
            /** Chheck if requested eventType is supported. */
            result = checkIfASFSupported(privateData, eventType);
        } else {
            result = EINVAL;
        }

        if(result == (uint32_t)EOK) {
            privateData->int_mask |= mask;

            /** Update interrupt mask registers.*/
            asfSettingInterrupts(privateData);
        }
    }
    return result;
}

uint32_t ASF_EnableAllEvents(ASF_PrivateData* privateData) {
    uint32_t result = 0;

    /** Checks correctness of parameters. If at least one of given parameter
     * are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        privateData->int_mask = ~ASF_INT_MASK;
        /** Update interrupt mask registers.*/
        asfSettingInterrupts(privateData);
    }
    return result;
}

uint32_t ASF_DisableAllEvents(ASF_PrivateData* privateData) {
    uint32_t result = EOK;

    /** Checks correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        privateData->int_mask = ASF_INT_MASK;
        /** Update interrupt mask registers.*/
        asfSettingInterrupts(privateData);
    }
    return result;
}

uint32_t ASF_SetEventAsNonFatal(ASF_PrivateData* privateData,
        ASF_EventErrorType eventType) {
    uint32_t result = EOK;

    /** Checks correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        uint32_t offset = (uint32_t)eventType;
        uint32_t mask = 0;

        if(offset <= (uint32_t)ASF_INTEGRITY) {
            mask = (uint32_t)1u << offset;
            /** Checks if eventType features is supported by ASF controller.*/
            result = checkIfASFSupported(privateData, eventType);
        } else {
            result = EINVAL;
        }

        if(result == (uint32_t)EOK) {
            uint32_t reg;
            /** Updates fatal_nonfatal_select register. If bit in
             *  register is set to 1 that means it is set as fatal.
             */
            reg = CPS_UncachedRead32(&privateData->regs->fatal_nonfatal_select);
            reg &= ~mask;
            CPS_UncachedWrite32(&privateData->regs->fatal_nonfatal_select, reg);
        }
    }

    return result;
}

uint32_t ASF_SetEventAsFatal(ASF_PrivateData* privateData,
        ASF_EventErrorType eventType) {
    uint32_t result = EOK;

    /** Checks correctness of parameters. If at least one of given parameter
     *  are incorrect then function returns EINVAL code error.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        uint32_t offset = (uint32_t)eventType;
        uint32_t mask = 0;

        if(offset <= (uint32_t)ASF_INTEGRITY) {
            mask = (uint32_t)1u << offset;
            /** Checks if eventType features is supported by ASF controller.*/
            result = checkIfASFSupported(privateData, eventType);
        } else {
            result = EINVAL;
        }

        if(result == (uint32_t)EOK) {
            uint32_t reg;

            /** Updates fatal_nonfatal_select register. If bit in
             *  register is set to 1 that means it is set as fatal.
             */
            reg = CPS_UncachedRead32(&privateData->regs->fatal_nonfatal_select);
            reg |= mask;
            CPS_UncachedWrite32(&privateData->regs->fatal_nonfatal_select, reg);
        }
    }
    return result;
}

static uint32_t enableProtocolEventByMask(ASF_PrivateData* privateData,
        uint32_t mask,
        bool enable) {
    uint32_t result = EOK;
    uint32_t local_mask;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    local_mask = privateData->supportedProtocols & mask;
    if(local_mask == ZERO) {
        result = ENOTSUP;
    } else {
        if(enable) {
            /** Enable detection of selected protocol errors.*/
            privateData->protocols_mask &= ~local_mask;
        } else {
            /** Disable detection of selected protocol features.*/
            privateData->protocols_mask |= local_mask;
        }

        /** Update interrupt mask registers.*/
        asfSettingInterrupts(privateData);
    }
    return result;
}

uint32_t ASF_EnableProtocolEventByMask(ASF_PrivateData* privateData, uint32_t mask) {
    uint32_t result = EOK;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Call internal function to enables detection of selected protocol error.*/
        result =enableProtocolEventByMask(privateData, mask, true);
    }
    return result;
}

uint32_t ASF_EnableProtocolEventByID(ASF_PrivateData* privateData, uint8_t id) {
    uint32_t result = 0;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        if(id < ASF_MAX_PROT_TO_EVENTS) {
            uint32_t mask = (uint32_t)1 << id;

           /** Calls internal function to enables detection of selected protocol error.*/
            result = enableProtocolEventByMask(privateData, mask, true);
        } else {
            result = EINVAL;
        }
    }
    return result;
}

uint32_t ASF_DisableProtocolEventByMask(ASF_PrivateData* privateData, uint32_t mask) {
    uint32_t result =0;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {

        /** Call internal function to disables detection of selected protocol error.*/
        result = enableProtocolEventByMask(privateData, mask, false);
    }
    return result;
}

uint32_t ASF_DisableProtocolEventByID(ASF_PrivateData* privateData, uint8_t id) {
    uint32_t result =0;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        if(id < ASF_MAX_PROT_TO_EVENTS) {
            uint32_t mask = (uint32_t)1 << id;

        /** Call internal function to disables detection of selected protocol error.*/
        result = enableProtocolEventByMask(privateData, mask, false);
        } else  {
            result = EINVAL;
        }
    }
    return result;
}

static uint32_t enableTimeoutEventByMask(ASF_PrivateData* privateData,
        uint32_t mask,
        bool enable) {
    uint32_t result = EOK;


    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData->supportedTimeouts ^ mask) == ZERO) {
        result = ENOTSUP;
    } else {
        if(enable) {

            /** Enable detection of selected timeout errors.*/
            privateData->timeouts_mask &= ~mask;
        } else {

            /** Enable detection of selected timeout errors.*/
            privateData->timeouts_mask |= mask;
        }

        /** Update interrupt mask registers. */
        asfSettingInterrupts(privateData);
    }
    return result;
}

uint32_t ASF_EnableTimeoutEventByMask(ASF_PrivateData* privateData, uint32_t mask) {
    uint32_t result = EOK;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Call internal function to enables detection of selected timeout error.*/
        result = enableTimeoutEventByMask(privateData, mask, true);
    }
    return result;
}

uint32_t ASF_EnableTimeoutEventByID(ASF_PrivateData* privateData, uint8_t id) {
    uint32_t result = 0;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        if(id < ASF_MAX_PROT_TO_EVENTS) {
            uint32_t mask = (uint32_t)1 << id;
            /** Call internal function to enables detection of selected timeout error.*/
            result = enableTimeoutEventByMask(privateData, mask, true);
        } else {
            result = EINVAL;
        }
    }
    return result;
}

uint32_t ASF_DisableTimeoutEventByMask(ASF_PrivateData* privateData, uint32_t mask) {
    uint32_t result = 0;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Call internal function to disables detection of selected timeout error.*/
        result = enableTimeoutEventByMask(privateData, mask, false);
    }
    return result;
}

uint32_t ASF_DisableTimeoutEventByID(ASF_PrivateData* privateData, uint8_t id) {
    uint32_t result = 0;

    /* Verify whether at least one selected protocol events is supported.
     * Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        if(id < ASF_MAX_PROT_TO_EVENTS) {
            uint32_t mask = (uint32_t)1 << id;

            /** Call internal function to disables detection of selected timeout error.*/
            result = enableTimeoutEventByMask(privateData, mask, false);
        } else {
            result = EINVAL;
        }
    }
    return result;
}

uint32_t ASF_GetStatistic(const ASF_PrivateData* privateData, ASF_StatInfo* stats) {
    uint32_t result = 0;

    /* Verify whether at least one selected protocol events is supported.
     * Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Copy internally stored statistic. */
        *stats = privateData->statistic;
    }

    return result;
}

uint32_t ASF_ClearStatistic(ASF_PrivateData* privateData) {
    uint32_t result = 0;

    /** Verify whether at least one selected protocol events is supported.
     *  Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Clear memory used by statistic object.*/
        asf_memclear((uint8_t*)&privateData->statistic, sizeof(privateData->statistic));
    }
    return result;
}

uint32_t ASF_RestoreStatistic(ASF_PrivateData* privateData, const ASF_StatInfo* stats) {
    uint32_t result = 0;

    /* Verify whether at least one selected protocol events is supported.
     * Function enables only supported events.
     */
    if((privateData == NULL) || (privateData->tagSecurity != ASF_SECURITY_TAG)) {
        result = EINVAL;
    } else if (privateData->state < ASF_INITIALISED) {
        result = EINVAL;
    } else {
        /** Copy restored statistic object. */
        privateData->statistic = *stats;
    }

    return result;
}
