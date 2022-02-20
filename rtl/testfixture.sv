`timescale 1ns/10ps

module testfixture;

logic clk;
logic rstn;
logic [7:0]  sram0_0 [0:(2**14)-1];
logic [7:0]  sram0_1 [0:(2**14)-1];
logic [7:0]  sram0_2 [0:(2**14)-1];
logic [7:0]  sram0_3 [0:(2**14)-1];
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

initial begin: monitor_instruction
  integer fn;
  integer pc1,  pc2,  pc3,  pc4,  pc5,  pc6;
  integer vld1, vld2, vld3, vld4, vld5, vld6;
  integer       ins2, ins3, ins4, ins5, ins6;

  fn = $fopen("do_ins.txt","w");
  vld1=0;vld2=0;vld3=0;vld4=0;vld5=0;vld6=0;
  

  #1;
  @(posedge rstn) fork
    forever @(posedge clk) begin: pipe1_pc
      pc1  <= core0.pc;
      vld1 <= 1;
    end
    forever @(posedge clk) begin: pipe2_ins
      vld2 <= vld1;
      pc2  <= pc1;
      ins2 <= core0.ins_reg;
    end
    forever @(posedge clk) begin: pipe3_exe
      pc3  <= pc2;
      vld3 <= vld2;
      ins3 <= ins2;
    end
    forever @(posedge clk) begin: pipe4_csr
      pc4  <= pc3;
      vld4 <= vld3;
      ins4 <= ins3;
    end
    forever @(posedge clk) begin: pipe5_lsu
      pc5  <= pc4;
      vld5 <= vld4;
      ins5 <= ins4;
    end
    forever @(posedge clk) begin: pipe6_commit
      pc6  <= pc5;
      vld6 <= vld5;
      ins6 <= ins5;
    end
    forever @(posedge clk) begin: output_instructin 
      if(vld6) begin 
        $fwrite(fn, "%h ", pc6);
        fwrite_instruction(fn, ins6);
        $fwrite(fn, "\n");
      end
    end
  join
end

task fwrite_instruction(
input [31:0] fn,
input [31:0] ins
); begin
  logic [4:0]  rs1_a;
  logic [4:0]  rs2_a_shamt;
  logic [4:0]  rd_a;
  logic [2:0]  funct3;
  logic [6:0]  funct7;
  logic [6:0]  opcode;
  logic [31:0] iimm;
  logic [31:0] simm;
  logic [31:0] bimm;
  logic [31:0] uimm;
  logic [31:0] jimm;

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

  if(opcode==7'b0010011) begin
    if(funct3==3'b000) $fwrite(fn, "addi, ");
    fw_reg_name(fn, rd_a);
    fw_reg_name(fn, rs1_a);
    $fwrite(fn, "0x%0h", iimm);
  end
end endtask

task fw_reg_name(
input [31:0] fn,
input [4:0]  reg_adr
); begin
  case(reg_adr)
   0:$fwrite(fn, "z0, ");
   1:$fwrite(fn, "ra, "); 
   2:$fwrite(fn, "sp, ");
   3:$fwrite(fn, "gp, ");
   4:$fwrite(fn, "tp, ");
   5:$fwrite(fn, "t0, ");
   6:$fwrite(fn, "t1, ");
   7:$fwrite(fn, "t2, ");
   8:$fwrite(fn, "s0, ");
   9:$fwrite(fn, "s1, ");
  10:$fwrite(fn, "a0, ");
  11:$fwrite(fn, "a1, ");
  12:$fwrite(fn, "a2, ");
  13:$fwrite(fn, "a3, ");
  14:$fwrite(fn, "a4, ");
  15:$fwrite(fn, "a5, ");
  16:$fwrite(fn, "a6, ");
  17:$fwrite(fn, "a7, ");
  18:$fwrite(fn, "s2, ");
  19:$fwrite(fn, "s3, ");
  20:$fwrite(fn, "s4, ");
  21:$fwrite(fn, "s5, ");
  22:$fwrite(fn, "s6, ");
  23:$fwrite(fn, "s7, ");
  24:$fwrite(fn, "s8, ");
  25:$fwrite(fn, "s9, ");
  26:$fwrite(fn, "s10,");
  27:$fwrite(fn, "s11,");
  28:$fwrite(fn, "t3, ");
  29:$fwrite(fn, "t4, ");
  30:$fwrite(fn, "t5, ");
  31:$fwrite(fn, "t6, "); 
  endcase
end endtask

initial begin: monitor_regfile
  integer i, j, fn;
  integer rf_rd_e, rf_rd_a; 
  i = 0;
  rf_rd_e = 0;
  fn = $fopen("regfile.txt","w");

  #1;
  @(posedge rstn);
  forever begin
    $fwrite(fn, "cycle %d,",i[15:0]);
    if(rf_rd_e) 
      $fwrite(fn, "a:%h, d:%h", rf_rd_a, core0.u_rf0.rf_arr[rf_rd_a]);  
    $fwrite(fn,"\n");

    rf_rd_e = core0.u_rf0.rd_e;
    rf_rd_a = core0.u_rf0.rd_a;
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
  #(100 * 10);
  $display("The dog is coming, shutdown");
  $finish;
end


endmodule





