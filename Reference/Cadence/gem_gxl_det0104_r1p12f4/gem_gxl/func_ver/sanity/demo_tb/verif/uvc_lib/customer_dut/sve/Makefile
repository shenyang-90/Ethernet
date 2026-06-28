#------------------------------------------------------------------------------
# File      : Makefile
# Author    : Cadence
# Description : Simple Makefile
#------------------------------------------------------------------------------
# Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
#------------------------------------------------------------------------------

CDN_DEMO_TB_PATH_OVERRIDE ?=
# Step 1. Check if the var has been set by the user
ifeq ($(CDN_DEMO_TB_PATH_OVERRIDE),)
 MAKE_LOC := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
 CDN_DEMO_TB_PATH := $(abspath ${MAKE_LOC}/../../../../)
 # NOTE: CDN_DEMO_TB_PATH must be exported for vManager
else
 CDN_DEMO_TB_PATH := $(CDN_DEMO_TB_PATH_OVERRIDE)
endif

#--------------------------------------------------------------------
# Setup the default extra args and defines needed to compile and use the 
# customer DUT TB and UVM overrides package.
#--------------------------------------------------------------------
IRUN_BASE_ARGS:= \
  -define CUSTOMER_DUT \
	-define CDN_DEMO_RAM_INTEGRATION_TEST
RTL_SRC:= \
  -incdir $(CDN_DEMO_TB_PATH)/verif/uvc_lib/customer_dut/sve/ \
  -F $(CDN_DEMO_TB_PATH)/verif/uvc_lib/customer_dut/sve/customer_dut.f \

PROTOCOL_PKG:= \
  -incdir $(CDN_DEMO_TB_PATH)/verif/uvc_lib/customer_dut/sv/ \
  -incdir $(CDN_DEMO_TB_PATH)/verif/uvc_lib/customer_dut/sve/ \
  $(CDN_DEMO_TB_PATH)/verif/uvc_lib/customer_dut/sv/customer_pkg.sv \

#--------------------------------------------------------------------
# Import main cdn_demo TB Makefile
#--------------------------------------------------------------------
include $(CDN_DEMO_TB_PATH)/verif/uvc_lib/cdn_demo/sve/Makefile 

#--------------------------------------------------------------------
# END OF FILE
#--------------------------------------------------------------------

