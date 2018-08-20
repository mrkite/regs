{********************************************                                   
; File: Loader.p                                                                
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT LOADER;                                                                    
INTERFACE                                                                       
USES TYPES;                                                                     
                                                                                
(* *** Toolset Errors ***                                                       
CONST                                                                           
idNotFound = $1101; {error - segment/application/entry not found }              
idNotLoadFile = $1104; {error - file is not a load file }                       
idBusyErr = $1105; {error - system loader is busy }                             
idFilVersErr = $1107; {error - file version error }                             
idUserIDErr = $1108; {error - user ID error }                                   
idSequenceErr = $1109; {error - segnum out of sequence }                        
idBadRecordErr = $110A; {error - illegal load record found }                    
idForeignSegErr = $110B; {error - segment is foreign }                          
   *** Toolset Errors *** *)                                                    
                                                                                
TYPE                                                                            
InitialLoadOutputRecPtr = ^InitialLoadOutputRec;                                
InitialLoadOutputRec = RECORD                                                   
    userID : Integer;                                                           
    startAddr : Ptr;                                                            
    dPageAddr : Integer;                                                        
    buffSize : Integer;                                                         
END;                                                                            
RestartOutRecPtr = ^RestartOutRec;                                              
RestartOutRec = RECORD                                                          
    userID : Integer;                                                           
    startAddr : Ptr;                                                            
    dPageAddr : Integer;                                                        
    buffSize : Integer;                                                         
END;                                                                            
LoadSegNameOutPtr = ^LoadSegNameOut;                                            
LoadSegNameOut = RECORD                                                         
    segAddr : Ptr;                                                              
    fileNum : Integer;                                                          
    segNum : Integer;                                                           
END;                                                                            
UnloadSegOutRecPtr = ^UnloadSegOutRec;                                          
UnloadSegOutRec = RECORD                                                        
    userID : Integer;                                                           
    fileNum : Integer;                                                          
    segNum : Integer;                                                           
END;                                                                            
PROCEDURE LoaderInitialization   ; Tool $11,$01;                                
PROCEDURE LoaderStartUp   ; Tool $11,$02;                                       
PROCEDURE LoaderShutDown   ; Tool $11,$03;                                      
FUNCTION LoaderVersion  : Integer ; Tool $11,$04;                               
PROCEDURE LoaderReset   ; Tool $11,$05;                                         
FUNCTION LoaderStatus  : Boolean ; Tool $11,$06;                                
PROCEDURE GetLoadSegInfo ( userID:Integer; loadFileNum:Integer;                 
loadSegNum:Integer; bufferPtr:Ptr)  ; Tool $11,$0F;                             
FUNCTION GetUserID ( pathNamePtr:Ptr) : Integer ; Tool $11,$10;                 
FUNCTION GetUserID2 ( pathNamePtr:Ptr) : Integer ; Tool $11,$21;                
FUNCTION InitialLoad ( userID:Integer; loadFileNamePtr:Ptr; spMemFlag:Boolean)  
: InitialLoadOutputRec ; EXTERNAL ;                                             
FUNCTION InitialLoad2 ( userID:Integer; loadFileNamePtr:Ptr; spMemFlag:Boolean; 
inputType:Integer) : InitialLoadOutputRec ; EXTERNAL ;                          
FUNCTION LGetPathname ( userID:Integer; fileNumber:Integer) : Ptr ; Tool        
$11,$11;                                                                        
FUNCTION LGetPathname2 ( userID:Integer; fileNumber:Integer) : Ptr ; Tool       
$11,$22;                                                                        
FUNCTION GetPathname ( userID:Integer; fileNumber:Integer) : Ptr ; Tool         
$11,$11;                                                                        
FUNCTION GetPathname2 ( userID:Integer; fileNumber:Integer) : Ptr ; Tool        
$11,$22;                                                                        
PROCEDURE RenamePathname ( oldPathname:Ptr; newPathname:Ptr)  ; Tool $11,$13;   
FUNCTION LoadSegName ( userID:Integer; loadFileNamePtr:Ptr; loadSegNamePtr:Ptr) 
: LoadSegNameOut ; EXTERNAL ;                                                   
FUNCTION LoadSegNum ( userID:Integer; loadFileNum:Integer; loadSegNum:Integer)  
: Ptr ; Tool $11,$0B;                                                           
FUNCTION Restart ( userID:Integer) : RestartOutRec ; EXTERNAL ;                 
FUNCTION UnloadSeg ( segmentPtr:Ptr) : UnloadSegOutRec ; EXTERNAL ;             
PROCEDURE UnloadSegNum ( userID:Integer; loadFileNum:Integer;                   
loadSegNum:Integer)  ; Tool $11,$0C;                                            
FUNCTION UserShutDown ( userID:Integer; restartFlag:Integer) : Integer ; Tool   
$11,$12;                                                                        
IMPLEMENTATION                                                                  
END.                                                                            
