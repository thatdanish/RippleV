import os 
import sys 
import random
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import cocotb
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.types import LogicArray
from cocotb_tools.runner import get_runner

from utils.simulation import NextClockCycle, ResetTrigger, clk_

# Parameters

MAX_CLKS = 13000
N_TESTS = 6000
MAX_ADDR_RANGE = 16384
FILE = "../../../data/sample/sample_instructions.hex"

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
    with open(FILE, "r") as file:
        for line in file:
            data.append(hex(int(line.strip(), 16)))
    
    # Tests
    for _ in range(N_TESTS):
        await RisingEdge(dut.clk_i)
        dut.en_i.value = 1
        addr = random.randint(0, MAX_ADDR_RANGE-1)
        dut.addr_i.value = addr

        await NextClockCycle(dut)
        dut.en_i.value = 0

        try:
            assert data[addr >> 2] == hex(LogicArray(dut.data_o.value, 32))
        except:
            raise AssertionError(f"Invalid read --> expected : {data[addr >> 2]}, got {dut.data_o.value}")
        
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
        parameters={"FILE":f'"{FILE}"'},  
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="inst_mem",
        test_module="tests_inst_mem",
        parameters={"FILE":f'"{FILE}"'},  
        waves=waves
    )

if __name__ == "__main__":
    test_runner_inst_mem()