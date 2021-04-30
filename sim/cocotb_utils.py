from types import SimpleNamespace

import cocotb
from cocotb_bus.monitors import BusMonitor, Monitor
from cocotb_bus.drivers import BusDriver, Driver
from cocotb.log import SimLog
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep, FallingEdge

class Bundle(SimpleNamespace):
    def __contains__(self, signal):
        return signal in self.__dict__

class BundleAgent:
    _signals = []
    _optional_signals = []
    def __init__(self, name, bind):
        self.name = name
        self.bus = Bundle(**self.validate_map(bind))
        self.log = SimLog(f"cocotb.{self}")
    def validate_map(self, _map):
        for virtual_signal in self._signals:
            if not virtual_signal in _map.keys():
                raise ValueError(f'Missing signal "{virtual_signal}"')
        for actual_signal in _map.keys():
            if not actual_signal in self._signals and not actual_signal in self._optional_signals:
                raise ValueError(f'Cannot bind "{actual_signal}"')
        return dict(_map)
    def __str__(self):
        return f"{type(self).__qualname__}({self.name})"

class BundleMonitor(BundleAgent, Monitor):
    def __init__(self, name, bind, reset = None, reset_n = None, callback = None, event = None):
        self._reset = reset
        self._reset_n = reset_n
        BundleAgent.__init__(self, name=name, bind=bind)
        Monitor.__init__(self, callback=callback, event=event)
    @property
    def in_reset(self):
        """Boolean flag showing whether the bus is in reset state or not."""
        if self._reset_n is not None:
            return not bool(self._reset_n.value.integer)
        if self._reset is not None:
            return bool(self._reset.value.integer)
        return False

class BundleDriver(BundleAgent, Driver):
    def __init__(self, name, bind):
        BundleAgent.__init__(self, name=name, bind=bind)
        Driver.__init__(self)

def get_top_module(name):
    return cocotb.handle.SimHandle(cocotb.simulator.get_root_handle(name))

def verilog_string(string):
    return int.from_bytes(string.encode("utf-8"),byteorder='big')

def get_test_name():
    return cocotb.regression_manager._test.__name__ # pylint: disable=protected-access

@cocotb.coroutine
async def wait_for_signal(signal):
    await ReadOnly()
    while signal.value.integer != 1:
        await RisingEdge(signal)
        await ReadOnly()
    await NextTimeStep()

@cocotb.coroutine
async def wait_for_nsignal(signal):
    await ReadOnly()
    while signal.value.integer != 0:
        await FallingEdge(signal)
        await ReadOnly()
    await NextTimeStep()
