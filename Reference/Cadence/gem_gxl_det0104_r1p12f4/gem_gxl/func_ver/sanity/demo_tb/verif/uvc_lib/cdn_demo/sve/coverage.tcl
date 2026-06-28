
select_coverage -all

####################################
#set_com is useful to use but user must be aware that the tb must not have constructs like
# logic rst_n = 0;  During the constant analysis the tool will interprit reset as always being 0 even
#   if it is being controlled elsewhere
#  Another alternative is to use set_com and have -covdut set to your DUT and not the TB
#set_com -nounconnect -logreuse
####################################

set_expr_scoring -control
# set_expr_scoring -all is being deprecated and might not be supported in future versions

#  Recommended replacements are the next two lines
set_expr_coverable_operators -all
#set_expr_coverable_statements -all

#use the following if the DUT is underdevelopment
#set_code_fine_grained_merging
set_toggle_portsonly

#set_toggle_excludefile -bitexclude

# Allow for immediate assertions to be captured at elab time - used for coverage mapping
select_functional -imm_asrt_class_package

# Deselect BIND Modules for code coverage reporting
deselect_coverage -bet -sysv_bind_modules

## Need advice for projects that utilize SV for

# Covergroup options

# "Typical" switches to remove coverage
set_implicit_block_scoring -off
deselect_coverage -remove_empty_instances

 
