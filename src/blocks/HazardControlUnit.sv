// Hazard Control Unit

module HazardControlUnit (
    input clk_i,
    input rst_i,
    input typed_pkg::instruction_type_t hcu_inst_type_i,
    input bl_take_branch_i, 
    input logic [4:0] rs1_i, 
    input logic [4:0] rs2_i, 
    input logic [4:0] rd_i, 
    output logic stall_l1_o,
    output logic clear_l1_o,
    output logic stall_l2_o,
    output logic clear_l2_o,
    output logic stall_l3_o,
    output logic clear_l3_o,
    output logic stall_l4_o,
    output logic clear_l4_o,
    output logic stall_if_o,
    output logic stall_id_o,
    output logic stall_ex_o,
    output logic stall_mem_o,
    output logic stall_wb_o,
    output typed_pkg::hcu_handler_stages_t hcu_hnd_stage_o,
    output logic pc_en_o,
    output typed_pkg::sel_pc_t pc_sel_o
);
import typed_pkg::*;

localparam UCJ_STALL_MAX = 4;
localparam TRAP_STALL_MAX = 12;
localparam TRAP_STAGE_TWO = 4;
localparam TRAP_STAGE_THREE = 8;
localparam MRET_STALL_MAX = 4;
localparam WFI_STALL_WAIT = 4;


typedef enum bit[2:0] { stall_clear, stall_ID_IF , stall_IF, clear_L1_L2, handle_trap, stall_all} outputs_type_t;
outputs_type_t set_outputs;

logic [4:0] rd_prev[4], rd_stale;
logic [3:0] ucj_stall_counter, trap_stall_counter, mret_stall_counter, wfi_stall_counter;

