`ifndef AHBVIRTUALWRITEWITHWAITSTATESEQUENCE_INCLUDED_
`define AHBVIRTUALWRITEWITHWAITSTATESEQUENCE_INCLUDED_
 
class AhbVirtualWriteWithWaitStateSequence extends AhbVirtualBaseSequence;
  `uvm_object_utils(AhbVirtualWriteWithWaitStateSequence)
 
  AhbMasterSequence ahbMasterSequence[NO_OF_MASTERS];
 
  AhbSlaveSequence ahbSlaveSequence[NO_OF_SLAVES];
 
  extern function new(string name ="AhbVirtualWriteWithWaitStateSequence");
  extern task body();
 
endclass : AhbVirtualWriteWithWaitStateSequence
 
function AhbVirtualWriteWithWaitStateSequence::new(string name ="AhbVirtualWriteWithWaitStateSequence");
  super.new(name);
endfunction : new
 
task AhbVirtualWriteWithWaitStateSequence::body();
  super.body();

  foreach(ahbMasterSequence[i])
    ahbMasterSequence[i] = AhbMasterSequence::type_id::create("ahbMasterSequence");
  
  foreach(ahbSlaveSequence[i]) begin
    ahbSlaveSequence[i] = AhbSlaveSequence::type_id::create("ahbSlaveSequence");
    ahbSlaveSequence[i].randomize();
  end
  foreach(ahbMasterSequence[i])begin 
    if(!ahbMasterSequence[i].randomize() with {
                                                                hsizeSeq dist {BYTE:=1, HALFWORD:=1, WORD:=1};
							//      hsizeSeq == WORD;
								hwriteSeq ==1;
                                                                htransSeq == NONSEQ;
 							//	hburstSeq == INCR4;
                                                                hburstSeq dist { 2:=1, 3:=1, 4:=1, 5:=2, 6:=2, 7:=2};
 							      foreach(busyControlSeq[i]) busyControlSeq[i] dist {0:=100, 1:=0};}
                                                        ) begin
       `uvm_error(get_type_name(), "Randomization failed : Inside AhbVirtualWriteWithWaitStateSequence")
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
