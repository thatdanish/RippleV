`timescale 1ns/1ns
`default_nettype none

module temp_alu_v2 (
    input clk_i,
    input rst_i,
    input en_i,
    input typed_pkg::alu_opr_t opr_i,
    input logic [31:0] a_i, 
    input logic [31:0] b_i,
    output logic [31:0] out_o
);

import typed_pkg::*;

logic [31:0] int_out;

// rs2 -->a, rs1 -->b
always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        out_o <= 'd0;
    end else begin
        if (en_i == 1'b1)  begin
            out_o <= int_out;
        end else begin
            out_o <= out_o;
        end
    end    
end

always_comb begin 
    int_out = 'd0;
    case (opr_i)
        ALU_ADD : int_out = signed'(a_i) + (b_i); 
        ALU_SUB : int_out = b_i - a_i;
        ALU_MUL : int_out = func_mul(a_i, b_i);
        ALU_MULH : int_out = func_mulh(a_i, b_i);
        ALU_MULHU : int_out = func_mulhu(a_i, b_i);
        ALU_MULHSU : int_out = func_mulhsu(a_i, b_i);
        ALU_DIV : int_out = func_div(a_i,b_i);
        ALU_DIVU : int_out = func_divu(a_i, b_i);
        ALU_REM : int_out = func_rem(a_i, b_i);
        ALU_REMU : int_out = func_remu(a_i, b_i);
        ALU_SLT : int_out = 32'(signed'(b_i)<signed'(a_i));
        ALU_SLTU : int_out = 32'(unsigned'(b_i)<unsigned'(a_i));
        ALU_AND : int_out = b_i & a_i;
        ALU_OR :  int_out = b_i | a_i;
        ALU_XOR : int_out = b_i ^ a_i;
        ALU_SLL : int_out = (b_i == 32'b0) ? 32'b0 : b_i << a_i[4:0];
        ALU_SRL : int_out = (b_i == 32'b0) ? 32'b0 : b_i >> a_i[4:0];
        ALU_SRA : int_out = (b_i == 32'b0) ? 32'b0 : unsigned'(signed'(b_i) >>> a_i[4:0]);
        default: begin
            int_out = 'b0;
        end
    endcase 

end

// Functions

function logic [31:0] func_div (logic [31:0] a, b);
    if (b == 32'h80000000 && a == 32'hFFFFFFFF) 
        return b;
    else if (a == 32'd0)
        return 32'hFFFFFFFF;
    else
        return signed'(b_i)/signed'(a_i);
endfunction

function logic [31:0] func_divu (logic [31:0] a, b);
    if (a == 32'd0)
        return 32'hFFFFFFFF;
    else
        return unsigned'(b_i)/unsigned'(a_i);
endfunction

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
    if (a == 32'd0) 
        return b;
    else begin
        int_result = signed'(b) % signed'(a);
        return int_result;
    end
endfunction

function logic [31:0] func_remu (logic [31:0] a, b);
    bit [31:0] int_result;
    if (a == 32'd0) 
        return b;
    else begin
        int_result = unsigned'(b) % unsigned'(a);
        return int_result;
    end
endfunction

endmodule