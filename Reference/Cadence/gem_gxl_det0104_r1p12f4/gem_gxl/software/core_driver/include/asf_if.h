/**********************************************************************
 * Copyright (C) 2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 **********************************************************************
 * WARNING: This file is auto-generated using api-generator utility.
 *          Do not edit it manually.
 **********************************************************************
 * Cadence Core Driver for Active Safety Features (ASF) extension.
 **********************************************************************/

#ifndef ASF_IF_H
#define ASF_IF_H

#include "cdn_stdtypes.h"
#include "asf_regs.h"

/** @defgroup ConfigInfo  Configuration and Hardware Operation Information
 *  The following definitions specify the driver operation environment that
 *  is defined by hardware configuration or client code. These defines are
 *  located in the header file of the core driver.
 *  @{
 */

/**********************************************************************
* Defines
**********************************************************************/
/** Length of array holding the controller name associated with this ASF instance. */
#define	ASF_CONTROLLER_NAME_LEN (100U)

/** Length of array holding the version of controller associated with this ASF instance. */
#define	ASF_CONTROLLER_VERSION_LEN (16U)

/**
 * Number of implemented extended events. This number is used by statistics module.
 * The available range is 0 to 32. The safest solution is to leave this
 * parameter unchanged.
 * As extended events Core Driver understand the maximum available number of
 * protocol or timeout fault errors.
 * ASF has two IP specific group of faults - protocol errors and transaction timeout errors.
 * They are reported as interrupt by ASF core. Each of them has additional
 * separate register asf_trans_to_fault_mask and asf_protocol_fault_mask and
 * each bit in these registers represent different fault event.
 * So every protocol (ASF_PROTOCOL) and transaction timeout (ASF_TRANSACTION_TIMEOUT)
 * fault event can means 1 of 32 different faults.
*/
#define	ASF_MAX_NUMBER_EXTENDED_EVENTS (32U)

/** Size of array used by statistics module holding last detected SRAM errors. */
#define	ASF_LAST_SRAM_ERROR_ARRAY_SIZE (10U)

/**
 *  @}
 */


/** @defgroup DataStructure Dynamic Data Structures
 *  This section defines the data structures used by the driver to provide
 *  hardware information, modification and dynamic operation of the driver.
 *  These data structures are defined in the header file of the core driver
 *  and utilized by the API.
 *  @{
 */

/**********************************************************************
 * Forward declarations
 **********************************************************************/
typedef struct ASF_Config_s ASF_Config;
typedef struct ASF_SysReq_s ASF_SysReq;
typedef struct ASF_sramEventInfo_s ASF_sramEventInfo;
typedef struct ASF_sramInfo_s ASF_sramInfo;
typedef struct ASF_EventInfo_s ASF_EventInfo;
typedef struct ASF_StatInfo_s ASF_StatInfo;
typedef struct ASF_Callbacks_s ASF_Callbacks;

typedef struct ASF_PrivateData_s ASF_PrivateData;

/**********************************************************************
 * Enumerations
 **********************************************************************/
/** Type defines all available events that can be reported by ASF. */
typedef enum
{
    ASF_SRAM_CORRECTABLE = 0U,
    ASF_SRAM_UNCORRECTABLE = 1U,
    ASF_DATA_PARITY = 2U,
    ASF_CONFIGURATION = 3U,
    ASF_TRANSACTION_TIMEOUT = 4U,
    ASF_PROTOCOL = 5U,
    ASF_INTEGRITY = 6U,
} ASF_EventErrorType;

/**********************************************************************
 * Callbacks
 **********************************************************************/
/**
 * Reports all errors detected by ASF.
 * Params:
 * privetData - driver state info specific to this instance.
 * eventInfo - information fully describing detected event.
*/
typedef void (*ASF_eventErrorDetected)(ASF_PrivateData* privetData, ASF_EventInfo* eventInfo);

/**********************************************************************
 * Structures and unions
 **********************************************************************/
/**
 * Configuration of device.
 * Object of this type is used for probe and init functions.
*/
struct ASF_Config_s
{
    /** Base address of device controller registers */
    ASF_Regs* regBase;
    /**
     * Name of the controller related to this ASF instance. This field is optional and
     * can be helpful during debugging complex project.
    */
    uint8_t controllerName[ASF_CONTROLLER_NAME_LEN];
    /**
     * Version of controller related to this ASF instance. This field is optional and
     * can be helpful during debugging complex project.
    */
    uint8_t controllerVersion[ASF_CONTROLLER_VERSION_LEN];
    /**
     * Timer value to use for transaction timeout monitor. Driver assumes that
     * this value will be set only once during initialization. This parameter
     * shall be specified in milliseconds.
    */
    uint16_t transactionTimeoutValue;
};

