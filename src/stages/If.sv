// Instruction fetch stage

module If #(
    parameter string FILE  = "../../../data/sample/sample_instructions.hex",
    parameter ADDR_WIDTH  = 32,
    parameter WORD_SIZE  = 32
) (
    input clk_i,
    input rst_i,
    input stall_if_i,
    // Instruction memory
    input inst_mem_en_i, 
    output logic [31:0] inst_mem_data_o,
    // PC
    input pc_en_i,
    input logic [31:0] pc_update_i,
    output logic [31:0] pc_out_o
);
    logic [ADDR_WIDTH-1:0] pc_out_address;

    assign pc_out_o = pc_out_address;

    inst_mem #(
        .FILE(FILE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .WORD_SIZE(WORD_SIZE)
    ) inst_mem_inst (
        .clk_i,
        .rst_i,
        .en_i(inst_mem_en_i), 
        .addr_i(pc_out_address),
        .data_o(inst_mem_data_o)
    );

    ProgramCounterv2 #( 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) program_counter_v2_inst (
        .clk_i,
        .rst_i,
        .stall_if_i,
        .en_i(pc_en_i),
        .pc_update_i(pc_update_i),
        .pc_o(pc_out_address)
    );
    
endmodule