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
    output logic [31:0] l4_dmem_data_o
);

    always_ff @( posedge clk_i ) begin
        if (!rst_i) begin
            l4_csr_data_o <= 'd0;
            l4_dmem_data_o <= 'd0;
        end else begin
            if ( clear_l4_i == 1'b1 ) begin
                l4_csr_data_o <= 'd0;
                l4_dmem_data_o <= 'd0;
            end else begin
                l4_csr_data_o <= ( stall_l4_i == 1'b1) ? l4_csr_data_o : csr_data_i;
                l4_dmem_data_o <= ( stall_l4_i == 1'b1) ? l4_dmem_data_o : dmem_data_i;
            end
        end
        
    end
    
endmodule