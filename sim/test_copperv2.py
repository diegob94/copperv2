import logging

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb.log import SimLog
from cocotb.regression import TestFactory
from cocotb.result import TestSuccess, TestComplete

from testbench import Testbench
from riscv_utils import compile_test, crt0
from cocotb_utils import verilog_string, get_test_name, get_top_module


@cocotb.coroutine
async def basic_test(dut, instructions = None, expected_regfile = None):
    """ Copperv2 base test """

    iverilog_dump = get_top_module("iverilog_dump")
    iverilog_dump.test_name <= verilog_string(get_test_name())
    #SimLog("cocotb").setLevel(logging.DEBUG)

    elf = compile_test(crt0 + instructions)
    tb = Testbench(dut, elf, expected_regfile)

    tb.start_clock()
    await tb.do_reset()

    while not tb.finish():
        await RisingEdge(tb.clock)
    await ClockCycles(tb.clock,20)

tf = TestFactory(test_function=basic_test)
tf.add_option(('instructions', 'expected_regfile'), [
    ([ # lui
        "lui t0, 0x123",
    ],[
        "t0 0x123000",
    ]),
    ([ # addi
        "addi t0, zero, 0x123",
    ],[
        "t0 0x123",
    ]),
    ([ # add
        "add t0, zero, 12",
        "add t1, zero, 34",
        "add t2, t0, t1",
    ],[
        "t0 12",
        "t1 34",
        "t2 46",
    ]),
])
tf.generate_tests()
