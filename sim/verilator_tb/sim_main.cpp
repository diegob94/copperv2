#include <verilated.h>
#include "Vcopperv.h"

int main(int argc, char** argv, char** env) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vcopperv* top = new Vcopperv{contextp};
    while (!contextp->gotFinish()) { top->eval(); }
    delete top;
    delete contextp;
    return 0;
}
