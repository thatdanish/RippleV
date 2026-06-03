import os
import sys
from pathlib import Path

import pytest
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb_tools.runner import get_runner

sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.loader import load_hex_to_imem, get_symbol_address, addr_to_dmem_index
from utils.monitor import wait_for_tohost

# Parameters

DMEM_BASE = 0x80000000



@cocotb.test()
async def run_riscv_test(dut):
    hex_path = os.environ["TEST_HEX"]
    elf_path = os.environ["TEST_ELF"]

    tohost_addr = get_symbol_address(elf_path, "tohost")
    assert tohost_addr is not None, f"tohost symbol not found in {elf_path}"
    tohost_idx = addr_to_dmem_index(tohost_addr, DMEM_BASE)

    dut.rst_i.value = 0
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())
    await Timer(50, unit="ns")

    load_hex_to_imem(dut, hex_path)

    dut.rst_i.value = 1

    passed, val = await wait_for_tohost(dut, tohost_idx)
    assert passed, f"Test FAILED: tohost=0x{val:08x}, failing case={(val >> 1) & 0xFFFF}"


