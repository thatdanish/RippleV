import sys
from pathlib import Path

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.simulation import NextClockCycle, ResetTrigger, clk_

# Parameters

MAX_CLKS = 500
N_TESTS = 1
TO_HOST = 0x01FC>>2
RESULT = 0x0100>>2
RST_HND = 0x0000
INT_HND = 0x3FF8
SUCCESS = 0xCAFECAFE

# Initialize Inputs

async def init_inputs(dut):
    dut.ext_interrupt_i.value = 0
    dut.main_enable_i.value = 0

# Monitor TO HOST

async def monitor(dut):
    while True:
        await NextClockCycle(dut)

        if dut.data_mem_inst.dmem[TO_HOST].value == SUCCESS:
            cocotb.pass_test()

@cocotb.test()
async def run_test(dut):
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    monitor_to_host = cocotb.start_soon(monitor(dut))

    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 3)
    
    # Check Reset Handler Address
    try: 
        assert dut.pc_final.value == RST_HND
    except:
        raise AssertionError(f"Invalid RST_HND : expected : {RST_HND}, got : {dut.pc_final.value}")

    # Start Test
    dut.main_enable_i.value = 1
        
    await clk
    
    # If not passed till now, then fail
    raise AssertionError(f"Incorrect TO_HOST ({hex(TO_HOST)}) read --> exp : {hex(SUCCESS)}, got : {hex(dut.data_mem_inst.dmem[TO_HOST].value)}")
