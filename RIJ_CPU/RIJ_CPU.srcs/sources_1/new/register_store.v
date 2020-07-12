`timescale 1ns / 1ps
module register_store(
    input Clk,
    input Reset,
    input [6:2] R_Addr_A,       //��2�ֽڶ��룬��5�ֽڶ�Ӧ�Ĵ������
    input [6:2] R_Addr_B,
    input [6:2] W_Addr,
    input [31:0]W_Data,
    input Write_Reg,            //д�ź�
    output wire [31:0]R_Data_A,
    output wire [31:0]R_Data_B
    );

//�Ĵ�����
reg [31:0] REG_files[1:31];

//������ ����߼���·��û�ж��������źţ���ʱ��
assign R_Data_A = (R_Addr_A==5'b00000)? 32'h0000_0000 : REG_files[R_Addr_A[6:2]];
assign R_Data_B = (R_Addr_B==5'b00000)? 32'h0000_0000 : REG_files[R_Addr_B[6:2]];

//д����
integer i;
always@(posedge Clk or posedge Reset)
begin
    if(Reset)
        //�Ĵ����ѳ�ʼ��
        begin
            for(i = 4; i <= 124; i = i + 4)
                REG_files[ i/4 ] = 32'h0000_0000;
        end
    else
        begin
            //����Ϊ�˲��ԼĴ����Ѻ�ALU�Ľ�����ʱ
           
            //д��Ĵ���
           if(Write_Reg && (W_Addr[6:2] != 5'b00000))
                REG_files[W_Addr[6:2]] = W_Data;
        end
end

endmodule
