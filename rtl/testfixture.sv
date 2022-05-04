`timescale 1ns/10ps
`define MONITOR_ON
//`define MONITOR_RF_ON
`define DUMP_SRAM_ON
//`define WAVE_ON

module testfixture;

logic clk;
logic rstn;
logic [ 7:0] sram0_0 [0:(2**14)-1];
logic [ 7:0] sram0_1 [0:(2**14)-1];
logic [ 7:0] sram0_2 [0:(2**14)-1];
logic [ 7:0] sram0_3 [0:(2**14)-1];
logic [31:0] sram0   [0:(2**14)-1];
logic [13:0] sram0_a;
logic        sram0_e;
logic [31:0] sram0_o;

logic [31:0] sram1 [0:(2**14)-1];
logic [13:0] sram1_a;
logic [ 3:0] sram1_we;
logic [31:0] sram1_wd;
logic [ 3:0] sram1_re;
logic [31:0] sram1_rd;

// core
logic [15:0] ins_a;
logic        ins_e;
logic [31:0] ins;
logic [15:0] dat_a;
logic [3:0]  dat_we;
logic [31:0] dat_wd;
logic [3:0]  dat_re;
logic [31:0] dat_rd;

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
  integer i;
  // init
  $readmemh("../../test_compile/prog0/sram_0_0.hex", sram0_0);
  $readmemh("../../test_compile/prog0/sram_0_1.hex", sram0_1);
  $readmemh("../../test_compile/prog0/sram_0_2.hex", sram0_2);
  $readmemh("../../test_compile/prog0/sram_0_3.hex", sram0_3);
  for(i=0;i<2**14;i=i+1) begin
    sram0[i][ 0+:8] = sram0_0[i];
    sram0[i][ 8+:8] = sram0_1[i];
    sram0[i][16+:8] = sram0_2[i];
    sram0[i][24+:8] = sram0_3[i];
  end
  ins = 0;

  @(posedge rstn) fork
    forever@(posedge clk) begin
      sram0_a <= ins_a[13+2:2];
      sram0_e <= ins_e;
    end
    forever@(*) begin
      if(sram0_e) sram0_o = sram0[sram0_a];
      ins = sram0_o;
    end
  join
end

initial begin: sram1_model
  // init
  integer i;
  //for (i=0;i<65536;i=i+1) sram1[i] = 0;
  sram1_we = 0;

  @(posedge rstn) fork
    forever@(posedge clk) begin
      sram1_a  <= dat_a[13+2:2];
      sram1_we <= dat_we;
      sram1_wd <= dat_wd;
      sram1_re <= dat_re;
    end
    forever@(*) begin: write_sram1
      if(sram1_we[0]) sram1[sram1_a][ 0+:8] = sram1_wd[ 0+:8];
      if(sram1_we[1]) sram1[sram1_a][ 8+:8] = sram1_wd[ 8+:8];
      if(sram1_we[2]) sram1[sram1_a][16+:8] = sram1_wd[16+:8];
      if(sram1_we[3]) sram1[sram1_a][24+:8] = sram1_wd[24+:8];
    end
    forever@(*) begin: read_sram1
      if(sram1_re[0]) sram1_rd[ 0+:8] = sram1[sram1_a][ 0+:8];
      if(sram1_re[1]) sram1_rd[ 8+:8] = sram1[sram1_a][ 8+:8];
      if(sram1_re[2]) sram1_rd[16+:8] = sram1[sram1_a][16+:8];
      if(sram1_re[3]) sram1_rd[24+:8] = sram1[sram1_a][24+:8];
      dat_rd = sram1_rd;
    end
  join
  //for (i=0;i<10;i=i+1) $display("%h", sram0[i]);
end

core core0(
.clk    (clk   ),
.rstn   (rstn  ),
.ins_a  (ins_a ),
.ins_e  (ins_e ),
.ins    (ins   ),
.dat_a  (dat_a ),
.dat_we (dat_we),
.dat_wd (dat_wd),
.dat_re (dat_re),
.dat_rd (dat_rd)
);

integer glb_cnt;

initial begin: global_counter
  glb_cnt = 0;
  @(posedge rstn);
  forever@(posedge clk) glb_cnt = glb_cnt + 1;
end

integer fflag;

