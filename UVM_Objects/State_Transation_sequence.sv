class State_Transation_sequence extends uvm_sequence;

    `uvm_object_utils(State_Transation_sequence)
    
    // Declare the ALU Packet and configuration object
    ALU_Packet Packet;
    ALU_config cnfg;

    function new (string name = "Edge_Cases_sequence");
        super.new(name);
    endfunction

    // Pre-body task 
    virtual task pre_body();
        Packet = ALU_Packet::type_id::create("Packet");

        // retrieve the ALU configuration from the uvm_config_db
        if (!uvm_config_db#(ALU_config)::get(null, "", "cnfg", cnfg))
            `uvm_fatal(get_full_name(), "can't get config for Operand1_basic_sequence");
    endtask : pre_body

    // body 
    virtual task body();
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("                Test_initialized : State_transitions"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        
        repeat(100) begin
            // Execute pre-body to prepare the packet and configuration
            this.pre_body();

            if (!Packet.randomize()) begin
                `uvm_fatal("RANDOMIZATION_FAILED", "Randomization of the transaction failed!");
            end

            // Check if the test is not "Initialize_Test" and configure the packet if necessary
            if (uvm_root::get().find("uvm_test_top").get_type_name() != "Initialize_Test") begin
                cnfg.configure_Packet(Packet); // Apply the configuration to the packet
            end

            // Set ALU enable signal to 1 and send the packet
            Packet.ALU_en = 1'b1;
            `uvm_send(Packet); // Send the packet to the sequencer
        end
        
        // Wait for the last transaction to complete (timeout of 10 time units)
        `wait_last_transaction(10);
    endtask : body

endclass
