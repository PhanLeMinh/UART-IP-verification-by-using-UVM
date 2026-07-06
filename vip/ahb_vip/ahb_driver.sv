class ahb_driver extends uvm_driver #(ahb_transaction);
  `uvm_component_utils(ahb_driver)

  virtual ahb_if ahb_vif;

  function new(string name="ahb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    /** Applying the virtual interface received through the config db - learn detail in next session*/
    if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get from uvm_config_db. Please check!"))
  endfunction: build_phase

  /** User can use ahb_vif to control real interface like systemverilog part*/
  virtual task run_phase(uvm_phase phase);
     forever begin
          /**Get item from sequence through sequencer*/
          seq_item_port.get(req);
          `uvm_info(get_type_name(), $sformatf("Driver received transaction: addr = %h, data = %h, xact_type = %s", req.addr, req.data, (req.xact_type == ahb_transaction::READ) ? "READ" : "WRITE"), UVM_LOW)
          $cast(rsp, req.clone());
          rsp.set_id_info (req);
               
          //drive
          drive();

          /**Response item from sequence through sequencer*/
          seq_item_port.put(rsp);
    end
  endtask: run_phase

  virtual task drive();
          ahb_vif.HADDR     = 0;
          ahb_vif.HBURST    = 0;
          ahb_vif.HTRANS    = 0;
          ahb_vif.HSIZE     = 0;
          ahb_vif.HPROT     = 0;
          ahb_vif.HWRITE    = 0;
          ahb_vif.HWDATA    = 0;
          ahb_vif.HMASTLOCK = 0;
          wait (ahb_vif.HRESETn);
          @(posedge ahb_vif.HCLK);
          if (req.xact_type == ahb_transaction::WRITE) 
          begin
               //ADDRESS_PHASE
               #1;
               ahb_vif.HADDR     = req.addr;
               ahb_vif.HBURST    = req.burst_type;
               ahb_vif.HMASTLOCK = req.lock;
               ahb_vif.HPROT     = req.prot;
               ahb_vif.HSIZE     = req.xfer_size;
               ahb_vif.HTRANS    = 2'h2;
               ahb_vif.HWRITE    = 1;
               `uvm_info(get_type_name(), $sformatf("WRITE complete: addr = %h, data = %h", req.addr, req.data), UVM_LOW)
               
               //DATA_PHASE
               @(posedge ahb_vif.HCLK);
               #1;
               ahb_vif.HADDR     = 10'h00;
               ahb_vif.HBURST    = 3'h0;
               ahb_vif.HMASTLOCK = 0;
               ahb_vif.HPROT     = 4'h0;
               ahb_vif.HSIZE     = 3'h0;
               ahb_vif.HTRANS    = 0;
               ahb_vif.HWRITE    = 0;
               ahb_vif.HWDATA    = req.data;

               //IDLE
               repeat (3) @(posedge ahb_vif.HCLK);
               #1;
                    ahb_vif.HWDATA = 32'h0;
          end
          if (req.xact_type == ahb_transaction::READ) begin
               //ADDRESS_PHASE
               #1;
               ahb_vif.HADDR     = req.addr;
               ahb_vif.HBURST    = req.burst_type;
               ahb_vif.HMASTLOCK = req.lock;
               ahb_vif.HPROT     = req.prot;
               ahb_vif.HSIZE     = req.xfer_size;
               ahb_vif.HTRANS    = 2'h2;
               ahb_vif.HWRITE    = 0;

               //DATA_PHASE
               @(posedge ahb_vif.HCLK);
               ahb_vif.HADDR     = 10'h00;
               ahb_vif.HBURST    = 3'h0;
               ahb_vif.HMASTLOCK = 0;
               ahb_vif.HPROT     = 4'h0;
               ahb_vif.HSIZE     = 3'h0;
               ahb_vif.HTRANS    = 2'h0;
               ahb_vif.HWRITE    = 0;

               repeat (2) @(posedge ahb_vif.HCLK);
               #1;
               rsp.data  = ahb_vif.HRDATA;
               rsp.data  = req.data;
               `uvm_info(get_type_name(), $sformatf("READ complete: addr = %h, data = %h, rev data = %h", req.addr, req.data, rsp.data), UVM_LOW)
               
               //IDLE
               @(posedge ahb_vif.HCLK);
               #1;
               ahb_vif.HRDATA = 32'h0;
         end
  endtask:drive
endclass: ahb_driver