initial begin: finish_prog
  fflag = 0;
  @(posedge rstn);
  forever@(posedge clk) #1 if(sram1[1023]==1) begin
    fflag = 1; 
    break;
  end
  repeat(10) @(posedge clk) #1;
  $finish; 
end

integer m_vld;
`ifdef MONITOR_ON
initial begin: monitor_core
  integer i;
  i = 1;
  m_vld = 0;

  #1;
  @(posedge rstn);
  repeat(14838-8) @(posedge clk) begin
    i = i + 1;
  end
  repeat(20) @(posedge clk) begin
    #1;
    // check opcode
//    $display("cyc %d,pc %h,ins %h,ifu_vld %d,[LUI%b AUIPC%b JAL%b JALR%b B%b LD%b ST%b ALUi%b i_ALU%b F%b E%b CSR%b FnoD%b vld%b]",
//              i[15:0], core0.u_ifu0.pc, core0.ins, core0.ifu_vld,
//              core0.u_exe0.p1_iLUI,
//              core0.u_exe0.p1_iAUIPC,
//              core0.u_exe0.p1_iJAL,
//              core0.u_exe0.p1_iJALR,
//              core0.u_exe0.p1_iB,
//              core0.u_exe0.p1_iLD,
//              core0.u_exe0.p1_iST,
//              core0.u_exe0.p1_iALUi,
//              core0.u_exe0.p1_iALU,
//              core0.u_exe0.p1_iF,
//              core0.u_exe0.p1_iE,
//              core0.u_exe0.p1_iCSR,
//              core0.fwd_no_dat,
//              m_vld[4:3]);
    // branch 
//    $display("cyc %d,pc %h,ins %h,ifu_vld %d,[B%b f3b%b]",
//              i[15:0], core0.u_ifu0.pc, core0.ins, core0.ifu_vld,
//              core0.u_exe0.p1_iB, core0.u_exe0.p1_f3);
    // load word
//    $display("cyc %d,pc %h,ins %h,ifu_vld %d,[iLD %d,f3 %b]",
//              i[15:0], core0.u_ifu0.pc, core0.ins, core0.ifu_vld, core0.u_exe0.p1_iLD, core0.u_exe0.p1_f3);
    // store word
//    $display("cyc %d,pc %h,ins %h,ifu_vld %d,[iST %d,f1 %h,f2 %h],[lsu_a %h,lsu_wd %h]",
//              i, core0.u_ifu0.pc, core0.ins, core0.ifu_vld, core0.u_exe0.p1_iST,
//              core0.u_exe0.fwd_o1, core0.u_exe0.fwd_o2, 
//              core0.u_exe0.lsu_a,  core0.u_exe0.lsu_wd); 
    // check hazard
    $display("cyc %d,pc %h,ins %h,ifu[vld %d ins %h],[JAL%b JALR%b B%b LD%b ST%b hibf%b hf%b hs%b]",
              i[15:0], core0.u_ifu0.pc, core0.ins, 
              core0.ifu_vld, core0.ifu_ins,
              core0.u_exe0.p1_iJAL,
              core0.u_exe0.p1_iJALR,
              core0.u_exe0.p1_iB,
              core0.u_exe0.p1_iLD,
              core0.u_exe0.p1_iST,
              {!core0.ifu_vld, core0.branch, core0.fwd_no_dat},
              {core0.hzf_ifu, core0.hzf_ex0, core0.hzf_ex1},
              {core0.hzs_ifu, core0.hzs_ex0, core0.hzs_ex1, core0.hzs_ex2});
    i=i+1;
  end
end
`endif

`ifdef DUMP_SRAM_ON
initial begin: dump_sram
  integer cnt;
  integer fn0, fn1;
  integer flag;

  cnt = 1;
  fn0 = $fopen("dump_sram0.txt", "w");
  fn1 = $fopen("dump_sram1.txt", "w");
  flag = 0;
  #1 @(posedge rstn);
  fwrite_sram0(cnt, fn0);

  forever @(posedge clk) begin
    #1;
    if(cnt==14468-2) fwrite_sram1(cnt, fn1);
    if(fflag==1)     fwrite_sram1(cnt, fn1);
    if(fflag==1) break;
    if(sram1[0]==32'hfffff004 && flag==0) begin
      $display("sram1 adr0 cnt:%d",cnt[15:0]);
      flag = 1;
    end
    cnt = cnt + 1;
  end
  $fclose(fn0);
  $fclose(fn1);
  $display("dump_sram break");
end
`endif

