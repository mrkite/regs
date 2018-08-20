{********************************************                                   
; File: Memory.p                                                                
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT MEMORY;                                                                    
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
memErr = $0201; {error - unable to allocate block }                             
emptyErr = $0202; {error - illegal operation, empty handle }                    
notEmptyErr = $0203; {error - an empty handle was expected for this operation } 
lockErr = $0204; {error - illegal operation on a locked block }                 
purgeErr = $0205; {error - attempt to purge an unpurgable block }               
handleErr = $0206; {error - an invalid handle was given }                       
idErr = $0207; {error - an invalid owner ID was given }                         
attrErr = $0208; {error - operation illegal on block with given attributes }    
   *** Toolset Errors *** *)                                                    
                                                                                
attrNoPurge = $0000; {Handle Attribute Bits - Not purgeable }                   
attrBank = $0001; {Handle Attribute Bits - fixed bank }                         
attrAddr = $0002; {Handle Attribute Bits - fixed address }                      
attrPage = $0004; {Handle Attribute Bits - page aligned }                       
attrNoSpec = $0008; {Handle Attribute Bits - may not use special memory }       
attrNoCross = $0010; {Handle Attribute Bits - may not cross banks }             
attrPurge1 = $0100; {Handle Attribute Bits - Purge level 1 }                    
attrPurge2 = $0200; {Handle Attribute Bits - Purge level 2 }                    
attrPurge3 = $0300; {Handle Attribute Bits - Purge level 3 }                    
attrPurge = $0300; {Handle Attribute Bits - test or set both purge bits }       
attrHandle = $1000; {Handle Attribute Bits - block of master pointers }         
attrSystem = $2000; {Handle Attribute Bits - system handle }                    
attrFixed = $4000; {Handle Attribute Bits - not movable }                       
attrLocked = $8000; {Handle Attribute Bits - locked }                           
PROCEDURE MMBootInit   ; Tool $02,$01;                                          
FUNCTION MMStartUp  : Integer ; Tool $02,$02;                                   
PROCEDURE MMShutDown ( userID:Integer)  ; Tool $02,$03;                         
FUNCTION MMVersion  : Integer ; Tool $02,$04;                                   
PROCEDURE MMReset   ; Tool $02,$05;                                             
FUNCTION MMStatus  : Boolean ; Tool $02,$06;                                    
PROCEDURE BlockMove ( srcPtr:Ptr; dstPtr:Ptr; count:Longint)  ; Tool $02,$2B;   
PROCEDURE CheckHandle ( theHandle:Handle)  ; Tool $02,$1E;                      
PROCEDURE CompactMem   ; Tool $02,$1F;                                          
PROCEDURE DisposeAll ( userID:Integer)  ; Tool $02,$11;                         
PROCEDURE DisposeHandle ( theHandle:Handle)  ; Tool $02,$10;                    
FUNCTION FindHandle ( locationPtr:Ptr) : Handle ; Tool $02,$1A;                 
FUNCTION FreeMem  : Longint ; Tool $02,$1B;                                     
FUNCTION GetHandleSize ( theHandle:Handle) : Longint ; Tool $02,$18;            
PROCEDURE HandToHand ( sourceHandle:Handle; destHandle:Handle; count:Longint)   
; Tool $02,$2A;                                                                 
PROCEDURE HandToPtr ( sourceHandle:Handle; destPtr:Ptr; count:Longint)  ; Tool  
$02,$29;                                                                        
PROCEDURE HLock ( theHandle:Handle)  ; Tool $02,$20;                            
PROCEDURE HLockAll ( userID:Integer)  ; Tool $02,$21;                           
PROCEDURE HUnlock ( theHandle:Handle)  ; Tool $02,$22;                          
PROCEDURE HUnlockAll ( userID:Integer)  ; Tool $02,$23;                         
FUNCTION MaxBlock  : Longint ; Tool $02,$1C;                                    
FUNCTION NewHandle ( blockSize:Longint; userID:Integer; attributes:Integer;     
locationPtr:Ptr) : Handle ; Tool $02,$09;                                       
PROCEDURE PtrToHand ( sourcePtr:Ptr; destHandle:Handle; count:Longint)  ; Tool  
$02,$28;                                                                        
PROCEDURE PurgeAll ( userID:Integer)  ; Tool $02,$13;                           
PROCEDURE PurgeHandle ( theHandle:Handle)  ; Tool $02,$12;                      
FUNCTION RealFreeMem  : Longint ; Tool $02,$2F;                                 
PROCEDURE ReallocHandle ( blockSize:Longint; userID:Integer;                    
attributes:Integer; locationPtr:Ptr; theHandle:Handle)  ; Tool $02,$0A;         
PROCEDURE RestoreHandle ( theHandle:Handle)  ; Tool $02,$0B;                    
PROCEDURE SetHandleSize ( newSize:Longint; theHandle:Handle)  ; Tool $02,$19;   
PROCEDURE SetPurge ( newPurgeLevel:Integer; theHandle:Handle)  ; Tool $02,$24;  
PROCEDURE SetPurgeAll ( newPurgeLevel:Integer; userID:Integer)  ; Tool $02,$25; 
FUNCTION TotalMem  : Longint ; Tool $02,$1D;                                    
PROCEDURE AddToOOMQueue ( headerPtr:Ptr)  ; Tool $02,$0C;                       
PROCEDURE DeleteFromOOMQueue ( headerPtr:Ptr)  ; Tool $02,$0D;                  
IMPLEMENTATION                                                                  
END.                                                                            
