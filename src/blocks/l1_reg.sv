`timescale 1ns/1ns
`default_nettype none

module l1_reg (
    input clk_i,
    input rst_i,
    input clear_l1_i, 
    input stall_l1_i, 
    // Instruction mem
    input logic [31:0] imem_inst_i,
    output logic [31:0] l1_imem_inst_o
);

    always_ff @( posedge clk_i ) begin 
        if (!rst_i) begin
            l1_imem_inst_o <= 'd0;
        end else begin
            if ( clear_l1_i == 1'b1 ) l1_imem_inst_o <= 'd0;
            else l1_imem_inst_o <= ( stall_l1_i == 1'b1 ) ? l1_imem_inst_o : imem_inst_i;
        end
    end
    
endmodule