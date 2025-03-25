interface ALU_intf(input logic clk);
    // Define bit width for operands
    parameter Data_width = 5;

    // Interface signal declarations
    logic intf_rst_n;                              // Active-low reset
    logic intf_ALU_en;                            // ALU enable signal
    logic intf_Operand1_en;                       // Operand 1 enable
    logic intf_Operand2_en;                       // Operand 2 enable
    logic signed [Data_width - 1 : 0] intf_Operand1;     // First operand
    logic signed [Data_width - 1 : 0] intf_Operand2;     // Second operand
    logic [2:0] intf_Operand1_op;                 // Operation select for operand 1
    logic [1:0] intf_Operand2_op;                 // Operation select for operand 2
    logic signed [Data_width : 0] intf_ALU_out;          // ALU output result

    // Clocking block for synchronous signal sampling
    clocking cb @(posedge clk);
        default input #2 output #2;               // Default timing for inputs/outputs
        input intf_ALU_out;
        output intf_ALU_en;
        output intf_Operand1_en;
        output intf_Operand2_en;
        output intf_Operand1;
        output intf_Operand2;
        output intf_Operand1_op;
        output intf_Operand2_op;
    endclocking

/************************ Assertions ************************/

    //Check for the stability of the Output if ALU_en is 0
    property ALU_en_Stability_Asser;
        @(posedge clk) disable iff (!intf_rst_n)
        !intf_ALU_en |=> $stable(intf_ALU_out);
    endproperty
    assert property (ALU_en_Stability_Asser)
        else $error("Output isn't stable while ALU was disabled");

    property ALU_output_correct;
        @(posedge clk) disable iff (!intf_rst_n || !intf_ALU_en)
        (intf_Operand1_en && !intf_Operand2_en && intf_Operand1_op == 3'b000) |=> 
        intf_ALU_out == ($past(intf_Operand1,1) + $past(intf_Operand2,1));
    endproperty

assert property (ALU_output_correct)
    else $error("ALU output is incorrect for the ADD operation and the value is: %0d " ,intf_ALU_out);
    

    // Checks for the output isn't X when we have an operations in operand2_set2
    property Operand2_set2_Asser;
        @(posedge clk) disable iff (intf_rst_n == 1'b0 || intf_ALU_en == 1'b0)
        (intf_Operand1_en && intf_Operand2_en) |=> (intf_ALU_out !== 'x);
    endproperty
    assert property (Operand2_set2_Asser)
        else $error("ALU output is Unknown");



    // Check for the output that isn't unkown
    property Valid_out_Asser;
        @(posedge clk) disable iff (intf_rst_n == 1'b0 || intf_ALU_en == 1'b0)
        intf_ALU_out !== 'x;
    endproperty
    assert property (Valid_out_Asser)
        else $error("ALU output is unknown");


endinterface