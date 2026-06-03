import subprocess
import os

def load_hex_to_imem(dut, hex_path: str):
    """Load hex file into instruction memory signal array."""
    with open(hex_path) as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        word = int(line.strip(), 16)
        dut.inst_mem_inst.int_inst_mem[i].value = word

def get_symbol_address(elf_path: str, symbol: str) -> int | None:
    """Use nm to get symbol address from ELF."""
    try:
        result = subprocess.run(
            ["riscv64-unknown-elf-nm", elf_path],
            capture_output=True, text=True, check=True
        )
        for line in result.stdout.splitlines():
            parts = line.split()
            if len(parts) == 3 and parts[2] == symbol:
                return int(parts[0], 16)
    except subprocess.CalledProcessError:
        return None
    return None

def addr_to_dmem_index(addr: int, dmem_base: int = 0x80000000) -> int:
    """Convert byte address to word index in dmem array."""
    return (addr - dmem_base) >> 2