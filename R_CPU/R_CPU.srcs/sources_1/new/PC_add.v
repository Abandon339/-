`timescale 1ns / 1ps
module PC_add(
    input rst,
    input clk,
    output reg[7:0] PC
    );
wire [7:0] PC_new;
assign PC_new = PC + 4;
always@(posedge clk, posedge rst)
begin
    if(rst)
        PC = 32'h0000_0000; //PC���㣬��ָ��MIPS CPU��0�����濪ʼִ�г���
    else                    //clk�½��أ�����PC
        PC = PC_new;
end
endmodule
