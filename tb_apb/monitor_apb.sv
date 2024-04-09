`ifndef __monitor_apb
`define __monitor_apb
//`include "tranzactie_semafoare.sv"

class monitor_apb extends uvm_monitor;
  
  //monitorul se adauga in baza de date UVM
  `uvm_component_utils (monitor_apb) 
  
  //se declara colectorul de coverage care va inregistra valorile semnalelor de pe interfata citite de monitor
 // coverage_senzor colector_coverage_senzor; 
  
  //este creat portul prin care monitorul trimite spre exterior (la noi, informatia este accesata de scoreboard), prin intermediul agentului, tranzactiile extrase din traficul de pe interfata
  uvm_analysis_port #(apb_transaction) port_date_monitor_apb;

  virtual apb_if interface_monitor_apb;
  
  apb_transaction apb_item, aux_tr_apb;
  
  //constructorul clasei
  function new(string name = "monitor_apb", uvm_component parent = null);
    
    //prima data se apeleaza constructorul clasei parinte
    super.new(name, parent);
    
    
    
    //se creeaza portul prin care monitorul trimite in exterior, prin intermediul agentului, datele pe care le-a cules din traficul de pe interfata
    port_date_monitor_apb = new("port_date_monitor_apb",this);
    
  //  colector_coverage_senzor = coverage_senzor::type_id::create ("colector_coverage_senzor", this);
    
    apb_item   = apb_transaction::type_id::create("date_noi");
    
    aux_tr_apb = apb_transaction::type_id::create("datee_noi");
  endfunction
  
  
  //se preia din baza de date interfata la care se va conecta monitorul pentru a citi date, si se "leaga" la interfata pe care deja monitorul o contine
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_interface", interface_monitor_apb))
      `uvm_fatal("MONITOR_APB", "Nu s-a putut accesa interfata monitorului")
  endfunction
        
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
//	colector_coverage_senzor.p_monitor = this;  
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin

      @(interface_monitor_apb.cb_monitor iff interface_monitor_apb.cb_monitor.pready && interface_monitor_apb.cb_monitor.psel &&     interface_monitor_apb.cb_monitor.penable);
      
          apb_item.addr     = interface_monitor_apb.cb_monitor.paddr ;         
          apb_item.write    = interface_monitor_apb.cb_monitor.pwrite;
         
      if(apb_item.write)                                     
              apb_item.data = interface_monitor_apb.cb_monitor.pwdata;   
          else 
              apb_item.data = interface_monitor_apb.cb_monitor.prdata;    
  

      aux_tr_apb = apb_item.copy();

      port_date_monitor_apb.write(aux_tr_apb); 
      `uvm_info("MONITOR_APB", $sformatf("S-a receptionat tranzactia cu informatiile:"), UVM_NONE)
      aux_tr_apb.afiseaza_informatia_tranzactiei();
	  
      //se inregistreaza valorile de pe cele doua semnale de iesire
   //   colector_coverage_senzor.stari_senzor_cg.sample();
      
    //  @(negedge interface_monitor_apb.cb_monitor); //acest wait il adaug deoarece uneori o tranzactie este interpretata a fi doua tranzactii identice back to back (validul este citit ca fiind 1 pe doua fronturi consecutive de ceas); in implementarea curenta nu se poate sa vina doua tranzactii back to back
      
      
    end
  endtask
  
  
endclass: monitor_apb

`endif