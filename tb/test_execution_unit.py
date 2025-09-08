
# test_my_design.py (simple)
import os
from pathlib import Path
import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, ClockCycles, FallingEdge, RisingEdge
from cocotb.clock import Clock
from rvi import Opcode, StoreFunct, OpImmFunct, Reg, LoadFunct
from cocotb.types import concat,LogicArray,Range
from cocotb.result import TestSuccess

def encode_instr(opcode,rs1,imm,funct,rd=None,rs2=None):
    instr = LogicArray(range=Range(31,0))
    opcode_la = LogicArray(opcode,Range(6,0))
    rd_la     = LogicArray(rd,Range(4,0))
    funct_la  = LogicArray(funct,Range(9,0))
    rs1_la    = LogicArray(rs1,Range(4,0))
    rs2_la    = LogicArray(rs2,Range(4,0))
    imm_la    = LogicArray(imm,Range(11,0))
    instr[6:0] = opcode_la
    if opcode == Opcode.OP_IMM_32 or opcode == Opcode.LOAD:
        assert rd is not None
        instr[11:7]  = rd_la
        instr[14:12] = funct_la[2:0]
        instr[19:15] = rs1_la
        instr[31:20] = imm_la
    elif opcode == Opcode.STORE:
        assert rs2 is not None
        instr[11:7]  = imm_la[4:0]
        instr[14:12] = funct_la[2:0]
        instr[19:15] = rs1_la
        instr[24:20] = rs2_la
        instr[31:25] = imm_la[11:5]
    return instr

def test_encode_instr():
    assert encode_instr(
        opcode=Opcode.OP_IMM_32,
        rd=Reg.x2,
        rs1=Reg.x5,
        funct=OpImmFunct.ADDI,
        imm=44).integer == 0b000000101100_00101_000_00010_0011011
    assert encode_instr(
        opcode=Opcode.STORE,
        rs1=Reg.x5,
        rs2=Reg.x2,
        funct=StoreFunct.SW,
        imm=-6).integer == 0b1111111_00010_00101_010_11010_0100011
    assert encode_instr(
        opcode=Opcode.LOAD,
        rd=Reg.x3,
        rs1=Reg.x9,
        funct=LoadFunct.LW,
        imm=8).integer == 0b000000001000_01001_010_00011_0000011

async def check_bus_write(dut,addr,data):
    while True:
        await RisingEdge(dut.clk)
        if dut.bus_cmd_en.value and dut.bus_cmd_we.value:
            assert dut.bus_cmd_addr.value.integer == addr
            assert dut.bus_cmd_wdata.value.integer == data
            raise TestSuccess("Received bus write")

async def check_bus_read(dut,addr,data):
    while True:
        await RisingEdge(dut.clk)
        if dut.bus_cmd_en.value and ~dut.bus_cmd_we.value:
            assert dut.bus_cmd_addr.value.integer == addr
            dut.bus_rsp_rdata.value = data
            await RisingEdge(dut.clk)
            break

@cocotb.test()
async def bus_write_test(dut):
    c = Clock(dut.clk, 10, 'ns')
    await cocotb.start(c.start())
    dut.rstn.value = 0
    await ClockCycles(dut.clk,3)
    dut.rstn.value = 1
    await ClockCycles(dut.clk,3)
    dut.instr_valid.value  = 1
    dut.instr.value = encode_instr(
        opcode = Opcode.OP_IMM_32,
        rd     = Reg.x2,
        rs1    = Reg.zero,
        imm    = 33,
        funct  = OpImmFunct.ADDI,
    )
    await RisingEdge(dut.clk)
    dut.instr.value = encode_instr(
        opcode = Opcode.OP_IMM_32,
        rd     = Reg.x3,
        rs1    = Reg.zero,
        imm    = 13,
        funct  = OpImmFunct.ADDI,
    )
    await RisingEdge(dut.clk)
    dut.instr.value = encode_instr(
        opcode = Opcode.STORE,
        rs1    = Reg.x3,
        rs2    = Reg.x2,
        imm    = -6,
        funct  = StoreFunct.SW,
    )
    await RisingEdge(dut.clk)
    dut.instr_valid.value  = 0
    cocotb.start_soon(check_bus_write(dut,addr=7,data=33))
    await ClockCycles(dut.clk,10)
    assert False

@cocotb.test()
async def bus_read_test(dut):
    c = Clock(dut.clk, 10, 'ns')
    await cocotb.start(c.start())
    dut.rstn.value = 0
    await ClockCycles(dut.clk,3)
    dut.rstn.value = 1
    await ClockCycles(dut.clk,3)
    dut.instr_valid.value  = 1
    dut.instr.value = encode_instr(
        opcode = Opcode.OP_IMM_32,
        rd     = Reg.x2,
        rs1    = Reg.zero,
        imm    = 33,
        funct  = OpImmFunct.ADDI,
    )
    await RisingEdge(dut.clk)
    dut.instr.value = encode_instr(
        opcode = Opcode.OP_IMM_32,
        rd     = Reg.x3,
        rs1    = Reg.zero,
        imm    = 13,
        funct  = OpImmFunct.ADDI,
    )
    await RisingEdge(dut.clk)
    dut.instr.value = encode_instr(
        opcode = Opcode.LOAD,
        rs1    = Reg.x3,
        rd     = Reg.x5,
        imm    = -6,
        funct  = LoadFunct.LW,
    )
    await RisingEdge(dut.clk)
    dut.instr.value = encode_instr(
        opcode = Opcode.STORE,
        rs1    = Reg.x3,
        rs2    = Reg.x5,
        imm    = 0,
        funct  = StoreFunct.SW,
    )
    await RisingEdge(dut.clk)
    dut.instr_valid.value  = 0
    cocotb.start_soon(check_bus_read(dut,addr=7,data=33))
    cocotb.start_soon(check_bus_write(dut,addr=13,data=33))
    await ClockCycles(dut.clk,10)
    assert False

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
