# This file contains LINT filters for the Conformal CCD tool.
# Generated for design configuration "pbuf_3qs_axi" on Mon Nov 20 09:34:29 GMT 2017


# ** Anything Not Design Related **
#    There are loads of technology specific warnings in the fail logs.  we can ignore these
  add_rule_filter tech_specific -description "Technologyu specific fails. not design related - Waived." -message "*/process/tsmc*" -rule  hdl_default_checks/* -replace

# ** Signal has input but it has no output **
#    These refer to signals (wires) that are driven in the design but are not sampled by anything.
#    This is due to the design being heavily parameterized with IO signals on some modules only relevant to
#    particular configurations. We cannot remove these as they are relevant in other configs. so they are sometimes floating.
#    There is no real harm here so waiving.
  add_rule_filter hdl_default_checks/rtl_checks/RTL14/1 -description "Signal was driven but not sampled - config specific and no issue. Waived." -message "*" -rule hdl_default_checks/rtl_checks/RTL14 -replace

# ** Fanout load of the signal is removed **
#    similar to RTL14. we are waiving these as it will not cause any functional issue. They cannot be fixed in the RTL without
#    causing other LINT issues to emerge.  For example, consider an adder. The output of the adder is often padded by an extra bit to
#    acccomodate the overflow. the overflow bit is however often ignored and shows up here.
  add_rule_filter hdl_default_checks/rtl_checks/RTL14.1/1 -description "Fanout load of the signal is removed - Waived." -message "*" -rule hdl_default_checks/rtl_checks/RTL14.1 -replace

# ** Unsigned reference with index/part selection to a signed variable **
#    There is nothing wrong here, nor is there a real risk. what is happening is that a genvar or an integer used within a "for" loop
#    is being used within the code itself. By using an index on the variable, it automatically becomes unsigned.
#    genvars and integers seem to be initialized as signed variables here, hence the warning. These can be waived.  
#    There are actually 3 separate warnings to do with signed vs unsigned namely ..
#      1. Unsigned reference with index/part selection to a signed variable ..
#      2. Comparison with signed and unsigned operands ..
#      3. Implicit signed expression is converted to unsigned ..
  add_rule_filter hdl_default_checks/rtl_checks/RTL7.11b -description "using an index on for loop count variable is fine. Waived." -message "*" -rule hdl_default_checks/rtl_checks/RTL7.11b -replace

  add_rule_filter hdl_default_checks/rtl_checks/RTL7.10 -description "genvars and integers are initialized as signed variables. being compared to unsigned integers. No real issue and waived." -message "*" -rule hdl_default_checks/rtl_checks/RTL7.10 -replace

  add_rule_filter hdl_default_checks/rtl_checks/RTL7.11 -description "Notification that signed number is being converted to unsigned - this is as expected as everything in the design is coded as unsigned ." -message "*" -rule hdl_default_checks/rtl_checks/RTL7.11 -replace

