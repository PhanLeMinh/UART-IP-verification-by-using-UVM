class uart_transaction extends uvm_sequence_item;

    rand bit [`UART_DATA_WIDTH - 1:0] data;

    `uvm_object_utils_begin (uart_transaction)
        `uvm_field_int (data, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end

    function new (string name = "uart_transaction");
        super.new(name);
    endfunction: new
endclass
