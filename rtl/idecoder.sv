`include "copperv_pkg.sv"

module idecoder import copperv_pkg::instr_t; (
  input [31:0] instr,
  output instr_t decoded_instr
);
import copperv_pkg::opcode_t;
always_comb begin
  case (instr[6:0])
    rvi_pkg::OP:     decoded_instr = decode_type_r(instr,rvi_pkg::OP);
    rvi_pkg::OP_IMM: decoded_instr = decode_type_i(instr,rvi_pkg::OP_IMM);
    rvi_pkg::JALR:   decoded_instr = decode_type_i(instr,rvi_pkg::JALR);
    rvi_pkg::LOAD:   decoded_instr = decode_type_i(instr,rvi_pkg::LOAD);
    rvi_pkg::JAL:    decoded_instr = decode_type_j(instr,rvi_pkg::JAL);
    rvi_pkg::LUI:    decoded_instr = decode_type_u(instr,rvi_pkg::LUI);
    rvi_pkg::AUIPC:  decoded_instr = decode_type_u(instr,rvi_pkg::AUIPC);
    rvi_pkg::BRANCH: decoded_instr = decode_type_b(instr,rvi_pkg::BRANCH);
    rvi_pkg::STORE:  decoded_instr = decode_type_s(instr,rvi_pkg::STORE);
    default:         decoded_instr = '{default: '0, opcode: rvi_pkg::RESERVED_4};
  endcase
end

function automatic instr_t decode_type_u;
  input [31:0] instr;
  input opcode_t opcode;
  decode_type_u.opcode = opcode;
  decode_type_u.rd     = instr[11:7];
  decode_type_u.rs1    = '0;
  decode_type_u.rs2    = '0;
  decode_type_u.imm    = {instr[31:12],12'b0};
  decode_type_u.funct  = '0;
endfunction : decode_type_u

function automatic instr_t decode_type_j;
  input [31:0] instr;
  input opcode_t opcode;
  decode_type_j.opcode = opcode;
  decode_type_j.rd     = instr[11:7];
  decode_type_j.rs1    = '0;
  decode_type_j.rs2    = '0;
  decode_type_j.imm    = 32'($signed({instr[31],instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0}));
  decode_type_j.funct  = '0;
endfunction : decode_type_j

function automatic instr_t decode_type_i;
  input [31:0] instr;
  input opcode_t opcode;
  logic [2:0] funct3;
  logic [11:0] imm;
  decode_type_i.opcode = opcode;
  decode_type_i.rd     = instr[11:7];
  decode_type_i.rs1    = instr[19:15];
  decode_type_i.rs2    = '0;
  funct3 = instr[14:12];
  imm    = instr[31:20];
  if (opcode == rvi_pkg::OP_IMM && funct3 inside {rvi_pkg::SLLI[2:0],rvi_pkg::SRLI[2:0],rvi_pkg::SRAI[2:0]}) begin
    decode_type_i.imm   = 32'(imm[4:0]);
    decode_type_i.funct = {funct3,imm[11:5]};
  end else begin
    decode_type_i.imm   = 32'($signed(imm));
    decode_type_i.funct = 10'(funct3);
  end
endfunction : decode_type_i

function automatic instr_t decode_type_r;
  input [31:0] instr;
  input opcode_t opcode;
  decode_type_r.opcode = opcode;
  decode_type_r.rd     = instr[11:7];
  decode_type_r.rs1    = instr[19:15];
  decode_type_r.rs2    = instr[24:20];
  decode_type_r.imm    = '0;
  decode_type_r.funct  = {instr[31:25],instr[14:12]};
endfunction : decode_type_r

function automatic instr_t decode_type_b;
  input [31:0] instr;
  input opcode_t opcode;
  decode_type_b.opcode = opcode;
  decode_type_b.rd     = '0;
  decode_type_b.rs1    = instr[19:15];
  decode_type_b.rs2    = instr[24:20];
  decode_type_b.imm    = 32'($signed({instr[31],instr[7],instr[30:25],instr[11:8],1'b0}));
  decode_type_b.funct  = 10'(instr[14:12]);
endfunction : decode_type_b

function automatic instr_t decode_type_s;
  input [31:0] instr;
  input opcode_t opcode;
  decode_type_s.opcode = opcode;
  decode_type_s.rd     = '0;
  decode_type_s.rs1    = instr[19:15];
  decode_type_s.rs2    = instr[24:20];
  decode_type_s.imm    = 32'($signed({instr[31:25],instr[11:7]}));
  decode_type_s.funct  = 10'(instr[14:12]);
endfunction : decode_type_s

endmodule
