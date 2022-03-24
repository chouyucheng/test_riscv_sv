module u_hz (
input  ifu_vld,
input  branch,
input  fwd_no_dat,
output logic hzf_ifu,
output logic hzf_ex0,
output logic hzs_ifu,
output logic hzs_ex0,
output logic hzs_ex1,
output logic hzs_ex2
);

always_comb begin
  hzf_ifu = 0;
  hzf_ex0 = 0;
  hzs_ifu = 0;
  hzs_ex0 = 0;
  hzs_ex1 = 0;
  hzs_ex2 = 0;
  if(!ifu_vld) begin: no_instruction
    hzf_ex0 = 1;
  end
  if(branch) begin: branch_instruction
    hzf_ifu = 1;
    hzf_ex0 = 1;
  end
  if(fwd_no_dat) begin: forwarding_no_data
    hzs_ifu = 1;
    hzs_ex0 = 1;
    hzf_ex1 = 1;
  end
end

endmodule





