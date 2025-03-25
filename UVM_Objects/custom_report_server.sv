//-----------------------------------------------------------------------------
//  Usage:
//      I used this class in my UVM testbench to replace the default
//      report server and customize how messages are logged during simulation.
//      not printing the timetamp and line and hirearchy.
//-----------------------------------------------------------------------------

class custom_report_server extends uvm_report_server;

    // Override the compose_message method
    virtual function string compose_message(uvm_severity severity,
                                           string name,
                                           string id,
                                           string message,
                                           string filename,
                                           int line);

                                               
        // Customize the message format
        return $sformatf("UVM_INFO @ %6t [%s] %s",$time,id, message);
    endfunction

endclass