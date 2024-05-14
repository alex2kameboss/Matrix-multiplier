`ifndef __scoreboard
`define __scoreboard

//se declara prefixele pe care le vor avea elementele folosite pentru a prelua datele 
`uvm_analysis_imp_decl(_memorie)
`uvm_analysis_imp_decl(_apb)

class scoreboard extends uvm_scoreboard;
  
  //se adauga componenta in baza de date UVM
  `uvm_component_utils(scoreboard)
  
  //se declara porturile prin intermediul carora scoreboardul primeste datele de la agenti, aceste date reflectand functionalitatea DUT-ului
  //a se observa ca prefixele declarate mai sus intra in componenta tipului de data al porturilor
  //pentru fiecare port declarat, se spune carui tip de scoreboard ii apartine (in situatia de fata avem doar o clasa care defineste scoreboardul cu numele "scoreboard") portul, si ce tip de date vor fi vehiculate pe portul respectiv
  uvm_analysis_imp_memorie #(tranzactie_agent_memorie, scoreboard) port_pentru_datele_de_laA;
  uvm_analysis_imp_memorie #(tranzactie_agent_memorie, scoreboard) port_pentru_datele_de_laB;
  uvm_analysis_imp_memorie #(tranzactie_agent_memorie, scoreboard) port_pentru_datele_de_laC;
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_laAPB;
  
  //se declara colectorul de coverage folosit pentru a se inregistra ce valori a generat apbul atunci cand DUT-ul era pornit (enable = 1)
  coverage_valori_citite_memorie_ref colector_coverage_scoreboard;
  
  //pentru a inregistra coverage-ul dorit avem nevoie sa stim atat ce valori au venit de la apbi
  tranzactie_apb tranzactie_config;
  //se declara structura care va retine datele prezise de modelul de referinta; aceste date vor fi comparate cu datele de la iesirea DUT-ului
  tranzactie_memorie tranzactie_A, tranzactie_B, tranzactie_C, tranzactie_de_la_dut;
  
  //lista in care se retin tranzactiile pentru memoriei calculate de referinta; folosim o lista deoarece referinta calculeaza mai repede in ce stare se afla memorieii decat DUT-ul, si aceste calcule trebuie retinute pana cand se culeg datele si de la DUT
  //tranzactie_agent_memorie lista_tranzactii_ref [$];
  
  bit enable;
  
  int exp_N, exp_M, exp_P;
  int exp_addrA, exp_addrB, exp_addrC;
  int exp_A [exp_M][exp_N];
  int exp_B [exp_N][exp_P];
  int exp_C [exp_M][exp_P];
  int status;
  
  bit[7:0] data_A [$];
  bit[7:0] data_B [$];
  bit[15:0]data_C [255:0]; //address: data
  bit[7:0] data_C_after_sort [$];
  
  covergroup cov_trans;
    exp_M : coverpoint exp_M_cp {
      bins b1 = {32};
      bins b2 = {1024};
      bins b3 = {64, 96, 128, 160, 992}; //multipli de 32
	  }
	exp_N : coverpoint exp_N_cp {
      bins b1 = {32};
      bins b2 = {1024};
      bins b3 = {64, 96, 128, 160, 992}; //multipli de 32
	  }	  
	exp_P : coverpoint exp_P_cp {
      bins b1 = {32};
      bins b2 = {1024};
      bins b3 = {64, 96, 128, 160, 992}; //multipli de 32
	  }
	exp_M_exp_N: cross exp_M_cp,exp_N_cp;
	exp_N_exp_P: cross exp_N_cp,exp_P_cp;
	exp_M_exp_P: cross exp_M_cp,exp_P_cp;
	
	exp_addrA : coverpoint exp_addrA_cp {
      bins b1 = {0};
      bins b2 = {1024};
      bins b3 = {[1:1024]};
	  bins b4 = {[1025:9999]};//out_of_range
	  }
	exp_addrB : coverpoint exp_addrB_cp {
      bins b1 = {0};
      bins b2 = {1024};
      bins b3 = {[1:1024]};
	  bins b4 = {[1025:9999]};
	  }
	exp_addrC : coverpoint exp_addrB_cp {
      bins b1 = {0};
      bins b2 = {1024};
      bins b3 = {[1:1024]};
	  bins b4 = {[1025:9999]};
	  }
	 status :coverpoint status_cp {
      bins b1 = {'b0};
      bins b2 = {'b1};//START
      bins b3 = {'b2};//STOP
	  bins b4 = {'b4};//ERR
	  }
  endgroup
  
  cov_trans cov_trans_i = new();

   //constructorul clasei
  function new(string name="scoreboard", uvm_component parent=null);
    //se apeleaza mai intai constructorul clasei parinte
    super.new(name, parent);
    //crearea porturilor
    port_pentru_datele_de_laMemorie = new("pentru_datele_de_laMemorie", this);
    port_pentru_datele_de_laAPB= new("pentru_datele_de_laAPB", this);
    // C = A*B
    tranzactie_config = new(); //APB
    
    tranzactie_A = new();
	
	tranzactie_B = new();
	
	tranzactie_C = new();
	
    tranzactie_de_la_dut  = new(); // C de la DUT
    
    //se creeaza colectorul de coverage (la creare, se apeleaza constructorul colectorului de coverage)
    //colector_coverage_scoreboard = coverage_valori_citite_apb_ref::type_id::create("colector_coverage_scoreboard", this);
    
  endfunction
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
    ///colector_coverage_fsm_memorie_inteligenta.p_scoreboard = this;
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  
  //fiecare port de analiza UVM are atasata o functie write; prefixul declarat la inceputul acestui fisier pentru fiecare port se ataseaza automat functiei write, obtinand denumirile de mai jos
  //functiile write ale fiecarui port de date sunt apelate de componentele care pun date pe respectivul port (a se vedea fisierele unde sunt declarati agentii); aici, respectivele functii sunt implementate, pentru ca scoreboardul sa stie cum sa reactioneze atunci cand primeste date pe fiecare din porturi
  function void write_apb(input tranzactie_apb tranzactie_noua_apb);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul APB tranzactia cu informatia:\n"), UVM_LOW)
    tranzactie_noua_APB.afiseaza_informatia_tranzactiei();
	tranzactie_venita_de_la_apb = new();
	 // rand bit          write;
     // rand bit [16-1 :0] addr ;
     // rand bit [8 -1:0] data ;
     // rand int          delay;
     // rand bit [DWITH -1:0] prdata;
    if (tranzactie_venita_de_la_apb.addr == 'h0) exp_addrA = tranzactie_venita_de_la_apb.data;
    if (tranzactie_venita_de_la_apb.addr == 'h1) exp_addrB = tranzactie_venita_de_la_apb.data;
    if (tranzactie_venita_de_la_apb.addr == 'h2) exp_addrC = tranzactie_venita_de_la_apb.data;
    if (tranzactie_venita_de_la_apb.addr == 'h3) exp_N = tranzactie_venita_de_la_apb.data;
    if (tranzactie_venita_de_la_apb.addr == 'h4) exp_M = tranzactie_venita_de_la_apb.data;
    if (tranzactie_venita_de_la_apb.addr == 'h5) exp_P = tranzactie_venita_de_la_apb.data;
    if (tranzactie_venita_de_la_apb.addr == 'h6) status = tranzactie_noua_apb.status;
    cov_trans_i.sample();
  endfunction : write_apb
  
  function void write_A(input tranzactie_memorie tranzactie_noua_memorie);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul memorie A:\n"), UVM_LOW)
    //tranzactie_noua_memorie.afiseaza_informatia_tranzactiei_agent_memorie  
	if (exp_addrC != tranzactie_noua_memorie.addr )  `uvm_error("ERROR", $sformat("Expected addr %0d actual %0d", exp_addrA, tranzactie_noua_memorie.addr));
	for(int i=0;i<(256:8);i=i+8)
		if(tranzactie_noua_memorie.data[(i*8-1):i])
			data_A.push_back(tranzactie_noua_memorie.data[(i*8-1):i]);
  endfunction : write_A
  
  function void write_B(input tranzactie_memorie tranzactie_noua_memorie);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul memorie B:\n"), UVM_LOW)
    //tranzactie_noua_memorie.afiseaza_informatia_tranzactiei_agent_memorie  
	if (exp_addrB != tranzactie_noua_memorie.addr )  `uvm_error("ERROR", $sformat("Expected addr %0d actual %0d", exp_addrB, tranzactie_noua_memorie.addr));
	for(int i=0;i<(256:8);i=i+8)
		if(tranzactie_noua_memorie.data[(i*8-1):i])
			data_B.push_back(tranzactie_noua_memorie.data[(i*8-1):i]);
	
  endfunction : write_B
  
  function void write_C(input tranzactie_memorie tranzactie_noua_memorie);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul memorie C:\n"), UVM_LOW)
    //tranzactie_noua_memorie.afiseaza_informatia_tranzactiei_agent_memorie  
	data_C[tranzactie_noua_memorie.addr].push_back(tranzactie_noua_memorie.data);
	
	for 
  endfunction : write_C
  
  function void reconstruct_A(bit[7:0] data[$], int n, int m);
   for (int i=0;i<n;i++)
    for (int j=0;j<m;j++)
	exp_A[i][j] = data.pop_front();
  endfunction : reconstruct
  
   function void reconstruct_B(bit[7:0] data[$], int n, int m);
   for (int i=0;i<n;i++)
    for (int j=0;j<m;j++)
	exp_B[i][j] = data.pop_front();
  endfunction : reconstruct
  
   function void reconstruct_C(bit[7:0] data[$], int n, int m);
   for (int i=0;i<n;i++)
    for (int j=0;j<m;j++)
	exp_C[i][j] = data.pop_front();
  endfunction : reconstruct
  
    function verifica_corespondenta_datelor(tranzactie_memorie tranzactie_C, tranzactie_memorie tranzactie_de_la_dut);
	for (int i=0;i<exp_M;i++)
		for (int j=0;j<exp_P;j++)
			if(exp_C[i][j] != tranzactie_de_la_dut.data[i][j]) `uvm_error("ERROR", $sformat("Expected data %0d actual %0d", exp_C[i][j], tranzactie_de_la_dut.data[i][j]));
  endfunction
  
  function calculeaza_exp_c(tranzactie_memorie tranzactie_A, tranzactie_memorie tranzactie_B);
	for (int i=0;i<exp_N;i++)
		for (int j=0;j<exp_P;j++)
			for(int k=0;k<=exp_M;k++)
				exp_C[i][j]+=exp_A[i][k]*exp_B[k][j];
    
  endfunction
  
  virtual function void check_phase (uvm_phase phase);
    super.check_phase(phase);
	reconstruct_A(data_A, exp_N, exp_M);
	reconstruct_B(data_B, exp_M, exp_P);
     //sort  C by addr
   bit [16:0]aux;
   bit [7:0]x;
   for (int i=0;i<data_C.size();i++)
	for (int j=0;j<data_C.size()-1;j++)
	if(i<j){
	aux= data_C[i];
	data_C[i]=data_C[j];
	data_C[j]=aux;
	}
	for (int i=0;i<data_C.size();i++)begin
	 x=data_C[i].pop_front();
	 for(int j=0;j<(256:8);j=j+8)
	  data_C_after_sort[i].push_back(x[(i*8-1):i]);
	end
	reconstruct_C(data_C_after_sort, exp_N, exp_P);
	if (exp_addrC != tranzactie_de_la_dut.addr )  `uvm_error("ERROR", $sformat("Expected addr %0d actual %0d", exp_addrC, tranzactie_de_la_dut.addr));
	//TBD verifica dimensiunile 
	calculeaza_exp_c(exp_A, exp_B);
	verifica_corespondenta_datelor (tranzactie_noua_memorie.data, exp_C);
  endfunction
         
endclass
`endif

