{********************************************                                   
; File: ADB.p                                                                   
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT ADB;                                                                       
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
cmndIncomplete = $0910; {error - Command not completed. }                       
cantSync = $0911; {error - Can't synchronize }                                  
adbBusy = $0982; {error - Busy  (command pending) }                             
devNotAtAddr = $0983; {error - Device not present at address }                  
srqListFull = $0984; {error - List full }                                       
   *** Toolset Errors *** *)                                                    
                                                                                
readModes = $000A; {ReadKeyMicroData -  }                                       
readConfig = $000B; {ReadKeyMicroData -  }                                      
readADBError = $000C; {ReadKeyMicroData -  }                                    
readVersionNum = $000D; {ReadKeyMicroData -  }                                  
readAvailCharSet = $000E; {ReadKeyMicroData -  }                                
readAvailLayout = $000F; {ReadKeyMicroData -  }                                 
readMicroMem = $0009; {ReadKeyMicroMem -  }                                     
abort = $0001; {SendInfo - command }                                            
resetKbd = $0002; {SendInfo - command }                                         
flushKbd = $0003; {SendInfo - command }                                         
setModes = $0004; {SendInfo - 2nd param is pointer to mode byte }               
clearModes = $0005; {SendInfo - 2nd param is pointer to mode Byte }             
setConfig = $0006; {SendInfo - 2nd param is pointer to SetConfigRec }           
synch = $0007; {SendInfo - 2nd param is pointer to SynchRec }                   
writeMicroMem = $0008; {SendInfo - 2nd param is pointer to MicroControlMemRec } 
resetSys = $0010; {SendInfo - command }                                         
keyCode = $0011; {SendInfo - 2nd param is pointer to key code byte. }           
resetADB = $0040; {SendInfo - command }                                         
transmitADBBytes = $0047; {SendInfo - add number of bytes to this  }            
enableSRQ = $0050; {SendInfo - command - ADB address in low nibble }            
flushADBDevBuf = $0060; {SendInfo - command - ADB address in low nibble }       
disableSRQ = $0070; {SendInfo - command - ADB address in low nibble }           
transmit2ADBBytes = $0080; {SendInfo - add ADB address to this }                
listen = $0080; {SendInfo - adbCommand = listen + ( 16 * reg) + (adb address) } 
talk = $00C0; {SendInfo - adbCommand = talk + ( 16 * reg) + (adb address) }     
                                                                                
TYPE                                                                            
ReadConfigRecPtr = ^ReadConfigRec;                                              
ReadConfigRec = PACKED RECORD                                                   
    rcRepeatDelay : Byte; { Output Byte: Repeat / Delay }                       
    rcLayoutOrLang : Byte; { Output Byte: Layout / Language }                   
    rcADBAddr : Byte; { Output Byte: ADB address - keyboard and mouse }         
END;                                                                            
SetConfigRecPtr = ^SetConfigRec;                                                
SetConfigRec = PACKED RECORD                                                    
    scADBAddr : Byte; { keyboard and mouse }                                    
    scLayoutOrLang : Byte;                                                      
    scRepeatDelay : Byte;                                                       
END;                                                                            
SynchRecPtr = ^SynchRec;                                                        
SynchRec = PACKED RECORD                                                        
    synchMode : Byte;                                                           
    synchKybdMouseAddr : Byte;                                                  
    synchLayoutOrLang : Byte;                                                   
    synchRepeatDelay : Byte;                                                    
END;                                                                            
ScaleRecPtr = ^ScaleRec;                                                        
ScaleRec = RECORD                                                               
    xDivide : Integer;                                                          
    yDivide : Integer;                                                          
    xOffset : Integer;                                                          
    yOffset : Integer;                                                          
    xMultiply : Integer;                                                        
    yMultiply : Integer;                                                        
END;                                                                            
PROCEDURE ADBBootInit   ; Tool $09,$01;                                         
PROCEDURE ADBStartUp   ; Tool $09,$02;                                          
PROCEDURE ADBShutDown   ; Tool $09,$03;                                         
FUNCTION ADBVersion  : Integer ; Tool $09,$04;                                  
PROCEDURE ADBReset   ; Tool $09,$05;                                            
FUNCTION ADBStatus  : Boolean ; Tool $09,$06;                                   
PROCEDURE AbsOff   ; Tool $09,$10;                                              
PROCEDURE AbsOn   ; Tool $09,$0F;                                               
PROCEDURE AsyncADBReceive ( compPtr:Ptr)  ; Tool $09,$0D;                       
PROCEDURE ClearSRQTable   ; Tool $09,$16;                                       
PROCEDURE GetAbsScale (VAR dataInPtr:ScaleRec)  ; Tool $09,$13;                 
FUNCTION ReadAbs  : Integer ; Tool $09,$11;                                     
PROCEDURE ReadKeyMicroData ( dataLength:Integer; dataPtr:Ptr;                   
adbCommand:Integer)  ; Tool $09,$0A;                                            
PROCEDURE ReadKeyMicroMem ( dataLength:Integer; dataPtr:Ptr;                    
adbCommand:Integer)  ; Tool $09,$0B;                                            
PROCEDURE SendInfo ( dataLength:Integer; dataPtr:Ptr; adbCommand:Integer)  ;    
Tool $09,$09;                                                                   
PROCEDURE SetAbsScale ( dataOutPtr:ScaleRec)  ; Tool $09,$12;                   
PROCEDURE SRQPoll ( compPtr:Ptr; adbRegAddr:Integer)  ; Tool $09,$14;           
PROCEDURE SRQRemove ( adbRegAddr:Integer)  ; Tool $09,$15;                      
PROCEDURE SyncADBReceive ( inputWord:Integer; compPtr:Ptr; adbCommand:Integer)  
; Tool $09,$0E;                                                                 
IMPLEMENTATION                                                                  
END.                                                                            
