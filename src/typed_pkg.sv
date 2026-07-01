`timescale 1ns/1ns  // for making verilator happy

package typed_pkg;
    
// Instructions to CTRL-Unit

typedef enum bit[5:0] { CTRL_ADDI, CTRL_SLTI, CTRL_SLTIU, CTRL_ANDI, CTRL_ORI, CTRL_XORI, CTRL_SLLI,
    CTRL_SRLI, CTRL_SRAI, CTRL_LUI, CTRL_AUIPC, CTRL_ADD, CTRL_SUB, CTRL_SLTU, CTRL_SLT, CTRL_AND, CTRL_OR,
    CTRL_XOR, CTRL_SLL, CTRL_SRL, CTRL_SRA, CTRL_JAL, CTRL_JALR, CTRL_BEQ, CTRL_BNE, CTRL_BGE, CTRL_BLT, CTRL_BLTU,
    CTRL_BGEU, CTRL_LW, CTRL_LH, CTRL_LHU, CTRL_LB, CTRL_LBU, CTRL_SW, CTRL_SH, CTRL_SB, CTRL_MUL, CTRL_MULH,
    CTRL_MULHU, CTRL_MULHSU, CTRL_DIV, CTRL_DIVU, CTRL_REM, CTRL_REMU, CTRL_MRET, CTRL_WFI, CTRL_CSRRW, CTRL_CSRRS,
    CTRL_CSRRC, CTRL_CSRRWI, CTRL_CSRRSI, CTRL_CSRRCI, CTRL_FENCE, CTRL_ECALL, CTRL_EBREAK } ctrl_inst_t;

// Instructions to ALU

typedef enum bit [4:0] { ALU_ADD, ALU_SUB, ALU_MUL, ALU_MULH, ALU_MULHU, ALU_MULHSU, ALU_DIV, ALU_DIVU, ALU_REM,
    ALU_REMU, ALU_SLT, ALU_SLTU, ALU_AND, ALU_OR, ALU_XOR, ALU_SLL, ALU_SRL, ALU_SRA, ALU_BEQ, ALU_BNE, ALU_BLT,
    ALU_BLTU, ALU_BGE, ALU_BGEU, ALU_JAL, ALU_JALR } alu_opr_t;

// Address to CSR

typedef enum bit[11:0] { CSR_stvec = 12'h105, CSR_satp = 12'h180, CSR_mhartid = 12'hF14, CSR_mstatus = 12'h300,
    CSR_medeleg = 12'h302, CSR_mideleg = 12'h303, CSR_mie = 12'h304, CSR_mtvec = 12'h305, CSR_mepc = 12'h341,
    CSR_mcause = 12'h342, CSR_mnstatus = 12'h744, CSR_pmpcfg0 = 12'h3A0, CSR_pmpaddr0 = 12'h3B0 } csr_addr_t;

// Causes

typedef enum bit [31:0] { cause_ecall = {1'b0, 31'd11}, cause_illegal_instruction = {1'b0, 31'd2}, cause_break = {1'b0, 31'd3},
    cause_interrupt = {1'b1, 31'd11} } cause_t;

// mux_reg_file_addr

typedef enum bit[1:0] { sel_reg_file_rs1, sel_reg_file_rs2, sel_reg_file_rd } sel_reg_file_addr_t;

// mux_reg_file_data

typedef enum bit[2:0] { sel_reg_file_data_mem, sel_reg_file_alu, sel_reg_file_decoder, sel_reg_file_pc, sel_reg_file_csr } sel_reg_file_data_t;

// mux_alu_a

typedef enum bit[1:0] { sel_alu_const_4, sel_alu_sign_ext_offset, sel_alu_lui, sel_alu_rs2 } sel_alu_a_t;

// mux_alu_b

typedef enum bit [1:0] { sel_alu_pc, sel_alu_rs1  } sel_alu_b_t;

// mux_pc

typedef enum bit [1:0] { sel_pc_direct_update, sel_pc_update, sel_pc_jump_vec, sel_pc_int_hnd  } sel_pc_t;

// mux_csr_data

typedef enum bit [1:0] { sel_csr_data_pc, sel_csr_data_uimm, sel_csr_data_rs1, sel_csr_data_ctrl_unit } sel_csr_data_t;

// mux_csr_addr

typedef enum bit[1:0] { sel_csr_addr_decoder, sel_csr_addr_ctrl_unit  } sel_csr_addr_t;

// Read & write

typedef enum logic { write, read } rw_t;

// Transfer - byte, hex, word

typedef enum bit[1:0] { transfer_byte, transfer_hex_byte, transfer_word } transfer_t;

// Write - complete, set, clear

typedef enum bit[1:0] { write_complete, write_set, write_clear } write_t;

// Load - signed, un-signed

typedef enum bit[1:0] { load_signed, load_unsigned } load_t;

// Instruction type

typedef enum bit[3:0] { HCU_I_type, HCU_R_type, HCU_LOAD_type, HCU_STORE_type, HCU_CJ_type , HCU_UCJ_type, HCU_CSR_type, 
                        HCU_ecall, HCU_mret, HCU_wfi, HCU_trap} instruction_type_t;

// HCU special stages

typedef enum bit[1:0] {first, second, third, fourth} hcu_handler_stages_t;

endpackage