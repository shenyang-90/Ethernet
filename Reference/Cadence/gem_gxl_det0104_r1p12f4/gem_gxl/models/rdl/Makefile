#########################################
# Makefile to generate the register model
#########################################

# Find reg_verifier tool
REG_VERIFIER_TOOL = $(shell which reg_verifier)
export REG_VERIFIER_TOOL

ifeq ($(REG_VERIFIER_TOOL),)
  # reg verifier not found so hard wire to known path.
	 REG_VERIFIER_TOOL = /grid/avs/install/incisive/14.2/14.20.008/bin/reg_verifier
endif

BUILD_DIR = ${PWD}
export BUILD_DIR

IPXACT_VERSION ?= ieee1685_2009

RDL_DIR := $(MODULE_PATH)/models/rdl
RDL_TOP_FILE_NAME := $(DESIGN)
RDL_FILE = $(RDL_DIR)/$(RDL_TOP_FILE_NAME).rdl

USE_TTI ?= 1

REV_NUM = $(shell svn info $(MODULE_PATH) | grep "Last Changed Rev" | perl -p -e 's/Last Changed Rev:\s//gi;')

rdl_dependencies : \
	 $(RDL_DIR)/xhci_config.rdl \
	 $(RDL_DIR)/$(RDL_TOP_FILE_NAME).rdl \
	 $(RDL_DIR)/xhci_doorbell.rdl \
	 $(RDL_DIR)/xhci_xdebugports.rdl \
	 $(RDL_DIR)/xhci_cap_regs.rdl \
	 $(RDL_DIR)/xhci_op_regs.rdl \
	 $(RDL_DIR)/xhci_runtime_regs.rdl \
	 $(RDL_DIR)/xhci_interrupter_regset_hilo.rdl \
	 $(RDL_DIR)/xhci_rsvd_fields.rdl \
	 $(RDL_DIR)/xhci_xcap_regs.rdl \
	 $(RDL_DIR)/xhci_ports.rdl \
	 $(RDL_DIR)/xhci_xcap_new_regs.rdl \
	 $(RDL_DIR)/xhci_msi.rdl \
	 $(RDL_DIR)/xhci_xsup_prot_cap.rdl 

# USER EDITABLE SECTION - END
################################

.DEFAULT_GOAL := all

# Setup the specman path for the computed_defines.v target.
export SPECMAN_PATH:=${SPECMAN_PATH}:${CDN_XHCI_PATH}/verif/uvc_lib_e:${RDL_DIR}:${BUILD_DIR}:${CONFIG_DIR}:${CDN_XHCI_PATH}/rtl/common/include:${CDN_XHCI_PATH}/rtl/include

#--------------------------------------------------------------------
# TARGET : computed_defines.v - This target file is created using a
# specman program "comp_defines.e" to process all of the verilog
# defines so that the final values can be extracted and dumped into
# this computed_defines.v for the Perl script create_cfg.pl to read
# and generate the correct sysRDL configuration structure.
#--------------------------------------------------------------------
.phony: comp_defines
comp_defines: $(BUILD_DIR)/computed_defines.v

$(BUILD_DIR)/computed_defines.v:
	 cp ${CDN_XHCI_PATH}/rtl/include/fl_host_core.vh $(BUILD_DIR)/local_fl_host_core.vh
	 sed -i '/TRM_XFER_DEBUG_BUS_WD/d' $(BUILD_DIR)/local_fl_host_core.vh
	 sed -i '/HOST_APP_/d' $(BUILD_DIR)/local_fl_host_core.vh
	 cp ${CDN_XHCI_PATH}/rtl/include/debug_port.vh $(BUILD_DIR)/local_debug_port.vh
	 sed -i 's/fl_host_core.vh/local_fl_host_core.vh/' $(BUILD_DIR)/local_debug_port.vh
	 sed -i '/HOST_APP_/d' $(BUILD_DIR)/local_debug_port.vh
	 sed -i '/DEV_APP_/d' $(BUILD_DIR)/local_debug_port.vh
	 sed -i '/ISO_TMSTAMP/d' $(BUILD_DIR)/local_debug_port.vh
	 cp ${CDN_XHCI_PATH}/rtl/link/include/link.vh $(BUILD_DIR)/local_link.vh
	 specman -c "load comp_defines; test"


