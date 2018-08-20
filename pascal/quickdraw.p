{********************************************                                   
; File: Quickdraw.p                                                             
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT QUICKDRAW;                                                                 
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
alreadyInitialized = $0401; {error - Quickdraw already initialized }            
cannotReset = $0402; {error - never used }                                      
notInitialized = $0403; {error - Quickdraw not initialized }                    
screenReserved = $0410; {error - screen reserved }                              
badRect = $0411; {error - bad rectangle }                                       
notEqualChunkiness = $0420; {error - Chunkiness is not equal }                  
rgnAlreadyOpen = $0430; {error - region is already open }                       
rgnNotOpen = $0431; {error - region is not open }                               
rgnScanOverflow = $0432; {error - region scan overflow }                        
rgnFull = $0433; {error - region is full }                                      
polyAlreadyOpen = $0440; {error - poly is already open }                        
polyNotOpen = $0441; {error - poly is not open }                                
polyTooBig = $0442; {error - poly is too big }                                  
badTableNum = $0450; {error - bad table number }                                
badColorNum = $0451; {error - bad color number }                                
badScanLine = $0452; {error - bad scan line }                                   
notImplemented = $04FF; {error - not implemented }                              
   *** Toolset Errors *** *)                                                    
                                                                                
tsNumber = $04; { -  }                                                          
U_colorTable = $0F; {AnSCBByte - Mask for SCB color table }                     
scbReserved = $10; {AnSCBByte - Mask for SCB reserved bit }                     
scbFill = $20; {AnSCBByte - Mask for SCB fill bit }                             
scbInterrupt = $40; {AnSCBByte - Mask for SCB interrupt bit }                   
scbColorMode = $80; {AnSCBByte - Mask for SCB color mode bit }                  
table320 = $32; {ColorData -  (val=size) }                                      
table640 = $32; {ColorData -  (val=size) }                                      
blueMask = $000F; {ColorValue - Mask for Blue nibble }                          
greenMask = $00F0; {ColorValue - Mask for green nibble }                        
redMask = $0F00; {ColorValue - Mask for red nibble }                            
widMaxSize = $0001; {FontFlags -  }                                             
zeroSize = $0002; {FontFlags -  }                                               
maskSize = $08; {GrafPort - Mask Size (val=size) }                              
locSize = $10; {GrafPort - Loc Size (val=size) }                                
patsize = $20; {GrafPort - Pattern Size (val=size) }                            
pnStateSize = $32; {GrafPort - Pen State Size (Val=size) }                      
portSize = $AA; {GrafPort - Size of GrafPort }                                  
black = $000; {MasterColors - These work in 320 and 640 mode }                  
blue = $00F; {MasterColors - These work in 320 and 640 mode }                   
darkGreen320 = $080; {MasterColors - These work in 320 mode }                   
green320 = $0E0; {MasterColors - These work in 320 mode }                       
green640 = $0F0; {MasterColors - These work in 640 mode }                       
lightBlue320 = $4DF; {MasterColors - These work in 320 mode }                   
purple320 = $72C; {MasterColors - These work in 320 mode }                      
darkGray320 = $777; {MasterColors - These work in 320 mode }                    
periwinkleBlue320 = $78F; {MasterColors - These work in 320 mode }              
brown320 = $841; {MasterColors - These work in 320 mode }                       
lightGray320 = $0CCC; {MasterColors - These work in 320 mode }                  
red320 = $0D00; {MasterColors - These work in 320 mode }                        
lilac320 = $0DAF; {MasterColors - These work in 320 mode }                      
red640 = $0F00; {MasterColors - These work in 640 mode }                        
orange320 = $0F70; {MasterColors - These work in 320 mode }                     
flesh320 = $0FA9; {MasterColors - These work in 320 mode }                      
yellow = $0FF0; {MasterColors - These work in 320 and 640 mode }                
white = $0FFF; {MasterColors - These work in 320 and 640 mode }                 
modeCopy = $0000; {PenModeDATA -  }                                             
modeOR = $0001; {PenModeDATA -  }                                               
modeXOR = $0002; {PenModeDATA -  }                                              
modeBIC = $0003; {PenModeDATA -  }                                              
modeForeCopy = $0004; {PenModeDATA -  }                                         
modeForeOR = $0005; {PenModeDATA -  }                                           
modeForeXOR = $0006; {PenModeDATA -  }                                          
modeForeBIC = $0007; {PenModeDATA -  }                                          
modeNOT = $8000; {PenModeDATA -  }                                              
notCopy = $8000; {PenModeDATA -  }                                              
notOR = $8001; {PenModeDATA -  }                                                
notXOR = $8002; {PenModeDATA -  }                                               
notBIC = $8003; {PenModeDATA -  }                                               
notForeCOPY = $8004; {PenModeDATA -  }                                          
notForeOR = $8005; {PenModeDATA -  }                                            
notForeXOR = $8006; {PenModeDATA -  }                                           
notForeBIC = $8007; {PenModeDATA -  }                                           
mode320 = $0000; {QDStartup - Argument to QDStartup }                           
mode640 = $0080; {QDStartup - Argument to QDStartup }                           
plainMask = $0000; {TextStyle - Mask for plain text bit }                       
boldMask = $0001; {TextStyle - Mask for bold bit }                              
italicMask = $0002; {TextStyle - Mask for italic bit }                          
underlineMask = $0004; {TextStyle - Mask for underline bit }                    
outlineMask = $0008; {TextStyle - Mask for outline bit }                        
shadowMask = $0010; {TextStyle - Mask for shadow bit }                          
                                                                                
