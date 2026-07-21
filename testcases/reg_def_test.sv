class reg_def_test extends uart_base_test;
    `uvm_component_utils(reg_def_test)

    function new(string name = "reg_def_test", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        uvm_reg_hw_reset_seq hw_reset_seq;

        phase.raise_objection(this);
        
        // Default reset value
        hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("hw_reset_seq");
        hw_reset_seq.model = uart_env.regmodel;
        hw_reset_seq.start(null);
    
        phase.drop_objection(this);
    endtask
        
endclass
