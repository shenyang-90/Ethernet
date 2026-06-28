#------------------------------------------------------------------------------
# File      : Makefile
# Author    : Dr. John S. MacBeth (Cadence Design Systems).
# Description : Simple Makefile
#------------------------------------------------------------------------------
# Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
#------------------------------------------------------------------------------


#--------------------------------------------------------------------
# SHELL
#-------
# Shell commands in this Makefile use tcsh syntax, so this is the
#SHELL = /bin/tcsh
#--------------------------------------------------------------------


#--------------------------------------------------------------------
# SOURCE
#--------
# Points to the source directory.
SOURCE_SV_DIR       = ${PWD}/../sv
SOURCE_SV_TEST_DIR  = ${PWD}
SOURCE_HDL_TB  = ${PWD}/cdn_clock_example_top.sv
TEST_NAME = cdn_clock_basic_test
#--------------------------------------------------------------------


#--------------------------------------------------------------------
# Top level name of the testbench/unit to simulate
#--------------------------------------------------------------------
TOP_LEVEL_TB_NAME = cdn_clock_tb

#--------------------------------------------------------------------
#--------------------------------------------------------------------
# TARGETS
#--------------------------------------------------------------------
#--------------------------------------------------------------------
targets:
	echo "Availible targets : " clean, run, run_i, cov

#--------------------------------------------------------------------
# TARGET : clean
#--------------------------------------------------------------------
clean :
	rm -rf INCA_libs
	rm -rf .simvision
	rm -rf waves.shm
	rm -rf html
	rm -rf cov_work
	rm -f *.ucd
	rm -f *.html
	rm -f *.ucm
	rm -f *.log
	rm -f *.elog
	rm -f *.key
	rm -f *~

#--------------------------------------------------------------------
# TARGET : run_i
#--------------------------------------------------------------------
run_i:
	irun \
		-top $(TOP_LEVEL_TB_NAME) \
		$(SOURCE_HDL_TB) \
		-access +rwc \
		-uvm \
		+UVM_TESTNAME=$(TEST_NAME) \
		+incdir+$(SOURCE_SV_DIR) \
		-coverage all \
		-covoverwrite \
		-gui 

#--------------------------------------------------------------------
# TARGET : run
#--------------------------------------------------------------------
run:
	irun \
		-top $(TOP_LEVEL_TB_NAME) \
		$(SOURCE_HDL_TB) \
		-access +rwc \
		-uvm \
		+UVM_TESTNAME=$(TEST_NAME) \
		+incdir+$(SOURCE_SV_DIR) \
		-coverage all \
		-covoverwrite

#--------------------------------------------------------------------
# TARGET : cov
#--------------------------------------------------------------------
cov:
	iccr -test $(PWD)/cov_work/design/test/ -GUI

#--------------------------------------------------------------------
# TARGET : lint
#--------------------------------------------------------------------
lint:
	irun \
		-top $(TOP_LEVEL_TB_NAME) \
		$(SOURCE_HDL_TB) \
		-access +rwc \
		-uvm \
		+UVM_TESTNAME=$(TEST_NAME) \
		+incdir+$(SOURCE_SV_DIR) \
		-hal \
		-gui 

#--------------------------------------------------------------------
# END OF FILE
#--------------------------------------------------------------------

