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
  input  logic        bus_rsp_ready
);
import copperv_pkg::alu_op_e;

logic        dec_regfile_rd_en;
alu_op_e     dec_alu_op;
logic        dec_bus_en;
logic        dec_bus_we;

logic [31:0] ex_instr_imm;
alu_op_e     ex_alu_op;
logic [4:0]  ex_regfile_rd;
logic        ex_regfile_rd_en;
logic [31:0] ex_regfile_rs1_data;
logic [31:0] ex_regfile_rs2_data;
logic        ex_bus_en;
logic        ex_bus_we;

logic [31:0] ct_alu_dout;
logic [4:0]  ct_regfile_rd;
logic        ct_regfile_rd_en;
logic [31:0] ct_regfile_rs1_data;
logic [31:0] ct_regfile_rs2_data;
logic        ct_bus_en;
logic        ct_bus_we;

assign instr_ready = 1;

logic [31:0] regfile_mem [1:31];
logic [4:0]  regfile_rd;
logic [4:0]  regfile_rs1;
logic [4:0]  regfile_rs2;
logic [31:0] regfile_rd_data;
logic        regfile_rd_en;
logic [31:0] regfile_rs1_data;
logic [31:0] regfile_rs2_data;

always_ff @(posedge clk, negedge rstn) begin : regfile_write
  if (!rstn) begin
    for (int i = 1; i < 32; i++) begin
      regfile_mem[i] <= '0;
    end
  end else begin
    if (regfile_rd_en && regfile_rd != 0) begin
      regfile_mem[regfile_rd] <= regfile_rd_data;
    end
  end
end : regfile_write

always_comb begin : regfile_read
  regfile_rs1_data = regfile_rs1 == 0 ? '0 : regfile_mem[regfile_rs1];
  regfile_rs2_data = regfile_rs1 == 0 ? '0 : regfile_mem[regfile_rs2];
end : regfile_read

assign regfile_rs1 = instr_rs1;
assign regfile_rs2 = instr_rs2;

always_comb begin : control_dec
  dec_alu_op = copperv_pkg::ALU_NOP;
  dec_regfile_rd_en = 1'b0;
  case (instr_opcode)
    rvi_pkg::OP_IMM_32: begin
      case (instr_funct)
        rvi_pkg::ADDI: begin
          dec_alu_op = copperv_pkg::ALU_ADD;
          dec_regfile_rd_en = 1'b1;
        end
        default:;
      endcase
    end
    rvi_pkg::STORE: begin
      case (instr_funct)
        rvi_pkg::SW: begin
          dec_alu_op = copperv_pkg::ALU_ADD;
          dec_bus_en = 1'b1;
          dec_bus_we = 1'b1;
        end
        default:;
      endcase
    end
    default:;
  endcase
end : control_dec

always_ff @(posedge clk, negedge rstn) begin : ex_reg
  if (!rstn) begin
    ex_instr_imm        <= '0;
    ex_alu_op           <= copperv_pkg::ALU_NOP;
    ex_regfile_rd       <= '0;
    ex_regfile_rd_en    <= 1'b0;
    ex_regfile_rs1_data <= '0;
    ex_regfile_rs2_data <= '0;
    ex_bus_en           <= 1'b0;
    ex_bus_we           <= 1'b0;
  end else begin
    if (instr_valid && instr_ready) begin
      ex_instr_imm        <= instr_imm;
      ex_alu_op           <= dec_alu_op;
      ex_regfile_rd       <= instr_rd;
      ex_regfile_rd_en    <= dec_regfile_rd_en;
      ex_regfile_rs1_data <= regfile_rs1_data;
      ex_regfile_rs2_data <= regfile_rs2_data;
      ex_bus_en           <= dec_bus_en;
      ex_bus_we           <= dec_bus_we;
    end else begin
      ex_alu_op           <= copperv_pkg::ALU_NOP;
      ex_regfile_rd_en    <= 1'b0;
      ex_bus_en           <= 1'b0;
    end
  end
end : ex_reg

alu_op_e alu_op;
logic [31:0] alu_dout;
logic [31:0] alu_din1;
logic [31:0] alu_din2;
logic alu_comp_eq;
logic alu_comp_lt;
logic alu_comp_ltu;
assign alu_din1 = regfile_rs1_data;
assign alu_din2 = ex_instr_imm;
assign alu_op = ex_alu_op;
always_comb begin : alu_ops
  case (alu_op)
    copperv_pkg::ALU_NOP:  alu_dout = '0;
    copperv_pkg::ALU_ADD:  alu_dout = alu_din1 + alu_din2; 
    copperv_pkg::ALU_SUB:  alu_dout = alu_din1 - alu_din2;
    copperv_pkg::ALU_AND:  alu_dout = alu_din1 & alu_din2;
    copperv_pkg::ALU_SLL:  alu_dout = alu_din1 << alu_din2[4:0];
    copperv_pkg::ALU_SRL:  alu_dout = alu_din1 >> alu_din2[4:0];
    copperv_pkg::ALU_SRA:  alu_dout = $signed(alu_din1) >>> alu_din2[4:0];
    copperv_pkg::ALU_XOR:  alu_dout = alu_din1 ^ alu_din2;
    copperv_pkg::ALU_OR:   alu_dout = alu_din1 | alu_din2;
    copperv_pkg::ALU_SLT:  alu_dout = 32'(alu_comp_lt);
    copperv_pkg::ALU_SLTU: alu_dout = 32'(alu_comp_ltu);
    default:               alu_dout = '0;
  endcase
end : alu_ops

always_comb begin : alu_comp
  alu_comp_eq  = alu_din1 == alu_din2;
  alu_comp_lt  = $signed(alu_din1) < $signed(alu_din2);
  alu_comp_ltu = alu_din1 < alu_din2;
end : alu_comp

always_ff @(posedge clk, negedge rstn) begin : ct_reg
  if (!rstn) begin
    ct_alu_dout         <= '0;
    ct_regfile_rd       <= '0;
    ct_regfile_rd_en    <= 1'b0;
    ct_regfile_rs1_data <= '0;
    ct_regfile_rs2_data <= '0;
    ct_bus_en           <= 1'b0;
    ct_bus_we           <= 1'b0;
  end else begin
    ct_alu_dout         <= alu_dout;
    ct_regfile_rd       <= ex_regfile_rd;
    ct_regfile_rd_en    <= ex_regfile_rd_en;
    ct_regfile_rs1_data <= ex_regfile_rs1_data;
    ct_regfile_rs2_data <= ex_regfile_rs2_data;
    ct_bus_en           <= ex_bus_en;
    ct_bus_we           <= ex_bus_we;
  end
end

assign regfile_rd_data = ct_alu_dout;
assign regfile_rd      = ct_regfile_rd;
assign regfile_rd_en   = ct_regfile_rd_en;

assign bus_cmd_addr    = ct_alu_dout;
assign bus_cmd_wdata   = ct_regfile_rs2_data;
assign bus_cmd_en      = ct_bus_en;
assign bus_cmd_we      = ct_bus_we;

endmodule
