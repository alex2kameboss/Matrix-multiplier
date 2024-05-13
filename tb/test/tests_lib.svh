class apb_base_test extends uvm_test;

    `uvm_component_utils(apb_base_test)

//---------------------------------Constructor of class------------------------------
    function new( string name = "apb_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    environment m_env;

// poate trebuie sa schimb itemul , nu merge asa ,  nu stiu care e prblema  
    // uvm_tlm_analysis_fifo#(intrr_item) interrupt_fifo;

//-----------------------------------Build phase-------------------------------------
    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        m_env = environment::type_id::create("m_env", this);
        // interrupt_fifo = new("interrupt_fifo", this);
    endfunction


    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

//-----------------------------------Connect phase-------------------------------------
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // environment.agnt_apb.monitor_apb_inst0.mon_analysis_port_intr.connect(interrupt_fifo.analysis_export);
    endfunction : connect_phase

    // task wait_interrupt();
      //  intrr_item item;
        // interrupt_fifo.get(item);
    // endtask : wait_interrupt
endclass : apb_base_test

 
// First test with random opration
class first_succes_test extends apb_base_test;

    `uvm_component_utils(first_succes_test)

    function new( string name = "first_succes_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase (uvm_phase phase);

        apb_sequence apb_seq = apb_sequence::type_id::create("apb_seq");

        phase.raise_objection(this);

        apb_seq.start(m_env.agnt_apb.sequencer_agent_apb_inst0);
        `uvm_info(get_type_name(),$sformatf ("First test"), UVM_NONE)
        $display("test....");
        
        phase.drop_objection (this);

    endtask

endclass : first_succes_test