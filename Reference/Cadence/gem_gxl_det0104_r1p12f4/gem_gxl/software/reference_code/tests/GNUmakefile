####################################################################
# copyright (C) 2014 Cadence Design Systems
# All rights reserved.
#
# Test build makefile for EMAC driver reference tests
####################################################################

# assume we're in the ref_code/tests directory
CORE_DIR := ../../core_driver
DRV_LIB := $(CORE_DIR)/lib/libedd.a

CFLAGS := -I$(CORE_DIR)/include
CFLAGS += -I$(CORE_DIR)/src
CFLAGS += -D __BARE_METAL__

# TODO: set CC appropriately to target platform
#CC := arm-none-eabi-gcc
CC := gcc

.PHONY: all
all: example_main drvlib

drvlib:
	@echo "*** building driver library ***"
	make -C $(CORE_DIR)
	@echo "*** building driver library DONE***"

example_main: cps_emac_bm.o edd_test_supp.o mac_test.o $(DRV_LIB)

.PHONY: clean
clean:
	rm -fr *.o
	rm -fr example_main
	make -C $(CORE_DIR) clean
