import AhbGlobalPackage::*;

interface AhbInterconnect(
  input logic hclk,
  input logic hresetn,
  AhbInterface.ahbinterconnectModport ahbInterface[NO_OF_MASTERS]
);
  
  // State variables
  int lastGrantPos[NO_OF_SLAVES];
  int slaveThreshold[NO_OF_SLAVES];
  int startingPoint;
  int check_master;  
  // Loop variables
  int i, j, m, n;
  int swasthik;
  logic[3:0] d;
  logic grantThisMaster;
  logic [$clog2(NO_OF_MASTERS)-1:0]tempOwner;
  logic[$clog2(NO_OF_MASTERS)-1:0]owner;

  // Round-robin arbitration signals
  logic [NO_OF_MASTERS-1:0] master_request [NO_OF_SLAVES];
  logic [NO_OF_MASTERS-1:0] master_grant [NO_OF_SLAVES];
  logic current_owner_locked;
  int ownerTemp;
   int master_to_check; 
  // Current owner tracking
  logic [$clog2(NO_OF_MASTERS)-1:0] current_owner [NO_OF_SLAVES];
  logic slave_has_owner [NO_OF_SLAVES];
      
  // Address decode signals
  logic [NO_OF_SLAVES-1:0] slave_match [NO_OF_MASTERS];
  


 initial begin 
  for(int k=0;k<NO_OF_SLAVES;k++) begin
    slaveThreshold[k] = startingPoint + ((2**32)/NO_OF_SLAVES)-1;
    startingPoint = slaveThreshold[k]+1;
  end
end 


generate 
  for(genvar slaveLoop =0 ; slaveLoop < NO_OF_SLAVES ; slaveLoop++) begin 
    for(genvar masterLoop =0 ; masterLoop < NO_OF_MASTERS ; masterLoop++) begin 
      always_comb begin
          master_request[slaveLoop][masterLoop] = slaveLoop ==0 ? (ahbInterface[masterLoop].haddr < slaveThreshold[slaveLoop]) : ((ahbInterface[masterLoop].haddr >= slaveThreshold[slaveLoop-1]) && (ahbInterface[masterLoop].haddr < slaveThreshold[slaveLoop] ) );
      end
   end 
  end
endgenerate 

//current owner of the bus
generate 
  for(genvar slaveLoop =0; slaveLoop < NO_OF_SLAVES ;slaveLoop++) begin
    for(genvar masterLoop = 0; masterLoop < NO_OF_MASTERS ; masterLoop++) begin 
      always_ff@(posedge hclk or hresetn) begin 
        if(!hresetn) begin 
          current_owner[slaveLoop] = '0; 
          slave_has_owner[slaveLoop] = 0;
        end 
      
        else begin 
           if(master_grant[slaveLoop][masterLoop] == 1) begin 
             current_owner[slaveLoop] = masterLoop;
             slave_has_owner[slaveLoop] = 1;
           end 
          if(slave_has_owner[slaveLoop]) begin
            owner = current_owner[slaveLoop];
            if(master_request[slaveLoop][masterLoop]&& 
               (ahbInterface[masterLoop].htrans == 2'b00) &&  // IDLE
               !ahbInterface[masterLoop].hmastlock && current_owner[slaveLoop]==masterLoop) begin      // No lock
              slave_has_owner[slaveLoop] <= 1'b0;
            end
          end 
        
      end 
    end 
  end
 end  
endgenerate




generate 

  for(genvar slaveLoop = 0 ; slaveLoop < NO_OF_SLAVES ;slaveLoop++) begin 
     logic [$clog2(NO_OF_MASTERS)-1:0] rr_pointer [NO_OF_SLAVES];
   logic [$clog2(NO_OF_MASTERS)-1:0] granted_master_id;
    logic grant_found;
    int next_rr_pointer;
    logic current_owner_locked;
    int master_to_check;    
    always_ff @(posedge hclk or negedge hresetn) begin
        if(!hresetn) begin
          rr_pointer[slaveLoop] <= NO_OF_MASTERS - 1; // Start with last master, so we begin from master 0
        end else begin
          rr_pointer[slaveLoop] <= next_rr_pointer;
        end
    end
  
    always_comb begin //if my previous master goes idle  transfer ownership to other requested slave
         master_grant[slaveLoop] = '0;
        next_rr_pointer = rr_pointer[slaveLoop];
        granted_master_id = 0;
        grant_found = 1'b0;


           if(|master_request[slaveLoop]) begin // Only arbitrate if someone is requesting
            
            // FIXED: Start from the master AFTER the last served master
            // Search in round-robin order starting from (rr_pointer + 1)
            for(int search_offset = 1; search_offset <= NO_OF_MASTERS; search_offset++) begin
              master_to_check = (rr_pointer[slaveLoop] + search_offset) % NO_OF_MASTERS;
              
              if(!grant_found && master_request[slaveLoop][master_to_check]) begin
                master_grant[slaveLoop][master_to_check] = 1'b1;
                granted_master_id = master_to_check;
                grant_found = 1'b1;
                break;
              end
            end
            
            // Update pointer to point to the master we just granted
            // (This master becomes the "last served" for next round)
            if(grant_found) begin
              next_rr_pointer = granted_master_id;
            end
          end 
       end
      end  
endgenerate 

generate
    for(genvar gm = 0; gm < NO_OF_MASTERS; gm++) begin : master_select_gen
      logic [NO_OF_SLAVES-1:0] selected_slaves;
      
      for(genvar gs = 0; gs < NO_OF_SLAVES; gs++) begin : slave_select_check
        always_comb begin
          // Slave is selected if:
          // 1. This master is granted access to this slave, OR
          // 2. This master is current owner and addressing this slave
          selected_slaves[gs] = master_grant[gs][gm] || 
                               (slave_has_owner[gs] && 
                                (current_owner[gs] == gm) && 
                                master_request[gs][gm]);
        end
      end
      
      always_comb begin
        ahbInterface[gm].hselx = |selected_slaves;
      end
    end
  endgenerate



endinterface 
