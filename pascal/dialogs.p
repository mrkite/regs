{********************************************                                   
; File: Dialogs.p                                                               
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT DIALOGS;                                                                   
INTERFACE                                                                       
USES TYPES,QUICKDRAW,EVENTS,CONTROLS,WINDOWS,LINEEDIT;                          
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
badItemType = $150A; {error -  }                                                
newItemFailed = $150B; {error -  }                                              
itemNotFound = $150C; {error -  }                                               
notModalDialog = $150D; {error -  }                                             
   *** Toolset Errors *** *)                                                    
                                                                                
getInitView = $0001; {Command -  }                                              
getInitTotal = $0002; {Command -  }                                             
getInitValue = $0003; {Command -  }                                             
scrollLineUp = $0004; {Command -  }                                             
scrollLineDown = $0005; {Command -  }                                           
scrollPageUp = $0006; {Command -  }                                             
scrollPageDown = $0007; {Command -  }                                           
scrollThumb = $0008; {Command -  }                                              
buttonItem = $000A; {Item Type -  }                                             
checkItem = $000B; {Item Type -  }                                              
radioItem = $000C; {Item Type -  }                                              
scrollBarItem = $000D; {Item Type -  }                                          
userCtlItem = $000E; {Item Type -  }                                            
statText = $000F; {Item Type -  }                                               
longStatText = $0010; {Item Type -  }                                           
editLine = $0011; {Item Type -  }                                               
iconItem = $0012; {Item Type -  }                                               
picItem = $0013; {Item Type -  }                                                
userItem = $0014; {Item Type -  }                                               
userCtlItem2 = $0015; {Item Type -  }                                           
longStatText2 = $0016; {Item Type -  }                                          
itemDisable = $8000; {Item Type -  }                                            
minItemType = $000A; {Item Type Range -  }                                      
maxItemType = $0016; {Item Type Range -  }                                      
ok = $0001; {ItemID -  }                                                        
cancel = $0002; {ItemID -  }                                                    
inButton = $0002; {ModalDialog2 - Part code }                                   
inCheckBox = $0003; {ModalDialog2 - Part code }                                 
inRadioButton = $0004; {ModalDialog2 - Part code }                              
inUpArrow = $0005; {ModalDialog2 - Part code }                                  
inDownArrow = $0006; {ModalDialog2 - Part code }                                
inPageUp = $0007; {ModalDialog2 - Part code }                                   
inPageDown = $0008; {ModalDialog2 - Part code }                                 
inStatText = $0009; {ModalDialog2 - Part code }                                 
inGrow = $000A; {ModalDialog2 - Part code }                                     
inEditLine = $000B; {ModalDialog2 - Part code }                                 
inUserItem = $000C; {ModalDialog2 - Part code }                                 
inLongStatText = $000D; {ModalDialog2 - Part code }                             
inIconItem = $000E; {ModalDialog2 - Part code }                                 
inLongStatText2 = $000F; {ModalDialog2 -  }                                     
inThumb = $0081; {ModalDialog2 - Part code }                                    
okDefault = $0000; {Stage Bit Vector -  }                                       
cancelDefault = $0040; {Stage Bit Vector -  }                                   
alertDrawn = $0080; {Stage Bit Vector -  }                                      
                                                                                
atItemListLength = $0005;                                                       
                                                                                
dtItemListLength = $0008;                                                       
                                                                                
TYPE                                                                            
DialogPtr = WindowPtr ;                                                         
ItemTempHndl = ^ItemTempPtr;                                                    
ItemTempPtr = ^ItemTemplate;                                                    
ItemTemplate = RECORD                                                           
    itemID : Integer;                                                           
    itemRect : Rect;                                                            
    itemType : Integer;                                                         
    itemDescr : Ptr;                                                            
    itemValue : Integer;                                                        
    itemFlag : Integer;                                                         
    itemColor : Ptr; { pointer to appropriate type of color table }             
