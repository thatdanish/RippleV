`timescale 1ns/1ns
`default_nettype none

module ctrl_unit(
    // External
    input clk_i,
    input rst_i,
    input main_enable_i, 
    // CSR
    input interrupt_i,
    // Decoder
    input logic [5:0] instruction_i,
    // PC
    output logic [1:0] pc_mux_sel_o, 
    output logic pc_en_o
    // Housekeeper
    output logic housekeeper_en_o, 
    output logic [1:0] housekeeper_task_o,
    // Instruction Memory
    output inst_mem_en_o,
    // Reg-file
    output logic [1:0] reg_file_addr_mux_sel_o,
    output logic [1:0] reg_file_data_mux_sel_o,
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
    output data_mem_rw_o,

);

    import Opcodes_pkg::*;
    import sel_pkg::*;

    typedef enum bit[3:0] { RESET_TRIGGER, UPDATE_PC_AFTER_RESET, IDLE, TAKE_BRANCH, INST_START, READ_RS1, READ_RS2,
                            WRITE_RD, LOAD_FROM_DATA_MEM, STORE_DATA_MEM} state_t;
    
    state_t current_state, next_state;
    logic take_branch_delayed;

    always_ff @( posedge clk_i ) begin : StateUpdateBlock
        if (!rst_i) begin
            current_state <= RESET_TRIGGER;
            take_branch_delayed <= 1'b0;
        end else begin
            current_state <= next_state;
            take_branch_delayed <= take_branch_i;
        end
    end

    always_comb begin : NextStateComputeBlock
        next_state = IDLE;
        case (current_state)
            RESET_TRIGGER: begin
                // make core come out of reset
                next_state = UPDATE_PC_AFTER_RESET;
            end
            UPDATE_PC_AFTER_RESET : begin
                next_state = IDLE; 
            end
            IDLE: begin
                if (interrupt_i == 1'b1) next_state = (main_enable_i == 1'b1) ? INST_START : IDLE; 
                else next_state = IDLE;
            end
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
                    // TODO : Implement MRET, WFI
                    // CTRL_MRET: next_state  = 
                    // CTRL_WFI: next_state = 
                    default: next_state = IDLE;
                endcase
            end
            READ_RS2: begin
                next_state = READ_RS1;
            end
            READ_RS1: begin
                next_state = ALU_COMPUTE;
            end
            ALU_COMPUTE: begin
                if (instruction_i inside {CTRL_LW,CTRL_LH,CTRL_LHU,CTRL_LB,CTRL_LBU}) 
                    next_state = LOAD_FROM_DATA_MEM;
                else if (instruction_i inside {CTRL_SW,CTRL_SH,CTRL_SB})
                    next_state = STORE_DATA_MEM;
                else if (instruction_i inside {CTRL_BEQ, CTRL_BGE, CTRL_BGEU, CTRL_BLT, CTRL_BLTU, CTRL_BNE})
                    if (take_branch_i == 1'b1 && take_branch_delayed == 1'b0) 
                        next_state = ALU_COMPUTE;
                    else if (take_branch_i == 1'b0 && take_branch_delayed == 1'b1) 
                        next_state = TAKE_BRANCH;
                    else
                        next_state = IDLE;
                else if (instruction_i inside {CTRL_JAL, CTRL_JALR})
                    next_state = TAKE_BRANCH;
                else 
                    next_state = WRITE_RD;
            end
            WRITE_RD: begin
                if (instruction_i == CTRL_JAL) 
                    next_state = ALU_COMPUTE;
                else if (instruction_i == CTRL_JALR)
                    next_state = READ_RS1;
                else
                    next_state = IDLE;
            end
            LOAD_FROM_DATA_MEM: begin
                next_state = WRITE_RD;
            end
            STORE_DATA_MEM: begin
                next_state = IDLE;
            end
            TAKE_BRANCH: begin
                next_state =  IDLE;
            end
            default: begin
               // TODO : Fill default condition
            end
        endcase
        
    end
    
    always_comb begin : OutputBlock
        // Housekeeper 
        housekeeper_en_o = 1'b0;
        housekeeper_task_o = 'd0;
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

        case (current_state)
            RESET_TRIGGER: begin
                // make core come out of reset
                housekeeper_en_o = 1'b1;
                housekeeper_task_o = task_reset;
            end
            UPDATE_PC_AFTER_RESET : begin
                pc_en_o = 1'b1;
                pc_mux_sel_o = sel_pc_handler_addr;
            end
            IDLE: begin
                if (main_enable_i == 1'b1 && interrupt_i == 1'b0) begin
                    inst_mem_en_o = 1'b1;    
                    // Update PC
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
                    case (instruction_i)
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
                            alu_b_mux_sel_o = sel_alu_pc
                            alu_opr_o = ALU_JAL;
                        end
                        CTRL_ADD: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_ADD;
                        end
                        CTRL_SUB: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_SUB;
                        end
                        CTRL_SLTU: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_SLTU;
                        end
                        CTRL_SLT: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_SLT;
                        end
                        CTRL_AND: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_AND;
                        end
                        CTRL_OR: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_OR;
                        end
                        CTRL_XOR: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_XOR;
                        end
                        CTRL_SLL: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_SLL;
                        end
                        CTRL_SRL: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_SRL;
                        end
                        CTRL_SRA: begin
                            alu_en_o = 1'b1;
                            alu_a_mux_sel_o = sel_alu_rs2;
                            alu_b_mux_sel_o = sel_alu_rs1;
                            alu_opr_o = CTRL_SRA;
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
                            alu_opr_o = ALU_JAL;
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
                            alu_b_mux_sel_o = sel_reg_file_rs1;
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
                        // TODO : Implement MRET, WFI
                        // CTRL_MRET: begin
                        //     alu_en_o =
                        //     alu_a_mux_sel_o =
                        //     alu_b_mux_sel_o = 
                        //     alu_opr_o = 
                        // end
                        // CTRL_WFI : begin
                        //     alu_en_o = 
                        //     alu_a_mux_sel_o = 
                        //     alu_b_mux_sel_o = 
                        //     alu_opr_o = 
                        // end
                        default: begin
                            // TODO : Fill default condition
                        end
                    endcase
                end
            end
            WRITE_RD: begin
                reg_file_en_o = 1'b1;
                reg_file_addr_mux_sel_o =  sel_reg_file_rd;
                reg_file_rw_o = write;
                if (instruction_i inside {CTRL_LW,CTRL_LH,CTRL_LHU,CTRL_LB,CTRL_LBU})
                    reg_file_data_mux_sel_o =  sel_reg_file_data_mem;
                else if (instruction_i inside {CTRL_JAL, CTRL_JALR})
                    reg_file_data_mux_sel_o = sel_reg_file_pc;
                else if (instruction_i == CTRL_LUI)
                    reg_file_data_mux_sel_o =  sel_reg_file_decoder;
                else
                    reg_file_data_mux_sel_o =  sel_reg_file_alu;
            end
            LOAD_FROM_DATA_MEM: begin
                data_mem_en_o = 1'b1;
                rw_data_mem_o = read;
            end
            STORE_DATA_MEM: begin
                data_mem_en_o = 1'b1;
                rw_data_mem_o = write;
            end
            TAKE_BRANCH: begin
                pc_mux_sel_o = sel_pc_update
                pc_en_o = 1'b1;
            end
            default: begin
                // TODO : Fill default condition
            end
        endcase
    end
   
endmodule