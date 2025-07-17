import AhbGlobalPackage::*;

interface AhbInterconnect(AhbInterface.ahbinterconnectModport  ahbInterface[NO_OF_MASTERS]); 

genvar i;
  generate 
    for(i=0;i<NO_OF_MASTERS;i++)
     begin
       always_comb
         ahbInterface[i].hselx =1;
    end
  endgenerate 

endinterface
  
