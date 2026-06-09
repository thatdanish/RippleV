import os
import pytest
from cocotb_tools.runner import get_runner

# Parameters

def get_test_cases():
    TC_DIR = "../../data/"
    tests = []
    for dname in sorted(os.listdir(TC_DIR)):
        if dname.startswith("tc_"):
            test_case = os.path.join(f"{dname}")
            tests.append(pytest.param(test_case, id=dname))

    return tests

@pytest.mark.parametrize("test_case", get_test_cases())
def test_runner_RippleV_Mc(test_case):

    SIM = os.getenv("SIM", "verilator")
    WAVES = os.getenv("WAVES", 1)
    HEX_FILE_PATH = f"../../../data/{test_case}/{test_case}.hex"

    SOURCES = [
    "../../src/csr.sv",
    "../../src/ctrl_unit.sv",
    "../../src/data_mem.sv",
    "../../src/decoder.sv",
    "../../src/csr_ctrl.sv",
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
        clean=True,
        parameters={"FILE":f'"{HEX_FILE_PATH}"'},     
        timescale=("1ns", "1ns"), 
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="RippleV_Mc",
        test_module="tests_RippleV_Mc", 
        parameters={"FILE":f'"{HEX_FILE_PATH}"'}, 
        timescale=("1ns", "1ns"), 
        waves=WAVES
    )

if __name__ == "__main__":
    test_runner_RippleV_Mc()