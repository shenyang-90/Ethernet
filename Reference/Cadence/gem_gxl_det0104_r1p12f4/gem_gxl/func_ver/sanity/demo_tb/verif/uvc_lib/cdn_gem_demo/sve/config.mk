#-------------------------------------------------------------------------------
# File      : conifg.mk
# Author    : Cadence
# Description : cdn_gem_demo Makefile extension
#-------------------------------------------------------------------------------
# Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# CMDLINE ARGS
#-------------------------------------------------------------------------------

CONFIG ?= pbuf_axi_uvm

#----------------------------------------
# Hidden Args
#----------------------------------------

CONFIG_SEED ?= $(shell perl -e 'srand; print int(rand(65535)+1)')
RESTRICT    ?= uvm_demotb
REGRESSION  ?= rr
RLIST       ?=

# Override cdn_demo Makefile
ENV_PATH_DISABLE_CHECK := 1
COV                    := 0

#-------------------------------------------------------------------------------
# MAKE ENV VARIABLES
#-------------------------------------------------------------------------------

#----------------------------------------
# General Setup
#----------------------------------------

# Override cdn_demo Makefile
VM_DIR := $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/vm/

#----------------------------------------
# Protocol Setup
#----------------------------------------

define PROTOCOL_HELP
- Protocol Specific Help:
-----------------------------------------------------------------------------------------

 To run wiht a fixed config  : make <run_command> TEST=<test_name> CONFIG=<config_name>
 To run with a random config : make <run_command> TEST=<test_name> CONFIG=random RESTRICT=uvm_demotb
 To run a custom regression  : make rr RLIST="<test_name_1> <test_name_2> ..."

 Makefile targets :
         regression     - Standalone regression - all tests
         regression_c   - Standalone regression - C tests
         regression_uvm - Standalone regression - UVM tests
         rr             - Standalone regression - specify a custom test list with the RLIST switch

 Optional Make switches :
         CONFIG         - Design config name. For random configs use 'random' (default: pbuf_axi_uvm)
         CONFIG_SEED    - Design config seed, used when generating random configs
         RESTRICT       - Restriction file name for random config generation (default: uvm_demotb)
         RLIST          - Specify a custom test list for standalone regressions. Surround in "" quotes
endef
export PROTOCOL_HELP

# Specify the protocol setup target
PROTOCOL_SETUP_TARGET := protocol_setup

# Specify the protocol clean target
PROTOCOL_CLEAN_TARGET := clean_protocol

# Specify the protocol VIPs that should be compiled
PROTOCOL_VIP := enet

