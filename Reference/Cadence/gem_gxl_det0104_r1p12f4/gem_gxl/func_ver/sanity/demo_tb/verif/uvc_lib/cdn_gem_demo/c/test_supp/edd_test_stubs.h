/******************************************************************************
 * copyright (C) 2014-2015 Cadence Design Systems
 * All rights reserved.
 *****************************************************************************/

/*! \file edd_test_stubs.h
 *  \brief This file is used as test support for the core driver tests.
 */

#ifndef __EDD_TEST_STUBS_H__
#define __EDD_TEST_STUBS_H__


typedef int    (*cddc_printf)     (const char *, ...);
typedef struct {
    cddc_printf     printf;
} cddcOp;

#endif //__EDD_TEST_STUBS_H__
