/**********************************************************************
 * Copyright (C) 2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 **********************************************************************
 * WARNING: This file is auto-generated using api-generator utility.
 *          Do not edit it manually.
 **********************************************************************
 * Cadence Core Driver for Active Safety Features (ASF) extension.
 **********************************************************************/

#ifndef ASF_PRIV_H
#define ASF_PRIV_H

#include "asf_if.h"
#include "asf_regs.h"

/** @defgroup DataStructure Dynamic Data Structures
 *  This section defines the data structures used by the driver to provide
 *  hardware information, modification and dynamic operation of the driver.
 *  These data structures are defined in the header file of the core driver
 *  and utilized by the API.
 *  @{
 */


/**********************************************************************
 * Enumerations
 **********************************************************************/
/** Type defines all possible state for ASF driver. */
typedef enum
{
    ASF_DESTROYED = 0U,
    ASF_INITIALISED = 1U,
    ASF_STOPPED = 2U,
    ASF_STARTED = 3U,
    ASF_TEST_MODE_STARTED = 4U,
    ASF_TEST_MODE_COMPLETED = 5U,
} ASF_States;

/**********************************************************************
 * Structures and unions
 **********************************************************************/
/**
 * Structure contains private data for Core Driver that should not  be used by
 * upper layers. This is not a part of API and manipulating of those data may cause
 * unpredictable behavior of Core Driver.
*/
struct ASF_PrivateData_s
{
    ASF_Regs* regs;
    /** Current state of ASF instance. */
    volatile ASF_States state;
    /** Field used to detects whether correct ASF object was passed to API function */
    uint32_t tagSecurity;
    /**
     * Name of controller related to this ASF extension. The field is optional and
     * can be helpful during debugging complex project.
    */
    uint8_t controllerName[ASF_CONTROLLER_NAME_LEN];
    /**
     * Version of controller related to ASF extension. This field is optional and
     * can be helpful during debugging complex project.
    */
    uint8_t controllerVersion[ASF_CONTROLLER_VERSION_LEN];
    /** Holds data about supported ASF features */
    uint32_t supportedFeatures;
    /** Hold data about supported protocol fault events */
    uint32_t supportedProtocols;
    /** Hold data about supported timeout fault events */
    uint32_t supportedTimeouts;
    /**
     * Number of timeout errors supported by controller associated with
     * this instance of ASF.
    */
    uint32_t timeoutErrCount;
    uint32_t protocolErrCount;
    ASF_EventInfo eventInfo;
    ASF_StatInfo statistic;
    ASF_Callbacks callbacks;
    /**
     * Holds data indicating which fault events will be enabled after calling
     * start() function. This field allows programmer to configure required events
     * before it calls start() function. Selected events will be enabled only after
     * calling start() API function.
    */
    uint32_t int_mask;
    /**
     * Holds data indicating which protocol events will be enabled after calling
     * start() function. This field allows programmer to configure required events
     * before it calls start() function. Selected events will be enabled only after
     * calling start() API function.
    */
    uint32_t protocols_mask;
    /**
     * Holds data indicating which timeout events will be enabled after calling
     * start() function. This field allows programmer to configure required events
     * before it calls start() function. Selected events will be enabled only after
     * calling start() API function.
    */
    uint32_t timeouts_mask;
};

/**
 *  @}
 */

#endif	/* ASF_PRIV_H */
