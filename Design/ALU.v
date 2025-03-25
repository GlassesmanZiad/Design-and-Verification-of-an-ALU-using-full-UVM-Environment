// -----------------------------------------------------------------------------
// Define macro for next state logic used throughout the FSM

// -----------------------------------------------------------------------------
`define NEXT_STATE_LOGIC(Operand1_en, Operand2_en, next_state)\
    case({Operand1_en,Operand2_en})      				      \
	2'b10  : next_state <= Operand1_set;				      \
	2'b01  : next_state <= Operand2_set1;                     \
	2'b11  : next_state <= Operand2_set2;                     \
	default: next_state <= IDLE;                              \
     endcase
                                                                
                                                            
/*
* Arithmetic Logic Unit (ALU) module that performs various arithmetic and logical operations
* on two operands based on operation codes and enable signals.
*
* Parameters:
*   Data_Width - Width of input operands (default: 5 bits)
*
* Inputs:
*   clk         - Clock signal
*   rst_n       - Active low asynchronous reset
*   ALU_en      - ALU enable signal
*   Operand1_en - Enable signal for first operand
*   Operand2_en - Enable signal for second operand
*   Operand1    - First input operand [Data_Width-1:0]
*   Operand2    - Second input operand [Data_Width-1:0]
*   Operand1_op - Operation select for Operand1 set (3 bits)
*   Operand2_op - Operation select for Operand2 sets (2 bits)
*
* Outputs:
*   ALU_output  - Result of ALU operation (6 bits signed)
*/

// ALU module with configurable data width

module ALU #(parameter Data_Width = 5) (
    input wire clk,
    input wire rst_n,          // Active low reset

    // Control signals
    input wire ALU_en,         // ALU enable
    input wire Operand1_en,    // First operand enable
    input wire Operand2_en,    // Second operand enable

    // Data inputs
    input wire signed [Data_Width - 1:0] Operand1,
    input wire signed [Data_Width - 1:0] Operand2,

    // Operation selection
    input wire [2:0] Operand1_op,   // Operation select for Operand1
    input wire [1:0] Operand2_op,   // Operation select for Operand2

    // Result output
    output reg signed [Data_Width:0] ALU_output
);

// FSM state definitions

localparam  IDLE          = 2'b00,     // IDLE state
            Operand1_set  = 2'b01,     // Processing Operand1 operations
            Operand2_set1 = 2'b10,     // Processing Operand2 first set operations
            Operand2_set2 = 2'b11;      // Processing Operand2 second set operations


// Operation codes for Operand1 processing
localparam Operand1_set_ADD  = 3'b000,
           Operand1_set_SUB  = 3'b001,
           Operand1_set_XOR  = 3'b010,
           Operand1_set_AND1 = 3'b011,
           Operand1_set_AND2 = 3'b100,
           Operand1_set_XNOR = 3'b101,
           Operand1_set_OR   = 3'b110,
           Operand1_set_NULL = 3'b111;

// Operation codes for Operand2 first set
localparam Operand2_set1_NAND  = 2'b00,
           Operand2_set1_ADD1  = 2'b01,
           Operand2_set1_ADD2  = 2'b10,
           Operand2_set1_NULL  = 2'b11;

// Operation codes for Operand2 second set
localparam Operand2_set2_XOR           = 2'b00,
           Operand2_set2_XNOR          = 2'b01,
           Operand2_set2_DEC_Operand1  = 2'b10,
           Operand2_set2_INC_Operand2  = 2'b11;           

reg [1:0] state, next_state;

// Sequential state register with async reset
always @(posedge clk or negedge rst_n) begin
    if (~ rst_n)
        state <= IDLE;  
    else begin
        if (ALU_en) begin
            if (state == next_state) begin
                case ({Operand1_en,Operand2_en})
			2'b10: begin
                    			case (Operand1_op)                                        
                        			3'b000 : ALU_output <= Operand1 + Operand2;           
                        			3'b001 : ALU_output <= Operand1 - Operand2;           
                        			3'b010 : ALU_output <= {1'b0,Operand1 ^ Operand2};    
                        			3'b011 : ALU_output <= {1'b0,Operand1 & Operand2};    
                        			3'b100 : ALU_output <= {1'b0,Operand1 & Operand2};    
                        			3'b101 : ALU_output <= {1'b0,Operand1 | Operand2};   
                        			3'b110 : ALU_output <= {1'b0,Operand1 ~^ Operand2};    
                        			3'b111 : ALU_output <= ALU_output;                    
                    			endcase   
                		end
               		2'b01: begin
                    			case (Operand2_op)
                        			Operand2_set1_NAND : ALU_output <= {1'b0,~(Operand1 & Operand2)};                         
                        			Operand2_set1_ADD1 : ALU_output <= Operand1 + Operand2;                         
                        			Operand2_set1_ADD2 : ALU_output <= Operand1 + Operand2;                         
                        			Operand2_set1_NULL : ALU_output <= ALU_output;                         
                    			endcase
                		end
                	2'b11: begin
                    		case (Operand2_op)
                        		Operand2_set2_XOR         : ALU_output <= {1'b0,Operand1 ^ Operand2};                         
                        		Operand2_set2_XNOR        : ALU_output <= {1'b0,Operand1 ~^ Operand2};                         
                        		Operand2_set2_DEC_Operand1: ALU_output <= Operand1 - 1;                         
                        		Operand2_set2_INC_Operand2: ALU_output <= Operand2 + 2;                                  
                    		endcase
                	end
		endcase                                                                    
            end else state <= next_state;
        end else ALU_output <= ALU_output; 
    end 
end

// Next state logic based on current state and enable signals
always @(state or Operand1_en or Operand2_en) begin
    if (ALU_en) begin
        case(state)
                IDLE: begin
                    `NEXT_STATE_LOGIC(Operand1_en, Operand2_en, next_state)
                end
                // Perform Operand1 operations
                Operand1_set: begin
                    `NEXT_STATE_LOGIC(Operand1_en, Operand2_en, next_state)
                end
                // Perform Operand2 first set operations
                Operand2_set1: begin
                    `NEXT_STATE_LOGIC(Operand1_en, Operand2_en, next_state)
                end
                // Perform Operand2 second set operations
                Operand2_set2: begin
                    `NEXT_STATE_LOGIC(Operand1_en, Operand2_en, next_state)
                end
        endcase
    end
    else
        next_state = IDLE;
end

// Output logic based only on current state
always @(state) begin 
        case(state)
                IDLE: begin
                    ALU_output <= ALU_output;
                end
                Operand1_set: begin
                    case (Operand1_op)
                        Operand1_set_ADD: begin
                            ALU_output <= Operand1 + Operand2;                        
                        end 
                        Operand1_set_SUB: begin
                            ALU_output <= Operand1 - Operand2;                          
                        end
                        Operand1_set_XOR: begin
                            ALU_output <= {1'b0,Operand1 ^ Operand2};                         
                        end
                        Operand1_set_AND1: begin
                            ALU_output <= {1'b0,Operand1 & Operand2};                        
                        end
                        Operand1_set_AND2: begin
                            ALU_output <= {1'b0,Operand1 & Operand2};                          
                        end
                        Operand1_set_XNOR: begin
                            ALU_output <= {1'b0,Operand1 | Operand2};                         
                        end
                        Operand1_set_OR: begin
                            ALU_output <= {1'b0,Operand1 ~^ Operand2};                        
                        end                        
                        Operand1_set_NULL: begin
                            ALU_output <= ALU_output;                          
                        end                                           
                    endcase
                end
                Operand2_set1: begin
                    case (Operand2_op)
                        Operand2_set1_NAND: begin
                            ALU_output <= {1'b0,~(Operand1 & Operand2)};                         
                        end 
                        Operand2_set1_ADD1: begin
                            ALU_output <= Operand1 + Operand2;                         
                        end
                        Operand2_set1_ADD2: begin
                            ALU_output <= Operand1 + Operand2;                         
                        end
                        Operand2_set1_NULL: begin
                            ALU_output <= ALU_output;                         
                        end
                    endcase
                end
                Operand2_set2: begin
                    case (Operand2_op)
                        Operand2_set2_XOR: begin
                            ALU_output <= {1'b0,Operand1 ^ Operand2};                         
                        end
                        Operand2_set2_XNOR: begin
                            ALU_output <= {1'b0,Operand1 ~^ Operand2};                         
                        end
                        Operand2_set2_DEC_Operand1: begin
                            ALU_output <= Operand1 - 1;                         
                        end
                        Operand2_set2_INC_Operand2: begin
                            ALU_output <= Operand2 + 2;                         
                        end             
                    endcase                
                end
        endcase
    end
// Initialize state and output
initial begin
    state = IDLE;
    ALU_output = 0;
end
endmodule

