class enviroment extends uvm_env;
    `uvm_component_utils(enviroment)

    function new(string name = "enviroment",uvm_component parent);
        super.new(name,parent);            
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction 

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction 
endclass
