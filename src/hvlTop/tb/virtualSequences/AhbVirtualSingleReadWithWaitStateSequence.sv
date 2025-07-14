`ifndef AHBVIRTUALSINGLEREADWITHWAITSTATESEQUENCE_INCLUDED_
`define AHBVIRTUALSINGLEREADWITHWAITSTATESEQUENCE_INCLUDED_
 
class AhbVirtualSingleReadWithWaitStateSequence extends AhbVirtualBaseSequence;
  `uvm_object_utils(AhbVirtualSingleReadWithWaitStateSequence)
 
  AhbMasterSequence ahbMasterSequence[NO_OF_MASTERS];
 
  AhbSlaveSequence ahbSlaveSequence[NO_OF_SLAVES];
 
  extern function new(string name ="AhbVirtualSingleReadWithWaitStateSequence");
  extern task body();
 
endclass : AhbVirtualSingleReadWithWaitStateSequence
 
function AhbVirtualSingleReadWithWaitStateSequence::new(string name ="AhbVirtualSingleReadWithWaitStateSequence");
  super.new(name);
endfunction : new
 
task AhbVirtualSingleReadWithWaitStateSequence::body();
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
							      hwriteSeq ==0;
                                                              htransSeq == NONSEQ;
                                                              hburstSeq == SINGLE;
						              foreach(busyControlSeq[i]) busyControlSeq[i] dist {0:=100, 1:=0};
}
 
                                                        ) begin
       `uvm_error(get_type_name(), "Randomization failed : Inside AhbVirtualSingleReadWithWaitStateSequence")
    end
   end 
    fork
      foreach(ahbSlaveSequence[i]) begin 
       ahbSlaveSequence[i].start(p_sequencer.ahbSlaveSequencer[i]);
      end 
      foreach(ahbMasterSequence[i])
        ahbMasterSequence[i].start(p_sequencer.ahbMasterSequencer[i]); 
    join	
 
endtask : body
 
`endif 
 
