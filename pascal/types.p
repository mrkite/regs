{********************************************                                   
; File: Types.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT TYPES;                                                                     
INTERFACE                                                                       
                                                                                
CONST                                                                           
noError = $0000;                                                                
                                                                                
refIsPointer = $0000; {RefDescriptor -  }                                       
refIsHandle = $0001; {RefDescriptor -  }                                        
refIsResource = $0002; {RefDescriptor -  }                                      
refIsNewHandle = $0003; {RefDescriptor -  }                                     
                                                                                
TYPE                                                                            
Byte = 0..255;                                                                  
Fixed = Longint ;                                                               
Frac = Longint ;                                                                
ExtendedPtr = ^Extended;                                                        
                                                                                
SignedByte = -128..127;                                                         
PackedByte = PACKED ARRAY [1..1] of SignedByte;                                 
Ptr = ^PackedByte;                                                              
PointerPtr = ^Ptr;                                                              
Handle = ^Ptr;                                                                  
                                                                                
HandlePtr = ^Handle;                                                            
                                                                                
CStringPtr = Ptr;                                                               
CStringHndl = ^CStringPtr;                                                      
CStringHndlPtr = ^CStringHndl;                                                  
ProcPtr = Ptr;                                                                  
VoidProcPtr = ProcPtr;                                                          
WordProcPtr = ProcPtr;                                                          
LongProcPtr = ProcPtr;                                                          
                                                                                
IntPtr = ^Integer;                                                              
FPTPtr = Ptr ;                                                                  
String255 = STRING[255];                                                        
String255Ptr = ^String255;                                                      
String255Hndl = ^String255Ptr;                                                  
String255HndlPtr = ^String255Hndl;                                              
Str255 = String255;                                                             
StringPtr = String255Ptr;                                                       
StringHandle = ^StringPtr;                                                      
String32 = STRING[32];                                                          
String32Ptr = ^String32;                                                        
String32Handle = ^String32Ptr;                                                  
Str32 = String32;                                                               
                                                                                
PointPtr = ^Point;                                                              
Point = RECORD                                                                  
    v : Integer;                                                                
    h : Integer;                                                                
END;                                                                            
RectHndl = ^RectPtr;                                                            
RectPtr = ^Rect;                                                                
Rect = RECORD                                                                   
CASE INTEGER OF                                                                 
1:                                                                              
        (top: Integer;                                                          
        left: Integer;                                                          
        bottom: Integer;                                                        
        right: Integer);                                                        
2:                                                                              
        (topLeft: Point;                                                        
        botRight: Point);                                                       
3: (                                                                            
v1 : Integer;                                                                   
h1 : Integer;                                                                   
v2 : Integer;                                                                   
h2 : Integer);                                                                  
END;                                                                            
                                                                                
TimeRecHndl = ^TimeRecPtr;                                                      
TimeRecPtr = ^TimeRec;                                                          
TimeRec = PACKED RECORD                                                         
    second : Byte;                                                              
    minute : Byte;                                                              
    hour : Byte;                                                                
    year : Byte;                                                                
    day : Byte;                                                                 
    month : Byte;                                                               
    extra : Byte;                                                               
    weekDay : Byte;                                                             
END;                                                                            
                                                                                
RefDescriptor = Integer;                                                        
Ref = RECORD                                                                    
     CASE Integer OF                                                            
     refIsPointer : ( refIsPointer : Ptr ) ;                                    
     refIsHandle : ( refIsHandle : Handle ) ;                                   
     refIsResource : ( refIsResource : Longint ) ;                              
     refIsNewHandle : ( refIsNewHandle : Handle ) ;                             
END;                                                                            
                                                                                
IMPLEMENTATION                                                                  
END.                                                                            
