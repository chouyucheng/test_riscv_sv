module u_hz (
input  ifu_en,
input  branch,
output logic hzf_ifu,
output logic hzf_ex0
);

always_comb begin
  hzf_ifu = 0;
  hzf_ex0 = 0;
  if(!ifu_en) begin: no_instruction
    hzf_ex0 = 1;
  end
  if(branch) begin: branch_instruction
    hzf_ifu = 1;
    hzf_ex0 = 1;
  end
end

endmodule





