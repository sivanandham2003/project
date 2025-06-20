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