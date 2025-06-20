`timescale 1ns/1ps
module MUX_for_PCSrc(
    input [31:0] PCPlus4, PCTarget,
    input PCSrc,take_branch,jump_enb,
    output [31:0] PCNext
);  
    
  assign PCNext =((PCSrc && take_branch)| jump_enb) ? PCTarget : PCPlus4;
endmodule


//PC Logic
module program_counter(
input clk, reset, 
input [31:0] pc_in,
output reg [31:0] pc_out
    );
    always@(posedge clk)
    if (reset)
        pc_out<=32'd0;
    else
        pc_out<=pc_in;    
endmodule


//Logic of Adder for PCPlus4
module Adder_for_PCPlus4(
    input [31:0] pc_out,
    output [31:0] PCPlus4
);
assign PCPlus4 = pc_out + 4;
endmodule


//Logic of Adder for PCTarget
module Adder_for_PCTarget(
    input [31:0] pc_out,
    input [31:0] ImmExt,
  output [31:0] PCTarget
);
assign PCTarget =  pc_out + ImmExt;
endmodule

module mux_for_jump_type(
  input [31:0] pc_current,r1,
  input jalr,
  output [31:0] pc_in_for_pctarget_mux
);

  assign pc_in_for_pctarget_mux=jalr?r1:pc_current;
endmodule



`timescale 1ns/1ps
`timescale 1ns/1ps
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




module decoder(
    input [31:0] inst,
    output [4:0] rs1,rs2,rd,
    output [2:0] funct3,
    output [6:0] funct7,
    output [6:0] opcode
);

assign opcode = inst[6:0];
assign rd     = inst[11:7];
assign rs1    = inst[19:15];
assign rs2    = inst[24:20];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];

endmodule


module control_unit(
  input      [6:0] opcode,
  input      [2:0] funct3,
  input      [6:0] funct7,
  output reg       aluscr2,
  output reg       mem_read,mem_write,reg_write,result_mux,pcscr,
  output reg [3:0] alu_sel,
  output reg [2:0] b_sel,
  output reg [1:0] s_sel,imm_mux,
  output reg [2:0] ld_sel,
  output reg      jalr,jump_enb
  
);

    localparam load   = 7'b0000011; // load
    localparam r_type = 7'b0110011; // add, sub, or, and
    localparam i_type = 7'b0010011; // addi, ori, andi
    localparam b_type = 7'b1100011; // branch instruction
    localparam s_type = 7'b0100011; // store instruction
    localparam jal_type = 7'b1101111; // jump instruction
    localparam jalr_type= 7'b1100111; // jump instruction
    localparam u_type = 7'b0110111; // lui


always@(*) begin

//take_branch=1'b0;  

  case(opcode)

        r_type : begin 
          aluscr2=1'b0;
          reg_write=1'b1;
          mem_read=1'b0;
          mem_write=1'b0;
          result_mux=1'b0;
          pcscr=1'b0;
          imm_mux=2'b00;
          //take_branch=1'b0;
          jalr=1'b0;
          jump_enb=1'b0;
          case ({funct3, funct7})
                    10'b000_0000000: alu_sel = 4'b0000; // add
                    10'b000_0100000: alu_sel = 4'b0001; // sub
                    10'b001_0000000: alu_sel = 4'b0010; // sll
                    10'b010_0000000: alu_sel = 4'b0011; // slt
                    10'b011_0000000: alu_sel = 4'b0100; // sltu
                    10'b100_0000000: alu_sel = 4'b0101; // xor
                    10'b101_0000000: alu_sel = 4'b0110; // srl
                    10'b101_0100000: alu_sel = 4'b0111; // sra
                    10'b110_0000000: alu_sel = 4'b1000; // or
                    10'b111_0000000: alu_sel = 4'b1001; // and
                    default: alu_sel = 4'b0000;
                endcase
            end

        i_type : begin
          aluscr2=1'b1;
          reg_write=1'b1;
          mem_read=1'b0;
          mem_write=1'b0;
          result_mux=1'b0;
          pcscr=1'b0;
          imm_mux=2'b00;
         // take_branch=1'b0;
          jalr=1'b0;
          jump_enb=1'b0;
          case (funct3)
                    3'b000: alu_sel = 4'b0000; // addi
                    3'b100: alu_sel = 4'b0101; // xori
                    3'b110: alu_sel = 4'b1000; // ori
                    3'b111: alu_sel = 4'b1001; // andi
                    3'b010: alu_sel = 4'b0011; // slti
                    3'b011: alu_sel = 4'b0100; // sltiu
                    3'b001: alu_sel = 4'b0010; // slli
                    3'b101: alu_sel = 4'b0110; // srli/srai
                    default: alu_sel = 4'b0000;
                endcase
        end
        
        load : begin
          alu_sel=4'b0000;
          aluscr2=1'b1;
          reg_write=1'b1;
          mem_read=1'b1;
          mem_write=1'b0;
          result_mux=1'b1;
          pcscr=1'b0;
          imm_mux=2'b00;
          //take_branch=1'b0;
          jalr=1'b0;
          jump_enb=1'b0;


          case (funct3)
                    3'b000: ld_sel = 3'b000; // lb
                    3'b001: ld_sel = 3'b001; // lh
                    3'b010: ld_sel = 3'b010; // lw
                    3'b100: ld_sel = 3'b011; // lbu
                    3'b101: ld_sel = 3'b100; // lhu
                    default: ld_sel = 3'b111;
                endcase
        end

        s_type : begin
          aluscr2=1'b1;
          reg_write=1'b0;
          mem_read=1'b0;
          mem_write=1'b1;
          result_mux=1'b0;
          pcscr=1'b0;
          imm_mux=2'b01;
          //take_branch=1'b0;
          jalr=1'b0;
           jump_enb=1'b0;
          case (funct3)
                    3'b000: s_sel = 2'b00; // sb
                    3'b001: s_sel = 2'b01; // sh
                    3'b010: s_sel = 2'b10; // sw
                    default: s_sel = 2'b11; // Invalid
                endcase
        end 

        b_type : begin
          aluscr2=1'b0;
          reg_write=1'b0;
          mem_read=1'b0;
          mem_write=1'b0;
          result_mux=1'b0;
          pcscr=1'b1;
          imm_mux=2'b10;
          //take_branch=1'b1;
          jalr=1'b0;
          jump_enb=1'b0;
          case (funct3)
                    3'b000: b_sel = 3'b000; // beq
                    3'b001: b_sel = 3'b001; // bne
                    3'b100: b_sel = 3'b010; // blt
                    3'b101: b_sel = 3'b011; // bge
                    3'b110: b_sel = 3'b100; // bltu
                    3'b111: b_sel = 3'b101; // bgeu
                    default: b_sel = 3'b000;
                endcase
        end

        jal_type: begin
          aluscr2=1'b0;
          reg_write=1'b1;
          mem_read=1'b0;
          mem_write=1'b0;
          result_mux=1'b0;
          pcscr=1'b1;
          imm_mux=2'b11;
          jalr=1'b0;
          //take_branch=1'b0;
          jump_enb=1'b1;
        end 

        jalr_type : begin
          aluscr2=1'b0;
          reg_write=1'b1;
          mem_read=1'b0;
          mem_write=1'b0;
          result_mux=1'b0;
          pcscr=1'b1;
          imm_mux=2'b00;
          jalr=1'b1;
          //take_branch=1'b0;
           jump_enb=1'b1;
        end
        
  endcase
end
endmodule



module sign_extend (
    input [31:0] inst,
    input [1:0] imm_mux,
    output reg [31:0] imm_ext
);

    always @(*) begin
        case (imm_mux)
            2'b00: imm_ext = {{20{inst[31]}}, inst[31:20]}; // I-type
            2'b01: imm_ext = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // S-type
            2'b10: imm_ext = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; // B-type
            2'b11: imm_ext = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // J-type
            default: imm_ext = 32'b0;
        endcase
    end
endmodule


module mux_alu2_sel (
    input wire [31:0] a2,
    input wire [31:0] imm_ext,
    input wire alu_scr2,
    output wire [31:0] mux_scr2
);

assign mux_scr2 = alu_scr2 ? imm_ext : a2;

endmodule

`timescale 1ns/1ps
module registerFile(
  input clk,
  input RegWrite,jump_enb,
  input [4:0] rs1, rs2, rd,
  input [31:0] writeData,pc_out,
  output [31:0] readData1, readData2
);

  reg [31:0] registers[0:31];
  integer i;
  assign readData1 = (rs1 != 5'd0) ? registers[rs1] : 32'b0;
  assign readData2 = (rs2 != 5'd0) ? registers[rs2] : 32'b0;
  always @(posedge clk) begin
    if (RegWrite && rd != 5'd0) begin
      registers[rd] <= (jump_enb) ?( pc_out+4) : writeData;
      //$display("RegWrite: x%0d <= %0d at time %0t", rd, writeData, $time);
    end
  end
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      registers[i] = 32'b0;
    end
  end
  initial begin
    registers[2]=32'd3;
    registers[4]=32'd1;
    registers[10]=32'd1027;
  end
endmodule


module alu (
    input wire [31:0] a1,
    input wire [31:0] mux_scr2,
    input wire [3:0] alu_sel,
    input wire [2:0] b_sel,
    output reg take_branch,
    output reg [31:0] alu_rslt
);
    

    always @(*) begin
        // ALU operations
        case (alu_sel)
            4'b0000: alu_rslt = a1 + mux_scr2; // ADD / ADDI
            4'b0001: alu_rslt = a1 - mux_scr2; // SUB
            4'b0010: alu_rslt = a1 << (mux_scr2[4:0]); // SLL / SLLI
            4'b0011: alu_rslt = ($signed(a1) < $signed(mux_scr2)) ? 32'd1 : 32'd0; // SLT / SLTI
            4'b0100: alu_rslt = (a1 < mux_scr2) ? 32'd1 : 32'd0; // SLTU / SLTIU
            4'b0101: alu_rslt = a1 ^ mux_scr2; // XOR / XORI
            4'b0110: alu_rslt = a1 >> (mux_scr2[4:0]); // SRL / SRLIhow store instruction executed
            4'b0111: alu_rslt = $signed(a1) >>> (mux_scr2[4:0]); // SRA / SRAI
            4'b1000: alu_rslt = a1 | mux_scr2; // OR / ORI
            4'b1001: alu_rslt = a1 & mux_scr2; // AND / ANDI
            default: alu_rslt = a1+mux_scr2;
        endcase

    end
   
    always @(*) begin
      
        case (b_sel)
            3'b000: take_branch = (a1 == mux_scr2); // BEQ
            3'b001: take_branch = (a1 != mux_scr2);              // BNE
            3'b010: take_branch = ($signed(a1) < $signed(mux_scr2));  // BLT
            3'b011: take_branch = ($signed(a1) >= $signed(mux_scr2)); // BGE
            3'b100: take_branch = (a1 < mux_scr2);               // BLTU
            3'b101: take_branch = (a1 >= mux_scr2);              // BGEU
            default: take_branch = 1'b0;
        endcase
    end
endmodule

`timescale 1ns/1ps
module dataMemory(
  input clk,
  input MemWrite, MemRead,
  input [1:0] s_sel,
  input [2:0] ld_sel,
  input [31:0] addr, writeData,
  output reg [31:0] rd_data
);

  reg [31:0] memory [0:255]; 
  wire [7:0] mem_index = addr[9:2]; 
  wire [31:0] readData;
  integer i;
  always @(posedge clk) begin
    if (MemWrite) begin
      if (mem_index < 256) begin
        case(s_sel) 
            2'b00: memory[mem_index] <= writeData[7:0];
            2'b01: memory[mem_index] <= writeData[15:0];
            2'b10: memory[mem_index] <= writeData;
            default:begin
            end
        
        endcase

      end else begin
        $display("Write out-of-bounds: addr=0x%0h", addr);
      end
    end
  end
  assign readData = (MemRead && mem_index < 256) ? memory[mem_index] : 32'd0;

  always@(*) begin

  case (ld_sel)
            3'b000: rd_data = {{24{readData[7]}}, readData[7:0]}; // lb
            3'b001: rd_data = {{16{readData[15]}}, readData[15:0]}; // lh
            3'b010: rd_data = readData; // lw
            3'b011: rd_data = {24'b0, readData[7:0]}; // lbu
            3'b100: rd_data = {16'b0, readData[15:0]}; // lhu
            default: rd_data = 32'b0;
        endcase
  end
  
  initial begin
    for (i = 0; i < 256; i = i + 1) begin
      memory[i] = 32'd0;
    end

  end

  initial begin
    memory[0]=1;
    memory[1]=6;
   //memory[2]=4; 
    memory[3]=8;
    memory[4]=513;
  end
  always @(*) begin
    if (MemRead && mem_index < 256)
      $display("MemRead: Mem[0x%0h] => %0d", addr, memory[mem_index]);
  end
endmodule






module destinatiom_reg_mux(
    input wire [31:0] rd_data,
    input wire [31:0] alu_rslt,
    input  wire       rslt_mux,
    output wire [31:0] final_data
);

assign final_data = (rslt_mux == 1)? rd_data : alu_rslt;

endmodule
