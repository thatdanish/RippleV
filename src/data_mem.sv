`timescale 1ns/1ns
`default_nettype none

module data_mem #( 
    parameter ADDR_WIDTH = 32
) (
    input clk_i,
    input rst_i,
    input en_i,
    input rw_i,
    input logic [1:0] transfer_type_i,
    input logic [ADDR_WIDTH-1:0] addr_i,
    input logic [31:0] data_i,    
    output logic [31:0] data_o    
);

import Transfer_pkg::*;

logic [31:0] dmem[4096+1];

always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        data_o <= 'd0;
    end else begin
        if (en_i == 1'b1) begin
            if (rw_i == read) begin
                /* verilator lint_off CASEINCOMPLETE */
                unique case (transfer_type_i)
                    transfer_byte :  begin
                        case (32'((addr_i >> 2) % 32'd4))
                            'd0: data_o <= 32'(dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][7:0]);
                            'd1: data_o <= 32'(dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][15:8]);
                            'd2: data_o <= 32'(dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][23:16]);
                            'd3: data_o <= 32'(dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][31:24]);
                        endcase
                    end
                    transfer_hex_byte : begin
                        case (32'((addr_i >> 2) % 32'd4))
                            'd0: data_o <= 32'(dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][15:0]);
                            'd2: data_o <= 32'(dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][31:16]);
                        endcase
                    end
                    transfer_word : data_o <= dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))];
                endcase
               /* verilator lint_on CASEINCOMPLETE */
            end
            else begin                
                /* verilator lint_off CASEINCOMPLETE */
                unique case (transfer_type_i)
                    transfer_byte :  begin
                        case (32'((addr_i >> 2) % 32'd4))
                            'd0: dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][7:0] <= data_i[7:0];
                            'd1: dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][15:8] <= data_i[7:0];
                            'd2: dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][23:16] <= data_i[7:0];
                            'd3: dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][31:24] <= data_i[7:0];
                        endcase
                    end
                    transfer_hex_byte : begin
                        case (32'((addr_i >> 2) % 32'd4))
                            'd0: dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][15:0] <= data_i[15:0];
                            'd2: dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))][31:16] <= data_i[15:0];
                        endcase
                    end
                    transfer_word : dmem[32'((addr_i >> 2)-((addr_i >> 2)%4))] <= data_i;
                endcase
               /* verilator lint_on CASEINCOMPLETE */
            end 
        end
    end    
end
    
endmodule
