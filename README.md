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
        
        Fig 1 : RippleV overview.
</center>

**Note**: Diagram shown above is not final, does not include control path and is only for general understanding. Actual implementation might differ from  what is shown, however the aim would be to match the implementaion to the diagram as closely as possible. Hence, both the diagram and implementation might change from time to time. 

## Source

- [Unpriviledged Instructructions](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf)
- [Priviledged Instructions](https://docs.riscv.org/reference/isa/_attachments/riscv-privileged.pdf)
