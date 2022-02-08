module u_alu(
input        [2:0]  f3,
input               f7_b5,
input        [31:0] alu_i1,
input        [31:0] alu_i2,
output logic [31:0] alu_o
);

localparam [2:0]
ADD_SUB = 3'b000,
SLL     = 3'b001,
SLT     = 3'b010,
SLTU    = 3'b011,
XOR     = 3'b100,
SRL_SRA = 3'b101,
OR      = 3'b110,
AND     = 3'b111;

logic [32:0] add_i1;
logic [32:0] add_i2;
logic [32:0] add_o;

logic [31:0] sll_o;
logic [31:0] slt_o;
logic [31:0] sltu_o;
logic [31:0] xor_o;

logic [31:0] srl_o;
logic [31:0] sra_msk;
logic [31:0] srla_o;

logic [31:0] or_o;
logic [31:0] and_o;

always_comb begin: add_ctrl_input
  add_i1 = {1'b0, alu_i1};
  add_i2 = ((f3==ADD_SUB & f7_b5) | 
             f3==SLT   | 
             f3==SLTU) ? {1'b1, -alu_i2} : {1'b0, alu_i2};
end

always_comb begin: add_cal
  add_o = add_i1 + add_i2;
end

always_comb begin: sll_cal
  sll_o = alu_i1 << alu_i2[4:0];
end

always_comb begin: slt_cal
  slt_o = {31'b0, add_o[31]};
end

always_comb begin: sltu_cal
  slt_o = {31'b0, add_o[32]};
end

always_comb begin: xor_cal
  xor_o = alu_i1 ^ alu_i2;
end

always_comb begin: srl_sra_cal
  srl_o   =  alu_i1        >> alu_i2[4:0];
  sra_msk =  32'hffff_ffff >> alu_i2[4:0];
  srla_o  = (alu_i1[31] & f7_b5) ? ~sra_msk | srl_o : srl_o; 
end

always_comb begin: or_cal
  or_o = alu_i1 | alu_i2;
end

always_comb begin: and_cal
  and_o = alu_i1 & alu_i2;
end

always_comb begin: alu_output
  alu_o = (f3==ADD_SUB) ? add_o  : 
          (f3==SLL    ) ? sll_o  : 
          (f3==SLT    ) ? slt_o  : 
          (f3==SLTU   ) ? sltu_o : 
          (f3==XOR    ) ? xor_o  : 
          (f3==SRL_SRA) ? srla_o : 
          (f3==OR     ) ? or_o   : 
          (f3==AND    ) ? and_o  : 0; 
end

endmodule
