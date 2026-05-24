// 
//  Multi-Cycle RippleV Core. NOT PIPELINED.
// 

`timescale 1ns/1ns
`default_nettype none

module RippleV_Mc #( 
    parameter ADDR_WIDTH = 5,
    parameter RST_HND = 4,
    parameter EXP_HND = 8,
    parameter INT_HND = 0
) (
    input clk_i,
    input rst_i,
    input ext_interrupt_i
);
    logic interrupt, housekeeper_enable, csr_rw, csr_enable, pc_enable;
    logic [1:0] housekeeper_task, sel_mux_pc;
    logic [ADDR_WIDTH-1:0] handler_address, pc_update_from_alu, pc_update, pc_final;
    logic [2:0] csr_addr;
    logic [31:0] csr_data;

    ctrl_unit ctrl_unit_inst (
        .clk_i,
        .rst_i,
        .interrupt_i(interrupt), 
        .sel_pc_mux(sel_mux_pc),
        .housekeeper_en_o(housekeeper_enable),
        .housekeeper_task_o(housekeeper_task)
    );

    housekeeper #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .RST_HND(RST_HND), 
        .EXP_HND(EXP_HND), 
        .INT_HND(INT_HND)
    ) housekeeper_inst (
        .clk_i,
        .rst_i,
        .en_i(housekeeper_enable),
        .task_i(housekeeper_task),
        .csr_en_o(csr_enable),
        .csr_rw_o(csr_rw),
        .csr_addr_o(csr_addr),
        .handler_addr_o(handler_address)
    );

    csr # ( 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) csr_inst (
        .clk_i,
        .rst_i,
        .ext_interrupt_i,
        .rw_i(csr_rw),
        .en_i(csr_enable),
        .csr_addr_i(csr_addr),
        .new_data_i(pc_final),
        .interrupt_status_o(interrupt),
        .csr_data_o(csr_data)
    );

    mux_pc #( 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mux_pc_inst (
        .sel_i(sel_mux_pc),
        .pc_update_i(pc_update_from_alu), // not connected
        .mret_i(csr_data[ADDR_WIDTH-1:0]), 
        .handler_addr_i(handler_address),
        .data_o(pc_update)
    );

    program_counter #( 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) program_counter_inst (
        .clk_i,
        .rst_i,
        .en_i(pc_enable),
        .pc_update_i(pc_update),
        .pc_o(pc_final) // not connected
    );


// Assertions


endmodule
