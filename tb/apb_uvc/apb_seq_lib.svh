class apb_base_sequence extends uvm_sequence#(apb_transaction, apb_transaction ); 
    `uvm_object_utils(apb_base_sequence)
    `uvm_declare_p_sequencer(apb_sequencer)

    apb_transaction item;
    function new (string name="apb_base_sequence");
        super.new(name);     
        
    endfunction
endclass : apb_base_sequence

class apb_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_sequence)


  function new (string name="apb_sequence");
      super.new(name);    
  endfunction

  virtual task body();
  item = apb_transaction::type_id::create("item");
      for(int i = 0; i<50 ;i++) begin
           start_item (item);
           if(!(item.randomize() with {data == i;
                                       addr inside {[16'h0:16'h7c] };
                                       addr % 4 == 0;
                                       delay == 0;
                                       write  inside {[0:1] } ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);
           //get_response()
      end
  endtask : body
endclass : apb_sequence