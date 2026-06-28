

module tb_datasync ( );

  timeprecision 10ps;
  timeunit      10ps;

  //--------------------------------------------------------------------
  // Local parameters
  //--------------------------------------------------------------------
  localparam               CLK_FACTOR = 1;
  
  localparam                 AD_WIDTH = 32'd6;                         // Address width
  localparam    [AD_WIDTH:0] DEPTH    =   'd64;                        // Number of RAM words 
  localparam          [13:0] MAX_FILL = DEPTH - 'd4;
  localparam    [AD_WIDTH:0] GRAY_GAP = 2**AD_WIDTH - DEPTH;
  localparam             AD_WIDTH_P_1 = AD_WIDTH+32'd1;
  localparam             AD_WIDTH_M_1 = AD_WIDTH-32'd1;

  logic            reset_clock_if_n;
  logic            reference_rst;
  logic            reference_clk;
  logic            reference_ppm_rst;
  logic            reference_ppm_clk;
  integer          ppm_tol = 0;
  reg              [AD_WIDTH:0] push_cnt_r;               // FIFO push counter - binary
  reg              [AD_WIDTH:0] push_cnt_plus;            // FIFO push counter adder - binary
  reg              [AD_WIDTH:0] push_cnt_gray_r;          // FIFO push counter - gray registered

  reg              [AD_WIDTH:0] push_cnt_gray_synch;      // FIFO push counter - gray registered

  

// -----------------------------------------------------------------------------
// 1.0 Generate Primary clocks
// -----------------------------------------------------------------------------

  cdn_clk_rst_gen_block reference_clk_rst();                     // Refernce clk connected to tx mac, tx serdes and rx mac
  cdn_clk_rst_gen_block reference_ppm_clk_rst();                 // Refernce clk with ppm diff connected to rx serdes

// -----------------------------------------------------------------------------
// 2.0 Setup Primary clocks
// -----------------------------------------------------------------------------
  // Set up primary clocks at time zero 
  initial begin
  
    reference_clk_rst.clock_name          = " Reference Clk ";
    reference_ppm_clk_rst.clock_name      = " Reference PPM Clk ";
    reset_clock_if_n                      = 1'b0;
    
    reference_clk_rst.clk_freq            = (100*CLK_FACTOR);
    reference_ppm_clk_rst.clk_freq        = (100*CLK_FACTOR);
    
    reference_clk_rst.rst_slave           = 1;
    reference_ppm_clk_rst.rst_slave       = 1;
    
    reference_clk_rst.reset_off_delay     = 4;
    reference_ppm_clk_rst.reset_off_delay = 4;
    
    reference_clk_rst.jitter_max          = 0.2;
    reference_ppm_clk_rst.jitter_max      = 0.2;
    reference_clk_rst.skew_offset         = 0.2;
    reference_ppm_clk_rst.skew_offset     = 0.2;
    
    void'(randomize(ppm_tol) with { ppm_tol inside {[-1000:1000]};} );
    
    reference_ppm_clk_rst.ppm_tol         = ppm_tol;
    
    #100ns;
    
    reset_clock_if_n                      = 1'b1;

    #100us;
    
    $stop;
    
  end
  
  assign reference_clk_rst.sys_reset_n      = reset_clock_if_n;
  assign reference_ppm_clk_rst.sys_reset_n  = reset_clock_if_n;
    
  assign reference_rst                      = reference_clk_rst.reset_out_n;
  assign reference_clk                      = reference_clk_rst.clk_out;

  assign reference_ppm_rst                  = reference_ppm_clk_rst.reset_out_n;
  assign reference_ppm_clk                  = reference_ppm_clk_rst.clk_out;

