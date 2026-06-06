import os
import pytest
from cocotb_tools.runner import get_runner

# Parameters

def get_test_cases():
    TC_DIR = "../../data/"
    tests = []
    for dname in sorted(os.listdir(TC_DIR)):
        if dname.startswith("tc_"):
            hex_file = os.path.join(TC_DIR, dname + f"/{dname}.hex")
            tests.append(pytest.param(hex_file, id=dname))

    return tests

@pytest.mark.parametrize("hex_file", get_test_cases())
def test_runner_RippleV_Mc(hex_file):

    SIM = os.getenv("SIM", "verilator")
    WAVES = os.getenv("WAVES", 1)

    SOURCES = [
    "../../src/csr.sv",
    "../../src/ctrl_unit.sv",
    "../../src/data_mem.sv",
    "../../src/decoder.sv",
    "../../src/housekeeper.sv",
    "../../src/inst_mem.sv",
    "../../src/MUXs.sv",
    "../../src/all_pkgs.sv",
    "../../src/program_counter.sv",
    "../../src/reg_file.sv",
    "../../src/RippleV_Mc.sv",
    "../../src/temp_alu.sv"
        ]

    runner = get_runner(SIM)

    runner.build(
        sources=SOURCES,
        hdl_toplevel="RippleV_Mc",
        waves=WAVES,
        clean=False,
        parameters={"FILE":f'"{hex_file}"'},      
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="RippleV_Mc",
        test_module="tests_RippleV_Mc", 
        parameters={"FILE":f'"{hex_file}"'}, 
        verbose=True,     
        waves=WAVES
    )

if __name__ == "__main__":
    test_runner_RippleV_Mc()