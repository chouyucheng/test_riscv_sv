module u_exe (
input clk,
input rstn,
// from dec
input i_LUI;
input i_AUIPC;
input i_JAL;
input i_JALR;
input i_B;
input i_LD;
input i_ST;
input i_ALUi;
input i_ALU;
input i_F;
input i_E;
input i_CSR;
input [4:0]  rs1_a;
input [4:0]  rs2_a_shamt;
input [4:0]  rd_a;
input [2:0]  funct3;
input [6:0]  funct7;
input [31:0] imm;
// rf
input  [31:0] rf_rs1_o;
input  [31:0] rf_rs2_o;
output        rf_rd_e;
output [4:0]  rf_rd_a;
output [31:0] rf_rd_i;
// alu

// csr

// lsu
);

endmodule







