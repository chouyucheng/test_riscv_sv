`timescale 1ns/10ps

module testfixture;

logic clk;
logic rstn;
logic [7:0] sram0_0 [0:(2**14)-1];
logic [7:0] sram0_1 [0:(2**14)-1];
logic [7:0] sram0_2 [0:(2**14)-1];
logic [7:0] sram0_3 [0:(2**14)-1];
logic        sram0_e;
logic [13:0] sram0_a;
logic [31:0] sram0_o;

logic [31:0] sram1 [0:(2**14)-1];

// core
logic [15:0] ins_a;
logic        ins_e;
logic [31:0] ins;

initial begin: clock
  clk = 0;
  forever #5 clk = ~clk;
end

initial begin: reset
  rstn = 1;
  @(posedge clk) #1 rstn = 0;
  @(posedge clk) #1 rstn = 1;
end

initial begin: sram0_model
  // init
  $readmemh("../../test_compile/prog0/sram_0_0.hex", sram0_0);
  $readmemh("../../test_compile/prog0/sram_0_1.hex", sram0_1);
  $readmemh("../../test_compile/prog0/sram_0_2.hex", sram0_2);
  $readmemh("../../test_compile/prog0/sram_0_3.hex", sram0_3);
  forever@(posedge clk) begin
    sram0_a = ins_a[15:2];
    sram0_e = ins_e;
    if(sram0_e) sram0_o[ 0+:8] = sram0_0[sram0_a];
    if(sram0_e) sram0_o[ 8+:8] = sram0_1[sram0_a];
    if(sram0_e) sram0_o[16+:8] = sram0_2[sram0_a];
    if(sram0_e) sram0_o[24+:8] = sram0_3[sram0_a];
    ins = sram0_o;
  end
end

initial begin: sram1_model
  // init
  integer i;
  for (i=0;i<65536;i=i+1) sram1[i] = 0;
  //for (i=0;i<10;i=i+1) $display("%h", sram0[i]);
end

core core0(
.clk    (clk),
.rstn   (rstn),
.ins_a  (ins_a ),
.ins_e  (ins_e ),
.ins    (ins   ),
.dat_a  (/*dat_a */),
.dat_we (/*dat_we*/),
.dat_wd (/*dat_wd*/),
.dat_re (/*dat_re*/),
.dat_rd (/*dat_rd*/)
);

initial begin: monitor_ins
  integer i;
  i = 0;

  #1;
  @(posedge rstn);
  repeat(10) begin
      $display("cycle %d, pc: %h, ins: %h, ALUi: %b", 
                i, core0.pc, core0.ins_reg, core0.i_ALUi);
      i=i+1;
      @(posedge clk) #1;
  end
end

initial begin: dump_fsdb
  $fsdbDumpfile("wave.fsdb");
  $fsdbDumpvars;
  $fsdbDumpMDA;
end 

initial begin: WDT
  #(1000 * 10);
  $display("The dog is coming, shutdown");
  $finish;
end


endmodule





