`timescale 1ns/1ns
`default_nettype none

module Decoderv2 (
    input clk_i,
    input rst_i,
    input stall_id_i, 
    input logic [31:0] inst_i,
    output logic [4:0] rd_o,
    output logic [4:0] rs1_o,
    output logic [4:0] rs2_o,
    output typed_pkg::csr_addr_t csr_addr_o,
    output logic [31:0] imm_offset_o,
    output logic [31:0] lui_o,
    output typed_pkg::ctrl_inst_t inst_to_ctrl_o,
    output typed_pkg::instruction_type_t hcu_inst_type_o
);
    import Opcodes_pkg::*;
    import typed_pkg::*;
    
logic [31:0] current_instruction;
logic [6:0] op_code, funct_7;
logic [2:0] funct_3;

assign rd_o = current_instruction[11:7];
assign rs1_o = current_instruction[19:15];
assign rs2_o = current_instruction[24:20];

assign csr_addr_o = csr_addr_t'(current_instruction[31:20]);

assign lui_o = {current_instruction[31:12], 12'd0};

assign op_code = inst_i[6:0];
assign funct_3 = inst_i[14:12];
assign funct_7 = inst_i[31:25];

always_ff @( posedge clk_i ) begin 
    if(!rst_i) begin
        inst_to_ctrl_o <= ctrl_inst_t'('d0);
        current_instruction <= 'd0;
    end else begin
        current_instruction <= ( stall_id_i == 1'b1 ) ? current_instruction : inst_i;
        case (inst_i)
            MRET: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_MRET;
            WFI: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_WFI;
            ECALL: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_ECALL;
            EBREAK: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_EBREAK;
            default: begin
                case (op_code)
                    LUI : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_LUI;
                    AUIPC : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_AUIPC;
                    JAL : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_JAL;
                    JALR : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_JALR;
                    CJ :  begin
                        case (funct_3)
                            BEQ : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_BEQ;
                            BNE : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_BNE;
                            BGE : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_BGE;
                            BLT : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_BLT;
                            BLTU : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_BLTU;
                            BGEU : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_BGEU;
                            default: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                        endcase
                    end
                    LOAD :  begin
                        case (funct_3)
                            LB : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_LB;
                            LH : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_LH;
                            LW : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_LW;
                            LBU : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_LBU;
                            LHU : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_LHU;
                            default: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                        endcase
                    end
                    STORE :  begin
                        case (funct_3)
                            SB : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SB;
                            SH : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SH;
                            SW : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SW;
                            default: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                        endcase
                    end
                    IMM_T :  begin
                        case (funct_3)
                            ADDI : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_ADDI;
                            SLTI : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SLTI;
                            SLTIU : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SLTIU;
                            XORI : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_XORI;
                            ORI : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_ORI;
                            ANDI : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_ANDI;
                            SLLI : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SLLI;
                            SRLI_SRAI : begin
                                if (funct_7 == SRLI_F7) inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SRLI;
                                else inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SRAI;
                            end
                            default: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                        endcase
                    end
                    REG_T :  begin
                        case (funct_3)
                            ADD_SUB_MUL : begin
                                case (funct_7)
                                    ADD_F7 : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_ADD;
                                    SUB_F7 : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SUB;
                                    MUL_F7 : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_MUL;
                                    default: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                                endcase
                            end 
                            SLL_MULH : begin
                            if (funct_7 == SLL_F7) inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SLL;
                            else inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_MULH;
                            end
                            SLT_MULHSU : begin
                                if (funct_7 == SLT_F7) inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SLT;
                                else inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_MULHSU;
                            end
                            SLTU_MULHU : begin
                            if (funct_7 == SLTU_F7) inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SLTU;
                            else inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_MULHU;
                            end
                            XOR_DIV : begin
                            if (funct_7 == XOR_F7) inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_XOR;
                            else inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_DIV;
                            end
                            SRL_SRA_DIVU : begin
                                case (funct_7)
                                    SRL_F7 : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SRL;
                                    SRA_F7 : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_SRA;
                                    DIVU_F7 : inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_DIVU;
                                    default: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                                endcase
                            end
                            OR_REM : begin
                            if (funct_7 == OR_F7) inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_OR;
                            else inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_REM;
                            end
                            AND_REMU : begin
                            if (funct_7 == AND_F7) inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_AND;
                            else inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_REMU;
                            end
                            default: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                        endcase
                    end
                    ZICSR: begin
                        case (funct_3)
                            CSRRW: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_CSRRW;
                            CSRRS: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_CSRRS;
                            CSRRC: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_CSRRC;
                            CSRRWI: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_CSRRWI;
                            CSRRSI: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_CSRRSI;
                            CSRRCI: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_CSRRCI;
                            default:  inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                        endcase
                    end
                    FENCE: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : CTRL_FENCE;
                    default: inst_to_ctrl_o <= (stall_id_i == 1'b1) ? inst_to_ctrl_o : ctrl_inst_t'('d0);
                endcase
            end
        endcase
    end
end

always_comb begin : ImmOutputBlock
    case (inst_to_ctrl_o)
        CTRL_ADDI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_SLTI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_SLTIU: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_ANDI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_ORI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_XORI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_SLLI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = 32'(current_instruction[24:20]);
        end
        CTRL_SRLI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = 32'(current_instruction[24:20]);
        end
        CTRL_SRAI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = 32'(current_instruction[24:20]);
        end
        CTRL_LUI: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = {current_instruction[31:12], 12'd0};
        end
        CTRL_AUIPC: begin
            hcu_inst_type_o = HCU_I_type;
            imm_offset_o = {current_instruction[31:12], 12'd0};
        end
        CTRL_ADD: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_SUB: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_SLTU: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_SLT: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_AND: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_OR: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_XOR: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_SLL: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_SRL: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_SRA: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_JAL: begin
            hcu_inst_type_o = HCU_UCJ_type;
            imm_offset_o = (current_instruction[31] == 1) ? {11'hFFF, {current_instruction[31], current_instruction[19:12], current_instruction[20], current_instruction[30:21], 1'b0}} : {11'b0, {current_instruction[31], current_instruction[19:12], current_instruction[20], current_instruction[30:21], 1'b0}};
        end
        CTRL_JALR: begin
            hcu_inst_type_o = HCU_UCJ_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_BEQ: begin
            hcu_inst_type_o = HCU_CJ_type;
            imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        end
        CTRL_BNE: begin
            hcu_inst_type_o = HCU_CJ_type;
            imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        end
        CTRL_BGE: begin
            hcu_inst_type_o = HCU_CJ_type;
            imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        end
        CTRL_BLT: begin
            hcu_inst_type_o = HCU_CJ_type;
            imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        end
        CTRL_BLTU: begin
            hcu_inst_type_o = HCU_CJ_type;
            imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        end
        CTRL_BGEU: begin
            hcu_inst_type_o = HCU_CJ_type;
            imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        end
        CTRL_LW: begin
            hcu_inst_type_o = HCU_LOAD_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_LH: begin
            hcu_inst_type_o = HCU_LOAD_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_LHU: begin
            hcu_inst_type_o = HCU_LOAD_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_LB: begin
            hcu_inst_type_o = HCU_LOAD_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_LBU: begin
            hcu_inst_type_o = HCU_LOAD_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_SW: begin
            hcu_inst_type_o = HCU_STORE_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:25], current_instruction[11:7]} : {20'b0, current_instruction[31:25], current_instruction[11:7]};
        end
        CTRL_SH: begin
            hcu_inst_type_o = HCU_STORE_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:25], current_instruction[11:7]} : {20'b0, current_instruction[31:25], current_instruction[11:7]};
        end
        CTRL_SB: begin
            hcu_inst_type_o = HCU_STORE_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:25], current_instruction[11:7]} : {20'b0, current_instruction[31:25], current_instruction[11:7]};
        end
        CTRL_MUL: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        end
        CTRL_MULH: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_MULHU: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_MULHSU: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_DIV: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_DIVU: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_REM: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_REMU: begin
            hcu_inst_type_o = HCU_R_type;
            imm_offset_o = 'd0;
        end
        CTRL_MRET: begin
            hcu_inst_type_o = HCU_mret;
            imm_offset_o = 'd0;
        end
        CTRL_WFI: begin
            hcu_inst_type_o = HCU_wfi;
            imm_offset_o = 'd0;
        end
        CTRL_ECALL: begin
            hcu_inst_type_o = HCU_ecall;
            imm_offset_o = 'd0;
        end
        CTRL_EBREAK: begin
            hcu_inst_type_o = HCU_trap;
            imm_offset_o = 'd0;
        end
        CTRL_CSRRW: begin
            hcu_inst_type_o = HCU_CSR_type;
            imm_offset_o = 'd0; 
        end
        CTRL_CSRRS: begin
            hcu_inst_type_o = HCU_CSR_type;
            imm_offset_o = 'd0; 
        end
        CTRL_CSRRC: begin
            hcu_inst_type_o = HCU_CSR_type;
            imm_offset_o = 'd0; 
        end
        CTRL_CSRRWI: begin
            hcu_inst_type_o = HCU_CSR_type;
            imm_offset_o = 32'(current_instruction[19:15]); 
        end
        CTRL_CSRRSI: begin
            hcu_inst_type_o = HCU_CSR_type;
            imm_offset_o = 32'(current_instruction[19:15]); 
        end
        CTRL_CSRRCI:begin
            hcu_inst_type_o = HCU_CSR_type;
            imm_offset_o = 32'(current_instruction[19:15]); 
        end
        default: begin
            hcu_inst_type_o = instruction_type_t'('d0);
            imm_offset_o = 'd0;
        end
    endcase
end


endmodule