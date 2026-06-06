import os 
import sys 
import random
from pathlib import Path
import math
sys.path.insert(0, str(Path(__file__).parent.parent))

import numpy as np
import cocotb
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.types import LogicArray, Logic
from cocotb_tools.runner import get_runner

from utils.simulation import NextClockCycle, ResetTrigger, clk_

# Parameters

MAX_CLKS = 10000
N_TESTS = 5000

# Init-inputs

async def init_inputs(dut):
    dut.en_i.value = 0
    dut.opr_i.value = 0
    dut.a_i.value = 0
    dut.b_i.value = 0

# ALU model

def model_ALU(a:LogicArray,b:LogicArray,opr:int) -> LogicArray | Logic :
    if opr == 0:
        #  ADD
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a + b, 33)
        return z[31:0]
    elif opr == 1: 
        #  SUB
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray.from_signed(a - b , 33)
        return z[31:0]
    elif opr == 2:
        # MUL
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a*b, 64)
        return z[31:0]
    elif opr == 3:
        # MULH
        a = a.to_signed()
        b = b.to_signed()
        z = LogicArray.from_signed(a*b, 64)
        return z[63:32]
    elif opr == 4:
        # MULHU
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a*b, 64)
        return z[63:32]
    elif opr == 5:
        # MULHSU
        a = a.to_unsigned()
        b = b.to_signed()
        z = LogicArray.from_signed(a*b, 64)
        return z[63:32]
    elif opr == 6:
        # DIV
        a = a.to_signed()
        b = b.to_signed()
        z = b/a
        if z >= 0:
            z = math.floor(z)
        else: 
            z = math.ceil(z)
        return LogicArray.from_signed(z, 32)
    elif opr == 7:
        # DIVU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return LogicArray(int(b/a), 32)
    elif opr == 8:
        # REM 
        a = a.to_signed()
        b = b.to_signed()
        if a < 0 and b >=0:
            a = a*-1
            z = LogicArray.from_signed(b%a, 32)
            return z
        if a > 0 and b < 0:
            b = b*-1
            z = LogicArray.from_signed(-1*(b%a), 32)
            return z
        z = LogicArray.from_signed(b%a, 32)
        return z
    elif opr == 9:
        # REMU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return LogicArray(int(b%a), 32)
    elif opr == 10:
        # SLT
        a = a.to_signed()
        b = b.to_signed()
        return LogicArray(b<a,32)
    elif opr == 11:
        # SLTU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return LogicArray(b<a,32)
    elif opr == 13:
        # AND
        return a & b
    elif opr == 14:
        # OR
        return a | b
    elif opr == 15:
        # XOR
        return a ^ b
    elif opr == 16:
        # SLL
        b = b.to_unsigned()
        a_shift = a[4:0]
        a_shift = a_shift.to_unsigned()
        z = LogicArray( b << a_shift, 32+a_shift)
        return z[31:0]
    elif opr == 17:
        # SRL
        a_shift = a[4:0].to_unsigned()
        b_unsigned = b.to_unsigned()
        return LogicArray(b_unsigned >> a_shift, 32)
    elif opr == 18:
        # SRA
        b = b.to_unsigned()
        a_shift = a[4:0]
        a_shift = a_shift.to_unsigned()
        return LogicArray( b >> a_shift, 32)
    elif opr == 19:
        # BEQ
        return a == b
    elif opr == 20:
        # BNE
        return a != b
    elif opr == 21:
        # BLT
        a = a.to_signed()
        b = b.to_signed()
        return Logic(b < a)
    elif opr == 22:
        # BLTU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return Logic(b < a)
    elif opr == 23:
        # BGE
        a = a.to_signed()
        b = b.to_signed()
        return Logic(b >= a)
    elif opr == 12:
        # BGEU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return Logic(b >= a)
    elif opr == 25:
        # JALR
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a + b, 33)
        z[0] = 0
        return z[31:0]
    else:
        raise NotImplementedError("Invalid operation error. {opr}")

# Computation-test

@cocotb.test()
async def compute_test(dut):

    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 10)
    
    cond_branch = [19, 20, 21, 22, 23, 12]

    for _ in range(N_TESTS):
        opr = random.randint(0,25)
             
        while opr == 24:
            opr = random.randint(0,25)

        a = LogicArray(random.getrandbits(32), 32)
        b = LogicArray(random.getrandbits(32), 32)

        dut.en_i.value = 1
        dut.a_i.value = a
        dut.b_i.value = b
        dut.opr_i.value = opr

        await NextClockCycle(dut)
        
        dut.en_i.value = 0
        
        res = model_ALU(a,b,opr)

        if opr in cond_branch:
            try:
                assert res == dut.take_branch_o.value
            except:
                    raise AssertionError(f"Opr : {opr} --> Invalid take_branch_o value\n"
                                        f"a : {a} ({int(a)}), b : {b} ({int(b)})")
        else:
            try:
                assert res == dut.out_o.value
            except:
                    raise AssertionError(f"Invalid Output value -->\n"
                                         f"Opr: {opr}, a : {a} ({a.to_unsigned()}), b : {b} ({b.to_unsigned()})\n"
                                         f"Expected : {res} (), got : {dut.out_o.value}")
        
def test_runner_alu():
    sim = os.getenv("SIM", "verilator")
    waves = os.getenv("WAVES", 1)
    sources = ["../../src/all_pkgs.sv", "../../src/temp_alu.sv"]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="temp_alu",
        waves=waves,
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="temp_alu",
        test_module="tests_alu",
        waves=waves
    )

if __name__ == "__main__":
    test_runner_alu()