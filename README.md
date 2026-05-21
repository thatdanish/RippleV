<center>

# RippleV : A Pipelined RISC-V (32IM) Core

</center>

RippleV is a RISC-V core, supporting 32 bits *I* & *M* extensions. 


## Design Features

### Supportted Instruction

| Type        | Instructions |
|  :----:     |  :----:      |
| I-type      |  ADDI, SLTI, SLTIU, ANDI, ORI, XORI, SLLI, SRLI, SRAI, LUI, AUIPC |
| R-type      |  ADD, SUB,SLTU, SLT, AND, OR, XOR,SLL, SRL |
| Uncodtional Jump  | JAL, JALR |
| Conditional Jump  |  BEQ, BNE, BLT, BLTU |
| Load/Store |  LW, LH, LHU, LB,LBU, SW, SH, SB |
| M-Extension |  MUL, MULH, MULHU, MULHSU, DIV, DIVU, REM, REMU |
| *Priviledged Instructions* |  MRET, WFI |

### Implemented CSRs
- mstatus
- mepc
- mcause
- misa
- mtvec

### Core Diagram
<center> 

![image](img/Overview.svg ) 
        
        Fig 1 : RippleV core diagram.
</center>

**Legend**:
- Blue = Designed & Verified   
- White = Incomplete design and/or verification
- Yellow = Temporary design and/or verification

#### Note: 
Diagram shown above is not final, does not include control path and is only for general understanding. Actual implementation might differ from  what is shown, however the aim would be to match the implementation to the diagram as closely as possible. Hence, both the diagram and implementation might be updated from time to time. 

## Supported/Recommended Tools
- CocoTB (for verification)
- Verilator v5.048 (simulation/compilation) -- *Recommended*
- Icarus (for simulation/compilation) -- *Support deprecated since [v0.0.1](link)*
- Surfer ( for waveforms) -- *Recommended*
- GTKwave (for waveforms)


VERILATOR & SURFER support is planned [see issue](https://github.com/thatdanish/RippleV/issues/1#issue-4471244125).


## Source

- [Unpriviledged Instructructions](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf)
- [Priviledged Instructions](https://docs.riscv.org/reference/isa/_attachments/riscv-privileged.pdf)
