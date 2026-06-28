//------------------------------------------------------------------------------
// Copyright (c) 2001-2017 Cadence Design Systems, Inc.
//
// The information herein (Cadence IP) contains confidential and proprietary
// information of Cadence Design Systems, Inc. Cadence IP may not be modified,
// copied, reproduced, distributed, or disclosed to third parties in any manner,
// medium, or form, in whole or in part, without the prior written consent of
// Cadence Design Systems Inc. Cadence IP is for use by Cadence Design Systems,
// Inc. customers only. Cadence Design Systems, Inc. reserves the right to make
// changes to Cadence IP at any time and without notice.
//------------------------------------------------------------------------------
//
//   Filename:           tb_rgmii.v
//   Module Name:        tb_rgmii
//
//   Release Revision:   r1p12f2
//   Release SVN Tag:    gem_gxl_det0104_r1p12f2
//
//   IP Name:            GEM Gigabit Ethernet MAC
//   IP Part Number:     IP7014A
//
//   Product Type:       Off-the-shelf
//   IP Type:            Soft
//   IP Family:          Ethernet Controller
//   Technology:         N/A
//   Protocol:           Ethernet
//   Architecture:       N/A
//   Licensable IP:      SIP-Ethernet-MAC+DMA+1588+TSN+PCS+A-10M/100M/1G-IP7014A
//
//------------------------------------------------------------------------------
//   Description    : This is the rgmii_interface module for the Ethernet MAC.
//                    It provides the appropriate interfaces to connect the EMAC
//                    GMII interface and ten bit interface to an RGMII
//                    compatible PHY.
//
//------------------------------------------------------------------------------


// rgmii interface for MAC
module tb_rgmii(
                       // System signals
                       n_rgmii_rxreset,
                       n_rgmii_rx_n_reset,

             `ifdef RGMII_2X_CLOCK // if double speed transmit clock is enabled

                       n_rgmii_2x_tx_reset,
                       rgmii_2x_tx_clk,

             `else                 // if double speed transmit clock is disabled

                       n_rgmii_txreset,
                       n_rgmii_tx_n_reset,
                       rgmii_tx_clk,
                       rgmii_tx_n_clk,

             `endif                // end of `define statement

                       // Clock input signal
                       rgmii_rx_clk,
                       rgmii_rx_n_clk,
                       rbc1_sig,
                       rgmii_tx_clk_sig,

                       // RGMII signals
                       rgmii_txd,
                       rgmii_tx_ctl,
                       rgmii_rxd,
                       rgmii_rx_ctl,

                       // gmii / mii ethernet interface.
                       gmii_col,
                       gmii_crs,
                       gmii_tx_er,
                       gmii_txd,
                       gmii_tx_en,
                       gmii_rxd,
                       gmii_rx_er,
                       gmii_rx_dv,
                       gmii_gigabit,
                       gmii_link_status,
                       gmii_speed,
                       gmii_duplex_in,
                       gmii_duplex_out,

                       // ten bit interface signals.
                       tbi_tx_group,
                       tbi_rx_group,
                       tbi
                       );

