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

// program counter
logic [31:0] pc;

// instruction fetch 
logic [31:0] ins_reg;

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
logic [31:0] rs1_o;
logic [31:0] rs2_o;
logic        rf_rd_e;
logic [4:0]  rf_rd_a;
logic [31:0] rf_rd_i;

u_pc u_pc0(
.clk  (clk ),
.rstn (rstn),
.pc   (pc  )
);

u_ifu u_ifu0(
.clk     (clk    ),
.rstn    (rstn   ),
.pc      (pc     ),
.ins_a   (ins_a  ),
.ins_e   (ins_e  ),
.ins     (ins    ),
.ins_reg (ins_reg) 
);

u_dec u_dec0(
.ins         (ins_reg    ),
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
.rs1_o (rs1_o      ),
.rs2_o (rs2_o      ),
.rd_e  (rf_rd_e    ),
.rd_a  (rf_rd_a    ),
.rd_i  (rf_rd_i    )
);

endmodule







