`timescale 1ns/1ns
`default_nettype none

module temp_alu (
    input clk_i,
    input rst_i,
    input en_i,
    input logic [4:0] opr_i,
    input logic [31:0] a_i, 
    input logic [31:0] b_i,
    output logic [31:0] out_o,
    output logic take_branch_o
);

import ALU_pkg::*;

logic [31:0] int_out;
logic int_take_branch;

// rs2 -->a, rs1 -->b
always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        out_o <= 'd0;
        take_branch_o <= 'd0;
    end else begin
        if (en_i == 1'b1)  begin
            take_branch_o <= int_take_branch;
            out_o <= int_out;
        end else begin
            take_branch_o <= take_branch_o;
            out_o <= out_o;
        end
    end    
end

always_comb begin 
    int_out = 'd0;
    int_take_branch = 1'b0;
    case (opr_i)
        ALU_ADD : int_out = signed'(a_i) + (b_i); 
        ALU_SUB : int_out = a_i - b_i;
        ALU_MUL : int_out = func_mul(a_i, b_i);
        ALU_MULH : int_out = func_mulh(a_i, b_i);
        ALU_MULHU : int_out = func_mulhu(a_i, b_i);
        ALU_MULHSU : int_out = func_mulhsu(a_i, b_i);
        ALU_DIV : int_out = signed'(b_i)/signed'(a_i);
        ALU_DIVU : int_out = unsigned'(b_i)/unsigned'(a_i);
        ALU_REM : int_out = func_rem(a_i, b_i);
        ALU_REMU : int_out = unsigned'(b_i)%unsigned'(a_i);
        ALU_SLT : int_out = 32'(signed'(b_i)<signed'(a_i));
        ALU_SLTU : int_out = 32'(unsigned'(b_i)<unsigned'(a_i));
        ALU_AND : int_out = b_i & a_i;
        ALU_OR :  int_out = b_i | a_i;
        ALU_XOR : int_out = b_i ^ a_i;
        ALU_SLL : int_out = (b_i == 32'b0) ? 32'b0 : b_i << a_i[4:0];
        ALU_SRL : int_out = (b_i == 32'b0) ? 32'b0 : b_i >> a_i[4:0];
        ALU_SRA : int_out = (b_i == 32'b0) ? 32'b0 : b_i >>> a_i[4:0];
        ALU_JAL : int_out = func_jal(a_i,b_i);
        ALU_JALR : int_out = func_jalr(a_i,b_i);
        ALU_BEQ : int_take_branch = (a_i == b_i);
        ALU_BNE :  int_take_branch = (a_i != b_i);
        ALU_BLT : int_take_branch = (signed'(b_i) < signed'(a_i));
        ALU_BLTU : int_take_branch = (unsigned'(b_i) < unsigned'(a_i));
        ALU_BGE : int_take_branch = (signed'(b_i) >= signed'(a_i));
        ALU_BGEU : int_take_branch = (unsigned'(b_i) >= unsigned'(a_i));
        default: begin
            int_take_branch = 1'b0;
            int_out = 'b0;
        end
    endcase 

end

// Functions

function logic [31:0] func_mul (logic [31:0] a, b);
    bit [63:0] int_result;
    int_result = a * b;
    return int_result[31:0];
endfunction

function logic [31:0] func_mulh (logic [31:0] a, b);
    bit [63:0] int_result;
    int_result = signed'(a) * signed'(b);
    return int_result[63:32];
endfunction

function logic [31:0] func_mulhu (logic [31:0] a, b);
    bit [63:0] int_result;
    int_result = unsigned'(a) * unsigned'(b);
    return int_result[63:32];
endfunction

function logic [31:0] func_mulhsu (logic [31:0] a, b);
    bit [63:0] int_result;
    int_result = 64'(unsigned'(a)) * 64'(signed'(b));
    return int_result[63:32];
endfunction 

function logic [31:0] func_rem (logic [31:0] a, b);
    bit [31:0] int_result;
    int_result = signed'(b) % signed'(a);
    int_result[31] = b[31];
    return int_result;
endfunction

function logic [31:0] func_jal (logic [31:0] a, b);
    bit [31:0] int_result;
    int_result = a + b - 31'(4);
    return int_result;
endfunction

function logic [31:0] func_jalr (logic [31:0] a, b);
    bit [31:0] int_result;
    int_result = a + b;
    return {int_result[31:1], 1'b0};
endfunction


endmodule