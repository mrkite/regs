{********************************************                                   
; File: TextEdit.p                                                              
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT TEXTEDIT;                                                                  
INTERFACE                                                                       
USES TYPES,MEMORY,QUICKDRAW,EVENTS,CONTROLS,FONTS,GSOS,RESOURCES;               
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
teAlreadyStarted = $2201; {error -  }                                           
teNotStarted = $2202; {error -  }                                               
teInvalidHandle = $2203; {error -  }                                            
teInvalidVerb = $2204; {error -  }                                              
teInvalidFlag = $2205; {error -  }                                              
teInvalidPCount = $2206; {error -  }                                            
teInvalidRect = $2207; {error -  }                                              
teBufferOverflow = $2208; {error -  }                                           
teInvalidLine = $2209; { -  }                                                   
teInvalidCall = $220A; { -  }                                                   
   *** Toolset Errors *** *)                                                    
                                                                                
NullVerb = $0; {TE -  }                                                         
PStringVerb = $0001; {TE -  }                                                   
CStringVerb = $0002; {TE -  }                                                   
C1InputVerb = $0003; {TE -  }                                                   
C1OutputVerb = $0004; {TE -  }                                                  
HandleVerb = $0005; {TE -  }                                                    
PointerVerb = $0006; {TE -  }                                                   
NewPStringVerb = $0007; {TE -  }                                                
fEqualLineSpacing = $8000; {TE -  }                                             
fShowInvisibles = $4000; {TE -  }                                               
teInvalidDescriptor = $2204; { -  }                                             
teInvalidParameter = $220B; { -  }                                              
teInvalidTextBox2 = $220C; { -  }                                               
teEqualLineSpacing = $8000; { -  }                                              
teShowInvisibles = $4000; { -  }                                                
teJustLeft = $0; { -  }                                                         
teJustRight = $1; { -  }                                                        
teJustCenter = $2; { -  }                                                       
teJustFull = $3; { -  }                                                         
teNoTabs = $0; { -  }                                                           
teColumnTabs = $1; { -  }                                                       
teAbsoluteTabs = $2; { -  }                                                     
teLeftTab = $0; { -  }                                                          
teCenterTab = $1; { -  }                                                        
teRightTab = $2; { -  }                                                         
teDecimalTab = $3; { -  }                                                       
teInvis = $4000; { -  }                                                         
teCtlColorIsPtr = $0000; { -  }                                                 
teCtlColorIsHandle = $0004; { -  }                                              
teCtlColorIsResource = $0008; { -  }                                            
teCtlStyleIsPtr = $0000; { -  }                                                 
teCtlStyleIsHandle = $0001; { -  }                                              
teCtlStyleIsResource = $0002; { -  }                                            
teNotControl = $80000000; { -  }                                                
teSingleFormat = $40000000; { -  }                                              
teSingleStyle = $20000000; { -  }                                               
teNoWordWrap = $10000000; { -  }                                                
teNoScroll = $08000000; { -  }                                                  
teReadOnly = $04000000; { -  }                                                  
teSmartCutPaste = $02000000; { -  }                                             
teTabSwitch = $01000000; { -  }                                                 
teDrawBounds = $00800000; { -  }                                                
teColorHilite = $00400000; { -  }                                               
teRefIsPtr = $0000; { -  }                                                      
teRefIsHandle = $0001; { -  }                                                   
teRefIsResource = $0002; { -  }                                                 
teRefIsNewHandle = $0003; { -  }                                                
teDataIsPString = $0000; { -  }                                                 
teDataIsCString = $0001; { -  }                                                 
teDataIsC1Input = $0002; { -  }                                                 
teDataIsC1Output = $0003; { -  }                                                
teDataIsTextBox2 = $0004; { -  }                                                
teDataIsTextBlock = $0005; { -  }                                               
teTextIsPtr = $0000; { -  }                                                     
teTextIsHandle = $0008; { -  }                                                  
teTextIsResource = $0010; { -  }                                                
teTextIsNewHandle = $0018; { -  }                                               
tePartialLines = $8000; { -  }                                                  
teDontDraw = $4000; { -  }                                                      
teUseFont = $0020; { -  }                                                       
teUseSize = $0010; { -  }                                                       
teUseForeColor = $0008; { -  }                                                  
teUseBackColor = $0004; { -  }                                                  
teUseUserData = $0002; { -  }                                                   
teUseAttributes = $0001; { -  }                                                 
teReplaceFont = $0040; { -  }                                                   
teReplaceSize = $0020; { -  }                                                   
teReplaceForeColor = $0010; { -  }                                              
teReplaceBackColor = $0008; { -  }                                              
teReplaceUserField = $0004; { -  }                                              
teReplaceAttributes = $0002; { -  }                                             
teSwitchAttributes = $0001; { -  }                                              
teEraseRect = $0001; { -  }                                                     
teEraseBuffer = $0002; { -  }                                                   
teRectChanged = $0003; { -  }                                                   
doEraseRect = $0001; { -  }                                                     
doEraseBuffer = $0002; { -  }                                                   
doRectChanged = $0003; { -  }                                                   
doKeyStroke = $0004; { -  }                                                     
                                                                                
