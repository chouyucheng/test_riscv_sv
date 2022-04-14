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
input        flush0,
input        flush1,
input        stall0,
input        stall1,
input        stall2,
output logic fwd_no_dat,
// br_ctrl
output logic        branch,
// br_adr
output logic [31:0] br_adr_i1,
output logic [31:0] br_adr_i2,
// alu
output logic [3:0]  alu_op,
output logic [31:0] alu_i1,
output logic [31:0] alu_i2,
input        [31:0] alu_o,
input               alu_eq,
input               alu_lt,
input               alu_ltu,
// csr
// lsu
output logic  [31:0] lsu_a,
output logic  [ 3:0] lsu_we,
output logic  [31:0] lsu_wd,
output logic  [ 3:0] lsu_re,
// output
input                lsu_vld,
input         [31:0] lsu_rd
);

// pipe1 input reg 
logic [31:0] p1_pc;
logic        p1_iLUI;
logic        p1_iAUIPC;
logic        p1_iJAL;
logic        p1_iJALR;
logic        p1_iB;
logic        p1_iLD;
logic        p1_iST;
logic        p1_iALUi;
logic        p1_iALU;
logic        p1_iF;
logic        p1_iE;
logic        p1_iCSR;
logic [4:0]  p1_rs1_a;
logic [4:0]  p1_rs2_a_sht;
logic [4:0]  p1_rd_a;
logic [2:0]  p1_f3;
logic [6:0]  p1_f7;
logic [31:0] p1_imm;
logic [31:0] p1_rs1_o;
logic [31:0] p1_rs2_o;

//forwarding
logic [31:0] fwd_o1;
logic [31:0] fwd_o2;

// lsu
logic p2_iLD;
logic p3_iLD;

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

always_ff@(posedge clk or negedge rstn) begin: p1_reg_input
  if(!rstn) begin
    p1_pc        <= 0;
    p1_iLUI      <= 0;
    p1_iAUIPC    <= 0;
    p1_iJAL      <= 0;
    p1_iJALR     <= 0;
    p1_iB        <= 0;
    p1_iLD       <= 0;
    p1_iST       <= 0;
    p1_iALUi     <= 0;
    p1_iALU      <= 0;
    p1_iF        <= 0;
    p1_iE        <= 0;
    p1_iCSR      <= 0;
    p1_rs1_a     <= 0;
    p1_rs2_a_sht <= 0;
    p1_rd_a      <= 0;
    p1_f3        <= 0;
    p1_f7        <= 0;
    p1_imm       <= 0;
    p1_rs1_o     <= 0;
    p1_rs2_o     <= 0;
  end else if(flush0) begin
    p1_iLUI      <= 0; 
    p1_iAUIPC    <= 0; 
    p1_iJAL      <= 0; 
    p1_iJALR     <= 0; 
    p1_iB        <= 0; 
    p1_iLD       <= 0; 
    p1_iST       <= 0; 
    p1_iALUi     <= 0; 
    p1_iALU      <= 0; 
    p1_iF        <= 0; 
    p1_iE        <= 0; 
    p1_iCSR      <= 0; 
  end else if(!stall0) begin
    p1_pc        <= pc;
    p1_iLUI      <= i_LUI;
    p1_iAUIPC    <= i_AUIPC;
    p1_iJAL      <= i_JAL;
    p1_iJALR     <= i_JALR;
    p1_iB        <= i_B;
    p1_iLD       <= i_LD;
    p1_iST       <= i_ST;
    p1_iALUi     <= i_ALUi;
    p1_iALU      <= i_ALU;
    p1_iF        <= i_F;
    p1_iE        <= i_E;
    p1_iCSR      <= i_CSR;
    p1_rs1_a     <= rs1_a;
    p1_rs2_a_sht <= rs2_a_shamt;
    p1_rd_a      <= rd_a;
    p1_f3        <= funct3;
    p1_f7        <= funct7;
    p1_imm       <= imm;
    p1_rs1_o     <= rf_rs1_o;
    p1_rs2_o     <= rf_rs2_o;
  end
end

always_comb begin: p1_ctrl_forwarding
  fwd_o1 = (buf0_we & p1_rs1_a    ==buf0_a) ? buf0_d : 
           (buf1_we & p1_rs1_a    ==buf1_a) ? buf1_d :
           (buf2_we & p1_rs1_a    ==buf2_a) ? buf2_d : p1_rs1_o;
  fwd_o2 = (buf0_we & p1_rs2_a_sht==buf0_a) ? buf0_d : 
           (buf1_we & p1_rs2_a_sht==buf1_a) ? buf1_d :
           (buf2_we & p1_rs2_a_sht==buf2_a) ? buf2_d : p1_rs2_o;

  fwd_no_dat = 
         ((p1_iLUI  | p1_iAUIPC | p1_iJAL)  ? 0 :
          (           p1_rs1_a    ==0)      ? 0 : 
          (!buf0_we & p1_rs1_a    ==buf0_a) | 
          (!buf1_we & p1_rs1_a    ==buf1_a) |
          (!buf2_we & p1_rs1_a    ==buf2_a) ? 1 : 0)|
         ((p1_iLUI  | p1_iAUIPC | p1_iJAL)  ? 0 :
          (p1_iJALR | p1_iLD    | p1_iALUi) ? 0 : 
          (           p1_rs2_a_sht==0)      ? 0 :
          (!buf0_we & p1_rs2_a_sht==buf0_a) |  
          (!buf1_we & p1_rs2_a_sht==buf1_a) | 
          (!buf2_we & p1_rs2_a_sht==buf2_a) ? 1 : 0);
