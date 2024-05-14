class apb_base_test extends uvm_test;
    `uvm_component_utils(apb_base_test)

//---------------------------------Constructor of class------------------------------
    function new( string name = "apb_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    environment m_env;
//-----------------------------------Build phase-------------------------------------
    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        m_env = environment::type_id::create("m_env", this);
    endfunction


    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

//-----------------------------------Connect phase-------------------------------------
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction : connect_phase

endclass : apb_base_test

// class first_succes_test extends apb_base_test;
//     `uvm_component_utils(first_succes_test)

//     function new( string name = "first_succes_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual task run_phase (uvm_phase phase);

//         apb_sequence apb_seq = apb_sequence::type_id::create("apb_seq");

//         phase.raise_objection(this);
//         apb_seq.start(m_env.agnt_apb.sequencer_agent_apb_inst0);
//         `uvm_info(get_type_name(),$sformatf ("First test"), UVM_NONE)
//         $display("test....");
//         phase.drop_objection (this);

//     endtask
// endclass : first_succes_test

class config_test extends apb_base_test;
    `uvm_component_utils(config_test)

    function new( string name = "config_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase (uvm_phase phase);

        config_sequence apb_config_seq = config_sequence::type_id::create("apb_seq");

        phase.raise_objection(this);
        apb_config_seq.start(m_env.agnt_apb.sequencer_agent_apb_inst0);
        `uvm_info(get_type_name(),$sformatf ("First test"), UVM_NONE)
        $display("test....");
        phase.drop_objection (this);

    endtask
endclass : config_test

// class write_read_test extends apb_base_test;
//     `uvm_component_utils(write_read_test)

//     function new( string name = "write_read_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual task run_phase (uvm_phase phase);

//         write_read_sequence apb_wr_seq = write_read_sequence::type_id::create("apb_wr_seq");

//         phase.raise_objection(this);
//         apb_wr_seq.start(m_env.agnt_apb.sequencer_agent_apb_inst0);
//         `uvm_info(get_type_name(),$sformatf ("First test"), UVM_NONE)
//         $display("test....");
//         phase.drop_objection (this);

//     endtask
// endclass : write_read_test


// class w_all_ffffffff_test extends apb_base_test;
//     `uvm_component_utils(w_all_ffffffff_test)

//     function new( string name = "w_all_ffffffff_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual task run_phase (uvm_phase phase);

//         write_all_ffffffff apb_seq_fff = write_all_ffffffff::type_id::create("apb_seq_fff");

//         phase.raise_objection(this);
//         apb_seq_fff.start(m_env.agnt_apb.sequencer_agent_apb_inst0);
//         `uvm_info(get_type_name(),$sformatf ("First test"), UVM_NONE)
//         $display("test....");
//         phase.drop_objection (this);

//     endtask
// endclass : w_all_ffffffff_test