TYPE                                                                            
TEColorTablePtr = ^TEColorTable;                                                
TEColorTable = RECORD                                                           
    contentColor : Integer;                                                     
    outlineColor : Integer;                                                     
    pageBoundaryColor : Integer;                                                
    hiliteForeColor : Integer;                                                  
    hiliteBackColor : Integer;                                                  
    vertColorDescriptor : Integer;                                              
    vertColorRef : Longint;                                                     
    horzColorDescriptor : Integer;                                              
    horzColorRef : Longint;                                                     
    growColorDescriptor : Integer;                                              
    growColorRef : Longint;                                                     
END;                                                                            
TEBlockEntry = RECORD                                                           
    text : Handle;                                                              
    length : Handle;                                                            
    flags : Integer;                                                            
END;                                                                            
TEBlocksHndl = ^TEBlocksPtr;                                                    
TEBlocksPtr = ^TEBlocksRecord;                                                  
TEBlocksRecord = RECORD                                                         
    start : Longint;                                                            
    index : Integer;                                                            
    blocks : ARRAY[1..1] OF TEBlockEntry;                                       
END;                                                                            
TEHandle = ^TERecordPtr;                                                        
TERecordPtr = ^TERecord;                                                        
TERecord = PACKED RECORD                                                        
    ctlNext : CtlRecHndl;                                                       
    ctlOwner : WindowPtr;                                                       
    ctlRect : Rect;                                                             
    ctlFlag : Byte;                                                             
    ctlHilite : Byte;                                                           
    ctlValue : Integer;                                                         
    ctlProc : ProcPtr;                                                          
    ctlAction : ProcPtr;                                                        
    ctlData : Longint;                                                          
    ctlRefCon : Longint;                                                        
    ctlColorRef : TEColorTablePtr;                                              
                                                                                
    ctlID : Longint;                                                            
    ctlMoreFlags : Integer;                                                     
    ctlVersion : Integer;                                                       
    theChar : Integer;                                                          
    theModifiers : Integer;                                                     
    extendFlag : Integer;                                                       
    moveByWord : Integer;                                                       
    inputPtr : Ptr;                                                             
    inputLength : Longint;                                                      
    theRect : Rect;                                                             
END;                                                                            
TETabItem = RECORD                                                              
    tabKind : Integer;                                                          
    tabData : Integer;                                                          
END;                                                                            
TERuler = RECORD                                                                
    leftMargin : Integer;                                                       
    leftIndent : Integer;                                                       
    rightMargin : Integer;                                                      
    just : Integer;                                                             
    extraLS : Integer;                                                          
    flags : Integer;                                                            
    userData : Integer;                                                         
    tabType : Integer;                                                          
    tabs : ARRAY[1..1] OF TETabItem;                                            
    tabTerminator : Integer;                                                    
END;                                                                            
TEStyle = RECORD                                                                
    teFont : FontID;                                                            
    foreColor : Integer;                                                        
    backColor : Integer;                                                        
    reserved : Longint;                                                         
END;                                                                            
TEStyleGroupHndl = ^TEStyleGroupPtr;                                            
TEStyleGroupPtr = ^TEStyleGroup;                                                
TEStyleGroup = RECORD                                                           
    count : Integer;                                                            
    styles : ARRAY[1..1] OF TEStyle;                                            
END;                                                                            
TEStyleItem = RECORD                                                            
    length : Longint;                                                           
    offset : Longint;                                                           
END;                                                                            
TEFormatHndl = ^TEFormatPtr;                                                    
TEFormatPtr = ^TEFormat;                                                        
TEFormat = RECORD                                                               
    version : Integer;                                                          
    rulerListLength : Longint;                                                  
    theRulerList : ARRAY[1..1] OF TERuler;                                      
    styleListLength : Longint;                                                  
    theStyleList : ARRAY[1..1] OF TEStyle;                                      
    numberOfStyles : Longint;                                                   
    theStyles : ARRAY[1..1] OF TEStyleItem;                                     
