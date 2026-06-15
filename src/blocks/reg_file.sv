`timescale 1ns/1ns
`default_nettype none

module reg_file(
    input clk_i,
    input rst_i,
    input en_i, 
    input typed_pkg::rw_t rw_i,
    input logic [4:0] addr_i,
    input logic [31:0] data_i,
    output logic [31:0] data_o
);

import typed_pkg::*;

logic [31:0] [31:0] int_regs;

always_ff @( posedge clk_i ) begin 
    if (!rst_i) begin
        data_o <= 'd0;
        int_regs <= 'd0;
    end else begin
        if (en_i == 1'b1) begin
            if (rw_i == write) begin // write
                if (addr_i != 'd0) int_regs[addr_i] <= data_i;
                else int_regs <= int_regs;
            end else begin // read
                data_o <= int_regs[addr_i];
            end
        end
    end
end

endmodule