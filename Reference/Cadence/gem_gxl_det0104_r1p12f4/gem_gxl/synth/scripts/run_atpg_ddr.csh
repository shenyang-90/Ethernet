#
#          Description :      ATPG runscript
#
#      Original Author :      Vladimir Zivkovic
#
#------------------------------------------------------------------------------
source ./setup_project.csh

##########################################################################################
## Define the DDR workarea,, i.e. the location of a directory that contain the files requested 
## for ATPG. These files are previously generated through synthesis and make_bets for configuration
setenv DDR_WORKAREA ""

###########################################################################################
## Define the clock name and frequency for the only external clock that will be used during test
setenv SCANCLOCKNAME ""
setenv SCANCLOCKFREQUENCY ""

###########################################################################################
## Define the netlist with the absolute path for ATPG. It can be either post-synthesis or post layout. 
setenv DDR_NETLIST ""

###########################################################################################
## Define the technology user setup with the absolute path for ATPG.
setenv DDR_USER_SETUP ""

cp ${DDR_WORKAREA}/run_atpg_template_RTLDesignFlow.csh .
chmod 740 run_atpg_template_RTLDesignFlow.csh

source ./run_atpg_template_RTLDesignFlow.csh
