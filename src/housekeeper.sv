`timescale 1ns/1ns
`default_nettype none

module housekeeper #( 
    parameter ADD_WIDTH = 5,
    parameter RST_HND = 4, 
    parameter EXP_HND = 8, 
    parameter INT_HND = 0, 
) (
    input clk_i,
    input rst_i,
    input  task_i,
    output logic [2:0] csr_addr_o;
    output logic [ADD_WIDTH-1:0] handler_addr;
);
    import sel_pkg::*;
    import Opcodes_pkg::*;

    logic [ADD_WIDTH-1:0] reset_handler, exception_handler, interrupt_handler;

    always_ff @( posedge clk_i ) begin
        if (!rst_i) begin
            reset_handler <= ADD_WIDTH'(RST_HND);
            exception_handler <= ADD_WIDTH'(EXP_HND);
            interrupt_handler <= ADD_WIDTH'(INT_HND);
        end else begin
            case (task_i)
                task_reset: begin
                    csr_addr_o <= 'd0;
                    handler_addr <= RST_HND;
                end
                task_exception: begin
                    csr_addr_o <= CSR_mepc;
                    handler_addr <= EXP_HND;
                end
                task_interrupt: begin
                    csr_addr_o <= CSR_mepc;
                    handler_addr <= INT_HND;
                end
                task_mret: begin
                    csr_addr_o <= CSR_mepc;
                    handler_addr <= 'd0;
                end
                default: begin
                    csr_addr_o <= 'd0;
                    handler_addr <= 'd0;
                end
            endcase
        end
        
    end
endmodule
