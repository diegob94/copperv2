`ifndef COPPERV_PKG_HEADER_GUARD
`define COPPERV_PKG_HEADER_GUARD

`include "rvi_pkg.sv"

package copperv_pkg;
  import rvi_pkg::opcode_e;
  export rvi_pkg::opcode_e;
  
  typedef enum logic [3:0] {
    ALU_NOP,
    ALU_ADD,
    ALU_SUB,
    ALU_AND,
    ALU_SLL,
    ALU_SRL,
    ALU_SRA,
    ALU_XOR,
    ALU_OR,
    ALU_SLT,
    ALU_SLTU
  } alu_op_e;

  typedef enum logic {
    RD_ALU_DOUT,
    RD_MEM_RDATA
  } regfile_rd_sel_e;

endpackage : copperv_pkg

`endif // COPPERV_PKG_HEADER_GUARD
