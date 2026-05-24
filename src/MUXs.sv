`timescale 1ns/1ns
`default_nettype none

module mux_reg_file_addr(
    input logic [2:0] sel_i, 
    input logic [4:0] rs1_i, 
    input logic [4:0] rs2_i, 
    input logic [4:0] rd_i, 
    output logic [4:0] addr_reg_o
);
    import sel_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_reg_file_rs1 : addr_reg_o = rs1_i;
            sel_reg_file_rs2 : addr_reg_o = rs2_i;
            sel_reg_file_rd : addr_reg_o = rd_i;
            default: addr_reg_o = 'd0;
        endcase 
    end
endmodule

module mux_reg_file_data(
    input logic [2:0] sel_i, 
    input logic [31:0] from_data_mem_i, 
    input logic [31:0] from_ALU_i, 
    input logic [31:0] from_decoder_i, 
    output logic [31:0] data_o
);
    import sel_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_reg_file_data_mem : data_o = from_data_mem_i;
            sel_reg_file_alu : data_o = from_ALU_i;
            sel_reg_file_decoder : data_o = from_decoder_i;
            default: data_o = 'd0;
        endcase
    end
endmodule

module mux_alu_a(
    input logic [2:0] sel_i, 
    input logic [31:0] const_4_i, 
    input logic [31:0] sign_ext_offset_i, 
    input logic [31:0] lui_i, 
    input logic [31:0] rs2_i, 
    output logic [31:0] data_o
);
    import sel_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_alu_const_4 : data_o = const_4_i;
            sel_alu_sign_ext_offset : data_o = sign_ext_offset_i;
            sel_alu_lui : data_o = lui_i;
            sel_alu_rs2 : data_o = rs2_i;
            default: data_o = 'd0;
        endcase
    end
endmodule

module mux_alu_b(
    input logic [2:0] sel_i, 
    input logic [31:0] pc_i, 
    input logic [31:0] rs1_i,  
    output logic [31:0] data_o
);
    import sel_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_alu_pc  : data_o = pc_i;
            sel_alu_rs1 : data_o = rs1_i;
            default: data_o = 'd0;
        endcase
    end
endmodule

module mux_pc #( 
    parameter ADDR_WIDTH = 5
) (
    input logic [1:0] sel_i, 
    input logic [ADDR_WIDTH-1:0] pc_update_i, 
    input logic [ADDR_WIDTH-1:0] mret_i,  
    input logic [ADDR_WIDTH-1:0] handler_addr_i,  
    output logic [ADDR_WIDTH-1:0] data_o
);
    import sel_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_pc_pc_update : data_o = pc_update_i;
            sel_pc_mret : data_o = mret_i;
            sel_pc_handler_addr : data_o = handler_addr_i;
            default: data_o = 'd0;
        endcase
    end
endmodule