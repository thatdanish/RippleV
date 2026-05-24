package sel_pkg;

// mux_reg_file_addr

localparam  sel_reg_file_rs1 = 2'd0;
localparam  sel_reg_file_rs2 = 2'd1;
localparam  sel_reg_file_rd = 2'd2;

// mux_reg_file_data

localparam  sel_reg_file_data_mem = 2'd0;
localparam  sel_reg_file_alu = 2'd1;
localparam  sel_reg_file_decoder = 2'd2;

// mux_alu_a

localparam  sel_alu_const_4 = 2'd0;
localparam  sel_alu_sign_ext_offset = 2'd1;
localparam  sel_alu_lui = 2'd2;
localparam  sel_alu_rs2 = 2'd3;

// mux_alu_b

localparam  sel_alu_pc_i = 2'd0;
localparam  sel_alu_rs1 = 2'd1;

// mux_pc

localparam  sel_pc_pc_update = 2'd0;
localparam  sel_pc_mret = 2'd1;
localparam  sel_pc_handler_addr = 2'd2;

// housekeeper task

localparam  task_reset = 2'd0;
localparam  task_exception = 2'd1;
localparam  task_interrupt = 2'd2;
localparam  task_mret = 2'd3;

endpackage