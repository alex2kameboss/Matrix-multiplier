class apb_base_sequence extends uvm_sequence#(apb_transaction, apb_transaction ); 
    `uvm_object_utils(apb_base_sequence)
    `uvm_declare_p_sequencer(apb_sequencer)

    apb_transaction item;
    function new (string name="apb_base_sequence");
        super.new(name);     
    endfunction
endclass : apb_base_sequence

//change the name of this test
// class apb_sequence extends apb_base_sequence;

//   `uvm_object_utils(apb_sequence)


//   function new (string name="apb_sequence");
//       super.new(name);    
//   endfunction

//   virtual task body();
//   item = apb_transaction::type_id::create("item");
//       for(int i = 0; i<50 ;i++) begin
//            start_item (item);
//            if(!(item.randomize() with {data == i;
//                                        addr inside {[16'h0:16'h7c] };
//                                        addr % 4 == 0;
//                                        delay == 0;
//                                        write  inside {[0:1] } ;}))
//             `uvm_error(get_type_name(), "rand_error")
//            finish_item (item);
//            //get_response()
//       end
//   endtask : body
// endclass : apb_sequence

class config_sequence extends apb_base_sequence;

  `uvm_object_utils(config_sequence)


  function new (string name="config_sequence");
      super.new(name);    
  endfunction

  virtual task body();
  item = apb_transaction::type_id::create("item");
            //config a adrress
           start_item (item);
           if(!(item.randomize() with {data      == 'h1;
                                       addr      == 'd0;
                                       write     == 1 ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);
            //config b adrress
           start_item (item);
           if(!(item.randomize() with {data      == 'h2;
                                       addr      == 'd1;
                                       write     == 1 ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

            //config a adrress
           start_item (item);
           if(!(item.randomize() with {data      == 'h3;
                                       addr      == 'd2;
                                       write     == 1 ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

           //config param M
           start_item (item);
           if(!(item.randomize() with {data      == 'd64;
                                       addr      == 'd3;
                                       write     == 1 ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);
            //config param N
           start_item (item);
           if(!(item.randomize() with {data      == 'd64;
                                       addr      == 'd4;
                                       write     == 1 ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

            //config param P
           start_item (item);
           if(!(item.randomize() with {data      == 'd64;
                                       addr      == 'd5;
                                       write     == 1 ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

           //START
           start_item (item);
           if(!(item.randomize() with {data[1:0] == 1;
                                       addr      == 'h6;
                                       write     == 1 ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

           //get_response()
  endtask : body
endclass : config_sequence


class apb_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_sequence)


  function new (string name="apb_sequence");
      super.new(name);    
  endfunction

  virtual task body();
  item = apb_transaction::type_id::create("item");

    // write the op1 register- the address for A
           start_item (item);
           if(!(item.randomize() with {data == 1;
                                       addr==0;
                                       delay == 0;
                                       write == 1  ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

    // write the op2 register- the address for B
            start_item (item);
           if(!(item.randomize() with {data == 2;
                                       addr==1;
                                       delay == 0;
                                       write == 1  ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

    // read the op3 resgister- the destination address C
           start_item (item);
           if(!(item.randomize() with {data == 3;
                                       addr==2;
                                       delay == 0;
                                       write == 1;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

    // write the m param
            start_item (item);
           if(!(item.randomize() with {data == 64;
                                       addr==3;
                                       delay == 0;
                                       write == 1  ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

    // write the n param
            start_item (item);
           if(!(item.randomize() with {data == 64;
                                       addr==4;
                                       delay == 0;
                                       write == 1  ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

    // write the p param
            start_item (item);
           if(!(item.randomize() with {data == 64;
                                       addr==5;
                                       delay == 0;
                                       write == 1  ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);

    // config the state register
            start_item (item);
           if(!(item.randomize() with {data == 1;
                                       addr==6;
                                       delay == 0;
                                       write == 1  ;}))
            `uvm_error(get_type_name(), "rand_error")
           finish_item (item);
  endtask : body
endclass : apb_sequence

// class write_read_sequence extends apb_base_sequence;

//   `uvm_object_utils(write_read_sequence)


//   function new (string name="write_read_sequence");
//       super.new(name);    
//   endfunction

//   virtual task body();
//   item = apb_transaction::type_id::create("item");
//       for(int i = 0; i<50 ;i++) begin
//            start_item (item);
//            if(!(item.randomize() with {data == i;
//                                        addr == i;
//                                        delay == 0;
//                                        write ==1 ;}))
//             `uvm_error(get_type_name(), "rand_error")
//            finish_item (item);

//             start_item (item);
//            if(!(item.randomize() with {
//                                        addr == i;
//                                        delay == 0;
//                                        write ==0 ;}))
//             `uvm_error(get_type_name(), "rand_error")
//            finish_item (item);
//            //get_response()
//       end
//   endtask : body
// endclass : write_read_sequence

// class write_all_ffffffff extends apb_base_sequence;
//     `uvm_object_utils(write_all_ffffffff)
  
//     function new (string name = "write_all_ffffffff");
//         super.new(name);     
//     endfunction

//     virtual task body();
//        item = apb_transaction::type_id::create("item");
//        for(int i = 0; i<32;i++) begin
//         start_item (item);
          
//              if(!(item.randomize() with {data == 8'hff;
//                                          addr == 'h7 ;
//                                          delay == 0 ;
//                                          write  == 1; }))
//             `uvm_error(get_type_name(), "rand_error")
//         finish_item (item);
//         get_response(item);
//        end

//     endtask : body
// endclass : write_all_ffffffff
