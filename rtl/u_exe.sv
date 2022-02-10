module u_exe (
input clk,
input rstn,
// from dec
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
// alu
output logic [3:0]  alu_op,
output logic [31:0] alu_i1,
output logic [31:0] alu_i2,
input        [31:0] alu_o
// csr

// lsu
);

// input reg
logic reg_iLUI;
logic reg_iAUIPC;
logic reg_iJAL;
logic reg_iJALR;
logic reg_iB;
logic reg_iLD;
logic reg_iST;
logic reg_iALUi;
logic reg_iALU;
logic reg_iF;
logic reg_iE;
logic reg_iCSR;
logic [4:0]  reg_rs1_a;
logic [4:0]  reg_rs2_a_shamt;
logic [4:0]  reg_rd_a;
logic [2:0]  reg_funct3;
logic [6:0]  reg_funct7;
logic [31:0] reg_imm;
logic [31:0] reg_rs1_o;
logic [31:0] reg_rs2_o;

always@(posedge clk or negedge rstn) begin: input_reg
  if(!rstn) begin
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
    reg_funct3      <= 0;
    reg_funct7      <= 0;
    reg_imm         <= 0;
    reg_rs1_o       <= 0;
    reg_rs2_o       <= 0;
  end else begin
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
    reg_funct3      <= funct3;
    reg_funct7      <= funct7;
    reg_imm         <= imm;
    reg_rs1_o       <= rf_rs1_o;
    reg_rs2_o       <= rf_rs2_o;
  end
end

always_comb begin: alu_ctrl
  alu_op[2:0] = reg_funct3;
  alu_op[3]   = (reg_iALU) | 
                (reg_iALUi & reg_funct3==3'b101) ? reg_funct7[5] : 0; 
end


endmodule







