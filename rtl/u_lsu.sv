module u_lsu (
input clk,
input rstn,
// input
input  [31:0] lsu_a,
input  [ 3:0] lsu_we,
input  [31:0] lsu_wd,
input  [ 3:0] lsu_re,
// output
output logic        lsu_vld,
output logic [31:0] lsu_rd,
// sram1
output logic [15:0] dat_a,
output logic [3:0]  dat_we,
output logic [31:0] dat_wd,
output logic [3:0]  dat_re,
input        [31:0] dat_rd
);

endmodule





