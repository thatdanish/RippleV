// 
// Pipelined RippleV Core.
// 


module RippleV #(
    parameter ADDR_WIDTH = 32,
    parameter WORD_SIZE = 32,
    parameter string IMEM_FILE = "../../../data/sample/sample_instructions.hex",
    parameter string DMEM_FILE = "../../../data/sample/sample_instructions.hex",
    parameter LOAD_FROM_DMEM_HEX = 0,
    parameter RST_HND = 32'h0,
    parameter TRAP_HND = 32'd4,
    parameter INT_HND = 32'h3FF8
) (
    input clk_i,
    input rst_i,
    input ext_interrupt_i,
    input main_enable_i,
    output interrupt_ack_o 
);  
    import typed_pkg::*;

    HazardControlUnit hcu_inst (
        .clk_i,
        .rst_i,
        .hcu_inst_type_i(),
        .bl_take_branch_i(), 
        .rs1_i(), 
        .rs2_i(), 
        .rd_i(), 
        .stall_l1_o(),
        .clear_l1_o(),
        .stall_l2_o(),
        .clear_l2_o(),
        .stall_l3_o(),
        .clear_l3_o(),
        .stall_l4_o(),
        .clear_l4_o(),
        .stall_if_o(),
        .stall_id_o(),
        .stall_ex_o(),
        .stall_mem_o(),
        .stall_wb_o(),
        .hcu_hnd_stage_o() 
    // TODO : sel net for PC mux
    );

    If #(
        .FILE(IMEM_FILE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .WORD_SIZE(WORD_SIZE)
    ) if_inst (
        .clk_i,
        .rst_i,
        .stall_if_i(),
        // IMEM
        .inst_mem_en_i(),
        .inst_mem_data_o(),
        // PC v2
        .pc_en_i(),
        .pc_update_i()
    );

    l1_reg l1_reg_inst (
        .clk_i,
        .rst_i,
        .clear_l1_i(),
        .stall_l1_i(),
        .imem_inst_i(),
        .l1_imem_inst_o()
    );

    Id id_inst (
        .clk_i,
        .rst_i,
        // CU
        .main_enable_i(),
        .interrupt_i(),
        .pc_mux_sel_o(), 
        .pc_en_o(), 
        .csr_addr_from_ctrl_o(),
        .csr_data_from_ctrl_o(),
        .csr_addr_mux_sel_o(),
        .csr_data_mux_sel_o(),
        .csr_write_type_o(),
        .csr_rw_o(),
        .csr_en_o(),
        .inst_mem_en_o(),
        .take_branch_i(),
        .alu_en_o(),
        .alu_opr_o(),
        .alu_a_mux_sel_o(),
        .alu_b_mux_sel_o(),
        .data_mem_en_o(),
        .data_mem_transfer_type_o(),
        .data_mem_rw_o(),
        .data_mem_load_type_o(),
        // Decoder
        .decoder_inst_i(),
        .rd_o(),
        .rs1_o(),
        .rs2_o(),
        .csr_addr_o(),
        .imm_offset_o(),
        .lui_o(),
    );
    
    l2_reg l2_reg_inst (
        .clk_i,
        .rst_i,
        .clear_l2_i(), 
        .stall_l2_i(), 
        // Decoder v2
        .rs1_i(), 
        .rs2_i(), 
        .rd_i(), 
        .imm_offset_i(), 
        .lui_i(), 
        .csr_addr_i(), 
        .l2_rs1_o(), 
        .l2_rs2_o(), 
        .l2_rd_o(), 
        .l2_imm_offset_o(), 
        .l2_lui_o(), 
        .l2_csr_addr_o(), 
        // Control unit v2
        .csr_addr_from_ctrl_i(), 
        .csr_addr_mux_sel_i(), 
        .csr_data_mux_sel_i(), 
        .csr_write_type_i(), 
        .csr_rw_i(), 
        .csr_en_i(), 
        .csr_data_from_ctrl_i(), 
        .reg_file_addr_mux_sel_i(),
        .reg_file_data_mux_sel_i(),
        .reg_file_read_en_i(),
        .reg_file_write_en_i(),
        .alu_opr_i(),
        .alu_a_mux_sel_i(),
        .alu_b_mux_sel_i(),
        .alu_en_i(), 
        .bl_opr_i(),
        .branch_logic_en_i(),
        .data_mem_transfer_type_i(),
        .data_mem_rw_i(),
        .data_mem_load_type_i(), 
        .data_mem_en_i(),
        .l2_csr_addr_from_ctrl_o(), 
        .l2_csr_addr_mux_sel_o(), 
        .l2_csr_data_mux_sel_o(), 
        .l2_csr_write_type_o(), 
        .l2_csr_rw_o(), 
        .l2_csr_en_o(), 
        .l2_csr_data_from_ctrl_o(), 
        .l2_reg_file_addr_mux_sel_o(),
        .l2_reg_file_data_mux_sel_o(),
        .l2_reg_file_read_en_o(),
        .l2_reg_file_write_en_o(),
        .l2_alu_opr_o(),
        .l2_alu_a_mux_sel_o(),
        .l2_alu_b_mux_sel_o(),
        .l2_alu_en_o(), 
        .l2_bl_opr_o(),
        .l2_branch_logic_en_o(),
        .l2_data_mem_transfer_type_o(),
        .l2_data_mem_rw_o(),
        .l2_data_mem_load_type_o(), 
        .l2_data_mem_en_o(),
        // Reg file v2
        .rs1_data_i(),
        .rs2_data_i(),
        .l2_rs1_data_o(),
        .l2_rs2_data_o()
    );

    Ex ex_inst (
        .clk_i,
        .rst_i,
        .stall_ex_i(),
        // MUX-ALU
        .sel_mux_alu_a(),
        .sel_mux_alu_b(),
        .alu_mux_a_sign_ext_i(),
        .alu_mux_a_lui_i(),
        .alu_mux_a_rs2_i(),
        .alu_mux_b_pc_i(),
        .alu_mux_b_rs1_i(),
        // MUX-BL
        .sel_mux_bl_a(),
        .sel_mux_bl_b(),
        // ALU
        .alu_en_i(),
        .alu_opr_i(),
        .alu_out_o(),
        // BL
        .bl_en_i(),
        .bl_opr_i(),
        .bl_take_branch_o()
        // Output
        .pc_update_o()
    );
    
    l3_reg l3_reg_inst (
        .clk_i,
        .rst_i,
        .stall_l3_i(), 
        .clear_l3_i(), 
        .alu_out_i(),
        .l3_alu_out_o()
    );

    Mem mem_inst (
        .clk_i,
        .rst_i,
        .stall_mem_i(),
        // Data mem
        .data_mem_rw_i(),
        .data_mem_transfer_type_i(),
        .data_mem_load_type_i(),
        .data_mem_en_i(),
        .data_mem_addr_i(),
        .data_mem_data_i(),
        .data_mem_data_o(),
        // CSR mux
        .sel_mux_csr_addr(),
        .sel_mux_csr_data(),
        .csr_addr_from_cu_i(),
        .csr_addr_from_decoder_i(),
        .csr_pc_i(),
        .csr_uimm_i(),
        .csr_rs1_i(),
        .csr_from_ctrl_unit_i(),
        // CSR
        .csr_write_type_i(),
        .csr_rw_i(),
        .ext_interrupt_i(),
        .csr_en_i(),
        .interrupt_status_o(),
        .csr_data_o()      
    );
    
    l4_reg l4_reg_inst (
        .clk_i,
        .rst_i,
        .stall_l4_i(), 
        .clear_l4_i(), 
        .csr_data_i(),
        .l4_csr_data_o(),
        .dmem_data_i(),
        .l4_dmem_data_o()
    );
    
    // Reg file -- common to ID & WB stages

    RegFilev2 reg_file_inst (
        .clk_i,
        .rst_i,
        .read_en_i(),
        .write_en_i(),
        .stall_id_i(), 
        .rs1_addr_i(),
        .rs2_addr_i(),
        .rd_addr_i(),
        .rd_data_i(),
        .rs1_data_o(),
        .rs2_data_o() 
    );

    
endmodule