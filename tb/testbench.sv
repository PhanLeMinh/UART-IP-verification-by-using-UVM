module testbench;
    import uvm_pkg::*;
    import uart_pkg::*;
    import ahb_pkg::*;
    // ** Instance interface

    ahb_if ahb_vif();
    uart_if uart_vif();
    
    // ** Interconnect
    uart_top u_dut(
                   .HCLK(ahb_vif.HCLK), 
                   .HRESETN(ahb_vif.HRESETn),
                   .HADDR(ahb_vif.HADDR), 
                   .HBURST(ahb_vif.HBURST), 
                   .HTRANS(ahb_vif.HTRANS), 
                   .HSIZE(ahb_vif.HSIZE), 
                   .HPROT(ahb_vif.HPROT), 
                   .HWRITE(ahb_vif.HWRITE), 
                   .HWDATA(ahb_vif.HWDATA),
                   .HSEL(ahb_vif.HSEL),
                   .HREADYOUT(ahb_vif.HREADYOUT), 
                   .HRDATA(ahb_vif.HRDATA), 
                   .HRESP(ahb_vif.HRESP)
                   .uart_rxd(uart_vif.rx),
                   .uart_txd(uart_vif.tx));
    
    // ** Set the VIP interface on the enviroment
    initial begin
        uvm_config_db#(virtual ahb_if)::set(null,"uvm_test_top","ahb_vif",ahb_vif);
        uvm_config_db#(virtual uart_if)::set(null,"uvm_test_top","uart_vif",uart_vif);
        // ** Start the UVM test
        run_test();
    end

    initial begin
        ahb_vif.HCLK = 0;
        always #5 ahb_vif.HCLK = ~ahb_vif.HCLK;
    end

    initial begin
        ahb_vif.HRESETn = 0;
        repeat (5) @(posedge ahb_vif.HCLK);
        ahb_vif.HRESETn = 1;
    end
endmodule
