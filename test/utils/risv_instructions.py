import random
from cocotb.types import LogicArray


class RandomInstruction():

    i_type  = ["ADDI", "SLTI", "SLTIU", "ANDI", "ORI", "XORI", "SLLI", "SRLI", "SRAI"]
    lui_type = ["LUI", "AUIPC"]
    r_type = [ "ADD", "SUB", "SLTU", "SLT", "AND", "OR", "XOR", "SLL", "SRL", "SRA"]
    conditional_jump = ["JAL", "JALR"]                              
    unconditional_jump = ["BEQ", "BNE", "BLT", "BLTU"] 
    load_store = ["LW", "LH", "LHU", "LB", "LBU", "SW", "SH", "SB"]
    m_type = ["MUL", "MULH", "MULHU", "MULHSU", "DIV", "DIVU", "REM", "REMU", "MRET", "WFI"]    
    
    def __init__(self, instruction: str|None = None, imm: int|None = None, Rd: int|None = None, Rs1: int|None = None, Rs2: int|None = None):
        self.final_inst = LogicArray(0, 32)

        if instruction == None:
            self.instruction = random.choice(self.instruction_list)
        else: 
            self.instruction = instruction
        if imm == None:
            self.imm = random.getrandbits(12)
        else: 
            self.imm = imm
        if Rs1 == None:
            self.rs1 = random.getrandbits(5)
        else: 
            self.rs1 = Rs1
        if Rs2 == None:
            self.rs2 = random.getrandbits(5)
        else: 
            self.rs2 = Rs2
        if Rd == None:
            self.rd = random.getrandbits(5)
        else: 
            self.rd = Rd

        self._gen_instruction()

    
    def _gen_instruction(self):
        
        # Immediate type
        if self.instruction in RandomInstruction.i_type:
            self.final_inst[31:20] = LogicArray(self.imm, 12)
            self.final_inst[19:15] = LogicArray(self.rs1, 5)
            self.final_inst[14:12] = LogicArray(self._get_funct3(), 3)
            self.final_inst[11:7] = LogicArray(self.rd, 5)
            self.final_inst[6:0] = LogicArray(self._get_opcode(), 7)
        elif self.insturction in RandomInstruction.t_type:
            pass


    def get_logic_array(self):
        return self.final_inst()

    def _get_funct3(self):
        if self.instruction == "ADDI":
            return 
    
    def _get_opcode(self):
        return 34
    
    def _gen_string(self):
        if self.instruction in RandomInstruction.i_type:      
            return f"Inst : {self.instruction}, Imm: {self.imm}, Rs1 : {self.rs1}, Rs2 : {self.rs2}, Rd : {self.rd}"
        
    def __str__(self):
        return self._gen_string()

def test():
    inst = RandomInstruction(instruction="ADDI")

    print(inst)

if __name__ == "__main__":
    test()