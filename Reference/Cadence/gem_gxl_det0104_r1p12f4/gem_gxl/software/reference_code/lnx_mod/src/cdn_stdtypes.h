/******************************************************************************
 * Copyright (C) 2014-2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 *
 * The material contained herein is the proprietary and confidential
 * information of Cadence or its licensors, and is supplied subject to, and may
 * be used only by Cadence's customer in accordance with a previously executed
 * license and maintenance agreement between Cadence and that customer.
 *
 ******************************************************************************
 * cdn_stdtypes.h
 * Cadence types and definitions
 ******************************************************************************/

#ifndef __INCLUDE_CDN_STDTYPES_H___
#define	__INCLUDE_CDN_STDTYPES_H___

#include "cdn_stdint.h"

/* Define NULL constant */
#ifndef NULL
#define	NULL	((void *)0)
#endif

/* Define bool data type */
#define bool	_Bool
#define	true	1
#define	false	0
#define	__bool_true_false_are_defined 1

#endif	/* __INCLUDE_CDN_STDTYPES_H__ */
