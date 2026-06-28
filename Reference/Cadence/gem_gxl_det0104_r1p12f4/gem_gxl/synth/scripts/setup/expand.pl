#!/usr/bin/perl

# Authore: mlewis
# Date: 06/03/16
# Beta version of file expansion script to create a single .f for RDF
# Supports nested .f files to 3 levels.

use File::Basename;
use Cwd 'abs_path';


#my @list_of_flist = ('manifest.f');
@list_of_files = split (/ /,$ENV{EXPAND_LIST}); 

#foreach $ cur_file(@list_of_files) {
#     print "\nGOT THIS FILE: $cur_file\n";
#}

my $full_paths = 1;
my $new_flist = "./expanded.f"; 

# Clean up for new filelist
  open NEWFLIST, ">" . $new_flist or die("Could not open output file '$new_flist'!");

#  open LISTOFALL, ">" . full_list.txt or die("Could not open output file 'full_list.txt'!");

foreach $ current_flist(@list_of_files) {
   #  print "Expanding Current Filelist: $current_flist\n";

  open NEWFLIST, ">>" . $new_flist or die("Could not open output file '$new_flist'!");
  open CURFLIST, "<" . $current_flist or die("Could not open input file '$current_flist'!");


  # Select path to .f
  my $current_path = dirname $current_flist;
#     print "CURRENT PATH - $current_path\n";

  while ($line = <CURFLIST>) {
    if ($line =~ /-f (.*.f)/i ) {
     # print "\nOFF to expand this nested .f  = $1\n";
     # print "with is path to original .f  = $current_path\n";
      expand_filelist($1, $current_path);
    } else {
      expand_line($line, $current_path);  
    }  
  }
close NEWFLIST;
close CURFLIST;
}


# Subroutine to expand a nested .f
sub expand_filelist($)
{
  
# .f name being worked on
my $current_filelist = shift(@_);
# path to .f
my $path_to_f=shift(@_);
my $fname;
my $path_to_f_mod;

#print "\n Now expanding $current_filelist\n";

if ($current_filelist =~ s/\${?(\w+)}?/$ENV{$1}/ ) {
 ($fname, $path_to_f_mod) = fileparse($current_filelist);
 } else {
 ($fname, $path_to_f_mod) = fileparse("$path_to_f/$current_filelist");
} 


# The path to put into the final .f is the relative to the place where the toplevel .f exists
my $final_path_to_f = "$path_to_f_mod";
my $ffile_to_parse = "$path_to_f_mod$fname";

open CURSUBFLIST, "<" . "$ffile_to_parse" or die("Could not open input file '$ffile_to_parse'!");

 while (my $subline = <CURSUBFLIST>) {
  #  print "\n Subline is $subline";
   if ($subline =~ /-f (.*.f)/i ) {
     expand_filelist2($1, $final_path_to_f);
  #  print "\n\n Finished expanding $current_filelist\n\n";
   } else {
     expand_line($subline, $final_path_to_f);  
   }  
 }
#close CURSUBFLIST;
}


# Subroutine to expand a nested .f
sub expand_filelist2($)
{
  
# .f name being worked on
my $current_filelist = shift(@_);
# path to .f
my $path_to_f=shift(@_);
my $fname;
my $path_to_f_mod;

#print "\n Now expanding 2  $current_filelist\n";



if ($current_filelist =~ s/\${?(\w+)}?/$ENV{$1}/ ) {
 ($fname, $path_to_f_mod) = fileparse($current_filelist);
 } else {
 ($fname, $path_to_f_mod) = fileparse("$path_to_f/$current_filelist");
} 


# The path to put into the final .f is the relative to the place where the toplevel .f exists
my $final_path_to_f = "$path_to_f_mod";
my $ffile_to_parse = "$path_to_f_mod$fname";

open CURSUBFLISTTWO, "<" . "$ffile_to_parse" or die("Could not open input file '$ffile_to_parse'!");

 while (my $subline = <CURSUBFLISTTWO>) {
  #  print "\n Subline 2 is $subline";
   if ($subline =~ /-f (.*.f)/i ) {
     expand_filelist3($1, $final_path_to_f);
 #   print "\n\n 2  Finished expanding $current_filelist\n\n";
   } else {
     expand_line($subline, $final_path_to_f);  
   }  
 }
#close CURSUBFLIST;
}


