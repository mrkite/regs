{********************************************                                   
; File: QDAux.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT QDAUX;                                                                     
INTERFACE                                                                       
USES TYPES,QUICKDRAW;                                                           
CONST                                                                           
                                                                                
(* *** Private Constants ***                                                    
frameVerb = $00; {PicInfo - PRIVATE - for reference only }                      
picNop = $00; {PicInfo - PRIVATE - for reference only }                         
drawCharVerb = $00; {PicInfo - PRIVATE - for reference only }                   
paintVerb = $01; {PicInfo - PRIVATE - for reference only }                      
picClipRgn = $01; {PicInfo - PRIVATE - for reference only }                     
drawTextVerb  = $01; {PicInfo - PRIVATE - for reference only }                  
eraseVerb = $02; {PicInfo - PRIVATE - for reference only }                      
picBkPat = $02; {PicInfo - PRIVATE - for reference only }                       
drawCStrVerb = $02; {PicInfo - PRIVATE - for reference only }                   
invertVerb = $03; {PicInfo - PRIVATE - for reference only }                     
picTxFont = $03; {PicInfo - PRIVATE - for reference only }                      
fillVerb = $04; {PicInfo - PRIVATE - for reference only }                       
picTxFace = $04; {PicInfo - PRIVATE - for reference only }                      
picTxMode = $05; {PicInfo - PRIVATE - for reference only }                      
picSpExtra = $06; {PicInfo - PRIVATE - for reference only }                     
picPnSize = $07; {PicInfo - PRIVATE - for reference only }                      
picPnMode = $08; {PicInfo - PRIVATE - for reference only }                      
picPnPat = $09; {PicInfo - PRIVATE - for reference only }                       
picThePat = $0A; {PicInfo - PRIVATE - for reference only }                      
picOvSize = $0B; {PicInfo - PRIVATE - for reference only }                      
picOrigin = $0C; {PicInfo - PRIVATE - for reference only }                      
picTxSize = $0D; {PicInfo - PRIVATE - for reference only }                      
picFGColor = $0E; {PicInfo - PRIVATE - for reference only }                     
picBGColor = $0F; {PicInfo - PRIVATE - for reference only }                     
picTxRatio = $10; {PicInfo - PRIVATE - for reference only }                     
picVersion = $11; {PicInfo - PRIVATE - for reference only }                     
lineNoun = $20; {PicInfo - PRIVATE - for reference only }                       
picLine = $20; {PicInfo - PRIVATE - for reference only }                        
picLineFrom = $21; {PicInfo - PRIVATE - for reference only }                    
picShortL = $22; {PicInfo - PRIVATE - for reference only }                      
picShortLFrom = $23; {PicInfo - PRIVATE - for reference only }                  
picLongText = $28; {PicInfo - PRIVATE - for reference only }                    
picDHText = $29; {PicInfo - PRIVATE - for reference only }                      
picDVText = $2A; {PicInfo - PRIVATE - for reference only }                      
picDVDHText = $2B; {PicInfo - PRIVATE - for reference only }                    
rectNoun = $30; {PicInfo - PRIVATE - for reference only }                       
rRectNoun = $40; {PicInfo - PRIVATE - for reference only }                      
ovalNoun = $50; {PicInfo - PRIVATE - for reference only }                       
arcNoun = $60; {PicInfo - PRIVATE - for reference only }                        
polyNoun = $70; {PicInfo - PRIVATE - for reference only }                       
rgnNoun = $80; {PicInfo - PRIVATE - for reference only }                        
mapNoun = $90; {PicInfo - PRIVATE - for reference only }                        
picBitsRect = $90; {PicInfo - PRIVATE - for reference only }                    
picBitsRgn = $91; {PicInfo - PRIVATE - for reference only }                     
picPBitsRect = $98; {PicInfo - PRIVATE - for reference only }                   
picPBitsRgn = $99; {PicInfo - PRIVATE - for reference only }                    
picShortComment = $A0; {PicInfo - PRIVATE - for reference only }                
picLongComment = $A1; {PicInfo - PRIVATE - for reference only }                 
picEnd = $FF; {PicInfo - PRIVATE - for reference only }                         
   *** Private Constants *** *)                                                 
                                                                                
resMode640PMask = $00; {SeedFill/CalcMask -  }                                  
resMode640DMask = $01; {SeedFill/CalcMask -  }                                  
resMode320Mask = $02; {SeedFill/CalcMask -  }                                   
destModeCopyMask = $0000; {SeedFill/CalcMask -  }                               
destModeLeaveMask = $1000; {SeedFill/CalcMask -  }                              
destModeOnesMask = $2000; {SeedFill/CalcMask -  }                               
destModeZerosMask = $3000; {SeedFill/CalcMask -  }                              
destModeError = $1212; {Error -  }                                              
                                                                                
TYPE                                                                            
QDIconRecordHndl = ^QDIconRecordPtr;                                            
QDIconRecordPtr = ^QDIconRecord;                                                
QDIconRecord = RECORD                                                           
    iconType : Integer;                                                         
    iconSize : Integer;                                                         
    iconHeight : Integer;                                                       
    iconWidth : Integer;                                                        
    iconImage : PACKED ARRAY[1..1] OF Byte;                                     
    iconMask : PACKED ARRAY[1..1] OF Byte;                                      
END;                                                                            
PicHndl = ^PicPtr;                                                              
PicPtr = ^Picture;                                                              
Picture = RECORD                                                                
    picSCB : Integer;                                                           
    picFrame : Rect; { Followed by picture opcodes  }                           
END;                                                                            
PROCEDURE QDAuxBootInit   ; Tool $12,$01;                                       
PROCEDURE QDAuxStartUp   ; Tool $12,$02;                                        
PROCEDURE QDAuxShutDown   ; Tool $12,$03;                                       
FUNCTION QDAuxVersion  : Integer ; Tool $12,$04;                                
PROCEDURE QDAuxReset   ; Tool $12,$05;                                          
FUNCTION QDAuxStatus  : Boolean ; Tool $12,$06;                                 
PROCEDURE CopyPixels ( srcLocPtr:LocInfo; destLocPtr:LocInfo; srcRect:Rect;     
destRect:Rect; xferMode:Integer; makeRgn:RgnHandle)  ; Tool $12,$09;            
PROCEDURE DrawIcon ( iconPtr:QDIconRecord; displayMode:Integer; xPos:Integer;   
yPos:Integer)  ; Tool $12,$0B;                                                  
PROCEDURE SpecialRect ( rectPtr:Rect; frameColor:Integer; fillColor:Integer)  ; 
Tool $12,$0C;                                                                   
PROCEDURE WaitCursor   ; Tool $12,$0A;                                          
PROCEDURE SeedFill ( srcLocInfoPtr:LocInfo; srcRect:Rect;                       
dstLocInfoPtr:LocInfo; dstRect:Rect; seedH:Integer; seedV:Integer;              
resMode:Integer; U__patternPtr:PatternPtr; leakTblPtr:Ptr)  ; Tool $12,$0D;     
PROCEDURE CalcMask ( srcLocInfoPtr:LocInfo; srcRect:Rect;                       
dstLocInfoPtr:LocInfo; dstRect:Rect; resMode:Integer; U__patternPtr:PatternPtr; 
leakTblPtr:Ptr)  ; Tool $12,$0E;                                                
PROCEDURE PicComment ( kind:Integer; dataSize:Integer; dataHandle:Handle)  ;    
Tool $04,$B8;                                                                   
PROCEDURE ClosePicture   ; Tool $04,$B9;                                        
PROCEDURE DrawPicture ( picHandle:PicHndl; destRect:Rect)  ; Tool $04,$BA;      
PROCEDURE KillPicture ( pichandle:PicHndl)  ; Tool $04,$BB;                     
FUNCTION OpenPicture ( picFrame:Rect) : PicHndl ; Tool $04,$B7;                 
IMPLEMENTATION                                                                  
END.                                                                            
