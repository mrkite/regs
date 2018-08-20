{********************************************                                   
; File: Resources.p                                                             
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT RESOURCES;                                                                 
INTERFACE                                                                       
USES TYPES,MEMORY,GSOS;                                                         
CONST                                                                           
                                                                                
resLogOut = $0; {ResourceConverter -  }                                         
resLogIn = $1; {ResourceConverter -  }                                          
resLogApp = $0; {ResourceConverter -  }                                         
resLogSys = $2; {ResourceConverter -  }                                         
                                                                                
(* *** Toolset Errors ***                                                       
resForkUsed = $1E01; {Error - Resource fork not empty }                         
resBadFormat = $1E02; {Error - Format of resource fork is unknown }             
resForkEmpty = $1E03; {Error - Resource fork is empty }                         
resNoCurFile = $1E04; {Error - there are no current open resource files }       
resDupID = $1E05; {Error - ID is already used }                                 
resNotFound = $1E06; {Error - resource was not found }                          
resFileNotFound = $1E07; {Error - resource file not found }                     
resBadAppID = $1E08; {Error - User ID not found, please call ResourceStartup }  
resNoUniqueID = $1E09; {Error - a unique ID was not found }                     
resBadAttr = $1E0A; {Error - reseved bits in attributes word are not zero }     
resHashGone = $1E0B; {Error - the hash count table is no longer valid }         
resIndexRange = $1E0D; {Error - index is out of range }                         
resNoCurApp = $1E0E; {Error - no current application, please call               
ResourceStartup }                                                               
   *** Toolset Errors *** *)                                                    
                                                                                
resChanged = $0020; {Resources -  }                                             
resPreLoad = $0040; {Resources -  }                                             
resProtected = $0080; {Resources -  }                                           
resAbsLoad = $0400; {Resources -  }                                             
resConverter = $0800; {Resources -  }                                           
resMemAttr = $C3F1; {Resources -  }                                             
systemMap = $0001; {Resources -  }                                              
mapChanged = $0002; {Resources -  }                                             
romMap = $0004; {Resources -  }                                                 
resNameOffset = $10000; {Resources - type holding names }                       
resNameVersion = $0001; {Resources -  }                                         
rIcon = $8001; {Resources - resource type holding names }                       
rPicture = $8002; {Resources - resource type holding names }                    
rControlList = $8003; {Resources - resource type holding names }                
rControlTemplate = $8004; {Resources - resource type holding names }            
rWindow = $8005; {Resources - resource type holding names }                     
rString = $8006; {Resources - resource type holding names }                     
rStringList = $8007; {Resources - resource type holding names }                 
rMenuBar = $8008; {Resources - resource type holding names }                    
rMenu = $8009; {Resources - resource type holding names }                       
rMenuItem = $800A; {Resources - resource type holding names }                   
rTextForLETextBox2 = $800B; {Resources - resource type holding names }          
rCtlDefProc = $800C; {Resources - resource type holding names }                 
rCtlColorTbl = $800D; {Resources - resource type holding names }                
rWindParam1 = $800E; {Resources - resource type holding names }                 
rWindParam2 = $800F; {Resources - resource type holding names }                 
rWindColor = $8010; {Resources - resource type holding names }                  
rResName = $8014; {Resources - resource type holding names }                    
                                                                                
TYPE                                                                            
ResID = Longint ;                                                               
ResType = Integer ;                                                             
ResAttr = Integer ;                                                             
                                                                                
                                                                                
ResHeaderRec = RECORD                                                           
    rFileVersion : Longint; { Format version of resource fork }                 
    rFileToMap : Longint; { Offset from start to resource map record }          
    rFileMapSize : Longint; { Number of bytes map occupies in file }            
    rFileMemo : PACKED ARRAY[1..128] OF Byte; { Reserved space for application  
}                                                                               
    rFileRecSize : Longint; { Size of ResHeaderRec Record }                     
END;                                                                            
FreeBlockRec = RECORD                                                           
    blkOffset : Longint;                                                        
    blkSize : Longint;                                                          
END;                                                                            
ResMapHandle = ^ResMapPtr;                                                      
ResMapPtr = ^ResMap;                                                            
ResMap = RECORD                                                                 
    mapNext : ResMapHandle; { Handle to next resource map }                     
    mapFlag : Integer; { Bit Flags }                                            
    mapOffset : Longint; { Map's file position }                                
    mapSize : Longint; { Number of bytes map occupies in file }                 
    mapToIndex : Integer;                                                       
    mapFileNum : Integer;                                                       
    mapID : Integer;                                                            
    mapIndexSize : Longint;                                                     
    mapIndexUsed : Longint;                                                     
    mapFreeListSize : Integer;                                                  
    mapFreeListUsed : Integer;                                                  
    mapFreeList : ARRAY[1..1] OF FreeBlockRec; { n bytes (array of free block   
records) }                                                                      
END;                                                                            
ResRefRecPtr = ^ResRefRec;                                                      
ResRefRec = RECORD                                                              
    fResType : ResType;                                                         
    fResID : ResID;                                                             
    fResOffset : Longint;                                                       
    fResAttr : ResAttr;                                                         
    fResSize : Longint;                                                         
    fResHandle : Handle;                                                        
END;                                                                            
ResourceSpec = RECORD                                                           
    resourceType : ResType;                                                     
    resourceID : ResID;                                                         
END;                                                                            
ResNameEntryPtr = ^ResNameEntry;                                                
ResNameEntry = RECORD                                                           
    namedResID : ResID;                                                         
    resName : Str255;                                                           
END;                                                                            
ResNameRecordHandle = ^ResNameRecordPtr;                                        
ResNameRecordPtr = ^ResNameRecord;                                              
ResNameRecord = RECORD                                                          
    version : Integer;                                                          
    nameCount : Longint;                                                        
    resNameEntries : ARRAY[1..1] OF ResNameEntry;                               
END;                                                                            
PROCEDURE ResourceBootInit   ; Tool $1E,$01;                                    
PROCEDURE ResourceStartup ( userID:Integer)  ; Tool $1E,$02;                    
PROCEDURE ResourceShutdown   ; Tool $1E,$03;                                    
FUNCTION ResourceVersion  : Integer ; Tool $1E,$04;                             
PROCEDURE ResourceReset   ; Tool $1E,$05;                                       
FUNCTION ResourceStatus  : Boolean ; Tool $1E,$06;                              
PROCEDURE AddResource ( resourceHandle:Handle; resourceAttr:ResAttr;            
resourceType:ResType; resourceID:ResID)  ; Tool $1E,$0C;                        
PROCEDURE CloseResourceFile ( fileID:Integer)  ; Tool $1E,$0B;                  
FUNCTION CountResources ( resourceType:ResType) : Longint ; Tool $1E,$22;       
FUNCTION CountTypes  : Integer ; Tool $1E,$20;                                  
PROCEDURE CreateResourceFile ( auxType:Longint; fileType:Integer;               
fileAccess:Integer; fileName:GSString255Ptr)  ; Tool $1E,$09;                   
PROCEDURE DetachResource ( resourceType:ResType; resourceID:ResID)  ; Tool      
$1E,$18;                                                                        
FUNCTION GetCurResourceApp  : Integer ; Tool $1E,$14;                           
FUNCTION GetCurResourceFile  : Integer ; Tool $1E,$12;                          
FUNCTION GetIndResource ( resourceType:ResType; resourceIndex:Longint) : ResID  
; Tool $1E,$23;                                                                 
FUNCTION GetIndType ( typeIndex:Integer) : ResType ; Tool $1E,$21;              
FUNCTION GetMapHandle ( fileID:Integer) : ResMapHandle ; Tool $1E,$26;          
FUNCTION GetOpenFileRefNum ( fileID:Integer) : Integer ; Tool $1E,$1F;          
FUNCTION GetResourceAttr ( resourceType:ResType; resourceID:ResID) : ResAttr ;  
Tool $1E,$1B;                                                                   
FUNCTION GetResourceSize ( resourceType:ResType; currentID:ResID) : Longint ;   
Tool $1E,$1D;                                                                   
FUNCTION HomeResourceFile ( resourceType:ResType; resourceID:ResID) : Integer ; 
Tool $1E,$15;                                                                   
FUNCTION LoadAbsResource ( loadAddress:Longint; maxSize:Longint;                
resourceType:ResType; resourceID:ResID) : Handle ; Tool $1E,$27;                
FUNCTION LoadResource ( resourceType:ResType; resourceID:ResID) : Handle ; Tool 
$1E,$0E;                                                                        
PROCEDURE MarkResourceChange ( U__changeFlag:Boolean; resourceType:ResType;     
resourceID:ResID)  ; Tool $1E,$10;                                              
PROCEDURE MatchResourceHandle ( foundRec:Ptr; resourceHandle:Handle)  ; Tool    
$1E,$1E;                                                                        
FUNCTION OpenResourceFile ( openAccess:Integer; resourceMapPtr:ResMapPtr;       
fileName:GSString255Ptr) : Integer ; Tool $1E,$0A;                              
PROCEDURE ReleaseResource ( purgeLevel:Integer; resourceType:ResType;           
resourceID:ResID)  ; Tool $1E,$17;                                              
PROCEDURE RemoveResource ( resourceType:ResType; resourceID:ResID)  ; Tool      
$1E,$0F;                                                                        
PROCEDURE ResourceConverter ( converterProc:ProcPtr; resourceType:ResType;      
logFlags:Integer)  ; Tool $1E,$28;                                              
PROCEDURE SetCurResourceApp ( userID:Integer)  ; Tool $1E,$13;                  
PROCEDURE SetCurResourceFile ( fileID:Integer)  ; Tool $1E,$11;                 
PROCEDURE SetResourceAttr ( resourceAttr:ResAttr; resourceType:ResType;         
currentID:ResID)  ; Tool $1E,$1C;                                               
FUNCTION SetResourceFileDepth ( searchDepth:Integer) : Integer ; Tool $1E,$25;  
PROCEDURE SetResourceID ( newID:ResID; resourceType:ResType; currentID:ResID)   
; Tool $1E,$1A;                                                                 
FUNCTION SetResourceLoad ( readFlag:Integer) : Integer ; Tool $1E,$24;          
FUNCTION UniqueResourceID ( IDrange:Integer; resourceType:ResType) : ResID ;    
Tool $1E,$19;                                                                   
PROCEDURE UpdateResourceFile ( fileID:Integer)  ; Tool $1E,$0D;                 
PROCEDURE WriteResource ( resourceType:ResType; resourceID:ResID)  ; Tool       
$1E,$16;                                                                        
IMPLEMENTATION                                                                  
END.                                                                            
