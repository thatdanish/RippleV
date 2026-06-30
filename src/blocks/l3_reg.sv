`timescale 1ns/1ns
`default_nettype none

module l3_reg (
    input clk_i,
    input rst_i,
    input stall_l3_i, 
    input clear_l3_i, 
    // Decoder
    input logic [31:0] lui_i,
    output logic [31:0] l3_lui_o,
    // ALU
    input logic [31:0] alu_out_i,
    output logic [31:0] l3_alu_out_o,
    // DMEM
    input dmem_en_i,
    input typed_pkg::rw_t data_mem_rw_i,
    input typed_pkg::transfer_t data_mem_transfer_type_i,
    input typed_pkg::load_t data_mem_load_type_i,
    input logic [31:0] data_mem_addr_i,
    input logic [31:0] data_mem_data_i,
    output logic l3_dmem_en_o,
    output typed_pkg::rw_t  l3_data_mem_rw_o,
    output typed_pkg::transfer_t l3_data_mem_transfer_type_o,
    output typed_pkg::load_t l3_data_mem_load_type_o,
    output logic [31:0] l3_data_mem_addr_o,
    output logic [31:0] l3_data_mem_data_o,
    // CSR Mux
    input typed_pkg::sel_csr_addr_t sel_mux_csr_addr_i,
    input typed_pkg::sel_csr_data_t sel_mux_csr_data_i,
    input typed_pkg::csr_addr_t csr_addr_from_cu_i,
    input typed_pkg::csr_addr_t csr_addr_from_decoder_i,
    input logic [31:0] csr_pc_i,
    input logic [31:0] csr_uimm_i,
    input logic [31:0] csr_rs1_i,
    input logic [31:0] csr_data_from_ctrl_unit_i,
    output typed_pkg::sel_csr_addr_t l3_sel_mux_csr_addr_o,
    output typed_pkg::sel_csr_data_t l3_sel_mux_csr_data_o,
    output typed_pkg::csr_addr_t l3_csr_addr_from_cu_o,
    output typed_pkg::csr_addr_t l3_csr_addr_from_decoder_o,
    output logic [31:0] l3_csr_pc_o,
    output logic [31:0] l3_csr_uimm_o,
    output logic [31:0] l3_csr_rs1_o,
    output logic [31:0] l3_csr_data_from_ctrl_unit_o,
    // CSR
    input typed_pkg::write_t csr_write_type_i,
    input typed_pkg::rw_t csr_rw_i,
    input csr_en_i,
    output typed_pkg::write_t l3_csr_write_type_o,
    output typed_pkg::rw_t l3_csr_rw_o,
    output logic l3_csr_en_o,
    // Reg file v2
    input reg_file_write_en_i,
    input [4:0] reg_file_rd_addr_i, 
    input typed_pkg::sel_reg_file_data_t reg_file_data_mux_sel_i, 
    output typed_pkg::sel_reg_file_data_t l3_reg_file_data_mux_sel_o,
    output l3_reg_file_write_en_o,
    output [4:0] l3_reg_file_rd_addr_o
);
    import typed_pkg::*;
    
    logic dmem_en_1, csr_en_1, reg_file_write_en_1;
    logic [4:0] reg_file_rd_addr_1;
    logic [31:0] lui_1, data_mem_data_1, csr_pc_1, csr_uimm_1, csr_rs1_1, csr_data_from_ctrl_unit_1;
    rw_t data_mem_rw_1, csr_rw_1;
    transfer_t data_mem_transfer_type_1;
    load_t data_mem_load_type_1;
    sel_csr_addr_t sel_mux_csr_addr_1;
    sel_csr_data_t sel_mux_csr_data_1;
    csr_addr_t csr_addr_from_cu_1;
    csr_addr_t csr_addr_from_decoder_1;
    write_t csr_write_type_1;
    sel_reg_file_data_t reg_file_data_mux_sel_1;

    always_ff @( posedge clk_i ) begin
        if ( !rst_i ) begin
            l3_alu_out_o <= 'd0;
            l3_lui_o <= 'd0;
            l3_alu_out_o <= 'd0;
            l3_dmem_en_o <= 'd0;
            l3_data_mem_rw_o <= rw_t'('d0);
            l3_data_mem_transfer_type_o <= transfer_t'('d0);
            l3_data_mem_load_type_o <= load_t'('d0);
            l3_data_mem_addr_o <= 'd0;
            l3_data_mem_data_o <= 'd0;
            l3_sel_mux_csr_addr_o <= sel_csr_addr_t'('d0);
            l3_sel_mux_csr_data_o <= sel_csr_data_t'('d0);
            l3_csr_addr_from_cu_o <= csr_addr_t'('d0);
            l3_csr_addr_from_decoder_o <= csr_addr_t'('d0);
            l3_csr_pc_o <= 'd0;
            l3_csr_uimm_o <= 'd0;
            l3_csr_rs1_o <= 'd0;
            l3_csr_data_from_ctrl_unit_o <= 'd0;
            l3_csr_write_type_o <= write_t'('d0);
            l3_csr_rw_o <= rw_t'('d0);
            l3_csr_en_o <= 'd0;
            l3_reg_file_write_en_o <= 'd0;
            l3_reg_file_rd_addr_o <= 'd0;
            l3_reg_file_data_mux_sel_o <= sel_reg_file_data_t'('d0);
        end else begin
            
            // Delay - I

            lui_1 <= lui_i;
            dmem_en_1 <= dmem_en_i;
            data_mem_rw_1 <= data_mem_rw_i;
            data_mem_transfer_type_1 <= data_mem_transfer_type_i;
            data_mem_load_type_1 <= data_mem_load_type_i;
            data_mem_data_1 <= data_mem_data_i;
            sel_mux_csr_addr_1 <= sel_mux_csr_addr_i;
            sel_mux_csr_data_1 <= sel_mux_csr_data_i;
            csr_addr_from_cu_1 <= csr_addr_from_cu_i;
            csr_addr_from_decoder_1 <= csr_addr_from_decoder_i;
            csr_pc_1 <= csr_pc_i;
            csr_uimm_1 <= csr_uimm_i;
            csr_rs1_1 <= csr_rs1_i;
            csr_data_from_ctrl_unit_1 <= csr_data_from_ctrl_unit_i;
            csr_write_type_1 <= csr_write_type_i;
            csr_rw_1 <= csr_rw_i;
            csr_en_1 <= csr_en_i;
            reg_file_write_en_1 <= reg_file_write_en_i;
            reg_file_rd_addr_1 <= reg_file_rd_addr_i;
            reg_file_data_mux_sel_1 <= reg_file_data_mux_sel_i;


            if ( clear_l3_i == 1'b1 ) begin 
                l3_alu_out_o <= 'd0;
                l3_lui_o <= 'd0;
                l3_dmem_en_o <= 'd0;
                l3_data_mem_rw_o <= rw_t'('d0);
                l3_data_mem_transfer_type_o <= transfer_t'('d0);
                l3_data_mem_load_type_o <= load_t'('d0);
                l3_data_mem_addr_o <= 'd0;
                l3_data_mem_data_o <= 'd0;
                l3_sel_mux_csr_addr_o <= sel_csr_addr_t'('d0);
                l3_sel_mux_csr_data_o <= sel_csr_data_t'('d0);
                l3_csr_addr_from_cu_o <= csr_addr_t'('d0);
                l3_csr_addr_from_decoder_o <= csr_addr_t'('d0);
                l3_csr_pc_o <= 'd0;
                l3_csr_uimm_o <= 'd0;
                l3_csr_rs1_o <= 'd0;
                l3_csr_data_from_ctrl_unit_o <= 'd0;
                l3_csr_write_type_o <= write_t'('d0);
                l3_csr_rw_o <= rw_t'('d0);
                l3_csr_en_o <= 'd0;
                l3_reg_file_write_en_o <= 'd0;
                l3_reg_file_rd_addr_o <= 'd0;
                l3_reg_file_data_mux_sel_o <= sel_reg_file_data_t'('d0);
            end
            else begin
                l3_lui_o <= ( stall_l3_i == 1'b1 ) ? l3_lui_o : lui_1; 
                l3_alu_out_o <= ( stall_l3_i == 1'b1 ) ? l3_alu_out_o : alu_out_i; 
                l3_dmem_en_o <= (stall_l3_i == 1'b1 ) ? l3_dmem_en_o : dmem_en_1;
                l3_data_mem_rw_o <= (stall_l3_i == 1'b1 ) ? l3_data_mem_rw_o : data_mem_rw_1;
                l3_data_mem_transfer_type_o <= (stall_l3_i == 1'b1 ) ? l3_data_mem_transfer_type_o : data_mem_transfer_type_1;
                l3_data_mem_load_type_o <= (stall_l3_i == 1'b1 ) ? l3_data_mem_load_type_o : data_mem_load_type_1;
                l3_data_mem_addr_o <= (stall_l3_i == 1'b1 ) ? l3_data_mem_addr_o : data_mem_addr_i;
                l3_data_mem_data_o <= (stall_l3_i == 1'b1 ) ? l3_data_mem_data_o : data_mem_data_1;
                l3_sel_mux_csr_addr_o <= (stall_l3_i == 1'b1 ) ? l3_sel_mux_csr_addr_o : sel_mux_csr_addr_1;
                l3_sel_mux_csr_data_o <= (stall_l3_i == 1'b1 ) ? l3_sel_mux_csr_data_o : sel_mux_csr_data_1;
                l3_csr_addr_from_cu_o <= (stall_l3_i == 1'b1 ) ? l3_csr_addr_from_cu_o : csr_addr_from_cu_1;
                l3_csr_addr_from_decoder_o <= (stall_l3_i == 1'b1 ) ? l3_csr_addr_from_decoder_o : csr_addr_from_decoder_1;
                l3_csr_pc_o <= (stall_l3_i == 1'b1 ) ? l3_csr_pc_o : csr_pc_1;
                l3_csr_uimm_o <= (stall_l3_i == 1'b1 ) ? l3_csr_uimm_o : csr_uimm_1;
                l3_csr_rs1_o <= (stall_l3_i == 1'b1 ) ? l3_csr_rs1_o : csr_rs1_1;
                l3_csr_data_from_ctrl_unit_o <= (stall_l3_i == 1'b1 ) ? l3_csr_data_from_ctrl_unit_o : csr_data_from_ctrl_unit_1;
                l3_csr_write_type_o <= (stall_l3_i == 1'b1 ) ? l3_csr_write_type_o : csr_write_type_1;
                l3_csr_rw_o <= (stall_l3_i == 1'b1 ) ? l3_csr_rw_o : csr_rw_1;
                l3_csr_en_o <= (stall_l3_i == 1'b1 ) ? l3_csr_en_o : csr_en_1;
                l3_reg_file_write_en_o <= (stall_l3_i == 1'b1 ) ? l3_reg_file_write_en_o : reg_file_write_en_1;
                l3_reg_file_rd_addr_o <= (stall_l3_i == 1'b1 ) ? l3_reg_file_rd_addr_o : reg_file_rd_addr_1;
                l3_reg_file_data_mux_sel_o <= (stall_l3_i == 1'b1 ) ? l3_reg_file_data_mux_sel_o : reg_file_data_mux_sel_1;
            end
        end
    end

endmodule