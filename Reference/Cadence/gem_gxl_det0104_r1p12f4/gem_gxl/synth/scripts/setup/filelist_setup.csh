#!/bin/csh -f




##########################################################
#  Multiple dotf handling - No need to modify
##########################################################

if (-e ./rdf4.0.1_expanded.f) then
#  rm ./expanded.f
  echo ""
  echo "This rdf4.0.1_expanded.f filelist already exists and will not be updated:"
  echo "  $PWD/rdf4.0.1_expanded.f !"  
  echo "Please delete this file if a new rdf4.0.1_expanded.f is to be generated"
  echo ""
else 
  foreach current_flist ($RTL_F_FILELIST)
  set path_to_f = ""
  set current_path = ""
  # Grab the pathnames to be used to replace any relative paths in the .f file
  set current_path = "${current_flist:h}"; set path_to_f = ($path_to_f $current_path)
  #  echo "  Expanding filelist: $current_flist "
  # Need an env variable so that Perl can use below
  setenv currentpath $current_path

    cat $current_flist >> ./rdf4.0.1_expanded.f
    # remove "./" if it exists
      perl -p -i -e 's/^\s*\.\///' ./rdf4.0.1_expanded.f

    # Remove any whitespace at the end of the line
      perl -p -i -e 's/(\s+$)/\n/g' ./rdf4.0.1_expanded.f
   # echo "  current path: $current_path "

    # Remove empty lines
    perl -ni -e 'print unless /^\s*$/' ./rdf4.0.1_expanded.f

      
if (! $KEEP_PATHS) then
    # Make all paths absolute that dont have environment variables in the path  
      perl -p -i -e 's/^\s*//; s+^\s*(?\![/\$/\+])+'"$current_path/+" ./rdf4.0.1_expanded.f
      # Substitute all environment variables in the provided .f with their path 
      perl -p -i -e 's#\${?(\w+)}?# $ENV{$1} // $& #ge;' ./rdf4.0.1_expanded.f

    # Expand include dirs to full paths
    #  perl -p -i -e 's/(\+incdir\+)(.*)\n/$1$ENV{currentpath}\n/g' ./rdf4.0.1_expanded.f
endif

    #  grep '\.v'$          ./expanded.f > ./expanded_vlog.f        # Create verilog filelist
    #  grep '\.sv'$         ./expanded.f > ./expanded_svlog.f       # Create SystemVerilog filelist
    #  grep '\.v\|.sv'$     ./expanded.f > ./expanded_svlog_vlog.f  # Create SystemVerilog + Verilog filelist
    #  grep '\.vhd\|.vhdl'$ ./expanded.f > ./expanded_vhdl.f        # Create VHDL filelist

  end

  echo ""
  echo "rdf4.0.1 version of final expanded and merged filelist can be found here:"
  echo "  $PWD/rdf4.0.1_expanded.f"

endif


if (-e ./expanded.f) then

  echo "rdf4.0.2 expanded filelist already exists and will not be updated:"
  echo "  $PWD/expanded.f !"  
  echo "Please delete this file if a new expanded.f is to be generated"
  echo ""
else
  echo ""
  echo "rdf4.0.2 expanded and merged filelist can be found here:"
  echo "  $PWD/expanded.f"
  echo ""
  ${IPF_DESIGN_FLOW_SCRIPTS}/setup/expand.pl

endif
##########################################################
