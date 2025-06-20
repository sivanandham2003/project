module processor_tb;

  // Inputs to the processor
  reg clk;
  reg reset;

  // Wires for interconnecting modules
  wire [31:0] pc_out, pc_in, PCPlus4, PCTarget, instruction, imm_ext, readData1, readData2, alu_rslt, rd_data, final_data, mux_scr2, pc_in_for_pctarget_mux;
  wire [4:0] rs1, rs2, rd;
  wire [2:0] funct3, b_sel, ld_sel;
  wire [6:0] funct7, opcode;
  wire [3:0] alu_sel;
  wire [1:0] s_sel, imm_mux;
  wire aluscr2, mem_read, mem_write, reg_write, result_mux, pcscr, take_branch, jalr, jump_enb;

  // Instantiate the processor modules
  program_counter pc (
    .clk(clk),
    .reset(reset),
    .pc_in(pc_in),
    .pc_out(pc_out)
  );

  Adder_for_PCPlus4 adder_pc_plus4 (
    .pc_out(pc_out),
    .PCPlus4(PCPlus4)
  );

  mux_for_jump_type jump_mux (
    .pc_current(pc_out),
    .r1(readData1),
    .jalr(jalr),
    .pc_in_for_pctarget_mux(pc_in_for_pctarget_mux)
  );

  Adder_for_PCTarget adder_pctarget (
    .pc_out(pc_in_for_pctarget_mux),
    .ImmExt(imm_ext),
    .PCTarget(PCTarget)
  );

  MUX_for_PCSrc pcsrc_mux (
    .PCPlus4(PCPlus4),
    .PCTarget(PCTarget),
    .PCSrc(pcscr),
    .take_branch(take_branch),
    .jump_enb(jump_enb),
    .PCNext(pc_in)
  );

  instructionMemory imem (
    .addr(pc_out),
    .instruction(instruction)
  );

  decoder dec (
    .inst(instruction),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .funct3(funct3),
    .funct7(funct7),
    .opcode(opcode)
  );

  control_unit cu (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .aluscr2(aluscr2),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .reg_write(reg_write),
    .result_mux(result_mux),
    .pcscr(pcscr),
    .alu_sel(alu_sel),
    .b_sel(b_sel),
    .s_sel(s_sel),
    .imm_mux(imm_mux),
    .ld_sel(ld_sel),
    .jalr(jalr),
    .jump_enb(jump_enb)
    //.take_branch(take_branch)
  );

  sign_extend se (
    .inst(instruction),
    .imm_mux(imm_mux),
    .imm_ext(imm_ext)
  );

  registerFile regfile (
    .clk(clk),
    .RegWrite(reg_write),
    .jump_enb(jump_enb),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .writeData(final_data),
    .pc_out(pc_out),
    .readData1(readData1),
    .readData2(readData2)
  );

  mux_alu2_sel alu2_mux (
    .a2(readData2),
    .imm_ext(imm_ext),
    .alu_scr2(aluscr2),
    .mux_scr2(mux_scr2)
  );

  alu alu_inst (
    .a1(readData1),
    .mux_scr2(mux_scr2),
    .alu_sel(alu_sel),
    .b_sel(b_sel),
    .take_branch(take_branch),
    .alu_rslt(alu_rslt)
  );

  dataMemory dmem (
    .clk(clk),
    .MemWrite(mem_write),
    .MemRead(mem_read),
    .s_sel(s_sel),
    .ld_sel(ld_sel),
    .addr(alu_rslt),
    .writeData(readData2),
    .rd_data(rd_data)
  );

  destinatiom_reg_mux dest_mux (
    .rd_data(rd_data),
    .alu_rslt(alu_rslt),
    .rslt_mux(result_mux),
    .final_data(final_data)
  );
  endmodule