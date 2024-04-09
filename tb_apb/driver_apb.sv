`ifndef __driver_apb
`define __driver_apb


class driver_apb extends uvm_driver #(apb_transaction);
  `uvm_component_utils (driver_apb)
  virtual apb_if apb_interface_instance;
  
  //constructorul clasei
  function new(string name = "driver_apb", uvm_component parent = null);
    super.new(name, parent);   //este apelat constructorul clasei parinte
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);  //este apelata mai intai functia build_phase din clasa parinte
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_if", apb_interface_instance))begin
      `uvm_fatal("DRIVER_APB", "Nu s-a putut accesa interfata_senzorului")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("DRIVER_APB", $sformatf("Se asteapta o tranzactie de la sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER_APB", $sformatf("S-a primit o tranzactie de la sequencer"), UVM_LOW)
      send_transaction(req);
      `uvm_info("DRIVER_APB", $sformatf("Tranzactia a fost transmisa pe interfata"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
  
  task send_transaction(apb_transaction apb_item);
    $timeformat(-9, 2, " ns", 20);//cand se va afisa in consola timpul, folosind directiva %t timpul va fi afisat in nanosecunde (-9), cu 2 zecimale, iar dupa valoare se va afisa abrevierea " ns"
    apb_interface_instance.cb_drv.psel   <= 'b1;
    apb_interface_instance.cb_drv.paddr  <= apb_item.addr;
    apb_interface_instance.cb_drv.pwrite <= apb_item.write;
    
    if(apb_interface_instance.cb_drv.pwrite)
      apb_interface_instance.cb_drv.pwdata <= apb_item.data;
    
    @( apb_interface_instance.cb_drv iff apb_interface_instance.cb_drv.pready);
      apb_interface_instance.cb_drv.psel    <= 'b0;
      apb_interface_instance.cb_drv.penable <= 'b0;
      apb_interface_instance.cb_drv.pwdata  <= 'bx;
      apb_interface_instance.cb_drv.paddr   <= 'bx;
      apb_interface_instance.cb_drv.pwrite  <= 'bx;
    
    
    `ifdef DEBUG
    $display("DRIVER_AGENT_SENZOR, dupa transmisie; [T=%0t]", $realtime);
    `endif;
  endtask
  
endclass
`endif