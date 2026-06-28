#------------------------------------------------------------------------------
# File      : config.rdl_ram_integration.mk
# Author    : smckelvie@cadence.com
# Description : Reference example for the RAM integration block.
#------------------------------------------------------------------------------
# Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
#------------------------------------------------------------------------------
# Description:
# The purpose of this file is to give a reference example for the RAM
# integration block where the various files are setup to compile the RAM
# integration tests/files.
#
#------------------------------------------------------------------------------

#--------------------------------------------------------------------
# RAM integration setup.
#--------------------------------------------------------------------

RTL_SRC += \
	-incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/sve \
  ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo_ram_integration/sve/cdn_demo_top.sv

# Add the demo top the verification source
IRUN_VERIF_SRC += \
	$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo/sve/cdn_demo_module_top.sv \

# Add the RAM integration C test
IRUN_C_COMPILE_ARGS += \
    $(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo_ram_integration/sve/tests_c/$(TEST_TITLE).c) \


define PROTOCOL_HELP
	Protocol help includes the RAM Integration block.....
	....as an example of using multiple lines
endef
export PROTOCOL_HELP

