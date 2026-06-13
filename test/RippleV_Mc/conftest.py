import pytest
import os
import shutil
import subprocess

COVERAGE_DIR = "coverage_per_test"

@pytest.fixture(autouse=True)
def per_test_coverage(request):
    """Copy coverage file after each test with unique name."""
    yield  # test runs here
    
    # After test completes, copy coverage file with test name
    test_name = request.node.name.replace('[', '_').replace(']', '')
    os.makedirs(COVERAGE_DIR, exist_ok=True)
    
    # Verilator default coverage output location
    cov_src = "sim_build/coverage.dat"
    cov_dst = f"{COVERAGE_DIR}/coverage_{test_name[23:]}.dat"
    
    if os.path.exists(cov_src):
        shutil.copy(cov_src, cov_dst)
        print(f"\nCoverage saved: {cov_dst}")
    else:
        print(f"\nWarning: coverage file not found at {cov_src}")

@pytest.fixture(scope='session', autouse=True)
def merge_coverage(request):
    """Merge all per-test coverage files after session ends."""
    yield  # all tests run here

    cov_files = [
        f"{COVERAGE_DIR}/{f}"
        for f in os.listdir(COVERAGE_DIR)
        if f.endswith('.dat')
    ]

    if not cov_files:
        print("\nNo coverage files found to merge.")
        return

    # Merge all into one
    subprocess.run([
        'verilator_coverage',
        '--write', f'{COVERAGE_DIR}/merged.dat',
        *cov_files
    ], check=True)