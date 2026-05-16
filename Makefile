# Decoder

decoder:
	cd test/decoder && pytest test_runner_decoder.py -s

wave_decoder:
	cd test/decoder/sim_build && gtkwave decoder.fst