// -----------------------------------------------------------------------------
// 3.0 Stimulus
// -----------------------------------------------------------------------------

  // Gray code gen
  //------------------------------
  always@(*)
  begin : PUSH_PLUS
    if ({1'b0,push_cnt_r[AD_WIDTH-1:0]} < (DEPTH - {{AD_WIDTH_M_1{1'b0}},1'b1})) begin
      push_cnt_plus               = push_cnt_r + 1'b1;
    end
    else begin
      push_cnt_plus[AD_WIDTH-1:0] = {AD_WIDTH{1'b0}};
      push_cnt_plus[AD_WIDTH]     = !push_cnt_r[AD_WIDTH];
    end
  end

  always@(posedge reference_clk or negedge reference_rst)
  begin: PUSH_CNT_PROC
    if (reference_rst == 1'b0) begin
      push_cnt_r      <= {AD_WIDTH_P_1{1'b0}};
      push_cnt_gray_r <= {AD_WIDTH_P_1{1'b0}};
    end
    else begin
      push_cnt_r                  <=  push_cnt_plus;
      if (push_cnt_plus[AD_WIDTH] == 1'b0) begin  
        push_cnt_gray_r           <=  binary2gray(push_cnt_plus);
      end
      else begin
        push_cnt_gray_r           <=  binary2gray(push_cnt_plus + GRAY_GAP);
      end
    end
  end

  // rand events
  //------------------------------

  
  logic [AD_WIDTH:0] rand_events;
  logic [AD_WIDTH:0] rand_events_sync;
  
  genvar rand_ind;
  generate
  
    for (rand_ind=0; rand_ind<=AD_WIDTH; rand_ind++) begin: RAND_BIT_GEN
    
      integer unsigned rand_cycles; 
      
      initial begin
        
        rand_cycles           = 10;
        rand_events[rand_ind] = 1'b0; 
      
        forever begin
        
          @(posedge reference_clk);
          
          if (rand_cycles == 0) begin
            void'(randomize(rand_cycles) with { rand_cycles inside {[2:50]};});
            rand_events[rand_ind] = !rand_events[rand_ind];
          end
          else begin
            rand_cycles--;
          end
          
        end
        
      end
      
    end
    
  endgenerate
  
      
// -----------------------------------------------------------------------------
// 4.0 Gray coded sync DUT
// -----------------------------------------------------------------------------
    
  cdnsdru_datasync_v1 #(
    .CDNSDRU_DATASYNC_RESET_STATE           (`CDNSDRU_DATASYNC_RESET_STATE), // Reset state of the internal metastability registers.
    .CDNSDRU_DATASYNC_SYNC_RESET            (`CDNSDRU_DATASYNC_SYNC_RESET),  // Use synchronous reset (results in no reset on flops).
    .CDNSDRU_DATASYNC_NUM_FLOPS             (`CDNSDRU_DATASYNC_NUM_FLOPS),   // Number of serial flops - should probably never vary from 2
    .CDNSDRU_DATASYNC_DIN_W                 (AD_WIDTH_P_1),         // Width of the input bus
    .CDNSDRU_DATASYNC_ENABLE_RANDOMIZATION  (1'b1),                 // Only used in conjunction with vunit
    .CDNSDRU_DATASYNC_META_WINDOW           (3)                     // Define the randomization window before the clock edge (ns)
  ) test_ffsync_gray (
    .clk     (reference_ppm_clk),
    .reset_n (reference_ppm_rst),
    .din     (push_cnt_gray_r),
    .dout    (push_cnt_gray_synch)
  );

  genvar ind;
  generate
    for(ind=0; ind<=AD_WIDTH; ind=ind+1)
    begin:LNC_SYNC
      cdnsdru_datasync_v1 # (
        .CDNSDRU_DATASYNC_RESET_STATE           (`CDNSDRU_DATASYNC_RESET_STATE), // Reset state of the internal metastability registers.
        .CDNSDRU_DATASYNC_SYNC_RESET            (`CDNSDRU_DATASYNC_SYNC_RESET),  // Use synchronous reset (results in no reset on flops).
        .CDNSDRU_DATASYNC_NUM_FLOPS             (`CDNSDRU_DATASYNC_NUM_FLOPS),   // Number of serial flops - should probably never vary from 2
        .CDNSDRU_DATASYNC_DIN_W                 (1'b1),         // Width of the input bus
        .CDNSDRU_DATASYNC_ENABLE_RANDOMIZATION  (1'b1),                 // Only used in conjunction with vunit
        .CDNSDRU_DATASYNC_META_WINDOW           (3)                     // Define the randomization window before the clock edge (ns)
      ) test_ffsync_bits (
        .clk     (reference_ppm_clk),
        .reset_n (reference_ppm_rst),
        .din     (rand_events[ind]),
        .dout    (rand_events_sync[ind])
      );

    end
  endgenerate

// -----------------------------------------------------------------------------
// X.0 Assertions
// -----------------------------------------------------------------------------
  assert_one_bit_gray_code_change : assert property (
    @(posedge reference_clk)
      disable iff (!reference_rst)
      !$stable(push_cnt_gray_r) |=>
        ((($past(push_cnt_gray_r)^push_cnt_gray_r)&(($past(push_cnt_gray_r)^push_cnt_gray_r)-'d1)) == 'd0)
  );

// -----------------------------------------------------------------------------
// X.0 functions
// -----------------------------------------------------------------------------
  // -----------------------------------------------------------------------
  //                    Binary & Gray Converter Functions
  // -----------------------------------------------------------------------
  function [AD_WIDTH:0] binary2gray; // Binary to Gray code conversion
    input [AD_WIDTH:0] bin;
    binary2gray = (bin>>1) ^ bin;
  endfunction

  function [AD_WIDTH:0] gray2binary; // Gray to Binary code conversion
    input [AD_WIDTH:0] gray;
    integer i;
    reg result;

    for (i=0; i<=AD_WIDTH; i=i+1) begin
      result = ^(gray>>i);
      gray2binary[i] = result;
    end
  endfunction

  
endmodule
