class Operand2_set1_test extends uvm_test ;

    `uvm_component_utils(Operand2_set1_test) 
    Test2_Virtual_Sequence vseq;  // Virtual sequence for the test
    ALU_config cnfg;  // ALU configuration object
    custom_report_server custom_server;  // Custom report server for managing UVM report output
    ALU_Env env; 
    int counter; // to count the ALU_en when it becomes zero (Debugging)

    function new (string name = "Operand2_set1_test", uvm_component parent = null);
        super.new(name, parent); 
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase ); 
        super.build_phase(phase);  
        env = ALU_Env::type_id::create("env", this);  
        vseq = Test2_Virtual_Sequence::type_id::create("vseq", null);  // Create the virtual sequence for the test
        cnfg = ALU_config::type_id::create("cnfg", null);  // Create the ALU configuration object
		// set the operation for operand2_set1 test
        cnfg.Operand1_en = 1'b0; 
        cnfg.Operand2_en = 1'b1;  
        uvm_config_db#(ALU_config)::set(null, "*", "cnfg", cnfg);  // Set the configuration in the UVM config database
        custom_server = new();  // Create a new custom report server
        uvm_report_server::set_server(custom_server);  // Set the custom report server
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase ); 
        super.connect_phase(phase); 
        vseq.sequencer = env.agent.sequencer;  // Connect the sequencer from the environment to the virtual sequence
    endfunction
    
    // Start of simulation phase
    virtual function void start_of_simulation_phase(uvm_phase phase);
        uvm_report_server server = uvm_report_server::get_server();  // Get the global report server
        server.set_max_quit_count(10);  // Set the maximum number of quits 
        this.set_report_verbosity_level(UVM_MEDIUM);  // Set the report verbosity level 
    endfunction
    
    // End of elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        this.print();  // Print the test information of the UVM Hirearchy
    endfunction

    // Run phase
    task run_phase(uvm_phase phase); 
        super.run_phase(phase);  
        phase.raise_objection(this);  
        vseq.start(null);  // Start the virtual sequence
        phase.drop_objection(this);  
    endtask

    // Report phase
    virtual function void report_phase(uvm_phase phase);
        uvm_report_server server = uvm_report_server::get_server();  // Get the global report server
        super.report_phase(phase); 
        
        // Retrieve a counter from the UVM config DB 
        if (!uvm_config_db#(int)::get(null, "*", "counter", counter))
            `uvm_fatal(get_full_name(), "can't get ALU_en_off from Monitor");  

        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);  
        `uvm_info(get_type_name, $sformatf("                                   Reporting Phase"), UVM_MEDIUM); 
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);

        // Check the report severity count for errors or warnings and report
        if (server.get_severity_count(UVM_ERROR) > 5) begin
            `uvm_error(get_type_name, "Reporting Phase: Test failed with errors");  // Report error if there are more than 5 errors
        end else if (server.get_severity_count(UVM_WARNING) > 5) begin
            `uvm_warning(get_type_name, "Reporting Phase: Test completed with warnings");  // Report warning if there are more than 5 warnings
        end else begin
            `uvm_info(get_type_name, "Reporting Phase: Test passed successfully", UVM_MEDIUM);  // Report success 
        end
        
        // Log the number of times ALU_en was set to zero
        `uvm_info(get_type_name, $sformatf("Reporting Phase: no. of ALU_en equals zero is %3d", counter), UVM_MEDIUM);
    endfunction

    // Final phase: Perform any final cleanup or additional reporting
    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);  
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("                                   Final Phase"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        `uvm_info(get_type_name, "Final Phase: Simulation completed", UVM_MEDIUM); 
    endfunction
    
endclass
