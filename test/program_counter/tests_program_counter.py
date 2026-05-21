import os
import sys
import random
from pathlib import Path

import cocotb 
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sys.path.insert(0, str(Path(__file__).parent.parent)+"/sim/")

from simulation import NextClockCycle, clk_, ResetTrigger

# Parameters

MAX_CLOCK = 200
N_TESTS = 50

# Init-inputs

async def init_inputs(dut):
    dut.en_i.value = 0
    dut.pc_update_i.value = 0

# Smoke-test

@cocotb.test()
async def smoke_test(dut):

    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLOCK))
    await init_inputs(dut)
    await ResetTrigger(dut)
    await ClockCycles(dut.clk_i, 5)

    # Test
    for _ in range(N_TESTS):
        dut.en_i.value = 1
        value = random.getrandbits(5)
        dut.pc_update_i.value = value

        await RisingEdge(dut.clk_i) 
        dut.en_i.value = 0

        await NextClockCycle(dut)

        try:
            assert dut.pc_o.value == value
        except:
            raise AssertionError(f"Incorrect PC value --> Expected {value}, got {dut.pc_o.value}")
        
    await ClockCycles(dut.clk_i, 10)

    cocotb.pass_test()

def test_runner_program_counter():
    sim = os.getenv("SIM", "verilator")
    waves = os.getenv("WAVES", 1)

    sources = ["../../src/program_counter.sv"]
    
    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="program_counter",
        waves=waves,
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="program_counter",
        test_module="tests_program_counter",
        waves=waves
    )

if __name__ == "__main__":
    test_runner_program_counter()