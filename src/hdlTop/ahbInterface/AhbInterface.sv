`ifndef AHBINTERFACE_INCLUDED_
`define AHBINTERFACE_INCLUDED_

import AhbGlobalPackage::*;

interface AhbInterface(input hclk, input hresetn);
  
  wire  [ADDR_WIDTH-1:0] haddr;
  logic [NO_OF_SLAVES-1:0] hselx;
  
  wire [2:0] hburst;

  wire hmastlock;

  wire [HPROT_WIDTH-1:0] hprot;
 
  wire [2:0] hsize;

  wire hnonsec;

  wire hexcl;

  wire [HMASTER_WIDTH-1:0] hmaster;

  wire [1:0] htrans;


  wire [DATA_WIDTH-1:0] hwdata;

  wire [(DATA_WIDTH/8)-1:0] hwstrb;

  wire hwrite;

  wire [DATA_WIDTH-1:0] hrdata;

  logic hreadyout;

  wire hresp;

  wire hexokay;

  logic hready;

 modport ahbinterconnectModport(input hreadyout, output hready,hselx, inout  haddr,hburst,hprot,hmastlock,hsize,hnonsec,hexcl,hmaster,htrans,hwdata,hwstrb,hwrite,hresp,hrdata);
 endinterface : AhbInterface

`endif

