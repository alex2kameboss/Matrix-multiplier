class mem_base_sequence extends uvm_sequence#(mem_transaction, mem_transaction ); 
    `uvm_object_utils(mem_base_sequence)
    // `uvm_declare_p_sequencer(sequencer_agent_memory_inst0)
    // `uvm_declare_p_sequencer(sequencer_agent_memory_inst1)
    // `uvm_declare_p_sequencer(sequencer_agent_memory_inst2)

    mem_transaction item;
    function new (string name="mem_base_sequence");
        super.new(name);     
        
    endfunction
endclass : mem_base_sequence

class mem_a_sequence extends mem_base_sequence;

  `uvm_object_utils(mem_a_sequence)


  function new (string name="mem_a_sequence");
      super.new(name);    
  endfunction

  virtual task body();
  item = mem_transaction::type_id::create("item");
      for(int i = 0; i<30; i++) begin
           start_item (item);
           if(!(item.randomize() with {data == i;
                                      }))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);
           //get_response()
      end
  endtask : body
endclass : mem_a_sequence

class mem_b_sequence extends mem_base_sequence;

  `uvm_object_utils(mem_b_sequence)


  function new (string name="mem_b_sequence");
      super.new(name);    
  endfunction

  virtual task body();
  item = mem_transaction::type_id::create("item");
      for(int i = 0; i<10; i++) begin
           start_item (item);
           if(!(item.randomize() with {data == i;
                                      }))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);
           //get_response()
      end
  endtask : body
endclass : mem_b_sequence

class mem_c_sequence extends mem_base_sequence;

  `uvm_object_utils(mem_c_sequence)


  function new (string name="mem_c_sequence");
      super.new(name);    
  endfunction

  virtual task body();
  item = mem_transaction::type_id::create("item");
      for(int i = 0; i<10; i++) begin
           start_item (item);
           if(!(item.randomize() with {data == i;
                                      }))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);
           //get_response()
      end
  endtask : body
endclass : mem_c_sequence