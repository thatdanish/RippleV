import pytest
import os
from cocotb_tools.runner import get_runner

# Parameters

ISA_TESTS_DIR = os.environ.get("RISCV_TESTS_DIR", "/opt/riscv-tests/isa")
HEX_OUT_DIR = "/tmp/riscv_hex"

def get_rv32ui_tests():
    os.makedirs(HEX_OUT_DIR, exist_ok=True)
    tests = []
    for fname in sorted(os.listdir(ISA_TESTS_DIR)):
        if fname.startswith("rv32ui-p-") and "." not in fname:
            elf = os.path.join(ISA_TESTS_DIR, fname)
            hex_path = os.path.join(HEX_OUT_DIR, fname + ".hex")
            tests.append(pytest.param(fname, elf, hex_path, id=fname))
    return tests

@pytest.mark.parametrize("test_name,elf_path,hex_path", get_rv32ui_tests())
def test_runner_RippleV_Mc(test_name, elf_path, hex_path):
    # Convert ELF to hex before simulation
    from conftest import elf_to_hex
    elf_to_hex(elf_path, hex_path)

    os.environ["TEST_HEX"] = hex_path
    os.environ["TEST_ELF"] = elf_path

    sim = os.getenv("SIM", "verilator")
    waves = os.getenv("WAVES", 1)

    SOURCES = [
    "../../src/csr.sv",
    "../../src/ctrl_unit.sv",
    "../../src/data_mem.sv",
    "../../src/decoder.sv",
    "../../src/housekeeper.sv",
    "../../src/inst_mem.sv",
    "../../src/MUXs.sv",
    "../../src/Opcodes_pkg.sv",
    "../../src/program_counter.sv",
    "../../src/reg_file.sv",
    "../../src/RippleV_Mc.sv",
    "../../src/sel_pkg.sv",
    "../../src/temp_alu.sv",
    ]

    runner = get_runner(sim)

    runner.build(
        sources=SOURCES,
        hdl_toplevel="RippleV_Mc",
        waves=waves,
        clean=False,         
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="RippleV_Mc",
        test_module="tests_RippleV_Mc", 
        waves=waves
    )

if __name__ == "__main__":
    test_runner_RippleV_Mc()