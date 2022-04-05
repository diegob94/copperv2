import logging
import os
from pathlib import Path
from textwrap import dedent
from cocotb.log import SimLog

import pytest
from cocotb_test.simulator import run

from cocotb_utils import Bfm

import cocotb
from cocotb.triggers import Join, RisingEdge
from cocotb_utils import anext

root_dir = Path(__file__).resolve().parent.parent
work_dir = root_dir/'work/sim/test_testbench'
work_dir.mkdir(exist_ok=True,parents=True)

@pytest.fixture
def ready_valid_rtl():
    rtl = work_dir/"ready_valid.v"
    rtl.write_text(dedent("""
    `timescale 1ns/1ps
    module top(
        output clock,
        output reset,
        output ready,
        output valid,
        output [7:0] data
    );
    initial #1000;
    endmodule
    """))
    print("Generated",rtl)
    return rtl

#@cocotb.test(timeout_time=10,timeout_unit="us")
#async def run_ready_valid_bfm_test(dut):
#    """ ready/valid BFM test """
#    SimLog("bfm").setLevel(logging.DEBUG)
#    reference = 123
#    payload = dict(data = dut.data)
#    bfm = ReadyValidBfm(entity=dut,prefix=None,clock=dut.clock,payload=payload,reset=dut.reset)
#    bfm.start_clock()
#    await bfm.reset()
#    await bfm.drive_ready(1)
#    send_task = cocotb.start_soon(bfm.send_payload(data=reference))
#    received = await anext(bfm.recv_payload())
#    assert received['data'] == reference
#    await Join(send_task)
#    await RisingEdge(dut.clock)
#
#def test_ready_valid(ready_valid_rtl):
#    run(
#        verilog_sources=[ready_valid_rtl],
#        toplevel="top",
#        module="test_testbench",
#        waves = True,
#        sim_build=work_dir/'test_ready_valid',
#        testcase = "run_ready_valid_bfm_test",
#    )

