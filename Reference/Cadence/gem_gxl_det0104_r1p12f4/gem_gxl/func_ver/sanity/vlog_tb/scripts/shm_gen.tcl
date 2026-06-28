# shm file to generate waveform databases for simulation

database -default -shm gem_gxl -into waves.shm;
probe tb_gem_gxl -all -depth all -shm;
probe tb_gem_gxl -ports -depth all -shm
probe i_gem_gxl -all -depth all -memories -shm;

# UVM tb
probe cdn_tb -all -depth all -shm
probe cdn_tb -ports -depth all -shm
probe cdn_tb.dut_i.i_gem -all -depth all -memories -shm;

probe -show

run
database -close gem_gxl