END;                                                                            
TETextRef = RECORD CASE INTEGER OF                                              
     $0000:(textIsPStringPtr:StringPtr);                                        
     $0001:(textIsCStringPtr:CStringPtr);                                       
     $0002:(textIsC1InputPtr:GSString255Ptr);                                   
     $0003:(textIsC1OutputPtr:ResultBuf255Ptr);                                 
     $0004:(textIsTB2Ptr:Ptr);                                                  
     $0005:(textIsRawPtr:Ptr);                                                  
                                                                                
     $0008:(textIsPStringHandle:String255Hndl);                                 
     $0009:(textIsCStringHandle:CStringHndl);                                   
     $000A:(textIsC1InputHandle:GSString255Hndl);                               
     $000B:(textIsC1OutputHandle:ResultBuf255Hndl);                             
     $000C:(textIsTB2Handle:Handle);                                            
     $000D:(textIsRawHandle:Handle);                                            
                                                                                
     $0010:(textIsPStringResource: ResID);                                      
     $0011:(textIsCStringResource: ResID);                                      
     $0012:(textIsC1InputResource: ResID);                                      
     $0013:(textIsC1OutputResource: ResID);                                     
     $0014:(textIsTB2Resource: ResID);                                          
     $0015:(textIsRawResource: ResID);                                          
                                                                                
     $0018:(textIsPStringNewH:String255HndlPtr);                                
     $0019:(textIsCStringNewH:CStringHndlPtr);                                  
     $001A:(textIsC1InputNewH:GSString255HndlPtr);                              
     $001B:(textIsC1OutputNewH:ResultBuf255HndlPtr);                            
     $001C:(textIsTB2NewH:HandlePtr);                                           
     $001D:(textIsRawNewH:HandlePtr);                                           
END;                                                                            
                                                                                
TEStyleRef = RECORD CASE INTEGER OF                                             
     $0000:(styleIsPtr:TEFormatPtr);                                            
     $0001:(styleIsHandle:TEFormatHndl);                                        
     $0002:(styleIsResource:ResID);                                             
     $0003:(styleIsNewH:^TEFormatHndl);                                         
END;                                                                            
                                                                                
TEParamBlockHndl = ^TEParamBlockPtr;                                            
TEParamBlockPtr = ^TEParamBlock;                                                
TEParamBlock = RECORD                                                           
    pCount : Integer;                                                           
    controlID : Longint;                                                        
    boundsRect : Rect;                                                          
    procRef : Longint;                                                          
    flags : Integer;                                                            
    moreflags : Integer;                                                        
    refCon : Longint;                                                           
    textFlags : Longint;                                                        
    indentRect : Rect;                                                          
    vertBar : CtlRecHndl;                                                       
    vertScroll : Integer;                                                       
    horzBar : CtlRecHndl;                                                       
    horzScroll : Integer;                                                       
    styleRef : TEStyleRef;                                                      
    textDescriptor : Integer;                                                   
    textRef : TETextRef;                                                        
    textLength : Longint;                                                       
    maxChars : Longint;                                                         
    maxLines : Longint;                                                         
    maxHeight : Integer;                                                        
    pageHeight : Integer;                                                       
    headerHeight : Integer;                                                     
    footerHeight : Integer;                                                     
    pageBoundary : Integer;                                                     
    colorRef : Longint;                                                         
    drawMode : Integer;                                                         
    filterProcPtr : ProcPtr;                                                    
END;                                                                            
TEInfoRec = RECORD                                                              
    charCount : Longint;                                                        
    lineCount : Longint;                                                        
    formatMemory : Longint;                                                     
    totalMemory : Longint;                                                      
    styleCount : Longint;                                                       
    rulerCount : Longint;                                                       
END;                                                                            
TEHooks = RECORD                                                                
    charFilter : ProcPtr;                                                       
    wordWrap : ProcPtr;                                                         
    wordBreak : ProcPtr;                                                        
    drawText : ProcPtr;                                                         
    eraseText : ProcPtr;                                                        
