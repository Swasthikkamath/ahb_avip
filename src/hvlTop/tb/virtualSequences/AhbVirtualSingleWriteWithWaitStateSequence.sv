`ifndef AHBVIRTUALSINGLEWRITEWITHWAITSTATESEQUENCE_INCLUDED_
`define AHBVIRTUALSINGLEWRITEWITHWAITSTATESEQUENCE_INCLUDED_
 
class AhbVirtualSingleWriteWithWaitStateSequence extends AhbVirtualBaseSequence;
  `uvm_object_utils(AhbVirtualSingleWriteWithWaitStateSequence)
 
  AhbMasterSequence ahbMasterSequence[NO_OF_MASTERS];
 
  AhbSlaveSequence ahbSlaveSequence[NO_OF_SLAVES];
 
  extern function new(string name ="AhbVirtualSingleWriteWithWaitStateSequence");
  extern task body();
 
endclass : AhbVirtualSingleWriteWithWaitStateSequence
 
function AhbVirtualSingleWriteWithWaitStateSequence::new(string name ="AhbVirtualSingleWriteWithWaitStateSequence");
  super.new(name);
endfunction : new
 
task AhbVirtualSingleWriteWithWaitStateSequence::body();
  super.body();
  foreach(ahbMasterSequence[i])
    ahbMasterSequence[i] = AhbMasterSequence::type_id::create("ahbMasterSequence");

  foreach(ahbSlaveSequence[i]) begin
    ahbSlaveSequence[i]= AhbSlaveSequence::type_id::create("ahbSlaveSequence");
   ahbSlaveSequence[i].randomize();
  end
  foreach(ahbMasterSequence[i])begin 
    if(!ahbMasterSequence[i].randomize() with {
                                                              hsizeSeq dist {BYTE:=1, HALFWORD:=1, WORD:=1};
							      hwriteSeq ==1;
                                                              htransSeq == NONSEQ;
                                                              hburstSeq == SINGLE;
						              foreach(busyControlSeq[i]) busyControlSeq[i] dist {0:=100, 1:=0};
}
 
                                                        ) begin
       `uvm_error(get_type_name(), "Randomization failed : Inside AhbVirtualSingleWriteWithWaitStateSequence")
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