/** System requirements returned by probe */
struct ASF_SysReq_s
{
    /** Size of memory required for driver's private data. */
    uint32_t privDataSize;
};

/** Structure holds information describing SRAM fault event. */
struct ASF_sramEventInfo_s
{
    /** ID of SRAM instance that generated fault Event. */
    uint8_t sramInstanceId;
    /** Address of SRAM instance that generated fault Event. */
    uint32_t sramAddress;
};

/** Structure holds information related to all SRAM instances. */
struct ASF_sramInfo_s
{
    /**
     * Field used only for ASF_SRAM_UNCORRECTABLE and ASF_SRAM_CORRECTABLE error events.
     * This filed will be set only if ASF was not able to correct detected SRAM fault.
    */
    uint8_t sramUncorrectableError;
    /**
     * Field used only for ASF_SRAM_UNCORRECTABLE and ASF_SRAM_CORRECTABLE error events.
     * Each controller can support many SRAM block. This field indicate for which
     * SRAM instance ID and SRAM address fault occurred.
    */
    ASF_sramEventInfo sramFaultInfo;
    /**
     * Field contains number of detected uncorrectable errors.
     * It is updated only on ASF_SRAM_UNCORRECTABLE event.
    */
    uint16_t uncorrectableErroCounter;
    /**
     * Field contains number of detected correctable errors.
     * This filed is updated only on ASF_SRAM_CORRECTABLE event.
    */
    uint16_t correctableErrorCounter;
};

/**
 * Instance of this object is passed as parameter to all functions defined in
 * ASF_Callbacks object.
 * Core Driver used this structure to describe all kind of detected events
 * The supported events are described by ASF_EventErrorType data type.
 * The type of detected and reported event is stored in eventErrorCode field.
 * Information included in this object can be collected by upper layer for
 * diagnostic or statistics purpose.
 * Additionally to facilitate identification of IP controller associated with
 * this event it has name and version fields describing name and version of
 * IP Controller.
*/
struct ASF_EventInfo_s
{
    /** Name of controller associated with ASF module. */
    uint8_t name[ASF_CONTROLLER_NAME_LEN];
    /** Version of controller associated with ASF module. */
    uint8_t version[ASF_CONTROLLER_VERSION_LEN];
    /** Interrupt event type detected by ASF. */
    ASF_EventErrorType eventErrorCode;
    /** Indicates whether reported fault is fatal or non-fatal. */
    uint8_t fatalEvent;
    /** Field holds all information related to SRAM. */
    ASF_sramInfo sramInfo;
    /**
     * Fault number for protocol and timeout events. ASF specification say that
     * this timeout and protocol fault are IP specific, Each IP controller can
     * contains different numbers of this events. extendedErrorIdx field defines
     * the index of fault event. Basic fault type can be read from eventErrorCode
     * field.
    */
    uint8_t extendedErrorIdx;
};

