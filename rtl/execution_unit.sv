`include "copperv_pkg.sv"
`default_nettype none

module execution_unit import copperv_pkg::opcode_e; (
  input  logic        clk, 
  input  logic        rstn,
  
  input  opcode_e     instr_opcode,
  input  logic [4:0]  instr_rd,
  input  logic [4:0]  instr_rs1,
  input  logic [4:0]  instr_rs2,
  input  logic [31:0] instr_imm,
  input  logic [9:0]  instr_funct,
  input  logic        instr_valid,
  output logic        instr_ready,
  
  output logic [31:0] bus_cmd_addr,
  output logic [31:0] bus_cmd_wdata,
  output logic        bus_cmd_en,
  output logic        bus_cmd_we,
  input  logic [31:0] bus_rsp_rdata,
  input  logic        bus_rsp_ready,

  output logic [4:0]  regfile_cmd_rd,
  output logic [4:0]  regfile_cmd_rs1,
  output logic [4:0]  regfile_cmd_rs2,
  output logic [31:0] regfile_cmd_rd_data,
  output logic        regfile_cmd_rd_en,
  input  logic [31:0] regfile_rsp_rs1_data,
  input  logic [31:0] regfile_rsp_rs2_data
);
import copperv_pkg::alu_op_e;

opcode_e     ex_instr_opcode;
logic [4:0]  ex_instr_rd;
logic [4:0]  ex_instr_rs1;
logic [4:0]  ex_instr_rs2;
logic [31:0] ex_instr_imm;
logic [9:0]  ex_instr_funct;

assign instr_ready = 1;

assign regfile_cmd_rs1 = instr_rs1;
assign regfile_cmd_rs2 = instr_rs2;

always_ff @(posedge clk, negedge rstn) begin : ex_reg
  if (!rstn) begin
    ex_instr_opcode <= rvi_pkg::RESERVED_4;
    ex_instr_rd     <= '0;
    ex_instr_rs1    <= '0;
    ex_instr_rs2    <= '0;
    ex_instr_imm    <= '0;
    ex_instr_funct  <= '0;
  end else if (instr_valid && instr_ready) begin
    ex_instr_opcode <= instr_opcode;
    ex_instr_rd     <= instr_rd;
    ex_instr_rs1    <= instr_rs1;
    ex_instr_rs2    <= instr_rs2;
    ex_instr_imm    <= instr_imm;
    ex_instr_funct  <= instr_funct;
  end
end : ex_reg

alu_op_e alu_op;
logic [31:0] alu_res;
always_comb begin : alu_op_dec
  alu_op = copperv_pkg::ALU_NOP;
  case (ex_instr_opcode)
    rvi_pkg::OP_IMM_32: begin
      case (ex_instr_funct)
        rvi_pkg::ADDI: alu_op = copperv_pkg::ALU_ADD;
        default:;
      endcase
    end
    default:;
  endcase
end : alu_op_dec

logic [31:0] alu_op1;
logic [31:0] alu_op2;
assign alu_op1 = regfile_rsp_rs1_data;
assign alu_op2 = ex_instr_imm;
always_comb begin : alu_compute
  alu_res = '0;
  case (alu_op)
    copperv_pkg::ALU_NOP:;
    copperv_pkg::ALU_ADD: alu_res = alu_op1 + alu_op2;
    default:;
  endcase
end : alu_compute

assign regfile_cmd_rd_data = alu_res;
assign regfile_cmd_rd = ex_instr_rd;

endmodule
