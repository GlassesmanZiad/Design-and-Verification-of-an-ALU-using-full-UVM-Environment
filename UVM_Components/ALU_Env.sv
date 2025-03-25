class ALU_Env extends uvm_env;

    `uvm_component_utils(ALU_Env)

    // Declare components (agents, scoreboard, and subscriber) to be used in the environment
    ALU_Agent      agent;        
    ALU_Scoreboard scoreboard;  
    ALU_Subscriber subscriber;   

    function new (string name = "ALU_Env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  

        // Create instances of the agent, scoreboard, and subscriber
        agent      = ALU_Agent      :: type_id :: create("agent", this);     
        scoreboard = ALU_Scoreboard :: type_id :: create("scoreboard", this); 
        subscriber = ALU_Subscriber :: type_id :: create("subscriber", this); 
    endfunction

    // Connect phase 
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase); 

        // Connect the agent's analysis port to both the scoreboard and subscriber
        agent.analysis_port.connect(scoreboard.analysis_export); 
        agent.analysis_port.connect(subscriber.analysis_export); 
    endfunction

    // Run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);  
    endtask
endclass
