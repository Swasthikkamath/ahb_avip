`ifndef HDLTOP_INCLUDED
`define HDLTOP_INCLUDED

module HdlTop;


  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import AhbGlobalPackage::*;

  initial begin
    `uvm_info("HDL_TOP","HDL_TOP",UVM_LOW);
  end


  bit hclk;
  bit hresetn;
  //bit SLAVE_ID[NO_OF_SLAVES];
  //bit MASTER_ID[NO_OF_MASTERS];
/*
  initial begin 
    foreach(SLAVE_ID[i])
      SLAVE_ID[i] = i;
   
    foreach(MASTER_ID[i])
      MASTER_ID[i] = i;
  end 
*/
  initial begin
   hclk = 1'b0;
    forever #10 hclk =!hclk;
  end

  initial begin
    hresetn = 1'b1;
   #15 hresetn= 1'b0;

   // repeat(1) begin
      @(posedge hclk);
   // end
     hresetn = 1'b1;
  end


  AhbInterface ahbInterface[NO_OF_MASTERS-1:0](hclk,hresetn);

  //AhbMasterAgentBFM ahbMasterAgentBFM[NO_OF_MASTERS-1:0](ahbInterface); 

 //AhbSlaveAgentBFM ahbSlaveAgentBFM[NO_OF_SLAVES-1:0](ahbInterface); 


  
  genvar i;

  generate 
    for(i=0; i < NO_OF_MASTERS ;i++) begin 
       AhbMasterAgentBFM#(.MASTER_ID(i)) ahbMasterAgentBFM(ahbInterface[i]);
    end 
  endgenerate 
  genvar j;

  generate
    for(j=0; j < NO_OF_SLAVES ;j++) begin
       AhbSlaveAgentBFM#(.SLAVE_ID(j)) ahbSlaveAgentBFM(ahbInterface[j]);
    end
  endgenerate

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, HdlTop); 
  end

endmodule : HdlTop

`endif