task fwrite_sram0 (
input [31:0] cnt,
input [31:0] fn
); begin
  integer i, ed;
  integer state;

  //header
  $fwrite(fn, "cyc %4d-2\n", cnt+2);
  $fwrite(fn, "  address , data\n");

  ed = 2**14;
  for(i=0;i<ed;i=i+1) begin
    if(i==0) begin
      $fwrite(fn, "0x%h, ", i*4); //addr
      state = "DIFF"; 
    end else if(sram0[i]===sram0[i-1]) begin
      state = state=="DIFF" ? "SAM1" : "SAM2";
    end else if(state=="DIFF") begin
      $fwrite(fn, "0x%h\n", sram0[i-1]); //data
      $fwrite(fn, "0x%h, ", i*4);        //addr
    end else if(state=="SAM1") begin
      $fwrite(fn, "0x%h\n", sram0[i-1]); //data
      $fwrite(fn, "0x%h, 0x%h\n", i*4-4, sram0[i-1]); 
      $fwrite(fn, "0x%h, ", i*4);        //addr
      state = "DIFF"; 
    end else if(state=="SAM2") begin
      $fwrite(fn, "0x%h\n", sram0[i-1]); //data
      $fwrite(fn, " ~\n");
      $fwrite(fn, "0x%h, 0x%h\n", i*4-4, sram0[i-1]); 
      $fwrite(fn, "0x%h, ", i*4);        //addr
      state = "DIFF"; 
    end
   
    if(i!=ed-1) begin
    end else if(state=="DIFF") begin
      $fwrite(fn, "0x%h\n", sram0[i]); //data
    end else if(state=="SAM1") begin
      $fwrite(fn, "0x%h\n", sram0[i-1]); //data
      $fwrite(fn, "0x%h, 0x%h\n", i*4, sram0[i]); 
    end else if(state=="SAM2") begin
      $fwrite(fn, "0x%h\n", sram0[i-1]); //data
      $fwrite(fn, " ~\n");
      $fwrite(fn, "0x%h, 0x%h\n", i*4, sram0[i]); 
    end
  end
end endtask

task fwrite_sram1 (
input [31:0] cnt,
input [31:0] fn
); begin
  integer i, ed;
  integer state;

  //header
  $fwrite(fn, "cyc %4d-2\n", cnt+2);
  $fwrite(fn, "  address , data\n");

  ed = 2**14;
  for(i=0;i<ed;i=i+1) begin
    if(i==0) begin
      $fwrite(fn, "0x%h, ", i*4); //addr
      state = "DIFF"; 
    end else if(sram1[i]===sram1[i-1]) begin
      state = state=="DIFF" ? "SAM1" : "SAM2";
    end else if(state=="DIFF") begin
      $fwrite(fn, "0x%h\n", sram1[i-1]); //data
      $fwrite(fn, "0x%h, ", i*4);        //addr
    end else if(state=="SAM1") begin
      $fwrite(fn, "0x%h\n", sram1[i-1]); //data
      $fwrite(fn, "0x%h, 0x%h\n", i*4-4, sram1[i-1]); 
      $fwrite(fn, "0x%h, ", i*4);        //addr
      state = "DIFF"; 
    end else if(state=="SAM2") begin
      $fwrite(fn, "0x%h\n", sram1[i-1]); //data
      $fwrite(fn, " ~\n");
      $fwrite(fn, "0x%h, 0x%h\n", i*4-4, sram1[i-1]); 
      $fwrite(fn, "0x%h, ", i*4);        //addr
      state = "DIFF"; 
    end
   
    if(i!=ed-1) begin
    end else if(state=="DIFF") begin
      $fwrite(fn, "0x%h\n", sram1[i]); //data
    end else if(state=="SAM1") begin
      $fwrite(fn, "0x%h\n", sram1[i-1]); //data
      $fwrite(fn, "0x%h, 0x%h\n", i*4, sram1[i]); 
    end else if(state=="SAM2") begin
      $fwrite(fn, "0x%h\n", sram1[i-1]); //data
      $fwrite(fn, " ~\n");
      $fwrite(fn, "0x%h, 0x%h\n", i*4, sram1[i]); 
    end
  end
