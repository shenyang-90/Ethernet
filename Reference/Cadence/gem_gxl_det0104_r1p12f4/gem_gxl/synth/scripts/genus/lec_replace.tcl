#!/bin/tclsh
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
#    Primary Unit Name :      lec_replace.tcl
#
#          Description :      Ensures sim model is used for comparison  
#
#      Original Author :      Mark Lewis
#
#------------------------------------------------------------------------------

source ./project.tcl
puts "RTL Design Flow Version: $RTLDesignFlow_VERSION"
puts "  RDF SVN Revision Info: $RDF_SVN_INFO"

# Remove '-define SYNTHESIS' to ensure that RTL that uses this variable is not included and that the simulation model is instead used for
# comparison
exec perl -p -i -e "s/-define SYNTHESIS //g" ${_OUTPUTS_PATH}/rtl2mapped.lec.do
#exec perl -p -i -e "s/-define SYNTHESIS //g" ${_OUTPUTS_PATH}/rtl2final.lec.do