#--------------------------------------------------------------------
# TARGET : svregs - create the system verilog uvm_reg code
#--------------------------------------------------------------------
.phony: svregs
svregs: $(BUILD_DIR)/$(RDL_TOP_FILE_NAME).sv
$(BUILD_DIR)/$(RDL_TOP_FILE_NAME).sv : $(BUILD_DIR)/$(RDL_TOP_FILE_NAME).xml
	 @echo [make] Building SV register model from ipxact
	 @$(IREG_GEN)/bin/iregGen -i $(BUILD_DIR)/$(RDL_TOP_FILE_NAME).xml -d ${BUILD_DIR} -o $(RDL_TOP_FILE_NAME).sv -uvm11a
	 @echo [make] Building SV regsister model complete
	 @echo [make] Removing coverage of reserved fields in SV regsister model
	 @sed -i '/coverpoint Rsvd/d' $(BUILD_DIR)/$(RDL_TOP_FILE_NAME).sv
	 @sed -i 's/1, UVM_LITTLE_ENDIAN/4, UVM_LITTLE_ENDIAN/g' $(BUILD_DIR)/$(RDL_TOP_FILE_NAME).sv
	 @echo [make] Removing coverage of reserved fields in SV regsister model complete

#--------------------------------------------------------------------
# TARGET : docs - make rtf and html docs for the xHCI registers
#--------------------------------------------------------------------
.phony: docs
docs: rtf html

.phony : html
html: 
	 socrates_cli --plugin bitwise --path $(BUILD_DIR) --new --workarea bitwise --import systemrdl_import --file $(RDL_FILE) --generate default_html --component $(RDL_TOP_FILE_NAME) --slavebusinterface s_1 --output $(BUILD_DIR)

.phony : rtf
rtf: 
	 socrates_cli --plugin bitwise --path $(BUILD_DIR) --new --workarea bitwise --import systemrdl_import --file $(RDL_FILE) --generate default_rtf --component $(RDL_TOP_FILE_NAME) --slavebusinterface s_1 --output $(BUILD_DIR)

#--------------------------------------------------------------------
# TARGET : ipxact - make ipxact using socrates_cli or TTI Glue
#--------------------------------------------------------------------
.phony: ipxact
ipxact: $(BUILD_DIR)/$(RDL_TOP_FILE_NAME).xml
$(BUILD_DIR)/${RDL_TOP_FILE_NAME}.xml:
ifeq ($(USE_TTI),0)
	 @echo [make] Building IP-XACT using socrates_cli tool.
	 socrates_cli --plugin bitwise --path $(BUILD_DIR) --new --workarea ipxact --import systemrdl_import --file $(RDL_FILE) --export $(IPXACT_VERSION) --force --component $(RDL_TOP_FILE_NAME) --output $(BUILD_DIR)
	 # The following needs to be removed from xml before iregGen can be run
	 #         <spirit:readAction>modify</spirit:readAction>
	 #         <spirit:modifiedWriteValue>modify</spirit:modifiedWriteValue>
	 perl -p -i -e "s/^.*\<spirit\:readAction\>modify.*\n//g" $(BUILD_DIR)/ipxact/$(RDL_TOP_FILE_NAME)_component.xml
	 perl -p -i -e "s/^.*\<spirit\:modifiedWriteValue\>modify.*\n//g" $(BUILD_DIR)/ipxact/$(RDL_TOP_FILE_NAME)_component.xml
	 @mv $(BUILD_DIR)/ipxact/$(RDL_TOP_FILE_NAME)_component.xml $(BUILD_DIR)/$(RDL_TOP_FILE_NAME).xml
	 @rm -rf $(BUILD_DIR)/ipxact
	 @echo [make] Building IP-XACT complete .. see $(RDL_TOP_FILE_NAME).xml file in BUILD_DIR.
