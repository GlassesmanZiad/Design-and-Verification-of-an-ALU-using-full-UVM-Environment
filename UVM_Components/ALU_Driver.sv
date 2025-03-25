// ALU_Driver class - A driver to send ALU_Packet items to the DUT
class ALU_Driver extends uvm_driver #(ALU_Packet);


    `uvm_component_utils(ALU_Driver)

    // Virtual interface to interact with the DUT interface
    virtual ALU_intf vif_Drv;
    
    // Configuration object that stores ALU-related settings
    ALU_config cnfg;
    
    // Strings to hold operation and set names
    string operation, set;

    // Constructor to initialize the driver component
    function new (string name = "ALU_Driver", uvm_component parent = null);
        super.new(name, parent); 
    endfunction

    // Build phase 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  
        
        // Get the virtual interface from the UVM configuration database
        if (!uvm_config_db #(virtual ALU_intf)::get(this, "", "vif", vif_Drv))
            `uvm_fatal(get_full_name(), "Virtual interface not found for driver")  

        // Get the configuration object from the UVM configuration database
        if (!uvm_config_db#(ALU_config)::get(this, "", "cnfg", cnfg))
            `uvm_fatal(get_full_name(), "can't get config for driver")  
    endfunction

    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);  
    endfunction

    // Reset phase 
    virtual task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        //Here we Raise objection to keep the simulation in this phase and finish it, then procced to the main phase insie the run phase  
        phase.raise_objection(this);  
        `uvm_info(get_type_name, $sformatf("ALU resetting...."), UVM_MEDIUM)
        vif_Drv.intf_rst_n = 1'b0;  
        #1;  
        vif_Drv.intf_rst_n = 1'b1;
        #1;
        vif_Drv.intf_rst_n = 1'b0;  
        #3;  
        vif_Drv.intf_rst_n = 1'b1;   
        `uvm_info(get_type_name, $sformatf("Reset complete, starting run_phase"), UVM_LOW)
        phase.drop_objection(this);  
    endtask

    // Run phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);  

        // Wait for the ALU to be out of reset
        wait(vif_Drv.intf_rst_n == 1'b1);
        
        forever begin
            ALU_Packet Packet;  
            seq_item_port.get_next_item(Packet);
            @(negedge vif_Drv.clk);
            #0;  // Avoid Racing conitions

            // Drive the ALU packet signals onto the DUT interface
            vif_Drv.intf_ALU_en      <= Packet.ALU_en;
            vif_Drv.intf_Operand1_en <= Packet.Operand1_en;
            vif_Drv.intf_Operand2_en <= Packet.Operand2_en;
            vif_Drv.intf_Operand1    <= Packet.Operand1;
            vif_Drv.intf_Operand2    <= Packet.Operand2;
            vif_Drv.intf_Operand1_op <= Packet.Operand1_op;
            vif_Drv.intf_Operand2_op <= Packet.Operand2_op;

            // This is my user defined macros found in "ALU_Macros.sv"
            `get_operation(Packet, set, operation)
            
            // Log the ALU packet information to the UVM report
            `uvm_info(get_type_name, $sformatf("ALU_Packet: ALU_en= %0b, Operand1_en= %0b, Operand2_en=%0b, Operand1=%0d, Operand2=%0d, Operand1_op=%0h, Operand2_op=%0h",
            Packet.ALU_en, Packet.Operand1_en, Packet.Operand2_en, Packet.Operand1, Packet.Operand2, Packet.Operand1_op, Packet.Operand2_op), UVM_HIGH)
            
            $display("----------------------------------------------------------------------------------------------------------------------------------------");
            `uvm_info(get_type_name, $sformatf("ALU_Packet: ALU_en=%0b, Operand1=%3d, Operand2=%3d, Operand Set= %s, Operation= %s",
            Packet.ALU_en, Packet.Operand1, Packet.Operand2, set, operation), UVM_MEDIUM)

            // Mark that the driver has started an completed sending the packet
            cnfg.driver_started = 1;
            seq_item_port.item_done();
        end
    endtask

endclass
