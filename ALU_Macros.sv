/*******************************************************************************************************************/
/******************************************     Macros Summary     ************************************************/
/*******************************************************************************************************************/
// `get_operation` Macro:
// This macro is responsible for determining the operation to be performed based on the combination
// of `Operand1_en` and `Operand2_en`. It checks the operation type for both operands (`Operand1_op`
// and `Operand2_op`) and sets a corresponding description for the operation. The result is used in
// the ALU computation for different types of operations such as summation, subtraction, bitwise 
// operations, and more.


// `Check` Macro:
// This macro checks if the ALU output (`ALU_out`) matches the expected result based on the 
// provided operands and operations. It logs detailed information about the ALU packet and 
// compares the actual output with the expected output for different operation combinations. 
// If the output matches, it logs a test pass message, and if it does not match, it logs an error.
// The macro also increments the test case counter and logs information for special cases when
// operands are not enabled or certain operations do not apply.


// `wait_last_transaction` Macro:
// This macro is used to simulate a delay for the last transaction in the simulation. It allows
// the testbench to wait for a specified amount of time before proceeding with the next action, 
// ensuring proper synchronization of transactions.
/*******************************************************************************************************************/
/*******************************************************************************************************************/

// This macro defines the operation based on the values of Operand1_en and Operand2_en\
`define get_operation(Packet, set, operation) \
    // Check combination of Operand1_en and Operand2_en\
    case ({Packet.Operand1_en, Packet.Operand2_en}) \
        2'b10 : begin \
            set = "Operand1 set"; \
            case (Packet.Operand1_op) \
                3'b000: operation = "Summation"; \
                3'b001: operation = "Subtraction"; \
                3'b010: operation = "Bitwise XOR"; \
                3'b011: operation = "Bitwise AND"; \
                3'b100: operation = "Bitwise AND"; \
                3'b101: operation = "Bitwise OR"; \
                3'b110: operation = "Bitwise XNOR"; \
                3'b111: operation = "NULL Operation"; \
            endcase \
        end \
        2'b01 : begin \
            set = "Operand2 set1"; \
            case (Packet.Operand2_op) \
                2'b00: operation = "NAND"; \
                2'b01: operation = "Summation"; \
                2'b10: operation = "Summation"; \
                2'b11: operation = "NULL Operation"; \
            endcase \
        end \
        2'b11 : begin \
            set = "Operand2 set2"; \
            case (Packet.Operand2_op) \
                2'b00: operation = "Bitwise XOR"; \
                2'b01: operation = "Bitwise XNOR"; \
                2'b10: operation = "Subtracting 1 from first Operand"; \
                2'b11: operation = "Adding 2 to second Operand"; \
            endcase \
        end \
        default: begin \
            operation = "NULL"; \
            set = "NULL"; \
        end \
    endcase

// This macro checks if the ALU output is as expected, reports the result, and logs the test result.\
`define Check(Packet, actual_out, counter) \
    if (Packet.ALU_en) begin \
    //$display("op1: %0b,op2: %0b",Packet.Operand1_en, Packet.Operand2_en);\
        case ({Packet.Operand1_en, Packet.Operand2_en}) \
            2'b10 : begin \
            `uvm_info(get_type_name, $sformatf("ALU_Packet: ALU_en=%0b, Operand1_en=%0b, Operand2_en=%0b, Operand1=%0d, Operand2=%0d, Operand1_op=%0h, Operand2_op=%0h, ALU_out=%0d",Packet.ALU_en, Packet.Operand1_en, Packet.Operand2_en, Packet.Operand1, Packet.Operand2, Packet.Operand1_op, Packet.Operand2_op, Packet.ALU_out), UVM_HIGH)\
                case (Packet.Operand1_op) \
                    3'b000: actual_out = Packet.Operand1 + Packet.Operand2; \
                    3'b001: actual_out = Packet.Operand1 - Packet.Operand2; \
                    3'b010: actual_out[4:0] = Packet.Operand1 ^ Packet.Operand2; \
                    3'b011: actual_out[4:0] = Packet.Operand1 & Packet.Operand2; \
                    3'b100: actual_out[4:0] = Packet.Operand1 & Packet.Operand2; \
                    3'b101: actual_out[4:0] = Packet.Operand1 | Packet.Operand2; \
                    3'b110: actual_out[4:0] = Packet.Operand1 ~^ Packet.Operand2; \
                    3'b111: actual_out = Packet.ALU_out; \
                endcase \
            end \
            2'b01 : begin \
                case (Packet.Operand2_op) \
                    2'b00: actual_out[4:0] = ~(Packet.Operand1 & Packet.Operand2); \
                    2'b10: actual_out = Packet.Operand1 + Packet.Operand2; \
                    2'b01: actual_out = Packet.Operand1 + Packet.Operand2; \
                    default: actual_out = Packet.ALU_out; \
                endcase \
            end \
            2'b11 : begin \
                case (Packet.Operand2_op) \
                    2'b00: actual_out[4:0] = Packet.Operand1 ^ Packet.Operand2; \
                    2'b01: actual_out[4:0] = Packet.Operand1 ~^ Packet.Operand2; \
                    2'b10: actual_out = Packet.Operand1 - 1; \
                    2'b11: actual_out = Packet.Operand2 + 2; \
                endcase \
            end \
            default: actual_out = Packet.ALU_out;\
        endcase \
        // Check if the actual output matches the expected ALU output\
        if (actual_out == Packet.ALU_out) begin \
            case ({Packet.Operand1_en, Packet.Operand2_en}) \
                2'b11: begin \
                    // Special case when Operand2_op is 2'b10 or 2'b11\
                    case (Packet.Operand2_op) \
                        2'b10: begin \
                            `uvm_info(get_type_name, $sformatf("Test Case [%3d] %3d - 1 equals The ALU output which is %3d Test Passed!", counter, Packet.Operand1, Packet.ALU_out), UVM_MEDIUM) \
                        end \
                        2'b11: begin \
                            `uvm_info(get_type_name, $sformatf("Test Case [%3d] %3d + 2 equals The ALU output which is %3d Test Passed!", counter, Packet.Operand2, Packet.ALU_out), UVM_MEDIUM) \
                        end \
                        default: begin \
                            `uvm_info(get_type_name, $sformatf("Test Case [%3d] ALU output which is %3d equals actual output Test Passed!", counter, Packet.ALU_out), UVM_MEDIUM) \
                        end \
                    endcase \
                end \
                2'b10: begin \
                    // Case for Operand1_op = 3'b111 (no change in ALU output)\
                    if (Packet.Operand1_op == 3'b111) begin \
                        `uvm_info(get_type_name, $sformatf("Test Case [%3d] The ALU output remains the same which is %3d Test Passed!", counter, Packet.ALU_out), UVM_MEDIUM) \
                    end \
                    else \
                        `uvm_info(get_type_name, $sformatf("Test Case [%3d] ALU output which is %3d equals actual output Test Passed!", counter, Packet.ALU_out), UVM_MEDIUM) \
                end \
                2'b01: begin \
                    // Case for Operand2_op = 2'b11 (no change in ALU output)\
                    if (Packet.Operand2_op == 2'b11) begin \
                        `uvm_info(get_type_name, $sformatf("Test Case [%3d] The ALU output remains the same which is %3d Test Passed!", counter, Packet.ALU_out), UVM_MEDIUM) \
                    end \
                    else \
                        `uvm_info(get_type_name, $sformatf("Test Case [%3d] ALU output which is %3d equals actual output Test Passed!", counter, Packet.ALU_out), UVM_MEDIUM) \
                end \
                default: begin \
                    if (~Packet.Operand1_en && ~Packet.Operand2_en) begin \
                        `uvm_info(get_type_name, $sformatf("Test Case [%3d] Both Enable Operand1 and Enable Operand2 are not Active!", counter), UVM_MEDIUM) \
                    end \
                    else \
                        `uvm_info(get_type_name, $sformatf("Test Case [%3d] ALU output which is %3d equals actual output Test Passed!", counter, Packet.ALU_out), UVM_MEDIUM) \
                end \
            endcase \
            counter = counter + 1; \
        end \
        else begin \
            `uvm_error(get_type_name, $sformatf("Test Case [%3d] Checking Failed! The ALU output is %3d and the expected output is %3d", counter, Packet.ALU_out, actual_out), UVM_MEDIUM) \
            counter = counter + 1; \
        end \
    end \
    else begin \
        `uvm_info(get_type_name, $sformatf("Test Case [%3d] ALU_en is zero, ALU is OFF!",counter), UVM_MEDIUM) \
        counter = counter+1;\
    end

// This macro simulates a delay for the last transaction\
`define wait_last_transaction(delay) \
    #delay; 
