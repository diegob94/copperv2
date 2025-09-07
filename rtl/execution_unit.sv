`include "copperv_pkg.sv"
`default_nettype none

module execution_unit import copperv_pkg::opcode_e; (
  input  logic        clk, 
  input  logic        rstn,
  
  input  logic [31:0] instr,
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
import copperv_pkg::regfile_rd_sel_e;

logic [31:0]     dec_instr;
logic            dec_instr_valid;
regfile_rd_sel_e dec_regfile_rd_sel;
logic            dec_regfile_rd_en;
alu_op_e         dec_alu_op;
logic            dec_bus_en;
logic            dec_bus_we;

regfile_rd_sel_e ex_regfile_rd_sel;
logic [31:0]     ex_instr_imm;
alu_op_e         ex_alu_op;
logic [4:0]      ex_regfile_rd;
logic            ex_regfile_rd_en;
logic [31:0]     ex_regfile_rs1_data;
logic [31:0]     ex_regfile_rs2_data;
logic            ex_bus_en;
logic            ex_bus_we;

regfile_rd_sel_e ct_regfile_rd_sel;
logic [31:0]     ct_alu_dout;
logic [4:0]      ct_regfile_rd;
logic            ct_regfile_rd_en;
logic [31:0]     ct_regfile_rs1_data;
logic [31:0]     ct_regfile_rs2_data;
logic            ct_bus_en;
logic            ct_bus_we;

assign instr_ready = 1;

opcode_e     instr_opcode;
logic [4:0]  instr_rd;
logic [4:0]  instr_rs1;
logic [4:0]  instr_rs2;
logic [31:0] instr_imm;
logic [9:0]  instr_funct;

logic [4:0]  regfile_rd;
logic [4:0]  regfile_rs1;
logic [4:0]  regfile_rs2;
logic [31:0] regfile_rd_data;
logic        regfile_rd_en;
logic [31:0] regfile_rs1_data;
logic [31:0] regfile_rs2_data;

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

idecoder idecoder (
  .instr(dec_instr),
  .opcode(instr_opcode),
  .funct(instr_funct),
  .rs1(instr_rs1),
  .rs2(instr_rs2),
  .rd(instr_rd),
  .imm(instr_imm)
);

regfile regfile(
  .clk(clk),
  .rstn(rstn),
  .rd(regfile_rd),
  .rs1(regfile_rs1),
  .rs2(regfile_rs2),
  .rd_data(regfile_rd_data),
  .rd_en(regfile_rd_en),
  .rs1_data(regfile_rs1_data),
  .rs2_data(regfile_rs2_data)
);

alu alu(
  .op(alu_op),
  .din1(alu_din1),
  .din2(alu_din2),
  .dout(alu_dout),
  .comp_eq(alu_comp_eq),
  .comp_lt(alu_comp_lt),
  .comp_ltu(alu_comp_ltu)
);

assign regfile_rs1 = instr_rs1;
assign regfile_rs2 = instr_rs2;

always_comb begin : control_dec
  dec_alu_op = copperv_pkg::ALU_NOP;
  dec_regfile_rd_en = 1'b0;
  dec_regfile_rd_sel = copperv_pkg::RD_ALU_DOUT;
  case (instr_opcode)
    rvi_pkg::OP_IMM_32: begin
      case (instr_funct)
        rvi_pkg::ADDI: begin
          dec_alu_op = copperv_pkg::ALU_ADD;
          dec_regfile_rd_en = 1'b1;
          dec_regfile_rd_sel = copperv_pkg::RD_ALU_DOUT;
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

always_ff @(posedge clk, negedge rstn) begin : dec_reg
  if (!rstn) begin
    dec_instr <= '0;
  end else begin
    if (instr_valid && instr_ready) begin
      dec_instr <= instr;
      dec_instr_valid <= 1'b1;
    end else begin
      dec_instr_valid <= 1'b0;
    end
  end
end : dec_reg

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
    ex_regfile_rd_sel   <= copperv_pkg::RD_ALU_DOUT;
  end else begin
    if (dec_instr_valid) begin
      ex_instr_imm        <= instr_imm;
      ex_alu_op           <= dec_alu_op;
      ex_regfile_rd       <= instr_rd;
      ex_regfile_rd_en    <= dec_regfile_rd_en;
      ex_regfile_rs1_data <= regfile_rs1_data;
      ex_regfile_rs2_data <= regfile_rs2_data;
      ex_bus_en           <= dec_bus_en;
      ex_bus_we           <= dec_bus_we;
      ex_regfile_rd_sel   <= dec_regfile_rd_sel;
    end else begin
      ex_alu_op           <= copperv_pkg::ALU_NOP;
      ex_regfile_rd_en    <= 1'b0;
      ex_bus_en           <= 1'b0;
    end
  end
end : ex_reg

assign bus_cmd_addr    = alu_dout;
assign bus_cmd_wdata   = ex_regfile_rs2_data;
assign bus_cmd_en      = ex_bus_en;
assign bus_cmd_we      = ex_bus_we;

always_ff @(posedge clk, negedge rstn) begin : ct_reg
  if (!rstn) begin
    ct_alu_dout         <= '0;
    ct_regfile_rd       <= '0;
    ct_regfile_rd_en    <= 1'b0;
    ct_regfile_rs1_data <= '0;
    ct_regfile_rs2_data <= '0;
    ct_bus_en           <= 1'b0;
    ct_bus_we           <= 1'b0;
    ct_regfile_rd_sel   <= copperv_pkg::RD_ALU_DOUT;
  end else begin
    ct_alu_dout         <= alu_dout;
    ct_regfile_rd       <= ex_regfile_rd;
    ct_regfile_rd_en    <= ex_regfile_rd_en;
    ct_regfile_rs1_data <= ex_regfile_rs1_data;
    ct_regfile_rs2_data <= ex_regfile_rs2_data;
    ct_bus_en           <= ex_bus_en;
    ct_bus_we           <= ex_bus_we;
    ct_regfile_rd_sel   <= ex_regfile_rd_sel;
  end
end

always_comb begin : regfile_rd_mux
  case (ct_regfile_rd_sel)
    copperv_pkg::RD_ALU_DOUT:  regfile_rd_data = ct_alu_dout;
    copperv_pkg::RD_MEM_RDATA: regfile_rd_data = bus_rsp_rdata;
    default:                   regfile_rd_data = ct_alu_dout;
  endcase
end : regfile_rd_mux
assign regfile_rd    = ct_regfile_rd;
assign regfile_rd_en = ct_regfile_rd_en;

endmodule
