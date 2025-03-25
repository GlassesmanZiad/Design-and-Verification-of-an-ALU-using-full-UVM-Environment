class Operand2_set2_test extends uvm_test ;

    `uvm_component_utils(Operand2_set2_test)
    
    // Declare the virtual sequence, configuration object, custom report server, and environment
    Test3_Virtual_Sequence vseq;
    ALU_config cnfg;
    custom_report_server custom_server;
    ALU_Env env;
    int counter;  // Variable to track the count of ALU_en off 

    function new (string name = "Operand2_set2_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase 
    function void build_phase(uvm_phase phase ) ; 
        super.build_phase(phase);
        
        // Create and configure the environment, virtual sequence, and configuration object
        env = ALU_Env::type_id::create("env", this);
        vseq = Test3_Virtual_Sequence::type_id::create("vseq", null);
        cnfg = ALU_config::type_id::create("cnfg", null);
        
        // Set Operand1 and Operand2 enabled
        cnfg.Operand1_en = 1'b1;
        cnfg.Operand2_en = 1'b1;
        
        // Set the configuration in the config DB for global access
        uvm_config_db#(ALU_config)::set(null, "*", "cnfg", cnfg);
        
        // Create and set a custom report server
        custom_server = new();
        uvm_report_server::set_server(custom_server);
    endfunction

    // Connect phase 
    function void connect_phase(uvm_phase phase) ; 
        super.connect_phase(phase);
        
        // Connect the virtual sequence's sequencer to the environment's sequencer
        vseq.sequencer = env.agent.sequencer;
    endfunction

    // Start of simulation phase 
    virtual function void start_of_simulation_phase(uvm_phase phase);
        // Get the global report server
        uvm_report_server server = uvm_report_server::get_server();
        
        // Set the maximum quit count for simulation termination
        server.set_max_quit_count(10);
        
        // Set the report verbosity level to medium
        this.set_report_verbosity_level(UVM_MEDIUM);
    endfunction

    // End of elaboration phase 
    function void end_of_elaboration_phase(uvm_phase phase);
        this.print();
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
        
        // Ensure the counter value is available from the Monitor (ALU_en off count)
        if (!uvm_config_db#(int)::get(null, "*", "counter", counter))
            `uvm_fatal(get_full_name(), "can't get ALU_en_off from Monitor");

        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("                                   Reporting Phase"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);

        // Check if there are errors or warnings and report 
        if (server.get_severity_count(UVM_ERROR) > 5) begin
            `uvm_error(get_type_name, "Reporting Phase: Test failed with errors");
        end else if (server.get_severity_count(UVM_WARNING) > 5) begin
            `uvm_warning(get_type_name, "Reporting Phase: Test completed with warnings");
        end else begin
            `uvm_info(get_type_name, "Reporting Phase: Test passed successfully", UVM_MEDIUM);
        end
        
        // Report the count of ALU_en equals zero 
        `uvm_info(get_type_name, $sformatf("Reporting Phase: no. of ALU_en equals zero is %3d", counter), UVM_MEDIUM);
    endfunction

    // Final phase 
    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("                                   Final Phase"), UVM_MEDIUM);
        `uvm_info(get_type_name, $sformatf("================================================================================"), UVM_MEDIUM);
        `uvm_info(get_type_name, "Final Phase: Simulation completed", UVM_MEDIUM);
    endfunction

endclass
