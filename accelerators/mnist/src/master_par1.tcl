solution file add ./testbench.cpp 
solution file add ./hw_infer.cpp 
solution file add ./sw_infer.cpp 
solution file add ./cat_access.cpp 
solution file add ./diags.cpp 
solution file add ./catapult_accel.cpp 

#solution options set /Input/CompilerFlags {-I ../../../include -DSYNTHESIS -DMASTER -DHOST -DWEIGHT_MEMORY -DFIXED_POINT -DPAR_IN=$env("PAR") -DA53 }
solution options set /Input/CompilerFlags {-I . -I ../../../include -DSYNTHESIS -DMASTER -DHOST -DWEIGHT_MEMORY -DFIXED_POINT -DPAR_IN=1 -DA53 }

go analyze
go compile

solution library add nangate-45nm_beh -- -rtlsyntool DesignCompiler -vendor Nangate -technology 045nm
solution library add ccs_sample_mem
solution library add amba

go libraries

directive set /conv_par_in/core -DESIGN_GOAL Latency
directive set -CLOCKS {clk {-CLOCK_PERIOD 50 -CLOCK_EDGE rising -CLOCK_HIGH_TIME 25 -CLOCK_OFFSET 0.000000 -CLOCK_UNCERTAINTY 0.0 -RESET_KIND async -RESET_SYNC_NAME rst -RESET_SYNC_ACTIVE high -RESET_ASYNC_NAME arst_n -RESET_ASYNC_ACTIVE low -ENABLE_NAME {} -ENABLE_ACTIVE high}}
directive set /conv_par_in/memory:rsc -MAP_TO_MODULE {amba.ccs_axi4_master_core ADDR_WIDTH=44 ID_WIDTH=6 REGION_MAP_SIZE=4}

go assembly

directive set /conv_par_in/core/perform_convolution:shift_register:rsc -MAP_TO_MODULE {[Register]}

go architect

ignore_memory_precedences -from *write_mem(input*  -to *read_mem(input*
ignore_memory_precedences -from *write_mem(output* -to *read_mem(output*
ignore_memory_precedences -from *write_mem(dense*  -to *read_mem(dense*

go allocate
go extract

