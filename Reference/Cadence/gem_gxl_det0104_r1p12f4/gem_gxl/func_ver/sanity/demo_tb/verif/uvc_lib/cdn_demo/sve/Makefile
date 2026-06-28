#------------------------------------------------------------------------------
# File      : Makefile
# Author    : Cadence
# Description : Simple Makefile
#------------------------------------------------------------------------------
# Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
#------------------------------------------------------------------------------

#--------------------------------------------------------------------
# CMDLINE ARGS
#--------------------------------------------------------------------

CDN_VIP_LIB_PATH ?= ./cdn_vip_lib
TEST ?= cdn_demo_base_test
UVM_VERBOSITY?=UVM_LOW
SEED?=1
COV?=1
ARGS?=
PHY=?=USB_SIERRA_SD0301M_T16FFC
CDN_DEMO_SW_PATH_OVERRIDE ?=
CDN_DEMO_RTL_PATH_OVERRIDE ?=
CDN_DEMO_PHY_PATH_OVERRIDE ?=
CDN_DEMO_TB_PATH_OVERRIDE ?=
CDN_DEMO_DUT_LIB_PATH ?= ./cdn_dut_lib
CDN_DEMO_VERIF_LIB_PATH ?= ./cdn_verif_lib
ENV_PATH_DISABLE_CHECK ?= 0

#--------------------------------------------------------------------
# CDN_DEMO_PATH Root Location
#--------------------------------------------------------------------

# Determine the CDN_DEMO_PATH root location
ifeq ($(CDN_DEMO_TB_PATH_OVERRIDE),)
  MAKE_LOC := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
  CDN_DEMO_PATH := $(abspath ${MAKE_LOC}/../../../../)
else
  MAKE_LOC := $(CDN_DEMO_TB_PATH_OVERRIDE)/verif/uvc_lib/cdn_demo/sve
  CDN_DEMO_PATH := $(CDN_DEMO_TB_PATH_OVERRIDE)
endif

export CDN_DEMO_PATH

#--------------------------------------------------------------------
# VIP/Tool Library setup
#--------------------------------------------------------------------

# Add the locally compiled VIP paths to library paths.
# Additionally setup the tool paths. This may have been done in the
# sourceme.csh but if it hasn't then it is setup here.
CDS_ARCH ?= lnx86
SPECMAN_PATH    := ${CDN_VIP_LIB_PATH}/64bit:${SPECMAN_PATH}
LD_LIBRARY_PATH := ${CDN_VIP_LIB_PATH}/64bit:${LD_LIBRARY_PATH}
IUS_HOME := $(shell ncroot)
PATH := ${IUS_HOME}/tools.${CDS_ARCH}/bin:${PATH}
LD_LIBRARY_PATH := ${DENALI}/verilog:${IUS_HOME}/tools.${CDS_ARCH}/specman/lib/64bit:${IUS_HOME}/tools.${CDS_ARCH}/lib/64bit:${LD_LIBRARY_PATH}

export SPECMAN_PATH
export LD_LIBRARY_PATH
export PATH

VIP_BASE_ARGS := \
   -define DENALI_UVM \
   -define DENALI_SV_NC \
   -mess \
   -define CDN_AUTO_TEST \
   -incdir ${DENALI}//ddvapi/sv \
   ${DENALI}/ddvapi/sv/denaliMem.sv \
   -define CDN_APB_VIP_NUM_OF_SLAVES=2 \
   ${DENALI}/ddvapi/sv/denaliCdn_apb.sv \
   -incdir ${DENALI}/ddvapi/sv/uvm/cdn_apb \
   ${DENALI}/ddvapi/sv/uvm/cdn_apb/cdnApbUvmTop.sv \
   -incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_apb_vip/sv/ \
   $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_apb_vip/sv/cdn_apb_vip_pkg.sv \
   -incdir ${DENALI}/ddvapi/sv/hdl_interfaces/cdn_apb \
   ${DENALI}/ddvapi/sv/denaliCdn_axi.sv \
   -incdir ${DENALI}/ddvapi/sv/uvm/cdn_axi \
   ${DENALI}/ddvapi/sv/uvm/cdn_axi/cdnAxiUvmTop.sv \
   -incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_axi_vip/sv/ \
   $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_axi_vip/sv/cdn_axi_vip_pkg.sv \
   ${CDN_VIP_LIB_PATH}/64bit/ncsim_psui.sv

VIP_RUN_ARGS := \
   -top specman \
   -top specman_wave \
   -snprerun notest \
   -snnoauto \
   -loadvpi ${DENALI}/verilog/libcdnsv.so:cdnsvVIP:export \
   -ncsimargs "-loadrun ${CDN_VIP_LIB_PATH}/64bit/libcdnvipcuvm.so" \

#--------------------------------------------------------------------
# General Setup
#--------------------------------------------------------------------

