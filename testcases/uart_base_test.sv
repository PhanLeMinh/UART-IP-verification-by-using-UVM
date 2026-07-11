class uart_base_test extends uvm_test;
    `uvm_component_utils(uart_base_test)

    virtual ahb_if ahb_vif;
    virtual uart_if uart_vif;

    uart_configuration uart_cfg;
    uart_enviroment uart_env;

    function new(string name = "uart_base_test", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_id(),"Entered...", UVM_HIGH)

        if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
            `uvm_fatal(get_type_name(),"Failed to get ahb_vif from uvm_config_db")
        if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))
            `uvm_fatal(get_type_name(),"Failed to get uart_vif from uvm_config_db")
        
        uart_cfg = uart_configuration::type_id::create("uart_cfg",this);
        if(!uart_cfg.randomize())
            `uvm_fatal(get_type_name(),"Failed to randomize uart_cfg")

        uart_env = uart_enviroment::type_id::create("uart_env",this);

        uvm_config_db#(virtual ahb_if)::set(this,"uart_env","ahb_vif",ahb_vif);
        uvm_config_db#(virtual uart_if)::set(this,"uart_env","uart_vif",uart_vif);
        uvm_config_db#(uart_configuration)::set(this,"uart_env","uart_cfg",uart_cfg);

        `uvm_info(get_type_name(),"Exiting...", UVM_HIGH)
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Entered...", UVM_HIGH)
        uvm_top.print_topology();
        `uvm_info(get_type_name(),"Exiting...", UVM_HIGH)
    endfunction
endclass
