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
    
    // Misc
    logic stall_if, stall_l1, stall_id, stall_l2, stall_ex, stall_l3, stall_mem, stall_l4, stall_wb, clear_l1, clear_l2;
    logic clear_l3, clear_l4, imem_enable, csr_enable, l2_csr_enable, l3_csr_enable, alu_enable, l2_alu_enable, bl_enable, l2_bl_enable;
    logic dmem_enable, l2_dmem_enable, l3_dmem_enable, reg_file_read_enable, reg_file_write_enable, l2_reg_file_write_enable, l3_reg_file_write_enable, l4_reg_file_write_enable;
    logic bl_take_branch, interrupt_status, pc_enable;
    
    logic [31:0] riscv_instruction, l1_riscv_instruction, csr_data_from_cu, l2_csr_data_from_cu, l3_csr_data_from_cu;
    logic [31:0] rs1_data, l2_rs1_data, l3_rs1_data, rs2_data, l2_rs2_data, imm_offset, l2_imm_offset, l3_imm_offset, lui, l2_lui, l3_lui, l4_lui;
    logic [31:0] pc_addr, l1_pc_addr, l2_pc_addr, l3_pc_addr, l4_pc_addr, pc_new, alu_out, l3_alu_out, l4_alu_out, l3_dmem_addr, l3_dmem_data;
    logic [31:0] dmem_out_data, l4_dmem_out_data, csr_out_data, l4_csr_out_data, pc_update_from_execute, pc_direct_update_from_execute, reg_file_rd_data;

    logic [4:0] rs1_addr, rs1_addr_hcu, l2_rs1_addr, rs2_addr, rs2_addr_hcu, l2_rs2_addr, rd_addr, rd_addr_hcu, l2_rd_addr, l3_rd_addr, l4_rd_addr; 
    
    // CSR
    sel_csr_addr_t sel_csr_addr, l2_sel_csr_addr, l3_sel_csr_addr;
    sel_csr_data_t sel_csr_data, l2_sel_csr_data, l3_sel_csr_data;
    csr_addr_t csr_addr_decoder, l2_csr_addr_decoder, l3_csr_addr_decoder;
    csr_addr_t csr_addr_from_cu, l2_csr_addr_from_cu, l3_csr_addr_from_cu;
    write_t csr_write_type, l2_csr_write_type, l3_csr_write_type;
    rw_t csr_rw, l2_csr_rw, l3_csr_rw;
    
    // ALU
    sel_alu_a_t sel_alu_a, l2_sel_alu_a;
    sel_alu_b_t sel_alu_b, l2_sel_alu_b;
    alu_opr_t alu_operation, l2_alu_operation, bl_operation, l2_bl_operation;

    // DMEM
    transfer_t dmem_transfer_type, l2_dmem_transfer_type, l3_dmem_transfer_type;
    load_t dmem_load_type, l2_dmem_load_type, l3_dmem_load_type;
    rw_t  dmem_rw, l2_dmem_rw, l3_dmem_rw;        

    // RegFile v2
    sel_reg_file_data_t sel_reg_file_data, l2_sel_reg_file_data, l3_sel_reg_file_data, l4_sel_reg_file_data;
    
    // PC
    sel_pc_t sel_pc;

    // HCU
    hcu_handler_stages_t hcu_handler_stage;

    // CU
    instruction_type_t hcu_instruction;

     // Hazard Control Unit -----------------------------------------------------------------------

    HazardControlUnit hcu_inst (
        .clk_i,
        .rst_i,
        .hcu_inst_type_i(hcu_instruction),
        .bl_take_branch_i(bl_take_branch), 
        .rs1_i(rs1_addr_hcu), 
        .rs2_i(rs2_addr_hcu), 
        .rd_i(rd_addr_hcu), 
        .stall_l1_o(stall_l1),
        .clear_l1_o(clear_l1),
        .stall_l2_o(stall_l2),
        .clear_l2_o(clear_l2),
        .stall_l3_o(stall_l3),
        .clear_l3_o(clear_l3),
        .stall_l4_o(stall_l4),
        .clear_l4_o(clear_l4),
        .stall_if_o(stall_if),
        .stall_id_o(stall_id),
        .stall_ex_o(stall_ex),
        .stall_mem_o(stall_mem),
        .stall_wb_o(stall_wb),
        .hcu_hnd_stage_o(hcu_handler_stage), 
        .pc_en_o(pc_enable),
        .pc_sel_o(sel_pc)
    );

    always_ff @( posedge clk_i ) begin : DelayRegisters
        rs1_addr_hcu <= rs1_addr;
        rs2_addr_hcu <= rs2_addr;
        rd_addr_hcu <= rd_addr;
    end

    // Instruction-fetch --------------------------------------------------------------------------

    mux_pc_v2 #( 
        .ADDR_WIDTH(ADDR_WIDTH),
        .INT_HND(INT_HND)
    ) mux_pc_inst (
        .clk_i,
        .sel_i(sel_pc),
        .pc_direct_update_i(pc_direct_update_from_execute),
        .pc_update_i(pc_update_from_execute),
        .jump_vec_i(csr_out_data),
        .data_o(pc_new)
    );

    If #(
        .FILE(IMEM_FILE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .WORD_SIZE(WORD_SIZE)
    ) if_inst (
        .clk_i,
        .rst_i,
        .stall_if_i(stall_if),
        // IMEM
        .inst_mem_en_i(imem_enable),
        .inst_mem_data_o(riscv_instruction),
        // PC v2
        .pc_en_i(pc_enable),
        .pc_update_i(pc_new),
        .pc_out_o(pc_addr)
    );

    // Pipeline register I ------------------------------------------------------------------------

    l1_reg l1_reg_inst (
        .clk_i,
        .rst_i,
        .clear_l1_i(clear_l1),
        .stall_l1_i(stall_l1),
        .imem_inst_i(riscv_instruction),
        .l1_imem_inst_o(l1_riscv_instruction),
        .pc_i(pc_addr),
        .l1_pc_out_o(l1_pc_addr)
    );

    // Instruction-decode -------------------------------------------------------------------------

    Id id_inst (
        .clk_i,
        .rst_i,
        .stall_id_i(stall_id),
        .interrupt_ack_o,
        // CU
        .main_enable_i,
        .interrupt_i(interrupt_status),
        .hcu_hnd_stage_i(hcu_handler_stage), 
        .csr_addr_from_ctrl_o(csr_addr_from_cu),
        .csr_data_from_ctrl_o(csr_data_from_cu),
        .csr_addr_mux_sel_o(sel_csr_addr),
        .csr_data_mux_sel_o(sel_csr_data),
        .csr_write_type_o(csr_write_type),
        .csr_rw_o(csr_rw),
        .csr_en_o(csr_enable),
        .inst_mem_en_o(imem_enable),
        .reg_file_data_mux_sel_o(sel_reg_file_data),
        .reg_file_read_en_o(reg_file_read_enable),
        .reg_file_write_en_o(reg_file_write_enable),
        .alu_en_o(alu_enable),
        .alu_opr_o(alu_operation),
        .alu_a_mux_sel_o(sel_alu_a),
        .alu_b_mux_sel_o(sel_alu_b),
        .bl_opr_o(bl_operation),
        .branch_logic_en_o(bl_enable),
        .data_mem_en_o(dmem_enable),
        .data_mem_transfer_type_o(dmem_transfer_type),
        .data_mem_rw_o(dmem_rw),
        .data_mem_load_type_o(dmem_load_type),
        // Decoder
        .decoder_inst_i(l1_riscv_instruction),
        .rd_o(rd_addr),
        .rs1_o(rs1_addr),
        .rs2_o(rs2_addr),
        .csr_addr_o(csr_addr_decoder),
        .imm_offset_o(imm_offset),
        .lui_o(lui),
        .hcu_inst_type_o(hcu_instruction)
    );
    
    // Pipeline register II -----------------------------------------------------------------------

    l2_reg l2_reg_inst (
        .clk_i,
        .rst_i,
        .clear_l2_i(clear_l2), 
        .stall_l2_i(stall_l2), 
        // Decoder v2
        .rs1_i(rs1_addr), 
        .rs2_i(rs2_addr), 
        .rd_i(rd_addr), 
        .imm_offset_i(imm_offset), 
        .lui_i(lui), 
        .csr_addr_i(csr_addr_decoder), 
        .l2_rs1_o(l2_rs1_addr), 
        .l2_rs2_o(l2_rs2_addr), 
        .l2_rd_o(l2_rd_addr), 
        .l2_imm_offset_o(l2_imm_offset), 
        .l2_lui_o(l2_lui), 
        .l2_csr_addr_o(l2_csr_addr_decoder), 
        // Control unit v2
        .csr_addr_from_ctrl_i(csr_addr_from_cu), 
        .csr_addr_mux_sel_i(sel_csr_addr), 
        .csr_data_mux_sel_i(sel_csr_data), 
        .csr_write_type_i(csr_write_type), 
        .csr_rw_i(csr_rw), 
        .csr_en_i(csr_enable), 
        .csr_data_from_ctrl_i(csr_data_from_cu), 
        .reg_file_data_mux_sel_i(sel_reg_file_data),
        .alu_opr_i(alu_operation),
        .alu_a_mux_sel_i(sel_alu_a),
        .alu_b_mux_sel_i(sel_alu_b),
        .alu_en_i(alu_enable), 
        .bl_opr_i(bl_operation),
        .branch_logic_en_i(bl_enable),
        .data_mem_transfer_type_i(dmem_transfer_type),
        .data_mem_rw_i(dmem_rw),
        .data_mem_load_type_i(dmem_load_type), 
        .data_mem_en_i(dmem_enable),
        .l2_csr_addr_from_ctrl_o(l2_csr_addr_from_cu), 
        .l2_csr_addr_mux_sel_o(l2_sel_csr_addr), 
        .l2_csr_data_mux_sel_o(l2_sel_csr_data), 
        .l2_csr_write_type_o(l2_csr_write_type), 
        .l2_csr_rw_o(l2_csr_rw), 
        .l2_csr_en_o(l2_csr_enable), 
        .l2_csr_data_from_ctrl_o(l2_csr_data_from_cu), 
        .l2_reg_file_data_mux_sel_o(l2_sel_reg_file_data),
        .l2_alu_opr_o(l2_alu_operation),
        .l2_alu_a_mux_sel_o(l2_sel_alu_a),
        .l2_alu_b_mux_sel_o(l2_sel_alu_b),
        .l2_alu_en_o(l2_alu_enable), 
        .l2_bl_opr_o(l2_bl_operation),
        .l2_branch_logic_en_o(l2_bl_enable),
        .l2_data_mem_transfer_type_o(l2_dmem_transfer_type),
        .l2_data_mem_rw_o(l2_dmem_rw),
        .l2_data_mem_load_type_o(l2_dmem_load_type), 
        .l2_data_mem_en_o(l2_dmem_enable),
        // Reg file v2
        .reg_file_read_en_i(reg_file_read_enable),
        .reg_file_write_en_i(reg_file_write_enable),
        .rs1_data_i(rs1_data),
        .rs2_data_i(rs2_data),
        .l2_rs1_data_o(l2_rs1_data),
        .l2_rs2_data_o(l2_rs2_data),
        .l2_reg_file_write_en_o(l2_reg_file_write_enable),
        // PC
        .pc_i(l1_pc_addr),
        .l2_pc_out_o(l2_pc_addr)
    );

    // Execute ------------------------------------------------------------------------------------

    Ex ex_inst (
        .clk_i,
        .rst_i,
        .stall_ex_i(stall_ex),
        // MUX-ALU
        .sel_mux_alu_a(l2_sel_alu_a),
        .sel_mux_alu_b(l2_sel_alu_b),
        .alu_mux_a_sign_ext_i(l2_imm_offset),
        .alu_mux_a_lui_i(l2_lui),
        .alu_mux_a_rs2_i(l2_rs2_data),
        .alu_mux_b_pc_i(l2_pc_addr),
        .alu_mux_b_rs1_i(l2_rs1_data),
        // ALU
        .alu_en_i(l2_alu_enable),
        .alu_opr_i(l2_alu_operation),
        .alu_out_o(alu_out),
        // BL
        .bl_en_i(l2_bl_enable),
        .pc_direct_i(pc_addr),
        .bl_opr_i(l2_bl_operation),
        .bl_take_branch_o(bl_take_branch),
        // Output
        .pc_update_o(pc_update_from_execute),
        .pc_direct_update_o(pc_direct_update_from_execute)
    );
    
    // Pipeline register III ----------------------------------------------------------------------

    l3_reg l3_reg_inst (
        .clk_i,
        .rst_i,
        .stall_l3_i(stall_l3), 
        .clear_l3_i(clear_l3), 
        .lui_i(l2_lui),
        .l3_lui_o(l3_lui),
        .alu_out_i(alu_out),
        .l3_alu_out_o(l3_alu_out),
        .dmem_en_i(l2_dmem_enable),
        .data_mem_rw_i(l2_dmem_rw),
        .data_mem_transfer_type_i(l2_dmem_transfer_type),
        .data_mem_load_type_i(l2_dmem_load_type),
        .data_mem_addr_i(alu_out),
        .data_mem_data_i(l2_rs2_data),
        .l3_dmem_en_o(l3_dmem_enable),
        .l3_data_mem_rw_o(l3_dmem_rw),
        .l3_data_mem_transfer_type_o(l3_dmem_transfer_type),
        .l3_data_mem_load_type_o(l3_dmem_load_type),
        .l3_data_mem_addr_o(l3_dmem_addr),
        .l3_data_mem_data_o(l3_dmem_data),
        .sel_mux_csr_addr_i(l2_sel_csr_addr),
        .sel_mux_csr_data_i(l2_sel_csr_data),
        .csr_addr_from_cu_i(l2_csr_addr_from_cu),
        .csr_addr_from_decoder_i(l2_csr_addr_decoder),
        .csr_pc_i(l2_pc_addr),
        .csr_uimm_i(l2_imm_offset),
        .csr_rs1_i(l2_rs1_data),
        .csr_data_from_ctrl_unit_i(l2_csr_data_from_cu),
        .l3_sel_mux_csr_addr_o(l3_sel_csr_addr),
        .l3_sel_mux_csr_data_o(l3_sel_csr_data),
        .l3_csr_addr_from_cu_o(l3_csr_addr_from_cu),
        .l3_csr_addr_from_decoder_o(l3_csr_addr_decoder),
        .l3_csr_pc_o(l3_pc_addr),
        .l3_csr_uimm_o(l3_imm_offset),
        .l3_csr_rs1_o(l3_rs1_data),
        .l3_csr_data_from_ctrl_unit_o(l3_csr_data_from_cu),
        .csr_write_type_i(l2_csr_write_type),
        .csr_rw_i(l2_csr_rw),
        .csr_en_i(l2_csr_enable),
        .l3_csr_write_type_o(l3_csr_write_type),
        .l3_csr_rw_o(l3_csr_rw),
        .l3_csr_en_o(l3_csr_enable),
        .reg_file_write_en_i(l2_reg_file_write_enable),
        .reg_file_rd_addr_i(l2_rd_addr), 
        .reg_file_data_mux_sel_i(l2_sel_reg_file_data), 
        .l3_reg_file_write_en_o(l3_reg_file_write_enable),
        .l3_reg_file_rd_addr_o(l3_rd_addr), 
        .l3_reg_file_data_mux_sel_o(l3_sel_reg_file_data)
    );

    // Memory -------------------------------------------------------------------------------------

    Mem mem_inst (
        .clk_i,
        .rst_i,
        .stall_mem_i(stall_mem),
        // Data mem
        .data_mem_rw_i(l3_dmem_rw),
        .data_mem_transfer_type_i(l3_dmem_transfer_type),
        .data_mem_load_type_i(l3_dmem_load_type),
        .data_mem_en_i(l3_dmem_enable),
        .data_mem_addr_i(l3_dmem_addr),
        .data_mem_data_i(l3_dmem_data),
        .data_mem_data_o(dmem_out_data),
        // CSR mux
        .sel_mux_csr_addr_i(l3_sel_csr_addr),
        .sel_mux_csr_data_i(l3_sel_csr_data),
        .csr_addr_from_cu_i(l3_csr_addr_from_cu),
        .csr_addr_from_decoder_i(l3_csr_addr_decoder),
        .csr_pc_i(l3_pc_addr),
        .csr_uimm_i(l3_imm_offset),
        .csr_rs1_i(l3_rs1_data),
        .csr_data_from_ctrl_unit_i(l3_csr_data_from_cu),
        // CSR
        .csr_write_type_i(l3_csr_write_type),
        .csr_rw_i(l3_csr_rw),
        .ext_interrupt_i,
        .csr_en_i(l3_csr_enable),
        .interrupt_status_o(interrupt_status),
        .csr_data_o(csr_out_data)      
    );

    // Pipeline register IV -----------------------------------------------------------------------
    
    l4_reg l4_reg_inst (
        .clk_i,
        .rst_i,
        .stall_l4_i(stall_l4), 
        .clear_l4_i(clear_l4), 
        .csr_data_i(csr_out_data),
        .l4_csr_data_o(l4_csr_out_data),
        .dmem_data_i(dmem_out_data),
        .l4_dmem_data_o(l4_dmem_out_data),
        .alu_out_i(l3_alu_out),
        .l4_alu_out_o(l4_alu_out),
        .lui_i(l3_lui),
        .l4_lui_o(l4_lui),
        .pc_addr_i(l3_pc_addr),
        .l4_pc_addr_o(l4_pc_addr),
        .reg_file_write_en_i(l3_reg_file_write_enable),
        .l4_reg_file_write_en_o(l4_reg_file_write_enable),
        .reg_file_rd_addr_i(l3_rd_addr),
        .l4_reg_file_rd_addr_o(l4_rd_addr),
        .reg_file_data_mux_sel_i(l3_sel_reg_file_data),
        .l4_reg_file_data_mux_sel_o(l4_sel_reg_file_data)
    );
    
    // Reg file -- common to ID & WB stages -------------------------------------------------------

    mux_reg_file_data mux_reg_file_data_inst (
        .sel_i(l4_sel_reg_file_data),
        .from_data_mem_i(l4_dmem_out_data),
        .from_ALU_i(l4_alu_out),
        .from_decoder_i(l4_lui),
        .from_pc_i(l4_pc_addr),
        .from_csr_i(l4_csr_out_data),
        .data_o(reg_file_rd_data)
    );


    RegFilev2 reg_file_inst (
        .clk_i,
        .rst_i,
        .stall_wb_i(stall_wb), 
        .stall_id_i(stall_id), 
        .read_en_i(reg_file_read_enable),
        .write_en_i(l4_reg_file_write_enable),
        .rs1_addr_i(rs1_addr),
        .rs2_addr_i(rs2_addr),
        .rd_addr_i(l4_rd_addr),
        .rd_data_i(reg_file_rd_data),
        .rs1_data_o(rs1_data),
        .rs2_data_o(rs2_data) 
    );

    
endmodule