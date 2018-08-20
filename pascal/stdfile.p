{********************************************                                   
; File: StdFile.p                                                               
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT STDFILE;                                                                   
INTERFACE                                                                       
USES Types, QuickDraw, Events, Controls, Windows, LineEdit, Dialogs;            
CONST                                                                           
                                                                                
noDisplay = $0000; {filterProc result - file not to be displayed }              
noSelect = $0001; {filterProc result - file displayed, but not selectable }     
displaySelect = $0002; {filterProc result - file displayed and selectable }     
sfMatchFileType = $8000; { -  }                                                 
sfMatchAuxType = $4000; { -  }                                                  
sfDisplayGrey = $2000; { -  }                                                   
                                                                                
TYPE                                                                            
SFReplyRecPtr = ^SFReplyRec;                                                    
SFReplyRec = RECORD                                                             
    good : Boolean;                                                             
    fileType : Integer;                                                         
    auxFileType : Integer;                                                      
    filename : String[15];                                                      
    fullPathname : String[128];                                                 
END;                                                                            
SFReplyRec2Hndl = ^SFReplyRec2Ptr;                                              
SFReplyRec2Ptr = ^SFReplyRec2;                                                  
SFReplyRec2 = RECORD                                                            
    good : Boolean;                                                             
    filetype : Integer;                                                         
    auxType : Longint;                                                          
    nameDesc : RefDescriptor;                                                   
    nameRef : Ref;                                                              
    pathDesc : RefDescriptor;                                                   
    pathRef : Ref;                                                              
END;                                                                            
multiReplyRecord = RECORD                                                       
    good : Integer;                                                             
    namesHandle : Handle;                                                       
END;                                                                            
SFTypeListHandle = ^SFTypeListPtr;                                              
SFTypeListPtr = ^SFTypeList;                                                    
SFTypeList = PACKED RECORD                                                      
    numEntries : Byte;                                                          
    fileTypeEntries : PACKED ARRAY[1..5] OF Byte;                               
END;                                                                            
TypeSelector2 = RECORD                                                          
    flags : Integer;                                                            
    fileType : Integer;                                                         
    auxType : Longint;                                                          
END;                                                                            
SFTypeList2Ptr = ^SFTypeList2;                                                  
SFTypeList2 = RECORD                                                            
    numEntries : Integer;                                                       
    fileTypeEntries : ARRAY[1..5] OF TypeSelector2;                             
END;                                                                            
PROCEDURE SFBootInit   ; Tool $17,$01;                                          
PROCEDURE SFStartUp ( userID:Integer; dPageAddr:Integer)  ; Tool $17,$02;       
PROCEDURE SFShutDown   ; Tool $17,$03;                                          
FUNCTION SFVersion  : Integer ; Tool $17,$04;                                   
PROCEDURE SFReset   ; Tool $17,$05;                                             
FUNCTION SFStatus  : Boolean ; Tool $17,$06;                                    
PROCEDURE SFAllCaps ( allCapsFlag:Boolean)  ; Tool $17,$0D;                     
PROCEDURE SFGetFile                                                             
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFGetFile2                                                            
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFMultiGet2 ( whereX:Integer;                                         
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFPGetFile ( whereX:Integer;                                          
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFPGetFile2 ( whereX:Integer;                                         
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFPMultiGet2 ( whereX:Integer;                                        
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFPPutFile ( whereX:Integer;                                          
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFPPutFile2                                                           
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFPutFile ( whereX:Integer;                                           
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE SFPutFile2 ( whereX:Integer;                                          
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
FUNCTION SFShowInvisible ( invisibleState:Boolean) : Boolean ; Tool $17,$12;    
PROCEDURE SFReScan ( filterProcPtr:ProcPtr; typeListPtr:SFTypeList2Ptr)  ; Tool 
$17,$13;                                                                        
IMPLEMENTATION                                                                  
END.                                                                            
