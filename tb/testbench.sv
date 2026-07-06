class testbench;
    import uvm_pkg::*;
    import uart_pkg::*;
    import ahb_pkg::*;
    // ** Instance interface

    // ** Interconnect
    
    // ** Set the VIP interface on the enviroment
    initial begin
        
        // ** Start the UVM test
        run_test();
    end
endclass