TYPE                                                                            
TextStyle = Integer ;                                                           
ColorValue = Integer ;                                                          
AnSCBByte = Byte ;                                                              
PatternPtr = ^Pattern;                                                          
Pattern = PACKED ARRAY[1..32] of Byte ;                                         
Mask = PACKED ARRAY[1..8] OF Byte;                                              
CursorHndl = ^CursorPtr;                                                        
CursorPtr = ^Cursor;                                                            
Cursor = RECORD                                                                 
    cursorHeight : Integer; { size in bytes }                                   
    cursorWidth : Integer; { enclosing rectangle }                              
    cursorData : ARRAY[1..1,1..1] OF Integer;                                   
    cursorMask : ARRAY[1..1,1..1] OF Integer;                                   
    cursorHotSpot : Point;                                                      
END;                                                                            
RgnHandle = ^RgnPtr;                                                            
RgnPtr = ^Region;                                                               
Region = RECORD                                                                 
    rgnSize : Integer; { size in bytes }                                        
    rgnBBox : Rect; { enclosing rectangle }                                     
END;                                                                            
BufDimRecHndl = ^BufDimRecPtr;                                                  
BufDimRecPtr = ^BufDimRec;                                                      
BufDimRec = RECORD                                                              
    maxWidth : Integer;                                                         
    textBufHeight : Integer;                                                    
    textBufferWords : Integer;                                                  
    fontWidth : Integer;                                                        
END;                                                                            
FontHndl = ^FontPtr;                                                            
FontPtr = ^Font;                                                                
Font = RECORD                                                                   
    offseToMF : Integer; { fully defined front of the Font record. }            
    family : Integer;                                                           
    style : TextStyle;                                                          
    size : Integer;                                                             
    version : Integer;                                                          
    fbrExtent : Integer;                                                        
END;                                                                            
FontGlobalsRecHndl = ^FontGlobalsRecPtr;                                        
FontGlobalsRecPtr = ^FontGlobalsRecord;                                         
FontGlobalsRecord = RECORD                                                      
    fgFontID : Integer; { currently 12 bytes long, but may be expanded }        
    fgStyle : TextStyle;                                                        
    fgSize : Integer;                                                           
    fgVersion : Integer;                                                        
    fgWidMax : Integer;                                                         
    fgFBRExtent : Integer;                                                      
END;                                                                            
FontIDHndl = ^FontIDPtr;                                                        
FontIDPtr = ^FontID;                                                            
FontID = PACKED RECORD                                                          
    famNum : Integer;                                                           
    fontStyle : Byte;                                                           
    fontSize : Byte;                                                            
END;                                                                            
FontInfoRecHndl = ^FontInfoRecPtr;                                              
FontInfoRecPtr = ^FontInfoRecord;                                               
FontInfoRecord = RECORD                                                         
    ascent : Integer;                                                           
    descent : Integer;                                                          
    widMax : Integer;                                                           
    leading : Integer;                                                          
END;                                                                            
LocInfoHndl = ^LocInfoPtr;                                                      
LocInfoPtr = ^LocInfo;                                                          
LocInfo = RECORD                                                                
    portSCB : Integer; { SCBByte in low byte }                                  
    ptrToPixImage : Ptr; { ImageRef }                                           
    width : Integer; { Width }                                                  
    boundsRect : Rect; { BoundsRect }                                           
