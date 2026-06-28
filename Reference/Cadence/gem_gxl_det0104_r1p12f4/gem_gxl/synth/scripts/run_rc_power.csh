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
#    Primary Unit Name :      run_rc_power.csh
#
#          Description :      RC power runscript
#
#      Original Author :      Patrick McKeever 
#
#------------------------------------------------------------------------------
source ./setup_project.csh


$LSF genus -legacy_ui -files $IPF_DESIGN_FLOW_SCRIPTS/rc/rc_power.tcl -nogui -post quit -E
