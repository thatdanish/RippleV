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
    output typed_pkg::ctrl_inst_t inst_to_ctrl_o
);
    import Opcodes_pkg::*;
    import typed_pkg::*;
    
logic [31:0] current_instruction;
logic [6:0] op_code, funct_7;
logic [2:0] funct_3;

assign rd_o = inst_i[11:7];
assign rs1_o = inst_i[19:15];
assign rs2_o = inst_i[24:20];

assign csr_addr_o = csr_addr_t'(inst_i[31:20]);

assign lui_o = {inst_i[31:12], 12'd0};

assign op_code = inst_i[6:0];
assign funct_3 = inst_i[14:12];
assign funct_7 = inst_i[31:25];

always_ff @( posedge clk_i ) begin 
    if(!rst_i) begin
        inst_to_ctrl_o <= ctrl_inst_t'('d0);
        current_instruction <= 'd0;
    end else begin
        current_instruction <= inst_i;
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
        CTRL_ADDI: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_SLTI: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_SLTIU: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_ANDI: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_ORI: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_XORI: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_SLLI: imm_offset_o = 32'(current_instruction[24:20]);
        CTRL_SRLI: imm_offset_o = 32'(current_instruction[24:20]);
        CTRL_SRAI: imm_offset_o = 32'(current_instruction[24:20]);
        CTRL_LUI: imm_offset_o = {current_instruction[31:12], 12'd0};
        CTRL_AUIPC: imm_offset_o = {current_instruction[31:12], 12'd0};
        CTRL_ADD: imm_offset_o = 'd0;
        CTRL_SUB: imm_offset_o = 'd0;
        CTRL_SLTU: imm_offset_o = 'd0;
        CTRL_SLT: imm_offset_o = 'd0;
        CTRL_AND: imm_offset_o = 'd0;
        CTRL_OR: imm_offset_o = 'd0;
        CTRL_XOR: imm_offset_o = 'd0;
        CTRL_SLL: imm_offset_o = 'd0;
        CTRL_SRL: imm_offset_o = 'd0;
        CTRL_SRA: imm_offset_o = 'd0;
        CTRL_JAL: imm_offset_o = (current_instruction[31] == 1) ? {11'hFFF, {current_instruction[31], current_instruction[19:12], current_instruction[20], current_instruction[30:21], 1'b0}} : {11'b0, {current_instruction[31], current_instruction[19:12], current_instruction[20], current_instruction[30:21], 1'b0}};
        CTRL_JALR: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_BEQ: imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        CTRL_BNE: imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        CTRL_BGE: imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        CTRL_BLT: imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        CTRL_BLTU: imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        CTRL_BGEU: imm_offset_o = (current_instruction[31] == 1) ? {19'hFFFFF, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}} : {19'b0, {current_instruction[31], current_instruction[7], current_instruction[30:25], current_instruction[11:8], 1'b0}};
        CTRL_LW: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_LH: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_LHU: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_LB: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_LBU: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_SW: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:25], current_instruction[11:7]} : {20'b0, current_instruction[31:25], current_instruction[11:7]};
        CTRL_SH: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:25], current_instruction[11:7]} : {20'b0, current_instruction[31:25], current_instruction[11:7]};
        CTRL_SB: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:25], current_instruction[11:7]} : {20'b0, current_instruction[31:25], current_instruction[11:7]};
        CTRL_MUL: imm_offset_o = (current_instruction[31] == 1) ? {20'hFFFFF, current_instruction[31:20]} : {20'b0, current_instruction[31:20]};
        CTRL_MULH: imm_offset_o = 'd0;
        CTRL_MULHU: imm_offset_o = 'd0;
        CTRL_MULHSU: imm_offset_o = 'd0;
        CTRL_DIV: imm_offset_o = 'd0;
        CTRL_DIVU: imm_offset_o = 'd0;
        CTRL_REM: imm_offset_o = 'd0;
        CTRL_REMU: imm_offset_o = 'd0;
        CTRL_MRET: imm_offset_o = 'd0;
        CTRL_WFI: imm_offset_o = 'd0;
        CTRL_CSRRW: imm_offset_o = 'd0; 
        CTRL_CSRRS: imm_offset_o = 'd0; 
        CTRL_CSRRC: imm_offset_o = 'd0; 
        CTRL_CSRRWI: imm_offset_o = 32'(current_instruction[19:15]); 
        CTRL_CSRRSI: imm_offset_o = 32'(current_instruction[19:15]); 
        CTRL_CSRRCI:imm_offset_o = 32'(current_instruction[19:15]); 
        default: imm_offset_o = 'd0;
    endcase
end


endmodule