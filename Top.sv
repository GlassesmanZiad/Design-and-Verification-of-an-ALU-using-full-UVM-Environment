import uvm_pkg::*;  
import MyPackage::*; 
`include "ALU_intf.sv"  

module Top(); 

    // Define signals for the testbench
    bit clk; 
    bit reset;  

    always #5 clk = ~clk;

    // Instantiate the ALU interface with the clock signal
    ALU_intf intf(clk);

    // Instantiate the DUT (Design Under Test)
    ALU DUT (
        .clk(clk),  
        .rst_n(intf.intf_rst_n),  
        .ALU_en(intf.intf_ALU_en), 
        .Operand1_en(intf.intf_Operand1_en),  
        .Operand2_en(intf.intf_Operand2_en),  
        .Operand1(intf.intf_Operand1), 
        .Operand2(intf.intf_Operand2),  
        .Operand1_op(intf.intf_Operand1_op), 
        .Operand2_op(intf.intf_Operand2_op),  
        .ALU_output(intf.intf_ALU_out)  
    );

    // Initial block for UVM configuration and running the test
    initial begin
        // Set the UVM configuration for virtual interface
        uvm_config_db #(virtual ALU_intf) :: set(null, "*", "vif", intf);
        
        // Start the UVM test execution
        run_test();
    end

    // Initial block to configure waveform dumping and finish the simulation
    final begin
        // Configure waveform dumping for simulation analysis
        $dumpfile("waves.vpd");  // Specify the waveform dump file
        $dumpvars(0, Top);  // Dump all signals from the Top module
    end

endmodule
