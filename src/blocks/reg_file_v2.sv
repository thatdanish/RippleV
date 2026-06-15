`timescale 1ns/1ns
`default_nettype none

module reg_file_v2 (
    input clk_i,
    input rst_i,
    input en_i,
    input typed_pkg::rw_t rw_i,
    input logic[4:0] rs1_addr_i,
    input logic[4:0] rs2_addr_i,
    input logic[4:0] rd_addr_i,
    input logic[31:0] rd_data_i,
    output logic[31:0] rs1_data_o,
    output logic[31:0] rs2_data_o  
);

import typed_pkg::*;

logic [31:0] [31:0] int_regs;

always_ff @( posedge clk_i ) begin 
    if (!rst_i) begin
        rs1_data_o <= 'd0;
        rs2_data_o <= 'd0;
        int_regs <= 'd0;
    end else begin
        if (en_i == 1'b1) begin
            if (rw_i == write) begin // write
                if (rd_addr_i != 'd0) int_regs[rd_addr_i] <= rd_data_i;
                else int_regs <= int_regs;
            end else begin // read
                rs1_data_o <= int_regs[rs1_addr_i];
                rs2_data_o <= int_regs[rs2_addr_i];
            end
        end
    end
end

endmodule 