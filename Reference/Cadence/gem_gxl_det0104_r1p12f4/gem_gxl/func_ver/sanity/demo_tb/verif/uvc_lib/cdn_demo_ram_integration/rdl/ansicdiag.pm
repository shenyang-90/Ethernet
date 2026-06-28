# ============================================================================
#
# Program  : ansic.pm
# Language : Perl
# Purpose  : This is a base generator creating ANSI C header files.
#
# Docs     : For more information on writing and extending existing generators
#            please refer to the "Writing and Customizing Output Generators"
#            of the blueprint users guide.
#
#            Doc Path: $BLUEPRINT_HOME/doc/blueprint_user_guide.pdf
#
# ============================================================================
#
#    *************************************************************************
#    *                                                                       *
#    * DENALI SOFTWARE PROVIDES THIS SOFTWARE AND YOU PROVIDE FEEDBACK       *
#    * "AS IS" WITH NO WARRANTIES WHATSOEVER AND EXPRESSLY DISCLAIMS ALL     *
#    * REPRESENTATIONS, WARRANTIES AND CONDITIONS, INCLUDING BUT NOT LIMITED *
#    * TO WARRANTIES AND CONDITIONS OF MERCHANTABILITY, FITNESS FOR A        *
#    * PARTICULAR PURPOSE, TITLE AND NONINFRINGEMENT.  DENALI SOFTWARE'S     *
#    * TOTAL AGGREGATE LIABILITY ARISING FROM YOUR USE OF THIS GENERATOR     *
#    * SOFTWARE IS LIMITED TO ONE U.S. DOLLAR.                               *
#    *                                                                       *
#    * To download the latest version of this generator visit:               *
#    *   http://www.denali.com/forums/showthread.php?t=2                     *
#    *                                                                       *
#    *************************************************************************
#
# ============================================================================

package ansicdiag;
use warnings;
use strict;
require Exporter;
require RegCodeGen;
our @ISA = qw(RegCodeGen Exporter);

