
CATAPULT_HOME    ?= /wv/hlsb/CATAPULT/10.6a/PRODUCTION/aol/Mgc_home

#==============================================

FUNCTION         ?= conv_par_in
ACCEL_NAME       ?= cat_accel
PAR              ?= 1

SOURCES          = testbench.cpp hw_infer.cpp sw_infer.cpp cat_access.cpp diags.cpp catapult_accel.cpp
SPEC_FILE        = $(FUNCTION).spec
HEADERS          = cat_access.h hw_infer.h sw_infer.h diags.h mnist_par.hpp 

ACCELERATOR      = ../hw/master_par$(PAR).v
BUS_IF           = ../hw/$(ACCEL_NAME).v
HEADER           = ../sw/$(FUNCTION).h 

HOST_EXE         = testbench

CRUFT            = Catapult* catapult.log make.out design_checker_constraints.tcl design_checker_pre_build.tcl catapult.pinfo differences.txt

CATAPULT         = $(CATAPULT_HOME)/bin/catapult
CATAPULT_FLAGS   = -shell -file master_par$(PAR).tcl

IFGEN_DIR        = ../../../if_gen
IFGEN            = if_gen_axi
IFGEN_CMD        = $(IFGEN_DIR)/$(IFGEN)

INCLUDES         = -I $(CATAPULT_HOME)/shared/include -I ../../../include -I .

OPTS             += -D FIXED_POINT -D WEIGHT_MEMORY -D MASTER -D A53

QUIET_FLAG       = --no-print-directory

export WEIGHT_PATH = ../../../data

.PHONY: all run_host clean

all: $(ACCELERATOR) $(HEADER) $(BUS_IF) $(HOST_EXE)

run_host: $(HOST_EXE)
	@echo "Running host testbench"
	@./$(HOST_EXE)

$(ACCELERATOR): $(SOURCES) $(HEADERS) master_par$(PAR).tcl
	@echo "CAT      $(SOURCES) -o $(ACCELERATOR)"
	@rm -rf $(CRUFT)
	@$(CATAPULT) $(CATAPULT_FLAGS) >> make.out
	@cp Catapult/*/concat_rtl.v $@
	@rm -rf $(CRUFT)

$(HOST_EXE): $(HEADERS) $(SOURCES) 
	@echo "GCC      $(SOURCES) -o $@"
	@g++ -g -o $@ $(INCLUDES) -D HOST -D PAR_IN=$(PAR) -std=c++11 $(OPTS) $(SOURCES) >> make.out

$(BUS_IF): $(SPEC_FILE) $(SOURCES) $(IFGEN_CMD)
	@echo "IFGEN    $(SPEC_FILE)"
	@$(IFGEN_CMD) $(FUNCTION) $(SPEC_FILE) $(ACCEL_NAME)
	mv $(ACCEL_NAME).v $(BUS_IF)
	mv $(FUNCTION).h $(HEADER)

$(HEADER): $(SPEC_FILE) $(SOURCES) $(IFGEN_CMD)
	@echo "IFGEN    $(SPEC_FILE)"
	@$(IFGEN_CMD) $(FUNCTION) $(SPEC_FILE) $(ACCEL_NAME)
	mv $(ACCEL_NAME).v $(BUS_IF)
	mv $(FUNCTION).h $(HEADER)

$(IFGEN_CMD):
	@echo "MAKE     $(IFGEN)"
	make -C $(IFGEN_DIR) $(IFGEN) $(QUIET_FLAG)

clean:
	@echo "Removing created files and cruft"
	@rm -rf $(CRUFT) $(ACCELERATOR) $(HOST_EXE) $(BUS_IF) $(HEADER)


