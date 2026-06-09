`timescale 1ns/1ns
`default_nettype none

module csr #(
    parameter ADDR_WIDTH = 32
) (
    input clk_i,
    input rst_i,
    input rw_i,
    input en_i,
    input ext_interrupt_i,
    input logic[11:0] csr_addr_i,
    input logic[ADDR_WIDTH-1:0] new_data_i,
    output interrupt_status_o,
    output logic [31:0] csr_data_o    
);

import CSR_pkg::*;
import Transfer_pkg::*;

logic [31:0] mstatus, mepc, mtvec, mcause;

assign interrupt_status_o = mstatus[3];

always_ff @( posedge clk_i ) begin 
    if (!rst_i) begin
        mstatus <= 'd0;
        mepc <= 'd0;
        mtvec <= 'd0;
        mcause <= 'd0;
    end else begin
        mtvec <= 32'b0;

        if (ext_interrupt_i == 1'b1) mstatus[3] <= 1'b1; // interrupt registered
        else mstatus <= {19'b0, 2'b11, 11'b0};
        
        if (en_i == 1'b1) begin
            if (rw_i == read) begin 
            /* verilator lint_off CASEINCOMPLETE */
                unique case (csr_addr_i)
                    // CSR_misa : csr_data_o <= misa;
                    CSR_mstatus : csr_data_o <= mstatus;
                    CSR_mepc : csr_data_o <= mepc;
                    CSR_mtvec : csr_data_o <= mtvec;
                    CSR_mcause : csr_data_o <= mcause;
                    default: csr_data_o <= 'd0; 
                endcase
            /* verilator lint_off CASEINCOMPLETE*/
            end else begin 
                case (csr_addr_i)
                    CSR_mepc : mepc <= new_data_i;
                    CSR_mcause : mcause <= new_data_i;
                endcase
            end 
        end
    end
end

endmodule