else
	 @echo [make] Building IP-XACT using TTI tool.
	 @echo [make] LANG env var = ${LANG}
	 @echo [make] TTI_IPXACT_TOOL_PATH = ${TTI_IPXACT_TOOL_PATH}
	 @${TTI_IPXACT_TOOL_PATH}/ipxact_packager -xml_target_dir $(BUILD_DIR) -rdve_file_name tmp -rdl_file $(RDL_FILE)
	 perl -p -i -e "s/emac_regs\</__ALL__\</g" $(BUILD_DIR)/tmp_ipxact.xml
	 perl -p -i -e "s/emac_regs_memory_map_wrapper/emac_regs/g" $(BUILD_DIR)/tmp_ipxact.xml
	 @mv $(BUILD_DIR)/tmp_ipxact.xml $(BUILD_DIR)/$(RDL_TOP_FILE_NAME).xml
	 @echo [make] Building IP-XACT complete .. see $(RDL_TOP_FILE_NAME).xml file in BUILD_DIR.
endif

#--------------------------------------------------------------------
# TARGET : ipxact_comp - make ipxact IO and register component using socrates DE
#--------------------------------------------------------------------
#.phony: ipxact_comp
#ipxact_comp: $(BUILD_DIR)/cdnsxhci_component.xml
#$(BUILD_DIR)/cdnsxhci_component.xml:$(BUILD_DIR)/$(RDL_TOP_FILE_NAME).xml
#	 @echo [make] Building full IP-XACT component using Socrates DE tool.
#	 socrates_cli -data socrates_de_worklib --project cdnsxhci_component --flow AddNewProject
#	 socrates_cli -data socrates_de_worklib --project cdnsxhci_component --flow RunScript -DScriptFile=$(RDL_DIR)/ipxact_component/process_ipxact.rb
#	 @cp socrates_de_worklib/cdnsxhci_component/arm_com-cdnsxhci_component-cdnsxhci_ips-1_0.xml cdnsxhci_component.xml
#	 @echo [make] Building full IP-XACT component complete .. see cdnsxhci_component.xml file in BUILD_DIR.


#--------------------------------------------------------------------
# TARGET : clean - cleanup directory to ensure files get regenerated
# [EB]   : removing files with ".log" extension unpredictably screw 
#          things up in some environments, like the demo TB.
#          So, avoid doing that.
#--------------------------------------------------------------------
.phony: clean
clean:
	 -@rm -rf $(RDL_DIR)/${DESIGN}.rdl
	 -@rm -rf $(RDL_TOP_FILE_NAME).e
	 -@#rm -rf *.log*
	 -@#rm -rf $(RDL_DIR)/*.log
	 -@rm -rf $(RDL_DIR)/log.txt
	 -@rm -rf *.elog
	 -@rm -rf *.bak*
	 -@rm -rf *.ddb*
	 -@rm -rf *source_code_settings*
	 -@rm -rf *.txt
	 -@rm -rf *.html
	 -@rm -rf *.css 
	 -@rm -rf *.xml
	 -@rm -rf bitwise.*
	 -@rm -rf ipxact.bitwise*
	 -@rm -rf ipxact
	 -@rm -rf $(RDL_DIR)/preprocessed*
	 -@rm -rf *.rtf
	 -@rm -rf tmp_rdl
	 -@rm -rf tmp.xml
	 -@rm -rf local_*.vh
	 -@rm -rf computed_defines.v
	 -@rm -rf $(RDL_TOP_FILE_NAME).sv
	 -@rm -rf ${CONFIG_DIR}/$(RDL_TOP_FILE_NAME).e
	 -@rm -rf reg_verifier_dir
	 -@rm -rf edit_$(RDL_TOP_FILE_NAME).xml
	 -@rm -rf socrates_de_worklib