always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        rd_prev[0] <= 'd0;
        rd_prev[1] <= 'd0;
        rd_prev[2] <= 'd0;
        rd_prev[3] <= 'd0;
        ucj_stall_counter <= 'd0;
        set_outputs <= outputs_type_t'('d0);
    end else begin
        // shift rd reg
        rd_prev[1] <= rd_prev[0];
        rd_prev[2] <= rd_prev[1];
        rd_prev[3] <= rd_prev[2];      
        rd_stale <= rd_prev[3];      

        if (bl_take_branch_i == 1'b1) 
            set_outputs <= clear_L1_L2;
        else begin
            case (hcu_inst_type_i)
                HCU_I_type: begin
                    if (rs_hazard(rs1_i)) begin
                        set_outputs <= stall_ID_IF; // stall ID & IF
                    end else begin
                        set_outputs <= stall_clear;
                        rd_prev[0] <= rd_i;  // store rd
                    end
                end
                HCU_R_type: begin
                    if (rs_hazard(rs1_i) || rs_hazard(rs2_i)) begin
                        set_outputs <= stall_ID_IF; // stall ID & IF
                    end else begin
                        set_outputs <= stall_clear;
                        rd_prev[0] <= rd_i; // store rd
                    end
                end
                HCU_UCJ_type: begin
                    // Increment counter
                    ucj_stall_counter <= ( ucj_stall_counter == UCJ_STALL_MAX ) ? 'd0 : ucj_stall_counter + 'd1;
                    
                    if ( ucj_stall_counter == UCJ_STALL_MAX )
                        set_outputs <= stall_clear; // clear stall after delay
                    else
                        set_outputs <= stall_IF; // stall IF
                end
                HCU_CJ_type: begin
                    set_outputs <= stall_clear; // only take action if take_branch_i is asserted
                end
                HCU_CSR_type: begin
                    if (csr_hazard(rs1_i)) begin
                        set_outputs <= stall_ID_IF; // stall ID & IF
                    end else begin
                        set_outputs <= stall_clear;
                        rd_prev[0] <= rd_i;  // store rd
                    end
                end
                HCU_ecall: begin
                    // Increment counter
                    trap_stall_counter <= ( trap_stall_counter == TRAP_STALL_MAX ) ? 'd0 : trap_stall_counter + 'd1;
                    
                    set_outputs <= (trap_stall_counter == TRAP_STALL_MAX) ? stall_clear : handle_trap;
                end
                HCU_mret: begin
                    // Increment counter
                    mret_stall_counter <= ( mret_stall_counter == MRET_STALL_MAX ) ? 'd0 : mret_stall_counter + 'd1;
                    
                    if ( mret_stall_counter == MRET_STALL_MAX )
                        set_outputs <= stall_clear; // clear stall after delay
                    else
                        set_outputs <= stall_IF; // stall IF
                end
                HCU_wfi: begin
                    // Increment counter
                    wfi_stall_counter <= ( wfi_stall_counter == WFI_STALL_WAIT ) ? wfi_stall_counter : wfi_stall_counter + 'd1;

                    set_outputs <= stall_all; // stall complete core
                end
                HCU_trap: begin
                    // Increment counter
                    trap_stall_counter <= ( trap_stall_counter == TRAP_STALL_MAX ) ? 'd0 : trap_stall_counter + 'd1;
                    
                    set_outputs <= (trap_stall_counter == TRAP_STALL_MAX) ? stall_clear : handle_trap;
                end
                default: set_outputs <= stall_all;
            endcase
        end
    end
end

always_comb begin 
    stall_l1_o = 1'b0;
    clear_l1_o = 1'b0;
    stall_l2_o = 1'b0;
    clear_l2_o = 1'b0;
    stall_l3_o = 1'b0;
    clear_l3_o = 1'b0;
    stall_l4_o = 1'b0;
    clear_l4_o = 1'b0;
    stall_if_o = 1'b0;
    stall_id_o = 1'b0;
    stall_ex_o = 1'b0;
    stall_mem_o = 1'b0;
    stall_wb_o = 1'b0;

    pc_en_o = 1'b0;
    pc_sel_o = sel_pc_t'('d0);

    hcu_hnd_stage_o = hcu_handler_stages_t'('d0);
    
    case (set_outputs)
        stall_clear: begin
            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_update;
        end
        stall_ID_IF: begin
            // I & R types
            stall_id_o = 1'b1;
            stall_l1_o = 1'b1;
            stall_if_o = 1'b1;

            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_update;
        end
        stall_IF: begin
            // UCJ type
            stall_l1_o = 1'b1;
            stall_if_o = 1'b1;

            pc_en_o = 1'b0;
            pc_sel_o = sel_pc_update;
        end
        clear_L1_L2: begin
            // CJ type
            clear_l1_o = 1'b1;
            clear_l2_o = 1'b1;

            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_update;
        end
        handle_trap: begin
            // ECALL & Illegal instruction
            stall_if_o = 1'b1;
            stall_l1_o = 1'b1;
            stall_id_o = 1'b1;

            if ( trap_stall_counter >= TRAP_STAGE_TWO )
                hcu_hnd_stage_o = second;
            else if ( trap_stall_counter >= TRAP_STAGE_THREE ) begin
                hcu_hnd_stage_o =  third;
                pc_en_o = 1'b1;
                pc_sel_o = sel_pc_jump_vec;
            end else
                hcu_hnd_stage_o = first;
        end
        stall_all: begin
            stall_if_o = 1'b1;
            stall_l1_o = 1'b1;
            stall_id_o = 1'b1;
            pc_en_o = 1'b0;
            pc_sel_o = sel_pc_update;
            
            if (wfi_stall_counter == WFI_STALL_WAIT) begin
                stall_l2_o = 1'b1;
                stall_ex_o = 1'b1;
                stall_l3_o = 1'b1;
                stall_mem_o = 1'b1;
                stall_l4_o = 1'b1;
                stall_wb_o = 1'b1;
            end
        end     
        default: pc_en_o = 1'b0;
   endcase
end

// Functions

function logic rs_hazard(input logic[4:0] rs_reg);
    if ( (rs_reg == rd_prev[0] || rs_reg == rd_prev[1] || rs_reg == rd_prev[2] || rs_reg == rd_prev[3]) 
        && (rs1_i !=rd_stale) && (rs1_i != 5'd0) )
        return 1'b1;
    else 
        return 1'b0;
endfunction

function logic csr_hazard(input logic[4:0] rs_reg);
    if ( ((rs_reg == rd_prev[0] || rs_reg == rd_prev[1] || rs_reg == rd_prev[2] || rs_reg == rd_prev[3]) 
        && (rs1_i !=rd_stale) && (rs1_i != 5'd0)) || (rs1_i == rd_i) )
        return 1'b1;
    else 
        return 1'b0;
endfunction

endmodule