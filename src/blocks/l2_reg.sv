`timescale 1ns/1ns
`default_nettype none

module l2_reg (
    input clk_i,
    input rst_i,
    input clear_l2_i, 
    input stall_l2_i, 
    // PC 
    input logic [31:0] pc_i,
    output logic [31:0] l2_pc_out_o, 
    // Decoder v2
    input logic [4:0] rs1_i, 
    input logic [4:0] rs2_i, 
    input logic [4:0] rd_i, 
    input logic [31:0] imm_offset_i, 
    input logic [31:0] lui_i, 
    input typed_pkg::csr_addr_t csr_addr_i, 
    output logic [4:0] l2_rs1_o, 
    output logic [4:0] l2_rs2_o, 
    output logic [4:0] l2_rd_o, 
    output logic [31:0] l2_imm_offset_o, 
    output logic [31:0] l2_lui_o, 
    output typed_pkg::csr_addr_t l2_csr_addr_o, 
    // Control unit v2
    input typed_pkg::csr_addr_t csr_addr_from_ctrl_i, 
    input typed_pkg::sel_csr_addr_t csr_addr_mux_sel_i, 
    input typed_pkg::sel_csr_data_t csr_data_mux_sel_i, 
    input typed_pkg::write_t csr_write_type_i, 
    input typed_pkg::rw_t csr_rw_i, 
    input logic csr_en_i, 
    input logic [31:0] csr_data_from_ctrl_i, 
    input typed_pkg::sel_reg_file_data_t reg_file_data_mux_sel_i,
    input typed_pkg::alu_opr_t alu_opr_i,
    input typed_pkg::sel_alu_a_t alu_a_mux_sel_i,
    input typed_pkg::sel_alu_b_t alu_b_mux_sel_i,
    input logic alu_en_i, 
    input typed_pkg::alu_opr_t bl_opr_i,
    input logic branch_logic_en_i,
    input typed_pkg::transfer_t data_mem_transfer_type_i,
    input typed_pkg::rw_t data_mem_rw_i,
    input typed_pkg::load_t data_mem_load_type_i, 
    input logic data_mem_en_i,
    output typed_pkg::csr_addr_t l2_csr_addr_from_ctrl_o, 
    output typed_pkg::sel_csr_addr_t l2_csr_addr_mux_sel_o, 
    output typed_pkg::sel_csr_data_t l2_csr_data_mux_sel_o, 
    output typed_pkg::write_t l2_csr_write_type_o, 
    output typed_pkg::rw_t l2_csr_rw_o, 
    output logic l2_csr_en_o, 
    output logic [31:0] l2_csr_data_from_ctrl_o, 
    output typed_pkg::sel_reg_file_data_t l2_reg_file_data_mux_sel_o,
    output typed_pkg::alu_opr_t l2_alu_opr_o,
    output typed_pkg::sel_alu_a_t l2_alu_a_mux_sel_o,
    output typed_pkg::sel_alu_b_t l2_alu_b_mux_sel_o,
    output logic l2_alu_en_o, 
    output typed_pkg::alu_opr_t l2_bl_opr_o,
    output logic l2_branch_logic_en_o,
    output typed_pkg::transfer_t l2_data_mem_transfer_type_o,
    output typed_pkg::rw_t l2_data_mem_rw_o,
    output typed_pkg::load_t l2_data_mem_load_type_o, 
    output logic l2_data_mem_en_o,
    // Reg file v2
    input reg_file_read_en_i,
    input reg_file_write_en_i,
    input logic[31:0] rs1_data_i,
    input logic[31:0] rs2_data_i,
    output logic[31:0] l2_rs1_data_o,
    output logic[31:0] l2_rs2_data_o, 
    output l2_reg_file_write_en_o
);

    import typed_pkg::*;

    logic csr_en_1, reg_file_read_en_1, reg_file_write_en_1, alu_en_1, branch_logic_en_1, data_mem_en_1;
    logic [31:0] pc_1, imm_offset_1, lui_1, csr_data_from_ctrl_1, pc_2, imm_offset_2, lui_2, pc_3, imm_offset_3, lui_3;
    logic [31:0] pc_4;
    logic [4:0] rs1_1, rs2_1, rd_1, rs1_2, rs2_2, rd_2, rs1_3, rs2_3, rd_3;
    csr_addr_t csr_addr_1, csr_addr_from_ctrl_1, csr_addr_2, csr_addr_3;
    sel_csr_addr_t csr_addr_mux_sel_1;
    sel_csr_data_t csr_data_mux_sel_1;
    write_t csr_write_type_1;
    rw_t csr_rw_1, data_mem_rw_1;
    sel_reg_file_data_t reg_file_data_mux_sel_1;
    alu_opr_t alu_opr_1, bl_opr_1;
    sel_alu_a_t alu_a_mux_sel_1;
    sel_alu_b_t alu_b_mux_sel_1;
    transfer_t data_mem_transfer_type_1;
    load_t data_mem_load_type_1;

    always_ff @( posedge clk_i ) begin 
        if (!rst_i) begin
            l2_pc_out_o <= 'd0;
            l2_rs1_o <= 'd0; 
            l2_rs2_o <= 'd0; 
            l2_rd_o <= 'd0; 
            l2_imm_offset_o <= 'd0; 
            l2_lui_o <= 'd0; 
            l2_csr_addr_o <= csr_addr_t'('d0); 
            l2_csr_addr_from_ctrl_o <= csr_addr_t'('d0);
            l2_csr_addr_mux_sel_o <= sel_csr_addr_t'('d0); 
            l2_csr_data_mux_sel_o <= sel_csr_data_t'('d0); 
            l2_csr_write_type_o <= write_t'('d0); 
            l2_csr_rw_o <= rw_t'('d0); 
            l2_csr_en_o <= 'd0; 
            l2_csr_data_from_ctrl_o <= 'd0; 
            l2_reg_file_data_mux_sel_o <= sel_reg_file_data_t'('d0);
    
            l2_reg_file_write_en_o <= 'd0;
            l2_alu_opr_o <= alu_opr_t'('d0);
            l2_alu_a_mux_sel_o <= sel_alu_a_t'('d0);;
            l2_alu_b_mux_sel_o <= sel_alu_b_t'('d0);;
            l2_alu_en_o <= 'd0; 
            l2_bl_opr_o <= alu_opr_t'('d0);
            l2_branch_logic_en_o <= 'd0;
            l2_data_mem_transfer_type_o <= transfer_t'('d0);
            l2_data_mem_rw_o <= rw_t'('d0);
            l2_data_mem_load_type_o <= load_t'('d0); 
            l2_data_mem_en_o <= 'd0;
            l2_rs1_data_o <= 'd0;
            l2_rs2_data_o <= 'd0; 
        end else begin
            
            // Delay I -  CU, Decoder & PC
            pc_1 <= pc_i;
            rs1_1 <= rs1_i;
            rs2_1 <= rs2_i;
            rd_1 <= rd_i;
            imm_offset_1 <= imm_offset_i;
            lui_1 <= lui_i;
            csr_addr_1 <= csr_addr_i;
            csr_addr_from_ctrl_1 <= csr_addr_from_ctrl_i;
            csr_addr_mux_sel_1 <= csr_addr_mux_sel_i;
            csr_data_mux_sel_1 <= csr_data_mux_sel_i;
            csr_write_type_1 <= csr_write_type_i;
            csr_rw_1 <= csr_rw_i;
            csr_en_1 <= csr_en_i;
            csr_data_from_ctrl_1 <= csr_data_from_ctrl_i;
            reg_file_data_mux_sel_1 <= reg_file_data_mux_sel_i;
            reg_file_read_en_1 <= reg_file_read_en_i;
            reg_file_write_en_1 <= reg_file_write_en_i;
            alu_opr_1 <= alu_opr_i;
            alu_a_mux_sel_1 <= alu_a_mux_sel_i;
            alu_b_mux_sel_1 <= alu_b_mux_sel_i;
            alu_en_1 <= alu_en_i;
            bl_opr_1 <= bl_opr_i;
            branch_logic_en_1 <= branch_logic_en_i;
            data_mem_transfer_type_1 <= data_mem_transfer_type_i;
            data_mem_rw_1 <= data_mem_rw_i;
            data_mem_load_type_1 <= data_mem_load_type_i;
            data_mem_en_1 <= data_mem_en_i;

            // Delay II - Decoder & PC
            pc_2 <= pc_1;
            rs1_2 <= rs1_1;
            rs2_2 <= rs2_1;
            rd_2 <= rd_1;
            imm_offset_2 <= imm_offset_1;
            lui_2 <= lui_1;
            csr_addr_2 <= csr_addr_1;

            // Delay III - Decoder & PC 
            pc_3 <= pc_2;
            rs1_3 <= rs1_2;
            rs2_3 <= rs2_2;
            rd_3 <= rd_2;
            imm_offset_3 <= imm_offset_2;
            lui_3 <= lui_2;
            csr_addr_3 <= csr_addr_2;

            // Delay IV - PC
            pc_4 <= pc_3;

            if ( clear_l2_i == 1'b1 ) begin
                l2_pc_out_o <= 'd0;
                l2_rs1_o <= 'd0; 
                l2_rs2_o <= 'd0; 
                l2_rd_o <= 'd0; 
                l2_imm_offset_o <= 'd0; 
                l2_lui_o <= 'd0; 
                l2_csr_addr_o <= csr_addr_t'('d0); 
                l2_csr_addr_from_ctrl_o <= csr_addr_t'('d0);
                l2_csr_addr_mux_sel_o <= sel_csr_addr_t'('d0); 
                l2_csr_data_mux_sel_o <= sel_csr_data_t'('d0); 
                l2_csr_write_type_o <= write_t'('d0); 
                l2_csr_rw_o <= rw_t'('d0); 
                l2_csr_en_o <= 'd0; 
                l2_csr_data_from_ctrl_o <= 'd0; 
                l2_reg_file_data_mux_sel_o <= sel_reg_file_data_t'('d0);
        
                l2_reg_file_write_en_o <= 'd0;
                l2_alu_opr_o <= alu_opr_t'('d0);
                l2_alu_a_mux_sel_o <= sel_alu_a_t'('d0);;
                l2_alu_b_mux_sel_o <= sel_alu_b_t'('d0);;
                l2_alu_en_o <= 'd0; 
                l2_bl_opr_o <= alu_opr_t'('d0);
                l2_branch_logic_en_o <= 'd0;
                l2_data_mem_transfer_type_o <= transfer_t'('d0);
                l2_data_mem_rw_o <= rw_t'('d0);
                l2_data_mem_load_type_o <= load_t'('d0); 
                l2_data_mem_en_o <= 'd0;
                l2_rs1_data_o <= 'd0;
                l2_rs2_data_o <= 'd0;            
            end else begin
                l2_pc_out_o <= ( stall_l2_i == 1'b1 ) ? l2_pc_out_o : pc_4;
                l2_rs1_o <= ( stall_l2_i == 1'b1 ) ? l2_rs1_o : rs1_3;
                l2_rs2_o <= ( stall_l2_i == 1'b1 ) ? l2_rs2_o : rs2_3;
                l2_rd_o <= ( stall_l2_i == 1'b1 ) ? l2_rd_o : rd_3;
                l2_imm_offset_o <= ( stall_l2_i == 1'b1 ) ? l2_imm_offset_o : imm_offset_3;
                l2_lui_o <= ( stall_l2_i == 1'b1 ) ? l2_lui_o : lui_3;
                l2_csr_addr_o <= ( stall_l2_i == 1'b1 ) ? l2_csr_addr_o : csr_addr_3;
                l2_csr_addr_from_ctrl_o <= ( stall_l2_i == 1'b1 ) ? l2_csr_addr_from_ctrl_o : csr_addr_from_ctrl_1; 
                l2_csr_addr_mux_sel_o <= ( stall_l2_i == 1'b1 ) ? l2_csr_addr_mux_sel_o : csr_addr_mux_sel_1; 
                l2_csr_data_mux_sel_o <= ( stall_l2_i == 1'b1 ) ? l2_csr_data_mux_sel_o : csr_data_mux_sel_1; 
                l2_csr_write_type_o <= ( stall_l2_i == 1'b1 ) ? l2_csr_write_type_o : csr_write_type_1; 
                l2_csr_rw_o <= ( stall_l2_i == 1'b1 ) ? l2_csr_rw_o : csr_rw_1; 
                l2_csr_en_o <= ( stall_l2_i == 1'b1 ) ? l2_csr_en_o : csr_en_1; 
                l2_csr_data_from_ctrl_o <= ( stall_l2_i == 1'b1 ) ? l2_csr_data_from_ctrl_o : csr_data_from_ctrl_1; 
                l2_reg_file_data_mux_sel_o <= ( stall_l2_i == 1'b1 ) ? l2_reg_file_data_mux_sel_o  : reg_file_data_mux_sel_1;
        
                l2_reg_file_write_en_o <= ( stall_l2_i == 1'b1 ) ? l2_reg_file_write_en_o  : reg_file_write_en_1;
                l2_alu_opr_o <= ( stall_l2_i == 1'b1 ) ? l2_alu_opr_o  : alu_opr_1;
                l2_alu_a_mux_sel_o <= ( stall_l2_i == 1'b1 ) ? l2_alu_a_mux_sel_o  : alu_a_mux_sel_1;
                l2_alu_b_mux_sel_o <= ( stall_l2_i == 1'b1 ) ? l2_alu_b_mux_sel_o  : alu_b_mux_sel_1;
                l2_alu_en_o <= ( stall_l2_i == 1'b1 ) ? l2_alu_en_o : alu_en_1; 
                l2_bl_opr_o <= ( stall_l2_i == 1'b1 ) ? l2_bl_opr_o  : bl_opr_1;
                l2_branch_logic_en_o <= ( stall_l2_i == 1'b1 ) ? l2_branch_logic_en_o  : branch_logic_en_1;
                l2_data_mem_transfer_type_o <= ( stall_l2_i == 1'b1 ) ? l2_data_mem_transfer_type_o  : data_mem_transfer_type_1;
                l2_data_mem_rw_o <= ( stall_l2_i == 1'b1 ) ? l2_data_mem_rw_o  : data_mem_rw_1;
                l2_data_mem_load_type_o <= ( stall_l2_i == 1'b1 ) ? l2_data_mem_load_type_o : data_mem_load_type_1; 
                l2_data_mem_en_o <= ( stall_l2_i == 1'b1 ) ? l2_data_mem_en_o  : data_mem_en_1;
                l2_rs1_data_o <= ( stall_l2_i == 1'b1 ) ? l2_rs1_data_o  : rs1_data_i;
                l2_rs2_data_o <= ( stall_l2_i == 1'b1 ) ? l2_rs2_data_o : rs2_data_i; 
            end
        end
    end
    
endmodule