end endtask

initial begin: monitor_instruction
  integer cnt;
  integer fn;
  integer vld3, vld4, vld5, vld6, vld7;
  integer pc3,  pc4,  pc5,  pc6,  pc7;
  integer ins3, ins4, ins5, ins6, ins7;
  integer             adr5, adr6, adr7;
  integer             wd5,  wd6,  wd7;
  integer                   rd6,  rd7;

  cnt = 1;
  fn = $fopen("do_ins.txt","w");
  vld3=0;vld4=0;vld5=0;vld6=0;vld7=0;
  

  #1;
  @(posedge rstn) fork
    forever @(posedge clk) begin: pipe1_pc_out
    end
    forever @(posedge clk) begin: pipe2_ins_mem_out
    end
    forever @(posedge clk) begin: pipe3_ins_reg_out
      vld3     <= !core0.hzf_ex0;
      m_vld[3] <= !core0.hzf_ex0;
      pc3  <= core0.ifu_pc;
      ins3 <= core0.ifu_ins;
    end
    forever @(posedge clk) begin: pipe4_exe
      vld4     <= core0.branch | (!core0.hzf_ex1 & vld3);
      m_vld[4] <= core0.branch | (!core0.hzf_ex1 & vld3);
      pc4  <= pc3;
      ins4 <= ins3;
    end
    forever @(posedge clk) begin: pipe5_csr
      vld5 <= vld4;
      pc5  <= pc4;
      ins5 <= ins4;
      adr5 <= core0.lsu_a;
      wd5  <= core0.lsu_wd;
    end
    forever @(posedge clk) begin: pipe6_lsu
      vld6 <= vld5;
      pc6  <= pc5;
      ins6 <= ins5;
      adr6 <= adr5;
      wd6  <= wd5;
      rd6  <= core0.lsu_rd;
    end
    forever @(posedge clk) begin: pipe7_commit
      vld7 <= vld6;
      pc7  <= pc6;
      ins7 <= ins6;
      adr7 <= adr6;
      wd7  <= wd6;
      rd7  <= rd6;
    end
    forever @(posedge clk) begin: output_instructin 
      #1;
      if(cnt== 91)   $fwrite(fn, "skip1--------\n");
      if(cnt== 7278) $fwrite(fn, "skip2--------\n");

      if     (cnt>=91   & cnt<(91+  7*1022));
      else if(cnt>=7278 & cnt<(7278+7*1022));
      else if(vld7) begin 
        $fwrite(fn, "%d ", cnt[15:0]);
        $fwrite(fn, "%h ", pc7);
        fwrite_instruction(fn, pc7, ins7, adr7, wd7, rd7);
        $fwrite(fn, "\n");
      end 
      cnt = cnt + 1;
    end
  join
end

