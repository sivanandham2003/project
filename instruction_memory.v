module instructionMemory(
  input [31:0] addr,
  output [31:0] instruction
);

  reg [31:0] memory [0:255];
  integer i;

  assign instruction = memory[addr[9:2]];

  initial begin
    // Clear memory
    for (i = 0; i < 256; i = i + 1)
      memory[i] = 32'b0;

    // ----------------------------------------------------------
    // TEST PROGRAM:
    // addi x1, x0, 2      ; x1 = 2
    // addi x2, x0, 5      ; x2 = 5
    // add  x3, x1, x2     ; x3 = x1 + x2 = 7
    // sw   x3, 0(x0)      ; store x3 at Mem[0]
    // lw   x4, 0(x0)      ; x4 = Mem[0] = 7
    // beq  x3, x4, +8     ; if x3 == x4, skip next instruction
    // addi x5, x0, 1      ; x5 = 1 (should be skipped if branch is taken)
    // addi x6, x0, 9      ; x6 = 9 (should always execute)
    // ----------------------------------------------------------

  memory[0]=32'h00122083; //load x1,X4(imm=1)
  memory[1]=32'h00422403; //load x8,x4(imm=1)
  memory[2]=32'h0080c3b3; //  add x7, x1, x8
  memory[3]=32'h0070c463;//beq x1 x7 memory[5](20-pc value)
  memory[4]=32'h00422483; //load x9 x4(imm=4) 
  memory[5]=32'h0074a3a3; //store sw x9(imm=3)  x7;
  memory[6]=32'h00408613; // add x12 x1 x8
  memory[7]=32'h01008767; //jalr x14 x1(imm=16) 
 // memory[6]=32'h008005ef; //jar
  //memory[5]=32'h00a401a3; //store sw x8(imm=3)  x10;
  //memory[6]=32'h01020603;//load byte lb x12 x4(imm=16) 


  end

endmodule