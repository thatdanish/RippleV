// Execution stage

module ex_stage (
    input clk_i,
    input rst_i,
    input stall_ex_i,
    // MUX-ALU
    input typed_pkg::sel_alu_a_t sel_mux_alu_a,
    input typed_pkg::sel_alu_b_t sel_mux_alu_b,
    input logic [31:0] alu_mux_a_sign_ext_i,
    input logic [31:0] alu_mux_a_lui_i,
    input logic [31:0] alu_mux_a_rs2_i,
    input logic [31:0] alu_mux_b_pc_i
    input logic [31:0] alu_mux_b_rs1_i,
    // MUX-BL
    input typed_pkg::sel_alu_a_t sel_mux_bl_a,
    input typed_pkg::sel_alu_b_t sel_mux_bl_b,
    // ALU
    input alu_en_i,
    input typed_pkg::alu_opr_t alu_opr_i,
    output logic [31:0] alu_out_o,
    // BL
    input bl_en_i,
    input typed_pkg::alu_opr_t bl_opr_i,
    output bl_take_branch_o
    // Output
    output pc_update_o
);  
    logic [31:0] alu_out, bl_pc_update;

    assign alu_out_o = alu_out;

    mux_alu_a_v2 mux_alu_a_v2_inst (
        .clk_i,
        .sel_i(sel_mux_alu_a), 
        .const_4_i(32'd4), 
        .sign_ext_offset_i(alu_mux_a_sign_ext_i), 
        .lui_i(alu_mux_a_lui_i), 
        .rs2_i(alu_mux_a_rs2_i), 
        .data_o(alu_a_out)
    );

    mux_alu_b mux_alu_b_inst (
        .sel_i(sel_mux_alu_b), 
        .pc_i(alu_mux_b_pc_i), 
        .rs1_i(alu_mux_b_rs1_i),  
        .data_o(alu_b_out)
    );

    temp_alu_v2 temp_alu_v2_inst (
        .clk_i,
        .rst_i,
        .en_i(alu_en_i),
        .opr_i(alu_opr_i),
        .a_i(alu_a_out), 
        .b_i(alu_b_out),
        .out_o(alu_out),
    );

    branch_logic branch_logic_inst (
        .clk_i,
        .rst_i,
        .en_i(bl_en_i),
        .opr_i(bl_opr_i),
        .sign_ext_offset_i(alu_mux_a_sign_ext_i),
        .rs2_i(alu_mux_a_rs2_i),
        .rs1_i(alu_mux_b_rs1_i),
        .pc_i(alu_mux_b_pc_i),
        .pc_update_o(bl_pc_update),
        .take_branch_o(bl_take_branch_o)  
    );

    // Mux
    always_comb begin
        case (bl_take_branch_o)
            1'b0: pc_update_o = alu_out
            1'b1: pc_update = bl_pc_update
            default: 
        endcase
    end
    
endmodule