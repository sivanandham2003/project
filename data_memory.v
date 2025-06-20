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



