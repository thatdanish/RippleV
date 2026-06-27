`timescale 1ns/1ns
`default_nettype none

module l4_reg (
    input clk_i,
    input rst_i,
    input stall_l4_i, 
    input clear_l4_i, 
    // CSR 
    input logic [31:0] csr_data_i,
    output logic [31:0] l4_csr_data_o,
    // Data mem
    input logic [31:0] dmem_data_i,
    output logic [31:0] l4_dmem_data_o,
    // ALU
    input logic [31:0] alu_out_i,
    output logic [31:0] l4_alu_out_o,
    // Decoder
    input logic [31:0] lui_i,
    output logic [31:0] l4_lui_o,
    // PC
    input logic [31:0] pc_addr_i,
    output logic [31:0] l4_pc_addr_o,
    // Reg file
    input reg_file_write_en_i
    input logic [31:0] reg_file_data_mux_sel_i,
    input logic [31:0] reg_file_rd_addr_i,
    output logic [31:0] l4_reg_file_rd_addr_o,
    output l4_reg_file_write_en_o,
    output logic [31:0] l4_reg_file_data_mux_sel_o
);

    always_ff @( posedge clk_i ) begin
        if (!rst_i) begin
            l4_csr_data_o <= 'd0;
            l4_dmem_data_o <= 'd0;
            l4_alu_out_o    <= 'd0;
            l4_lui_o    <= 'd0;
            l4_pc_addr_o    <= 'd0;
            l4_reg_file_rd_addr_o   <= 'd0;
            l4_reg_file_write_en_o  <= 'd0;
            l4_reg_file_data_mux_sel_o  <= 'd0;
        end else begin
            if ( clear_l4_i == 1'b1 ) begin
                l4_csr_data_o <= 'd0;
                l4_dmem_data_o <= 'd0;
                l4_alu_out_o    <= 'd0;
                l4_lui_o    <= 'd0;
                l4_pc_addr_o    <= 'd0;
                l4_reg_file_rd_addr_o   <= 'd0;
                l4_reg_file_write_en_o  <= 'd0;
                l4_reg_file_data_mux_sel_o  <= 'd0;
            end else begin
                l4_csr_data_o <= ( stall_l4_i == 1'b1 ) ? l4_csr_data_o : csr_data_i;
                l4_dmem_data_o <= ( stall_l4_i == 1'b1 ) ? l4_dmem_data_o : dmem_data_i;
                l4_alu_out_o    <= ( stall_l4 == 1'b1 ) ? l4_alu_out_o : alu_out_i;
                l4_lui_o    <= ( stall_l4 == 1'b1 ) ? l4_lui_o : lui_i;
                l4_pc_addr_o    <= ( stall_l4 == 1'b1 ) ? l4_pc_addr_o : pc_addr_i;
                l4_reg_file_rd_addr_o   <= ( stall_l4 == 1'b1 ) ? l4_reg_file_rd_addr_o : reg_file_rd_addr_i;
                l4_reg_file_write_en_o  <= ( stall_l4 == 1'b1 ) ? l4_reg_file_write_en_o : reg_file_write_en_i;
                l4_reg_file_data_mux_sel_o  <= ( stall_l4 == 1'b1 ) ? l4_reg_file_data_mux_sel_o : reg_file_data_mux_sel_i;
            end
        end
    end
    
endmodule