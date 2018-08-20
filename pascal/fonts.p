{********************************************                                   
; File: Fonts.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT FONTS;                                                                     
INTERFACE                                                                       
USES TYPES,QUICKDRAW;                                                           
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
fmDupStartUpErr = $1B01; {error - duplicate FMStartUp call }                    
fmResetErr = $1B02; {error - can't reset the Font Manager }                     
fmNotActiveErr = $1B03; {error - Font Manager not active }                      
fmFamNotFndErr = $1B04; {error - family not found }                             
fmFontNtFndErr = $1B05; {error - font not found }                               
fmFontMemErr = $1B06; {error - font not in memory }                             
fmSysFontErr = $1B07; {error - system font cannot be purgeable }                
fmBadFamNumErr = $1B08; {error - illegal family number }                        
fmBadSizeErr = $1B09; {error - illegal size }                                   
fmBadNameErr = $1B0A; {error - illegal name length }                            
fmMenuErr = $1B0B; {error - fix font menu never called }                        
fmScaleSizeErr = $1B0C; {error - scaled size of font exeeds limits }            
   *** Toolset Errors *** *)                                                    
                                                                                
newYork = $0002; {Family Number -  }                                            
geneva = $0003; {Family Number -  }                                             
monaco = $0004; {Family Number -  }                                             
venice = $0005; {Family Number -  }                                             
london = $0006; {Family Number -  }                                             
athens = $0007; {Family Number -  }                                             
sanFran = $0008; {Family Number -  }                                            
toronto = $0009; {Family Number -  }                                            
cairo = $000B; {Family Number -  }                                              
losAngeles = $000C; {Family Number -  }                                         
times = $0014; {Family Number -  }                                              
helvetica = $0015; {Family Number -  }                                          
courier = $0016; {Family Number -  }                                            
symbol = $0017; {Family Number -  }                                             
taliesin = $0018; {Family Number -  }                                           
shaston = $FFFE; {Family Number -  }                                            
baseOnlyBit = $0020; {FamSpecBits -  }                                          
notBaseBit = $0020; {FamStatBits -  }                                           
memOnlyBit = $0001; {FontSpecBits -  }                                          
realOnlyBit = $0002; {FontSpecBits -  }                                         
anyFamBit = $0004; {FontSpecBits -  }                                           
anyStyleBit = $0008; {FontSpecBits -  }                                         
anySizeBit = $0010; {FontSpecBits -  }                                          
memBit = $0001; {FontStatBits -  }                                              
unrealBit = $0002; {FontStatBits -  }                                           
apFamBit = $0004; {FontStatBits -  }                                            
apVarBit = $0008; {FontStatBits -  }                                            
purgeBit = $0010; {FontStatBits -  }                                            
notDiskBit = $0020; {FontStatBits -  }                                          
notFoundBit = $8000; {FontStatBits -  }                                         
dontScaleBit = $0001; {Scale Word -  }                                          
                                                                                
TYPE                                                                            
FontStatRecHndl = ^FontStatRecPtr;                                              
FontStatRecPtr = ^FontStatRec;                                                  
FontStatRec = RECORD                                                            
    resultID : FontID;                                                          
    resultStats : Integer;                                                      
END;                                                                            
PROCEDURE FMBootInit   ; Tool $1B,$01;                                          
PROCEDURE FMStartUp ( userID:Integer; dPageAddr:Integer)  ; Tool $1B,$02;       
PROCEDURE FMShutDown   ; Tool $1B,$03;                                          
FUNCTION FMVersion  : Integer ; Tool $1B,$04;                                   
PROCEDURE FMReset   ; Tool $1B,$05;                                             
FUNCTION FMStatus  : Boolean ; Tool $1B,$06;                                    
PROCEDURE AddFamily ( famNum:Integer; famName:Str255)  ; Tool $1B,$0D;          
PROCEDURE AddFontVar ( fontHandle:FontHndl; newSpecs:Integer)  ; Tool $1B,$14;  
FUNCTION ChooseFont ( currentID:FontID; famSpecs:Integer) : FontID ; Tool       
$1B,$16;                                                                        
FUNCTION CountFamilies ( famSpecs:Integer) : Integer ; Tool $1B,$09;            
FUNCTION CountFonts ( desiredID:FontId; fontSpecs:Integer) : Integer ; Tool     
$1B,$10;                                                                        
FUNCTION FamNum2ItemID ( famNum:Integer) : Integer ; Tool $1B,$1B;              
FUNCTION FindFamily ( famSpecs:Integer; positionNum:Integer; famName:Str255) :  
Integer ; Tool $1B,$0A;                                                         
PROCEDURE FindFontStats ( desiredID:FontId; fontSpecs:Integer;                  
positionNum:Integer;VAR resultPtr:FontStatRec)  ; Tool $1B,$11;                 
PROCEDURE FixFontMenu ( menuID:Integer; startingID:Integer; famSpecs:Integer)   
; Tool $1B,$15;                                                                 
FUNCTION FMGetCurFID  : FontID ; Tool $1B,$1A;                                  
FUNCTION FMGetSysFID  : FontID ; Tool $1B,$19;                                  
PROCEDURE FMSetSysFont ( newFontID:FontID)  ; Tool $1B,$18;                     
FUNCTION GetFamInfo ( famNum:Integer; famName:Str255) : Integer ; Tool $1B,$0B; 
FUNCTION GetFamNum ( famName:Str255) : Integer ; Tool $1B,$0C;                  
PROCEDURE InstallFont ( desiredID:FontID; scaleWord:Integer)  ; Tool $1B,$0E;   
PROCEDURE InstallWithStats ( desiredID:FontID; scaleWord:Integer;               
resultPtr:Ptr)  ; Tool $1B,$1C;                                                 
FUNCTION ItemID2FamNum ( itemID:Integer) : Integer ; Tool $1B,$17;              
PROCEDURE LoadFont ( desiredID:FontID; fontSpecs:Integer;                       
positionNum:Integer;VAR resultPtr:FontStatRec)  ; Tool $1B,$12;                 
PROCEDURE LoadSysFont   ; Tool $1B,$13;                                         
PROCEDURE SetPurgeStat ( theFontID:FontID; purgeStat:Integer)  ; Tool $1B,$0F;  
IMPLEMENTATION                                                                  
END.                                                                            
