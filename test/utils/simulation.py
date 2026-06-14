from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles, ReadOnly

# Parameters

CLOCKPERIOD = 10
N_CLKS = 5
MAX_CLKS = 150

# Clock generate

async def clk_(dut, MAX_CLKS:int | float = MAX_CLKS, CLOCKPERIOD:int = CLOCKPERIOD):
    clk = Clock(dut.clk_i, CLOCKPERIOD, "ns")
    clk.start()
    await ClockCycles(dut.clk_i, int(MAX_CLKS))
    clk.stop()

# Reset

async def ResetTrigger(dut, N_CLK:int | float = N_CLKS):
    dut.rst_i.value = 0
    await ClockCycles(dut.clk_i, int(N_CLK))
    dut.rst_i.value = 1

# Next clk-cycle

async def NextClockCycle(dut):
    await RisingEdge(dut.clk_i)
    await Timer(1)