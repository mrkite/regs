{********************************************                                   
; File: Windows.p                                                               
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT WINDOWS;                                                                   
INTERFACE                                                                       
USES TYPES,QUICKDRAW,EVENTS,CONTROLS;                                           
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
paramLenErr = $0E01; {error - first word of parameter list is the wrong size }  
allocateErr = $0E02; {error - unable to allocate window record }                
taskMaskErr = $0E03; {error - bits 12-15 are not clear in WmTaskMask field of   
EventRecord }                                                                   
   *** Toolset Errors *** *)                                                    
                                                                                
wNoConstraint = $0000; {Axis parameter - No constraint on movement. }           
wHAxisOnly = $0001; {Axis parameter - Horizontal axis only. }                   
wVAxisOnly = $0002; {Axis parameter - Vertical axis only. }                     
FromDesk = $00; {Desktop Command - Subtract region from desktop }               
ToDesk = $1; {Desktop Command - Add region to desktop }                         
GetDesktop = $2; {Desktop Command - Get Handle of Desktop region }              
SetDesktop = $3; {Desktop Command - Set Handle of Desktop region }              
GetDeskPat = $4; {Desktop command - Address of  pattern or drawing routine }    
SetDeskPat = $5; {Desktop command - Change Address of  pattern or drawing       
routine }                                                                       
GetVisDesktop = $6; {Desktop command - Get destop region less visible windows.  
}                                                                               
BackGroundRgn = $7; {Desktop command - For drawing directly on desktop. }       
toBottom = $FFFFFFFE; {SendBehind value - To send window to bottom. }           
topMost = $FFFFFFFF; {SendBehind value - To make window top. }                  
bottomMost = $0000; {SendBehind value - To make window bottom. }                
tmMenuKey = $0001; {Task Mask -  }                                              
tmUpdate = $0002; {Task Mask -  }                                               
tmFindW = $0004; {Task Mask -  }                                                
tmMenuSel = $0008; {Task Mask -  }                                              
tmOpenNDA = $0010; {Task Mask -  }                                              
tmSysClick = $0020; {Task Mask -  }                                             
tmDragW = $0040; {Task Mask -  }                                                
tmContent = $0080; {Task Mask -  }                                              
tmClose = $0100; {Task Mask -  }                                                
tmZoom = $0200; {Task Mask -  }                                                 
tmGrow = $0400; {Task Mask -  }                                                 
tmScroll = $0800; {Task Mask -  }                                               
tmSpecial = $1000; {Task Mask -  }                                              
tmCRedraw = $2000; {Task Mask -  }                                              
tmInactive = $4000; {Task Mask -  }                                             
tmInfo = $8000; {Task Mask -  }                                                 
wNoHit = $0000; {TaskMaster codes - retained for back compatibility.  }         
inNull = $0000; {TaskMaster codes - retained for back compatibility }           
inKey = $0003; {TaskMaster codes - retained for back compatibility }            
inButtDwn = $0001; {TaskMaster codes - retained for back compatibility }        
inUpdate = $0006; {TaskMaster codes - retained for back compatibility }         
wInDesk = $0010; {TaskMaster codes - On Desktop }                               
wInMenuBar = $0011; {TaskMaster codes - On system menu bar }                    
wClickCalled = $0012; {TaskMaster codes - system click called }                 
wInContent = $0013; {TaskMaster codes - In content region }                     
wInDrag = $0014; {TaskMaster codes - In drag region }                           
wInGrow = $0015; {TaskMaster codes - In grow region, active window only }       
wInGoAway = $0016; {TaskMaster codes - In go-away region, active window only }  
wInZoom = $0017; {TaskMaster codes - In zoom region, active window only }       
wInInfo = $0018; {TaskMaster codes - In information bar }                       
wInSpecial = $0019; {TaskMaster codes - Item ID selected was 250 - 255 }        
wInDeskItem = $001A; {TaskMaster codes - Item ID selected was 1 - 249 }         
wInFrame = $1B; {TaskMaster codes - in Frame, but not on anything else }        
wInactMenu = $1C; {TaskMaster codes - "selection" of inactive menu item }       
wClosedNDA = $001D; {TaskMaster codes - desk accessory closed }                 
wCalledSysEdit = $001E; {TaskMaster codes - inactive menu item selected }       
wInSysWindow = $8000; {TaskMaster codes - hi bit set for system windows }       
wDraw = $00; {VarCode - Draw window frame command. }                            
wHit = $01; {VarCode - Hit test command. }                                      
wCalcRgns = $02; {VarCode - Compute regions command. }                          
wNew = $03; {VarCode - Initialization command. }                                
wDispose = $04; {VarCode - Dispose command. }                                   
fHilited = $0001; {WFrame - Window is highlighted. }                            
fZoomed = $0002; {WFrame - Window is zoomed. }                                  
fAllocated = $0004; {WFrame - Window record was allocated. }                    
fCtlTie = $0008; {WFrame - Window state tied to controls. }                     
fInfo = $0010; {WFrame - Window has an information bar. }                       
fVis = $0020; {WFrame - Window is visible. }                                    
fQContent = $0040; {WFrame -  }                                                 
fMove = $0080; {WFrame - Window is movable. }                                   
fZoom = $0100; {WFrame - Window is zoomable. }                                  
fFlex = $0200; {WFrame -  }                                                     
fGrow = $0400; {WFrame - Window has grow box. }                                 
fBScroll = $0800; {WFrame - Window has horizontal scroll bar. }                 
fRScroll = $1000; {WFrame - Window has vertical scroll bar. }                   
fAlert = $2000; {WFrame -  }                                                    
fClose = $4000; {WFrame - Window has a close box. }                             
fTitle = $8000; {WFrame - Window has a title bar. }                             
windSize = $145; {WindRec - Size of WindRec. }                                  
wmTaskRecSize = $0046; {WmTaskRec - Size of WmTaskRec. }                        
wTrackZoom = $001F; { -  }                                                      
wHitFrame = $0020; { -  }                                                       
wInControl = $0021; { -  }                                                      
                                                                                
