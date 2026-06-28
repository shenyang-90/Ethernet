set clk_overconstraint 1

# Clock aclk, constrained to 62.5Mhz
set aclk_period [expr 16 * $clk_overconstraint]
create_clock [get_ports aclk] -name aclk -period $aclk_period -waveform "0 [expr $aclk_period * 0.50]"

# Clock rx_clk, constrained to 125Mhz
set rx_clk_period [expr 8 * $clk_overconstraint]
create_clock [get_ports rx_clk] -name rx_clk -period $rx_clk_period -waveform "0 [expr $rx_clk_period * 0.50]"

# Clock tsu_clk, constrained to 50Mhz
set tsu_clk_period [expr 20 * $clk_overconstraint]
create_clock [get_ports tsu_clk] -name tsu_clk -period $tsu_clk_period -waveform "0 [expr $tsu_clk_period * 0.50]"

# Clock tx_clk, constrained to 125Mhz
set tx_clk_period [expr 8 * $clk_overconstraint]
create_clock [get_ports tx_clk] -name tx_clk -period $tx_clk_period -waveform "0 [expr $tx_clk_period * 0.50]"

# Clock pclk, constrained to 100Mhz
set pclk_period [expr 10 * $clk_overconstraint]
create_clock [get_ports pclk] -name pclk -period $pclk_period -waveform "0 [expr $pclk_period * 0.50]"

# Clock n_tx_clk, constrained to 125Mhz
set n_tx_clk_period [expr 8 * $clk_overconstraint]
create_clock [get_ports n_tx_clk] -name n_tx_clk -period $n_tx_clk_period -waveform "[expr $n_tx_clk_period * 0.50] $n_tx_clk_period"
  set_false_path  -from aclk -to rx_clk	
  set_false_path  -from aclk -to tsu_clk	
  set_false_path  -from aclk -to tx_clk	
  set_false_path  -from aclk -to pclk	
  set_false_path  -from aclk -to n_tx_clk	
  set_false_path  -from rx_clk -to aclk	
  set_false_path  -from rx_clk -to tsu_clk	
  set_false_path  -from rx_clk -to tx_clk	
  set_false_path  -from rx_clk -to pclk	
  set_false_path  -from rx_clk -to n_tx_clk	
  set_false_path  -from tsu_clk -to aclk	
  set_false_path  -from tsu_clk -to rx_clk	
  set_false_path  -from tsu_clk -to tx_clk	
  set_false_path  -from tsu_clk -to pclk	
  set_false_path  -from tsu_clk -to n_tx_clk	
  set_false_path  -from tx_clk -to aclk	
  set_false_path  -from tx_clk -to rx_clk	
  set_false_path  -from tx_clk -to tsu_clk	
  set_false_path  -from tx_clk -to pclk	
  set_false_path  -from pclk -to aclk	
  set_false_path  -from pclk -to rx_clk	
  set_false_path  -from pclk -to tsu_clk	
  set_false_path  -from pclk -to tx_clk	
  set_false_path  -from pclk -to n_tx_clk	
  set_false_path  -from n_tx_clk -to aclk	
  set_false_path  -from n_tx_clk -to rx_clk	
  set_false_path  -from n_tx_clk -to tsu_clk	
  set_false_path  -from n_tx_clk -to pclk	
set_clock_groups -asynchronous -name gem_gxl_clock_groups  \
  -group  [get_clocks aclk]  \
  -group  [get_clocks rx_clk]  \
  -group  [get_clocks tsu_clk]  \
  -group [ list  [get_clocks tx_clk] [get_clocks n_tx_clk]  ] \
  -group  [get_clocks pclk] 