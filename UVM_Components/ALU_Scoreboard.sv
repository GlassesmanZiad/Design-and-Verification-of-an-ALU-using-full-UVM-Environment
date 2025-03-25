// ALU_Scoreboard class: A UVM scoreboard that compares expected ALU output with actual output.
class ALU_Scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ALU_Scoreboard)  

    // Declare variables to store the ALU packet data, actual ALU output, and a counter for tracking no. of test cases.
    ALU_Packet Packet;
    uvm_analysis_imp#(ALU_Packet, ALU_Scoreboard) analysis_export;  // Declare an analysis export for receiving ALU_Packet.
    logic [5:0] actual_out;  
    logic [15:0] counter;  
    uvm_event scoreboard_start;  // Event to trigger the scoreboard run phase for each transaction (after write function excution).

    function new (string name = "ALU_Scoreboard", uvm_component parent = null);
        super.new(name, parent);  
        actual_out = 0;  
        counter = 1;  
        scoreboard_start = new();  
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase); 
        super.build_phase(phase);  
        analysis_export = new("analysis_export", this);  
    endfunction

    // Write method: Receives the ALU_Packet from the monitor and stores it.
    function void write (ALU_Packet t); 
        Packet = t;
        
        `uvm_info("wr_fun_scoreboard", $sformatf("ALU_Packet: ALU_en=%1b, Operand1_en=%1b, Operand2_en=%1b, Operand1=%5d, Operand2=%5d, Operand1_op=%02h, Operand2_op=%02h, ALU_out=%5d",
            Packet.ALU_en, Packet.Operand1_en, Packet.Operand2_en, Packet.Operand1, Packet.Operand2, Packet.Operand1_op, Packet.Operand2_op, Packet.ALU_out), UVM_HIGH);
        
        // Trigger the scoreboard start event to process the received packet in the run phase.
        scoreboard_start.trigger;
    endfunction

    // Run phase
    task run_phase(uvm_phase phase); 
        super.run_phase(phase); 
        
        forever begin
            actual_out = 0;  

            // Wait for the scoreboard_start event to be triggered by the monitor.
            scoreboard_start.wait_trigger;
            
            // Check the packet using the `Check` macro and compare the actual ALU output with the expected output.
            `Check(Packet, actual_out, counter)

            `uvm_info(get_type_name, $sformatf("ALU_Packet: ALU_en=%1b, Operand1_en=%1b, Operand2_en=%1b, Operand1=%5d, Operand2=%5d, Operand1_op=%02h, Operand2_op=%02h, ALU_out=%5d",
                Packet.ALU_en, Packet.Operand1_en, Packet.Operand2_en, Packet.Operand1, Packet.Operand2, Packet.Operand1_op, Packet.Operand2_op, Packet.ALU_out), UVM_HIGH);
        end
    endtask
endclass