//------------------------------------------------------------------------------
// Declare inputs and outputs
//------------------------------------------------------------------------------
   input          n_rgmii_rxreset;     // reset associated with rgmii_rx_clk
   input          n_rgmii_rx_n_reset;  // reset associated with rgmii_rx_n_clk

  `ifdef RGMII_2X_CLOCK    // if 2x clock is selected as transmit clock

   input          rgmii_2x_tx_clk;     // double speed transmit  clock
   input          n_rgmii_2x_tx_reset; // reset associated with rgmii_2x_tx_clk

  `else                   // if double speed transmit clock is disabled

   input          n_rgmii_txreset;     // reset associated with rgmii_tx_clk
   input          n_rgmii_tx_n_reset;  // reset associated with rgmii_tx_n_clk
   input          rgmii_tx_clk;        //transmit clock
   input          rgmii_tx_n_clk;      //out of phase transmit clock

  `endif// end of `define statement

   // Clock inputs
   input          rgmii_rx_clk;        //receive clock
   input          rgmii_rx_n_clk;      //out of phase transmit clock
   input          rbc1_sig;            //receive clock rbc1 from phy.
   input          rgmii_tx_clk_sig;    //transmit clock used as mux select


   // MII signals
   // Note that gmii_col and crs are asynchronous output signals.
   output         gmii_col;             // Indicate collision occured.
   output         gmii_crs;             // Carrier sense signal.
   input    [7:0] gmii_txd;             // Transmit data byte.
   input          gmii_tx_en;           // Transmit enable.
   input          gmii_tx_er;           // transmit error
   output   [7:0] gmii_rxd;             // Receive data byte.
   output         gmii_rx_er;           // Receive error.
   output         gmii_rx_dv;           // Receive data valid.
   input          gmii_gigabit;         // indicates gigabit operation
   output         gmii_link_status;     // indicates link status
   output [1:0]   gmii_speed;           // Rgmii extracted speed signal
   output         gmii_duplex_out;      // Rgmii extracted duplex signal
   input          gmii_duplex_in;       // input duplex signal

   // RGMII signals
   output   [3:0] rgmii_txd;       // Transmit data, nibble.
   output         rgmii_tx_ctl;    // Transmit enable on RGMII.
   input    [3:0] rgmii_rxd;       // Receive data, nibble.
   input          rgmii_rx_ctl;    // Receive error on RGMII.

   // ten bit interface signals.
   input    [9:0] tbi_tx_group;    // 8b/10b encoded transmit data to the phy.
   output   [9:0] tbi_rx_group;    // 8b/10b encoded receive data from the phy
   input          tbi;             // ten bit interface active


   // Wire and reg declarations.
   wire           gmii_col;        // Indicate collision occured.
   wire           gmii_crs;        // Carrier sense signal.
   reg      [7:0] gmii_rxd;        // Receive data byte.
   reg            gmii_rx_er;      // Receive error.
   reg            gmii_rx_dv;      // Receive data valid.
   reg      [3:0] tx_data_neg;     // nibble to be transmitted on neg edge
   reg            tx_ctrl_neg;     // ctrl bit to be transmitted on neg edge
   reg      [3:0] rx_data_pos;     // nibble received on neg edge
   reg            rx_ctrl_pos;     // ctrl bit received on neg edge
   reg      [3:0] rx_data_neg;     // nibble received on neg edge
   reg            rx_ctrl_neg;     // ctrl bit received on neg edge
   reg      [9:0] tbi_rx_group;    // 8b/10b encoded transmit data to the phy.
   reg            crs_dv;          // carrier sense and data valid
   wire     [9:0] rx_code_group;   // reconstructed code group
   reg            comma_detect;    // indicates presence of comma codegroup
   reg            comma_detect_1d; // 1 clock delayed comma_detect signal
   reg      [9:0] rx_code_group_1d;// 1 clock delayed rx_code_group
   reg            mux_sel;         // select signal to align comma to rbc0
   reg            gmii_duplex_out; // Rgmii extracted duplex signal
   reg            gmii_link_status;// indicates link status
   reg      [1:0] gmii_speed;      // Rgmii extracted speed signal

  `ifdef RGMII_2X_CLOCK // if double speed transmit clock is enabled

   reg      [3:0] rgmii_txd_int;   // signals used for registering tx-outputs
   reg            rgmii_tx_ctl_int;// signals used for registering tx-outputs

  `else                // if double speed transmit clock is disabled

   reg      [3:0] tx_data_neg_1b;  // early nibble received on neg edge
   reg            tx_ctrl_neg_1b;  // early ctrl bit received on neg edge
   reg      [3:0] tx_data_pos;     // nibble to be transmitted on pos edge
   reg            tx_ctrl_pos;     // ctrl bit to be transmitted on pos edge

  `endif               // end of `define statement

//==============================================================================
// registered output at  double speed clock (optional)
// Double speed clock is used to register the DDR rgmii tx signals
// this is optional feature and can be included through rgmii_defs.v file
//==============================================================================

 `ifdef RGMII_2X_CLOCK  // if double speed transmit clock is enabled

   assign rgmii_txd    = rgmii_txd_int;
   assign rgmii_tx_ctl = rgmii_tx_ctl_int;



//==============================================================================
// registered output at  double speed clock (optional)
// Double speed clock is used to register the DDR rgmii tx signals
// this is optional feature and can be included through rgmii_defs.v file
//==============================================================================
   always@(posedge rgmii_2x_tx_clk or negedge n_rgmii_2x_tx_reset)
     begin
        if (~n_rgmii_2x_tx_reset)
          begin
             rgmii_txd_int      <=  4'h0;
             rgmii_tx_ctl_int   <=  1'b0;
             tx_data_neg        <=  4'h0;
             tx_ctrl_neg        <=  1'b0;
          end
        else
          begin
             if (~rgmii_tx_clk_sig)
               begin
                  if (tbi)
                    begin
                       rgmii_txd_int      <=  tbi_tx_group[3:0];
                       rgmii_tx_ctl_int   <=  tbi_tx_group[4];
                       tx_data_neg        <=  tbi_tx_group[8:5];
                       tx_ctrl_neg        <=  tbi_tx_group[9];
                    end
                  else
                    begin
                       rgmii_txd_int      <=  gmii_txd[3:0];
                       rgmii_tx_ctl_int   <=  gmii_tx_en;
                       tx_data_neg        <=  gmii_txd[7:4];
                       tx_ctrl_neg        <=  gmii_tx_en ^ gmii_tx_er;
                    end
               end
             else
               begin
                  rgmii_txd_int           <= tx_data_neg;
                  rgmii_tx_ctl_int        <= tx_ctrl_neg;
                  tx_data_neg             <= tx_data_neg;
                  tx_ctrl_neg             <= tx_data_neg;
               end
          end
     end


  `else // If double speed transmit clock is disabled


