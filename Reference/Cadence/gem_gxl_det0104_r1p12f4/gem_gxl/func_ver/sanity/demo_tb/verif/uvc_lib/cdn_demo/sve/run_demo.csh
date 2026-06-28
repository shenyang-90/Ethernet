#!/bin/csh -e
#------------------------------------------------------------------------------
#   Description
#------------------------------------------------------------------------------
#   Customer facing wrapper script to run the demo testbench
#
#   Usage Guidelines
#  -----------------
#  o Customer can set CDN_VIP_LIB_PATH to point at pre-compiled VIP libs OR
#    the run command must build the VIP libraries if required **this is incisive only!!**
#  o The run command *MUST* return 0 on a pass and non-zero on a fail
#    It must use an external script to parse the logfile to determine pass / fail
#  o This script *MUST* return 0 on a demo test pass and non-zero on a fail OR non-test 
#    command (eg -h or -testlist)
#    The return value will be checked by the release packager!
#------------------------------------------------------------------------------
# Usage: ./$0 [OPTIONS]";
#  -h|-help|--help                : Prints this help
#  -test   <testname>             : Name of test. Run -testlist to get tests. Defaults to $DEFAULT_TEST
#  -tool   <incisive|vcs|questa>  : Name of simulator. Suuported simulators for this IP are $SUPPORTED_SIMULATORS
#  -config                        : IP configuration name. Defaults to the config for this code drop ($CFG). Use only if >1 config is available
#  -debug  <low|medium|high|full> : Debug verbosity (defaults to low)
#  -gui                           : Runs in interactive mode (batch mode with waves by default)
#  -testlist                      : Print the list of available tests
#  -clean                         : Cleans the working area
#------------------------------------------------------------------------------

# Paths - set absolute path to the project root directory
setenv CDN_DEMO_PATH "$PWD"

# Specify default test
set DEFAULT_TEST=cdn_demo_base_test

# List supported simulators "incisive vcs questa"
set SUPPORTED_SIMULATORS="incisive"

# Builds the VIP in the current directory if not specified
if (! $?CDN_VIP_LIB_PATH) then
  setenv CDN_VIP_LIB_PATH cdn_vip_lib
endif 


# Command line processing
#------------------------
set TEST=`echo $argv[*] | perl -ne ' if (/-test (.*?)\s|\n/) {print "$1\n";}'`
set TOOL=`echo $argv[*] | perl -ne ' if (/-tool (incisive|vcs|questa)\s|\n/) {print "$1\n";}'`
set CFG=`echo $argv[*] | perl -ne ' if (/-config (.*?)\s|\n/) {print "$1\n";}'`
set DEBUG=`echo $argv[*] | perl -ne ' if (/-debug (low|med|high|full)\s|\n/) {print "$1\n";}'`
set GUI=`echo $argv[*] | perl -ne ' if (/-gui/) {print "1";} else {print "0";}'`
set TESTLIST=`echo $argv[*] | perl -ne ' if (/-testlist/) {print "1";} else {print "0";}'`
set HELP=`echo $argv[*] | perl -ne ' if (/-h|-help|--help/) {print "1";} else {print "0";}'`
set CLEAN=`echo $argv[*] | perl -ne ' if (/-clean/) {print "1";} else {print "0";}'`
set SIM_IS_SUPPORTED=`echo $SUPPORTED_SIMULATORS | perl -sne 'if (/(^|\s)$tool(\s|\n)/) {print "1";} else {print "0"};' -- -tool="$TOOL"`

if ($HELP == "1") then
  echo "Usage: ./$0 [OPTIONS]";
  echo "  -h|-help|--help                : Prints this help";
  echo "  -test   <testname>             : Name of test. Run -testlist to get tests. Defaults to $DEFAULT_TEST";
  echo "  -tool   <incisive|vcs|questa>  : Name of simulator. Suuported simulators for this IP are $SUPPORTED_SIMULATORS";
  echo "  -config                        : IP configuration name. Defaults to the config for this code drop ($CFG). Use only if >1 config is available";
  echo "  -debug  <low|medium|high|full> : Debug verbosity (defaults to low)";
  echo "  -gui                           : Runs in interactive mode (batch mode with waves by default - use simvision to view waves)";
  echo "  -testlist                      : Print the list of available tests";
  echo "  -clean                         : Cleans the working area";
  echo "Example : ./$0";
  exit -1
endif

if ($TESTLIST == "1") then
  make -f ${CDN_DEMO_PATH}/Makefile tests
  exit -1
endif

if ($CLEAN == "1") then
  make -f ${CDN_DEMO_PATH}/Makefile clean
  exit -1
endif

if (! $?TOOL || $SIM_IS_SUPPORTED != "1") then
  set TOOL=incisive
  echo "[${0}] INFO: Simulator not supported. Running with incisive (default)."
endif

# If config is not set, list the config directory and choose the first one
# A delivery should only have 1 config. For local testing purposes, this can be defined
#if (! $?CFG || $CFG == "") then
#  set CFG=`ls --color=never ${CFG_DIR} | head -1`
#  echo "[${0}] INFO: Config not specified. Run $CFG (default)."
#endif

if (! $?TEST || $TEST == "") then
    set TEST=$DEFAULT_TEST
    echo "[${0}] INFO: Test name not specified. Run $DEFAULT_TEST (default)."
endif

echo "****** DIP/VIP demo tb ******";
echo "Env :";
echo "  CDN_VIP_LIB_PATH=$CDN_VIP_LIB_PATH";
echo "  TOOL=$TOOL";
echo "  CFG=$CFG";
echo "  CDN_DEMO_PATH=${CDN_DEMO_PATH}";
echo "  TEST=$TEST";
echo "**********************************";

#if ( ! -d "${CFG_DIR}/${CFG}" ) then
#    echo "[${0}] ERROR: IP configuration not found. ${CFG_DIR}/${CFG} does not exist."
#    exit -1
#endif

if ($GUI == "1") then
  set TARGET=run_i
else 
  set TARGET=run
endif

set UVM_VERB=UVM_LOW
switch ($DEBUG)
  case "medium":
    set UVM_VERB=UVM_MEDIUM
    breaksw
  case "high":
    set UVM_VERB=UVM_HIGH
    breaksw
  case "full":
    set UVM_VERB=UVM_FULL
    breaksw
  default :
    set UVM_VERB=UVM_LOW
    breaksw
endsw

if ($TOOL == "incisive") then

  make -f ${CDN_DEMO_PATH}/Makefile ${TARGET} \
    CDN_VIP_LIB_PATH=$CDN_VIP_LIB_PATH \
    TEST=${TEST} \
    UVM_VERBOSITY=${UVM_VERB} \
    COV=0 \

#    CFG=${CFG}  \

endif



