#!/grid/common/bin/perl -w 

=head1 lsf_sub

 lsf_sub.pl - A wrapper script to use the compile and simulate scripts and
              farm out the test simulations over LSF

=head1 SYNOPSIS

 lsf_sub.pl <config> [-help|-codecover|-gate_max -cadencerc -soce <rundir> -keeptidy]

=head1 DESCRIPTION

 lsf_sub.pl - A wrapper script to use the compile and simulate scripts and
              farm out the test simulations over LSF

=head1 OPTIONS

Options may be abbreviated by truncation and unknown options will be
passed through to NC.

use '-keeptidy' to launch a monitor folowing the submission of all jobs which
will automatically delete workdirs for passing sims.  This drastically
reduces diskspace and numbers of remaining workddirs folowing a regression

=over 1

=item -h[elp]            

Print this message

=head1 AUTHOR

ewanm@cadence.com

=head1 COPYRIGHT

 ###############################################################################
 #                                                                             #
 #           CADENCE                    Copyright (c) 2002                     #
 #                                       Cadence Design Systems, Inc.
 #            VCAD                       All rights reserved.
 #
 #  This work may not be copied, modified, re-published, uploaded, executed, or
 #  distributed in any way, in any medium, whether in whole or in part, without
 #  prior written permission from Cadence Design Systems, Inc.
 ###############################################################################


=cut

use diagnostics;
use strict;
use English;
use Getopt::Long;
use Cwd;
#use File::Remove qw(remove);

# Enable parsing of top-of-file comments as documentation
use Pod::Usage;

my $DESIGN   = "gem_gxl";
my $cwd = getcwd;
my $design_top_dir = "$cwd/..";
my $rtl_dir       = "$design_top_dir/hdl/hdl_src/";
my $dir_tb_dir    = "$design_top_dir/func_ver/sanity/vlog_tb/";
my $soc_tb_dir    = "$design_top_dir/func_ver/soc/";
my $cf       = "";
my $first_run = 1;
my $worklib_locn = "";
my $bsub_cmd_workdir = "";
my $queue = "lnx64";
my $queuecnt = 0;
my $cc_path  = "";
my $rpt_dir  = "";
my $rpt_name = "";
my $top_cc_module = "";
my $last_testname = "";
my $help = '';
my $codecover = "";
my $covmerge = 0;
my $topmodule = "$DESIGN";
my $topcovermodule = $topmodule;
my $gate_min = "";
my $gate_max = "";
my $tool = "";
my $soceRundir = "";
my $glstage = "";
my $keeptidy = 0;
my $first_only = 0;
my $simargs = "-nowarn SNPREC -nowarn SPDUSD -nowarn DSEMEL -nowarn DSEM2009 -64bit -nontcglitch -errormax 5";
my $compargs = "";
my $compargs_base = "";
my $compargs_gls = "";
my $use_imc = 1;
my $run_unr = 0;
my $include_common_tests = 0;
my $only_common_tests = 0;
my $include_soc = 0;
my $exclude_rtl = 0;
my $tb = "";
my $seed = int(rand(500));
my @failed_test;

my $user = $ENV{LOCAL_USER};

if (exists($ENV{DESIGN})) {
  $DESIGN = "$ENV{DESIGN}";
} else {
  print "\n\$DESIGN environment variable is not set - setting DESIGN to \"gem\" \n";
}

if (exists($ENV{RTL_PATH})) {
  $rtl_dir = "$ENV{RTL_PATH}";
} else {
  print "\$RTL_PATH environment variable is not set - setting RTL path to \"$rtl_dir\" \n";
}

if (exists($ENV{DIRECTED_TB_PATH})) {
  $dir_tb_dir = "$ENV{DIRECTED_TB_PATH}";
} else {
  print "\$DIRECTED_TB_PATH environment variable is not set - setting DIRECTED_TB_PATH path to \"$dir_tb_dir\" \n";
}

if (exists($ENV{SOC_TB_PATH})) {
  $soc_tb_dir = "$ENV{SOC_TB_PATH}";
} else {
  print "\$SOC_TB_PATH environment variable is not set - setting SOC_TB_PATH path to \"$soc_tb_dir\" \n";
}

if (!$ARGV[0]) {
  print "\n\n*** You need to run this script with at least one argument!\n\n";$help =1;
}

print "\n";

