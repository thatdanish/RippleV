`timescale 1ns/1ns
`default_nettype none

module csr #(
    parameter ADDR_WIDTH = 32,
    parameter B_TEST = 0,
    parameter TRAP_HND = 32'd0
) (
    input clk_i,
    input rst_i,
    input rw_i,
    input en_i,
    input ext_interrupt_i,
    input logic[1:0] write_type_i,
    input logic[11:0] csr_addr_i,
    input logic[ADDR_WIDTH-1:0] new_data_i,
    output interrupt_status_o,
    output logic [31:0] csr_data_o    
);

import CSR_pkg::*;
import Transfer_pkg::*;

logic [31:0] stvec, satp, mhartid, mstatus, medeleg, mideleg, mie;
logic [31:0] mepc, mtvec, mcause, mnstatus, pmpcfg0, pmpaddr0;

assign interrupt_status_o = mstatus[3];

always_ff @( posedge clk_i ) begin 
    if (~rst_i) begin
        stvec <= 'd0;
        satp <= 'd0;
        mhartid <= 'd0;
        mstatus <= 'd0;
        medeleg <= 'd0;
        mideleg <= 'd0;
        mie <= 'd0;
        mepc <= 'd0;
        mtvec <= TRAP_HND;
        mcause <= 'd0;
        mnstatus <= 'd0;
        pmpcfg0 <= 'd0;
        pmpaddr0 <= 'd0;
    end else begin
        if (ext_interrupt_i == 1'b1) mstatus[3] <= 1'b1; // interrupt registered
          
        if (en_i == 1'b1) begin
            if (rw_i == read) begin 
            /* verilator lint_off CASEINCOMPLETE */
                unique case (csr_addr_i)
                    CSR_stvec: csr_data_o <= stvec;
                    CSR_satp: csr_data_o <= satp;
                    CSR_mhartid: csr_data_o <= mhartid;
                    CSR_mstatus: csr_data_o <= mstatus;
                    CSR_medeleg: csr_data_o <= medeleg;
                    CSR_mideleg: csr_data_o <= mideleg;
                    CSR_mie: csr_data_o <= mie;
                    CSR_mtvec : csr_data_o <= mtvec;
                    CSR_mepc : csr_data_o <= mepc;
                    CSR_mcause : csr_data_o <= mcause;
                    CSR_mnstatus: csr_data_o <= mnstatus;
                    CSR_pmpcfg0: csr_data_o <= pmpcfg0;
                    CSR_pmpaddr0: csr_data_o <= pmpaddr0;
                    default: csr_data_o <= 'd0; 
                endcase
            /* verilator lint_off CASEINCOMPLETE*/
            end else begin 
                unique case (csr_addr_i)
                    CSR_stvec: begin
                        case (write_type_i)
                            write_complete: stvec <= new_data_i;
                            write_set: stvec <= (new_data_i == 'd0) ? stvec : stvec^new_data_i;
                            write_clear: stvec <= (new_data_i == 'd0) ? stvec : ~(stvec^new_data_i);
                            default: stvec <= stvec;
                        endcase
                    end
                    CSR_satp: begin
                        case (write_type_i)
                            write_complete: satp <= new_data_i;
                            write_set: satp <= (new_data_i == 'd0) ? satp : satp^new_data_i;
                            write_clear: satp <= (new_data_i == 'd0) ? satp : ~(satp^new_data_i);
                            default: satp <= satp;
                        endcase
                    end
                    CSR_mhartid: begin
                        case (write_type_i)
                            write_complete: mhartid <= new_data_i;
                            write_set: mhartid <= (new_data_i == 'd0) ? mhartid : mhartid^new_data_i;
                            write_clear: mhartid <= (new_data_i == 'd0) ? mhartid : ~(mhartid^new_data_i);
                            default: mhartid <= mhartid;
                        endcase
                    end
                    CSR_mstatus: begin
                        case (write_type_i)
                            write_complete: mstatus <= new_data_i;
                            write_set: mstatus <= (new_data_i == 'd0) ? mstatus : mstatus^new_data_i;
                            write_clear: mstatus <= (new_data_i == 'd0) ? mstatus : ~(mstatus^new_data_i);
                            default: mstatus <= mstatus;
                        endcase
                    end
                    CSR_medeleg: begin
                        case (write_type_i)
                            write_complete: medeleg <= new_data_i;
                            write_set: medeleg <= (new_data_i == 'd0) ? medeleg : medeleg^new_data_i;
                            write_clear: medeleg <= (new_data_i == 'd0) ? medeleg : ~(medeleg^new_data_i);
                            default: medeleg <= medeleg;
                        endcase
                    end
                    CSR_mideleg: begin
                        case (write_type_i)
                            write_complete: mideleg <= new_data_i;
                            write_set: mideleg <= (new_data_i == 'd0) ? mideleg : mideleg^new_data_i;
                            write_clear: mideleg <= (new_data_i == 'd0) ? mideleg : ~(mideleg^new_data_i);
                            default: mideleg <= mideleg;
                        endcase
                    end
                    CSR_mie: begin
                        case (write_type_i)
                            write_complete: mie <= new_data_i;
                            write_set: mie <= (new_data_i == 'd0) ? mie : mie^new_data_i;
                            write_clear: mie <= (new_data_i == 'd0) ? mie : ~(mie^new_data_i);
                            default: mie <= mie;
                        endcase
                    end
                    CSR_mtvec : begin
                        case (write_type_i)
                            write_complete: mtvec <= new_data_i;
                            write_set: mtvec <= (new_data_i == 'd0) ? mtvec : mtvec^new_data_i;
                            write_clear: mtvec <= (new_data_i == 'd0) ? mtvec : ~(mtvec^new_data_i);
                            default: mtvec <= mtvec;
                        endcase
                    end
                    CSR_mepc : begin
                        case (write_type_i)
                            write_complete: mepc <= new_data_i;
                            write_set: mepc <= (new_data_i == 'd0) ? mepc : mepc^new_data_i;
                            write_clear: mepc <= (new_data_i == 'd0) ? mepc : ~(mepc^new_data_i);
                            default: mepc <= mepc;
                        endcase
                    end
                    CSR_mcause : begin
                        case (write_type_i)
                            write_complete: mcause <= new_data_i;
                            write_set: mcause <= (new_data_i == 'd0) ? mcause : mcause^new_data_i;
                            write_clear: mcause <= (new_data_i == 'd0) ? mcause : ~(mcause^new_data_i);
                            default: mcause <= mcause;
                        endcase
                    end
                    CSR_mnstatus: begin
                        case (write_type_i)
                            write_complete: mnstatus <= new_data_i;
                            write_set: mnstatus <= (new_data_i == 'd0) ? mnstatus : mnstatus^new_data_i;
                            write_clear: mnstatus <= (new_data_i == 'd0) ? mnstatus : ~(mnstatus^new_data_i);
                            default: mnstatus <= mnstatus;
                        endcase
                    end
                    CSR_pmpcfg0: begin
                        case (write_type_i)
                            write_complete: pmpcfg0 <= new_data_i;
                            write_set: pmpcfg0 <= (new_data_i == 'd0) ? pmpcfg0 : pmpcfg0^new_data_i;
                            write_clear: pmpcfg0 <= (new_data_i == 'd0) ? pmpcfg0 : ~(pmpcfg0^new_data_i);
                            default: pmpcfg0 <= pmpcfg0;
                        endcase
                    end
                    CSR_pmpaddr0: begin
                        case (write_type_i)
                            write_complete: pmpaddr0 <= new_data_i;
                            write_set: pmpaddr0 <= (new_data_i == 'd0) ? pmpaddr0 : pmpaddr0^new_data_i;
                            write_clear: pmpaddr0 <= (new_data_i == 'd0) ? pmpaddr0 : ~(pmpaddr0^new_data_i);
                            default: pmpaddr0 <= pmpaddr0;
                        endcase
                    end
                    default: csr_data_o <= 'd0; 
                endcase
            end
        end
    end
end

// Assertions

// property valid_csr_write;
//     @(posedge clk_i) (B_TEST == 0) && (rw_i == write) && (en_i == 1'b1) 
//         |-> (csr_addr_i != CSR_mtvec && csr_addr_i != CSR_mhartid);
// endproperty

//     assert property (valid_csr_write)
//     else $fatal(0, "Invalid CSR write attempted");

endmodule