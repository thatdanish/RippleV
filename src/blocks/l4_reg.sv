// verilog_format: off
`timescale 1ns / 1ns
`default_nettype none
// verilog_format: on

module l4_reg (
    input                                        clk_i,
    input                                        rst_i,
    input                                        stall_l4_i,
    input                                        clear_l4_i,
    // CSR 
    input  logic                          [31:0] csr_data_i,
    output logic                          [31:0] l4_csr_data_o,
    // Data mem
    input  logic                          [31:0] dmem_data_i,
    output logic                          [31:0] l4_dmem_data_o,
    // ALU
    input  logic                          [31:0] alu_out_i,
    output logic                          [31:0] l4_alu_out_o,
    // Decoder
    input  logic                          [31:0] lui_i,
    output logic                          [31:0] l4_lui_o,
    // PC
    input  logic                          [31:0] pc_addr_i,
    output logic                          [31:0] l4_pc_addr_o,
    // Reg file
    input  typed_pkg::sel_reg_file_data_t        reg_file_data_mux_sel_i,
    output typed_pkg::sel_reg_file_data_t        l4_reg_file_data_mux_sel_o,
    input                                        reg_file_write_en_i,
    output                                       l4_reg_file_write_en_o,
    input  logic                          [ 4:0] reg_file_rd_addr_i,
    output logic                          [ 4:0] l4_reg_file_rd_addr_o
);
  import typed_pkg::*;

  logic       reg_file_write_en_1;
  logic [4:0] reg_file_rd_addr_1;
  logic [31:0] alu_out_1, lui_1, pc_addr_1;
  sel_reg_file_data_t reg_file_data_mux_sel_1;

  always_ff @(posedge clk_i) begin
    if (!rst_i) begin
      l4_csr_data_o              <= 'd0;
      l4_dmem_data_o             <= 'd0;
      l4_alu_out_o               <= 'd0;
      l4_lui_o                   <= 'd0;
      l4_pc_addr_o               <= 'd0;
      l4_reg_file_rd_addr_o      <= 'd0;
      l4_reg_file_write_en_o     <= 'd0;
      l4_reg_file_data_mux_sel_o <= sel_reg_file_data_t'('d0);

      reg_file_data_mux_sel_1    <= sel_reg_file_data_t'('d0);
      reg_file_write_en_1        <= 1'b0;
      reg_file_rd_addr_1         <= 'd0;
      alu_out_1                  <= 'd0;
      lui_1                      <= 'd0;
      pc_addr_1                  <= 'd0;

    end else begin
      if (clear_l4_i == 1'b1) begin
        l4_csr_data_o              <= 'd0;
        l4_dmem_data_o             <= 'd0;
        l4_alu_out_o               <= 'd0;
        l4_lui_o                   <= 'd0;
        l4_pc_addr_o               <= 'd0;
        l4_reg_file_rd_addr_o      <= 'd0;
        l4_reg_file_write_en_o     <= 'd0;
        l4_reg_file_data_mux_sel_o <= sel_reg_file_data_t'('d0);

        reg_file_data_mux_sel_1    <= sel_reg_file_data_t'('d0);
        reg_file_write_en_1        <= 1'b0;
        reg_file_rd_addr_1         <= 'd0;
        alu_out_1                  <= 'd0;
        lui_1                      <= 'd0;
        pc_addr_1                  <= 'd0;
      end else begin
        // Delay 1

        reg_file_data_mux_sel_1    <= reg_file_data_mux_sel_i;
        reg_file_write_en_1        <= reg_file_write_en_i;
        reg_file_rd_addr_1         <= reg_file_rd_addr_i;
        alu_out_1                  <= alu_out_i;
        lui_1                      <= lui_i;
        pc_addr_1                  <= pc_addr_i;

        l4_csr_data_o              <= (stall_l4_i == 1'b1) ? l4_csr_data_o : csr_data_i;
        l4_dmem_data_o             <= (stall_l4_i == 1'b1) ? l4_dmem_data_o : dmem_data_i;
        l4_alu_out_o               <= (stall_l4_i == 1'b1) ? l4_alu_out_o : alu_out_1;
        l4_lui_o                   <= (stall_l4_i == 1'b1) ? l4_lui_o : lui_1;
        l4_pc_addr_o               <= (stall_l4_i == 1'b1) ? l4_pc_addr_o : pc_addr_1;
        l4_reg_file_rd_addr_o      <= (stall_l4_i == 1'b1) ? l4_reg_file_rd_addr_o : reg_file_rd_addr_1;
        l4_reg_file_write_en_o     <= (stall_l4_i == 1'b1) ? l4_reg_file_write_en_o : reg_file_write_en_1;
        l4_reg_file_data_mux_sel_o <= (stall_l4_i == 1'b1) ? l4_reg_file_data_mux_sel_o : reg_file_data_mux_sel_1;
      end
    end
  end

endmodule