# Specify the Doxygen source files upon which build HTML documentation.
DOCS_DOXYGEN_SRC := $(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/*/sve/tests_c/*.c)
DOCS_DOXYGEN_SRC += $(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/*/c/*.h)
DOCS_DOXYGEN_SRC += $(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/*/c/test_supp/*.h)

#---------------------------------------
# DUT Setup
#---------------------------------------

DESIGN              := gem_gxl
MODULE_PATH         := $(CDN_DEMO_PATH)/../../..

MODULE_CONFIG_PATH  := $(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs
TECH                := default
GEN_SYNTH           := ""

export MODULE_PATH

# Export for vManager
export TOP_DIR
export CDN_VIP_LIB_PATH

#---------------------------------------
# Config Setup
#---------------------------------------

ifeq ($(CONFIG),random)
  RANDOM_CONFIG := 1
else ifneq ($(wildcard $(MODULE_CONFIG_PATH)/$(CONFIG).cee),)
  RANDOM_CONFIG := 0
else
  $(error *E : The configuration does not exist. Available: $(MODULE_CONFIG_PATH))
endif

#---------------------------------------
# Tests Setup
#---------------------------------------

# Get test lists from vsifs
TESTS_UVM_REG := $(filter cdn_%,$(shell grep "_test" $(VM_DIR)/cdn_gem_demo_regression_uvm_reg.vsif))
TESTS_UVM     := $(filter cdn_%,$(shell grep "_test" $(VM_DIR)/cdn_gem_demo_regression_uvm.vsif))
TESTS_C       := $(filter cdn_%,$(shell grep "_test" $(VM_DIR)/cdn_gem_demo_regression_c.vsif))
TESTS_GLOBAL  := $(filter cdn_%,$(shell grep "_test" $(VM_DIR)/cdn_gem_demo_regression_global.vsif))

# Override Makefile
ifeq ($(TEST),cdn_demo_base_test)
  TEST         := cdn_gem_demo_base_test
  TEST_TITLE   := $(TEST)
  UVM_TESTNAME := $(TEST)
else ifeq ($(C_TEST),1)
  UVM_TESTNAME := cdn_gem_demo_c_base_test
endif

# Have you set a valid test name?
ifeq ($(findstring cdn_gem_demo_base_test, $(TEST_TITLE)),)
  ifeq ($(findstring $(TEST_TITLE), $(TESTS_GLOBAL)),)
    $(error *E : Wrong test name. See $(VM_DIR)/cdn_gem_demo_regression_global.vsif for available)
  endif
endif

# To distinguish UVM_REG tests from others since stuff needs to be disabled in
# the testbench
UVM_REG_TEST := 0
ifneq ($(findstring _uvm_reg_, $(TEST_TITLE)),)
    UVM_REG_TEST := 1
endif

#-----------------------------------------
# Debug Setup
#-----------------------------------------

ifeq ($(UVM_VERBOSITY),UVM_HIGH)
  DENALI_LOG := 1
  C_DEBUG    := 1
else ifeq ($(UVM_VERBOSITY),UVM_FULL)
  DENALI_LOG := 1
  C_DEBUG    := 2
else ifeq ($(UVM_VERBOSITY),UVM_DEBUG)
  DENALI_LOG := 1
  C_DEBUG    := 3
else
  DENALI_LOG := 0
  C_DEBUG    := 0
endif

#-------------------------------------------------------------------------------
# SIMULATION ARGUMENTS
#-------------------------------------------------------------------------------

#----------------------------------------
# RTL
#----------------------------------------

#IRUN_RTL_BASE_ARGS := ./$(DESIGN)_defs.v

RTL_SRC := \
  -incdir $(MODULE_PATH)/func_ver/sanity/vlog_tb/src \
  -F ./$(DESIGN).f \
  $(MODULE_PATH)/func_ver/sanity/vlog_tb/src/tb_defs.v

ifeq ($(DESIGN),gem)
  RTL_SRC += \
    $(MODULE_PATH)/func_ver/sanity/vlog_tb/src/common/tb_dpram.v
else
  RTL_SRC += \
    $(MODULE_PATH)/func_ver/sanity/vlog_tb/src/tb_dpram.v
endif

RTL_SRC += \
  $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/sve/cdn_gem_demo_dut_wrapper.sv

#----------------------------------------
# VIPs
#----------------------------------------

VIP_ENET_ARGS := \
  -incdir $(DENALI)/ddvapi/sv/uvm/enet \
  -incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_enet_vip/sv \
  $(DENALI)/ddvapi/sv/denaliEnet.sv \
  $(DENALI)/ddvapi/sv/uvm/enet/cdnEnetUvmTop.sv \
  $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_enet_vip/sv/cdn_enet_vip_pkg.sv \
  $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_enet_vip/sv/cdn_enet_vip_gmii_if.sv \
  $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_enet_vip/sv/cdn_enet_vip_rgmii_if.sv \
  $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_enet_vip/sv/cdn_enet_vip_rmii_if.sv

VIP_BASE_ARGS += \
  $(VIP_ENET_ARGS)

#----------------------------------------
# Protocol
#----------------------------------------

PROTOCOL_SPECIFIC_ARGS := \
  -nowarn NOTVFW \
  -nowarn DSEM2009 \
  -nowarn PRLDYN \
  -nowarn PRPASZ \
  -nowarn SPDUSD \
  -l irun_$(TEST_TITLE).log

ifeq ($(UVM_REG_TEST),1)
  PROTOCOL_SPECIFIC_ARGS += \
    -define CDN_GEM_DEMO_UVM_REG_TESTS
endif

PROTOCOL_PKG += \
  -incdir . \
  -incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/sv \
  -incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/sve \
  -incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/sve/tests \
  -incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/sve/tests_c \
  $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/sv/cdn_gem_demo_pkg.sv

#---------------------------------------
# C
#---------------------------------------

ifeq ($(C_TEST), 1)
  IRUN_C_COMPILE_ARGS += \
    -licq \
    -nbasync \
    -messages \
    -nowarn CUVWSP \
    -nowarn CUSRCH \
    -nowarn CUVMPW \
    -DDPI_COMPATIBILITY_VERSION_1800v2005 \
    -D__BARE_METAL__

  ifeq ($(C_DEBUG),1)
    IRUN_C_COMPILE_ARGS += \
      -DEDD_DBG_LOG
  endif

  ifeq ($(C_DEBUG),2)
    IRUN_C_COMPILE_ARGS += \
      -g
  endif

  ifeq ($(C_DEBUG),3)
    IRUN_C_COMPILE_ARGS += \
      -DCDN_DEMO_DEBUG
  endif

  IRUN_C_COMPILE_ARGS += \
    -incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/sve/tests_c \
    -I$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/c \
    -I$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/c/test_supp \
    -I$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/c/CoreDriver/include \
    -I$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/c/CoreDriver/src \
    $(wildcard $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/c/*.c) \
    $(wildcard $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/c/test_supp/*.c) \
    $(wildcard $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/c/CoreDriver/src/*.c) \
    $(wildcard $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/sve/tests_c/$(TEST_TITLE).c)
endif

#-------------------------------------------------------------------------------
# MAKE TARGETS & RULES
#-------------------------------------------------------------------------------

#---------------------------------------
# default: this runs when the Makefile 
# is called without arguments.
#---------------------------------------
.PHONY: default
default: clean regression

#---------------------------------------
# docs_delivery: move the docs to the 
# appropriate delivery directories, 
# rather than being located within the 
# current working directory.
#---------------------------------------
.PHONY: docs_delivery
docs_delivery: docs
	@cp -r ./docs_nd ./docs_doxygen $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_gem_demo/docs
	@echo "*****************************"
	@echo "Copied to delivery directory:"
	@echo "*****************************"
	@echo "Natural Docs Output : ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_gem_demo/docs/docs_nd/index.html"
	@echo "Doxygen Docs Output : ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_gem_demo/docs/docs_doxygen/index.html"
	@echo "*****************************"

#---------------------------------------
# clean_protocol: protocol-specific
# clean.
#---------------------------------------
.PHONY: clean_protocol
clean_protocol:
	rm -rf ./vmgr_db
	rm -rf ./*_regression.*
	rm -rf ./*.trc
	rm -rf ./*.his
	rm -rf ./*.err
	rm -rf ./*.elog
	rm -rf ./*.f
	rm -rf ./*.v
	rm -rf ./*.sv
	rm -rf ./.denalirc*
	rm -rf ./*.xml
	rm -rf ./*.rdl
	rm -rf ./*.bitwise*
	rm -rf ./*.setup
	rm -rf ./indago_*
	rm -rf ./run_the_test.csh
	rm -rf ./$(DESIGN)_$(CONFIG).*
	rm -rf ./gem_regmodel.sv
	rm -rf ./docs_doxygen
	rm -rf ./docs_nd
	rm -rf ./naturaldoc_project_folder
	rm -f *.results
	rm -rf *.shm
	rm -rf ./config_*
	rm -rf ./imc.log
	rm -rf ./mdv.log
	rm -rf ./Glue.log

#---------------------------------------
# denali: sets the Denali log and
# verbosity.
#---------------------------------------
.PHONY: denali
denali:
	@rm -f ./.denalirc;
	@touch ./.denalirc
	@echo "ErrorCount ${TOP_LEVEL_TB_NAME}.ps_error_count" >> ./.denalirc
  ifeq ($(DENALI_LOG),1)
	  @echo "Historyfile denali.his" >> ./.denalirc
	  @echo "Historydebug on" >> ./.denalirc
	  @echo "Tracefile denali.trc" >> ./.denalirc
  endif

#---------------------------------------
# create_defs: creates defs and .f
# files for the DUT.
#---------------------------------------
.PHONY: create_defs
create_defs:
	@rm -rf  ./$(DESIGN)_defs.v
	@rm -rf  ./edma_defs.v
	@rm -rf  ./ungroup_params.v
	@rm -rf  ./edma_params.v

  # Make sure seed is the last argument as it can be undefined for vManager
  # compile only runs and it causes a problem with the cfg builder
	$(MODULE_PATH)/work/gem_cfg_builder.pl -cfg $(CONFIG) -seed $(CONFIG_SEED) ${GEN_SYNTH} -tech ${TECH} -restrict $(RESTRICT) | tee $(TEST_TITLE).setup

	@if [ -a $(CDN_DEMO_RTL_PATH)/edma_defs.v ]; then \
	  cp -rf $(CDN_DEMO_RTL_PATH)/edma_defs.v ./; \
	  cp -rf $(CDN_DEMO_RTL_PATH)/ungroup_params.v ./; \
	  cp -rf $(CDN_DEMO_RTL_PATH)/edma_params.v ./; \
	else \
	  cp -rf $(CDN_DEMO_RTL_PATH)/common/edma_defs.v ./; \
	  cp -rf $(CDN_DEMO_RTL_PATH)/common/ungroup_params.v ./; \
	  cp -rf $(CDN_DEMO_RTL_PATH)/common/edma_params.v ./; \
	fi;

#---------------------------------------
# ipxact: convert RDL into xml (DUT
# registers).
#---------------------------------------
ipxact: $(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs/reg_models/$(DESIGN)_$(CONFIG).xml
$(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs/reg_models/$(DESIGN)_$(CONFIG).xml:
	@echo Cannot find $(DESIGN)_$(CONFIG).xml in ./cfg_gen_pkg/fixed_cfgs/reg_models, so generating it from RDL.
	@rm -rf ./$(DESIGN)_$(CONFIG).rdl
	@rm -rf ./$(DESIGN)_$(CONFIG).xml
	@cp $(MODULE_PATH)/private/rdl/$(DESIGN)/*.rdl .
	@$(MODULE_PATH)/private/scripts/create_rdl.rb --inputDefs ./$(DESIGN)_defs.v --outputDir ./temp/ --only_gen_rdl --releaseFlow
	@mv ./temp/emac.rdl ./$(DESIGN)_$(CONFIG).rdl
	@rm -rf ./temp
	@$(MAKE) -f $(MODULE_PATH)/models/rdl/Makefile clean ipxact RDL_DIR="${PWD}" RDL_TOP_FILE_NAME="$(DESIGN)_$(CONFIG)"
	@if [ $(RANDOM_CONFIG) = 0 ]; then \
	  mv ./$(DESIGN)_$(CONFIG).rdl $(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs/reg_models/; \
	  mv ./$(DESIGN)_$(CONFIG).xml $(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs/reg_models/; \
	fi

#---------------------------------------
# svregs: convert xml into UVM_REG model
# (DUT registers).
#---------------------------------------
svregs: $(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs/reg_models/$(DESIGN)_$(CONFIG).sv
$(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs/reg_models/$(DESIGN)_$(CONFIG).sv:
	@if [ $(RANDOM_CONFIG) = 0 ]; then \
	  cp $(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs/reg_models/$(DESIGN)_$(CONFIG).xml ./; \
	fi
	@rm -rf ./$(DESIGN)_$(CONFIG).sv
	@$(MAKE) -f $(MODULE_PATH)/models/rdl/Makefile svregs RDL_DIR="${PWD}" RDL_TOP_FILE_NAME="$(DESIGN)_$(CONFIG)"
	@mv ./$(DESIGN)_$(CONFIG).sv ./gem_regmodel.sv
	@if [ $(RANDOM_CONFIG) = 0 ]; then \
	  mv ./gem_regmodel.sv $(MODULE_PATH)/work/cfg_gen_pkg/fixed_cfgs/reg_models/$(DESIGN)_$(CONFIG).sv; \
	fi

#---------------------------------------
# protocol_setup: creates all the setup 
# files needed for the DUT (defs, .f,
# uvm_reg file).
#---------------------------------------
.PHONY: protocol_setup
protocol_setup: denali create_defs ipxact svregs
  ifeq ($(RANDOM_CONFIG), 0)
	  @cp $(MODULE_CONFIG_PATH)/reg_models/$(DESIGN)_$(CONFIG).sv ./gem_regmodel.sv
  endif

#---------------------------------------
# rr: runs tests contained in RLIST.
#---------------------------------------
.PHONY: rr
rr:
  ifeq ($(RLIST),)
	  @echo "********************************************************************";
	  @echo "Target \"rr\" cannot run without arguments.";
	  @echo "Please, call one of the local regressions or insert a list of test:";
	  @echo "  make rr RLIST=\"<test_name_1> <test_name_2> ...\"";
	  @echo "To run a local regression, read the help first:";
	  @echo "  make help";
	  @echo "********************************************************************";
  else
	  @rm -rf $(REGRESSION).results;
	  @touch $(REGRESSION).results;
	  @$(foreach test,$(RLIST), \
	    $(MAKE) -f $(MAKE_LOC)/Makefile run TEST=$(test); \
	    wait $!; \
	    if [ -a denali.his ]; then cp denali.his denali_$(test).his; fi; \
	    if [ -a denali.trc ]; then cp denali.trc denali_$(test).trc; fi; \
	    $(VM_DIR)/check_for_pass.pl $(test) >> $(REGRESSION).results;)
  endif

#---------------------------------------
# regression_uvm_reg: standalone
# regression of UVM_REG tests.
#---------------------------------------
.PHONY: regression_uvm_reg
regression_uvm_reg:
	$(eval RLIST := $(TESTS_UVM_REG))
	$(MAKE) -f $(MAKE_LOC)/Makefile rr RLIST="$(RLIST)" REGRESSION=regression_uvm_reg

#---------------------------------------
# regression_uvm: standalone regression 
# of UVM tests.
#---------------------------------------
.PHONY: regression_uvm
regression_uvm:
	$(eval RLIST := $(TESTS_UVM))
	$(MAKE) -f $(MAKE_LOC)/Makefile rr RLIST="$(RLIST)" REGRESSION=regression_uvm

#---------------------------------------
# regression_c: standalone regression 
# of C tests.
#---------------------------------------
# Group regressions
.PHONY: regression_c
regression_c:
	$(eval RLIST := $(TESTS_C))
	$(MAKE) -f $(MAKE_LOC)/Makefile rr RLIST="$(RLIST)" REGRESSION=regression_c

#---------------------------------------
# regression: standalone regression of 
# all tests.
#---------------------------------------
.PHONY: regression
regression:
	$(eval RLIST := $(TESTS_GLOBAL))
	$(MAKE) -f $(MAKE_LOC)/Makefile rr RLIST="$(RLIST)" REGRESSION=regression

#-------------------------------------------------------------------------------
# END OF FILE
#-------------------------------------------------------------------------------

