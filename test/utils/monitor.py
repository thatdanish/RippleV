import cocotb
from cocotb.triggers import RisingEdge, Timer

async def wait_for_tohost(dut, tohost_idx: int, timeout_cycles: int = 100_000):
    """
    Poll dmem[tohost_idx] each cycle.
    Returns (passed: bool, value: int)
    """
    for cycle in range(timeout_cycles):
        await RisingEdge(dut.clk_i)
        val = int(dut.data_mem_inst.int_data_mem[tohost_idx].value) 
        if val != 0:
            passed = (val == 1)
            return passed, val
    return False, -1 