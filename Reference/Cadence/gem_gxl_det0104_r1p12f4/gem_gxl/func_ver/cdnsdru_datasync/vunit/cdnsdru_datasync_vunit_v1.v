//------------------------------------------------------------------------------
//
//            CADENCE                    Copyright (c) 2014
//                                       Cadence Design Systems, Inc.
//                                       All rights reserved.
//
//  This work may not be copied, modified, re-published, uploaded, executed, or
//  distributed in any way, in any medium, whether in whole or in part, without
//  prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
//
//   Author                : smckelvi@cadence.com
//
//   Date                  : 2nd November, 2014
//
//
//------------------------------------------------------------------------------
//
// Usage details :
// ---------------
//
// This vuint is intended to be used with cdnsdru_datasync to give 
// randomisation and coverage.
//
// To enable the random synchronizer please include this vunit in the compile 
// with the irun switch -propfile_vlog <vunit_path>/cdnsdru_datasync_vunit.v
// This will enable a random extra cycle delay through the synchronizer.
// Giving the posiblity of N and N+1 cycles where 
// N = CDNSDRU_DATASYNC_NUM_FLOPS.
// To override the randomisation set the 
// CDNSDRU_DATASYNC_RANDOMIZATION_DISABLE define. This define is if just the 
// random syncflop needs to be disabled.
//
// The flop delay is chosen at random. To make the actual behaviour slightly 
// more realistic the delay through the synchronizer is only adjusted if the 
// data changes between the negative and positive edges of the clock. If the 
// whole clock cycle is considered then the syncflop behaviour can become 
// unrealistic.
//
// To randomize the delay through the synchronizer the $urandom() function is
// used. The seed for the $urandom() function is set by the -svseed on the
// irun command line, using the -svseed switch.
//
// The recommendation is to not deliver this module to customers and to
// instead replace with the standard (in rtl directory) synchronization 
// module. Most DIP has differing configuration mechanisms, so there is not 
// one solution for all IP. It's therefore the RTL owner's decision to 
// determine how this module is replaced with a standard syncflop for customer 
// deliveries. Within the re-use repository 2 synchronizers exist, one in 
// the verif directory (this one) and one at the level above. The one at the 
// level above can be replaced with the random version.
// 
// Coverage also exists in this module, covering 2 and 3 cycle delays through
// the synchronizer for falling and rising edges. This coverage can be used to
// determine if the verification environment has clock settings that allow
// randomization to happen. Coverage can also be collected for all
// synchronizers to ensure random delays are occurring at each synchronizer.
//
// This module additionally does not support Verilog 2001 or Verilog 1995 as
// coverage is collected. The module must therefore be compiled with the
// system verilog switch set. For customer delivery, the syncflop within the
// rtl directory should be used, which is Verilog 2001 compatible.
//
// Please note that CDNSDRU_DATASYNC_META_WINDOW parameter should be kept 
// to an integer value in the parameterisation section in order to avoid
// any issues with synthesis tool support.
//
// Description :
// -------------
//
// Very simple block, assuming you ignore the CDNS define, that includes a 
// metastability filter, with a configurable depth and reset state.
//
// This block also has an additional "MDV" verification mode where the delay 
// through the synchronizer can vary between 2 and 3 clocks. The flop delay
// is chosen at random. To make the actual behaviour slightly more realistic
// the delay through the synchronizer is only adjusted if the data changes
// in a 3ns window before the clock edge - this mimics a real life system, 
// where inputs changing just before the clock edge may transition either way.
// 
// To make this work for buses, using gray code synchronisation as an example,
// when the input changes faster than the destination clock,  we need to take
// into account some special scenarios. Take a gray counter counting up from 
// 0-2, which in gray will go 0, 1, 3. Assuming the 0, 1, 3 occurs within one 
// clock of the destination clock then we can't randomly delay bits 0 and 1 
// through the synchronizer, as we could end up with a result of 2 (3 in 
// binary) which is not correct. We therefore only take into account the last 
// bus change - i.e. the transition from 1-3.
//
// We also only consider the case where din changes within the current clock 
// cycle.
// Owing to a high variability in IP configuration there will be some 
// scenarios where the syncflop destination clock is actually the same clock 
// as the source clock, and synchronization is not needed. In this case the 
// data will always change on clock edge and we don't want to start 
// randomizing the synchronization delay when the clocks are actually 
// synchronous.
//
// This block also collects coverage for the following metrics:
//   - Falling -> Rising  edge N   cycle delay
//   - Falling -> Rising  edge N+1 cycle delay
//   - Rising  -> Falling edge N   cycle delay
//   - Rising  -> Falling edge N+1 cycle delay
//
// Implementation Recommendations:
// -------------------------------
//
// When synchronizing signals that are expected to rise and fall at very
// similar times, it's better to synchronize the signals across all in one
// syncflop module, rather than using multiple instantiations of the syncflop.
// For example, if there are 2 signals to synchronize across use 
// CDNSDRU_DATASYNC_DIN_W=2 rather than 2 instantiations. 
// This module counts the number of toggles per input to vary the 
// randomization. This toggle count is per module, so if 2  modules are 
// instantiated with input signals that have an almost identical toggle rate 
// then then both signals can be randomized identically. However, if one 
// instantiations is used then the toggle counts will count toggles for both 
// input signals, so the signals will not have a similar randomization.
//
// Gray coded busses 
// -----------------
// NOTE: When this module is instanced as a bus, i.e. the parameter 
// CDNSDRU_DATASYNC_DIN_W is > 1, the vunit make the assumption that the bus
// is gray coded. That means that it expects ONLY ONE BIT to change on any 
// input clock cycle. If this assumption is violated the vunit will be more 
// optimistic than it should be masking convergence issues. Therefore please
// DO NOT instance a bus on unrelated signals.
//
// To ensure the above assumption holds please add this assertion on the din 
// signals above the synchronisers. It must be clocked of the input domain not
// the synchroniser domain hence it is not included here.
//
//  // check only one bit changes in push gray coded counter
//  assert_one_bit_gray_code_change : assert property (
//    @(posedge <clk_input_domain>)
//      disable iff (!reset_input_n)
//      !$stable(<din_bus_name>) |=>
//        ((($past(<din_bus_name>)^<din_bus_name>)&(($past(<din_bus_name>)^<din_bus_name>)-'d1)) == 'd0)
//  );
//------------------------------------------------------------------------------

