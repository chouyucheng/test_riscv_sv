module u_ifu (
input clk,
input rstn,
// sram 0
output logic [15:0] ins_a,
output              ins_e,
input        [31:0] ins,
// output
output logic [31:0] ifu_pc,
output logic [31:0] ifu_ins
);

logic [31:0] pc;
logic [31:0] pc_d1;

always_ff@(posedge clk or negedge rstn) begin: p1_reg_pc
  if(!rstn) pc <= 0;
  else      pc <= pc + 4;
end

assign ins_e = 1;
always_comb begin: p1_ctrl_ins_mem
  ins_a = pc[15:0];
end

always_ff@(posedge clk or negedge rstn) begin: p2_reg_pc_d1
  if(!rstn) pc_d1 <= 0;
  else      pc_d1 <= pc;
end

always_ff@(posedge clk or negedge rstn) begin: p3_reg_pc_d2
  if(!rstn) ifu_pc <= 0;
  else      ifu_pc <= pc_d1;
end

always_ff@(posedge clk or negedge rstn) begin: p3_reg_ins
  if(!rstn) ifu_ins <= 0;
  else      ifu_ins <= ins;
end

endmodule




