
LOCATION = "MENTOR"
#LOCATION = "GLOBAL_FOUNDRIES"

#====== GF Location Specific Settings ============

ifeq ($(LOCATION), "GLOBAL_FOUNDRIES")

export QUESTA_HOME      ?= /tool/eda/apps/mentorQuestaUltra/10.6c/questasim/
export VIS_HOME         ?= /u/release/2020.2/visualizer
export CODELINK_HOME    ?= /project/codelink_qa/codelink_homes/codelink_home_2020.1_ixl
export A53_SOURCE_DIR   ?= /proj/cad_scratch6/prajput/mentor/a53/cortex_a53/arm_cortex_a53/logical/
export CATAPULT_HOME    ?= /tool/eda/apps/mentorCatapult/10.5/Mgc_home/
export CODEBENCH_HOME   ?= /proj/cad_arm_14lpp/knaraya2/m4_sample_rundir/gcc-arm-none-eabi-5_4-2016q3
export VERDI_HOME       ?=
export ARM_LIB          ?=

endif

#====== Location Specific Settings ============

ifeq ($(LOCATION), "MENTOR")

export QUESTA_HOME      ?= /u/release/2020.2/questasim
export VIS_HOME         ?= /u/release/2020.2/visualizer
export CODELINK_HOME    ?= /project/codelink_qa/codelink_homes/codelink_home_2020.1_ixl
export WARPCORE_HOME    ?= /project/codelink_qa/warpcore_homes/warpcore_home_1.5_1
#export A53_SOURCE_DIR   ?= /home/russk/gf_staging/from_gf/arm_cortex_a53/cortexa53/logical
export A53_SOURCE_DIR   ?= /home/russk/gf_staging/from_gf/arm_cortex_a53/arm_cortex_a53/cortexa53/logical
export CATAPULT_HOME    ?= /wv/hlsb/CATAPULT/10.5a/PRODUCTION/aol/Mgc_home
export CODEBENCH_HOME   ?= /home/russk/accelerator/cat_accel_design/tools/gcc-arm-none-eabi-9-2019-q4-major

export ARM_LIB          ?= /home/russk/gf_staging/new_tree/arm_lib

endif

#====== Run Specific Settings =================
#       set on the 'make' command line

export ACCEL            ?= null
export PROGRAM          ?= $(ACCEL)

#=============================================


PAR           ?= 3

ifdef OPT
GCC_OPT        = "OPT=true"
endif

ifdef FSDB
FSDB_OPT       = dump
endif

ifdef MASTER
HDL_DEFINES    += "+define+MASTER "
endif

ifdef TB_MEM
HDL_DEFINES    += "+define+TB_MEM "
WEIGHT_MEMORY  = tbench.ssram_high
else
WEIGHT_MEMORY  = tbench.top.ssram_high
endif

ifdef BYTE_MEM
HDL_DEFINES    += "+define+BYTE_MEMORY "
RUN_DO         = run_byte.do
else 
RUN_DO         = run.do
endif

#export ACCEL_PATH  = ../accelerators/$(ACCEL)
export ACCEL_PATH  = ../accelerators/mnist

export PATH   := $(QUESTA_HOME)/bin:$(VIS_HOME)/bin:$(PATH)

VLOG           = vlog
VSIM           = vsim
VMAP           = vmap
VLIB           = vlib
VOPT           = vopt
SCCOM          = sccom


VLOG_FLAGS     = -work $(work) +acc=all $(HDL_DEFINES)
VIS_FLAGS      = -work $(work) -L $(ARM_LIB) -t 1ps -visualizer -qwavedb=+signal+report+memory=1024+transaction+class
VSIM_FLAGS     = -work $(work) -L $(ARM_LIB) -t 1ps -voptargs="+acc" -do $(RUN_DO)
VOPT_VIS_FLAGS = -undefsyms=verbose -debug +designfile 
VOPT_FLAGS     = -g +acc=all -L $(ARM_LIB)
SCCOM_FLAGS    = -g -O0 $(INCLUDES) -std=c++11

#MTI_VCO_MODE   = 32

export TERMINAL      = ../terminal
export MEMORY_IMAGE  = ../sw/$(PROGRAM)/$(PROGRAM)