/**
 * Structure holds statistic data gathered by ASF Core Driver.
 * Only enabled ASF features will be gathered. For protection of gathered data
 * Core Driver internally holds ale collected data and sends to upper layer only copy of
 * this data. To retrieved actual ASF_statInfo object getStatistic
 * API function should be called. This statistic data can be used for debug
 * and diagnostic purposes.
 * Core Driver has implemented three API functions that can be used for handling statistic:
 *   - getStatistic
 *   - clearStatistic
 *   - restoreStatistic
 * Statistic are zeroed in initialization of Core Driver but also can be
 * explicitly cleared by means of clearStatistic function.
 * If upper layer wants to restore previously saved statistic object
 * (e.g. after rebooting system) it can use restoreStatistic API function.
*/
struct ASF_StatInfo_s
{
    /** Name of controller associated with ASF module. */
    uint8_t name[ASF_CONTROLLER_NAME_LEN];
    /** Version of controller associated with ASF module. */
    uint8_t version[ASF_CONTROLLER_VERSION_LEN];
    /** Number of detected integrity errors. */
    uint32_t integrityErrCounter;
    /** Number of detected configuration and status registers errors. */
    uint32_t configStatusErrCounter;
    /** Number of detected data and address paths parity errors. */
    uint32_t dataAdressParityErrCounter;
    /** Number of detected SRAM uncorrectable errors. */
    uint32_t sramUncorrectableErrCounter;
    /** Last ASF_LAST_SRAM_ERROR_ARRAY_SIZE detected correctable SRAM error events. */
    ASF_sramEventInfo lastSramCorrectableErr[ASF_LAST_SRAM_ERROR_ARRAY_SIZE];
    /** Last ASF_LAST_SRAM_ERROR_ARRAY_SIZE detected uncorrectable SRAM error events. */
    ASF_sramEventInfo lastSramUncorrectableErr[ASF_LAST_SRAM_ERROR_ARRAY_SIZE];
    /** Number of detected SRAM correctable errors. */
    uint32_t sramCorrectableErrCounter;
    /**
     * Number of detected protocol errors. Each element of array holds
     * information about other protocol error. Max number of possible
     * protocol errors supported by ASF is 32.
     * The number of supported by controller timeout errors associated with this
     * instance of ASF can be read from  protocolErrCount.
    */
    uint32_t protocolErrCounter[ASF_MAX_NUMBER_EXTENDED_EVENTS];
    /** Number of all detected protocol errors. */
    uint32_t allProtocolErrCounter;
    /**
     * Number of detected timeout errors. Each element of array holds
     * information about other timeout error. Max number of possible
     * timeout errors supported by ASF is 32.
     * The number of supported by controller timeout errors associated with this
     * instance of ASF can be read from timeoutErrCount,
    */
    uint32_t timeoutErrCounter[ASF_MAX_NUMBER_EXTENDED_EVENTS];
    /** Number of all detected timeout errors. */
    uint32_t allTimeoutErrCounter;
};

/**
 * struct containing function pointers for communication ASF driver with higher layers.
 * Each call passes the driver's privateData pointer for instance
 * identification if necessary, and also pass data related to the event.
*/
struct ASF_Callbacks_s
{
    ASF_eventErrorDetected sramCorrectableEvent;
    ASF_eventErrorDetected sramUncorrectableEvent;
    ASF_eventErrorDetected dataAdressParityEvent;
    ASF_eventErrorDetected configStatusRegiseterEvent;
    ASF_eventErrorDetected transactionTimeoutEvent;
    ASF_eventErrorDetected protocolEvent;
    ASF_eventErrorDetected integrityEvent;
};

/**
 *  @}
 */

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
/**
 * Checks configuration object.
 * @param[in] config Driver/hardware configuration required.
 * @param[out] sysReq Holds information about the size of memory allocations required.
 * @return EOK on success (requirements structure filled).
 * @return ENOTSUP if configuration cannot be supported due to driver/hardware constraints.
 */
uint32_t ASF_Probe(const ASF_Config* config, ASF_SysReq* sysReq);
/**
 * Initializes the driver instance as specified in the config.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] config Specifies driver/hardware configuration.
 * @param[in] callbacks Client-supplied callback functions.
 * @return EOK on success
 * @return EINVAL if illegal/inconsistent values in 'config'.
 * @return ENOTSUP if hardware has an inconsistent configuration or doesn't support feature(s) required by 'config' parameters.
 */
uint32_t ASF_Init(ASF_PrivateData* privateData, const ASF_Config* config, const ASF_Callbacks* callbacks);
/**
 * Destroy the driver (automatically performs a stop).
 * @param[in] privateData Driver state info specific to this instance.
 */
void ASF_Destroy(ASF_PrivateData* privateData);
/**
 * Start the ASF driver.
 * @param[in] privateData Driver state info specific to this instance.
 */
void ASF_Start(ASF_PrivateData* privateData);
/**
 * Stop the driver. This should disable the hardware, including its
 * interrupt at the source.
 * @param[in] privateData Driver state info specific to this instance.
 */
void ASF_Stop(ASF_PrivateData* privateData);
/**
 * Driver ISR.  Platform-specific code is responsible for ensuring
 * this gets called when the corresponding hardware's interrupt is
 * asserted. Registering the ISR should be done after calling init,
 * and before calling start. The driver's ISR will not attempt to lock
 * any locks, but will perform client callbacks. If the client wishes
 * to defer processing to non-interrupt time, it is responsible for
 * doing so.
 * @param[in] privateData Driver state info specific to this instance.
 */
