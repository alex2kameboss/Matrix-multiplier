class mem_monitor_b extends uvm_monitor;
  
  //monitorul se adauga in baza de date UVM
  `uvm_component_utils (mem_monitor_b) 
  
  //se declara colectorul de coverage care va inregistra valorile semnalelor de pe interfata citite de monitor
  // coverage_memory colector_coverage_memory; 
  
  //este creat portul prin care monitorul trimite spre exterior (la noi, informatia este accesata de scoreboard), prin intermediul agentului, tranzactiile extrase din traficul de pe interfata
  uvm_analysis_port #(mem_transaction) port_date_monitor_memory_b;
  
  //declaratia interfetei de unde monitorul isi colecteaza datele
  //virtual interfata_senzor interfata_monitor_senzor;
  virtual memory_interface memory_interface_instance;
  
  mem_transaction mem_item, aux_tr_memory;
  
  //constructorul clasei
  function new(string name = "mem_monitor_b", uvm_component parent = null);
    
    //prima data se apeleaza constructorul clasei parinte
    super.new(name, parent);
    
    
    
    //se creeaza portul prin care monitorul trimite in exterior, prin intermediul agentului, datele pe care le-a cules din traficul de pe interfata
    port_date_monitor_memory_b = new("mem_monitor_b",this);
    
    //se creeaza colectorul de coverage (la creare, se apeleaza constructorul colectorului de coverage)
    
    // colector_coverage_memory = coverage_memory::type_id::create ("colector_coverage_memory", this);
    
    
    //se creeaza obiectul (tranzactia) in care se vor retine datele colectate de pe interfata la fiecare tact de ceas
    mem_item   = mem_transaction::type_id::create("date_noi");
    
    aux_tr_memory = mem_transaction::type_id::create("datee_noi");
  endfunction
  
  
  //se preia din baza de date interfata la care se va conecta monitorul pentru a citi date, si se "leaga" la interfata pe care deja monitorul o contine
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual memory_interface)::get(this, "", "b_bus", memory_interface_instance))
        `uvm_fatal("mem_monitor_a", "Nu s-a putut accesa interfata monitorului")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
	// colector_coverage_senzor.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin 
      
      //!!!!sa astept ca datele sa fie valide
      wait(memory_interface_instance.cb_monitor.req & memory_interface_instance.cb_monitor.ack); 
      
      //preiau datele de pe interfata de iesire a DUT-ului (interfata_semafoare)
      mem_item.data = memory_interface_instance.cb_monitor.data;
      mem_item.addr = memory_interface_instance.cb_monitor.addr;


      aux_tr_memory = mem_item.copy();//nu vreau sa folosesc pointerul starea_preluata_a_senzorului pentru a trimite datele, deoarece continutul acestuia se schimba, iar scoreboardul va citi alte date 
      
       //tranzactia cuprinzand datele culese de pe interfata se pune la dispozitie pe portul monitorului, daca modulul nu este in reset
      port_date_monitor_memory_b.write(aux_tr_memory); 
      `uvm_info("mem_monitor", $sformatf("S-a receptionat tranzactia cu informatiile:"), UVM_NONE)
      // aux_tr_memory.afiseaza_informatia_tranzactiei();
	  
      //se inregistreaza valorile de pe cele doua semnale de iesire
      // colector_coverage_memory.stari_memory_cg.sample();
      
      // @(posedge memory_interface_instance.cb_monitor); //acest wait il adaug deoarece uneori o tranzactie este interpretata a fi doua tranzactii identice back to back (validul este citit ca fiind 1 pe doua fronturi consecutive de ceas); in implementarea curenta nu se poate sa vina doua tranzactii back to back
      
      
    end//forever begin
  endtask
  
  
endclass: mem_monitor_b
