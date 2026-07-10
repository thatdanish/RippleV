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
    output logic stall_cu_o,
    output logic stall_ex_o,
    output logic stall_mem_o,
    output logic stall_wb_o,
    output logic stall_pc_direct_o,
    output typed_pkg::hcu_handler_stages_t hcu_hnd_stage_o,
    output logic pc_en_o,
    output typed_pkg::sel_pc_t pc_sel_o);
import typed_pkg::*;

localparam AFTER_RST_STALL_MAX = 3;
localparam UCJ_STALL_MAX = 3;
localparam PROPAGATE_MAX = 3;
localparam MRET_STALL_MAX = 4;
localparam WFI_STALL_WAIT = 4;
localparam TRAP_STALL_MAX = 12;
localparam TRAP_STAGE_TWO = 4;
localparam TRAP_STAGE_THREE = 8;
localparam ARRAY_MAX = 6;

typedef struct packed {
    logic [4:0] reg_addr;
    bit active;
} rd_monitor_t;

typedef struct packed {
    logic [4:0] reg_addr;
    logic [2:0] rd_id;
} rd_shift_reg_t;

typedef enum bit[3:0] { STALL_AFTER_RST, STALL_OFF, STALL_FOR_CJ, STALL_FOR_UCJ, STALL_FOR_RBW, PROPAGATE_PC_JUMP, 
                        STALL_FOR_ECALL, STALL_FOR_MRET, STALL_FOR_WFI, STALL_FOR_TRAP } state_t;

state_t current_state, next_state;
rd_monitor_t rd_prev[ARRAY_MAX];
rd_shift_reg_t rd_shift_reg[ARRAY_MAX], rd_stale;
logic [2:0] rd_idx;
logic ucj_stall_ptr, mret_stall_ptr, trap_stall_ptr, ecall_stall_ptr, propagate_ptr, after_rst_ptr;
logic [3:0] stall_counter;
instruction_type_t current_hcu_inst;

assign after_rst_ptr = ( stall_counter == AFTER_RST_STALL_MAX );
assign ucj_stall_ptr = ( stall_counter == UCJ_STALL_MAX );
assign propagate_ptr = ( stall_counter == PROPAGATE_MAX );
assign mret_stall_ptr = ( stall_counter == MRET_STALL_MAX );
assign trap_stall_ptr = ( stall_counter == TRAP_STALL_MAX );
assign ecall_stall_ptr = ( stall_counter == TRAP_STALL_MAX );

