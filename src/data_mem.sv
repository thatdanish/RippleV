`timescale 1ns/1ns
`default_nettype none

module data_mem #( 
    parameter ADDR_WIDTH = 5
) (
    input clk_i,
    input rst_i,
    input en_i,
    input rw_i,
    input logic [ADDR_WIDTH-1:0] addr_i,
    input logic [31:0] data_i    
    output logic [31:0] data_o    
);
import Opcodes_pkg::read;
import Opcodes_pkg::write;

logic [31:0] int_data_mem[logic[ADDR_WIDTH-1:0]];

always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        data_o <= 'd0
    end else begin
        if (en_i == 1'b1) begin
            if (rw_i == read) data_o <= int_data_mem[addr_i];
            else int_data_mem[addr_i] <= data_i
        end else data_o <= 'd0;
    end    
end
    
endmodule