vunit cdnsdru_datasync_vunit_v1 (cdnsdru_datasync_v1)
{

  timeunit      10ps;
  timeprecision 10ps;

  // Get the time for a number of points, to ensure we randomize if the
  // signals changes within the 2-3ns clock window for example.
  time                           din_edge_time [CDNSDRU_DATASYNC_DIN_W-1:0];
  time                           din_bus_edge_time;
  time                           meta_window;
  // store the last meta flop value
  logic    [CDNSDRU_DATASYNC_DIN_W-1:0] meta_old;
  // randomised bit to select meta update
  bit      [CDNSDRU_DATASYNC_DIN_W-1:0] no_update_out;

  // Calcuate the sync clock frequency and meta stabelity window
  initial begin
  
    @(posedge clk)
    @(posedge clk)
    
    meta_window         = $time;
    
    @(posedge clk)

    // make the window 1/4 of a cycle
    meta_window         = ($time - meta_window) * 0.25;
    
  `ifndef CDNSDRU_DATASYNC_V1_META_WINDOW_USER
    // take the window that is the smallest
    // this is to avoid the window ending up much larger than the clock period
    // It is still much larger than a real setup window, to get more hits.
    if (meta_window > CDNSDRU_DATASYNC_META_WINDOW*100) 
      meta_window = CDNSDRU_DATASYNC_META_WINDOW*1ns;
  `else
    // User defined meta window
      meta_window = `CDNSDRU_DATASYNC_V1_META_WINDOW_USER * 1ns;
  `endif
      
    //$display("SYNC_DEBUG: Meta Window set to : %d @%d", meta_window, $time);
    
  end

  
  // metastablity control signal
  genvar i_vnt;
  generate 
    for (i_vnt=0; i_vnt<CDNSDRU_DATASYNC_DIN_W; i_vnt = i_vnt+1) begin : gen_sync_rand
    
`ifndef CDNSDRU_DATASYNC_RANDOMIZATION_DISABLE 
  `ifndef CDNSDRU_DATASYNC_SYNTHESIS 
  
      bit      no_update; // randomize can not take a vector slice so need a temp veriable
  
      if (CDNSDRU_DATASYNC_ENABLE_RANDOMIZATION == 1'b1) begin
        // Vary the delay through the synchronizer if MDV is on.
      
        // if there is metastablity then set the first flop back to its old value
        // on the falling edge of the clock
        initial begin
        
          din_edge_time[i_vnt] = $time;
          meta_old[i_vnt]      = meta[i_vnt];
          no_update_out[i_vnt] = 0;
          no_update            = 0;
          
          forever begin
           
            // Record the time of the last clock edge
            @(din[i_vnt])
            
            din_edge_time[i_vnt] = $time;
            meta_old[i_vnt]      = meta[i_vnt];
            
            @(posedge clk)
            
            // The input has changed so randomly choose if this current edge
            // catches the change or if the next edge catches the change.
            if ((($time - din_edge_time[i_vnt])     <= (meta_window))       &&    // Has input changed within the 3ns window before the clock edge
                 (din_edge_time[i_vnt]              == din_bus_edge_time) ) begin // Only take into account the last bus transition -
                                                                                  // see description for more details
              // randomise the metastablity update
              void'(randomize(no_update));
              // this vector is visable from the outside so may be used for cross coverage
              no_update_out[i_vnt]     = no_update;
              
              if  (no_update_out[i_vnt] != 0) begin
                @(negedge clk)
                meta[i_vnt]            = meta_old[i_vnt];
              end
              
              no_update                = 0;
              no_update_out[i_vnt]     = 0;
              
            end
          end
        end
        
      end
      
      // Record the edge time of the last input data to change.
      initial begin
      
        din_bus_edge_time    <= $time;
        
        forever begin
          @(din[i_vnt]);
          din_bus_edge_time    <= $time;
        end
        
      end

  `endif // CDNSDRU_DATASYNC_SYNTHESIS
`endif // CDNSDRU_DATASYNC_RANDOMIZATION_DISABLE
    
`ifdef ABV_ON

      //-------------------------------------------------------
      // Collect coverage
      //-------------------------------------------------------
      // Rising to falling with a CDNSDRU_DATASYNC_NUM_FLOPS cycle delay
      property rising2falling_Ncycle_delay_prop;
        @(posedge clk)
        disable iff (dout[i_vnt] == 1'bx)
        $fell(din[i_vnt] && dout[i_vnt]) |->  ##(CDNSDRU_DATASYNC_NUM_FLOPS) $fell(dout[i_vnt]);
      endproperty
      rising2falling_Ncycle_delay : cover  property (rising2falling_Ncycle_delay_prop);
      
      // Falling to rising with a CDNSDRU_DATASYNC_NUM_FLOPS cycle delay
      property falling2rising_Ncycle_delay_prop;
        @(posedge clk)
        disable iff (dout[i_vnt] == 1'bx)
        $rose(din[i_vnt] && !dout[i_vnt]) |->  ##(CDNSDRU_DATASYNC_NUM_FLOPS) $rose(dout[i_vnt]);
      endproperty
      falling2rising_Ncycle_delay : cover  property (falling2rising_Ncycle_delay_prop);
     
  `ifndef CDNSDRU_DATASYNC_RANDOMIZATION_DISABLE 
    `ifndef CDNSDRU_DATASYNC_SYNTHESIS
  
      if (CDNSDRU_DATASYNC_ENABLE_RANDOMIZATION == 1'b1) begin
      
        // Rising to falling with a CDNSDRU_DATASYNC_NUM_FLOPS+1 cycle delay
        property rising2falling_Np1cycle_delay_prop;
          @(posedge clk)
          disable iff (dout[i_vnt] == 1'bx)
          $fell(din[i_vnt] && dout[i_vnt]) |->  ##(CDNSDRU_DATASYNC_NUM_FLOPS+1) $fell(dout[i_vnt]);
        endproperty
        rising2falling_Np1cycle_delay : cover  property (rising2falling_Np1cycle_delay_prop);
        
        // Falling to rising with a CDNSDRU_DATASYNC_NUM_FLOPS+1 cycle delay
        property falling2rising_Np1cycle_delay_prop;
          @(posedge clk)
          disable iff (dout[i_vnt] == 1'bx)
          $rose(din[i_vnt] && !dout[i_vnt]) |->  ##(CDNSDRU_DATASYNC_NUM_FLOPS+1) $rose(dout[i_vnt]);
        endproperty
        falling2rising_Np1cycle_delay : cover  property (falling2rising_Np1cycle_delay_prop);

      end
    
    `endif // CDNSDRU_DATASYNC_SYNTHESIS
  `endif // CDNSDRU_DATASYNC_RANDOMIZATION_DISABLE
`endif // ABV_ON

      end
    endgenerate
    
}