/*`ifndef __scoreboard
`define __scoreboard

//se declara prefixele pe care le vor avea elementele folosite pentru a prelua datele 
`uvm_analysis_imp_decl(_memorie)
`uvm_analysis_imp_decl(_apb)

class scoreboard extends uvm_scoreboard;
  
  //se adauga componenta in baza de date UVM
  `uvm_component_utils(scoreboard)
  
  //se declara porturile prin intermediul carora scoreboardul primeste datele de la agenti, aceste date reflectand functionalitatea DUT-ului
  //a se observa ca prefixele declarate mai sus intra in componenta tipului de data al porturilor
  //pentru fiecare port declarat, se spune carui tip de scoreboard ii apartine (in situatia de fata avem doar o clasa care defineste scoreboardul cu numele "scoreboard") portul, si ce tip de date vor fi vehiculate pe portul respectiv
  uvm_analysis_imp_memorie #(tranzactie_agent_memorie, scoreboard) port_pentru_datele_de_laA;
  uvm_analysis_imp_memorie #(tranzactie_agent_memorie, scoreboard) port_pentru_datele_de_laB;
  uvm_analysis_imp_memorie #(tranzactie_agent_memorie, scoreboard) port_pentru_datele_de_laC;
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_laAPB;
  
  //se declara colectorul de coverage folosit pentru a se inregistra ce valori a generat apbul atunci cand DUT-ul era pornit (enable = 1)
  coverage_valori_citite_memorie_ref colector_coverage_scoreboard;
  
  //pentru a inregistra coverage-ul dorit avem nevoie sa stim atat ce valori au venit de la apbi
  tranzactie_apb tranzactie_config;
  //se declara structura care va retine datele prezise de modelul de referinta; aceste date vor fi comparate cu datele de la iesirea DUT-ului
  tranzactie_memorie tranzactie_A, tranzactie_B, tranzactie_C, tranzactie_de_la_dut;
  
  //lista in care se retin tranzactiile pentru memoriei calculate de referinta; folosim o lista deoarece referinta calculeaza mai repede in ce stare se afla memorieii decat DUT-ul, si aceste calcule trebuie retinute pana cand se culeg datele si de la DUT
  //tranzactie_agent_memorie lista_tranzactii_ref [$];
  
  bit enable;
  
  int exp_N, exp_M, exp_P;
  int exp_addrA, exp_addrB, exp_addrC;
  int exp_A [exp_M][exp_N];
  int exp_B [exp_N][exp_P];
  int exp_C [exp_M][exp_P];
  
   //constructorul clasei
  function new(string name="scoreboard", uvm_component parent=null);
    //se apeleaza mai intai constructorul clasei parinte
    super.new(name, parent);
    //crearea porturilor
    port_pentru_datele_de_laMemorie = new("pentru_datele_de_laMemorie", this);
    port_pentru_datele_de_laAPB= new("pentru_datele_de_laAPB", this);
    // C = A*B
    tranzactie_config = new(); //APB
    
    tranzactie_A = new();
	
	tranzactie_B = new();
	
	tranzactie_C = new();
	
    tranzactie_de_la_dut  = new(); // C de la DUT
    
    //se creeaza colectorul de coverage (la creare, se apeleaza constructorul colectorului de coverage)
    //colector_coverage_scoreboard = coverage_valori_citite_apb_ref::type_id::create("colector_coverage_scoreboard", this);
    
  endfunction
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
    ///colector_coverage_fsm_memorie_inteligenta.p_scoreboard = this;
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  
  //fiecare port de analiza UVM are atasata o functie write; prefixul declarat la inceputul acestui fisier pentru fiecare port se ataseaza automat functiei write, obtinand denumirile de mai jos
  //functiile write ale fiecarui port de date sunt apelate de componentele care pun date pe respectivul port (a se vedea fisierele unde sunt declarati agentii); aici, respectivele functii sunt implementate, pentru ca scoreboardul sa stie cum sa reactioneze atunci cand primeste date pe fiecare din porturi
  function void write_apb(input tranzactie_apb tranzactie_noua_apb);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul APB tranzactia cu informatia:\n"), UVM_LOW)
    tranzactie_noua_APB.afiseaza_informatia_tranzactiei();
	tranzactie_venita_de_la_apb = new();
	exp_N = tranzactie_noua_apb.N;
	exp_M = tranzactie_noua_apb.M;
	exp_P = tranzactie_noua_apb.P;
    exp_addrA = tranzactie_noua_apb.addrA;
	exp_addrB = tranzactie_noua_apb.addrB;
	exp_addrC = tranzactie_noua_apb.addrC;
  endfunction : write_apb
  
  function void write_A(input tranzactie_memorie tranzactie_noua_memorie);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul memorie A:\n"), UVM_LOW)
    //tranzactie_noua_memorie.afiseaza_informatia_tranzactiei_agent_memorie  
	if (exp_addrA != tranzactie_noua_memorie.addr )  `uvm_error("ERROR", $sformat("Expected addr %0d actual %0d", exp_addrA, tranzactie_noua_memorie.addr));
	//TBD verifica dimensiunile 
	exp_A = tranzactie_noua_memorie.data;
  endfunction : write_A
  
  function void write_B(input tranzactie_memorie tranzactie_noua_memorie);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul memorie B:\n"), UVM_LOW)
    //tranzactie_noua_memorie.afiseaza_informatia_tranzactiei_agent_memorie  
	if (exp_addrB != tranzactie_noua_memorie.addr )  `uvm_error("ERROR", $sformat("Expected addr %0d actual %0d", exp_addrB, tranzactie_noua_memorie.addr));
	//TBD verifica dimensiunile 
	
  endfunction : write_B
  
  function void write_C(input tranzactie_memorie tranzactie_noua_memorie);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul memorie C:\n"), UVM_LOW)
    //tranzactie_noua_memorie.afiseaza_informatia_tranzactiei_agent_memorie  
	if (exp_addrC != tranzactie_de_la_dut.addr )  `uvm_error("ERROR", $sformat("Expected addr %0d actual %0d", exp_addrC, tranzactie_de_la_dut.addr));
	//TBD verifica dimensiunile 
	calculeaza_exp_c(exp_A, exp_B);
	verifica_corespondenta_datelor (tranzactie_noua_memorie.data, exp_C);
  endfunction : write_C
  
          
  function verifica_corespondenta_datelor(tranzactie_memorie tranzactie_C, tranzactie_memorie tranzactie_de_la_dut);
	for (int i=0;i<exp_M;i++)
		for (int j=0;j<exp_P;j++)
			if(exp_C[i][j] != tranzactie_de_la_dut.data[i][j]) `uvm_error("ERROR", $sformat("Expected data %0d actual %0d", exp_C[i][j], tranzactie_de_la_dut.data[i][j]));
  endfunction
  
  function calculeaza_exp_c(tranzactie_memorie tranzactie_A, tranzactie_memorie tranzactie_B);
	for (int i=0;i<exp_N;i++)
		for (int j=0;j<exp_P;j++)
			for(int k=0;k<=exp_M;k++)
				exp_C[i][j]+=exp_A[i][k]*exp_B[k][j];
  endfunction
endclass
`endif*/