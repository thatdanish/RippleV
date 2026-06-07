`timescale 1ns/1ns
`default_nettype  none

module inst_mem #( 
    parameter string FILE = "../../../data/sample/sample_instructions.hex",
    parameter ADDR_WIDTH = 32,
    parameter MEM_SIZE = 32
) (
    input clk_i,
    input rst_i,
    input en_i, 
    input [ADDR_WIDTH-1:0] addr_i,
    output logic [31:0] data_o
);

integer file;

logic [MEM_SIZE-1:0] imem [4096];

initial begin
    $readmemh(FILE, imem);
end

always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        data_o <= 'd0;
    end else begin
        if (en_i) begin
            data_o <= imem[addr_i >> 2];
        end
    end
end

endmodule