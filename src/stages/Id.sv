// Instruction decode stage

module Id (
    input clk_i,
    input rst_i,
    input stall_id_i,
    output interrupt_ack_o,
    // CU
    input main_enable_i,
    input interrupt_i,
    input typed_pkg::hcu_handler_stages_t hcu_hnd_stage_i, 
    output typed_pkg::csr_addr_t csr_addr_from_ctrl_o,
    output logic [31:0] csr_data_from_ctrl_o,
    output typed_pkg::sel_csr_addr_t csr_addr_mux_sel_o,
    output typed_pkg::sel_csr_data_t csr_data_mux_sel_o,
    output typed_pkg::write_t csr_write_type_o,
    output typed_pkg::rw_t csr_rw_o,
    output csr_en_o,
    output inst_mem_en_o,
    output typed_pkg::sel_reg_file_data_t reg_file_data_mux_sel_o,
    output reg_file_read_en_o,
    output reg_file_write_en_o,
    output alu_en_o,
    output typed_pkg::alu_opr_t alu_opr_o,
    output typed_pkg:: sel_alu_a_t alu_a_mux_sel_o,
    output typed_pkg:: sel_alu_a_t alu_b_mux_sel_o,
    output data_mem_en_o,
    output typed_pkg::alu_opr_t bl_opr_o,
    output branch_logic_en_o,
    output typed_pkg::transfer_t data_mem_transfer_type_o,
    output typed_pkg::rw_t data_mem_rw_o,
    output typed_pkg::load_t data_mem_load_type_o,
    output typed_pkg::instruction_type_t hcu_inst_type_o,
    // Decoder
    input logic [31:0] decoder_inst_i,
    output [4:0] rd_o,
    output [4:0] rs1_o,
    output [4:0] rs2_o,
    output typed_pkg::csr_addr_t csr_addr_o,
    output [31:0] imm_offset_o,
    output [31:0] lui_o
);
    import typed_pkg::*;

    ctrl_inst_t ctrl_instruction;
    
    ControlUnitv2 ctrl_unit_inst (
        .clk_i,
        .rst_i,
        .main_enable_i, 
        .interrupt_ack_o,
        .interrupt_i,
        .instruction_i(ctrl_instruction),
        .csr_addr_from_ctrl_o,
        .csr_data_from_ctrl_o,
        .csr_addr_mux_sel_o,
        .csr_data_mux_sel_o,
        .csr_write_type_o,
        .csr_rw_o,
        .csr_en_o,
        .inst_mem_en_o,
        .reg_file_data_mux_sel_o,
        .reg_file_read_en_o,
        .reg_file_write_en_o,
        .alu_en_o, 
        .alu_opr_o,
        .alu_a_mux_sel_o,
        .alu_b_mux_sel_o,
        .bl_opr_o,
        .branch_logic_en_o,
        .data_mem_en_o,
        .data_mem_transfer_type_o,
        .data_mem_rw_o,
        .data_mem_load_type_o,
        .hcu_hnd_stage_i
    );

    Decoderv2 decoder_inst (
        .clk_i,
        .rst_i,
        .stall_id_i,
        .inst_i(decoder_inst_i),
        .rd_o,
        .rs1_o,
        .rs2_o,
        .csr_addr_o,
        .imm_offset_o,
        .lui_o,
        .inst_to_ctrl_o(ctrl_instruction),
        .hcu_inst_type_o
    );
    
endmodule