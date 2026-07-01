`timescale 1ns/1ns
`default_nettype none

module ProgramCounterv2 #(
    parameter ADDR_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] RST_HND = 0
    ) (
    input clk_i,
    input rst_i,
    input en_i,
    input stall_if_i, 
    input logic [ADDR_WIDTH-1:0] pc_update_i,
    output logic [ADDR_WIDTH-1:0] pc_o   
);
    

always_ff @( posedge clk_i ) begin 
    if (!rst_i) pc_o <= RST_HND;
    else begin 
        if ( en_i == 1'b1 && stall_if_i == 1'b0 )
            pc_o <= pc_update_i;
        else 
            pc_o <= pc_o;
    end
end
endmodule