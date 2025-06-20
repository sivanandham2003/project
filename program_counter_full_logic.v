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