terminal       = terminal.so

hw_sources     = ../hw
marker_dir     = $(markers)/maker.mark

# markers

markers        = marker_files
build          = $(markers)/build.mark
build_vis      = $(markers)/build_vis.mark
work_lib       = $(markers)/work.mark
tbench         = $(markers)/tbench.sv.mark
#cortex_a53     = $(markers)/cortex_a53.mark
codelink       = $(markers)/codelink.mark
accelerator    = $(markers)/accelerator.mark

hdl_source_markers =                     \
		 $(markers)/addr_gen.sv.mark               \
		 $(markers)/axi_byte_enables.sv.mark       \
		 $(markers)/axi_segment_arbiter.sv.mark    \
		 $(markers)/bus_fifo.sv.mark               \
		 $(markers)/mux.sv.mark                    \
		 $(markers)/sram.sv.mark                   \
		 $(markers)/uart.sv.mark                   \
		 $(markers)/axi_addr_latch.sv.mark         \
		 $(markers)/axi_data_latch.sv.mark         \
		 $(markers)/axi_slave_if.sv.mark           \
		 $(markers)/char_in.sv.mark                \
		 $(markers)/null_periph.sv.mark            \
		 $(markers)/tbench.sv.mark                 \
		 $(markers)/axi_matrix.sv.mark             \
		 $(markers)/axi_slave_segment.sv.mark      \
		 $(markers)/char_out.sv.mark               \
		 $(markers)/ready_gen.sv.mark              \
		 $(markers)/timer.sv.mark                  \
		 $(markers)/top.sv.mark                    \
		 $(markers)/arbiter.sv.mark                \
		 $(markers)/dump.v.mark                    \
		 $(markers)/axi4_interconnect_NxN.sv.mark

a53_source     = $(A53_SOURCE_DIR)/cortexa53/verilog/CORTEXA53.v
design         = $(tbench)
opt_object     = tbench_opt
vis_opt_object = tbench_opt_vis

work           = ./work

CRUFT          = transcript              \
		 *.wlf                   \
		 wlf*                    \
		 modelsim.ini            \
		 codelink.ini            \
		 *stacktrace*            \
		 qwave.db                \
		 .visualizer             \
		 visualizer.log          \
		 design.bin              \
		 make.out                \
                 codelink_replay.rlf     \
		 .cdl_top.jdb            \
		 .codelink_logs          \
		 .codelink_out           \
                 run.do                  \
                 run_byte.do             \
		 core.*

.PHONY: run

#====== Questa target ==============

.PHONY: run_questa

run_questa: $(build) $(RUN_DO) software
	@echo VSIM    tbench $(PROGRAM) $(FSDB_OPT)
	@$(VSIM) $(VSIM_FLAGS) tbench $(FSDB_OPT) -sv_lib terminal >> make.out

$(build): $(marker_dir) $(work_lib) $(hdl_source_markers) $(cortex_a53) $(accelerator) $(terminal) 
	@echo VOPT    tbench
	###@$(VOPT) $(VOPT_FLAGS) tbench -o $(opt_object) >> make.out
	@$(VOPT) $(VOPT_FLAGS) $(FSDB_OPT) tbench -o $(opt_object) >> make.out
	@touch $(build)

#====== Visualizer target ==========

.PHONY: run_vis

run_vis: $(build_vis) $(RUN_DO) software
	@echo VSIM    $(vis_opt_object)
	@$(VSIM) $(VIS_FLAGS) $(vis_opt_object) >> make.out

$(build_vis): $(marker_dir) $(work_lib) $(hdl_source_markers) $(cortex_a53) $(accelerator) $(terminal) 
	@echo VOPT    tbench $(FSDB_OPT)
	@$(VOPT) $(VOPT_VIS_FLAGS) tbench $(FSDB_OPT) -o $(vis_opt_object) >> make.out
	@touch $(build_vis)

#====== Codelink target ============

.PHONY: run_codelink

run_codelink: $(build) $(codelink) $(RUN_DO) codelink.ini software
	$(VSIM) $(VSIM_FLAGS) tbench -sv_lib terminal \
		-foreign "codelink $(CODELINK_HOME)/lib/codelink.so" \
		+codelink_cpulabel=Top >> make.out

