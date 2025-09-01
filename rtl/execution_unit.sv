`include "copperv_pkg.sv"

module execution_unit 
  import copperv_pkg::instr_t;
  import copperv_pkg::mem_cmd_t;
  import copperv_pkg::mem_rsp_t;
  import copperv_pkg::regfile_cmd_t;
  import copperv_pkg::regfile_rsp_t;
(
  input                clk, 
  input                rstn,
  input  instr_t       decoded_instr,
  input                instr_valid,
  output mem_cmd_t     imem_cmd,
  input  mem_rsp_t     imem_rsp,
  output mem_cmd_t     dmem_cmd,
  input  mem_rsp_t     dmem_rsp,
  output regfile_cmd_t regfile_cmd,
  input  regfile_rsp_t regfile_rsp
);
  
endmodule

