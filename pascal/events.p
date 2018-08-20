{********************************************                                   
; File: Events.p                                                                
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT EVENTS;                                                                    
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
emDupStrtUpErr = $0601; {error - duplicate EMStartup Call }                     
emResetErr = $0602; {error - can't reset error the Event Manager }              
emNotActErr = $0603; {error - event manager not active }                        
emBadEvtCodeErr = $0604; {error - illegal event code }                          
emBadBttnNoErr = $0605; {error - illegal button number }                        
emQSiz2LrgErr = $0606; {error - queue size too large }                          
emNoMemQueueErr = $0607; {error - not enough memory for queue }                 
emBadEvtQErr = $0681; {error - fatal sys error - event queue damaged }          
emBadQHndlErr = $0682; {error - fatal sys error - queue handle damaged }        
   *** Toolset Errors *** *)                                                    
                                                                                
nullEvt = $0000; {Event Code -  }                                               
mouseDownEvt = $0001; {Event Code -  }                                          
mouseUpEvt = $0002; {Event Code -  }                                            
keyDownEvt = $0003; {Event Code -  }                                            
autoKeyEvt = $0005; {Event Code -  }                                            
updateEvt = $0006; {Event Code -  }                                             
activateEvt = $0008; {Event Code -  }                                           
switchEvt = $0009; {Event Code -  }                                             
deskAccEvt = $000A; {Event Code -  }                                            
driverEvt = $000B; {Event Code -  }                                             
app1Evt = $000C; {Event Code -  }                                               
app2Evt = $000D; {Event Code -  }                                               
app3Evt = $000E; {Event Code -  }                                               
app4Evt = $000F; {Event Code -  }                                               
mDownMask = $0002; {Event Masks -  }                                            
mUpMask = $0004; {Event Masks -  }                                              
keyDownMask = $0008; {Event Masks -  }                                          
autoKeyMask = $0020; {Event Masks -  }                                          
updateMask = $0040; {Event Masks -  }                                           
activeMask = $0100; {Event Masks -  }                                           
switchMask = $0200; {Event Masks -  }                                           
deskAccMask = $0400; {Event Masks -  }                                          
driverMask = $0800; {Event Masks -  }                                           
app1Mask = $1000; {Event Masks -  }                                             
app2Mask = $2000; {Event Masks -  }                                             
app3Mask = $4000; {Event Masks -  }                                             
app4Mask = $8000; {Event Masks -  }                                             
everyEvent = $FFFF; {Event Masks -  }                                           
jcTickCount = $00; {Journal Code - TickCount call }                             
jcGetMouse = $01; {Journal Code - GetMouse call }                               
jcButton = $02; {Journal Code - Button call }                                   
jcEvent = $04; {Journal Code - GetNextEvent and EventAvail calls }              
activeFlag = $0001; {Modifier Flags - set if window being activated }           
changeFlag = $0002; {Modifier Flags - set if active wind. changed state }       
btn1State = $0040; {Modifier Flags - set if button 1 up }                       
btn0State = $0080; {Modifier Flags - set if button 0 up }                       
appleKey = $0100; {Modifier Flags - set if Apple key down }                     
shiftKey = $0200; {Modifier Flags - set if shift key down }                     
capsLock = $0400; {Modifier Flags - set if caps lock key down }                 
optionKey = $0800; {Modifier Flags - set if option key down }                   
controlKey = $1000; {Modifier Flags - set if Control key down }                 
keyPad = $2000; {Modifier Flags - set if keypress from key pad }                
                                                                                
TYPE                                                                            
EventRecordHndl = ^EventRecordPtr;                                              
EventRecordPtr = ^EventRecord;                                                  
EventRecord = RECORD CASE INTEGER OF                                            
    0: (                                                                        
        what : Integer; { event code }                                          
        message : Longint; { event message }                                    
        when : Longint; { ticks since startup }                                 
        where : Point; { mouse location }                                       
        modifiers : Integer; { modifier flags }                                 
       );                                                                       
    1:  (                                                                       
         wmWhat : Integer;                                                      
         wmMessage : Longint;                                                   
         wmWhen : Longint;                                                      
         wmWhere : Point;                                                       
         wmModifiers : Integer;                                                 
         wmTaskData : Longint; { TaskMaster return value. }                     
         wmTaskMask : Longint; { TaskMaster feature mask. }                     
         wmLastClickTick : Longint;                                             
         wmClickCount : Integer;                                                
         wmTaskData2 : Longint;                                                 
         wmTaskData3 : Longint;                                                 
         wmTaskData4 : Longint;                                                 
         wmLastClickPt : Point;                                                 
       );                                                                       
END;                                                                            
PROCEDURE EMBootInit   ; Tool $06,$01;                                          
PROCEDURE EMStartUp ( dPageAddr:Integer; queueSize:Integer; xMinClamp:Integer;  
xMaxClamp:Integer; yMinClamp:Integer; yMaxClamp:Integer; userID:Integer)  ;     
Tool $06,$02;                                                                   
PROCEDURE EMShutDown   ; Tool $06,$03;                                          
FUNCTION EMVersion  : Integer ; Tool $06,$04;                                   
PROCEDURE EMReset   ; Tool $06,$05;                                             
FUNCTION EMStatus  : Boolean ; Tool $06,$06;                                    
FUNCTION Button ( buttonNum:Integer) : Boolean ; Tool $06,$0D;                  
FUNCTION DoWindows  : Integer ; Tool $06,$09;                                   
FUNCTION EventAvail ( eventMask:Integer;VAR eventPtr:EventRecord) : Boolean ;   
Tool $06,$0B;                                                                   
PROCEDURE FakeMouse ( changedFlag:Integer; modLatch:Integer; xPos:Integer;      
yPos:Integer; ButtonStatus:Integer)  ; Tool $06,$19;                            
FUNCTION FlushEvents ( eventMask:Integer; stopMask:Integer) : Integer ; Tool    
$06,$15;                                                                        
FUNCTION GetCaretTime  : Longint ; Tool $06,$12;                                
FUNCTION GetDblTime  : Longint ; Tool $06,$11;                                  
PROCEDURE GetMouse (VAR mouseLocPtr:Point)  ; Tool $06,$0C;                     
FUNCTION GetNextEvent ( eventMask:Integer;VAR eventPtr:EventRecord) : Boolean ; 
Tool $06,$0A;                                                                   
FUNCTION GetOSEvent ( eventMask:Integer;VAR eventPtr:EventRecord) : Boolean ;   
Tool $06,$16;                                                                   
FUNCTION OSEventAvail ( eventMask:Integer;VAR eventPtr:EventRecord) : Boolean ; 
Tool $06,$17;                                                                   
FUNCTION PostEvent ( eventCode:Integer; eventMsg:Longint) : Integer ; Tool      
$06,$14;                                                                        
PROCEDURE SetEventMask ( sysEventMask:Integer)  ; Tool $06,$18;                 
PROCEDURE SetSwitch   ; Tool $06,$13;                                           
FUNCTION StillDown ( buttonNum:Integer) : Boolean ; Tool $06,$0E;               
FUNCTION WaitMouseUp ( buttonNum:Integer) : Boolean ; Tool $06,$0F;             
FUNCTION TickCount  : Longint ; Tool $06,$10;                                   
FUNCTION GetKeyTranslation  : Integer ; Tool $06,$1B;                           
PROCEDURE SetKeyTranslation ( kTransID:Integer)  ; Tool $06,$1C;                
PROCEDURE SetAutoKeyLimit ( newLimit:Integer)  ; Tool $06,$1A;                  
IMPLEMENTATION                                                                  
END.                                                                            
