#include <verilated.h>
#include "Vcopperv.h"

vluint64_t main_time = 0;       // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  This is in units of the timeprecision
// used in Verilog (or from --timescale-override)

int main(int argc, char** argv, char** env) {
  VerilatedContext* contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Vcopperv* top = new Vcopperv{contextp};
  while (!contextp->gotFinish()) { 
    top->eval();
		main_time++;
  }
  delete top;
  delete contextp;
  return 0;
}
