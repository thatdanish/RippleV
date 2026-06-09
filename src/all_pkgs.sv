`timescale 1ns/1ns  // for making verilator happy

package Opcodes_pkg;

// Opcode & funct-codes

localparam LUI = 7'b0110111;
localparam AUIPC = 7'b0010111;
localparam JAL = 7'b1101111;
localparam JALR = 7'b1100111;
localparam CJ = 7'b1100011;
    localparam BEQ = 3'b000;
    localparam BNE = 3'b001;
    localparam BGE = 3'b101;
    localparam BLTU = 3'b110;
    localparam BGEU = 3'b111;
localparam LOAD = 7'b0000011;
    localparam LB = 3'b000;
    localparam LH = 3'b001;
    localparam LW = 3'b010;
    localparam LBU = 3'b100;
    localparam LHU = 3'b101;
localparam STORE = 7'b0100011;
    localparam SB = 3'b000;
    localparam SH = 3'b001;
    localparam SW = 3'b010;
localparam IMM_T = 7'b0010011;
    localparam ADDI = 3'b000;
    localparam SLTI = 3'b010;
    localparam SLTIU = 3'b011;
    localparam XORI = 3'b100;
    localparam ORI = 3'b110;
    localparam ANDI = 3'b111;
    localparam SLLI = 3'b001;
        localparam SLLI_F7 = 7'b0000000;
    localparam SRLI_SRAI = 3'b101;
        localparam SRLI_F7 = 7'b0000000;
        localparam SRAI_F7 = 7'b0100000;
localparam REG_T = 7'b0110011;
    localparam ADD_SUB_MUL = 3'b000;
        localparam ADD_F7 = 7'b0000000;
        localparam SUB_F7 = 7'b0100000;
        localparam MUL_F7 = 7'b0000001;
    localparam SLL_MULH = 3'b001;
        localparam SLL_F7 = 7'b0000000;
        localparam MULH_F7 = 7'b0000001;
    localparam SLT_MULHSU = 3'b010;
        localparam SLT_F7 = 7'b0000000;
        localparam MULHSU_F7 = 7'b0000001;
    localparam SLTU_MULHU = 3'b011;
        localparam SLTU_F7 = 7'b0000000;
        localparam MULHU_F7 = 7'b0000001;
    localparam XOR_DIV = 3'b100;
        localparam XOR_F7 = 7'b0000000;
        localparam DIV_F7 = 7'b0000001;
    localparam SRL_SRA_DIVU = 3'b101;
        localparam SRL_F7 = 7'b0000000;
        localparam SRA_F7 = 7'b0100000;
        localparam DIVU_F7 = 7'b0000001;
    localparam OR_REM = 3'b110;
        localparam OR_F7 = 7'b0000000;
        localparam REM_F7 = 7'b0000001;
    localparam AND_REMU = 3'b111;
        localparam AND_F7 = 7'b0000000;
        localparam REMU_F7 = 7'b0000001;
localparam ZICSR = 7'b1110011;
    localparam CSRRW = 3'b001;
    localparam CSRRS = 3'b010;
    localparam CSRRC = 3'b011;
    localparam CSRRWI = 3'b101;
    localparam CSRRSI = 3'b110;
    localparam CSRRCI = 3'b111;
endpackage

package CTRL_pkg;
    
// Instructions to CTRL-Unit

localparam CTRL_ADDI = 6'd0;
localparam CTRL_SLTI = 6'd1;
localparam CTRL_SLTIU = 6'd2;
localparam CTRL_ANDI = 6'd3;
localparam CTRL_ORI = 6'd4;
localparam CTRL_XORI = 6'd5;
localparam CTRL_SLLI = 6'd6;
localparam CTRL_SRLI = 6'd7;
localparam CTRL_SRAI = 6'd8;
localparam CTRL_LUI = 6'd9;
localparam CTRL_AUIPC = 6'd10;
localparam CTRL_ADD = 6'd11;
localparam CTRL_SUB = 6'd12;
localparam CTRL_SLTU = 6'd13;
localparam CTRL_SLT = 6'd14;
localparam CTRL_AND = 6'd15;
localparam CTRL_OR = 6'd16;
localparam CTRL_XOR = 6'd17;
localparam CTRL_SLL = 6'd18;
localparam CTRL_SRL = 6'd19;
localparam CTRL_SRA = 6'd46;
localparam CTRL_JAL = 6'd20;
localparam CTRL_JALR = 6'd21;
localparam CTRL_BEQ = 6'd22;
localparam CTRL_BNE = 6'd23;
localparam CTRL_BGE = 6'd44;
localparam CTRL_BLT = 6'd24;
localparam CTRL_BLTU = 6'd25;
localparam CTRL_BGEU = 6'd45;
localparam CTRL_LW = 6'd26;
localparam CTRL_LH = 6'd27;
localparam CTRL_LHU = 6'd28;
localparam CTRL_LB = 6'd29;
localparam CTRL_LBU = 6'd30;
localparam CTRL_SW = 6'd31;
localparam CTRL_SH = 6'd32;
localparam CTRL_SB = 6'd33;
localparam CTRL_MUL = 6'd34;
localparam CTRL_MULH = 6'd35;
localparam CTRL_MULHU = 6'd36;
localparam CTRL_MULHSU = 6'd37;
localparam CTRL_DIV = 6'd38;
localparam CTRL_DIVU = 6'd39;
localparam CTRL_REM = 6'd40;
localparam CTRL_REMU = 6'd41;
localparam CTRL_MRET = 6'd42;
localparam CTRL_WFI = 6'd43;

endpackage

package ALU_pkg;

// Instructions to ALU

localparam ALU_ADD = 5'd0;
localparam ALU_SUB = 5'd1;
localparam ALU_MUL = 5'd2;
localparam ALU_MULH = 5'd3;
localparam ALU_MULHU = 5'd4;
localparam ALU_MULHSU = 5'd5;
localparam ALU_DIV = 5'd6;
localparam ALU_DIVU = 5'd7;
localparam ALU_REM = 5'd8;
localparam ALU_REMU = 5'd9;
localparam ALU_SLT = 5'd10;
localparam ALU_SLTU = 5'd11;
localparam ALU_AND = 5'd13;
localparam ALU_OR = 5'd14;
localparam ALU_XOR = 5'd15;
localparam ALU_SLL = 5'd16;
localparam ALU_SRL = 5'd17;
localparam ALU_SRA = 5'd18;
localparam ALU_BEQ = 5'd19;
localparam ALU_BNE = 5'd20;
localparam ALU_BLT = 5'd21;
localparam ALU_BLTU = 5'd22;
localparam ALU_BGE = 5'd23;
localparam ALU_BGEU = 5'd12;
localparam ALU_JAL = 5'd24;
localparam ALU_JALR = 5'd25;

endpackage

package CSR_pkg;

// Address to CSR

localparam CSR_stvec = 12'h105;
localparam CSR_satp = 12'h180;
localparam CSR_mhartid = 12'hF12;
localparam CSR_mstatus = 12'h300;
localparam CSR_medeleg = 12'h302;
localparam CSR_mideleg = 12'h303;
localparam CSR_mie = 12'h304;
localparam CSR_mtvec = 12'h305;
localparam CSR_mepc = 12'h341;
localparam CSR_mcause = 12'h342;    
localparam CSR_mnstatus = 12'h744;
localparam CSR_pmpcfg0 = 12'h3A0;
localparam CSR_pmpaddr0 = 12'h3B0;

endpackage

package sel_pkg;

// mux_reg_file_addr

localparam  sel_reg_file_rs1 = 2'd0;
localparam  sel_reg_file_rs2 = 2'd1;
localparam  sel_reg_file_rd = 2'd2;

// mux_reg_file_data

localparam  sel_reg_file_data_mem = 2'd0;
localparam  sel_reg_file_alu = 2'd1;
localparam  sel_reg_file_decoder = 2'd2;
localparam  sel_reg_file_pc = 2'd3;

// mux_alu_a

localparam  sel_alu_const_4 = 2'd0;
localparam  sel_alu_sign_ext_offset = 2'd1;
localparam  sel_alu_lui = 2'd2;
localparam  sel_alu_rs2 = 2'd3;

// mux_alu_b

localparam  sel_alu_pc = 2'd0;
localparam  sel_alu_rs1 = 2'd1;

// mux_pc

localparam  sel_pc_update = 2'd0;
localparam  sel_pc_mret = 2'd1;
localparam  sel_pc_handler_addr = 2'd2;

// housekeeper tasks

localparam  task_reset = 2'd0;
localparam  task_exception = 2'd1;
localparam  task_interrupt = 2'd2;
localparam  task_mret = 2'd3;

endpackage

package Transfer_pkg;
// Read & write

localparam read = 1'b1;
localparam write = 1'b0;

localparam transfer_byte = 2'b00;
localparam transfer_hex_byte = 2'b01;
localparam transfer_word = 2'b10;

endpackage