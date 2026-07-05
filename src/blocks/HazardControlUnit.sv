// Hazard Control Unit

module HazardControlUnit (
    input clk_i,
    input rst_i,
    input jump_valid_i,
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
    output logic stall_pc_direct_o,
    output typed_pkg::hcu_handler_stages_t hcu_hnd_stage_o,
    output logic pc_en_o,
    output typed_pkg::sel_pc_t pc_sel_o,
    output typed_pkg::status_t core_status_o
);
import typed_pkg::*;

localparam UCJ_STALL_MAX = 3;
localparam UCJ_SECONDARY_MAX = 5;
localparam TRAP_STALL_MAX = 12;
localparam TRAP_STAGE_TWO = 4;
localparam TRAP_STAGE_THREE = 8;
localparam MRET_STALL_MAX = 4;
localparam WFI_STALL_WAIT = 4;


typedef enum bit[2:0] { stall_off, stall_I_R , stall_clear_UCJ, clear_CJ, handle_trap, stall_all, propagate_pc_jump} outputs_type_t;
outputs_type_t set_outputs;

logic [4:0] rd_prev[4], rd_stale;
logic [3:0] ucj_stall_counter, ucj_secondary_counter, trap_stall_counter, mret_stall_counter, wfi_stall_counter;

always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        rd_prev[0] <= 'd0;
        rd_prev[1] <= 'd0;
        rd_prev[2] <= 'd0;
        rd_prev[3] <= 'd0;
        ucj_stall_counter <= 'd0;
        ucj_secondary_counter <= 'd0;
        set_outputs <= outputs_type_t'('d0);
    end else begin
        // shift rd reg
        rd_prev[1] <= rd_prev[0];
        rd_prev[2] <= rd_prev[1];
        rd_prev[3] <= rd_prev[2];      
        rd_stale <= rd_prev[3];      

        if ( bl_take_branch_i == 1'b1 ) 
            set_outputs <= clear_CJ;
        else begin
            case (hcu_inst_type_i)
                HCU_I_type: begin
                    if (rs_hazard(rs1_i)) begin
                        set_outputs <= stall_I_R; // stall ID & IF
                    end else begin
                        set_outputs <= stall_off;
                        rd_prev[0] <= rd_i;  // store rd
                    end

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
                HCU_R_type: begin
                    if (rs_hazard(rs1_i) || rs_hazard(rs2_i)) begin
                        set_outputs <= stall_I_R; // stall ID & IF
                    end else begin
                        set_outputs <= stall_off;
                        rd_prev[0] <= rd_i; // store rd
                    end

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
                HCU_LOAD_type: begin
                    set_outputs <= stall_off;
                    rd_prev[0] <= rd_i;
        

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;
 
                end
                HCU_STORE_type: begin
                    set_outputs <= stall_off;
        

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;
 
                end
                HCU_UCJ_type: begin
                    // Increment counter                 
                    ucj_stall_counter <= ( ucj_stall_counter == UCJ_STALL_MAX ) ? ucj_stall_counter : ucj_stall_counter + 'd1;
                                        
                    if ( ucj_stall_counter == UCJ_STALL_MAX ) begin
                        // Increment secondary counter
                        ucj_secondary_counter <= ( ucj_secondary_counter == UCJ_SECONDARY_MAX ) ? 'd0 : ucj_secondary_counter + 'd1;
                        
                        if ( ucj_secondary_counter == UCJ_SECONDARY_MAX ) begin
                            ucj_stall_counter <= 'd0; 
                
                            // set_outputs <= stall_off; // clear stall after delay
                        end else begin
                            set_outputs <= propagate_pc_jump;
                        end
                    end else
                        set_outputs <= stall_clear_UCJ; // stall IF

                    // Clear counters
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
                HCU_CJ_type: begin
                    set_outputs <= stall_off; // only take action if take_branch_i is asserted
        

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
                HCU_CSR_type: begin
                    if (csr_hazard(rs1_i)) begin
                        set_outputs <= stall_I_R; // stall ID & IF
                    end else begin
                        set_outputs <= stall_off;
                        rd_prev[0] <= rd_i;  // store rd
                    end

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
                HCU_ecall: begin
                    // Increment counter
                    trap_stall_counter <= ( trap_stall_counter == TRAP_STALL_MAX ) ? trap_stall_counter : trap_stall_counter + 'd1;
        
                    
                    set_outputs <= (trap_stall_counter == TRAP_STALL_MAX) ? stall_off : handle_trap;

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
                HCU_mret: begin
                    // Increment counter
                    mret_stall_counter <= ( mret_stall_counter == MRET_STALL_MAX ) ? mret_stall_counter : mret_stall_counter + 'd1;

                    if ( mret_stall_counter == MRET_STALL_MAX ) begin
                        set_outputs <= stall_off; // clear stall after delay
                    end else
                        set_outputs <= stall_clear_UCJ; // stall IF

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    
                end
                HCU_wfi: begin
                    // Increment counter
                    wfi_stall_counter <= ( wfi_stall_counter == WFI_STALL_WAIT ) ? wfi_stall_counter : wfi_stall_counter + 'd1;
        

                    set_outputs <= stall_all; // stall complete core

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
                HCU_trap: begin
                    // Increment counter
                    trap_stall_counter <= ( trap_stall_counter == TRAP_STALL_MAX ) ? trap_stall_counter : trap_stall_counter + 'd1;
        

                    set_outputs <= (trap_stall_counter == TRAP_STALL_MAX) ? stall_off : handle_trap;

                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
                default: begin
                    set_outputs <= stall_all;
                
                    // Clear counters
                    ucj_stall_counter <= 'd0;
                    trap_stall_counter <= 'd0;
                    mret_stall_counter <= 'd0;

                end
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
    stall_pc_direct_o = 1'b0;
    core_status_o = status_t'('d0);

    pc_en_o = 1'b0;
    pc_sel_o = sel_pc_t'('d0);

    hcu_hnd_stage_o = hcu_handler_stages_t'('d0);
    
    case (set_outputs)
        stall_off: begin
            core_status_o = ACTIVE;

            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_direct_update;
        end
        propagate_pc_jump : begin
            if ( hcu_inst_type_i == HCU_UCJ_type ) begin
                core_status_o = PROPGT;

                stall_if_o = ( ucj_secondary_counter > 'd2 ) ? 1'b0 : 1'b1;
                stall_id_o = ( ucj_secondary_counter > 'd4 ) ? 1'b0 : 1'b1;
                stall_pc_direct_o = 1'b1;
                // clear_l2_o = 1'b1;
            end

            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_direct_update;

        end
        stall_clear_UCJ: begin
            core_status_o = STALL;
            
            // UCJ type
            stall_if_o = 1'b1;
            stall_l1_o = 1'b1;
            stall_id_o = 1'b1;
            clear_l2_o = ( ucj_stall_counter > 'd2 ) ? 1'b1 : 1'b0;
            stall_pc_direct_o = 1'b1;

            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_update;
        end
        stall_I_R: begin
            core_status_o = STALL;
            // I & R types
            stall_id_o = 1'b1;
            stall_l1_o = 1'b1;
            stall_if_o = 1'b1;
            
            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_direct_update;
        end
        clear_CJ: begin
            core_status_o = STALL;

            // CJ type
            clear_l1_o = 1'b1;
            clear_l2_o = 1'b1;

            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_update;
        end
        handle_trap: begin
            core_status_o = STALL;

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
            core_status_o = ALL_STALLED;

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
        default: begin 
           core_status_o = ALL_STALLED;
           pc_en_o = 1'b0;
        end
   endcase
end

// Functions

function logic rs_hazard(input logic[4:0] rs_reg);
    if ( (rs_reg == rd_prev[0] || rs_reg == rd_prev[1] || rs_reg == rd_prev[2] || rs_reg == rd_prev[3]) 
        && (rs_reg != rd_stale) && (rs_reg != 5'd0) )
        return 1'b1;
    else 
        return 1'b0;
endfunction

function logic csr_hazard(input logic[4:0] rs_reg);
    if ( ((rs_reg == rd_prev[0] || rs_reg == rd_prev[1] || rs_reg == rd_prev[2] || rs_reg == rd_prev[3]) 
        && (rs_reg != rd_stale) && (rs_reg != 5'd0)) || (rs_reg == rd_i) )
        return 1'b1;
    else 
        return 1'b0;
endfunction

endmodule