/**********************************************************************
 * Copyright (C) 2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 **********************************************************************
 * WARNING: This file is auto-generated using api-generator utility.
 *          Do not edit it manually.
 **********************************************************************
 * Cadence Core Driver for Active Safety Features (ASF) extension.
 **********************************************************************/

/**
 * This file contains sanity API functions. The purpose of sanity functions
 * is to check input parameters validity. They take the same parameters as
 * original API functions and return 0 on success or EINVAL on wrong parameter
 * value(s).
 */

#ifndef ASF_SANITY_H
#define ASF_SANITY_H

#include <asf_if.h>
#include <cdn_stdtypes.h>
#include <cdn_errno.h>


#define	ASF_ProbeSF ASF_SanityFunction1
#define	ASF_InitSF ASF_SanityFunction2
#define	ASF_DestroySF ASF_SanityFunction3
#define	ASF_StartSF ASF_SanityFunction3
#define	ASF_StopSF ASF_SanityFunction3
#define	ASF_IsrSF ASF_SanityFunction3
#define	ASF_CheckIfASFSupportedSF ASF_SanityFunction7
#define	ASF_GetSupportedASFSF ASF_SanityFunction8
#define	ASF_GetSupportedTimeoutErrorSF ASF_SanityFunction8
#define	ASF_GetSupportedProtocolErroSF ASF_SanityFunction8
#define	ASF_SelfTestSF ASF_SanityFunction3
#define	ASF_TestEventSF ASF_SanityFunction12
#define	ASF_EnableEventSF ASF_SanityFunction12
#define	ASF_DisableEventSF ASF_SanityFunction12
#define	ASF_EnableAllEventsSF ASF_SanityFunction3
#define	ASF_DisableAllEventsSF ASF_SanityFunction3
#define	ASF_SetEventAsNonFatalSF ASF_SanityFunction12
#define	ASF_SetEventAsFatalSF ASF_SanityFunction12
#define	ASF_EnableProtocolEventByMasSF ASF_SanityFunction19
#define	ASF_EnableProtocolEventByIDSF ASF_SanityFunction20
#define	ASF_DisableProtocolEventByMaSF ASF_SanityFunction19
#define	ASF_DisableProtocolEventByIDSF ASF_SanityFunction20
#define	ASF_EnableTimeoutEventByMaskSF ASF_SanityFunction19
#define	ASF_EnableTimeoutEventByIDSF ASF_SanityFunction20
#define	ASF_DisableTimeoutEventByMasSF ASF_SanityFunction19
#define	ASF_DisableTimeoutEventByIDSF ASF_SanityFunction20
#define	ASF_GetStatisticSF ASF_SanityFunction27
#define	ASF_ClearStatisticSF ASF_SanityFunction3
#define	ASF_RestoreStatisticSF ASF_SanityFunction29
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] config Driver/hardware configuration required.
 * @param[out] sysReq Holds information about the size of memory allocations required.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction1(const ASF_Config* config, ASF_SysReq* sysReq)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (config == NULL)
    {
        ret = EINVAL;
    }
    if (sysReq == NULL)
    {
        ret = EINVAL;
    }


    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] config Specifies driver/hardware configuration.
 * @param[in] callbacks Client-supplied callback functions.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction2(ASF_PrivateData* privateData, const ASF_Config* config, const ASF_Callbacks* callbacks)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }
    if (config == NULL)
    {
        ret = EINVAL;
    }
    if (callbacks == NULL)
    {
        ret = EINVAL;
    }


    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction3(ASF_PrivateData* privateData)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }


    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] asfFeature Feature required for checking.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction7(const ASF_PrivateData* privateData, ASF_EventErrorType asfFeature)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }
    if (
        asfFeature != ASF_SRAM_CORRECTABLE &&
        asfFeature != ASF_SRAM_UNCORRECTABLE &&
        asfFeature != ASF_DATA_PARITY &&
        asfFeature != ASF_CONFIGURATION &&
        asfFeature != ASF_TRANSACTION_TIMEOUT &&
        asfFeature != ASF_PROTOCOL &&
        asfFeature != ASF_INTEGRITY
    )
    {
        ret = EINVAL;
    }

    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @param[out] asf_flag Bit flags specifies supported ASF features.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction8(const ASF_PrivateData* privateData, uint32_t* asf_flag)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }
    if (asf_flag == NULL)
    {
        ret = EINVAL;
    }


    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] eventType Indicating which test will be started.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction12(ASF_PrivateData* privateData, ASF_EventErrorType eventType)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }
    if (
        eventType != ASF_SRAM_CORRECTABLE &&
        eventType != ASF_SRAM_UNCORRECTABLE &&
        eventType != ASF_DATA_PARITY &&
        eventType != ASF_CONFIGURATION &&
        eventType != ASF_TRANSACTION_TIMEOUT &&
        eventType != ASF_PROTOCOL &&
        eventType != ASF_INTEGRITY
    )
    {
        ret = EINVAL;
    }

    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] mask Bit mask indicating which fault events will be enabled.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction19(ASF_PrivateData* privateData, uint32_t mask)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }


    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] id Index of protocol fault event that will be enabled.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction20(ASF_PrivateData* privateData, uint8_t id)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }


    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @param[out] stats Pointer to object that will be filled with statistic data.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction27(const ASF_PrivateData* privateData, ASF_StatInfo* stats)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }
    if (stats == NULL)
    {
        ret = EINVAL;
    }


    return ret;
}
/**
 * A common function to check the validity of API functions with
 * following parameter types
 * @param[in] privateData Driver state info specific to this instance.
 * @param[in] stats Pointer to object with data being restored.
 * @return 0 success
 * @return EINVAL invalid parameters
 */
static inline int32_t ASF_SanityFunction29(ASF_PrivateData* privateData, const ASF_StatInfo* stats)
{
    /* Declaring return variable */
    int32_t ret = 0;

    if (privateData == NULL)
    {
        ret = EINVAL;
    }
    if (stats == NULL)
    {
        ret = EINVAL;
    }


    return ret;
}

#endif	/* ASF_SANITY_H */
