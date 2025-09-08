`ifndef AHBSLAVEAGENTCONFIG_INCLUDED_
`define AHBSLAVEAGENTCONFIG_INCLUDED_

class AhbSlaveAgentConfig extends uvm_object;
  
  `uvm_object_utils(AhbSlaveAgentConfig) 
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  bit hasCoverage;
 
  bit ahbSlaveDriverId;
 
  bit ahbSlaveMonitorId;

  bit [ADDR_WIDTH-1:0]maximumAddress;

  bit [ADDR_WIDTH-1:0]minimumAddress;
  
  bit [7:0]slaveMemory[longint];

  virtual AhbSlaveDriverBFM ahbSlaveDriverBfm;
  
  virtual AhbSlaveMonitorBFM ahbSlaveMonitorBfm;
 
  bit [DATA_WIDTH-1:0]haddr;

  rand int noOfWaitStates; 

  rand bit needWaitStates;

  extern function new(string name = "AhbSlaveAgentConfig");
  extern function void do_print(uvm_printer printer);
  extern virtual task slaveMemoryTask(bit [ADDR_WIDTH-1:0]slaveAddress, bit [DATA_WIDTH-1:0]data); 

endclass : AhbSlaveAgentConfig

function AhbSlaveAgentConfig::new(string name = "AhbSlaveAgentConfig");
  super.new(name);
endfunction : new


function void AhbSlaveAgentConfig::do_print(uvm_printer printer);
  super.do_print(printer);

  printer.print_string ("is_active",is_active.name());
  printer.print_field ("hasCoverage",hasCoverage,$bits(hasCoverage),UVM_DEC);
  printer.print_field ("maximumAddress",maximumAddress,$bits(maximumAddress),UVM_HEX);
  printer.print_field ("minimumAddress",minimumAddress,$bits(minimumAddress),UVM_HEX);

endfunction : do_print

task AhbSlaveAgentConfig::slaveMemoryTask(bit [ADDR_WIDTH-1:0]slaveAddress, bit [DATA_WIDTH-1:0]data); 
  slaveMemory[slaveAddress] = data;
endtask : slaveMemoryTask

`endif
