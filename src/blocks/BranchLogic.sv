`timescale 1ns/1ns
`default_nettype none

module BranchLogic (
    input clk_i,
    input rst_i,
    input en_i,
    input typed_pkg::alu_opr_t opr_i,
    input logic [31:0] sign_ext_offset_i,
    input logic [31:0] rs2_i,
    input logic [31:0] rs1_i,
    input logic [31:0] pc_i,
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
                take_branch_o <= 1'b0;
            end
        end
    end

    always_comb begin 
        int_pc_update = 'd0;
        int_take_branch = 'd0;
        case (opr_i)
            ALU_JAL: begin
                int_take_branch = 1'b1;
                int_pc_update = func_jal(pc_i, sign_ext_offset_i);
            end
            ALU_JALR: begin
                int_take_branch = 1'b1;
                int_pc_update = func_jalr(rs1_i, sign_ext_offset_i);
            end
            ALU_BEQ: begin
               int_take_branch = (rs2_i == rs1_i);
               int_pc_update = signed'(pc_i) + signed'(sign_ext_offset_i);
            end
            ALU_BNE: begin 
                int_take_branch = (rs2_i != rs1_i);
                int_pc_update = signed'(pc_i) + signed'(sign_ext_offset_i);
            end
            ALU_BLT: begin 
                int_take_branch = (signed'(rs1_i) < signed'(rs2_i));
                int_pc_update = signed'(pc_i) + signed'(sign_ext_offset_i);
            end
            ALU_BLTU:begin 
                int_take_branch = (unsigned'(rs1_i) < unsigned'(rs2_i)); 
                int_pc_update = signed'(pc_i) + signed'(sign_ext_offset_i);
            end
            ALU_BGE: begin 
                int_take_branch = (signed'(rs1_i) >= signed'(rs2_i));
                int_pc_update = signed'(pc_i) + signed'(sign_ext_offset_i);
            end
            ALU_BGEU:begin 
                 int_take_branch = (unsigned'(rs1_i) >= unsigned'(rs2_i));
                 int_pc_update = signed'(pc_i) + signed'(sign_ext_offset_i);
                end
            default: begin
                int_take_branch = 'd0;
                int_pc_update = signed'(pc_i) + signed'(32'd4);
            end
        endcase
    end

    // Functions
    function logic [31:0] func_jal (logic [31:0] a, b);
        bit [31:0] int_result;
        int_result = a + b;
        return int_result;
    endfunction

    function logic [31:0] func_jalr (logic [31:0] a, b);
        bit [31:0] int_result;
        int_result = a + b;
        return {int_result[31:1], 1'b0};
    endfunction
    
endmodule