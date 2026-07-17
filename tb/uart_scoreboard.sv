`uvm_analysis_imp_decl(_tx)
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_ahb)
class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_imp_tx #(uart_transaction, uart_scoreboard) tx_export;
    uvm_analysis_imp_rx #(uart_transaction, uart_scoreboard) rx_export;
    uvm_analysis_imp_ahb #(ahb_transaction, uart_scoreboard) ahb_export;

    uart_configuration uart_cfg;

    ahb_transaction exp_tx_q[$];
    uart_transaction exp_rx_q[$];

    function new(string name = "uart_scoreboard", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(uart_configuration)::get(this, "", "uart_cfg", uart_cfg))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_config from uvm_config_db"))

        
        tx_export = new("tx_export",this);
        rx_export = new("rx_export",this);
        ahb_export = new("ahb_export",this);
        
        `uvm_info(get_type_name(), $sformatf("Build_phase done!"), UVM_LOW)
    endfunction 

    virtual task run_phase(uvm_phase phase);
    endtask

    function void write_ahb(ahb_transaction trans);
        if(trans.addr == 'h18 && trans.xact_type == ahb_transaction::WRITE) begin
            exp_tx_q.push_back(trans); // TX path: luu expected data
        end
        else if(trans.addr == 'h1C && trans.xact_type == ahb_transaction::READ) begin
            // RX path: compare voi expected uart_rxd
            if(exp_rx_q.size() == 0)
                `uvm_error(get_type_name(),"Data ERROR")
            else begin
                uart_transaction exp_data = exp_rx_q.pop_front();
                if(trans.data[7:0] == exp_data.data[7:0])
                    `uvm_info(get_type_name(), $sformatf("[PASSED] "), UVM_LOW)
                else
                    `uvm_error(get_type_name(), "[FAILED]")
            end
        end
    endfunction

    function void write_tx(uart_transaction trans);
        if(exp_tx_q.size() == 0) begin
            `uvm_error(get_type_name(), "DATA ERROR")
        end else begin
            // Compare voi exp_tx_q
            ahb_transaction exp_data = exp_tx_q.pop_front();
            if(trans.data[7:0] == exp_data.data[7:0])
                `uvm_info(get_type_name(),$sformatf("[PASSED]: DATA MATCHED"), UVM_LOW)
            else 
                `uvm_error(get_type_name(),$sformatf("[FAILED]: exp_data = %0h, act_data = %0h", exp_data.data, trans.data ), UVM_LOW)
        end
    endfunction

    function void write_rx(uart_transaction trans);
        exp_rx_q.push_back(trans);
    endfunction

endclass
