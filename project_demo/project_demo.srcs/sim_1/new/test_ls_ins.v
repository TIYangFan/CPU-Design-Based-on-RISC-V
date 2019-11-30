`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/30 15:41:27
// Design Name: 
// Module Name: test_ls_ins
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_ls_ins;

 
    reg clk;
    reg rst_n;
    
    // �Ĵ���
    reg [4:0]        rw;       // д���ַ
    wire [31:0]      bus_w;   // д������
    reg              reg_wr;  // дʹ��

    reg [4:0]        ra;      // ����ַ
    reg              re1;     // ��ˮ���Ż�
    wire [31:0]      bus_a;          // ��������

    reg [4:0]        rb;      // ����ַ
    reg              re2;     //��ˮ���Ż�
    wire [31:0]      bus_b;          // ������
    
    // ALU
    reg [3:0]          alu_ctr;
    //reg [31:0]         regA_i,regB_i;
    
    //wire [31:0]        res_o;
    wire               zero;
    
    
    // ��չ��
    reg [31:0]             instr;
    reg [2:0]              ext_op;
    wire [31:0]            imm;
    
    reg                    alu_bsrc; // mux from busb and imm.
    wire [31:0]            bus_bi;  // alu_bsrc result.
    
    // �洢��
    //reg [31:0]       addr;      // д���ַ
    //reg [31:0]       data_in;   // д������
    reg              mem_wr;    // дʹ��
    
    wire [31:0]      data_out;  // ��������
    
    reg             mem_to_reg; // mux from alu out and mem out.
    wire [31:0]     bus_wo;     // mem_to_reg result.
    
        
    initial begin
        clk = 0;
        rst_n = 0;
        #100;
        rst_n = 1'b1;
        reg_wr = 1'b1;  // �Ĵ���дʹ��
        mem_wr = 1'b1;  // �洢��дʹ��
        re1 = 1'b1;
        re2 = 1'b1;
        
        #100    // sw store.

        alu_ctr = 4'b0000;  // add 
        alu_bsrc = 1'b1;    // imm12 ��������չ
        ext_op = 3'b010;    // immS
        
        ra = 5'b00001;      // Rs1 R[Rs1]
        rb = 5'b00001;      // Rs2 R[Rs2]
        
        instr = 32'b0000_0000_0000_0000_0000_0000_1000_0000; // {{20{instr[31]}}, instr[31:25], instr[11:7]}
        mem_to_reg = 1'b1;
        
        
        #100    // lw load
        alu_ctr = 4'b0000;  // add 
        alu_bsrc = 1'b1;    // imm12 ��������չ
        ext_op = 3'b000;    // immI
        
        ra = 5'b00001;      // Rs1 R[Rs1]
        instr = 32'b0000_0000_0001_0000_0000_0000_0000_0000; // {{20{instr[31]}} , instr[31:20]}
        mem_to_reg = 1'b1;
        rw = 5'b00011;
        
        #100    // ��֤�Ƿ������洢�� Reg 
        ra = 5'b00011;
        
    end
    always #20 clk = ~clk;
    
    // �Ĵ���
    reg_file reg_file0(
        .rst_n(rst_n),
        .clk(clk),
        
        .rw(rw),
        .bus_w(bus_wo),
        .reg_wr(reg_wr),
        
        .ra(ra),
        .re1(re1),
        .bus_a(bus_a),
        
        .rb(rb),
        .re2(re2),
        .bus_b(bus_b)
        );
        
    // ALU
    alu_top alu_top0(
        .regA_i(bus_a), 
        .regB_i(bus_bi), 
        .alu_ctr(alu_ctr), 
        .res_o(bus_w), 
        .zero(zero)
        );
    
    // ��չ��
    ie ie0(
        .instr(instr),
        .ext_op(ext_op),
        .imm(imm)
    );
    
    // �洢��
    mem_file mem_file0(
        .rst_n(rst_n),
        .clk(clk),
    
        .addr(bus_w),      // д���ַ
        .data_in(bus_b),   // д������
        .mem_wr(mem_wr),    // дʹ��
        
        .data_out(data_out)  // д������
    );
    
    // mux from bus_b and imm. send bus_bi to alu regB_i.
    assign bus_bi = alu_bsrc ? imm : bus_b;
    
    // mux from alu out and mem out.
    assign bus_wo = mem_to_reg ? data_out : bus_w;

endmodule