module destinatiom_reg_mux(
    input wire [31:0] rd_data,
    input wire [31:0] alu_rslt,
    input  wire       rslt_mux,
    output wire [31:0] final_data
);

assign final_data = (rslt_mux == 1)? rd_data : alu_rslt;

endmodule
