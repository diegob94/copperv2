#include <stdio.h>
#include "riscv_test.h"

int volatile * const TEST_RESULT = T_ADDR;
int volatile * const SIM_OUT = O_ADDR;
int volatile * const TIMER_COUNTER = TC_ADDR;

void _putc(char c){
    *SIM_OUT = c;
}
void print(char* c){
    while(*c) _putc(*(c++));
}

int a;

int main(){
    if (a != 0)
        *TEST_RESULT = T_FAIL;
    *TEST_RESULT = T_PASS;
}