END;                                                                            
QDProcsHndl = ^QDProcsPtr;                                                      
QDProcsPtr = ^QDProcs;                                                          
QDProcs = RECORD                                                                
    stdText : VoidProcPtr;                                                      
    stdLine : VoidProcPtr;                                                      
    stdRect : VoidProcPtr;                                                      
    stdRRect : VoidProcPtr;                                                     
    stdOval : VoidProcPtr;                                                      
    stdArc : VoidProcPtr;                                                       
    stdPoly : VoidProcPtr;                                                      
    stdRgn : VoidProcPtr;                                                       
    stdPixels : VoidProcPtr;                                                    
    stdComment : VoidProcPtr;                                                   
    stdTxMeas : VoidProcPtr;                                                    
    stdTxBnds : VoidProcPtr;                                                    
    stdGetPic : VoidProcPtr;                                                    
    stdPutPic : VoidProcPtr;                                                    
END;                                                                            
GrafPortHndl = ^GrafPortPtr;                                                    
GrafPortPtr = ^GrafPort;                                                        
GrafPort = RECORD                                                               
    portInfo : LocInfo;                                                         
    portRect : Rect; { PortRect }                                               
    clipRgn : RgnHandle; { Clip Rgn. Pointer }                                  
    visRgn : RgnHandle; { Vis. Rgn. Pointer }                                   
    bkPat : Pattern; { BackGround Pattern }                                     
    pnLoc : Point; { Pen Location }                                             
    pnSize : Point; { Pen Size }                                                
    pnMode : Integer; { Pen Mode }                                              
    pnPat : Pattern; { Pen Pattern }                                            
    pnMask : Mask; { Pen Mask }                                                 
    pnVis : Integer; { Pen Visable }                                            
    fontHandle : FontHndl;                                                      
    gfontID : FontID; { Font ID }                                               
    fontFlags : Integer; { FontFlags }                                          
    txSize : Integer; { Text Size }                                             
    txFace : TextStyle; { Text Face }                                           
    txMode : Integer; { Text Mode }                                             
    spExtra : Fixed; { Fixed Point Value }                                      
    chExtra : Fixed; { Fixed Point Value }                                      
    fgColor : Integer; { ForeGround Color }                                     
    bgColor : Integer; { BackGround Color }                                     
    picSave : Handle; { PicSave }                                               
    rgnSave : Handle; { RgnSave }                                               
    polySave : Handle; { PolySave }                                             
    grafProcs : QDProcsPtr;                                                     
    arcRot : Integer; { ArcRot }                                                
    userField : Longint; { UserField }                                          
    sysField : Longint; { SysField }                                            
END;                                                                            
PaintParamHndl = ^PaintParamPtr;                                                
PaintParamPtr = ^PaintParam;                                                    
PaintParam = RECORD                                                             
    ptrToSourceLocInfo : LocInfoPtr;                                            
    ptrToDestLocInfo : LocInfoPtr;                                              
    ptrToSourceRect : RectPtr;                                                  
    ptrToDestPoint : PointPtr;                                                  
    mode : Integer;                                                             
    maskHandle : Handle; { clip region }                                        
END;                                                                            
PenStateHndl = ^PenStatePtr;                                                    
PenStatePtr = ^PenState;                                                        
PenState = RECORD                                                               
    psPnSize : Point;                                                           
    psPnMode : Integer;                                                         
    psPnPat : Pattern;                                                          
    psPnMask : Mask;                                                            
END;                                                                            
RomFontRecHndl = ^RomFontRecPtr;                                                
RomFontRecPtr = ^RomFontRec;                                                    
RomFontRec = RECORD                                                             
    rfFamNum : Integer;                                                         
    rfFamStyle : Integer;                                                       
    rfSize : Integer;                                                           
    rfFontHandle : FontHndl;                                                    
    rfNamePtr : Ptr;                                                            
    rfFBRExtent : Integer;                                                      
END;                                                                            
ColorTableHndl = ^ColorTablePtr;                                                
ColorTablePtr = ^ColorTable;                                                    
ColorTable = RECORD                                                             
    entries : ARRAY[1..16] OF Integer;                                          
