# Vars

WAVE ?= surfer # wave views
TC ?=		# test case
TOP_PYTEST_FLAG ?=	# top test
B_PYTEST_FLAG ?= -s	# block test

# All

all: all_blocks rvmc 

# All blocks

all_blocks: B_PYTEST_FLAG=-ra 
all_blocks: decoder reg_file program_counter csr inst_mem data_mem alu reg_file_v2 bl

# Decoder

decoder:
	cd test/decoder && pytest test_runner_decoder.py $(B_PYTEST_FLAG)

wave_decoder:
	cd test/decoder/sim_build && $(WAVE) dump.fst

coverage_decoder:
	cd test/decoder/sim_build && verilator_coverage --annotate . coverage.dat

# Reg-file

reg_file:
	cd test/reg_file && pytest tests_reg_file.py $(B_PYTEST_FLAG)

wave_reg_file:
	cd test/reg_file/sim_build && $(WAVE) dump.fst

coverage_reg_file:
	cd test/reg_file/sim_build && verilator_coverage --annotate . coverage.dat

# Reg-file-V2

reg_file_v2:
	cd test/reg_file_v2 && pytest tests_reg_file_v2.py $(B_PYTEST_FLAG)

wave_reg_file_v2:
	cd test/reg_file_v2/sim_build && $(WAVE) dump.fst

coverage_reg_file_v2:
	cd test/reg_file_v2/sim_build && verilator_coverage --annotate . coverage.dat

# Program-counter

program_counter:
	cd test/program_counter && pytest tests_program_counter.py $(B_PYTEST_FLAG)

wave_program_counter:
	cd test/program_counter/sim_build && $(WAVE) dump.fst

coverage_program_counter:
	cd test/program_counter/sim_build && verilator_coverage --annotate . coverage.dat

# CSR

csr:
	cd test/csr && pytest tests_csr.py $(B_PYTEST_FLAG)

wave_csr:
	cd test/csr/sim_build && $(WAVE) dump.fst

coverage_csr:
	cd test/csr/sim_build && verilator_coverage --annotate . coverage.dat

# Instruction-memory

inst_mem:
	cd test/inst_mem && pytest tests_inst_mem.py $(B_PYTEST_FLAG)

wave_inst_mem:
	cd test/inst_mem/sim_build && $(WAVE) dump.fst

coverage_inst_mem:
	cd test/inst_mem/sim_build && verilator_coverage --annotate . coverage.dat

# Data-memory

data_mem:
	cd test/data_mem && pytest tests_data_mem.py $(B_PYTEST_FLAG)

wave_data_mem:
	cd test/data_mem/sim_build && $(WAVE) dump.fst

coverage_data_mem:
	cd test/data_mem/sim_build && verilator_coverage --annotate . coverage.dat

# ALU

alu:
	cd test/ALU && pytest tests_alu.py $(B_PYTEST_FLAG)

wave_alu:
	cd test/ALU/sim_build && $(WAVE) dump.fst

coverage_alu:
	cd test/ALU/sim_build && verilator_coverage --annotate . coverage.dat

# Branch Logic

bl:
	cd test/branch_logic && pytest tests_branch_logic.py $(B_PYTEST_FLAG)

wave_bl:
	cd test/branch_logic/sim_build && $(WAVE) dump.fst

coverage_bl:
	cd test/branch_logic/sim_build && verilator_coverage --annotate . coverage.dat

# --------------------------------------------------------------------------------------- #

# RippleV - Multi-cycle

# run simulations with $(TC) hex
rvmc:
	cd test/RippleV_Mc && rm -rf coverage_per_test && pytest test_runner_RippleV_Mc.py -vvvk "tc_$(TC)" $(TOP_PYTEST_FLAG) -x -ra

wave_rvmc:
	cd test/RippleV_Mc/sim_build && $(WAVE) dump.fst

coverage_rvmc:
	cd test/RippleV_Mc/coverage_per_test && verilator_coverage --annotate . merged.dat

# --------------------------------------------------------------------------------------- #

# RippleV

rv:
	cd test/RippleV && rm -rf coverage_per_test && pytest test_runner_RippleV.py -vvvk "tc_$(TC)" $(TOP_PYTEST_FLAG) -x -ra

wave_rv:
	cd test/RippleV/sim_build && $(WAVE) dump.fst

coverage_rv: 
	cd test/RippleV/coverage_per_test && verilator_coverage --annotate . merged.dat

# --------------------------------------------------------------------------------------- #

# C

# generate .hex, .efl, .dump from .c & copy into a  new $(TC) directory
tc_gen:
	cd sw && make TC=tc_$(TC)

# delete $(TC) directory
tc_clean:
	cd data && rm -rf tc_$(TC)

# compile $(TC), a C code 
gcc: 
	cd sw/sw_tc && gcc tc_$(TC).c -o tc_$(TC) && ./tc_$(TC)

# clean leftovers
gcc_clean: 
	cd sw/sw_tc && rm -rf tc_$(TC)

# --------------------------------------------------------------------------------------- #

# RISCV-Tests

# Generate .elf, .hex, .dump in $(TC) directories for riscv-tests - ONLY NEED TO RUN ONCE

compile_rvtests:
	for test in /opt/riscv-tests/isa/rv32ui-p* /opt/riscv-tests/isa/rv32um-p*; do \
		    name=$${test##*-p-}; \
    		mkdir -p data/tc_$$name; \
			\
			riscv32-unknown-elf-objcopy \
        	-O verilog \
    		--only-section=.text \
    		--only-section=.rodata \
    		--only-section=.data \
			--verilog-data-width 4\
        	$$test data/tc_$$name/tc_$$name-imem.hex; \
			\
			riscv32-unknown-elf-objcopy \
        	-O verilog \
			--only-section=.data \
    		--only-section=.tohost \
    		--change-section-lma .data=0x00000000 \
    		--change-section-lma .tohost=0x00000040 \
			--verilog-data-width 4\
        	$$test data/tc_$$name/tc_$$name-dmem.hex; \
			\
			riscv32-unknown-elf-objdump -d -M no-aliases $$test > data/tc_$$name/tc_$$name.dump;\
	done

# clean $(TC) directories
clean_rvtests:
	for test in /opt/riscv-tests/isa/rv32ui-p* /opt/riscv-tests/isa/rv32um-p*; do \
		name=$${test##*-p-};\
		rm -rf data/tc_$$name; \
	done

