// 
//  Handles CSR interactions and loading handler address into PC
//

`timescale 1ns/1ns
`default_nettype none

module housekeeper #( 
    parameter ADDR_WIDTH = 32,
    parameter RST_HND = 4, 
    parameter EXP_HND = 8, 
    parameter INT_HND = 0 
) (
    input clk_i,
    input rst_i,
    input en_i,
    input  logic [1:0] task_i,
    output csr_en_o,
    output csr_rw_o,
    output logic [2:0] csr_addr_o,
    output logic [ADDR_WIDTH-1:0] handler_addr_o
);
    import sel_pkg::*;
    import CSR_pkg::*;

    logic [ADDR_WIDTH-1:0] reset_handler, exception_handler, interrupt_handler;

    always_ff @( posedge clk_i ) begin
        if (!rst_i) begin
            reset_handler <= ADDR_WIDTH'(RST_HND);
            exception_handler <= ADDR_WIDTH'(EXP_HND);
            interrupt_handler <= ADDR_WIDTH'(INT_HND);
        end else begin
            if (en_i == 1'b1) begin
                case (task_i)
                    task_reset: begin
                        csr_rw_o <= 1'b0;
                        csr_en_o <= 1'b0;
                        csr_addr_o <= 'd0;
                        handler_addr_o <= RST_HND;
                    end
                    task_exception: begin
                        csr_rw_o <= write;
                        csr_en_o <= 1'b1;
                        csr_addr_o <= CSR_mepc;
                        handler_addr_o <= EXP_HND;
                    end
                    task_interrupt: begin
                        csr_rw_o <= write;
                        csr_en_o <= 1'b1;
                        csr_addr_o <= CSR_mepc;
                        handler_addr_o <= INT_HND;
                    end
                    task_mret: begin
                        csr_rw_o <= read;
                        csr_en_o <= 1'b1;
                        csr_addr_o <= CSR_mepc;
                        handler_addr_o <= 'd0;
                    end
                    default: begin
                        csr_rw_o <= 1'b0;
                        csr_en_o <= 'd0;
                        csr_addr_o <= 'd0;
                        handler_addr_o <= 'd0;
                    end
                endcase
            end else begin
                csr_rw_o <= 1'b0;
                csr_en_o <= 1'b0;
                csr_addr_o <= 'd0;
                handler_addr_o <= 'd0;
            end
        end
        
    end
endmodule
