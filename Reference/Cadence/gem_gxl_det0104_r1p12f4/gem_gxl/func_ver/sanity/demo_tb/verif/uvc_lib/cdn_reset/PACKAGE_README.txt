#------------------------------------------------------------------------------
# Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
#------------------------------------------------------------------------------
******************************************************************************
* Title: RESET UVC
* Name: cdns_reset
* Version: 1.0
* Requires:
  UVM {1.1.}
* Modified: Nov-2012
* Category: 
* Support: Cadence SOC Realization
* Documentation:  

* Description:

This UVC encapsulates the reset signal and associated coverage and
checks.

It is important to set the `DEFINES to control the clock period (for
sequences) and if the reset is active high or active low.

* Directory structure:

This package contains the following directories:
 
  sv/        - SystemVerilog sources.
  examples/  - Contains a simple use case example.
  docs/      - Contains release notes and any other documentation.

* To demo:

Run the demo.sh script.

