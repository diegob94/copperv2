
module regfile (
  input  logic        clk,
  input  logic        rstn,
  input  logic [4:0]  rd,
  input  logic [4:0]  rs1,
  input  logic [4:0]  rs2,
  input  logic [31:0] rd_data,
  input  logic        rd_en,
  output logic [31:0] rs1_data,
  output logic [31:0] rs2_data
);
logic [31:0] mem [1:31];

always_ff @(posedge clk, negedge rstn) begin : regfile_write
  if (!rstn) begin
    for (int i = 1; i < 32; i++) begin
      mem[i] <= '0;
    end
  end else begin
    if (rd_en && rd != 0) begin
      mem[rd] <= rd_data;
    end
  end
end : regfile_write

always_comb begin : regfile_read
  rs1_data = rs1 == 0 ? '0 : mem[rs1];
  rs2_data = rs1 == 0 ? '0 : mem[rs2];
end : regfile_read

endmodule