`timescale 1ns/1ns
`default_nettype none

module ctrl_unit(
    input clk_i,
    input rst_i,

);
    import Opcodes_pkg::*;
    import mux_pkg::*;

    typedef enum bit[3:0] { IDLE } state_t;

    state_t current_state, next_state;


    always_ff @( posedge clk_i ) begin
        if (!rst) begin
            
        end else begin
            
        end
    end
    
endmodule
