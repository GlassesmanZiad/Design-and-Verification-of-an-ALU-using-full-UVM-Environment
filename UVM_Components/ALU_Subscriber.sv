// ALU_Subscriber class: UVM subscriber component that receives and processes ALU_Packet data.
// It also collects coverage for various operand and ALU operations.

class ALU_Subscriber extends uvm_subscriber #(ALU_Packet);
    `uvm_component_utils(ALU_Subscriber) 

    ALU_Packet Packet;  
    uvm_analysis_imp#(ALU_Packet, ALU_Subscriber) analysis_export; // Analysis export for sending data
    uvm_event subscriber_start;  // Event to trigger processing in the run phase

    // Covergroup to collect input operand and control signal coverage
    covergroup inputs_collector;
        inputOperand1   : coverpoint Packet.Operand1 {
            bins negative_val = {[-16:-1]};  
            bins zero_val = {0};            
            bins positive_val = {[1:15]};    
        }

        // Coverpoint for Operand2 with bins for negative, zero, and positive values
        inputOperand2   : coverpoint Packet.Operand2 {
            bins negative_val = {[-16:-1]};  
            bins zero_val = {0};             
            bins positive_val = {[1:15]};    
        }

        // Coverpoint for Operand1 enable signal with bins for high and low
        inputOperand1_en: coverpoint Packet.Operand1_en {
            bins high = {1}; 
            bins low  = {0};  
        }

        // Coverpoint for Operand2 enable signal with bins for high and low
        inputOperand2_en: coverpoint Packet.Operand2_en {
            bins high = {1};  
            bins low  = {0};  
        }

        // Coverpoint for ALU enable signal with bins for high and ignore low
        inputALU_en: coverpoint Packet.ALU_en {
            bins high = {1};  
            bins low  = {0}; 
        }
    endgroup

    // Covergroup to collect Operand1 operation coverage
    covergroup operand1_op;
        // Coverpoint for Operand1 operations with bins for each operation type
        operand1_set  : coverpoint Packet.Operand1_op {
            bins ADD  = {3'b000}; 
            bins SUB  = {3'b001}; 
            bins XOR  = {3'b010}; 
            bins AND1 = {3'b011}; 
            bins AND2 = {3'b100}; 
            bins XNOR = {3'b101}; 
            bins OR   = {3'b110};
            bins NULL = {3'b111}; 
        }
    endgroup

    // Covergroup for the first set of Operand2 operations
    covergroup operand2_op_set1;
        // Coverpoint for Operand2 operations with bins for each operation type
        operand2_set1  : coverpoint Packet.Operand2_op {
            bins NAND  = {2'b00};
            bins ADD1  = {2'b01};
            bins ADD2  = {2'b10};
            bins NULL  = {2'b11};
        }
    endgroup

    // Covergroup for the second set of Operand2 operations
    covergroup operand2_op_set2;
        // Coverpoint for Operand2 operations with bins for each operation type
        operand2_set2  : coverpoint Packet.Operand2_op {
            bins XOR          = {2'b00};
            bins XNOR         = {2'b01};
            bins DEC_Operand1 = {2'b10};
            bins INC_Operand2 = {2'b11};
        }
    endgroup

    // Covergroup to collect ALU output coverage
    covergroup output_collector;
        // Coverpoint for ALU output with bins for negative, zero, and positive values
        operand2_set2  : coverpoint Packet.ALU_out {
            bins negative_val = {[-32:-1]};
            bins zero_val = {0};
            bins positive_val = {[1:31]};
        }
    endgroup

    // Constructor: Initializes the ALU_Subscriber with necessary objects and covergroups
    function new (string name = "ALU_Subscriber", uvm_component parent = null);
        super.new(name, parent);
        subscriber_start = new;
        inputs_collector = new;
        operand1_op = new;
        operand2_op_set1 = new;
        operand2_op_set2 = new; 
        output_collector = new;
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  
        Packet = ALU_Packet ::type_id::create("Packet"); 
        analysis_export = new("analysis_export",this); // Create analysis export for sending data
    endfunction

    // Write function: Receives ALU packet and triggers the subscriber event
    function void write ( ALU_Packet t );
        Packet = t; 
        `uvm_info("wr_fun_subscriber", $sformatf("ALU_Packet: ALU_en=%1b, Operand1_en=%1b, Operand2_en=%1b, Operand1=%5d, Operand2=%5d, Operand1_op=%02h, Operand2_op=%02h, ALU_out=%5d",
            Packet.ALU_en, Packet.Operand1_en, Packet.Operand2_en, Packet.Operand1, Packet.Operand2, Packet.Operand1_op, Packet.Operand2_op, Packet.ALU_out), UVM_HIGH)
        subscriber_start.trigger;  // Trigger the event to start processing in the run phase
    endfunction

    // Run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            subscriber_start.wait_trigger;  // Wait for the trigger event

            inputs_collector.sample();
            operand1_op.sample();
            output_collector.sample();

            // Conditionally sample Operand2 operation coverage based on enable signals
            if (~Packet.Operand1_en && Packet.Operand2_en) begin
                operand2_op_set1.sample();
            end else if (Packet.Operand1_en && Packet.Operand2_en) begin
                operand2_op_set2.sample();
            end
        end
    endtask
endclass
