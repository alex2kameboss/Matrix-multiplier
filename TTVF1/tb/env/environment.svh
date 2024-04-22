class environment extends uvm_env;

     `uvm_component_utils (environment)

     function new (string name = "environment", uvm_component parent = null);     
              super.new(name, parent);
     endfunction

     mem_agent agnt_mem;
     agent_apb agnt_apb;

     virtual function void build_phase(uvm_phase phase);
            
            super.build_phase(phase);

            agnt_mem = mem_agent::type_id::create("agnt_mem", this);
            agnt_apb = agent_apb::type_id::create("agnt_apb", this);

       //      agnt_apb.is_active = 1;
       //      agnt_mem.is_active = 1;

     endfunction

     virtual function void connect_phase (uvm_phase phase);
            super.connect_phase (phase);
            // agnt.memory_monitor_a.mon_analysis_port.connect(scor_req_ack.req_ack_imp);

     endfunction


endclass :  environment