END;                                                                            
PROCEDURE TEBootInit   ; Tool $22,$01;                                          
PROCEDURE TEStartup ( userId:Integer; directPage:Integer)  ; Tool $22,$02;      
PROCEDURE TEShutdown   ; Tool $22,$03;                                          
FUNCTION TEVersion  : Integer ; Tool $22,$04;                                   
PROCEDURE TEReset   ; Tool $22,$05;                                             
FUNCTION TEStatus  : Integer ; Tool $22,$06;                                    
PROCEDURE TEActivate ( teH:TEHandle)  ; Tool $22,$0F;                           
PROCEDURE TEClear ( teH:TEHandle)  ; Tool $22,$19;                              
PROCEDURE TEClick (VAR theEventPtr:EventRecord; teH:TEHandle)  ; Tool $22,$11;  
PROCEDURE TECut ( teH:TEHandle)  ; Tool $22,$16;                                
PROCEDURE TECopy ( teH:TEHandle)  ; Tool $22,$17;                               
PROCEDURE TEDeactivate ( teH:TEHandle)  ; Tool $22,$10;                         
FUNCTION TEGetDefProc  : ProcPtr ; Tool $22,$22;                                
PROCEDURE TEGetHooks (VAR hooks:TEHooks; count:Integer; teH:TEHandle)  ; Tool   
$22,$20;                                                                        
PROCEDURE TEGetSelection (VAR selStart:Longint;VAR selEnd:Longint;              
teH:TEHandle)  ; Tool $22,$1C;                                                  
FUNCTION TEGetSelectionStyle (VAR commonStyle:TEStyle;                          
styleHandle:TEStyleGroupHndl; teH:TEHandle) : Integer ; Tool $22,$1E;           
FUNCTION TEGetText ( bufferDesc:Integer; bufferRef:TETextRef;                   
bufferLength:Longint; styleDesc:Integer; styleRef:TEStyleRef; teH:TEHandle) :   
Longint ; Tool $22,$0C;                                                         
PROCEDURE TEGetTextInfo (VAR infoRec:TEInfoRec; pCount:Integer; teH:TEHandle)   
; Tool $22,$0D;                                                                 
PROCEDURE TEIdle ( teH:TEHandle)  ; Tool $22,$0E;                               
PROCEDURE TEInsert ( textDesc:Integer; textRef:TETextRef; textLength:Longint;   
styleDesc:Integer; styleRef:TEStyleRef; teH:TEHandle)  ; Tool $22,$1A;          
PROCEDURE TEInsertPageBreak ( teH:TEHandle)  ; Tool $22,$15;                    
PROCEDURE TEKey ( theEventPtr:EventRecord; teH:TEHandle)  ; Tool $22,$14;       
PROCEDURE TEKill ( teH:TEHandle)  ; Tool $22,$0A;                               
FUNCTION TENew ( theParms:TEParamBlock) : TEHandle ; Tool $22,$09;              
FUNCTION TEPaintText ( thePort:GrafPortPtr; start:Longint; destRect:rect;       
paintFlags:Integer; teH:TEHandle) : Longint ; Tool $22,$13;                     
PROCEDURE TEPaste ( teH:TEHandle)  ; Tool $22,$18;                              
PROCEDURE TEReplace ( textDesc:Integer; textRef:TETextRef; textLength:Longint;  
styleDesc:Integer; styleRef:TEStyleRef; teH:TEHandle)  ; Tool $22,$1B;          
PROCEDURE TESetHooks ( hooks:TEHooks; count:Integer; teH:TEHandle)  ; Tool      
$22,$21;                                                                        
PROCEDURE TESetSelection ( selStart:Longint; selEnd:Longint; teH:TEHandle)  ;   
Tool $22,$1D;                                                                   
PROCEDURE TESetText ( textDesc:Integer; textRef:TETextRef; textLength:Longint;  
styleDesc:Integer; styleRef:TEStyleRef; teH:TEHandle)  ; Tool $22,$0B;          
PROCEDURE TEStyleChange ( flags:Integer; newStyle:TEStyle; teH:TEHandle)  ;     
Tool $22,$1F;                                                                   
PROCEDURE TEUpdate ( teH:TEHandle)  ; Tool $22,$12;                             
PROCEDURE TEGetRuler ( rulerDescriptor:Integer; rulerRef:Ref; teH:TEHandle)  ;  
Tool $22,$23;                                                                   
PROCEDURE TEOffsetToPoint ( textOffset:Longint; vertPosPtr:Ptr; horzPosPtr:Ptr; 
teH:TEHandle)  ; Tool $22,$20;                                                  
FUNCTION TEPointToOffset ( vertPosPtr:Ptr; horzPosPtr:Ptr; teH:TEHandle) :      
Longint ; Tool $22,$21;                                                         
FUNCTION TEScroll ( scrollDescriptor:Integer; vertAmount:Longint;               
horzAmount:Longint; teH:TEHandle) : Longint ; Tool $22,$25;                     
PROCEDURE TESetRuler ( rulerDescriptor:Integer; rulerRef:Ref; teH:TEHandle);    
Tool $22,$24;                                                                   
IMPLEMENTATION                                                                  
END.                                                                            