#--------------------------------------------------------------------
# TARGET : all - builds docs and ipxact for Jenkins checks
#--------------------------------------------------------------------
.phony: all
all: docs ipxact



#--------------------------------------------------------------------
# TARGET : release - builds rtf and ipxact for release based on
# specified config. Gets file names correct for release.
#--------------------------------------------------------------------
.phony: release
release: rtf ipxact_release check_committed_vr_ad_is_match
	 $(MAKE) ipxact_release CONFIG=$(CONFIG) IPXACT_VERSION=ieee1685_2009 USE_TTI=0
	 $(MAKE) ipxact_release CONFIG=$(CONFIG) IPXACT_VERSION=ipxact14 USE_TTI=0
	 cp $(RDL_TOP_FILE_NAME)_map_s_1.rtf "Cadence ${DESIGN} IP - Programmers Guide.rtf"

.phony: ipxact_release
ipxact_release:
	 $(MAKE) ipxact CONFIG=$(CONFIG) IPXACT_VERSION=$(IPXACT_VERSION) USE_TTI=0
	 cp $(RDL_TOP_FILE_NAME).xml $(RDL_TOP_FILE_NAME)_$(IPXACT_VERSION)_$(CONFIG)_svnR$(REV_NUM).xml

#--------------------------------------------------------------------
# TARGET : help - print some help
#--------------------------------------------------------------------
.phony: help
help:
	 @echo "Register Model Generation"
	 @echo "-------------------------"
	 @echo " USE_TTI - Control which tool is used for generation of IPXACT. "
	 @echo "	   - USE_TTI=0 for socretes_cli"
	 @echo "	   - USE_TTI=1 for Cadence TTI Glue"
	 @echo "	   - Default USE_TTI=$(USE_TTI)"
	 @echo ""
	 @echo " The generated IPXACT can then be used by iregGen to generate"
	 @echo " the SV register model for the UVM-SV VE or by vr_ad script to"
	 @echo " generate the vr_ad register model for the Specman UVM-e VE."
	 @echo " All outputs are currently dumped into the BUILD_DIR which is"
	 @echo " set to BUILD_DIR=$(BUILD_DIR) - normally PWD"
	 @echo ""
	 @echo " IPXACT_VERSION - Control IPXACT version to generate."
	 @echo "		   - Possible values:"
	 @echo "		     - ipxact12"
	 @echo "		     - ipxact14"
	 @echo "		     - ieee1685_2009"
	 @echo "		   - Default IPXACT_VERSION=$(IPXACT_VERSION)"
	 @echo ""
	 @echo "----------------------------"
	 @echo "> make docs"
	 @echo "  - Generates the HTML and rtf docs for xHCI"
	 @echo "> make ipxact"
	 @echo "  - Generates the IP-XACT from the SystemRDL"
	 @echo "> make vr_ad"
	 @echo "  - Generates the vr_ad Specman register model from the SystemRDL (via IPXACT)"
	 @echo "> make svregs"
	 @echo "  - Generates the SystemVerilog register model from the SystemRDL (via IPXACT)"
	 @echo "> make clean"
	 @echo "  - Deletes all the output and log files in the local rdl directory"
	 @echo "> make all"
	 @echo "  - Generates docs and ipxact for Jenkins checks."
	 @echo "> make release CONFIG=$(CONFIG)"
	 @echo "  - Generates RTF doc and ipxact for specified config. Gets file names correct for release."
	 @echo "> make check_committed_vr_ad_is_match CONFIG=$(CONFIG) "
	 @echo "  - This target generates vr_ad files locally and then diffs them with committed version."
	 @echo "  - This is run as part of the release target."
	 @echo "----------------------------"
