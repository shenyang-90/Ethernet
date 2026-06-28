-timescale 10ps/10ps

+define+ABV_ON
+define+ABV_RESET_ON
//+define+CDNSDRU_DATASYNC_SYNTHESIS
+define+CDNSDRU_DATASYNC_RESET_STATE=1
+define+CDNSDRU_DATASYNC_SYNC_RESET=1
+define+CDNSDRU_DATASYNC_NUM_FLOPS=4

-sv 
-propfile_vlog ../vunit/cdnsdru_datasync_vunit_v1.v 
-gui
-assert
-access +rwc
-coverage all
-covoverwrite
-abvcoveron
-abvrecordcoverall
-top tb_datasync

../../hdl/hdl_src/cdnsdru_datasync_synth_example.sv
../../hdl/hdl_src/cdnsdru_datasync_v1.v
./cdn_clk_rst_gen_block.sv
./tb_datasync.sv
