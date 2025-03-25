// ALU_Sequencer class: A UVM sequencer responsible for generating sequences of ALU operations.
class ALU_Sequencer extends uvm_sequencer #(ALU_Packet);
    `uvm_component_utils(ALU_Sequencer) 

    function new (string name = "ALU_Sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  
    endfunction
    
    // Run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask 
endclass