TYPE                                                                            
WmTaskRec = EventRecord ;                                                       
                                                                                
                                                                                
WmTaskRecPtr = EventRecordPtr ;                                                 
                                                                                
WindColorHndl = ^WindColorPtr;                                                  
WindColorPtr = ^WindColor;                                                      
WindColor = RECORD                                                              
    frameColor : Integer; { Color of window frame. }                            
    titleColor : Integer; { Color of title and bar. }                           
    tBarColor : Integer; { Color/pattern of title bar. }                        
    growColor : Integer; { Color of grow box. }                                 
    infoColor : Integer; { Color of information bar. }                          
END;                                                                            
WindRecPtr = ^WindRec;                                                          
WindRec = RECORD                                                                
    port : GrafPort; { Window's port }                                          
    wDefProc : ProcPtr;                                                         
    wRefCon : Longint;                                                          
    wContDraw : ProcPtr;                                                        
    wReserved : Longint; { Space for future expansion }                         
    wStrucRgn : RgnHandle; { Region of frame plus content. }                    
    wContRgn : RgnHandle; { Content region. }                                   
    wUpdateRgn : RgnHandle; { Update region. }                                  
    wControls : CtlRecHndl; { Window's control list. }                          
    wFrameCtrls : CtlRecHndl; { Window frame's control list. }                  
    wFrame : Integer;                                                           
END;                                                                            
WindowChainPtr = ^WindowChain;                                                  
WindowChain = RECORD                                                            
    wNext : WindowChainPtr;                                                     
    theWindow : WindRec;                                                        
END;                                                                            
ParamListHndl = ^ParamListPtr;                                                  
ParamListPtr = ^ParamList;                                                      
ParamList = RECORD                                                              
    paramLength : Integer; { Parameter to NewWindow.  }                         
    wFrameBits : Integer; { Parameter to NewWindow. }                           
    wTitle : Ptr; { Parameter to NewWindow. }                                   
    wRefCon : Longint; { Parameter to NewWindow. }                              
    wZoom : Rect; { Parameter to NewWindow. }                                   
    wColor : WindColorPtr; { Parameter to NewWindow. }                          
    wYOrigin : Integer; { Parameter to NewWindow. }                             
    wXOrigin : Integer; { Parameter to NewWindow. }                             
    wDataH : Integer; { Parameter to NewWindow. }                               
    wDataW : Integer; { Parameter to NewWindow. }                               
    wMaxH : Integer; { Parameter to NewWindow. }                                
    wMaxW : Integer; { Parameter to NewWindow. }                                
    wScrollVer : Integer; { Parameter to NewWindow. }                           
    wScrollHor : Integer; { Parameter to NewWindow. }                           
    wPageVer : Integer; { Parameter to NewWindow. }                             
    wPageHor : Integer; { Parameter to NewWindow. }                             
    wInfoRefCon : Longint; { Parameter to NewWindow. }                          
    wInfoHeight : Integer; { height of information bar }                        
    wFrameDefProc : LongProcPtr; { Parameter to NewWindow. }                    
    wInfoDefProc : VoidProcPtr; { Parameter to NewWindow. }                     
    wContDefProc : VoidProcPtr; { Parameter to NewWindow. }                     
    wPosition : Rect; { Parameter to NewWindow. }                               
    wPlane : WindowPtr; { Parameter to NewWindow. }                             
    wStorage : WindowChainPtr; { Parameter to NewWindow. }                      
END;                                                                            
DeskMessageRecordPtr = ^DeskMessageRecord;                                      
DeskMessageRecord = RECORD                                                      
    reserved : Longint;                                                         
    messageType : Integer;                                                      
    drawType : Integer;                                                         
END;                                                                            
FUNCTION AlertWindow ( alertFlags:Integer; subStrPtr:Ptr; alertStrPtr:Ref) :    
Integer ; Tool $0E,$59;                                                         
PROCEDURE DrawInfoBar ( theWindowPtr:WindowPtr)  ; Tool $0E,$55;                
PROCEDURE EndFrameDrawing   ; Tool $0E,$5B;                                     
FUNCTION GetWindowMgrGlobals  : Longint ; Tool $0E,$58;                         
PROCEDURE ResizeWindow ( hiddenFlag:Integer; U__rectPtr:Rect;                   
theWindowPtr:WindowPtr)  ; Tool $0E,$5C;                                        
PROCEDURE StartFrameDrawing ( windowPtr:Longint)  ; Tool $0E,$5A;               
PROCEDURE WindBootInit   ; Tool $0E,$01;                                        
PROCEDURE WindStartUp ( userID:Integer)  ; Tool $0E,$02;                        
PROCEDURE WindShutDown   ; Tool $0E,$03;                                        
FUNCTION WindVersion  : Integer ; Tool $0E,$04;                                 
PROCEDURE WindReset   ; Tool $0E,$05;                                           
FUNCTION WindStatus  : Boolean ; Tool $0E,$06;                                  
PROCEDURE BeginUpdate ( theWindowPtr:WindowPtr)  ; Tool $0E,$1E;                
PROCEDURE BringToFront ( theWindowPtr:WindowPtr)  ; Tool $0E,$24;               
FUNCTION CheckUpdate ( theEventPtr:EventRecordPtr) : Boolean ; Tool $0E,$0A;    
PROCEDURE CloseWindow ( theWindowPtr:WindowPtr)  ; Tool $0E,$0B;                
FUNCTION Desktop ( deskTopOP:Integer; dtParam:Longint) : Ptr ; Tool $0E,$0C;    
PROCEDURE DragWindow ( grid:Integer; startX:Integer; startY:Integer;            
grace:Integer; boundsRectPtr:RectPtr; theWindowPtr:WindowPtr)  ; Tool $0E,$1A;  
PROCEDURE EndInfoDrawing   ; Tool $0E,$51;                                      
PROCEDURE EndUpdate ( theWindowPtr:WindowPtr)  ; Tool $0E,$1F;                  
FUNCTION FindWindow (VAR theWindowPtr:WindowPtr; pointX:Integer;                
pointY:Integer) : Integer ; Tool $0E,$17;                                       
FUNCTION FrontWindow  : WindowPtr ; Tool $0E,$15;                               
FUNCTION GetContentDraw ( theWindowPtr:WindowPtr) : VoidProcPtr ; Tool $0E,$48; 
FUNCTION GetContentOrigin ( theWindowPtr:WindowPtr) : Point ; Tool $0E,$3E;     
FUNCTION GetContentRgn ( theWindowPtr:WindowPtr) : RgnHandle ; Tool $0E,$2F;    
FUNCTION GetDataSize ( theWindowPtr:WindowPtr) : Longint ; Tool $0E,$40;        
FUNCTION GetDefProc ( theWindowPtr:WindowPtr) : LongProcPtr ; Tool $0E,$31;     
FUNCTION GetFirstWindow  : WindowPtr ; Tool $0E,$52;                            
PROCEDURE GetFrameColor (VAR colorPtr:WindColorPtr; theWindowPtr:WindowPtr)  ;  
Tool $0E,$10;                                                                   
FUNCTION GetInfoDraw ( theWindowPtr:WindowPtr) : VoidProcPtr ; Tool $0E,$4A;    
FUNCTION GetInfoRefCon ( theWindowPtr:WindowPtr) : Longint ; Tool $0E,$35;      
FUNCTION GetMaxGrow ( theWindowPtr:WindowPtr) : Longint ; Tool $0E,$42;         
FUNCTION GetNextWindow ( theWindowPtr:WindowPtr) : WindowPtr ; Tool $0E,$2A;    
FUNCTION GetPage ( theWindowPtr:WindowPtr) : Longint ; Tool $0E,$46;            
PROCEDURE GetRectInfo (VAR infoRectPtr:Rect; theWindowPtr:WindowPtr)  ; Tool    
$0E,$4F;                                                                        
FUNCTION GetScroll ( theWindowPtr:WindowPtr) : Longint ; Tool $0E,$44;          
FUNCTION GetStructRgn ( theWindowPtr:WindowPtr) : RgnHandle ; Tool $0E,$2E;     
FUNCTION GetSysWFlag ( theWindowPtr:WindowPtr) : Boolean ; Tool $0E,$4C;        
FUNCTION GetUpdateRgn ( theWindowPtr:WindowPtr) : RgnHandle ; Tool $0E,$30;     
FUNCTION GetWControls ( theWindowPtr:WindowPtr) : CtlRecHndl ; Tool $0E,$33;    
FUNCTION GetWFrame ( theWindowPtr:WindowPtr) : Integer ; Tool $0E,$2C;          
FUNCTION GetWKind ( theWindowPtr:WindowPtr) : Integer ; Tool $0E,$2B;           
FUNCTION GetWMgrPort  : WindowPtr ; Tool $0E,$20;                               
FUNCTION GetWRefCon ( theWindowPtr:WindowPtr) : Longint ; Tool $0E,$29;         
FUNCTION GetWTitle ( theWindowPtr:WindowPtr) : Ptr ; Tool $0E,$0E;              
FUNCTION GetZoomRect ( theWindowPtr:WindowPtr) : RectPtr ; Tool $0E,$37;        
FUNCTION GrowWindow ( minWidth:Integer; minHeight:Integer; startX:Integer;      
startY:Integer; theWindowPtr:WindowPtr) : Longint ; Tool $0E,$1B;               
PROCEDURE HideWindow ( theWindowPtr:WindowPtr)  ; Tool $0E,$12;                 
PROCEDURE HiliteWindow ( fHiliteFlag:Boolean; theWindowPtr:WindowPtr)  ; Tool   
$0E,$22;                                                                        
PROCEDURE InvalRect ( badRectPtr:Rect)  ; Tool $0E,$3A;                         
PROCEDURE InvalRgn ( badRgnHandle:RgnHandle)  ; Tool $0E,$3B;                   
PROCEDURE MoveWindow ( newX:Integer; newY:Integer; theWindowPtr:WindowPtr)  ;   
Tool $0E,$19;                                                                   
FUNCTION NewWindow ( theParamListPtr:ParamList) : WindowPtr ; Tool $0E,$09;     
FUNCTION PinRect ( theXPt:Integer; theYPt:Integer; theRectPtr:Rect) : Point ;   
Tool $0E,$21;                                                                   
PROCEDURE RefreshDesktop ( redrawRect:RectPtr)  ; Tool $0E,$39;                 
PROCEDURE SelectWindow ( theWindowPtr:WindowPtr)  ; Tool $0E,$11;               
PROCEDURE SendBehind ( behindWindowPtr:WindowPtr; theWindowPtr:WindowPtr)  ;    
Tool $0E,$14;                                                                   
PROCEDURE SetContentDraw ( contentDrawPtr:VoidProcPtr; theWindowPtr:WindowPtr)  
; Tool $0E,$49;                                                                 
PROCEDURE SetContentOrigin ( xOrigin:Integer; yOrigin:Integer;                  
theWindowPtr:WindowPtr)  ; Tool $0E,$3F;                                        
PROCEDURE SetContentOrigin2 ( scrollFlag:Integer; xOrigin:Integer;              
yOrigin:Integer; theWindowPtr:WindowPtr)  ; Tool $0E,$57;                       
PROCEDURE SetDataSize ( dataWidth:Integer; dataHeight:Integer;                  
theWindowPtr:WindowPtr)  ; Tool $0E,$41;                                        
PROCEDURE SetDefProc ( wDefProcPtr:LongProcPtr; theWindowPtr:WindowPtr)  ; Tool 
$0E,$32;                                                                        
PROCEDURE SetFrameColor ( newColorPtr:WindColorPtr; theWindowPtr:WindowPtr)  ;  
Tool $0E,$0F;                                                                   
PROCEDURE SetInfoDraw ( infoRecCon:VoidProcPtr; theWindowPtr:WindowPtr)  ; Tool 
$0E,$16;                                                                        
PROCEDURE SetInfoRefCon ( infoRefCon:Longint; theWindowPtr:WindowPtr)  ; Tool   
$0E,$36;                                                                        
PROCEDURE SetMaxGrow ( maxWidth:Integer; maxHeight:Integer;                     
theWindowPtr:WindowPtr)  ; Tool $0E,$43;                                        
PROCEDURE SetOriginMask ( originMask:Integer; theWindowPtr:WindowPtr)  ; Tool   
$0E,$34;                                                                        
PROCEDURE SetPage ( hPage:Integer; vPage:Integer; theWindowPtr:WindowPtr)  ;    
Tool $0E,$47;                                                                   
PROCEDURE SetScroll ( hScroll:Integer; vScroll:Integer; theWindowPtr:WindowPtr) 
; Tool $0E,$45;                                                                 
PROCEDURE SetSysWindow ( theWindowPtr:WindowPtr)  ; Tool $0E,$4B;               
PROCEDURE SetWFrame ( wFrame:Integer; theWindowPtr:WindowPtr)  ; Tool $0E,$2D;  
FUNCTION SetWindowIcons ( newFontHandle:FontHndl) : FontHndl ; Tool $0E,$4E;    
PROCEDURE SetWRefCon ( wRefCon:Longint; theWindowPtr:WindowPtr)  ; Tool         
$0E,$28;                                                                        
PROCEDURE SetWTitle ( title:Str255; theWindowPtr:WindowPtr)  ; Tool $0E,$0D;    
PROCEDURE SetZoomRect ( wZoomSizePtr:Rect; theWindowPtr:WindowPtr)  ; Tool      
$0E,$38;                                                                        
PROCEDURE ShowHide ( showFlag:Boolean; theWindowPtr:WindowPtr)  ; Tool $0E,$23; 
PROCEDURE ShowWindow ( theWindowPtr:WindowPtr)  ; Tool $0E,$13;                 
PROCEDURE SizeWindow ( newWidth:Integer; newHeight:Integer;                     
theWindowPtr:WindowPtr)  ; Tool $0E,$1C;                                        
PROCEDURE StartDrawing ( theWindowPtr:WindowPtr)  ; Tool $0E,$4D;               
PROCEDURE StartInfoDrawing (VAR infoRectPtr:Rect; theWindowPtr:WindowPtr)  ;    
Tool $0E,$50;                                                                   
FUNCTION TaskMaster ( taskMask:Integer; taskRecPtr:WmTaskRec) : Integer ; Tool  
$0E,$1D;                                                                        
FUNCTION TrackGoAway ( startX:Integer; startY:Integer; theWindowPtr:WindowPtr)  
: Boolean ; Tool $0E,$18;                                                       
FUNCTION TrackZoom ( startX:Integer; startY:Integer; theWindowPtr:WindowPtr) :  
Boolean ; Tool $0E,$26;                                                         
PROCEDURE ValidRect ( goodRectPtr:Rect)  ; Tool $0E,$3C;                        
PROCEDURE ValidRgn ( goodRgnHandle:RgnHandle)  ; Tool $0E,$3D;                  
FUNCTION WindDragRect ( actionProcPtr:VoidProcPtr; dragPatternPtr:Pattern;      
startX:Integer; startY:Integer; dragRectPtr:Rect; limitRectPtr:Rect;            
slopRectPtr:Rect; dragFlag:Integer) : Longint ; Tool $0E,$53;                   
PROCEDURE WindNewRes   ; Tool $0E,$25;                                          
FUNCTION WindowGlobal ( WindowGlobalMask:Integer) : Integer ; Tool $0E,$56;     
PROCEDURE ZoomWindow ( theWindowPtr:WindowPtr)  ; Tool $0E,$27;                 
FUNCTION TaskMasterDA ( eventMask:Integer; taskRecPtr:Ptr) : Integer ; Tool     
$0E,$5F;                                                                        
FUNCTION CompileText ( subType:Integer; subStringsPtr:Ptr; srcStringPtr:Ptr;    
srcSize:Integer) : Handle ; Tool $0E,$60;                                       
FUNCTION NewWindow2 ( titlePtr:StringPtr; refCon:Longint;                       
contentDrawPtr:ProcPtr; defProcPtr:ProcPtr; paramTableDesc:RefDescriptor;       
paramTableRef:Ref; resourceType:Integer) : WindowPtr ; Tool $0E,$61;            
FUNCTION ErrorWindow ( subType:Integer; subStringPtr:Ptr; errNum:Integer) :     
Integer ; Tool $0E,$62;                                                         
IMPLEMENTATION                                                                  
END.                                                                            
