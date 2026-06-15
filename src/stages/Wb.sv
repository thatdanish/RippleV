// Write back stage

module wb_stage (
    input clk_i,
    input rst_i,
    // Reg-file
    input reg_file_en_i
    input typed_pkg::rw_t reg_file_rw_i
    input reg_file_addr_i,
    input reg_file_data_i,
    output reg_file_data_o
);
    import typed_pkg::*; 

    reg_file reg_file_inst (
        .clk_i,
        .rst_i,
        .en_i(reg_file_en_i), 
        .rw_i(reg_file_rw_i),
        .addr_i(reg_file_addr_i),
        .data_i(reg_file_data_i),
        .data_o(reg_file_data_o)
    );
    
endmodule