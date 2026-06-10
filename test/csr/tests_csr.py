import os
import sys
import random
from pathlib import Path

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.simulation import NextClockCycle, ResetTrigger, clk_

# Parameters

MAX_CLKS = 4000
N_TESTS = 2000

# Init-inputs

async def init_inputs(dut):
    dut.en_i.value = 0
    dut.write_type_i.value = 0
    dut.rw_i.value = 0
    dut.ext_interrupt_i.value = 0
    dut.csr_addr_i.value = 0
    dut.new_data_i.value = 0

# Smoke-test

@cocotb.test()
async def smoke_test(dut):

    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 5)

    # Test
    addr_write_csrs = {"mhartid": 0xF14, "mstatus" : 0x300, "mepc": 0x341, "mcause": 0x342, "mtvec":0x305}
    addr_read_csrs = {"stvec": 0x105, "satp": 0x180, "mhartid": 0xF14, "mstatus" : 0x300, "medeleg":0x302, "mideleg":0x303,
                       "mie":0x304,  "mepc": 0x341, "mcause": 0x342, "mtvec":0x305, "mnstatus":0x744, "pmpcfg0":0x3A0, "pmpaddr0":0x3B0}
    data_csrs = {"stvec": 0, "satp": 0, "mhartid": 0, "mstatus" : 0, "medeleg":0, "mideleg":0,
                    "mie":0,  "mepc": 0, "mcause": 0, "mtvec":0, "mnstatus":0, "pmpcfg0":0, "pmpaddr0":0}

    for _ in range(N_TESTS):
        rw = random.randint(0,1)
        
        dut.en_i.value = 1
        dut.rw_i.value = rw
        # read
        if rw: 
            choice = random.choice(list(addr_read_csrs.keys()))
            addr = addr_read_csrs[choice]
            dut.csr_addr_i.value = addr

            await RisingEdge(dut.clk_i)
            dut.en_i.value = 0

            await NextClockCycle(dut)

            try:
                assert int(dut.csr_data_o.value) == data_csrs[choice]
            except:
                raise AssertionError(f"Invalid read --> {choice} : expected : {format(data_csrs[choice], '032b')}({data_csrs[choice]}), \n"
                                     f"got : {dut.csr_data_o.value}")
  
        # write
        else:
            choice = random.choice(list(addr_write_csrs.keys()))
            addr = addr_write_csrs[choice]
            dut.csr_addr_i.value = addr
            data = random.getrandbits(5)
            dut.new_data_i.value = data

            await RisingEdge(dut.clk_i)
            dut.en_i.value = 0
            data_csrs[choice] = data

    await ClockCycles(dut.clk_i, 5)
    
    # Interrupt
    dut.ext_interrupt_i.value = 1 
    await NextClockCycle(dut)
    try:
        assert dut.interrupt_status_o.value == 1
    except:
        raise AssertionError("Interrupt status not asserted")
    

    await ClockCycles(dut.clk_i,10)
    cocotb.pass_test()


def test_runner_csr():
    sim = os.getenv("SIM", "verilator")            
    waves = os.getenv("WAVES", True)            

    sources = ["../../src/all_pkgs.sv", "../../src/csr.sv"]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="csr",
        waves=waves, 
        clean=True,
        parameters={"B_TEST": 1},
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs", "--timing"]
    )

    runner.test(
        hdl_toplevel="csr",
        test_module="tests_csr",
        parameters={"B_TEST": 1},
        waves=waves
    )

if __name__ == "__main__":
    test_runner_csr()