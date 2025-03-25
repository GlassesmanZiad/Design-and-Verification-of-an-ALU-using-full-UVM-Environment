// Transaction class for ALU verification
class ALU_Packet extends uvm_sequence_item;

// Define data width parameter
parameter Data_width = 5;

// Control signals
rand  bit ALU_en;         // ALU enable signal
rand  bit Operand1_en;    // Operand1 enable signal
rand  bit Operand2_en;    // Operand2 enable signal

// Input operands
rand logic signed [Data_width - 1 : 0] Operand1;    // First operand
rand logic signed [Data_width - 1 : 0] Operand2;    // Second operand

// Operation selection signals
rand bit [2:0] Operand1_op;    // Operation selector for Operand1
rand bit [1:0] Operand2_op;    // Operation selector for Operand2

// ALU output
logic signed [Data_width  : 0] ALU_out;    // Result of ALU operation

`uvm_object_utils_begin(ALU_Packet)
    `uvm_field_int(ALU_en,UVM_ALL_ON)
    `uvm_field_int(Operand1_en,UVM_ALL_ON)
    `uvm_field_int(Operand2_en,UVM_ALL_ON)
    `uvm_field_int(Operand1,UVM_ALL_ON)
    `uvm_field_int(Operand2,UVM_ALL_ON)
    `uvm_field_int(Operand1_op,UVM_ALL_ON)
    `uvm_field_int(Operand2_op,UVM_ALL_ON)
    `uvm_field_int(ALU_out,UVM_ALL_ON)
`uvm_object_utils_end

// Constraint blocks for different test scenarios
constraint ALU_en_off_case {{ALU_en == 1'b0};}                    // ALU disabled case
constraint ALU_en_on_case  {{ALU_en == 1'b1};}                    // ALU enabled case

// Constraints for operand enable combinations
constraint Operand1_set_constraint{{Operand1_en == 1'b1};         // Only Operand1 enabled
                                   {Operand1_en != Operand2_en};}
constraint Operand2_set1_constraint {{Operand2_en == 1'b1};       // Only Operand2 enabled
                                     {Operand1_en != Operand2_en};}
constraint Operand2_set2_constraint {{Operand1_en == 1'b1};       // Both operands enabled
                                     {Operand2_en == 1'b1};}

// Edge case testing with maximum values
constraint Operands_Edge {
                            Operand1 inside {15,-16};
                            Operand1 dist {15:=50, -16:=50};
                            Operand2 inside {15,-16};
                            Operand2 dist {15:=50, -16:=50};
                            if(Operand1_en && Operand2_en){
                              Operand2_op != 2;
                              Operand2_op != 3;
                            }
                        }



// Constraint for bitwise operations
constraint bitwise_operation_case{Operand1_op inside {[2:6]};     // Valid Operand1 operations
                                  if(~Operand1_en && Operand2_en){
                                    Operand2_op == 0;
                                  }
                                  if(Operand1_en && Operand2_en){
                                    Operand2_op inside {[0:1]};
                                  }
                                 }     // Valid Operand2 operations

// Constructor: Initially disable all constraints
function new();
      ALU_en_off_case.constraint_mode(0);
      ALU_en_on_case.constraint_mode(0);
      Operand1_set_constraint.constraint_mode(0);
      Operand2_set1_constraint.constraint_mode(0);
      Operand2_set2_constraint.constraint_mode(0);
      ALU_en_on_case.constraint_mode(0);
      Operands_Edge.constraint_mode(0);
      bitwise_operation_case.constraint_mode(0);
endfunction

endclass

