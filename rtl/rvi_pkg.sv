`ifndef RVI_PKG_HEADER_GUARD
`define RVI_PKG_HEADER_GUARD

package rvi_pkg;
  typedef enum logic [6:0] {
    LOAD       = 7'b0000011,
    LOAD_FP    = 7'b0000111,
    CUSTOM_0   = 7'b0001011,
    MISC_MEM   = 7'b0001111,
    OP_IMM     = 7'b0010011,
    AUIPC      = 7'b0010111,
    OP_IMM_32  = 7'b0011011,
    RESERVED_0 = 7'b0011111,
    STORE      = 7'b0100011,
    STORE_FP   = 7'b0100111,
    CUSTOM_1   = 7'b0101011,
    AMO        = 7'b0101111,
    OP         = 7'b0110011,
    LUI        = 7'b0110111,
    OP_32      = 7'b0111011,
    RESERVED_1 = 7'b0111111,
    MADD       = 7'b1000011,
    MSUB       = 7'b1000111,
    NMSUB      = 7'b1001011,
    NMADD      = 7'b1001111,
    OP_FP      = 7'b1010011,
    OP_V       = 7'b1010111,
    CUSTOM_2   = 7'b1011011,
    RESERVED_2 = 7'b1011111,
    BRANCH     = 7'b1100011,
    JALR       = 7'b1100111,
    RESERVED_3 = 7'b1101011,
    JAL        = 7'b1101111,
    SYSTEM     = 7'b1110011,
    OP_VE      = 7'b1110111,
    CUSTOM_3   = 7'b1111011,
    RESERVED_4 = 7'b1111111
  } opcode_e;
  typedef enum logic [9:0] {
    BEQ  = 10'b0000000000,
    BNE  = 10'b0000000001,
    BLT  = 10'b0000000100,
    BGE  = 10'b0000000101,
    BLTU = 10'b0000000110,
    BGEU = 10'b0000000111
  } branch_funct_e;
  typedef enum logic [9:0] {
    LB  = 10'b0000000000,
    LH  = 10'b0000000001,
    LW  = 10'b0000000010,
    LBU = 10'b0000000100,
    LHU = 10'b0000000101
  } load_funct_e;
  typedef enum logic [9:0] {
    SB = 10'b0000000000,
    SH = 10'b0000000001,
    SW = 10'b0000000010
  } store_funct_e;
  typedef enum logic [9:0] {
    ADDI  = 10'b0000000000,
    SLTI  = 10'b0000000010,
    SLTIU = 10'b0000000011,
    XORI  = 10'b0000000100,
    ORI   = 10'b0000000110,
    ANDI  = 10'b0000000111,
    SLLI  = 10'b0000000001,
    SRLI  = 10'b0000000101,
    SRAI  = 10'b0100000101
  } op_imm_funct_e;
  typedef enum logic [9:0] {
    ADD  = 10'b0000000000,
    SUB  = 10'b0100000000,
    SLL  = 10'b0000000001,
    SLT  = 10'b0000000010,
    SLTU = 10'b0000000011,
    XOR  = 10'b0000000100,
    SRL  = 10'b0000000101,
    SRA  = 10'b0100000101,
    OR   = 10'b0000000110,
    AND  = 10'b0000000111
  } op_funct_e;
endpackage : rvi_pkg

`endif // RVI_PKG_HEADER_GUARD
