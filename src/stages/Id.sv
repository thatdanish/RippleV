// Instruction decode stage

module id_stage (
    input clk_i,
    input rst_i,
    // CU
    input main_enable_i
    input interrupt_i,
    output pc_mux_sel_o, 
    output pc_en_o, 
    output typed_pkg::csr_addr_t csr_addr_from_ctrl_o,
    output csr_data_from_ctrl_o,
    output csr_addr_mux_sel_o,
    output csr_data_mux_sel_o,
    output typed_pkg::write_t csr_write_type_o,
    output typed_pkg::rw_t csr_rw_o,
    output csr_en_o,
    output inst_mem_en_o,
    input take_branch_i,
    input alu_en_o,
    input typed_pkg::alu_opr_t alu_opr_o,
    output alu_a_mux_sel_o,
    output alu_b_mux_sel_o,
    output data_mem_en_o,
    output typed_pkg::transfer_t data_mem_transfer_type_o,
    output typed_pkg::rw_t data_mem_rw_o,
    output typed_pkg::load_t data_mem_load_type_o
    // Decoder
    input decoder_inst_i,
    output rd_o,
    output rs1_o,
    output rs2_o,
    output typed_pkg::csr_addr_t csr_addr_o,
    output imm_offset_o,
    output lui_o,
    // Reg-file
    input reg_file_addr_i,
    input reg_file_data_i,
    output reg_file_data_o
);
    import typed_pkg::*;

    ctrl_unit ctrl_unit_inst (
        .clk_i,
        .rst_i,
        .main_enable_i, 
        .interrupt_ack_o,
        .interrupt_i,
        .instruction_i()
        .pc_mux_sel_o, 
        .pc_en_o, 
        .csr_addr_from_ctrl_o,
        .csr_data_from_ctrl_o,
        .csr_addr_mux_sel_o,
        .csr_data_mux_sel_o,
        .csr_write_type_o,
        .csr_rw_o,
        .csr_en_o,
        .inst_mem_en_o,
        .reg_file_addr_mux_sel_o(),
        .reg_file_data_mux_sel_o(),
        .reg_file_rw_o(),
        .reg_file_en_o(),
        .take_branch_i, 
        .alu_en_o, 
        .alu_opr_o,
        .alu_a_mux_sel_o,
        .alu_b_mux_sel_o,
        .data_mem_en_o,
        .data_mem_transfer_type_o,
        .data_mem_rw_o,
        .data_mem_load_type_o
    );

    decoder decoder_inst (
        .clk_i,
        .rst_i,
        .inst_i(decoder_inst_i),
        .rd_o,
        .rs1_o,
        .rs2_o,
        .csr_addr_o,
        .imm_offset_o,
        .lui_o,
        .inst_to_ctrl_o() 
    );

    reg_file reg_file_inst (
        .clk_i,
        .rst_i,
        .en_i(reg_file_enable), 
        .rw_i(reg_file_rw),
        .addr_i,
        .data_i,
        .data_o
    );
    
endmodule