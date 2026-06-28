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
 * asf_trace.h
 * debugging functions header file
 *****************************************************************************/
#ifndef ASF_TRACE_H
#define ASF_TRACE_H

//#define TRACE_ENABLED

#ifdef TRACE_ENABLED
/**
 * Display configuration information related with ASF controller 
 * @param[in] privateData Driver state info specific to this instance.
 * @return Error code
*/
uint32_t ASF_traceConfigSetting(ASF_PrivateData * priv); 

/**
 * Displays generic statistic information
 * @param[in] stat Statistic information object
 * @return void
*/
void ASF_TraceSimpleStatInfo(ASF_StatInfo *stat);

/**
 * Displays extended statistic information
 * In addition to the generic information function display 
 * information about reported timeout and protocol errors.
 * @param[in] stat Statistic information object
 * @return void
*/
void ASF_TraceExtendedStatInfo(ASF_StatInfo *stat);


/**
 * Function changes event error code to strintg 
 * param[in] eventErrorCode ASF event error code
 * return Event error in string form
*/
char * ASF_EventErrorTypeToString(ASF_EventErrorType eventErrorCode);

/**
 * Function display information about event
 * param[in] eventInfo object containg information related to detected fault condition
 * return void
*/
void ASF_traceEvent(ASF_EventInfo* eventInfo);
#else 
#define ASF_traceConfigSetting(priv)
#define ASF_TraceSimpleStatInfo(stat)
#define ASF_TraceExtendedStatInfo(stat)
#define ASF_EventErrorTypeToString(eventErrorCode)
#define ASF_traceEvent(eventInfo)
#endif

#endif //ASF_TRACE_H

