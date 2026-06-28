//------------------------------------------------------------------------------
//  $Id$
//------------------------------------------------------------------------------
//
//            CADENCE                    Copyright (c) 2015
//                                       Cadence Design Systems, Inc.
//            IPG                        All rights reserved.
//
//  This work may not be copied, modified, re-published, uploaded, executed, or
//  distributed in any way, in any medium, whether in whole or in part, without
//  prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
//
//   Module Name    : cdn_clk_rst_gen_block.sv
//
//   Filename       : cdn_clk_rst_gen_block.sv
//
//   Author         :
//
//   Date           :
//
//   Limitations    :
//
//------------------------------------------------------------------------------
//   Description    : Generic clock block
//
//------------------------------------------------------------------------------
`timescale 1ps/1ps

interface cdn_clk_rst_gen_block ;
  // Configuration
  string            clock_name         = " UNNAMED CLK ";  // name used in the info messages
  real              clk_freq           = 100;             // Clock frequency in MHz
  logic             clk_slave          = 0;               // Use TB ref clock as base
  logic             rst_slave          = 0;               // Use TB ref clock as base
  integer           ppm_tol            = 0;               // PPM tolerance clock.
  real              pll_factor         = 1;               // multiply the ref clock. NOTE: 
                                                          //  - a number > 1 will give a slower clock
                                                          //  - a number < 1 will give a faster clock
  real              jitter_max         = 0;               // Max jitter between 0-1 cycle - 0 is off
  real              skew_offset        = 0;               // fixed offset of rising edge
  real              duty_cycle         = 0.5;             // Define the mark/space ratio 0-1 - NOTE not implimented yet
  integer           clk_startup_delay  = 0;               // number of clock cyles before clock is seen externaly
  integer           reset_off_delay    = 1;               // number of clock cyles after sys reset is released 
  logic             verbose            = 0;               // up the info mesages
  
  // clocks and reset inputs
  logic             sys_reset_n;        // Reset from the test bench may be tied high
  logic             ref_clk;            // Test bench reference clock may be tied off
  logic             en_clk;             // gate the clock as required synchronous active high enable
  
  // clock and reset outputs
  logic             reset_out_n;        // generated reset
  logic             clk_out;            // generated clock
  logic             locked_out;         // clock is running and stable
  
  // internals signals
  logic             int_gen_rst    = 1'b0;  // Internal reset
  logic             int_gen_clk    = 1'b0;  // Internally generated clock
  //logic             sel_clk;                // Ref/Internal selected clock 
  logic             skew_clk;               // Internal skewed clock
  logic             jit_clk;                // Internal jitered clock
  logic             en_clock_align = 1'b0;  // synchronised clock enable
  integer unsigned  lock_count     = 0;     // lock signal counter
  logic             int_locked;

  //--------------------------------------------------------------------------//
  // internal reset generation
  //--------------------------------------------------------------------------//
  initial begin
  
    #1
    
    if (rst_slave == 1'b0) begin

      $display("CLK BLOCK - %20s@%10tps: Generating reset",clock_name,$time);
      int_gen_rst = 1'b0;
      #10;
      int_gen_rst = 1'b1;
      
    end
    else begin 
    
      $display("CLK BLOCK - %20s@%10tps: Reset slave",clock_name,$time);
      forever begin
        @(sys_reset_n)  int_gen_rst = sys_reset_n;
      end
    
    end

  end

  //--------------------------------------------------------------------------//
  // internal clock generation
  //--------------------------------------------------------------------------//
  real            clk_freq_ppm;
  real            clk_freq_last;
  real            clk_per_real;
  real            clk_half_per_real;
  integer         clk_half_per_int;
  real            clk_err_real;
  
  initial
  begin

    #1
  
    clk_freq_ppm      = clk_freq * 1.0e6 + (clk_freq * $itor(ppm_tol));
    clk_freq_last     = -1;
    clk_err_real      = 0;
    clk_per_real      = 100;
    clk_half_per_int  = 1;
    clk_half_per_real = 1;
    int_gen_clk       = 1'b0;
    
    forever begin
    
      while (clk_slave == 1'b0) begin

        if (clk_freq_ppm != clk_freq_last) begin
          clk_per_real   = (1/clk_freq_ppm) * 1.0e12; // period in ps if the timescale is changed change this also
          clk_err_real   = 0;
          int_gen_clk    = 1'b0;
          lock_count     = 0;
        end
        
        clk_freq_last       = clk_freq_ppm;
        clk_freq_ppm        = clk_freq * 1.0e6 + (clk_freq * $itor(ppm_tol));
        clk_half_per_real   = (clk_per_real / 2) + clk_err_real;
        clk_half_per_int    = $rtoi(clk_half_per_real);
        clk_err_real        = clk_half_per_real - $itor(clk_half_per_int);

        #(clk_half_per_int);
        int_gen_clk  = ~int_gen_clk;

      end
      
      #(clk_half_per_int);
      int_gen_clk  = 1'b0;

      $display("CLK BLOCK - %20s@%10tps: Using reference clock",clock_name,$time);
      @(clk_slave);
      $display("CLK BLOCK - %20s@%10tps: Switching to internal clock",clock_name,$time);

    end
  end

  //--------------------------------------------------------------------------//
  // PLL for ref clock
  //--------------------------------------------------------------------------//
  // NOTE: only reliable with interger multipuls 
  // needs to be corrected at some point
  //assign sel_clk = (clk_slave == 1'b1) ? ref_clk : int_gen_clk;
  
  // Multiply the selected frequncy by PLL factor
  real             pll_half_per_real;
  real             pll_half_per_int;
  real             pll_err_real;
  real             pll_err_real_acc;
  time             pll_edge;
  logic            pll_clk;
  logic            pll_or_sel_clk;
  real             pll_factor_last;
  logic            factor_update;

  real             av_half_per;
  real             acc_half_per;
  integer          edge_count;
  
  integer          div_edge_count;
  bit              pll_factor_is_int;
  
  initial begin
    forever begin
    
      if  ((pll_factor > 1 && (pll_factor   - $rtoi(pll_factor)   == 0)) ||
           (pll_factor < 1 && (1/pll_factor - $rtoi(1/pll_factor) == 0)))   pll_factor_is_int = 1;
      else                                                                  pll_factor_is_int = 0;
      @pll_factor;
      
    end
  end
  
  initial
  begin
  
    pll_half_per_int  = 1;
    factor_update     = 1'b0;
    pll_half_per_real = 1.0;
    pll_err_real      = 0.0;
    av_half_per       = 1.0;
    acc_half_per      = 0.0;
    
    edge_count        = 1;
    
    @(ref_clk);

    pll_factor_last  = pll_factor;

    pll_edge         = $time;
    
    $display("CLK BLOCK - %20s@%10tps: PLL factor initial: %0f",clock_name,$time,pll_factor);

    forever begin
      
      if (pll_factor_is_int && pll_factor > 1) begin
        @pll_factor;
        #1ps;
      end
      else begin
        while (pll_factor != 1) begin
        
          @(ref_clk);
          pll_half_per_real = $itor($time - pll_edge) * pll_factor;
          pll_half_per_int  = $rtoi(pll_half_per_real + pll_err_real);
          pll_err_real      = pll_half_per_real - $rtoi(pll_half_per_int);
          if (pll_factor > 1) begin
            pll_err_real_acc  = pll_err_real_acc + pll_err_real;
          end
          pll_edge          = $time;
        
          if (pll_factor_last != pll_factor) begin
            lock_count    = 0;
            factor_update = 1'b1;
            $display("CLK BLOCK - %20s@%10tps: PLL factor update: %0f",clock_name,$time,pll_factor);
          end
        
          pll_factor_last  = pll_factor;
        
        end
      end
      
      @(pll_factor);
      $display("CLK BLOCK - %20s@%10tps: PLL factor update: %0f",clock_name,$time,pll_factor);
      lock_count       = 0;
      pll_factor_last  = pll_factor;
      
      @(ref_clk);
      pll_edge         = $time;

    end
  end

  initial begin
    pll_clk           = 1'b0;
    pll_err_real_acc  = 0;
    div_edge_count    = 0;
    
    @(posedge ref_clk);
    @(posedge ref_clk);

    forever begin
    
      while (pll_factor != 1) begin
        
        if (pll_factor_is_int && pll_factor > 1) begin
          
          for (div_edge_count = 0; div_edge_count < $rtoi(pll_factor); div_edge_count++) begin
          
            @(ref_clk);
            
          end
          
          pll_clk          <= ~pll_clk;
          
        end
        begin
        
          pll_clk          = ~pll_clk;
          
          // keep the edges in sync if the factor changes
          if (factor_update) begin
          
            if (pll_clk) begin
              #pll_half_per_int;
              pll_clk = 1'b0;
            end
          
            @(posedge ref_clk);
            @(posedge ref_clk);
            
            factor_update    = 1'b0;
            pll_clk          = 1'b1;
            pll_err_real_acc = 0;
            
          end
        
          if (pll_factor < 1) begin
            pll_err_real_acc  = pll_err_real_acc + pll_err_real;
          end
          #(pll_half_per_int + $rtoi(pll_err_real_acc));
          pll_err_real_acc = pll_err_real_acc - $rtoi(pll_err_real_acc);

          
        end
      
      end
      
      #pll_half_per_int;
      pll_clk = 1'b0;
      
      @(pll_factor or sys_reset_n);
      @(posedge ref_clk);
      @(posedge ref_clk);

    end
  end
  
  assign pll_or_sel_clk = int_gen_clk | pll_clk;
  
  //--------------------------------------------------------------------------//
  // clock conditioning
  //--------------------------------------------------------------------------//
  
  // skew by skew_offset, fraction of a clock cycle
  integer unsigned skew_edge_delay;
  time             rs_skew_edge;
  real             skew_offset_last;
  integer unsigned current_period = 0;
  
  integer unsigned jit_edge_delay = 0;
  integer unsigned jit_limit      = 0;
  
  // calulate the skew when ever the offset changes
  initial
  begin
    skew_edge_delay   = 0;
    rs_skew_edge      = $time;
    
    @(posedge pll_or_sel_clk);
        
    if (skew_offset != 0.0) begin
      $display("CLK BLOCK - %20s@%10tps: Initial skew set to: %0f",clock_name,$time,skew_offset);
    end
    else begin
      if (verbose == 1'b1) $display("CLK BLOCK - %20s@%10tps: Skew disabled",clock_name,$time);
    end
    
    if (jitter_max != 0.0) begin
      $display("CLK BLOCK - %20s@%10tps: Jitter enabled - %0f",clock_name,$time,jitter_max);
    end
    else begin
      if (verbose == 1'b1) $display("CLK BLOCK - %20s@%10tps: Jitter disabled",clock_name,$time);
    end
    
    forever begin
    
      while (skew_offset != 0.0 || jitter_max != 0.0) begin
      
        rs_skew_edge = $time;
        @(posedge pll_or_sel_clk);
        $cast(current_period,$time - rs_skew_edge);
        if (skew_offset != 0.0) begin
          skew_edge_delay  = $rtoi(skew_offset * $itor(current_period));
        end
        else begin
          skew_edge_delay  = 0;
        end
        if (jitter_max != 0.0) begin
          jit_limit         = $rtoi((jitter_max/2) * $itor(current_period));
          void'(randomize(jit_edge_delay) with { jit_edge_delay <=  (jit_limit*2);} );
          if (jit_edge_delay >= skew_edge_delay) begin
            skew_edge_delay  = 0;
          end
          else begin
            skew_edge_delay  = (skew_edge_delay-jit_limit) + jit_edge_delay;
          end
        end
        
        skew_offset_last = skew_offset;
        if (skew_offset_last != skew_offset) 
          $display("CLK BLOCK - %20s@%10tps: New skew set to: %0f",clock_name,$time,skew_offset);
          
      end
      
      skew_edge_delay = 0;
      
      @(skew_offset or jitter_max);
      $display("CLK BLOCK - %20s@%10tps: Skew update - %0f",clock_name,$time,skew_offset);
      $display("CLK BLOCK - %20s@%10tps: Jitter update - %0f",clock_name,$time,jitter_max);

    end
  end
  
  always@(*) begin
    if (skew_offset != 0.0 || jitter_max != 0.0) 
      jit_clk <= #skew_edge_delay pll_or_sel_clk;
    else
      jit_clk <= pll_or_sel_clk;
  end
  
  //--------------------------------------------------------------------------//
  // lock and reset generatation
  //--------------------------------------------------------------------------//
  // generate locked signal
  
  initial
  begin
    int_locked = 1'b0;
    
    //@(posedge int_gen_rst);
    @(negedge jit_clk);
    
    forever begin
    
      while (lock_count < clk_startup_delay + 2) begin
      
        @(negedge jit_clk);
        lock_count = lock_count + 1;
        
      end
      
      int_locked = 1'b1;
      
      if (clk_slave == 0) begin
        $display("CLK BLOCK - %20s@%10tps: Fequency set to: %8fMHz | PPM set to: %4d | Actual : %8fMHz ",
            clock_name,$time,clk_freq,ppm_tol,clk_freq_ppm);
      end

      @(lock_count or negedge int_gen_rst);
      lock_count = 0;
      int_locked = 1'b0;

    end
    
  end
  
  // generate reset signal
  integer unsigned reset_count;
  logic            reset_n;

  initial
  begin
    reset_n     = 1'b0;
    reset_count = 0;
    
    @(posedge int_gen_rst);
    
    forever begin
    
      while (reset_count < reset_off_delay) begin
        @(negedge jit_clk)
        reset_count = reset_count + 1;
      end
      
      reset_n     = 1'b1;
      $display("CLK BLOCK - %20s@%10tps: Reset released",clock_name,$time);
      @(negedge int_gen_rst);
      reset_n     = 1'b1;
      reset_count = 0;
      
    end

    
  end

  //--------------------------------------------------------------------------//
  // Assign outputs
  //--------------------------------------------------------------------------//
  initial begin
    en_clock_align = 1'b0;
    #1ps;
    
    if (en_clk == 1'b0 || en_clk == 1'b1)
      en_clock_align = en_clk;
    else
      en_clock_align = 1'b1;
      
    forever begin
      @en_clk;
      @(negedge jit_clk)
      en_clock_align = en_clk;
    end
  end
            
  assign  clk_out     = (int_locked && en_clock_align) ? jit_clk : 1'b0;
  assign  reset_out_n =  reset_n;
  assign  locked_out  =  int_locked;

  //--------------------------------------------------------------------------//
  // Mesure and check the outputs
  //--------------------------------------------------------------------------//
  
  
    // Check the skew and select the edge furthest for mesuring
    time             check_fast_clk_period;
    bit              fast_clk_sel;
    time             check_edge_dist;
    bit              check_edge_select;
    
    bit              fast_clk;
    bit              slow_clk;
    bit              cont_check;
    bit              check_en;
    
    initial begin
      forever begin
        while (check_en) begin
          if (pll_factor > 1) begin
            @ref_clk;
            if (check_edge_select)  fast_clk =  ref_clk;
            else                    fast_clk = !ref_clk;
          end
          else begin
            @pll_clk;
            if (check_edge_select)  fast_clk =  pll_clk;
            else                    fast_clk = !pll_clk;
          end
        end
        @check_en;
      end
    end
    initial begin
      forever begin
        while (check_en) begin
          if (pll_factor < 1) begin
            @ref_clk;
            slow_clk =  ref_clk;
          end
          else begin
            @pll_clk;
            slow_clk =  pll_clk;
          end
        end
        @check_en;
      end
    end
    
    initial
    begin
    
      check_fast_clk_period    = 0;
      check_edge_select        = 0;
      check_edge_dist          = 0;
      
      @(posedge fast_clk);
      @(posedge fast_clk);
      
      check_edge_dist         = $time;
      @(posedge fast_clk);
      check_fast_clk_period    = $time - check_edge_dist;
      
      @(posedge slow_clk);
      @(posedge slow_clk);
      @(posedge slow_clk);
      check_edge_dist      = $time;
      
      @(posedge fast_clk);
      check_edge_dist         = $time - check_edge_dist;
      
      if (((check_edge_dist >= 0)                           && (check_edge_dist <= check_fast_clk_period * 0.2)) ||
          ((check_edge_dist >= check_fast_clk_period * 0.8) && (check_edge_dist <= check_fast_clk_period + 1)))
        check_edge_select       = 1;
        
      @(posedge slow_clk);
      @(posedge slow_clk);
      @(posedge slow_clk);
      
    end
        
    //assign fast_clk      =  (pll_factor > 1)   ?  (check_en | ref_clk  ): (check_en |jit_clk );
    //assign slow_clk      =  (pll_factor < 1)   ?  (check_en | ref_clk  ): (check_en |jit_clk );
    //assign fast_clk_sel  =   check_edge_select ? !(check_en | fast_clk ): (check_en |fast_clk);
    
    
    integer  clk_ratio_count   = 0;
    bit      clock_fault       = 0;
    real     clock_ratio       = 0;
    
    initial begin
    
      check_en                 = 1;

      @(posedge fast_clk);
        
      forever begin
        if ((en_clk != 1'b0) && (clk_slave != 1'b0) && pll_factor_is_int) begin
        
          fork 
            begin
              forever begin
              
                @(posedge fast_clk);
                clk_ratio_count++;
               
              end
            end
            begin
              forever begin
              
                @(posedge slow_clk);
                #1ps;
                
                if (int_gen_rst) begin
                  if (((clk_ratio_count ==   pll_factor) && (pll_factor > 1)) || 
                      ((clk_ratio_count == 1/pll_factor) && (pll_factor < 1)))  begin
                    clock_ratio      = pll_factor;
                  end
                  else begin
                    clock_ratio     = clk_ratio_count;
                    clock_fault     = 1;
                  end
                  if (cont_check!=1) begin
                    check_en                 = 0;
                  end
                end
                clk_ratio_count     <= 0;
                
              end
              
            end
          join
          
        end
        else begin
        
          check_en                 = 0;
          @((en_clk != 1'b0) && (clk_slave != 1'b0) && pll_factor_is_int);
          check_en                 = 1;
          
        end
        
      end
    end
    
  //end 

endinterface : cdn_clk_rst_gen_block
