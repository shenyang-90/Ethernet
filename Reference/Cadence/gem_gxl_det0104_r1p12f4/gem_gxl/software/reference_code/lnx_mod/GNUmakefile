###############################################################################
# copyright (C) 2014-2015 Cadence Design Systems
# All rights reserved.
###############################################################################
#
#  Make NIC linux driver as loadable module, and load/unload using
#   modp & modpr targets
#
###############################################################################

DIST   	?= $(shell uname -r)
DRV_NAME := cds_mac
DEV_NAME := cdsmac
mod_dir	:= $(abspath .)
src_dir := $(mod_dir)/src
edd_dir := $(mod_dir)/../core_driver
KDIR    := /lib/modules/$(DIST)/build/
obj_dir := $(mod_dir)/obj
mod_file := $(DRV_NAME).ko

targ_make := Makefile.mac_mod

src_files := $(wildcard \
	$(edd_dir)/include/cedi.h \
	$(edd_dir)/include/cps.h \
	$(edd_dir)/include/emac_regs*.h \
	$(edd_dir)/src/*.[ch] \
	$(src_dir)/*.[ch] \
	)

.PHONY: all modules clean

all: mod_file macdiag

mod_file: modules

# link in the source files for core & linux drivers, and the Makefile
$(obj_dir)/Makefile:
	@if [ ! -d $(obj_dir) ]; then mkdir -p $(obj_dir); fi
	cd $(obj_dir) && for srcfil in $(src_files); do ln -fs $$srcfil; done
	cd $(obj_dir) && ln -fs $(src_dir)/$(targ_make) Makefile

modules: $(obj_dir)/Makefile
	make -C $(KDIR) M=$(obj_dir) NIC2=$(NIC2) modules
	sudo make install

insmod:
	sudo insmod $(obj_dir)/$(mod_file)
#	sudo chmod 777 /dev/$(DEV_NAME)*

modp:
	sudo modprobe $(DRV_NAME)
  
modpr:
	sudo modprobe -r $(DRV_NAME)  
  
lsmod:
	- lsmod | grep $(DRV_NAME)

rmmod:
	sudo rmmod $(obj_dir)/$(mod_file)

install:
#	typically one invokes this as "sudo make install"
	install -p $(obj_dir)/$(DRV_NAME).ko $(DESTDIR)/lib/modules/$(DIST)
	/sbin/depmod -a

macdiag: 
	make -C src $(obj_dir)/mac_diag
	mv $(obj_dir)/mac_diag $(mod_dir)

clean:
	$(RM) -r $(obj_dir)


