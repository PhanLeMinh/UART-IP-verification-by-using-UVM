class uart_configuration extends uvm_object;

    typedef enum bit [1:0] {NONE,ODD,EVEN} parity_mode;
    typedef enum bit [1:0] {TRANS,REV,DUAL} direction_mode;

    rand      parity_mode parity;
    rand      direction_mode direction;
    rand int baud_rate;
    rand int data_width;
    rand int num_of_stop_bit;

    constraint config_c{
        data_width inside {5,6,7,8,9};
        num_of_stop_bit inside {1,2};
        baud_rate > 0;
        baud_rate < 115201;
    }

    `uvm_object_utils_begin (uart_configuration)
        `uvm_field_enum     (parity_mode,   parity   ,UVM_ALL_ON|UVM_HEX)
        `uvm_field_enum     (direction_mode,direction,UVM_ALL_ON|UVM_HEX)
        `uvm_field_int      (baud_rate               ,UVM_ALL_ON|UVM_HEX)
        `uvm_field_int      (data_width              ,UVM_ALL_ON|UVM_HEX)
        `uvm_field_int      (num_of_stop_bit         ,UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new (string name = "uart_configuration");
        super.new(name);
        `uvm_info("uart_configuration","Set up done!", UVM_HIGH)
    endfunction:new
endclass: uart_configuration
