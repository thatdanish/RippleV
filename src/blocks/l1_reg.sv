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
    // PC
    input logic [31:0] pc_i,
    output logic [31:0] l1_pc_out_o
);

    always_ff @( posedge clk_i ) begin 
        if (!rst_i) begin
            l1_imem_inst_o <= 'd0;
        end else begin
            if ( clear_l1_i == 1'b1 ) begin
                l1_imem_inst_o <= 'd0;
                l1_pc_out <= 'd0;
            end
            else begin
                l1_imem_inst_o <= ( stall_l1_i == 1'b1 ) ? l1_imem_inst_o : imem_inst_i;
                l1_pc_out_o <= ( stall_l1_i == 1'b1 ) ? l1_pc_out_o : pc_i;
            end
        end
    end
    
endmodule