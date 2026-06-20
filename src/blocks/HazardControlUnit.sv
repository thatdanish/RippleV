// Hazard Control Unit

module HazardControlUnit (
    input clk_i,
    input rst_i,
    input typed_pkg::hcu_handler_stages_t hcu_hnd_stage_i,
    input logic [4:0] rs1_i, 
    input logic [4:0] rs2_i, 
    input logic [4:0] rd_i, 
    output logic l1_stall_o,
    output logic l1_clear_o,
    output logic l2_stall_o,
    output logic l2_clear_o,
    output logic l3_stall_o,
    output logic l3_clear_o,
    output logic l4_stall_o,
    output logic l4_clear_o,
    output typed_pkg::instruction_type_t hcu_inst_type_o 
);

always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        
    end else begin
        rd_prev2 <= rd_prev1;
        rd_prev3 <= rd_prev2;
        rd_prev4 <= rd_prev3;      
        rd_stale <= rd_prev4;      

        case (hcu_hnd_stage_i)
            HCU_I_type: begin
                if (rs1_i inside {rd_prev1, rd_prev2, rd_prev3, rd_prev4} && rs1_i !=rd_stale && rs1_i != 5'd0) begin
                    // something
                end else begin
                   // Store rd
                    rd_prev1 <= rd_i;
                end
            end
            default: 
        endcase
    end
end

endmodule