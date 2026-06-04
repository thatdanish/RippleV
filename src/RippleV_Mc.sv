// 
//  Multi-Cycle RippleV Core. NOT PIPELINED.
// 

`timescale 1ns/1ns
`default_nettype none

module RippleV_Mc #( 
    parameter ADDR_WIDTH = 32,
    parameter MEM_SIZE = 32,
    parameter RST_HND = 4,
    parameter EXP_HND = 8,
    parameter INT_HND = 0
) (
    input clk_i,
    input rst_i,
    input ext_interrupt_i,
    input main_enable_i
);
    import CTRL_pkg::*;

    logic interrupt, housekeeper_enable, csr_rw, csr_enable, pc_enable, inst_mem_enable, reg_file_rw, reg_file_enable;
    logic take_branch, alu_enable, data_mem_enable, data_mem_rw;
    logic [1:0] housekeeper_task, transfer_type, sel_mux_pc, sel_mux_reg_file_addr, sel_mux_reg_file_data, sel_mux_alu_a, sel_mux_alu_b;
    logic [ADDR_WIDTH-1:0] handler_address, pc_update_from_alu, pc_update, pc_final;
    logic [2:0] csr_addr;
    logic [4:0] alu_operations, register_rs1, register_rs2, register_rd, final_register_addr;
    logic [5:0] ctrl_instruction;
    logic [31:0] csr_data, new_instruction, alu_output, reg_file_output, data_mem_output, immediate_offset, lui, final_register_data;
    logic [31:0] final_alu_a, final_alu_b;

    ctrl_unit ctrl_unit_inst (
        .clk_i,
        .rst_i,
        .main_enable_i, 
        .interrupt_i(interrupt),
        .instruction_i(ctrl_instruction),
        .pc_mux_sel_o(sel_mux_pc), 
        .pc_en_o(pc_enable), 
        .housekeeper_en_o(housekeeper_enable), 
        .housekeeper_task_o(housekeeper_task),
        .inst_mem_en_o(inst_mem_enable),
        .reg_file_addr_mux_sel_o(sel_mux_reg_file_addr),
        .reg_file_data_mux_sel_o(sel_mux_reg_file_data),
        .reg_file_rw_o(reg_file_rw),
        .reg_file_en_o(reg_file_enable),
        .take_branch_i(take_branch), 
        .alu_en_o(alu_enable), 
        .alu_opr_o(alu_operations),
        .alu_a_mux_sel_o(sel_mux_alu_a),
        .alu_b_mux_sel_o(sel_mux_alu_b),
        .data_mem_en_o(data_mem_enable),
        .data_mem_transfer_type_o(transfer_type)
        .data_mem_rw_o(data_mem_rw)
    );

    inst_mem #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) inst_mem_inst (
        .clk_i,
        .rst_i,
        .en_i(inst_mem_enable), 
        .addr_i(pc_final),
        .data_o(new_instruction)
    );

    data_mem #( 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) data_mem_inst (
        .clk_i,
        .rst_i,
        .en_i(data_mem_enable),
        .rw_i(data_mem_rw),
        .transfer_type_i(transfer_type)
        .addr_i(alu_output[ADDR_WIDTH-1:0]),
        .data_i(reg_file_output),    
        .data_o(data_mem_output)  
    );

    decoder decoder_inst (
        .clk_i,
        .rst_i,
        .inst_i(new_instruction),
        .rd_o(register_rd),
        .rs1_o(register_rs1),
        .rs2_o(register_rs2),
        .imm_offset_o(immediate_offset),
        .lui_o(lui),
        .inst_to_ctrl_o(ctrl_instruction) 
    );

    reg_file reg_file_inst (
        .clk_i,
        .rst_i,
        .en_i(reg_file_enable), 
        .rw_i(reg_file_rw),
        .addr_i(final_register_addr),
        .data_i(final_register_data),
        .data_o(reg_file_output)
    );
    
    temp_alu temp_alu_inst (
        .clk_i,
        .rst_i,
        .en_i(alu_enable),
        .opr_i(alu_operations),
        .a_i(final_alu_a), 
        .b_i(final_alu_b),
        .out_o(alu_output),
        .take_branch_o(take_branch)
    );

    housekeeper #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .RST_HND(RST_HND), 
        .EXP_HND(EXP_HND), 
        .INT_HND(INT_HND)
    ) housekeeper_inst (
        .clk_i,
        .rst_i,
        .en_i(housekeeper_enable),
        .task_i(housekeeper_task),
        .csr_en_o(csr_enable),
        .csr_rw_o(csr_rw),
        .csr_addr_o(csr_addr),
        .handler_addr_o(handler_address)
    );

    csr # ( 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) csr_inst (
        .clk_i,
        .rst_i,
        .ext_interrupt_i,
        .rw_i(csr_rw),
        .en_i(csr_enable),
        .csr_addr_i(csr_addr),
        .new_data_i(pc_final),
        .interrupt_status_o(interrupt),
        .csr_data_o(csr_data)
    );

    program_counter #( 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) program_counter_inst (
        .clk_i,
        .rst_i,
        .en_i(pc_enable),
        .pc_update_i(pc_update),
        .pc_o(pc_final)
    );

    mux_pc #( 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mux_pc_inst (
        .sel_i(sel_mux_pc),
        .pc_update_i(pc_update_from_alu),
        .mret_i(csr_data[ADDR_WIDTH-1:0]), 
        .handler_addr_i(handler_address),
        .data_o(pc_update)
    );

    mux_reg_file_addr muc_reg_file_addr_inst (
        .sel_i(sel_mux_reg_file_addr),
        .rs1_i(register_rs1),
        .rs2_i(register_rs2),
        .rd_i(register_rd),
        .addr_reg_o(final_register_addr)
    );

    mux_reg_file_data mux_reg_file_data_inst (
        .sel_i(sel_mux_reg_file_addr), 
        .from_data_mem_i(data_mem_output), 
        .from_ALU_i(alu_output), 
        .from_decoder_i(lui), 
        .from_pc_i(32'(pc_final)), 
        .data_o(final_register_data)
    );

    mux_alu_a mux_alu_a_inst (
        .clk_i,
        .sel_i(sel_mux_alu_a), 
        .const_4_i(32'd4), 
        .sign_ext_offset_i(immediate_offset), 
        .lui_i(lui), 
        .rs2_i(reg_file_output), 
        .data_o(final_alu_a)
    );

    mux_alu_b mux_alu_b_inst (
        .sel_i(sel_mux_alu_b), 
        .pc_i(32'(pc_final)), 
        .rs1_i(reg_file_output),  
        .data_o(final_alu_b)
    );


// Coverage

cover property (@ (posedge clk_i) ctrl_instruction == CTRL_ADDI); 
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SLTI);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SLTIU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_ANDI);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_ORI);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_XORI);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SLLI);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SRLI);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SRAI);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_LUI);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_AUIPC);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_ADD);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SUB);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SLTU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SLT);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_AND);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_OR);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_XOR);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SLL);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SRL);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SRA);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_JAL);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_JALR);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_BEQ);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_BNE);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_BGE);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_BLT);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_BLTU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_BGEU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_LW);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_LH);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_LHU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_LB);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_LBU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SW);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SH);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_SB);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_MUL);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_MULH);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_MULHU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_MULHSU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_DIV);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_DIVU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_REM);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_REMU);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_MRET);
cover property (@(posedge clk_i) ctrl_instruction == CTRL_WFI);

endmodule
