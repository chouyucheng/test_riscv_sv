module u_br_adr(
input        [31:0] br_adr_i1,
input        [31:0] br_adr_i2,
output logic [31:0] br_adr_o
);

always_comb begin
  br_adr_o = br_adr_i1 + br_adr_i2;
end

endmodule
