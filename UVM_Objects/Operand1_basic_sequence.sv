class Operand1_basic_sequence extends uvm_sequence;

    `uvm_object_utils(Operand1_basic_sequence)
    ALU_Packet Packet;   
    ALU_config cnfg;     // Configuration object for ALU

    function new (string name = "Operand1_basic_sequence");
        super.new(name);  
    endfunction

    // Pre-body task
    virtual task pre_body();
        Packet = ALU_Packet ::type_id::create("Packet");
        
        // Retrieve ALU configuration from the global config DB
        if (!uvm_config_db#(ALU_config)::get(null, "", "cnfg", cnfg)) begin
            `uvm_fatal(get_full_name(), "can't get config for Operand1_basic_sequence")
        end
        
        `uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("                Test_initialized : Operand1_set Randomization"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);
    endtask : pre_body

    // Body of the sequence
    virtual task body();
        // Create a new ALU_Packet for each execution of the body task
        Packet = ALU_Packet ::type_id::create("Packet");
        
        repeat(100) begin
            if (!Packet.randomize()) begin
                `uvm_fatal("RANDOMIZATION_FAILED", "Randomization of the transaction failed!");
            end
            
            // Apply configuration to the packet
            cnfg.configure_Packet(Packet);
            
            `uvm_info(get_type_name,$sformatf("ALU_en: %b , op1_en: %b , op2_en: %b",Packet.ALU_en,Packet.Operand1_en,Packet.Operand2_en),UVM_HIGH);  
            
            // Send the randomized packet
            `uvm_send (Packet)
        end
        
        // Wait for the last transaction to complete before ending the task
        `wait_last_transaction(15)
    endtask : body

endclass
