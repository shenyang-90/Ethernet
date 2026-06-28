/**********************************************************************
 * Copyright (C) 2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 **********************************************************************
 * WARNING: This file is auto-generated using api-generator utility.
 *          Do not edit it manually.
 **********************************************************************
 * Cadence Core Driver for Active Safety Features (ASF) extension.
 **********************************************************************/
#ifndef ASF_OBJ_IF_H
#define ASF_OBJ_IF_H

#include "asf_if.h"

/** @defgroup DriverObject Driver API Object
 *  API listing for the driver. The API is contained in the object as
 *  function pointers in the object structure. As the actual functions
 *  resides in the Driver Object, the client software must first use the
 *  global GetInstance function to obtain the Driver Object Pointer.
 *  The actual APIs then can be invoked using obj->(api_name)() syntax.
 *  These functions are defined in the header file of the core driver
 *  and utilized by the API.
 *  @{
 */

/**********************************************************************
 * API methods
 **********************************************************************/
typedef struct ASF_OBJ_s
{
    /**
     * Checks configuration object.
     * @param[in] config Driver/hardware configuration required.
     * @param[out] sysReq Holds information about the size of memory allocations required.
     * @return EOK on success (requirements structure filled).
     * @return ENOTSUP if configuration cannot be supported due to driver/hardware constraints.
     */
    uint32_t (*probe)(const ASF_Config* config, ASF_SysReq* sysReq);

    /**
     * Initializes the driver instance as specified in the config.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] config Specifies driver/hardware configuration.
     * @param[in] callbacks Client-supplied callback functions.
     * @return EOK on success
     * @return EINVAL if illegal/inconsistent values in 'config'.
     * @return ENOTSUP if hardware has an inconsistent configuration or doesn't support feature(s) required by 'config' parameters.
     */
    uint32_t (*init)(ASF_PrivateData* privateData, const ASF_Config* config, const ASF_Callbacks* callbacks);

    /**
     * Destroy the driver (automatically performs a stop).
     * @param[in] privateData Driver state info specific to this instance.
     */
    void (*destroy)(ASF_PrivateData* privateData);

    /**
     * Start the ASF driver.
     * @param[in] privateData Driver state info specific to this instance.
     */
    void (*start)(ASF_PrivateData* privateData);

    /**
     * Stop the driver. This should disable the hardware, including its
     * interrupt at the source.
     * @param[in] privateData Driver state info specific to this instance.
     */
    void (*stop)(ASF_PrivateData* privateData);

    /**
     * Driver ISR.  Platform-specific code is responsible for ensuring
     * this gets called when the corresponding hardware's interrupt is
     * asserted. Registering the ISR should be done after calling init,
     * and before calling start. The driver's ISR will not attempt to
     * lock any locks, but will perform client callbacks. If the client
     * wishes to defer processing to non-interrupt time, it is
     * responsible for doing so.
     * @param[in] privateData Driver state info specific to this instance.
     */
    void (*isr)(ASF_PrivateData* privateData);

    /**
     * Function checks if controller support selected ASF features.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] asfFeature Feature required for checking.
     * @return EOK on success - required ASF feature is supported by IP core.
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP if required ASF features is not supported.
     */
    uint32_t (*checkIfASFSupported)(const ASF_PrivateData* privateData, ASF_EventErrorType asfFeature);

    /**
     * Function by means of asf_flag returns all supported ASF features.
     * Features are returned in the form of bit mask (e.g 1 <<
     * ASF_INTEGRITY |        1 << ASF_PROTOCOL | 1 << ASF_DATA_PARITY).
     * @param[in] privateData Driver state info specific to this instance.
     * @param[out] asf_flag Bit flags specifies supported ASF features.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*getSupportedASF)(const ASF_PrivateData* privateData, uint32_t* asf_flag);

    /**
     * Function gets supported timeout faults. The number and meaning of
     * timeout faults are IP specific and can vary depending on the IP
     * controller. Core Driver is able to detect how many and which
     * faults are supported but doesn't have knowledge what they mean.
     * For this reason the interpretation of these faults should be done
     * by upper layer. Supported timeout faults are returned in the form
     * of bit mask, where each bit corresponds to different type of
     * timeout fault
     * @param[in] privateData Driver state info specific to this instance.
     * @param[out] flag Bit flags specifies supported timeout errors.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*getSupportedTimeoutErrors)(const ASF_PrivateData* privateData, uint32_t* flag);

    /**
     * Function gets supported timeout faults. The number and meaning of
     * timeout faults are IP specific and can vary depending on the IP
     * controller. Core Driver is able to detect how many and which
     * faults are supported but doesn't have knowledge what they mean.
     * For this reason the interpretation of these faults should be done
     * by upper layer. Supported timeout faults are returned in the form
     * of bit mask, where each bit corresponds to different type of
     * timeout fault
     * @param[in] privateData Driver state info specific to this instance.
     * @param[out] flag Bit flags specifies supported protocol errors.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*getSupportedProtocolErrors)(const ASF_PrivateData* privateData, uint32_t* flag);

    /**
     * Run self test to checks if all events are generated for supported
     * ASF features.
     * @param[in] privateData Driver state info specific to this instance.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     * @return EPROTO if one of available fault events was not generated.
     */
    uint32_t (*selfTest)(ASF_PrivateData* privateData);

    /**
     * Function runs single test for a given type of fault event (see
     * ASF_EventErrorType). Test forces generate selected type's event
     * and checks if that event has occurred.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] eventType Indicating which test will be started.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     * @return EPROTO if selected test doesn't generate event.
     * @return ENOTSUP if selected ASF feature is not implemented.
     */
    uint32_t (*testEvent)(ASF_PrivateData* privateData, ASF_EventErrorType eventType);

    /**
     * Enable generation one of 7 available fault events.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] eventType Fault event that will be enabled..
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP if selected ASF feature is not implemented.
     */
    uint32_t (*enableEvent)(ASF_PrivateData* privateData, ASF_EventErrorType eventType);

    /**
     * Disable generation one of 7 available fault events.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] eventType Fault event that will be disabled.
     * @return EOK on success
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP if selected ASF feature is not implemented.
     */
    uint32_t (*disableEvent)(ASF_PrivateData* privateData, ASF_EventErrorType eventType);

    /**
     * Enable generation all seven available fault events, provided that
     * they are implemented in IP controller.
     * @param[in] privateData Driver state info specific to this instance.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*enableAllEvents)(ASF_PrivateData* privateData);

    /**
     * Disable generation all available fault events.
     * @param[in] privateData Driver state info specific to this instance.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*disableAllEvents)(ASF_PrivateData* privateData);

    /**
     * Sets selected fault events as non-fatal. By default after
     * initialization all faults events are treated as fatal.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] eventType Fault event that will be treated as non-fatal.
     * @return EOK on success
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP if selected ASF feature is not implemented.
     */
    uint32_t (*setEventAsNonFatal)(ASF_PrivateData* privateData, ASF_EventErrorType eventType);

    /**
     * Sets selected fault events as fatal. By default after
     * initialization all faults events are treated as fatal.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] eventType Fault event that will be treated as fatal.
     * @return EOK on success
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP if selected ASF feature is not implemented.
     */
    uint32_t (*setEventAsFatal)(ASF_PrivateData* privateData, ASF_EventErrorType eventType);

    /**
     * Enables generation selected by mask protocol fault events. The
     * types of protocol fault events are IP specific. All protocol
     * faults for which bits are set will be enabled. This function
     * doesn't disable any enabled fault events. All not supported
     * protocol fault event will be ignored.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] mask Bit mask indicating which fault events will be enabled.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*enableProtocolEventByMask)(ASF_PrivateData* privateData, uint32_t mask);

    /**
     * Enables generation selected by ID protocol fault events. The types
     * of protocol fault events are IP specific.This function allows to
     * enable handling selected by index fault event. Index is the bit
     * number in appropriate ASF register and it is numbered starting
     * from 1 to max 32. The number of available protocol fault events is
     * IP specific.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] id Index of protocol fault event that will be enabled.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP if required protocol fault event is not supported.
     */
    uint32_t (*enableProtocolEventByID)(ASF_PrivateData* privateData, uint8_t id);

    /**
     * Disables generation of timeout fault events selected by mask. The
     * types of protocol fault events are IP specific. All protocol
     * faults for which bits are set will be disabled. This function
     * doesn't enable any disabled fault events. All not supported
     * protocol fault event will be ignored.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] mask Bit mask indicating which fault events will be disabled.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*disableProtocolEventByMask)(ASF_PrivateData* privateData, uint32_t mask);

    /**
     * Disables generation of timeout fault events selected by ID. The
     * types of protocol fault events are IP specific.This function
     * allows to disable handling selected by index fault event. Index is
     * the bit number in appropriate ASF register and it is numbered
     * starting from 1 to max 32. The number of available protocol fault
     * events is IP specific.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] id Index of protocol fault event that will be enabled.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP if required protocol fault event is not supported.
     */
    uint32_t (*disableProtocolEventByID)(ASF_PrivateData* privateData, uint8_t id);

    /**
     * Enables generation selected by mask timeout fault events. The
     * types of timeout fault events are IP specific. All timeout faults
     * for which bits are set will be enabled. This function doesn't
     * disable any enabled timeout events. All not supported timeout
     * fault event will be ignored.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] mask Bit mask indicating which timeout events will be enabled.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*enableTimeoutEventByMask)(ASF_PrivateData* privateData, uint32_t mask);

    /**
     * Enables generation selected by ID timeout fault events. The types
     * of timeout fault events are IP specific.This function allows to
     * enable handling selected by index timeout event. Index is the bit
     * number in appropriate ASF register and it is numbered  starting
     * from 1 to max 32. The number of available timeout fault events is
     * IP specific.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] id Index of timeout fault event that will be enabled.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP If id exceeds the number of supported timeout fault events.
     */
    uint32_t (*enableTimeoutEventByID)(ASF_PrivateData* privateData, uint8_t id);

    /**
     * Disables generation of timeout fault events selected by mask. The
     * types of timeout fault events are IP specific. All timeout faults
     * for which bits are set will be disabled. This function doesn't
     * enable any disabled fault events. All not supported timeout fault
     * event will be ignored.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] mask Bit mask indicating which fault events will be disabled.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*disableTimeoutEventByMask)(ASF_PrivateData* privateData, uint32_t mask);

    /**
     * Disables generation of timeout fault events selected by ID. The
     * types of timeout fault events are IP specific.This function allows
     * to disable handling selected by index fault event. Index is the
     * bit number in appropriate ASF register and it is numbered starting
     * from 1 to max 32. The number of available timeout fault events is
     * IP specific.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] id Index of timeout fault event that will be enabled.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     * @return ENOTSUP if required timeout fault event is not supported.
     */
    uint32_t (*disableTimeoutEventByID)(ASF_PrivateData* privateData, uint8_t id);

    /**
     * Function fills the ASF_statistisc object passed by stats parameter
     * with all collected fault events. For the protection of data, Core
     * Driver returns to requester only copies of gathered data.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[out] stats Pointer to object that will be filled with statistic data.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*getStatistic)(const ASF_PrivateData* privateData, ASF_StatInfo* stats);

    /**
     * Function clears the statistics gathered by ASF Core Driver.
     * @param[in] privateData Driver state info specific to this instance.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid.
     */
    uint32_t (*clearStatistic)(ASF_PrivateData* privateData);

    /**
     * Function restores the statistics from saved copies. After
     * restoring of data driver will continue collection of data on
     * restored object. Before this operation driver has to be stopped.
     * Function can be used to restore data after rebooting whole system.
     * @param[in] privateData Driver state info specific to this instance.
     * @param[in] stats Pointer to object with data being restored.
     * @return EOK on success.
     * @return EINVAL if one of the parameter are invalid
     */
    uint32_t (*restoreStatistic)(ASF_PrivateData* privateData, const ASF_StatInfo* stats);

} ASF_OBJ;

/**
 * In order to access the ASF APIs, the upper layer software must call
 * this global function to obtain the pointer to the driver object.
 * @return ASF_OBJ* Driver Object Pointer
 */
extern ASF_OBJ *ASF_GetInstance(void);

/**
 *  @}
 */


#endif	/* ASF_OBJ_IF_H */
