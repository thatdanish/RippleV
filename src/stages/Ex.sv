// Execution stage

module ex_stage (
    input clk_i,
    input rst_i,
    // ALU
    input alu_en_i,
    input typed_pkg::alu_opr_t alu_opr_i,
    input alu_a_i,
    input alu_b_i,
    output alu_out_o,
    output alu_take_branch_o
);
    temp_alu temp_alu_inst (
        .clk_i,
        .rst_i,
        .en_i(alu_en_i),
        .opr_i(alu_opr_i),
        .a_i(alu_a_i), 
        .b_i(alu_b_i),
        .out_o(alu_out_o),
        .take_branch_o(alu_take_branch_o)
    );
endmodule