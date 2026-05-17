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