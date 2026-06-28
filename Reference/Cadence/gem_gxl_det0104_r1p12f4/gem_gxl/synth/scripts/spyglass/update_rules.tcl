## This goal was updated on recommendation from Atrenta.  It will be included in future releases of the IPKit.
   current_goal constraints/sdc_check
   set_goal_option ignorerules Clk_Gen23
   set_goal_option addrules Clk_Gen23a
   
## Additonal rule requested by sumana@cadence.com 23/09/14
   current_goal lint/lint_rtl
   set_goal_option addrules W238
   set_goal_option addrules UndrivenOutTermNLoaded-ML
   set_goal_option addrules W162
   set_goal_option addrules W163
   set_goal_option addrules W164

## Generate labels cause issues in DC.  RUle addition requested by kamild on 23/01/15
   set_goal_option addrules NoGenLabel-ML

   current_goal cdc/cdc_setup_check
## This rule does not give any worthwile information and is likely to be removed by Atrenta 
   set_goal_option ignorerules Setup_req01 

   current_goal cdc/cdc_verify_struct 
## This rule does not give any worthwile information and is likely to be removed by Atrenta 
   set_goal_option ignorerules Setup_req01 
#   set_goal_option report {cdc_matrix}
## Recommended replacement from Atrenta for  ipkit/atrenta_5.2.1_v1 
   set_goal_option ignorerules Ac_coherency01a 
   set_goal_option ignorerules Ac_coherency02a 
   set_goal_option addrules Ac_conv01
   set_goal_option addrules Ac_conv02
   
   current_goal cdc/cdc_verify
## This rule does not give any worthwile information and is likely to be removed by Atrenta 
   set_goal_option ignorerules Setup_req01 
## Recommended replacement from Atrenta for  ipkit/atrenta_5.2.1_v1 
   set_goal_option ignorerules Ac_coherency01a 
   set_goal_option ignorerules Ac_coherency02a 
   set_goal_option addrules Ac_conv01
   set_goal_option addrules Ac_conv02
