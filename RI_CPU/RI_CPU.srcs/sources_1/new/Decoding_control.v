`timescale 1ns / 1ps

module Decoding_control(
    input clk,
    input rst,
    input [5:0] OP,
    input [5:0] func,
    output reg rt_rd_s,
    output reg imm_s,
    output reg rt_imm_s,
    output reg alu_mem_s,
    output reg Mem_Write,
    output reg Write_Reg,
    output reg[3:0] ALU_OP
    );

always@(*)
begin
    ALU_OP = 3'b000;    Write_Reg = 1'b0;   rt_rd_s = 1'b0;
    rt_imm_s = 1'b0;      imm_s = 1'b0;     alu_mem_s = 1'b0;
    Mem_Write = 1'b0;
    //===============R��ָ��
    if(OP == 6'b000000)
    begin
        Write_Reg = 1'b1;
        case(func)
            6'b100000: ALU_OP = 3'b100; //add
            6'b100010: ALU_OP = 3'b101; //sub
            6'b100100: ALU_OP = 3'b000; //and
            6'b100101: ALU_OP = 3'b001; //or
            6'b100110: ALU_OP = 3'b010; //xor
            6'b100111: ALU_OP = 3'b011; //nor
            6'b101011: ALU_OP = 3'b110; //sltu
            6'b000100: ALU_OP = 3'b111; //sllv
        endcase
    end
    //===============I��ָ��
    else if(OP[5:3] == 3'b001)
    begin        
        Write_Reg = 1'b1;    rt_rd_s = 1'b1;    rt_imm_s = 1'b1;   
        case(OP[2:0])
            3'b000: begin ALU_OP = 3'b100; imm_s = 1'b1; end   //addi �з�������չ
            3'b100: ALU_OP = 3'b000; //andi
            3'b110: ALU_OP = 3'b010; //xori
            3'b011: ALU_OP = 3'b110; //sltiu
        endcase
    end
    //===========I��ָ��ȡ����ָ��
    else if(OP == 6'b100011 || OP == 6'b101011)
    begin
        rt_imm_s = 1'b1; imm_s = 1'b1;
        ALU_OP = 3'b100;    //ALU�ӷ��������ڼ���rs+offset
        if(OP == 6'b100011)         //lw
        begin
            Write_Reg = 1'b1;
            rt_rd_s = 1'b1;
            alu_mem_s = 1'b1;
        end
        else                        //sw
            Mem_Write = 1'b1;       //���ݼĴ���д���ź���1         
    end
end
endmodule
