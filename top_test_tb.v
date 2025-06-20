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

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period (100MHz clock)
  end

  // Reset and simulation control
  initial begin
    // Initialize inputs
    reset = 1;
    #15; // Hold reset for 15ns
    reset = 0;

    // Run simulation for enough cycles to execute all instructions
    #500; // 50 cycles at 10ns = 500ns
    $finish;
  end

  // Monitor key signals
  initial begin
    $monitor("Time=%0t | PC=%h | Instruction=%h | rs1=%d | rs2=%d | rd=%d | readData1=%h | readData2=%h | alu_rslt=%h | final_data=%h | mem_read=%b | mem_write=%b | reg_write=%b | take_branch=%b | jump_enb=%b",
             $time, pc_out, instruction, rs1, rs2, rd, readData1, readData2, alu_rslt, final_data, mem_read, mem_write, reg_write, take_branch, jump_enb);
  end

  // Dump variables for waveform analysis
  initial begin
    $dumpfile("processor_tb.vcd");
    $dumpvars(0, processor_tb);
    
  end
  
    // After simulation ends, display register and memory contents
  integer j;
  initial begin
    // Wait for simulation to end
    #510;  // Wait slightly more than simulation time to ensure writes complete

    $display("\n===============================");
    $display("Final Register File Contents:");
    $display("===============================");
    for (j = 0; j < 32; j = j + 1) begin
      $display("x%0d = %0d (0x%h)", j, processor_tb.regfile.registers[j], processor_tb.regfile.registers[j]);
    end

    $display("\n===============================");
    $display("Final Data Memory Contents (non-zero only):");
    $display("===============================");
    for (j = 0; j < 256; j = j + 1) begin
      if (processor_tb.dmem.memory[j] !== 32'b0) begin
        $display("Mem[0x%0h] = %0d (0x%h)", j << 2, processor_tb.dmem.memory[j], processor_tb.dmem.memory[j]);
      end
    end
  end


endmodule