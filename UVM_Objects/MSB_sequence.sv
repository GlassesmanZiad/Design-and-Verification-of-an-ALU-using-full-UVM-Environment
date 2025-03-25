class MSB_sequence extends uvm_sequence;

    `uvm_object_utils(MSB_sequence) 
    ALU_Packet Packet;  
    ALU_config cnfg;    // Declare ALU configuration object to hold configuration data

    function new (string name = "Edge_Cases_sequence");
        super.new(name);
    endfunction

    // Pre-body 
    virtual task pre_body();
        Packet = ALU_Packet ::type_id::create("Packet");
        
        // Retrieve configuration from the UVM config database
        if (!uvm_config_db#(ALU_config)::get(null, "", "cnfg", cnfg)) 
            `uvm_fatal(get_full_name(), "can't get config for Operand1_basic_sequence"); 
    endtask : pre_body

    // Body task
    virtual task body();
        `uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("                Test_initialized : MSB_test"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);

        repeat(100) begin
            this.pre_body();  // Call pre-body task to initialize packet and retrieve configuration
            
            // Apply the bitwise_operation_case constraint to the packet 
            Packet.bitwise_operation_case.constraint_mode(1);
            
            if (!Packet.randomize()) begin
                `uvm_fatal("RANDOMIZATION_FAILED", "Randomization of the transaction failed!"); 
            end
            
            // Configure the packet with the values from the ALU_config object
            cnfg.configure_Packet(Packet);
            
            // Send the configured packet
            `uvm_send(Packet);
        end
        
        // Wait for the last transaction to complete (with a timeout of 15 units)
        `wait_last_transaction(15);
    endtask : body

endclass
