
# test_my_design.py (simple)
import os
from pathlib import Path
import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, ClockCycles, FallingEdge, RisingEdge
from cocotb.clock import Clock

@cocotb.test()
async def basic_test(dut):
    c = Clock(dut.clk, 10, 'ns')
    await cocotb.start(c.start())
    dut.rstn.value = 0
    await ClockCycles(dut.clk,3)
    dut.rstn.value = 1
    await ClockCycles(dut.clk,3)
    dut.instr_opcode.value = 0x1b
    dut.instr_rd.value = 2
    dut.instr_rs1.value = 0
    dut.instr_imm.value = 33
    dut.instr_funct.value = 0x0
    dut.instr_valid.value = 1
    await RisingEdge(dut.clk)
    dut.instr_valid.value = 0
    await ClockCycles(dut.clk,3)

def test_my_design_runner():
    sim = os.getenv("SIM", "verilator")

    proj_path = Path(__file__).resolve().parent.parent

    sources = [
        proj_path / "rtl/execution_unit.sv"
    ]

    includes = [
        proj_path / "rtl"
    ]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        includes=includes,
        hdl_toplevel="execution_unit",
        timescale=("1ns","1ns"),
        waves=True,
        build_args=["--trace-fst"],
    )

    runner.test(
        hdl_toplevel="execution_unit", 
        test_module="test_execution_unit",
        waves=True,
    )
