class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)

  virtual ahb_if ahb_vif;

  uvm_analysis_port#(ahb_transaction) item_observed_port;

  function new(string name="ahb_monitor", uvm_component parent);
    super.new(name,parent);
    item_observed_port = new("item_observed_port",this);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
        `uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_vif from uvm_config_db. Please check!"))
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    ahb_transaction ahb_trans;

    forever begin
        do 
            @(posedge ahb_vif.HCLK);
        while(!(ahb_vif.HTRANS == 2'b10));
        `uvm_info(get_type_name(),"Start capture AHB transaction",UVM_LOW)
        ahb_trans = new("observed_trans");
        ahb_trans.addr = ahb_vif.HADDR;
        $cast(ahb_trans.xact_type, ahb_vif.HWRITE);
        $cast(ahb_trans.xfer_size, ahb_vif.HSIZE);
        $cast(ahb_trans.burst_type, ahb_vif.HBURST);
        ahb_trans.prot = ahb_vif.HPROT;
        ahb_trans.lock = ahb_vif.HMASTLOCK;
        do 
            @(posedge ahb_vif.HCLK);
        while(!(ahb_vif.HREADYOUT == 1'b1));
        ahb_trans.data = (ahb_trans.xact_type == ahb_transaction::WRITE) ? ahb_vif.HWRITE : ahb_vif.HRDATA;
        `uvm_info(get_type_name(),$sformatf("Observed transaction: \n%s",ahb_trans.sprint()),UVM_LOW)

    end
  endtask: run_phase

endclass: ahb_monitor

