`include "copperv_pkg.sv"

module alu import copperv_pkg::alu_op_e; (
  input  alu_op_e     op,
  input  logic [31:0] din1,
  input  logic [31:0] din2,
  output logic [31:0] dout,
  output logic        comp_eq,
  output logic        comp_lt,
  output logic        comp_ltu
);

always_comb begin : alu_ops
  case (op)
    copperv_pkg::ALU_NOP:  dout = '0;
    copperv_pkg::ALU_ADD:  dout = din1 + din2; 
    copperv_pkg::ALU_SUB:  dout = din1 - din2;
    copperv_pkg::ALU_AND:  dout = din1 & din2;
    copperv_pkg::ALU_SLL:  dout = din1 << din2[4:0];
    copperv_pkg::ALU_SRL:  dout = din1 >> din2[4:0];
    copperv_pkg::ALU_SRA:  dout = $signed(din1) >>> din2[4:0];
    copperv_pkg::ALU_XOR:  dout = din1 ^ din2;
    copperv_pkg::ALU_OR:   dout = din1 | din2;
    copperv_pkg::ALU_SLT:  dout = 32'(comp_lt);
    copperv_pkg::ALU_SLTU: dout = 32'(comp_ltu);
    default:               dout = '0;
  endcase
end : alu_ops

always_comb begin : alu_comp
  comp_eq  = din1 == din2;
  comp_lt  = $signed(din1) < $signed(din2);
  comp_ltu = din1 < din2;
end : alu_comp

endmodule