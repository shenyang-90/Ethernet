##################################
### Test clock definition for Tmax
##################################

#Specify here all test clocks in the following format:

add_clocks 0 <scan clock name> -timing {10 2.5 7.5 2} -unit ns -shift
# The timing has been pre-selected, do not change it!

###########################################################
# E.g.
#add_clocks 0 pma0_cmn_scanclk_refclk -timing {10 2.5 7.5 2} -unit ns -shift
#
# refer to Encounter Test pinassign file to fetch the clock signals:
# ${_OUTPUTS_PATH}/$testmode/$DESIGN.$testmode.pinassign 
###########################################################
