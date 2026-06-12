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
    if opr == "ALU_ADD":
        #  ADD
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a + b, 33)
        return z[31:0]
    elif opr == "ALU_SUB": 
        #  SUB
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray.from_signed(b-a , 33)
        return z[31:0]
    elif opr == "ALU_MUL":
        # MUL
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a*b, 64)
        return z[31:0]
    elif opr == "ALU_MULH":
        # MULH
        a = a.to_signed()
        b = b.to_signed()
        z = LogicArray.from_signed(a*b, 64)
        return z[63:32]
    elif opr == "ALU_MULHU":
        # MULHU
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a*b, 64)
        return z[63:32]
    elif opr == "ALU_MULHSU":
        # MULHSU
        a = a.to_unsigned()
        b = b.to_signed()
        z = LogicArray.from_signed(a*b, 64)
        return z[63:32]
    elif opr == "ALU_DIV":
        # DIV
        a = a.to_signed()
        b = b.to_signed()
        if (b == 0x80000000 and a == 0xFFFFFFFF):
            return LogicArray.from_signed(b, 32)
        elif (a == 0):
            return LogicArray.from_signed(-1, 32)
        else:
            z = b/a
            if z >= 0:
                z = math.floor(z)
            else: 
                z = math.ceil(z)
            return LogicArray.from_signed(z, 32)
    elif opr == "ALU_DIVU":
        # DIVU
        a = a.to_unsigned()
        b = b.to_unsigned()
        if (a == 0):
            return LogicArray.from_signed(-1, 32)
        else:
            return LogicArray(int(b/a), 32)
    elif opr == "ALU_REM":
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
    elif opr == "ALU_REMU":
        # REMU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return LogicArray(int(b%a), 32)
    elif opr == "ALU_SLT":
        # SLT
        a = a.to_signed()
        b = b.to_signed()
        return LogicArray(b<a,32)
    elif opr == "ALU_SLTU":
        # SLTU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return LogicArray(b<a,32)
    elif opr == "ALU_AND":
        # AND
        return a & b
    elif opr == "ALU_OR":
        # OR
        return a | b
    elif opr == "ALU_XOR":
        # XOR
        return a ^ b
    elif opr == "ALU_SLL":
        # SLL
        b = b.to_unsigned()
        a_shift = a[4:0]
        a_shift = a_shift.to_unsigned()
        z = LogicArray( b << a_shift, 32+a_shift)
        return z[31:0]
    elif opr == "ALU_SRL":
        # SRL
        a_shift = a[4:0].to_unsigned()
        b_unsigned = b.to_unsigned()
        return LogicArray(b_unsigned >> a_shift, 32)
    elif opr == "ALU_SRA":
        # SRA
        b = b.to_unsigned()
        a_shift = a[4:0]
        a_shift = a_shift.to_unsigned()
        return LogicArray( b >> a_shift, 32)
    elif opr == "ALU_BEQ":
        # BEQ
        return a == b
    elif opr == "ALU_BNE":
        # BNE
        return a != b
    elif opr == "ALU_BLT":
        # BLT
        a = a.to_signed()
        b = b.to_signed()
        return Logic(b < a)
    elif opr == "ALU_BLTU":
        # BLTU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return Logic(b < a)
    elif opr == "ALU_BGE":
        # BGE
        a = a.to_signed()
        b = b.to_signed()
        return Logic(b >= a)
    elif opr == "ALU_BGEU":
        # BGEU
        a = a.to_unsigned()
        b = b.to_unsigned()
        return Logic(b >= a)
    elif opr == "ALU_JAL":
        # JALR
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a + b - 4, 33)
        return z[31:0]
    elif opr == "ALU_JALR":
        # JALR
        a = a.to_unsigned()
        b = b.to_unsigned()
        z = LogicArray(a + b, 33)
        z[0] = 0
        return z[31:0]
    else:
        raise NotImplementedError(f"Invalid operation error. {opr}")

# Computation-test

@cocotb.test()
async def compute_test(dut):

    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 10)
    
    ALU_oprtions = [ "ALU_ADD", "ALU_SUB", "ALU_MUL", "ALU_MULH", "ALU_MULHU", "ALU_MULHSU", "ALU_DIV", "ALU_DIVU", "ALU_REM",
                    "ALU_REMU", "ALU_SLT", "ALU_SLTU", "ALU_AND", "ALU_OR", "ALU_XOR", "ALU_SLL", "ALU_SRL", "ALU_SRA", "ALU_BEQ", "ALU_BNE", "ALU_BLT",
                    "ALU_BLTU", "ALU_BGE", "ALU_BGEU", "ALU_JAL", "ALU_JALR" ]
    
    cond_branch = ["ALU_BEQ", "ALU_BNE", "ALU_BLT", "ALU_BLTU", "ALU_BGE", "ALU_BGEU"]

    for _ in range(N_TESTS):
        opr = random.choice(ALU_oprtions)
             
        a = LogicArray(random.getrandbits(32), 32)
        b = LogicArray(random.getrandbits(32), 32)

        dut.en_i.value = 1
        dut.a_i.value = a
        dut.b_i.value = b
        dut.opr_i.value = ALU_oprtions.index(opr)

        await NextClockCycle(dut)
        
        dut.en_i.value = 0
        
        res = model_ALU(a,b,opr)

        if opr in cond_branch:
            try:
                assert res == dut.take_branch_o.value
            except:
                    raise AssertionError(f"Opr : {opr} --> Invalid take_branch_o value\n"
                                        f"a : {a} ({int(a)}), b : {b} ({int(b)})"
                                        f"Expected : {res} (), got : {dut.take_branch_o.value}")
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
    sources = ["../../src/typed_pkg.sv", "../../src/temp_alu.sv"]

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