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