TOP_LEVEL_TB_NAME := cdn_demo_tb
WAVES_TCL := ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/sve/waves.tcl
STARTUP_TCL := ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/sve/startup.tcl
IDA_TCL := ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/sve/ida.tcl
RUN_TCL := ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/sve/run.tcl
FARM_VSIF:=/grid/scp/hw/apps/emanager_lsf_setup/farm_default_rh6.vsif
VM_DIR := $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo/vm/
IRUN_BASE_ARGS+=
IRUN_BASE_RUN_ARGS+=
IRUN_VERIF_BASE_ARGS+=
IRUN_VERIF_SRC+=
IRUN_VERIF_RUN_ARGS+=

#--------------------------------------------------------------------
# RTL Setup.
# Note. The RTL_SRC variable should be set in the config.mk file and
# the variables are added here as a placeholder to ensure consistency.
#--------------------------------------------------------------------

RTL_SRC +=
IRUN_RTL_BASE_ARGS +=

#--------------------------------------------------------------------
# C Specific Args - all C tests have the prefix
# cdn_<protocol>_demo_c_<test_name>_test.c. The test name is therefore
# parsed to determine if a C test is running, and if this is the case
# then the additional IRUN_C_???_ARGS are set. Otherwise no C structures
# are compiled.
#--------------------------------------------------------------------
TEST_TITLE := $(TEST)
UVM_TESTNAME := $(TEST)
IRUN_C_BASE_ARGS += 
IRUN_C_COMPILE_ARGS += 
ifneq ($(findstring _demo_c_, $(TEST)),)
  C_TEST := 1
