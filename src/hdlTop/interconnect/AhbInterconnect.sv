import AhbGlobalPackage::*;

interface AhbInterconnect(AhbInterface.ahbinterconnectModport  ahbInterface[NO_OF_MASTERS]); 

  int lastGrantPos;
  int found;
  genvar i;
    generate 
      for(i=0;i<NO_OF_MASTERS;i++)begin
        always_comb
          if(ahbInterface[i].haddr[2:0]==3'b 111)
            ahbInterface[i].hselx =1;
      end
    endgenerate 

endinterface
  