END;                                                                            
PROCEDURE QDBootInit   ; Tool $04,$01;                                          
PROCEDURE QDStartUp ( dPageAddr:Integer; masterSCB:Integer; maxWidth:Integer;   
userID:Integer)  ; Tool $04,$02;                                                
PROCEDURE QDShutDown   ; Tool $04,$03;                                          
FUNCTION QDVersion  : Integer ; Tool $04,$04;                                   
PROCEDURE QDReset   ; Tool $04,$05;                                             
FUNCTION QDStatus  : Boolean ; Tool $04,$06;                                    
PROCEDURE AddPt (VAR srcPtPtr:Point;VAR destPtPtr:Point)  ; Tool $04,$80;       
PROCEDURE CharBounds ( theChar:CHAR;VAR resultPtr:Rect)  ; Tool $04,$AC;        
FUNCTION CharWidth ( theChar:CHAR) : Integer ; Tool $04,$A8;                    
PROCEDURE ClearScreen ( colorWord:Integer)  ; Tool $04,$15;                     
PROCEDURE ClipRect ( rectPtr:Rect)  ; Tool $04,$26;                             
PROCEDURE ClosePoly   ; Tool $04,$C2;                                           
PROCEDURE ClosePort ( portPtr:GrafPortPtr)  ; Tool $04,$1A;                     
PROCEDURE CloseRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$6E;                     
PROCEDURE CopyRgn ( srcRgnHandle:RgnHandle; destRgnHandle:RgnHandle)  ; Tool    
$04,$69;                                                                        
PROCEDURE CStringBounds ( cStringPtr:Ptr;VAR resultRect:Rect)  ; Tool $04,$AE;  
FUNCTION CStringWidth ( cStringPtr:Ptr) : Integer ; Tool $04,$AA;               
PROCEDURE DiffRgn ( rgn1Handle:RgnHandle; rgn2Handle:RgnHandle;                 
diffRgnHandle:RgnHandle)  ; Tool $04,$73;                                       
PROCEDURE DisposeRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$68;                   
PROCEDURE DrawChar ( theChar:CHAR)  ; Tool $04,$A4;                             
PROCEDURE DrawCString ( cStrPtr:CStringPtr)  ; Tool $04,$A6;                    
PROCEDURE DrawString ( str:Str255)  ; Tool $04,$A5;                             
PROCEDURE DrawText ( textPtr:Ptr; textLength:Integer)  ; Tool $04,$A7;          
FUNCTION NotEmptyRect ( rectPtr:Rect) : Boolean ; Tool $04,$52;                 
FUNCTION EmptyRgn ( aRgnHandle:RgnHandle) : Boolean ; Tool $04,$78;             
FUNCTION EqualPt (VAR point1Ptr:Point;VAR point2Ptr:Point) : Boolean ; Tool     
$04,$83;                                                                        
FUNCTION EqualRect ( rect1Ptr:Rect; rect2Ptr:Rect) : Boolean ; Tool $04,$51;    
FUNCTION EqualRgn ( rgn1Handle:RgnHandle; rgn2Handle:RgnHandle) : Boolean ;     
Tool $04,$77;                                                                   
PROCEDURE EraseArc ( rectPtr:Rect; startAngle:Integer; arcAngle:Integer)  ;     
Tool $04,$64;                                                                   
PROCEDURE EraseOval ( rectPtr:Rect)  ; Tool $04,$5A;                            
PROCEDURE ErasePoly ( polyHandle:Handle)  ; Tool $04,$BE;                       
PROCEDURE EraseRect ( rectPtr:Rect)  ; Tool $04,$55;                            
PROCEDURE EraseRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$7B;                     
PROCEDURE EraseRRect ( rectPtr:Rect; ovalWidth:Integer; ovalHeight:Integer)  ;  
Tool $04,$5F;                                                                   
PROCEDURE FillArc ( rectPtr:Rect; startAngle:Integer; arcAngle:Integer;         
patternPtr:Pattern)  ; Tool $04,$66;                                            
PROCEDURE FillOval ( rectPtr:Rect; patternPtr:Pattern)  ; Tool $04,$5C;         
PROCEDURE FillPoly ( polyHandle:Handle; patternPtr:Pattern)  ; Tool $04,$C0;    
PROCEDURE FillRect ( rectPtr:Rect; patternPtr:Pattern)  ; Tool $04,$57;         
PROCEDURE FillRgn ( aRgnHandle:RgnHandle; patternPtr:Pattern)  ; Tool $04,$7D;  
PROCEDURE FillRRect ( rectPtr:Rect; ovalWidth:Integer; ovalHeight:Integer;      
patternPtr:Pattern)  ; Tool $04,$61;                                            
PROCEDURE ForceBufDims ( maxWidth:Integer; maxFontHeight:Integer;               
maxFBRExtent:Integer)  ; Tool $04,$CC;                                          
PROCEDURE FrameArc ( rectPtr:Rect; startAngle:Integer; arcAngle:Integer)  ;     
Tool $04,$62;                                                                   
PROCEDURE FrameOval ( rectPtr:Rect)  ; Tool $04,$58;                            
PROCEDURE FramePoly ( polyHandle:Handle)  ; Tool $04,$BC;                       
PROCEDURE FrameRect ( rectPtr:Rect)  ; Tool $04,$53;                            
PROCEDURE FrameRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$79;                     
PROCEDURE FrameRRect ( rectPtr:Rect; ovalWidth:Integer; ovalHeight:Integer)  ;  
Tool $04,$5D;                                                                   
FUNCTION GetAddress ( tableID:Integer) : Ptr ; Tool $04,$09;                    
FUNCTION GetArcRot  : Integer ; Tool $04,$B1;                                   
FUNCTION GetBackColor  : Integer ; Tool $04,$A3;                                
PROCEDURE GetBackPat (VAR patternPtr:Pattern)  ; Tool $04,$35;                  
FUNCTION GetCharExtra  : Fixed ; Tool $04,$D5;                                  
PROCEDURE GetClip ( aRgnHandle:RgnHandle)  ; Tool $04,$25;                      
FUNCTION GetClipHandle  : RgnHandle ; Tool $04,$C7;                             
FUNCTION GetColorEntry ( tableNumber:Integer; entryNumber:Integer) : Integer ;  
Tool $04,$11;                                                                   
PROCEDURE GetColorTable ( tableNumber:Integer;VAR destTablePtr:ColorTable)  ;   
Tool $04,$0F;                                                                   
FUNCTION GetCursorAdr  : CursorPtr ; Tool $04,$8F;                              
FUNCTION GetFGSize  : Integer ; Tool $04,$CF;                                   
FUNCTION GetFont  : FontHndl ; Tool $04,$95;                                    
FUNCTION GetFontFlags  : Integer ; Tool $04,$99;                                
PROCEDURE GetFontGlobals (VAR fgRecPtr:FontGlobalsRecord)  ; Tool $04,$97;      
FUNCTION GetFontID  : FontID ; Tool $04,$D1;                                    
PROCEDURE GetFontInfo (VAR fontInfoRecPtr:FontInfoRecord)  ; Tool $04,$96;      
FUNCTION GetFontLore (VAR recordPtr:FontGlobalsRecord; recordSize:Integer) :    
Integer ; Tool $04,$D9;                                                         
FUNCTION GetForeColor  : Integer ; Tool $04,$A1;                                
FUNCTION GetGrafProcs  : QDProcsPtr ; Tool $04,$45;                             
FUNCTION GetMasterSCB  : Integer ; Tool $04,$17;                                
PROCEDURE GetPen (VAR pointPtr:Point)  ; Tool $04,$29;                          
PROCEDURE GetPenMask (VAR maskPtr:Mask)  ; Tool $04,$33;                        
FUNCTION GetPenMode  : Integer ; Tool $04,$2F;                                  
PROCEDURE GetPenPat (VAR patternPtr:Pattern)  ; Tool $04,$31;                   
PROCEDURE GetPenSize (VAR pointPtr:Point)  ; Tool $04,$2D;                      
PROCEDURE GetPenState (VAR U__penStatePtr:PenState)  ; Tool $04,$2B;            
FUNCTION GetPicSave  : Longint ; Tool $04,$3F;                                  
FUNCTION GetPixel ( h:Integer; v:Integer) : Integer ; Tool $04,$88;             
FUNCTION GetPolySave  : Longint ; Tool $04,$43;                                 
FUNCTION GetPort  : GrafPortPtr ; Tool $04,$1C;                                 
PROCEDURE GetPortLoc (VAR locInfoPtr:LocInfo)  ; Tool $04,$1E;                  
PROCEDURE GetPortRect (VAR U__rectPtr:Rect)  ; Tool $04,$20;                    
FUNCTION GetRgnSave  : Longint ; Tool $04,$41;                                  
PROCEDURE GetROMFont (VAR recordPtr:RomFontRec)  ; Tool $04,$D8;                
FUNCTION GetSCB ( scanLine:Integer) : Integer ; Tool $04,$13;                   
FUNCTION GetSpaceExtra  : Fixed ; Tool $04,$9F;                                 
FUNCTION GetStandardSCB  : Integer ; Tool $04,$0C;                              
FUNCTION GetSysField  : Longint ; Tool $04,$49;                                 
FUNCTION GetSysFont  : FontHndl ; Tool $04,$B3;                                 
FUNCTION GetTextFace  : TextStyle ; Tool $04,$9B;                               
FUNCTION GetTextMode  : Integer ; Tool $04,$9D;                                 
FUNCTION GetTextSize  : Integer ; Tool $04,$D3;                                 
FUNCTION GetUserField  : Longint ; Tool $04,$47;                                
FUNCTION GetVisHandle  : RgnHandle ; Tool $04,$C9;                              
PROCEDURE GetVisRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$B5;                    
PROCEDURE GlobalToLocal (VAR pointPtr:Point)  ; Tool $04,$85;                   
PROCEDURE GrafOff   ; Tool $04,$0B;                                             
PROCEDURE GrafOn   ; Tool $04,$0A;                                              
PROCEDURE HideCursor   ; Tool $04,$90;                                          
PROCEDURE HidePen   ; Tool $04,$27;                                             
PROCEDURE InflateTextBuffer ( newWidth:Integer; newHeight:Integer)  ; Tool      
$04,$D7;                                                                        
PROCEDURE InitColorTable (VAR tablePtr:ColorTable)  ; Tool $04,$0D;             
PROCEDURE InitCursor   ; Tool $04,$CA;                                          
PROCEDURE InitPort ( portPtr:GrafPortPtr)  ; Tool $04,$19;                      
PROCEDURE InsetRect (VAR U__rectPtr:Rect; deltaH:Integer; deltaV:Integer)  ;    
Tool $04,$4C;                                                                   
PROCEDURE InsetRgn ( aRgnHandle:RgnHandle; dH:Integer; dV:Integer)  ; Tool      
$04,$70;                                                                        
PROCEDURE InvertArc ( rectPtr:Rect; startAngle:Integer; arcAngle:Integer)  ;    
Tool $04,$65;                                                                   
PROCEDURE InvertOval ( rectPtr:Rect)  ; Tool $04,$5B;                           
PROCEDURE InvertPoly ( polyHandle:Handle)  ; Tool $04,$BF;                      
PROCEDURE InvertRect ( rectPtr:Rect)  ; Tool $04,$56;                           
PROCEDURE InvertRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$7C;                    
PROCEDURE InvertRRect ( rectPtr:Rect; ovalWidth:Integer; ovalHeight:Integer)  ; 
Tool $04,$60;                                                                   
PROCEDURE KillPoly ( polyHandle:Handle)  ; Tool $04,$C3;                        
PROCEDURE Line ( dH:Integer; dV:Integer)  ; Tool $04,$3D;                       
PROCEDURE LineTo ( h:Integer; v:Integer)  ; Tool $04,$3C;                       
PROCEDURE LocalToGlobal (VAR pointPtr:Point)  ; Tool $04,$84;                   
PROCEDURE MapPoly ( polyHandle:Handle; srcRectPtr:Rect; destRectPtr:Rect)  ;    
Tool $04,$C5;                                                                   
PROCEDURE MapPt (VAR pointPtr:Point; srcRectPtr:Rect; destRectPtr:Rect)  ; Tool 
$04,$8A;                                                                        
PROCEDURE MapRect (VAR rectPtr:Rect; srcRectPtr:Rect; destRectPtr:Rect)  ; Tool 
$04,$8B;                                                                        
PROCEDURE MapRgn ( aRgnHandle:RgnHandle; srcRectPtr:Rect; destdRectPtr:Rect)  ; 
Tool $04,$8C;                                                                   
PROCEDURE Move ( dH:Integer; dV:Integer)  ; Tool $04,$3B;                       
PROCEDURE MovePortTo ( h:Integer; v:Integer)  ; Tool $04,$22;                   
PROCEDURE MoveTo ( h:Integer; v:Integer)  ; Tool $04,$3A;                       
FUNCTION NewRgn  : RgnHandle ; Tool $04,$67;                                    
PROCEDURE ObscureCursor   ; Tool $04,$92;                                       
PROCEDURE OffsetPoly ( polyHandle:Handle; dH:Integer; dV:Integer)  ; Tool       
$04,$C4;                                                                        
PROCEDURE OffsetRect (VAR U__rectPtr:Rect; deltaH:Integer; deltaV:Integer)  ;   
Tool $04,$4B;                                                                   
PROCEDURE OffsetRgn ( aRgnHandle:RgnHandle; dH:Integer; dV:Integer)  ; Tool     
$04,$6F;                                                                        
FUNCTION OpenPoly  : handle ; Tool $04,$C1;                                     
PROCEDURE OpenPort ( portPtr:GrafPortPtr)  ; Tool $04,$18;                      
PROCEDURE OpenRgn   ; Tool $04,$6D;                                             
PROCEDURE PaintArc ( rectPtr:Rect; startAngle:Integer; arcAngle:Integer)  ;     
Tool $04,$63;                                                                   
PROCEDURE PaintOval ( rectPtr:Rect)  ; Tool $04,$59;                            
PROCEDURE PaintPixels ( U__paintParamPtr:PaintParam)  ; Tool $04,$7F;           
PROCEDURE PaintPoly ( polyHandle:Handle)  ; Tool $04,$BD;                       
PROCEDURE PaintRect ( rectPtr:Rect)  ; Tool $04,$54;                            
PROCEDURE PaintRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$7A;                     
PROCEDURE PaintRRect ( rectPtr:Rect; ovalWidth:Integer; ovalHeight:Integer)  ;  
Tool $04,$5E;                                                                   
PROCEDURE PenNormal   ; Tool $04,$36;                                           
PROCEDURE PPToPort ( srcLocPtr:LocInfoPtr; srcRectPtr:Rect; destX:Integer;      
destY:Integer; transferMode:Integer)  ; Tool $04,$D6;                           
PROCEDURE Pt2Rect (VAR point1Ptr:Point;VAR point2Ptr:Point;VAR U__rectPtr:Rect) 
; Tool $04,$50;                                                                 
FUNCTION PtInRect (VAR pointPtr:Point; rectPtr:Rect) : Boolean ; Tool $04,$4F;  
FUNCTION PtInRgn (VAR pointPtr:Point; aRgnHandle:RgnHandle) : Boolean ; Tool    
$04,$75;                                                                        
FUNCTION Random  : Integer ; Tool $04,$86;                                      
FUNCTION RectInRgn ( rectPtr:Rect; aRgnHandle:RgnHandle) : Boolean ; Tool       
$04,$76;                                                                        
PROCEDURE RectRgn ( aRgnHandle:RgnHandle; rectPtr:Rect)  ; Tool $04,$6C;        
PROCEDURE RestoreBufDims ( sizeInfoPtr:BufDimRecPtr)  ; Tool $04,$CE;           
PROCEDURE SaveBufDims (VAR sizeInfoPtr:BufDimRec)  ; Tool $04,$CD;              
PROCEDURE ScalePt (VAR pointPtr:Point; srcRectPtr:Rect; destRectPtr:Rect)  ;    
Tool $04,$89;                                                                   
PROCEDURE ScrollRect ( rectPtr:Rect; dH:Integer; dV:Integer;                    
aRgnHandle:RgnHandle)  ; Tool $04,$7E;                                          
FUNCTION SectRect ( rect1Ptr:Rect; rect2Ptr:Rect;VAR intersectRectPtr:Rect) :   
Boolean ; Tool $04,$4D;                                                         
PROCEDURE SectRgn ( rgn1Handle:RgnHandle; rgn2Handle:RgnHandle;                 
destRgnHandle:RgnHandle)  ; Tool $04,$71;                                       
PROCEDURE SetAllSCBs ( newSCB:Integer)  ; Tool $04,$14;                         
PROCEDURE SetArcRot   ; Tool $04,$B0;                                           
PROCEDURE SetBackColor ( backColor:Integer)  ; Tool $04,$A2;                    
PROCEDURE SetBackPat ( patternPtr:Pattern)  ; Tool $04,$34;                     
PROCEDURE SetBufDims ( maxWidth:Integer; maxFontHeight:Integer;                 
maxFBRExtent:Integer)  ; Tool $04,$CB;                                          
PROCEDURE SetCharExtra ( charExtra:Fixed)  ; Tool $04,$D4;                      
PROCEDURE SetClip ( aRgnHandle:RgnHandle)  ; Tool $04,$24;                      
PROCEDURE SetClipHandle ( aRgnHandle:RgnHandle)  ; Tool $04,$C6;                
PROCEDURE SetColorEntry ( tableNumber:Integer; entryNumber:Integer;             
newColor:ColorValue)  ; Tool $04,$10;                                           
PROCEDURE SetColorTable ( tableNumber:Integer; srcTablePtr:ColorTable)  ; Tool  
$04,$0E;                                                                        
PROCEDURE SetCursor ( theCursorPtr:Cursor)  ; Tool $04,$8E;                     
PROCEDURE SetEmptyRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$6A;                  
PROCEDURE SetFont ( newFontHandle:FontHndl)  ; Tool $04,$94;                    
PROCEDURE SetFontFlags ( fontFlags:Integer)  ; Tool $04,$98;                    
PROCEDURE SetFontID (VAR U__fontID:FontID)  ; Tool $04,$D0;                     
PROCEDURE SetForeColor ( foreColor:Integer)  ; Tool $04,$A0;                    
PROCEDURE SetGrafProcs ( grafProcsPtr:QDProcsPtr)  ; Tool $04,$44;              
PROCEDURE SetIntUse ( useInt:Integer)  ; Tool $04,$B6;                          
PROCEDURE SetMasterSCB ( masterSCB:Integer)  ; Tool $04,$16;                    
PROCEDURE SetOrigin ( h:Integer; v:Integer)  ; Tool $04,$23;                    
PROCEDURE SetPenMask ( maskPtr:Mask)  ; Tool $04,$32;                           
PROCEDURE SetPenMode ( penMode:Integer)  ; Tool $04,$2E;                        
PROCEDURE SetPenPat ( patternPtr:Pattern)  ; Tool $04,$30;                      
PROCEDURE SetPenSize ( penWidth:Integer; penHeight:Integer)  ; Tool $04,$2C;    
PROCEDURE SetPenState (VAR U__penStatePtr:PenState)  ; Tool $04,$2A;            
PROCEDURE SetPicSave ( picSaveValue:Longint)  ; Tool $04,$3E;                   
PROCEDURE SetPolySave ( polySaveValue:Longint)  ; Tool $04,$42;                 
PROCEDURE SetPort ( portPtr:GrafPortPtr)  ; Tool $04,$1B;                       
PROCEDURE SetPortLoc ( U__locInfoPtr:LocInfo)  ; Tool $04,$1D;                  
PROCEDURE SetPortRect ( rectPtr:Rect)  ; Tool $04,$1F;                          
PROCEDURE SetPortSize ( portWidth:Integer; portHeight:Integer)  ; Tool $04,$21; 
PROCEDURE SetPt (VAR srcPtPtr:Point; h:Integer; v:Integer)  ; Tool $04,$82;     
PROCEDURE SetRandSeed ( randomSeed:Longint)  ; Tool $04,$87;                    
PROCEDURE SetRect (VAR aRectPtr:Rect; left:Integer; top:Integer; right:Integer; 
bottom:Integer)  ; Tool $04,$4A;                                                
PROCEDURE SetRectRgn ( aRgnHandle:RgnHandle; left:Integer; top:Integer;         
right:Integer; bottom:Integer)  ; Tool $04,$6B;                                 
PROCEDURE SetRgnSave ( rgnSaveValue:Longint)  ; Tool $04,$40;                   
PROCEDURE SetSCB ( scanLine:Integer; newSCB:Integer)  ; Tool $04,$12;           
PROCEDURE SetSolidBackPat ( colorNum:Integer)  ; Tool $04,$38;                  
PROCEDURE SetSolidPenPat ( colorNum:Integer)  ; Tool $04,$37;                   
PROCEDURE SetSpaceExtra ( spaceExtra:Fixed)  ; Tool $04,$9E;                    
PROCEDURE SetStdProcs ( stdProcRecPtr:QDProcsPtr)  ; Tool $04,$8D;              
PROCEDURE SetSysField ( sysFieldValue:Longint)  ; Tool $04,$48;                 
PROCEDURE SetSysFont ( fontHandle:FontHndl)  ; Tool $04,$B2;                    
PROCEDURE SetTextFace ( textFace:TextStyle)  ; Tool $04,$9A;                    
PROCEDURE SetTextMode ( textMode:Integer)  ; Tool $04,$9C;                      
PROCEDURE SetTextSize ( textSize:Integer)  ; Tool $04,$D2;                      
PROCEDURE SetUserField ( userFieldValue:Longint)  ; Tool $04,$46;               
PROCEDURE SetVisHandle ( aRgnHandle:RgnHandle)  ; Tool $04,$C8;                 
PROCEDURE SetVisRgn ( aRgnHandle:RgnHandle)  ; Tool $04,$B4;                    
PROCEDURE ShowCursor   ; Tool $04,$91;                                          
PROCEDURE ShowPen   ; Tool $04,$28;                                             
PROCEDURE SolidPattern ( colorNum:Integer;VAR patternPtr:Pattern)  ; Tool       
$04,$39;                                                                        
PROCEDURE StringBounds ( str:Str255;VAR resultPtr:Rect)  ; Tool $04,$AD;        
FUNCTION StringWidth ( str:Str255) : Integer ; Tool $04,$A9;                    
PROCEDURE SubPt (VAR srcPtPtr:Point;VAR destPtPtr:Point)  ; Tool $04,$81;       
PROCEDURE TextBounds ( textPtr:Ptr; textLength:Integer;VAR resultPtr:Rect)  ;   
Tool $04,$AF;                                                                   
FUNCTION TextWidth ( textPtr:Ptr; textLength:Integer) : Integer ; Tool $04,$AB; 
PROCEDURE UnionRect ( rect1Ptr:Rect; rect2Ptr:Rect;VAR unionRectPtr:Rect)  ;    
Tool $04,$4E;                                                                   
PROCEDURE UnionRgn ( rgn1Handle:RgnHandle; rgn2Handle:RgnHandle;                
unionRgnHandle:RgnHandle)  ; Tool $04,$72;                                      
PROCEDURE XorRgn ( rgn1Handle:RgnHandle; rgn2Handle:RgnHandle;                  
xorRgnHandle:RgnHandle)  ; Tool $04,$74;                                        
IMPLEMENTATION                                                                  
END.                                                                            
