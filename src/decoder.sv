`timescale 1ns/1ns
`default_nettype none

module decoder(
    input clk_i,
    input rst_i,
    input logic [31:0] inst_i,
    output logic [4:0] rd_o,
    output logic [4:0] rs1_o,
    output logic [4:0] rs2_o,
    output logic [31:0] imm_offset_o,
    output logic [31:0] lui_o,
    output logic [5:0] inst_to_ctrl_o
);

import Opcodes_pkg::*;

logic [6:0] op_code, funct_7;
logic [2:0] funct_3;

assign rd_o = inst_i[11:7];
assign rs1_o = inst_i[19:15];
assign rs2_o = inst_i[24:20];
assign imm_offset_o = (inst_i[31] == 1) ? {20'hFFFFF, inst_i[31:20]} : {20'b0, inst_i[31:20]};
assign lui_o = {inst_i[31:12], 12'd0};

assign op_code = inst_i[6:0];
assign funct_3 = inst_i[14:12];
assign funct_7 = inst_i[31:25];

always_ff @( posedge clk_i ) begin 
    if(!rst_i) begin
        inst_to_ctrl_o <= 'd0;
    end else begin
        case (op_code)
            LUI : inst_to_ctrl_o <= CTRL_LUI;
            AUIPC : inst_to_ctrl_o <= CTRL_AUIPC;
            JAL : inst_to_ctrl_o <= CTRL_JAL;
            JALR : inst_to_ctrl_o <= CTRL_JALR;
            CJ :  begin
                case (funct_3)
                    BEQ : inst_to_ctrl_o <= CTRL_BEQ;
                    BNE : inst_to_ctrl_o <= CTRL_BNE;
                    BGE : inst_to_ctrl_o <= CTRL_BGE;
                    BLTU : inst_to_ctrl_o <= CTRL_BLTU;
                    BGEU : inst_to_ctrl_o <= CTRL_BGEU;
                    default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            LOAD :  begin
                case (funct_3)
                    LB : inst_to_ctrl_o <= CTRL_LB;
                    LH : inst_to_ctrl_o <= CTRL_LH;
                    LW : inst_to_ctrl_o <= CTRL_LW;
                    LBU : inst_to_ctrl_o <= CTRL_LBU;
                    LHU : inst_to_ctrl_o <= CTRL_LHU;
                    default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            STORE :  begin
                case (funct_3)
                    SB : inst_to_ctrl_o <= CTRL_SB;
                    SH : inst_to_ctrl_o <= CTRL_SH;
                    SW : inst_to_ctrl_o <= CTRL_SW;
                    default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            IMM_T :  begin
                case (funct_3)
                    ADDI : inst_to_ctrl_o <= CTRL_ADDI;
                    SLTI : inst_to_ctrl_o <= CTRL_SLTI;
                    SLTIU : inst_to_ctrl_o <= CTRL_SLTU;
                    XORI : inst_to_ctrl_o <= CTRL_XORI;
                    ORI : inst_to_ctrl_o <= CTRL_ORI;
                    ANDI : inst_to_ctrl_o <= CTRL_ANDI;
                    SLLI : inst_to_ctrl_o <= CTRL_SLLI;
                    SRLI_SRAI : begin
                        if (funct_7 == SRLI_F7) inst_to_ctrl_o <= CTRL_SRLI;
                        else inst_to_ctrl_o <= CTRL_SRAI;
                    end
                    default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            REG_T :  begin
                case (funct_3)
                    ADD_SUB_MUL : begin
                        case (funct_7)
                            ADD_F7 : inst_to_ctrl_o <= CTRL_ADD;
                            SUB_F7 : inst_to_ctrl_o <= CTRL_SUB;
                            MUL_F7 : inst_to_ctrl_o <= CTRL_MUL;
                            default: inst_to_ctrl_o <= 'd0;
                        endcase
                    end 
                    SLL_MULH : begin
                       if (funct_7 == SLL_F7) inst_to_ctrl_o <= CTRL_SLL;
                       else inst_to_ctrl_o <= CTRL_MULH;
                    end
                    SLT_MULHSU : begin
                        if (funct_7 == SLT_F7) inst_to_ctrl_o <= CTRL_SLT;
                        else inst_to_ctrl_o <= CTRL_MULHSU;
                    end
                    SLTU_MULHU : begin
                       if (funct_7 == SLTU_F7) inst_to_ctrl_o <= CTRL_SLTU;
                       else inst_to_ctrl_o <= CTRL_MULHU;
                    end
                    XOR_DIV : begin
                       if (funct_7 == XOR_F7) inst_to_ctrl_o <= CTRL_XOR;
                       else inst_to_ctrl_o <= CTRL_DIV;
                    end
                    SRL_SRA_DIVU : begin
                        case (funct_7)
                            SRL_F7 : inst_to_ctrl_o <= CTRL_SRL;
                            SRA_F7 : inst_to_ctrl_o <= CTRL_SRA;
                            DIVU_F7 : inst_to_ctrl_o <= CTRL_DIVU;
                            default: inst_to_ctrl_o <= 'd0;
                        endcase
                    end
                    OR_REM : begin
                       if (funct_7 == OR_F7) inst_to_ctrl_o <= CTRL_OR;
                       else inst_to_ctrl_o <= CTRL_REM;
                    end
                    AND_REMU : begin
                       if (funct_7 == AND_F7) inst_to_ctrl_o <= CTRL_AND;
                       else inst_to_ctrl_o <= CTRL_REMU;
                    end
                    default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            default: inst_to_ctrl_o <= 'd0;
        endcase
    end
end


endmodule