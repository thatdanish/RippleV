# Decoder

decoder:
	cd test/decoder && pytest test_runner_decoder.py -s

wave_decoder:
	cd test/decoder/sim_build && surfer dump.fst

coverage_decoder:
	cd test/decoder/sim_build && verilator_coverage --annotate . coverage.dat

# Reg-file

reg_file:
	cd test/reg_file && pytest tests_reg_file.py -s

wave_reg_file:
	cd test/reg_file/sim_build && surfer dump.fst

coverage_reg_file:
	cd test/reg_file/sim_build && verilator_coverage --annotate . coverage.dat

# Program-counter

program_counter:
	cd test/program_counter && pytest tests_program_counter.py -s

wave_program_counter:
	cd test/program_counter/sim_build && surfer dump.fst

coverage_program_counter:
	cd test/program_counter/sim_build && verilator_coverage --annotate . coverage.dat

# CSR

csr:
	cd test/csr && pytest tests_csr.py -s

wave_csr:
	cd test/csr/sim_build && surfer dump.fst

coverage_csr:
	cd test/csr/sim_build && verilator_coverage --annotate . coverage.dat

# Instruction-memory

inst_mem:
	cd test/inst_mem && WAVES=1 pytest tests_inst_mem.py -s

wave_inst_mem:
	cd test/inst_mem/sim_build && surfer dump.fst

coverage_inst_mem:
	cd test/inst_mem/sim_build && verilator_coverage --annotate . coverage.dat

# Data-memory

data_mem:
	cd test/data_mem && pytest tests_data_mem.py -s

wave_data_mem:
	cd test/data_mem/sim_build && gtkwave dump.fst

coverage_data_mem:
	cd test/data_mem/sim_build && verilator_coverage --annotate . coverage.dat

# ALU

alu:
	cd test/ALU && pytest tests_alu.py -s

wave_alu:
	cd test/ALU/sim_build && surfer dump.fst

coverage_alu:
	cd test/ALU/sim_build && verilator_coverage --annotate . coverage.dat

# --------------------------------------------------------------------------------------- #

# RippleV_Mc

rvmc:
	cd test/RippleV_Mc && pytest test_runner_RippleV_Mc.py -v -k "rv32ui-p-addi"  

wave_rvmc:
	cd test/RippleV_Mc/sim_build && surfer dump.fst

coverage_rvmc:
	cd test/RippleV_Mc/sim_build && verilator_coverage --annotate . coverage.dat