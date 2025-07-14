`ifndef AHBVIRTUALWRITEWITHBUSYSEQUENCE_INCLUDED_
`define AHBVIRTUALWRITEWITHBUSYSEQUENCE_INCLUDED_
 
class AhbVirtualWriteWithBusySequence extends AhbVirtualBaseSequence;
  `uvm_object_utils(AhbVirtualWriteWithBusySequence)
 
  AhbMasterSequence ahbMasterSequence[NO_OF_MASTERS];
 
  AhbSlaveSequence ahbSlaveSequence[NO_OF_SLAVES];
 
  extern function new(string name ="AhbVirtualWriteWithBusySequence");
  extern task body();
 
endclass : AhbVirtualWriteWithBusySequence
 
function AhbVirtualWriteWithBusySequence::new(string name ="AhbVirtualWriteWithBusySequence");
  super.new(name);
endfunction : new
 
task AhbVirtualWriteWithBusySequence::body();
  super.body();
  foreach(ahbMasterSequence[i])
    ahbMasterSequence[i]= AhbMasterSequence::type_id::create("ahbMasterSequence");
  foreach(ahbSlaveSequence[i]) begin 
    ahbSlaveSequence[i]= AhbSlaveSequence::type_id::create("ahbSlaveSequence");
    ahbSlaveSequence[i].randomize();
  end
  
   foreach(ahbMasterSequence[i])begin 
    if(!ahbMasterSequence[i].randomize() with {
                                                              hsizeSeq == WORD;
							      hwriteSeq ==1;
                                                              htransSeq == NONSEQ;
                                                              hburstSeq dist { 2:=1, 3:=1, 4:=1, 5:=2, 6:=2, 7:=2}; 
                                                              foreach(busyControlSeq[i]) busyControlSeq[i] dist {0:=50, 1:=50};}
                                                        ) begin
       `uvm_error(get_type_name(), "Randomization failed : Inside AhbVirtualWriteWithBusySequence")
     end
    end 

    fork
     foreach(ahbSlaveSequence[i])
       ahbSlaveSequence[i].start(p_sequencer.ahbSlaveSequencer[i]);
     foreach(ahbMasterSequence[i])
      ahbMasterSequence[i].start(p_sequencer.ahbMasterSequencer[i]); 
    join	
  
endtask : body
 
`endif  
