class enviroment extends uvm_env;
    `uvm_component_utils(enviroment)

    virtual ahb_if ahb_vif;
    ahb_agent      ahb_agt;

    uart_reg_block regmodel;
    uart_reg2ahb_adapter ahb_adapter;

    // Predictor class creation
    uvm_reg_predictor#(ahb_transaction) ahb_predictor;

    function new(string name = "enviroment",uvm_component parent);
        super.new(name,parent);            
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
            `uvm_fatal(get_type_name(),"Failed to get ahb_vif from uvm_config_db")

        ahb_agt = ahb_agent::type_id::create("ahb_agt");

        ahb_predictor = uvm_reg_predictor#(ahb_transaction)::type_id::create("ahb_predictor",this);

        regmodel = uart_reg_block::type_id::create("regmodel",this);
        regmodel.build();

        ahb_adapter = uart_reg2ahb_adapter::type_id::create("ahb_adapter");

        uvm_config_db#(virtual ahb_if)::set(this,"ahb_agent","ahb_vif",ahb_vif);

    endfunction 

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if(remodel.get_parent() == null)
            regmodel.ahb_map.set_sequencer(ahb_agt.sequencer, ahb_adapter);

        // Predictor connection
        ahb_predictor.map = regmodel.ahb_map;
        ahb_predictor.adapter = ahb_adapter;
        ahb_agt.monitor.item_observed_port.connect(ahb_predictor.bus_in);

        // Connect_monitor to scoreboard

    endfunction 
endclass
