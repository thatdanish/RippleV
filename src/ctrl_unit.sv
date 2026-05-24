`timescale 1ns/1ns
`default_nettype none

module ctrl_unit(
    input clk_i,
    input rst_i,
    input interrupt_i,
    output logic [1:0] sel_pc_mux, 
    output housekeeper_en_o, 
    output logic [1:0] housekeeper_task_o
);

    import Opcodes_pkg::*;
    import sel_pkg::*;

    typedef enum bit[3:0] { RESET_TRIGGER, UPDATE_PC_AFTER_RESET, IDLE } state_t;

    state_t current_state, next_state;

    always_ff @( posedge clk_i ) begin : StateUpdateBlock
        if (!rst_i) begin
            current_state <= RESET_TRIGGER;
        end else begin
            current_state <= next_state;
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
                next_state = IDLE; // temp
            end
            default: begin
                // temp
            end
        endcase
        
    end
    
    always_comb begin : OutputBlock
        housekeeper_en_o = 1'b0;
        housekeeper_task_o = 'd0;
        sel_pc_mux = 'd0;
        case (current_state)
            RESET_TRIGGER: begin
                // make core come out of reset
                housekeeper_en_o = 1'b1;
                housekeeper_task_o = task_reset;
            end
            UPDATE_PC_AFTER_RESET : begin
                sel_pc_mux = sel_pc_handler_addr;
            end
            IDLE: begin
                // temp
            end
            default: begin
                // temp
            end
        endcase
    end
   
endmodule