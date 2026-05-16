
import sys
from pathlib import Path
import random
import cocotb
from cocotb.triggers import ClockCycles, RisingEdge

sys.path.insert(0,  str(Path(__file__).parent.parent)+"/sim/")
from simulation import clk_, ResetTrigger, NextClockCycle


# Parameters

CLOCKPERIOD = 10
MAX_CLOCKS = 140
N_TESTS = 50

# Initialize-inputs

async def init_inputs(dut):
    dut.inst_i.value = 0

# smoke-test

@cocotb.test()
async def smoketest(dut):
    
    # Setup
    clk = cocotb.start_soon(clk_(dut, CLOCKPERIOD, MAX_CLOCKS/2))
    await init_inputs(dut)
    await ResetTrigger(dut, 5)
    await ClockCycles(dut.clk_i, 3)

    # Probe
    for _ in range(N_TESTS):
        inst = random.getrandbits(32)
        inst_bin = format(inst, '032b')[::-1]
        dut.inst_i.value = inst

        await NextClockCycle(dut)
        
        try:
            assert dut.rd_o.value == ''.join(reversed(inst_bin[7:12]))
        except:
            raise AssertionError(f"expected Rd : {''.join(reversed(inst_bin[7:12]))}, got : {dut.rd_o.value}")
        try:
            assert dut.rs1_o.value == ''.join(reversed(inst_bin[15:20]))
        except:
            raise AssertionError(f"expected Rs1 : {''.join(reversed(inst_bin[15:20]))}, got : {dut.rs1_o.value}")
        try:
            assert dut.rs2_o.value == ''.join(reversed(inst_bin[20:25]))
        except:
            raise AssertionError(f"expected Rs2 : {''.join(reversed(inst_bin[20:25]))}, got : {dut.rs2_o.value}")
        try:
             assert dut.lui_o.value[31:12] == ''.join(reversed(inst_bin[12:32]))
        except:
            raise AssertionError(f"expected LUI [12:31] : {''.join(reversed(inst_bin[12:32]))}, got : {dut.lui_o.value[31:12]}"
                                 f"LUI : {dut.lui_o.value}")   
        try:
            assert (((inst_bin[31] == '1' and dut.imm_offset_o.value[31] == 1) or (inst_bin[31] == '0' and dut.imm_offset_o.value[31] == 0)) and dut.imm_offset_o.value[11:0] == "".join(reversed(inst_bin[20:32])))
        except:
            raise AssertionError(f"instruction: {inst_bin}, dut.imm_offset_o.value : {dut.imm_offset_o.value}\n"
                                 f"expected Imm/Offset[11:0]: {"".join(reversed(inst_bin[20:32]))}, got : {dut.imm_offset_o.value[11:0]}")
      
    await ClockCycles(dut.clk_i, 5)
    cocotb.pass_test()