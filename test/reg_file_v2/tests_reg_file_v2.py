import os
import sys
from pathlib import Path
import random
import numpy as np

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb_tools.runner import get_runner
from cocotb.types import LogicArray

sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.simulation import NextClockCycle, ResetTrigger, clk_, read, write

# Parameters

MAX_CLOCKS = 11000
MAX_TEST = 5000

# Initialize inputs

async def init_inputs(dut):
    dut.write_en_i.value = 0
    dut.read_en_i.value = 0
    dut.rw_i.value = 0
    dut.rs1_addr_i.value = 0
    dut.rs2_addr_i.value = 0
    dut.rd_data_i.value = 0

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
        reg_file[addr] = LogicArray(0, 32)

    # Test
    for _ in range(MAX_TEST):
        rw = LogicArray.from_unsigned(random.randint(0,1), 1)
        rs1_addr = LogicArray.from_unsigned(random.getrandbits(5), 5)
        rs2_addr = LogicArray.from_unsigned(random.getrandbits(5), 5)
        rd_addr = LogicArray.from_unsigned(random.getrandbits(5), 5)
        rd_data = LogicArray.from_unsigned(random.getrandbits(32), 32)

        dut.rw_i.value = rw
        if rw == read:
            dut.read_en_i.value = 1
            dut.write_en_i.value = 0
        else: 
            dut.read_en_i.value = 0
            dut.write_en_i.value = 1
        dut.rs1_addr_i.value = rs1_addr
        dut.rs2_addr_i.value = rs2_addr
        dut.rd_addr_i.value = rd_addr
        dut.rd_data_i.value = rd_data

        await RisingEdge(dut.clk_i)
        dut.read_en_i.value = 0
        dut.write_en_i.value = 0
        await NextClockCycle(dut)

        int_regs_hw = np.array(dut.int_regs.value, dtype=str)
        int_regs_hw = np.flip(int_regs_hw).reshape(32,32)
        value_rd = "".join(list(np.flip(int_regs_hw[rd_addr])))
        value_rs1 = "".join(list(np.flip(int_regs_hw[rs1_addr])))
        value_rs2 = "".join(list(np.flip(int_regs_hw[rs2_addr])))
        
        if rw == write:
            # update ref-model
            if (rd_addr.to_unsigned() != 0):
                reg_file[rd_addr.to_unsigned()] = rd_data
            
            try:
                assert reg_file[rd_addr.to_unsigned()] == value_rd
            except:
                raise AssertionError ("Invalid write\n" \
                    f" Expected --> Addr : {rd_addr}, Data : {rd_data} ({rd_data.to_unsigned()})\n"
                    f" Got -->  Data : {value_rd} ")
        else: # read

            try:
                assert (LogicArray(reg_file[rs1_addr.to_unsigned()], 32) == value_rs1) and (LogicArray(reg_file[rs2_addr.to_unsigned()], 32) == value_rs2)
            except:
                raise AssertionError ("Invalid read\n" \
                    f" Expected --> RS1-Addr : {rs1_addr} ({rs1_addr.to_unsigned()}), Data : {LogicArray(reg_file[rs1_addr.to_unsigned()], 32)} ({reg_file[rs1_addr.to_unsigned()]})\n"
                    f" Got -->  Data : {value_rs1} \n"
                    f" Expected --> RS2-Addr : {rs2_addr} ({rs2_addr.to_unsigned()}), Data : {LogicArray(reg_file[rs2_addr.to_unsigned()], 32)} ({reg_file[rs2_addr.to_unsigned()]})\n"
                    f" Got -->  Data : {value_rs2} ")
    
    await ClockCycles(dut.clk_i, 10)
    cocotb.pass_test()

def test_runner_reg_file_v2():
    sim = os.getenv("SIM", "verilator")    
    waves = os.getenv("WAVES", 1)

    sources = ["../../src/typed_pkg.sv", "../../src/blocks/reg_file_v2.sv"]
    
    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="reg_file_v2",
        waves=waves,
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="reg_file_v2",
        test_module="tests_reg_file_v2",
        waves=waves
    )

if __name__=="__main__":
    test_runner_reg_file_v2()
