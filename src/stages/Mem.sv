// Memory stage

module mem_stage #(
    parameter ADDR_WIDTH = 32,
    parameter LOAD_FROM_DMEM_HEX = 0,
    parameter TRAP_HND = 32'd4,
    parameter string FILE = "../../../data/sample/sample_instructions.hex"
) (
    input clk_i,
    input rst_i,
    // Data mem
    input data_mem_en_i,
    input typed_pkg::rw_t data_mem_rw_i,
    input typed_pkg::transfer_t data_mem_transfer_type_i,
    input typed_pkg::load_t data_mem_load_type_i,
    input data_mem_addr_i,
    input data_mem_data_i,
    input data_mem_data_o,
    // CSR
    input ext_interrupt_i,
    input typed_pkg::write_t csr_write_type_i,
    input typed_pkg::rw_t csr_rw_i,
    input csr_en_i,
    input typed_pkg::csr_addr_t csr_addr_i,
    input csr_data_i,
    output interrupt_status_o,
    output csr_data_o
);
    import typed_pkg::*; 
    
    data_mem #( 
        .ADDR_WIDTH(ADDR_WIDTH),
        .LOAD_FROM_DMEM_HEX(LOAD_FROM_DMEM_HEX),
        .FILE(DMEM_FILE)
    ) data_mem_inst (
        .clk_i,
        .rst_i,
        .en_i(data_mem_en_i),
        .rw_i(data_mem_rw_i),
        .transfer_type_i(data_mem_transfer_type_i),
        .load_type_i(data_mem_load_type_i),
        .addr_i(data_mem_addr_i),
        .data_i(data_mem_data_i),    
        .data_o(data_mem_data_o)  
    );

    csr # ( 
        .ADDR_WIDTH(ADDR_WIDTH),
        .TRAP_HND(TRAP_HND)
    ) csr_inst (
        .clk_i,
        .rst_i,
        .ext_interrupt_i,
        .write_type_i(csr_write_type_i),
        .rw_i(csr_rw_i),
        .en_i(csr_en_i),
        .csr_addr_i(csr_addr_i),
        .new_data_i(csr_data_i),
        .interrupt_status_o,
        .csr_data_o(csr_data_o)
    );


endmodule