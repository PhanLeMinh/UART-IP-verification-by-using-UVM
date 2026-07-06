class uart_driver extends uvm_driver #(uart_transaction);
    `uvm_component_utils(uart_driver)

    virtual uart_if uart_vif;
    uart_configuration uart_cfg;

    function new (string name = "uart_driver", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual uart_if)::get(this,"","vif",uart_vif))
            `uvm_fatal(get_type_name(),$sformatf("Failed to get vif from uvm_config_db!"))

        if(!uvm_config_db #(uart_configuration)::get(this,"","cfg",uart_cfg))
            `uvm_fatal(get_type_name(),$sformatf("Failed to get cfg from uvm_config_db!"))

    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            uart_vif.tx = 1'b1;
            seq_item_port.get(req);
            drive(req);
            $cast(rsp,req.clone());
            rsp.set_id_info(req);
            seq_item_port.put(rsp);
        end
    endtask: run_phase

    virtual task drive(uart_transaction req);
       int bit_time;
       bit parity;

       bit_time = (1_000_000)/uart_cfg.baud_rate;
       parity   = 1'b0;

       `uvm_info(get_type_name(),$sformatf("[Driver] Transmit data: %b",req.data),UVM_LOW)

       // START BIT
       uart_vif.tx = 0;
       #(bit_time);

       // DATA BIT
       for(int i = 0;i < uart_cfg.data_width; i++) begin
           uart_vif.tx = req.data[i];
           parity      = parity ^ req.data[i];
           #(bit_time);
       end

       // PARITY BIT
       case(uart_cfg.parity)
           uart_configuration::NONE:begin
               
           end
           uart_configuration::EVEN:begin
               uart_vif.tx = parity;
               #(bit_time);
           end
           uart_configuration::ODD:begin
               uart_vif.tx = ~parity;
               #(bit_time);
           end
           default: `uvm_fatal(get_type_name(),"Unknown parity mode")
       endcase

       // STOP BIT
       uart_vif.tx = 1;
       #(uart_cfg.num_of_stop_bit*bit_time);

       `uvm_info(get_type_name(),$sformatf("End of transmit"),UVM_LOW)
    endtask: drive
endclass: uart_driver