# Subroutine to expand a nested .f
sub expand_filelist3($)
{
  
# .f name being worked on
my $current_filelist = shift(@_);
# path to .f
my $path_to_f=shift(@_);
my $fname;
my $path_to_f_mod;

#print "\n Now expanding 3  $current_filelist\n";



if ($current_filelist =~ s/\${?(\w+)}?/$ENV{$1}/ ) {
 ($fname, $path_to_f_mod) = fileparse($current_filelist);
 } else {
 ($fname, $path_to_f_mod) = fileparse("$path_to_f/$current_filelist");
} 


# The path to put into the final .f is the relative to the place where the toplevel .f exists
my $final_path_to_f = "$path_to_f_mod";
my $ffile_to_parse = "$path_to_f_mod$fname";

open CURSUBFLISTTHREE, "<" . "$ffile_to_parse" or die("Could not open input file '$ffile_to_parse'!");

 while (my $subline = <CURSUBFLISTTHREE>) {
   # print "\n Subline 3 is $subline";
   if ($subline =~ /-f (.*.f)/i ) {
     expand_filelist3($1, $final_path_to_f);
 #   print "\n\n 3 Finished expanding $current_filelist\n\n";
   } else {
     expand_line($subline, $final_path_to_f);  
   }  
 }
#close CURSUBFLIST;
}


# Subroutine to expand each individual line that isnt a -f line
sub expand_line($)
{

# .f name being worked on
 my $line = shift(@_);

# Path to the .f being worked on
 my $path_to_f_in=shift(@_);
    $path_to_f="$path_to_f_in/";

 my $new_path;     

     if ($line =~ /-f (.*.f)/i ) {
       print "\n\nSUB Need to expand this in \n";

     } elsif ($line =~ /\.(v|sv|svh|vh|vhd|vhdl)/ ) {
       $new_path = check_path_type($path_to_f, $line);
       print NEWFLIST "$new_path";
       
     } elsif ($line =~ /^(\+incdir\+)(.*)/ ) {
       $new_path = check_incdir_path_type($path_to_f, $2);
       $new_path = get_full_path($new_path);
       print NEWFLIST "+incdir+$new_path\n";

     } elsif ($line =~ /^(\-incdir )(.*)/ ) {
       $new_path = check_incdir_path_type($path_to_f, $2);
       print NEWFLIST "+incdir+$new_path\n";
       
     } elsif ($line =~ /^(\+define\+)(.*)/ ) {
       print NEWFLIST "$1$2\n";

     } elsif ($line =~ /^(\-define )(.*)/ ) {
       print NEWFLIST "+define+$2\n";
     }
   }


#Check for type of path (relative, EnvVar, Full)
sub check_path_type($)
{
 my $path_to_f = shift(@_);
 my $line = shift(@_);
 my $return_line = "";

if ($ENV{KEEP_PATHS} == 0) {

 # Substitute env Var
  if ($line =~ s/\${?(\w+)}?/$ENV{$1}/ ) {
    $return_line=$line;
#    print "ENV VAR === $ENV{$1}\n"
 # Check for ./ notation   
  } elsif ($line =~ s/(^.\/)(\w+)/$2/ ) {
    $return_line="$path_to_f$line";
 # Check for full path 
  } elsif ($line =~ /^\// ) {
    $return_line="$line";
 # Check for ../ notation   
  } elsif ($line =~ /^..\// ) {
    $return_line="$path_to_f$line";
  } else  {
    $return_line="$path_to_f$line";
  }
}

else {
    $return_line=$line;
}


## Clean up ./ and //  
  if ($return_line =~ s/\/\.\//\// ){
  }
  
  if ($return_line =~ s/\/\//\// ){
  }
  
  if ($full_paths && !($line =~ /^\// ) && ($ENV{KEEP_PATHS} == 0)) {
    $return_line = get_full_path($return_line);
    if ($return_line eq "") {
      die("Check the content of your manifest file, could not open $line");
    } 
  }  
#print "IN CHECK RETURN = $return_line\n";
 return ($return_line) 
}

#Check for type of path (relative, EnvVar, Full)
sub check_incdir_path_type($)
{
 my $path_to_f = shift(@_);
 my $line = shift(@_);


 # Substitute env Var
  if ($line =~ s/\${?(\w+)}?/$ENV{$1}/ ) {
    $path_to_f="$line";
 # Check for ./ notation   
  } elsif ($line =~ /^.\// ) {
    $path_to_f="$path_to_f$line";
 # Check for full path 
  } elsif ($line =~ /^\// ) {
    $path_to_f="$line";
 # Check for ./ notation   
  } elsif ($line =~ /^..\// ) {
    $path_to_f="$path_to_f$line";
  } else {
    $path_to_f="$path_to_f$line";
  }
 return ($path_to_f) 
}

sub get_full_path($) {
my $full_path = shift(@_);

$full_path = abs_path($full_path);

}

close CURFLIST;
close NEWFLIST;
