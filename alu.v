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