class mem_agent extends uvm_agent;
  
  `uvm_component_utils(mem_agent)//se adauga agentul la baza de date a acestui proiect; de acolo, acelasi agent se va prelua ulterior spre a putea fi folosit
  
  
  //se instantiaza componentele de baza ale agentului: driverul, monitorul si sequencer-ul; driverul si monitorul sunt create de catre noi, pe cand sequencerul se ia direct din biblioteca UVM
  mem_driver_a   mem_driver_a_inst;

  mem_driver_b   mem_driver_b_inst;

  mem_driver_c   mem_driver_c_inst;

  mem_monitor_a  mem_monitor_a_inst;

  mem_monitor_b  mem_monitor_b_inst;

  mem_monitor_c  mem_monitor_c_inst;
  
  uvm_sequencer #(mem_transaction) sequencer_agent_memory_inst0;

  uvm_sequencer #(mem_transaction) sequencer_agent_memory_inst1;

  uvm_sequencer #(mem_transaction) sequencer_agent_memory_inst2;

  
  
  //se declara portul de comunicare al agentului cu scoreboardul/mediul de referinta; prin acest port agentul trimite spre verificare datele preluate de la monitor; a se observa ca intre monitor si agent (practic in interiorul agentului) comunicarea se face la nivel de tranzactie
  uvm_analysis_port #(mem_transaction) de_la_monitor_memory_a; 

  uvm_analysis_port #(mem_transaction) de_la_monitor_memory_b; 

  uvm_analysis_port #(mem_transaction) de_la_monitor_memory_c; 
  
  
  //se declara un camp in care spunem daca agentul este activ sau pasiv; un agent activ contine in plus, fata de agentul pasiv, driver si sequencer
  local int is_active = 1;  //0 inseamna agent pasiv; 1 inseamna agent activ
  
  
  //se declara constructorul clasei; acesta este un cod standard pentru toate componentele
  function new (string name = "agent_memory", uvm_component parent = null);
      super.new (name, parent);
      de_la_monitor_memory_a = new("de_la_monitor_memory_a", this);
      de_la_monitor_memory_b = new("de_la_monitor_memory_b", this);
      de_la_monitor_memory_c = new("de_la_monitor_memory_c", this);

  endfunction 
  
  
  //rularea unui mediu de verificare cuprinde mai multe faze; in faza "build", se "asambleaza" agentul, tinandu-se cont daca acesta este activ sau pasiv
  virtual function void build_phase (uvm_phase phase);
    
    //se apeleaza functia build_phase din clasa parinte (uvm_agent)
    super.build_phase(phase);
    
    //atat agentii activi, cat si agentii pasivi au nevoie de un monitor 
    mem_monitor_a_inst = mem_monitor_a::type_id::create ("mem_monitor_a_inst", this);
    mem_monitor_b_inst = mem_monitor_b::type_id::create ("mem_monitor_b_inst", this);
    mem_monitor_c_inst = mem_monitor_c::type_id::create ("mem_monitor_c_inst", this);

    // daca agentul este activ, i se adauga atat sequencerul (componenta care aduce datele in agent) cat si driverul (componenta care preia datele de la sequencer si le transmite DUT-ului adaptandu-le protocolului de comunicatie al acestuia)
    if (is_active==1) begin
      sequencer_agent_memory_inst0 = uvm_sequencer#(mem_transaction)::type_id::create ("sequencer_agent_memory_inst0", this);
      sequencer_agent_memory_inst1 = uvm_sequencer#(mem_transaction)::type_id::create ("sequencer_agent_memory_inst1", this);
      sequencer_agent_memory_inst2 = uvm_sequencer#(mem_transaction)::type_id::create ("sequencer_agent_memory_inst2", this);

      mem_driver_a_inst = mem_driver_a::type_id::create ("mem_driver_a_inst", this);
      mem_driver_b_inst = mem_driver_b::type_id::create ("mem_driver_b_inst", this);
      mem_driver_c_inst = mem_driver_c::type_id::create ("mem_driver_c_inst", this);

    end

  endfunction
  
  
  //rularea unui mediu de verificare cuprinde mai multe faze; in faza "connect", se realizeaza conexiunile intre componente; in cazul agentului, se realizeaza conexiunile intre sub-componentele agentului
  virtual function void connect_phase (uvm_phase phase);
    
    //se apeleaza functia connect_phase din clasa parinte (uvm_agent)
    super.connect_phase(phase);
    
    //se conecteaza portul agentului cu portul de comunicatie al monitorului din agent (monitorul nu poate trimite date in exterior decat prin intermediul agentului din care face parte)
    de_la_monitor_memory_a = mem_monitor_a_inst.port_date_monitor_memory_a;
    de_la_monitor_memory_b = mem_monitor_b_inst.port_date_monitor_memory_b;
    de_la_monitor_memory_c = mem_monitor_c_inst.port_date_monitor_memory_c;
    
	// driverul primeste date de la sequencer, pentru a le transmite DUT-ului; daca agentul este activ, trebuie realizata si conexiunea intre sequencer si driver 
    if (is_active==1)begin
       mem_driver_a_inst.seq_item_port.connect (sequencer_agent_memory_inst0.seq_item_export);
       mem_driver_b_inst.seq_item_port.connect (sequencer_agent_memory_inst1.seq_item_export);
       mem_driver_c_inst.seq_item_port.connect (sequencer_agent_memory_inst2.seq_item_export);
    end
    
  endfunction
  
endclass
