class agent_apb extends uvm_agent;
  
  `uvm_component_utils (agent_apb)//se adauga agentul la baza de date a acestui proiect; de acolo, acelasi agent se va prelua ulterior spre a putea fi folosit
  
  driver_apb  driver_apb_inst0;
  monitor_apb monitor_apb_inst0;
  
  uvm_sequencer #(apb_transaction) sequencer_agent_apb_inst0;
 
  uvm_analysis_port #(apb_transaction) from_apb_monitor; 
  
  
  //se declara un camp in care spunem daca agentul este activ sau pasiv; un agent activ contine in plus, fata de agentul pasiv, driver si sequencer
  local int is_active = 1;  //0 inseamna agent pasiv; 1 inseamna agent activ

  function new (string name = "agent_apb", uvm_component parent = null);
    super.new (name, parent);
    // from_apb_monitor = new("de_la_monitor_senzor", this);
  endfunction 
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    monitor_apb_inst0 = monitor_apb::type_id::create ("monitor_apb_inst0", this);
    
    if (is_active==1) begin
      sequencer_agent_apb_inst0 = uvm_sequencer#(apb_transaction)::type_id::create ("sequencer_agent_apb_inst0", this);
      driver_apb_inst0 = driver_apb::type_id::create ("driver_apb_inst0", this);
    end
  endfunction
  
  
  //rularea unui mediu de verificare cuprinde mai multe faze; in faza "connect", se realizeaza conexiunile intre componente; in cazul agentului, se realizeaza conexiunile intre sub-componentele agentului
  virtual function void connect_phase (uvm_phase phase);
    
    super.connect_phase(phase);
    
    from_apb_monitor = monitor_apb_inst0.port_date_monitor_apb;
    
    if (is_active==1)begin
      driver_apb_inst0.seq_item_port.connect (sequencer_agent_apb_inst0.seq_item_export);
    end
    
  endfunction
  
endclass