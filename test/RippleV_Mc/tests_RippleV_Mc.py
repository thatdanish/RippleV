import sys
from pathlib import Path
import random

import cocotb
from cocotb.types import LogicArray
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sys.path.insert(0, str(Path(__file__).parent.parent)+"/utils/")

from simulation import clk_, NextClockCycle, ResetTrigger

# Parameters

MAX_CLKS = 100
N_TESTS = 100

# Initialize inputs

async def init_inputs(dut):
    dut.ext_interrupt_i.value = 0
    dut.main_enable_i = 0

# Main test 

@cocotb.test()
async def test_top(dut):
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    await ResetTrigger(dut)
    
    await ClockCycles(dut.clk_i, 2)
    await NextClockCycle(dut)

    try:
        assert(dut.program_counter_inst.pc_o.value == LogicArray(4, 5))
    except:
        raise AssertionError("Incorrect Reset handler address")
    
    cocotb.pass_test()