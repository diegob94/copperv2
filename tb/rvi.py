from enum import IntEnum

class Opcode(IntEnum):
    LOAD       = 0b00_000_11
    LOAD_FP    = 0b00_001_11
    CUSTOM_0   = 0b00_010_11
    MISC_MEM   = 0b00_011_11
    OP_IMM     = 0b00_100_11
    AUIPC      = 0b00_101_11
    OP_IMM_32  = 0b00_110_11
    RESERVED_0 = 0b00_111_11
    STORE      = 0b01_000_11
    STORE_FP   = 0b01_001_11
    CUSTOM_1   = 0b01_010_11
    AMO        = 0b01_011_11
    OP         = 0b01_100_11
    LUI        = 0b01_101_11
    OP_32      = 0b01_110_11
    RESERVED_1 = 0b01_111_11
    MADD       = 0b10_000_11
    MSUB       = 0b10_001_11
    NMSUB      = 0b10_010_11
    NMADD      = 0b10_011_11
    OP_FP      = 0b10_100_11
    OP_V       = 0b10_101_11
    CUSTOM_2   = 0b10_110_11
    RESERVED_2 = 0b10_111_11
    BRANCH     = 0b11_000_11
    JALR       = 0b11_001_11
    RESERVED_3 = 0b11_010_11
    JAL        = 0b11_011_11
    SYSTEM     = 0b11_100_11
    OP_VE      = 0b11_101_11
    CUSTOM_3   = 0b11_110_11
    RESERVED_4 = 0b11_111_11

class BranchFunct(IntEnum):
    BEQ  = 0b0000000_000
    BNE  = 0b0000000_001
    BLT  = 0b0000000_100
    BGE  = 0b0000000_101
    BLTU = 0b0000000_110
    BGEU = 0b0000000_111

class LoadFunct(IntEnum):
    LB  = 0b0000000_000
    LH  = 0b0000000_001
    LW  = 0b0000000_010
    LBU = 0b0000000_100
    LHU = 0b0000000_101

class StoreFunct(IntEnum):
    SB = 0b0000000_000
    SH = 0b0000000_001
    SW = 0b0000000_010

class OpImmFunct(IntEnum):
    ADDI  = 0b0000000_000
    SLTI  = 0b0000000_010
    SLTIU = 0b0000000_011
    XORI  = 0b0000000_100
    ORI   = 0b0000000_110
    ANDI  = 0b0000000_111
    SLLI  = 0b0000000_001
    SRLI  = 0b0000000_101
    SRAI  = 0b0100000_101

class OpFunct(IntEnum):
    ADD  = 0b0000000_000
    SUB  = 0b0100000_000
    SLL  = 0b0000000_001
    SLT  = 0b0000000_010
    SLTU = 0b0000000_011
    XOR  = 0b0000000_100
    SRL  = 0b0000000_101
    SRA  = 0b0100000_101
    OR   = 0b0000000_110
    AND  = 0b0000000_111

class Reg(IntEnum):
    zero = 0
    x1   = 1
    x2   = 2
    x3   = 3
    x4   = 4
    x5   = 5
    x6   = 6
    x7   = 7
    x8   = 8
    x9   = 9
    x10  = 10
    x11  = 11
    x12  = 12
    x13  = 13
    x14  = 14
    x15  = 15
    x16  = 16
    x17  = 17
    x18  = 18
    x19  = 19
    x20  = 20
    x21  = 21
    x22  = 22
    x23  = 23
    x24  = 24
    x25  = 25
    x26  = 26
    x27  = 27
    x28  = 28
    x29  = 29
    x30  = 30
    x31  = 31
