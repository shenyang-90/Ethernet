#!/bin/csh
#------------------------------------------------------------------------------
#                                     
#            CADENCE                    Copyright (c) 2001-2015
#                                       Cadence Design Systems, Inc.
#                                       All rights reserved.
#
#  This work may not be copied, modified, re-published, uploaded, executed, or
#  distributed in any way, in any medium, whether in whole or in part, without
#  prior written permission from Cadence Design Systems, Inc.
#------------------------------------------------------------------------------
#
#    Primary Unit Name :      lec_replace_dofile.csh
#
#          Description :      Executes lec_replace
#
#      Original Author :      Mark Lewis
#
#------------------------------------------------------------------------------

#source ./setup_project.csh

tclsh $IPF_DESIGN_FLOW_SCRIPTS/genus/lec_replace.tcl