END;                                                                            
AlertTempHndl = ^AlertTempPtr;                                                  
AlertTempPtr = ^AlertTemplate;                                                  
AlertTemplate = RECORD                                                          
    atBoundsRect : Rect;                                                        
    atAlertID : Integer;                                                        
    atStage1 : Byte;                                                            
    atStage2 : Byte;                                                            
    atStage3 : Byte;                                                            
    atStage4 : Byte;                                                            
    atItemList : ARRAY[1..atItemListLength] OF ItemTempPtr; { Null terminated   
array }                                                                         
END;                                                                            
DlgTempHndl = ^DlgTempPtr;                                                      
DlgTempPtr = ^DialogTemplate;                                                   
DialogTemplate = RECORD                                                         
    dtBoundsRect : Rect;                                                        
    dtVisible : Boolean;                                                        
    dtRefCon : Longint;                                                         
    dtItemList : ARRAY[1..dtItemListLength] OF ItemTempPtr; { Null terminated   
array }                                                                         
END;                                                                            
IconRecordHndl = ^IconRecordPtr;                                                
IconRecordPtr = ^IconRecord;                                                    
IconRecord = RECORD                                                             
    iconRect : Rect;                                                            
    iconImage : PACKED ARRAY[1..1] OF Byte;                                     
END;                                                                            
UserCtlItemPBHndl = ^UserCtlItemPBPtr;                                          
UserCtlItemPBPtr = ^UserCtlItemPB;                                              
UserCtlItemPB = RECORD                                                          
    defProcParm : Longint; { ? should this be a LongProcPtr? }                  
    titleParm : Ptr;                                                            
    param2 : Integer;                                                           
    param1 : Integer;                                                           
