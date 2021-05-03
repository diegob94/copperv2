package copperv2

import chisel3._
import chisel3.util.{Decoupled,MuxLookup}

class Cuv2Config {
  class BusConfig(
    var data_width: Int = 32, 
    var addr_width: Int = 32, 
    var resp_width: Int = 1
  )
  var bus = new BusConfig()
  var pc_width = 32
  var pc_init = 0
}

class idecoder extends BlackBox {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))
    val imm = Output(UInt(32.W))
    val inst_type = Output(UInt(4.W))
    val rd = Output(UInt(5.W))
    val rs1 = Output(UInt(5.W))
    val rs2 = Output(UInt(5.W))
    val funct = Output(UInt(5.W))
  })
}

class register_file extends BlackBox {
  val io = IO(new Bundle {
    val clk = Input(Bool())
    val rst = Input(Bool())
    val rd_en = Input(Bool())
    val rs1_en = Input(Bool())
    val rs2_en = Input(Bool())
    val rd = Input(UInt(5.W))
    val rs1 = Input(UInt(5.W))
    val rs2 = Input(UInt(5.W))
    val rd_din = Input(UInt(32.W))
    val rs1_dout = Output(UInt(32.W))
    val rs2_dout = Output(UInt(32.W))
  })
}

class arith_logic_unit extends BlackBox {
  val io = IO(new Bundle {
    val alu_din1 = Input(UInt(32.W))
    val alu_din2 = Input(UInt(32.W))
    val alu_op = Input(UInt(4.W))
    val alu_dout = Output(UInt(32.W))
    val alu_comp = Output(UInt(3.W))
  })
}

class control_unit extends BlackBox {
  val io = IO(new Bundle {
    val clk = Input(Bool())
    val rst = Input(Bool())
    val inst_type = Input(UInt(4.W))
    val inst_valid = Input(Bool())
    val alu_comp = Input(UInt(3.W))
    val funct = Input(UInt(5.W))
    val data_valid = Input(Bool())
    val inst_fetch = Output(Bool())
    val load_data = Output(Bool())
    val store_data = Output(Bool())
    val rd_en = Output(Bool())
    val rs1_en = Output(Bool())
    val rs2_en = Output(Bool())
    val rd_din_sel = Output(UInt(2.W))
    val pc_next_sel = Output(UInt(2.W))
    val alu_din1_sel = Output(UInt(2.W))
    val alu_din2_sel = Output(UInt(2.W))
    val alu_op = Output(UInt(4.W))
  })
}

class Cuv2ReadChannel(config: Cuv2Config) extends Bundle {
  // Output
  val addr = Decoupled(UInt(config.bus.addr_width.W))
  // Input
  val data = Flipped(Decoupled(UInt(config.bus.data_width.W)))
}

class Cuv2WriteOutput(config: Cuv2Config) extends Bundle {
  val strobe_width = config.bus.data_width / 4
  val data = UInt(config.bus.data_width.W)
  val addr = UInt(config.bus.addr_width.W)
  val strobe = UInt(strobe_width.W)
}

class Cuv2WriteChannel(config: Cuv2Config) extends Bundle {
  // Output
  val req = Decoupled(new Cuv2WriteOutput(config))
  // Input
  val resp = Flipped(Decoupled(UInt(config.bus.resp_width.W)))
}

class Copperv2Bus(config: Cuv2Config) extends Bundle {
  val ir = new Cuv2ReadChannel(config)
  val dr = new Cuv2ReadChannel(config)
  val dw = new Cuv2WriteChannel(config)
}

class Copperv2 extends MultiIOModule with RequireSyncReset {
  val config = new Cuv2Config
  val bus = new Copperv2Bus(config)
  val ir = IO(bus.ir)
  val dr = IO(bus.dr)
  val dw = IO(bus.dw)
  ir.addr.valid := 0.U
  ir.addr.bits := 0.U
  ir.data.ready := 0.U
  dr.addr.valid := 0.U
  dr.addr.bits := 0.U
  dr.data.ready := 0.U
  dw.req.valid := 0.U
  dw.req.bits.data := 0.U
  dw.req.bits.addr := 0.U
  dw.req.bits.strobe := 0.U
  dw.resp.ready := 0.U
  val control = Module(new control_unit)
  val idec = Module(new idecoder)
  val regfile = Module(new register_file)
  val alu = Module(new arith_logic_unit)
  val pc = RegInit(config.pc_init.U(config.pc_width.W))
  val pc_en = MuxLookup(control.io.pc_next_sel,true.B,Array(0.U -> false.B))
  val pc_next = MuxLookup(control.io.pc_next_sel,0.U,Array(
    1.U -> (pc + 4.U),
    2.U -> (pc + idec.io.imm),
    3.U -> (regfile.io.rs1_dout + idec.io.imm),
  ))
  when (pc_en) {
    pc := pc_next
  }
  when (ir.addr.ready) {
    ir.addr.bits := pc
    ir.addr.valid := true.B
  }
}
