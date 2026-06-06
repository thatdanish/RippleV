import sys
from pathlib import Path

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.simulation import NextClockCycle, ResetTrigger, clk_

# Parameters

MAX_CLKS = 10000
N_TESTS = 1
TO_HOST = 0x01FC
RST_HND = 0x0000
INT_HND = 0x3FF8
SUCCESS = 0xCAFECAFE

# Initialize Inputs

async def init_inputs(dut):
    dut.ext_interrupt_i.value = 0
    dut.main_enable_i.value = 0

@cocotb.test()
async def run_test(dut):
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))

    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 3)
    
    # Check Reset Handler Address
    try: 
        assert dut.pc_final.value == RST_HND
    except:
        raise AssertionError(f"Invalid RST_HND : expected : {RST_HND}, got : {dut.pc_final.value}")

    dut.main_enable_i.value = 1

    await ClockCycles(dut.clk_i, 200)
    
    try:
        assert dut.data_mem_inst.dmem[TO_HOST].value == SUCCESS
    except:
        raise AssertionError(f"Incorrect TO_HOST value. expected : {SUCCESS}, got : {dut.data_mem_inst.dmem[TO_HOST].value}")
    

    cocotb.pass_test()