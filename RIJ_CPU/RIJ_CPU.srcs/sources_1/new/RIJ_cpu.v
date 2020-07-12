`timescale 1ns / 1ps

module RIJ_CPU(
    input clk,
    input rst,
    output OF,   //������Ӱ��ı�־λ
    output ZF,
    output [31:0] ALU_F,
    output [31:0] M_R_Data
    );
//wire [31:0]ALU_F;
wire [31:0] PC;
wire [31:0] Inst_code;
wire [31:0] ALU_A,ALU_B;
wire Write_Reg;
wire [2:0] ALU_OP;
wire [5:0]OP,func;
wire [4:0]Rs,Rt,Rd;

//---------����I��ָ����ر���
wire [1:0] w_r_s, wr_data_s;
wire imm_s, rt_imm_s;      //��ѡһ����ѡ���ź�
wire [4:0]W_Addr;
wire [15:0] imm;
wire [31:0] imm_data;
wire Mem_Write;
wire [31:0] M_W_Data;
wire [31:0] W_Data, R_Data_B;
wire clk_ram;
//---------����J����ر���
wire [1:0] pc_s;    //pc��ѡһ����ѡ����
wire [25:0] address;
assign OP =  Inst_code[31:26];
assign Rs =  Inst_code[25:21];
assign Rt =  Inst_code[20:16];
assign Rd =  Inst_code[15:11];
assign func =  Inst_code[5:0];
assign imm  = Inst_code[15:0];
assign address = Inst_code[25:0];

assign W_Addr = (w_r_s[1])? 5'b11111: ((w_r_s[0]) ? Rt : Rd);
assign W_Data = (wr_data_s[1])? PC+4 : ((wr_data_s[0])? M_R_Data : ALU_F); //lwд��Ĵ���
assign imm_data = (imm_s)? {{16{imm[15]}},imm} : {{16{1'b0}},imm};  //��ȡ����offset
assign ALU_B = (rt_imm_s) ? imm_data : R_Data_B;
assign M_W_Data = R_Data_B;     //sw����Rt��M_W_Data����д��rs+offset ���ݴ洢��

//assign #10 clk_ram = clk;   //��ʱ���ݼĴ�����ʱ������

//PC����ģ�飬������µ�PCֵ
PC_add  auto_increase_pc(
    .clk        (~clk),
    .rst        (rst),
    .pc_s       (pc_s),
    .R_Data_A   (ALU_A),
    .imm_data   (imm_data),
    .address    (address),
    .PC         (PC)
);

//ָ��Ĵ���ģ�飬����Ĵ�����ַ�������ַ�ϵ�ָ������
blk_mem_gen_0 Inst_store (
  .clka         (clk),
  .addra        (PC[7:2]),
  .douta        (Inst_code)
);
//���ݼĴ���ģ��
mem_store mem_store (
  .Clk                  (clk),    // ʱ��
  .Reset                (rst),
  .Mem_Write            (Mem_Write),      // д���ź�
  .addra                (ALU_F[7:2]),  // д���ַ
  .M_W_Data             (M_W_Data),    // д������
  .M_R_Data             (M_R_Data)  // �������
);
register_store reg_store(
    .Clk        (~clk),
    .Reset      (rst),
    .R_Addr_A   (Rs),
    .R_Addr_B   (Rt),
    .W_Addr     (W_Addr),
    .W_Data     (W_Data),
    .Write_Reg  (Write_Reg),
    .R_Data_A   (ALU_A),
    .R_Data_B   (R_Data_B)

);

//ALU���㣬�������W_Data��ͨ��ʱ���߼���·д��Ĵ���
ALU_32 alu(
    .clk        (~clk),
    .rst        (rst),
    .A          (ALU_A),        //ALU_A�����Ǵ�R_Data_A����
    .B          (ALU_B),
    .ALU_OP     (ALU_OP),
    .F          (ALU_F),
    .FR_ZF      (ZF),
    .FR_OF      (OF)
);

//ָ������Ϳ��Ƶ�Ԫ
Decoding_control Decode_control(
    .OP         (OP),
    .ZF         (ZF),
    .OF         (OF),
    .PC_s       (pc_s),
    .w_r_s      (w_r_s),
    .imm_s      (imm_s),
    .rt_imm_s   (rt_imm_s),
    .wr_data_s  (wr_data_s),
    .Mem_Write  (Mem_Write),
    .func       (func),
    .Write_Reg  (Write_Reg),
    .ALU_OP     (ALU_OP)
);

endmodule
