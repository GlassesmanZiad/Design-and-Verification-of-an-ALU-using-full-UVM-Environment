class Repeat_Operation_sequence extends uvm_sequence;

    `uvm_object_utils(Repeat_Operation_sequence) 
    ALU_Packet Packet;
    ALU_config cnfg;  // ALU configuration object to configure the packet
    reg [2:0] operation;  // Register to store the operation to repeat
    reg [2:0] counter ;  // Counter to track how many times the operation has been repeated
    function new (string name = "Edge_Cases_sequence");
        super.new(name);
        counter = 0;
    endfunction

    // Pre-body task
    virtual task pre_body();
        Packet = ALU_Packet::type_id::create("Packet");  
        if (!uvm_config_db#(ALU_config)::get(null, "", "cnfg", cnfg))  // Retrieve configuration from the UVM config DB
            `uvm_fatal(get_full_name(), "can't get config for Operand1_basic_sequence");
    endtask : pre_body

    // Body task
    virtual task body();
        
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);  
        `uvm_info(get_type_name, $sformatf("                Test_initialized : Repeat_operation"), UVM_MEDIUM);  
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);  
        
        Packet = ALU_Packet::type_id::create("Packet");
        
        repeat(200) begin
            if (!Packet.randomize()) begin 
                `uvm_fatal("RANDOMIZATION_FAILED", "Randomization of the transaction failed!");  // Fatal error if randomization fails
            end
            
            // Check counter value to determine behavior for repeating operation
            if (counter == 0) begin  // If this is the first packet, store the initial operation
                counter = counter + 1;  // Increment counter to keep track of iterations
                cnfg.configure_Packet(Packet);  // Configure the packet with settings from the config object
                if (Packet.Operand1_en && ~Packet.Operand2_en) begin
                    operation = Packet.Operand1_op;  // Store the Operand1 operation   
                end else operation = Packet.Operand2_op;  // Store the Operand2 operation 
                `uvm_send(Packet);  // Send the packet
            end else if(counter < 5) begin  // If counter is less than 5, repeat the same operation
                void'(Packet.randomize());  // Randomize again while keeping the operation the same
                counter = counter + 1;  // Increment counter
                cnfg.configure_Packet(Packet);  // Configure the packet with settings from the config object
                if (Packet.Operand1_en && ~Packet.Operand2_en) begin
                    Packet.Operand1_op = operation;  // Store the Operand1 operation   
                end else Packet.Operand2_op = operation;  // Store the Operand2 operation 
                `uvm_send(Packet);  // Send the packet
            end else begin  // After 5 repetitions, reset the counter and randomize a new operation
                void'(Packet.randomize());  // Randomize the packet again
                counter = 0;  // Reset counter after 5 repetitions
                cnfg.configure_Packet(Packet);  // Configure the packet
                if (Packet.Operand1_en && ~Packet.Operand2_en) begin
                    Packet.Operand1_op = operation;  // Store the Operand1 operation   
                end else Packet.Operand2_op = operation;  // Store the Operand2 operation 
                `uvm_send(Packet);  // Send the packet
            end
        end
        `wait_last_transaction(15);  // Wait for the last transaction to complete before finishing the sequence
    endtask : body

endclass
