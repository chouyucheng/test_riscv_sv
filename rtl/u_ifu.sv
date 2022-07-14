module u_ifu (
input clk,
input rstn,
// program counter
input [31:0] pc,
// sram 0
output logic [15:0] ins_a,
output              ins_e,
input        [31:0] ins,
// output
output logic [31:0] ins_reg
);

assign ins_e = 1;
always_comb begin: ctrl_ins_mem
  ins_a = pc[15:0];
end

always_ff@(posedge clk or negedge rstn) begin: fetch_ins
  if(!rstn) ins_reg <= 0;
  else      ins_reg <= ins;
end

endmodule





