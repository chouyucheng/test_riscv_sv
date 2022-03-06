module u_exe (
input clk,
input rstn,
// ifu
input [31:0] pc,
// dec
input i_LUI,
input i_AUIPC,
input i_JAL,
input i_JALR,
input i_B,
input i_LD,
input i_ST,
input i_ALUi,
input i_ALU,
input i_F,
input i_E,
input i_CSR,
input [4:0]  rs1_a,
input [4:0]  rs2_a_shamt,
input [4:0]  rd_a,
input [2:0]  funct3,
input [6:0]  funct7,
input [31:0] imm,
// rf
input        [31:0] rf_rs1_o,
input        [31:0] rf_rs2_o,
output logic        rf_rd_e,
output logic [4:0]  rf_rd_a,
output logic [31:0] rf_rd_i,
// hazard
input flush0,
// br_ctrl
output logic        branch,
// br_adr
output logic [31:0] br_adr_i1,
output logic [31:0] br_adr_i2,
// alu
output logic [3:0]  alu_op,
output logic [31:0] alu_i1,
output logic [31:0] alu_i2,
input        [31:0] alu_o
// csr

// lsu
);

// input reg 
logic [31:0] reg_pc;
logic        reg_iLUI;
logic        reg_iAUIPC;
logic        reg_iJAL;
logic        reg_iJALR;
logic        reg_iB;
logic        reg_iLD;
logic        reg_iST;
logic        reg_iALUi;
logic        reg_iALU;
logic        reg_iF;
logic        reg_iE;
logic        reg_iCSR;
logic [4:0]  reg_rs1_a;
logic [4:0]  reg_rs2_a_shamt;
logic [4:0]  reg_rd_a;
logic [2:0]  reg_f3;
logic [6:0]  reg_f7;
logic [31:0] reg_imm;
logic [31:0] reg_rs1_o;
logic [31:0] reg_rs2_o;

// forwarding
logic [31:0] fwd_o1;
logic [31:0] fwd_o2;

// write regfile buffer
logic        buf0_we;
logic  [4:0] buf0_a;
logic [31:0] buf0_d;
logic        buf1_we;
logic  [4:0] buf1_a;
logic [31:0] buf1_d;
logic        buf2_we;
logic  [4:0] buf2_a;
logic [31:0] buf2_d;

always_ff@(posedge clk or negedge rstn) begin: input_reg
  if(!rstn) begin
    reg_pc          <= 0;
    reg_iLUI        <= 0;
    reg_iAUIPC      <= 0;
    reg_iJAL        <= 0;
    reg_iJALR       <= 0;
    reg_iB          <= 0;
    reg_iLD         <= 0;
    reg_iST         <= 0;
    reg_iALUi       <= 0;
    reg_iALU        <= 0;
    reg_iF          <= 0;
    reg_iE          <= 0;
    reg_iCSR        <= 0;
    reg_rs1_a       <= 0;
    reg_rs2_a_shamt <= 0;
    reg_rd_a        <= 0;
    reg_f3          <= 0;
    reg_f7          <= 0;
    reg_imm         <= 0;
    reg_rs1_o       <= 0;
    reg_rs2_o       <= 0;
  end else if(flush0) begin
    reg_iLUI        <= 0; 
    reg_iAUIPC      <= 0; 
    reg_iJAL        <= 0; 
    reg_iJALR       <= 0; 
    reg_iB          <= 0; 
    reg_iLD         <= 0; 
    reg_iST         <= 0; 
    reg_iALUi       <= 0; 
    reg_iALU        <= 0; 
    reg_iF          <= 0; 
    reg_iE          <= 0; 
    reg_iCSR        <= 0; 
  end else begin
    reg_pc          <= pc;
    reg_iLUI        <= i_LUI;
    reg_iAUIPC      <= i_AUIPC;
    reg_iJAL        <= i_JAL;
    reg_iJALR       <= i_JALR;
    reg_iB          <= i_B;
    reg_iLD         <= i_LD;
    reg_iST         <= i_ST;
    reg_iALUi       <= i_ALUi;
    reg_iALU        <= i_ALU;
    reg_iF          <= i_F;
    reg_iE          <= i_E;
    reg_iCSR        <= i_CSR;
    reg_rs1_a       <= rs1_a;
    reg_rs2_a_shamt <= rs2_a_shamt;
    reg_rd_a        <= rd_a;
    reg_f3          <= funct3;
    reg_f7          <= funct7;
    reg_imm         <= imm;
    reg_rs1_o       <= rf_rs1_o;
    reg_rs2_o       <= rf_rs2_o;
  end
end

always_comb begin: forwarding_ctrl
  fwd_o1 = (reg_iAUIPC) ? reg_pc : 
           (reg_iJAL)   ? reg_pc : reg_rs1_o;
  fwd_o2 = (reg_iAUIPC)                 ? reg_imm     :
           (reg_iJAL)                   ? 32'd4       : 
           (reg_iALUi & reg_f3==3'b001) | 
           (reg_iALUi & reg_f3==3'b101) ? rs2_a_shamt :
           (reg_iALUi)                  ? reg_imm     : reg_rs2_o;
end

always_comb begin: branch_ctrl
  branch = (reg_iJAL);
end

always_comb begin: branch_adr_ctrl
  br_adr_i1 = reg_pc;
  br_adr_i2 = reg_imm;
end

always_comb begin: alu_ctrl
  alu_op[2:0] = (reg_iAUIPC) ? 3'b000 : reg_f3;
  alu_op[3]   = (reg_iALU) | 
                (reg_iALUi & reg_f3==3'b101) ? reg_f7[5] : 0; 

  alu_i1 = fwd_o1;
  alu_i2 = fwd_o2; 
end

always_ff@(posedge clk or negedge rstn) begin: write_regfile_buffer
  if(!rstn) begin
    buf0_we <= 0;
    buf0_a  <= 0;
    buf0_d  <= 0;
    buf1_we <= 0;
    buf1_a  <= 0;
    buf1_d  <= 0;
    buf2_we <= 0;
    buf2_a  <= 0;
    buf2_d  <= 0;
  end else begin
    buf0_we <= (reg_iAUIPC | reg_iJAL | reg_iALU | reg_iALUi);
    buf0_a  <= (reg_iAUIPC | reg_iJAL | reg_iALU | reg_iALUi) ? reg_rd_a : 0;
    buf0_d  <= (reg_iAUIPC | reg_iJAL | reg_iALU | reg_iALUi) ? alu_o    : 0;
    buf1_we <=  buf0_we;
    buf1_a  <=  buf0_a;
    buf1_d  <=  buf0_d;
    buf2_we <=  buf1_we;
    buf2_a  <=  buf1_a;
    buf2_d  <=  buf1_d;
  end
end

always_comb begin: write_regfile_ctrl
  rf_rd_e = buf2_we;
  rf_rd_a = buf2_a;
  rf_rd_i = buf2_d; 
end

endmodule







