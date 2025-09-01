`ifndef COPPERV_PKG_HEADER_GUARD
`define COPPERV_PKG_HEADER_GUARD

`include "rvi_pkg.sv"

package copperv_pkg;
  import rvi_pkg::opcode_t;
  export rvi_pkg::opcode_t;

  typedef struct {
    opcode_t     opcode;
    logic [4:0]  rd;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [31:0] imm;
    logic [9:0]  funct;
  } instr_t;

  typedef struct {
    logic [31:0] addr;
    logic [31:0] wr_data;
    logic en;
    logic we;
  } mem_cmd_t;

  typedef struct {
    logic [31:0] rd_data;
    logic ready;
  } mem_rsp_t;

  typedef struct {
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [31:0] rd_data;
    logic rd_en;
  } regfile_cmd_t;

  typedef struct {
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
  } regfile_rsp_t;

endpackage : copperv_pkg

`endif // COPPERV_PKG_HEADER_GUARD
