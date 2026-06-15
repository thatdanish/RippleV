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
   
    DMEM_HEX_FILE_PATH = f"../../../data/{test_case}/{test_case}-dmem.hex"
    if os.path.exists(DMEM_HEX_FILE_PATH[3:]):
        IMEM_HEX_FILE_PATH = f"../../../data/{test_case}/{test_case}-imem.hex"
        LOAD_FROM_DMEM_HEX = 1
    else:
        IMEM_HEX_FILE_PATH = f"../../../data/{test_case}/{test_case}.hex"
        LOAD_FROM_DMEM_HEX = 0

    SOURCES = [
    "../../src/Opcodes_pkg.sv",
    "../../src/typed_pkg.sv",
    "../../src/RippleV_Mc.sv",
    "../../src/blocks/csr.sv",
    "../../src/blocks/ctrl_unit.sv",
    "../../src/blocks/data_mem.sv",
    "../../src/blocks/decoder.sv",
    "../../src/blocks/inst_mem.sv",
    "../../src/blocks/MUXs.sv",
    "../../src/blocks/program_counter.sv",
    "../../src/blocks/reg_file.sv",
    "../../src/blocks/temp_alu.sv"
    ]

    runner = get_runner(SIM)

    runner.build(
        sources=SOURCES,
        hdl_toplevel="RippleV_Mc",
        waves=WAVES,
        clean=True,
        parameters={"IMEM_FILE":f'"{IMEM_HEX_FILE_PATH}"', "DMEM_FILE":f'"{DMEM_HEX_FILE_PATH}"',
                    "LOAD_FROM_DMEM_HEX": LOAD_FROM_DMEM_HEX},     
        timescale=("1ns", "1ns"), 
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="RippleV_Mc",
        test_module="tests_RippleV_Mc", 
        parameters={"IMEM_FILE":f'"{IMEM_HEX_FILE_PATH}"', "DMEM_FILE":f'"{DMEM_HEX_FILE_PATH}"',
                    "LOAD_FROM_DMEM_HEX": LOAD_FROM_DMEM_HEX},    
        timescale=("1ns", "1ns"), 
        waves=WAVES
    )

if __name__ == "__main__":
    test_runner_RippleV_Mc()