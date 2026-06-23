`timescale 1ns/1ns
`default_nettype none

module l3_reg (
    input clk_i,
    input rst_i,
    input stall_l3_i, 
    input clear_l3_i, 
    // ALU
    input logic [31:0] alu_out_i,
    output logic [31:0] l3_alu_out_o
);
    
    always_ff @( posedge clk_i ) begin
        if ( !rst ) begin
            l3_alu_out_o <= 'd0;
        end else begin
            if ( clear_l3_i == 1'b1 ) l3_alu_out_o <= 'd0;
            else l3_alu_out_o <= ( stall_l3_i == 1'b1 ) ? l3_alu_out_o : alu_out_i; 
        end
    end

endmodule