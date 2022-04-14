module u_alu(
input        [3:0]  alu_op,
input        [31:0] alu_i1,
input        [31:0] alu_i2,
output logic [31:0] alu_o,
output logic        alu_eq,
output logic        alu_lt,
output logic        alu_ltu
);

localparam [3:0]
OP_ADD  = 4'b0000,
OP_SUB  = 4'b1000,
OP_SLL  = 4'b0001,
OP_SLT  = 4'b0010,
OP_SLTU = 4'b0011,
OP_XOR  = 4'b0100,
OP_SRL  = 4'b0101,
OP_SRA  = 4'b1101,
OP_OR   = 4'b0110,
OP_AND  = 4'b0111;

logic signed [31:0] sig_i1;
logic signed [31:0] sig_i2;

always_comb begin: unsigned_to_signed
  sig_i1 = alu_i1;
  sig_i2 = alu_i2;
end

always_comb begin: compare_for_branch
  alu_eq  = (alu_i1 == alu_i2);
  alu_lt  = (sig_i1 <  sig_i2); 
  alu_ltu = (alu_i1 <  alu_i2); 
end

always_comb begin: alu_output
  alu_o = (alu_op==OP_ADD ) ? alu_i1  +  alu_i2      : 
          (alu_op==OP_SUB ) ? alu_i1  -  alu_i2      : 
          (alu_op==OP_SLL ) ? alu_i1 <<  alu_i2[4:0] : 
          (alu_op==OP_SLT ) ? {31'b0,    alu_lt}     : 
          (alu_op==OP_SLTU) ? {31'b0,    alu_ltu}    : 
          (alu_op==OP_XOR ) ? alu_i1  ^  alu_i2      : 
          (alu_op==OP_SRL ) ? alu_i1  >> alu_i2[4:0] : 
          (alu_op==OP_SRA ) ? sig_i1 >>> alu_i2[4:0] : 
          (alu_op==OP_OR  ) ? alu_i1  |  alu_i2      : 
          (alu_op==OP_AND ) ? alu_i1  &  alu_i2      : 0; 
end

endmodule
