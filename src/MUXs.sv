`timescale 1ns/1ns
`default_nettype none

module mux_reg_file_addr(
    input typed_pkg::sel_reg_file_addr_t sel_i, 
    input logic [4:0] rs1_i, 
    input logic [4:0] rs2_i, 
    input logic [4:0] rd_i, 
    output logic [4:0] addr_reg_o
);
    import typed_pkg::*;

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
    input typed_pkg::sel_reg_file_data_t sel_i, 
    input logic [31:0] from_data_mem_i, 
    input logic [31:0] from_ALU_i, 
    input logic [31:0] from_decoder_i, 
    input logic [31:0] from_pc_i, 
    input logic [31:0] from_csr_i, 
    output logic [31:0] data_o
);
    import typed_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_reg_file_data_mem : data_o = from_data_mem_i;
            sel_reg_file_alu : data_o = from_ALU_i;
            sel_reg_file_decoder : data_o = from_decoder_i;
            sel_reg_file_pc : data_o = from_pc_i;
            sel_reg_file_csr : data_o = from_csr_i;
            default: data_o = 'd0;
        endcase
    end
endmodule

module mux_alu_a(
    input clk_i,
    input typed_pkg::sel_alu_a_t sel_i, 
    input logic [31:0] const_4_i, 
    input logic [31:0] sign_ext_offset_i, 
    input logic [31:0] lui_i, 
    input logic [31:0] rs2_i, 
    output logic [31:0] data_o
);
    import typed_pkg::*;

    logic [31:0] rs2_delayed;

    always_ff @( posedge clk_i ) begin 
        rs2_delayed <= rs2_i;
    end

    always_comb begin 
        case (sel_i)
            sel_alu_const_4 : data_o = const_4_i;
            sel_alu_sign_ext_offset : data_o = sign_ext_offset_i;
            sel_alu_lui : data_o = lui_i;
            sel_alu_rs2 : data_o = rs2_delayed;
            default: data_o = 'd0;
        endcase
    end
endmodule

module mux_alu_b(
    input typed_pkg::sel_alu_b_t sel_i, 
    input logic [31:0] pc_i, 
    input logic [31:0] rs1_i,  
    output logic [31:0] data_o
);
    import typed_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_alu_pc  : data_o = pc_i;
            sel_alu_rs1 : data_o = rs1_i;
            default: data_o = 'd0;
        endcase
    end
endmodule

module mux_pc #( 
    parameter ADDR_WIDTH = 32,
    parameter INT_HND = 32'd8
) (
    input clk_i,
    input typed_pkg::sel_pc_t sel_i, 
    input logic [ADDR_WIDTH-1:0] pc_update_i, 
    input logic [ADDR_WIDTH-1:0] jump_vec_i,    
    output logic [ADDR_WIDTH-1:0] data_o
);
    import typed_pkg::*;
    logic [ADDR_WIDTH-1:0] int_hnd;
    
    always_ff @( posedge clk_i ) begin 
        int_hnd <= INT_HND;
    end

    always_comb begin 
        case (sel_i)
            sel_pc_update : data_o = pc_update_i;
            sel_pc_jump_vec : data_o = jump_vec_i;
            sel_pc_int_hnd : data_o = int_hnd;
            default: data_o = 'd0;
        endcase
    end
endmodule

module mux_csr_data (
    input typed_pkg::sel_csr_data_t sel_i,
    input logic [31:0] pc_i,
    input logic [31:0] uimm_i,
    input logic [31:0] rs1_i,
    input logic [31:0] from_ctrl_unit_i,
    output logic [31:0] data_o
);
    import typed_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_csr_data_pc : data_o = pc_i;
            sel_csr_data_uimm : data_o = uimm_i;
            sel_csr_data_rs1 : data_o = rs1_i;
            sel_csr_data_ctrl_unit : data_o = from_ctrl_unit_i;
            default: data_o = 'd0;
        endcase
    end
endmodule

module mux_csr_addr (
    input typed_pkg::sel_csr_addr_t sel_i,
    input logic [11:0] from_ctrl_unit_i,
    input logic [11:0] from_decoder_i,
    output logic [11:0] addr_o
);
    import typed_pkg::*;

    always_comb begin 
        case (sel_i)
            sel_csr_addr_decoder : addr_o = from_decoder_i;
            sel_csr_addr_ctrl_unit : addr_o = from_ctrl_unit_i;
            default: addr_o = 'd0;
        endcase
    end
endmodule