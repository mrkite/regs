{********************************************                                   
; File: Locator.p                                                               
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT LOCATOR;                                                                   
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
toolNotFoundErr = $0001; {error -  }                                            
funcNotFoundErr = $0002; {error -  }                                            
toolVersionErr = $0110; {error -  }                                             
sysStrtMtErr = $0100; {error - can't mount system startup volume }              
messNotFoundErr = $0111; {error -  }                                            
   *** Toolset Errors *** *)                                                    
                                                                                
fileInfoType = $0001; {MessageCenter - Message type parameter }                 
addMessage = $0001; {MessageCenter - action parameter }                         
getMessage = $0002; {MessageCenter - action parameter }                         
deleteMessage = $0003; {MessageCenter - action parameter }                      
mvReturn = $0001; {TLMountVolume - like ok for dialogs }                        
mvEscape = $0002; {TLMountVolume - like cancel for dialogs }                    
sysTool = $0000; {Tool Set Spec -  }                                            
userTool = $8000; {Tool Set Spec -  }                                           
                                                                                
TYPE                                                                            
MessageRecHndl = ^MessageRecPtr;                                                
MessageRecPtr = ^MessageRec;                                                    
MessageRec = RECORD                                                             
    messageNext : MessageRecHndl;                                               
    messageType : Integer;                                                      
    messageData : Integer;                                                      
    fileNames : PACKED ARRAY[1..1] OF Str255;                                   
END;                                                                            
ToolSpec = RECORD                                                               
    toolNumber : Integer;                                                       
    minVersion : Integer;                                                       
END;                                                                            
StartStopRecordPtr = ^StartStopRecord;                                          
StartStopRecord = RECORD                                                        
    flags : Integer;                                                            
    videoMode : Integer;                                                        
    resFileID : Integer;                                                        
    dPageHandle : Handle;                                                       
    numTools : Integer;                                                         
END;                                                                            
PROCEDURE TLBootInit   ; Tool $01,$01;                                          
PROCEDURE TLStartUp   ; Tool $01,$02;                                           
PROCEDURE TLShutDown   ; Tool $01,$03;                                          
FUNCTION TLVersion  : Integer ; Tool $01,$04;                                   
PROCEDURE TLReset   ; Tool $01,$05;                                             
FUNCTION TLStatus  : Boolean ; Tool $01,$06;                                    
FUNCTION GetFuncPtr ( userOrSystem:Integer; funcTSNum:Integer) : Ptr ; Tool     
$01,$0B;                                                                        
FUNCTION GetTSPtr ( userOrSystem:Integer; tSNum:Integer) : Ptr ; Tool $01,$09;  
FUNCTION GetWAP ( userOrSystem:Integer; tSNum:Integer) : Ptr ; Tool $01,$0C;    
PROCEDURE LoadOneTool ( toolNumber:Integer; minVersion:Integer)  ; Tool         
$01,$0F;                                                                        
PROCEDURE LoadTools ( toolTablePtr:Ptr)  ; Tool $01,$0E;                        
PROCEDURE MessageCenter ( action:Integer; messagetype:Integer;                  
messageHandle:MessageRecHndl)  ; Tool $01,$15;                                  
PROCEDURE RestoreTextState ( stateHandle:Handle)  ; Tool $01,$14;               
FUNCTION SaveTextState  : Handle ; Tool $01,$13;                                
PROCEDURE SetDefaultTPT   ; Tool $01,$16;                                       
PROCEDURE SetTSPtr ( userOrSystem:Integer; tsNum:Integer; fptablePtr:FPTPtr)  ; 
Tool $01,$0A;                                                                   
PROCEDURE SetWAP ( userOrSystem:Integer; tSNum:Integer; waptPtr:Ptr)  ; Tool    
$01,$0D;                                                                        
FUNCTION TLMountVolume ( whereX:Integer; whereY:Integer; line1:Str255;          
line2:Str255; but1:Str255; but2:Str255) : Integer ; Tool $01,$11;               
FUNCTION TLTextMountVolume ( line1:Str255; line2:Str255; but1:Str255;           
but2:Str255) : Integer ; Tool $01,$12;                                          
PROCEDURE UnloadOneTool ( toolNumber:Integer)  ; Tool $01,$10;                  
FUNCTION StartUpTools ( userID:Integer; startStopRefDesc:RefDescriptor;         
startStopRef:Ref) : Ref ; Tool $01,$18;                                         
PROCEDURE ShutDownTools ( startStopDesc:RefDescriptor; startStopRef:Ref)  ;     
Tool $01,$19;                                                                   
FUNCTION MessageByName ( createItFlag:Boolean; recordPtr:Ptr) : Longint ; Tool  
$01,$17;                                                                        
IMPLEMENTATION                                                                  
END.                                                                            