void ASF_Isr(ASF_PrivateData* privateData);
/**
 * Function checks if controller support selected ASF features.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] asfFeature Feature required for checking.
 * @return EOK on success - required ASF feature is supported by IP core.
 * @return EINVAL if one of the parameter are invalid.
 * @return ENOTSUP if required ASF features is not supported.
 */
uint32_t ASF_CheckIfASFSupported(const ASF_PrivateData* privateData, ASF_EventErrorType asfFeature);
/**
 * Function by means of asf_flag returns all supported ASF features.
 * Features are returned in the form of bit mask (e.g 1 <<
 * ASF_INTEGRITY |        1 << ASF_PROTOCOL | 1 << ASF_DATA_PARITY).
 * @param[in] privateData Driver state info specific to this instance.
 * @param[out] asf_flag Bit flags specifies supported ASF features.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_GetSupportedASF(const ASF_PrivateData* privateData, uint32_t* asf_flag);
/**
 * Function gets supported timeout faults. The number and meaning of
 * timeout faults are IP specific and can vary depending on the IP
 * controller. Core Driver is able to detect how many and which faults
 * are supported but doesn't have knowledge what they mean. For this
 * reason the interpretation of these faults should be done by upper
 * layer. Supported timeout faults are returned in the form of bit
 * mask, where each bit corresponds to different type of timeout fault
 * @param[in] privateData Driver state info specific to this instance.
 * @param[out] flag Bit flags specifies supported timeout errors.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_GetSupportedTimeoutErrors(const ASF_PrivateData* privateData, uint32_t* flag);
/**
 * Function gets supported timeout faults. The number and meaning of
 * timeout faults are IP specific and can vary depending on the IP
 * controller. Core Driver is able to detect how many and which faults
 * are supported but doesn't have knowledge what they mean. For this
 * reason the interpretation of these faults should be done by upper
 * layer. Supported timeout faults are returned in the form of bit
 * mask, where each bit corresponds to different type of timeout fault
 * @param[in] privateData Driver state info specific to this instance.
 * @param[out] flag Bit flags specifies supported protocol errors.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_GetSupportedProtocolErrors(const ASF_PrivateData* privateData, uint32_t* flag);
/**
 * Run self test to checks if all events are generated for supported
 * ASF features.
 * @param[in] privateData Driver state info specific to this instance.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 * @return EPROTO if one of available fault events was not generated.
 */
uint32_t ASF_SelfTest(ASF_PrivateData* privateData);
/**
 * Function runs single test for a given type of fault event (see
 * ASF_EventErrorType). Test forces generate selected type's event and
 * checks if that event has occurred.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] eventType Indicating which test will be started.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 * @return EPROTO if selected test doesn't generate event.
 * @return ENOTSUP if selected ASF feature is not implemented.
 */
uint32_t ASF_TestEvent(ASF_PrivateData* privateData, ASF_EventErrorType eventType);
/**
 * Enable generation one of 7 available fault events.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] eventType Fault event that will be enabled..
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 * @return ENOTSUP if selected ASF feature is not implemented.
 */
uint32_t ASF_EnableEvent(ASF_PrivateData* privateData, ASF_EventErrorType eventType);
/**
 * Disable generation one of 7 available fault events.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] eventType Fault event that will be disabled.
 * @return EOK on success
 * @return EINVAL if one of the parameter are invalid.
 * @return ENOTSUP if selected ASF feature is not implemented.
 */
uint32_t ASF_DisableEvent(ASF_PrivateData* privateData, ASF_EventErrorType eventType);
/**
 * Enable generation all seven available fault events, provided that
 * they are implemented in IP controller.
 * @param[in] privateData Driver state info specific to this instance.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_EnableAllEvents(ASF_PrivateData* privateData);
/**
 * Disable generation all available fault events.
 * @param[in] privateData Driver state info specific to this instance.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_DisableAllEvents(ASF_PrivateData* privateData);
/**
 * Sets selected fault events as non-fatal. By default after
 * initialization all faults events are treated as fatal.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] eventType Fault event that will be treated as non-fatal.
 * @return EOK on success
 * @return EINVAL if one of the parameter are invalid.
 * @return ENOTSUP if selected ASF feature is not implemented.
 */
uint32_t ASF_SetEventAsNonFatal(ASF_PrivateData* privateData, ASF_EventErrorType eventType);
/**
 * Sets selected fault events as fatal. By default after
 * initialization all faults events are treated as fatal.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] eventType Fault event that will be treated as fatal.
 * @return EOK on success
 * @return EINVAL if one of the parameter are invalid.
 * @return ENOTSUP if selected ASF feature is not implemented.
 */
