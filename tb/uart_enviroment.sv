class uart_enviroment extends uvm_env;
    `uvm_component_utils(uart_enviroment)

    virtual ahb_if ahb_vif;
    virtual uart_if uart_vif;

    uart_configuration uart_cfg;

    ahb_agent      ahb_agt;
    uart_agent     uart_agt;
    uart_scoreboard uart_sb;

    uart_reg_block regmodel;
    uart_reg2ahb_adapter ahb_adapter;

    // Predictor class creation
    uvm_reg_predictor#(ahb_transaction) ahb_predictor;

    function new(string name = "enviroment",uvm_component parent);
        super.new(name,parent);            
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"Entered...", UVM_HIGH)
        
        if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
            `uvm_fatal(get_type_name(),"Failed to get ahb_vif from uvm_config_db")
        if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))
            `uvm_fatal(get_type_name(),"Failed to get uart_vif from uvm_config_db")
        if(!uvm_config_db#(uart_configuration)::get(this,"","uart_cfg",uart_cfg))
            `uvm_fatal(get_type_name(),"Failed to get uart_cfg from uvm_config_db")

        ahb_agt = ahb_agent::type_id::create("ahb_agt",this);
        uart_agt = uart_agent::type_id::create("uart_agt",this);
        uart_sb = uart_scoreboard::type_id::create("uart_sb",this);

        ahb_predictor = uvm_reg_predictor#(ahb_transaction)::type_id::create("ahb_predictor",this);

        regmodel = uart_reg_block::type_id::create("regmodel",this);
        regmodel.build();

        ahb_adapter = uart_reg2ahb_adapter::type_id::create("ahb_adapter");

        uvm_config_db#(virtual ahb_if)::set(this,"ahb_agt","ahb_vif",ahb_vif);
        uvm_config_db#(virtual uart_if)::set(this,"uart_agt","uart_vif",uart_vif);
        uvm_config_db#(uart_configuration)::set(this,"uart_agent","uart_cfg",uart_cfg);
        `uvm_info(get_type_name(),"Exiting...", UVM_HIGH)
    endfunction 

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if(regmodel.get_parent() == null)
            regmodel.ahb_map.set_sequencer(ahb_agt.sequencer, ahb_adapter);

        // Predictor connection
        ahb_predictor.map = regmodel.ahb_map;
        ahb_predictor.adapter = ahb_adapter;
        ahb_agt.monitor.item_observed_port.connect(ahb_predictor.bus_in);

        // Connect_monitor to scoreboard
        ahb_agt.monitor.monitor_tx.connect(uart_sb.tx_export);
        ahb_agt.monitor.monitor_rx.connect(uart_sb.rx_export);
    endfunction 
endclass
