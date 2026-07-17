class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    virtual uart_if vif;
    uart_configuration cfg;

    uart_monitor   monitor;
    uart_driver    driver;
    uart_sequencer sequencer;

    function new (string name="uart_agent", uvm_component parent);
        super.new(name,parent);
    endfunction:new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual uart_if)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"Fail to get vif from uvm_config_db")

        if(!uvm_config_db#(uart_configuration)::get(this,"","cfg",cfg))
            `uvm_fatal(get_type_name(),"Fail to get cfg from uvm_config_db")

        if(cfg.direction == uart_configuration::REV) begin
            is_active = UVM_PASSIVE;
            vif.tx    = 1'b1;
            `uvm_info(get_type_name(),"Configured as PASSIVE agent", UVM_LOW)
        end
        else begin
            is_active = UVM_ACTIVE;
            `uvm_info(get_type_name(),"Configrued as ACTIVE agent",UVM_LOW)
        end

        monitor   = uart_monitor::type_id::create("monitor",this);
        uvm_config_db#(virtual uart_if)::set(this,"monitor","vif",vif);
        uvm_config_db#(uart_configuration)::set(this,"monitor","cfg",cfg);

        if(is_active == UVM_ACTIVE) begin
            driver    = uart_driver::type_id::create("driver",this);
            sequencer = uart_sequencer::type_id::create("sequencer",this);
            uvm_config_db#(virtual uart_if)::set(this,"driver","vif",vif);
            uvm_config_db#(uart_configuration)::set(this,"driver","cfg",cfg);
        end
    endfunction:build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction:connect_phase
endclass:uart_agent
