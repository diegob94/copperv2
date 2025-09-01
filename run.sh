#!/bin/bash

verilator --lint-only +incdir+./rtl/ rtl/execution_unit.sv

