`timescale 1ns/1ns
`default_nettype none

module ctrl_unit(
    // External
    input clk_i,
    input rst_i,
    input main_enable_i, 
    output logic interrupt_ack_o,
    // CSR
    input interrupt_i,
    // Decoder
    input logic [5:0] instruction_i,
    // PC
    output logic [1:0] pc_mux_sel_o, 
    output logic pc_en_o,
    // CSR
    output logic [11:0] csr_addr_from_ctrl_o, 
    output logic [31:0] csr_data_from_ctrl_o, 
    output logic [1:0] csr_addr_mux_sel_o, 
    output logic [1:0] csr_data_mux_sel_o, 
    output logic [1:0] csr_write_type_o, 
    output logic csr_rw_o, 
    output logic csr_en_o, 
    // Instruction Memory
    output inst_mem_en_o,
    // Reg-file
    output logic [1:0] reg_file_addr_mux_sel_o,
    output logic [2:0] reg_file_data_mux_sel_o,
    output logic reg_file_rw_o,
    output logic reg_file_en_o,
    // ALU
    input take_branch_i, 
    output logic alu_en_o, 
    output logic [4:0] alu_opr_o,
    output logic[1:0] alu_a_mux_sel_o,
    output logic[1:0] alu_b_mux_sel_o,
    // Data Memory
    output logic data_mem_en_o,
    output logic [1:0] data_mem_transfer_type_o,
    output data_mem_rw_o
);

    import Opcodes_pkg::*;
    import ALU_pkg::*;
    import CTRL_pkg::*;
    import CSR_pkg::*;
    import Transfer_pkg::*;
    import sel_pkg::*;

    typedef enum bit[4:0] { IDLE, JUMP_PC, INST_START, READ_RS1, READ_RS2, ALU_COMPUTE, WRITE_RD,
                            LOAD_FROM_DATA_MEM, STORE_DATA_MEM, BUFF_1,READ_CSR, WRITE_CSR, NOP,
                            WRITE_MCAUSE, WRITE_MEPC, READ_MTVEC_MEPC, WFI_STALL} state_t;

    state_t current_state, next_state;
    logic take_branch_delayed;                        
    logic [5:0] current_instruction;                    

    always_ff @( posedge clk_i ) begin : StateUpdateBlock
        if (!rst_i) begin
            current_state <= IDLE;
            take_branch_delayed <= 1'b0;
            current_instruction <= 'd0;
        end else begin
            current_state <= next_state;
            take_branch_delayed <= take_branch_i;
            if (current_state == INST_START) current_instruction <= instruction_i;
            else current_instruction <= current_instruction;
        end
    end

    always_comb begin : NextStateComputeBlock
        next_state = IDLE;
        case (current_state)
            IDLE: begin
                if (interrupt_i == 1'b0) next_state = (main_enable_i == 1'b1) ? BUFF_1 : IDLE; 
                else next_state = WRITE_MCAUSE;
            end
            BUFF_1: next_state = INST_START;
            INST_START: begin
                unique case (instruction_i)
                    CTRL_ADDI: next_state  = READ_RS1;
                    CTRL_SLTI: next_state  = READ_RS1;
                    CTRL_SLTIU: next_state  = READ_RS1;
                    CTRL_ANDI: next_state  = READ_RS1;
                    CTRL_ORI: next_state  = READ_RS1;
                    CTRL_XORI: next_state  = READ_RS1;
                    CTRL_SLLI: next_state  = READ_RS1;
                    CTRL_SRLI: next_state  = READ_RS1;
                    CTRL_SRAI: next_state  = READ_RS1;
                    CTRL_LUI: next_state  = WRITE_RD;
                    CTRL_AUIPC: next_state  = ALU_COMPUTE;
                    CTRL_ADD: next_state  = READ_RS2;
                    CTRL_SUB: next_state  = READ_RS2;
                    CTRL_SLTU: next_state  = READ_RS2;
                    CTRL_SLT: next_state  = READ_RS2;
                    CTRL_AND: next_state  = READ_RS2;
                    CTRL_OR: next_state  = READ_RS2;
                    CTRL_XOR: next_state  = READ_RS2;
                    CTRL_SLL: next_state  = READ_RS2;
                    CTRL_SRL: next_state  = READ_RS2;
                    CTRL_SRA: next_state  = READ_RS2;
                    CTRL_JAL: next_state  = WRITE_RD;
                    CTRL_JALR: next_state  = WRITE_RD;
                    CTRL_BEQ: next_state  = READ_RS2;
                    CTRL_BNE: next_state  = READ_RS2;
                    CTRL_BGE: next_state  = READ_RS2;
                    CTRL_BLT: next_state  = READ_RS2;
                    CTRL_BLTU: next_state  = READ_RS2;
                    CTRL_BGEU: next_state  = READ_RS2;
                    CTRL_LW: next_state  = READ_RS1;
                    CTRL_LH: next_state  = READ_RS1;
                    CTRL_LHU: next_state  = READ_RS1;
                    CTRL_LB: next_state  = READ_RS1;
                    CTRL_LBU: next_state  = READ_RS1;
                    CTRL_SW: next_state  = READ_RS1;
                    CTRL_SH: next_state  = READ_RS1;
                    CTRL_SB: next_state  = READ_RS1;
                    CTRL_MUL: next_state  = READ_RS2;
                    CTRL_MULH: next_state  = READ_RS2;
                    CTRL_MULHU: next_state  = READ_RS2;
                    CTRL_MULHSU: next_state  = READ_RS2;
                    CTRL_DIV: next_state  = READ_RS2;
                    CTRL_DIVU: next_state  = READ_RS2;
                    CTRL_REM: next_state  = READ_RS2;
                    CTRL_REMU: next_state  = READ_RS2;
                    CTRL_CSRRW: next_state = READ_CSR;
                    CTRL_CSRRS: next_state = READ_CSR;
                    CTRL_CSRRC: next_state = READ_CSR;
                    CTRL_CSRRWI: next_state = READ_CSR;
                    CTRL_CSRRSI: next_state = READ_CSR;
                    CTRL_CSRRCI: next_state = READ_CSR;
                    CTRL_FENCE: next_state = NOP;
                    CTRL_ECALL: next_state = WRITE_MCAUSE;
                    CTRL_MRET: next_state  = READ_MTVEC_MEPC;
                    CTRL_WFI: next_state = WFI_STALL;
                    default: next_state = WRITE_MCAUSE; // illegal instruction exception
                endcase
            end
            READ_RS2: begin
                next_state = READ_RS1;
            end
            READ_RS1: begin
                next_state = ALU_COMPUTE;
            end
            ALU_COMPUTE: begin
                if (current_instruction inside {CTRL_LW, CTRL_LH,CTRL_LHU,CTRL_LB,CTRL_LBU}) 
                    next_state = LOAD_FROM_DATA_MEM;
                else if (current_instruction inside {CTRL_SW,CTRL_SH,CTRL_SB})
                    next_state = STORE_DATA_MEM;
                else if (current_instruction inside {CTRL_BEQ, CTRL_BGE, CTRL_BGEU, CTRL_BLT, CTRL_BLTU, CTRL_BNE})
                    if (take_branch_i == 1'b1 && take_branch_delayed == 1'b0) 
                        next_state = ALU_COMPUTE;
                    else if (take_branch_i == 1'b0 && take_branch_delayed == 1'b1) 
                        next_state = JUMP_PC;
                    else
                        next_state = IDLE;
                else if (current_instruction inside {CTRL_JAL, CTRL_JALR})
                    next_state = JUMP_PC;
                else 
                    next_state = WRITE_RD;
            end
            WRITE_RD: begin
                if (current_instruction == CTRL_JAL) 
                    next_state = ALU_COMPUTE;
                else if (current_instruction == CTRL_JALR)
                    next_state = READ_RS1;
                else if (current_instruction inside {CTRL_CSRRS, CTRL_CSRRW, CTRL_CSRRC, CTRL_CSRRWI, CTRL_CSRRSI, CTRL_CSRRCI})
                    next_state = WRITE_CSR;
                else
                    next_state = IDLE;
            end
            LOAD_FROM_DATA_MEM: begin
                next_state = WRITE_RD;
            end
            STORE_DATA_MEM: begin
                next_state = IDLE;
            end
            JUMP_PC: begin
                next_state =  IDLE;
            end
            READ_CSR: begin
                next_state = WRITE_RD;
            end
            WRITE_CSR: begin
                next_state = IDLE;
            end
            NOP: begin
                next_state = IDLE;
            end
            WRITE_MCAUSE: begin
                next_state = WRITE_MEPC;
            end
            WRITE_MEPC: begin
                next_state = (interrupt_i == 1'b1) ? JUMP_PC : READ_MTVEC_MEPC;
            end
            READ_MTVEC_MEPC: begin
                next_state = JUMP_PC;
            end
            WFI_STALL: begin
                // Core hang
                next_state = WFI_STALL;
            end
            default: begin
               // UGLY : Fill default condition
            end
        endcase
        
    end
    
    always_comb begin : OutputBlock
        // External
        interrupt_ack_o = 1'b0;
        // CSR  
        csr_data_from_ctrl_o = 'd0; 
        csr_addr_from_ctrl_o = 'd0; 
        csr_addr_mux_sel_o = 'd0;
        csr_data_mux_sel_o = 'd0;
        csr_write_type_o = 'd0;
        csr_en_o = 1'b0; 
        csr_rw_o = 1'b0; 
        // PC
        pc_mux_sel_o = 'd0;
        pc_en_o = 1'b0;
        // Inst-mem
        inst_mem_en_o = 1'b0;
        // Reg-file
        reg_file_addr_mux_sel_o = 'b0;
        reg_file_data_mux_sel_o = 'b0;
        reg_file_rw_o = 1'b0;
        reg_file_en_o = 1'b0;
        // ALU
        alu_en_o = 1'b0;
        alu_a_mux_sel_o = 'd0;
        alu_b_mux_sel_o = 'd0;
        alu_opr_o = 'b0;
        // Data-mem
        data_mem_en_o = 1'b0;
        data_mem_rw_o = 1'b0;
        data_mem_transfer_type_o = 2'b0;

        case (current_state)
            IDLE: begin
                if (main_enable_i == 1'b1 && interrupt_i == 1'b0) begin
                    inst_mem_en_o = 1'b1;    
                    
                    // Update PC                    
                    alu_en_o = 1'b1;
                    alu_opr_o = ALU_ADD;
                    alu_a_mux_sel_o = sel_alu_const_4;
                    alu_b_mux_sel_o = sel_alu_pc;
                end
            end
            INST_START: begin
                // Update PC = PC+4
                pc_mux_sel_o = sel_pc_update;
                pc_en_o = 1'b1;
            end
            READ_RS1: begin
                reg_file_en_o = 1'b1;
                reg_file_addr_mux_sel_o =  sel_reg_file_rs1;
                reg_file_rw_o = read;
            end
            READ_RS2: begin
                reg_file_en_o = 1'b1;
                reg_file_addr_mux_sel_o =  sel_reg_file_rs2;
                reg_file_rw_o = read;
            end
            ALU_COMPUTE: begin
                if (take_branch_delayed == 1'b1) begin
                    // Conditional branch
                    alu_en_o = 1'b1;
                    alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                    alu_b_mux_sel_o = sel_alu_pc;
                    alu_opr_o = ALU_JAL;
                end else begin
                    case (current_instruction)
                        CTRL_ADDI: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_ADD;
                        end
                        CTRL_SLTI: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SLT;
                        end
                        CTRL_SLTIU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SLTU;
                        end
                        CTRL_ANDI: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_AND;
                        end
                        CTRL_ORI: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_OR;
                        end
                        CTRL_XORI: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_XOR;
                        end
                        CTRL_SLLI: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SLL;
                        end
                        CTRL_SRLI: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SRL;
                        end
                        CTRL_SRAI: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SRA;
                        end
                        CTRL_AUIPC: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_lui;
                            alu_b_mux_sel_o = sel_alu_pc;
                            alu_opr_o = ALU_JAL;
                        end
                        CTRL_ADD: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_ADD;
                        end
                        CTRL_SUB: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SUB;
                        end
                        CTRL_SLTU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SLTU;
                        end
                        CTRL_SLT: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SLT;
                        end
                        CTRL_AND: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_AND;
                        end
                        CTRL_OR: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_OR;
                        end
                        CTRL_XOR: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_XOR;
                        end
                        CTRL_SLL: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SLL;
                        end
                        CTRL_SRL: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SRL;
                        end
                        CTRL_SRA: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_SRA;
                        end
                        CTRL_JAL: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_pc;
                            alu_opr_o = ALU_JAL;
                        end
                        CTRL_JALR: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_JALR;
                        end
                        CTRL_BEQ: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_BEQ;
                        end
                        CTRL_BNE: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_BNE;
                        end
                        CTRL_BGE: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_BGE;
                        end
                        CTRL_BLT: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_BLT;
                        end
                        CTRL_BLTU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_BLTU;
                        end
                        CTRL_BGEU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_BGEU;
                        end
                        CTRL_LW: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_ADD;
                        end
                        CTRL_LH: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_ADD;
                        end
                        CTRL_LHU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_ADD;
                        end
                        CTRL_LB: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_ADD;
                        end
                        CTRL_LBU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_ADD;
                        end
                        CTRL_SW: begin
                            alu_en_o = 1'b1; 
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset; 
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_ADD;

                            // Read RS2 for storing
                            reg_file_en_o = 1'b1;
                            reg_file_addr_mux_sel_o =  sel_reg_file_rs2;
                            reg_file_rw_o = read;
                        end
                        CTRL_SH: begin
                            alu_en_o = 1'b1; 
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset; 
                            alu_b_mux_sel_o = sel_reg_file_rs1;
                            alu_opr_o = ALU_ADD;
                            
                            // Read RS2 for storing
                            reg_file_en_o = 1'b1;
                            reg_file_addr_mux_sel_o =  sel_reg_file_rs2;
                            reg_file_rw_o = read;
                        end
                        CTRL_SB: begin
                            alu_en_o = 1'b1; 
                            alu_a_mux_sel_o = sel_alu_sign_ext_offset; 
                            alu_b_mux_sel_o = sel_reg_file_rs1;
                            alu_opr_o = ALU_ADD; 

                            // Read RS2 for storing
                            reg_file_en_o = 1'b1;
                            reg_file_addr_mux_sel_o =  sel_reg_file_rs2;
                            reg_file_rw_o = read;
                        end
                        CTRL_MUL: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_MUL;
                        end
                        CTRL_MULH: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_MULH;
                        end
                        CTRL_MULHU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_MULHU;
                        end
                        CTRL_MULHSU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_MULHSU;
                        end
                        CTRL_DIV: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_DIV;
                        end
                        CTRL_DIVU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_DIVU;
                        end
                        CTRL_REM: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_REM;
                        end
                        CTRL_REMU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = ALU_REMU;
                        end
                        default: begin
                            // UGLY : Fill default condition
                        end
                    endcase
                end
            end
            WRITE_RD: begin
                reg_file_en_o = 1'b1;
                reg_file_addr_mux_sel_o =  sel_reg_file_rd;
                reg_file_rw_o = write;
                if (current_instruction inside {CTRL_LW,CTRL_LH,CTRL_LHU,CTRL_LB,CTRL_LBU})
                    reg_file_data_mux_sel_o =  sel_reg_file_data_mem;
                else if (current_instruction inside {CTRL_JAL, CTRL_JALR})
                    reg_file_data_mux_sel_o = sel_reg_file_pc;
                else if (current_instruction == CTRL_LUI)
                    reg_file_data_mux_sel_o =  sel_reg_file_decoder;
                else if (current_instruction inside {CTRL_CSRRS, CTRL_CSRRW, CTRL_CSRRC, CTRL_CSRRWI, CTRL_CSRRSI, CTRL_CSRRCI})
                    reg_file_data_mux_sel_o = sel_reg_file_csr;
                else
                    reg_file_data_mux_sel_o =  sel_reg_file_alu;
            end
            LOAD_FROM_DATA_MEM: begin
                data_mem_en_o = 1'b1;
                data_mem_rw_o = read;
                case (current_instruction)
                    CTRL_LW :  data_mem_transfer_type_o = transfer_word;
                    CTRL_LH :  data_mem_transfer_type_o = transfer_hex_byte;
                    CTRL_LHU :  data_mem_transfer_type_o = transfer_hex_byte;
                    CTRL_LB :  data_mem_transfer_type_o = transfer_byte;
                    CTRL_LBU :  data_mem_transfer_type_o = transfer_byte;
                    default: data_mem_transfer_type_o = 'd0;
                endcase
            end
            STORE_DATA_MEM: begin
                data_mem_en_o = 1'b1;
                data_mem_rw_o = write;
                case (current_instruction)
                    CTRL_SW :  data_mem_transfer_type_o = transfer_word;
                    CTRL_SH :  data_mem_transfer_type_o = transfer_hex_byte;
                    CTRL_SB :  data_mem_transfer_type_o = transfer_hex_byte;
                    default: data_mem_transfer_type_o = 'd0;
                endcase
            end
            JUMP_PC: begin
                pc_en_o = 1'b1;
                if (interrupt_i == 1'b1) begin
                    interrupt_ack_o = 1'b1;
                    pc_mux_sel_o = sel_pc_int_hnd;
                end else begin
                    if (current_instruction inside {CTRL_JAL, CTRL_JALR, CTRL_BEQ, CTRL_BGE, CTRL_BGEU, CTRL_BLT, CTRL_BLTU, CTRL_BNE})
                        pc_mux_sel_o = sel_pc_update;
                    else
                        pc_mux_sel_o = sel_pc_jump_vec;
                end
            end
            READ_CSR: begin
                csr_en_o = 1'b1;
                csr_rw_o = read;
                csr_addr_mux_sel_o = sel_csr_addr_decoder;
            end
            WRITE_CSR: begin
                csr_en_o = 1'b1;
                csr_rw_o = write;
                csr_addr_mux_sel_o =  sel_csr_addr_decoder;
                case (current_instruction)
                    CTRL_CSRRW: csr_write_type_o = write_complete;
                    CTRL_CSRRS: csr_write_type_o = write_set;
                    CTRL_CSRRC: csr_write_type_o = write_clear;
                    CTRL_CSRRWI: csr_write_type_o = write_complete;
                    CTRL_CSRRSI: csr_write_type_o = write_set;
                    CTRL_CSRRCI: csr_write_type_o = write_clear;
                    default: csr_write_type_o = 'd0;
                endcase
            end
            WRITE_MCAUSE: begin
                csr_en_o = 1'b1;
                csr_rw_o = write;
                csr_addr_mux_sel_o =  sel_csr_addr_ctrl_unit;
                csr_addr_from_ctrl_o =  CSR_mcause;
                csr_data_mux_sel_o =  sel_csr_data_ctrl_unit;
                if (interrupt_i == 1'b1) begin
                    csr_data_from_ctrl_o = cause_interrupt;
                end else begin
                    case (current_instruction)
                        CTRL_ECALL: csr_data_from_ctrl_o = cause_ecall;
                        CTRL_EBREAK:csr_data_from_ctrl_o =  cause_break;
                        default: csr_data_from_ctrl_o = cause_illegal_instruction;
                    endcase
                end
            end
            WRITE_MEPC: begin
                csr_en_o = 1'b1;
                csr_rw_o = write;
                csr_addr_mux_sel_o =  sel_csr_addr_ctrl_unit;
                csr_addr_from_ctrl_o =  CSR_mepc;
                csr_data_mux_sel_o =  sel_csr_data_pc;
            end
            READ_MTVEC_MEPC: begin
                csr_en_o = 1'b1;
                csr_rw_o = read;
                csr_addr_mux_sel_o =  sel_csr_addr_ctrl_unit;
                if (current_instruction == CTRL_MRET)
                    csr_addr_from_ctrl_o =  CSR_mepc;
                else 
                    csr_addr_from_ctrl_o =  CSR_mtvec;
            end
            default: begin
                // UGLY : Fill default condition
            end
        endcase
    end
endmodule