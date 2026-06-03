import os
import sys
from pathlib import Path
import random
import numpy as np

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sys.path.insert(0, str(Path(__file__).parent.parent)+"/utils/")

from simulation import *

# Parameters

MAX_CLOCKS = 3000
MAX_TEST = 1000

# Initialize inputs

async def init_inputs(dut):
    dut.en_i.value = 0
    dut.rw_i.value = 0
    dut.addr_i.value = 0
    dut.data_i.value = 0

# Read-write tests

@cocotb.test()
async def read_write_test(dut):

    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLOCKS))
    await init_inputs(dut)
    await ResetTrigger(dut)
    await ClockCycles(dut.clk_i, 5)

    # Reg-file model - initialized 
    reg_file = {}
    for addr in range(32):
        reg_file[addr] = 0

    # Test

    for _ in range(MAX_TEST):
        rw = random.randint(0,1)
        addr = random.getrandbits(5)
        addr_bin = format(addr, '05b')
        data = random.getrandbits(32)

        if addr != 0 and rw == 0:
            reg_file[addr] = data

        dut.en_i.value = 1
        dut.addr_i.value = addr
        dut.data_i.value = data
        dut.rw_i.value  = rw    
        await RisingEdge(dut.clk_i)
        dut.en_i.value = 0
        await NextClockCycle(dut)

        if rw == 0: 
            int_regs = np.array(dut.int_regs.value, dtype=str)
            int_regs = np.flip(int_regs).reshape(32,32)
            value = "".join(list(np.flip(int_regs[addr])))
            if addr != 0:
                try:
                    assert value == format(data, '032b')
                except:
                    raise AssertionError ("Invalid write\n" \
                    f" Expected --> Addr : {addr_bin} ({addr}), Data : {format(data, '032b')} ({data})\n"
                    f" Got -->  Data : {value} ")
            else: 
                assert value == format(0, '032b')
        else:
            try:
                assert dut.data_o.value == reg_file[addr]
            except:
                raise AssertionError ("Invalid read\n" \
                f"Expected --> Addr : {addr_bin} ({addr}) , Data : {reg_file[addr]}\n"
                f"Got --> Data : {dut.data_o.value}")
        
    await ClockCycles(dut.clk_i, 10)
    cocotb.pass_test()


def test_runner_reg_file():
    sim = os.getenv("SIM", "verilator")    
    waves = os.getenv("WAVES", 1)

    sources = ["../../src/Opcodes_pkg.sv", "../../src/reg_file.sv"]
    
    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="reg_file",
        waves=waves,
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="reg_file",
        test_module="tests_reg_file",
        waves=waves
    )

if __name__=="__main__":
    test_runner_reg_file()