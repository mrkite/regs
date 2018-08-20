{********************************************                                   
; File: Lists.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT LISTS;                                                                     
INTERFACE                                                                       
USES TYPES,QUICKDRAW,EVENTS,CONTROLS;                                           
CONST                                                                           
                                                                                
cString = $0001; {ListType bit mask - null terminated string type }             
LIST_STRG = $0001; {ListType bit mask - null terminated string type }           
selectOnlyOne = $0002; {ListType bit mask - only one selection allowed }        
LIST_SELECT = $0002; {ListType bit mask - single selection only }               
memDisabled = $40; {memFlag - Sets member flag to disabled }                    
memSelected = $80; {memFlag - Sets member flag to selected }                    
                                                                                
TYPE                                                                            
LColorTableHndl = ^LColorTablePtr;                                              
LColorTablePtr = ^LColorTable;                                                  
LColorTable = RECORD                                                            
    listFrameClr : Integer; { Frame color }                                     
    listNorTextClr : Integer; { Unhighlighted text color }                      
    listSelTextClr : Integer; { Highlighted text color }                        
    listNorBackClr : Integer; { Unhighlighted background color }                
    listSelBackClr : Integer; { Highlighted backgraound color }                 
END;                                                                            
MemRecHndl = ^MemRecPtr;                                                        
MemRecPtr = ^MemRec;                                                            
MemRec = PACKED RECORD                                                          
    memPtr : Ptr; { Pointer to string, or custom }                              
    memFlag : Byte; { Bit Flag }                                                
END;                                                                            
ListCtlRecHndl = ^ListCtlRecPtr;                                                
ListCtlRecPtr = ^ListCtlRec;                                                    
ListCtlRec = PACKED RECORD                                                      
    ctlNext : CtlRecHndl; { Handle of Next Control }                            
    ctlOwner : GrafPortPtr; { Window owner }                                    
    ctlRect : Rect; { Enclosing Rect }                                          
    ctlFlag : Byte; { Bit 7 visible, Bit 0 string type, Bit 1 multiple }        
    ctlHilite : Byte; { (not used) }                                            
    ctlValue : Integer; { First member in display }                             
    ctlProc : LongProcPtr; { Address of list definition procedure }             
    ctlAction : LongProcPtr; { Address of list action procedure }               
    ctlData : Longint; { Low = view size, High = total members }                
    ctlRefCon : Longint; { Not used }                                           
    ctlColor : LColorTablePtr; { Null for default colors }                      
    ctlMemDraw : VoidProcPtr; { Address of routine to draw members }            
    ctlMemHeight : Integer; { Member's Height in Pixels }                       
    ctlMemSize : Integer; { Bytes in member record }                            
    ctlList : MemRecPtr; { Adress of first member record in array }             
    ctlListBar : CtlRecHndl; { Handle of list contrlo's scroll bar control }    
END;                                                                            
ListRecHndl = ^ListRecPtr;                                                      
ListRecPtr = ^ListRec;                                                          
ListRec = RECORD                                                                
    listRect : Rect; { Enclosing Rectangle }                                    
    listSize : Integer; { Number of List Members }                              
    listView : Integer; { Max Viewable members }                                
    listType : Integer; { Bit Flag }                                            
    listStart : Integer; { First member in view }                               
    listCtl : CtlRecHndl; { List control's handle }                             
    listDraw : VoidProcPtr; { Address of Custom drawing routine }               
    listMemHeight : Integer; { Height of list members }                         
    listMemSize : Integer; { Size of Member Records }                           
    listPointer : MemRecPtr; { Pointer to first element in MemRec array }       
    listRefCon : Longint; { becomes Control's refCon }                          
    listScrollClr : BarColorsPtr; { Color table for list's scroll bar }         
END;                                                                            
PROCEDURE ListBootInit   ; Tool $1C,$01;                                        
PROCEDURE ListStartup   ; Tool $1C,$02;                                         
PROCEDURE ListShutDown   ; Tool $1C,$03;                                        
FUNCTION ListVersion  : Integer ; Tool $1C,$04;                                 
PROCEDURE ListReset   ; Tool $1C,$05;                                           
FUNCTION ListStatus  : Boolean ; Tool $1C,$06;                                  
FUNCTION CreateList ( theWindowPtr:WindowPtr; U__listRecPtr:ListRecPtr) :       
ListCtlRecHndl ; Tool $1C,$09;                                                  
PROCEDURE DrawMember ( memberPtr:MemRecPtr; U__listRecPtr:ListRecPtr)  ; Tool   
$1C,$0C;                                                                        
FUNCTION GetListDefProc  : LongProcPtr ; Tool $1C,$0E;                          
PROCEDURE NewList ( memberPtr:MemRecPtr; U__listRecPtr:ListRecPtr)  ; Tool      
$1C,$10;                                                                        
FUNCTION NextMember ( memberPtr:MemRecPtr; U__listRecPtr:ListRecPtr) :          
MemRecPtr ; Tool $1C,$0B;                                                       
FUNCTION ResetMember ( U__listRecPtr:ListRecPtr) : MemRecPtr ; Tool $1C,$0F;    
PROCEDURE SelectMember ( memberPtr:MemRecPtr; U__listRecPtr:ListRecPtr)  ; Tool 
$1C,$0D;                                                                        
PROCEDURE SortList ( comparePtr:VoidProcPtr; U__listRecPtr:ListRecPtr)  ; Tool  
$1C,$0A;                                                                        
PROCEDURE DrawMember2 ( itemNumber:Integer; ctlHandle:CtlRecHndl)  ; Tool       
$1C,$11;                                                                        
FUNCTION NextMember2 ( itemNumber:Integer; ctlHandle:CtlRecHndl) : Integer ;    
Tool $1C,$12;                                                                   
FUNCTION ResetMember2 ( ctlHandle:CtlRecHndl) : Integer ; Tool $1C,$13;         
PROCEDURE SelectMember2 ( itemNumber:Integer; ctlHandle:CtlRecHndl)  ; Tool     
$1C,$14;                                                                        
PROCEDURE SortList2 ( comparePtr:Ptr; ctlHandle:CtlRecHndl)  ; Tool $1C,$15;    
PROCEDURE NewList2 ( drawProcPtr:ProcPtr; listStart:Integer; listRef:Ref;       
listRefDesc:RefDescriptor; listSize:Integer; ctlHandle:CtlRecHndl)  ; Tool      
$1C,$16;                                                                        
IMPLEMENTATION                                                                  
END.                                                                            
