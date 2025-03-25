// ALU_Monitor class: A UVM monitor that observes the ALU interface and generates ALU packets.
class ALU_Monitor extends uvm_monitor;

    `uvm_component_utils(ALU_Monitor)

    // Declare a virtual interface to connect to the DUT.
    virtual ALU_intf vif_Mntr;  

    // Declare the analysis port to send ALU_Packet to other components (scoreboard or subscriber).
    uvm_analysis_port#(ALU_Packet) analysis_port;
    ALU_Packet Packet;
    ALU_config cnfg;
	int counter;

    function new (string name = "ALU_Monitor", uvm_component parent = null);
        super.new(name, parent);
		counter = 0; 
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase); 
        super.build_phase(phase);  
        
        // Retrieve the virtual interface from the configuration database.
        if (!uvm_config_db #(virtual ALU_intf) :: get(this, "", "vif", vif_Mntr))
            `uvm_fatal(get_full_name(), "Error!");  

        // Retrieve the configuration object from the configuration database.
        if (!uvm_config_db#(ALU_config)::get(this, "", "cnfg", cnfg))
            `uvm_fatal(get_full_name(), "can't get config for Monitor");  

        analysis_port = new("analysis_port", this);
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase); 
        super.connect_phase(phase);  
    endfunction
    
    // Run phase
    task run_phase(uvm_phase phase); 
        super.run_phase(phase);  

        // Wait for the rising edge of the clock signal to synchronize with DUT.
        @(posedge vif_Mntr.clk);

        forever begin
            Packet = ALU_Packet::type_id::create("Packet");

            // Wait for the driver to have started the test (driver_started flag is set to 1).
            wait(cnfg.driver_started == 1);

            // Capture the ALU signal values (INPUTS) on the rising edge of the clock.
            @(posedge vif_Mntr.clk);

            Packet.ALU_en      = vif_Mntr.intf_ALU_en;
            Packet.Operand1    = vif_Mntr.intf_Operand1;
            Packet.Operand2    = vif_Mntr.intf_Operand2;
            Packet.Operand1_en = vif_Mntr.intf_Operand1_en;
            Packet.Operand2_en = vif_Mntr.intf_Operand2_en;
            Packet.Operand1_op = vif_Mntr.intf_Operand1_op;
            Packet.Operand2_op = vif_Mntr.intf_Operand2_op;

            // Wait for the falling edge of the clock to get the ALU result.
            @(negedge vif_Mntr.clk);

            Packet.ALU_out     = vif_Mntr.intf_ALU_out;

            // Reset the driver_started flag for the next cycle.
            cnfg.driver_started = 0;
			if (Packet.ALU_en == 1'b0) begin
				counter = counter + 1;
			end
            `uvm_info(get_type_name, $sformatf("ALU_Packet: ALU_en=%0b, Operand1_en=%0b, Operand2_en=%0b, Operand1=%0d, Operand2=%0d, Operand1_op=%0h, Operand2_op=%0h, ALU_out=%0d",
                Packet.ALU_en, Packet.Operand1_en, Packet.Operand2_en, Packet.Operand1, Packet.Operand2, Packet.Operand1_op, Packet.Operand2_op, Packet.ALU_out), UVM_HIGH);

            // Write the ALU_Packet to the analysis port for further processing.
            analysis_port.write(Packet);
        end
    endtask
	virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        uvm_config_db#(int)::set(null, "*", "counter", counter);
    endfunction
endclass
