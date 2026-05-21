import os 
import sys 
import random
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent)+"/sim/")

import cocotb
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb_tools.runner import get_runner

from simulation import clk_, NextClockCycle, ResetTrigger

# Parameters

MAX_CLKS = 5000
N_TESTS = 2000

# Initialize Inputs

async def init_inputs(dut):
    dut.en_i.value = 0
    dut.rw_i.value = 0
    dut.addr_i.value = 0
    dut.data_i.value = 0

# Smoke test

@cocotb.test()
async def smoke_test(dut):
    
    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 5)

    data_mem_model = {}
    
    # write
    for _ in range(int(N_TESTS/2)):
        await RisingEdge(dut.clk_i)
        dut.en_i.value = 1
        dut.rw_i.value = 0 
        addr = random.getrandbits(5)
        data = random.getrandbits(32)
        dut.addr_i.value = addr
        dut.data_i.value = data

        data_mem_model[addr] = data

        await NextClockCycle(dut)
        dut.en_i.value = 0

    # read
    dut.data_i.value = 0
    for _ in range(int(N_TESTS/2)):
        dut.en_i.value = 1
        dut.rw_i.value = 1 
        addr = random.choice(list(data_mem_model.keys()))
        dut.addr_i.value = addr
        await RisingEdge(dut.clk_i)

        dut.en_i.value = 0
        await NextClockCycle(dut)

        try: 
            assert data_mem_model[addr] == dut.data_o.value
        except:
            raise AssertionError(f"Invalid read --> ADDR {addr} expected : {data_mem_model[addr]}, got : {dut.data_o.value}")

def test_data_mem():
    
    sim = os.getenv("SIM", "icarus")
    waves = os.getenv("WAVES", 1)
    sources = ["../../src/Opcodes_pkg.sv", "../../src/data_mem.sv"]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="data_mem",
        waves=waves
    )

    runner.test(
        hdl_toplevel="data_mem",
        test_module="tests_data_mem",
        waves=waves
    )

if __name__ == "__main__":
    test_data_mem()