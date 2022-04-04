import logging
import dataclasses
import os
from pathlib import Path
from itertools import repeat

import cocotb
from cocotb.triggers import Join, Event
from cocotb.log import SimLog
import toml
import cocotb_utils as utils

from testbench import Testbench
from riscv_utils import compile_instructions, parse_data_memory, compile_riscv_test

import pyuvm as uvm
from wb_adapter_uvm import WbAdapterTest

from bus import CoppervBusSourceBfm
from cocotbext.wishbone.monitor import WishboneSlave

root_dir = Path(__file__).resolve().parent.parent
sim_dir = root_dir/'sim'
toml_path = sim_dir/"tests/unit_tests.toml"
unit_tests = toml.loads(toml_path.read_text())

T_ADDR = 0x80000000
O_ADDR = 0x80000004
TC_ADDR = 0x80000008
T_PASS = 0x01000001
T_FAIL = 0x02000001

@dataclasses.dataclass
class TestParameters:
    name: str
    instructions: list = dataclasses.field(default_factory=list)
    expected_regfile_read: list = dataclasses.field(default_factory=list)
    expected_regfile_write: list = dataclasses.field(default_factory=list)
    expected_data_read: list = dataclasses.field(default_factory=list)
    expected_data_write: list = dataclasses.field(default_factory=list)
    data_memory: list = dataclasses.field(default_factory=list)
    def __repr__(self):
        p = '\n'.join([f"{k} = {repr(v)}" for k,v in dataclasses.asdict(self).items()])
        return '\n' + p

@cocotb.test(timeout_time=10,timeout_unit="us")
async def unit_test(dut):
    """ Copperv unit tests """
    test_name = os.environ['TEST_NAME']
    params = TestParameters(test_name,**unit_tests[test_name])
    SimLog("cocotb").setLevel(logging.DEBUG)

    instruction_memory = compile_instructions(params.instructions)
    data_memory = parse_data_memory(params.data_memory)
    tb = Testbench(dut,
        test_name,
        expected_data_read=params.expected_data_read,
        expected_data_write=params.expected_data_write,
        expected_regfile_read=params.expected_regfile_read,
        expected_regfile_write=params.expected_regfile_write,
        instruction_memory=instruction_memory,
        data_memory=data_memory)
    tb.bus_bfm.start_clock()
    await tb.bus_bfm.reset()
    await tb.finish()

@cocotb.test(timeout_time=100,timeout_unit="us")
async def riscv_test(dut):
    """ RISCV compliance tests """
    test_name = os.environ['TEST_NAME']
    asm_path = Path(os.environ['ASM_PATH'])
    SimLog("cocotb").setLevel(logging.DEBUG)

    instruction_memory, data_memory = compile_riscv_test(asm_path)
    tb = Testbench(dut,
        test_name,
        instruction_memory=instruction_memory,
        data_memory=data_memory,
        enable_self_checking=False,
        pass_fail_address = T_ADDR,
        pass_fail_values = {T_FAIL:False,T_PASS:True})

    tb.bus_bfm.start_clock()
    await tb.bus_bfm.reset()
    await tb.end_test.wait()

@cocotb.test(timeout_time=1,timeout_unit="us")
async def verify_wishbone_adapter_test(dut):
    """ Wishbone adapter tests """
    wbm = WishboneSlave(dut, "wb_monitor", dut.clock,
                 signals_dict={"cyc":  "wb_cyc",
                             "stb":  "wb_stb",
                             "we":   "wb_we",
                             "adr":  "wb_adr",
                             "datwr":"wb_datwr",
                             "datrd":"wb_datrd",
                             "ack":  "wb_ack" })
    bus_bfm = CoppervBusSourceBfm(
        clock=dut.clock,
        reset=dut.reset,
        entity=dut,
        prefix="bus_",
    )
    bus_bfm.start_clock()
    await bus_bfm.reset()
    #SimLog("bfm").setLevel(logging.DEBUG)
    uvm.ConfigDB().set(None, "*.wb_agent.*", "BFM", wb_bfm)
    uvm.ConfigDB().set(None, "*.bus_agent.*", "BFM", bus_bfm)
    await uvm.uvm_root().run_test(WbAdapterTest,keep_singletons=True)

@cocotb.test(timeout_time=1,timeout_unit="us")
async def wishbone_adapter_read_test(dut):
    """ Wishbone adapter read test """
    data = 101
    addr = 123
    datGen = repeat(data)
    SimLog("bfm").setLevel(logging.DEBUG)
    wbm = WishboneSlave(dut,"wb",dut.clock,datgen=datGen)
    bus_bfm = CoppervBusSourceBfm(clock=dut.clock,reset=dut.reset,entity=dut,prefix="bus_")
    bus_bfm.init()
    bus_bfm.start_clock()
    await bus_bfm.reset()
    monitor = cocotb.start_soon(utils.Combine(
        wbm.wait_for_recv(),
        utils.anext(bus_bfm.get_read_response()),
        utils.anext(bus_bfm.get_read_request())))
    cocotb.start_soon(bus_bfm.drive_ready(1))
    await bus_bfm.send_read_request(addr)
    wb_res, bus_resp_recv, bus_req_recv = await Join(monitor)
    assert wb_res[0].adr == addr
    assert wb_res[0].datrd == data
    assert bus_req_recv["addr"] == addr
    assert bus_resp_recv["data"] == data

@cocotb.test(timeout_time=1,timeout_unit="us")
async def wishbone_adapter_write_test(dut):
    """ Wishbone adapter write test """
    data = 101
    addr = 123
    strobe = 0b0100
    SimLog("bfm").setLevel(logging.DEBUG)
    wbm = WishboneSlave(dut,"wb",dut.clock)
    bus_bfm = CoppervBusSourceBfm(clock=dut.clock,reset=dut.reset,entity=dut,prefix="bus_")
    bus_bfm.init()
    bus_bfm.start_clock()
    await bus_bfm.reset()
    monitor = cocotb.start_soon(utils.Combine(
        wbm.wait_for_recv(),
        utils.anext(bus_bfm.get_write_response()),
        utils.anext(bus_bfm.get_write_request())))
    cocotb.start_soon(bus_bfm.drive_ready(1))
    await bus_bfm.send_write_request(data,addr,strobe)
    wb_res, bus_resp_recv, bus_req_recv = await Join(monitor)
    assert wb_res[0].adr == addr
    assert wb_res[0].datwr == data
    assert wb_res[0].sel == strobe
    assert wb_res[0].ack == True
    assert bus_req_recv["addr"] == addr
    assert bus_req_recv["data"] == data
    assert bus_req_recv["strobe"] == strobe
    assert bus_resp_recv["resp"] == 1