# Read command line (and previously written command file
&read_arguments( );
# Use POD (Plain Old Documentation) to process top of script into help/manpage
pod2usage(0) if ($help);
my $workdir   = "";
my $workdir_prefix  = "";

my @tests     = ();   # list of a single null string
my $test_dir = "${dir_tb_dir}/tests/tests_$cf";
my $soc_test_dir = "${soc_tb_dir}tests_$cf";
my $common_test_dir = "${dir_tb_dir}/tests/common";
my $bsub_cmd = "bsub -R \"OSREL==EE60\" -o bsub.log";
my $sim_type = "_rtlsim";
my $soc_options = "";
my $covtest = "";
my $report_name = "";
if (!-e "${dir_tb_dir}reports") {system ("mkdir ${dir_tb_dir}/reports");}


# Add all the basic 
$compargs_base = "-nowarn SNPREC -nowarn SPDUSD -nowarn DSEMEL -nowarn DSEM2009 -64bit -c -F ${dir_tb_dir}/src/tb_${topmodule}.f -nclibdirname irun_snapshot -timescale 1ns/1ps -sv -incdir ${dir_tb_dir}/src/ -top tb_${topmodule} -define ABV_ON -define debugmsglvl0 -assert -define directed";

# Set up Code Coverage files
$rpt_dir = "../codecover/icc";
$rpt_name = "full_cc_";

# Do -all/-list options after whole command line processed
if ($gate_max eq "-gate_max" || $gate_min eq "-gate_min" ) {

  @tests=find_all_valid_gltests();
  $compargs_gls = "-f $design_top_dir/pnr/$soceRundir/data_${cf}/libfiles.f $design_top_dir/pnr/$soceRundir/data_${cf}/${topmodule}.${glstage}.v -log irun_compile_gls.log -ALLOWREDEFINITION -nontcglitch -nowarn RECOME -nowarn NTCNNC -nowarn SDFNCAP -define GLSIM  $compargs_base -tfile ./${topmodule}_tfile.txt -SDF_CMD_FILE sdf_cmd_file";
  
  if ($gate_max eq "-gate_max") {
    $compargs_gls = "$compargs_gls -maxdelays ";
  } else {
    $compargs_gls = "$compargs_gls -mindelays ";
  }
  
} else {
  @tests=find_all_tests();
  $compargs = "-F ./${topmodule}.f -define rtl -log irun_compile.log $compargs_base";
}

my $testname = "";
my $testdir = "";

if ($codecover eq "-codecover") {
#  $compargs = "$compargs -coverage all -covoverwrite -covfile ../scripts/codecover/cdn_vlog_covfile.txt -access +c";
  $compargs = "$compargs -covdut gem -coverage all -covoverwrite -access +c";
}

if (($gate_max eq "-gate_max") || ($gate_min eq "-gate_min")) {
  $sim_type = "_".$gate_max.$gate_min;
  $soc_options = "$soc_options -optimize";
  if ($gate_max eq "-gate_max") {$report_name = "cadencercmax";} else {$report_name = "cadencercmin";}
} elsif ($codecover eq "-codecover") {
  $sim_type = "_coveragesim";
  $simargs = "$simargs -scope tb_{$topcovermodule}";
  $soc_options = "$soc_options -coverage";
  $report_name = "rtl";
} else { # RTL sim
  $report_name = "rtl";
  $soc_options = "$soc_options -optimize";
}

$workdir_prefix = ${cf}.${sim_type};

