class Test4_Virtual_Sequence extends uvm_sequence;
    `uvm_object_utils(Test4_Virtual_Sequence)

    // Declare sequence objects for different types of operations
    ALU_Sequencer sequencer;
    ALU_en_sequence basic_sequence;
    State_Transation_sequence state_tr;

    // Pre-body task 
    virtual task pre_body();
        // Create instances of each sequence
  		basic_sequence = ALU_en_sequence           :: type_id :: create ("basic_sequence");
  		state_tr       = State_Transation_sequence :: type_id :: create ("state_tr"); 
	endtask


    virtual task body();
        // Main body task 
        basic_sequence.start(sequencer);
        state_tr.start(sequencer);
    endtask
endclass