# Vars

WAVE ?= surfer
TC ?=

# Decoder

decoder:
	cd test/decoder && pytest test_runner_decoder.py -s

wave_decoder:
	cd test/decoder/sim_build && $(WAVE) dump.fst

coverage_decoder:
	cd test/decoder/sim_build && verilator_coverage --annotate . coverage.dat

# Reg-file

reg_file:
	cd test/reg_file && pytest tests_reg_file.py -s

wave_reg_file:
	cd test/reg_file/sim_build && $(WAVE) dump.fst

coverage_reg_file:
	cd test/reg_file/sim_build && verilator_coverage --annotate . coverage.dat

# Program-counter

program_counter:
	cd test/program_counter && pytest tests_program_counter.py -s

wave_program_counter:
	cd test/program_counter/sim_build && $(WAVE) dump.fst

coverage_program_counter:
	cd test/program_counter/sim_build && verilator_coverage --annotate . coverage.dat

# CSR

csr:
	cd test/csr && pytest tests_csr.py -vvvs

wave_csr:
	cd test/csr/sim_build && $(WAVE) dump.fst

coverage_csr:
	cd test/csr/sim_build && verilator_coverage --annotate . coverage.dat

# Instruction-memory

inst_mem:
	cd test/inst_mem && pytest tests_inst_mem.py -s

wave_inst_mem:
	cd test/inst_mem/sim_build && $(WAVE) dump.fst

coverage_inst_mem:
	cd test/inst_mem/sim_build && verilator_coverage --annotate . coverage.dat

# Data-memory

data_mem:
	cd test/data_mem && pytest tests_data_mem.py -s

wave_data_mem:
	cd test/data_mem/sim_build && $(WAVE) dump.fst

coverage_data_mem:
	cd test/data_mem/sim_build && verilator_coverage --annotate . coverage.dat

# ALU

alu:
	cd test/ALU && pytest tests_alu.py -s

wave_alu:
	cd test/ALU/sim_build && $(WAVE) dump.fst

coverage_alu:
	cd test/ALU/sim_build && verilator_coverage --annotate . coverage.dat

# --------------------------------------------------------------------------------------- #

# RippleV

# generate .hex, .efl, .dump from .c & copy into a  new $(TC) directory
tc_gen:
	cd sw && make TC=tc_$(TC)

# delete $(TC) directory
tc_clean:
	cd data && rm -rf tc_$(TC)

# run simulations with $(TC) hex
rvmc:
	cd test/RippleV_Mc && pytest test_runner_RippleV_Mc.py -vvvk "tc_$(TC)"

wave_rvmc:
	cd test/RippleV_Mc/sim_build && $(WAVE) dump.fst

coverage_rvmc:
	cd test/RippleV_Mc/sim_build && verilator_coverage --annotate . coverage.dat

# C

# compile $(TC), a C code 
gcc: 
	cd sw/sw_tc && gcc tc_$(TC).c -o tc_$(TC) && ./tc_$(TC)

# clean leftovers
gcc_clean: 
	cd sw/sw_tc && rm -rf tc_$(TC)


# Generate .elf, .hex, .dump in $(TC) directories for riscv-tests - ONLY NEED TO RUN ONCE

compile_rvtests:
	for test in /opt/riscv-tests/isa/rv32ui-p* /opt/riscv-tests/isa/rv32um-p*; do \
		    name=$${test##*-p-}; \
    		mkdir -p data/tc_$$name; \
			\
			riscv32-unknown-elf-objcopy \
        	-O verilog \
			--verilog-data-width 4\
        	$$test data/tc_$$name/tc_$$name.hex; \
			\
			riscv32-unknown-elf-objdump -d -M no-aliases $$test > data/tc_$$name/tc_$$name.dump;\
	done

# clean $(TC) directories
clean_rvtests:
	for test in /opt/riscv-tests/isa/rv32ui-p* /opt/riscv-tests/isa/rv32um-p*; do \
		name=$${test##*-p-};\
		rm -rf data/tc_$$name; \
	done