uint32_t ASF_SetEventAsFatal(ASF_PrivateData* privateData, ASF_EventErrorType eventType);
/**
 * Enables generation selected by mask protocol fault events. The
 * types of protocol fault events are IP specific. All protocol faults
 * for which bits are set will be enabled. This function doesn't
 * disable any enabled fault events. All not supported protocol fault
 * event will be ignored.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] mask Bit mask indicating which fault events will be enabled.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_EnableProtocolEventByMask(ASF_PrivateData* privateData, uint32_t mask);
/**
 * Enables generation selected by ID protocol fault events. The types
 * of protocol fault events are IP specific.This function allows to
 * enable handling selected by index fault event. Index is the bit
 * number in appropriate ASF register and it is numbered starting from
 * 1 to max 32. The number of available protocol fault events is IP
 * specific.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] id Index of protocol fault event that will be enabled.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 * @return ENOTSUP if required protocol fault event is not supported.
 */
uint32_t ASF_EnableProtocolEventByID(ASF_PrivateData* privateData, uint8_t id);
/**
 * Disables generation of timeout fault events selected by mask. The
 * types of protocol fault events are IP specific. All protocol faults
 * for which bits are set will be disabled. This function doesn't
 * enable any disabled fault events. All not supported protocol fault
 * event will be ignored.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] mask Bit mask indicating which fault events will be disabled.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_DisableProtocolEventByMask(ASF_PrivateData* privateData, uint32_t mask);
/**
 * Disables generation of timeout fault events selected by ID. The
 * types of protocol fault events are IP specific.This function allows
 * to disable handling selected by index fault event. Index is the bit
 * number in appropriate ASF register and it is numbered  starting
 * from 1 to max 32. The number of available protocol fault events is
 * IP specific.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] id Index of protocol fault event that will be enabled.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 * @return ENOTSUP if required protocol fault event is not supported.
 */
uint32_t ASF_DisableProtocolEventByID(ASF_PrivateData* privateData, uint8_t id);
/**
 * Enables generation selected by mask timeout fault events. The types
 * of timeout fault events are IP specific. All timeout faults for
 * which bits are set will be enabled. This function doesn't disable
 * any enabled timeout events. All not supported timeout fault event
 * will be ignored.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] mask Bit mask indicating which timeout events will be enabled.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_EnableTimeoutEventByMask(ASF_PrivateData* privateData, uint32_t mask);
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
uint32_t ASF_EnableTimeoutEventByID(ASF_PrivateData* privateData, uint8_t id);
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
uint32_t ASF_DisableTimeoutEventByMask(ASF_PrivateData* privateData, uint32_t mask);
/**
 * Disables generation of timeout fault events selected by ID. The
 * types of timeout fault events are IP specific.This function allows
 * to disable handling selected by index fault event. Index is the bit
 * number in appropriate ASF register and it is numbered starting from
 * 1 to max 32. The number of available timeout fault events is IP
 * specific.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] id Index of timeout fault event that will be enabled.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 * @return ENOTSUP if required timeout fault event is not supported.
 */
uint32_t ASF_DisableTimeoutEventByID(ASF_PrivateData* privateData, uint8_t id);
/**
 * Function fills the ASF_statistisc object passed by stats parameter
 * with all collected fault events. For the protection of data, Core
 * Driver returns to requester only copies of gathered data.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[out] stats Pointer to object that will be filled with statistic data.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_GetStatistic(const ASF_PrivateData* privateData, ASF_StatInfo* stats);
/**
 * Function clears the statistics gathered by ASF Core Driver.
 * @param[in] privateData Driver state info specific to this instance.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid.
 */
uint32_t ASF_ClearStatistic(ASF_PrivateData* privateData);
/**
 * Function restores the statistics from saved copies. After restoring
 * of data driver will continue collection of data on restored object.
 * Before this operation driver has to be stopped. Function can be
 * used to restore data after rebooting whole system.
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] stats Pointer to object with data being restored.
 * @return EOK on success.
 * @return EINVAL if one of the parameter are invalid
 */
uint32_t ASF_RestoreStatistic(ASF_PrivateData* privateData, const ASF_StatInfo* stats);

/**
 *  @}
 */


#endif	/* ASF_IF_H */
