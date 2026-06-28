make -f ../../../work/Makefile create_defs CFG=pbuf_3qs_axi GEN_SYNTH=" -gen_synth"
irun -c -F gem_gxl.f -top gem_gxl -incdir ./ 

rm -rf INCA_libs
rm -rf *defs*
rm -rf *param*
rm -rf *run_fpga*
rm -rf gem_gxl.f
