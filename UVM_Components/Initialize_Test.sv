class Initialize_Test extends uvm_test ;

    `uvm_component_utils(Initialize_Test) 
    
    // Declare test components
    Test4_Virtual_Sequence vseq;       
    ALU_config cnfg;                   
    custom_report_server custom_server; 
    ALU_Env env;                       
	int counter;

    function new (string name = "Initialize_Test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase); 
        super.build_phase(phase);  
        
        // Create the environment, virtual sequence, configuration, and report server
        env = ALU_Env :: type_id :: create ("env", this); 
        vseq = Test4_Virtual_Sequence :: type_id :: create ("vseq", null); 
        cnfg = ALU_config :: type_id :: create ("cnfg", null); 
        
        // Configure the ALU settings specificilly for this test
        cnfg.Operand1_en = 1'b0;  // Disable Operand1
        cnfg.Operand2_en = 1'b1;  // Enable Operand2
        
        // Set the configuration object in the UVM config database
        uvm_config_db#(ALU_config)::set(null, "*", "cnfg", cnfg); 
        
        // Create and set a custom report server to set verbosity
        custom_server = new();
        uvm_report_server::set_server(custom_server);  // Set custom report server for handling UVM reports
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase); 
        super.connect_phase(phase);  // Call base class connect_phase
        
        // Connect the sequencer of the virtual sequence to the agent's sequencer in the environment (Scoreboard and subscriber)
        vseq.sequencer = env.agent.sequencer;
    endfunction

    // Start of simulation phase
    virtual function void start_of_simulation_phase(uvm_phase phase);
        uvm_report_server server = uvm_report_server::get_server();
        
        // Set the maximum number of times the simulation should quit
        server.set_max_quit_count(10);
        
        // Set report verbosity level for the test
        this.set_report_verbosity_level(UVM_MEDIUM);
    endfunction

    // End of elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        this.print();  // Print out the configuration of the UVM hirearchy
    endfunction

    // Run phase
    task run_phase(uvm_phase phase); 
        super.run_phase(phase);
        
        phase.raise_objection(this);
    
        // Start the virtual sequence
        vseq.start(null); 
        
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
