import os 
import sys 
import random
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent)+"/utils/")

import cocotb
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb_tools.runner import get_runner

from simulation import clk_, NextClockCycle, ResetTrigger

# Parameters

MAX_CLKS = 3000
N_TESTS = 1000

# Initialize inputs

async def init_inputs(dut):
    dut.en_i.value = 0
    dut.addr_i.value = 0

# Tests

@cocotb.test()
async def smoke_test(dut):

    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 5)

    data = []
    with open("../../../data/sample_instructions.data", "r") as file:
        for line in file:
            data.append(line.strip())
    
    # Tests
    for _ in range(N_TESTS):
        await RisingEdge(dut.clk_i)
        dut.en_i.value = 1
        addr = random.getrandbits(5)
        dut.addr_i.value = addr

        await NextClockCycle(dut)
        dut.en_i.value = 0

        try:
            assert data[addr] == dut.data_o.value
        except:
            raise AssertionError(f"Invalid read --> expected : {data[addr]}, got {dut.data_o.value}")
        
    await ClockCycles(dut.clk_i, 10)


def test_runner_inst_mem():
    sim = os.getenv("SIM", "verilator")
    waves = os.getenv("WAVES", 1)
    sources = ["../../src/inst_mem.sv"]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="inst_mem",
        waves=waves,
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="inst_mem",
        test_module="tests_inst_mem",
        waves=waves
    )

if __name__ == "__main__":
    test_runner_inst_mem()