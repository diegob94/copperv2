`include "copperv_pkg.sv"

module idecoder import copperv_pkg::opcode_e; (
  input [31:0]        instr,
  output opcode_e     opcode,
  output logic [4:0]  rs1,
  output logic [4:0]  rs2,
  output logic [4:0]  rd,
  output logic [31:0] imm,
  output logic [9:0]  funct
);
always_comb begin
  case (instr[6:0])
    rvi_pkg::OP_32: decode_type_r(
      .instr_opcode(rvi_pkg::OP_32),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    rvi_pkg::OP_IMM_32: decode_type_i(
      .instr_opcode(rvi_pkg::OP_IMM_32),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    rvi_pkg::JALR: decode_type_i(
      .instr_opcode(rvi_pkg::JALR),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    rvi_pkg::LOAD: decode_type_i(
      .instr_opcode(rvi_pkg::LOAD),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    rvi_pkg::JAL: decode_type_j(
      .instr_opcode(rvi_pkg::JAL),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    rvi_pkg::LUI: decode_type_u(
      .instr_opcode(rvi_pkg::LUI),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    rvi_pkg::AUIPC: decode_type_u(
      .instr_opcode(rvi_pkg::AUIPC),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    rvi_pkg::BRANCH: decode_type_b(
      .instr_opcode(rvi_pkg::BRANCH),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    rvi_pkg::STORE: decode_type_s(
      .instr_opcode(rvi_pkg::STORE),
      .instr(instr),
      .opcode(opcode),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm),
      .funct(funct)
    );
    default: begin
      opcode = rvi_pkg::RESERVED_4;
      rs1    = '0;
      rs2    = '0;
      rd     = '0;
      imm    = '0;
      funct  = '0;
    end
  endcase
end

task decode_type_u;
  input opcode_e      instr_opcode;
  input [31:0]        instr;
  output opcode_e     opcode;
  output logic [4:0]  rs1;
  output logic [4:0]  rs2;
  output logic [4:0]  rd;
  output logic [31:0] imm;
  output logic [9:0]  funct;

  opcode = instr_opcode;
  rd     = instr[11:7];
  rs1    = '0;
  rs2    = '0;
  imm    = {instr[31:12],12'b0};
  funct  = '0;
endtask : decode_type_u

task decode_type_j;
  input opcode_e      instr_opcode;
  input [31:0]        instr;
  output opcode_e     opcode;
  output logic [4:0]  rs1;
  output logic [4:0]  rs2;
  output logic [4:0]  rd;
  output logic [31:0] imm;
  output logic [9:0]  funct;

  opcode = instr_opcode;
  rd     = instr[11:7];
  rs1    = '0;
  rs2    = '0;
  imm    = 32'($signed({instr[31],instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0}));
  funct  = '0;
endtask : decode_type_j

task decode_type_i;
  input opcode_e      instr_opcode;
  input [31:0]        instr;
  output opcode_e     opcode;
  output logic [4:0]  rs1;
  output logic [4:0]  rs2;
  output logic [4:0]  rd;
  output logic [31:0] imm;
  output logic [9:0]  funct;

  opcode = instr_opcode;
  rd     = instr[11:7];
  rs1    = instr[19:15];
  rs2    = '0;
  if (opcode == rvi_pkg::OP_IMM && instr[14:12] inside {rvi_pkg::SLLI[2:0],rvi_pkg::SRLI[2:0],rvi_pkg::SRAI[2:0]}) begin
    imm   = 32'(instr[24:20]);
    funct = {instr[14:12],instr[31:25]};
  end else begin
    imm   = 32'($signed(instr));
    funct = 10'(instr[14:12]);
  end
endtask : decode_type_i

task decode_type_r;
  input opcode_e      instr_opcode;
  input [31:0]        instr;
  output opcode_e     opcode;
  output logic [4:0]  rs1;
  output logic [4:0]  rs2;
  output logic [4:0]  rd;
  output logic [31:0] imm;
  output logic [9:0]  funct;

  opcode = instr_opcode;
  rd     = instr[11:7];
  rs1    = instr[19:15];
  rs2    = instr[24:20];
  imm    = '0;
  funct  = {instr[31:25],instr[14:12]};
endtask : decode_type_r

task decode_type_b;
  input opcode_e      instr_opcode;
  input [31:0]        instr;
  output opcode_e     opcode;
  output logic [4:0]  rs1;
  output logic [4:0]  rs2;
  output logic [4:0]  rd;
  output logic [31:0] imm;
  output logic [9:0]  funct;

  opcode = instr_opcode;
  rd     = '0;
  rs1    = instr[19:15];
  rs2    = instr[24:20];
  imm    = 32'($signed({instr[31],instr[7],instr[30:25],instr[11:8],1'b0}));
  funct  = 10'(instr[14:12]);
endtask : decode_type_b

task decode_type_s;
  input opcode_e      instr_opcode;
  input [31:0]        instr;
  output opcode_e     opcode;
  output logic [4:0]  rs1;
  output logic [4:0]  rs2;
  output logic [4:0]  rd;
  output logic [31:0] imm;
  output logic [9:0]  funct;

  opcode = instr_opcode;
  rd     = '0;
  rs1    = instr[19:15];
  rs2    = instr[24:20];
  imm    = 32'($signed({instr[31:25],instr[11:7]}));
  funct  = 10'(instr[14:12]);
endtask : decode_type_s

endmodule
