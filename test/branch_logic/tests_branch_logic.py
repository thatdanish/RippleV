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
    dut.opr_i.value = 0
    dut.sign_ext_offset_i.value = 0
    dut.rs2_i.value = 0
    dut.rs1_i.value = 0
    dut.pc_i.value = 0

# Branch Logic Model

def model_BL(a:LogicArray,b:LogicArray,opr:str) -> LogicArray | Logic :
    if opr == "ALU_JAL":
        # JAL
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
    else:
        raise NotImplementedError(f"Invalid operation {opr}")
    
    # Test

@cocotb.test()
async def test(dut):
    
    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 10)

    ALL_ALU_operations = [ "ALU_ADD", "ALU_SUB", "ALU_MUL", "ALU_MULH", "ALU_MULHU", "ALU_MULHSU", "ALU_DIV", "ALU_DIVU", "ALU_REM",
                    "ALU_REMU", "ALU_SLT", "ALU_SLTU", "ALU_AND", "ALU_OR", "ALU_XOR", "ALU_SLL", "ALU_SRL", "ALU_SRA", "ALU_BEQ", "ALU_BNE", "ALU_BLT",
                    "ALU_BLTU", "ALU_BGE", "ALU_BGEU", "ALU_JAL", "ALU_JALR" ]

    VALID_ALU_operations = ["ALU_BEQ", "ALU_BNE", "ALU_BLT",
                "ALU_BLTU", "ALU_BGE", "ALU_BGEU", "ALU_JAL", "ALU_JALR" ]
    
    cond_branch = ["ALU_BEQ", "ALU_BNE", "ALU_BLT", "ALU_BLTU", "ALU_BGE", "ALU_BGEU"]


    for _ in range(N_TESTS):
        opr = random.choice(VALID_ALU_operations)

        a = LogicArray(random.getrandbits(32), 32)
        b = LogicArray(random.getrandbits(32), 32)

        dut.en_i.value = 1
        dut.sign_ext_offset_i.value = a
        dut.rs2_i.value = a
        dut.rs1_i.value = b
        dut.pc_i.value = b
        dut.opr_i.value = ALL_ALU_operations.index(opr)

        await NextClockCycle(dut)

        dut.en_i.value = 0

        res = model_BL(a,b,opr)

        if opr in cond_branch:
            try:
                assert res == dut.take_branch_o.value
            except:
                    raise AssertionError(f"Opr : {opr} --> Invalid take_branch_o value\n"
                                        f"a : {a} ({int(a)}), b : {b} ({int(b)})"
                                        f"Expected : {res} (), got : {dut.take_branch_o.value}")
        else:
            try:
                assert res == dut.pc_update_o.value
            except:
                    raise AssertionError(f"Invalid Output value -->\n"
                                            f"Opr: {opr}, a : {a} ({a.to_unsigned()}), b : {b} ({b.to_unsigned()})\n"
                                            f"Expected : {res} (), got : {dut.pc_update_o.value}")

def test_runner_bl():
    sim = os.getenv("SIM", "verilator")
    waves = os.getenv("WAVES", 1)
    sources = ["../../src/typed_pkg.sv", "../../src/blocks/BranchLogic.sv"]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="BranchLogic",
        waves=waves,
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="BranchLogic",
        test_module="tests_branch_logic",
        waves=waves
    )

if __name__ == "__main__":
    test_runner_bl()