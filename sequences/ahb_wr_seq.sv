class ahb_wr_seq extends uvm_sequence #(ahb_transaction);
    `uvm_object_utils(ahb_wr_seq)

    function new(string name = "ahb_wr_seq");
        super.new(name);
    endfunction

    virtual task body();
        req = ahb_transaction::type_id::create("req");


    endtask

endclass
