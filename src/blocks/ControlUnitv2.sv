// verilog_format: off
`timescale 1ns / 1ns
`default_nettype none
// verilog_format: on

module ControlUnitv2 (
    // External
    input                                         clk_i,
    input                                         rst_i,
    input                                         main_enable_i,
    input                                         stall_cu_i,
    output logic                                  interrupt_ack_o,
    // Decoder 
    input  typed_pkg::ctrl_inst_t                 instruction_i,
    // CSR
    input                                         interrupt_i,
    output typed_pkg::csr_addr_t                  csr_addr_from_ctrl_o,
    output typed_pkg::sel_csr_addr_t              csr_addr_mux_sel_o,
    output typed_pkg::sel_csr_data_t              csr_data_mux_sel_o,
    output typed_pkg::write_t                     csr_write_type_o,
    output typed_pkg::rw_t                        csr_rw_o,
    output logic                                  csr_en_o,
    output logic                           [31:0] csr_data_from_ctrl_o,
    // Instruction Memory
    output                                        inst_mem_en_o,
    // Reg-file v2
    output typed_pkg::sel_reg_file_data_t         reg_file_data_mux_sel_o,
    output logic                                  reg_file_read_en_o,
    output logic                                  reg_file_write_en_o,
    // ALU
    output typed_pkg::alu_opr_t                   alu_opr_o,
    output typed_pkg::sel_alu_a_t                 alu_a_mux_sel_o,
    output typed_pkg::sel_alu_b_t                 alu_b_mux_sel_o,
    output logic                                  alu_en_o,
    // Branch logic
    output typed_pkg::alu_opr_t                   bl_opr_o,
    output logic                                  branch_logic_en_o,
    // Data Memory
    output typed_pkg::transfer_t                  data_mem_transfer_type_o,
    output typed_pkg::rw_t                        data_mem_rw_o,
    output typed_pkg::load_t                      data_mem_load_type_o,
    output logic                                  data_mem_en_o,
    // HCU
    input  typed_pkg::hcu_handler_stages_t        hcu_hnd_stage_i
);

  import typed_pkg::*;

  typedef enum bit [3:0] {
    NORMAL,
    INTERRUPT,
    OFF
  } operation_t;

  operation_t current_asserted_outputs;

  always_ff @(posedge clk_i) begin
    if (!rst_i) begin
      current_asserted_outputs <= OFF;
    end else begin
      if (main_enable_i == 1'b1 && interrupt_i == 1'b0 && stall_cu_i == 1'b0) begin
        current_asserted_outputs <= NORMAL;
      end else if (interrupt_i == 1'b1)
        // TODO: Implement interrupt handling
        current_asserted_outputs <= OFF;
      else current_asserted_outputs <= OFF;
    end
  end

  always_comb begin

    // External
    interrupt_ack_o          = 1'b0;
    // CSR  
    csr_rw_o                 = rw_t'(1'b0);
    csr_addr_from_ctrl_o     = csr_addr_t'('d0);
    csr_addr_mux_sel_o       = sel_csr_addr_t'('d0);
    csr_data_mux_sel_o       = sel_csr_data_t'('d0);
    csr_write_type_o         = write_t'('d0);
    csr_en_o                 = 1'b0;
    csr_data_from_ctrl_o     = 'd0;
    // Inst-mem
    inst_mem_en_o            = 1'b1;
    // Reg file V2
    reg_file_read_en_o       = 1'b0;
    reg_file_write_en_o      = 1'b0;
    reg_file_data_mux_sel_o  = sel_reg_file_data_t'('b0);
    // ALU
    alu_a_mux_sel_o          = sel_alu_a_t'('d0);
    alu_b_mux_sel_o          = sel_alu_b_t'('d0);
    alu_opr_o                = alu_opr_t'('b0);
    alu_en_o                 = 1'b0;
    // Branch logic
    bl_opr_o                 = alu_opr_t'('b0);
    branch_logic_en_o        = 1'b0;
    // Data-mem
    data_mem_rw_o            = rw_t'(1'b0);
    data_mem_transfer_type_o = transfer_t'(2'b0);
    data_mem_load_type_o     = load_t'('d0);
    data_mem_en_o            = 1'b0;

    // ALU operations
    case (instruction_i)
      CTRL_ADDI:   alu_opr_o = ALU_ADD;
      CTRL_SLTI:   alu_opr_o = ALU_SLT;
      CTRL_SLTIU:  alu_opr_o = ALU_SLTU;
      CTRL_ANDI:   alu_opr_o = ALU_AND;
      CTRL_ORI:    alu_opr_o = ALU_OR;
      CTRL_XORI:   alu_opr_o = ALU_XOR;
      CTRL_SLLI:   alu_opr_o = ALU_SLL;
      CTRL_SRLI:   alu_opr_o = ALU_SRL;
      CTRL_SRAI:   alu_opr_o = ALU_SRA;
      CTRL_AUIPC:  alu_opr_o = ALU_JAL;
      CTRL_ADD:    alu_opr_o = ALU_ADD;
      CTRL_SUB:    alu_opr_o = ALU_SUB;
      CTRL_SLTU:   alu_opr_o = ALU_SLTU;
      CTRL_SLT:    alu_opr_o = ALU_SLT;
      CTRL_AND:    alu_opr_o = ALU_AND;
      CTRL_OR:     alu_opr_o = ALU_OR;
      CTRL_XOR:    alu_opr_o = ALU_XOR;
      CTRL_SLL:    alu_opr_o = ALU_SLL;
      CTRL_SRL:    alu_opr_o = ALU_SRL;
      CTRL_SRA:    alu_opr_o = ALU_SRA;
      CTRL_JAL:    alu_opr_o = ALU_JAL;
      CTRL_JALR:   alu_opr_o = ALU_JALR;
      CTRL_BEQ:    alu_opr_o = ALU_ADD;  // placeholders
      CTRL_BNE:    alu_opr_o = ALU_ADD;  // placeholders
      CTRL_BGE:    alu_opr_o = ALU_ADD;  // placeholders
      CTRL_BLT:    alu_opr_o = ALU_ADD;  // placeholders
      CTRL_BLTU:   alu_opr_o = ALU_ADD;  // placeholders
      CTRL_BGEU:   alu_opr_o = ALU_ADD;  // placeholders
      CTRL_LW:     alu_opr_o = ALU_ADD;  // placeholders
      CTRL_LH:     alu_opr_o = ALU_ADD;  // placeholders
      CTRL_LHU:    alu_opr_o = ALU_ADD;  // placeholders
      CTRL_LB:     alu_opr_o = ALU_ADD;  // placeholders
      CTRL_LBU:    alu_opr_o = ALU_ADD;  // placeholders
      CTRL_SW:     alu_opr_o = ALU_ADD;  // placeholders
      CTRL_SH:     alu_opr_o = ALU_ADD;  // placeholders
      CTRL_SB:     alu_opr_o = ALU_ADD;  // placeholders
      CTRL_MUL:    alu_opr_o = ALU_MUL;
      CTRL_MULH:   alu_opr_o = ALU_MULH;
      CTRL_MULHU:  alu_opr_o = ALU_MULHU;
      CTRL_MULHSU: alu_opr_o = ALU_MULHSU;
      CTRL_DIV:    alu_opr_o = ALU_DIV;
      CTRL_DIVU:   alu_opr_o = ALU_DIVU;
      CTRL_REM:    alu_opr_o = ALU_REM;
      CTRL_REMU:   alu_opr_o = ALU_REMU;
      default:     alu_opr_o = alu_opr_t'('d0);
    endcase

    // Asserted outputs
    if (current_asserted_outputs == NORMAL) begin
      case (instruction_i)
        CTRL_ADDI, CTRL_SLTI, CTRL_SLTIU, CTRL_ANDI, CTRL_ORI, CTRL_XORI, CTRL_SLLI, CTRL_SRLI, CTRL_SRAI, CTRL_LUI, CTRL_AUIPC: begin
          // IMEM enable
          inst_mem_en_o       = 1'b1;

          // Read RS1
          reg_file_read_en_o  = 1'b1;

          // Compute @ ALU - mux a, b
          alu_en_o            = 1'b1;
          alu_a_mux_sel_o     = sel_alu_sign_ext_offset;
          alu_b_mux_sel_o     = sel_alu_rs1;

          // Write RD
          reg_file_write_en_o = 1'b1;
          if (instruction_i == CTRL_LUI) reg_file_data_mux_sel_o = sel_reg_file_decoder;
          else reg_file_data_mux_sel_o = sel_reg_file_alu;

        end
        CTRL_ADD, CTRL_SUB, CTRL_SLTU, CTRL_SLT, CTRL_AND, CTRL_OR, CTRL_XOR, CTRL_SLL, CTRL_SRL, CTRL_SRA: begin
          // IMEM enable
          inst_mem_en_o           = 1'b1;

          // Read RS1
          reg_file_read_en_o      = 1'b1;

          // Compute @ ALU - mux a, b
          alu_en_o                = 1'b1;
          alu_a_mux_sel_o         = sel_alu_rs2;
          alu_b_mux_sel_o         = sel_alu_rs1;

          // Write RD
          reg_file_write_en_o     = 1'b1;
          reg_file_data_mux_sel_o = sel_reg_file_alu;

        end
        CTRL_LW, CTRL_LH, CTRL_LHU, CTRL_LB, CTRL_LBU, CTRL_SW, CTRL_SH, CTRL_SB: begin
          // IMEM enable
          inst_mem_en_o      = 1'b1;

          // Read RS1 (LOAD & STORE), RS2 (STORE)
          reg_file_read_en_o = 1'b1;

          // Address gen @ ALU - mux a, b
          alu_en_o           = 1'b1;
          alu_a_mux_sel_o    = sel_alu_sign_ext_offset;
          alu_b_mux_sel_o    = sel_alu_rs1;

          // Write RD (LOAD), Read/Write from data-mem
          data_mem_en_o      = 1'b1;

          case (instruction_i)
            CTRL_LW: begin
              reg_file_write_en_o      = 1'b1;
              reg_file_data_mux_sel_o  = sel_reg_file_data_mem;
              data_mem_rw_o            = read;
              data_mem_load_type_o     = load_signed;
              data_mem_transfer_type_o = transfer_word;
            end
            CTRL_LH: begin
              reg_file_write_en_o      = 1'b1;
              reg_file_data_mux_sel_o  = sel_reg_file_data_mem;
              data_mem_rw_o            = read;
              data_mem_load_type_o     = load_signed;
              data_mem_transfer_type_o = transfer_hex_byte;
            end
            CTRL_LHU: begin
              reg_file_write_en_o      = 1'b1;
              reg_file_data_mux_sel_o  = sel_reg_file_data_mem;
              data_mem_rw_o            = read;
              data_mem_load_type_o     = load_unsigned;
              data_mem_transfer_type_o = transfer_hex_byte;
            end
            CTRL_LB: begin
              reg_file_write_en_o      = 1'b1;
              reg_file_data_mux_sel_o  = sel_reg_file_data_mem;
              data_mem_rw_o            = read;
              data_mem_load_type_o     = load_signed;
              data_mem_transfer_type_o = transfer_byte;
            end
            CTRL_LBU: begin
              reg_file_write_en_o      = 1'b1;
              reg_file_data_mux_sel_o  = sel_reg_file_data_mem;
              data_mem_rw_o            = read;
              data_mem_load_type_o     = load_unsigned;
              data_mem_transfer_type_o = transfer_byte;
            end
            CTRL_SW: begin
              data_mem_rw_o            = write;
              data_mem_transfer_type_o = transfer_word;
            end
            CTRL_SH: begin
              data_mem_rw_o            = write;
              data_mem_transfer_type_o = transfer_hex_byte;
            end
            CTRL_SB: begin
              data_mem_rw_o            = write;
              data_mem_transfer_type_o = transfer_byte;
            end
            default: begin
              data_mem_en_o       = 1'b0;
              reg_file_write_en_o = 1'b0;
            end
          endcase

        end
        CTRL_JAL, CTRL_JALR: begin
          // IMEM enable
          inst_mem_en_o      = 1'b1;

          // Read RS1 (JALR)
          reg_file_read_en_o = 1'b1;

          // Jump PC gen @ BL - mux a, b
          branch_logic_en_o  = 1'b1;
          if (instruction_i == CTRL_JAL) begin
            bl_opr_o = ALU_JAL;
          end else begin
            bl_opr_o = ALU_JALR;
          end

          // Write (PC+4) to RD 
          reg_file_write_en_o     = 1'b1;
          reg_file_data_mux_sel_o = sel_reg_file_pc;

        end
        CTRL_BEQ, CTRL_BNE, CTRL_BGE, CTRL_BLT, CTRL_BLTU, CTRL_BGEU: begin
          // IMEM enable
          inst_mem_en_o      = 1'b1;

          // Read RS1, RS2
          reg_file_read_en_o = 1'b1;

          // Check for branch @ BL
          branch_logic_en_o  = 1'b1;

          case (instruction_i)
            CTRL_BEQ: begin
              bl_opr_o = ALU_BEQ;
            end
            CTRL_BNE: begin
              bl_opr_o = ALU_BNE;
            end
            CTRL_BLT: begin
              bl_opr_o = ALU_BLT;
            end
            CTRL_BLTU: begin
              bl_opr_o = ALU_BLTU;
            end
            CTRL_BGE: begin
              bl_opr_o = ALU_BGE;
            end
            CTRL_BGEU: begin
              bl_opr_o = ALU_BGEU;
            end
            default: begin
              bl_opr_o = alu_opr_t'('d0);
            end
          endcase
        end
        CTRL_CSRRW, CTRL_CSRRS, CTRL_CSRRC, CTRL_CSRRWI, CTRL_CSRRSI, CTRL_CSRRCI: begin
          // Read RS1
          reg_file_read_en_o = 1'b1;

          // Read & write @ CSR
          csr_en_o           = 1'b1;
          csr_rw_o           = write;
          csr_addr_mux_sel_o = sel_csr_addr_decoder;
          case (instruction_i)
            CTRL_CSRRW: begin
              csr_data_mux_sel_o = sel_csr_data_rs1;
              csr_write_type_o   = write_complete;
            end
            CTRL_CSRRS: begin
              csr_data_mux_sel_o = sel_csr_data_rs1;
              csr_write_type_o   = write_set;
            end
            CTRL_CSRRC: begin
              csr_data_mux_sel_o = sel_csr_data_rs1;
              csr_write_type_o   = write_clear;
            end
            CTRL_CSRRWI: begin
              csr_data_mux_sel_o = sel_csr_data_uimm;
              csr_write_type_o   = write_complete;
            end
            CTRL_CSRRSI: begin
              csr_data_mux_sel_o = sel_csr_data_uimm;
              csr_write_type_o   = write_set;
            end
            CTRL_CSRRCI: begin
              csr_data_mux_sel_o = sel_csr_data_uimm;
              csr_write_type_o   = write_clear;
            end
            default: csr_write_type_o = write_t'('d0);
          endcase

          // Write RD
          reg_file_write_en_o     = 1'b1;
          reg_file_data_mux_sel_o = sel_reg_file_csr;
        end
        CTRL_ECALL: begin
          // IMEM enable
          inst_mem_en_o = 1'b1;

          csr_en_o      = 1'b1;
          if (hcu_hnd_stage_i == first) begin
            // Write PC to mepc @ CSR
            csr_rw_o             = write;
            csr_addr_mux_sel_o   = sel_csr_addr_ctrl_unit;
            csr_addr_from_ctrl_o = CSR_mepc;
            csr_data_mux_sel_o   = sel_csr_data_pc;
          end else if (hcu_hnd_stage_i == second) begin
            // Write mcause @ CSR
            csr_rw_o             = write;
            csr_addr_mux_sel_o   = sel_csr_addr_ctrl_unit;
            csr_addr_from_ctrl_o = CSR_mcause;
            csr_data_mux_sel_o   = sel_csr_data_ctrl_unit;
            csr_data_from_ctrl_o = cause_ecall;
          end else begin
            // Read mtvec @ CSR
            csr_rw_o             = read;
            csr_addr_mux_sel_o   = sel_csr_addr_ctrl_unit;
            csr_addr_from_ctrl_o = CSR_mtvec;
          end

          // Jumping PC to mtvec : handled by HCU
        end
        CTRL_MRET: begin
          // IMEM enable
          inst_mem_en_o        = 1'b1;

          // Read mepc @ CSR
          csr_rw_o             = read;
          csr_addr_mux_sel_o   = sel_csr_addr_ctrl_unit;
          csr_addr_from_ctrl_o = CSR_mepc;

          // Jumping PC to mepc : handled by HCU
        end
        CTRL_WFI: begin
          // IMEM enable
          inst_mem_en_o = 1'b1;
        end
        default: begin
          inst_mem_en_o = 1'b1;
        end
      endcase
    end else if (current_asserted_outputs == INTERRUPT) begin
      // IMEM enable
      inst_mem_en_o = 1'b1;

      if (hcu_hnd_stage_i == first) begin
        // Write mepc @ CSR
        csr_rw_o             = write;
        csr_addr_mux_sel_o   = sel_csr_addr_ctrl_unit;
        csr_addr_from_ctrl_o = CSR_mepc;
        csr_data_mux_sel_o   = sel_csr_data_pc;
      end else if (hcu_hnd_stage_i == second) begin
        // Write mcause @ CSR
        csr_rw_o             = write;
        csr_addr_mux_sel_o   = sel_csr_addr_ctrl_unit;
        csr_addr_from_ctrl_o = CSR_mcause;
        csr_data_mux_sel_o   = sel_csr_data_ctrl_unit;
        csr_data_from_ctrl_o = cause_illegal_instruction;
      end else begin
        // Read mtvec @ CSR
        csr_rw_o             = read;
        csr_addr_mux_sel_o   = sel_csr_addr_ctrl_unit;
        csr_addr_from_ctrl_o = CSR_mtvec;
      end
      // Jumping PC to mtvec : handled by HCU
    end else begin
      inst_mem_en_o = (rst_i == 1'b1) ? 1'b1 : 1'b0;
    end
  end
endmodule
