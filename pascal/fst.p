{********************************************                                   
; File: FST.p                                                                   
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT FST;                                                                       
INTERFACE                                                                       
USES Types,GSOS;                                                                
                                                                                
TYPE                                                                            
BufferControlRecPtr = ^BufferControlRec;                                        
BufferControlRec = RECORD                                                       
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    refNum : Integer;                                                           
    flags : Integer;                                                            
END;                                                                            
SpecialOpenForkRecPtr = ^SpecialOpenForkRec;                                    
SpecialOpenForkRec = RECORD                                                     
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    referenceNum : Integer;                                                     
    pathname : GSString255Ptr;                                                  
    accessMode : Integer;                                                       
    resourceNum : Integer;                                                      
END;                                                                            
ByteRangeLockRecPtr = ^ByteRangeLockRec;                                        
ByteRangeLockRec = RECORD                                                       
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
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
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
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
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    pathname : GSString255Ptr;                                                  
    accessRights : SetAccessRightsRec;                                          
    ownerName : ResultBuf255Ptr;                                                
    groupName : ResultBuf255Ptr;                                                
END;                                                                            
UserInfoRecPtr = ^UserInfoRec;                                                  
UserInfoRec = RECORD                                                            
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    deviceNum : Integer;                                                        
    userName : ResultBuf255Ptr;                                                 
    primaryGroupName : ResultBuf255Ptr;                                         
END;                                                                            
CopyFileRecPtr = ^CopyFileRec;                                                  
CopyFileRec = RECORD                                                            
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    sourcePathname : GSString255Ptr;                                            
    destPathname : GSString255Ptr;                                              
END;                                                                            
GetUserPathRecPtr = ^GetUserPathRec;                                            
GetUserPathRec = RECORD                                                         
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    prefix : ResultBuf255Ptr;                                                   
END;                                                                            
DesktopRecPtr = ^DesktopRec;                                                    
DesktopRec = RECORD                                                             
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    desktopRefNum : Integer;                                                    
    pathname : GSString255Ptr;                                                  
END;                                                                            
GetCommentRecPtr = ^GetCommentRec;                                              
GetCommentRec = RECORD                                                          
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    desktopRefNum : Integer;                                                    
    pathname : GSString255Ptr;                                                  
    comment : ResultBuf255Ptr;                                                  
END;                                                                            
SetCommentRecPtr = ^SetCommentRec;                                              
SetCommentRec = RECORD                                                          
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    desktopRefNum : Integer;                                                    
    pathname : GSString255Ptr;                                                  
    comment : GSString255Ptr;                                                   
END;                                                                            
GetServerNameRecPtr = ^GetServerNameRec;                                        
GetServerNameRec = RECORD                                                       
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    command : Integer;                                                          
    pathname : GSString255Ptr;                                                  
    serverName : ResultBuf255Ptr;                                               
    zoneName : ResultBuf255Ptr;                                                 
END;                                                                            
IMPLEMENTATION                                                                  
END.                                                                            
