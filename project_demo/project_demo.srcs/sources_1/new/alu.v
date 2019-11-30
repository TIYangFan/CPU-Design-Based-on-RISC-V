module alu(
    
    input [31:0]         regA_i,
    input [31:0]         regB_i,
    
    input                sub_ctr_i,
    input                sig_ctr_i,
    input [1:0]          op_ctr_i,
    
    output   zf, // ���־
    output   sf, // ���ű�־
    output   cf, // ��λ/��λ��־
    output   of, // �����־
    
    output reg           cout,
    output reg [31:0]    result_o
    
    );

reg [31:0] result;

    
always @ (*) begin

    case(op_ctr_i)
        
        2'b00, 2'b11: begin    // add sub ѡ��ӷ���������
            
            // ������չ
            if (sub_ctr_i) begin
                {cout, result} <= regA_i + ~regB_i + sub_ctr_i;  
            end       
            else begin
                {cout, result} <= regA_i + regB_i + sub_ctr_i;
            end
                        
            if (op_ctr_i == 2'b00) begin
                result_o <= result;
            end
            
            else if(op_ctr_i == 2'b11) begin
                
                if (sig_ctr_i) begin // �����������Ƚ�С���� 1
                    result_o <= {(of|sf), 31'b0}; // ����չ
                end
                
                else begin
                    result_o <= {(sub_ctr_i|cf), 31'b0};// ����չ    
                end                
            
            end
                         
        end 
        
        2'b01: begin    // or ѡ�񡰰�λ�򡱽�����
            result <= regA_i | regB_i;
        end
        
        2'b10: begin    // srcB ѡ������� B ֱ�����
            result <= regB_i;
        end
        
        // 2'b11: begin    // slt sltu ѡ��С����λ������
        // end
        
    endcase
    
end

assign zf = (result_o == 32'b0 ? 1'b1 : 1'b0); // ���־
assign sf = result_o[31];   // ���ű�־
assign cf = (sub_ctr_i ? ~cout : cout); // ��λ/��λ��־
assign of = ((result_o[31] ^ regA_i[31]) && (result_o[31] ^ regB_i[31]) ? 1'b1 : 1'b0 ); // �����־
    
    
endmodule