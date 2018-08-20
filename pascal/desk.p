{********************************************                                   
; File: Desk.p                                                                  
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT DESK;                                                                      
INTERFACE                                                                       
USES TYPES,QUICKDRAW,EVENTS;                                                    
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
daNotFound = $0510; {error - desk accessory not found }                         
notSysWindow = $0511; {error - not the system window }                          
   *** Toolset Errors *** *)                                                    
                                                                                
eventAction = $0001; {NDA action code -  }                                      
runAction = $0002; {NDA action code -  }                                        
undoAction = $0005; {NDA action code -  }                                       
cutAction = $0006; {NDA action code -  }                                        
copyAction = $0007; {NDA action code -  }                                       
pasteAction = $0008; {NDA action code -  }                                      
clearAction = $0009; {NDA action code -  }                                      
cursorAction = $0003; {NDAaction code -  }                                      
kUndo = $0001; {System Edit - edit type }                                       
kCut = $0002; {System Edit - edit type }                                        
kCopy = $0003; {System Edit - edit type }                                       
kPaste = $0004; {System Edit - edit type }                                      
kClear = $0005; {System Edit - edit type }                                      
PROCEDURE DeskBootInit   ; Tool $05,$01;                                        
PROCEDURE DeskStartUp   ; Tool $05,$02;                                         
PROCEDURE DeskShutDown   ; Tool $05,$03;                                        
FUNCTION DeskVersion  : Integer ; Tool $05,$04;                                 
PROCEDURE DeskReset   ; Tool $05,$05;                                           
FUNCTION DeskStatus  : Boolean ; Tool $05,$06;                                  
PROCEDURE ChooseCDA   ; Tool $05,$11;                                           
PROCEDURE CloseAllNDAs   ; Tool $05,$1D;                                        
PROCEDURE CloseNDA ( refNum:Integer)  ; Tool $05,$16;                           
PROCEDURE CloseNDAByWinPtr ( theWindowPtr:GrafPortPtr)  ; Tool $05,$1C;         
PROCEDURE FixAppleMenu ( startingID:Integer)  ; Tool $05,$1E;                   
FUNCTION GetDAStrPtr  : Ptr ; Tool $05,$14;                                     
FUNCTION GetNumNDAs  : Integer ; Tool $05,$1B;                                  
PROCEDURE InstallCDA ( idHandle:Handle)  ; Tool $05,$0F;                        
PROCEDURE InstallNDA ( idHandle:Handle)  ; Tool $05,$0E;                        
FUNCTION OpenNDA ( idNum:Integer) : Integer ; Tool $05,$15;                     
PROCEDURE RestAll   ; Tool $05,$0C;                                             
PROCEDURE RestScrn   ; Tool $05,$0A;                                            
PROCEDURE SaveAll   ; Tool $05,$0B;                                             
PROCEDURE SaveScrn   ; Tool $05,$09;                                            
PROCEDURE SetDAStrPtr ( altDispHandle:Handle; stringTablePtr:Ptr)  ; Tool       
$05,$13;                                                                        
PROCEDURE SystemClick ( eventRecPtr:EventRecord; theWindowPtr:GrafPortPtr;      
findWndwResult:Integer)  ; Tool $05,$17;                                        
FUNCTION SystemEdit ( editType:Integer) : Boolean ; Tool $05,$18;               
FUNCTION SystemEvent ( eventWhat:Integer; eventMessage:Longint;                 
eventWhen:Longint; eventWhere:Point; eventMods:Integer) : Boolean ; Tool        
$05,$1A;                                                                        
PROCEDURE SystemTask   ; Tool $05,$19;                                          
PROCEDURE AddToRunQ ( headerPtr:Ptr)  ; Tool $05,$1F;                           
PROCEDURE RemoveFromRunQ ( headerPtr:Ptr)  ; Tool $05,$20;                      
PROCEDURE RemoveCDA ( idHandle:Handle)  ; Tool $05,$21;                         
PROCEDURE RemoveNDA ( idHandle:Handle)  ; Tool $05,$22;                         
IMPLEMENTATION                                                                  
END.                                                                            
