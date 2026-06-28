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
#    Primary Unit Name :      tech_lib_setup.tcl
#
#          Description :      Library setup script called by project.tcl
#
#      Original Author :      Anna Gilbert
#
#------------------------------------------------------------------------------

#NB the referenced path below would possibly need to be modified, as appropriate to the location of the master tech_lib_setup.tcl 
#depending on your site
#the "local" tech_lib_setup.tcl file can be modified to include references to non-standard libraries, to meet customer-specific requirements.

# source /process/tsmc/library_setup/tech_lib_setup.tcl

#  Comment out above and use the following file as a template to understand the variables that
#  need to be set up to use the delivered synthesis scripts.
source ./tech_lib_28nm.tcl