end

always_comb begin: p1_ctrl_branch
  branch = (p1_iJAL)  | 
           (p1_iJALR) |
           (p1_iB & p1_f3==3'b000 &  alu_eq)           |
           (p1_iB & p1_f3==3'b001 & !alu_eq)           |
           (p1_iB & p1_f3==3'b100 &            alu_lt) | 
           (p1_iB & p1_f3==3'b101 & !alu_eq & !alu_lt) |
           (p1_iB & p1_f3==3'b110 &            alu_ltu)|
           (p1_iB & p1_f3==3'b111 & !alu_eq & !alu_ltu);
end

always_comb begin: p1_ctrl_branch_adr
  br_adr_i1 = (p1_iJALR) ? fwd_o1 : p1_pc;
  br_adr_i2 =  p1_imm;
end

always_comb begin: p1_ctrl_alu
  alu_op[3]   = (p1_iALU) | 
                (p1_iALUi & p1_f3==3'b101) ? p1_f7[5] : 0; 
  alu_op[2:0] = (p1_iLUI)   ? 3'b000 :
                (p1_iAUIPC) ? 3'b000 : 
                (p1_iLD)    ? 3'b000 :
                (p1_iST)    ? 3'b000 : p1_f3;

  alu_i1 = (p1_iLUI)   ? 0     :
           (p1_iAUIPC) ? p1_pc : 
           (p1_iJAL)   ? p1_pc : 
           (p1_iJALR)  ? p1_pc : fwd_o1;
  alu_i2 = (p1_iLUI)                  ? p1_imm       :
           (p1_iAUIPC)                ? p1_imm       :
           (p1_iJAL)                  ? 32'd4        : 
           (p1_iJALR)                 ? 32'd4        :
           (p1_iST)                   ? p1_imm       :
           (p1_iLD)                   ? p1_imm       :
           (p1_iALUi & p1_f3==3'b001) | 
           (p1_iALUi & p1_f3==3'b101) ? p1_rs2_a_sht :
           (p1_iALUi)                 ? p1_imm       : fwd_o2;
end

always_ff@(posedge clk or negedge rstn) begin: p2_reg_lsu
  if(!rstn) begin
    lsu_a  <= 0;
    lsu_we <= 0;
    lsu_wd <= 0;
    lsu_re <= 0;
    p2_iLD <= 0;
  end else if(flush1) begin
    lsu_a  <= 0;
    lsu_we <= 0;
    lsu_wd <= 0;
    lsu_re <= 0;
    p2_iLD <= 0;
  end else if(!stall1) begin
    lsu_a  <= (p1_iST) ? alu_o : 
              (p1_iLD) ? alu_o : lsu_a;
    lsu_we <= (p1_iST  & p1_f3==3'b010) ? 4'b1111 : 4'b0000;
    lsu_wd <= (p1_iST) ? fwd_o2 : lsu_wd;
    lsu_re <= (p1_iLD  & p1_f3==3'b010) ? 4'b1111 : 4'b0000;
    p2_iLD <=  p1_iLD;
  end
end

always_ff@(posedge clk or negedge rstn) begin: p3_reg_lsu
  if(!rstn) begin
    p3_iLD <= 0;
  end else if(!stall2) begin
    p3_iLD <= p2_iLD;
  end
end

always_ff@(posedge clk or negedge rstn) begin: p2_reg_commit
  if(!rstn) begin
    buf0_a  <= 0;
    buf0_we <= 0;
    buf0_d  <= 0;
  end else if(flush1) begin
    buf0_a  <= 0;
    buf0_we <= 0;
  end else if(!stall1) begin
    buf0_a  <=  p1_rd_a;
    buf0_we <= (p1_iLUI | p1_iAUIPC | p1_iJAL | p1_iJALR |
                p1_iALU | p1_iALUi) & (p1_rd_a!=0);
    buf0_d  <= (p1_iLUI | p1_iAUIPC | p1_iJAL | p1_iJALR |
                p1_iALU | p1_iALUi) & (p1_rd_a!=0) ? alu_o   : 0;
  end
end

always_ff@(posedge clk or negedge rstn) begin: p3_reg_commit
  if(!rstn) begin
    buf1_a  <= 0;
    buf1_we <= 0;
    buf1_d  <= 0;
  end else if(!stall2) begin
    buf1_a  <= buf0_a;
    buf1_we <= buf0_we;
    buf1_d  <= buf0_d;
  end
end

always_ff@(posedge clk or negedge rstn) begin: p4_reg_commit
  if(!rstn) begin
    buf2_we <= 0;
    buf2_a  <= 0;
    buf2_d  <= 0;
  end else begin
    buf2_a  <=  buf1_a;
    buf2_we <=  p3_iLD  | buf1_we;
    buf2_d  <= (p3_iLD) ? lsu_rd : buf1_d;
  end
end

always_comb begin: p4_ctrl_write_regfile
  rf_rd_e = buf2_we;
  rf_rd_a = buf2_a;
  rf_rd_i = buf2_d; 
end

endmodule







