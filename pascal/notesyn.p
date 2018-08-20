{********************************************                                   
; File: NoteSyn.p                                                               
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT NOTESYN;                                                                   
INTERFACE                                                                       
USES TYPES;                                                                     
                                                                                
(* *** Toolset Errors ***                                                       
CONST                                                                           
nsAlreadyInit = $1901; {error - Note Syn already initialized }                  
nsSndNotInit = $1902; {error - Sound Tools not initialized }                    
nsNotAvail = $1921; {error - generator not available }                          
nsBadGenNum = $1922; {error - bad generator number }                            
nsNotInit = $1923; {error - Note Syn not initialized }                          
nsGenAlreadyOn = $1924; {error - generator already on }                         
soundWrongVer = $1925; {error - incompatible versions of Sound  and NoteSyn }   
   *** Toolset Errors *** *)                                                    
                                                                                
TYPE                                                                            
EnvelopeHndl = ^EnvelopePtr;                                                    
EnvelopePtr = ^Envelope;                                                        
Envelope = PACKED RECORD                                                        
    st1BkPt : Byte;                                                             
    st1Increment : Integer;                                                     
    st2BkPt : Byte;                                                             
    st2Increment : Integer;                                                     
    st3BkPt : Byte;                                                             
    st3Increment : Integer;                                                     
    st4BkPt : Byte;                                                             
    st4Increment : Integer;                                                     
    st5BkPt : Byte;                                                             
    st5Increment : Integer;                                                     
    st6BkPt : Byte;                                                             
    st6Increment : Integer;                                                     
    st7BkPt : Byte;                                                             
    st7Increment : Integer;                                                     
    st8BkPt : Byte;                                                             
    st8Increment : Integer;                                                     
END;                                                                            
WaveFormHndl = ^WaveFormPtr;                                                    
WaveFormPtr = ^WaveForm;                                                        
WaveForm = PACKED RECORD                                                        
    wfTopKey : Byte;                                                            
    wfWaveAddress : Byte;                                                       
    wfWaveSize : Byte;                                                          
    wfDocMode : Byte;                                                           
    wfRelPitch : Integer;                                                       
END;                                                                            
InstrumentHndl = ^InstrumentPtr;                                                
InstrumentPtr = ^Instrument;                                                    
Instrument = PACKED RECORD                                                      
    theEnvelope : Envelope;                                                     
    releaseSegment : Byte;                                                      
    priorityIncrement : Byte;                                                   
    pitchBendRange : Byte;                                                      
    vibratoDepth : Byte;                                                        
    vibratoSpeed : Byte;                                                        
    inSpare : Byte;                                                             
    aWaveCount : Byte;                                                          
    bWaveCount : Byte;                                                          
    aWaveList : ARRAY[1..1] OF WaveForm;                                        
    bWaveList : ARRAY[1..1] OF WaveForm;                                        
END;                                                                            
PROCEDURE NSBootInit   ; Tool $19,$01;                                          
PROCEDURE NSStartUp ( updateRate:Integer; userUpdateRtnPtr:Ptr)  ; Tool         
$19,$02;                                                                        
PROCEDURE NSShutDown   ; Tool $19,$03;                                          
FUNCTION NSVersion  : Integer ; Tool $19,$04;                                   
PROCEDURE NSReset   ; Tool $19,$05;                                             
FUNCTION NSStatus  : Boolean ; Tool $19,$06;                                    
PROCEDURE AllNotesOff   ; Tool $19,$0D;                                         
FUNCTION AllocGen ( requestPriority:Integer) : Integer ; Tool $19,$09;          
PROCEDURE DeallocGen ( genNumber:Integer)  ; Tool $19,$0A;                      
PROCEDURE NoteOff ( genNumber:Integer; semitone:Integer)  ; Tool $19,$0C;       
PROCEDURE NoteOn ( genNumber:Integer; semitone:Integer; volume:Integer;         
instrumentPtr:Ptr)  ; Tool $19,$0B;                                             
PROCEDURE NSSetUpdateRate ( updateRate:Integer)  ; Tool $19,$0E;                
FUNCTION NSSetUserUpdateRtn ( updateRtn:VoidProcPtr) : VoidProcPtr ; Tool       
$19,$0F;                                                                        
IMPLEMENTATION                                                                  
END.                                                                            
