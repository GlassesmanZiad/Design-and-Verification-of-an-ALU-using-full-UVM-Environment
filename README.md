# ALU Design and Verification using UVM

>This project implements and verifies an Arithmetic Logic Unit (ALU) using Universal Verification Methodology (UVM). The ALU performs various arithmetic and logical operations with comprehensive UVM-based verification.

## 🚀 Table of Contents
- **ALU Design** : `Module Interface` `State Machine Architecture` `Special Handling`


## ⚙️ ALU Design
This is a configurable Arithmetic Logic Unit (ALU) implemented in SystemVerilog using a Finite State Machine (FSM) architecture. The ALU performs various arithmetic and logical operations on two input operands based on control signals and operation codes.

### Module Interface

<p align="left">
  <img width="600"  src="Images/alu.jpg"><br>
</p>

>##### Parameters
| Parameter     | Type    | Default | Description                     |
|--------------|---------|---------|---------------------------------|
| `Data_Width` | integer | 5       | Bit width of input operands     |

>##### Input Ports
| Signal         | Direction | Width       | Type    | Description                          |
|----------------|-----------|-------------|---------|--------------------------------------|
| `clk`          | input     | 1           | wire    | System clock                         |
| `rst_n`        | input     | 1           | wire    | Active-low asynchronous reset        |
| `ALU_en`       | input     | 1           | wire    | Master enable for ALU operations     |
| `Operand1_en`  | input     | 1           | wire    | Enable for Operand1 operations       |
| `Operand2_en`  | input     | 1           | wire    | Enable for Operand2 operations       |
| `Operand1`     | input     | Data_Width  | wire    | First input operand (signed)         |
| `Operand2`     | input     | Data_Width  | wire    | Second input operand (signed)        |
| `Operand1_op`  | input     | 3           | wire    | Operation code for Operand1 set      |
| `Operand2_op`  | input     | 2           | wire    | Operation code for Operand2 sets     |

>##### Output Ports
| Signal        | Direction | Width       | Type  | Description                     |
|---------------|-----------|-------------|-------|---------------------------------|
| `ALU_output`  | output    | Data_Width+1| reg   | ALU result (signed)             |


### State Machine Architecture
The ALU implements a 4-state Finite State Machine (FSM) that controls all operations which are:<br>
1- `IDLE State (2'b00)`<br>
2- `Operand1_set State (2'b01): ADD, SUB, XOR, AND1, AND2, XNOR, OR, NULL`<br>
3- `Operand2_set1 State (2'b10): NAND, ADD1, ADD2, NULL`<br>
4- `Operand2_set2 State (2'b11): XOR, XNOR, DEC_Operand1, INC_Operand2`<br>
>##### Machine State diagram


### Special Handling

* Same-State Output Issue:
  * When staying in the same state, the output is recalculated based on new inputs
  * Prevents output stagnation when performing consecutive operations in the same state

* Bitwise Operation Handling:
  * All bitwise operations (AND, OR, XOR, etc.) are zero-extended to 6 bits
  * MSB is explicitly set to 0 for bitwise results
* Reset Behavior:
  * Asynchronous reset brings the FSM to IDLE state
  * Output is maintained during disabled state (ALU_en=0)

### UVM Verification
- Complete UVM testbench architecture:
  - Sequencer, Driver, Monitor
  - Scoreboard with reference model
  - Coverage collector
  - Assertion-based checking
- 8 test sequences covering:
  - Basic operations
  - Edge cases
  - MSB handling
  - Repeated operations
- Functional coverage closure:
  - FSM coverage
  - Toggle coverage
  - Condition coverage

## Project Structure
ALU_project_UVM/<br>
├── rtl/ # RTL code <br>
│ └── alu.sv # ALU core with FSM<br>
├── tb/ # Testbench<br>
│ ├── alu_pkg.sv # UVM package<br>
│ ├── alu_if.sv # Interface<br>
│ ├── sequences/ # UVM sequences<br>
│ ├── tests/ # Test cases<br>
│ └── coverage/ # Coverage reports<br>
├── sim/ # Simulation<br>
│ ├── run_sim.sh # Run script<br>
│ └── results/ # Logs/waveforms<br>
├── docs/ # Documentation<br>
│ └── presentation.pptx # Project slides<br>
└── README.md # This file<br>
