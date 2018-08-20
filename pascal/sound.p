{********************************************                                   
; File: Sound.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT SOUND;                                                                     
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
noDOCFndErr = $0810; {error - no DOC chip found }                               
docAddrRngErr = $0811; {error - DOC address range error }                       
noSAppInitErr = $0812; {error - no SAppInit call made }                         
invalGenNumErr = $0813; {error - invalid generator number }                     
synthModeErr = $0814; {error - synthesizer mode error }                         
genBusyErr = $0815; {error - generator busy error }                             
mstrIRQNotAssgnErr = $0817; {error - master IRQ not assigned }                  
sndAlreadyStrtErr = $0818; {error - sound tools already started }               
unclaimedSndIntErr = $08FF; {error - sound tools already started }              
   *** Toolset Errors *** *)                                                    
                                                                                
ffSynthMode = $0001; {channelGenMode - Free form synthesizer mode }             
noteSynthMode = $0002; {channelGenMode - Note synthesizer mode. }               
gen0off = $0001; {genMask - param to FFStopSound }                              
gen1off = $0002; {genMask - param to FFStopSound }                              
gen2off = $0004; {genMask - param to FFStopSound }                              
gen3off = $0008; {genMask - param to FFStopSound }                              
gen4off = $0010; {genMask - param to FFStopSound }                              
gen5off = $0020; {genMask - param to FFStopSound }                              
gen6off = $0040; {genMask - param to FFStopSound }                              
gen7off = $0080; {genMask - param to FFStopSound }                              
gen8off = $0100; {genMask - param to FFStopSound }                              
gen9off = $0200; {genMask - param to FFStopSound }                              
gen10off = $0400; {genMask - param to FFStopSound }                             
gen11off = $0800; {genMask - param to FFStopSound }                             
gen12off = $1000; {genMask - param to FFStopSound }                             
gen13off = $2000; {genMask - param to FFStopSound }                             
gen14off = $4000; {genMask - param to FFStopSound }                             
genAvail = $0000; {genStatus - Generator available status }                     
ffSynth = $0100; {genStatus - Free Form Synthesizer status }                    
noteSynth = $0200; {genStatus - Note Synthesizer status }                       
lastBlock = $8000; {genStatus - Last block of wave }                            
smReadRegister = $00; {Jump Table Offset - Read Register routine }              
smWriteRegister = $04; {Jump Table Offset - Write Register routine }            
smReadRam = $08; {Jump Table Offset - Read Ram routine }                        
smWriteRam = $0C; {Jump Table Offset - Write Ram routine }                      
smReadNext = $10; {Jump Table Offset - Read Next routine }                      
smWriteNext = $14; {Jump Table Offset - Write Next routine }                    
smOscTable = $18; {Jump Table Offset - Pointer to Oscillator table }            
smGenTable = $1C; {Jump Table Offset - Pointer to generator table }             
smGcbAddrTable = $20; {Jump Table Offset - Pointer to GCB address table }       
smDisableInc = $24; {Jump Table Offset - Disable Increment routine }            
                                                                                
TYPE                                                                            
SoundPBHndl = ^SoundPBPtr;                                                      
SoundPBPtr = ^SoundParamBlock;                                                  
SoundParamBlock = RECORD                                                        
    waveStart : Ptr; { starting address of wave }                               
    waveSize : Integer; { waveform size in pages }                              
    freqOffset : Integer; { ? formula to be provided }                          
    docBuffer : Integer; { DOC buffer start address, low byte = 0 }             
    bufferSize : Integer; { DOC buffer start address, low byte = 0 }            
    nextWavePtr : SoundPBPtr; { Pointer to start of next wave's parameter block 
}                                                                               
    volSetting : Integer; { DOC volume setting. High byte = 0 }                 
END;                                                                            
DocRegParamBlkPtr = ^DocRegParamBlk;                                            
DocRegParamBlk = PACKED RECORD                                                  
    oscGenType : Integer;                                                       
    freqLow1 : Byte;                                                            
    freqHigh1 : Byte;                                                           
    vol1 : Byte;                                                                
    tablePtr1 : Byte;                                                           
    control1 : Byte;                                                            
    tableSize1 : Byte;                                                          
    freqLow2 : Byte;                                                            
    freqHigh2 : Byte;                                                           
    vol2 : Byte;                                                                
    tablePtr2 : Byte;                                                           
    control2 : Byte;                                                            
    tableSize2 : Byte;                                                          
END;                                                                            
PROCEDURE SoundBootInit   ; Tool $08,$01;                                       
PROCEDURE SoundStartUp ( dPageAddr:Integer)  ; Tool $08,$02;                    
PROCEDURE SoundShutDown   ; Tool $08,$03;                                       
FUNCTION SoundVersion  : Integer ; Tool $08,$04;                                
PROCEDURE SoundReset   ; Tool $08,$05;                                          
FUNCTION SoundToolStatus  : Boolean ; Tool $08,$06;                             
FUNCTION FFGeneratorStatus ( genNumber:Integer) : Integer ; Tool $08,$11;       
FUNCTION FFSoundDoneStatus ( genNumber:Integer) : Boolean ; Tool $08,$14;       
FUNCTION FFSoundStatus  : Integer ; Tool $08,$10;                               
PROCEDURE FFStartSound ( genNumFFSynth:Integer; pBlockPtr:SoundPBPtr)  ; Tool   
$08,$0E;                                                                        
PROCEDURE FFStopSound ( genMask:Integer)  ; Tool $08,$0F;                       
FUNCTION GetSoundVolume ( genNumber:Integer) : Integer ; Tool $08,$0C;          
FUNCTION GetTableAddress  : Ptr ; Tool $08,$0B;                                 
PROCEDURE ReadRamBlock ( destPtr:Ptr; docStart:Integer; byteCount:Integer)  ;   
Tool $08,$0A;                                                                   
PROCEDURE SetSoundMIRQV ( sMasterIRQ:Longint)  ; Tool $08,$12;                  
PROCEDURE SetSoundVolume ( volume:Integer; genNumber:Integer)  ; Tool $08,$0D;  
FUNCTION SetUserSoundIRQV ( userIRQVector:Longint) : Ptr ; Tool $08,$13;        
PROCEDURE WriteRamBlock ( srcPtr:Ptr; docStart:Integer; byteCount:Integer)  ;   
Tool $08,$09;                                                                   
PROCEDURE FFSetUpSound ( channelGen:Integer; paramBlockPtr:SoundPBPtr)  ; Tool  
$08,$15;                                                                        
PROCEDURE FFStartPlaying ( genWord:Integer)  ; Tool $08,$16;                    
PROCEDURE SetDOCReg ( pBlockPtr:DocRegParamBlk)  ; Tool $08,$17;                
PROCEDURE ReadDOCReg (VAR pBlockPtr:DocRegParamBlk)  ; Tool $08,$18;            
IMPLEMENTATION                                                                  
END.                                                                            
