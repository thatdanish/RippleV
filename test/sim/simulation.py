from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles


# Clock generate

async def clk_(dut, CLOCKPERIOD:int, N_CLKS:int | float):
    clk = Clock(dut.clk_i, CLOCKPERIOD, "ns")
    clk.start()
    await ClockCycles(dut.clk_i, int(N_CLKS))
    clk.stop()

# Reset

async def ResetTrigger(dut, N_CLK:int | float):
    dut.rst_i.value = 0
    await ClockCycles(dut.clk_i, int(N_CLK))
    dut.rst_i.value = 1

# Next clk-cycle

async def NextClockCycle(dut):
    await RisingEdge(dut.clk_i)
    await Timer(1)