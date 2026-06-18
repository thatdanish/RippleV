`timescale 1ns/1ns
`default_nettype none

module ctrl_unit_v2 (
    // External
    input clk_i,
    input rst_i,
    input main_enable_i,
    output logic interrupt_ack_o,
    // CSR
    input interrupt_i,
    output typed_pkg::csr_addr_t csr_addr_from_ctrl_o, 
    output typed_pkg::sel_csr_addr_t csr_addr_mux_sel_o, 
    output typed_pkg::sel_csr_data_t csr_data_mux_sel_o, 
    output typed_pkg::write_t csr_write_type_o, 
    output typed_pkg::rw_t csr_rw_o, 
    output logic csr_en_o, 
    output logic [31:0] csr_data_from_ctrl_o, 
    // Instruction Memory
    output inst_mem_en_o,
    // Reg-file v2
    output typed_pkg::sel_reg_file_addr_t reg_file_addr_mux_sel_o,
    output typed_pkg::sel_reg_file_data_t reg_file_data_mux_sel_o,
    output logic reg_file_read_en_o,
    output logic reg_file_write_en_o,
    // ALU
    output typed_pkg::alu_opr_t alu_opr_o,
    output typed_pkg::sel_alu_a_t alu_a_mux_sel_o,
    output typed_pkg::sel_alu_b_t alu_b_mux_sel_o,
    input take_branch_i, 
    output logic alu_en_o, 
    // Branch logic
    output typed_pkg::alu_opr_t bl_opr_o,
    output logic branch_logic_en_o,
    // Data Memory
    output typed_pkg::transfer_t data_mem_transfer_type_o,
    output typed_pkg::rw_t data_mem_rw_o,
    output typed_pkg::load_t data_mem_load_type_o, 
    output logic data_mem_en_o,
    // HCU
    output typed_pkg::instruction_type_t hcu_inst_type_o
);

    import typed_pkg::*;

    typedef enum bit[3:0] { OUTPUTS_OFF, OUTPUTS_I_TYPE, OUTPUTS_R_TYPE, OUTPUTS_LS_TYPE, 
                        OUTPUTS_CJ_TYPE , OUTPUTS_UCJ_TYPE, OUTPUTS_CSR_TYPE, OUTPUTS_ECALL,
                        OUTPUTS_MRET, OUTPUTS_WFI, OUTPUTS_INCORRECT_INST } asserted_output_t;

    asserted_outputs_t current_asserted_outputs;
    ctrl_inst_t current_instruction;  

    always_ff @( posedge clk_i) begin
        if (!rst_i) begin
            current_asserted_outputs <= OUTPUTS_OFF;
            current_instruction <= ctrl_inst_t'('d0);
        end else begin
            current_instruction <= instruction_i;
            if (main_enable_i == 1'b1 && interrupt_i == 1'b0) begin
                case (instruction_i)
                    CTRL_ADDI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_SLTI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_SLTIU: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_ANDI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_ORI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_XORI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_SLLI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_SRLI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_SRAI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_LUI: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_AUIPC: current_asserted_outputs  = OUTPUTS_I_TYPE;
                    CTRL_ADD: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_SUB: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_SLTU: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_SLT: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_AND: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_OR: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_XOR: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_SLL: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_SRL: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_SRA: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_JAL: current_asserted_outputs  = OUTPUTS_UCJ_TYPE;
                    CTRL_JALR: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_BEQ: current_asserted_outputs  = OUTPUTS_CJ_TYPE;
                    CTRL_BNE: current_asserted_outputs  = OUTPUTS_CJ_TYPE;
                    CTRL_BGE: current_asserted_outputs  = OUTPUTS_CJ_TYPE;
                    CTRL_BLT: current_asserted_outputs  = OUTPUTS_CJ_TYPE;
                    CTRL_BLTU: current_asserted_outputs  = OUTPUTS_CJ_TYPE;
                    CTRL_BGEU: current_asserted_outputs  = OUTPUTS_CJ_TYPE;
                    CTRL_LW: current_asserted_outputs  = OUTPUTS_LS_TYPE;
                    CTRL_LH: current_asserted_outputs  = OUTPUTS_LS_TYPE;
                    CTRL_LHU: current_asserted_outputs  = OUTPUTS_LS_TYPE;
                    CTRL_LB: current_asserted_outputs  = OUTPUTS_LS_TYPE;
                    CTRL_LBU: current_asserted_outputs  = OUTPUTS_LS_TYPE;
                    CTRL_SW: current_asserted_outputs  = OUTPUTS_LS_TYPE;
                    CTRL_SH: current_asserted_outputs  = OUTPUTS_LS_TYPE;
                    CTRL_SB: current_asserted_outputs  = OUTPUTS_LS_TYPE;
                    CTRL_MUL: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_MULH: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_MULHU: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_MULHSU: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_DIV: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_DIVU: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_REM: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_REMU: current_asserted_outputs  = OUTPUTS_R_TYPE;
                    CTRL_CSRRW: current_asserted_outputs = OUTPUTS_CSR_TYPE;
                    CTRL_CSRRS: current_asserted_outputs = OUTPUTS_CSR_TYPE;
                    CTRL_CSRRC: current_asserted_outputs = OUTPUTS_CSR_TYPE;
                    CTRL_CSRRWI: current_asserted_outputs = OUTPUTS_CSR_TYPE;
                    CTRL_CSRRSI: current_asserted_outputs = OUTPUTS_CSR_TYPE;
                    CTRL_CSRRCI: current_asserted_outputs = OUTPUTS_CSR_TYPE;
                    CTRL_FENCE: current_asserted_outputs = OUTPUTS_OFF;
                    CTRL_ECALL: current_asserted_outputs = OUTPUTS_ECALL;
                    CTRL_MRET: current_asserted_outputs  = OUTPUT_MRET;
                    CTRL_WFI: current_asserted_outputs = OUTPUT_WFI;
                    default: current_asserted_outputs = OUTPUTS_INCORRECT_INST;
                endcase
            end else if (interrupt_i == 1'b1) 
                // TODO: Implement interrupt handling
                current_asserted_outputs <= OUTPUTS_OFF;
            else
                current_asserted_outputs <= OUTPUTS_OFF;
        end
    end

    always_comb begin 

        // External
        interrupt_ack_o = 1'b0;
        // CSR  
        csr_rw_o = rw_t'(1'b0); 
        csr_addr_from_ctrl_o = csr_addr_t'('d0); 
        csr_addr_mux_sel_o = sel_csr_addr_t'('d0);
        csr_data_mux_sel_o = sel_csr_data_t'('d0);
        csr_write_type_o = write_t'('d0);
        csr_en_o = 1'b0; 
        csr_data_from_ctrl_o = 'd0; 
        // PC
        pc_mux_sel_o = sel_pc_t'('d0);
        pc_en_o = 1'b0;
        // Inst-mem
        inst_mem_en_o = 1'b0;      
        // Reg file V2
        reg_file_read_en_o = 1'b0;
        reg_file_write_en_o = 1'b0;
        reg_file_addr_mux_sel_o = sel_reg_file_addr_t'('b0);
        reg_file_data_mux_sel_o = sel_reg_file_data_t'('b0);
        // ALU
        alu_a_mux_sel_o = sel_alu_a_t'('d0);
        alu_b_mux_sel_o = sel_alu_b_t'('d0);
        alu_opr_o = alu_opr_t'('b0);
        alu_en_o = 1'b0;
        // Branch logic
        bl_opr_o = alu_opr_t'('b0);
        branch_logic_en_o = 1'b0;
        // Data-mem
        data_mem_rw_o = rw_t'(1'b0);
        data_mem_transfer_type_o = transfer_t'(2'b0);
        data_mem_load_type_o = load_t'('d0);
        data_mem_en_o = 1'b0;
        // HCU
        hcu_inst_type_o = instruction_type_t'('d0);
        // ALU operations
        case (current_instruction)
            CTRL_ADDI: alu_opr_o = ALU_ADD;
            CTRL_SLTI: alu_opr_o = ALU_SLT;
            CTRL_SLTIU: alu_opr_o = ALU_SLTU;
            CTRL_ANDI: alu_opr_o = ALU_AND;
            CTRL_ORI: alu_opr_o = ALU_OR;
            CTRL_XORI: alu_opr_o = ALU_XOR;
            CTRL_SLLI: alu_opr_o = ALU_SLL;
            CTRL_SRLI: alu_opr_o = ALU_SRL;
            CTRL_SRAI: alu_opr_o = ALU_SRA;
            CTRL_AUIPC: alu_opr_o = ALU_JAL;
            CTRL_ADD: alu_opr_o = ALU_ADD;
            CTRL_SUB: alu_opr_o = ALU_SUB;
            CTRL_SLTU: alu_opr_o = ALU_SLTU;
            CTRL_SLT: alu_opr_o = ALU_SLT;
            CTRL_AND: alu_opr_o = ALU_AND;
            CTRL_OR: alu_opr_o = ALU_OR;
            CTRL_XOR: alu_opr_o = ALU_XOR;
            CTRL_SLL: alu_opr_o = ALU_SLL;
            CTRL_SRL: alu_opr_o = ALU_SRL;
            CTRL_SRA: alu_opr_o = ALU_SRA;
            CTRL_JAL: alu_opr_o = ALU_JAL; // FIXME : Assign correct alu_opr_o 
            CTRL_JALR: alu_opr_o = ALU_JALR; // FIXME : Assign correct alu_opr_o 
            CTRL_BEQ: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_BNE: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_BGE: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_BLT: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_BLTU: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_BGEU: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_LW: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_LH: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_LHU: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_LB: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_LBU: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_SW: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_SH: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_SB: alu_opr_o = ALU_ADD; // FIXME : Assign correct alu_opr_o 
            CTRL_MUL: alu_opr_o = ALU_MUL;
            CTRL_MULH: alu_opr_o = ALU_MULH;
            CTRL_MULHU: alu_opr_o = ALU_MULHU;
            CTRL_MULHSU: alu_opr_o = ALU_MULHSU;
            CTRL_DIV: alu_opr_o = ALU_DIV;
            CTRL_DIVU: alu_opr_o = ALU_DIVU;
            CTRL_REM: alu_opr_o = ALU_REM;
            CTRL_REMU: alu_opr_o = ALU_REMU;
        endcase

        case (current_asserted_outputs)
            OUTPUTS_OFF: begin
                // UGLY : Empty condition
            end 
            OUTPUTS_I_TYPE: begin
                // Read RS1
                reg_file_read_en_o = 1'b1;

                // Inform HCU
                hcu_inst_type_o = HCU_I_type;

                // Compute @ ALU - mux a, b
                alu_en_o = 1'b1;
                alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                alu_b_mux_sel_o = sel_alu_rs1;

                // Write RD
                reg_file_write_en_o = 1'b1;  

                // Update PC -> PC+4    
                branch_logic_en_o = 1'b1;
            end 
            OUTPUTS_R_TYPE: begin
                // Read RS1
                reg_file_read_en_o = 1'b1;

                // Inform HCU
                hcu_inst_type_o = HCU_R_type;

                // Compute @ ALU - mux a, b
                alu_en_o = 1'b1;
                alu_a_mux_sel_o = sel_alu_rs2;
                alu_b_mux_sel_o = sel_alu_rs1;

                // Write RD
                reg_file_write_en_o = 1'b1;  

                // Update PC -> PC+4    
                branch_logic_en_o = 1'b1;
            end 
            OUTPUTS_LS_TYPE: begin
                // Read RS1 (LOAD & STORE), RS2 (STORE)
                reg_file_read_en_o = 1'b1;

                // Inform HCU
                hcu_inst_type_o = HCU_LS_type;
                
                // Address gen @ ALU - mux a, b
                alu_en_o = 1'b1;
                alu_a_mux_sel_o = sel_alu_sign_ext_offset;
                alu_b_mux_sel_o = sel_alu_rs1;

                // Write RD (LOAD), Read/Write from data-mem
                data_mem_en_o = 1'b1;

                case (current_instruction)
                    CTRL_LW: begin
                        reg_file_write_en_o = 1'b1;
                        data_mem_rw_o = read;
                        data_mem_load_type_o = load_signed;
                        data_mem_transfer_type_o = transfer_word;
                    end
                    CTRL_LH: begin
                        reg_file_write_en_o = 1'b1;
                        data_mem_rw_o = read;
                        data_mem_load_type_o = load_signed;
                        data_mem_transfer_type_o = transfer_hex_byte;
                    end
                    CTRL_LHU: begin
                        reg_file_write_en_o = 1'b1;
                        data_mem_rw_o = read;
                        data_mem_load_type_o = load_unsigned;
                        data_mem_transfer_type_o = transfer_hex_byte;
                    end
                    CTRL_LB: begin
                        reg_file_write_en_o = 1'b1;
                        data_mem_rw_o = read;
                        data_mem_load_type_o = load_signed;
                        data_mem_transfer_type_o = transfer_byte;
                    end
                    CTRL_LBU: begin
                        reg_file_write_en_o = 1'b1;
                        data_mem_rw_o = read;
                        data_mem_load_type_o = load_unsigned;
                        data_mem_transfer_type_o = transfer_byte;
                    end
                    CTRL_SW: begin
                        data_mem_rw_o = write;
                        data_mem_transfer_type_o = transfer_word;
                    end
                    CTRL_SH: begin
                        data_mem_rw_o = write;
                        data_mem_transfer_type_o = transfer_hex_byte;
                    end
                    CTRL_SB: begin
                        data_mem_rw_o = write;
                        data_mem_transfer_type_o = transfer_byte;
                    end
                endcase

                // Update PC -> PC+4    
                branch_logic_en_o = 1'b1;
            end  
            OUTPUTS_UCJ_TYPE: begin
                // Read RS1 (JALR)
                reg_file_read_en_o = 1'b1;

                // Inform HCU
                hcu_inst_type_o = HCU_UCJ_type;

                // Jump PC gen @ BL - mux a, b
                branch_logic_en_o = 1'b1;
                if (current_instruction == CTRL_JAL) begin
                    bl_opr_o = ALU_JAL;
                end else begin
                    bl_opr_o = ALU_JALR;
                end
                
                // Write (PC+4) to RD 
                // Todo : check if pc + 4 is automatically available
                reg_file_write_en_o = 1'b1; 
            end 
            OUTPUTS_CJ_TYPE: begin
                // Read RS1, RS2
                reg_file_read_en_o = 1'b1;

                // Inform HCU
                hcu_inst_type_o = HCU_CJ_type;

                // Check for branch @ BL
                branch_logic_en_o = 1'b1;
    
                case (current_instruction)
                    CTRL_BEQ: begin
                        bl_opr_o = ALU_BEQ;
                    end 
                    CTRL_BNE: begin
                        bl_opr_o = ALU_BNE;
                    end 
                    CTRL_BLT: begin
                        bl_opr_o = ALU_BLT;
                    end 
                    CTRL_BLTU: begin
                        bl_opr_o = ALU_BLTU;
                    end 
                    CTRL_BGE: begin
                        bl_opr_o = ALU_BGE
                    end 
                    CTRL_BGEU: begin
                        bl_opr_o = ALU_BGEU
                    end 
                endcase
            end 
            OUTPUTS_CSR_TYPE: begin
                // Read RS1
                reg_file_read_en_o = 1'b1;

                // Inform HCU
                hcu_inst_type_o = HCU_CSR_type;

     
                // Write RD
                reg_file_write_en_o = 1'b1;  

                // Update PC -> PC+4    
                branch_logic_en_o = 1'b1;
            end 
            OUTPUTS_ECALL: begin
                
            end 
            OUTPUTS_MRET: begin
                
            end 
            OUTPUTS_WFI: begin
                
            end 
            OUTPUTS_INCORRECT_INST: begin
                
            end 
            default:
        endcase
    end
endmodule