#====== Codelink target ============

.PHONY: run_warpcore

run_warpcore: $(build) $(warpcore) $(RUN_DO) warpcore.config software
	@$(VLOG) $(VLOG_FLAGS) $(WARPCORE_HOME)/bim/CORTEXA53_r0_warpcore.sv +incdir+../hw +define+WARPCORE_CLOCK=tbench.CLK  >> make.out
	$(VSIM) $(VSIM_FLAGS) tbench -sv_lib terminal -sv_lib $(WARPCORE_HOME)/lib/libwarpcore_vsim_4.5_32

#====== A53 processor ===============
# ARM processor should be pe-compiled into $(ARM_LIB) 
#$(cortex_a53): $(marker_dir) $(work_lib) ../hw.old/ca53_compile.vc $(a53_source)
#	@echo VLOG    $(a53_source)
#	@$(VLOG) $(VLOG_FLAGS) -f ../hw.old/ca53_compile.vc $(a53_source) >> make.out
#	@touch $(cortex_a53)
#
#====== Accelerator =================

$(accelerator):
	@echo "Making accelerator"
	@make -C $(ACCEL_PATH)/src 
	@echo $(VLOG) $(VLOG_FLAGS) $(ACCEL_PATH)/hw/cat_accel.v
	@$(VLOG) $(VLOG_FLAGS) $(ACCEL_PATH)/hw/cat_accel.v >> make.out
	@echo $(VLOG) $(VLOG_FLAGS) $(ACCEL_PATH)/hw/$(ACCEL).v
	@$(VLOG) $(VLOG_FLAGS) $(ACCEL_PATH)/hw/$(ACCEL).v >> make.out
	@touch $(accelerator)

#====== Codelink ====================
#       in simulation software debug

$(codelink): $(marker_dir) $(work_lib) $(CODELINK_HOME)/vsim/codelink_cpu_CORTEXA53_dev.sv
	@echo VLOG $(CODELINK_HOME)/vsim/codelink_cpu_CORTEXA53_r0_v2.sv
	@$(VLOG) $(VLOG_FLAGS) $(CODELINK_HOME)/vsim/codelink_cpu_CORTEXA53_dev.sv +define+CPU_PATH=tbench.top.cpu.g_ca53_cpu[0].u_ca53_cpu  >> make.out
	@echo VLOG ../hw/tbench.v +define+CODELINK
	@touch $(tbench)
	@$(VLOG) $(VLOG_FLAGS) ../hw/tbench.sv +define+CODELINK >> make.out
	@touch $(codelink)

#====== Warpcore ====================
#       fast processor model

$(warpcore): $(marker_dir) $(work_lib) $(WARPCORE_HOME)/vsim/codelink_cpu_CORTEXA53_dev.sv
	@echo VLOG $(WARPCORE_HOME)/bim/CORTEXA53_r0_warpcore.sv 
	@$(VLOG) $(VLOG_FLAGS) $(WARPCORE_HOME)/bim/CORTEXA53_r0_warpcore.sv +incdir+../hw +define+WARPCORE_CLOCK=tbench.clk  >> make.out
	@echo VLOG ../hw/tbench.v +define+WARPCORE
	@touch $(tbench)
	@$(VLOG) $(VLOG_FLAGS) ../hw/tbench.sv +define+WARPCORE >> make.out
	@touch $(warpcore)

#====== Generic compile rules ======
 