always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        rd_prev[0].reg_addr <= 'd0;
        rd_prev[0].active <= 'd0;
        rd_prev[1].reg_addr <= 'd0;
        rd_prev[1].active <= 'd0;
        rd_prev[2].reg_addr <= 'd0;
        rd_prev[2].active <= 'd0;
        rd_prev[3].reg_addr <= 'd0;
        rd_prev[3].active <= 'd0;
        rd_prev[4].reg_addr <= 'd0;
        rd_prev[4].active <= 'd0;
        rd_prev[5].reg_addr <= 'd0;
        rd_prev[5].active <= 'd0;
        
        rd_shift_reg[0].reg_addr <= 'd0;
        rd_shift_reg[0].rd_id <= 'd0;
        rd_shift_reg[1].reg_addr <= 'd0;
        rd_shift_reg[1].rd_id <= 'd0;
        rd_shift_reg[2].reg_addr <= 'd0;
        rd_shift_reg[2].rd_id <= 'd0;
        rd_shift_reg[3].reg_addr <= 'd0;
        rd_shift_reg[3].rd_id <= 'd0;
        rd_shift_reg[4].reg_addr <= 'd0;
        rd_shift_reg[4].rd_id <= 'd0;
        rd_shift_reg[5].reg_addr <= 'd0;
        rd_shift_reg[5].rd_id <= 'd0;

        rd_stale.reg_addr <= 'd0;
        rd_stale.rd_id <= 'd0;
        
        rd_idx <= 'd0;
        stall_counter <= 'd0;
        current_hcu_inst <= instruction_type_t'('d0);
    end else begin
        // shift rd reg
        rd_shift_reg[1].reg_addr <= rd_shift_reg[0].reg_addr;
        rd_shift_reg[1].rd_id <= rd_shift_reg[0].rd_id;
        rd_shift_reg[2].reg_addr <= rd_shift_reg[1].reg_addr;
        rd_shift_reg[2].rd_id <= rd_shift_reg[1].rd_id;
        rd_shift_reg[3].reg_addr <= rd_shift_reg[2].reg_addr;      
        rd_shift_reg[3].rd_id <= rd_shift_reg[2].rd_id;      
        rd_shift_reg[4].reg_addr <= rd_shift_reg[3].reg_addr;      
        rd_shift_reg[4].rd_id <= rd_shift_reg[3].rd_id;      
        rd_shift_reg[5].reg_addr <= rd_shift_reg[4].reg_addr;      
        rd_shift_reg[5].rd_id <= rd_shift_reg[4].rd_id;      

        rd_stale.reg_addr <= rd_shift_reg[5].reg_addr;    
        rd_stale.rd_id <= rd_shift_reg[5].rd_id;    
        
        // Save Rd
        if ( hcu_inst_type_i inside {HCU_I_type, HCU_R_type, HCU_CSR_type, HCU_LOAD_type} ) begin
            rd_prev[0].reg_addr <= rd_i;
            
            rd_prev[rd_idx].reg_addr <= rd_i;
            rd_prev[rd_idx].active <= 1'b1;
            rd_idx <= (rd_idx == ARRAY_MAX-1 ) ? 'd0 : rd_idx + 'd1;
        end else begin
        
            // Toggle active bit
            rd_prev[0].active <= ( rd_prev[rd_idx].reg_addr == rd_stale.reg_addr && rd_stale.rd_id == 'd0 ) ? 1'b0 : rd_prev[0].active;
            rd_prev[1].active <= ( rd_prev[rd_idx].reg_addr == rd_stale.reg_addr && rd_stale.rd_id == 'd1 ) ? 1'b0 : rd_prev[0].active;
            rd_prev[2].active <= ( rd_prev[rd_idx].reg_addr == rd_stale.reg_addr && rd_stale.rd_id == 'd2 ) ? 1'b0 : rd_prev[0].active;
            rd_prev[3].active <= ( rd_prev[rd_idx].reg_addr == rd_stale.reg_addr && rd_stale.rd_id == 'd3 ) ? 1'b0 : rd_prev[0].active;
            rd_prev[4].active <= ( rd_prev[rd_idx].reg_addr == rd_stale.reg_addr && rd_stale.rd_id == 'd4 ) ? 1'b0 : rd_prev[0].active;
            rd_prev[5].active <= ( rd_prev[rd_idx].reg_addr == rd_stale.reg_addr && rd_stale.rd_id == 'd5 ) ? 1'b0 : rd_prev[0].active;
        end

        // Save HCU instruction
        if ( current_state == STALL_OFF )
            current_hcu_inst <= hcu_inst_type_i;

        // Counter
        case (current_state)
            STALL_AFTER_RST :  stall_counter <= ( stall_counter == AFTER_RST_STALL_MAX ) ? 'd0 : stall_counter + 'd1;
            STALL_FOR_UCJ :  stall_counter <= ( stall_counter == UCJ_STALL_MAX ) ? 'd0 : stall_counter + 'd1;
            PROPAGATE_PC_JUMP :  stall_counter <= ( stall_counter == PROPAGATE_MAX ) ? 'd0 : stall_counter + 'd1;
            STALL_FOR_ECALL :  stall_counter <= ( stall_counter == TRAP_STALL_MAX ) ? 'd0 : stall_counter + 'd1;
            STALL_FOR_MRET : stall_counter <= ( stall_counter == MRET_STALL_MAX ) ? 'd0 : stall_counter + 'd1;
            STALL_FOR_WFI : stall_counter <= ( stall_counter == WFI_STALL_WAIT ) ? 'd0 : stall_counter + 'd1;
            STALL_FOR_TRAP : stall_counter <= ( stall_counter == TRAP_STALL_MAX ) ? 'd0 : stall_counter + 'd1;
            default: stall_counter <= 'd0;
       endcase          
    end 
end

always_ff @( posedge clk_i ) begin : StateUpdate
    if (!rst_i) begin
        current_state <= STALL_AFTER_RST;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    next_state = STALL_OFF;

    case (current_state)
        STALL_AFTER_RST: begin 
            if (after_rst_ptr == 1'b1)
                next_state = STALL_OFF;
            else 
                next_state = STALL_AFTER_RST;
        end
        STALL_OFF :  begin
            if ( bl_take_branch_i == 1'b1 ) 
                next_state = STALL_FOR_CJ;
            else begin
                case (hcu_inst_type_i)
                    HCU_I_type: begin
                        if (rs_hazard(rs1_i)) next_state = STALL_FOR_RBW; // stall ID & IF  
                    end
                    HCU_R_type: begin
                        if (rs_hazard(rs1_i) || rs_hazard(rs2_i)) next_state = STALL_FOR_RBW; // stall ID & IF
                    end
                    HCU_UCJ_type: begin
                        next_state =  STALL_FOR_UCJ;
                    end
                    HCU_CSR_type: begin
                        if (csr_hazard(rs1_i)) next_state = STALL_FOR_RBW; // stall ID & IF
                    end
                    HCU_ecall: begin
                        next_state = STALL_FOR_ECALL;
                    end
                    HCU_mret: begin
                        next_state = STALL_FOR_MRET;
                    end
                    HCU_wfi: begin
                        next_state = STALL_FOR_WFI;
                    end
                    HCU_trap: begin
                        next_state = STALL_FOR_TRAP;
                    end                    
                    default: next_state = STALL_OFF;
                endcase
            end
        end
        STALL_FOR_RBW: begin
            case (current_hcu_inst)
                HCU_I_type: begin 
                    if ( rs_hazard(rs1_i) ) next_state = STALL_FOR_RBW;
                    else next_state = STALL_OFF;
                end
                HCU_R_type: begin
                    if ( rs_hazard(rs1_i) || rs_hazard(rs2_i) ) next_state = STALL_FOR_RBW;
                    else next_state = STALL_OFF;
                end
                default: next_state = STALL_FOR_RBW;
            endcase
        end
        STALL_FOR_UCJ: begin
            if ( ucj_stall_ptr == 1'b1 ) next_state = PROPAGATE_PC_JUMP;
            else next_state = STALL_FOR_UCJ;
        end
        PROPAGATE_PC_JUMP: begin
            if ( propagate_ptr == 1'b1 ) next_state = STALL_OFF;
            else next_state = PROPAGATE_PC_JUMP;
        end
        default: begin
        end
    endcase
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
    stall_cu_o = 1'b0;
    pc_en_o = 1'b0;
    pc_sel_o = sel_pc_t'('d0);

    hcu_hnd_stage_o = hcu_handler_stages_t'('d0);
    
    case (current_state)
        STALL_AFTER_RST: begin
            stall_cu_o = 1'b1;
            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_direct_update;
        end
        STALL_OFF: begin
            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_direct_update;
        end
        PROPAGATE_PC_JUMP : begin
            stall_id_o = ( stall_counter > 'd1 ) ? 1'b0 : 1'b1;
            stall_pc_direct_o = 1'b1;
      
            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_direct_update;
        end
        STALL_FOR_UCJ: begin     
            stall_if_o = 1'b1;
            stall_l1_o = 1'b1;
            stall_id_o = 1'b1;
            clear_l2_o = ( stall_counter > 'd2 ) ? 1'b1 : 1'b0;
            stall_pc_direct_o = 1'b1;

            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_update;
        end
        STALL_FOR_RBW: begin
            // I & R types
            stall_id_o = 1'b1;
            stall_l1_o = 1'b1;
            stall_if_o = 1'b1;
            
            pc_en_o = 1'b1;
            pc_sel_o = sel_pc_direct_update;
        end
        STALL_FOR_ECALL: begin
        end
        STALL_FOR_MRET: begin
        end
        STALL_FOR_WFI: begin
        end
        STALL_FOR_TRAP: begin
        end

        // ***************************************************** NOT DEBUGGED ********************************************************** //
        // clear_CJ: begin

        //     // CJ type
        //     clear_l1_o = 1'b1;
        //     clear_l2_o = 1'b1;

        //     pc_en_o = 1'b1;
        //     pc_sel_o = sel_pc_update;
        // end
        // handle_trap: begin

        //     // ECALL & Illegal instruction
        //     stall_if_o = 1'b1;
        //     stall_l1_o = 1'b1;
        //     stall_id_o = 1'b1;

        //     if ( stall_counter >= TRAP_STAGE_TWO )
        //         hcu_hnd_stage_o = second;
        //     else if ( stall_counter >= TRAP_STAGE_THREE ) begin
        //         hcu_hnd_stage_o =  third;
        //         pc_en_o = 1'b1;
        //         pc_sel_o = sel_pc_jump_vec;
        //     end else
        //         hcu_hnd_stage_o = first;
        // end
        // stall_all: begin

        //     stall_if_o = 1'b1;
        //     stall_l1_o = 1'b1;
        //     stall_id_o = 1'b1;
            
        //     pc_en_o = 1'b0;
        //     pc_sel_o = sel_pc_update;
            
        //     if (stall_counter == WFI_STALL_WAIT) begin
        //         stall_l2_o = 1'b1;
        //         stall_ex_o = 1'b1;
        //         stall_l3_o = 1'b1;
        //         stall_mem_o = 1'b1;
        //         stall_l4_o = 1'b1;
        //         stall_wb_o = 1'b1;
        //     end
        // end     
        default: begin 
           pc_en_o = 1'b0;
        end
   endcase
end

// Functions ---------------------------------------------------------------------------------------------------------------

function logic rs_hazard(input logic[4:0] rs_reg);
    if ( ( (rs_reg == rd_prev[0].reg_addr && rd_prev[0].active == 1'b1) ||  (rs_reg == rd_prev[1].reg_addr && rd_prev[1].active == 1'b1) 
        ||  (rs_reg == rd_prev[2].reg_addr && rd_prev[2].active == 1'b1) ||  (rs_reg == rd_prev[3].reg_addr && rd_prev[3].active == 1'b1) 
        ||  (rs_reg == rd_prev[4].reg_addr && rd_prev[4].active == 1'b1) ||  (rs_reg == rd_prev[5].reg_addr && rd_prev[5].active == 1'b1) ) 
        && (rs_reg != 5'd0) )
        return 1'b1;
    else 
        return 1'b0;
endfunction


function logic csr_hazard(input logic[4:0] rs_reg);
    if ( ( (rs_reg == rd_prev[0].reg_addr && rd_prev[0].active == 1'b1) ||  (rs_reg == rd_prev[1].reg_addr && rd_prev[1].active == 1'b1) 
        ||  (rs_reg == rd_prev[2].reg_addr && rd_prev[2].active == 1'b1) ||  (rs_reg == rd_prev[3].reg_addr && rd_prev[3].active == 1'b1) 
        ||  (rs_reg == rd_prev[4].reg_addr && rd_prev[4].active == 1'b1) ||  (rs_reg == rd_prev[5].reg_addr && rd_prev[5].active == 1'b1) ) 
        && ( (rs_reg != 5'd0)) || (rs_reg == rd_i) )
        return 1'b1;
    else 
        return 1'b0;
endfunction

endmodule