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
 * asf_tests.h
 * Header file containing declaration of tests
 *****************************************************************************/
#ifndef ASF_TEST_H
#define ASF_TEST_H

#include  "asf_priv.h"
#include "cdn_stdtypes.h"

uint32_t ASF_testBIST1(ASF_PrivateData *priv);
uint32_t ASF_testBIST2(ASF_PrivateData *priv);
uint32_t ASF_testDisableAllEventsFunc(ASF_PrivateData *priv);
uint32_t ASF_testEnableAllEventsFunc(ASF_PrivateData *priv);
uint32_t ASF_testEnableEventFunc(ASF_PrivateData *priv);
uint32_t ASF_testSetEventAsNonFatalFunc(ASF_PrivateData *priv, uint8_t instId);
uint32_t ASF_testDisableEventFunc(ASF_PrivateData *priv);
uint32_t ASF_testEnableProtocolEventByMaskFunc(ASF_PrivateData *priv);
uint32_t ASF_testDisableProtocolEventByMaskFunc(ASF_PrivateData *priv);
uint32_t ASF_testEnableProtocolEventByIDFunc(ASF_PrivateData *priv);
uint32_t ASF_testDisableProtocolEventByIDFunc(ASF_PrivateData *priv);
uint32_t ASF_testEnableTimeoutEventByMaskFunc(ASF_PrivateData *priv);
uint32_t ASF_testDisableTimeoutEventByMaskFunc(ASF_PrivateData *priv);
uint32_t ASF_testEnableTimeoutEventByIDFunc(ASF_PrivateData *priv);
uint32_t ASF_testDisableTimeoutEventByIDFunc(ASF_PrivateData *priv);
uint32_t ASF_testStatisticFunc(ASF_PrivateData *priv);

#endif
