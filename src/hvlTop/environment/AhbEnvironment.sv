`ifndef AHBENVIRONMENT_INCLUDED_
`define AHBENVIRONMENT_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: AhbEnvironment
// Creates master agent and slave agent and scoreboard
//--------------------------------------------------------------------------------------------
class AhbEnvironment extends uvm_env;
  `uvm_component_utils(AhbEnvironment)

  //Variable: ahbMasterAgent
  //Declaring ahb master agent handle
  AhbMasterAgent ahbMasterAgent[];

  //Variable: ahbSlaveAgent
  //Declaring ahb slave agent handle
  AhbSlaveAgent  ahbSlaveAgent[];

  //Variable: ahbScoreboard
  //Declaring ahb scoreboard handle
  AhbScoreboard ahbScoreboard;

  //Variable: ahbVirtualSequencer
  //Declaring ahb virtual seqr handle
  AhbVirtualSequencer ahbVirtualSequencer;
  
  //Variable: ahbEnvironmentConfig
  //Declaring handle for ahb_env_config_object
  AhbEnvironmentConfig ahbEnvironmentConfig;  

  AhbMasterAgentConfig ahbMasterAgentConfig[];

  AhbSlaveAgentConfig ahbSlaveAgentConfig[];
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "AhbEnvironment", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass : AhbEnvironment

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - AhbEnvironment
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function AhbEnvironment::new(string name = "AhbEnvironment",uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: build_phase
// Builds the master and slave agents and scoreboard
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void AhbEnvironment::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db #(AhbEnvironmentConfig)::get(this,"","AhbEnvironmentConfig",ahbEnvironmentConfig)) begin
    `uvm_fatal("FATAL_ENV_CONFIG", $sformatf("Couldn't get the ahbEnvironmentConfig from config_db"))
  end

  ahbMasterAgentConfig = new[ahbEnvironmentConfig.noOfMasters];
    foreach(ahbMasterAgentConfig[i])
      begin
        ahbMasterAgentConfig[i] = ahbEnvironmentConfig.ahbMasterAgentConfig[i];
        if(!uvm_config_db #(AhbMasterAgentConfig)::get(this,"",$sformatf("AhbMasterAgentConfig[%0d]",i),ahbMasterAgentConfig[i])) begin
          `uvm_fatal("FATAL_MA_AGENT_CONFIG", $sformatf("Couldn't get the ahbMasterAgentConfig from config_db"))
        end
      end

  ahbMasterAgent = new[ahbEnvironmentConfig.noOfMasters];
    foreach(ahbMasterAgent[i]) begin
      ahbMasterAgent[i] = AhbMasterAgent::type_id::create($sformatf("ahbMasterAgent[%0d]",i),this);
    end

  ahbSlaveAgentConfig = new[ahbEnvironmentConfig.noOfSlaves];
    foreach(ahbSlaveAgentConfig[i]) begin
      ahbSlaveAgentConfig[i] = ahbEnvironmentConfig.ahbSlaveAgentConfig[i];
      if(!uvm_config_db #(AhbSlaveAgentConfig)::get(this,"",$sformatf("AhbSlaveAgentConfig[%0d]",i), ahbSlaveAgentConfig[i])) begin
        `uvm_fatal("FATAL_MA_CANNOT_GET_AHB_SLAVE_AGENT_CONFIG", "cannot get ahbSlaveAgentConfig from uvm_config_db");
      end
    end

  ahbSlaveAgent = new[ahbEnvironmentConfig.noOfSlaves];
    foreach(ahbSlaveAgent[i]) begin
      ahbSlaveAgent[i] = AhbSlaveAgent::type_id::create($sformatf("ahbSlaveAgent[%0d]",i),this);
    end

    if(ahbEnvironmentConfig.hasVirtualSequencer) begin
      ahbVirtualSequencer = AhbVirtualSequencer::type_id::create("ahbVirtualSequencer",this);
      ahbVirtualSequencer.ahbMasterSequencer = new[ahbEnvironmentConfig.noOfMasters];
      ahbVirtualSequencer.ahbSlaveSequencer = new[ahbEnvironmentConfig.noOfSlaves];  
    end

    if(ahbEnvironmentConfig.hasScoreboard) begin
      ahbScoreboard = AhbScoreboard::type_id::create("ahbScoreboard",this);
    end

    foreach(ahbMasterAgent[i]) begin
      ahbMasterAgent[i].ahbMasterAgentConfig=ahbMasterAgentConfig[i];
    end

    foreach(ahbSlaveAgent[i]) begin  
      ahbSlaveAgent[i].ahbSlaveAgentConfig=ahbSlaveAgentConfig[i];
    end

endfunction : build_phase

//--------------------------------------------------------------------------------------------
// Function: connect_phase
//  Connects the master agent monitor's analysis_port with scoreboard's analysis_fifo 
//  Connects the slave agent monitor's analysis_port with scoreboard's analysis_fifo 
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void AhbEnvironment::connect_phase(uvm_phase phase); 
  super.connect_phase(phase);
  if(ahbEnvironmentConfig.hasVirtualSequencer) begin
    foreach(ahbMasterAgent[i]) begin
      ahbVirtualSequencer.ahbMasterSequencer[i] = ahbMasterAgent[i].ahbMasterSequencer;
     end
     foreach(ahbSlaveAgent[i]) begin
       ahbVirtualSequencer.ahbSlaveSequencer[i] = ahbSlaveAgent[i].ahbSlaveSequencer;
     end
  end

  foreach(ahbMasterAgent[i]) begin
    ahbMasterAgent[i].ahbMasterMonitorProxy.ahbMasterAnalysisPort.connect(ahbScoreboard.ahbMasterAnalysisFifo[i].analysis_export);
  end

  foreach(ahbSlaveAgent[i]) begin
    ahbSlaveAgent[i].ahbSlaveMonitorProxy.ahbSlaveAnalysisPort.connect(ahbScoreboard.ahbSlaveAnalysisFifo[i].analysis_export);
  end

endfunction : connect_phase

`endif
