# Decoder

decoder:
	cd test/decoder && pytest test_runner_decoder.py -s

wave_decoder:
	cd test/decoder/sim_build && gtkwave decoder.fst


# Reg-file

reg_file:
	cd test/reg_file && pytest tests_reg_file.py -s

wave_reg_file:
	cd test/reg_file/sim_build && gtkwave reg_file.fst

# Program-counter

program_counter:
	cd test/program_counter && pytest tests_program_counter.py -s

wave_program_counter:
	cd test/program_counter/sim_build && gtkwave program_counter.fst

# CSR

csr:
	cd test/csr && pytest tests_csr.py -s

wave_csr:
	cd test/csr/sim_build && gtkwave csr.fst

# Instruction-memory

inst_mem:
	cd test/inst_mem && pytest tests_inst_mem.py -s

wave_inst_mem:
	cd test/inst_mem/sim_build && gtkwave inst_mem.fst

# Data-memory

data_mem:
	cd test/data_mem && pytest tests_data_mem.py -s

wave_data_mem:
	cd test/data_mem/sim_build && gtkwave data_mem.fst

# ALU

alu:
	cd test/ALU && pytest tests_alu.py -s

wave_alu:
	cd test/ALU/sim_build && gtkwave temp_alu.fst