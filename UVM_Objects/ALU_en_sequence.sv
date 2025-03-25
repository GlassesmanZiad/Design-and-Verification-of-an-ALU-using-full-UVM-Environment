class ALU_en_sequence extends uvm_sequence;

    `uvm_object_utils(ALU_en_sequence)
    ALU_Packet Packet;

    virtual task pre_body();
        Packet = ALU_Packet::type_id::create("Packet");
    endtask : pre_body

    function new(string name = "ALU_en_sequence");
        super.new(name); 
    endfunction

    virtual task body();
        //info message to indicate the sequence start
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("                Test_initialized : ALU_en is off"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);

        repeat(16) begin
            // Call pre_body to initialize the Packet before each iteration
            this.pre_body();
            Packet.ALU_en_off_case.constraint_mode(1);    // Enable ALU-off constraints
            if (!Packet.randomize()) begin
                `uvm_fatal("RANDOMIZATION_FAILED", "Randomization of the transaction failed!");
            end

            // Send the randomized Packet over the sequencer
            `uvm_send(Packet)
        end
        // Wait for the last transaction to finish (10 time units here)
        `wait_last_transaction(10)
    endtask : body
endclass
