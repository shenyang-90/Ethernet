/******************************************************************************
 * Copyright (C) 2015-2017 Cadence Design Systems, Inc.
 * All rights reserved worldwide.
 *
 * The material contained herein is the proprietary and confidential
 * information of Cadence or its licensors, and is supplied subject to, and may
 * be used only by Cadence's customer in accordance with a previously executed
 * license and maintenance agreement between Cadence and that customer.
 *
 ******************************************************************************
 *
 * Example Reference Test Code main function showing definition of the test
 * environment logging printf definition.
 *
 *****************************************************************************/
#include <stdio.h>
#include "edd_test_supp.h"

/* test-environment printf defn for compatibility with Cadence environment */
typedef int    (*env_printf)     (const char *, ...);
typedef struct {
    env_printf     printf;
} envOp;

envOp bmEnv;

int main (int argc, char **argv) {

    bmEnv.printf = printf;  /* use standard printf for logging */

    txRxTest(&bmEnv, NULL, NULL);

    cbTxRxTest(&bmEnv, NULL, NULL);

    loopbackTest(&bmEnv, NULL, NULL);

    emacTxRxTest(&bmEnv, NULL, NULL);

    printf("\nReference tests finished\n");
}
