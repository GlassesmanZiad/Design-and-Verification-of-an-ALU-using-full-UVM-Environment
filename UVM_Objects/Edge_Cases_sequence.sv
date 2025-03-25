class Edge_Cases_sequence extends uvm_sequence;

    `uvm_object_utils(Edge_Cases_sequence)   

    ALU_Packet Packet;         
    ALU_config cnfg;             // Configuration object for ALU setup

    function new (string name = "Edge_Cases_sequence");
        super.new(name); 
    endfunction

    // Pre-body 
    virtual task pre_body();
        Packet = ALU_Packet ::type_id::create("Packet");
        
        // Retrieve configuration from the UVM config database
        if (!uvm_config_db#(ALU_config)::get(null, "", "cnfg", cnfg)) 
            `uvm_fatal(get_full_name(), "can't get config for Operand1_basic_sequence") 
    endtask : pre_body

    // Body 
    virtual task body();
        `uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("                Test_initialized : Edge_cases"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);
        
        repeat(100) begin
            // Call pre-body to initialize Packet and configuration
            this.pre_body();
            
            // Apply edge constraints on operands
            Packet.Operands_Edge.constraint_mode(1);
            
            if (!Packet.randomize()) begin
                `uvm_fatal("RANDOMIZATION_FAILED", "Randomization of the transaction failed!");
            end
            
            // Configure the Packet using the configuration
            cnfg.configure_Packet(Packet);
            
            // Send the randomized and configured packet
            `uvm_send (Packet)
        end
        
        // Wait for the last transaction to finish before completing the sequence
        `wait_last_transaction(15)
    endtask : body

endclass
