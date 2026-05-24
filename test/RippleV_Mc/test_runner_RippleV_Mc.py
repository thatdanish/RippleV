import os
from cocotb_tools.runner import get_runner

def test_runner_RippleV_Mc():
    sim = os.getenv("SIM", "verilator")
    waves = os.getenv("WAVES", 1)

    sources = [
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
        sources=sources,
        hdl_toplevel="RippleV_Mc",
        waves=waves,
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="RippleV_Mc",
        test_module="tests_RippleV_Mc",
        waves=waves
    )

if __name__ == "__main__":
    test_runner_RippleV_Mc()