if ($exclude_rtl == 0 && ($gate_max ne "-gate_max") && ($gate_min ne "-gate_min")) {
  foreach my $test_with_dir (@tests) {
    $testname = $test_with_dir;
    $testname =~ s/$test_dir\///g;
    $testname =~ s/$common_test_dir\///g;
    $testname =~ s/[a-zA-Z0-9_]+\///g;

    if ($codecover eq "-codecover") {
      $covtest = "-covtest $testname";
    } else {
      $covtest = "";
    } 
    
    if ($first_only == 0 || $first_run == 1) {
      $workdir = $workdir_prefix."_".$testname;
      $cc_path = "../work_"."${workdir_prefix}_*/icc_results_"."$cf"."/$topcovermodule";
      system "rm -rf ../work_$workdir;mkdir ../work_$workdir";
      chdir "../work_$workdir";
      if ($first_run == 1) {
        $first_run = 0;
        $worklib_locn = "../work_$workdir";
#        system ("../work/gem_cfg_builder.pl -cfg ${cf}");
        system ("make -f ../work/Makefile create_defs CFG=${cf} SEED=${seed}");
        
        # COMPILE 
        system ("$bsub_cmd -q $queue -J COMPILING_$workdir_prefix 'irun $compargs'");
  
        # 1st SIMULATE 
        print "Info... Compiling the design into ../work_$workdir\n";
        $bsub_cmd_workdir = $bsub_cmd . " -q $queue -J 'lsf_sub_sim_$workdir_prefix' -w 'ended('COMPILING_$workdir_prefix')'";
        system ("$bsub_cmd_workdir '${dir_tb_dir}/scripts/trans.pl $test_with_dir -seed ${seed}; irun -64bit -R -nclibdirname irun_snapshot $simargs $covtest -log ${dir_tb_dir}/reports/reports_$cf/ncsim.${report_name}.log${testname};sleep 2; cp -r irun_compile.log ${dir_tb_dir}/reports/reports_${cf}/compile_${report_name}.log'");
    
      } else {
        system ("cp $worklib_locn/${topmodule}_defs.v .");
        $bsub_cmd_workdir = $bsub_cmd . " -q $queue -J 'lsf_sub_sim_$testname' -w 'ended('lsf_sub_sim_$workdir_prefix')'";
        system ("$bsub_cmd_workdir '${dir_tb_dir}/scripts/trans.pl $test_with_dir -seed ${seed}; irun -64bit -R -nclibdirname $worklib_locn/irun_snapshot $simargs $covtest -log ${dir_tb_dir}/reports/reports_$cf/ncsim.${report_name}.log${testname}'");
      }
    }
    chdir $cwd;
  }
} elsif (($gate_max eq "-gate_max") || ($gate_min eq "-gate_min")) {

  foreach my $test_with_dir (@tests) {
    $testname = $test_with_dir;
    $testname =~ s/$test_dir\///g;
    $testname =~ s/$common_test_dir\///g;
    $testname =~ s/[a-zA-Z0-9_]+\///g;
    $workdir = $workdir_prefix."_".$testname;
    if ($first_only == 0 || $first_run == 1) {
      system "mkdir ../work_$workdir";
      chdir "../work_$workdir";
      if ($first_run == 1) {
        $first_run = 0;
        $worklib_locn = "../work_$workdir";
#        system ("../work/gem_cfg_builder.pl -cfg ${cf}");
        system ("make -f ../work/Makefile create_defs CFG=${cf} SEED=${seed}");
        system ("cp ${cwd}/sdf_cmd_file . ");
        system ("cp ${cwd}/${topmodule}_tfile.txt . ");
        print "CMD :-> $bsub_cmd -q $queue -J COMPLIB_SIM_DONE_$workdir_prefix 'irun $compargs_gls'";

        # COMPILE 
        system ("$bsub_cmd -q $queue -J COMPLIB_SIM_DONE_$workdir_prefix 'irun $compargs_gls'");

        # 1st SIMULATE 
        $bsub_cmd_workdir = $bsub_cmd . " -q $queue -J lsf_sub_sim_$testname -w 'ended('COMPLIB_SIM_DONE_$workdir_prefix')'";
        system ("$bsub_cmd_workdir '${dir_tb_dir}/scripts/trans.pl $test_with_dir -seed ${seed}; irun $simargs -R -nclibdirname irun_snapshot $covtest -log ${dir_tb_dir}/reports/reports_$cf/ncsim.${report_name}.log${testname};sleep 2; cp -r irun_compile_gls.log ${dir_tb_dir}/reports/reports_${cf}/compile_${report_name}.log'");
  
      } else {
        system ("cp $worklib_locn/${topmodule}_defs.v .");
        $bsub_cmd_workdir = $bsub_cmd . " -q $queue -J lsf_sub_sim_$testname -w 'ended('COMPLIB_SIM_DONE_$workdir_prefix')'";
        system ("$bsub_cmd_workdir '${dir_tb_dir}/scripts/trans.pl $test_with_dir -seed ${seed}; irun $simargs -R -nclibdirname $worklib_locn/irun_snapshot $covtest -log ${dir_tb_dir}/reports/reports_$cf/ncsim.${report_name}.log${testname};sleep 2'");
      }
    }
    chdir $cwd;
   }
}

