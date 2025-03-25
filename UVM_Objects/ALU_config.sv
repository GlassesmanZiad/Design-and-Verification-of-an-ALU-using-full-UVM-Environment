// ALU_config class that is used for configuring the ALU_Packet based on certain configuration parameters
class ALU_config extends uvm_object;

    `uvm_object_utils(ALU_config)
      bit driver_started;
      bit Operand1_en;  
      bit Operand2_en; 
    // Function to configure an ALU_Packet 
    function void configure_Packet(ALU_Packet Packet); 
        Packet.Operand1_en = Operand1_en;
        Packet.Operand2_en = Operand2_en;
        Packet.ALU_en = 1'b1; 
    endfunction

    // Constructor for ALU_config class
    function new(string name = "ALU_config");
        super.new(name); 

        // Initialize configuration parameters
        driver_started = 0;
        Operand1_en = 1'b0;  
        Operand2_en = 1'b0;  
    endfunction

endclass