endif
ifeq ($(C_TEST),1)
  TEST_TITLE := $(TEST)
  UVM_TESTNAME := cdn_demo_base_test
  IRUN_C_BASE_ARGS += \
    +define+CDN_DEMO_C
  IRUN_C_COMPILE_ARGS := \
		$(IRUN_C_BASE_ARGS) \
    -Wcc -std=c99 \
    -I${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/c/ \
    -I${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/sve/tests_c/ \
    -I. \
    -DCDN_DEMO_TB \
    -DDEBUG \
    -DCDN_DEMO_C \
    -Dprintf=vpi_printf \
    $(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/sve/tests_c/$(TEST_TITLE).c) \
    $(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/c/*.c)
endif

#--------------------------------------------------------------------
# PROTOCOL Specific Args
#--------------------------------------------------------------------

PROTOCOL_SETUP_TARGET +=

PROTOCOL_CLEAN_TARGET +=

# Specify the protocol vip that should be compiled, such as
# PROTOCOL_VIP := enet
PROTOCOL_VIP := ""

# This option can add specific protocol options to the help file
PROTOCOL_HELP := ""

# Top level pkg for the protocol verification environment. Typical examples is as follows
#PROTOCOL_PKG += "$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_sd4hc_demo/sv/cdn_sd4hc_demo_pkg.sv"
PROTOCOL_PKG += 

# This variable is unlikely to change and allows the user to change the location
# of the doxygen tests. The Doxygen file then picks up this variable for the
# source files
DOCS_DOXYGEN_SRC := $(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/*/sve/tests_c/*)
DOCS_DOXYGEN_SRC += $(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/*/tests_c/*)

# Check if we have a protocol specific config.mk. If there is not a protocol specific
# config.mk then this is just a demoTB template run so include the example rdl_integration
# config.mk file
ifneq ($(wildcard $(MAKE_LOC)/../../*/*/config.mk),)
   include $(MAKE_LOC)/../../*/*/config.mk
   PROTOCOL_SETUP_TARGET := protocol_setup
# demoTB template run only - include the rdl_ram_integration specific config.mk
else
   include $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/sve/config.rdl_ram_integration.mk
endif

# The following file is used to extend the natural docs menu file
NATURAL_DOCS_MENU_PROTOCOL := $(CDN_DEMO_PATH)/verif/uvc_lib/*/*/natural_docs_menu_protocol.txt

#--------------------------------------------------------------------
# Get the root working directory and the roots for the SW, PHY and
# RTL directories
#
# The variables below define the root location for the SW, PHY and
# RTL directories. These variables can be set at the Makefile call beforehand
# if the SW, PHY or RTL directories are not located in a "Cadence
# internal" directory or located in a "delivery package" directory.
# The following 3 steps are taken to determine the source of the PHY, RTL
# and SW directories.
#   1) Override is set via the Makefile call
#   2) "Cadence internal use" directory
#   3) "Delivery Package" directory
# If none of the above 3 locations contain the appropriate files then
# an error is raised.
# In addition,a key concept is that no environment variables need to be set in the
# sourceme.csh to define any of these paths, as the when the Makefile is called
# the path to the Makefile can be determined and the root of the tree can be
# derived from this Makefile location (see MAKE_LOC & CDN_DEMO_PATH variables for the example). This
# however only applies to files located in 2) or 3) and the variables
# should be set in advance at the Makefile call if the SW, PHY or RTL
# directories are in a customer specific area - ie. not locations 2) or 3).
#
# - SW - $(CDN_DEMO_SW_PATH_OVERRIDE) Variable
#   1) - Set via Makefile call
#   2) - $(CDN_DEMO_PATH)/sw                - Cadence internal use
#   3) - $(CDN_DEMO_PATH)/../../software    - Delivery Package
# - RTL - $(CDN_DEMO_RTL_PATH_OVERRIDE) Variable
#   1) - Set via Makefile call
#   2) - $(CDN_DEMO_PATH)/sw                - Cadence internal use
#   3) - $(CDN_DEMO_PATH)/../../hdl/hdl_src - Delivery Package
# - PHY - $(CDN_DEMO_PHY_PATH_OVERRIDE) Variable
#   1) - Set via Makefile call
#   2) - $(CDN_DEMO_PATH)/$(PHY)            - Cadence internal use
#   3) - $(CDN_DEMO_PATH)/$(PHY)            - Delivery Package
#
#--------------------------------------------------------------------

# Check to see if the SW override variable is set
ifeq ($(CDN_DEMO_SW_PATH_OVERRIDE),)
	# Determine if this is an internal Cadence run
	ifneq ($(wildcard $(CDN_DEMO_PATH)/sw),)
		CDN_DEMO_SW_PATH := $(CDN_DEMO_PATH)/sw/
	endif
	# Determine if this is a delivery run
	ifneq ($(wildcard $(CDN_DEMO_PATH)/../../../software),)
		CDN_DEMO_SW_PATH := $(CDN_DEMO_PATH)/../../../software/
	endif
else
	CDN_DEMO_SW_PATH := $(CDN_DEMO_SW_PATH_OVERRIDE)
	# Determine if the override variable has SW code
	ifeq ($(wildcard $(CDN_DEMO_SW_PATH)),)
		CDN_DEMO_SW_PATH =
	endif
endif

# Check to see if the RTL override variable is set
ifeq ($(CDN_DEMO_RTL_PATH_OVERRIDE),)
	# Determine if this is an internal Cadence run
	ifneq ($(wildcard $(CDN_DEMO_PATH)/rtl),)
		CDN_DEMO_RTL_PATH := $(CDN_DEMO_PATH)/rtl/
	endif
	# Determine if this is a delivery run
	ifneq ($(wildcard $(CDN_DEMO_PATH)/../../../hdl/hdl_src),)
		CDN_DEMO_RTL_PATH := $(CDN_DEMO_PATH)/../../../hdl/hdl_src/
	endif
else
  CDN_DEMO_RTL_PATH := $(CDN_DEMO_RTL_PATH_OVERRIDE)
	# Determine if the override variable has RTL code
	ifeq ($(wildcard $(CDN_DEMO_RTL_PATH)),)
		CDN_DEMO_RTL_PATH =
	endif
endif

# Check to see if the PHY override variable is set
ifeq ($(CDN_DEMO_PHY_PATH_OVERRIDE),)
	# Determine if this is an internal Cadence run
	ifneq ($(wildcard $(CDN_DEMO_PATH)/$(PHY)),)
		CDN_DEMO_PHY_PATH := $(CDN_DEMO_PATH)/$(PHY)/
	endif
	# Determine if this is a delivery run
	ifneq ($(wildcard $(CDN_DEMO_PATH)/../../../../$(PHY)),)
		CDN_DEMO_PHY_PATH := $(CDN_DEMO_PATH)/../../../../$(PHY)/
	endif
else
	CDN_DEMO_PHY_PATH := $(CDN_DEMO_PHY_PATH_OVERRIDE)
	# Determine if the override variable has PHY code
	ifeq ($(wildcard $(CDN_DEMO_PHY_PATH)),)
		CDN_DEMO_PHY_PATH =
	endif
endif

# Determine if the appropriate SW, PHY and RTL paths have found
# the necessary input files. If this is not the case then raise an error
ifneq ($(ENV_PATH_DISABLE_CHECK),1)
  ifeq ($(CDN_DEMO_SW_PATH),)
    $(error *E : CDN_DEMO_SW_PATH contains no source files. Please ensure the SW paths are set correctly)
  endif
endif
ifneq ($(ENV_PATH_DISABLE_CHECK),1)
  ifeq ($(CDN_DEMO_RTL_PATH),)
    $(error *E : CDN_DEMO_RTL_PATH contains no source files. Please ensure the RTL paths are set correctly)
  endif
endif
ifneq ($(ENV_PATH_DISABLE_CHECK),1)
  ifeq ($(CDN_DEMO_PHY_PATH),)
    $(error *E : CDN_DEMO_PHY_PATH contains no source files. Please ensure the PHY paths are set correctly)
  endif
endif


#--------------------------------------------------------------------
# IRUN ARGUMENTS
#--------------------------------------------------------------------

ifeq ($(COV), 1)
   IRUN_COV_ARGS += \
      -coverage all \
      -covoverwrite \
      -covfile ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/sve/coverage.tcl
else
   IRUN_COV_ARGS := ""
endif

IRUN_VERIF_SRC := \
	-incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_clock/sv/ \
	-incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_reset/sv/ \
	-incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo/sv \
	-incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo/sve \
	-incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo/sve/tests \
	-incdir $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/sve \
	$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_reset/sv/cdn_reset_pkg.sv \
	$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_clock/sv/cdn_clock_pkg.sv \
	$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo/sv/cdn_demo_pkg.sv \
	$(PROTOCOL_PKG) \
	$(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo/sve/cdn_demo_module_top.sv \

IRUN_BASE_ARGS += \
	-nowarn DSEMEL \
	-nowarn COVUCC \
	-nowarn COVDCL \
	-nowarn COVNSO \
	-nowarn COVUTA \
	-nowarn COVMDD \
	-nowarn CGPIDF \
	-64bit \
	-timescale "1ps/1ps" \
	-sntimescale "1ps/1ps" \
	-vlogext .vh \
	-access +rwc \
	-status \
	-errormax 1 \

IRUN_VERIF_BASE_ARGS += \
	-uvm \
	$(IRUN_VERIF_SRC) \
	-top $(TOP_LEVEL_TB_NAME) \

IRUN_VERIF_RUN_ARGS += \
	-seed   $(SEED) \
	-svseed   $(SEED) \
	-snseed   $(SEED) \
	+UVM_TESTNAME=$(UVM_TESTNAME) \
	+UVM_VERBOSITY=$(UVM_VERBOSITY) \
	-simvisargs "-title ${TEST_TITLE}"
	+UVM_MAX_QUIT_COUNT=1 \

IRUN_BASE_RUN_ARGS += \
	$(VIP_BASE_ARGS) \
	$(VIP_RUN_ARGS) \
	$(PROTOCOL_SPECIFIC_ARGS) \
	$(IRUN_BASE_ARGS) \
	$(IRUN_COV_ARGS) \


#--------------------------------------------------------------------
# TARGET : clean
#--------------------------------------------------------------------
.PHONY : clean 
clean : $(PROTOCOL_CLEAN_TARGET)
	rm -rf regressions
	rm -rf INCA_libs
	rm -rf naturaldoc_project_folder 
	rm -rf docs_nd
	rm -rf docs_doxygen
	rm -rf _Menu.txt
	rm -rf ida*
	rm -rf simvision*
	rm -rf irun*
	rm -rf .simvision
	rm -rf waves.shm
	rm -rf html
	rm -rf cov_work
	rm -f *.ucd
	rm -f *.ucm
	rm -f *.elog
	rm -f irun.log
	rm -f *.key
	rm -f *~
	rm -f run_*.results
	rm -rf cdn_dut_lib
	rm -rf cdn_verif_lib

#--------------------------------------------------------------------
# TARGET : clean_rdl
#--------------------------------------------------------------------
.PHONY : clean_rdl
clean_rdl :
	rm -f ipxact*
	rm -f *regs*.sv
	rm -f *addr*.h
	rm -f *addr*.*v*
	rm -f *addr*.c
	rm -f *diag*.c
	rm -f *reg*.h
	rm -f *.xml
	rm -f *.html
	rm -f *.rtf
	rm -f *.css
	rm -f bitwise.*bak*
	rm -f Glue.log
	rm -f sim_file.log
	rm -f bitwise.bitwise
	rm -f Generator.log
	rm -f CLI.log
	rm -f jspecview.log


#--------------------------------------------------------------------
# TARGET : clean_vip
#--------------------------------------------------------------------
.PHONY :  clean_vip
clean_vip:
	rm -rf $(CDN_VIP_LIB_PATH)
	rm -rf *vip*.csh

#--------------------------------------------------------------------
# TARGET : scrub
#--------------------------------------------------------------------
.PHONY : scrub
scrub : clean clean_rdl clean_vip

#--------------------------------------------------------------------
# TARGET : tests - show available tests
#--------------------------------------------------------------------
ifneq ($(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/*/sve/tests/*est.sv),)
  TESTS += $(shell ls -1 ${CDN_DEMO_PATH}/verif/uvc_lib/*/sve/tests/*est.sv | sed 's/\.sv//' | sed 's/.*\///')
endif
ifneq ($(wildcard ${CDN_DEMO_PATH}/verif/uvc_lib/*/sve/tests_c/*est.c),)
  TESTS += $(shell ls -1 ${CDN_DEMO_PATH}/verif/uvc_lib/*/sve/tests_c/*est.c | sed 's/\.c//' | sed 's/.*\///')
endif
.PHONY: tests
tests:
	@$(foreach test,$(TESTS),echo "$(test)";)

#--------------------------------------------------------------------
# TARGET : docs
# This target uses NaturalDocs and Doxygen to make HTML documentation.
# The flow here is slightly strange as NaturalDocs is effectively run
# twice. The Menu.txt support in NaturalDocs is cumbersome and it was
# not easy (and we did try) to generate the file list automatically.
# We therefore let NaturalDocs generate the file list and then copy
# this file list to our own Menu.txt file.
#--------------------------------------------------------------------
.PHONY: docs_natural
docs_natural:
	-@rm -rf ./naturaldoc_project_folder
	@mkdir ./naturaldoc_project_folder
	@cp ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/docs/natural_docs_topics.txt ./naturaldoc_project_folder/Topics.txt
	@cp ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/docs/natural_docs_menu.txt ./naturaldoc_project_folder/Menu.txt
	@cat ${NATURAL_DOCS_MENU_PROTOCOL} >> ./naturaldoc_project_folder/Menu.txt
	@rm -rf ./docs_nd
	@mkdir ./docs_nd
	@NaturalDocs --no-auto-group -i ${CDN_DEMO_PATH}/verif/uvc_lib/ -o HTML ./docs_nd -p ./naturaldoc_project_folder --documented-only
	@cp ./naturaldoc_project_folder/Menu.txt _Menu.txt
	@rm -rf ./naturaldoc_project_folder
	@mkdir ./naturaldoc_project_folder
	@cp ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/docs/natural_docs_topics.txt ./naturaldoc_project_folder/Topics.txt
	@cp ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/docs/natural_docs_menu.txt ./naturaldoc_project_folder/Menu.txt
	@cat ${NATURAL_DOCS_MENU_PROTOCOL} >> ./naturaldoc_project_folder/Menu.txt
	@rm -rf ./docs_nd
	@mkdir ./docs_nd
	@echo "Group: Files  {" >> ./naturaldoc_project_folder/Menu.txt
	@grep "^File" _Menu.txt >> ./naturaldoc_project_folder/Menu.txt
	@echo "   }  # Group: Files" >> ./naturaldoc_project_folder/Menu.txt
	@rm -f _Menu.txt
	@NaturalDocs --no-auto-group -i ${CDN_DEMO_PATH}/verif/uvc_lib/ -o HTML ./docs_nd -p ./naturaldoc_project_folder --documented-only
	-@rm -rf ./naturaldoc_project_folder


export DOCS_DOXYGEN_SRC
.PHONY: docs_doxygen
docs_doxygen:
	@rm -rf docs_doxygen
	@doxygen ${CDN_DEMO_PATH}/verif/uvc_lib/cdn_demo/docs/Doxyfile

docs: docs_doxygen docs_natural
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo "docs target complete:"
	@echo "Natural Docs Output : ./docs_nd/index.html"
	@echo "Doxygen Docs Output : ./docs_doxygen/index.html"
	@echo ""


#	@cp ${CDN_DEMO_PATH}/doc/natural_docs_menu.txt ./naturaldoc_project_folder/Menu.txt

#--------------------------------------------------------------------
# TARGET : vip
#--------------------------------------------------------------------

$(CDN_VIP_LIB_PATH):
	unset TMPDIR && ${CDN_VIP_ROOT}/bin/cdn_vip_setup_env \
	-cdn_vip_root ${CDN_VIP_ROOT} \
	-cdn_vip_lib ${CDN_VIP_LIB_PATH} \
	-sim ncsim_irun \
	-m sv_uvm \
	-csh \
	-v \
	-64 \
	-install "axi apb ${PROTOCOL_VIP}"

vip:$(CDN_VIP_LIB_PATH)

#--------------------------------------------------------------------
# TARGET : run_i
#--------------------------------------------------------------------
run_i : $(CDN_VIP_LIB_PATH) $(PROTOCOL_SETUP_TARGET) rdl_ram_integration
	irun \
		$(IRUN_BASE_RUN_ARGS) \
		$(IRUN_RTL_BASE_ARGS) \
		$(RTL_SRC) \
		$(IRUN_VERIF_BASE_ARGS) \
		$(IRUN_C_COMPILE_ARGS) \
		$(IRUN_VERIF_RUN_ARGS) \
		${ARGS} \
		-input ${WAVES_TCL} \
		-input ${RUN_TCL} \

#		-gui

#--------------------------------------------------------------------
# TARGET : run_debug
#--------------------------------------------------------------------
run_debug : $(CDN_VIP_LIB_PATH) $(PROTOCOL_SETUP_TARGET) rdl_ram_integration
	irun \
		$(IRUN_BASE_RUN_ARGS) \
		$(IRUN_RTL_BASE_ARGS) \
		$(RTL_SRC) \
		$(IRUN_VERIF_BASE_ARGS) \
		$(IRUN_C_COMPILE_ARGS) \
		$(IRUN_VERIF_RUN_ARGS) \
		${ARGS} \
		-input ${WAVES_TCL} \
		-input ${STARTUP_TCL} \
		-input ${IDA_TCL} \
		-uvmlinedebug \
		-linedebug \

#		-gui

#--------------------------------------------------------------------
# TARGET : run
#--------------------------------------------------------------------
run : $(CDN_VIP_LIB_PATH) $(PROTOCOL_SETUP_TARGET) rdl_ram_integration
	unset TMPDIR &&  irun \
		$(IRUN_BASE_RUN_ARGS) \
		$(IRUN_RTL_BASE_ARGS) \
		$(RTL_SRC) \
		$(IRUN_VERIF_BASE_ARGS) \
		$(IRUN_C_COMPILE_ARGS) \
		$(IRUN_VERIF_RUN_ARGS) \
		${ARGS} \

#--------------------------------------------------------------------
# TARGET : compile_dut
#--------------------------------------------------------------------
.PHONY : compile_dut 
compile_dut :
	@echo "[make] Compiling the DUT only..."
	irun \
		-compile \
		$(IRUN_BASE_ARGS) \
		$(IRUN_RTL_BASE_ARGS) \
		-makelib $(CDN_DEMO_DUT_LIB_PATH) \
		$(RTL_SRC) \
		-endlib \
		${ARGS}
	@echo "[make] Compilation of the DUT complete."

#--------------------------------------------------------------------
# TARGET : elab
#--------------------------------------------------------------------
.PHONY : elab
elab: 
	@echo "[make] Elaborating the DUT and DEMO TB together..."
	irun \
		$(IRUN_BASE_RUN_ARGS) \
		$(IRUN_RTL_BASE_ARGS) \
		$(IRUN_C_BASE_ARGS) \
		$(IRUN_VERIF_BASE_ARGS) \
		-reflib $(CDN_DEMO_DUT_LIB_PATH) \
		-elaborate \
		-nclibdirname $(CDN_DEMO_VERIF_LIB_PATH) \
		${ARGS}
	@echo "[make] Elaboration of the DUT and DEMO TB complete."

#--------------------------------------------------------------------
# TARGET : compile_c
#--------------------------------------------------------------------
# Compile C code to a local library, as each C test is compiled at
# run time. Unlike UVM where all tests are compiled using elab, C tests
# work slightly differently and each test is compiled per simulation run.
# The footprint for this additional C compile is tiny and play no
# significance to disk space of a regression.
.PHONY :
compile_c:
ifneq ($(C_TEST),)
	@echo "[make] Compile C infrastructure..."
	irun \
		-compile \
		$(IRUN_BASE_ARGS) \
		$(IRUN_COV_ARGS) \
		$(IRUN_C_COMPILE_ARGS) \
		${ARGS}
	@echo "[make] Compile C infrastrucutre complete."
endif

# If we are running a C test then we need to compile in the .so shared
# object file to allow the test to pull this in.
IRUN_C_RUN_ARGS +=
ifneq ($(C_TEST),)
  IRUN_C_RUN_ARGS = -ncsimargs " -loadrun
  IRUN_C_RUN_ARGS += $(wildcard ./INCA_libs/irun.lnx8664.15.20.nc/librun.so)
  IRUN_C_RUN_ARGS += "
endif

#--------------------------------------------------------------------
# TARGET : simulate
#--------------------------------------------------------------------
.PHONY : simulate
simulate:
	@echo "[make] Elaborating the DUT and DEMO TB together..."
	irun \
		$(IRUN_BASE_ARGS) \
		$(IRUN_COV_ARGS) \
		$(VIP_RUN_ARGS) \
		$(IRUN_VERIF_RUN_ARGS) \
		$(IRUN_C_RUN_ARGS) \
		-reflib $(CDN_VIP_LIB_PATH) \
		-reflib $(CDN_DEMO_DUT_LIB_PATH) \
		-reflib ./INCA_libs \
		-nclibdirname $(CDN_DEMO_VERIF_LIB_PATH) \
		-R \
		${ARGS}
	@echo "[make] Elaboration of the DUT and DEMO TB complete."
#--------------------------------------------------------------------
# TARGET : start_vm
#--------------------------------------------------------------------
.PHONY : start_vm
# Set up the farm vsif
LSF_PROJECT_STRING:=cdn_demo_tb
LICENSE_QUEUEING:=yes
export FARM_VSIF
export LSF_PROJECT_STRING

start_vm :
	emanager -64 -p "setup" &

#--------------------------------------------------------------------
# TARGET : rdl_ram_integration
#--------------------------------------------------------------------
# Build the uvm_regs and C headers
RDL_RAM_INTEGRATION_TOP := $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/cdn_ram_stub_regs_map.rdl
RDL_RAM_INTEGRATION_INPUT_DEPENDENCIES := \
  $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/cdn_ram_stub_regs.rdl \
  $(RDL_RAM_INTEGRATION_TOP)
RDL_RAM_INTEGRATION_OUTPUT_DEPENDENCIES := \
	cdn_ram_stub_regs_map.sv \
	cdn_ram_stub_addr_map.h \
	cdn_ram_stub_addr_map_macro.h

.PHONY : rdl_ram_integration
rdl_ram_integration : $(RDL_RAM_INTEGRATION_OUTPUT_DEPENDENCIES)
$(RDL_RAM_INTEGRATION_OUTPUT_DEPENDENCIES) : $(RDL_RAM_INTEGRATION_INPUT_DEPENDENCIES)
	if [ -a $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/sv/cdn_ram_stub_regs_map.sv ]; then \
	  echo "**** RAM INTEGRATION **** copying files from delivery path"; \
	  cp $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/sv/cdn_ram_stub_regs_map.sv     ./cdn_ram_stub_regs_map.sv; \
	  cp $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/c/cdn_ram_stub_addr_map.h       ./cdn_ram_stub_addr_map.h; \
	  cp $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/c/cdn_ram_stub_addr_map_macro.h ./cdn_ram_stub_addr_map_macro.h; \
	else \
	  echo "**** RAM INTEGRATION **** generate the xml"; \
	  $(TTI_IPXACT_TOOL_PATH)/ipxact_packager \
	    -xml_target_dir . \
	    -rdve_file_name tmp \
	    -rdl_file $(RDL_RAM_INTEGRATION_TOP); \
	  mv tmp_ipxact.xml cdn_ram_stub_regs_map_component.xml; \
	  echo "**** RAM INTEGRATION **** generate the UVM_REG model"; \
	  echo "[make] iregGen starting..."; \
	  iregGen -i cdn_ram_stub_regs_map_component.xml -o cdn_ram_stub_regs_map.sv -uvm11a; \
	  echo "[make] iregGen ending..."; \
	  echo "**** RAM INTEGRATION **** generate C headers"; \
	  echo "[make] Blueprint starting..."; \
	  blueprint \
	    -odir . \
	    -I $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/ \
	    -codegen $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/ansicdiag.codegen \
	    -ansicdiag \
	    -typeprefix CDN_DEMO_TB_RAM_INTEGRATION \
	    $(RDL_RAM_INTEGRATION_TOP); \
	  blueprint \
	    -odir . \
	    -I $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/ \
	    -codegen $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/ansicdiag.codegen \
	    -verilog -vh \
	    $(RDL_RAM_INTEGRATION_TOP); \
	  echo "[make] Blueprint ending..."; \
	fi;

#--------------------------------------------------------------------
# TARGET : rdl_ram_integration_docs
#--------------------------------------------------------------------
# Build the RDL RAM integration docs
.PHONY : rdl_ram_integration_docs
rdl_ram_integration_docs :
	@echo [make] Building html starting.... 
	socrates_cli --plugin bitwise \
		--path . \
		--new \
		--workarea bitwise \
		--import systemrdl_import \
		--file $(RDL_RAM_INTEGRATION_TOP) \
		--generate default_html \
		--component cdn_ram_stub_regs_map \
		--slavebusinterface s_1 \
		--output . 
	# Remove a redundant file
	-@rm *s_1*.html
	@echo [make] Building html ending...
	@echo [make] Building rtf starting.... 
	socrates_cli --plugin bitwise  \
		--path . \
		--new  \
		--workarea bitwise  \
		--import systemrdl_import  \
		--file $(RDL_RAM_INTEGRATION_TOP) \
		--generate default_rtf  \
		--component  cdn_ram_stub_regs_map \
		--slavebusinterface s_1  \
		--output . 
	# Doing some tidy up
	-@rm $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/log.txt
	-@rm $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/preprocessed*
	-@rm $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/rdl/systemrdl_importer.log
	@echo [make] Building rtf ending...

#--------------------------------------------------------------------
# TARGET : rdl_ram_integration_delivery
#--------------------------------------------------------------------
# Move the UVM_REG, C headers, IP-XACT and docs to the appropriate delivery
# directories, rather than being located within the current working
# directory
RDL_RAM_INTEGRATION_SV_REGS_DELIVERY_DIR := $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/sv
RDL_RAM_INTEGRATION_C_DELIVERY_DIR := $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/c
RDL_RAM_INTEGRATION_DOCS_DELIVERY_DIR := $(CDN_DEMO_PATH)/verif/uvc_lib/cdn_demo_ram_integration/docs
rdl_ram_integration_delivery :rdl_ram_integration_docs rdl_ram_integration
	@echo " [make] moving c headers into c delivery dir"
	@mv *.c $(RDL_RAM_INTEGRATION_C_DELIVERY_DIR)/.
	@mv *.h $(RDL_RAM_INTEGRATION_C_DELIVERY_DIR)/.
	@echo " [make] moving svregs into delivery dir"
	@mv  cdn_ram_stub_regs_map.sv $(RDL_RAM_INTEGRATION_SV_REGS_DELIVERY_DIR)/.
	@echo " [make] moving docs into delivery dir"
	@mv *.html *.rtf $(RDL_RAM_INTEGRATION_DOCS_DELIVERY_DIR)/.
	@echo " [make] Finished generation of files for SVN commit for release."


#--------------------------------------------------------------------
# TARGET : gen_regression_scripts - generates regression scripts from
# the vsif files associated with the target dut config.
#--------------------------------------------------------------------
.phony: gen_regression_scripts
gen_regression_scripts:
	@ls -1 $(VM_DIR) | grep ".vsif" | grep "cdn_.*demo_" | grep -i "regression" | xargs -t $(VM_DIR)/gen_standalone_regression_script.pl -vm_path=$(VM_DIR)

#--------------------------------------------------------------------
# TARGET : print_env - print the key environment variables
#--------------------------------------------------------------------
.phony: print_envs
print_envs:
	@echo "CDN_DEMO_PATH = $(CDN_DEMO_PATH)"
	@echo "CDN_DEMO_SW_PATH = $(CDN_DEMO_SW_PATH)"
	@echo "CDN_DEMO_PHY_PATH = $(CDN_DEMO_PHY_PATH)"
	@echo "CDN_DEMO_RTL_PATH = $(CDN_DEMO_RTL_PATH)"

#--------------------------------------------------------------------
# TARGET : echo - echo an argument to the command line
#--------------------------------------------------------------------
echo-% :
	@echo "$*=$($*)"

#--------------------------------------------------------------------
# TARGET : help - Some useful switches for debug.
#--------------------------------------------------------------------
help:
	@echo "-----------------------------------------------------------------------------------------------------"
	@echo "-- Cadence Demo TB simulation help"
	@echo "-----------------------------------------------------------------------------------------------------"
	@echo ""
	@echo " To compile and simulate : make <run_command> TEST=<testname> SEED=random "
	@echo ""
	@echo " Makefile targets :"
	@echo "         run        - Batch mode. No waves. For debug by logfile."
	@echo "         run_debug  - Batch mode. Waves + debug + medium verbosity. "
	@echo "         run_i      - Interactive (GUI) mode."
	@echo "         start_vm   - Start emanager for regression runs."
	@echo "         clean      - Remove all build files, including VIP"
	@echo "         compile_dut - Part of the 4 step flow - Compile the DUT only."
	@echo "         elab        - Part of the 4 step flow - Compile the TB and elaborate the design."
	@echo "         compile_c   - Part of the 4 step flow - Compile the C code only."
	@echo "         simulate    - Part of the 4 step flow - Simulate the design using the pre-eaborated libraries."
	@echo "         docs       - To make HTML documentation with the following formats:"
	@echo "                       - UVM/SV Tests/Infrastructure : NaturalDocs : Documentation in PWD/docs_nd"
	@echo "                       - C Tests                     : Doxygen     : Documentation in PWD/docs_doxygen"
	@echo "         tests      - Prints out a list of available tests."
	@echo "         echo-ARG   - Echo the value of ARG to the comand line."
	@echo "         print_envs - Print key environment variables - note. the echo- target can also be used to print any variable"
	@echo ""
	@echo " Optional Make switches :"
	@echo "         TEST=cdn_demo_base_test               - Specify the test to run (cdn_demo_base_test is the default)"
	@echo "         SEED=1                                - Specify seed (1 by default)"
	@echo "         CDN_VIP_LIB_PATH=cdn_vip_lib          - VIP Compile Directory (cdn_vip_lib is the default)"
	@echo "         CDN_DEMO_DUT_LIB_PATH=cdn_dut_lib     - DUT compile library - used with the compile_dut target"
	@echo "         CDN_DEMO_VERIF_LIB_PATH=cdn_verif_lib - VERIF compile library - used with the elab"
	@echo "         UVM_VERBOSITY=[UVM_NONE|UVM_LOW|UVM_MEDIUM|UVM_HIGH|UVM_DEBUG]"
	@echo "                                               - Enable appropriate UVM verbosity level. Default=UVM_LOW"
	@echo "         CDN_DEMO_TB_PATH_OVERRIDE             - Override default location of demo_tb"
	@echo "         CDN_DEMO_RTL_PATH_OVERRIDE            - Override default location of RTL code."
	@echo "         CDN_DEMO_SW_PATH_OVERRIDE             - Override default location of SW code."
	@echo "         CDN_DEMO_PHY_PATH_OVERRIDE            - Override default location of PHY code."
	@echo "         COV=1                                 - Enable or disable coverage collection. 1 : Enable. 0 : Disable."
	@echo "         PHY=                                  - Specify the name of the PHY. For example, USB_SIERRA_SD0301M_T16FFC"
	@echo "         ARGS=                                 - Pass arguments to the irun command. Surround in '' quotes"
	@echo "-----------------------------------------------------------------------------------------"
	@echo "- Regression Script Generation:"
	@echo "-----------------------------------------------------------------------------------------"
	@echo "  make gen_regression_scripts - Generates regression scripts (bash) from the vsif files"
	@echo "                                for the selected CONFIG."
	@echo "                                This target is for cusomters who do not use vManager."
	@echo "-----------------------------------------------------------------------------------------"
	@echo "$$PROTOCOL_HELP"
	@echo ""
	@echo "-----------------------------------------------------------------------------------------------------"


#--------------------------------------------------------------------
# END OF FILE
#--------------------------------------------------------------------
