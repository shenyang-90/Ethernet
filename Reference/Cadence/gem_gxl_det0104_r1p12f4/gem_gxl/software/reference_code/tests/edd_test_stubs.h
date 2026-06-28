/******************************************************************************
 * Copyright (C) 2014-2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 *
 * The material contained herein is the proprietary and confidential
 * information of Cadence or its licensors, and is supplied subject to, and may
 * be used only by Cadence's customer in accordance with a previously executed
 * license and maintenance agreement between Cadence and that customer.
 *
 ******************************************************************************/

#ifndef __EDD_TEST_STUBS_H__
#define __EDD_TEST_STUBS_H__


typedef int    (*cddc_printf)     (const char *, ...);
typedef struct {
    cddc_printf     printf;
} cddcOp;

#endif //__EDD_TEST_STUBS_H__