##----------------------------------------------------------------------------
## initialize
##----------------------------------------------------------------------------
sub initialize {
  my( $this ) = @_;

  no strict 'refs';

  #comment /subswitch
  my $commstr = "main::CL_".ref($this)."_comment";
  $this->{comment} = defined $$commstr;


  # depth optional cmd line arg
  $this->{file_depth}    = 0;
  my $depthstr = "main::CL_".ref($this)."_depth";
  $this->{file_depth}    = $$depthstr->[0]
    if( defined $$depthstr  );

  # filename optional cmd line arg
  $this->{filename}   = "";
  my $filenamestr = "main::CL_".ref($this)."_filename";
  $this->{filename}   = $$filenamestr->[0]
    if( defined $$filenamestr );

  # effwidth optional cmd line arg
  $this->{reg_eff_width} = 0;
  my $effwidthstr = "main::CL_".ref($this)."_effwidth";
  if( defined $$effwidthstr ) {
      $this->{reg_eff_width} = $$effwidthstr->[0];
      my $n = int($this->{reg_eff_width} / 8);
      if( ($n * 8) != $this->{reg_eff_width} ) {
	  printf("error: ansic was passed an effective width (-effwidth $this->{reg_eff_width}) that was not divisible by 8\n");
	  exit(1);
      }
  }

  # trunc optional cmd line arg
  $this->{trunc}  = 0;
  my $truncstr    = "main::CL_".ref($this)."_trunc";
  $this->{trunc}  = $$truncstr->[0]
    if( defined $$truncstr  );
  $this->warning("define name uniqueness for components isn't guarenteed using this option.
		  user must guarentee this uniqueness by uniquifying addrmap/regfile/reg declaration names in RDL") if( defined $$truncstr  );

  $this->{my_global_type_prefix} = "";
  my $typeprefixstr = "main::CL_".ref($this)."_typeprefix";
  $this->{my_global_type_prefix}   = $$typeprefixstr->[0]
    if( defined $$typeprefixstr );

  # Initialize ANSI-C class variables

  my $type_name = $this->component_to_type_name($this->{target}, 0);
  my $file_name = $this->{filename}.$type_name;



  $this->create_handle($type_name, $file_name.".h",                "/*", "*/");
  $this->create_handle($type_name."_macro", $file_name."_macro.h", "/*", "*/");
  $this->create_handle($type_name."_diag", $file_name."_diag.c",   "/*", "*/");

  $this->{chandle}            = $type_name;
  $this->{shared_handle}      = undef;
  $this->{ctype}              = undef;
  $this->{dtypes}             = {};
  $this->{dtypes}->{order}    = [];
  my $tmp_name=$type_name;
  $tmp_name =~ s/(?<=[^\W_])_+([^\W_])|([^\W_]+)|_+/\U$1\L$2/g;
  $this->{my_camelName}       = $tmp_name;
  $this->{my_multi_level}     = 1;
  $this->{my_prepend}         = "";
  $this->{my_max_reg_len}     = 0;
  $this->{my_max_field_len}   = 0;


  $this->block_iterate("addrmap", "regfile", "reg", "field");

  $this->SUPER::initialize();
}

##----------------------------------------------------------------------------
## gen
##----------------------------------------------------------------------------
sub gen {
  my( $this ) = @_;

  $this->SUPER::gen();

  my $data_type_pad    = {};
  my $includes         = {};
  my $handled_includes = {};

  # Generate version macro
  my $type_name  = $this->component_to_type_name($this->{target}, 0);
  $this->{ctype} = $this->{dtypes}->{$type_name};
  $this->discover_dependencies();
  my $sources    = join("\\n\n", sort($this->sources()));

  $this->{ctype}->{macro} .= "\n";
  $this->{ctype}->{reg_macros} = {};
  $this->write_macro(uc($type_name)."__VERSION", "\"$sources\"\n");

  # Build up a list of includes for each file handle
  foreach my $dtype (@{$this->{dtypes}->{order}}) {
    $this->{ctype} = $this->{dtypes}->{$dtype}; # this->{ctype} holder for currect struct being iterated
    my $handle     = $this->{ctype}->{handle};

    $includes->{$handle} = {} if ( !exists $includes->{$handle} );
    # requires - hash of structs requried by struct, $this->{dtypes}->{$dtype}
    foreach my $req (keys(%{$this->{ctype}->{requires}})) {
      next if ( $this->{dtypes}->{$req}->{handle} eq $handle );
      $includes->{$handle}->{$req} = $this->{dtypes}->{$req};
    }
  }

  foreach my $dtype (@{$this->{dtypes}->{order}}) { # $this->{dtypes}->{order} = array of struct type info
    $this->{ctype} = $this->{dtypes}->{$dtype};     # $this->{dtypes}          = hash of struct type info
    my $h          = $this->{ctype}->{handle};

    # Generate includes for header file
    if( !exists $handled_includes->{$h} ) {
      $handled_includes->{$h} = {};
      my $file_name = $this->{filename}.$h."_macro";
      $this->write("#include \"".$file_name.".h\"\n", $h);

      foreach my $req (sort(keys(%{$includes->{$h}}))) {
	my $req_handle = $includes->{$h}->{$req}->{handle};

	next if( exists $handled_includes->{$h}->{$req_handle} );
	$handled_includes->{$h}->{$req_handle} = 1;

	$file_name = $this->{filename}.$req_handle;
	$this->write("#include \"".$file_name.".h\"\n", $h);
      }

      $this->write("\n", $h);
    }

    foreach my $pad_ver (@{$this->{ctype}->{pad_ver}}) {
      my $type = $dtype;
      my $pad  = "";

      if( $pad_ver ) {
	$type   .= sprintf("__post_pad_0x%x", $pad_ver);
	#print("before a seq of gen_inst_line (pad_ver) \n");
	$pad     = $this->gen_inst_line($pad_ver, 1);
      }

      $this->write(sprintf("#ifndef __REG_%s__\n",   uc($type)),      $h);
      $this->write(sprintf("#define __REG_%s__\n\n", uc($type)),      $h);
      $this->write("struct $type {\n",                                $h);
      $this->write($this->{ctype}->{body},                            $h);
      $this->write("$pad};\n\n",                                      $h);
      $this->write(sprintf("#endif /* __REG_%s__ */\n\n", uc($type)), $h);
      my $dh = $h."_diag";

      my $tmp_str=$this->{my_global_type_prefix};
      if (($type ne $this->component_to_type_name($this->{target}, 0)) or
	  ($this->{my_multi_level}==0)) {
	  # this is for all register structures
	  $this->write($this->write_diag_fcn($type),                  $dh);
      } else {
	  $this->write(
	      "void read_all_registers(uintptr_t regsBase) {\n\n",    $dh);
	  $this->write($this->{ctype}->{diag_extra},                  $dh);
	  $this->write("}\n\n",                                       $dh);
	  $this->write("#if AUTO==0\n",                               $dh);
	  $this->write(
	      $this->write_cddc_wrapper("read_all_registers"),        $dh);

	  $this->write("#endif //AUTO\n",                             $dh);
	  $this->write("void reg\_$tmp_str\_RegisterDumpCmds() {\n\n",$dh);
      }
      $this->write($this->{ctype}->{diag},                            $dh);
      if (($type eq $this->component_to_type_name($this->{target}, 0)) and
	  ($this->{my_multi_level}!=0)) {
	  $this->write("#if AUTO==0\n",                               $dh);
	  $this->write(
	      $this->write_cddc_reg_cmd("(void*)NULL", "regDump_$tmp_str",
					"read_all_registers",
					"wrapper_read_all_registers",
					"read_all_registers <regsBase>"),
								      $dh);

	  $this->write($this->write_reg_func_last_lines(),            $dh);
	  $this->write("#endif //AUTO\n",                             $dh);
      } else {
	  $this->write($this->write_diag_fcn_end($type),              $dh);
      }
      $this->write("};\n\n",                                          $dh);
      if (($type ne $this->component_to_type_name($this->{target}, 0)) or
	  ($this->{my_multi_level}==0)) {
	  $this->write("#if AUTO==0\n",                               $dh);
	  $this->write($this->write_diag_cddc_fcn($type),             $dh);
	  $this->write("#endif //AUTO\n",                             $dh);
      }
#
    }

    my $mh = $h."_macro";
#   $this->write(sprintf("#ifndef __REG_%s_MACRO__\n",   uc($dtype)),    $mh);
#   $this->write(sprintf("#define __REG_%s_MACRO__\n\n", uc($dtype)),    $mh);
    $this->write($this->{ctype}->{macro},                                $mh);
#    $this->write($this->{ctype}->{diag},                                 $dh);
#   $this->write(sprintf("#endif /* __REG_%s_MACRO__ */\n\n",uc($dtype)),$mh);
  }

  foreach my $hndl (keys(%{$this->{handles}})) {
      if ($hndl !~ m/diag/i) {
	  my $file_name = $this->{filename}.$hndl;
	  my $prepend = sprintf("#ifndef __REG_%s_H__\n",    uc($file_name));
	  $prepend   .= sprintf("#define __REG_%s_H__\n\n",  uc($file_name));
	  $this->prepend($prepend, $hndl);
	  $this->write(sprintf("#endif /* __REG_%s_H__ */\n",uc($file_name)), $hndl);
      } else {
	  my $file_name = $this->{filename}.$hndl;
	  $file_name =~ s/_diag//;
	  my $tmp_str=$this->{my_global_type_prefix};
	  my $prepend = "#include <stdint.h>\n#include <stdio.h>\n#include <stdlib.h>\n\n";
	  $prepend .= "#include \"cps_v2.h\"\n";
	  $prepend .= "#if AUTO==0\n";
	  $prepend .= "#include \"cddc.h\"\n";
	  $prepend .= "#endif //AUTO\n\n";
	  $prepend .= "#include \"$file_name.h\"\n\n";
	  $prepend .= $this->{my_prepend};
	  # limits to fit results in an 80 character line.
	  if ($this->{my_max_reg_len} > 69) {
	      $this->{my_max_reg_len} = 69;
	  }
	  if ($this->{my_max_field_len} > 44) {
	      $this->{my_max_field_len} = 44;
	  }
	  $prepend .= "#define $tmp_str\_MAX_REG_LEN ".
	      $this->{my_max_reg_len}."\n\n";
	  $prepend .= "#define $tmp_str\_MAX_FIELD_LEN ".
	      $this->{my_max_field_len}."\n\n";
	  $prepend .= "#define CHECK_WRITE_READ_VALUE 0xFFFFFFFF\n\n";
	  my $camelCaseName=$this->{my_camelName};
	  $prepend .= "typedef struct $file_name $tmp_str\_$camelCaseName\_DIAG;\n\n";
	  $prepend .= "uint32_t ignore_rclr;\n\n";
	  $prepend .= "uint32_t print_fields;\n\n";
	  $prepend .= "uint32_t check_reset;\n";
	  $prepend .= "uint32_t check_reset_count=0;\n\n";
	  $prepend .= "uint32_t check_write_read;\n";
	  $prepend .= "uint32_t check_write_read_count=0;\n\n";
	  $prepend .= "void set_ignore_rclr(uint32_t val){\n";
	  $prepend .= "  ignore_rclr=val;\n";
	  $prepend .= "  printf(\"\\nignore_rclr: %u\\n\",ignore_rclr);\n}\n";
	  $prepend .= "#if AUTO==0\n";
	  $prepend .= $this->write_cddc_wrapper("set_ignore_rclr");
	  $prepend .= "#endif //AUTO\n\n";
	  $prepend .= "void set_print_fields(uint32_t val){\n";
	  $prepend .= "  print_fields=val;\n";
	  $prepend .= "  printf(\"\\nprint_fields: %u\\n\",print_fields);\n}\n";
	  $prepend .= "#if AUTO==0\n";
	  $prepend .= $this->write_cddc_wrapper("set_print_fields");
	  $prepend .= "#endif //AUTO\n\n";
	  $prepend .= "void set_check_reset(uint32_t val){\n";
	  $prepend .= "  check_reset=val;\n";
	  $prepend .= "  printf(\"\\ncheck_reset: %u\\n\",check_reset);\n}\n";
	  $prepend .= "#if AUTO==0\n";
	  $prepend .= $this->write_cddc_wrapper("set_check_reset");
	  $prepend .= "#endif //AUTO\n\n";
	  $prepend .= "void set_check_write_read(uint32_t val){\n";
	  $prepend .= "  check_write_read=val;\n";
	  $prepend .= "  printf(\"\\ncheck_write_read: %u\\n\",check_write_read);\n}\n";
	  $prepend .= "#if AUTO==0\n";
	  $prepend .= $this->write_cddc_wrapper("set_check_write_read");
	  $prepend .= "#endif //AUTO\n\n";


	  #$prepend   .= sprintf("#define __REG_%s_H__\n\n",  uc($file_name));
	  $this->prepend($prepend, $hndl);
	  #$this->write(sprintf("#endif /* __REG_%s_H__ */\n",uc($file_name)), $hndl);

	  if ($this->{my_multi_level}==0) {
	      my $tmp_str=$this->{my_global_type_prefix};
	      my $append=
		  "void reg\_$tmp_str\_RegisterDumpCmds() {\n\n";
	      my $tmp_type_name = "struct ".$this->{chandle};
	      $append .= "#if AUTO==0\n";
	      $append .=
		  $this->write_diag_reg_line("",$tmp_type_name,"","");
	      $append .= $this->write_reg_func_last_lines();
	      $append .= "#endif //AUTO\n";
	      $append .= "}\n";

	      $this->write($append,$hndl);

	  }
      }
  }

  # Actually write out all the files
  $this->write_output();

  if ($this->{filename} ne "" ) { #&& $this->{file_depth} <= 0) {
    my $file_name = $this->{filename}.$type_name;

    my $fullname = $file_name.".h";
    my $linkname = $this->{filename}.".h";
    my $outdir =  $this->{compiler}->output_path();
    system("cd $outdir; rm -rf $linkname; ln -s $fullname $linkname") if ($this->{filename} ne ""); # && (-f $linkname));
    print "generated [".ref($this)."] \"$linkname\" link to \"$fullname\" in ".$this->{compiler}->output_path()."\n";
  }

}

##----------------------------------------------------------------------------
## gen_component
##----------------------------------------------------------------------------
sub gen_component {
  my( $this, $comp, $assign, $path ) = @_;

  if( $comp->type() eq "reg" ) {
    $this->gen_local_instances($comp, $assign, $path);
    return;
  }

  return if( $comp->type() eq "signal" );
  return if( $comp->type() eq "field" );
  return if( $comp->type() eq "attribute" );
  my $type_name = $this->component_to_type_name($comp, 0);

  # Skip any component whose code has already been generated
  return if( exists $this->{dtypes}->{$type_name} );

  $this->{dtypes}->{$type_name}->{body}        = "";
  $this->{dtypes}->{$type_name}->{macro}       = "";
  $this->{dtypes}->{$type_name}->{diag}        = "";
  $this->{dtypes}->{$type_name}->{diag_extra}  = "";
  $this->{dtypes}->{$type_name}->{max_reg_len} = 0;
  $this->{dtypes}->{$type_name}->{max_field_len} = 0;
  $this->{dtypes}->{$type_name}->{handle}      = $this->{chandle};
  $this->{dtypes}->{$type_name}->{addr}        = 0;
  $this->{dtypes}->{$type_name}->{pad_idx}     = 0;
  $this->{dtypes}->{$type_name}->{pad_ver}     = [0];
  $this->{dtypes}->{$type_name}->{requires}    = {};
  $this->{dtypes}->{$type_name}->{comp}        = $comp;
  $this->{dtypes}->{$type_name}->{reg_width}   = 0;

  # this->{ctype} holder for currect struct being iterated
  my $save_ctype = $this->{ctype};
  $this->{ctype} = $this->{dtypes}->{$type_name};

  $this->SUPER::gen_component($comp, $assign, $path);

  my $eff_width_pad = $comp->addr_width() - $this->{ctype}->{addr};
#  my $eff_width_pad = $comp->actual_addr_width() - $this->{ctype}->{addr};
#  my $eff_width_pad = $comp->actual_top_addr() - $this->{ctype}->{addr};
  #print("addr_width: ".$comp->addr_width()."\n");
  #print("actual_addr_width: ".$comp->actual_addr_width()."\n");

  #print("actual_top_addr: ".$comp->actual_top_addr()."\n");
  #print("this->{ctype}->{addr}: ".$this->{ctype}->{addr}."\n");
  #print("before a seq of gen\_inst\_line (eff_with_pad: $eff_width_pad)\n");
  $this->gen_inst_line($eff_width_pad) if( $eff_width_pad > 0 );
#print "cname:".$comp->name."  eff_width_pad=".$eff_width_pad." actual_addr_width=".$comp->actual_addr_width()." actual_top_addr=".$comp->{stats}->{actual_top_addr}." ctype_addr=".$this->{ctype}->{addr}."\n";

  push @{$this->{dtypes}->{order}}, $type_name;

  $this->{ctype}         = $save_ctype;
}



##----------------------------------------------------------------------------
## gen_addrmap_inst
##----------------------------------------------------------------------------
sub gen_addrmap_inst {
  my( $this, $assign, $path ) = @_;

  my $iass       = $this->curr_inst_assignments($assign, $path);
  my $inst       = $path->instance();
  my $icomp      = $inst->type();
  my $type_name  = $this->component_to_type_name($icomp, 0);
  my $ctxt_hndl  = $this->{chandle};
  my $addr_width = $icomp->addr_width(); # <- address range of component. 0x0 to last pad or reg
  my $actual_addr_width = $icomp->actual_addr_width(); # <- real address range, 1st reg to last reg


  if( $this->{file_depth} >= $path->length() ) {
    if( !exists $this->{dtypes}->{$type_name} ) {
      my $file_name = $this->{filename}.$type_name;
      $this->create_handle($type_name, $file_name.".h", "/*", "*/");
      $this->create_handle($type_name."_macro",$file_name."_macro.h",
			   "/*", "*/");
      $this->create_handle($type_name."_diag",$file_name."_diag.c",
			   "/*", "*/");
    }

    $this->{chandle} = $type_name;
  }

  # Generate used global components

  if(  !exists $this->{dtypes}->{$type_name} ) {
    $this->gen_component($icomp, $assign, $path);
  }

  if( ($this->{dtypes}->{$type_name}->{handle} ne $this->{chandle}) &&
      ($this->{dtypes}->{$type_name}->{handle} ne $type_name) )
  {
    $this->create_global_data_type($type_name);
  }

  # encapsulating struct, $this->{ctype}, will require this struct
  $this->{ctype}->{requires}->{$type_name} = $this->{dtypes}->{$type_name};

  $this->{chandle} = $ctxt_hndl;

  # pad_cnt = reg inst address - prev address
  #              ( prev address - 1st reg: address of comp encapsulating this inst
  #                             - else:    address after prev pad/reg )
  my $pad_cnt = $inst->addr() - $this->{ctype}->{addr};

  #print("before a seq of gen_inst_line (gen_addrmap_inst, pad_cnt)\n");
  $this->gen_inst_line($pad_cnt) if( $pad_cnt );

  my @icomp_insts = $icomp->instances();
  my $first_inst   = $icomp_insts[0]; #jbb
  my $first_icomp  = $first_inst->type(); #jbb
  my $last_inst   = $icomp_insts[scalar(@icomp_insts) - 1];
  my $last_icomp  = $last_inst->type();
  my $addr_adj;

  if( $inst->num() == 1 ) {
    $addr_adj       = $addr_width;

    if( $last_inst->num() > 1 && $last_icomp->type() ne "reg" ) {
      $addr_adj    += $last_inst->incr() - $last_icomp->actual_top_addr();
    }
  } else {
    $addr_adj = $inst->incr() * $inst->num();
  }

  if( !defined $icomp->parent() ) {
    $this->write_macro("RFILE_INST_".uc($path->str("__")."__ADDR"),
		       sprintf("0x%xULL", $this->{ctype}->{addr}));

    $this->write_macro("RFILE_INST_".uc($path->str("__")."__END_ADDR"),
		       sprintf("0x%xULL", ($this->{ctype}->{addr} +
					  $addr_width)));
  }

  $this->write_macro("RFILE_INST_".uc($path->str("__")."__NUM"), $inst->num());

  my $pad_width = $inst->incr() - $icomp->actual_top_addr();

  # subtract any explicit offset set on $first_inst since $actual_addr_width does not include this
#  $pad_width = $inst->incr() - ($actual_addr_width + $first_inst->addr()) if ($first_inst->addrSetByUser()); #jbb
  # if last_inst was a regfile/addrmap array get rid of the alignment padding of the last index
  $pad_width   -= $last_inst->incr() - $last_icomp->actual_top_addr()
      if( $last_inst->num() > 1 && $last_icomp->type() ne "reg" );
  my $align_pad         = 0;
  if( defined $this->{dtypes}->{$type_name}->{reg_width} ) {
      my $max_reg_width = $this->{dtypes}->{$type_name}->{reg_width};
      $align_pad        = ($addr_width % ($max_reg_width/8))
	  if( $max_reg_width );
  }

  if( $inst->num() > 1 && $pad_width ) {
    $pad_width += $align_pad if( $align_pad != 0 );

    push @{$this->{dtypes}->{$type_name}->{pad_ver}}, $pad_width;
    $type_name = sprintf("%s__post_pad_0x%x", $type_name, $pad_width);
  } elsif( $align_pad != 0 ) {
    push @{$this->{dtypes}->{$type_name}->{pad_ver}}, $align_pad;
    $type_name = sprintf("%s__post_pad_0x%x", $type_name, $align_pad);
  }
my $iname=$inst->name;
my $cname=$icomp->name;
#print $iname.": num=".$inst->num()." incr=". $inst->incr()." actual_addr_width=".$icomp->{stats}->{actual_addr_width}." actual_top_addr=".$icomp->actual_top_addr()." width.max=".$icomp->{stats}->{width}->{max}." width.min=".$icomp->{stats}->{width}->{min}."\n";

  #print("before a seq of gen_inst_line (struct)\n");
  #my $temp_addr=$addr_adj + $align_pad;
  #print("  potential candidate for offset: ".$temp_addr."\n");
  $this->gen_inst_line("struct ".$type_name, $inst->name(), $inst->num(),
		       $addr_adj + $align_pad );
}

##----------------------------------------------------------------------------
## gen_regfile_inst
##----------------------------------------------------------------------------
sub gen_regfile_inst {
  my( $this, $assign, $path ) = @_;
  $this->gen_addrmap_inst($assign, $path);
}

##----------------------------------------------------------------------------
## gen_reg_inst
##----------------------------------------------------------------------------
sub gen_reg_inst {
  my( $this, $assign, $path ) = @_;

  my $iass      = $this->curr_inst_assignments($assign, $path);
  my $inst      = $path->instance();
  my $icomp     = $inst->type();
  my $handle    = $this->{ctype}->{handle};
  my $type_name = $this->component_to_type_name($icomp, 0);
  my $reg_width = $this->reg_eff_width($icomp) / 8;

  my $reg_data_type = $this->reg_data_type($inst);

  # pad_cnt = reg inst address - prev address
  #              ( prev address - 1st reg: address of comp encapsulating this inst
  #                             - else:    address after prev pad/reg )
  my $pad_cnt = $inst->addr() - $this->{ctype}->{addr};

  #print("before a seq of gen_inst_line (gen_reg_inst)\n");
  $this->gen_inst_line($pad_cnt) if( $pad_cnt );

  my $addr_adj = $inst->incr() * $inst->num();
  $addr_adj    = $reg_width  if( $inst->num() == 1 );

  my $pre_pad  = 0;

  # Since this is a big-endian memory structure we need to pre-pad here
  if( $reg_width < ($icomp->width() / 8) ) {
    my @insts    = $icomp->instances();
    my $max_inst = $insts[scalar(@insts) - 1];
    #print("max inst: $max_inst\n");
    my $msb_diff = $icomp->width() - $max_inst->msb();
    $pre_pad     = int($msb_diff / 8);
    $pre_pad     = ($icomp->width() / 8) - $reg_width
      if( (($icomp->width() / 8) - $reg_width) < $pre_pad );
  }

  # create a struct = { uint_x, pad } i.e. {arysize'{reg, gap}}
  #  to account for mem gaps between regs in an array
  if( ($reg_width < $inst->incr()) && ($inst->num() > 1) ) {
    my $pad_size   = $inst->incr() - $reg_width;
    my $post_pad   = $pad_size - $pre_pad;
    my $gbl_type   = $reg_data_type;
    $gbl_type     .= sprintf("__pre_pad_0x%x",  $pre_pad)  if($pre_pad);
    $gbl_type     .= sprintf("__post_pad_0x%x", $post_pad) if($post_pad > 0);

    if( !exists $this->{dtypes}->{$gbl_type} ) {
      $this->{dtypes}->{$gbl_type}->{body}     = "";
      $this->{dtypes}->{$gbl_type}->{macro}    = "";
      $this->{dtypes}->{$gbl_type}->{handle}   = $this->{chandle};
      $this->{dtypes}->{$gbl_type}->{addr}     = 0;
      $this->{dtypes}->{$gbl_type}->{pad_idx}  = 0;
      $this->{dtypes}->{$gbl_type}->{pad_ver}  = [0];
      $this->{dtypes}->{$gbl_type}->{requires} = {};

      # put this reg component into its own struct
      my $old_ctype  = $this->{ctype}; #jbb
      $this->{ctype} = $this->{dtypes}->{$gbl_type}; #jbb

      #print("before a seq of gen_inst_line\n");
      $this->gen_inst_line($pre_pad)  if( $pre_pad );
      $this->gen_inst_line($reg_data_type, "data", 1, 0);
      $this->gen_inst_line($post_pad) if( $post_pad > 0 );

      $this->create_global_data_type($gbl_type);
      push @{$this->{dtypes}->{order}}, $gbl_type; # dtypes list also accounts for special
						   # struct of gap + reg (..or pad + uint)
      # encapsulating struct, $this->{ctype}, will require this struct
      $this->{ctype} = $old_ctype; #jbb
      $this->{ctype}->{requires}->{$gbl_type} = $this->{dtypes}->{$gbl_type};

    }

    $reg_data_type = "struct ".$gbl_type;

  } else {
    #print("before a seq of gen\_inst\_line (pre\_pad: $pre_pad)\n");
    $this->gen_inst_line($pre_pad) if( $pre_pad );
    $reg_data_type = "volatile ".$reg_data_type;
  }

  my $tmp_1=$icomp->parent()->name(); #$path->str();
  my $tmp_2=$path->str();
  my $upper_name="";
  if ($tmp_1 eq $handle) {
      $upper_name=$tmp_1;
  } else {
      $upper_name=$tmp_2;
      $upper_name=~s/\..*//;
  }
  #print("calling gen_inst_line with \n  $reg_data_type \n  $tmp_1\n  $tmp_2\n  $handle\n");
  my $reg_prop=$this->check_fields_flags($inst);
  my $tmp_3=$reg_prop->{rclr};
  #print("  rclr: $tmp_3\n");
  if ($tmp_1 eq $handle) {
      $this->{my_multi_level}=0;
  }
  #my $tmp_4=$tmp_1;
  #$tmp_4 =~ s/Rfile.*//;
  #print("  inst->name:".$inst->name()."\n");
  #print("  upper name: $upper_name\n");
  #print("  field: $tmp_4\n");
  #print("  upper diag:".$this->{dtypes}->{$tmp_4}->{addr}."\n");
  $this->gen_inst_line($reg_data_type, $inst->name(), $inst->num(), $addr_adj, $upper_name, $handle, $tmp_3);

  $this->gen_component($icomp, $assign, $path);

  my $group_name="";
  if (defined $upper_name) {
      if ($upper_name ne $handle) {
	  $group_name = $upper_name;
	  $group_name =~ s/Rfile.*//;
      }
  }

  $this->gen_reg_macro($inst, $handle."_macro", $inst->name(), $reg_data_type, $group_name);

  if ( $this->{comment} ) {
    if ($inst->desc()) {
      $this->{ctype}->{macro} .= "\n/* macros for ".$path->str()."\n   desc = ".$inst->desc()." */\n";
    }   else {
      $this->{ctype}->{macro} .= "\n/* macros for ".$path->str()."\n   desc = NONE PROVIDED */\n";
    }
  } else {
    $this->{ctype}->{macro} .= "\n/* macros for ".$path->str()." */\n";
  };


  $this->write_macro("INST_".uc($path->str("__")."__NUM"), $inst->num());
}

##----------------------------------------------------------------------------
## check_fields_flags
##----------------------------------------------------------------------------
sub check_fields_flags {
  my( $this, $inst) = @_;

  my $comp           = $inst->type();
  my $read_mask      = 0;
  my $write_mask     = 0;
  my $rclr_mask      = 0;
  my $woset_mask     = 0;
  my $woclr_mask     = 0;
  my $reset_mask     = 0;
  my $reset_val      = 0;

  foreach my $field_inst ($comp->instances()) {
    my $field_comp   = $field_inst->type();
    my $field_mask   = $this->gen_mask($field_inst->num(), $field_inst->lsb());

    $read_mask   = 1 if( $field_comp->sw_r()  );
    $write_mask  = 1 if( $field_comp->sw_w()  );
    $rclr_mask   = 1 if( $field_comp->rclr()  );
    $woset_mask  = 1 if( $field_comp->woset() );
    $woclr_mask  = 1 if( $field_comp->woclr() );

  }

  my $ret;
  $ret->{read}  = $read_mask;
  $ret->{write} = $write_mask;
  $ret->{rclr}  = $rclr_mask;
  $ret->{woset} = $woset_mask;
  $ret->{woclr} = $woclr_mask;

  return $ret;
}

##----------------------------------------------------------------------------
## gen_field_inst
##----------------------------------------------------------------------------
sub gen_field_inst {
  my( $this, $assign, $path ) = @_;

  my $inst    = $path->instance();
  my $iass    = $this->curr_inst_assignments($assign, $path);
  my $encode  = $inst->encode($iass, $path);

  return if( !defined $encode );

  my $icomp   = $inst->type();
  my $handle  = $this->{chandle}."_macro";
  my $prefix  = uc($path->str("__")."__".$encode->name());

  $this->write_macro("FIELD_INST_".uc($path->str("__")."__NUM"), $inst->num());

  if(!exists $this->{done}->{"encoding_".$prefix} ) {
    $this->{done}->{"encoding_".$prefix} = 1;

  if ( $this->{comment} ) {
    $this->{ctype}->{macro} .= sprintf("\n/* encoding macros for %s\n   desc =",
				       $path->str("::"));
    if ( $inst->desc() ) {
      $this->{ctype}->{macro} .= " ".$inst->desc()." */\n";
    } else {
      $this->{ctype}->{macro} .= " NONE PROVIDED */\n";
    };
  } else {
    $this->{ctype}->{macro} .= sprintf("\n/* encoding macros for %s */\n",
				       $path->str("::"));
  };



#   $this->{ctype}->{macro} .= sprintf("#ifndef _ENCODING_%s_\n", uc($prefix));
#   $this->{ctype}->{macro} .= sprintf("#define _ENCODING_%s_\n", uc($prefix));

    my $encwidth;
    foreach my $enc ($encode->encodings()) {
      my $encval  = $enc->value();
      my $encname = $enc->name();

      my $encdesc = $enc->desc();
      if ( !$encdesc ) {
	$encdesc = "NONE PROVIDED";
      };

      $encwidth = $this->vnum_to_dec(\$encval) if( $encval =~ m/\'/ );
      $encval   = hex($encval)                 if( $encval =~ m/^0x/ );

      if ( $this->{comment} ) {
	$this->{ctype}->{macro} .= sprintf("/* encoding desc = $encdesc */\n");
	$this->write_macro($prefix."__".uc($encname), $encval);
	$this->{ctype}->{macro} .= sprintf("\n");
      } else {
	$this->write_macro($prefix."__".uc($encname), $encval);
      };
    }

    $this->write_macro($prefix."__ENCODING_WIDTH", $encwidth)
      if( defined $encwidth );

    if ( $this->{comment} ) {
      $this->{ctype}->{macro} .= sprintf("\n/* encoding macros for %s\n   desc =",
					 $path->str("::"));
    if ( $inst->desc() ) {
      $this->{ctype}->{macro} .= " ".$inst->desc()." */\n";
    } else {
      $this->{ctype}->{macro} .= " NONE PROVIDED */\n";
    };
  } else {
    $this->{ctype}->{macro} .= sprintf("\n/* encoding macros for %s */\n",
				       $path->str("::"));
  };

#   $this->{ctype}->{macro} .= sprintf("#endif /* _ENCODING_%s_ */\n\n",
#                              uc($prefix));
  }
}

##  ##----------------------------------------------------------------------------
##  ## gen_addrmap_def
##  ##----------------------------------------------------------------------------
##  sub gen_addrmap_def {
##    my( $this, $comp, $assign, $path ) = @_;
##
##    $this->gen_component($comp, $assign, $path);
##  }
##
##  ##----------------------------------------------------------------------------
##  ## gen_regfile_def
##  ##----------------------------------------------------------------------------
##  sub gen_regfile_def {
##    my( $this, $comp, $assign, $path ) = @_;
##
##    $this->gen_component($comp, $assign, $path);
##  }

##----------------------------------------------------------------------------
## vnum_to_dec  -- verilog style number to decimal converter
##----------------------------------------------------------------------------
sub vnum_to_dec {
  my( $this, $vnum ) = @_;

  if( $$vnum =~ m/\'h/ ) {
    $$vnum =~ s/([0-9])*\'h/0x/;
    $$vnum = hex($$vnum);
    return $1;
  } elsif( $$vnum =~ m/\'d/ ) {
    $$vnum =~ s/([0-9])*\'d//;
    return $1;
  } elsif( $$vnum =~ m/\'b/ ) {
    $$vnum =~ s/([0-9])*\'b//;
    my $width = $1;

    my @vnum = split(//, $$vnum);
    $$vnum   = 0;

    foreach my $n (@vnum) {
      $$vnum <<= 1;
      $$vnum++ if( $n == 1 );
    }

    return $width;
  }

  return undef;
}

##----------------------------------------------------------------------------
## reg_eff_width
##----------------------------------------------------------------------------
sub reg_eff_width {
  my( $this, $comp ) = @_;
  my $comp_width = $comp->width();

  return $comp_width if( $this->{reg_eff_width} == 0 );

  my @insts      = $comp->instances();
  my $max_inst   = $insts[scalar(@insts) - 1];
  my $max_byte   = int($max_inst->msb() / 8);
  my $width_byte = int($comp_width / 8);
  my $min_width  = $this->{reg_eff_width};
  $min_width     = $width_byte * 8 if( ($width_byte * 8) < $min_width );

  return $min_width if( $max_byte == 0 );

  my $ret_width  = $comp_width;

  while( $max_byte < ($width_byte / 2) ) {
      $ret_width  /= 2;
      $width_byte /= 2;
  }

  return $min_width if( $ret_width < $min_width );
  return $ret_width;
}

##----------------------------------------------------------------------------
## reg_data_type
##----------------------------------------------------------------------------
sub reg_data_type {
  my( $this, $inst ) = @_;

  my $width = $this->reg_eff_width($inst->type());
  $this->{ctype}->{reg_width} = $width if( $width > $this->{ctype}->{reg_width} );
  return "uint".$width."_t";
}

##----------------------------------------------------------------------------
## gen_field_read_macro
##----------------------------------------------------------------------------
sub gen_field_read_macro {
  my( $this, $field_macro, $inst, $mask, $type ) = @_;

  my $lsb = $inst->lsb();
  my $rhs = "($type)(src) & $mask";
  if( $lsb != 0 ) {
      $rhs    = "(($rhs) >> $lsb)"
  } else {
      $rhs    = "($rhs)"
  }

  $this->write_macro($field_macro."__READ(src)", $rhs);
}

##----------------------------------------------------------------------------
## gen_field_write_macro
##----------------------------------------------------------------------------
sub gen_field_write_macro {
  my( $this, $field_macro, $inst, $mask, $type ) = @_;

  my $lsb = $inst->lsb();
  my $rhs = "($type)(src)";
  $rhs    = "($rhs << $lsb)" if( $lsb != 0 );
  $rhs    = "($rhs & $mask)";

  $this->write_macro($field_macro."__WRITE(src)", $rhs);
}

##----------------------------------------------------------------------------
## gen_field_modify_macro
##----------------------------------------------------------------------------
sub gen_field_modify_macro {
  my( $this, $field_macro, $inst, $mask, $type ) = @_;

  my $lsb = $inst->lsb();
  my $rhs = "($type)(src)";
  $rhs    = "($rhs << $lsb)" if( $lsb != 0 );
  $rhs    = "(dst) = ((dst) & ~$mask) | ($rhs & $mask)";

  $this->write_macro($field_macro."__MODIFY(dst, src)", $rhs);
}

##----------------------------------------------------------------------------
## gen_field_verify_macro
##----------------------------------------------------------------------------
sub gen_field_verify_macro {
  my( $this, $field_macro, $inst, $mask, $type ) = @_;

  my $lsb = $inst->lsb();
  my $rhs = "($type)(src)";
  $rhs    = "($rhs << $lsb)" if( $lsb != 0 );
  $rhs    = "($rhs & ~$mask)";

  $this->write_macro($field_macro."__VERIFY(src)", "(!($rhs))");
}

##----------------------------------------------------------------------------
## gen_field_set_macro
##----------------------------------------------------------------------------
sub gen_field_set_macro {
  my( $this, $field_macro, $inst, $mask, $type ) = @_;

  my $lsb = $inst->lsb();
  my $src = "($type)(1)";
  $src    = "($src << $lsb)" if( $lsb != 0 );
  my $rhs = "(dst) = ((dst) & ~$mask) | $src";

  $this->write_macro($field_macro."__SET(dst)", $rhs);
}

##----------------------------------------------------------------------------
## gen_field_clr_macro
##----------------------------------------------------------------------------
sub gen_field_clr_macro {
  my( $this, $field_macro, $inst, $mask, $type ) = @_;

  my $lsb = $inst->lsb();
  my $src = "($type)(".($inst->type()->woclr() ? 1 : 0).")";
  $src    = "($src << $lsb)" if( $lsb != 0 );
  my $rhs = "(dst) = ((dst) & ~$mask) | $src";

  $this->write_macro($field_macro."__CLR(dst)", $rhs);
}

##----------------------------------------------------------------------------
## gen_reg_macro
##----------------------------------------------------------------------------
sub gen_reg_macro {
  my( $this, $inst, $h, $name, $reg_data_type, $group_name ) = @_;

  my $comp           = $inst->type();
  my $read_mask      = 0;
  my $write_mask     = 0;
  my $rclr_mask      = 0;
  my $woset_mask     = 0;
  my $woclr_mask     = 0;
  my $reset_mask     = 0;
  my $reset_val      = 0;
  my $type_name      = $this->component_to_type_name($comp, 0);
#  my $macro          = uc($type_name);
  my $macro          = uc($this->component_to_macro_name($comp, 0));
  my $comp_path_str  = $this->component_path_str($comp);
  my $type           = $this->reg_data_type($inst);
  my $byte_width     = int($this->reg_eff_width($comp) / 8);
  my $hex            = "0x%0".(2 * $byte_width);
  $hex              .= ($byte_width == 8 ) ? "llxULL" : "xU";

  return if ( exists $this->{ctype}->{reg_macros}->{$type_name} );
  $this->{ctype}->{reg_macros}->{$type_name} = "$macro";


  if ($this->{comment}) {
    $this->{ctype}->{macro} .= "\n/* macros for $comp_path_str\n";

    if ( $inst->desc() ) {
      $this->{ctype}->{macro} .= "   desc = ".$inst->desc()." */\n";
    } else {
      $this->{ctype}->{macro} .= "   desc = NONE PROVIDED */\n";
    }
  } else {
    $this->{ctype}->{macro} .= "\n/* macros for $comp_path_str */\n";
  };

  $this->{ctype}->{macro} .= "#ifndef __$macro\_MACRO__\n";
  $this->{ctype}->{macro} .= "#define __$macro\_MACRO__\n";

  foreach my $field_inst ($comp->instances()) {
    my $field_comp   = $field_inst->type();
    my $field_mask   = $this->gen_mask($field_inst->num(), $field_inst->lsb());
    my $hex_str      = sprintf("$hex", $field_mask);

    $read_mask      |= $field_mask if( $field_comp->sw_r()  );
    $write_mask     |= $field_mask if( $field_comp->sw_w()  );
    $rclr_mask      |= $field_mask if( $field_comp->rclr()  );
    $woset_mask     |= $field_mask if( $field_comp->woset() );
    $woclr_mask     |= $field_mask if( $field_comp->woclr() );

    my $field_macro = $macro."__".uc($field_inst->name());



    my $temp_desc = $field_inst->desc();
    if ($this->{comment}) {
      if ($temp_desc) {
	$this->{ctype}->{macro} .= sprintf("\n/* macros for field %s\n   desc = %s */\n",
					   $field_inst->name(), $temp_desc );
      } else {
	$this->{ctype}->{macro} .= sprintf("\n/* macros for field %s\n   desc = NONE PROVIDED */\n",
					   $field_inst->name() );
      }
    } else {
      $this->{ctype}->{macro} .= sprintf("\n/* macros for field %s */\n",
					 $field_inst->name() );
    }


    #print("at macro: type name: $type_name\n");
    #print("  ".$field_inst->name()."\n");
    #print("  $field_macro\n");
    #print("  ".$field_comp->rclr()."\n");
    my $tmp_1=$this->check_fields_flags($inst);
    #print("  ".$tmp_1->{rclr}."\n");
    # create field read macro
    $this->{ctype}->{diag} .=
	$this->write_diag($field_inst->name(),$field_macro,$tmp_1->{rclr})
	if ( $field_comp->sw_r()  );

    my $structure_loc="";
    if ($group_name ne "") {
	$structure_loc = "registers->$group_name.$name";
    } else {
	$structure_loc = "registers->$name";
    }

    if ($reg_data_type =~ m/uint[0-9]+\_t/) {
	# There seems to  be a problem while writing  fields of USBCMD
	# register, DMA fires, simulator  throws errors.  This is only
	# temporary   solution.    Different   mechanism   should   be
	# implemented.  Test   code  should   be  generated   for  all
	# registers,  and there  should  be a  set  of variables  that
	# enable/disable  Write  Read  Test   for  certain  fields  of
	# registers.
	if ($name !~ m/USBCMD/) {
	    $this->{ctype}->{diag} .=
		$this->write_check_write_read_diag($field_macro, $reg_data_type, $structure_loc )
		if ( $field_comp->sw_w() &&  $field_comp->sw_r() );
	}
    }

    $this->write_macro($field_macro."__SHIFT", $field_inst->lsb());
    $this->write_macro($field_macro."__WIDTH", $field_inst->num());
    $this->write_macro($field_macro."__MASK",  sprintf($hex, $field_mask));

    $this->write_macro($field_macro."__RESET",
		       $this->verilog_to_c($field_inst->reset()))
	if( $field_comp->reset() );

    $this->gen_field_read_macro(  $field_macro, $field_inst, $hex_str, $type)
      if( $field_comp->sw_r() );

    $this->gen_field_write_macro( $field_macro, $field_inst, $hex_str, $type)
      if( $field_comp->sw_w() );

    $this->gen_field_modify_macro($field_macro, $field_inst, $hex_str, $type)
      if( $field_comp->sw_w() );

    $this->gen_field_verify_macro($field_macro, $field_inst, $hex_str, $type)
      if( $field_comp->sw_w() );

    $this->gen_field_set_macro(   $field_macro, $field_inst, $hex_str, $type)
      if( $field_inst->num() == 1 && !$field_comp->woclr() );

    $this->gen_field_clr_macro(   $field_macro, $field_inst, $hex_str, $type)
      if( $field_inst->num() == 1 && !$field_comp->woset() );

    $reset_val |= $this->conv_num($field_inst->reset())
      if( defined $field_inst->reset() );
  }

  $this->write_macro(  $macro."__TYPE", $type);

  if( $read_mask ) {
    $this->write_macro($macro."__READ", sprintf($hex, $read_mask));
    $this->write_macro($macro."__RCLR", sprintf($hex, $rclr_mask))
      if( $rclr_mask );
  }

  if( $write_mask ) {
    $this->write_macro($macro."__WRITE", sprintf($hex, $read_mask));
    $this->write_macro($macro."__WOSET", sprintf($hex, $woset_mask))
      if( $woset_mask );

    $this->write_macro($macro."__WOCLR", sprintf($hex, $woclr_mask))
      if( $woclr_mask );
  }

  if( $reset_mask ) {
    $this->write_macro($macro."__RESET_MASK",  sprintf($hex, $reset_mask));
    $this->write_macro($macro."__RESET_VALUE", sprintf($hex, $reset_val));
  }

  $this->{ctype}->{macro} .= "\n#endif /* __$macro\_MACRO__ */\n\n";
}


##----------------------------------------------------------------------------
## move_to_shared
##----------------------------------------------------------------------------
sub move_to_shared {
  my( $this, $type_name ) = @_;

  $this->{dtypes}->{$type_name}->{handle} = $this->{shared_handle};
  # "requires" - hash of structs used by "$type_name" struct
  foreach my $req (keys(%{$this->{dtypes}->{$type_name}->{requires}})) {
    $this->move_to_shared($req)
      if ( $this->{dtypes}->{$req}->{handle} ne $this->{shared_handle} );
  }
}


##----------------------------------------------------------------------------
## verilog_to_c - convert verilog style number to C style
##  there is also vnum_to_dec that can be used instead
##----------------------------------------------------------------------------
sub verilog_to_c {
    my( $this, $value) = @_;
    my $result = '';
    $result=$value;
    $result=~s/[0-9]+\'h/0x/g;
    $result=~s/[0-9]+\'d//g;
    if ($result =~ m/[0-9]+\'b/) {
	$result=~s/[0-9]+\'b/0b/g;
    }

    return $result;

}

##----------------------------------------------------------------------------
## gen_inst_line
##----------------------------------------------------------------------------
sub gen_inst_line {
  my( $this, $type_name, $inst_name, $inst_num, $addr_adj, $glob_type_name, $glob_handle, $rclr_flag ) = @_;

  my $inst_num_str = $inst_num;
  my $const        = 0;
  my $zero_addr    = 0;
  if( !defined $addr_adj ) {
    $const        = 1 if( defined $inst_name && $inst_name == 1 );
    $zero_addr    = 1 if( defined $inst_num  && $inst_num  == 1 );
    my $pad_idx   = $this->{ctype}->{pad_idx};
    $pad_idx      = 0 if( $zero_addr );

    $addr_adj     = $type_name; # only argument passed would be addr_adj
    $inst_num     = $type_name; # addr_adj == inst_num
    $type_name    = "volatile char";
    $inst_name    = sprintf("pad__%d", $pad_idx);
    $this->{ctype}->{pad_idx}++ if( !$const );
    $inst_num_str = sprintf("0x%x", $inst_num);
  }

  my $base_addr     = $this->{ctype}->{addr};
  $base_addr        = 0 if( $zero_addr );

  my $curr_addr_str = sprintf("0x%x", $base_addr);
  my $addr_adj_str  = sprintf("0x%x", $base_addr + $addr_adj);

  my $curr_addr_pad = 10 - length($curr_addr_str);
  my $addr_adj_pad  = 10 - length($addr_adj_str);


  #SWS to support desc
  #my $desc = $this->{target}->desc($this);
  #print "DESC=$desc\n";

  #  print $this;

  #  my $name = $this->{target}->desc_name($this);
  #  print "DESC_NAME=$name\n";


  my $comment = "/* ";
  $comment   .= (" ")x$curr_addr_pad if( $curr_addr_pad );
  $comment   .= "$curr_addr_str - $addr_adj_str";
  $comment   .= (" ")x$addr_adj_pad  if( $addr_adj_pad  );
  $comment   .= " */";

  my $stmt    = "  $type_name $inst_name";
  $stmt      .= "[".$inst_num_str."]" if( $inst_num > 1 );

  my $line;
  my $comment_pad_len  = 78 - length($stmt) - length($comment);
  if( $comment_pad_len > 0 ) {
    my $comment_pad = (" ")x$comment_pad_len;
    $line           = $stmt.";".$comment_pad.$comment."\n";
  } else {
    $comment_pad_len = 79 - length($comment);
    $line            = $stmt.";\n".(" ")x$comment_pad_len.$comment."\n";
  }

  # SWS
  # print "LINE = $line\n";

  my $type_name_mod = $type_name;
  $type_name_mod =~ s/volatile //;
  my $group_name="";
  my $read_to_clear = (defined $rclr_flag) ? $rclr_flag : 0;
  if (defined $glob_type_name) {
      if ($glob_type_name ne $glob_handle) {
	  $group_name = $glob_type_name;
	  $group_name =~ s/Rfile.*//;
      }
  }
  #print("  group name: $group_name\n");
  if ($inst_num==1) {
      #print("base addr: $base_addr\n");
      $this->{ctype}->{diag} .=
	  $this->write_diag_reg_line($inst_name,$type_name_mod,
				     $group_name,$base_addr,$read_to_clear);
      if ($type_name_mod !~ m/uint[0-9]+\_t/) {
	  $this->{ctype}->{diag_extra} .=
	      $this->write_diag_call_all_line($type_name_mod);
	  my $name_prefix=$this->{my_global_type_prefix};
	  my $type_name_new=$type_name_mod;
	  $type_name_new =~ s/\s*struct\s*//;
	  $type_name_new =~ s/Rfile\s*//;
	  $type_name_new = uc($type_name_new);
	  my $shift_hex = sprintf("0x%08x",$base_addr);
	  $this->{my_prepend} .=
	      "#define $name_prefix\_$type_name_new\_REGISTER\_BLOCK\_SHIFT $shift_hex\n\n";
      }
  } else {
      #print("gen inst line: $type_name, $inst_name\n");
  }

  return $line if( $const );

  $this->{ctype}->{addr} += $addr_adj;
  $this->{ctype}->{body} .=  $line;
}

##----------------------------------------------------------------------------
## write_macro
##----------------------------------------------------------------------------
sub write_macro {
  my( $this, $macro, $val ) = @_;

  my $def     = "#define $macro ";
  my $pad_len = 79 - length($def) - length($val);
  my $pad     = "";

  if( $pad_len > 0 ) {
    $pad = (" ")x$pad_len;
    $this->{ctype}->{macro} .= "$def$pad$val\n";
  } elsif( $pad_len == 0 ) {
    $this->{ctype}->{macro} .= "$def$val\n";
  } else {
    my $def_pad_len = 20;
    my $def_pad     = (" ")x$def_pad_len;
    my @val         = split(/\s+/, $val);
    $val            = "\\\n".$def_pad.shift @val;
    my $val_len     = length($val) + $def_pad_len;

    foreach my $v (@val) {
      my $v_len = length($v);
      if( ($val_len + $v_len + $def_pad_len) < 78 ) {
	$val_len += $v_len + 1;
	$val     .= " $v";
      } else {
	$val_len  = $def_pad_len + $v_len;
	$val     .= "\\\n$def_pad$v";
      }
    }

    $this->{ctype}->{macro} .= "$def$val\n";
  }
}

##---
##write_diag
##---
sub write_diag {
  my( $this, $name, $macro_pref, $rclr ) = @_;

  my $diag_line="  if ((print_fields==1)";
  my $extra_pad="  ";

  if ($rclr) {
      $diag_line .=
	  "&&(ignore_rclr==1))";
  } else {
      $diag_line .= ")";
  }
  $diag_line .= "{\n";
  $diag_line .=
      $extra_pad."  printf(\"  %-*s:%08x, mask:%08x, width:%u\\n\",\n";
  $diag_line .=
      $extra_pad."         max_field_len,\"$name\",\n";
  if (length($name)>$this->{ctype}->{max_field_len}) {
      $this->{ctype}->{max_field_len}=length($name);
  }
  $diag_line .=
      $extra_pad."         $macro_pref"."__READ(tmp),\n";
  $diag_line .=
      $extra_pad."         $macro_pref"."__MASK,\n";
  $diag_line .=
      $extra_pad."         $macro_pref"."__WIDTH);\n";

  $diag_line .=
      "  }\n";

  $diag_line .= "  if ((check_reset==1)";

  if ($rclr) {
      $diag_line .=
	  "&&(ignore_rclr==1))";
  } else {
      $diag_line .= ")";
  }
  $diag_line .= "{\n";
  $diag_line .=
      $extra_pad."  if(($macro_pref"."__READ(tmp))!=\n";
  $diag_line .=
      $extra_pad."     ($macro_pref"."__RESET)){\n";
  $diag_line .=
      $extra_pad."    check_reset_count++;\n";
  $diag_line .=
      $extra_pad."    printf(\"  VALUE MISMATCH:%-*s:%08x, reset:%08x\\n\",\n";
  $diag_line .=
      $extra_pad."           max_field_len,\"$name\",\n";
  $diag_line .=
      $extra_pad."           $macro_pref"."__READ(tmp),\n";
  $diag_line .=
      $extra_pad."           $macro_pref"."__RESET);\n";
  $diag_line .=
      $extra_pad."  }\n";

  $diag_line .=
      "  }\n";


  return $diag_line;
}

##---
##write_check_write_read_diag
##---
sub write_check_write_read_diag {
  my( $this, $macro_pref, $reg_data_type, $structure_loc) = @_;

  my $diag_line="";
  my $extra_pad="  ";

  $diag_line .=
      "  if ((check_write_read==1)){\n";
  $diag_line .=
      $extra_pad."  CPS_UncachedWrite32(($reg_data_type*)&($structure_loc), ($macro_pref"."__WRITE(CHECK_WRITE_READ_VALUE)));\n";
  $diag_line .=
      $extra_pad."  read_write_tmp = CPS_UncachedRead32(($reg_data_type*)&($structure_loc));\n";
  $diag_line .=
      $extra_pad."  if(($macro_pref"."__READ(read_write_tmp))!=\n";
  $diag_line .=
      $extra_pad."     ($macro_pref"."__READ(CHECK_WRITE_READ_VALUE))){\n";
  $diag_line .=
      $extra_pad."    check_write_read_count++; \n";
  $diag_line .=
      $extra_pad."    printf(\"  WRITE READ MISMATCH\\n\"); \n";
  $diag_line .=
      $extra_pad."  }\n";
  $diag_line .=
      $extra_pad."  CPS_UncachedWrite32(($reg_data_type*)&($structure_loc), ($macro_pref"."__RESET));\n";
  $diag_line .=
      "  }\n";


  return $diag_line;
}

##---
##write_diag_fcn
##---
sub write_diag_fcn {
  my( $this, $name ) = @_;
  $name =~ s/Rfile//;

  my $tmp_str=$this->{my_global_type_prefix};
  my $tmp_type=$this->{my_camelName};
  my $global_struct = "$tmp_str\_$tmp_type\_DIAG";
  my $fcn_str = "void read\_$name\_registers(uintptr\_t regsBase) {\n\n";
  if ($this->{ctype}->{max_reg_len} > $this->{my_max_reg_len}) {
      $this->{my_max_reg_len}=$this->{ctype}->{max_reg_len};
  }
  if ($this->{ctype}->{max_field_len} > $this->{my_max_field_len}) {
      $this->{my_max_field_len}=$this->{ctype}->{max_field_len};
  }

  my $define_name = "$tmp_str\_".uc($name)."_REGISTER_BLOCK_SHIFT";
  $fcn_str .= "  $global_struct* registers;\n\n";
  $fcn_str .= "  uint32_t tmp, read_write_tmp, offs;\n\n";
  $fcn_str .= "#ifdef $define_name\n";
  $fcn_str .= "  uint32_t block_offset=$define_name;\n";
  $fcn_str .= "#else \/\/$define_name\n";
  $fcn_str .= "  uint32_t block_offset=0;\n";
  $fcn_str .= "#endif \/\/$define_name\n\n";
  $fcn_str .= "  uint32\_t max\_reg\_len=$tmp_str\_MAX_REG_LEN;\n\n";
  $fcn_str .= "  uint32\_t max\_field\_len=$tmp_str\_MAX_FIELD_LEN;\n\n";
  $fcn_str .= "  registers=($global_struct*)regsBase;\n\n";
  $fcn_str .= "  printf(\"\\nignore rclr : %d\\n\",ignore_rclr);\n\n";
  $fcn_str .= "  printf(\"print fields: %d\\n\",print_fields);\n\n";
  $fcn_str .= "  printf(\"\\nreading $name registers at base: %08x\\n\",(uint32_t)regsBase);\n\n";
  return $fcn_str;

}

sub write_diag_fcn_end {
  my( $this, $name ) = @_;
  $name =~ s/Rfile//;
  my $fcn_str = "  if (check_reset==1){\n";
  $fcn_str .=   "     printf(\"\\nfinished reading $name registers\\n\");\n";
  $fcn_str .=   "     printf(\"check_reset_count: %u (value mismatches)\\n\", check_reset_count);\n";
  $fcn_str .=   "     printf(\"check_write_read_count: %u (value mismatches)\\n\", check_write_read_count);\n";
  $fcn_str .=   "  }\n\n";

  return $fcn_str;

}

##---
##write_diag_cddc_fcn
##---
sub write_diag_cddc_fcn {
  my( $this, $name ) = @_;

  $name =~ s/Rfile//;

  return $this->write_cddc_wrapper("read_".$name."_registers");

}


sub write_cddc_wrapper {
    my ( $this, $fcn_name) = @_;

    my $fcn_str = "void* wrapper\_$fcn_name";
    $fcn_str .= "(void * cddcInst, void * pD, char * paramv) {\n\n";
    $fcn_str .= "  cddcOp *cInst = (cddcOp *)cddcInst;\n";
    $fcn_str .= "  char params[1][512];\n  int  len;\n  char *hd;\n\n";
    $fcn_str .= "  hd = paramv;\n  len = getTok( hd, params[0]);\n";
    $fcn_str .= "  hd += len;\n";
    $fcn_str .= "  if (!len) {\n";
    $fcn_str .= "    cInst->printf(\"Error: invalid number of params [0]\");\n";
    $fcn_str .= "    return;\n  }\n\n";
    $fcn_str .= "  $fcn_name(getValFromStr(params[0]));\n\n";
    $fcn_str .= "}\n\n";

    return $fcn_str;
}

##---
##write_diag_reg_line
##---
sub write_diag_reg_line {
    my( $this, $name, $type_name, $group_name, $tgt_offset, $rclr ) = @_;
    my $diag_line = "\n  //$name\n";
    my $def_t = "uint32_t";
    if ($type_name =~ m/uint[0-9]+\_t/) {
	my $structure_loc="";
	if ($group_name ne "") {
	    $structure_loc = "registers->$group_name.$name";
	} else {
	    $structure_loc = "registers->$name";
	}
	#print(" struct loc: $structure_loc\n");
	my $extra_pad="";
	if ($rclr) {
	    $diag_line .=
		"  if (ignore_rclr==1) {\n";
	    $extra_pad="  "
	}
	$diag_line .=
	    $extra_pad."  tmp=CPS_UncachedRead32(($type_name*)&($structure_loc));\n";
	$diag_line .=
	    $extra_pad."  offs=($def_t)(&($structure_loc))-($def_t)regsBase;\n";
	$diag_line .=
	    $extra_pad."  printf(\"%-*s:%08x\\n\",\n";
	$diag_line .=
	    $extra_pad."         max_reg_len, \"$name\", tmp);\n";
	if (length($name)>$this->{ctype}->{max_reg_len}) {
	    $this->{ctype}->{max_reg_len}=length($name);
	}
	$diag_line .=
	    $extra_pad."  if ((block_offset+$tgt_offset)!=offs){\n";
		$diag_line .=
	    $extra_pad."     printf(\"  WARNING! tgt offs:%08x, act offs:%08x\\n\",\n";
	$diag_line .=
	    $extra_pad."            block_offset+$tgt_offset, offs);\n";
	$diag_line .=
	    $extra_pad."  }\n";

	if ($rclr) {
	    $diag_line .=
		"  }\n";
	}
    } else {
	$type_name =~ s/\s*struct\s*//;
	$type_name =~ s/Rfile\s*//;
	my $tmp_str=$this->{my_global_type_prefix};
	$diag_line = "#if AUTO==0\n";
	$diag_line .=
	    $this->write_cddc_reg_cmd("(void*)NULL", "regDump_$tmp_str",
				      "read\_$type_name",
				      "wrapper\_read\_$type_name\_registers",
				      "read\_$type_name\ <base address>");
	$diag_line .= "#endif //AUTO\n";
    }
    return $diag_line;
    #$this->{ctype}->{diag} .=  $diag_line;
}

sub write_cddc_reg_cmd {
    my( $this, $parent, $group, $disp_fcn, $call_fcn, $disp_usage ) = @_;
    my $diag_line =
	"  cddc_regCmd($parent,\"$group\",\"$disp_fcn\",\n";
    $diag_line .=
	"              $call_fcn, NULL,\n";
    $diag_line .=
	"              \"$disp_usage\", RET_PASS_STR);\n\n";
    return $diag_line;
}

sub write_diag_call_all_line {
    my( $this, $type_name ) = @_;
    $type_name =~ s/\s*struct\s*//;
    $type_name =~ s/Rfile\s*//;
    my $diag_line = "";
    $diag_line .=
	"  read\_$type_name\_registers(regsBase);\n\n";
    return $diag_line;
}

sub write_reg_func_last_lines {
    my( $this ) = @_;
    my $diag_line="";
    my $tmp_str=$this->{my_global_type_prefix};
    $diag_line .=
	$this->write_cddc_reg_cmd("(void*)NULL", "regDump_$tmp_str",
				  "set_ignore_rclr",
				  "wrapper_set_ignore_rclr",
				  "set_ignore_rclr <value>\\n ".
				  "1-ignore\\n 0-don't");
    $diag_line .=
	$this->write_cddc_reg_cmd("(void*)NULL", "regDump_$tmp_str",
				  "set_print_fields",
				  "wrapper_set_print_fields",
				  "set_print_fields <value>\\n ".
				  "1-print\\n 0-don't");
    $diag_line .=
	$this->write_cddc_reg_cmd("(void*)NULL", "regDump_$tmp_str",
				  "set_check_reset",
				  "wrapper_set_check_reset",
				  "set_check_reset <value>\\n ".
				  "1-check\\n 0-don't");
    $diag_line .= "  ignore_rclr = 0; \n\n";
    $diag_line .= "  print_fields = 0; \n\n";
    $diag_line .= "  check_reset = 0; \n\n";
    return $diag_line;

}

##----------------------------------------------------------------------------
## create_global_data_type
##----------------------------------------------------------------------------
sub create_global_data_type {
  my( $this, $type ) = @_;

  if( !defined $this->{shared_handle} ) {
    my $shared_handle      = $this->{target}->name()."__shared";
    $this->{shared_handle} = $shared_handle;
    my $file_name          = $this->{filename}.$shared_handle;
    $this->create_handle($shared_handle, $file_name.".h", "/*", "*/");
    $this->create_handle($shared_handle."_macro", $file_name."_macro.h",
			 "/*", "*/");
  }

  $this->move_to_shared($type);
}

##----------------------------------------------------------------------------
## component_to_type_name
##----------------------------------------------------------------------------
sub component_to_type_name {
  my( $this, $comp, $append_type ) = @_;

  $append_type = 1 if( !defined $append_type );

  my $type_name = $comp->name();
  $type_name   .= "__".$comp->type() if( $append_type );

  my $pcomp = $comp->parent();
  while( $pcomp ) {
    $type_name = $pcomp->name()."__".$type_name if ($pcomp->name() ne "BlueprintGlobalNameSpace");
    $pcomp = $pcomp->parent();
  }

  return $type_name;
}


##----------------------------------------------------------------------------
## component_to_macro_name - component_to_type_name but name trunc feature
##----------------------------------------------------------------------------
sub component_to_macro_name {
  my( $this, $comp, $append_type ) = @_;

  $append_type = 1 if( !defined $append_type );

  my $macro_name = $comp->name();
  $macro_name   .= "__".$comp->type() if( $append_type );

  my $scopelevels = 0;
  my @parents;
  my $pcomp = $comp->parent();
  while( $pcomp ) {
    $scopelevels++;
    push @parents, $pcomp->name();
    #$macro_name = $pcomp->name()."__".$macro_name if ($pcomp->name() ne "BlueprintGlobalNameSpace");
    $pcomp = $pcomp->parent();
  }

  # truncate the macros name
  for( my $i = 0; $i < ($scopelevels - $this->{trunc}); $i++ ) {
    $macro_name = $parents[$i]."__".$macro_name if ($parents[$i] ne "BlueprintGlobalNameSpace");
  }

  return $macro_name;
}



##----------------------------------------------------------------------------
## component_path_str
##----------------------------------------------------------------------------
sub component_path_str {
  my( $this, $comp ) = @_;

  my $comp_path = $comp->name();

  my $pcomp = $comp->parent();
  while( $pcomp ) {
    $comp_path = $pcomp->name()."::".$comp_path;
    $pcomp     = $pcomp->parent();
  }

  return $comp_path;
}

##----------------------------------------------------------------------------
## gen_mask
##----------------------------------------------------------------------------
sub gen_mask {
  my( $this, $width, $lsb ) = @_;

  my $fmask       = -1;
  my $upper_shift = 64 - $width;
  $fmask <<= $upper_shift;
  $fmask >>= $upper_shift;
  $fmask <<= $lsb;
}

1;
