module u_dec(
input [31:0] ins,
output logic i_LUI,
output logic i_AUIPC,
output logic i_JAL,
output logic i_JALR,
output logic i_B,
output logic i_LD,
output logic i_ST,
output logic i_ALUi,
output logic i_ALU,
output logic i_F,
output logic i_E,
output logic i_CSR,
output logic [4:0]  rs1_a,
output logic [4:0]  rs2_a_shamt,
output logic [4:0]  rd_a,
output logic [2:0]  funct3,
output logic [6:0]  funct7,
output logic [31:0] imm
);

logic [6:0]  opcode;
logic [31:0] iimm;
logic [31:0] simm;
logic [31:0] bimm;
logic [31:0] uimm;
logic [31:0] jimm;

always_comb begin: ctrl_decode
  funct7      = ins[31:25];
  rs2_a_shamt = ins[24:20];
  rs1_a       = ins[19:15];
  funct3      = ins[14:12];
  rd_a        = ins[11:7];
  opcode      = ins[6:0];
  iimm        = {{21{ins[31]}},ins[30:25],ins[24:21],ins[20]};
  simm        = {{21{ins[31]}},ins[30:25],ins[11:8], ins[7]};
  bimm        = {{21{ins[31]}},ins[7],    ins[30:25],ins[11:8],            1'b0};
  uimm        = {    ins[31],  ins[30:20],ins[19:12],                     12'b0};
  jimm        = {{11{ins[31]}},ins[19:12],ins[20],   ins[30:25],ins[24:21],1'b0};
end

always_comb begin: ctrl_opcode
  i_LUI   = (opcode==7'b0110111);
  i_AUIPC = (opcode==7'b0010111);
  i_JAL   = (opcode==7'b1101111);
  i_JALR  = (opcode==7'b1100111)&(funct3==3'b000);
  i_B     = (opcode==7'b1100011)&(funct3!=3'b010)&(funct3!=3'b011);  
  i_LD    = (opcode==7'b0000011);
  i_ST    = (opcode==7'b0100011);
  i_ALUi  = (opcode==7'b0010011);
  i_ALU   = (opcode==7'b0110011);
  i_F     = (opcode==7'b0001111);
  i_E     = (opcode==7'b1110011);
  i_CSR   = (opcode==7'b1110011);
end

always_comb begin: mux_imm
  imm = (i_LUI   ? uimm:0)|    
        (i_AUIPC ? uimm:0)| 
        (i_JAL   ? jimm:0)| 
        (i_JALR  ? iimm:0)| 
        (i_B     ? bimm:0)| 
        (i_LD    ? iimm:0)| 
        (i_ST    ? simm:0)|
        (i_ALUi  ? iimm:0);
end

endmodule






