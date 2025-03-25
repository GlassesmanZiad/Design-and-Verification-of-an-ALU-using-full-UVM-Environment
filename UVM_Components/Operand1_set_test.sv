class Operand1_set_test extends uvm_test ;
    
    `uvm_component_utils(Operand1_set_test) 
    Test1_Virtual_Sequence vseq;  // Sequence for virtual testing of Operand1
    ALU_config cnfg;              // Configuration object for ALU
    custom_report_server custom_server;  // Custom report server for managing UVM report outputs
    ALU_Env env;
	int counter;                

    function new (string name = "Operand1_set_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase) ; 
        super.build_phase(phase) ;  
        env = ALU_Env::type_id::create("env",this);  
        vseq = Test1_Virtual_Sequence::type_id::create("vseq",null);  
        cnfg = ALU_config::type_id::create("cnfg",null);  // Create the ALU configuration instance
        
        // Set the configuration for Operand1 and Operand2
        cnfg.Operand1_en = 1'b1;  
        cnfg.Operand2_en = 1'b0;  
        
        // Store the configuration into the UVM configuration database
        uvm_config_db#(ALU_config)::set(null, "*", "cnfg", cnfg);
        custom_server = new();
        uvm_report_server::set_server(custom_server);
    endfunction

    // Connect phase
    function void connect_phase(uvm_phase phase) ; 
        super.connect_phase(phase) ; 
        vseq.sequencer = env.agent.sequencer;  // Set the sequencer for the virtual sequence
    endfunction

    // End of elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        this.print();  // Print test Hirearchy
    endfunction

    // Start of simulation phase
    virtual function void start_of_simulation_phase(uvm_phase phase);
        uvm_report_server server = uvm_report_server::get_server();  
        server.set_max_quit_count(10);  // Set the max number of times to quit the simulation
        this.set_report_verbosity_level(UVM_MEDIUM);  // Set the report verbosity level
    endfunction

    // Run phase
    task run_phase(uvm_phase phase) ; 
        super.run_phase(phase); 
        phase.raise_objection(this);  
        vseq.start(null);  // Start the virtual sequence
        phase.drop_objection(this); 
    endtask

    // Report phase
    virtual function void report_phase(uvm_phase phase);
        uvm_report_server server = uvm_report_server::get_server();
        super.report_phase(phase);
        if (!uvm_config_db#(int)::get(null, "*", "counter", counter))
        	`uvm_fatal(get_full_name(), "can't get ALU_en_off from Monitor"); 

		`uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("                                   Reporting Phase"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);

        // Check if there are errors or warnings and report
        if (server.get_severity_count(UVM_ERROR) > 5) begin
            `uvm_error(get_type_name, "Reporting Phase: Test failed with errors")
        end else if (server.get_severity_count(UVM_WARNING) > 5) begin
            `uvm_warning(get_type_name, "Reporting Phase: Test completed with warnings")
        end else begin
            `uvm_info(get_type_name, "Reporting Phase: Test passed successfully", UVM_LOW)
        end
		`uvm_info(get_type_name, $sformatf("Reporting Phase: no. of ALU_en equals zero is %3d",counter), UVM_LOW)
    endfunction

    // Final phase
    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        // Perform any final cleanup or additional reporting here
		`uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("                                   Final Phase"),UVM_MEDIUM);
        `uvm_info(get_type_name,$sformatf("================================================================================"),UVM_MEDIUM);
        `uvm_info(get_type_name,"Final Phase: Simulation completed", UVM_LOW)
    endfunction

endclass
