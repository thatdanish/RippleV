import os
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from tests_decoder import *

from cocotb_tools.runner import get_runner

def test_runner_decoder():
    sim = os.getenv("SIM", "verilator")    
    waves = os.getenv("WAVES", 1)

    sources = ["../../src/all_pkgs.sv","../../src/decoder.sv"]
    
    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="decoder",
        waves=waves, 
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]

    )

    runner.test(
        hdl_toplevel="decoder",
        test_module="test_runner_decoder",
        waves=waves
    )

if __name__=="__main__":
    test_runner_decoder()