`timescale 1ns/1ns
`default_nettype none

module branch_logic (
    input clk_i,
    input rst_i,
    input en_i,
    input typed_pkg::alu_opr_t opr_i,
    input logic [31:0] a_i,
    input logic [31:0] b_i,
    output logic [31:0] pc_update_o,
    output logic take_branch_o    
);

    import typed_pkg::*;
    
    logic [31:0] int_pc_update;
    logic int_take_branch;

    always_ff @( posedge clk_i ) begin 
        if (!rst_i) begin
            pc_update_o <= 'd0;
            take_branch_o <= 'd0;
        end else begin
            if (en_i == 1'b1) begin
                pc_update_o <= int_pc_update;
                take_branch_o <= int_take_branch;
            end else begin
                pc_update_o <= pc_update_o;
                take_branch_o <= take_branch_o;
            end
        end
    end

    always_comb begin 
        int_pc_update = 'd0;
        int_take_branch = 'd0;
        case (opr_i)
            ALU_ADD: int_pc_update = signed'(a_i) + signed'(b_i);
            ALU_JAL: int_pc_update = func_jal(a_i, b_i);
            ALU_JALR: int_pc_update = func_jalr(a_i, b_i);
            ALU_BEQ: int_take_branch = (a_i == b_i);
            ALU_BNE:  int_take_branch = (a_i != b_i);
            ALU_BLT: int_take_branch = (signed'(b_i) < signed'(a_i));
            ALU_BLTU: int_take_branch = (unsigned'(b_i) < unsigned'(a_i)); 
            ALU_BGE: int_take_branch = (signed'(b_i) >= signed'(a_i));
            ALU_BGEU:  int_take_branch = (unsigned'(b_i) >= unsigned'(a_i));
            default: begin
                int_pc_update = 'd0;
                int_take_branch = 'd0;
            end
        endcase
    end

    // Functions
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