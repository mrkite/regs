{********************************************                                   
; File: AppleShareFST.p                                                         
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT APPLESHAREFST;                                                             
INTERFACE                                                                       
USES TYPES,GSOS;                                                                
CONST                                                                           
                                                                                
ASBufferControl = $0001; {Command Number -  }                                   
ASByteRangeLock = $0002; {Command Number -  }                                   
ASSpecialOpenFork = $0003; {Command Number -  }                                 
ASGetPrivileges = $0004; {Command Number -  }                                   
ASSetPrivileges = $0005; {Command Number -  }                                   
ASUserInfo = $0006; {Command Number -  }                                        
ASCopyFile = $0007; {Command Number -  }                                        
ASGetUserPath = $0008; {Command Number -  }                                     
ASOpenDesktop = $0009; {Command Number -  }                                     
ASCloseDesktop = $000A; {Command Number -  }                                    
ASGetComment = $000B; {Command Number -  }                                      
ASSetComment = $000C; {Command Number -  }                                      
ASGetServerName = $000D; {Command Number -  }                                   
appleShareNetError = $0088; {Error - AppleShare Network Error }                 
unknownUser = $007E; {Error - specified user name not registered }              
unknownGroup = $007F; {Error - specified group name not the name of a group }   
lockRange = $8000; {Mask -  }                                                   
relativeToEOF = $4000; {Mask -  }                                               
seeFolders = $00; {Mask -  }                                                    
seeFiles = $02; {Mask -  }                                                      
makeChanges = $0004; {Mask -  }                                                 
folderOwner = $80; {Mask -  }                                                   
onDesktop = $0001; {File Info Mask -  }                                         
bFOwnAppl = $0002; {File Info Mask - used internally }                          
bFNever = $0010; {File Info Mask - never SwitchLaunch }                         
bFAlways = $0020; {File Info Mask - always SwitchLaunch }                       
shareApplication = $0040; {File Info Mask - set if file is a shareable          
application }                                                                   
fileIsInited = $0100; {File Info Mask - seen by Finder }                        
fileHasChanged = $0200; {File Info Mask - used internally by Finder }           
fileIsBusy = $0400; {File Info Mask - copied from File System busy bit }        
fileNoCopy = $0800; {File Info Mask - not used in 5.0 and later, formally BOZO  
}                                                                               
fileIsSystem = $1000; {File Info Mask - set if file is a system file }          
fileHasBundle = $2000; {File Info Mask -  }                                     
fileIsInvisible = $4000; {File Info Mask -  }                                   
fileIsLocked = $8000; {File Info Mask -  }                                      
inTrashWindow = $FFFD; {Window Info Mask -  }                                   
inDesktopWindow = $FFFE; {Window Info Mask -  }                                 
inDiskWindow = $0000; {Window Info Mask -  }                                    
requestReadAccess = $0000; {accessWord Mask -  }                                
requestWriteAccess = $0002; {accessWord Mask -  }                               
denyReadAccess = $0010; {accessWord Mask -  }                                   
denyWriteAccess = $0020; {accessWord Mask -  }                                  
dataForkNum = $0000; {forkNum Mask -  }                                         
resourceForkNum = $0001; {forkNum Mask -  }                                     
                                                                                
TYPE                                                                            
CommandBlock = RECORD                                                           
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    commandNum : Integer;                                                       
END;                                                                            
BufferControlRecPtr = ^BufferControlRec;                                        
BufferControlRec = RECORD                                                       
    pBlock : CommandBlock;                                                      
    refNum : Integer;                                                           
    flags : Integer;                                                            
END;                                                                            
SpecialOpenForkRecPtr = ^SpecialOpenForkRec;                                    
SpecialOpenForkRec = RECORD                                                     
    pBlock : CommandBlock;                                                      
    pathname : GSString255Ptr;                                                  
    accessMode : Integer;                                                       
    forkNum : Integer;                                                          
END;                                                                            
ByteRangeLockRecPtr = ^ByteRangeLockRec;                                        
ByteRangeLockRec = RECORD                                                       
    pBlock : CommandBlock;                                                      
    referenceNum : Integer;                                                     
    lockFlag : Integer;                                                         
    fileOffset : Longint;                                                       
    rangeLength : Longint;                                                      
    rangeStart : Longint;                                                       
END;                                                                            
GetAccessRightsRecPtr = ^GetAccessRightsRec;                                    
GetAccessRightsRec = PACKED RECORD                                              
    reserved : Byte;                                                            
    world : Byte;                                                               
    group : Byte;                                                               
    owner : Byte;                                                               
END;                                                                            
GetPrivilegesRecPtr = ^GetPrivilegesRec;                                        
GetPrivilegesRec = RECORD                                                       
    pBlock : CommandBlock;                                                      
    pathname : GSString255Ptr;                                                  
    accessRights : GetAccessRightsRec;                                          
    ownerName : ResultBuf255Ptr;                                                
    groupName : ResultBuf255Ptr;                                                
END;                                                                            
SetAccessRightsRecPtr = ^SetAccessRightsRec;                                    
SetAccessRightsRec = PACKED RECORD                                              
    userSummary : Byte;                                                         
    world : Byte;                                                               
    group : Byte;                                                               
    owner : Byte;                                                               
END;                                                                            
SetPrivilegesRecPtr = ^SetPrivilegesRec;                                        
SetPrivilegesRec = RECORD                                                       
    pBlock : CommandBlock;                                                      
    pathname : GSString255Ptr;                                                  
    accessRights : SetAccessRightsRec;                                          
    ownerName : ResultBuf255Ptr;                                                
    groupName : ResultBuf255Ptr;                                                
END;                                                                            
UserInfoRecPtr = ^UserInfoRec;                                                  
UserInfoRec = RECORD                                                            
    pBlock : CommandBlock;                                                      
    deviceNum : Integer;                                                        
    userName : ResultBuf255Ptr;                                                 
    primaryGroupName : ResultBuf255Ptr;                                         
END;                                                                            
CopyFileRecPtr = ^CopyFileRec;                                                  
CopyFileRec = RECORD                                                            
    pBlock : CommandBlock;                                                      
    sourcePathname : GSString255Ptr;                                            
    destPathname : GSString255Ptr;                                              
END;                                                                            
GetUserPathRecPtr = ^GetUserPathRec;                                            
GetUserPathRec = RECORD                                                         
    pBlock : CommandBlock;                                                      
    prefix : ResultBuf255Ptr;                                                   
END;                                                                            
DesktopRecPtr = ^DesktopRec;                                                    
DesktopRec = RECORD                                                             
    pBlock : CommandBlock;                                                      
    desktopRefNum : Integer;                                                    
    pathname : GSString255Ptr;                                                  
END;                                                                            
GetCommentRecPtr = ^GetCommentRec;                                              
GetCommentRec = RECORD                                                          
    pBlock : CommandBlock;                                                      
    desktopRefNum : Integer;                                                    
    pathname : GSString255Ptr;                                                  
    comment : ResultBuf255Ptr;                                                  
END;                                                                            
SetCommentRecPtr = ^SetCommentRec;                                              
SetCommentRec = RECORD                                                          
    pBlock : CommandBlock;                                                      
    desktopRefNum : Integer;                                                    
    pathname : GSString255Ptr;                                                  
    comment : GSString255Ptr;                                                   
END;                                                                            
GetServerNameRecPtr = ^GetServerNameRec;                                        
GetServerNameRec = RECORD                                                       
    pBlock : CommandBlock;                                                      
    pathname : GSString255Ptr;                                                  
    serverName : ResultBuf255Ptr;                                               
    zoneName : ResultBuf255Ptr;                                                 
END;                                                                            
IMPLEMENTATION                                                                  
END.                                                                            
