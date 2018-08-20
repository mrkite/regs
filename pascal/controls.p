{********************************************                                   
; File: Controls.p                                                              
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT CONTROLS;                                                                  
INTERFACE                                                                       
USES TYPES,QUICKDRAW,EVENTS;                                                    
CONST                                                                           
                                                                                
wmNotStartedUp = $1001; {error - Window manager was not started first. }        
noConstraint = $0000; {Axis Parameter - No constraint on movement. }            
hAxisOnly = $0001; {Axis Parameter - Horizontal axis only. }                    
vAxisOnly = $0002; {Axis Parameter - Vertical axis only. }                      
simpRound = $0000; {CtlFlag - Simple button flag }                              
upFlag = $0001; {CtlFlag - Scroll bar flag.  }                                  
boldButton = $0001; {CtlFlag - Bold round cornered outlined button. }           
simpBRound = $0001; {CtlFlag - Simple button flag }                             
downFlag = $0002; {CtlFlag - Scroll bar flag. }                                 
simpSquare = $0002; {CtlFlag - Simple button flag }                             
simpDropSquare = $0003; {CtlFlag - Simple button flag }                         
leftFlag = $0004; {CtlFlag - Scroll bar flag. }                                 
rightFlag = $0008; {CtlFlag - Scroll bar flag. }                                
dirScroll = $0010; {CtlFlag - Scroll bar flag. }                                
horScroll = $0010; {CtlFlag - Scroll bar flag. }                                
family = $007F; {CtlFlag - Mask for radio button family number }                
ctlInVis = $0080; {CtlFlag - invisible mask for any type of control  }          
inListBox = $88; {CtlFlag -  }                                                  
simpleProc = $00000000; {CtlProc -  }                                           
checkProc = $02000000; {CtlProc -  }                                            
radioProc = $04000000; {CtlProc -  }                                            
scrollProc = $06000000; {CtlProc -  }                                           
growProc = $08000000; {CtlProc -  }                                             
drawCtl = $0000; {DefProc - Draw control command. }                             
calcCRect = $0001; {DefProc - Compute drag RECT command. }                      
testCtl = $0002; {DefProc - Hit test command. }                                 
initCtl = $0003; {DefProc - Initialize command. }                               
dispCtl = $0004; {DefProc - Dispose command. }                                  
posCtl = $0005; {DefProc - Move indicator command. }                            
thumbCtl = $0006; {DefProc - Compute drag parameters command. }                 
dragCtl = $0007; {DefProc - Drag command. }                                     
autoTrack = $0008; {DefProc - Action command. }                                 
newValue = $0009; {DefProc - Set new value command. }                           
setParams = $000A; {DefProc - Set new parameters command. }                     
moveCtl = $000B; {DefProc - Move command. }                                     
recSize = $000C; {DefProc - Return record size command. }                       
noHilite = $0000; {hiliteState - Param to HiliteControl }                       
inactiveHilite = $00FF; {hiliteState - Param to HiliteControl }                 
noPart = $0000; {PartCode -  }                                                  
simpleButton = $0002; {PartCode -  }                                            
checkBox = $0003; {PartCode -  }                                                
radioButton = $0004; {PartCode -  }                                             
upArrow = $0005; {PartCode -  }                                                 
downArrow = $0006; {PartCode -  }                                               
pageUp = $0007; {PartCode -  }                                                  
pageDown = $0008; {PartCode -  }                                                
growBox = $000A; {PartCode -  }                                                 
thumb = $0081; {PartCode -  }                                                   
fCtlTarget = $8000; {CtlRec.ctlMoreFlags - is current target of typing commands 
}                                                                               
fCtlCanBeTarget = $4000; {CtlRec.ctlMoreFlags - can be made the target control  
}                                                                               
fCtlWantEvents = $2000; {CtlRec.ctlMoreFlags - control can be called view       
SendEventToCtl }                                                                
fCtlProcRefNotPtr = $1000; {CtlRec.ctlMoreFlags - set = ID of defproc, clear =  
pointer to defproc }                                                            
fCtlTellAboutSize = $0800; {CtlRec.ctlMoreFlags - set if ctl needs notification 
when size of owning window changes }                                            
fCtlIsMultiPar = $0400; {CtlRec.ctlMoreFlags - set if ctl needs notification to 
be hidden }                                                                     
titleIsPtr = $00; {Ctl Verb -  }                                                
titleIsHandle = $01; {Ctl Verb -  }                                             
titleIsResource = $02; {Ctl Verb -  }                                           
colorTableIsPtr = $00; {Ctl Verb -  }                                           
colorTableIsHandle = $04; {Ctl Verb -  }                                        
colorTableIsResource = $08; {Ctl Verb -  }                                      
ctlHandleEvent = $0D; {DefProc message -  }                                     
ctlChangeTarget = $0E; {DefProc message -  }                                    
ctlChangeBounds = $0F; {DefProc message -  }                                    
ctlWindChangeSize = $10; {DefProc message -  }                                  
ctlHandleTab = $11; {DefProc message -  }                                       
ctlHideCtl = $12; {DefProc message -  }                                         
singlePtr = $0000; {InputVerb -  }                                              
singleHandle = $0001; {InputVerb -  }                                           
singleResource = $0002; {InputVerb -  }                                         
ptrToPtr = $0003; {InputVerb -  }                                               
ptrToHandle = $0004; {InputVerb -  }                                            
ptrToResource = $0005; {InputVerb -  }                                          
handleToPtr = $0006; {InputVerb -  }                                            
handleToHandle = $0007; {InputVerb -  }                                         
handleToResource = $0008; {InputVerb -  }                                       
resourceToResource = $0009; {InputVerb -  }                                     
simpleButtonControl = $80000000; {ProcRefs -  }                                 
checkControl = $82000000; {ProcRefs -  }                                        
radioControl = $84000000; {ProcRefs -  }                                        
scrollBarControl = $86000000; {ProcRefs -  }                                    
growControl = $88000000; {ProcRefs -  }                                         
statTextControl = $81000000; {ProcRefs -  }                                     
editLineControl = $83000000; {ProcRefs -  }                                     
editTextControl = $85000000; {ProcRefs -  }                                     
popUpControl = $87000000; {ProcRefs -  }                                        
listControl = $89000000; {ProcRefs -  }                                         
iconButtonControl = $07FF0001; {ProcRefs -  }                                   
pictureControl = $8D000000; {ProcRefs -  }                                      
                                                                                
(* *** Toolset Errors ***                                                       
noCtlError = $1004; {Error - no controls in window }                            
noSuperCtlError = $1005; {Error - no super controls in window }                 
noCtlTargetError = $1006; {Error - no target super control }                    
notSuperCtlError = $1007; {Error - action can only be done on super control }   
canNotBeTargetError = $1008; {Error - conrol cannot be made target }            
noSuchIDError = $1009; {Error - specified ID cannot be found }                  
tooFewParmsError = $100A; {Error - not enough params specified }                
noCtlToBeTargetError = $100B; {Error - NextCtl call, no ctl could be target }   
noWind_Err = $100C; {Error - there is no front window }                         
   *** Toolset Errors *** *)                                                    
                                                                                
TYPE                                                                            
WindowPtr = GrafPortPtr ;                                                       
                                                                                
                                                                                
BarColorsHndl = ^BarColorsPtr;                                                  
BarColorsPtr = ^BarColors;                                                      
BarColors = RECORD                                                              
    barOutline : Integer; { color for outlining bar, arrows, and thumb }        
    barNorArrow : Integer; { color of arrows when not highlighted }             
    barSelArrow : Integer; { color of arrows when highlighted }                 
    barArrowBack : Integer; { color of arrow box's background }                 
    barNorThumb : Integer; { color of thumb's background when not highlighted } 
    barSelThumb : Integer; { color of thumb's background when highlighted }     
    barPageRgn : Integer; { color and pattern page region: high byte - 1=       
dither, 0 = solid }                                                             
    barInactive : Integer; { color of scroll bar's interior when inactive }     
END;                                                                            
BoxColorsHndl = ^BoxColorsPtr;                                                  
BoxColorsPtr = ^BoxColors;                                                      
BoxColors = RECORD                                                              
    boxReserved : Integer; { reserved }                                         
    boxNor : Integer; { color of box when not checked }                         
    boxSel : Integer; { color of box when checked }                             
    boxTitle : Integer; { color of check box's title }                          
END;                                                                            
BttnColorsHndl = ^BttnColorsPtr;                                                
BttnColorsPtr = ^BttnColors;                                                    
BttnColors = RECORD                                                             
    bttnOutline : Integer; { color of outline }                                 
    bttnNorBack : Integer; { color of background when not selected }            
    bttnSelBack : Integer; { color of background when selected }                
    bttnNorText : Integer; { color of title's text when not selected }          
    bttnSelText : Integer; { color of title's text when selected }              
END;                                                                            
CtlRecHndlPtr = ^CtlRecHndl;                                                    
CtlRecHndl = ^CtlRecPtr;                                                        
CtlRecPtr = ^CtlRec;                                                            
CtlRec = PACKED RECORD                                                          
    ctlNext : CtlRecHndl; { Handle of next control. }                           
    ctlOwner : WindowPtr; { Pointer to control's window. }                      
    ctlRect : Rect; { Enclosing rectangle. }                                    
    ctlFlag : Byte; { Bit flags. }                                              
    ctlHilite : Byte; { Highlighted part. }                                     
    ctlValue : Integer; { Control's value. }                                    
    ctlProc : LongProcPtr; { Control's definition procedure. }                  
    ctlAction : LongProcPtr; { Control's action procedure. }                    
    ctlData : Longint; { Reserved for CtrlProc's use. }                         
    ctlRefCon : Longint; { Reserved for application's use. }                    
    ctlColor : Ptr; { Pointer to appropriate color table. }                     
    ctlReserved : PACKED ARRAY[1..16] OF Byte; { Reserved for future expansion  
}                                                                               
    ctlID : Longint;                                                            
    ctlMoreFlags : Integer;                                                     
    ctlVersion : Integer;                                                       
END;                                                                            
LimitBlkHndl = ^LimitBlkPtr;                                                    
LimitBlkPtr = ^LimitBlk;                                                        
LimitBlk = RECORD                                                               
    boundRect : Rect; { Drag bounds. }                                          
    slopRect : Rect; { Cursor bounds. }                                         
    axisParam : Integer; { Movement constrains. }                               
    dragPatt : Ptr; { Pointer to 32 byte Pattern for drag outline. }            
END;                                                                            
RadioColorsHndl = ^RadioColorsPtr;                                              
RadioColorsPtr = ^RadioColors;                                                  
RadioColors = RECORD                                                            
    radReserved : Integer; { reserved }                                         
    radNor : Integer; { color of radio button when off }                        
    radSel : Integer; { color of radio button when on }                         
    radTitle : Integer; { color of radio button's title text }                  
END;                                                                            
PROCEDURE CtlBootInit   ; Tool $10,$01;                                         
PROCEDURE CtlStartUp ( userID:Integer; dPageAddr:Integer)  ; Tool $10,$02;      
PROCEDURE CtlShutDown   ; Tool $10,$03;                                         
FUNCTION CtlVersion  : Integer ; Tool $10,$04;                                  
PROCEDURE CtlReset   ; Tool $10,$05;                                            
FUNCTION CtlStatus  : Boolean ; Tool $10,$06;                                   
PROCEDURE CtlNewRes   ; Tool $10,$12;                                           
PROCEDURE DisposeControl ( theControlHandle:CtlRecHndl)  ; Tool $10,$0A;        
PROCEDURE DragControl ( startX:Integer; startY:Integer; limitRectPtr:Rect;      
slopRectPtr:Rect; dragFlag:Integer; theControlHandle:CtlRecHndl)  ; Tool        
$10,$17;                                                                        
FUNCTION DragRect ( actionProcPtr:VoidProcPtr; dragPatternPtr:Pattern;          
startX:Integer; startY:Integer; dragRectPtr:Rect; limitRectPtr:Rect;            
slopRectPtr:Rect; dragFlag:Integer) : Longint ; Tool $10,$1D;                   
PROCEDURE DrawControls ( theWindowPtr:WindowPtr)  ; Tool $10,$10;               
PROCEDURE DrawOneCtl ( theControlHandle:CtlRecHndl)  ; Tool $10,$25;            
PROCEDURE EraseControl ( theControlHandle:CtlRecHndl)  ; Tool $10,$24;          
FUNCTION FindControl (VAR foundCtl:CtlRecHndl; pointX:Integer; pointY:Integer;  
theWindowPtr:WindowPtr) : Integer ; Tool $10,$13;                               
FUNCTION GetCtlAction ( theControlHandle:CtlRecHndl) : LongProcPtr ; Tool       
$10,$21;                                                                        
FUNCTION GetCtlDPage  : Integer ; Tool $10,$1F;                                 
FUNCTION GetCtlParams ( theControlHandle:CtlRecHndl) : Longint ; Tool $10,$1C;  
FUNCTION GetCtlRefCon ( theControlHandle:CtlRecHndl) : Longint ; Tool $10,$23;  
FUNCTION GetCtlTitle ( theControlHandle:CtlRecHndl) : Ptr ; Tool $10,$0D;       
FUNCTION GetCtlValue ( theControlHandle:CtlRecHndl) : Integer ; Tool $10,$1A;   
FUNCTION GrowSize  : Longint ; Tool $10,$1E;                                    
PROCEDURE HideControl ( theControlHandle:CtlRecHndl)  ; Tool $10,$0E;           
PROCEDURE HiliteControl ( hiliteState:Integer; theControlHandle:CtlRecHndl)  ;  
Tool $10,$11;                                                                   
PROCEDURE KillControls ( theWindowPtr:WindowPtr)  ; Tool $10,$0B;               
PROCEDURE MoveControl ( newX:Integer; newY:Integer;                             
theControlHandle:CtlRecHndl)  ; Tool $10,$16;                                   
FUNCTION NewControl ( theWindowPtr:WindowPtr; boundsRectPtr:Rect; titlePtr:Ptr; 
flag:Integer; value :Integer; param1:Integer; param2:Integer;                   
defProcPtr:LongProcPtr; refCon:Longint; U__colorTablePtr:Ptr) : CtlRecHndl ;    
Tool $10,$09;                                                                   
PROCEDURE SetCtlAction ( newActionPtr:LongProcPtr; theControlHandle:CtlRecHndl) 
; Tool $10,$20;                                                                 
FUNCTION SetCtlIcons ( newFontHandle:FontHndl) : FontHndl ; Tool $10,$18;       
PROCEDURE SetCtlParams ( param2:Integer; param1:Integer;                        
theControlHandle:CtlRecHndl)  ; Tool $10,$1B;                                   
PROCEDURE SetCtlRefCon ( newRefCon:Longint; theControlHandle:CtlRecHndl)  ;     
Tool $10,$22;                                                                   
PROCEDURE SetCtlTitle ( title:Str255; theControlHandle:CtlRecHndl)  ; Tool      
$10,$0C;                                                                        
PROCEDURE SetCtlValue ( curValue:Integer; theControlHandle:CtlRecHndl)  ; Tool  
$10,$19;                                                                        
PROCEDURE ShowControl ( theControlHandle:CtlRecHndl)  ; Tool $10,$0F;           
FUNCTION TestControl ( pointX:Integer; pointY:Integer;                          
theControlHandle:CtlRecHndl) : Integer ; Tool $10,$14;                          
FUNCTION TrackControl ( startX:Integer; startY:Integer;                         
actionProcPtr:LongProcPtr; theControlHndl:CtlRecHndl) : Integer ; Tool $10,$15; 
FUNCTION NewControl2 ( ownerPtr:WindowPtr; inputDesc:RefDescriptor;             
inputRef:Ref) : CtlRecHndl ; Tool $10,$31;                                      
FUNCTION FindTargetCtl  : CtlRecHndl ; Tool $10,$26;                            
FUNCTION MakeNextCtlTarget  : CtlRecHndl ; Tool $10,$27;                        
PROCEDURE MakeThisCtlTarget ( targetCtlRecHndl:CtlRecHndl)  ; Tool $10,$28;     
PROCEDURE CallCtlDefProc ( U__ctlRecHndl:CtlRecHndl; defProcMessage:Integer;    
U__param:Longint)  ; Tool $10,$2C;                                              
PROCEDURE NotifyControls ( U__mask:Integer; message:Integer; U__param:Longint;  
window:WindowPtr)  ; Tool $10,$2D;                                              
FUNCTION SendEventToCtl ( targetOnlyFlag:Integer; U__WindowPtr:WindowPtr;       
extendedTaskRecPtr:Ptr) : Boolean ; Tool $10,$29;                               
FUNCTION GetCtlID ( theCtlHandle:CtlRecHndl) : Longint ; Tool $10,$2A;          
PROCEDURE SetCtlID ( newID:Longint; theCtlHandle:CtlRecHndl)  ; Tool $10,$2B;   
FUNCTION GetCtlMoreFlags ( theCtlHandle:CtlRecHndl) : Longint ; Tool $10,$2E;   
FUNCTION SetCtlMoreFlags ( newID:Longint; theCtlHandle:CtlRecHndl) : Longint ;  
Tool $10,$2F;                                                                   
FUNCTION GetCtlHandleFromID ( U__WindowPtr:WindowPtr; ControlID:Longint) :      
CtlRecHndl ; Tool $10,$30;                                                      
PROCEDURE SetCtlParamPtr ( SubArrayPtr:Ptr)  ; Tool $10,$34;                    
FUNCTION GetCtlParamPtr  : Ptr ; Tool $10,$35;                                  
FUNCTION CMLoadResource ( U__ResType:Integer; U__ResID:Longint) : Handle ; Tool 
$10,$32;                                                                        
PROCEDURE CMReleaseResource ( U__ResType:Integer; U__ResID:Longint)  ; Tool     
$10,$33;                                                                        
PROCEDURE InvalCtls ( U__WindowPtr:Longint)  ; Tool $10,$37;                    
PROCEDURE NotifyCtls ( moreFlagsMask:Integer; message:Integer; param:Longint;   
theGrafPortPtr:GrafPort)  ; Tool $10,$2D;                                       
IMPLEMENTATION                                                                  
END.                                                                            
