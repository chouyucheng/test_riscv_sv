module u_ifu (
input clk,
input rstn,
// hazard
input flush,
input stall,
// branch
input        branch,
input [31:0] br_adr,
// output
output logic        ifu_vld,
output logic [31:0] ifu_pc,
output logic [31:0] ifu_ins,
// sram 0
output logic [15:0] ins_a,
output              ins_e,
input        [31:0] ins
);

logic en_p1;

logic [31:0] pc;
logic [31:0] pc_p1;

always_ff@(posedge clk or negedge rstn) begin: pipe0_reg_pc
  if(!rstn) pc <= 0;
  else      pc <= branch ? br_adr :
                  !stall ? pc + 4 : pc;
end

assign ins_e = 1;
always_comb begin: pipe0_ctrl_ins_mem
  ins_a = pc[15:0];
end

always_ff@(posedge clk or negedge rstn) begin: pipe1_reg
  if(!rstn) begin 
    en_p1 <= 0;
    pc_p1 <= 0;
  end else if(flush) begin
    en_p1 <= 0;
    pc_p1 <= 0;
  end else if(!stall)begin
    en_p1 <= 1;
    pc_p1 <= pc;
  end
end

always_ff@(posedge clk or negedge rstn) begin: pipe2_reg
  if(!rstn) begin
    ifu_vld <= 0;
    ifu_pc  <= 0;
    ifu_ins <= 0;
  end else if(flush) begin
    ifu_vld <= 0;
    ifu_pc  <= 0;
    ifu_ins <= 0;
  end else if(!stall)begin
    ifu_vld <= en_p1;
    ifu_pc  <= pc_p1;
    ifu_ins <= ins;
  end
end

endmodule




