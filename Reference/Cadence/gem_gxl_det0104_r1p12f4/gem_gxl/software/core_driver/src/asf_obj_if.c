/**********************************************************************
 * Copyright (C) 2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 **********************************************************************
 * WARNING: This file is auto-generated using api-generator utility.
 *          Do not edit it manually.
 **********************************************************************
 * Cadence Core Driver for Active Safety Features (ASF) extension.
 **********************************************************************/

#include "asf_obj_if.h"


ASF_OBJ *ASF_GetInstance(void)
{
    static ASF_OBJ driver =
    {
        .probe = ASF_Probe,
        .init = ASF_Init,
        .destroy = ASF_Destroy,
        .start = ASF_Start,
        .stop = ASF_Stop,
        .isr = ASF_Isr,
        .checkIfASFSupported = ASF_CheckIfASFSupported,
        .getSupportedASF = ASF_GetSupportedASF,
        .getSupportedTimeoutErrors = ASF_GetSupportedTimeoutErrors,
        .getSupportedProtocolErrors = ASF_GetSupportedProtocolErrors,
        .selfTest = ASF_SelfTest,
        .testEvent = ASF_TestEvent,
        .enableEvent = ASF_EnableEvent,
        .disableEvent = ASF_DisableEvent,
        .enableAllEvents = ASF_EnableAllEvents,
        .disableAllEvents = ASF_DisableAllEvents,
        .setEventAsNonFatal = ASF_SetEventAsNonFatal,
        .setEventAsFatal = ASF_SetEventAsFatal,
        .enableProtocolEventByMask = ASF_EnableProtocolEventByMask,
        .enableProtocolEventByID = ASF_EnableProtocolEventByID,
        .disableProtocolEventByMask = ASF_DisableProtocolEventByMask,
        .disableProtocolEventByID = ASF_DisableProtocolEventByID,
        .enableTimeoutEventByMask = ASF_EnableTimeoutEventByMask,
        .enableTimeoutEventByID = ASF_EnableTimeoutEventByID,
        .disableTimeoutEventByMask = ASF_DisableTimeoutEventByMask,
        .disableTimeoutEventByID = ASF_DisableTimeoutEventByID,
        .getStatistic = ASF_GetStatistic,
        .clearStatistic = ASF_ClearStatistic,
        .restoreStatistic = ASF_RestoreStatistic,
    };

    return &driver;
}
