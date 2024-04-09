`ifndef __transaction_apb
`define __transaction_apb

class apb_transaction extends uvm_sequence_item;
  

  `uvm_object_utils(apb_transaction)
  
  rand bit          write;
  rand bit [8-1 :0] addr ;
  rand bit [8 -1:0] data ;
  rand int          delay;
 // rand bit [DWITH -1:0] prdata;
 
  constraint delay_c {delay<10;delay>0;}
  
  function new(string name = "element_secventaa");
    super.new(name);  
  endfunction
  
  //functie de afisare a unei tranzactii
  function void afiseaza_informatia_tranzactiei();
    $display("Valoarea write: %0h, Valoarea addr: %0h, Valoarea data: %0h", write, addr, data);
  endfunction
  
  function apb_transaction copy();
	  copy       = new()     ;
	  copy.write = this.write;
	  copy.addr  = this.addr ;
	  copy.data  = this.data ;
    copy.delay = this.delay;
	return copy;
  endfunction

endclass
`endif
