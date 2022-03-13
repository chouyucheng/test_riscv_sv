module core(
input clk,
input rstn,
// sram0 instrusction
output  [15:0] ins_a,
output         ins_e,
input   [31:0] ins,
// sram1 data
output [15:0]  dat_a,
output [3:0]   dat_we,
output [31:0]  dat_wd,
output [3:0]   dat_re,
input  [31:0]  dat_rd
);

// instruction fetch unit 
logic        ifu_vd;
logic [31:0] ifu_pc;
logic [31:0] ifu_ins;

// decoder
logic i_LUI;
logic i_AUIPC;
logic i_JAL;
logic i_JALR;
logic i_B;
logic i_LD;
logic i_ST;
logic i_ALUi;
logic i_ALU;
logic i_F;
logic i_E;
logic i_CSR;
logic [4:0]  rs1_a;
logic [4:0]  rs2_a_shamt;
logic [4:0]  rd_a;
logic [2:0]  funct3;
logic [6:0]  funct7;
logic [31:0] imm;

// regfile
logic [31:0] rf_rs1_o;
logic [31:0] rf_rs2_o;
logic        rf_rd_e;
logic [4:0]  rf_rd_a;
logic [31:0] rf_rd_i;

// hazard
logic hzf_ifu;
logic hzf_ex0;

// branch control
logic branch;

// branch address
logic [31:0] br_adr_i1;
logic [31:0] br_adr_i2;
logic [31:0] br_adr_o;


// alu 
logic [3:0]  alu_op;
logic [31:0] alu_i1;
logic [31:0] alu_i2;
logic [31:0] alu_o;
logic        alu_lt;
logic        alu_ltu;

u_ifu u_ifu0(
.clk     (clk     ),
.rstn    (rstn    ),
.flush   (hzf_ifu ),
.branch  (branch  ),
.br_adr  (br_adr_o),
.ifu_vld (ifu_vld ),
.ifu_pc  (ifu_pc  ),
.ifu_ins (ifu_ins ), 
.ins_a   (ins_a   ),
.ins_e   (ins_e   ),
.ins     (ins     )
);

u_dec u_dec0(
.ins         (ifu_ins    ),
.i_LUI       (i_LUI      ),
.i_AUIPC     (i_AUIPC    ),
.i_JAL       (i_JAL      ),
.i_JALR      (i_JALR     ),
.i_B         (i_B        ),
.i_LD        (i_LD       ),
.i_ST        (i_ST       ),
.i_ALUi      (i_ALUi     ),
.i_ALU       (i_ALU      ),
.i_F         (i_F        ),
.i_E         (i_E        ),
.i_CSR       (i_CSR      ),
.rs1_a       (rs1_a      ),
.rs2_a_shamt (rs2_a_shamt),
.rd_a        (rd_a       ),
.funct3      (funct3     ),
.funct7      (funct7     ),
.imm         (imm        ) 
);

u_rf u_rf0(
.clk   (clk        ),
.rs1_a (rs1_a      ),
.rs2_a (rs2_a_shamt),
.rs1_o (rf_rs1_o   ),
.rs2_o (rf_rs2_o   ),
.rd_e  (rf_rd_e    ),
.rd_a  (rf_rd_a    ),
.rd_i  (rf_rd_i    )
);

u_hz u_hz0 (
.ifu_vld (ifu_vld),
.branch  (branch ),
.hzf_ifu (hzf_ifu),
.hzf_ex0 (hzf_ex0)
);

u_exe u_exe0 (
.clk         (clk        ),
.rstn        (rstn       ),
// ifu
.pc          (ifu_pc     ),
// dec
.i_LUI       (i_LUI      ),
.i_AUIPC     (i_AUIPC    ),
.i_JAL       (i_JAL      ),
.i_JALR      (i_JALR     ),
.i_B         (i_B        ),
.i_LD        (i_LD       ),
.i_ST        (i_ST       ),
.i_ALUi      (i_ALUi     ),
.i_ALU       (i_ALU      ),
.i_F         (i_F        ),
.i_E         (i_E        ),
.i_CSR       (i_CSR      ),
.rs1_a       (rs1_a      ),
.rs2_a_shamt (rs2_a_shamt),
.rd_a        (rd_a       ),
.funct3      (funct3     ),
.funct7      (funct7     ),
.imm         (imm        ),
// rf
.rf_rs1_o    (rf_rs1_o   ),
.rf_rs2_o    (rf_rs2_o   ),
.rf_rd_e     (rf_rd_e    ),
.rf_rd_a     (rf_rd_a    ),
.rf_rd_i     (rf_rd_i    ),
// hazard
.flush0      (hzf_ex0    ),
// br_ctrl
.branch      (branch     ),
// br_adr
.br_adr_i1   (br_adr_i1  ),
.br_adr_i2   (br_adr_i2  ),
// alu
.alu_op      (alu_op     ),
.alu_i1      (alu_i1     ),
.alu_i2      (alu_i2     ),
.alu_o       (alu_o      ), 
.alu_lt      (alu_lt     ),
.alu_ltu     (alu_ltu    )
// csr

// lsu
);

u_br_adr u_br_adr0(
.br_adr_i1 (br_adr_i1),
.br_adr_i2 (br_adr_i2),
.br_adr_o  (br_adr_o )        
);

u_alu u_alu0(
.alu_op  (alu_op ),
.alu_i1  (alu_i1 ),
.alu_i2  (alu_i2 ),
.alu_o   (alu_o  ), 
.alu_lt  (alu_lt ),
.alu_ltu (alu_ltu)
);
    
endmodule







