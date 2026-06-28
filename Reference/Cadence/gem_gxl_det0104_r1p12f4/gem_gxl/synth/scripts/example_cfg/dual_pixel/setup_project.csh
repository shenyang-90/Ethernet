#!/bin/csh
#------------------------------------------------------------------------------
#                                     
#            CADENCE                    Copyright (c) 2002-2014
#                                       Cadence Design Systems, Inc.
#                                       All rights reserved.
#
#  This work may not be copied, modified, re-published, uploaded, executed, or
#  distributed in any way, in any medium, whether in whole or in part, without
#  prior written permission from Cadence Design Systems, Inc.
#------------------------------------------------------------------------------
#
#    Primary Unit Name :      setup_project_template.csh
#
#          Description :      Template Project environment variable setup
#
#      Original Author :      Colin Scott 
#
#------------------------------------------------------------------------------

setenv RTLDesignFlow_VERSION 4.0

unsetenv STATICS_FILE
unsetenv NL_TOGGLE_FILE_DIR
unsetenv STAMP
unsetenv IPF_DESIGN_FLOW_SCRIPTS
unsetenv ATPG_OTHER_MODULES
unsetenv DFT_ABSTRACT_MODEL
unsetenv DEFINEMACRO
unsetenv LSF
unsetenv DELIVERY_TAG
unsetenv TECHNOLOGY
unsetenv DESIGN
unsetenv KEEP_PATHS
unsetenv BLACKBOXES
unsetenv HDL_SEARCH_PATH
unsetenv POWER_INTENT_FILE
unsetenv SPYGLASS_PACK_LOCATION
unsetenv COMPILATION_CHECK_RPT

###################################################################################################
## Identifies target technology, used by tech_lib_setup.tcl.
################################################################################
  setenv TECHNOLOGY TSMC28HPM_9T

################################################################################
## Top level name of the target design.
################################################################################
  setenv PREFIX ""
  setenv DESIGN ${PREFIX}csi2tx_toplevel

################################################################################
## Setup paths dependent on execution in Stork or 
## development area 
## Identifies the root directory of the design or configuration.
## Absolute path is recomended.  Relative path not fully tested 
################################################################################

  if (! $?STORK_DELIVERY) then 
    echo "Running internal IP directory structure flow"
    setenv DUT_PATH $MIPI_CSI2TX_CTRL_INSTALL_DIR
    setenv CFG_DIR "$DUT_PATH/cfg"     
  else
    echo "Running Stork based directory structure flow"
    setenv DUT_PATH <e.g $MIPI_CSI2TX_CTRL_INSTALL_DIR or /project/design...>
    setenv CFG_DIR "$DUT_PATH/hdl_qc/cfg"
  endif


################################################################################
## Design modes to be optimised, valid combinations are below
################################################################################
  setenv DESIGN_MODES "func"
#setenv DESIGN_MODES "func scan_shift scan_capture at_speed"
#setenv DESIGN_MODES "func scan"


################################################################################
## Identifies the name of the target design configuration.
## Used as suffix in result directories and file names,
## to differentiate between multiple IP configurations.
## (Optional, nothing will be used in its place)
################################################################################
  setenv CONFIG "dual_pixel"


################################################################################
## Provide path to logfiles 
## (used in conjunction with /setup/setup_dirs.tcl).
## If not defined the DUT_PATH will be used.
################################################################################
  setenv LOG_PATH $DUT_PATH

################################################################################
## Identifies RTL root directory
################################################################################
  if (! $?STORK_DELIVERY) then
    setenv RTL_PATH $DUT_PATH/rtl
  else
    setenv RTL_PATH $DUT_PATH/hdl/hdl_src
  endif


################################################################################
## List of RTL filelists.
## This can be mix of VHDL, Verilog and System Verilog.
## This is expected to contain only the filelists and no other
## elements such as `defines
## E.G set RTL_F_FILELIST = (First_list.f \
##                           second_list.f)
##
################################################################################

  set RTL_F_FILELIST = (${RTL_PATH}/csi2tx_toplevel.f)

################################################################################
## Retain the same paths that are in the proivded .f files.
##  0 == replace with full paths in the expanded.f (default)
################################################################################
  setenv KEEP_PATHS 0


