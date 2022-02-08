module u_pc(
input  clk,
input  rstn,
// output
output logic [31:0] pc 
); 

always_ff@(posedge clk or negedge rstn) begin: reg_pc
  if(!rstn) pc <= 0;
  else      pc <= pc + 4; 
end

endmodule