$(object_dir)/%.o: %.cpp
	@echo CC      $<
	@$(GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $< >> make.out

$(markers)/%.sv.mark: $(hw_sources)/%.sv
	@echo VLOG    $<
	@$(VLOG) $(VLOG_FLAGS) $< >> make.out
	@touch $@

$(markers)/%.v.mark: $(hw_sources)/%.v
	@echo VLOG    $<
	@$(VLOG) $(VLOG_FLAGS) $< >> make.out
	@touch $@

$(markers)/%.sc.mark: %.cpp
	@echo SCCOM   $<
	@$(SCCOM) $(SCCOM_FLAGS) $(DEFINES) -D QUESTA -D MATCHLIB $<
	@touch $@

#====== Working directories ========

$(marker_dir):
	@echo MKDIR   $@
	@mkdir $(markers) >> make.out
	@touch $(marker_dir)

$(work_lib): $(marker_dir)
	@echo VLIB    $(work)
	@$(VLIB) $(work) >> make.out
	@echo VMAP    -work $(work)
	@$(VMAP) work $(work) >> make.out
	@touch $(work_lib)

#====== Support programs ===========

$(terminal): $(TERMINAL)/dpi/terminal.c $(TERMINAL)/bin/terminal_emulator
	@echo CC      $<
	@$(CC) -m32 -DVSIM -fPIC -shared -o $(terminal) $(TERMINAL)/dpi/terminal.c -I $(QUESTA_HOME)/include -I ./

$(TERMINAL)/bin/terminal_emulator: $(TERMINAL)/dpi/terminal_emulator.c
	@echo CC      $<
	@$(CC) -m32 -o $(TERMINAL)/bin/terminal_emulator $(TERMINAL)/dpi/terminal_emulator.c -lpthread >> make.out


#====== Questa run script ==========

run.do: 
	@echo CREATE   run.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.mem    " >  run.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).mem -format hex                 tbench.top.ssram_low.mem    " >> run.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).mem        " >> run.do
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).mem -format hex $(WEIGHT_MEMORY).mem        " >> run.do 
	@echo "add wave -r /*                                                                                    " >> run.do
	@echo "run 3000 ms                                                                                       " >> run.do

run_byte.do: 
	@echo CREATE   run_byte.do
	@echo "                                                                                                             " >  run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[0].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[1].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[2].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[3].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[4].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[5].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[6].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[7].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[8].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[9].byte_memory.mem    " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[10].byte_memory.mem   " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[11].byte_memory.mem   " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[12].byte_memory.mem   " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[13].byte_memory.mem   " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[14].byte_memory.mem   " >> run_byte.do
	@echo "mem load -filldata 0                                                  tbench.top.ssram_low.genblk1[15].byte_memory.mem   " >> run_byte.do
	@echo "                                                                                                             " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte0.mem -format hex           tbench.top.ssram_low.genblk1[0].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte1.mem -format hex           tbench.top.ssram_low.genblk1[1].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte2.mem -format hex           tbench.top.ssram_low.genblk1[2].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte3.mem -format hex           tbench.top.ssram_low.genblk1[3].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte4.mem -format hex           tbench.top.ssram_low.genblk1[4].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte5.mem -format hex           tbench.top.ssram_low.genblk1[5].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte6.mem -format hex           tbench.top.ssram_low.genblk1[6].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte7.mem -format hex           tbench.top.ssram_low.genblk1[7].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte8.mem -format hex           tbench.top.ssram_low.genblk1[8].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte9.mem -format hex           tbench.top.ssram_low.genblk1[9].byte_memory.mem    " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte10.mem -format hex          tbench.top.ssram_low.genblk1[10].byte_memory.mem   " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte11.mem -format hex          tbench.top.ssram_low.genblk1[11].byte_memory.mem   " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte12.mem -format hex          tbench.top.ssram_low.genblk1[12].byte_memory.mem   " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte13.mem -format hex          tbench.top.ssram_low.genblk1[13].byte_memory.mem   " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte14.mem -format hex          tbench.top.ssram_low.genblk1[14].byte_memory.mem   " >> run_byte.do
	@echo "mem load -infile \$$env(MEMORY_IMAGE).byte15.mem -format hex          tbench.top.ssram_low.genblk1[15].byte_memory.mem   " >> run_byte.do
	@echo "                                                                                                             " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[0].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[1].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[2].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[3].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[4].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[5].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[6].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[7].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[8].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[9].byte_memory.mem        " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[10].byte_memory.mem       " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[11].byte_memory.mem       " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[12].byte_memory.mem       " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[13].byte_memory.mem       " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[14].byte_memory.mem       " >> run_byte.do
	@echo "mem load -filldata 0                                                  $(WEIGHT_MEMORY).genblk1[15].byte_memory.mem       " >> run_byte.do
	@echo "                                                                                                             " >> run_byte.do
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte0.mem -format hex $(WEIGHT_MEMORY).genblk1[0].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte1.mem -format hex $(WEIGHT_MEMORY).genblk1[1].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte2.mem -format hex $(WEIGHT_MEMORY).genblk1[2].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte3.mem -format hex $(WEIGHT_MEMORY).genblk1[3].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte4.mem -format hex $(WEIGHT_MEMORY).genblk1[4].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte5.mem -format hex $(WEIGHT_MEMORY).genblk1[5].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte6.mem -format hex $(WEIGHT_MEMORY).genblk1[6].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte7.mem -format hex $(WEIGHT_MEMORY).genblk1[7].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte8.mem -format hex $(WEIGHT_MEMORY).genblk1[8].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte9.mem -format hex $(WEIGHT_MEMORY).genblk1[9].byte_memory.mem  " >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte10.mem -format hex $(WEIGHT_MEMORY).genblk1[10].byte_memory.mem" >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte11.mem -format hex $(WEIGHT_MEMORY).genblk1[11].byte_memory.mem" >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte12.mem -format hex $(WEIGHT_MEMORY).genblk1[12].byte_memory.mem" >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte13.mem -format hex $(WEIGHT_MEMORY).genblk1[13].byte_memory.mem" >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte14.mem -format hex $(WEIGHT_MEMORY).genblk1[14].byte_memory.mem" >> run_byte.do 
	@echo "mem load -infile ../weights/wide_fixed_weights_$(PAR).byte15.mem -format hex $(WEIGHT_MEMORY).genblk1[15].byte_memory.mem" >> run_byte.do 
	@echo "                                                                                                             " >> run_byte.do
	@echo "add wave -r /*                                                                                               " >> run_byte.do
	@echo "run 3000 ms                                                                                                  " >> run_byte.do

