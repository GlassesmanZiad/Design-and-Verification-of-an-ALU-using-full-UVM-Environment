class Operand2_set1_basic_sequence extends uvm_sequence;

    `uvm_object_utils(Operand2_set1_basic_sequence)  
    ALU_Packet Packet;  
    ALU_config cnfg;    // Configuration object for ALU

    function new (string name = "Operand2_set1_basic_sequence");
        super.new(name);
    endfunction

    // Pre-body 
    virtual task pre_body();
        Packet = ALU_Packet::type_id::create("Packet"); 
        if (!uvm_config_db#(ALU_config)::get(null, "", "cnfg", cnfg))  // Retrieve the configuration from the UVM database
            `uvm_fatal(get_full_name(), "can't get config for Operand1_basic_sequence")  
    endtask : pre_body

    // Body task
    virtual task body();
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM); 
        `uvm_info(get_type_name, $sformatf("                Test_initialized : Operand2_set1 Randomization"), UVM_MEDIUM);  
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        
        repeat(100) begin
            this.pre_body();  // Execute pre-body task to create a new packet and retrieve config
            Packet.Operand2_set1_constraint.constraint_mode(1); 

            if (!Packet.randomize()) begin
                `uvm_fatal("RANDOMIZATION_FAILED", "Randomization of the transaction failed!");
            end
            
            // Apply configuration to the packet
            cnfg.configure_Packet(Packet);
            
            // Send the packet through UVM sequence
            `uvm_send(Packet);
        end
        `wait_last_transaction(15)
    endtask : body

endclass
