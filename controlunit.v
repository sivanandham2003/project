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