class Test3_Virtual_Sequence extends uvm_sequence;
    `uvm_object_utils(Test3_Virtual_Sequence)

    // Declare sequence objects for different types of operations
    ALU_Sequencer sequencer;
    Operand2_set2_basic_sequence basic_sequence;
    Edge_Cases_sequence edge_cases_sequence;
    MSB_sequence msb_sequence;
    Repeat_Operation_sequence repeat_op_sequence;

    // Pre-body task 
    virtual task pre_body();
        // Create instances of each sequence
  		basic_sequence      = Operand2_set2_basic_sequence   :: type_id :: create ("basic_sequence");
  		edge_cases_sequence = Edge_Cases_sequence            :: type_id :: create ("edge_cases_sequence"); 
        msb_sequence        = MSB_sequence                   :: type_id :: create ("msb_sequence"); 
        repeat_op_sequence  = Repeat_Operation_sequence      :: type_id :: create ("repeat_op_sequence");
	endtask

    // Main body task 
    virtual task body();
        basic_sequence.start(sequencer);
        repeat_op_sequence.start(sequencer);
        edge_cases_sequence.start(sequencer);
        msb_sequence.start(sequencer);
    endtask
endclass