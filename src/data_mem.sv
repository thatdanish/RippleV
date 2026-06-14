`timescale 1ns/1ns
`default_nettype none

module data_mem #( 
    parameter ADDR_WIDTH = 32,
    parameter LOAD_FROM_DMEM_HEX = 0,
    parameter string FILE = "../../../data/sample/sample_instructions.hex"
) (
    input clk_i,
    input rst_i,
    input en_i,
    input typed_pkg::rw_t rw_i,
    input typed_pkg::transfer_t transfer_type_i,
    input typed_pkg::load_t load_type_i, 
    input logic [ADDR_WIDTH-1:0] addr_i,
    input logic [31:0] data_i,    
    output logic [31:0] data_o    
);

import typed_pkg::*;

logic [31:0] dmem[4096];

initial begin
    if (LOAD_FROM_DMEM_HEX)
        $readmemh(FILE, dmem);
end

always_ff @( posedge clk_i ) begin
    if (!rst_i && !LOAD_FROM_DMEM_HEX) begin
        data_o <= 'd0;
    end else begin
        if (en_i == 1'b1) begin
            if (rw_i == read) begin
                /* verilator lint_off CASEINCOMPLETE */
                unique case (transfer_type_i)
                    transfer_byte :  begin
                        case (addr_i[1:0])
                            2'd0: data_o <= (dmem[12'(addr_i[31:2])][7] == 1'b1 && load_type_i == load_signed) ? {24'hFFFFFF, dmem[12'(addr_i[31:2])][7:0]} : {24'h0, dmem[12'(addr_i[31:2])][7:0]};
                            2'd1: data_o <= (dmem[12'(addr_i[31:2])][15] == 1'b1 && load_type_i == load_signed) ? {24'hFFFFFF, dmem[12'(addr_i[31:2])][15:8]} : {24'h0, dmem[12'(addr_i[31:2])][15:8]};
                            2'd2: data_o <= (dmem[12'(addr_i[31:2])][23] == 1'b1 && load_type_i == load_signed) ? {24'hFFFFFF, dmem[12'(addr_i[31:2])][23:16]} : {24'h0, dmem[12'(addr_i[31:2])][23:16]};
                            2'd3: data_o <= (dmem[12'(addr_i[31:2])][31] == 1'b1 && load_type_i == load_signed) ? {24'hFFFFFF, dmem[12'(addr_i[31:2])][31:24]} : {24'h0, dmem[12'(addr_i[31:2])][31:24]};
                        endcase
                    end
                    transfer_hex_byte : begin
                        case (addr_i[1:0])
                            2'd0: data_o <= (dmem[12'(addr_i[31:2])][15] == 1'b1 && load_type_i == load_signed) ? {16'hFFFF, dmem[12'(addr_i[31:2])][15:0]} : {16'h0, dmem[12'(addr_i[31:2])][15:0]};
                            2'd2: data_o <= (dmem[12'(addr_i[31:2])][31] == 1'b1 && load_type_i == load_signed) ? {16'hFFFF, dmem[12'(addr_i[31:2])][31:16]} : {16'h0, dmem[12'(addr_i[31:2])][31:16]};
                        endcase
                    end
                    transfer_word : data_o <= dmem[12'(addr_i[31:2])];
                endcase
               /* verilator lint_on CASEINCOMPLETE */
            end
            else begin                
                /* verilator lint_off CASEINCOMPLETE */
                unique case (transfer_type_i)
                    transfer_byte :  begin
                        case (addr_i[1:0])
                            2'd0: dmem[12'(addr_i[31:2])][7:0] <= data_i[7:0];
                            2'd1: dmem[12'(addr_i[31:2])][15:8] <= data_i[7:0];
                            2'd2: dmem[12'(addr_i[31:2])][23:16] <= data_i[7:0];
                            2'd3: dmem[12'(addr_i[31:2])][31:24] <= data_i[7:0];
                        endcase
                    end
                    transfer_hex_byte : begin
                        case (addr_i[1:0])
                            2'd0: dmem[12'(addr_i[31:2])][15:0] <= data_i[15:0];
                            2'd2: dmem[12'(addr_i[31:2])][31:16] <= data_i[15:0];
                        endcase
                    end
                    transfer_word : dmem[12'(addr_i[31:2])] <= data_i;
                endcase
               /* verilator lint_on CASEINCOMPLETE */
            end 
        end
    end    
end

always_comb begin : blockName
    
end
endmodule
