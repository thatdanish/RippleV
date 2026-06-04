import os 
import sys 
import random
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent)+"/utils/")

import cocotb
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.types import LogicArray
from cocotb_tools.runner import get_runner

from simulation import clk_, NextClockCycle, ResetTrigger

# Parameters

MAX_CLKS = 13000
N_TESTS = 6000
MAX_ADDR_RANGE = 16384

data_mem_dict = {}
for i in range(0, MAX_ADDR_RANGE, 4):
    data_mem_dict[i] = 0

# Initialize Inputs

async def init_inputs(dut):
    dut.en_i.value = 0
    dut.rw_i.value = 0
    dut.transfer_type_i.value = 0
    dut.addr_i.value = 0
    dut.data_i.value = 0

# Data mem model

def data_mem_model(data=0, addr=0, transfer=0, READ=False):
    
    # Read 
    if READ:
        # byte
        if transfer == 0:
            if (addr >> 2) % 4 == 0:
                data_to_send = LogicArray(0, 32)
                data_ = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
                data_to_send[7:0] = data_[7:0]
                return data_to_send
            elif (addr >> 2) % 4 == 1:
                data_to_send = LogicArray(0, 32)
                data_ = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
                data_to_send[7:0] = data_[15:8]
                return data_to_send
            elif (addr >> 2) % 4 == 2:
                data_to_send = LogicArray(0, 32)
                data_ = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
                data_to_send[7:0] = data_[23:16]
                return data_to_send
            else:
                data_to_send = LogicArray(0, 32)
                data_ = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
                data_to_send[7:0] = data_[31:24]
                return data_to_send
        # hex_byte
        elif transfer == 1:
            if (addr >> 2) % 4 == 0:
                data_to_send = LogicArray(0, 32)
                data_ = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
                data_to_send[15:0] = data_[15:0]
                return data_to_send
            elif (addr >> 2) % 4 == 2:
                data_to_send = LogicArray(0, 32)
                data_ = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
                data_to_send[15:0] = data_[31:16]
                return data_to_send
            else: 
                AssertionError(f"Addr : {addr}, addr >> 2 : {addr >> 2}, addr >> 2 % 4 : {(addr >> 2)%4}")
        # word
        else:
            return LogicArray.from_unsigned(data_mem_dict[(addr >> 2)], 32)

    # Write-byte
    if transfer == 0: 
        if (addr  >> 2) % 4 == 0:
            data_to_store = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
            data_ = LogicArray(data, 32)
            data_to_store[7:0] =  data_[7:0]
            data_mem_dict[(addr >> 2)-((addr >> 2) % 4)] = data_to_store.to_unsigned()
        elif (addr  >> 2) % 4 == 1:
            data_to_store = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
            data_ = LogicArray(data, 32)
            data_to_store[15:8] =  data_[7:0]
            data_mem_dict[(addr >> 2)-((addr >> 2) % 4)] = data_to_store.to_unsigned()
        elif (addr  >> 2) % 4 == 2:
            data_to_store = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
            data_ = LogicArray(data, 32)
            data_to_store[23:16] =  data_[7:0]
            data_mem_dict[(addr >> 2)-((addr >> 2) % 4)] = data_to_store.to_unsigned()
        else:
            data_to_store = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
            data_ = LogicArray(data, 32)
            data_to_store[31:24] =  data_[7:0]
            data_mem_dict[(addr >> 2)-((addr >> 2) % 4)] = data_to_store.to_unsigned()
    # hex_byte
    elif transfer == 1:
        if (addr >> 2) % 4 == 0:
            data_to_store = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
            data_ = LogicArray(data, 32)
            data_to_store[15:0] =  data_[15:0]
            data_mem_dict[(addr >> 2)-((addr >> 2) % 4)] = data_to_store.to_unsigned()
        elif (addr >> 2) % 4 == 2:
            data_to_store = LogicArray.from_unsigned(data_mem_dict[(addr >> 2)-((addr >> 2) % 4)], 32)
            data_ = LogicArray(data, 32)
            data_to_store[31:16] =  data_[15:0]
            data_mem_dict[(addr >> 2)-((addr >> 2) % 4)] = data_to_store.to_unsigned()
        else:
            raise AssertionError(f"Addr : {addr}, addr >> 2 : {addr >> 2}, addr >> 2 % 4 : {(addr >> 2)%4}")
    # word
    else:
        data_mem_dict[(addr >> 2)] = data

