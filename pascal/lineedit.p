{********************************************                                   
; File: LineEdit.p                                                              
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT LINEEDIT;                                                                  
INTERFACE                                                                       
USES TYPES,QUICKDRAW,EVENTS;                                                    
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
leDupStrtUpErr = $1401; {error - duplicate LEStartup call }                     
leResetErr = $1402; {error - can't reset Line Edit }                            
leNotActiveErr = $1403; {error - Line Edit not active }                         
leScrapErr = $1404; {error - desk scrap too big to copy }                       
   *** Toolset Errors *** *)                                                    
                                                                                
leJustLeft = $0000; {Justification -  }                                         
leJustCenter = $0001; {Justification -  }                                       
leJustFill = $0002; {Justification -  }                                         
leJustRight = $FFFF; {Justification -  }                                        
                                                                                
TYPE                                                                            
LERecHndl = ^LERecPtr;                                                          
LERecPtr = ^LERec;                                                              
LERec = RECORD                                                                  
    leLineHandle : Handle;                                                      
    leLength : Integer;                                                         
    leMaxLength : Integer;                                                      
    leDestRect : Rect;                                                          
    leViewRect : Rect;                                                          
    lePort : GrafPortPtr;                                                       
    leLineHite : Integer;                                                       
    leBaseHite : Integer;                                                       
    leSelStart : Integer;                                                       
    leSelEnd : Integer;                                                         
    leActFlg : Integer;                                                         
    leCarAct : Integer;                                                         
    leCarOn : Integer;                                                          
    leCarTime : Longint;                                                        
    leHiliteHook : VoidProcPtr;                                                 
    leCaretHook : VoidProcPtr;                                                  
    leJust : Integer;                                                           
    lePWChar : Integer;                                                         
END;                                                                            
PROCEDURE LEBootInit   ; Tool $14,$01;                                          
PROCEDURE LEStartUp ( userID:Integer; dPageAddr:Integer)  ; Tool $14,$02;       
PROCEDURE LEShutDown   ; Tool $14,$03;                                          
FUNCTION LEVersion  : Integer ; Tool $14,$04;                                   
PROCEDURE LEReset   ; Tool $14,$05;                                             
FUNCTION LEStatus  : Boolean ; Tool $14,$06;                                    
PROCEDURE LEActivate ( leRecHandle:LERecHndl)  ; Tool $14,$0F;                  
PROCEDURE LEClick ( eventPtr:EventRecord; leRecHandle:LERecHndl)  ; Tool        
$14,$0D;                                                                        
PROCEDURE LECopy ( leRecHandle:LERecHndl)  ; Tool $14,$13;                      
PROCEDURE LECut ( leRecHandle:LERecHndl)  ; Tool $14,$12;                       
PROCEDURE LEDeactivate ( leRecHandle:LERecHndl)  ; Tool $14,$10;                
PROCEDURE LEDelete ( leRecHandle:LERecHndl)  ; Tool $14,$15;                    
PROCEDURE LEDispose ( leRecHandle:LERecHndl)  ; Tool $14,$0A;                   
PROCEDURE LEFromScrap   ; Tool $14,$19;                                         
FUNCTION LEGetScrapLen  : Integer ; Tool $14,$1C;                               
FUNCTION LEGetTextHand ( leRecHandle:LERecHndl) : Handle ; Tool $14,$22;        
FUNCTION LEGetTextLen ( leRecHandle:LERecHndl) : Integer ; Tool $14,$23;        
PROCEDURE LEIdle ( leRecHandle:LERecHndl)  ; Tool $14,$0C;                      
PROCEDURE LEInsert ( textPtr:Ptr; textLength:Integer; leRecHandle:LERecHndl)  ; 
Tool $14,$16;                                                                   
PROCEDURE LEKey ( theKey:CHAR; modifiers:Integer; leRecHandle:LERecHndl)  ;     
Tool $14,$11;                                                                   
FUNCTION LENew ( destRectPtr:Rect; viewRectPtr:Rect; maxTextLen:Integer) :      
LERecHndl ; Tool $14,$09;                                                       
PROCEDURE LEPaste ( leRecHandle:LERecHndl)  ; Tool $14,$14;                     
FUNCTION LEScrapHandle  : Handle ; Tool $14,$1B;                                
PROCEDURE LESetCaret ( caretProcPtr:VoidProcPtr; leRecHandle:LERecHndl)  ; Tool 
$14,$1F;                                                                        
PROCEDURE LESetHilite ( hiliteProcPtr:VoidProcPtr; leRecHandle:LERecHndl)  ;    
Tool $14,$1E;                                                                   
PROCEDURE LESetJust ( just:Integer; leRecHandle:LERecHndl)  ; Tool $14,$21;     
PROCEDURE LESetScrapLen ( newLength:Integer)  ; Tool $14,$1D;                   
PROCEDURE LESetSelect ( selStart:Integer; selEnd:Integer;                       
leRecHandle:LERecHndl)  ; Tool $14,$0E;                                         
PROCEDURE LESetText ( textPtr:Ptr; textLength:Integer; leRecHandle:LERecHndl)   
; Tool $14,$0B;                                                                 
PROCEDURE LETextBox ( textPtr:Ptr; textLength:Integer; rectPtr:Rect;            
just:Integer)  ; Tool $14,$18;                                                  
PROCEDURE LETextBox2 ( textPtr:Ptr; textLength:Integer; rectPtr:Rect;           
just:Integer)  ; Tool $14,$20;                                                  
PROCEDURE LEToScrap   ; Tool $14,$1A;                                           
PROCEDURE LEUpdate ( leRecHandle:LERecHndl)  ; Tool $14,$17;                    
FUNCTION GetLEDefProc  : Ptr ; Tool $14,$24;                                    
IMPLEMENTATION                                                                  
END.                                                                            
