`ifndef AHBSLAVEMONITORPROXY_INCLUDED_
`define AHBSLAVEMONITORPROXY_INCLUDED_

class AhbSlaveMonitorProxy extends uvm_monitor; 
  `uvm_component_utils(AhbSlaveMonitorProxy)

  virtual AhbSlaveMonitorBFM ahbSlaveMonitorBFM;

  AhbSlaveAgentConfig ahbSlaveAgentConfig;

  uvm_analysis_port#(AhbSlaveTransaction) ahbSlaveAnalysisPort;

  string ahbSlaveIdAsci;
  
  string ahbBfmField;
  extern function new(string name = "AhbSlaveMonitorProxy", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass : AhbSlaveMonitorProxy

function AhbSlaveMonitorProxy::new(string name = "AhbSlaveMonitorProxy",uvm_component parent);
  super.new(name, parent);
  ahbSlaveAnalysisPort = new("ahbSlaveAnalysisPort",this);
endfunction : new

function void AhbSlaveMonitorProxy::build_phase(uvm_phase phase);
  super.build_phase(phase);
  /*    
  if(!uvm_config_db #(virtual AhbSlaveMonitorBFM)::get(this,"","AhbSlaveMonitorBFM", ahbSlaveMonitorBFM)) begin
    `uvm_fatal("FATAL MDP CANNOT GET AHBSLAVE MONITOR BFM","cannot get() ahbSlaveMonitorBFM");
  end
  */    
endfunction : build_phase

function void AhbSlaveMonitorProxy::end_of_elaboration_phase(uvm_phase phase);
 super.end_of_elaboration_phase(phase);
  //ahbSlaveMonitorBFM.ahbSlaveMonitorProxy = this;
endfunction : end_of_elaboration_phase

task AhbSlaveMonitorProxy::run_phase(uvm_phase phase);
      
  AhbSlaveTransaction ahbSlavePacket;
  
  ahbSlaveIdAsci.itoa(ahbSlaveAgentConfig.ahbSlaveMonitorId);
  
  ahbBfmField = {"AhbSlaveMonitorBFM" , ahbSlaveIdAsci};
  
  
  if(!uvm_config_db #(virtual AhbSlaveMonitorBFM)::get(this,"",ahbBfmField, ahbSlaveMonitorBFM)) begin
    `uvm_fatal("FATAL MDP CANNOT GET AHBSLAVE MONITOR BFM","cannot get() ahbSlaveMonitorBFM");
  end

  ahbSlavePacket = AhbSlaveTransaction::type_id::create("slave Packet");

  ahbSlaveMonitorBFM.waitForResetn();

  forever begin
    ahbTransferCharStruct structDataPacket;
    ahbTransferConfigStruct  structConfigPacket; 
    AhbSlaveTransaction  ahbSlaveClonePacket;

    AhbSlaveConfigConverter :: fromClass (ahbSlaveAgentConfig, structConfigPacket);
    ahbSlaveMonitorBFM.slaveSampleData (structDataPacket, structConfigPacket);

    $display("&&&&values inside monitor proxy %p&&&",structDataPacket);
    AhbSlaveSequenceItemConverter :: toClass (structDataPacket, ahbSlavePacket);


    $cast(ahbSlaveClonePacket, ahbSlavePacket.clone());
    `uvm_info(get_type_name(),$sformatf("Sending packet via analysis_port: , \n %s", ahbSlaveClonePacket.sprint()),UVM_HIGH)
    ahbSlaveAnalysisPort.write(ahbSlaveClonePacket);
  end

endtask : run_phase

`endif