# Smoke test

@cocotb.test()
async def smoke_test(dut):
    
    # Setup
    clk = cocotb.start_soon(clk_(dut, MAX_CLKS))
    await init_inputs(dut)
    await ResetTrigger(dut)

    await ClockCycles(dut.clk_i, 5)

    # write
    for _ in range(int(N_TESTS/2)):
        await RisingEdge(dut.clk_i)

        addr = random.randint(0, MAX_ADDR_RANGE-1) 
        
        if (addr >> 2) % 4 == 0:
            transfer = random.randint(0,2)
        elif (addr >> 2) % 2 == 0:
            transfer = random.randint(0,1)
        else:
            transfer = 0

        data = random.getrandbits(32)
        
        data_mem_model(data, addr, transfer)

        dut.en_i.value = 1
        dut.rw_i.value = 0 
        dut.addr_i.value = addr
        dut.data_i.value = data
        dut.transfer_type_i.value = transfer


        await NextClockCycle(dut)
        dut.en_i.value = 0

        # cocotb.log.info("SPACE")
        # cocotb.log.info(f"Address : {addr}, actual address : {(addr >> 2) - (addr >> 2)%4}, transfer : {transfer},  addr >> 2%4 : {(addr >> 2)%4}, addr >> 2 %2 : {(addr >> 2) %2}")
        # cocotb.log.info(f"Expected data mem : {LogicArray.from_unsigned(data_mem_dict[(addr >> 2) - (addr >> 2)%4], 32)}")
        # cocotb.log.info(f"Hardware data mem : {dut.int_data_mem[(addr >> 2) - (addr >> 2)%4].value}")

    # read
    dut.data_i.value = 0
    for _ in range(int(N_TESTS/2)):
        
        addr = random.randint(0, MAX_ADDR_RANGE-1)  
        
        if (addr >> 2) % 4 == 0:
            transfer = random.randint(0,2)
        elif (addr >> 2) % 2 == 0:
            transfer = random.randint(0,1)
        else:
            transfer = 0

        dut.en_i.value = 1
        dut.rw_i.value = 1 
        dut.addr_i.value = addr
        dut.transfer_type_i.value = transfer
        
        await RisingEdge(dut.clk_i)

        dut.en_i.value = 0
        await NextClockCycle(dut)
        
        expected_value = data_mem_model(transfer=transfer, addr=addr, READ=True)
        try: 
            assert expected_value == dut.data_o.value
        except:
            cocotb.log.info(f"Address : {addr}, actual address : {(addr >> 2) - (addr >> 2)%4}, transfer : {transfer},  addr >> 2%4 : {(addr >> 2)%4}, addr >> 2 %2 : {(addr >> 2) %2}")
            cocotb.log.info(f"Expected data mem : {LogicArray.from_unsigned(data_mem_dict[(addr >> 2) - (addr >> 2)%4], 32)}")
            cocotb.log.info(f"Hardware data mem : {dut.int_data_mem[(addr >> 2) - (addr >> 2)%4].value}")
            raise AssertionError(f"Invalid read --> ADDR {addr} expected : {expected_value}, got : {dut.data_o.value}")

def test_runner_data_mem():
    
    sim = os.getenv("SIM", "verilator")
    waves = os.getenv("WAVES", 1)
    sources = ["../../src/all_pkgs.sv", "../../src/data_mem.sv"]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="data_mem",
        waves=waves,
        clean=True,
        build_args=["--coverage", "--trace", "--trace-fst", "--trace-structs"]
    )

    runner.test(
        hdl_toplevel="data_mem",
        test_module="tests_data_mem",
        waves=waves
    )

if __name__ == "__main__":
    test_runner_data_mem()