################################################################################
## Identifies search paths for RTL include files
## E.g. setenv HDL_SEARCH_PATH   "${RTL_PATH} Other_paths1 Other_paths2"
################################################################################
  setenv HDL_SEARCH_PATH   "${RTL_PATH}"


################################################################################
## The CPF/1801 file for lp implementation should be defined here if it exists
################################################################################
#  setenv POWER_INTENT_FILE $IPF_DESIGN_FLOW_SCRIPTS/cpf/project.cpf
  
################################################################################
## set the SDC Constraint file(s)
################################################################################
  setenv SDC_PATH "$CFG_DIR/$CONFIG/constraints"


################################################################################
## set the location of a statics file if available
## adding statics can reduce CDC noise in reports
################################################################################
  setenv STATICS_FILE      $CFG_DIR/${CONFIG}/statics/statics_default


################################################################################
## path to directory where all power state tcf/saif dirs are
################################################################################
#  setenv NL_TOGGLE_FILE_DIR <path>
#  setenv RTL_TOGGLE_FILE_DIR <path>

################################################################################
## Identifies an arbitrary tagname of the current run through the flow.
## Output files for each tool will be created within a $STAMP directory.
## Can be used to prevent overwriting of results from a previous run.
## Optional, if not set SVN version will be used
################################################################################
  setenv STAMP RDF4.0_final


################################################################################
## Identifies the path to the checked out IPF Design Flow scripts.
## 
################################################################################

  if (! $?STORK_DELIVERY) then
    setenv IPF_DESIGN_FLOW_SCRIPTS /projects/rtldesignflow/work/mlewis/scripts_trunk/release_flow/scripts
  else
    setenv IPF_DESIGN_FLOW_SCRIPTS $DUT_PATH/synth/script
  endif

################################################################################
## A comma-separated list of any additional netlist files required
## for ATPG, e.g. interface-only stub files.
## (Optional)
################################################################################
  setenv ATPG_OTHER_MODULES ""


################################################################################
## describes pre-existing scanchains inside hard IP
## Comment out if not required
################################################################################
#  setenv DFT_ABSTRACT_MODEL <scan_abstract_file_or_ctl>


################################################################################
## if -defines are required for hard macros
################################################################################
  setenv DEFINEMACRO ""

################################################################################
## Blackboxes - List any instances to be blackboxed in CCD, Superlint and Spyglass
##  setenv BLACKBOXES "csi2tx_ctrl_reg csi2tx_protocol"
## comment out if not required
################################################################################
#   setenv BLACKBOXES "<space separated list of modules>"

################################################################################
## if a local TDR file is required, specify the location here
## default is set automatically by ET to $env(Install_Dir)/defaults/rules/tdr
################################################################################
#  setenv TDRPATH <define location to local tdr e.g "$CFG_DIR/${CONFIG}/dft/">


################################################################################
## set default values to svn revision for the variables if not explicitly set
################################################################################
  if (! $?STAMP)     setenv STAMP  svn-r`svn info $RTL_PATH |grep '^Revision:' | sed -e 's/^Revision: //'`
  if ($STAMP == "")  setenv STAMP  svn-r`svn info $RTL_PATH |grep '^Revision:' | sed -e 's/^Revision: //'`


################################################################################
## Using or not LSF
## (e.g. setenv LSF "bsub -Is")
## If using multi threading do not use the interactive queue. 
## Use a queue that will support the number of jobs you want to run.
## (Optional, if undefined will default to "" i.e not using LSF)
################################################################################
#  setenv MTHREAD_QUEUE <lsf queue>
  setenv LSF "bsub -Is"


################################################################################
# Define TAG name to run checks on prior to customer delivery
################################################################################
#  setenv DELIVERY_TAG <delivery_tag>


################################################################################
# Select Spyglass output directory for packed reports
################################################################################
  setenv SPYGLASS_PACK_LOCATION $DUT_PATH/spyglass/${CONFIG}

################################################################################
#  Generate Filelists
################################################################################

  source ${IPF_DESIGN_FLOW_SCRIPTS}/setup/filelist_setup.csh
  setenv RTL_F_FILE "./expanded.f"   

################################################################################