#====== Codelink.ini file ==========

codelink.ini:
	@echo CREATE codelink.ini
	@echo "[Top]                                       " >  codelink.ini
	@echo "inst_path = tbench.codelink_monitor         " >> codelink.ini
	@echo "elf_file = ../sw/\$${PROGRAM}/\$${PROGRAM}  " >> codelink.ini
	@echo "                                            " >> codelink.ini
	@echo "proc_type = armcortex_a53rtl_dev            " >> codelink.ini

#====== Warpcore Config file

warpcore.config:
	@echo CREATE warpcore.config
	@echo "                                                                                           " >  warpcore.config
	@echo "warpcore -launchcmd launch_vm --vm_type qemu --elf_file ../sw/\$$(PROGRAM)/\$$(PROGRAM)    " >> warpcore.config
	@echo "warpcore -instpath tbench.top.cpu -cpulabel CPU                                            " >> warpcore.config
	@echo "warpcore -accesstype sw -start 0x00000000000 -end 0x0001FFFFFFF -cpu CPU                   " >> warpcore.config
	@echo "warpcore -accesstype hw -start 0x00020000000 -end 0xFFFFFFFFFFF -cpu CPU                   " >> warpcore.config
	@echo "                                                                                           " >> warpcore.config

#====== Software image =============

.PHONY: software

software:
	@echo "Building program: $(PROGRAM)"
	@make -C ../sw/$(PROGRAM) TARGET=$(PROGRAM)

#====== Clean up ===================

.PHONY: clean

clean:
	@echo RM      targets and cruft
	@rm -rf $(target)        \
                $(work)          \
                $(markers)       \
                $(object_dir)    \
                $(CRUFT)         \
                $(terminal)      \
		$(TERMINAL)/bin/terminal_emulator
	@make -C ../sw/$(PROGRAM) clean PROGRAM=$(PROGRAM)

clean_everything:
	@echo RM targets and cruft
	@rm -rf $(target)        \
		$(work)          \
		$(markers)       \
		$(object_dir)    \
		$(CRUFT)         \
		$(terminal)      \
		$(TERMINAL)/bin/terminal_emulator
	@make -C ../sw/$(PROGRAM)                          clean_everything
#	@make -C ../accelerators/bfloat_mac/src  clean
#	@make -C ../accelerators/mac/src         clean
#	@make -C ../accelerators/sha256/src      clean
#	@make -C ../accelerators/mnist/src       clean
#	@make -C ../accelerators/conv_basic/src  clean
#	@make -C ../accelerators/conv_pipe/src    clean