# If -include_soc was set, then run some soc tests as well
if ($include_soc) {
  print "\nRunning SoC tests from this script currently unsupported.\n";
#  print "Submitting SoC tests for $cf config...\n";
#  @tests=find_all_soc_tests();
#  chdir $cwd;
#  foreach $testname (@tests) {
#    $workdir = $workdir_prefix."_soc_".$testname;
#    system "mkdir ../work_$workdir";
#    chdir "../work_$workdir";
#    $bsub_cmd_workdir = $bsub_cmd . " -q $queue -J 'soc_$testname'";
#    system ("$bsub_cmd_workdir '../runscripts/run_soc_test.csh -cf $cf -run $testname $soc_options'");
#  }
}

# All jobs have been launched. If -keeptidy was set, then now monitor the rk_dirs
# ../work_$workdir holds the name of the last work_dir
my $success;
my $failed;
my $assrt_fail;
my $compile_workdir;
my $final_test_passed;
my $final_test_failed;
my $all_tests_finished;
my $total_jobs = 0;
my $num_fails_found = 0;
my $num_assrt_found = 0;
my $num_passes_found = 0;
my $num_new_passes_found = 0;
my @workdir_list;
my $num_workdirs = 0;
my $last_num_workdirs = 0;
my $num_compworkdir_finished = 0;
my $lsf_slots = 0;
my $last_fail = "";
my $num_no_finish_cnt = 0;
if ($keeptidy || $covmerge) {
  if ($keeptidy) {print "\nYou asked me to monitor the work dirs created and delete them if/when the test that was run inside that directory passes\nWARNING : This monitor will remain active until all tests in the regression have completed.  Make sure you submitted the lsf_sub.pl to the farm!\n\n";}
  $all_tests_finished = 0;
  while ($all_tests_finished == 0) {
    chdir $cwd;
    if ($first_only == 0) {sleep 20;} else {sleep 2;}
    @workdir_list=find_all_workdirs();
    $last_num_workdirs = $num_workdirs;
    $num_workdirs = $#workdir_list+1;
    $lsf_slots = `bjobs -w | grep RUN | grep lsf_sub_sim | wc -l`;
    $lsf_slots =~ s/\n//g;
    $total_jobs = `bjobs -w | grep lsf_sub_sim | wc -l`;
    if ($lsf_slots > 0 && $last_num_workdirs == $num_workdirs)  {
      $num_no_finish_cnt++;
    } elsif ($last_num_workdirs != $num_workdirs)  {
      $num_no_finish_cnt = 0;
    }
    if (($num_no_finish_cnt == 315)  && ($lsf_slots != 0)) {
      print "Some tests dont seem to be finishing. Killing all submitted jobs and exiting ...\n";
      foreach my $workdir (@workdir_list) {
        my $local_test_name = $workdir;
        $local_test_name =~ s/\.\.\/work_${cf}_rtlsim_//g;
        $local_test_name =~ s/\///g;
        $local_test_name =~ s/\s|\n|\r//g;
        system ("bkill -J lsf_sub_sim_$local_test_name");
      }
      $all_tests_finished = 1;
    }
    if ($total_jobs == 0) {
      print "No jobs pending or running! Finishing ...\n";
    }
    print "Snapshot ... remaining = $num_workdirs, compdirs = " . $num_compworkdir_finished . ", slots = " . $lsf_slots . ", ass_fails = $num_assrt_found, any_fails = $num_fails_found, passed = $num_passes_found(+$num_new_passes_found), lastfail = $last_fail\n";
    $num_fails_found = 0;
    $num_assrt_found = 0;
    $num_new_passes_found = 0;
    if ($codecover eq "-codecover") {$num_passes_found = 0;}
    $num_compworkdir_finished = 0;
    foreach my $workdir (@workdir_list) {
      if (-e "$workdir/bsub.log") { 
        $success = ( system("grep --silent \" status = PASS\" $workdir/bsub.log >/dev/null") ) ? 0 : 1;
        $success = ( system("grep --silent \"* PASSED *\" $workdir/bsub.log >/dev/null") ) ? $success : 1;
        $success = ( system("grep --silent \" and Passed\" $workdir/bsub.log >/dev/null") ) ? $success : 1;  ## This is for SoC

        $assrt_fail = ( system("grep --silent \"ASRTST\" $workdir/bsub.log >/dev/null") ) ? 0 : 1;
        
        $failed = ( system("grep --silent \"*E,NOSTUP\" $workdir/bsub.log >/dev/null") ) ? $assrt_fail : 1; # Fail if assertion failure as well
        $failed = ( system("grep --silent \"*E,RFAIL\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
        $failed = ( system("grep --silent \"* FAILED *\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
        $failed = ( system("grep --silent \" status = FAIL\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
        $failed = ( system("grep --silent \"* ENDED BEFORE ALL ACTIVITY COMPLETE *\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
        $failed = ( system("grep --silent \" and FAILED\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
#        print "Success is $success and Fail is $failed\n";
        if (-e "$workdir/irun_compile.log") {$compile_workdir = 1;} else {$compile_workdir = 0;}
        #$compile_workdir = ( system("grep --silent \"R U N N I N G   R T L   C O M P I L A T I O N\" $workdir/bsub.log >/dev/null") ) ? 0 : 1;
        if ($failed) {$num_fails_found++;$last_fail = $workdir};
        if ($assrt_fail) {$num_assrt_found++;}
      } else {
        $success = 0;
      };
      
      if (($success == 1) && ($failed == 0)) { 
        #if ($compile_workdir) {print "Found PASS result in $workdir, not removing yet because it is the compile dir\n"}
#        else {print "Found PASS result in $workdir, so removing\n"; remove \1, $workdir; }
#        if ($compile_workdir == 0) { print "Found PASS result in $workdir, so removing\n"; system ("rm -rf $workdir"); }
        if ($compile_workdir == 0) { 
          $num_passes_found++; 
          $num_new_passes_found++;
          if ($codecover ne "-codecover") {system ("rm -rf $workdir");}
        } else {$num_compworkdir_finished++;}
      }
#      if ($failed && $compile_workdir) {$num_compworkdir_finished++;}
      #if ($success == 0 && $failed == 0) {print "Whoops - I didnt recognize anything in $workdir to identify if it had finished or not\n";}
    }
   # print @workdir_list,"\n";
   # Now check if all tests have finished
   # if we are just monitoring and not deleting directories (which is true if we are running code coverage), then
   # this will be  $num_compworkdir_finished + $num_fails_found + $num_passes_found
   # If we are deleting all passing workdirs, then it will just be $num_compworkdir_finished + $num_fails_found
#   print "compworkdir finish is $num_workdirs  $num_compworkdir_finished  $num_fails_found\n";
   if (($codecover eq "-codecover" && $num_workdirs == ($num_compworkdir_finished + $num_fails_found + $num_passes_found)) ||
       ($codecover ne "-codecover" && $num_workdirs == ($num_compworkdir_finished + $num_fails_found)) || 
       $total_jobs == 0) {
      $all_tests_finished = 1;
      #print "ALL FINISHED = $all_tests_finished\n";
      print "Final cleanup - removing those workdirs that had the compiled snapshots (with passing results only) ...\n";
      @workdir_list=find_all_workdirs();
      foreach my $workdir (@workdir_list) {
        if (-e "$workdir/irun_compile.log") {$compile_workdir = 1;} else {$compile_workdir = 0;}
      #  if ($compile_workdir) { -- need to get rid of this because some non-work directories might not have been processed correctly due to a race
          $success = ( system("grep --silent \" status = PASS\" $workdir/bsub.log >/dev/null") ) ? 0 : 1;
          $success = ( system("grep --silent \"* PASSED *\" $workdir/bsub.log >/dev/null") ) ? $success : 1;
          $success = ( system("grep --silent \" and Passed\" $workdir/bsub.log >/dev/null") ) ? $success : 1;  ## This is for SoC

          $assrt_fail = ( system("grep --silent \"ASRTST\" $workdir/bsub.log >/dev/null") ) ? 0 : 1;
          
          $failed = ( system("grep --silent \"*E,NOSTUP\" $workdir/bsub.log >/dev/null") ) ? $assrt_fail : 1; # Fail if assertion failure as well
          $failed = ( system("grep --silent \"*E,RFAIL\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
          $failed = ( system("grep --silent \"* FAILED *\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
          $failed = ( system("grep --silent \" status = FAIL\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
          $failed = ( system("grep --silent \"* ENDED BEFORE ALL ACTIVITY COMPLETE *\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
          $failed = ( system("grep --silent \" and FAILED\" $workdir/bsub.log >/dev/null") ) ? $failed : 1;
          if ($failed) {$success = 0}
          if ($success) {
            $num_passes_found++;
            if ($codecover ne "-codecover") {print "\tRemoving $workdir\n";system ("rm -rf $workdir");}
          }
       # }
      }
      print "\n Final results ... assertion fails = $num_assrt_found, total fails = $num_fails_found, total passes = $num_passes_found. Failing workdirs have been preserved.\n";
    }
  }
  
  # Whats left should be the fails ..
  @workdir_list=find_all_workdirs();
  open(LOGOUT, ">regression.log") || die "Cannot open regression.log file for writing\n";
  print LOGOUT "Summary for last regression (user $ENV{LOCAL_USER})\n\n";
  print LOGOUT "Total Passes      : $num_passes_found\n";
  print LOGOUT "Total Fails       : $num_fails_found\n";
  print LOGOUT "Total Unfinished  : ",$#workdir_list,"\n";
  my $cnt = 0;
  if ($num_fails_found > 0) {
    print LOGOUT "First 10 fails : \n";
    foreach my $workdir (@workdir_list) {
      if ($cnt < 10) {$cnt++;print LOGOUT "\t$workdir\n";}
      else {last;}
    }
  }
  close LOGOUT;
  system("mutt -s \"Directed Vlog Regression Results\" $user < regression.log");
}

# Run code coverage
if ($covmerge)  {
  $top_cc_module = $topcovermodule;
  run_codecover();
  print "\n\n*************************************************************************************\n";
  print "Submitting merge command to LSF - this will run when last test simulation has completed ...\n";
  $bsub_cmd_workdir = $bsub_cmd . " -q $queue -J 'COVERAGE_MERGE_${cf}'";
  system ("rm -rf cov_work");
  if ($use_imc) {system ("$bsub_cmd_workdir 'imc -exec all_cov_imc.f'");} else {system ("$bsub_cmd_workdir 'iccr all_cov_iccr.f'");}
  
#  print "\n\n*************************************************************************************\n";
#  print "When all LSF jobs are complete, merge coverage data with the command:\n\n";
#  print "     cd ../work_$workdir \n";
#  print "     iccr all_cov.f \n\n";
#  print "Cummulative Code Coverage results can be found in:\n";
#  print "   $rpt_dir/$rpt_name${cf}.sum  : summary of results\n";
#  print "   $rpt_dir/$rpt_name${cf}.rpt  : RTL with coverage marked\n";
#  print "\n";
#  print "   To Invoke the gui and see a graphical representation, type :  iccr gui_cov.f \n";
#  print "*************************************************************************************\n\n\n";

  # Run UNR(unreachable) analysis if requested
  if ($run_unr) {
    print "Submitting unreachable analysis command to LSF - this will run when last test simulation has completed ...\n\n";
    ### NEED TO ADD IN A BASIC SIM TO GENERATE AN SHM - rename to "init_for_formal.shm"
    system "mkdir ../work_unr";
    chdir "../work_unr";
    system ("$bsub_cmd '../runscripts/compile.pl -cf ${cf};../runscripts/simulate.pl -run basic_rx -shm;rm -rf cds.lib;rm -rf hdl.var;rm -rf worklib;mv ${topmodule}_${cf}_rtl.shm ./init_for_formal.shm'");
    $bsub_cmd_workdir = $bsub_cmd . " -q $queue -J 'RUN_UNR_${cf}' -w 'ended('COVERAGE_MERGE_${cf}')'";
    system ("$bsub_cmd_workdir 'irun -iev -64bit -R -nclibdirname $worklib_locn/irun_snapshot -covdb $cwd/cov_work/scope/merged_results -coverage all -covdut gem -covoverwrite -input ../private/scripts/unr/iev_init.tcl'");
    $bsub_cmd_workdir = $bsub_cmd . " -q $queue -J 'MERGE_UNR' -w 'ended('RUN_UNR_${cf}')'";
    system ("$bsub_cmd_workdir 'imc -init `find . -name imc_coverage_unr_merge.cmd &`'");
    chdir $cwd;
  }
}

sub find_all_workdirs {
  my @workdir_list_int;
  @workdir_list_int = grep ( !/CVS/, split(/\n/, `ls -d ../work_*${sim_type}*`));
  foreach (@workdir_list_int) {
    $_ =~ s/CVS//g;
    $_ =~ s/(\s+|\r|\n)//g;
  };
 # print @workdir_list_int;
  return @workdir_list_int;
}

sub find_all_tests {
  my @test_list;
  if ( ! -d $test_dir && $tests[0] ) {
    print "No tests directory: $test_dir\n";
    exit 6;
  }
  if ( ! -d $common_test_dir) {
    print "No common tests directory: $common_test_dir\n";
    return grep( s|$test_dir/||,
             grep ( !/CVS/,
               split(' ', `ls -d $test_dir/*`)));
  } else {
    print "Common tests directory found: $common_test_dir\n";
    if ($only_common_tests) {
      #@test_list = grep ( !/CVS/, split(/\n/, `find $common_test_dir/*`));
      @test_list = `find $common_test_dir/ -name '*' -type f | grep -v ".svn"`;
    } elsif ($include_common_tests) {
      my @common_test_list = `find $common_test_dir/ -name '*' -type f | grep -v ".svn"`;
      @test_list = `find $test_dir/ -name '*' -type f | grep -v ".svn"`;
      @test_list = push(@common_test_list,@test_list);
    } else {
      @test_list = grep ( !/CVS/, split(/\n/, `ls -d $test_dir/*`));
    }
    foreach (@test_list) {
      #grep ( !/CVS/, $_);
      $_ =~ s/CVS//g;
      $_ =~ s/(\s+|\r|\n)//g;
    };
#    print @test_list;
    return @test_list;
  }
}

sub find_all_soc_tests {
    return grep( s|$soc_test_dir/||,
             grep ( !/CVS/,
               split(' ', `ls -d $soc_test_dir/*`)));
}


sub find_all_valid_gltests {
#  my @dont_run_these_1 = grep ("sel_ahb_freq 3", $test_dir);
  system ("grep 'sel_ahb_freq 3' $test_dir/* > dont_run_these");
  system ("grep 'sel_ahb_freq 4' $test_dir/* >> dont_run_these");
  my @dont_run_these;
  my @my_tests;
  open DONT_RUN_THESE , "dont_run_these"; 
  while (<DONT_RUN_THESE>) {
    if ($_ =~ /^$test_dir\/(.*?)\:/) { 
      push @dont_run_these, $1;
    }
  }
  
  if ( ! -d $test_dir && $tests[0] ) {
    print "No tests directory: $test_dir\n";
    exit 6;
  }
  
  if ( ! -d $common_test_dir) {
    @my_tests = grep( s|$test_dir/||,
                     grep ( !/CVS/,
                       split(' ', `ls -d $test_dir/*`)));
  } else {
    if ($only_common_tests) {
      @my_tests = `find $common_test_dir/ -name '*' -type f | grep -v ".svn"`;
    } elsif ($include_common_tests) {
      my @common_test_list = `find $common_test_dir/ -name '*' -type f | grep -v ".svn"`;
      @my_tests = `find $test_dir/ -name '*' -type f | grep -v ".svn"`;
      @my_tests = push(@common_test_list,@my_tests);
    } else {
      @my_tests = grep ( !/CVS/, split(/\n/, `ls -d $test_dir/*`));
    }
    foreach (@my_tests) {
      #grep ( !/CVS/, $_);
      $_ =~ s/CVS//g;
      $_ =~ s/(\s+|\r|\n)//g;
    };
  }
  my @my_red_tests;

  print "\n";
  for (my $q0=0;$q0<=$#my_tests;$q0++) {
    my $dont_add = 0;
    for (my $q1=0;$q1<=$#dont_run_these;$q1++) {
      if ($dont_run_these[$q1] eq $my_tests[$q0]) {
        print " ... Removing $dont_run_these[$q1] from test list as it runs too fast for synthesized netlist\n";
        $dont_add = 1;
        last;
      }
    }
    if ($dont_add == 0) {push @my_red_tests,$my_tests[$q0];}
  }
  print "\n";
  return @my_red_tests;
}


# Merge Coverage data
sub run_codecover {
  open(REPORT_COV_ALL, ">all_cov_iccr.f") || die "Cannot open all_cov_iccr.f file for writing\n";
    print REPORT_COV_ALL "set_dut_module $top_cc_module\n";
    print REPORT_COV_ALL "merge -code -output merged_results $cc_path/*\n";
    print REPORT_COV_ALL "load_test $cc_path/merged_results\n";
    print REPORT_COV_ALL "list_coverage_files\n";
    print REPORT_COV_ALL "list_coverage -module *\n";
    print REPORT_COV_ALL "list_coverage -instance *\n";
    print REPORT_COV_ALL "report_tabular_summary -module -sort b -raw * > $rpt_dir/$rpt_name${cf}.sum\n" ;
    print REPORT_COV_ALL "test_order -b 1 -e 0 -t 1 >> $rpt_dir/$rpt_name${cf}.sum\n";
    print REPORT_COV_ALL "report_tabular_summary -module -sort t -raw * >> $rpt_dir/$rpt_name${cf}.sum\n" ;
    print REPORT_COV_ALL "test_order -b 0 -e 0 -t 1 >> $rpt_dir/$rpt_name${cf}.sum\n";
    print REPORT_COV_ALL "report_tabular_summary -module -sort bte -raw * >> $rpt_dir/$rpt_name${cf}.sum\n" ;  
    print REPORT_COV_ALL "test_order -b 1 -e 1 -t 1 >> $rpt_dir/$rpt_name${cf}.sum\n";
    print REPORT_COV_ALL "report_tabular_summary -module -sort b -raw * > $rpt_dir/$rpt_name${cf}.rpt\n";
    print REPORT_COV_ALL "report_block_annotated_source -module * > $rpt_dir/$rpt_name${cf}.rpt\n";
  close REPORT_COV_ALL;

  open(REPORT_COV_ALL, ">all_cov_imc.f") || die "Cannot open all_cov_imc.f file for writing\n";
#    if ($include_soc) {
#      print REPORT_COV_ALL "merge_config -source tb_rse.rse_top.i_gem_ss.i_dut0 -targettype gem\n";
#      print REPORT_COV_ALL "merge_config -source tb_rse.rse_top.i_gem_ss.i_dut1 -targettype gem\n";
#    }
    print REPORT_COV_ALL "merge_config -sourcetype gem -targettype gem\n";
    print REPORT_COV_ALL "merge ../work_${cf}_coveragesim_*/cov_work/scope/test -out merged_results -overwrite -metrics all\n";
    print REPORT_COV_ALL "load cov_work/scope/merged_results\n";
  close REPORT_COV_ALL;

  open(GUI_COV_ALL, ">gui_cov.f") || die "Cannot open gui_cov.f file for writing\n";
    print GUI_COV_ALL "set_dut_module $top_cc_module\n";
    print GUI_COV_ALL "load_test $cc_path/merged_results\n";
  close GUI_COV_ALL;
}  
  

sub read_arguments {
  $cf = $ARGV[0];

  my @saved_argv=@ARGV;
  # Variable stores command line/config options
  # Use standard perl package to process command line & config file
  # enter "perldoc Getopt::Long" at the command line for instructions

  # Note if you are adding switches to override `define statements in the HDL
  # Please use -- push @testdefines, "name"
  # This will ensure it is set up correctly for Modelsim & VCS
  Getopt::Long::Configure ("pass_through");
  my %opthash = ('h|help' => \$help,
                 'cfg=s' => sub {$cf = $_[1];},
                 'cf=s' => sub {$cf = $_[1];},
                 'seed=s' => sub {$seed = $_[1];print "lsf_sub.pl : setting seed to $seed from cmd line.\n";},
                 'codecover' => sub {$codecover = "-codecover";},
                 'covmerge' => sub {$covmerge = 1;},
                 'imc' => sub {$use_imc = 1;},
                 'iccr' => sub {$use_imc = 0;},
                 'run_unr' => sub {$run_unr = 1;},
                 'include_common' => sub {$include_common_tests = 1;},
                 'only_common' => sub {$only_common_tests = 1;},
                 'include_soc' => sub {$include_soc = 1;},
                 'exclude_rtl' => sub {$exclude_rtl = 1;},    # rtl sims are run as default
                 'topcovermodule=s' => $topcovermodule,
                 'gate_max' => sub {$gate_max = "-gate_max";},
                 'gate_min' => sub {$gate_min = "-gate_min";},
                 'cadencerc'=>sub {$tool = "-cadencerc"; },
                 'soce=s'=> sub {$soceRundir = "$_[1]";},
                 'stage=s'=> sub {$glstage = "$_[1]";},
                 'first_only' => sub {$first_only = 1;},
                 'keeptidy'=> sub {$keeptidy = 1;},
                 );
  #print "Getting arguments";
  @ARGV=@saved_argv;
  GetOptions (%opthash);
}
  
