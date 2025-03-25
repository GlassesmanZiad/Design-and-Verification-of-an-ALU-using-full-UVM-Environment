// ALU_Agent is a UVM agent for an Arithmetic Logic Unit (ALU) component in the testbench.
class ALU_Agent extends uvm_agent;

    `uvm_component_utils(ALU_Agent)

    ALU_Sequencer sequencer;    // Sequencer to generate sequences for the DUT
    ALU_Driver driver;          // Driver to drive the generated sequences to the DUT
    ALU_Monitor monitor;        // Monitor to observe DUT signals and generate coverage or analysis data

    // UVM analysis port to send data from the monitor to other components
    uvm_analysis_port#(ALU_Packet) analysis_port;

    // Constructor for the ALU_Agent class
    function new (string name = "ALU_Agent", uvm_component parent = null);
        super.new(name, parent);  
    endfunction

    // Build phase 
    function void build_phase(uvm_phase phase); 
        super.build_phase(phase);  
        
        // Check if the agent is active, and if so, create the sequencer and driver components
        if(get_is_active == UVM_ACTIVE) begin
            sequencer = ALU_Sequencer::type_id::create("sequencer", this);  
            driver    = ALU_Driver::type_id::create("driver", this);        
        end

        monitor = ALU_Monitor::type_id::create("monitor", this);
        
        analysis_port = new("analysis_port", this); 
    endfunction
    
    // Connect phase 
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase); 
        
        // Connect the sequencer's sequence item export to the driver's sequence item port
        driver.seq_item_port.connect(sequencer.seq_item_export);
        
        // Connect the monitor's analysis port to the analysis port of the agent
        monitor.analysis_port.connect(analysis_port);
    endfunction

    // Run phase 
    task run_phase(uvm_phase phase);
        super.run_phase(phase); 
    endtask

endclass
