{********************************************                                   
; File: NoteSeq.p                                                               
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT NOTESEQ;                                                                   
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
pitchBend = $0; {Command -  }                                                   
tempo = $00000001; {Command -  }                                                
turnNotesOff = $00000002; {Command -  }                                         
jump = $00000003; {Command -  }                                                 
setVibratoDepth = $00000004; {Command -  }                                      
programChange = $00000005; {Command -  }                                        
setRegister = $00000006; {Command -  }                                          
ifGo = $00000007; {Command -  }                                                 
incRegister = $00000008; {Command -  }                                          
decRegister = $00000009; {Command -  }                                          
midiNoteOff = $0000000A; {Command -  }                                          
midiNoteOn = $0000000B; {Command -  }                                           
midiPolyKey = $0000000C; {Command -  }                                          
midiCtlChange = $0000000D; {Command -  }                                        
midiProgChange = $0000000E; {Command -  }                                       
midiChnlPress = $0000000F; {Command -  }                                        
midiPitchBend = $00000010; {Command -  }                                        
midiSelChnlMode = $00000011; {Command -  }                                      
midiSysExclusive = $00000012; {Command -  }                                     
midiSysCommon = $00000013; {Command -  }                                        
midiSysRealTime = $00000014; {Command -  }                                      
midiSetSysExl = $00000015; {Command -  }                                        
commandMask = $0000007F; {Command -  }                                          
volumeMask = $0000007F; {Command -  }                                           
chord = $00000080; {Command -  }                                                
val1Mask = $00007F00; {Command -  }                                             
toneMask = $00007F00; {Command -  }                                             
noteMask = $00008000; {Command -  }                                             
lByte = $00FF0000; {Command - meaning depends on midi command }                 
durationMask = $07FF0000; {Command -  }                                         
trackMask = $78000000; {Command -  }                                            
delayMask = $80000000; {Command -  }                                            
hByte = $FF000000; {Command -  }                                                
                                                                                
(* *** Toolset Errors ***                                                       
noRoomMidiErr = $1A00; {error -  }                                              
noCommandErr = $1A01; {error - can't understand the current SeqItem }           
noRoomErr = $1A02; {error - sequence is more than twelve levels deep }          
startedErr = $1A03; {error - Note Sequencer is already started }                
noNoteErr = $1A04; {error - can't find the note to be turned off by the current 
SeqItem }                                                                       
noStartErr = $1A05; {error - Note Sequencer not started yet }                   
instBndsErr = $1A06; {error - Instrument number out of Instrument boundary      
range }                                                                         
nsWrongVer = $1A07; {error - incompatible versions of NoteSequencer and         
NoteSynthesizer }                                                               
   *** Toolset Errors *** *)                                                    
                                                                                
TYPE                                                                            
LocRecHndl = ^LocRecPtr;                                                        
LocRecPtr = ^LocRec;                                                            
LocRec = RECORD                                                                 
    curPhraseItem : Integer;                                                    
    curPattItem : Integer;                                                      
    curLevel : Integer;                                                         
END;                                                                            
PROCEDURE SeqBootInit   ; Tool $1A,$01;                                         
PROCEDURE SeqStartUp ( dPageAddr:Integer; mode:Integer; updateRate:Integer;     
increment:Integer)  ; Tool $1A,$02;                                             
PROCEDURE SeqShutDown   ; Tool $1A,$03;                                         
FUNCTION SeqVersion  : Integer ; Tool $1A,$04;                                  
PROCEDURE SeqReset   ; Tool $1A,$05;                                            
FUNCTION SeqStatus  : Boolean ; Tool $1A,$06;                                   
PROCEDURE SeqAllNotesOff   ; Tool $1A,$0D;                                      
FUNCTION ClearIncr  : Integer ; Tool $1A,$0A;                                   
FUNCTION GetLoc  : LocRec ; EXTERNAL ;                                          
FUNCTION GetTimer  : Integer ; Tool $1A,$0B;                                    
PROCEDURE SetIncr ( increment:Integer)  ; Tool $1A,$09;                         
PROCEDURE SetInstTable ( instTable:Handle)  ; Tool $1A,$12;                     
PROCEDURE SetTrkInfo ( priority:Integer; instIndex:Integer; trackNum:Integer)   
; Tool $1A,$0E;                                                                 
PROCEDURE StartInts   ; Tool $1A,$13;                                           
PROCEDURE StartSeq ( errHndlrRoutine:VoidProcPtr; compRoutine:VoidProcPtr;      
sequence:Handle)  ; Tool $1A,$0F;                                               
PROCEDURE StepSeq   ; Tool $1A,$10;                                             
PROCEDURE StopInts   ; Tool $1A,$14;                                            
PROCEDURE StopSeq ( next:Integer)  ; Tool $1A,$11;                              
PROCEDURE StartSeqRel ( errHandlerPtr:ProcPtr; compRoutine:ProcPtr;             
sequence:Handle)  ; Tool $1A,$15;                                               
IMPLEMENTATION                                                                  
END.                                                                            
