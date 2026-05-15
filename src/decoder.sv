`default_nettype none

module decoder(
    input clk_i,
    input rst_i,
    input logic [31:0] inst_i,
    output logic [4:0] rd_o,
    output logic [4:0] rs1_o,
    output logic [4:0] rs2_o,
    output logic [11:0] imm_offset_o,
    output logic [31:0] lui_o,
    output logic [5:0] inst_to_ctrl_o
);

import Opcodes::*;

logic [6:0] op_code, funct_7;
logic [2:0] funct_3;

assign rd_o = inst_i[11:7];
assign rs1_o = inst_i[19:15];
assign rs2_o = inst_i[24:20];
assign imm_offset_o = (inst_i[31] == 1) ? {12{1'b1}, inst_i[31:20]} : {12'b0, inst_i[31:20]};
assign lui_o = {inst_i[31:12], 12'd0};

assign op_code = inst_i[6:0];
assign funct_7 = inst_i[14:12];
assign funct_3 = inst_i[31:25];

always_ff @( posedge clk_i ) begin 
    if(!rst_i) begin
        inst_to_ctrl_o <= 'd0;
    end else begin
        unique case (op_code)
            LUI : inst_to_ctrl_o <= CTRL_LUI;
            AUIPC : inst_to_ctrl_o <= CTRL_AUIPC;
            JAL : inst_to_ctrl_o <= CTRL_JAL;
            JALR : inst_to_ctrl_o <= CTRL_JALR;
            CJ :  begin
                unique case (funct_3)
                    BEQ : inst_to_ctrl_o <= CTRL_BEQ;
                    BNE : inst_to_ctrl_o <= CTRL_BNE;
                    BGE : inst_to_ctrl_o <= CTRL_BGE;
                    BLTU : inst_to_ctrl_o <= CTRL_BLTU;
                    BGEU : inst_to_ctrl_o <= CTRL_BGEU;
                    default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            LOAD :  begin
                unique case (funct_3)
                    LB : inst_to_ctrl_o <= CTRL_LB;
                    LH : inst_to_ctrl_o <= CTRL_LH;
                    LW : inst_to_ctrl_o <= CTRL_LW;
                    LBU : inst_to_ctrl_o <= CTRL_LBU;
                    LHU : inst_to_ctrl_o <= CTRL_LHU;
                    default: default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            STORE :  begin
                unique case (funct_3)
                    SB : inst_to_ctrl_o <= CTRL_SB;
                    SH : inst_to_ctrl_o <= CTRL_SH;
                    SW : inst_to_ctrl_o <= CTRL_SW;
                    default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            IMM_T :  begin
                unique case (funct_3)
                    ADDI : inst_to_ctrl_o <= CTRL_ADDI;
                    SLTI : inst_to_ctrl_o <= CTRL_SLTI;
                    SLTU : inst_to_ctrl_o <= CTRL_SLTU;
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
                unique case (funct_3)
                    ADD_SUB : begin
                        if (funct_7 == ADD_F7) inst_to_ctrl_o <= CTRL_ADD;
                        else inst_to_ctrl_o <= CTRL_SUB;
                    end 
                    SLL : inst_to_ctrl_o <= CTRL_SLL;
                    SLT : inst_to_ctrl_o <= CTRL_SLT;
                    SLTU : inst_to_ctrl_o <= CTRL_SLTU;
                    XOR : inst_to_ctrl_o <= CTRL_XOR;
                    SRL_SRA : begin
                        if (funct_7 == SRL_F7) inst_to_ctrl_o <= CTRL_SRL;
                        else inst_to_ctrl_o <= CTRL_SRA;
                    end
                    OR : inst_to_ctrl_o <= CTRL_OR;
                    AND : inst_to_ctrl_o <= CTRL_AND;
                    default: inst_to_ctrl_o <= 'd0;
                endcase
            end
            default: inst_to_ctrl_o <= 'd0;
        endcase
    end
end


endmodule