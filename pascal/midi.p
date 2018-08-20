{********************************************                                   
; File: MIDI.p                                                                  
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT MIDI;                                                                      
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
miToolNum = $0020; {Midi - the tool number of the MIDI Tool Set }               
miDrvrFileType = $00BB; {Midi - filetype of MIDI device driver }                
miNSVer = $0102; {Midi - minimum version of Note Synthesizer required by MIDI   
Tool Set }                                                                      
miSTVer = $0203; {Midi - minimum version of Sound Tools needed by MIDI Tool Set 
}                                                                               
miDrvrAuxType = $0300; {Midi - aux type of MIDI device driver }                 
                                                                                
(* *** Toolset Errors ***                                                       
miStartUpErr = $2000; {Midi - MIDI Tool Set is not started  }                   
miPacketErr = $2001; {Midi - incorrect length for a received MIDI command }     
miArrayErr = $2002; {Midi - a designated array had an insufficient or illegal   
size }                                                                          
miFullBufErr = $2003; {Midi - input buffer overflow }                           
miToolsErr = $2004; {Midi - the required tools were not started up or had       
insufficient versions }                                                         
miOutOffErr = $2005; {Midi - MIDI output must first be enabled }                
miNoBufErr = $2007; {Midi - no buffer is currently allocated }                  
miDriverErr = $2008; {Midi - the designated file is not a legal MIDI device     
driver }                                                                        
miBadFreqErr = $2009; {Midi - the MIDI clock cannot attain the requested        
frequency }                                                                     
miClockErr = $200A; {Midi - the MIDI clock value wrapped to zero }              
miConflictErr = $200B; {Midi - conflicting processes for MIDI input }           
miNoDevErr = $200C; {Midi - no MIDI device driver loaded }                      
miDevNotAvail = $2080; {Midi - the requested device is not available }          
miDevSlotBusy = $2081; {Midi - requested slot is already in use }               
miDevBusy = $2082; {Midi - the requested device is already in use }             
miDevOverrun = $2083; {Midi - device overrun by incoming MIDI data }            
miDevNoConnect = $2084; {Midi - no connection to MIDI }                         
miDevReadErr = $2085; {Midi - framing error in received MIDI data }             
miDevVersion = $2086; {Midi - ROM version is incompatible with device driver }  
miDevIntHndlr = $2087; {Midi - conflicting interrupt handler is installed }     
   *** Toolset Errors *** *)                                                    
                                                                                
miSetClock = $0000; {MidiClock - set time stamp clock }                         
miStartClock = $0001; {MidiClock - start time stamp clock }                     
miStopClock = $0002; {MidiClock - stop time stamp clock }                       
miSetFreq = $0003; {MidiClock - set clock frequency }                           
miRawMode = $00000000; {MidiControl - raw mode for MIDI input and output }      
miSetRTVec = $0000; {MidiControl - set real-time message vector }               
miPacketMode = $00000001; {MidiControl - packet mode for MIDI input and output  
}                                                                               
miSetErrVec = $0001; {MidiControl - set real-time error vector }                
miStandardMode = $00000002; {MidiControl - standard mode for MIDI input and     
output }                                                                        
miSetInBuf = $0002; {MidiControl - set input buffer information }               
miSetOutBuf = $0003; {MidiControl - set output buffer information }             
miStartInput = $0004; {MidiControl - start MIDI input }                         
miStartOutput = $0005; {MidiControl - start MIDI output }                       
miStopInput = $0006; {MidiControl - stop MIDI input }                           
miStopOutput = $0007; {MidiControl - stop MIDI output }                         
miFlushInput = $0008; {MidiControl - discard contents of input buffer }         
miFlushOutput = $0009; {MidiControl - discard contents of output buffer }       
miFlushPacket = $000A; {MidiControl - discard next input packet }               
miWaitOutput = $000B; {MidiControl - wait for output buffer to empty }          
miSetInMode = $000C; {MidiControl - set input mode }                            
miSetOutMode = $000D; {MidiControl - set output mode }                          
miClrNotePad = $000E; {MidiControl - clear all notes marked on in the note pad  
}                                                                               
miSetDelay = $000F; {MidiControl - set minimum delay between output packets }   
miOutputStat = $0010; {MidiControl - enable/disable output of running-status }  
miIgnoreSysEx = $0011; {MidiControl - ignore system exclusive input }           
miSelectDrvr = $0000; {MidiDevice - display device driver selection dialog }    
miLoadDrvr = $0001; {MidiDevice - load and initialize device driver }           
miUnloadDrvr = $0002; {MidiDevice - shutdown MIDI device, unload driver }       
miNextPktLen = $0; {MidiInfo - return length of next packet }                   
miInputChars = $0001; {MidiInfo - return number of characters in input buffer } 
miOutputChars = $0002; {MidiInfo - return number of characters in output buffer 
}                                                                               
miMaxInChars = $0003; {MidiInfo - return maximum number of characters in input  
buffer }                                                                        
miMaxOutChars = $0004; {MidiInfo - return maximum number of characters in       
output buffer }                                                                 
miRecordAddr = $0005; {MidiInfo - return current MidiRecordSeq address }        
miPlayAddr = $0006; {MidiInfo - return current MidiPlaySeq address }            
miClockValue = $0007; {MidiInfo - return current time stamp clock value }       
miClockFreq = $0008; {MidiInfo - return number of clock ticks per second }      
                                                                                
TYPE                                                                            
MiBufInfo = RECORD                                                              
    bufSize : Integer; { size of buffer (0 for default) }                       
    address : Ptr; { address of buffer (0 for auto-allocation) }                
END;                                                                            
MiDriverInfo = RECORD                                                           
    slot : Integer; { device slot }                                             
    external : Integer; { slot internal (=0) / external (=1) }                  
    pathname : PACKED ARRAY[1..65] OF Byte; { device driver pathname }          
END;                                                                            
PROCEDURE MidiBootInit   ; Tool $20,$01;                                        
PROCEDURE MidiStartUp ( userID:Integer; directPages:Integer)  ; Tool $20,$02;   
PROCEDURE MidiShutDown   ; Tool $20,$03;                                        
FUNCTION MidiVersion  : Integer ; Tool $20,$04;                                 
PROCEDURE MidiReset   ; Tool $20,$05;                                           
FUNCTION MidiStatus  : Boolean ; Tool $20,$06;                                  
PROCEDURE MidiClock ( funcNum:Integer; arg:Longint)  ; Tool $20,$0B;            
PROCEDURE MidiControl ( controlCode:Integer)  ; Tool $20,$09;                   
PROCEDURE MidiDevice ( funcNum:Integer; driverInfo:Ptr)  ; Tool $20,$0A;        
FUNCTION MidiInfo ( funcNum:Integer) : Longint ; Tool $20,$0C;                  
PROCEDURE MidiInputPoll   ; EXTERNAL ;                                          
FUNCTION MidiReadPacket ( arrayAddr:Ptr; arraySize:Integer) : Integer ; Tool    
$20,$0D;                                                                        
FUNCTION MidiWritePacket ( arrayAddr:Ptr) : Integer ; Tool $20,$0E;             
IMPLEMENTATION                                                                  
END.                                                                            
