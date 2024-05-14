class driver_apb extends uvm_driver #(apb_transaction);
  `uvm_component_utils (driver_apb)

  
  //constructorul clasei
  function new(string name = "driver_apb", uvm_component parent = null);
    super.new(name, parent);   //este apelat constructorul clasei parinte
  endfunction

    virtual apb_interface apb_interface_instance;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);  //este apelata mai intai functia build_phase din clasa parinte
    if (!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_interface_instance", apb_interface_instance))begin
      `uvm_fatal("DRIVER_APB", "Nu s-a putut accesa interfata")
    end
  endfunction
  

//--------------------------task pentru initializarea semnalelor cu 0----------------
    task init();
      apb_interface_instance.cb_drv.psel    <= 0;
      apb_interface_instance.cb_drv.penable <= 0;
      apb_interface_instance.cb_drv.pwrite  <= 0;
      apb_interface_instance.cb_drv.paddr   <= 0;
      apb_interface_instance.cb_drv.pwdata  <= 0;
    endtask

//------------------------------------Run phase---------------------------------------
    virtual task run_phase (uvm_phase phase);

      apb_transaction apb_item;
      init();
      @(posedge apb_interface_instance.preset_n);    
      @(apb_interface_instance.cb_drv);

      forever begin   
         seq_item_port.get_next_item (apb_item);
        // repeat(apb_item.delay) @(apb_interface_instance.cb_drv);
         case(apb_item.write)
             1'b0:read  (apb_item);
             1'b1:write (apb_item);
         endcase

         seq_item_port.item_done ();
         seq_item_port.put_response(apb_item);
      end
   endtask

//-------------------------task for read trasnfer when trans is 0---------------------

virtual task read ( inout apb_transaction  apb_item);
      apb_interface_instance.cb_drv.psel    <= 1;
      apb_interface_instance.cb_drv.pwrite  <= apb_item.write;
      apb_interface_instance.cb_drv.paddr   <= apb_item.addr;
      @(apb_interface_instance.cb_drv);
      apb_interface_instance.cb_drv.penable <= 1;
      @(apb_interface_instance.cb_drv iff apb_interface_instance.cb_drv.pready);
      apb_item.data                        = apb_interface_instance.cb_drv.prdata;
      apb_interface_instance.cb_drv.penable <= 0;
      apb_interface_instance.cb_drv.psel    <= 0;
      
   endtask

//------------------------task for write trasnfer when trans is 1----------------------- 

virtual task write (apb_transaction apb_item );
      apb_interface_instance.cb_drv.psel    <= 1;
      apb_interface_instance.cb_drv.pwrite <= apb_item.write;
      apb_interface_instance.cb_drv.paddr  <= apb_item.addr;
      apb_interface_instance.cb_drv.pwdata <= apb_item.data;
      @(apb_interface_instance.cb_drv);
      apb_interface_instance.cb_drv.penable <=1;
      @(apb_interface_instance.cb_drv iff apb_interface_instance.cb_drv.pready);
      apb_interface_instance.cb_drv.penable <= 0;
      apb_interface_instance.cb_drv.psel    <= 0;

   endtask

endclass
