class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void buil_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction 

    virtual task run_phase(uvm_phase phase);
        
    endtask

endclass
