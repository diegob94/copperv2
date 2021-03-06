package copperv2

import chisel3._
import chisel3.experimental.ChiselEnum

object InstType extends ChiselEnum {
  val IMM     = Value // 0
  val INT_IMM = Value
  val INT_REG = Value
  val BRANCH  = Value
  val STORE   = Value
  val JAL     = Value // 5
  val AUIPC   = Value
  val JALR    = Value
  val LOAD    = Value
  val FENCE   = Value
}

object Funct extends ChiselEnum {
  val ADD        = Value // 0
  val SUB        = Value
  val AND        = Value
  val EQ         = Value
  val NEQ        = Value
  val LT         = Value // 5
  val GTE        = Value
  val LTU        = Value
  val GTEU       = Value
  val MEM_BYTE   = Value
  val MEM_HWORD  = Value // 10
  val MEM_WORD   = Value
  val MEM_BYTEU  = Value
  val MEM_HWORDU = Value
  val JAL        = Value
  val SLL        = Value
  val SLT        = Value
  val SLTU       = Value
  val XOR        = Value
  val SRL        = Value
  val SRA        = Value
  val OR         = Value
}

object RdDinSel extends ChiselEnum {
  val NONE = Value
  val IMM = Value
  val ALU = Value
  val MEM = Value
}

object PcNextSel extends ChiselEnum {
  val STALL       = Value
  val INCR        = Value
  val ADD_IMM     = Value
  val ADD_RS1_IMM = Value
}

object AluDin1Sel extends ChiselEnum {
  val RS1 = Value
  val PC  = Value
}

object AluDin2Sel extends ChiselEnum {
  val IMM     = Value
  val RS2     = Value
  val CONST_4 = Value
}

object AluOp extends ChiselEnum {
  val NOP  = Value
  val ADD  = Value
  val SUB  = Value
  val AND  = Value
  val SLL  = Value
  val SRA  = Value
  val SRL  = Value
  val XOR  = Value
  val OR   = Value
  val SLT  = Value
  val SLTU = Value
}

class AluComp extends Bundle {
  val EQ  = Bool()
  val LT  = Bool()
  val LTU = Bool()
}

object State extends ChiselEnum {
  val RESET  = Value // 0
  val IDLE   = Value
  val FETCH  = Value
  val DECODE = Value
  val EXEC   = Value
  val MEM    = Value // 5
  val COMMIT = Value
}
