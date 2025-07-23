`ifndef AHBVIRTUALREADWITHBUSYSEQUENCE_INCLUDED_
`define AHBVIRTUALREADWITHBUSYSEQUENCE_INCLUDED_
 
class AhbVirtualReadWithBusySequence extends AhbVirtualBaseSequence;
  `uvm_object_utils(AhbVirtualReadWithBusySequence)
 
  AhbMasterSequence ahbMasterSequence[NO_OF_MASTERS];
 
  AhbSlaveSequence ahbSlaveSequence[NO_OF_SLAVES];
 
  extern function new(string name ="AhbVirtualReadWithBusySequence");
  extern task body();
 
endclass : AhbVirtualReadWithBusySequence
 
function AhbVirtualReadWithBusySequence::new(string name ="AhbVirtualReadWithBusySequence");
  super.new(name);
endfunction : new
 
task AhbVirtualReadWithBusySequence::body();
  super.body();
  foreach(ahbMasterSequence[i])
    ahbMasterSequence[i]= AhbMasterSequence::type_id::create("ahbMasterSequence");
  foreach(ahbSlaveSequence[i]) begin
    ahbSlaveSequence[i]= AhbSlaveSequence::type_id::create("ahbSlaveSequence");
    ahbSlaveSequence[i].randomize();
   end
   foreach(ahbMasterSequence[i])begin 
    if(!ahbMasterSequence[i].randomize() with {
                                                              hsizeSeq dist {BYTE:=1, HALFWORD:=1, WORD:=1};
							      hwriteSeq == 0;
                                                              htransSeq == NONSEQ;
                                                              hburstSeq dist { 2:=1, 3:=1, 4:=1, 5:=2, 6:=2, 7:=2}; 
                                                              foreach(busyControlSeq[i]) busyControlSeq[i] dist {0 := 75,1 := 25};}
                                                        ) begin
       `uvm_error(get_type_name(), "Randomization failed : Inside AhbVirtualReadWithBusySequence")
    end
   end 
    fork
       $display("\n\n\n--------------------------------ENTERED FORK---------------------------------------\n\n\n ");
       foreach(ahbMasterSequence[i]) begin 
         fork
            automatic int j = i;
            ahbMasterSequence[j].start(p_sequencer.ahbMasterSequencer[j]);
         join_none 
       end 
       foreach(ahbSlaveSequence[i]) begin
         fork
          automatic int j =i;
          ahbSlaveSequence[j].start(p_sequencer.ahbSlaveSequencer[j]);
         join_none
        end 
     join
    wait fork;
   $display("\n\n\n -------------------------------FORK ENDED---------------------------------- \n\n\n");	

endtask : body
 
`endif  
