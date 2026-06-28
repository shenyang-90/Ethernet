#############################################################################
# copyright (C) 2014 Cadence Design Systems
# All rights reserved.
#
# Instructions:
#
# This makefile is for GNU make 3.79 or later.
#
# This is an example of building the initialization code and the driver.
#
# Inputs:
# - TGTDIR: points to build target (defaults to .)
# - CC: C compiler
# - CFLAGS: flags to C compiler
#
# End products (for lib target):
#
#	$(TGTDIR)/lib/libedd.a (driver library)
#
# Targets:
#	lib: as above
#	clean: remove objects
#
#############################################################################

COMPONENT_NAME := edd

#############################################################################
# Configurable variables
#############################################################################

# TODO: set CC, AR and CFLAGS as appropriate to your platform & toolchain
# OR set them in defines.mak
#AR := arm-none-eabi-ar -r
AR := ar -r
#CC32 := arm-none-eabi-gcc 
CC32 := gcc
CC := $(CC32) 
CFLAGS := -g -O0

#############################################################################
# Calculated variables
#############################################################################

DEFS := $(wildcard defines.mak)
ifneq ($(DEFS),)
include $(DEFS)
endif

ifndef TGTDIR
  TGTDIR := .
endif

DIR := .

OBJDIR := $(TGTDIR)/obj
LIBDIR := $(TGTDIR)/lib

CINCDIR := $(DIR)/include
CSRCDIR := $(DIR)/src

CFLAGS += -I$(CINCDIR) -I$(CSRCDIR)

CFLAGS += $(EXTRA_CFLAGS)

#############################################################################
# File targets
#############################################################################

CINCFILES := $(wildcard $(CINCDIR)/*.h)
CINCFILES += $(wildcard $(CSRCDIR)/*.h)

DRVSRC := $(notdir $(wildcard $(CSRCDIR)/*.c)) 

DRVOBJ := $(addprefix $(OBJDIR)/,$(addsuffix .o,$(basename $(DRVSRC))))

COBJ := $(DRVOBJ)

RANLIB := ranlib

LIBNAME := $(COMPONENT_NAME)
LIB := $(LIBDIR)/lib$(LIBNAME).a

#############################################################################
# Targets
#############################################################################

.PHONY: all drv

all: lib

lib: $(LIB)

#############################################################################

# clean
.PHONY: clean

clean:
	-rm -f $(COBJ)
	-rmdir $(OBJDIR)
	-rm -rf $(LIBDIR)

#############################################################################
# Pattern Rules
#############################################################################

$(LIB): $(COBJ)
	@echo COBJ:$(COBJ)
	@echo CINCFILES:$(CINCFILES)
	@echo OBJDIR:$(OBJDIR)
	@echo AR:$(AR)
	if [ ! -d $(@D) ]; then mkdir -p $(@D); fi
	$(AR) $@ $^
	-($(RANLIB) $@ || true) >/dev/null 2>&1

$(OBJDIR)/%.o: $(CSRCDIR)/%.c
	if [ ! -d $(@D) ]; then mkdir -p $(@D); fi
	@echo CFLAGS: $(CFLAGS)
	$(CC32) -c -o $(@) $(CFLAGS) $<

#############################################################################
# header deps (lazy)
#############################################################################

$(COBJ) : $(CINCFILES)