// assign rgmii_txd    = rgmii_tx_clk_sig? tx_data_pos : tx_data_neg;
   assign rgmii_txd    = ~gmii_gigabit ? tx_data_pos : rgmii_tx_clk_sig ? tx_data_pos : tx_data_neg;
   assign rgmii_tx_ctl = rgmii_tx_clk_sig? tx_ctrl_pos : tx_ctrl_neg;


//==============================================================================
// transmit data on tx_pose  edge
// pos signals are the signals to be transmitted on the rising edge of the
// rgmii_tx_clk
// _neg_1b signals are to be sampled on the rising edge of rgmii_tx_n_clk
// and to be transmitted on the falling edge of rgmii_tx_clk.
//==============================================================================
   always@(posedge rgmii_tx_clk or negedge n_rgmii_txreset)
     begin
        if (~n_rgmii_txreset)
          begin
             tx_data_pos    <=  4'h0;
             tx_ctrl_pos    <=  1'b0;
             tx_data_neg_1b <=  4'h0;
             tx_ctrl_neg_1b <=  1'b0;
          end
        else
          begin
             if (tbi)
               begin
                  tx_data_pos    <=  tbi_tx_group[3:0];
                  tx_ctrl_pos    <=  tbi_tx_group[4];
                  tx_data_neg_1b <=  tbi_tx_group[8:5];
                  tx_ctrl_neg_1b <=  tbi_tx_group[9];
               end
             else
               begin
                  tx_data_pos    <=  gmii_txd[3:0];
                  tx_ctrl_pos    <=  gmii_tx_en;
                  tx_data_neg_1b <=  gmii_txd[7:4];
                  tx_ctrl_neg_1b <=  gmii_tx_en ^ gmii_tx_er;
               end
          end
     end


//==============================================================================
// negedge transmit data
// tx data and control signals that has to be transmitted on the rising
// edge of the rgmii_tx_clk
//==============================================================================
   always@(posedge rgmii_tx_n_clk or negedge n_rgmii_tx_n_reset )
     begin
        if (~n_rgmii_tx_n_reset)
          begin
             tx_data_neg <=  4'h0;
             tx_ctrl_neg <=  1'b0;
          end
        else
          begin
             tx_data_neg <=  tx_data_neg_1b;
             tx_ctrl_neg <=  tx_ctrl_neg_1b;
          end
     end

  `endif // end of optional `define double speed logic





//==============================================================================
// posedge receive data
// -lower nibble of gmii_rxd
// -gmii_rx_dv
// reset value is been set to 4 which resuts in the decode of
// speed,link_status and duplex_out signals to their default values
//==============================================================================
   always@(posedge rgmii_rx_clk or negedge n_rgmii_rxreset)
     begin
        if (~n_rgmii_rxreset)
          begin
             rx_data_pos <=  4'h4;
             rx_ctrl_pos <=  1'b0;
          end
        else
          begin
             rx_data_pos <=  rgmii_rxd;
             rx_ctrl_pos <=  rgmii_rx_ctl;
          end
     end


//==============================================================================
// negedge receive data
// -upper nibble of gmii_rxd
// -encoded gmii_rx_er signal
//==============================================================================
   always@(posedge rgmii_rx_n_clk or negedge n_rgmii_rx_n_reset)
     begin
        if (~n_rgmii_rx_n_reset)
          begin
             rx_data_neg <=  4'h0;
             rx_ctrl_neg <=  1'b0;
          end
        else
          begin
             rx_data_neg <=  rgmii_rxd;
             rx_ctrl_neg <=  rgmii_rx_ctl;
          end
     end



