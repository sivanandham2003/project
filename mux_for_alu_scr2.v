module mux_alu2_sel (
    input wire [31:0] a2,
    input wire [31:0] imm_ext,
    input wire alu_scr2,
    output wire [31:0] mux_scr2
);

assign mux_scr2 = alu_scr2 ? imm_ext : a2;

endmodule