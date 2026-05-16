PWD := $(shell pwd)

SIM = icarus

TOPLEVEL_LANG = verilog

VERILOG_SOURCES = $(PWD)/../../src/Opcodes_pkg.sv $(PWD)/../../src/decoder.sv

COCOTB_TOPLEVEL = decoder

COCOTB_TEST_MODULES = tests_decoder

WAVES = 1

include $(shell cocotb-config --makefiles)/Makefile.sim