//==============================================================================
// received data and control (gmii) signals
// -gmii_rx_dv is received on the rising edge of the rgmii_rx_clk
// -gmii_rx_er is received on the falling edge of the rgmii_rx_clk
// -gmii_rxd is received on the both edges of the rgmii_rx_clk in the form of
//  nibbles
//==============================================================================
  always@(posedge rgmii_rx_clk or negedge n_rgmii_rxreset)
     begin
        if (~n_rgmii_rxreset)
          begin
             gmii_rxd      <=  8'h00;
             gmii_rx_er    <=  1'b0;
             gmii_rx_dv    <=  1'b0;
          end
        else
          begin
             if (tbi)
               begin
                  gmii_rxd      <=  8'h00;
                  gmii_rx_er    <=  1'b0;
                  gmii_rx_dv    <=  1'b0;
               end
             else
               begin
                  gmii_rx_dv    <=  rx_ctrl_pos;
                  gmii_rxd      <=  {rx_data_neg,rx_data_pos};
                  gmii_rx_er    <=  rx_ctrl_pos ^ rx_ctrl_neg;
               end
          end
     end

// synchronize gmii_gigabit
// Use verilog here instead of synchroniser to support gate level sims.
reg gmii_gigabit_meta;
reg gmii_gigabit_sync;
always@(posedge rgmii_rx_clk or negedge n_rgmii_rxreset)
begin
  if (~n_rgmii_rxreset)
  begin
    gmii_gigabit_meta <= 1'b0;
    gmii_gigabit_sync <= 1'b0;
  end
  else
  begin
    gmii_gigabit_meta <= gmii_gigabit;
    gmii_gigabit_sync <= gmii_gigabit_meta;
  end
end

//   cdnsdru_datasync_v1 i_cdnsdru_datasync_v1_gmii_gigabit (
//      .clk(rgmii_rx_clk),
//      .reset_n(n_rgmii_rxreset),
//      .din(gmii_gigabit),
//      .dout(gmii_gigabit_sync));

