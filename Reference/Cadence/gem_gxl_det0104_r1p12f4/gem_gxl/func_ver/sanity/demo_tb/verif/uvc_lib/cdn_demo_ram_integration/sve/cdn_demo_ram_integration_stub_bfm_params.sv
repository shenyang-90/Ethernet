  // SRAM NAME (STRING)
  parameter string SRAM_NAME [0:31] = '{SRAM0_NAME,
                                        SRAM1_NAME,
                                        SRAM2_NAME,
                                        SRAM3_NAME,
                                        SRAM4_NAME,
                                        SRAM5_NAME,
                                        SRAM6_NAME,
                                        SRAM7_NAME,
                                        SRAM8_NAME,
                                        SRAM9_NAME,
                                        SRAM10_NAME,
                                        SRAM11_NAME,
                                        SRAM12_NAME,
                                        SRAM13_NAME,
                                        SRAM14_NAME,
                                        SRAM15_NAME,
                                        SRAM16_NAME,
                                        SRAM17_NAME,
                                        SRAM18_NAME,
                                        SRAM19_NAME,
                                        SRAM20_NAME,
                                        SRAM21_NAME,
                                        SRAM22_NAME,
                                        SRAM23_NAME,
                                        SRAM24_NAME,
                                        SRAM25_NAME,
                                        SRAM26_NAME,
                                        SRAM27_NAME,
                                        SRAM28_NAME,
                                        SRAM29_NAME,
                                        SRAM30_NAME,
                                        SRAM31_NAME};

  // SRAM ADDRESS WIDTH
  parameter SRAM_ADDR_WD = SRAM0_ADDR_WD  +
                           SRAM1_ADDR_WD  +
                           SRAM2_ADDR_WD  +
                           SRAM3_ADDR_WD  +
                           SRAM4_ADDR_WD  +
                           SRAM5_ADDR_WD  +
                           SRAM6_ADDR_WD  +
                           SRAM7_ADDR_WD  +
                           SRAM8_ADDR_WD  +
                           SRAM9_ADDR_WD  +
                           SRAM10_ADDR_WD +
                           SRAM11_ADDR_WD +
                           SRAM12_ADDR_WD +
                           SRAM13_ADDR_WD +
                           SRAM14_ADDR_WD +
                           SRAM15_ADDR_WD +
                           SRAM16_ADDR_WD +
                           SRAM17_ADDR_WD +
                           SRAM18_ADDR_WD +
                           SRAM19_ADDR_WD +
                           SRAM20_ADDR_WD +
                           SRAM21_ADDR_WD +
                           SRAM22_ADDR_WD +
                           SRAM23_ADDR_WD +
                           SRAM24_ADDR_WD +
                           SRAM25_ADDR_WD +
                           SRAM26_ADDR_WD +
                           SRAM27_ADDR_WD +
                           SRAM28_ADDR_WD +
                           SRAM29_ADDR_WD +
                           SRAM30_ADDR_WD +
                           SRAM31_ADDR_WD;

  parameter [10:0] SRAM_ADDR_WD_ARRAY [0:31] = '{SRAM0_ADDR_WD ,
                                                 SRAM1_ADDR_WD ,
                                                 SRAM2_ADDR_WD ,
                                                 SRAM3_ADDR_WD ,
                                                 SRAM4_ADDR_WD ,
                                                 SRAM5_ADDR_WD ,
                                                 SRAM6_ADDR_WD ,
                                                 SRAM7_ADDR_WD ,
                                                 SRAM8_ADDR_WD ,
                                                 SRAM9_ADDR_WD ,
                                                 SRAM10_ADDR_WD,
                                                 SRAM11_ADDR_WD,
                                                 SRAM12_ADDR_WD,
                                                 SRAM13_ADDR_WD,
                                                 SRAM14_ADDR_WD,
                                                 SRAM15_ADDR_WD,
                                                 SRAM16_ADDR_WD,
                                                 SRAM17_ADDR_WD,
                                                 SRAM18_ADDR_WD,
                                                 SRAM19_ADDR_WD,
                                                 SRAM20_ADDR_WD,
                                                 SRAM21_ADDR_WD,
                                                 SRAM22_ADDR_WD,
                                                 SRAM23_ADDR_WD,
                                                 SRAM24_ADDR_WD,
                                                 SRAM25_ADDR_WD,
                                                 SRAM26_ADDR_WD,
                                                 SRAM27_ADDR_WD,
                                                 SRAM28_ADDR_WD,
                                                 SRAM29_ADDR_WD,
                                                 SRAM30_ADDR_WD,
                                                 SRAM31_ADDR_WD};

  parameter SRAM0_ADDR_WD_START  = 0;
  parameter SRAM1_ADDR_WD_START  = SRAM0_ADDR_WD_START  + SRAM0_ADDR_WD ;
  parameter SRAM2_ADDR_WD_START  = SRAM1_ADDR_WD_START  + SRAM1_ADDR_WD ;
  parameter SRAM3_ADDR_WD_START  = SRAM2_ADDR_WD_START  + SRAM2_ADDR_WD ;
  parameter SRAM4_ADDR_WD_START  = SRAM3_ADDR_WD_START  + SRAM3_ADDR_WD ;
  parameter SRAM5_ADDR_WD_START  = SRAM4_ADDR_WD_START  + SRAM4_ADDR_WD ;
  parameter SRAM6_ADDR_WD_START  = SRAM5_ADDR_WD_START  + SRAM5_ADDR_WD ;
  parameter SRAM7_ADDR_WD_START  = SRAM6_ADDR_WD_START  + SRAM6_ADDR_WD ;
  parameter SRAM8_ADDR_WD_START  = SRAM7_ADDR_WD_START  + SRAM7_ADDR_WD ;
  parameter SRAM9_ADDR_WD_START  = SRAM8_ADDR_WD_START  + SRAM8_ADDR_WD ;
  parameter SRAM10_ADDR_WD_START = SRAM9_ADDR_WD_START  + SRAM9_ADDR_WD ;
  parameter SRAM11_ADDR_WD_START = SRAM10_ADDR_WD_START + SRAM10_ADDR_WD;
  parameter SRAM12_ADDR_WD_START = SRAM11_ADDR_WD_START + SRAM11_ADDR_WD;
  parameter SRAM13_ADDR_WD_START = SRAM12_ADDR_WD_START + SRAM12_ADDR_WD;
  parameter SRAM14_ADDR_WD_START = SRAM13_ADDR_WD_START + SRAM13_ADDR_WD;
  parameter SRAM15_ADDR_WD_START = SRAM14_ADDR_WD_START + SRAM14_ADDR_WD;
  parameter SRAM16_ADDR_WD_START = SRAM15_ADDR_WD_START + SRAM15_ADDR_WD;
  parameter SRAM17_ADDR_WD_START = SRAM16_ADDR_WD_START + SRAM16_ADDR_WD;
  parameter SRAM18_ADDR_WD_START = SRAM17_ADDR_WD_START + SRAM17_ADDR_WD;
  parameter SRAM19_ADDR_WD_START = SRAM18_ADDR_WD_START + SRAM18_ADDR_WD;
  parameter SRAM20_ADDR_WD_START = SRAM19_ADDR_WD_START + SRAM19_ADDR_WD;
  parameter SRAM21_ADDR_WD_START = SRAM20_ADDR_WD_START + SRAM20_ADDR_WD;
  parameter SRAM22_ADDR_WD_START = SRAM21_ADDR_WD_START + SRAM21_ADDR_WD;
  parameter SRAM23_ADDR_WD_START = SRAM22_ADDR_WD_START + SRAM22_ADDR_WD;
  parameter SRAM24_ADDR_WD_START = SRAM23_ADDR_WD_START + SRAM23_ADDR_WD;
  parameter SRAM25_ADDR_WD_START = SRAM24_ADDR_WD_START + SRAM24_ADDR_WD;
  parameter SRAM26_ADDR_WD_START = SRAM25_ADDR_WD_START + SRAM25_ADDR_WD;
  parameter SRAM27_ADDR_WD_START = SRAM26_ADDR_WD_START + SRAM26_ADDR_WD;
  parameter SRAM28_ADDR_WD_START = SRAM27_ADDR_WD_START + SRAM27_ADDR_WD;
  parameter SRAM29_ADDR_WD_START = SRAM28_ADDR_WD_START + SRAM28_ADDR_WD;
  parameter SRAM30_ADDR_WD_START = SRAM29_ADDR_WD_START + SRAM29_ADDR_WD;
  parameter SRAM31_ADDR_WD_START = SRAM30_ADDR_WD_START + SRAM30_ADDR_WD;

  parameter [10:0] SRAM_ADDR_WD_START_ARRAY [0:31] = '{SRAM0_ADDR_WD_START ,
                                                       SRAM1_ADDR_WD_START ,
                                                       SRAM2_ADDR_WD_START ,
                                                       SRAM3_ADDR_WD_START ,
                                                       SRAM4_ADDR_WD_START ,
                                                       SRAM5_ADDR_WD_START ,
                                                       SRAM6_ADDR_WD_START ,
                                                       SRAM7_ADDR_WD_START ,
                                                       SRAM8_ADDR_WD_START ,
                                                       SRAM9_ADDR_WD_START ,
                                                       SRAM10_ADDR_WD_START,
                                                       SRAM11_ADDR_WD_START,
                                                       SRAM12_ADDR_WD_START,
                                                       SRAM13_ADDR_WD_START,
                                                       SRAM14_ADDR_WD_START,
                                                       SRAM15_ADDR_WD_START,
                                                       SRAM16_ADDR_WD_START,
                                                       SRAM17_ADDR_WD_START,
                                                       SRAM18_ADDR_WD_START,
                                                       SRAM19_ADDR_WD_START,
                                                       SRAM20_ADDR_WD_START,
                                                       SRAM21_ADDR_WD_START,
                                                       SRAM22_ADDR_WD_START,
                                                       SRAM23_ADDR_WD_START,
                                                       SRAM24_ADDR_WD_START,
                                                       SRAM25_ADDR_WD_START,
                                                       SRAM26_ADDR_WD_START,
                                                       SRAM27_ADDR_WD_START,
                                                       SRAM28_ADDR_WD_START,
                                                       SRAM29_ADDR_WD_START,
                                                       SRAM30_ADDR_WD_START,
                                                       SRAM31_ADDR_WD_START};

  // SRAM DATA WIDTH
  parameter SRAM_DATA_WD = SRAM0_DATA_WD  +
                           SRAM1_DATA_WD  +
                           SRAM2_DATA_WD  +
                           SRAM3_DATA_WD  +
                           SRAM4_DATA_WD  +
                           SRAM5_DATA_WD  +
                           SRAM6_DATA_WD  +
                           SRAM7_DATA_WD  +
                           SRAM8_DATA_WD  +
                           SRAM9_DATA_WD  +
                           SRAM10_DATA_WD +
                           SRAM11_DATA_WD +
                           SRAM12_DATA_WD +
                           SRAM13_DATA_WD +
                           SRAM14_DATA_WD +
                           SRAM15_DATA_WD +
                           SRAM16_DATA_WD +
                           SRAM17_DATA_WD +
                           SRAM18_DATA_WD +
                           SRAM19_DATA_WD +
                           SRAM20_DATA_WD +
                           SRAM21_DATA_WD +
                           SRAM22_DATA_WD +
                           SRAM23_DATA_WD +
                           SRAM24_DATA_WD +
                           SRAM25_DATA_WD +
                           SRAM26_DATA_WD +
                           SRAM27_DATA_WD +
                           SRAM28_DATA_WD +
                           SRAM29_DATA_WD +
                           SRAM30_DATA_WD +
                           SRAM31_DATA_WD;

  parameter [15:0] SRAM_DATA_WD_ARRAY [0:31] = '{SRAM0_DATA_WD ,
                                                 SRAM1_DATA_WD ,
                                                 SRAM2_DATA_WD ,
                                                 SRAM3_DATA_WD ,
                                                 SRAM4_DATA_WD ,
                                                 SRAM5_DATA_WD ,
                                                 SRAM6_DATA_WD ,
                                                 SRAM7_DATA_WD ,
                                                 SRAM8_DATA_WD ,
                                                 SRAM9_DATA_WD ,
                                                 SRAM10_DATA_WD,
                                                 SRAM11_DATA_WD,
                                                 SRAM12_DATA_WD,
                                                 SRAM13_DATA_WD,
                                                 SRAM14_DATA_WD,
                                                 SRAM15_DATA_WD,
                                                 SRAM16_DATA_WD,
                                                 SRAM17_DATA_WD,
                                                 SRAM18_DATA_WD,
                                                 SRAM19_DATA_WD,
                                                 SRAM20_DATA_WD,
                                                 SRAM21_DATA_WD,
                                                 SRAM22_DATA_WD,
                                                 SRAM23_DATA_WD,
                                                 SRAM24_DATA_WD,
                                                 SRAM25_DATA_WD,
                                                 SRAM26_DATA_WD,
                                                 SRAM27_DATA_WD,
                                                 SRAM28_DATA_WD,
                                                 SRAM29_DATA_WD,
                                                 SRAM30_DATA_WD,
                                                 SRAM31_DATA_WD};

  parameter SRAM0_DATA_WD_START  = 0;
  parameter SRAM1_DATA_WD_START  = SRAM0_DATA_WD_START  + SRAM0_DATA_WD ;
  parameter SRAM2_DATA_WD_START  = SRAM1_DATA_WD_START  + SRAM1_DATA_WD ;
  parameter SRAM3_DATA_WD_START  = SRAM2_DATA_WD_START  + SRAM2_DATA_WD ;
  parameter SRAM4_DATA_WD_START  = SRAM3_DATA_WD_START  + SRAM3_DATA_WD ;
  parameter SRAM5_DATA_WD_START  = SRAM4_DATA_WD_START  + SRAM4_DATA_WD ;
  parameter SRAM6_DATA_WD_START  = SRAM5_DATA_WD_START  + SRAM5_DATA_WD ;
  parameter SRAM7_DATA_WD_START  = SRAM6_DATA_WD_START  + SRAM6_DATA_WD ;
  parameter SRAM8_DATA_WD_START  = SRAM7_DATA_WD_START  + SRAM7_DATA_WD ;
  parameter SRAM9_DATA_WD_START  = SRAM8_DATA_WD_START  + SRAM8_DATA_WD ;
  parameter SRAM10_DATA_WD_START = SRAM9_DATA_WD_START  + SRAM9_DATA_WD ;
  parameter SRAM11_DATA_WD_START = SRAM10_DATA_WD_START + SRAM10_DATA_WD;
  parameter SRAM12_DATA_WD_START = SRAM11_DATA_WD_START + SRAM11_DATA_WD;
  parameter SRAM13_DATA_WD_START = SRAM12_DATA_WD_START + SRAM12_DATA_WD;
  parameter SRAM14_DATA_WD_START = SRAM13_DATA_WD_START + SRAM13_DATA_WD;
  parameter SRAM15_DATA_WD_START = SRAM14_DATA_WD_START + SRAM14_DATA_WD;
  parameter SRAM16_DATA_WD_START = SRAM15_DATA_WD_START + SRAM15_DATA_WD;
  parameter SRAM17_DATA_WD_START = SRAM16_DATA_WD_START + SRAM16_DATA_WD;
  parameter SRAM18_DATA_WD_START = SRAM17_DATA_WD_START + SRAM17_DATA_WD;
  parameter SRAM19_DATA_WD_START = SRAM18_DATA_WD_START + SRAM18_DATA_WD;
  parameter SRAM20_DATA_WD_START = SRAM19_DATA_WD_START + SRAM19_DATA_WD;
  parameter SRAM21_DATA_WD_START = SRAM20_DATA_WD_START + SRAM20_DATA_WD;
  parameter SRAM22_DATA_WD_START = SRAM21_DATA_WD_START + SRAM21_DATA_WD;
  parameter SRAM23_DATA_WD_START = SRAM22_DATA_WD_START + SRAM22_DATA_WD;
  parameter SRAM24_DATA_WD_START = SRAM23_DATA_WD_START + SRAM23_DATA_WD;
  parameter SRAM25_DATA_WD_START = SRAM24_DATA_WD_START + SRAM24_DATA_WD;
  parameter SRAM26_DATA_WD_START = SRAM25_DATA_WD_START + SRAM25_DATA_WD;
  parameter SRAM27_DATA_WD_START = SRAM26_DATA_WD_START + SRAM26_DATA_WD;
  parameter SRAM28_DATA_WD_START = SRAM27_DATA_WD_START + SRAM27_DATA_WD;
  parameter SRAM29_DATA_WD_START = SRAM28_DATA_WD_START + SRAM28_DATA_WD;
  parameter SRAM30_DATA_WD_START = SRAM29_DATA_WD_START + SRAM29_DATA_WD;
  parameter SRAM31_DATA_WD_START = SRAM30_DATA_WD_START + SRAM30_DATA_WD;

  parameter [15:0] SRAM_DATA_WD_START_ARRAY [0:31] = '{SRAM0_DATA_WD_START ,
                                                       SRAM1_DATA_WD_START ,
                                                       SRAM2_DATA_WD_START ,
                                                       SRAM3_DATA_WD_START ,
                                                       SRAM4_DATA_WD_START ,
                                                       SRAM5_DATA_WD_START ,
                                                       SRAM6_DATA_WD_START ,
                                                       SRAM7_DATA_WD_START ,
                                                       SRAM8_DATA_WD_START ,
                                                       SRAM9_DATA_WD_START ,
                                                       SRAM10_DATA_WD_START,
                                                       SRAM11_DATA_WD_START,
                                                       SRAM12_DATA_WD_START,
                                                       SRAM13_DATA_WD_START,
                                                       SRAM14_DATA_WD_START,
                                                       SRAM15_DATA_WD_START,
                                                       SRAM16_DATA_WD_START,
                                                       SRAM17_DATA_WD_START,
                                                       SRAM18_DATA_WD_START,
                                                       SRAM19_DATA_WD_START,
                                                       SRAM20_DATA_WD_START,
                                                       SRAM21_DATA_WD_START,
                                                       SRAM22_DATA_WD_START,
                                                       SRAM23_DATA_WD_START,
                                                       SRAM24_DATA_WD_START,
                                                       SRAM25_DATA_WD_START,
                                                       SRAM26_DATA_WD_START,
                                                       SRAM27_DATA_WD_START,
                                                       SRAM28_DATA_WD_START,
                                                       SRAM29_DATA_WD_START,
                                                       SRAM30_DATA_WD_START,
                                                       SRAM31_DATA_WD_START};

  // SRAM DEPTH of RAM
  parameter SRAM_DEPTH = SRAM0_DEPTH  +
                         SRAM1_DEPTH  +
                         SRAM2_DEPTH  +
                         SRAM3_DEPTH  +
                         SRAM4_DEPTH  +
                         SRAM5_DEPTH  +
                         SRAM6_DEPTH  +
                         SRAM7_DEPTH  +
                         SRAM8_DEPTH  +
                         SRAM9_DEPTH  +
                         SRAM10_DEPTH +
                         SRAM11_DEPTH +
                         SRAM12_DEPTH +
                         SRAM13_DEPTH +
                         SRAM14_DEPTH +
                         SRAM15_DEPTH +
                         SRAM16_DEPTH +
                         SRAM17_DEPTH +
                         SRAM18_DEPTH +
                         SRAM19_DEPTH +
                         SRAM20_DEPTH +
                         SRAM21_DEPTH +
                         SRAM22_DEPTH +
                         SRAM23_DEPTH +
                         SRAM24_DEPTH +
                         SRAM25_DEPTH +
                         SRAM26_DEPTH +
                         SRAM27_DEPTH +
                         SRAM28_DEPTH +
                         SRAM29_DEPTH +
                         SRAM30_DEPTH +
                         SRAM31_DEPTH;

  // DP1R1W NAME (STRING)
  parameter string DP1R1W_NAME [0:31] = '{DP1R1W0_NAME,
                                          DP1R1W1_NAME,
                                          DP1R1W2_NAME,
                                          DP1R1W3_NAME,
                                          DP1R1W4_NAME,
                                          DP1R1W5_NAME,
                                          DP1R1W6_NAME,
                                          DP1R1W7_NAME,
                                          DP1R1W8_NAME,
                                          DP1R1W9_NAME,
                                          DP1R1W10_NAME,
                                          DP1R1W11_NAME,
                                          DP1R1W12_NAME,
                                          DP1R1W13_NAME,
                                          DP1R1W14_NAME,
                                          DP1R1W15_NAME,
                                          DP1R1W16_NAME,
                                          DP1R1W17_NAME,
                                          DP1R1W18_NAME,
                                          DP1R1W19_NAME,
                                          DP1R1W20_NAME,
                                          DP1R1W21_NAME,
                                          DP1R1W22_NAME,
                                          DP1R1W23_NAME,
                                          DP1R1W24_NAME,
                                          DP1R1W25_NAME,
                                          DP1R1W26_NAME,
                                          DP1R1W27_NAME,
                                          DP1R1W28_NAME,
                                          DP1R1W29_NAME,
                                          DP1R1W30_NAME,
                                          DP1R1W31_NAME};
   

  // DP1R1W ADDRESS WIDTH
  parameter DP1R1W_ADDR_WD = DP1R1W0_ADDR_WD  +
                             DP1R1W1_ADDR_WD  +
                             DP1R1W2_ADDR_WD  +
                             DP1R1W3_ADDR_WD  +
                             DP1R1W4_ADDR_WD  +
                             DP1R1W5_ADDR_WD  +
                             DP1R1W6_ADDR_WD  +
                             DP1R1W7_ADDR_WD  +
                             DP1R1W8_ADDR_WD  +
                             DP1R1W9_ADDR_WD  +
                             DP1R1W10_ADDR_WD +
                             DP1R1W11_ADDR_WD +
                             DP1R1W12_ADDR_WD +
                             DP1R1W13_ADDR_WD +
                             DP1R1W14_ADDR_WD +
                             DP1R1W15_ADDR_WD +
                             DP1R1W16_ADDR_WD +
                             DP1R1W17_ADDR_WD +
                             DP1R1W18_ADDR_WD +
                             DP1R1W19_ADDR_WD +
                             DP1R1W20_ADDR_WD +
                             DP1R1W21_ADDR_WD +
                             DP1R1W22_ADDR_WD +
                             DP1R1W23_ADDR_WD +
                             DP1R1W24_ADDR_WD +
                             DP1R1W25_ADDR_WD +
                             DP1R1W26_ADDR_WD +
                             DP1R1W27_ADDR_WD +
                             DP1R1W28_ADDR_WD +
                             DP1R1W29_ADDR_WD +
                             DP1R1W30_ADDR_WD +
                             DP1R1W31_ADDR_WD;

  parameter [10:0] DP1R1W_ADDR_WD_ARRAY [0:31] = '{DP1R1W0_ADDR_WD ,
                                                   DP1R1W1_ADDR_WD ,
                                                   DP1R1W2_ADDR_WD ,
                                                   DP1R1W3_ADDR_WD ,
                                                   DP1R1W4_ADDR_WD ,
                                                   DP1R1W5_ADDR_WD ,
                                                   DP1R1W6_ADDR_WD ,
                                                   DP1R1W7_ADDR_WD ,
                                                   DP1R1W8_ADDR_WD ,
                                                   DP1R1W9_ADDR_WD ,
                                                   DP1R1W10_ADDR_WD,
                                                   DP1R1W11_ADDR_WD,
                                                   DP1R1W12_ADDR_WD,
                                                   DP1R1W13_ADDR_WD,
                                                   DP1R1W14_ADDR_WD,
                                                   DP1R1W15_ADDR_WD,
                                                   DP1R1W16_ADDR_WD,
                                                   DP1R1W17_ADDR_WD,
                                                   DP1R1W18_ADDR_WD,
                                                   DP1R1W19_ADDR_WD,
                                                   DP1R1W20_ADDR_WD,
                                                   DP1R1W21_ADDR_WD,
                                                   DP1R1W22_ADDR_WD,
                                                   DP1R1W23_ADDR_WD,
                                                   DP1R1W24_ADDR_WD,
                                                   DP1R1W25_ADDR_WD,
                                                   DP1R1W26_ADDR_WD,
                                                   DP1R1W27_ADDR_WD,
                                                   DP1R1W28_ADDR_WD,
                                                   DP1R1W29_ADDR_WD,
                                                   DP1R1W30_ADDR_WD,
                                                   DP1R1W31_ADDR_WD};

  parameter DP1R1W0_ADDR_WD_START  = 0;
  parameter DP1R1W1_ADDR_WD_START  = DP1R1W0_ADDR_WD_START  + DP1R1W0_ADDR_WD ;
  parameter DP1R1W2_ADDR_WD_START  = DP1R1W1_ADDR_WD_START  + DP1R1W1_ADDR_WD ;
  parameter DP1R1W3_ADDR_WD_START  = DP1R1W2_ADDR_WD_START  + DP1R1W2_ADDR_WD ;
  parameter DP1R1W4_ADDR_WD_START  = DP1R1W3_ADDR_WD_START  + DP1R1W3_ADDR_WD ;
  parameter DP1R1W5_ADDR_WD_START  = DP1R1W4_ADDR_WD_START  + DP1R1W4_ADDR_WD ;
  parameter DP1R1W6_ADDR_WD_START  = DP1R1W5_ADDR_WD_START  + DP1R1W5_ADDR_WD ;
  parameter DP1R1W7_ADDR_WD_START  = DP1R1W6_ADDR_WD_START  + DP1R1W6_ADDR_WD ;
  parameter DP1R1W8_ADDR_WD_START  = DP1R1W7_ADDR_WD_START  + DP1R1W7_ADDR_WD ;
  parameter DP1R1W9_ADDR_WD_START  = DP1R1W8_ADDR_WD_START  + DP1R1W8_ADDR_WD ;
  parameter DP1R1W10_ADDR_WD_START = DP1R1W9_ADDR_WD_START  + DP1R1W9_ADDR_WD ;
  parameter DP1R1W11_ADDR_WD_START = DP1R1W10_ADDR_WD_START + DP1R1W10_ADDR_WD;
  parameter DP1R1W12_ADDR_WD_START = DP1R1W11_ADDR_WD_START + DP1R1W11_ADDR_WD;
  parameter DP1R1W13_ADDR_WD_START = DP1R1W12_ADDR_WD_START + DP1R1W12_ADDR_WD;
  parameter DP1R1W14_ADDR_WD_START = DP1R1W13_ADDR_WD_START + DP1R1W13_ADDR_WD;
  parameter DP1R1W15_ADDR_WD_START = DP1R1W14_ADDR_WD_START + DP1R1W14_ADDR_WD;
  parameter DP1R1W16_ADDR_WD_START = DP1R1W15_ADDR_WD_START + DP1R1W15_ADDR_WD;
  parameter DP1R1W17_ADDR_WD_START = DP1R1W16_ADDR_WD_START + DP1R1W16_ADDR_WD;
  parameter DP1R1W18_ADDR_WD_START = DP1R1W17_ADDR_WD_START + DP1R1W17_ADDR_WD;
  parameter DP1R1W19_ADDR_WD_START = DP1R1W18_ADDR_WD_START + DP1R1W18_ADDR_WD;
  parameter DP1R1W20_ADDR_WD_START = DP1R1W19_ADDR_WD_START + DP1R1W19_ADDR_WD;
  parameter DP1R1W21_ADDR_WD_START = DP1R1W20_ADDR_WD_START + DP1R1W20_ADDR_WD;
  parameter DP1R1W22_ADDR_WD_START = DP1R1W21_ADDR_WD_START + DP1R1W21_ADDR_WD;
  parameter DP1R1W23_ADDR_WD_START = DP1R1W22_ADDR_WD_START + DP1R1W22_ADDR_WD;
  parameter DP1R1W24_ADDR_WD_START = DP1R1W23_ADDR_WD_START + DP1R1W23_ADDR_WD;
  parameter DP1R1W25_ADDR_WD_START = DP1R1W24_ADDR_WD_START + DP1R1W24_ADDR_WD;
  parameter DP1R1W26_ADDR_WD_START = DP1R1W25_ADDR_WD_START + DP1R1W25_ADDR_WD;
  parameter DP1R1W27_ADDR_WD_START = DP1R1W26_ADDR_WD_START + DP1R1W26_ADDR_WD;
  parameter DP1R1W28_ADDR_WD_START = DP1R1W27_ADDR_WD_START + DP1R1W27_ADDR_WD;
  parameter DP1R1W29_ADDR_WD_START = DP1R1W28_ADDR_WD_START + DP1R1W28_ADDR_WD;
  parameter DP1R1W30_ADDR_WD_START = DP1R1W29_ADDR_WD_START + DP1R1W29_ADDR_WD;
  parameter DP1R1W31_ADDR_WD_START = DP1R1W30_ADDR_WD_START + DP1R1W30_ADDR_WD;

  parameter [10:0] DP1R1W_ADDR_WD_START_ARRAY [0:31] = '{DP1R1W0_ADDR_WD_START ,
                                                         DP1R1W1_ADDR_WD_START ,
                                                         DP1R1W2_ADDR_WD_START ,
                                                         DP1R1W3_ADDR_WD_START ,
                                                         DP1R1W4_ADDR_WD_START ,
                                                         DP1R1W5_ADDR_WD_START ,
                                                         DP1R1W6_ADDR_WD_START ,
                                                         DP1R1W7_ADDR_WD_START ,
                                                         DP1R1W8_ADDR_WD_START ,
                                                         DP1R1W9_ADDR_WD_START ,
                                                         DP1R1W10_ADDR_WD_START,
                                                         DP1R1W11_ADDR_WD_START,
                                                         DP1R1W12_ADDR_WD_START,
                                                         DP1R1W13_ADDR_WD_START,
                                                         DP1R1W14_ADDR_WD_START,
                                                         DP1R1W15_ADDR_WD_START,
                                                         DP1R1W16_ADDR_WD_START,
                                                         DP1R1W17_ADDR_WD_START,
                                                         DP1R1W18_ADDR_WD_START,
                                                         DP1R1W19_ADDR_WD_START,
                                                         DP1R1W20_ADDR_WD_START,
                                                         DP1R1W21_ADDR_WD_START,
                                                         DP1R1W22_ADDR_WD_START,
                                                         DP1R1W23_ADDR_WD_START,
                                                         DP1R1W24_ADDR_WD_START,
                                                         DP1R1W25_ADDR_WD_START,
                                                         DP1R1W26_ADDR_WD_START,
                                                         DP1R1W27_ADDR_WD_START,
                                                         DP1R1W28_ADDR_WD_START,
                                                         DP1R1W29_ADDR_WD_START,
                                                         DP1R1W30_ADDR_WD_START,
                                                         DP1R1W31_ADDR_WD_START};

  // DP1R1W DATA WIDTH
  parameter DP1R1W_DATA_WD = DP1R1W0_DATA_WD  +
                             DP1R1W1_DATA_WD  +
                             DP1R1W2_DATA_WD  +
                             DP1R1W3_DATA_WD  +
                             DP1R1W4_DATA_WD  +
                             DP1R1W5_DATA_WD  +
                             DP1R1W6_DATA_WD  +
                             DP1R1W7_DATA_WD  +
                             DP1R1W8_DATA_WD  +
                             DP1R1W9_DATA_WD  +
                             DP1R1W10_DATA_WD +
                             DP1R1W11_DATA_WD +
                             DP1R1W12_DATA_WD +
                             DP1R1W13_DATA_WD +
                             DP1R1W14_DATA_WD +
                             DP1R1W15_DATA_WD +
                             DP1R1W16_DATA_WD +
                             DP1R1W17_DATA_WD +
                             DP1R1W18_DATA_WD +
                             DP1R1W19_DATA_WD +
                             DP1R1W20_DATA_WD +
                             DP1R1W21_DATA_WD +
                             DP1R1W22_DATA_WD +
                             DP1R1W23_DATA_WD +
                             DP1R1W24_DATA_WD +
                             DP1R1W25_DATA_WD +
                             DP1R1W26_DATA_WD +
                             DP1R1W27_DATA_WD +
                             DP1R1W28_DATA_WD +
                             DP1R1W29_DATA_WD +
                             DP1R1W30_DATA_WD +
                             DP1R1W31_DATA_WD;

  parameter [15:0] DP1R1W_DATA_WD_ARRAY [0:31] = '{DP1R1W0_DATA_WD ,
                                                   DP1R1W1_DATA_WD ,
                                                   DP1R1W2_DATA_WD ,
                                                   DP1R1W3_DATA_WD ,
                                                   DP1R1W4_DATA_WD ,
                                                   DP1R1W5_DATA_WD ,
                                                   DP1R1W6_DATA_WD ,
                                                   DP1R1W7_DATA_WD ,
                                                   DP1R1W8_DATA_WD ,
                                                   DP1R1W9_DATA_WD ,
                                                   DP1R1W10_DATA_WD,
                                                   DP1R1W11_DATA_WD,
                                                   DP1R1W12_DATA_WD,
                                                   DP1R1W13_DATA_WD,
                                                   DP1R1W14_DATA_WD,
                                                   DP1R1W15_DATA_WD,
                                                   DP1R1W16_DATA_WD,
                                                   DP1R1W17_DATA_WD,
                                                   DP1R1W18_DATA_WD,
                                                   DP1R1W19_DATA_WD,
                                                   DP1R1W20_DATA_WD,
                                                   DP1R1W21_DATA_WD,
                                                   DP1R1W22_DATA_WD,
                                                   DP1R1W23_DATA_WD,
                                                   DP1R1W24_DATA_WD,
                                                   DP1R1W25_DATA_WD,
                                                   DP1R1W26_DATA_WD,
                                                   DP1R1W27_DATA_WD,
                                                   DP1R1W28_DATA_WD,
                                                   DP1R1W29_DATA_WD,
                                                   DP1R1W30_DATA_WD,
                                                   DP1R1W31_DATA_WD};

  parameter DP1R1W0_DATA_WD_START  = 0;
  parameter DP1R1W1_DATA_WD_START  = DP1R1W0_DATA_WD_START  + DP1R1W0_DATA_WD ;
  parameter DP1R1W2_DATA_WD_START  = DP1R1W1_DATA_WD_START  + DP1R1W1_DATA_WD ;
  parameter DP1R1W3_DATA_WD_START  = DP1R1W2_DATA_WD_START  + DP1R1W2_DATA_WD ;
  parameter DP1R1W4_DATA_WD_START  = DP1R1W3_DATA_WD_START  + DP1R1W3_DATA_WD ;
  parameter DP1R1W5_DATA_WD_START  = DP1R1W4_DATA_WD_START  + DP1R1W4_DATA_WD ;
  parameter DP1R1W6_DATA_WD_START  = DP1R1W5_DATA_WD_START  + DP1R1W5_DATA_WD ;
  parameter DP1R1W7_DATA_WD_START  = DP1R1W6_DATA_WD_START  + DP1R1W6_DATA_WD ;
  parameter DP1R1W8_DATA_WD_START  = DP1R1W7_DATA_WD_START  + DP1R1W7_DATA_WD ;
  parameter DP1R1W9_DATA_WD_START  = DP1R1W8_DATA_WD_START  + DP1R1W8_DATA_WD ;
  parameter DP1R1W10_DATA_WD_START = DP1R1W9_DATA_WD_START  + DP1R1W9_DATA_WD ;
  parameter DP1R1W11_DATA_WD_START = DP1R1W10_DATA_WD_START + DP1R1W10_DATA_WD;
  parameter DP1R1W12_DATA_WD_START = DP1R1W11_DATA_WD_START + DP1R1W11_DATA_WD;
  parameter DP1R1W13_DATA_WD_START = DP1R1W12_DATA_WD_START + DP1R1W12_DATA_WD;
  parameter DP1R1W14_DATA_WD_START = DP1R1W13_DATA_WD_START + DP1R1W13_DATA_WD;
  parameter DP1R1W15_DATA_WD_START = DP1R1W14_DATA_WD_START + DP1R1W14_DATA_WD;
  parameter DP1R1W16_DATA_WD_START = DP1R1W15_DATA_WD_START + DP1R1W15_DATA_WD;
  parameter DP1R1W17_DATA_WD_START = DP1R1W16_DATA_WD_START + DP1R1W16_DATA_WD;
  parameter DP1R1W18_DATA_WD_START = DP1R1W17_DATA_WD_START + DP1R1W17_DATA_WD;
  parameter DP1R1W19_DATA_WD_START = DP1R1W18_DATA_WD_START + DP1R1W18_DATA_WD;
  parameter DP1R1W20_DATA_WD_START = DP1R1W19_DATA_WD_START + DP1R1W19_DATA_WD;
  parameter DP1R1W21_DATA_WD_START = DP1R1W20_DATA_WD_START + DP1R1W20_DATA_WD;
  parameter DP1R1W22_DATA_WD_START = DP1R1W21_DATA_WD_START + DP1R1W21_DATA_WD;
  parameter DP1R1W23_DATA_WD_START = DP1R1W22_DATA_WD_START + DP1R1W22_DATA_WD;
  parameter DP1R1W24_DATA_WD_START = DP1R1W23_DATA_WD_START + DP1R1W23_DATA_WD;
  parameter DP1R1W25_DATA_WD_START = DP1R1W24_DATA_WD_START + DP1R1W24_DATA_WD;
  parameter DP1R1W26_DATA_WD_START = DP1R1W25_DATA_WD_START + DP1R1W25_DATA_WD;
  parameter DP1R1W27_DATA_WD_START = DP1R1W26_DATA_WD_START + DP1R1W26_DATA_WD;
  parameter DP1R1W28_DATA_WD_START = DP1R1W27_DATA_WD_START + DP1R1W27_DATA_WD;
  parameter DP1R1W29_DATA_WD_START = DP1R1W28_DATA_WD_START + DP1R1W28_DATA_WD;
  parameter DP1R1W30_DATA_WD_START = DP1R1W29_DATA_WD_START + DP1R1W29_DATA_WD;
  parameter DP1R1W31_DATA_WD_START = DP1R1W30_DATA_WD_START + DP1R1W30_DATA_WD;

  parameter [15:0] DP1R1W_DATA_WD_START_ARRAY [0:31] = '{DP1R1W0_DATA_WD_START ,
                                                         DP1R1W1_DATA_WD_START ,
                                                         DP1R1W2_DATA_WD_START ,
                                                         DP1R1W3_DATA_WD_START ,
                                                         DP1R1W4_DATA_WD_START ,
                                                         DP1R1W5_DATA_WD_START ,
                                                         DP1R1W6_DATA_WD_START ,
                                                         DP1R1W7_DATA_WD_START ,
                                                         DP1R1W8_DATA_WD_START ,
                                                         DP1R1W9_DATA_WD_START ,
                                                         DP1R1W10_DATA_WD_START,
                                                         DP1R1W11_DATA_WD_START,
                                                         DP1R1W12_DATA_WD_START,
                                                         DP1R1W13_DATA_WD_START,
                                                         DP1R1W14_DATA_WD_START,
                                                         DP1R1W15_DATA_WD_START,
                                                         DP1R1W16_DATA_WD_START,
                                                         DP1R1W17_DATA_WD_START,
                                                         DP1R1W18_DATA_WD_START,
                                                         DP1R1W19_DATA_WD_START,
                                                         DP1R1W20_DATA_WD_START,
                                                         DP1R1W21_DATA_WD_START,
                                                         DP1R1W22_DATA_WD_START,
                                                         DP1R1W23_DATA_WD_START,
                                                         DP1R1W24_DATA_WD_START,
                                                         DP1R1W25_DATA_WD_START,
                                                         DP1R1W26_DATA_WD_START,
                                                         DP1R1W27_DATA_WD_START,
                                                         DP1R1W28_DATA_WD_START,
                                                         DP1R1W29_DATA_WD_START,
                                                         DP1R1W30_DATA_WD_START,
                                                         DP1R1W31_DATA_WD_START};

  // DP1R1W DEPTH of RAM
  parameter DP1R1W_DEPTH = DP1R1W0_DEPTH  +
                           DP1R1W1_DEPTH  +
                           DP1R1W2_DEPTH  +
                           DP1R1W3_DEPTH  +
                           DP1R1W4_DEPTH  +
                           DP1R1W5_DEPTH  +
                           DP1R1W6_DEPTH  +
                           DP1R1W7_DEPTH  +
                           DP1R1W8_DEPTH  +
                           DP1R1W9_DEPTH  +
                           DP1R1W10_DEPTH +
                           DP1R1W11_DEPTH +
                           DP1R1W12_DEPTH +
                           DP1R1W13_DEPTH +
                           DP1R1W14_DEPTH +
                           DP1R1W15_DEPTH +
                           DP1R1W16_DEPTH +
                           DP1R1W17_DEPTH +
                           DP1R1W18_DEPTH +
                           DP1R1W19_DEPTH +
                           DP1R1W20_DEPTH +
                           DP1R1W21_DEPTH +
                           DP1R1W22_DEPTH +
                           DP1R1W23_DEPTH +
                           DP1R1W24_DEPTH +
                           DP1R1W25_DEPTH +
                           DP1R1W26_DEPTH +
                           DP1R1W27_DEPTH +
                           DP1R1W28_DEPTH +
                           DP1R1W29_DEPTH +
                           DP1R1W30_DEPTH +
                           DP1R1W31_DEPTH;

  // DP2R2W NAME (STRING)
  parameter string DP2R2W_NAME [0:31] = '{DP2R2W0_NAME,
                                          DP2R2W1_NAME,
                                          DP2R2W2_NAME,
                                          DP2R2W3_NAME,
                                          DP2R2W4_NAME,
                                          DP2R2W5_NAME,
                                          DP2R2W6_NAME,
                                          DP2R2W7_NAME,
                                          DP2R2W8_NAME,
                                          DP2R2W9_NAME,
                                          DP2R2W10_NAME,
                                          DP2R2W11_NAME,
                                          DP2R2W12_NAME,
                                          DP2R2W13_NAME,
                                          DP2R2W14_NAME,
                                          DP2R2W15_NAME,
                                          DP2R2W16_NAME,
                                          DP2R2W17_NAME,
                                          DP2R2W18_NAME,
                                          DP2R2W19_NAME,
                                          DP2R2W20_NAME,
                                          DP2R2W21_NAME,
                                          DP2R2W22_NAME,
                                          DP2R2W23_NAME,
                                          DP2R2W24_NAME,
                                          DP2R2W25_NAME,
                                          DP2R2W26_NAME,
                                          DP2R2W27_NAME,
                                          DP2R2W28_NAME,
                                          DP2R2W29_NAME,
                                          DP2R2W30_NAME,
                                          DP2R2W31_NAME};

  // DP2R2W ADDRESS WIDTH
  parameter DP2R2W_ADDR_WD = DP2R2W0_ADDR_WD  +
                             DP2R2W1_ADDR_WD  +
                             DP2R2W2_ADDR_WD  +
                             DP2R2W3_ADDR_WD  +
                             DP2R2W4_ADDR_WD  +
                             DP2R2W5_ADDR_WD  +
                             DP2R2W6_ADDR_WD  +
                             DP2R2W7_ADDR_WD  +
                             DP2R2W8_ADDR_WD  +
                             DP2R2W9_ADDR_WD  +
                             DP2R2W10_ADDR_WD +
                             DP2R2W11_ADDR_WD +
                             DP2R2W12_ADDR_WD +
                             DP2R2W13_ADDR_WD +
                             DP2R2W14_ADDR_WD +
                             DP2R2W15_ADDR_WD +
                             DP2R2W16_ADDR_WD +
                             DP2R2W17_ADDR_WD +
                             DP2R2W18_ADDR_WD +
                             DP2R2W19_ADDR_WD +
                             DP2R2W20_ADDR_WD +
                             DP2R2W21_ADDR_WD +
                             DP2R2W22_ADDR_WD +
                             DP2R2W23_ADDR_WD +
                             DP2R2W24_ADDR_WD +
                             DP2R2W25_ADDR_WD +
                             DP2R2W26_ADDR_WD +
                             DP2R2W27_ADDR_WD +
                             DP2R2W28_ADDR_WD +
                             DP2R2W29_ADDR_WD +
                             DP2R2W30_ADDR_WD +
                             DP2R2W31_ADDR_WD;

  parameter [10:0] DP2R2W_ADDR_WD_ARRAY [0:31] = '{DP2R2W0_ADDR_WD ,
                                                   DP2R2W1_ADDR_WD ,
                                                   DP2R2W2_ADDR_WD ,
                                                   DP2R2W3_ADDR_WD ,
                                                   DP2R2W4_ADDR_WD ,
                                                   DP2R2W5_ADDR_WD ,
                                                   DP2R2W6_ADDR_WD ,
                                                   DP2R2W7_ADDR_WD ,
                                                   DP2R2W8_ADDR_WD ,
                                                   DP2R2W9_ADDR_WD ,
                                                   DP2R2W10_ADDR_WD,
                                                   DP2R2W11_ADDR_WD,
                                                   DP2R2W12_ADDR_WD,
                                                   DP2R2W13_ADDR_WD,
                                                   DP2R2W14_ADDR_WD,
                                                   DP2R2W15_ADDR_WD,
                                                   DP2R2W16_ADDR_WD,
                                                   DP2R2W17_ADDR_WD,
                                                   DP2R2W18_ADDR_WD,
                                                   DP2R2W19_ADDR_WD,
                                                   DP2R2W20_ADDR_WD,
                                                   DP2R2W21_ADDR_WD,
                                                   DP2R2W22_ADDR_WD,
                                                   DP2R2W23_ADDR_WD,
                                                   DP2R2W24_ADDR_WD,
                                                   DP2R2W25_ADDR_WD,
                                                   DP2R2W26_ADDR_WD,
                                                   DP2R2W27_ADDR_WD,
                                                   DP2R2W28_ADDR_WD,
                                                   DP2R2W29_ADDR_WD,
                                                   DP2R2W30_ADDR_WD,
                                                   DP2R2W31_ADDR_WD};

  parameter DP2R2W0_ADDR_WD_START  = 0;
  parameter DP2R2W1_ADDR_WD_START  = DP2R2W0_ADDR_WD_START  + DP2R2W0_ADDR_WD ;
  parameter DP2R2W2_ADDR_WD_START  = DP2R2W1_ADDR_WD_START  + DP2R2W1_ADDR_WD ;
  parameter DP2R2W3_ADDR_WD_START  = DP2R2W2_ADDR_WD_START  + DP2R2W2_ADDR_WD ;
  parameter DP2R2W4_ADDR_WD_START  = DP2R2W3_ADDR_WD_START  + DP2R2W3_ADDR_WD ;
  parameter DP2R2W5_ADDR_WD_START  = DP2R2W4_ADDR_WD_START  + DP2R2W4_ADDR_WD ;
  parameter DP2R2W6_ADDR_WD_START  = DP2R2W5_ADDR_WD_START  + DP2R2W5_ADDR_WD ;
  parameter DP2R2W7_ADDR_WD_START  = DP2R2W6_ADDR_WD_START  + DP2R2W6_ADDR_WD ;
  parameter DP2R2W8_ADDR_WD_START  = DP2R2W7_ADDR_WD_START  + DP2R2W7_ADDR_WD ;
  parameter DP2R2W9_ADDR_WD_START  = DP2R2W8_ADDR_WD_START  + DP2R2W8_ADDR_WD ;
  parameter DP2R2W10_ADDR_WD_START = DP2R2W9_ADDR_WD_START  + DP2R2W9_ADDR_WD ;
  parameter DP2R2W11_ADDR_WD_START = DP2R2W10_ADDR_WD_START + DP2R2W10_ADDR_WD;
  parameter DP2R2W12_ADDR_WD_START = DP2R2W11_ADDR_WD_START + DP2R2W11_ADDR_WD;
  parameter DP2R2W13_ADDR_WD_START = DP2R2W12_ADDR_WD_START + DP2R2W12_ADDR_WD;
  parameter DP2R2W14_ADDR_WD_START = DP2R2W13_ADDR_WD_START + DP2R2W13_ADDR_WD;
  parameter DP2R2W15_ADDR_WD_START = DP2R2W14_ADDR_WD_START + DP2R2W14_ADDR_WD;
  parameter DP2R2W16_ADDR_WD_START = DP2R2W15_ADDR_WD_START + DP2R2W15_ADDR_WD;
  parameter DP2R2W17_ADDR_WD_START = DP2R2W16_ADDR_WD_START + DP2R2W16_ADDR_WD;
  parameter DP2R2W18_ADDR_WD_START = DP2R2W17_ADDR_WD_START + DP2R2W17_ADDR_WD;
  parameter DP2R2W19_ADDR_WD_START = DP2R2W18_ADDR_WD_START + DP2R2W18_ADDR_WD;
  parameter DP2R2W20_ADDR_WD_START = DP2R2W19_ADDR_WD_START + DP2R2W19_ADDR_WD;
  parameter DP2R2W21_ADDR_WD_START = DP2R2W20_ADDR_WD_START + DP2R2W20_ADDR_WD;
  parameter DP2R2W22_ADDR_WD_START = DP2R2W21_ADDR_WD_START + DP2R2W21_ADDR_WD;
  parameter DP2R2W23_ADDR_WD_START = DP2R2W22_ADDR_WD_START + DP2R2W22_ADDR_WD;
  parameter DP2R2W24_ADDR_WD_START = DP2R2W23_ADDR_WD_START + DP2R2W23_ADDR_WD;
  parameter DP2R2W25_ADDR_WD_START = DP2R2W24_ADDR_WD_START + DP2R2W24_ADDR_WD;
  parameter DP2R2W26_ADDR_WD_START = DP2R2W25_ADDR_WD_START + DP2R2W25_ADDR_WD;
  parameter DP2R2W27_ADDR_WD_START = DP2R2W26_ADDR_WD_START + DP2R2W26_ADDR_WD;
  parameter DP2R2W28_ADDR_WD_START = DP2R2W27_ADDR_WD_START + DP2R2W27_ADDR_WD;
  parameter DP2R2W29_ADDR_WD_START = DP2R2W28_ADDR_WD_START + DP2R2W28_ADDR_WD;
  parameter DP2R2W30_ADDR_WD_START = DP2R2W29_ADDR_WD_START + DP2R2W29_ADDR_WD;
  parameter DP2R2W31_ADDR_WD_START = DP2R2W30_ADDR_WD_START + DP2R2W30_ADDR_WD;

  parameter [10:0] DP2R2W_ADDR_WD_START_ARRAY [0:31] = '{DP2R2W0_ADDR_WD_START ,
                                                         DP2R2W1_ADDR_WD_START ,
                                                         DP2R2W2_ADDR_WD_START ,
                                                         DP2R2W3_ADDR_WD_START ,
                                                         DP2R2W4_ADDR_WD_START ,
                                                         DP2R2W5_ADDR_WD_START ,
                                                         DP2R2W6_ADDR_WD_START ,
                                                         DP2R2W7_ADDR_WD_START ,
                                                         DP2R2W8_ADDR_WD_START ,
                                                         DP2R2W9_ADDR_WD_START ,
                                                         DP2R2W10_ADDR_WD_START,
                                                         DP2R2W11_ADDR_WD_START,
                                                         DP2R2W12_ADDR_WD_START,
                                                         DP2R2W13_ADDR_WD_START,
                                                         DP2R2W14_ADDR_WD_START,
                                                         DP2R2W15_ADDR_WD_START,
                                                         DP2R2W16_ADDR_WD_START,
                                                         DP2R2W17_ADDR_WD_START,
                                                         DP2R2W18_ADDR_WD_START,
                                                         DP2R2W19_ADDR_WD_START,
                                                         DP2R2W20_ADDR_WD_START,
                                                         DP2R2W21_ADDR_WD_START,
                                                         DP2R2W22_ADDR_WD_START,
                                                         DP2R2W23_ADDR_WD_START,
                                                         DP2R2W24_ADDR_WD_START,
                                                         DP2R2W25_ADDR_WD_START,
                                                         DP2R2W26_ADDR_WD_START,
                                                         DP2R2W27_ADDR_WD_START,
                                                         DP2R2W28_ADDR_WD_START,
                                                         DP2R2W29_ADDR_WD_START,
                                                         DP2R2W30_ADDR_WD_START,
                                                         DP2R2W31_ADDR_WD_START};

  // DP2R2W DATA WIDTH
  parameter DP2R2W_DATA_WD = DP2R2W0_DATA_WD  +
                             DP2R2W1_DATA_WD  +
                             DP2R2W2_DATA_WD  +
                             DP2R2W3_DATA_WD  +
                             DP2R2W4_DATA_WD  +
                             DP2R2W5_DATA_WD  +
                             DP2R2W6_DATA_WD  +
                             DP2R2W7_DATA_WD  +
                             DP2R2W8_DATA_WD  +
                             DP2R2W9_DATA_WD  +
                             DP2R2W10_DATA_WD +
                             DP2R2W11_DATA_WD +
                             DP2R2W12_DATA_WD +
                             DP2R2W13_DATA_WD +
                             DP2R2W14_DATA_WD +
                             DP2R2W15_DATA_WD +
                             DP2R2W16_DATA_WD +
                             DP2R2W17_DATA_WD +
                             DP2R2W18_DATA_WD +
                             DP2R2W19_DATA_WD +
                             DP2R2W20_DATA_WD +
                             DP2R2W21_DATA_WD +
                             DP2R2W22_DATA_WD +
                             DP2R2W23_DATA_WD +
                             DP2R2W24_DATA_WD +
                             DP2R2W25_DATA_WD +
                             DP2R2W26_DATA_WD +
                             DP2R2W27_DATA_WD +
                             DP2R2W28_DATA_WD +
                             DP2R2W29_DATA_WD +
                             DP2R2W30_DATA_WD +
                             DP2R2W31_DATA_WD;

  parameter [15:0] DP2R2W_DATA_WD_ARRAY [0:31] = '{DP2R2W0_DATA_WD ,
                                                   DP2R2W1_DATA_WD ,
                                                   DP2R2W2_DATA_WD ,
                                                   DP2R2W3_DATA_WD ,
                                                   DP2R2W4_DATA_WD ,
                                                   DP2R2W5_DATA_WD ,
                                                   DP2R2W6_DATA_WD ,
                                                   DP2R2W7_DATA_WD ,
                                                   DP2R2W8_DATA_WD ,
                                                   DP2R2W9_DATA_WD ,
                                                   DP2R2W10_DATA_WD,
                                                   DP2R2W11_DATA_WD,
                                                   DP2R2W12_DATA_WD,
                                                   DP2R2W13_DATA_WD,
                                                   DP2R2W14_DATA_WD,
                                                   DP2R2W15_DATA_WD,
                                                   DP2R2W16_DATA_WD,
                                                   DP2R2W17_DATA_WD,
                                                   DP2R2W18_DATA_WD,
                                                   DP2R2W19_DATA_WD,
                                                   DP2R2W20_DATA_WD,
                                                   DP2R2W21_DATA_WD,
                                                   DP2R2W22_DATA_WD,
                                                   DP2R2W23_DATA_WD,
                                                   DP2R2W24_DATA_WD,
                                                   DP2R2W25_DATA_WD,
                                                   DP2R2W26_DATA_WD,
                                                   DP2R2W27_DATA_WD,
                                                   DP2R2W28_DATA_WD,
                                                   DP2R2W29_DATA_WD,
                                                   DP2R2W30_DATA_WD,
                                                   DP2R2W31_DATA_WD};

  parameter DP2R2W0_DATA_WD_START  = 0;
  parameter DP2R2W1_DATA_WD_START  = DP2R2W0_DATA_WD_START  + DP2R2W0_DATA_WD ;
  parameter DP2R2W2_DATA_WD_START  = DP2R2W1_DATA_WD_START  + DP2R2W1_DATA_WD ;
  parameter DP2R2W3_DATA_WD_START  = DP2R2W2_DATA_WD_START  + DP2R2W2_DATA_WD ;
  parameter DP2R2W4_DATA_WD_START  = DP2R2W3_DATA_WD_START  + DP2R2W3_DATA_WD ;
  parameter DP2R2W5_DATA_WD_START  = DP2R2W4_DATA_WD_START  + DP2R2W4_DATA_WD ;
  parameter DP2R2W6_DATA_WD_START  = DP2R2W5_DATA_WD_START  + DP2R2W5_DATA_WD ;
  parameter DP2R2W7_DATA_WD_START  = DP2R2W6_DATA_WD_START  + DP2R2W6_DATA_WD ;
  parameter DP2R2W8_DATA_WD_START  = DP2R2W7_DATA_WD_START  + DP2R2W7_DATA_WD ;
  parameter DP2R2W9_DATA_WD_START  = DP2R2W8_DATA_WD_START  + DP2R2W8_DATA_WD ;
  parameter DP2R2W10_DATA_WD_START = DP2R2W9_DATA_WD_START  + DP2R2W9_DATA_WD ;
  parameter DP2R2W11_DATA_WD_START = DP2R2W10_DATA_WD_START + DP2R2W10_DATA_WD;
  parameter DP2R2W12_DATA_WD_START = DP2R2W11_DATA_WD_START + DP2R2W11_DATA_WD;
  parameter DP2R2W13_DATA_WD_START = DP2R2W12_DATA_WD_START + DP2R2W12_DATA_WD;
  parameter DP2R2W14_DATA_WD_START = DP2R2W13_DATA_WD_START + DP2R2W13_DATA_WD;
  parameter DP2R2W15_DATA_WD_START = DP2R2W14_DATA_WD_START + DP2R2W14_DATA_WD;
  parameter DP2R2W16_DATA_WD_START = DP2R2W15_DATA_WD_START + DP2R2W15_DATA_WD;
  parameter DP2R2W17_DATA_WD_START = DP2R2W16_DATA_WD_START + DP2R2W16_DATA_WD;
  parameter DP2R2W18_DATA_WD_START = DP2R2W17_DATA_WD_START + DP2R2W17_DATA_WD;
  parameter DP2R2W19_DATA_WD_START = DP2R2W18_DATA_WD_START + DP2R2W18_DATA_WD;
  parameter DP2R2W20_DATA_WD_START = DP2R2W19_DATA_WD_START + DP2R2W19_DATA_WD;
  parameter DP2R2W21_DATA_WD_START = DP2R2W20_DATA_WD_START + DP2R2W20_DATA_WD;
  parameter DP2R2W22_DATA_WD_START = DP2R2W21_DATA_WD_START + DP2R2W21_DATA_WD;
  parameter DP2R2W23_DATA_WD_START = DP2R2W22_DATA_WD_START + DP2R2W22_DATA_WD;
  parameter DP2R2W24_DATA_WD_START = DP2R2W23_DATA_WD_START + DP2R2W23_DATA_WD;
  parameter DP2R2W25_DATA_WD_START = DP2R2W24_DATA_WD_START + DP2R2W24_DATA_WD;
  parameter DP2R2W26_DATA_WD_START = DP2R2W25_DATA_WD_START + DP2R2W25_DATA_WD;
  parameter DP2R2W27_DATA_WD_START = DP2R2W26_DATA_WD_START + DP2R2W26_DATA_WD;
  parameter DP2R2W28_DATA_WD_START = DP2R2W27_DATA_WD_START + DP2R2W27_DATA_WD;
  parameter DP2R2W29_DATA_WD_START = DP2R2W28_DATA_WD_START + DP2R2W28_DATA_WD;
  parameter DP2R2W30_DATA_WD_START = DP2R2W29_DATA_WD_START + DP2R2W29_DATA_WD;
  parameter DP2R2W31_DATA_WD_START = DP2R2W30_DATA_WD_START + DP2R2W30_DATA_WD;

  parameter [15:0] DP2R2W_DATA_WD_START_ARRAY [0:31] = '{DP2R2W0_DATA_WD_START ,
                                                         DP2R2W1_DATA_WD_START ,
                                                         DP2R2W2_DATA_WD_START ,
                                                         DP2R2W3_DATA_WD_START ,
                                                         DP2R2W4_DATA_WD_START ,
                                                         DP2R2W5_DATA_WD_START ,
                                                         DP2R2W6_DATA_WD_START ,
                                                         DP2R2W7_DATA_WD_START ,
                                                         DP2R2W8_DATA_WD_START ,
                                                         DP2R2W9_DATA_WD_START ,
                                                         DP2R2W10_DATA_WD_START,
                                                         DP2R2W11_DATA_WD_START,
                                                         DP2R2W12_DATA_WD_START,
                                                         DP2R2W13_DATA_WD_START,
                                                         DP2R2W14_DATA_WD_START,
                                                         DP2R2W15_DATA_WD_START,
                                                         DP2R2W16_DATA_WD_START,
                                                         DP2R2W17_DATA_WD_START,
                                                         DP2R2W18_DATA_WD_START,
                                                         DP2R2W19_DATA_WD_START,
                                                         DP2R2W20_DATA_WD_START,
                                                         DP2R2W21_DATA_WD_START,
                                                         DP2R2W22_DATA_WD_START,
                                                         DP2R2W23_DATA_WD_START,
                                                         DP2R2W24_DATA_WD_START,
                                                         DP2R2W25_DATA_WD_START,
                                                         DP2R2W26_DATA_WD_START,
                                                         DP2R2W27_DATA_WD_START,
                                                         DP2R2W28_DATA_WD_START,
                                                         DP2R2W29_DATA_WD_START,
                                                         DP2R2W30_DATA_WD_START,
                                                         DP2R2W31_DATA_WD_START};

  // DP2R2W DEPTH of RAM
  parameter DP2R2W_DEPTH = DP2R2W0_DEPTH  +
                           DP2R2W1_DEPTH  +
                           DP2R2W2_DEPTH  +
                           DP2R2W3_DEPTH  +
                           DP2R2W4_DEPTH  +
                           DP2R2W5_DEPTH  +
                           DP2R2W6_DEPTH  +
                           DP2R2W7_DEPTH  +
                           DP2R2W8_DEPTH  +
                           DP2R2W9_DEPTH  +
                           DP2R2W10_DEPTH +
                           DP2R2W11_DEPTH +
                           DP2R2W12_DEPTH +
                           DP2R2W13_DEPTH +
                           DP2R2W14_DEPTH +
                           DP2R2W15_DEPTH +
                           DP2R2W16_DEPTH +
                           DP2R2W17_DEPTH +
                           DP2R2W18_DEPTH +
                           DP2R2W19_DEPTH +
                           DP2R2W20_DEPTH +
                           DP2R2W21_DEPTH +
                           DP2R2W22_DEPTH +
                           DP2R2W23_DEPTH +
                           DP2R2W24_DEPTH +
                           DP2R2W25_DEPTH +
                           DP2R2W26_DEPTH +
                           DP2R2W27_DEPTH +
                           DP2R2W28_DEPTH +
                           DP2R2W29_DEPTH +
                           DP2R2W30_DEPTH +
                           DP2R2W31_DEPTH;

  // RF NAME (STRING)
  parameter string RF_NAME [0:31] = '{RF0_NAME,
                                      RF1_NAME,
                                      RF2_NAME,
                                      RF3_NAME,
                                      RF4_NAME,
                                      RF5_NAME,
                                      RF6_NAME,
                                      RF7_NAME,
                                      RF8_NAME,
                                      RF9_NAME,
                                      RF10_NAME,
                                      RF11_NAME,
                                      RF12_NAME,
                                      RF13_NAME,
                                      RF14_NAME,
                                      RF15_NAME,
                                      RF16_NAME,
                                      RF17_NAME,
                                      RF18_NAME,
                                      RF19_NAME,
                                      RF20_NAME,
                                      RF21_NAME,
                                      RF22_NAME,
                                      RF23_NAME,
                                      RF24_NAME,
                                      RF25_NAME,
                                      RF26_NAME,
                                      RF27_NAME,
                                      RF28_NAME,
                                      RF29_NAME,
                                      RF30_NAME,
                                      RF31_NAME};

  // RF ADDRESS WIDTH
  parameter RF_ADDR_WD = RF0_ADDR_WD  +
                         RF1_ADDR_WD  +
                         RF2_ADDR_WD  +
                         RF3_ADDR_WD  +
                         RF4_ADDR_WD  +
                         RF5_ADDR_WD  +
                         RF6_ADDR_WD  +
                         RF7_ADDR_WD  +
                         RF8_ADDR_WD  +
                         RF9_ADDR_WD  +
                         RF10_ADDR_WD +
                         RF11_ADDR_WD +
                         RF12_ADDR_WD +
                         RF13_ADDR_WD +
                         RF14_ADDR_WD +
                         RF15_ADDR_WD +
                         RF16_ADDR_WD +
                         RF17_ADDR_WD +
                         RF18_ADDR_WD +
                         RF19_ADDR_WD +
                         RF20_ADDR_WD +
                         RF21_ADDR_WD +
                         RF22_ADDR_WD +
                         RF23_ADDR_WD +
                         RF24_ADDR_WD +
                         RF25_ADDR_WD +
                         RF26_ADDR_WD +
                         RF27_ADDR_WD +
                         RF28_ADDR_WD +
                         RF29_ADDR_WD +
                         RF30_ADDR_WD +
                         RF31_ADDR_WD;

  parameter [10:0] RF_ADDR_WD_ARRAY [0:31] = '{RF0_ADDR_WD ,
                                               RF1_ADDR_WD ,
                                               RF2_ADDR_WD ,
                                               RF3_ADDR_WD ,
                                               RF4_ADDR_WD ,
                                               RF5_ADDR_WD ,
                                               RF6_ADDR_WD ,
                                               RF7_ADDR_WD ,
                                               RF8_ADDR_WD ,
                                               RF9_ADDR_WD ,
                                               RF10_ADDR_WD,
                                               RF11_ADDR_WD,
                                               RF12_ADDR_WD,
                                               RF13_ADDR_WD,
                                               RF14_ADDR_WD,
                                               RF15_ADDR_WD,
                                               RF16_ADDR_WD,
                                               RF17_ADDR_WD,
                                               RF18_ADDR_WD,
                                               RF19_ADDR_WD,
                                               RF20_ADDR_WD,
                                               RF21_ADDR_WD,
                                               RF22_ADDR_WD,
                                               RF23_ADDR_WD,
                                               RF24_ADDR_WD,
                                               RF25_ADDR_WD,
                                               RF26_ADDR_WD,
                                               RF27_ADDR_WD,
                                               RF28_ADDR_WD,
                                               RF29_ADDR_WD,
                                               RF30_ADDR_WD,
                                               RF31_ADDR_WD};

  parameter RF0_ADDR_WD_START  = 0;
  parameter RF1_ADDR_WD_START  = RF0_ADDR_WD_START  + RF0_ADDR_WD ;
  parameter RF2_ADDR_WD_START  = RF1_ADDR_WD_START  + RF1_ADDR_WD ;
  parameter RF3_ADDR_WD_START  = RF2_ADDR_WD_START  + RF2_ADDR_WD ;
  parameter RF4_ADDR_WD_START  = RF3_ADDR_WD_START  + RF3_ADDR_WD ;
  parameter RF5_ADDR_WD_START  = RF4_ADDR_WD_START  + RF4_ADDR_WD ;
  parameter RF6_ADDR_WD_START  = RF5_ADDR_WD_START  + RF5_ADDR_WD ;
  parameter RF7_ADDR_WD_START  = RF6_ADDR_WD_START  + RF6_ADDR_WD ;
  parameter RF8_ADDR_WD_START  = RF7_ADDR_WD_START  + RF7_ADDR_WD ;
  parameter RF9_ADDR_WD_START  = RF8_ADDR_WD_START  + RF8_ADDR_WD ;
  parameter RF10_ADDR_WD_START = RF9_ADDR_WD_START  + RF9_ADDR_WD ;
  parameter RF11_ADDR_WD_START = RF10_ADDR_WD_START + RF10_ADDR_WD;
  parameter RF12_ADDR_WD_START = RF11_ADDR_WD_START + RF11_ADDR_WD;
  parameter RF13_ADDR_WD_START = RF12_ADDR_WD_START + RF12_ADDR_WD;
  parameter RF14_ADDR_WD_START = RF13_ADDR_WD_START + RF13_ADDR_WD;
  parameter RF15_ADDR_WD_START = RF14_ADDR_WD_START + RF14_ADDR_WD;
  parameter RF16_ADDR_WD_START = RF15_ADDR_WD_START + RF15_ADDR_WD;
  parameter RF17_ADDR_WD_START = RF16_ADDR_WD_START + RF16_ADDR_WD;
  parameter RF18_ADDR_WD_START = RF17_ADDR_WD_START + RF17_ADDR_WD;
  parameter RF19_ADDR_WD_START = RF18_ADDR_WD_START + RF18_ADDR_WD;
  parameter RF20_ADDR_WD_START = RF19_ADDR_WD_START + RF19_ADDR_WD;
  parameter RF21_ADDR_WD_START = RF20_ADDR_WD_START + RF20_ADDR_WD;
  parameter RF22_ADDR_WD_START = RF21_ADDR_WD_START + RF21_ADDR_WD;
  parameter RF23_ADDR_WD_START = RF22_ADDR_WD_START + RF22_ADDR_WD;
  parameter RF24_ADDR_WD_START = RF23_ADDR_WD_START + RF23_ADDR_WD;
  parameter RF25_ADDR_WD_START = RF24_ADDR_WD_START + RF24_ADDR_WD;
  parameter RF26_ADDR_WD_START = RF25_ADDR_WD_START + RF25_ADDR_WD;
  parameter RF27_ADDR_WD_START = RF26_ADDR_WD_START + RF26_ADDR_WD;
  parameter RF28_ADDR_WD_START = RF27_ADDR_WD_START + RF27_ADDR_WD;
  parameter RF29_ADDR_WD_START = RF28_ADDR_WD_START + RF28_ADDR_WD;
  parameter RF30_ADDR_WD_START = RF29_ADDR_WD_START + RF29_ADDR_WD;
  parameter RF31_ADDR_WD_START = RF30_ADDR_WD_START + RF30_ADDR_WD;

  parameter [10:0] RF_ADDR_WD_START_ARRAY [0:31] = '{RF0_ADDR_WD_START ,
                                                     RF1_ADDR_WD_START ,
                                                     RF2_ADDR_WD_START ,
                                                     RF3_ADDR_WD_START ,
                                                     RF4_ADDR_WD_START ,
                                                     RF5_ADDR_WD_START ,
                                                     RF6_ADDR_WD_START ,
                                                     RF7_ADDR_WD_START ,
                                                     RF8_ADDR_WD_START ,
                                                     RF9_ADDR_WD_START ,
                                                     RF10_ADDR_WD_START,
                                                     RF11_ADDR_WD_START,
                                                     RF12_ADDR_WD_START,
                                                     RF13_ADDR_WD_START,
                                                     RF14_ADDR_WD_START,
                                                     RF15_ADDR_WD_START,
                                                     RF16_ADDR_WD_START,
                                                     RF17_ADDR_WD_START,
                                                     RF18_ADDR_WD_START,
                                                     RF19_ADDR_WD_START,
                                                     RF20_ADDR_WD_START,
                                                     RF21_ADDR_WD_START,
                                                     RF22_ADDR_WD_START,
                                                     RF23_ADDR_WD_START,
                                                     RF24_ADDR_WD_START,
                                                     RF25_ADDR_WD_START,
                                                     RF26_ADDR_WD_START,
                                                     RF27_ADDR_WD_START,
                                                     RF28_ADDR_WD_START,
                                                     RF29_ADDR_WD_START,
                                                     RF30_ADDR_WD_START,
                                                     RF31_ADDR_WD_START};

  // RF DATA WIDTH
  parameter RF_DATA_WD = RF0_DATA_WD  +
                         RF1_DATA_WD  +
                         RF2_DATA_WD  +
                         RF3_DATA_WD  +
                         RF4_DATA_WD  +
                         RF5_DATA_WD  +
                         RF6_DATA_WD  +
                         RF7_DATA_WD  +
                         RF8_DATA_WD  +
                         RF9_DATA_WD  +
                         RF10_DATA_WD +
                         RF11_DATA_WD +
                         RF12_DATA_WD +
                         RF13_DATA_WD +
                         RF14_DATA_WD +
                         RF15_DATA_WD +
                         RF16_DATA_WD +
                         RF17_DATA_WD +
                         RF18_DATA_WD +
                         RF19_DATA_WD +
                         RF20_DATA_WD +
                         RF21_DATA_WD +
                         RF22_DATA_WD +
                         RF23_DATA_WD +
                         RF24_DATA_WD +
                         RF25_DATA_WD +
                         RF26_DATA_WD +
                         RF27_DATA_WD +
                         RF28_DATA_WD +
                         RF29_DATA_WD +
                         RF30_DATA_WD +
                         RF31_DATA_WD;

  parameter [15:0] RF_DATA_WD_ARRAY [0:31] = '{RF0_DATA_WD ,
                                               RF1_DATA_WD ,
                                               RF2_DATA_WD ,
                                               RF3_DATA_WD ,
                                               RF4_DATA_WD ,
                                               RF5_DATA_WD ,
                                               RF6_DATA_WD ,
                                               RF7_DATA_WD ,
                                               RF8_DATA_WD ,
                                               RF9_DATA_WD ,
                                               RF10_DATA_WD,
                                               RF11_DATA_WD,
                                               RF12_DATA_WD,
                                               RF13_DATA_WD,
                                               RF14_DATA_WD,
                                               RF15_DATA_WD,
                                               RF16_DATA_WD,
                                               RF17_DATA_WD,
                                               RF18_DATA_WD,
                                               RF19_DATA_WD,
                                               RF20_DATA_WD,
                                               RF21_DATA_WD,
                                               RF22_DATA_WD,
                                               RF23_DATA_WD,
                                               RF24_DATA_WD,
                                               RF25_DATA_WD,
                                               RF26_DATA_WD,
                                               RF27_DATA_WD,
                                               RF28_DATA_WD,
                                               RF29_DATA_WD,
                                               RF30_DATA_WD,
                                               RF31_DATA_WD};

  parameter RF0_DATA_WD_START  = 0;
  parameter RF1_DATA_WD_START  = RF0_DATA_WD_START  + RF0_DATA_WD ;
  parameter RF2_DATA_WD_START  = RF1_DATA_WD_START  + RF1_DATA_WD ;
  parameter RF3_DATA_WD_START  = RF2_DATA_WD_START  + RF2_DATA_WD ;
  parameter RF4_DATA_WD_START  = RF3_DATA_WD_START  + RF3_DATA_WD ;
  parameter RF5_DATA_WD_START  = RF4_DATA_WD_START  + RF4_DATA_WD ;
  parameter RF6_DATA_WD_START  = RF5_DATA_WD_START  + RF5_DATA_WD ;
  parameter RF7_DATA_WD_START  = RF6_DATA_WD_START  + RF6_DATA_WD ;
  parameter RF8_DATA_WD_START  = RF7_DATA_WD_START  + RF7_DATA_WD ;
  parameter RF9_DATA_WD_START  = RF8_DATA_WD_START  + RF8_DATA_WD ;
  parameter RF10_DATA_WD_START = RF9_DATA_WD_START  + RF9_DATA_WD ;
  parameter RF11_DATA_WD_START = RF10_DATA_WD_START + RF10_DATA_WD;
  parameter RF12_DATA_WD_START = RF11_DATA_WD_START + RF11_DATA_WD;
  parameter RF13_DATA_WD_START = RF12_DATA_WD_START + RF12_DATA_WD;
  parameter RF14_DATA_WD_START = RF13_DATA_WD_START + RF13_DATA_WD;
  parameter RF15_DATA_WD_START = RF14_DATA_WD_START + RF14_DATA_WD;
  parameter RF16_DATA_WD_START = RF15_DATA_WD_START + RF15_DATA_WD;
  parameter RF17_DATA_WD_START = RF16_DATA_WD_START + RF16_DATA_WD;
  parameter RF18_DATA_WD_START = RF17_DATA_WD_START + RF17_DATA_WD;
  parameter RF19_DATA_WD_START = RF18_DATA_WD_START + RF18_DATA_WD;
  parameter RF20_DATA_WD_START = RF19_DATA_WD_START + RF19_DATA_WD;
  parameter RF21_DATA_WD_START = RF20_DATA_WD_START + RF20_DATA_WD;
  parameter RF22_DATA_WD_START = RF21_DATA_WD_START + RF21_DATA_WD;
  parameter RF23_DATA_WD_START = RF22_DATA_WD_START + RF22_DATA_WD;
  parameter RF24_DATA_WD_START = RF23_DATA_WD_START + RF23_DATA_WD;
  parameter RF25_DATA_WD_START = RF24_DATA_WD_START + RF24_DATA_WD;
  parameter RF26_DATA_WD_START = RF25_DATA_WD_START + RF25_DATA_WD;
  parameter RF27_DATA_WD_START = RF26_DATA_WD_START + RF26_DATA_WD;
  parameter RF28_DATA_WD_START = RF27_DATA_WD_START + RF27_DATA_WD;
  parameter RF29_DATA_WD_START = RF28_DATA_WD_START + RF28_DATA_WD;
  parameter RF30_DATA_WD_START = RF29_DATA_WD_START + RF29_DATA_WD;
  parameter RF31_DATA_WD_START = RF30_DATA_WD_START + RF30_DATA_WD;

  parameter [15:0] RF_DATA_WD_START_ARRAY [0:31] = '{RF0_DATA_WD_START ,
                                                     RF1_DATA_WD_START ,
                                                     RF2_DATA_WD_START ,
                                                     RF3_DATA_WD_START ,
                                                     RF4_DATA_WD_START ,
                                                     RF5_DATA_WD_START ,
                                                     RF6_DATA_WD_START ,
                                                     RF7_DATA_WD_START ,
                                                     RF8_DATA_WD_START ,
                                                     RF9_DATA_WD_START ,
                                                     RF10_DATA_WD_START,
                                                     RF11_DATA_WD_START,
                                                     RF12_DATA_WD_START,
                                                     RF13_DATA_WD_START,
                                                     RF14_DATA_WD_START,
                                                     RF15_DATA_WD_START,
                                                     RF16_DATA_WD_START,
                                                     RF17_DATA_WD_START,
                                                     RF18_DATA_WD_START,
                                                     RF19_DATA_WD_START,
                                                     RF20_DATA_WD_START,
                                                     RF21_DATA_WD_START,
                                                     RF22_DATA_WD_START,
                                                     RF23_DATA_WD_START,
                                                     RF24_DATA_WD_START,
                                                     RF25_DATA_WD_START,
                                                     RF26_DATA_WD_START,
                                                     RF27_DATA_WD_START,
                                                     RF28_DATA_WD_START,
                                                     RF29_DATA_WD_START,
                                                     RF30_DATA_WD_START,
                                                     RF31_DATA_WD_START};

  // RF DEPTH of RAM
  parameter RF_DEPTH = RF0_DEPTH  +
                       RF1_DEPTH  +
                       RF2_DEPTH  +
                       RF3_DEPTH  +
                       RF4_DEPTH  +
                       RF5_DEPTH  +
                       RF6_DEPTH  +
                       RF7_DEPTH  +
                       RF8_DEPTH  +
                       RF9_DEPTH  +
                       RF10_DEPTH +
                       RF11_DEPTH +
                       RF12_DEPTH +
                       RF13_DEPTH +
                       RF14_DEPTH +
                       RF15_DEPTH +
                       RF16_DEPTH +
                       RF17_DEPTH +
                       RF18_DEPTH +
                       RF19_DEPTH +
                       RF20_DEPTH +
                       RF21_DEPTH +
                       RF22_DEPTH +
                       RF23_DEPTH +
                       RF24_DEPTH +
                       RF25_DEPTH +
                       RF26_DEPTH +
                       RF27_DEPTH +
                       RF28_DEPTH +
                       RF29_DEPTH +
                       RF30_DEPTH +
                       RF31_DEPTH ;




  // SRAM_BE NAME (STRING)
  parameter string SRAM_BE_NAME [0:31] = '{SRAM_BE_0_NAME,
                                           SRAM_BE_1_NAME,
                                           SRAM_BE_2_NAME,
                                           SRAM_BE_3_NAME,
                                           SRAM_BE_4_NAME,
                                           SRAM_BE_5_NAME,
                                           SRAM_BE_6_NAME,
                                           SRAM_BE_7_NAME,
                                           SRAM_BE_8_NAME,
                                           SRAM_BE_9_NAME,
                                           SRAM_BE_10_NAME,
                                           SRAM_BE_11_NAME,
                                           SRAM_BE_12_NAME,
                                           SRAM_BE_13_NAME,
                                           SRAM_BE_14_NAME,
                                           SRAM_BE_15_NAME,
                                           SRAM_BE_16_NAME,
                                           SRAM_BE_17_NAME,
                                           SRAM_BE_18_NAME,
                                           SRAM_BE_19_NAME,
                                           SRAM_BE_20_NAME,
                                           SRAM_BE_21_NAME,
                                           SRAM_BE_22_NAME,
                                           SRAM_BE_23_NAME,
                                           SRAM_BE_24_NAME,
                                           SRAM_BE_25_NAME,
                                           SRAM_BE_26_NAME,
                                           SRAM_BE_27_NAME,
                                           SRAM_BE_28_NAME,
                                           SRAM_BE_29_NAME,
                                           SRAM_BE_30_NAME,
                                           SRAM_BE_31_NAME};

  // SRAM_BE ADDRESS WIDTH
  parameter SRAM_BE_ADDR_WD = SRAM_BE_0_ADDR_WD  +
                              SRAM_BE_1_ADDR_WD  +
                              SRAM_BE_2_ADDR_WD  +
                              SRAM_BE_3_ADDR_WD  +
                              SRAM_BE_4_ADDR_WD  +
                              SRAM_BE_5_ADDR_WD  +
                              SRAM_BE_6_ADDR_WD  +
                              SRAM_BE_7_ADDR_WD  +
                              SRAM_BE_8_ADDR_WD  +
                              SRAM_BE_9_ADDR_WD  +
                              SRAM_BE_10_ADDR_WD +
                              SRAM_BE_11_ADDR_WD +
                              SRAM_BE_12_ADDR_WD +
                              SRAM_BE_13_ADDR_WD +
                              SRAM_BE_14_ADDR_WD +
                              SRAM_BE_15_ADDR_WD +
                              SRAM_BE_16_ADDR_WD +
                              SRAM_BE_17_ADDR_WD +
                              SRAM_BE_18_ADDR_WD +
                              SRAM_BE_19_ADDR_WD +
                              SRAM_BE_20_ADDR_WD +
                              SRAM_BE_21_ADDR_WD +
                              SRAM_BE_22_ADDR_WD +
                              SRAM_BE_23_ADDR_WD +
                              SRAM_BE_24_ADDR_WD +
                              SRAM_BE_25_ADDR_WD +
                              SRAM_BE_26_ADDR_WD +
                              SRAM_BE_27_ADDR_WD +
                              SRAM_BE_28_ADDR_WD +
                              SRAM_BE_29_ADDR_WD +
                              SRAM_BE_30_ADDR_WD +
                              SRAM_BE_31_ADDR_WD;

  parameter [10:0] SRAM_BE_ADDR_WD_ARRAY [0:31] = '{SRAM_BE_0_ADDR_WD ,
                                                    SRAM_BE_1_ADDR_WD ,
                                                    SRAM_BE_2_ADDR_WD ,
                                                    SRAM_BE_3_ADDR_WD ,
                                                    SRAM_BE_4_ADDR_WD ,
                                                    SRAM_BE_5_ADDR_WD ,
                                                    SRAM_BE_6_ADDR_WD ,
                                                    SRAM_BE_7_ADDR_WD ,
                                                    SRAM_BE_8_ADDR_WD ,
                                                    SRAM_BE_9_ADDR_WD ,
                                                    SRAM_BE_10_ADDR_WD,
                                                    SRAM_BE_11_ADDR_WD,
                                                    SRAM_BE_12_ADDR_WD,
                                                    SRAM_BE_13_ADDR_WD,
                                                    SRAM_BE_14_ADDR_WD,
                                                    SRAM_BE_15_ADDR_WD,
                                                    SRAM_BE_16_ADDR_WD,
                                                    SRAM_BE_17_ADDR_WD,
                                                    SRAM_BE_18_ADDR_WD,
                                                    SRAM_BE_19_ADDR_WD,
                                                    SRAM_BE_20_ADDR_WD,
                                                    SRAM_BE_21_ADDR_WD,
                                                    SRAM_BE_22_ADDR_WD,
                                                    SRAM_BE_23_ADDR_WD,
                                                    SRAM_BE_24_ADDR_WD,
                                                    SRAM_BE_25_ADDR_WD,
                                                    SRAM_BE_26_ADDR_WD,
                                                    SRAM_BE_27_ADDR_WD,
                                                    SRAM_BE_28_ADDR_WD,
                                                    SRAM_BE_29_ADDR_WD,
                                                    SRAM_BE_30_ADDR_WD,
                                                    SRAM_BE_31_ADDR_WD};

  parameter SRAM_BE_0_ADDR_WD_START  = 0;
  parameter SRAM_BE_1_ADDR_WD_START  = SRAM_BE_0_ADDR_WD_START  + SRAM_BE_0_ADDR_WD ;
  parameter SRAM_BE_2_ADDR_WD_START  = SRAM_BE_1_ADDR_WD_START  + SRAM_BE_1_ADDR_WD ;
  parameter SRAM_BE_3_ADDR_WD_START  = SRAM_BE_2_ADDR_WD_START  + SRAM_BE_2_ADDR_WD ;
  parameter SRAM_BE_4_ADDR_WD_START  = SRAM_BE_3_ADDR_WD_START  + SRAM_BE_3_ADDR_WD ;
  parameter SRAM_BE_5_ADDR_WD_START  = SRAM_BE_4_ADDR_WD_START  + SRAM_BE_4_ADDR_WD ;
  parameter SRAM_BE_6_ADDR_WD_START  = SRAM_BE_5_ADDR_WD_START  + SRAM_BE_5_ADDR_WD ;
  parameter SRAM_BE_7_ADDR_WD_START  = SRAM_BE_6_ADDR_WD_START  + SRAM_BE_6_ADDR_WD ;
  parameter SRAM_BE_8_ADDR_WD_START  = SRAM_BE_7_ADDR_WD_START  + SRAM_BE_7_ADDR_WD ;
  parameter SRAM_BE_9_ADDR_WD_START  = SRAM_BE_8_ADDR_WD_START  + SRAM_BE_8_ADDR_WD ;
  parameter SRAM_BE_10_ADDR_WD_START = SRAM_BE_9_ADDR_WD_START  + SRAM_BE_9_ADDR_WD ;
  parameter SRAM_BE_11_ADDR_WD_START = SRAM_BE_10_ADDR_WD_START + SRAM_BE_10_ADDR_WD;
  parameter SRAM_BE_12_ADDR_WD_START = SRAM_BE_11_ADDR_WD_START + SRAM_BE_11_ADDR_WD;
  parameter SRAM_BE_13_ADDR_WD_START = SRAM_BE_12_ADDR_WD_START + SRAM_BE_12_ADDR_WD;
  parameter SRAM_BE_14_ADDR_WD_START = SRAM_BE_13_ADDR_WD_START + SRAM_BE_13_ADDR_WD;
  parameter SRAM_BE_15_ADDR_WD_START = SRAM_BE_14_ADDR_WD_START + SRAM_BE_14_ADDR_WD;
  parameter SRAM_BE_16_ADDR_WD_START = SRAM_BE_15_ADDR_WD_START + SRAM_BE_15_ADDR_WD;
  parameter SRAM_BE_17_ADDR_WD_START = SRAM_BE_16_ADDR_WD_START + SRAM_BE_16_ADDR_WD;
  parameter SRAM_BE_18_ADDR_WD_START = SRAM_BE_17_ADDR_WD_START + SRAM_BE_17_ADDR_WD;
  parameter SRAM_BE_19_ADDR_WD_START = SRAM_BE_18_ADDR_WD_START + SRAM_BE_18_ADDR_WD;
  parameter SRAM_BE_20_ADDR_WD_START = SRAM_BE_19_ADDR_WD_START + SRAM_BE_19_ADDR_WD;
  parameter SRAM_BE_21_ADDR_WD_START = SRAM_BE_20_ADDR_WD_START + SRAM_BE_20_ADDR_WD;
  parameter SRAM_BE_22_ADDR_WD_START = SRAM_BE_21_ADDR_WD_START + SRAM_BE_21_ADDR_WD;
  parameter SRAM_BE_23_ADDR_WD_START = SRAM_BE_22_ADDR_WD_START + SRAM_BE_22_ADDR_WD;
  parameter SRAM_BE_24_ADDR_WD_START = SRAM_BE_23_ADDR_WD_START + SRAM_BE_23_ADDR_WD;
  parameter SRAM_BE_25_ADDR_WD_START = SRAM_BE_24_ADDR_WD_START + SRAM_BE_24_ADDR_WD;
  parameter SRAM_BE_26_ADDR_WD_START = SRAM_BE_25_ADDR_WD_START + SRAM_BE_25_ADDR_WD;
  parameter SRAM_BE_27_ADDR_WD_START = SRAM_BE_26_ADDR_WD_START + SRAM_BE_26_ADDR_WD;
  parameter SRAM_BE_28_ADDR_WD_START = SRAM_BE_27_ADDR_WD_START + SRAM_BE_27_ADDR_WD;
  parameter SRAM_BE_29_ADDR_WD_START = SRAM_BE_28_ADDR_WD_START + SRAM_BE_28_ADDR_WD;
  parameter SRAM_BE_30_ADDR_WD_START = SRAM_BE_29_ADDR_WD_START + SRAM_BE_29_ADDR_WD;
  parameter SRAM_BE_31_ADDR_WD_START = SRAM_BE_30_ADDR_WD_START + SRAM_BE_30_ADDR_WD;

  parameter [10:0] SRAM_BE_ADDR_WD_START_ARRAY [0:31] = '{SRAM_BE_0_ADDR_WD_START ,
                                                          SRAM_BE_1_ADDR_WD_START ,
                                                          SRAM_BE_2_ADDR_WD_START ,
                                                          SRAM_BE_3_ADDR_WD_START ,
                                                          SRAM_BE_4_ADDR_WD_START ,
                                                          SRAM_BE_5_ADDR_WD_START ,
                                                          SRAM_BE_6_ADDR_WD_START ,
                                                          SRAM_BE_7_ADDR_WD_START ,
                                                          SRAM_BE_8_ADDR_WD_START ,
                                                          SRAM_BE_9_ADDR_WD_START ,
                                                          SRAM_BE_10_ADDR_WD_START,
                                                          SRAM_BE_11_ADDR_WD_START,
                                                          SRAM_BE_12_ADDR_WD_START,
                                                          SRAM_BE_13_ADDR_WD_START,
                                                          SRAM_BE_14_ADDR_WD_START,
                                                          SRAM_BE_15_ADDR_WD_START,
                                                          SRAM_BE_16_ADDR_WD_START,
                                                          SRAM_BE_17_ADDR_WD_START,
                                                          SRAM_BE_18_ADDR_WD_START,
                                                          SRAM_BE_19_ADDR_WD_START,
                                                          SRAM_BE_20_ADDR_WD_START,
                                                          SRAM_BE_21_ADDR_WD_START,
                                                          SRAM_BE_22_ADDR_WD_START,
                                                          SRAM_BE_23_ADDR_WD_START,
                                                          SRAM_BE_24_ADDR_WD_START,
                                                          SRAM_BE_25_ADDR_WD_START,
                                                          SRAM_BE_26_ADDR_WD_START,
                                                          SRAM_BE_27_ADDR_WD_START,
                                                          SRAM_BE_28_ADDR_WD_START,
                                                          SRAM_BE_29_ADDR_WD_START,
                                                          SRAM_BE_30_ADDR_WD_START,
                                                          SRAM_BE_31_ADDR_WD_START};

  // SRAM_BE DATA WIDTH
  parameter SRAM_BE_DATA_WD = SRAM_BE_0_DATA_WD  +
                              SRAM_BE_1_DATA_WD  +
                              SRAM_BE_2_DATA_WD  +
                              SRAM_BE_3_DATA_WD  +
                              SRAM_BE_4_DATA_WD  +
                              SRAM_BE_5_DATA_WD  +
                              SRAM_BE_6_DATA_WD  +
                              SRAM_BE_7_DATA_WD  +
                              SRAM_BE_8_DATA_WD  +
                              SRAM_BE_9_DATA_WD  +
                              SRAM_BE_10_DATA_WD +
                              SRAM_BE_11_DATA_WD +
                              SRAM_BE_12_DATA_WD +
                              SRAM_BE_13_DATA_WD +
                              SRAM_BE_14_DATA_WD +
                              SRAM_BE_15_DATA_WD +
                              SRAM_BE_16_DATA_WD +
                              SRAM_BE_17_DATA_WD +
                              SRAM_BE_18_DATA_WD +
                              SRAM_BE_19_DATA_WD +
                              SRAM_BE_20_DATA_WD +
                              SRAM_BE_21_DATA_WD +
                              SRAM_BE_22_DATA_WD +
                              SRAM_BE_23_DATA_WD +
                              SRAM_BE_24_DATA_WD +
                              SRAM_BE_25_DATA_WD +
                              SRAM_BE_26_DATA_WD +
                              SRAM_BE_27_DATA_WD +
                              SRAM_BE_28_DATA_WD +
                              SRAM_BE_29_DATA_WD +
                              SRAM_BE_30_DATA_WD +
                              SRAM_BE_31_DATA_WD;

  parameter [15:0] SRAM_BE_DATA_WD_ARRAY [0:31] = '{SRAM_BE_0_DATA_WD ,
                                                    SRAM_BE_1_DATA_WD ,
                                                    SRAM_BE_2_DATA_WD ,
                                                    SRAM_BE_3_DATA_WD ,
                                                    SRAM_BE_4_DATA_WD ,
                                                    SRAM_BE_5_DATA_WD ,
                                                    SRAM_BE_6_DATA_WD ,
                                                    SRAM_BE_7_DATA_WD ,
                                                    SRAM_BE_8_DATA_WD ,
                                                    SRAM_BE_9_DATA_WD ,
                                                    SRAM_BE_10_DATA_WD,
                                                    SRAM_BE_11_DATA_WD,
                                                    SRAM_BE_12_DATA_WD,
                                                    SRAM_BE_13_DATA_WD,
                                                    SRAM_BE_14_DATA_WD,
                                                    SRAM_BE_15_DATA_WD,
                                                    SRAM_BE_16_DATA_WD,
                                                    SRAM_BE_17_DATA_WD,
                                                    SRAM_BE_18_DATA_WD,
                                                    SRAM_BE_19_DATA_WD,
                                                    SRAM_BE_20_DATA_WD,
                                                    SRAM_BE_21_DATA_WD,
                                                    SRAM_BE_22_DATA_WD,
                                                    SRAM_BE_23_DATA_WD,
                                                    SRAM_BE_24_DATA_WD,
                                                    SRAM_BE_25_DATA_WD,
                                                    SRAM_BE_26_DATA_WD,
                                                    SRAM_BE_27_DATA_WD,
                                                    SRAM_BE_28_DATA_WD,
                                                    SRAM_BE_29_DATA_WD,
                                                    SRAM_BE_30_DATA_WD,
                                                    SRAM_BE_31_DATA_WD};

  parameter SRAM_BE_0_DATA_WD_START  = 0;
  parameter SRAM_BE_1_DATA_WD_START  = SRAM_BE_0_DATA_WD_START  + SRAM_BE_0_DATA_WD ;
  parameter SRAM_BE_2_DATA_WD_START  = SRAM_BE_1_DATA_WD_START  + SRAM_BE_1_DATA_WD ;
  parameter SRAM_BE_3_DATA_WD_START  = SRAM_BE_2_DATA_WD_START  + SRAM_BE_2_DATA_WD ;
  parameter SRAM_BE_4_DATA_WD_START  = SRAM_BE_3_DATA_WD_START  + SRAM_BE_3_DATA_WD ;
  parameter SRAM_BE_5_DATA_WD_START  = SRAM_BE_4_DATA_WD_START  + SRAM_BE_4_DATA_WD ;
  parameter SRAM_BE_6_DATA_WD_START  = SRAM_BE_5_DATA_WD_START  + SRAM_BE_5_DATA_WD ;
  parameter SRAM_BE_7_DATA_WD_START  = SRAM_BE_6_DATA_WD_START  + SRAM_BE_6_DATA_WD ;
  parameter SRAM_BE_8_DATA_WD_START  = SRAM_BE_7_DATA_WD_START  + SRAM_BE_7_DATA_WD ;
  parameter SRAM_BE_9_DATA_WD_START  = SRAM_BE_8_DATA_WD_START  + SRAM_BE_8_DATA_WD ;
  parameter SRAM_BE_10_DATA_WD_START = SRAM_BE_9_DATA_WD_START  + SRAM_BE_9_DATA_WD ;
  parameter SRAM_BE_11_DATA_WD_START = SRAM_BE_10_DATA_WD_START + SRAM_BE_10_DATA_WD;
  parameter SRAM_BE_12_DATA_WD_START = SRAM_BE_11_DATA_WD_START + SRAM_BE_11_DATA_WD;
  parameter SRAM_BE_13_DATA_WD_START = SRAM_BE_12_DATA_WD_START + SRAM_BE_12_DATA_WD;
  parameter SRAM_BE_14_DATA_WD_START = SRAM_BE_13_DATA_WD_START + SRAM_BE_13_DATA_WD;
  parameter SRAM_BE_15_DATA_WD_START = SRAM_BE_14_DATA_WD_START + SRAM_BE_14_DATA_WD;
  parameter SRAM_BE_16_DATA_WD_START = SRAM_BE_15_DATA_WD_START + SRAM_BE_15_DATA_WD;
  parameter SRAM_BE_17_DATA_WD_START = SRAM_BE_16_DATA_WD_START + SRAM_BE_16_DATA_WD;
  parameter SRAM_BE_18_DATA_WD_START = SRAM_BE_17_DATA_WD_START + SRAM_BE_17_DATA_WD;
  parameter SRAM_BE_19_DATA_WD_START = SRAM_BE_18_DATA_WD_START + SRAM_BE_18_DATA_WD;
  parameter SRAM_BE_20_DATA_WD_START = SRAM_BE_19_DATA_WD_START + SRAM_BE_19_DATA_WD;
  parameter SRAM_BE_21_DATA_WD_START = SRAM_BE_20_DATA_WD_START + SRAM_BE_20_DATA_WD;
  parameter SRAM_BE_22_DATA_WD_START = SRAM_BE_21_DATA_WD_START + SRAM_BE_21_DATA_WD;
  parameter SRAM_BE_23_DATA_WD_START = SRAM_BE_22_DATA_WD_START + SRAM_BE_22_DATA_WD;
  parameter SRAM_BE_24_DATA_WD_START = SRAM_BE_23_DATA_WD_START + SRAM_BE_23_DATA_WD;
  parameter SRAM_BE_25_DATA_WD_START = SRAM_BE_24_DATA_WD_START + SRAM_BE_24_DATA_WD;
  parameter SRAM_BE_26_DATA_WD_START = SRAM_BE_25_DATA_WD_START + SRAM_BE_25_DATA_WD;
  parameter SRAM_BE_27_DATA_WD_START = SRAM_BE_26_DATA_WD_START + SRAM_BE_26_DATA_WD;
  parameter SRAM_BE_28_DATA_WD_START = SRAM_BE_27_DATA_WD_START + SRAM_BE_27_DATA_WD;
  parameter SRAM_BE_29_DATA_WD_START = SRAM_BE_28_DATA_WD_START + SRAM_BE_28_DATA_WD;
  parameter SRAM_BE_30_DATA_WD_START = SRAM_BE_29_DATA_WD_START + SRAM_BE_29_DATA_WD;
  parameter SRAM_BE_31_DATA_WD_START = SRAM_BE_30_DATA_WD_START + SRAM_BE_30_DATA_WD;

  parameter [15:0] SRAM_BE_DATA_WD_START_ARRAY [0:31] = '{SRAM_BE_0_DATA_WD_START ,
                                                          SRAM_BE_1_DATA_WD_START ,
                                                          SRAM_BE_2_DATA_WD_START ,
                                                          SRAM_BE_3_DATA_WD_START ,
                                                          SRAM_BE_4_DATA_WD_START ,
                                                          SRAM_BE_5_DATA_WD_START ,
                                                          SRAM_BE_6_DATA_WD_START ,
                                                          SRAM_BE_7_DATA_WD_START ,
                                                          SRAM_BE_8_DATA_WD_START ,
                                                          SRAM_BE_9_DATA_WD_START ,
                                                          SRAM_BE_10_DATA_WD_START,
                                                          SRAM_BE_11_DATA_WD_START,
                                                          SRAM_BE_12_DATA_WD_START,
                                                          SRAM_BE_13_DATA_WD_START,
                                                          SRAM_BE_14_DATA_WD_START,
                                                          SRAM_BE_15_DATA_WD_START,
                                                          SRAM_BE_16_DATA_WD_START,
                                                          SRAM_BE_17_DATA_WD_START,
                                                          SRAM_BE_18_DATA_WD_START,
                                                          SRAM_BE_19_DATA_WD_START,
                                                          SRAM_BE_20_DATA_WD_START,
                                                          SRAM_BE_21_DATA_WD_START,
                                                          SRAM_BE_22_DATA_WD_START,
                                                          SRAM_BE_23_DATA_WD_START,
                                                          SRAM_BE_24_DATA_WD_START,
                                                          SRAM_BE_25_DATA_WD_START,
                                                          SRAM_BE_26_DATA_WD_START,
                                                          SRAM_BE_27_DATA_WD_START,
                                                          SRAM_BE_28_DATA_WD_START,
                                                          SRAM_BE_29_DATA_WD_START,
                                                          SRAM_BE_30_DATA_WD_START,
                                                          SRAM_BE_31_DATA_WD_START};

  // SRAM_BE DEPTH of RAM
  parameter SRAM_BE_DEPTH = SRAM_BE_0_DEPTH  +
                            SRAM_BE_1_DEPTH  +
                            SRAM_BE_2_DEPTH  +
                            SRAM_BE_3_DEPTH  +
                            SRAM_BE_4_DEPTH  +
                            SRAM_BE_5_DEPTH  +
                            SRAM_BE_6_DEPTH  +
                            SRAM_BE_7_DEPTH  +
                            SRAM_BE_8_DEPTH  +
                            SRAM_BE_9_DEPTH  +
                            SRAM_BE_10_DEPTH +
                            SRAM_BE_11_DEPTH +
                            SRAM_BE_12_DEPTH +
                            SRAM_BE_13_DEPTH +
                            SRAM_BE_14_DEPTH +
                            SRAM_BE_15_DEPTH +
                            SRAM_BE_16_DEPTH +
                            SRAM_BE_17_DEPTH +
                            SRAM_BE_18_DEPTH +
                            SRAM_BE_19_DEPTH +
                            SRAM_BE_20_DEPTH +
                            SRAM_BE_21_DEPTH +
                            SRAM_BE_22_DEPTH +
                            SRAM_BE_23_DEPTH +
                            SRAM_BE_24_DEPTH +
                            SRAM_BE_25_DEPTH +
                            SRAM_BE_26_DEPTH +
                            SRAM_BE_27_DEPTH +
                            SRAM_BE_28_DEPTH +
                            SRAM_BE_29_DEPTH +
                            SRAM_BE_30_DEPTH +
                            SRAM_BE_31_DEPTH;


  // DP1R1W_BE NAME (STRING)
  parameter string DP1R1W_BE_NAME [0:31] = '{DP1R1W_BE_0_NAME,
                                             DP1R1W_BE_1_NAME,
                                             DP1R1W_BE_2_NAME,
                                             DP1R1W_BE_3_NAME,
                                             DP1R1W_BE_4_NAME,
                                             DP1R1W_BE_5_NAME,
                                             DP1R1W_BE_6_NAME,
                                             DP1R1W_BE_7_NAME,
                                             DP1R1W_BE_8_NAME,
                                             DP1R1W_BE_9_NAME,
                                             DP1R1W_BE_10_NAME,
                                             DP1R1W_BE_11_NAME,
                                             DP1R1W_BE_12_NAME,
                                             DP1R1W_BE_13_NAME,
                                             DP1R1W_BE_14_NAME,
                                             DP1R1W_BE_15_NAME,
                                             DP1R1W_BE_16_NAME,
                                             DP1R1W_BE_17_NAME,
                                             DP1R1W_BE_18_NAME,
                                             DP1R1W_BE_19_NAME,
                                             DP1R1W_BE_20_NAME,
                                             DP1R1W_BE_21_NAME,
                                             DP1R1W_BE_22_NAME,
                                             DP1R1W_BE_23_NAME,
                                             DP1R1W_BE_24_NAME,
                                             DP1R1W_BE_25_NAME,
                                             DP1R1W_BE_26_NAME,
                                             DP1R1W_BE_27_NAME,
                                             DP1R1W_BE_28_NAME,
                                             DP1R1W_BE_29_NAME,
                                             DP1R1W_BE_30_NAME,
                                             DP1R1W_BE_31_NAME};

  // DP1R1W_BE ADDRESS WIDTH
  parameter DP1R1W_BE_ADDR_WD = DP1R1W_BE_0_ADDR_WD  +
                                DP1R1W_BE_1_ADDR_WD  +
                                DP1R1W_BE_2_ADDR_WD  +
                                DP1R1W_BE_3_ADDR_WD  +
                                DP1R1W_BE_4_ADDR_WD  +
                                DP1R1W_BE_5_ADDR_WD  +
                                DP1R1W_BE_6_ADDR_WD  +
                                DP1R1W_BE_7_ADDR_WD  +
                                DP1R1W_BE_8_ADDR_WD  +
                                DP1R1W_BE_9_ADDR_WD  +
                                DP1R1W_BE_10_ADDR_WD +
                                DP1R1W_BE_11_ADDR_WD +
                                DP1R1W_BE_12_ADDR_WD +
                                DP1R1W_BE_13_ADDR_WD +
                                DP1R1W_BE_14_ADDR_WD +
                                DP1R1W_BE_15_ADDR_WD +
                                DP1R1W_BE_16_ADDR_WD +
                                DP1R1W_BE_17_ADDR_WD +
                                DP1R1W_BE_18_ADDR_WD +
                                DP1R1W_BE_19_ADDR_WD +
                                DP1R1W_BE_20_ADDR_WD +
                                DP1R1W_BE_21_ADDR_WD +
                                DP1R1W_BE_22_ADDR_WD +
                                DP1R1W_BE_23_ADDR_WD +
                                DP1R1W_BE_24_ADDR_WD +
                                DP1R1W_BE_25_ADDR_WD +
                                DP1R1W_BE_26_ADDR_WD +
                                DP1R1W_BE_27_ADDR_WD +
                                DP1R1W_BE_28_ADDR_WD +
                                DP1R1W_BE_29_ADDR_WD +
                                DP1R1W_BE_30_ADDR_WD +
                                DP1R1W_BE_31_ADDR_WD;

  parameter [10:0] DP1R1W_BE_ADDR_WD_ARRAY [0:31] = '{DP1R1W_BE_0_ADDR_WD ,
                                                      DP1R1W_BE_1_ADDR_WD ,
                                                      DP1R1W_BE_2_ADDR_WD ,
                                                      DP1R1W_BE_3_ADDR_WD ,
                                                      DP1R1W_BE_4_ADDR_WD ,
                                                      DP1R1W_BE_5_ADDR_WD ,
                                                      DP1R1W_BE_6_ADDR_WD ,
                                                      DP1R1W_BE_7_ADDR_WD ,
                                                      DP1R1W_BE_8_ADDR_WD ,
                                                      DP1R1W_BE_9_ADDR_WD ,
                                                      DP1R1W_BE_10_ADDR_WD,
                                                      DP1R1W_BE_11_ADDR_WD,
                                                      DP1R1W_BE_12_ADDR_WD,
                                                      DP1R1W_BE_13_ADDR_WD,
                                                      DP1R1W_BE_14_ADDR_WD,
                                                      DP1R1W_BE_15_ADDR_WD,
                                                      DP1R1W_BE_16_ADDR_WD,
                                                      DP1R1W_BE_17_ADDR_WD,
                                                      DP1R1W_BE_18_ADDR_WD,
                                                      DP1R1W_BE_19_ADDR_WD,
                                                      DP1R1W_BE_20_ADDR_WD,
                                                      DP1R1W_BE_21_ADDR_WD,
                                                      DP1R1W_BE_22_ADDR_WD,
                                                      DP1R1W_BE_23_ADDR_WD,
                                                      DP1R1W_BE_24_ADDR_WD,
                                                      DP1R1W_BE_25_ADDR_WD,
                                                      DP1R1W_BE_26_ADDR_WD,
                                                      DP1R1W_BE_27_ADDR_WD,
                                                      DP1R1W_BE_28_ADDR_WD,
                                                      DP1R1W_BE_29_ADDR_WD,
                                                      DP1R1W_BE_30_ADDR_WD,
                                                      DP1R1W_BE_31_ADDR_WD};

  parameter DP1R1W_BE_0_ADDR_WD_START  = 0;
  parameter DP1R1W_BE_1_ADDR_WD_START  = DP1R1W_BE_0_ADDR_WD_START  + DP1R1W_BE_0_ADDR_WD ;
  parameter DP1R1W_BE_2_ADDR_WD_START  = DP1R1W_BE_1_ADDR_WD_START  + DP1R1W_BE_1_ADDR_WD ;
  parameter DP1R1W_BE_3_ADDR_WD_START  = DP1R1W_BE_2_ADDR_WD_START  + DP1R1W_BE_2_ADDR_WD ;
  parameter DP1R1W_BE_4_ADDR_WD_START  = DP1R1W_BE_3_ADDR_WD_START  + DP1R1W_BE_3_ADDR_WD ;
  parameter DP1R1W_BE_5_ADDR_WD_START  = DP1R1W_BE_4_ADDR_WD_START  + DP1R1W_BE_4_ADDR_WD ;
  parameter DP1R1W_BE_6_ADDR_WD_START  = DP1R1W_BE_5_ADDR_WD_START  + DP1R1W_BE_5_ADDR_WD ;
  parameter DP1R1W_BE_7_ADDR_WD_START  = DP1R1W_BE_6_ADDR_WD_START  + DP1R1W_BE_6_ADDR_WD ;
  parameter DP1R1W_BE_8_ADDR_WD_START  = DP1R1W_BE_7_ADDR_WD_START  + DP1R1W_BE_7_ADDR_WD ;
  parameter DP1R1W_BE_9_ADDR_WD_START  = DP1R1W_BE_8_ADDR_WD_START  + DP1R1W_BE_8_ADDR_WD ;
  parameter DP1R1W_BE_10_ADDR_WD_START = DP1R1W_BE_9_ADDR_WD_START  + DP1R1W_BE_9_ADDR_WD ;
  parameter DP1R1W_BE_11_ADDR_WD_START = DP1R1W_BE_10_ADDR_WD_START + DP1R1W_BE_10_ADDR_WD;
  parameter DP1R1W_BE_12_ADDR_WD_START = DP1R1W_BE_11_ADDR_WD_START + DP1R1W_BE_11_ADDR_WD;
  parameter DP1R1W_BE_13_ADDR_WD_START = DP1R1W_BE_12_ADDR_WD_START + DP1R1W_BE_12_ADDR_WD;
  parameter DP1R1W_BE_14_ADDR_WD_START = DP1R1W_BE_13_ADDR_WD_START + DP1R1W_BE_13_ADDR_WD;
  parameter DP1R1W_BE_15_ADDR_WD_START = DP1R1W_BE_14_ADDR_WD_START + DP1R1W_BE_14_ADDR_WD;
  parameter DP1R1W_BE_16_ADDR_WD_START = DP1R1W_BE_15_ADDR_WD_START + DP1R1W_BE_15_ADDR_WD;
  parameter DP1R1W_BE_17_ADDR_WD_START = DP1R1W_BE_16_ADDR_WD_START + DP1R1W_BE_16_ADDR_WD;
  parameter DP1R1W_BE_18_ADDR_WD_START = DP1R1W_BE_17_ADDR_WD_START + DP1R1W_BE_17_ADDR_WD;
  parameter DP1R1W_BE_19_ADDR_WD_START = DP1R1W_BE_18_ADDR_WD_START + DP1R1W_BE_18_ADDR_WD;
  parameter DP1R1W_BE_20_ADDR_WD_START = DP1R1W_BE_19_ADDR_WD_START + DP1R1W_BE_19_ADDR_WD;
  parameter DP1R1W_BE_21_ADDR_WD_START = DP1R1W_BE_20_ADDR_WD_START + DP1R1W_BE_20_ADDR_WD;
  parameter DP1R1W_BE_22_ADDR_WD_START = DP1R1W_BE_21_ADDR_WD_START + DP1R1W_BE_21_ADDR_WD;
  parameter DP1R1W_BE_23_ADDR_WD_START = DP1R1W_BE_22_ADDR_WD_START + DP1R1W_BE_22_ADDR_WD;
  parameter DP1R1W_BE_24_ADDR_WD_START = DP1R1W_BE_23_ADDR_WD_START + DP1R1W_BE_23_ADDR_WD;
  parameter DP1R1W_BE_25_ADDR_WD_START = DP1R1W_BE_24_ADDR_WD_START + DP1R1W_BE_24_ADDR_WD;
  parameter DP1R1W_BE_26_ADDR_WD_START = DP1R1W_BE_25_ADDR_WD_START + DP1R1W_BE_25_ADDR_WD;
  parameter DP1R1W_BE_27_ADDR_WD_START = DP1R1W_BE_26_ADDR_WD_START + DP1R1W_BE_26_ADDR_WD;
  parameter DP1R1W_BE_28_ADDR_WD_START = DP1R1W_BE_27_ADDR_WD_START + DP1R1W_BE_27_ADDR_WD;
  parameter DP1R1W_BE_29_ADDR_WD_START = DP1R1W_BE_28_ADDR_WD_START + DP1R1W_BE_28_ADDR_WD;
  parameter DP1R1W_BE_30_ADDR_WD_START = DP1R1W_BE_29_ADDR_WD_START + DP1R1W_BE_29_ADDR_WD;
  parameter DP1R1W_BE_31_ADDR_WD_START = DP1R1W_BE_30_ADDR_WD_START + DP1R1W_BE_30_ADDR_WD;

  parameter [10:0] DP1R1W_BE_ADDR_WD_START_ARRAY [0:31] = '{DP1R1W_BE_0_ADDR_WD_START ,
                                                            DP1R1W_BE_1_ADDR_WD_START ,
                                                            DP1R1W_BE_2_ADDR_WD_START ,
                                                            DP1R1W_BE_3_ADDR_WD_START ,
                                                            DP1R1W_BE_4_ADDR_WD_START ,
                                                            DP1R1W_BE_5_ADDR_WD_START ,
                                                            DP1R1W_BE_6_ADDR_WD_START ,
                                                            DP1R1W_BE_7_ADDR_WD_START ,
                                                            DP1R1W_BE_8_ADDR_WD_START ,
                                                            DP1R1W_BE_9_ADDR_WD_START ,
                                                            DP1R1W_BE_10_ADDR_WD_START,
                                                            DP1R1W_BE_11_ADDR_WD_START,
                                                            DP1R1W_BE_12_ADDR_WD_START,
                                                            DP1R1W_BE_13_ADDR_WD_START,
                                                            DP1R1W_BE_14_ADDR_WD_START,
                                                            DP1R1W_BE_15_ADDR_WD_START,
                                                            DP1R1W_BE_16_ADDR_WD_START,
                                                            DP1R1W_BE_17_ADDR_WD_START,
                                                            DP1R1W_BE_18_ADDR_WD_START,
                                                            DP1R1W_BE_19_ADDR_WD_START,
                                                            DP1R1W_BE_20_ADDR_WD_START,
                                                            DP1R1W_BE_21_ADDR_WD_START,
                                                            DP1R1W_BE_22_ADDR_WD_START,
                                                            DP1R1W_BE_23_ADDR_WD_START,
                                                            DP1R1W_BE_24_ADDR_WD_START,
                                                            DP1R1W_BE_25_ADDR_WD_START,
                                                            DP1R1W_BE_26_ADDR_WD_START,
                                                            DP1R1W_BE_27_ADDR_WD_START,
                                                            DP1R1W_BE_28_ADDR_WD_START,
                                                            DP1R1W_BE_29_ADDR_WD_START,
                                                            DP1R1W_BE_30_ADDR_WD_START,
                                                            DP1R1W_BE_31_ADDR_WD_START};

  // DP1R1W_BE DATA WIDTH
  parameter DP1R1W_BE_DATA_WD = DP1R1W_BE_0_DATA_WD  +
                                DP1R1W_BE_1_DATA_WD  +
                                DP1R1W_BE_2_DATA_WD  +
                                DP1R1W_BE_3_DATA_WD  +
                                DP1R1W_BE_4_DATA_WD  +
                                DP1R1W_BE_5_DATA_WD  +
                                DP1R1W_BE_6_DATA_WD  +
                                DP1R1W_BE_7_DATA_WD  +
                                DP1R1W_BE_8_DATA_WD  +
                                DP1R1W_BE_9_DATA_WD  +
                                DP1R1W_BE_10_DATA_WD +
                                DP1R1W_BE_11_DATA_WD +
                                DP1R1W_BE_12_DATA_WD +
                                DP1R1W_BE_13_DATA_WD +
                                DP1R1W_BE_14_DATA_WD +
                                DP1R1W_BE_15_DATA_WD +
                                DP1R1W_BE_16_DATA_WD +
                                DP1R1W_BE_17_DATA_WD +
                                DP1R1W_BE_18_DATA_WD +
                                DP1R1W_BE_19_DATA_WD +
                                DP1R1W_BE_20_DATA_WD +
                                DP1R1W_BE_21_DATA_WD +
                                DP1R1W_BE_22_DATA_WD +
                                DP1R1W_BE_23_DATA_WD +
                                DP1R1W_BE_24_DATA_WD +
                                DP1R1W_BE_25_DATA_WD +
                                DP1R1W_BE_26_DATA_WD +
                                DP1R1W_BE_27_DATA_WD +
                                DP1R1W_BE_28_DATA_WD +
                                DP1R1W_BE_29_DATA_WD +
                                DP1R1W_BE_30_DATA_WD +
                                DP1R1W_BE_31_DATA_WD;

  parameter [15:0] DP1R1W_BE_DATA_WD_ARRAY [0:31] = '{DP1R1W_BE_0_DATA_WD ,
                                                      DP1R1W_BE_1_DATA_WD ,
                                                      DP1R1W_BE_2_DATA_WD ,
                                                      DP1R1W_BE_3_DATA_WD ,
                                                      DP1R1W_BE_4_DATA_WD ,
                                                      DP1R1W_BE_5_DATA_WD ,
                                                      DP1R1W_BE_6_DATA_WD ,
                                                      DP1R1W_BE_7_DATA_WD ,
                                                      DP1R1W_BE_8_DATA_WD ,
                                                      DP1R1W_BE_9_DATA_WD ,
                                                      DP1R1W_BE_10_DATA_WD,
                                                      DP1R1W_BE_11_DATA_WD,
                                                      DP1R1W_BE_12_DATA_WD,
                                                      DP1R1W_BE_13_DATA_WD,
                                                      DP1R1W_BE_14_DATA_WD,
                                                      DP1R1W_BE_15_DATA_WD,
                                                      DP1R1W_BE_16_DATA_WD,
                                                      DP1R1W_BE_17_DATA_WD,
                                                      DP1R1W_BE_18_DATA_WD,
                                                      DP1R1W_BE_19_DATA_WD,
                                                      DP1R1W_BE_20_DATA_WD,
                                                      DP1R1W_BE_21_DATA_WD,
                                                      DP1R1W_BE_22_DATA_WD,
                                                      DP1R1W_BE_23_DATA_WD,
                                                      DP1R1W_BE_24_DATA_WD,
                                                      DP1R1W_BE_25_DATA_WD,
                                                      DP1R1W_BE_26_DATA_WD,
                                                      DP1R1W_BE_27_DATA_WD,
                                                      DP1R1W_BE_28_DATA_WD,
                                                      DP1R1W_BE_29_DATA_WD,
                                                      DP1R1W_BE_30_DATA_WD,
                                                      DP1R1W_BE_31_DATA_WD};

  parameter DP1R1W_BE_0_DATA_WD_START  = 0;
  parameter DP1R1W_BE_1_DATA_WD_START  = DP1R1W_BE_0_DATA_WD_START  + DP1R1W_BE_0_DATA_WD ;
  parameter DP1R1W_BE_2_DATA_WD_START  = DP1R1W_BE_1_DATA_WD_START  + DP1R1W_BE_1_DATA_WD ;
  parameter DP1R1W_BE_3_DATA_WD_START  = DP1R1W_BE_2_DATA_WD_START  + DP1R1W_BE_2_DATA_WD ;
  parameter DP1R1W_BE_4_DATA_WD_START  = DP1R1W_BE_3_DATA_WD_START  + DP1R1W_BE_3_DATA_WD ;
  parameter DP1R1W_BE_5_DATA_WD_START  = DP1R1W_BE_4_DATA_WD_START  + DP1R1W_BE_4_DATA_WD ;
  parameter DP1R1W_BE_6_DATA_WD_START  = DP1R1W_BE_5_DATA_WD_START  + DP1R1W_BE_5_DATA_WD ;
  parameter DP1R1W_BE_7_DATA_WD_START  = DP1R1W_BE_6_DATA_WD_START  + DP1R1W_BE_6_DATA_WD ;
  parameter DP1R1W_BE_8_DATA_WD_START  = DP1R1W_BE_7_DATA_WD_START  + DP1R1W_BE_7_DATA_WD ;
  parameter DP1R1W_BE_9_DATA_WD_START  = DP1R1W_BE_8_DATA_WD_START  + DP1R1W_BE_8_DATA_WD ;
  parameter DP1R1W_BE_10_DATA_WD_START = DP1R1W_BE_9_DATA_WD_START  + DP1R1W_BE_9_DATA_WD ;
  parameter DP1R1W_BE_11_DATA_WD_START = DP1R1W_BE_10_DATA_WD_START + DP1R1W_BE_10_DATA_WD;
  parameter DP1R1W_BE_12_DATA_WD_START = DP1R1W_BE_11_DATA_WD_START + DP1R1W_BE_11_DATA_WD;
  parameter DP1R1W_BE_13_DATA_WD_START = DP1R1W_BE_12_DATA_WD_START + DP1R1W_BE_12_DATA_WD;
  parameter DP1R1W_BE_14_DATA_WD_START = DP1R1W_BE_13_DATA_WD_START + DP1R1W_BE_13_DATA_WD;
  parameter DP1R1W_BE_15_DATA_WD_START = DP1R1W_BE_14_DATA_WD_START + DP1R1W_BE_14_DATA_WD;
  parameter DP1R1W_BE_16_DATA_WD_START = DP1R1W_BE_15_DATA_WD_START + DP1R1W_BE_15_DATA_WD;
  parameter DP1R1W_BE_17_DATA_WD_START = DP1R1W_BE_16_DATA_WD_START + DP1R1W_BE_16_DATA_WD;
  parameter DP1R1W_BE_18_DATA_WD_START = DP1R1W_BE_17_DATA_WD_START + DP1R1W_BE_17_DATA_WD;
  parameter DP1R1W_BE_19_DATA_WD_START = DP1R1W_BE_18_DATA_WD_START + DP1R1W_BE_18_DATA_WD;
  parameter DP1R1W_BE_20_DATA_WD_START = DP1R1W_BE_19_DATA_WD_START + DP1R1W_BE_19_DATA_WD;
  parameter DP1R1W_BE_21_DATA_WD_START = DP1R1W_BE_20_DATA_WD_START + DP1R1W_BE_20_DATA_WD;
  parameter DP1R1W_BE_22_DATA_WD_START = DP1R1W_BE_21_DATA_WD_START + DP1R1W_BE_21_DATA_WD;
  parameter DP1R1W_BE_23_DATA_WD_START = DP1R1W_BE_22_DATA_WD_START + DP1R1W_BE_22_DATA_WD;
  parameter DP1R1W_BE_24_DATA_WD_START = DP1R1W_BE_23_DATA_WD_START + DP1R1W_BE_23_DATA_WD;
  parameter DP1R1W_BE_25_DATA_WD_START = DP1R1W_BE_24_DATA_WD_START + DP1R1W_BE_24_DATA_WD;
  parameter DP1R1W_BE_26_DATA_WD_START = DP1R1W_BE_25_DATA_WD_START + DP1R1W_BE_25_DATA_WD;
  parameter DP1R1W_BE_27_DATA_WD_START = DP1R1W_BE_26_DATA_WD_START + DP1R1W_BE_26_DATA_WD;
  parameter DP1R1W_BE_28_DATA_WD_START = DP1R1W_BE_27_DATA_WD_START + DP1R1W_BE_27_DATA_WD;
  parameter DP1R1W_BE_29_DATA_WD_START = DP1R1W_BE_28_DATA_WD_START + DP1R1W_BE_28_DATA_WD;
  parameter DP1R1W_BE_30_DATA_WD_START = DP1R1W_BE_29_DATA_WD_START + DP1R1W_BE_29_DATA_WD;
  parameter DP1R1W_BE_31_DATA_WD_START = DP1R1W_BE_30_DATA_WD_START + DP1R1W_BE_30_DATA_WD;

  parameter [15:0] DP1R1W_BE_DATA_WD_START_ARRAY [0:31] = '{DP1R1W_BE_0_DATA_WD_START ,
                                                            DP1R1W_BE_1_DATA_WD_START ,
                                                            DP1R1W_BE_2_DATA_WD_START ,
                                                            DP1R1W_BE_3_DATA_WD_START ,
                                                            DP1R1W_BE_4_DATA_WD_START ,
                                                            DP1R1W_BE_5_DATA_WD_START ,
                                                            DP1R1W_BE_6_DATA_WD_START ,
                                                            DP1R1W_BE_7_DATA_WD_START ,
                                                            DP1R1W_BE_8_DATA_WD_START ,
                                                            DP1R1W_BE_9_DATA_WD_START ,
                                                            DP1R1W_BE_10_DATA_WD_START,
                                                            DP1R1W_BE_11_DATA_WD_START,
                                                            DP1R1W_BE_12_DATA_WD_START,
                                                            DP1R1W_BE_13_DATA_WD_START,
                                                            DP1R1W_BE_14_DATA_WD_START,
                                                            DP1R1W_BE_15_DATA_WD_START,
                                                            DP1R1W_BE_16_DATA_WD_START,
                                                            DP1R1W_BE_17_DATA_WD_START,
                                                            DP1R1W_BE_18_DATA_WD_START,
                                                            DP1R1W_BE_19_DATA_WD_START,
                                                            DP1R1W_BE_20_DATA_WD_START,
                                                            DP1R1W_BE_21_DATA_WD_START,
                                                            DP1R1W_BE_22_DATA_WD_START,
                                                            DP1R1W_BE_23_DATA_WD_START,
                                                            DP1R1W_BE_24_DATA_WD_START,
                                                            DP1R1W_BE_25_DATA_WD_START,
                                                            DP1R1W_BE_26_DATA_WD_START,
                                                            DP1R1W_BE_27_DATA_WD_START,
                                                            DP1R1W_BE_28_DATA_WD_START,
                                                            DP1R1W_BE_29_DATA_WD_START,
                                                            DP1R1W_BE_30_DATA_WD_START,
                                                            DP1R1W_BE_31_DATA_WD_START};

  // DP1R1W_BE DEPTH of RAM
  parameter DP1R1W_BE_DEPTH = DP1R1W_BE_0_DEPTH  +
                              DP1R1W_BE_1_DEPTH  +
                              DP1R1W_BE_2_DEPTH  +
                              DP1R1W_BE_3_DEPTH  +
                              DP1R1W_BE_4_DEPTH  +
                              DP1R1W_BE_5_DEPTH  +
                              DP1R1W_BE_6_DEPTH  +
                              DP1R1W_BE_7_DEPTH  +
                              DP1R1W_BE_8_DEPTH  +
                              DP1R1W_BE_9_DEPTH  +
                              DP1R1W_BE_10_DEPTH +
                              DP1R1W_BE_11_DEPTH +
                              DP1R1W_BE_12_DEPTH +
                              DP1R1W_BE_13_DEPTH +
                              DP1R1W_BE_14_DEPTH +
                              DP1R1W_BE_15_DEPTH +
                              DP1R1W_BE_16_DEPTH +
                              DP1R1W_BE_17_DEPTH +
                              DP1R1W_BE_18_DEPTH +
                              DP1R1W_BE_19_DEPTH +
                              DP1R1W_BE_20_DEPTH +
                              DP1R1W_BE_21_DEPTH +
                              DP1R1W_BE_22_DEPTH +
                              DP1R1W_BE_23_DEPTH +
                              DP1R1W_BE_24_DEPTH +
                              DP1R1W_BE_25_DEPTH +
                              DP1R1W_BE_26_DEPTH +
                              DP1R1W_BE_27_DEPTH +
                              DP1R1W_BE_28_DEPTH +
                              DP1R1W_BE_29_DEPTH +
                              DP1R1W_BE_30_DEPTH +
                              DP1R1W_BE_31_DEPTH;


  // DP2R2W_BE NAME (STRING)
  parameter string DP2R2W_BE_NAME [0:31] = '{DP2R2W_BE_0_NAME,
                                             DP2R2W_BE_1_NAME,
                                             DP2R2W_BE_2_NAME,
                                             DP2R2W_BE_3_NAME,
                                             DP2R2W_BE_4_NAME,
                                             DP2R2W_BE_5_NAME,
                                             DP2R2W_BE_6_NAME,
                                             DP2R2W_BE_7_NAME,
                                             DP2R2W_BE_8_NAME,
                                             DP2R2W_BE_9_NAME,
                                             DP2R2W_BE_10_NAME,
                                             DP2R2W_BE_11_NAME,
                                             DP2R2W_BE_12_NAME,
                                             DP2R2W_BE_13_NAME,
                                             DP2R2W_BE_14_NAME,
                                             DP2R2W_BE_15_NAME,
                                             DP2R2W_BE_16_NAME,
                                             DP2R2W_BE_17_NAME,
                                             DP2R2W_BE_18_NAME,
                                             DP2R2W_BE_19_NAME,
                                             DP2R2W_BE_20_NAME,
                                             DP2R2W_BE_21_NAME,
                                             DP2R2W_BE_22_NAME,
                                             DP2R2W_BE_23_NAME,
                                             DP2R2W_BE_24_NAME,
                                             DP2R2W_BE_25_NAME,
                                             DP2R2W_BE_26_NAME,
                                             DP2R2W_BE_27_NAME,
                                             DP2R2W_BE_28_NAME,
                                             DP2R2W_BE_29_NAME,
                                             DP2R2W_BE_30_NAME,
                                             DP2R2W_BE_31_NAME};

  // DP2R2W_BE ADDRESS WIDTH
  parameter DP2R2W_BE_ADDR_WD = DP2R2W_BE_0_ADDR_WD  +
                                DP2R2W_BE_1_ADDR_WD  +
                                DP2R2W_BE_2_ADDR_WD  +
                                DP2R2W_BE_3_ADDR_WD  +
                                DP2R2W_BE_4_ADDR_WD  +
                                DP2R2W_BE_5_ADDR_WD  +
                                DP2R2W_BE_6_ADDR_WD  +
                                DP2R2W_BE_7_ADDR_WD  +
                                DP2R2W_BE_8_ADDR_WD  +
                                DP2R2W_BE_9_ADDR_WD  +
                                DP2R2W_BE_10_ADDR_WD +
                                DP2R2W_BE_11_ADDR_WD +
                                DP2R2W_BE_12_ADDR_WD +
                                DP2R2W_BE_13_ADDR_WD +
                                DP2R2W_BE_14_ADDR_WD +
                                DP2R2W_BE_15_ADDR_WD +
                                DP2R2W_BE_16_ADDR_WD +
                                DP2R2W_BE_17_ADDR_WD +
                                DP2R2W_BE_18_ADDR_WD +
                                DP2R2W_BE_19_ADDR_WD +
                                DP2R2W_BE_20_ADDR_WD +
                                DP2R2W_BE_21_ADDR_WD +
                                DP2R2W_BE_22_ADDR_WD +
                                DP2R2W_BE_23_ADDR_WD +
                                DP2R2W_BE_24_ADDR_WD +
                                DP2R2W_BE_25_ADDR_WD +
                                DP2R2W_BE_26_ADDR_WD +
                                DP2R2W_BE_27_ADDR_WD +
                                DP2R2W_BE_28_ADDR_WD +
                                DP2R2W_BE_29_ADDR_WD +
                                DP2R2W_BE_30_ADDR_WD +
                                DP2R2W_BE_31_ADDR_WD;

  parameter [10:0] DP2R2W_BE_ADDR_WD_ARRAY [0:31] = '{DP2R2W_BE_0_ADDR_WD ,
                                                      DP2R2W_BE_1_ADDR_WD ,
                                                      DP2R2W_BE_2_ADDR_WD ,
                                                      DP2R2W_BE_3_ADDR_WD ,
                                                      DP2R2W_BE_4_ADDR_WD ,
                                                      DP2R2W_BE_5_ADDR_WD ,
                                                      DP2R2W_BE_6_ADDR_WD ,
                                                      DP2R2W_BE_7_ADDR_WD ,
                                                      DP2R2W_BE_8_ADDR_WD ,
                                                      DP2R2W_BE_9_ADDR_WD ,
                                                      DP2R2W_BE_10_ADDR_WD,
                                                      DP2R2W_BE_11_ADDR_WD,
                                                      DP2R2W_BE_12_ADDR_WD,
                                                      DP2R2W_BE_13_ADDR_WD,
                                                      DP2R2W_BE_14_ADDR_WD,
                                                      DP2R2W_BE_15_ADDR_WD,
                                                      DP2R2W_BE_16_ADDR_WD,
                                                      DP2R2W_BE_17_ADDR_WD,
                                                      DP2R2W_BE_18_ADDR_WD,
                                                      DP2R2W_BE_19_ADDR_WD,
                                                      DP2R2W_BE_20_ADDR_WD,
                                                      DP2R2W_BE_21_ADDR_WD,
                                                      DP2R2W_BE_22_ADDR_WD,
                                                      DP2R2W_BE_23_ADDR_WD,
                                                      DP2R2W_BE_24_ADDR_WD,
                                                      DP2R2W_BE_25_ADDR_WD,
                                                      DP2R2W_BE_26_ADDR_WD,
                                                      DP2R2W_BE_27_ADDR_WD,
                                                      DP2R2W_BE_28_ADDR_WD,
                                                      DP2R2W_BE_29_ADDR_WD,
                                                      DP2R2W_BE_30_ADDR_WD,
                                                      DP2R2W_BE_31_ADDR_WD};

  parameter DP2R2W_BE_0_ADDR_WD_START  = 0;
  parameter DP2R2W_BE_1_ADDR_WD_START  = DP2R2W_BE_0_ADDR_WD_START  + DP2R2W_BE_0_ADDR_WD ;
  parameter DP2R2W_BE_2_ADDR_WD_START  = DP2R2W_BE_1_ADDR_WD_START  + DP2R2W_BE_1_ADDR_WD ;
  parameter DP2R2W_BE_3_ADDR_WD_START  = DP2R2W_BE_2_ADDR_WD_START  + DP2R2W_BE_2_ADDR_WD ;
  parameter DP2R2W_BE_4_ADDR_WD_START  = DP2R2W_BE_3_ADDR_WD_START  + DP2R2W_BE_3_ADDR_WD ;
  parameter DP2R2W_BE_5_ADDR_WD_START  = DP2R2W_BE_4_ADDR_WD_START  + DP2R2W_BE_4_ADDR_WD ;
  parameter DP2R2W_BE_6_ADDR_WD_START  = DP2R2W_BE_5_ADDR_WD_START  + DP2R2W_BE_5_ADDR_WD ;
  parameter DP2R2W_BE_7_ADDR_WD_START  = DP2R2W_BE_6_ADDR_WD_START  + DP2R2W_BE_6_ADDR_WD ;
  parameter DP2R2W_BE_8_ADDR_WD_START  = DP2R2W_BE_7_ADDR_WD_START  + DP2R2W_BE_7_ADDR_WD ;
  parameter DP2R2W_BE_9_ADDR_WD_START  = DP2R2W_BE_8_ADDR_WD_START  + DP2R2W_BE_8_ADDR_WD ;
  parameter DP2R2W_BE_10_ADDR_WD_START = DP2R2W_BE_9_ADDR_WD_START  + DP2R2W_BE_9_ADDR_WD ;
  parameter DP2R2W_BE_11_ADDR_WD_START = DP2R2W_BE_10_ADDR_WD_START + DP2R2W_BE_10_ADDR_WD;
  parameter DP2R2W_BE_12_ADDR_WD_START = DP2R2W_BE_11_ADDR_WD_START + DP2R2W_BE_11_ADDR_WD;
  parameter DP2R2W_BE_13_ADDR_WD_START = DP2R2W_BE_12_ADDR_WD_START + DP2R2W_BE_12_ADDR_WD;
  parameter DP2R2W_BE_14_ADDR_WD_START = DP2R2W_BE_13_ADDR_WD_START + DP2R2W_BE_13_ADDR_WD;
  parameter DP2R2W_BE_15_ADDR_WD_START = DP2R2W_BE_14_ADDR_WD_START + DP2R2W_BE_14_ADDR_WD;
  parameter DP2R2W_BE_16_ADDR_WD_START = DP2R2W_BE_15_ADDR_WD_START + DP2R2W_BE_15_ADDR_WD;
  parameter DP2R2W_BE_17_ADDR_WD_START = DP2R2W_BE_16_ADDR_WD_START + DP2R2W_BE_16_ADDR_WD;
  parameter DP2R2W_BE_18_ADDR_WD_START = DP2R2W_BE_17_ADDR_WD_START + DP2R2W_BE_17_ADDR_WD;
  parameter DP2R2W_BE_19_ADDR_WD_START = DP2R2W_BE_18_ADDR_WD_START + DP2R2W_BE_18_ADDR_WD;
  parameter DP2R2W_BE_20_ADDR_WD_START = DP2R2W_BE_19_ADDR_WD_START + DP2R2W_BE_19_ADDR_WD;
  parameter DP2R2W_BE_21_ADDR_WD_START = DP2R2W_BE_20_ADDR_WD_START + DP2R2W_BE_20_ADDR_WD;
  parameter DP2R2W_BE_22_ADDR_WD_START = DP2R2W_BE_21_ADDR_WD_START + DP2R2W_BE_21_ADDR_WD;
  parameter DP2R2W_BE_23_ADDR_WD_START = DP2R2W_BE_22_ADDR_WD_START + DP2R2W_BE_22_ADDR_WD;
  parameter DP2R2W_BE_24_ADDR_WD_START = DP2R2W_BE_23_ADDR_WD_START + DP2R2W_BE_23_ADDR_WD;
  parameter DP2R2W_BE_25_ADDR_WD_START = DP2R2W_BE_24_ADDR_WD_START + DP2R2W_BE_24_ADDR_WD;
  parameter DP2R2W_BE_26_ADDR_WD_START = DP2R2W_BE_25_ADDR_WD_START + DP2R2W_BE_25_ADDR_WD;
  parameter DP2R2W_BE_27_ADDR_WD_START = DP2R2W_BE_26_ADDR_WD_START + DP2R2W_BE_26_ADDR_WD;
  parameter DP2R2W_BE_28_ADDR_WD_START = DP2R2W_BE_27_ADDR_WD_START + DP2R2W_BE_27_ADDR_WD;
  parameter DP2R2W_BE_29_ADDR_WD_START = DP2R2W_BE_28_ADDR_WD_START + DP2R2W_BE_28_ADDR_WD;
  parameter DP2R2W_BE_30_ADDR_WD_START = DP2R2W_BE_29_ADDR_WD_START + DP2R2W_BE_29_ADDR_WD;
  parameter DP2R2W_BE_31_ADDR_WD_START = DP2R2W_BE_30_ADDR_WD_START + DP2R2W_BE_30_ADDR_WD;

  parameter [10:0] DP2R2W_BE_ADDR_WD_START_ARRAY [0:31] = '{DP2R2W_BE_0_ADDR_WD_START ,
                                                            DP2R2W_BE_1_ADDR_WD_START ,
                                                            DP2R2W_BE_2_ADDR_WD_START ,
                                                            DP2R2W_BE_3_ADDR_WD_START ,
                                                            DP2R2W_BE_4_ADDR_WD_START ,
                                                            DP2R2W_BE_5_ADDR_WD_START ,
                                                            DP2R2W_BE_6_ADDR_WD_START ,
                                                            DP2R2W_BE_7_ADDR_WD_START ,
                                                            DP2R2W_BE_8_ADDR_WD_START ,
                                                            DP2R2W_BE_9_ADDR_WD_START ,
                                                            DP2R2W_BE_10_ADDR_WD_START,
                                                            DP2R2W_BE_11_ADDR_WD_START,
                                                            DP2R2W_BE_12_ADDR_WD_START,
                                                            DP2R2W_BE_13_ADDR_WD_START,
                                                            DP2R2W_BE_14_ADDR_WD_START,
                                                            DP2R2W_BE_15_ADDR_WD_START,
                                                            DP2R2W_BE_16_ADDR_WD_START,
                                                            DP2R2W_BE_17_ADDR_WD_START,
                                                            DP2R2W_BE_18_ADDR_WD_START,
                                                            DP2R2W_BE_19_ADDR_WD_START,
                                                            DP2R2W_BE_20_ADDR_WD_START,
                                                            DP2R2W_BE_21_ADDR_WD_START,
                                                            DP2R2W_BE_22_ADDR_WD_START,
                                                            DP2R2W_BE_23_ADDR_WD_START,
                                                            DP2R2W_BE_24_ADDR_WD_START,
                                                            DP2R2W_BE_25_ADDR_WD_START,
                                                            DP2R2W_BE_26_ADDR_WD_START,
                                                            DP2R2W_BE_27_ADDR_WD_START,
                                                            DP2R2W_BE_28_ADDR_WD_START,
                                                            DP2R2W_BE_29_ADDR_WD_START,
                                                            DP2R2W_BE_30_ADDR_WD_START,
                                                            DP2R2W_BE_31_ADDR_WD_START};

  // DP2R2W_BE DATA WIDTH
  parameter DP2R2W_BE_DATA_WD = DP2R2W_BE_0_DATA_WD  +
                                DP2R2W_BE_1_DATA_WD  +
                                DP2R2W_BE_2_DATA_WD  +
                                DP2R2W_BE_3_DATA_WD  +
                                DP2R2W_BE_4_DATA_WD  +
                                DP2R2W_BE_5_DATA_WD  +
                                DP2R2W_BE_6_DATA_WD  +
                                DP2R2W_BE_7_DATA_WD  +
                                DP2R2W_BE_8_DATA_WD  +
                                DP2R2W_BE_9_DATA_WD  +
                                DP2R2W_BE_10_DATA_WD +
                                DP2R2W_BE_11_DATA_WD +
                                DP2R2W_BE_12_DATA_WD +
                                DP2R2W_BE_13_DATA_WD +
                                DP2R2W_BE_14_DATA_WD +
                                DP2R2W_BE_15_DATA_WD +
                                DP2R2W_BE_16_DATA_WD +
                                DP2R2W_BE_17_DATA_WD +
                                DP2R2W_BE_18_DATA_WD +
                                DP2R2W_BE_19_DATA_WD +
                                DP2R2W_BE_20_DATA_WD +
                                DP2R2W_BE_21_DATA_WD +
                                DP2R2W_BE_22_DATA_WD +
                                DP2R2W_BE_23_DATA_WD +
                                DP2R2W_BE_24_DATA_WD +
                                DP2R2W_BE_25_DATA_WD +
                                DP2R2W_BE_26_DATA_WD +
                                DP2R2W_BE_27_DATA_WD +
                                DP2R2W_BE_28_DATA_WD +
                                DP2R2W_BE_29_DATA_WD +
                                DP2R2W_BE_30_DATA_WD +
                                DP2R2W_BE_31_DATA_WD;

  parameter [15:0] DP2R2W_BE_DATA_WD_ARRAY [0:31] = '{DP2R2W_BE_0_DATA_WD ,
                                                      DP2R2W_BE_1_DATA_WD ,
                                                      DP2R2W_BE_2_DATA_WD ,
                                                      DP2R2W_BE_3_DATA_WD ,
                                                      DP2R2W_BE_4_DATA_WD ,
                                                      DP2R2W_BE_5_DATA_WD ,
                                                      DP2R2W_BE_6_DATA_WD ,
                                                      DP2R2W_BE_7_DATA_WD ,
                                                      DP2R2W_BE_8_DATA_WD ,
                                                      DP2R2W_BE_9_DATA_WD ,
                                                      DP2R2W_BE_10_DATA_WD,
                                                      DP2R2W_BE_11_DATA_WD,
                                                      DP2R2W_BE_12_DATA_WD,
                                                      DP2R2W_BE_13_DATA_WD,
                                                      DP2R2W_BE_14_DATA_WD,
                                                      DP2R2W_BE_15_DATA_WD,
                                                      DP2R2W_BE_16_DATA_WD,
                                                      DP2R2W_BE_17_DATA_WD,
                                                      DP2R2W_BE_18_DATA_WD,
                                                      DP2R2W_BE_19_DATA_WD,
                                                      DP2R2W_BE_20_DATA_WD,
                                                      DP2R2W_BE_21_DATA_WD,
                                                      DP2R2W_BE_22_DATA_WD,
                                                      DP2R2W_BE_23_DATA_WD,
                                                      DP2R2W_BE_24_DATA_WD,
                                                      DP2R2W_BE_25_DATA_WD,
                                                      DP2R2W_BE_26_DATA_WD,
                                                      DP2R2W_BE_27_DATA_WD,
                                                      DP2R2W_BE_28_DATA_WD,
                                                      DP2R2W_BE_29_DATA_WD,
                                                      DP2R2W_BE_30_DATA_WD,
                                                      DP2R2W_BE_31_DATA_WD};

  parameter DP2R2W_BE_0_DATA_WD_START  = 0;
  parameter DP2R2W_BE_1_DATA_WD_START  = DP2R2W_BE_0_DATA_WD_START  + DP2R2W_BE_0_DATA_WD ;
  parameter DP2R2W_BE_2_DATA_WD_START  = DP2R2W_BE_1_DATA_WD_START  + DP2R2W_BE_1_DATA_WD ;
  parameter DP2R2W_BE_3_DATA_WD_START  = DP2R2W_BE_2_DATA_WD_START  + DP2R2W_BE_2_DATA_WD ;
  parameter DP2R2W_BE_4_DATA_WD_START  = DP2R2W_BE_3_DATA_WD_START  + DP2R2W_BE_3_DATA_WD ;
  parameter DP2R2W_BE_5_DATA_WD_START  = DP2R2W_BE_4_DATA_WD_START  + DP2R2W_BE_4_DATA_WD ;
  parameter DP2R2W_BE_6_DATA_WD_START  = DP2R2W_BE_5_DATA_WD_START  + DP2R2W_BE_5_DATA_WD ;
  parameter DP2R2W_BE_7_DATA_WD_START  = DP2R2W_BE_6_DATA_WD_START  + DP2R2W_BE_6_DATA_WD ;
  parameter DP2R2W_BE_8_DATA_WD_START  = DP2R2W_BE_7_DATA_WD_START  + DP2R2W_BE_7_DATA_WD ;
  parameter DP2R2W_BE_9_DATA_WD_START  = DP2R2W_BE_8_DATA_WD_START  + DP2R2W_BE_8_DATA_WD ;
  parameter DP2R2W_BE_10_DATA_WD_START = DP2R2W_BE_9_DATA_WD_START  + DP2R2W_BE_9_DATA_WD ;
  parameter DP2R2W_BE_11_DATA_WD_START = DP2R2W_BE_10_DATA_WD_START + DP2R2W_BE_10_DATA_WD;
  parameter DP2R2W_BE_12_DATA_WD_START = DP2R2W_BE_11_DATA_WD_START + DP2R2W_BE_11_DATA_WD;
  parameter DP2R2W_BE_13_DATA_WD_START = DP2R2W_BE_12_DATA_WD_START + DP2R2W_BE_12_DATA_WD;
  parameter DP2R2W_BE_14_DATA_WD_START = DP2R2W_BE_13_DATA_WD_START + DP2R2W_BE_13_DATA_WD;
  parameter DP2R2W_BE_15_DATA_WD_START = DP2R2W_BE_14_DATA_WD_START + DP2R2W_BE_14_DATA_WD;
  parameter DP2R2W_BE_16_DATA_WD_START = DP2R2W_BE_15_DATA_WD_START + DP2R2W_BE_15_DATA_WD;
  parameter DP2R2W_BE_17_DATA_WD_START = DP2R2W_BE_16_DATA_WD_START + DP2R2W_BE_16_DATA_WD;
  parameter DP2R2W_BE_18_DATA_WD_START = DP2R2W_BE_17_DATA_WD_START + DP2R2W_BE_17_DATA_WD;
  parameter DP2R2W_BE_19_DATA_WD_START = DP2R2W_BE_18_DATA_WD_START + DP2R2W_BE_18_DATA_WD;
  parameter DP2R2W_BE_20_DATA_WD_START = DP2R2W_BE_19_DATA_WD_START + DP2R2W_BE_19_DATA_WD;
  parameter DP2R2W_BE_21_DATA_WD_START = DP2R2W_BE_20_DATA_WD_START + DP2R2W_BE_20_DATA_WD;
  parameter DP2R2W_BE_22_DATA_WD_START = DP2R2W_BE_21_DATA_WD_START + DP2R2W_BE_21_DATA_WD;
  parameter DP2R2W_BE_23_DATA_WD_START = DP2R2W_BE_22_DATA_WD_START + DP2R2W_BE_22_DATA_WD;
  parameter DP2R2W_BE_24_DATA_WD_START = DP2R2W_BE_23_DATA_WD_START + DP2R2W_BE_23_DATA_WD;
  parameter DP2R2W_BE_25_DATA_WD_START = DP2R2W_BE_24_DATA_WD_START + DP2R2W_BE_24_DATA_WD;
  parameter DP2R2W_BE_26_DATA_WD_START = DP2R2W_BE_25_DATA_WD_START + DP2R2W_BE_25_DATA_WD;
  parameter DP2R2W_BE_27_DATA_WD_START = DP2R2W_BE_26_DATA_WD_START + DP2R2W_BE_26_DATA_WD;
  parameter DP2R2W_BE_28_DATA_WD_START = DP2R2W_BE_27_DATA_WD_START + DP2R2W_BE_27_DATA_WD;
  parameter DP2R2W_BE_29_DATA_WD_START = DP2R2W_BE_28_DATA_WD_START + DP2R2W_BE_28_DATA_WD;
  parameter DP2R2W_BE_30_DATA_WD_START = DP2R2W_BE_29_DATA_WD_START + DP2R2W_BE_29_DATA_WD;
  parameter DP2R2W_BE_31_DATA_WD_START = DP2R2W_BE_30_DATA_WD_START + DP2R2W_BE_30_DATA_WD;

  parameter [15:0] DP2R2W_BE_DATA_WD_START_ARRAY [0:31] = '{DP2R2W_BE_0_DATA_WD_START ,
                                                            DP2R2W_BE_1_DATA_WD_START ,
                                                            DP2R2W_BE_2_DATA_WD_START ,
                                                            DP2R2W_BE_3_DATA_WD_START ,
                                                            DP2R2W_BE_4_DATA_WD_START ,
                                                            DP2R2W_BE_5_DATA_WD_START ,
                                                            DP2R2W_BE_6_DATA_WD_START ,
                                                            DP2R2W_BE_7_DATA_WD_START ,
                                                            DP2R2W_BE_8_DATA_WD_START ,
                                                            DP2R2W_BE_9_DATA_WD_START ,
                                                            DP2R2W_BE_10_DATA_WD_START,
                                                            DP2R2W_BE_11_DATA_WD_START,
                                                            DP2R2W_BE_12_DATA_WD_START,
                                                            DP2R2W_BE_13_DATA_WD_START,
                                                            DP2R2W_BE_14_DATA_WD_START,
                                                            DP2R2W_BE_15_DATA_WD_START,
                                                            DP2R2W_BE_16_DATA_WD_START,
                                                            DP2R2W_BE_17_DATA_WD_START,
                                                            DP2R2W_BE_18_DATA_WD_START,
                                                            DP2R2W_BE_19_DATA_WD_START,
                                                            DP2R2W_BE_20_DATA_WD_START,
                                                            DP2R2W_BE_21_DATA_WD_START,
                                                            DP2R2W_BE_22_DATA_WD_START,
                                                            DP2R2W_BE_23_DATA_WD_START,
                                                            DP2R2W_BE_24_DATA_WD_START,
                                                            DP2R2W_BE_25_DATA_WD_START,
                                                            DP2R2W_BE_26_DATA_WD_START,
                                                            DP2R2W_BE_27_DATA_WD_START,
                                                            DP2R2W_BE_28_DATA_WD_START,
                                                            DP2R2W_BE_29_DATA_WD_START,
                                                            DP2R2W_BE_30_DATA_WD_START,
                                                            DP2R2W_BE_31_DATA_WD_START};

  // DP2R2W_BE DEPTH of RAM
  parameter DP2R2W_BE_DEPTH = DP2R2W_BE_0_DEPTH  +
                              DP2R2W_BE_1_DEPTH  +
                              DP2R2W_BE_2_DEPTH  +
                              DP2R2W_BE_3_DEPTH  +
                              DP2R2W_BE_4_DEPTH  +
                              DP2R2W_BE_5_DEPTH  +
                              DP2R2W_BE_6_DEPTH  +
                              DP2R2W_BE_7_DEPTH  +
                              DP2R2W_BE_8_DEPTH  +
                              DP2R2W_BE_9_DEPTH  +
                              DP2R2W_BE_10_DEPTH +
                              DP2R2W_BE_11_DEPTH +
                              DP2R2W_BE_12_DEPTH +
                              DP2R2W_BE_13_DEPTH +
                              DP2R2W_BE_14_DEPTH +
                              DP2R2W_BE_15_DEPTH +
                              DP2R2W_BE_16_DEPTH +
                              DP2R2W_BE_17_DEPTH +
                              DP2R2W_BE_18_DEPTH +
                              DP2R2W_BE_19_DEPTH +
                              DP2R2W_BE_20_DEPTH +
                              DP2R2W_BE_21_DEPTH +
                              DP2R2W_BE_22_DEPTH +
                              DP2R2W_BE_23_DEPTH +
                              DP2R2W_BE_24_DEPTH +
                              DP2R2W_BE_25_DEPTH +
                              DP2R2W_BE_26_DEPTH +
                              DP2R2W_BE_27_DEPTH +
                              DP2R2W_BE_28_DEPTH +
                              DP2R2W_BE_29_DEPTH +
                              DP2R2W_BE_30_DEPTH +
                              DP2R2W_BE_31_DEPTH;


  // RF_BE NAME (STRING)
  parameter string RF_BE_NAME [0:31] = '{RF_BE_0_NAME,
                                         RF_BE_1_NAME,
                                         RF_BE_2_NAME,
                                         RF_BE_3_NAME,
                                         RF_BE_4_NAME,
                                         RF_BE_5_NAME,
                                         RF_BE_6_NAME,
                                         RF_BE_7_NAME,
                                         RF_BE_8_NAME,
                                         RF_BE_9_NAME,
                                         RF_BE_10_NAME,
                                         RF_BE_11_NAME,
                                         RF_BE_12_NAME,
                                         RF_BE_13_NAME,
                                         RF_BE_14_NAME,
                                         RF_BE_15_NAME,
                                         RF_BE_16_NAME,
                                         RF_BE_17_NAME,
                                         RF_BE_18_NAME,
                                         RF_BE_19_NAME,
                                         RF_BE_20_NAME,
                                         RF_BE_21_NAME,
                                         RF_BE_22_NAME,
                                         RF_BE_23_NAME,
                                         RF_BE_24_NAME,
                                         RF_BE_25_NAME,
                                         RF_BE_26_NAME,
                                         RF_BE_27_NAME,
                                         RF_BE_28_NAME,
                                         RF_BE_29_NAME,
                                         RF_BE_30_NAME,
                                         RF_BE_31_NAME};

  // RF_BE ADDRESS WIDTH
  parameter RF_BE_ADDR_WD = RF_BE_0_ADDR_WD  +
                            RF_BE_1_ADDR_WD  +
                            RF_BE_2_ADDR_WD  +
                            RF_BE_3_ADDR_WD  +
                            RF_BE_4_ADDR_WD  +
                            RF_BE_5_ADDR_WD  +
                            RF_BE_6_ADDR_WD  +
                            RF_BE_7_ADDR_WD  +
                            RF_BE_8_ADDR_WD  +
                            RF_BE_9_ADDR_WD  +
                            RF_BE_10_ADDR_WD +
                            RF_BE_11_ADDR_WD +
                            RF_BE_12_ADDR_WD +
                            RF_BE_13_ADDR_WD +
                            RF_BE_14_ADDR_WD +
                            RF_BE_15_ADDR_WD +
                            RF_BE_16_ADDR_WD +
                            RF_BE_17_ADDR_WD +
                            RF_BE_18_ADDR_WD +
                            RF_BE_19_ADDR_WD +
                            RF_BE_20_ADDR_WD +
                            RF_BE_21_ADDR_WD +
                            RF_BE_22_ADDR_WD +
                            RF_BE_23_ADDR_WD +
                            RF_BE_24_ADDR_WD +
                            RF_BE_25_ADDR_WD +
                            RF_BE_26_ADDR_WD +
                            RF_BE_27_ADDR_WD +
                            RF_BE_28_ADDR_WD +
                            RF_BE_29_ADDR_WD +
                            RF_BE_30_ADDR_WD +
                            RF_BE_31_ADDR_WD;

  parameter [10:0] RF_BE_ADDR_WD_ARRAY [0:31] = '{RF_BE_0_ADDR_WD ,
                                                  RF_BE_1_ADDR_WD ,
                                                  RF_BE_2_ADDR_WD ,
                                                  RF_BE_3_ADDR_WD ,
                                                  RF_BE_4_ADDR_WD ,
                                                  RF_BE_5_ADDR_WD ,
                                                  RF_BE_6_ADDR_WD ,
                                                  RF_BE_7_ADDR_WD ,
                                                  RF_BE_8_ADDR_WD ,
                                                  RF_BE_9_ADDR_WD ,
                                                  RF_BE_10_ADDR_WD,
                                                  RF_BE_11_ADDR_WD,
                                                  RF_BE_12_ADDR_WD,
                                                  RF_BE_13_ADDR_WD,
                                                  RF_BE_14_ADDR_WD,
                                                  RF_BE_15_ADDR_WD,
                                                  RF_BE_16_ADDR_WD,
                                                  RF_BE_17_ADDR_WD,
                                                  RF_BE_18_ADDR_WD,
                                                  RF_BE_19_ADDR_WD,
                                                  RF_BE_20_ADDR_WD,
                                                  RF_BE_21_ADDR_WD,
                                                  RF_BE_22_ADDR_WD,
                                                  RF_BE_23_ADDR_WD,
                                                  RF_BE_24_ADDR_WD,
                                                  RF_BE_25_ADDR_WD,
                                                  RF_BE_26_ADDR_WD,
                                                  RF_BE_27_ADDR_WD,
                                                  RF_BE_28_ADDR_WD,
                                                  RF_BE_29_ADDR_WD,
                                                  RF_BE_30_ADDR_WD,
                                                  RF_BE_31_ADDR_WD};

  parameter RF_BE_0_ADDR_WD_START  = 0;
  parameter RF_BE_1_ADDR_WD_START  = RF_BE_0_ADDR_WD_START  + RF_BE_0_ADDR_WD ;
  parameter RF_BE_2_ADDR_WD_START  = RF_BE_1_ADDR_WD_START  + RF_BE_1_ADDR_WD ;
  parameter RF_BE_3_ADDR_WD_START  = RF_BE_2_ADDR_WD_START  + RF_BE_2_ADDR_WD ;
  parameter RF_BE_4_ADDR_WD_START  = RF_BE_3_ADDR_WD_START  + RF_BE_3_ADDR_WD ;
  parameter RF_BE_5_ADDR_WD_START  = RF_BE_4_ADDR_WD_START  + RF_BE_4_ADDR_WD ;
  parameter RF_BE_6_ADDR_WD_START  = RF_BE_5_ADDR_WD_START  + RF_BE_5_ADDR_WD ;
  parameter RF_BE_7_ADDR_WD_START  = RF_BE_6_ADDR_WD_START  + RF_BE_6_ADDR_WD ;
  parameter RF_BE_8_ADDR_WD_START  = RF_BE_7_ADDR_WD_START  + RF_BE_7_ADDR_WD ;
  parameter RF_BE_9_ADDR_WD_START  = RF_BE_8_ADDR_WD_START  + RF_BE_8_ADDR_WD ;
  parameter RF_BE_10_ADDR_WD_START = RF_BE_9_ADDR_WD_START  + RF_BE_9_ADDR_WD ;
  parameter RF_BE_11_ADDR_WD_START = RF_BE_10_ADDR_WD_START + RF_BE_10_ADDR_WD;
  parameter RF_BE_12_ADDR_WD_START = RF_BE_11_ADDR_WD_START + RF_BE_11_ADDR_WD;
  parameter RF_BE_13_ADDR_WD_START = RF_BE_12_ADDR_WD_START + RF_BE_12_ADDR_WD;
  parameter RF_BE_14_ADDR_WD_START = RF_BE_13_ADDR_WD_START + RF_BE_13_ADDR_WD;
  parameter RF_BE_15_ADDR_WD_START = RF_BE_14_ADDR_WD_START + RF_BE_14_ADDR_WD;
  parameter RF_BE_16_ADDR_WD_START = RF_BE_15_ADDR_WD_START + RF_BE_15_ADDR_WD;
  parameter RF_BE_17_ADDR_WD_START = RF_BE_16_ADDR_WD_START + RF_BE_16_ADDR_WD;
  parameter RF_BE_18_ADDR_WD_START = RF_BE_17_ADDR_WD_START + RF_BE_17_ADDR_WD;
  parameter RF_BE_19_ADDR_WD_START = RF_BE_18_ADDR_WD_START + RF_BE_18_ADDR_WD;
  parameter RF_BE_20_ADDR_WD_START = RF_BE_19_ADDR_WD_START + RF_BE_19_ADDR_WD;
  parameter RF_BE_21_ADDR_WD_START = RF_BE_20_ADDR_WD_START + RF_BE_20_ADDR_WD;
  parameter RF_BE_22_ADDR_WD_START = RF_BE_21_ADDR_WD_START + RF_BE_21_ADDR_WD;
  parameter RF_BE_23_ADDR_WD_START = RF_BE_22_ADDR_WD_START + RF_BE_22_ADDR_WD;
  parameter RF_BE_24_ADDR_WD_START = RF_BE_23_ADDR_WD_START + RF_BE_23_ADDR_WD;
  parameter RF_BE_25_ADDR_WD_START = RF_BE_24_ADDR_WD_START + RF_BE_24_ADDR_WD;
  parameter RF_BE_26_ADDR_WD_START = RF_BE_25_ADDR_WD_START + RF_BE_25_ADDR_WD;
  parameter RF_BE_27_ADDR_WD_START = RF_BE_26_ADDR_WD_START + RF_BE_26_ADDR_WD;
  parameter RF_BE_28_ADDR_WD_START = RF_BE_27_ADDR_WD_START + RF_BE_27_ADDR_WD;
  parameter RF_BE_29_ADDR_WD_START = RF_BE_28_ADDR_WD_START + RF_BE_28_ADDR_WD;
  parameter RF_BE_30_ADDR_WD_START = RF_BE_29_ADDR_WD_START + RF_BE_29_ADDR_WD;
  parameter RF_BE_31_ADDR_WD_START = RF_BE_30_ADDR_WD_START + RF_BE_30_ADDR_WD;

  parameter [10:0] RF_BE_ADDR_WD_START_ARRAY [0:31] = '{RF_BE_0_ADDR_WD_START ,
                                                        RF_BE_1_ADDR_WD_START ,
                                                        RF_BE_2_ADDR_WD_START ,
                                                        RF_BE_3_ADDR_WD_START ,
                                                        RF_BE_4_ADDR_WD_START ,
                                                        RF_BE_5_ADDR_WD_START ,
                                                        RF_BE_6_ADDR_WD_START ,
                                                        RF_BE_7_ADDR_WD_START ,
                                                        RF_BE_8_ADDR_WD_START ,
                                                        RF_BE_9_ADDR_WD_START ,
                                                        RF_BE_10_ADDR_WD_START,
                                                        RF_BE_11_ADDR_WD_START,
                                                        RF_BE_12_ADDR_WD_START,
                                                        RF_BE_13_ADDR_WD_START,
                                                        RF_BE_14_ADDR_WD_START,
                                                        RF_BE_15_ADDR_WD_START,
                                                        RF_BE_16_ADDR_WD_START,
                                                        RF_BE_17_ADDR_WD_START,
                                                        RF_BE_18_ADDR_WD_START,
                                                        RF_BE_19_ADDR_WD_START,
                                                        RF_BE_20_ADDR_WD_START,
                                                        RF_BE_21_ADDR_WD_START,
                                                        RF_BE_22_ADDR_WD_START,
                                                        RF_BE_23_ADDR_WD_START,
                                                        RF_BE_24_ADDR_WD_START,
                                                        RF_BE_25_ADDR_WD_START,
                                                        RF_BE_26_ADDR_WD_START,
                                                        RF_BE_27_ADDR_WD_START,
                                                        RF_BE_28_ADDR_WD_START,
                                                        RF_BE_29_ADDR_WD_START,
                                                        RF_BE_30_ADDR_WD_START,
                                                        RF_BE_31_ADDR_WD_START};

  // RF_BE DATA WIDTH
  parameter RF_BE_DATA_WD = RF_BE_0_DATA_WD  +
                            RF_BE_1_DATA_WD  +
                            RF_BE_2_DATA_WD  +
                            RF_BE_3_DATA_WD  +
                            RF_BE_4_DATA_WD  +
                            RF_BE_5_DATA_WD  +
                            RF_BE_6_DATA_WD  +
                            RF_BE_7_DATA_WD  +
                            RF_BE_8_DATA_WD  +
                            RF_BE_9_DATA_WD  +
                            RF_BE_10_DATA_WD +
                            RF_BE_11_DATA_WD +
                            RF_BE_12_DATA_WD +
                            RF_BE_13_DATA_WD +
                            RF_BE_14_DATA_WD +
                            RF_BE_15_DATA_WD +
                            RF_BE_16_DATA_WD +
                            RF_BE_17_DATA_WD +
                            RF_BE_18_DATA_WD +
                            RF_BE_19_DATA_WD +
                            RF_BE_20_DATA_WD +
                            RF_BE_21_DATA_WD +
                            RF_BE_22_DATA_WD +
                            RF_BE_23_DATA_WD +
                            RF_BE_24_DATA_WD +
                            RF_BE_25_DATA_WD +
                            RF_BE_26_DATA_WD +
                            RF_BE_27_DATA_WD +
                            RF_BE_28_DATA_WD +
                            RF_BE_29_DATA_WD +
                            RF_BE_30_DATA_WD +
                            RF_BE_31_DATA_WD;

  parameter [15:0] RF__BEDATA_WD_ARRAY [0:31] = '{RF_BE_0_DATA_WD ,
                                                  RF_BE_1_DATA_WD ,
                                                  RF_BE_2_DATA_WD ,
                                                  RF_BE_3_DATA_WD ,
                                                  RF_BE_4_DATA_WD ,
                                                  RF_BE_5_DATA_WD ,
                                                  RF_BE_6_DATA_WD ,
                                                  RF_BE_7_DATA_WD ,
                                                  RF_BE_8_DATA_WD ,
                                                  RF_BE_9_DATA_WD ,
                                                  RF_BE_10_DATA_WD,
                                                  RF_BE_11_DATA_WD,
                                                  RF_BE_12_DATA_WD,
                                                  RF_BE_13_DATA_WD,
                                                  RF_BE_14_DATA_WD,
                                                  RF_BE_15_DATA_WD,
                                                  RF_BE_16_DATA_WD,
                                                  RF_BE_17_DATA_WD,
                                                  RF_BE_18_DATA_WD,
                                                  RF_BE_19_DATA_WD,
                                                  RF_BE_20_DATA_WD,
                                                  RF_BE_21_DATA_WD,
                                                  RF_BE_22_DATA_WD,
                                                  RF_BE_23_DATA_WD,
                                                  RF_BE_24_DATA_WD,
                                                  RF_BE_25_DATA_WD,
                                                  RF_BE_26_DATA_WD,
                                                  RF_BE_27_DATA_WD,
                                                  RF_BE_28_DATA_WD,
                                                  RF_BE_29_DATA_WD,
                                                  RF_BE_30_DATA_WD,
                                                  RF_BE_31_DATA_WD};

  parameter RF_BE_0_DATA_WD_START  = 0;
  parameter RF_BE_1_DATA_WD_START  = RF_BE_0_DATA_WD_START  + RF_BE_0_DATA_WD ;
  parameter RF_BE_2_DATA_WD_START  = RF_BE_1_DATA_WD_START  + RF_BE_1_DATA_WD ;
  parameter RF_BE_3_DATA_WD_START  = RF_BE_2_DATA_WD_START  + RF_BE_2_DATA_WD ;
  parameter RF_BE_4_DATA_WD_START  = RF_BE_3_DATA_WD_START  + RF_BE_3_DATA_WD ;
  parameter RF_BE_5_DATA_WD_START  = RF_BE_4_DATA_WD_START  + RF_BE_4_DATA_WD ;
  parameter RF_BE_6_DATA_WD_START  = RF_BE_5_DATA_WD_START  + RF_BE_5_DATA_WD ;
  parameter RF_BE_7_DATA_WD_START  = RF_BE_6_DATA_WD_START  + RF_BE_6_DATA_WD ;
  parameter RF_BE_8_DATA_WD_START  = RF_BE_7_DATA_WD_START  + RF_BE_7_DATA_WD ;
  parameter RF_BE_9_DATA_WD_START  = RF_BE_8_DATA_WD_START  + RF_BE_8_DATA_WD ;
  parameter RF_BE_10_DATA_WD_START = RF_BE_9_DATA_WD_START  + RF_BE_9_DATA_WD ;
  parameter RF_BE_11_DATA_WD_START = RF_BE_10_DATA_WD_START + RF_BE_10_DATA_WD;
  parameter RF_BE_12_DATA_WD_START = RF_BE_11_DATA_WD_START + RF_BE_11_DATA_WD;
  parameter RF_BE_13_DATA_WD_START = RF_BE_12_DATA_WD_START + RF_BE_12_DATA_WD;
  parameter RF_BE_14_DATA_WD_START = RF_BE_13_DATA_WD_START + RF_BE_13_DATA_WD;
  parameter RF_BE_15_DATA_WD_START = RF_BE_14_DATA_WD_START + RF_BE_14_DATA_WD;
  parameter RF_BE_16_DATA_WD_START = RF_BE_15_DATA_WD_START + RF_BE_15_DATA_WD;
  parameter RF_BE_17_DATA_WD_START = RF_BE_16_DATA_WD_START + RF_BE_16_DATA_WD;
  parameter RF_BE_18_DATA_WD_START = RF_BE_17_DATA_WD_START + RF_BE_17_DATA_WD;
  parameter RF_BE_19_DATA_WD_START = RF_BE_18_DATA_WD_START + RF_BE_18_DATA_WD;
  parameter RF_BE_20_DATA_WD_START = RF_BE_19_DATA_WD_START + RF_BE_19_DATA_WD;
  parameter RF_BE_21_DATA_WD_START = RF_BE_20_DATA_WD_START + RF_BE_20_DATA_WD;
  parameter RF_BE_22_DATA_WD_START = RF_BE_21_DATA_WD_START + RF_BE_21_DATA_WD;
  parameter RF_BE_23_DATA_WD_START = RF_BE_22_DATA_WD_START + RF_BE_22_DATA_WD;
  parameter RF_BE_24_DATA_WD_START = RF_BE_23_DATA_WD_START + RF_BE_23_DATA_WD;
  parameter RF_BE_25_DATA_WD_START = RF_BE_24_DATA_WD_START + RF_BE_24_DATA_WD;
  parameter RF_BE_26_DATA_WD_START = RF_BE_25_DATA_WD_START + RF_BE_25_DATA_WD;
  parameter RF_BE_27_DATA_WD_START = RF_BE_26_DATA_WD_START + RF_BE_26_DATA_WD;
  parameter RF_BE_28_DATA_WD_START = RF_BE_27_DATA_WD_START + RF_BE_27_DATA_WD;
  parameter RF_BE_29_DATA_WD_START = RF_BE_28_DATA_WD_START + RF_BE_28_DATA_WD;
  parameter RF_BE_30_DATA_WD_START = RF_BE_29_DATA_WD_START + RF_BE_29_DATA_WD;
  parameter RF_BE_31_DATA_WD_START = RF_BE_30_DATA_WD_START + RF_BE_30_DATA_WD;

  parameter [15:0] RF_BE_DATA_WD_START_ARRAY [0:31] = '{RF_BE_0_DATA_WD_START ,
                                                        RF_BE_1_DATA_WD_START ,
                                                        RF_BE_2_DATA_WD_START ,
                                                        RF_BE_3_DATA_WD_START ,
                                                        RF_BE_4_DATA_WD_START ,
                                                        RF_BE_5_DATA_WD_START ,
                                                        RF_BE_6_DATA_WD_START ,
                                                        RF_BE_7_DATA_WD_START ,
                                                        RF_BE_8_DATA_WD_START ,
                                                        RF_BE_9_DATA_WD_START ,
                                                        RF_BE_10_DATA_WD_START,
                                                        RF_BE_11_DATA_WD_START,
                                                        RF_BE_12_DATA_WD_START,
                                                        RF_BE_13_DATA_WD_START,
                                                        RF_BE_14_DATA_WD_START,
                                                        RF_BE_15_DATA_WD_START,
                                                        RF_BE_16_DATA_WD_START,
                                                        RF_BE_17_DATA_WD_START,
                                                        RF_BE_18_DATA_WD_START,
                                                        RF_BE_19_DATA_WD_START,
                                                        RF_BE_20_DATA_WD_START,
                                                        RF_BE_21_DATA_WD_START,
                                                        RF_BE_22_DATA_WD_START,
                                                        RF_BE_23_DATA_WD_START,
                                                        RF_BE_24_DATA_WD_START,
                                                        RF_BE_25_DATA_WD_START,
                                                        RF_BE_26_DATA_WD_START,
                                                        RF_BE_27_DATA_WD_START,
                                                        RF_BE_28_DATA_WD_START,
                                                        RF_BE_29_DATA_WD_START,
                                                        RF_BE_30_DATA_WD_START,
                                                        RF_BE_31_DATA_WD_START};

  // RF_BE DEPTH of RAM
  parameter RF_BE_DEPTH = RF_BE_0_DEPTH  +
                          RF_BE_1_DEPTH  +
                          RF_BE_2_DEPTH  +
                          RF_BE_3_DEPTH  +
                          RF_BE_4_DEPTH  +
                          RF_BE_5_DEPTH  +
                          RF_BE_6_DEPTH  +
                          RF_BE_7_DEPTH  +
                          RF_BE_8_DEPTH  +
                          RF_BE_9_DEPTH  +
                          RF_BE_10_DEPTH +
                          RF_BE_11_DEPTH +
                          RF_BE_12_DEPTH +
                          RF_BE_13_DEPTH +
                          RF_BE_14_DEPTH +
                          RF_BE_15_DEPTH +
                          RF_BE_16_DEPTH +
                          RF_BE_17_DEPTH +
                          RF_BE_18_DEPTH +
                          RF_BE_19_DEPTH +
                          RF_BE_20_DEPTH +
                          RF_BE_21_DEPTH +
                          RF_BE_22_DEPTH +
                          RF_BE_23_DEPTH +
                          RF_BE_24_DEPTH +
                          RF_BE_25_DEPTH +
                          RF_BE_26_DEPTH +
                          RF_BE_27_DEPTH +
                          RF_BE_28_DEPTH +
                          RF_BE_29_DEPTH +
                          RF_BE_30_DEPTH +
                          RF_BE_31_DEPTH ;

