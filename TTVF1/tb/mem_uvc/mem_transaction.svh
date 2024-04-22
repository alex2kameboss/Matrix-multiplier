//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class mem_transaction extends uvm_sequence_item;
  
  //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(mem_transaction)
  
    rand bit  [256 - 1 : 0 ] data;
    rand bit  [16  - 1 : 0 ] addr;

    rand int                delay            ;
 
  //constructorul clasei; această funcție este apelată când se creează un obiect al clasei "tranzactie"
  function new(string name = "mem_transaction");//numele dat este ales aleatoriu, si nu mai este folosit in alta parte
    super.new(name);  
  endfunction
  
  function mem_transaction copy();
	  copy       = new();
    copy.data  = this.data;
    copy.addr  = this.addr;
    copy.delay = this.delay;
	return copy;
  endfunction

endclass