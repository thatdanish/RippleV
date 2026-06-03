import pytest
import subprocess
import os

ISA_TESTS_DIR = os.environ.get("RISCV_TESTS_DIR", "/path/to/riscv-tests/isa")
HEX_OUT_DIR = "/tmp/riscv_hex"

def pytest_configure(config):
    os.makedirs(HEX_OUT_DIR, exist_ok=True)

def elf_to_hex(elf_path: str, out_hex: str):
    """Convert ELF -> binary -> word-per-line hex."""
    bin_path = out_hex.replace(".hex", ".bin")
    subprocess.run(
        ["riscv64-unknown-elf-objcopy", "-O", "binary", elf_path, bin_path],
        check=True
    )
    with open(bin_path, "rb") as f:
        data = f.read()
    # Pad to word boundary
    while len(data) % 4:
        data += b'\x00'
    with open(out_hex, "w") as f:
        for i in range(0, len(data), 4):
            word = int.from_bytes(data[i:i+4], "little")
            f.write(f"{word:08x}\n")

@pytest.fixture(scope="session")
def riscv_test_elfs():
    """Return list of (name, elf_path, hex_path) for rv32ui-p tests."""
    tests = []
    for fname in sorted(os.listdir(ISA_TESTS_DIR)):
        if fname.startswith("rv32ui-p-") and "." not in fname:
            elf = os.path.join(ISA_TESTS_DIR, fname)
            hex_path = os.path.join(HEX_OUT_DIR, fname + ".hex")
            elf_to_hex(elf, hex_path)
            tests.append((fname, elf, hex_path))
    return tests