END;                                                                            
PROCEDURE DialogBootInit   ; Tool $15,$01;                                      
PROCEDURE DialogStartUp ( userID:Integer)  ; Tool $15,$02;                      
PROCEDURE DialogShutDown   ; Tool $15,$03;                                      
FUNCTION DialogVersion  : Integer ; Tool $15,$04;                               
PROCEDURE DialogReset   ; Tool $15,$05;                                         
FUNCTION DialogStatus  : Boolean ; Tool $15,$06;                                
FUNCTION Alert ( alertTemplatePtr:AlertTemplate; filterProcPtr:WordProcPtr) :   
Integer ; Tool $15,$17;                                                         
FUNCTION CautionAlert ( alertTemplatePtr:AlertTemplate;                         
filterProcPtr:WordProcPtr) : Integer ; Tool $15,$1A;                            
PROCEDURE CloseDialog ( theDialogPtr:DialogPtr)  ; Tool $15,$0C;                
FUNCTION DefaultFilter ( theDialogPtr:DialogPtr; theEventPtr:EventRecord;       
itemHitPtr:IntPtr) : Boolean ; Tool $15,$36;                                    
FUNCTION DialogSelect ( theEventPtr:EventRecord;VAR resultPtr:WindowPtr;VAR     
itemHitPtr:Integer) : Boolean ; Tool $15,$11;                                   
PROCEDURE DisableDItem ( theDialogPtr:DialogPtr; itemID:Integer)  ; Tool        
$15,$39;                                                                        
PROCEDURE DlgCopy ( theDialogPtr:DialogPtr)  ; Tool $15,$13;                    
PROCEDURE DlgCut ( theDialogPtr:DialogPtr)  ; Tool $15,$12;                     
PROCEDURE DlgDelete ( theDialogPtr:DialogPtr)  ; Tool $15,$15;                  
PROCEDURE DlgPaste ( theDialogPtr:DialogPtr)  ; Tool $15,$14;                   
PROCEDURE DrawDialog ( theDialogPtr:DialogPtr)  ; Tool $15,$16;                 
PROCEDURE EnableDItem ( theDialogPtr:DialogPtr; itemID:Integer)  ; Tool         
$15,$3A;                                                                        
PROCEDURE ErrorSound ( soundProcPtr:VoidProcPtr)  ; Tool $15,$09;               
FUNCTION FindDItem ( theDialogPtr:DialogPtr; thePoint:Point) : Integer ; Tool   
$15,$24;                                                                        
FUNCTION GetAlertStage  : Integer ; Tool $15,$34;                               
FUNCTION GetControlDItem ( theDialogPtr:DialogPtr; itemID:Integer) : CtlRecHndl 
; Tool $15,$1E;                                                                 
FUNCTION GetDefButton ( theDialogPtr:DialogPtr) : Integer ; Tool $15,$37;       
PROCEDURE GetDItemBox ( theDialogPtr:DialogPtr; itemID:Integer;                 
itemBoxPtr:Rect)  ; Tool $15,$28;                                               
FUNCTION GetDItemType ( theDialogPtr:DialogPtr; itemID:Integer) : Integer ;     
Tool $15,$26;                                                                   
FUNCTION GetDItemValue ( theDialogPtr:DialogPtr; itemID:Integer) : Integer ;    
Tool $15,$2E;                                                                   
FUNCTION GetFirstDItem ( theDialogPtr:DialogPtr) : Integer ; Tool $15,$2A;      
PROCEDURE GetIText ( theDialogPtr:DialogPtr; itemID:Integer;VAR text:Str255)  ; 
Tool $15,$1F;                                                                   
PROCEDURE GetNewDItem ( theDialogPtr:DialogPtr; itemTemplatePtr:ItemTemplate)   
; Tool $15,$33;                                                                 
FUNCTION GetNewModalDialog ( dialogTemplatePtr:DlgTempPtr) : DialogPtr ; Tool   
$15,$32;                                                                        
FUNCTION GetNextDItem ( theDialogPtr:DialogPtr; itemID:Integer) : Integer ;     
Tool $15,$2B;                                                                   
PROCEDURE HideDItem ( theDialogPtr:DialogPtr; itemID:Integer)  ; Tool $15,$22;  
FUNCTION IsDialogEvent ( theEventPtr:EventRecord) : Boolean ; Tool $15,$10;     
FUNCTION ModalDialog ( filterProcPtr:WordProcPtr) : Integer ; Tool $15,$0F;     
FUNCTION ModalDialog2 ( filterProcPtr:WordProcPtr) : Longint ; Tool $15,$2C;    
PROCEDURE NewDItem ( theDialogPtr:DialogPtr; itemID:Integer; itemRectPtr:Rect;  
itemType:Integer; itemDescr:Ptr; itemValue:Integer; itemFlag:Integer;           
itemColorPtr:Ptr)  ; Tool $15,$0D;                                              
FUNCTION NewModalDialog ( dBoundsRectPtr:Rect; dVisibleFlag:Boolean;            
dRefCon:Longint) : DialogPtr ; Tool $15,$0A;                                    
FUNCTION NewModelessDialog ( dBoundsRectPtr:Rect; dTitle:Str255;                
dBehindPtr:DialogPtr; dFlag:Integer; dRefCon:Longint; dFullSizePtr:Rect) :      
DialogPtr ; Tool $15,$0B;                                                       
FUNCTION NoteAlert ( alertTemplatePtr:AlertTempPtr; filterProcPtr:WordProcPtr)  
: Integer ; Tool $15,$19;                                                       
PROCEDURE ParamText ( param0:Str255; param1:Str255; param2:Str255;              
param3:Str255)  ; Tool $15,$1B;                                                 
PROCEDURE RemoveDItem ( theDialogPtr:DialogPtr; itemID:Integer)  ; Tool         
$15,$0E;                                                                        
PROCEDURE ResetAlertStage   ; Tool $15,$35;                                     
PROCEDURE SelIText ( theDialogPtr:DialogPtr; itemID:Integer; startSel:Integer;  
endSel:Integer)  ; Tool $15,$21;                                                
PROCEDURE SelectIText ( theDialogPtr:DialogPtr; itemID:Integer;                 
startSel:Integer; endSel:Integer)  ; Tool $15,$21;                              
PROCEDURE SetDAFont ( fontHandle:FontHndl)  ; Tool $15,$1C;                     
PROCEDURE SetDefButton ( defButtonID:Integer; theDialogPtr:DialogPtr)  ; Tool   
$15,$38;                                                                        
PROCEDURE SetDItemBox ( theDialogPtr:DialogPtr; itemID:Integer;                 
itemBoxPtr:Rect)  ; Tool $15,$29;                                               
PROCEDURE SetDItemType ( itemType:Integer; theDialogPtr:DialogPtr;              
itemID:Integer)  ; Tool $15,$27;                                                
PROCEDURE SetDItemValue ( itemValue:Integer; theDialogPtr:DialogPtr;            
itemID:Integer)  ; Tool $15,$2F;                                                
PROCEDURE SetIText ( theDialogPtr:DialogPtr; itemID:Integer; theString:Str255)  
; Tool $15,$20;                                                                 
PROCEDURE ShowDItem ( theDialogPtr:DialogPtr; itemID:Integer)  ; Tool $15,$23;  
FUNCTION StopAlert ( alertTemplatePtr:AlertTempPtr; filterProcPtr:WordProcPtr)  
: Integer ; Tool $15,$18;                                                       
PROCEDURE UpdateDialog ( theDialogPtr:DialogPtr; updateRgnHandle:RgnHandle)  ;  
Tool $15,$25;                                                                   
IMPLEMENTATION                                                                  
END.                                                                            
