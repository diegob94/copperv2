from collections import namedtuple
import subprocess

import cocotb
from cocotb.decorators import RunningTask
from cocotb.log import SimLog
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep, FallingEdge
from cocotb.clock import Clock
from cocotb.types import Logic

from cocotb_bus.bus import Bus

import typing
import dataclasses

class Bfm:
    _signals = []
    _optional_signals = []
    def __init__(self,entity,prefix,clock,reset=None,reset_n=None,period=10,period_unit="ns",signals_dict=None):
        self.log = SimLog(f"bfm.{type(self).__qualname__}")
        self.clock = clock
        self._reset = reset
        self._reset_n = reset_n
        self.period = period
        self.period_unit = period_unit
        if signals_dict is not None:
            self._signals=signals_dict
        self.bus = Bus(entity=entity,name=prefix,signals=self._signals,optional_signals=self._optional_signals)
    @property
    def in_reset(self):
        """Boolean flag showing whether the bus is in reset state or not."""
        if self._reset is not None:
            # self.log.debug(f"[{self.__class__.__qualname__}] in_reset: {self._reset._name}")
            return bool(self._reset.value.integer)
        if self._reset_n is not None:
            # self.log.debug(f"[{self.__class__.__qualname__}] in_reset: {self._reset_n._name}")
            return not bool(self._reset_n.value.integer)
        return False
    def start_clock(self):
        cocotb.start_soon(Clock(self.clock,self.period,self.period_unit).start())
    async def reset(self):
        if self._reset is not None:
            await RisingEdge(self.clock)
            self._reset.value = 1
            await RisingEdge(self.clock)
            self._reset.value = 0
        if self._reset_n is not None:
            await RisingEdge(self.clock)
            self._reset_n.value = 0
            await RisingEdge(self.clock)
            self._reset_n.value = 1
    async def wait_for_signal(self,signal,value):
        self.log.debug(f"wait_for_signal: {signal._name} value {value}")
        await ReadOnly()
        while self.in_reset or Logic(signal.value.binstr) != Logic(value):
            await RisingEdge(self.clock)
            await ReadOnly()
        self.log.debug(f"wait_for_signal: {signal._name} value {value} return")
        await NextTimeStep()

def anext(async_generator):
    return RunningTask(async_generator.__anext__())

async def Combine(*triggers):
    def get_return_value(x):
        if hasattr(x,"parent"):
            return x.parent.data
        return x.retval
    c = await cocotb.triggers.Combine(*triggers)
    return [get_return_value(t) for t in c.triggers]

def get_top_module(name):
    return cocotb.handle.SimHandle(cocotb.simulator.get_root_handle(name))

def to_verilog_string(string):
    return int.from_bytes(string.encode("utf-8"),byteorder='big')

def from_array(data,addr):
    buf = []
    for i in range(4):
        value = 0
        if addr+i in data:
            value = data[addr+i]
        buf.append(value)
    return int.from_bytes(buf,byteorder='little')

def to_bytes(data):
    return (data).to_bytes(length=4,byteorder='little')

def run(*args,**kwargs):
    log = SimLog("cocotb")
    log.debug(f"run: {args}")
    r = subprocess.run(*args,shell=True,encoding='utf-8',capture_output=True,**kwargs)
    if r.returncode != 0:
        log.error(f"run stdout: {r.stdout}")
        log.error(f"run stderr: {r.stderr}")
        raise ChildProcessError(f"Error during command execution: {args}")
    return r
