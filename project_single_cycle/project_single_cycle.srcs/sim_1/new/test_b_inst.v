`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/01 08:38:32
// Design Name: 
// Module Name: test_b_inst
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


module test_b_inst;
 
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
    
    
    // pc
    wire [31:0]    cur_pc;
    //reg  [31:0]    imm;
    reg           branch;
    //reg           zero;

    wire [31:0]    next_pc;

    reg              ce;
    //reg  [31:0]      addr;
    wire [31:0]     inst;
    
        
    initial begin
        clk = 0;
        rst_n = 0;
        #100;
        rst_n = 1'b1;
        reg_wr = 1'b0;  // �Ĵ���дʹ��
        mem_wr = 1'b0;  // �洢��дʹ��
        re1 = 1'b1;
        re2 = 1'b1;
        
        #50    // R[Rs1] == R[Rs2] PC <- PC + (SEXT(imm12) * 2)

        alu_ctr = 4'b1000;  // sub
        alu_bsrc = 1'b0;    // alu
        ext_op = 3'b011;    // immB
        branch = 1'b1;      // next_pc
        
        ra = 5'b00001;      // Rs1 R[Rs1]
        rb = 5'b00001;      // Rs2 R[Rs2]
        
        instr = 32'b0000_0000_0000_0000_0000_0100_0000_0000; //  imm <= {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        mem_to_reg = 1'b1;
        
        
        #50    // R[Rs1] != R[Rs2] PC <- PC + 4
        
        alu_ctr = 4'b1000;  // sub
        alu_bsrc = 1'b0;    // alu
        ext_op = 3'b011;    // immB
        branch = 1'b1;      // next_pc
        
        ra = 5'b00001;      // Rs1 R[Rs1]
        rb = 5'b00010;      // Rs2 R[Rs2]
        
        instr = 32'b0000_0000_0000_0000_0000_0100_0000_0000;
        
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
    data_mem data_mem0(
        .rst_n(rst_n),
        .clk(clk),
    
        .addr(bus_w),      // д���ַ
        .data_in(bus_b),   // д������
        .mem_wr(mem_wr),    // дʹ��
        
        .data_out(data_out)  // д������
    );
    
    // �µ�ַ�߼�
    next_pc next_pc0(
        .pc(cur_pc),
        .imm(imm),
        .branch(branch),
        .zero(zero),
        .next_pc(next_pc)
        );
    
    // ָ��洢��
    inst_rom inst_rom0(
        .ce(ce),
        .addr(cur_pc),
        .inst(inst)
        );
    
    // ���������
    pc_reg pc_reg0(
        .clk(clk),
        .rst_n(rst_n),
        
        .next_pc(next_pc),
        .cur_pc(cur_pc)
        );
    
    // mux from bus_b and imm. send bus_bi to alu regB_i.
    assign bus_bi = alu_bsrc ? imm : bus_b;
    
    // mux from alu out and mem out.
    assign bus_wo = mem_to_reg ? data_out : bus_w;

endmodule
