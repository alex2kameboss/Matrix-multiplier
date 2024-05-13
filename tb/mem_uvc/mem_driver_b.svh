//driverul va prelua date de tip "tranzactie", pe care le va trimite DUT-ului, conform protocolul de comunicatie de pe interfata
class mem_driver_b extends uvm_driver #(mem_transaction);
  
  //driverul se adauga in baza de date UVM
  `uvm_component_utils (mem_driver_b)
  
  //este declarata interfata pe care driverul va trimite datele
  virtual memory_interface memory_interface_instance;
  
  //constructorul clasei
  function new(string name = "mem_driver_b", uvm_component parent = null);
    //este apelat constructorul clasei parinte
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //este apelata mai intai functia build_phase din clasa parinte
    super.build_phase(phase);
    if (!uvm_config_db#(virtual memory_interface)::get(this, "", "b_bus", memory_interface_instance))begin
      `uvm_fatal("mem_driver_b", "Nu s-a putut accesa interfata_senzorului")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("mem_driver_b", $sformatf("Se asteapta o tranzactie de la sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("mem_driver_b", $sformatf("S-a primit o tranzactie de la sequencer"), UVM_LOW)
      trimiterea_tranzactiei(req);
      `uvm_info("mem_driver_b", $sformatf("Tranzactia a fost transmisa pe interfata"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
  
  task trimiterea_tranzactiei(mem_transaction mem_item);
    $timeformat(-9, 2, " ns", 20);//cand se va afisa in consola timpul, folosind directiva %t timpul va fi afisat in nanosecunde (-9), cu 2 zecimale, iar dupa valoare se va afisa abrevierea " ns"
    
    $display("%0t mem_driver_b", $time());
    @(posedge memory_interface_instance.cb_drv_b.req)
    memory_interface_instance.ack             <= 'b1;
    if(~memory_interface_instance.cb_drv_b.w_en) begin
      memory_interface_instance.cb_drv_b.data <= mem_item.data;
    end
    @(memory_interface_instance.clk);
    memory_interface_instance.cb_drv_b.ack    <= 'b0;
    
    $display("mem_driver_b, dupa transmisie; [T=%0t]", $realtime);

  endtask
  
endclass