//==============================================================================
// carrier sense /data valid signal decoding
// - GMII_RX_DV true ie. rx_ctrl_pos
// - GMII_RX_DV is false and GMII_RX_ER is true (ie. rx_ctrl_neg) and
//    - GMII_RXD[7:0] contains ff (carrier sense)
//    - GMII_RXD[7:0] contains oe (false carrier indication)
//    - if gigabit mode and
//         - GMII_RXD[7:0] contains 1f (carrier extend error)
//         - GMII_RXD[7:0] contains 0f (carrier extend)
//==============================================================================
   always@(posedge rgmii_rx_clk or negedge n_rgmii_rxreset)
     begin
        if (~n_rgmii_rxreset)
          begin
             crs_dv   <=  1'b0;
          end
        else
          begin
             if (tbi)
               begin
                  crs_dv   <=  1'b0;
               end
             else
               begin
                  if (((rx_ctrl_neg & ~rx_ctrl_pos) &
                       (({rx_data_neg,rx_data_pos} == 8'hff) |
                        ({rx_data_neg,rx_data_pos} == 8'h0e) |
                        ((({rx_data_neg,rx_data_pos} == 8'h1f)  |
                          ({rx_data_neg,rx_data_pos} == 8'h0f)) &
                         gmii_gigabit_sync))) | rx_ctrl_pos)
                    begin
                       crs_dv   <=  1'b1;
                    end
                  else
                    begin
                       crs_dv   <=  1'b0;
                    end
               end
          end
     end


//==============================================================================
// extraction of GMII control signals
// -when there is no carrier sense and no receive error detected
//  gmii_rxd contains the control information:
//    gmii_link_status  gmii_rxd[0]
//    gmii_duplex_out   gmii_rxd[3]
//    gmii_speed        gmii_rxd[2:1]
//==============================================================================
   always@(posedge rgmii_rx_clk or negedge n_rgmii_rxreset)
     begin
        if (~n_rgmii_rxreset)
          begin
             gmii_link_status  <=  1'b0;
             gmii_duplex_out   <=  1'b0;
             gmii_speed        <=  2'b10;
          end
        else
          begin
             if (tbi)
               begin
                  gmii_link_status  <=  1'b0;
                  gmii_duplex_out   <=  1'b0;
                  gmii_speed        <=  2'b10;
               end
             else
               begin
                  if (~rx_ctrl_pos & ~rx_ctrl_neg)
                    begin
                       gmii_link_status  <= rx_data_pos[0];
                       gmii_speed        <= rx_data_pos[2:1];
                       gmii_duplex_out   <= rx_data_pos[3];
                    end
                  else
                    begin
                       gmii_link_status  <= gmii_link_status;
                       gmii_speed        <= gmii_speed;
                       gmii_duplex_out   <= gmii_duplex_out;
                    end
               end
          end
     end



//==============================================================================
// gmii_col indicates the collision detection in the half duplex mode
//==============================================================================

   assign gmii_col = crs_dv & gmii_tx_en & ~gmii_duplex_in;

//==============================================================================
// gmii_crs indicates carrier sense ie  valid data received
//
// Note the RGMII interface should assert CRS on TX_EN. When the RGMII spec says
// 'The PHY will not assert CRS as a result of TX_EN being true' it is referring
// to the PHY and not the RGMII interface.
//
//==============================================================================

   assign gmii_crs = crs_dv | gmii_tx_en;


//==============================================================================
//==============================================================================
//rtbi receive logic
//==============================================================================
//==============================================================================
// Receives data on the both edges of the clock  and convert it into 10bit
// code groups synchronised to +ve edge of rgmii_rx_clk clock. Code groups
// are searched for comma pattern to output the code groups alligned to the
// clocks rbc0 and rbc1, such that every comma should get sent with positive
// edge of rbc0.
//==============================================================================


   assign rx_code_group = {rx_ctrl_neg,rx_data_neg,
                         rx_ctrl_pos,rx_data_pos};


//==============================================================================
//comma sequence detection
// - code groups with patterns 1100000xxx and 0011111xxx are called comma
//   code groups
//==============================================================================
   always@(rx_code_group)
     begin
        if ((rx_code_group[6:0] == 7'b0000011) |
            (rx_code_group[6:0] == 7'b1111100) ) // bit reversed comma patterns
          begin
             comma_detect = 1'b1;
          end
        else
          begin
             comma_detect = 1'b0;
          end
     end


//==============================================================================
// 1 clock delay to rx_code_groups for 2nd stage of pipeline
//==============================================================================
   always@(posedge rgmii_rx_clk or negedge n_rgmii_rxreset)
     begin
        if (~n_rgmii_rxreset)
          begin
             comma_detect_1d  <=  1'b0;
             rx_code_group_1d <=  10'd0;
          end
        else
          begin
             comma_detect_1d  <=  comma_detect;
             rx_code_group_1d <=  rx_code_group;
          end
     end


//==============================================================================
// select signal that selects the code group from one of the two stages of
// pipeline in order to align codes groups to rbc0 and rbc1 (ie. code group
// with comma pattern should always get sent out on the +ve edge of rbc0.
//==============================================================================
   always@(posedge rgmii_rx_clk or negedge n_rgmii_rxreset)
     begin
        if (~n_rgmii_rxreset)
          begin
             mux_sel <= 1'b0;
          end
        else
          begin
             if (rbc1_sig)
               begin
                  if (comma_detect )
                    begin
                       mux_sel <= 1'b0;
                    end
                  else
                    begin
                       if (comma_detect_1d)
                         begin
                            mux_sel <= 1'b1;
                         end
                       else
                         begin
                            mux_sel <= mux_sel;
                         end
                    end
                end
              else
                begin
                   mux_sel <= mux_sel;
                end
          end
     end


//==============================================================================
// generation and alignment of tbi_rx_group
// whenever comma codegroup is deteted it realigns codegroups by selecting
// pipeline stages such that comma code groups is transmitted on the rising
// edge of rbc0
//==============================================================================
   always@(posedge rgmii_rx_clk or negedge n_rgmii_rxreset)
     begin
        if (~n_rgmii_rxreset)
          begin
             tbi_rx_group <= 10'd0;
          end
        else
          begin
             if (tbi)
               begin
                  if (rbc1_sig)
                    begin
                       if ((comma_detect_1d | mux_sel) & ~comma_detect )
                         begin
                            tbi_rx_group <= rx_code_group_1d;
                         end
                       else
                         begin
                            tbi_rx_group <= rx_code_group;
                         end
                    end // if (rbc1_sig)
                  else
                    begin
                       if (mux_sel)
                         begin
                            tbi_rx_group <= rx_code_group_1d;
                         end
                       else
                         begin
                            tbi_rx_group <= rx_code_group;
                         end
                    end
               end
             else
               begin
                  tbi_rx_group <= 10'd0;
               end
          end
     end


endmodule
