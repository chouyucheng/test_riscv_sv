module u_rf(
input clk,
// read regfile
input        [4:0]  rs1_a,
input        [4:0]  rs2_a,
output logic [31:0] rs1_o,
output logic [31:0] rs2_o,
// write regfile
input        rd_e,
input [4:0]  rd_a,
input [31:0] rd_i
);

logic [31:0] rf_arr [1:31];

always_ff@(posedge clk) begin: writhe_data
  if(rd_e & rd_a!=0) rf_arr[rd_a] <= rd_i;
end

always_comb begin: read_data
  rs1_o = (rs1_a==0)    ? 0    :
          (rs1_a==rd_a) ? rd_i : rf_arr[rs1_a];
  rs2_o = (rs2_a==0)    ? 0    :
          (rs2_a==rd_a) ? rd_i : rf_arr[rs2_a];
end

endmodule





