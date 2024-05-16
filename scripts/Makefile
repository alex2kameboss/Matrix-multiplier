WIDTH?=16
CORES?=4

LOG_DIR_PATH = logs
DEFINES = +define+BATCH+A_WIDTH=$(WIDTH)+A_HEIGHT=$(WIDTH)+
WORKDIR = sim_$(WIDTH)
TO_WORKDIR = cd $(WORKDIR) && 

log_dir:
	mkdir -p sim_$(WIDTH)/$(LOG_DIR_PATH)

rtl_analyzing: log_dir
	$(TO_WORKDIR) vlogan $(DEFINES) -sverilog -work work -full64 -l $(LOG_DIR_PATH)/analyzing_$(WIDTH).log ../src/*.sv ../src/async_fifo/*.sv ../interfaces/*.sv ../vivado_wrapper/mem_mock_gen.sv ../metrics/measure_metrics.sv

rtl_compile: rtl_analyzing
	$(TO_WORKDIR) vcs -fgp -j$(CORES) -sverilog work.measure_metrics -full64 -l $(LOG_DIR_PATH)/compile_$(WIDTH).log -lca

simulate: rtl_compile
	$(TO_WORKDIR) simv -fgp=num_threads:$(CORES) -l $(LOG_DIR_PATH)/simulate_$(WIDTH).log