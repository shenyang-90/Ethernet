#!/bin/csh
#------------------------------------------------------------------------------
#                                     
#            CADENCE                    Copyright (c) 2002-2015
#                                       Cadence Design Systems, Inc.
#                                       All rights reserved.
#
#  This work may not be copied, modified, re-published, uploaded, executed, or
#  distributed in any way, in any medium, whether in whole or in part, without
#  prior written permission from Cadence Design Systems, Inc.
#------------------------------------------------------------------------------
#
#    Primary Unit Name :      create_tech_cpf.csh.csh
#
#          Description :      Conformal Low Power Runscript
#
#      Original Author :      Patrick McKeever 
#
#------------------------------------------------------------------------------
source ./setup_project.csh

$LSF lec -verify -lp -nogui -dofile $IPF_DESIGN_FLOW_SCRIPTS/clp/create_tech_cpf.do
