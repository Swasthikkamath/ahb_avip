`ifndef AHBMASTERAGENTBFM_INCLUDED_
`define AHBMASTERAGENTBFM_INCLUDED_

module AhbMasterAgentBFM #(parameter MASTER_ID = 0)(AhbInterface ahbInterface); // Change interface to AhbInterface

  import uvm_pkg::*;
  `include "uvm_macros.svh"
 

  string ahbMasterDriverId;
  string ahbMasterMonitorId;
  string ahbMasterIdAsci;
 
  initial begin
    `uvm_info("ahb master agent bfm", $sformatf("AHB MASTER AGENT BFM id is %0d",MASTER_ID), UVM_LOW);
  end
  
  AhbMasterDriverBFM ahbMasterDriverBFM (
    .hclk(ahbInterface.hclk),
    .hresetn(ahbInterface.hresetn),
    .haddr(ahbInterface.haddr),
    .hburst(ahbInterface.hburst),
    .hmastlock(ahbInterface.hmastlock),
    .hprot(ahbInterface.hprot),
    .hsize(ahbInterface.hsize),
    .hnonsec(ahbInterface.hnonsec),
    .hexcl(ahbInterface.hexcl),
    .hmaster(ahbInterface.hmaster),
    .htrans(ahbInterface.htrans),
    .hwdata(ahbInterface.hwdata),
    .hwstrb(ahbInterface.hwstrb),
    .hwrite(ahbInterface.hwrite),
    .hrdata(ahbInterface.hrdata),
    .hreadyout(ahbInterface.hreadyout),
    .hresp(ahbInterface.hresp),
    .hexokay(ahbInterface.hexokay),
    .hready(ahbInterface.hready)
    //.hselx(ahbInterface.hselx)
  );

  AhbMasterMonitorBFM ahbMasterMonitorBFM (
    .hclk(ahbInterface.hclk),
    .hresetn(ahbInterface.hresetn),
    .haddr(ahbInterface.haddr),
    .hburst(ahbInterface.hburst),
    .hmastlock(ahbInterface.hmastlock),
    .hprot(ahbInterface.hprot),
    .hsize(ahbInterface.hsize),
    .hnonsec(ahbInterface.hnonsec),
    .hexcl(ahbInterface.hexcl),
    .hmaster(ahbInterface.hmaster),
    .htrans(ahbInterface.htrans),
    .hwdata(ahbInterface.hwdata),
    .hwstrb(ahbInterface.hwstrb),
    .hwrite(ahbInterface.hwrite),
    .hrdata(ahbInterface.hrdata),
    .hreadyout(ahbInterface.hreadyout),
    .hresp(ahbInterface.hresp),
    .hexokay(ahbInterface.hexokay),
    .hready(ahbInterface.hready)
    //.hselx(ahbInterface.hselx)
  );

  initial begin
    ahbMasterIdAsci.itoa(MASTER_ID);
    ahbMasterDriverId  = {"AhbMasterDriverBFM" , ahbMasterIdAsci};
    ahbMasterMonitorId  = {"AhbMasterMonitorBFM" , ahbMasterIdAsci};
    uvm_config_db#(virtual AhbMasterDriverBFM)::set(null,"*",ahbMasterDriverId, ahbMasterDriverBFM);
    uvm_config_db#(virtual AhbMasterMonitorBFM)::set(null,"*",ahbMasterMonitorId, ahbMasterMonitorBFM);
  end
/*
   bind AhbMasterMonitorBFM AhbMasterAssertion ahb_assert (.hclk(ahbInterface.hclk),
                                                         .hresetn(ahbInterface.hresetn),
                                                         .hready(ahbInterface.hready),
                                                         .haddr(ahbInterface.haddr),
                                                         .htrans(ahbInterface.htrans),
                                                         .hwrite(ahbInterface.hwrite),
                                                         .hsize(ahbInterface.hsize),
                                                         .hburst(ahbInterface.hburst),
                                                         .hprot(ahbInterface.hprot),
                                                         .hmaster(ahbInterface.hmaster),
                                                         .hmastlock(ahbInterface.hmastlock),
                                                         .hwdata(ahbInterface.hwdata),
                                                         .hresp(ahbInterface.hresp),
                                                         .hexcl(ahbInterface.hexcl),
                                                         .hselx(ahbInterface.hselx),
							 .hwstrb(ahbInterface.hwstrb)
                                                        );
 
  bind AhbMasterMonitorBFM AhbMasterCoverProperty ahb_cover (.hclk(ahbInterface.hclk),
 							     .hresetn(ahbInterface.hresetn),
  							     .haddr(ahbInterface.haddr),
							     .hselx(ahbInterface.hselx),
							     .hburst(ahbInterface.hburst),
							     .hmastlock(ahbInterface.hmastlock),
							     .hprot(ahbInterface.hprot),
							     .hsize(ahbInterface.hsize),
							     .hnonsec(ahbInterface.hnonsec),
							     .hexcl(ahbInterface.hexcl),
							     .hmaster(ahbInterface.hmaster),
							     .htrans(ahbInterface.htrans),
							     .hwdata(ahbInterface.hwdata),
							     .hwstrb(ahbInterface.hwstrb),
							     .hwrite(ahbInterface.hwrite),
							     .hrdata(ahbInterface.hrdata),
							     .hreadyout(ahbInterface.hreadyout),
							     .hresp(ahbInterface.hresp),
							     .hexokay(ahbInterface.hexokay),
							     .hready(ahbInterface.hready)
							     );
 */
endmodule : AhbMasterAgentBFM
`endif