task fwrite_instruction(
input [31:0] fn,
input [31:0] pc,
input [31:0] ins,
input [31:0] adr,
input [31:0] wd,
input [31:0] rd
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

  if(opcode==7'b0110111) begin
    $fwrite(fn, "LUI,   ");
    fw_reg_name(fn, rd_a);
    $fwrite(fn, "    ");
    $fwrite(fn, "0x%h, ", uimm);
    $fwrite(fn, "rd:0x%h", core0.u_rf0.rf_arr[rd_a]);
  end
  if(opcode==7'b0010111) begin
    $fwrite(fn, "AUIPC, ");
    fw_reg_name(fn, rd_a);
    $fwrite(fn, "pc, ");
    $fwrite(fn, "0x%h, ", uimm);
    $fwrite(fn, "rd:0x%h", core0.u_rf0.rf_arr[rd_a]);
  end
  if(opcode==7'b1101111) begin
    $fwrite(fn, "JAL,   ");
    fw_reg_name(fn, rd_a);
    $fwrite(fn,"    ");
    $fwrite(fn, "0x%h, ", pc+jimm);
    $fwrite(fn, "rd:0x%h", core0.u_rf0.rf_arr[rd_a]);
  end
  if(opcode==7'b1100111 & funct3==3'b000) begin
    $fwrite(fn, "JALR,  ");
    fw_reg_name(fn, rd_a);
    fw_reg_name(fn, rs1_a);
    $fwrite(fn, "0x%h, ", iimm);
    $fwrite(fn, "rd:0x%h", core0.u_rf0.rf_arr[rd_a]);
  end
  if(opcode==7'b1100011) begin
    if(funct3==3'b000) $fwrite(fn, "BEQ,   ");
    if(funct3==3'b001) $fwrite(fn, "BNE,   ");
    if(funct3==3'b100) $fwrite(fn, "BLT,   ");
    if(funct3==3'b101) $fwrite(fn, "BGE,   ");
    if(funct3==3'b110) $fwrite(fn, "BLTU,  ");
    if(funct3==3'b111) $fwrite(fn, "BGEU,  ");
    fw_reg_name(fn, rs1_a);
    fw_reg_name(fn, rs2_a_shamt);
    $fwrite(fn, "0x%h, ", pc+bimm);
  end
  if(opcode==7'b0000011) begin
    if(funct3==3'b010) $fwrite(fn, "LW,    ");
    fw_reg_name(fn, rd_a);
    fw_reg_name(fn, rs1_a);
    $fwrite(fn, "0x%h, ", iimm);
    $fwrite(fn, "sram1\[0x%h\]=>0x%h", adr, rd);
  end
  if(opcode==7'b0100011) begin
    if(funct3==3'b010) $fwrite(fn, "SW,    ");
    fw_reg_name(fn, rs2_a_shamt);
    fw_reg_name(fn, rs1_a);
    $fwrite(fn, "0x%h, ", simm);
    $fwrite(fn, "sram1\[0x%h\]<=0x%h", adr, wd);
  end
  if(opcode==7'b0010011) begin
    if(funct3==3'b000) $fwrite(fn, "ADDI,  ");
    if(funct3==3'b010) $fwrite(fn, "SLTI,  ");
    if(funct3==3'b011) $fwrite(fn, "SLTIU, ");
    if(funct3==3'b100) $fwrite(fn, "XORI,  ");
    if(funct3==3'b110) $fwrite(fn, "ORI,   ");
    if(funct3==3'b111) $fwrite(fn, "ANDI,  ");
    if(funct3==3'b001 & !funct7[5]) $fwrite(fn, "SLLI,  ");
    if(funct3==3'b101 & !funct7[5]) $fwrite(fn, "SRLI,  ");
    if(funct3==3'b101 &  funct7[5]) $fwrite(fn, "SRAI,  ");
    fw_reg_name(fn, rd_a);
    fw_reg_name(fn, rs1_a);
    $fwrite(fn, "0x%h, ", iimm);
    $fwrite(fn, "rd:0x%h", core0.u_rf0.rf_arr[rd_a]);
  end
  if(opcode==7'b0110011) begin
    if(funct3==3'b000 & !funct7[5]) $fwrite(fn, "ADD,   ");
    if(funct3==3'b000 &  funct7[5]) $fwrite(fn, "SUB,   ");
    if(funct3==3'b001)              $fwrite(fn, "SLL,   ");
    if(funct3==3'b010)              $fwrite(fn, "SLT,   ");
    if(funct3==3'b011)              $fwrite(fn, "SLTU,  ");
    if(funct3==3'b100)              $fwrite(fn, "XOR,   ");
    if(funct3==3'b101 & !funct7[5]) $fwrite(fn, "SRL,   ");
    if(funct3==3'b101 &  funct7[5]) $fwrite(fn, "SRA,   ");
    if(funct3==3'b110)              $fwrite(fn, "OR,    ");
    if(funct3==3'b111)              $fwrite(fn, "AND,   ");
    fw_reg_name(fn, rd_a);
    fw_reg_name(fn, rs1_a);
    fw_reg_name(fn, rs2_a_shamt);
    $fwrite(fn, "        ");
    $fwrite(fn, "rd:0x%h", core0.u_rf0.rf_arr[rd_a]);
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

`ifdef MONITOR_RF_ON
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
`endif

initial begin: WDT
  #(30000 * 10);
  $display("The dog is coming, shutdown");
  $finish;
end

`ifdef WAVE_ON
initial begin: dump_fsdb
  $fsdbDumpfile("wave.fsdb");
  $fsdbDumpvars;
  $fsdbDumpMDA;
end 
`endif



endmodule





